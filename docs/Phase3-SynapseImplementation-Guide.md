# Phase 3: Azure Synapse Analytics - Complete Implementation Guide

## Overview

**Phase 3** transforms your **operational data** (Dataverse) into **analytical data** (Synapse warehouse).

This guide covers:
1. ✓ Understanding warehouse architecture
2. ✓ Connecting Synapse to Dataverse
3. ✓ Building fact/dimension tables (star schema)
4. ✓ Creating ETL pipelines
5. ✓ Loading and validating data

---

## Part 1: Warehouse Architecture Concepts

### Operational vs Analytical Data

**Dataverse (Operational - OLTP)**
- Optimized for **transactions** (insert/update individual records)
- Normalized (no redundancy)
- Many tables joined together
- Real-time updates
- Example: A customer creates a sale record

**Synapse (Analytical - OLAP)**
- Optimized for **analysis** (read large aggregates)
- Denormalized (controlled redundancy)
- Star schema (facts + dimensions)
- Batch updates (nightly loads)
- Example: "Total sales by region and product"

### Star Schema Design

```
                    DimDate
                      |
                      |
    DimCustomer ---- FactSales ---- DimProduct
        |              |              |
    Customer ID    Sale ID        Product ID
    Name           Quantity       Name
    City           Total Amount   Category
    Region         Sale Date      Price
                   Customer ID
                   Product ID
```

**Why Star Schema?**
- ✓ Fast aggregations (sums, counts by dimension)
- ✓ Clear business logic (fact vs dimension)
- ✓ Supports drill-down analysis (dimension hierarchies)
- ✓ Easy for BI tools (Power BI, Tableau)

### Fact vs Dimension Tables

**Fact Table (FactSales)**
- Stores **measurements/metrics** (quantitative data)
- Quantity, Total Amount, Revenue
- Foreign keys to dimensions
- Additive (can sum them)
- Grows the fastest (one row per transaction)

