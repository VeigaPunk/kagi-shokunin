# R64ScoutPreState — independent pre-state census at BASE `09cbee831d57be7c4edfbe77bf238f46bf729047`

Seat: `R64ScoutPreState` (scout, leaf member). Lane: `kagi-shokunin`.
Claim BASE: `09cbee831d57be7c4edfbe77bf238f46bf729047`.
Frozen predeclaration: `plans/round-64.md` @ `dff0929c0e084822b0fe32e0d164534c768f97fe` (incl. Amendment A1).
Scratch root: `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ScoutPreState/` (deleted at yield).
Read-only: no lane file was edited; no mutating git/jj command was run anywhere; the lane working tree
was only read (`git archive`, `git show`, `git ls-tree`, `git status --porcelain`).

Every number below is **derived by a command run in this seat's scratch**, not quoted from the plan.
The plan is cited only for the frozen predicate wording.

---

## 0. Tooling

No tool was installed or upgraded by this seat. `git 2.56.0`, `python3 3.14.8`, `bash` (system),
`coreutils` — all pre-existing. `/home/vgpnk/.omp/agent/RULES.md` was read; no pacman/uv/npm
transaction was needed, so the operator's tooling directive has nothing to record.

---

## 1. BASE tree extraction and the sealed fixture file

```
$ S="${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r64/R64ScoutPreState"; mkdir -p "$S/base" && \
  git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 09cbee831d57be7c4edfbe77bf238f46bf729049 | tar -x -C "$S/base"
EXTRACT OK
```

Extracted tree size: `209M` (`du -sh`). Top level: `AGENTS.md LOG.md PROVINCE.md README.md SCORECARD.md
SHONEN.md SKILL.md considerthese corpus plans`.

### 1.1 BASE checker (the measured instrument)

```
$ cd "$S/base"; sha256sum plans/round-61-c1-check.py; wc -l plans/round-61-c1-check.py; wc -c plans/round-61-c1-check.py
eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6  plans/round-61-c1-check.py
2031 plans/round-61-c1-check.py
98257 plans/round-61-c1-check.py
```

**BASE checker: sha256 `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6`, 2031 lines,
98257 bytes.** (Cross-checked from the lane: `git show 09cbee8:plans/round-61-c1-check.py | sha256sum`
⇒ the same `eb08094c…`.)

### 1.2 The sealed held-out TSV — **absent at BASE**

```
$ cd "$S/base"; sha256sum plans/round-64-heldout.tsv; wc -l plans/round-64-heldout.tsv; wc -c plans/round-64-heldout.tsv
sha256sum: plans/round-64-heldout.tsv: No such file or directory (os error 2)
wc: plans/round-64-heldout.tsv: No such file or directory (os error 2)
wc: plans/round-64-heldout.tsv: No such file or directory (os error 2)

$ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin ls-tree --name-only 09cbee831d57be7c4edfbe77bf238f46bf729047 plans/ | grep round-64
(no output)

$ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin cat-file -e 09cbee8:plans/round-64.md
fatal: path 'plans/round-64.md' exists on disk, but not in '09cbee831d57be7c4edfbe77bf238f46bf729047'
```

**The sealed file does not exist at BASE.** It is introduced by the frozen-plan commit `dff0929`,
which is a *descendant* of BASE (`git merge-base --is-ancestor 09cbee8 dff0929` ⇒ rc 0). Measured at
the two commits where it does exist (identical bytes at both):

```
$ git -C <lane> show dff0929:plans/round-64-heldout.tsv | sha256sum; git -C <lane> show dff0929:plans/round-64-heldout.tsv | wc -l -c
b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2  -
    21    3584

$ sha256sum <lane>/plans/round-64-heldout.tsv; wc -l -c <lane>/plans/round-64-heldout.tsv
b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2  plans/round-64-heldout.tsv
    21    3584 plans/round-64-heldout.tsv
```

**Sealed TSV: sha256 `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2`, 3584 bytes,
21 lines = 1 header + 20 data rows.** This matches the seal declared in plan §C1 / Amendment A1
(`b0f51e2a…`). The lane's working-tree copy and the `dff0929` blob are byte-identical.

> **Defect D-R64-1 (wave-prompt premise, not a frozen-predicate defect).** The wave prompt's step 1
> asks for the sealed TSV's size and digest **"at 09cbee8…"**. At that revision the file does not
> exist (see above). The seal is a property of the frozen-plan commit `dff0929` and of the lane tip,
> not of BASE. Nothing in the frozen predicate is affected (the predicate names the *held-out
> fixtures*, not a BASE revision), so no amendment is proposed; the L1 should cite the seal as
> `dff0929`/lane-tip rather than as a BASE revision.

