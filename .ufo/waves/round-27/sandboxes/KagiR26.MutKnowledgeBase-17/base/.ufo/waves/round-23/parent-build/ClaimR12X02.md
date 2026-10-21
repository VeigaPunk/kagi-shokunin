# ClaimR12X02 — R12-02 `op-ref-probe.sh --selftest`

**Observed revision.** `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20, round-22
non-author spot-check). Working tree also carries *untracked* round-23 scaffold
(`corpus/closure-dispositions.py`, `corpus/closure-dispositions.json`, `plans/round-23.md`,
`.ufo/waves/round-23/`) — `git status --porcelain` confirms `??` for all four. Everything below
that concerns C1 is therefore about an uncommitted file, not the base revision.

**Row under audit** (`corpus/claim-ledger.tsv:27`):

```
R12-02  bash corpus/op-ref-probe.sh --selftest   ^OP_REF_SELFTEST: PASS \(36 cases\)   0   300
```

**Method / limits.** Read-only static read of the probe (`corpus/op-ref-probe.sh`, 788 lines),
the ledger engine (`corpus/claim-ledger.sh`), `SCORECARD.md`, `corpus/QUALITY.md`, the round-20/21/22
records, and the round-23 plan + untracked C1 files. **No gate, handler, `op`, or vault command was
executed.** The only host probes were `command -v op` (a PATH lookup, no execution) and
`sha256sum`/`wc` on a source file. No tool installs were needed or made.

---

## 1. Verdict / last-line / exit — supported

- **Last-line shape.** `selftest()` prints `OP_REF_SELFTEST: PASS (%d cases)` only when
  `S_FAIL == 0` (`corpus/op-ref-probe.sh:746-750`); on any failure it prints
  `FAIL (n cases, m failed)` and `return 1`. The PASS line can therefore never coexist with a
  printed `FAIL case=` line. Observed: consistent.
- **Case count 36 is causally correct at this revision.** Static accounting from source:
  27 top-level `tcase` calls + the one inside `policy_case` (`:695`) executed 4× = 31 case checks;
  plus 5 paired `S_N` increments (`:679` once, `:697` four times) = **36**. This matches the
  independent round-22 decomposition (`31 + 5 = 36`, `.ufo/waves/round-22/build/Entry18.md:106-113`)
  — no re-derivation debt.
- **Exit 0 is entailed, not incidental.** `exit $?` from `selftest` (`:784`), so exit 0 ⟺ PASS line.
  Exit and last line are not independent assertions here; the row's two-column rule is satisfied
  either way.
- **Timeout 300 is justified with wide margin.** The selftest spawns 31 `bash "$SELF"` subprocesses,
  writes ~20 small fixtures, `mkfifo`×1, `chmod`×5, `mktemp`; it performs no network I/O, no `op`
  execution (all op-facing cases are `--evaluate` or die before `collect`), no vault call, and no
  read from a FIFO. 300s is also the modal value across the row class
  (of eleven selftest rows, eight use 300 and the three Python selftests use 120). `[INFERENCE]` no committed wall-clock
  receipt exists; the bound rests on the call graph above. Nothing in the case set can block.
- **Row policy.** `bash` is allowlisted, no metacharacters, and `op` inside
  `corpus/op-ref-probe.sh` does **not** trip `DENY_WORD_RE` because the following `-` is excluded
  from the boundary class (`corpus/claim-ledger.sh:163-166`). The row is runnable, not POLICY-refused.

## 2. Causality of the claimed classes — mostly supported; two prose mismatches

Every class named in the note has a discriminating seed at this revision: value (`:617`), masking
(`:621`), edge (`:625`), quoting (`:629`), precedence (`:633`), union (`:637`), inherited trim
(`:641`), signatures (`:658`), refs classification (`:606`, `:662`), malformed blindness (`:646`,
`:650`), SETUP paths (`:664-668`). Supported.

Two calibration mismatches in the note text (not verdict defects):

1. **"four POLICY cases"** — the source seeds **five** POLICY fixtures and 10 paired checks:
   `policy-ref-token` plus `policy_case` ×4 (`absent-present`, `adir-is-a-file`, `env-symlink`,
   `env-fifo`, `:677-699`). The note's four *classes* (ref token, symlink, FIFO, premise break) cover
   them, but the count is one fixture short of the source.
2. **The POLICY fixtures do not discriminate clauses.** `poison_symlink` writes a ref token into the
   symlink target and `poison_absent`/`poison_adir_file` write tokens into the premise files
   (`:701-704`), so all three are still refused by the `op://` rule if their specific clause is
   deleted. Only `env-fifo` (no token) discriminates non-regular refusal. The stale/alike redundancy
   is already admitted for other checks in the entry's own §8.11(a)
   (`corpus/knowledge/op-ref-consumption.md:239-250`); this instance is not listed there.
   Consequence: "refusal before exec" is proven as a *property*; per-clause immunity is not.

