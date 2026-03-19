---
summary: "Use xAI Grok models in OpenHoof"
read_when:
  - You want to use Grok models in OpenHoof
  - You are configuring xAI auth or model ids
title: "xAI"
---

# xAI

OpenHoof ships a bundled `xai` provider plugin for Grok models.

## Setup

1. Create an API key in the xAI console.
2. Set `XAI_API_KEY`, or run:

```bash
openhoof onboard --auth-choice xai-api-key
```

3. Pick a model such as:

```json5
{
  agents: { defaults: { model: { primary: "xai/grok-4" } } },
}
```

## Current bundled model catalog

OpenHoof now includes these xAI model families out of the box:

- `grok-4`, `grok-4-0709`
- `grok-4-fast-reasoning`, `grok-4-fast-non-reasoning`
- `grok-4-1-fast-reasoning`, `grok-4-1-fast-non-reasoning`
- `grok-4.20-experimental-beta-0304-reasoning`
- `grok-4.20-experimental-beta-0304-non-reasoning`
- `grok-code-fast-1`

The plugin also forward-resolves newer `grok-4*` and `grok-code-fast*` ids when
they follow the same API shape.

## Web search

The bundled `grok` web-search provider uses `XAI_API_KEY` too:

```bash
openhoof config set tools.web.search.provider grok
```

## Known limits

- Auth is API-key only today. There is no xAI OAuth/device-code flow in OpenHoof yet.
- `grok-4.20-multi-agent-experimental-beta-0304` is not supported on the normal xAI provider path because it requires a different upstream API surface than the standard OpenHoof xAI transport.
- Native xAI server-side tools such as `x_search` and `code_execution` are not yet first-class model-provider features in the bundled plugin.

## Notes

- OpenHoof applies xAI-specific tool-schema and tool-call compatibility fixes automatically on the shared runner path.
- For the broader provider overview, see [Model providers](/providers/index).
