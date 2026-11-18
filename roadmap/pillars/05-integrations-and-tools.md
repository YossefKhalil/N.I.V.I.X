# Pillar 5 — Integrations and tools

Master list: [ROADMAP.md § Phase 6](../../ROADMAP.md#phase-6--optional-expansions).

## v1 baseline (in DSH)
- Filesystem tools (workspace-scoped)
- Shell execution (sandboxed)
- Web fetch/search (research skill)
- Browser automation (browser-use, v1)
- Session traces / trajectory view

## T-01 — aria2 (v1.x)
- High-speed multi-protocol downloader.
- **Gate:** download → ClamAV/VirusTotal scan → allow/quarantine.

## T-02 — yt-dlp (v1.x)
- Media download/extraction.
- **Gate:** same scan gate; no auto-execution of downloaded media.

## T-03 — ego lite wrapper for browser-use (v1.x)
- Ultrafast wrapper around the v1 browser-use tool.
- **Gate:** same sandbox + egress allowlist as browser-use.

## Dropped
| Item | Reason |
|---|---|
| Blender MCP | Dropped |
| Minecraft modding | Dropped |
| Image generation | Dropped |
| hexstrike | Dropped |

## Rules for every integration
1. Runs under a DSH sandbox mode.
2. Has no memory/vault access unless explicitly granted.
3. Egress via the proxy/allowlist.
4. Outputs are scanned before use.
5. Can be disabled by the kill switch.

## Acceptance
- Each integration has a skill wrapper, a sandbox profile, and tests.
- Gated tools require explicit authorization.