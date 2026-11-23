/*
    File: database/02_sample_data/parts/04_products_and_specs.sql
    Tables: Products, CPU_Specifications, GPU_Specifications
    Description: Demo products (10 CPUs, 10 GPUs, and 6 other PC components)
                 with structured specs for all CPU and GPU products.
    Prerequisite: 02_categories.sql loaded.
*/

USE pckal_db;

-- Category IDs: 2 CPUs, 3 GPUs, 5 Monitors, 6 Keyboards, 7 Mice,
-- 8 Storage, 9 Power Supplies, 10 Cooling.
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
  (13, 7, 'Logitech G102 Gaming Mouse',             'Logitech','G102',     'Wired gaming mouse with 8,000 DPI sensor.',                 '2026-07-22 11:10:00'),
  (14, 8, 'Samsung 990 PRO 1TB NVMe SSD',             'Samsung', '990 PRO 1TB', '1TB NVMe M.2 solid-state drive for desktop storage.',     '2026-07-23 09:00:00'),
  (15, 9, 'Corsair RM850e 850W Power Supply',          'Corsair', 'RM850e',     '850W modular power supply for desktop PC builds.',        '2026-07-23 09:05:00'),
  (16,10, 'DeepCool AK620 CPU Air Cooler',             'DeepCool','AK620',      'Dual-tower air cooler for compatible desktop processors.','2026-07-23 09:10:00'),
  (17, 2, 'AMD Ryzen 9 7950X Processor',               'AMD',     '7950X',       '16-core, 32-thread AM5 desktop processor.',              '2026-07-24 09:00:00'),
  (18, 2, 'AMD Ryzen 9 7900X Processor',               'AMD',     '7900X',       '12-core, 24-thread AM5 desktop processor.',              '2026-07-24 09:05:00'),
  (19, 2, 'AMD Ryzen 7 7700 Processor',                'AMD',     '7700',        '8-core, 16-thread AM5 desktop processor.',               '2026-07-24 09:10:00'),
  (20, 2, 'AMD Ryzen 5 7600 Processor',                'AMD',     '7600',        '6-core, 12-thread AM5 desktop processor.',               '2026-07-24 09:15:00'),
  (21, 2, 'Intel Core i5-14400F Processor',            'Intel',   'i5-14400F',   '10-core (6P+4E), 16-thread LGA1700 desktop processor.',   '2026-07-24 09:20:00'),
  (22, 3, 'NVIDIA GeForce RTX 4080 SUPER 16GB',         'NVIDIA',  'RTX 4080 SUPER','16GB GDDR6X graphics card for high-end gaming and creation.','2026-07-24 10:00:00'),
  (23, 3, 'NVIDIA GeForce RTX 4090 24GB',               'NVIDIA',  'RTX 4090',    '24GB GDDR6X graphics card for demanding workloads.',     '2026-07-24 10:05:00'),
  (24, 3, 'AMD Radeon RX 7900 XTX 24GB',                'AMD',     'RX 7900 XTX', '24GB GDDR6 graphics card for high-end gaming.',          '2026-07-24 10:10:00'),
  (25, 3, 'AMD Radeon RX 7900 XT 20GB',                 'AMD',     'RX 7900 XT',  '20GB GDDR6 graphics card for enthusiast gaming.',        '2026-07-24 10:15:00'),
  (26, 3, 'Intel Arc B580 12GB Graphics Card',          'Intel',   'Arc B580',    '12GB GDDR6 graphics card for modern gaming systems.',     '2026-07-24 10:20:00');

-- CPU specs (products 1-5 and 17-21)
INSERT INTO CPU_Specifications (product_id, socket_type, core_count, thread_count, base_clock_ghz, boost_clock_ghz, tdp_watts) VALUES
  (1, 'AM5',     6, 12, 4.70, 5.30, 105),
  (2, 'AM5',     8, 16, 4.20, 5.00, 120),
  (3, 'LGA1700', 14, 20, 3.50, 5.10, 125),
  (4, 'LGA1700', 20, 28, 3.40, 5.60, 125),
  (5, 'AM4',     6, 12, 3.50, 4.40, 65),
  (17,'AM5',     16, 32, 4.50, 5.70, 170),
  (18,'AM5',     12, 24, 4.70, 5.60, 170),
  (19,'AM5',      8, 16, 3.80, 5.30, 65),
  (20,'AM5',      6, 12, 3.80, 5.10, 65),
  (21,'LGA1700', 10, 16, 2.50, 4.70, 65);

-- GPU specs (products 6-10 and 22-26)
INSERT INTO GPU_Specifications (product_id, chipset, vram_capacity_gb, memory_type, interface, tdp_watts) VALUES
  (6,  'RTX 4060',       8,  'GDDR6',  'PCIe 4.0 x8',  115),
  (7,  'RTX 4070 Super', 12, 'GDDR6X', 'PCIe 4.0 x16', 220),
  (8,  'RX 7800 XT',     16, 'GDDR6',  'PCIe 4.0 x16', 263),
  (9,  'RX 7600',        8,  'GDDR6',  'PCIe 4.0 x8',  165),
  (10, 'Arc A750',       8,  'GDDR6',  'PCIe 4.0 x16', NULL),
  (22, 'RTX 4080 SUPER', 16, 'GDDR6X', 'PCIe 4.0 x16', 320),
  (23, 'RTX 4090',       24, 'GDDR6X', 'PCIe 4.0 x16', 450),
  (24, 'RX 7900 XTX',    24, 'GDDR6',  'PCIe 4.0 x16', 355),
  (25, 'RX 7900 XT',     20, 'GDDR6',  'PCIe 4.0 x16', 315),
  (26, 'Arc B580',       12, 'GDDR6',  'PCIe 4.0 x8',  190);

-- Verification: expect 26 products, 10 CPU specifications, 10 GPU specifications
SELECT (SELECT COUNT(*) FROM Products)           AS products_count,
       (SELECT COUNT(*) FROM CPU_Specifications) AS cpu_specs,
       (SELECT COUNT(*) FROM GPU_Specifications) AS gpu_specs;
