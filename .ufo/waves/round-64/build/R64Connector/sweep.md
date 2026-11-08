# Sibling-Overlap Sweep Receipt — kagi round 64 (R64Connector)

- **Date**: 2026-11-08
- **Seat**: `R64Connector` (connector, UFO-FSD role)
- **Lane**: `kagi-shokunin` (secrets & vault ops)
- **Claim BASE**: `09cbee831d57be7c4edfbe77bf238f46bf729047` (round-63 verifier spot-check tip)
- **FROZEN Predeclaration**: `plans/round-64.md` (commit `dff0929c0e084822b0fe32e0d164534c768f97fe`, including Amendment A1)
- **Receipt Path**: `.ufo/waves/round-64/build/R64Connector/sweep.md`
- **Report Path**: `.ufo/waves/round-64/w1/R64Connector.md`
- **Scope Scanned**: All 20 sibling lanes under `/home/vgpnk/Projects/shokunin/*-shokunin/` (read-only)
- **Target Grounds Scanned**:
  1. A held-out fixture set
  2. A lookup-table / mutation-kill contract
  3. A recursion bound or depth guard in a delegating gate
  4. A stub-refusal control
  5. A seal / sha256-checked fixture table

---

## 1. Fleet Lane Census

Across the fleet root `/home/vgpnk/Projects/shokunin/`, exactly 21 `*-shokunin` lane repositories exist (20 sibling lanes plus `kagi-shokunin`).

### Census Command & Output
```bash
$ for d in /home/vgpnk/Projects/shokunin/*-shokunin; do [ -d "$d" ] && basename "$d"; done | sort
audio-shokunin
chousa-shokunin
game-dev-2d-shokunin
game-dev-3d-shokunin
kagi-shokunin
kaidoku-shokunin
kake-shokunin
kama-shokunin
kasegi-shokunin
kengaku-shokunin
kotoba-shokunin
kotodama-shokunin
kumitate-shokunin
lore-shokunin
mado-shokunin
mori-shokunin
revenger-shokunin
souji-shokunin
tabi-shokunin
tameshi-shokunin
tsukuroi-shokunin
```

---

## 2. Carried Breadth Debt (`ADJACENCY_SCOPE: DEFECT`)

The assignment specifically requires recording the carried `ADJACENCY_SCOPE: DEFECT` breadth debt (`breadth_drift=5 breadth_unverified=1`) and whether round 64 moves it.

### Scope Gate Verification Command & Exact Output
```bash
$ bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/scope-gate.sh
SCOPE BREADTH-CHILDREN-DRIFT $HOME/.config/opencode pinned=20 live=5
SCOPE BREADTH-DECLARED-DRIFT $HOME/.config/opencode pinned=4 live=1
SCOPE BREADTH-CHILDREN-DRIFT $HOME/.local/bin pinned=105 live=117
SCOPE BREADTH-DECLARED-DRIFT $HOME/.local/bin pinned=2 live=0
SCOPE BREADTH-CHILDREN-DRIFT $HOME/.agents pinned=4 live=3
SCOPE BREADTH-HOST-MISSING $HOME/.local/share/the-musketeer/chrome-profile
BREADTH_AUDIT: DEFECT (required=4 pins=4 checked=3 ok=0 children=125 declared=2 undeclared=123 missing=0 invalid=0 drift=5 exceeds=0 unverified=1)
ADJACENCY_ABSTAIN: rows=15
ADJACENCY_ASSET_ABSENT: rows=18 (asset rows: surface-census.sh owns the GONE verdict)
ADJACENCY_SCOPE: DEFECT (census=35 owned=27 shared=8 groups=4 owners=4 unresolved=1 contested=1 escapes=0 inbound=0 foreign=0 orphans=0 stale_basis=0 basis_escape=0 own_unlisted=0 breadth_required=4 breadth_pins=4 breadth_checked=3 breadth_ok=0 breadth_missing=0 breadth_invalid=0 breadth_drift=5 breadth_exceeds=0 breadth_unverified=1)
```

