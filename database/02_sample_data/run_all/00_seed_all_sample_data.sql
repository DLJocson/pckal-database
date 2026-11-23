/*
    PCKAL: Run-all sample-data seed script
    Target: MySQL 8.0.16+
    Prerequisite: all 20 finalized schema tables must already exist in pckal_db.
    Recommended: install finalized promotion and inventory triggers before seeding.

    HOW TO USE:
    1. Run against a CLEAN test database after the schema is created.
    2. Execute this entire file once. Do not also execute files from ../parts.
    3. This file embeds the numbered parts in dependency order and includes
       intermediate verification SELECT statements.

    For manual/debug execution, run ../parts/01_*.sql through ../parts/07_*.sql
    in numeric order, one complete file at a time.
*/

USE pckal_db;


-- ========================================================================
-- BEGIN INCLUDED FILE: 01_roles.sql
-- ========================================================================
/*
    File: database/02_sample_data/parts/01_roles.sql
    Table: Roles
    Description: Inserts the three application-level roles defined by the
                 finalized schema. This reference table intentionally has
                 three rows: customer, vendor, and administrator.
    Prerequisite Parent Tables: None
*/

USE pckal_db;

INSERT INTO Roles (role_id, role_name, description) VALUES
    (1, 'customer',      'Browses the catalog, manages a cart, places orders, and writes reviews.'),
    (2, 'vendor',        'Owns a storefront, manages listings and inventory, and fulfills vendor suborders.'),
    (3, 'administrator', 'Marketplace moderation and management (accounts, catalog, disputes).')
ON DUPLICATE KEY UPDATE
    description = VALUES(description);

SELECT role_id, role_name FROM Roles ORDER BY role_id;

-- ========================================================================
-- BEGIN INCLUDED FILE: 02_categories.sql
-- ========================================================================
/*
    File: database/02_sample_data/parts/02_categories.sql
    Table: Categories
    Description: Inserts product categories. Parent categories are inserted
                 before their children so every parent_category_id points
                 to an existing row. Safe to re-run: category_name is UNIQUE.
    Prerequisite Parent Tables: None (requires database/01_schema/02_product_catalog/01_categories.sql)
*/

USE pckal_db;

-- 1) Top-level (parent) categories
INSERT INTO Categories (category_id, category_name, parent_category_id, description) VALUES
    (1, 'PC Components', NULL, 'Internal parts used to build or upgrade a desktop PC.'),
    (4, 'Peripherals',   NULL, 'External devices used with a computer.')
ON DUPLICATE KEY UPDATE
    description = VALUES(description);

-- 2) Child categories under PC Components (CPUs, GPUs, storage, power, cooling)
INSERT INTO Categories (category_id, category_name, parent_category_id, description) VALUES
    (2, 'CPUs', 1, 'Desktop processors with socket, core, and clock specifications.'),
    (3, 'GPUs', 1, 'Graphics cards with chipset, VRAM, and interface specifications.'),
    (8, 'Storage', 1, 'Internal storage devices such as solid-state drives.'),
    (9, 'Power Supplies', 1, 'Power supply units for desktop computer systems.'),
    (10, 'Cooling', 1, 'Air and liquid cooling components for computer systems.')
ON DUPLICATE KEY UPDATE
    description = VALUES(description);

-- 3) Child categories under Peripherals
INSERT INTO Categories (category_id, category_name, parent_category_id, description) VALUES
    (5, 'Monitors',  4, 'Computer displays for work and gaming.'),
    (6, 'Keyboards', 4, 'Wired and wireless keyboards.'),
    (7, 'Mice',      4, 'Wired and wireless mice.')
ON DUPLICATE KEY UPDATE
    description = VALUES(description);

-- Verification: every child shows its parent name
SELECT c.category_id,
       c.category_name,
       p.category_name AS parent_category
FROM Categories c
LEFT JOIN Categories p ON p.category_id = c.parent_category_id
ORDER BY COALESCE(c.parent_category_id, c.category_id), c.category_id;

SELECT COUNT(*) AS categories_count FROM Categories; -- Expected: 10

-- ========================================================================
-- BEGIN INCLUDED FILE: 03_users_and_vendors.sql
-- ========================================================================
/*
    File: database/02_sample_data/parts/03_users_and_vendors.sql
    Tables: Users, User_Roles, Vendors
    Description: Demo accounts (1 administrator, 10 vendor owners, and 8
                 customer accounts), role assignments, and vendor profiles.
                 All sample people/businesses are fictional; password_hash
                 values are placeholders and are not login-ready credentials.
    Prerequisite: 01_roles.sql loaded.
*/

