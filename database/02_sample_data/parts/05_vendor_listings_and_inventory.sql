/*
    File: database/02_sample_data/parts/05_vendor_listings_and_inventory.sql
    Tables: Vendor_Products, Inventory, Inventory_Transactions
    Description: 36 vendor listings with one inventory row and an initial
                 restock per listing. Inventory.quantity_on_hand is recalculated
                 from all transactions at the end, so the result is correct
                 with or without the inventory trigger.
    Prerequisite: 03_users_and_vendors.sql and 04_products_and_specs.sql loaded.
*/

USE pckal_db;

-- Original listings: vendor 1 = PixelForge (1-7), vendor 2 = Byte Bazaar
-- (8-15), vendor 3 = CoreZone (16-23). Listing 7 is inactive and listing
-- 23 is discontinued. Added active listings 24-36 belong to vendors 4-10.
INSERT INTO Vendor_Products (vendor_product_id, vendor_id, product_id, seller_sku, price, listing_status, listed_at) VALUES
  (1,  1, 1,  'PF-CPU-7600X',    13500.00, 'active',       '2026-07-25 09:00:00'),
  (2,  1, 2,  'PF-CPU-7800X3D',  24900.00, 'active',       '2026-07-25 09:05:00'),
  (3,  1, 3,  'PF-CPU-13600K',   16800.00, 'active',       '2026-07-25 09:10:00'),
  (4,  1, 6,  'PF-GPU-4060',     18900.00, 'active',       '2026-07-25 09:15:00'),
  (5,  1, 7,  'PF-GPU-4070S',    39500.00, 'active',       '2026-07-25 09:20:00'),
  (6,  1, 11, 'PF-MON-27GP850',  18500.00, 'active',       '2026-07-25 09:25:00'),
  (7,  1, 12, 'PF-KBD-K2',        5900.00, 'inactive',     '2026-07-25 09:30:00'),
  (8,  2, 1,  'BB-CPU-7600X',    13200.00, 'active',       '2026-07-26 10:00:00'),
  (9,  2, 3,  'BB-CPU-13600K',   16500.00, 'active',       '2026-07-26 10:05:00'),
  (10, 2, 4,  'BB-CPU-14700K',   22900.00, 'active',       '2026-07-26 10:10:00'),
  (11, 2, 5,  'BB-CPU-5600',      6300.00, 'active',       '2026-07-26 10:15:00'),
  (12, 2, 6,  'BB-GPU-4060',     18500.00, 'active',       '2026-07-26 10:20:00'),
  (13, 2, 8,  'BB-GPU-7800XT',   32900.00, 'active',       '2026-07-26 10:25:00'),
  (14, 2, 9,  'BB-GPU-7600',     14500.00, 'active',       '2026-07-26 10:30:00'),
  (15, 2, 13, 'BB-MSE-G102',      1250.00, 'active',       '2026-07-26 10:35:00'),
  (16, 3, 2,  'CZ-CPU-7800X3D',  24500.00, 'active',       '2026-07-27 11:00:00'),
  (17, 3, 4,  'CZ-CPU-14700K',   23200.00, 'active',       '2026-07-27 11:05:00'),
  (18, 3, 7,  'CZ-GPU-4070S',    38900.00, 'active',       '2026-07-27 11:10:00'),
  (19, 3, 8,  'CZ-GPU-7800XT',   32500.00, 'active',       '2026-07-27 11:15:00'),
  (20, 3, 10, 'CZ-GPU-A750',     11500.00, 'active',       '2026-07-27 11:20:00'),
  (21, 3, 11, 'CZ-MON-27GP850',  17900.00, 'active',       '2026-07-27 11:25:00'),
  (22, 3, 12, 'CZ-KBD-K2',        5800.00, 'active',       '2026-07-27 11:30:00'),
  (23, 3, 13, 'CZ-MSE-G102',      1200.00, 'discontinued', '2026-07-27 11:35:00'),
  (24, 4, 14, 'SH-SSD-990PRO',      7900.00, 'active', '2026-08-02 09:00:00'),
  (25, 5, 15, 'NTP-PSU-RM850E',     6500.00, 'active', '2026-08-02 09:05:00'),
  (26, 6, 16, 'CC-COOL-AK620',      3800.00, 'active', '2026-08-02 09:10:00'),
  (27, 4, 17, 'SH-CPU-7950X',      32500.00, 'active', '2026-08-02 09:15:00'),
  (28, 5, 18, 'NTP-CPU-7900X',     24500.00, 'active', '2026-08-02 09:20:00'),
  (29, 6, 19, 'CC-CPU-R7700',      17900.00, 'active', '2026-08-02 09:25:00'),
  (30, 7, 20, 'BWD-CPU-R7600',     12500.00, 'active', '2026-08-03 10:00:00'),
  (31, 8, 21, 'NGC-CPU-I514400F',  10900.00, 'active', '2026-08-03 10:05:00'),
  (32, 9, 22, 'GG-GPU-4080S',     65000.00, 'active', '2026-08-03 10:10:00'),
  (33,10, 23, 'PTS-GPU-4090',    105000.00, 'active', '2026-08-03 10:15:00'),
  (34, 4, 24, 'SH-GPU-7900XTX',   52000.00, 'active', '2026-08-03 10:20:00'),
  (35, 5, 25, 'NTP-GPU-7900XT',   42000.00, 'active', '2026-08-03 10:25:00'),
  (36, 6, 26, 'CC-GPU-ARCB580',   14500.00, 'active', '2026-08-03 10:30:00');

