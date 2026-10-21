# ClaimR17X01 — R17-01 semantic audit (round 23 parent-build, read-only critic)

**Observed revision.** `kagi-shokunin` HEAD `d218603b74099ddca0bd8f869516fc41db0979bf`
(2026-10-20T21:11:59-03:00). The only working-tree entry is untracked `.ufo/waves/round-23/`.
Row: `corpus/claim-ledger.tsv:45`, 6 fields. The awk-extracted row line plus LF hashes to sha256
`ce611105995432897f79ed65dfcd8bd6024d176c09e479eaf908cf4f3746b7eb`, byte-identical to
`.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:45`. These `corpus/stamps.tsv` rows match the
current sha, lines and bytes: `claim-ledger.tsv`, `claim-ledger.sh`, `scope-gate.sh`, `adjacency.tsv`,
`surface-census.tsv`, `knowledge/adjacency-breadth.md`, `knowledge/substrate-deferral.md`,
`lessons/round-17.md` and `SCORECARD.md`.

**Row history.** `bc1af88` (2026-09-29, round 17) created the row. Its only later change is `fecee87`
(2026-10-14, round 18), which appended ` [substrate]` to the note. The expect, exit and timeout fields
are unchanged since creation. `corpus/scope-gate.sh` is byte-identical to `bc1af88` (sha256 `078a2601…`).

**Scope.** No command was executed: no gate, no selftest, no host probe. Host facts below are quoted from
committed receipts with their dates. Tools installed: none.

## 1. What R17-01 actually obligates (causal, not line-count)

Row: `bash corpus/scope-gate.sh --breadth` · last-line ERE `^BREADTH_AUDIT: CLEAN \(required=4 pins=4
checked=4 ok=4 children=182 declared=8 undeclared=174 missing=0 invalid=0 drift=0 exceeds=0 unverified=0\)$`
· exit 0 · timeout 300.

- **Last line.** This is the breadth-only verdict (`scope-gate.sh:609-618`). In `--breadth` mode it is
  printed last (`:662-665`; dispatch `:1125-1130`). It holds only when each of the four leaf roots
  exists, is a real directory, resolves inside HOME, and has live children and live declared counts
  equal to its pin (`:546-602`). The pins are `adjacency.tsv:75-78`: 20/4, 105/2, 4/1 and 53/1.
- **Exit 0.** This is the whole-gate result (`:652-666`). It also requires zero partition defects,
  including the R6 basis lines in sibling lanes, which are resolved through the script-derived
  `LANE_ROOT` (`:91`, `:338-371`; `adjacency.tsv:82` `lane:kake/SKILL.md:161`, `:84`
  `lane:kotoba/…:30`). In its exit dimension, R17-01 therefore includes the R16-01 partition obligation.
- **Not checked by the ledger.** The per-directory lines and `ADJACENCY_BREADTH_SET` are not asserted,
  because the ledger matches only the last non-empty line (`claim-ledger.sh:436-444`). The note says
  "the member-set line pins the four literal dirs", but no executed check tests the 4-dir production
  set. The only set assertion is the hermetic selftest, which substring-matches a **3-dir** fixture set
  (`scope-gate.sh:897-905`). Literal membership is constrained only by three indirect pieces: the
  stamped `adjacency.tsv` (`stamps.tsv:1`), the derivation (`scope-gate.sh:504-525`), and the
  R17-02/R17-03 counts.
- **Which roots depend on the substrate (from census rows):**
  - `$HOME/.local/bin`: `declared=2` means `the-janitor` and `tac-check` (`surface-census.tsv:30-31`).
    This part **does depend** on the substrate. `children=105` is the host's tool inventory.
  - `$HOME/.config/opencode` (integrator/unresolved, `adjacency.tsv:81`): the declared buckets are
    opencode.json, agents, plugin and tools (`surface-census.tsv:26-29`), plus `children=20`. Most of
    this does not depend on the substrate.
  - `$HOME/.agents` 4/1: kotoba's AGENTS.md (`adjacency.tsv:84`, census `:55`). Does not depend on the
    substrate.
  - chrome-profile 53/1: kake-contested, with the kagi NMH (`adjacency.tsv:82-83`, census `:52-54`). Does
    not depend on the substrate.

## 2. Expected verdict / last line / exit / timeout

