# RCiteTargets: C2 lone-clone citation census (round 25 build)

Seat KagiR25.RCiteTargets-2 (leaf). Base `4587c61a348e4528717404a68912c373f3ef4d03` (sandbox `git rev-parse HEAD`). Axes: operability (C2, primary), classifier truth. Real lane read-only; this file is the only write. No `verify`/`cells`, no lane git, no installs (none needed).
Sandbox `/fast/scratch/kagi-r25/RCiteTargets-2`: `lane/` lone clone at BASE; `named/kagi-shokunin/` same commit, dir named as the lane; `fleet/kagi-shokunin/` BASE clone with tracked `.ufo` moved aside, real `.ufo` linked, and `kake-`/`kama-`/`kotoba-shokunin` symlinked in from the real fleet.

## 1. Runs

Command: `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/RCiteTargets-2/home bash corpus/claim-ledger.sh citations`
- lone `lane/`: exit 1. `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)`; first line `UNRESOLVED LOG.md:210 .ufo/l0-questions.md (ufo)`. Matches plans/round-25.md:51.
- named (same command, absolute path): exit 1. `... unresolved=46 ephemeral=0 labeled=18)`.
- fleet mirror (same): exit 0. `CITATION_GATE: CLEAN (cites=1371 docs=67 unresolved=0 ephemeral=0 labeled=13)`.
- Real-lane docs: all 67 gate docs byte-identical to BASE (`filecmp`); no extra knowledge/lessons `.md`; `corpus/claim-ledger.sh` identical. The fleet mirror reproduces real-lane citation state.
- Existence: `os.path.exists` over `cite_target` candidates (claim-ledger.sh:620-638), ROOT=`/home/vgpnk/Projects/shokunin/kagi-shokunin`; same answer as `test -e`. Spot `test -e` (all exit 0): `shokunin/kake-shokunin/SKILL.md`, `shokunin/.ufo/reports/round-10/protocol.md`, `shokunin/.ufo/watchdog.log`, `kagi-shokunin/.ufo/waves/round-22/frozen/before/expected.json`, `kagi-shokunin/.ufo/round-20/inspection.json`, `kagi-shokunin/SKILL.md`.

## 2. Classes (88 UNRESOLVED rows, 62 unique tokens; local/shorthand/rootdoc = 0)
- ufo: 31 rows / 20 tokens, lane-first `.ufo/...` (claim-ledger.sh:627-632).
- sibling: 57 rows / 42 tokens: self-named `kagi-shokunin/...` 42 / 36; other lanes `kake|kama|kotoba-shokunin/...` 15 / 6 (cite_class :613-614).
- Fleet existence: 62/62 tokens and 88/88 rows present.

## 3. Verdicts

| bucket | rows | tokens | verdict |
|---|---|---|---|
| A. lane-local, absent in fleet and lane commit | 0 | 0 | real defect: none |
| B. lane-local name-bound: committed, resolves as `kagi-shokunin/...` | 42 | 36 | not a defect; misfiled by class rule (F1) |
| C. fleet-only `.ufo/...` (absent from lane commit) | 31 | 20 | layout |
| D. fleet-only other-lane dirs | 15 | 6 | layout |
| E. labelled dead, absent in fleet: `.ufo/reports/round-2/AGGREGATE.md` (test -e = 1 fleet, 1 lane) | 3 | 1 | accepted by label (claim-ledger.sh:44-49) |

Evidence for B: the named-clone residual is exactly C+D (`named.out`: 46 UNRESOLVED lines, all `.ufo` or `kake|kama|kotoba-shokunin`; no `kagi-shokunin/` left). `git -C lane ls-files`: 575 `.ufo` paths tracked, including `.ufo/waves/round-22/before.json`; none of the 20 C tokens is tracked.

## 4. Tokens (rows; first cite; all present in fleet)

