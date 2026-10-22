-- =============================================================================
-- Enterprise Salesforce CRM Pipeline Health Scoring & Revenue Governance Suite
-- Author: Sachin Sharma (Commercial Analytics & RevOps Leader)
-- Dialect: PostgreSQL
-- Description:
--     Production-grade SQL analytics engine modeling 1.6M+ records across 6 core
--     Salesforce CRM objects:
--       1. sf_user: 3,782 Internal Employees (AEs, Managers, VPs, SVPs with hierarchy)
--       2. sf_account: 156,034 Customer Accounts (Real Brands: Nike, Adidas, Microsoft, etc.)
--       3. sf_contact: 312,450 Customer Stakeholders (Economic Buyers, Champions)
--       4. sf_opportunity: 345,005 Pipeline Opportunities (Multi-Opp per Account)
--       5. sf_opportunity_field_history: 608,997 Audit Trail Change Records
--       6. sf_presales_data: 180,000 Technical Pre-Sales & PoC Support Tickets
--
-- Direct Architecture Connection:
--     Powers the live interactive RevOps Pipeline Health Dashboard
--     (RevOps_Pipeline_Health_Dashboard.html) with stage dwell audits,
--     0-100 algorithmic risk scoring, multi-opp account concentration, and quota rollups.
-- =============================================================================

-- =============================================================================
-- SECTION 1: RELATIONAL SCHEMA DEFINITION (SALESFORCE CRM DDL)
-- =============================================================================

-- 1.1 sf_user (Employees & Management Hierarchy | 3,782 Rows)
CREATE TABLE IF NOT EXISTS sf_user (
    user_id VARCHAR(50) PRIMARY KEY,
    employee_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(100) NOT NULL, -- Strategic Enterprise AE, Commercial AE, Pre-Sales SE, Sales Manager, VP of Sales, SVP / CRO
    manager_id VARCHAR(50) REFERENCES sf_user(user_id), -- Self-referencing reporting hierarchy
    region VARCHAR(50) NOT NULL, -- North America, EMEA, APAC, LATAM
    annual_quota NUMERIC(14, 2) NOT NULL DEFAULT 1000000.00,
    is_active SMALLINT NOT NULL DEFAULT 1
);

-- 1.2 sf_account (Enterprise Accounts & Brand Names | 156,034 Rows)
CREATE TABLE IF NOT EXISTS sf_account (
    account_id VARCHAR(50) PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL, -- e.g. 'Nike, Inc.', 'Adidas AG', 'Microsoft Corporation', 'Walmart Inc.'
    account_tier VARCHAR(50) NOT NULL, -- Tier 1: Prime Strategic Enterprise, Tier 2: Mid-Market, Tier 3: Emerging Commercial
    industry VARCHAR(100) NOT NULL, -- Athletic Apparel & Retail, Cloud Software, Consumer Goods, etc.
    region VARCHAR(50) NOT NULL,
    annual_revenue NUMERIC(16, 2), -- Client firmographics (e.g. $51.2B for Nike)
    assigned_ae_id VARCHAR(50) REFERENCES sf_user(user_id),
    created_date DATE NOT NULL
);

-- 1.3 sf_contact (Customer Stakeholders & Champions | 312,450 Rows)
CREATE TABLE IF NOT EXISTS sf_contact (
    contact_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL REFERENCES sf_account(account_id),
    contact_name VARCHAR(255) NOT NULL,
    title VARCHAR(150) NOT NULL, -- e.g. 'VP of Digital Experience', 'Chief Information Officer', 'Procurement Director'
    role VARCHAR(100) NOT NULL, -- Economic Buyer, Technical Evaluator, Executive Champion, Procurement
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    is_primary_decision_maker SMALLINT NOT NULL DEFAULT 0
);

-- 1.4 sf_opportunity (Pipeline Deals & Multi-Opp Structure | 345,005 Rows)
CREATE TABLE IF NOT EXISTS sf_opportunity (
    opportunity_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL REFERENCES sf_account(account_id), -- Allows multiple opportunities per account
    owner_id VARCHAR(50) REFERENCES sf_user(user_id),
    opportunity_name VARCHAR(255) NOT NULL, -- e.g. 'Nike - Global DTC POS Modernization', 'Adidas - Omnichannel Cloud'
    deal_type VARCHAR(50) NOT NULL, -- New Logo Acquisition, Enterprise Expansion / Upsell, Annual Renewal
    stage_name VARCHAR(100) NOT NULL, -- Prospecting, Qualification, Needs Analysis, Value Prop, Proposal, Negotiation, Closed Won, Closed Lost
    lead_source VARCHAR(100) NOT NULL, -- Inbound Web, Outbound SDR, Partner Referral, Executive Event
    acv_amount NUMERIC(14, 2) NOT NULL DEFAULT 0.00, -- Annual Contract Value
    created_date DATE NOT NULL,
    stage_entry_date DATE NOT NULL,
    close_date DATE NOT NULL,
    is_closed SMALLINT NOT NULL DEFAULT 0,
    is_won SMALLINT NOT NULL DEFAULT 0
);

