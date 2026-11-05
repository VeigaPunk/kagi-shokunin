# ReviewC2 — adversarial review of C2 (freshness), kagi round 36

Seat: ReviewC2 (leaf reviewer). Read-only on the lane. Scratch
`/fast/scratch/hyaku/kagi-r36/ReviewC2/` (cleared before yield). Lane HEAD `09f27e2`;
instrument/controls commit `cb8cb65`; BASE extraction = `git archive cb8cb65`.

## Verdict

**ADMIT-WITH-CONDITIONS** for the bytes currently in the lane working tree (the L1's
landing), and **REJECT** for the candidate exactly as the frozen text specifies
(F3 = "the 15 drifting clock=feed rows" only). The literal F3 yields counter 0 but
`release-clock.py` prints FAILED, which is the frozen operability kill rule.

## Q1 — Is the round-26 receipt superseded, not rewritten or deleted?

Raw:

```
$ git -C kagi-shokunin log --oneline -1 -- .ufo/waves/round-26/observe-2.json
d30c989 round-26: reverify Python drift and rearm named successor clocks
$ sha256sum .ufo/waves/round-26/observe-2.json
13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169
$ git ls-tree HEAD .ufo/waves/round-26/observe-2.json
100644 blob e02f4dec80e671df8def781344758d7e812df97a	.ufo/waves/round-26/observe-2.json
$ git diff --quiet HEAD -- .ufo/waves/round-26/   -> rc=0 (clean)
$ git log --oneline -1 -- .ufo/waves/round-36/controls/observe-live.json
cb8cb65 round-36: arm the self-assessment population and commit executed predeclaration controls
```

- The lane working tree has no modification to any round-26 file. The round-26 receipt
  is byte-identical to its committed blob, and its sha256 equals the old
  `DEFAULT_RECEIPT_SHA256` (HEAD `corpus/release-clock.py:28`).
- BASE (`cb8cb65`) `python3 corpus/release-clock.py` → `RELEASE_CLOCK: CLEAN
  (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` rc=0, using the
  round-26 pin. So the historical receipt still validates against its own table.
- F4 repoints the default; `--receipt .ufo/waves/round-26/observe-2.json --receipt-sha 13b8…`
  remains a valid explicit-citation path (`main()` lines 2116–2124).

**Answer: yes.** Repointing is supersession, not rewrite. Caveat: after the repoint the
round-26 receipt no longer validates against the *current* table (its values are the
pre-drift ones). That is the intended meaning of "superseded"; it is recorded as history,
not as current.

## Q2 — Is the round-36 receipt gate output rather than hand-edited?

Structure (`analyze_receipt.py`, `receipt-analysis.txt`):

```
sha256 3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727 bytes 10916
top_keys ['format', 'observations'] format release-clock-observations-v1
n_records 30; unique_ids 30; dup []; sorted_by_id True
key_shapes {9: 30} uniform
bad_sha_feed []
observed_at_all_match_Z_fmt True
errors []   http_status ['200']
clock_counts {'feed': 20, 'rendered-quote': 10}
```

- `load_receipt_bundle` accepts it: format string correct, `observations` list, every
  record a dict with string `id`, no duplicate ids.
- Record count = bound on-release rows (30 = 30). Every `sha256` is 64 lowercase hex.
  Timestamps are non-decreasing in id order (23:42:50 → 23:42:58).
  The shared digests are consistent: S008–S011 share one sha (same
  `releases.atom`), S012/S013/S022–S024 share one, etc. Each shared digest belongs to one
  URL.
- **Decisive check — live re-run of the gate's own `--observe` path** into scratch
  (`python3 cand/corpus/release-clock.py --observe live/observe-refetch.json`):

```
RELEASE_CLOCK_OBSERVE: wrote 30 observations (failed=0 fired=15 regressed=0) ...
rc=0 (wall 7.7 s)
```

  Field comparison against the committed receipt (`compare.py`):

