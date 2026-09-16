# RetailPulse — E-Commerce Revenue & Customer Analytics

An end-to-end analytics project built on ~99K real orders from the Olist Brazilian e-commerce marketplace (2016–2018). It goes from raw relational data in PostgreSQL, through Python cleaning and statistical analysis, into a customer segmentation model, and finishes as an interactive Power BI dashboard.

The goal wasn't to produce charts for their own sake — it was to answer the questions a retail analytics team actually gets asked: *Where is revenue coming from? Which customers are worth keeping? Is delivery performance hurting satisfaction, and by how much? Are there regional problems worth flagging?*

---

## What's in here

| | |
|---|---|
| **Database** | PostgreSQL — 9 relational tables, proper keys and constraints |
| **SQL** | 23 business-question queries across 6 areas: revenue trends, customer/RFM analysis, delivery operations, product & seller performance, payments, data quality |
| **Python** | pandas, SQLAlchemy, scikit-learn, SciPy, Matplotlib/Seaborn — cleaning, EDA, K-Means clustering, hypothesis testing |
| **Dashboard** | Power BI — 3 pages, fully interactive, cross-filtered |

---

## Key findings

**Delivery delay is the strongest driver of customer dissatisfaction found in this dataset.** Orders that arrived on time or early averaged a 4.29/5 review score. Orders delayed 4+ days averaged 1.86/5 — a drop of nearly two and a half stars. A two-sample t-test confirms this isn't noise (t = 138.03, p < 0.001). Statistical significance doesn't prove delivery delay is the *only* cause, but the effect size here is large enough that it's hard to explain any other way.

**Repeat customers are rare, but disproportionately valuable.** Only about 3% of customers ever placed a second order, yet that 3% accounts for roughly 5% of total revenue. K-Means clustering on Recency/Frequency/Monetary confirms this independently: the resulting "Champions" segment is 2,801 customers (about 3% of the base) but drives 61.5% of total revenue.

**Growth has come from more customers, not bigger baskets.** Average order value stayed flat — roughly $125–160 — across nearly two years, while total monthly orders climbed steadily. Whatever's driving revenue growth, it isn't customers spending more per purchase.

**Delivery delay isn't evenly spread across the country.** Excluding low-volume states to avoid reading too much into small samples, sellers based in Maranhão (MA) have a 23% late-delivery rate on 389 orders — well above São Paulo's 8.7% on nearly 69,000 orders. That gap is large enough on a big enough sample to be worth investigating as a real regional logistics issue.

**November 24, 2017 — Black Friday — shows up as a clear single-day spike** in the revenue trend, followed by a dip in December consistent with demand being pulled forward rather than lost. Found independently in both the SQL and the Python EDA.

---

## Dashboard

Three pages, built on the cleaned dataset and the RFM segments:

- **Executive Overview** — revenue trend, category performance, payment mix, core KPIs
- **Customer Segments** — segment sizes, RFM profile per segment, revenue contribution
- **Operations** — delivery performance, review score vs. delay, late-delivery rate by seller state

Full PDF export: [`dashboards/RetailPulse_Dashboard.pdf`](dashboards/RetailPulse_Dashboard.pdf)

---

## How the project is organized

```
RetailPulse/
├── schema/
│   ├── Database_schema.pgerd       ER diagram
│   └── table_structure.sql         CREATE TABLE statements for all 9 tables
├── sql/
│   ├── A_Revenue&Trends.sql
│   ├── B_CustomerAnalysis.sql
│   ├── C_Delivery&Operations.sql
│   ├── D_Product&SellerPerformance.sql
│   ├── E_Payments.sql
│   └── F_DataQuality&Validation.sql
├── notebooks/
│   ├── 01_eda_datacleaning.ipynb   cleaning, merging, feature engineering, EDA, t-test
│   └── 02_rfm_segmentation.ipynb   RFM table, scaling, elbow method, K-Means, segment naming
├── data/
│   ├── rfm_segments.csv            output of the segmentation notebook
│   └── README.md                   notes on regenerating the full dataset
├── dashboards/
│   ├── RetailPulse.pbix
│   └── RetailPulse_Dashboard.pdf
└── README.md
```

**Database:** the raw Olist CSVs were loaded into PostgreSQL as 9 properly normalized tables (customers, orders, order items, products, sellers, payments, reviews, geolocation, and a category-name translation table), with primary and foreign keys enforced rather than assumed.

**SQL:** 23 queries split across six files, each one framed as an actual business question rather than a generic "show me the data" query — things like month-over-month growth, repeat-purchase rate, late-delivery rate by seller region, and a handful of data-quality checks (duplicate reviews, mismatched payment totals, orphaned product references).

**Python:** the two notebooks pick up where SQL leaves off. The first handles cleaning, merging eight tables into one working dataset, feature engineering, exploratory charts, and the delivery-delay t-test. The second builds the RFM table, scales and log-transforms it to handle skew, uses the elbow method to justify k=4, runs K-Means, and turns the four resulting clusters into named business segments (Champions, Potential Loyalists, New/Low-Value, Lost).

**Dashboard:** built on top of both the raw database and the segmentation output, three pages, fully cross-filterable.

---

## Data quality notes

Real datasets aren't clean by default, and a few genuine issues turned up during the cleaning pass rather than being assumed away:

- A handful of `order_items` rows had shipping-limit dates years in the future, inconsistent with orders that were already cancelled or delivered — almost certainly a data entry error, fixed by imputing from the order's approval date rather than dropped.
- About 1.85% of products were missing a category. Rather than drop them and lose otherwise-usable price and weight data, they were labeled `unknown` and kept.
- A small number of order-items referenced a `product_id` with no matching row in the products table at all — handled the same way, labeled and retained rather than discarded.

Full reasoning for each decision, including the investigation steps, is documented inline in `01_eda_datacleaning.ipynb`.

---

## Running it yourself

**1. Clone and set up the database**
```bash
git clone https://github.com/ExpertAvinash/RetailPulse.git
cd RetailPulse
```
Create a PostgreSQL database, run `schema/table_structure.sql`, then load the [Olist dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) CSVs into their matching tables.

**2. Add your own credentials**

Create a `.env` file in the project root (this is git-ignored, you'll need to make your own):
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_database
DB_USER=your_username
DB_PASSWORD=your_password
```

**3. Run the notebooks, in order**

`01_eda_datacleaning.ipynb` first — connects to the database, cleans and merges everything, exports the working dataset. Then `02_rfm_segmentation.ipynb` — builds the RFM table and runs the clustering.

**4. Open the dashboard**

`dashboards/RetailPulse.pbix` in Power BI Desktop, pointed at the same database plus `data/rfm_segments.csv`.

---

## A couple of honest caveats

Statistical significance in the t-test means the delivery-delay effect is very unlikely to be random noise — it doesn't by itself prove delay is the *only* thing driving low reviews. Low-volume states (like the few states excluded from the delivery-rate comparison) would need more data before any operational decision gets made off them. And the RFM segment names are my own business interpretation of the clusters K-Means found, not labels the algorithm produced on its own.

---

## Dataset

[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — roughly 99,000 orders placed on the Olist marketplace in Brazil between 2016 and 2018, covering orders, customers, products, sellers, payments, and reviews.

---

**Avinash Paliwal**
GitHub: https://github.com/ExpertAvinash
LinkedIn: https://www.linkedin.com/in/avinash-paliwal-a710a1253/