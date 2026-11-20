# Nivix — Roadmap

Master roadmap. Architecture in [`docs/architecture.md`](./docs/architecture.md). Build order in [`docs/build-order.md`](./docs/build-order.md). Security tests in [`docs/security-test-suite.md`](./docs/security-test-suite.md).

## Legend

| Symbol | Meaning |
|---|---|
| ⬜ | planned |
| 🟦 | in-progress |
| ✅ | done |
| 🟥 | blocked |
| ⏸️ | deferred |

**Priority:** **P0** must ship for v1 · **P1** v1.x · **P2** later

## Target

> A portable, local-first personal agent that runs from one folder — **no Docker, no WSL2** — keeps a temporal memory of my life, codes and researches, and never sends my personal data to the cloud. A cloud model is available only as a sandboxed helper.

---

## Phase 0 — Bootstrap

| ID | Task | Pri | Status | Depends on | Done when |
|---|---|---|---|---|---|
| F-01 | Pin the DSH fork and verify `dsh web` runs from source | P0 | ⬜ | — | Fresh clone builds and serves |
| F-02 | Nivix layout (`nivix/`, `packages/nivix-*`) + upstream-sync branch | P0 | ⬜ | F-01 | Upstream merge is a rebase |
| F-03 | Nivix Core: config, lifecycle, identity hook | P0 | ⬜ | F-02 | Core loads; identity hook fires |
| F-04 | Repo hygiene: public repo, `.gitignore` memory/vault, license, CI | P0 | ⬜ | F-01 | Personal data cannot be committed |
| F-05 | Test DSH's default persona; record keep/change | P1 | ⬜ | F-03 | Written persona note |
| F-06 | Conventions + ADR process | P1 | ⬜ | F-04 | First ADR merged |
| F-07 | Brand: logo, palette, icon set | P2 | ⬜ | F-04 | Used in web/desktop |

**Exit:** `dsh web` runs the fork; repo clean; identity hook works.

---

## Phase 1 — Local inference

| ID | Task | Pri | Status | Depends on | Done when |
|---|---|---|---|---|---|
| INF-01 | Build Ni-Strata (UnbiasedStrata) | P0 | ⬜ | — | Serves `/v1/chat/completions` |
| INF-02 | `InferenceBackend` adapter (OpenAI-compatible) + health/model selection | P0 | ⬜ | INF-01 | Nivix selects and health-checks the backend |
| INF-03 | Tool-calling validation with Qwen3.6-35B-A3B | P0 | ⬜ | INF-02 | 10/10 tool calls |
| INF-04 | Structured-output validation (`json_object`) | P0 | ⬜ | INF-03 | Valid JSON over 20 runs |
| INF-05 | Ling 3.0 Tiny floor model | P1 | ⏸️ | INF-01 | Runs on CPU/iGPU/GPU |
| INF-06 | **Port Ni-Strata/UnbiasedStrata to native Windows (CUDA 12.x)** | P2 | ⏸️ | INF-01 | Windows build serves `/v1` on NVIDIA |
| INF-07 | MTP speculative decoding for Qwen3.6-35B-A3B (`draft-mtp`, MTP GGUF) | P1 | ⏸️ | INF-01 | Download MTP GGUF; `--spec-draft-n-max 2`; measured vs 23.77 t/s |
| INF-07b | DSpark/DFlash/n-gram evaluation | P2 | ⏸️ | INF-01 | Evaluated; DFlash/n-gram net loss on A3B; DSpark drafter unavailable |
| INF-08 | TurboQuant KV cache support in Ni-Strata | P1 | ⏸️ | INF-01 | KV type supported; memory down; speed measured |

**Exit:** local agent completes a tool-using task with zero cloud calls.

---

## Phase 2 — Security core + cloud subagent

