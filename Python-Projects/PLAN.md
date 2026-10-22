# Python Projects Portfolio Suite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the local `Python-Projects` portfolio into a comprehensive, multi-project data science suite featuring 6 standalone subfolders with clean naming, executable Python scripts, notebooks, high-resolution aesthetic visual charts, layman-accessible documentation, and a central master `README.md`.

**Architecture:** Each project will reside in its own cleanly named subfolder containing the notebook/script, an `assets/` directory with generated publication-grade visual charts, and a dedicated `README.md` structured around: Problem Statement, Analytical Approach, Visual Findings & Key Metrics, and Business Decision Value. A root `.gitignore` will ensure no heavy (>100MB) database or raw CSV dumps enter the Git tree, while a Master `README.md` indexes the full suite with executive navigation cards.

**Tech Stack:** Python 3 (Pandas, NumPy, Matplotlib, Seaborn, TextBlob, Folium, Scikit-learn), Markdown, GitHub Pages / Git.

**Spec / Requirements:**
- No numbered folder prefixes (clean names matching user desktop directories).
- Move existing `crm_pipeline_etl.py` into `Salesforce CRM Pipeline ETL/`.
- No heavy CSV or 500+ MB SQLite data files in the portfolio repository. Keep it simple with Python code, notebooks, generated visuals, and rich documentation.
- All documentation in concise, layman-accessible terms with aesthetic visual representations.

## Global Constraints
- Target root directory: `C:\Users\Sachin\Desktop\GitHub-Portfolio-Package\Python-Projects`
- Clean folder names:
  1. `Salesforce CRM Pipeline ETL`
  2. `E-Commerce Sales Data Analytics`
  3. `Zomato Geospatial Data Analytics`
  4. `S&P Global Time Series Stock Market Data Analytics`
  5. `Youtube Text Data Analytics`
  6. `IPL Data Analytics`
- No data files > 50MB. Exclude `zomato_rawdata.sqlite` (575 MB), YouTube comment dumps (588 MB), and S&P 500 individual CSV bundles (505 files).

---

### Task 1: Environment Setup & Salesforce CRM Pipeline ETL Migration
**Files:**
- Create: `Salesforce CRM Pipeline ETL/README.md`
- Move: `crm_pipeline_etl.py` -> `Salesforce CRM Pipeline ETL/crm_pipeline_etl.py`
- Create: `.gitignore`

- [ ] **Step 1:** Create `Salesforce CRM Pipeline ETL/` directory and move `crm_pipeline_etl.py`.
- [ ] **Step 2:** Author `Salesforce CRM Pipeline ETL/README.md` with problem statement (CRM deal hygiene), approach (automated ETL & anomaly flagging), architecture diagram, and executive impact.
- [ ] **Step 3:** Create root `.gitignore` blocking `*.sqlite`, `*.db`, `*.ftr`, `*.csv`, `individual_stocks_5yr/`, and `additional_data/`.

---

### Task 2: E-Commerce Sales Data Analytics Showcase
**Files:**
- Source: `C:\Users\Sachin\Desktop\Python Project\E-Commerce Sales Data Analytics`
- Target: `E-Commerce Sales Data Analytics/`
- Script: `ecommerce_sales_analysis.py`
- Notebook: `Sales_Analysis.ipynb`
- Assets: `assets/monthly_sales_trend.png`, `assets/city_sales_distribution.png`, `assets/price_vs_quantity_elasticity.png`, `assets/hourly_purchase_distribution.png`
- Documentation: `README.md`

- [ ] **Step 1:** Copy and clean `Sales_analysis_Shan_Singh.ipynb` to target folder as `Sales_Analysis.ipynb`.
- [ ] **Step 2:** Generate high-resolution, aesthetic visual plots using Matplotlib/Seaborn into `assets/` (dark/modern aesthetic, high DPI).
- [ ] **Step 3:** Author clean standalone script `ecommerce_sales_analysis.py`.
- [ ] **Step 4:** Author `README.md` covering Problem Statement, Approach, Visual Insights, Market Basket Analysis, and Revenue Impact.

---

### Task 3: Zomato Geospatial Data Analytics Showcase
**Files:**
- Source: `C:\Users\Sachin\Desktop\Python Project\Zomato Geospatial Data Analytics`
- Target: `Zomato Geospatial Data Analytics/`
- Script: `zomato_geospatial_analytics.py`
- Notebook: `Zomato_Analysis.ipynb`
- Assets: `assets/online_order_vs_rating.png`, `assets/top_cuisines_distribution.png`, `assets/popular_dish_ngrams.png`, `assets/restaurant_density_clusters.png`
- Documentation: `README.md`

