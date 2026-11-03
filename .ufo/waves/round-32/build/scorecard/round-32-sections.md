## Round 32 — pre-move (repo HEAD 32c35fe, round-31 close)

Frozen BASE `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`; plan and frozen claims `507dd9f`
(committed alone, before any round-32 data). Every axis stood at 9 at round-31 close, so this
table is the reference line the round's two claims are measured against — no value in it is a
round-32 measurement, and the `lane-status:` reds are named in the calibration row rather than
left to prose. The `CELL_AUDIT` figures in that row are the round-31 receipt values, not a claim
about the spliced file: these two sections add 12 cells (projected `cells=234 row_pointed=174
stamp_pointed=108`), so the next `cells` run re-counts and the receipt is the only place the 222
belongs.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | Unchanged from round 29: the release-clock surface carries the extraction contract, the agreement invariant, six bounds and four falsifiers, and the refusal bounds (masking of ref-resolved values, item-level reads, the absent handler) stand. The round adds no mechanism claim on a held surface. Row `R29-01`. | round 29 |
| coverage | 9 | Unchanged: 71 registry rows with the census green at BASE, and the OIDC workload-federation theme admitted in round 31; the NIST SP 800-57 family assimilation candidate is deferred to the next round by the two-claim cap (`plans/round-32.md` §Assimilation). Row `R31-02`. | round 31 |
| operability | 9 | Unchanged: nine gate mode-sets with verdicts and selftests, `bash corpus/eol-sweep.sh` green at BASE (row `R30-01`); nothing schedules any gate and the by-hand duties remain by-hand. | round 30 |
| freshness | 9 | Unchanged: every declared entry's re-verification link is gate-checked (`bash corpus/claim-ledger.sh docs`, row `R14-01`) and the 21 legacy entries stay the named gap. C2's BASE is a count, not a score move: §11 of `corpus/knowledge/op-ref-consumption.md` was measured on op 2.41.0 while `op --version` reads 2.41.1 (observed 2026-11-03), so the byte pin does not cite the installed version — `plans/round-32.md` §C2 BASE 0. | round 29 |
| calibration | 9 | Kept at 9, reason stated: the cell audit (`bash corpus/claim-ledger.sh cells`) completes to `CELL_AUDIT: POLICY (cells=222 row_pointed=162 stamp_pointed=103 policy=2)` with FAIL {`R25-02`} and POLICY {`R29-01`, `R29-02`} — all three operator-routed (the `PYTHON_SCRIPT_RE` registration is a gate-policy change; L0 line for `kagi`, round 30), so the instrument reports a red this lane cannot clear without an operator policy decision. The reds are named here and the score is neither raised nor lowered to hide them. Row `R31-01`; receipt `.ufo/waves/round-31/final/receipts/cells-at-tip.txt` lines 42–43, re-read 2026-11-03. | round 31 |
| adjacency | 9 | Unchanged: the ownership partition gate is green (row `R17-02`); OIDC/workload-identity ground is unclaimed by siblings (round-21/30 sweeps, re-swept in round 31 over 20 lanes with 0 hits). | round 31 |

## Round 32 — post-move (claims C1 calibration, C2 freshness)

C1 counts self-description mismatches (SD1–SD6) with a new counter and targets n = 0; C2 re-pins
`op` byte-evidence to the installed 2.41.1 (`op --version`, observed 2026-11-03). No predicate,
counter, kill rule or target moved: `plans/round-32.md` is the frozen contract, and every number
marked `[L1-FILL]` is the L1's to fill from its measured run. Both axes stand at the saturation
line, so the round records a mechanism landing, not a scalar move.

Frozen counting commands (verbatim, run from the lane root):

    bash corpus/self-description-sweep.sh

    V=$(op --version | awk '{print $1}')
    awk '/^## 11\./{f=1;next} /^## /{f=0} f' corpus/knowledge/op-ref-consumption.md | grep -c "op \`$V\`"
    bash corpus/op-ref-probe.sh --dotenv-bytes; echo "exit=$?"

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| calibration | 9 → 9 | C1 (SELF_DESCRIPTION): six prose observations become one counted predicate — SD1 frontier bullets naming a theme a Core bullet already holds, SD2 `## Frontier` tombstones in `corpus/README.md`, SD3 `SHONEN.md` evidence paths that do not exist, SD4 `M31-n` ids with no mistakes row, SD5 lane-status red ids absent from the latest calibration row, SD6 `claim-ledger.sh citations` UNRESOLVED lines. BASE sum 10 (2+2+0+1+3+2) → measured `[L1-FILL]`, target 0. The three routed reds `R25-02`, `R29-01` and `R29-02` stay named and red (operator-routed POLICY/FAIL: the counter reports a red the lane cannot clear without operator gate policy), so the score is kept at 9 with that reason and is not raised on a counter that cannot clear them. | Frozen C1 command above ⇒ last line `SELF_DESCRIPTION: [L1-FILL]`, exit `[L1-FILL]`; fix-pinning selftest `[L1-FILL]` planted-mismatch cases, each exiting 1 with its check named (a fixture that stays clean is a defect). Row `R31-01`. |
| freshness | 9 → 9 | C2 (BYTE_PIN): the installed version must appear in the §11 range of the byte contract and the six-class probe must exit 0 CLEAN on it; BASE counts 0 occurrences of the installed version in the §11 range and the probe's BASE line is `[L1-FILL]`. The 2.41.0 measurement is kept verbatim (append-only) and the new one enters as `### 11.1`, sourced by the new `S072` row. Bound: six classes only — nothing here says anything about ref-resolved values, item reads or the absent handler. | Frozen C2 commands above ⇒ first prints `[L1-FILL]`, `OP_DOTENV_BYTES: [L1-FILL]`, `exit=[L1-FILL]`. Row `R21-01` is the probe row; the §11.1 text must carry the version's byte line. |
| depth | 9 → 9 | No new mechanism claim: the round adds no knowledge entry and touches no held surface beyond the §11 range it appends to; the refusal bounds stand. | Row `R29-01`. |
| coverage | 9 → 9 | Registry 71 → 72 (`S072` only: the 1Password CLI 2.41.1 release-history row C2 rests on); no knowledge entry and no governed path surface is added or retired, and no registry `status`/`used-by` edit is expected. | `bash corpus/sources-census.sh` ⇒ `SOURCES_CENSUS: [L1-FILL]`, exit `[L1-FILL]`; rows `R21-02` and `R31-02` anchor `rows=71` and must migrate to `rows=72` with the census line re-recorded. |
| operability | 9 → 9 | One new runnable counter (`corpus/self-description-sweep.sh`, counts-only, exiting non-zero with the failing check named) and no new scheduling: the checklist's by-hand duties and the absence of a scheduler are unchanged, and the increment is claimed under C1 rather than double-counted here. | Row `R30-01`. |
| adjacency | 9 → 9 | The new counter reads this lane's own docs only; no sibling repo, `considerthese/` input or shokuknow source is edited, and the operator's gate-policy reds stay operator-owned instead of being absorbed as lane state. | Row `R17-02`. |

Measured revision, exact exits and receipts are appended after the measured revision lands; no
unrun result is stated here. A non-clean C1 or C2 is reported as a partial move with the output,
never re-scoped (`plans/round-32.md` kill rules).

**Move-log row (append to the scorecard's Move log table):**

    | 32 | calibration + freshness | 9 | 9 | C1 SELF_DESCRIPTION (SD1–SD6, target 0) + C2 BYTE_PIN (op 2.41.1 inside §11, six-class probe CLEAN); counts `[L1-FILL]`; `SCORECARD.md` §Round 32 — post-move |
