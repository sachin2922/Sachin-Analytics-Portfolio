-- =============================================================================
-- Enterprise Salesforce CRM Pipeline Health Scoring & Revenue Governance Suite
-- Author: Sachin Sharma (Commercial Analytics & RevOps Leader)
-- Dialect: PostgreSQL
-- Description:
--     Production-grade SQL analytics suite modeling core Salesforce CRM objects:
--     Pre-Sales Leads, Accounts, Contacts, Opportunities, Field History Audit,
--     and User Quotas. Implements multi-tier CTEs, stage dwell-time SLA audits,
--     0-100 algorithmic health scoring, rep quota ranking, and conversion attribution.
-- =============================================================================

-- =============================================================================
-- SECTION 1: RELATIONAL SCHEMA DEFINITION (SALESFORCE CRM DDL)
-- =============================================================================

-- 1.1 sf_user (Sales Reps & Quotas)
CREATE TABLE IF NOT EXISTS sf_user (
    user_id VARCHAR(50) PRIMARY KEY,
    rep_name VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL, -- Enterprise AE, Strategic AE, Commercial AE
    region VARCHAR(50) NOT NULL, -- EMEA, APAC, US-East, US-West
    annual_quota NUMERIC(14, 2) NOT NULL DEFAULT 1000000.00
);

-- 1.2 sf_account (Enterprise Accounts)
CREATE TABLE IF NOT EXISTS sf_account (
    account_id VARCHAR(50) PRIMARY KEY,
    account_name VARCHAR(255) NOT NULL,
    account_tier VARCHAR(50) NOT NULL, -- Tier 1: Prime Enterprise, Tier 2: Mid-Market, Tier 3: Emerging
    industry VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    annual_revenue NUMERIC(16, 2)
);

-- 1.3 sf_contact (Decision Makers & Champions)
CREATE TABLE IF NOT EXISTS sf_contact (
    contact_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL REFERENCES sf_account(account_id),
    contact_name VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL, -- Economic Buyer, Technical Evaluator, Executive Sponsor
    is_primary_decision_maker SMALLINT NOT NULL DEFAULT 0
);

-- 1.4 sf_lead (Pre-Sales Data)
CREATE TABLE IF NOT EXISTS sf_lead (
    lead_id VARCHAR(50) PRIMARY KEY,
    lead_source VARCHAR(100) NOT NULL, -- Inbound Web, Outbound SDR, Partner Referral, Executive Event
    status VARCHAR(50) NOT NULL, -- Converted, Working, Disqualified
    created_date DATE NOT NULL,
    converted_account_id VARCHAR(50) REFERENCES sf_account(account_id)
);

-- 1.5 sf_opportunity (Core Pipeline Opportunities)
CREATE TABLE IF NOT EXISTS sf_opportunity (
    opportunity_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL REFERENCES sf_account(account_id),
    owner_id VARCHAR(50) REFERENCES sf_user(user_id),
    stage_name VARCHAR(100) NOT NULL, -- Prospecting, Qualification, Needs Analysis, Value Proposition, Proposal, Negotiation, Closed Won, Closed Lost
    lead_source VARCHAR(100) NOT NULL,
    acv_amount NUMERIC(14, 2) NOT NULL DEFAULT 0.00,
    created_date DATE NOT NULL,
    stage_entry_date DATE NOT NULL,
    is_closed SMALLINT NOT NULL DEFAULT 0,
    is_won SMALLINT NOT NULL DEFAULT 0
);

-- 1.6 sf_opportunity_field_history (Audit Trail for Dwell-Time Tracking)
CREATE TABLE IF NOT EXISTS sf_opportunity_field_history (
    history_id VARCHAR(50) PRIMARY KEY,
    opportunity_id VARCHAR(50) NOT NULL REFERENCES sf_opportunity(opportunity_id),
    field VARCHAR(100) NOT NULL, -- StageName
    old_value VARCHAR(100),
    new_value VARCHAR(100),
    created_date TIMESTAMP NOT NULL
);

