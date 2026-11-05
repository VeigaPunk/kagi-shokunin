# K37ExecEvidence — kagi round 37, attempt 1: evidence gates at candidate 9efcea7

Seat: K37ExecEvidence (executor, leaf, wave `build`). Read-only. Every gate ran in a `git archive` extraction; the lane tree was not written.

- Candidate: lane commit `9efcea722bdcf19dbbebf558e0172fafa565ae15` (short `9efcea7`).
- BASE: `911ab519b6b07694c3cb9f7d9a7c56e142ad957c`.
- Predeclaration (frozen counter, controls): `04489d4184edb25a01ec8983b3ccedb45c683564`.
- Scratch: `/fast/scratch/hyaku/kagi-r37/K37ExecEvidence` (deleted before yield; peak 279 MB).

## 0. Setup and identity

| command | exit | output |
|---|---:|---|
| `S=/fast/scratch/hyaku/kagi-r37/K37ExecEvidence; mkdir -p "$S"` | 0 | (first attempt, with the `cwd` set to the not-yet-existing scratch, failed with `Working directory does not exist`; nothing was extracted; re-run after `mkdir -p`) |
| `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 9efcea7 \| tar -x -C "$S"` | 0 | `ARCHIVE_OK` |
| `git -C <lane> rev-parse 9efcea7^{commit}` | 0 | `9efcea722bdcf19dbbebf558e0172fafa565ae15` |
| `git -C <lane> rev-parse 911ab519b6b07694c3cb9f7d9a7c56e142ad957c^{commit}` | 0 | `911ab519b6b07694c3cb9f7d9a7c56e142ad957c` |
| `sha256sum "$S/.ufo/waves/round-37/controls/observe-r37.json"` | 0 | `cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203` (matches the pin in the counter) |
| `git -C <lane> archive 04489d4… \| tar -x -C $S/base` | 0 | predeclaration tree for the BASE contrast |

## 1. `python3 corpus/self-counts.py` (extraction of 9efcea7)

Command: `TMPDIR=$S python3 corpus/self-counts.py` → **exit 2**.
Final line: `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`

- `stale=0`: **no stale row**; no row id to name.
- POLICY rows, exactly the two expected:
  - `POLICY PV-FEEDTOKEN-SHAPES ledger:R29-02 command not allowlisted`
  - `POLICY PV-FEEDTOKEN-SELFTEST ledger:R29-01 command not allowlisted`
- Exit 2 is the documented POLICY/SETUP code (`corpus/self-counts.py` header: "Exit: 0 CLEAN; 1 STALE (including UNLOCATED/AMBIGUOUS); 2 POLICY/SETUP"). It is not a stale count and is the operator-owned state (R29-01/R29-02). Reported as-is, not treated as a pass.

## 2. `bash corpus/sources-census.sh --selftest` (extraction)

Command exit **0**. Final line: `SOURCES_CENSUS_SELFTEST: PASS (70 cases)`.
Sample of the 70 `case … ok` lines: `case clean: ok (exit 0, CLEAN)`, `case dup: ok (exit 1, SC_DUP)`, `case cred-vault: ok (exit 1, SC_CREDENTIAL)`, `case setup-root-noarg: ok (exit 2, SETUP)`, `case fetch-disagree: ok (exit 1, SC_FETCH)`, `case inrow-nonreproducing-counted: ok (exit 0, CLEAN_NONREP)`.

## 3. `bash corpus/claim-ledger.sh docs` (extraction)

Command exit **0**. Final line:
`DOC_AUDIT: CLEAN (entries=35 row_linked=32 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`
Preceding ratio line: `DOC_AUDIT_RATIO: row_linked=32/35 floor=18 by_hand=3 duplicate_reasons=0`.
Knowledge entries are unchanged this round; exit 0 is a clean result, nothing hidden.

## 4. Not run, by instruction

- `claim-ledger.sh verify` and `claim-ledger.sh cells` were **not run** (minutes-long; already POLICY at BASE per the assignment). Nothing is claimed about them here.
- The fleet census `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` was not run by this seat (not in the assignment list; the lane census below is run instead).

## 5. The '88' audit (SKILL.md, PROVINCE.md, corpus/README.md)

Commands (extraction, `grep -n '88'`):

