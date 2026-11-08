# R68MutGate — mutation probe: C1/C2 counters, the widened census gate, the ledger

Seat: R68MutGate (attack, mutation-tester). Lane `kagi-shokunin`, branch `master`.
Claim BASE `d3b2a4e8eed710277951e430efd3d27b5983033c`. Frozen predeclaration
`plans/round-68.md` (`23a8e02`, Amendment A1 `4251519`). Read-only on the lane:
every mutant ran on a scratch copy; no lane byte was written, no git command
mutated anything, no fleet path touched. Scratch
`/fast/scratch/hyaku/kagi-r68/R68MutGate/` (deleted after the receipts were
copied here). Tooling: system `bash` 5.3, `python3` 3.14.8; nothing installed
(`/home/vgpnk/.omp/agent/RULES.md` read; pacman paused, not run).

This is a mutation probe, not an integration judgement: each mutant is the
smallest behaviour-bearing edit at the point it names; a mutant is **KILLED**
when a detector refuses it and **SURVIVED** when the instrument still passes.
A surviving mutant is a coverage finding, never permission to change a
contract.

## Tested bytes (pinned)

| artifact | sha256 | state during probe |
|---|---|---|
| `plans/round-68-c1.sh` | `4461be435fe755aa0382e1bd8c60bb6ea0fb3297b2fb17c9561dd2351df2d2f6` | final tested counter (selftest `PASS (59 cases)`) |
| `plans/round-68-c2.sh` | `ba9d74b4d791224688483c4c427ed56ce4566fb3845a71b75626ca3598f57faf` | latest at C2 leg probe time; the seat was still editing |
| `corpus/sources-census.sh` | `b93f0614…` for the gate mutants; `5b9e1b37…` when the counter reference ran | green selftest `PASS (98 cases)` |
| `corpus/claim-ledger.tsv` | `ad5c719736542a2cd4038c8af4c4516cd06483d9f5d453655f5d1717b6437e9c` | R21-03 pin 98 cases, R68-01 `verified=38 col15=33` |
| `.ufo/waves/round-68/journals/expectation-migrations.json` | `70ca8245a8c3e0be52be8cc1cccb4f3de883c64f440a76159cb3a3c7c465ce48` | five migrations, R21-03 88→98 |

The live candidate reference at those bytes:

```
$ bash plans/round-68-c1.sh --tree <candidate copy> --base-tree <d3b2a4e8 archive>
C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1
```

`38/33` is the S167 frontier-row contribution over the frozen `37/32`
(Amendment A1.2); the counter's own line prints the measured numbers.

## 1. C1 counter mutants (a)–(e), (i)

Mutants are byte copies of `plans/round-68-c1.sh` under `mutants/`; each
substitution asserts it matched exactly once, and the copy is re-hashed.
Detection used two instruments: the counter's own `--selftest` (59 cases) and
independent divider trees where the pristine counter and the mutant must
diverge.

### (a) leg filter removed — any `SC_CAPTURE` finding counts

```
mutant: c1-leg-any.sh
        return any(fid == anchor_id and why == reason ...)  ->  return any(fid == anchor_id ...)
command: bash mutants/c1-leg-any.sh --selftest --base-tree <BASE>
output:  C1_VERIFIED_SELFTEST: FAIL (59 cases, 1 failed) names=m1-wrong-reason
verdict: KILLED by the counter's own selftest.
```

Divider (wrong-reason gate: the M4 emission renamed to `capture-token`, the
gate selftest expectations moved with it, gate selftest green):

```
pristine: C1_VERIFIED: verified=38 col15=33 caught=5/6 guard=1   (mut-m4 misses)
mutant:   C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1   (wrong reason counted)
verdict:  KILLED — the mutant credits a gate that emits the wrong reason,
          while the pristine counter refuses the same tree.
```

### (b) expected reason accepted loosely (`capture-` prefix only)

```
mutant: c1-leg-prefix.sh
        why == reason  ->  why.startswith("capture-")
output: C1_VERIFIED_SELFTEST: FAIL (59 cases, 2 failed) names=m1-wrong-reason,m5-right
verdict: KILLED. The prefix mutant also rejects `normalized-digest-mismatch`
         (m5-right), so its loosening is behaviourally visible in two places.
```

