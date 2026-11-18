# N.I.V.I.X PROJECT

Parent repository for the **Nivix** project. The code lives in three child repositories; this repo holds the roadmap and the cross-repo documentation.

> Nivix is a personal, portable, local-first AI agent platform. Built on DeepSeek Harness, with a temporal memory and a sandboxed cloud helper. No Docker, no WSL2.

> GitHub slug: `N.I.V.I.X-PROJECT` — GitHub does not allow spaces in repository names. The local folder keeps the space.

## Repositories

| Repo | Role | Upstream |
|---|---|---|
| [**Ni-Agent**](https://github.com/YossefKhalil/Ni-Agent) | Agent runtime — DSH fork, Nivix Core, skills, interfaces | [`deepseek-ai/deepseek-harness`](https://github.com/deepseek-ai/deepseek-harness) |
| [**Ni-Zep**](https://github.com/YossefKhalil/Ni-Zep) | Temporal memory — Graphiti fork (LadybugDB backend) | [`getzep/graphiti`](https://github.com/getzep/graphiti) |
| [**Ni-Strata**](https://github.com/YossefKhalil/Ni-Strata) | Local inference — UnbiasedStrata fork | [`robertkarl/UnbiasedStrata`](https://github.com/robertkarl/UnbiasedStrata) |

## Roadmap

All planning docs live in [`roadmap/`](./roadmap/):

| Doc | Purpose |
|---|---|
| [ROADMAP.md](./roadmap/ROADMAP.md) | Phases, tasks, priorities, acceptance criteria |
| [architecture.md](./roadmap/architecture.md) | Locked architecture, data flows, trust boundaries |
| [build-order.md](./roadmap/build-order.md) | Ordered steps, dependency graph, gates G0–G5 |
| [security-test-suite.md](./roadmap/security-test-suite.md) | Minimal v1 security gates |
| [pillars/](./roadmap/pillars/) | Per-pillar detail (foundation → distribution) |
| [adr/](./roadmap/adr/) | Architecture decision records |

## Clone everything

```powershell
./scripts/clone-all.ps1
```

```bash
./scripts/clone-all.sh
```

Clones land in `repos/` (gitignored). The parent stays light; child repos are independent.

## Layout

```
N.I.V.I.X PROJECT/
├── README.md
├── roadmap/
├── repos/          # clone targets (gitignored)
└── scripts/
```

## Rules

- The parent repo holds **plans, not personal data**. Memory and vault live in the portable Nivix folder, never here.
- Child repos are independent; update them on their own cadence.
- A decision that spans repos gets an ADR here first.
- No Docker, no WSL2 in any required path.

## Status

Architecture locked. Implementation starts at **Step 0** in [build-order.md](./roadmap/build-order.md).