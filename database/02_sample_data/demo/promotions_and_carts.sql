/*
    File: database/02_sample_data/demo/promotions_and_carts.sql
    Tables: Promotions, Shopping_Carts, Cart_Items
    Description: Demo promotions (expired, active, upcoming) and customer carts.
                 Promotion date ranges for the same listing do not overlap.
    Prerequisite: vendor_listings_and_inventory.sql loaded.
*/

USE pckal_db;

-- Status as of 2026-11-21: expired 1, 2, 4, 7 | active 3, 6, 8, 9 | upcoming 5
INSERT INTO Promotions (promotion_id, vendor_product_id, discount_type, discount_value, start_date, end_date, created_at) VALUES
  (1, 12, 'percentage',   10.00,   '2026-09-01', '2026-09-30', '2026-08-25 09:00:00'),
  (2, 5,  'fixed_amount', 2000.00, '2026-09-15', '2026-10-15', '2026-09-10 09:00:00'),
  (3, 16, 'percentage',   5.00,    '2026-11-15', '2026-11-30', '2026-11-10 09:00:00'),
  (4, 1,  'percentage',   10.00,   '2026-10-01', '2026-10-31', '2026-09-25 09:00:00'),
  (5, 21, 'percentage',   15.00,   '2026-12-01', '2026-12-15', '2026-11-15 09:00:00'),
  (6, 12, 'percentage',   8.00,    '2026-11-01', '2026-11-30', '2026-10-25 09:00:00'),
  (7, 14, 'fixed_amount', 500.00,  '2026-10-05', '2026-10-12', '2026-10-01 09:00:00'),
  (8, 9,  'fixed_amount', 1000.00, '2026-11-18', '2026-11-25', '2026-11-15 09:00:00'),
  (9, 13, 'fixed_amount', 1500.00, '2026-11-10', '2026-12-10', '2026-11-05 09:00:00');

-- Customer carts (carts 4 and 5 became orders 10 and 11)
INSERT INTO Shopping_Carts (cart_id, user_id, cart_status, created_at) VALUES
  (1, 5,  'active',      '2026-11-18 20:00:00'),
  (2, 6,  'active',      '2026-11-19 21:10:00'),
  (3, 7,  'abandoned',   '2026-10-22 19:30:00'),
  (4, 8,  'checked_out', '2026-11-19 08:30:00'),
  (5, 9,  'checked_out', '2026-11-20 12:00:00'),
  (6, 10, 'active',      '2026-11-20 22:45:00');

-- A listing appears only once per cart
INSERT INTO Cart_Items (cart_item_id, cart_id, vendor_product_id, quantity, added_at) VALUES
  (1,  1, 9,  1, '2026-11-18 20:05:00'),
  (2,  1, 15, 1, '2026-11-18 20:07:00'),
  (3,  2, 12, 1, '2026-11-19 21:15:00'),
  (4,  2, 11, 1, '2026-11-19 21:16:00'),
  (5,  3, 18, 1, '2026-10-22 19:35:00'),
  (6,  3, 21, 1, '2026-10-22 19:36:00'),
  (7,  4, 9,  1, '2026-11-19 08:35:00'),
  (8,  4, 16, 1, '2026-11-19 08:36:00'),
  (9,  5, 13, 1, '2026-11-20 12:05:00'),
  (10, 6, 19, 1, '2026-11-20 22:50:00'),
  (11, 6, 20, 1, '2026-11-20 22:52:00');

-- Verification: expect 9, 6, 11
SELECT (SELECT COUNT(*) FROM Promotions)     AS promotions,
       (SELECT COUNT(*) FROM Shopping_Carts) AS carts,
       (SELECT COUNT(*) FROM Cart_Items)     AS cart_items;