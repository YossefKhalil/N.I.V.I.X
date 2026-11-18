# ADR-0002 — Local-first, cloud as a sandboxed subagent

## Status
accepted

## Context
Nivix is a personal agent trusted with personal data. Cloud models are useful for heavy tasks but must not receive personal data or device access.

## Decision
- The **local model** (Qwen3.6-35B-A3B via Ni-Strata) is the main agent and has full local access.
- The **cloud model** (DeepSeek V4.1 Flash, `cloud_model`) is a **sandboxed subagent** used only for allowlisted heavy tasks.
- The cloud subagent runs in a separate Cordis context with no memory/vault services, a scratch filesystem, and egress through the credential proxy.
- Escalation requires policy approval by default.

## Consequences
- Personal data stays local.
- Cloud capability is available without ambient access.
- The boundary is architectural, not dependent on the local model's good behavior.
- Local model capability is the ceiling for most work; cloud is a deliberate escalation.