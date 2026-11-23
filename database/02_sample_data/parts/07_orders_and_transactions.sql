/*
    File: database/02_sample_data/parts/07_orders_and_transactions.sql
    Tables: Orders, Vendor_Orders, Order_Items, Payments, Shipments,
            Reviews, Inventory_Transactions
    Description: Demo orders with payments, shipments, reviews, and the
                 stock movements they cause. Order totals are not stored;
                 they are computed from Order_Items.
    Prerequisite: 01_roles.sql through 06_promotions_and_carts.sql loaded.
*/

USE pckal_db;

INSERT INTO Orders (order_id, user_id, shipping_address, order_date, completion_date, order_status) VALUES
  (1,  5,  'Unit 5B, 21 Maginhawa St, Quezon City', '2026-08-05 10:15:00', '2026-08-09 16:00:00', 'completed'),
  (2,  6,  '88 Osmena Blvd, Cebu City',             '2026-08-18 14:30:00', '2026-08-24 14:00:00', 'completed'),
  (3,  7,  '17 Lanang Rd, Davao City',              '2026-09-10 09:20:00', '2026-09-16 12:00:00', 'completed'),
  (4,  8,  '3F Ortigas Ave, Pasig City',            '2026-09-20 19:45:00', '2026-09-27 11:00:00', 'completed'),
  (5,  9,  '5 Session Rd, Baguio City',             '2026-10-03 13:10:00', '2026-10-10 15:00:00', 'completed'),
  (6,  5,  'Unit 5B, 21 Maginhawa St, Quezon City', '2026-10-12 20:00:00', '2026-10-20 13:00:00', 'completed'),
  (7,  10, '29 Iznart St, Iloilo City',             '2026-10-18 11:30:00', '2026-10-25 17:00:00', 'completed'),
  (8,  6,  '88 Osmena Blvd, Cebu City',             '2026-11-02 15:25:00', '2026-11-08 11:00:00', 'completed'),
  (9,  7,  '17 Lanang Rd, Davao City',              '2026-11-12 18:10:00', NULL,                  'processing'),
  (10, 8,  '3F Ortigas Ave, Pasig City',            '2026-11-19 09:00:00', NULL,                  'pending'),
  (11, 9,  '5 Session Rd, Baguio City',             '2026-11-20 12:30:00', NULL,                  'processing'),
  (12, 10, '29 Iznart St, Iloilo City',             '2026-10-28 10:00:00', NULL,                  'cancelled'),
  (13, 5,  'Unit 5B, 21 Maginhawa St, Quezon City', '2026-11-05 16:40:00', '2026-11-13 15:00:00', 'completed');

-- One suborder per vendor per order: UNIQUE (order_id, vendor_id)
INSERT INTO Vendor_Orders (vendor_order_id, order_id, vendor_id, vendor_order_status) VALUES
  (1,  1,  1, 'completed'),
  (2,  1,  2, 'completed'),
  (3,  2,  3, 'completed'),
  (4,  3,  2, 'completed'),
  (5,  4,  1, 'completed'),
  (6,  5,  1, 'completed'),
  (7,  5,  3, 'completed'),
  (8,  6,  2, 'completed'),
  (9,  7,  3, 'completed'),
  (10, 8,  2, 'completed'),
  (11, 9,  1, 'shipped'),
  (12, 9,  3, 'processing'),
  (13, 10, 2, 'pending'),
  (14, 10, 3, 'pending'),
  (15, 11, 2, 'processing'),
  (16, 12, 1, 'cancelled'),
  (17, 13, 3, 'completed');

