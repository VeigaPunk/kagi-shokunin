# ClaimR21X01 — R21-01 `op-ref-probe.sh --dotenv-bytes` (semantic audit)

Seat: ClaimR21X01 (leaf, read-only). Base/HEAD read: `d218603b74099ddca0bd8f869516fc41db0979bf`.
Row owner: this seat only; no judgment/admission authority claimed. No installs were needed
(nothing recorded). No gate, handler, `op`, vault or host command was executed; nothing in
production was modified. Evidence is static read of the committed tree, `sha256sum`/`wc -lc`,
`git rev-parse`/`git diff --stat`/`git show`, and package metadata (`pacman -Q 1password-cli`).

## 1. The obligation as frozen

`corpus/claim-ledger.tsv:51` (fields verbatim, TAB-separated):

```
R21-01
bash corpus/op-ref-probe.sh --dotenv-bytes
^OP_DOTENV_BYTES: CLEAN \(checks=6 failed=0\)$
0
120
op-only byte contract (round 21 admission of the arm landed in aea7a43): six generated
plain-value dotenv classes run through `op run --env-file` under `env -i` with scratch
HOME/XDG (no ref, no account, no handler), stdout hex-compared to literal measured bytes;
measured CLEAN on op 2.40.0 (round 20) and 2.41.0 (2026-10-19). Proves representation
fidelity only; an op-side failure (sign-in, timeout, missing binary) also reads as DRIFT
exit 1 today, so a red row is not by itself a byte change (round-21 reviewer finding M1)
```

Consumer (`corpus/claim-ledger.sh:424-444`): run under `cd "$ROOT"`, `timeout -k 5 120`, capture
stdout+stderr, drop blank lines, take the **last** line, Bash-regex match `expect`, exit must
equal `want`. Timeout 124/137 is `reason=timeout`, not a defer (`:429-431`).

## 2. Is the expectation justified? — supported (causal, not count-decorative)

| element | causal chain | verdict |
|---|---|---|
| `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)` is the last line | `dotenv_bytes` (`op-ref-probe.sh:519-552`) prints one `DOTENV_BYTES_CASE` line per case (`:504`, `:506`), then calls `evaluate_bytes` (`:551`), whose only clean exit is the printf at `:516`. op's stderr is diverted per case to `$WORK/stderr` (`:544`), `od`/`tr` output never leaves command substitution (`:547`), and the EXIT trap (`:146-151`) is a bare `rm -rf`/`rm -f`. Nothing writes after `:516`. | supported |
| `checks=6` | `DOTENV_BYTE_CONTRACT` holds exactly six rows (`:135-142`: escaped-lf, trailing-lf, newline-only, single-literal, double-multiline, single-multiline); `i` counts observation rows (`:495`, `:509`); `checks=%d` is that `i` (`:516`). A 7th contract row → `die … extra observation row` exit 2 (`:496-497`); a missing row → `failed += 6-i` (`:511`) → `DRIFT` exit 1. So the literal `checks=6 failed=0` entails exactly six rows in contract order. | supported |
| each PASS is a byte equality with `rc==0` | `:499-501` enforces id order + numeric rc + hex charset + no extra field; `:503` requires `rc == 0 && hex == want`; `want` is literal measured hex, not derived from the fixture. | supported |
| `exit 0` | `evaluate_bytes` returns 1 at `:514` and 0 at `:517`; `dotenv_bytes` returns it (`:551`); byte-mode dispatch does `exit $?` (`:775`). No other 0 path; SETUP paths die 2 (`:521-530`, `:548`, `:770`). | supported |
| `120` s | inner bound is 6 × `timeout 10` (`:262`) = 60 s soft; the inner `timeout` has no `-k`, so the hard bound is the ledger's `timeout -k 5 120` (`claim-ledger.sh:427`). Measured total in the round-22 receipt: **0.043 s** (≈2800× headroom). | supported |
| policy-clean | `bash corpus/op-ref-probe.sh --dotenv-bytes` has no metachar/backslash/empty-quote; the deny word `op` does not match inside `op-ref-probe.sh` because the following `-` is in the allow class (`claim-ledger.sh:162-186`). | supported |

Executed receipt (frozen, round 22): `.ufo/waves/round-22/final-verification.json`,
`safe_rows[id=R21-01]` — `exit: 0`, `last: "OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)"`, six
`DOTENV_BYTES_CASE … status=PASS` lines, `seconds: 0.043`, `h1: 8ada17a5…`. In the same run
`skipped_rows` contains **R12-01** (the live `op-ref-probe.sh` row) as host/substrate-dependent —
the byte row was the only op-invoking row that executed.

