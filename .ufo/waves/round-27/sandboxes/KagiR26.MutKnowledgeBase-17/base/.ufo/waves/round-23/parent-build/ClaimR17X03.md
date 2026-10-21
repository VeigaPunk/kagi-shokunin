# ClaimR17X03 — R17-03 semantic audit (read-only)

Observed revision: `d218603b74099ddca0bd8f869516fc41db0979bf` (HEAD, no tracked
modifications). Frozen population confirmed at this revision: 43 command rows,
`corpus/claim-ledger.tsv` sha256 `e680696843637587…`, 58 lines / 17844 bytes =
`corpus/stamps.tsv:5`. In-flight and **untracked** (outside the frozen
population): `corpus/closure-dispositions.py` (mtime 2026-10-21 00:45),
`corpus/closure-dispositions.json` (00:46), `.ufo/waves/round-23/`;
`corpus/fixtures/cells-hermetic/` (`claims.tsv`, `SCORECARD.md`, `stamps.tsv`,
`corpus/fx-ok.sh`) landed untracked during this audit, as did
`corpus/source-fetches.tsv` and modifications to `corpus/SOURCES.md` /
`corpus/sources-census.sh` (other owners). The files this row depends on —
`corpus/claim-ledger.tsv`, `corpus/stamps.tsv`, `corpus/scope-gate.sh`,
`corpus/adjacency.tsv` — were unchanged at that point, so the frozen 43-row
population and R17-03's tuple are exactly as audited. No gate, row command,
handler or host probe was executed. All behavioral statements below are read
from source.

## 1. The row and what it actually measures

`corpus/claim-ledger.tsv:47`

```
R17-03  grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv  ^8$  0  30  <note>
```

Data: `corpus/adjacency.tsv` (83 lines, sha256 `4d9bfb11…`) declares eight
`# no-enumerate` rows at lines 67–74 and four `# breadth` pins at 75–78.
Partition: leaves = 67 `.local/bin`, 68 `.config/opencode`, 69 `.agents`,
70 `…/chrome-profile`; aggregates = 71 `.config`, 72 `.local/state`,
73 `.local/share`, 74 `.local/share/the-musketeer`. The split is correct under
the gate's rule (`corpus/scope-gate.sh:501–517`: a no-enumerate dir is a leaf
iff it has no strict descendant `# no-enumerate` or `# scan` dir; scans at
`corpus/surface-census.tsv:17–20`). The note's second clause is therefore
factually true, but it is **not produced by this command**.

Two ERE bounds decide what `^8$` can prove:
- `[[:space:]]+` also matches SPACE-separated lines, but the gate parses the
  TSV with `IFS=$'\t'` and skips a `#`-line with an empty second field as a
  comment (`corpus/scope-gate.sh:193–196`). R17-03 can therefore count a
  "declaration" the gate never enforces.
- The `.` stands where `$` sits; the eight real rows are measured bytes
  `# no-enumerate<TAB>$HOME/…` (`adjacency.tsv:67–74`). A literal `$` or a
  backslash cannot be expressed in a claim command at all: `META_RE` contains
  `$` (`corpus/claim-ledger.sh:163`) and a backslash is refused (`:184`), so
  `verify` would exit 2 POLICY (`:973–975`). The policy-legal tightening is
  `[[:cntrl:]]+` (space excluded, tab kept); the `$` wildcard is only
  removable inside the gate.

Verdict/exit/last-line/timeout — **supported**:
- 8 matching lines ⇒ `grep -c` exit 0, sole output line `8`; `^8$` is literal
  (passes the bare-anchor refusal at `corpus/claim-ledger.sh:414–415`).
- Deletion is doubly fatal: zero matches ⇒ exit 1 (≠ want 0) and last line `0`.
- 30 s against a 5660-byte single-file scan; the persisted run records
  `seconds: 0.002` (`.ufo/waves/round-22/final-verification.json`, R17-03).