**C, ufo** (untracked at BASE; resolve in `/home/vgpnk/Projects/shokunin/.ufo/`):
- `.ufo/l0-questions.md` x2 (LOG.md:210) · `.ufo/prompts/kagi-round-3.md` x2 (lessons/round-3.md:3) · `.ufo/prompts/kagi-round-4.md` x1 (lessons/round-4.md:3)
- `.ufo/prompts/kagi-round-5.md` x1 (lessons/round-5.md:3) · `kagi-round-22.md` x1 (lessons/round-22-verifier-spotcheck.md:7) · `kagi-round-23.md` x1 (lessons/round-23-verifier-spotcheck.md:7)
- `.ufo/reports/round-10/kagi.md` x1 (knowledge/adjacency-scope.md:237) · `round-10/protocol.md` x3 (knowledge/claim-ledger.md:27) · `round-8/aggregator.md` x1 (LOG.md:366)
- `.ufo/reports/round-3/kagi.md` x2 (lessons/round-6-aggregator-audit.md:124) · `round-7/kagi.md` x2 (:125) · `round-9/kagi.md` x2 (:100) · `round-9/kake.md` x1 (:129)
- `.ufo/reports/round-22/kagi.md` x2 (lessons/round-22-verifier-spotcheck.md:6) · `round-23/kagi.md` x2 (lessons/round-23-verifier-spotcheck.md:6)
- `.ufo/state` x1 (lessons/round-23.md:89) · `.ufo/state/aggregator.round` x2 (lessons/round-4-aggregator-audit.md:3) · `.ufo/watchdog.log` x1 (corpus/README.md:26)
- `.ufo/waves/round-1.json` x2 (corpus/README.md:26) · `.ufo/waves/kaika-w3/kagi-review.md` x1 (lessons/round-21-verifier-spotcheck.md:6)

**B, self-named** (42 rows; resolves in any clone named `kagi-shokunin`):
- Repo root `kagi-shokunin/` x1 (lessons/round-4-aggregator-audit.md:59).
- Committed non-.ufo (5): `LOG.md` x1 (lessons/round-1-aggregator-seed.md:20); `SKILL.md` x2 (round-1-aggregator-seed.md:22); `SHONEN.md` x1 (round-6-aggregator-audit.md:94); `corpus/lessons/round-9.md` x1 (:58); `corpus/transcript-scan.sh` x1 (:154).
- Committed `.ufo` (30, all tracked): round-20 `wave/` (LOG.md:873), `inspection.json` x3 (LOG.md:900), `continuation.json` (LOG.md:943), `pane-attestation.json` (LOG.md:911), `local-checks.json` (lessons/round-20.md:3), `reports/round-20/kagi.md` (LOG.md:941); round-22 `before.json` (LOG.md:1072), `initial-checks.json` x3 (SCORECARD.md:749), `final-verification.json` x2 (LOG.md:1151), `task-receipt-falsify.json` (LOG.md:1108), `round21-migrations.json` (lessons/round-22.md:47), `pin-migration-errata.json` (:212), `review-evidence-quarantine-closure.json` (:210), `frozen/before/expected.json` (SKILL.md:697), `frozen/before/corpus/stamps.tsv` (lessons/round-22.md:35), `waves/round-22/` and `build/` dirs (LOG.md:1081; lessons/round-22.md:242), six `build/*.md` (knowledge/control-plane-hardening.md:199 and five more), five `falsify/*.md` (lessons/round-22.md:207-209; round-22-source-errata.md:38-39); round-23 `waves/round-23/` dir (lessons/round-23-verifier-spotcheck.md:27) and `final-verification.json` (:37).

**D, other lanes** (6 tokens, 15 rows; sibling dirs outside the lane repo):
- `kake-shokunin/SKILL.md` x9 (LOG.md:598) · `kake-shokunin/corpus/knowledge/mirror-pitfalls.md` x1 (knowledge/adjacency-scope.md:306) · `kake-shokunin/corpus/lessons/round-1-aggregator-audit.md` x1 (corpus/README.md:98)
- `kama-shokunin/corpus/knowledge/cross-lane-scope.md` x1 (corpus/README.md:96) · `kotoba-shokunin/corpus/knowledge/alwayson-checklist-round7.md` x2 (corpus/README.md:97) · `kotoba-shokunin/corpus/knowledge/fleet-skill-audit-round5.md` x1 (lessons/round-5-aggregator-mirror-bare-path-and-unclosed-prereq.md:4)