USE pckal_db;

-- 1 administrator, 10 vendor owners, 6 active customer-only accounts,
-- 1 suspended customer, and 1 deactivated customer. User 3 also has the
-- customer role in addition to being a vendor owner.
INSERT INTO Users (user_id, username, email, password_hash, full_name, phone_number, account_status, created_at) VALUES
  (1,  'admin_marco',    'marco.villanueva@pckal.example',  '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000001', 'Marco Villanueva',  '09170000001', 'active',      '2026-07-01 08:00:00'),
  (2,  'pixelforge_rina','rina.castillo@pixelforge.example','$2y$10$DEMOONLYfakehashvalue000000000000000000000000000002', 'Rina Castillo',     '09170000002', 'active',      '2026-07-02 09:00:00'),
  (3,  'bytebazaar_ken', 'ken.aquino@bytebazaar.example',   '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000003', 'Ken Aquino',        '09170000003', 'active',      '2026-07-02 09:30:00'),
  (4,  'corezone_lia',   'lia.navarro@corezone.example',    '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000004', 'Lia Navarro',       NULL,          'active',      '2026-07-03 10:00:00'),
  (5,  'juan_dc',        'juan.delacruz@mail.example',      '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000005', 'Juan dela Cruz',    '09180000005', 'active',      '2026-07-10 14:20:00'),
  (6,  'maria_s',        'maria.santos@mail.example',       '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000006', 'Maria Santos',      '09180000006', 'active',      '2026-07-12 11:05:00'),
  (7,  'paolo_r',        'paolo.reyes@mail.example',        '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000007', 'Paolo Reyes',       '09180000007', 'active',      '2026-07-15 16:40:00'),
  (8,  'angela_t',       'angela.tan@mail.example',         '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000008', 'Angela Tan',        '09180000008', 'active',      '2026-07-20 13:10:00'),
  (9,  'miguel_r',       'miguel.ramos@mail.example',       '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000009', 'Miguel Ramos',      NULL,          'active',      '2026-08-01 09:15:00'),
  (10, 'sofia_m',        'sofia.mendoza@mail.example',      '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000010', 'Sofia Mendoza',     '09180000010', 'active',      '2026-08-03 18:00:00'),
  (11, 'carlo_b',        'carlo.bautista@mail.example',     '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000011', 'Carlo Bautista',    '09180000011', 'suspended',   '2026-08-10 12:00:00'),
  (12, 'dina_f',         'dina.flores@mail.example',        '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000012', 'Dina Flores',       NULL,          'deactivated', '2026-08-12 15:30:00'),
  (13, 'siliconhub_eli',  'eli.morales@siliconhub.example',   '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000013', 'Eli Morales',       '09190000013', 'active',      '2026-07-28 09:00:00'),
  (14, 'nexatech_ana',    'ana.garcia@nexatech.example',      '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000014', 'Ana Garcia',        '09190000014', 'active',      '2026-07-28 09:30:00'),
  (15, 'circuitcentral_noel','noel.ramos@circuitcentral.example','$2y$10$DEMOONLYfakehashvalue000000000000000000000000000015', 'Noel Ramos',        '09190000015', 'active',      '2026-07-28 10:00:00'),
  (16, 'byteworks_mia',   'mia.reyes@byteworks.example',      '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000016', 'Mia Reyes',         '09190000016', 'active',      '2026-07-29 09:00:00'),
  (17, 'nextgen_jules',   'jules.lim@nextgen.example',        '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000017', 'Jules Lim',         '09190000017', 'active',      '2026-07-29 09:30:00'),
  (18, 'gpugalaxy_ira',   'ira.cruz@gpugalaxy.example',       '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000018', 'Ira Cruz',          '09190000018', 'active',      '2026-07-30 09:00:00'),
  (19, 'powertech_lex',   'lex.torres@powertech.example',     '$2y$10$DEMOONLYfakehashvalue000000000000000000000000000019', 'Lex Torres',        '09190000019', 'active',      '2026-07-30 09:30:00');

