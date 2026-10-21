# CritNoHarm — round 23 falsification of the no-axis-harm claim

Seat `KagiR23.CritNoHarm` (critic; judged on calibration, freshness, operability).
Attacked: the round's claim that C1/C2/C3 move calibration/freshness/operability
with **no axis harmed** (SCORECARD.md:835-844, LOG.md:1180-). For each touched
artifact I tried to find one concrete way an axis is harmed, then attacked the
strongest candidates with executed counterexamples.

**Result: the no-harm claim does not hold as written.**
- One host-independent regression hits an existing pinned row: R13-03, found in F1. The round cannot see it because it skips that row.
- The measured verdict carries one false-provenance label (F2).
- Three gate holes are open and fixable:
  - freshness (F3);
  - operability: the round's own operability cell cannot be verified (F4);
  - adjacency: a digest oracle (F5).
- One unclaimed executable change has no detector (F6).
- Several prose contradictions remain (F7).

The C1/C2/C3 named gates re-measure green.

## Target, and the tree kept moving

- I was assigned `d218603` plus the uncommitted tree. While this review ran, the lane committed and pushed nine commits:
  - `e1884c6` at 01:04:19. This is the measured commit.
  - `ea5b734`, `b55e0e7`, `7af07b4`, `284d40e`, `638d44c`, `def9bc2`, `58bd8d7`.
  - `57776b2` at 01:18:44, the last HEAD observed.
- How the trees were captured:
  - A `cp -a` snapshot at 01:03:30 (`/tmp/critnoharm-r23-010330/lane`).
  - `git archive <commit> | tar -x` copies of `d218603`, `e1884c6`, `def9bc2`, `58bd8d7` and `57776b2` under `/tmp/critnoharm-r23-*`.
- Every mutation ran in a fresh copy under `/tmp/critnoharm-r23-work/`. Every finding below names the commit it was measured at.
- At about 01:00 I messaged `KagiR23`. `corpus/surface-census.sh` had gone from clean to modified (`+DEEP=""`, mtime 00:56:57) and was not in the claim set. See F6.

## Touched artifacts (`git diff d218603..57776b2` plus transient)

- **Modified and tracked:**
  - `LOG.md`, `SCORECARD.md`, `SKILL.md`, `PROVINCE.md`
  - `corpus/SOURCES.md`, `corpus/claim-ledger.sh`, `corpus/claim-ledger.tsv`, `corpus/stamps.tsv`
  - `corpus/knowledge/op-ref-consumption.md`
  - `corpus/sources-census.sh`, `corpus/surface-census.sh`
- **Added:**
  - `corpus/closure-dispositions.py` and `corpus/closure-dispositions.json`
  - `corpus/source-fetches.tsv`
  - the five files under `corpus/fixtures/cells-hermetic/`
  - `corpus/lessons/round-23.md` and `plans/round-23.md`
  - under `.ufo/waves/round-23/`: `expectation-migrations.json`, `final-verification.json`, the spec and dispatch JSON, and three relocated seat reports
- **Transient, never committed:** `corpus/__pycache__/closure-dispositions.cpython-314.pyc` (00:46).

## Commands and exits

All commands were host-free. None touched `op`, the vault, the account or the handler. I ran no legacy `verify`, no host-bound or substrate row, and no parent row audit.