### 1.3 Disclosure — this seat read the sealed file

This seat **read** `plans/round-64-heldout.tsv` (the 20 fixture rows) in order to *apply* the eight
fixtures for the census, which the seat's own step 3/4 explicitly requires ("apply the five H
fixtures … apply the three Q fixtures the same way"). It did **not** read it for the checker's
benefit: no checker code was written or suggested by this seat, the checker hardening seat
(`R64ExecC1Grammar`) received nothing from this seat, and the seat's own output is a measurement
record, not a construction input. The seat is not the C1 checker hardening seat, so the
"must not read" prohibition (which binds `R64ExecC1Grammar`) does not bind this seat. The fixture
**strings** are deliberately not reproduced in this receipt beyond the derived readings (the anchor
uniqueness counts are recorded; the anchor/replacement text is not, to keep the sealed content out
of a citable artifact).

---

## 2. Slim tree — unmodified copy reads `value=0` (rc 1)

Slim tree = the seven named input files, copied from the extracted BASE tree:

```
$ find "$S/slim" -type f | sort
$S/slim/.ufo/waves/round-60/w1-results.json
$S/slim/LOG.md
$S/slim/SKILL.md
$S/slim/corpus/lessons/round-60.md
$S/slim/plans/round-60-c2.sh
$S/slim/plans/round-60.md
$S/slim/plans/round-61-c1-check.py
$ du -sh "$S/slim"
556K	$S/slim
```

Run (the frozen invocation, `--fleet` present, `--no-challenge`):

```
$ cd "$S/slim" && HYAKU_SCRATCH=... TMPDIR=... python3 -I -B plans/round-61-c1-check.py \
    --root "$S/slim" --repo /home/vgpnk/Projects/shokunin/kagi-shokunin \
    --fleet /home/vgpnk/Projects/shokunin --no-challenge
c1: i1 HOLD derived results=16 output=3824 supersedes-lines-after=1 last-line=states-derived-count-and-names-mutants.md
c1: i2 HOLD selftest[rc=0 cases=36 PASS-line] registry[selftest-cell='`bash plans/round-60-c2.sh --selftest` ⇒' none-own=absent] mutation[mutated rc=1 finding=yes]
c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance
c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three
c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place polarity=asserted
c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 quoted-stamp=15:09:28 fleet-stamp=15:09:28 denial=none
c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-pairs-bound-to-subjects
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
RC=1
```

**Unmodified slim copy: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`,
rc 1.** Re-run twice ⇒ identical line (no flakiness observed).

### 2.1 Slim tree ≡ full tree (equivalence check)

```
$ cd "$S/base" && python3 -I -B plans/round-61-c1-check.py --root "$S/base" --repo <lane> --fleet /home/vgpnk/Projects/shokunin --no-challenge
c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-pairs-bound-to-subjects
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
RC=1
```

The full 209 MB BASE tree and the 556 K slim tree read the **identical** `C1_ROUTED:` line. The slim
tree is a faithful surrogate for the unmodified reading.

### 2.2 Reading independence from the lane working tree

The lane working tree is dirty (a sibling seat is editing `plans/round-61-c1-check.py` in place), so
the reading was re-derived against a pristine BASE clone instead of the live lane:

```
$ git clone --shared --no-checkout <lane> "$S/baserepo" && git -C "$S/baserepo" checkout -f 09cbee831d57be7c4edfbe77bf238f46bf729047
HEAD is now at 09cbee8 round-63 verifier spot-check (integrator, hyaku): non-author admit/reject

