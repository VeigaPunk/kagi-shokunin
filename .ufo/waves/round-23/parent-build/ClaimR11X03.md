# ClaimR11X03 — R11-03 census-selftest obligation audit

Seat `ClaimR11X03` (leaf, read-only, no subagent dispatch). Only write: this report.
Audit target: row **R11-03** at `corpus/claim-ledger.tsv:17`, revision
`d218603b74099ddca0bd8f869516fc41db0979bf` (`plans/round-23.md:5`).
Row line sha256 `e4342fa9fd4407d08bc30d3ff18ac5c7c11edc1d5e8f7c37f09fb93ca6c3785b`
(224 bytes), identical to the R22 frozen copy
`.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:17`.
Audited bytes at HEAD: `corpus/claim-ledger.tsv` sha256 `e6806968…8305`, 58 lines /
17844 bytes (`corpus/stamps.tsv:5`); `corpus/surface-census.sh` sha256 `275d8294…009f`,
886 lines / 44212 bytes (`corpus/stamps.tsv:63`) — both match their stamps.
Tree state: audited files clean at HEAD; only untracked `.ufo/waves/round-23/`. Two
untracked C1 files (`corpus/closure-dispositions.py`, `.json`) appeared during this audit
(mtime 00:46) and are **not** part of the frozen revision; treated as out-of-scope
in-flight work. No production write, no gate/handler/op/vault/host command executed.

## 1. Row and causal chain

```
R11-03  bash corpus/surface-census.sh --selftest
        ^SELFTEST: PASS \(16 cases\)    exit 0    timeout 300
        note: census selftest, case count pinned; the two verb cases SKIP
              (recorded, not failed) when the handler is absent — since round 18 [substrate]
```

- Implementation: `corpus/surface-census.sh:694-848` (`selftest()`), verdict at 846-847.
- Consumption: `corpus/claim-ledger.sh:400-444` — command runs under
  `timeout -k 5 300 bash -o pipefail -c`, and passes only when the exit equals 0 **and**
  the expected ERE matches the last non-empty output line (436-444).
- Deferral gate: `corpus/claim-ledger.sh:416-419` skips the row entirely when the note
  contains `[substrate]` and `substrate_present()` is false (140-148).
- Documented/persisted evidence: `corpus/knowledge/surface-census.md:249-256` (dated
  reproduction 2026-09-28), `SCORECARD.md:50`, `SCORECARD.md:324`;
  `.ufo/waves/round-22/safe-row-plan.json` (same command/ERE/exit/timeout, marked not
  authorized) and `.ufo/waves/round-22/final-verification.json:528` (R11-03 in
  `skipped_rows`, reason "Not executed").

## 2. Is the expected last line / exit / timeout justified?

**Last line — justified as a harness-completion claim, not as a 16-execution claim.**
`SELFTEST: PASS (%s cases)` at 846 is reachable only after every case block has run
(`failures==0`). The literal `16` is causally tied to the code, not to prose:
12 `run_case` invocations (767-775, 789-791: clean, mode-drift, asset-gone,
runtime-absent, undeclared-file, crosscheck-disagree, symlink-swap, sqlite-magic,
sqlite-magic-prefix-only, required-table-gone, row-floor, malformed-row) plus four
explicit case blocks (778 sqlite-unavailable, 803 fused-shape-row, 816 verbs-sandboxed,
822/834 verbs-break-injection). `run_case` increments `cases` at 752 before judging, so
a failing case still yields `FAIL (f/16 cases)`; a deleted/added case moves the count and
breaks the pin — the intended reviewed re-pin behaviour. **Caveat:** the two verb cases
contribute to the 16 in both arms; in the skip arm (817-823) they are counted without
being executed, and the verdict line carries no skip count (§4).

**Exit 0 — justified.** The same branch prints the PASS line and exits 0; harness setup
failure aborts earlier under `set -euo pipefail` (line 74) before any verdict, so exit 0
means the harness reached its end with zero case failures. It does not mean "no
unexecuted cases" (below).

**Timeout 300 — justified with wide margin, no measured receipt.** Cost is 14 scratch
census runs plus, only when the handler resolves, two `--verbs` runs. The documented
default set is `pass=7 skip=3` and `--deep` is "≤25 s"
(`corpus/knowledge/surface-census.md:250-251`, `SCORECARD.md:50`); the scratch trees are
tiny (`surface-census.sh:700-718`). The command/ERE/exit/timeout tuple is unchanged since
the row landed in round 11 (`301b9ec`); round-8 and round-19 receipts ran the same
selftest. No execution receipt records wall time; 300 s is a safe bound, not a measured one.

## 3. `[substrate]` deferral, SKIP-SELF, hermetic synthetic mode

