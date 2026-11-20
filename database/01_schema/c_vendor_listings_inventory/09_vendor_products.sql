/*
    File: database/01_schema/03_vendor_listings_inventory/01_vendor_products.sql
    Table: Vendor_Products
    Description: Represents a vendor-specific listing of a shared product.
    Prerequisite Parent Tables: Vendors, Products
*/

USE pckal_db;

CREATE TABLE Vendor_Products (
    vendor_product_id  INT AUTO_INCREMENT,
    vendor_id          INT NOT NULL,
    product_id         INT NOT NULL,
    seller_sku         VARCHAR(50) NOT NULL,
    price              DECIMAL(10,2) NOT NULL,
    listing_status     ENUM('active', 'inactive', 'discontinued')
                       NOT NULL DEFAULT 'active',
    listed_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (vendor_product_id),
    -- Prevents a vendor from listing the same shared product twice.
    CONSTRAINT uq_vendor_products_vendor_id_product_id
        UNIQUE (vendor_id, product_id),
    -- Ensures SKU uniqueness within each vendor's listings.
    CONSTRAINT uq_vendor_products_vendor_id_seller_sku
        UNIQUE (vendor_id, seller_sku),
    CONSTRAINT fk_vendor_products_vendor_id
        FOREIGN KEY (vendor_id)
        REFERENCES Vendors(vendor_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_vendor_products_product_id
        FOREIGN KEY (product_id)
        REFERENCES Products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Listing prices cannot be negative.
    CONSTRAINT chk_vendor_products_price_nonnegative
        CHECK (price >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;