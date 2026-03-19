# Agent Workflow — OpenHoof

This is the autonomous agent workflow for OpenHoof development.
Agents work locally, push branches, open PRs, and CI auto-merges if green.
**No human intervention required.**

---

## Local Repo

```
/Users/openclaw/openhoof/OpenHoof
```

Git remote: `git@github-openhoof:OpenHoof-AI/OpenHoof.git`
Default branch: `main`
Git identity: `thekethorse <ket@openhoof.ai>`

---

## Branch Naming

All agent-created branches **must** use one of these prefixes (auto-merge only fires on these):

```
agent/<short-description>      # general agent work
ket/<short-description>        # ket-initiated features
auto/<short-description>       # automated/scheduled tasks
```

Examples:
- `agent/fix-telegram-reconnect`
- `ket/openhoof-landing-copy`
- `auto/dependency-update`

---

## Autonomous PR Flow

1. **Branch** — create from latest `main`:
   ```bash
   cd /Users/openclaw/openhoof/OpenHoof
   git checkout main && git pull
   git checkout -b agent/<task-name>
   ```

2. **Work** — make changes, follow `AGENTS.md` coding conventions

3. **Build check** — always verify before pushing:
   ```bash
   pnpm build:strict-smoke
   pnpm lint
   ```

4. **Commit** — use the repo's committer script:
   ```bash
   node scripts/committer "<Conventional Commit msg>" <changed files...>
   ```
   Or manually: `git add <files> && git commit -m "<msg>"`

5. **Push**:
   ```bash
   git push -u origin agent/<task-name>
   ```

6. **Open PR**:
   ```bash
   gh pr create \
     --title "<Short title>" \
     --body "<What changed and why>" \
     --base main \
     --head agent/<task-name>
   ```

7. **CI runs** — GitHub Actions runs build + lint + tests automatically

8. **Auto-merge** — if CI passes and branch prefix matches `agent/`, `ket/`, or `auto/`, the PR auto-merges to `main` via squash

---

## PR Body Template

```markdown
## What

<Brief description of the change>

## Why

<Motivation — bug fix, feature, improvement>

## Testing

<How it was verified — build passed, tests ran, manual check>
```

---

## Rules

- Never push directly to `main` — always use a feature branch + PR
- Always run `pnpm build:strict-smoke` and `pnpm lint` before pushing
- Keep PRs focused — one task per PR
- If CI fails: fix locally, push again to the same branch, CI reruns
- Never commit secrets, keys, phone numbers, or real credentials

---

## Key Commands

| Task | Command |
|------|---------|
| Install deps | `pnpm install` |
| Build | `pnpm build:strict-smoke` |
| Full build | `pnpm build` |
| Lint | `pnpm lint` |
| Format fix | `pnpm format:fix` |
| Type check | `pnpm tsgo` |
| Tests | `pnpm test:fast` |
| All checks | `pnpm check` |

---

## Auto-merge Eligibility

PRs auto-merge when ALL of these are true:
1. Branch name starts with `agent/`, `ket/`, or `auto/`
2. All CI checks pass (build + lint + tests)
3. No merge conflicts

If any check fails, the PR stays open for review.
