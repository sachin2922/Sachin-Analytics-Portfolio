# Advanced SQL Architecture & Analytics Projects

<p align="center">
  <img src="https://img.shields.io/badge/Language-SQL%20(ANSI%20Standard)-00758F?style=for-the-badge&logo=mysql&logoColor=white" alt="SQL" />
  <img src="https://img.shields.io/badge/Techniques-CTEs%20|%20Window%20Functions%20|%20Partitions-1155CC?style=for-the-badge" alt="Techniques" />
  <img src="https://img.shields.io/badge/Database-PostgreSQL%20|%20Snowflake%20|%20MS%20SQL-353744?style=for-the-badge" alt="Database" />
</p>

This repository contains enterprise-grade SQL architectures designed for commercial analytics, multi-stage revenue modeling, and complex analytical deep-dives.

---

### 🚀 Highlighted Project: Multi-Tier Opportunity Dwell Time & Pipeline Health Scoring

* **Query Script:** [`pipeline_health_scoring_ctes.sql`](./pipeline_health_scoring_ctes.sql)
* **Core Patterns:** Multi-level Common Table Expressions (CTEs), Analytic Window Functions (`DENSE_RANK()`, `SUM() OVER PARTITION`), Conditional Aggregations, and Date Arithmetic.

#### 🎯 Business Context
To empower C-suite leaders with real-time revenue predictability, raw transactional CRM logs must be modeled into aggregated, risk-scored metrics. This SQL script replaces fragile procedural loops with a declarative, vectorized pipeline that evaluates deal slippage and dwell-time risk.

#### 🧠 Modular CTE Pipeline Architecture

```text
┌────────────────────────┐
│  Stage_Benchmarks CTE  │  --> Defines historical SLA dwell-time per sales stage
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   Cleaned_Deals CTE    │  --> Normalizes dates, joins Account tiers, handles nulls
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│ Dwell_Calculations CTE │  --> Computes days in stage, total deal age, benchmark ratios
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│  Health_Score_Tier CTE │  --> Generates composite score (0-100) & classifies health bands
└───────────┬────────────┘
            │
┌───────────▼────────────┐
│   Final Summary View   │  --> Yields executive-ready revenue exposure and triage priority
└────────────────────────┘
```

---

### 💡 Advanced SQL Features Demonstrated

* **Multi-Tier CTEs:** Decouples complex business transformations into testable, maintainable logical units.
* **Window Functions:** Computes running totals, account-level opportunity ranks, and stage progression velocities.
* **Conditional Weighting:** Formulates weighted penalty functions directly inside SQL to eliminate middle-tier transformation bottlenecks.
* **Index & Query Optimization:** Designed with SARGable predicate filtering (`WHERE o.is_closed = FALSE`) to optimize execution plan costs on large datasets.

---

### 📁 Files in This Directory

* 💾 **[`pipeline_health_scoring_ctes.sql`](./pipeline_health_scoring_ctes.sql)**: Production SQL script demonstrating multi-level CTEs, window functions, and pipeline risk categorization.
* 📄 **`README.md`**: Project overview, architectural flow, and query design principles.

---

[⬅️ Return to Main Portfolio Hub](../README.md)
