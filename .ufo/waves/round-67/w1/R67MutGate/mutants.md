# R67MutGate — mutant kill table (round 67, w1)

Mutated file: `corpus/sources-census.sh`, lane working tree, sha256
`e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f`
(58661 B, 966 lines), the bytes `R67ExecGate` declared landed after the
R67Revenger finding (`stat -Lc %s` size resolution + new
`capture-symlink-intree-control` case; `--selftest` →
`SOURCES_CENSUS_SELFTEST: PASS (89 cases)`, exit 0).

Provenance: this is the second run. The first ran on the superseded snapshot
`46de3d8c…` (955 lines, 88 cases) and produced the same seven kills; its
receipts are kept under `history-46de/`. The retest on `e7aacecd…` was run at
`R67ExecGate`'s request after the revenger's byte change; the mutation anchors
were regenerated from the new bytes and every anchor asserted exactly one
occurrence.

Every mutant is a scratch copy of those bytes with the smallest single-point
change that instates the assigned defect. Mutants were installed as
`<scratch>/clean/corpus/sources-census.sh` (the script directory must hold the
sibling `rendered-text-v1.py`, exactly as in the lane). Per-mutant sha256 and
unified diff: `M*/mutation.diff`. The lane file was never written by this seat;
the scratch copy was restored to the pristine sha256 after every mutant.

Detection commands, run per mutant:

```
bash <scratch>/clean/corpus/sources-census.sh --selftest
bash <scratch>/clean/corpus/sources-census.sh --root <scratch>/<tree>
```

The second is the assigned "scratch tree with a repointed capture":
`S113` col 16 points at `.ufo/waves/round-55/capture/S114.body` (a different
body; 85138 B vs 90604 B, different digest). Supplementary defect trees, all
one defect on the same row; pristine control in `pristine/`:

| tree | defect | pristine `SOURCES_CAPTURES` | pristine rc |
|---|---|---|---|
| clean | candidate + S115 re-cut (and S166 prose row, A3) | `CLEAN (path_rows=36 bound=36 located=36 prose=121)` | 0 |
| repoint | S113 → S114.body | `FAILED (defects=2 path_rows=36 bound=35 located=35 prose=121)`; bytes+digest | 1 |
| samesize | S113 body, one byte flipped | `FAILED (defects=1 …bound=35…)`; digest only | 1 |
| quote | col 13 non-locating | `FAILED (defects=1 …located=35…)`; quote-not-located | 1 |
| absolute | col 16 `/etc/hostname` | `FAILED (defects=1 …bound=35…)`; outside-root | 1 |
| traversal | col 16 `../outside.body`, absent | `FAILED …`; outside-root | 1 |
| escape | `../outside.body`, present, S113's exact bytes | `FAILED …`; outside-root | 1 |
| truncate | body − 1 byte | `FAILED (defects=2 …)`; bytes+digest | 1 |
| delete | body removed | `FAILED …`; missing | 1 |
| counts | S113 location re-cut to prose | `CLEAN (path_rows=35 bound=35 located=35 prose=122)` | 0 |

`prose=121` is the amended-population value (A2.4/A3: S166 is registered with a
prose location and does not move `path_rows`/`bound`/`located`); the gate's four
counts equal this counter's derivation on the clean tree.

## Kill table

