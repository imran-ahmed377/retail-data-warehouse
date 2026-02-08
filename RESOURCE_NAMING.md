# Azure Resource Naming Conventions

This document establishes naming conventions for all Azure resources in the Retail Analytics project.

## Rationale

Consistent naming prevents confusion, enables cost tracking, and scales across teams and environments.

## General Pattern

```
{resource-prefix}-{project}-{environment}-{sequence}
```

## Naming Rules

1. **Length:** 3-63 characters (varies by resource type)
2. **Case:** lowercase only
3. **Special characters:** hyphens (-) only (except storage accounts)
4. **No prefixes needed:** Resource type is self-evident in the portal

## Resource-Specific Patterns

### Compute & Analytics

| Resource | Pattern | Example | Notes |
|---|---|---|---|
| Resource Group | `rg-{project}-{env}` | `rg-retail-analytics-dev` | Contains all resources |
| Synapse Workspace | `syn-{project}-{env}` | `syn-retail-analytics-dev` | Must be unique globally |
| Dedicated SQL Pool | `pool-{project}-{env}` | `pool-retail-analytics-dev` | Within Synapse workspace |
| Integration Runtime | `ir-{project}-{env}` | `ir-retail-analytics-dev` | For data movement |

### Storage

| Resource | Pattern | Example | Notes |
|---|---|---|---|
| Storage Account | `st{project}{env}{seq}` | `stretailanalyticsdev1` | No hyphens; globally unique |
| Container | `{purpose}-{env}-data` | `raw-dev-data` | Describes data stage |
| File Share | `fs-{purpose}-{env}` | `fs-config-dev` | For shared configuration |

### Data Services

| Resource | Pattern | Example | Notes |
|---|---|---|---|
| Dataverse Env | `{project}-{env}-{seq}` | `retail-analytics-dev-01` | Portal naming; user-friendly |
| Data Factory | `adf-{project}-{env}` | `adf-retail-analytics-dev` | For ETL/ELT pipelines |

### Networking & Security

| Resource | Pattern | Example | Notes |
|---|---|---|---|
| Virtual Network | `vnet-{project}-{env}` | `vnet-retail-analytics-dev` | Uncommon for simple projects |
| Key Vault | `kv-{project}-{env}` | `kv-retail-analytics-dev` | For secrets & credentials |

## Tagging Strategy

All resources should be tagged with:

```
Environment: dev | staging | prod
Project: retail-analytics
Owner: your-name@email.com
CostCenter: learning | production
CreatedDate: YYYY-MM-DD
```

**Example:** Resource Group tags in Azure Portal:
```
Environment: dev
Project: retail-analytics
Owner: student@uwindsor.ca
CostCenter: learning
```

## Environment Suffixes

| Environment | Description | Typical Use |
|---|---|---|
| dev | Development | Learning, testing |
| staging | Staging | Pre-production validation |
| prod | Production | Live analytics |

For this project, use **dev** only.

## Sequencing

If you need multiple instances of the same resource:
- `rg-retail-analytics-dev-01`
- `rg-retail-analytics-dev-02`

(Rarely needed for this project.)

---

**Apply these conventions when creating any Azure resource.** This ensures maintainability and follows industry best practices.
