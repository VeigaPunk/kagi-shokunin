# K45CriticClaims — adversarial review of the round-45 claims (pre-candidate, falsify)

Measured at lane HEAD `307fb50` (the predeclaration commit); BASE `0d0192f` is an ancestor (`git merge-base --is-ancestor` rc 0).
Staged package read read-only at `/home/vgpnk/Projects/shokuknow/merge/kagi/`. No candidate re-executed; counters judged from source + committed receipts.

## D-1 — (a) stagnation-nudge premise is mis-measured (severity: medium — AMEND before candidate, named L0 item)

Exact: `plans/round-45.md:9-10` — "the last / capability row entered in round 39 (`declared-axis conformance`, `anchor-pin drift detection`), so the / window N=3 is exhausted".
Evidence: `SCORECARD.md:712` — the table's latest row is "gate self-testing with committed expected findings … | 40 |"; `SCORECARD.md:714` — "The latest first-working round in this table is 40". The plan omits the round-40 row and contradicts the table it cites.
Verdict: the conclusion survives — per `AXES.md:66-70` and `SCORECARD.md:718`, the window is the last three completed rounds (42–44); no capability entered in 42–44 under either measurement (latest entry 40), so the nudge fires regardless. But the frozen waiver sentence rests on a false measurement; calibration requires the amendment, not a silent edit.
Amendment A1: correct the sentence to round 40 and re-derive the window (41–44 empty).

## D-2 — (b) C2 overlap: none on 11770-3 ground itself; three named adjacencies, one stale provenance line, one dependency gap (severity: medium — AMEND recommended)

No-overlap check re-verified: `grep -rn "17901\|11770" corpus/SOURCES.md corpus/knowledge/*.md PROVINCE.md` → only `corpus/SOURCES.md:149` (uncommitted leads bullet, working-tree only: `git show BASE:corpus/SOURCES.md | grep -c "Round-45 disposition"` → 0; `git status --porcelain` shows ` M corpus/SOURCES.md`). The plan's "held nowhere" holds for 11770-3 content. Adjacencies:
1. Same entry shape: round-33 core already holds standards status/supersession for the key-management family — `PROVINCE.md:92` "publication status and currency signals of the key-management family" (NIST S073–S082, re-opened 2026-11-04). C2 is a fourth status-shaped entry, different standard family. Adjacent, not identical.
2. Subject boundary: round-34 core holds "KMS-managed credential lifecycle" (`PROVINCE.md:81`, S083–S087). The staged r41 row itself quotes the ISO catalogue excluding "key lifecycle management" from 11770-3's scope — the boundary keeps C2 off round-34 ground only if the entry honors it; the plan never states the boundary.
3. Stale ground line: both staged rows justify themselves as "lane frontier item — NIST key-management draft status (`corpus/README.md` §Frontier)" (r39:5, r41:8) — but `corpus/README.md:120-122` §Frontier holds only "Observable release clocks"; the NIST item moved to core in round 33. The staged provenance describes a frontier state the target lane no longer has; the plan adopts the theme without reconciling it.
4. Dependency gap: the staged rows are not self-contained — r39:9 "Round 8 established that GB/T 17901.3-2021 修改采用 ISO/IEC 11770-3:2015"; r41:12 "Round 10 read the 2015 and 2021 editions from their own text"; r39 dates GB/T 17901.3-2021 from "round 8's S148". These staged premises are held nowhere in the lane; the quarantine slice (`plans/round-45.md:59`: S053, S071, S081, S090, S091, S093, S108, S113) does not contain the dependency ids (staged S148, S159, S170–S173), so the slice check cannot see them; the re-open duty covers cited ids, not uncited premises.
Amendment A2: add a scope-boundary sentence (11770-3 status/supersession only; no lifecycle ground) and require the admitted entry to be self-contained — every factual premise cited and re-opened this round. Note: renumber target "S100 onward" (`plans/round-45.md:57-58`) overlaps the staged append's own S100+ ids; "next free" must skip staged-reserved ids too (the §6 grep pair is the operational guard).

## D-3 — (c) one universal clause lacks an enumerating command: C1 kill rule 3's exception (severity: medium — AMEND recommended)

Inside the two frozen predicate formulas, no defect: every universal is enumerated by a command (C1 manifest walk `corpus/claims-declared.sh:115ff`; C2 census, quote-bodies ADDED rows, `quote-locate.py`; renumber grep pair). The hit is in the kill rules: `plans/round-45.md:32-34` — "killed if … the candidate reports a MISMATCH on any real round ≥ 39 **that lacks a named defect**". The universal is enumerated by the gate run, but the exception "lacks a named defect" is prose: no frozen artifact is named where the defect must be named, and no command checks it — the only kill that cannot fire mechanically, and the subject of the kill decides whether it fired.
Amendment A5: pin "named" to a checkable location (a routed-defect row with id in the round-45 lesson, resolvable by grep).