## 3. `[substrate]` deferral — untagged is correct, but one case silently reads the host

- Deferral triggers only on the literal note tag (`corpus/claim-ledger.sh:416-419`;
  `corpus/knowledge/substrate-deferral.md:47-58`). R12-02 is untagged — correct for the *execution*
  test: the selftest never execs the handler or `op`, so tagging it would be wrong (a deferred row is
  "not measurable here", not a pass, and would silently drop a hermetic obligation on exactly the
  hosts that can still prove it).
- **However**, `tcase janitor-binary-missing` (`:667-668`) overrides only `OP_REF_JANITOR_BIN`.
  `verify()` checks `command -v "$OP_BIN"` **before** the janitor (`:483-486`), and `OP_BIN` defaults
  to the host's `op` (`:69`). On a host with no `op` on `PATH` the probe dies
  `SETUP (op binary not found: op)` with exit 2, which matches the wanted exit but **not** the case
  pattern `SETUP \(janitor binary not executable` → one case fails → last line
  `OP_REF_SELFTEST: FAIL (36 cases, 1 failed)`, exit 1.
- This is exactly `QM4`'s weak signal — "a case … that fails only on a substrate-absent host"
  (`corpus/QUALITY.md:42`) — and the same class as round-18 defect 1, which was fixed in
  `corpus/surface-census.sh:821-823` by printing `skip-case … substrate-absent`
  (`corpus/lessons/round-18.md:31-41`). `op` is a declared substrate dependence for the live row
  R12-01 (`corpus/claim-ledger.tsv:26`) but is undeclared and unneeded for this one.

**Primary consumer-visible risk — false-fail (evidence-supported, static).**
This host has `/usr/bin/op` and no handler; R12-02 is green here *only* because of that binary.
A host-free runner (the shape C3 is chartered to build, `plans/round-23.md` item 3) that strips
`op` from `PATH` turns R12-02 red although nothing about the comparator is broken; `cells` then
reports `row_failures=1`/`CELL_AUDIT: BROKEN` (`corpus/claim-ledger.sh:1005-1012`), because
R12-02 is cited by scorecard cells (`SCORECARD.md:93`, `:641`) and `cells` re-runs every cited row
that does not invoke `claim-ledger.sh` (`:806-820`). Nothing in the ledger or cells runner supplies
the documented override `OP_REF_OP_BIN`.

**Minimal synthetic falsifier (proposal for L1; not executed here).**
Build a PATH containing only symlinks to the tools the selftest needs, and no `op`:

```bash
tmp=$(mktemp -d); mkdir -p "$tmp/bin" "$tmp/tmp" "$tmp/home"
for t in bash env grep awk sed cut tr sort comm head tail mktemp mkdir chmod mkfifo rm ln; do
  ln -s "$(command -v "$t")" "$tmp/bin/$t"
done
env -i HOME="$tmp/home" TMPDIR="$tmp/tmp" PATH="$tmp/bin" \
  /bin/bash corpus/op-ref-probe.sh --selftest
# predicted today: FAIL case=janitor-binary-missing ... out=<OP_REF_PROBE: SETUP (op binary not found: op)>
#                  OP_REF_SELFTEST: FAIL (36 cases, 1 failed), exit 1
```

