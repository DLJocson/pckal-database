/*
    PCKAL sample-data preflight
    Run this before the seed script. It should return zero rows for missing tables.
*/
SELECT required.table_name AS required_table,
       CASE WHEN t.table_name IS NULL THEN 'MISSING' ELSE 'OK' END AS status
FROM (
    SELECT 'Users' AS table_name
    UNION ALL SELECT 'Roles'
    UNION ALL SELECT 'User_Roles'
    UNION ALL SELECT 'Vendors'
    UNION ALL SELECT 'Categories'
    UNION ALL SELECT 'Products'
    UNION ALL SELECT 'CPU_Specifications'
    UNION ALL SELECT 'GPU_Specifications'
    UNION ALL SELECT 'Vendor_Products'
    UNION ALL SELECT 'Inventory'
    UNION ALL SELECT 'Inventory_Transactions'
    UNION ALL SELECT 'Promotions'
    UNION ALL SELECT 'Shopping_Carts'
    UNION ALL SELECT 'Cart_Items'
    UNION ALL SELECT 'Orders'
    UNION ALL SELECT 'Vendor_Orders'
    UNION ALL SELECT 'Order_Items'
    UNION ALL SELECT 'Payments'
    UNION ALL SELECT 'Shipments'
    UNION ALL SELECT 'Reviews'
) AS required
LEFT JOIN information_schema.tables AS t
  ON t.table_schema = 'pckal_db'
 AND t.table_name = required.table_name
 AND t.table_type = 'BASE TABLE'
ORDER BY required.table_name;

SELECT required.trigger_name AS required_trigger,
       CASE WHEN t.trigger_name IS NULL THEN 'MISSING' ELSE 'OK' END AS status
FROM (
    SELECT 'trg_inventory_transaction_after_insert' AS trigger_name
    UNION ALL SELECT 'trg_promotion_before_insert'
    UNION ALL SELECT 'trg_promotion_before_update'
) AS required
LEFT JOIN information_schema.triggers AS t
  ON t.trigger_schema = 'pckal_db'
 AND t.trigger_name = required.trigger_name
ORDER BY required.trigger_name;
