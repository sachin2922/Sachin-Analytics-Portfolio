-- =============================================================================
-- Enterprise Pipeline Health Scoring & Stuck Stage Diagnostic Model
-- Author: Sachin Sharma (Commercial Analytics & RevOps Leader)
-- Dialect: ANSI SQL (Compatible with Snowflake, PostgreSQL, BigQuery, MS SQL)
-- Description:
--     Multi-tier Common Table Expression (CTE) pipeline that calculates stage
--     dwell times, identifies stuck deal bottlenecks (>1.5x stage benchmark),
--     evaluates ACV distributions, and assigns composite Health Bands.
-- =============================================================================

WITH 

-- CTE 1: Define Stage SLA Benchmarks (Average historical days spent per stage)
Stage_Benchmarks AS (
    SELECT 'Prospecting' AS stage_name, 14 AS benchmark_days UNION ALL
    SELECT 'Qualification', 21 UNION ALL
    SELECT 'Needs Analysis', 30 UNION ALL
    SELECT 'Value Proposition', 25 UNION ALL
    SELECT 'Decision Makers', 35 UNION ALL
    SELECT 'Proposal / Quote', 20 UNION ALL
    SELECT 'Negotiation / Review', 15
),

-- CTE 2: Base Normalized Opportunity Data
Cleaned_Opportunities AS (
    SELECT
        opp.opportunity_id,
        opp.account_id,
        COALESCE(acc.account_name, 'Unknown Account') AS account_name,
        COALESCE(acc.account_tier, 'Non-Prime') AS account_tier,
        opp.stage_name,
        opp.lead_source,
        COALESCE(opp.owner_id, 'UNASSIGNED') AS owner_id,
        CAST(opp.acv_amount AS NUMERIC(12, 2)) AS acv_amount,
        CAST(opp.created_date AS DATE) AS created_date,
        CAST(opp.stage_entry_date AS DATE) AS stage_entry_date,
        CURRENT_DATE AS evaluation_date
    FROM salesforce_opportunities opp
    LEFT JOIN salesforce_accounts acc
        ON opp.account_id = acc.account_id
    WHERE opp.is_closed = FALSE  -- Active pipeline deals only
      AND opp.is_deleted = FALSE
),

-- CTE 3: Stage Dwell Time & Velocity Metrics
Dwell_Time_Metrics AS (
    SELECT
        c.opportunity_id,
        c.account_id,
        c.account_name,
        c.account_tier,
        c.stage_name,
        c.lead_source,
        c.owner_id,
        c.acv_amount,
        c.created_date,
        c.stage_entry_date,
        
        -- Dwell Time Calculations
        (c.evaluation_date - c.stage_entry_date) AS days_in_current_stage,
        (c.evaluation_date - c.created_date) AS total_deal_age_days,
        COALESCE(sb.benchmark_days, 20) AS benchmark_stage_days,
        
        -- Ratio of actual dwell to benchmark
        ROUND(
            CAST((c.evaluation_date - c.stage_entry_date) AS NUMERIC) / 
            NULLIF(COALESCE(sb.benchmark_days, 20), 0), 
            2
        ) AS dwell_ratio,
        
        -- Rank opportunities within each account by ACV (Window Function)
        DENSE_RANK() OVER (
            PARTITION BY c.account_id 
            ORDER BY c.acv_amount DESC
        ) AS account_opp_rank,
        
        -- Running Total ACV by Stage (Window Function)
        SUM(c.acv_amount) OVER (
            PARTITION BY c.stage_name
        ) AS stage_total_acv

    FROM Cleaned_Opportunities c
    LEFT JOIN Stage_Benchmarks sb
        ON c.stage_name = sb.stage_name
),

-- CTE 4: Risk Flagging & Composite Health Scoring
Risk_Scored_Pipeline AS (
    SELECT
        d.*,
        
        -- Stuck Stage Flag (>1.5x historical benchmark)
        CASE 
            WHEN d.dwell_ratio > 1.50 THEN 1 
            ELSE 0 
        END AS is_stuck_stage,
        
        -- Sub-Benchmark ACV Flag ($35K average threshold)
        CASE 
            WHEN d.acv_amount < 35000.00 THEN 1 
            ELSE 0 
        END AS is_below_avg_acv,
        
        -- Unassigned Opportunity Flag
        CASE 
            WHEN d.owner_id = 'UNASSIGNED' THEN 1 
            ELSE 0 
        END AS is_unassigned,
        
        -- Composite Health Score (0 - 100)
        GREATEST(
            0,
            LEAST(
                100,
                ROUND(
                    100.0
                    -- Dwell delay penalty (up to 45 points)
                    - (CASE WHEN d.dwell_ratio > 1.0 THEN LEAST(45.0, (d.dwell_ratio - 1.0) * 35.0) ELSE 0.0 END)
                    -- Unassigned penalty (25 points)
                    - (CASE WHEN d.owner_id = 'UNASSIGNED' THEN 25.0 ELSE 0.0 END)
                    -- Sub-benchmark ACV penalty (15 points)
                    - (CASE WHEN d.acv_amount < 35000.00 THEN 15.0 ELSE 0.0 END)
                    -- Strategic Prime account boost (10 points)
                    + (CASE WHEN d.account_tier = 'Prime' THEN 10.0 ELSE 0.0 END)
                )
            )
        ) AS composite_health_score

    FROM Dwell_Time_Metrics d
),

-- CTE 5: Health Band Categorization
Classified_Pipeline AS (
    SELECT
        r.*,
        CASE
            WHEN r.composite_health_score >= 75 THEN 'Healthy'
            WHEN r.composite_health_score >= 50 THEN 'Moderate Risk'
            ELSE 'Critical Intervention'
        END AS health_band,
        
        -- Exposure metric: ACV at critical risk
        CASE
            WHEN r.composite_health_score < 50 THEN r.acv_amount
            ELSE 0.00
        END AS acv_at_critical_risk

    FROM Risk_Scored_Pipeline r
)

-- Final Output: Executive Triage View
SELECT
    opportunity_id,
    account_name,
    account_tier,
    stage_name,
    lead_source,
    owner_id,
    acv_amount,
    days_in_current_stage,
    benchmark_stage_days,
    dwell_ratio,
    is_stuck_stage,
    is_unassigned,
    composite_health_score,
    health_band,
    acv_at_critical_risk,
    
    -- Priority Ranking for Weekly Deal Intervention
    ROW_NUMBER() OVER (
        ORDER BY 
            CASE health_band 
                WHEN 'Critical Intervention' THEN 1 
                WHEN 'Moderate Risk' THEN 2 
                ELSE 3 
            END ASC,
            acv_amount DESC
    ) AS intervention_priority_rank

FROM Classified_Pipeline
ORDER BY intervention_priority_rank ASC;