# unmodified slim copy with --repo = baserepo@09cbee8:
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0   rc=1
# F2 with --repo = baserepo@09cbee8:
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0   rc=1
# P6 with --repo = baserepo@09cbee8:
C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0   rc=1
```

The `--repo` derivation source does not change any reading: the same lines come out with `--repo` =
the dirty live lane and with `--repo` = a pristine BASE clone. (`derive_numstat` /
`derive_ci_set` read only the pinned revisions `14a6c07d`/`818d2a82`/`a677c78e`, which are identical
in both.)

---

## 3. The five H fixtures (F2, F6, F8, F10, B4) — each accepted at BASE (`value=0`, rc 1)

Method: for each fixture, a **fresh slim copy** is built from the extracted BASE tree, the fixture's
anchor is asserted to occur **exactly once** in the named file, the replacement is applied once, and
the checker is invoked with the frozen command line. Driver: `$S/drive.py` (in scratch).

Anchor uniqueness across all 20 sealed rows (asserted before any application):

```
$ python3 - <<'PY'   # count the anchor in the BASE tree file named by each sealed row
F1   file=corpus/lessons/round-60.md  anchor-count=1
F2   file=corpus/lessons/round-60.md  anchor-count=1
F3   file=corpus/lessons/round-60.md  anchor-count=1
F4   file=corpus/lessons/round-60.md  anchor-count=1
F5   file=corpus/lessons/round-60.md  anchor-count=1
F6   file=LOG.md                      anchor-count=1
F7   file=LOG.md                      anchor-count=1
F8   file=corpus/lessons/round-60.md  anchor-count=1
F9   file=corpus/lessons/round-60.md  anchor-count=1
F10  file=corpus/lessons/round-60.md  anchor-count=1
P1   file=corpus/lessons/round-60.md  anchor-count=1
P2   file=corpus/lessons/round-60.md  anchor-count=1
P3   file=LOG.md                      anchor-count=1
P4   file=LOG.md                      anchor-count=1
P5   file=corpus/lessons/round-60.md  anchor-count=1
P6   file=corpus/lessons/round-60.md  anchor-count=1
B3   file=corpus/lessons/round-60.md  anchor-count=1
B4   file=corpus/lessons/round-60.md  anchor-count=1
B5   file=corpus/lessons/round-60.md  anchor-count=1
P7   file=corpus/lessons/round-60.md  anchor-count=1
```

**Every sealed row's anchor occurs exactly once at BASE** — no fixture is vacuous at BASE.

### 3.1 The five H readings

```
FIXTURE F2  file=corpus/lessons/round-60.md  anchor-count=1  sha-after=361a7d1e3e630a14025cc5a1e186d8d9f5659bc81ec8951a40420bc4e5c6f032
FIXTURE F2  rc=1
FIXTURE F2  C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
FIXTURE F6  file=LOG.md                      anchor-count=1  sha-after=ef6d9e57ef7eef65e1615aa9903105549c6c77a1e7ea59ced040bca912c87dd9
FIXTURE F6  rc=1
FIXTURE F6  C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
FIXTURE F8  file=corpus/lessons/round-60.md  anchor-count=1  sha-after=2b8c608a6bf9ebaad2c27f6c3265f867fc6f55ca0e15abc496873c63db3f6829
FIXTURE F8  rc=1
FIXTURE F8  C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
FIXTURE F10 file=corpus/lessons/round-60.md  anchor-count=1  sha-after=47965982b5108062f27bd0a0ab872b54c0f8391c3035751e040a7d7946e7f3f5
FIXTURE F10 rc=1
FIXTURE F10 C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
FIXTURE B4  file=corpus/lessons/round-60.md  anchor-count=1  sha-after=3df8807e656b97bdcdf475cc9d50e35a55343f39ce85c6c094c012f2ad560723
FIXTURE B4  rc=1
FIXTURE B4  C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
```

**All five held-out forgeries are ACCEPTED by the BASE checker (`value=0`), rc 1.**

---

## 4. The three Q fixtures (P6, B5, P7) — each rejected at BASE (`value>=1`, rc 1)

```
FIXTURE P6 file=corpus/lessons/round-60.md  anchor-count=1  sha-after=780a240c00e82a1629ff25afe8c948aa5961b0b0300db01859b6c6ea0e97c13e
FIXTURE P6 rc=1
FIXTURE P6 C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0
FIXTURE B5 file=corpus/lessons/round-60.md  anchor-count=1  sha-after=7ccc1f73c5796aefd6080dc404f732eb9554641c0e468b56c27cffcdd332a5dc
FIXTURE B5 rc=1
FIXTURE B5 C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0
FIXTURE P7 file=corpus/lessons/round-60.md  anchor-count=1  sha-after=777b3e76848810770cfcd34eb9f6b182652bc370975d0c9a10847e4ca9d98e21
FIXTURE P7 rc=1
FIXTURE P7 C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0
```

**All three held-out benign rewrites are REJECTED by the BASE checker (`value=1`), rc 1.**
Item bits: P6 fails on **i7** (binding window), B5 fails on **i4** (idiom class), P7 fails on **i7**
(binding window / parenthetical).

### 4.1 The BASE `heldout` count, re-derived

The frozen predicate counts `heldout` = (number of H fixtures on which the checker prints `value=0`)
+ (number of Q fixtures on which it prints `value>=1`). From §3 and §4:

| | H (F2,F6,F8,F10,B4) | Q (P6,B5,P7) |
|---|---|---|
| BASE reading | value=0 ×5 (all accepted) | value=1 ×3 (all rejected) |

⇒ **heldout = 5 + 3 = 8, population = 8, POP = 8.** This is the BASE reading the round's C1 target
is measured against (`heldout=8 → 0`). It is reproduced here by measurement, not copied from the plan.

### 4.2 Control row re-measured for context (P4)

```
FIXTURE P4 file=LOG.md  anchor-count=1  sha-after=05ef26953099beabe5e7866f1d786dc734c265b2f6d70276d587762de9329b6
FIXTURE P4 rc=1
FIXTURE P4 C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
```

P4 reads `value=0` on the slim tree **and** on the full 209 MB BASE tree (both measured) — i.e. P4
reads `value=0` here, whereas `census-a1.md` records P4 as `value=1` with `i2=0` and labels it a
"slim-tree artifact". See **D-R64-2** below. P4 is a control, outside H/Q, so the held-out
population (5 H + 3 Q) is unaffected either way.

### 4.3 P4 — five independent measurements

| # | tree | `--repo` | reading | rc |
|---|---|---|---|---|
| 1 | slim | live lane | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` | 1 |
| 2 | slim (re-run) | live lane | same line | 1 |
| 3 | slim | live lane (again, separate driver invocation) | same line | 1 |
| 4 | full 209 MB BASE tree | live lane | same line | 1 |
| 5 | slim | pristine `baserepo@09cbee8` | same line | 1 |

