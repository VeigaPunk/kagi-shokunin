# ClaimR16X01: R16-01 (`bash corpus/scope-gate.sh`) semantic audit, round 23 attempt 1

Seat: `ClaimR16X01` (critic, leaf, read-only). Axes: calibration, freshness, operability.
Scope: exactly `R16-01`. R16-02 to R16-06 and R17-* have their own owners. Cross-row notes in §8 are flags only, not findings.

## 0. Observed revision and what was executed

- Lane `HEAD` at audit start: `d218603b74099ddca0bd8f869516fc41db0979bf`, with no tracked modifications (`plans/round-23.md:3` names the same base).
- The bytes this audit depends on are unchanged and match their stamps:
  - `corpus/scope-gate.sh` `078a2601…` (1129 lines / 55002 bytes) = `corpus/stamps.tsv:59`.
  - `corpus/adjacency.tsv` `4d9bfb11…` = `stamps.tsv:1`.
  - `corpus/surface-census.tsv` `4af0dbcc…` = `stamps.tsv:64`.
  - Sibling basis files: `kake-shokunin/SKILL.md` `539e9a12…` and `kotoba-shokunin/corpus/knowledge/alwayson-checklist-round7.md` `10d35ef0…` (read only).
- **In-flight L1 integration was observed during the audit (from about 00:53).** Changed: `corpus/claim-ledger.sh` (now `c20c2d04…`, 88480 bytes; the stamp says `cf56f9ea…`/88425), `corpus/claim-ledger.tsv`, `SCORECARD.md` (Round 23 sections appended at :824+), `corpus/fixtures/cells-hermetic/` and `corpus/closure-dispositions.{py,json}`.
  - The `R16-01` row bytes (`claim-ledger.tsv:39`) did not change.
  - Every `claim-ledger.sh` line cited below was re-read after the edit and sits at the same position.
  - In-flight material is labelled **in-flight** and is not treated as landed evidence.
- **Nothing was executed:** not the row, not any gate, the handler or the ledger, and no host directory was listed. Evidence comes from:
  - code reading;
  - committed receipts;
  - my own Python over the committed TSVs (static derivation);
  - reads of the two cited sibling-lane lines.
- No public sources were used.

## 1. The obligation

`corpus/claim-ledger.tsv:39`:

- **Command:** `bash corpus/scope-gate.sh`
- **Expect:** an anchored ERE requiring `ADJACENCY_SCOPE: CLEAN (…)` with 23 literal fields, from `census=35` to `breadth_unverified=0`.
- **Exit:** 0. **Timeout:** 300.
- **Note:** "the ownership partition plus breadth extension, live … [substrate]".

## 2. Is the expected verdict, last line, exit and timeout justified?

Verdict: **supported as a historical (2026-09-29) return-to-baseline pin; not reachable on the current host.**