| # | mutant (defect) | sha256 | own `--selftest` | repointed-capture detector | sharp supplementary witness | verdict |
|---|---|---|---|---|---|---|
| M1 | length-only capture test restored, no byte read | `71a527dc…624ceef7` | **FAIL (89 cases, 8 failed)** — `capture-repoint` exit 0 want 1 | `SOURCES_CAPTURES: CLEAN` on the repointed tree, rc 0 (should be FAILED) | every defect tree CLEAN; clean-tree counts identical to pristine | **KILLED** |
| M2 | digest comparison dropped, size only | `4b91eaf0…5b7d8c99` | **FAIL (89 cases, 2 failed)** — `capture-repoint` (same-size body, digest reason absent), `capture-truncate-by-1` (1 finding, want 2) | `FAILED (defects=1 …)` but the only finding is `capture-bytes-mismatch`; `capture-digest-mismatch` absent | `samesize` tree reads `CLEAN` (blind to a same-length digest change) | **KILLED** |
| M3 | quote check replaced by "quote nonempty" | `7f43ce72…06d17641` | **FAIL (89 cases, 1 failed)** — `capture-quote-garbage` exit 0 want 1 | repoint still caught (bytes+digest) | `quote` tree reads `CLEAN` (garbage quote bound as located) | **KILLED** |
| M4 | constant printer of `bound=36 located=36` | `62a7e7b1…79763d7e` | **FAIL (89 cases, 83 failed)** — `clean` case fails the stage relation `bound ≤ path_rows` | repoint FAILED with correct reasons (findings are real; only the printed counts are constants) | `counts` tree: `CLEAN (path_rows=35 bound=36 located=36 prose=122)` — bound > path_rows, contradicts pristine 35/35/35 | **KILLED** |
| M5 | prose rows checked as paths (false-positive class) | `7e877c79…e670777b` | **FAIL (89 cases, 83 failed)** — `clean` case exit 1 want 0, 4 findings | clean tree: `FAILED (defects=121 path_rows=157 …prose=0)` | 121 `capture-missing` findings on prose rows | **KILLED** |
| M6 | exit 0 with an SC_CAPTURE finding present | `d265c5aa…6c9d7872` | **FAIL (89 cases, 8 failed)** — every capture case exit 0 want 1 | repoint prints `FAILED (defects=2 …)` but exits **0** | all six defect trees exit 0 while printing FAILED | **KILLED** |
| M7 | realpath containment dropped (absolute/traversal accepted) | `d91751f3…4d32c39f` | **FAIL (89 cases, 3 failed)** — `capture-absolute-location`, `capture-dotdot-location`, `capture-symlink-escape` | repoint still caught (in-tree body) | `escape` and `traversal` read `CLEAN` (outside body binds); `absolute` reports `capture-missing` instead of `capture-outside-root` | **KILLED** |

No mutant survived any detector. Every kill is against the gate's own
`--selftest`; the repointed-capture tree independently kills M1 and M6 outright
and shows M2/M3/M7 blind to their specific classes.

## Per-mutant evidence

### M1 — length-only capture test restored (no byte read)

`M1-length-only/mutation.diff`: the whole `cap_row` read-through removed and
replaced by the pre-round-67 length test `[[ ${#loc} -ge 8 ]]`; no `stat`, no
`sha256sum`, no `realpath`, no locate.

- selftest: `SOURCES_CENSUS_SELFTEST: FAIL (89 cases, 8 failed)`; the eight are
  `capture-repoint`, `capture-missing`, `capture-truncate-by-1`,
  `capture-absolute-location`, `capture-dotdot-location`,
  `capture-quote-garbage`, `capture-bytes-declared`,
  `capture-symlink-escape`; each `exit 0 want 1` with
  `last=SOURCES_CENSUS: CLEAN (...)`.
- repointed capture: `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36
  located=36 prose=121)`, `SOURCES_CENSUS: CLEAN`, rc 0.
- the clean-tree summary is byte-identical to pristine, so the clean line alone
  cannot distinguish M1: its witness is the selftest and every mutated tree.
- frozen-predicate backstop: `caught=0/6` (all six legs read CLEAN) → kill rule
  `caught < 6`; guard (b) also 0 (selftest FAIL).

### M2 — digest comparison dropped (size only)

`M2-size-only/mutation.diff`: `got=$(sha256sum …)` and the digest comparison
removed; `stat -Lc %s` size test retained.

- selftest: `capture-repoint` FAIL — the fixture repoint is a **same-size**
  sibling (`sed s/Audit/audit/` keeps the length), so with the digest test gone
  the row reaches the garbage-quote check and reports `quote-not-located`, not
  the expected `capture-digest-mismatch` (reason assertion at
  `corpus/sources-census.sh:906-913`); `capture-truncate-by-1` FAIL — one
  finding, the case expects two (`capture-bytes-mismatch,capture-digest-mismatch`).
