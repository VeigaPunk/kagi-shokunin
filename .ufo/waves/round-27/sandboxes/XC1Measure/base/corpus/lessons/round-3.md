# Lessons — round 3

Round context: kagi L1 dispatched (`.ufo/prompts/kagi-round-3.md`). Goal: run
the one missing end-to-end proof (`the-janitor request`) and close the
`op`-CLI knowledge gap. Both attempted against live surfaces 2026-09-28.

## What happened

`echo 'Reply with the single word READY.' | the-janitor request` ran the full
pipeline — stdin contract, `client.lock` flock, `ensure_started`, tmux
`janitor` spawn, `_serve` env strip — and failed at the 1Password auth gate
after ~60 s wall time:

```
the-janitor: handler exited before becoming ready
Enable 1Password Settings -> Developer -> Integrate with 1Password CLI, unlock the app, then retry.
```
exit 1. Cause chain confirmed by probes: caller-side `the-janitor whoami` →
`account is not signed in` (exit 1), and `op signin --raw` inside tmux dies
non-interactively instead of prompting. Cleanup afterwards: `the-janitor
stop` → `already stopped`, exit 0; no tmux session, no `session-id` left.

## What worked

- **Negative end-to-end is still evidence.** The run exercised every stage up
  to auth and produced the exact boundary text the SKILL.md failure table
  predicted — the domain's honest answer today is "operator signin required",
  recorded with timing and exit code, not a stub.
- **`the-janitor whoami` is a ~20 ms predictor.** Its exit code tells you
  whether a `request` will die in the readiness loop before spending 60 s.
- **`op account list` works while signed out.** Registered-account metadata is
  readable offline; it is also PII — record shape only.

## What failed / newly discovered

- **Endpoint drift, undetected by every gate.** `opencode.json` pins
  `127.0.0.1:8080/v1`; port 8080 is a Jitsi videobridge; the real llama-server
  serves the same model on **34113**. `status` prints the endpoint string but
  never probes it; the readiness loop only checks OpenCode health on 40961.
  Even with auth fixed, requests would have hit Jetty 404s.
- **`handler exited before becoming ready` is overloaded.** It means
  "op signin died", not just "unlock the app" — the hint text under-specifies
  the actual failure (caller-side `whoami` discriminates).

## Rules extracted (carry forward)

1. Predict before you spend: `the-janitor whoami` exit 1 ⇒ `request` will die
   in readiness; check the endpoint's `/health` too, not just `status` output.
2. `status` fields are *configured* values, not *verified* capabilities —
   endpoint, model, and fallback lines describe intent, not reachability.
3. `the-janitor stop` is always safe cleanup: idempotent, exit 0, removes
   `session-id` even when already stopped.
4. `op` account-list values are PII-class metadata — like `op://` ref paths,
   they stay out of durable artifacts.
5. The handler's readiness gate covers auth and OpenCode health only; model-
   endpoint reachability is the operator's problem (fix `opencode.json` or
   move the server, then re-run).