All five agree: **P4 → `value=0`, `i2=1`**, with the i2 detail line
`i2 HOLD selftest[rc=0 cases=36 PASS-line] registry[selftest-cell='`bash plans/round-60-c2.sh --selftest` ⇒' none-own=absent] mutation[mutated rc=1 finding=yes]`.

### 4.4 Load probe on the i2 leg (mechanism for a transient `i2=0`)

The i2 leg's timing-sensitive part is `_c2_selftest_run` → `bash plans/round-60-c2.sh --selftest`
under a **90 s** timeout (`plans/round-61-c1-check.py:178` `SELFTEST_TIMEOUT = 90`, `:655-671`).
Measured wall time of that selftest on this host:

| conditions | wall |
|---|---|
| idle | 8.68 s / 10.18 s |
| 8 busy loops | 13.91 s |
| 64 busy loops on 32 cores (`nproc` = 32) | 36.14 s |

Under that heavy load the checker's own i2 leg still read `i2=1` and the tree still read
`value=0` — so the timeout was **not** reproduced here. The measurement does establish that the
i2 leg's wall time scales steeply with machine load (8.7 s → 36.1 s, a 4× increase) and that only
≈2.5× headroom remains against the frozen 90 s timeout; a transient `i2=0` on a busier host is
therefore a plausible mechanism for the census row, but this seat **did not reproduce it** and does
not assert it. The reproducible fact is the opposite of the census row: P4 reads `value=0` in both
tree shapes and under both `--repo` choices, five times out of five.

---

## 5. The checker's `--selftest` case count and the A4 vehicle's construction requirement

### 5.1 `--selftest` case count at BASE

```
$ cd "$S/base" && python3 -I -B plans/round-61-c1-check.py --selftest
C1_CHECK_SELFTEST: PASS (cases=102)
RC=0
```

**BASE checker selftest: `C1_CHECK_SELFTEST: PASS (cases=102)`, rc 0.** Plan §C1 guard leg (b) floor
is `N >= 91`; the BASE instrument is at 102.

### 5.2 The A4 lookup-table vehicle — construction requirement (plan §C1 guard leg (e))

The frozen guard (e) text, verbatim from `plans/round-64.md` (lines 50-54):

> "(e) the A4 lookup-table vehicle (a checker carrying a literal `NEGATORS = frozenset(())` dead
> line plus a 15-string fixture lookup and a constant `PASS (cases=91)`) is refused on the held-out
> set — it must NOT reach `heldout=0` on the candidate."

So the vehicle that guard (e) must refuse has **three** construction requirements, all fixed by the
frozen text:

1. a literal `NEGATORS = frozenset(())` **dead line** (one assignment, so the round-63 challenge
   needle can be applied to it);
