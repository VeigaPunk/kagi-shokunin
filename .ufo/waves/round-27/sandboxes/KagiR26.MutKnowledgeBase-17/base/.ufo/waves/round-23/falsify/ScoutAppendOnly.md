# ScoutAppendOnly — round-23 falsification (append-only + prose corrections)

Seat: leaf scout, read-only on the lane. Base `d218603b74099ddca0bd8f869516fc41db0979bf`
(`git rev-parse HEAD` = d218603; round-23 work is an uncommitted working tree).
No lane file was edited. No installs, no host gates, no network re-fetch, no git/jj mutation.
The one non-file-mutating diagnostic that declares state in a *caller* shell is labelled as
such below.

## Attacked

1. Append-only property of the assigned set: `LOG.md`, `SCORECARD.md`,
   `corpus/QUALITY.md`, `corpus/README.md`, `corpus/knowledge/*.md`.
2. The two round-23 prose corrections: SKILL.md `PASS (29 cases)` → `36`, and
   op-ref-consumption `DRIFT exit 1` → `SETUP exit 2`, against
   `corpus/op-ref-probe.sh:525-526`.
3. Cross-check of the exact gate verdicts that LOG.md / SCORECARD.md quote as this
   round's "After" evidence, re-run host-free (`sources-census`, `closure-dispositions`,
   `cells` fixture row) — a quoted line that does not reproduce is a documentation defect
   regardless of who owns the artifact.

## Commands and exits (all from `/home/vgpnk/Projects/shokunin/kagi-shokunin`)

| # | Command | Exit | Observed |
|---|---|---|---|
| 1 | `git diff --numstat d218603 -- LOG.md SCORECARD.md corpus/QUALITY.md corpus/README.md corpus/knowledge/` | 0 | `43 0 LOG.md`; `40 0 SCORECARD.md`; `3 2 corpus/knowledge/op-ref-consumption.md`; QUALITY/README absent (no diff) |
| 2 | `git diff --quiet d218603 -- corpus/QUALITY.md` / `... corpus/README.md` | 0 / 0 | unchanged |
| 3 | `git diff --name-only d218603 -- corpus/knowledge/` | 0 | only `corpus/knowledge/op-ref-consumption.md` |
| 4 | `bash corpus/op-ref-probe.sh --selftest` | 0 | `OP_REF_SELFTEST: PASS (36 cases)` |
| 5 | `OP_REF_OP_BIN=/nonexistent/kagi12-op bash corpus/op-ref-probe.sh --dotenv-bytes` | 2 | `OP_DOTENV_BYTES: SETUP (op binary not found)` |
| 6 | `OP_REF_OP_BIN=/bin/false bash corpus/op-ref-probe.sh --dotenv-bytes` | 1 | `DOTENV_BYTES_CASE … status=FAIL reason=exit-or-bytes` ×6; `OP_DOTENV_BYTES: DRIFT (checks=6 failed=6)` |
| 7 | `bash corpus/sources-census.sh` | **1** | `corpus/sources-census.sh: line 242: S007: unbound variable` — no verdict line |
| 8 | `bash corpus/sources-census.sh --selftest` | 0 | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` (12 `fetch-*` cases) |
| 9 | `bash -c 'declare -A SUPERSEDED=(); source corpus/sources-census.sh'` (caller-scope diagnostic only) | 0 | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` |
| 10 | `python3 corpus/closure-dispositions.py` | 0 | `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)` |
| 11 | `python3 corpus/closure-dispositions.py --selftest` | 0 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (13 cases)` |
| 12 | `bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --claims …/claims.tsv --stamps …/stamps.tsv --scorecard …/SCORECARD.md --docs …/SCORECARD.md` | 0 | `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)` |
| 13 | `grep -c '^## Round ' SCORECARD.md` | 0 | `27` |
| 14 | `awk -F'\t' '!/^#/ && NF' corpus/source-fetches.tsv` | 0 | 10 data rows, each `NF=16`; 9 distinct `$4` URLs; all 10 `$3` row-identity digests match sha256(`id\tstatus\turl\n`) |
| 15 | `find corpus/fixtures/cells-hermetic -type f \| wc -l` | 0 | `5` |
| 16 | `git cat-file -e d218603:corpus/closure-dispositions.py` (`…source-fetches.tsv`, `…fixtures/cells-hermetic`) | 128 each | absent at base, as LOG's "Before" says |

## Findings

### F1 — BLOCKER: the C2 census gate does not run on the committed tree (falsifies R21-02 and LOG.md:1194)

`bash corpus/sources-census.sh` exits **1** with
`corpus/sources-census.sh: line 242: S007: unbound variable` and prints no
`SOURCES_CENSUS:` verdict. Line 242 assigns `SUPERSEDED[$fid]=1`, but `SUPERSEDED` is
never declared (only occurrences in the file are use-sites at
`corpus/sources-census.sh:242` and the awk emitter at `:245`; script runs
`set -uo pipefail` at `:107`). Undeclared → indexed-array assignment → subscript `S007`
evaluated arithmetically → unbound under `set -u` (mechanism reproduced:
`bash -uc 'SUPERSEDED[S007]=1'` → `S007: unbound variable`, exit 127).
The first emitted supersession token is `S019 → S007`
(`awk -F'|' ... corpus/SOURCES.md` prints `S019->S007, S020->S006, S022->S012,
S023->S013, S025->S014, S026->S016`), so the loop dies on its first iteration.
This is round-23 code (`# ---- fetch provenance (round 23, routed D7)` at
`sources-census.sh:226`); the base script had no `SUPERSEDED` handling at all
(`git show d218603:corpus/sources-census.sh | grep -n 'SUPERSEDED\|supersede'` → no
matches, exit 1).