Receipt still applies at HEAD: `git diff --stat 8ada17a..HEAD -- corpus/op-ref-probe.sh` is empty
(the probe is unchanged since `aea7a43`), and the `R21-01` line hashes identically at `8ada17a`
and HEAD (`4113617f9b01…`). Only neighbouring rows and stamps moved. The frozen pre-image
`.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:51` is textually identical.

Stamps at HEAD (`corpus/stamps.tsv:5,15,29,55`) match recomputation exactly:
`claim-ledger.tsv e6806968… 58/17844`, `claim-ledger.md e914e2ac… 488/33222`,
`op-ref-consumption.md 4b89d3b9… 384/25991`, `op-ref-probe.sh 0f1945e8… 788/34362`. Host state
observed: `1password-cli 2.41.0-1` owns `/usr/bin/op`; `$HOME/.local/bin/the-janitor` is absent.
Frozen population `43` matches an independent row-id count and `plans/round-23.md:3-5`.

## 3. Deferral, SKIP-SELF, hermetic mode — what each does to this row

### [substrate] deferral — correctly inapplicable; tagging it would be harmful
- The tag is literal `[substrate]` in the note (`claim-ledger.sh:416-418`); the predicate is
  `[[ -x "$HOME/.local/bin/the-janitor" ]]` (`:140-147`). R21-01 has no tag and `dotenv_bytes`
  never references `JAN_BIN` (`op-ref-probe.sh:519-552`) — so the row **runs and can pass on a
  handler-absent host**, which is exactly the round-22 receipt.
- Do **not** "fix" this by adding `[substrate]`: it would DEFER a measurable, passing row on this
  host (a false DEFER that loses the obligation) and would change `R18-02`'s `^11$` count pin
  (`claim-ledger.tsv:49`).
- The real asymmetry: the sibling live row **R12-01 is tagged** and its note names the `op`-on-PATH
  dependence plus `SETUP exit 2` (`claim-ledger.tsv:26`), while R21-01 depends on the same binary
  (strictly less: no handler) and is untagged. The deferral mechanism has one predicate for a
  two-dependency situation. Consequence: with `op` absent, R21-01 becomes
  `FAIL R21-01 reason=exit-mismatch exit=2 want=0` and `CLAIM_LEDGER: FAIL (… failed=1 deferred=0 …)`
  — a claim failure, not an unmeasurable obligation, while R12-01 (superset dependence) would DEFER.

### SKIP-SELF — does not apply; `cells` does re-run this row
- SKIP-SELF tests the command for `*claim-ledger.sh*` (`claim-ledger.sh:816-819`). R21-01's command
  contains `op-ref-probe.sh`, so it is **written to the re-run set** (`:821-828`) and executed by
  `verify_claims` inside `cells`.
- Causal consequence on this host: `R13-03` (the `cells` row) is itself `[substrate]`-tagged
  (`claim-ledger.tsv:38`), so `verify` DEFERs the entire cell audit here. The scorecard cells that
  cite R21-01 — `SCORECARD.md:641` (depth) and `:645` (freshness); `:454` is the move-log table and
  is not an axis cell — therefore rest on the round-22 receipt, **not** on a current cells re-run.
  R21-01 is neither skipped nor deferred; it is simply not reached, because its auditor is deferred.

### Hermetic synthetic mode — comparator only, cannot carry the obligation
- `--dotenv-bytes --evaluate F` dispatches straight to `evaluate_bytes` (`op-ref-probe.sh:766-775`):
  no `command -v op`, no `op_exec`, no process. The selftest's `bytes-faithful` case already proves
  this path prints `CLEAN (checks=6 failed=0)` exit 0 from a hand-written file (`:716-724`). The
  entry states the same limit at `op-ref-consumption.md:254-258`.
- A hermetic cells proof (C3, `plans/round-23.md:32-39`) that includes R21-01 as an `--evaluate`
  row would therefore publish the exact expected verdict while measuring nothing. That is the
  false-clean C3 must design out, not a defect of the row (the row itself runs live).

## 4. Consumer-visible risk + minimal synthetic falsifier (proposed, not executed)

