# Commercial Analytics & Revenue Operations Portfolio

<p align="center">
  <img src="https://img.shields.io/badge/Status-Live%20Dashboards-00AB44?style=for-the-badge&logo=github" alt="Live Status" />
  <img src="https://img.shields.io/badge/Stack-SQL%20|%20Python%20|%20Power%20BI%20|%20Salesforce-1155CC?style=for-the-badge" alt="Tech Stack" />
  <img src="https://img.shields.io/badge/Domain-Commercial%20Analytics%20|%20RevOps-353744?style=for-the-badge" alt="Domain" />
</p>

Welcome to my executive analytics portfolio. This repository showcases interactive, production-grade business intelligence suites engineered to solve operational capacity bottlenecks, revenue forecasting risks, and commercial pipeline governance challenges.

---

### 🚀 Quick Access — Live Interactive Dashboards

| Project | Core Domain | Key Business Impact | Live Interactive Demo |
| :--- | :--- | :--- | :--- |
| **Utilization & Efficiency Tracker** | Operational BI & Workforce Capacity | **-60%** reporting overhead, **+40%** TAT acceleration | [👉 Launch Live Dashboard](https://sachin2922.github.io/Sachin-Analytics-Portfolio/Utilization%20%26%20Efficiency%20Tracker.html) |
| **RevOps Pipeline Health Analysis** | Revenue Operations & CRM Analytics | **+15%** ARR expansion, **+30%** C-Suite decision velocity | [👉 Launch Live Dashboard](https://sachin2922.github.io/Sachin-Analytics-Portfolio/RevOps_Pipeline_Health_Dashboard.html) |

---

## 1. [Utilization & Efficiency Tracker](https://sachin2922.github.io/Sachin-Analytics-Portfolio/Utilization%20%26%20Efficiency%20Tracker.html) ↗

[![Utilization & Efficiency Tracker Preview](assets/utilization_tracker_preview.png)](https://sachin2922.github.io/Sachin-Analytics-Portfolio/Utilization%20%26%20Efficiency%20Tracker.html)
<p align="center"><i>Click the preview above or the heading to launch the live interactive dashboard</i></p>

### 🎯 Business Problem
* **Operational Blind Spots:** Cross-functional research and compliance teams lacked unified visibility into daily productive hours, sprint commitments, and individual workload distribution.
* **Skewed Productivity Metrics:** Raw ticket volume counts penalized researchers handling complex enterprise investigations while over-rewarding low-effort, trivial requests.
* **Resource Imbalance:** Ineffective capacity planning led to SLA slippage, delayed turnaround times (TAT), and unoptimized quarterly incentive allocations.

### 🧠 Analytical Approach & Framework
* **Normalized Ticket Velocity:** Formulated a weighted scoring algorithm that standardizes ticket complexity (Enterprise vs. Mid-Market vs. Trivial) to evaluate true researcher productivity objectively.
* **Capacity Deductions & Benchmarking:** Established strict sprint capacity models (480 min/day adjusted with a 10% meeting/admin overhead buffer = 432 productive min/day) to quantify net available bandwidth against historical benchmarks.
* **Multi-Tier Cohort Segmentation:** Grouped researchers by specialized cohorts (Enterprise, Mid-Market, Mixed) to account for varying domain complexity and research depth.

### 💡 Solution & Quantified Impact
* **Unified Telemetry Suite:** Deployed an end-to-end operational control center tracking sprint commitments, actual time logged, system turnaround times, and QA audit scores.
* **Measurable Results:**
  * **60% Reduction** in manual sprint capacity reporting workloads.
  * **40% Improvement** in turnaround time (TAT) on high-priority deliverables.
  * Established 100% data-backed governance for Quarterly Incentive Plans (QIP).

### 📑 Tab-by-Tab Architecture & Functionality

| Tab / Module | Functional Focus & What It Does |
| :--- | :--- |
| **1. Home (Analytics Suite)** | Executive telemetry hub offering single-click navigation across all operational KPIs, sprint milestones, and cohort performance cards. |
| **2. Glossary & KPI Formulas** | Complete data dictionary documenting metric logic, DAX/SQL calculation formulas, and definitions (e.g., Normalized Velocity, Net Commitment %). |
| **3. Time Sheet** | Sprint capacity model displaying standard cohort benchmarks, daily productive minute budgets (432 min/day), and entity/domain effort breakdowns. |
| **4. Tickets Overview** | Real-time intake and completion tracker categorizing tickets across Full-Scope Research, Trivial, and Enforcement workflows with velocity trends. |
| **5. Utilization Overview** | Core capacity balance sheet tracking actual productive effort vs. sprint capacity, identifying over-allocated and under-utilized analysts. |
| **6. Branding Team Utilization** | Dedicated operational tracking sub-module evaluating branding and specialized review workflows. |
| **7. Incentive X Utilization** | Transparent Quarterly Incentive Plan (QIP) tracker linking capacity utilization bands and normalized velocity to bonus tiers. |
| **8. Ticket Complexity** | Macroscopic complexity distribution monitoring (Low / Medium / High) to ensure equitable workload distribution across pods. |
| **9. Complexity Details** | Deep-dive analytical view mapping individual researcher touchpoints, task sizes, and complexity outliers. |
| **10. System TAT** | Turnaround time diagnostic engine evaluating system-generated SLA milestones, queue bottlenecks, and end-to-end resolution duration. |
| **11. QA Analysis** | Quality governance dashboard evaluating audit scores, defect classifications, and compliance check coverage across deliverable cycles. |

---

## 2. [RevOps Pipeline Health Analysis](https://sachin2922.github.io/Sachin-Analytics-Portfolio/RevOps_Pipeline_Health_Dashboard.html) ↗

[![RevOps Pipeline Health Dashboard Preview](assets/revops_pipeline_preview.png)](https://sachin2922.github.io/Sachin-Analytics-Portfolio/RevOps_Pipeline_Health_Dashboard.html)
<p align="center"><i>Click the preview above or the heading to launch the live interactive dashboard</i></p>

### 🎯 Business Problem
* **Unpredictable Revenue Forecasting:** Sales and RevOps leadership suffered from late-stage deal slippage and inaccurate quarterly pipeline projections due to static CRM reports.
* **Pipeline Stagnation & Neglect:** High-value enterprise opportunities languished unnoticed in early/mid stages without automated alerts or intervention mechanisms.
* **Deal Quality Disparity:** A significant proportion of active deals were valued below average annual contract value (ACV) or remained unassigned, diluting seller productivity.

### 🧠 Analytical Approach & Framework
* **Multi-Factor Pipeline Health Index:** Developed a dynamic scoring matrix evaluating deals against 4 core risk vectors: Deal Age vs. Stage Benchmark, Stuck Stage Duration, ACV Banding, and Account Prime Status.
* **Intervention Prioritization Matrix:** Segmented opportunities into actionable triage tiers (At-Risk, Monitor, Healthy) to guide weekly sales 1-on-1s and deal reviews.
* **Historical ACV Benchmarking:** Compared open deals against 12-month trailing ACV benchmarks ($35K) to isolate high-leverage expansion opportunities from resource-draining low-value deals.

### 💡 Solution & Quantified Impact
* **Executive Command Center:** Delivered a centralized, interactive command center bridging Salesforce CRM opportunities, lead source attribution, and conversion health bands.
* **Measurable Results:**
  * **+15% ARR Expansion** driven by prioritized seller focus on healthy, high-probability enterprise opportunities.
  * **30% Faster C-Suite Decision Speed** through automated pipeline hygiene and real-time revenue-at-risk visibility.
  * **Zero Opportunity Leakage** with instant visibility into unassigned accounts and lagging deal stages.

### 📑 Tab-by-Tab Architecture & Functionality

| Module / Component | Functional Focus & What It Does |
| :--- | :--- |
| **1. Executive KPI Summary** | Instant top-line health checks: Total Open Deals, Win Rate %, Total Pipeline ACV, Healthy ACV, and Revenue at Risk. |
| **2. Health Banding Engine** | Algorithmic classification segmenting all open pipeline volume into *Healthy*, *Moderate Risk*, and *Critical Intervention* categories. |
| **3. Stuck Stage Diagnostics** | Identifies opportunities exceeding standard stage dwell-time thresholds, isolating organizational pipeline friction points. |
| **4. ACV Distribution Benchmarks** | Evaluates deal distribution against the 12-month trailing ACV average ($35K) and flags sub-benchmark deal concentration (45%). |
| **5. Prime vs. Non-Prime Accounts** | Cross-cuts conversion probability and pipeline health by strategic tier, ensuring high-value accounts receive executive sponsorship. |
| **6. Opportunity Source Attribution** | Tracks lead generation performance (Inbound, Partner, Outbound SDR, Organic) against conversion velocity and win probability. |
| **7. Deal Intervention Action Plan** | Granular list view ranking at-risk deals by intervention priority to equip sales directors with immediate tactical next steps. |

---

### 🛠️ Core Technical Competencies Demonstrated

* **Data Modeling & Architecture:** Star Schema Normalization, Relational Modeling, Fact/Dimension Mapping, Capacity Balancing.
* **Advanced Analytics & BI:** SQL Window Functions, CTEs, Dynamic DAX Measures, Cohort Dwell Time Analysis, SLA Modeling.
* **Enterprise RevOps & Systems:** Salesforce CRM Workflow Integration, Pipeline Hygiene Automation, KPI Governance Frameworks.
* **Executive Delivery:** C-Suite Visual Design, Interactive Filtering, Root-Cause Diagnostics, Actionable Business Storytelling.

---

### 👨‍💻 About the Author

**Sachin Sharma**  
*Commercial Analytics & Risk Operations Leader*  
* 📍 Delhi NCR / Noida, India  
* 💼 [LinkedIn Profile](https://www.linkedin.com/in/sachinsharma02)  
* ✉️ sharma2922sachin@gmail.com  
* 📱 +91-8700858524