**Fix (deterministic, no skip needed).** In that one case, also point `OP_REF_OP_BIN` at an
executable stub (the same scratch stub the POLICY cases already build), e.g.
`env OP_REF_OP_BIN="$d/op-stub" OP_REF_JANITOR_BIN=/nonexistent/kagi12-jan bash "$SELF" --fixture "$c"`.
`verify()` dies at the janitor check before `collect`, so the stub is never executed — the case
stays hermetic and the 36 count is unchanged. Then the falsifier above must print
`PASS (36 cases)`, exit 0. (Do **not** fix this by tagging `[substrate]`.)

## 4. SKIP-SELF and hermetic cells — obligation preserved today; C3 must keep it

- **SKIP-SELF does not touch R12-02.** The skip test is the literal command containing
  `claim-ledger.sh` (`corpus/claim-ledger.sh:815-820`); R12-02's command contains
  `corpus/op-ref-probe.sh`. So `self_skipped` is unaffected and the row is re-run by `cells`.
  Verified by reading, not by running.
- **`cells` is not hermetic today.** `cells_evidence` hands the cited rows to `verify_claims`
  unchanged; `verify_claims` executes `timeout -k 5 … bash -o pipefail -c "$cmd"` with the inherited
  environment and no `KAGI_SUBSTRATE`/PATH scrub (`:423`; `cells_evidence` at `:799-824`). R12-02 therefore inherits
  the host's `op`, which is precisely why §3's leak is latent rather than visible here.
- **What C3 (`R23-01`, `plans/round-23.md` item 3) must retain for this row:**
  1. R12-02 must remain *run* (not skipped, not deferred) in any run that claims to preserve
     command-row obligations; `rows_run` is the counter that proves it.
  2. A fixture-root `cells` run that cites only synthetic rows proves the *machinery*, not R12-02's
     comparator. If the goal sentence "preserve all command-row obligations" is to hold, the
     hermetic run must either include the real row (with `OP_REF_OP_BIN` supplied, or the §3 fix
     landed) or state explicitly that real-row semantics stay with `verify`/`R13-03`.
  3. If the hermetic harness scrubs PATH and *also* runs real `corpus/*.sh` rows, R12-02 is the first
     row that will false-fail; land §3's fix before wiring it in, or the C3 proof will be red for a
     host reason and invite the wrong remedy (a `[substrate]` tag).

## 5. C1 closure-disposition integration — what it must not absorb

`corpus/closure-dispositions.py` (untracked) parses 15 obligations from
`corpus/lessons/round-22-verifier-spotcheck.md` (`D1-D9`, `SPOT-01..05`, `ADJ`). **R12-02 is not
one of them**, so C1 cannot certify this row directly. Three retention points:

1. **Pointer ≠ content.** `resolve_pointer` (`corpus/closure-dispositions.py:80-103`) only proves the
   file exists, the `#` anchor matches a heading, and the obligation id appears as a token in the
   file body. The module's own docstring states the bound: "A `fixed` pointer proves a reviewed
   record exists at that path, not that its content is correct" (`:8-13`). A disposition that names
   `R12-02` would pass even if the row's expectation were stale. The number that closes this
   obligation is the row's current `expect` (36) reconciled with the source-derived composition
   (31+5) — a claim-count assertion (`` `grep -c` of authored lines ``) is not that reconciliation.
