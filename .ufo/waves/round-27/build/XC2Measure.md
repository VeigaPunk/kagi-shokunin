# XC2Measure: round-27 C2 downgrade counting instrument (draft, UNRUN)

Frozen BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b`. Unlabelled citations are `path:line` in that commit. Reproduce with `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin show 0a47dd189356ea66ec83c3891eed54526e95b89b:<path> | cat -n`. I read a `git archive` copy of the commit, not the working tree.

Citations marked **(WT)** are working-tree files that are NOT in BASE (checked with `git cat-file -e`): `plans/round-27.md`, `.ufo/waves/round-27/c2-before.json`, `.ufo/waves/round-27/tools/c2-measure.py`. They describe the round, not the frozen code.

Status: the instrument is drafted and was NOT run, as assigned. Behaviour claims below are code-derived inference, marked [INFERENCE], until L1 runs it. No check in this report passed by execution.

Axes named (godspeed): (1) fidelity of expectations to plans/round-27.md, (2) independence from release-clock.py, (3) sensitivity: what the assigned S040 fixture can and cannot see.

## 1. Deliverable

- Draft: `.ufo/waves/round-27/sandboxes/XC2Measure/c2-measure.py` (stdlib Python 3, 17,948 bytes, tag 91A9).
- Interface: `python3 c2-measure.py <rev> <label> [--expect auto|base|after] [--work DIR]`. `auto` means base when rev is `0a47dd18…`, otherwise after.
- Steps:
  1. Resolve rev in the lane repo. Scratch-clone it with git's global and system config disabled, then check out the rev detached.
  2. Run the clone's `corpus/release-clock.py` with no arguments (default offline check). Match its summary against the R25-04 pin text in `corpus/claim-ledger.tsv`, read as data and never executed.
  3. Build a downgrade fixture in the work dir. Copy the clone's `corpus/` and its current receipt `.ufo/waves/round-26/observe-2.json`. Forge S040 in both: table observed `3.15.0` / verdict `fired`, and receipt `parsed_version` `3.15.0` / verdict `fired`. Before forging, require the rev's own S040 receipt to agree with its row, so only the lie differs.
  4. Run the clone's `release-clock.py --root <fixture> --receipt .ufo/waves/round-26/observe-2.json --receipt-sha <sha256 of forged receipt>`.
  5. Judge. base: exit 0, `CLEAN`, no findings, fired count +1 (lie counted as a release event). after: exit 1, `FAILED`, `REGRESSED S040` present, fired count not raised. default (both modes): exit equal to the pin's exit (0), `CLEAN`, no findings, summary matches the R25-04 pin.
- Output: `c2-measure.json` in the work dir (argv, exit, stdout, stderr, finding lines, fixture before/after lines and records, reasons) plus a printed summary. Exit 0 = PASS (expectation met), 1 = FAIL, 2 = SETUP.
- Writes only under the work dir (default `sandboxes/XC2Measure/runs/`). Each run clones the lane (the BASE working-tree archive alone is 46 MB; the clone adds `.git`), so delete the run directory after use.
- Pins hard-coded at round-27 BASE: `RECEIPT_REL`, `LEDGER_ROW`, `TARGET`, `DOWNGRADE`. A candidate that moves the default receipt shows as SETUP or FAIL; the draft does not guess.
- Relation to the existing `.ufo/waves/round-27/tools/c2-measure.py` (WT): that tool computes counts without expectations or precondition checks. My draft is a second, independent implementation for cross-check. It differs in: per-phase PASS/FAIL, ledger-pin match, coherence precondition, fired-count "never a release event" check, Traceback detection, and hard-coded paths. The existing tool's `LANE = parents[4]` (line 24) works only in place, and it writes scratch under `/fast/scratch` (line 41).

## 2. BASE facts the draft relies on

### 2.1 The accepted lie (why BASE returns CLEAN)

- `corpus/release-clocks.tsv:30`: S040, clock `feed`, feed S039, anchored `3.15.1`, observed `3.15.1`, verdict `not-fired`. Also `:24-25` (S027/S028 fired, 3.15.0 → 3.15.1) and `:31` (S041).
- `.ufo/waves/round-26/observe-2.json:312-322`: S040 receipt record, `parsed_version` `3.15.1`, `not-fired`. Also `:246-256` (S027), `:257-267` (S028), `:323-333` (S041).
- `corpus/SOURCES.md:47`: S040 is `on-release`, anchor "title Python 3.15.1 documentation". `:46`: S039 is kind `docs`, recheck `90d`, so the feed binding is valid. `:33-34`: S027/S028 are `on-release` with 3.15.0 anchors. `:42`: S036 is `90d`.
- `corpus/release-clock.py:507-526`: feed branch. BADFEED (`:509-514`) and anchor naming (`:517-518`, via `version_is_named` at `:341-346`) pass. `:524-526`: `verdict == "fired" and norm(observed) != norm(anchored)` sets `row_fired`. No ordering test appears anywhere in the branch.
- `:378-408` `receipt_matches`: verdict equality (`:387`), `observed_at` date equality (`:388`), and `parsed_version` equality after `norm_version` (`:393-399`). No ordering.
- `:527-531`: a `not-fired` downgrade (observed ≠ anchor) falls to `INCONSISTENT`. So BASE accepts only the `fired` label on a downgrade. A forger must also forge the label.
- `:558-561` count; `:579` `passed = not errors and bound == on_release`; `:583-590` print `CATEGORY ID` lines then `RELEASE_CLOCK: STATE (on_release=… fired=…)`; `:1603-1604` exit mapping.
- Predicted at BASE for the lie [INFERENCE, unrun]: exit 0, `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=4 derived=15)`, no finding lines. The existing artifact `.ufo/waves/round-27/c2-before.json:9-31` (WT) records the same stdout; I did not run it and have not re-verified it.

### 2.2 Default offline check

- `corpus/release-clock.py:28`: `DEFAULT_RECEIPT_SHA256 = 13b8540c…`. A read-only sha256 of `.ufo/waves/round-26/observe-2.json` at BASE gives `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169` (10,964 bytes). It matches, so the default receipt pin holds [observed hash; the script was not run].
- `:448-450` default receipt path. `:1573-1575` explicit receipts need a digest; `:1594-1597` select the expected digest. `:1562` help text: "default is the round-26 rearmed receipt".
- `corpus/claim-ledger.tsv:83` R25-04: command `python3 corpus/release-clock.py`, exit 0, pattern `^RELEASE_CLOCK: CLEAN \(on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15\)$`. `:82` R25-03 is the selftest pin (67 cases), not run.
- Read-only parse: `corpus/SOURCES.md` has 41 registry rows, 30 of them `on-release`, which matches the pin's on_release=30.
- Predicted at BASE [INFERENCE from the pin, unrun]: exit 0, `CLEAN`, fired=3.

### 2.3 Other facts

- `corpus/release-clock.py:654-699` `parse_latest_version` already compares versions numerically (`tuple(int(...))` at `:699`). A candidate should reuse that precedent.
- `:730-734` `observe_one` labels any `parsed ≠ anchored` as `fired`, with no ordering.
- `corpus/lessons/round-26.md:231-233` names the inherited limit: "the evaluator defines fired as observed-version unequal to anchor, not strictly newer. A stale/cropped feed could regress and un-fire an older anchor; no monotonic-history guarantee is made."
- `plans/round-27.md:26-28` (WT): C2 problem, including "(or un-fires an already fired predecessor)". `:29-31`: the rule, which is only "observation below the anchor" for numeric X.Y.Z, with non-numeric anchors kept as a declared limit. `:32`: sourcing by version-precedence rows "opened this round". `:33-35`: counting command.
- At BASE, no `corpus/SOURCES.md` row mentions precedence, and no `REGRESSED` token appears under `corpus/` (case-sensitive grep). So the category and the sourcing are both new in round 27.

## 3. Counterexamples (code-derived; none executed)

### CE1: un-fire of a predecessor passes the literal C2 rule (main finding)

- Fixture: S027 (anchor `3.15.0`, `SOURCES.md:33`, bound to S036 `SOURCES.md:42`). Table `release-clocks.tsv:24` observed `3.15.1`→`3.15.0`, verdict `fired`→`not-fired`. Receipt `observe-2.json:246-256` parsed `3.15.0`, `not-fired`.
- BASE: equality branch `:527-528` accepts it. Result CLEAN, fired 3→2.
- Existing artifact `c2-before.json:58-81` (WT; `unfire`: S027 and S028 forged): exit 0, CLEAN, fired=1. Recorded there, not run by me.
- Literal C2 (`plans/round-27.md:29-31`, WT) refuses only an observation below its own anchor. 3.15.0 is not below 3.15.0, so the un-fire stays CLEAN. The plan's own problem statement (`:28`, WT) names this path, and the literal rule does not close it.
- Consequence [INFERENCE]: for the four existing fixtures (WT `c2-before.json:9-104`), a candidate implementing the literal rule gives:
  - lie: refused (REGRESSED S040).
  - rollback (`c2-before.json:32-57`): refused via REGRESSED S040 and S041. S027/S028 still CLEAN.
  - unfire: still CLEAN.
  - nonnumeric: still CLEAN (declared limit, CE4).
  So the accepted count goes 4→2, not 4→0.
- Decision for L1 (I do not choose): (a) refuse when observed is below the highest numeric anchor bound to the same feed URL. S036 and S039 both use `https://www.python.org/downloads/feed.rss`, so the key must be the URL: keyed on feed_source_id, S036 vs S039 would miss this case. (b) Sticky-fired per row. (c) Name it a declared limit and amend `plans/round-27.md:28` (WT).

