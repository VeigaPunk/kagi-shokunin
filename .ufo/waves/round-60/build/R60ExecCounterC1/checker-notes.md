# R60ExecCounterC1 — checker notes (plans/round-60-c1-check.py)

Instrument: `plans/round-60-c1-check.py` (C1_ROUTED counter, kagi round 60, §C1 **as
amended by §A5**, commit b662e114, **and §A6** — the scope receipt's token prefix is
`ADJACENCY_SCOPE:`, the scope gate's own verdict token). Driver:
`plans/round-60-c1.sh` (unchanged). Claim BASE `a677c78ece8e3d3b4a43dda55254f2a7b33cc1d2`.
Final sha256: checker `52d4fd5c6660e6a9235ae6cbf7e4e504c245b06cc6aa871fa83df721489fa658`,
driver `c11da5c60db536c97ef3e22c0f2d6ab0704e56b1508ce6e93a65847d0e39d599`.

Every compared number is derived at run time from the measured tree; no constant in
the checker restates a fact the tree asserts. The literals that remain are the frozen
predicate's own anchors (paths, `R31`, `SCORECARD.md:1971`, `21 controls`, heading/phrase
literals, the §A5 needle).

## Per-item derivation (§A5-amended)

### I1 — LOG.md round-59 correction block (§A5 1)
- Anchor: last `LOG.md` line containing the literal `__DEAD__`.
- Block: the LAST block after that anchor whose first line matches
  `^## Round 59 — correction` (em-dash U+2014); block ends at the next `^## ` heading
  or EOF. The block must name `w1-results.json`.
