# CritRowSafety — R23-01 / R23-02 command safety and expectation pinning

Seat: `KagiR23.CritRowSafety` (critic, round-23 falsify). I stayed read-only on the lane and
wrote nothing there except this file. Scratch copies went under
`/tmp/kagi-r23-critrowsafety/` and were deleted after the run. I did not run `verify`, any
host-bound row, or any legacy gate. No tool was installed.

## Target and revision binding

The lane moved while I reviewed it. It started as base `d218603` plus the uncommitted tree
(my first read), then went through `e1884c6` (01:04:19), `ea5b734`, `b55e0e7`, `7af07b4`,
`284d40e` and `638d44c`, ending at **`def9bc2e12534ae2c2492bae1034eb8122c2c179`** (01:11:47 -0300).
Every measurement below was rerun on `git archive def9bc2` copies. At run time the worktree
differed from def9bc2 in 0 paths under `corpus/` and `SCORECARD.md`. All path:line references
are to def9bc2. After my run the worktree gained one lesson wording edit and its stamp
(`round-23.md` grows by one line after :132). No finding depends on that edit.

Three changes between the uncommitted tree and def9bc2 bear on this seat. I count them as
improvements, not findings:
- The fixture is now pinned at `corpus/stamps.tsv:21-25`. It had no rows in the uncommitted tree.
- A `**REJECTED` adjudication is now parsed (`closure-dispositions.py:99`). The uncommitted tree
  matched only `**ADMITTED.**`.
- The D9 pointer changed. It used to be `corpus/claim-ledger.tsv`, which resolved on R23-01's
  note text "routed D9". It is now `corpus/fixtures/cells-hermetic/SCORECARD.md`, which resolves
  on a new line-1 HTML comment.

**Re-verified at `58bd8d70d310ecaac0316e4b576073cc75142332` (01:16:35 -0300, worktree drift 0).**
Every finding below still reproduces there. One change matters: D3 moved from `fixed` to
`reported`, so R23-02 now pins `fixed=6 reported=3`, and the pinned line in the P-series becomes
`… fixed=6 reported=3 …`. See the Addendum for the reruns and for which findings the lane has
since disclosed.

## Answers to the three questions

1. **Can a count-preserving fixture edit keep the exact CELL_AUDIT line green?**
   - **Yes, for R23-01 alone.** All 8 count-preserving mutants printed the byte-identical
     pinned line (exit 0).
   - **No, at ledger level, if the edit is unreviewed.** The fixture pins (`stamps.tsv:21-25`)
     flag every mutant. R22-03 goes red: exit 1, `REVISION_AUDIT: DRIFT (stale=1 …)`.
   - **Yes again after a one-row re-pin** (`corpus/stamps.tsv | 2 +-`). R12-03, R22-03 and
     R23-01 all pass while fixture row R90-02 reaches `$HOME` through `~`.
2. **Can a deferred or self-skipped row inflate `rows_run`?**
   - **Deferred: yes, by construction.** One run printed `rows_run=2 row_deferred=1` with only
     one row executed. R23-01's exact `row_deferred=0` rejects this, unless the caller's
     environment exports `KAGI_SUBSTRATE=present`. Then the line is byte-identical and passes.
   - **Self-skipped: `rows_run` is not inflated, but `row_pointed` is.** The round's own
     operability cell (`SCORECARD.md:841`) rests only on R23-01, and `cells` SKIP-SELFs R23-01.
     In a scratch tree with the same cell shape (S1), the cells audit stayed CLEAN after I broke
     R23-01.
   - **Duplicate ids also inflate it.** `rows_run` counts rows, not ids: two copies of `R90-01`
     give `rows_run=2`.
3. **Can R23-02 pass with an all-prose disposition set?**
   - **Yes, and the committed set already is one.** All 7 `fixed` pointers resolve on prose or
     comment tokens.
   - A 4-file tree whose only evidence is a 3-line prose file, with every note set to 24×`x`,
     prints the byte-identical pinned line.
   - D9 still resolves with the fixture cut down to its comment line and R23-01 deleted from the
     ledger. On that same tree R23-01 exits 2.

## Findings

### F1 — R23-02 counts prose and comment tokens as `fixed` (calibration · high · fixable defect)

