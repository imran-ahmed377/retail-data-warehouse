# Retail Analytics Project - Complete Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Why This Project?](#why-this-project)
3. [Technology Stack](#technology-stack)
4. [Project Architecture](#project-architecture)
5. [Step-by-Step Guide](#step-by-step-guide)
6. [What We Built](#what-we-built)
7. [Key Lessons Learned](#key-lessons-learned)
8. [How to Resume This Project](#how-to-resume-this-project)

---

## Project Overview

**Goal:** Build a complete retail analytics system that moves data from a business application (Dataverse) through a data warehouse (Azure Synapse) and finally into a business intelligence tool (Power BI) for analysis.

**Real-World Scenario:** Imagine a retail company that sells products. They need to:
- Track customers who buy products
- Record every sale that happens
- Analyze sales trends (which products sell most, which customers spend most, etc.)

This project demonstrates exactly how that happens in modern enterprise systems.

**Project Completion Status:** 
- ✅ Phase 1-3 Complete (Data loaded into warehouse)
- ⏳ Phase 4 Pending (Power BI visualization layer)
- 🛑 Paused due to Azure subscription expiration (needs upgrade to pay-as-you-go)

---

## Why This Project?

### The Business Problem
A business has transactional data scattered around. They need a central place to analyze it:
- Customer data (who buys from us?)
- Product data (what do we sell?)
- Sales data (how much did we sell?)

### The Solution
Build a **data warehouse** that:
1. Pulls data from the live business system (Dataverse)
2. Organizes it in a structured way (Synapse warehouse)
3. Provides fast analytics on top of it (Power BI)

This is called the **ETL + Analytics** pattern and is used by every major tech company (Google, Amazon, Netflix, etc.).

---

## Technology Stack

### 1. **Microsoft Dataverse** (Source System)
- **What:** Cloud database where business applications store live data
- **Why:** Companies often use Dynamics 365 and model-driven Power Apps which store data in Dataverse
- **In this project:** Stores Customer, Product, and Sales tables with 5 records each

### 2. **Azure Synapse** (Data Warehouse)
- **What:** Specialized database optimized for analyzing large amounts of historical data
- **Why:** Regular databases are for transactions; Synapse is for analytics (can query millions of rows instantly)
- **In this project:** Stores dimension tables (DimCustomer, DimProduct) and fact table (FactSales)

### 3. **Azure Storage** (Data Lake)
- **What:** Cloud file storage (like Dropbox, but for data engineering)
- **Why:** Intermediate storage for CSV files during data transfer
- **In this project:** Stores Customer.csv, Product.csv, Sales.csv files

### 4. **Power BI** (Analytics/Visualization)
- **What:** Tool to create dashboards and reports from data
- **Why:** Business users can't read database tables; they need charts, graphs, dashboards
- **In this project:** Will connect to Synapse and create retail sales dashboard (Phase 4)

---

## Project Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    RETAIL ANALYTICS PIPELINE                    │
└─────────────────────────────────────────────────────────────────┘

PHASE 1: SOURCE SYSTEM
┌──────────────────────────────────────────────────────────────────┐
│  Microsoft Dataverse (Transactional Database)                   │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │  Customer       │  │  Product        │  │  Sales         │  │
│  │  (5 records)    │  │  (5 records)    │  │  (5 records)   │  │
│  └─────────────────┘  └─────────────────┘  └────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
         │                    │                      │
         │ EXTRACT            │                      │
         └────────────────────┴──────────────────────┘
                              │
                              ▼
PHASE 2: DATA MOVEMENT
┌──────────────────────────────────────────────────────────────────┐
│  Azure Storage (CSV Files)                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │ Customer.csv     │  │ Product.csv      │  │ Sales.csv    │  │
│  │ (5 rows)         │  │ (5 rows)         │  │ (5 rows)     │  │
│  └──────────────────┘  └──────────────────┘  └──────────────┘  │
└──────────────────────────────────────────────────────────────────┘
         │                    │                      │
         │ LOAD               │                      │
         └────────────────────┴──────────────────────┘
                              │
                              ▼
PHASE 3: DATA WAREHOUSE (PROJECT CURRENT STAGE)
┌──────────────────────────────────────────────────────────────────┐
│  Azure Synapse (Analytical Database)                             │
│  ┌─────────────────────┐  ┌────────────────────────────────┐   │
│  │  DIMENSION TABLES   │  │  FACT TABLE                    │   │
│  ├─────────────────────┤  ├────────────────────────────────┤   │
│  │ DimCustomer (5)     │  │ FactSales (5)                  │   │
│  │ DimProduct (5)      │  │ - Links to DimCustomer & Product
│  │                     │  │ - Contains quantities & amounts │   │
│  └─────────────────────┘  └────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
         │                                           │
         │ ANALYZE (SQL queries on warehouse)       │
         └───────────────────┬──────────────────────┘
                             │
                             ▼
PHASE 4: VISUALIZATION (NOT YET STARTED)
┌──────────────────────────────────────────────────────────────────┐
│  Power BI (Business Intelligence)                                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  DASHBOARD: Retail Sales Overview                        │   │
│  │  ├─ Total Sales by Customer (pie chart)                 │   │
│  │  ├─ Top Selling Products (bar chart)                    │   │
│  │  ├─ Revenue Trend (line chart)                          │   │
│  │  └─ Sales by Region (map)                               │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

### Key Concept: Dimension vs Fact Tables

**Dimension Table (DimCustomer, DimProduct)**
- Describes "who" and "what"
- Changes slowly (customer info updated weekly/monthly)
- Relatively small (thousands-millions of rows)
- Example: Name, City, Region, Price, Category

**Fact Table (FactSales)**
- Records "what happened" (transactions)
- Changes frequently (new sales every second)
- Very large (billions of rows in real systems)
- References dimensions via keys (CustomerKey, ProductKey)
- Contains measurements (Quantity, TotalAmount)

**Why separate?** Efficiency. If we stored customer name 1000 times for 1000 sales, we'd waste space. Instead, store name once in DimCustomer, reference it by key in FactSales.

---

## Step-by-Step Guide

### PHASE 1: Set Up Azure Environment (COMPLETED ✅)

#### Step 1.1: Create Azure Subscription
- Created free trial: Azure for Students (provided by University of Windsor)
- Subscription ID: `cbcbc57d-0c75-47a0-b4ce-3f8ea945bad8`
- Tenant: `12f933b3-3d61-4b19-9a4d-689021de8cc9`

#### Step 1.2: Create Resource Group
- Resource Group: `rg-retail-analytics-dev`
- Region: Central Canada (closest to Toronto)
- Purpose: Container for all Azure resources (like a folder)

#### Step 1.3: Install Development Tools
- Azure CLI: Command-line tool to manage Azure resources
- Visual Studio Code: Code editor
- Extensions: Azure extensions for managing resources from VS Code

---

### PHASE 2: Create Source System in Dataverse (COMPLETED ✅)

#### Step 2.1: Create Customer Table
**Purpose:** Store information about who buys from us

**Fields:**
- CustomerID (CUST001, CUST002, etc.) - unique business key
- CustomerName (John Smith, Sarah Johnson, etc.)
- City (Toronto, Vancouver, etc.)
- Region (Ontario, British Columbia, etc.)

**Sample Data (5 customers):**
```
CUST001 | John Smith    | Toronto    | Ontario
CUST002 | Sarah Johnson | Vancouver  | British Columbia
CUST003 | Michael Chen  | Calgary    | Alberta
CUST004 | Emma Davis    | Montreal   | Quebec
CUST005 | Robert Wilson | Winnipeg   | Manitoba
```

#### Step 2.2: Create Product Table
**Purpose:** Store what we sell

**Fields:**
- ProductID (PROD001, PROD002, etc.)
- ProductName (Laptop, Office Chair, etc.)
- Category (Electronics, Furniture, Accessories)
- Price (999.99, 299.99, etc.)

**Sample Data (5 products):**
```
PROD001 | Laptop        | Electronics | 999.99
PROD002 | Office Chair  | Furniture   | 299.99
PROD003 | Desk Lamp     | Accessories | 49.99
PROD004 | Monitor       | Electronics | 399.99
PROD005 | Keyboard      | Accessories | 79.99
```

#### Step 2.3: Create Sales Table
**Purpose:** Record every transaction

**Fields:**
- SaleID (SALE001, SALE002, etc.)
- CustomerID (reference to who bought)
- ProductID (reference to what was sold)
- Quantity (how many units)
- TotalAmount (price × quantity)

**Sample Data (5 sales):**
```
SALE001 | CUST001 | PROD001 | 2 units | $1,999.98
SALE002 | CUST002 | PROD002 | 1 unit  | $299.99
SALE003 | CUST003 | PROD003 | 5 units | $249.95
SALE004 | CUST004 | PROD004 | 1 unit  | $399.99
SALE005 | CUST005 | PROD005 | 3 units | $239.97
```

**How Created:** Via Power Apps Copilot (low-code interface), not manually writing SQL

---

### PHASE 3: Create Data Warehouse in Synapse (COMPLETED ✅)

#### Step 3.1: Create Synapse Workspace
**What is a workspace?** Container that holds all analytics resources

**Configuration:**
- Name: `syn-retail-analytics-dev`
- Region: Central Canada
- Storage Account: Auto-created (`stretailanalyticsdev1`)

**Result:** Empty analytics environment ready to receive data

#### Step 3.2: Create Dedicated SQL Pool
**What is a dedicated pool?** The actual database engine optimized for analytics

**Configuration:**
- Name: `SalesPool`
- Type: Dedicated SQL Pool (as opposed to Serverless)
- Size: DW100c (DW = Data Warehouse, 100c = 100 compute units, smallest/cheapest)
- Purpose: Where we store dimension and fact tables

**Why Dedicated?** 
- Serverless is read-only (can't create tables)
- Dedicated lets us CREATE TABLE, INSERT data, run analytics
- We chose DW100c (smallest) to minimize costs for learning

#### Step 3.3: Create Warehouse Schema
**What is schema?** Blueprint of database structure (table definitions)

**Dimension Tables:**
```sql
CREATE TABLE DimCustomer (
    CustomerKey INT,           -- Surrogate key (1, 2, 3...)
    CustomerID NVARCHAR(50),   -- Business key (CUST001, CUST002...)
    CustomerName NVARCHAR(200),
    City NVARCHAR(100),
    Region NVARCHAR(100)
)

CREATE TABLE DimProduct (
    ProductKey INT,
    ProductID NVARCHAR(50),
    ProductName NVARCHAR(200),
    Category NVARCHAR(100),
    Price DECIMAL(10,2)
)
```

**Fact Table:**
```sql
CREATE TABLE FactSales (
    SalesKey INT,              -- Unique sale identifier
    SaleID NVARCHAR(50),       -- Business key
    CustomerKey INT,           -- Reference to DimCustomer
    ProductKey INT,            -- Reference to DimProduct
    Quantity INT,
    TotalAmount DECIMAL(10,2)
)
```

**Key Difference from Dataverse:**
- Dataverse: Normalized for transactions (lots of relationships, foreign keys)
- Synapse: Denormalized for analytics (simple, flat, fast queries)
- Synapse constraints minimal (no IDENTITY, no enforced PRIMARY KEYS) because it's analytical, not transactional

#### Step 3.4: Load Data Into Warehouse (COMPLETED ✅)
**Method Used:** BasicSetup.sql with simple INSERT statements
```sql
INSERT INTO DimCustomer VALUES (1, 'CUST001', 'John Smith', 'Toronto', 'Ontario')
INSERT INTO DimCustomer VALUES (2, 'CUST002', 'Sarah Johnson', 'Vancouver', 'British Columbia')
-- ... repeat for all 5 customers
-- ... same for Product and Sales
```

**Result:** 15 rows total (5 per table) loaded successfully in 5.294 seconds

---

### PHASE 4: Move Data from Dataverse to Synapse (IN PROGRESS ⏳)

#### Why Two Databases?
- **Dataverse:** Live production database (optimized for daily operations)
- **Synapse:** Historical analytics database (optimized for reporting)
- **Reality:** In production, you'd run this every night to sync new sales data

#### Step 4.1: Extract from Dataverse (COMPLETED ✅)
**Method:** Since Dataverse export failed, manually created CSV files
```
Customer.csv  → 5 customer records
Product.csv   → 5 product records
Sales.csv     → 5 sales records
```

#### Step 4.2: Store in Azure Storage (COMPLETED ✅)
**Location:** Azure Blob Storage container `dataverse-exports`

**URLs:**
- https://stretailanalyticsdev1.blob.core.windows.net/dataverse-exports/Customer.csv
- https://stretailanalyticsdev1.blob.core.windows.net/dataverse-exports/Product.csv
- https://stretailanalyticsdev1.blob.core.windows.net/dataverse-exports/Sales.csv

**Why intermediate storage?**
- Synapse can't directly connect to Dataverse due to MFA limitations
- CSV in blob storage is universal (can come from anywhere)
- Realistic pattern: Extract → Store → Load

#### Step 4.3: Load into Synapse (PENDING ⏳)
**Method:** COPY command (Synapse-native bulk loading)

```sql
COPY INTO DimCustomer
FROM 'https://stretailanalyticsdev1.blob.core.windows.net/dataverse-exports/Customer.csv'
WITH (FILE_TYPE = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n')
```

**Status:** Script created (SynapseCopyFromCSV.sql) but execution paused due to Azure subscription expiration

---

### PHASE 4 (Incomplete): Create Power BI Reports

#### Step 4.1: Connect Power BI to Synapse
```
Power BI Desktop
  ↓
Get Data
  ↓
Azure Synapse
  ↓
Server: syn-retail-analytics-dev.sql.azuresynapse.net
Database: SalesPool
```

#### Step 4.2: Create Data Model
- Import DimCustomer, DimProduct, FactSales
- Create relationships:
  - FactSales.CustomerKey → DimCustomer.CustomerKey
  - FactSales.ProductKey → DimProduct.ProductKey

#### Step 4.3: Build Dashboard
- **Total Sales by Customer:** GROUP BY CustomerName, SUM(TotalAmount)
- **Top Products:** ORDER BY Quantity DESC, LIMIT 5
- **Revenue by Category:** GROUP BY Category, SUM(TotalAmount)
- **Sales Trend:** GROUP BY SaleID, visualize timeline

---

## What We Built

### File Structure
```
c:\Users\Asus\Desktop\Skills Upgrade\MS Dataverse\
├── PROJECT_DOCUMENTATION.md        ← You are here
├── scripts/
│   ├── BasicSetup.sql              ← Creates tables, inserts data
│   ├── SynapseCopyFromCSV.sql       ← Loads CSVs into Synapse
│   └── [Other script versions]      ← Historical attempts
├── data/
│   ├── Customer.csv                ← 5 customer records
│   ├── Product.csv                 ← 5 product records
│   └── Sales.csv                   ← 5 sales records
└── docs/
    └── [Architecture diagrams, notes]
```

### Azure Resources Created
| Resource | Name | Status | Cost |
|----------|------|--------|------|
| Resource Group | rg-retail-analytics-dev | Active | Free |
| Synapse Workspace | syn-retail-analytics-dev | Disabled* | $0.52/hour |
| Dedicated SQL Pool | SalesPool (DW100c) | Disabled* | Included |
| Storage Account | stretailanalyticsdev1 | Disabled* | $0.02/GB |
| Dataverse Environment | retail-analytics-dev | Active | Included |

*Currently disabled due to Azure subscription expiration

### Data Assets Created
| Asset | Records | Size | Status |
|-------|---------|------|--------|
| DimCustomer | 5 | ~200 bytes | ✅ In Synapse |
| DimProduct | 5 | ~250 bytes | ✅ In Synapse |
| FactSales | 5 | ~300 bytes | ✅ In Synapse |
| Customer.csv | 5 | ~300 bytes | ✅ In Storage |
| Product.csv | 5 | ~250 bytes | ✅ In Storage |
| Sales.csv | 5 | ~300 bytes | ✅ In Storage |

---

## Key Lessons Learned

### Technical Lessons

#### 1. **Azure Synapse Constraint Limitations**
**Problem:** Standard SQL Server constraints don't work in Synapse

**Failed Attempts:**
- ❌ `IDENTITY(1,1)` auto-increment → Not supported
- ❌ `PRIMARY KEY` enforced → Not supported
- ❌ `FOREIGN KEY` inline → Not supported
- ❌ `UNIQUE` enforced → Not supported
- ❌ `CREATE TABLE [dbo].TableName` → Schema syntax not supported

**Solution:** Use informational constraints only
```sql
-- Instead of:
PRIMARY KEY (CustomerKey)

-- Use:
NONCLUSTERED PRIMARY KEY (CustomerKey) NOT ENFORCED
-- This tells optimization engine about relationships but doesn't enforce them
```

**Why?** Synapse's columnar storage isn't designed for relational constraints. It assumes data is already clean.

#### 2. **SQL Pool Types Matter**
**Mistake:** Tried running `CREATE TABLE` on serverless SQL pool

**Lesson:** 
- **Serverless:** Read-only, great for querying data already loaded
- **Dedicated:** Read/write, required for creating tables and loading data
- **Choice:** Always use Dedicated for ETL, Serverless for ad-hoc queries

#### 3. **Authentication with MFA is Complex**
**Problem:** Service Principal authentication failed with MFA requirement

**Root Cause:** Synapse supports non-interactive flows only; your account has MFA enforced

**Solutions Explored:**
1. ❌ Service Principal Key → Requires non-MFA account (not available)
2. ❌ Office 365 Auth → Still can't trigger interactive prompt
3. ✅ CSV + Storage → Avoids authentication entirely

**Lesson:** Enterprise authentication is layered. When automated systems can't authenticate interactively, use intermediate storage or service accounts.

#### 4. **Dataverse Export Limitations**
**Problem:** Dataverse UI export feature didn't work

**Alternative Solution:** Manually created CSV with same data structure

**Lesson:** When UI tools fail, go back to basics (manual file creation, CLI commands, APIs)

### Project Management Lessons

#### 1. **Preview/Test Before Production**
Each SQL script iteration taught us what works in Synapse. Debugging early saved time later.

#### 2. **Cloud Costs Require Monitoring**
Azure credits expire. Set budget alerts in production to avoid surprises.

#### 3. **Document as You Go**
This document would have been much harder to write if I hadn't tracked progress throughout.

#### 4. **Separation of Concerns**
- Dataverse = Transactional (OLTP)
- Synapse = Analytical (OLAP)
- Power BI = Visualization (BI)

Each layer has a specific job and different technology fits each job best.

---

## How to Resume This Project

### Current State
- ✅ Source data loaded in Dataverse (15 records across 3 tables)
- ✅ Warehouse schema created in Synapse (3 tables ready)
- ✅ Data initially loaded via SQL (BasicSetup.sql, 5.294 seconds)
- ✅ CSVs created and uploaded to Azure Storage
- ⏳ COPY commands ready but not executed (Azure disabled)
- ❌ Power BI visualization not started

### To Continue Project (When Azure is Upgraded)

#### Step 1: Upgrade Azure Subscription
1. Go to Azure Portal
2. Click "Upgrade" on your subscription
3. Select "Pay-as-You-Go"
4. Add payment method (credit/debit card)
5. Services automatically resume within minutes

#### Step 2: Load CSV Data into Synapse
1. Open Synapse Studio (syn-retail-analytics-dev)
2. Go to "Develop" → "SQL scripts"
3. Open or paste: `SynapseCopyFromCSV.sql`
4. Select "SalesPool" database
5. Click "Run"
6. Verify: Should show 5 rows per table loaded

#### Step 3: Build Power BI Dashboard
1. Download Power BI Desktop (free)
2. Connect to Synapse:
   - Server: `syn-retail-analytics-dev.sql.azuresynapse.net`
   - Database: `SalesPool`
3. Import tables: DimCustomer, DimProduct, FactSales
4. Create relationships on foreign keys
5. Build visualizations:
   - Total Sales (card)
   - Sales by Customer (pie)
   - Top Products (bar)
   - Revenue by Region (map)

#### Step 4 (Optional): Automate with ETL Pipeline
- Create Synapse pipeline with:
  - Copy activity: Dataverse → Blob Storage (nightly)
  - Copy activity: Blob Storage → Synapse (nightly)
  - Trigger: Run at 2 AM daily
- This would keep warehouse automatically synced with live Dataverse

### Estimated Times (When Upgrading)
- Azure upgrade: 5 minutes
- COPY data load: 2 minutes
- Power BI dashboard: 30 minutes
- Total to completion: ~45 minutes

### Cost Estimate (Pay-as-You-Go)
For your project:
- Synapse DW100c: ~$1.50/hour (pause when not using)
- Storage: ~$0.02/GB/month
- Power BI: Free (individual/development edition)
- **Monthly cost:** ~$30-50 (if pool runs 24/7)
- **Your cost:** ~$5-10/month (if pool runs 1-2 hours/day during development)

### Important Files to Keep
- `PROJECT_DOCUMENTATION.md` ← This file
- `scripts/BasicSetup.sql` → Working baseline
- `scripts/SynapseCopyFromCSV.sql` → Next step
- `data/*.csv` → Source for COPY command
- `scripts/` → All SQL scripts for reference

### Troubleshooting

**If COPY command fails with "cannot find file":**
- Check blob storage URLs are correct
- Verify CSVs uploaded successfully to Azure Storage
- Ensure SalesPool is online and connected

**If Power BI can't connect to Synapse:**
- Verify SalesPool is online
- Check firewall rules (may need to add your IP)
- Try "Test connection" first

**If you see "DW100c is paused":**
- Resume the pool: Synapse Studio → SQL Pools → SalesPool → Resume
- Wait 5 minutes for startup
- Try again

---

## Summary

You've built the **foundation of a enterprise data analytics system**:

1. **Source System (Dataverse):** Live transactional data
2. **Data Movement (CSV + Storage):** Extract and transport layer
3. **Data Warehouse (Synapse):** Central repository for analysis
4. **Visualization (TBD Power BI):** Insights and dashboards

This architecture scales from 5 records (your project) to billions of records (real retail companies). The concepts you've learned—dimensional modeling, ETL, OLAP databases, cloud compute—are exactly what Netflix, Amazon, Google use daily.

**Next action:** Upgrade Azure subscription, complete COPY load, build Power BI dashboard.

---

*Last Updated: February 8, 2026*
*Project: Retail Analytics Pipeline*
*Status: Phase 3 Complete, Paused for Azure Upgrade*