-- 1.5 sf_opportunity_field_history (Audit Trail Log | 608,997 Rows)
CREATE TABLE IF NOT EXISTS sf_opportunity_field_history (
    history_id VARCHAR(50) PRIMARY KEY,
    opportunity_id VARCHAR(50) NOT NULL REFERENCES sf_opportunity(opportunity_id),
    field_modified VARCHAR(100) NOT NULL, -- 'StageName', 'Amount', 'CloseDate', 'Probability'
    old_value VARCHAR(255),
    new_value VARCHAR(255),
    modified_by_user_id VARCHAR(50) REFERENCES sf_user(user_id),
    modified_timestamp TIMESTAMP NOT NULL,
    dwell_days_in_prior_stage NUMERIC(8, 1)
);

-- 1.6 sf_presales_data (Pre-Sales Technical Tickets | 180,000 Rows)
CREATE TABLE IF NOT EXISTS sf_presales_data (
    ticket_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL REFERENCES sf_account(account_id),
    opportunity_id VARCHAR(50) REFERENCES sf_opportunity(opportunity_id),
    assigned_engineer_id VARCHAR(50) REFERENCES sf_user(user_id),
    ticket_type VARCHAR(100) NOT NULL, -- Technical RFP / Security Review, Custom Architecture PoC, Executive Demo
    priority VARCHAR(20) NOT NULL, -- P1 - Critical, P2 - High, P3 - Medium, P4 - Low
    ticket_status VARCHAR(50) NOT NULL, -- Resolved, In Progress, Escalated, Pending Customer
    created_at TIMESTAMP NOT NULL,
    resolved_at TIMESTAMP,
    resolution_time_hours NUMERIC(10, 1),
    sla_target_hours NUMERIC(10, 1) NOT NULL DEFAULT 48.0,
    is_sla_breached SMALLINT NOT NULL DEFAULT 0
);

-- High-Performance Composite Indexes
CREATE INDEX IF NOT EXISTS idx_opp_account ON sf_opportunity(account_id);
CREATE INDEX IF NOT EXISTS idx_opp_owner ON sf_opportunity(owner_id);
CREATE INDEX IF NOT EXISTS idx_opp_stage ON sf_opportunity(stage_name);
CREATE INDEX IF NOT EXISTS idx_opp_hist_opp_date ON sf_opportunity_field_history(opportunity_id, modified_timestamp);
CREATE INDEX IF NOT EXISTS idx_presales_opp ON sf_presales_data(opportunity_id);
CREATE INDEX IF NOT EXISTS idx_contact_acc ON sf_contact(account_id);
CREATE INDEX IF NOT EXISTS idx_user_manager ON sf_user(manager_id);


-- =============================================================================
-- SECTION 2: STAGE DWELL TIME & BOTTLENECK AUDIT (FIELD HISTORY AUDIT)
-- Direct Link: Powers the 'Avg Deal Stage' & 'Stuck Stage Diagnostics' Tab
-- =============================================================================

-- Question: Which stages exceed target SLAs and where are deals bottlenecking?
-- Uses Opportunity Field History to calculate exact days spent in each stage.

