# ADR-0004 — Graphiti temporal KG for memory

## Status
accepted

## Context
A personal agent must remember how facts change over time, not just accumulate them. Mem0-style flat stores lack a temporal model. Graphiti provides bi-temporal facts (validity windows), automatic invalidation of contradicted facts, episode provenance, and hybrid retrieval without an LLM in the retrieval loop.

## Decision
Use **Graphiti** (forked as `YossefKhalil/Ni-Zep`) with:
- embedded **LadybugDB** (maintained Kuzu fork, Windows-native, MIT) via Graphiti's Kuzu driver alias — no Docker, no WSL2; fallback is bundled Neo4j Community,
- the local model via OpenAI-compatible `/v1` with `structured_output_mode="json_object"`,
- telemetry disabled,
- a thin authenticated HTTP service owned by Nivix.

## Consequences
- Accurate "what is true now" and "what was true then".
- Provenance from fact to episode.
- A Python sidecar and a graph database to operate.
- Local-model structured output must be validated (main risk).
- Alternative considered: Cognee (simpler, local, TS SDK) — rejected for v1 because it is not bi-temporal.