| item | verdict | evidence |
|---|---|---|
| 2026-09-29 value | **supported (historical)** | main-repo `.ufo/reports/round-17/kagi.md:77-83` (committed `f284c98`); `corpus/lessons/round-17.md:38-45`; `LOG.md:682-683` (exit 0); `knowledge/adjacency-breadth.md:3-7,18-24,147-149` |
| receipt fidelity | **unmarked abridgment** | Both `--breadth` transcripts omit `ADJACENCY_ABSTAIN: rows=1` and `ADJACENCY_SCOPE: CLEAN (…)`. The byte-identical gate prints both in every mode before the set line (`:638`, `:656-661`); the same report's default-mode run at `:72-75` shows `ABSTAIN rows=1`. The final line is unaffected. |
| last-line placement | supported statically | `:603-606`, `:619`, `:656-666`. No test asserts the position. |
| exit 0 | justified, broader than the note ("the coverage number") | A partition-only defect gives `BREADTH_AUDIT: CLEAN …` with exit 1 (bound 6, `adjacency-breadth.md:130-132`). The ledger then prints only `FAIL R17-01 reason=exit-mismatch exit=1 want=0` (`claim-ledger.sh:432-434`), so the cause cannot be told apart from breadth drift. This is a latent false-fail attribution. |
| timeout 300 | justified by margin | The live run took about 2.3 s on 182 entries (`lessons/round-17.md:97-99`). A timeout produces `FAIL reason=timeout` (`claim-ledger.sh:428-431`), so it fails closed. |
| currentness | **refuted as current fact; unresolved as a gate verdict** | Round 18 measured `ADJACENCY_SCOPE: DEFECT (… breadth_drift=6 breadth_unverified=1)`, exit 1 (`lessons/round-18.md:27`). Read-only counts on 2026-10-20 were: opencode 3 (pin 20), `.local/bin` 50 (pin 105), `.agents` 3 (pin 4), chrome-profile absent (pin 53) (`.ufo/waves/round-22/build/Entry02.md:94-96`). That was not a gate run, and nothing was re-observed here. `adjacency-scope.md:315-326` labels the old counts historical. The ledger note (`claim-ledger.tsv:45`) is undated and unlabelled, unlike R18-01's dated note (`:48`). |

## 3. Does `[substrate]` deferral preserve the obligation? No — refuted for this row

- **Predicate.** `-x $HOME/.local/bin/the-janitor` (`claim-ledger.sh:140-146`), applied before the policy
  check and before execution (`:416-418`).
