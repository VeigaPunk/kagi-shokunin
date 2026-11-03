# CensusBase — independent re-derivation of every BASE fact in `plans/round-31.md`

Seat: CensusBase (kagi round-31 BUILD wave). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
read-only for this seat. No lane mutation, no network, no installs, no credential access.
Receipts: `.ufo/waves/round-31/base/` (6 named group files + 1 routed-items file).

## 0. Method and BASE identity

* Lane HEAD at measurement: `4767b045773607fc8ab4cb7ba2fea386e05b53c0` (plan commit).
* `git merge-base --is-ancestor 655e620651808ac04bb59bfa35b81227f62a031b HEAD` → true.
* `git diff --stat 655e620..HEAD` → 5 files, 239 insertions, all under `plans/` and
  `.ufo/waves/round-31/` (plan + census-start + 3 controls).
* `git diff --stat 655e620 -- corpus SCORECARD.md LOG.md SOURCES.md` → **empty**.
  ⇒ every number below is a fact of frozen BASE `655e620`, measured in the lane, not of a scratch clone.
* No `lsp` server serves markdown/shell payloads in this lane, so semantic symbol tracing does not apply;
  every claim here is a gate execution or an exact-text derivation, and the two places where I had to
  emulate a gate (cells population and per-cell pointers) are labelled as emulation and cross-checked
  against the real gate's own probe output.

## 1. Result table — declared vs measured

| # | Declared in `plans/round-31.md` | Measured (receipt) | Verdict |
|---|---|---|---|
| 1 | five debt headings with the exact old text listed in C1 items 1–5 | `SCORECARD.md:1018,1082,1110,1181,1239` — byte-identical incl. U+2014 (`base-headings.txt`) | **MATCH** |
| 2 | `claim-ledger.sh cells` → setup error on the Round-26 heading, exit 2, no `CELL_AUDIT:` | exactly that; 20 `LABELED-ID` lines then 1 error; byte-identical to `controls/cells-base.txt` (`base-cells.txt`) | **MATCH** |
| 3 | `sources-census.sh` → `CLEAN (rows=60 A=57 B=1 C=2 queued=1 mined=56 rejected=3 entries_sourced=8 legacy=21 captures=60 …)` exit 0 | all 13 counters identical, exit 0 (`base-census.txt`) | **MATCH** |
| 4 | legacy 21; registry rows 60; `corpus/knowledge/` has 0 `oidc` entries | 21 / 60 / 0 (`base-counts.txt`) | **MATCH** (derivation caveat F3) |
| 5 | `revision-audit --history c2cab35…` CLEAN added=36 exit 0; `row-identity scorecard-rounds` count=36 `1259a3e1…`; `revision-added` count=36 `2b86f032…`; `self-counts` POLICY policy=2 exit 2 | all four exact; the three ledger pins R22-03/R24-06/R24-15 resolve green in the lane (`base-rows.txt`) | **MATCH** |
| 6 | fleet `sources-census.sh validate … kagi` exit 0, 14 W04 allowed | exit 0, 14 W04, warning set identical to `census-start.txt` (`base-fleet.txt`) | **MATCH** |

Plan-declared supporting facts, also re-derived (`base-routed.txt`): D1 = exactly 11 uncommitted
`.ufo/waves/round-30/` paths; D2 `final/receipts/selfcounts-at-tip.txt` holds `stale=8`
(and `setup=1`); D3a `PYTHON_SCRIPT_RE` has no `feed-token-agree` entry (`corpus/claim-ledger.sh:263`);
D3b the CR-trim defect is at `scripts/sources-census.sh:581` exactly
(`function trim(s) { gsub(/^[ \t]+|[ \t]+$/,…) }`); `python3` 3.14.8, `op` 2.41.1 (version string only),
the-janitor absent in all three declared paths; the OIDC lead is present in `corpus/README.md:116` and
`corpus/SOURCES.md:100-102` and was introduced by round-21 commit `c41af82` ("since round 21" holds);
no sibling lane carries any `*oidc*` knowledge entry. C2's id space is clean at BASE: max lane id
`S060`, `S061–S071` hold 0 rows each, both staged entry names absent.

## 2. MUST-FIX / decision findings