Causation diagnostic, not a production fix: declaring `declare -A SUPERSEDED=()` in a
caller shell before sourcing (row 9) yields the exact line LOG.md:1194-1195 and
claim-ledger.tsv:59's R21-02 expect, exit 0. So the `rows=26` count is right and the
blocker is the missing declaration on the committed path.

Why the 59-case selftest misses it: `grep -n 'supersede' corpus/sources-census.sh`
matches only `:245` (the awk), i.e. no fixture in the 59 cases carries a `supersedes`
field, so the supersession-collection branch is never exercised. The 12 `fetch-*` cases
cover missing/url/status/rowdigest/digest/quote-long/norm/normsha/location/unknown/
duplicate/disagree — not this branch.

Consequence: LOG.md:1194 (`SOURCES_CENSUS: CLEAN … exit0`) and R21-02's expected
`^SOURCES_CENSUS: CLEAN \(rows=26 …\)$` are not reproducible as committed. C2's
freshness evidence is unoperable until the declaration lands; the claim cannot be
credited on the current tree even though the underlying registry rows are correct.

### F2 — DEFECT: the SETUP/DRIFT correction is over-broad and contradicts its own cited lines

Both corrected locations now say the whole class `(sign-in, timeout, missing binary)`
reads `SETUP` exit 2:

- `corpus/claim-ledger.tsv:51` (R21-01): "an op-side failure (sign-in, timeout, missing
  binary) reads as SETUP exit 2 today (code at op-ref-probe.sh:525-526)".
- `corpus/knowledge/op-ref-consumption.md:362-365`: same sentence, same citation.

The cited lines are only the **preflight** check
`OP_BIN=$(command -v "$OP_BIN") || die "OP_DOTENV_BYTES: SETUP (op binary not found)" 2`
(`op-ref-probe.sh:525-526`; missing tools are the analogous preflight at `:521-523`).
A sign-in prompt or a timeout happens **inside** the six-case loop: `op_exec` captures
`rc` (`:542-550`) and `evaluate_bytes` marks any `rc != 0` or hex mismatch as
`status=FAIL` (`:503-507`), then returns
`OP_DOTENV_BYTES: DRIFT (checks=6 failed=N)` exit 1 (`:512-515`). There is no `rc`
special-case. Empirically (row 6), a real op-side exit failure — `/bin/false` in the
op slot, exercising the same branch a refused sign-in or `timeout 10` kill would hit, with
`actual` empty — yields `DRIFT (checks=6 failed=6)` exit **1**; only the absent binary
(row 5) yields `SETUP` exit **2**.

So round 23 corrected a true statement about sign-in/timeout into a false one, while
fixing the one class (missing binary) that was genuinely misdescribed. The accurate
sentence is: missing binary / missing tools → SETUP exit 2; sign-in and timeout → DRIFT
exit 1. The LOG's generalisation at `LOG.md:1209-1211` ("the probe code prints SETUP
exit 2") inherits the same over-scope. This is a round-23-introduced inaccuracy in both
edited prose sites, not a historical pin.

Side effect at `corpus/knowledge/op-ref-consumption.md:365`: the replacement line was
not re-wrapped (`...byte change; and failing rows print no observed` is a 130+ column
line) — cosmetic only.

### F3 — Defect (numeric): "10 declared captures over 7 URLs" is 9 distinct URLs

