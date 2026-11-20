/*
    File: database/01_schema/01_identity_and_access/01_users.sql
    Table: Users
    Description: Stores customer, vendor-account owner, and marketplace
                 administrator account information.
    Prerequisite Parent Tables: None
*/

USE pckal_db;

CREATE TABLE Users (
    user_id         INT AUTO_INCREMENT,
    username        VARCHAR(50) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    full_name       VARCHAR(100) NOT NULL,
    phone_number    VARCHAR(20) NULL,
    account_status  ENUM('active', 'suspended', 'deactivated')
                    NOT NULL DEFAULT 'active',
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    CONSTRAINT uq_users_username
        UNIQUE (username),
    CONSTRAINT uq_users_email
        UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;