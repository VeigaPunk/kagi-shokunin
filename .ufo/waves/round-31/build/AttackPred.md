# AttackPred — pre-data attack on the round-31 frozen predicates

Seat: AttackPred (godspeed, leaf, no subagents). Scope: attack C1 and C2 predicates and their counting commands before data lands. No scope widening proposed.

## Pre-data state (verified)

- Lane HEAD is `2d46e57` ("round-31: plan correction 1 (migration set 3->10; R11-08 predicate exception) — pre-data"), on top of `4767b04` (plan + START census + BASE controls) and `655e620` (BASE).
- No work commit exists after the plan commit. Corrections are still legal under the plan's own rule ("appended before the first work commit").
- I attacked the corrected contract: plan correction 1 (`2d46e57`, 29 added lines) is read in full below. I did not find it in my first pass, because it landed after my first `git log`; my first pass had read the `4767b04` text.
- Scratch: a `git clone --shared` of the lane at `4767b04` under `/fast/scratch/hyaku/kagi-r31/AttackPred/`. Used only for experiments. Deleted before this yield. The lane was not written to. No installs, no credential or vault contact, no network. `pacman` untouched.

## Verdict summary

| ID | Claim | Verdict | One line |
|---|---|---|---|
| F1 | C1 | MUST-FIX | Frozen grader is green with six UNCITED cells present; kill rule says that is lane-owned red. |
| F2 | C1 | MUST-FIX | `cells >= 210` is in the prose but not in the counting command; a silently dropped section passes. |
| F3 | C1 | MUST-FIX | FAIL/POLICY grader is set equality, prose says subset; honest fixes to routed ids turn the grader red. |
| F4 | C1 | MUST-FIX | Stamp re-pin list omits `corpus/claim-ledger.tsv`, which the identity migrations force to move. |
| F5 | C1 | MUST-FIX | Correction 1's R11-08 exception rests on a premise cells mode does not exhibit, and it is unbound. |
| F6 | C1 | NOTE | Migrations must be measured after the last SCORECARD/ledger/stamp write, including round-31 headings. |
| F7 | C1+C2 | NOTE | "Causally separable" is false as written; correction 1 closes the numeric coupling but the sentence stays wrong. |
| F8 | C2 | MUST-FIX | Tier-A, date, and body-id clauses are ungraded; census reads only the `source:` field. |
| F9 | C2 | MUST-FIX | JP product page S095 self-declares "flip to C"; census accepts A+C co-citation; predicate says tier-A only; kill rule is silent. |
| F10 | C2 | MUST-FIX | Re-freeze path is open (no work commit). Correction 1 covers C1 only; C2 needs its own correction before the first work commit. |
| F11 | C2 | NOTE | `legacy=21` is a count, not a content check; the 21 files are outside every census check. |
| F12 | C2 | NOTE | `rows=71` counts ids, not identities; a silent substitution inside S061–S071 keeps the counts. |
| F13 | C1 | NOTE | 12 HOST-SKIP and 5 SKIP-SELF rows are not re-run and invisible to the grader. |
| F14 | C1+C2 | (control, passes) | Both BASE controls distinguish: a do-nothing round cannot reach either predicate. |
| F15 | C1 | (shape check, passes) | No output shape makes an honest run fail. Verdict-not-final on R24-06 was a real digest mismatch. |

## C1 findings

### F1 — MUST-FIX — UNCITED cells pass the frozen counting command

Evidence (scratch clone at `4767b04`): applied the five frozen heading rewrites (exact `sed` lines, `git diff --stat` = 5 insertions / 5 deletions, SCORECARD.md only), recomputed R22-03, R24-06 and R24-15, and re-pinned the stamps for `SCORECARD.md` and `corpus/claim-ledger.tsv`. Then ran the frozen grep set on the receipt:

- `unrecognised round heading` = 0 (pass)
- `^CELL_AUDIT:` = 1 (pass)
- FAIL/POLICY ids = `R25-02 R29-01 R29-02` (pass)
- `^STALE-POINTER` = 0 (pass)
- **`^UNCITED` = 6** (not graded)

The six: `SCORECARD.md:1200` freshness, `:1201` calibration, `:1203` coverage, `:1204` operability (Round 29 table), `:1247` depth, `:1250` adjacency (Round 30 table). They carry no row id and no stamped path.

