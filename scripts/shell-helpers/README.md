# HoofDock <!-- omit in toc -->

Stop typing `docker-compose` commands. Just type `hoofdock-start`.

Inspired by Simon Willison's [Running OpenHoof in Docker](https://til.simonwillison.net/llms/openhoof-docker).

- [Quickstart](#quickstart)
- [Available Commands](#available-commands)
  - [Basic Operations](#basic-operations)
  - [Container Access](#container-access)
  - [Web UI \& Devices](#web-ui--devices)
  - [Setup \& Configuration](#setup--configuration)
  - [Maintenance](#maintenance)
  - [Utilities](#utilities)
- [Common Workflows](#common-workflows)
  - [Check Status and Logs](#check-status-and-logs)
  - [Set Up WhatsApp Bot](#set-up-whatsapp-bot)
  - [Troubleshooting Device Pairing](#troubleshooting-device-pairing)
  - [Fix Token Mismatch Issues](#fix-token-mismatch-issues)
  - [Permission Denied](#permission-denied)
- [Requirements](#requirements)

## Quickstart

**Install:**

```bash
mkdir -p ~/.hoofdock && curl -sL https://raw.githubusercontent.com/openhoof/openhoof/main/scripts/shell-helpers/hoofdock-helpers.sh -o ~/.hoofdock/hoofdock-helpers.sh
```

```bash
echo 'source ~/.hoofdock/hoofdock-helpers.sh' >> ~/.zshrc && source ~/.zshrc
```

**See what you get:**

```bash
hoofdock-help
```

On first command, HoofDock auto-detects your OpenHoof directory:

- Checks common paths (`~/openhoof`, `~/workspace/openhoof`, etc.)
- If found, asks you to confirm
- Saves to `~/.hoofdock/config`

**First time setup:**

```bash
hoofdock-start
```

```bash
hoofdock-fix-token
```

```bash
hoofdock-dashboard
```

If you see "pairing required":

```bash
hoofdock-devices
```

And approve the request for the specific device:

```bash
hoofdock-approve <request-id>
```

## Available Commands

### Basic Operations

| Command            | Description                     |
| ------------------ | ------------------------------- |
| `hoofdock-start`   | Start the gateway               |
| `hoofdock-stop`    | Stop the gateway                |
| `hoofdock-restart` | Restart the gateway             |
| `hoofdock-status`  | Check container status          |
| `hoofdock-logs`    | View live logs (follows output) |

### Container Access

| Command                   | Description                                    |
| ------------------------- | ---------------------------------------------- |
| `hoofdock-shell`          | Interactive shell inside the gateway container |
| `hoofdock-cli <command>`  | Run OpenHoof CLI commands                      |
| `hoofdock-exec <command>` | Execute arbitrary commands in the container    |

### Web UI & Devices

| Command                 | Description                                |
| ----------------------- | ------------------------------------------ |
| `hoofdock-dashboard`    | Open web UI in browser with authentication |
| `hoofdock-devices`      | List device pairing requests               |
| `hoofdock-approve <id>` | Approve a device pairing request           |

### Setup & Configuration

| Command              | Description                                       |
| -------------------- | ------------------------------------------------- |
| `hoofdock-fix-token` | Configure gateway authentication token (run once) |

### Maintenance

| Command            | Description                                      |
| ------------------ | ------------------------------------------------ |
| `hoofdock-rebuild` | Rebuild the Docker image                         |
| `hoofdock-clean`   | Remove all containers and volumes (destructive!) |

### Utilities

| Command              | Description                               |
| -------------------- | ----------------------------------------- |
| `hoofdock-health`    | Run gateway health check                  |
| `hoofdock-token`     | Display the gateway authentication token  |
| `hoofdock-cd`        | Jump to the OpenHoof project directory    |
| `hoofdock-config`    | Open the OpenHoof config directory        |
| `hoofdock-workspace` | Open the workspace directory              |
| `hoofdock-help`      | Show all available commands with examples |

## Common Workflows

### Check Status and Logs

**Restart the gateway:**

```bash
hoofdock-restart
```

**Check container status:**

```bash
hoofdock-status
```

**View live logs:**

```bash
hoofdock-logs
```

### Set Up WhatsApp Bot

**Shell into the container:**

```bash
hoofdock-shell
```

**Inside the container, login to WhatsApp:**

```bash
openhoof channels login --channel whatsapp --verbose
```

Scan the QR code with WhatsApp on your phone.

**Verify connection:**

```bash
openhoof status
```

### Troubleshooting Device Pairing

**Check for pending pairing requests:**

```bash
hoofdock-devices
```

**Copy the Request ID from the "Pending" table, then approve:**

```bash
hoofdock-approve <request-id>
```

Then refresh your browser.

### Fix Token Mismatch Issues

If you see "gateway token mismatch" errors:

```bash
hoofdock-fix-token
```

This will:

1. Read the token from your `.env` file
2. Configure it in the OpenHoof config
3. Restart the gateway
4. Verify the configuration

### Permission Denied

**Ensure Docker is running and you have permission:**

```bash
docker ps
```

## Requirements

- Docker and Docker Compose installed
- Bash or Zsh shell
- OpenHoof project (from `docker-setup.sh`)

## Development

**Test with fresh config (mimics first-time install):**

```bash
unset HOOFDOCK_DIR && rm -f ~/.hoofdock/config && source scripts/shell-helpers/hoofdock-helpers.sh
```

Then run any command to trigger auto-detect:

```bash
hoofdock-start
```