-- Each item sits in the suborder of the vendor that owns the listing.
-- Original listings 1-7 = vendor 1, 8-15 = vendor 2, 16-23 = vendor 3;
-- added listings 24-36 belong to vendors 4-10 and are not used by these
-- existing order-history examples.
-- unit_price_before_discount = listing price at checkout;
-- discount_applied_per_unit  = promotion discount valid on the order date.
INSERT INTO Order_Items (order_item_id, vendor_order_id, vendor_product_id, quantity, unit_price_before_discount, discount_applied_per_unit) VALUES
  (1,  1,  1,  1, 13500.00, 0.00),
  (2,  2,  15, 2, 1250.00,  0.00),
  (3,  3,  20, 1, 11500.00, 0.00),
  (4,  3,  22, 1, 5800.00,  0.00),
  (5,  4,  12, 1, 18500.00, 1850.00),   -- 10% promo (promotion 1)
  (6,  4,  11, 1, 6300.00,  0.00),
  (7,  5,  5,  1, 39500.00, 2000.00),   -- fixed promo (promotion 2)
  (8,  5,  2,  1, 24900.00, 0.00),
  (9,  6,  1,  1, 13500.00, 1350.00),   -- 10% promo (promotion 4)
  (10, 7,  17, 1, 23200.00, 0.00),
  (11, 7,  22, 1, 5800.00,  0.00),
  (12, 8,  13, 1, 32900.00, 0.00),
  (13, 8,  15, 1, 1250.00,  0.00),
  (14, 9,  18, 1, 38900.00, 0.00),
  (15, 9,  21, 2, 17900.00, 0.00),
  (16, 10, 12, 1, 18500.00, 1480.00),   -- 8% promo (promotion 6)
  (17, 10, 8,  1, 13200.00, 0.00),
  (18, 11, 3,  1, 16800.00, 0.00),
  (19, 12, 16, 1, 24500.00, 0.00),      -- promotion 3 had not started yet
  (20, 13, 9,  1, 16500.00, 1000.00),   -- fixed promo (promotion 8)
  (21, 14, 16, 1, 24500.00, 1225.00),   -- 5% promo (promotion 3)
  (22, 15, 13, 1, 32900.00, 1500.00),   -- fixed promo (promotion 9)
  (23, 16, 4,  1, 18900.00, 0.00),
  (24, 17, 19, 1, 32500.00, 0.00),
  (25, 17, 22, 1, 5800.00,  0.00);

-- One simulated payment per order (Payments.order_id is UNIQUE).
-- amount_paid = order net total. Failed payment records 0.00.
INSERT INTO Payments (payment_id, order_id, payment_method, transaction_reference, amount_paid, payment_status, paid_at) VALUES
  (1,  1,  'simulated_card',   'SIM-CARD-2026-0001', 16000.00, 'succeeded', '2026-08-05 10:16:00'),
  (2,  2,  'cash_on_delivery', NULL,                 17300.00, 'succeeded', '2026-08-24 13:05:00'),
  (3,  3,  'simulated_ewallet','SIM-EWAL-2026-0003', 22950.00, 'succeeded', '2026-09-10 09:21:00'),
  (4,  4,  'simulated_card',   'SIM-CARD-2026-0004', 62400.00, 'succeeded', '2026-09-20 19:46:00'),
  (5,  5,  'simulated_ewallet','SIM-EWAL-2026-0005', 41150.00, 'succeeded', '2026-10-03 13:11:00'),
  (6,  6,  'simulated_card',   'SIM-CARD-2026-0006', 34150.00, 'succeeded', '2026-10-12 20:01:00'),
  (7,  7,  'simulated_card',   'SIM-CARD-2026-0007', 74700.00, 'succeeded', '2026-10-18 11:31:00'),
  (8,  8,  'simulated_ewallet','SIM-EWAL-2026-0008', 30220.00, 'succeeded', '2026-11-02 15:26:00'),
  (9,  9,  'simulated_ewallet','SIM-EWAL-2026-0009', 41300.00, 'succeeded', '2026-11-12 18:11:00'),
  (10, 10, 'cash_on_delivery', NULL,                 38775.00, 'pending',   NULL),
  (11, 11, 'simulated_card',   'SIM-CARD-2026-0011', 31400.00, 'succeeded', '2026-11-20 12:31:00'),
  (12, 12, 'simulated_ewallet','SIM-EWAL-2026-0012', 0.00,     'failed',    NULL),
  (13, 13, 'simulated_card',   'SIM-CARD-2026-0013', 38300.00, 'succeeded', '2026-11-05 16:41:00');