| # | tree | command | exit | last line |
|---|---|---|---|---|
| G1 | 57776b2 | `python3 corpus/closure-dispositions.py` | 0 | `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)` |
| G2 | 58bd8d7 (.py identical at 57776b2) | `python3 corpus/closure-dispositions.py --selftest` | 0 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)` |
| G3 | 58bd8d7 | `bash corpus/sources-census.sh` | 0 | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` |
| G4 | 58bd8d7 | `bash corpus/sources-census.sh --selftest` | 0 | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` |
| G5 | 58bd8d7 | R23-01 command verbatim (`claim-ledger.tsv:59`) | 0 | exact pinned `CELL_AUDIT: CLEAN (cells=6 … rows_run=2 row_deferred=0 … self_skipped=0 orphans=0)` |
| G6 | 01:03 snapshot (`claim-ledger.sh` sha `c20c2d04…`, identical at 57776b2) | `bash corpus/claim-ledger.sh --selftest` | 0 | `SELFTEST: PASS (121 cases)` |
| G7 | 57776b2 | recompute every `stamps.tsv` tuple (`awk` + `sha256sum` loop) | — | 79 rows, 0 stale |
| F1 | d218603 / e1884c6 / def9bc2 / 58bd8d7 / 57776b2 | stub-row `cells` (see F1) | 0 / 1 / 1 / 1 / 1 | base `CLEAN … missing_ids=0`; all others `BROKEN … missing_ids=2` |
| E1c | 57776b2 copy | delete the S024 row from `source-fetches.tsv`; `bash corpus/sources-census.sh` | 1 | `FINDING SC_FETCH id=S024 missing-provenance` / `FAILED (findings=1 rows=26)` |
| E1 | 57776b2 copy | as E1c, plus a fabricated in-row ``Fetch sha256: `a×64` `` in S024's registry row | **0** | `SOURCES_CENSUS: CLEAN (rows=26 …)` |
| E2 | 57776b2 copy | all 15 pointers → `corpus/lessons/round-22-verifier-spotcheck.md#Routed defects`; `rm corpus/source-fetches.tsv corpus/lessons/round-23.md`; closure gate | **0** | `CLEAN (obligations=15 fixed=6 reported=3 … pointers=15)` |
| E2' | same copy | `bash corpus/sources-census.sh` | 1 | `FAILED (findings=13 rows=26)` (10 × SC_FETCH missing-provenance, 3 × SC_USEDBY_MISSING) |
| E3a | 57776b2 copy | `bash corpus/op-ref-probe.sh --dotenv-bytes --evaluate <six rows rc=124, empty hex>` | 1 | `OP_DOTENV_BYTES: DRIFT (checks=6 failed=6)` |
| E3b | 57776b2 copy | `env OP_REF_OP_BIN=<stub: prints "not currently signed in", exit 1> bash corpus/op-ref-probe.sh --dotenv-bytes` | 1 | `OP_DOTENV_BYTES: DRIFT (checks=6 failed=6)` |
| E3d | 57776b2 copy | `env OP_REF_OP_BIN=/nonexistent/critnoharm-op bash corpus/op-ref-probe.sh --dotenv-bytes` | 2 | `OP_DOTENV_BYTES: SETUP (op binary not found)` |
| E4 | 57776b2 copy | `cells` over SCORECARD.md:835-844 (committed post-move section) with the real R23-01/R23-02/R21-02/R21-03/R17-02 rows; R21-01 stubbed so `op` never runs | 0 | `SKIP-SELF R23-01 …` / `CELL_AUDIT: CLEAN (… rows_run=5 … self_skipped=1 …)` |
| E4b | same copy after `rm corpus/fixtures/cells-hermetic/corpus/fx-ok.sh` | same `cells` | **0** | still `CLEAN (… self_skipped=1 …)` |
| E4b' | same copy | R23-01 command run directly | 1 | `FAIL R90-01 reason=exit-mismatch exit=127` / `CELL_AUDIT: BROKEN (… row_failures=1 …)` |
| E5 | 57776b2 copy | `python3 corpus/closure-dispositions.py --dispositions /tmp/…/outside/d.json --source /tmp/…/outside/file.txt` | 2 | `SETUP (source digest mismatch: 000… -> d8ace4cf…77434)`, which equals `sha256sum` of the outside file; `policy_check` (sourced from `claim-ledger.sh:160-192`) prints `ALLOWED` for that row string |
| E6 | 284d40e copy / 57776b2 copy | change only S026's normalized digest in `source-fetches.tsv`; census | 1 / 0 | at 284d40e, `same-url-normalized-disagreement` while the docs said "no cross-capture equality is enforced"; fixed in 638d44c |

## Findings

### F1 — DEFECT (operability, calibration): the round-23 lesson turns R13-03 red on every host, and the skip list hides it

