# Financial Performance, Receivables & Working-Capital Analytics

This is a starter project for an end-to-end analytics portfolio.

> **Dataset disclaimer:** All records supplied in `data/` are synthetic and generated for learning. They do not describe a real company. Currency is assumed to be Indian rupees (INR). Reporting date: 30 June 2026.

## Included data
- `customers.csv`: customer attributes
- `products.csv`: product category, unit cost and list price
- `orders.csv`: order header records
- `order_items.csv`: item-level sales and discounts
- `invoices.csv`: invoice amount and due date
- `payments.csv`: full and partial payments
- `inventory_snapshots.csv`: opening and closing inventory snapshots

No external dataset download is required. Use these supplied CSVs to start.

## Tools
SQL Server/SSMS, Python with Pandas, Excel/Power Query, Power BI, Git/GitHub.

## Quick start
1. Extract the ZIP to a project folder, for example `C:\Projects\financial-working-capital-analytics`.
2. Open `sql/00_create_database.sql` in SSMS and execute it to create a separate `FinancialOpsDB` database.
3. In SSMS, right-click `FinancialOpsDB` > Tasks > Import Flat File for each CSV in `data/`. Use destination table names matching the CSV basenames (without `.csv`): `customers`, `products`, `orders`, `order_items`, `invoices`, `payments`, `inventory_snapshots`.
4. Review inferred data types during import. IDs and quantities should be whole numbers, dates should be dates, and money columns should use a fixed precision type such as `decimal(18,2)` where possible.
5. After all seven CSVs are imported, run `sql/01_data_quality_checks.sql`, then the analysis scripts in numeric order.
6. Run `python/validate_data.py` from the project root after installing Pandas (`python -m pip install pandas`).
7. Use the query outputs to build Power BI visuals; do not claim any findings until you have run and reviewed the calculations.

## Business questions
- What are net sales, gross profit, gross margin, and average order value?
- How much remains outstanding or overdue as of the reporting date?
- Which customers carry the largest overdue balances?
- Which products have relatively low gross margins?
- What do the available inventory snapshots show?

## Important metric notes
- Net sales = quantity × unit selling price − line discount.
- COGS = quantity × product unit cost.
- Gross profit excludes overhead, freight and other operating expenses.
- Outstanding = invoice amount minus payments received on/before the reporting date, floored at zero. This starter data has no credit notes/write-offs.
- Inventory turnover and days inventory outstanding require appropriate period-level costs and inventory valuation; only report them if you define and justify the method.
- A receivable being overdue is an exposure for follow-up, not proof of bad debt.

## Additional SQL scripts
- `sql/04_inventory_snapshot_analysis.sql`: values current stock and compares opening/closing snapshots.
- `sql/05_customer_revenue_concentration.sql`: ranks customers and calculates revenue shares.

## GitHub contribution setup
See `docs/GITHUB_CONTRIBUTION_WORKFLOW.md` for the first local commit and frequent, meaningful contribution workflow.