```
ids equal: True 30 30
field clock / http_status / url / parsed_version / located / verdict: differing ids = []
field sha256 differing ids: 0 []
```

  All 30 records reproduce field-for-field, including the body sha256 of every feed and
  quote page. A hand-written receipt would not match live bytes this exactly. Caveat: the
  refetch ran about 30 minutes later (2026-11-05T00:13Z vs 2026-11-04T23:42Z); the
  feeds did not change in that window.

**Answer: yes, it is gate output.** The receipt is not hand-edited. Caveat: the
counter `plans/round-36-c2.sh` does not pin the receipt's sha256 (see Forgery below).

## Q3 — Apply F3+F4 in scratch; does the counter reach 0, and does verify print CLEAN?

Method: `apply_candidate.py` on `git archive cb8cb65` copy. F4: the two constants and the
argparse help. F3: exactly the 15 drifting feed rows (`S012–S016, S021–S028, S040, S041`),
taking `parsed_version`, `observed_at` date, `verdict`, and a note suffix. The F3 diff is
`cand-F3-literal.tsv.diff`.

```
F3 changed rows: 15 ['S012', 'S013', 'S014', 'S015', 'S016', 'S021', ..., 'S040', 'S041']
== CAND C2 counter
0            rc=0
== CAND verify
RECEIPT-MISMATCH S005 S006 S007 S008 S009 S010 S011 S017 S018 S019 S020 S029 S030 S031 S032
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=15 fired=15 derived=10)   rc=1
== CAND selftest
RELEASE_CLOCK_SELFTEST: PASS (116 cases)  rc=0
```

**The literal F3 fails the kill rule.** The counter is 0, but the 15 bound rows that
were *not* drifting (S005–S011, S017–S020, S029–S032) keep `observed_at` 2026-10-21 and no
longer match the receipt's date. That gives `RECEIPT-MISMATCH` for each (`receipt_matches`
requires `receipt_date(observed_at) == values["observed_at"]`). Under the plan's own kill
rule ("verify does not print CLEAN → C2 fails"), the literal F3 cannot pass. The plan's
text and its kill rule are inconsistent. A correction is therefore unavoidable.

**The lane working tree (landed by the L1) resolves this by also re-dating those 15
non-drifting rows.** Lane WT, read-only:

```
$ bash plans/round-36-c2.sh                     -> 0 rc=0
$ python3 corpus/release-clock.py              -> RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15) rc=0
```

Diff scope vs BASE (`lane-wt-vs-base.tsv.diff`): 30 rows changed, not 15. Extra rows:
S005, S006, S007, S008, S009, S010, S011, S017, S018, S019, S020, S029, S030, S031, S032
(15). For those the version and verdict are unchanged. Only `observed_at` (→ 2026-11-04)
and the note change, and the note reads "re-observed unchanged by the round-36 receipt
observe-live.json". That is accurate: the receipt does observe them with the same values.

## Q4 — Does F3 keep the table's own semantics?

`semantics.py`:

```
CAND    anchor/clock/url/feedsrc changed: []  rows changed: 15   derived prefix lost: []  gained: []
LANE-WT anchor/clock/url/feedsrc changed: []  rows changed: 30   derived prefix lost: []  gained: []
header equal True (both)
```

- `anchored_version` is untouched in all rows. Feed URL, `feed_source_id`, and `clock`
  are untouched.
- Every `derived:` note still begins `derived:`. Derived rows still pass
  `derived_anchor_bound` (no DERIVATION finding), and `derived=15` on WT matches BASE.
- Verify on WT has no DERIVATION/REGRESSED/NON-CANONICAL finding.

## Forgery / fail-closed controls (executed, scratch copies of the candidate)

