/*
Inventory snapshot analysis.
The dataset has two synthetic snapshots: 2025-12-31 and 2026-06-30.
Do not interpret snapshot differences as detailed daily inventory movements.
*/
USE FinancialOpsDB;
GO

-- Current stock exposure by product as of 2026-06-30
WITH snapshot_values AS (
    SELECT s.product_id, s.snapshot_date, s.stock_quantity,
           CAST(s.stock_quantity * p.unit_cost AS decimal(18,2)) AS stock_value
    FROM dbo.inventory_snapshots s
    JOIN dbo.products p ON p.product_id = s.product_id
)
SELECT sv.product_id, p.product_name, sv.snapshot_date,
       sv.stock_quantity, sv.stock_value
FROM snapshot_values sv
JOIN dbo.products p ON p.product_id = sv.product_id
WHERE sv.snapshot_date = '2026-06-30'
ORDER BY sv.stock_value DESC;
GO

-- Compare opening and closing snapshots per product
WITH sv AS (
    SELECT s.product_id, s.snapshot_date, s.stock_quantity,
           CAST(s.stock_quantity * p.unit_cost AS decimal(18,2)) AS stock_value
    FROM dbo.inventory_snapshots s
    JOIN dbo.products p ON p.product_id = s.product_id
), opening AS (
    SELECT product_id, stock_quantity AS opening_quantity, stock_value AS opening_value
    FROM sv WHERE snapshot_date = '2025-12-31'
), closing AS (
    SELECT product_id, stock_quantity AS closing_quantity, stock_value AS closing_value
    FROM sv WHERE snapshot_date = '2026-06-30'
)
SELECT p.product_id, p.product_name,
       o.opening_quantity, c.closing_quantity,
       c.closing_quantity - o.opening_quantity AS quantity_change,
       o.opening_value, c.closing_value,
       c.closing_value - o.opening_value AS stock_value_change
FROM dbo.products p
JOIN opening o ON o.product_id = p.product_id
JOIN closing c ON c.product_id = p.product_id
ORDER BY stock_value_change DESC;
GO
