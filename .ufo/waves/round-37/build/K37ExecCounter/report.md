K37ExecCounter — kagi round 37 (attempt 1), wave build
Seat: executor, C2 freshness counter measurement and fail-closed controls
Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (branch master)
Candidate: 9efcea722bdcf19dbbebf558e0172fafa565ae15
BASE: 911ab519b6b07694c3cb9f7d9a7c56e142ad957c
Predeclaration (frozen counter/receipt blobs): 04489d4184edb25a01ec8983b3ccedb45c683564
Receipt sha256 (pinned): cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203

Scratch: /fast/scratch/hyaku/kagi-r37/K37ExecCounter (removed before yield)

== 0. Setup checks (executed)

Command: git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse HEAD 911ab519... 9efcea7
Output:
  9efcea722bdcf19dbbebf558e0172fafa565ae15   (HEAD)
  911ab519b6b07694c3cb9f7d9a7c56e142ad957c   (BASE)
  9efcea722bdcf19dbbebf558e0172fafa565ae15   (9efcea7)

Command: sha256sum <lane>/.ufo/waves/round-37/controls/observe-r37.json
Output: cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203  (matches pin)

== 1. Extractions (executed)

  git -C <lane> archive 9efcea722bdcf19dbbebf558e0172fafa565ae15 | tar -x -C $S/cand
  git -C <lane> archive 911ab519b6b07694c3cb9f7d9a7c56e142ad957c | tar -x -C $S/base

- cand: the committed receipt was already in the archive at .ufo/waves/round-37/controls/observe-r37.json.
  A copy of the lane receipt was placed over it: `cmp` against the lane file printed nothing-differs (CMP-CAND-IDENTICAL).
- base: the receipt and the counter did NOT exist at 911ab51 (the counter was added after BASE). Per the
  assignment, the lane receipt was copied into base/.ufo/waves/round-37/controls/, and the frozen counter
  plans/round-37-c2.sh was copied from the candidate extraction into base/plans/ (COPIED-FROZEN-COUNTER-TO-BASE).
  The counter is byte-identical to the frozen blob at 04489d4 and 9efcea7 (see §5). The BASE measurement
  therefore uses the frozen instrument over BASE's SOURCES.md, which is the claim's BASE definition.
- sha256 of the receipt copy in both extractions: cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203.

== 2. Main runs (executed)

Command: cd <cand> && bash plans/round-37-c2.sh
  stdout: 0
  stderr: (empty)
  exit:   0

Command: cd <base> && bash plans/round-37-c2.sh
  stdout: 3
  stderr: (empty)
  exit:   0

Re-run at the end of the session (same commands): cand -> "0", rc=0; base -> "3", rc=0.

Verdict vs claim (BASE 3, target 0): MATCHES. Candidate reads 0; BASE reads 3.

== 3. Setup / fail-closed controls (executed)

Setup A — receipt removed (copy of the candidate extraction; file deleted):
  Command: cd <cand-norec> && bash plans/round-37-c2.sh
  stdout: (empty)
  stderr: C2 SETUP: receipt missing or sha mismatch
  exit:   2
  Result: exit 2, no integer on stdout. PASS (expected).

Setup B — one trailing space appended to the receipt (copy of the candidate extraction):
  Command: printf ' ' >> <cand-space>/.ufo/waves/round-37/controls/observe-r37.json; cd <cand-space> && bash plans/round-37-c2.sh
  stdout: (empty)
  stderr: C2 SETUP: receipt missing or sha mismatch
  exit:   2
  Result: exit 2, no integer on stdout. PASS (expected).

Note on Setup B: the stderr text says "missing or sha mismatch" for both A and B; the script does not
distinguish the two causes. This is the script's single fail-closed message, as written in the frozen counter.

== 4. Counter probe — S089 anchor names v2.2.0 (executed; probe of the counter, not a claim change)

Copy of the candidate extraction; in corpus/SOURCES.md row S089 only, every occurrence of "v2.2.1" in the
anchor cell (column 6) was replaced with "v2.2.0". The source cell and all other cells were unchanged.
  Anchor before: Entry titled v2.2.1, tag link /releases/tag/v2.2.1, first stable entry at byte offset 726;
  Anchor after : Entry titled v2.2.0, tag link /releases/tag/v2.2.0, first stable entry at byte offset 726;

  Command: cd <cand-anchor> && bash plans/round-37-c2.sh
  stdout: 1
  stderr: (empty)
  exit:   0

