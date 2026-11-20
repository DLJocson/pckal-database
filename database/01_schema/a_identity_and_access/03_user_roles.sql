/*
    File: database/01_schema/01_identity_and_access/03_user_roles.sql
    Table: User_Roles
    Description: Associates users with one or more application-level roles.
    Prerequisite Parent Tables: Users, Roles
*/

USE pckal_db;

CREATE TABLE User_Roles (
    user_role_id  INT AUTO_INCREMENT,
    user_id       INT NOT NULL,
    role_id       INT NOT NULL,
    assigned_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_role_id),
    -- Prevents assigning the same role to the same user more than once.
    CONSTRAINT uq_user_roles_user_id_role_id
        UNIQUE (user_id, role_id),
    CONSTRAINT fk_user_roles_user_id
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    -- Protect role definitions while they are assigned to users.
    CONSTRAINT fk_user_roles_role_id
        FOREIGN KEY (role_id)
        REFERENCES Roles(role_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;