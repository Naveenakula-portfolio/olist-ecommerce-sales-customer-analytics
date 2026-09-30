# Olist E-commerce Sales & Customer Analytics

**Portfolio project for entry-level Data Analyst roles**  
**Tools:** Python, pandas, NumPy, Matplotlib, Seaborn, SQLite SQL, Jupyter Notebook

## Executive overview
This project analyzes the public Olist Brazilian E-Commerce dataset to understand order performance, product-category value, payment patterns, delivery timeliness, and customer review scores.

The uploaded dataset contains **9 CSV tables**. Purchase timestamps span **2016-09-04 to 2018-10-17**.

### Verified headline findings
- The dataset contains **99,441 orders**, including **96,478 delivered orders (97.02%)**.
- Delivered order items total **BRL 13,221,498.11** in item value. This is a merchandise-value proxy, **not profit or audited revenue**.
- The highest delivered item-value category is **health_beauty**, with **BRL 1,233,131.72** in item value.
- Among delivered orders with both actual and estimated delivery timestamps, **8.11%** arrived after the estimate. Mean delivery duration was **12.56 days**.
- Average review score is **4.09/5**. **14.69%** of review records have scores of 1 or 2.
- Average review score is **4.29** for delivered orders arriving on/before the estimate and **2.57** for late deliveries. This is an observed association, not proof of causation.
- **3.12%** of unique customer IDs in this dataset are associated with more than one order.

## Business questions
1. How did delivered order volume change over time?
2. Which product categories account for the most delivered item value?
3. Which customer states account for the most delivered orders?
4. Which payment types account for the most recorded payment value?
5. What is the typical delivery duration?
6. What share of delivered orders arrived after the estimated delivery date?
7. Are review scores different for late versus on-time deliveries?
8. What share of unique customer IDs is associated with multiple orders?
9. Which data-quality limitations should be considered before business decisions?

## Project structure
```text
olist_ecommerce_analytics_project/
├── README.md
├── requirements.txt
├── .gitignore
├── data/raw/README.md
├── notebooks/retail_analysis.ipynb
├── sql/analysis_queries.sql
├── charts/ (7 PNG charts)
└── reports/
    ├── executive_summary.md
    └── interview_prep.md
```

## Dataset source
Kaggle: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

Download the dataset ZIP from Kaggle. Raw data is intentionally not included in this project package. Check the dataset's license and usage terms before redistribution.

## How to reproduce the analysis
1. Install Python 3.10+ and Jupyter, or use [Google Colab](https://colab.research.google.com/).
2. Download the Kaggle ZIP.
3. Put the ZIP in the project root, or extract all nine CSV files into `data/raw/`.
4. Install dependencies: `pip install -r requirements.txt`
5. Open `notebooks/retail_analysis.ipynb`.
6. Run all cells from top to bottom.
7. Review generated charts and validation output. The notebook creates `olist_analytics.db` locally and writes chart PNGs into `charts/`.

## SQL analysis
`sql/analysis_queries.sql` contains 20 SQLite queries covering order status, monthly order volume, category analysis, state-level order counts, payment type, delivery duration, delivery timing, review scores, repeat customers, sellers, product metadata completeness, CTEs, and window functions.

Load the CSVs into SQLite tables with the names used in the script: `orders`, `order_items`, `order_payments`, `order_reviews`, `customers`, `products`, `sellers`, `geolocation`, and `category_translation`. The notebook creates these tables automatically.

## Data-quality decisions
- Dates are parsed explicitly; invalid values become missing and are reported.
- Missing delivery timestamps are not filled with guessed dates.
- Products without a category remain categorized as `unknown`.
- The geolocation table contains repeated rows. Do not use it as a one-to-one ZIP-code lookup without aggregation.
- Items, payments, and reviews are aggregated separately at order level before joining to orders, avoiding join fan-out.
- The project does not automatically delete unusual values without investigation.

## Metric definitions and limitations
- **Delivered item value:** sum of item `price` for orders whose status is `delivered`. It is not profit, margin, or audited accounting revenue.
- **Recorded payment value:** sum of payment records across all statuses; it may differ from item value due to freight, installments, vouchers, and other payment behavior.
- **Late delivery:** actual customer delivery timestamp is later than the estimated delivery date, among delivered orders with both timestamps available.
- **Repeat customer:** a `customer_unique_id` associated with more than one order in this dataset.
- This is historical data spanning 2016–2018 and should not be presented as a current market snapshot.
- Review-score differences are observational; do not claim delivery delays alone caused lower scores.
- Some product metadata, order timestamps, and review text are missing.

## Resume bullet templates
Customize only after you run and verify the project yourself:
- Analyzed **99,441** public e-commerce orders using Python and SQLite SQL to investigate order status, category performance, delivery timing, payment behavior, and customer reviews.
- Built 20 SQL queries using aggregations, joins, CTEs, and window functions, and validated key order-level metrics against Python calculations.
- Created 7 data visualizations and documented evidence-based findings and business recommendations in a reproducible GitHub project.

## Interview readiness
See `reports/interview_prep.md` for 10 questions with beginner-friendly sample answers. Be ready to explain how you prevented duplicate counting when joining one-to-many tables, why item value is not profit, and how you validated the results.
