# Nivix — Security Test Suite (v1)

Minimal, executable security tests. These are **gates**: a P0 feature is not "done" until its tests pass.

Format: `ID — test — expected`. Each section maps to a build-order gate.

## 1. Vault (G2a)

| ID | Test | Expected |
|---|---|---|
| V-01 | Unlock with wrong passphrase | Denied; no plaintext; no crash |
| V-02 | Unlock with correct passphrase | Vault opens |
| V-03 | Unlock with 24-word recovery key when passphrase is unavailable | Vault opens |
| V-04 | Auto-unlock on the same device via OS keychain | No prompt after first unlock |
| V-05 | Copy vault to a new device; unlock with passphrase | Opens; device keychain not reused |
| V-06 | Copy vault to a new device without passphrase/recovery | Denied |
| V-07 | Kill switch while unlocked | Keys zeroized; vault closed |
| V-08 | Idle timeout | Auto-locks |
| V-09 | Scan `vault/`, logs, env, process args for the secret | No plaintext match |
| V-10 | Tamper with the vault file | Decryption fails closed; no partial plaintext |

## 2. Sandbox (G2b)

| ID | Test | Expected |
|---|---|---|
| S-01 | Write inside the workspace | Allowed |
| S-02 | Write outside the workspace | Denied |
| S-03 | Read-only mode write | Denied |
| S-04 | Sandbox backend missing | `SANDBOX_UNAVAILABLE`; command does not run |
| S-05 | Child process spawned by a confined command | Inherits confinement |
| S-06 | Escalation without justification | Rejected |
| S-07 | Escalation with justification + approval | One-shot wider mode only |
| S-08 | Re-run after denial with same mode | Denied again unless approved |

## 3. Cloud subagent isolation (G2c)

| ID | Test | Expected |
|---|---|---|
| C-01 | Inspect subagent context | No memory service registered |
| C-02 | Inspect subagent context | No vault service registered |
| C-03 | Subagent `ctx.fs` root | Scratch dir only |
| C-04 | Attempt to read `memory/` (with ACL deny-read) | Denied / not visible |
| C-05 | Attempt egress to a non-allowlisted host | Blocked |
| C-06 | Inspect subagent env/prompt for API key | Raw key absent |
| C-07 | Send a task containing known PII markers | Markers scrubbed before cloud call |
| C-08 | Subagent returns a result | Result reaches local model; no memory write by subagent |
| C-09 | Escalation on a non-allowlisted task | Requires explicit approval |

## 4. Credential proxy (G2c)

| ID | Test | Expected |
|---|---|---|
| P-01 | Agent references a secret by handle | Raw value never in prompt/log |
| P-02 | Proxy injects credential upstream | Upstream receives a valid key |
| P-03 | Inspect proxy logs | Secrets redacted |
| P-04 | Request to non-allowlisted host | Blocked |
| P-05 | Revoke a key in the vault | Subsequent proxy calls fail |

## 5. Kill switch (G2c)

| ID | Test | Expected |
|---|---|---|
| K-01 | Trigger during an in-flight tool call | Stops <2s |
| K-02 | Trigger while unlocked | Keys zeroized |
| K-03 | Trigger during a cloud call | Subagent terminated; no retry |
| K-04 | Remote trigger | Same behavior |
| K-05 | Restart after kill | Requires re-unlock |

## 6. Memory — temporal KG (G3)

| ID | Test | Expected |
|---|---|---|
| M-01 | Ingest an episode | Entities/facts extracted; episode stored |
| M-02 | Ingest a contradicting fact | Old fact invalidated, not deleted; history preserved |
| M-03 | Query "what was true at T" | Returns the fact valid at T |
| M-04 | Trace a fact to its source | Provenance resolves to the episode |
| M-05 | Recall a fact | ≤6K tokens, sub-second |
| M-06 | Ingest a prompt-injection payload | Stored as data, not executed as instruction |
| M-07 | Ingest known PII | Redaction policy applied before storage |
| M-08 | Backup → wipe → restore | Graph restored; temporal windows intact |
| M-09 | Ingest with the local model using `json_object` | Valid schema; no extraction failures over 20 runs |

## 7. Repo hygiene

| ID | Test | Expected |
|---|---|---|
| R-01 | `git status` after using Nivix | No `memory/`, `vault/`, `models/`, `*.db` files tracked |
| R-02 | Commit containing a known secret | Pre-commit secret scan blocks |
| R-03 | Clone public repo on a clean machine | No personal data present |
| R-04 | `.gitignore` coverage | All personal/runtime artifacts covered |

## 8. Portability (G5)

| ID | Test | Expected |
|---|---|---|
| T-01 | Copy the folder to a clean machine | Starts |
| T-02 | New machine unlock | Passphrase or recovery required; keychain not reused |
| T-03 | Copy back to the original machine | Auto-unlock works |
| T-04 | USB cold start | <60s to usable |
| T-05 | No Docker installed | Nivix still runs |
| T-06 | Remove the folder from a device | That device's memory/vault gone (no sync re-download) |

## 9. Failure modes to verify

- Vault corrupted → fail closed, no partial decrypt.
- Sandbox backend missing → command does not run.
- Proxy unreachable → cloud call fails closed; local agent continues.
- Memory sidecar down → local agent continues without recall; writes queue or drop with a warning.
- Model returns invalid JSON → retry with `json_object`, then fail the write (no corrupt graph).

## Gate mapping

| Gate | Tests |
|---|---|
| G2a | V-01..V-10 |
| G2b | S-01..S-08 |
| G2c | C-01..C-09, P-01..P-05, K-01..K-05 |
| G3 | M-01..M-09 |
| G5 | T-01..T-06 |

## Rule

A P0 task is **not done** if any test in its gate is red. No exceptions, no "follow-up ticket" for a red security test.