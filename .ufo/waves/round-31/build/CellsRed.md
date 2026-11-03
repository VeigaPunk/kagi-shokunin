# CellsRed — C1 cell-audit re-arm probe (round-31 BUILD wave)

Seat: `CellsRed` (executor/labrat-class probe seat). Host: Arch Linux, python3 3.14.8,
`/usr/bin/python` also present, `op --version` 2.41.1 (untouched), the-janitor ABSENT.
No tools installed, no pacman transaction, no network fetch, no credential/vault/op contact.
Lane files were not modified. Scratch: `/fast/scratch/hyaku/kagi-r31/CellsRed/` (deleted at
end — see §Cleanup).

Lane revisions observed (the L1 was committing concurrently):
`4767b045` = plan + census + controls (my BASE control receipt),
`2d46e575` = plan correction 1 (migration set 3→10; R11-08 exception) — the correction was
read and is treated as part of the frozen contract below.

## Receipts

- `.ufo/waves/round-31/build/cells-red-base.txt` — BASE (read-only, in lane) control.
- `.ufo/waves/round-31/build/cells-red-probe.txt` — five sed rewrites only, scratch clone.
- `.ufo/waves/round-31/build/cells-red-inlane-rows.txt` — the four affected rows re-run
  **in the lane, read-only**, plus the SCORECARD stamp state at that moment.

## 1. BASE control (lane, read-only, rev 4767b045)

```
claim-ledger: unrecognised round heading in …/SCORECARD.md: '## Round 26 — bounded release-drift response' (expected '## Round <N> — pre-move|post-move')
EXIT=2
```
No `CELL_AUDIT:` line. Plan's C1 before-state reproduced exactly.

## 2. Probe: five rewrites only (scratch clone, lone clone)

Applied with `sed -i` using the plan's five literal old→new pairs; `git diff --stat` =
`SCORECARD.md | 10 +++++-----` (5 insertions, 5 deletions, the five heading lines and
nothing else). `grep -cE '^## Round [0-9]+ — (pre-move|post-move)'` 33 → 35 (R26 and R27
were the two non-parsing headings; R28–R30 already matched on the `post-move:` prefix).

Raw result (`cells-red-probe.txt`, exit 2):

```
FAIL R22-03 reason=exit-mismatch exit=1 want=0
FAIL R24-06 reason=verdict-not-final exit=0
FAIL R24-15 reason=exit-mismatch exit=2 want=0
FAIL R25-02 reason=exit-mismatch exit=2 want=0
POLICY R29-01 reason=first-token:python
POLICY R29-02 reason=first-token:python
STALE-POINTER SCORECARD.md sha=f4eb6ec481f1->ea0ba36fb843 lines=1252->1252 bytes=134670->134700
CELL_AUDIT: POLICY (cells=210 row_pointed=147 stamp_pointed=94 policy=2)
EXIT=2
```

Line-class tally: LABELED-ID 20, HOST-SKIP 12, UNCITED 6, SKIP-SELF 5, FAIL 4, POLICY 2,
STALE-POINTER 1. **Zero `LAYOUT-INCOMPLETE` / `DEFER` lines: the `cells` audit consumes no
fleet layout, so the lone-clone QM22 degradation does not apply to this gate at all.**

## 3. Classification of every FAIL / POLICY / SKIP / STALE line

Verified by re-running the rows **in the lane, read-only** (`cells-red-inlane-rows.txt`):

| line | class | evidence |
|---|---|---|
| `FAIL R22-03` | expected migration (stamp re-pin) | in lane: `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=36 invalid=0)` exit 0. In the probe it is `STALE SCORECARD.md` → exit 1, caused by the reshape's own byte change. |
| `FAIL R24-06` | expected migration (digest) | in lane: `ROW_IDENTITY: scorecard-rounds count=36 sha256=1259a3e1…` exit 0. Probe digest differs because heading text changed; count stays 36. |
| `FAIL R24-15` | expected migration (downstream of the stale stamp) | in lane: `ROW_IDENTITY: revision-added count=36 sha256=2b86f032…` exit 0. It shells `revision-audit --history` and exits 2 when that audit is stale. |
| `FAIL R25-02` | **routed** (operator) | in lane: `SELF_COUNTS: POLICY (claims=62 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` exit 2. |
| `POLICY R29-01` | **routed** (operator) | the allowlist (`claim-ledger.sh:262`) is `bash`, `grep`, `sha256sum`, `wc`, `test`, `python3`; the row's first token is `python`. Classified by code reading; the script was **not executed** (content-safety boundary). |
| `POLICY R29-02` | **routed** (operator) | same allowlist reason. Not executed. |
| `STALE-POINTER SCORECARD.md` | expected migration (stamp re-pin) | plan C1 already says the reshaped landing re-pins the stamp. |
| `SKIP-SELF` ×5 (`R11-08`, `R11-09`, `R14-01`, `R18-03`, `R23-01`) | by design | rows invoke `claim-ledger.sh`; `cells` refuses nested self-audit. |
| `HOST-SKIP` ×12 | by design / correct output | host rows unauthorized on this host (substrate declared absent). Not counted as reds. |
| `UNCITED` ×6 | **pre-existing lane finding, NOT round-31-caused** | see §6. |

