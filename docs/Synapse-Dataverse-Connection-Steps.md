# Azure Synapse to Dataverse Connection Guide

## Quick Reference for Phase 3 Implementation

### Prerequisites Checklist

Before connecting Synapse to Dataverse, ensure:
- [ ] Synapse workspace is fully deployed
- [ ] Dedicated SQL pool is created and running
- [ ] You have Dataverse environment details:
  - Organization URL: `https://retail-analytics-dev.crm.dynamics.com/`
  - Table names: `new_customer`, `new_product`, `new_sales`
- [ ] SQL admin credentials saved (username: `sqladmin`, password: [yours])

---

## Method 1: Connect via Synapse Studio (Recommended for Learning)

### Step 1: Open Synapse Studio

1. Go to **Azure Portal** → Your Synapse workspace
2. Click **Open Synapse Studio** (or navigate to https://web.azuresynapse.net)
3. Wait for the interface to load

### Step 2: Create Linked Service to Dataverse

1. Click **Manage** (left sidebar icon that looks like a plug)
2. Click **Linked services**
3. Click **+ New**
4. Search for **"Dataverse"** or **"Common Data Service"**
5. Select **Common Data Service (Dataverse)** or **Dynamics 365 / Common Data Service**

#### Configuration Options:

**Option A: Service Principal (Recommended for Production)**
```
Name: LinkedService_Dataverse_Prod
Organization URI: https://retail-analytics-dev.crm.dynamics.com/
Authentication Type: Service Principal
Service Principal ID: [Your Azure App Registration ID]
Service Principal Key: [Your App Secret]
Tenant ID: 12f933b3-3d61-4b19-9a4d-689021de8cc9
```

**Option B: Managed Identity (If available in your Synapse)**
```
Name: LinkedService_Dataverse_Managed
Organization URI: https://retail-analytics-dev.crm.dynamics.com/
Authentication Type: Managed Identity
```

**Option C: Account Key / Connection String**
```
Use a shared account that has access to Dataverse
(Simpler for testing, not recommended for production)
```

6. Click **Test connection** to verify
7. If successful, click **Create**

### Step 3: Create Source Datasets

In **Integrate** section, create 3 datasets:

#### Dataset 1: Customer Source

1. Click **Integrate** → **+ New** → **Dataset**
2. Search for **"Dataverse"** → Select it
3. Configuration:
   ```
   Name: Dataset_Customer_Source
   Linked Service: LinkedService_Dataverse_Prod
   Entity: new_customers (or select from dropdown)
   ```
4. Click **OK**

#### Dataset 2: Product Source

Repeat with:
```
Name: Dataset_Product_Source
Entity: new_products
```

#### Dataset 3: Sales Source

Repeat with:
```
Name: Dataset_Sales_Source
Entity: new_sales
```

### Step 4: Create Sink Datasets (SQL Pool)

Create 3 datasets pointing to your SQL pool tables:

#### Dataset 1: DimCustomer Sink

1. Click **Integrate** → **+ New** → **Dataset**
2. Search for **"Azure Synapse Analytics"** → Select it
3. Configuration:
   ```
   Name: Dataset_DimCustomer_Sink
   Linked Service: [Your SQL Pool Connection]
   Table: [dbo].[DimCustomer]
   ```
4. Click **OK**

#### Dataset 2: DimProduct Sink

```
Name: Dataset_DimProduct_Sink
Table: [dbo].[DimProduct]
```

#### Dataset 3: FactSales Sink

```
Name: Dataset_FactSales_Sink
Table: [dbo].[FactSales]
```

### Step 5: Create Copy Pipeline

1. Click **Integrate** → **+ New** → **Pipeline**
2. Name it: `Pipeline_DV_to_Synapse`

#### Add Copy Activity 1: Customer

1. Drag **Copy data** activity onto canvas
2. Name it: `Copy_Customer`
3. **Source tab:**
   - Dataset: `Dataset_Customer_Source`
4. **Sink tab:**
   - Dataset: `Dataset_DimCustomer_Sink`
5. **Mapping tab:**
   - Auto-detect or manually map:
     - `new_customerid` → `CustomerID`
     - `new_name` → `CustomerName`
     - `new_city` → `City`
     - `new_region` → `Region`

#### Add Copy Activity 2: Product

Repeat with:
```
Source: Dataset_Product_Source
Sink: Dataset_DimProduct_Sink

Mapping:
new_productid → ProductID
new_productname → ProductName
new_category → Category
new_price → Price
```

#### Add Copy Activity 3: Sales

Repeat with:
```
Source: Dataset_Sales_Source
Sink: Dataset_FactSales_Sink

Mapping:
new_saleid → SaleID
new_saledate → SaleDateKey
new_quantity → Quantity
new_totalamount → TotalAmount

For lookup mappings (customer/product):
You may need to use Data Flow for complex Join logic
Or handle in post-load SQL scripts
```

### Step 6: Set Pipeline Dependencies

Ensure dimensions load before facts:

1. **Click and drag** from `Copy_Customer` activity → `Copy_Sales`
2. **Click and drag** from `Copy_Product` activity → `Copy_Sales`

This creates a dependency so Sales only runs after both dimensions complete.

### Step 7: Run the Pipeline

1. Click **Debug** (or Publish first, then Trigger)
2. Monitor execution:
   - Green checkmark = Activity succeeded
   - Red X = Activity failed
3. Click **Output** to see rows copied

---

## Method 2: Connect via Azure Data Factory (Alternative)

If you want to manage pipelines separately from Synapse:

### Create ADF Instance

1. Azure Portal → **Create resource** → **Data Factory**
2. Configure same linked services and datasets
3. Create pipelines with same copy activities
4. Schedule pipelines to run on a schedule (daily, hourly, etc.)

---

## Validation Queries (Run in Synapse SQL Pool)

After pipeline succeeds, verify data:

### Row Count Validation

```sql
SELECT 
    'DimCustomer' AS TableName, COUNT(*) AS RowCount
FROM [dbo].[DimCustomer]
UNION ALL
SELECT 'DimProduct', COUNT(*) FROM [dbo].[DimProduct]
UNION ALL
SELECT 'FactSales', COUNT(*) FROM [dbo].[FactSales];
```

**Expected Output:**
```
DimCustomer    5
DimProduct     5
FactSales      5
```

### Sample Data Query

```sql
SELECT TOP 5
    DC.[CustomerName],
    DP.[ProductName],
    FS.[Quantity],
    FS.[TotalAmount]
FROM [dbo].[FactSales] FS
INNER JOIN [dbo].[DimCustomer] DC ON FS.[CustomerKey] = DC.[CustomerKey]
INNER JOIN [dbo].[DimProduct] DP ON FS.[ProductKey] = DP.[ProductKey];
```

### Referential Integrity Check

```sql
-- Ensure all foreign keys point to valid dimension records
SELECT 
    'Missing Customer References' AS Issue,
    COUNT(*) AS Count
FROM [dbo].[FactSales]
WHERE [CustomerKey] NOT IN (SELECT [CustomerKey] FROM [dbo].[DimCustomer])

UNION ALL

SELECT 
    'Missing Product References',
    COUNT(*)
FROM [dbo].[FactSales]
WHERE [ProductKey] NOT IN (SELECT [ProductKey] FROM [dbo].[DimProduct]);
```

**Expected Output:** All counts should be 0

---

## Troubleshooting

| Problem | Cause | Solution |
|---|---|---|
| Cannot find Dataverse in dataset dropdown | Linked service not created | Create linked service first |
| Copy activity fails with 403 | Authentication denied | Check Dataverse credentials and Synapse permissions |
| Rows not appearing in sink | Copy succeeded but no data | Check table doesn't have constraints; run manual insert test |
| Foreign key violations in FactSales | Dimension data not loaded first | Reorder activities; ensure dimensions complete first |
| Duplicate row error | Multiple executions | Check for unique constraints; truncate tables before rerun |

---

## Next Steps After Connection

1. ✅ Create SQL pool and warehouse schema
2. ✅ Connect Synapse to Dataverse
3. ✅ Run ETL pipeline
4. **Now:** Create Power BI reports (Phase 4)

---

## Reference Links

- Dataverse REST API: https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/overview
- Synapse Analytics: https://learn.microsoft.com/en-us/azure/synapse-analytics/
- Copy Activity in Synapse: https://learn.microsoft.com/en-us/azure/synapse-analytics/data-integration/concepts-data-factory-differences