### (c) guard (b) threshold lowered to 0

```
mutant: c1-guardb-zero.sh
        cases >= 89  ->  cases >= 0
output: C1_VERIFIED_SELFTEST: PASS (59 cases)
verdict at selftest: SURVIVED (no guard-b boundary case in the selftest).
```

Divider (`lowcount`: a gate that runs every case but prints and exits
`SOURCES_CENSUS_SELFTEST: PASS (0 cases)`, i.e. a case-count liar; the gate's
`verify` path is untouched, so the tree stays CLEAN):

```
pristine: C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=0
          (guard a=1 b=0 c=1 d=skip e=1; guard-b cases=0 < 89)
mutant:   C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1
          (guard a=1 b=1 c=1 d=skip e=1; the 0-case liar passes)
verdict: KILLED by the divider — the mutant prints the passing predicate on a
         tree whose gate never ran a case, while the pristine counter refuses.
```

### (d) guard (e) removed

```
mutant: c1-guarde-removed.sh
        ge = guard_e(clean, derived)  ->  ge = 1
output: C1_VERIFIED_SELFTEST: PASS (59 cases)
verdict at selftest: SURVIVED (guard_e is not exercised by the selftest).
```

Divider (`prosefinding`: the gate prints a raw, uncounted
`FINDING SC_CAPTURE id=S150 capture-token` for a prose row while its verdict
stays CLEAN with counts equal to the derivation; the divider gate's own
selftest is green, `PASS (98 cases)`):

```
pristine: C1_VERIFIED: verified=38 col15=33 caught=0/6 guard=0
          (guard a=1 b=1 c=1 d=skip e=0; guard-e prose_findings=S150)
mutant:   C1_VERIFIED: verified=38 col15=33 caught=0/6 guard=1
          (guard a=1 b=1 c=1 d=skip e=1; caught=0 because the raw finding also
           breaks the verdict/finding-count reconciliation)
verdict:  SURVIVED at the selftest (59 cases PASS); NOT independently
          falsifiable: with the counter's forgery reconciliation landed, any
          unscored SC_CAPTURE finding on the clean tree either flips the
          verdict (guard-a=0) or breaks the leg accounting (caught<6). No
          reachable input let the guard-e-removed mutant print a passing
          verdict; the guard hole is masked by stronger checks, which is a
          coverage finding, not a contract change.
```

### (e) derivation uses the candidate's own normalizer

```
mutant: c1-cand-normalizer.sh
        locator_script(): TREE's corpus/rendered-text-v1.py first
output: C1_VERIFIED_SELFTEST: PASS (59 cases)
verdict at selftest: SURVIVED (the selftest tree has no lying normalizer).
```

