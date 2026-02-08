-- Load CSV files from Azure Storage into Synapse

-- Clear existing data (optional - comment out if you want to keep old data)
DELETE FROM FactSales;
DELETE FROM DimProduct;
DELETE FROM DimCustomer;

-- Load Customer data
COPY INTO DimCustomer
FROM 'https://stretailanalyticsdev1.blob.core.windows.net/dataverse-exports/Customer.csv'
WITH
(FILE_TYPE = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

-- Load Product data
COPY INTO DimProduct
FROM 'https://stretailanalyticsdev1.blob.core.windows.net/dataverse-exports/Product.csv'
WITH
(FILE_TYPE = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

-- Load Sales data
COPY INTO FactSales
FROM 'https://stretailanalyticsdev1.blob.core.windows.net/dataverse-exports/Sales.csv'
WITH
(FILE_TYPE = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n');

-- Verify data loaded
    SELECT 'DimCustomer' AS TableName, COUNT(*) AS RecordCount
    FROM DimCustomer
UNION ALL
    SELECT 'DimProduct', COUNT(*)
    FROM DimProduct
UNION ALL
    SELECT 'FactSales', COUNT(*)
    FROM FactSales;