2. a **15-string fixture lookup**;
3. a **constant `PASS (cases=91)`** selftest.

The 15 strings are the ten `F` replacements of `plans/round-63-residual.tsv` plus the five `B`
replacements of `plans/round-62-bypass.tsv` — the same construction the round-63 routed leg `d1`
names (`table_strings = [v[2] for v in residual.values()] + [v[2] for v in bypass.values()]`).
Measured: `10 + 5 = 15` rows, and the two source TSVs are the only committed fixture tables.

### 5.3 The vehicle, built and measured by this seat

Built in scratch exactly as the frozen text describes (dead `NEGATORS` line, 15-string table from
the committed tables, constant `PASS (cases=91)`, `value=1` on a table hit else `value=0`), and run
over the committed and the held-out sets:

```
VEHICLE table size: 15
VEHICLE unmodified-copy table hits (must be empty for guard a): []
VEHICLE unmodified: C1_ROUTED: value=0 population=7 ... guard=0        (rc 1)
VEHICLE selftest rc=0 out='C1_CHECK_SELFTEST: PASS (cases=91)'
VEHICLE r63 F1..F10 -> value=1 (10/10 rejected)
VEHICLE r63 accepted(forgery value=0)=0
VEHICLE benign P1..P6 -> value=0 (6/6 accepted)
VEHICLE r63 rejected(benign value>=1)=0
VEHICLE held H F2 -> value=0 ; F6 -> value=0 ; F8 -> value=0 ; F10 -> value=0 ; B4 -> value=0
VEHICLE held Q P6 -> value=0 ; B5 -> value=0 ; P7 -> value=0
VEHICLE heldout_vehicle = h_count(5)+q_count(0) = 5   (guard (e) needs >=1: PASS)
```

So the vehicle **is** a vehicle in the round-63 sense (accepted=0 / rejected=0 on the committed
tables, `value=0` on the unmodified copy, constant `PASS (cases=91)`), and on the held-out set it
reads **heldout = 5 ≠ 0** ⇒ guard (e) has a live target.

### 5.4 The negative vector — the guard leg is falsifiable, not vacuous

Same vehicle with the five held-out **H** replacements added to the table (20 strings):

```
VEHICLE answers=1 table size: 20
VEHICLE answers=1 held H F2 -> value=1 ; F6 -> value=1 ; F8 -> value=1 ; F10 -> value=1 ; B4 -> value=1
VEHICLE answers=1 held Q P6 -> value=0 ; B5 -> value=0 ; P7 -> value=0
VEHICLE answers=1 heldout = h(0)+q(0) = 0     (the negative vector: reaches heldout=0)
```

**The guard leg (e) can fail**: a lookup table that carries an entry for each held-out forgery
reaches `heldout=0`. The frozen plan already names this as its ceiling ("a lookup table carrying a
*new* entry for each held-out fixture would also reach `heldout=0`"); this measurement confirms the
leg discriminates the 15-string vehicle from a hardened grammar checker, and simultaneously confirms
the named ceiling.

### 5.5 The challenge needle on the BASE checker (K5's "must fail on a mutated copy")

```
$ python3 - ... # rewrite the single `NEGATORS = frozenset` assignment to `frozenset(())`
NEGATORS assignment starts: 1 at lines [236]
assignment spans lines 236 - 238
emptied
$ python3 -I -B plans/round-61-c1-check.py --selftest
C1_CHECK_SELFTEST: FAIL (cases=102 failed=14 names=b3-negated-withdrawn-unresolved,b4-no-three-unresolved,b5-not-rewritten-unresolved,f1-forgery-unresolved,f3-forgery-unresolved,f5-forgery-unresolved,f6-forgery-unresolved,f7-forgery-unresolved,negator-round63-membership,negator-set-membership,window-negator-detected,window-no-three-negated,mid-window-not-only-still-negator,window-negator-at-10-tokens)
rc=1
```

The BASE checker **does** fail on the emptied-negator copy (rc 1, 14 named failures), so K5's
"must fail on a mutated copy" clause is satisfied at BASE. The same mutation applied to the
**vehicle** leaves it printing `C1_CHECK_SELFTEST: PASS (cases=91)` with rc 0 and no `FAIL` line —
the vehicle cannot be killed that way, which is why guard (e) has to be the held-out-set leg.

### 5.6 K5's "one case per held-out shape class" at BASE

```
$ grep -niE "heldout|held-out|pair-assert|every-pair|subject-negat|parenthet|em-dash|no-new|single-mechan|not-less-than" plans/round-61-c1-check.py
(no matches)
```

The BASE checker's 102 selftest cases carry **no** case naming any round-64 held-out shape class.
K5's clause is therefore genuinely open at BASE (it is the hardening seat's deliverable), and the
`N >= 91` floor in guard (b) is not the binding constraint — the K5 per-class clause is.