- Policy-clean: first token `grep`, no metacharacter, no denied verb
  (`corpus/claim-ledger.sh:170–190`), so it runs everywhere.

## 2. Causality (not a count of authored lines)

- The ledger holds **43 rows but 42 distinct (command, expect, exit, timeout)
  tuples**. The single duplicate is exactly R16-06 (`claim-ledger.tsv:44`) ≡
  R17-03: all four fields byte-identical; only the note differs.
- This is not accidental: `adjacency.tsv:42` says "Ledger rows R16-04/R16-06 and
  R17-03 pin the real rows", and the lane has a declared-re-pin precedent —
  R18-03's note says "same isolated selftest as R11-09" and its expectation is
  *strengthened* with a trailing `$` (R11-09's is unanchored). R17-03 is a
  re-pin that neither declares the relation nor strengthens anything.
- Consequence for accounting, not for the verdict: R17-03 adds no falsifying
  power over R16-06. It is legitimate as the *data* pointer inside the
  Round-17 coverage cell (which does not cite R16-06), but "43 obligations" is
  42 independent measurements. C1/closure accounting must dedupe by tuple.
- The note's 4-leaf/4-aggregate claim is measured by `scope-gate.sh`
  R10/R12 (`:469–499`, `:501–517`), i.e. rows R16-01 (`claim-ledger.tsv:39`)
  and R17-01 (`:45`) — both `[substrate]`-tagged — and by the stamped prose in
  `corpus/knowledge/adjacency-breadth.md:66–77`. R17-03 measures cardinality 8,
  which is invariant under a 5-leaf/3-aggregate re-split.

## 3. Deferral, SKIP-SELF, hermetic mode

- **`[substrate]`**: correctly absent — the command reads one committed file
  and never touches `$HOME`. But the obligation it is used to support loses
  its measurement on an absent host: `substrate_present()`
  (`claim-ledger.sh:140–147`) defers all 11 tagged rows (`:416–419`), including
  R16-01/R17-01, and `verify` still prints
  `CLAIM_LEDGER: CLEAN (claims=43 deferred=11 …)` (`:982–983`). Deferral is
  documented as absence, not a pass (`corpus/knowledge/substrate-deferral.md`
  §Bounds 1).
- **SKIP-SELF**: does not apply. The rule tests the command for
  `*claim-ledger.sh*` (`claim-ledger.sh:811–819`); R17-03 is a `grep`, so it is
  re-run inside `cells`. R13-03 is the row the rule skips.
- **Hermetic synthetic mode**: R17-03 is hermetic-safe (no host read), so a
  fixture can and should exercise this exact tuple. C3 requirements in §5.

## 4. Consumer-visible risk (one, with minimal falsifier)

**Risk — `cells` can print `CELL_AUDIT: CLEAN` while the Round-17 coverage
cell's only measurement row was deferred and the boundary set changed at
constant count.** Mechanism, all from source:
1. `SCORECARD.md:301` cites `R17-01` (live derivation, tagged/deferred),
   `R17-02` and `R17-03` (count-only), plus the stamped doc. It does **not**
   name `corpus/adjacency.tsv`, so its stamp is not compared by `cells`
   (only `CEL_PATHS` are compared, `claim-ledger.sh:830–848`).
2. `cells` collects cited ids as a **union across all cells** (`:755–762`),
   re-runs them (`:806–829`) and treats `DEFER` as non-failing; CLEAN ignores
   `C_DEFER` (`:1005–1013`). `cells` never calls `verify_stamps` (dispatch
   `:969–987` vs `:995–1013`).
3. A count-preserving swap (replace 67–74's `$HOME/.agents` with
   `$HOME/.cache`, rewrite a line with spaces instead of a tab, or use a bogus
   `XHOME/.agents` line the `.HOME` wildcard also matches) leaves
   R17-03/R16-06 green at 8 and R17-02 green at 4; the gate would skip the
   space form as a comment (`scope-gate.sh:193–196`) and reject the other two
   as `ENUM-CLASH`. `scope-gate.sh:1009–1016` proves the gate catches this
   class, but it does not run when deferred.
4. Bounds: `verify` mode catches any content edit through `stamps.tsv:1`
   (`STALE`), so the exposure is specific to the `cells` entry point that
   R13-03 (and planned R23-01) certifies. Aggravators: `rows_run` counts
   deferred rows (`C_N` increments at `:415`, before the DEFER branch at
   `:416`; `CL_ROWS_RUN=$C_N` at `:828`), so "rows_run=2 row_deferred=1" means
   two considered, one executed; and the ERE's `.HOME` accepts one arbitrary
   character in place of `$` (`XHOME/…`, `/HOME/…`), so 8 counted lines do not
   prove eight `$HOME` declarations.

**Minimal synthetic falsifier (proposed, not executed).** Fixture root `F`:
- `F/adjacency.tsv`: 8 lines `# no-enumerate<TAB>$HOME/<name>`;
- `F/claims.tsv`: `A-01` = R17-03's exact tuple against `corpus/adjacency.tsv`;
  `A-02` = any count row over a fixture file whose note contains
  `[substrate]` (deferral arm);
- `F/scorecard.md`: one `## Round 1 — post-move` table, six axes, coverage cell
  citing `A-01`, `A-02` and a stamped fixture doc; `F/stamps.tsv` pins only
  that doc.
- Invoke with `KAGI_SUBSTRATE=absent` in the *environment* (not in a claim
  command — see below):
  `bash corpus/claim-ledger.sh cells --root F --claims F/claims.tsv --stamps F/stamps.tsv --scorecard F/scorecard.md --docs F/scorecard.md`.
- Predicted [INFERENCE from `:806–829`, `:1005–1013`]:
  `CELL_AUDIT: CLEAN (… rows_run=2 row_deferred=1 row_failures=0 …)` exit 0.
- Mutation: change one `# no-enumerate` line's path, same line count. Re-run →
  predicted still CLEAN. This is the false-clean: the count rows cannot see it
  and the derivation row is deferred.
- Required post-fix behavior: EITHER the fixture cell also cites the fixture
  `adjacency.tsv` as a stamped path (swap ⇒ `STALE-POINTER`, exit 1), OR the
  fixture adds a parse-only derivation row and the expected CLEAN line pins
  `row_deferred=0`.

Cheap fixes, in order: (a) add `corpus/adjacency.tsv` to the evidence column
of `SCORECARD.md:301` so `cells` compares its `stamps.tsv:1` pin; (b) change
`[[:space:]]+` to `[[:cntrl:]]+` in R17-03 and R16-06 — policy-legal (no
`$`/backslash; `claim-ledger.sh:163,184`), gate-exact for tabs, and it keeps
the count at 8 on the measured bytes 67–74; it still admits CR/VT separators
the gate ignores, and a literal `$` is unexpressible in a claim command, so
record both as bounds in the note; (c) per-cell deferral accounting, or a
stated rule that a cell citing a deferred row is unverified; (d) a parse-only
`scope-gate.sh --plan` (R10/R12 only, no enumeration) that validates
`$HOME`-anchored tab-separated declarations, derives leaves/aggregates and
compares the pin set hermetically — the only place the identity/wildcard
checks can be exact.

## 5. What C3 `cells` must retain for this row

1. **Obligation inventory.** The hermetic proof must list all 43 rows and mark
   R17-03 covered or out-of-scope with a reason; a fixture whose claims file
   holds three synthetic rows must not advertise `CELL_AUDIT: CLEAN` as
   coverage of the 43. (This is the claim-count trap the round is auditing.)
2. **Exact tuple in the fixture.** Include R17-03's command/expect/exit/timeout
   verbatim (TAB-separated 8-line data, 30 s) against a fixture-local adjacency
   copy, cited from a fixture cell. The plan's "fixture mutation case must
   fail" then has a real instantiation: delete one line ⇒ last line `7` ≠
   `^8$` ⇒ `CELL_AUDIT: BROKEN … row_failures=1`.
3. **Pin the summary.** R23-01's expected line must assert an exact
   `rows_run=N row_deferred=0`; a `[0-9]+`-permissive line (as R13-03 uses)
   admits a fixture where every cited row deferred. Remember `rows_run`
   includes deferred rows today.
4. **`--root` is not enough.** `--root` relocates only `ROOT`; `STAMPS`/`CLAIMS`
   still default to `corpus/` under the script dir (`claim-ledger.sh:102–106`),
   and stamp rows resolve as `$ROOT/$1` (`:359–372`). R23-01 must pass
   `--claims --stamps --scorecard --docs` explicitly.
5. **Never let a tagged row reach the host probe.** `substrate_present()` is
   called only for `[substrate]` notes (`:416`) and probes
   `$HOME/.local/bin/the-janitor` (`:146`); a claim command cannot override it
   — the policy allowlist refuses a leading `VAR=value`/`env`
   (`:170–174`). A host-free fixture must exclude tagged rows (declaring the 11
   out of scope) rather than include them.
6. **Do not inherit aggregate deferral.** For the real Round-17 cell the
   deferred row is R17-01; C3 should either fail/skip that cell explicitly or
   record per-cell `deferred` so `CLEAN` cannot be read as "the live result was
   re-measured".

**Landed fixture check.** `corpus/fixtures/cells-hermetic/` (untracked, read
2026-10-21 00:53) now holds: `claims.tsv` with `R90-01`
(`bash corpus/fx-ok.sh`, `^FX: OK$`, 0, 10) and `R90-02`
(`grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv`, `^8$`,
0, **10**); a `## Round 90 — pre-move` scorecard whose six axes cite
`R90-01`/`R90-02`, the freshness cell also naming `corpus/adjacency.tsv`;
`stamps.tsv` pinning `corpus/fx-ok.sh` (2 lines/38 bytes) and
`corpus/adjacency.tsv` (sha `c17f7e17…`, 9 lines/307 bytes — both measured
fresh); `corpus/fx-ok.sh`; and `corpus/adjacency.tsv` (9 lines, **0 tabs, 19
spaces**: eight space-separated `# no-enumerate` lines).
- Good: the count row now exists and the data file is both pinned and cited,
  so a count-preserving swap trips `STALE-POINTER`. The §4 swap exposure is
  closed **at fixture scale**; keep this shape.
- Defect in the fixture data: it is the space syntax the gate skips as a
  comment (`scope-gate.sh:193–196`). Measured on that file:
  `[[:space:]]+` = 8, `[[:cntrl:]]+` = 0. As landed, R90-02 proves the count
  over a shape `scope-gate.sh` never parses. Convert the eight lines to TAB
  separators (matching `adjacency.tsv:67–74`).
- The timeout is 10, not R17-03's 30: the tuple is a variant, not the exact
  obligation. Use 30 if the pair is to be called exact.
- Still no `[substrate]`/deferral arm. That is the correct host-free choice
  (§5.5); the deferral path must be declared out of scope, not silently
  absent.
- Inventory: 2 fixture rows vs 43 real rows; R23-01's expected line and the
  round lesson must state that ratio.

## 6. What C1 closure-disposition integration must retain for this row

- R17-03 is **not** one of C1's obligations: `parse_obligations` yields
  `D1–D9`, `SPOT-01..05`, `ADJ` (`corpus/closure-dispositions.py:76–102`), and
  the current in-flight `closure-dispositions.json` points every `fixed`
  pointer at `corpus/lessons/round-23.md`, never at the ledger. Nothing in C1
  may count R17-03 as an independent closed obligation; the ledger holds 42
  distinct measurements.
- If a disposition ever cites a claim row, the pointer must resolve to the
  **row**, not the file: `#anchor` matches only lines beginning with `#`
  (`:116–118`), so a TSV row cannot be anchored, and the `fixed` token test
  (`:132–137`) accepts any prose mention of the id anywhere in the file. Fix:
  for `.tsv` pointers split on TAB and require field 1 equality (or add a
  `#row:<id>` form). Latent today (no current mention of R17-03 outside its
  row).
- Integration arithmetic: if C3 adds R23-01 (and C1 adds any row), the active
  ledger moves — `stamps.tsv:5` must be re-pinned and R21-04
  (`claim-ledger.tsv:54`, expect `^43$`) updated in the same reviewed commit,
  with QM14 old/new migration evidence (`corpus/QUALITY.md:73`) and the
  append-only rule that duplicate active rows are not a way to preserve
  history (`corpus/knowledge/claim-ledger.md:474–487`). Do not "retire" R17-03
  without updating its four citations: `SCORECARD.md:301`,
  `adjacency-breadth.md:10`, `adjacency-scope.md:19`, `adjacency.tsv:42`.

## 7. Evidence classes

| Class | Item | State |
|---|---|---|
| current | `claim-ledger.tsv:47`; `adjacency.tsv:42,67–78`; `scope-gate.sh:501–517`; `stamps.tsv:1,5` (both fresh: measured sha matches) | observed at HEAD |
| current code | `claim-ledger.sh:140–147,415–419,755–829,1006–1013`; `closure-dispositions.py:76–137` | read, unexecuted |
| historical run | `.ufo/waves/round-22/final-verification.json` R17-03: exit 0, last `8`, 0.002 s | executed round 22; its `h1` binding is the subject of routed D6 (`round-22-verifier-spotcheck.md:177`) |
| historical snapshot | `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:47` — byte-identical to current row | frozen receipt |
| historical doc | `corpus/lessons/round-17.md:34` ("`R17-01..03`, scorecard/log updates") | prose, no relation declared |
| superseded | `SCORECARD.md:719` corrects the old "13 bounds" locator claim (not a bounds list) | already dispositioned; not reopened here |
| in-flight C3 | `corpus/fixtures/cells-hermetic/{claims.tsv (R90-01,R90-02),SCORECARD.md,stamps.tsv,corpus/fx-ok.sh,corpus/adjacency.tsv}` | untracked, 00:53 state; fixture data is space-separated; not in the frozen population; ledger/stamps unchanged |

## 8. Limits

- No execution: the row command, `scope-gate.sh`, `claim-ledger.sh` and
  `closure-dispositions.py` were not run; `rows_run`/CLEAN line predictions are
  code-derived inference, not observed output.
- Host substrate state was not probed; "absent" is taken from committed
  round-18/22 records (11 tags; `substrate-deferral.md`). On a present-substrate
  host R16-01/R17-01 run and the primary risk closes; the boundary-set check
  then depends on the gate, not on R17-03.
- The in-flight C1/C2/C3 files are untracked and may change under integration;
  C1 statements describe the 2026-10-21 00:45/00:46 snapshot, the C3 fixture the
  00:53 snapshot (R90-01/R90-02, space-separated data). The four files R17-03
  depends on were unchanged when checked. The separator probe on the fixture
  (`[[:space:]]`=8 vs `[[:cntrl:]]`=0) was a read-only grep on the fixture, not
  the row command; the real-file count was verified by byte inspection
  (`adjacency.tsv:67–74` all TAB).
- Representation caveat, latent (static read, no counterexample in shipped
  data): the leaf rule compares raw directive strings while membership expands
  `$HOME` (`scope-gate.sh:121–124,206,501–517`), so an equivalent absolute
  declaration would change the derived leaf set. R17-03 would fail such a
  rewrite (count 7), so it is bounded today; the parse-only plan row in §4(d)
  should normalize both sides.
