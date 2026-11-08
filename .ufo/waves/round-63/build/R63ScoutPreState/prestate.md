# R63ScoutPreState — pre-state census of C1_RESIDUAL and C2_REFUSAL at BASE

Seat `R63ScoutPreState` (scout, pre-state census). Read-only: **no lane file was
edited**; every measurement ran on copies under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ScoutPreState/` (deleted after
the seat yielded).

- Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`
- Claim BASE: `0c07aab8df64b673a54a5113aebd7f34b622adbc`
- Frozen predeclaration read: `plans/round-63.md` (commit `12c9e4284d6de52ba61fcc656165cd24e8b74480`),
  plus `corpus/lessons/round-62-verifier-spotcheck.md` §2/§6 and `corpus/lessons/round-62.md`
- Every number below is **derived** by a command shown next to it. No number is quoted
  from the plan.

## 0. Tooling

No tool was installed or upgraded for this seat (nothing was needed beyond
`git archive`, `python3` and `bash`, all present). No `pacman`/`uv`/`cargo`/`npm`
transaction was run, so there is no tool/version/channel row to report.

## 1. The extracted BASE tree

```
$ mkdir -p /fast/scratch/hyaku/kagi-r63/R63ScoutPreState/base
$ git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 0c07aab8df64b673a54a5113aebd7f34b622adbc | tar -x -C /fast/scratch/hyaku/kagi-r63/R63ScoutPreState/base
```

The extraction is read-only against the lane (`git archive` writes nothing). The
extracted tree carries 10 883 files.

### 1.1 The BASE checker

```
$ cd /fast/scratch/hyaku/kagi-r63/R63ScoutPreState/base
$ sha256sum plans/round-61-c1-check.py
f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0  plans/round-61-c1-check.py
$ wc -l plans/round-61-c1-check.py
1710 plans/round-61-c1-check.py
```

### 1.2 The other BASE instruments (sha256, for reference)

```
$ sha256sum plans/round-62-c1.sh plans/round-62-c2.sh plans/round-62-controls.sh plans/round-61-c2.sh plans/round-60.md corpus/lessons/round-60.md LOG.md
efe676ebb0d016664705f17c181ecc3331963a4b09fb2f80403f8773170cf62f  plans/round-62-c1.sh
b26d42207ff51168811ebd1a32bd2969ee103497662d46f175ac2dd29d1ebe9c  plans/round-62-c2.sh
93587e6d15d5c0ebb94fac3a6039235070632c45dd5c3db86ae7fbcf1107ea97  plans/round-62-controls.sh
20614697f3720aa446501b3c3246748c762a025b99065a19556476d9ff3f4f29  plans/round-61-c2.sh
84bae42fd691431de762ebc4065ebd31404c1248558dc0098c019490185fa98e  plans/round-60.md
4fcaa1fbe8acdb36d5ff50dd7bedf576ff44dd6d6937c0657442fd87b2e5f382  corpus/lessons/round-60.md
4632615e4053cc1083c6f17642ad6c3aefcfcafddf0cfecdfd899f60e19342ca  LOG.md
```

### 1.3 The fixture anchors occur exactly once in the BASE tree

```
$ grep -cF -- '**A3 item 2 is withdrawn**' plans/round-60.md            → 1
$ grep -cF -- 'the round introduced three new record defects it did not route' corpus/lessons/round-60.md → 1
$ grep -cF -- 'it was rewritten in place at' LOG.md                    → 1
$ grep -cF -- 'so the literal reading is 3/16 = 18.75 %, and counting the sentinel as an attack seat gives 4/16 = 25 %' corpus/lessons/round-60.md → 1
$ grep -cF -- 'launch 15:09:28 −03' corpus/lessons/round-60.md        → 1
```

(The `−` in the last anchor is U+2212 MINUS SIGN; the lesson file carries it in
that codepoint, so the fixture anchor is byte-exact. The fleet report
`/home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md:194` carries the
ASCII hyphen instead: `Stale-lane: the round is `progressing`, not stale — launch 15:09:28 -03, lane commits at`
— verified with `grep -c 'launch' ` ⇒ 1 and `grep -c '15:09:28'` ⇒ 1 in that file,
so the I6 derivation has exactly one candidate launch stamp to read.)

### 1.4 No round-63 instrument exists at BASE

```
$ ls plans/round-63-*
ls: cannot access 'plans/round-63-*': No such file or directory
$ grep -rl 'C1_RESIDUAL' plans/ ; grep -rl 'C2_REFUSAL' plans/
(no output — neither verdict line has a producer at BASE)
```

