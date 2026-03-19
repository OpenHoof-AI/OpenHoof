---
summary: "CLI reference for `openhoof browser` (profiles, tabs, actions, Chrome MCP, and CDP)"
read_when:
  - You use `openhoof browser` and want examples for common tasks
  - You want to control a browser running on another machine via a node host
  - You want to attach to your local signed-in Chrome via Chrome MCP
title: "browser"
---

# `openhoof browser`

Manage OpenHoof’s browser control server and run browser actions (tabs, snapshots, screenshots, navigation, clicks, typing).

Related:

- Browser tool + API: [Browser tool](/tools/browser)

## Common flags

- `--url <gatewayWsUrl>`: Gateway WebSocket URL (defaults to config).
- `--token <token>`: Gateway token (if required).
- `--timeout <ms>`: request timeout (ms).
- `--browser-profile <name>`: choose a browser profile (default from config).
- `--json`: machine-readable output (where supported).

## Quick start (local)

```bash
openhoof browser profiles
openhoof browser --browser-profile openhoof start
openhoof browser --browser-profile openhoof open https://example.com
openhoof browser --browser-profile openhoof snapshot
```

## Profiles

Profiles are named browser routing configs. In practice:

- `openhoof`: launches or attaches to a dedicated OpenHoof-managed Chrome instance (isolated user data dir).
- `user`: controls your existing signed-in Chrome session via Chrome DevTools MCP.
- custom CDP profiles: point at a local or remote CDP endpoint.

```bash
openhoof browser profiles
openhoof browser create-profile --name work --color "#FF5A36"
openhoof browser create-profile --name chrome-live --driver existing-session
openhoof browser delete-profile --name work
```

Use a specific profile:

```bash
openhoof browser --browser-profile work tabs
```

## Tabs

```bash
openhoof browser tabs
openhoof browser open https://docs.openhoof.ai
openhoof browser focus <targetId>
openhoof browser close <targetId>
```

## Snapshot / screenshot / actions

Snapshot:

```bash
openhoof browser snapshot
```

Screenshot:

```bash
openhoof browser screenshot
```

Navigate/click/type (ref-based UI automation):

```bash
openhoof browser navigate https://example.com
openhoof browser click <ref>
openhoof browser type <ref> "hello"
```

## Existing Chrome via MCP

Use the built-in `user` profile, or create your own `existing-session` profile:

```bash
openhoof browser --browser-profile user tabs
openhoof browser create-profile --name chrome-live --driver existing-session
openhoof browser create-profile --name brave-live --driver existing-session --user-data-dir "~/Library/Application Support/BraveSoftware/Brave-Browser"
openhoof browser --browser-profile chrome-live tabs
```

This path is host-only. For Docker, headless servers, Browserless, or other remote setups, use a CDP profile instead.

## Remote browser control (node host proxy)

If the Gateway runs on a different machine than the browser, run a **node host** on the machine that has Chrome/Brave/Edge/Chromium. The Gateway will proxy browser actions to that node (no separate browser control server required).

Use `gateway.nodes.browser.mode` to control auto-routing and `gateway.nodes.browser.node` to pin a specific node if multiple are connected.

Security + remote setup: [Browser tool](/tools/browser), [Remote access](/gateway/remote), [Tailscale](/gateway/tailscale), [Security](/gateway/security)