**Deferral carries, it does not discharge.** R11-03 is one of the 11
`[substrate]`-tagged rows whose count `R18-02` pins. On this host
`test -x "$HOME/.local/bin/the-janitor"` is false and the handler is not on PATH, so
`substrate_present()` (claim-ledger.sh:140-148) returns false and `verify` prints
`DEFER R11-03 reason=substrate-absent`; the command never runs. Per
`corpus/knowledge/substrate-deferral.md` §Bounds 1, that is absence recorded, not a pass.
No current execution receipt for R11-03 exists; the last persisted disposition
(R22) is also "Not executed".

**The two predicates diverge.** The ledger decides deferral from the *file path*
(`-x $HOME/.local/bin/the-janitor`, claim-ledger.sh:145); the selftest decides its skip
from *PATH resolution* (`command -v "$JANITOR"`, surface-census.sh:817, with
`JANITOR="${THE_JANITOR_BIN:-the-janitor}"` at 82). If the handler exists at the
deferred path but is not on the invoker's PATH, the row is **not** deferred yet both verb
cases skip. The note's wording ("when the handler is absent") is narrower than the code's
condition (the emitted reason string is "handler not on PATH", 821/823).

**`SKIP-SELF` does not apply.** `cells_evidence` skips a row only when its command contains
`claim-ledger.sh` (`corpus/claim-ledger.sh:816-820`); R11-03 invokes `surface-census.sh`,
so `cells` re-runs it through the ordinary machinery whenever a cited cell names it and
the substrate predicate says present. `SCORECARD.md:324` (round-18 post-move,
operability) cites `R11-03`, so that cell's evidence is re-run; on today's host it defers
and the CELL_AUDIT line reports `row_deferred=1` (`corpus/claim-ledger.sh:1011`).

**Hermetic synthetic mode preserves 14 of 16 cases, conditionally 16.** The 14
surfaces/shapes cases are host-free: `census_verify` (761-764) pins `--root "$R/host"`
and scratch census/shapes/baseline files, and `resolve()` rewrites `$HOME`→`$ROOT` and
`$STATE` (122-127), so no real home path is read. The two verb cases execute the **real**
handler when it resolves (`--verbs --verb-root`, 828 and 834), and `--verbs` runs probes
that call `$JANITOR` and `tmux has-session` (469, 484, 508, 523, 573, 677, 687). They are hermetic only
via the skip branch. So the selftest proves its 14 synthetic obligations on any host and
its 2 handler obligations only where the handler resolves.

**Undeclared tool dependency.** `build_tree` and two case setups call bare `sqlite3`
(710, 789, 790) instead of `"$SQLITE3"` (initialized from `SQLITE3_BIN` at 83), although
case 10 exists specifically to prove the `SQLITE3_BIN` fail-closed path. A host with the
handler present but no `sqlite3` on PATH aborts the harness at fixture creation; the row
then fails exit mismatch/127 with a shell error as its last line. That is an honest
failure, but a misdiagnosed one, and it is outside what `[substrate]` defers. A hermetic
fixture that executes this row must provide `sqlite3`.

## 4. Consumer-visible risk and minimal synthetic falsifier

