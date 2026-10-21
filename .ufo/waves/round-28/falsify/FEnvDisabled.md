# FEnvDisabled — PYTHONINTMAXSTRDIGITS=0 without `-I`: oversized observation still refused?

Target `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (pinned candidate).
Carrier: C1 freshness (canonical version tokens), `corpus/release-clock.py` only.

**Verdict: PASS (candidate).** Under `PYTHONINTMAXSTRDIGITS=0` *without* `-I`, the pinned candidate still refuses an oversized observation with the exact typed category `NON-CANONICAL S040`, exit 1, no `Traceback`, and **no fired verdict written** — identically to the frozen `-I` environment. The one HIGH finding is about the *measurement*, not the candidate.

## F-1 (HIGH, measurement) — the frozen counting command is blind to `PYTHONINTMAXSTRDIGITS`

`plans/round-28.md:29` freezes `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py …`. `-I` implies `-E` (`sys.flags.ignore_environment == 1`, verified), so `PYTHONINTMAXSTRDIGITS` is **discarded** and the child runs at the default limit 4300; the instrument's own child env (`tools/c1-measure.py:339-344`) never sets it either. The frozen C1 count therefore cannot distinguish an env-independent lexical bound from an env-dependent `int()`-catch.

Counterexample `envdep2` = pinned candidate with the lexical 18-digit bound removed from `non_canonical_version`, `version_order` reverted to `tuple(int(part) …)`, and the `int()` `ValueError` re-typed as `NON-CANONICAL`. Verdicts from the instrument's own `classify()`:

| tree | env | F2-table-oversize | F4-observe-oversize | verdict |
|---|---|---|---|---|
| `cand` 62a33b1 | frozen `-I` | exit 1 `NON-CANONICAL S040` | exit 1 `NON-CANONICAL S040` | TYPED 4/4 |
| `cand` 62a33b1 | **attack** `limit=0` no `-I` | exit 1 `NON-CANONICAL S040` | exit 1 `NON-CANONICAL S040` | TYPED 4/4 |
| `envdep2` | frozen `-I` | exit 1 `NON-CANONICAL S040` | exit 1 `NON-CANONICAL S040` | **TYPED 4/4** |
| `envdep2` | **attack** `limit=0` no `-I` | **exit 0 `CLEAN … fired=4`** | **exit 1, `fired=1` receipt written** | **MISHANDLED 2/4** |

`envdep2` is *indistinguishable from the candidate* under the frozen command, yet under the env var it accepts the 4301-digit token as a release and writes a **fired** observation. **This does not impeach the pinned candidate, which passes in both environments** — it impeaches the *inference* that "TYPED 4/4" demonstrates env-independence. C1's stated reasoning (`plans/round-28.md:17-25`) is about CPython's runtime limit; the candidate's real defence is different and stronger — a *lexical* bound. Recommend the lesson say the bound is lexical/env-independent (it already does at `corpus/lessons/round-28.md:58`) and that the before/after counts are an environment-specific lower bound, not an env-independence proof.

## F-2 (MEDIUM, candidate, receipt path) — a huge integer in a receipt raises an untyped traceback

`corpus/release-clock.py:523-525` (pinned 62a33b1) catches only `except (UnicodeError, json.JSONDecodeError)`. CPython's int-string limit error is a plain `ValueError`, **not** a `json.JSONDecodeError`, so it escapes the handler: `python3 -B cand/corpus/release-clock.py --receipt <huge-int-receipt> --receipt-sha <sha>` → exit 1, stderr contains `Traceback … ValueError: Exceeds the limit (4300 digits) …`. Verified identically at BASE and the pinned candidate — **pre-existing, not a round-28 regression**. It breaks the round's "never a traceback" wording (`plans/round-28.md:19-20`) on the receipt path, but it is not the C1 version-token path, so it does not falsify C1. **Already fixed downstream of the pinned commit:** lane HEAD has advanced to `5e84747`, whose `corpus/release-clock.py` (sha256 `fa9bcc02…`) reads `except (UnicodeError, ValueError)` and additionally types a non-canonical `parsed_version`; the pinned candidate 62a33b1 does neither.

## F-3 (LOW) — lane HEAD has advanced past the pinned candidate

Lane HEAD is now `5e84747` (was `62a33b1` when this review started); `corpus/release-clock.py` is now `fa9bcc02…` vs the pinned `ebe17f16…cd86`, and `corpus/stamps.tsv` no longer pins the pinned digest. All measurements here used `git archive` exports of the **pinned** commits, byte-verified: `cand/corpus/release-clock.py` sha256 `ebe17f16…cd86` == `git show 62a33b1:corpus/release-clock.py`. Re-measuring against the checkout now measures `5e84747`, not `62a33b1`.

## Commands run (exit codes)

```
python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 62a33b1… FEnvDisabled-cand frozen-cand.json  # exit 0
   -> C1_MEASURE FEnvDisabled-cand: mishandled=0/4 typed=4/4 other=0/4 control_exit=0 control_clean=True
