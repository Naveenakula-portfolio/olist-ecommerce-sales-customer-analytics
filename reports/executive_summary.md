# Executive Summary — Olist E-commerce Analytics

## Objective
Analyze the Olist Brazilian E-Commerce dataset to summarize order activity, delivered item value, product category performance, payment behavior, delivery timeliness, and review scores.

## Scope
The source archive contains nine CSV tables. Order-purchase timestamps range from 2016-09-04 to 2018-10-17. The dataset includes 99,441 orders, 112,650 order-item rows, 103,886 payment records, and 99,224 review records.

## Key results
1. **Order completion:** 96,478 of 99,441 orders have a `delivered` status (97.02%).
2. **Delivered item value:** Item `price` values associated with delivered orders total BRL 13,221,498.11. This is a merchandise-value proxy, not profit or audited revenue.
3. **Category value:** `health_beauty` is the highest delivered item-value category at BRL 1,233,131.72; this category represents 9.33% of delivered item value.
4. **Delivery duration:** Mean time from purchase to customer delivery is 12.56 days among delivered orders with valid timestamps.
5. **Late deliveries:** 7,826 of 96,470 delivered orders with both actual and estimated delivery timestamps arrived late (8.11%).
6. **Reviews:** Mean review score is 4.09/5; 14.69% of review records score 1 or 2.
7. **Delivery and reviews:** Mean review score is 4.29 for orders delivered on/before estimate versus 2.57 for late orders. This is an association and does not establish causation.
8. **Repeat customer indicator:** 2,997 of 96,096 unique customer IDs (3.12%) are associated with more than one order.
9. **Geographic concentration:** Customer state `SP` has 40,501 delivered orders, the highest state-level count.
10. **Observed order peak:** 2017-11 has the highest delivered order count in the observed monthly series (7,289 orders).

## Recommendations for further investigation
- Segment late delivery rates by seller, state, and product category to identify where operational review may be useful.
- Compare category item value with order counts and review scores; do not infer profitability without cost data.
- Investigate low-review orders alongside delivery timing, category, and available review comments while acknowledging confounding factors.
- Analyze repeat-order behavior by customer cohort, and acknowledge that the dataset's observation window may not capture full customer history.
- Standardize metric definitions and preserve order-level aggregation when joining items, payments, and reviews.

## Data quality and limitations
- The geolocation table contains 261,831 exact duplicate rows; it should not be used as a one-to-one lookup without aggregation.
- 610 product records have missing category values; 2 have missing weight.
- 160 orders lack approval timestamps and 2,965 lack customer delivery timestamps across all order statuses.
- Missing values were not imputed with invented timestamps or categories.
- Item value is not profit; full operating costs are not available in this dataset.
- Review associations are descriptive, not causal.
- The dataset is historical (2016–2018), not a current representation of Brazilian e-commerce.

## KPI definitions
- **Delivered order rate:** delivered orders / all orders.
- **Delivered item value:** sum of item price for items associated with delivered orders.
- **Average delivery duration:** mean elapsed days from purchase to customer delivery, among delivered orders with valid timestamps.
- **Late delivery rate:** delivered orders after estimated date / delivered orders with actual and estimated dates.
- **Low-review rate:** review records with score <= 2 / all review records.
- **Repeat customer rate:** unique customer IDs with more than one order / all unique customer IDs represented in the orders data.