-- Shipments (a suborder may have several; vendor order 5 has two).
-- Statuses shown: pending, packed, shipped, delivered.
INSERT INTO Shipments (shipment_id, vendor_order_id, carrier_name, tracking_number, shipment_status, shipped_at, delivered_at) VALUES
  (1,  1,  'LBC Express',   'LBC-1000001', 'delivered', '2026-08-06 09:00:00', '2026-08-09 15:30:00'),
  (2,  2,  'J&T Express',   'JT-2000001',  'delivered', '2026-08-06 10:00:00', '2026-08-08 14:00:00'),
  (3,  3,  'Flash Express', 'FE-3000001',  'delivered', '2026-08-19 10:00:00', '2026-08-24 13:00:00'),
  (4,  4,  'LBC Express',   'LBC-1000002', 'delivered', '2026-09-11 09:30:00', '2026-09-16 11:00:00'),
  (5,  5,  'J&T Express',   'JT-2000002',  'delivered', '2026-09-21 10:00:00', '2026-09-25 10:00:00'),
  (6,  5,  'LBC Express',   'LBC-1000003', 'delivered', '2026-09-22 10:00:00', '2026-09-27 10:30:00'),
  (7,  6,  'LBC Express',   'LBC-1000004', 'delivered', '2026-10-04 09:00:00', '2026-10-08 15:00:00'),
  (8,  7,  'Flash Express', 'FE-3000002',  'delivered', '2026-10-04 11:00:00', '2026-10-10 14:00:00'),
  (9,  8,  'J&T Express',   'JT-2000003',  'delivered', '2026-10-13 09:30:00', '2026-10-20 12:00:00'),
  (10, 9,  'LBC Express',   'LBC-1000005', 'delivered', '2026-10-19 10:00:00', '2026-10-25 16:00:00'),
  (11, 10, 'Flash Express', 'FE-3000003',  'delivered', '2026-11-03 09:00:00', '2026-11-08 10:00:00'),
  (12, 11, 'LBC Express',   'LBC-1000006', 'shipped',   '2026-11-13 09:00:00', NULL),
  (13, 12, NULL,            NULL,          'packed',    NULL,                  NULL),
  (14, 13, NULL,            NULL,          'pending',   NULL,                  NULL),
  (15, 15, NULL,            NULL,          'packed',    NULL,                  NULL),
  (16, 17, 'J&T Express',   'JT-2000004',  'delivered', '2026-11-06 09:00:00', '2026-11-13 14:00:00');

-- Reviews: at most one per order item (UNIQUE). seller_rating may be NULL.
-- Only items from completed orders are reviewed; some items have no review.
INSERT INTO Reviews (review_id, order_item_id, product_rating, seller_rating, review_text, reviewed_at) VALUES
  (1,  1,  5, 5,    'Runs cool and fast. Seller shipped within a day.',        '2026-08-10 09:00:00'),
  (2,  3,  4, 5,    'Good value GPU for the price.',                           '2026-08-25 10:00:00'),
  (3,  4,  5, NULL, 'Typing feel is great.',                                   '2026-08-25 10:05:00'),
  (4,  5,  5, 4,    'Ran all my games at 1080p with no issues.',               '2026-09-17 18:00:00'),
  (5,  7,  5, 5,    'Excellent card and very quiet.',                          '2026-09-28 20:00:00'),
  (6,  8,  5, 5,    'Best gaming CPU I have used.',                            '2026-09-28 20:05:00'),
  (7,  10, 4, 4,    'Strong performance, but it runs a bit hot.',              '2026-10-11 12:00:00'),
  (8,  11, 3, 4,    'The key sound is louder than I expected.',                '2026-10-11 12:05:00'),
  (9,  12, 5, 4,    'Great 1440p performance.',                                '2026-10-21 19:00:00'),
  (10, 14, 5, 5,    'Fast delivery and well packed.',                          '2026-10-26 09:00:00'),
  (11, 15, 4, 4,    'Sharp picture, but the stand is a bit wobbly.',           '2026-10-26 09:10:00'),
  (12, 16, 4, 5,    'Good card for the price.',                                '2026-11-09 13:00:00'),
  (13, 17, 5, 5,    'Very good value CPU.',                                    '2026-11-09 13:05:00'),
  (14, 24, 5, 5,    'Runs everything at high settings.',                       '2026-11-14 18:00:00');