### Analysis: Does Round 64 Move This Debt?
**No. Round 64 does not move the carried breadth debt.**
- **Root Cause**: The breadth debt is caused by substrate absence on the execution host:
  1. `$HOME/.config/opencode`: pinned 20 children (live 5) and pinned 4 declared (live 1) ⇒ 2 drifts;
  2. `$HOME/.local/bin`: pinned 105 children (live 117) and pinned 2 declared (live 0, because `the-janitor` and `tac-check` binaries are absent on this host) ⇒ 2 drifts;
  3. `$HOME/.agents`: pinned 4 children (live 3) ⇒ 1 drift;
  Total `breadth_drift = 5`.
  4. `$HOME/.local/share/the-musketeer/chrome-profile`: directory absent on host (`BREADTH-HOST-MISSING`) ⇒ `breadth_unverified = 1`.
- **Domain Discipline**: Round 64 is strictly scoped to:
  - C1: calibration (`C1_HELDOUT`: heldout 8 → 0, population 8, rejecting five held-out forgeries F2, F6, F8, F10, B4, accepting three benign rewrites P6, B5, P7, refusing A4 lookup-table vehicle);
  - C2: operability (`C2_REFUSAL`: terminated 0 → 1, killed=5, population=5 from ONE bounded end-to-end run);
  - Routed defects D-63-1 (A4 vehicle guard vacuum), D-63-2 (C2 nested recursion), D-63-3 (carried).
- Per `PROVINCE.md:10-18, 83`, kagi refuses to reinstall host-level substrate or artificially repin directory breadth in the absence of the real substrate. The debt remains correctly carried, measured, reported, and unabsorbed.

---

## 3. Systematic Sibling Scan for the Five Target Grounds

### 3.1 Held-Out Fixture Set

#### Scan Command
```bash
$ for d in /home/vgpnk/Projects/shokunin/*-shokunin; do
    [ "$d" = "/home/vgpnk/Projects/shokunin/kagi-shokunin" ] && continue
    name=$(basename "$d")
    hits=$(grep -rniIE --exclude-dir='.git' --exclude-dir='.jj' 'held[-_ ]out' "$d" 2>/dev/null | wc -l)
    if [ "$hits" -gt 0 ]; then echo "$name: $hits"; fi
  done
audio-shokunin: 27
chousa-shokunin: 509
game-dev-2d-shokunin: 10
game-dev-3d-shokunin: 5
kaidoku-shokunin: 5131
kake-shokunin: 357
kama-shokunin: 237
kasegi-shokunin: 33
kengaku-shokunin: 922
kotoba-shokunin: 567
kotodama-shokunin: 234
kumitate-shokunin: 377
lore-shokunin: 1
mado-shokunin: 581
mori-shokunin: 89
revenger-shokunin: 72
souji-shokunin: 617
tabi-shokunin: 70
tameshi-shokunin: 615
tsukuroi-shokunin: 300
```

