# K41ReviewDocs (round-41 C2 reviewer seat) — scoped findings

Deliverables (this dir): `base-check.txt`, `attacks.md`, `notes.md`. Scratch
`/fast/scratch/hyaku/kagi-r41/K41ReviewDocs` (and K41ReviewDocs2 for the final frozen-counter
re-runs) deleted at teardown; no lane tree was edited; no `claim-ledger.sh verify` was run
(not in this seat's scope: C2 only). Tooling installs: **none**.

## Base-state check (at 5142b52, receipt `base-check.txt`)

| Claim | Status |
|---|---|
| step-5 class = re `\s` on str = `str.isspace()` | bound: S095 body, frozen quote count=1 (raw offset 75897); full S040-era clause locates normalized count=1 (measured this seat, not bound in any cell) |
| includes U+00A0 | derivation-only: bound via the class sentence (S095) + S097's membership definition; the body carries ZERO literal U+00A0 bytes; `unicode.category(U+00A0)=Zs, isspace=True` (measured) |
| includes U+3000 | UNSUPPORTED by the cited page (S095 body has no U+3000/ideographic token, x0 measured); true of lane python only (`Zs, isspace=True`); per plan it belongs in the round-lesson Gate |
| ASCII-only fails 3 of 10 digests (S022–S024) | 7-of-10 measured only in unbound workspace rows (`round-23/falsify/CritDigestDomain.md:122`, round-24 lesson S030 cell); no round-23 body is committed, so it is not re-derivable from the tree; the digests themselves are bound in source-fetches.tsv (S022 `06d2508c…`, S023 `0e62e056…`, S024 `7c5a19e2…`; replayed 10/10 in `round-24/normalizer-replay.json`) |
| S022–S024 identity | they are Vault JWT/lease/KV-digest rows, NOT whitespace teachers; correct only as "the rows whose digests distinguish the classes" |
| Sources paragraph at BASE | stale: no S### id; points at the round-24 row (S027, superseded twice); S096's quote bound (offset 13521, count=1) but name-only |

## Attack table (executed readings of the frozen `plans/round-41-c2.sh`, receipt `attacks.md`)

| Attack | Target | N | Reads |
|---|---|---|---|
| BASE 5142b52 tree | — | 1 | a0 b0 c1 |
| decoy control (S027+quote) | (a) | 2 | matches precommitted receipt |
| candidate shape | — | 3 | a1 b1 c1 |
| TA1 quote split across two lines | (b) | 2 | grep -qF needs one physical line |
| TA2 cites superseded S040 | (a) | 2 | |
| TA3 S097 cited for `\s` = White_Space | paragraph sentence | **3** | counter-green; sentence ungrounded (S097's quote says cat Zs or bidi WS/B/S — includes U+001C-1F, which White_Space excludes) |
| TA4 step-5 sentence cites nothing | ceiling | **3** | survives the counter in both sub-cases |
| TA5 quote only in a code comment | (b) | 2 | awk paragraph slice excludes comments |
| TA6 cites S095 only, keeps U+3000 | — | **3** | counter-green; U+3000 stays unsupported by the cited page |

## Post-landing S097 check, prepared (the assignment item 3 — exact line for `attacks.md`)

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-41/capture/S097.body \
  "A character is whitespace if in the Unicode character database"
```
Dry-run against the scout's committed S097 body (sha256
`e2992e17d9b8f15f09b2971e356d06c5e0f1572fefa6ce733eb6d7d48466e2b3`, 815447 bytes,
byte-identical to this seat's independent live fetch, `cmp` exit 0): `count=1`, exit 0.
The paragraph's S097 sentence may ground only "cat Zs or bidi class WS/B/S"; any
"equals White_Space" clause is ungrounded and is the S098 reject's ground.

## Surviving defects (routed, not fixed in the lane)

1. The frozen counter is fully green (N=3) under TA3/TA4/TA6: it binds one id set and one
   quote, and its ceiling (disclosed in the plan) is exactly the hole TA6 walks through.
   Defense = this seat's checklist at landing; record any surviving ungrounded page claim.
2. The served UTS #18 page spells the mapping `space(\s) -> \p{Whitespace}` and delegates the
   set to PropList; the plan's reject reason writes `\p{White_Space}` (same property, different
   case); the S098 row's quote must carry the served token (route: scribe seat).
3. S097 has no registry row at 5142b52 while the executor's paragraph cites it; the counter
   cannot check row existence (frozen as written). The S097 row must record url AND final_url
   (`/3/library/stdtypes.html` 301-redirects to `/3/builtins/stdtypes.html`, http_status 200 on
   the final hop) or the census will classify the row non-reproducing.
4. S095's verbatim-quote/derivation-quote boundary (M40-14/QM44): the full str.isspace()
   clause locates only after normalization; raw-literal storage of it would fail the
   `quote-bodies.tsv` byte-exact gate. Registry seat must keep the frozen short verbatim
   quote (offset 75897) and store the extended clause as a derived/normalized quote.

Counters re-verified on a fresh 5142b52 clone before teardown: c2=1, c1=0, controls exit 0
(c1-refuse 0 / c1-accept 0 / c1-no-gate 0 / decoy 2 / C2 BASE 1), selftest PASS cases=22 rc 0.
