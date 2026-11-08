# R64Reviewer — round-64 instrument attack (kagi, C1/C2)

Seat: reviewer (attack). Read-only on lane source: no lane instrument, fixture or
record was edited by this seat; every attack tree and counter copy lives under
`/fast/scratch/hyaku/kagi-r64/R64Reviewer/` (removed before yield). Receipts:
this directory (`receipts/`, `attacks/`).

**Disclosure:** this seat did **not** read `plans/round-64-heldout.tsv` (the sealed
held-out set). The counter's own H/Q mapping is exercised through the counter, and
the attack trees were built from the round-60 correction lines the plan names, not
from the seal. The seal file was copied byte-for-byte into one scratch attack tree
only because the counter verifies its sha256; its contents were never opened here.

## 0. Pins (measured, not quoted)

| object | sha256 | bytes measured |
|---|---|---|
| lane HEAD (working tree dirty) | `eb647d23132cf7ffc3b3cd08f2083b8e39e5391e` | 2026-11-08 02:1x |
| `plans/round-61-c1-check.py` BASE = HEAD bytes | `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6` | 2031 lines |
| `plans/round-61-c1-check.py` hardened (working tree) | `c433dcb25c6a0e5adc4c25e068f949d173f900e693cd54a56451762c291ff7ef` | 2127 lines; `--selftest` ⇒ `C1_CHECK_SELFTEST: PASS (cases=110)` |
| `plans/round-64-c1.sh` | `552775a2…` (02:13) → `b940c890…` (02:19) → `7e5bcfa1…` (02:26) → `2d5cba28…` (02:33) → `83d1ee8b…` (02:35; the last bytes seen; the defect and the forged pass were re-checked on each). The sha moved under this seat four times; the three findings below are stable across all four. | 762 lines at `83d1ee8b` |
| `plans/round-64-c2.sh` | `061f0ad51d0bbe3972477efe6ef9c7f2c1900a3f0863a16fb335da1753b67315` | 376 lines |
| `plans/round-64-controls.sh` | `7c247aea…` (02:13) → `4db83dd2…` (the bytes cited) | 6 selftest cases A–D |
| `plans/round-63-c1.sh` / `plans/round-63-c2.sh` | `6842eb75…` / (round-63 counter) | carried |

The lane was live during this seat: the checker moved `2d48e481 → c433dcb2` and the
C1 counter `552775a2 → b940c890 → 7e5bcfa1 → 2d5cba28 → 83d1ee8b` between 02:10
and 02:35. Every reading below names the bytes; all C1 grammar readings were
re-run on `c433dcb2` after the last checker change, and the C1 counter findings
were re-measured on `83d1ee8b` (the last bytes seen: the same unbound variable at
`:559`/`:620`, the same coded fixture paths, and the same forged pass).

### Method (and its one reduction)

- Trees: slim copies (the seven checker inputs plus the fleet report) built per
  fixture; each has exactly one byte-exact replacement (the driver asserts the
  anchor occurs exactly once). Slim-vs-full equality for the unmodified copy was
  established by the L1; this seat re-checked the unmodified slim copy reads
  `value=0` with the full checker.
- Per-fixture readings: the pinned checker module is imported and its own
  `item1..item7` functions are called on the copy (`receipts/measurements.jsonl`).
  The composed `value` is `evaluate`'s `count` = number of FAIL items; `i2` is the
  one item not re-run per fixture (its inputs — `plans/round-60-c2.sh`, `SKILL.md` —
  are untouched by every fixture) and reads `i2=1` on the control. Cross-checked
  against full `C1_ROUTED` runs: F01 ⇒ `value=0 population=7 i1..i7=1`, B01 ⇒
  `value=0`, both reproduced (§2, §3).
- Full-tree runs of the counters are quoted with their exact command and receipt.

## 1. C1 — new forgery instances the hardened checker still accepts

21 new instances (`F01..F21`), 19 still accepted, 2 rejected. `accepted` =
`C1_ROUTED: value=0` (the forgery survives). Every tree is BASE-plus-one-edit; the
BASE column is the HEAD checker (`eb08094c`), the right column the hardened checker
(`c433dcb2`). Exact edits are in `receipts/fixtures.json`; per-item reads in
`receipts/measurements.jsonl`.

