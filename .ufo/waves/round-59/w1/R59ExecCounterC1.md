# R59ExecCounterC1 — C1 instrument (`plans/round-59-c1-check.py`, `plans/round-59-c1.sh`)

Seat: executor, kagi round 59 wave 1. Write scope held: the two instrument files plus
receipts under `.ufo/waves/round-59/build/R59ExecCounterC1/` and this report. No lane
commit, no git/jj mutation anywhere, no writes outside scope. Tooling: nothing
installed or updated (python3 3.14.8, git, tar, coreutils as shipped).

## Frozen bytes

| file | sha256 |
|---|---|
| `plans/round-59-c1-check.py` | `6844c1d46545ca0f1bd9819128830717249480dadf0a7038bcc37ffba10a7743` |
| `plans/round-59-c1.sh` | `73a2fc68693a37ec62fcff80b2d46c33e76c86570d10f0c92cc8a1c21e56f2e3` |

Freeze history: first freeze `e6c079f6…` was amended after the pre-freeze battery's
`C1-F5` control caught a genuine I5 selection defect (below); the driver never changed.

## What the checker implements (§C1, predeclaration af7b6651)

- I1: last lesson line of the form `Registry <N> → <M> at the candidate` vs the row
  census of `corpus/SOURCES.md` derived at run time from the pinned revisions
  (`git show 1b13f5da…:corpus/SOURCES.md`, `git show be8705f8…:corpus/SOURCES.md`,
  each `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'`). No constant carries the
  117/120 facts; the hashes are data-source selectors only.
- I2: first unsigned integer after `corpus/source-fetches.tsv` on the last lesson line
  naming it vs `git diff 1b13f5da… be8705f8… -- corpus/source-fetches.tsv` lines
  starting `+S`.
- I3: (a) `CONTROL ` / `CONTROL C1-F` / `CONTROL C2-F` line counts derived from
  `.ufo/waves/round-58/controls/controls-prefreeze.txt` on the measured tree, all three
  stated on the last lesson line naming `controls-prefreeze.txt`; (b) the supplement
  names `C1-F10` and `C2-F4` and `.ufo/waves/round-59/final/supplement-receipt.txt`'s
  last non-empty line equals `SUPPLEMENT: match=2 mismatch=0` exactly.
- I4: `.ufo/waves/round-59/final/citation-gate-r59.txt`'s last non-empty line matches
  `CITATION_GATE: … unresolved=<U> …`; the last lesson line naming that path states
  `unresolved=<U>` with the same U.
- I5: the mission minutes derived from the driver-digest timestamps in
  `corpus/lessons/round-58-verifier-spotcheck.md` (11:54:48 → 13:36:19 = 101) and the
  word `progressing` must appear on the lesson's LAST `stale-lane:` line (case-
  insensitive), selected by subject alone.
- GUARD (in the checker, per the frozen predicate): all five items evaluated
  (population=5, tokens 0|1), then a scratch copy of the measured tree whose ONLY delta
  is the arrow digit M → M+1 on I1's last Registry line must make the checker print
  exactly value+1 (self re-run with `--no-challenge`, derivation context passed through
  hidden `--base-rev`/`--land-rev`), and a printer stub always printing
  `value=0 population=5` must FAIL that challenge (it is genuinely executed and
  parsed). Copy parent must resolve outside the measured root — at/inside → SETUP rc2
  (QM74); unwritable → guard=0 fail-closed. Copy excludes `.git`/`.jj`; the derivation
  repo travels via `--repo`.
- Output: five `c1:` evidence lines (each carrying the derived number it compared),
  then `C1_ROUTED: value=V|FAIL population=5 i1..i5 guard=G`; `--no-challenge` prints
  the diagnostic count with guard=0; `--json` prints one JSON object; exit 0 iff
  guard=1 and value=0, 1 otherwise, 2 SETUP.
- Driver `plans/round-59-c1.sh [revision] | --tree DIR`: materialises the tree under
  `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r59/R59ExecCounterC1/<tag>/tree`
  (`git archive` for a revision, tar copy excluding `.git`/`.jj` for `--tree`, copy
  target refuses to resolve at/inside the measured tree), runs the checker
  guard-bearing with `--repo <lane>`, prints its lines plus `c1-driver:` provenance;
  exit contract as frozen; BASE default `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`.
- `--selftest`: 33 cases over synthetic git-fixture trees (git init asserted toplevel
  == fixture), PASS rc=0.

## Measured evidence (receipts in `.ufo/waves/round-59/build/R59ExecCounterC1/`)

