# XC1Measure: round-27 C1 counting instrument (draft, unrun)

- Lane: kagi-shokunin. BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`, contained by `refs/heads/master` and `refs/jj/keep/0a47dd…`.
- Author: KagiR26.XC1Measure-17 (leaf executor). Milestone: round-27 C1 (knowledge-entry number binding). C2 is not assessed here.
- Draft: `.ufo/waves/round-27/sandboxes/XC1Measure/c1-measure.py` (286 lines, stdlib only, mode set executable by the write tool).
- Status: written, **not executed, not parsed**. No run of the instrument, the gate, any selftest, any ledger row, or any build, lint or format. Unrun checks are not passes.
- BASE citations are `file:line` in the BASE tree, read from `.ufo/waves/round-27/sandboxes/XC1Measure/base/` (a `git archive` of BASE: SKILL.md, PROVINCE.md, corpus/; 107 members). "WT" means the uncommitted working tree. "[INFERENCE]" marks a prediction that rests on a ledger pin standing in for a live value.
- Tools: none installed or upgraded. Host already had Python 3.14.8 and git 2.56.0 (version queries only). No labrat dispatched.

## 1. Bottom line

1. The draft implements the requested contract (§2). Nothing about it is verified yet.
2. **Backreference locators break the one-digit red control.** Four candidate rows use `\1` (§5.4). A one-digit change to their captured number makes the line UNLOCATED, not STALE. The plan's sentence "a one-digit knowledge-entry mutation turns the binder STALE" is false for these rows as written.
3. **The candidate table is moving and uncommitted.** Its knowledge rows went 18 → 16 → 22 across this session, and two rows disappeared (§5.2). The instrument reads committed revisions only, so L1 must commit a frozen table before counting.
4. Static prediction, BASE docs with the candidate table: exit 1, stale 4 (3 static, 1 [INFERENCE]), unlocated 0, ambiguous 0 (§5.3). Not measured.
5. `.ufo/waves/round-27/tools/c1-measure.py` (4.1 KB, not mine, already present when I started) breaks the spec in at least 12 checkable ways (§4). I did not reuse its code and do not recommend promoting it.

## 2. Instrument contract (draft)

Command: `c1-measure.py DOCS_REV TABLE_REV LABEL [--mutate ID] [--json PATH]`

| Behaviour | Where in draft |
|---|---|
| Scratch dir from `mkdtemp(prefix="kagi-r27-c1-", dir=/fast/scratch)`; refuses if `/fast/scratch` is not a directory | `c1-measure.py:46`, `:198–203` |
| Lane found by walking up from the file for `corpus/self-counts.py` beside `.git`; works from `tools/` and from `sandboxes/<name>/` | `:79–83` |
| Revisions resolved with `git -C lane rev-parse --verify --quiet <rev>^{commit}`; names starting with `-` or containing whitespace refused | `:86–91` |
| Table bytes from `git -C lane show <table-sha>:corpus/self-counts.tsv` (lane object store, so unreachable table commits still work) | `:207` |
| Clone: `git clone --quiet --no-checkout --no-hardlinks <lane> <scratch>/lane`, then `checkout --detach <docs-sha>`; table bytes written into the clone | `:217–221` |
| Binding count and knowledge count computed by the instrument from the table, using the gate's data-row rule | `:94–97`, `:198–264` |
| Environment exactly `PATH`, `HOME=<scratch>`, `LC_ALL=C` | `:204` |
| Gate: `python3 -B corpus/self-counts.py`, cwd = clone, stdin DEVNULL, timeout 3600 s | `:48`, `:100–104` |
| Accounting: verdict ids (`OK/STALE/UNLOCATED/AMBIGUOUS/POLICY/SETUP <id>`) compared with table ids → `accounted` | `:100–137` |
| `--mutate ID`: measure; bump the first digit of group 1 on the unique located line (+1, or −1 for a 9 so the result stays one digit); measure again | `:144–177` |
| Judge: PASS iff ID was OK before, is STALE after, gate exit 1, and ID is the only newly flagged id; INCONCLUSIVE if ID was not OK before; otherwise FAIL | `:179–191` |
| Exit: normal mode returns the gate's exit; mutate mode 0 on PASS else 1; instrument error 3 | `:257`, `:264` |
| Writes: scratch only (removed in `finally`), plus optional `--json` | `:258–262` |

Deviation from the literal spec: mutation is `+1` except `9 → 8` (never a carry or a leading zero). Stated in the docstring.

## 3. BASE gate facts (cited)

| Fact | BASE cite |
|---|---|
| Exit 0 CLEAN, 1 STALE (incl. UNLOCATED/AMBIGUOUS), 2 POLICY/SETUP | `corpus/self-counts.py:35` |
| Default table `corpus/self-counts.tsv`; default root = parent of the script | `:53`, `:559` |
| Reads are `read_text(encoding="utf-8")` (universal newlines) | `:68–70` |
| Data-row rule: nonblank and first non-space char not `#` | `:88–90`, `:95–96` |
| Six nonempty columns; valid id; duplicate id is SETUP | `:99–105` |
| Locator and extract must have exactly one capture group | `:110–117` |
| `ledger:` refuses `[host]`/`[substrate]` notes; allowlist `bash grep python3`; verify/cells recursion refused; host consent refused | `:259–260`, `:265–266`, `:267–272`, `:273–274` |
| `ledger:` exit mismatch is SETUP | `:298–299` |
| Live output = last nonempty line | `:300–303` |
| Locator must match exactly one doc line (zero → UNLOCATED, many → AMBIGUOUS) | `:326–336` |
| Claimed value must be a nonnegative integer | `:338` |
| `rows:` live = data-row count of the file | `:339–341` |
| `expect:` = ledger column 3 (the pin), never executed | `:342–348` (pin read at `:344`) |
| `ledger:` live = extract of last output line | `:349–356` |
| Per-binding verdict, stale counter, print | `:357–359` |
| Per-binding GateError → POLICY/SETUP line | `:360–362` |
| Summary lines | `:370–371` (STALE), `:373` (CLEAN) |