-- Role assignments (role_id: 1 customer, 2 vendor, 3 administrator)
-- Ken (user 3) holds two roles: vendor AND customer.
INSERT INTO User_Roles (user_role_id, user_id, role_id, assigned_at) VALUES
  (1,  1, 3, '2026-07-01 08:00:00'),
  (2,  2, 2, '2026-07-02 09:00:00'),
  (3,  3, 2, '2026-07-02 09:30:00'),
  (4,  3, 1, '2026-07-02 09:35:00'),
  (5,  4, 2, '2026-07-03 10:00:00'),
  (6,  5, 1, '2026-07-10 14:20:00'),
  (7,  6, 1, '2026-07-12 11:05:00'),
  (8,  7, 1, '2026-07-15 16:40:00'),
  (9,  8, 1, '2026-07-20 13:10:00'),
  (10, 9, 1, '2026-08-01 09:15:00'),
  (11, 10, 1, '2026-08-03 18:00:00'),
  (12, 11, 1, '2026-08-10 12:00:00'),
  (13, 12, 1, '2026-08-12 15:30:00'),
  (14, 13, 2, '2026-07-28 09:00:00'),
  (15, 14, 2, '2026-07-28 09:30:00'),
  (16, 15, 2, '2026-07-28 10:00:00'),
  (17, 16, 2, '2026-07-29 09:00:00'),
  (18, 17, 2, '2026-07-29 09:30:00'),
  (19, 18, 2, '2026-07-30 09:00:00'),
  (20, 19, 2, '2026-07-30 09:30:00');

-- One vendor profile per vendor-owner user (Vendors.user_id is UNIQUE)
INSERT INTO Vendors (vendor_id, user_id, store_name, store_description, business_address, contact_number, account_status, created_at) VALUES
  (1, 2, 'PixelForge Computers', 'Gaming-focused PC parts and peripherals.',          '12 Aurora Blvd, Quezon City',       '028-555-0101', 'active', '2026-07-02 10:00:00'),
  (2, 3, 'Byte Bazaar PH',       'Budget-friendly processors, GPUs, and accessories.', '45 Rizal Ave, Cebu City',           '032-555-0102', 'active', '2026-07-02 10:30:00'),
  (3, 4, 'CoreZone Hardware',    'High-performance CPUs, GPUs, and displays.',         '8 Magsaysay Rd, Davao City',        NULL,           'active', '2026-07-03 11:00:00'),
  (4, 13, 'SiliconHub Components', 'Storage, processors, and premium graphics cards.',   '20 Commonwealth Ave, Quezon City', '028-555-0104', 'active', '2026-07-28 10:00:00'),
  (5, 14, 'NexaTech Parts',        'Power supplies, CPUs, and graphics components.',     '15 Osmena Blvd, Cebu City',         '032-555-0105', 'active', '2026-07-28 10:30:00'),
  (6, 15, 'Circuit Central',       'Cooling parts and mainstream PC components.',       '27 San Pedro St, Davao City',       '082-555-0106', 'active', '2026-07-28 11:00:00'),
  (7, 16, 'ByteWorks Depot',       'Affordable desktop processors and upgrade parts.',  '18 J.M. Basa St, Iloilo City',       '033-555-0107', 'active', '2026-07-29 10:00:00'),
  (8, 17, 'NextGen Components',    'Processors, memory, and computing components.',    '44 Session Rd, Baguio City',        '074-555-0108', 'active', '2026-07-29 10:30:00'),
  (9, 18, 'GPU Galaxy PH',         'Graphics cards and enthusiast gaming components.', '9 Lacson St, Bacolod City',         '034-555-0109', 'active', '2026-07-30 10:00:00'),
  (10,19, 'PowerTech Supply',      'Power and performance components for PC builders.','31 Magsaysay Ave, Cagayan de Oro',   '088-555-0110', 'active', '2026-07-30 10:30:00');

-- Verification: expect 19 users, 20 role assignments, 10 vendors
SELECT (SELECT COUNT(*) FROM Users)      AS users_count,
       (SELECT COUNT(*) FROM User_Roles) AS user_roles_count,
       (SELECT COUNT(*) FROM Vendors)    AS vendors_count;

-- ========================================================================
-- BEGIN INCLUDED FILE: 04_products_and_specs.sql
-- ========================================================================
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

-- ========================================================================
-- BEGIN INCLUDED FILE: 05_vendor_listings_and_inventory.sql
-- ========================================================================
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

