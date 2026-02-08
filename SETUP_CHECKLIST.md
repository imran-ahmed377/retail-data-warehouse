# Phase 1 Setup Checklist

Complete this checklist to finalize your foundation. Check off each item as you complete it.

## Azure Portal Setup

- [ ] **Subscription Verified**
  - Logged into Azure Portal
  - Confirmed subscription: `Azure for Students`
  - Subscription ID: cbcbc57d-0c75-47a0-b4ce-3f8ea945bad8
  - Role: Owner
  - Credit balance checked

- [ ] **Power Platform Access Verified**
  - Logged into Power Platform Admin Center (https://admin.powerplatform.microsoft.com)
  - Can see "Create Environment" option for Dataverse

- [x] **Resource Group Created**
  - Name: `rg-retail-analytics-dev`
  - Region: `Central Canada` ✅
  - Status: Deployed & visible in Resource Groups list ✅
  - Pinned to dashboard for quick access ✅

## Local Development Environment

- [ ] **Azure CLI Installed**
  - Open PowerShell/Command Prompt
  - Run: `az --version`
  - Result: Should show version number (e.g., "azure-cli 2.60.0")
  - **Install if missing:** https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows

- [ ] **Azure CLI Authenticated**
  - Run: `az login`
  - Browser opens, sign in with Azure student account
  - Run: `az account show`
  - Result: Should display your subscription details

- [ ] **PowerShell 7+ Installed** (Optional but recommended)
  - Open PowerShell
  - Run: `$PSVersionTable.PSVersion`
  - Result: Should show version 7.0 or higher
  - **Install if needed:** https://github.com/PowerShell/PowerShell/releases

- [ ] **VS Code Extensions Installed**
  - Open VS Code
  - Go to Extensions (Ctrl+Shift+X)
  - Install:
    - [ ] "Azure Tools" (Microsoft)
    - [ ] "Azure Synapse Analytics" (Microsoft)
    - [ ] "SQL Server (mssql)" (Microsoft)
    - [ ] "Power BI" (Microsoft)
  - Note: These help with IntelliSense and resource management

- [ ] **Project Folder Structure Created**
  - [ ] 01-dataverse/
  - [ ] 02-synapse/
  - [ ] 03-powerbi/
  - [ ] scripts/
  - [ ] data/
  - [ ] docs/
  - [ ] configs/
  - [ ] README.md ✅

## Documentation

- [ ] **Project README Created** ✅
  - Location: `/README.md`
  - Contains project overview, structure, and status

- [ ] **Naming Conventions Documented** ✅
  - Location: `/RESOURCE_NAMING.md`
  - Review and understand the patterns

- [ ] **Azure Info Documented**
  - Subscription ID noted
  - Region preference chosen
  - Resource group name finalized

## Verification

- [ ] **Azure CLI Can List Resources**
  - Run: `az group list --output table`
  - Result: Should show `rg-retail-analytics-dev`

- [ ] **Can Access Dataverse Environment Creator**
  - Go to https://admin.powerplatform.microsoft.com
  - Try to create a Dataverse environment (don't finish, just verify the button works)

- [ ] **VS Code Project Opens Correctly**
  - Open VS Code
  - File → Open Folder → Select your project folder
  - Verify all subfolders appear in Explorer

## Final Readiness Check

- [ ] All items above are checked ✅
- [ ] You have access to Azure Portal, Power Platform, and local development tools
- [ ] You understand naming conventions and will apply them
- [ ] You're ready to proceed with **Phase 2: MS Dataverse**

---

**When all items are complete, you're ready for Phase 2!**

Expected time: **30 minutes to 1 hour**

**Troubleshooting:**
- Azure CLI install issues? Check: https://learn.microsoft.com/en-us/cli/azure/troubleshoot
- Power Platform access issues? Check: https://powerapps.microsoft.com/support
- VS Code extensions not showing? Reload VS Code (Ctrl+Shift+P → Developer: Reload Window)
