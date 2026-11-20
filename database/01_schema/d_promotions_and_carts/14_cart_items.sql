/*
    File: database/01_schema/04_promotions_and_carts/03_cart_items.sql
    Table: Cart_Items
    Description: Stores vendor listings and quantities currently
                 selected in a shopping cart.
    Prerequisite Parent Tables: Shopping_Carts, Vendor_Products
*/

USE pckal_db;

CREATE TABLE Cart_Items (
    cart_item_id       INT AUTO_INCREMENT,
    cart_id            INT NOT NULL,
    vendor_product_id  INT NOT NULL,
    quantity           SMALLINT NOT NULL,
    added_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cart_item_id),
    -- A vendor listing must appear only once in a particular cart.
    CONSTRAINT uq_cart_items_cart_id_vendor_product_id
        UNIQUE (cart_id, vendor_product_id),
    CONSTRAINT fk_cart_items_cart_id
        FOREIGN KEY (cart_id)
        REFERENCES Shopping_Carts(cart_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_vendor_product_id
        FOREIGN KEY (vendor_product_id)
        REFERENCES Vendor_Products(vendor_product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Cart item quantity must be greater than zero.
    CONSTRAINT chk_cart_items_quantity_positive
        CHECK (quantity > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;