# Enterprise SQL Architecture & Analytics Portfolio

<p align="center">
  <img src="https://img.shields.io/badge/Stack-SQL%20(PostgreSQL%20|%20Snowflake%20|%20MS%20SQL)-00758F?style=for-the-badge&logo=postgresql&logoColor=white" alt="SQL Stack" />
  <img src="https://img.shields.io/badge/Specializations-Star%20Schema%20|%20CTEs%20|%20Window%20Functions-1155CC?style=for-the-badge" alt="Specializations" />
  <img src="https://img.shields.io/badge/Projects-2%20Production%20Suites-00AB44?style=for-the-badge" alt="Projects" />
</p>

Welcome to my central SQL repository. This portfolio showcases production-grade database modeling, multi-tier Common Table Expressions (CTEs), analytical window functions, and business intelligence query pipelines designed for high-performance decision support.

---

### 📂 Specialized SQL Projects Directory

| Project Domain | Core Business Question Solved | Key SQL Techniques & Methods | Explore Project |
| :--- | :--- | :--- | :--- |
| **🛒 Supermart Commercial Retail Analytics (PostgreSQL)** | *Where is our \$2.3M retail revenue losing profit, and at what discount % do orders turn negative?* | Star Schema (Fact/Dims), Window Functions (`NTILE`, `DENSE_RANK`), P&L Joins, Seasonality | [👉 Open Suite](./Supermart-Commercial-Retail-Analytics) |
| **💼 Salesforce Pipeline Health Scoring** | *Which CRM deals are stagnating past SLA benchmarks and putting quarterly ARR at risk?* | Multi-tier Modular CTEs, Dwell-Time SLAs, Composite Algorithmic Health Scoring (0–100) | [👉 Open Suite](./Salesforce-Pipeline-Health-Scoring) |

---

### 🚀 Highlighted Project Overviews

---

#### 1. [Supermart Enterprise Commercial Retail Analytics & Customer Intelligence (PostgreSQL)](./Supermart-Commercial-Retail-Analytics)
* **The Problem:** An omnichannel retail enterprise generated \$2.3M in sales, but severe promotional discounting (up to 80%) eroded bottom-line margins in categories like Furniture (yielding an anemic 2.49% net margin).
* **The SQL Architecture:** Modeled 10,000+ transaction rows into a relational Star Schema (`dim_customer`, `dim_product`, `fact_sales`). Analyzed category P&L performance, discount bleed sensitivity, and customer lifetime value (LTV).
* **Visual Insights:** Established that discounts **above 20%** cause net profit to collapse into negative territory (**-10% to -119% loss** per order) and proved Q4 holiday surges account for 35% of annual revenue.
* **Commercial Impact:** Capped discounting at 15% on high-bleed categories, recovering **~\$85K in lost profits**, and isolated top 10% VIP accounts generating 48% of gross profit.

---

#### 2. [Salesforce Opportunity Dwell Time & Pipeline Health Scoring](./Salesforce-Pipeline-Health-Scoring)
* **The Problem:** Sales leaders often discover deal slippage in the final week of the quarter because CRM systems lack vectorized dwell-time auditing.
* **The SQL Architecture:** Engineered a declarative, multi-tier CTE pipeline (`Stage_Benchmarks`, `Cleaned_Deals`, `Dwell_Calculations`, `Health_Score_Tier`, `Final_Summary_View`).
* **Technical Highlights:** Window functions (`DENSE_RANK()`, `SUM() OVER PARTITION`), SARGable date filtering, and automated 0–100 composite health scoring.
* **Commercial Impact:** **+15% ARR expansion** by surfacing 28% of pipeline deals in the *Critical Intervention* band before quarter-end.

---

### 🛠️ Core Database Competencies Demonstrated
* **Relational Schema Design:** Star Schema Normalization, Primary/Foreign Key Integrity, Fact/Dimension Table Modeling.
* **Advanced Querying & Aggregations:** Multi-tier CTEs, Analytic Window Functions (`DENSE_RANK`, `ROW_NUMBER`, `NTILE`, `LAG`, `LEAD`), Rolling Running Totals.
* **Performance Tuning & Optimization:** B-Tree Composite Indexing, SARGable Predicate Filtering, NULL-safe arithmetic (`NULLIF`), Query Execution Plan Cost Reduction.
