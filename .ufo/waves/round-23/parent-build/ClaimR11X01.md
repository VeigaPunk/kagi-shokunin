# ClaimR11X01 — semantic audit of ledger row R11-01

Scope: one frozen command obligation, read-only. No gate, handler, host probe, or
sibling gate was executed. Observed revision: `d218603b74099ddca0bd8f869516fc41db0979bf`
(2026-10-20T21:11:59-03:00, "round-22 verifier spot-check"). Working tree also holds
untracked `.ufo/waves/round-23/` and untracked `corpus/closure-dispositions.{py,json}` +
`corpus/__pycache__/` (in-flight C1, not committed; not treated as evidence). No tool
installed or updated; none needed. During the audit the lane's L1 landed concurrent
working-tree changes (`corpus/claim-ledger.tsv`, `corpus/claim-ledger.sh`,
`corpus/SOURCES.md`, `corpus/sources-census.sh` modified; `corpus/fixtures/` and
`corpus/lessons/round-23.md` new). R11-01 at `corpus/claim-ledger.tsv:15` is
byte-identical before and after; all findings are against that row text and the
`d218603` implementation, with the concurrency recorded where it changes an
integration count (§8.4, §9).

## 1. The obligation as frozen

`corpus/claim-ledger.tsv:15`:

```
R11-01  bash corpus/surface-census.sh
        ^SURFACE_CENSUS: CLEAN \(assets=[1-9][0-9]* runtime=[1-9][0-9]* scanned=[0-9]+ ok=[1-9][0-9]*
        exit 0  timeout 300
        note: declared surfaces + runtime shapes (round 10) [substrate]
```

Ledger mechanics (`corpus/claim-ledger.tsv:1-5`, `corpus/claim-ledger.sh:400-446`):
`expect` is a **prefix** ERE matched with `[[ $last =~ $expect ]]` against the last
non-empty line of combined stdout+stderr; exit must equal column 5. Policy allows
`bash` as first token with no metacharacters (`claim-ledger.sh:160-164`), so the row's
command passes unchanged.

## 2. Implementation trace (observed, static)

- Dispatch: `corpus/surface-census.sh:852-869`. `verify` runs `load_census`,
  `verify_surfaces`, `verify_unlisted`, `verify_shapes`; then
  `if [[ $FAILED -eq 0 ]]` prints the CLEAN line (`:859-863`) and `exit 0`;
  otherwise prints DRIFT (`:865-867`) and `exit 1`. No output follows CLEAN; the EXIT
  trap (`:116-121`) prints nothing. ⇒ **last-line and exit are causally tied to the
  verdict**, not to an authored string.
- Every non-OK surface/shape verdict sets `FAILED=1`: DIVERGED/GONE/LINK/UNLISTED/
  CROSSCHECK (`:186-237`), SHAPE/SHAPE-UNVERIFIED (`:344-430`). ⇒ exit 0 is reachable
  only when no drift/defect was observed (ABSENT/SKIP are exit-neutral by design).
- Field provenance (`:859-863`):
  - `assets`, `runtime` = counts of declared classes in `corpus/surface-census.tsv`
    (`ROW_CLASS`), i.e. **declaration counts**, not verification counts.
  - `scanned` = `${#SCAN_DIR[@]}`, collected only from `# scan` comment directives
    (`:155-160`).
  - `ok` = `N_OK`, incremented **only** in `verify_surfaces` (`:235`); shapes never
    increment it.
  - `absent` = shared counter for missing *runtime surfaces* (`:189-197`) **and**
    missing *shape rows* (`:344-347`).
- Current data: `corpus/surface-census.tsv:17-20` declares four scan dirs; `:21-55`
  declare 20 `asset` + 15 `runtime` rows (matches `R11-11`=`35`, `:25`);
  `corpus/state-shape.tsv:27-48` declare 22 rows (matches `R11-10`=`22`, `:24`).
- Implementation freshness: `git diff 301b9ec d218603 -- corpus/surface-census.sh`
  contains **only** the round-18 selftest skip branch (`:818-830`); the verify path and
  emitter are byte-identical to the row's round-11 contract. `surface-census.tsv`
  changed only a note since round 10 (`client.py` note); `state-shape.tsv` gained the
  round-22 erratum comment (`:49-53`), no row/value change. ⇒ **the expectation is not
  stale against the current emitter.**

## 3. Verdict on the expectation

