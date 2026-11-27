/*
    File: database/04_programmability/views/vw_monthly_sales.sql
    Table(s): Orders, Payments, Vendor_Orders, Order_Items
    Description: Summarizes monthly sales from completed orders with
                 succeeded payments, grouped by completion_date year and month.
                 Excludes pending, processing, cancelled, or unpaid orders.
    Prerequisite(s): 01_schema/.../15_orders.sql through 18_payments.sql
*/

USE pckal_db;

CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT
    YEAR(o.completion_date) AS sales_year,
    MONTH(o.completion_date) AS sales_month,
    DATE_FORMAT(o.completion_date, '%Y-%m') AS year_month_label,
    COUNT(DISTINCT o.order_id) AS completed_orders_count,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    ROUND(COALESCE(SUM(oi.unit_price_before_discount * oi.quantity), 0.00), 2) AS gross_sales,
    ROUND(COALESCE(SUM(oi.discount_applied_per_unit * oi.quantity), 0.00), 2) AS total_discounts,
    ROUND(
        COALESCE(
            SUM((oi.unit_price_before_discount - oi.discount_applied_per_unit) * oi.quantity),
            0.00
        ),
        2
    ) AS net_sales
FROM Orders o
JOIN Payments pay ON pay.order_id = o.order_id
JOIN Vendor_Orders vo ON vo.order_id = o.order_id
JOIN Order_Items oi ON oi.vendor_order_id = vo.vendor_order_id
WHERE o.order_status = 'completed'
  AND o.completion_date IS NOT NULL
  AND pay.payment_status = 'succeeded'
GROUP BY
    YEAR(o.completion_date),
    MONTH(o.completion_date),
    DATE_FORMAT(o.completion_date, '%Y-%m')
ORDER BY
    sales_year DESC,
    sales_month DESC;