---
summary: "CLI reference for `openhoof health` (gateway health endpoint via RPC)"
read_when:
  - You want to quickly check the running Gateway’s health
title: "health"
---

# `openhoof health`

Fetch health from the running Gateway.

```bash
openhoof health
openhoof health --json
openhoof health --verbose
```

Notes:

- `--verbose` runs live probes and prints per-account timings when multiple accounts are configured.
- Output includes per-agent session stores when multiple agents are configured.
