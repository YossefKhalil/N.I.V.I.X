# Nivix — Architecture

Locked for v1. This document is the source of truth for *how the pieces fit*.

## 1. Layered view

```
┌───────────────────────────────────────────────────────────────────┐
│ Interfaces        DSH web + desktop (v1)                          │
│                   mobile / Discord / voice / watch (later)        │
├───────────────────────────────────────────────────────────────────┤
│ Skills & modes    skills framework · coder · research (v1)        │
│                   zen / medical / mental-health / self-learn (later)│
├───────────────────────────────────────────────────────────────────┤
│ Integrations      files · shell · web fetch (v1)                  │
│                   aria2 / yt-dlp / browser / computer use (later) │
├───────────────────────────────────────────────────────────────────┤
│ Memory            Graphiti temporal KG + LadybugDB                │
│                   (Python sidecar, local LLM, no Docker)          │
├───────────────────────────────────────────────────────────────────┤
│ Core infra        vault · DSH sandbox · cloud subagent ·          │
│                   credential proxy · kill switch · router ·       │
│                   memory sanitizer                                │
├───────────────────────────────────────────────────────────────────┤
│ Nivix Core        config · lifecycle · identity hook · plugins    │
├───────────────────────────────────────────────────────────────────┤
│ DSH               DeepSeek Harness fork (Node + Cordis)           │
├───────────────────────────────────────────────────────────────────┤
│ Inference         Ni-Strata (UnbiasedStrata engine)               │
│                   Qwen3.6-35B-A3B → Ling 3.0 Tiny (v1.x)          │
└───────────────────────────────────────────────────────────────────┘
```

## 2. Core components

### 2.1 DSH fork
- Fork of `deepseek-ai/deepseek-harness` (MIT), Node.js, Cordis plugin model.
- Nivix code lives in **separate directories** (`nivix/`, `packages/nivix-*`), with an **upstream-sync branch** and a `patches/` dir.
- No fork of the agent loop unless unavoidable. Extend via plugins.

### 2.2 Nivix Core
- Owns: config schema, lifecycle, identity hook, Nivix plugin registration.
- Identity: v1 uses DSH default; v1.x injects a compact identity stub; v2 adds `soul.md`.

### 2.3 Local inference — Ni-Strata
- `YossefKhalil/Ni-Strata`, forked from `robertkarl/UnbiasedStrata` (PolyStrata engines on Strata).
- Serves an OpenAI-compatible API on localhost (`/v1/chat/completions`).
- Pluggable behind an `InferenceBackend` interface; Nivix never hard-codes an engine.
- Target platform for v1: Linux x86-64 + NVIDIA + CUDA 12.x. **Windows port is the plan, deferred** (INF-06); until it lands, Windows runs everything except local inference, or a fallback backend behind the same interface.
- Floor model: Ling 3.0 Tiny (v1.x).

