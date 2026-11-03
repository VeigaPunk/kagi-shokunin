# CAttackPredicates — round-30 predicate falsification (pre-data)

Date 2026-11-03 · seat CAttackPredicates (critic, leaf) · judged on calibration/freshness/coverage.

Method: BASE verified — plan commit `b7482b4` diff vs frozen `f67232c` adds ONLY `plans/round-30.md` + `census-start.txt` (diff --stat), worktree tracked-clean, so production bytes ≡ BASE. All experiments ran in scratch `/fast/scratch/hyaku/kagi-r30/CAttackPredicates/` (lane extracted via `git archive HEAD | tar -x`), removed after receipts were copied to `final/attack-pred/`. No lane production file touched; no installs (none needed); no pacman; no vault/credential contact; CRLF-boundary claims untouched.

## Controls (a): committed reds reproduce at BASE

| Instrument | Frozen expectation | Measured | Match |
|---|---|---|---|
| `census-start.txt` receipt | E12 ×52, exit 1 | 52 E12 lines (S001–S052) + `census exit=1` | ✓ |
| fleet census `validate --root … kagi` | exit 1, E12 ×52 | exit 1, 52 E12 | ✓ |
| `python3 corpus/self-counts.py` | exit 2, "six STALE cells" | exit 2, **stale=8** | ✗ count (F1) |
| `bash corpus/claim-ledger.sh verify` | 13 FAIL + 2 POLICY, `CLAIM_LEDGER: POLICY` | exit 2, exactly 13 FAIL, POLICY R29-01/R29-02 `first-token:python`, `CLAIM_LEDGER: POLICY (claims=67 policy=2 stamped=94)` | ✓ |
| `bash corpus/checklist-run.sh --ratio` | SETUP exit 2 | exit 2, `SETUP no '## Credential-hygiene checklist' … SKILL.md` | ✓ |
| `bash corpus/sources-census.sh` (lane; R21-02's command) | exit 0 over CRLF, number-only mismatch | exit 0, `SOURCES_CENSUS: CLEAN (rows=52 A=50 B=0 C=2 queued=1 mined=48 rejected=3 entries_sourced=5 legacy=21 captures=52 inrow=16 inrow_only=0 inrow_nonreproducing=12)` | ✓ |
| C3 counter 1 grep / counter 2 ls | 0 / absent | 0 / all 3 absent | ✓ |

Do-nothing control holds: no frozen after-state is reachable without the claimed deltas.

## Verdicts

### C1 calibration — predicate SOUND (control + separability proven); 2 corrections REQUIRED before work commit

- **F1 — frozen text miscounts the control.** BASE stale set is **8**, not six: SC-SKILL-STAMPS 91→94, SC-SKILL-CLAIMS 65→67, PV-STAMPS 91→94, PV-CLAIMS 65→67, RD-LEDGER-ROWS 65→67, RD-STAMPS 91→94, **RD-DOCS-ROWLINKED 22→23, RD-DOCS-ENTRIES 25→26**. The two extra cells belong to R14-01's own migration (already in the twelve), so coverage is complete — but the frozen "six STALE cells" understates the committed control. Correction: "eight STALE cells (six routed doc cells + RD-DOCS-ROWLINKED/RD-DOCS-ENTRIES under R14-01)".
- **F2 — R25-02 is an unowned red inside C1's own gate.** Ledger row R25-02 = `python3 corpus/self-counts.py` expecting `^SELF_COUNTS: CLEAN \(claims=60 stale=0\)$`; live is claims=62; it FAILs at BASE (`exit-mismatch 2≠0`) and appears in NO claim: the twelve enumerate 10 migrations + R29-01/R29-02; R11-08 is triaged in Honesty constraints; R25-02 is nowhere in round-30.md. Internal inconsistency: C1's frozen counter writes `CLEAN (claims=N stale=0)` with N free — it can pass at claims=62 while R25-02 still FAILs at claims=60. Smallest fix: add R25-02 to C1's migration set (60→current, old→new recorded) or triage it in the plan corrections before the first work commit.
- **(b) Gameability.** Cheapest cheat: edit claimed cells in `self-counts.tsv` (and ledger expect cells) straight to live values with no old→new record → `self-counts.py` CLEAN, twelve re-runs pass. The kill rule catches semantics changes and still-failing rows only; the record-and-reason clause is prose, mechanically unenforced. Arithmetic SOUND; record clause rests on honesty + reviewer seats. Optional mechanical mitigation: one `old→new` line per migrated id in the lesson, greppable in the same counting pass.
- **(c) Separability — PROVEN, not asserted.** CR-stripping exactly the three C2 files in scratch leaves the self-counts STALE set byte-identical (8 cells, same values); the only delta is `SETUP KN-CHECKLIST-FALSIFY-FLOOR ledger:R15-05` clearing — that row is C2's own counted surface. R21-04's `grep -cE '^R[0-9]+-[0-9]+'` is CR-insensitive. Sequencing hazard (not separability): R21-02's expect is a FULL-LINE snapshot (`rows=51 A=49 … entries_sourced=4 captures=51`) and R21-04 pins row count — both move again when C3's 8 rows and R30-01 land (51→60; 67→68). "Independent of whether C3 landed" is true of the mechanism, FALSE of the value; measured-revision discipline is load-bearing — capture pins after ALL claims land.
- **(d) Universal "every drifted pin".** Machine-visible drift is enumerated by stale=0 + twelve named rows — but F2 shows the enumeration incomplete today, and the record clause has no enumerating command.

### C2 freshness — predicate ATTACKED (counter 2 unsatisfiable as frozen; recurrence gate ungated)

- **F3 — frozen counter 2 can never print 0.** Measured: pristine checkout (git archive) = **135** CR files (132 under committed `.ufo/` receipts: round-26/27/28 curl `--dump-header` captures are CRLF by RFC 7230 — correct evidence bytes, not drift — plus round-29 final/*.json and retained-probe node_modules files) + exactly the 3 production files; live lane root = **166** (163 under `.ufo/` incl. untracked round-30 wave files). The command excludes only `.git/.jj`. "before: 3" holds only under a `.ufo`-excluding scope; after honest repair the count stays >130 forever, so R30-01 would be BORN permanently red — `claim-ledger.sh verify` could never return CLEAN again, poisoning every future round — and the only mechanical paths to 0 are destructive cheats (strip/delete retained-probe evidence): exactly the "cells deleted instead of corrected" class. **Fix (freeze THIS form as R30-01):** `git ls-files -z | grep -zv '^\.ufo/' | xargs -0 grep -lI $'\r' | wc -l` → before 3, after 0. Triangulation then closes: SOURCES.md CR → counters 1+2; SKILL.md CR → counters 2+3; claim-ledger.tsv CR → counter 2.
- **F4 — counter 1 cheat demonstrated.** One inserted LF `## Registry` line above the still-fully-CRLF table → fleet census **exit 0** (W04 warnings only; "warnings allowed" per the frozen counter); lane census stays CLEAN. Zero byte repair on SOURCES.md. Closed automatically by F3's fix (SOURCES.md still counts ≥1 CR file).
- **F5 — counter 3 SOUND.** On the LF-repaired scratch tree: exit 0 with EXACTLY `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`, byte-identical to R15-05's ledger expect. The exact-string pin makes checklist.tsv reclassification self-defeating; honest repair (unchanged checklist.tsv + LF SKILL.md) is the only path.
- **F6 — ungated universal.** The after-state includes `.gitattributes` (`eol=lf`) "so the conversion cannot recur silently" — NO frozen counter checks the file or attribute; a round can repair bytes, skip the convention, pass all three counters. Kill rules cover E12-persistence and renormalization blowup, not absence. Fix: fold an attribute assertion into R30-01's command (`git check-attr eol -- SKILL.md corpus/SOURCES.md corpus/claim-ledger.tsv` ⇒ `eol: lf` each) or add R30-02; R21-04's pin must then anticipate 68 rows at measured revision.

### C3 coverage — predicate ATTACKED at content level (cheap fix); shape machinery otherwise sound

- **Controls:** measured 0 / 3-absent / lane-census CLEAN rows=52 at BASE. Staged package confirmed: `SOURCES.append.md` carries S066–S073; the three knowledge files exist in `merge/kagi/knowledge/`.
- **F7 — the counting set passes with zero admitted knowledge (simulated).** Empirically: 8 staged rows renumbered per the frozen map (S066→S053 … S073→S060) + 3 EMPTY knowledge files → counter 1 = **8**, counter 2 = **3**; the census counter correctly FAILS — `SC_USEDBY_NOCITE` (the reverse used-by handshake exists and catches empty files) and `SC_MALFORMED nf=14` (staged rows S058–S060 are NF=14 raw — the plan's "normalized to fleet schema" step is real and machine-enforced ✓). But the pass-configuration degrades to **stub entries**: a ~5-line file (`source: S05x` + `verified-at:` + `recheck:` + one copied sentence) closes SC_ENTRY_HEADER/SC_ENTRY_CITE/SC_USEDBY_NOCITE, and SC_FETCH accepts provenance whose identity digest is sha256 over (id, status, URL) computed by the checker from the same files (census lines 258–263) — self-computable by a fabricator; staged rows carry no in-row fetch digest (0 × `Fetch sha256:` in SOURCES.append.md). Net: all three frozen counters green with stub entries + shape-valid rows + fabricated-but-well-formed fetch rows — no re-opened source, no located quote, no detection-vs-verification content. Nothing mechanical measures content provenance; the kill rule governs entries that are gate-checked, and stubs are. **Smallest fix:** pin `entries_sourced=8` (live BASE = 5) in counter 3's expected CLEAN line — forces the three files to be sourced entries with a passing handshake. Cheap hardening: count used-by exactness (each of S053–S060 names exactly its citing admitted entries) and/or count in-round-dated fetch rows for the 8 ids.
- **(c) Separability — PROVEN.** Counter 1's pattern never reaches EOL (CR-insensitive); counter 3's census CR-strips (exit 0 measured over CRLF at BASE and post-strip); no C1 value is read. Only interaction: R21-02's snapshot pin (see C1).
- **(d) Universal "every cited source re-opened this round"** and the per-document renumber map are prose-only — no enumerating command (see F7 hardening).

## Summary

| Claim | Verdict | Blocking items |
|---|---|---|
| C1 | SOUND (arithmetic + separability proven) | F1 text correction; F2 add/triage R25-02 — both before work commit |
| C2 | **ATTACKED** | F3 re-scope counter 2 (R30-01 form) — without it the row is permanently red; F4 closed by F3; F6 gate the .gitattributes |
| C3 | **ATTACKED** (content level) | F7 pin `entries_sourced=8` in counter 3's expected line; hardening optional |

Amendment list for L1 (plan allows corrections appended before the first work commit; nothing has landed): (1) F1 wording; (2) F2 R25-02; (3) F3 frozen counter-2 form; (4) F6 attribute assertion (+R21-04 pin anticipation); (5) F7 `entries_sourced=8` pin; (6) integrator note: R21-02/R14-01 snapshot pins and R21-04 row count captured only at the measured revision AFTER C3 and R30-01 land (51→60; 65→67→68).

Tooling: no installs/upgrades performed (none required); pacman untouched. Scratch `/fast/scratch/hyaku/kagi-r30/CAttackPredicates/` removed after receipts landed in `final/attack-pred/` (self-counts base/after-strip, lane census, checklist base/after-LF, ledger verify, fleet census base/heading-cheat, cr-counts, c3-cheat-sim).
