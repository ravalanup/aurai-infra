# Contributing to aurai-infra

## Principles
- **Infrastructure as code only.** No manual changes to shared environments.
- **No secrets in the repository.** Use Secrets Manager and the External Secrets Operator.
- **Small, reviewable changes.** One concern per pull request.
- **Production-shaped, prototype-scaled.** Keep patterns real; document what a larger rollout adds.

## Before opening a pull request
1. `make lint` passes (Helm).
2. `make tf-fmt` produces no changes and `make tf-validate ENV=dev|staging|prod` passes.
3. Any change to the shape of the platform updates `docs/architecture.md` and, if it alters a decision, an ADR in `aurai-docs`.
4. VPC CIDRs in Terraform and `networkPolicies.allowedIngressCIDRs` in Helm values still match.

## Conventions
- Terraform: formatted with `terraform fmt`, community modules pinned to a major version, no inline credentials.
- Helm: values documented in `values.yaml`, secrets referenced by name (`existingSecret`), never embedded outside `values-local.yaml`.
- Commit messages: imperative mood with a prefix (`feat:`, `fix:`, `docs:`, `chore:`, `ci:`).

## Reviews
Changes to `terraform/` and network policies need review from a second person. Production changes require a reviewed plan attached to the pull request.
