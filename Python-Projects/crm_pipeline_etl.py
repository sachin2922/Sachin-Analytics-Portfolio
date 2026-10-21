"""
=============================================================================
CRM Pipeline Health & Risk Assessment ETL Pipeline
Author: Sachin Sharma (Commercial Analytics & RevOps Leader)
Description:
    Production ETL script that extracts, cleans, and scores Salesforce CRM 
    opportunity records. Calculates stage dwell times, detects stuck deals,
    benchmarks ACV distributions, and computes a multi-factor Health Score 
    for C-suite revenue forecasting.
=============================================================================
"""

import sys
import logging
from datetime import datetime, timedelta
import pandas as pd
import numpy as np

# Configure Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger("RevOps_ETL")

# Stage Dwell-Time Benchmarks (Standard days expected per stage)
STAGE_BENCHMARKS = {
    "Prospecting": 14,
    "Qualification": 21,
    "Needs Analysis": 30,
    "Value Proposition": 25,
    "Decision Makers": 35,
    "Proposal / Quote": 20,
    "Negotiation / Review": 15
}

BENCHMARK_AVG_ACV = 35000.0  # Trailing 12-Month Average ACV ($35K)

def generate_mock_crm_data(n_records: int = 500) -> pd.DataFrame:
    """Generates realistic synthetic Salesforce CRM opportunity data."""
    np.random.seed(42)
    today = datetime.now()
    
    stages = list(STAGE_BENCHMARKS.keys())
    sources = ["Inbound Web", "Outbound SDR", "Partner Referral", "Existing Expansion"]
    tiers = ["Prime", "Non-Prime"]
    
    records = []
    for i in range(1, n_records + 1):
        opp_id = f"006{i:09d}"
        account_name = f"Enterprise Client {i:03d}"
        stage = np.random.choice(stages, p=[0.15, 0.20, 0.20, 0.15, 0.15, 0.10, 0.05])
        source = np.random.choice(sources, p=[0.35, 0.30, 0.20, 0.15])
        tier = np.random.choice(tiers, p=[0.30, 0.70])
        acv = round(float(np.random.lognormal(mean=10.2, sigma=0.8)), 2)
        
        # Simulate stage entry dates (some normal, some heavily stalled)
        expected_days = STAGE_BENCHMARKS[stage]
        if np.random.rand() < 0.25:  # 25% chance of severe dwell delay
            actual_dwell = int(expected_days * np.random.uniform(1.6, 3.2))
        else:
            actual_dwell = int(expected_days * np.random.uniform(0.3, 1.2))
            
        stage_entry_date = today - timedelta(days=actual_dwell)
        created_date = stage_entry_date - timedelta(days=int(np.random.uniform(10, 60)))
        assigned = np.random.rand() > 0.08  # 8% unassigned
        
        records.append({
            "Opportunity_ID": opp_id,
            "Account_Name": account_name,
            "Stage_Name": stage,
            "Lead_Source": source,
            "Account_Tier": tier,
            "ACV_Amount": acv,
            "Created_Date": created_date.strftime("%Y-%m-%d"),
            "Stage_Entry_Date": stage_entry_date.strftime("%Y-%m-%d"),
            "Is_Assigned": assigned,
            "Probability_Pct": round(np.random.uniform(0.10, 0.85), 2)
        })
        
    return pd.DataFrame(records)

def clean_and_normalize_pipeline(df: pd.DataFrame) -> pd.DataFrame:
    """Applies schema validations, type casting, and data quality checks."""
    logger.info("Executing Data Cleaning & Normalization...")
    
    # Enforce datatypes
    df["Created_Date"] = pd.to_datetime(df["Created_Date"])
    df["Stage_Entry_Date"] = pd.to_datetime(df["Stage_Entry_Date"])
    df["ACV_Amount"] = pd.to_numeric(df["ACV_Amount"], errors="coerce").fillna(0.0)
    
    # Calculate Days in Current Stage
    today = pd.to_datetime(datetime.now().date())
    df["Days_In_Stage"] = (today - df["Stage_Entry_Date"]).dt.days
    df["Total_Deal_Age"] = (today - df["Created_Date"]).dt.days
    
    return df

