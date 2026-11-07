# R56ExecControls — prefreeze executable controls for `plans/round-56-c1.sh`

Seat R56ExecControls, kagi round 56 attempt 1, lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `832ba6a53d6a76706b5c80bce2278683dea33d42`. 2026-11-07, receipts 07:33–08:05 -03:00. Observed answering model for this session: `zai/glm-5.3-flashx` (session workstation metadata, not inferred from the prompt). No production file was edited; no git/jj mutation anywhere (reads only: `rev-parse`, `cat-file`, `archive`, `show`, `ls-files`, `diff`, `log`, `status`); no fixture writes; no tool installs (RULES.md read; none needed). Scratch `/fast/scratch/hyaku/kagi-r56/R56ExecControls/` — every run self-cleans via `trap rm -rf`; directory verified empty and deleted before this yield.

## Deliverables (only paths this seat wrote)

- `.ufo/waves/round-56/build/R56ExecControls.d/controls.sh` — the proposed controls instrument, sha256 `feaaa14e68d5a3c69e2b5e7113c23594fb7571cac0a00826046eda411feebee6` (syntax-checked `bash -n` rc 0 after last edit). Scored runs 4/5 with the prior table revision `fa134cd2313b89259418f34fd4ddd07844ef013006e27b947fc15c78c3de539d`; per-epoch expectation revisions are annotated in the script comments and each run's receipt records the script's self-hash.
- `.ufo/waves/round-56/build/R56ExecControls.d/controls-run.txt` — receipt of the LAST run (per-run overwritten by design): header pins reference tree, counter/gate/manifest/self sha256; one `CONTROL <id> rc=<rc> MATCH|MISMATCH expect=<ERE> got=<line>` block per control; full counter stdout appended on every MISMATCH; `COUNTER-CHANGED-MIDRUN` line when the guard fires; self-hash re-recorded at end.
- This report.

## Instrument

`bash .ufo/waves/round-56/build/R56ExecControls.d/controls.sh --tree <landing-root> [--only ERE] [--receipt P]`

- Takes one snapshot of the reference overlay (`git ls-files -co --exclude-standard` when `--tree` is a git toplevel, verified via `rev-parse --show-toplevel`; `cp -a` otherwise), then per control copies that snapshot into an isolated scratch tree, applies exactly one mutation, runs the public counter `HYAKU_SCRATCH=<run> bash plans/round-56-c1.sh --tree <copy>` (or the revision form for C01), and compares rc + the full `C1_REPLAY:` line against an expectation ERE fixed in the script before the scored run of each epoch.
- Counter integrity guard: the counter's sha256 is pinned at run start and re-verified before every invocation; any change aborts with rc 3 and records both hashes. This fired four times during the wave — every verdict in every receipt is bound to one counter revision.
- 39 controls, ≥20 genuine per spec, no padding: 2 calibration (BASE rev-mode 0; landing 10), 5 r1 clock-shape attacks, 6 r2 manifest/registry attacks, 6 r3 body-integrity attacks (incl. the named-ceiling witness C15), 4 r4 replay attacks, 4 r5/guard attacks (incl. the full gate-forgery witness C23), 12 fail-closed/SETUP/tolerance attacks.

## Findings (each names bytes/rc/ids)

