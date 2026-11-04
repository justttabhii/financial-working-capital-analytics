USE FinancialOpsDB;
GO
DECLARE @ReportingDate date = '2026-06-30';

-- Aggregate payments first to avoid multiplying invoice rows.
WITH payment_totals AS (
    SELECT invoice_id, SUM(payment_amount) AS total_paid
    FROM dbo.payments WHERE payment_date <= @ReportingDate GROUP BY invoice_id
),
balances AS (
    SELECT i.invoice_id, i.customer_id, i.invoice_date, i.due_date, i.invoice_amount,
           COALESCE(pt.total_paid,0) AS total_paid,
           CASE WHEN i.invoice_amount-COALESCE(pt.total_paid,0)<0 THEN 0
                ELSE i.invoice_amount-COALESCE(pt.total_paid,0) END AS outstanding_balance,
           CASE WHEN i.due_date<@ReportingDate AND i.invoice_amount-COALESCE(pt.total_paid,0)>0
                THEN DATEDIFF(day,i.due_date,@ReportingDate) ELSE 0 END AS days_overdue
    FROM dbo.invoices i LEFT JOIN payment_totals pt ON pt.invoice_id=i.invoice_id
)
SELECT SUM(outstanding_balance) AS total_outstanding,
       SUM(CASE WHEN days_overdue>0 THEN outstanding_balance ELSE 0 END) AS total_overdue,
       CAST(100.0*SUM(CASE WHEN days_overdue>0 THEN outstanding_balance ELSE 0 END)
            /NULLIF(SUM(outstanding_balance),0) AS decimal(8,2)) AS overdue_pct
FROM balances;
GO

-- Aging buckets. Paid invoices have zero outstanding; they are separated from aging.
WITH payment_totals AS (
    SELECT invoice_id,SUM(payment_amount) total_paid FROM dbo.payments
    WHERE payment_date<='2026-06-30' GROUP BY invoice_id
),
balances AS (
    SELECT i.invoice_id,i.due_date,
           CASE WHEN i.invoice_amount-COALESCE(pt.total_paid,0)<0 THEN 0
                ELSE i.invoice_amount-COALESCE(pt.total_paid,0) END outstanding_balance,
           CASE WHEN i.due_date<'2026-06-30' AND i.invoice_amount-COALESCE(pt.total_paid,0)>0
                THEN DATEDIFF(day,i.due_date,'2026-06-30') ELSE 0 END days_overdue
    FROM dbo.invoices i LEFT JOIN payment_totals pt ON pt.invoice_id=i.invoice_id
)
SELECT CASE WHEN outstanding_balance=0 THEN 'Paid'
            WHEN days_overdue=0 THEN 'Current'
            WHEN days_overdue BETWEEN 1 AND 30 THEN '1-30 days'
            WHEN days_overdue BETWEEN 31 AND 60 THEN '31-60 days'
            WHEN days_overdue BETWEEN 61 AND 90 THEN '61-90 days'
            ELSE 'Over 90 days' END AS aging_bucket,
       SUM(outstanding_balance) AS balance_amount, COUNT(*) AS invoice_count
FROM balances
GROUP BY CASE WHEN outstanding_balance=0 THEN 'Paid'
              WHEN days_overdue=0 THEN 'Current'
              WHEN days_overdue BETWEEN 1 AND 30 THEN '1-30 days'
              WHEN days_overdue BETWEEN 31 AND 60 THEN '31-60 days'
              WHEN days_overdue BETWEEN 61 AND 90 THEN '61-90 days'
              ELSE 'Over 90 days' END
ORDER BY MIN(days_overdue);
GO

-- Largest overdue customer balances
WITH payment_totals AS (
    SELECT invoice_id,SUM(payment_amount) total_paid FROM dbo.payments
    WHERE payment_date<='2026-06-30' GROUP BY invoice_id
),
balances AS (
    SELECT i.customer_id,
           CASE WHEN i.invoice_amount-COALESCE(pt.total_paid,0)<0 THEN 0
                ELSE i.invoice_amount-COALESCE(pt.total_paid,0) END outstanding_balance,
           CASE WHEN i.due_date<'2026-06-30' AND i.invoice_amount-COALESCE(pt.total_paid,0)>0
                THEN DATEDIFF(day,i.due_date,'2026-06-30') ELSE 0 END days_overdue
    FROM dbo.invoices i LEFT JOIN payment_totals pt ON pt.invoice_id=i.invoice_id
)
SELECT c.customer_id,c.customer_name,SUM(b.outstanding_balance) AS overdue_balance
FROM balances b JOIN dbo.customers c ON c.customer_id=b.customer_id
WHERE b.days_overdue>0
GROUP BY c.customer_id,c.customer_name
ORDER BY overdue_balance DESC;
GO
