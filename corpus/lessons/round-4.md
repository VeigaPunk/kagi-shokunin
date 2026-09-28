# Lessons — round 4

Round context: kagi L1 dispatched (`.ufo/prompts/kagi-round-4.md`). Goal:
pick the highest-value corpus gap. The open item "service-account path"
(README known gaps) plus the scattered env-var surface won — the auth
selectors were never documented anywhere.

## What happened

Re-read `cmd_serve` (L186–226) and the script header (L1–27) with fresh eyes;
probed live surfaces to confirm nothing drifted since round 3.

## What worked

- **The service-account path is real and already implemented.** `_serve`
  L194: `if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]` — token present ⇒ the
  entire interactive chain (`op account get` → `op signin --raw` → `op
  whoami`) is skipped. This is the headless route; it was the missing piece
  in the round-3 "how would this ever run unattended" question.
- **`OP_ACCOUNT` exists** (L196–197): expands to `--account <value>` on all
  three `op` calls — the multi-account selector. Both selectors are invisible
  in `usage()`; the knob table in `knowledge/janitor-env-contract.md` is the
  only complete inventory.
- **`op account get` works signed out** (like `account list`): returns
  `url`, `email`, `user_uuid`, `account_uuid`, `domain`, `type`, `state`.
  `.domain` is what builds `OP_SESSION_<domain>`. Values are PII — shape only
  recorded.

## What failed / newly discovered

- **Two endpoint strings, one is cosmetic.** `MODEL_ENDPOINT` (L17) is a
  hardcoded literal feeding only `status`'s display line. The real request
  path URL is `provider.qwen-local.options.baseURL` in `opencode.json`. So
  the round-3 drift fix is one JSON field, but `status` will keep printing
  the stale literal — verifying via `status` after the fix would mislead.
- **`op.env` is not all `op://` refs.** Live `refs` (2026-09-28, 10 keys):
  two keys carry raw values (`XAI_TEAM_ID`, `TOKEN_PLAN_INFNET_IDENT` —
  identifier-class, still redacted by `refs` and at 0600). The
  "everything is a ref" convention is aspirational.
- **Credential strip is asymmetric.** `_serve` unsets ~19 model/API vars but
  leaves `OP_SESSION_*`, `OP_ACCOUNT`, `OP_SERVICE_ACCOUNT_TOKEN` — by design
  for the last one, but a stray caller-side `OP_SESSION_<other-domain>` would
  survive into the handler env.

## Rules extracted (carry forward)

1. Env-var inventory lives in the knob table, not `usage()` — `usage()` is
   silent on every knob including the auth selectors.
2. "Fix the endpoint" means `opencode.json` `baseURL`; there is no env
   override and the `status` line is decorative.
3. Raw values can exist in `op.env` — only the `^[A-Z][A-Z0-9_]*=` shape +
   `op://` prefix get shown by `refs`; identifiers-as-plaintext are observed
   reality, not a violation signal by themselves.
4. PII class for artifacts now explicitly includes `op account get`/`account
   list` values (emails, UUIDs, names) alongside `op://` ref paths.