- **Mechanism.** `resolve_pointer` (`closure-dispositions.py:104-127`) applies two tests:
  - The anchor test passes if *any* line starting with `#` contains the anchor substring
    (:119-122).
  - The `fixed` test passes if the id token appears *anywhere* in the file (:123-126).

  The docstring and the R23-02 note disclose this bound (`closure-dispositions.py:41-45`;
  `claim-ledger.tsv:60`: "Records existence, not fix quality").
- **Committed state: the line that actually supplies each `fixed` id token.**
  - D1 resolves on `round-23.md:15`, the sentence "routed defects D1-D9". It does not use its own
    paragraph at :66-77.
  - D3, D4, D5 and D6 resolve on `round-23.md:84/:92/:98/:102`.
  - **D7 resolves on `source-fetches.tsv:2`**, the comment `# D7: bind every mined row …`.
  - **D9 resolves on `fixtures/cells-hermetic/SCORECARD.md:1`**, the comment
    `<!-- D9: hermetic cells fixture; rows are declared in claims.tsv -->`.

  None of the 7 resolves against a claim row, a row result, or a stamped digest.
- **Executed counterexamples.** All ran the R23-02 command in a copy of def9bc2. Each printed
  the byte-identical line `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2
  operator_owned=1 no_action=5 rejected=0 pointers=15)` with exit 0.
  - **P1.** The whole tree is `closure-dispositions.{py,json}`, the source lesson, and
    `corpus/prose.md` (`# Routed defect dispositions` / `D1 D3 D4 D5 D6 D7 D9`). Every pointer
    targets prose.md and every note is 24×`x`.
  - **P2a.** The fixture is cut down to `SCORECARD.md` containing only its comment line;
    `claims.tsv`, `stamps.tsv` and `corpus/` are deleted, and the R23-01 row is removed from the
    ledger. On the same tree, R23-01 exits 2 (`claims file not found`).
  - **P2b.** `corpus/source-fetches.tsv` is replaced by the single line `# D7`.
  - **P6.** D1's paragraph (`round-23.md:66-77`) is deleted.
- **Impacted claims.**
  - `SCORECARD.md:843` (C1: "7 fixed") and `:851` ("pointer-resolving disposition") count
    prose records as fixes.
  - The parent-build constraints are not met mechanically: `ClaimR13X01.md:145`,
    `ClaimR15X03.md:113-115` and `ClaimR11X01.md:203-208` require D9 to resolve to the
    executable fixture plus R23-01, "not to prose that names D9". A comment line satisfies the
    check.
- **What still guards.** The JSON is pinned (`stamps.tsv:14`) and so is the fixture scorecard
  (`:21`). An unreviewed rewrite of either goes stale under R22-03. A reviewed re-pin goes
  through, and no check distinguishes executable evidence from prose.
- **Smallest safe correction.**
  - Give `fixed` dispositions a typed evidence field. Either `row: R23-01`, resolved against
    `corpus/claim-ledger.tsv` (row exists, not `[substrate]`, not self-invoking, with
    command/expect digest recorded), or a path that has a matching `corpus/stamps.tsv` row.
  - Search for the id only in non-comment lines inside the anchored section.
  - Emit `fixed_executable=N` and pin it in R23-02.
  - If the checker is not changed, reword `SCORECARD.md:843/851` to "7 prose records marked
    fixed".

### F2 — R23-01 pins summary counts, not fixture semantics (operability, freshness · medium · partly fixable)

