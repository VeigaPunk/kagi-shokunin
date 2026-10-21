# ScribeCorrections — round-24 build: named corrections of round-23 wording

Seat: ScribeCorrections (scribe, leaf member, no subagent dispatch). Milestone: round-24 build
(host-safe ledger, legacy recapture, identity rows). Judged on operability, freshness, calibration.
Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin. This report is the only write.
Tool installs: none. No host-private, vault, account, or credential read. No gate, selftest, or
verifier was executed; every claim below is from source reading plus read-only git
(`git log`, `git show --stat`, `git ls-tree`, `git show <rev>:<path>`).

## Summary

Three named corrections are drafted. All are append-only: `plans/round-23.md`, the round-23 lesson,
and the fleet report are not rewritten. The integrator appends the text below to the round-24
record. `plans/round-24.md:75-77` already reserves these corrections; it names the two wording
corrections and does not name the status correction.

Quoting note: the literal string "consume the closure's decisions" does not occur in
`plans/round-23.md`. That plan wording is split across lines 9-10 ("Consume the non-author
closure's" / "decisions instead of self-certifying agreement"). The literal form occurs in
`corpus/lessons/round-23.md:9`, `corpus/lessons/round-23-verifier-spotcheck.md:146`, and
`plans/round-24.md:77`. The original lines are quoted verbatim below.

## 1. "commit tree" → working tree

Original, `plans/round-23.md:13` (verbatim):
```
   obligation, resolves every `fixed` pointer in the commit tree, and fails on a
```
Original, the same wording quoted by the verifier, `corpus/lessons/round-23-verifier-spotcheck.md:145-146`:
`plans/round-23.md still says "commit tree"` / `and "consume the closure's decisions", though the gate reads the working tree and consumes ids.`

Evidence (static, `corpus/closure-dispositions.py`):
- `:106` `def resolve_pointer(root, pointer, oid, kind)`; `:111` `target = root / rel`;
  `:112-113` `if not target.is_file(): return [("POINTER-MISSING", ...)]`. Filesystem only.
- `:378` `root = Path(".")`; `:390` `root = Path(argv[i])` under `--root DIR`.
- No git invocation in the file. The only `subprocess` (`:296-297`) sits in the selftest and runs
  the script against a temp root.
- `:41-43` bound: "a `fixed` pointer proves that a file exists at that path and contains the id
  token somewhere". The docstring never mentions a commit.
- Precedent not applied to the plan: `corpus/lessons/round-23.md:216-217` already reads
  "C1 resolves pointers against the working tree, never a commit tree". The plan line was never
  corrected.

Correction text (append to the round-24 record):
> **Correction R24-C1 (named; `plans/round-23.md:13`).** "in the commit tree" reads "in the working
> tree". `corpus/closure-dispositions.py` resolves each `fixed` pointer as a filesystem path under
> `--root` (default `.`): `root / rel` plus `is_file()` (`:111-113`, `:378`). It never invokes git.
> A pointer resolves when the file exists in the working tree, whether or not it is committed.
> This correction does not change the gate; it corrects the plan's description of it.

## 2. "consume the closure's decisions" → consumes obligation ids

Original, `plans/round-23.md:9-10` (verbatim):
```
9. **C1 calibration (capability acquisition).** Consume the non-author closure's
10:   decisions instead of self-certifying agreement: `corpus/closure-dispositions.py`
```
Original, the literal phrase as it appears elsewhere: `corpus/lessons/round-23.md:9`
`(consume the closure's decisions through a resolving disposition gate), C2`;
`corpus/lessons/round-23-verifier-spotcheck.md:146` `and "consume the closure's decisions", though
the gate reads the working tree and consumes ids.`; `plans/round-24.md:77`
`"consume the closure's decisions" — it consumes obligation ids).`

Evidence (static, `corpus/closure-dispositions.py`):
- `:41-43` "Obligations are the closure's id list, not the reviewer's verdicts; a `fixed` pointer
  proves that a file exists at that path and contains the id token somewhere".
- `:16` obligations become `D<N>`, `SPOT-<NN>`, and `ADJ`. These are ids parsed from the closure
  document by `parse_obligations` (`:78-103`).
- `:171-211` checks the lane's typed disposition rows against those ids (missing, duplicate,
  unknown). It reads no verdict text from the closure.
- `:8-9` "It never decides whether a fix is good -- it decides whether the lane recorded one and
  whether the record still resolves."

