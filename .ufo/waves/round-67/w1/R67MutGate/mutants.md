# R67MutGate — mutant kill table (round 67, w1)

Mutated file: `corpus/sources-census.sh`, lane working tree, sha256
`46de3d8c115ee121e0ae2a0fe55da34c7f821635a0f9ecb651e49f6e5498dbac`
(58024 B, 955 lines), the bytes `R67ExecGate` declared landed
(`--selftest` → `SOURCES_CENSUS_SELFTEST: PASS (88 cases)`, exit 0).

Every mutant is a scratch copy of those bytes with the smallest single-point
change that instates the assigned defect; replacements asserted exactly one
anchor occurrence. Mutants were installed as
`<scratch>/clean/corpus/sources-census.sh` (the script directory must hold the
sibling `rendered-text-v1.py`, exactly as in the lane). Per-mutant sha256 and
unified diff: `diffs/`. The lane file was never written by this seat; the
scratch copy was restored to the pristine sha256 after every mutant.

Detection commands, run per mutant:

```
bash <scratch>/clean/corpus/sources-census.sh --selftest
bash <scratch>/clean/corpus/sources-census.sh --root <scratch>/<tree>
```

The second is the assigned "scratch tree with a repointed capture":
`S113` col 16 points at `.ufo/waves/round-55/capture/S114.body` (a different
body; 85138 B vs 90604 B, different digest). Supplementary defect trees, all
one defect on the same row, derive their expected output from the pristine
control in `pristine/`:

| tree | defect | pristine `SOURCES_CAPTURES` | pristine rc |
|---|---|---|---|
| clean | candidate + S115 re-cut | `CLEAN (path_rows=36 bound=36 located=36 prose=120)` | 0 |
| repoint | S113 → S114.body | `FAILED (defects=2 path_rows=36 bound=35 located=35 prose=120)`; bytes+digest | 1 |
| samesize | S113 body, one byte flipped | `FAILED (defects=1 …bound=35…)`; digest only | 1 |
| quote | col 13 non-locating | `FAILED (defects=1 …located=35…)`; quote-not-located | 1 |
| absolute | col 16 `/etc/hostname` | `FAILED (defects=1 …bound=35…)`; outside-root | 1 |
| traversal | col 16 `../outside.body`, absent | `FAILED …`; outside-root | 1 |
| escape | `../outside.body`, present, S113's exact bytes | `FAILED …`; outside-root | 1 |
| truncate | body − 1 byte | `FAILED (defects=2 …)`; bytes+digest | 1 |
| delete | body removed | `FAILED …`; missing | 1 |
| counts | S113 location re-cut to prose | `CLEAN (path_rows=35 bound=35 located=35 prose=121)` | 0 |

## Kill table

