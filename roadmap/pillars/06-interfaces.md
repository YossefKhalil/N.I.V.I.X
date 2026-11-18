# Pillar 6 — Interfaces

Master list: [ROADMAP.md § Phase 5](../../ROADMAP.md#phase-5--interface--portability).

## UI-01 — Nivix theme/brand
- **Do:** brand the DSH web + desktop UI (logo, palette, typography).
- **Done:** consistent Nivix identity across web and desktop.

## UI-02 — Portable profile/bundle
- **Do:** one folder containing app, runtime, config, memory, vault, models, launch script.
- **Layout:**
  ```
  nivix/
  ├── app/            # Nivix + DSH runtime
  ├── runtime/        # Node, Python sidecar, Ni-Strata binaries
  ├── config/         # profiles, permission presets, model config
  ├── memory/         # Graphiti/LadybugDB data (gitignored, encrypted)
  ├── vault/          # encrypted vault + recovery metadata (gitignored)
  ├── models/         # GGUF model files
  └── start.(cmd|sh)
  ```
- **Done:** folder runs on a clean machine with the same state.

## UI-03 — Launch scripts
- **Do:** `start.cmd` (Windows) and `start.sh` (Linux) start the sidecars, then DSH, then open the UI.
- **Done:** one command starts Nivix; graceful shutdown.

## UI-04 — USB cold-start
- **Do:** run from a USB drive; host GPU optional; CPU/iGPU fallback via the floor model.
- **Done:** <60s to usable; state persists.

## UI-05 — Backup/restore
- **Do:** encrypted backup of vault + memory; restore to a clean folder.
- **Done:** M-08/T-01..T-03 pass.

## UI-06 — Other surfaces (v2 / v3)
- **Mobile (v2):** thin client over the local API.
- **Discord + voice (v2):** bot surface and voice I/O; sandboxed; no memory admin.
- **Ni-Watch (v3):** custom smartwatch hardware; blueprint at `Ni-Watch Blueprint.html`.
- **Ni-Volt (v3):** custom hardware; blueprint at `Ni-Volt Blueprint.html`.
- **Done:** each surface has an acceptance test and respects the same permission model.

## Interface rules
- Every surface goes through Nivix Core, never talks to the model directly.
- Secrets are never rendered in a UI.
- The kill switch is reachable from every surface.
- Mobile/remote surfaces require auth.

## Acceptance for Phase 5
- Web + desktop branded and usable.
- Portable folder proven on a second machine.
- USB cold start <60s.
- Backup/restore verified.