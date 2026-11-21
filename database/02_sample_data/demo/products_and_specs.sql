/*
    File: database/02_sample_data/demo/products_and_specs.sql
    Tables: Products, CPU_Specifications, GPU_Specifications
    Description: Demo products (5 CPUs, 5 GPUs, 3 peripherals) with specs.
                 Specs are only for CPU and GPU products.
    Prerequisite: reference/categories.sql loaded.
*/

USE pckal_db;

-- Category IDs: 2 CPUs, 3 GPUs, 5 Monitors, 6 Keyboards, 7 Mice
INSERT INTO Products (product_id, category_id, product_name, brand, model_number, description, created_at) VALUES
  (1,  2, 'AMD Ryzen 5 7600X Processor',            'AMD',    '7600X',     '6-core, 12-thread AM5 desktop processor.',                  '2026-07-20 09:00:00'),
  (2,  2, 'AMD Ryzen 7 7800X3D Processor',          'AMD',    '7800X3D',   '8-core AM5 processor with 3D V-Cache for gaming.',          '2026-07-20 09:05:00'),
  (3,  2, 'Intel Core i5-13600K Processor',         'Intel',  'i5-13600K', '14-core (6P+8E) LGA1700 unlocked processor.',               '2026-07-20 09:10:00'),
  (4,  2, 'Intel Core i7-14700K Processor',         'Intel',  'i7-14700K', '20-core (8P+12E) LGA1700 unlocked processor.',              '2026-07-20 09:15:00'),
  (5,  2, 'AMD Ryzen 5 5600 Processor',             'AMD',    '5600',      '6-core, 12-thread AM4 processor for budget builds.',        '2026-07-20 09:20:00'),
  (6,  3, 'MSI GeForce RTX 4060 Ventus 2X 8GB',     'MSI',    NULL,        'Compact dual-fan 8GB graphics card for 1080p gaming.',      '2026-07-21 10:00:00'),
  (7,  3, 'ASUS Dual GeForce RTX 4070 Super 12GB',  'ASUS',   NULL,        '12GB GDDR6X graphics card for 1440p gaming.',               '2026-07-21 10:05:00'),
  (8,  3, 'Sapphire Pulse Radeon RX 7800 XT 16GB',  'Sapphire', NULL,      '16GB GDDR6 graphics card for high-refresh 1440p gaming.',   '2026-07-21 10:10:00'),
  (9,  3, 'XFX Speedster SWFT 210 Radeon RX 7600 8GB','XFX',  NULL,        'Entry-level 8GB graphics card for 1080p gaming.',           '2026-07-21 10:15:00'),
  (10, 3, 'ASRock Challenger Arc A750 8GB',         'ASRock', NULL,        '8GB graphics card with PCIe 4.0 interface.',                '2026-07-21 10:20:00'),
  (11, 5, 'LG UltraGear 27-inch QHD 165Hz Monitor', 'LG',     '27GP850-B', '27-inch QHD IPS gaming monitor, 165Hz.',                    '2026-07-22 11:00:00'),
  (12, 6, 'Keychron K2 Wireless Mechanical Keyboard','Keychron', NULL,     'Compact 75% wireless mechanical keyboard.',                 '2026-07-22 11:05:00'),
  (13, 7, 'Logitech G102 Gaming Mouse',             'Logitech','G102',     'Wired gaming mouse with 8,000 DPI sensor.',                 '2026-07-22 11:10:00');

-- CPU specs (products 1-5)
INSERT INTO CPU_Specifications (product_id, socket_type, core_count, thread_count, base_clock_ghz, boost_clock_ghz, tdp_watts) VALUES
  (1, 'AM5',     6, 12, 4.70, 5.30, 105),
  (2, 'AM5',     8, 16, 4.20, 5.00, 120),
  (3, 'LGA1700', 14, 20, 3.50, 5.10, 125),
  (4, 'LGA1700', 20, 28, 3.40, 5.60, 125),
  (5, 'AM4',     6, 12, 3.50, 4.40, 65);

-- GPU specs (products 6-10)
INSERT INTO GPU_Specifications (product_id, chipset, vram_capacity_gb, memory_type, interface, tdp_watts) VALUES
  (6,  'RTX 4060',       8,  'GDDR6',  'PCIe 4.0 x8',  115),
  (7,  'RTX 4070 Super', 12, 'GDDR6X', 'PCIe 4.0 x16', 220),
  (8,  'RX 7800 XT',     16, 'GDDR6',  'PCIe 4.0 x16', 263),
  (9,  'RX 7600',        8,  'GDDR6',  'PCIe 4.0 x8',  165),
  (10, 'Arc A750',       8,  'GDDR6',  'PCIe 4.0 x16', NULL);

-- Verification: expect 13, 5, 5
SELECT (SELECT COUNT(*) FROM Products)           AS products_count,
       (SELECT COUNT(*) FROM CPU_Specifications) AS cpu_specs,
       (SELECT COUNT(*) FROM GPU_Specifications) AS gpu_specs;