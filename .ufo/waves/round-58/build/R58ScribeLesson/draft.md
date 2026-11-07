# Round 58 — the round-57 routed record defects become a checked population (C1, calibration); an executed OpenBao ACL-policy semantics trial measures allow/deny path mechanics (C2, operability)

source: S118 (https://openbao.org/docs/concepts/policies/); S119 (https://openbao.org/docs/commands/policy/), both OpenBao docs Version 2.7.x, opened this round; routed-defect base `corpus/lessons/round-57-verifier-spotcheck.md` (non-author closure, twelve defects D1–D12).

Axis binding (frozen plan `plans/round-58.md`): C1 → calibration, C2 → operability. BASE
`1b13f5dad921f8901f56d30c428f89614dd74d8a`. Predeclaration commit `0085a5f76c9dc7e977f6606324e873d25b4fc44d`
(`plans/round-58.md` alone, 170 insertions; `git show --stat 0085a5f`).

Shape (wave `kagi-r58-w1`): one v1 wave, **13 seats** — 2 scout, 4 executor, 2 scribe, 1 reviewer,
1 critic, 1 mutation-tester, 1 sentinel, 1 connector; attack 4/13 = 30.8 % (floor ≥25 %), one
connector, no labrat (commands in the D9 row). The frozen plan's §Shape declares 14 seats including
1 labrat; the dispatch carries 13. §Shape is prose, not a predicate: it is recorded here and not
amended, and the protocol floor (8) and the band (8–16) hold either way.

Measurement environment for every number below: a clean `git archive 1b13f5d` extraction for lane-local
files (receipt `.ufo/waves/round-58/build/R58ScribeLesson/base-read.txt`), and the lane worktree for
gates that resolve sibling lanes by fleet root (see M6). Extraction path
`/fast/scratch/hyaku/kagi-r58/R58ScribeLesson/base` (deleted before this seat returned).

## Claims

### C1 — calibration: the round-57 routed record defects are resolved and re-checkable

Frozen predicate (plan text, verbatim):

```
C1_ROUTED: value = the number of UNRESOLVED items over POP = 8 fixed routed-defect
items (I1..I8 below), when GUARD = 1, else FAIL; target 0 (BASE 8).
An item is UNRESOLVED iff its named condition does not hold on the measured tree.
GUARD = 1 iff the checker evaluates all eight items (prints population=8 with
i1..i8 each 0|1, none skipped) and, on a copy of the measured tree whose only
delta is the I4 statement text changed to a wrong count, prints exactly value+1.
```

Target 0. BASE 8 (declared). Commands:

```
python3 -I -B plans/round-58-c1-check.py --root <tree>
bash plans/round-58-c1.sh <revision>          # BASE when omitted; --tree DIR also accepted
```

Target line: `C1_ROUTED: value=V population=8 i1=.. i8=.. guard=G`; exit 0 iff guard=1 and V==0.

**Amendments observed while drafting** (worktree, uncommitted at draft time; `git diff plans/round-58.md`
⇒ +23 lines): **A1** restates I2's condition to five `INSTRUMENT` pins equal to the measured tree's
sha256 and a last `CONTROLS:` line with `N≥13` (reason given: the frozen `plans/round-57-controls.sh`
declares 15 controls over the shipped bytes, so a literal-13 form would leave a correct fix
unresolved); **A2** restates I3's quote test to compare after whitespace-run normalization. The value,
target, POP, guard and kill rules are unchanged, and the predicates quoted above are unchanged. The
item table uses the amended reading of I2 and I3. The A1/A2 reasons were not independently verified
by this seat (that would mean running the freeze battery over a REF tree).

**BASE population census, read independently by this seat** (both counters are absent at BASE:
`ls plans/round-58-c1-check.py plans/round-58-c1.sh` ⇒ absent, so the reading below is a hand read of
each frozen condition, not a counter run; commands in
`.ufo/waves/round-58/build/R58ScribeLesson/base-read.txt`):

| id | condition read at BASE | 0/1 | command that decided it |
|---|---|---|---|
| I1 | no `epoch C` in the round-57 LOG block or the SCORECARD round-57 sections | 0 | `awk 'NR>=1933 && NR<=1945' LOG.md \| grep -c 'epoch C'` ⇒ 0; `sed -n '1861,1905p' SCORECARD.md \| grep -c 'epoch C'` ⇒ 0 |
| I2 | **as amended by A1** (five `INSTRUMENT` pins equal the tree's sha256, last `CONTROLS:` line `match=N mismatch=0`, N≥13): at committed BASE the only receipt pins `b130bb83…` while `plans/round-57.md` is `76e836ee…` | 0 | `sha256sum plans/round-57.md plans/round-57-c1.sh plans/round-57-c2.sh plans/round-57-controls.sh plans/round-57-c1-check.py`; `grep '^INSTRUMENT\|^CONTROLS' .ufo/waves/round-57/controls/controls-prefreeze-epochC*.txt` |
| I3 | `corpus/lessons/round-57.md` contains `S117` zero times; `source:` names S115/S116 | 0 | `grep -c 'S117' corpus/lessons/round-57.md` ⇒ 0; `sed -n '1,4p' corpus/lessons/round-57.md` |
| I4 | the round-57 surface states 116 where the registry measures 117 | 0 | `grep -n 'Registry 114' SCORECARD.md corpus/lessons/round-57.md`; `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` ⇒ 117 |
| I5 | `SKILL.md` names `current-claims` zero times | 0 | `grep -c 'current-claims' SKILL.md` ⇒ 0 |
| I6 | `--round` is rejected (argparse rc 2) and the file carries 12 occurrences of the literal `round-56`; its EPOCHS sentence names `plans/round-56.md` literally, so it names no round-N authority | 0 | `python3 -I -B corpus/current-claims.py --round 57 --root .` ⇒ `error: unrecognized arguments: --round 57`, rc 2; `grep -c 'round-56' corpus/current-claims.py` ⇒ 12 |
| I7 | the lesson's S115 Gate row says `Enabling and disabling audit devices`; the capture body says `Enabling/Disabling audit devices` (2 occurrences) | 0 | `grep -n 'Enabling' corpus/lessons/round-57.md`; `grep -c 'Enabling/Disabling audit devices' .ufo/waves/round-57/capture/S115.body` ⇒ 2 |
| I8 | `stale_basis=1` (in-lane run; the extraction reads 3 — see M6) | 0 | `bash corpus/scope-gate.sh \| grep ADJACENCY_SCOPE` (in the lane) |

⇒ 8 of 8 unheld at BASE, consistent with the plan's declared `value=8 population=8`. The counter must
still print that line itself; this table is the independent cross-read, not a substitute.

### C2 — operability: an executed OpenBao ACL-policy semantics trial

Frozen predicate (plan text, verbatim):

```
C2_POLICY_TRIAL: value = 5 when the trial's real run is HOLDS 5/5 twice, each of
the five falsifier shims flips exactly its designated test (baseline vector HHHHH;
SH1 -> BHHHH, SH2 -> HBHHH, SH3 -> HHBHH, SH4 -> HHHBH, SH5 -> HHHHB), a PATH with
no bao reads SETUP rc2 with no HOLDS, and a PATH wrapper that lies on the
client-side capability introspection flips exactly T5; else 0.
Target 5 (BASE 0: the trial does not exist at BASE).
POP: T1 deny-by-default and exact-path reach; T2 `*` prefix glob only as the last
character; T3 deny precedence over a broader allow; T4 `+` bounded to one path
segment; T5 union of capabilities at one pattern vs highest-priority match across
different patterns.
```

Target 5. BASE 0, measured: `ls corpus/openbao-policy-trial.sh` ⇒
`No such file or directory`, rc 2. Commands:

```
bash plans/round-58-c2.sh <revision>          # BASE when omitted; --tree DIR also accepted
bash corpus/openbao-policy-trial.sh [--work DIR]
```

Target line: `C2_POLICY_TRIAL: value=V tests=5 pass=P shims=K vectors=ok/5 guard=G`; exit 0 iff value=5.

L1 to fill: the candidate readings (`value=`, both real-run vectors, shim vectors, the no-bao and
wrapper legs) are **not** filled here — this seat ran no trial and the instrument does not exist at
draft time. The commands above are the ones that produce them.

## Routed dispositions

Twelve rows, one per r57 routed defect (D7 and D8 both ride item I6). `verdict` is this round's disposition; `BASE` is what a
re-run of the named command on `1b13f5d` prints; `decided by` is the check that can fail. A `gated`
row is carried by a frozen C1 item — it is not fixed until that item reads 1. An `open` row has no
frozen item it can ride as written: it closes only when one receipt satisfies its stated mechanism,
and the L1 owns that fix.

| # | r57 defect | verdict | BASE reading (command) | decided by |
|---|---|---|---|---|
| D1 | epoch record missing from LOG/SCORECARD | `gated` — I1 | `epoch C` count 0 in both (`awk … LOG.md \| grep -c`; `sed -n '1861,1905p' SCORECARD.md \| grep -c`) | `round-58-c1-check.py` i1 |
| D2 | report's landed-changes table reverses the landing/epoch-C order | `fixed` — corrected in this round's report, the r57 report bytes are never rewritten. Correction content, verbatim: the graph is `03cbf656` (epoch B) → `d857f344` (landing) → `8d8e0588` (epoch C); the landing commit carries the epoch-B counter/controls and **no** epoch-C receipt; the hardened instruments are a later commit | `git log --oneline --reverse 03cbf656..8d8e0588` ⇒ `d857f34` then `8d8e058` | L1 to fill: `grep -n '03cbf656.*d857f344.*8d8e0588' /home/vgpnk/Projects/shokunin/.ufo/reports/round-58/kagi.md` (report absent at draft time) |
| D3 | epoch-C receipt pins a plan hash older than the plan it shipped with | `open` — I2. Mechanism, measured: one candidate receipt (`controls-prefreeze-epochC-final.txt`) pins `76e836ee…` = the tree's sha256 of `plans/round-57.md` but carries **no** `CONTROLS:` line; the other (`controls-prefreeze-epochC.txt`) carries `CONTROLS: match=13 mismatch=0` but pins `b130bb83…`; **no single receipt carries both**. I2 closes only when one receipt carries all five `INSTRUMENT` pins *and* its own `CONTROLS:` line — the same class as I4 ("the receipt must name what it measured"). The L1 owns that fix. Amendment **A1** relaxes the item's count to `match=N mismatch=0, N≥13` and the uncommitted worktree `-final` receipt now reads five pins + `match=15`; that is a candidate, not a closure, and the verdict here stays open until the committed tree reads i2=1 | `sha256sum plans/round-57.md plans/round-57-c1.sh plans/round-57-c2.sh plans/round-57-controls.sh plans/round-57-c1-check.py`; `grep '^INSTRUMENT\|^CONTROLS' .ufo/waves/round-57/controls/controls-prefreeze-epochC*.txt` | `round-58-c1-check.py` i2 (absent at draft time) |
| D4 | S117 has no `## Gate` record; `used-by` names a lesson that does not cite it | `gated` — I3 | `grep -c 'S117' corpus/lessons/round-57.md` ⇒ 0; lane census prints `FINDING SC_USEDBY_NOCITE id=S117 path=corpus/lessons/round-57.md` | `round-58-c1-check.py` i3 |
| D5 | registry count stale (116 vs 117) and a count attributed to a receipt the receipt does not carry | `gated` — I4 | `SCORECARD.md:1894` and `corpus/lessons/round-57.md:86` both say `114 → 116`; measured `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` ⇒ 117; `.ufo/waves/round-57/final/gates.txt:20` ⇒ `rows=116`. (A worktree edit to the lesson already carries `114 → 117`; uncommitted at draft time, so not counted) | `round-58-c1-check.py` i4 |
| D6 | the lane's gate has no SKILL.md registry row | `gated` — I5 | `grep -c 'current-claims' SKILL.md` ⇒ 0 | `round-58-c1-check.py` i5 |
| D7 | the gate is round-56-specific: its audited surface is hard-coded, so "checked every round" overstates it | `gated` — I6 | `--round 57` ⇒ argparse rc 2 (`python3 -I -B corpus/current-claims.py --round 57 --root .`); 12 occurrences of the literal `round-56` (`grep -c 'round-56' corpus/current-claims.py`) | `round-58-c1-check.py` i6 |
| D8 | the EPOCHS docstring names an authority the code does not read | `gated` — I6 (the live gate carries the class). At BASE the defect is in the frozen `plans/round-57-c1-check.py`: its docstring says the EPOCHS authority is "the number of `.ufo/waves/round-56/controls/controls-prefreeze-epoch*.txt` files", while `:125` reads `plans/round-56.md` epoch tokens. The frozen bytes are not edited; `corpus/current-claims.py`'s EPOCHS sentence must name the round-N authority its code reads | `sed -n '20,24p' plans/round-57-c1-check.py`; `sed -n '125,131p' plans/round-57-c1-check.py` | `round-58-c1-check.py` i6 |
| D9 | wave shape: the prompt's minimum split vs the wave | `fixed` for this round's shape, with a **plan↔artifact count drift** recorded. Measured: `counts.total=13`, roles `scout 2, executor 4, scribe 2, reviewer 1, critic 1, mutation-tester 1, sentinel 1, connector 1`; attack `4/13 = 30.8 %` (≥25 %), one connector, one batched v1 wave. The frozen plan's §Shape declares **14** seats including 1 labrat; the dispatch has **13** and no labrat | `python3 -c "import json;d=json.load(open('.ufo/waves/round-58/w1-dispatch.json'));print(d['counts'])"` ⇒ `{'spawn': 13, 'resume': 0, 'total': 13}`; `python3 -c "import json,collections;r=json.load(open('.ufo/waves/round-58/w1/swarm-registry.json'));c=collections.Counter(m['role'] for m in r['members'].values());print(dict(c),len(r['members']))"` ⇒ the role counts above, 13 | none reads plan §Shape against the dispatch (see M2) |
| D10 | the lane committed a fleet-scope `.ufo/prompts/` file | `why-not` — `.ufo/prompts/*.md` is inside a lane's writable set and the content is the dispatched prompt, so the file is legitimate; the defect is the **identity**: it was committed by the lane, and the prompt file should be committed by the orchestrator identity, not the lane. The pushed commit is not rewritten (changing an author identity on a pushed commit is worse than the blemish). **The class repeated in r58**: `git show --stat --format='%an <%ae> %s' 22157d84` (fleet repo `/home/vgpnk/Projects/shokunin`) ⇒ `kagi-shokunin <kagi@shokunin.local>` "round-58: kagi dispatch evidence", `.ufo/prompts/kagi-round-58.md`, 939 insertions, one file | same `git show` (read-only) | none (see M4) |
| D11 | red gates at the tip: checkbox substrate absence + one stale basis | `gated` — I8 for the stale basis; the checklist half has **no** lane registration: `grep -rn 'CHECKLIST_RUN: BROKEN' --include='*.md' .` finds only r18/r57 narrative, no registration file. Registered here as still-open, with a proposed criterion (see M5) | `bash corpus/scope-gate.sh \| grep ADJACENCY_SCOPE` ⇒ `stale_basis=1` (BASE 3 in the r57 record, measured `stale_basis=3` in the extraction — M6); `bash corpus/checklist-run.sh` ⇒ `CHECKLIST_RUN: BROKEN (items=16 runnable=9 by_hand=7 failed=7)`, rc 1, first failure `FileNotFoundError … /home/vgpnk/.config/opencode/agents/janitor.md` (host substrate) | `round-58-c1-check.py` i8 (stale basis only) |
| D12 | anchor label drift on the S115 Gate row | `gated` — I7 | lesson says `(§Enabling and disabling audit devices)`; the capture body carries `Enabling/Disabling audit devices` twice | `round-58-c1-check.py` i7 |

**D13 — new, not in the frozen routed set** (so it is claimed by no C1 item; the table above stays
D1–D12):

| # | defect | verdict | measured (command) | decided by / landing condition |
|---|---|---|---|---|
| D13 | the lane's own registry census is red and the r57 battery never ran it | `open` — routed to round 59, not folded into any claim | `bash corpus/sources-census.sh` ⇒ `SOURCES_CENSUS: FAILED (findings=4 rows=117)`, rc 1, with the four findings `FINDING SC_FETCH id=S115 missing-provenance`, `FINDING SC_FETCH id=S116 missing-provenance`, `FINDING SC_FETCH id=S117 missing-provenance`, `FINDING SC_USEDBY_NOCITE id=S117 path=corpus/lessons/round-57.md`; identical at r57 tip `ee1a745` and at BASE `1b13f5d`. `corpus/source-fetches.tsv` holds no row for those ids (`grep -c 'S115\|S116\|S117' corpus/source-fetches.tsv` ⇒ 0). r57 `.ufo/waves/round-57/final/gates.txt` §census-end recorded the **fleet** validator instead (`kagi ok`, `rows=116`, rc 0), which is why the lane's own gate went unread | **This round must not deepen the debt**: if the round lands any `corpus/SOURCES.md` row or any `corpus/knowledge/` entry, the same commit must add that row's `corpus/source-fetches.tsv` provenance line and its `used-by` target; otherwise D13 grows and round 59 inherits two reds instead of one. Checked by re-running `bash corpus/sources-census.sh` on the landing tree (expected `CLEAN`, rc 0, or `FAILED` with no new id) |

## Mistakes

| class · evidence pointer · captured-by · fix |
|---|
| `receipt-rc-from-pipeline` · `.ufo/waves/round-58/controls/scope-gate-base.txt` ends `rc=0` while the same file's last verdict line is `ADJACENCY_SCOPE: DEFECT` and a direct `bash corpus/scope-gate.sh; echo rc=$?` ⇒ `rc=1` (`scope_rc=1` on any defect, `corpus/scope-gate.sh:660`) · captured-by: **none** (this seat's re-run) · fix: capture `$?` on the gate invocation itself, never after a pipe; proposed criterion — every `rc=` line under `.ufo/waves/*/controls/*.txt` must equal the exit code of re-running the command named in the same file. |
| `wave-shape-plan-artifact-drift` · `plans/round-58.md` §Shape declares 14 seats incl. 1 labrat and 4/14 = 29 % attack; `.ufo/waves/round-58/w1-dispatch.json` has `counts.total=13`, no labrat, attack 4/13 = 30.8 % · captured-by: **none** (no gate compares the plan's role table with the dispatch) · fix: proposed criterion — a wave-shape check that reads the plan's declared seat table and the dispatch's `members{}`, and fails on a count or role-set difference. |
| `receipt-split-across-two-files` · a receipt's value is the intersection of **which bytes** and **what happened**, and splitting the two across files lets each look healthy: `controls-prefreeze-epochC-final.txt` carries the right pins (all five equal to the tree's `sha256sum`, `plans/round-57.md` = `76e836ee…`) and **no** `CONTROLS:` line, while `controls-prefreeze-epochC.txt` carries `CONTROLS: match=13 mismatch=0` and pins `b130bb83…` (stale). Neither alone answers "was this measured, on these bytes". The first version of the repair reproduced exactly that split; the worktree `-final` file now carries five pins plus `CONTROLS: match=15 mismatch=0`, which satisfies the mechanism only under amendment A1 (`N≥13`, since the shipped `plans/round-57-controls.sh` declares 15 controls over the shipped bytes) · captured-by: this seat's read of the two files, then A1; the check that can fire is `plans/round-58-c1-check.py` i2 · fix: one receipt per epoch carrying both the pins and its own summary, and the predicate's N read from the battery's own declared control count instead of a transcribed number. |
| `prompt-committed-under-the-wrong-identity` · the fleet repo's `.ufo/prompts/kagi-round-58.md` was committed by `kagi-shokunin <kagi@shokunin.local>` at `22157d84` (`git show --stat --format='%an <%ae>' 22157d84` ⇒ 939 insertions, one file) — the same class as r57 D10, one round later. The path is inside a lane's writable set and the content is the dispatched prompt, so the file is legitimate; the identity is not · captured-by: **none** in the lane (this seat's read-only `git show` in the fleet repo) · fix: the prompt file is committed by the **orchestrator** identity, not the lane; an already-pushed commit is not rewritten. Proposed criterion — a fleet-repo pre-receive check that rejects a commit touching `.ufo/prompts/*.md` whose author is a lane identity. |
| `gate-battery-ran-the-wrong-instrument` · r57 `.ufo/waves/round-57/final/gates.txt` §census-end records `kagi ok` + `rows=116` from the fleet validator, while the lane's own census is red at the same revision: `SOURCES_CENSUS: FAILED (findings=4 rows=117)`, rc 1 · captured-by: **none** at r57 (this seat's re-run at `ee1a745` and at `1b13f5d`: identical 4 findings, rc 1) · fix: the pre-freeze battery must enumerate the lane's own gates by discovery, not by memory; proposed criterion — the battery's gate list is diffed against the gate entry points the lane ships. |
| `extraction-breaks-fleet-root-resolution` · `bash corpus/scope-gate.sh` inside a `git archive` extraction reads `stale_basis=3`; the same bytes in the lane read `stale_basis=1`. The two extra rows are `SCOPE NOT-A-FILE … basis=lane:kake/SKILL.md:161` and `… basis=lane:kotoba/…:30`, resolved against the extraction's parent directory · captured-by: **none** (this seat's two-run diff) · fix: measure fleet-rooted gates in the lane or pass the fleet root explicitly; proposed criterion — a gate that resolves sibling lanes prints the resolved fleet root, and a `lane:` basis that does not resolve is reported as SETUP, not as a stale basis. |