### F1 — (MUST-FIX, claim accuracy) C2 says all 11 staged ids "collide with lane ids". Only 6 do.
Evidence: staged ids are `S052–S057 / S064–S065 / S092–S093 / S095` (11 rows, 8 under
`oidc-federation-trust-policy.md` + 3 under `cdp-bridge-1password-oidc-workflow.md`,
`SOURCES.append.md` lines 7–12, 19–20, 47–48, 50). Live lane rows exist for `S052–S057` (atom RFC 4287,
gitleaks, trufflehog, betterleaks, GitHub search API, trufflehog docs); `S064`, `S065`, `S092`, `S093`,
`S095` are **free** in `corpus/SOURCES.md` (`grep -E '^\| S064 \|'` → nothing).
The renumber to `S061–S071` is still correct and still required (the id follows the document, never
arithmetic), so the predicate's `+11` and the renumber map are unaffected — but the stated reason is
wrong for 5 of 11 rows. Recommend a one-line plan correction before the first work commit (QM29/QM14).

### F2 — (MUST-FIX, claim accuracy / W04 baseline) "11 distinct sources" overstates distinctness for 1–2 rows.
Evidence: `https://www.1password.dev/brokered-access` (staged `S092`) is already registered **three
times** — `S007`, `S019`, `S032`; `https://www.1password.dev/brokered-access/custom-workflow` (staged
`S093`) matches `S018`'s `…/custom-workflow/` modulo the trailing slash. The assimilation package's own
§"Rows whose source the lane's registry already holds" (`MERGE-REPORT.md:120-126`) names `S092` against
lane rows `S007/S019/S032` and asks the operator to state the aspect the staged row adds; the plan does
not record that statement. Consequences: (a) 9 of 11 URLs are genuinely new, so `rows 60→71` still
measures and the lane census does not gate URL duplication; (b) the **fleet** validate's W04 set will
grow past the 14-warning baseline after adoption (warnings only — exit 0 unaffected). Record the
added-aspect justification per the package's own checklist, or the "distinct" wording should move.

### F3 — (MUST-FIX for any re-derivation, seat-brief precision) the legacy count is `grep -L '^source:'`, not `grep -L legacy`.
`grep -L legacy corpus/knowledge/*.md | wc -l` → **29** (every entry lacks the literal word);
`grep -L '^source:' corpus/knowledge/*.md | wc -l` → **21**, which is the rule the census applies
(`corpus/sources-census.sh:337`) and the number `corpus/README.md:122` documents. The plan's 21 is
right; only the command spelling matters — a future seat reproducing `grep -L legacy` would report a
false 29-vs-21 mismatch.

### F4 — (decision, blocks C1's spirit) the content-preserving reshape cannot produce a red-free audit: 6 of the 30 never-audited cells carry no pointer.
Emulating `cells()` exactly (same section regexes, `AXES_RE` row filter,
`IDWORD_RE='[A-Za-z0-9_-]*R[0-9]+-[0-9]+[A-Za-z0-9_-]*'`, `norm_tok` order, exact-string `stamp_index`)
over the scorecard with the five headings treated as conforming gives:

```
cells 210 · row_pointed 147 · stamp_pointed 94 · uncited 6
UNCITED SCORECARD.md:1200 freshness    (Round 29)
UNCITED SCORECARD.md:1201 calibration  (Round 29)
UNCITED SCORECARD.md:1203 coverage     (Round 29)
UNCITED SCORECARD.md:1204 operability  (Round 29)
UNCITED SCORECARD.md:1247 depth        (Round 30)
UNCITED SCORECARD.md:1250 adjacency    (Round 30)
```

