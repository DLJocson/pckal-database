/*
    File: database/01_schema/04_promotions_and_carts/01_promotions.sql
    Table: Promotions
    Description: Stores fixed-amount or percentage discounts
                 for individual vendor listings.
    Prerequisite Parent Tables: Vendor_Products
*/

USE pckal_db;

CREATE TABLE Promotions (
    promotion_id       INT AUTO_INCREMENT,
    vendor_product_id  INT NOT NULL,
    discount_type      ENUM('fixed_amount', 'percentage') NOT NULL,
    discount_value     DECIMAL(10,2) NOT NULL,
    start_date         DATE NOT NULL,
    end_date           DATE NOT NULL,
    created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (promotion_id),
    CONSTRAINT fk_promotions_vendor_product_id
        FOREIGN KEY (vendor_product_id)
        REFERENCES Vendor_Products(vendor_product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Discount must be positive; percentage discounts cannot exceed 100%.
    CONSTRAINT chk_promotions_discount_value_valid
        CHECK (
            discount_value > 0
            AND (
                discount_type <> 'percentage'
                OR discount_value <= 100
            )
        ),
    -- Promotion end date must not precede its start date.
    CONSTRAINT chk_promotions_end_date_valid
        CHECK (end_date >= start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;