| # | mutant (defect) | sha256 | own `--selftest` | repointed-capture detector | sharp supplementary witness | verdict |
|---|---|---|---|---|---|---|
| M1 | length-only capture test restored, no byte read | `056b022a…c026ee28` | **FAIL (88 cases, 8 failed)** — `capture-repoint` exit 0 want 1 | `SOURCES_CAPTURES: CLEAN` on the repointed tree, rc 0 (should be FAILED) | every defect tree CLEAN; identical counts to pristine on the clean tree | **KILLED** |
| M2 | digest comparison dropped, size only | `c69dabcf…43fade3a` | **FAIL (88 cases, 2 failed)** — `capture-repoint` (same-size body, digest reason absent), `capture-truncate-by-1` (1 finding, want 2) | `FAILED (defects=1 …)` but the only finding is `capture-bytes-mismatch`; `capture-digest-mismatch` absent | `samesize` tree reads `CLEAN` (blind to a same-length digest change) | **KILLED** |
| M3 | quote check replaced by "quote nonempty" | `38396a35…ad3b44b0` | **FAIL (88 cases, 1 failed)** — `capture-quote-garbage` exit 0 want 1 | repoint still caught (bytes+digest) | `quote` tree reads `CLEAN` (garbage quote bound as located) | **KILLED** |
| M4 | constant printer of `bound=36 located=36` | `a0c72592…64ffbe4f` | **FAIL (88 cases, 82 failed)** — `clean` case fails the stage relation `bound ≤ path_rows` | repoint FAILED with correct reasons (findings are real; only the printed counts are constants) | `counts` tree: `CLEAN (path_rows=35 bound=36 located=36 prose=121)` — bound > path_rows, contradicts pristine 35/35/35 | **KILLED** |
| M5 | prose rows checked as paths (false-positive class) | `10ead6ce…05afd5dd` | **FAIL (88 cases, 82 failed)** — `clean` case exit 1 want 0, 4 findings | clean tree: `FAILED (defects=120 path_rows=156 …prose=0)` | 120 `capture-missing` findings on prose rows | **KILLED** |
| M6 | exit 0 with an SC_CAPTURE finding present | `549a48ff…f9f86f00` | **FAIL (88 cases, 8 failed)** — every capture case exit 0 want 1 | repoint prints `FAILED (defects=2 …)` but exits **0** | all six defect trees exit 0 while printing FAILED | **KILLED** |
| M7 | realpath containment dropped (absolute/traversal accepted) | `e6f05de4…dcfc69cb` | **FAIL (88 cases, 3 failed)** — `capture-absolute-location`, `capture-dotdot-location`, `capture-symlink-escape` | repoint still caught (in-tree body) | `escape` and `traversal` read `CLEAN` (outside body binds); `absolute` reports `capture-missing` instead of `capture-outside-root` | **KILLED** |

No mutant survived any detector. Every kill is against the gate's own
`--selftest`; the repointed-capture tree independently kills M1 and M6 outright
and shows M2/M3/M7 blind to their specific classes.

## Per-mutant evidence

### M1 — length-only capture test restored (no byte read)

Diff `diffs/M1-length-only.diff`: the whole `cap_row` read-through removed and
replaced by the pre-round-67 length test `[[ ${#loc} -ge 8 ]]`; no `stat`, no
`sha256sum`, no `realpath`, no locate.

- selftest: `SOURCES_CENSUS_SELFTEST: FAIL (88 cases, 8 failed)`; the eight are
  `capture-repoint`, `capture-missing`, `capture-truncate-by-1`,
  `capture-absolute-location`, `capture-dotdot-location`,
  `capture-quote-garbage`, `capture-bytes-declared`,
  `capture-symlink-escape`; each `exit 0 want 1` with
  `last=SOURCES_CENSUS: CLEAN (...)`.
- repointed capture: `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36
  located=36 prose=120)`, `SOURCES_CENSUS: CLEAN`, rc 0.
- the clean-tree summary is byte-identical to pristine, so the clean line alone
  cannot distinguish M1: its witness is the selftest and every mutated tree.
- frozen-predicate backstop: `caught=0/6` (all six legs read CLEAN) → kill rule
  `caught < 6`; guard (b) also 0 (selftest FAIL).

### M2 — digest comparison dropped (size only)

Diff `diffs/M2-size-only.diff`: `got=$(sha256sum …)` and the digest comparison
removed; `stat` size test retained.

- selftest: `capture-repoint` FAIL — the fixture repoint is a **same-size**
  sibling (`sed s/Audit/audit/` keeps the length), so with the digest test gone
  the row reaches the garbage-quote check and reports `quote-not-located`, not
  the expected `capture-digest-mismatch` (reason assertion at
  `corpus/sources-census.sh:906-913`); `capture-truncate-by-1` FAIL — one
  finding, the case expects two (`capture-bytes-mismatch,capture-digest-mismatch`).
- repointed capture (different size): `SOURCES_CAPTURES: FAILED (defects=1 …)`
  with only `FINDING SC_CAPTURE id=S113 capture-bytes-mismatch`.
- sharp witness: `samesize` (same byte count, one byte flipped) reads
  `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)`, rc 0
  — the mutation is blind to the digest-only class by construction.
