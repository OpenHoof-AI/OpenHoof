---
summary: "CLI reference for `openhoof reset` (reset local state/config)"
read_when:
  - You want to wipe local state while keeping the CLI installed
  - You want a dry-run of what would be removed
title: "reset"
---

# `openhoof reset`

Reset local config/state (keeps the CLI installed).

```bash
openhoof backup create
openhoof reset
openhoof reset --dry-run
openhoof reset --scope config+creds+sessions --yes --non-interactive
```

Run `openhoof backup create` first if you want a restorable snapshot before removing local state.
