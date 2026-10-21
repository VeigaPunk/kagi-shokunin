# FEnv640 — round-28 falsification: C1 int-limit / oversize-token carrier

Target: `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (BASE `3553d499577084a6c98d7078906017840bbf7b28`).
Carrier attacked: `corpus/release-clock.py` version-token canonicality (plan §C1) only.

**Verdict: PASS for the frozen carrier** (exact typed category `NON-CANONICAL`, exit 1, no traceback, no fired verdict, under
`-X int_max_str_digits=640` and at the default limit), with **one MEDIUM plan-text deviation (F1)** and **one LOW calibration note (F2)**
for the planner. No defect in the candidate's typing of oversize/leading-zero tokens was found.

## Environment / method
- python3 3.14.8; default `sys.get_int_max_str_digits()`=4300; `-X int_max_str_digits=640` = CPython's lowest configurable limit
  (640-digit `int()` succeeds, 641-digit raises — verified).
- Trees exported read-only into `/fast/scratch/hyaku/kagi-r28/FEnv640/{cand,base}` (git archive of the pinned revs). No writes to the
  lane checkout, no commits, **no network**: the feed path was driven through the module's own injection points (static opener + fake
  resolver), the same mechanism the candidate's own selftest uses.
- Fixtures (release-clocks.tsv edit only, row `S040`; the edited row mirrored into a copy of the default receipt, per plan §C1 correction):
  `observed_version = 3.15.<N×"1">`, `verdict=fired`, run with `--receipt <copy> --receipt-sha <sha256>`.

## Findings

**F1 — MEDIUM — C1 is not total for feed entries: a non-canonical feed entry below the newest canonical token is silently ignored.**
- Candidate `corpus/release-clock.py:784-797` (`newest_stable`): "A non-canonical token … that orders below the newest canonical token
  cannot be the newest release and is ignored"; the behaviour is pinned by the candidate's own selftest
  `corpus/release-clock.py:1382-1388` ("older oversize entry was not ignored").
- `plans/round-28.md` §C1: "a version token used for an anchor, a table observation **or a feed entry** must be canonical … otherwise the
  row or feed gets a typed finding (exit 1)". The candidate types only entries at/above the newest canonical token.
- Counterexample (offline probe, RSS body with entries `Python 3.15.1` and `Python 3.14.<4301×"1">`):
  candidate `parse_latest_version` → `'3.15.1'`; `observe_one` → `verdict='not-fired' parsed_version='3.15.1' error=None` → the feed
  passes with no typed finding (CLI would exit 0 CLEAN). BASE on the same body raised an untyped
  `ValueError: Exceeds the limit (4300 digits)…` (`base corpus/release-clock.py:715` → `:380 int(part)`), i.e. the candidate replaces a
  BASE crash with silence, not with the plan's typed finding.
- Impact: no false release event and no traceback, but "a feed entry must be canonical" does not hold for every feed entry. Frozen
  fixtures F1/F2/F4 are unaffected (F4's oversize token is the *newest* entry → typed). Planner decision: amend §C1 or the code.

**F2 — LOW (calibration) — the implemented bound is not CPython's conversion limit; the rule is text-based and limit-agnostic.**
- Candidate `corpus/release-clock.py:388` `VERSION_COMPONENT_MAX_DIGITS = 18` (rationale `:384-387`). `sys.get_int_max_str_digits()` is
  never called anywhere in the file (only mentioned in the comment at `:386`); no `int()` is applied to any version token.
- Consequence: a 640-digit component — convertible by CPython at the default 4300 limit **and** at the lowest configurable 640 limit —
  is still typed `NON-CANONICAL`; output is byte-identical at limits 4300 / 640 / disabled(0). Good (the rule is not a restatement of the
  runtime limit, unlike BASE), but plan §C1's "components beyond CPython's int-string conversion limit become typed findings" describes a
  4300-digit bound while the code refuses ≥19 digits. No control/fixture is affected (no corpus component exceeds 18 digits).

**F3 — INFO — BASE defects confirmed, i.e. the new rule is not cosmetic.** BASE `corpus/release-clock.py:380` `int(part)` reached from
`:386 is_regression` → `:567 evaluate`:
- 4301-digit token → uncaught `ValueError` traceback, exit 1, at the default limit *and* at limit 640;
- 640-digit token (mirrored receipt) → exit 0 `RELEASE_CLOCK: CLEAN (… observed=30 fired=4 derived=15)` — a **fired** release event
  counted from a non-canonical token;
- leading-zero `3.15.01` (mirrored receipt) → exit 0 CLEAN `fired=4`;
- BASE feed path, 4301-digit newest token → error text "Exceeds the limit (640 digits)…" (untyped/generic).

## Candidate assertions reproduced (all exit codes observed)
| run | limit | stdout | exit |
|---|---|---|---|
| cand, S040 = 3.15.<640×1> | 640 | `NON-CANONICAL S040` + `FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=15)` | 1 |
| cand, S040 = 3.15.<4301×1> | 640 | same as above | 1 |
| cand, same two fixtures | default | same as above (byte-identical) | 1 |
| cand, S040 = 3.15.01 (plan F1) | 640 | `NON-CANONICAL S040` | 1 |
| cand, unmodified tree (control) | 4300/640/0 | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` | 0 |
| cand `--selftest` | 640 and default | `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` (BASE: 79) | 0 |
| base, S040 = 3.15.<4301×1> | 640 | `Traceback … ValueError: Exceeds the limit (640 digits)…` | 1 |
| base, S040 = 3.15.<640×1> | 640 | `RELEASE_CLOCK: CLEAN (… fired=4 …)` | 0 |
| base, control | 4300/640/0 | `CLEAN (… fired=3 …)` | 0 |