**E, labelled dead** (not in the UNRESOLVED list): `.ufo/reports/round-2/AGGREGATE.md` x3 (knowledge/claim-ledger.md:132; lessons/round-11.md:71; lessons/round-5-aggregator-mirror-bare-path-and-unclosed-prereq.md:21).

## 5. Findings

F1 (counterexample to the C2 rule as written). plans/round-25.md:41-45 classifies unresolved `ufo`/`sibling` tokens as FLEET-ABSENT and promises "lane-local misses stay UNRESOLVED". A dead self-named cite has class `sibling`. Planted `plant/planted.md` (sandbox only) holds `kagi-shokunin/corpus/nope.md` and `corpus/nope.md`. BASE output is identical in lone, named and fleet layouts: `UNRESOLVED .../planted.md:1 kagi-shokunin/corpus/nope.md (sibling)`, `UNRESOLVED .../planted.md:2 corpus/nope.md (local)`, `CITATION_GATE: BROKEN (cites=2 docs=1 unresolved=2 ...)`, exit 1 each. Under the rule as written, the self-named cite becomes FLEET-ABSENT in the lone clone (INCOMPLETE, not UNRESOLVED). [INFERENCE from rule text and observed class; C2 is absent at BASE.] The control text (plans/round-25.md:53-55) names no self-named form, so this path is untested. Its expected `fleet_absent=88` (plans/round-25.md:52) counts the 42 lane-committed rows of bucket B as layout.
  Fix: resolve the fixed lane prefix `kagi-shokunin/` against ROOT before the class decision, using a constant (basename(ROOT) is `lane` in the lone clone). Keep `ufo` and other-lane tokens as fleet candidates. Add `kagi-shokunin/corpus/nope.md` to the controls. Expected lone result: `unresolved=0 fleet_absent=46`. [INFERENCE; the named-clone run applies this resolution and leaves exactly C+D.]

F2 (marker hazard). `$ROOT/../kagi-shokunin` is ROOT itself in a clone of that name, so a marker keyed on it cannot signal "lone". Measured with `test -e`: `$ROOT/../.ufo` = 0 fleet, 1 lone, 1 named; `$ROOT/../kake-shokunin` = 0 fleet, 1 lone. Key the marker on `$ROOT/../.ufo`.

F3 (counter caveat). `labeled=` is layout-dependent (25 lone / 18 named / 13 fleet): labelled path tokens count only while unresolved, so 12 of the 25 resolve in fleet. `cites=1371` and `docs=67` are invariant. Quote the layout with any `labeled` figure.

F4 (no real defect). Bucket A is empty. Bucket E is true dead (absent in fleet and lane) but labelled, so accepted by claim-ledger.sh:44-49. The fleet-layout gate is CLEAN (exit 0), so the C2 premise "fleet layout unchanged" holds at BASE.

## 6. Unrun, limits, next

- C2 is not implemented at BASE. Every post-change count above is [INFERENCE].
- `verify`/`cells` (R11-08 row) not run: forbidden on the real tree and outside this item. Installs or updates: none.
- Real-lane `git status` not run; lane git untouched. The real-lane doc set equals BASE (verified above).
- Fleet mirror construction (sandbox only): `git clone -q --no-hardlinks <sandbox>/lane <sandbox>/fleet/kagi-shokunin`, checkout BASE; `mv .../kagi-shokunin/.ufo .../kagi-shokunin/.ufo-clone`; `ln -s` real `.ufo` and `kake-`/`kama-`/`kotoba-shokunin` into `fleet/`.
- After C2, rerun: lone `citations` in `lane/` (expect `fleet_absent=88` as written, `46` with the F1 fix); fleet mirror (expect CLEAN, exit 0); planted `kagi-shokunin/corpus/nope.md` (expect UNRESOLVED, exit 1 in lone).
