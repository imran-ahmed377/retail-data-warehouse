-- Very Basic Synapse Setup - No Constraints, No Complexity

CREATE TABLE DimCustomer
(
    CustomerKey INT,
    CustomerID NVARCHAR(50),
    CustomerName NVARCHAR(200),
    City NVARCHAR(100),
    Region NVARCHAR(100)
);
CREATE TABLE DimProduct
(
    ProductKey INT,
    ProductID NVARCHAR(50),
    ProductName NVARCHAR(200),
    Category NVARCHAR(100),
    Price DECIMAL(10,2)
);
CREATE TABLE FactSales
(
    SalesKey INT,
    SaleID NVARCHAR(50),
    CustomerKey INT,
    ProductKey INT,
    Quantity INT,
    TotalAmount DECIMAL(10,2)
);

INSERT INTO DimCustomer
VALUES
    (1, 'CUST001', 'John Smith', 'Toronto', 'Ontario');
INSERT INTO DimCustomer
VALUES
    (2, 'CUST002', 'Sarah Johnson', 'Vancouver', 'British Columbia');
INSERT INTO DimCustomer
VALUES
    (3, 'CUST003', 'Michael Chen', 'Calgary', 'Alberta');
INSERT INTO DimCustomer
VALUES
    (4, 'CUST004', 'Emma Davis', 'Montreal', 'Quebec');
INSERT INTO DimCustomer
VALUES
    (5, 'CUST005', 'Robert Wilson', 'Winnipeg', 'Manitoba');

INSERT INTO DimProduct
VALUES
    (1, 'PROD001', 'Laptop', 'Electronics', 999.99);
INSERT INTO DimProduct
VALUES
    (2, 'PROD002', 'Office Chair', 'Furniture', 299.99);
INSERT INTO DimProduct
VALUES
    (3, 'PROD003', 'Desk Lamp', 'Accessories', 49.99);
INSERT INTO DimProduct
VALUES
    (4, 'PROD004', 'Monitor', 'Electronics', 399.99);
INSERT INTO DimProduct
VALUES
    (5, 'PROD005', 'Keyboard', 'Accessories', 79.99);

INSERT INTO FactSales
VALUES
    (1, 'SALE001', 1, 1, 2, 1999.98);
INSERT INTO FactSales
VALUES
    (2, 'SALE002', 2, 2, 1, 299.99);
INSERT INTO FactSales
VALUES
    (3, 'SALE003', 3, 3, 5, 249.95);
INSERT INTO FactSales
VALUES
    (4, 'SALE004', 4, 4, 1, 399.99);
INSERT INTO FactSales
VALUES
    (5, 'SALE005', 5, 5, 3, 239.97);

SELECT *
FROM DimCustomer;
SELECT *
FROM DimProduct;
SELECT *
FROM FactSales;
