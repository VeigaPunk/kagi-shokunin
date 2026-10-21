# MutClosurePointer — D1 pointer falsification (round 23)

Seat: mutation tester, falsification wave. Axes: calibration / freshness / operability.
Target: C1 calibration gate `corpus/closure-dispositions.py` + `corpus/closure-dispositions.json`
(`fixed` pointer resolution; claimed selftest 13). Assignment: mutate D1's pointer on an
isolated `/tmp` copy to (A) an existing file that never names D1 and (B) a heading that does
not exist; report whether either is silently accepted.

Everything below ran host-free against a scratch copy. No network, no installs/updates, no
production edit, no host gate. The only file written under the lane is this report.

## Scratch setup and pristine baseline

```
SCRATCH=$(mktemp -d /tmp/kagi-r23-mutclosure.XXXXXX)   # -> /tmp/kagi-r23-mutclosure.bqsPsb
rsync -a --exclude .git --exclude .jj --exclude .ufo /home/vgpnk/Projects/shokunin/kagi-shokunin/ "$SCRATCH"/
cp "$SCRATCH/corpus/closure-dispositions.json" /tmp/kagi-r23-mutclosure.bqsPsb.pristine.json
python3 corpus/closure-dispositions.py                                  # in production tree
python3 "$SCRATCH/corpus/closure-dispositions.py" --root "$SCRATCH"    # pristine scratch
```

Both exited 0 with the identical line:

```
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
```

Pristine digests (production == scratch):

```
f20f00d1be8d50984953eb21c377a333912e9c1ca346e4637850586f04cc0d59  corpus/closure-dispositions.json
65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7  corpus/lessons/round-22-verifier-spotcheck.md
d55209887c13825cdf4b0a423aed080830d0ffaaefbb980ce01d49cb9642c773  corpus/lessons/round-23.md
06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29  corpus/SOURCES.md
```

Baseline P1 of D1: `corpus/lessons/round-23.md:64` is `## Routed defect dispositions`;
D1 is named at `corpus/lessons/round-23.md:15,66,169`. The pre-mutation pointer is
`corpus/lessons/round-23.md#Routed defect dispositions` (`corpus/closure-dispositions.json:49-53`).

## Mutant A — pointer to an existing file that never names D1

Edit (scratch only): D1 `pointer` -> `corpus/SOURCES.md` (file exists; its sha256 is
`06dde644…` above; it contains zero matches for the gate's own token regex
`(^|[^A-Za-z0-9_])D1([^0-9]|$)`, verified by `grep -cE` -> `0`).

Mutated JSON sha256: `d104efd6de1df753bcdcd9300984dc59f2fe14af83d98e23afb5ca94f35ea300`.

```
python3 "$SCRATCH/corpus/closure-dispositions.py" --root "$SCRATCH"
DISPOSITION POINTER-ID D1 corpus/SOURCES.md
CLOSURE_DISPOSITIONS: FAILED (obligations=15 dispositions=15 missing=0 unknown=0 unresolved=1)
exit=1
```

**Verdict: KILLED.** Not silently accepted. The failure is produced by
`corpus/closure-dispositions.py:117-120` (token check gated on `kind == "fixed"`).

## Mutant B — pointer to a heading that does not exist

Edit (scratch only): D1 `pointer` -> `corpus/lessons/round-23.md#No Such Heading QZ`.
No line of that file starts with `#` and contains the anchor (checked directly; the only
`#` lines are 5, 20, 56, 64, 137, 149, 160).

Mutated JSON sha256: `a86ceb960c03f7e1234c9b542b3b7883d05d3dfea22fdd4902768adb5d0cce0f`.

```
python3 "$SCRATCH/corpus/closure-dispositions.py" --root "$SCRATCH"
DISPOSITION POINTER-ANCHOR D1 corpus/lessons/round-23.md#No Such Heading QZ
CLOSURE_DISPOSITIONS: FAILED (obligations=15 dispositions=15 missing=0 unknown=0 unresolved=1)
exit=1
```

**Verdict: KILLED.** Not silently accepted, via `corpus/closure-dispositions.py:112-116`.

## Supplementary probes — where the detector silently accepts (bound-setting)

Not part of the two assigned mutants; run because they decide what the claim may state.
Both ran on the same scratch tree with the same command and the same scratch `--root`.

### P1: a heading that does not exist *as a heading*, but is a substring of a real heading