- **Executed counterexamples.** Each used a def9bc2 copy and the exact R23-01 command. Each
  printed the byte-identical CLEAN line (exit 0, row PASS):
  - **M1.** R90-01's expectation is weakened from `^FX: OK$` to `.`.
  - **M2.** `corpus/fx-ok.sh` is rewritten to read a file outside `--root` and *append* to one
    (the side-effect file afterwards holds `18`). The fixture's own stamp row for fx-ok.sh is
    never compared in `cells` mode, because only cell-cited paths are compared
    (`claim-ledger.sh:830-841`; disclosed at `round-23.md:159-160`).
  - **M3.** Two `R90-01` rows replace R90-02, and the scorecard's R90-02 citations are changed
    to R90-01. Result: `rows_run=2` from one id and one command. No duplicate-id refusal exists
    (`load_ids` `claim-ledger.sh:606-617`; `verify_claims` :400-446).
  - **M3b.** On top of M3, one `# no-enumerate` declaration is deleted (the count becomes 7) and
    the fixture's stamp is re-pinned. It still passes, so the plan's mutation case no longer
    bites.
  - **M4.** R90-02 greps an absolute path outside the fixture root.
  - **M4b.** R90-02 becomes `grep -c x ~/kagi-r23-critrowsafety-nonexistent-probe`, with exit 2
    and the expectation set to grep's not-found line. Running the same command directly
    expands `~` to `/home/vgpnk/…`; the probe path does not exist, so no content was read.
  - **M6b.** One declaration is deleted, the expectation becomes `^7$`, and the fixture's
    stamps row is re-pinned.
  - **M7.** fx-ok.sh re-invokes the gate (see F5).

  Control **M6a** (delete one declaration, nothing else) gives exit 1 with
  `CELL_AUDIT: BROKEN (… row_failures=1 stale_pointers=1 …)`, so the exact pin does work when
  counts move.
- **Command safety.** I extracted `policy_check` verbatim from def9bc2 and evaluated it in
  scratch:
  - It refuses `grep -c x $HOME/probe` (rc=1, `metachar`; `META_RE` at `claim-ledger.sh:163`).
  - It allows (rc=0) `~/…`, `/tmp/…`, `../../../…`, and `sha256sum /etc/hostname`.

  So the R23-01 note's "no $HOME, no substrate probe, no network" (`claim-ledger.tsv:59`) and
  the lesson's "No real host path is read" (`round-23.md:167`) describe the reviewed bytes. No
  check enforces them.
- **What actually guards: the pin layer.**
  - In my comparison of the 5 fixture rows at `stamps.tsv:21-25`: M1/M2/M4/M4b/M7 have 1 stale
    row, M6b has 3, M3b has 4, and the control has 0.
  - A real run in a scratch `git clone --no-hardlinks` at def9bc2 (X1): after the M4b edit,
    R22-03 exits 1 with `REVISION_AUDIT: DRIFT (stale=1 missing=0 dropped=0 added=16 invalid=0)`
    and `STALE corpus/fixtures/cells-hermetic/claims.tsv`. R23-01 stays PASS.
  - **Re-pin bypass (X2).** I rewrote only the `claims.tsv` row in `corpus/stamps.tsv`
    (`2 +-`). Then R12-03 printed `79` (PASS), R22-03 printed `CLEAN (stale=0 … added=16 …)`
    (PASS), and R23-01 PASS, with the `~`-reaching row in place. All three are count- or
    pin-based, so a single line in a reviewed diff is the only signal. This matches the lane's
    stated stance (`claim-ledger.sh:18`: "Regenerating is a reviewed commit"), so the bypass
    itself is a **tradeoff**.
- **Fixable parts.** These are safe at def9bc2: 0 ledger commands use `~`, a leading-`/`
  operand, or `..`, and there are 0 duplicate ids.
  1. In `policy_check`, refuse `~`, plus leading-`/` and `..` operands. This makes "no $HOME"
     mechanical for row commands, though not for script bodies.
  2. Refuse duplicate claim ids in `load_ids`/`verify_claims`.
  3. Have a fixture cell also cite `claims.tsv` and `corpus/fx-ok.sh`, so R23-01 compares them
     itself, and re-pin `stamp_pointed=` in R23-01.

### F3 — The round's own operability cell rests on a self-skipped row (operability, calibration · medium · fixable)

- The cell at `SCORECARD.md:841` (Round 23 post-move, operability) cites only `R23-01`. That
  command contains `claim-ledger.sh`, so `cells` SKIP-SELFs it (`claim-ledger.sh:816-819`). The
  pre-move cell at `:830` cites R15-05, which is re-run, and R13-03, which is skipped.