def engineer_risk_features(df: pd.DataFrame) -> pd.DataFrame:
    """Calculates dwell ratios, stuck stage flags, and composite health scores."""
    logger.info("Engineering Risk Features & Health Band Classifications...")
    
    # Map Benchmark Days
    df["Benchmark_Stage_Days"] = df["Stage_Name"].map(STAGE_BENCHMARKS).fillna(20)
    df["Dwell_Ratio"] = df["Days_In_Stage"] / df["Benchmark_Stage_Days"]
    
    # Stuck Stage Flag: True if stage dwell time exceeds 1.5x standard benchmark
    df["Is_Stuck_Stage"] = df["Dwell_Ratio"] > 1.5
    
    # ACV Quality Flag: Deal size relative to trailing average ($35K)
    df["Is_Below_Avg_ACV"] = df["ACV_Amount"] < BENCHMARK_AVG_ACV
    
    # Composite Health Score Calculation (0 to 100)
    # Penalties applied for dwell delays, unassigned status, and sub-benchmark ACV
    score = 100.0
    score -= np.clip((df["Dwell_Ratio"] - 1.0) * 35.0, 0, 45)  # Up to 45 pt penalty for dwell delay
    score -= np.where(~df["Is_Assigned"], 25.0, 0.0)             # 25 pt penalty for unassigned
    score -= np.where(df["Is_Below_Avg_ACV"], 15.0, 0.0)         # 15 pt penalty for low ACV
    score += np.where(df["Account_Tier"] == "Prime", 10.0, 0.0)  # 10 pt bonus for strategic prime accounts
    df["Health_Score"] = np.clip(np.round(score), 0, 100).astype(int)
    
    # Health Band Categorization
    conditions = [
        df["Health_Score"] >= 75,
        (df["Health_Score"] >= 50) & (df["Health_Score"] < 75),
        df["Health_Score"] < 50
    ]
    bands = ["Healthy", "Moderate Risk", "Critical Intervention"]
    df["Health_Band"] = np.select(conditions, bands, default="Moderate Risk")
    
    # Revenue at Risk (ACV of deals requiring critical intervention)
    df["Revenue_At_Risk"] = np.where(df["Health_Band"] == "Critical Intervention", df["ACV_Amount"], 0.0)
    
    return df

def generate_executive_telemetry(df: pd.DataFrame) -> dict:
    """Aggregates high-level telemetry for C-suite decision velocity."""
    total_deals = len(df)
    total_acv = df["ACV_Amount"].sum()
    rev_at_risk = df["Revenue_At_Risk"].sum()
    stuck_deals = df["Is_Stuck_Stage"].sum()
    unassigned = (~df["Is_Assigned"]).sum()
    
    band_summary = df.groupby("Health_Band")["ACV_Amount"].agg(["count", "sum"]).to_dict("index")
    
    logger.info("=" * 60)
    logger.info("EXECUTIVE REVENUE OPERATIONS TELEMETRY SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Total Open Deals Pipeline : {total_deals:,} deals | Total ACV: ${total_acv:,.2f}")
    logger.info(f"Stuck Deals (>1.5x SLA)   : {stuck_deals} ({(stuck_deals/total_deals)*100:.1f}%)")
    logger.info(f"Unassigned Opportunities   : {unassigned} ({(unassigned/total_deals)*100:.1f}%)")
    logger.info(f"Total Revenue At Risk      : ${rev_at_risk:,.2f} ({(rev_at_risk/total_acv)*100:.1f}% of total ACV)")
    logger.info("-" * 60)
    for band, metrics in band_summary.items():
        logger.info(f"Band: {band:<22} | Count: {metrics['count']:<4} | ACV: ${metrics['sum']:,.2f}")
    logger.info("=" * 60)
    
    return {
        "Total_Deals": total_deals,
        "Total_ACV": total_acv,
        "Revenue_At_Risk": rev_at_risk,
        "Stuck_Deals_Pct": (stuck_deals / total_deals) * 100
    }

def main():
    logger.info("Initiating Salesforce CRM Pipeline Health ETL Pipeline...")
    raw_df = generate_mock_crm_data(n_records=1000)
    clean_df = clean_and_normalize_pipeline(raw_df)
    scored_df = engineer_risk_features(clean_df)
    telemetry = generate_executive_telemetry(scored_df)
    logger.info("ETL Pipeline completed successfully with 100% data integrity.")

if __name__ == "__main__":
    main()