## Sources & frontier

Numbers below are commands, not prose. `before` is measured at BASE `1b13f5d`; `after` is the L1's to
fill at the landing revision.

**Census before** (BASE `1b13f5d`):

```
bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi  ⇒ `kagi ok`, rc 0
grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md              ⇒ 117
awk -F'|' '/^\|[[:space:]]*S[0-9][0-9][0-9]+[[:space:]]*\|/ {gsub(/[[:space:]]/,"",$5); c[$5]++} END {for (t in c) print t, c[t]}' corpus/SOURCES.md
                                                                                  ⇒ A 113, B 2, C 2
bash corpus/sources-census.sh                                                     ⇒ FAILED (findings=4 rows=117), rc 1
```

**Census after** (L1 to fill at the landing revision, same three commands): rows `______`, tiers
`A __ B __ C __`, lane-census verdict `______` (rc `__`). The frozen plan opens S118/S119, so the
expected delta is +2 rows; the admission tier is the scout's, not this seat's, and is filled from the
landing census line, not from this sentence.

**Rows added by tier** (L1 to fill from the after-census):

| tier | rows added | ids |
|---|---|---|
| A | `__` | `S118, S119` (L1 confirm) |
| B | `__` | |
| C | `__` | |

**Rows touched old → new** (L1 to fill; a row whose cells did not change is not listed):

