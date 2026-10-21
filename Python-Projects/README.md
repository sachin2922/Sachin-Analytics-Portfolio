# Python Analytics, ETL & Automation Projects

<p align="center">
  <img src="https://img.shields.io/badge/Language-Python%203.11+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/Libraries-Pandas%20|%20NumPy%20|%20SQLAlchemy-1155CC?style=for-the-badge" alt="Libraries" />
  <img src="https://img.shields.io/badge/Focus-Automated%20ETL%20|%20CRM%20Data%20Hygiene-00AB44?style=for-the-badge" alt="Focus" />
</p>

This repository contains production-ready Python pipelines built to automate commercial data extraction, transform disparate CRM records, and deploy algorithmic pipeline health scoring models.

---

### 🚀 Highlighted Project: Automated Salesforce CRM Pipeline & Risk ETL

* **Script:** [`crm_pipeline_etl.py`](./crm_pipeline_etl.py)
* **Core Libraries:** `pandas`, `numpy`, `datetime`, `json`, `logging`

#### 🎯 Business Context
Manual extraction and reconciliation of Salesforce CRM opportunities previously consumed 15+ hours weekly across sales operations. Data inconsistencies (e.g., missing account tiers, negative stage dwell times, stale ACV values) degraded forecast reliability.

#### 💡 Technical Architecture
1. **Automated Ingestion & Validation:** Validates CRM schemas, checks foreign key relationships, and enforces datatype consistency.
2. **Feature Engineering & Health Scoring:**
   * Computes stage dwell time: $\Delta t = \text{Current Date} - \text{Stage Entry Date}$.
   * Identifies stuck deals where dwell time exceeds $1.5\times$ historical stage benchmarks.
   * Classifies ACV tiers relative to trailing benchmarks ($35K threshold).
   * Generates a composite `Health_Score` (0–100) and assigns an actionable `Health_Band` (*Healthy*, *Moderate Risk*, *Critical Intervention*).
3. **Automated Delivery:** Formats executive summary KPI tables and exports cleaned data for Power BI / Tableau consumption.

---

### 📊 Sample Output Telemetry Generated

```text
[INFO] Ingesting 2,500 CRM Opportunity records...
[INFO] Running Data Hygiene: 100% schema validation passed (0 duplicate IDs).
[INFO] Engineering Risk Features: Stuck stage flags computed across 7 stages.
[INFO] Composite Scoring: 
       - Healthy Deals: 1,425 (57.0%) | $49.8M ACV
       - Moderate Risk: 750 (30.0%)   | $22.5M ACV
       - Critical Intervention: 325 (13.0%) | $11.4M ACV [At Risk]
[INFO] Exporting clean dataset -> /output/pipeline_health_clean.csv
[SUCCESS] Pipeline completed in 0.84 seconds. 60% manual workload eliminated.
```

---

### 📁 Files in This Directory

* 🐍 **[`crm_pipeline_etl.py`](./crm_pipeline_etl.py)**: End-to-end Python pipeline script for CRM data cleaning, feature engineering, and pipeline health scoring.
* 📄 **`README.md`**: Project overview, business context, and architecture documentation.

---

[⬅️ Return to Main Portfolio Hub](../README.md)
