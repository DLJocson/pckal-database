/*
    File: database/04_programmability/views/vw_vendor_ratings.sql
    Table(s): Vendors, Vendor_Orders, Order_Items, Reviews
    Description: Computes average seller ratings across non-NULL seller_rating
                 values linked through Order_Items -> Vendor_Orders -> Vendors.
    Prerequisite(s): 01_schema/.../04_vendors.sql, 16_vendor_orders.sql, 17_order_items.sql, 20_reviews.sql
*/

USE pckal_db;

CREATE OR REPLACE VIEW vw_vendor_ratings AS
SELECT
    v.vendor_id,
    v.store_name AS vendor_name,
    v.account_status AS vendor_status,
    COUNT(r.seller_rating) AS seller_rating_count,
    ROUND(AVG(r.seller_rating), 2) AS avg_seller_rating
FROM Vendors v
LEFT JOIN Vendor_Orders vo ON vo.vendor_id = v.vendor_id
LEFT JOIN Order_Items oi ON oi.vendor_order_id = vo.vendor_order_id
LEFT JOIN Reviews r ON r.order_item_id = oi.order_item_id
GROUP BY
    v.vendor_id,
    v.store_name,
    v.account_status;