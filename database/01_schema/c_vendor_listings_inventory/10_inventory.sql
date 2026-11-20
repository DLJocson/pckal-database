/*
    File: database/01_schema/03_vendor_listings_inventory/02_inventory.sql
    Table: Inventory
    Description: Stores the current stock balance and low-stock threshold
                 for each vendor listing.
    Prerequisite Parent Tables: Vendor_Products
*/

USE pckal_db;

CREATE TABLE Inventory (
    vendor_product_id   INT NOT NULL,
    quantity_on_hand    INT NOT NULL DEFAULT 0,
    low_stock_threshold INT NOT NULL DEFAULT 5,
    updated_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (vendor_product_id),
    CONSTRAINT fk_inventory_vendor_product_id
        FOREIGN KEY (vendor_product_id)
        REFERENCES Vendor_Products(vendor_product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    -- Stock quantity cannot be negative.
    CONSTRAINT chk_inventory_quantity_on_hand_nonnegative
        CHECK (quantity_on_hand >= 0),
    -- Low-stock threshold cannot be negative.
    CONSTRAINT chk_inventory_low_stock_threshold_nonnegative
        CHECK (low_stock_threshold >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;