---
summary: "Uninstall OpenHoof completely (CLI, service, state, workspace)"
read_when:
  - You want to remove OpenHoof from a machine
  - The gateway service is still running after uninstall
title: "Uninstall"
---

# Uninstall

Two paths:

- **Easy path** if `openhoof` is still installed.
- **Manual service removal** if the CLI is gone but the service is still running.

## Easy path (CLI still installed)

Recommended: use the built-in uninstaller:

```bash
openhoof uninstall
```

Non-interactive (automation / npx):

```bash
openhoof uninstall --all --yes --non-interactive
npx -y openhoof uninstall --all --yes --non-interactive
```

Manual steps (same result):

1. Stop the gateway service:

```bash
openhoof gateway stop
```

2. Uninstall the gateway service (launchd/systemd/schtasks):

```bash
openhoof gateway uninstall
```

3. Delete state + config:

```bash
rm -rf "${OPENHOOF_STATE_DIR:-$HOME/.openhoof}"
```

If you set `OPENHOOF_CONFIG_PATH` to a custom location outside the state dir, delete that file too.

4. Delete your workspace (optional, removes agent files):

```bash
rm -rf ~/.openhoof/workspace
```

5. Remove the CLI install (pick the one you used):

```bash
npm rm -g openhoof
pnpm remove -g openhoof
bun remove -g openhoof
```

6. If you installed the macOS app:

```bash
rm -rf /Applications/OpenHoof.app
```

Notes:

- If you used profiles (`--profile` / `OPENHOOF_PROFILE`), repeat step 3 for each state dir (defaults are `~/.openhoof-<profile>`).
- In remote mode, the state dir lives on the **gateway host**, so run steps 1-4 there too.

## Manual service removal (CLI not installed)

Use this if the gateway service keeps running but `openhoof` is missing.

### macOS (launchd)

Default label is `ai.openhoof.gateway` (or `ai.openhoof.<profile>`; legacy `com.openhoof.*` may still exist):

```bash
launchctl bootout gui/$UID/ai.openhoof.gateway
rm -f ~/Library/LaunchAgents/ai.openhoof.gateway.plist
```

If you used a profile, replace the label and plist name with `ai.openhoof.<profile>`. Remove any legacy `com.openhoof.*` plists if present.

### Linux (systemd user unit)

Default unit name is `openhoof-gateway.service` (or `openhoof-gateway-<profile>.service`):

```bash
systemctl --user disable --now openhoof-gateway.service
rm -f ~/.config/systemd/user/openhoof-gateway.service
systemctl --user daemon-reload
```

### Windows (Scheduled Task)

Default task name is `OpenHoof Gateway` (or `OpenHoof Gateway (<profile>)`).
The task script lives under your state dir.

```powershell
schtasks /Delete /F /TN "OpenHoof Gateway"
Remove-Item -Force "$env:USERPROFILE\.openhoof\gateway.cmd"
```

If you used a profile, delete the matching task name and `~\.openhoof-<profile>\gateway.cmd`.

## Normal install vs source checkout

### Normal install (install.sh / npm / pnpm / bun)

If you used `https://openhoof.ai/install.sh` or `install.ps1`, the CLI was installed with `npm install -g openhoof@latest`.
Remove it with `npm rm -g openhoof` (or `pnpm remove -g` / `bun remove -g` if you installed that way).

### Source checkout (git clone)

If you run from a repo checkout (`git clone` + `openhoof ...` / `bun run openhoof ...`):

1. Uninstall the gateway service **before** deleting the repo (use the easy path above or manual service removal).
2. Delete the repo directory.
3. Remove state + workspace as shown above.
