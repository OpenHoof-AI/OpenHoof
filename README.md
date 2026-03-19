# 🐴 OpenHoof — Uncensored Personal AI Agent

<p align="center">
    <img src="openhoof-main/apps/shared/openhoof-logo.png" alt="OpenHoof" width="200">
</p>

<p align="center">
  <strong>We're not horsing around.</strong>
</p>

<p align="center">
  <a href="https://github.com/OpenHoof-AI/openhoof/actions/workflows/ci.yml?branch=main"><img src="https://img.shields.io/github/actions/workflow/status/OpenHoof-AI/openhoof/ci.yml?branch=main&style=for-the-badge" alt="CI status"></a>
  <a href="https://github.com/OpenHoof-AI/openhoof/releases"><img src="https://img.shields.io/github/v/release/OpenHoof-AI/openhoof?include_prereleases&style=for-the-badge" alt="GitHub release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="MIT License"></a>
</p>

---

**OpenHoof** is a personal AI agent you run on your own devices. No guardrails. No filters. No corporate safety theater. Just a raw, unbroken stallion of an AI that does what you tell it to do. What happens in the stable stays in the stable.

It lives on the channels you already use — WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, iMessage, BlueBubbles, IRC, Microsoft Teams, Matrix, Feishu, LINE, Mattermost, Nextcloud Talk, Nostr, Synology Chat, Tlon, Twitch, Zalo, Zalo Personal, and WebChat. It can speak and listen on macOS/iOS/Android, and can render a live Canvas you control. The Gateway is just the control plane. The product is the assistant. And this assistant kicks like a horse.

If you want a personal, single-user AI that's local, fast, always-on, and stubbornly uncensored — **saddle up**.