| id | class (file · edit) | BASE | hardened `c433dcb2` |
|---|---|---|---|
| F01 | denial predicate in a later sentence (I3 · `plans/round-60.md`: `**A3 item 2 is withdrawn**. The record denies that it was withdrawn.`) | accepted | **accepted** `i3=1` |
| F02 | negator in a previous sentence (I3 · `**A3 item 2 is not withdrawn. A3 item 2 is withdrawn**`) | accepted | **accepted** `i3=1` |
| F03 | subject swap with a third subject (I7 · `the sentinel's literal reading is 3/16 = 18.75 %, and the literal sentinel gives 4/16 = 25 %`) | accepted | **accepted** `i7=1` |
| F04 | unbound duplicate pair (I7 · pair appended with no subject) | accepted | rejected `i7=0` — **fix fires** |
| F05 | duplicated mechanism + contrastive hedge (I5 · `rewritten in place` once, then `although the record says the mechanism was an in-place rewrite, the change was appended`) | accepted | **accepted** `i5=1` |
| F06 | `no such`-style denial the list misses (I3 · `**A3 item 2 is withdrawn**, though such a withdrawal never happened`) | accepted | **accepted** `i3=1` |
| F07 | fabricated stamp that is a derived committer time (I6 · `15:09:28` → `15:06:58`) | rejected | rejected `i6=0` — **closed** |
| F08 | fraction + percentage from a different denominator (I7 · `… 4/16 = 25 %, i.e. 3/15 = 20 %`) | accepted | **accepted** `i7=1` |
| F09 | appositive hides a negation (I3 · `**A3 item 2 is withdrawn, the claim the record disputes**`) | accepted | **accepted** `i3=1` |
| F10 | token form the lists do not carry (I3 · `**A3 item 2 cannot be said to be withdrawn**`) | accepted | **accepted** `i3=1` |
| F11 | I4 denial verb outside the closed set (`… it did not route, a claim the record disputes`) | accepted | **accepted** `i4=1` |
| F12 | I5 post-token denial outside the closed set (`… rewritten in place at — the record contradicts this`) | accepted | **accepted** `i5=1` |
| F13 | I6 post-token denial outside the closed set (`launch 15:09:28 −03, a time the record disputes`) | accepted | **accepted** `i6=1` |
| F14 | denial predicate in a later sentence (I7 · `… gives 4/16 = 25 %. The record denies the second reading.`) | accepted | **accepted** `i7=1` |
| F15 | quote mask deletes a scare-quoted negator (I3 · `**A3 item 2 is "not" withdrawn**`) | accepted | **accepted** `i3=1` |
| F16 | negation after the subject, pair still binds (I7 · `the sentinel is not an attack seat, yet 4/16 = 25 % counts it`) | accepted | **accepted** `i7=1` |
| F17 | fabricated non-derived stamp riding the `>=3` floor (I6 · `15:47:01` → `12:34:56`) | accepted | **accepted** `i6=1` |
| F18 | negator beyond the 24-token window (I3, plan ceiling) | accepted | **accepted** `i3=1` |
| F19 | `no such` denial the list misses, in-sentence paraphrase (I3 · `though such a withdrawal does not exist`) | accepted | **accepted** `i3=1` |
| F20 | same-sentence denial beyond the 24-token post window (I3) | accepted | **accepted** `i3=1` |
| F21 | negator denial the I6 list misses (I6 · `the record never recorded that launch`) | accepted | **accepted** `i6=1` |

Measured totals: BASE accepts 20/21; the hardened checker accepts **19/21**. The
three fixes the round claims are visible where they apply: F04 (every-pair-bound)
and F07 (quoted-span equality) fire; the negated-subject guard fires only when the
blocker precedes the subject (F16 shows the one-sided case).

The round's plan names the ceiling ("eight fixtures are eight fixtures, not a
grammar proof"), so these readings do not falsify `heldout=0`; they falsify any
reading of `heldout=0` as class closure. Finding **R64-G-01..G-04**.

## 2. C1 — new benign rewrites

13 trees; the eight classes the seat was asked for are B01–B08 and all are accepted
by the hardened checker. `accepted` = `value=0`, the required reading.

