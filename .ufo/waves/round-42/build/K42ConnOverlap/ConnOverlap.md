# ConnOverlap — sibling overlap scan for kagi round 42 (C1 deletion rule, C2 runner fix)

Seat: K42ConnOverlap (connector, leaf, read-only over siblings). Lane: kagi-shokunin.
BASE e8265c0d90b01fcce0447d2f70615b0592ed145f; plan `plans/round-42.md` read in full; terms are its frozen vocabulary.
Axes touched by the scanned claims: C1 → calibration, C2 → freshness.

## 1. Scope and method

Lanes scanned (20, kagi-shokunin excluded): audio, chousa, game-dev-2d, game-dev-3d, kaidoku, kake,
kama, kasegi, kengaku, kotoba, kotodama, kumitate, lore, mado, mori, revenger, souji, tabi, tameshi,
tsukuroi (all `/home/vgpnk/Projects/shokunin/<lane>`). Out-of-pattern dir `kumitate-shokinin` (typo name,
not `*-shokunin`) was not in scope and was not scanned.

Searches (grep tool, `.git` excluded via `!**/.git/**`; counts are **files with ≥1 matching line**;
"floor" = grep pagination floor, i.e. at least that many):

| # | term | pattern | case | files |
|---|------|---------|------|-------|
| 1 | expect-journal | `expect-journal` (rechecked `expect[-_]journal`, insensitive) | exact | **0** |
| 2 | expectation-migrations | `expectation-migrations` | exact | **1** (2 lines) |
| 3 | claim-ledger.tsv row deletion | `claim-ledger`; `MISSING_ROW\|row_missing`; `REFUSE DELETED\|DELETED R[0-9]`; `row deletion\|deleting rows\|deleted rows\|delete a row\|remove a row\|row removal\|DELETE FROM` | mixed | `claim-ledger`: **633+** (floor); `MISSING_ROW` family: **43**; row-deletion variants: **584** (floor) |
| 4 | `DELETED` | `DELETED` | exact (uppercase) | **622** (floor) |
| 5 | controls.sh with a C2 BASE line | files named `controls.sh` / `*controls*.sh` (glob) × content `c2` (insensitive); text `controls\.sh`; text `c2-base` | mixed | literal-name `controls.sh`: **7**, of which with `c2`: **0**; `*controls*.sh` files: **60+** (glob floor); `c2-base` text: **1560** (floor) |
| 6 | c2-base-19025d9 | `c2-base-19025d9` | exact | **0** |
| 7 | rendered-text-v1 | `rendered-text-v1` | exact | **28** (fully paged: 20 + 8) |
| 8 | journal gate | `journal[ -]gate` | insensitive | **9** (fully enumerated) |

