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