Correction text (append to the round-24 record):
> **Correction R24-C2 (named; `plans/round-23.md:9-10`).** "Consume the non-author closure's
> decisions" reads "Consume the non-author closure's obligation ids". The gate takes the closure's
> frozen id list (`D1`-`D9`, `SPOT-NN`, `ADJ`; `corpus/closure-dispositions.py:16`, `:78-103`) and
> requires one typed lane disposition per id. It does not read, compare, or certify the closure's
> verdicts (`:41-43`). Agreement is recorded only as the lane's typed disposition, which is not
> verified outside agreement.

## 3. Stale "uncommitted" sentence in the round-23 report

Original, `.ufo/reports/round-23/kagi.md:115-116` (fleet repo, committed at `00cfe25d`,
2026-10-21 01:34:58 -0300; `git show 00cfe25d:.ufo/reports/round-23/kagi.md` line 115 matches):
```
115:  for round 23 (attempt 1 was clean); other parent-built reports remain parent-owned
116:  and uncommitted by this lane.
```
The sentence is split across lines 115-116; the literal "remain parent-owned and uncommitted" does
not occur on a single line. The verifier already flagged it: `corpus/lessons/round-23-verifier-spotcheck.md:31-32`
and `:201-202` (D7).

Evidence (read-only git, kagi repo):
- At report time: `git ls-tree -r --name-only 8a4ecbbd -- .ufo/waves/round-23/parent-build | wc -l`
  → `1`. The lane tip was 19 s before the report, so the sentence was accurate when written.
- `git show --format='%H %ci %s' -s 46fac5a` → `46fac5a… 2026-10-21 02:24:03 -0300
  round-23: commit wave evidence (parent-build + falsify reports)`.
- `git show --name-status --format= 46fac5a -- .ufo/waves/round-23/parent-build` → 66 `A`.
- `git ls-tree -r --name-only 46fac5a -- .ufo/waves/round-23/parent-build | wc -l` → `67`;
  `find .ufo/waves/round-23/parent-build -type f | wc -l` → `67`. Every parent-build file is tracked.
- `46fac5a` also adds 63 falsify files and modifies 2 (`--name-status -- .ufo/waves/round-23/falsify`).

Correction text (append to the round-24 record; the fleet report is not edited):
> **Correction R24-C3 (named; `.ufo/reports/round-23/kagi.md:115-116`).** "other parent-built reports
> remain parent-owned and uncommitted by this lane" was accurate at its report commit `00cfe25d`
> (lane tip `8a4ecbbd` tracked 1 of 67 parent-build files). It is stale. Commit `46fac5a`
> (2026-10-21 02:24:03 -0300) committed the other 66 parent-build reports; all 67 are tracked at
> `46fac5a`. The fleet report keeps its original text; this correction governs it.

## 4. Other occurrences the integrator should know about (not in the three asked corrections)

- `corpus/closure-dispositions.py:2` module title repeats "a non-author closure's decisions into a
  machine-checked obligation set". Same overstatement as C2. A code-comment edit is outside this
  seat's scope.
- `corpus/lessons/round-23.md:8-9` repeats "consume the closure's decisions through a resolving
  disposition gate". Covered by R24-C2 by reference.
- `corpus/lessons/round-23-verifier-spotcheck.md:204-205` (D8) already asks for these names:
  "Plan wording ("commit tree", "consume decisions") should get a named correction rather than stand."
- `plans/round-24.md:75-77` already reserves R24-C1 and R24-C2 as named corrections. It does not
  reserve R24-C3, which is the status sentence in the fleet report.

## 5. Discrepancies found

- The literal "consume the closure's decisions" is not in `plans/round-23.md` (see quoting note).
  The plan's wording is split across lines 9-10.
- "remain parent-owned and uncommitted" is split across `kagi.md:115-116`, not on one line.
- The stale sentence was accurate when written and went stale at `46fac5a`. It is not a false
  claim at the report time.

## 6. Checks for the integrator (not run by this seat)

- `grep -n 'commit tree' plans/round-23.md` should still show line 13. The correction is appended,
  not applied in place.
- `sha256sum plans/round-23.md` should match its pre-round value. This confirms the append-only rule.
- Re-run `git ls-tree -r --name-only 46fac5a -- .ufo/waves/round-23/parent-build | wc -l` and the
  `find` count together. Both should read 67.

Report: .ufo/waves/round-24/build/ScribeCorrections.md