- repointed capture (different size): `SOURCES_CAPTURES: FAILED (defects=1 …)`
  with only `FINDING SC_CAPTURE id=S113 capture-bytes-mismatch`.
- sharp witness: `samesize` (same byte count, one byte flipped) reads
  `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)`, rc 0
  — blind to the digest-only class by construction.
- backstop: `caught=5/6` — the m1 repoint leg (A2.3: a same-size, different-sha
  in-tree body; expected `capture-digest-mismatch`; `plans/round-67-c1.sh:159-167`
  and `leg_caught` at `:479-491`) fails; kill rule `caught < 6`; guard (b) 0.

### M3 — quote check replaced by "quote nonempty"

`M3-quote-nonempty/mutation.diff`: `[[ -z $q ]] || ! cap_locate …` becomes
`[[ -z $q ]]`; a non-empty quote now always passes.

- selftest: `case capture-quote-garbage: FAIL (exit 0 want 1; want SC_CAPTURE
  findings=1; last=SOURCES_CENSUS: CLEAN …)`.
- repointed capture: still `FAILED (defects=2 …)` with bytes+digest — M3 is not
  visible on that tree, which is why the garbage-quote tree is the assigned
  class witness.
- sharp witness: `quote` tree reads `CLEAN` (garbage quote counted as located).
- backstop: `caught=5/6` — the m6 quote leg fails; kill rule `caught < 6`;
  guard (b) 0.

### M4 — constant printer of `bound=36 located=36`

`M4-constant-counts/mutation.diff`: the two `SOURCES_CAPTURES` printfs print
literal 36 for `bound` and `located`; `path_rows`/`prose`/`defects` stay
computed.

- selftest: `FAIL (89 cases, 83 failed)`. The first failure is `case clean:
  FAIL (…)` — the harness's structural assertion
  `located ≤ bound ≤ path_rows` (`corpus/sources-census.sh:915-940`) holds
  36 ≤ 1 against the fixture's `path_rows=1`; every fixture with fewer than 36
  path rows fails the same way.
- clean tree: the printed line is byte-identical to pristine
  (`CLEAN (path_rows=36 bound=36 located=36 prose=121)`) because the true
  counts equal the constants.
- repointed tree: FAILED with the true reasons; the six caught legs pass
  (`leg_caught` checks exit 1, FAILED verdict, `defects == len(findings)` and
  the expected reasons on the mutated id — not the printed bound/located).
- sharp witness: `counts` tree (a legitimate 35-path-row tree) prints
  `CLEAN (path_rows=35 bound=36 located=36 prose=122)` — `bound > path_rows`
  and `bound/located` contradict the pristine 35/35/35.
- backstop: **guard (b) only**. Guard (a) (`plans/round-67-c1.sh:677-697`)
  compares the four printed counts to the counter's derivation (36/36/36/121
  here), so the constant matches; guard (e) is clean; `caught=6/6`. The landed
  selftest's per-case `SOURCES_CAPTURES` assertion and stage relation are the
  sole line of defence against this class — see Ceilings (1).

### M5 — prose rows checked as paths

`M5-prose-as-paths/mutation.diff`: the `cap_is_shaped` early return removed;
every fetch row enters the path branch.

- selftest: `FAIL (89 cases, 83 failed)`; `case clean: FAIL (exit 1 want 0;
  want CLEAN findings=0; last=SOURCES_CENSUS: FAILED (findings=4 rows=4))`,
  because the four fixture prose locations become `capture-missing`.
- clean tree: `SOURCES_CAPTURES: FAILED (defects=121 path_rows=157 bound=36
  located=36 prose=0)` and 121 `FINDING SC_CAPTURE id=<id> capture-missing`,
  one per prose row (120 BASE prose + S166, A3).
- backstop: guard (a) fails (clean verdict not CLEAN, counts differ), guard (e)
  fails (prose ids carry findings, `plans/round-67-c1.sh:783-797`), guard (b) 0.

### M6 — exit 0 with an SC_CAPTURE finding present

`M6-exit-zero-on-capture/mutation.diff`: before the final `exit 1`,
`[[ $CAP_DEFECTS -gt 0 ]] && exit 0`.