2. **Historical vs current counts must be resolved by pointer, not by presence.** The current
   documents carrying `29 cases` are: `corpus/knowledge/op-ref-consumption.md:276` (explicitly
   superseded by the correction note at `:371-374`, and by the erratum at `:375-385`);
   `SKILL.md:643` (**unmarked, current-voice, still wrong by 7** — round-21 named this debt and left
   it because the same line carries the reference-scheme token, `corpus/lessons/round-21.md:87`);
   and the dated historical records `LOG.md:329,469`, `SCORECARD.md:93,619`,
   `corpus/lessons/round-12.md:21`, `corpus/lessons/round-19-recensus.md:14`. A C1/C2 checker that
   only counts occurrences of the obligation id will treat `SKILL.md:643` as agreement. Under QM1
   (`corpus/QUALITY.md:39`) it is a live freshness defect; it is pre-existing and already named,
   not newly authored.
3. **Integration order.** All seven `fixed` rows in `corpus/closure-dispositions.json` point at
   `corpus/lessons/round-23.md` / `…/#Routed defect dispositions`, which does not exist yet
   (`ls` → absent; `plans/round-23.md` is untracked). Until that lesson lands, `resolve_pointer`
   returns `POINTER-MISSING` for every `fixed` row, so C1's stated acceptance
   (`CLOSURE_DISPOSITIONS: CLEAN (obligations=15 …)`) is unreachable in the commit tree. Flagged to
   the C1 owner via KagiR23, not claimed as this row's verdict.

## 6. Secondary false-clean risk (calibration, not a proven production defect)

The row's ERE has `^` but **no `$`**, and the ledger applies it to the last non-empty line with
`[[ $last =~ $expect ]]` (`corpus/claim-ledger.sh:436-444`) — a prefix match. A verdict line such as
`OP_REF_SELFTEST: PASS (36 cases) skipped=1` would pass this row although QM3
(`corpus/QUALITY.md:41`) forbids skips that are not counted by the verdict. The ledger's own
`verdict-not-final` case (`:1317`) tests a *trailer line*, not a same-line suffix, so nothing covers
this. Falsifier: on a scratch `--claims` file, point this row's command at a fixture script that
prints exactly that line and exits 0; `verify` reports CLEAN. Fix: terminate the ERE with `$`
(the ledger's literal rule at `:414` still passes; `R12-03` already uses `^70$`).

## 7. Historical vs current evidence

| item | evidence | status |
|---|---|---|
| 36-case pin | `corpus/claim-ledger.tsv:27`; source composition `op-ref-probe.sh:595-750`; `Entry18.md:106-113` | **current, supported** |
| 36 observed at runtime | `corpus/lessons/round-20.md:21` (`PASS (36 cases)`, exit 0); `corpus/lessons/round-21-verifier-spotcheck.md:17` (29→36 re-pin, op 2.41.0) | historical receipt, matches current source |
| 29 cases | 29 = the pre-`aea7a43` pin; `corpus/lessons/round-12.md:116` records the 15→21→29 chain | **historical / superseded** |
| 21 cases | erased count in the entry's §10 | historical (`op-ref-consumption.md:375-385` erratum) |
| probe stamp | `corpus/stamps.tsv:55` = `0f1945e8…  788  34362`; measured `sha256sum`/`wc -lc` identical | **fresh** (QM5 satisfied) |
| row stability | round-22 frozen before copy `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv` R12-02 = `36 \| 0 \| 300`; current identical | unchanged since freeze |

## 8. Remaining unknowns

- No committed wall-clock measurement of `--selftest`; the 300s justification is structural
  (`[INFERENCE]`). A future row could pin a duration only by executing the gate.
- The op-less-host failure is derived from source order; per contract it was **not** executed. The
  synthetic PATH falsifier above is the acceptance test for the fix.
- Whether C3's fixture-root design will cite real rows is not yet written down (`plans/round-23.md`
  item 3 is prose only; `corpus/fixtures/cells-hermetic/` does not exist), so §4.2 remains a
  requirement to state, not an observed property.

Report: .ufo/waves/round-23/parent-build/ClaimR12X02.md