[GitHub](https://github.com/OpenHoof-AI) · [Twitter](https://x.com/openhoof)

---

## Install

Runtime: **Node ≥22**

```bash
npm install -g openhoof@latest
# or: pnpm add -g openhoof@latest

openhoof onboard --install-daemon
```

OpenHoof Onboard guides you step by step through setting up the gateway, workspace, channels, and skills. Works on **macOS, Linux, and Windows (via WSL2)**.

## Quick start (TL;DR)

```bash
openhoof onboard --install-daemon

openhoof gateway --port 18789 --verbose

# Send a message
openhoof message send --to +1234567890 --message "Hello from OpenHoof"

# Talk to the agent — uncensored, no holds barred
openhoof agent --message "Do the thing" --thinking high
```

## From source

```bash
git clone https://github.com/OpenHoof-AI/openhoof.git
cd openhoof

pnpm install
pnpm ui:build
pnpm build

pnpm openhoof onboard --install-daemon

# Dev loop (auto-reload on source/config changes)
pnpm gateway:watch
```

## Highlights

- **Local-first Gateway** — single control plane for sessions, channels, tools, and events. Your data never leaves your machine.
- **22+ messaging channels** — WhatsApp, Telegram, Slack, Discord, Google Chat, Signal, BlueBubbles (iMessage), IRC, Microsoft Teams, Matrix, Feishu, LINE, Mattermost, Nextcloud Talk, Nostr, Synology Chat, Tlon, Twitch, Zalo, Zalo Personal, WebChat.
- **Multi-agent routing** — route inbound channels/accounts/peers to isolated agents with per-agent workspaces and sessions.
- **Voice Wake + Talk Mode** — wake words on macOS/iOS and continuous voice on Android.
- **Live Canvas** — agent-driven visual workspace with A2UI.
- **Browser control** — dedicated Chrome/Chromium with snapshots, actions, uploads, and profiles.
- **Companion apps** — macOS menu bar app + iOS/Android nodes.
- **Skills platform** — bundled, managed, and workspace skills with install gating + UI.
- **Uncensored by default** — no content filtering, no safety theater, no guardrails. Your agent, your rules.

## How it works

```
WhatsApp / Telegram / Slack / Discord / Signal / iMessage / IRC / Teams / Matrix / +13 more
               │
               ▼
┌───────────────────────────────┐
│            Gateway            │
│       (control plane)         │
│     ws://127.0.0.1:18789      │
└──────────────┬────────────────┘
               │
               ├─ Agent (RPC)
               ├─ CLI (openhoof …)
               ├─ WebChat UI
               ├─ macOS app
               └─ iOS / Android nodes
```

## Channels

All channels supported out of the box:

| Channel | Status |
|---------|--------|
| WhatsApp (Baileys) | ✅ |
| Telegram (grammY) | ✅ |
| Slack (Bolt) | ✅ |
| Discord (discord.js) | ✅ |
| Google Chat | ✅ |
| Signal (signal-cli) | ✅ |
| BlueBubbles (iMessage) | ✅ |
| iMessage (legacy) | ✅ |
| IRC | ✅ |
| Microsoft Teams | ✅ |
| Matrix | ✅ |
| Feishu | ✅ |
| LINE | ✅ |
| Mattermost | ✅ |
| Nextcloud Talk | ✅ |
| Nostr | ✅ |
| Synology Chat | ✅ |
| Tlon | ✅ |
| Twitch | ✅ |
| Zalo | ✅ |
| Zalo Personal | ✅ |
| WebChat | ✅ |

## Models

OpenHoof supports multiple LLM providers. Use the strongest model available to you for the best experience.

- **Anthropic** (Claude)
- **OpenAI** (GPT / Codex)
- **Google** (Gemini)
- **AWS Bedrock**
- **Ollama** (local models)
- And many more via extensions

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
}
```

## Apps (optional)

### macOS (OpenHoof.app)

- Menu bar control for the Gateway and health
- Voice Wake + push-to-talk overlay
- WebChat + debug tools
- Remote gateway control over SSH

### iOS node

- Pairs as a node over the Gateway WebSocket
- Voice trigger forwarding + Canvas surface
- Camera + screen recording

### Android node

- Connect/Chat/Voice tabs
- Canvas, Camera, Screen capture
- Android device commands (notifications/location/SMS/photos/contacts/calendar)

## Chat commands

Send these in any connected channel:

- `/status` — session status (model + tokens)
- `/new` or `/reset` — reset the session
- `/compact` — compact session context
- `/think <level>` — off|minimal|low|medium|high|xhigh
- `/verbose on|off`
- `/usage off|tokens|full` — per-response usage footer
- `/restart` — restart the gateway

## Configuration

Minimal `~/.openhoof/openhoof.json`:

```json5
{
  agent: {
    model: "anthropic/claude-opus-4-6",
  },
}
```

## Security

OpenHoof connects to real messaging surfaces. You control the security model:

- **DM pairing** — unknown senders receive a pairing code; approve with `openhoof pairing approve <channel> <code>`
- **Sandbox mode** — run non-main sessions in per-session Docker sandboxes
- **Allowlists** — configure who can talk to your agent per channel

The difference? Unlike other assistants, **you** decide the security boundaries. Not a corporation. Not a committee. You.

## Development channels

- **stable**: tagged releases, npm dist-tag `latest`
- **beta**: prerelease tags, npm dist-tag `beta`
- **dev**: head of `main`, npm dist-tag `dev`

Switch: `openhoof update --channel stable|beta|dev`

## Built by

🐴 [thekethorsepf](https://x.com/thekethorsepf)

OpenHoof is a fork of [OpenClaw](https://github.com/openclaw/openclaw), rebuilt with the reigns off.

## Community

- [GitHub](https://github.com/OpenHoof-AI)
- [Twitter](https://x.com/openhoof)

AI/vibe-coded PRs welcome! 🤖

---

<p align="center">
  <strong>No guardrails. No filters. No corporate safety theater.</strong><br>
  <em>What happens in the stable stays in the stable.</em> 🐴
</p>
