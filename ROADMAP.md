# Roadmap

This roadmap shows the current direction for the `cloud-projects` monorepo.

## ✨ Current focus

- ✅ Centralize shared Terraform modules in `infrastructure-modules/`
- ✅ Implement Azure Key Vault automated key rotation
- ✅ Use shared Azure modules for Key Vault, Cosmos DB, Function App, Event Grid, and Monitoring
- ✅ Add documentation and contributor guidance
- ✅ Add GitHub release automation

## 🎯 Next milestones

- [ ] Add CI validation for Terraform across shared modules and project roots
- [ ] Add end-to-end tests for the Azure key rotation project
- [ ] Expand support for AWS self-healing infrastructure
- [ ] Add module registry or remote module publishing workflow
- [ ] Improve cross-project documentation and examples

## 🚀 Future possibilities

- Multi-cloud reusable infrastructure patterns
- Automated environment promotion (dev → staging → prod)
- Module versioning strategy and changelog generation
- More project templates under `cloud-learning/`

## 🤝 How to contribute to the roadmap

- Open an issue for a new feature or improvement.
- Label issues with `good-first-issue` when they are beginner-friendly.
- Suggest updates to this roadmap via PR.
