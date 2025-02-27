DELIMITER //

CREATE PROCEDURE GetOrderSummaryByRegion()
BEGIN
    SELECT 
        s.town_village AS Region,
        CAST(REPLACE(o.order_ref, 'PO', '') AS UNSIGNED) AS Order_Reference,
        DATE_FORMAT(o.order_date, '%Y-%m') AS Order_Period,
        CONCAT(UPPER(LEFT(s.supplier_name, 1)), LOWER(SUBSTRING(s.supplier_name, 2))) AS Supplier_Name,
        FORMAT(o.total_amount, 2) AS Order_Total_Amount,
        o.status AS Order_Status,
        GROUP_CONCAT(DISTINCT i.invoice_ref) AS Invoice_Reference,
        FORMAT(SUM(i.amount), 2) AS Invoice_Total_Amount,
        CASE 
            WHEN COUNT(CASE WHEN i.status = 'Paid' THEN 1 END) = COUNT(i.invoice_ref) THEN 'No Action'
            WHEN COUNT(CASE WHEN i.status = 'Pending' THEN 1 END) > 0 THEN 'To follow up'
            WHEN COUNT(CASE WHEN i.status IS NULL THEN 1 END) > 0 THEN 'To verify'
            ELSE 'Unknown'
        END AS Action
    FROM Orders o
    JOIN Suppliers s ON o.supplier_id = s.supplier_id
    LEFT JOIN Invoices i ON o.order_id = i.order_id
    GROUP BY s.town_village, o.order_id
    ORDER BY s.town_village, o.total_amount DESC;
END //

DELIMITER ;

CALL GetOrderSummaryByRegion();