**Risk (false-clean): the pinned line cannot distinguish 16 executed from 14 executed +
2 skipped.** This is the exact shape QUALITY.md QM4 names ("the case count does not
absorb it") and the class the corpus already recorded on a substrate-absent host:
`corpus/lessons/round-19-recensus.md:13` records `SELFTEST: PASS (16 cases)` from the
2026-10-14 handler-absent host without recording the two `skip-case` lines — a durable
receipt that the pin is satisfiable with both verb obligations unexecuted. A consumer
applying the ledger's last-line rule (claim-ledger.sh:436-444), the knowledge entry's
reproduction block (`corpus/knowledge/surface-census.md:252`), or a C3 fixture sees only
`PASS (16 cases)`.

The reachable configuration where this is *not* already caught by deferral is §3's
predicate mismatch: handler executable at `$HOME/.local/bin/the-janitor`, not on PATH.
Then R11-03 executes and passes, while sibling `R11-02` (`--verbs`) fails loudly in the
same environment (`verbs()` dies "handler not on PATH", surface-census.sh:469) — proof
that the condition is detectable at a sibling row but invisible in this row's pin.

**Minimal synthetic falsifier proposal for L1 (not executed here; no passing result
claimed):**

1. Fixture home `$F` with an executable file `$F/.local/bin/the-janitor` (the selftest's
   skip guard and `substrate_present` only need the exec bit; content unused).
2. `PATH=$P` where `$P` holds `bash`, coreutils, `sqlite3`, `python3`, and **no**
   `the-janitor`.
3. Run `HOME=$F PATH=$P bash corpus/claim-ledger.sh verify --root <fixture-root>
   --claims <fixture ledger containing this row and a fixture stamps/docs set>`.
4. Assert the output contains `skip-case 15` and `skip-case 16`, and that R11-03 reports
   PASS (exit 0, last line matches the row ERE). Static reading predicts both hold today
   [INFERENCE — not run].
5. Gate for the fix: a second fixture asserts that a row may not report a bare PASS when
   either `skip-case` line appears unless the expected ERE names `skipped=2` (or the
   disposition is recorded as 14/16). Against current source that fixture fails; that
   failure is the proposed L1 failing fixture (not a fabricated pass), and it must pass
   after a reviewed re-pin.
6. Fix shape is L1's call and a reviewed re-pin: either emit
   `SELFTEST: PASS (16 cases, 2 skipped)` at 846 (updating row R11-03, the knowledge
   reproduction line and stamps per QM14), or keep the line and make C1/C3 consumers
   assert the two `skip-case` lines explicitly. A bare count change without the skip
   field would move the problem, not close it.

## 5. What C1 closure-disposition integration must retain for this row

- R11-03 is **not** an obligation of the in-flight `corpus/closure-dispositions.py`
  (its model is D1–D9 / SPOT-01..05 / ADJ from the round-22 verifier spot-check). C1 must
  not claim that checker dispositions claim-ledger rows.
- If C1 follows scorecard evidence, the chain for `SCORECARD.md:324` is
  `R11-03` → `corpus/claim-ledger.tsv:17` → `corpus/surface-census.sh:694-848`
  (stamp `corpus/stamps.tsv:63`). The required disposition vocabulary is
  `deferred(substrate-absent)` today (or `hermetic 14/16`), never `fixed`/`verified`.
- Membership checks are not execution evidence: `is_row` (claim-ledger.sh:619-623), the
  cell `has_row` test (757-763) and the `docs` `row_linked` count (913) all accept a
  row id that never ran. `CLAIM_LEDGER: CLEAN (… deferred=11 …)` exits 0 (973-983), and
  `CELL_AUDIT: CLEAN (… row_deferred=1 …)` exits 0 (1011): a C1 consumer must read the
  per-row `DEFER` line or the `deferred`/`row_deferred` counts, not the CLEAN verdict.

## 6. What C3 hermetic cells proof must retain for this row

- If the fixture cells run includes R11-03, the runner must export
  `KAGI_SUBSTRATE=present` (otherwise `verify_claims` defers it) **and** make the handler
  unresolvable (`THE_JANITOR_BIN=/nonexistent/the-janitor`, or a PATH without it) so the
  selftest never executes the live handler. It must then assert both `skip-case` lines
  plus `SELFTEST: PASS (16 cases)`, so the fixture does not claim the two handler
  obligations ran. It must also provide `sqlite3` (§3).
- The exact `CELL_AUDIT: CLEAN` pin should include concrete `rows_run` and
  `row_deferred` values, plus a mutation case that adds `[substrate]` to a cited
  executable row and changes those counts; otherwise a deferred row is laundered into a
  green cell (cells still counts it via `has_row`, 757-763).
- If the fixture excludes R11-03, C3's accounting must list it as an uncovered carried
  obligation. "All command-row obligations preserved" is false for this row unless one of
  the two branches above is recorded.

## 7. Historical vs current evidence

| Date | Host | Evidence | Meaning |
|---|---|---|---|
| 2026-09-28 | handler present | `corpus/knowledge/surface-census.md:1-15,249-252` | `SELFTEST: PASS (16 cases)` with all cases executable; `--verbs` pass=7 skip=3 |
| 2026-10-14 | handler absent | `corpus/lessons/round-19-recensus.md:13` | `SELFTEST: PASS (16 cases)` after the r18 skip fix; skip lines not recorded — the false-clean receipt |
| R22 freeze | substrate absent (carried; R22 did not re-measure) | `.ufo/waves/round-22/final-verification.json:528` | R11-03 explicitly **not executed**; row bytes identical to HEAD |
| 2026-10-21 (now) | handler absent (`test -x` false, `command -v` false) | `corpus/claim-ledger.tsv:17` + `claim-ledger.sh:140-148` | disposition `DEFER`, command never run; no current execution receipt |

Current documentation is accurate where it dates itself (the knowledge reproduction is
titled 2026-09-28) and the row note declares the skip; the residual gap is that the
pinned artifact (the last line) carries no skip count.

## 8. Limits / remaining unknowns

- No command executed; all verdict claims are static-causal from the cited lines. Wall
  time for `--selftest` on this host is unmeasured (300 s bound inferred, not observed).
- The handler-present path is unverifiable here (handler absent, no source). In
  particular probe 9 (`status-contract`) compares the sandboxed `status` state with the
  **real** `tmux has-session -t janitor` (surface-census.sh:672-689); whether those two
  always agree on a restored substrate is unresolved [INFERENCE: they can diverge; not
  observed].
- The predicate divergence in §3 depends on the invoker's PATH; not measured.
- Scope held to R11-03. R11-01/R11-02 are cited only for contrast; their obligations are
  other owners' audits. No prior-round artifact was re-executed.
- Tools: `read`, `bash` (read-only file/hash/git queries), Python JSON parsing. No
  installs/upgrades; no gates, no `op`/vault/host commands.

Report: .ufo/waves/round-23/parent-build/ClaimR11X03.md
