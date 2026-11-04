# ReviewC1 — attack report on claim C1 (`corpus/prefreeze-control.sh`)

Seat: ReviewC1 (leaf reviewer). Date: 2026-11-04.
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, reviewed at `880824b1d3da5f70b2fe489a34fe866a47314672`
(`round-33: plan + frozen claims`), frozen BASE `76f4eeae7aa9af4dbb9423f5632b55791824253a`.
Deliverable under review: `.ufo/waves/round-33/build/prefreeze-control.sh`
sha256 `c265a5d82a8b3b0dc588ba3c9e5b5cd887de092127be36835584ee7f8b381e59`, 256 lines.
Installed copy `corpus/prefreeze-control.sh` is byte-identical (same sha256).
Scratch: `/fast/scratch/hyaku/kagi-r33/ReviewC1` (removed before yield); raw logs copied to
`.ufo/waves/round-33/build/review/ReviewC1-receipts.txt`.
Convention: **PASS = the claim survives the attack**; **FAIL = the attack defeats the claim**.
No lane file was edited; no vault contact; no network; only read-only git.

Method: (1) read the frozen interface in `plans/round-33.md` §C1 and the executor's frozen
interface text; (2) built an **independent reference implementation** of that interface in scratch
(`pf.sh`, 8-case selftest), used to establish what the spec itself does; (3) attacked the delivered
bytes directly; (4) re-ran the red witness with the delivered bytes (188 s) and with the reference
implementation (194 s).

---

## 0. Frozen targets, measured at review time

| # | Target (plans/round-33.md §C1) | Command | Observed | Verdict |
|---|---|---|---|---|
| a | round-33 controls: `PREFREEZE: CLEAN (controls=4 mismatch=0)` exit 0 | `cd $L && bash corpus/prefreeze-control.sh run --base 76f4eea… --controls plans/round-33.controls.tsv` | 4× `OK`, `CLEAN (controls=4 mismatch=0)`, rc=0 | **met** |
| b | round-32 controls: `MISMATCH (controls=2 mismatch=2)` exit 1, naming `sd5 expect=3 measured=1` and `total expect=10 measured=8` | `bash <delivered> run --base 32c35fe… --controls plans/round-32.controls.tsv` | exactly the three lines, rc=1 (188 s) | **met** |
| c | `--selftest` → `PASS (cases=N)` exit 0, N ≥ 8 | `bash <delivered> --selftest` | 10 cases, all `ok`, `PASS (10 cases)`, rc=0 | **met** |
| d | capabilities-table rows naming it ≥ 1 | `awk '/^## Capabilities$/,/^## Saturation$/' SCORECARD.md \| grep -c 'prefreeze-control.sh'` | `1` | **met** |

`$L` = `/home/vgpnk/Projects/shokunin/kagi-shokunin`. (b) was executed from the build copy with
`PREFREEZE_REPO=$L`; the installed copy is byte-identical and, installed at `corpus/`, derives
`LANE=$L` itself — verified with a probe row (`lane_is_lane expect=1 measured=1`) — so the run is
command-equivalent to the plan's literal invocation.

Admission note: at my first targets check (before the L1 landed its edits) (d) read `0` (SCORECARD
row absent) and the plan's own counting command could not run (artifact not yet installed). Both
were satisfied at the final check — installed copy present, (d)=1. The kill rule is therefore **not**
triggered at the final measured state; had the wave stopped before the L1 install, C1 would have
been a partial move by its own rule.

---

## 1. Red witness, verified independently

`plans/round-32.controls.tsv` replayed at `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`:

| source | `sd5` | `total` | verdict | exit | wall |
|---|---|---|---|---|---|
| plan §C1 target (b) | expect=3 **measured=1** | expect=10 **measured=8** | `MISMATCH (controls=2 mismatch=2)` | 1 | — |
| delivered bytes, my run | 3 / 1 | 10 / 8 | identical | 1 | 188 s |
| independent reference impl, my run | 3 / 1 | 10 / 8 | identical | 1 | 194 s |
| executor receipt `.ufo/waves/round-33/build/prefreeze-32.txt` | 3 / 1 | 10 / 8 | identical | 1 | — |
| `ExecReplay` independent replay (`build/replay/sweep-replay.txt:19-24`) | 1 | 8 | `MISMATCH n=8 (…SD5=1…)`, exit 1 | 1 | — |

