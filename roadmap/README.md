# Nivix Roadmap

The planning set for Nivix. The code lives in the three child repos linked from the [parent README](../README.md).

| Doc | What it answers |
|---|---|
| [ROADMAP.md](./ROADMAP.md) | What ships when, at what priority |
| [architecture.md](./architecture.md) | How the pieces fit and where the trust boundaries are |
| [build-order.md](./build-order.md) | What to build first and what blocks what |
| [security-test-suite.md](./security-test-suite.md) | What must pass before a P0 is "done" |
| [pillars/](./pillars/) | Deep detail per area |
| [adr/](./adr/) | Why the big decisions were made |

## Reading order

1. `ROADMAP.md` — the whole picture.
2. `architecture.md` — the shape.
3. `build-order.md` — the next action.
4. `security-test-suite.md` — the bar.
5. `pillars/` — when you're working in that area.
6. `adr/` — when you want to change a decision.

## Rule

If a decision changes, write an ADR that supersedes the old one. Don't silently edit history.