Every binding produces exactly one verdict line, so "accounted" is a sound invariant to check.

## 4. Counterexamples to `.ufo/waves/round-27/tools/c1-measure.py` (A1F5, not mine; wave file, uncommitted)

1. Four positional arguments (adds `OUT.json`) against the three-argument contract: `:32–34`.
2. Environment not whitelisted: adds `PYTHONDONTWRITEBYTECODE` at `:37–38`.
3. Gate run as `python3 -I -B` (`:62`), not `-B`. Harmless here, still a deviation.
4. Bump `(d+1) % 10` at `:58` wraps 9 → 0; `96` becomes `06`, a leading-zero form the gate accepts.
5. **The red control cannot fail.** `--mutate` only records the change (`:61`) and prints (`:72–73`). Nothing asserts the mutated id is STALE, so a binder that never reports STALE still exits 0.
6. Table read with `git -C clone show` (`:43`). A table commit not reachable from the clone's refs raises an unhandled `CalledProcessError`.
7. Row rule differs from the gate: `if line and not line.startswith("#")` (`:45`). A whitespace-only line crashes at `r[1]` (`:46`, IndexError). An indented `  # note` counts as a binding; the gate does not (`self-counts.py:95–96`).
8. `LANE = Path(__file__).resolve().parents[4]` (`:22`) only works at `.ufo/waves/round-27/tools/`. From `sandboxes/<name>/` it resolves to `.ufo`, and the clone fails.
9. Gate call `timeout=1500` (`:62–63`) with no `TimeoutExpired` handling.
10. Unknown `--mutate` id → unhandled `StopIteration` (`:49`).
11. Text I/O without encoding or newline handling (`:51`, `:60`). Latent: the ten docs the candidate table references have no CR (§5, DOC-HYGIENE check).
12. Clone omits `--no-hardlinks` (`:41`), so objects are hardlinked to the lane. Minor isolation point.

## 5. Static reads (no gate run, no ledger row run)