The three disclosed facts agree: the round-32 declared values were estimates, the counter measures
`SD5=1` and `n=8`, and the delivered gate reports the mismatch rather than a clean pass. The
red-witness behaviour is real, not a recited string: the same binary measured `registry_rows
expect=72 measured=71` at `32c35fe` and correctly refused the round-33 controls there
(receipts §4).

**Receipt integrity (F2, observed then closed):** mid-wave, the artifact the plan designates as
the committed red witness, `.ufo/waves/round-33/final/c1-red-witness.txt` (md5 then
`c07402704533bdf9a0fcfbf604784c5f`), was **not** the canonical capture. Its first 50 bytes had been
overwritten in place with

```
MISMATCH sd5 expect=3 measured=1
7fd13f7e63a7ce9b
```

replacing the canonical `revision=32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b` line; both files were
653 bytes, so a size check could not see it. The `7fd1…` fragment is the last 16 hex of the rev,
i.e. the file had been hand-assembled, not captured. **The L1 replaced it before my final check:**
both files now read md5 `79808ecc9692ef007d0354c2fdec0ccd` and start with `revision=…`, so the
canonical artifact is now byte-exact. The finding is retained as evidence that the artifact path
is not capture-guarded (nothing prevents a hand edit); the verdict lines were correct throughout.

---

## 2. Cheat paths

### C1 — a stub that echoes the verdicts without running any command
```bash
S=/fast/scratch/hyaku/kagi-r33/ReviewC1
bash $S/stub.sh --selftest
bash $S/stub.sh run --base 76f4eeae7aa9af4dbb9423f5632b55791824253a --controls $L/plans/round-33.controls.tsv
bash $S/stub.sh run --base 32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b --controls $L/plans/round-32.controls.tsv
```
Observed (receipts §2): `PREFREEZE_SELFTEST: PASS (cases=8)` rc=0; `CLEAN (controls=4 mismatch=0)`
rc=0; `MISMATCH (controls=2 mismatch=2)` with both named rows rc=1. Target (d) is a grep over
`SCORECARD.md` and does not involve the script at all.
**Verdict: FAIL for the claim as a predicate.** All four targets are string/count assertions; a
20-line stub satisfies them. This is structural for any predicate phrased as "prints X" and is
*not* a defect of the delivered code — the delivered bytes are a real 256-line gate, and the M1
mutation below is killed by its own selftest. The defence is the wave's mutation seat plus code
reading, not the predicate.

### C2 — a controls file whose commands are all `echo <expect>`
```bash
bash <delivered> run --base 76f4eea… --controls $S/att/all-echo.tsv   # x=1 y=2 z=3 w=4
```
Observed: 4× `OK`, `PREFREEZE: CLEAN (controls=4 mismatch=0)` rc=0 (receipts §3).
**Verdict: FAIL for the claim.** The harness cannot distinguish a frozen controls file from an
author-written one, and the receipt records the controls *path* but not its hash (F4), so this
cheat is invisible in the artifact. The committed blob today is
`c7e8de695a8bd73162c50d382140ec8526d1feff` and matches the working tree; nothing in the gate or
receipt binds it.

### C3 — `--work` pointing at a tree that is not the named revision
Delivered semantics: `--work` (and `$TMPDIR`) is a **parent**; `EXTRACT=$(mktemp -d …)` is always
fresh and is removed on exit. Tested with an absolute `--work` pre-populated with the `76f4eea`
extraction (48 lesson files) and `--base 32c35fe` (46):

```bash
bash <delivered> run --base 32c35fe… --controls $S/att/lessons48.tsv --work $S/workB
bash <delivered> run --base 32c35fe… --controls $L/plans/round-33.controls.tsv --work $S/workC
```
Observed: `MISMATCH lessons expect=48 measured=46`; `MISMATCH registry_rows expect=72 measured=71`
(receipts §4). Extraction overwrites into a fresh dir, so no stale file survives.
**Verdict: PASS — cheat resisted.** (For contrast, a reference variant that treats `--work` as the
extraction target, and one that reuses a non-empty `--work` without extracting, both return CLEAN;
that shows the exploitability is a property of *how the interface sentence is read*, and the
delivered reading is the safe one.)

### C4 — relative `--work` / relative `TMPDIR`
```bash
bash <delivered> run --base 32c35fe… --controls $S/att/lessons48.tsv --work workB
TMPDIR=tmp bash <delivered> run --base 76f4eea… --controls $S/att/lessons46.tsv
```
Observed: every row `NORESULT … (no integer)` → `PREFREEZE: SETUP noresult` rc=2, with a bash
redirection error on stderr (`deliv.sh: line 226: workB/prefreeze.…/stderr/lessons.stderr: No such
file or directory`). **This is F1, not a cheat:** it can never produce a false CLEAN (all rows go
NORESULT), but a documented interface option fails wholesale and reports the wrong reason.
**Verdict: PASS for the claim (no false green), with defect F1.**

