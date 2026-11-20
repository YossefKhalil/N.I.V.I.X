# Local inference benchmark — 2026-11-20

## Setup

| | |
|---|---|
| GPU | NVIDIA GeForce RTX 3050, 6144 MiB, driver 610.62 |
| CPU | Intel i7-8700 (6C/12T) |
| RAM | 16 GB |
| Model | `Qwen3.6-35B-A3B-APEX-I-Compact.gguf` — qwen35moe 35B.A3B, Q4_K_M, 34.66B params, 16.10 GiB |
| Vision projector | `mmproj.gguf` — 0.84 GB (not yet exercised in these runs) |
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

## Why Ni-Strata did not run

- No CUDA toolkit: `nvcc`, CUDA headers (`cuda_runtime.h`), and CUDA import libs are absent. Only `cudart64_12.dll`, `cublas64_12.dll`, `cublasLt64_12.dll` exist.
- No `clang`; Visual Studio 2022 Build Tools are present (MSVC works via `vcvars64.bat`).
- In `Ni-Strata`'s `CMakeLists.txt`, `strata-poly` is only defined under `STRATA_NATIVE_EXPERTS AND (STRATA_ENABLE_CUDA OR STRATA_ENABLE_HIP)`.
- Ni-Strata is Linux-first; Windows support is partial.

**To actually run Ni-Strata here:** install CUDA Toolkit 12.x (~3 GB), then attempt a Windows CMake build of `strata-poly` (likely needs source patches). Alternative: build on a Linux/NVIDIA host.

## Next

1. **MTP/DSpark** for Qwen3.6-35B-A3B — speculative decoding to raise decode.
2. **TurboQuant KV cache** in Ni-Strata — smaller KV, more context, measured speed/memory.
3. Windows-native Ni-Strata build (INF-06), if the CUDA toolkit route is taken.