# ADR-0007 — Inference platform: Linux-first, Windows port planned

## Status
accepted

## Context
`Ni-Strata` is forked from `robertkarl/UnbiasedStrata`, which targets **Linux x86-64 + NVIDIA + CUDA 12.x**. Nivix must be portable and must not require Docker or WSL2. A native Windows inference path does not exist yet.

## Decision
- **v1 runs the inference engine on native Linux/NVIDIA.**
- **Porting Ni-Strata/UnbiasedStrata to native Windows is the plan, deferred** (task INF-06).
- Until the port lands, Windows can run everything except local inference; if Windows-native inference is needed sooner, a fallback backend is added behind the same `InferenceBackend` interface — never by weakening the portability rule.

## Consequences
- v1 is honest about its platform: memory is native Windows (LadybugDB), inference is Linux-first.
- The `InferenceBackend` abstraction keeps the Windows port a backend swap, not an architecture change.
- A Windows-native fallback is optional and does not replace UnbiasedStrata as the performance engine.
- No Docker and no WSL2 anywhere in the required path.