Why the grader cannot see it: in `corpus/claim-ledger.sh` the POLICY branch exits (`CELL_AUDIT: POLICY`, lines 1251–1253) before the BROKEN branch that would report `uncited` (lines 1255–1258). A run with POLICY present never reports the uncited count in its summary.

Why the claim cannot repair it: the kill rule names "an uncited/missing-id class" as lane-owned red. The scope forbids editing those cells ("No table cell, score or evidence line inside those sections changes"). So the only honest outcome for these six is honest-stop. The frozen predicate does not say that.

Fix, before data: the counting command adds `grep -c '^UNCITED'` = 0 and `grep -c '^MISSING-ID'` = 0. State that UNCITED > 0 is an honest-stop for C1, not a repair. Correction 1 (`2d46e57`) does not address this.

### F2 — MUST-FIX — `cells >= 210` is not graded; a silently dropped section passes

Evidence (scratch): renamed the Round 27 heading to H3 (`### Round 27 — post-move (…)`) after a non-round H2 (`## Notes`). Result: exit 2, `CELL_AUDIT: POLICY (cells=204 row_pointed=141 …)`, no error. The frozen grep set has no term that reads `cells=`, so this receipt passes it: unrecognised = 0, CELL_AUDIT = 1, FAIL/POLICY set unchanged, STALE = 0.

Control (scratch): the same H3 heading placed directly after a round H2 is loud: `scorecard section '## Round 26 …' does not carry all six axes exactly once (found=12 …)`.

Why it is silent: `SECTION_RE` (`^ {0,3}##[[:blank:]]+`) and `ROUND_RE` both require `##`. An H3 round heading matches neither, so `in_set` stays 0 after a non-round H2 and its rows are never counted. The silent case is exactly "H3 round heading after a non-round H2".

Fix, before data: the counting command reads `cells=` from the `CELL_AUDIT` line and requires it to be at least 210 (exactly 210 at the measured tip). Note for the operator, not this round: the parser should reject any H3+ heading matching `Round [0-9]+`. That is a gate-semantics change, so it is out of this round's scope.

### F3 — MUST-FIX — FAIL/POLICY grader is set equality; prose says subset

Prose: "every FAIL/POLICY row line it prints is exactly one of the three operator-routed ids". Grader: `sort -u` equals `R25-02 R29-01 R29-02`, which is set equality. Correction 1 widens the allowed set to four ids and still says "exactly".

Consequence: an honest fix to a routed id turns the frozen grader red. Examples: `R25-02` repaired, or the D3 operator registration of `feed-token-agree` in `PYTHON_SCRIPT_RE` removing the R29-01/R29-02 POLICY lines. Both are honest and both fail the frozen grep.

Fix: require every printed FAIL/POLICY id to be a member of the allowed set (`comm -23` of printed ids against the allowed set is empty). Equality is not required.

### F4 — MUST-FIX — the stamp re-pin list omits `corpus/claim-ledger.tsv`

The plan names only the `SCORECARD.md` stamp re-pin. The three identity rows (and the correction-1 migrations) edit `corpus/claim-ledger.tsv`, which is itself stamp-pinned.

Evidence (scratch): after the ledger migration, the grader reports `STALE-POINTER corpus/claim-ledger.tsv sha=23363843b898->1eb02de7d4c1 lines=86->86 bytes=31289->31303`. Re-pinning that stamp row (sha, lines, bytes) cleared it. The ledger had to be re-pinned twice in scratch because a second migration edit moved it again.

Answer to the kill-rule question (d):

- The three named identity rows are claim rows; they produce FAIL lines, not STALE-POINTER.
- STALE-POINTER comes from `corpus/stamps.tsv` byte pins. The only stamp rows that cover the five headings are `SCORECARD.md` (stamps.tsv:3). `corpus/fixtures/cells-hermetic/SCORECARD.md` (stamps.tsv:23) is a fixture and unaffected.
- So the sufficient set is: re-pin `SCORECARD.md` and `corpus/claim-ledger.tsv`, both measured after the last edit to either.

Fix: list both re-pins with old→new in the lesson's Migrations section, and state the ordering.

### F5 — MUST-FIX — the R11-08 exception rests on a premise cells mode does not exhibit