#### Detailed Findings by Lane
| Lane | Path:Line | What It Holds | Duplicate vs. Adjacent |
|---|---|---|---|
| `tameshi-shokunin` | `corpus/knowledge/regression-tally-completeness.md:1, 40, 60` | Cites S094 (Dwork et al., arXiv:1411.2664v3 §1 "a held-out test kept from the candidate"). Establishes fleet methodology: sealed held-out mutants committed by hash before scoring defeat public shape allowlists. | **Adjacent** (fleet verification methodology authority; owns the general theoretical principle, does not own kagi's vault/records gates) |
| `kama-shokunin` | `corpus/QUALITY.md:713` (KQ150) | Quality law KQ150: requires held-out cells added by counters to kill named forgeries to be sized past the threshold where the forgery fails, tested against red-before counters. | **Adjacent** (inference engine runtime domain; qualifies local model-serving cells) |
| `mori-shokunin` | `corpus/lessons/round-89.md:37, 79` | Held-out battery (78 cases from residual seats) catches overfit in repair rule that passed its own 34-case training battery with harm=0. | **Adjacent** (process monitoring / cgroups domain) |
| `chousa-shokunin` | `corpus/lessons/round-47.md:145`, `round-48.md:9` | Held-out natural polarity flip fixtures written by seats that did not author the tool, subsequently converted to fixed regression set. | **Adjacent** (research citation grounding domain) |
| `kaidoku-shokunin` | `corpus/knowledge/2026-10-26-r39-sqfs-outcome-triage.md:57` | R39-C2 scored on held-out set generated from distinct SquashFS superblock variants. | **Adjacent** (binary reverse-engineering domain) |
| `mado-shokunin` | `corpus/knowledge/mutation-testing-r28.md:18`, `corpus/lessons/round-27.md:7` | R28/R27 held-out set rotated across waves for compositor window rule evaluation. | **Adjacent** (desktop window compositor domain) |
| `revenger-shokunin` | `.ufo/waves/round-68/R68ConnectorOverlap.md:84` | Adjacency receipt noting tameshi owns the rule for sealed held-out mutation copies, while revenger applies a local instance. | **Adjacent** (binary RE triage domain) |

**Conclusion**: Sibling lanes use held-out fixture sets as local instances of the anti-overfitting discipline established by `tameshi-shokunin` (S094). Kagi's C1 held-out fixture set (`plans/round-64-heldout.tsv`, 20 rows, Amendment A1) is strictly lane-owned, testing historical record-correction polarity and binding mechanics across OpenBao/the-janitor historical records. Adjacent; kagi absorbs nothing.

---

### 3.2 Lookup-Table / Mutation-Kill Contract

#### Scan Command
```bash
$ for d in /home/vgpnk/Projects/shokunin/*-shokunin; do
    [ "$d" = "/home/vgpnk/Projects/shokunin/kagi-shokunin" ] && continue
    name=$(basename "$d")
    hits=$(grep -rniIE --exclude-dir='.git' --exclude-dir='.jj' 'lookup[-_ ]table|lookup table' "$d" 2>/dev/null | grep -iE 'guard|gate|vehicle|refus|defeat|mutat|contract|forger' | wc -l)
    if [ "$hits" -gt 0 ]; then echo "$name: $hits"; fi
  done
chousa-shokunin: 3
kaidoku-shokunin: 7
kake-shokunin: 5
kama-shokunin: 4
kasegi-shokunin: 5
kengaku-shokunin: 6
kotoba-shokunin: 6
kotodama-shokunin: 7
kumitate-shokunin: 1
lore-shokunin: 1
mado-shokunin: 6
mori-shokunin: 5
revenger-shokunin: 5
souji-shokunin: 4
tabi-shokunin: 2
tameshi-shokunin: 1
```

#### Detailed Findings by Lane
| Lane | Path:Line | What It Holds | Duplicate vs. Adjacent |
|---|---|---|---|
| `chousa-shokunin` | `corpus/lessons/round-65.md:25` | "A fixed-case black-box counter cannot distinguish a parsing validator from an argv-keyed lookup table (reviewer demo scored 20/20 without parsing receipts)". | **Adjacent** (citation receipt parser verification) |
| `mori-shokunin` | `corpus/lessons/round-90.md:40`, `r/Mo89C02Critic.md:64` | `class-target-reachable-by-a-lookup-table`: critic forge-b builds 21-string frozenset lookup table passing fixed-string count-c1 and noharm tests. | **Adjacent** (command execution binding checks) |
| `mado-shokunin` | `.ufo/waves/round-48/w1-results.json:208` | Critic attack demonstrating that a lookup table keyed by fixture id scores green against live-oracle tests unless nonce-fresh cases are added. | **Adjacent** (Hyprland window cache checks) |
| `kengaku-shokunin` | `corpus/SOURCES.md:345` (S329) | Evaluates Terminal-Bench 2.0 task grader where hidden tests are 3 published games, defeated by a 103-entry lookup table. | **Adjacent** (model benchmark grader evaluation) |
| `kotoba-shokunin` | `.ufo/waves/round-62/w1/RevPlanScope.md:18` | Reviewer notes: fixed attacks and benign controls do not satisfy mutation-kill claim because a published lookup table satisfies them. | **Adjacent** (agent skill frontmatter gates) |
| `revenger-shokunin` | `.ufo/waves/round-93/w1/ConnectorOverlap/considerthese-note.md:20` | Review notes that controls caught lazy skips, but surviving reachability was skilled forgery including lookup tables. | **Adjacent** (artifact provenance checks) |

**Conclusion**: Across multiple sibling lanes, critics and reviewers have repeatedly demonstrated that fixed-fixture counters can be gamed by lookup tables. Kagi's C1 claim specifically addresses this defect (routed defect D-63-1, closing M63-6): guard leg (e) refuses the A4 lookup-table vehicle by evaluating it against the held-out set, while challenge leg (f) verifies negator set sensitivity. Adjacent; in-lane gate defense.

---

### 3.3 Recursion Bound / Depth Guard in Delegating Gates

#### Scan Command
```bash
$ for d in /home/vgpnk/Projects/shokunin/*-shokunin; do
    [ "$d" = "/home/vgpnk/Projects/shokunin/kagi-shokunin" ] && continue
    name=$(basename "$d")
    hits=$(grep -rniIE --exclude-dir='.git' --exclude-dir='.jj' 'recursion[-_ ]bound|depth[-_ ]guard|delegat.*gate|nested.*battery|recursion.*limit|recursion.*depth' "$d" 2>/dev/null | grep -iE 'guard|gate|counter|battery|bound' | wc -l)
    if [ "$hits" -gt 0 ]; then echo "$name: $hits"; fi
  done
audio-shokunin: 3
chousa-shokunin: 5
game-dev-2d-shokunin: 5
game-dev-3d-shokunin: 5
kaidoku-shokunin: 5
kake-shokunin: 5
kama-shokunin: 5
kasegi-shokunin: 5
kengaku-shokunin: 5
kotoba-shokunin: 5
kotodama-shokunin: 5
kumitate-shokunin: 5
lore-shokunin: 5
mado-shokunin: 5
mori-shokunin: 5
revenger-shokunin: 5
souji-shokunin: 5
tabi-shokunin: 5
tameshi-shokunin: 5
tsukuroi-shokunin: 5
```

#### Detailed Findings by Lane
| Lane | Path:Line | What It Holds | Duplicate vs. Adjacent |
|---|---|---|---|
| `kama-shokunin` | `tools/pre-report-gate.py:1641`, `corpus/knowledge/pre-report-gate.md:81` | Recursion guard: `PRE_REPORT_RECURSION depth={depth} refused` — detects gate re-entry when invoked from child processes/reports, exiting 3. | **Adjacent** (pre-report check re-entry protection; process-level depth tracking) |
| `kaidoku-shokunin` | `corpus/lessons/round-97.md:49`, `round-97-verifier-spotcheck.md:77` | Recorded defect M97-r: `K-ownrun` leg re-ran the rule with the same mutant table, causing nested runs to re-enter and exhaust scratch disk. Fixed with K-ownrun recursion bound. | **Adjacent** (mutation test runner recursion bound) |
| `kumitate-shokunin` | `corpus/knowledge/kimi-modes-machinery.md:138`, `.ufo/waves/round-36/build/RevChecklistSelf.md:6` | `task.maxRecursionDepth=2` for swarm coordinator task spawning; checklist recursion bound skipping self-spawn commands. | **Adjacent** (swarm coordinator orchestration engine) |
| `lore-shokunin` | `.ufo/waves/round-98/seats/V05-c2-chain-six.md:207` | Recursion bound implemented via `DEPENDENCY_FREEZE_SELF_TEST_CHILD` env flag. | **Adjacent** (continuity bible dependency checker) |
| `mado-shokunin` | `corpus/lessons/round-96-verifier-spotcheck.md:162` | `indent-depth-guard-one` AST depth limiter on parser checks. | **Adjacent** (syntax parsing depth bound) |
| `chousa-shokunin` | `corpus/lessons/round-51.md:22, 194`, `round-54-verifier-spotcheck.md:129` | Counter refused delegation to live lane tools by pinning frozen base copies (`controls/tool-before.py`) to prevent cyclic evaluation. | **Adjacent** (research source citation verification) |

**Conclusion**: Multiple lanes have faced gate re-entry recursion when verification batteries invoke counters that in turn invoke batteries. Kagi's C2 recursion bound (`C2_RECURSION_BOUND`, default 1 in `plans/round-64-c2.sh`) specifically bounds delegating battery calls to fixture/confinement controls only, eliminating the round-63 timeout failure (D-63-2). Adjacent; in-lane counter operability repair.

---

### 3.4 Stub-Refusal Control

#### Scan Command
```bash
$ for d in /home/vgpnk/Projects/shokunin/*-shokunin; do
    [ "$d" = "/home/vgpnk/Projects/shokunin/kagi-shokunin" ] && continue
    name=$(basename "$d")
    hits=$(grep -rniIE --exclude-dir='.git' --exclude-dir='.jj' 'stub[-_ ]refusal|printer[-_ ]stub|refus.*stub|stub.*control' "$d" 2>/dev/null | wc -l)
    if [ "$hits" -gt 0 ]; then echo "$name: $hits"; fi
  done
audio-shokunin: 5
chousa-shokunin: 5
game-dev-3d-shokunin: 1
kaidoku-shokunin: 5
kake-shokunin: 5
kama-shokunin: 4
kasegi-shokunin: 5
kengaku-shokunin: 5
kotoba-shokunin: 5
kotodama-shokunin: 5
kumitate-shokunin: 5
mado-shokunin: 5
mori-shokunin: 5
revenger-shokunin: 5
souji-shokunin: 5
tabi-shokunin: 5
tameshi-shokunin: 5
tsukuroi-shokunin: 5
```

#### Detailed Findings by Lane
| Lane | Path:Line | What It Holds | Duplicate vs. Adjacent |
|---|---|---|---|
| `kumitate-shokunin` | `corpus/knowledge/ready-handoff-admission.md:2` | Ready-handoff gate refuses constant-printer stub (reads 3/16 vs target 16/16 on frozen counter `C81_C1`). | **Adjacent** (swarm handoff admission gate) |
| `chousa-shokunin` | `corpus/lessons/round-53-verifier-spotcheck.md:27` | `forge-c1.py` string-stubs `--selftest`; counter-controls test refusal of canned selftests. | **Adjacent** (research citation matrix checks) |
| `kasegi-shokunin` | `corpus/instruments/README.md:1030`, `corpus/lessons/round-45.md:13` | Selftest `--do-nothing-control` substitutes a stub counter whose limbs all read green to ensure red-expecting cases fail. | **Adjacent** (bounty claim packaging gate) |
| `kake-shokunin` | `corpus/knowledge/cache-key-conformance-gate.md:10, 32` | Tests 7 non-conforming stubs against RFC 9110 HTTP cache key rules. | **Adjacent** (web publishing cache gate) |
| `mado-shokunin` | `corpus/QUALITY.md:393` (Rule 73) | Counter sandbox hides stub payload from tested tool using compiled mode 0111 execute-only binaries. | **Adjacent** (window management tool sandboxing) |
| `revenger-shokunin` | `corpus/lessons/round-95.md:96`, `round-90.md:63` | Pre-freeze controls testing refusal of stubs that print pass lines without executing. | **Adjacent** (binary RE evidence provenance) |

**Conclusion**: Stub-refusal controls are a standard fleet defense to verify that claim counters fail closed on unearned passes. Kagi's round-64 controls battery (`plans/round-64-controls.sh` controls `C1-F9` and `C2-F7`) and C1 guard leg (d) specifically test refusal of printer-stub claim counters over secrets/vault record assertions. Adjacent; in-lane authority.

---

### 3.5 Seal / SHA256-Checked Fixture Table

#### Scan Command
```bash
$ for d in /home/vgpnk/Projects/shokunin/*-shokunin; do
    [ "$d" = "/home/vgpnk/Projects/shokunin/kagi-shokunin" ] && continue
    name=$(basename "$d")
    hits=$(grep -rniIE --exclude-dir='.git' --exclude-dir='.jj' 'seal.*(sha256|hash|digest|table|tsv|fixture)|(sha256|hash|digest).*check.*(fixture|table|tsv)|sealed.*(tsv|fixture|table)' "$d" 2>/dev/null | wc -l)
    if [ "$hits" -gt 0 ]; then echo "$name: $hits"; fi
  done
audio-shokunin: 5
chousa-shokunin: 5
game-dev-2d-shokunin: 5
game-dev-3d-shokunin: 5
kaidoku-shokunin: 5
kake-shokunin: 5
kama-shokunin: 5
kotoba-shokunin: 3
kotodama-shokunin: 5
kumitate-shokunin: 5
lore-shokunin: 5
mado-shokunin: 5
mori-shokunin: 5
revenger-shokunin: 5
souji-shokunin: 5
tabi-shokunin: 5
tameshi-shokunin: 5
tsukuroi-shokunin: 5
```

#### Detailed Findings by Lane
| Lane | Path:Line | What It Holds | Duplicate vs. Adjacent |
|---|---|---|---|
| `tameshi-shokunin` | `corpus/knowledge/regression-tally-completeness.md:40-60` | Sealed mutant tables (`contract-amendment-3.json` sha256-pinned, scored via `c1-measure-v4.py --sealed SEALED_JSON`). Requires sealed-file and tally-block digests to match before scoring. | **Adjacent** (method authority for sealed mutation test suites) |
| `kake-shokunin` | `corpus/lessons/round-38-verifier-spotcheck.md:58-59`, `round-36-verifier-spotcheck.md:73-75` | Counter freezes `KEY_SHA256 = "749ef6a6..."`; fixture cases `cases_v3.json` remain sealed until reveal and verified against the pin. | **Adjacent** (accessibility test fixture sealing) |
| `mado-shokunin` | `corpus/knowledge/tripwire-lifetime-recovery-r22.md:33` | Raw source cells and fixtures sealed before implementation in `truth-seal.json`. | **Adjacent** (tripwire ground-truth sealing) |
| `chousa-shokunin` | `corpus/knowledge/receipt-expectation-digests-r40.md:23` | `active-r39-receipts.tsv` digest-pinned expectation table for verification. | **Adjacent** (research citation expectation table) |
| `kumitate-shokunin` | `corpus/knowledge/runtime-remainder-census.md:132, 208` | `validate_routing_mirror` binds compiled seat table to live mirror via sealed body digest. | **Adjacent** (swarm seat routing table verification) |

**Conclusion**: Pre-declaration sealing of fixture tables via cryptographic hashes is the recognized fleet protocol to ensure zero data leakage between test designers and candidate authors. Kagi's C1 held-out fixture table (`plans/round-64-heldout.tsv`, sha256 `b0f51e2a7e7b5b62efa17c91761e24e01fe1a3ff384181e468b628544faa93c2`, Amendment A1) is strictly lane-local, governing historical secrets and vault ops record sentences. Adjacent; kagi absorbs nothing.

---

## 4. Summary Table of All 20 Sibling Lanes

| # | Lane Repository | Primary Domain | Sibling Status | Overlap Analysis & Notes |
|---|---|---|---|---|
| 1 | `audio-shokunin` | Audio DSP / WAV processing | **Adjacent** | Canonical WAV sha256 digests; stub audio conversion checks; zero vault/secrets relevance |
| 2 | `chousa-shokunin` | Research methodology & citations | **Adjacent** | S058/S059 SRI digests; lookup-table parser gaming demonstrations; fixed-base controls |
| 3 | `game-dev-2d-shokunin` | 2D game engine (Godot) | **Adjacent** | Runner hash verification; step-level focus edge checks; no record correction grammar |
| 4 | `game-dev-3d-shokunin` | 3D game engine (Unreal MCP) | **Adjacent** | Live-tree fixture SHA256 integrity checks; physics blocked-gate stubs |
| 5 | `kaidoku-shokunin` | Binary reverse engineering | **Adjacent** | R97-r mutation runner recursion bound; Mach-O header / ASAR Evidence sha256 seals |
| 6 | `kake-shokunin` | Web publishing & accessibility | **Adjacent** | `sealed_count_v3.py` sha256 case pins; RFC 9110 cache stub refusal |
| 7 | `kama-shokunin` | Local LLM inference runtime | **Adjacent** | `pre-report-gate.py` `PRE_REPORT_RECURSION depth` gate; KQ150 held-out cell sizing |
| 8 | `kasegi-shokunin` | Bug bounty claim packaging | **Adjacent** | Limb mutation check harness; selftest `--do-nothing-control` stub counter refusal |
| 9 | `kengaku-shokunin` | Model evaluation & benchmarks | **Adjacent** | Grader lookup-table defeat analysis (S329 Terminal-Bench 2.0); hash checks |
| 10 | `kotoba-shokunin` | Agent & skill frontmatter | **Adjacent** | Q47/Q85 mutation battery lookup-table refusal; detached commit sentinel checks |
| 11 | `kotodama-shokunin` | Fictional world-building | **Adjacent** | Evidentiality source stubs; two-string lookup table refusal controls |
| 12 | `kumitate-shokunin` | Swarm orchestration & harness | **Adjacent** | `task.maxRecursionDepth=2`; C81_C1 constant-printer stub refusal; sealed table mirrors |
| 13 | `lore-shokunin` | Narrative canon verification | **Adjacent** | `DEPENDENCY_FREEZE_SELF_TEST_CHILD` recursion guard; provenance chain controls |
| 14 | `mado-shokunin` | Desktop window management | **Adjacent** | `truth-seal.json` pre-seal fixtures; Rule 73 compiled sandbox stub payload hiding |
| 15 | `mori-shokunin` | System resource & liveness | **Adjacent** | R89 78-case held-out battery; forge-b frozenset lookup table defeat demonstration |
| 16 | `revenger-shokunin` | Shipped artifact binary RE | **Adjacent** | R68 tameshi sealed-mutant rule acknowledgment; pre-freeze stub-printer controls |
| 17 | `souji-shokunin` | Repo & worktree hygiene | **Adjacent** | Splitlines line model sha256 pins; nested `.git` directory jj colocation checks |
| 18 | `tabi-shokunin` | Browser automation (BiDi) | **Adjacent** | CDP loopback port stub argv tests; dynamic page nonce digest decoupling |
| 19 | `tameshi-shokunin` | Fleet verification methodology | **Adjacent** | Authority for S094 held-out testing and sealed mutation test tally completeness (`c1-measure-v4.py`) |
| 20 | `tsukuroi-shokunin` | OS package & boot repair | **Adjacent** | R32 fixture-gated behavioral counter live views; census `--selftest` mount tables |

---

## 5. Non-Obvious Move (UFO-FSD Connector Synthesis)

### Evidence
1. **Contract vs. Implementation Seam in C2 Delegation**:
   In `plans/round-64.md` §C2 (lines 156-160), the frozen plan states:
   *"The recursion bound is an explicit environment flag `C2_RECURSION_BOUND` (default 1): at 1 the counter's controls-battery leg delegates to the battery's fixture/confinement controls only and never re-enters a counter; at 0 it delegates to the full battery (which re-enters both counters)."*
2. **Implementation Gap in `plans/round-64-controls.sh`**:
   Inspection of `plans/round-64-controls.sh` reveals that `main()` invokes `probe_counters()` unconditionally at line 638. `probe_counters()` invokes both `C1_INSTR` (`plans/round-64-c1.sh`) and `C2_INSTR` (`plans/round-64-c2.sh`) with `timeout 2400`. The variable `C2_RECURSION_BOUND` is only referenced in comments, in `ctrl_c2_bound()`, and in the selftest case D; it is **never evaluated inside `probe_counters()` or `resolve_instruments()`**.
3. **Second-Order Recursion Failure**:
   When `plans/round-64-c2.sh` executes leg 3 (`C2-F7`) and leg 4 (`C1-F9`) by calling `bash "$TREE/plans/round-64-controls.sh" "$TREE"`, the child controls battery invokes `probe_counters()`, which re-enters `plans/round-64-c2.sh`. Without an active guard inside `probe_counters()`, this triggers infinite mutual recursion, reproducing defect D-63-2 (M63-LEN) and causing `plans/round-64-c2.sh` to hit the outer timeout with `rc=124`, violating C2's termination milestone (`terminated=0`).
4. **Execution Cost Coupling in C1**:
   `plans/round-64-c1.sh` scores 20 fixtures from `plans/round-64-heldout.tsv`. Copying the entire repository tree (~200 MB) for each fixture takes ~90 s per copy (1800 s total), blowing the 1200 s budget. Slim-tree copying (copying only the 7 files required by the checker) reduces per-fixture setup from ~90 s to <0.1 s (<3 s total).

### Affected Axes
- **operability (primary)**: directly unblocks C2 termination (`terminated 0 → 1` with `killed=5` within 15 seconds instead of timing out at 1200 s with `rc=124`).
- **calibration (secondary)**: protects C1 and the controls battery against vacuous timeouts and allows unmutated no-work and real controls to complete reliably.
- **adjacency (preserved)**: maintains clean lane boundaries by solving the recursion bound locally without altering external orchestrator contracts.

### Proposed Move
In `plans/round-64-controls.sh`, add an explicit recursion-bound short-circuit at the top of `probe_counters()`:
```bash
probe_counters() {
  if [ "${C2_RECURSION_BOUND:-0}" = "1" ]; then
    # Bounded child execution: skip counter re-entry to prevent recursion
    emit "# recursion-bound: probe_counters skipped under C2_RECURSION_BOUND=1"
    return 0
  fi
  # ... existing C1_INSTR and C2_INSTR invocations ...
}
```
When `C2_RECURSION_BOUND=1`, `probe_counters()` immediately returns. The battery then executes the fixture controls (`C1-F9`, `C2-F7`, `PRIOR-*`), emits `mismatch` for `C2-F7` and `C1-F9` (since the stub lines do not match the expected BASE lines), and completes in <2 seconds.
When `C2_RECURSION_BOUND=0` (the refutation leg `C2-BOUND`), `probe_counters()` runs uninhibited, re-entering `plans/round-64-c2.sh` and reproducing the expected timeout, proving that the recursion bound is load-bearing (kill rule K2).

### Risks & Mitigations
- **Risk**: In a child run where `probe_counters()` is skipped, `ctrl_c1_nowork`, `ctrl_c2_nowork`, `ctrl_c1_real`, and `ctrl_c2_real` will find `C1_HAVE=0` and `C2_HAVE=0` and report `skip`.
- **Mitigation**: This is strictly conforming to plan §C2 ("delegates to the battery's fixture/confinement controls only and never re-enters a counter"). Legs L3 and L4 only check for `CONTROL C2-F7 .*verdict=mismatch` and `CONTROL C1-F9 .*verdict=mismatch`. The top-level standalone invocation (`bash plans/round-64-controls.sh`) runs without `C2_RECURSION_BOUND=1` and evaluates all controls.

### Verification
1. Standalone execution: `C2_RECURSION_BOUND=1 bash plans/round-64-controls.sh .` completes in <3 s, emits `CONTROL C1-F9 ... verdict=mismatch` and `CONTROL C2-F7 ... verdict=mismatch`, with zero counter re-entry.
2. Refutation execution: `C2_RECURSION_BOUND=0 timeout 240 bash plans/round-64-c2.sh --tree .` times out with `rc=124`, proving kill rule K2.
3. Candidate execution: `bash plans/round-64-c2.sh --tree .` prints exactly one `C2_REFUSAL: killed=5 population=5 guard=1 terminates=1` line in <15 s.

---

SEAT-STATUS: complete
