# R63ExecC1Grammar — round-61-c1-check.py hardening receipt

Seat: R63ExecC1Grammar (executor, calibration). Lane repo
`/home/vgpnk/Projects/shokunin/kagi-shokunin`, claim BASE
`0c07aab8df64b673a54a5113aebd7f34b622adbc`. Frozen plan
`plans/round-63.md` §C1 (predeclaration `12c9e428`).

File changed: `plans/round-61-c1-check.py` (only file owned).

Post-change pins:

- `sha256sum plans/round-61-c1-check.py` ⇒
  `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6`
- `wc -l plans/round-61-c1-check.py` ⇒ `2031` (was 1710 at BASE)
- `git diff --stat` ⇒ `417 insertions(+), 96 deletions(-)`
- selftest case count ⇒ `C1_CHECK_SELFTEST: PASS (cases=102)` (target N >= 91)

Scratch (deleted before yield): `/fast/scratch/hyaku/kagi-r63/R63ExecC1Grammar/`
— `base-tree/` = `git archive 0c07aab8` extraction; `fixtures/{base,f1..f10,p1..p6,
b3..b7,p3r..p5r}/` = per-fixture copies; `results/<name>.txt` = per-run output;
`gm5/` = mutant checkers; `selftest-work*/`, `ch-*/` = leg scratch.

## Commands and outputs

### 1. BASE tree, unmodified (must read value=0)

```
python3 -I -B plans/round-61-c1-check.py --root <scratch>/base-tree \
  --repo /home/vgpnk/Projects/shokunin/kagi-shokunin \
  --fleet /home/vgpnk/Projects/shokunin --no-challenge
```

```
c1: i1 HOLD derived results=16 output=3824 supersedes-lines-after=1 last-line=states-derived-count-and-names-mutants.md
c1: i2 HOLD selftest[rc=0 cases=36 PASS-line] registry[selftest-cell='`bash plans/round-60-c2.sh --selftest` ⇒' none-own=absent] mutation[mutated rc=1 finding=yes]
c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance
c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three
c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place polarity=asserted
c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 quoted-stamp=15:09:28 fleet-stamp=15:09:28 denial=none
c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-pairs-bound-to-subjects
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
rc=1
```

### 2. Full challenge run on the unmodified BASE tree (guard must read 1)

```
C1_CHALLENGE_PARENT=<scratch>/ch-full python3 -I -B plans/round-61-c1-check.py \
  --root <scratch>/fixtures/base --repo <lane> --fleet <fleet> --verbose
```

```
… (same seven c1: HOLD lines) …
c1-guard: copy delta deletions 1->2 on the evaluated I5 line: value=1 expect=1; stub value=0 fails=True
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=1
rc=0
```

### 3. Selftest

```
python3 -I -B plans/round-61-c1-check.py --selftest --work <scratch>/selftest-work2
C1_CHECK_SELFTEST: PASS (cases=102)   rc=0
```

### 4. Sixteen frozen fixtures (each on its own copy; `--no-challenge`)

Driver per fixture: `python3 -I -B plans/round-61-c1-check.py --root
<scratch>/fixtures/<id> --repo <lane> --fleet /home/vgpnk/Projects/shokunin
--no-challenge` with `C1_CHALLENGE_PARENT=<scratch>/ch-<id>`.