- **Cause:** `corpus/lessons/round-23.md:91` (`` `R1-01` ``) and `:164` (`` `R90-02` ``) at 57776b2 are id-shaped words that are not ledger rows. Neither line carries a mark word.
  - The id audit tokenizes with `claim-ledger.sh:631`.
  - It exempts only lines that match `:641`: `scratch|ephemeral|relocat|formerly|no longer|removed|renamed|historical|fabricated|illustrative|example`.
  - It prints `MISSING-ID` (`:665`) over the default doc set, which includes `corpus/lessons/*.md` (`:526`).
  - R13-03 (`claim-ledger.tsv:38`) pins `missing_ids=0`.
  - `:163` says "illustrative", but `R90-02` wrapped onto `:164`.
- **Command:** a host-free stand-in for R13-03. It keeps the same 45 ids and the default docs, stamps and scorecard, and replaces every command with a harmless grep. The id audit depends only on ids and docs.

      awk -F'\t' 'BEGIN{OFS="\t"} /^#/||NF<6{next}{print $1,"grep -c kagi-stub-never-matches SHONEN.md","^0$",1,30,"stub"}' corpus/claim-ledger.tsv > stub.tsv
      bash corpus/claim-ledger.sh cells --root <tree> --claims stub.tsv

- **Results:**
  - d218603: exit 0, `CELL_AUDIT: CLEAN (cells=144 … missing_ids=0 … stale_pointers=0 …)`.
  - e1884c6: exit 1, `BROKEN (… missing_ids=2 … stale_pointers=1 …)`.
  - def9bc2, 58bd8d7, 57776b2: exit 1, `BROKEN (cells=156 … missing_ids=2 … stale_pointers=0 …)`, printing `MISSING-ID corpus/lessons/round-23.md:91 R1-01` and `MISSING-ID corpus/lessons/round-23.md:164 R90-02`.
- **Why it is invisible to the round:** `final-verification.json` marks R13-03 `skipped` ("host-bound/substrate row"). The failure is pure doc parsing, so it fails on every host. Legacy `verify` would fail the same way (its own selftest case is `verify-id-missing` → `unresolved_ids=2`).
- **Smallest correction:** add a mark word to both lines, for example "illustrative" on `:164` and "example" on `:91`. Then add a host-free id-audit row so that skipping R13-03 cannot hide doc-only regressions.

### F2 — DEFECT (calibration, false provenance): post-measurement results are labelled with the measured commit

- **The verdict file:** `.ufo/waves/round-23/final-verification.json` records `measured_commit: e1884c6…`. It also records R22-03 as `REVISION_AUDIT: CLEAN (stale=0 … added=16 …)`, and its own note says "R22-03 re-ran CLEAN added=16 after the final restamp". That restamp is `ea5b734`.
- **Why that cannot hold at e1884c6:**
  - At e1884c6, `corpus/stamps.tsv` pins `corpus/claim-ledger.tsv` at `f1a73f09…` / 19506 B. The committed file is `0d3d7500…` / 19558 B.
  - My stub cells run printed `STALE-POINTER corpus/claim-ledger.tsv sha=f1a73f09aa7f->0d3d75008122 lines=60->60 bytes=19506->19558`.
  - `revision-audit.py:373-387` makes the same tuple comparison. So R22-03 at e1884c6 would read `DRIFT (stale=1 …)`. This is computed, not run, because R22-03 is a parent row.
- **The fleet report repeats it:** `/home/vgpnk/Projects/shokunin/.ufo/reports/round-23/kagi.md:123-126` says "Supporting counts at `e1884c6e`: … revision audit `CLEAN (stale=0 …)`". That is false for that commit.
- **The LOG mixes trees:** the After line at `LOG.md:1192-1194` pairs e1884c6's `fixed=7 reported=2` with the 14-case selftest that only arrived in 7af07b4. R23-02 now pins `fixed=6 reported=3` (`claim-ledger.tsv:60`).
- **The D6 fix itself:** R23-02 counted D6 as `fixed` at e1884c6, but `git cat-file -e e1884c6:.ufo/waves/round-23/final-verification.json` fails. The fix landed one commit later.
- **Smallest correction:** do one of these, then fix `kagi.md:123-126` and the LOG After line to say which commit each value comes from:
  - re-run the safe rows at a single commit at or after the final restamp, and record that commit; or
  - record a commit or tree digest per result.