- No "Traceback" in any candidate output (`grep -l Traceback out/cand-*.txt` → none); `fired` stays at the control value 3 → no fired
  verdict for the bad row; the table path writes no receipt.
- **Typed category is not a generic receipt mismatch**: with a receipt whose S040 record carries `error="non-canonical version token: …"`,
  the candidate prints `NON-CANONICAL S040` (exit 1) while BASE prints only `RECEIPT-MISMATCH S040` (exit 1). With the *unmirrored*
  receipt the candidate prints `NON-CANONICAL S040` **and** `RECEIPT-MISMATCH S040` — the typed category is present, not masked.
- Observe path (offline): oversize newest entry (640 and 4301) → `verdict=None parsed_version=None error='non-canonical version token:
  feed has no canonical stable X.Y.Z entry'`; oversize row anchor → `verdict=None error='non-canonical version token: row anchor or
  observation; no verdict written'`; text feed (`Version: X.Y.Z`) oversize → `non-canonical version token: text release version`.
  No verdict written in any case.
- Ledger pin `corpus/claim-ledger.tsv:82` (R25-03) expects `RELEASE_CLOCK_SELFTEST: PASS \(106 cases\)$` — reproduced (106) at both limits.

## Commands (exit codes)
```
python3 -I -B -X int_max_str_digits=640 corpus/release-clock.py --receipt receipt-mirror.json --receipt-sha <sha>   # 1 (cand), 1 (base, traceback)
python3 -I -B corpus/release-clock.py                                                                            # 0 (both, control)
python3 -I -B -X int_max_str_digits=640 corpus/release-clock.py --selftest                                          # 0 (106 cases)
python3 -X int_max_str_digits=640 feedprobe.py <tree> {640,4301} {canonical,newest,older,rowanchor}                  # probe, no network
```
Artifacts: `.ufo/waves/round-28/sandboxes/FEnv640/{mkfixture.py,feedprobe.py,out/*.txt}` (heavy trees in
`/fast/scratch/hyaku/kagi-r28/FEnv640/`, deleted at completion). No tool was installed or upgraded.

## Not checked / residual risk
- No live network: `--observe` was exercised only through injected openers; a real python.org fetch (or a feed with an *older* oversize
  entry — see F1) is unverified end-to-end.
- C2 derivation binding, the plan's `c1-measure.py`/`c2-measure.py` tools, ledger/census integrity beyond the selftest-count pin, and
  the rest of the round are out of scope and untested.
- The 19..4300-digit band is typed `NON-CANONICAL` by the candidate although CPython could convert it; whether that is intended is F2.
