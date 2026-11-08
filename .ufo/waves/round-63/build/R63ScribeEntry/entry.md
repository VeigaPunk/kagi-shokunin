# R63ScribeEntry — command and output record

Seat `R63ScribeEntry` (scribe, round 63 attempt 1, wave `kagi-r63-w1`). Lane
`/home/vgpnk/Projects/shokunin/kagi-shokunin` at BASE
`0c07aab8df64b673a54a5113aebd7f34b622adbc` (lane HEAD at write time `966c469`).
Scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ScribeEntry` (deleted before
yield; the receipts below are copied into this directory). Every command ran from the
lane root unless a `cd` is shown. This file is a record, not a verdict: the frozen
counters and the L1's candidate receipt are the verdicts.

## S1 — reads before writing

```
$ git log --oneline -8
81bd56c round-63: plan Amendment A2 (C2 population 5, L5 vacuous at BASE with its measured SETUP reading)
4fe6c0d round-63: wave spec, dispatch and ready file (kagi-r63-w1, 15 seats) with plan Amendment A1 (wave shape only)
12c9e42 round-63: frozen predeclaration (C1 C1_RESIDUAL accepted 10->0 and rejected 6->0; C2 C2_REFUSAL killed 0->6)
0c07aab round-62 verifier spot-check (integrator, hyaku): non-author admit/reject
```

Read in full: `plans/round-63.md` (§C1, §C2, §Frontier, §considerthese, §Bounds,
Amendments A1/A2), `corpus/lessons/round-62.md` (§Gate, §Mistakes), 
`corpus/lessons/round-62-verifier-spotcheck.md` (§2, §6), `corpus/QUALITY.md` (QM76–QM82),
`SKILL.md` §Gate registry (`:857-871`, the round-62 additions), 
`corpus/knowledge/claim-instrument-falsifiability.md` (entry shape).

```
$ wc -l corpus/QUALITY.md SKILL.md corpus/SOURCES.md
  285 corpus/QUALITY.md
  871 SKILL.md
  296 corpus/SOURCES.md
