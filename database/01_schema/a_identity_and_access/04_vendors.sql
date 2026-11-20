/*
    File: database/01_schema/01_identity_and_access/04_vendors.sql
    Table: Vendors
    Description: Stores seller profile and storefront information linked
                 to a user account.
    Prerequisite Parent Tables: Users
*/

USE pckal_db;

CREATE TABLE Vendors (
    vendor_id         INT AUTO_INCREMENT,
    user_id           INT NOT NULL,
    store_name        VARCHAR(100) NOT NULL,
    store_description TEXT NULL,
    business_address  VARCHAR(255) NULL,
    contact_number    VARCHAR(20) NULL,
    account_status    ENUM('active', 'suspended', 'deactivated')
                      NOT NULL DEFAULT 'active',
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (vendor_id),
    CONSTRAINT uq_vendors_user_id
        UNIQUE (user_id),
    CONSTRAINT uq_vendors_store_name
        UNIQUE (store_name),
    CONSTRAINT fk_vendors_user_id
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;