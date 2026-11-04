# Metric Dictionary

**Reporting date:** 2026-06-30  
**Currency assumption:** INR (₹)  
**Data status:** Synthetic / illustrative.

- **Net sales revenue:** Sum of quantity × unit selling price − line discount.
- **COGS:** Sum of quantity × product unit cost.
- **Gross profit:** Net sales revenue − COGS. Excludes overhead and other operating costs.
- **Gross margin %:** Gross profit ÷ net sales revenue × 100 when revenue is positive.
- **Average order value:** Net sales revenue ÷ distinct order count.
- **Outstanding invoice balance:** Invoice amount − payments received on/before reporting date, floored at zero.
- **Days overdue:** Reporting date − due date for an invoice with an outstanding balance and a due date before the reporting date; otherwise zero.
- **Aging buckets:** Current, 1–30, 31–60, 61–90, Over 90 days. Assign each outstanding balance to one bucket.
- **Inventory snapshots:** Inventory quantity recorded at a specific date. Two snapshots alone do not prove stockout history or robust inventory turnover.

## Reconciliation
Compare invoice amounts to line-item totals, and compare invoice balances to payment totals. Independently calculate selected metrics in Python and SQL. Log mismatches and investigate rather than silently altering values.
