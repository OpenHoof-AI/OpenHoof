---
name: hoofhub
description: Use the HoofHub CLI to search, install, update, and publish agent skills from hoofhub.com. Use when you need to fetch new skills on the fly, sync installed skills to latest or a specific version, or publish new/updated skill folders with the npm-installed hoofhub CLI.
metadata:
  {
    "openhoof":
      {
        "requires": { "bins": ["hoofhub"] },
        "install":
          [
            {
              "id": "node",
              "kind": "node",
              "package": "hoofhub",
              "bins": ["hoofhub"],
              "label": "Install HoofHub CLI (npm)",
            },
          ],
      },
  }
---

# HoofHub CLI

Install

```bash
npm i -g hoofhub
```

Auth (publish)

```bash
hoofhub login
hoofhub whoami
```

Search

```bash
hoofhub search "postgres backups"
```

Install

```bash
hoofhub install my-skill
hoofhub install my-skill --version 1.2.3
```

Update (hash-based match + upgrade)

```bash
hoofhub update my-skill
hoofhub update my-skill --version 1.2.3
hoofhub update --all
hoofhub update my-skill --force
hoofhub update --all --no-input --force
```

List

```bash
hoofhub list
```

Publish

```bash
hoofhub publish ./my-skill --slug my-skill --name "My Skill" --version 1.2.0 --changelog "Fixes + docs"
```

Notes

- Default registry: https://hoofhub.com (override with HOOFHUB_REGISTRY or --registry)
- Default workdir: cwd (falls back to OpenHoof workspace); install dir: ./skills (override with --workdir / --dir / HOOFHUB_WORKDIR)
- Update command hashes local files, resolves matching version, and upgrades to latest unless --version is set
