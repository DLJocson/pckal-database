/*
    File: database/01_schema/01_identity_and_access/02_roles.sql
    Table: Roles
    Description: Defines application-level roles assigned through User_Roles.
    Prerequisite Parent Tables: None
*/

USE pckal_db;

CREATE TABLE Roles (
    role_id      INT AUTO_INCREMENT,
    role_name    VARCHAR(30) NOT NULL,
    description  VARCHAR(255) NULL,
    PRIMARY KEY (role_id),
    CONSTRAINT uq_roles_role_name
        UNIQUE (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;