/*
    File: database/01_schema/05_orders_and_fulfillment/03_order_items.sql
    Table: Order_Items
    Description: Stores purchased line items and preserves the price
                 and discount used at checkout.
    Prerequisite Parent Tables: Vendor_Orders, Vendor_Products
*/

USE pckal_db;

CREATE TABLE Order_Items (
    order_item_id                 BIGINT AUTO_INCREMENT,
    vendor_order_id               BIGINT NOT NULL,
    vendor_product_id             INT NOT NULL,
    quantity                      SMALLINT NOT NULL,
    unit_price_before_discount    DECIMAL(10,2) NOT NULL,
    discount_applied_per_unit     DECIMAL(10,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (order_item_id),
    CONSTRAINT fk_order_items_vendor_order_id
        FOREIGN KEY (vendor_order_id)
        REFERENCES Vendor_Orders(vendor_order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_vendor_product_id
        FOREIGN KEY (vendor_product_id)
        REFERENCES Vendor_Products(vendor_product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Purchased quantity must be greater than zero.
    CONSTRAINT chk_order_items_quantity_positive
        CHECK (quantity > 0),
    -- Purchase-time unit price cannot be negative.
    CONSTRAINT chk_order_items_unit_price_nonnegative
        CHECK (unit_price_before_discount >= 0),
    -- Discount cannot be negative or exceed the original unit price.
    CONSTRAINT chk_order_items_discount_applied_per_unit_valid
        CHECK (
            discount_applied_per_unit >= 0
            AND discount_applied_per_unit <= unit_price_before_discount
        )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;