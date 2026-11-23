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