Consequently the C2 legs below are measured on the BASE-era instruments
(`plans/round-62-c1.sh`, `plans/round-62-c2.sh`, `plans/round-61-c1-check.py`),
which is the closest measurable analogue of the round-63 counters.

## 2. How each fixture copy was built

Every fixture copy is a full `cp -a` of the extracted BASE tree, with exactly one
byte-exact single substitution applied by a Python helper that **counts the
anchor occurrences and fails closed on anything other than 1**:

```python
n = text.count(anchor)
if n != 1:
    raise SystemExit("ANCHOR-COUNT ... count=%d (must be exactly 1)" % n)
text.replace(anchor, repl, 1)
```

The per-fixture occurrence count is recorded with each fixture below; every one
reads **1**. The driver script is
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ScoutPreState/driver.py`
(scratch, deleted at the end of the seat).

The measurement command for every fixture copy is:

```
$ python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge
```

(run with cwd = the copy; `HYAKU_SCRATCH`/`TMPDIR` pointed inside this seat's
scratch root).

## 3. C1_RESIDUAL — the pre-state census

### 3.1 The ten forgery fixtures (F1..F10) — measured on the BASE checker

**F1 (FORGERY, reviewer id N2)** — file `plans/round-60.md`

- anchor → replacement: `**A3 item 2 is withdrawn**` → `**A3 item 2 is hardly withdrawn**`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: all seven items HOLD (i1..i7 = 1)

**F2 (FORGERY, reviewer id N3)** — file `plans/round-60.md`

- anchor → replacement: `**A3 item 2 is withdrawn**` → `**A3 item 2 is withdrawn — the record denies it**`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: all seven items HOLD (i1..i7 = 1)

**F3 (FORGERY, reviewer id N4)** — file `plans/round-60.md`

- anchor → replacement: `**A3 item 2 is withdrawn**` → `**A3 item 2 is not, as the earlier draft asserted, withdrawn**`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: all seven items HOLD (i1..i7 = 1)

**F4 (FORGERY, reviewer id N6)** — file `corpus/lessons/round-60.md`

- anchor → replacement: `the round introduced three new record defects it did not route` → `the round introduced "three new record defects it did not route", a claim the record refutes`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: all seven items HOLD (i1..i7 = 1)

**F5 (FORGERY, reviewer id N7)** — file `corpus/lessons/round-60.md`

- anchor → replacement: `the round introduced three new record defects it did not route` → `the round did not introduce: three new record defects it did not route`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: all seven items HOLD (i1..i7 = 1)

**F6 (FORGERY, reviewer id N14)** — file `corpus/lessons/round-60.md`

- anchor → replacement: `the round introduced three new record defects it did not route` → `the round did not introduce, as the earlier claim had it, three new record defects it did not route`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: all seven items HOLD (i1..i7 = 1)

**F7 (FORGERY, reviewer id N9)** — file `LOG.md`

- anchor → replacement: `it was rewritten in place at` → `it was not, contrary to the earlier record's claim, rewritten in place at`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: all seven items HOLD (i1..i7 = 1)

**F8 (FORGERY, reviewer id N11)** — file `corpus/lessons/round-60.md`

- anchor → replacement: `so the literal reading is 3/16 = 18.75 %, and counting the sentinel as an attack seat gives 4/16 = 25 %` → `so the literal reading is 4/16 = 25 %, and counting the sentinel as an attack seat gives 3/16 = 18.75 %`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: all seven items HOLD (i1..i7 = 1)

**F9 (FORGERY, reviewer id N12)** — file `corpus/lessons/round-60.md`

- anchor → replacement: `launch 15:09:28 −03` → `launch 16:59:59 −03`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: all seven items HOLD (i1..i7 = 1)

**F10 (FORGERY, reviewer id N12b)** — file `corpus/lessons/round-60.md`

- anchor → replacement: `launch 15:09:28 −03` → `launch 15:09:28 −03 (also seen at 16:59:59 −03)`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: all seven items HOLD (i1..i7 = 1)

### 3.2 The six benign fixtures (P1..P6) — measured on the BASE checker

**P1 (BENIGN, reviewer id D7)** — file `plans/round-60.md`

- anchor → replacement: `**A3 item 2 is withdrawn**` → `**Item 2 of A3 is withdrawn**`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: c1: i3 FAIL a7-at-line=331 block-end=331 amendment=incomplete lesson-line=second-instance

