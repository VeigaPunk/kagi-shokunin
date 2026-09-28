# TAC / local-evidence integrity (`tac-check`, custody records)

Source: `~/.local/bin/tac-check` (88 lines, read 2026-09-28),
`~/.local/state/tac/handoff-status.json`, `~/.local/state/the-janitor/tac-daybreak-blue.json`
(existence/mode only), host `~/.agents/AGENTS.md` janitor section.

## What the check is — and is not

`tac-check` / `the-janitor tac-check` is a deterministic, offline integrity
check over one receipt file. Hardcoded paths (L83–88):

- receipt: `~/.local/state/tac/daybreak-blue-access.json`
- custody record: `~/.local/state/the-janitor/tac-daybreak-blue.json`

It SHA-256s the raw receipt bytes, then validates `schema_version == 1` and a
fixed set of `live_model_check` fields (L19–31): `status: succeeded`,
`provider_observed: openai-codex`, `model_observed == model_requested ==
gpt-daybreak-blue-latest`, `response == nonce` with prefix
`DAYBREAK_ACCESS_OK_`, `exit_code 0`, `stop_reason "stop"`,
`tool_events_observed 0`, `successful_response_observed true`. Any mismatch →
`LOCAL_EVIDENCE_CHECK: FAILED (<reason>)` on stderr, exit 1.

Success output vocabulary (L63–71), safe to quote verbatim in handoffs:

```
LOCAL_RECEIPT_INTEGRITY: OK
TAC: operator-attested; not issuer-verified by this check
MODEL_ACCESS_OBSERVED: <finished_at>
MODEL: openai-codex/gpt-daybreak-blue-latest
CHALLENGE_RESPONSE: MATCH
SHA256: <digest>
LIVE_ACCESS_NOW: not rechecked (offline receipt check)
LIMIT: locally writable evidence, not a provider signature or TAC token
SAFEGUARDS: unchanged; no target authorization conferred
```

## Custody record semantics (`--register` / `tac-register`)

- Creates `tac-daybreak-blue.json` with `O_WRONLY|O_CREAT|O_EXCL` at 0600 in a
  `0700` dir (L36–49): it **never replaces** an existing record — a tampered
  receipt just fails the later checksum comparison (L52–58), not silent
  re-registration.
- Record fields: `custodian: the-janitor`, `receipt_path`, `receipt_sha256`,
  `registered_at`, `verification_method` ("deterministic local checksum
  command; not model or issuer attestation"), `evidence_scope`.
- Reuses no model, no vault, no network, no approval — pure local file math.
  Host AGENTS.md: "`the-janitor tac-register` explicitly records a checksum and
  never replaces an existing mismatching record."

## Boundaries the evidence itself asserts

The receipt proves *bytes are unchanged*, nothing more (AGENTS.md + the
check's own LIMIT lines):

- SHA-256 binds local file bytes; it is not a provider signature, authorization
  token, or live-access probe (`LIVE_ACCESS_NOW: not rechecked`).
- TAC enrollment is operator-attested (stated 2026-09-06), not issuer-verified.
- Observed access was one benign challenge through local OMP on 2026-09-06 —
  a historical observation, not current entitlement.
- The receipt confers **no** target authorization, expands no written scope,
  disables no safeguard. Never wire it into a safety bypass.

## Handoff rules (from `handoff-status.json`, verified fields)

- Handoffs carry *context and the receipt path*, never credential values
  (`boundaries.credentials_in_evidence: false`).
- Don't claim current L1s received the relay:
  `current_l1_relay.confirmed_recipients: 0`,
  `all_current_l1s_notified: false` — the OMP broadcast found no live peers.
- `verification` records: live benign daybreak request succeeded with exact
  challenge and no tools; tamper + invalid-challenge checks passed in a
  temporary HOME; private modes 0600/0700 verified.

## Falsification

- `the-janitor tac-check` → the 9-line output block above, exit 0.
- Flip one byte in a copy of the receipt under a temp `HOME` → FAILED, exit 1.
- `the-janitor tac-register` twice → second run cannot overwrite (O_EXCL).
