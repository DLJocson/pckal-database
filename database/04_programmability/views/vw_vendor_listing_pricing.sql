/*
    File: database/04_programmability/views/vw_vendor_listing_pricing.sql
    Table(s): Vendor_Products, Products, Vendors, Inventory, Promotions
    Description: Shows each vendor listing's regular price, active promotion
                 details (as of CURDATE()), unit discount amount, and
                 effective promotional selling price.
    Prerequisite(s): 01_schema/.../04_vendors.sql through 12_promotions.sql,
                     fn_calculate_promotional_price
*/

USE pckal_db;

CREATE OR REPLACE VIEW vw_vendor_listing_pricing AS
SELECT
    vp.vendor_product_id,
    vp.vendor_id,
    v.store_name AS vendor_name,
    v.account_status AS vendor_status,
    vp.product_id,
    p.product_name,
    p.brand,
    vp.seller_sku,
    vp.listing_status,
    COALESCE(inv.quantity_on_hand, 0) AS quantity_on_hand,
    vp.price AS regular_price,
    promo.promotion_id,
    promo.discount_type,
    promo.discount_value,
    promo.start_date AS promo_start_date,
    promo.end_date AS promo_end_date,
    ROUND(
        vp.price - COALESCE(
            fn_calculate_promotional_price(vp.vendor_product_id, CURDATE()),
            vp.price
        ),
        2
    ) AS discount_per_unit,
    COALESCE(
        fn_calculate_promotional_price(vp.vendor_product_id, CURDATE()),
        vp.price
    ) AS effective_price
FROM Vendor_Products vp
JOIN Products p ON p.product_id = vp.product_id
JOIN Vendors v ON v.vendor_id = vp.vendor_id
LEFT JOIN Inventory inv ON inv.vendor_product_id = vp.vendor_product_id
LEFT JOIN Promotions promo
       ON promo.vendor_product_id = vp.vendor_product_id
      AND CURDATE() BETWEEN promo.start_date AND promo.end_date;