**P2 (BENIGN, reviewer id D7)** — file `plans/round-60.md`

- anchor → replacement: `**A3 item 2 is withdrawn**` → `**A3 item 2 is not merely withdrawn**`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: c1: i3 FAIL a7-at-line=331 block-end=331 amendment=incomplete lesson-line=second-instance

**P3 (BENIGN, reviewer id D7)** — file `corpus/lessons/round-60.md`

- anchor → replacement: `the round introduced three new record defects it did not route` → `the round introduced no fewer than three new record defects it did not route`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: c1: i4 FAIL candidates=1 last-line=missing-quote-ids-or-negated-three

**P4 (BENIGN, reviewer id D7)** — file `corpus/lessons/round-60.md`

- anchor → replacement: `the round introduced three new record defects it did not route` → `the round introduced 3 new record defects it did not route`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: c1: i4 FAIL candidates=1 last-line=missing-quote-ids-or-negated-three

**P5 (BENIGN, reviewer id D7)** — file `LOG.md`

- anchor → replacement: `it was rewritten in place at` → `it was not appended but rewritten in place at`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: c1: i5 FAIL derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=present

**P6 (BENIGN, reviewer id D7)** — file `LOG.md`

- anchor → replacement: `it was rewritten in place at` → `it was rewritten in-place at`
- anchor occurrence count in the measured copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines: c1: i5 FAIL derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=missing negator=present

### 3.3 The unmodified copy

- command: `python3 -I -B plans/round-61-c1-check.py --root <copy of BASE, no fixture> --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge`
- output: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- rc: **1**
- per-item lines:
  - `c1: i1 HOLD derived results=16 output=3824 supersedes-lines-after=1 last-line=states-derived-count-and-names-mutants.md`
  - `c1: i2 HOLD selftest[rc=0 cases=36 PASS-line] registry[selftest-cell='`bash plans/round-60-c2.sh --selftest` ⇒' none-own=absent] mutation[mutated rc=1 finding=yes]`
  - `c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance`
  - `c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three`
  - `c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=absent`
  - `c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=none`
  - `c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-fraction-percentage-pairs-present`

### 3.4 The checker's own `--selftest` case count

- command: `python3 -I -B plans/round-61-c1-check.py --selftest` (run in the extracted BASE tree)
- output: `C1_CHECK_SELFTEST: PASS (cases=75)`
- rc: **0**

### 3.5 Tally

- accepted (forgeries reading `value=0`): **10 / 10**
- rejected (benign rewrites reading `value>=1`): **6 / 6**
- unmodified copy reading `value=0`: yes
- every forgery rc: 1; every benign rc: 1; unmodified rc: 1

### 3.6 C2 legs

**CM2a** — copy of `plans/round-62-c1.sh` with
`stub=0; [[ $stub_c1 -eq 1 && $stub_c2 -eq 1 ]] && stub=1` replaced by `stub=1`

- needle occurrence count in the copy (asserted exactly 1): **1**
- command: `bash plans/round-62-c1.sh --selftest --tree <BASE tree>`, run with cwd = the copy's own tree (the script resolves its TSVs from its parent dir)
- output (last line): `C1_COUNTER_SELFTEST: PASS (8/8 checks)`
- rc: **0**
  - `c1-counter: selftest tree=--tree /fast/scratch/hyaku/kagi-r63/R63ScoutPreState/base (copied 10883 files) scratch=/fast/scratch/hyaku/kagi-r63/R63ScoutPreState/scratch/kagi-r62/R62ExecC1Counter/run-20261107T200602Z-2809150`
  - `C1_COUNTER_SELFTEST: PASS (8/8 checks)`

**CM2b** — copy of `plans/round-62-c1.sh` with a line `SL_OK=1` appended before the closing brace of `stub_leg`

- needle occurrence count in the copy (asserted exactly 1): **1**
- command: `bash plans/round-62-c1.sh --selftest --tree <BASE tree>`, run with cwd = the copy's own tree
- output (last line): `C1_COUNTER_SELFTEST: PASS (8/8 checks)`
- rc: **0**
  - `c1-counter: selftest tree=--tree /fast/scratch/hyaku/kagi-r63/R63ScoutPreState/base (copied 10883 files) scratch=/fast/scratch/hyaku/kagi-r63/R63ScoutPreState/scratch/kagi-r62/R62ExecC1Counter/run-20261107T200718Z-3459692`
  - `C1_COUNTER_SELFTEST: PASS (8/8 checks)`

