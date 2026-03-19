---
summary: "CLI reference for `openhoof logs` (tail gateway logs via RPC)"
read_when:
  - You need to tail Gateway logs remotely (without SSH)
  - You want JSON log lines for tooling
title: "logs"
---

# `openhoof logs`

Tail Gateway file logs over RPC (works in remote mode).

Related:

- Logging overview: [Logging](/logging)

## Examples

```bash
openhoof logs
openhoof logs --follow
openhoof logs --json
openhoof logs --limit 500
openhoof logs --local-time
openhoof logs --follow --local-time
```

Use `--local-time` to render timestamps in your local timezone.
