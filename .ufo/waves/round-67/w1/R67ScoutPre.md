# R67ScoutPre — round 67 scout (pre-flight BASE census, blindness witness, C2 legs)

seat: `R67ScoutPre` (scout, wave 1 of round 67, lane kagi)
lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`)
BASE (frozen claim): `076701a11a58e3eb58d996b4c76c5e18071fb179`
tip at measurement: `aa8807e443166f45485e1aada2989f646efc707c` — *"round-67: frozen predeclaration (plan, claims, declared-axis rows, scorecard pre-move)"*

role: re-derive the round's BASE census independently; do not trust the L1's numbers.

---

## Axes touched

| axis | touched | how |
|---|---|---|
| **calibration** | yes | every plan-stated BASE number re-derived from `git show BASE:` / fresh `git archive` extractions, never from the live tree; five defects named in the frozen plan and its in-flight landing surfaces |
| **freshness** | yes | measured the *current* state of the landing surfaces (census bytes, C1/C2 counters, S115 re-cut status, the `PROVINCE.md`/`SKILL.md` selftest pin) at a moving tip; recorded which pins are still open |
| depth / coverage / operability / adjacency | not touched | out of this seat's scope (no edits, no commits, no dispatch) |

**No edits were made outside this report and its receipts directory.** No commit, no `git add`, no stash, no jj mutation, no `agent://all`, no `ask`. No subagent dispatched (leaf seat).

---

## 1. Tip hash, status, census bytes, selftest count

```
tip:  aa8807e443166f45485e1aada2989f646efc707c
BASE: 076701a11a58e3eb58d996b4c76c5e18071fb179
```

`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin status --porcelain` — full output in
receipt `01-tip-and-status.txt`. At the first reading it listed only untracked round-67
dispatch artefacts. By the last reading the L1 and the in-flight executor seats were
actively editing (`corpus/sources-census.sh`, `plans/round-67-c1.sh`, `plans/round-67-c2.sh`
untracked and modified; `SCORECARD.md`, `SKILL.md`, `PROVINCE.md`, `corpus/QUALITY.md`,
`corpus/README.md`, `corpus/lessons/round-66.md`, `.ufo/waves/round-66/claims.json`,
`.ufo/waves/round-66/claim-falsification.tsv` modified; `corpus/lessons/round-67.md` and
`.ufo/waves/round-66/final/c3-base.txt` untracked).

**Census sha256 at BASE** (and identical at the tip — the round-67 predeclaration commit
did not touch it):

```
e9ae2620ff4ad8e3122f8e7c04c19d16afccf03f0feec7c72edcce78bdd58252  corpus/sources-census.sh
```

**`--selftest` case count at BASE: 78 cases** — `SOURCES_CENSUS_SELFTEST: PASS (78 cases)`, rc=0.
Pinned consistently at BASE in `SKILL.md:50`, `SKILL.md:702`, `SKILL.md:755`, `PROVINCE.md:78`.

**BASE census on the unmodified BASE tree** → `SOURCES_CENSUS: CLEAN (rows=156 A=139 B=2 C=15
queued=3 mined=136 rejected=17 entries_sourced=26 legacy=21 captures=156 inrow=16
inrow_only=0 inrow_nonreproducing=12)`, rc=0.

---

## 2. Population census over `corpus/source-fetches.tsv` (independent)

Method (my own script, receipt `02-population-census.txt`): a row is **capture-path-shaped**
when col16 contains `/` **and** matches `^[A-Za-z0-9._][A-Za-z0-9._/-]*$`; **bound** means the
path resolves repo-relative, its realpath is inside the tree, it is a regular file, its
sha256 equals col10 and its size equals col11; **located** means col13 locates `count>=1`
under the col14 normalization (`rendered-text-v1` via `corpus/rendered-text-v1.py locate FILE
QUOTE`, `raw-literal-v1` by literal substring). Prose locations are counted and never checked.

| quantity | measured at BASE |
|---|---|
| rows total | **156** |
| path-shaped (col16) rows | **36** |
| prose rows | **120** |
| path-shaped rows whose file exists with sha256==col10 **and** size==col11 | **36** (0 failures) |
| path-shaped rows whose col13 locates under col14 | **35** |
| **not** locating | **1 — S115** |

