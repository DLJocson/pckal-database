/*
    File: database/01_schema/05_orders_and_fulfillment/06_reviews.sql
    Table: Reviews
    Description: Stores product feedback and, optionally,
                 a separate seller rating for the same purchased item.
    Prerequisite Parent Tables: Order_Items
*/

USE pckal_db;

CREATE TABLE Reviews (
    review_id       INT AUTO_INCREMENT,
    order_item_id   BIGINT NOT NULL,
    product_rating  TINYINT NOT NULL,
    seller_rating   TINYINT NULL,
    review_text     TEXT NULL,
    reviewed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id),
    -- Only one review record is allowed per purchased line item.
    CONSTRAINT uq_reviews_order_item_id
        UNIQUE (order_item_id),
    CONSTRAINT fk_reviews_order_item_id
        FOREIGN KEY (order_item_id)
        REFERENCES Order_Items(order_item_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    -- Product rating must be between 1 and 5.
    CONSTRAINT chk_reviews_product_rating_valid
        CHECK (product_rating BETWEEN 1 AND 5),
    -- Optional seller rating must also be between 1 and 5.
    CONSTRAINT chk_reviews_seller_rating_valid
        CHECK (
            seller_rating IS NULL
            OR seller_rating BETWEEN 1 AND 5
        )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;