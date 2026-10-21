# CritCounting — round-27 counting-command critique (calibration, freshness)

Seat: `KagiR26.CritCounting-17`, critic. This is advice from inside the lane, not non-author closure.
Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b` (`git rev-parse HEAD` = BASE). The working tree
holds L1's uncommitted integration, and it changed while I was reviewing: `release-clock.py` gained `feed_floors`
in the middle of my review. Claims tagged **WT** describe the working tree as of about 15:15 UTC. Claims
tagged **BASE** come from `git show BASE:<path>`, snapshotted into
`.ufo/waves/round-27/sandboxes/CritCounting/base/`.

`plans/round-27.md` is untracked, so it does not exist at BASE. Its line numbers below refer to the working tree.

I executed no gate, selftest, build, linter, or ledger row. Everything below comes from reading files, plus
static regex evaluation of `self-counts.tsv` locators over document text, with ledger **pins** read in place of
live runs. Every "expected output" below is therefore **[INFERENCE]** until L1 executes it.

## Axes

- **calibration (C1):** each reviewed current-tense knowledge number is bound to its source. The red-before must
  be caused by stale numbers, not by a broken locator. The mutation control must cover every digit the bound
  line asserts.
- **freshness (C2):** a numeric downgrade must never end CLEAN. The red-before must be discriminating: each
  fixture must fail for the reason it names, not because a sibling row happens to be red.

## The one concrete attack (C1): the mutation control only mutates the captured digit

**Claim attacked.** `plans/round-27.md:19-20` says "a one-digit knowledge mutation turns the binder STALE".
Lesson M27-2 (`corpus/lessons/round-27.md:86`, WT) uses a single `--mutate KN-LEDGER-REPRO-SELFTEST` as its
evidence.

**Why the control cannot fail.** `.ufo/waves/round-27/tools/c1-measure.py:55-60` bumps the digit at
`match.start(1)`, which is always the binder's own capture group. The control therefore cannot reach any other
digit on the same reviewed line.

**Static census.** Across the 15 lines the 18 `KN-*` bindings locate (WT), there are 52 digit runs. 18 are
captured and 34 are not. Most uncaptured runs are legitimate history clauses ("72 at round 10", "round-10
output read claims=17"). Four, however, restate the bound quantity in the present tense.

**Counterexamples.** Each mutant below locates exactly as before, and each binding still reads its captured
value, so the binder is predicted CLEAN (exit 0):

| Mutant (one digit) | Line (identical at BASE and WT) | Binding that still reads OK |
|---|---|---|
| `SELFTEST: PASS (170 cases)` → `(270 cases)` | `corpus/knowledge/claim-ledger.md:304`, second "170" | `KN-LEDGER-REPRO-SELFTEST` captures the first "170" (`# 170 scratch cases`) |
| `caught=18/18` → `caught=18/28` | `corpus/knowledge/adjacency-scope.md:17` | `KN-SCOPE-CURRENT-FALSIFY` (`caught=([0-9]+)/`) |
| `caught=18/18` → `caught=18/28` | `corpus/knowledge/adjacency-scope.md:155` | `KN-SCOPE-TABLE-FALSIFY` |
| `caught=18/18` → `caught=18/28` | `corpus/knowledge/adjacency-breadth.md:155` | `KN-BREADTH-FALSIFY` |

There is also a wrong-quantity binding. `KN-SCOPE-MUTATIONS` (`adjacency-scope.md:269`, "`--falsify` runs 18
mutations") extracts the **numerator** `caught=([0-9]+)/` from the R16-03 pin (BASE
`corpus/claim-ledger.tsv:41`, `caught=18/18 failed=0`). The sentence counts mutations *run*, which is the
denominator. They agree today only because 18/18.

**Evidence that the fix works.** I evaluated the replacement locators below statically. Each still matches its
WT line with the same capture, has exactly one group (the `self-counts.py:8-9` contract), and matches none of
the four mutants. A non-matching mutant becomes UNLOCATED, which already counts as exit 1 STALE per BASE
`corpus/self-counts.py:35` and `:327-331`, `:369-372`.

**Smallest safe correction.** Use same-value backreferences in the locator. This needs no new table rows and
no code change:

```text
KN-LEDGER-REPRO-SELFTEST  ^bash corpus/claim-ledger\.sh --selftest +# ([0-9]+) scratch cases +→ SELFTEST: PASS \(\1 cases\)
KN-SCOPE-CURRENT-FALSIFY  ^`SCOPE_FALSIFY: PASS \(caught=([0-9]+)/\1 failed=0\)
KN-SCOPE-TABLE-FALSIFY    ^\| `SCOPE_SELFTEST: PASS \([0-9]+ cases\)` / `SCOPE_FALSIFY: PASS \(caught=([0-9]+)/\1 failed=0\)
KN-BREADTH-FALSIFY        ^# SCOPE_FALSIFY: PASS \(caught=([0-9]+)/\1 failed=0\)
KN-SCOPE-MUTATIONS        extract → caught=[0-9]+/([0-9]+)
```

