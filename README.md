# Retail Analytics Project - Azure Implementation

## Project Overview
A complete retail analytics solution demonstrating real-world data architecture:
- **Dataverse** → **Azure Synapse** → **OLAP/Warehouse** → **Semantic Layer** → **Power BI**

## Current Status
- [x] Phase 1: Foundation & Setup ✅
- [x] Phase 2: MS Dataverse (Tables & Data Model) ✅
- [ ] Phase 3: Azure Synapse (Analytics Warehouse) - **In Progress - Deployment underway**
- [ ] Phase 4: Power BI (Semantic Layer & Reporting)

## Project Structure

```
MS Dataverse/
├── 01-dataverse/          # Dataverse configuration & schema docs
├── 02-synapse/            # Synapse ETL pipelines & SQL schemas
├── 03-powerbi/            # Power BI reports & measures
├── scripts/               # PowerShell, Python, SQL scripts
├── data/                  # Sample data files
├── docs/                  # Architecture, guides, notes
├── configs/               # Connection strings, credentials (gitignore)
└── README.md              # This file
```

## Key Resources

**Subscription Details:**
- Subscription ID: cbcbc57d-0c75-47a0-b4ce-3f8ea945bad8
- Directory: University of Windsor (uwindsor.ca)
- Region Preference: East US
- Role: Owner

**Resource Group:**
- Name: rg-retail-analytics-dev
- Region: Central Canada
- Status: ✅ Created & Active

## Naming Conventions

| Resource Type | Pattern | Example |
|---|---|---|
| Resource Group | rg-{project}-{env} | rg-retail-analytics-dev |
| Synapse Workspace | syn-{project}-{env} | syn-retail-analytics-dev |
| SQL Pool | pool-{project}-{env} | pool-retail-analytics-dev |
| Storage Account | st{project}{env}{random} | stretailanalyticsdev1 |
| Dataverse Env | {project}-{env} | retail-analytics-dev |

## Learning Objectives

### Phase 1: Foundation
- Understand Azure subscription & resource management
- Learn resource naming conventions
- Set up local development environment

### Phase 2: Dataverse
- Create tables with business context
- Establish relationships (1-to-many)
- Work with lookup columns
- Import sample data

### Phase 3: Synapse (Analytics Layer) - In Progress
- Create Synapse workspace (deployment in progress)
- Understand star schema (facts + dimensions)
- Learn ETL/ELT automation
- Build fact and dimension tables
- Connect Dataverse to Synapse pipelines

**Documentation:**
- [Phase 3 Implementation Guide](docs/Phase3-SynapseImplementation-Guide.md) - Comprehensive concepts and architecture
- [Synapse Connection Steps](docs/Synapse-Dataverse-Connection-Steps.md) - Step-by-step connection guide
- [SQL Schema Scripts](scripts/Synapse-WarehouseSchema-Setup.sql) - Ready-to-run warehouse setup

### Phase 4: Power BI
- Create business measures
- Build semantic layer
- Design analytics visualizations
- Understand measure vs dimension

## Next Steps
1. ✅ Verify Azure student account
2. ⏳ Create resource group in Azure Portal
3. ⏳ Set up local development environment (Azure CLI, extensions)
4. ⏳ Verify everything is ready for Phase 2

---