| facet | finding | confidence |
|---|---|---|
| last line | supported: CLEAN is the final stdout write before `exit 0`; trap silent | observed |
| exit 0 | supported: biconditional with `FAILED==0`; all drift classes set it | observed |
| emitter text | supported: ERE is an exact prefix of `:859`; `^` anchored | observed |
| timeout 300 | justified as a hang bound only: local `stat`/`find`/sqlite snapshot, no network, no `op`, no handler start. No runtime receipt exists for the verify path; 300 is not performance evidence | observed/inference |
| counts pin the docs? | **refuted**: the row admits `scanned=0` and does not pin 20/15 or `ok=34`. This is the round-22 Entry21 §D gap, extended below | observed |
| live current verdict | unresolved under this contract (no execution). Committed evidence (round-18 lesson `:1-13`; round-22 `safe-row-plan.json`, `final-verification.json` skipped R11-01 "Host/substrate-dependent … Not executed") records substrate absent ⇒ the row would **DEFER**, not PASS | [INFERENCE] from committed receipts |

`ok=[1-9][0-9]*` is causally redundant under CLEAN: if `assets>=1` and the run is
CLEAN, every declared asset is present and therefore OK, so `ok >= assets >= 1`.
It cannot independently detect degradation.

Historical line, `2026-09-28` (round 10, re-quoted through round 14):
`SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)`
(`corpus/knowledge/surface-census.md:9-11`; `SCORECARD.md:49`; `PROVINCE.md:8`).
The `absent=2` reading as one missing runtime surface plus its missing shape row is an
[INFERENCE] from the shared counter (`surface-census.sh:193` and `:346`) and
`ok=34 = 20+14`; no per-line round-10 receipt is archived. `PROVINCE.md:8`'s phrase
"`absent=2` runtime rows" is therefore imprecise (the counter mixes surfaces and
shapes), but no row pins `absent`, so nothing fires.

## 4. `[substrate]` deferral — justified, with a named blind spot

`substrate_present` is `[[ -x "$HOME/.local/bin/the-janitor" ]]`, overridable by
`KAGI_SUBSTRATE` (`claim-ledger.sh:130-146`); a tagged row prints
`DEFER <id> reason=substrate-absent` and is never policy-checked or run
(`:415-418`). The tag is correct for this row: CLEAN requires the handler binary,
`client.py`, `op.env`, the state tree, etc. (`surface-census.tsv:21-38`), so on an
absent host the honest output is DRIFT exit 1, not a claim failure. Deferral prevents
that false-fail and is documented as host state, not forgiveness
(`corpus/knowledge/substrate-deferral.md:60-78`). Residual bound: the row is skipped
**whole**, so residual non-handler surfaces (e.g. `$HOME/.local/state/tac`,
chrome-profile NMH) are also not re-checked while the handler is absent. That is a
conservative loss, not a false-clean, because the expected line requires CLEAN, which
is unreachable without the handler.

## 5. SKIP-SELF — not applicable, and must stay that way

`cells` skips a cited row only when its command token contains `claim-ledger.sh`
(`claim-ledger.sh:810-819`); R11-01's command is `corpus/surface-census.sh`, so it is
**re-run** by `cells` (14 scored SCORECARD table cells cite `R11-01`) and counts as
`row_deferred`, never `self_skipped`. When the substrate is absent, `R13-03` itself
carries `[substrate]` (`claim-ledger.tsv:38`) and defers, so no cells summary is
produced at all on this host. Any round-23 host-free mode must not
broaden SKIP-SELF into "any host-touching row": that would silently convert R11-01's
obligation into a skip, and `R13-03`'s ERE accepts any `self_skipped` value.

## 6. Hermetic synthetic mode — cannot satisfy this row

`surface-census.sh` supports `--census/--shapes/--baseline/--root` (`:77-83`), used by
its selftest (`:761-766`). R11-01's frozen command passes none of them, and `ROOT`
defaults to `$HOME` (`:76`). Therefore a synthetic run can prove the *contract shape*
("the emitter's CLEAN line still matches this ERE on a scratch tree") but **cannot**
satisfy the row's host claim. Do not label fixture coverage as this row passing; the
round-22 plan already uses the correct wording, "Fixture coverage is separate from live
verification" (`.ufo/waves/round-22/safe-row-plan.json`, skipped R11-01 entry).

## 7. One concrete consumer-visible false-clean risk