If L1 does not take this fix, the claim must be narrowed to "a one-digit mutation **of a bound (captured)
number**". The remaining present-tense digits on bound lines that stay unbound should be named in the lesson:
`drift-gate.md:143` "6 of", `checklist-execution.md:173` "17th"/"items=17" (live+1, derived), and
`:179` "runnable=6 floor=8".

## Counting commands, C1

Set `T=.ufo/waves/round-27/tools`, `B=0a47dd189356ea66ec83c3891eed54526e95b89b`, and `C=<integrated candidate, 40 hex>`.
`c1-measure.py` needs committed revisions (`:32`), so the after table must be the candidate's committed table.

```bash
python3 $T/c1-measure.py $B $C c1-before .ufo/waves/round-27/c1-before.json
python3 $T/c1-measure.py $C $C c1-after  .ufo/waves/round-27/c1-after.json
for id in $(git show $C:corpus/self-counts.tsv | awk -F'\t' '!/^#/ && $2 ~ /^corpus\/knowledge\// {print $1}'); do
  python3 $T/c1-measure.py $C $C mut-$id .ufo/waves/round-27/c1-mut-$id.json --mutate $id; done
```

`c1-measure.py` records findings but asserts nothing (`:64-73`). Its `exit` is vacuous on its own: an
after-only locator that is UNLOCATED on BASE docs gives exit 1 with zero stale numbers. The red-before must
therefore be asserted on the exact finding set.

**Red-before (BASE docs, candidate table).**
- `exit == 1`.
- `sorted(findings)` equals exactly `STALE` for these five ids: `KN-CENSUS-DRIFT-SYMBOLS`,
  `KN-LEDGER-REPRO-CLAIMS`, `KN-LEDGER-REPRO-SELFTEST`, `KN-LEDGER-REPRO-STAMPS`, `KN-OPREF-REPRO-SELFTEST`.
- Zero UNLOCATED, AMBIGUOUS, POLICY, or SETUP findings, and no non-`KN` id among the findings.
- `knowledge_bindings == 18`.
- `last_line == "SELF_COUNTS: STALE (claims=56 stale=5 unlocated=0 ambiguous=0)"`, where 56 is the 38 BASE rows
  plus 18.

My static locator pass predicts exactly these five against BASE values. All 18 locators locate exactly once on
BASE docs, so nothing is UNLOCATED. The predicted before→after values are 17→65, 33→89, 72→170 (`claim-ledger.md:301,304`),
29→36 (`op-ref-consumption.md:276`), and 19→20 (`surface-census.md:32`). This matches README WT `:218-222`
("five stale").

**After (candidate docs, candidate table).**
- `exit == 0`, `findings == []`.
- `last_line == "SELF_COUNTS: CLEAN (claims=56 stale=0)"`.

**Mutation.** For each of the 18 knowledge ids, the run must give `exit == 1` and findings exactly
`[("STALE", id)]`. An extra or different finding means the mutant also broke another binding.

**Literal mutants (needs a `c1-measure` variant that replaces an exact substring on doc:line).** The four
mutants in the table above must give `exit == 1` with exactly the owning id as UNLOCATED or STALE. **This is red
today [INFERENCE: CLEAN]. It turns green only after the backreference fix.**

**QM21 history.** For each of the five stale ids, the candidate's located line must still contain the BASE value
token: `claims=17`, `stamped=33`, `72`, `29`, `19`. This is a static grep.

**Provenance gap.** Lesson M27-2 (`corpus/lessons/round-27.md:86`, WT) cites
`.ufo/waves/round-27/c1-before.json`. That file **does not exist**: the directory listing shows only
`c2-before.json`. The red-before is unproven until that file is written by the first command above.

**In-flight coupling defect.**
- WT `corpus/claim-ledger.tsv` R12-03 is now `^90$`, because `corpus/lessons/round-27.md` was stamped
  (`stamps.tsv` has 90 nonblank lines).
- WT `corpus/knowledge/claim-ledger.md:301` still says `stamped=89`, so `KN-LEDGER-REPRO-STAMPS` will be STALE
  on the candidate [INFERENCE from the pin].
- A claim-only C1 overlay on BASE (stamps = 89) would read CLEAN and hide this.
- The C1 "after" therefore **must** be measured on the integrated candidate, not only on the separability
  overlays named in `plans/round-27.md:40-41`.

## Counting commands, C2

```bash
python3 $T/c2-measure.py $B c2-before .ufo/waves/round-27/c2-before.json   # already filed; read, not re-run by me
python3 $T/c2-measure.py $C c2-after  .ufo/waves/round-27/c2-after.json
```

**Recorded red-before.** I read `c2-before.json` (format `kagi-round27-c2-measure-v1`, revision = BASE):
- `lie`: exit 0, `RELEASE_CLOCK: CLEAN (… observed=30 fired=4 derived=15)`.
- `rollback`: exit 0, CLEAN `fired=3`.
- `control`: CLEAN `fired=3`.
- `default`: CLEAN `on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15`.

The mechanism is BASE `corpus/release-clock.py:524-531`, where a row counts as fired whenever observed ≠ anchor,
plus `:730-734`.