| ID | Task | Pri | Status | Depends on | Done when |
|---|---|---|---|---|---|
| CI-01 | Vault: Argon2id(passphrase) → key; OS keychain auto-unlock; 24-word recovery; zeroize | P0 | ⬜ | F-03 | V-01..V-10 pass |
| CI-02 | DSH sandbox: `sandbox-local` + presets (`workspace-write` + `ask`), fail-closed | P0 | ⬜ | F-03 | S-01..S-08 pass |
| CI-03 | Cloud subagent: sandboxed OpenCode, separate context, no memory/vault, scratch fs | P0 | ⬜ | CI-02 | C-01..C-04, C-08 pass |
| CI-04 | Credential-injection proxy + egress allowlist | P0 | ⬜ | CI-01, CI-03 | P-01..P-05 pass |
| CI-05 | Kill switch: stop activity, zeroize keys | P0 | ⬜ | CI-01 | K-01..K-05 pass; <2s |
| CI-06 | Memory write sanitizer (injection, PII) | P0 | ⬜ | M-01 | M-06, M-07 pass |
| CI-07 | Cloud escalation policy (no standalone router) | P0 | ⬜ | INF-02, CI-03 | Escalates only when allowed |
| CI-08 | Canarytokens | P0 | ⬜ | CI-01 | Trigger produces an alert |
| CI-09 | LlamaFirewall | P1 | ⏸️ | CI-04 | Injection payloads blocked |
| CI-10 | VirusTotal + ClamAV | P1 | ⏸️ | CI-04 | EICAR detected; downloads flagged |
| CI-11 | SSH device enrollment (script/QR, master approval) | P1 | ⏸️ | CI-01 | A device can be enrolled from the Master Nivix |

**Exit:** local/cloud separation proven; secrets never exposed; kill switch works.

---

## Phase 3 — Memory (Graphiti + LadybugDB)

| ID | Task | Pri | Status | Depends on | Done when |
|---|---|---|---|---|---|
| M-01 | Graphiti sidecar: `Ni-Zep` + **LadybugDB** (Kuzu driver alias), native Windows, no Docker/WSL2 | P0 | ⬜ | INF-02 | Ingests and recalls over HTTP |
| M-02 | Nivix memory client (Node ↔ Graphiti) | P0 | ⬜ | M-01 | Add + recall + temporal query |
| M-03 | Temporal schema: entities, facts with validity, episodes | P0 | ⬜ | M-02 | Contradiction invalidates, history kept |
| M-04 | Retrieval budget + hybrid search tuning | P0 | ⬜ | M-03 | ≤6K tokens, sub-second |
| M-05 | Memory tests: invalidation, provenance, time-scoped | P0 | ⬜ | M-03 | M-01..M-09 pass |
| M-06 | Encrypted backup/restore | P1 | ⬜ | M-01, CI-01 | Restore verified |

**Exit:** remembers across restarts; answers "what was true then" correctly.

---

## Phase 4 — Agent capability

| ID | Task | Pri | Status | Depends on | Done when |
|---|---|---|---|---|---|
| S-01 | Skills framework (DSH plugin registration, sandboxed invocation) | P0 | ⬜ | F-03 | Install/uninstall at runtime |
| S-02 | Coder skill (read/edit, run tests, traces) | P0 | ⬜ | S-01, CI-02 | Edits a repo and runs its tests in-sandbox |
| S-03 | Research skill (web search/fetch, citations) | P0 | ⬜ | S-01 | Cited answer |
| S-04 | browser-use tool (v1) | P0 | ⬜ | S-01, CI-02 | Sandboxed browser task completes |
| S-05 | Computer use (v1.x) | P1 | ⏸️ | S-01, CI-02 | Desktop task with consent + kill switch |
| S-06 | Medical skills (v1.x, personal, advisory-only) | P1 | ⏸️ | S-01 | Disclaimers, no diagnosis |
| S-07 | Mental-health mode (v1.x, personal, safety guardrails) | P1 | ⏸️ | S-01 | Crisis path documented |
| S-08 | Controlled self-learn (review-gated) | P2 | ⏸️ | S-01, M-01 | Agent drafts; user approves |
| S-09 | Full `soul.md` + Distilly process | P2 | ⏸️ | F-05 | Persona consistent; guardrails verified |

**Exit:** daily driver: code, research, browser, remember.

---

## Phase 5 — Interface + portability

| ID | Task | Pri | Status | Depends on | Done when |
|---|---|---|---|---|---|
| UI-01 | Nivix theme/brand in DSH web/desktop | P1 | ⬜ | F-07 | Branded web + desktop |
| UI-02 | Portable profile/bundle: data, config, runtime, sidecars | P0 | ⬜ | all P0 | Folder runs on a clean machine |
| UI-03 | Launch scripts (Windows + Linux) | P0 | ⬜ | UI-02 | One command starts Nivix |
| UI-04 | USB cold-start test | P0 | ⬜ | UI-03 | <60s, state intact |
| UI-05 | Backup/restore | P1 | ⬜ | M-06 | Restore verified |
| UI-06 | Mobile (v2) · Discord + voice (v2) · Ni-Watch + Ni-Volt (v3) | P2 | ⏸️ | UI-01 | Per-surface acceptance |