- **S1 (executed).** Scratch scorecard: operability cites only R23-01, the other five cells cite
  a trivial row, and the ledger row is copied verbatim.
  - The cells audit gives exit 0 with `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 …
    rows_run=1 … self_skipped=1 orphans=0)`.
  - I then broke R23-01 in the same tree. Run directly, it gives exit 1 with `BROKEN (…
    row_failures=1 stale_pointers=1 …)`.
  - The same cells audit again gives exit 0 with the identical CLEAN line. R13-03's regex
    (`claim-ledger.tsv:38`, `self_skipped=[0-9]+`) accepts both runs.
- **Impact.** This repeats M23-3 inside the round's own scored cell, against the lesson's fix
  text "the real-tree claim is not made" (`round-23.md:148`).
- **Correction.** Do one of the following:
  - Add a pointer that `cells` re-checks to `SCORECARD.md:841`, for example
    `corpus/fixtures/cells-hermetic/claims.tsv`, which is pinned at `stamps.tsv:22`.
  - Or have `cells` count cells whose only row pointers were self-skipped (`self_only_cells=N`)
    and pin it to 0.

### F4 — Deferral inflates `rows_run`, and the pin depends on the environment (operability · low · fixable)

- **Mechanism.**
  - `C_N` is incremented at `claim-ledger.sh:415`, before the DEFER branch at :416-418, and
    `CL_ROWS_RUN=$C_N` is set at :828.
  - The `KAGI_SUBSTRATE` override is documented for the selftest (:138-139) but read
    unconditionally (:140-146).
  - `verify_claims` passes the caller's environment through to nested rows (:426-427).
- **M5 (executed).** I added `[substrate]` to R90-02's note.
  - With `KAGI_SUBSTRATE=absent`: `DEFER R90-02` and `CLEAN (… rows_run=2 row_deferred=1 …)`,
    exit 0. The R23-01 row FAILs, so the pin works.
  - With `KAGI_SUBSTRATE=present`: the byte-identical pinned line, row PASS.
- This only happens after an edit to the pinned fixture. The R23-01 note now concedes that
  `rows_run` includes deferrals.
- **Correction.** Report `rows_executed` separately, or ignore `KAGI_SUBSTRATE` outside
  `--selftest`.

### F5 — A fixture script can re-invoke the gate without SKIP-SELF seeing it (operability / command safety · low · tradeoff)

- **M7 (executed).** fx-ok.sh runs `bash ../../claim-ledger.sh --help`, and the marker file
  reads `gate-invoked`. R23-01 still prints the byte-identical line with `self_skipped=0`. The
  guard is only a substring test on the row's command text (`claim-ledger.sh:816`).
- **[INFERENCE, not executed: it would run host-bound rows].** The same script could run
  `bash ../../claim-ledger.sh cells` with no `--root`. ROOT then defaults to the real lane
  (`claim-ledger.sh:102-106`), and the real scorecard's cited rows would be re-run from inside
  R23-01. The nesting guard refuses only `verify` (:236-238).
- The fx-ok.sh pin (`stamps.tsv:24`) and review bound this. Every `bash corpus/*.sh` row shares
  the same property.

### F6 — The negative halves of C1 and C3 are not pinned by any ledger row (calibration, operability · low-medium · fixable)

- **REJECTED branch has no test.** The branch at `closure-dispositions.py:99` has no selftest
  case; the selftest's only adjudication fixture is `**ADMITTED.**` at :246.
  - Mutant: I removed ` or line.startswith("**REJECTED")` from a def9bc2 copy. `--selftest`
    still gives exit 0 with `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)`, so the mutant
    survives.
  - The real branch works (P4a/P4b below), but nothing would notice if it were removed.
- **The closure selftest is not a ledger row.** `claim-ledger.tsv:60` is the only
  closure-dispositions row, so the "14 cases" at `SCORECARD.md:851` and `round-23.md:205` are
  unpinned. By contrast, R22-02, R22-04 and R21-03 pin their own selftests.
- **No committed mutation case for C3.** The plan says "a fixture mutation case must fail"
  (`plans/round-23.md:38-42`), but nothing committed runs one.
  - `claim-ledger.sh` changed only `PYTHON_SCRIPT_RE`, and its selftest stays at 121
    (`claim-ledger.tsv:23`, `:50`).
  - The lesson hands the negative case to "the falsify wave" (`round-23.md:164-165`).
  - My M6a reproduces it today; nothing reruns it later.
