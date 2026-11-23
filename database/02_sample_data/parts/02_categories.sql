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
