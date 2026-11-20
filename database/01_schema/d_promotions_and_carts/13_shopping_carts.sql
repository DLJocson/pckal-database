/*
    File: database/01_schema/04_promotions_and_carts/02_shopping_carts.sql
    Table: Shopping_Carts
    Description: Stores shopping cart records owned by customers.
    Prerequisite Parent Tables: Users
*/

USE pckal_db;

CREATE TABLE Shopping_Carts (
    cart_id      INT AUTO_INCREMENT,
    user_id      INT NOT NULL,
    cart_status  ENUM('active', 'checked_out', 'abandoned')
                 NOT NULL DEFAULT 'active',
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cart_id),
    -- Shopping carts are transient; deleting a user clears their carts.
    CONSTRAINT fk_shopping_carts_user_id
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;