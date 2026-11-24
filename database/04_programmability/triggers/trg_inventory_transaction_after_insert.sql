/*
    File: database/04_programmability/triggers/trg_inventory_transaction_after_insert.sql
    Table(s): Inventory_Transactions, Inventory
    Description: Applies signed quantity_change from Inventory_Transactions to
                 Inventory.quantity_on_hand after insert and rejects any
                 movement that would result in negative stock.
    Prerequisite(s): 01_schema/.../10_inventory.sql, 11_inventory_transactions.sql
*/

USE pckal_db;

DROP TRIGGER IF EXISTS trg_inventory_transaction_after_insert;

DELIMITER $$

CREATE TRIGGER trg_inventory_transaction_after_insert
AFTER INSERT ON Inventory_Transactions
FOR EACH ROW
BEGIN
    DECLARE v_current_stock INT;

    SELECT quantity_on_hand
      INTO v_current_stock
      FROM Inventory
     WHERE vendor_product_id = NEW.vendor_product_id;

    IF v_current_stock IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Inventory record missing for vendor_product_id.';
    END IF;

    IF v_current_stock + NEW.quantity_change < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock: transaction would make quantity_on_hand negative.';
    END IF;

    UPDATE Inventory
       SET quantity_on_hand = quantity_on_hand + NEW.quantity_change
     WHERE vendor_product_id = NEW.vendor_product_id;
END$$

DELIMITER ;