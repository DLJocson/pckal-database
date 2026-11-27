/*
    File: database/04_programmability/procedures/sp_adjust_inventory.sql
    Table(s): Vendor_Products, Inventory, Inventory_Transactions
    Description: Validates a vendor listing and records an inventory movement
                 ('restock', 'adjustment', or 'return') in
                 Inventory_Transactions with sign validation and atomic
                 transaction handling.
    Prerequisite(s): 01_schema/.../09_vendor_products.sql, 10_inventory.sql, 11_inventory_transactions.sql,
                     trg_inventory_transaction_after_insert
*/

USE pckal_db;

DROP PROCEDURE IF EXISTS sp_adjust_inventory;

DELIMITER $$

CREATE PROCEDURE sp_adjust_inventory(
    IN p_vendor_product_id INT,
    IN p_transaction_type  ENUM('restock', 'adjustment', 'return'),
    IN p_quantity_change   INT,
    IN p_reason            VARCHAR(255)
)
BEGIN
    DECLARE v_listing_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*)
      INTO v_listing_exists
      FROM Vendor_Products
     WHERE vendor_product_id = p_vendor_product_id;

    IF v_listing_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Inventory adjustment failed: vendor_product_id does not exist.';
    END IF;

    IF p_transaction_type IN ('restock', 'return') AND p_quantity_change <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Inventory adjustment failed: restock and return require a positive quantity_change.';
    END IF;

    IF p_transaction_type = 'adjustment' AND p_quantity_change = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Inventory adjustment failed: adjustment requires a non-zero quantity_change.';
    END IF;

    -- Lock inventory row before inserting transaction
    SELECT vendor_product_id
      FROM Inventory
     WHERE vendor_product_id = p_vendor_product_id
     FOR UPDATE;

    INSERT INTO Inventory_Transactions (
        vendor_product_id,
        transaction_type,
        quantity_change,
        reason,
        transaction_date
    )
    VALUES (
        p_vendor_product_id,
        p_transaction_type,
        p_quantity_change,
        COALESCE(NULLIF(TRIM(p_reason), ''), CONCAT('Manual ', p_transaction_type)),
        NOW()
    );

    COMMIT;
END$$

DELIMITER ;