### F3 — DEFECT (freshness): the "legacy" in-row exemption in SC_FETCH is open to new rows

- **Code vs docs:**
  - `sources-census.sh:279-283` accepts any registry row whose line contains ``Fetch sha256: `<64 hex>` `` and skips the provenance requirement.
  - The docs limit this path to S001–S016: `source-fetches.tsv:35-37` and `sources-census.sh:67-69`.
- **Counterexample (E1):** S024 is a round-23 row. With its declared capture deleted and a fabricated, representation-free in-row digest added, the census exits 0 CLEAN. The control (E1c) exits 1 with `missing-provenance`.
- **Harm:** D7's "fixed" gate, and R21-02, stay green for a future row whose only provenance is an invented digest.
- **Smallest correction:** allow the in-row path only for frozen legacy ids, for example `[[ $fid =~ ^S0(0[1-9]|1[0-6])$ ]]`, and add one selftest case: an in-row digest on a post-legacy id must raise `SC_FETCH`.

### F4 — DEFECT/BOUND (operability): the round's own operability cell cannot be verified by the scorecard audit

- **Cause:** `SCORECARD.md:841` cites only R23-01. R23-01's command contains `claim-ledger.sh`, so `cells` skips it at `claim-ledger.sh:816-819` (SKIP-SELF).
- **Conflict with the lesson:** M23-3 (`round-23.md:154`) says "the real-tree claim is not made", but `:841` is a real-tree cell.
- **Counterexample:** E4 and E4b. Even with the fixture broken, the scorecard audit prints `CLEAN … self_skipped=1` with exit 0, while R23-01 itself is BROKEN with exit 1.
- **Smallest correction:** either
  - state the bound in the cell: verifiable only by running R23-01 directly, because `cells` self-skips it; or
  - exempt `cells --root corpus/fixtures/…` from SKIP-SELF. Recursion is impossible there because the fixture ledger has no row that invokes `claim-ledger.sh`.

### F5 — DEFECT (adjacency, privacy): the allowlist widening admits a digest oracle for host files

- **The widening:** `claim-ledger.sh:161` allows `python3 corpus/closure-dispositions.py` with any arguments.
- **The script:**
  - `closure-dispositions.py:148` (`root / source_rel`) and `:151` (`root / dispositions_rel`) let an absolute argument replace the root.
  - `:157` prints the observed sha256 on a mismatch.
  - The pointer escape guard at `:106-117` is not applied to `--source` or `--dispositions`.
- **Counterexample (E5):** the gate prints the sha256 of a file outside the lane, and `policy_check` (`:170-192`) allows that command as a claim row.
- **Smallest correction:** do either or both:
  - apply the pointer rule to `--source` and `--dispositions` (relative, no `..`, must resolve under the root), and stop printing the observed digest;
  - limit the allowlist for this script to no arguments or `--selftest`.

### F6 — BOUND (operability, calibration): `DEEP=""` rode in on the restamp with no detector

- **The change:** `surface-census.sh:82` (`DEEP=""`, read at `:585`, `:605`, `:627`) was committed in e1884c6.
- **Where it is and is not recorded:**
  - It is absent from LOG §Round 23, the lesson and the SCORECARD.
  - At e1884c6 it had no migration record. It was later filed as a *prose* change in `expectation-migrations.json` `prose_changes[4]`, added in 7af07b4.
  - `stamps.tsv:77` re-pinned the new bytes, `1e697b01…`.
- **No detector:**
  - R11-03 still expects `16 cases` (`claim-ledger.tsv:17`).
  - R11-02's regex (`:16`) still accepts `pass=10 skip=0`, which is the deep set.
  - So deleting line 82 would turn nothing red.