**Risk (supported).** R21-01 is an untagged row whose subject is an external package, and the row
note (and `op-ref-consumption.md:363`) misdescribe the one failure mode that *is* distinguished:
both say "missing binary … reads as DRIFT exit 1", but `dotenv_bytes:525-526` dies
`OP_DOTENV_BYTES: SETUP (op binary not found)` with **exit 2**. So a triager following the note
looks for a byte drift where the instrument actually reported "not measurable". The ledger folds
both into `reason=exit-mismatch`, differing only in the `exit=` field (`:433`), and — with no tag —
into `deferred=0`.

**Falsifier A — untagged external absence is reported as a claim failure (proposal; L1 to run).**
```
printf 'X1\tbash corpus/op-ref-probe.sh --dotenv-bytes\t^OP_DOTENV_BYTES: CLEAN \\(checks=6 failed=0\\)$\t0\t120\ttest\n' > /tmp/r21-01.tsv
OP_REF_OP_BIN=/nonexistent/op bash corpus/claim-ledger.sh verify --claims /tmp/r21-01.tsv
```
Predicted from source: row emits `OP_DOTENV_BYTES: SETUP (op binary not found)` and exits 2; the
ledger prints `FAIL X1 reason=exit-mismatch exit=2 want=0` then
`CLAIM_LEDGER: FAIL (claims=1 failed=1 deferred=0 …)`, exit 1. That falsifies the note's
"missing binary → DRIFT exit 1" sentence and shows the obligation has no unmeasurable class.
(The `--claims` override isolates the row; stamps/idref still run read-only on the real root.)

**Falsifier B — hermetic substitute produces the verdict without the measurement (proposal).**
```
printf '%s\n' $'escaped-lf\t0\t616c7068610a62657461' $'trailing-lf\t0\t616c7068610a0a' \
  $'newline-only\t0\t0a' $'single-literal\t0\t616c7068615c6e62657461' \
  $'double-multiline\t0\t616c7068610a62657461' $'single-multiline\t0\t616c7068610a62657461' \
  > /tmp/r21-obs.tsv
env -i PATH=/usr/bin:/bin bash corpus/op-ref-probe.sh --dotenv-bytes --evaluate /tmp/r21-obs.tsv
```
Predicted: `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0, zero `op` processes. This is the
selftest's own `bytes-faithful` case; it is the exact shape a hermetic cell must not count as R21-01.

**Fix recommendation (smallest correct).** Append an erratum to the row note and
`op-ref-consumption.md:363`: *sign-in or timeout → DRIFT exit 1; missing `op` binary → SETUP
exit 2; a TERM-ignoring `op` → ledger `reason=timeout exit=124`*. A note-only change to the ledger
still moves the executable TSV snapshot, so it needs a stamps re-pin and an old/new migration
record (`plans/round-23.md:44-46`; `corpus/QUALITY.md` QM14). If an unmeasurable class is wanted,
add a **separate** tagged predicate on `command -v op` (and update `R18-02`'s count in the same
change) — never reuse `[substrate]`.

## 5. What C3 cells / C1 closure-disposition integration must retain

C3 (hermetic, host-free cells):
1. Classify R21-01 **`live-op`**, not `synthetic`: its only carrier is 1password-cli. Keep the row
   and its frozen receipt in the obligation set; do not let the fixture root's `CELL_AUDIT: CLEAN`
   be read as this row's re-verification.
2. A fixture that omits R21-01 must **count** the omission; the current machinery has only
   `self_skipped` and `row_deferred` (`claim-ledger.sh:1006-1012`), neither of which fits. Add a
   counted external/not-run class so the obligation is preserved visibly rather than dropped.
3. `R23-01`'s fixture should include at least one row with an external dependency and assert it is
   counted as not-run — that proves the mechanism preserves obligations, which a stub-op "PASS"
   would not.
4. Preserve the pin's shape exactly (six ids, contract order, literal hex, `checks=6`), and keep
   `R13-03`'s skip reason explicit (`plans/round-23.md:38-39`); on this host the cell audit itself
   defers, so the fixture path is the only future route to the R21-01-citing cells.
5. Never point the hermetic `cells` fixture at the real probe with the real `op` (host-free), and
   never give a stub the expected bytes.

C1 (closure dispositions):
1. `corpus/closure-dispositions.py:76-102` parses only D1–D9/SPOT-01..05/ADJ (15 obligations);
   claim rows are outside it. `obligations=15` must never be read as covering R21-01.
2. If the note/prose correction is recorded as `fixed`, the pointer must resolve to
   `corpus/claim-ledger.tsv` (or `corpus/op-ref-probe.sh`) **and** the checker must verify the row
   content (expect/exit/timeout), not just the id token. `resolve_pointer` (`:104-123`) currently
   accepts any occurrence of `R21-01` in the target file for `fixed`, and a `#anchor` proves only a
   heading exists — a lesson saying "R21-01 was wrong" would satisfy it. That is precisely the
   "claim-count assurance" failure mode C1 exists to prevent.