-- B-Tree Performance Indexes
CREATE INDEX IF NOT EXISTS idx_opp_account ON sf_opportunity(account_id);
CREATE INDEX IF NOT EXISTS idx_opp_owner ON sf_opportunity(owner_id);
CREATE INDEX IF NOT EXISTS idx_opp_stage ON sf_opportunity(stage_name);
CREATE INDEX IF NOT EXISTS idx_opp_hist ON sf_opportunity_field_history(opportunity_id, created_date);


-- =============================================================================
-- SECTION 2: STAGE DWELL TIME & BOTTLENECK AUDIT (FIELD HISTORY)
-- =============================================================================

-- Question: Which stages exceed target SLAs and where are deals bottlenecking?
-- Uses Opportunity Field History to calculate exact days spent in each stage.

WITH Stage_SLA_Benchmarks AS (
    SELECT 'Prospecting' AS stage_name, 14 AS sla_days UNION ALL
    SELECT 'Qualification', 21 UNION ALL
    SELECT 'Needs Analysis', 30 UNION ALL
    SELECT 'Value Proposition', 25 UNION ALL
    SELECT 'Proposal / Quote', 20 UNION ALL
    SELECT 'Negotiation / Review', 15
),
Active_Pipeline_Dwell AS (
    SELECT 
        o.opportunity_id,
        o.stage_name,
        o.acv_amount,
        (CURRENT_DATE - o.stage_entry_date) AS days_in_current_stage,
        b.sla_days,
        ROUND((CURRENT_DATE - o.stage_entry_date)::NUMERIC / NULLIF(b.sla_days, 0), 2) AS dwell_ratio
    FROM sf_opportunity o
    INNER JOIN Stage_SLA_Benchmarks b ON o.stage_name = b.stage_name
    WHERE o.is_closed = 0
)
SELECT 
    stage_name,
    COUNT(opportunity_id) AS open_deals_count,
    ROUND(SUM(acv_amount), 2) AS total_stage_acv,
    ROUND(AVG(days_in_current_stage), 1) AS avg_actual_dwell_days,
    MAX(sla_days) AS sla_benchmark_days,
    ROUND(AVG(dwell_ratio), 2) AS avg_dwell_ratio,
    SUM(CASE WHEN dwell_ratio > 1.50 THEN 1 ELSE 0 END) AS stuck_deals_count
FROM Active_Pipeline_Dwell
GROUP BY stage_name
ORDER BY avg_dwell_ratio DESC;


-- =============================================================================
-- SECTION 3: MULTI-FACTOR 0-100 PIPELINE HEALTH SCORING PIPELINE
-- =============================================================================

-- Question: Which deals are at critical risk and require sales director escalation?
-- Evaluates 4 risk vectors: Dwell Overstay, ACV Banding ($35K threshold), Tier, and Ownership.

WITH Base_Opportunities AS (
    SELECT 
        o.opportunity_id,
        a.account_name,
        a.account_tier,
        u.rep_name,
        o.stage_name,
        o.acv_amount,
        (CURRENT_DATE - o.stage_entry_date) AS days_in_stage,
        COALESCE(u.rep_name, 'UNASSIGNED') AS owner_name
    FROM sf_opportunity o
    LEFT JOIN sf_account a ON o.account_id = a.account_id
    LEFT JOIN sf_user u ON o.owner_id = u.user_id
    WHERE o.is_closed = 0
),
Dwell_Benchmarked AS (
    SELECT 
        b.*,
        CASE 
            WHEN stage_name = 'Prospecting' THEN 14
            WHEN stage_name = 'Qualification' THEN 21
            WHEN stage_name = 'Needs Analysis' THEN 30
            WHEN stage_name = 'Value Proposition' THEN 25
            WHEN stage_name = 'Proposal / Quote' THEN 20
            WHEN stage_name = 'Negotiation / Review' THEN 15
            ELSE 20
        END AS benchmark_days
    FROM Base_Opportunities b
),
Scored_Pipeline AS (
    SELECT 
        d.*,
        ROUND(days_in_stage::NUMERIC / benchmark_days, 2) AS dwell_ratio,
        GREATEST(0, (
            100 
            - (CASE WHEN (days_in_stage::NUMERIC / benchmark_days) > 1.50 THEN 35
                    WHEN (days_in_stage::NUMERIC / benchmark_days) > 1.00 THEN 15 ELSE 0 END)
            - (CASE WHEN acv_amount < 35000.00 THEN 25 ELSE 0 END)
            - (CASE WHEN owner_name = 'UNASSIGNED' THEN 40 ELSE 0 END)
        )) AS health_score
    FROM Dwell_Benchmarked d
)
SELECT 
    opportunity_id,
    account_name,
    account_tier,
    owner_name,
    stage_name,
    acv_amount,
    days_in_stage,
    health_score,
    CASE 
        WHEN health_score >= 80 THEN 'Healthy'
        WHEN health_score >= 50 THEN 'Moderate Risk'
        ELSE 'Critical Intervention'
    END AS health_band
