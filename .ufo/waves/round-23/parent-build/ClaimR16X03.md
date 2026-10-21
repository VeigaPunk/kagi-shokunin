# ClaimR16X03 — R16-03 `scope-gate.sh --falsify` (semantic audit)

Seat: ClaimR16X03 (leaf, read-only). Base/HEAD read: `d218603b74099ddca0bd8f869516fc41db0979bf`
("round-22 verifier spot-check (integrator, hyaku): non-author admit/reject"). Tracked worktree
clean; only untracked `.ufo/waves/round-23/` present. Row owner: this seat; no judgment/admission
authority. No gate, handler, `op`, vault or host command was executed; no installs were needed
(so no tool/version record is owed). Everything below is a read of committed bytes plus
`git rev-parse`/`sha256sum`/`wc` measurements. "Derived" means inferred statically from source or
committed measurements, not executed.

## 1. The obligation as frozen

`corpus/claim-ledger.tsv:41` (byte-identical to `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:41`
and to `git show HEAD:corpus/claim-ledger.tsv`, line sha256 `8ae657be…6ff4f`):

| field | value |
|---|---|
| id | `R16-03` |
| command | `bash corpus/scope-gate.sh --falsify` |
| expect | `^SCOPE_FALSIFY: PASS \(caught=18/18 failed=0\)$` |
| exit | `0` |
| timeout | `300` |
| note | "…9 partition mutations plus 9 breadth mutations… two breadth mutations measure live host counts, so absent substrate it partially runs — deferred instead `[substrate]`" |

Consumer path: `corpus/claim-ledger.sh:411-444` — `cd "$ROOT"`, `timeout -k 5 300`
(`:427`), stdout+stderr captured, blanks dropped, **last** non-empty line matched against
`expect` (`:436-441`), exit must equal `want` (`:431-434`); 124/137 is a FAIL (`:429-431`).
Policy permits it: first token `bash`, no metacharacters, no denied verb
(`corpus/claim-ledger.sh:161-173`). Row population: 43 command rows, 11 carrying `[substrate]`.

## 2. Is the expectation justified? — supported as a code property; host reproducibility is separate

| element | evidence (current bytes) | verdict |
|---|---|---|
| `caught=18/18` | `total=18` literal at `corpus/scope-gate.sh:677`; 18 distinct case invocations: 17 `mutate_case` calls (`:705,710,714,719,726,734,742,749,771,775,779,783,787,791,794,798,802`) plus the manual `basis-escape-on-resolved-lane-root` branch (`:751-768`). `caught` increments only on `rc==want && output contains token` (`:686-689`) | **supported (causal, both directions)** |
| PASS cannot be vacuous | PASS requires `caught==total && failed==0` (`:804-806`); deleting a case without lowering `total` yields `caught{t,}<18` → FAIL; adding one yields `caught>18` → FAIL, and the ledger `expect` pins the literal count, so silent case removal is consumer-visible | supported |
| exact last line | PASS prints exactly `SCOPE_FALSIFY: PASS (caught=%s/%s failed=0)` (`:805`); the only later action is `return 0` plus the EXIT trap `rm -rf` (`:675`), which prints nothing | supported |
| `^…$` anchor | FAIL branch is `SCOPE_FALSIFY: FAIL (caught=%s/%s failed=%s)` (`:808`) — cannot match the PASS ERE | supported (no cross-branch acceptance) |
| `exit 0` | `falsify` returns 0 on PASS (`:806`), 1 on FAIL (`:809`); a failing internal command under `set -euo pipefail` aborts without the PASS line → ledger FAIL | supported |
| mutation targets still exist | shipped literals the `sed` mutations key on are present: `corpus/adjacency.tsv:75-78` (`children=20 declared=4`, `children=105 declared=2`, `children=4 declared=1`, `children=53 declared=1`), `:81` (`kake contested presence-only`), `:80` (`lane:kake/SKILL.md:161`); scan mutation target `# scan $HOME/.config/opencode` derivable from `surface-census.tsv:19` | supported (no silent no-op sed) |
| `timeout 300` | 18 full partition+breadth gate runs per invocation, each with 4 `find -maxdepth 1` over pinned dirs plus 35-row census and 4 basis resolves. **No committed timing receipt exists** for `--falsify`; `.ufo/waves/round-22/final-verification.json` lists R16-03 under `skipped_rows`. 300 s is ample by inspection but unmeasured | **unverified (headroom plausible)** |

Causality of the count, not the authored line count: the PASS branch is reachable only when every
one of the 18 dynamic increments happened and no failure branch fired; the constant is bound to
the case set from *both* sides, and the ledger row binds the constant.

### 2.1 Host-count dependence is four cases, not two

