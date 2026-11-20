/*
    File: database/01_schema/05_orders_and_fulfillment/02_vendor_orders.sql
    Table: Vendor_Orders
    Description: Splits a customer order into seller-specific suborders.
    Prerequisite Parent Tables: Orders, Vendors
*/

USE pckal_db;

CREATE TABLE Vendor_Orders (
    vendor_order_id      BIGINT AUTO_INCREMENT,
    order_id             BIGINT NOT NULL,
    vendor_id            INT NOT NULL,
    vendor_order_status  ENUM(
                             'pending',
                             'processing',
                             'shipped',
                             'completed',
                             'cancelled'
                         ) NOT NULL DEFAULT 'pending',
    PRIMARY KEY (vendor_order_id),
    -- A vendor can appear only once within a customer order.
    CONSTRAINT uq_vendor_orders_order_id_vendor_id
        UNIQUE (order_id, vendor_id),
    CONSTRAINT fk_vendor_orders_order_id
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_vendor_orders_vendor_id
        FOREIGN KEY (vendor_id)
        REFERENCES Vendors(vendor_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;