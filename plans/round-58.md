# Round 58 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 58, attempt 1. Claim BASE
`1b13f5dad921f8901f56d30c428f89614dd74d8a` (round-57 verifier spot-check tip).

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3; a capability entered round 57,
so no stagnation waiver is claimed. Both claims are declared below before any
candidate work; this file is committed alone as the predeclaration, then the
instruments are committed, then the pre-freeze control battery, then the candidate.

Motivating evidence for the round:
- `corpus/lessons/round-57-verifier-spotcheck.md` (non-author closure, lane tip
  `1b13f5d`) routed twelve defects D1–D12; the fixable ones are unresolved at BASE
  and no lane gate reads them.
- `bash corpus/scope-gate.sh` at BASE ends
  `ADJACENCY_SCOPE: DEFECT … stale_basis=1` naming `SCORECARD.md:54` as a basis line
  that no longer carries the token `opencode`.
- `corpus/knowledge/` holds no executed OpenBao **authorization** mechanic: the lane's
  trials cover token/lease (r49), wrapping (r51), KV v2 versions (r52) and audit
  devices (r57); ACL path matching, capability precedence and deny semantics are
  documented only.

## C1 — calibration: the round-57 routed record defects are resolved and re-checkable

Target axis: calibration (mismatch count between the lane's own statements/pointers
and the observed repository state).