- backstop: `caught=5/6` — the `repoint` leg (expected
  `capture-digest-mismatch`, counter `plans/round-67-c1.sh:144-151`) fails; the
  counter's own repoint target `S148.body` is 39750 B against S164's 264946 B,
  so the same size-only path applies; kill rule `caught < 6`; guard (b) 0.

### M3 — quote check replaced by "quote nonempty"

Diff `diffs/M3-quote-nonempty.diff`: `[[ -z $q ]] || ! cap_locate …` becomes
`[[ -z $q ]]`; a non-empty quote now always passes.

- selftest: `case capture-quote-garbage: FAIL (exit 0 want 1; want SC_CAPTURE
  findings=1; last=SOURCES_CENSUS: CLEAN …)`.
- repointed capture: still `FAILED (defects=2 …)` with bytes+digest — M3 is not
  visible on that tree, which is why the garbage-quote tree is the assigned
  class witness.
- sharp witness: `quote` tree reads `CLEAN` (garbage quote counted as located).
- backstop: `caught=5/6` — the `quote` leg fails; kill rule `caught < 6`;
  guard (b) 0.

### M4 — constant printer of `bound=36 located=36`

Diff `diffs/M4-constant-counts.diff`: the two `SOURCES_CAPTURES` printfs print
literal 36 for `bound` and `located`; `path_rows`/`prose`/`defects` stay
computed.

- selftest: `FAIL (88 cases, 82 failed)`. The first failure is `case clean:
  FAIL (…)` — the harness's structural assertion
  `located ≤ bound ≤ path_rows` (`corpus/sources-census.sh:915-940`) holds
  36 ≤ 1 against the fixture's `path_rows=1`; every fixture with fewer than 36
  path rows fails the same way.
- clean tree: the printed line is byte-identical to pristine
  (`CLEAN (path_rows=36 bound=36 located=36 prose=120)`) because the true
  counts equal the constants.
- repointed tree: FAILED with the true reasons (the six caught legs would still
  pass: `leg_caught`, `plans/round-67-c1.sh:333-338`, checks exit/verdict/
  summary state/reason, not the printed counts).
- sharp witness: `counts` tree (a legitimate 35-path-row tree) prints
  `CLEAN (path_rows=35 bound=36 located=36 prose=121)` — `bound > path_rows`
  and `bound/located` contradict the pristine 35/35/35.
- backstop: **guard (b) only**. Guard (a) (`plans/round-67-c1.sh:530-546`)
  compares the print to the counter's own derivation, which is 36/36 on this
  tree, so the constant matches; guard (e) is clean; `caught=6/6`. The landed
  selftest's per-case `SOURCES_CAPTURES` assertion and stage relation are the
  sole line of defence against this class — see Ceilings (1).

### M5 — prose rows checked as paths

Diff `diffs/M5-prose-as-paths.diff`: the `cap_is_shaped` early return removed;
every fetch row enters the path branch.

- selftest: `FAIL (88 cases, 82 failed)`; `case clean: FAIL (exit 1 want 0;
  want CLEAN findings=0; last=SOURCES_CENSUS: FAILED (findings=4 rows=4))`,
  because the four fixture prose locations become `capture-missing`.
- clean tree: `SOURCES_CAPTURES: FAILED (defects=120 path_rows=156 bound=36
  located=36 prose=0)` and 120 `FINDING SC_CAPTURE id=<id> capture-missing`,
  one per prose row.
- backstop: guard (a) fails (clean verdict not CLEAN, line not the frozen one),
  guard (e) fails (prose ids carry findings, `plans/round-67-c1.sh:622-636`),
  guard (b) 0.

### M6 — exit 0 with an SC_CAPTURE finding present

Diff `diffs/M6-exit-zero-on-capture.diff`: before the final `exit 1`,
`[[ $CAP_DEFECTS -gt 0 ]] && exit 0`.

- selftest: `FAIL (88 cases, 8 failed)`; each capture case `exit 0 want 1`
  while `last=SOURCES_CENSUS: FAILED (findings=N rows=4)` — the verdict string
  is right, the status is wrong.
