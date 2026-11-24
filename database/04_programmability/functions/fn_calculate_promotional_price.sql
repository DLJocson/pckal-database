/*
    File: database/04_programmability/functions/fn_calculate_promotional_price.sql
    Table(s): Vendor_Products, Promotions
    Description: Calculates the effective unit price for a vendor listing on a
                 given reference date (defaults to CURDATE() if NULL). Applies
                 any matching fixed_amount or percentage promotion and prevents
                 negative prices.
    Prerequisite(s): 01_schema/.../09_vendor_products.sql, 12_promotions.sql
*/

USE pckal_db;

DROP FUNCTION IF EXISTS fn_calculate_promotional_price;

DELIMITER $$

CREATE FUNCTION fn_calculate_promotional_price(
    p_vendor_product_id INT,
    p_reference_date    DATE
)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_regular_price DECIMAL(10,2);
    DECLARE v_discount_type ENUM('fixed_amount', 'percentage');
    DECLARE v_discount_value DECIMAL(10,2);
    DECLARE v_effective_date DATE;
    DECLARE v_final_price DECIMAL(10,2);

    SET v_effective_date = COALESCE(p_reference_date, CURDATE());

    SELECT price
      INTO v_regular_price
      FROM Vendor_Products
     WHERE vendor_product_id = p_vendor_product_id;

    IF v_regular_price IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT discount_type, discount_value
      INTO v_discount_type, v_discount_value
      FROM Promotions
     WHERE vendor_product_id = p_vendor_product_id
       AND v_effective_date BETWEEN start_date AND end_date
     ORDER BY start_date DESC, promotion_id DESC
     LIMIT 1;

    IF v_discount_type IS NULL THEN
        SET v_final_price = v_regular_price;
    ELSEIF v_discount_type = 'fixed_amount' THEN
        SET v_final_price = v_regular_price - v_discount_value;
    ELSEIF v_discount_type = 'percentage' THEN
        SET v_final_price = v_regular_price - (v_regular_price * (v_discount_value / 100.00));
    ELSE
        SET v_final_price = v_regular_price;
    END IF;

    IF v_final_price < 0.00 THEN
        SET v_final_price = 0.00;
    END IF;

    RETURN ROUND(v_final_price, 2);
END$$

DELIMITER ;