# ClaimR11X04 — R11-04 `bash corpus/drift-pins.sh` (semantic audit)

Read-only. Production untouched; no gate, handler, op/vault or host command executed.
Observed revision: `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20 21:11:59 -0300;
round-22 verifier spot-check). Worktree clean except untracked `.ufo/waves/round-23/`.
Round-22 measured code commit `4be5da3cac11a1db64c3e0a77246fd7f2bdee413`
(`SCORECARD.md` §Final measured outcome); `git diff 4be5da3..HEAD -- corpus/` touches
README/SOURCES/lessons/stamps only — not this row's files.

Row (exact, `corpus/claim-ledger.tsv:18`):

```
R11-04  bash corpus/drift-pins.sh  ^DRIFT_PINS: CLEAN \(files=[1-9][0-9]* symbols=[1-9][0-9]*\)  0  120  host-file + symbol drift vs committed baselines (round 9) [substrate]
```

## 1. Verdict summary

| Question | Verdict | Basis |
|---|---|---|
| Last-line ↔ exit pair coherent | **supported** | `drift-pins.sh:253-259`; counters at `:127-241` |
| Timeout `120` justified | **supported** | round-22 executed R11-05 receipt (rev `8ada17a`): 13 gate invocations in 0.2 s |
| ERE precisely pins the claim its consumers attach | **refuted** | accepts `files=1`, `files=14`, trailing text (regex-only eval) |
| `[substrate]` deferral correct for this row | **supported, coarse** | 9/15 rows are the-janitor tree; 6/15 are adjacent host surfaces |
| `SKIP-SELF` applies | **no — correctly not applied** | `claim-ledger.sh:816-819` keys on `claim-ledger.sh` only |
| C3 can prove this row hermetically | **only in parts** | CLEAN not producible from repo bytes (§5) |

## 2. What the command actually asserts (observed)

`corpus/drift-pins.sh` = 451 lines, `sha256 c138d34c…0feb` (matches
`corpus/knowledge/drift-gate.md:3`). Static structure, parsed from the shipped data:
`FILES` 15 entries (`drift-pins.sh:45-63`), `NOHASH` 6 (`:70-77`),
`drift-baseline.tsv` 15 data rows, `drift-symbols.tsv` 20 data rows. Set equality holds:
`FILES` == baseline paths exactly, `NOHASH` == the six `sha = -` rows, 9 rows are
content-hashed. `CLEAN` is printed only after both bad counters are zero
(`:249-259`); every non-OK row (MISSING/DRIFT/LINK/POLICY/UNPINNED/EXTRA/DUP at
`:127-189`, GONE/AMBIG/MOVED/COUNT/SHAPE at `:198-241`) increments a bad counter, and an
empty symbol set is itself a failure (`:193-196`). Therefore **CLEAN implies
`files=15 symbols=20` today** — but the printed numbers are not part of the row's
predicate.

Exit: 0 only on the CLEAN branch, 1 on DRIFT, 2 on setup (`:122-125`, `:244-249`).
The ledger runs the row as `timeout -k 5 120 bash -o pipefail -c "$cmd"` with combined
streams (`claim-ledger.sh:426-427`), requires `rc == 0` (`:430-433`), and matches the last
non-empty line with an **unanchored** `[[ $last =~ $expect ]]` (`:436-442`).

## 3. Is the expectation justified?

- **Supported (causality, not counts).** The clean-state line and exit 0 are produced by
  the same two counters; no path prints CLEAN and returns nonzero, and no DRIFT path can
  satisfy `rc = 0`. `^` anchors the head; the pattern cannot match `DRIFT_SELFTEST: PASS`
  or the DRIFT summary. `files=[1-9]` correctly rejects `files=0`, which is reachable in
  the documented alternate-pair mode with an empty baseline (membership check skipped,
  `:164-168`) — the author anticipated the vacuous case.
- **Supported (timeout).** `.ufo/waves/round-22/final-verification.json` `safe_rows`
  R11-05: `DRIFT_SELFTEST: PASS (13 cases)`, exit 0, `seconds: 0.2` — 13 full gate
  invocations. The verify path is 15 `stat`/`wc`/`sha256sum` plus 20 `grep -cE` on small
  text files; no network, no handler, no `op`. 120 s is >100× headroom. `[INFERENCE]`
  from code shape, not a timed run.
- **Partly refuted (precision).** Evaluated the row's ERE as a regex against synthetic
  last lines (pattern literal only; **no gate/row executed**):

  | synthetic last line | row verdict |
  |---|---|
  | `DRIFT_PINS: CLEAN (files=15 symbols=20)` | MATCH (intended) |
  | `DRIFT_PINS: CLEAN (files=1 symbols=1)` | **MATCH** |
  | `DRIFT_PINS: CLEAN (files=14 symbols=20)` | **MATCH** |
  | `DRIFT_PINS: CLEAN (files=15 symbols=19)` | **MATCH** |
  | `DRIFT_PINS: CLEAN (files=15 symbols=20) trailing` | **MATCH** (no `$`) |
  | `DRIFT_PINS: CLEAN (files=0 symbols=0)` | REJECT |
  | `DRIFT_PINS: DRIFT (files_ok=0 files_bad=15 symbols_ok=0 symbols_bad=20)` | REJECT |

  The row is an oracle for "the gate printed CLEAN and exited 0", **not** for the
  membership counts. It has been count-agnostic since its first appearance (`301b9ec`,
  round 11) and was untouched by the round-18 tag commit `fecee87`; epochs
  `301b9ec`/`4e48b77`/`fecee87`/`HEAD` carry the identical ERE.

## 4. `[substrate]` deferral: correct but coarse

- Predicate: `substrate_present()` = `[[ -x "$HOME/.local/bin/the-janitor" ]]`
  (`claim-ledger.sh:140-146`), overridable by `KAGI_SUBSTRATE=present|absent`. The note
  contains the literal `[substrate]`, so when absent the row prints
  `DEFER R11-04 reason=substrate-absent` and is **skipped before policy and execution**
  (`:416-419`), counted in `deferred=`/`row_deferred=`.
- Justified: the command reads 15 `$HOME` paths; 9 are the-janitor config/state/bin tree
  (handler, 4 config files, 1 state file, 2 tac files, `tac-check`), 6 are adjacent host
  surfaces (`opencode` config ×4, `~/.agents/AGENTS.md`, NativeMessagingHosts manifest).
  On an absent-substrate host a live run is a guaranteed MISSING/GONE failure — the
  documented false finding (`corpus/knowledge/substrate-deferral.md` §Contract).
- Coarse: deferral is row-granular, so the 6 partially measurable adjacent surfaces are
  also suppressed. Accepted bound: the alternative is a false failure, and the census row
  that would report them is itself tagged and deferred.
- Current disposition (observed/declared, not executed): handler absent 2026-10-20
  (`.ufo/waves/round-22/build/Entry20.md` §3) ⇒ **DEFER**. Last recorded live CLEAN =
  **2026-09-28** (`LOG.md:620`, inside the round-16 entry starting `:593`;
  `drift-gate.md:169` "Reproduction (2026-09-28)"). 2026-10-14 re-census recorded
  `DRIFT (files_ok=0 files_bad=15 symbols_ok=0 symbols_bad=20)` (`LOG.md:733-734`).
  Of the three drift rows, round 22 executed only **R11-05** and skipped R11-04 and R18-01 by ID
  (`.ufo/waves/round-22/safe-row-plan.json` `skipped_rows[3]`;
  `final-verification.json` `skipped_rows`). No post-2026-09-28 CLEAN receipt exists;
  round 17 (2026-09-29) logged no drift line — a receipt gap, not a pass.

## 5. `SKIP-SELF` and C3 hermetic cells — what must be retained

- **SKIP-SELF: not applicable.** `cells_evidence` skips only commands containing
  `claim-ledger.sh` (`claim-ledger.sh:816-819`). R11-04 is therefore re-run inside `cells`
  and prints DEFER there; `CELL_AUDIT: CLEAN (… rows_run=R row_deferred=N …)` carries the
  deferral (`:1011`). **15 scored cells cite R11-04** (rounds 10, 11, 12 pre/post, 13 pre/post,
  14 pre, 15 post, 16 post, 17 pre, 21 pre), and one `cells` run re-runs the
  row once (deduped).
- **C3 population obligation.** R11-04 must remain in the row population with its
  expect/exit/timeout and be reported as *deferred: live-substrate*; it must never be
  counted as passed and never dropped. It must not be executed, and **must not be forced
  into execution via `KAGI_SUBSTRATE=present`** — that arm runs the real gate against
  `$HOME`. `KAGI_SUBSTRATE=absent` alone is insufficient: untagged R18-01
  (`claim-ledger.tsv:48`) has the **same live command**, so C3 needs a command-surface
  classifier, not only the tag.
- **Oracle proof (hermetic, allowed).** Reuse the ledger matcher (`claim-ledger.sh:442`)
  over synthetic last lines: accept `CLEAN (15,20)`; reject `DRIFT`, `CLEAN (0,0)`, and
  (once tightened) `CLEAN (14,20)`. No gate runs.
- **Gate-logic proof.** R11-05's scratch-tree selftest (13 cases, `drift-pins.sh:374-445`)
  is the hermetic proof of the CLEAN/DRIFT/COUNT/SHAPE machine — round-22 receipt
  (rev `8ada17a`, wave dated 2026-10-20): PASS, 0.2 s. It exercises the alternate-pair mode, where the
  `UNPINNED`/`EXTRA`/`DUP` membership checks are **skipped by design** (`:164-168`), so it
  cannot prove membership closure.
- **Membership proof (proposal, not executed).** An empty scratch `HOME` + the default
  baseline is hermetic (every path is absent: `stat` fails at `:127-147`, `grep` fails at
  `:202-204`; no live file is read) and structurally forces exactly
  `DRIFT_PINS: DRIFT (files_ok=0 files_bad=15 symbols_ok=0 symbols_bad=20)`, exit 1 —
  R18-01's line and the 15/20 membership. This is the only hermetic route to the counts.
- **CLEAN is not hermetically producible from repo bytes.** 9/15 rows are content-hashed
  and the repo holds only digests; the 6 NOHASH rows need exact mode+lines of files that
  are absent. C3 must label R11-04 `live-substrate-only`, not "hermetically verified".
- **C3 false-fail hazard.** A naive hermeticization (scratch `HOME` + run the row command)
  produces the DRIFT exit-1 line above ⇒ `FAIL R11-04 reason=exit-mismatch exit=1 want=0`
  on a healthy host. Forced by `drift-pins.sh:127-241`; do not implement it that way.

## 6. C1 closure-disposition — what must be retained

1. **Follow the actual pointers:** row line 18 → `corpus/drift-pins.sh` (blob
   `c138d34c…`) → `drift-baseline.tsv` (15) + `drift-symbols.tsv` (20) → note tag →
   `substrate_present()` (`claim-ledger.sh:140-146`).
2. **Disposition, not assurance:** on the frozen host the row is `deferred`, with the
   receipt chain above (round-22 ID skip; last executed CLEAN 2026-09-28). Closure must
   not record it as verified/holding.
3. **Counts are not closure.** `CELL_AUDIT: CLEAN` and `DOC_AUDIT: CLEAN` resolve pointers
   only: `doc_audit` checks `is_row` (`:861-948`, resolution at `:913`; `:619-623`) and `cells` re-runs rows but
   treats DEFER as non-failure. `corpus/knowledge/drift-gate.md:9` declares
   `Reverify: R11-04, R11-05`, so `DOC_AUDIT` stays structurally satisfied while R11-04 is
   unmeasured.
4. **Do not conflate R11-04 with R18-01.** Same command, opposite expected lines
   (`tsv:18` vs `tsv:48`), mutually exclusive by host state. A checker keyed on the command
   string would invent a contradiction or pick arbitrarily.
5. **The number has no home in this row.** "15 files / 20 pins" is enforced only by
   R18-01 (exact `files_bad=15 symbols_bad=20`, untagged, runs everywhere) and checklist
   row E1 (`corpus/checklist.tsv:26`, exact ok-counts, executed only through the tagged
   R15-01). C1 should record those as the number's pointers, or open a count row.

## 7. One consumer-visible risk + minimal synthetic falsifier

**Risk (false-clean, moderate, currently latent).** Fifteen scored cells cite R11-04; seven of them state the membership counts
(`SCORECARD.md:41,63,85,96,107,219,242`), as do `PROVINCE.md:47`, `SKILL.md:434` and
`drift-gate.md:169`. The row accepts any nonzero
membership. A unilateral shrink — delete one `drift-baseline.tsv` row **and** its `FILES`
entry (its symbol rows may stay; symbols are independent of the baseline) — prints
`DRIFT_PINS: CLEAN (files=14 symbols=20)`, exit 0, and R11-04 still passes. The guards live
outside this row: R18-01's exact bad-count (untagged, every host) and checklist E1's exact
ok-count (only through the tagged R15-01); the first fires only if `verify` (or R18-01
itself) runs and neither is co-edited. No evidence that membership has ever shrunk:
`FILES` == baseline today; this is an oracle-precision gap, not a current misreading.

**Minimal falsifier for L1 (hermetic, no substrate, no live gate):**
1. *Static, fails today:* assert that R11-04's ERE rejects
   `DRIFT_PINS: CLEAN (files=14 symbols=20)` (and `(files=1 symbols=1)`). It matches today —
   demonstrated above by regex evaluation only. A one-line `tcase` in
   `claim-ledger.sh --selftest` that loads the shipped ERE from `claim-ledger.tsv` and
   asserts rejection of the 14-row line converts the gap into a red test.
2. *Optional end-to-end, scratch tree:* one-file baseline + one-symbol pair through the
   gate's documented `--baseline/--symbols` mode prints `DRIFT_PINS: CLEAN (files=1
   symbols=1)` exit 0 (membership checks skipped, `:164-168`), and that line satisfies the
   shipped row. Proposed, not run.

**Fix (choose one, journal the old/new expectation per the lane's migration convention —
cf. `R11-09` note):** tighten to `^DRIFT_PINS: CLEAN \(files=15 symbols=20\)$`; or add a
count row over the two data files; or, minimally, record in the row note that membership
is pinned by R18-01/E1, not here. Tightening is the house pattern (R12-03, R13-02, R21-04
all pin exact counts) and the counts are already stable since round 12.

## 8. Limits / unresolved

- No gate executed; the 2026-10-14 DRIFT and 2026-10-20 `files_bad=15` readings are
  same-round narrative / static reproduction (`Entry20.md` §3, §8), not fresh captures.
- Round 17's drift re-run (if any) is unlogged; "last CLEAN 2026-09-28" is the last
  *recorded* one, not proof none later occurred.
- Inherited from Entry20 (not re-adjudicated here): `-x` accepts a directory at the pinned
  path, which would un-defer all 11 tagged rows into FAILs, R11-04 included; R18-01's
  summary cannot distinguish "13 absent + 2 mode-diverged" from "15 absent".
- Minor doc freshness: `corpus/knowledge/claim-ledger.md` §Class 5 documents the
  `CELL_AUDIT` summary shape **without** `row_deferred`, which the implementation prints
  (`claim-ledger.sh:1011`); relevant to any C1 reader parsing that line.
- Out of scope by assignment: R11-05, R18-01, R15-01, R13-03 internals (sibling owners).

Report: .ufo/waves/round-23/parent-build/ClaimR11X04.md
Installs/updates: none.