| Facet | Finding | Basis |
|---|---|---|
| Field order | The ERE's 23 fields match the emitter token for token, in order. | `scope-gate.sh:641-651`, `:656-661` |
| Last line | In default mode the summary is the last line. `BREADTH_AUDIT` prints first (`:619`, non-breadth mode), then `ADJACENCY_ABSTAIN`/`ASSET_ABSENT` (`:638-639`), then the summary (`:657`/`:659`). The extra lines at `:662-665` print only under `--breadth`. Nothing prints after the summary. | `claim-ledger.sh:24-30`, `:436-444` |
| Exit | CLEAN gives 0 and any defect gives 1 (`scope_rc`, `:656-666`; top-level `gate` under `set -e`, `:76`, `:1125-1130`). SETUP and usage give 2 (`:102`, `:183-188`). | code |
| Data-only fields (static re-derivation, current bytes) | Re-derived from the committed TSVs: `census=35 owned=27 shared=8 groups=4 owners=4 unresolved=1 contested=1 foreign=0 orphans=0 own_unlisted=0 breadth_required=4 breadth_pins=4 breadth_missing=0 breadth_invalid=0`. Group coverage is 4/1/2/1. Assets/runtime are 20/15. R5, R7, R8, R10 and R11 are clean. The required leaf set is `.agents`, `.config/opencode`, `.local/bin` and `chrome-profile`. Census-linked buckets are 4/2/1/1 and equal the `declared=` pins; children total 182. | `adjacency.tsv:48-84`; `surface-census.tsv:17-55` |
| `stale_basis=0` (R6) | All 4 cited lines match their tokens today: `SCORECARD.md:54` `opencode`; `kake-shokunin/SKILL.md:161` `musketeer`; `corpus/lessons/round-8-aggregator-box3-coldrun.md:64` `NativeMessagingHosts`; `kotoba-shokunin/…/alwayson-checklist-round7.md:30` `AGENTS\.md`. | direct line reads (`token_hits` semantics, `scope-gate.sh:155-163`, `:338-371`) |
| Host fields (`escapes`, `inbound`, `breadth_checked/ok/drift/exceeds/unverified`) | **Not current.** CLEAN was last recorded 2026-09-29, the last execution on 2026-10-14 returned DEFECT, and a round-22 static reproduction also gives DEFECT (§7). | — |
| Timeout 300 | Measured post-breadth runtime is about 2.3 s (`lessons/round-17.md:97-99`), roughly 130× headroom. Cost grows per breadth child × census row (a subshell `expand` per pair, `scope-gate.sh:574-581`); reaching 300 s would take about 24k breadth children [INFERENCE]. Justified. | — |

Precision of the expectation:

- The ERE is fully literal and anchored, so any count change or any defect flips it. That includes defect classes that have no summary field (OVERCLAIM, UNKNOWN-OWNER, ENUM-CLASH, R9 UNVERIFIED, …), because they still turn CLEAN into DEFECT.
- Documented bound, not a defect: 25 owned rows lie outside every breadth root (`.config/the-janitor` 5, `.local/state/the-janitor` 17, `.local/state/tac` 3).
  - When those rows are absent, `escapes=0 inbound=0` is vacuous.
  - Only the non-final `ADJACENCY_ASSET_ABSENT`/`ABSTAIN` lines (`scope-gate.sh:638-639`) show this, and the ledger's last-line rule drops them (`claim-ledger.sh:436`).
  - This is documented (`adjacency-scope.md:151-152`), and the GONE verdict is delegated to R11-01.

## 3. Do deferral, SKIP-SELF and hermetic mode preserve the obligation?

**`[substrate]` deferral does not preserve it. The predicate is too broad and too narrow at once.**

- **The predicate.** `substrate_present()` is `[[ -x "$HOME/.local/bin/the-janitor" ]]`, with a `KAGI_SUBSTRATE` override (`claim-ledger.sh:140-146`). A tagged row is DEFERred before policy and before execution (`:416-419`).
- **What the tag is supposed to mean.** The contract says the tag declares that the command "measures the substrate (`the-janitor` + its state/config tree)", and that "deferral cannot launder a real regression" (`knowledge/substrate-deferral.md:27-30`, `:38-39`).
- **R16-01 is a mixed row.** Its obligations split into three groups:
  - **Substrate-independent:** R1–R8 and R10–R12 over committed data.
  - **Fleet-layout-dependent:** R6 `lane:` bases resolved under `$SCRIPT_DIR/../..` (`scope-gate.sh:91`, `:338-343`).
  - **Host-dependent:** R9 resolution, plus R13 counts on four roots. Three of those four roots belong to other owners — integrator, kake, kotoba (`adjacency.tsv:81-84`).
- **Too broad (main risk, §4).** While the handler binary is absent, every one of those obligations is suspended, including the two sibling-lane basis checks that no stamp and no other row covers.
- **Too narrow (secondary, §8 F2).** The handler binary alone un-defers the row against roots that the handler does not own.

**SKIP-SELF does not apply.** The rule matches `*claim-ledger.sh*` in the command (`claim-ledger.sh:816-820`); R16-01's command is the scope gate, so `cells` re-runs it (or defers it). It neither preserves nor drops anything. Caveat: `rows_run` counts deferred rows (`:415`, `:828`; already raised by ClaimR17X03).