Method: the gate's locator and table rules applied with Python `re` to the BASE copies. `rows:` live values are data-row counts of BASE files. `expect:` values are the BASE ledger's column 3 extracted by the binding's regex. `ledger:` values are **not** executed.

### 5.1 BASE table: `corpus/self-counts.tsv:15–52`, sha256 `ceadba89…`, 7,752 bytes, 38 bindings

- Every locator matches exactly one BASE doc line (38/38). No UNLOCATED or AMBIGUOUS.
- 11 statically checkable (`rows:` 7, `expect:` 4): all OK.
- 27 `ledger:` bindings: each claimed value equals its ledger pin (static) [INFERENCE: live = pin]. Example: `SC-SKILL-STAMPS` claims 89 at `SKILL.md:46`; pin R12-03 is `^89$` at `corpus/claim-ledger.tsv:28`.
- Static BASE-block verdict: 11 OK, 27 unexecuted, 0 STALE, 0 UNLOCATED.

### 5.2 Candidate table: working tree, uncommitted

- Snapshot: sha256 `67d5d1db…`, 12,366 bytes, 60 data rows: the 38 BASE rows (lines 15–52) and 22 KN rows at lines 58–79.
- History in this session: first read had 18 KN rows (lines 58–75, including `KN-LEDGER-REPRO-CLAIMS` at :68 and `KN-LEDGER-REPRO-STAMPS` at :69); the audit read had 16 (58–73); the last read had 22 (58–79). The two LEDGER-REPRO rows are gone. WT `corpus/knowledge/claim-ledger.md:301` now reads `claims=N stamped=M`, with the old values moved into history (see §5.5).
- Six of the ten docs the table references differ between WT and BASE at audit time: SKILL.md, PROVINCE.md, corpus/README.md, knowledge/claim-ledger.md, knowledge/op-ref-consumption.md, knowledge/surface-census.md. The instrument ignores WT entirely.

### 5.3 Static verdicts for the 22 KN rows against BASE docs

| Row (candidate line) | BASE doc:line | claimed | source | live / pin | predicted |
|---|---|---|---|---|---|
| KN-OPREF-REPRO-SELFTEST (:70) | op-ref-consumption.md:276 | 29 | expect:R12-02 | 36 (claim-ledger.tsv:27) | **STALE** |
| KN-OPREF-FALSIFY-SELFTEST (:79) | op-ref-consumption.md:296 | 21 | expect:R12-02 | 36 | **STALE** |
| KN-CENSUS-DRIFT-SYMBOLS (:73) | surface-census.md:32 | 19 | rows:drift-symbols.tsv | 20 | **STALE** |
| KN-LEDGER-REPRO-SELFTEST (:68) | claim-ledger.md:304 | 72 | ledger:R11-09 | pin 170 (claim-ledger.tsv:23) | **STALE** [INFERENCE] |
| KN-DRIFT-BOUND-FILES (:69) | drift-gate.md:143 | 15 | rows:drift-baseline.tsv | 15 | OK |
| KN-CENSUS-DRIFT-FILES (:72) | surface-census.md:32 | 15 | rows:drift-baseline.tsv | 15 | OK |
| KN-OPREF-CORRECTION-SELFTEST (:71) | op-ref-consumption.md:374 | 36 | expect:R12-02 | 36 | OK |
| KN-BREADTH-FALSIFY (:59) | adjacency-breadth.md:155 | 18 | expect:R16-03 | 18 | OK (backref) |
| KN-BREADTH-FALSIFIERS (:75) | adjacency-breadth.md:158 | 18 | expect:R16-03 | 18 | OK |
| KN-SCOPE-CURRENT-FALSIFY (:61) | adjacency-scope.md:17 | 18 | expect:R16-03 | 18 | OK (backref) |
| KN-SCOPE-TABLE-FALSIFY (:63) | adjacency-scope.md:155 | 18 | expect:R16-03 | 18 | OK (backref) |
| KN-SCOPE-MUTATIONS (:64) | adjacency-scope.md:269 | 18 | expect:R16-03 | 18 | OK |
| KN-SUBSTRATE-CENSUS-SELFTEST (:76) | substrate-deferral.md:44 | 16 | expect:R11-03 | 16 | OK |
| KN-SUBSTRATE-ABSENCE-FILES (:77) | substrate-deferral.md:50 | 15 | expect:R18-01 | 15 | OK |
| KN-BREADTH-SCOPE-SELFTEST (:58) | adjacency-breadth.md:152 | 61 | ledger:R16-02 | pin 61 (tsv:40) | OK [INFERENCE] |
| KN-SCOPE-CURRENT-SELFTEST (:60) | adjacency-scope.md:16 | 61 | ledger:R16-02 | pin 61 | OK [INFERENCE] |
| KN-SCOPE-TABLE-SELFTEST (:62) | adjacency-scope.md:155 | 61 | ledger:R16-02 | pin 61 | OK [INFERENCE] |
| KN-CHECKLIST-SELFTEST (:65) | checklist-execution.md:63 | 34 | ledger:R15-02 | pin 34 (tsv:34) | OK [INFERENCE] |
| KN-CHECKLIST-FALSIFY-ROWS (:66) | checklist-execution.md:173 | 16 | ledger:R15-04 | pin 16 (tsv:36) | OK [INFERENCE] |
| KN-CHECKLIST-FALSIFY-ITEMS (:67) | checklist-execution.md:179 | 16 | ledger:R15-04 | pin 16 | OK [INFERENCE: items = rows] |
| KN-CHECKLIST-FALSIFY-FLOOR (:78) | checklist-execution.md:179 | 8 | ledger:R15-05 | pin floor=8 (tsv:37) | OK [INFERENCE] |
| KN-BREADTH-LINES (:74) | adjacency-breadth.md:148 | 4 | ledger:R17-02 | pin `^4$` (tsv:46) | OK [INFERENCE] |

