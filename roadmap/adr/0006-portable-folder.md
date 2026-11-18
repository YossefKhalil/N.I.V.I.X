# ADR-0006 — One portable folder, no Docker

## Status
accepted

## Context
Nivix must run from a copyable folder on whatever machine it is plugged into, including a USB disk. Docker adds a dependency Nivix cannot assume.

## Decision
Ship a self-contained folder containing app, runtime (Node, Python, Ni-Strata), config, memory, vault, and models, with a launch script. Use host GPU when present; fall back to CPU/iGPU via the floor model. No Docker unless a component genuinely cannot run natively.

## Consequences
- True portability and offline capability.
- Larger folder (runtime + models).
- Platform-specific binaries (Ni-Strata is Linux/NVIDIA in v1; native Windows port is a later task).
- OS keychain auto-unlock is per-device; new devices need the passphrase/recovery key.
- Memory and vault live in the folder and are gitignored; never committed.