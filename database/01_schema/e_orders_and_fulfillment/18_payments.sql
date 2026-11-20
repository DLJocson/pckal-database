/*
    File: database/01_schema/05_orders_and_fulfillment/04_payments.sql
    Table: Payments
    Description: Stores one simulated payment record for each
                 customer order.
    Prerequisite Parent Tables: Orders
*/

USE pckal_db;

CREATE TABLE Payments (
    payment_id             BIGINT AUTO_INCREMENT,
    order_id               BIGINT NOT NULL,
    payment_method         ENUM(
                               'simulated_card',
                               'simulated_ewallet',
                               'cash_on_delivery'
                           ) NOT NULL,
    transaction_reference  VARCHAR(100) NULL,
    amount_paid            DECIMAL(10,2) NOT NULL,
    payment_status         ENUM(
                               'pending',
                               'succeeded',
                               'failed'
                           ) NOT NULL DEFAULT 'pending',
    paid_at                DATETIME NULL,
    PRIMARY KEY (payment_id),
    -- Enforces one payment record per customer order.
    CONSTRAINT uq_payments_order_id
        UNIQUE (order_id),
    CONSTRAINT fk_payments_order_id
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Payment amount cannot be negative.
    CONSTRAINT chk_payments_amount_paid_nonnegative
        CHECK (amount_paid >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;