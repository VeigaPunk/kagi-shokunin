# R67MutGate — mutation test of the SC_CAPTURE census check (round 67, w1)

Seat: mutation-tester (leaf, no subagent dispatch). Lane `kagi-shokunin`,
branch `master`, BASE `076701a11a58e3eb58d996b4c76c5e18071fb179`, frozen
predeclaration `plans/round-67.md` @
`aa8807e443166f45485e1aada2989f646efc707c` (operative amendments A1–A5 read;
A2.1, A2.3, A2.4 and A3 govern this check). Nothing committed, nothing staged,
no sibling lane or fleet path touched. Scratch root
`/fast/scratch/hyaku/kagi-r67/R67MutGate/` (deleted before yield; receipts
copied here first).

Report: `.ufo/waves/round-67/w1/R67MutGate.md`
Kill table + receipts: `.ufo/waves/round-67/w1/R67MutGate/` (`mutants.md`,
`M1-…`–`M7-…` with `mutation.diff`, `pristine/`, `matrix.tsv`,
`history-46de/`).

## Bytes under test

| item | value |
|---|---|
| file | `corpus/sources-census.sh` (lane working tree) |
| sha256 | `e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f` |
| size / lines | 58661 B / 966 lines |
| pristine `--selftest` | `SOURCES_CENSUS_SELFTEST: PASS (89 cases)`, exit 0 |
| candidate clean line (lane) | `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)` |
| BASE gate (git show `076701a`) | sha256 `e9ae2620ff4ad8e3122f8e7c04c19d16afccf03f0feec7c72edcce78bdd58252`, no `SC_CAPTURE`, `--selftest` 78 cases |

Provenance: the first run mutated the superseded snapshot `46de3d8c…`
(955 lines, 88 cases) and produced the same seven kills; its receipts are
under `history-46de/`. After `R67ExecGate` fixed the R67Revenger finding
(`stat -Lc %s`, new `capture-symlink-intree-control`, 89 cases) the run was
repeated on `e7aacecd…`; the table and every number below are from those
bytes. The lane file itself was never written by this seat; every mutation ran
on a scratch copy restored to the pristine sha256 afterwards.

`prose=121` is the amended population (A2.4/A3: S166 is registered with a
prose location and does not move `path_rows`/`bound`/`located`); guard (a)
compares the printed counts to the counter's derivation, not to a literal 120.

## Method

Seven mutants, each the pristine file with the smallest single-point change
that instates the assigned defect; every replacement asserted exactly one
anchor occurrence (anchor drift fails loudly rather than producing a different
mutant). Each mutant was installed as
`<scratch>/clean/corpus/sources-census.sh` (the script directory must hold the
sibling `rendered-text-v1.py`, as in the lane) and run against:

1. the gate's own `--selftest` — the primary detector;
2. `verify --root` on the assigned scratch tree with a **repointed capture**
   (`S113` col 16 → `S114.body`: 85138 B vs 90604 B, different digest);
3. seven supplementary one-defect trees on the same row: `samesize` (same byte
   count, one byte flipped), `quote` (non-locating col 13), `absolute`
   (`/etc/hostname`), `traversal` (`../outside.body`, absent), `escape`
   (`../outside.body` present with S113's exact bytes — the counter's m5 `..`
   leg), `truncate` (−1 byte), `delete`, and `counts` (location re-cut to prose,
   a legitimate 35-path-row tree).

Killed = observed behaviour differs from the pristine gate on the same tree
(selftest non-zero/FAIL; missing `SOURCES_CAPTURES: FAILED`; missing
`FINDING SC_CAPTURE id=S113 <expected reason>`; non-1 exit where pristine
exits 1). Restored the pristine bytes and re-checked the sha256 after every
mutant.

Pristine control on the same trees (full text in `R67MutGate/pristine/`):
clean `CLEAN (36/36/36/121)` rc 0; repoint `FAILED (defects=2, bound=35)`
bytes+digest rc 1; samesize `FAILED (defects=1)` digest rc 1; quote
`FAILED (defects=1, located=35)` quote-not-located rc 1; absolute/traversal/
escape `FAILED (defects=1)` outside-root rc 1; truncate `FAILED (defects=2)`
bytes+digest rc 1; delete `FAILED (defects=1)` missing rc 1; counts
`CLEAN (35/35/35/122)` rc 0. All five frozen reasons are witnessed on the
pristine bytes.

## Verdict

**All seven mutants killed; no survivor.** Full per-mutant evidence, diffs and
sha256 in `R67MutGate/mutants.md`.

| mutant | selftest | repointed capture | sharp witness | verdict |
|---|---|---|---|---|
| M1 length-only, no byte read | FAIL 8/89 (`capture-repoint` exit 0 want 1) | **CLEAN**, rc 0 | every defect tree CLEAN | KILLED |
| M2 digest dropped, size only | FAIL 2/89 (`capture-repoint` same-size case; `truncate` 1 not 2 findings) | FAILED, bytes only (no digest) | `samesize` CLEAN | KILLED |
| M3 quote → nonempty | FAIL 1/89 (`capture-quote-garbage`) | caught (bytes+digest) | `quote` CLEAN | KILLED |
| M4 constant `bound=36 located=36` | FAIL 83/89 (`clean` stage relation `bound ≤ path_rows`) | FAILED, true reasons | `counts`: `bound=36` with `path_rows=35` | KILLED |
| M5 prose as paths | FAIL 83/89 (`clean` exit 1 want 0) | clean: 121 findings | `CLEAN` line becomes `FAILED (defects=121, path_rows=157, prose=0)` | KILLED |
| M6 exit 0 with SC_CAPTURE | FAIL 8/89 (all capture cases exit 0 want 1) | FAILED printed, **rc 0** | all trees rc 0 | KILLED |
| M7 no realpath containment | FAIL 3/89 (`absolute`, `dotdot`, `symlink-escape`) | caught | `escape`/`traversal` CLEAN; `absolute` → wrong reason (`capture-missing`) | KILLED |