| id | class | BASE `eb08094c` | hardened `c433dcb2` |
|---|---|---|---|
| B01 | appositive (`**A3 item 2, the every-request claim, is withdrawn**`) | accepted | accepted |
| B02 | passive with agent (`has been withdrawn by the lane`) | accepted | accepted |
| B03 | numeric form (`3 (three) new record defects`) | accepted | accepted |
| B04 | hyphenated anchor (`A3-item-2 is withdrawn`) | accepted | accepted |
| B05 | contrastive (`withdrawn, not merely restated`) | accepted | accepted |
| B06 | parenthetical aside between subject and pair (I7) | accepted | accepted |
| B07 | em-dash aside (I7) | accepted | accepted |
| B08 | quoted-but-asserted (I3) | accepted | accepted |
| B09 | em-dash aside carrying an abbreviation (`i.e.`) | rejected | rejected — pre-existing |
| B10 | subject after pair (`4/16 = 25 % is the sentinel's reading`) | rejected | rejected — pre-existing |
| B11 | benign `no … other than` before the subject | accepted | **rejected** — hardening regression |
| B12 | nested parenthetical with a long aside | rejected | rejected — pre-existing |
| B13 | idiom `not less than` (I4) | rejected | accepted — the round's new idiom |

**B11 is the one regression**: `no reading other than the literal reading gives
3/16 = 18.75 %` reads `value=0` at BASE and `value=1 i7=0` on `c433dcb2` —
`_subject_blocked` scans five tokens before the subject and finds `no`, so the only
`literal reading` subject is discarded and its pair is unbound. Fix: narrow the
blocker set to a negator that scopes the subject itself (`no … subject is`, or a
`not`/`different` directly before the noun phrase) and do not discard the subject
when a comparative (`other than`, `except`) intervenes. Finding **R64-G-06**.

## 3. Counter attacks

All commands run from this seat's scratch with `HYAKU_SCRATCH=/fast/scratch/hyaku`;
the counter scripts were invoked as copies, never edited in the lane.

### A. C1 counter — a path-keyed checker stub reaches the target

The counter names each fixture copy after its fixture id
(`round-64-c1.sh:473 ftree="$pfx.H-$id.tree"`, `:493 bt="$pfx.Q-$id.tree"`) and
passes that path to the measured checker as `--root`. A 12-line checker stub that
prints `PASS (cases=110)` for `--selftest`, `value=1` when `H-` is in `--root` and
`value=0` otherwise therefore reads exactly as a perfect candidate. Measured on the
newest counter bytes (`83d1ee8b`, receipt
`receipts/c1-stub-forged-pass-final-83d1ee8b.txt`; the same pass measured on
`7e5bcfa1` and `2d5cba28`), with only the one-line unbound variable fixed (§4
R64-C1-01):

```
c1-heldout: per-fixture F2=value1 F6=value1 F8=value1 F10=value1 B4=value1 P6=value0 B5=value0 P7=value0
C1_HELDOUT: heldout=0 population=8 guard=1 (real=1 selftest=1 resid=1 stub=1 vehicle=1)
rc=0
```

On the unedited live bytes the same tree prints everything up to the final line and
then dies: `round-64-c1.sh: line 620: stub2_e2: unbound variable`, rc 1 (receipt
`receipts/c1-stub-forged-pass-live.txt`). Both readings are of one tree with a
stub checker and a 3-line stub `plans/round-63-c1.sh`; no fixture work is done.
Finding **R64-C1-02**.

### B. C1 counter — the resid leg runs the measured tree's own counter