- selftest: `FAIL (89 cases, 8 failed)`; each capture case `exit 0 want 1`
  while `last=SOURCES_CENSUS: FAILED (findings=N rows=4)` — the verdict string
  is right, the status is wrong.
- repointed capture: `FAILED (defects=2 …)`, **rc 0**; every defect tree the
  same.
- backstop: `caught=0/6` — `leg_caught` requires `rc == 1`
  (`plans/round-67-c1.sh:479-491`); kill rule `caught < 6`; guard (b) 0.

### M7 — realpath containment dropped (absolute/traversal accepted)

`M7-no-containment/mutation.diff`: the absolute-location early refusal removed
and `[[ -z $rp || ( $rp != "$CAP_ROOT" && $rp != "$CAP_ROOT"/* ) ]]` weakened
to `[[ -z $rp ]]`.

- selftest: `FAIL (89 cases, 3 failed)` — `capture-absolute-location` (the
  fixture's absolute in-tree path now binds), `capture-dotdot-location`
  (2 findings where 1 expected, and not the outside-root reason),
  `capture-symlink-escape`.
- repointed capture: still caught (the repointed body is in-tree).
- sharp witnesses: `escape` (byte-identical body one level outside the tree,
  the counter's m5 `..` leg) and `traversal` read
  `SOURCES_CAPTURES: CLEAN`, rc 0; `absolute` reports
  `capture-missing` instead of `capture-outside-root` (the gate prefixes
  `CAP_ROOT` before resolution, so the absolute refusal, not realpath, is what
  classifies `/…`).
- backstop: `caught=4/6` — the m4 absolute and m5 dotdot legs fail; kill rule
  `caught < 6`; guard (b) 0.

## Ceilings / notes (no survivor)

1. **M4's blind spot is structural and is closed only by the gate's selftest.**
   On the real tree the true `bound/located` are 36/36, equal to the constants;
   guard (a) and all six caught legs accept M4. It is killed because the
   selftest asserts `SOURCES_CAPTURES` on small fixtures **and** enforces
   `located ≤ bound ≤ path_rows` (`corpus/sources-census.sh:915-940`). If either
   assertion were dropped, a constant `bound=36 located=36` printer would pass
   `C1_READTHROUGH` (guard=1, caught=6/6). Countermeasure, already in the
   landed bytes and kept after the revenger change: the per-case `xcap`
   assertion plus the stage relation; a `capture-prose-skip` case with
   `path_rows=0` is the cheapest discriminator.
2. **M1/M6 clean-tree lines are byte-identical to pristine.** A "no byte read"
   gate and an "exit 0 with findings" gate are invisible to guard (a) and to any
   reading of the clean tree; they are caught by guard (b) and by `rc == 1` in
   `leg_caught`. The counter must keep the exit-code term.
3. **Absolute locations are classified capture-intent** by `cap_is_shaped`
   (`^/…`), legalized by Amendment A2.1 and matched by the counter's
   `ABS_SHAPE`; it makes the frozen absolute leg catchable and changes
   `path_rows` on an absolute-mutated tree (36 v 35 under the narrow regex).
   The clean tree is unaffected (36/121, A3).
4. **`prose=121`, not 120, is the amended population** (A2.4/A3): S166's row is
   prose. The SC_CAPTURE classes are unchanged; M5 now reports 121 prose
   findings.
5. Not probed (outside the seven assigned mutants): dropping only the absolute
   refusal while keeping the realpath test (M7's `absolute` witness shows it
   would surface as `capture-missing`, caught by the selftest case and the
   counter's m4 leg), and a stat/read race on the source tree.

## Restoration evidence

- pristine before the retest battery:
  `e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f`
- per-mutant installed sha256: `M*/gate-sha.txt`
  (`71a527dc…`, `4b91eaf0…`, `7f43ce72…`, `62a7e7b1…`, `7e877c79…`,
  `d265c5aa…`, `d91751f3…`)
- pristine restored after every mutant; after the battery:
  `e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f`
  (same bytes), and the lane file was never modified by this seat.
- the superseded `46de3d8c…` run (same seven kills) is under `history-46de/`.
