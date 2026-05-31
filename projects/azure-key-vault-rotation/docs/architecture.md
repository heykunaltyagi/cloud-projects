# Azure Key Vault Rotation Architecture

This document describes the flow of the Azure Key Vault automated rotation solution implemented in `azure-key-vault-rotation`.

## High-level flow

```plaintext
Azure Key Vault
       ↓
  Event Grid
       ↓
Azure Function App
      / \
     /   \
    ↓     ↓
Event Hub  Cosmos DB
          ↓
     Azure Monitor
```

## Flow description

1. **Azure Key Vault**
   - The core vault stores keys and exposes events for key lifecycle activity.
   - When a key nears expiry or is updated, Key Vault emits events.

2. **Event Grid**
   - Event Grid subscribes to Key Vault events.
   - It filters and forwards key-related events to the Azure Function App.
   - This is the event-driven trigger point for rotation.

3. **Azure Function App**
   - Receives Key Vault events from Event Grid.
   - Contains the rotation logic written in Python.
   - Uses access to Key Vault and the Event Hub.
   - If rotation occurs, it writes audit data to Event Hub and rotation history to Cosmos DB.

4. **Azure Event Hub**
   - Collects audit records for each key rotation or related action.
   - Enables downstream analytics or processing of rotation events.

5. **Azure Cosmos DB**
   - Stores rotation history and metadata for audit/tracking.
   - Provides a persistent record of key rotation operations.

6. **Azure Monitor**
   - Watches the Function App execution.
   - Sends alerts when the rotation function fails or reports errors.

## Terraform modularization

The project now centralizes reusable infrastructure components in `infrastructure-modules/`:

- `azure_key_vault/`
- `azure_cosmos_db/`
- `azure_function_app/`
- `azure_event_grid/`
- `azure_monitoring/`

The root project consumes these shared modules to keep the implementation consistent and reusable.

## Notes

- Provider configuration is stored in `terraform/versions.tf`.
- Variables are kept in `terraform/variables.tf`.
- Data lookups are defined in `terraform/data.tf`.
- This markdown file is intentionally simple so it is easy to include in documentation and README references.
