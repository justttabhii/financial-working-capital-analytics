USE FinancialOpsDB;
GO
-- Revenue concentration by customer. Revenue is based on net order-item sales.
WITH customer_sales AS (
    SELECT o.customer_id,
           SUM(CAST(oi.quantity * oi.unit_selling_price - oi.discount_amount AS decimal(18,2))) AS net_revenue
    FROM dbo.orders o
    JOIN dbo.order_items oi ON oi.order_id = o.order_id
    GROUP BY o.customer_id
), ranked AS (
    SELECT c.customer_id, c.customer_name, c.customer_segment, c.region,
           cs.net_revenue,
           CAST(100.0 * cs.net_revenue / NULLIF(SUM(cs.net_revenue) OVER (), 0) AS decimal(8,2)) AS revenue_share_pct,
           RANK() OVER (ORDER BY cs.net_revenue DESC) AS revenue_rank
    FROM customer_sales cs
    JOIN dbo.customers c ON c.customer_id = cs.customer_id
)
SELECT customer_id, customer_name, customer_segment, region,
       net_revenue, revenue_share_pct, revenue_rank
FROM ranked
ORDER BY revenue_rank, customer_id;
GO

-- Top 10 customers and their share of total revenue
WITH customer_sales AS (
    SELECT o.customer_id,
           SUM(CAST(oi.quantity * oi.unit_selling_price - oi.discount_amount AS decimal(18,2))) AS net_revenue
    FROM dbo.orders o
    JOIN dbo.order_items oi ON oi.order_id = o.order_id
    GROUP BY o.customer_id
), ranked AS (
    SELECT customer_id, net_revenue,
           100.0 * net_revenue / NULLIF(SUM(net_revenue) OVER (), 0) AS revenue_share_pct,
           ROW_NUMBER() OVER (ORDER BY net_revenue DESC) AS rn
    FROM customer_sales
)
SELECT r.rn AS revenue_rank, c.customer_name, r.net_revenue,
       CAST(r.revenue_share_pct AS decimal(8,2)) AS revenue_share_pct
FROM ranked r JOIN dbo.customers c ON c.customer_id = r.customer_id
WHERE r.rn <= 10
ORDER BY r.rn;
GO