**Exit:** Nivix runs from a USB folder on a clean machine and resumes memory.

---

## Phase 6 — Optional expansions

| ID | Task | Pri | Status | Notes |
|---|---|---|---|---|
| T-01 | aria2 | P1 | ⏸️ | v1.x |
| T-02 | yt-dlp | P1 | ⏸️ | v1.x |
| T-03 | ego lite wrapper for browser-use | P1 | ⏸️ | v1.x |
| D-01 | Portable distribution sign-off | P0 | ⬜ | ties UI-02..UI-04 |
| D-02 | Release/update procedure | P1 | ⬜ | semver, changelog, upstream sync |

---

## Explicitly dropped

| Item | Reason |
|---|---|
| omnirouter | Redundant; cloud escalation policy covers it |
| Unreal Agent + workers | Dropped |
| Legacy memory (easyclaw, hermes) | Dropped |
| nivix zen naming | Dropped |
| hexstrike | Dropped |
| Blender MCP | Dropped |
| Minecraft modding | Dropped |
| Image generation | Dropped |
| Scale-out workers | Dropped |

## Deferred (not dropped)

| Item | When |
|---|---|
| Distilly / full `soul.md` | v2 |
| Mobile | v2 |
| Discord + voice | v2 |
| Ni-Watch + Ni-Volt | v3 (blueprints exist) |
| SSH device enrollment | v1.x |
| Medical + mental-health | v1.x |

---

## Cross-cutting

| ID | Concern | Notes |
|---|---|---|
| X-01 | Threat model / security review | Gate before P0 ships |
| X-02 | Observability | DSH traces + Nivix logs |
| X-03 | Test strategy | Security suite is a gate |
| X-04 | Docs & ADRs | Keep in sync |
| X-05 | Release/versioning | Semver from v0.1.0 |

## Milestones

| Milestone | Definition |
|---|---|
| M0 — Bootstrap | Phase 0 |
| M1 — Local agent | Phase 1 |
| M2 — Safe boundary | Phase 2 |
| M3 — Memory | Phase 3 |
| M4 — Daily driver | Phase 4 |
| M5 — Portable | Phase 5 → **v1.0** |

## Open questions

1. **LadybugDB on Windows**: it rides Graphiti's deprecated Kuzu driver; write-path stability must be proven (known Kuzu Windows crash). Fallback: bundled Neo4j Community (JRE + server), still no Docker/WSL2.
2. **Native Windows inference (direction set)**: Ni-Strata targets Linux/NVIDIA in v1; the **Windows port is the plan, deferred** (INF-06). Until it lands, Windows runs everything except local inference; a fallback backend can be added behind `InferenceBackend` if needed sooner.
3. **SSH enrollment**: define the QR/script flow and how the Master Nivix authorizes a device.
4. **Ni-Watch / Ni-Volt**: v3 hardware; blueprints exist.

## Changelog

- Initial roadmap from the pillar list.
- Rewritten after architecture lock.
- Round 7 answers applied: dropped omnirouter, Unreal Agent, legacy memory, zen naming, hexstrike, Blender, Minecraft, image gen, scale-out workers; moved Canarytokens to v1; moved SSH/medical/mental-health/computer-use/ego-lite to v1.x; browser-use to v1; mobile/Discord/voice to v2; Ni-Watch/Ni-Volt to v3; replaced FalkorDB Lite with LadybugDB (Windows-native, no WSL2).
- Inference platform: v1 targets Linux/NVIDIA; **native Windows port is the plan, deferred** (INF-06).
- Baseline benchmark on the prebuilt llama.cpp CUDA backend: **pp512 ≈ 82.3 t/s · tg128 ≈ 23.8 t/s** (Qwen3.6-35B-A3B Q4_K_M, RTX 3050 6 GB). See `benchmarks/2026-11-20-local-inference.md`. Ni-Strata build blocked: no CUDA toolkit/headers.