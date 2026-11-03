# ReviewSD — attack on C1 (SELF_DESCRIPTION: CLEAN n=0), round-32 BUILD wave

Seat: reviewer, leaf. Scope: re-derive SD1–SD6 from the frozen plan wording only
(`plans/round-32.md`, commit 507dd9f), falsify the derivation, compare predicate
sentences, name SD1 false-positive classes. Lane files untouched; BASE measured in a
`git clone --shared` fixture detached at `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`
(toplevel asserted before any fixture mutation; zero commits made).

## 1. Verdict per check at BASE

Independent derivation (my own grep/awk, written from the plan's SD table before
reading any delivered script):

| check | mine at BASE | plan BASE | verdict |
|---|---|---|---|
| SD1 | **2** | 2 | holds — the single Frontier bullet PROVINCE.md:90 names both themes; Core bullets :88 (secret scanning) and :89 (OIDC workload-federation) hold both |
| SD2 | **2** | 2 | holds — corpus/README.md:117 and :118, exactly the plan's lines; `## Frontier` spans :111–:120 |
| SD3 | **0** | 0 | holds — all 7 distinct evidence tokens in SHONEN.md resolve (`corpus/claim-ledger.sh`, `corpus/lessons/round-19-recensus.md`, `corpus/op-ref-probe.sh`, `corpus/scope-gate.sh`, `LOG.md`, `PROVINCE.md`, `SKILL.md`) |
| SD4 | **1** | 1 | holds — named {M31-1..6} minus rowed {M31-1..5} = M31-6 (Corrigenda 2, round-31.md) |
| SD5 | **1** | 3 | **defect (frozen-plan BASE table, not the wording)** — see §2 |
| SD6 | **2** | 2 | holds — `CITATION_GATE: BROKEN (cites=1988 docs=84 unresolved=2 …)` exit 1; both lines lane-local (see §3) |

BASE sum: **8 measured vs 10 frozen** (2+2+0+1+1+2). The entire delta is SD5 (−2).

## 2. SD5 discrepancy (reported, not edited — the plan is frozen authority)

Plan wording: red ids on the `lane-status:` line (`R25-02,R29-01,R29-02`) "absent
from the latest `calibration` row of the latest `## Round` section".

- Latest `## Round` section = `## Round 31 — post-move …` (SCORECARD.md:1281; the
  last `^## Round` heading; file ends :1292).
- Its calibration row is :1285 (the only `| calibration` row in that section). It
  names `R29-01/R29-02` ("the summary stays `POLICY` while R29-01/R29-02 are
  operator-blocked") and does **not** name `R25-02` → absent count **1**.
- The plan's 3 matches only the Round-31 **pre-move** row (:1278, names none of the
  reds) — i.e. "latest Round section" read as the pre-move half, or a parser that
  stopped at the first round-31 section.
- The delivered counter agrees with the wording, not the table: it selects the
  first `^\| *calibration *\|` row of the last `## Round` section (self-description-sweep.sh
  SD5 block); first == only == :1285 → it must measure SD5=1 at BASE.