- **Assessment:** the change is a safety improvement (ClaimR11X02 §4), not a regression. But QM14 (`QUALITY.md:73`) names the failure class "restamping to hide…". An executable change pinned with no falsifier and no round prose sits in that class.
- **Smallest correction:** name the change in the LOG and lesson. Then either add ClaimR11X02's falsifier as a census selftest case (`DEEP=1` in the environment plus a stub must give 3 `requires --deep` skips), or tighten R11-02 to `pass=7 skip=3`.

### F7 — Calibration defects in prose (minor, fixable)

- **W04 count:** `kagi.md:78` says "seven W04 lines"; `:133` says "same five W04 lines".
- **The mistakes sweep:**
  - `round-23.md:156-158` says the sweep "looked for a fourth mistake and found none", yet `:153` records M23-4.
  - The sweep's pathspec (`corpus/lessons corpus/QUALITY.md`) leaves out the one corpus body rewritten in place: `git diff --numstat d218603..HEAD -- corpus/knowledge` shows `op-ref-consumption.md` with 4 insertions and 2 deletions.
  - That contradicts `plans/round-23.md:47` ("Every corpus/log/quality change is an append"). The rewrite is journaled in `prose_changes[2]`, so QM14 is met.
  - When the sweep line was written, HEAD was d218603, so `d218603..HEAD` was an empty range.
- **Unclosed parenthesis:** the corrected sentence at `op-ref-consumption.md:362-363` leaves "(sign-in prompt, timeout," open.
- **Stale pointer:** `claim-ledger.tsv:54` (R21-04) says "old/new value recorded in round-22 journal". The 43→45 change is recorded in `.ufo/waves/round-23/expectation-migrations.json`.
- **Unpinned count:** the closure selftest count went 13 → 14 inside the round. It is cited at `SCORECARD.md:851` and `LOG.md:1194`, but no ledger row pins it. That breaks the ledger's own rule (`claim-ledger.tsv:11-14`: "a number a doc cites is a claim").

### F8 — BOUND (calibration): a C1 "fixed" disposition can be satisfied by the obligation list itself

- **Counterexample:** E2 and E2'. The gate reports `fixed=6` with every pointer aimed at the outside closure and both fix artifacts deleted. The census in the same tree fails.
- **Real instance:** D6 at e1884c6, as in F2.
- **Status:** since 58bd8d7 the docstring states the general bound (`closure-dispositions.py:41-47`), so this is a stated tradeoff.
- **Remaining cheap fix:** refuse a pointer that resolves to the `source` file.

## One concrete harm argument per axis

| axis | concrete harm | status |
|---|---|---|
| operability | R13-03 turns red on every host (F1). The operability cell at SCORECARD.md:841 cannot be verified by `cells` (F4). | defects |
| calibration | Results are mislabelled with the measured commit, and the fleet report states a false CLEAN at e1884c6 (F2). Prose contradicts itself (F7). "fixed" can be satisfied by the obligation source (F8). | defects / bound |
| freshness | The in-row exemption lets a new row pass on a fabricated digest (F3). | defect |
| adjacency | An allowlisted claim row can fingerprint any readable host file (F5). | defect |
| coverage | S025/S026 supersede S014/S016 in prose only. S014/S016 stay `mined` with used-by `vault-openbao-token-lease-lifecycle.md`, whose body still cites S014 (`:33`, `:40`) and S016 (`:49`). The corrected locators reach only the lesson (debt named in M23-2). | bound, no new harm |
| depth | None found. As committed, the R21-01 note (`claim-ledger.tsv:51`) and `op-ref-consumption.md:362-366` match the code (E3a/E3b/E3d; `op-ref-probe.sh:258-262`, `503-516`, `525-526`). | confirmation |

## Confirmations (re-measured, no harm)