No UNEXPECTED FAIL and no layout artifact survived this classification.

## 4. Predicate verdict

**Raw reshape-only run: the frozen predicate does NOT hold** (4 FAIL ids + 1 STALE-POINTER).
The setup error is gone and the audit completes to `CELL_AUDIT:` with `cells=210`, but the
grading greps fail on the three identity rows + the stamp.

**After the bookkeeping the landing already owes (correction §1) it holds exactly.** Carried
out in scratch, in this order:

1. re-pin `SCORECARD.md` in `corpus/stamps.tsv` (sha `f4eb6ec4…`→`ea0ba36f…`, lines 1252,
   bytes 134670→134700) → `STALE-POINTER` gone, **R22-03 and R24-15 go green on their own**
   (they were only stale-stamp casualties); remaining: `FAIL R24-06`, `FAIL R25-02`,
   `POLICY R29-01`, `POLICY R29-02`.
2. migrate R24-06's expectation digest (`1259a3e1…` → `5193d55b…` for the reshaped heading
   text) → this edits `corpus/claim-ledger.tsv`, which is itself stamped, so the audit now
   prints `STALE-POINTER corpus/claim-ledger.tsv sha=23363843b898->591eb9c7edcf` plus
   `FAIL R22-03`/`FAIL R24-15` again.
3. re-pin `corpus/claim-ledger.tsv` in `corpus/stamps.tsv` → final state:

```
FAIL R25-02 reason=exit-mismatch exit=2 want=0
POLICY R29-01 reason=first-token:python
POLICY R29-02 reason=first-token:python
CELL_AUDIT: POLICY (cells=210 row_pointed=147 stamp_pointed=94 policy=2)
unrecognised_heading_count=0  cell_audit_lines=1  stale_pointer_count=0
fail_policy_ids=R25-02 R29-01 R29-02   cells=210 (≥210)
```

All four frozen greps pass. **The cascade is causally closed: any edit to a pinned file
re-opens the stamp, so a migration is only complete when its file's stamps row is re-pinned
in the same landing.** The R24-06 expectation and the `corpus/claim-ledger.tsv` stamp row
are a single atomic step, not two.

## 5. What the in-lane run will show beyond the probe

The probe has no round-31 content. Positive control (scratch): appending a properly tabled
`## Round 31 — pre-move (…)` section gave `CELL_AUDIT: POLICY (cells=216 row_pointed=153
stamp_pointed=94 policy=2)` and turned red exactly `R13-01` (heading count 36→37),
`R22-03`, `R24-06`, `R24-15` and the SCORECARD stamp — i.e. precisely the count/identity
rows the correction's 10-row set names. The other seven rows of that set move for the same
reason on the C2 bytes (new registry rows, captures, entries, lesson). No new UNCITED
appeared because the probe cells cited row ids.

**Hard authoring constraint (negative control, measured):** a `## Round 31 — … pre-move`
heading **without** a full six-axis table re-enters the exact BASE failure:

```
claim-ledger: scorecard section '## Round 31 — pre-move (…)' does not carry all six axes exactly once (found=0 missing=depth coverage operability freshness calibration adjacency)
EXIT=2
```
`section_check` requires all six axes exactly once in **every** recognised section,
pre-move included (`SEC_RE='^ {0,3}##[[:blank:]]+Round [0-9]+ — (pre|post)-move([[:blank:]]|$)'`).
Both round-31 headings must carry the 6-row table from their first commit, or C1 dies at
setup. Cells must cite an `R<n>-<n>` row id or a stamped path, or they add UNCITED lines.

## 6. The one unplanned lane-owned finding: six pre-existing UNCITED cells