- **Correction.**
  - Add a `rejected-adjudication` selftest case.
  - Add a ledger row `python3 corpus/closure-dispositions.py --selftest` pinned to the measured
    count.
  - Commit a broken-fixture twin with its own row (exit 1, pinned `BROKEN` line). This needs
    the R21-04/QM14 migration.

## Held (attacked, did not break)

- **Policy.** The R23-01 and R23-02 commands pass `policy_check` (rc=0) and contain no
  metacharacters. R23-01's nested `cells` at `CLAIM_LEDGER_DEPTH=1` is allowed by design
  (`claim-ledger.sh:229-238`).
- **Python arguments.** `PYTHON_SCRIPT_RE` (`:161`) admits arbitrary trailing arguments for the
  new script. `python3 corpus/closure-dispositions.py --root / --source etc/hostname
  --dispositions /tmp/x.json` gets rc=0. But grep and sha256sum already accept absolute
  operands (rc=0), so this is **no new read class**. R23-02 as committed takes no arguments and
  reads only lane files.
- **R23-01's exact pins.** They kill an all-deferred fixture (M5-absent), a failing cited row
  (M6a), and orphans.
- **Kind changes and the closure source.**
  - Changing a disposition kind changes the counts, so R23-02's pin catches it.
  - A count-preserving swap is not caught. P3 swapped D2 (reported) and D3 (fixed) and got the
    byte-identical line, exit 0.
  - The closure source has no stamps row (0 rows), but it is chained through the pinned JSON
    digest (`stamps.tsv:14`). P5 rewrote D9's demand and re-digested the JSON; the line was
    byte-identical with exit 0, and only the JSON pin would show it.
- **REJECTED handling works today.**
  - P4a: source changed to `**REJECTED.**` with the ADJ row kept gives the identical CLEAN line,
    exit 0, so ADJ is still owed.
  - P4b: the same with the ADJ row dropped gives `DISPOSITION MISSING ADJ` and `FAILED (…
    missing=1 …)`, exit 1.

## Commands and exits

Row verdicts follow `verify_claims` semantics (`claim-ledger.sh:426-443`): `cd ROOT`,
`CLAIM_LEDGER_DEPTH=1`, `timeout -k 5 T bash -o pipefail -c CMD`, then both an exit match and an
ERE match on the last non-empty line. I emulated this with the harness below, without invoking
`verify`.

