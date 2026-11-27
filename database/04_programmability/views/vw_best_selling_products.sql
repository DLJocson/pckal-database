/*
    File: database/04_programmability/views/vw_best_selling_products.sql
    Table(s): Products, Categories, Vendor_Products, Order_Items,
              Vendor_Orders, Orders, Payments
    Description: Ranks shared products by total units sold and net revenue from
                 completed orders with succeeded payments.
    Prerequisite(s): 01_schema/.../05_categories.sql through 09_vendor_products.sql, 15_orders.sql through 18_payments.sql
*/

USE pckal_db;

CREATE OR REPLACE VIEW vw_best_selling_products AS
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    c.category_name,
    COALESCE(SUM(CASE
        WHEN o.order_status = 'completed'
         AND o.completion_date IS NOT NULL
         AND pay.payment_status = 'succeeded'
        THEN oi.quantity
        ELSE 0
    END), 0) AS total_units_sold,
    COUNT(DISTINCT CASE
        WHEN o.order_status = 'completed'
         AND o.completion_date IS NOT NULL
         AND pay.payment_status = 'succeeded'
        THEN o.order_id
    END) AS completed_orders_count,
    ROUND(COALESCE(SUM(CASE
        WHEN o.order_status = 'completed'
         AND o.completion_date IS NOT NULL
         AND pay.payment_status = 'succeeded'
        THEN (oi.unit_price_before_discount - oi.discount_applied_per_unit) * oi.quantity
        ELSE 0.00
    END), 0.00), 2) AS net_revenue
FROM Products p
JOIN Categories c ON c.category_id = p.category_id
LEFT JOIN Vendor_Products vp ON vp.product_id = p.product_id
LEFT JOIN Order_Items oi ON oi.vendor_product_id = vp.vendor_product_id
LEFT JOIN Vendor_Orders vo ON vo.vendor_order_id = oi.vendor_order_id
LEFT JOIN Orders o ON o.order_id = vo.order_id
LEFT JOIN Payments pay ON pay.order_id = o.order_id
GROUP BY
    p.product_id,
    p.product_name,
    p.brand,
    c.category_name
ORDER BY
    total_units_sold DESC,
    net_revenue DESC;