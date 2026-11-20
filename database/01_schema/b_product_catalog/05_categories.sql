/*
    File: database/01_schema/02_product_catalog/01_categories.sql
    Table: Categories
    Description: Maintains product classifications and optional
                 parent-child category grouping.
    Prerequisite Parent Tables: None
*/

USE pckal_db;

CREATE TABLE Categories (
    category_id         INT AUTO_INCREMENT,
    category_name       VARCHAR(50) NOT NULL,
    parent_category_id  INT NULL,
    description         VARCHAR(255) NULL,
    PRIMARY KEY (category_id),
    CONSTRAINT uq_categories_category_name
        UNIQUE (category_name),
    CONSTRAINT fk_categories_parent_category_id
        FOREIGN KEY (parent_category_id)
        REFERENCES Categories(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;