All four numbers reproduce, exactly, the real gate's own after-reshape output in
`.ufo/waves/round-31/build/cells-red-probe.txt` (`CELL_AUDIT: POLICY (cells=210 row_pointed=147
stamp_pointed=94 policy=2)` with the same six coordinates), so this is not an emulator artifact.
Why they are unpointed: R29's cells cite `S052` (a SOURCES id, not a ledger row),
`STABLE_TOKEN_RE`, `.ufo/waves/round-29/tools/c1-measure.py` (never stamp-registered), bare
`feed-token-agree.py` (`norm_tok` adds no `corpus/` prefix), `M29-*`, `QM30`; R30's two cells are prose.
Only `R29-01`, `R29-02`, `R30-01` rows exist for those rounds, and no `R28-*` row exists at all.
Repairing them means editing six evidence lines — which C1 forbids ("no table cell, score or evidence
line inside those sections changes"). So the plan is internally inconsistent: either allow a
QM14-recorded pointer-only edit (stamps `corpus/lessons/round-29.md`, `corpus/lessons/round-30.md`,
`corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/feed-token-agree.py` are all fresh and would resolve),
or let C1 honest-stop naming the six cells as the finding.

Note the branch order at `corpus/claim-ledger.sh:1249-1262`: `POLICY` is printed and exits 2 **before**
the `BROKEN` test on `CL_UNCITED`. So the after-state summary line will read `CELL_AUDIT: POLICY (…policy=2)`
while `uncited=6` — the frozen predicate's four greps (no setup error / one `CELL_AUDIT:` /
`FAIL|POLICY` ids ⊆ {R25-02,R29-01,R29-02} / zero `STALE-POINTER`) would **pass by the letter** even
though the kill rule's "uncited/missing-id class" is present. A verifier grading the predicate alone
would call C1 green; the kill rule says otherwise. The L1 must resolve this explicitly rather than let
the two readings diverge.

## 3. Two more things the L1 should know before landing C1

* **All 35 parsed round sections carry the six axes exactly once** (independent emulation of
  `section_check`, `dying` on any missing/duplicate axis): 35/35 conform, including the five sections
  being reshaped (6 cells each, 30 total). So the reshape will not die in `section_check`, and the
  population floor is exact: **210 cells** = the plan's `cells ≥ 210`.
* **The SCORECARD stamp is currently fresh** (`corpus/stamps.tsv` digest `f4eb6ec4…` equals
  `sha256sum SCORECARD.md`, 1252 lines / 134670 bytes), so any byte change in the reshape *necessarily*
  makes it stale; the re-pin in the same landing is causal, not cosmetic. The stamp-cited paths inside
  R26–R30 (`corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/eol-sweep.sh`,
  `corpus/knowledge/feed-token-boundaries.md`, `corpus/lessons/round-26.md`, `corpus/lessons/round-28.md`,
  `corpus/release-clock.py`, `corpus/sources-census.sh`) are all fresh at BASE — no pre-existing
  STALE-POINTER lurks in the never-audited sections besides the scorecard's own coming re-pin.

## 4. Remaining unknowns (not derivable read-only at BASE)

1. After-state of any gate (by definition): the census's `71/10/21/71`, the audit's final summary, the
   fleet exit after adoption.
2. Whether the identity-row migrations (R24-06 / R24-15 / R22-03) will be *green* rather than merely
   re-pinned at the tip — depends on the round's own file set; BASE only proves they are green now and
   that they measure exactly `36`.
3. Whether the C2 adopters will collapse the staged `source:` headers correctly: the staged entries carry
   **8** and **3** `^source:` lines (census allows ≤1, `SC_ENTRY_HEADER`), `verified-at: 2026-10-23`
   (must become `2026-11-03`), prose `recheck:` cells, and **no `Reverify:` line** in either file — the
   plan's per-entry contract requires the last one to be added.
4. Whether the round-31 sections themselves can be made audit-clean (plan C1 kill rule, premise only
   knowable after they are written).

## 5. Receipt index

| file | group |
|---|---|
| `base/base-headings.txt` | five debt headings + parser-shape proof + provenance |
| `base/base-cells.txt` | `claim-ledger.sh cells` full output, exit 2, control diff, 210-cell population and 6-UNCITED emulation |
| `base/base-census.txt` | lane census CLEAN line, exit 0, field-by-field table, cross-checks |
| `base/base-counts.txt` | legacy 21 / rows 60 / oidc 0, id space `S061–S071`, staged id collision split, URL overlap |
| `base/base-rows.txt` | revision-audit, both row-identity digests, the three ledger pins, self-counts, stamp freshness |
| `base/base-fleet.txt` | fleet validate output, exit 0, 14 W04 vs census-start |
| `base/base-routed.txt` | D1 11 paths, D2 `stale=8`, D3a/D3b sites, host declaration, frontier provenance, sibling sweep, staged-header constraints |

Scratch used only at `/fast/scratch/hyaku/kagi-r31/CensusBase/` and deleted before yielding.
No tool was installed or upgraded; no network access was made; no lane or fleet file was modified.
