# Architecture Decision Records

Short, immutable records of decisions that shape Nivix. Format: context → decision → consequences.

| ADR | Title | Status |
|---|---|---|
| [0001](./0001-dsh-fork-distribution.md) | Build Nivix as a DSH fork/distribution | accepted |
| [0002](./0002-local-first-cloud-subagent.md) | Local-first, cloud as a sandboxed subagent | accepted |
| [0003](./0003-dsh-native-sandbox.md) | Use DSH's native sandbox, not a custom one | accepted |
| [0004](./0004-graphiti-temporal-memory.md) | Graphiti temporal KG for memory | accepted |
| [0005](./0005-minimal-vault.md) | Minimal vault: passphrase + keychain + recovery key | accepted |
| [0006](./0006-portable-folder.md) | One portable folder, no Docker | accepted |
| [0007](./0007-inference-platform.md) | Inference platform: Linux-first, Windows port planned | accepted |

New decisions get the next number. Superseding an ADR means writing a new one and marking the old one `superseded by NNNN`; never edit history.