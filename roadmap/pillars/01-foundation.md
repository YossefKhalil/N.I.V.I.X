# Pillar 1 — Foundation

Master list: [ROADMAP.md § Phase 0](../../ROADMAP.md#phase-0--bootstrap).

## F-01 — Pin the DSH fork
- **Repo:** `YossefKhalil/Ni-Agent` (fork of `deepseek-ai/deepseek-harness`, MIT).
- **Do:** clone, `pnpm install`, `pnpm build`, `pnpm dsh web`.
- **Done:** fresh clone builds and serves the web UI on a clean machine.
- **Notes:** DSH is developer-preview with breaking changes — pin a commit, sync deliberately.

## F-02 — Nivix layout + upstream sync
- **Do:** create `nivix/` and `packages/nivix-*`; add `upstream` remote; create `upstream-sync` branch; `patches/` for unavoidable core edits.
- **Rule:** Nivix code lives in separate dirs; upstream files stay untouched where possible.
- **Done:** an upstream merge is a rebase, not a rewrite.

## F-03 — Nivix Core
- **Do:** config schema, lifecycle, identity hook, plugin registration.
- **Identity:** v1 = DSH default (pass-through); v1.x = compact identity stub; v2 = `soul.md` (BT7274-inspired).
- **Done:** Core loads as a plugin; identity hook fires on boot; start/stop is clean.

## F-04 — Repo hygiene
- **Do:** public repo; `.gitignore` for `memory/`, `vault/`, `models/`, `*.gguf`, `*.db`, `*.db-wal`, `*.db-shm`; pre-commit secret scan; CI skeleton.
- **Rule:** code/config only — **no personal data in the public repo**.
- **Done:** `git status` after a Nivix run shows no personal artifacts.

## F-05 — Default persona test
- **Do:** use DSH's default persona for a week; record what to keep/change.
- **Output:** a short persona note (not code).
- **Done:** written note; no behavior changes yet.

## F-06 — Conventions + ADRs
- **Do:** `CONTRIBUTING.md`, ADR template, commit conventions, review policy.
- **Done:** first ADR merged (fork/distribution decision).

## F-07 — Brand (P2)
- **Do:** logo, palette, typography, icon set.
- **Done:** used in web/desktop.

## Acceptance for Phase 0
- `dsh web` runs the fork.
- Nivix Core loads.
- Repo cannot accidentally commit personal data.
- Upstream sync is cheap.