### 2.4 Memory — Graphiti
- **Temporal knowledge graph**: entities, facts with validity windows, episodes for provenance.
- Contradictions auto-invalidate old facts; history is preserved.
- Hybrid retrieval: semantic + BM25 + graph traversal; no LLM in the retrieval loop.
- Deployment: Python sidecar, `graphiti-core` + **LadybugDB** (maintained Kuzu fork) via the Kuzu driver alias — **native Windows, no Docker, no WSL2**. Fallback: bundled Neo4j Community (JRE + server).
- Local LLM via OpenAI-compatible `/v1`; `structured_output_mode="json_object"` for local-model reliability.
- Telemetry disabled (`GRAPHITI_TELEMETRY_ENABLED=false`).
- Nivix wraps a thin authenticated HTTP service around it (Graphiti's reference REST/MCP servers are unauthenticated and not production).
- Nivix keeps its own fork at **`YossefKhalil/Ni-Zep`** (fork of `getzep/graphiti`) so memory behavior can be customized without upstream drift.

### 2.5 Vault
- One memorized **master passphrase** → **Argon2id** → vault key.
- First unlock per device stores the key in the **OS keychain** (Windows Credential Manager / DPAPI); auto-unlock thereafter.
- **24-word recovery key** generated once at setup, shown once, never stored on the device.
- **Kill switch** and idle lock zeroize the in-memory key.
- No envelope/TPM ceremony in v1.

### 2.6 Cloud subagent
- The only path to a cloud model (DeepSeek V4.1 Flash, exposed as `cloud_model`).
- Runs as a **sandboxed OpenCode agent** in a **separate Cordis context**.
- Context has: no memory service, no vault service, `ctx.fs` scoped to a scratch dir, DSH sandbox `workspace-write`.
- Egress goes through the credential proxy; no raw API key in the subagent env.
- Receives an explicit task bundle from the local model; returns a result. No ambient access.
- Escalation is policy-gated (allowlisted task types + user approval by default).

### 2.7 Sandbox
- **DSH native** `ctx.sandbox` + `sandbox-local` + permission presets.
- Modes: `read-only` / `workspace-write` / `danger-full-access`.
- Default: `workspace-write` + `ask`; **fail-closed** (`SANDBOX_UNAVAILABLE`).
- Backends: Windows ACL, Linux Landlock; enforcement reported `full`/`partial`.
- Documented gap: DSH's vocabulary is **filesystem effects only** — no network/process/credential limits, same-world. The proxy covers egress; the separate context covers service access.
- Optional v1 hardening: ACL **deny-read** on `memory/` for the cloud subagent's process.

### 2.8 Credential proxy
- Caddy (or equivalent) injects credentials at the network boundary.
- Agents reference secrets by handle; raw values never enter prompts, logs, or the sandbox.
- Also enforces the cloud egress allowlist.

### 2.9 Kill switch
- Stops all agent activity and zeroizes vault/session keys.
- Remote-triggerable; tested to <2s.

## 3. Data flows

### 3.1 Local turn (default)
```
user → interface → Nivix Core → local model (Ni-Strata)
     → skills/tools under DSH sandbox
     → memory recall (Graphiti, ≤6K tokens)
     → response → interface
     → memory write (sanitizer → Graphiti episode)
```

### 3.2 Cloud escalation
```
local model decides a task needs cloud_model
  → policy check (allowlisted? approval?)
  → build task bundle (explicitly constructed, no memory)
  → sanitizer (PII / secret scrub)
  → cloud subagent (separate context, scratch fs, sandbox)
  → egress via credential proxy → DeepSeek V4.1 Flash
  → result returns to local model
```

### 3.3 Memory write
```
interaction → memory write sanitizer → Graphiti.add_episode
  → entity/fact extraction (local LLM)
  → contradiction check → invalidate old fact (keep history)
  → persist in LadybugDB
```

### 3.4 Memory recall
```
query → Graphiti hybrid search (semantic + BM25 + graph)
  → top-k with validity window
  → budgeted context (≤6K tokens)
  → local model
```

## 4. Trust boundaries

| Boundary | Trusted | Untrusted / constrained |
|---|---|---|
| Local model ↔ device | Full local access | — |
| Local model ↔ memory | Full read/write via memory client | Writes pass sanitizer |
| Local ↔ cloud | — | Cloud subagent: no memory, no vault, scratch fs, egress allowlist |
| Agent ↔ secrets | Handles only | Raw secrets only at proxy boundary |
| Agent ↔ filesystem | Workspace | Outside workspace denied by DSH sandbox |
| Repo ↔ personal data | Code/config only | Memory/vault excluded by `.gitignore` |

## 5. Portability model

The portable folder contains:
```
nivix/
├── app/            # Nivix + DSH runtime
├── runtime/        # Node, Python sidecar, Ni-Strata binaries
├── config/         # profiles, permission presets, model config
├── memory/         # Graphiti/LadybugDB data (gitignored, encrypted at rest)
├── vault/          # encrypted vault + recovery metadata (gitignored)
├── models/         # GGUF model files
└── start.(cmd|sh)  # launcher
```
- No Docker unless genuinely necessary.
- Host GPU optional; CPU/iGPU fallback via the floor model.
- Copy the folder → same state on another machine (vault requires passphrase/recovery on a new device).

## 6. Decision log

| # | Decision | Rationale |
|---|---|---|
| D1 | Nivix is a DSH **fork/distribution**, not a new harness | Inherit upstream; heavy separation keeps sync cheap |
| D2 | **Local-first**: local model is main, cloud is a subagent | Personal data stays local; cloud is a capability boost |
| D3 | Cloud subagent is a **sandboxed OpenCode agent** in a separate context | Full capability without memory/vault access |
| D4 | Sandbox = **DSH native** (`ctx.sandbox` + `sandbox-local`) | Real OS-level confinement; no custom cross-platform sandbox |
| D5 | Memory = **Graphiti** temporal KG + **LadybugDB** (embedded, Windows-native) | Bi-temporal facts, provenance, token-efficient retrieval, no Docker/WSL2 |
| D6 | Vault = passphrase → Argon2id → key; OS keychain; 24-word recovery | Minimal friction, one memorized secret, real protection |
| D7 | Inference = **Ni-Strata** (UnbiasedStrata), pluggable | Lean local engine; swap-friendly interface |
| D8 | Memory lives **outside the public repo** | Personal data never committed |
| D9 | Persona staged: default → stub → full | Cost/benefit; avoid over-constraining v1 |
| D10 | Growth is **user-directed, review-gated** | Avoid self-bloat and unsafe self-modification |

## 7. Known limitations (v1)

- DSH sandbox is filesystem-effect-only and same-world; not a VM boundary.
- Cloud subagent read-isolation depends on OS ACLs, not DSH policy.
- Graphiti needs reliable structured output from the local model; must be validated.
- LadybugDB rides Graphiti's deprecated Kuzu driver; the write path must be proven on Windows (known Kuzu crash). Fallback: bundled Neo4j Community.
- Ni-Strata targets Linux/NVIDIA in v1; Windows/macOS support comes later.
- DSH is developer-preview with breaking changes; pin and sync deliberately.