-- Stock movements caused by the orders above, in date order so stock never
-- goes negative at any point. Sign rules (CHECK): sale_deduction < 0,
-- restock/return > 0, adjustment <> 0.
INSERT INTO Inventory_Transactions (vendor_product_id, transaction_type, quantity_change, reason, transaction_date) VALUES
  (1,  'sale_deduction', -1, 'Order 1',  '2026-08-05 10:15:00'),
  (15, 'sale_deduction', -2, 'Order 1',  '2026-08-05 10:15:00'),
  (20, 'sale_deduction', -1, 'Order 2',  '2026-08-18 14:30:00'),
  (22, 'sale_deduction', -1, 'Order 2',  '2026-08-18 14:30:00'),
  (12, 'sale_deduction', -1, 'Order 3',  '2026-09-10 09:20:00'),
  (11, 'sale_deduction', -1, 'Order 3',  '2026-09-10 09:20:00'),
  (5,  'sale_deduction', -1, 'Order 4',  '2026-09-20 19:45:00'),
  (2,  'sale_deduction', -1, 'Order 4',  '2026-09-20 19:45:00'),
  (11, 'adjustment',     -2, 'Damaged units found during stock count', '2026-09-30 17:00:00'),
  (1,  'sale_deduction', -1, 'Order 5',  '2026-10-03 13:10:00'),
  (17, 'sale_deduction', -1, 'Order 5',  '2026-10-03 13:10:00'),
  (22, 'sale_deduction', -1, 'Order 5',  '2026-10-03 13:10:00'),
  (13, 'sale_deduction', -1, 'Order 6',  '2026-10-12 20:00:00'),
  (15, 'sale_deduction', -1, 'Order 6',  '2026-10-12 20:00:00'),
  (18, 'sale_deduction', -1, 'Order 7',  '2026-10-18 11:30:00'),
  (21, 'sale_deduction', -2, 'Order 7',  '2026-10-18 11:30:00'),
  (4,  'sale_deduction', -1, 'Order 12', '2026-10-28 10:00:00'),
  (4,  'return',          1, 'Order 12 cancelled after failed payment', '2026-10-29 09:00:00'),
  (23, 'adjustment',     -2, 'Units returned to supplier after discontinuation', '2026-10-30 09:00:00'),
  (12, 'sale_deduction', -1, 'Order 8',  '2026-11-02 15:25:00'),
  (8,  'sale_deduction', -1, 'Order 8',  '2026-11-02 15:25:00'),
  (19, 'sale_deduction', -1, 'Order 13', '2026-11-05 16:40:00'),
  (22, 'sale_deduction', -1, 'Order 13', '2026-11-05 16:40:00'),
  (22, 'restock',         5, 'Supplier restock', '2026-11-10 08:00:00'),
  (3,  'sale_deduction', -1, 'Order 9',  '2026-11-12 18:10:00'),
  (16, 'sale_deduction', -1, 'Order 9',  '2026-11-12 18:10:00'),
  (9,  'sale_deduction', -1, 'Order 10', '2026-11-19 09:00:00'),
  (16, 'sale_deduction', -1, 'Order 10', '2026-11-19 09:00:00'),
  (13, 'sale_deduction', -1, 'Order 11', '2026-11-20 12:30:00');

-- Make Inventory match the full transaction history (safe with or without the trigger).
UPDATE Inventory i
SET i.quantity_on_hand = COALESCE(
      (SELECT SUM(t.quantity_change)
       FROM Inventory_Transactions t
       WHERE t.vendor_product_id = i.vendor_product_id), 0)
WHERE i.vendor_product_id > 0;

-- Verification: expect 13 orders, 17 vendor orders, 25 items, 13 payments,
-- 16 shipments, 14 reviews, and 65 inventory transactions after the
-- 36 initial restocks in vendor_listings_and_inventory.sql
SELECT (SELECT COUNT(*) FROM Orders)                 AS orders_count,
       (SELECT COUNT(*) FROM Vendor_Orders)          AS vendor_orders_count,
       (SELECT COUNT(*) FROM Order_Items)            AS order_items_count,
       (SELECT COUNT(*) FROM Payments)               AS payments_count,
       (SELECT COUNT(*) FROM Shipments)              AS shipments_count,
       (SELECT COUNT(*) FROM Reviews)                AS reviews_count,
       (SELECT COUNT(*) FROM Inventory_Transactions) AS inventory_transactions_count;
