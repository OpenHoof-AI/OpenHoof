---
summary: "CLI reference for `openhoof devices` (device pairing + token rotation/revocation)"
read_when:
  - You are approving device pairing requests
  - You need to rotate or revoke device tokens
title: "devices"
---

# `openhoof devices`

Manage device pairing requests and device-scoped tokens.

## Commands

### `openhoof devices list`

List pending pairing requests and paired devices.

```
openhoof devices list
openhoof devices list --json
```

### `openhoof devices remove <deviceId>`

Remove one paired device entry.

```
openhoof devices remove <deviceId>
openhoof devices remove <deviceId> --json
```

### `openhoof devices clear --yes [--pending]`

Clear paired devices in bulk.

```
openhoof devices clear --yes
openhoof devices clear --yes --pending
openhoof devices clear --yes --pending --json
```

### `openhoof devices approve [requestId] [--latest]`

Approve a pending device pairing request. If `requestId` is omitted, OpenHoof
automatically approves the most recent pending request.

```
openhoof devices approve
openhoof devices approve <requestId>
openhoof devices approve --latest
```

### `openhoof devices reject <requestId>`

Reject a pending device pairing request.

```
openhoof devices reject <requestId>
```

### `openhoof devices rotate --device <id> --role <role> [--scope <scope...>]`

Rotate a device token for a specific role (optionally updating scopes).

```
openhoof devices rotate --device <deviceId> --role operator --scope operator.read --scope operator.write
```

### `openhoof devices revoke --device <id> --role <role>`

Revoke a device token for a specific role.

```
openhoof devices revoke --device <deviceId> --role node
```

## Common options

- `--url <url>`: Gateway WebSocket URL (defaults to `gateway.remote.url` when configured).
- `--token <token>`: Gateway token (if required).
- `--password <password>`: Gateway password (password auth).
- `--timeout <ms>`: RPC timeout.
- `--json`: JSON output (recommended for scripting).

Note: when you set `--url`, the CLI does not fall back to config or environment credentials.
Pass `--token` or `--password` explicitly. Missing explicit credentials is an error.

## Notes

- Token rotation returns a new token (sensitive). Treat it like a secret.
- These commands require `operator.pairing` (or `operator.admin`) scope.
- `devices clear` is intentionally gated by `--yes`.
- If pairing scope is unavailable on local loopback (and no explicit `--url` is passed), list/approve can use a local pairing fallback.

## Token drift recovery checklist

Use this when Control UI or other clients keep failing with `AUTH_TOKEN_MISMATCH` or `AUTH_DEVICE_TOKEN_MISMATCH`.

1. Confirm current gateway token source:

```bash
openhoof config get gateway.auth.token
```

2. List paired devices and identify the affected device id:

```bash
openhoof devices list
```

3. Rotate operator token for the affected device:

```bash
openhoof devices rotate --device <deviceId> --role operator
```

4. If rotation is not enough, remove stale pairing and approve again:

```bash
openhoof devices remove <deviceId>
openhoof devices list
openhoof devices approve <requestId>
```

5. Retry client connection with the current shared token/password.

Related:

- [Dashboard auth troubleshooting](/web/dashboard#if-you-see-unauthorized-1008)
- [Gateway troubleshooting](/gateway/troubleshooting#dashboard-control-ui-connectivity)