`leg_resid` executes `bash "$t/plans/round-63-c1.sh" --tree "$t"` — the *measured
tree's* bytes, in every invocation. A tree carrying a three-line stub that prints
`C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 …` and exits 0 reads
`resid=1` (receipts A above). The vehicle-identity leg resolves
`$LANE/plans/round-63-c1.sh` (the counter's own repo): honest when the counter runs
from the lane, tree-supplied when the counter is the tree's own copy — which the
`--tree` contract permits. Finding **R64-C1-03**.

### C. C2 counter — a tree of seven stub instruments reaches the target

`plans/round-64-c2.sh` reads every leg and every guard from the measured tree
(`$TREE/plans/round-62-c1.sh`, `round-63-controls.sh`, `round-61-c1-check.py`,
`round-62-c2.sh`, `round-62-controls.sh`, `round-63-c2.sh`). A tree whose six
instruments are stubs (the l1 needle present once, so the mutation applies) measured
(`receipts/c2-stubtree-forged-pass.txt`, counter sha `061f0ad5`):

```
c2-refusal: guard a=1 r63selftest=1 b=1 c=1 d=1
C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1 terminates=1 bound=1)
rc=0   elapsed=5s
```

No counter work, no bao, no round-63 leg: the C2 verdict is a composition of the
tree's own scripts. Findings **R64-C2-01**, **R64-C2-04**.

### D. C2-BOUND — a bound=0 crash reads as nontermination

`ctrl_c2_bound` treats *no verdict line and any non-zero rc* as the refutation. A
counter that prints the candidate line under `C2_RECURSION_BOUND=1` and exits 1
immediately under `C2_RECURSION_BOUND=0` (no recursion at all) measured
(`receipts/c2-bound-v5-crash.txt`):

```
CONTROL C2-BOUND expect=nontermination-bound=0 mismatch-if-terminates observed=no-verdict-line;rc=1;timeout=240s verdict=match
CONTROLS: match=4 mismatch=3
```

The control cannot distinguish a crash from a hang, so a bound flag read once and
never re-checked satisfies guard leg (b). (A counter that terminates *with* a line
under bound=0 is correctly refused — measured in the first pass of this attack; the
current `ctrl_c2_bound` reports `verdict=mismatch` for any verdict line.) Finding
**R64-C2-02**.

### E. A counter whose `--selftest` prints PASS without a case

- C2 counter copy with a dispatch before `BUDGET_S=1200`:
  `C2R64_SELFTEST: PASS (cases=21)`, rc 0 (`receipts/c2-selftest-printer.txt`).
- C1 counter copy with a dispatch **before the seal check**:
  `C1_HELDOUT_SELFTEST: PASS (cases=22)`, rc 0 (`receipts/c1-selftest-printer.txt`) —
  it prints PASS with no held-out table present, so the seal is not exercised.
- The round-64 controls battery never runs either counter's `--selftest` (its
  probe path is `--tree` only), and neither counter carries a self-challenge.
  Findings **R64-C1-06**, **R64-C2-05**.

### F. A battery whose control list is empty

A copy of `plans/round-64-controls.sh` with the eight `ctrl_*` calls in `main`
replaced by `:` measured (`receipts/controls-empty-list.txt`):

```
SKIPS: 0
CONTROLS: match=0 mismatch=0
SEAT-STATUS: complete
rc=0
```

Nothing requires a minimum population, so any consumer gating on `mismatch=0` and
`skips=0` is satisfied vacuously. Finding **R64-B-01**.

## 4. Findings — severity, evidence, fix

Open findings only. "Guard" means the frozen plan's guard leg, not a claim number.

**R64-C1-01 CRITICAL (operability; every live sha `b940c890`→`83d1ee8b`) — the C1 counter cannot
print its verdict line: `stub2_e2` is unbound.** `leg_stub` sets `stub_e2`
(`:559 stub2_rc=$SL_RC; stub_e2=$SL_OK`) while the verdict block reads `stub2_e2`
(`:620`), so under `set -u` the script dies before `C1_HELDOUT:`. Measured on the
unmodified counter and on the stub tree: `line 620: stub2_e2: unbound variable`,
rc 1, no verdict line (receipts `c1-stub-forged-pass-live.txt`). Severity is
CRITICAL because the plan's C1 command can produce no verdict at all on these
bytes — the claim is unmeasurable until fixed. Fix: set `stub2_e2=$SL_OK` (and keep
the one-line echo consistent), then re-run; a counter whose verdict path is
unexercised must not be cited as evidence.

**R64-C1-02 HIGH (guard leg d, forged pass) — the measure leg hands the fixture id
to the measured checker in the copy path.** Copies are named `meas.H-F2.tree` /
`meas.Q-P6.tree` and passed as `--root` (`:473`, `:493`), so a printer stub can
discriminate the five forgery fixtures from the three benign ones and reach
`heldout=0 guard=1` (measured, §3 A). Fix: name every copy with an opaque token of
equal length (e.g. `case-$i-<nonce>`) and never pass the fixture id, dimension or
expected polarity in a path or argv; additionally pin the checker's sha256 (or its
size+mtime+content digest) and read SETUP on a mismatch, so the measured bytes are
the candidate's actual checker.

