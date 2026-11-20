/*
    File: database/01_schema/03_vendor_listings_inventory/03_inventory_transactions.sql
    Table: Inventory_Transactions
    Description: Records restocks, sales deductions, returns,
                 and manual stock adjustments.
    Prerequisite Parent Tables: Vendor_Products
*/

USE pckal_db;

CREATE TABLE Inventory_Transactions (
    inventory_transaction_id BIGINT AUTO_INCREMENT,
    vendor_product_id        INT NOT NULL,
    transaction_type         ENUM(
                                 'restock',
                                 'sale_deduction',
                                 'adjustment',
                                 'return'
                             ) NOT NULL,
    quantity_change          INT NOT NULL,
    reason                   VARCHAR(255) NULL,
    transaction_date         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (inventory_transaction_id),
    CONSTRAINT fk_inventory_transactions_vendor_product_id
        FOREIGN KEY (vendor_product_id)
        REFERENCES Vendor_Products(vendor_product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Positive values add stock, negative values deduct stock,
    -- and adjustments must be nonzero.
    CONSTRAINT chk_inventory_transactions_quantity_change_matches_type
        CHECK (
            (
                transaction_type IN ('restock', 'return')
                AND quantity_change > 0
            )
            OR
            (
                transaction_type = 'sale_deduction'
                AND quantity_change < 0
            )
            OR
            (
                transaction_type = 'adjustment'
                AND quantity_change <> 0
            )
        )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;