D1 `pointer` -> `corpus/lessons/round-23.md#Routed defect` (no heading equals
`Routed defect`: `grep -nE '^#+ +Routed defect *$' corpus/lessons/round-23.md` printed
nothing, exit 1; the anchor is only a substring of line 64).

```
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
exit=0
```

**Silently accepted.** Mechanism: `corpus/closure-dispositions.py:113-114` is
`line.startswith("#") and anchor in line` — anchor matching is a substring test over *any*
line whose first character is `#`, with no heading-level, delimiter, equality, or
markdown-heading check. A fenced-code `# comment` line would satisfy it equally. The
script's docstring states "carry a heading containing the anchor", so this is inside the
documented semantics, but it is weaker than "the heading exists".

### P2: non-`fixed` pointer to an existing file that never names its obligation

D2 row (`corpus/closure-dispositions.json:55-61`; id `:56`, pointer `:60`; class `routed-defect`, disposition
`reported`) `pointer` -> `corpus/SOURCES.md` (zero `D2` tokens there).

```
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
exit=0
```

**Silently accepted by design.** `corpus/closure-dispositions.py:117` runs the ID token
check only when `kind == "fixed"`; `reported`/`rejected`/`no-action`/`operator-owned`
pointers need only exist (anchor included) and may be omitted. The claim's wording
("fixed pointers resolve") is accurate; the coverage limit must be stated.

## Restoration evidence

```
cp /tmp/kagi-r23-mutclosure.bqsPsb.pristine.json "$SCRATCH/corpus/closure-dispositions.json"
sha256sum  # both files
f20f00d1be8d50984953eb21c377a333912e9c1ca346e4637850586f04cc0d59  "$SCRATCH/corpus/closure-dispositions.json"
f20f00d1be8d50984953eb21c377a333912e9c1ca346e4637850586f04cc0d59  /tmp/kagi-r23-mutclosure.bqsPsb.pristine.json
python3 "$SCRATCH/corpus/closure-dispositions.py" --root "$SCRATCH"
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 ...)   exit=0
```

Detector selftest on the scratch tree (host-free):

```
python3 "$SCRATCH/corpus/closure-dispositions.py" --selftest
CLOSURE_DISPOSITIONS_SELFTEST: PASS (13 cases)     exit=0
```

It prints `case pointer-id: ok` and `case pointer-anchor: ok`
(`corpus/closure-dispositions.py:297-298,310-311`); the mutants above show the same two failure
codes also fire on the real production rows, not just the fixture. Production digests after
the probe are unchanged (`f20f00d1…` dispositions, `d5520988…` round-23 lesson). Scratch
copy and pristine backup under `/tmp/kagi-r23-mutclosure.bqsPsb*` were removed after this
report (created and deleted by this seat, no residue added).

## Finding

No defect against the C1 claim as written. Both assigned mutants are killed with exit 1 and
the expected codes (`POINTER-ID`, `POINTER-ANCHOR`); neither is silently accepted. One
boundary variant of mutant B is silently accepted: a *non-existent* heading text that is a
substring of a real heading passes. The claim must state these bounds:

1. Anchor resolution is a substring test over any line starting with `#`
   (`corpus/closure-dispositions.py:113-114`), not exact heading identity or level. A
   pointer anchor may name a heading fragment, and a `#` line inside a code fence would
   satisfy it; `#Routed defect` passes on a file whose only match is
   `## Routed defect dispositions` (`corpus/lessons/round-23.md:64`).
2. Obligation-ID naming is enforced only for `fixed` dispositions
   (`corpus/closure-dispositions.py:117-120`); non-`fixed` pointers resolve on path (and
   anchor, if given) existence alone, and are optional. A `reported` row can point at a
   file that never mentions its id and still yield `CLEAN`.
3. The ID check is a loose token search anywhere in the file
   (`corpus/closure-dispositions.py:118-119`), not proximity to the named section or the
   note's subject; a file that merely mentions `D1` somewhere satisfies it.
4. The gate proves a record path exists and (for `fixed`) mentions the id; it does not
   prove the disposition prose is honest or the fix correct — as its own docstring states
   (`corpus/closure-dispositions.py:41-44`).
5. The 13-case selftest exercises pointer failures only on a synthetic fixture
   (`corpus/closure-dispositions.py:262-313`); production-row behavior is separately
   measured above, not guaranteed by the selftest.