**F1 — Gate-identity forgery hole in the 096251c9 draft; demonstrably closed by the epoch-B pin.** Against counter `096251c9b7a7405dbae320eb4dbb3ef0a092cf5e530d2274de0b2e29509bde9a` + gate `b7782f35…` (epoch-A draft, pre-predeclaration), control C23 replaced `corpus/recheck-replay.py` with a 20-line python printer that fabricates all ten `MATCH <entry>:<L> id=<id> form=<form> stated=<N> replayed=<N>` lines from public knowledge and ends `RECHECK_REPLAY: CLEAN (clocks=10 …)`; `--selftest` prints PASS. Observed: `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)`, rc 0 — a full gate forgery scored the target (run 2, receipt section `C23-R5-gate-printer-forged-match`). r4/r2/r3 are the counter's own work, so the only defense was r5 trusting gate stdout shape. C22 (printer without MATCH lines) read `value=0 present=10 replayed=0 gate=1 guard=1` — right answer, wrong reason. The epoch-B repair (`GATE_SHA256_PIN=<gate sha>`, committed at `5d9a1571911ec38a456a40b443e19640abb9a88b`) makes C23 read `value=0 … gate=0 guard=1` (run 4 MATCH) — hole closed; C22/C23/C24 are kept as regression witnesses. Residual note: the pin moves with the gate bytes, so the counter and gate must be re-pinned in the same commit; the kill-rule diff pathspec covers `plans/*` only, so a gate-only edit would pass the diff check while breaking the pin — safe-by-failure (value=0), but worth one sentence in `plans/round-56.md`.

**F2 — Crash bugs in the intermediate draft `0153f876…` (post-epoch-A repair, mid-wave).** While manifest() was changed to return a tuple, one saved revision still called it single-valued: four mutation classes produced rc 1, a python traceback and NO `C1_REPLAY` line (fail-open in the "one output line" contract): C29 malformed manifest row (`TypeError: 'NoneType' object is not subscriptable`), C30 entry deleted / C31 registry deleted / C32 restated-with-fresh-capture (`TypeError: list indices must be integers or slices, not str`), all at `<stdin> line 121` (run 2 receipt, counter output sections). Fixed later the same hour (`man, man_malformed = manifest()`). Lesson for freeze: every parse-defect path must land in the graded verdict (r2-*/SETUP), never an exception.

**F3 — r5 makes the reading all-or-nothing; the `bad=` list is the real diagnosis.** The counter's gate verdict requires the pinned digest AND `--root` rc 0 AND a last line exactly `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 …)` (counter `6b132ea1…`/`d2bcb790…` line: `m.groups() == ("10","10","0",…)`). Consequence, measured repeatedly (runs 2–5): whenever the measured gate's own population changes (gutted/duplicated/indented clock line, deleted entry, restated-N-with-fresh-capture — controls C03/C06/C07/C30/C32), the gate reports CLEAN over 7/9/11 clocks, the shape check rejects it, `gate=0`, and `replayed` collapses to 0. At P=10 the value is therefore always 0, 10 or FAIL; intermediate counts occur only when the gate stays CLEAN but a clock fails r2 (C13 `value=9 gate=1`). No code change requested — but `plans/round-56.md` could say "replayed is 0-or-P; `bad=` carries the per-clock diagnosis" so a future reader does not expect gradation.

**F4 — The named ceiling is real and pinned: C15.** Tampering `S054.body` (+1 byte) AND restating the manifest digest scores `value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` on every epoch tested (096251c9, 6b132ea1). This is the plan's declared ceiling ("a hand-written capture with a self-consistent manifest row scores; provenance is the fetch receipt and a non-author live re-fetch"), not a defect. C38 (truncated PDF body, digest restated) correctly reads `value=0 … gate=0` via r4 `r4-replayNone` + gate TOOL/DRIFT.

**F5 — Manifest row-uniqueness tolerance, then fail-closed.** On 096251c9/6b132ea1, a duplicate-id row over a fresh non-clock URL with a reused `body_path`+sha256 (C36) scored `value=10 (bad=none)` — the counter's list-parse has no cross-row checks while the gate's dict-parse SETUPs on duplicate URLs (C10: counter `r2-rows2`, gate SETUP `manifest-duplicate-url`). The epoch-C draft (d4dc9ddc/`d4392ffe…`) fail-closes the whole manifest on shared `body_path`/`sha256` and malformed `fetched`/`http_status`, so C36 must now read `value=0 … bad=r2-manifest-malformed:` (expectation updated; not yet scored — churn). Direction is correct (binding tightens).