| id | tree | command | exit | last line (abridged) | row |
|---|---|---|---|---|---|
| R23-01@def9bc2 | archive | R23-01 cmd (`claim-ledger.tsv:59`) | 0 | `CELL_AUDIT: CLEAN (cells=6 … rows_run=2 row_deferred=0 … self_skipped=0 orphans=0)` | PASS |
| R23-02@def9bc2 | archive | `python3 corpus/closure-dispositions.py` | 0 | `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 … pointers=15)` | PASS |
| selftest | lane | `python3 corpus/closure-dispositions.py --selftest` | 0 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)` | — |
| M0 | copy | R23-01 | 0 | identical | PASS |
| M1 / M2 / M3 / M3b / M4 / M4b / M6b / M7 | copy | R23-01 | 0 each | identical | PASS each |
| M5 absent | copy | R23-01, `KAGI_SUBSTRATE=absent` | 0 | `… rows_run=2 row_deferred=1 …` | FAIL |
| M5 present | copy | R23-01, `KAGI_SUBSTRATE=present` | 0 | identical | PASS |
| M6a control | copy | R23-01 | 1 | `CELL_AUDIT: BROKEN (… row_failures=1 stale_pointers=1 …)` | FAIL |
| S1 before / after break | copy | scratch `cells` vs R13-03 regex | 0 / 0 | `CLEAN (… rows_run=1 … self_skipped=1 …)` both | PASS / PASS |
| S1 R23-01 direct after break | copy | R23-01 | 1 | `BROKEN (… row_failures=1 stale_pointers=1 …)` | FAIL |
| P1 / P2a / P2b / P3 / P5 / P6 | copy | R23-02 | 0 each | identical | PASS each |
| P2a R23-01 | same tree | R23-01 | 2 | `claim-ledger: claims file not found: …` | FAIL |
| P4a / P4b | copy | R23-02 | 0 / 1 | identical / `FAILED (… missing=1 …)` | PASS / FAIL |
| REJECTED mutant | copy | `--selftest` | 0 | `PASS (14 cases)` | survives |
| X0 | clone | R12-03 / R22-03 / R23-01 | 0 / 0 / 0 | `79` / `CLEAN (stale=0 … added=16 …)` / identical | PASS ×3 |
| X1 (M4b edit) | clone | R23-01 / R22-03 | 0 / 1 | identical / `DRIFT (stale=1 …)` | PASS / FAIL |
| X2 (re-pin `stamps.tsv`, 2 +-) | clone | R12-03 / R22-03 / R23-01 | 0 / 0 / 0 | `79` / `CLEAN (… added=16 …)` / identical | PASS ×3 |

There was an earlier run on the transitional, pre-commit tree. It gave the same R23-01 mutant
results. I discarded its P-series because my copy set lacked the moved D9 target.

## Reproduction (verbatim harness, run as `bash exp2.sh` → `REV=def9bc2…`, `SCRIPT_EXIT=0`)

```bash
#!/usr/bin/env bash
# CritRowSafety (kagi round-23 falsify), commit-bound rerun. Reads the lane
# (git archive / clone --no-hardlinks); writes only under $B/run2. No `verify`.
set -uo pipefail
LANE=/home/vgpnk/Projects/shokunin/kagi-shokunin
B=/tmp/kagi-r23-critrowsafety
W=$B/run2
rm -rf -- "$W"; mkdir -p "$W/base"
export PYTHONDONTWRITEBYTECODE=1
unset KAGI_SUBSTRATE CLAIM_LEDGER_DEPTH
REV=${1:-$(git -C "$LANE" rev-parse HEAD)}
git -C "$LANE" archive --format=tar "$REV" corpus SCORECARD.md | tar -x -C "$W/base"
L=$W/base; F=corpus/fixtures/cells-hermetic
field() { awk -F'\t' -v id="$1" -v n="$2" '$1==id{print $n}' "$L/corpus/claim-ledger.tsv"; }
C1=$(field R23-01 2); E1=$(field R23-01 3); C2=$(field R23-02 2); E2=$(field R23-02 3)
E1303=$(field R13-03 3); C1203=$(field R12-03 2); E1203=$(field R12-03 3); C2203=$(field R22-03 2); E2203=$(field R22-03 3)
run_row() { # LABEL ROOT CMD EXPECT WANT TMO [ENV=VAL...]  (claim-ledger.sh:426-443 semantics)
  local label=$1 root=$2 cmd=$3 exp=$4 want=$5 tmo=$6; shift 6
  local out rc=0 last verdict
  out=$(cd "$root" && env "$@" CLAIM_LEDGER_DEPTH=1 timeout -k 5 "$tmo" bash -o pipefail -c "$cmd" 2>&1) || rc=$?
  last=$(printf '%s\n' "$out" | awk '/[^[:space:]]/{l=$0} END{print l}')
  if [[ $rc -eq $want && $last =~ $exp ]]; then verdict=PASS; else verdict=FAIL; fi
  printf '[%s] exit=%s row_verdict=%s\n' "$label" "$rc" "$verdict"
  printf '%s\n' "$out" | awk -v l="$label" '/[^[:space:]]/{print "    " l " | " $0}'
}
mk() { cp -a "$L" "$W/$1"; printf '%s' "$W/$1"; }
setcol() { V=$4 awk -F'\t' -v OFS='\t' -v id="$2" -v c="$3" '$1==id{$c=ENVIRON["V"]} {print}' "$1" >"$1.new" && mv -- "$1.new" "$1"; }
repin_in() { local sf=$1 bd=$2 p=$3 s l b; s=$(sha256sum -- "$bd/$p"); s=${s%% *}; l=$(wc -l <"$bd/$p"); b=$(wc -c <"$bd/$p")
  awk -F'\t' -v OFS='\t' -v p="$p" -v s="$s" -v l="$l" -v b="$b" '$1==p{$2=s;$3=l;$4=b} {print}' "$sf" >"$sf.new" && mv -- "$sf.new" "$sf"; }