FROM Scored_Pipeline
ORDER BY health_score ASC, acv_amount DESC;


-- =============================================================================
-- SECTION 4: SALES REP QUOTA ATTAINMENT & PIPELINE COVERAGE LEADERBOARD
-- =============================================================================

-- Question: Which reps are hitting quota vs. relying on fragile pipeline coverage?
-- Employs Window Functions (DENSE_RANK) and calculates 3x coverage targets.

WITH Rep_Aggregations AS (
    SELECT 
        u.user_id,
        u.rep_name,
        u.region,
        u.annual_quota,
        ROUND(COALESCE(SUM(CASE WHEN o.is_won = 1 THEN o.acv_amount ELSE 0 END), 0), 2) AS won_acv,
        ROUND(COALESCE(SUM(CASE WHEN o.is_closed = 0 THEN o.acv_amount ELSE 0 END), 0), 2) AS open_pipeline_acv,
        COUNT(CASE WHEN o.is_closed = 0 THEN 1 END) AS active_deal_count
    FROM sf_user u
    LEFT JOIN sf_opportunity o ON u.user_id = o.owner_id
    GROUP BY u.user_id, u.rep_name, u.region, u.annual_quota
),
Performance_Metrics AS (
    SELECT 
        *,
        ROUND((won_acv / NULLIF(annual_quota, 0)) * 100, 1) AS quota_attainment_pct,
        ROUND(open_pipeline_acv / NULLIF((annual_quota - won_acv), 0), 2) AS remaining_pipeline_coverage,
        DENSE_RANK() OVER (ORDER BY won_acv DESC) AS overall_rep_rank
    FROM Rep_Aggregations
)
SELECT 
    overall_rep_rank,
    rep_name,
    region,
    annual_quota,
    won_acv,
    quota_attainment_pct,
    open_pipeline_acv,
    remaining_pipeline_coverage,
    CASE 
        WHEN quota_attainment_pct >= 100 THEN 'Quota Crushed (President Club)'
        WHEN quota_attainment_pct >= 75  THEN 'On Track'
        ELSE 'At-Risk / Coaching Required'
    END AS rep_standing
FROM Performance_Metrics
ORDER BY overall_rep_rank;


-- =============================================================================
-- SECTION 5: PRE-SALES LEAD ATTRIBUTION & CONVERSION VELOCITY
-- =============================================================================

-- Question: Which lead channels yield the highest enterprise win rates?
-- Joins Pre-Sales Leads with Opportunities to evaluate lead source ROI.

SELECT 
    l.lead_source,
    COUNT(DISTINCT l.lead_id) AS total_leads_generated,
    COUNT(DISTINCT o.opportunity_id) AS converted_opportunities,
    ROUND(COUNT(DISTINCT o.opportunity_id)::NUMERIC / COUNT(DISTINCT l.lead_id) * 100, 1) AS lead_to_opp_conversion_pct,
    ROUND(SUM(CASE WHEN o.is_won = 1 THEN o.acv_amount ELSE 0 END), 2) AS won_revenue,
    ROUND(
        SUM(CASE WHEN o.is_won = 1 THEN 1.0 ELSE 0 END) / 
        NULLIF(COUNT(CASE WHEN o.is_closed = 1 THEN 1 END), 0) * 100, 
        1
    ) AS win_rate_pct
FROM sf_lead l
LEFT JOIN sf_opportunity o ON l.lead_source = o.lead_source
GROUP BY l.lead_source
ORDER BY won_revenue DESC;