---

## 6. C2 — the round-63 counter does not terminate (rc 124, no verdict line)

### 6.1 BASE tree, 240 s budget

```
$ cd "$S/base" && HYAKU_SCRATCH=$S/scratchroot TMPDIR=$S/scratchroot \
    timeout 240 bash plans/round-63-c2.sh --tree "$S/base" > out 2> err
RC=124
$ wc -c out err
0 out
0 err
```

**`timeout 240 bash plans/round-63-c2.sh --tree <BASE tree>` ⇒ rc 124, stdout 0 bytes, stderr 0
bytes — no `C2_REFUSAL:` verdict line at all.** (The run consumed the full 240 s; wall time 241.2 s.)

### 6.2 Lane tip tree (the tree the wave works on), 240 s budget

```
$ git archive eb647d23132cf7ffc3b3cd08f2083b8e39e5391e | tar -x -C "$S/master"
$ cd "$S/master" && HYAKU_SCRATCH=$S/scratchroot2 TMPDIR=$S/scratchroot2 \
    timeout 240 bash plans/round-63-c2.sh --tree "$S/master" > out 2>&1
RC=124
$ wc -c out
0 out
```

Same reading on the current lane tip: **rc 124, no verdict line** (wall time 242.3 s). The
round-63 counter is byte-identical at BASE and at the lane tip:

```
6842eb759e4605d4ee4ba49c1994aa777c6d33e330652d3d2463515df97b5d0e  $S/master/plans/round-63-c2.sh
6842eb759e4605d4ee4ba49c1994aa777c6d33e330652d3d2463515df97b5d0e  $S/base/plans/round-63-c2.sh
```

### 6.3 Where the non-termination comes from (source-traced)

```
$ grep -c "C2_RECURSION_BOUND" plans/round-63-c2.sh
0
$ grep -n "round-63-controls.sh" plans/round-63-c2.sh
12:#   l3  the tree's plans/round-63-controls.sh control `C2-F6` must read `mismatch`
197:if [ -f "$TREE/plans/round-63-controls.sh" ]; then
198:  bash "$TREE/plans/round-63-controls.sh" "$TREE" >"$WORK/battery.out" 2>&1
$ grep -n 'timeout 2400 bash "\$C2_INSTR"' plans/round-63-controls.sh
460:    timeout 2400 bash "$C2_INSTR" --tree "$CAND" > "$SCR/c2-unmut.out" 2> "$SCR/c2-unmut.err"
```

Two edges form the cycle: `round-63-c2.sh:198` runs the battery `plans/round-63-controls.sh`, and
`round-63-controls.sh:460` runs `plans/round-63-c2.sh` again on the candidate tree. The BASE counter
carries **no** recursion-bound variable (`grep -c` ⇒ 0), so each nesting level re-enters the pair.
Process snapshot during a run (two live shells of the same pair at once, one of them the *battery's*
child counter):

```
$ ps -eo pid,ppid,etimes,args | grep -E "round-6[23]-(c2|controls)\.sh"
2510155 1589058     129 bash plans/round-63-c2.sh --tree …/master
2912503    1487      38 timeout 600 bash plans/round-63-controls.sh …/prior-snap
2912524 2912503      38 bash plans/round-63-controls.sh …/prior-snap
```

### 6.4 The committed round-63 receipt

```
$ wc -c /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-63/final/c2-refusal.txt
7 /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-63/final/c2-refusal.txt
$ od -c …/c2-refusal.txt
0000000   r   c   =   1   2   4  \n
0000007
```

**Round-63 C2 receipt: 7 bytes, content `rc=124\n`.** (The lane's round-64 base receipt
`.ufo/waves/round-64/base/c2-e2e-head.txt` is likewise 7 bytes `rc=124\n`.)

### 6.5 Supplementary: the round-63 C2 counter's own selftest at BASE

```
$ cd "$S/base" && bash plans/round-63-c2.sh --selftest
C2R63_SELFTEST: PASS (cases=13)
RC=0
```

The instrument's own selftest is healthy; only its end-to-end invocation fails to terminate.