File-name census (glob, hidden, gitignore off): `**/claim-ledger*` → 40 hits, **all kagi-owned** (corpus +
sandboxes); `**/expect-journal*` → 3 hits, **all kagi-owned** (corpus + r41/r42 build copies);
`**/expectation-migrations*` → **all kagi-owned**; `**/*controls*.sh` → 60+ (floor), kagi plans/*-controls.sh
plus sibling runners (kake r90–r92, kumitate r69/r70/r88, mori r89/r90/r93, tabi r65, tameshi r54–58,
kotoba r89, kasegi r46, kotodama r76/77, souji r77).

Method caveats: grep respects gitignore, so untracked/ignored sibling subtrees were not searched;
`.ufo/waves/**` hits appear throughout, so sibling wave trees are tracked and were covered. Mega-sets
(DELETED 622, claim-ledger 633+, row-deletion variants 584, c2-base 1560) were sampled at pages 1–2 and
tails (skip=20 / skip=620 / skip=570 / skip=1545) plus targeted disambiguation greps; they are classified
as clusters, not enumerated line-by-line. Small sets (expectation-migrations, rendered-text-v1, journal
gate, literal controls.sh, MISSING_ROW) were fully paged.

## 2. Headline answers (the two named questions)

**(a) Does any sibling implement a claim-ledger row-deletion refusal? — NO.**
No sibling gate refuses "base-ledger id absent from candidate ledger" (`EXPECT_JOURNAL: REFUSE DELETED <ID>`).
Zero `expect-journal` references, zero `REFUSE DELETED` / `DELETED R<digits>` token matches, and no
sibling-owned claim-ledger file exists (glob: all 40 are kagi's). No sibling distinguishes journaled from
unjournaled deletions; none has a migration-record concept for deletions. Closest family (all adjacent):
- **kasegi r42 J12** (`ExecJ12J13.sh`, concurrent round): refuses ANY tracked `corpus/` path deleted
  relative to a base whose blob is itself digest-pinned fail-closed (`deleted=<n>`, exit 0 iff `deleted=0`) —
  path-level, not ledger rows, no journal classes.
- **lore r96–r98** (`V18-preservation-mutations.md`): frozen-inventory pins catch "fully self-consistent
  deletions" that pass both map and support (`REDUCTION-DETECTED`, `inventory_mismatch`) — the same
  rationale as kagi C1 (a deletion is invisible to both of a gate's candidate-side populations) solved with
  a frozen base-side inventory, not a journal.
- **kotodama r85/r90** (`tools/check-corpus-index.py`): `MISSING_ROW`/`GHOST_ROW` two-sided set difference
  disk↔index — but both sides come from the same candidate tree, no base ledger.
- **kaidoku r30** (`tools/round-30/settle-gate.py`): `MISSING_ROW` = registry member without ledger row
  (token collision with kagi's kept class; expected-row-absent, not deletion-vs-base).
- **kake r47/r56/r60** (`MutationC1Row.md`, `c56_selftally.py` `row_deleted`→`row_missing`, `score_row_missing`):
  count/membership-based row-absence refusals over SKILL.md tables; the r47 report itself bounds the
  predicate as "row *presence*, not row *meaning*".

**(b) Does any sibling implement a receipt re-derivation (from a pinned revision)? — YES; this is fleet
prior art, strongest in kake.**
- **kake r91** — the direct precedent for kagi's C2 candidate rule: `controls/run_controls.sh` measures all
  fixtures in a scratch clone checked out `--detach` at `BASE`/`--revision`; a committed replay receipt
  exists (`controls/replay-tip.txt`, "controls ok 9/9" at revision); and the committed counter
  `c91_defects.py` **refuses** unless the committed runner replays green at the revision it names — closing
  kake's own R90-C, where the runner read the live lane tree (`$LANE/baseclean.out`) and "stopped
  replaying", i.e. **the same defect class as kagi's round-41 C2 receipt** (committed 1, worktree 3).
- **kake r24** `scripts/receipt_replay.py`: replay of round-23 receipt sets against one pinned REV with
  digest-pinned frozen populations ("Maintained receipt replay registry — round 24").
- **kake r51** `ExecCensusMirrorValidate.md` Run E: `git archive 19a99bd corpus | tar -x` used to
  re-derive a pinned revision's registry bytes (and prove an append purely additive: HEAD minus the two
  appended rows reproduces the base blob byte-for-byte).
- **kake r56/r58** c56 counters: run with `--root . --revision <commit>`, "runs the ten documented
  selftests in a clone of the revision" (committed bytes only).
- **kumitate r69/r70**: frozen `c1-controls.sh`/`c2-controls.sh` (donothing/autoorigin/forgecapture modes)
  plus r70 replay tooling over pinned-source fixtures of the frozen runner.
- **souji r18** (`census/round-18/.../ConnFleetPointerTools.txt`): the fleet principle stated outright —
  resolve pointers at `--rev` (`git show <rev>:<path>`), never the worktree; chousa LOG/MINT r73:
  "the corpus landing must re-derive every citation rather than copy one".
- **NOT found anywhere**: kagi's A1 delta — taking the *counter itself* from a pinned predeclaration
  commit (`git show 5142b52:plans/round-41-c2.sh`). kake's r91 counter runs from the caller's tree; no
  sibling pins the counter blob to a predeclaration commit. kagi's C2 candidate rule (counter run inside a
  `git archive` of the pinned BASE, receipt last line == D) also has no exact sibling counterpart; kake's
  mechanism is clone-checkout-based, not archive-based.

## 3. Hit table

Verdicts: **overlap** = implements the term's kagi mechanism; **adjacent** = same problem family, different
mechanism or substrate; **none** = no relation (reference-only, receipt copy, or false positive).

### expect-journal — 0 hits

### expectation-migrations — 1 file

| hit | lane | verdict |
|---|---|---|
| `.ufo/waves/round-58/w2/T58W2ConnSib-receipts/narrow.json:14,127` (embeds kagi row-identity R12-03 context naming `.ufo/waves/round-26/expectation-migrations.json`) | tameshi | none — receipt copy of kagi output; no sibling-owned expectation-migrations file (glob) |

### claim-ledger / row deletion — 0 implementations; family hits

| hit | lane | verdict |
|---|---|---|
| `tools/round-30/settle-gate.py:36,204-206` — `MISSING_ROW` (member w/o ledger row) | kaidoku | adjacent |
| `.ufo/waves/round-30/w1/ExecSettleGate.md:29-33,59-63`; `.ufo/waves/round-31/w1/ExecPrefreezeR31.md:189-190,239-243,453-455,480-482` | kaidoku | adjacent |
| `.ufo/waves/round-85/w1/stage/ExecIndexAuditor/check-corpus-index.py:118-121` — `MISSING_ROW` = disk−counts, `GHOST_ROW` = counts−disk | kotodama | adjacent |
| `.ufo/waves/round-85/w1/ExecIndexAuditor.md:33,42-46`; `.ufo/waves/round-85/w1/MutationTester.md:13` (row-omission mutant killed) | kotodama | adjacent |
| `.ufo/waves/round-90/w1/ExecReadme.md:14-15,144-147` — row↔file bijection classes | kotodama | adjacent |
| `.ufo/waves/round-42/wave1/ExecJ12J13.sh:20-47` — `deleted=<n>` refused vs pinned-digest base (concurrent r42) | kasegi | adjacent |
| `.ufo/waves/round-42/wave1/ConnWave2Seed.txt:129` — FLIP-ROW-DELETED seed, count-based (concurrent r42) | kasegi | adjacent |
| `.ufo/waves/round-46/attempt2/wave1/R46bExecNoharm.draft/noharm.sh:13-17,81-98` (+ `R46bExecNoharm.md:9-13,62-65`, `R46bW2MutNoHarm.md:30-35,45-49`) — DELETED-line budget vs base, PRE-JUSTIFIED/FINDING | kasegi | adjacent |
| `.ufo/waves/round-47/w1/MutationC1Row.md:34-52` — registry-row deletion → `registry_rows 2/2→1/2`, KILLED | kake | adjacent |
| `.ufo/waves/round-56/c56_selftally.py:19,404,440` — `row_deleted` fixture → `row_missing` refusal | kake | adjacent |
| `.ufo/waves/round-56/w2/MutC1V2.md:36` — M21 (row_missing dropped) KILLED by row_deleted | kake | adjacent |
| `.ufo/waves/round-56/w1/CriticControls.md:14` — measured delete-a-row → `row_missing` | kake | adjacent |
| `.ufo/waves/round-60/w1/ExecC1Fixtures.md:60-63,81` (+ `c60_gate_status_fixtures.py:700-703`) — `score_row_missing` refusal class | kake | adjacent |
| `.ufo/waves/round-39/w2a3/MutCriterionO.md:20` — missing-row guard mutant | kake | adjacent |
| `.ufo/waves/round-51/w1/ExecCensusMirrorValidate.md:56-79` — Run B/E: deleting rows 152–153 reproduces base blob; `git archive 19a99bd corpus \| tar -x` re-derivation | kake | adjacent |
| `.ufo/waves/round-52/w2 build_fx.py:117-120` — grader-DELETED forgery fixture (fx04 A5 laundering) | kengaku | adjacent |
| `.ufo/waves/round-50/w3/MutPlan/mutate-v5.py:41` (+ `v5-mut-results.json:72`) — row renamed `no-reader-failure-DELETED`, table_matches reds | kaidoku | adjacent |
| `.ufo/waves/arc3-loop1-round1/claims/c2/EX-24/pin-mutability.md:116-125` — PIN DELETED attack variants | kaidoku | adjacent |
| `.ufo/waves/arc3-loop1-round3/claims/c3/EX-42/battery-landed.txt:12-14` — "README arc3 token DELETED" → CITATION_DRIFT refused | kaidoku | adjacent |
| `.ufo/waves/arc3-loop1-round3/EX-45/evidence/scripts/attack-battery.py:180-183` — `re.sub(must_match,"DELETED")` mutator | kaidoku | adjacent |
| `.ufo/waves/round-45/w2/R45W2CritC1Text/harness/attack2.py:60-66` — "# ARM DELETED" mutation | kaidoku | adjacent |
| `.ufo/waves/round-46/w1/R46W1MutGate/probe/p3b.py:6-9` — claims file DELETED in freeze..rev → pristine exits 2 | kaidoku | adjacent |
| `.ufo/waves/round-98/seats/V18-preservation-mutations.md:84-90,158-161` — row drop / fully self-consistent deletion caught only by frozen inventory pin (`inventory_mismatch`, `REDUCTION-DETECTED`) | lore | adjacent — strongest conceptual cousin of C1's rationale |
| `LOG.md:1004-1006`, `SCORECARD.md:160-169`, `reports/round-79/r79-adjudicator.md:28-30`, `reports/round-80/r80-verifier.md:89-91` — CASES-row-deletion forges killed in batteries | game-dev-2d | adjacent |
| `reports/round-88/r88-verifier.md:202-206` — `kill/` CASES-row-deletion forge | game-dev-3d | adjacent |
| `.ufo/waves/round-31/wave2/CritMistakes.md:93-99` — paragraph-DELETED fixtures for stale-paragraph detector | kasegi | adjacent |
| `.ufo/waves/round-30/build/R30RevCounter.md:221-224` — junk edit "kappa sentence DELETED, not scoped" must be scoped | kengaku | adjacent |
| `.ufo/waves/round-21/frozen/before/corpus/lessons/round-20.md:306-307` (+ ~12 assimilation copies r48–r59) — "history-row deletion" prose | kake | none — documentation |
| `.ufo/waves/round-26/fetched/text/S008-1.txt:1` — tar `--delete` help text | kake | none — false positive |
| `.ufo/waves/round-56/make_spec_w1.py:223-225` (+ `w1-dispatch.json:449-450`, `w1-spec.json:158-159`) — attack prose "deleting rows then adding same-named rows elsewhere" | kake | none — spec prose (mechanism counted at the c56 rows above) |
| remainder of the 584-file row-deletion set (not enumerated) | various | mixed none (lesson copies, help text) — floor noted in §1 |

`MISSING_ROW` exact token (43 files): kaidoku settle-gate + kotodama corpus-index + kumitate
`round-70/build/K70ScribeWaveCensus/validate-reconciliation.mjs:89` (print label, none) + kotodama
`round-64/gen-w2.py:138` (build constant, none). No sibling uses kagi's `DELETED <ID>` form.

### `DELETED` (uppercase) — 622 files (floor); sampled + targeted greps

| hit | lane | verdict |
|---|---|---|
| `.ufo/waves/round-75/w1-results.json:28` — SCRATCH_DELETED | kake | none — housekeeping |
| `.ufo/waves/arc2-loop1-round8/S1.md:102` — runtime root already deleted | kaidoku | none |
| `.ufo/waves/round-32/a2audit/A2NoHarmBaseline.md:60` — 4 DELETED files diff stat | kaidoku | none |
| `.ufo/waves/round-50/r50-w3-results.json:64` — leaked file DELETED, re-verified | kaidoku | none |
| `.ufo/waves/round-50/w1/C1SentinelFetch.md:35` (+ `commands.txt:40`) — trap `rm -rf` hazard demo | kaidoku | none |
| `.ufo/waves/round-55/w1/SC4ProbePrior/pattern.md:352-353` — scratch deletion demo | kengaku | none |
| `.ufo/waves/round-91/w1-results.json:10` — scratch deleted at exit | kengaku | none |
| `.ufo/waves/round-32/w1/ExecNoNetwork/netlog-*.json:1` — `COOKIE_STORE_COOKIE_DELETED` netlog constants | tabi | none — false positive |
| `.ufo/waves/round-34/w2/RerunNoHarm/receipts/numstat-nonzero-deletions.txt:1` — numstat receipt | tabi | none |
| remainder (not enumerated): scratch-deletion receipts, attack labels, `git diff` DELETED lines | various | mixed none / adjacent (attack-label rows captured in §3 row-deletion table) |

Targeted disambiguation: `REFUSE DELETED|DELETED R[0-9]` → **0 hits** — no sibling uses kagi's refusal-token form.

### controls.sh with a C2 BASE line

| hit | lane | verdict |
|---|---|---|
| `.ufo/evidence/round-54/control/, round-55..58/controls.sh` (4 files + 2 stage copies) | tameshi | none — no `c2` content (grep 0) |
| `.ufo/waves/round-77/w1/stage/ExecFreezeChecklist/controls.sh` | kotodama | none — no `c2` content |
| `.ufo/waves/round-91/controls/run_controls.sh:9-25,30-73` — `BASE=5b20af16…`; clone `--shared` + `checkout --detach $BASE`; C2 do-nothing at BASE + 5 forgery subjects + reachability control; receipts committed | kake | **overlap** — C2 controls re-derived at a pinned revision |
| `.ufo/waves/round-91/controls/replay-tip.txt:1-16` — committed replay receipt, `controls ok 9/9` at `f4fff130…` | kake | **overlap** |
| `.ufo/waves/round-91/c91_defects.py:24-37,55-58,218-222` — gate: committed `run_controls.sh` must replay at `--revision` (closes R90-C) | kake | **overlap** |
| `.ufo/waves/round-90/freeze.md:50-54` (+ `w1/ExecReplay.md:43-47`, `w1-dispatch.json:54,140`) — R90-C: runner copied live `$LANE/baseclean.out`, "stopped replaying"; repair pinned inputs to committed blobs | kake | adjacent — kake's own instance of kagi's round-41 C2 defect class |
| `scripts/receipt_replay.py:1-53` (BASE `b5d599e1…` at :52) — replay receipt sets against pinned REV | kake | adjacent — receipt custody at revision, no re-execution |
| `.ufo/waves/round-35/verification/control-c2-base.json:1-5` (+ `.exit`, v2 copies; parent-tree listing `round-36/criteria/r35-0b7779dc-parent-tree-report.md:2429-2457`) | kake | adjacent — sibling C2 BASE control receipts at pinned revisions |
| `.ufo/waves/round-29/c2_matrix_count.py:156-160` (+ `verification/c2-before-…/c2-after-….json`) — counter run at named revisions | kake | adjacent |
| `.ufo/waves/round-56/w1/ExecBaseControls.md:45-46,114-115` — c1/c2 BASE controls at `e48354b7…` | kake | adjacent |
| `.ufo/waves/round-70/build/K70ExecFixtureTests/fixtures/synth-controls/c2-controls.sh:1-50` (+ r69 `probe/c2-controls.sh`, `build/K70ReviewCounterR5/ref-c2-controls.sh`) — frozen C2 controls runner + replay tooling over pinned-source fixtures | kumitate | adjacent |
| `.ufo/waves/round-93/w1/MutationR93/harness.py:312-317,414-417` — `build_c2_tree("c2-base","base")` do-nothing fixtures (concurrent r93) | revenger | adjacent |
| `census/round-58/wave/w1/S58Mutationtester10/*/receipts.txt:728-734`; `corpus/lessons/round-38-verifier-spotcheck.md:63-64`, `round-38.md:35-36,131-132` — `c2-base-composition2.txt` "measured at a revision that contains it"; superseded-label discipline for revision-pinned receipts | souji | adjacent |
| text `c2-base` remainder (1560 files, not enumerated): sibling C2-counter receipt families (kake dominant) | various | adjacent family (no exact kagi receipt name) |

Exact term: no sibling file writes a receipt named like kagi's `c2-base-19025d9.txt`; `c2-base-19025d9` → **0 hits**.

### rendered-text-v1 — 28 files, all references to kagi's own tool; **0 sibling implementations**

| hit | lane | verdict |
|---|---|---|
| `.ufo/waves/round-36/w1/ConnectorSiblingOverlap.md:21,58-63,78` (+ round-48 assimilation copy) — pins deliberate divergence from `rendered-text-v1.py` (sha `7d6bfe8154…`); "closest algorithmic overlap with C1" study | kake | adjacent |
| `.ufo/waves/round-30/build/R30ConnSibling.md:28-29,68-70,81-83,93-95,112-116,124-135` — contrast study; "no change requested to `sources-census.sh` or `rendered-text-v1.py`" | kengaku | adjacent |
| `.ufo/waves/round-30/falsify/R30FxSibling.md:43,61-62,95-96,111-127` (+ `R30FxEvidence.md:123`) — narrower/wider-than analysis; report-out shape owed if a fetch table lands | kengaku | adjacent |
| `.ufo/waves/round-24/w1/OverlapKagi.md:47-49,155-158` — overlap study of kagi projections incl. normalizer selftest counts | tameshi | adjacent |
| `.ufo/waves/round-29/w1/ConnectorOverlap.md:9,39-42` — survivor-kill conventions cite kagi fixture practice | tameshi | adjacent |
| `.ufo/waves/round-31/build/ConnectorSiblings31.md:33` — contrast: kagi accepts normalized reproduction; chousa byte-exact, non-interoperable | chousa | adjacent |
| `.ufo/waves/round-58/w1/R58ConnectorSiblingScope.md:88-91` (+ `w1-results.json:381-383`) — ownership check: `rendered-text` in SKILL/README → kagi only; no chousa consumer | chousa | adjacent — confirms kagi's one-declaration holds |
| `.ufo/waves/round-90/K90Connector/overlap.md:44,103` (+ `hits.psv:23`) — normalizer-family census (U+200B–FEFF strippers across kagi/chousa/kake/kotodama; kasegi gates method precedent) | kumitate | adjacent |
| `census/round-55/wave/w1/S55connector01/receipts/sibling-classification.tsv:12` — classifies kagi `sources-census.sh` OVERLAP via "normalization rendered-text-v1 is declared ONCE" | souji | adjacent |
| `.ufo/waves/round-33/w2/CritAdjacencyHarm/gap-scan.txt:3`; `.ufo/waves/round-62/w1/pinned-contexts.txt:21` (+ `context-0.stdout:79`) — PROVINCE inventory pins | tabi | none |
| `.ufo/waves/round-35/w1/CritC1Counter/bg-blindspots-full.json:1` — receipt dump | tabi | none |
| `.ufo/waves/round-59/w1/ConnectorSiblings.stream.jsonl:11` — transcript quote | kumitate | none |
| `.ufo/waves/round-52/w1/R52ConnSiblings.md:64-66` — inventory ("not format extraction") | chousa | none |
| `.ufo/waves/round-58/w2/T58W2ConnSib-receipts/narrow.json:752` (+ `narrow-20.json:25`) — kagi gate-registry receipt copies | tameshi | none |
| `.ufo/waves/round-50/w1/R50RevScopeSiblings/tip.kagi.md:56`, `R50ScoutLiveTip/kagi-PROVINCE-at-tip.txt:56`, `kagi-PROVINCE.diff:22` — kagi tip snapshots | tsukuroi | none |

### journal gate — 9 files

| hit | lane | verdict |
|---|---|---|
| `.ufo/waves/round-41/w2-results.json:178`; `.ufo/waves/round-41/w2/MutC2V2Gates.md:50-54`; `.ufo/waves/round-41/w2/MutC2V2Gates/matrix.md:95-98` — "journal gates" M17–M21 = mado's own gates over its boot/advert `[LOG]` journals; pin-shadowed, no sole kill | mado | adjacent — same words, different substrate; no expectation-migration concept |
| `.ufo/waves/round-15/build/ScribeNoHarmLedger.md:21` — "Same-census before/after journal gate" in `mori-round14-regressions.py` | mori | adjacent — gate over earlyoom journal state |
| `.ufo/waves/round-30/w2/MutToolFix.md:15` — "active-only outer journal gate" restored in earlyoom tool fix | mori | adjacent |
| `.ufo/waves/round-13/correction/UniversalCritic.md:23` — `systemd-journal-gatewayd` | tsukuroi | none — substring false positive |
| `.ufo/waves/round-29/w2/RevMarkerO10/NEWS-v262:5593ff` — upstream systemd changelog | tsukuroi | none |
| `.ufo/waves/round-36/w1/SrcSystemdNews/NEWS-v262.full` — same content | tsukuroi | none |
| `.ufo/waves/round-42/w1/ConsiderPatchOffset/pkg/systemd.PKGBUILD:215,220` — optdepends lines | tsukuroi | none |

### claim-ledger (string) — 633+ files (floor), all references to kagi's tool; **no sibling-owned ledger**

| hit | lane | verdict |
|---|---|---|
| `LOG.md:53-57` + `.ufo/waves/round-73/w1/R73S01/frozen-LOG.md:53-57` — mis-cited `claim-ledger.sh:45-48`; "the corpus landing must re-derive every citation rather than copy one" | chousa | adjacent — freshness principle stated |
| `MINT.md:127-131` — "Do not inherit a fleet citation gate as the chain walker": ran kagi `claim-ledger.sh citations` read-only, clean with zero recognized cites → rejected for chousa's purpose | chousa | adjacent — tested-and-rejected reuse |
| `.ufo/waves/round-25/build/ConnectorMetaSiblings.md:10` — "partial executable overlap plus an equivalent re-verification declaration" | chousa | adjacent |
| `.ufo/waves/round-18/transcripts/w1/ConnFleetPointerTools.txt:110-119` — fleet pointer-resolution study: kagi `cite_target` is worktree `[ -e ]`; kaidoku probe is "the only checker that uses the git tree at `--rev`"; souji C2 resolves at rev, never worktree | souji | adjacent — the exact principle behind kagi's C2 fix, stated in r18 |
| `.ufo/waves/round-58/w1/ConnSiblingOverlap.md:11,16-18` — cites kagi claim-ledger citation/idref classes as sibling-registry precedent | kake | adjacent |
| `.ufo/waves/round-31/w1/ConnectSiblingOverlap.md:27` — kagi allowlist-residual wording for C1 docs | kake | adjacent |
| `.ufo/waves/round-46/w1/ConnectorSiblingOverlap.md:17,34,39` (+ `residual/ScoutSiblingOverlap.md:55-58`, `round-58/w1-results.json:238`) — kagi `claim-ledger.sh citations` declared out-of-scope for kake's commit-lint | kake | adjacent |
| `.ufo/waves/round-29/w1/ConnectorSiblings.md:33-34,86-87` — E06: kagi ledger craft cited, "do not replace Kaidoku's freeze-disclosure row contract with Kagi's command-ledger schema" | kaidoku | adjacent |
| `.ufo/waves/round-32/a2audit/A2SiblingOverlap.md:28-30` — kagi calibration gate ≠ kaidoku capabilities table | kaidoku | adjacent |
| `.ufo/waves/round-40/w1/R40ConnSibling.md:43-44` (+ artifacts copy) — receipt-replay registry census incl. kagi `claim-ledger.sh verify` | kaidoku | adjacent |
| `.ufo/waves/round-45/w2/R45W2Trends.md:22-23,34` (+ `r45-w2-results.json:153-155`) — kaidoku's own claim-ledger-header rows audit | kaidoku | adjacent |
| `census/round-16/transcripts/w1/SiblingOverlap.txt:126`; `census/round-18/transcripts/w1/ConnFleetPointerTools.txt:86,92`; `census/round-29/waves/w1/deliver-sibling-overlap.tsv:56-60`; `.ufo/waves/round-31/w2/SwarmConnector28.md:25` | souji | none — census transcripts/rows |
| remainder (not enumerated): sibling connector/reviewer reports and receipt copies citing kagi paths | various | none — references only |

## 4. Verdict tally

Enumerated hits in §3 (file-level; copies folded into their primary row):

| verdict | count | mechanisms |
|---|---|---|
| overlap | **3** | 1 mechanism: kake r91 revision-pinned controls replay (runner + committed replay receipt + enforcing counter) |
| adjacent | **54** | deletion/absence detection families (kaidoku, kotodama, kasegi r42/r46, kake r39/r47/r51/r56/r60, lore, gamedev, kengaku, attack batteries); receipt re-derivation family (kake r24/r29/r35/r51/r56/r90, kumitate r69/r70, souji r18/r38/r58, revenger r93, chousa r73); rendered-text-v1 contrast studies (kake, kengaku, tameshi, chousa, kumitate, souji); journal-gate phrase in other substrates (mado, mori) |
| none | **27** | receipt copies, transcript/census rows, tip snapshots, changelog/netlog/argp false positives, housekeeping receipts |

Cluster floors (classified, not enumerated): DELETED remainder ~580 files (predominantly
scratch-deletion/housekeeping receipts and attack labels); row-deletion-variants remainder ~560 files
(predominantly kake r20 lesson copies + help text + attack prose, none); claim-ledger remainder ~600
files (sibling references to kagi, none); `c2-base` remainder ~1500 files (sibling C2-counter receipt
families, adjacent family).

## 5. Proposed move (connector synthesis)

**Move M — record the fleet lineage of both round-42 claims, and route a durable C2 gate form for round 43.**
1. *Freshness (C2), no code change this round:* the lesson/notes should record that kake r90→r91 is fleet
   prior art for the C2 candidate rule — kake hit the identical defect class (committed runner reading the
   live lane tree, R90-C "stopped replaying") and closed it with a **committed counter that refuses unless
   the runner replays at `--revision`**, plus a committed replay receipt. kagi's C2 counter is a one-shot
   frozen predicate; kake's is the durable form. Citing it costs nothing and improves freshness honesty.
2. *Round-43 route (routed, not claimed):* a kake-style permanent gate for kagi — `corpus` or `plans`
   counter asserting "the committed `plans/round-41-controls.sh` replays green at the revision it names"
   (kake `c91_defects.py:24-37` form), which would keep the C2 property alive after round 42 closes.
3. *Calibration (C1), citation only:* kagi C1's rationale ("a deleted row is in neither population of the
   frozen classes") is independently present in lore r96–r98 (frozen-inventory pin catches fully
   self-consistent deletions) and kasegi r42 J12 (deleted-vs-pinned-digest-base refusal, fail-closed wrong
   base). C1 remains fleet-novel in its object (claim ledger + journal classes) — worth one lineage line.

**Axes affected:** freshness and calibration improve (honest lineage + a routed durable gate); no axis harmed.
**Risks:** the lineage lines must land in the lesson/notes, never by editing the frozen plan or counters;
kasegi r42 and revenger r93 were live during this scan (concurrent rounds) — pin any citation to
file+line+observed content and re-verify at integration; kake r91 paths are wave artifacts (mutable across
rounds), so quote bytes, not just paths.
**Second-order:** souji r18 already established "resolve at `--rev`, never the worktree" as a fleet
principle — kagi's C2 fix conforms to it; no contradiction with any sibling. No sibling contradicts C1's
append-only reasoning; chousa MINT's "do not inherit a fleet citation gate" concern does not apply (C1 is
kagi-local, not exported).

## 6. Verification and bounds

- Searches: the eight greps in §1 plus `MISSING_ROW` (exact), `REFUSE DELETED|DELETED R[0-9]`,
  `controls\.sh`, `receipt_replay|re-derivation|rederive`, and glob censuses for `claim-ledger*`,
  `expect-journal*`, `expectation-migrations*`, `*controls*.sh` — all shown with counts above; zeros are
  re-checked (expect-journal also case-insensitively with underscore variant).
- Read for classification: kake r91 `run_controls.sh` (77 lines), `replay-tip.txt`, `c91_defects.py`
  excerpts; kake `scripts/receipt_replay.py:1-53`; kake r47 `MutationC1Row.md` (full); kake r51
  `ExecCensusMirrorValidate.md:39-83`; kasegi r42 `ExecJ12J13.sh:19-63`; kumitate r70 `c2-controls.sh:1-50`.
- Counts marked "floor" are grep pagination floors; everything else was fully paged.
- Bounds honored: siblings touched only via grep/glob/read — no write, no git/jj command, no clone of any
  lane. Writes: this file and its Report-trailer copy
  `.ufo/waves/round-42/build/K42ConnOverlap.md` (identical bytes), both inside the kagi lane's own build
  dir per the seat spec. No scratch dir created (no build work); no tool installs (none needed).