**Vacuity in the instrument.**
- `c2-measure.py:77` sets `accepted_clean = exit==0 and CLEAN`, and the summary at `:80` counts that.
  `downgrades_accepted_clean=0/2` is therefore met by **any** failure: SETUP exit 2, RECEIPT-MISMATCH, or
  INCONSISTENT.
- The `rollback` fixture (`:27-28`) bundles the S027/S028 un-fire together with the S040/S041 below-anchor lie.
  It goes red through S040/S041 alone, so it does not discriminate the un-fire. This overlaps CritC2Rollback.

**Required after-assertions (WT code read with `feed_floors` at `:390-410` and `:567-574`; observe floor at `:793-794`).**

| Fixture | exit | Finding lines, exactly | Summary tail [INFERENCE] |
|---|---|---|---|
| lie | 1 | `REGRESSED S040` | `FAILED (… observed=29 fired=3 derived=15)` |
| rollback | 1 | `REGRESSED S027`, `S028`, `S040`, `S041` | `observed=26 fired=1` |
| **unfire** (new: only S027/S028 → 3.15.0/not-fired) | 1 | `REGRESSED S027`, `S028` | `observed=28 fired=1` |
| control | 0 | none | byte-identical to the BASE control line |
| default | 0 | none | `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` |

The new `unfire` fixture needs one line added to `FIXTURES` (`c2-measure.py:25-30`): `"unfire": {"S027": ("3.15.0","not-fired"), "S028": ("3.15.0","not-fired")}`.
At BASE it is CLEAN `fired=1` [INFERENCE], so its red-before is real. After the change it is red only through
the python.org feed floor of 3.15.1 (S040/S041 anchors). This is the discriminating un-fire count.

Default CLEAN30 is predicted to survive `feed_floors`. On every feed URL, every row's observation is at or above
that feed's highest numeric anchor: sops 3.13.3, vault 2.2.0 (S012 floor 2.2.0), openbao 2.7.1, python 3.15.1,
and curl 8.23.0. Of the 20 feed rows, 19 have numeric anchors; the only non-numeric one is S012 `v1.21.x`.

**Selftest growth must be derived, not hand-written.**
- BASE pin: 67 (BASE `corpus/claim-ledger.tsv:82`).
- The WT name-set diff against BASE shows **no removed case**, 7 new `run_case` names, and 2 new inline
  `failures.append` checks: "older live feed observation…" and "return to the anchor after a recorded newer
  observation…". That predicts 67 + 9 = **76** [INFERENCE: no new call sits inside a loop].
- WT R25-03 is still pinned at `73`, the SKILL/PROVINCE bindings say 73, and lesson `:77` says "Six new". All
  three are stale against the current code.
- Command:

  ```bash
  diff <(git show $B:corpus/release-clock.py | grep -oE 'run_case\("[^"]+"|failures.append\("[^"]+"' | sort) \
       <(git show $C:corpus/release-clock.py | grep -oE 'run_case\("[^"]+"|failures.append\("[^"]+"' | sort)
  ```

  It must show only `>` lines, and the executed count must equal 67 + the number of `>` lines.

**Red-before per new case (scratch-copy mutants of the candidate; L1 runs them).** Each mutant must fail
exactly the named cases, and only those:
- **`is_regression` → `False`:** fails every REGRESSED-expecting case and both observe checks. The controls
  "numeric not lexical" and "non-numeric anchor keeps inequality" must still pass.
- **`feed_floors` → `{}`:** fails only "feed floor catches un-fire" and "feed floor lifts non-numeric anchor".
- **Drop the `observed_version` floor in `observe_one`:** fails only "return to the anchor…".
- **Compare versions as strings:** fails "numeric not lexical".

## Overclaim still present (C2, wording)

WT `corpus/QUALITY.md:132` (QM25) says "never an un-fire of an earlier anchor". The WT code comment at
`:571-573` itself concedes: "An observation EQUAL to the feed floor cannot be told from a legitimate state."

Counterexample: a fired row with no higher-anchored sibling on its feed URL. Replay accepts its return to
exactly its own anchor as CLEAN. `--observe` would type it `regressed` through the recorded-observation floor,
but only when the table row is not edited first.

Correction: QM25 and lesson §C2 should say "below the row's anchor or any numeric anchor on the same feed URL;
a return to exactly the feed floor is undetectable in replay (a declared limit)".

## What I did NOT check

- I ran no `self-counts.py`, `release-clock.py`, `claim-ledger.sh`, selftest, or measure script. All expected
  exits and lines above are inferred from code, and live `ledger:` values were replaced by committed pins.
- Unrun checks are not passes.
- I did not review the other 18 knowledge entries for unbound current-tense numbers, beyond the round-25
  named-debt loci and the 15 bound lines.
- I did not verify S042/S043 source content, receipt digests, `knowledge-migrations.json`, or
  `expectation-migrations.json`.
- I did not check whether any new `run_case` call sits inside a loop; that affects the 76.
- I did not check `surface-census.md:226` "case 14", which the WT lesson names as debt.

Tooling: none installed or updated.
