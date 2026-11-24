/*
    File: database/04_programmability/views/vw_product_ratings.sql
    Table(s): Products, Categories, Vendor_Products, Order_Items, Reviews
    Description: Computes average product ratings and review counts per shared
                 product without join-induced inflation.
    Prerequisite(s): 01_schema/.../05_categories.sql through 09_vendor_products.sql, 17_order_items.sql, 20_reviews.sql
*/

USE pckal_db;

CREATE OR REPLACE VIEW vw_product_ratings AS
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    c.category_name,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.product_rating), 2) AS avg_product_rating
FROM Products p
JOIN Categories c ON c.category_id = p.category_id
LEFT JOIN Vendor_Products vp ON vp.product_id = p.product_id
LEFT JOIN Order_Items oi ON oi.vendor_product_id = vp.vendor_product_id
LEFT JOIN Reviews r ON r.order_item_id = oi.order_item_id
GROUP BY
    p.product_id,
    p.product_name,
    p.brand,
    c.category_name;