3. Record the obligation as **active/measured**, not closed: `KINDS` has no `active` kind
   (`:60`), so either add one or use `no-action` with a note that the row stays live under the
   op-release clock. A `fixed` disposition here would falsely close a recheck obligation.
4. Carry the **subject version** (`1password-cli 2.41.0-1`) with the receipt/disposition. The
   round-22 receipt has no version field (`final-verification.json` safe_rows: id/argv/expected/
   exit/stdout/last/seconds only), while the claim is version-scoped; the version currently lives
   only in prose (`claim-ledger.tsv:51`, `op-ref-consumption.md:315-319`, `SCORECARD.md:641`).
5. Do not migrate or restamp the row silently: any note edit is an executable-TSV change and needs
   the old/new record (`plans/round-23.md:44-46`; QM14).

## 6. Historical vs current evidence (for C2-style separation)

| assertion | status | pointer |
|---|---|---|
| six byte classes measured CLEAN on op 2.40.0 | historical (round 20), unchanged contract | `op-ref-consumption.md:310-319` |
| reviewer M1: op-side failures read as DRIFT not SETUP; failing rows print no hex; comparator-only selftest; stdin not redirected; usage omits the arm | historical round-21 debt, still open | `corpus/lessons/round-21.md:86` |
| `OP_REF_SELFTEST: PASS (29 cases)` | superseded (now 36) | `op-ref-consumption.md:276`, correction `:371-373`; `R12-02` pins 36 |
| "21 cases" comparator count | superseded, explicitly historical | `op-ref-consumption.md:296-299`, erratum `:375-384` |
| R21-01 executed, exit 0, 0.043 s, six PASS lines | active frozen receipt at `8ada17a` | `.ufo/waves/round-22/final-verification.json` |
| "R21-01 … not executed" | honest non-execution by a different (falsification) lane, not a contradiction of the verifier receipt | `.ufo/waves/round-22/falsify/ReopenSource05.md:248` |
| op 2.41.0-1 installed | current host fact | `pacman -Q 1password-cli` |

## 7. Limits

- No execution: the row, `claim-ledger.sh`, `op-ref-probe.sh` and every sibling gate were not run
  (contract). The current-behaviour statements come from source plus the committed round-22
  receipt; Falsifiers A/B are predictions, not observations, and L1 must run them.
- I did not invoke `op --version` (op command forbidden); `2.41.0` is read from the package
  metadata, which is consistent with the receipt's date and the note.
- The receipt was produced at `8ada17a`, one commit before HEAD; I proved the row text and the
  probe bytes are identical across that span, but the receipt's other 30 rows are outside my row.
- Not assessed: macOS/BSD portability (the arm is Linux-shaped: GNU `timeout`, `od -tx1`), and
  whether an `op` release that keeps these six byte outputs but changes other dotenv semantics
  should move the freshness cell — that over-read is bounded in prose (`op-ref-consumption.md:355-365`)
  but not machine-checked.
- Secondary bounds observed, not raised as defects: three of six cases share the expected hex
  `616c7068610a62657461`, so a generator mutation that swapped single/double quoting for the
  multiline pair is invisible to the comparator (the selftest pins the comparator, not the
  generator); the EXIT-trap `rm` (`op-ref-probe.sh:146-151`) runs after `exit $?` and any diagnostic
  would become the last line (`verdict-not-final`); an exported shell function named `op` would
  resolve to the bare name and fail 127 under `env -i` (false-fail).
- Working-tree note (outside my row): `corpus/closure-dispositions.{py,json}` and
  `plans/round-23.md` are untracked at HEAD, `corpus/lessons/round-23.md` (cited by every `fixed`
  disposition) does not exist, and `corpus/fixtures/` is absent — C1/C3 Before/After must be
  adjudicated on the final commit, not this worktree.

Report: .ufo/waves/round-23/parent-build/ClaimR21X01.md
