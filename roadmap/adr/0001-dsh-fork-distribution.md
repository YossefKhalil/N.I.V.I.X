# ADR-0001 — Build Nivix as a DSH fork/distribution

## Status
accepted

## Context
DeepSeek Harness (`dsh`) is an MIT-licensed, Cordis-based agent harness with an "everything is a plugin" architecture. Nivix needs deep customization (local inference, memory, vault, sandbox policy, cloud subagent) but does not want to maintain a harness from scratch.

## Decision
Nivix is a **fork** of `deepseek-ai/deepseek-harness` at `YossefKhalil/Ni-Agent`, with:
- Nivix code in separate directories (`nivix/`, `packages/nivix-*`),
- an `upstream` remote and `upstream-sync` branch,
- a `patches/` directory for unavoidable core edits.

## Consequences
- Inherits upstream features and fixes.
- Upstream is developer-preview with breaking changes; syncing must be deliberate.
- Fork discipline is a project rule: minimize edits to upstream files.
- The alternative (plugin-only) remains possible where it does not conflict.