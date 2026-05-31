# Cloud Projects

This repository is a cloud infrastructure monorepo that centralizes reusable Terraform modules and hosts standalone cloud projects.

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [README](./README.md) | Overview & quick start |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | How to contribute |
| [ROADMAP.md](./ROADMAP.md) | Project roadmap |

### 🛠️ Project Usage Guides

| Project | Usage Guide |
|---------|------------|
| 📝 Overview | [USAGE.md](./USAGE.md) |
| 🔐 Azure Key Vault Rotation | [README.md](./projects/azure-key-vault-rotation/README.md) |
| ☁️ AWS Self-Healing Infrastructure | [README.md](./projects/aws-self-healing-infrastructure/README.md) |
| 🔧 Infrastructure Modules | [USAGE.md](./infrastructure-modules/USAGE.md) |
| 📚 Cloud Learning | [USAGE.md](./cloud-learning/USAGE.md) |

## 📁 Repository structure

```
projects/
  ├── azure-key-vault-rotation/
  └── aws-self-healing-infrastructure/    # planned
infrastructure-modules/           # shared Terraform modules
cloud-learning/
  ├── terraform-poc/              # planned
  ├── python-asyncio-demo/         # planned
  └── k8s-experiments/             # planned
```

## 🚀 Active projects

- `projects/azure-key-vault-rotation/`
  - Available Azure Key Vault key rotation project.
  - Deploys Terraform resources, Azure Functions, Event Grid, Event Hub, Cosmos DB, and monitoring.
  - Uses shared modules in `infrastructure-modules/`.

- `projects/aws-self-healing-infrastructure/`
  - Planned AWS self-healing infrastructure project.
  - Placeholder directory for future AWS IaC and automation.

- `infrastructure-modules/`
  - Central shared Terraform modules repository.
  - Hosts reusable Azure modules for key vault, Cosmos DB, function app, event grid, and monitoring.

- `cloud-learning/`
  - Experimental projects and proofs of concept.
  - Contains placeholder folders for future learning work.

## 🏗️ Infrastructure Modules

```
infrastructure-modules/
├── modules/
│   ├── azure_key_vault/              🔐 Secure key storage with rotation-ready keys and policies
│   ├── azure_cosmos_db/              🗄️ NoSQL database for audit history and rotation logs
│   ├── azure_function_app/           ⚡ Serverless compute for key rotation automation
│   ├── azure_event_grid/             📡 Event routing from Key Vault to Function App
│   └── azure_monitoring/             📊 Alerts and monitoring for rotation failures
```