# ADR-0003 — Use DSH's native sandbox, not a custom one

## Status
accepted

## Context
Nivix needs process confinement for tool execution and for the cloud subagent. A custom cross-platform `SandboxProvider` (AppContainer, Landlock, Seatbelt, Node permissions) would be a large, inconsistent surface.

DSH already ships `ctx.sandbox` / `dsh-sandbox`: per-call file policy, `read-only` / `workspace-write` / `danger-full-access`, fail-closed `SANDBOX_UNAVAILABLE`, and OS backends (Windows ACL, Linux Landlock).

## Decision
Use DSH's native sandbox + `sandbox-local` + permission presets. Do not build a custom sandbox.
For the cloud subagent, add only what DSH lacks: a separate Cordis context (no memory/vault), scratch `ctx.fs`, egress via the credential proxy, and optionally an ACL deny-read on `memory/`.

## Consequences
- Less code, fewer inconsistencies, upstream maintenance.
- Known limits: filesystem effects only; same-world; Windows ACL is partial.
- Network/credential isolation comes from the proxy and context separation, not the sandbox.