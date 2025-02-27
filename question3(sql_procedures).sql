DELIMITER //

CREATE PROCEDURE MigrateBCMOrderMgt()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_order_ref, v_supplier_name, v_contact_name, v_address, v_contact_number, v_email, v_order_desc, v_order_status, v_line_amount, v_invoice_ref, v_hold_reason, v_invoice_desc,v_status VARCHAR(100);
    DECLARE v_order_date, v_invoice_date VARCHAR(20);
    DECLARE v_total_amount, v_invoice_amount VARCHAR(20);
    DECLARE v_supplier_id, v_order_id INT;
    
    DECLARE cur CURSOR FOR SELECT * FROM BCM_ORDER_MGT;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_order_ref, v_order_date, v_supplier_name, v_contact_name, v_address, v_contact_number, v_email, v_total_amount, v_order_desc, v_order_status, v_line_amount, v_invoice_ref, v_invoice_date, v_status, v_hold_reason, v_invoice_amount, v_invoice_desc;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Insert or get Supplier
        INSERT INTO Suppliers (supplier_name, contact_name, address, town_village, contact_number, email)
        SELECT v_supplier_name, v_contact_name, v_address, SUBSTRING_INDEX(SUBSTRING_INDEX(v_address, ',', -2), ',', 1), v_contact_number, v_email
        ON DUPLICATE KEY UPDATE supplier_id = LAST_INSERT_ID(supplier_id);
        SET v_supplier_id = LAST_INSERT_ID();

        -- Insert Order
        INSERT INTO Orders (order_ref, order_date, supplier_id, total_amount, description, status)
        VALUES (v_order_ref, STR_TO_DATE(v_order_date, '%d-%b-%Y'), v_supplier_id, CAST(REPLACE(v_total_amount, ',', '') AS DECIMAL(15,2)), v_order_desc, v_order_status);
        SET v_order_id = LAST_INSERT_ID();

        -- Insert Order Line
        IF v_line_amount IS NOT NULL THEN
            INSERT INTO Order_Lines (order_id, line_amount, description, status)
            VALUES (v_order_id, CAST(REPLACE(v_line_amount, ',', '') AS DECIMAL(15,2)), v_order_desc, v_order_status);
        END IF;

        -- Insert Invoice
        IF v_invoice_ref IS NOT NULL THEN
            INSERT INTO Invoices (order_id, invoice_ref, invoice_date, status, hold_reason, amount, description)
            VALUES (v_order_id, v_invoice_ref, STR_TO_DATE(v_invoice_date, '%d-%b-%Y'), v_status, v_hold_reason, CAST(REPLACE(v_invoice_amount, ',', '') AS DECIMAL(15,2)), v_invoice_desc);
        END IF;
    END LOOP;
    CLOSE cur;
END //

DELIMITER ;

CALL MigrateBCMOrderMgt();

select * from invoices;
select * from order_lines;
select * from suppliers;
select * from orders;