- **Named gates:** G1–G5 are green. The C3 mutation is caught when R23-01 runs directly (E4b').
- **Ledger selftest:** the allowlist-regex edit did not break it (G6, 121 cases).
- **Stamps:** all 79 tuples are fresh at 57776b2 (G7).
- **Census selftest coupling:** nine pre-existing cases had their expected finding totals changed. This is disclosed in the R21-03 entry of `expectation-migrations.json`. The harness checks only that the finding id is present and that the total matches (`sources-census.sh:574-575`); it does not check which classes make up the extra findings. This is a tradeoff, not a defect.

## Transient defects I observed that did not land (or were fixed during the window)

- **~00:59:** eight stamp tuples were stale (`claim-ledger.sh`, `claim-ledger.tsv`, `op-ref-consumption.md`, `sources-census.sh`, `SOURCES.md`, `LOG.md`, `SCORECARD.md`, `SKILL.md`), plus `surface-census.sh`. The restamp cleared them. One stale tuple remained at e1884c6 (see F2).
- **~00:55:** the uncommitted R21-01 note and knowledge entry said sign-in, timeout *and* missing binary all read as `SETUP` exit 2. E3a/E3b show that is false. It was corrected before e1884c6.
- **00:46:** `corpus/__pycache__/*.pyc` existed, untracked and not gitignored, in a lane that has `.jj`. It is absent from every round-23 commit and from the working tree.
- **"10 captures over 7 URLs":** the actual count is 9 (`awk -F'\t' '!/^#/&&NF==16{print $4}' corpus/source-fetches.tsv | sort -u | wc -l` → 9). Corrected in LOG and SCORECARD.
- **Lesson C3 contract:** it described a 4-file fixture with one row and empty stamps; the fixture has 5 files, 2 rows and 2 stamps. Corrected in b55e0e7.
- **R13-01 note:** a sentence was duplicated. Fixed in 7af07b4.
- **284d40e:** the docs said no cross-capture equality is enforced while the code enforced it (E6, exit 1). The rule was removed in 638d44c.

## Bounds the no-harm claim must state if it is admitted without fixes

1. R13-03 is red from e1884c6 through 57776b2 for a doc-only reason (`missing_ids=2`). "No axis harmed" cannot rest on that row being skipped.
2. `measured_commit` in the verdict file and the fleet report does not label every result. R22-03 was measured after the restamp, and at e1884c6 it would be `stale=1`.
3. The SC_FETCH in-row path is not limited to the legacy ids S001–S016.
4. SCORECARD.md:841 cannot be verified by `cells` (SKIP-SELF). Only a direct R23-01 run verifies it.
5. `closure-dispositions.py` accepts absolute `--source`/`--dispositions`, prints observed digests, and is allowlisted for claim rows.
6. The `surface-census.sh:82` behaviour change has no detector and no round prose.
7. A C1 "fixed" disposition means only that the id token appears somewhere. That includes the obligation source itself.

## Conformance

- **Writes:** in the lane, only this report. Scratch went to `/tmp/critnoharm-r23-*`, `/tmp/critnoharm-r23-exp.sh` and `/tmp/critnoharm-r23-exits.sh`.
- **Not done:** no installs or updates were attempted (the assignment pauses installs). No network fetch. No `jj` command.
- **Git:** my first three `git status` calls ran without `GIT_OPTIONAL_LOCKS=0`, so they may have refreshed `.git/index` stat data. Every later git read set it. Nothing changed refs or history.
- **Not run:** R13-03 itself, R22-03, R11-01/02/03, and legacy `verify`. F1 and F2 rely on the stub run and on tuple recomputation instead.

## Addendum — re-check at the newest HEAD (01:23)

- **Two more commits landed after the report was written:** `31f24e0` ("supersession prose-only bound") and `8934464` ("parent-build disposition scope bound").
- **F1 still holds at `8934464`.** I re-ran the same stub-row `cells` over a `git archive` copy: exit 1, `CELL_AUDIT: BROKEN (cells=156 … missing_ids=2 … stale_pointers=0 …)`.
  - `MISSING-ID corpus/lessons/round-23.md:91 R1-01`
  - `MISSING-ID corpus/lessons/round-23.md:165 R90-02` (line `:164` above is now `:165`)
- **Not re-run at `8934464`:** the other findings. They were last measured at `57776b2`.