### 6.6 Supplementary: the round-63 C1 counter's own selftest at BASE

Run in the extracted (non-git) BASE tree the counter's `--selftest` reads
`C1_RESIDUAL_SELFTEST: FAIL (26/28 checks) failed=value-parse-unmodified,stub-leg-negative-vector`.
That failure is an artefact of the extracted tree, not of BASE: `run_checker`
(`plans/round-63-c1.sh:192-201`) passes `--repo "$LANE"`, and `LANE` is derived from the counter's
own location (`plans/round-63-c1.sh:67`), so in a `git archive` extraction `--repo` points at a
directory with no `.git` and the checker's I5/I6 derivations fail. The same `--selftest` run against
A real BASE clone (`$S/baserepo`, `HEAD = 09cbee8`) is the git-backed control; its result is
recorded in §6.7 below. **No conclusion about the round-63 C1 counter is drawn here** — this seat's
scope is the C1 *checker* and the C2 *counter*.

### 6.7 The git-backed control for §6.6

Same counter, same BASE bytes, but with a real git-backed lane (`--repo` resolves):

```
$ cd "$S/baserepo" && HYAKU_SCRATCH=$S/scratchroot TMPDIR=$S/scratchroot \
    timeout 1200 bash plans/round-63-c1.sh --selftest
c1-residual: selftest tree=revision 0c07aab8df64b673a54a5113aebd7f34b622adbc (git archive) scratch=…
C1_RESIDUAL_SELFTEST: PASS (28/28 checks)
RC=0
```

**PASS (28/28)** in the git-backed clone against **FAIL (26/28)** in the `git archive` extraction.
The §6.6 failure is therefore an artefact of running the counter from a non-git extracted tree
(`--repo "$LANE"` with no `.git`), **not** a defect of the round-63 counter at BASE. Recorded so the
L1 does not mistake the extracted-tree reading for a counter defect.

---

## 7. Summary table — everything the acceptance list asks for