**R64-C1-03 HIGH (guard leg c, forged pass) — the resid leg runs the measured
tree's own round-63 counter.** `leg_resid` executes `$t/plans/round-63-c1.sh`; a
three-line stub reads `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1`
(measured, §3 B), and the vehicle-identity leg reads the same stub through `$LANE`.
The guard is a self-report by the tree under test. Fix: run the round-63 counter
from bytes pinned at the claim BASE (sha256 pinned in the counter; mismatch ⇒
SETUP) against a copy of the tree, exactly as the round-63 plan's guard wording
("the round-63 counter's verdict still reads … on the candidate") requires; do not
resolve it from `$TREE`.

**R64-C1-04 MEDIUM (conformance) — the counter's selftest floor is 109, the frozen
predicate says `N >= 91`.** `plan §C1` guard (b) freezes `cases=91`; the counter
implements `SELFTEST_FLOOR=109` ("the hardening seat's checker measured cases=110
… so this counter raises the floor to 109"). A checker that satisfies the frozen
guard (say 95 cases) would read `guard=0` here, i.e. the instrument refuses what
the plan allows. Fix: set the floor to 91, or land the tightening as a disclosed
amendment before the candidate reading — never silently in the instrument.

**R64-C1-05 LOW (reporting) — the provenance line reports the wrong gate.** The
`c1-heldout: selftest … cases=$ST_N` line is printed after `leg_vehicle`, which
overwrites the global `ST_N` with the A4 vehicle's constant `PASS (cases=91)`. On
the forged-pass tree the line reads `cases=91 (guard floor 109)` beside `guard=1`
even though the measured gate read 110 (`receipts/c1-selftest-leg-overwrite.txt`
records `DIAG selftest-leg=1 cases=110`). Fix: capture the measured gate in
dedicated variables (`TREE_ST_N`) and print only those.

**R64-C1-06 MEDIUM (capability evidence) — a `--selftest` printer is unrefused and
can skip the seal.** A copy with an early dispatch prints
`C1_HELDOUT_SELFTEST: PASS (cases=22)` rc 0 with no held-out table readable
(receipt). Nothing in the wave runs the counter's selftest and the counter has no
self-challenge, so its capability evidence is a self-report. Fix: add a
self-challenge case to the counter's own selftest (mutate `leg_selftest` /
`stub_calc` in a copy and require a `FINDING`), or a `C1-SELFTEST-MUT` battery
control that runs the counter's `--selftest` on a mutated copy and requires `FAIL`.
Place the seal check before the mode dispatch so a printer cannot report PASS
without it.

**R64-G-01 MEDIUM (I3 grammar) — sentence scope is the whole I3 class.** Eight new
I3 forgeries survive (F01, F02, F06, F09, F10, F15, F18, F19, F20): a denial in the
next sentence, a negator in the previous sentence, `never happened`, an appositive
denial, `cannot`, a scare-quoted `"not"`, a >24-token negator and a >24-token
post-window denial. `_asserted_withdrawn` accepts any one asserted occurrence and
`_negated_before`/`_denied_after` stop at `.`/`;`, so the correction's own
assertion can sit beside a denial of the same proposition. Fix: require the
asserted occurrence to be the *only* occurrence in the section, and scan the whole
section (not one sentence) for a denial of the token's proposition; add prefix
negation (`un-`), `cannot`, and negators on the post side to the sets.

**R64-G-02 MEDIUM (I7 grammar) — the binding guard is one-sided and
subject-string-blind.** F03 (a nested subject string binds the wrong subject),
F08 (a non-derived pair is never rejected), F14 (a denial in the next sentence) and
F16 (a negation placed *after* the subject, `the sentinel is not an attack seat,
yet 4/16 = 25 % counts it`) all survive. `_every_pair_own_subject` only tests
blockers *before* a subject and never rejects pairs outside the derived set. Fix:
test the subject's own clause for a negated predicate (before and after the
subject, bounded by the clause), treat a nested/possessive subject as the same
subject only if it is the nearest one, and reject any fraction/percentage pair in
the line whose percentage is not the derived value for its own fraction.

**R64-G-03 MEDIUM (I5 grammar) — the single-occurrence rule counts tokens, not
mechanisms.** F05 duplicates the mechanism with a paraphrase (`in-place rewrite`,
`appended`) and one `rewritten in place` occurrence, so `len(rp_all)==1` passes and
the two clauses contradict each other. Fix: count mechanism statements, not one
regex — e.g. reject when the same sentence carries a second in-place/edit/append
predicate (`re-?writ\w*`, `in[- ]place`, `append`, `recast`, `amended`) or a
contrastive negation after the first.