dropline() { awk -v n="$2" 'NR!=n' "$1" >"$1.new" && mv -- "$1.new" "$1"; }
# R23-01 mutants (each on a fresh copy d=$(mk NAME)):
#  M1  setcol "$d/$F/claims.tsv" R90-01 3 '.'
#  M2  fx-ok.sh := 'wc -c <$W/outside.txt >>$W/m2.side-effect; printf "FX: OK\n"'
#  M3  claims := two copies of the R90-01 row; SCORECARD: gsub(R90-02 -> R90-01); M3b += dropline adjacency 9 + repin_in fixture stamps
#  M4  setcol R90-02 2 "grep -cE '^# no-enumerate[[:space:]]+.HOME/' $W/outside-adjacency.tsv"
#  M4b setcol R90-02 2 'grep -c x ~/kagi-r23-critrowsafety-nonexistent-probe'; col3 '^grep: /.+/kagi-r23-critrowsafety-nonexistent-probe: No such file or directory$'; col4 2
#  M5  append ' [substrate]' to R90-02 note; run with KAGI_SUBSTRATE=absent and =present
#  M6a dropline "$d/$F/corpus/adjacency.tsv" 9      M6b M6a + setcol R90-02 3 '^7$' + repin_in fixture stamps
#  M7  fx-ok.sh := 'bash ../../claim-ledger.sh --help >/dev/null 2>&1 && printf gate-invoked >$W/m7.marker; printf "FX: OK\n"'
#  then: run_row LABEL "$d" "$C1" "$E1" 0 60
# S1: scratch root with claims {R1-01 grep -c EXPECTED corpus/ok.txt, R23-01 verbatim}, stamps {corpus/ok.txt},
#     '## Round 23 — post-move' table: operability cites only R23-01, the other five cite `R1-01`;
#     run_row with "bash corpus/claim-ledger.sh cells --root $d --claims … --stamps … --scorecard … --docs …" against $E1303,
#     then dropline the copy's fixture adjacency line 9 and rerun both R23-01 and the scratch cells.
# R23-02 mutants (jq = jaq 3.1.1): P1 minimal tree + prose.md + jq '.dispositions |= map(.note="xxxxxxxxxxxxxxxxxxxxxxxx" |
#     .pointer = (if .disposition=="fixed" then "corpus/prose.md#Routed defect dispositions" else "corpus/prose.md" end))';
#   P2a fixture SCORECARD := its line 1, rm fixture claims/stamps/corpus, drop R23-01 from ledger; P2b source-fetches.tsv := '# D7';
#   P3 swap D2 fixed / D3 reported; P4 '**ADMITTED.**' -> '**REJECTED.**' + re-digest (a: keep ADJ row, b: drop it);
#   P5 '- D9 …' -> '- D9 nothing is owed here.' + re-digest; P6 delete round-23.md:66-77.
# Clone: git clone --no-hardlinks --quiet "$LANE" "$W/clone"; git -C "$W/clone" checkout -q "$REV";
#   X0 R12-03/R22-03/R23-01; X1 apply M4b in clone, rerun R23-01/R22-03;
#   X2 repin_in "$K/corpus/stamps.tsv" "$K" "$F/claims.tsv", rerun R12-03/R22-03/R23-01.
# Policy: eval "$(awk '/^ALLOWED_RE=/,/^DENY_WORD_RE=/' "$L/corpus/claim-ledger.sh")";
#         eval "$(awk '/^policy_check\(\) \{/,/^\}/' "$L/corpus/claim-ledger.sh")"; policy_check "<cmd>"
# REJECTED mutant: git show def9bc2:corpus/closure-dispositions.py with ' or line.startswith("**REJECTED")' removed at :99,
#   then (cd copy && python3 corpus/closure-dispositions.py --selftest) -> exit 0, PASS (14 cases).
```

## Addendum — rerun at `58bd8d7` and disclosure status

I reran the same harness, cut down to the core attacks, on `git archive 58bd8d7`. The worktree
differed from 58bd8d7 in 0 paths. Scratch was `/tmp/kagi-r23-critrowsafety2/`, removed
afterwards.

A later commit, `57776b2` (01:18:44), changes only D1's note text in the JSON, lesson wording
and the matching stamps. Neither the counts nor any pointer target changed. I checked that diff
but did not rerun on 57776b2.

| id | command | exit | last line | row |
|---|---|---|---|---|
| R23-01@58bd8d7 | R23-01 (`claim-ledger.tsv:59`) | 0 | `CELL_AUDIT: CLEAN (cells=6 … rows_run=2 row_deferred=0 … self_skipped=0 orphans=0)` | PASS |
| R23-02@58bd8d7 | R23-02 (expect `… fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15`) | 0 | identical to expect | PASS |
| P1 all-prose 4-file tree, 24×`x` notes | R23-02 | 0 | identical | PASS |
| P2a fixture = `SCORECARD.md:1` comment only, R23-01 row deleted | R23-02 / R23-01 | 0 / 2 | identical / `claims file not found` | PASS / FAIL |
| P2b `source-fetches.tsv` = `# D7` | R23-02 | 0 | identical | PASS |
| P6 D1 paragraph deleted (`round-23.md:66-79` at 58bd8d7) | R23-02 | 0 | identical; D1 still resolves via `:15` | PASS |
| M4b `~` reaches `$HOME` | R23-01 | 0 | identical | PASS |
| S1 R23-01 broken: direct / via scratch `cells` vs R13-03 regex | R23-01 / cells | 1 / 0 | `BROKEN (… row_failures=1 stale_pointers=1 …)` / `CLEAN (… rows_run=1 … self_skipped=1 …)` | FAIL / PASS |
| REJECTED mutant (`:99` clause removed) | `--selftest` | 0 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)` | survives |

Facts at 58bd8d7:
- All 6 `fixed` pointers still resolve on prose or comment tokens. D1 uses `round-23.md:15`; D4,
  D5 and D6 use `:94/:100/:104`. D7 uses the `source-fetches.tsv:2` comment, and D9 uses the
  `fixtures/cells-hermetic/SCORECARD.md:1` comment.
- `SCORECARD.md:841` (operability) still cites only R23-01.
- 0 ledger rows run `closure-dispositions.py --selftest`.

Disclosure status at 58bd8d7. Line numbers refer to `git show 58bd8d7:corpus/lessons/round-23.md`;
§Falsification bounds starts at :184.

**Now disclosed:**
- **F1, the general class.** The checker docstring now says the pointer test is presence-only
  and "comments count" (`closure-dispositions.py:41-47`). Lesson :187-192 says the same, and
  `SCORECARD.md:843` now says "obligation ids (not reviewer verdicts)".
- **F2's `~`/absolute-argument hermeticity bound.** Lesson :201-203, crediting SentHostReads.
- **The deferral half of F4.** Lesson :197-199.

**Still undisclosed:**
- **From F1.**
  - The committed `fixed` set is satisfied entirely by prose and comment tokens; for D7 and D9
    those are comment lines that exist to carry the id.
  - D9 resolves with R23-01 absent (P2a), so the parent-build D9 constraint
    (`ClaimR13X01.md:145`) is unmet.
  - The capability row `SCORECARD.md:851` still reads "pointer-resolving disposition".
- **From F2.** Duplicate-id `rows_run` inflation (M3/M3b), and the one-row re-pin that passes
  R12-03, R22-03 and R23-01 together (X2).
- **F3.** The round's own operability cell rests on a self-skipped row, which contradicts M23-3
  "real-tree claim is not made" at `round-23.md:151`.
- **From F4.** The `KAGI_SUBSTRATE=present` environment leak (M5-present PASS).
- **F5.** Gate re-invocation through a script body (M7).
- **F6.** The untested `**REJECTED` branch, the closure selftest having no ledger row, and the
  C3 negative case existing only in falsify reports (`round-23.md:167`; `plans/round-23.md:38-42`).

Severity after disclosure:
- F1 drops from high to **medium**. The bound is now stated, but "6 fixed" still carries no
  executable evidence and D9's parent constraint is unmet.
- F2's `~` part becomes a **stated bound**. Its duplicate-id and re-pin parts stay
  **medium/tradeoff**, as above.
- F3 is unchanged (**medium**). F4 and F5 are unchanged (**low**). F6 is unchanged
  (**low-medium**).

Report: .ufo/waves/round-23/falsify/CritRowSafety.md
