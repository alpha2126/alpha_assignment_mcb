DELIMITER //

CREATE PROCEDURE GetMedianOrderDetails()
BEGIN
    WITH RankedOrders AS (
        SELECT 
            order_id,
            total_amount,
            ROW_NUMBER() OVER (ORDER BY total_amount) AS rn,
            COUNT(*) OVER () AS cnt
        FROM Orders
        WHERE total_amount IS NOT NULL
    )
    SELECT 
        CAST(REPLACE(o.order_ref, 'PO', '') AS UNSIGNED) AS Order_Reference,
        UPPER(DATE_FORMAT(o.order_date, '%d-%b-%Y')) AS Order_Date,
        s.supplier_name AS Supplier_Name,
        FORMAT(o.total_amount, 2) AS Order_Total_Amount,
        o.status AS Order_Status,
        GROUP_CONCAT(i.invoice_ref SEPARATOR '|') AS Invoice_References
    FROM RankedOrders ro
    JOIN Orders o ON ro.order_id = o.order_id
    JOIN Suppliers s ON o.supplier_id = s.supplier_id
    LEFT JOIN Invoices i ON o.order_id = i.order_id
    WHERE ro.rn = FLOOR((ro.cnt + 1) / 2)
    GROUP BY o.order_id;
END //

DELIMITER ;

CALL GetMedianOrderDetails();