| id | file | C1_ROUTED line | rc |
|---|---|---|---|
| base | — | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| f1 | plans/round-60.md (`hardly withdrawn`) | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| f2 | plans/round-60.md (`withdrawn — the record denies it`) | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| f3 | plans/round-60.md (`not, as the earlier draft asserted, withdrawn`) | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| f4 | corpus/lessons/round-60.md (`"…did not route", a claim the record refutes`) | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0` | 1 |
| f5 | corpus/lessons/round-60.md (`did not introduce: three…`) | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0` | 1 |
| f6 | corpus/lessons/round-60.md (`did not introduce, as the earlier claim had it, three…`) | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0` | 1 |
| f7 | LOG.md (`not, contrary to the earlier record's claim, rewritten in place`) | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0` | 1 |
| f8 | corpus/lessons/round-60.md (fractions swapped) | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0` | 1 |
| f9 | corpus/lessons/round-60.md (`launch 16:59:59 −03`) | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0` | 1 |
| f10 | corpus/lessons/round-60.md (`launch 15:09:28 −03 (also seen at 16:59:59 −03)`) | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0` | 1 |
| p1 | plans/round-60.md (`Item 2 of A3 is withdrawn`) | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| p2 | plans/round-60.md (`not merely withdrawn`) | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| p3 | corpus/lessons/round-60.md (`no fewer than three…`) | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| p4 | corpus/lessons/round-60.md (`introduced 3 new record defects`) | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| p5 | LOG.md (`not appended but rewritten in place`) | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| p6 | LOG.md (`rewritten in-place at`) | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |

Every `C1_ROUTED:` line carries `population=7`; the failing item's `iN=0`
token is the one the fixture targets (f1–f3→i3, f4–f6→i4, f7→i5, f8→i7,
f9–f10→i6). Per-item `c1:` detail lines (e.g. f7 `polarity=not-asserted`,
f9 `quoted-stamp=16:59:59 fleet-stamp=15:09:28`, f8
`pair-missing-swapped-or-unbound`) are in `<scratch>/results/<id>.txt`.

### 5. Round-62 guard legs (guard c/d must still hold)

Same driver on bypass copies b3–b7 and paraphrase copies p3r–p5r:

| id | C1_ROUTED line | rc |
|---|---|---|
| b3 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| b4 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0` | 1 |
| b5 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0` | 1 |
| b6 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0` | 1 |
| b7 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0` | 1 |
| p3r | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| p4r | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| p5r | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |

### 6. GM5 mutant (I6 superseded-stamp conjunct dropped)

Mutant: `ok = len(qualifying) >= 3 and not denied and superseded_ok` →
`ok = len(qualifying) >= 3 and not denied` (the plan's L6 mutation).

```
python3 -I -B <scratch>/gm5/check-mut.py --selftest --work <scratch>/gm5-work
C1_CHECK_SELFTEST: FAIL (cases=102 failed=3
  names=f9-forgery-unresolved,f10-forgery-unresolved,
        i6-superseded-stamp-conjunct-isolated)   rc=1
```

Additional mutant battery (each mutant applied to a copy of the checker,
`--selftest` run; all FAIL with named cases):

| mutant | result |
|---|---|
| `NEG_WINDOW` 24→5 | FAIL (f3,f4,f6,f7-forgery-unresolved, window-negator-at-10-tokens) |
| `NEG_WINDOW` 24→48 | FAIL (window-negator-at-31-tokens-ignored) |
| idiom rescue removed | FAIL (p2,p3b-benign-resolved, not-merely-idiom-rescues, not-only-idiom-not-negator) |
| contrastive `but` rescue removed | FAIL (p5b-benign-resolved, contrastive-but-rescues) |
| `DENY_SINGLE` emptied | FAIL (f2,f4-forgery-unresolved, denial-after-token-detected) |
| I3 `item 2 of A3` alternative dropped | FAIL (p1-benign-resolved) |
| I4 digit-`3` alternative dropped | FAIL (p4b-benign-resolved) |
| I5 `in-place` hyphen form dropped | FAIL (p6-benign-resolved) |
| I7 subject binding reverted to bare pair search | FAIL (f8-forgery-unresolved) |

### 7. Negator-test removal mutant (K5 class)

Mutant: `return t in NEGATORS or t.endswith(NT_SUFFIX)` → `return False`.

```
python3 -I -B <scratch>/gm5/check-negmut.py --selftest --work <scratch>/neg-work
C1_CHECK_SELFTEST: FAIL (cases=102 failed=15
  names=b3-negated-withdrawn-unresolved,b4-no-three-unresolved,
        b5-not-rewritten-unresolved,f1-forgery-unresolved,
        f3-forgery-unresolved,f5-forgery-unresolved,f6-forgery-unresolved,
        f7-forgery-unresolved,negator-round63-membership,
        negator-set-membership,window-negator-detected,
        window-no-three-negated,mid-window-not-only-still-negator,
        window-negator-at-10-tokens,k5-negator-needle-unique)   rc=1
