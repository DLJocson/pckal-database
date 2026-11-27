/*
    File: database/04_programmability/procedures/sp_checkout_cart.sql
    Table(s): Shopping_Carts, Cart_Items, Users, Vendors, Vendor_Products,
              Inventory, Inventory_Transactions, Promotions, Orders,
              Vendor_Orders, Order_Items, Payments, Shipments
    Description: Atomically validates an active shopping cart, locks listings and
                 stock, creates the main order, per-vendor suborders, frozen
                 order items, initial shipment records, simulated payment,
                 deducts stock via Inventory_Transactions, and marks the cart
                 checked_out.
    Prerequisite(s): 01_schema/.../19_shipments.sql,
                     fn_calculate_promotional_price,
                     trg_inventory_transaction_after_insert
*/

USE pckal_db;

DROP PROCEDURE IF EXISTS sp_checkout_cart;

DELIMITER $$

CREATE PROCEDURE sp_checkout_cart(
    IN  p_cart_id               INT,
    IN  p_user_id               INT,
    IN  p_shipping_address      VARCHAR(255),
    IN  p_payment_method        ENUM('simulated_card', 'simulated_ewallet', 'cash_on_delivery'),
    IN  p_transaction_reference VARCHAR(100),
    OUT p_order_id              BIGINT
)
BEGIN
    DECLARE v_cart_status VARCHAR(20);
    DECLARE v_user_status VARCHAR(20);
    DECLARE v_item_count INT DEFAULT 0;
    DECLARE v_invalid_count INT DEFAULT 0;
    DECLARE v_order_total DECIMAL(12,2) DEFAULT 0.00;
    DECLARE v_payment_status ENUM('pending', 'succeeded', 'failed');
    DECLARE v_paid_at DATETIME;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_order_id = NULL;
        RESIGNAL;
    END;

    START TRANSACTION;

    IF p_shipping_address IS NULL OR TRIM(p_shipping_address) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Checkout failed: shipping_address is required.';
    END IF;

    SELECT account_status
      INTO v_user_status
      FROM Users
     WHERE user_id = p_user_id;

    IF v_user_status IS NULL OR v_user_status <> 'active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Checkout failed: customer account does not exist or is not active.';
    END IF;

    SELECT cart_status
      INTO v_cart_status
      FROM Shopping_Carts
     WHERE cart_id = p_cart_id
       AND user_id = p_user_id
     FOR UPDATE;

    IF v_cart_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Checkout failed: shopping cart not found for this user.';
    END IF;

    IF v_cart_status <> 'active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Checkout failed: shopping cart is not active.';
    END IF;

    SELECT COUNT(*)
      INTO v_item_count
      FROM Cart_Items
     WHERE cart_id = p_cart_id;

    IF v_item_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Checkout failed: shopping cart is empty.';
    END IF;

    -- Lock inventory rows for items in this cart to prevent concurrent overselling
    SELECT COUNT(*)
      INTO v_invalid_count
      FROM (
          SELECT ci.cart_item_id
            FROM Cart_Items ci
            JOIN Vendor_Products vp ON vp.vendor_product_id = ci.vendor_product_id
            JOIN Vendors v ON v.vendor_id = vp.vendor_id
            JOIN Inventory inv ON inv.vendor_product_id = vp.vendor_product_id
           WHERE ci.cart_id = p_cart_id
           FOR UPDATE
      ) locked_items
      JOIN Cart_Items ci2 ON ci2.cart_item_id = locked_items.cart_item_id
      JOIN Vendor_Products vp2 ON vp2.vendor_product_id = ci2.vendor_product_id
      JOIN Vendors v2 ON v2.vendor_id = vp2.vendor_id
      JOIN Inventory inv2 ON inv2.vendor_product_id = vp2.vendor_product_id
     WHERE vp2.listing_status <> 'active'
        OR v2.account_status <> 'active'
        OR inv2.quantity_on_hand < ci2.quantity;

    IF v_invalid_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Checkout failed: one or more items are inactive, unavailable, or exceed stock.';
    END IF;

    -- Create parent order
    INSERT INTO Orders (user_id, shipping_address, order_date, completion_date, order_status)
    VALUES (p_user_id, TRIM(p_shipping_address), NOW(), NULL, 'pending');

    SET p_order_id = LAST_INSERT_ID();

    -- Create one vendor suborder per distinct vendor in the cart
    INSERT INTO Vendor_Orders (order_id, vendor_id, vendor_order_status)
    SELECT DISTINCT p_order_id, vp.vendor_id, 'pending'
      FROM Cart_Items ci
      JOIN Vendor_Products vp ON vp.vendor_product_id = ci.vendor_product_id
     WHERE ci.cart_id = p_cart_id;

    -- Insert line items with frozen purchase-time unit price and discount
    INSERT INTO Order_Items (
        vendor_order_id,
        vendor_product_id,
        quantity,
        unit_price_before_discount,
        discount_applied_per_unit
    )
    SELECT
        vo.vendor_order_id,
        ci.vendor_product_id,
        ci.quantity,
        vp.price,
        GREATEST(
            0.00,
            vp.price - COALESCE(
                fn_calculate_promotional_price(ci.vendor_product_id, CURDATE()),
                vp.price
            )
        )
      FROM Cart_Items ci
      JOIN Vendor_Products vp ON vp.vendor_product_id = ci.vendor_product_id
      JOIN Vendor_Orders vo ON vo.order_id = p_order_id
                           AND vo.vendor_id = vp.vendor_id
     WHERE ci.cart_id = p_cart_id;

    -- Create initial pending shipment record per vendor suborder
    INSERT INTO Shipments (vendor_order_id, shipment_status)
    SELECT vendor_order_id, 'pending'
      FROM Vendor_Orders
     WHERE order_id = p_order_id;

    -- Compute net order total from Order_Items
    SELECT COALESCE(
               SUM((unit_price_before_discount - discount_applied_per_unit) * quantity),
               0.00
           )
      INTO v_order_total
      FROM Order_Items oi
      JOIN Vendor_Orders vo ON vo.vendor_order_id = oi.vendor_order_id
     WHERE vo.order_id = p_order_id;

    IF p_payment_method = 'cash_on_delivery' THEN
        SET v_payment_status = 'pending';
        SET v_paid_at = NULL;
    ELSE
        SET v_payment_status = 'succeeded';
        SET v_paid_at = NOW();
    END IF;

    INSERT INTO Payments (
        order_id,
        payment_method,
        transaction_reference,
        amount_paid,
        payment_status,
        paid_at
    )
    VALUES (
        p_order_id,
        p_payment_method,
        p_transaction_reference,
        v_order_total,
        v_payment_status,
        v_paid_at
    );

    -- Record stock deductions (trigger updates Inventory.quantity_on_hand)
    INSERT INTO Inventory_Transactions (
        vendor_product_id,
        transaction_type,
        quantity_change,
        reason,
        transaction_date
    )
    SELECT
        ci.vendor_product_id,
        'sale_deduction',
        -ci.quantity,
        CONCAT('Order #', p_order_id),
        NOW()
      FROM Cart_Items ci
     WHERE ci.cart_id = p_cart_id;

    -- Mark shopping cart as checked_out
    UPDATE Shopping_Carts
       SET cart_status = 'checked_out'
     WHERE cart_id = p_cart_id;

    COMMIT;
END$$

DELIMITER ;