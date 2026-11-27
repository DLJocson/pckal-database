/*
    File: database/04_programmability/triggers/trg_promotion_before_update.sql
    Table(s): Promotions
    Description: Enforces end_date >= start_date and rejects overlapping
                 promotional date ranges for the same vendor_product_id on
                 update, excluding the row being updated.
    Prerequisite(s): 01_schema/.../12_promotions.sql
*/

USE pckal_db;

DROP TRIGGER IF EXISTS trg_promotion_before_update;

DELIMITER $$

CREATE TRIGGER trg_promotion_before_update
BEFORE UPDATE ON Promotions
FOR EACH ROW
BEGIN
    DECLARE v_overlap_count INT DEFAULT 0;

    IF NEW.end_date < NEW.start_date THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid promotion dates: end_date must be greater than or equal to start_date.';
    END IF;

    SELECT COUNT(*)
      INTO v_overlap_count
      FROM Promotions
     WHERE vendor_product_id = NEW.vendor_product_id
       AND promotion_id <> OLD.promotion_id
       AND NEW.start_date <= end_date
       AND NEW.end_date >= start_date;

    IF v_overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Overlapping promotion period for this vendor listing.';
    END IF;
END$$

DELIMITER ;