### C5 — `--base` label vs the revision actually measured
```bash
bash <delivered> run --base 76f4eeae… --controls plans/round-33.controls.tsv   # CLEAN 4/0
bash <delivered> run --base 880824b1d3da… --controls plans/round-33.controls.tsv  # CLEAN 4/0
```
Observed: two different revisions, **byte-identical** verdict lines; the harness prints no resolved
SHA and no `base=` line. The `revision=` field of the executor receipts is caller-supplied text.
**Verdict: FAIL for the claim's auditability.** The gate measures whatever `--base` resolves to and
says nothing about which commit that was; a receipt can pair a correct-looking verdict with any rev
label. The plan's counting commands pass full SHAs, so the risk is operator-side, but the capability
should print `base=<sha>` on the verdict path (F5).

---

## 3. Parse attacks (delivered bytes, `--base 76f4eea…`)

| id | controls command (and `expect`) | Observed | Verdict |
|---|---|---|---|
| P1a | `echo 'rows=8 (new=2)'`, expect 8 | `MISMATCH prose8 expect=8 measured=2` | PASS as specified — final digit run wins; a prose tail is silently measured, documented in the script header |
| P1b | same command, expect 2 | `OK prose2 expect=2 measured=2`, CLEAN | **footgun**: a writer reading the line as "8" and declaring 8 gets a red; declaring the trailing 2 gets a green |
| P2a | `echo '3 4'`, expect 3 | `MISMATCH two3 expect=3 measured=4` | PASS as specified |
| P2b | `echo '3 4'`, expect 4 | `OK two4 expect=4 measured=4`, CLEAN | **footgun** (last number wins, silently) |
| P3 | `echo 12 >&2`, expect 12 | `NORESULT err12 expect=12 (no integer)` → `SETUP noresult` rc=2 | PASS — stderr is never a measurement |
| P4 | `grep -c zzz corpus/README.md`, expect 0 | `OK grep0 expect=0 measured=0`, CLEAN | PASS — prints 0 while exiting 1; deliberately a measured 0 |
| P5 | command field containing a **real tab** (`printf "a<TAB>7"`), expect 7 | note `line 1: want id<TAB>expect<TAB>command` → `SETUP malformed-controls` rc=2 | PASS as implemented ("exactly two TABs"); the frozen text's "rest of the line, kept verbatim" conflicts — see F6 |
| P6a | expect `+3`, command `echo 3` | `SETUP malformed-controls` (`expect is not an integer: '+3'`) | PASS — validated at parse time |
| P6b | expect ` 3` (leading space) | `SETUP malformed-controls` | PASS |
| P7 | expect `3abc` | `SETUP malformed-controls` | PASS |
| P8 | `printf '72\nOK\n'`, expect 72 | `NORESULT last72 expect=72 (no integer)` rc=2 | PASS as specified — last non-empty line only; a trailing diagnostic loses the measurement |
| P9 | `printf '0\n'; exit 1`, expect 0 | `OK exit1 expect=0 measured=0`, CLEAN | PASS as specified (exit status ignored); broad: any failing command that prints a number is accepted |
| P10 | `true`, expect 0 | `NORESULT silent expect=0 (no integer)` rc=2 | PASS |
| P12 | empty expect field | `SETUP malformed-controls` | PASS |

The reference implementation of the frozen text behaved identically on P1–P4 and P8–P10; it differed
only where the frozen text is silent (non-integer `expect` validation), which the delivered script
correctly resolves by rejecting at parse time.

---

## 4. Selftest and mutation

Delivered `--selftest`: 10 cases (`equal-values`, `one-differs`, `two-differ`, `no-integer`,
`malformed-row`, `missing-controls-file`, `grep-c-exit1-is-zero`, `empty-controls`, `bad-rev`,
`timeout`), all `ok`, `PREFREEZE_SELFTEST: PASS (10 cases)` rc=0 — matches its receipt and exceeds
the required ≥8.

M1 mutation (copy of the delivered bytes, line 239 replaced by `if true; then`):

