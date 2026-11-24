/*
    File: database/04_programmability/views/vw_low_stock_inventory.sql
    Table(s): Inventory, Vendor_Products, Vendors, Products, Categories
    Description: Identifies vendor listings whose current stock is at or below
                 their low_stock_threshold (including out-of-stock items).
    Prerequisite(s): 01_schema/.../04_vendors.sql through 10_inventory.sql
*/

USE pckal_db;

CREATE OR REPLACE VIEW vw_low_stock_inventory AS
SELECT
    inv.vendor_product_id,
    v.vendor_id,
    v.store_name AS vendor_name,
    v.account_status AS vendor_status,
    p.product_id,
    p.product_name,
    p.brand,
    c.category_name,
    vp.seller_sku,
    vp.listing_status,
    inv.quantity_on_hand,
    inv.low_stock_threshold,
    (inv.low_stock_threshold - inv.quantity_on_hand) AS units_below_threshold,
    CASE
        WHEN inv.quantity_on_hand = 0 THEN 'out_of_stock'
        ELSE 'low_stock'
    END AS stock_alert_status,
    inv.updated_at
FROM Inventory inv
JOIN Vendor_Products vp ON vp.vendor_product_id = inv.vendor_product_id
JOIN Vendors v ON v.vendor_id = vp.vendor_id
JOIN Products p ON p.product_id = vp.product_id
JOIN Categories c ON c.category_id = p.category_id
WHERE inv.quantity_on_hand <= inv.low_stock_threshold;