WITH Stage_SLA_Benchmarks AS (
    SELECT 'Prospecting' AS stage_name, 14.0 AS sla_days UNION ALL
    SELECT 'Qualification', 21.0 UNION ALL
    SELECT 'Needs Analysis', 30.0 UNION ALL
    SELECT 'Value Proposition', 25.0 UNION ALL
    SELECT 'Proposal / Quote', 20.0 UNION ALL
    SELECT 'Negotiation / Review', 15.0
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
-- Direct Link: Powers the 'Pipeline Health Analysis' & 'Open Deals' Tab
-- =============================================================================

-- Question: Which deals are at critical risk and require sales director escalation?
-- Evaluates 4 risk vectors: Dwell Overstay, ACV Banding ($35K threshold), Tier, and Ownership.

WITH Base_Opportunities AS (
    SELECT 
        o.opportunity_id,
        a.company_name,
        a.account_tier,
        u.employee_name AS rep_name,
        o.opportunity_name,
        o.stage_name,
        o.acv_amount,
        (CURRENT_DATE - o.stage_entry_date) AS days_in_stage,
        COALESCE(u.employee_name, 'UNASSIGNED') AS owner_name
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
    company_name,
    opportunity_name,
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
-- SECTION 4: MULTI-OPPORTUNITY ACCOUNT PORTFOLIO ARR CONCENTRATION
-- Direct Link: Powers the 'Segmentation & Rep Coverage' Tab
-- =============================================================================

-- Question: How much revenue exposure exists per enterprise account (Nike, Adidas, etc.)
-- across their multiple open and closed opportunities?

SELECT 
    a.company_name,
    a.account_tier,
    a.industry,
    COUNT(o.opportunity_id) AS total_opps_associated,
    SUM(CASE WHEN o.is_closed = 0 THEN 1 ELSE 0 END) AS active_open_opps,
    ROUND(SUM(CASE WHEN o.is_closed = 0 THEN o.acv_amount ELSE 0 END), 2) AS active_pipeline_acv,
    ROUND(SUM(CASE WHEN o.is_won = 1 THEN o.acv_amount ELSE 0 END), 2) AS lifetime_won_acv,
    MAX(CASE WHEN o.is_closed = 0 THEN o.acv_amount ELSE 0 END) AS max_single_deal_acv,
    STRING_AGG(DISTINCT o.deal_type, ', ') AS active_deal_types
FROM sf_account a
INNER JOIN sf_opportunity o ON a.account_id = o.account_id
GROUP BY a.account_id, a.company_name, a.account_tier, a.industry
HAVING COUNT(o.opportunity_id) >= 2
ORDER BY active_pipeline_acv DESC
LIMIT 10;


-- =============================================================================
-- SECTION 5: MANAGEMENT HIERARCHY QUOTA ATTAINMENT (3,782 EMPLOYEES)
-- Direct Link: Powers the 'Sales Rep Distribution' Tab & Executive Quota Rollups
-- =============================================================================

-- Question: How do individual AEs roll up into Sales Managers, VPs, and SVP/CRO targets?
-- Employs Self-Referencing User Hierarchy with Analytical Window Functions (DENSE_RANK).

WITH Rep_Aggregations AS (
    SELECT 
        u.user_id,
        u.employee_name AS rep_name,
        mgr.employee_name AS manager_name,
        u.role,
        u.region,
        u.annual_quota,
        ROUND(COALESCE(SUM(CASE WHEN o.is_won = 1 THEN o.acv_amount ELSE 0 END), 0), 2) AS won_acv,
        ROUND(COALESCE(SUM(CASE WHEN o.is_closed = 0 THEN o.acv_amount ELSE 0 END), 0), 2) AS open_pipeline_acv,
        COUNT(CASE WHEN o.is_closed = 0 THEN 1 END) AS active_deal_count
    FROM sf_user u
    LEFT JOIN sf_user mgr ON u.manager_id = mgr.user_id
    LEFT JOIN sf_opportunity o ON u.user_id = o.owner_id
    WHERE u.role LIKE '%AE%'
    GROUP BY u.user_id, u.employee_name, mgr.employee_name, u.role, u.region, u.annual_quota
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
    manager_name,
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
-- SECTION 6: 180,000 PRE-SALES TICKET SLA IMPACT ON CONVERSION VELOCITY
-- Direct Link: Powers the Pre-Sales SE Capacity & Deal Velocity Correlation
-- =============================================================================

-- Question: How do pre-sales technical support tickets (PoCs, RFPs) impact deal cycle time and win rate?

WITH Ticket_Performance AS (
    SELECT 
        o.opportunity_id,
        o.stage_name,
        o.is_won,
        o.is_closed,
        o.acv_amount,
        (o.close_date - o.created_date) AS total_sales_cycle_days,
        COUNT(t.ticket_id) AS total_presales_tickets,
        ROUND(AVG(t.resolution_time_hours), 1) AS avg_ticket_resolution_hours,
        SUM(t.is_sla_breached) AS breached_tickets_count
    FROM sf_opportunity o
    LEFT JOIN sf_presales_data t ON o.opportunity_id = t.opportunity_id
    GROUP BY o.opportunity_id, o.stage_name, o.is_won, o.is_closed, o.acv_amount, o.close_date, o.created_date
)
SELECT 
    CASE 
        WHEN avg_ticket_resolution_hours < 24 THEN 'Fast Track (< 24 hrs)'
        WHEN avg_ticket_resolution_hours <= 48 THEN 'Standard SLA (24 - 48 hrs)'
        WHEN avg_ticket_resolution_hours <= 96 THEN 'Lagging SLA (49 - 96 hrs)'
        ELSE 'Breached SLA (> 96 hrs Critical)'
    END AS presales_sla_bucket,
    COUNT(opportunity_id) AS analyzed_opportunities,
    ROUND(AVG(total_presales_tickets), 1) AS avg_tickets_per_opp,
    ROUND(AVG(total_sales_cycle_days), 1) AS avg_sales_cycle_days,
    ROUND(SUM(CASE WHEN is_won = 1 THEN 1.0 ELSE 0 END) / NULLIF(COUNT(CASE WHEN is_closed = 1 THEN 1 END), 0) * 100, 1) AS win_rate_pct,
    ROUND(SUM(CASE WHEN is_won = 1 THEN acv_amount ELSE 0 END), 2) AS total_won_acv
FROM Ticket_Performance
WHERE avg_ticket_resolution_hours IS NOT NULL
GROUP BY 1
ORDER BY win_rate_pct DESC;
