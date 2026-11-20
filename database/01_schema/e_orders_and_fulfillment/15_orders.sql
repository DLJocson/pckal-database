/*
    File: database/01_schema/05_orders_and_fulfillment/01_orders.sql
    Table: Orders
    Description: Stores the main customer checkout transaction,
                 including the shipping address captured at checkout.
    Prerequisite Parent Tables: Users
*/

USE pckal_db;

CREATE TABLE Orders (
    order_id          BIGINT AUTO_INCREMENT,
    user_id           INT NOT NULL,
    shipping_address  VARCHAR(255) NOT NULL,
    order_date        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completion_date   DATETIME NULL,
    order_status      ENUM(
                          'pending',
                          'processing',
                          'completed',
                          'cancelled'
                      ) NOT NULL DEFAULT 'pending',
    PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_user_id
        FOREIGN KEY (user_id)
        REFERENCES Users(user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;