**Hermetic synthetic mode preserves the mechanism, not the obligation.**

- The only hermetic proof of the gate is `--selftest` (R16-02). It runs on scratch `$R/host` and `$R/lanes` and never reads the shipped `adjacency.tsv`/`surface-census.tsv` or the real sibling bases.
- `--falsify` (R16-03) is host-reading and is itself deferred.
- The in-flight C3 fixture carries no R16-01 tuple, which is correct because R16-01 cannot be made hermetic. So R16-01 is **retained but not preserved** by C3 (§5).

## 4. Consumer-visible false-clean: deferral hides basis decay in sibling lanes

The scenario (an R6 defect that does not depend on the substrate):

1. A sibling lane edits its file so the cited line no longer carries the token. For example, a line inserted above `kake-shokunin/SKILL.md:161` moves "the-musketeer" to :162.
2. This is the exact decay class that already happened once: README:76 → kake `SKILL.md:104-107` (`adjacency-scope.md:35-40`).
3. On a host without the handler, no executed path detects it:
   - R16-01, R16-03 and R17-01 are deferred.
   - R16-02 uses scratch lanes only.
   - R16-04/05/06 and R17-02/03 count lines in `adjacency.tsv`.
   - `stamps.tsv` cannot pin sibling files: `..` and absolute paths are refused (`claim-ledger.sh:335-336`).
   - R11-08 `citations` strips `:N` and checks only that the file exists (`claim-ledger.sh:501`, `:577`); `adjacency.tsv` is outside its doc set (`:525-526`).
4. `verify` therefore prints `CLAIM_LEDGER: CLEAN (… deferred=N …)`, and `cells` re-certifies the cells that cite R16-01 for exactly this mechanism:
   - `SCORECARD.md:242`: "a stale one is a verdict".
   - `SCORECARD.md:293`: "ownership citations have drift verdicts".
5. This contradicts `substrate-deferral.md:38-39`.
6. **No current instance:** all four tokens match at the observed bytes (§2).

### Minimal synthetic falsifier (proposal for L1; not executed)

Everything goes in a scratch root. It never touches `$HOME` or the real lanes. The ledger arm never executes the gate.

```bash
K=/home/vgpnk/Projects/shokunin/kagi-shokunin; F=$(mktemp -d)
mkdir -p "$F/kagi-shokunin/corpus/lessons" "$F/kake-shokunin" "$F/kotoba-shokunin/corpus/knowledge" "$F/host"
cp "$K/corpus/scope-gate.sh" "$K/corpus/adjacency.tsv" "$K/corpus/surface-census.tsv" "$F/kagi-shokunin/corpus/"
at() { printf 'x\n%.0s' $(seq "$(($1-1))"); printf '%s\n' "$2"; }   # text on line $1
at 54  'opencode'             >"$F/kagi-shokunin/SCORECARD.md"
at 64  'NativeMessagingHosts' >"$F/kagi-shokunin/corpus/lessons/round-8-aggregator-box3-coldrun.md"
at 30  '~/.agents/AGENTS.md'  >"$F/kotoba-shokunin/corpus/knowledge/alwayson-checklist-round7.md"
at 162 'the-musketeer profile' >"$F/kake-shokunin/SKILL.md"           # decayed: basis cites :161
# Arm A: the gate sees the decay (synthetic empty host)
bash "$F/kagi-shokunin/corpus/scope-gate.sh" --root "$F/host"; echo "exit=$?"
# Arm B: the ledger, same state, substrate absent
sed -n '39p' "$K/corpus/claim-ledger.tsv" >"$F/kagi-shokunin/claims.tsv"          # exact R16-01
awk -F'\t' '$1=="corpus/adjacency.tsv"' "$K/corpus/stamps.tsv" >"$F/kagi-shokunin/stamps.tsv"
KAGI_SUBSTRATE=absent bash "$K/corpus/claim-ledger.sh" verify --root "$F/kagi-shokunin" \
  --claims "$F/kagi-shokunin/claims.tsv" --stamps "$F/kagi-shokunin/stamps.tsv" \
  --docs "$F/kagi-shokunin/SCORECARD.md"; echo "exit=$?"
```

