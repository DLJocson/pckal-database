/*
    File: database/01_schema/05_orders_and_fulfillment/05_shipments.sql
    Table: Shipments
    Description: Stores shipment and delivery information
                 for vendor-specific suborders.
    Prerequisite Parent Tables: Vendor_Orders
*/

USE pckal_db;

CREATE TABLE Shipments (
    shipment_id      BIGINT AUTO_INCREMENT,
    vendor_order_id  BIGINT NOT NULL,
    carrier_name     VARCHAR(50) NULL,
    tracking_number  VARCHAR(100) NULL,
    shipment_status  ENUM(
                         'pending',
                         'packed',
                         'shipped',
                         'delivered',
                         'returned'
                     ) NOT NULL DEFAULT 'pending',
    shipped_at       DATETIME NULL,
    delivered_at     DATETIME NULL,
    PRIMARY KEY (shipment_id),
    CONSTRAINT fk_shipments_vendor_order_id
        FOREIGN KEY (vendor_order_id)
        REFERENCES Vendor_Orders(vendor_order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;