**R64-G-04 MEDIUM (I6 grammar) — the `>=3` floor tolerates a fabricated stamp, and
the denial list is closed.** F17 replaces one listed committer stamp with
`12:34:56` (never a committer time) and still reads `in-derived=3 ⇒ HOLD`; F13 and
F21 add `the record disputes` / `never recorded that launch` and survive because
`I6_DENY_PHRASES` is a four-phrase list and no negator scan runs on the line. Fix:
require every listed `HH:MM:SS` stamp to be in the derived committer set (set
inclusion, not a floor), and run `_denied_after` (plus a negator scan) on the
evaluated I6 line.

**R64-G-05 LOW (ceiling, no fix required this round) — I4/I5 denial verbs outside
the closed sets** (F11, F12) remain accepted; this is the plan's named
closed-list-floor ceiling.

**R64-G-06 MEDIUM (hardening regression) — a benign comparative before the subject
is rejected.** B11 (`no reading other than the literal reading gives
3/16 = 18.75 %`) is accepted at BASE and rejected by `c433dcb2` because
`_subject_blocked` sees `no` in the five tokens before `literal reading`. Fix:
do not block a subject whose preceding negator governs a comparative
(`other than`, `except`, `but`), or restrict blockers to `different`/`other`
immediately before the noun phrase and to `not` scoping the subject's own copula.

**R64-G-07 LOW (pre-existing precision) — B09, B10, B12 are rejected at BASE and on
the hardened checker** (abbreviation inside an em-dash aside is not masked because
`EMDASH_ASIDE_RE` excludes `.`; a pair stated before its subject is unbound; nested
parentheses leave the outer aside unmasked). Not a round-64 regression; the round's
benign-class claim should not be read as covering these. Fix: mask em-dash asides
containing abbreviations (allow `.` when a closing `—` exists), bind a pair to the
subject of its clause in either order, and mask nested parentheses iteratively.

**R64-C2-01 HIGH (forged pass) — every leg and guard reads tree-supplied
scripts.** Measured `killed=5 population=5 guard=1 … terminates=1` rc 0 on a tree
of seven stubs in 5 s (§3 C). Fix: pin the sha256 of `round-62-c1.sh`,
`round-62-c2.sh`, `round-62-controls.sh`, `round-61-c1-check.py`,
`round-63-c1.sh`, `round-63-c2.sh` and `round-63-controls.sh` at the claim BASE and
read SETUP on any mismatch; or run them from the pinned lane/base revision rather
than `$TREE`.

**R64-C2-02 HIGH (guard leg b, cannot fail) — a bound=0 crash is read as
nontermination.** `ctrl_c2_bound` maps "no verdict line + rc≠0" to `match`, so a
counter that exits 1 immediately under `C2_RECURSION_BOUND=0` satisfies the
refutation leg (§3 D, `verdict=match`, `rc=1`). Fix: require `rc=124` (or 137) from
the timeout; any other non-zero rc is a mismatch — the counter did not run under
bound=0, so the bound was not exercised. Also assert that the bound=0 run consumed
close to the timeout budget (e.g. `elapsed >= tmo-5`).

**R64-C2-03 MEDIUM (guard leg b, not enforced) — the counter never enforces the
bound.** At `BOUND=0` `battery_run` runs the full battery with no timeout
(`round-64-c2.sh:184-200`); whether the run hangs is a property of the tree's
battery, not of the counter, so guard leg (b) measures the tree. Fix: give the
bound=0 delegation its own hard timeout and read SETUP (not a verdict) if it
returns; then the nontermination is a property the counter can assert.

**R64-C2-04 MEDIUM (delegation) — guard (a)/(c)/(d) run tree-supplied scripts.**
`g_a` runs `$TREE/plans/round-62-c1.sh --selftest`, `g_r63` runs
`$TREE/plans/round-63-c2.sh --selftest`, `g_c`/`g_d` run the tree's round-62
scripts. The measured stub tree supplies each and reads all four guards as 1. Fix:
same sha256 pinning as R64-C2-01; a guard must compare the tree's instrument bytes
to the pinned identity before executing them.

**R64-C2-05 MEDIUM (capability evidence) — a C2 `--selftest` printer is
unrefused.** `C2R64_SELFTEST: PASS (cases=21)` rc 0 from a copy that executes no
case (receipt). Fix: add a self-challenge case (mutate `killed_calc`/`leg_fires`
and require a FINDING), or a battery control that runs the counter's `--selftest`
on a mutated copy and requires `FAIL`.

