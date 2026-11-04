USE FinancialOpsDB;
GO
-- Revenue = quantity * price less line discount. Gross profit excludes overhead.
WITH line_metrics AS (
    SELECT o.order_id, o.order_date, o.customer_id, o.region, oi.product_id,
           CAST(oi.quantity * oi.unit_selling_price - oi.discount_amount AS decimal(18,2)) AS net_revenue,
           CAST(oi.quantity * p.unit_cost AS decimal(18,2)) AS cogs
    FROM dbo.orders o
    JOIN dbo.order_items oi ON oi.order_id=o.order_id
    JOIN dbo.products p ON p.product_id=oi.product_id
)
SELECT SUM(net_revenue) AS net_sales_revenue, SUM(cogs) AS cogs,
       SUM(net_revenue-cogs) AS gross_profit,
       CAST(100.0*SUM(net_revenue-cogs)/NULLIF(SUM(net_revenue),0) AS decimal(8,2)) AS gross_margin_pct,
       COUNT(DISTINCT order_id) AS order_count,
       CAST(SUM(net_revenue)/NULLIF(COUNT(DISTINCT order_id),0) AS decimal(18,2)) AS average_order_value
FROM line_metrics;
GO

-- Monthly financial trend
WITH x AS (
    SELECT DATEFROMPARTS(YEAR(o.order_date),MONTH(o.order_date),1) AS sales_month,
           oi.quantity*oi.unit_selling_price-oi.discount_amount AS net_revenue,
           oi.quantity*p.unit_cost AS cogs
    FROM dbo.orders o JOIN dbo.order_items oi ON oi.order_id=o.order_id
    JOIN dbo.products p ON p.product_id=oi.product_id
)
SELECT sales_month, SUM(net_revenue) AS net_revenue, SUM(cogs) AS cogs,
       SUM(net_revenue-cogs) AS gross_profit
FROM x GROUP BY sales_month ORDER BY sales_month;
GO

-- Product profitability
SELECT p.product_id, p.product_name,
       SUM(oi.quantity*oi.unit_selling_price-oi.discount_amount) AS net_revenue,
       SUM(oi.quantity*p.unit_cost) AS cogs,
       SUM(oi.quantity*oi.unit_selling_price-oi.discount_amount-oi.quantity*p.unit_cost) AS gross_profit,
       CAST(100.0*SUM(oi.quantity*oi.unit_selling_price-oi.discount_amount-oi.quantity*p.unit_cost)
         /NULLIF(SUM(oi.quantity*oi.unit_selling_price-oi.discount_amount),0) AS decimal(8,2)) AS gross_margin_pct
FROM dbo.order_items oi JOIN dbo.products p ON p.product_id=oi.product_id
GROUP BY p.product_id,p.product_name ORDER BY gross_profit DESC;
GO
