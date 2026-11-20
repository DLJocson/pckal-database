/*
    File: database/01_schema/02_product_catalog/04_gpu_specifications.sql
    Table: GPU_Specifications
    Description: Stores structured technical details for GPU products.
    Prerequisite Parent Tables: Products
*/

USE pckal_db;

CREATE TABLE GPU_Specifications (
    product_id       INT NOT NULL,
    chipset          VARCHAR(50) NOT NULL,
    vram_capacity_gb SMALLINT NOT NULL,
    memory_type      VARCHAR(20) NOT NULL,
    interface        VARCHAR(30) NOT NULL,
    tdp_watts        SMALLINT NULL,
    PRIMARY KEY (product_id),
    CONSTRAINT fk_gpu_specifications_product_id
        FOREIGN KEY (product_id)
        REFERENCES Products(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    -- Video memory capacity must be positive.
    CONSTRAINT chk_gpu_specifications_vram_positive
        CHECK (vram_capacity_gb > 0),
    -- Optional thermal design power cannot be negative.
    CONSTRAINT chk_gpu_specifications_tdp_nonnegative
        CHECK (
            tdp_watts IS NULL
            OR tdp_watts >= 0
        )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;