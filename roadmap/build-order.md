# Nivix — Build Order

The order matters: each step produces something testable, and later steps depend on earlier ones.

## Dependency graph

```
F-01 ── F-02 ── F-03 ─────────────────────────────────────────────┐
  │                │                                             │
  └── INF-01 ── INF-02 ── INF-03 ── INF-04                       │
                   │                                             │
                   └── M-01 ── M-02 ── M-03 ── M-04 ── CI-06      │
                                                                 │
F-03 ── CI-01 ───────────────────────────────────────────────────┤
F-03 ── CI-02 ── CI-03 ── CI-04 ── CI-05                          │
                   │         │                                   │
                   └─────────┴── CI-07                            │
                                                                 │
CI-02 + CI-07 + M-02 ── S-01 ── S-02 / S-03 ── S-04             │
                                                                 │
F-03 + INF-02 + M-02 + CI-02 ── UI-01 ── UI-02 ── UI-03 ── UI-04 ┘
```

**Critical path:** `F-01 → F-03 → CI-01 → CI-02 → CI-03 → CI-04 → CI-05 → M-01 → M-02 → S-01 → S-02 → UI-02 → UI-04`

## Environment prerequisites

| Tool | Why |
|---|---|
| Node.js 22+ and `pnpm` | DSH runtime |
| Python 3.12+ | Graphiti sidecar (LadybugDB) |
| NVIDIA driver + CUDA 12.x | Ni-Strata / UnbiasedStrata |
| Linux x86-64 + NVIDIA (native) | Ni-Strata target for v1; native Windows port later |
| Git + `uv`/`pip` | forks and Python deps |

---

## Step 0 — Fork bootstrap (G0)

**Tasks:** F-01, F-02, F-04
- Clone `YossefKhalil/Ni-Agent`, install deps, run `pnpm build` + `pnpm dsh web`.
- Create `nivix/` and `packages/nivix-*`; add `upstream` remote and `upstream-sync` branch.
- Add `.gitignore` entries: `memory/`, `vault/`, `models/`, `*.gguf`, `*.db`, `*.db-wal`.
- CI: build + lint.

**Gate G0:** `dsh web` serves the fork; a fresh clone builds; `memory/` cannot be committed.

---

## Step 1 — Nivix Core (G0)

**Tasks:** F-03, F-06
- Nivix Core plugin: config schema, lifecycle, identity hook.
- Minimal identity: pass-through (DSH default) for v1.
- ADR template + first ADR (fork/distribution decision).

**Gate G0.5:** Core loads as a plugin; identity hook is called on boot.

---

## Step 2 — Local inference (G1)

**Tasks:** INF-01 → INF-02 → INF-03 → INF-04
- Build `Ni-Strata` (UnbiasedStrata) on Linux + NVIDIA. **Windows port is deferred (INF-06).**
- Verify `/v1/chat/completions` and `/v1/models`.
- Implement `InferenceBackend` (OpenAI-compatible), health check, model selection.
- Validate tool calling (10/10) and structured JSON (`json_object`).

**Gate G1:** local agent completes a tool-using task end-to-end, zero cloud calls.

---

## Step 3 — Vault (G2)

**Tasks:** CI-01
- Passphrase → Argon2id → key.
- OS keychain auto-unlock ("remember this device").
- 24-word recovery key (shown once, never stored).
- Zeroize on kill/idle.

**Gate G2a:** unlock, recovery, auto-unlock, and zeroize tests pass.

---

## Step 4 — Sandbox (G2)

**Tasks:** CI-02
- Mount DSH `sandbox-local`; set preset `workspace-write` + `ask`.
- Verify fail-closed `SANDBOX_UNAVAILABLE`.
- Verify child-process inheritance and escalation approval.

**Gate G2b:** writes outside workspace denied; no backend → no bare run.

---

## Step 5 — Cloud subagent + proxy (G2)

**Tasks:** CI-03 → CI-04 → CI-05 → CI-07
- Separate Cordis context: no memory/vault services; scratch `ctx.fs`; `workspace-write`.
- Wrap a sandboxed OpenCode agent as the subagent.
- Caddy credential-injection proxy + egress allowlist.
- Kill switch + router (`cloud_model` = DeepSeek V4.1 Flash).

**Gate G2c:** subagent completes a task with no memory/vault access, no raw key, allowlisted egress only; kill switch <2s.

---

## Step 6 — Memory sidecar (G3)

**Tasks:** M-01 → M-02 → M-03 → M-04 → CI-06
- `Ni-Zep` (Graphiti fork) + `graphiti-core` + **LadybugDB** (Kuzu driver alias), native Windows, no Docker/WSL2.
- Local LLM via `/v1`; `structured_output_mode="json_object"`; telemetry off.
- Thin authenticated HTTP service.
- Node memory client: add episode / recall / temporal query.
- Memory write sanitizer before ingestion.

**Gate G3:** contradiction invalidation, provenance, "what was true then", ≤6K-token recall all pass.

---

## Step 7 — Skills (G4)

**Tasks:** S-01 → S-02 / S-03 → S-04
- Skills framework (DSH plugin registration, sandboxed invocation).
- Coder skill: read/edit files, run tests, inspect traces.
- Research skill: web search/fetch, citations.
- Cloud escalation policy: allowlisted task types, approval default, sanitized bundle.

**Gate G4:** code a small feature and run its tests; produce a cited research answer; escalate once safely.

---

## Step 8 — Interface + portability (G5)

**Tasks:** UI-01 → UI-02 → UI-03 → UI-04 → UI-05
- Nivix theme in DSH web/desktop.
- Portable folder layout: app, runtime, config, memory, vault, models, start script.
- Launch scripts (Windows + Linux).
- USB cold-start test.
- Backup/restore.

**Gate G5:** copy the folder to a clean machine, start it, unlock, resume memory; USB <60s.

---

## Step 9 — Hardening (post-G5)

**Tasks:** CI-08, CI-09, CI-10, M-06, X-01..X-05
- LlamaFirewall, VirusTotal, ClamAV, Canarytokens.
- Encrypted backup/restore verification.
- Threat-model review; observability; release process.

---

## Step 10 — Expansion (post-v1)

**Tasks:** T-01..T-03, CI-11, UI-06, S-05..S-09
- aria2, yt-dlp, ego lite wrapper.
- SSH device enrollment (script/QR, master approval); computer use; medical; mental health; controlled self-learn; full `soul.md` + Distilly.
- Mobile (v2), Discord + voice (v2), Ni-Watch + Ni-Volt (v3).
- Port UnbiasedStrata to Windows (INF-06, planned).
- Dropped: Blender, Minecraft, image generation, hexstrike, scale-out workers.

---

## Gates summary

| Gate | Meaning | Blocks |
|---|---|---|
| G0 | Fork builds and serves | everything |
| G0.5 | Nivix Core loads | security |
| G1 | Local agent works | memory, skills |
| G2 | Security boundary proven | skills, portability |
| G3 | Temporal memory works | daily driver |
| G4 | Coder + research usable | interface |
| G5 | Portable folder works | v1.0 |

## Time-boxing guidance

- Steps 0–2 are the "walking skeleton": aim for the first local tool-calling agent before touching memory.
- Steps 3–5 are the security spine: do not skip or reorder.
- Step 6 is the differentiator: budget extra time for local-model structured output.
- Step 8 is where "portable" is proven or falsified; test on a second machine early.