`[substrate]` deferral is justified (the command reads live `$HOME`), but the note undercounts the
coupling. The breadth rules compare live `find` output to pins (`corpus/scope-gate.sh:519-601`).
Cases whose *firing condition* needs the live host to still match shipped pins:

1. `breadth-children-drift` (`:773-775`): pin `105→104`; fires iff live `.local/bin` children `≠104`.
2. `breadth-exceeds` (`:777-779`): pin `declared 4→3`; fires iff live declared `≥4`.
3. `breadth-declared-drift` (`:781-783`): pin `declared 4→5`; fires iff live declared `<5`
   (with 2, these jointly force **live declared == 4**).
4. `breadth-new-declared-child` (`:800-802`): appends `$HOME/.config/opencode/command/breadth-probe.md`
   to the census; fires `BREADTH-EXCEEDS` only if live declared rises above 4 — i.e. requires a
   direct child `command` to exist under `opencode`, or a baseline already >4.

The other five breadth mutations (`missing`, `aggregate`, `noenum`, `extra-field`, `whole-home`;
`:771,787,791,794,798`) fire on data/schema alone (tokens `BREADTH-MISSING`, `BREADTH-SCOPE`,
`BREADTH-NOENUM`, `BAD-ROW`, `is the whole HOME root` — `:485,522-542,791-798`); root absence can
add `HOST-MISSING` but the expected token still appears, so they are not count-bound.

Derivation on the latest committed host measurement: `.ufo/waves/round-22/build/Entry02.md:99-103`
records `~/.config/opencode` 3 children (pin 20), `~/.local/bin` 50 (pin 105), `~/.agents` 3
(pin 4), musketeer profile **absent** (pin 53). With at most 3 `opencode` children, live declared
`≤3`, so cases 2 and 4 cannot fire. **Derived (not executed): the row cannot PASS on that host;
`caught ≤ 16/18`.** This is consistent with the deferral but sharper than "partially runs".

## 3. Historical vs current evidence

- **Implementation frozen since round 17.** `git log -- corpus/scope-gate.sh` ends at `bc1af88`;
  current blob sha256 `078a2601…f8082`, 1129 lines, 55002 bytes — identical to `corpus/stamps.tsv:59`.
  Data frozen at the same commit; `corpus/adjacency.tsv` (`4d9bfb11…`) and `surface-census.tsv`
  (`4af0dbcc…`) match `stamps.tsv:1,64`. No stale-byte issue for this row's dependencies.
- **Last recorded execution is round 17, not a receipt.** `LOG.md:685-686` and
  `corpus/lessons/round-17.md:50-51` assert `SCOPE_FALSIFY: PASS (caught=18/18 failed=0)`, and the
  expectation was migrated there from `caught=9/9` at `bc1af88` (`.ufo/waves/round-22/build/Entry01.md:85`).
  These are authored observations, not captured stdout. Round 22 explicitly did **not** run it
  (`final-verification.json` `skipped_rows` R16-03; `Entry01.md:97` "operator-only").
- **Current documentation marks itself historical.** `corpus/knowledge/adjacency-scope.md:16-19,
  155, 257, 298-299` repeat the 18/18 line; the erratum at `:313-325` (round 22) says the CLEAN
  output and counts describe the 2026-09-29 host and "substrate deferral is not a new pass".
  `adjacency-breadth.md:155` repeats the line as evidence.
- **Doc/command mapping is inaccurate (freshness defect, does not affect the row line).**
  `adjacency-scope.md:267-274` says "`--falsify` runs 18 mutations against the shipped data+census"
  and lists item 2 `ORPHAN` and item 3 `UNKNOWN-OWNER`; neither token exists in the falsify body
  (grep over `scope-gate.sh:669-810` is empty). They are `--selftest` cases at `:965` and `:968`.
  A reader can therefore believe this row proves defect classes it does not.

## 4. `[substrate]`, SKIP-SELF, hermetic mode — what each preserves

- **Deferral is justified but leans on a proxy.** The tag contract defines `[substrate]` as "its
  command measures the substrate (`the-janitor` + its state/config tree)"
  (`corpus/knowledge/substrate-deferral.md:30-33`), and detection is presence+exec of **one file**
  (`corpus/claim-ledger.sh:140-147`; bound stated at `substrate-deferral.md:62-65`). R16-03 measures
  four roots, of which only `~/.local/bin` is janitor-adjacent: `~/.config/opencode` is
  integrator/unresolved, `~/.agents` is kotoba's, the musketeer profile is kake-contested
  (`corpus/adjacency.tsv:80-83`). The tag is right on today's host only because both the handler
  and the other roots are absent together.
  Consequence for the only named unblock: `SCORECARD.md:331-334` (round-18 carried debt) says
  reinstalling the handler "un-defers all rows … and every baseline re-derives". For R16-03 that is
  false: restoring `~/.local/bin/the-janitor` flips `substrate_present()`, the row runs, and the
  measured drift in `Entry02.md:99-103` guarantees `breadth-exceeds`/`new-declared-child` failure.
  A DEFER becomes a FAIL, i.e. a code-regression-shaped verdict for a host-state cause — exactly the
  confusion the deferral mechanism exists to remove (`substrate-deferral.md:20-24`).
