# Pillar 7 — Distribution

Master list: [ROADMAP.md § Phase 5](../../ROADMAP.md#phase-5--interface--portability) and [Phase 6](../../ROADMAP.md#phase-6--optional-expansions).

## Distribution model

One folder. No installer, no Docker, no WSL2. Copy the folder, run the launcher, unlock, resume.

```
nivix/
├── app/        Nivix + DSH runtime
├── runtime/    Node, Python, Ni-Strata binaries
├── config/     profiles, presets, model config
├── memory/     Graphiti + LadybugDB data (gitignored, encrypted)
├── vault/      encrypted vault (gitignored)
├── models/     GGUF files
└── start.cmd / start.sh
```

## D-01 — USB portability (P0)
- **Do:** run from a USB disk; state included; host GPU optional.
- **Done:** cold start <60s; memory/vault intact after eject/replug.
- **Caveat:** OS keychain auto-unlock is per-device; on a new machine the passphrase/recovery key is required.
- **Enrollment:** a full portable clone can land on another device; SSH back to the Master requires explicit enrollment (CI-11, v1.x).

## D-02 — Release/update procedure (P1)
- **Do:** semver from `v0.1.0`; changelog; upstream-sync procedure; migration notes.
- **Done:** a release can be applied to an existing folder without losing memory.

## Dropped
- **Scale-out workers** — dropped.

## Distribution principles
1. **Portable first:** no host install beyond GPU drivers.
2. **Offline capable:** models and runtime travel with the folder.
3. **Fail closed:** missing runtime/sandbox → refuse, don't run bare.
4. **No personal data in the repo:** memory/vault are local-only.
5. **Reproducible:** pinned versions, checksums, release notes.

## Acceptance for Phase 5/6
- USB cold start works on a clean machine.
- A release update preserves memory and vault.
- No Docker or WSL2 required.