python3 -I -B .ufo/waves/round-28/tools/c1-measure.py 3553d49… FEnvDisabled-base frozen-base.json  # exit 0
   -> C1_MEASURE FEnvDisabled-base: mishandled=3/4 typed=0/4 other=1/4 control_exit=0 control_clean=True
python3 -B attack.py   # exit 0  F1/F2/F3/F4 x {limit0-no-I, limit0-I, default-no-I, default-I} x {cand,base}
python3 -B attack2.py  # exit 0  F1/F3 under env; int-limit invariance 5/18/640; JSON huge-int
python3 -B attack3.py  # exit 0  near-miss + frozen instrument
python3 -B attack4.py  # exit 0  decisive discriminator, instrument classify()
python3 -B verify.py   # exit 0  final transcript (final-transcript.json)
python3 -I -B cand/corpus/release-clock.py --selftest  # exit 0  PASS (106 cases)  [BASE: PASS (79 cases)]
```
Selftest result identical with and without the env var.

## Exact candidate path:line (pinned 62a33b1)

`corpus/release-clock.py:388` `VERSION_COMPONENT_MAX_DIGITS = 18` (lexical bound) · `:395-406` `non_canonical_version` (`len(part) > 18` → non-canonical) · `:409-415` `version_order` `(len(digits), digits)` tuples, **no `int()`** · `:631` and `:680` `errors.add(("NON-CANONICAL", source_id))` (the typed finding) · `:523-525` receipt loader `except (UnicodeError, json.JSONDecodeError)` (F-2) · `:784-800` `newest_stable` raises `NON_CANONICAL_PREFIX`. BASE contrast: `base/corpus/release-clock.py:380` and `:760` — `tuple(int(part) …)`. `grep -cE '(^|[^A-Za-z_.])int\(' corpus/release-clock.py` → **2**, both comments (`:387`, `:1364`): **zero** `int()` calls on any version token, so the runtime limit is irrelevant to the candidate.

## Concrete counterexample (BASE under the attack env)

BASE `3553d49`, `PYTHONINTMAXSTRDIGITS=0`, no `-I`, S040 `observed_version=3.15.<4301×'1'>`, `verdict=fired`, receipt mirrored: `python3 -B base/corpus/release-clock.py --root <fixture> --receipt <copy> --receipt-sha <sha>` → exit 0, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)`. BASE **silently accepts** the 4301-digit token as canonical (fired=4 vs the control's fired=3) — no traceback, no typed finding. Under the default limit the same fixture instead dies with an untyped `ValueError` traceback: BASE is mishandled in *both* environments by different mechanisms — the plan's "raises an untyped ValueError traceback" (`plans/round-28.md:19-20`) describes only the default-limit case. `--observe` under the same env writes a **fired** receipt (`verdict: "fired"`, `parsed_version` length 4306) for the oversized token.

Pinned candidate, same attack env → exit 1, `NON-CANONICAL S040`, `RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=15)`. `fired=3` equals the control's `fired=3`: the oversized row contributes **no** fired release event. `--observe` writes `error: "non-canonical version token: feed newest stable entry"`, `verdict: null`, `parsed_version: null` — no verdict written. The typed token is `NON-CANONICAL`, outside the BASE-era set `{ORPHAN, UNBOUND, INCONSISTENT, BADFEED, REGRESSED, RECEIPT-MISMATCH, NOT OBSERVED}`; the output contains **no** `RECEIPT-MISMATCH`, so this is not a generic receipt mismatch standing in for the new rule. Env-independence holds across the whole legal range (`0`, `640`, `4300`, `100000`): F2 and F4 are TYPED at every value. Boundary: an 18-digit component is accepted (exit 0), a 19-digit component is `NON-CANONICAL` (exit 1) at every limit.

## What I did NOT check

- C2 (derived-anchor binding) and the rest of the round — out of scope by instruction; the 15 `derived:` rows' anchor/feed-row agreement, `separability.py`, `c2-measure.py`: not checked.
- Any live network fetch; the feed transport was stubbed offline exactly as `tools/c1-measure.py` stubs it (its `RUNNER`), so F3/F4 exercise the parser, not the network.
- Ledger rows `R25-03`/`R25-04` (`python3 corpus/release-clock.py`, **no** `-I`) were not run in the lane checkout: production invocations lack `-I`, so they *do* honour the variable.
- The working tree's uncommitted C2 changes; no gate/selftest was run in the lane checkout — all runs were in exported trees.

## Artifacts

`.ufo/waves/round-28/sandboxes/KagiR28.FEnvDisabled/` — `attack{,2,3,4}.py`, `verify.py`, `attack{,-2,-3,-4}-results.json`, `final-transcript.json`, `frozen-{cand,base}.json`. Heavy exported trees (538M) at `/fast/scratch/hyaku/kagi-r28/KagiR28.FEnvDisabled/` (`cand`, `base`, `nearmiss`, `envdep`, `envdep2`) per the scratch directive; retained for reproducibility. No tools installed, no packages upgraded.