**Dimension Table (DimCustomer, DimProduct)**
- Stores **descriptive attributes** (qualitative data)
- Customer Name, City, Region
- Primary key
- Non-additive (doesn't make sense to sum)
- Relatively small and stable

---

## Part 2: Connecting Synapse to Dataverse

### Prerequisites
- ✓ Synapse workspace created and deployed
- ✓ Dataverse environment with data
- ✓ SQL credentials (sqladmin + password you set)

### Step 1: Create Linked Service from Synapse to Dataverse

**What is a Linked Service?**
A connection configuration that allows Synapse to authenticate to external services (Dataverse).

#### Via Azure Portal:

1. Open your **Synapse workspace** in Azure Portal
2. Click **Manage** (left menu) → **Linked services**
3. Click **+ New**
4. Search for **"Common Data Service"** or **"Power Platform"**
5. Select **Common Data Service (Dataverse)**
6. Fill in:
   - **Name:** `LinkedService_Dataverse` (or any name)
   - **Organization URI:** `https://retail-analytics-dev.crm.dynamics.com/`
   - **Authentication type:** **Service Principal**
   - **Service principal ID:** [Your Azure app registration ID]
   - **Tenant ID:** `12f933b3-3d61-4b19-9a4d-689021de8cc9`
   - **Service principal key:** [Your service principal secret]
7. Click **Create**

**Note:** For simplicity, you can authenticate with your **user account** instead of service principal during testing. Ask Synapse to use "Personal authentication" if available.

#### Via PowerShell (Alternative):

```powershell
# Create linked service programmatically
$linkedServiceBody = @{
    "name" = "LinkedService_Dataverse"
    "properties" = @{
        "type" = "CommonDataServiceForApps"
        "typeProperties" = @{
            "deploymentType" = "Online"
            "organizationUri" = "https://retail-analytics-dev.crm.dynamics.com/"
            "authenticationType" = "ServicePrincipal"
            "servicePrincipalId" = "[your-service-principal-id]"
            "servicePrincipalCredential" = @{
                "type" = "SecureString"
                "value" = "[your-service-principal-secret]"
            }
            "tenantId" = "12f933b3-3d61-4b19-9a4d-689021de8cc9"
        }
    }
}
```

### Step 2: Create Datasets

**What are Datasets?**
They define the structure of data in Dataverse or Synapse that you want to copy.

#### Dataverse Source Datasets:

1. Create 3 datasets (in Synapse → Integrate):
   - `Dataset_Customer_Source` (points to Dataverse Customer table)
   - `Dataset_Product_Source` (points to Dataverse Product table)
   - `Dataset_Sales_Source` (points to Dataverse Sales table)

2. For each dataset:
   - Type: **Common Data Service for Apps**
   - Linked service: `LinkedService_Dataverse`
   - Entity name: `new_customers`, `new_products`, `new_sales`
   - Import schema

#### Synapse Sink Datasets:

1. Create 3 datasets for warehouse tables:
   - `Dataset_DimCustomer_Sink` (points to DimCustomer in SQL pool)
   - `Dataset_DimProduct_Sink` (points to DimProduct in SQL pool)
   - `Dataset_FactSales_Sink` (points to FactSales in SQL pool)

2. For each dataset:
   - Type: **Azure Synapse Analytics**
   - Linked service: Your Synapse SQL pool connection
   - Table name: `DimCustomer`, `DimProduct`, `FactSales`

---

## Part 3: Building Fact & Dimension Tables in Synapse

### Create the Warehouse Schema

#### Step 1: Create Synapse SQL Pool Databases

Open **Synapse Studio** (from your workspace):
1. Click **Data** (left menu)
2. Click **SQL pool** dropdown → Your dedicated SQL pool
3. Open **New SQL script**

#### Step 2: Create Dimension Tables

Run these SQL scripts in your Synapse SQL pool:

**Create DimCustomer:**
```sql
CREATE TABLE [dbo].[DimCustomer]
(
    [CustomerKey] INT IDENTITY(1,1) PRIMARY KEY,
    [CustomerID] NVARCHAR(50) NOT NULL,
    [CustomerName] NVARCHAR(200),
    [City] NVARCHAR(100),
    [Region] NVARCHAR(100),
    [LoadDate] DATETIME DEFAULT GETDATE(),
    [UpdateDate] DATETIME DEFAULT GETDATE()
);

-- Create unique constraint on natural key
ALTER TABLE [dbo].[DimCustomer]
ADD CONSTRAINT UQ_Customer_ID UNIQUE([CustomerID]);
```

**Create DimProduct:**
```sql
CREATE TABLE [dbo].[DimProduct]
(
    [ProductKey] INT IDENTITY(1,1) PRIMARY KEY,
    [ProductID] NVARCHAR(50) NOT NULL,
    [ProductName] NVARCHAR(200),
    [Category] NVARCHAR(100),
    [Price] DECIMAL(10, 2),
    [LoadDate] DATETIME DEFAULT GETDATE(),
    [UpdateDate] DATETIME DEFAULT GETDATE()
);

ALTER TABLE [dbo].[DimProduct]
ADD CONSTRAINT UQ_Product_ID UNIQUE([ProductID]);
```

**Create DimDate (Optional but powerful):**
```sql
CREATE TABLE [dbo].[DimDate]
(
    [DateKey] INT PRIMARY KEY,
    [Date] DATE NOT NULL,
    [Year] INT,
    [Month] INT,
    [MonthName] NVARCHAR(20),
    [Quarter] INT,
    [DayOfWeek] INT,
    [DayName] NVARCHAR(20)
);
```

#### Step 3: Create Fact Table

**Create FactSales:**
```sql
CREATE TABLE [dbo].[FactSales]
(
    [SalesKey] INT IDENTITY(1,1) PRIMARY KEY,
    [SaleID] NVARCHAR(50) NOT NULL,
    [CustomerKey] INT NOT NULL,
    [ProductKey] INT NOT NULL,
    [SaleDateKey] INT,
    [Quantity] INT,
    [TotalAmount] DECIMAL(10, 2),
    [LoadDate] DATETIME DEFAULT GETDATE(),
    [UpdateDate] DATETIME DEFAULT GETDATE(),
    
    -- Foreign keys
    CONSTRAINT FK_FactSales_Customer FOREIGN KEY ([CustomerKey]) 
        REFERENCES [dbo].[DimCustomer]([CustomerKey]),
    CONSTRAINT FK_FactSales_Product FOREIGN KEY ([ProductKey]) 
        REFERENCES [dbo].[DimProduct]([ProductKey])
);

ALTER TABLE [dbo].[FactSales]
ADD CONSTRAINT UQ_Sale_ID UNIQUE([SaleID]);
```

### Understanding the Schema

**Keys:**
- `CustomerKey`, `ProductKey` — Surrogate keys (auto-increment integers)
- `CustomerID`, `ProductID` — Natural keys (business identifiers from Dataverse)
- Foreign keys link fact to dimensions

**Benefits:**
- ✓ Fast joins on integer keys
- ✓ Small fact table (integers vs long strings)
- ✓ Support for slowly changing dimensions (dimension versioning)

---

## Part 4: Creating ETL Pipelines

### What is an ETL Pipeline?

**Extract** → Extract data from source (Dataverse)
**Transform** → Clean, aggregate, business logic
**Load** → Insert into warehouse (Synapse)

### Pipeline Architecture

```
Dataverse Tables
    ↓
  Extract
    ↓
Transform (SQL scripts)
    ↓
   Load
    ↓
Synapse Star Schema
```

### Create Copy Activities in Synapse

#### Step 1: Create Pipeline

1. Open **Synapse Studio** → **Integrate**
2. Click **+ New** → **Pipeline**
3. Name it: `Pipeline_Dataverse_to_Synapse`

#### Step 2: Add Copy Activity for Customer

1. Drag **Copy data** activity onto canvas
2. Name it: `CopyActivity_Customer`
3. Configuration:
   - **Source:** `Dataset_Customer_Source` (linked to Dataverse)
   - **Sink:** `Dataset_DimCustomer_Sink` (SQL pool table)
   - **Mapping:**
     - `new_customerid` → `CustomerID`
     - `new_name` → `CustomerName`
     - `new_city` → `City`
     - `new_region` → `Region`

#### Step 3: Add Copy Activity for Product

1. Drag another **Copy data** activity
2. Name it: `CopyActivity_Product`
3. Configuration:
   - **Source:** `Dataset_Product_Source`
   - **Sink:** `Dataset_DimProduct_Sink`
   - **Mapping:**
     - `new_productid` → `ProductID`
     - `new_productname` → `ProductName`
     - `new_category` → `Category`
     - `new_price` → `Price`

#### Step 4: Add Copy Activity for Sales

1. Drag another **Copy data** activity
2. Name it: `CopyActivity_Sales`
3. Configuration:
   - **Source:** `Dataset_Sales_Source`
   - **Sink:** `Dataset_FactSales_Sink`
   - **Mapping:**
     - `new_saleid` → `SaleID`
     - `new_saledate` → `SaleDateKey` (will be transformed)
     - `new_quantity` → `Quantity`
     - `new_totalamount` → `TotalAmount`
     - Lookups (customer/product IDs) → Foreign key mapping

#### Step 5: Set Dependencies

Order matters! Dimensions must load BEFORE facts:

1. **CopyActivity_Customer** → no dependencies
2. **CopyActivity_Product** → no dependencies
3. **CopyActivity_Sales** → depends on **both** Customer and Product activities

In Synapse: Drag from Customer activity to Sales activity (creates dependency arrow)

### Data Transformation with SQL

After copy activities, add a **SQL script activity** to:
- Calculate derived columns
- Aggregate data
- Apply business logic

**Example: Calculate Sales Summary**

```sql
-- Create summary table
CREATE TABLE [dbo].[SalesSummary]
(
    [SalesYear] INT,
    [SalesMonth] INT,
    [Region] NVARCHAR(100),
    [Category] NVARCHAR(100),
    [TotalQuantity] INT,
    [TotalAmount] DECIMAL(10, 2),
    [AvgOrderValue] DECIMAL(10, 2),
    [OrderCount] INT
);

-- Populate summary
INSERT INTO [dbo].[SalesSummary]
SELECT
    YEAR([dbo].[FactSales].[LoadDate]) AS SalesYear,
    MONTH([dbo].[FactSales].[LoadDate]) AS SalesMonth,
    [dbo].[DimCustomer].[Region],
    [dbo].[DimProduct].[Category],
    SUM([dbo].[FactSales].[Quantity]) AS TotalQuantity,
    SUM([dbo].[FactSales].[TotalAmount]) AS TotalAmount,
    AVG([dbo].[FactSales].[TotalAmount]) AS AvgOrderValue,
    COUNT(*) AS OrderCount
FROM [dbo].[FactSales]
INNER JOIN [dbo].[DimCustomer] ON [FactSales].[CustomerKey] = [DimCustomer].[CustomerKey]
INNER JOIN [dbo].[DimProduct] ON [FactSales].[ProductKey] = [DimProduct].[ProductKey]
GROUP BY
    YEAR([dbo].[FactSales].[LoadDate]),
    MONTH([dbo].[FactSales].[LoadDate]),
    [dbo].[DimCustomer].[Region],
    [dbo].[DimProduct].[Category];
```

---

## Part 5: Running and Validating the Pipeline

### Execute Pipeline

1. Open your pipeline in Synapse Studio
2. Click **Debug** (or **Publish** → **Trigger** → **Trigger now**)
3. Monitor execution → Watch all activities complete

### Validation Queries

Run these in Synapse to verify data loaded correctly:

```sql
-- Check row counts
SELECT 'DimCustomer' AS TableName, COUNT(*) AS RowCount FROM [dbo].[DimCustomer]
UNION ALL
SELECT 'DimProduct', COUNT(*) FROM [dbo].[DimProduct]
UNION ALL
SELECT 'FactSales', COUNT(*) FROM [dbo].[FactSales];

-- Check sample data with joins
SELECT 
    DC.[CustomerName],
    DP.[ProductName],
    FS.[Quantity],
    FS.[TotalAmount]
FROM [dbo].[FactSales] FS
INNER JOIN [dbo].[DimCustomer] DC ON FS.[CustomerKey] = DC.[CustomerKey]
INNER JOIN [dbo].[DimProduct] DP ON FS.[ProductKey] = DP.[ProductKey];

-- Check data integrity (no nulls in keys)
SELECT 
    (SELECT COUNT(*) FROM [dbo].[FactSales] WHERE [CustomerKey] IS NULL) AS NullCustomerKeys,
    (SELECT COUNT(*) FROM [dbo].[FactSales] WHERE [ProductKey] IS NULL) AS NullProductKeys;
```

### Expected Results

✓ DimCustomer: 5 rows
✓ DimProduct: 5 rows
✓ FactSales: 5 rows
✓ All foreign key constraints satisfied
✓ Sample query shows customer, product, quantity, and amount data

---

## Part 6: OLAP Analysis Examples

Now that you have the warehouse, demonstrate OLAP analysis:

**Drill-Down Example:**
```sql
-- Year → Month → Region → Category
SELECT 
    YEAR(FS.[LoadDate]) AS Year,
    MONTH(FS.[LoadDate]) AS Month,
    DC.[Region],
    DP.[Category],
    SUM(FS.[TotalAmount]) AS TotalSales,
    COUNT(*) AS NumberOfTransactions
FROM [dbo].[FactSales] FS
INNER JOIN [dbo].[DimCustomer] DC ON FS.[CustomerKey] = DC.[CustomerKey]
INNER JOIN [dbo].[DimProduct] DP ON FS.[ProductKey] = DP.[ProductKey]
GROUP BY 
    YEAR(FS.[LoadDate]),
    MONTH(FS.[LoadDate]),
    DC.[Region],
    DP.[Category]
ORDER BY Year, Month, Region, Category;
```

**Top Products by Region:**
```sql
SELECT TOP 10
    DC.[Region],
    DP.[ProductName],
    DP.[Category],
    SUM(FS.[Quantity]) AS TotalQuantitySold,
    SUM(FS.[TotalAmount]) AS TotalRevenue,
    AVG(FS.[TotalAmount]) AS AvgOrderValue
FROM [dbo].[FactSales] FS
INNER JOIN [dbo].[DimCustomer] DC ON FS.[CustomerKey] = DC.[CustomerKey]
INNER JOIN [dbo].[DimProduct] DP ON FS.[ProductKey] = DP.[ProductKey]
GROUP BY 
    DC.[Region],
    DP.[ProductName],
    DP.[Category]
ORDER BY TotalRevenue DESC;
```

---

## Summary

**Phase 3 teaches:**
- ✅ Operational vs analytical architectures
- ✅ Star schema design (facts + dimensions)
- ✅ ETL automation
- ✅ Data warehouse aggregations
- ✅ OLAP drill-down analysis

**What's Next (Phase 4):**
- Connect Power BI to Synapse
- Create semantic layer (business measures)
- Build analytical dashboards

---

## Troubleshooting

| Issue | Solution |
|---|---|
| Cannot connect to Dataverse | Check linked service auth; verify org URI |
| Copy activity fails | Check dataset mappings; verify column names |
| Foreign key violations | Ensure dimensions load before facts |
| Slow queries | Add indexes on fact table join keys |
| Data mismatch | Validate source and sink row counts |

