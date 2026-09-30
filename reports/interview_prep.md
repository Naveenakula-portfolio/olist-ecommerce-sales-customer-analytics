# Interview Preparation: Olist E-commerce Analytics

## 1. What was the business objective?
**Sample answer:** I analyzed a public e-commerce dataset to understand order activity, product-category item value, payment behavior, delivery performance, and review scores. The goal was to turn multiple raw CSV tables into clear KPIs and business questions.

## 2. Why did you use SQL and Python?
**Sample answer:** SQL was useful for joining relational tables and aggregating business metrics. Python helped me inspect data quality, perform exploratory analysis, create charts, and validate the SQL results.

## 3. Why aggregate order items before joining them to orders?
**Sample answer:** An order can contain multiple items. If I join raw order items, payments, and reviews together, the one-to-many relationships can multiply rows and inflate totals. I aggregated each child table at order level before joining.

## 4. What is the difference between item value and profit?
**Sample answer:** Item value is the sum of item prices. Profit requires costs such as product cost, fulfillment, marketing, and operating expenses. This dataset does not provide a complete cost structure, so I do not claim to calculate profit.

## 5. How did you handle missing data?
**Sample answer:** I measured missingness by column and examined why fields might be missing. I did not invent delivery timestamps or categories. Missing delivery times were excluded only from calculations that require an actual delivery timestamp.

## 6. How did you define a late delivery?
**Sample answer:** For delivered orders with both timestamps available, I compared the actual customer delivery timestamp with the estimated delivery date. An actual delivery later than the estimate was marked late.

## 7. What did you learn about reviews and delivery?
**Sample answer:** Average review scores were lower among orders delivered after the estimated date. This is an association, not proof that delay alone caused the lower score. Product quality, expectations, and customer support may also matter.

## 8. How did you validate your analysis?
**Sample answer:** I calculated delivered item value and delivered order count in both SQL and Python, then compared the results. I used assertions so the notebook would fail if the values did not match within a small tolerance.

## 9. What are the project's limitations?
**Sample answer:** The data is historical, missing values exist, item value is not profit, and observational review analysis cannot establish causality. Repeat customer results also depend on the dataset's time window and customer identifiers.

## 10. What would you do next?
**Sample answer:** I would build customer cohorts, segment delivery performance by seller and state, review category-level satisfaction, and add a Power BI dashboard. I would also ask stakeholders which KPIs they use to make decisions.
