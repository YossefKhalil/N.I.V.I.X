# Local inference benchmark — 2026-11-20

## Setup

| | |
|---|---|
| GPU | NVIDIA GeForce RTX 3050, 6144 MiB, driver 610.62 |
| CPU | Intel i7-8700 (6C/12T) |
| RAM | 16 GB |
| Model | `Qwen3.6-35B-A3B-APEX-I-Compact.gguf` — qwen35moe 35B.A3B, Q4_K_M, 34.66B params, 16.10 GiB |
| Vision projector | `mmproj.gguf` — 0.84 GB (present; not exercised yet) |
| Backend | Prebuilt **llama.cpp CUDA** 0.7.0-dev (build 11869, commit d327bf1f0) |
| Flags | `-ngl 99 -ncmoe 99` (all MoE experts on CPU, dense layers on GPU) |

> This is **llama.cpp**, not Ni-Strata. It establishes the baseline while the Ni-Strata build is blocked (see below).

## Results

| Threads | FA | KV | pp128 | tg32 | pp512 | tg128 |
|---:|---|---|---:|---:|---:|---:|
| 6 | off | f16 | **17.98** | 15.45 | — | — |
| 12 | on | f16 | 14.42 | 19.97 | — | — |
| 12 | off | f16 | 12.05 | **20.20** | — | — |
| 12 | on | q8_0 | 15.19 | 20.16 | **82.33** | **23.77** |

**Headline (stable, long run):** **pp512 ≈ 82.3 t/s · tg128 ≈ 23.8 t/s** at 12 threads, flash attention on, q8_0 KV cache.

Notes:
- Short-prompt prefill (`pp128`) is noisy and under-reports; the `pp512` number is the stable one.
- 12 threads helps decode (~+30%) but hurts short prefill on this 6-core CPU.
- q8_0 KV cache is a memory win with no decode penalty here.

## Speculative decoding — local tests (no download)

Tool: `llama-cli`, same model, `-t 12 -fa on -ctk q8_0 -ctv q8_0 -n 128`, repetitive JSON prompt.

| Config | Prompt t/s | Generation t/s | Verdict |
|---|---:|---:|---|
| baseline | 15.7 | **20.7** | reference |
| `--spec-type ngram-mod` (n-match 24, n-min 48, n-max 64) | 13.7 | 20.7 | no gain |
| `--spec-type ngram-simple --spec-draft-n-max 64` | 41.5 | 20.5 | no gain |
| `--moe-cache-mib 2048` | 31.0 | 13.3 | **worse decode** |

Prompt t/s is noisy (warm file cache); generation is the stable metric. **None of the no-download modes improved generation.**

## Speculative decoding — research

| Method | llama.cpp support | Needs | Evidence | Verdict for this box |
|---|---|---|---|---|
| **MTP** | `--spec-type draft-mtp` | MTP-capable GGUF (head baked in) | Unsloth ships `Qwen3.6-35B-A3B-MTP-GGUF`; byteshape too | **Only candidate worth testing** |
| **DSpark** | `--spec-type draft-dspark` | separate DSpark drafter | No Qwen3.6-35B-A3B DSpark drafter found | Skip for now |
| **DFlash** | `--spec-type draft-dflash` | DFlash drafter + conversion | RTX 3090 test: **−44.6%** on consumer Ampere Q4 | Skip |
| **n-gram** | `ngram-simple`, `ngram-mod`, `ngram-cache`, `ngram-map-*` | none | Local: no gain; RTX 3090: −3…−12% | Skip |
| **MoE expert cache** | `--moe-cache-mib N` | none | Local 2048 MiB: decode 13.3 t/s | Try 512/1024 later, low hope |

### MTP details (the one to try)
- Model: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF` — the MTP head is baked into the GGUF, no separate draft model.
- Sizes: UD-Q2_K_XL **12.57 GB** · UD-Q3_K_M 17.10 GB · UD-Q4_K_M 22.66 GB · UD-Q4_K_XL 22.85 GB · UD-Q8_K_XL 39.1 GB.
- Command: `--spec-type draft-mtp --spec-draft-n-max 2`.
- The current `APEX-I-Compact.gguf` is not an MTP repo; assume no MTP head.

### Why most spec-decode loses here
For a 3B-active A3B MoE, each drafted token pulls a fresh expert slice; the verify pass pays for the expert union with no amortization. 100% draft acceptance does not rescue it. This is the MoESD / Utility-Driven SD result, reproduced on RTX 3090 across n-gram, draft-model, and DFlash. MTP is structurally different (it reuses the target's own MTP head), so it is the exception worth measuring.

## Why Ni-Strata did not run

- No CUDA toolkit: `nvcc`, CUDA headers (`cuda_runtime.h`), and CUDA import libs are absent. Only `cudart64_12.dll`, `cublas64_12.dll`, `cublasLt64_12.dll` exist.
- No `clang`; Visual Studio 2022 Build Tools are present (MSVC works via `vcvars64.bat`).
- In `Ni-Strata`'s `CMakeLists.txt`, `strata-poly` is only defined under `STRATA_NATIVE_EXPERTS AND (STRATA_ENABLE_CUDA OR STRATA_ENABLE_HIP)`.
- Ni-Strata is Linux-first; Windows support is partial.

**To actually run Ni-Strata here:** install CUDA Toolkit 12.x (~3 GB), then attempt a Windows CMake build of `strata-poly` (likely needs source patches). Alternative: build on a Linux/NVIDIA host.

## Next

1. **MTP** — download `unsloth/Qwen3.6-35B-A3B-MTP-GGUF` (Q2_K_XL 12.57 GB or Q4_K_M 22.66 GB), run `--spec-type draft-mtp --spec-draft-n-max 2`, compare against 23.77 t/s.
2. **TurboQuant KV cache** in Ni-Strata — smaller KV, more context, measured speed/memory.
3. Windows-native Ni-Strata build (INF-06), if the CUDA toolkit route is taken.