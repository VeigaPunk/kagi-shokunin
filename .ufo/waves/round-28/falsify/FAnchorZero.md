# FAnchorZero — round-28 falsification of pinned candidate 62a33b1 (carrier: derived S008 anchor 3.13.03)

Scope: one carrier only — S008 (derived SOPS row, feed S033) with a non-canonical version token.
Candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0` vs BASE
`3553d499577084a6c98d7078906017840bbf7b28`. No network (feed transport stubbed at the script's own
`request_body` seam). No lane gate run in the lane checkout; every run used a `git archive` export
inside my sandbox, released after capture.

## Verdict

**PASS on the carrier.** The candidate types the bad S008 token, exits 1, writes no fired verdict,
prints no traceback; BASE silently accepts the same table. Two divergences from the frozen plan
text follow (one code-read, one not executed).

## Findings by severity

### F1 — MEDIUM — feed-entry canonicality is narrower than the plan's "a feed entry must be canonical"
`corpus/release-clock.py:791-798` (candidate). `newest_stable()` filters non-canonical feed tokens and
**ignores** any that order *below* the newest canonical token; only a token *at or above* it raises. Plan §C1
(frozen): "a version token used for an anchor, a table observation **or a feed entry** must be canonical ...
otherwise the row **or feed** gets a typed finding". A feed carrying `v3.13.01` below `v3.13.3` therefore yields
CLEAN, not a typed feed finding: `version_order("3.13.01") = ((1,'3'),(2,'13'),(1,'1'))` <
`version_order("3.13.3") = ((1,'3'),(2,'13'),(1,'3'))` (lines 411-417), so the token is dropped. Only *executed*
evidence is the sole-entry case (`v3.13.03` alone → typed `non-canonical version token: feed has no canonical
stable X.Y.Z entry`), which the frozen F3/F4 shape also hits; the below-newest case is **[CODE-READ, NOT
EXECUTED]** (L1 stop instruction), fixed by 791-798. Impact is bounded — the token never reaches
`parsed_version`, no false release is named — so this is a divergence from the plan's totality wording, not a
soundness hole; frozen F3/F4 unaffected.

### F2 — LOW — implemented bound is 18 digits; plan/S044 ground the bound on CPython's 4300-digit limit
`corpus/release-clock.py:388` `VERSION_COMPONENT_MAX_DIGITS = 18`, used at `:405` (`len(part) >
VERSION_COMPONENT_MAX_DIGITS`). Plan §C1 and `corpus/SOURCES.md:51` (S044) ground the bound on CPython's int-string
conversion limit (4300), so a 19–4300-digit component is typed `NON-CANONICAL` although CPython would convert it. It
over-rejects, never under-rejects, so it cannot admit a bad token. **[CODE-READ, NOT EXECUTED]** (my 19-digit probe
aborted on a syntax error; siblings `FBound18`/`FBound19` cover the bound separately). Frozen F2 shape (4301 digits)
unaffected: still typed.

### F3 — INFO — canonical and derivation findings are mutually exclusive on one row
`corpus/release-clock.py:618-631`: the `DERIVATION` check is gated on `not non_canonical`, so a
derived anchor that is both non-canonical *and* unbound from S033's located anchor yields
`NON-CANONICAL` only, never `DERIVATION` (observed: G2 group → 4× `NON-CANONICAL`, 0×
`DERIVATION`). The row still fails typed with exit 1, so nothing passes silently.

## Exact differential on the carrier (own fixtures; receipts mirrored so the finding cannot be a generic receipt mismatch)

| fixture (S008 row) | candidate 62a33b1 | BASE 3553d49 |
|---|---|---|
| control (unmodified tree) | exit 0 `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` | exit 0, identical counts |
| anchored=`3.13.03`, observed=`3.13.03`, receipt mirrored | **exit 1 `NON-CANONICAL S008`**, `FAILED … observed=29 fired=3 derived=14` | exit 0 `CLEAN … fired=3 derived=15` (silently accepted) |
| anchored=`3.13.03` only, receipt kept verbatim | **exit 1 `NON-CANONICAL S008`** (no `RECEIPT-MISMATCH` line) | exit 1 `INCONSISTENT S008` (BASE-era generic category) |
| observed=`3.13.03`, verdict=`fired`, receipt mirrored | **exit 1 `NON-CANONICAL S008`**, `fired=3` (no fired observation counted) | exit 0 `CLEAN … fired=4` → **a fired release was written** |
| anchored=`3.13.` + 4301×`1` | **exit 1 `NON-CANONICAL S008`**, no traceback | exit 1 **Traceback** `ValueError: Exceeds the limit (4300 digits)` (`base/corpus/release-clock.py:380`) |
| S033 derived group (S008-S011) lowered to canonical `3.13.2` | exit 1 `DERIVATION S008/S009/S010/S011` | exit 0 `CLEAN` (group lowering accepted) |
| S033 derived group lowered to `3.13.02` | exit 1 `NON-CANONICAL S008..S011` | exit 0 `CLEAN` |

`--observe` path (transport stubbed, rows narrowed to S008/S033, feed serves `v3.13.3`):
candidate anchor=`3.13.03` → exit 1, receipt `verdict=None`, `error='non-canonical version token:
row anchor or observation; no verdict written'` (`corpus/release-clock.py:864`), `NON-CANONICAL
S008`; BASE → exit 1 with receipt `verdict='fired'` `parsed_version='3.13.3'` (a fired verdict
written). Feed whose newest entry is `v3.13.03` → candidate receipt `error='non-canonical version
token: feed has no canonical stable X.Y.Z entry'`, `verdict=None`; BASE receipt `verdict='fired'`
`parsed_version='3.13.03'`. Control feed `v3.13.3` → both exit 0 `CLEAN … derived=1`.
Calibration on the real corpus: candidate control is `derived=15` (same as BASE) with **zero**
`DERIVATION` findings, so the C2 binding does not fire spuriously on the 15 real derived rows.