```
forgeA  S013 table observed_version 2.2.1 -> 9.9.9        counter 1   (above-receipt counted)
forgeB  S013 table observed_version 2.2.1 -> 2.2.0        counter 1   (below counted: equality, not ordering)
forgeC  empty receipt (observations: [])                  counter 20  (every feed row, fail closed)
forgeD  receipt removed                                   "C2 SETUP: receipt missing" rc=2
forgeE  receipt hand-edit S012 parsed 2.2.1 -> 2.2.0     counter 1; verify FAILED (sha pin) rc=1
forgeF  receipt AND table both edited S012 -> 2.2.0      counter 0 (!); verify FAILED rc=1
```

- The counter is correct on A–E, fail-closed on C–D.
- **Residual weakness (not a kill-rule breach):** `plans/round-36-c2.sh` reads the
  receipt without a sha256 pin, so a forger who co-edits the receipt and the table gets
  counter 0 (forgeF). The binding that catches it is `release-clock.py`'s default
  `DEFAULT_RECEIPT_SHA256` pin (verify → FAILED). The frozen counter cannot be changed, so
  the admitted claim must rest on the verify CLEAN with the sha pin, not on the counter alone.
- Note on rc: in the first forge run I piped verify through `tail` and read the pipe rc;
  re-run unmasked, `forgeE verify rc=1`, `forgeF verify rc=1`.

## Other observed facts

- BASE C1 counter (background job `bg_31714`, `bash plans/round-36-c1.sh` on the BASE
  extraction): **4**. Matches the plan's BASE; a corroborating control only (C1 is not
  assigned to this seat).
- BASE C2 counter: **15** rc=0; BASE verify CLEAN (round-26 pin).
- Knowledge entries (plan §Fix "knowledge entries stating old versions gain a
  re-verification line"): grep for `2.2.0|2.7.1|3.15.1|3.15.0` under `corpus/knowledge/`
  finds only `feed-token-boundaries.md:19,21,25,26,67,69`, which are parser examples
  (`Python 3.15.01`), not clock-state claims. No clock-state knowledge entry needed the line,
  and F1–F4 do not include it.
- Monotonic: `observed_at` is non-decreasing in id order (`True`).
- The lane working tree does not yet carry the F1 SCORECARD table; `git diff --stat`
  shows SCORECARD.md modified (32 lines). I did not review F1/F2 (not assigned).

## Conditions for ADMIT

1. Disclose in the round lesson (QM14 old/new journal, QM29: a later clarification goes in
   the lesson, not the frozen plan) that the landed fix re-dates 15 *unchanged* bound rows
   (S005–S011, S017–S020, S029–S032) from 2026-10-21 to 2026-11-04. Give old and new
   values, and state the reason: `verify` CLEAN requires the receipt date to match every
   bound row, and the literal F3 kill rule cannot otherwise pass.
2. Claim C2 by `release-clock.py` CLEAN (sha-pinned default) plus the counter, and
   state that the counter alone is forgeable by co-editing receipt and table (forgeF).
3. Keep the round-26 receipt committed and unchanged; cite it by sha
   (`13b8540c…`) as history.

## Raw SHA-256

```
3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727  .ufo/waves/round-36/controls/observe-live.json
13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169  .ufo/waves/round-26/observe-2.json
b18444f8f821c314719c91acf83bba3ad76731c7f787995b2783b1db8d2fa960  corpus/release-clock.py (lane WT; = cand)
5356c3aa812b5109ddcf70b7caa105667eb0dd1655bff313bce4620c3e4b1284  corpus/release-clocks.tsv (lane WT)
e462d5214365102ccaf402be63bb65b19d5177369f8a27cc1b220b09c786e5e8  cand literal-F3 release-clocks.tsv
99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd  BASE release-clocks.tsv (cb8cb65)
56bb37dfb9a5688a08fa872daf71d1cd95bfa2acd1cb1abbf74248b6704ca316  BASE release-clock.py (cb8cb65)
d9df0fcf955933e0128a41c1ae237518b1a329c6875ca1c2fbe01152391dfa92  live refetch receipt (scratch, copied to build/ReviewC2/live-refetch-observe.json)
```

## Tooling

No tools were installed. Only Python 3 stdlib, bash, git, and the lane's own scripts
were used.