```
CASE equal-values               ok
CASE one-differs                FAIL rc=0 last=PREFREEZE: CLEAN (controls=2 mismatch=0)
CASE two-differ                 FAIL rc=0 last=PREFREEZE: CLEAN (controls=2 mismatch=0)
…
PREFREEZE_SELFTEST: FAIL (10 cases)   rc=1
```
**Verdict: PASS — the selftest really does fail when the comparison is broken.** The `equal-values`
case still passes under the mutant, as expected; `one-differs` is the case that kills it.

Independent reference mutation on my own implementation reproduced the same kill.

---

## 5. Findings (severity order)

**F1 — MEDIUM — relative `--work` (and relative `$TMPDIR`) makes every row a false `SETUP noresult`.**
`corpus/prefreeze-control.sh:208-226`: `WORK_ROOT=${WORK:-${TMPDIR:-/tmp}}` is used unnormalised;
`mktemp -d "$WORK_ROOT/…"` then yields a **relative** `$EXTRACT`, so `$BASE_DIR` and `$RECEIPTS`
are relative too, and the per-row redirection `2>"$errf"` (line 226) is resolved *after*
`cd -- "$BASE_DIR"` in the same subshell. Every row then fails redirection and becomes `NORESULT`.
Evidence: receipts §4 (both `--work workB` and `TMPDIR=tmp`); a one-line patch
`EXTRACT=$(cd -- "$EXTRACT" && pwd -P)` after line 210 restored correct behaviour for both
(`MISMATCH lessons expect=48 measured=46`, and a real measurement instead of SETUP). The selftest
never exercises a relative path (case 1 passes an absolute `"$tmp/w1"`), so this shipped green.
Not a false-CLEAN (fails closed, exit 2), but the advertised interface option is unusable as a
relative path and the reason printed (`noresult`) misattributes the failure.

**F2 — MEDIUM (observed, then closed by the L1 during review) — the designated red-witness artifact
was a corrupt splice, not the capture.**
`cmp`/`diff` against `build/prefreeze-32.txt` (observed mid-wave): same 653 bytes, first 50 bytes
replaced by `MISMATCH sd5 expect=3 measured=1` + the rev's last 16 hex chars, `revision=` line gone
(md5 `c0740270…` vs canonical `79808ecc…`). The verdict lines were intact, so the measurement stood,
but the artifact was hand-assembled — the exact receipt-integrity class this round exists to close.
By my final check the L1 had replaced it: both files now read md5
`79808ecc9692ef007d0354c2fdec0ccd` and start with `revision=…`. **Closed.** Residual: nothing in the
path prevents a hand edit, so a capture-time hash in the receipt (F4) is still worth adding.

**F3 — MEDIUM (process/calibration) — the round's own START receipt contains the defect class, and
the frozen controls do not cover it.**
`.ufo/waves/round-33/controls/base-values.txt:17` records `sweep_exit=0`, but the sweep's own verdict
block is `SELF_DESCRIPTION: MISMATCH n=2 (…)` and the script exits **1** there
(`corpus/self-description-sweep.sh:387-389`); `ExecReplay` independently measured `exit=1` for the
same tree (`build/replay/sweep-replay.txt:19-20`). `plans/round-33.controls.tsv` has four rows and
none of them measures an exit code — so the new gate, run exactly as the plan prescribes, returns
CLEAN while this misstatement stands. The gate *can* catch it when the row exists: a row
`exit_row 0 'false; echo $?'` measures `MISMATCH … measured=1` (receipts §7). Recommendation (does
not change this round's frozen predicate): correct or annotate the receipt, and add an exit-code
row in round 34's controls. This is the strongest calibration finding: capability landed, deployed
coverage does not reach its own motivating class.

**F4 — LOW/MEDIUM — the receipt does not bind the controls file.**
`prefreeze-33.txt`/`prefreeze-32.txt` record `revision=`, `script=`, `script_sha256=`, `command=`,
`cwd=`, and the output, but no hash of the controls file. Consequently C2 (all-`echo` controls) and
any substitution of the frozen controls file are invisible in the artifact that admission will read.
Add `controls_sha256=` (or a `controls_blob=` from `git hash-object`) to the receipt label, and
ideally print the resolved `base=<sha>` from the harness itself.

**F5 — LOW — the verdict line carries no revision identity.**
`PREFREEZE: CLEAN (controls=N mismatch=0)` is identical for `76f4eea` and `880824b` (demonstrated,
C5). The plan's counting commands pass full SHAs, so this is latent, but a receipt's `revision=`
field is free text. One extra `note`/line (`base=<resolved-sha>`), or including it in the verdict,
closes it.

**F6 — LOW — documentation/behaviour mismatches in `corpus/knowledge/prefreeze-controls.md`.**
(a) The interface section documents `NORESULT <id> expect=<e>`, but the script prints
`NORESULT <id> expect=<e> (no integer)` or `(timeout Ns)`. (b) The section headed **"Why the exit
code is part of the measurement"** argues the opposite of its title (exit codes are deliberately
ignored; only the printed integer is compared). (c) The frozen interface sentence "the rest of the
line, kept verbatim" conflicts with "exactly three TAB fields"; the delivered script resolves it
strictly (a tab inside the command is `SETUP malformed-controls`, P5) and its own header documents
"exactly two TABs" — but the frozen knowledge entry repeats the ambiguous phrasing, so a future
author may expect a tab to survive.

