# SentFeedTokens — adversarial `--observe` review

BASE: `3553d499577084a6c98d7078906017840bbf7b28`. Scope axis: freshness / feed parsing. C2 calibration was not assessed.

## Findings (severity ordered)

### HIGH — non-canonical stable version can be written as a fired event (C1: MUST close)

- `corpus/release-clock.py:30-33,710-760` accepts digit components with leading zeroes and returns the original spelling; `:794-802` compares versions numerically only for regression, then uses spelling equality to decide `not-fired` versus `fired`.
- Concrete feed: `<feed><entry><title>Python 3.15.01</title></entry></feed>`, with the existing-style anchor `3.15.1`. Offline `observe_one` and synthetic-root `main --observe` probes wrote `parsed_version: "3.15.01", verdict: "fired"`; the observe summary said `failed=0 fired=1`. The CLI later exits 1 with `RECEIPT-MISMATCH S001`, but the false fired event is already in the output receipt. This is the frozen C1 F3 class, not a live vendor observation.
- Smallest remediation: reject non-canonical version tokens before selecting/recording a feed version, and produce a typed feed finding instead of a fired receipt. This is directly in frozen C1 scope.

### MEDIUM — unsupported XML encoding escapes as an untyped process crash (outside C1)

- `corpus/release-clock.py:733-736` wraps `ET.ParseError` and `ValueError`, but not `LookupError`; `:818-823` likewise does not catch it, and `main` catches only `SetupError` at `:1749-1751`.
- Counterexample: `<?xml version="1.0" encoding="x-no-such-encoding"?><feed><entry><title>v3.15.2</title></entry></feed>`. With a local mocked response, synthetic `--observe` emitted a `LookupError: unknown encoding` traceback (process exit 1) before writing any receipt. A fetched feed can therefore abort the whole observation pass rather than produce a row-level result.
- Smallest remediation: normalize unsupported-encoding `LookupError` to the parser's typed invalid-feed error (or validate the declaration), so one malformed feed cannot escape `observe_one`. This is outside the frozen C1 fixtures; it is still a concrete reliability defect.

### MEDIUM — no whole-operation deadline (outside C1; network behavior not exercised)

- `corpus/release-clock.py:309-317,676,681-705` performs synchronous DNS resolution without a deadline, passes `timeout=20` to `open`, then calls `response.read(MAX_BODY_BYTES + 1)` with no end-to-end deadline. A local no-return response mock was killed by the 2-second watchdog (child exit 124), despite `open` receiving timeout 20. This proves the caller has no overall deadline around the read; it does not emulate a real socket.
- [INFERENCE] A stalled resolver or a peer that keeps each socket read active but trickles a response can hold an observation much longer than 20 seconds. The byte cap does not cap elapsed time.
- Smallest remediation: bound DNS and the complete fetch/read with a monotonic total deadline; retain the existing per-read timeout and body cap. Not C1 scope.

### LOW — XML structure limits are checked after the full tree is built (outside C1)

- `corpus/release-clock.py:724-743` calls `ET.fromstring` at `:734` before counting nodes at `:737` and entries at `:742`. Thus the 100,000-element and 5,000-entry limits reject inputs only after ElementTree has parsed and allocated them. An offline 100,000-`<x/>` body (~400 KB) returned the typed “too many elements” error in 0.012s; 5,001 entries returned typed “too many entries”. The 8 MiB read cap at `:36,701-705` bounds bytes, not tree overhead.
- [INFERENCE] An input near the 8 MiB cap can force substantially more parse-tree memory than its wire size before rejection. The tested cases did not demonstrate OOM or a hang.
- Smallest remediation: enforce depth/node/entry budgets during parsing (or use a bounded streaming parser), rather than only after constructing the DOM. Out of C1 scope.

## Other requested cases and C1 oversize result

- A 50,000-level nested feed with one stable entry parsed successfully (`3.15.2`, 0.015s); no recursion crash observed. An exact 8,388,608-byte response was accepted by `request_body`; a 8,388,609-byte response returned `response too large` after requesting only 8,388,609 bytes. An 8 MiB title with no stable version returned a typed `ValueError`, not a traceback. Internal DTD/entity declaration was rejected; a numeric character reference parsed normally. No entity expansion was observed.
- A `3.15.` + 4,301-digit patch token reaches `int(part)` at `:760`: direct `parse_latest_version` raises Python 3.14.8's `ValueError` (limit 4,300 digits). In the normal observe path, `observe_one` catches that `ValueError` at `:822-823`, writes an error receipt with no verdict, and the synthetic CLI exits 1 with `RECEIPT-MISMATCH S001` / `fired=0`; no traceback was reproduced. The generic mismatch is not evidence of a specifically typed invalid-version finding. Thus C1 must close oversized-token classification, but the frozen plan's stated BASE traceback for the F4 `--observe` path was not reproduced; do not alter its frozen predicate/counting command based on this report.

## Commands and exits

Run from `.ufo/waves/round-28/sandboxes/SentFeedTokens-7`; all probes used the archived BASE and mocked feed responses, with no network access:

- `mkdir -p /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/SentFeedTokens-7/base && git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 3553d499577084a6c98d7078906017840bbf7b28 | tar -x -C /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-28/sandboxes/SentFeedTokens-7/base` — exit 0.
- `python3 -I -B feed_probe.py` — exit 0; direct oversized-token parser case raised `ValueError` inside the harness; unknown encoding raised `LookupError`; other results are above.
- `timeout 2s python3 -I -B feed_probe.py --hang` — child exit 124; watchdog assertion/shell exit 0.
- `python3 -I -B observe_probe.py` — exit 0; harness captured expected leading-zero fired receipt, oversized-token error receipt, and escaping `LookupError`.
- `python3 -I -B cli_probe.py leading-zero` — underlying CLI exit 1, fired receipt then `RECEIPT-MISMATCH`; wrapper exit 0.
- `python3 -I -B cli_probe.py oversized-version` — underlying CLI exit 1, error receipt and no traceback; wrapper exit 0.
- `python3 -I -B cli_probe.py unknown-encoding` — underlying CLI exit 1 with traceback; wrapper exit 0.

## Not checked

No live `--observe`, DNS, HTTP/TLS, slow-trickle server, unknown-host network, vault/account/handler/CDP, C2/source calibration, or production lane gate/selftest was run. The timeout test used a deliberately blocking local mock only. No worst-case 8 MiB high-node-count memory/OOM stress was attempted. No code or frozen plan/counting command was changed; no tool was installed.