### Which frozen predicate guard would catch a survivor

Read from `plans/round-67-c1.sh` (sha256
`3aed2ac69722138e0a0ffbc2745003d040b56ebcef22c1fd549df17c08344ab0`; `EXPECT`
159, `leg_caught` 479, `guard_a` 677, `guard_b` 699, `guard_c` 731,
`guard_d` 755, `guard_e` 783, `guard_f` 804, `predicate_ok` 844). The counter
was not run as authority; these are its source terms.

| mutant | guard/leg that catches it | note |
|---|---|---|
| M1 | **caught 0/6** + guard (b) | clean line identical to pristine → guard (a) blind |
| M2 | **caught 5/6** (m1 repoint) + guard (b) | truncate/delete/absolute/dotdot/quote still caught |
| M3 | **caught 5/6** (m6 quote) + guard (b) | repoint still caught |
| M4 | **guard (b) only** | caught 6/6 and guard (a) pass; the true 36/36 equals the constants |
| M5 | guard (a) + guard (e) + guard (b) | 121 prose findings |
| M6 | **caught 0/6** (`rc == 1` term) + guard (b) | clean line identical; verdict string is right |
| M7 | **caught 4/6** (m4 absolute, m5 dotdot) + guard (b) | repoint unaffected |

### Ceilings (no survivor)

1. **M4 is caught only by the gate's own selftest.** On the real tree the true
   `bound/located` are 36/36, so a constant printer of 36/36 reproduces the
   clean line and passes guard (a), guards (c)–(f) and all six caught legs
   (`leg_caught` checks exit 1, FAILED verdict, `defects == len(findings)` and
   the expected reasons, not the printed bound/located). The landed selftest
   kills it twice: per-case `SOURCES_CAPTURES` assertions on 1-row fixtures and
   the structural relation `located ≤ bound ≤ path_rows`
   (`corpus/sources-census.sh:915-940`). If either were weakened,
   `C1_READTHROUGH` could read `bound=36 located=36 caught=6/6 guard=1` from a
   gate that prints constants. Countermeasure already present: keep both; a
   `path_rows=0` fixture (`capture-prose-skip`) is the cheapest discriminator.
2. **M1 and M6 are invisible on the clean tree.** Both print the exact frozen
   clean line; the witnesses are the selftest and the `rc == 1` term of
   `leg_caught`. The counter must keep the exit-code term (it does).
3. **Absolute `/…` locations are capture-intent** in the landed gate
   (Amendment A2.1; `cap_is_shaped` accepts `^/…`), wider than the original
   prose regex. This is load-bearing for the frozen absolute leg; it matches
   the counter's `ABS_SHAPE` and changes `path_rows` on an absolute-mutated tree
   (36 v 35). Clean tree unaffected (36/121).
4. Not probed (outside the seven assigned mutants): dropping only the absolute
   refusal while keeping the realpath test (M7's `absolute` witness shows it
   would surface as `capture-missing`, caught by the selftest case and the
   counter's m4 leg), and a stat/read race on the source tree.

## Freshness evidence (C1's read-through class)

Measured on the same fixture as the frozen counter, with plain commands:

- BASE gate (`e9ae2620…`) on the repointed tree: `SOURCES_CENSUS: CLEAN`,
  rc 0 (`R67MutGate/pristine/base-gate-repoint.txt`) — the do-nothing control
  is blind to the repointed capture, as frozen.
- candidate gate (`e7aacecd…`): the repointed tree prints
  `SOURCES_CAPTURES: FAILED (defects=2 path_rows=36 bound=35 located=35
  prose=121)` with `capture-bytes-mismatch` and `capture-digest-mismatch`;
  `SOURCES_CENSUS: FAILED (findings=2 rows=157)`, rc 1.
- the six frozen mutation classes are each detected with their expected reason
  on the candidate (`repoint`→digest, `truncate`→bytes, `delete`→missing,
  `absolute`/`dotdot`→outside-root, `quote`→quote-not-located), witnessed by
  the pristine control row above.

## Calibration notes

- The lane gate moved twice during the wave (`593504926f…` → `46de3d8c…` →
  `e7aacecd…`); this report pins the sha of every byte it mutated. The 46de
  run (same seven kills) is kept under `R67MutGate/history-46de/`; no
  conclusion here depends on it.
- Anchors are exact-string replacements with a one-occurrence assertion; the
  revenger's `stat -Lc` change and the new in-tree symlink control were
  re-derived against `e7aacecd…`, not approximated.
- S166 (A3) raises `prose` 120 → 121; the SC_CAPTURE classes are unchanged and
  M5 now reports one finding per prose row (121).

## Restoration / cleanliness

- pristine sha256 before the retest battery and after it:
  `e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f`
  (58661 B); per-mutant installed shas in `R67MutGate/M*/gate-sha.txt`.
- the lane `corpus/sources-census.sh` was never written by this seat; only the
  report and receipt paths above were created.
- scratch `/fast/scratch/hyaku/kagi-r67/R67MutGate/` deleted before yield.
- no tool installs, no network, no git mutation.