S115: `.ufo/waves/round-57/capture/S115.body`, `rendered-text-v1`, `count=0`. Declared quote:
*"Audit devices must be enabled by a root user using bao audit enable or using the audit stanza."*

Normalizations across the 36 path rows: `rendered-text-v1` = 31, `raw-literal-v1` = 5 (all 5 locate).

**The regex is load-bearing.** 17 of the 120 prose rows *do* contain a `/` but fail the regex
(`page title/H1`, `H1 JWT/OIDC auth method`, `POST /:secret-mount-path/config parameters,
max_versions`, …). A gate testing only "contains `/`" would mis-classify 17 prose rows as path
rows. No row's col16 is absolute; none contains `..`.

---

## 3. The blindness witness

Method: one **fresh** `git archive BASE | tar -x -C <scratch>` per mutation, so no mutation can
leak into a later reading. (I made this mistake once — an early witness reused a tree I had
already mutated — and re-ran every witness on clean extractions. The readings below are the
clean ones.)

**Witness A — repoint S164's col16 to `.ufo/waves/round-64/capture/S148.body`**

```
$ bash corpus/sources-census.sh          # in the extracted copy
SOURCES_CENSUS: CLEAN (rows=156 A=139 B=2 C=15 queued=3 mined=136 rejected=17
  entries_sourced=26 legacy=21 captures=156 inrow=16 inrow_only=0 inrow_nonreproducing=12)
rc=0
```

The row still declares S164's own pin (`3b8d4e15…cba40`, 264946 B) while naming S148.body
(`fabc74c5…ba9f15`, 39750 B) — wrong body, wrong digest, wrong size, and the declared quote
does not locate in it. **BASE does not catch it.** The gate's only capture test at BASE is the
location string's *length* (`[[ ${#floc} -ge 8 ]]`, `corpus/sources-census.sh:305`).

**Witness B — S115's col13 replaced by a non-locating string** (also S164's, so the leg is not
confounded by S115's own pre-existing non-locating quote)

```
$ bash corpus/sources-census.sh          # in the extracted copy
SOURCES_CENSUS: CLEAN (rows=156 …)      rc=0
```

The census checks only the quote's **word count** (≤25) and its normalization *name*; it never
locates the quote in the body. **BASE does not catch it.**

> **BASE catches NEITHER witness.**