```
UNCITED SCORECARD.md:1200 freshness   (no resolving row id and no pinned artifact)
UNCITED SCORECARD.md:1201 calibration
UNCITED SCORECARD.md:1203 coverage
UNCITED SCORECARD.md:1204 operability
UNCITED SCORECARD.md:1247 depth
UNCITED SCORECARD.md:1250 adjacency
```
Lines 1200–1204 are the round-29 post-move axis rows; 1247/1250 are round-30's `depth` and
`adjacency` rows (round-30's other four axis cells cite `R30-01`/`R14-01`/`R21-02`). They
are **pre-existing**, latent since the audit stopped parsing at round 26 (the round-29/30
sections were written while `cells` was already dead), and are **not** in plan correction
1's allowed non-clean set.

Two facts the L1 needs:
- **They are invisible in the summary while any POLICY row exists.** `cells` emits
  `CELL_AUDIT: POLICY (cells/row_pointed/stamp_pointed/policy)` and `exit 2` **before** the
  BROKEN/CLEAN branches (`claim-ledger.sh:1250-1253`), so `row_failures`, `stale_pointers`
  and `uncited` never appear in the line while R29-01/R29-02 stay POLICY. The moment the
  POLICY rows clear, `CL_UNCITED>0` makes the verdict `CELL_AUDIT: BROKEN (… uncited=6 …)`,
  exit 1 (`claim-ledger.sh:1255-1256`).
- **They cannot be repaired inside C1's declared scope.** C1 says "No table cell, score or
  evidence line inside those sections changes", and two of the six sections (29, 30) are
  among the five being reshaped. Clearing them needs an evidence-line edit (adding a row id
  to those axis cells) or a new stamp for a token they cite; neither is a content-preserving
  heading reshape.

Reading of the frozen text: the predicate names only FAIL/POLICY rows and STALE-POINTER, so
the **predicate holds literally**; the kill rule separately names "an uncited/missing-id
class" as a lane-owned red that must be repaired-in-round **only if the round caused it** —
it did not. So this is a "finding-named" case, not a repair case, unless the L1 chooses to
widen the landing's scope deliberately. It should be recorded by name in the round-31
report/lesson and routed as its own item; it is not a reshape defect.

## 7. Other findings for the L1

1. **R25-02 is not only policy-blocked.** `corpus/self-counts.tsv` has 62 non-comment rows;
   R25-02 still expects `claims=60`. Even with a clean policy registration the row stays
   red (62≠60). Correction 1 forbids migrating it to hide a routed red — correct — but the
   expected-value drift should be named alongside the policy cause.
2. **D3's stated fix is insufficient for R29-01/R29-02 as written.** The card's D3 item is
   "`feed-token-agree` registration in `PYTHON_SCRIPT_RE`". But both rows start with bare
   `python`, and `ALLOWED_RE` rejects the first token *before* `PYTHON_SCRIPT_RE` is
   consulted (`claim-ledger.sh:275-276`). Registration alone changes nothing; the rows also
   need `python3` (a ledger-row edit, L0), or `python` added to the allowlist (much wider).
   Also `python` exists on this host (3.14.8), so the "no working python3 on the round-29
   Windows host" rationale does not hold here.
3. **The correction's R11-08 exception is inert in `cells` mode.** R11-08 appears as
   `SKIP-SELF` (it invokes `claim-ledger.sh`), never as FAIL, so the frozen counting command
   can never observe it. It matters only to `verify`-mode receipts. Harmless, but do not
   grade `cells` against it.
4. **The reshape's own blast radius is exactly 3 rows + 1 stamp**: R24-06 (digest),
   R22-03 and R24-15 (both via the stale SCORECARD stamp). The other seven rows of the
   10-row migration set are driven by added bytes, not by the heading rewrite — do not
   attribute them to the reshape.
5. **No layout artifact exists for this gate.** Unlike `citations` (which has a typed
   `LAYOUT-INCOMPLETE` path), `cells` needs nothing from the fleet; a lone clone reproduces
   the lane result exactly. QM22 does not apply to the C1 counting command.

## Risks / blockers

- None blocking. The lane tip advanced mid-run (4767b045 → 2d46e57, plan correction 1); my
  BASE control receipt is at 4767b045 and the in-lane rows receipt at 2d46e57. The
  correction was read and folded in.
- I did not execute `corpus/feed-token-agree.py` (nor any release-clock tokenizer) — the
  two POLICY lines are classified from the allowlist code, per the refusal boundary.

## Cleanup

`/fast/scratch/hyaku/kagi-r31/CellsRed/` (clone + `/tmp/sc-before-cellsred.md`,
`/tmp/sc-reshapeready.md`, `/tmp/cellsred-step*.txt`) — scratch tree deleted; the only
retained receipts are the three files above.