- Consequence: harmless for the claim. R5 lands a round-32 calibration row naming all
  three ids → SD5 1→0 (or 3→0 under the plan's reading); target n=0 reachable either
  way. But the frozen BASE table and the do-nothing control are off by 2: the control
  reads n=8, not n=10. Recommendation to the L1: keep the predicate untouched; record
  the BASE-table correction (10→8, SD5 3→1) in the round report as a plan-erratum,
  citing SCORECARD.md:1285.

## 3. SD6 measurement detail (honest bound)

`bash corpus/claim-ledger.sh citations` run inside the BASE fixture (read-only gate;
mode `citations` is in the script's own declared host-free args; no op, no writes):

- exit 1, `CITATION_GATE: BROKEN (cites=1988 docs=84 unresolved=2 ephemeral=0 labeled=20)`.
- The 2 UNRESOLVED lines: `corpus/lessons/round-30-verifier-spotcheck.md:41` and
  `corpus/lessons/round-31.md:121`, both citing the token `corpus/README.md:64/65/67`
  (the `:N/N/N` ref shape is not in the normalizer's line-ref grammar, so the token
  does not resolve — one of the two carries a stray backtick inside the token).
- Layout caveat: the fixture is a lone clone (`CITATION_LAYOUT: lone-clone
  fleet_absent=65`); 65 fleet-class tokens were skipped as FLEET-ABSENT, which by the
  gate's own rule are never counted as failed in a lone layout. So 2 is the complete
  lane-owned unresolved set at BASE; a fleet-layout run could only add lines if a
  fleet-resolvable path were itself broken — the plan's own 2026-11-03 lane-root
  observation (2) corroborates that it is not. base-run.txt (lane-root BASE run) is
  the layout-faithful confirmation; see §6.

## 4. Falsification (all three plants caught — derivation not defective)

Plants made with `edit` in the falsify fixture (still at BASE, dirty tree):

| plant | file | expected effect | measured |
|---|---|---|---|
| frontier theme line (`- **Frontier — planted…:** secret-scanning …`) | PROVINCE.md (new :93, inside the Core/Frontier/Adjacent section) | SD1 2→3 | **SD1=3** ✓ (L93 named) |
| moved-to-core tombstone (`… — moved to core in round 99.`) | corpus/README.md (new :121, inside `## Frontier`) | SD2 2→3 | **SD2=3** ✓ (L121 named) |
| missing M-row (deleted the `| M31-4 | seat stall |…` row; id still named in §Round shape and §Corrigenda 1) | corpus/lessons/round-31.md | SD4 1→2 | **SD4=2** ✓ (M31-4 rowless) |

SD3 stayed 0 and SD5 stayed 1 (plants did not touch those surfaces) — no cross-fire.
Derivation bug found in my own first pass and fixed before judging: the token regex
swallowed a sentence period (`corpus/op-ref-probe.sh.` → MISSING); after stripping
trailing punctuation SD3=0. The delivered script strips trailing `[.,;:]+` — same
guard. Receipts: sd-base.txt (first pass), sd-base2.txt (fixed BASE), sd-planted.txt.

## 5. Predicate identity (plan sentence vs delivered script)

Delivered copy reviewed: `.ufo/waves/round-32/build/sweep/self-description-sweep.sh`
(13.0 KB). `corpus/self-description-sweep.sh` does **not exist yet** at lane HEAD
(76241c0; `git ls-files` empty) — identity below is for the delivered build/ copy;
the committed counter must land byte-equivalent in the check bodies.

- **Sentence**: script's clean verdict is exactly `SELF_DESCRIPTION: CLEAN n=0`
  (exit 0), and the selftest asserts that exact last line on the clean fixture.
  n = `#HITS`, and every `HITS+=` is paired 1:1 with its `sdN` increment →
  n = SD1+…+SD6. **Same condition as the plan.**
- SD2, SD4: implementations are literal transcriptions of the plan wording (section
  bounds to next `## ` heading; `^\| <id> ` row test; distinct ids file-wide). Same.
- SD6: counts output lines beginning `UNRESOLVED` from the gate run inside the
  measured root; adds a SETUP (exit 2) guard when no `CITATION_GATE:` line is
  produced. Same condition at BASE (the gate's only uppercase-UNRESOLVED lines are
  the finding lines; the verdict line is lowercase `unresolved=`).
- SD3: equivalent at BASE; two bounded deviations: existence is `[ -e ]` (a
  *directory* named like a token would pass; SHONEN tokens are files) and token
  dedupe is per line (the same dead token on two lines counts twice; plan says
  "tokens", ambiguous). Neither can move BASE (0) or the plants.
- SD1: same count at BASE (2), but the **core-side trigger is weaker than the plan
  wording**: `case $line in *Core*)` accepts ANY line containing the substring
  `Core` — including the permanent section heading `## Core / Frontier / Adjacent
  (round 21)` (PROVINCE.md:83), which contains no theme. So `core_named` is
  effectively always 1: if a wrong-direction fix removed a theme from the Core
  bullets (:88/:89) while a Frontier bullet still named it, the script would keep
  firing (per plan wording it must still fire — the heading keeps it firing — but
  the plan's own condition would have gone false, i.e. the script cannot detect the
  fix was applied to the wrong half). Over-firing risk only, never under-firing;
  no effect at BASE or on R1's correct fix (which edits the Frontier bullet).
- SD5: script's selection (first calibration row of the last `## Round` section)
  equals the plan wording on the BASE tree (single candidate row :1285) and measures
  **1**, not the plan table's 3 — the script is consistent with the wording; the
  frozen table is the outlier (§2).

## 6. base-run.txt comparison (delivered during this review)

`sweep/base-run.txt` was 0 bytes (mid-write) at first check and landed (975 B) before
yield; no polling was done. Content: the delivered counter run at the lane root at
BASE, final line `SELF_DESCRIPTION: MISMATCH n=8 (SD1=2 SD2=2 SD3=0 SD4=1 SD5=1
SD6=2)`, exit 1 — **identical to my independent numbers on all six checks**:

- SD1=2 (both hits PROVINCE.md:90), SD2=2 (:117, :118), SD3=0, SD4=1 (M31-6 at
  round-31.md:214), SD6=2 (the same two lane-local citation lines) — all match.
- SD5=1, hit line names `SCORECARD.md:1285` — the executor's own BASE run confirms
  §2: the counter measures 1, the frozen table's 3 is the outlier. (Had base-run.txt
  printed SD5=3, it would have contradicted its own script's selection logic.)
- n=8 ≠ 0 with no edits → the do-nothing control holds; note it is 8, not the
  frozen table's 10.
- The SD6 lines here are the fleet-layout instance: still exactly 2 UNRESOLVED, so
  the lone-clone caveat in §3 is closed — no fleet-owned path adds unresolved lines.

## 7. SD1 false-positive answer (named lines)

At BASE exactly three PROVINCE.md lines match either theme ERE (case-insensitive):

- :88 `- **Core, round 30 — secret scanning, detection versus verification:** …` — Core bullet
- :89 `- **Core, round 31 — OIDC workload-federation trust policy:** …` — Core bullet
- :90 `- **Frontier — explored, not held:** OIDC workload-federation trust policy; secret-scanning …` — the true positive

The plan's clause "name a theme **in a `Frontier` bullet**" excludes :88/:89; a
derivation that drops the bullet-kind requirement fires on exactly those two lines
and reads 4 at BASE. No non-bullet prose line names either theme. Two adjacent traps
named for the record: (a) PROVINCE.md has **no `## Frontier` heading** — a
section-anchored SD1 false-negatives to 0; the bullet-label reading (`**Frontier`
prefix inside the `## Core / Frontier / Adjacent (round 21)` section) is the only
one consistent with the plan's BASE=2, and both my derivation and the delivered
script use it; (b) the delivered script's `*Core*` substring trigger (§5) can never
go false while heading :83 exists.

## 8. Commands run (exit codes)

| command (abbrev.) | exit |
|---|---|
| `git clone --shared …/kagi-shokunin base-clone`; `rev-parse --show-toplevel` == path; `checkout --detach 32c35fe…`; `rev-parse HEAD`; `status --porcelain` (0 lines) | 0 |
| `bash sd-derive.sh base-clone` (first pass, SD3 regex bug visible) | 0 |
| `bash corpus/claim-ledger.sh citations` (inside BASE fixture; SD6) | 1 (BROKEN unresolved=2 — expected at BASE) |
| `SKIP_SD6=1 bash sd-derive.sh base-clone` (fixed) | 0 |
| `git clone --shared … falsify-clone` + detach BASE (toplevel asserted) | 0 |
| `edit` plants ×3 (falsify-clone only) | 0 |
| `SKIP_SD6=1 bash sd-derive.sh falsify-clone` | 0 |
| `git -C <lane> ls-files -- 'corpus/self-description*'` | 0 (empty) |

No op contact beyond none at all (SD6 gate does not exec op; `op --version` not
needed by this seat). No tool installs (plain grep/awk/git/bash sufficed). No lane
file edited; both fixtures live in scratch and are deleted at seat exit.

## 9. Findings summary (severity)

1. **Defect (frozen-plan data, not wording): SD5 BASE=1, not 3** — SCORECARD.md:1285
   (Round-31 post-move calibration row) already names R29-01/R29-02; only R25-02 is
   absent. Plan BASE sum 10 → measurable 8. Target and kill rule unaffected. Record
   as plan erratum; do not edit the predicate.
2. **Latent defect (delivered script SD1 core side)**: `*Core*` substring trigger —
   heading :83 keeps `core_named` permanently true; a Core-bullet-side "fix" would be
   invisible to the check. Over-firing only; R1's fix path unaffected.
3. **Minor (delivered script SD3)**: `[ -e ]` accepts directories; per-line dedupe
   double-counts a dead token repeated on two lines. Dead at BASE.
4. **Process note**: `corpus/self-description-sweep.sh` not yet committed at HEAD —
   predicate identity verified on the delivered build/ copy; L1 should land the
   identical body.
5. **SD6 base-run caveat**: my 2 is a lone-clone measurement (65 FLEET-ABSENT
   skipped by design); the lane-root base-run.txt is the confirming instance.

Residual risk: none actionable in scope. Every SD1–SD6 acceptance verdict is above;
planted-mismatch result 3/3 caught; predicate sentence identical; false-positive
lines named (:88, :89; trap heading :83).

— ReviewSD, 2026-11-03