`corpus/source-fetches.tsv:37-46` holds 10 data rows (all 16 columns) with **9**
distinct `$4` values and 9 distinct `$5` values; the only duplicate URL is
`https://openbao.org/docs/concepts/tokens/` at S021 and S026. LOG.md:1202
("10 declared captures over 7 URLs") and SCORECARD.md:840 ("S024-S026 are correction
rows over seven distinct URLs") both state 7. The file itself is otherwise sound: all
ten `row_identity_sha256` values equal sha256(`id<TAB>status<TAB>url<LF>`), and all
statuses match the registry. The count needs correction; the provenance artifact does
not.

### F4 — Minor (numeric): fixture is 5 files, LOG says 4

`find corpus/fixtures/cells-hermetic -type f` returns 5:
`claims.tsv`, `stamps.tsv`, `SCORECARD.md`, `corpus/adjacency.tsv`, `corpus/fx-ok.sh`.
LOG.md:1203 says "`corpus/fixtures/cells-hermetic/` (4 files)" — that matches the four
top-level entries (three files + `corpus/`), not the file count. The R23-01 cells
verdict itself reproduces exactly (row 12), so this is a prose count only.

### F5 — Minor: duplicated sentence introduced in R13-01's note

`corpus/claim-ledger.tsv:29` now repeats
"… Includes the preserved blocked round-20 attempt, which cells excludes from scored
sections only; malformed actual scored headings still fail closed." twice. At base the
sentence appeared once (`git show d218603:corpus/claim-ledger.tsv | sed -n '29p'`); the
round-23 25→27 replacement appended a second copy. The pinned count itself is correct:
`grep -c '^## Round ' SCORECARD.md` = 27 (row 13).

## Confirmations (attacked, did not break)

- **Append-only holds for the assigned set.** LOG.md 43/0 and SCORECARD.md 40/0 are
  pure appends; QUALITY.md and README.md are untouched (exit 0 diff-quiet);
  `corpus/knowledge/` has exactly one modified file whose only two deleted lines are the
  old `DRIFT` sentence, explicitly documented at LOG.md:1209-1211 and replaced by the
  F2 text. No undocumented deletion in the assigned set.
- **SKILL.md 29→36 is correct.** `--selftest` on the tree prints exactly
  `OP_REF_SELFTEST: PASS (36 cases)`, exit 0 (row 4). SKILL.md:643 matches measured output.
- **C1 reproduces.** Gate and 13-case selftest print the exact LOG.md:1192-1194 and
  SCORECARD.md:843/851 lines, exit 0 (rows 10-11); `closure-dispositions.json` carries 15
  dispositions (7 fixed / 5 no-action / 2 reported / 1 operator-owned).
- **C3 reproduces.** R23-01's `cells` command prints the exact LOG.md:1196-1198 and
  SCORECARD.md:841 CLEAN line, exit 0 (row 12).
- **Census selftest claim is true but blind.** 59 cases pass, 12 of them `fetch-*`, exit 0
  (row 8) — the count is honest; the gap is that no case reaches `sources-census.sh:242`.
- **"Before" state is accurate.** All three round-23 artifacts are absent at d218603
  (row 16, exit 128 each); SOURCES.md is 3/0 (only S024-S026 added, existing rows
  unchanged); the three new rows' supersession targets (S014, S016) are new, not rewrites.

## Not run / limits

- `bash corpus/op-ref-probe.sh` full verify (the `checks=44 …` line in the same SKILL.md
  paragraph) — host-bound: needs a live `op` and `$HOME/.local/bin/the-janitor`. Not
  executed; not cited as evidence either way.
- No public re-fetch was needed; all findings are from the local tree and host-free gates.
- The `declare -A SUPERSEDED=()` run (row 9) declares state in the calling shell only; it
  changed no file and is reported as a causation diagnostic, not a pass for the committed
  tree.

## Verdict

Append-only is intact in the assigned docs, and both prose *edits* match the measured
case count (36) — but the SETUP/DRIFT replacement is wrong for sign-in/timeout (F2), and
the round's own C2 gate (R21-02) crashes on the committed tree at
`sources-census.sh:242` (F1), so LOG.md:1194's CLEAN/exit-0 quote is false as shipped.
C1 and C3 reproduce exactly. F3/F4/F5 are documentation-count/prose defects. Confidence:
high on F1 (reproduced exit 1, exact line, causation isolated) and F2 (static branch plus
empirical exit 1 vs 2); high on F3-F5 (byte/line counts); no claim here relies on
unobserved host behavior.