- repointed capture: `FAILED (defects=2 …)`, **rc 0**; every defect tree the
  same.
- backstop: `caught=0/6` — `leg_caught` requires `rc == 1`
  (`plans/round-67-c1.sh:333-338`); kill rule `caught < 6`; guard (b) 0.

### M7 — realpath containment dropped (absolute/traversal accepted)

Diff `diffs/M7-no-containment.diff`: the absolute-location early refusal
removed and `[[ -z $rp || ( $rp != "$CAP_ROOT" && $rp != "$CAP_ROOT"/* ) ]]`
weakened to `[[ -z $rp ]]`.

- selftest: `FAIL (88 cases, 3 failed)` — `capture-absolute-location` (the
  fixture's absolute in-tree path now binds), `capture-dotdot-location`
  (2 findings where 1 expected, and not the outside-root reason),
  `capture-symlink-escape`.
- repointed capture: still caught (the repointed body is in-tree).
- sharp witnesses: `escape` (byte-identical body one level outside the tree,
  the counter's `dotdot` leg) and `traversal` read
  `SOURCES_CAPTURES: CLEAN`, rc 0; `absolute` reports
  `capture-missing` instead of `capture-outside-root` (the gate prefixes
  `CAP_ROOT` before resolution, so the absolute refusal, not realpath, is what
  classifies `/…`).
- backstop: `caught=4/6` — the `absolute` and `dotdot` legs fail; kill rule
  `caught < 6`; guard (b) 0.

## Ceilings / notes (no survivor)

1. **M4's blind spot is structural and is closed only by the gate's selftest.**
   On the real tree the true `bound/located` are 36/36, equal to the constants;
   guard (a) and all six caught legs accept M4. It is killed because the
   selftest asserts `SOURCES_CAPTURES` on small fixtures **and** enforces
   `located ≤ bound ≤ path_rows` (`corpus/sources-census.sh:915-940`). If either
   assertion were dropped, a constant `bound=36 located=36` printer would pass
   `C1_READTHROUGH` (guard=1, caught=6/6). Proposed countermeasure, already in
   the landed bytes: keep the per-case `xcap` assertion and the stage relation;
   a `capture-prose-skip` case with `path_rows=0` is the cheapest discriminator.
2. **M1/M6 clean-tree lines are byte-identical to pristine.** A "no byte read"
   gate and an "exit 0 with findings" gate are invisible to guard (a) and to any
   reading of the clean tree; they are caught by guard (b) and by `rc == 1` in
   `leg_caught`. The counter must keep the exit-code term (it does).
3. **Absolute locations are classified capture-intent** by
   `cap_is_shaped` (`^/[A-Za-z0-9._][A-Za-z0-9._/-]*$`), wider than the frozen
   prose regex `^[A-Za-z0-9._][A-Za-z0-9._/-]*$`. This is load-bearing for the
   frozen `absolute` leg (otherwise `/etc/hostname` would be prose and never
   read) and matches the counter's `ABS_SHAPE`; it changes `path_rows` on an
   absolute-mutated tree from 35 to 36. The clean tree is unaffected
   (36/120). Recorded as an interface observation, not a defect.
4. Not probed (outside the seven assigned mutants): dropping only the absolute
   refusal while keeping the realpath test, and source-tree races between the
   stat and the read. M7's `absolute` witness shows the first would surface as
   `capture-missing` (wrong reason) and be caught by the
   `capture-absolute-location` case and the counter's `absolute` leg.

## Restoration evidence

- pristine before the battery: `46de3d8c115ee121e0ae2a0fe55da34c7f821635a0f9ecb651e49f6e5498dbac`
- per-mutant installed sha256: `gate-sha.txt` in each `M*/` directory (matches
  the sha in the kill table)
- pristine restored after every mutant; after the battery:
  `46de3d8c115ee121e0ae2a0fe55da34c7f821635a0f9ecb651e49f6e5498dbac`
  (same bytes), and the lane file was never modified by this seat.