- [ ] **Step 1:** Copy and clean `Zomato_analysis_Shan_Singh_Udemy_.ipynb` into target folder as `Zomato_Analysis.ipynb`.
- [ ] **Step 2:** Generate publication-grade visual charts in `assets/` showcasing rating variance, review n-grams, and geospatial density hotspots.
- [ ] **Step 3:** Author standalone script `zomato_geospatial_analytics.py`.
- [ ] **Step 4:** Author `README.md` focusing on restaurant location feasibility, menu keyword intelligence, and operational takeaways for food-tech ventures.

---

### Task 4: S&P Global Time Series Stock Market Data Analytics Showcase
**Files:**
- Source: `C:\Users\Sachin\Desktop\Python Project\S&P Global Time Series Stock Market Data Analytics`
- Target: `S&P Global Time Series Stock Market Data Analytics/`
- Script: `stock_market_time_series_analytics.py`
- Notebook: `Stock_Price_Analysis.ipynb`
- Assets: `assets/moving_averages_trend.png`, `assets/daily_returns_volatility.png`, `assets/tech_giants_correlation_heatmap.png`, `assets/resampled_performance_trend.png`
- Documentation: `README.md`

- [ ] **Step 1:** Copy and clean `Stock_price_analysis_Shan_Singh.ipynb` to `Stock_Price_Analysis.ipynb`.
- [ ] **Step 2:** Generate visual charts in `assets/` (SMA momentum crossovers, daily returns distribution, correlation matrix heatmap).
- [ ] **Step 3:** Author standalone script `stock_market_time_series_analytics.py`.
- [ ] **Step 4:** Author `README.md` covering Problem Statement (unhedged tech risk), Approach (moving averages & return co-movement), Visual Results, and Portfolio Strategy value.

---

### Task 5: YouTube Text Data Analytics Showcase
**Files:**
- Source: `C:\Users\Sachin\Desktop\Python Project\Youtube Text Data Analytics`
- Target: `Youtube Text Data Analytics/`
- Script: `youtube_text_sentiment_analytics.py`
- Notebook: `YouTube_Text_Analysis.ipynb`
- Assets: `assets/sentiment_distribution.png`, `assets/emoji_frequency_chart.png`, `assets/category_engagement_rates.png`, `assets/punctuation_virality_impact.png`
- Documentation: `README.md`

- [ ] **Step 1:** Copy and clean `youtube_analysis_shan_singh.ipynb` to `YouTube_Text_Analysis.ipynb`.
- [ ] **Step 2:** Generate visual charts in `assets/` (NLP polarity split, top emojis, engagement ratios by genre, punctuation correlation).
- [ ] **Step 3:** Author standalone script `youtube_text_sentiment_analytics.py`.
- [ ] **Step 4:** Author `README.md` explaining Problem Statement, NLP TextBlob pipeline, Visual Insights, and Content Strategy recommendations.

---

### Task 6: IPL Data Analytics Showcase
**Files:**
- Source: `C:\Users\Sachin\Desktop\Python Project\IPL Data Analytics`
- Target: `IPL Data Analytics/`
- Script: `ipl_match_performance_analytics.py`
- Notebook: `IPL_Analysis.ipynb`
- Assets: `assets/toss_decision_trends.png`, `assets/toss_vs_match_win_rate.png`, `assets/franchise_championship_wins.png`, `assets/death_overs_strike_rates.png`
- Documentation: `README.md`

- [ ] **Step 1:** Copy and clean `IPL_analysis_shan_singh.ipynb` to `IPL_Analysis.ipynb`.
- [ ] **Step 2:** Generate visual charts in `assets/` illustrating match-play strategy, toss bias evolution, and player performance metrics.
- [ ] **Step 3:** Author standalone script `ipl_match_performance_analytics.py`.
- [ ] **Step 4:** Author `README.md` detailing Problem Statement, Approach, Visual Insights, and Sports Analytics takeaways.

---

### Task 7: Master Hub Documentation & Portfolio Integration
**Files:**
- Create: `Python-Projects/README.md`
- Update: `GitHub-Portfolio-Package/README.md` (root portfolio hub)

- [ ] **Step 1:** Author comprehensive Master `Python-Projects/README.md` featuring:
  - Executive portfolio badges (Python, Data Science, NLP, Geospatial, Financial Analytics).
  - Multi-project comparative matrix with direct links to each subfolder.
  - Project summary cards with embedded preview thumbnails and core metrics.
  - Tech stack & package directory.
- [ ] **Step 2:** Verify all image paths and subfolder links resolve correctly.
- [ ] **Step 3:** Sync Master Root `GitHub-Portfolio-Package/README.md` to reference the expanded Python portfolio projects suite.