- **Contract.** The tag "declares that its command measures the substrate (the-janitor + its
  state/config tree)", and "deferral cannot launder a real regression" (`substrate-deferral.md:27-30,
  38-39`). Bound 1 calls a deferral "honestly not measurable here" (`:59-61`).
- **Counterexample from committed evidence.** The round-18 verdict that motivated the tag reads
  `breadth_unverified=1` and `breadth_drift=6`.
  - A missing root increments only `unverified` and is skipped before drift is counted
    (`scope-gate.sh:550-552`). Each present root contributes at most 2 drift (children and declared,
    `:588-601`).
  - So exactly one root was missing: chrome-profile, under the absent `the-musketeer`
    (`lessons/round-18.md:18`). The other three, including kotoba's `~/.agents`, were present and
    drifted on both counts.
  - The same lesson says the 11 failures were "every one substrate-caused" (`:28-29`). That is false for
    R17-01.
  - Round 22 shows the pattern again: `.agents` 3≠4 and chrome-profile absent, while the-janitor stayed
    absent (`Entry02.md:91-96`).
- **Effect.** `DEFER R17-01 reason=substrate-absent` parks the whole row. That includes sub-obligations
  that are measurable now and causally independent of the-janitor. Substrate absence alone is enough to
  make the row fail (`.local/bin` declared drops from 2 to at most 1), so deferral never hides a pass. It
  hides the cause and extent of the failure.
- **Return path is understated.** `SCORECARD.md:331-335` says reinstalling the-janitor un-defers the rows
  and "every baseline re-derives". But breadth pins are reviewed data with deliberately no `--pin`
  (`scope-gate.sh:75`). R17-01 would then fail with no cause printed until a reviewed re-measure is done.
  `adjacency-scope.md:325-326` corrects this for that entry. The scorecard debt list (`:341-343`) names
  only opencode 20→3.
- **A historical cell disagrees with its own round's verdict.** `SCORECARD.md:312` (round-18 pre, cites
  R17-01 and R17-02) says "three of the four pinned dirs are absent". That contradicts the same day's
  `breadth_unverified=1`, which means exactly one root was missing. [INFERENCE] The cell likely mixed up
  missing declared children with missing roots.

## 4. SKIP-SELF

- **Not applicable to R17-01 (supported).** SKIP-SELF only skips rows whose command contains
  `claim-ledger.sh` (`claim-ledger.sh:816-820`). R17-01's command does not, and `scope-gate.sh` never
  invokes the ledger (grep found 0 matches). R17-01 is never self-skipped: a citing cell sends it through
  `verify_claims`, where it is either deferred or executed.
- **Counting defect.** `rows_run` counts deferred rows. `C_N` is incremented before the DEFER branch
  (`:415` vs `:416-418`), and `CL_ROWS_RUN=$C_N` (`:828`). So R17-01 is counted in `CELL_AUDIT …
  rows_run=` even though it never runs.
- **Documentation does not cover it.** `knowledge/claim-ledger.md:198-202` says `row_pointed` shows "how
  many scores rest on a re-run command". Its round-22 erratum (`:474-480`) states that deferral is not
  verification, but it does not correct `rows_run` or `row_pointed`.

## 5. Hermetic and synthetic modes

- **`scope-gate.sh --selftest` (R16-02).** Hermetic: it builds a scratch HOME tree (`:816-905`) and
  proves the gate's logic only. Gaps:
  - The fixture declares no `$HOME/.local/bin` leaf (`:859-864`). No hermetic case covers the one root
    that depends on the substrate (removing the-janitor leading to `.local/bin` declared drift).
  - The breadth-mode case checks the 3-dir set and `BREADTH_AUDIT: CLEAN` by substring, not by
    last-line position (`:897-905`).
- **`--falsify` (R16-03).** Not hermetic for breadth. Every mutation runs the full gate with
  `--root "$ROOT"`, which is the real HOME (`:89`, `:683-684`), so each run lists the real roots
  (`:568`).
- **`KAGI_SUBSTRATE=absent`.** The "only hermetic lever" (`substrate-deferral.md:70-73`). It never
  executes R17-01, which satisfies "never run live", but it carries none of the obligation.
- **The C3 plan** runs `cells` at a fixture root through R23-01 (`plans/round-23.md:32-39`). Copying
  R17-01, or any `[substrate]` row, into the fixture claims makes the result host-dependent:
  - Substrate detection reads the real `$HOME` (`claim-ledger.sh:145`), not `--root`.
  - A ledger row cannot set `KAGI_SUBSTRATE` or `HOME`: the first token is allowlisted (`:160`) and `$`
    is refused (`:163`).
  - On this host the row defers, and is still counted in `rows_run`.
  - On a host with the substrate present, the row runs `bash corpus/scope-gate.sh --breadth` from the
    fixture root (`:426-427`). If the fixture lacks the script, it exits 127, a **false fail**. If the
    script is copied in, it enumerates the real HOME (`scope-gate.sh:89`, `:564-583`), which breaks
    C3's "never run live substrate commands".
  - The round-22 harness set `HOME` and `KAGI_SUBSTRATE=absent` from outside
    (`.ufo/waves/round-22/falsify/RunCellsMalformed.md:53`). A ledger row cannot.

## 6. What C3 and C1 integration must retain for R17-01

**C3 (`cells-hermetic` and R23-01).**
1. Keep R17-01's command and tag out of the fixture claims. State that R23-01 discharges no part of
   R17-01.
2. State that R13-03's real-scorecard run stays transitively host-private, because four cells cite
   R17-01: `SCORECARD.md:301`, `:303`, `:312` and `:620`.
3. Keep the fixture free of `[substrate]` rows, and pin `row_deferred=0` in R23-01's exact expected
   line. Otherwise `rows_run` can certify executions that never happened.
4. Keep R13-03's skip reason explicit (`plans/round-23.md:38-39`).

**C1 (closure dispositions).**
1. R17-01 is one of the verifier's 12 skipped IDs (`corpus/lessons/round-22-verifier-spotcheck.md:74-77`;
   `.ufo/waves/round-22/final-verification.json:567-571`). Its disposition is
   `skipped/host-only`, never `fixed` or `verified`. The D9 fix (`:183-184`) does not cover it.
2. Follow each pointer, don't just check that the id resolves. In all four citing cells the R17-01
   pointer resolves but is deferred. The remaining executable support never re-measures breadth:
   - directive counts: R17-02 and R17-03, which only count lines in `adjacency.tsv`;
   - document stamps: `adjacency-breadth.md`.
   - In the `:620` cell, two more stamps come from commands quoted in its text:
     `corpus/SOURCES.md` and `corpus/README.md`. Their current bytes contradict that cell's historical
     "no source registry" statement.
3. Provenance chain to record:
   - last CLEAN execution: 2026-09-29 at `bc1af88`, with abridged transcripts (section 2);
   - deferred since `fecee87`, 2026-10-14;
   - drift outside the substrate per the round-18 verdict and the round-22 read-only counts;
   - not observed in round 23.
4. Do not reuse the expected set line at `.ufo/waves/round-22/build/Entry01.md:93`. It omits
   `$HOME/.local/bin`: it is the 3-dir selftest set, not the live 4-dir set at `lessons/round-17.md:44`.

## 7. The one consumer-visible risk, with a minimal synthetic falsifier (proposal, not executed)

**Risk: clean now, misattributed failure later.** While `the-janitor` is not executable, a breadth
failure caused only by roots belonging to other lanes is reported as `DEFER R17-01
reason=substrate-absent`. The CLEAN `CLAIM_LEDGER`/`CELL_AUDIT` summaries show nothing about it, and
`rows_run` counts R17-01 as run. After the documented fix (reinstall the handler), R17-01 un-defers and
fails `exit-mismatch` with no output, which reads as a regression caused by the restore.

**Fixture for L1.** Scratch only, built in the `claim-ledger.sh` selftest scaffolding (`:1039-1113`):

```bash
printf 'R4-01\tgrep -c EXPECTED corpus/absent.txt\t^1$\t0\t5\tforeign-root stand-in [substrate]\n' >"$R/claims-r4.tsv"
six "$R/sc-defer-only.md" '`R4-01`' '`R4-01`' '`R4-01`' '`R4-01`' '`R4-01`' '`R4-01`'
env KAGI_SUBSTRATE=absent  "$0" cells --root "$R" --claims "$R/claims-r4.tsv" --stamps "$R/stamps.tsv" --scorecard "$R/sc-defer-only.md" --docs "$R/sc-defer-only.md"   # arm A
env KAGI_SUBSTRATE=present "$0" cells …same args…                                                                                                                       # arm P (control)
```

Current output, derived statically from `:415-418`, `:754-781`, `:805-828` and `:1006-1012`:

- **Arm P.** `FAIL R4-01 reason=exit-mismatch exit=2 want=0`, then
  `CELL_AUDIT: BROKEN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=1 row_deferred=0 row_failures=1 stale_pointers=0 self_skipped=0 orphans=0)`,
  exit 1.
- **Arm A.** `DEFER R4-01 reason=substrate-absent`, then
  `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 uncited=0 missing_ids=0 rows_run=1 row_deferred=1 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)`,
  exit 0.

**Assertion that fails today.** Arm A must report `rows_run=0` (no command executed). It must also not
show six cells resting only on deferred rows as row-pointed evidence on a CLEAN line.

**Higher-fidelity variant (R17-01 causality).** The scope-gate selftest tree already contains
`.local/bin/the-janitor` (`:826`). Add one undeclared child under `.agents` (the kotoba analogue). Run
`--breadth` against that synthetic root. The derived result is
`SCOPE BREADTH-CHILDREN-DRIFT $HOME/.agents pinned=1 live=2` and `BREADTH_AUDIT: DEFECT …`, exit 1, with
the substrate **present**. Wrap the same literal-path command as a `[substrate]` row under
`KAGI_SUBSTRATE=absent`, and it reports CLEAN. The failing measurement is the same; only the predicate
changed.

**Smallest safe correction (fixable defects).**
1. **This round, no code.** Apply the C3 items 1–4 and C1 items 1–4 above.
2. **Optional, one line.** Count only executed rows: `CL_ROWS_RUN=$((C_N - C_DEFER))`. R13-03's
   `rows_run=[0-9]+` still matches. Add the arm-A case under QM14.
3. **Append-only errata and migrations.**
   - Date R17-01's note and state that it parks three roots outside the substrate.
   - Add a `substrate-deferral.md` bound for rows that mix substrate and non-substrate dependencies.
   - Correct `lessons/round-18.md:28-29` and `SCORECARD.md:312`.
   - Make the R17-01 unblock action in `SCORECARD.md:331-335` require a reviewed re-measure of all four
     pins.
4. **Optional hermetic test.** Add a `.local/bin` leaf to the scope-gate selftest, with a case that
   removes the-janitor.

**Tradeoffs the judge must reject.**
- Re-pinning R17-01 to post-substrate counts without an authorized live run. That is fabricated
  freshness.
- Importing R17-01 into the C3 fixture.
- Treating the `KAGI_SUBSTRATE=absent` `rows_run` count as executed evidence.
- Untagging R17-01 this round. With no run authorized, its red verdict would rest only on read-only
  counts.

## Limits

- No live, host or gate execution, and no host probe. All post-round-17 host state comes from committed
  receipts: the round-18 lesson and the round-22 `Entry02` read-only counts. Current host state is
  unobserved.
- Derived outputs are static readings of the cited code lines, not runs.
- Owners of R16-01, R16-03, R17-02, R17-03 and R13-03 hold their rows; this report touches them only
  where they consume or constrain R17-01.