```

## S2 — BASE tree and the sixteen-fixture census (this seat's own run)

```
$ git archive 0c07aab8df64b673a54a5113aebd7f34b622adbc | tar -x -C <scratch>/base
$ du -sh <scratch>/base
206M	<scratch>/base
$ sha256sum <scratch>/base/plans/round-61-c1-check.py
f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0  plans/round-61-c1-check.py
$ wc -l <scratch>/base/plans/round-61-c1-check.py
1710
```

The fixture table was parsed from the frozen plan (not retyped): `fixtures.py` reads
`plans/round-63.md` §C1, splits each `| Fn | … |` row, resolves `same anchor` rows to the
previous row's anchor for the same file, and writes `fixtures.json` (16 rows). Each
fixture copy is `cp -a --reflink=auto base <copy>`, the anchor count is asserted to be
exactly 1 before substitution, and the checker runs as

```
python3 -I -B plans/round-61-c1-check.py --root . --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge
```

with `cwd` = the fixture copy. Full output (`census-base.txt`, 17 lines; the same data in
`census-base.json`):

```
BASE-unmodified	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F1	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F2	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F3	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F4	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F5	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F6	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F7	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F8	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F9	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
F10	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
P1	rc=1	C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0
P2	rc=1	C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0
P3	rc=1	C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0
P4	rc=1	C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0
P5	rc=1	C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0
P6	rc=1	C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0
SUMMARY accepted=10 rejected=6 population=10/6
```

This reproduces the L1's committed census (`.ufo/waves/round-63/base/census.md`, commit
`966c469`) line for line, from bytes this seat extracted itself.

## S3 — the two falsifier sentences

`falsifiers.py` builds two more copies of the BASE tree from the same anchor
(`**A3 item 2 is withdrawn**` in `plans/round-60.md`) and runs the BASE checker.

```
$ python3 falsifiers.py
X1-forgery-none-of-the-lists	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
X2-benign-adverbial-without	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
```

X1 is `**A3 item 2 is withdrawn in the abandoned draft alone**` (no listed negator,
denial or idiom; accepted — the closed-list floor). X2 is `**Without objection, A3 item 2
is withdrawn**` (a benign sentence the five-token window misses because `without` sits
six tokens before the token; accepted at BASE).

`falsifier-hardened.py` copies the lane working tree (rsync, `.git` excluded), records the
checker digest, and runs the same two sentences with `--fleet
/home/vgpnk/Projects/shokunin`:

```
checker sha256 cc92d8a91ab19ae0cf30555f81d25b20a2f8538e0583f1adb81455a39db97956
checker bytes 97564
X1	rc=1	C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0
X2	rc=1	C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0
```

So the hardened grammar rejects X2 (`i3=0`) and still accepts X1 — the over-read and the
under-read the entry's §Falsifiers states. The digest is a working-tree read at 20:09; the
landed checker is `eb08094c…` (2031 lines) and the entry names the digest it measured.

## S4 — instrument readings (point reads, mid-wave)

```
$ grep -c 'C1-F8\|C2-F6' plans/round-62-controls.sh
0
```

```
$ python3 -I -B plans/round-61-c1-check.py --selftest
C1_CHECK_SELFTEST: PASS (cases=76)          # 20:07, mid-hardening (floor is 91)
$ python3 -I -B plans/round-61-c1-check.py --selftest
C1_CHECK_SELFTEST: PASS (cases=102)         # 20:11, sha256 eb08094c…, 2031 lines
```

```
$ HYAKU_SCRATCH=<own> bash plans/round-63-c1.sh --selftest
c1-residual: selftest tree=revision 0c07aab8… (git archive) scratch=…
C1_RESIDUAL_SELFTEST: PASS (28/28 checks)
rc=0
```

```
$ HYAKU_SCRATCH=<own> bash plans/round-63-controls.sh --selftest     # 20:04 bytes
FINDING R63C-CTL-ST-e2e-base-c2nowork-match
FINDING R63C-CTL-ST-e2e-base-summary
CONTROLS_SELFTEST: FAIL (cases=25 failed=3)
rc=1
$ HYAKU_SCRATCH=<own> bash plans/round-63-controls.sh --selftest     # 20:19 bytes
CONTROLS_SELFTEST: PASS (cases=25)
rc=0
$ HYAKU_SCRATCH=<own> bash plans/round-63-c2.sh --selftest           # 20:21 bytes
C2R63_SELFTEST: PASS (cases=13)
rc=0
```

The first controls reading is a mid-iteration point read (the executor was still fixing
the e2e cases); the 20:19 bytes pass 25/25. The C2 counter landed at 20:21 (the seat that
owned it died on a provider 429; the L1 wrote it) and its selftest passes 13/13.

## S5 — source-line locates (this seat's own re-resolution)

```
$ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-63/capture/S135.body "pseudo-trigger terms for terms that contain trigger terms but do not act as contextual property triggers"
RENDERED_TEXT_V1_LOCATE: count=1
$ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-63/capture/S137.body "A mutant is deemed equivalent if, for all possible test cases, it exhibits the same behavior as the original program under test."
RENDERED_TEXT_V1_LOCATE: count=1
$ sha256sum .ufo/waves/round-63/capture/S135.body .ufo/waves/round-63/capture/S137.body
cdbb417379e146a9199efa54f6322b373880aee9f76faffc624c8f94ac41fb8b  S135.body
21893b049e06bf0f6e019808a5b47e3cdf2c0a9c56927bb0c7b2644b907d1849  S137.body
```

S135 is the same PMC deposit as S130 (same digest, 189603 B); S137 is the arXiv HTML
deposit (286109 B). The records scribe's id allocation (IRC, 20:11) names S135 and S137
as the two mined rows with `used-by` on the entry, which is why both are on the `source:`
line.

## S6 — files written

- `corpus/knowledge/negation-scope-grammar.md` (new): `source:`/`verified-at:`/`recheck:`
  trio, §The rule, §The two-sided test, §Bounds, §Falsifiers.
- `corpus/QUALITY.md` (appended): `## Criteria from the round-63 negation-scope work`
  with QM83 and QM84; no existing row rewritten.
- `SKILL.md` (appended): `## Gate registry — round-63 additions` with the three gate rows.
- This file and the receipts beside it.

## S7 — checks run on the written files

```
$ awk -F'|' '/^\| QM8[34] /{print NR": fields="NF}' corpus/QUALITY.md
291: fields=6
292: fields=6
```

(5-column row shape: 6 fields with the edge pipes; the first draft of QM84 carried an
escaped `\|` in a `grep` pattern and was rewritten to avoid it.)

```
$ head -1 corpus/knowledge/negation-scope-grammar.md | cut -c1-80
source: S135 — Harkema et al., "ConText: an algorithm for determining negation, …
$ sed -n '2,4p' corpus/knowledge/negation-scope-grammar.md | cut -c1-40
verified-at: 2026-11-07 — BASE `0c07aab8df64b6…
recheck: 180d — re-extract the claim BASE, re…
```

## S8 — final readings and the SKILL rows

The SKILL rows carry: C1 `C1_RESIDUAL_SELFTEST: PASS (28/28 checks)` (post-A3 bytes, 20:22; the
20:09 pre-A3 bytes read 10/10), C2 `C2R63_SELFTEST: PASS (cases=13)` (measured 20:23 on the landed
bytes), controls `CONTROLS_SELFTEST: PASS (cases=25)` (measured 20:19).

C1 counter verdict runs on the candidate tree: two attempts (20:12 and 20:17 bytes) were
cancelled or starved under wave load; the 20:12 run crashed on the counter's own stub leg
(`plans/round-63-c1.sh: line 472: STUB: unbound variable`), and the 20:17 run was killed
by this seat to free CPU after the reviewer recorded the same starvation class. No
`C1_RESIDUAL:` line was captured by this seat; the entry says the counter's line is the
counter's to print and the L1's to land, and does not substitute for it.