Predicted for BASE docs + candidate table: exit 1, stale 4 (rows marked STALE), unlocated 0, ambiguous 0. Only the 4th STALE row depends on a pin standing in for a live run. Not measured.

### 5.4 Backreference rows defeat the one-digit red control

Four candidate locators use `\1` (equality of two captured numbers): KN-BREADTH-FALSIFY (`adjacency-breadth.md:155`, pattern `caught=([0-9]+)/\1 failed=0`), KN-SCOPE-CURRENT-FALSIFY (`adjacency-scope.md:17`), KN-SCOPE-TABLE-FALSIFY (`adjacency-scope.md:155`), and KN-LEDGER-REPRO-SELFTEST (`claim-ledger.md:304`, pattern `# ([0-9]+) scratch cases … PASS \(\1 cases\)`).

Changing the captured first digit breaks the `\1` equality, so the line no longer matches. The gate then reports UNLOCATED (exit 1), which is not STALE and does not change `stale=`. The instrument returns FAIL ("mutated binding is UNLOCATED, not STALE") for these rows. [INFERENCE from regex semantics; not run.]

Use a non-backreference control, e.g. `KN-DRIFT-BOUND-FILES` (`drift-gate.md:143`, `15` → `25`).

### 5.5 Table notes and population changes

Notes that say "at BASE" for numbers BASE does not carry. BASE's own docs name those numbers as round-21 history:

| Row (BASE table line) | Note | BASE doc at cite | Where the old number lives in BASE |
|---|---|---|---|
| SC-SKILL-CLAIMS (:16) | "said 63/39 at BASE" | SKILL.md:46 "89 stamps + 65 claims" | corpus/README.md:64–65 "39 at round 21", "63 at round 21" |
| RD-LEDGER-ROWS (:46) | "said 39 at BASE" | README:64 "65 rows" | README:64 "39 at round 21" |
| RD-STAMPS (:47) | "said 63 at BASE" | README:65 "89 rows" | README:65 "63 at round 21" |
| RD-DOCS-ROWLINKED (:48) | "said 21 at BASE" | README:67 "22 row-linked" | README:67 "21/3/24 at round 21" |
| RD-DOCS-ENTRIES (:50) | "said 24 at BASE" | README:67 "25 pinned" | README:67 "24 at round 21" |
| RD-LEDGER-SELFTEST (:45) | "said 97 at BASE" | README:63 binds 170 | provenance of 97 not located (not searched further) |