**Claim.** `scanned=[0-9]+` accepts zero enumeration, and no sibling row pins the scan
set. On a substrate-present host whose declared paths otherwise match the CLEAN
baseline, deleting `corpus/surface-census.tsv:19`
(`# scan  $HOME/.local/state/the-janitor/xdg-data/opencode`) yields
`scanned=3`; deleting all four `:17-20` yields `scanned=0`. Both still match R11-01 and
exit 0, because `verify_unlisted` returns immediately when `SCAN_DIR` is empty
(`surface-census.sh:239-242`). The handler data root (`xdg-data/opencode`, 5 declared
children) then loses its UNLISTED check — the same undeclared-child class as round 6,
now in the data root rather than `$CONFIG_DIR`.

**Why no sibling catches it** (static analysis): `R11-11` counts non-`#` lines only
(`claim-ledger.tsv:25`), so a comment deletion leaves 35; `R16-01`'s `OWN-UNLISTED`
requires a scan dir only for each exact `# own` prefix (`scope-gate.sh:448-466`;
`adjacency.tsv:48-52`), and `:19` is a descendant of `$STATE`, not an own prefix;
`census=${#c_path[@]}` counts data rows only (`scope-gate.sh:265`); adjacency
`# no-enumerate`/`# breadth` rows cover other dirs (`adjacency.tsv:67-78`); stamps
guard only unreviewed bytes, and a reviewed declaration edit re-pins them.

**Consumer-visible:** `SCORECARD.md:49` (and `:61`) cites `R11-01` for "4 enumerable
dirs whose undeclared children are `UNLISTED`", and `PROVINCE.md:34` / `SKILL.md:34`
state the same. The row a reader is told to trust cannot distinguish 4 from 0.

**Minimal synthetic falsifier (proposal; not executed here — L1 to run):**
1. Reuse the census selftest scratch builder `build_tree` + `write_data`
   (`surface-census.sh:700-760`); no host path, no handler.
2. Write `$R/census-mutated.tsv` = the fixture census with all three `# scan` lines
   removed. Leave the tree unchanged (all fixture children declared).
3. Run `bash corpus/surface-census.sh verify --root "$R/host" --census
   "$R/census-mutated.tsv" --shapes "$R/shapes.tsv" --baseline "$R/baseline.tsv"`.
4. Expected observed (to be confirmed on the fixture): exit 0, last line
   `SURFACE_CENSUS: CLEAN (assets=3 runtime=7 scanned=0 ok=10 absent=0 skipped=0)`.
5. Apply R11-01's current ERE to that line → **it matches** (false-clean reproduced).
   Apply the proposed `scanned=[1-9][0-9]*` (or `scanned=4`) → no match, so the fixture
   is red as a fix test should be.

**Fix options, both integration decisions for L1:**
- (a) tightest minimal edit: change R11-01's ERE to `scanned=4` (docs and data both say
  four; a count change then needs a QM14 old/new migration like `R11-11`/`R11-10`).
  `scanned=[1-9][0-9]*` is only a stopgap: deleting one of four still passes.
- (b) keep the frozen row and add a static count row
  (`grep -c '^# scan' corpus/surface-census.tsv` ⇒ `^4$`), analogous to `R11-10/11`.
  Neither option alone proves *which* dirs; `R16-01` R8 confines scans to owned
  prefixes, which is the existing semantic guard.

## 8. What C3 (hermetic cells) must retain for this row

1. R11-01 stays in the live ledger unchanged and in the 43-row population
   (`R21-04`=`43`, `claim-ledger.tsv:54`). Its disposition in the round is
   **DEFER (substrate-absent)**, never "verified by fixture".
2. The fixture claims file must **exclude** R11-01 and the other ten `[substrate]`
   rows (`claim-ledger.tsv` lines 15,16,17,18,20,26,33,38,39,41,45; `R18-02`=`11`).
   With `KAGI_SUBSTRATE=present`, including it would execute the live `$HOME` census
   inside the "host-free" proof; with absent, it would emit `DEFER` and make
   `row_deferred` non-zero, breaking an exact `CELL_AUDIT: CLEAN (… row_deferred=0 …)`.
   The fixture landed during this audit holds only `R90-01` (`bash corpus/fx-ok.sh`,
   untagged; `corpus/fixtures/cells-hermetic/claims.tsv`), which satisfies this
   exclusion.
3. No new skip class may absorb non-self rows. `substrate_present` ignores `--root`
   and reads the real `$HOME` (`claim-ledger.sh:140-146`), but it is short-circuited
   by the tag (`:415`); an untagged fixture therefore never touches the host. Keep it
   that way; a fixture that needs env overrides cannot express them in a policy-clean
   row (`env` is not in `ALLOWED_RE`, `:160`).