-- One Inventory row per listing; balance starts at 0 and is filled below
INSERT INTO Inventory (vendor_product_id, quantity_on_hand, low_stock_threshold) VALUES
  (1, 0, 5), (2, 0, 5), (3, 0, 5), (4, 0, 5), (5, 0, 5), (6, 0, 3),
  (7, 0, 5), (8, 0, 5), (9, 0, 5), (10, 0, 5), (11, 0, 5), (12, 0, 5),
  (13, 0, 5), (14, 0, 5), (15, 0, 10), (16, 0, 5), (17, 0, 5), (18, 0, 5),
  (19, 0, 5), (20, 0, 5), (21, 0, 3), (22, 0, 5), (23, 0, 5), (24, 0, 5),
  (25, 0, 5), (26, 0, 5), (27, 0, 3), (28, 0, 4), (29, 0, 5), (30, 0, 5),
  (31, 0, 5), (32, 0, 2), (33, 0, 2), (34, 0, 3), (35, 0, 4), (36, 0, 5);

-- Initial restock for every listing (before the first demo order on 2026-08-05)
INSERT INTO Inventory_Transactions (vendor_product_id, transaction_type, quantity_change, reason, transaction_date) VALUES
  (1,  'restock', 10, 'Initial stock',  '2026-08-01 08:00:00'),
  (2,  'restock', 6,  'Initial stock',  '2026-08-01 08:01:00'),
  (3,  'restock', 8,  'Initial stock',  '2026-08-01 08:02:00'),
  (4,  'restock', 6,  'Initial stock',  '2026-08-01 08:03:00'),
  (5,  'restock', 4,  'Initial stock',  '2026-08-01 08:04:00'),
  (6,  'restock', 10, 'Initial stock',  '2026-08-01 08:05:00'),
  (7,  'restock', 12, 'Initial stock',  '2026-08-01 08:06:00'),
  (8,  'restock', 15, 'Initial stock',  '2026-08-01 09:00:00'),
  (9,  'restock', 8,  'Initial stock',  '2026-08-01 09:01:00'),
  (10, 'restock', 6,  'Initial stock',  '2026-08-01 09:02:00'),
  (11, 'restock', 20, 'Initial stock',  '2026-08-01 09:03:00'),
  (12, 'restock', 4,  'Initial stock',  '2026-08-01 09:04:00'),
  (13, 'restock', 5,  'Initial stock',  '2026-08-01 09:05:00'),
  (14, 'restock', 8,  'Initial stock',  '2026-08-01 09:06:00'),
  (15, 'restock', 30, 'Initial stock',  '2026-08-01 09:07:00'),
  (16, 'restock', 4,  'Initial stock',  '2026-08-01 10:00:00'),
  (17, 'restock', 4,  'Initial stock',  '2026-08-01 10:01:00'),
  (18, 'restock', 1,  'Initial stock',  '2026-08-01 10:02:00'),
  (19, 'restock', 6,  'Initial stock',  '2026-08-01 10:03:00'),
  (20, 'restock', 5,  'Initial stock',  '2026-08-01 10:04:00'),
  (21, 'restock', 6,  'Initial stock',  '2026-08-01 10:05:00'),
  (22, 'restock', 8,  'Initial stock',  '2026-08-01 10:06:00'),
  (23, 'restock', 2,  'Initial stock',  '2026-08-01 10:07:00'),
  (24, 'restock', 10, 'Initial stock', '2026-08-04 08:00:00'),
  (25, 'restock', 6 , 'Initial stock', '2026-08-04 08:01:00'),
  (26, 'restock', 8 , 'Initial stock', '2026-08-04 08:02:00'),
  (27, 'restock', 3 , 'Initial stock', '2026-08-04 08:03:00'),
  (28, 'restock', 4 , 'Initial stock', '2026-08-04 08:04:00'),
  (29, 'restock', 6 , 'Initial stock', '2026-08-04 08:05:00'),
  (30, 'restock', 12, 'Initial stock', '2026-08-04 08:06:00'),
  (31, 'restock', 10, 'Initial stock', '2026-08-04 08:07:00'),
  (32, 'restock', 2 , 'Initial stock', '2026-08-04 08:08:00'),
  (33, 'restock', 2 , 'Initial stock', '2026-08-04 08:09:00'),
  (34, 'restock', 3 , 'Initial stock', '2026-08-04 08:10:00'),
  (35, 'restock', 4 , 'Initial stock', '2026-08-04 08:11:00'),
  (36, 'restock', 8 , 'Initial stock', '2026-08-04 08:12:00');

-- Make Inventory match the transaction history
UPDATE Inventory i
SET i.quantity_on_hand = COALESCE(
      (SELECT SUM(t.quantity_change)
       FROM Inventory_Transactions t
       WHERE t.vendor_product_id = i.vendor_product_id), 0)
WHERE i.vendor_product_id > 0;

-- Verification at this stage: expect 36 listings, 36 inventory rows,
-- and 36 initial-restock transactions. orders_and_transactions.sql adds 29
-- subsequent stock movements, bringing the final transaction total to 65.
SELECT (SELECT COUNT(*) FROM Vendor_Products)        AS listings,
       (SELECT COUNT(*) FROM Inventory)              AS inventory_rows,
       (SELECT COUNT(*) FROM Inventory_Transactions) AS transactions;