## D-4 — (d) yes, the scope rule is gameable by permanent in-flight status (severity: medium — AMEND recommended)

Exact: `plans/round-45.md:27-29` — "a round R ≥ 39 is checked when `plans/round-R.md` carries claim headings AND SCORECARD carries `## Round R — post-move`. An in-flight round (no post-move section) is not yet a landed claim and is not checked."
Mechanism: the gate's existing direction demands a post-move section per manifest row (selftest case 4 → `MISMATCH 90 C1 section-missing`, `corpus/claims-declared.sh:74-76`), so a row cannot hide; but plan headings with **no manifest row and no post-move section** are checked by neither direction. A lane that lands work under declared headings and never appends the section passes REAL=CLEAN forever. No fixture covers the state (A, B, C all carry sections — `plans/round-45-c1.sh:48-64`), and no kill rule covers it (kill 3 needs a reported MISMATCH; the gate reports nothing).
The carve-out is required at the candidate — round 45 itself is in-flight there (headings, no section) — so deletion is wrong. Amendment A4: name the ceiling (permanent in-flight disables the new direction) and freeze the catch-up: once the section lands, every later run audits the round mechanically; round-46 scope must be expected to audit round 45.

## D-5 — (e) C2 counter ignores `quote-locate.py`'s exit code — the one gap that yields a PASSING value from a dead instrument (severity: high — AMEND before any seat scores)

Evidence: `plans/round-45-c2.sh:57` captures `locate_rc=$?`; `:59-67` counts `f_add` only from `NOT-LOCATED` lines; `:69` `located=$((m_add - f_add))`; `:74` echoes `rc=$locate_rc` but never gates `value`. If the locator crashes (rc ≠ 0) after emitting no NOT-LOCATED lines, `located = m_add` = every ADDED quote-bodies row → `value ≥ 3` → predicate satisfied. The kill rule `plans/round-45.md:52-54` "if any admitted entry quote is NOT-LOCATED" presupposes the locator ran; no kill names locator failure.
Amendment A2b (kill + counter, L0-named): extend the kill with "or `quote-locate.py` exits non-zero" and gate `value` on `locate_rc = 0`. The plan's own freeze (`plans/round-45.md:113-115`) permits this now: no seat has scored.

## D-6 — (e) C1 kill rules omit the fixture-crash / partial-detection case (severity: low — optional amendment)

`plans/round-45-c1.sh:66-68` keeps exit codes only. Gate exit 2 (SETUP) on fixture A or B is neither MISMATCH (1) nor CLEAN (0): DETECTED < 2 with POSITIVE = 1, REAL = CLEAN → value 1 ≠ target 2, and no named kill fires. A crash on all fixtures sets POSITIVE = 0 → killed; the residual hole is partial crash. Target-miss still fails the claim, hence low. Optional A6: "C1 is killed if DETECTED < 2 at the candidate."

## D-7 — (f) causal separability: yes, with one bookkeeping coupling (severity: info — optional amendment)

Artifacts are disjoint (C1: `corpus/claims-declared.sh` + scratch fixtures; C2: knowledge entry, SOURCES rows, quote-bodies rows, captures); neither counter reads the other's outputs; `AXES.md:36-37` "each verifiable without the others having landed" is satisfied in content. One coupling: both are scored at the same candidate revision and C1's REAL leg (`plans/round-45-c1.sh:68`) walks the whole real tree, including the wave's own round-45 bookkeeping — if `## Round 45 — post-move` and the round-45 manifest rows do not land atomically, the gate reads round 45 as in-scope and MISMATCHes it, killing C1 through landing order, not C2 content; kill 3's prose escape (D-3) is the only relief. Optional A7: name the atomic landing order.

## Verification performed (report only what ran)

- BASE receipts are committed at HEAD: `git ls-tree HEAD -- .ufo/waves/round-45/controls/` lists all five blobs; `c1-base.txt` reads exactly `C1_BIJECTION: value=0 detected=0 positive=1 real=CLEAN (rc A=0 B=0 C=1 tree=LANE)` and `c2-base.txt` reads `value=0 added=0 entries=0 census=0 located=0 …` — matching the plan's measured lines (evidence-verified by read, not re-executed; leaf bounds).
- Overlap grep re-run as quoted in D-2; frontier/core lines read at `corpus/README.md:120-122`, `PROVINCE.md:81,92`; gate and counters read in full; staged rows read at the paths cited.
- No checks named by other seats were run; no claim-ledger verify, no self-counts.

## Amendment summary (each a named L0 item — the plan's Frozen section forbids silent edits)

A1 (D-1) stagnation sentence corrected to round 40; A2/A2b (D-2, D-5) coverage boundary + self-contained-entry + quote-locate rc kill/counter gate; A4 (D-4) permanent-in-flight ceiling + round-46 catch-up; A5 (D-3) "named defect" pinned to a checkable lesson row; optional A6 (D-6), A7 (D-7). All are pre-scoring changes under `plans/round-45.md:113-115`.