- `SKILL.md` → **no matches**, exit 1. Zero hits.
- `PROVINCE.md` → one hit, exit 0:
  - `58: - ` `~/.local/bin/tac-check` (755, 88 lines)` — a file line count for the tac-check script. Not a registry count.
- `corpus/README.md` → five hits, exit 0:
  - `22: … ~/.local/bin/tac-check (88 lines) …` — file line count. Not a registry count.
  - `54: … 888 cells × 32+5 patterns …` — transcript-scan cell count. Not a registry count.
  - `65: … 112 rows (104 at round 32, … 88 at round 25, …)` — historical stamp-row history; the current stamp count is 112. Not a registry count.
  - `98: … source S088 historical/current boundary …` — row id, not a count.
  - `127: … own-work row S088 …` — row id, not a count.

Verdict on the audit: **no current-tense count in the three files says 88 registry rows.** The current registry count is 91: `grep -cE '^\|\s*S[0-9]{3,}\s*\|' corpus/SOURCES.md` → `91`, which agrees with the census `rows=91` in §9.

## 6. Frozen C2 counter `bash plans/round-37-c2.sh`

| tree | command | stdout | exit |
|---|---|---:|---:|
| candidate `9efcea7` (extraction) | `bash plans/round-37-c2.sh` | `0` | 0 |
| predeclaration `04489d4` (BASE contrast) | `bash plans/round-37-c2.sh` | `3` | 0 |
| BASE `911ab51` (counter copied in from 9efcea7 and the receipt, with the same sha; the counter is not in 911ab51) | `bash plans/round-37-c2.sh` | `3` | 0 |

Note: `git archive 911ab51 -- plans/round-37-c2.sh` fails (`fatal: pathspec 'plans/round-37-c2.sh' did not match any files`), because the counter is committed at 04489d4, not 911ab51. The 911ab51 value was therefore obtained by copying the frozen counter and receipt into a 911ab51 extraction, which is the same predicate on the BASE SOURCES.md.

Counter fires on the three frozen surfaces: BASE 3 (vault S034 `v2.2.0`; openbao S035 `v2.7.1`; python S039 `3.15.1`), candidate 0.

## 7. Frozen controls, re-executed (not read from the lane's log)

The battery `plans/round-37-controls.sh MODE` was run with `BASE=$S/base` (the 04489d4 extraction) and `HYAKU_SCRATCH=$S/hs`. Each mode builds its fixture in its own scratch copy and runs the frozen counter.

| control | frozen expect | re-run rc | re-run out | match |
|---|---:|---:|---:|---|
| `nowork` (HEAD tree, no fix) | 3 | 0 | 3 | yes |
| `g1` (vault row with superseded `v2.2.0`) | 3 | 0 | 3 | yes |
| `g2` (current openbao version under the vault URL) | 3 | 0 | 3 | yes |
| `g3` (current vault version only in `knowledge/`) | 3 | 0 | 3 | yes |
| `partial` (vault row only) | 2 | 0 | 2 | yes |
| `full` (all three current rows) | 0 | 0 | 0 | yes |

Setup controls, re-executed on copies of the base tree:

| control | command | rc | output |
|---|---|---:|---|
| receipt removed | `rm observe-r37.json; bash plans/round-37-c2.sh` | 2 | `C2 SETUP: receipt missing or sha mismatch` (no integer on stdout) |
| receipt tampered (one trailing space appended) | `printf ' ' >> observe-r37.json; bash plans/round-37-c2.sh` | 2 | `C2 SETUP: receipt missing or sha mismatch` (no integer on stdout) |

All six modes and both setup controls match the frozen expectations. The lane's own log `.ufo/waves/round-37/controls/c2-controls.txt` is consistent with these re-runs; the `LANE-GUARD` line in that log is the lane's own and I did not re-derive it.

## 8. Lane guard (read-only)

- `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse --show-toplevel` → `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
- `git … rev-parse --abbrev-ref HEAD` → `HEAD` (HEAD is detached); `rev-parse master HEAD` → both `9efcea722bdcf19dbbebf558e0172fafa565ae15`.
- `git … status --porcelain | grep -v '^??'` → no lines, exit 1 (**no tracked modifications**).
- `git … status --porcelain | wc -l` → `8`, all untracked `??` entries under `.ufo/waves/round-37/` (the orchestrator's build dispatch files; not created by this seat).

## 9. Lane census (`bash corpus/sources-census.sh`, extraction)

Command exit **0**. Final line:
`SOURCES_CENSUS: CLEAN (rows=91 A=87 B=2 C=2 queued=1 mined=87 rejected=3 entries_sourced=14 legacy=21 captures=91 inrow=16 inrow_only=0 inrow_nonreproducing=12)`

The lesson recorded `rows=88` at BASE; the candidate adds S089/S090/S091, giving 91.

## 10. Receipt copy into the wave dir

`cp .ufo/waves/round-37/controls/observe-r37.json .ufo/waves/round-37/build/K37ExecEvidence/observe-r37.copy.json` → `cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203` (sha verified).

## 11. Candidate registry rows checked (read-only grep, `corpus/SOURCES.md`)

- S034 `… hashicorp/vault/releases.atom … Entry titled v2.2.0 …` (stale anchor)
- S035 `… openbao/openbao/releases.atom … Entry titled v2.7.1 …` (stale anchor)
- S039 `… python.org/downloads/feed.rss … Python 3.15.1 item …` (stale anchor)
- S089 `… hashicorp/vault/releases.atom … Entry titled v2.2.1 …`, supersedes S034
- S090 `… openbao/openbao/releases.atom … Entry titled v2.7.2 …`, supersedes S035
- S091 `… python.org/downloads/feed.rss … Python 3.15.2 item …`, supersedes S039 (feed anchor)

The counter's verdict follows from these rows: the three surfaces now have URL-and-version holders in SOURCES.md.

## 12. Cleanup

Scratch `/fast/scratch/hyaku/kagi-r37/K37ExecEvidence` removed (`rm -rf`) before yield. Copies in the wave dir: `build/K37ExecEvidence/observe-r37.copy.json` (sha above) and this report.

## Installs and tool changes

None. No tool was installed, upgraded, or removed by this seat. No pacman use.

## Risks and limits

- `self-counts.py` exits 2 (POLICY) because of the two operator-owned reds R29-01/R29-02. This is the documented contract and is reported as POLICY, not as a pass; the stale count is 0.
- The counter checks that a row names the feed URL and the receipt version. It does not check the quote, `teaches`, or the live feed. This seat did not re-fetch the feeds (no network access was requested); the quote-to-bytes check is the reviewer seats' job, as the plan states.
- The BASE 911ab51 value was measured on a copied-in counter, because the counter is not committed there (§6).
- `claim-ledger.sh verify` / `cells` and the fleet census were not run (§4).

## Verdict

The lane's own gates agree with the claim at the candidate: stale rows 0 with two expected POLICY reds, the census selftest passes (70 cases), the ledger docs audit is clean, the C2 counter reads 3 at BASE and 0 at the candidate, the six frozen controls and the two setup controls reproduce their expectations, and no current-tense 88 registry count exists in the three files.

EVIDENCE VERDICT: AGREE