- **SKIP-SELF does not apply.** The test is `TF[1] == *claim-ledger.sh*` (`corpus/claim-ledger.sh:817-821`);
  R16-03 names `scope-gate.sh`, so a cell citing it **is** re-run. `SCORECARD.md:302` (Round 17
  post-move, operability) cites `R16-03`. On a provisioned host each production `cells` run
  therefore spawns 18 nested gate runs under `R13-03`'s 300 s budget (`:1011` keeps
  `row_deferred`). On this host `R13-03` is itself `[substrate]`-tagged, so the entire cells audit
  defers — the operative reason C3 needs a fixture path at all.
- **Hermetic synthetic mode is constructible with no source change.** `falsify` forwards the
  overridable globals `"$DATA"`, `"$CENSUS"`, `"$ROOT"`, `"$BASIS_ROOT"`, `"$LANE_ROOT"` to every
  mutated run (`scope-gate.sh:683-684`), and `expand()` rewrites `$HOME`→`ROOT` for census, own,
  no-enumerate and breadth paths. So `--falsify --data … --census … --root … --basis-root …
  --lane-root …` measures a synthetic tree. The obligation can be executed hermetically; it does
  not have to be deferred forever.

## 5. Consumer-visible risk and minimal synthetic falsifier

**Risk (false-fail direction, concrete):** the substrate predicate is one binary, while R16-03's
pass condition is four live directory counts. Restoring the handler alone turns a declared
`DEFER` into `FAIL R16-03 reason=exit-mismatch exit=1 want=0`, and — because the row is cited by
`SCORECARD.md:302` — turns `CELL_AUDIT` BROKEN with `row_failures=1` on a host where nothing in
`scope-gate.sh` regressed. The mirror direction is also real: with the four roots at their pins but
no handler, the row is never executed and the summary still reads
`CLAIM_LEDGER: CLEAN (… deferred=1 …)` / `CELL_AUDIT: CLEAN (… row_deferred=1 …)`.

**Proposed falsifier F1 (not executed here):** a tmp HOME containing **only**
`.local/bin/the-janitor` (mode 0755; nothing under `.config/opencode`, `.agents`, or the profile
root), a one-row claims file holding R16-03 verbatim, and `KAGI_SUBSTRATE` unset:

```
env HOME="$tmp/home" bash corpus/claim-ledger.sh verify --root . \
  --claims "$tmp/one.tsv" --stamps "$tmp/stamps.tsv"
```

Expected from current code: no `DEFER`; `FAIL R16-03 reason=exit-mismatch exit=1 want=0`
(`--falsify` returns 1 because at least the three declared-count cases fail), summary
`CLAIM_LEDGER: FAIL (claims=1 failed=1 deferred=0 …)`. This is a *failing* fixture: it falsifies
the "handler presence ⇒ row measurable" assumption and the `SCORECARD.md:331-334` unblock reading
for this row. Variant F2 (four roots at pins, no handler) yields `DEFER R16-03
reason=substrate-absent` with `deferred=1` — the false-skip half.

## 6. Concrete C3 fixture proposal (hermetic, count-pinned)

Pass fixture: fixture HOME with `.local/bin/{the-janitor,tac-check}` (2 children; declared 2),
`.config/opencode/{opencode.json,agents,tools,plugin,command}` (5 children; 4 census-matched at
baseline ⇒ live declared 4), `.agents/AGENTS.md`; profile root may be absent (`HOST-MISSING` is
exit-affecting but not token-relevant). Fixture copies of `adjacency.tsv`/`surface-census.tsv`
(unmodified pins, so the `sed` literals match) and fixture basis/lane files satisfying the four
group citations (`SCORECARD.md:54`+`opencode`; `lane:kake/SKILL.md:161`+`musketeer`;
`corpus/lessons/round-8-aggregator-box3-coldrun.md:64`+`NativeMessagingHosts`;
`lane:kotoba/…alwayson-checklist-round7.md:30`+`AGENTS\.md`). Command:

```
bash corpus/scope-gate.sh --falsify --root "$fx/home" --data "$fx/adjacency.tsv" \
  --census "$fx/census.tsv" --basis-root "$fx/basis" --lane-root "$fx/lanes"
```

Expected: `SCOPE_FALSIFY: PASS (caught=18/18 failed=0)`, exit 0 — same verdict, no host read.