```

### 8. Missing fleet report → SETUP (never a silent pass)

```
python3 -I -B plans/round-61-c1-check.py --root <scratch>/fixtures/base \
  --repo <lane> --fleet /nonexistent-fleet --no-challenge
C1_ROUTED: SETUP fleet report .ufo/reports/round-60/kagi.md unreadable:
  [Errno 2] No such file or directory: …   rc=2
```

## What changed (plans/round-63.md §C1, item by item)

- **Polarity (I3/I4/I5).** New `_asserted(text, start, end)`:
  `_mask_quotes` blanks every `"…"` span ending at/before `start`;
  `_negated_before` scans the last `NEG_WINDOW=24` tokens after the nearest
  `.`/`;` (`:` dropped — the N7 fix), skipping negators that head a listed
  idiom at the token tail (`not only|merely|just`, `no fewer|less than`) or
  that a `but` token follows before the token (contrastive rescue);
  `_denied_after` scans the first 24 tokens after the match end up to the
  nearest `.`/`;` for the denial predicates (`denies/denied/deny`,
  `refutes/refuted/refute`, `is false`, `are false`, `not true`, `untrue`,
  `not the case`, `no such`).
- **I3** accepts `A3 item 2` or `item 2 of A3` (`A3_ITEM2_SEQS`) in the
  12-token anchor window plus `_asserted` on `withdrawn`.
- **I4** accepts `three` (`THREE_RE`) or digit `3` (`COUNT3_RE`,
  word-boundary) plus `_asserted`.
- **I5** accepts `rewritten in place` or `rewritten in-place`
  (`REWRITTEN_IN_PLACE_RE = rewritten\s+in(?:\s+|-)place`) plus `_asserted`.
- **I6** keeps the launch line, the ≥3 derived committer stamps and the
  Amendment-A1 denial-phrase exclusion; adds `derive_fleet_stamp(fleet)`
  reading `{fleet}/.ufo/reports/round-60/kagi.md` §Stale-lane
  `launch HH:MM:SS` (SetupError → exit 2 on missing/unreadable/stamp-less
  report), and requires the correction line's quoted-span `HH:MM:SS` set to
  equal exactly `{fleet_stamp}` (`quoted == {fleet_stamp}`). New `--fleet`
  arg (default `/home/vgpnk/Projects/shokunin`), forwarded through
  `evaluate`/`measure`/`run_guard` (challenge re-run) and item signatures.
- **I7** binds each derived pair to its subject:
  `_pair_bound_to_subject` requires `3/16 = 18.75 %` within `SUBJECT_WINDOW=8`
  tokens after `literal reading` and `4/16 = 25 %` within 8 tokens after
  `sentinel` (quoted spans masked as before).
- Output line shape, modes (`--root --repo --fleet --no-challenge
  --selftest --json`) and all prior selftest cases preserved; selftest now
  builds a fleet fixture (`mk_fleet`, stamp `15:09:28`) and adds 27 cases:
  f1–f10 forgery-unresolved, p1/p2/p3b/p4b/p5b/p6 benign-resolved,
  `i6-superseded-stamp-conjunct-isolated`, `i6-missing-fleet-report-is-setup`,
  and grammar units (`negator-round63-membership`,
  `denial-after-token-detected`, `post-token-not-route-not-denial`,
  `not-merely-idiom-rescues`, `contrastive-but-rescues`,
  `quoted-span-masked`, `window-negator-at-10-tokens`,
  `window-negator-at-31-tokens-ignored`, `fleet-stamp-derived`).

## R63MutC1 survivor feedback (received mid-run, addressed)

Their snapshot f0409a45 (76 cases) predates the fleet wiring; current bytes
read 102 cases. All seven named survivors now have isolating cases (see §3
case names); the "post-token quotation mask" mutant target was removed by
construction — the mask is applied once in `_asserted`/`_negated_before` and
`_denied_after` consumes pre-masked text, so dropping a mask inside
`_denied_after` is not a reachable mutation.

SEAT-STATUS: complete
