# XSeparability — claim-separability overlay (round 27 build)

Author: KagiR26.XSeparability-17 (leaf executor). Lane-authored advice, not non-author closure. No SHONEN marks written.
Lane (read-only): `/home/vgpnk/Projects/shokunin/kagi-shokunin`. Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b` (resolves; 1123 tree entries).
Milestone: round-27 build — C1 knowledge-entry number binding; C2 release-clock regression refusal.

**Status: tool drafted, NOT RUN.** No gate, selftest, ledger row, `release-clock.py` mode, `verify`, linter or build was executed. No check passes are claimed. Pins and BASE regex/row counts were read as evidence only. Predictions are labelled as such.

---

## 1. Deliverables

| Item | Location | Identity |
|---|---|---|
| Overlay tool (draft, unrun, 646 lines) | `.ufo/waves/round-27/sandboxes/XSeparability/claim-separability-overlay.py` | sha256 `2661e53cb1c10ac220525e5ba1f96e7a40c4ec9c7dc58f512f8c54f12ab0a5d5` |
| BASE snapshot (byte-exact `git cat-file` blobs, 114 files) | `.ufo/waves/round-27/sandboxes/XSeparability/base/` + `base-manifest.tsv` (path, mode, blob oid, sha256, bytes) | — |
| Round-24 overlay pins (snapshot) | `.ufo/waves/round-27/sandboxes/XSeparability/base-extra/` | — |
| This report | `.ufo/waves/round-27/build/XSeparability.md` | — |

Tooling: none installed, updated or downloaded. Host already has git 2.56.0 and Python 3.14.8 (`python3 --version`). No pacman, uv, npm or network use.

Planned invocation for L1 (after AFTER is committed; never run by this seat):
```
python3 .ufo/waves/round-27/sandboxes/XSeparability/claim-separability-overlay.py \
  --after <AFTER_SHA> --partition <PARTITION.tsv> \
  --out .ufo/waves/round-27/build/XSeparability-overlay.json [--mutate <KN-ID>]
