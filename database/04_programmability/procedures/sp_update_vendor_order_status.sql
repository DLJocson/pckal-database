/*
    File: database/04_programmability/procedures/sp_update_vendor_order_status.sql
    Table(s): Vendor_Orders, Orders, Payments
    Description: Updates a vendor suborder's status and synchronizes the parent
                 order status and completion_date when all suborders are
                 completed or cancelled.
    Prerequisite(s): 01_schema/.../15_orders.sql, 16_vendor_orders.sql, 18_payments.sql
*/

USE pckal_db;

DROP PROCEDURE IF EXISTS sp_update_vendor_order_status;

DELIMITER $$

CREATE PROCEDURE sp_update_vendor_order_status(
    IN p_vendor_order_id BIGINT,
    IN p_new_status      ENUM('pending', 'processing', 'shipped', 'completed', 'cancelled')
)
BEGIN
    DECLARE v_order_id BIGINT;
    DECLARE v_current_status VARCHAR(20);
    DECLARE v_total_suborders INT DEFAULT 0;
    DECLARE v_completed_suborders INT DEFAULT 0;
    DECLARE v_cancelled_suborders INT DEFAULT 0;
    DECLARE v_active_suborders INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT order_id, vendor_order_status
      INTO v_order_id, v_current_status
      FROM Vendor_Orders
     WHERE vendor_order_id = p_vendor_order_id
     FOR UPDATE;

    IF v_order_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Status update failed: vendor_order_id not found.';
    END IF;

    IF v_current_status = 'completed' AND p_new_status <> 'completed' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Status update failed: completed vendor suborders cannot be reverted.';
    END IF;

    UPDATE Vendor_Orders
       SET vendor_order_status = p_new_status
     WHERE vendor_order_id = p_vendor_order_id;

    SELECT COUNT(*),
           SUM(CASE WHEN vendor_order_status = 'completed' THEN 1 ELSE 0 END),
           SUM(CASE WHEN vendor_order_status = 'cancelled' THEN 1 ELSE 0 END),
           SUM(CASE WHEN vendor_order_status IN ('pending', 'processing', 'shipped') THEN 1 ELSE 0 END)
      INTO v_total_suborders,
           v_completed_suborders,
           v_cancelled_suborders,
           v_active_suborders
      FROM Vendor_Orders
     WHERE order_id = v_order_id;

    IF v_total_suborders > 0 AND v_cancelled_suborders = v_total_suborders THEN
        UPDATE Orders
           SET order_status = 'cancelled',
               completion_date = NULL
         WHERE order_id = v_order_id;
    ELSEIF v_total_suborders > 0
       AND v_active_suborders = 0
       AND v_completed_suborders > 0
       AND (v_completed_suborders + v_cancelled_suborders) = v_total_suborders THEN
        UPDATE Orders
           SET order_status = 'completed',
               completion_date = COALESCE(completion_date, NOW())
         WHERE order_id = v_order_id;

        UPDATE Payments
           SET payment_status = 'succeeded',
               paid_at = COALESCE(paid_at, NOW())
         WHERE order_id = v_order_id
           AND payment_status = 'pending';
    ELSEIF v_active_suborders > 0 OR v_completed_suborders > 0 THEN
        UPDATE Orders
           SET order_status = 'processing'
         WHERE order_id = v_order_id
           AND order_status = 'pending';
    END IF;

    COMMIT;
END$$

DELIMITER ;