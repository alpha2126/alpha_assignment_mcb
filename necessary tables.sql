CREATE TABLE Suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(50),
    contact_name VARCHAR(50),
    address VARCHAR(100),
    town_village VARCHAR(50), -- Extracted from address
    contact_number VARCHAR(50),
    email VARCHAR(50)
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_ref VARCHAR(20),
    order_date DATE,
    supplier_id INT,
    total_amount DECIMAL(15,2),
    description VARCHAR(100),
    status VARCHAR(20),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

CREATE TABLE Order_Lines (
    order_line_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    line_amount DECIMAL(15,2),
    description VARCHAR(100),
    status VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

CREATE TABLE Invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    invoice_ref VARCHAR(20),
    invoice_date DATE,
    status VARCHAR(20),
    hold_reason VARCHAR(50),
    amount DECIMAL(15,2),
    description VARCHAR(100),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);