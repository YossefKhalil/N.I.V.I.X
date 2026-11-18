# Pillar 3 — Memory

Master list: [ROADMAP.md § Phase 3](../../ROADMAP.md#phase-3--memory-graphiti--ladybugdb).

## Why Graphiti
Mem0-style flat stores accumulate facts. A personal agent needs **temporal truth**: facts change, old facts are invalidated (not deleted), and "what was true then" must be answerable. Graphiti is the temporal context-graph framework that does this.

## M-01 — Memory sidecar (Windows-native, no Docker, no WSL2)
- **Repo:** `YossefKhalil/Ni-Zep` (fork of `getzep/graphiti`).
- **Backend:** **LadybugDB** — the maintained Kuzu fork, MIT, native Windows wheels/CLI, embedded file.
- **Wiring:** Graphiti has no dedicated LadybugDB driver; it runs through the Kuzu driver with an alias:
  ```python
  import sys, ladybug
  sys.modules.setdefault("kuzu", ladybug)
  from graphiti_core import Graphiti
  from graphiti_core.driver.kuzu_driver import KuzuDriver
  driver = KuzuDriver(db="nivix/memory/graph.ladybug")
  graphiti = Graphiti(graph_driver=driver)
  ```
- **LLM:** local model via OpenAI-compatible `/v1`; `structured_output_mode="json_object"`.
- **Telemetry:** `GRAPHITI_TELEMETRY_ENABLED=false`.
- **Service:** thin authenticated HTTP wrapper (Graphiti's reference servers are unauthenticated).
- **Fallback:** bundled **Neo4j Community** (JRE + server) — still native Windows, no Docker/WSL2.
- **Done:** sidecar ingests and recalls over HTTP on Windows.

## M-02 — Nivix memory client
- **Do:** Node client for `addEpisode`, `recall`, `temporalQuery`, `delete`.
- **Done:** add + recall + time-scoped query from Node.

## M-03 — Temporal schema
- **Entities:** people, projects, devices, preferences, events.
- **Facts:** triplets with `valid_at` / `invalid_at`; contradiction invalidates, never deletes.
- **Episodes:** raw interaction as provenance.
- **Ontology:** small prescribed set (Pydantic models); grow later.
- **Done:** M-01..M-04 pass.

## M-04 — Retrieval budget
- **Do:** hybrid semantic + BM25 + graph traversal; top-k with validity filtering; ≤6K tokens; sub-second.
- **Done:** M-05 passes.

## M-05 — Memory tests
- **Do:** invalidation, provenance, "what was true at T", injection-as-data, PII redaction.
- **Done:** M-01..M-09 pass.

## M-06 — Encrypted backup/restore
- **Do:** export graph + episodes to an encrypted archive; restore round-trip.
- **Done:** M-08 passes; restore verified on a clean folder.

## Operational risks
- **LadybugDB rides Graphiti's deprecated Kuzu driver.** Pin `graphiti-core` and `ladybug`; re-test on upgrade.
- **Windows write path:** a known Kuzu Windows crash exists (`add_episode` access violation). LadybugDB is the maintained fork; verify writes at ~500+ nodes early.
- **FTS indices:** the Kuzu driver's `build_indices_and_constraints` may not create full-text indices; create them explicitly on first read-write open.
- **Single writer:** LadybugDB allows one read-write open + many read-only readers. Design the sidecar accordingly.
- **Structured output:** local model must produce valid JSON; test 20 runs, keep `SEMAPHORE_LIMIT` low.
- **Never** send personal data to the cloud for extraction. Use the local model only.

## Acceptance for Phase 3
- Remembers across restarts on Windows.
- Contradictions invalidate with history preserved.
- Time-scoped questions answered correctly.
- Recall ≤6K tokens, sub-second.
- Backup/restore works.