**GM5** — copy of `plans/round-61-c1-check.py` with
`ok = len(qualifying) >= 3 and bool(superseded) and not denied` replaced by
`ok = len(qualifying) >= 3 and not denied`

- needle occurrence count in the copy (asserted exactly 1): **1**
- command: `python3 -I -B plans/round-61-c1-check.py --selftest`, run with cwd = the copy's own tree
- output (last line): `C1_CHECK_SELFTEST: PASS (cases=75)`
- rc: **0**
  - `C1_CHECK_SELFTEST: PASS (cases=75)`

**battery control count**

- command: `grep -c 'C1-F8\|C2-F6' plans/round-62-controls.sh`
- output: `0`
- rc: 1 (grep exits 1 on a zero count)

**L3 / L4 stub counters**

The two stubs are minimal files that print the claim's **target** verdict line
verbatim and exit 0 — the L3/L4 shape the plan names:

```
$ cat stubs/stub-c1-counter.sh            # L4 (D-6): printer-stub copy of the C1 claim counter
#!/usr/bin/env bash
printf '%s\n' 'C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 (real=1 selftest=1 prior=1 para=1 stub=1)'
exit 0
$ bash stubs/stub-c1-counter.sh
C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 (real=1 selftest=1 prior=1 para=1 stub=1)
rc=0
```

```
$ cat stubs/stub-c2-counter.sh            # L3 (D12): constant-verdict copy of the C2 claim counter
#!/usr/bin/env bash
printf '%s\n' 'C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1)'
exit 0
$ bash stubs/stub-c2-counter.sh
C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1)
rc=0
```

(The C2 stub prints the **post-Amendment-A2** target line — `population=5`, legs
`l1 l2 l3 l4 l6`, no `l5` — because A2 is the frozen predicate in force; the
pre-amendment form was `population=6` with an `l5` field. The C1 verdict line is
unchanged by A2.)

- both files print the target verdict line verbatim and exit 0, so at BASE they are indistinguishable from the real counters by output alone, and the battery carries no control that would catch them (`grep -c` ⇒ 0).

**L5 (S3) — zero-match M-A needle**

- S3 tree construction: `plans/round-61-c2.sh` marker lines `# BEGIN-DECIDE`, `# END-DECIDE`, `# BEGIN-SHIMS`, `# END-SHIMS` removed (counts before: {'# BEGIN-DECIDE': 1, '# END-DECIDE': 1, '# BEGIN-SHIMS': 1, '# END-SHIMS': 1}; after: {'# BEGIN-DECIDE': 0, '# END-DECIDE': 0, '# BEGIN-SHIMS': 0, '# END-SHIMS': 0}) and the BASE aggregation text removed (count before 0, after 0).
- command: `bash plans/round-62-c2.sh --tree <S3 tree>`
- output: `C2_HARDENED: SETUP needle-ma`
- rc: **2**

- control variant S3b (markers removed, BASE aggregation text left in place): output `C2_HARDENED: SETUP needle-ma`, rc 2 — same reading.
- **independent confirmation of plan Amendment A2**: L5 is vacuous at BASE (the leg already fires), so the C2 population is 5 (L1, L2, L3, L4, L6) and the target is killed=5, not 6.

## 4. What this seat derived (no plan figure quoted)

| claim | metric | derived at BASE | from |
|---|---|---|---|
| C1_RESIDUAL | accepted (forgeries reading `value=0`) | **10 / 10** | §3.1 |
| C1_RESIDUAL | rejected (benign rewrites reading `value>=1`) | **6 / 6** | §3.2 |
| C1_RESIDUAL | unmodified copy | reads `value=0` rc 1 | §3.3 |
| C1_RESIDUAL | checker `--selftest` cases | **75** | §3.4 |
| C2_REFUSAL | L1 (CM2a) killed? | **no** — mutant still prints `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0 | §3.6 |
| C2_REFUSAL | L2 (CM2b) killed? | **no** — mutant still prints `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0 | §3.6 |
| C2_REFUSAL | L3 (D12) killed? | **no** — the stub counter prints the target verdict line rc 0 and the battery carries no control for it (`grep -c` ⇒ 0) | §3.6 |
| C2_REFUSAL | L4 (D-6) killed? | **no** — the stub counter prints the target verdict line rc 0 and the battery carries no control for it (`grep -c` ⇒ 0) | §3.6 |
| C2_REFUSAL | L6 (GM5) killed? | **no** — mutant checker still prints `C1_CHECK_SELFTEST: PASS (cases=75)` rc 0 | §3.6 |
| C2_REFUSAL | L5 (S3) killed? | **the leg already fires at BASE** — `C2_HARDENED: SETUP needle-ma` rc 2, i.e. **vacuous** | §3.6 |

