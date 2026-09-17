# RetailPulse — Insights Report

**Analysis of ~99,000 orders from the Olist Brazilian e-commerce marketplace, 2016–2018**

---

## Summary

This report covers the core findings from an end-to-end analysis of the Olist dataset — built across PostgreSQL, Python, and Power BI. The short version: delivery performance is the single strongest lever on customer satisfaction in this data, repeat customers are rare but punch well above their weight in revenue, and the business's growth over the analyzed period came from acquiring more customers rather than getting existing ones to spend more per order.

Full methodology, code, and reasoning for every step are in the project's SQL files and Jupyter notebooks — this document focuses on what was found and what it means, not how it was calculated.

---

## 1. Delivery delay is costing real customer satisfaction

Every order in the dataset was bucketed by how late (or early) it arrived relative to its estimated delivery date, then compared against the review score the customer left.

| Delivery outcome | Average review score |
|---|---|
| On time or early | 4.29 / 5 |
| 1–3 days late | 3.29 / 5 |
| 4+ days late | 1.86 / 5 |

The drop is close to linear — each stage of lateness costs roughly a full star. Going from on-time to 4+ days late costs almost two and a half stars on average, which is a large effect by any standard.

To rule out the possibility this was just sampling noise, a two-sample t-test was run comparing on-time orders against orders delayed 4+ days:

```
t = 138.03
p < 0.001
```

A p-value this small means the difference is not something you'd expect to see by chance. This doesn't prove delivery delay is the *only* thing driving low reviews — customers who had a bad experience for other reasons could also be more likely to receive a late order, for instance — but the size of the effect and the statistical strength behind it make delivery delay a very hard signal to ignore.

**Why it matters:** review scores affect repeat-purchase likelihood and, on most marketplaces, product/seller visibility. If delivery reliability is treated as a pure logistics metric rather than a customer-experience one, it's being under-valued relative to its actual impact.

---

## 2. A small number of customers carry a disproportionate share of revenue

Across the full customer base, only about 3% of customers ever placed a second order. Everyone else bought once and never came back.

That 3%, though, isn't trivial — they account for roughly 5% of total revenue, meaning the average repeat customer is worth noticeably more than the average one-time buyer.

This was independently confirmed through a second, unrelated method: RFM (Recency, Frequency, Monetary) segmentation combined with K-Means clustering, run entirely separately from the SQL analysis above. The clustering identified four natural customer groups, and the smallest one — labeled "Champions" based on its recency, frequency, and spend profile — lines up closely with the same ~3%/~5% pattern found in SQL:

| Segment | Customers | Share of base | Share of revenue |
|---|---:|---:|---:|
| Potential Loyalists | 32,400 | ~35% | 61.5% |
| Lost | 27,141 | ~29% | 22.6% |
| New / Low-Value | 31,016 | ~33% | 10.4% |
| Champions | 2,801 | ~3% | 5.5% |

Champions and Potential Loyalists spend almost the same amount per customer on average (₹260 vs. ₹251) — the difference in total revenue share comes almost entirely from group size, not spending power. Potential Loyalists earn their name here: they're a much larger group of one-time buyers who already spent a meaningful amount, making them the highest-leverage retention target by sheer volume, even though Champions are individually the more loyal, repeat-purchasing customers.

**Why it matters:** Potential Loyalists — 32,400 customers who bought once, spent a meaningful amount, and did so recently — are the most efficient group to target for a second-purchase campaign. They already showed real intent; they just haven't been given a reason to come back. The Lost segment, despite being similar in size, has both been gone far longer (425 days on average vs. 160 for Potential Loyalists) and spent noticeably less per customer, making it a lower-priority, harder win-back.

---

## 3. Growth has come from more customers, not bigger orders

Average order value was tracked month over month across the full ~2-year window and stayed within a narrow band — roughly ₹125 to ₹160 — with no clear upward or downward trend.

Total monthly revenue, meanwhile, grew substantially over the same period. Since AOV stayed flat while revenue climbed, the growth has to be coming from somewhere else: order volume. More customers, more transactions — not existing customers spending more each time they buy.

**Why it matters:** if the business wants to keep growing, this data suggests continued customer acquisition has been doing the heavy lifting so far, and there may be untapped room on the other side — upselling, bundling, or minimum-order incentives designed to move AOV, which hasn't been a growth lever yet.

---

## 4. Late deliveries are not evenly distributed geographically

Grouping orders by the seller's state and calculating a late-delivery rate for each, after excluding states with too few orders to be statistically meaningful, revealed a real gap:

| Seller state | Late-delivery rate | Delivered orders |
|---|---:|---:|
| Maranhão (MA) | 23.1% | 389 |
| São Paulo (SP) | 8.7% | 68,641 |
| Rio de Janeiro (RJ) | 8.4% | 4,227 |

São Paulo, the largest seller hub by far, performs close to the overall average. Maranhão's rate is over 2.5x that, and while its order volume (389) is much smaller than São Paulo's, it's not so small that the number can be dismissed as noise — it's a large enough sample to represent a real pattern, not a fluke.

**Why it matters:** this points toward a specific, investigable operational issue rather than a general "delivery is slow" problem — something regional, possibly related to shipping infrastructure, seller density, or distance from major distribution hubs in that area.

---

## 5. Black Friday shows up clearly, and predictably

November 24, 2017 — Black Friday that year — produced a sharp, single-day spike in order volume, clearly visible in the monthly revenue trend as an outlier month. The following month showed a corresponding dip.

This pattern (a spike followed by a dip) is consistent with **demand pull-forward** — customers who would have bought in December instead bought during the Black Friday promotion, meaning some of what looks like "lost" December demand was actually just moved earlier, not lost outright.

This finding came up independently in both the SQL trend analysis and the separate Python EDA, landing on the same date both times.

**Why it matters:** mostly a sanity check that the data reflects real-world behavior accurately — but also a reminder that a demand dip immediately following a major promotion shouldn't automatically be read as a problem.

---

## Limitations worth stating plainly

- This is marketplace-level data from one platform (Olist) over a specific two-year window. It shouldn't be read as representative of Brazilian e-commerce broadly.
- Statistical significance in the t-test tells us the delivery-delay effect is real and unlikely to be chance — it doesn't isolate delivery delay as the sole cause of a low review, since other factors (product quality, seller communication) weren't controlled for here.
- The RFM segment names (Champions, Lost, etc.) are a business interpretation applied after clustering, not labels the algorithm itself produced. A different analyst might draw the segment boundaries slightly differently.
- Seller-state comparisons exclude low-volume states specifically to avoid over-reading small samples; some smaller states may still have real issues that this analysis wasn't able to confirm with confidence.

---

## Where this leads

If I were prioritizing next steps for this business based on what's here, in order:

1. **Investigate Maranhão's delivery pipeline specifically** — the gap is large and the sample is big enough to trust.
2. **Build a targeted second-purchase campaign for the Potential Loyalists segment** — 32,400 customers who already showed real spend and recency, the segment driving the largest share of revenue and the highest-leverage retention opportunity in the data.
3. **Test whether AOV can be moved** — since growth so far has been entirely volume-driven, bundling or minimum-order incentives represent an untested lever.

---

*Full analysis, code, and methodology available in the project repository: SQL queries in `sql/`, cleaning and statistical testing in `notebooks/01_eda_datacleaning.ipynb`, customer segmentation in `notebooks/02_rfm_segmentation.ipynb`.*