```
Exit: 0 all asserted checks PASS; 1 an asserted check FAILED; 2 REFUSED on integrity (nothing claimed). Read `integrity` in the JSON first.

---

## 2. What the tool does

Each tree is a fresh scratch clone (`/fast/scratch` exists: `drwxr-xr-x`, owner vgpnk) checked out at BASE, then overlaid. The lane is only read through `rev-parse`, `diff-tree -z --raw`, `diff -U0`, `cat-file blob` and `clone --no-checkout --no-hardlinks`. The working tree, index, refs and objects are never read or written.

| Tree | Overlay | Claim commands run inside it |
|---|---|---|
| `base` | none | gate; clock selftest; clock default; downgrade fixture (BASE code) |
| `c1` | every hunk/file the partition assigns to C1 | gate; `claim-ledger.sh verify` (recorded) |
| `c2` | every hunk/file assigned to C2 | gate; clock selftest; clock default; downgrade fixture |
| `table-after` | the AFTER binding table only ("after table on BASE docs") | gate |
| `after` | every changed path from AFTER (must equal AFTER) | gate; clock ×3; verify; optional one-digit mutant |

**Fidelity checks (refuse on failure, nothing claimed):**
- Whole-file overlay: written bytes sha256 == AFTER blob sha256, and the git blob oid (computed with the repo's object format) == AFTER oid (`build_tree`, tool lines ~300–313).
- Hunk-split file: all hunks applied to the BASE blob must reproduce the AFTER blob byte-for-byte (composition, `build_plan` ~266–273). Derived bytes sha256 is recorded.
- Per tree: `git diff --cached --name-only BASE` must equal the overlay set; `git diff --cached --name-only AFTER` must equal the predicted complement (`build_tree` ~316–328).
- Every changed path must have a partition row, and every partition row must be a changed path. Each hunk must match exactly one claim. Otherwise refuse.

**Asserted checks (not run):** see §5. Exit codes alone are never the verdict; the gate's `stale=`, `unlocated=`, `ambiguous=` counts are parsed.

**Partition contract (TSV, `path<TAB>claim<TAB>hunk_regex`):** `hunk_regex` is `ALL` (sole row for that path) or a Python regex (re.M) matched against each `-U0` hunk's removed and added lines. Limitation: hunk granularity is git's. Two claims' edits that are adjacent in one hunk are refused (fail closed); the author must split them or accept refusal.

---

## 3. Prior art and defects not to copy

- The assigned model `.ufo/waves/round-25/tools/claim-separability.py` **does not exist**. `round-25/tools/` holds `c1-measure.sh`, `c2-measure.sh`, `final-measure.py`, `c3-measure.py`, `capture-feeds.sh`.
- Modelled on: round-24 separability trees, which record per-input sha256 (`.ufo/waves/round-24/separability/c1-only/expected.json:5-8`; `c2-only-run.json:1-23`), and the round-25 clone-and-overlay pattern (`c1-measure.sh:19-25`).
- Defects in the round-25 precedent:
  - `c1-measure.sh:23-25` overlays with `git show` (porcelain), with no SHA check.
  - `c1-measure.sh:26-37` re-serializes `corpus/self-counts.tsv` from parsed rows (line 37). This drops the 14 header comment lines (BASE `corpus/self-counts.tsv:1-14`), so overlaid bytes are not the blob.
  - `c1-measure.sh:34-36` rewrites the RD-LEDGER-ROWS and RD-STAMPS locators for `--common`, changing the population measured.
  - `c1-measure.sh:9` and `:19` hard-code the lane and `/fast/scratch`. `c2-measure.sh:2` names its round-25 citation-layout check "C2", colliding with round-27 C2.
  - `final-measure.py:8` hard-codes the round-25 BASE `4587c61a348e4528717404a68912c373f3ef4d03`. Copying it measures the wrong base.
- The draft overlays the table byte-exact instead of rewriting it. The gate also accepts an absolute `--table` (`self-counts.py:29-31`, `:568-569`), which is a possible alternative that was not used.

---

## 4. Findings and counterexamples (BASE citations unless marked working-tree or plan)

### 4.1 The gate verdict is not one bit (calibration measurement)
- `corpus/self-counts.py:369-372`: any UNLOCATED or AMBIGUOUS prints `STALE` and exits 1 even when `stale=0`. Counterexample: a moved doc line gives exit 1 with `stale=0 unlocated=1`. "exit 1" is not "stale N".
- `corpus/self-counts.py:363-368`: any POLICY or SETUP exits 2 even when stale > 0. The plan's "(stale N, exit1)" (`plans/round-27.md:20-21`, working tree) is unreachable if any row errors. A non-zero ledger row raises SETUP at `self-counts.py:298-299`.
- `corpus/self-counts.py:255-257` (ledger:) and `:320-321` (expect:): a `ledger:`/`expect:` ID absent from the tree's ledger is POLICY. The in-flight rows use only IDs present at BASE: `R11-03` (`claim-ledger.tsv:17`), `R11-09` (:23), `R12-02` (:27), `R15-02` (:34), `R15-04` (:36), `R15-05` (:37), `R16-02` (:40), `R16-03` (:41), `R17-02` (:46), `R18-01` (:48). Future rows may not be.
- `corpus/self-counts.py:290-293`: ledger commands run with the caller's environment (no `env=`). The draft pins PATH/LC_ALL/HOME/TMPDIR; the gate does not.
- BASE locator census (Python `re`, same semantics as `self-counts.py:326-336`, no gate run): all 38 BASE rows (`corpus/self-counts.tsv:15-52`) locate exactly once in BASE docs. That is consistent with the R25-02 pin "CLEAN (claims=38 stale=0)" (`corpus/claim-ledger.tsv:81`).

### 4.2 Population volatility (working tree, uncommitted)
- `git diff --stat 0a47dd…` on the working tree lists 10 tracked files (158 insertions, 30 deletions): `corpus/QUALITY.md`, `README.md`, `SOURCES.md`, `knowledge/claim-ledger.md`, `knowledge/op-ref-consumption.md`, `knowledge/surface-census.md`, `release-clock.py` (84 lines), `self-counts.tsv` (+23), `source-fetches.tsv` (+2), `stamps.tsv` (27 lines). A tool or hand-run on the working tree is not reproducible.
- `corpus/self-counts.tsv` (working tree) moved during this session. First read: 18 KN rows at lines 53–75. Census 1: 54 data rows, 16 not at BASE. Census 2: 60 data rows, 22 not at BASE. The draft therefore reads committed blobs only.

### 4.3 The plan's "disjoint files" premise fails at file level
- `plans/round-27.md:39-41` (working tree; `plans/round-27.md` is **not** tracked at BASE) says C1 and C2 "touch disjoint production files."
- **A. C2 numbers inside C1's bound population.** `SKILL.md:48` states "`--selftest` 67 cases" for release-clock, bound by `corpus/self-counts.tsv:22` (SC-CLOCK-SELFTEST, `ledger:R25-03`). `PROVINCE.md:54` states "proves 67 cases", bound by `self-counts.tsv:38` (PV-CLOCK-SELFTEST). The R25-03 pin is `claim-ledger.tsv:82` = `(67 cases)`. If C2 adds k ≥ 1 selftest cases, a C2-only tree (BASE docs + AFTER release-clock.py) exits 1 with STALE on rows 22 and 38 unless the C2 partition carries `SKILL.md:48` and `PROVINCE.md:54`. This is a prediction from the plan's stated growth, not a run.
- **B. Bookkeeping counts.** `claim-ledger.tsv:81` (R25-02) pins `claims=38`: any added KN row changes it. `:52` (R21-02) pins `rows=41`: any SOURCES.md row changes it (C2's version-precedence rows, `plans/round-27.md:31-32`). `:54` (R21-04) pins 65 ledger rows: any new `R27-*` ledger row, from either claim, changes it, and it feeds `self-counts.tsv:16` (SC-SKILL-CLAIMS), `:35` (PV-CLAIMS) and `:46` (RD-LEDGER-ROWS). A C2 that adds one claim row dirties three C1-bound lines.
- **C. Stamps.** `self-counts.tsv:15`, `:34`, `:47` bind the stamp count through R12-03 (`claim-ledger.tsv:28`, `^89$`). Any `stamps.tsv` change moves all three.
- Conclusion: file-level partition is insufficient. The draft uses hunk-level assignment, fail-closed.

### 4.4 `docs` checks membership, not content
- `corpus/claim-ledger.sh:1197-1198`: the `docs` audit's UNPINNED check tests whether a knowledge entry is a row in `stamps.tsv`, counted in `DA_UNPINNED` (init at :1102 and :1109). A knowledge-doc overlay without a refreshed stamp row passes R14-01 (`claim-ledger.tsv:32`, consumed by `self-counts.tsv:48-50`).
- Content is compared at `claim-ledger.sh:498-502` (sha256, lines, bytes). I did not trace which subcommand calls it. [INFERENCE: `verify`.] The draft therefore records `verify` on the c1 and after trees. In a lone clone it is expected to end INCOMPLETE, exit 3 (`PROVINCE.md:52`). That result is recorded, not asserted.

### 4.5 C2 freshness: BASE accepts downgrades (predicted; not run)
- `corpus/release-clock.py:524-525`: a `fired` verdict is consistent whenever normalized observed ≠ anchored. There is no ordering. `:527-528`: `not-fired` is consistent whenever observed = anchored.
- `:397` (inside `receipt_matches`, `:378-408`): the receipt is matched by equality, not order.
- `:730-734` (`observe_one`, `:706-758`): verdict = `not-fired` iff equal, else `fired`. A stale feed reporting 3.15.0 is recorded `fired` against anchor 3.15.1 (S040, `corpus/release-clocks.tsv:30`). It un-fires S027 (anchored 3.15.0, `release-clocks.tsv:24`, `fired`) when the feed shows 3.15.0 (`:527-528`), with no CLEAN-blocking rule.
- The BASE selftest (`:848`–`:1553`) has no downgrade or regression case. A grep over `base/corpus/release-clock.py` for `downgrade|older|regress|precedence` returns nothing. The fired case is `:952-953` (observed 1.2.4 over anchor 1.2.3).
- The round-26 lesson already names this: "an inherited limit, not fixed or hidden here … could regress and un-fire an older anchor" (`corpus/lessons/round-26.md:230-237`).
- **Predicted BASE result** for the tool's fixture (S040 observed 3.15.0 `fired` plus a receipt with parsed 3.15.0 `fired`): CLEAN with fired +1, by `:524-525` and `:397`. Not run.
- Default receipt is intact: `.ufo/waves/round-26/observe-2.json` (tracked) sha256 = `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169`, equal to `release-clock.py:28` `DEFAULT_RECEIPT_SHA256`. Default path `:448-450`; pin use `:1594-1596`.
- R25-04 (`claim-ledger.tsv:83`) pins `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`. The plan's "CLEAN30" (`plans/round-27.md:34`) is `on_release=30`. C2 must not add on_release rows without migrating R25-04.

### 4.6 Calibration: named debt, dangling pointers, and binder mismatches
- `corpus/lessons/round-25.md:158-165` names `knowledge/claim-ledger.md:81`, `sops-age-key-rotation.md:68-70`, `vault-openbao-token-lease-lifecycle.md:78`, `op-ref-consumption.md:276,283,296`, `credential-isolation.md:120-122` and surface-census body numbers.
- `credential-isolation.md:120-122` **does not resolve**: the BASE file has 78 lines.
- `sops-age-key-rotation.md:70` and `vault-openbao-token-lease-lifecycle.md:78` carry "(2026-10-19)" dated observations. BASE `self-counts.tsv:5-10` puts round-dated history and measurements out of population. The table cannot decide these from text, so they need an explicit exclusion note, not silent omission.
- `op-ref-consumption.md:276` (current tense, Reproduction block): "`OP_REF_SELFTEST: PASS (29 cases)`". BASE pin R12-02 = 36 (`claim-ledger.tsv:27`). STALE at BASE docs (pin-proxy).
- `op-ref-consumption.md:296`: "`--selftest` proves the comparator on 21 cases, including fifteen seeded mutations". This is a sub-count. The in-flight row KN-OPREF-FALSIFY-SELFTEST binds it to R12-02's whole-selftest total (36). That is a binding-quantity mismatch. Correct handling is an exclusion or a new row for the comparator count. [INFERENCE from wording; `op-ref-probe.sh` not read.]
- `knowledge/claim-ledger.md:304` says 72 for R11-09 (pin 170, `claim-ledger.tsv:23`). STALE (pin-proxy), in an undated Reproduction block.
- `knowledge/surface-census.md:32` says 19 symbol pins. BASE `corpus/drift-symbols.tsv` has 20 data rows. STALE, deterministic (row count, no execution).

**Predicted stale rows at BASE docs for the 22-row in-flight table (census 2):** 4 rows — KN-LEDGER-REPRO-SELFTEST (72 vs 170), KN-OPREF-REPRO-SELFTEST (29 vs 36), KN-OPREF-FALSIFY-SELFTEST (21 vs 36), KN-CENSUS-DRIFT-SYMBOLS (19 vs 20). The other 18 match their BASE pin or BASE row count (pin-proxy or deterministic). Unlocated and ambiguous are predicted 0. Live values are not measured; the table may change again.

---

## 5. Checks the draft asserts (none run)

| ID | Asserted when | Expectation source |
|---|---|---|
| C1.base-table-on-base-docs-pinned | BASE gate exit 0, CLEAN, `claims=38` | `claim-ledger.tsv:81` (R25-02) |
| C1.after-tree-clean | after gate exit 0, CLEAN, `stale=0` | plan `:20-22` "on after docs (stale0, exit0)" |
| C1.after-table-on-base-docs-detects | table-after exit 1 **and** stale+unlocated+ambiguous ≥ 1 | plan `:20-21` "(stale N, exit1)", with the exit-code caveat of §4.1 |
| C1.one-digit-mutation-detected (`--mutate`) | mutant exit 1 and `STALE <ID>` | plan `:19-20` |
| C2.downgrade-accepted-at-base | base fixture exit 0, `RELEASE_CLOCK: CLEAN` | predicted from `:524-525`, `:397` |
| C2.downgrade-refused-after | after fixture exit 1, `REGRESSED S040` | plan `:33-34` |
| C2.live-default-clean-{base,after} | exit 0, `CLEAN (on_release=30 ` | `claim-ledger.tsv:83` (R25-04); plan `:34` |
| C2.selftest-only-insertions | no BASE line inside `selftest()` changed or deleted | plan `:34-35` "grows only by the new cases" |
| C2.selftest-growth-equals-inserted-cases | after − base cases = inserted `run_case(` lines | approximation: one call per case |

INFO only (not asserted): `C1.table-after-non-ok-rows`, `C2.cross-claim-rows-in-c2-tree` (statuses of rows 22 and 38 in the c2 tree).

Predicted, not asserted: base gate CLEAN with claims=38; c2 tree gate exit 1 with STALE on rows 22 and 38 if the AFTER selftest count grows; table-after gate exit 1 with ≥ 4 stale (§4.6).

---

## 6. Risks in the draft (unverified)

- **Never executed.** I re-read all 646 lines once, but a syntax or logic error is possible. Unverified paths: `diff-tree -z --raw` parsing (format checked on one `A` record only); the `-U0` parser's marker and deletion paths (one added-file diff observed); composition under real hunks; clone time; gate runtime (R11-09's 170-case selftest, R25-02, etc.).
- Unexpected exceptions that are not `Refused` propagate, and the scratch directory is left in place (deliberate, for debugging).
- Per-claim parsing reads the gate's output format (`self-counts.py:306-374`). A format change empties `per_claim`, which makes the checks FAIL rather than pass.
- The selftest-growth check assumes one `run_case(` per case. A loop would mismatch and be reported as FAIL with the numbers, for inspection.
- The downgrade fixture is synthetic. It tests the verifier's acceptance rule, not vendor truth (`SKILL.md:48` says the default replays a pinned receipt, not live release state).
- `verify` in a lone clone ends INCOMPLETE, exit 3. Recorded only.

---

## 7. What I did NOT check

- Did not run the tool, the gate, any selftest, any ledger command, `verify`, `release-clock.py` in any mode, or any linter, formatter or build.
- Did not measure live values. Pins, BASE row counts and BASE regex matches only.
- No AFTER rev exists (nothing is committed). The working tree was used only for diff-stat and for in-flight row counts. I did not read the in-flight diffs of `release-clock.py`, `SOURCES.md`, `source-fetches.tsv`, `README.md`, `QUALITY.md` or `stamps.tsv`, beyond the diff-stat.
- Did not read the round-27 exclusion list (`corpus/lessons/round-27.md` is not in BASE).
- Did not confirm which `claim-ledger.sh` subcommand reaches the comparator at lines 498–502.
- Did not verify the `op-ref-probe.sh` meaning of "21 cases" (§4.6).
- Did not read sibling sandboxes or their outputs for overlap.
- Did not check the version-precedence SOURCES.md rows (C2 sourcing); they are not in BASE.
- Did not contact vault, accounts, handlers, CDP or the network, and did not read host-private paths (`~/.config`, `op.env`, tokens, sessions). None were touched.
- Did not time anything.

---

## 8. Checks for L1 to run (once, after AFTER is committed)

1. Author the partition for the committed AFTER. Suggested rules: `SKILL.md:48` and `PROVINCE.md:54` → C2; `self-counts.tsv` rows → C1; each ledger hunk (`claim-ledger.tsv:81`, `:52`, `:54`, `:28`) → the claim that changed it.
2. Run the tool with `--mutate` set to one AFTER KN row ID.
3. Read `integrity` first. Exit 2 means the partition is incomplete or a fidelity check failed.
4. Decide C1 and C2 from the asserted checks and the per-claim lines, not from exit codes alone.

## 9. BASE blob identities used

| Path (BASE) | sha256 |
|---|---|
| `corpus/self-counts.py` | `5b600f0a997929cace485fc280bc74be5f0ef6f63711195855db0feaa79a6654` |
| `corpus/self-counts.tsv` | `ceadba8964006d29b4ab2cca9256615730c3829ac7af8f8738cb55b8412d80f4` |
| `corpus/release-clock.py` | `ef17654e0b7fcdee1cdf35d40dc359b194ce4b0711247877dedfa43ff6ef45cc` |
| `corpus/release-clocks.tsv` | `99a9b4bc36df89a0a86ca7fe16f922aab0abf8f4c3a3380bacdd8924cd02e6fd` |
| `corpus/claim-ledger.tsv` | `3fcdab10441d18038726f15420ccc58c36c292c698a9c8ad433c3725fb7c2aa5` |
| `corpus/claim-ledger.sh` | `ec915f604ba6dce33672263ef53e7f79912f4af94bd42ffb1fc32b6eefbc8da5` |
| `SKILL.md` | `8370a36a6ce033085a453e07601a136d82cdb0aa74340b914a6ca982f2828de1` |
| `PROVINCE.md` | `616e33da6befe71ad82ea07defa88e59bbb67cec42fd4bbbe95a9ee63843565b` |
| `.ufo/waves/round-25/tools/c1-measure.sh` | `4d3022d508006976c446b7aff4e4ac4cd63a2eaba07c4100cf8a9c2b5b01029b` |
| `.ufo/waves/round-25/tools/final-measure.py` | `c7620dc676f14fce1b56cbed296cab609eece4b7e638e9346516e72028cc7c96` |
| `.ufo/waves/round-26/observe-2.json` | `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` |

`plans/round-27.md` is not in BASE; its line citations refer to the working-tree copy.