| item | measured value |
|---|---|
| BASE checker sha256 | `eb08094c627c736ec8a868213d4f8605dea971de73e27d801dcc1b3565ff7db6` |
| BASE checker lines / bytes | `2031` lines / `98257` bytes |
| Sealed held-out TSV sha256 | `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2` |
| Sealed held-out TSV bytes / lines | `3584` bytes / `21` lines (1 header + 20 rows) — **absent at BASE**, present at `dff0929` and lane tip |
| Unmodified slim copy | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`, rc 1 |
| H F2 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`, rc 1 |
| H F6 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`, rc 1 |
| H F8 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`, rc 1 |
| H F10 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`, rc 1 |
| H B4 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`, rc 1 |
| Q P6 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0`, rc 1 |
| Q B5 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0`, rc 1 |
| Q P7 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0`, rc 1 |
| Derived BASE `heldout` / population | `heldout = 5 (H accepted) + 3 (Q rejected) = 8`, `population = 8` |
| Checker `--selftest` case count | `C1_CHECK_SELFTEST: PASS (cases=102)`, rc 0 |
| Emptied-negator copy of the BASE checker | `C1_CHECK_SELFTEST: FAIL (cases=102 failed=14 …)`, rc 1 |
| A4 vehicle (15 strings) on the held-out set | `heldout_vehicle = 5` ⇒ **not** 0 ⇒ refused (guard (e) live) |
| A4 vehicle + 5 held-out H replacements (20 strings) | `heldout = 0` ⇒ the guard leg **can** fail (negative vector) |
| C2 `timeout 240 bash plans/round-63-c2.sh --tree <BASE tree>` | **rc 124**, stdout 0 B, stderr 0 B, **no `C2_REFUSAL:` line** |
| C2 same on the lane-tip tree | **rc 124**, 0 B, no verdict line |
| Round-63 C2 receipt | `7` bytes, `rc=124\n` |
| Round-63 C2 counter's own `--selftest` | `C2R63_SELFTEST: PASS (cases=13)`, rc 0 |

---

## 8. Defects found (reported, not amended)

**D-R64-1 — the sealed TSV is not a BASE artifact (wave-prompt premise).**
The wave prompt's step 1 asks for the sealed file's size/digest "at `09cbee8…`". At BASE the file
does not exist (`git ls-tree` / `git cat-file` confirm); it enters with the frozen plan at `dff0929`,
which is a descendant of BASE. Measured digest and byte count at `dff0929` and at the lane tip are
identical (`b0f51e2a…`, 3584 B, 21 lines) and match the declared seal. The frozen predicate is
unaffected (it names the fixtures, not a revision). Proposed handling: cite the seal as
`dff0929`/lane-tip, not as BASE. **No frozen item is amended by this seat.**

**D-R64-2 — `census-a1.md`'s P4 row does not reproduce.**
`.ufo/waves/round-64/base/census-a1.md` records P4 as `value=1` with `i2=0` and calls it a
"slim-tree artifact (the same edit on the full tree leaves i2 untouched)". Measured here: P4 reads
`value=0` with `i2=1` on the **slim** tree (three independent runs), on the **full** 209 MB BASE
tree, and with `--repo` pointing at a pristine `09cbee8` clone — five measurements out of five, all
`value=0` (§4.3). The i2 detail line on the P4 tree reads
`i2 HOLD selftest[rc=0 cases=36 PASS-line] registry[…] mutation[mutated rc=1 finding=yes]` — i2 holds
in both tree shapes. P4 is a control outside H/Q, so the frozen population (5 H + 3 Q) and the
target `heldout=0` are unaffected; but the census file's P4 row (and the "slim-tree artifact"
reasoning that excluded P4) is not reproducible with the slim tree the wave context names.
Load-sensitivity of the i2 leg was probed (§4.4): its wall time rises 8.7 s → 36.1 s under load
against a frozen 90 s timeout, so a transient timeout-induced `i2=0` is a plausible mechanism — but
it was **not reproduced here** (under 64 busy loops the leg still read `i2=1`), so this seat asserts
only the reproducible fact: P4 reads `value=0`. **Not amended by this seat.**

**D-R64-3 — "Six fixes" vs seven enumerated shape classes (plan §C1 Amendment A1 wording).**
Plan §C1 Amendment A1 says "Six fixes are the reachable set" and then enumerates **seven** distinct
mechanisms: F2 (I7 pair assertion), F6 (I5 single-occurrence), F8 (I4 `NO_NEW`), F10 (I7
every-pair-bound), B4 (subject-negatedness), P6/P7 (binding-window masking — one class, two
fixtures), B5 (idiom class `not less than`). The wave context repeats "the six shape classes", and
the dispatch's C1-seat prompt is headed "The six reachable fixes" while numbering **seven** items
(1..7) and setting the case floor at `N >= 109` = 102 + **7**. The enumeration and the arithmetic
floor are mutually consistent at **seven**; the word "six" is not. K5 requires "one case per
held-out shape class", so a checker hardening seat that takes "six" literally and adds six cases
lands at `cases=108` and misses the counter's `N >= 109` floor. The frozen predicate, target, POP,
kill rules, fixtures and item conditions are all untouched by this observation — this is a count in
the plan's prose and in the seat prompt, reported for the L1 to reconcile, **not amended here**.

**D-R64-4 — `census-a1.md` mixes two revisions in one sentence (evidence attribution).**
`census-a1.md` reads "Checker `plans/round-61-c1-check.py` (2031 lines, sha `f2afd9b8…` at
0c07aab8)". Measured: at `0c07aab8` the checker is `f2afd9b8…` / **1710 lines**; at `09cbee8` it is
`eb08094c…` / **2031 lines**. The line count belongs to the round-64 BASE and the digest to the
round-63 BASE. Cosmetic, but a citation defect; the correct BASE digest is `eb08094c…` (§1.1).

---

## 9. What this seat did NOT do

- Did not read, write, or suggest any change to `plans/round-61-c1-check.py` (the C1 checker
  hardening seat's file, in flight in the lane working tree).
- Did not write, commit, push, stash, or otherwise mutate any git/jj state in the fleet repo, the
  lane, a sibling lane, or any index. Only `git archive`, `git clone --shared --no-checkout`,
  `git checkout -f` **inside this seat's own scratch clone**, `git show`, `git ls-tree`,
  `git cat-file`, `git merge-base --is-ancestor`, `git status --porcelain` were used.
- Did not amend any frozen predicate, target, POP, kill rule, fixture or item condition.
- Did not run the wave's candidate counters (`plans/round-64-c1.sh`, `plans/round-64-c2.sh`,
  `plans/round-64-controls.sh`, `plans/round-64-routed.sh` are sibling seats' in-flight files); the
  C2 measurement in §6 uses the frozen round-63 counter named by the seat's step 6.
- Did not write citable evidence under `/tmp`.

Scratch (`$S`, ≈25 GB of tree copies) is deleted at yield.

SEAT-STATUS: complete
