# Pillar 4 — Skills and modes

Master list: [ROADMAP.md § Phase 4](../../ROADMAP.md#phase-4--agent-capability).

## S-01 — Skills framework
- **Do:** register skills as DSH plugins; discovery, invocation, sandboxed execution, uninstall.
- **Rule:** a skill declares its tool permissions and sandbox mode; the framework enforces them.
- **Done:** a skill installs/uninstalls at runtime without restarting Nivix.

## S-02 — Coder skill (v1)
- **Do:** read/edit files, run tests, inspect traces, bounded workspace.
- **Sandbox:** `workspace-write` + `ask`; escalation one-shot.
- **Done:** edits a repo and runs its test suite in-sandbox.

## S-03 — Research skill (v1)
- **Do:** web search/fetch, source verification, citations.
- **Done:** returns a cited answer with links.

## S-04 — browser-use tool (v1)
- **Do:** sandboxed browser automation; separate profile; no credential auto-fill.
- **Done:** completes a browser task with allowlisted egress and no vault access.

## S-05 — Computer use (v1.x)
- **Do:** desktop automation + artifact capture; explicit per-session consent; kill switch reachable.
- **Done:** a desktop task completes under consent and can be stopped.

## S-06 — Medical skills (v1.x)
- **Do:** personal, advisory-only domain skills with disclaimers; no diagnosis claims.
- **Done:** disclaimers present; scope enforced.

## S-07 — Mental-health mode (v1.x)
- **Do:** personal, supportive mode with safety guardrails, escalation to human help, no clinical claims.
- **Done:** guardrails tested; crisis path documented.

## S-08 — Controlled self-learn (P2)
- **Do:** agent drafts new skills/patches into a sandbox; user reviews and approves; no autonomous install.
- **Done:** proposal → review → install flow works; rejected proposals discarded.

## S-09 — Full `soul.md` + Distilly (v2)
- **Do:** Distilly is the **process** of distilling BT7274 into a handwritten, versioned identity spec: voice, values, do/don't, escalation rules.
- **Done:** persona consistent across sessions; guardrails verified.

## Dropped
- **"nivix zen" naming** (and "antivirus"/"strike" labels) — dropped. Modes can return later under plain names if needed.

## Acceptance for Phase 4
- Coder edits + tests in-sandbox.
- Research returns citations.
- browser-use completes a sandboxed task.
- Cloud escalation is safe and policy-gated.
- Skills can be added without touching core.