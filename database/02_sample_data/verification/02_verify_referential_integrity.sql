/*
    PCKAL sample-data foreign-key orphan diagnostics
    All orphan_rows values should be zero. This is a diagnostic query, not a replacement for FK constraints.
*/
USE pckal_db;

SELECT 'User_Roles -> Users' AS check_name, COUNT(*) AS orphan_rows
FROM User_Roles c LEFT JOIN Users p ON p.user_id = c.user_id WHERE p.user_id IS NULL
UNION ALL SELECT 'User_Roles -> Roles', COUNT(*)
FROM User_Roles c LEFT JOIN Roles p ON p.role_id = c.role_id WHERE p.role_id IS NULL
UNION ALL SELECT 'Vendors -> Users', COUNT(*)
FROM Vendors c LEFT JOIN Users p ON p.user_id = c.user_id WHERE p.user_id IS NULL
UNION ALL SELECT 'Categories -> parent Categories', COUNT(*)
FROM Categories c LEFT JOIN Categories p ON p.category_id = c.parent_category_id
WHERE c.parent_category_id IS NOT NULL AND p.category_id IS NULL
UNION ALL SELECT 'Products -> Categories', COUNT(*)
FROM Products c LEFT JOIN Categories p ON p.category_id = c.category_id WHERE p.category_id IS NULL
UNION ALL SELECT 'CPU_Specifications -> Products', COUNT(*)
FROM CPU_Specifications c LEFT JOIN Products p ON p.product_id = c.product_id WHERE p.product_id IS NULL
UNION ALL SELECT 'GPU_Specifications -> Products', COUNT(*)
FROM GPU_Specifications c LEFT JOIN Products p ON p.product_id = c.product_id WHERE p.product_id IS NULL
UNION ALL SELECT 'Vendor_Products -> Vendors', COUNT(*)
FROM Vendor_Products c LEFT JOIN Vendors p ON p.vendor_id = c.vendor_id WHERE p.vendor_id IS NULL
UNION ALL SELECT 'Vendor_Products -> Products', COUNT(*)
FROM Vendor_Products c LEFT JOIN Products p ON p.product_id = c.product_id WHERE p.product_id IS NULL
UNION ALL SELECT 'Inventory -> Vendor_Products', COUNT(*)
FROM Inventory c LEFT JOIN Vendor_Products p ON p.vendor_product_id = c.vendor_product_id WHERE p.vendor_product_id IS NULL
UNION ALL SELECT 'Inventory_Transactions -> Vendor_Products', COUNT(*)
FROM Inventory_Transactions c LEFT JOIN Vendor_Products p ON p.vendor_product_id = c.vendor_product_id WHERE p.vendor_product_id IS NULL
UNION ALL SELECT 'Promotions -> Vendor_Products', COUNT(*)
FROM Promotions c LEFT JOIN Vendor_Products p ON p.vendor_product_id = c.vendor_product_id WHERE p.vendor_product_id IS NULL
UNION ALL SELECT 'Shopping_Carts -> Users', COUNT(*)
FROM Shopping_Carts c LEFT JOIN Users p ON p.user_id = c.user_id WHERE p.user_id IS NULL
UNION ALL SELECT 'Cart_Items -> Shopping_Carts', COUNT(*)
FROM Cart_Items c LEFT JOIN Shopping_Carts p ON p.cart_id = c.cart_id WHERE p.cart_id IS NULL
UNION ALL SELECT 'Cart_Items -> Vendor_Products', COUNT(*)
FROM Cart_Items c LEFT JOIN Vendor_Products p ON p.vendor_product_id = c.vendor_product_id WHERE p.vendor_product_id IS NULL
UNION ALL SELECT 'Orders -> Users', COUNT(*)
FROM Orders c LEFT JOIN Users p ON p.user_id = c.user_id WHERE p.user_id IS NULL
UNION ALL SELECT 'Vendor_Orders -> Orders', COUNT(*)
FROM Vendor_Orders c LEFT JOIN Orders p ON p.order_id = c.order_id WHERE p.order_id IS NULL
UNION ALL SELECT 'Vendor_Orders -> Vendors', COUNT(*)
FROM Vendor_Orders c LEFT JOIN Vendors p ON p.vendor_id = c.vendor_id WHERE p.vendor_id IS NULL
UNION ALL SELECT 'Order_Items -> Vendor_Orders', COUNT(*)
FROM Order_Items c LEFT JOIN Vendor_Orders p ON p.vendor_order_id = c.vendor_order_id WHERE p.vendor_order_id IS NULL
UNION ALL SELECT 'Order_Items -> Vendor_Products', COUNT(*)
FROM Order_Items c LEFT JOIN Vendor_Products p ON p.vendor_product_id = c.vendor_product_id WHERE p.vendor_product_id IS NULL
UNION ALL SELECT 'Payments -> Orders', COUNT(*)
FROM Payments c LEFT JOIN Orders p ON p.order_id = c.order_id WHERE p.order_id IS NULL
UNION ALL SELECT 'Shipments -> Vendor_Orders', COUNT(*)
FROM Shipments c LEFT JOIN Vendor_Orders p ON p.vendor_order_id = c.vendor_order_id WHERE p.vendor_order_id IS NULL
UNION ALL SELECT 'Reviews -> Order_Items', COUNT(*)
FROM Reviews c LEFT JOIN Order_Items p ON p.order_item_id = c.order_item_id WHERE p.order_item_id IS NULL
ORDER BY check_name;
