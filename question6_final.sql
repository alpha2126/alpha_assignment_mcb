DELIMITER //

CREATE PROCEDURE GetSupplierOrdersByMonth()
BEGIN
    SELECT 
        DATE_FORMAT(o.order_date, '%M %Y') AS Month,
        s.supplier_name AS Supplier_Name,
        s.contact_name AS Supplier_Contact_Name,
        SUBSTRING_INDEX(s.contact_number, ',', 1) AS Supplier_Contact_No_1, -- Assuming first number
        TRIM(SUBSTRING_INDEX(s.contact_number, ',', -1)) AS Supplier_Contact_No_2, -- Assuming second number
        COUNT(o.order_id) AS Total_Orders,
        FORMAT(SUM(o.total_amount), 2) AS Order_Total_Amount
    FROM Orders o
    JOIN Suppliers s ON o.supplier_id = s.supplier_id
    WHERE o.order_date BETWEEN '2024-01-01' AND '2024-08-31'
    GROUP BY DATE_FORMAT(o.order_date, '%M %Y'), s.supplier_id
    ORDER BY Total_Orders DESC;
END //

DELIMITER ;

CALL GetSupplierOrdersByMonth();