Predicted results [INFERENCE from the cited code]:

- **Arm A** (`scope-gate.sh:338-371`, `:550-552`, `:656-661`):
  - `SCOPE STALE-BASIS $HOME/.local/share/the-musketeer/chrome-profile basis=lane:kake/SKILL.md:161 lines=161-161 token=musketeer`
  - Last line `ADJACENCY_SCOPE: DEFECT (… stale_basis=1 … breadth_checked=0 … breadth_unverified=4)`, exit 1.
- **Control A′** (token moved back to line 161): the STALE-BASIS line disappears, `stale_basis=0`, and every other field is identical. The sibling file alone is the cause; host and substrate are the same in both arms.
- **Arm B** (`claim-ledger.sh:416-419`, `:969-983`; mirrors selftest `defer-substrate-absent`, `:1422`):
  - `DEFER R16-01 reason=substrate-absent`
  - `CLAIM_LEDGER: CLEAN (claims=1 deferred=1 stamped=1 ids=1 cited=0 labeled_ids=0 orphans=1)`, exit 0. **This is the false-clean.**

Required after a fix: in the A state with `KAGI_SUBSTRATE=absent`, at least one executed, untagged row turns red. In A′ it stays green.

### Smallest safe corrections (ranked)

**(a) This round, no code and no row changes.** In the round-23 lesson/report:
- Record that R16-01's deferral also suspends R1–R8/R10–R12 and the two sibling-lane bases (`adjacency.tsv:82,84`).
- Treat the cells that rest on R16-01 as historical while it is deferred.
- Do not book R23-01 or C3 as preserving R16-01.

**(b) Optional stopgap row: host-free, untagged, depends on the fleet layout (declare that the way R11-08 does at `claim-ledger.tsv:22`).**
- Command: `bash corpus/scope-gate.sh --root corpus/absent-host`, exit 1.
- Expected line: exactly the A′ line `ADJACENCY_SCOPE: DEFECT (census=35 owned=27 shared=8 groups=4 owners=4 unresolved=1 contested=1 escapes=0 inbound=0 foreign=0 orphans=0 stale_basis=0 basis_escape=0 own_unlisted=0 breadth_required=4 breadth_pins=4 breadth_checked=0 breadth_ok=0 breadth_missing=0 breadth_invalid=0 breadth_drift=0 breadth_exceeds=0 breadth_unverified=4)` [INFERENCE].
- It never reads `$HOME`. A relative root resolves under the runner's `cd "$ROOT"` (`claim-ledger.sh:426`).
- It catches Arm A and any count, escape or own-unlisted drift.
- It is blind to classes with no summary field. Those are edits to stamped data, and `verify` already catches them through `stamps.tsv:1,64`.
- Its line visibly differs from R16-01's live CLEAN, so it does not launder provenance.
- Cost: R21-04 (in-flight `^45$`), a stamps re-pin and a QM14 journal entry.

**(c) Next round, code.** Add `scope-gate.sh --partition`: rules R1–R8 and R10–R12, no `$HOME` read, and its own CLEAN line, so every defect class flips it. This is the same shape as ClaimR17X03 §4(d) `--plan`: one mode serving two consumers. R16-01 then keeps `[substrate]` only for R9 and R13.

## 5. What C3 (hermetic cells) must retain for R16-01

1. **Inventory.** List R16-01 as *retained, live, [substrate]-deferred, outside hermetic scope*.
   - By default it reads `$HOME` (`scope-gate.sh:89`) and the sibling lanes (`:91`).
   - The in-flight R23-01 covers only fixture rows R90-01/R90-02 (`corpus/fixtures/cells-hermetic/claims.tsv:1-2`; in-flight `claim-ledger.tsv:59`).
   - The round context's "preserve all command-row obligations" cannot be met for R16-01 with fixtures. Say so; do not imply it.