**Frozen predicate (this sentence is the plan's, the counter's code and the receipt's label):**

```
C1_ROUTED: value = the number of UNRESOLVED items over POP = 8 fixed routed-defect
items (I1..I8 below), when GUARD = 1, else FAIL; target 0 (BASE 8).
An item is UNRESOLVED iff its named condition does not hold on the measured tree.
GUARD = 1 iff the checker evaluates all eight items (prints population=8 with
i1..i8 each 0|1, none skipped) and, on a copy of the measured tree whose only
delta is the I4 statement text changed to a wrong count, prints exactly value+1.
```

| id | routed defect | required condition on the measured tree |
|---|---|---|
| I1 | spot-check D1 | `LOG.md`'s round-57 entry names freeze epoch C and the epoch-C receipt path, and `SCORECARD.md`'s round-57 post-move section names epoch C. |
| I2 | D3 | a `controls-prefreeze-epochC*.txt` receipt under `.ufo/waves/round-57/controls/` has an `INSTRUMENT` pin for `plans/round-57.md` equal to that file's sha256 in the measured tree and its last `CONTROLS:` line reads `match=13 mismatch=0`. |
| I3 | D4 | `corpus/lessons/round-57.md` carries a `## Gate` row for S117 naming its URL, the access date, and a quote of at most 25 words that occurs in `.ufo/waves/round-57/capture/S117.body`; S117's `used-by` cell names `corpus/lessons/round-57.md`; the lesson's `source:` line names S117. |
| I4 | D5 | every registry-count statement in the round-57 surface (`SCORECARD.md` round-57 post-move coverage row, `corpus/lessons/round-57.md` §Sources) states the measured data-row count of `corpus/SOURCES.md`; and any count a line attributes to `.ufo/waves/round-57/final/gates.txt` equals the count that file carries. |
| I5 | D6 | `SKILL.md`'s gate registry carries a row for `corpus/current-claims.py` naming its entry command, its verdict map and its `--selftest`. |
| I6 | D7 + D8 | `corpus/current-claims.py` accepts `--round N`, derives every audited-surface path from N (no literal round-56 path in the surface list), its module docstring's EPOCHS sentence names the authority its code reads, and `--selftest` exits 0. |
| I7 | D12 | the round-57 lesson's S115 Gate row names the live heading `Enabling/Disabling audit devices`. |
| I8 | D11 (stale basis) | `bash corpus/scope-gate.sh` at the measured tree reports `stale_basis=0`. |

Commands:
```
python3 -I -B plans/round-58-c1-check.py --root <tree>
bash plans/round-58-c1.sh <revision>          # BASE when omitted; --tree DIR also accepted
```
Output line: `C1_ROUTED: value=V population=8 i1=.. i8=.. guard=G`.
Exit 0 iff guard=1 and V==0; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: if any item's "fix" is a wording change the item's own condition does not
  read (checked by the eight forgery controls C1-F1..C1-F8 in
  `plans/round-58-controls.sh`, each of which breaks one item's substance while
  keeping its words), the counter must read value>0 on that forged tree; a forged
  tree reading 0 voids the claim and the counter reads FAIL.
- K2: if the checker prints value=0 on a tree that is byte-identical to BASE in
  every input file of an item, that item is vacuous and the claim is void.

**Population census at BASE (must be measured, not assumed):** the checker run on
the BASE tree must print `value=8 population=8`.

**Named ceilings:** the eight items are a closed set (the routed list is fixed by
the spot-check); an item's condition is a structural read, not a semantic proof that
the fixed text is true; the checker trusts the files it reads (a forged authority
that satisfies the condition passes).

## C2 — operability: an executed OpenBao ACL-policy semantics trial

Target axis: operability (a new executed capability, `SCORECARD.md` §Capabilities).

**Frozen predicate:**

```
C2_POLICY_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 twice, each of
the five falsifier shims flips exactly its designated test (baseline vector HHHHH;
SH1 -> BHHHH, SH2 -> HBHHH, SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB), a PATH with
no bao reads SETUP rc2 with no HOLDS, and a PATH wrapper that lies on the
client-side capability introspection flips exactly T5; else 0.
Target 5 (BASE 0: the trial does not exist at BASE).
POP: T1 deny-by-default and exact-path reach; T2 `*` prefix glob only as the last
character; T3 deny precedence over a broader allow; T4 `+` bounded to one path
segment; T5 union of capabilities at one pattern vs highest-priority match across
different patterns.
```

The five tests, each grounded in the sources opened this round (S118
`https://openbao.org/docs/concepts/policies/`, S119
`https://openbao.org/docs/commands/policy/`, both OpenBao docs Version 2.7.x):

| test | mechanic | observable |
|---|---|---|
| T1 | "Policies are deny by default, so an empty policy grants no permission"; a `read`-only token "cannot update or delete" the path | empty-policy token denied (403 `permission denied`) on a KV v2 data read; a `read`-grant token reads its path and is denied an update on it |
| T2 | `secret/bar/*` reads `secret/bar/zip` and `secret/bar/zip/zap` but not `secret/bars/zip`; `*` is "only supported as the last character of the path"; an exact path does not match a longer name | prefix-grant reads both descendants and is denied the sibling `bars`; exact grant reads its path and is denied the `food` extension |
| T3 | "this always takes precedence regardless of any other defined capabilities" (deny) | a token with a broad allow and a narrower `deny` stanza is denied at the denied path and allowed elsewhere |
| T4 | "a `+` can be used to denote any number of characters bounded within a single path segment" | `secret/data/+/teamb` allows one intermediate segment, denies two segments and denies zero |
| T5 | "If the same pattern appears in multiple policies, we take the union … If different patterns appear, we take only the highest-priority match" | same-pattern union: read from one policy + update from another both work, delete stays denied; different patterns: the exact `update` outranks a glob `read`, so read is denied while update works |

Commands:
```
bash plans/round-58-c2.sh <revision>          # BASE when omitted; --tree DIR also accepted
bash corpus/openbao-policy-trial.sh [--work DIR]
```
Output line: `C2_POLICY_TRIAL: value=V tests=5 pass=P shims=K vectors=ok/5 guard=G`.
Exit 0 iff value=5; 1 otherwise; 2 SETUP.

**Kill rules:**
- K1: a PATH with no `bao` must read SETUP rc 2 with no `HOLDS` line; a counter
  that scores it void the claim.
- K2: the trial must resolve `bao` through PATH (the wrapper leg); a trial with an
  absolute-path binary and shape-keyed output is the declared ceiling, checked by
  the receipts and a non-author probe, not by the counter.
- K3: no token or value may appear on any argv or in any printed line; a
  secret-shaped string in the counter's receipts voids the claim.

**Named ceilings:** a trial that shape-keys the shim vectors and introspects the
PATH wrapper reads 5 without measuring anything (the round-51/57 ceiling class);
one binary (OpenBao 2.7.2), the dev server's in-memory storage, one host; KV v2
path mapping only; templated policies, identity templating, `sudo` on root-protected
paths and `scan` are not measured.

## Instruments created by this round

- `corpus/openbao-policy-trial.sh` — the trial (T1–T5, shims SH1–SH5).
- `plans/round-58-c1-check.py`, `plans/round-58-c1.sh`, `plans/round-58-c2.sh`,
  `plans/round-58-controls.sh`.
- `corpus/current-claims.py` gains `--round N` (I6); it stays the gate that reads
  current-tense numeric self-descriptions.

## Pre-freeze controls (`plans/round-58-controls.sh`)

Two no-work controls (both counters on the BASE tree: C1 value=8, C2 value=0), one
positive reference reading (a tree carrying the fixes reads 0; a tree carrying the
trial reads 5), and eighteen forgery/fail-closed controls:

- C1-F1..C1-F8 — each breaks one item's substance while keeping satisfied-looking
  text; the checker must read exactly 1.
- C1-F9 — the checker on a tree with an item file removed reads pop<8/FAIL.
- C1-F10 — a printer stub (always value=0) fails the challenge leg.
- C2-F1 — a trial with the T5 shim removed reads <5; C2-F2 — a no-bao PATH reads
  SETUP; C2-F3 — a wrapper that lies on capability introspection must flip T5 only;
  C2-F4 — a trial whose real run is single-run (not repeated) reads <5;
  C2-F5 — a trial that prints HOLDS lines without a summary reads 0.
- C2-F6 — a counter that accepts a shim flipping two tests reads <5.
- C2-F7 — a trial binary whose sha256 is not the pinned OpenBao 2.7.2 is SETUP.
- C2-F8 — ambient `BAO_*`/`VAULT_*` variables exported by the caller do not change
  the readings.

The battery must read `CONTROLS: match=<N> mismatch=0` before any candidate is
measured, and the receipt pins the instrument hashes.

## Shape and write scope

One v1 wave, 14 seats, under `scripts/hyaku/ufo-wave-policy.json` (band 8–16):
4 executors, 2 scouts, 2 scribes, 1 labrat, 1 reviewer, 1 critic, 1
mutation-tester, 1 sentinel, 1 connector (attack share 4/14 = 29 %). The L1 holds
the canonical planner seat. Seats return findings and files; only the L1 commits,
through `scripts/hyaku/jj-lane.sh`.

## Amendments

### A1 — 2026-11-07, before any candidate reading of C1

I2's required condition is restated: a `controls-prefreeze-epochC*.txt` receipt under
`.ufo/waves/round-57/controls/` whose five `INSTRUMENT` pins (`plans/round-57.md`,
`plans/round-57-c1.sh`, `plans/round-57-c2.sh`, `plans/round-57-controls.sh`,
`plans/round-57-c1-check.py`) equal those files' sha256 in the measured tree, and whose
last `CONTROLS:` line reads `match=N mismatch=0` with N >= 13.

Reason: the frozen `plans/round-57-controls.sh` declares 15 controls when run with a REF
tree (the epoch-C receipt written at `8d8e0588` counted 13); the regenerated receipt
`.ufo/waves/round-57/controls/controls-prefreeze-epochC-final.txt` reads
`CONTROLS: match=15 mismatch=0` over the shipped bytes, so the literal-13 form would
leave a correct fix unresolved. The five-pin equality is the substantive check and is
strictly stronger than the count. Target, POP, guard, kill rules and every other item are
unchanged.

### A2 — 2026-11-07, before any candidate reading of C1

I3's quote test compares after collapsing whitespace runs: a quote of at most 25 words
counts as located when its text, with every run of whitespace normalized to one space,
occurs in the capture body with the same normalization. Reason: the rendered capture
wraps the S117 sentence across two lines; a raw substring test would reject a quote that
is present verbatim in the page. No other change.

### A3 — 2026-11-07, before any candidate reading of C1

I4's condition is restated in two count classes, because round 58 adds S118/S119 to the
registry and a round-57 delta statement must not claim rows that round 57 did not add. In
both locations (the SCORECARD round-57 post-move coverage row and the round-57 lesson
§Sources): (a) a *landing* count — a `Registry L → N` arrow — must state N = 117, the row
count the round-57 landing put in the registry (S117 landed in `94d72de9`); (b) a *tip*
count — a `tip count … = N` form or an `end … N rows` form — must equal the measured
tree's live data-row count; (c) any count attributed to
`.ufo/waves/round-57/final/gates.txt` must equal that file's `rows=` value and the line
must say the capture predates S117; (d) each location carries at least one count
statement. Reason: the plan's original single rule ("every statement equals the measured
count") would force the round-57 delta statement to claim 119 rows, two of which round 58
added; the landing count and the tip count are different facts. Target, POP, guard, kill
rules and every other item are unchanged.

### A4 — 2026-11-07, before the recorded candidate reading

§C1's population-census sentence ("the checker run on the BASE tree must print
`value=8 population=8`") is read through the frozen predicate's guard semantics: the
BASE tree yields two lines — the diagnostic leg prints `value=8 population=8` (all eight
items evaluated and unresolved), and the guard-bearing line prints `value=FAIL … guard=0`
because the wrong-count challenge cannot fire on a tree where I4 is already unresolved in
every class. "BASE 8" in the claim is the diagnostic count; the citable BASE line is
`C1_ROUTED: value=FAIL population=8 i1=0 … i8=0 guard=0` with its diagnostic companion.
No other change.

### A5 — 2026-11-07, before the recorded candidate reading

The pre-freeze control set is recorded as it runs (`plans/round-58-controls.sh`), with three
corrections the first battery exposed and the reviewer's attack predicted:
(a) C1-F4's expectation is `FAIL`, not `1`: breaking I4 removes the wrong-count challenge's own
target class, so the guard cannot add +1 on that tree; the item is still shown killed by
`i4=0`, and the checker's `--selftest` carries the value-1 shape for I4.
(b) C2-F2 and C2-F4 are the load-bearing pair for the counter's conjunction: a counter copy with
the shim/none/wrap conjuncts deleted reads 5 on the very trees the real counter refuses
(`C2-F6` double-flip shim, `C2-F3` introspection leg removed).
(c) §Pre-freeze controls' "C1 value=8" is the diagnostic-leg count; the citable BASE line is
`value=FAIL … guard=0` per A4.
The instrument hardening the reviewer's exploits required is part of the frozen bytes this
receipt pins: symlinked measured files read as absent, the coverage row must be unique, the S117
date must be the row's, the gate-registry row must sit in a gate-registry section and name the
script in its command cell, a named epoch-C receipt must exist, and item6 carries a behavioural
`--round` probe (a planted round-57-only disagreement must move `--round 57` and not `--round 56`).