## Commands run (all in sandbox; lane checkout untouched)

```
git archive 62a33b1 | tar -x -C .ufo/waves/round-28/sandboxes/FAnchorZero/       # exit 0
git archive 3553d49 | tar -x -C .ufo/waves/round-28/sandboxes/FAnchorZero/base  # exit 0
python3 fixtures.py . candidate     # exit 0 (per-fixture exits in output: 0,1,1,1,1,1,1)
python3 fixtures.py base base       # exit 0 (per-fixture exits in output: 0,0,1,0,1,0,0)
python3 observe_probe.py {.,base} {candidate,base} anchor   # script exit 1, observe exit=1
python3 feed_probe.py    {.,base} {candidate,base} "v3.13.03" # script exit 1, observe exit=1
python3 -I -B corpus/release-clock.py --selftest  # exit 0, SELFTEST: PASS (106 cases)
```
Probes + verbatim outputs: `.ufo/waves/round-28/sandboxes/FAnchorZero/receipts/`; trees deleted.

## What I did NOT check

- Repair revision `5e847472` was **not** tested; all results are against pinned `62a33b1`.
- The plan's frozen instruments `tools/c1-measure.py` / `c2-measure.py` were **not** run or reused.
- The below-newest non-canonical feed entry (F1) was not executed (CODE-READ); the 19-digit
  and middle/major-component zero variants are F2/peer scope, not executed here.
- No probe proved the `DERIVATION` binding reads `corpus/SOURCES.md` by repointing S033's anchor
  cell (syntax error before execution); the binding's source is read from
  `corpus/release-clock.py:618-625` (`feed_source = sources.get(feed_source_id)`), code-read.
- The other 14 derived rows and the non-derived feed rows (S012, S027/S028, S029, S040/S041) were
  not exercised; only S008's carrier and its S033 group. No network, no vault/CDP contact, no lane
  gates, no writes outside sandbox + report.