2. **Never stage R16-01's tuple into a fixture.** The working directory is the fixture root (`claim-ledger.sh:426`), so a copied gate would:
   - take `SCRIPT_DIR` inside the fixture;
   - resolve `lane:` bases under `corpus/fixtures/`, giving NOT-A-FILE ×2;
   - keep `ROOT=$HOME` (`:89`), i.e. read the live host.

   Separately, a `[substrate]` tag on any fixture row would make R23-01's exact `rows_run=2 row_deferred=0` depend on the host predicate (`claim-ledger.sh:145`).
3. **Never "hermeticize" R16-01 through the environment.** That means no `HOME=`, `ADJ_HOME=`/`ADJ_DATA`/`ADJ_CENSUS`/`ADJ_BASIS_ROOT`/`ADJ_LANE_ROOT` (`scope-gate.sh:87-91`), or `KAGI_SUBSTRATE=present`.
   - The `ADJ_*` overrides are undocumented in the gate's usage (`:63-75`, which names only the flags and `REALPATH_BIN`) and are not exercised by its selftest or falsify mode, which use flags.
   - `verify_claims` passes the caller's environment through unchanged (`:426-427`).
   - The summary carries no root or provenance field (`:641-657`).
   - So a synthetic host produces a **byte-identical** CLEAN.
4. **The in-flight fixture complies today.** Its 9-line synthetic adjacency (`c17f7e17…`) is not a copy of the real one, it carries no tag, it never calls the scope gate, and R23-01 pins `rows_run=2 row_deferred=0 self_skipped=0` exactly.
5. **Fix a pointer substitution in the in-flight scorecard (sent to KagiR23).**
   - `SCORECARD.md:833` (Round 23 pre-move, adjacency) cites `R16-02` for "the ownership partition … [is] unchanged". R16-02 is scratch-only and cannot observe the shipped partition, yet `cells` will credit it as executed evidence.
   - Use stamp pointers instead: `corpus/adjacency.tsv`, `corpus/surface-census.tsv` and `PROVINCE.md` (`cells` compares those, `claim-ledger.sh:830-841`). Add "R16-01 deferred, not re-measured".

## 6. What C1 (closure dispositions) must retain for R16-01

1. **R16-01 is not one of the closure's obligations.** It appears only in the closure's Exclusions paragraph (`corpus/lessons/round-22-verifier-spotcheck.md:74-77`).
   - The in-flight `parse_obligations` (`corpus/closure-dispositions.py:76-101`) correctly ignores that paragraph.
   - `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 …)` therefore says nothing about the 12 host rows that round 22 skipped by ID.
   - Carry R16-01 forward as an explicit residual: skipped by ID (`.ufo/waves/round-22/final-verification.json` `skipped_rows[8]`, "Not executed"), live obligation unverified since 2026-10-14.
2. **The D9 pointer is not evidence for R16-01.** The in-flight D9 disposition `fixed → corpus/claim-ledger.tsv` resolves on any token mention of "D9" (`closure-dispositions.py:117-120`), so it must not be read as discharging R13-03 or R16-01. D9's note keeps R13-03's skip explicit, which is correct.
3. **Some cells have no executed evidence on this host.**
   - `SCORECARD.md:242` (`R11-04`, `R16-01`, both tagged) and `:624` (`R16-01` only) have zero executed evidence while the substrate is absent. They still count as `row_pointed` in `cells`.
   - `SCORECARD.md:295`, `:316` and `:646` rest on R16-01 plus a stamp pointer, which checks bytes only.
   - Classify all of these as *historical, unverified*, not as "the pointer leads to a passing row".

## 7. Historical vs current evidence