**Minimal failing variant (the L1 mutation case):** delete `command` from the fixture host (one
`rmdir`). `breadth-new-declared-child` then has no direct child for the appended census row;
live declared stays 4 == pin 4, so no `BREADTH-EXCEEDS` is printed (the run still exits 1 via
`BREADTH-CHILDREN-DRIFT`, but the token is absent). Expected:
`FALSIFY FAIL breadth-new-declared-child (exit 1 want 1, token SCOPE BREADTH-EXCEEDS)` and
`SCOPE_FALSIFY: FAIL (caught=17/18 failed=1)`, exit 1. That single missing directory is the whole
difference between a green and a red obligation — the exact boundary a hermetic proof must pin.

## 7. What C3 cells and C1 closure-disposition integration must retain

1. **Population and pin unchanged.** R16-03 stays among the 43 rows with its current ERE/exit/timeout;
   no re-pin and no retag-to-green. Its production run remains host-scoped.
2. **Hermetic fixtures must not contain the production command.** A fixture claims file that copies
   `bash corpus/scope-gate.sh --falsify` reintroduces live `$HOME` reads and violates C3's
   "never run live substrate commands". Use a fixture-local id/synthetic command, or omit the row
   and carry an explicit deferred disposition. A fixture scorecard cell must not cite production
   R16-03 (it would be re-run by `cells_evidence`).
3. **`R23-01` cannot be re-executed by `cells`.** Its command names `claim-ledger.sh`, so
   `SKIP-SELF` (`claim-ledger.sh:817-821`) excludes it; C3's evidence is the safe-row `verify` run
   plus the fixture mutation case, not a cell. Do not report `self_skipped` as coverage.
4. **Deferral stays visible.** `CELL_AUDIT: CLEAN` keeps `row_deferred` (`claim-ledger.sh:1011`)
   and each deferral prints `DEFER <id> reason=substrate-absent` (`:417`). R13-03's ERE accepts
   `row_deferred=[0-9]+`, so deferral-count drift is **not** pinned by any row — C1's pointer
   discipline, not count assurance, is the only guard.
5. **C1 scope.** R16-03 is not among the 15 obligations (nine `^- D[0-9]`, five discernment
   decisions, adjudication: `plans/round-23.md:9-16`; `corpus/lessons/round-22-verifier-spotcheck.md:165-184`).
   It appears only in the skip-list parenthetical at `:74`; a checker anchored on `^- D[0-9]`
   must not promote that prose into an obligation. D9 (`:183-184`) is discharged by the fixture +
   `R23-01`; its disposition must not read as "cells is host-free in production" — the production
   audit still defers on this host because `R13-03` is `[substrate]`.
6. **Obligation source is unpinned.** `corpus/lessons/round-22-verifier-spotcheck.md` has no
   `corpus/stamps.tsv` row (only `round-22.md` at `:47`). If C1 binds dispositions to it, bind the
   bytes; otherwise the skip list (and R16-03's mention) can change with no drift verdict.
7. **No new "fixed" disposition for the debt.** SCORECARD.md:329-334 and the 11 `DEFER` rows remain
   the record; a fixture-side pass is not a substrate-return event.

## 8. Limits

- No execution: the PASS line, the `17/18` derivation, and the F1 output are static predictions
  from source; L1 must confirm them on the fixture.
- Host counts are the committed 2026-10-20 measurement (`Entry02.md:99-103`); they may have changed
  by 2026-10-21, and this audit did not measure the host.
- `timeout 300` headroom is unmeasured (no committed timing receipt).
- One doc defect is reported (falsify/selftest coverage conflation at `adjacency-scope.md:267-274`);
  it is a documentation issue, not a row failure.

## 9. Worktree note (observed during the audit, 2026-10-21T00:53)

The lane worktree moved while this audit ran: L1's in-flight round-23 edits now show
`M corpus/claim-ledger.sh`, `M corpus/claim-ledger.tsv`, `?? corpus/closure-dispositions.py`,
`?? corpus/fixtures/`. All line numbers in this report are HEAD/base (`d218603`) numbers.
R16-03 itself is unchanged: the row's sha256 is `8ae657be…6ff4f` in both
`git show HEAD:corpus/claim-ledger.tsv` and the worktree file (no `R16-03` line in
`git diff -- corpus/claim-ledger.tsv`), and `corpus/scope-gate.sh` is unmodified. The in-flight
`corpus/fixtures/cells-hermetic/claims.tsv` holds only `R90-01` (local script) and `R90-02`
(local `grep` count); it contains no `scope-gate.sh --falsify` row or synthetic equivalent, so
C3's fixture as observed does **not** execute R16-03's mutation set. That is the gap §6 closes;
it is recorded here as an observation, not an audit of another owner's unfinished work.