Correction 1, item 2, says R11-08 "reads FAIL at the measured revision" in `cells` and adds it to the allowed set.

Evidence: R11-08 is `bash corpus/claim-ledger.sh citations` (ledger row R11-08), a self-invoking gate. Cells mode skips self-invoking rows: `SKIP-SELF R11-08 (row invokes this gate; not re-run from inside the cell audit)`, which the L1's own probe receipt `build/cells-red-probe.txt` shows. The row can never print FAIL in cells mode.

Consequence: the exception is unnecessary for the predicate. As worded it is a standing allowance: any printed `FAIL R11-08` on the measured receipt matches the allowed set, the reason is not bound, and the "confirmation re-run after report filing" is not in the counting command.

Fix: strike correction-1 item 2. If the premise is a verify-mode or fleet-layout FAIL, it is outside C1's counter and belongs in the lesson, not the predicate.

### F6 — NOTE — migration measurement order; round-31 headings are scored cells

Correction 1 says the round's own `## Round 31 — pre-move/post-move` headings land from their first commit. R13-01 counts every `^## Round ` line (36 at BASE). R24-06's digest covers heading text. So both move when the round's own sections land, and those new sections become scored cells that need pointers; an UNCITED cell there breaks C1 as well.

Fix: state that the correction-1 migrations are measured after the last write to SCORECARD.md, the ledger and the stamps, and that the round-31 cells carry pointers.

### F7 — NOTE — the "causally separable" sentence is false; correction 1 closes the numeric coupling

Plan: "C1 touches only SCORECARD.md headings, the claim-ledger pins/stamps and its own gate … either verifies without the other."

Measured coupling from C2's landing:

- The two new knowledge entries are new files, so `corpus/knowledge` grows. Every knowledge file must carry a `Reverify:` line (`undeclared` in the docs audit, claim-ledger.sh:1145). The staged entries carry zero, so each must add one: R14-01 `entries` 29 → 31.
- R21-02 `rows` 60 → 71 and `captures` 60 → 71. R21-02 is cited by round-30 cells (`SCORECARD.md:1245`, `:1246`).
- R22-03 and R24-15 count added paths. The two new files and the round-31 lesson are added paths. R24-15's own note records round 30 moving the count 28 → 36 by adding files.
- R21-04 and R24-14 move if the new `Reverify:` declarations point at new ledger rows.

Correction 1 covers all of these, so the numeric coupling is closed. The sentence still states the opposite. Fix: strike "either verifies without the other" and state that C1's final migrations are measured after C2's files land.

## C2 findings

### F8 — MUST-FIX — tier-A, date and body-id clauses are ungraded; census reads only `source:`

Predicate: "both entry files cite only adopted `mined` tier-A rows whose `opened` is `2026-11-03`." Counting command: census CLEAN plus the S061–S071 count. Neither checks the clause.

- Census extracts ids only from the `source:` field (`corpus/sources-census.sh:151` `src_field`; `ids=$(grep -oE … "$field")`). Body text is never scanned.
- Census accepts an entry whose co-cited ids include any A or B row (`case ${TI[$id]-} in A|B`). A tier-C co-citation passes CLEAN.
- No census check of `opened`. Staged rows and entries carry `2026-10-23`.

Staged text, read in the shokuknow package:

- `cdp-bridge-1password-oidc-workflow.md` line 57 (body): `[round-1 S057]`. In the lane, S057 is the TruffleHog "Verification caching" row (`corpus/SOURCES.md:64`). After renumber this stale id names a different source. Line 57 also cites `[S092]`, which dangles: the lane registry ends at S060 and the adopted range is S061–S071.
- `oidc-federation-trust-policy.md` body lines 88 and 91 cite S012, S022, S047, S050. These are lane rows, not among the eleven adopted ones. A literal reading of "cite only adopted rows" fails on the staged text.
- `source:` line counts are 8 (oidc) and 3 (cdp). Census flags more than one `source:` line (`SC_ENTRY_HEADER`). The plan's collapse to one line is correct; the grader should check it.

Fix, before data: the grader adds (i) `opened` = `2026-11-03` for every adopted row, (ii) every S-id in each entry's full text is in the adopted set or is an explicitly named lane body reference, with tier A, (iii) `grep -c '^source:'` = 1 per entry, and (iv) no `S092` or `round-1 S057` string survives.

