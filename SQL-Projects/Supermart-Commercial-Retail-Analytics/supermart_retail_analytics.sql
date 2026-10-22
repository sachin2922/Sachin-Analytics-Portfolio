-- =============================================================================
-- Supermart Enterprise Commercial Retail Analytics & Customer Intelligence Suite
-- Author: Sachin Sharma (Commercial Analytics & RevOps Leader)
-- Dialect: PostgreSQL
-- Description:
--     Production-grade SQL analytics suite modeling 10,000+ omnichannel retail
--     orders. Features Star Schema relational modeling, multi-table P&L joins,
--     discount elasticity diagnostics, RFM customer lifetime value tiering,
--     window functions, and rolling time-series trend analysis.
-- =============================================================================

-- =============================================================================
-- SECTION 1: RELATIONAL SCHEMA DEFINITION (STAR SCHEMA DDL)
-- =============================================================================

-- 1.1 Customer Dimension Table
CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    segment VARCHAR(50) NOT NULL, -- Consumer, Corporate, Home Office
    age INT,
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50) NOT NULL -- East, West, Central, South
);

-- 1.2 Product Dimension Table
CREATE TABLE IF NOT EXISTS dim_product (
    product_id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100) NOT NULL, -- Technology, Furniture, Office Supplies
    sub_category VARCHAR(100) NOT NULL,
    product_name VARCHAR(255) NOT NULL
);

-- 1.3 Fact Sales Table
CREATE TABLE IF NOT EXISTS fact_sales (
    order_line INT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE NOT NULL,
    ship_mode VARCHAR(50) NOT NULL, -- Standard Class, Second Class, First Class, Same Day
    customer_id VARCHAR(50) NOT NULL REFERENCES dim_customer(customer_id),
    product_id VARCHAR(50) NOT NULL REFERENCES dim_product(product_id),
    sales NUMERIC(12, 4) NOT NULL,
    quantity INT NOT NULL,
    discount NUMERIC(5, 2) NOT NULL DEFAULT 0.0,
    profit NUMERIC(12, 4) NOT NULL
);

-- Performance Indexes on Join Keys & Date Filters
CREATE INDEX IF NOT EXISTS idx_sales_cust ON fact_sales(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_prod ON fact_sales(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_date ON fact_sales(order_date);


-- =============================================================================
-- SECTION 2: EXECUTIVE CATEGORY & SUB-CATEGORY P&L DIAGNOSTICS
-- =============================================================================

-- Question: Which categories drive volume vs. bottom-line profit margin?
-- Uncovers the "Furniture Margin Trap" where high sales yield near-zero net margin.

WITH Category_Performance AS (
    SELECT 
        p.category,
        COUNT(DISTINCT s.order_id) AS total_orders,
        SUM(s.quantity) AS total_units_sold,
        ROUND(SUM(s.sales), 2) AS gross_revenue,
        ROUND(SUM(s.profit), 2) AS net_profit,
        ROUND(AVG(s.discount) * 100, 1) AS avg_discount_pct,
        ROUND((SUM(s.profit) / NULLIF(SUM(s.sales), 0)) * 100, 2) AS net_profit_margin_pct
    FROM fact_sales s
    INNER JOIN dim_product p ON s.product_id = p.product_id
    GROUP BY p.category
)
SELECT 
    category,
    total_orders,
    total_units_sold,
    gross_revenue,
    net_profit,
    avg_discount_pct,
    net_profit_margin_pct,
    CASE 
        WHEN net_profit_margin_pct >= 15.0 THEN 'High Margin Driver'
        WHEN net_profit_margin_pct >= 8.0  THEN 'Healthy Volume Driver'
        ELSE 'Margin Bleed Risk'
    END AS strategic_classification
FROM Category_Performance
ORDER BY gross_revenue DESC;


-- =============================================================================
-- SECTION 3: THE DISCOUNTING TRAP & PROFIT BLEED SENSITIVITY
-- =============================================================================

-- Question: At what exact promotional discount percentage do transactions flip negative?
-- Evaluates transaction profitability across discount tiers.

SELECT 
    CASE 
        WHEN discount = 0.00 THEN '0% (Full Price)'
        WHEN discount BETWEEN 0.01 AND 0.10 THEN '1% - 10% Discount'
        WHEN discount BETWEEN 0.11 AND 0.20 THEN '11% - 20% Discount'
        WHEN discount BETWEEN 0.21 AND 0.30 THEN '21% - 30% Discount'
        WHEN discount BETWEEN 0.31 AND 0.50 THEN '31% - 50% Heavy Promo'
        ELSE 'Over 50% Clearance'
    END AS discount_tier,
    COUNT(order_line) AS transaction_count,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(profit), 2) AS avg_profit_per_order,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS realized_margin_pct
FROM fact_sales
GROUP BY 1
ORDER BY MIN(discount);


-- =============================================================================
-- SECTION 4: CUSTOMER RFM & LIFETIME VALUE (LTV) SEGMENTATION
-- =============================================================================

-- Question: Who are our top 10% high-margin VIP customers vs. low-value churn risks?
-- Applies Window Functions (NTILE, DENSE_RANK) to calculate quartile distributions.

WITH Customer_Metrics AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.segment,
        c.region,
        COUNT(DISTINCT s.order_id) AS total_lifetime_orders,
        ROUND(SUM(s.sales), 2) AS total_lifetime_spend,
        ROUND(SUM(s.profit), 2) AS total_profit_generated,
        MAX(s.order_date) AS last_purchase_date
    FROM dim_customer c
    INNER JOIN fact_sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.customer_name, c.segment, c.region
),
Ranked_Customers AS (
    SELECT 
        *,
        NTILE(4) OVER (ORDER BY total_lifetime_spend DESC) AS spend_quartile,
        DENSE_RANK() OVER (PARTITION BY region ORDER BY total_profit_generated DESC) AS profit_rank_in_region
    FROM Customer_Metrics
)
SELECT 
    customer_id,
    customer_name,
    segment,
    region,
    total_lifetime_orders,
    total_lifetime_spend,
    total_profit_generated,
    profit_rank_in_region,
    CASE 
        WHEN spend_quartile = 1 AND total_profit_generated > 1000 THEN 'Tier 1: Enterprise Champion'
        WHEN spend_quartile IN (1, 2) THEN 'Tier 2: High Value Core'
        WHEN spend_quartile = 3 THEN 'Tier 3: Mid-Market Regular'
        ELSE 'Tier 4: Transactional / At-Risk'
    END AS customer_tier
