/*
    File: database/01_schema/02_product_catalog/03_cpu_specifications.sql
    Table: CPU_Specifications
    Description: Stores structured technical details for CPU products.
    Prerequisite Parent Tables: Products
*/

USE pckal_db;

CREATE TABLE CPU_Specifications (
    product_id      INT NOT NULL,
    socket_type     VARCHAR(30) NOT NULL,
    core_count      SMALLINT NOT NULL,
    thread_count    SMALLINT NOT NULL,
    base_clock_ghz  DECIMAL(4,2) NOT NULL,
    boost_clock_ghz DECIMAL(4,2) NULL,
    tdp_watts       SMALLINT NOT NULL,
    PRIMARY KEY (product_id),
    CONSTRAINT fk_cpu_specifications_product_id
        FOREIGN KEY (product_id)
        REFERENCES Products(product_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    -- Physical core count must be positive.
    CONSTRAINT chk_cpu_specifications_core_count_positive
        CHECK (core_count > 0),
    -- Thread count must be positive.
    CONSTRAINT chk_cpu_specifications_thread_count_positive
        CHECK (thread_count > 0),
    -- Base clock speed must be positive.
    CONSTRAINT chk_cpu_specifications_base_clock_positive
        CHECK (base_clock_ghz > 0),
    -- Optional boost clock must not be lower than the base clock.
    CONSTRAINT chk_cpu_specifications_boost_clock_valid
        CHECK (
            boost_clock_ghz IS NULL
            OR boost_clock_ghz >= base_clock_ghz
        ),
    -- Thermal design power cannot be negative.
    CONSTRAINT chk_cpu_specifications_tdp_nonnegative
        CHECK (tdp_watts >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;