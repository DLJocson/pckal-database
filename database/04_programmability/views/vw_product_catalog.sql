/*
    File: database/04_programmability/views/vw_product_catalog.sql
    Table(s): Products, Categories, CPU_Specifications, GPU_Specifications,
              Vendor_Products, Vendors, Inventory
    Description: Displays shared catalog products with category hierarchy,
                 optional CPU/GPU technical specifications, vendor listing
                 availability, and current stock counts.
    Prerequisite(s): 01_schema/.../04_vendors.sql through 10_inventory.sql
*/

USE pckal_db;

CREATE OR REPLACE VIEW vw_product_catalog AS
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    p.model_number,
    p.description AS product_description,
    c.category_id,
    c.category_name,
    pc.category_name AS parent_category_name,
    cpu.socket_type,
    cpu.core_count,
    cpu.thread_count,
    cpu.base_clock_ghz,
    cpu.boost_clock_ghz,
    cpu.tdp_watts AS cpu_tdp_watts,
    gpu.chipset AS gpu_chipset,
    gpu.vram_capacity_gb,
    gpu.memory_type AS gpu_memory_type,
    gpu.interface AS gpu_interface,
    gpu.tdp_watts AS gpu_tdp_watts,
    vp.vendor_product_id,
    v.vendor_id,
    v.store_name AS vendor_name,
    v.account_status AS vendor_status,
    vp.seller_sku,
    vp.price AS regular_price,
    vp.listing_status,
    COALESCE(inv.quantity_on_hand, 0) AS quantity_on_hand,
    COALESCE(inv.low_stock_threshold, 5) AS low_stock_threshold
FROM Products p
JOIN Categories c ON c.category_id = p.category_id
LEFT JOIN Categories pc ON pc.category_id = c.parent_category_id
LEFT JOIN CPU_Specifications cpu ON cpu.product_id = p.product_id
LEFT JOIN GPU_Specifications gpu ON gpu.product_id = p.product_id
LEFT JOIN Vendor_Products vp ON vp.product_id = p.product_id
LEFT JOIN Vendors v ON v.vendor_id = vp.vendor_id
LEFT JOIN Inventory inv ON inv.vendor_product_id = vp.vendor_product_id;