FROM Ranked_Customers
WHERE profit_rank_in_region <= 5
ORDER BY region, profit_rank_in_region;


-- =============================================================================
-- SECTION 5: SHIPPING LOGISTICS & SLA TURNAROUND TIME (TAT)
-- =============================================================================

-- Question: Does premium shipping (Same Day / First Class) actually meet SLA standards?
-- Calculates average dispatch duration across ship modes and delivery regions.

SELECT 
    ship_mode,
    region,
    COUNT(order_line) AS total_shipments,
    ROUND(AVG(ship_date - order_date), 1) AS avg_turnaround_days,
    MIN(ship_date - order_date) AS fastest_dispatch_days,
    MAX(ship_date - order_date) AS slowest_dispatch_days,
    ROUND(AVG(profit), 2) AS avg_profit_per_order
FROM fact_sales s
INNER JOIN dim_customer c ON s.customer_id = c.customer_id
GROUP BY ship_mode, region
ORDER BY ship_mode, avg_turnaround_days;


-- =============================================================================
-- SECTION 6: TIME-SERIES SEASONALITY & 3-MONTH ROLLING REVENUE
-- =============================================================================

-- Question: What is the underlying revenue momentum when removing monthly noise?
-- Employs Window Frame (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) & LAG for MoM Growth.

WITH Monthly_Aggregations AS (
    SELECT 
        DATE_TRUNC('month', order_date)::DATE AS sales_month,
        ROUND(SUM(sales), 2) AS monthly_revenue,
        ROUND(SUM(profit), 2) AS monthly_profit,
        COUNT(DISTINCT order_id) AS total_monthly_orders
    FROM fact_sales
    GROUP BY DATE_TRUNC('month', order_date)::DATE
),
Rolling_Metrics AS (
    SELECT 
        sales_month,
        monthly_revenue,
        monthly_profit,
        total_monthly_orders,
        LAG(monthly_revenue, 1) OVER (ORDER BY sales_month) AS prev_month_revenue,
        ROUND(AVG(monthly_revenue) OVER (
            ORDER BY sales_month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2) AS rolling_3_month_avg_revenue
    FROM Monthly_Aggregations
)
SELECT 
    sales_month,
    monthly_revenue,
    rolling_3_month_avg_revenue,
    ROUND(((monthly_revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0)) * 100, 2) AS mom_growth_pct,
    monthly_profit
FROM Rolling_Metrics
ORDER BY sales_month DESC
LIMIT 12;
