# Pillar 2 — Core infra

Master list: [ROADMAP.md § Phase 2](../../ROADMAP.md#phase-2--security-core--cloud-subagent).

## CI-01 — Vault
- **Model:** one memorized passphrase → **Argon2id** → vault key.
- **Auto-unlock:** first unlock per device stores the key in the **OS keychain** (Windows Credential Manager / DPAPI). "Remember this device."
- **Recovery:** 24-word recovery key generated once at setup, shown once, **never stored on the device**.
- **Zeroize:** kill switch and idle lock wipe the in-memory key.
- **Done:** V-01..V-10 in the security suite pass.
- **Trade-off:** forget passphrase + lose device + lose recovery phrase = data gone.

## CI-02 — DSH sandbox
- **Do:** mount `sandbox-local` behind `ctx.sandbox`; default preset `workspace-write` + `ask`.
- **Modes:** `read-only` / `workspace-write` / `danger-full-access`.
- **Fail-closed:** missing backend → `SANDBOX_UNAVAILABLE`; never runs bare.
- **Done:** S-01..S-08 pass.
- **Known gap:** DSH's vocabulary is **filesystem effects only** — no network/process/credential limits, same-world.

## CI-03 — Cloud subagent
- **What:** a **sandboxed OpenCode agent** in a **separate Cordis context**.
- **Context:** no memory service, no vault service, `ctx.fs` scoped to a scratch dir, `workspace-write`.
- **Input:** an explicit task bundle from the local model; no ambient access.
- **Output:** a result returned to the local model.
- **Done:** C-01..C-04, C-08 pass.
- **Read gap:** add an ACL **deny-read** on `memory/` for the subagent process if read isolation is required.

## CI-04 — Credential-injection proxy
- **Do:** Caddy (or equivalent) injects credentials at the network boundary; egress allowlist.
- **Rule:** agents see handles, never raw secrets; logs redact.
- **Done:** P-01..P-05 pass.

## CI-05 — Kill switch
- **Do:** stop all activity, terminate subagents, zeroize keys; remote-triggerable.
- **Done:** K-01..K-05 pass; stop <2s.

## CI-06 — Memory write sanitizer
- **Do:** scan content before ingestion for prompt injection, secrets, PII.
- **Policy:** redact or reject per rule; log the decision (not the secret).
- **Done:** M-06, M-07 pass.

## CI-07 — Cloud escalation policy
- **Do:** local model is the default; `cloud_model` (DeepSeek V4.1 Flash) is an explicit escalation.
- **No standalone router.** omnirouter was dropped; this is a policy inside Nivix Core.
- **Policy:** allowlisted task types; approval by default; no automatic escalation for personal-data tasks.
- **Done:** escalation routes correctly; non-allowlisted tasks require approval.

## CI-08 — LlamaFirewall (P1)
- **Do:** wire into the request path; block/allow logging.
- **Done:** known injection payloads blocked.

## CI-09 — VirusTotal + ClamAV (P1)
- **Do:** scan-on-ingest for downloads; verdict cache.
- **Done:** EICAR detected; suspicious files flagged before use.

## CI-10 — Canarytokens (v1)
- **Do:** honey secrets + tripwires; alert on trigger.
- **Done:** triggered canary produces an alert.

## CI-11 — SSH device enrollment (v1.x)
- **Do:** a small cross-platform script / QR code enrolls a target device; **the Master Nivix on the main system must grant access**.
- **Scope:** Nivix can SSH only to devices it has been explicitly granted; no blanket access.
- **Done:** a device enrolls and a granted SSH session succeeds; ungranted devices fail.
- **Note:** a full portable USB clone can carry Nivix to another device; enrollment is what grants SSH back to the Master.

## Acceptance for Phase 2
- Local/cloud separation proven.
- Secrets never exposed.
- Kill switch works.
- Sandbox fails closed.