Evidence the single stale surface is vault: the rows the counter sees under the vault URL in the probe tree are
  S034 anchor: Entry titled v2.2.0, tag link /releases/tag/v2.2.0, updated 2026-10-15  (superseded row, unchanged)
  S089 anchor: Entry titled v2.2.0, tag link /releases/tag/v2.2.0, first stable entry  (probe edit)
Neither names 2.2.1, so the vault surface is held as stale; openbao (S090, v2.7.2) and python (S091, 3.15.2)
still hold, so the count is 1. Expected 1 (vault only): MATCHES.

Probe construction note (recorded, not hidden): my first probe attempt replaced only the "Entry titled v2.2.1"
phrase. It still read 0 because the anchor cell also carries "/releases/tag/v2.2.1", which the counter matches.
The first attempt was discarded; the reported probe above edits every v2.2.1 in the anchor cell. The first
attempt's result (stdout 0, rc 0) is therefore an artifact of my edit, not a counter result.

== 5. Frozen-file and mutation checks (read-only, executed)

Command: git -C <lane> diff --stat 04489d4 9efcea7 -- plans/round-37-c2.sh .ufo/waves/round-37/controls/observe-r37.json
  (no output), diff-rc=0  -> counter and receipt unchanged between predeclaration and candidate.
Command: git rev-parse 9efcea7:plans/round-37-c2.sh 04489d4:plans/round-37-c2.sh
  9beb0844d987bb466b75431a54038aed750e1974 (both) -> identical blob.
Command: git rev-parse 9efcea7:.ufo/waves/round-37/controls/observe-r37.json 04489d4:...observe-r37.json
  5a2e541fc3e81e9aac86d2dcdeada13b0a5cf395 (both) -> identical blob.
Command: grep -c -E "^\|? ?\*?S0(34|35|39) " <cand>/corpus/SOURCES.md
  3 -> S034, S035, S039 rows still present in the candidate (not deleted; supersession by new rows).
S034 row: `diff` of the S034 line between BASE and candidate SOURCES.md -> identical (S034-IDENTICAL).
Lane tracked-state: `git status --porcelain` shows only untracked entries under .ufo/waves/round-37/ and
plans/round-37.controls.tsv.tmp (not written by this seat; present before this seat's writes, from other seats/L1).
This seat wrote nothing into the lane tree except this report file and its seat copy.

== 6. Tooling

No tools installed. Used: bash, git (read-only: rev-parse, archive, diff, status), tar, sha256sum, cmp, python3 (stdlib
re, for editing scratch copies only), grep, cp -a. No pacman, no uv tool, no npm installs.

== 7. Observations for the reviewers (not verdicts)

- The frozen counter's anchor pattern matches a bare version anywhere in the anchor cell, so a version
  in the tag link satisfies it the same as in the title. This is the claimed predicate ("anchor cell names the
  receipt parsed_version"); it is consistent with the probe above.
- The counter does not verify that a row's quote is located in the fetched bytes; the plan names that as the
  Gate's job and the reviewer re-fetch's job, not the counter's. This seat did not re-fetch the feeds.
- The fail-closed message does not distinguish a missing receipt from a sha mismatch (see Setup B).
- The frozen counter file is not present at the BASE commit, so "BASE measured with the frozen counter" means
  the frozen counter was run over BASE's SOURCES.md with the same receipt, not a BASE-committed counter.

== 8. Summary table

| run | tree | stdout | stderr | exit | expected | result |
|---|---|---|---|---:|---|---|
| main | candidate 9efcea7 | 0 | - | 0 | 0 | PASS |
| main | BASE 911ab51 | 3 | - | 0 | 3 | PASS |
| setup A | candidate, receipt removed | - | C2 SETUP: receipt missing or sha mismatch | 2 | exit 2, no int | PASS |
| setup B | candidate, receipt + 1 space | - | C2 SETUP: receipt missing or sha mismatch | 2 | exit 2, no int | PASS |
| probe | candidate, S089 anchor -> v2.2.0 | 1 | - | 0 | 1 (vault only) | PASS |
| frozen-file | 04489d4 vs 9efcea7 | - | - | - | identical blobs | PASS |

COUNTER VERDICT: AGREE