### CE2: the assigned S040 fixture cannot see a string-compare defect

- Ordering check (eval, pure Python, not an instrument run): `"3.15.0" < "3.15.1"` is True as strings and as tuples, so S040 passes under either comparator. `"3.9.0" < "3.15.0"` is False as strings and True as tuples.
- A candidate that compares strings would accept a `3.9.0` downgrade of a `3.15.0` anchor (for example S027 observed `3.9.0`, fired) as CLEAN, and the S040 fixture would stay green. The existing `nonnumeric` fixture (S012 `1.20.0` vs `v1.21.x`) is outside the numeric rule, so it does not test this either.
- Needs a precedence fixture before C2 is claimed closed.

### CE3: the observe path labels a regression as a release event

- `observe_one` (`corpus/release-clock.py:730-734`) writes verdict `fired` for any `parsed ≠ anchored`. A receipt from a stale feed therefore records a regression as a release event.
- The TSV-side refusal still catches a forged table row. The receipt label is not refused by the check as written.
- `--observe` needs the network, so the draft does not exercise it. A candidate should relabel there too (`plans/round-27.md:30`, WT: "never a release event").

### CE4: declared limit, accepted CLEAN (for the record)

- S012 anchor `v1.21.x` (`corpus/release-clocks.tsv:9`, `SOURCES.md:18`) with observed `1.20.0` fired. The inequality rule keeps it. The existing artifact `c2-before.json:82-104` (WT) records CLEAN, fired=3. This matches `plans/round-27.md:31-32` (WT), so I list it only so the count is visible.

