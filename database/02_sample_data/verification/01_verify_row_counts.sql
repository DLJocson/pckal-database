/*
    PCKAL sample-data row-count verification
    Run after all seven numbered parts or the master seed script.
    Expected counts assume the population started from empty tables.
*/
USE pckal_db;

SELECT table_name, expected_rows, actual_rows,
       CASE WHEN expected_rows = actual_rows THEN 'PASS' ELSE 'CHECK' END AS validation
FROM (
    SELECT 'Roles' AS table_name, 3 AS expected_rows, (SELECT COUNT(*) FROM Roles) AS actual_rows
    UNION ALL SELECT 'Categories', 10, (SELECT COUNT(*) FROM Categories)
    UNION ALL SELECT 'Users', 19, (SELECT COUNT(*) FROM Users)
    UNION ALL SELECT 'User_Roles', 20, (SELECT COUNT(*) FROM User_Roles)
    UNION ALL SELECT 'Vendors', 10, (SELECT COUNT(*) FROM Vendors)
    UNION ALL SELECT 'Products', 26, (SELECT COUNT(*) FROM Products)
    UNION ALL SELECT 'CPU_Specifications', 10, (SELECT COUNT(*) FROM CPU_Specifications)
    UNION ALL SELECT 'GPU_Specifications', 10, (SELECT COUNT(*) FROM GPU_Specifications)
    UNION ALL SELECT 'Vendor_Products', 36, (SELECT COUNT(*) FROM Vendor_Products)
    UNION ALL SELECT 'Inventory', 36, (SELECT COUNT(*) FROM Inventory)
    UNION ALL SELECT 'Inventory_Transactions', 65, (SELECT COUNT(*) FROM Inventory_Transactions)
    UNION ALL SELECT 'Promotions', 10, (SELECT COUNT(*) FROM Promotions)
    UNION ALL SELECT 'Shopping_Carts', 10, (SELECT COUNT(*) FROM Shopping_Carts)
    UNION ALL SELECT 'Cart_Items', 19, (SELECT COUNT(*) FROM Cart_Items)
    UNION ALL SELECT 'Orders', 13, (SELECT COUNT(*) FROM Orders)
    UNION ALL SELECT 'Vendor_Orders', 17, (SELECT COUNT(*) FROM Vendor_Orders)
    UNION ALL SELECT 'Order_Items', 25, (SELECT COUNT(*) FROM Order_Items)
    UNION ALL SELECT 'Payments', 13, (SELECT COUNT(*) FROM Payments)
    UNION ALL SELECT 'Shipments', 16, (SELECT COUNT(*) FROM Shipments)
    UNION ALL SELECT 'Reviews', 14, (SELECT COUNT(*) FROM Reviews)
) AS row_count_check
ORDER BY table_name;

SELECT SUM(actual_rows) AS total_seeded_rows,
       CASE WHEN SUM(actual_rows) = 382 THEN 'PASS' ELSE 'CHECK' END AS total_validation
FROM (
    SELECT COUNT(*) AS actual_rows FROM Roles
    UNION ALL SELECT COUNT(*) FROM Categories
    UNION ALL SELECT COUNT(*) FROM Users
    UNION ALL SELECT COUNT(*) FROM User_Roles
    UNION ALL SELECT COUNT(*) FROM Vendors
    UNION ALL SELECT COUNT(*) FROM Products
    UNION ALL SELECT COUNT(*) FROM CPU_Specifications
    UNION ALL SELECT COUNT(*) FROM GPU_Specifications
    UNION ALL SELECT COUNT(*) FROM Vendor_Products
    UNION ALL SELECT COUNT(*) FROM Inventory
    UNION ALL SELECT COUNT(*) FROM Inventory_Transactions
    UNION ALL SELECT COUNT(*) FROM Promotions
    UNION ALL SELECT COUNT(*) FROM Shopping_Carts
    UNION ALL SELECT COUNT(*) FROM Cart_Items
    UNION ALL SELECT COUNT(*) FROM Orders
    UNION ALL SELECT COUNT(*) FROM Vendor_Orders
    UNION ALL SELECT COUNT(*) FROM Order_Items
    UNION ALL SELECT COUNT(*) FROM Payments
    UNION ALL SELECT COUNT(*) FROM Shipments
    UNION ALL SELECT COUNT(*) FROM Reviews
) AS total_count_check;
