---
summary: "CLI reference for `openhoof setup` (initialize config + workspace)"
read_when:
  - You’re doing first-run setup without full CLI onboarding
  - You want to set the default workspace path
title: "setup"
---

# `openhoof setup`

Initialize `~/.openhoof/openhoof.json` and the agent workspace.

Related:

- Getting started: [Getting started](/start/getting-started)
- CLI onboarding: [Onboarding (CLI)](/start/wizard)

## Examples

```bash
openhoof setup
openhoof setup --workspace ~/.openhoof/workspace
```

To run onboarding via setup:

```bash
openhoof setup --wizard
```