### CE5: non-numeric observation below a numeric anchor (unmeasured)

- Example: observed `3.15.0a1` against anchor `3.15.1`. The "both numeric X.Y.Z" gate fails, so the inequality rule applies and the row is accepted.
- `STABLE_TITLE_RE` (`corpus/release-clock.py:649`) and `parse_latest_version` (`:654-699`) exclude prereleases from observe, so this needs a hand-written TSV row. Not measured.

## 4. Coverage against the plan's counting command

- Covered by the draft: the downgrade fixture (lie) with per-phase expectations; default pin; the fired-count "not a release event" check; crash detection; the coherence precondition.
- Not covered: CE1, CE2, CE3, CE5; a dedicated upgrade control (the default check's three legitimate fired rows S012, S027, S028 cover this indirectly); derived rows (`note` begins `derived:`); the selftest-count clause of the plan (out of scope).

## 5. Run plan for L1 (once, after integration)

1. `python3 .ufo/waves/round-27/sandboxes/XC2Measure/c2-measure.py 0a47dd189356ea66ec83c3891eed54526e95b89b base`. Expect exit 0 and `verdict=PASS`, with default `match` and downgrade `counted=True`.
2. `python3 …/c2-measure.py <candidate-rev> after`. Expect exit 0 and `verdict=PASS` (the instrument's own exit; the downgrade run itself must exit 1). `counted=False`, `refused=True`.
3. Cross-check the lie row against the existing `tools/c2-measure.py` artifact (WT; lie: exit 0, CLEAN, fired=4 at BASE).
4. Before claiming C2 closed: add a CE1 (un-fire) and a CE2 (precedence, e.g. S027 observed `3.9.0`) fixture, or name them declared limits.

## 6. What I did NOT check

- Did not run: the draft (no execution, no syntax check beyond reading it back); release-clock.py at any rev (BASE default, BASE lie, selftest); the existing `tools/c2-measure.py`; any candidate rev (none exists yet).
- Did not read at BASE: `corpus/release-clock.py:176-211` (`valid_public_https_url`), `:334-338` (`valid_iso_date`), `:795-827` (`run_observe`), the selftest bodies beyond the cited lines, and `:654-699` except the numeric max line. Read `:129-152` (`parse_captures`: 16-field rows, which the fixture path depends on).
- Did not compare the working tree with BASE, and ran no `git status` or `git log`.
- Did not check C1 self-counts, SOURCES prose, stamps, SKILL/README/PROVINCE default-receipt wording, LOG, or lessons beyond the cited line.
- Did not confirm the "version-precedence rows opened this round" sourcing (`plans/round-27.md:32`, WT). None exists at BASE; no candidate exists to check.
- Did not touch the network, CDP, vault, op, or any host-private path. The draft scrubs `HOME` and disables git's global and system config.
- Did not verify DEFAULT pin execution; only the file hash matched.

## 7. Tooling and writes

- No tools installed or updated. Read-only use of `git archive`, `rev-parse`, `cat-file` and `python3 --version` (3.14.8) on the lane repo (no clone or checkout in the lane, no lane writes). Python in the eval kernel: sha256 and text parsing of BASE files, plus the two ordering expressions in CE2.
- Writes: the draft and this report. A throwaway BASE copy used for reading (`sandboxes/XC2Measure/base-snapshot/`) was removed after reading.