- Statement: the LAST line in the block matching the SHAPE
  `results=<R> dead=<D>`; ITS R,D must equal the derived census. A later wrong
  restatement in the same block breaks the item (C1-F1's class).
- Derived: `R` = `len(json.load(.ufo/waves/round-59/w1-results.json)["results"])`;
  `D` = count of those results whose `output` is absent or empty/whitespace. BASE `14 0`.
- GUARD: mutates the dead-seats digit of that SAME evaluated line, D → D+1 (0 → 1 at
  the round-59 census), preserving the `dead=`/`dead seats=` label (see the deviation
  note below).

### I2 — round-59 lesson R31 supersedes (§A5 2)
- Anchor: the LAST line whose first table cell is the routed id `R31`
  (row regex `^\| *R31 *\|`). Earlier prose mentions of `R31` do not relocate it.
- Statement: the LAST line after the anchor naming `C1_CHECK_SELFTEST`; it must match
  `supersedes R31` and contain the derived case count as a whole number.
- Derived count: the N of the LAST `C1_CHECK_SELFTEST: PASS (N cases)` line of
  `.ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt` (BASE 33).

### I3 — round-60 lesson routed dispositions (unchanged by §A5)
- `corpus/lessons/round-60.md` exists; its `## Routed dispositions` section's first
  contiguous `|`-table: first-cell `R[0-9]+` tokens ≥3 distinct with max occurrence 1;
  some lesson line names `R20`, `R21`, `R22` and the word `duplicate` (case-insensitive).

### I4 — SCORECARD controls count (unchanged by §A5)
- Derived N: `grep -cE '^CONTROL ' .ufo/waves/round-59/controls/controls-prefreeze.txt`
  (BASE 20). Anchor: LAST `SCORECARD.md` line matching `\(21 controls`; statement: the
  LAST later line matching `supersedes SCORECARD.md:1971`, which must contain
  `<N> controls` (whitespace-flexible).

### I5 — gate-evidence pointer supersedes (§A5 3)
- Anchor: LAST `SCORECARD.md` line matching `supersedes the round-59 gate-evidence
  pointer`. It must name three DISTINCT repo-relative paths under
  `.ufo/waves/round-60/final/` (basenames containing `release-clock`, `doc-audit`,
  `scope`; trailing `,;:.` stripped; containment enforced; a symlinked receipt is a
  problem). Each named file's LAST non-empty line must carry its token prefix
  (`RELEASE_CLOCK:`, `DOC_AUDIT:`, `ADJACENCY_SCOPE:` — §A6) AND at least one numeric
  `key=value` field (`[A-Za-z_][A-Za-z0-9_]*=\d+`) — a one-line stub fails. The line
  must state `never written`.

### I6 — measured-commit citation supersedes (§A5 4)
- Requires a SCORECARD.md line matching `supersedes the round-59 measured-commit
  citation` (LAST such line) that names `c1-landed.txt` AND contains
  `measured=revision <hash>` with hash equal to the value derived from the LAST
  `c1-driver: measured=revision <40hex>` line of
  `.ufo/waves/round-59/final/c1-landed.txt` (BASE `160caf750dcf15892b78ec066e66bc605ba57a5c`).
- The first-written `75165a07` anchor is gone (unsatisfiable at BASE).

### I7 — transit trial selftest, shown able to fail (§A5 5)
- Leg A: `bash <tree>/corpus/openbao-transit-trial.sh --selftest` (cwd=<tree>, 90 s
  timeout) exits 0 with `TRANSIT_SELFTEST: PASS (cases=N)`, N ≥ 6.
- Leg B: SKILL.md gate-registry row (columns found by header name; LAST row whose name
  cell contains `openbao-transit-trial.sh`) carries `--selftest` in its selftest cell
  and the row no longer carries `none — its own five shims`.
- Leg C: copy the trial to the challenge scratch, apply the single mutation
  `then S=BROKEN; rc=1;` → `then S=BROKEN; rc=0;` (needle must occur exactly once —
  0 or >1 fails closed), run the copy's `--selftest`, and require exit non-zero plus at
  least one `FINDING TRANSIT-ST-` line. A PASS printer has no needle → fails closed.
- Any missing script / timeout / non-zero exit / N < 6 / undetected mutation ⇒ I7
  UNRESOLVED (never SETUP).

## Checker hardening (§A5 6)

A tree whose `LOG.md`, `corpus/lessons/round-59.md`, `corpus/lessons/round-60.md`,
`SCORECARD.md`, `.ufo/waves/round-59/w1-results.json`,
`.ufo/waves/round-59/build/R59ExecCounterC1/selftest.txt`,
`.ufo/waves/round-59/controls/controls-prefreeze.txt` or
`.ufo/waves/round-59/final/c1-landed.txt` is a symlink is refused with
`C1_ROUTED: SETUP <path> is a symlink (refused)` rc 2 (checked on every evaluation).
Item5 additionally fails on a symlinked named final receipt. The challenge copy still
materialises symlinks (`copytree symlinks=False`, R22/M58-3 class) as defence in depth.

## GUARD

- Population 7, none skipped; value = count of UNRESOLVED items.
- Challenge: fresh `mkdtemp` under `C1_CHALLENGE_PARENT` → `HYAKU_SCRATCH` → `TMPDIR` →
  `/fast/scratch/hyaku` (no hardcoded `/tmp`); QM74 refuses a scratch at/inside the
  measured root (SETUP rc 2, checked in both modes); an unavailable scratch ⇒ guard=0.
- Delta: on the evaluated (LAST) I1 correction line only, the dead-seats digit D → D+1;
  re-run `--no-challenge` on the copy must print exactly value+1; a printer stub always
  printing `value=0` must fail that same challenge. GUARD=1 iff population=7 ∧
  challenge_ok ∧ stub_fails.
- **Deviation from the frozen GUARD literal, stated not silent:** the GUARD text says
  "the `dead seats=<n>` field" while I1's condition writes `dead=<D>`; the checker reads
  that count tolerantly (`dead=` or `dead seats=`) and mutates that digit. A strict
  `dead=`-only reading would make a guard-conforming `dead seats=` line unresolved and
  GUARD un-fireable. Numeric comparison unchanged. Recorded here, in the docstring, and
  coordinated with R60ExecFixRecords (their landed `results=14 dead seats=0` resolves I1).

## Selftest

`python3 -I -B plans/round-60-c1-check.py --selftest` builds its own fixtures in a temp
dir and prints `C1_CHECK_SELFTEST: PASS (46 cases)` (receipt `selftest.txt`). Coverage
includes: all-resolved reads 0 guard=1; all-unresolved reads 7; each of the seven items
resolving alone; satisfied-text-but-false-substance; after-the-wrong-line; missing and
malformed receipts; absent I7 script; I7 cases<6 / exit≠0 / PASS-printer-without-needle /
undetected mutation / registry row still carrying `none — its own five shims`; I1 later
restatement inside the block (last-statement-wins); I2 decoy anchor / misplaced
correction / later wrong restatement; I5 one-line stub receipts; I6 absent and
wrong-hash stating lines; I4 duplicate correction (last wins); I3 duplicate id; challenge
+1 firing on a tree with unresolved items; QM74 refusal; symlinked LOG.md refused with
SETUP (target file untouched); SETUP on a missing root.