Internal disagreements in BASE (static):
- `surface-census.md:32` says "19 symbol pins"; `drift-symbols.tsv` has 20 rows; `PROVINCE.md:47` says 20. KN-CENSUS-DRIFT-SYMBOLS is STALE at BASE.
- `op-ref-consumption.md:276` says "29 cases"; pin R12-02 is 36 (`claim-ledger.tsv:27`); the same file says 36 at `:374`.
- `op-ref-consumption.md:296` says 21; pin is 36.
- `claim-ledger.md:304` says 72 cases; pin R11-09 is 170 (`claim-ledger.tsv:23`).

Population change to decide explicitly:
- BASE `claim-ledger.md:301` carries `claims=17 stamped=33`. The pins are 65 (`claim-ledger.tsv:54`, R21-04) and 89 (`:28`, R12-03). Kept as numbers, both would be STALE.
- The candidate table dropped `KN-LEDGER-REPRO-CLAIMS` and `KN-LEDGER-REPRO-STAMPS`. WT `claim-ledger.md:301` now reads `claims=N stamped=M`, with the old values as history.
- Plan C1 says stale numbers are corrected and bound. Replacing them with placeholders is neither. Restore the bindings or record the population change in the table header.

## 6. Counting commands for L1 (not run)

```
python3 .ufo/waves/round-27/tools/c1-measure.py <BASE-sha> <table-commit> c1-base
python3 .ufo/waves/round-27/tools/c1-measure.py <after-docs-sha> <table-commit> c1-after
python3 .ufo/waves/round-27/tools/c1-measure.py <after-docs-sha> <table-commit> c1-red --mutate KN-DRIFT-BOUND-FILES
```

Expected per plan: c1-base exit 1 with stale 4 [INFERENCE]; c1-after exit 0, stale 0; c1-red PASS.

Prerequisites: `/fast/scratch` exists (verified as a directory; writability not probed); the table and docs commits are reachable from `refs/heads/master` (BASE is). Cost: mutate mode runs the gate twice, and ledger rows carry their own timeouts (`claim-ledger.tsv` column 5).

## 7. Not checked

- Not run: the instrument (mine or A1F5), the gate, any selftest, any ledger row, any build/lint/format. No syntax check either, so the draft is unparsed.
- Not probed: `/fast/scratch` writability and free space (existence only; I wrote nothing there).
- Not measured: live ledger outputs (27 BASE + 9 candidate rows). Every ledger-bound prediction is pin-based [INFERENCE].
- Not final: the candidate table and the WT docs. The "after" docs do not exist yet.
- Not checked: whether `claim-ledger.sh` or other ledger commands need more of the lane than a clone gives them.
- Not checked: `RD-LEDGER-SELFTEST`'s "97" provenance; clone time on this lane.
- Not assessed: freshness (C2, release-clock). Out of this seat's scope.
- Not touched: host-private paths, op.env, tokens, sessions, vault, CDP, lane Git index or jj state. Git was used read-only (`show`, `rev-parse`, `for-each-ref`, `cat-file`, `archive`, `--version`). No git writes.
- No installs, upgrades, commits, pushes, or writes outside the sandbox and this report.

## 8. Recommendations to L1

1. Commit a frozen table before counting. Never measure the working tree.
2. Fix the six "at BASE" notes in §5.5, or name the round each value comes from.
3. Use a non-backreference row for the red control (`KN-DRIFT-BOUND-FILES`). Decide how the four backreference rows (§5.4) will be counted: split them into two bindings, or record UNLOCATED as the designed outcome.
4. Decide the KN-LEDGER-REPRO-CLAIMS/STAMPS population change explicitly (§5.5).
5. Do not promote A1F5. If it is kept, fix §4 items 1–7 first.
6. Treat "stale 4" as a prediction. Any other number at c1-base means a pin is not the live value, or the table has changed since this snapshot.