| id | old | new | why |
|---|---|---|---|
| `S___` | `status=__` | `status=__` | |
| (provenance) | `corpus/source-fetches.tsv` has no S115–S117 row | rows added | closes the three `SC_FETCH missing-provenance` findings (D13) |

**Frontier.** S118/S119 are the two pages that ground C2's five mechanics (deny-by-default, `*`
suffix-only glob, deny precedence, `+` segment bound, same-pattern union vs cross-pattern
highest-priority match). The `corpus/knowledge/` frontier this round tests is the OpenBao
**authorization** mechanic: the lane holds executed token/lease (r49), wrapping (r51), KV v2 versions
(r52) and audit devices (r57) trials, but ACL-path semantics were documented only. Whether the entry
lands and the capability row enters `SCORECARD.md` §Capabilities is the L1's integration decision;
this seat wrote no corpus file.

## Limits (what this draft could not verify)

- Both counters (`plans/round-58-c1-check.py`, `plans/round-58-c1.sh`, `plans/round-58-c2.sh`) and the
  trial (`corpus/openbao-policy-trial.sh`) are **absent** at draft time; every C1 number above is a
  hand read of the frozen condition, and no C1/C2 receipt exists.
- `plans/round-58-controls.sh` and its battery receipt are absent; no `CONTROLS: match=N mismatch=0`
  line exists for this round, so no instrument hash is pinned anywhere yet.
- This round's report `/home/vgpnk/Projects/shokunin/.ufo/reports/round-58/kagi.md` is absent, so D2's
  correction sentence has no carrier yet; the content is in the D2 row above for the L1 to place.
- The worktree changed under this seat while it read (siblings editing `corpus/lessons/round-57.md`
  and `SCORECARD.md`, and amendments A1/A2 landing in `plans/round-58.md`); every "BASE" claim in
  this draft comes from the cached extraction, and every "worktree" mention is marked as uncommitted.
  D3 and M3 were rewritten after A1 landed; the C1 item table reads I2 and I3 as amended.
- `SCORECARD.md` axis scores, capability rows, `LOG.md`, `MANIFEST.json` and `corpus/lessons/round-58.md`
  were not written, by assignment.