**Extended to all six of the plan's mutation legs** (each on its own fresh extraction, BASE
census): `repoint` rc=0 CLEAN · `truncate-by-1` rc=0 CLEAN · `delete` rc=0 CLEAN ·
`absolute location` rc=0 CLEAN · `..` location` rc=0 CLEAN · `quote → garbage` rc=0 CLEAN.
So `caught=0/6` at BASE — the target is unreachable by doing nothing, not partially reachable.

**Fleet wrapper is blind too:** on the repointed copy,
`bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root … <copy>` reads
W04 duplicate-url warnings only, rc=0. The fleet wrapper has no capture-finding class at all
(this is the gate the round-66 lesson M66-5 confused with the lane gate).

---

## 4. The seven C2 legs at BASE

Every reading is from `git show BASE:<path>` or a fresh BASE extraction — **not** the live tree,
because the L1 was landing the repairs concurrently and reading the live tree would have
measured the repair instead of the defect. Receipt: `04-c2-seven-legs.txt`.

| leg | exact command | BASE reading | verdict |
|---|---|---|---|
| **L1** | `git show BASE:SCORECARD.md \| grep -n "C2_PREFILE: gate="` + `git show BASE:.ufo/waves/round-66/final/c2-candidate.txt` | `SCORECARD.md:2339` states ``C2_PREFILE: gate=A claims=3 rows=R attack_seats=K guard=G`` and "the ledger reads `pass` with the wave's attack seats reconciled"; the cited receipt reads `C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0` and `PREFILE-FALSIFICATION: SETUP findings=1` | **defect** |
| **L2** | `git show BASE:SKILL.md \| grep "c1-carrier: selftest cases="` + `bash plans/round-66-c1.sh --selftest` (in a BASE extraction) | `SKILL.md:893` pins `cases=14 failed=0`; the instrument prints `c1-carrier: selftest cases=45 failed=0` | **defect** (stale by 31) |
| **L3** | `git show BASE:corpus/README.md \| grep -c "claim-instrument-carrier-binding"` + `git ls-tree -r --name-only BASE \| grep -c "corpus/knowledge/claim-instrument-carrier-binding.md"` | 0 rows in README; the entry **exists** in the tree; README holds 12 `corpus/knowledge/` rows | **defect** |
| **L4** | `git show BASE:.ufo/waves/round-66/claim-falsification.tsv \| cut -f2` (+ `grep -c R66Sentinel`) | 9 rows: R66Reviewer×2, R66Critic×2, R66MutC1, R66ExecC2Claims, R66MutC2, R66ScoutPreState, R66Connector. **R66Sentinel = 0**, though it filed `.ufo/waves/round-66/w1/R66Sentinel.md` | **defect** |
| **L5** | `git show BASE:.ufo/waves/round-66/claims.json` | C2 title = `C2_CLAIMS: …`; C3 title = `C3_SELFREF: …`, while the landed counter prints `C3_CENSUS:` and the receipt prints `C2_PREFILE:` | **defect** |
| **L6** | `git ls-tree -r --name-only BASE -- .ufo/waves/round-66/final/` + `git log --all --oneline -- .ufo/waves/round-66/final/c3-base.txt` + `grep -c "c3-base" /home/vgpnk/Projects/shokunin/.ufo/reports/round-66/kagi.md` | BASE `final/` holds 10 files, `c3-base.txt` is **not** one; `git log --all` prints **nothing** for that path; the round-66 report cites it **twice** (lines 60, 189) | **defect** |
| **L7** | `git show BASE:corpus/lessons/round-66.md \| grep -c "used-by"` / `grep -c "S113"` / `wc -l` | 304 lines; `used-by` appears **once** (line 28, prose, no old→new); `S113` appears **0** times; no `Corrigendum — round 66` section | **defect** |

**7/7 legs read `defect`.** No leg is vacuous (none reads `ok` at BASE). The plan's C2
do-nothing control (`--tree BASE` ⇒ `mismatches=7`) is reachable as frozen.

---

## 5. Disagreements with the plan's stated BASE numbers

**None numerically.** Every clause of the plan's motivating evidence re-derives exactly: 36 path
rows, 36 bound (all hashes and byte counts match), 35 located, S115 the sole non-locating row,
120 prose rows, the gate's only capture test being `${#floc} -ge 8`, and BASE reading CLEAN on
a repointed copy. The C2 table's seven BASE defects all re-derive.

Two readings are recorded so they are not misread later, but **neither is a disagreement**:

- The plan's C1 **target** `located=36` is not a BASE reading. BASE is `located=35`; reaching 36
  needs the S115 quote re-cut the plan itself lists as a landing surface. The plan states both
  consistently (evidence = today, predicate = after the landing surface).
- `prose=120` in guard (a) holds only because the shape predicate's **regex** excludes the 17
  prose rows that contain a `/`.

---

## 6. Defects found in the frozen plan and its landing surfaces

### DEFECT F-1 — HIGH, calibration/attribution: the plan cites a receipt that does not exist

`plans/round-67.md` cites `.ufo/waves/round-67/base/blind-gate.txt` as the receipt for the
blindness ("re-measured here, receipt `.ufo/waves/round-67/base/blind-gate.txt`") and
`.ufo/waves/round-67/base/census-start.txt` for the frontier census. Measured: the directory
`.ufo/waves/round-67/base/` exists but is **empty**; `blind-gate.txt` is absent from the working
tree and from **every commit** (`git log --all -- .ufo/waves/round-67/base/blind-gate.txt`
prints nothing). The plan's own motivating evidence rests on a receipt that was never written —
the same class as the L6 defect this round exists to close, reproduced inside the round-67 plan.
The plan is frozen and I did not amend it; the L1 must land the receipt or the report must
re-derive it and say so.

**F-1 subsequently RESOLVED as to existence.** At 08:04 the L1 created
`.ufo/waves/round-67/base/` and both plan-cited paths now exist: `blind-gate.txt` and
`census-start.txt` (plus `base-gate.txt` and `base66-gate.txt`).

**Residual gap — the receipt is not self-identifying.** `blind-gate.txt` is a single CLEAN
verdict line and is **byte-identical** to `base-gate.txt`, the receipt of the *ordinary*
(unmutated) BASE tree; it names no mutation and no tree. That matters because the whole
point of the blindness witness is that the repointed copy prints the *same* verdict as the
clean tree — I measured exactly that — so a verdict-only receipt **cannot** carry the
witness. The evidence that a mutation was applied must live in the receipt's provenance.
This is the same standard the round itself applies to leg L6 ("a reconstructed receipt
whose header names its provenance"). My receipt `03-blindness-witness.txt` carries the
full witness. Receipt `08-f1-closure-and-gap.txt`.

### DEFECT F-2 — HIGH, coordination: the C1 predicate's arithmetic needs another seat's landing

The C1 predicate freezes `located=36` and guard (a) freezes the exact clean line
`SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)`. BASE is `located=35`
(S115). The S115 re-cut is a landing surface owned by **L1** (`corpus/source-fetches.tsv` — L1
only), while `plans/round-67-c1.sh` belongs to R67ExecCounterC1 and `corpus/sources-census.sh`
to R67ExecGate. So the counter and the gate cannot both read `located=36` until L1 lands the
re-cut. This is **confirmed by execution**: on the live tree the in-flight counter prints

```
C1_READTHROUGH: bound=36 located=35 caught=6/6 guard=0        rc=1
```

with `guard a=0` — guard (a) requires `clean["rc"]==0 and clean["verdict"]=="CLEAN"` and the
exact frozen line, and the tree currently reads
`SOURCES_CAPTURES: FAILED (defects=1 path_rows=36 bound=36 located=35 prose=120)`. The executor's
bytes are correct; the reading is blocked by a row it does not own. This is the round-66 M66-8
shape (a leg measuring state another seat owns) recurring in the predicate's arithmetic. It
resolves the moment L1 lands the re-cut — **verified by execution**: with only that one change
staged on a lane-shaped scratch, the counter reads
`C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1`, rc=0.

**F-2 subsequently RESOLVED in the tree.** The L1 landed the S115 re-cut while I was writing
this up, and the change is *exactly* what my analysis called for — **only col13**, with the
trailing period dropped (`…using the audit stanza.` → `…using the audit stanza`); col10, col11,
col14, col15 and col16 are untouched, and col15 was already correct so no digest re-pin was
needed. The live tree now reads:

```
SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)
SOURCES_CENSUS: CLEAN (rows=156 …)                                    rc=0
```

— the exact frozen guard-(a) line. Receipt `07-f2-closure.txt`.

### DEFECT F-3 — HIGH, vacuity: the frozen predicate cannot catch the "absolute location" leg

The frozen path-shape predicate is *col16 contains `/` **and** matches
`^[A-Za-z0-9._][A-Za-z0-9._/-]*$`*. An **absolute** location such as `/etc/passwd` does **not**
match that regex (the first character class excludes `/`). So under the predicate as frozen an
absolute location is classified **prose** and never checked — yet the plan's mutation battery
lists "absolute location" among the six legs, and the frozen reason vocabulary includes
`capture-outside-root`, otherwise reachable only by a `..` escape.

Verified empirically on a BASE extraction with the strict predicate applied:

```
SOURCES_CAPTURES: FAILED (defects=1 path_rows=35 bound=35 located=34 prose=121)
```

— the absolute row was counted as **prose** (`path_rows` 36→35, `prose` 120→121) and **no
SC_CAPTURE finding named it**. The absolute-location leg is therefore uncatchable as frozen,
and the strict run also breaks guard (a)'s exact clean line.

The in-flight executor has already solved this by **widening** the shape test to also accept an
absolute path (`cap_is_shaped` in the live `corpus/sources-census.sh` adds
`[[ $loc =~ ^/[A-Za-z0-9._][A-Za-z0-9._/-]*$ ]]`). With the widening the leg **is** caught:

```
FINDING SC_CAPTURE id=S164 capture-outside-root
SOURCES_CAPTURES: FAILED (defects=2 path_rows=36 bound=35 located=34 prose=120)
```

and the clean tree still prints `path_rows=36 prose=120`, so guard (a) holds. The widening is
**correct and necessary** — but it changes a *frozen predicate term*, and the plan says that
predicate is the plan's, the counter's code and the receipt's label. It must be recorded as
such. (Confirmed end-to-end by the in-flight counter: `caught=6/6`, with the absolute leg
reading `expected=capture-outside-root reasons=capture-outside-root verdict=FAILED`.)

**As it stands this defect is resolved in the bytes but not in the record.** The in-flight gate
carries the widening, so `caught=6/6` is real; the frozen plan text does not describe it, and the
plan states the predicate is "the plan's, the counter's code and the receipt's label". The L1
must therefore either amend the predicate term (which the plan forbids without an amendment) or
record the widening explicitly in the receipt so the receipt's label and the gate's behaviour
agree. Otherwise a future reader who trusts the plan's predicate will re-derive the strict
behaviour, find the absolute leg uncatchable, and read the counter as defective.

### DEFECT F-4 — MEDIUM, measurement hygiene: two cited receipts are seat obligations

The fleet wrapper `scripts/sources-census.sh validate` writes TSV to stdout and the lane's gate
writes nothing to disk, so `census-start.txt` and `blind-gate.txt` are produced by *seats*, not
by the tools. F-1 shows they were skipped once already. Recorded as a standing obligation, not
a tool defect.

### DEFECT F-5 — MEDIUM, citation freshness: the round-66 C3 counter's reading regresses under C1

Measured on the live tree with the in-flight SC_CAPTURE gate and S115 not yet re-cut:

```
bash corpus/sources-census.sh  -> SOURCES_CENSUS: FAILED (findings=1 rows=156)  rc=1
bash plans/round-66-c3.sh       -> C3_CENSUS: findings=1 rows=156 guard=1        rc=1
```

The round-66 C3 counter reads the lane gate's `findings=` field, so adding the SC_CAPTURE class
changes the round-66 counter's own reading from `findings=0` to `findings=1` on the round-67
tree — the round-66 landed receipt `.ufo/waves/round-66/final/c3-candidate.txt`
(`C3_CENSUS: findings=0`) no longer reproduces there. With S115 re-cut (simulated on a fresh
copy) both read clean again (`C3_CENSUS: findings=0 rows=156 guard=1`, rc=0). The regression is
entirely F-2's pending re-cut, not the SC_CAPTURE class — but the round's report must not cite
the round-66 C3 receipt as a reproducing reading on the round-67 tree without re-running it.

### Also open at measurement time (not plan defects — landing surfaces still pending)

- `PROVINCE.md:78` and `SKILL.md:50` still pin `--selftest` **78 cases** while the in-flight
  census reads **88** (`SOURCES_CENSUS_SELFTEST: PASS (88 cases)`). The plan lists
  "`PROVINCE.md` / `SKILL.md` selftest-count pins updated to the measured count" as a landing
  surface; it is **still open**. (Guard (b) requires `cases >= 84`; 88 satisfies it.)
- The in-flight census's selftest read `FAIL (88 cases, 10 failed)` on one run and
  `PASS (88 cases)` on a later run at the same path — the file was being edited underneath the
  measurement. The PASS reading is the later one.

---

## 7. Counter readings observed (in-flight, uncommitted — reported as observed, not endorsed)

These are the in-flight `plans/round-67-c1.sh` / `plans/round-67-c2.sh` as they stand in the
working tree. They are **not** committed bytes and were still being edited.

**On the live lane tree** (S115 not yet re-cut):

```
C1_READTHROUGH: bound=36 located=35 caught=6/6 guard=0        rc=1
    guard a=0 b=1 c=1 d=1 e=1
    mut-absolute expected=capture-outside-root reasons=capture-outside-root verdict=FAILED
    mut-dotdot    expected=capture-outside-root reasons=capture-outside-root verdict=FAILED
    mut-quote     expected=quote-not-located    reasons=quote-not-located    verdict=FAILED
```

The counter's own bound/located arithmetic **agrees with my independent census exactly**
(bound=36, located=35, path_rows=36, prose=120) — the two were derived separately.

**The frozen predicate is reachable.** Staged a lane-shaped scratch (fleet root + lane copy with
S115's col13 re-cut; scratch only — nothing in the lane was touched) so guard (d) resolves:

```
mut-repoint   expected=capture-digest-mismatch reasons=capture-bytes-mismatch,capture-digest-mismatch verdict=FAILED rc=1
mut-truncate  expected=capture-bytes-mismatch  reasons=capture-bytes-mismatch,capture-digest-mismatch verdict=FAILED rc=1
mut-delete    expected=capture-missing          reasons=capture-missing          verdict=FAILED rc=1
mut-absolute  expected=capture-outside-root     reasons=capture-outside-root    verdict=FAILED rc=1
mut-dotdot    expected=capture-outside-root     reasons=capture-outside-root    verdict=FAILED rc=1
mut-quote     expected=quote-not-located        reasons=quote-not-located       verdict=FAILED rc=1
c1-readthrough: guard a=1 b=1 c=1 d=1 e=1
C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1        rc=0
```

So `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1` **is reached** with the in-flight
bytes, once (i) S115's quote is re-cut and (ii) the fleet wrapper is resolvable. That confirms
F-2's diagnosis exactly: the only thing standing between the live tree and the frozen predicate
is S115's col13 — a row owned by L1, not by the counter or the gate. It also confirms F-3's
resolution: the absolute leg *is* caught, because the in-flight gate widens the shape predicate
to absolute paths.

**C2 on the live lane tree:**

```
LEG L1 verdict=ok ... verdict="C2_PREFILE: gate=0 claims=0 rows=0 attack_seats=0 guard=0"
                   gate_out="PREFILE-FALSIFICATION: SETUP findings=1"
LEG L2 verdict=ok instrument cases=45 failed=0 rc=0 skill=cases=45 failed=0
LEG L3 verdict=ok map-row:119 cells=3 entry=present
LEG L4 verdict=ok row=present claim=C1 class=neutral detail_len=293 referenced=present
LEG L5 verdict=ok expected=C1=C1_CARRIER,C2=C2_PREFILE,C3=C3_CENSUS superseded=C2_CLAIMS,C3_SELFREF
LEG L6 verdict=ok receipt=present header_lines=8 base=d549ee6eb877
                 gate='SOURCES_CENSUS: FAILED (findings=4 rows=155)'
LEG L7 verdict=ok corrigendum ids=7 pairs=7 source=git:d549ee6eb877..076701a11a58
c2-fidelity: guard a=1 b=1 c=1 base_defects=7 selftest_cases=22
C2_FIDELITY: mismatches=0 population=7 guard=1                rc=0
```

The C2 repair is complete on all seven legs **and** its do-nothing control reads
`base_defects=7` — the frozen leg set is non-vacuous, independently corroborating my BASE
measurement (7/7 legs read `defect`). L6's repaired receipt carries the provenance header the
plan asked for and re-derives the BASE reading `SOURCES_CENSUS: FAILED (findings=4 rows=155)`.

**S115 re-cut: only col13 has to change.** The other pins already bind its body correctly —
col10 `76339ff7…090c6`, col11 `41787`, col15 `781463ac…d147` (re-measured with
`rendered-text-v1.py digest`: identical to the declared value), col14 `rendered-text-v1`,
col16 `.ufo/waves/round-57/capture/S115.body`. The current col13 reads `count=0`. Candidates
that locate `count=1` and are ≤25 words: `must be enabled by a root user` (7 words),
`audit stanza` (2 words). **No digest change is needed** — only the quote.

---

## 8. Honest limits

- **Unrun checks.** The counters were **executed** (C1 on the live tree and on a lane-shaped
  scratch; C2 on the live tree) and the frozen predicate was reached — but against **in-flight,
  uncommitted** bytes that were being edited while I measured, and against a **scratch** lane
  copy for the guard-(d) leg. I did not run the counters' own `--selftest` batteries to
  completion, and I did not run the round's end-to-end fleet wrapper on the real lane root with
  the real `kagi` lane argument at the final tip. The reachability result in §7 is therefore
  evidence that the predicate is *reachable with these bytes*, not a verification of a landed
  commit.
- **Moving target.** The tip advanced and the working tree changed under me during the seat.
  Every BASE reading is anchored to `git show BASE:` or a fresh `git archive` extraction; every
  freshness reading is timestamped by the receipt it sits in.
- **Two self-inflicted errors, both corrected before reporting:** (a) an early witness reused a
  tree I had already mutated, and (b) several `grep`s drifted to the live tree because the
  session shell's cwd did not persist. Both were re-measured on clean extractions; the corrected
  readings are the ones reported. `L2`'s selftest, which first read `failed=2`, was a symptom of
  (a) — on a clean extraction it reads `cases=45 failed=0`, matching the plan.
- **Not checked:** the round-67 lesson, `corpus/QUALITY.md` additions, the falsification ledger,
  and the fleet-root census — other seats' surfaces.

---

## 9. Recommended actions for the L1 (integration owner)

1. ~~**Land the S115 quote re-cut** in `corpus/source-fetches.tsv` (L1 owns this file).~~
   **DONE — observed in the tree while I finished this report** (receipt `07-f2-closure.txt`):
   only col13 changed, trailing period dropped; the live gate now prints
   `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)` and the counter reads
   `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1`. F-2 is closed. My prediction that
   only col13 needed to change (no digest re-pin) was borne out exactly.
2. **Record the shape-predicate widening as an amendment or a receipt note** (F-3). Without the
   absolute-path branch the "absolute location" leg is uncatchable and `caught` is 5/6.
   The in-flight gate already has it; the plan's frozen text does not.
3. ~~**Write `.ufo/waves/round-67/base/blind-gate.txt`** (and `census-start.txt`) or drop the
   citations (F-1, F-4).~~ **DONE** — both paths exist as of 08:04. **Residual:** give
   `blind-gate.txt` a provenance header naming the tree it was measured on and the mutation
   applied (S164's col16 repointed to `.ufo/waves/round-64/capture/S148.body`, with the
   body's sha256/byte count). It is currently byte-identical to `base-gate.txt`, the ordinary
   clean-tree receipt, so as written it cannot be distinguished from a non-blindness
   reading — and it is the frozen plan's own motivating evidence. Receipt
   `08-f1-closure-and-gap.txt`.
4. **Update the `PROVINCE.md` / `SKILL.md` selftest-count pins** from 78 to the measured count
   (88 as of the in-flight bytes).
5. **Re-run `plans/round-66-c3.sh` on the round-67 tree** before citing the round-66 C3 receipt
   as a reproducing reading (F-5).

---

## Receipts

| file | contents |
|---|---|
| `.ufo/waves/round-67/w1/R67ScoutPre/01-tip-and-status.txt` | tip hash, BASE hash, `git status --porcelain`, census sha256 at BASE, BASE selftest count, BASE clean verdict |
| `.ufo/waves/round-67/w1/R67ScoutPre/02-population-census.txt` | the independent population census, method, per-row results, path-row id list, the 17 slash-bearing prose rows |
| `.ufo/waves/round-67/w1/R67ScoutPre/03-blindness-witness.txt` | both witnesses verbatim (rc + verdict line), all six mutation legs at BASE, fleet-wrapper blindness, the missing plan-cited receipt |
| `.ufo/waves/round-67/w1/R67ScoutPre/04-c2-seven-legs.txt` | all seven C2 legs: exact command, BASE reading, verdict |
| `.ufo/waves/round-67/w1/R67ScoutPre/05-disagreements-and-defects.txt` | disagreements (none numeric) + defects F-1…F-5 + what I did not verify |
| `.ufo/waves/round-67/w1/R67ScoutPre/06-counter-observations.txt` | the in-flight C1/C2 counter readings verbatim, the lane-shaped scratch that reached the frozen predicate, and the S115 re-cut analysis (only col13 changes) |
| `.ufo/waves/round-67/w1/R67ScoutPre/07-f2-closure.txt` | F-2 closure observed: the L1's S115 re-cut diff field by field, the trailing-period mechanism, and the resulting clean `SOURCES_CAPTURES:` line |
| `.ufo/waves/round-67/w1/R67ScoutPre/08-f1-closure-and-gap.txt` | F-1 closure observed (both plan-cited receipts now exist) and the residual: `blind-gate.txt` is byte-identical to the clean-tree receipt and names no mutation |

Scratch root used: `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r67/R67ScoutPre/` (removed before
yield, after the receipts were copied in). No large files under `/tmp`. No git fixture needed
mutation (no clone, no identity, no `git -C` mutation outside a `mktemp -d`-free read-only
extraction), so the `rev-parse --show-toplevel` assertion was not exercised.
