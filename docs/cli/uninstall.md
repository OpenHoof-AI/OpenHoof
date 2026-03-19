---
summary: "CLI reference for `openhoof uninstall` (remove gateway service + local data)"
read_when:
  - You want to remove the gateway service and/or local state
  - You want a dry-run first
title: "uninstall"
---

# `openhoof uninstall`

Uninstall the gateway service + local data (CLI remains).

```bash
openhoof backup create
openhoof uninstall
openhoof uninstall --all --yes
openhoof uninstall --dry-run
```

Run `openhoof backup create` first if you want a restorable snapshot before removing state or workspaces.