4. The concurrent integration adds `R23-01`/`R23-02`: `R21-04` moves 43→45 and
   `R13-01` 25→27. Neither new row carries `[substrate]`, so `R18-02` stays 11.
   Both moves need explicit migration records; they do not change R11-01.
5. If C3 wants contract evidence for this row, use the synthetic mode in §7 step 3
   and compare the emitted CLEAN line against R11-01's ERE on the scratch tree —
   labeled contract evidence, not the host claim.

## 9. What C1 (closure dispositions) must retain for this row

- The in-flight checker's obligations are D1–D9, SPOT-01..05, ADJ (15); **R11-01 is
  not one of them**. The concurrent integration gives the checker its own row
  (`R23-02`, `python3 corpus/closure-dispositions.py`), but a
  `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 …)` still must not be read as closure
  of any claim row, least of all this one.
- `resolve_pointer` resolves a path + optional heading + the obligation id
  (`corpus/closure-dispositions.py:104-130`, call site `:187-191`), not the row a
  note *names*. D9's `fixed` record names "R23-01" but its pointer is prose
  (`corpus/lessons/round-23.md#Routed defect dispositions`); it would resolve even if
  R23-01 or the fixture were absent. If any disposition cites a row as its evidence,
  the checker must resolve the actual row pointer (id present in
  `corpus/claim-ledger.tsv`, command/expect/exit/timeout read from it) and record the
  row's current disposition (for R11-01: deferred, substrate-absent), not a count.
- The round-22 Entry21 §D precedent stands: the headline numbers this row is cited for
  are not pinned by the row; C1 must not convert "row exists / 43 rows" into
  "census coverage holds".

## 10. C2 (fetch/quote provenance) — out of population, must stay historical

R11-01 has no public URL. Its quoted numbers are host observations at named dates
(2026-09-28/29), not active public evidence. `corpus/source-fetches.tsv`/`SC_FETCH`
cover SOURCES rows only; C2 must not claim fetch provenance for this row, and any
round-23 report quoting `assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0` must
label it historical. The round-22 erratum pattern (`state-shape.tsv:49-53`) is the
model.

## 11. Remaining unknowns / limits

- Current live verdict and current host state: not observed (execution forbidden).
  Committed round-22 receipts record the substrate as absent; whether the host still
  matches that is [UNRESOLVED].
- Whether the four scan dirs still exist/enumerate: [UNRESOLVED] (host state).
- The historical `absent=2` composition is inferred from code, not from an archived
  per-line receipt.
- The 300 s bound has no measured runtime receipt; it is defensible only as a hang
  bound.
- In-flight `corpus/closure-dispositions.{py,json}` are untracked and may change
  before integration; §9 describes the version observed, not a committed contract.

## 12. Prior art / non-duplication

Round-22 `Entry21.md` §D already found that R11-01's positive-count ERE does not pin
the headline 20/15/34 figures and suggested a future split pin. This report does not
repeat that: it adds (a) the `scanned=0` semantic hole and its uniquely unguarded
`xdg-data/opencode` directive, (b) the exact causal field map (declaration vs
verification counters, shared `absent`), and (c) the C3/C1/C2 retention requirements
for this specific row.

## Cites

`corpus/claim-ledger.tsv:15,24,25,38,54`; `corpus/surface-census.sh:76-83,116-121,155-160,186-237,239-242,334-430,700-760,818-830,852-869`;
`corpus/surface-census.tsv:17-20,21-55`; `corpus/state-shape.tsv:27-48,49-53`;
`corpus/claim-ledger.sh:130-146,160-164,400-446,810-819,1002-1012`;
`corpus/knowledge/surface-census.md:7-14,240-250`; `corpus/knowledge/substrate-deferral.md:1-10,60-78`;
`corpus/lessons/round-18.md:1-13,45-49`; `corpus/lessons/round-11.md:151`;
`corpus/scope-gate.sh:241-265,448-466`; `corpus/adjacency.tsv:48-52,67-78`;
`plans/round-23.md:30-38`; `SCORECARD.md:49,61`; `PROVINCE.md:8,34`; `SKILL.md:34`;
`.ufo/waves/round-22/safe-row-plan.json` (skipped R11-01), `.ufo/waves/round-22/final-verification.json` (skipped_rows R11-01).