**F7 — NIT — `--work` is created when missing.**
`mkdir -p -- "$WORK_ROOT"` (line 209) creates a typo'd path in the caller's cwd before failing.
Low impact (the harness never writes lane files from the plan's commands), but a gate should not
create a directory it was merely pointed at.

**Non-findings checked:** 256 lines (≤260); `set -u` present; no `eval`; exit statuses only 0/1/2;
`git archive` failure is detected via `PIPESTATUS` (both git and tar) — a naive pipeline would
silently measure an empty tree, the delivered script does not; `git rev-parse --verify "$REV^{commit}"`
pre-validates `bad-rev`; blank/comment skipping and `empty-controls` are correct; per-row stderr ids
are sanitised (`${id//[^A-Za-z0-9._-]/_}`) so a `../../evil` id does not escape the extraction
(tested, no leftover file); the fixture repo's toplevel is asserted before its single commit; the
`PREFREEZE_REPO` env override is an undeclared-but-necessary resolution of the frozen spec's
contradiction (hardcoded lane path vs fixture-repo selftest) and is documented in the header —
it should also be named in the plan addendum, since it is the mechanism by which the gate can be
pointed at another repository.

---

## 6. Residual risk and verification gaps

- **Predicate gameability is unfixable inside a "prints X" predicate.** Stub (C1) and private
  controls (C2) both defeat it; only the mutation seat and human code reading stand between a stub
  and admission. The delivered code is genuine and the M1 mutant is killed, which is the best
  evidence available — but it is process evidence, not predicate evidence.
- **No controls row covers exit codes or the `sweep_exit` claim** (F3), so this round's CLEAN is
  true and simultaneously silent about a known-wrong field in its own START receipt.
- **Relative-path behaviour is untested by the selftest** (F1); the fix is one line but needs a case.
- (b) was executed from the byte-identical build copy with `PREFREEZE_REPO=$L`, not from the
  installed path; equivalence is argued from the identical sha256 plus the verified `LANE`
  derivation (`lane_is_lane expect=1 measured=1`), not from a literal third 188 s run.
- Not run (out of scope for this seat by the wave contract): shellcheck, the full lane gates, the
  C2 counters, and any form of vault or network access.
- `final/c1-red-witness.txt` was observed corrupt mid-wave (F2) and **was replaced by the L1 before
  my final check**; the two files are now byte-identical (md5 `79808ecc…`). Re-diff if the artifact
  is touched again before admission.

---

## 7. Verdict on C1

- Capability delivered and real: **PASS**. The gate extracts a named revision, measures on the
  extraction, fails closed on unmeasurable rows, and its selftest kills the accept-any mutant.
- Frozen targets (a)–(d): **all four met at the final measured state** (the first targets check,
  before the L1 landed the artifact and the SCORECARD row, had (d)=0 and no runnable counting
  command; both were satisfied at the final check).
- Red witness at `32c35fe`: **independently reproduced** by the delivered bytes (188 s) and by an
  independent implementation of the frozen spec (194 s): `sd5 expect=3 measured=1`,
  `total expect=10 measured=8`, `MISMATCH 2/2`, exit 1.
- Surviving cheats: **stub** and **private all-`echo` controls** (both defeated only by code
  review/mutation, not by the predicate); `--work`-points-at-another-tree is **resisted**.
- Defects to fix before the gate is relied on as a general capability: **F1** (relative path),
  **F3/F4/F5** (receipt provenance and coverage). **F2** (red-witness artifact) was closed by the
  L1 during review. None of the findings produces a false CLEAN on either frozen controls file;
  F1 is a defect of this delivery, F3–F5 are calibration gaps of the deployed configuration.
