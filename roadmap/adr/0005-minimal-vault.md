# ADR-0005 — Minimal vault: passphrase + keychain + recovery key

## Status
accepted

## Context
Nivix must protect secrets and personal memory in a portable folder without high friction. Envelope encryption with TPM/DEK wrapping was judged overkill for a single-owner machine.

## Decision
- One **memorized master passphrase** → **Argon2id** → vault key.
- First unlock per device stores the key in the **OS keychain** (Windows Credential Manager / DPAPI) for auto-unlock. "Remember this device."
- A **24-word recovery key** is generated once at setup, shown once, never stored on the device.
- Kill switch and idle lock zeroize the in-memory key.
- No envelope/TPM ceremony in v1.

## Consequences
- One secret to remember; low friction.
- Portability: a new device needs the passphrase or recovery key; the keychain is per-device.
- If passphrase, device, and recovery key are all lost, data is unrecoverable — accepted.
- Stronger designs (TPM/Hello, multiple KEKs) can be added later without changing the vault format if the key hierarchy is versioned.