### F9 — MUST-FIX — S095 tier flip is unhandled

Staged row S095 (JP product page) reads `tier A`, and its note says "tier=A holds only for the Japanese terminology, flip to C if the ja path lags the en path". The cdp entry's only Japanese-language source is S095 (its line 4).

Census accepts A+C co-citation as CLEAN. The predicate says tier-A only. The kill rule has no clause for a tier flip. So an honest flip gives CLEAN census plus a predicate violation, and a quiet reliance on S095 would pass unnoticed.

Fix: add a kill-rule clause: a flip to C removes S095 from the entry, the counts re-freeze (rows 70), and the re-freeze happens in a correction before the first work commit. Alternatively, the grader checks each cited id's tier.

### F10 — MUST-FIX — the C2 re-freeze path is open, but correction 1 covers C1 only

Mechanism: correction 1 (`2d46e57`, "pre-data; appended before the first work commit") is exactly the legal path, and no work commit exists yet. The C2 changes (F8, F9, F11, F12, and the counts) need a second plan-only correction by the L1 before any work commit. The dispatched build-spec and build-dispatch pin `4767b04`; the correction text should say it supersedes them for C2.

### F11 — NOTE — `legacy=21` is a count, not a content check

Census states (`corpus/sources-census.sh:91–93`) that legacy entries are "outside every check … the credential scan included". Constancy at 21 proves only that 21 files still lack a column-1 `source:` line. Editing a legacy file keeps the count at 21. Fix: record a per-file hash list of the 21 legacy files at START and END.

### F12 — NOTE — `rows=71` counts ids, not identities

The grep `S(06[1-9]|07[01])` counts ids. Refusing one of the eleven and adding a different row with a fresh id keeps `rows`, `entries_sourced` and `captures` unchanged, so the predicate passes. Fix: the grader compares the eleven frozen URLs against the S061–S071 rows.

### C2 controls (F14 — passes)

Re-run read-only in the lane: `SOURCES_CENSUS: CLEAN (rows=60 A=57 B=1 C=2 queued=1 mined=56 rejected=3 entries_sourced=8 legacy=21 captures=60 …)` exit 0; `grep -cE '^\|…S(06[1-9]|07[01])…' corpus/SOURCES.md` = 0; `DOC_AUDIT: CLEAN (entries=29 … undeclared=0 …)`. A do-nothing round yields rows 60 and entries 8, so the predicate fails. The controls distinguish.

## Remaining C1 items

### F13 — NOTE — silent host and self skips

Probe receipt, and my scratch run: `HOST-SKIP` = 12 (R11-01…04, R11-06, R12-01, R13-03, R15-01, R16-01, R16-03, R17-01, R18-01) and `SKIP-SELF` = 5 (R11-08, R11-09, R14-01, R18-03, R23-01). Those 17 rows are never re-run, and the POLICY summary does not carry `host_skipped`. Expected with the-janitor absent, but the receipt should state it, e.g. `host_skipped=12 self_skipped=5` as expectations.

### F15 — NOTE — no output shape makes an honest run fail

The awk extraction on the probe receipt gives exactly the expected ids. `LABELED-ID`, `HOST-SKIP` and `SKIP-SELF` lines do not match the grep. The `verdict-not-final` on R24-06 in the probe was a real digest mismatch, cured by migration; it was not a format artifact. C1 control (F14, passes): the BASE control reproduced in scratch at `4767b04` with `claim-ledger: unrecognised round heading … '## Round 26 — bounded release-drift response'` and no CELL_AUDIT line, so a do-nothing round cannot reach the C1 predicate.

## Checklist for the L1 before the first work commit

1. Add the counting terms: `UNCITED` = 0, `MISSING-ID` = 0, `cells=` ≥ 210 (F1, F2).
2. Replace set equality with membership (F3). Strike correction-1 item 2 (F5).
3. Stamp re-pins: `SCORECARD.md` and `corpus/claim-ledger.tsv`, last (F4, F6).
4. Strike "either verifies without the other" (F7).
5. C2 correction 2: date, body-id and single-`source:` grader terms; S095 flip rule; the eleven-URL check; legacy hash list (F8–F12).
6. Land both corrections as plan-only commits before any work commit (F10).