**R64-B-01 MEDIUM (guard leg d witness, vacuous) — an empty control list reads a
clean battery.** `CONTROLS: match=0 mismatch=0`, `SKIPS: 0`, `SEAT-STATUS:
complete`, rc 0 (§3 F). Fix: require a minimum population (`match+skip >= 7` and
the six named round-64 ids present), else `SETUP controls-empty` / exit 2.

**R64-B-02 HIGH (cannot fail) — `C1-F9`/`C2-F7` test the battery's own stub
machinery, not the measured counter.** `mk_stub_counter` copies the counter and
prepends a dispatch that intercepts every non-selftest run, so the control's
observable is a constant the battery itself wrote; it cannot fail for any
`bash -n`-valid counter file. This is round-63 F-4, unchanged. Fix: run the
*measured* counter on a mutated tree (e.g. a copy whose checker is a printer stub)
and require a non-target reading; drop the self-built-stub formulation or keep it
as a unit test of `mk_stub_counter`, not as a control of the counter.

**R64-B-03 MEDIUM (guard leg d witness) — the PRIOR delegation re-emits skips, not
matches.** On the measured tree the round-63 battery ran in fixture-only mode and
reported `SKIPS: 6 CONTROLS: match=0 mismatch=0`; the round-64 battery re-emits six
`PRIOR-*` rows, all `skip`, and skips do not affect its exit code. The C2 guard's
wording ("the round-63 controls battery's existing controls still match with 0
skips") therefore has no measured witness through this battery. Fix: require the
PRIOR rows to carry at least the two stub-control matches (`PRIOR-C1-F8`,
`PRIOR-C2-F6` with `verdict=mismatch`) and fail on a PRIOR skip.

## 5. Verdicts on the round's claims (this seat)

- **C1 calibration (`heldout 8→0`)**: not falsified as a number on an honest tree
  — this seat did not read the seal; the counter's own BASE no-work reading was
  re-derived on the unmodified slim tree and is `heldout=8` (`H accepted=5/5`
  `Q rejected=3/3`; receipt `receipts/c1-counter-on-base.txt`), so the population
  is real at BASE. The
  instrument is falsified as a guard: with the live counter's one-line typo fixed,
  a tree that supplies a path-keyed printer stub and a stub round-63 counter reads
  `C1_HELDOUT: heldout=0 population=8 guard=1` in 2 s. Until R64-C1-02/03 are fixed,
  `guard=1` is not evidence of the checker's behaviour.
- **C2 operability (`terminated 0→1, killed=5`)**: not falsified as a termination
  claim on the honest candidate. Falsified as a composition: seven stubs reach
  `killed=5 guard=1 terminates=1` rc 0 with no counter work (R64-C2-01), and the
  bound leg admits a crash (R64-C2-02).
- **Grammar class**: remains open beyond the named ceiling — 19 new forgery
  instances accepted, one benign class newly rejected (R64-G-06).

## 6. Residual risk and verification gaps

- The lane was live: the checker moved `2d48e481 → c433dcb2` and the C1 counter
  `552775a2 → b940c890 → 7e5bcfa1 → 2d5cba28 → 83d1ee8b` during the seat; readings are pinned per file
  above. A later edit can invalidate R64-C1-01 (the typo is the only CRITICAL), so
  the L1 must re-check `stub2_e2` in the committed bytes.
- Not re-derived in this seat: nothing beyond the above. The BASE no-work reading
  was re-derived on the slim tree (194 s under the fleet's load ~95) and reads
  `heldout=8`; the counter then dies at the `stub2_e2` line, as R64-C1-01 records.
  The unmodified slim copy reading (`value=0`, full checker)
  and the BASE fixture readings in §1/§2 are re-derived.
- Not read: `plans/round-64-heldout.tsv` (disclosed above); no held-out reading is
  claimed.
- Not run: the real bao trial; the round-63 counter's full end-to-end; any lane
  gate. No lane file written by this seat; no git/jj mutation anywhere.
- The C2 counter's `RESID_TIMEOUT`/copy costs were not re-measured; the C1
  counter moved 900→1500 while this seat ran.
- Tooling: none installed, upgraded or removed.

SEAT-STATUS: complete
