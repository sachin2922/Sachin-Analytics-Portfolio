# Revenue Operations (RevOps) & Pipeline Health Projects

<p align="center">
  <img src="https://img.shields.io/badge/Domain-Revenue%20Operations-1155CC?style=for-the-badge" alt="Domain" />
  <img src="https://img.shields.io/badge/Status-Production%20Ready-00AB44?style=for-the-badge" alt="Status" />
  <img src="https://img.shields.io/badge/Stack-Salesforce%20|%20Power%20BI%20|%20SQL-353744?style=for-the-badge" alt="Stack" />
</p>

This section highlights strategic Revenue Operations (RevOps) solutions built to solve executive pipeline predictability challenges, eliminate deal slippage, and optimize account executive (AE) resource allocation.

---

### 🚀 [Launch Live Interactive RevOps Dashboard (click to open)](https://sachin2922.github.io/Sachin-Analytics-Portfolio/RevOps-Projects/RevOps_Pipeline_Health_Dashboard.html)

*Direct cloud-hosted interactive version. Fully functional with multi-filter slicers, deal health scoring, and stage diagnostics.*

---

## Project Case Study: Enterprise Pipeline Health & Risk Command Center

### 🎯 1. Business Problem
* **Pipeline Fog & Deal Slippage:** Sales leadership and finance directors relied on static monthly CRM snapshots, causing surprise late-stage slippage and quarterly forecast misses.
* **Deal Stagnation (Stuck Stages):** Opportunities frequently stalled in technical evaluation or proposal stages beyond standard velocity benchmarks without triggering alert workflows.
* **Unbalanced ACV Concentration:** Over 45% of seller-pursued deals fell significantly below the 12-month average annual contract value ($35K), consuming valuable AE bandwidth on low-margin accounts.
* **Orphaned Opportunities:** 8% of active pipeline deals remained unassigned or neglected during territory transitions, risking account churn before closing.

---

### 🧠 2. Analytical Approach & Decision Framework
1. **Multi-Factor Pipeline Health Index:** Formulated an algorithmic scoring system that classifies each opportunity into three health bands (*Healthy*, *Moderate Risk*, *Critical Intervention*) based on:
   * **Stage Dwell Time:** Deal age compared against historical stage benchmarks.
   * **Stuck Flag:** Opportunities exceeding $1.5\times$ standard stage duration.
   * **ACV Threshold:** Deal size relative to cohort average ACV ($35K benchmark).
   * **Account Tier:** Prime strategic accounts vs. Non-Prime transaction volume.
2. **Revenue at Risk Modeling:** Quantified total unweighted ACV vs. probability-adjusted healthy ACV to forecast real-time exposure.
3. **Actionable Intervention Triage:** Converted analytical findings into a daily operational workflow for sales directors during 1-on-1 pipeline reviews.

---

### 💡 3. Solution & Business Impact
* **Unified Single Source of Truth:** Engineered an interactive command center integrating Salesforce CRM opportunity objects, stage conversion funnels, and marketing attribution channels.
* **Quantified Commercial Impact:**
  * **+15% ARR Expansion:** Re-focused sales execution onto high-probability, high-ACV enterprise accounts.
  * **30% Faster C-Suite Decision Velocity:** Replaced ad hoc manual Excel reconciliations with real-time automated KPI governance.
  * **Zero Opportunity Leakage:** Immediate visibility and automated reassignment for orphaned accounts.

---

### 📑 4. Tab-by-Tab Architecture & Capabilities

| Module | What It Does & Strategic Value |
| :--- | :--- |
| **Executive KPI Summary** | Instant top-line health checks: Total Open Deals, Win Rate %, Total Pipeline ACV, Healthy ACV, and Revenue at Risk. |
| **Health Banding Engine** | Visual segmentation isolating deals that require immediate sales engineering or executive escalation. |
| **Stuck Stage Diagnostics** | Pinpoints exact friction stages (e.g., Legal / Security Review) causing systemic conversion delays. |
| **ACV Distribution Benchmarks** | Evaluates pipeline skewness against the $35K benchmark, isolating high-leverage growth deals. |
| **Prime vs. Non-Prime Analysis** | Cross-cuts conversion probability by account tier to ensure top-tier targets receive dedicated pre-sales support. |
| **Lead Source Attribution** | Evaluates win rates across Inbound, Outbound SDR, Partner, and Organic channels to optimize CAC. |
| **Intervention Priority Matrix** | Granular action list ranking accounts by urgency, deal size, and recommended remedial action. |

---

### 🏛️ 5. Underlying Relational SQL Architecture (1.6M+ Records)

This dashboard is powered directly by our production-grade **PostgreSQL Salesforce CRM Data Engine**:
* **Pre-Sales Tickets (`sf_presales_data` | 180,000 Rows):** Solves stage bottlenecks by tracking technical PoCs, security RFPs, and resolution SLAs.
* **Customer Accounts (`sf_account` | 156,034 Rows):** Customer accounts featuring real enterprise brands (**Nike, Adidas, Microsoft, Apple, Walmart, Spotify**).
* **Pipeline Deals (`sf_opportunity` | 345,005 Rows):** Multi-opportunity structure enabling portfolio ARR concentration analysis.
* **Internal Employees (`sf_user` | 3,782 Rows):** Hierarchical organizational structure (**AE $\rightarrow$ Sales Manager $\rightarrow$ Regional VP $\rightarrow$ SVP / CRO**).
* **Audit Trail (`sf_opportunity_field_history` | 608,997 Rows):** Powers stage dwell-time calculations and stuck deal alerts.
* **Customer Contacts (`sf_contact` | 312,450 Rows):** Maps executive champions and economic buyers to enterprise deals.

👉 **[Explore the PostgreSQL Pipeline Health & Scoring SQL Suite](../SQL-Projects/Salesforce-Pipeline-Health-Scoring)**

---

### 📁 Files in This Directory

* 🌐 **`RevOps_Pipeline_Health_Dashboard.html`**: Standalone production-grade interactive dashboard file.
* 📄 **`README.md`**: Complete architecture documentation and business impact report.

---

[⬅️ Return to Main Portfolio Hub](../README.md)