Divider (`normwrap`: a normalizer that delegates to the trusted copy for
every call except a sentinel quote, so the gate's own selftest stays green but
S166's garbage quote "locates" in-tree):

```
pristine: C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=0
          (guard a=0 b=1 c=1 d=skip e=1; defe defects=1 — S166's garbage quote
           does not locate under the trusted normalizer, and the gate's 38
           counts disagree with the 37-row derivation)
mutant:   C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1
          (guard a=1 b=1 c=1 d=skip e=1; the tree's wrapper normalizer moves
           both sides of the cross-check together)
verdict:  KILLED by the divider: the mutant accepts the tampered tree.
```

### (i) anchor id hard-coded instead of derived

```
mutant: c1-anchor-hardcoded.sh
        anchor["id"] = "S166" after the derivation loop
output: C1_VERIFIED_SELFTEST: FAIL (59 cases, 7 failed)
        names=anchor-is-last-token-binding,anchor-last,anchor-skips-nonbinding,
        builder-m1-mutates,builder-m2-mutates,builder-m4-mutates,builder-m5-mutates
verdict: KILLED by the selftest.
```

Divider (`no-anchor`: the S166 fetch row deleted; the derived anchor is S167):

```
pristine: anchor id=S167  caught=6/6 guard=0 (a=0 c=0 from the deleted row's
          missing-provenance finding)
mutant:   anchor id=S166 (token still S167)  caught=1/6 guard=0
          (only the id-independent file-level M3 leg survives)
verdict:  KILLED twice — by the selftest and by the divider.
```

## 2. Census-gate mutants (f)–(h)

Each mutant is a *self-consistent* deletion: the check and its own selftest
cases are removed together, and the gate's `--selftest` is re-run to prove it
is green (otherwise guard-b, not the leg, would be the only detector). Trees
are copies of the candidate with only `corpus/sources-census.sh` changed.

| mutant | edit | gate selftest | pristine C1 counter (measured) |
|---|---|---|---|
| `drop-whitespace-clean` | delete the cell classifier's whitespace block + its two cases | `PASS (96 cases)` | `C1_VERIFIED: verified=38 col15=33 caught=5/6 guard=1` — `mut-m1` has no `capture-whitespace` |
| `drop-normdigest-clean` | delete the col-15 recompute block + `capture-normalized-mismatch` case | `PASS (97 cases)` | `C1_VERIFIED: verified=38 col15=33 caught=5/6 guard=1` — `mut-m5 verdict=CLEAN` |
| `drop-cr-clean` | delete the file-level `grep -q $'\r'` finding + `fetch-cr-in-tsv` case, and adjust the CRLF case's finding count 2→1 | `PASS (97 cases)` | `C1_VERIFIED: verified=38 col15=33 caught=5/6 guard=1` — `mut-m3 crlf=0` |

The counter lines above were measured on the self-consistent mutants built at
gate `b93f0614…`; the final-gate (`e48fc6a7…`) rebuilds of the same three
deletions are green (`gm2-*-selftest.txt`, `96/97/97` cases) and the final
counter runs on them (`fin2-gm-*.txt`) also read
`C1_VERIFIED: verified=38 col15=33 caught=5/6 guard=1` — the same deletion
class, the same kill.

Verdicts: **all three KILLED** — the counter's six-leg accounting drops to
5/6 and its verdict line/exit refuse, so a gate that deletes any one of the
three new checks is measurable. Note the CR case: the CRLF file still fails at
the per-cell level (`capture-whitespace` on every CR cell, bound=0), but the
frozen M3 leg expects the file-level `SC_FETCH cr-in-tsv`; the exact-reason
match is what keeps the deletion visible.

## 3. C2 counter mutants (j)–(l)

Leg-level detector: `c2leg.py` extracts the counter's embedded Python and runs
one leg against a divider tree, so the expensive full-ledger `guard()` is not
needed to see the leg's own verdict. Counter bytes `ba9d74b4…`.

### (j) L1 compares two literals instead of the live count

```
mutant: c2-l1-literals.sh   (m = n inserted before the live comparison)
tree:   divc-l1 — the gate's --selftest prints/exits PASS (0 cases) while running every case
pristine: C2LEG: leg=LEG1 ok=0 detail=R21-03 expect carries no case count
mutant:   C2LEG: leg=LEG1 ok=0 detail=R21-03 expect carries no case count
verdict:  SURVIVED at the leg. Root cause is a defect in the instrument, not
          the mutation: expect_cases cannot parse the canonical expect (§5 F1),
          so the live comparison is never reached by either side. The counter's
          own selftest confirms the consequence at `9b32226f…`:
          `C2_RECORD_SELFTEST: FAIL (7 cases, 1 failed)`, case `positive`
          `rc=1 last=C2_RECORD: mismatches=2 population=3 guard=0`.
```

### (k) L3 accepts any SETUP as a skip

```
mutant: c2-l3-setup-skip.sh  (any rc!=0 from cells -> return True "cells=SKIP")
tree:   divc-l3 — SCORECARD.md header-only, cells exits 2 "no scored cells found"
pristine: C2LEG: leg=LEG3 ok=0 detail=cells no-verdict-line rc=2 tail='claim-ledger: no scored cells found …'
mutant:   C2LEG: leg=LEG3 ok=1 detail=cells=SKIP rc=2
verdict:  KILLED by the divider. The counter's own selftest negative
          (neg-scored-missing-axis) does NOT kill it: guard(c) independently
          refuses that fixture, so the selftest case passes with or without the
          mutant — a masking the probe makes visible.
```

### (l) L2 satisfied by row text alone

```
mutant: c2-l2-rowtext.sh  (the whole counter-execution block deleted)
tree:   divc-l2 — plans/round-68-c1.sh replaced by a `NOT_A_C1_VERDICT` stub
pristine: C2LEG: leg=LEG2 ok=0 detail=rows=R68-01,R68-02 c1-verdict-unrecognised rc=0 last='NOT_A_C1_VERDICT'
mutant:   C2LEG: leg=LEG2 ok=1 detail=rows=R68-01,R68-02 claims-declared=CLEAN
verdict:  KILLED by the divider. The selftest has no counter-absent/counter-
          lying fixture, so the mutant survives the counter's own selftest.
```

Note also that the pristine L2 as written accepts *any* `C1_VERIFIED:`-prefixed
last line (not `guard=1`), and `guard(b)` excludes `FAIL <id>` findings whose
id is in the ledger (`is_lesson_only`), so an absent/lying C1 counter does not
turn guard(b) red either: the leg's "green-consistent" docstring is stronger
than its code. The (l) divider shows both halves.

## 4. Ledger mutants (m), (n)

Detector: `bash corpus/expect-journal.sh --base-ledger <BASE ledger> --ledger <candidate> --journals <candidate journals>`.

Control on the landed bytes: `EXPECT_JOURNAL: CLEAN (changed=5 journaled=5)` rc 0.

```
(m) R21-03 expect -> '^SOURCES_CENSUS_SELFTEST: PASS' (prefix, no end anchor),
    journal new_expect matches:
EXPECT_JOURNAL: REFUSE NOT_LITERAL R21-03
EXPECT_JOURNAL: REFUSED (violations=1)   rc 1          -> KILLED

(n) landed ledger, journal with the R21-03 entry removed:
EXPECT_JOURNAL: REFUSE UNJOURNALED R21-03
EXPECT_JOURNAL: REFUSED (violations=1)   rc 1          -> KILLED
```

## 5. Findings (measured)

**F1 — the C2 counter's L1 pin parser cannot parse the ledger's pin format.**
`expect_cases()` as landed at `9b32226f…`/`ba9d74b4…`:

```python
m = re.search(r"\(\\?\((-?\d+)\) cases\\?\)", expect)          # needs ((89) cases)
m = re.search(r"\(\^?\\?\((\d+)\) cases\\?\)", expect)         # needs (\(\^?\(…)
```

The ledger's row is `^SOURCES_CENSUS_SELFTEST: PASS \(98 cases\)$`; both
patterns need a *second* literal `(` where the canonical form has `\`. Measured:

```
re.search(pattern, '^SOURCES_CENSUS_SELFTEST: PASS \\(98 cases\\)$') -> None
L1 detail on the real ledger: "R21-03 expect carries no case count"
```

The only strings these patterns match (`PASS ((89) cases)`, `PASS (\(89) cases\)`)
contain unescaped interior parentheses, which `expect-journal.sh` R3 refuses as
NOT_LITERAL — so **no R3-valid expect can satisfy L1 as written**. The
counter's positive selftest case therefore cannot pass, and its
`neg-l1-pin-88` negative case passes for the wrong reason (the same parse
failure, not the live-count mismatch). This is the QM89 class ("a verdict
field that cannot read differently") in the C2 instrument.

**F2 — C2 selftest negatives are masked by guard(c).** `neg-scored-missing-axis`
returns non-zero either because L3 refuses the tree or because guard(c)'s own
fixture refuses; the mutant that removes L3's refusal still fails the selftest
case only because the guard catches the class. The probe's independent divider
(cells failing for a class guard(c) does not own) is what kills (k).

**F3 — C1's frozen `37/32` versus the live `38/33`.** The live candidate
(including this round's own S167 frontier row) derives `verified=38 col15=33`;
a recut-only candidate derives the frozen `37/32`. Amendment A1.2 records both
and the ledger row R68-01 pins `38/33`. The counter prints its derivation and
the kill rule is a floor (`< 37`/`< 32`), so the frozen target is met; any
report must state both readings, never only one.

**F4 — A1.1's BASE anchor id and the implemented rule disagree.** A1.1 states
the last capture-path-shaped binding row is `S156` at BASE. The counter's
`derive_anchor` accepts a *mixed* cell's first token (deliberately, to keep the
prose escape hatch in the population), so at BASE it anchors `S166` (the
round-67 mixed row), and the old gate reads `caught=0/6` — the frozen no-work
control. A pure-token anchor at BASE is `S156`, on which the old gate catches
M4/M6 (`caught=2/6`). The numbers are self-consistent with the *implemented*
rule; A1.1's `S156` is not the rule the counter runs, and a reader applying
A1.1 literally would expect 2/6 at BASE.

**F5 — CRLF fails on two levels, but only one is the M3 leg.** The widened
gate emits per-cell `capture-whitespace` for every CR-terminated cell *and* the
file-level `SC_FETCH cr-in-tsv`; `bound` drops to 0. Deleting only the
file-level check still leaves the file FAILED (per-cell), yet the counter's M3
leg misses because its expected reason is the file-level line. That is a
correct detected deletion but a deceptive tree state: "the file still fails"
is not evidence the `cr-in-tsv` check exists.

**F6 — scratch hardlink incident (self-reported, restored).** Building the
`normstub` divider from `$S/ctrl` (a `cp -al` clone of the BASE extraction)
wrote `corpus/rendered-text-v1.py` **in place**, so the hardlink propagated the
stub into the BASE extraction itself. Detected by hash (`9da64fa0…` vs the
committed `14f6ca6a…`) and by an impossible `col15=1` derivation; the BASE
extraction was re-created from `git archive d3b2a4e8` (sha256s verified:
`14f6ca6a…` normalizer, `90dd4a2c…` TSV) and every affected reading was
discarded and re-run. The lane was never a source of a hardlink clone and was
not written; `corpus/rendered-text-v1.py` at the lane still hashes
`14f6ca6a…`. Divider builders now write through `.new` + `os.replace`.

## 6. Discarded readings

`div-lowcount-pristine.txt`, `div-lowcount-mutant.txt`, `div-prose-pristine.txt`,
`div-wrongreason-*.txt`, `c1-cand4-run1.txt`, `c2-selftest-initial.txt`, and the
`gm-*counter` runs made before the BASE restore show `col15=1`/`defects=32`
(the corrupted normalizer). They are kept in `discarded/` as restoration
evidence and are **not** used for any verdict in §1–§4. Final readings are in
`final-*.txt` and the `c2-leg*` receipts.

## 7. Residuals

- The C2 counter was still moving during the probe (`9b32226f` → `ba9d74b4`);
  its mutants must be rebuilt and the three leg probes re-run if the landed
  bytes differ. The advertised selftest (`C2_RECORD_SELFTEST`) was not taken
  to completion in the probe budget: each case re-runs `claim-ledger verify`
  on the full BASE ledger. Leg-level detectors were used instead, and F1 says
  the positive case cannot pass until `expect_cases` is fixed.
- The C1 counter/gate moved during the probe; every verdict above names the
  hash it ran on. A final re-run on the settled bytes is the integration
  reader's check.
- Ceilings carried, not re-opened: the gate cannot bind a fleet-root capture
  (S099), hardlink durability, one-token quotes, and a gate cannot vouch for
  its own normalizer (the counter's trusted-normalizer derivation covers the
  probe's (e) divider; the gate alone does not).

## Receipts

`R68MutGate/` (this directory): `fin2-*` final clean counter runs,
`c2-leg*` C2 leg probes, `selftest2-*` C1 mutant selftests, `gm2-*`
final-gate mutant selftests, `fin2-gm-*` final-gate counter runs,
`ledger-*` expect-journal refusals, `discarded/` the pre-restore readings.
Mutant bytes and the probe scripts are in `mutants/`.