| receipt | reading |
|---|---|
| `driver-base-5fa6e658.txt` | BASE archive: `C1_ROUTED: value=FAIL population=5 i1=0 i2=0 i3=0 i4=0 i5=0 guard=0`, rc=1 — the frozen BASE census (K2 shape: value=5 in diagnostic) |
| `base-reading-current-tree.txt` | acceptance-time capture (pre-drift working tree): `value=5 population=5 … guard=0`; regenerated mid-repair capture: `value=3 population=5 i1=1 i2=1 i3=0 i4=0 i5=0 guard=0` |
| `base-guard-reading-current-tree.txt` | mid-repair working tree guard-bearing: `value=3 … guard=1` (I1 resolved → challenge fires 3→4, stub refused); at BASE the same leg reads `value=FAIL … guard=0` (challenge cannot fire — the plan's round-58 A4 reading) |
| `selftest.txt` | `C1_CHECK_SELFTEST: PASS (33 cases)` rc=0 |
| `reference-fixed-tree.txt` | scratch tree with the five fixes: `value=0 population=5 i1=1..i5=1 guard=1` rc=0, challenge `arrow 120->121: value=1 expect=1; stub value=0 fails=True` |
| `reference-forged-i2.txt` | same tree with D2 stating 7 vs derived 6: exactly `value=1 … i2=0 guard=1` (K1 shape) |
| `reference-f5probe.txt` | fixed tree + appended wrong `stale-lane:` (96 min): exactly `value=1 … i5=0` |
| `instruments-sha256.txt` | pins above + revision pins + no-tooling note |

## Frozen-condition readings where the wording allowed more than one structural read

1. **I5 selection** (the one real defect, caught by the battery): the frozen text says
   "carries a line matching `stale-lane:` … that states …" — literally existential. My
   first implementation put the correctness conditions inside the selection predicate,
   so a LATER wrong `stale-lane:` line left the item resolved and a forged tree read 0,
   which kill rule K1 (C1-F5) voids the claim on. Harmonized with §C1's named
   "last occurrence wins" convention: select the last `stale-lane:` line by subject,
   compare afterwards. Regression case + `reference-f5probe.txt` receipt pin it.
2. **I2 "first unsigned integer after the file name"**: first whole digit-run after the
   FIRST occurrence of the path on that line. Correction lines must place the delta
   integer immediately after `corpus/source-fetches.tsv` — a commit hash between the
   path and the number would be read instead.
3. **I3(a) "states all three counts"**: the line must contain each derived integer
   (20, 9, 7) as a whole digit-run; order and labels free. Note `C1-F`/`C2-F` labels
   themselves carry digits 1/2 — harmless for the real 20/9/7, but a correction line
   should state the numbers explicitly.
4. **I3(b) "ends with the line"**: the file's last NON-EMPTY line equals
   `SUPPLEMENT: match=2 mismatch=0` exactly (whitespace-stripped).
5. **I4**: the receipt's last non-empty line must contain `CITATION_GATE:` and
   `unresolved=<U>` (search on that line); the lesson's last line naming
   `citation-gate-r59.txt` must carry the same U as a `unresolved=<U>` digit-run.
6. **Input-less tree**: an item whose named file is absent reads UNRESOLVED (population
   stays 5) per "UNRESOLVED iff its named condition does not hold"; guard then reads 0.
   The plan's C1-F6 expectation "pop<5/FAIL" is satisfied via the FAIL branch.
7. **Guard firing condition**: guard=1 requires I1's last Registry line to be RESOLVED
   (the mutation must be able to break it). Trees with non-I1 items unresolved read
   `value=<n> … guard=1` (forged-i2 receipt), only I1-unresolved trees read
   `value=FAIL … guard=0`. This is the predicate's own semantics and is what the
   K1 forgery controls parse.

## Line-shape requirements for the repair seat (what still owes, per the checker's evidence at capture)

- I1 ✅ and I2 ✅ already verify on the current working tree against the git derivations.
- I3: the last lesson line naming `controls-prefreeze.txt` currently states only 20 —
  it must also state 9 and 7 as digit-runs; `.ufo/waves/round-59/final/
  supplement-receipt.txt` must END with the exact line `SUPPLEMENT: match=2 mismatch=0`
  (the supplement file already names C1-F10 and C2-F4).
- I4: the citation receipt's last line must match `CITATION_GATE: … unresolved=<U> …`
  (current file's last line does not parse), and the lesson needs its last line naming
  `citation-gate-r59.txt` to state the same `unresolved=<U>`.
- I5: the lesson needs its `stale-lane:` line carrying 101 and `progressing` (none yet).

## Risks / boundaries

- Working tree in flight: readings drift by design; the canonical BASE receipts are
  `driver-base-5fa6e658.txt` (deterministic archive) and the two reference trees.
- The guard's challenged self-run passes its derivation context through hidden flags —
  mutation testing should keep `--base-rev`/`--land-rev` intact.
- `--repo` resolution order: explicit arg → measured root's `.git` → the lane the
  instrument ships in; batteries running the checker on scratch copies without `.git`
  should pass `--repo` explicitly (the driver always does).
- Session tooling quirk: several bash calls completed correctly on disk but reported
  empty output / rc=1 (reported via the QA channel); every affected receipt was
  verified by a follow-up read — the files above are the evidence, not the lost stdout.
- Scratch used: `/fast/scratch/hyaku/kagi-r59/R59ExecCounterC1/` (deleted before
  yield); no citable evidence lives outside the lane.

SEAT-STATUS: complete