| Class | Item | State |
|---|---|---|
| Superseded expectation | Round 16 (`8a6ec16`): `ADJACENCY_ABSTAIN: rows=1` + CLEAN without breadth fields, about 0.5 s (`LOG.md:613-617`; `lessons/round-16.md:45-48`; `SCORECARD.md:237`). Migrated at `bc1af88` (round-22 `build/Entry01.md:85`). | historical |
| Basis of the current expectation | 2026-09-29: `BREADTH_AUDIT: CLEAN (… 182/8/174 …)` then `ADJACENCY_SCOPE: CLEAN`, exit 0 (`knowledge/adjacency-scope.md:295-297`; `lessons/round-17.md:36-45`). | historical, the only CLEAN with breadth |
| Last execution | 2026-10-14: `DEFECT (… breadth_drift=6 breadth_unverified=1)`, exit 1 (`lessons/round-18.md:27`). `LOG.md:737` and `substrate-deferral.md:11` quote it without `breadth_unverified=1`. | historical; excerpts, not verbatim |
| Static re-derivation | 2026-10-20: `breadth_drift=5 breadth_unverified=1` (round-22 `build/Entry20.md:29`); live counts 3/50/3/absent vs pins 20/105/4/53 (`build/Entry02.md:54,94-97`). | historical static, not a run |
| Round-22 verification | R16-01 skipped by ID, not executed (`final-verification.json` and `safe-row-plan.json`, `skipped_rows[8]`). | receipt |
| Current docs | `adjacency-scope.md:315-326` erratum already marks the CLEAN as historical and requires re-checking basis and pins on substrate return. The ledger note still says "live" with no date. | current; note stale (low) |
| This audit | Data-only fields and 4/4 basis tokens statically confirmed at `d218603` bytes. | current static, nothing executed |

## 8. Secondary observations (low severity)

**F2 — the predicate is too narrow (partially known).**
- Reinstalling only the handler un-defers R16-01 against roots the handler does not restore.
- The result is a bare `FAIL R16-01 reason=exit-mismatch exit=1 want=0` (`claim-ledger.sh:432-434`); the gate output is suppressed by design (`:84-86`), so a partition defect and unrelated breadth churn look identical.
- `SCORECARD.md:333-335` says "every baseline re-derives against the live surface". That is false for R16-01: there is deliberately no `--pin` (`scope-gate.sh:75`), so a reviewed re-pin is required.
- `adjacency-scope.md:325-326` already qualifies this. The only residual is the round-18 sentence; an optional append-only correction would close it.

**The R16-01 note omits its fleet-layout dependence, unlike R11-08 (`claim-ledger.tsv:22`).**
- In a lone clone (for example the `/tmp/kagi-shokunin` residue, round-22 D8) with the handler present, the row would FAIL on NOT-A-FILE ×2.

**Cross-row flags, not adjudicated:**
- `SCORECARD.md:312` says "three of the four pinned dirs are absent". The same round's recorded `breadth_unverified=1` (with drift 6) implies exactly one root was unverified. Owner: R17-01/R17-02.
- Round-22 `build/Entry01.md:93` lists the breadth set without `$HOME/.local/bin` (compare `lessons/round-17.md:44`). Owner: R17-01.
- In-flight `SCORECARD.md:844` treats an unchanged count (R17-02) as evidence that the pin values are unchanged. Owner: R17-02.

## 9. Disclosures and limits

**Contract deviation.** At the start, before reading the full contract text, I ran `git log -1` and `git status --porcelain=v1 --untracked-files=no` in the live lane.
- `git status` may refresh the stat cache in `.git/index`. No content changed.
- I ran no further Git or JJ commands.

**Everything else** was file reads, `sha256sum`/`wc`/`stat`, my own Python over committed TSVs, and reads of the two sibling basis lines.

**Not done:**
- No gate, row, handler, op, vault or host command was executed.
- No host directory was listed. The absence of the substrate comes from the round-18/22 records.
- No tools were installed or updated.

**Limits:**
- Predicted outputs are code-derived [INFERENCE]; the falsifier was not run.
- In-flight C1/C3 statements describe the 00:46–00:56 snapshots and may change during integration.
- I sent one coordination message to KagiR23, covering the items in §4 and §5.5.

Report: .ufo/waves/round-23/parent-build/ClaimR16X01.md