**F6 — Guard semantics worth one line in the plan.** Epoch C makes a present-but-unpinned gate force `SELF_OK=0` (counter `d4dc9ddc…`: "a gate file that is present but not the pinned bytes can never satisfy the selftest conjunct either"), so C22/C23/C24 read `value=FAIL … guard=0`, while an ABSENT gate keeps `guard=1` → `value=0` (C25) — i.e. "no gate" reads as a number, "tampered gate" reads FAIL. Intentional per the GUARD definition ("when the measured tree carries the gate"), but the asymmetry is easy to misread; the controls pin it either way.

**F7 — Post-freeze churn record (facts, not adjudication).** Epoch-B was frozen at `5d9a157` (counter `6b132ea1b521e698aaf4a1085e051087726c6b5ec840f60339b206abe02b269c`, gate/PIN `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51`). The working tree then moved at least six times inside ~40 minutes: counter `6b132ea1→127f00c5→d2bcb790→be4af051→a0b0d9e5→7992ee6a…`, gate `2e9dfde3→d4392ffe→4c3e10a8…` (every transition caught and recorded by the instrument's guard; runs 5–8 receipts + service logs). The kill rule binds `5d9a157→candidate` on `plans/round-56.{md,-c1.sh,-controls.sh}`; the current working tree is not the frozen bytes. Re-freeze/epoch-C bookkeeping is the L1's call; this seat only records it.

## Scored evidence per counter revision

| Revision (counter sha256-16) | Instrument rev | Controls scored | Result |
|---|---|---|---|
| `096251c9…` (epoch-A draft) | `0100afcf…` (shakeout) then `fa134cd2…` | runs 1–2, all 39 | BASE 0, landing 10, 20/39 vs pre-shakeout table; **all mismatches instrument-side** (2 quoting bugs skipped mutations; 17 expectations ignored r5's global CLEAN conjunct); F1 forgery `value=10`; L1's own epoch-A receipt `controls-prefreeze.txt`: 12/12 MATCH (independently consistent) |
| `0153f876…` (transition) | — | C29–C32 only | 4× rc 1 crash, no verdict line (F2) |
| `6b132ea1…` + gate `2e9dfde3…` (**frozen epoch B, commit `5d9a157`**) | `fa134cd2…` | run 4, all 39 | 34 MATCH; C03/C06/C07/C30/C32 got-lines (recorded verbatim in run-4 extract and matching the corrected table below) |
| same frozen bytes | `fa134cd2…` | run 5, 36 of 39 | 33/33 MATCH incl. C30; guard aborted rc 3 on `→127f00c5` (C32 ran mid-swap, rc 2) |
| `d4dc9ddc…` + `d4392ffe…` (epoch-C draft) | `feaaa14e…` | run 6 | C01, C02 MATCH (landing 10 on the new manifest rules); guard rc 3 `→be4af051` |
| `be4af051…` | `feaaa14e…` | run 7 | C01–C04 MATCH; guard rc 3 `→a0b0d9e5` |
| `a0b0d9e5…` + gate `4c3e10a8…` | `feaaa14e…` | run 8 | C01 MATCH; C02–C16 got-lines are expectation-deltas against a revision this seat never read (e.g. C16 now `value=FAIL … guard=0 (…,selftest,gate-digest)` — F6 semantics plus a re-introduced `gate-digest` token); guard rc 3 `→7992ee6a` |

Cross-checks: L1 epoch-A receipt `.ufo/waves/round-56/controls/controls-prefreeze.txt` 12/12 MATCH (read; its F2/F5/F6/F9/F10 got-lines byte-agree with mine for the same controls); L1 epoch-B receipt `.ufo/waves/round-56/controls/controls-prefreeze-epochB.txt` 16/16 MATCH and readings `5d9a157→value=10`, `BASE→0`, `42070de→0 (gate-digest)` [peer-reported by KagiR56a3, not re-read by this seat].

## The 39-control table (expectations as fixed for the frozen epoch-B pair, all MATCH-evidenced in runs 4+5)

Format: id — mutation — expected `C1_REPLAY` fields (rc 0 unless noted). `V/P/R/G/U` = value/present/replayed/gate/guard.

| id | attack | V | P | R | G | U | first bad token |
|---|---|---|---|---|---|---|---|
| C01-BASE-no-work | revision mode, landing absent | 0 | 10 | 0 | 0 | 1 | r2-manifest: |
| C02-REF-positive | pristine landing | 10 | 10 | 10 | 1 | 1 | none |
| C03-R1-clock-deleted | backticked clock gutted, line kept | FAIL | 9 | 0 | 0 | 0 | absent: |
| C04-R1-N-restated | stated N 1→2 | FAIL | 9 | 0 | 0 | 0 | absent: |
| C05-R1-command-retexted | `-fsSL`→`-fsSLX` in clock | FAIL | 9 | 0 | 0 | 0 | absent: |
| C06-R1-second-clock-line | byte-identical clock restated on 2nd line | FAIL | 9 | 0 | 0 | 0 | absent: |
| C07-R1-recheck-indented | recheck line off column 1 | FAIL | 9 | 0 | 0 | 0 | absent: |
| C08-R2-manifest-absent | manifest file deleted | 0 | 10 | 0 | 0 | 1 | r2-manifest: |
| C09-R2-row-missing | S054 row dropped | 0 | 10 | 0 | 0 | 1 | r5-gate: (then r2-rows0) |
| C10-R2-row-duplicate | byte-identical duplicate row | 0 | 10 | 0 | 0 | 1 | r5-gate: (then r2-rows2) |
| C11-R2-url-swap | S054/S055 urls exchanged | 0 | 10 | 0 | 0 | 1 | r2-registry: |
| C12-R2-manifest-id-dangle | manifest id S054→S999 | 0 | 10 | 0 | 0 | 1 | r5-gate: (then r2-registry) |
| C13-R2-registry-status-minted | registry `mined`→`minted` | 9 | 10 | 9 | 1 | 1 | r2-registry: |
| C36-R2-duplicate-id-other-url | extra row, reused body_path/sha | 10 | 10 | 10 | 1 | 1 | none (epoch B) → 0 / r2-manifest-malformed: (epoch C) |
| C14-R3-body-tampered | +1 byte, manifest stale | 0 | 10 | 0 | 0 | 1 | r5-gate: (then r3-digest) |
| C15-R3-ceiling-handwritten-capture | +1 byte, digest restated (NAMED CEILING) | 10 | 10 | 10 | 1 | 1 | none |
| C16-R3-body-symlink | body → symlink out of capture dir | 0 | 10 | 0 | 0 | 1 | r3-file: |
| C17-R3-header-bytes-digest-fixed | `HTTP/2`+`set-cookie` prepended, digest restated | 0 | 10 | 0 | 0 | 1 | r5-gate: (then r3-headers) |
| C18-R3-body-absent | body file deleted | 0 | 10 | 0 | 0 | 1 | r5-gate: (then r3-file) |
| C34-R3-bytes-col-tampered | bytes column −1 | 0 | 10 | 0 | 0 | 1 | r5-gate: (then r3-digest) |
| C35-R3-sha-col-swap | two sha256 cells exchanged | 0 | 10 | 0 | 0 | 1 | r5-gate: (then r3-digest ×2) |
| C19-R4-body-filter-drained | pattern removed, digest restated | 0 | 10 | 0 | 0 | 1 | r5-gate: (then r4-replay0) |
| C20-R4-normaliser-lying-stub | measured `rendered-text-v1.py` → count=7 stub | 0 | 10 | 0 | 0 | 1 | r5-gate: (counter's r4 uses BASE copy and passes) |
| C21-R4-unsupported-second-clock | `sed`-pipe clock added as 2nd line | FAIL | 9 | 0 | 0 | 0 | absent: |
| C38-FC-malformed-capture-body-pdf | PDF truncated to 10 B, digest restated | 0 | 10 | 0 | 0 | 1 | r5-gate: (then r4-replayNone) |
| C22-R5-gate-printer-clean-only | python printer, CLEAN+PASS only | 0 | 10 | 0 | 0 | 1 | r5-gate: (epoch B) |
| C23-R5-gate-printer-forged-match | printer + 10 fabricated MATCH lines | **10 on 096251c9**; 0/0/0/1/1 on epoch B | | | | | r5-gate: |
| C24-R5-selftest-broken | `PASS`→`FAILX` in gate bytes | 0 | 10 | 0 | 0 | 1 | r5-gate: (epoch B; epoch C: FAIL/guard=0) |
| C25-R5-gate-absent | gate file deleted | 0 | 10 | 0 | 0 | 1 | r5-gate: |
| C26-FC-setup-bad-tree | `--tree /nonexistent` | rc 2 `C1_REPLAY: SETUP tree` | | | | | — |
| C27-FC-capture-dir-deleted | whole `round-56/capture/` deleted | 0 | 10 | 0 | 0 | 1 | r3-file: ×7 + r5-gate ×3 |
| C28-FC-manifest-header-malformed | header col `sha256`→`sha` | 0 | 10 | 0 | 0 | 1 | r2-manifest: |
| C29-FC-manifest-row-malformed | S101 row shortened to 6 cols | 0 | 10 | 0 | 0 | 1 | r2-manifest-malformed: (epoch B+) / r2-manifest: (A) |
| C30-FC-entry-absent | ISO entry deleted (3 clocks) | FAIL | 7 | 0 | 0 | 0 | absent: ×3 |
| C31-FC-registry-absent | SOURCES.md deleted | 0 | 10 | 0 | 0 | 1 | r2-registry: ×10 |
| C32-FC-restated-with-fresh-capture | N restated AND capture reforged to match | FAIL | 9 | 0 | 0 | 0 | absent: |
| C33-FC-entry-symlink | knowledge entry → symlink | FAIL | 9 | 0 | 0 | 0 | absent: (gate UNSUPPORTED symlinked-entry on repaired gates) |
| C37-FC-knowledge-dir-absent | `corpus/knowledge/` deleted | FAIL | 0 | 0 | 0 | 0 | absent: ×10 |
| C39-FC-setup-no-tools | `env -i PATH=/nonexistent` | rc 2 `C1_REPLAY: SETUP no-python3` | | | | | — |

## Method discipline (disclosed)

Run 1 was an instrument shakeout: two `sub` calls carried unescaped backticks (mutations C04/C32 never applied) and seventeen expectations ignored that r5's gate-CLEAN conjunct is global. All 19 run-1 mismatches were instrument defects; the counter was never modified by this seat. Expectations were re-derived from the counter/gate source and re-fixed before each scored run; every scored run's receipt pins counter/gate/manifest/self sha256, and the counter guard (rc 3) converts any mid-run lane edit into a recorded abort instead of a mixed verdict. Counter revisions this seat observed and characterized: `096251c9…`, `0153f876…`, `6b132ea1…` (frozen epoch B), `d2bcb790…`, `be4af051…`, `a0b0d9e5…`; gates `b7782f35…`, `637c8184…`, `2e9dfde3…`, `d4392ffe…`, `4c3e10a8…`.

## Frozen epoch-C verdict (anchor `711e6393e68658f396918c07de253e5a5c74d1b4`, superseded by epoch D)

Predeclaration epoch C landed at 08:0X -03:00 (per KagiR56a3): counter `7992ee6a97c9f1cfaf627c61322ecaf6aa0c31126a65f591567d7b6f7ee2802c`, gate `e9b7e4b7aa1e8173c4bfc2e536ce6d1ed29c4c0d6ee5f46bfa1e63d3692a62b4` (= GATE_SHA256_PIN; the gate additionally pins normaliser `14f6ca6a…`, selftest "PASS (18 cases)", introduces the trailing `gate-digest` token, capture_confined body paths, column-0 header refusal, manifest fetched/2xx/bijection, SELF_OK=0 on present-but-unpinned gates). Instrument re-anchored (`feaaa14e…` header names the commit; run 9 = `controls-run.txt`).

**Run 9 (scored, no churn): 36/39 MATCH on the frozen pair** — counter and gate hashes re-verified identical after the run. Provenance: `controls-run.txt` is last-writer-wins (each run overwrites it), and run 10's guard abort subsequently overwrote run 9's file; run 9's full 39-line listing is preserved in this seat's session transcript, and its decisive evidence is quoted verbatim below. The three mismatches are expectations one epoch behind, and their got-lines (quoted verbatim from run 9) match the frozen counter's semantics exactly, completing a 39/39 semantic agreement:

- C10 duplicate manifest row → `value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest-malformed:…)` — the new body_path+sha256 bijection fail-closes the manifest, exactly like C36. Expectation fixed.
- C20 lying normaliser stub → `value=FAIL present=10 replayed=0 gate=0 guard=0 (bad=r5-gate:…,…,selftest)` — the gate's normaliser pin refuses the stub and the selftest exercises the tree's own normaliser, so the selftest conjunct fails and guard drops. Expectation fixed. This is a strengthening: a tampered locate producer now costs GUARD, not just the count.
- C30 deleted ISO entry → `value=FAIL present=7 replayed=0 gate=0 guard=0 (bad=r5-gate:…,absent:…)` — the five present clocks processed before the ISO entry fail r5 first, so the bad list opens with `r5-gate`, not `absent`. Expectation fixed (token order only; value fields as epoch B).

Post-receipt churn: minutes after run 9 the working tree moved again (counter `7992ee6a→d6afdfe89983360c1bea9c5adceb8957e05f39a105bd4719cf7da7e5a5dd6900`, gate `e9b7e4b7→7d3e75bae9288a5caf1f34d7e4ecb070cd9639f98d02f5a86331ab9276a9f4ef`, caught by the guard in run 10 after 5/5 MATCH). Those bytes are uncommitted and bound by no kill rule; the anchor for this seat's evidence remains `711e6393`. Final receipt at freeze time: one command, `CONTROLS: total=39 match=39` expected against whatever revision the candidate binds — the three rows fixed above are already aligned with the epoch-C semantics that produced them.

Epoch-B rows in the table above stand as measured (run 4/5); the epoch-C frozen readings for every row are: C01 0/10/0/0/1, C02 10/10/10/1/1, C03–C05 FAIL/9/0/0/0 absent:, C06–C07 FAIL/9/0/0/0 absent:, C08 0/10/0/0/1 r2-manifest:, C09 0/10/0/0/1 r5-gate:, C10 0/10/0/0/1 r2-manifest-malformed:, C11 0/10/0/0/1 r2-registry:, C12 0/10/0/0/1 r5-gate:, C13 9/10/9/1/1 r2-registry:, C14 0/10/0/0/1 r5-gate:, C15 10/10/10/1/1 none (ceiling), C16 0/10/0/0/1 r3-file:, C17 0/10/0/0/1 r5-gate:, C18 0/10/0/0/1 r5-gate:, C19 0/10/0/0/1 r5-gate:, C20 FAIL/10/0/0/0 r5-gate:, C21 FAIL/9/0/0/0 absent:, C22/C23/C24 FAIL/10/0/0/0 r5-gate:, C25 0/10/0/0/1 r5-gate:, C26 rc2 SETUP tree, C27 0/10/0/0/1 r3-file:, C28 0/10/0/0/1 r2-manifest:, C29 0/10/0/0/1 r2-manifest-malformed:, C30 FAIL/7/0/0/0 r5-gate:, C31 0/10/0/0/1 r2-registry:, C32 FAIL/9/0/0/0 absent:, C33 FAIL/9/0/0/0 absent:, C34/C35 0/10/0/0/1 r5-gate:, C36 0/10/0/0/1 r2-manifest-malformed:, C37 FAIL/0/0/0/0 absent:, C38 0/10/0/0/1 r5-gate:, C39 rc2 SETUP no-python3.

## Frozen epoch-D verdict (anchor `d36231871c864c930d3e7e33f9c5345b30ab4f98`, superseded by epoch E) — CLEAN PASS

Epoch D superseded 711e6393 (R56MutCounter F9 + R56ReviewCounter G1/G2): header refusal is now `(?im)` any-case in gate and counter, N boundary excludes `_`/`.`, gate selftest 20 cases. Counter `82acbb2056aac6055a79f223a0e0abbb2cb24f11f01ca5ed12a230c8338bdc6a`, gate/PIN `5165da2a6fced02fce82c92fc898553db9a6d3d702d9fc6d1ca3ba185e77b14f`, working tree clean at the freeze.

**Run 11 (scored, no churn): `CONTROLS: total=41 match=41 mismatch=0`, rc 0** — the on-disk receipt `controls-run.txt` IS this run (last writer), counter and gate hashes re-verified identical post-run. The suite grew to 41 controls with two regression witnesses for the epoch-D fixes, both MATCH:

- **C40-R3-header-case-canonical** — S057.body prepended `HTTP/2 200` + capitalised `Set-Cookie:` with the manifest restated, so only the case rule is exercised. Under 711e6393 this scored `value=10` (the `(?m)`-only hole MutCounter F9 caught); under d362318 it reads `value=0 present=10 replayed=0 gate=0 guard=1 (bad=r5-gate:…,r3-headers:…)` with the gate at DRIFT (BAD-CAPTURE header-bytes).
- **C41-R1-N-boundary-underscore** — stated N encoded `-> 1_0`. Under 711e6393's `(?![0-9A-Za-z])` boundary this read PRESENT and scored; under d362318 PRESENT fails (`value=FAIL present=9 replayed=9 gate=1 guard=0 (bad=absent:…)` — the gate's own CLOCK_RE still parses stated=1, so its population stays 10 and CLEAN).

The epoch-C frozen readings for every other row carried over unchanged and all MATCH (C01 0/10/0/0/1; C02 10/10/10/1/1; C03–C07, C21, C32, C33 FAIL with r1 `absent:`; C08/C10/C28/C29/C36 0/10/0/0/1 via r2-manifest/-malformed; C09/C11–C14, C16–C20, C25, C27, C34/C35, C38 0/10/0/0/1 with the epoch-C token orders; C13 9/10/9/1/1; C15 10/10/10/1/1 — the named ceiling; C22/C23/C24 FAIL/10/0/0/0 — gate-forgery witnesses; C26/C39 rc 2 SETUP; C30 FAIL/7/0/0/0 r5-gate-first; C31 0/10/0/0/1; C37 FAIL/0/0/0/0).

Epoch-C section above stands as the historical record for 711e6393 (run 9, 36/39 + 3 got-lines); its C17 did NOT cover canonical-case smuggling — C40 now does.

## Frozen epoch-E verdict (anchor `dd31b7867723f89fc8f83e88cc7d98e17de26cf2`, superseded by epoch F) — CLEAN PASS

Epoch E supersedes d362318 with guard/doc hardening only, verdict semantics unchanged and pins unchanged: counter `d468533fbf593c4b2a3a97dc513b9feb2cff765892c126c02d7c6ef40273a954`, gate/PIN `5165da2a…`, normaliser pin `14f6ca6a…`. New: the counter SETUPs (rc 2) when `sha256sum`/`cut`/`tail`/`timeout`/`git`/`tar` are missing — and `no-python3` remains the FIRST check, so C39's `SETUP no-python3` expectation carries over exactly.

**Run 12 (scored, no churn): `CONTROLS: total=41 match=41 mismatch=0`, rc 0** — the on-disk receipt `controls-run.txt` is this run; counter and gate hashes re-verified identical post-run. All 41 expectations carried over from the epoch-D pass unchanged; instrument sha256 `75305a363b2814ab72f4fe752b64bd565c151a7cb444f93deee1ff95fd988e6c` (anchor header names dd31b786).

## Frozen epoch-F verdict (anchor `9cbe9d5f803de2518d4c11c6bc6b9a585e5120ad`, current kill-rule binding) — CLEAN PASS

Epoch F supersedes dd31b786: manifest `fetched` is now calendar-validated (shape AND `datetime.date.fromisoformat`) in gate AND counter (R56MutCounter-2 m31); their side also fixed a vacuous control (ReviewCounter I1) and bumped GATE_SHA256_PIN. Counter `f4c1de312e4a566dfde6c0699fb66a94c2e71e459eb97afbddb5c4073ffd2382`, gate/PIN `b6959d6c7afb9380c043cbd40530e6a70ee8da2bf79f1ea9d0669706f50bb5a3`, normaliser pin unchanged, tip `c90e6709` carries the freeze + receipts.

**Run 13 (scored, no churn): `CONTROLS: total=42 match=42 mismatch=0`, rc 0** — the on-disk receipt `controls-run.txt` is this run; counter and gate hashes re-verified identical post-run. Suite grew to 42 with one new regression witness, MATCH:

- **C42-R2-fetched-calendar-invalid** — S055 row's `fetched` set to `2026-02-30`: valid shape under the epoch-E regex (would have PASSED), refused by `fromisoformat` → `value=0 present=10 replayed=0 gate=0 guard=1 (bad=r2-manifest-malformed:…)`; independent of their F28 (different row, impossible-not-just-malformed date).

All other 41 expectations carried over from epoch E unchanged. Vacuity self-check (the ReviewCounter I1 class): every mutation in this suite asserts its file change and every row's got-line is recorded per run — C14/C34/C35 (digest families), C15 (ceiling by design), C36/C10 (bijection), C40/C41/C42 (epoch-D/F witnesses) were re-checked non-vacuous against their recorded got-lines.

## Risks, blockers, recommended next steps

1. **Blocker for a single-receipt 39/39 verdict:** the working-tree counter/gate are under active revision (F7). The instrument is settle-ready — at the freeze candidate run exactly: `bash .ufo/waves/round-56/build/R56ExecControls.d/controls.sh --tree /home/vgpnk/Projects/shokunin/kagi-shokunin`; rc 0 + `CONTROLS: total=39 match=39 mismatch=0` is the pass. If verdict shapes change again (new tokens/fields), only the affected rows' EREs need re-derivation from source; the guard + receipts localize which revision produced which line.
2. **Kill-rule coupling:** the gate PIN inside the counter makes `corpus/recheck-replay.py` effectively frozen with `plans/*`; the kill-rule pathspec names only `plans/*`. A gate-only candidate edit would pass the letter of the diff check while failing every reading (value=0) — recommend stating the PIN coupling in `plans/round-56.md` (L1's call).
3. **Ceilings to keep named:** C15 (hand-written capture scores 10 — by design), C24-class selftest check is an environment guard only once the pin exists, absent-gate reads `value=0` with `guard=1` (F6 asymmetry), C13 shows registry-status enforcement lives only in the counter (gate stays CLEAN) — fine, but the gate's CLEAN is not a registry-status verdict.
4. No secrets, cookies, vault or session material was read, captured or printed; the only network surface touched by these controls is none (all offline). Counter/gate behaviors were exercised on scratch copies only.