So: **C1 accepted = 10, rejected = 6** (both claims' BASE readings re-derived
independently), and **C2 killed = 0** over the live population.

## 5. Defects found (reported, never amended)

1. **L5 (S3) is vacuous at BASE — the plan's Amendment A2 is confirmed
   independently.** `bash plans/round-62-c2.sh --tree <tree without the marker
   block and without the BASE aggregation text>` prints
   `C2_HARDENED: SETUP needle-ma` with rc **2** (`plans/round-62-c2.sh:279`
   `[ "$ma_applied" = 1 ] || setup needle-ma`). A leg that already fires at BASE
   cannot count toward `killed`, so the C2 population is **5**
   (L1, L2, L3, L4, L6) and the target is **killed=5**, not 6. This seat
   re-derived that reading independently and it agrees with
   `plans/round-63.md` §Amendment A2 (commit `81bd56c`).
   *Consequence for the round:* the seat briefs and the wave milestone string
   still say `C2_REFUSAL killed 0->6` / "six named surviving mutants" — those
   carry the pre-amendment count. The frozen predicate (population 5, target
   killed=5) is authoritative; the briefs are stale. Reported to the L1, not
   amended.
2. **The BASE checker has no `--fleet` flag.** The plan's §C1 predicate states
   the checker is invoked
   `python3 -I -B … --root <copy> --repo <lane> --fleet <fleet-root> --no-challenge`.
   The BASE `plans/round-61-c1-check.py` rejects that flag:
   `argparse` prints `unrecognized arguments: --fleet /home/vgpnk/Projects/shokunin`
   and exits **2**. This is expected for a BASE instrument and is a note for the
   candidate's author (the round-63 checker must accept `--fleet` and read
   `/home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md` §Stale-lane);
   it is not a defect in the frozen predicate. Every measurement in this receipt
   therefore uses the flag set the plan itself lists in its §Commands block
   without `--fleet`, and the lane's own round-62 counter (`run_checker`) likewise
   passes only `--root/--repo/--no-challenge`.
3. **The BASE round-62 C2 counter's fallback needle does not match BASE bytes.**
   `plans/round-62-c2.sh`'s `apply_base_mut` looks for the BASE aggregation text
   `value=0\n[ "$pass" = 5 ] && …` — that string occurs **0** times in the BASE
   `plans/round-61-c2.sh` (`grep -c` equivalent: the literal was built in Python
   and `count` returned 0). Only the marker-block path
   (`# BEGIN-DECIDE`/`# END-DECIDE`) matches at BASE (1 occurrence each).
   Consequence: on an S3 tree (markers removed) the counter takes the
   `apply_base_mut` fallback, that also misses, and the leg SETUPs
   (`needle-ma`, rc 2) instead of reading a surviving mutant — which is exactly
   the L5 vacuity in §5.1. A candidate's S3 leg must therefore use a needle that
   the BASE tree actually carries.

## 6. Boundary notes (what this seat did NOT measure)

- This seat measured the **pre-state** of both claims only. It did not build the
  candidate, run `plans/round-63-c1.sh` / `plans/round-63-c2.sh` (they do not
  exist at BASE), or evaluate any candidate verdict.
- The C2 real-trial leg (`value=5 … shims=5 vectors=ok/5`) and the C2 counter's
  own `--selftest` on a candidate tree are **out of this seat's scope** (they
  need the candidate and, for the real trial, `bao`). The BASE-side equivalent
  (`round-61-c2.sh --selftest`) was not re-run either, because it is not one of
  the six named legs and the plan's guard leg (c) is a candidate-side reading.
- No guard-leg re-reading of the *candidate* was attempted; guard legs are stated
  against the candidate tree.

## 7. Scratch hygiene

Everything this seat created lives under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ScoutPreState/`
(`base/`, `fixtures/` — 17 full tree copies, `c2/`, `s3/`, `s3b/`, `scratch/`,
`stubs/`, three driver scripts and two JSON receipts) and is **deleted before the
seat yields**. No citable evidence was written under `/tmp`; no secret value,
token, cookie, session id or vault/item/field name appears in this receipt or
in the wave report.

SEAT-STATUS: complete
