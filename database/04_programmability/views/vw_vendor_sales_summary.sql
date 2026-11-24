/*
    File: database/04_programmability/views/vw_vendor_sales_summary.sql
    Table(s): Vendors, Vendor_Orders, Orders, Payments, Order_Items
    Description: Aggregates completed, paid sales metrics per vendor without
                 duplicating line-item quantities or totals.
    Prerequisite(s): 01_schema/.../04_vendors.sql, 15_orders.sql through 18_payments.sql
*/

USE pckal_db;

CREATE OR REPLACE VIEW vw_vendor_sales_summary AS
SELECT
    v.vendor_id,
    v.store_name AS vendor_name,
    v.account_status AS vendor_status,
    COUNT(DISTINCT CASE
        WHEN o.order_status = 'completed'
         AND o.completion_date IS NOT NULL
         AND pay.payment_status = 'succeeded'
        THEN vo.vendor_order_id
    END) AS completed_suborders_count,
    COALESCE(SUM(CASE
        WHEN o.order_status = 'completed'
         AND o.completion_date IS NOT NULL
         AND pay.payment_status = 'succeeded'
        THEN oi.quantity
        ELSE 0
    END), 0) AS total_units_sold,
    ROUND(COALESCE(SUM(CASE
        WHEN o.order_status = 'completed'
         AND o.completion_date IS NOT NULL
         AND pay.payment_status = 'succeeded'
        THEN oi.unit_price_before_discount * oi.quantity
        ELSE 0.00
    END), 0.00), 2) AS gross_sales,
    ROUND(COALESCE(SUM(CASE
        WHEN o.order_status = 'completed'
         AND o.completion_date IS NOT NULL
         AND pay.payment_status = 'succeeded'
        THEN oi.discount_applied_per_unit * oi.quantity
        ELSE 0.00
    END), 0.00), 2) AS total_discounts,
    ROUND(COALESCE(SUM(CASE
        WHEN o.order_status = 'completed'
         AND o.completion_date IS NOT NULL
         AND pay.payment_status = 'succeeded'
        THEN (oi.unit_price_before_discount - oi.discount_applied_per_unit) * oi.quantity
        ELSE 0.00
    END), 0.00), 2) AS net_sales
FROM Vendors v
LEFT JOIN Vendor_Orders vo ON vo.vendor_id = v.vendor_id
LEFT JOIN Orders o ON o.order_id = vo.order_id
LEFT JOIN Payments pay ON pay.order_id = o.order_id
LEFT JOIN Order_Items oi ON oi.vendor_order_id = vo.vendor_order_id
GROUP BY
    v.vendor_id,
    v.store_name,
    v.account_status
ORDER BY
    net_sales DESC,
    total_units_sold DESC;