-- ========================================================================
-- BEGIN INCLUDED FILE: 06_promotions_and_carts.sql
-- ========================================================================
/*
    File: database/02_sample_data/parts/06_promotions_and_carts.sql
    Tables: Promotions, Shopping_Carts, Cart_Items
    Description: 10 demo promotions (expired, active, upcoming) and 10
                 customer carts with cart items. Promotion date ranges for the
                 same listing do not overlap.
    Prerequisite: 05_vendor_listings_and_inventory.sql loaded.
*/

USE pckal_db;

-- Status as of 2026-11-23: expired 1, 2, 4, 7 | active 3, 6, 8, 9
-- | upcoming 5, 10. Update this date when using the sample data later.
INSERT INTO Promotions (promotion_id, vendor_product_id, discount_type, discount_value, start_date, end_date, created_at) VALUES
  (1, 12, 'percentage',   10.00,   '2026-09-01', '2026-09-30', '2026-08-25 09:00:00'),
  (2, 5,  'fixed_amount', 2000.00, '2026-09-15', '2026-10-15', '2026-09-10 09:00:00'),
  (3, 16, 'percentage',   5.00,    '2026-11-15', '2026-11-30', '2026-11-10 09:00:00'),
  (4, 1,  'percentage',   10.00,   '2026-10-01', '2026-10-31', '2026-09-25 09:00:00'),
  (5, 21, 'percentage',   15.00,   '2026-12-01', '2026-12-15', '2026-11-15 09:00:00'),
  (6, 12, 'percentage',   8.00,    '2026-11-01', '2026-11-30', '2026-10-25 09:00:00'),
  (7, 14, 'fixed_amount', 500.00,  '2026-10-05', '2026-10-12', '2026-10-01 09:00:00'),
  (8, 9,  'fixed_amount', 1000.00, '2026-11-18', '2026-11-25', '2026-11-15 09:00:00'),
  (9, 13, 'fixed_amount', 1500.00, '2026-11-10', '2026-12-10', '2026-11-05 09:00:00'),
  (10,24, 'percentage',   10.00,   '2026-12-01', '2026-12-15', '2026-11-16 09:00:00');

-- Customer carts (carts 4 and 5 became orders 10 and 11)
INSERT INTO Shopping_Carts (cart_id, user_id, cart_status, created_at) VALUES
  (1, 5,  'active',      '2026-11-18 20:00:00'),
  (2, 6,  'active',      '2026-11-19 21:10:00'),
  (3, 7,  'abandoned',   '2026-10-22 19:30:00'),
  (4, 8,  'checked_out', '2026-11-19 08:30:00'),
  (5, 9,  'checked_out', '2026-11-20 12:00:00'),
  (6, 10, 'active',      '2026-11-20 22:45:00'),
  (7, 5,   'abandoned',   '2026-09-03 11:00:00'),
  (8, 6,   'abandoned',   '2026-09-05 16:00:00'),
  (9, 7,   'abandoned',   '2026-09-07 14:30:00'),
  (10,10,  'abandoned',   '2026-09-08 18:45:00');

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
  (11, 6, 20, 1, '2026-11-20 22:52:00'),
  (12, 7, 11, 1, '2026-09-03 11:05:00'),
  (13, 7, 13, 1, '2026-09-03 11:07:00'),
  (14, 8, 8,  1, '2026-09-05 16:05:00'),
  (15, 8, 15, 1, '2026-09-05 16:07:00'),
  (16, 9, 6,  1, '2026-09-07 14:35:00'),
  (17, 9, 14, 1, '2026-09-07 14:37:00'),
  (18,10, 16, 1, '2026-09-08 18:50:00'),
  (19,10, 22, 1, '2026-09-08 18:52:00');

-- Verification: expect 10 promotions, 10 carts, and 19 cart items
SELECT (SELECT COUNT(*) FROM Promotions)     AS promotions,
       (SELECT COUNT(*) FROM Shopping_Carts) AS carts,
       (SELECT COUNT(*) FROM Cart_Items)     AS cart_items;

-- ========================================================================
-- BEGIN INCLUDED FILE: 07_orders_and_transactions.sql
-- ========================================================================
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


/* FINAL SUMMARY: expected values assume a clean schema before the seed run. */
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

SELECT SUM(row_count) AS total_seeded_rows,
       CASE WHEN SUM(row_count) = 382 THEN 'PASS' ELSE 'CHECK' END AS total_validation
FROM (
    SELECT COUNT(*) AS row_count FROM Roles
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
