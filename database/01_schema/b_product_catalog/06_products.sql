/*
    File: database/01_schema/02_product_catalog/02_products.sql
    Table: Products
    Description: Stores shared product information independently
                 of each vendor's listing, price, and stock.
    Prerequisite Parent Tables: Categories
*/

USE pckal_db;

CREATE TABLE Products (
    product_id    INT AUTO_INCREMENT,
    category_id   INT NOT NULL,
    product_name  VARCHAR(150) NOT NULL,
    brand         VARCHAR(50) NOT NULL,
    model_number  VARCHAR(50) NULL,
    description   TEXT NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id),
    CONSTRAINT fk_products_category_id
        FOREIGN KEY (category_id)
        REFERENCES Categories(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;