/*
    File: database/04_programmability/views/vw_active_promotions.sql
    Table(s): Promotions, Vendor_Products, Products, Vendors
    Description: Lists all currently active promotions as of CURDATE() along
                 with regular price, promotional price, and discount savings.
    Prerequisite(s): 01_schema/.../04_vendors.sql through 12_promotions.sql,
                     fn_calculate_promotional_price
*/

USE pckal_db;

CREATE OR REPLACE VIEW vw_active_promotions AS
SELECT
    pr.promotion_id,
    pr.vendor_product_id,
    v.vendor_id,
    v.store_name AS vendor_name,
    p.product_id,
    p.product_name,
    p.brand,
    vp.seller_sku,
    vp.listing_status,
    pr.discount_type,
    pr.discount_value,
    pr.start_date,
    pr.end_date,
    vp.price AS regular_price,
    fn_calculate_promotional_price(vp.vendor_product_id, CURDATE()) AS promotional_price,
    ROUND(
        vp.price - fn_calculate_promotional_price(vp.vendor_product_id, CURDATE()),
        2
    ) AS savings_per_unit
FROM Promotions pr
JOIN Vendor_Products vp ON vp.vendor_product_id = pr.vendor_product_id
JOIN Products p ON p.product_id = vp.product_id
JOIN Vendors v ON v.vendor_id = vp.vendor_id
WHERE CURDATE() BETWEEN pr.start_date AND pr.end_date;