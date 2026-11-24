/*
    File: database/04_programmability/functions/fn_calculate_order_total.sql
    Table(s): Orders, Vendor_Orders, Order_Items
    Description: Computes the net total for a customer order from its line
                 items ((unit_price_before_discount - discount_applied_per_unit)
                 * quantity) without storing duplicate order totals.
    Prerequisite(s): 01_schema/.../15_orders.sql, 16_vendor_orders.sql, 17_order_items.sql
*/

USE pckal_db;

DROP FUNCTION IF EXISTS fn_calculate_order_total;

DELIMITER $$

CREATE FUNCTION fn_calculate_order_total(
    p_order_id BIGINT
)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_order_total DECIMAL(12,2);

    SELECT COALESCE(
               SUM((oi.unit_price_before_discount - oi.discount_applied_per_unit) * oi.quantity),
               0.00
           )
      INTO v_order_total
      FROM Vendor_Orders vo
      JOIN Order_Items oi ON oi.vendor_order_id = vo.vendor_order_id
     WHERE vo.order_id = p_order_id;

    RETURN ROUND(v_order_total, 2);
END$$

DELIMITER ;