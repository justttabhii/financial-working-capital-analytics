USE FinancialOpsDB;
GO
-- Run after importing all seven CSVs into dbo tables with matching names.
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM dbo.customers
UNION ALL SELECT 'products', COUNT(*) FROM dbo.products
UNION ALL SELECT 'orders', COUNT(*) FROM dbo.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM dbo.order_items
UNION ALL SELECT 'invoices', COUNT(*) FROM dbo.invoices
UNION ALL SELECT 'payments', COUNT(*) FROM dbo.payments
UNION ALL SELECT 'inventory_snapshots', COUNT(*) FROM dbo.inventory_snapshots;
GO

-- Each duplicate query should return no rows.
SELECT customer_id, COUNT(*) FROM dbo.customers GROUP BY customer_id HAVING COUNT(*) > 1;
SELECT product_id, COUNT(*) FROM dbo.products GROUP BY product_id HAVING COUNT(*) > 1;
SELECT order_id, COUNT(*) FROM dbo.orders GROUP BY order_id HAVING COUNT(*) > 1;
SELECT item_id, COUNT(*) FROM dbo.order_items GROUP BY item_id HAVING COUNT(*) > 1;
SELECT invoice_id, COUNT(*) FROM dbo.invoices GROUP BY invoice_id HAVING COUNT(*) > 1;
SELECT payment_id, COUNT(*) FROM dbo.payments GROUP BY payment_id HAVING COUNT(*) > 1;
GO

-- Each orphan-reference query should return no rows.
SELECT o.order_id FROM dbo.orders o LEFT JOIN dbo.customers c ON c.customer_id=o.customer_id WHERE c.customer_id IS NULL;
SELECT i.item_id FROM dbo.order_items i LEFT JOIN dbo.orders o ON o.order_id=i.order_id WHERE o.order_id IS NULL;
SELECT i.item_id FROM dbo.order_items i LEFT JOIN dbo.products p ON p.product_id=i.product_id WHERE p.product_id IS NULL;
SELECT inv.invoice_id FROM dbo.invoices inv LEFT JOIN dbo.orders o ON o.order_id=inv.order_id WHERE o.order_id IS NULL;
SELECT p.payment_id FROM dbo.payments p LEFT JOIN dbo.invoices i ON i.invoice_id=p.invoice_id WHERE i.invoice_id IS NULL;
SELECT s.snapshot_id FROM dbo.inventory_snapshots s LEFT JOIN dbo.products p ON p.product_id=s.product_id WHERE p.product_id IS NULL;
GO

-- Basic invalid value checks: each should return no rows.
SELECT * FROM dbo.order_items WHERE quantity <= 0 OR unit_selling_price < 0 OR discount_amount < 0;
SELECT * FROM dbo.invoices WHERE invoice_amount < 0 OR due_date < invoice_date;
SELECT * FROM dbo.payments WHERE payment_amount <= 0;
SELECT * FROM dbo.inventory_snapshots WHERE stock_quantity < 0;
GO
