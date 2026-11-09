# Corrections sweep — places that become stale or false if round 71 lands

Read-only, against the candidate `39e76bc` working tree (SCORECARD.md with its uncommitted
insertion). Counts are in `counts-readonly.txt`. Severity: **S** = stale or false at landing
(must change in the integration); **P** = already stale before round 71 (the gate reads it; carried
unless the integration fixes it); **N** = new item the round needs; **O** = optional.

## corpus/README.md

1. **S — line 65, `Revision stamps (data)`**: `177 rows`. Live at candidate: 178 data rows (+1, the
   new entry). The trial `corpus/openbao-pki-issuer-trial.sh`, the counter `plans/round-71-c1.sh`,
   the controls runner `plans/round-71-controls.sh` and `plans/round-71.md` have **no** stamp rows
   (`stamps_mentioning_round71_or_trial: 0`). The round-70 pattern pinned the entry, the trial, the
   counter and the runner. See item N1. Bound by `RD-STAMPS`.
2. **S — line 67, `Knowledge-entry declarations (data)`**: `47 row-linked / 3 by-hand / 50 pinned`.
   Live: 51 entry files; the new entry is row-linked to `R21-02`, so 48 / 3 / 51. Bound by
   `RD-DOCS-ROWLINKED`, `RD-DOCS-BYHAND`, `RD-DOCS-ENTRIES`. The gate's own number is
   `claim-ledger.sh docs` (`DOC_AUDIT … entries=… row_linked=… by_hand=…`), not this grep.
3. **S — coverage map**: a new row after line 95 (readme-row.md §1).
4. **O — `Source registry` row (line ~107)**: no count, nothing stale.

## SKILL.md

5. **P — line 46, `Re-run a claim …` row**: `(164 stamps + 101 claims + claim ids …)`. Already
   stale at round-70 landing (self-counts `SC-SKILL-STAMPS`, `SC-SKILL-CLAIMS`; `SELF_COUNTS: POLICY
   … stale=4` with the same four ids at BASE, per the round-70 spot-check). After round 71 the live
   numbers are 178 stamps and 102 claims (claims unchanged). Fix in the integration, bound to the
   gate's own output, or carry and name it.
6. **S — lines 52–55 (round-70 PKI rows)**: still true. Line 55 says `no_store=true` is never used on a
   leaf that may need revoking; the new row (skill-rows.md row 4) refines it and says so.
   No line needs rewriting.
7. **N — decision table**: four rows to insert after line 55 (skill-rows.md). SD8 (no `M<r>-<n>..`
   token in SKILL.md) and SD1/SD2 (no Frontier-bullet theme) are respected by the draft.
8. **O — `## Gate registry` sections**: round 70 added no row for its trial or counter; round 71
   follows that pattern. Integration decides whether to add a registry row.

## PROVINCE.md

9. **P — line 73, `corpus/claim-ledger.sh` bullet**: `verify (164 revision stamps + 101 claim rows`.
   Same pre-existing staleness as item 5 (`PV-STAMPS`, `PV-CLAIMS`). Live: 178 / 102.
10. **N — after line 97**: the round-71 Core bullet (province-line.md). No Frontier bullet names
    PKI; SD1 is not triggered.

## SCORECARD.md

11. **S — `## Capabilities` table, after line 728**: the round-71 capability row (scorecard-draft.md §A),
    entering only at `value=4`.
12. **P — line 729 (paragraph after the capabilities table)**: "The latest first-working round in this
    table is 62" is already false (the round-70 row, `| 70 |`, is in the table). Append a note; do
    not rewrite the sentence.
13. **S — `## Round 71 — post-move`**: does not exist yet (draft: scorecard-draft.md §B). Its `depth` row
    must be the **only** `[C1]`-tagged row and its first cell must equal `depth` (claims-declared gate).
14. **N — `corpus/claims-declared.tsv`** (not a SCORECARD file, but gate-bound to it): add
    `71<TAB>C1<TAB>depth`. The file's last row is `70<TAB>C1<TAB>coverage`. Without it, the round's
    claim is not in the declared manifest.
15. **S — the round-70 `## Round 70 — post-move` freshness row**: already superseded by the appended
    errata in the working tree (`## Errata — round 70 post-move freshness sentence`). Confirmed present;
    no further change.
16. **P — `## Lane status` line**: `as-of:2026-11-07`. Not stale by its own rule (the dispatch state did
    not change); the date may be re-asserted at integration (O).
17. **S — the `## Round 71 — pre-move` section already in the working tree**: keep its text (it matches
    scorecard-draft.md §C). Its depth row cites the round-70 entry's `Does not establish` list, which
    the round-71 entry partly moves (see item 22).
18. **P — `current-claims.py` / `SELF_COUNTS`**: the post-move numbers (163 → 164, 47 → 48 row-linked,
    value=`<final>`) must be bound to live output. Not a prose-only update.

## corpus/knowledge and corpus/SOURCES.md

19. **S — `corpus/knowledge/openbao-pki-certificate-lifecycle.md` lines 54–55 (`Does not establish`)**:
    lists `leaf_not_after_behavior`, OCSP responses, revocation with a private key and multiple-issuer
    chain building as not established. Round 71 executes three of these (T6, T8, T9) plus per-issuer
    CRL routing (T7). The round-70 entry is true for its own scope; a dated appended note is the
    proposal (scorecard-draft.md §D), not a rewrite.
20. **S — `corpus/knowledge/openbao-pki-issuer-revocation-channels.md` line 4 `verified-at` and line 5
    `recheck: on-release`**: the registry rows S170 and S173 say `180d` (`awk -F'|'` on the recheck
    column). The entry's own clock is `on-release`, a text clock not bound by `release-clock.py`. The
    round-70 errata already says this for S170/S171. Proposal: the entry's `recheck:` line says
    `on-release (content clock; registry recheck 180d)`. The registry rows are append-only; do not edit
    their recheck cells.
21. **S — the new entry's summary line (Measured section)**: it quotes `OPENBAO_PKI_ISSUER_TRIAL: HOLDS
    holds=4 broken=0 error=0`. The script prints `… holds=… broken=… error=… bao=<ver> openssl=<ver>`
    (corpus/openbao-pki-issuer-trial.sh line 64). Quote the full line or say "abbreviated".
22. **N/A — the round-70 PKI entry** (item 19) and **SKILL.md line 55**: consistent after the round-71
    rows land. No conflict: round 70 says neither shows a relying party fetches the CRL; round 71 says
    the same.
23. **P — `corpus/SOURCES.md` S170 `used-by`**: the candidate lists both PKI entries. Fine. S173 row is
    `mined`, opened 2026-11-08, capture sha256 `42ef7582…5047a` matching the round-70 scout capture.

## Gates the integration must run (not run by the scribe)

24. **N — `bash corpus/sources-census.sh`**: expect `rows=164`; SC_CAPTURE for S173.
25. **N — `bash corpus/claim-ledger.sh verify`**: `stamped=` must match the README/SKILL/PROVINCE
    numbers chosen above (178 at the candidate, before any further stamps).
26. **N — `bash corpus/self-description-sweep.sh`**: the round-70 baseline is `n=28` (SD5=4 SD6=23 SD8=1)
    and the carried mismatch; round 71 must not add to it. Checked here by grep only: SD7 (`--selftest`
    in `corpus/openbao-pki-issuer-trial.sh`) = 0 matches; SD9 (`Reverify:` R21-02, r<30) out of scope.
27. **N — `bash corpus/claims-declared.sh`**: needs the round-71 manifest row (item 14) and one `[C1]`
    row with first cell `depth`.
28. **N — `python3 -I -B corpus/self-counts.py`**: the bound numbers in items 1, 2, 5, 9.

## Pending items (not stale; missing)

29. **N1 — stamp pins**: decide whether `corpus/openbao-pki-issuer-trial.sh`, `plans/round-71-c1.sh`,
    `plans/round-71-controls.sh` and `plans/round-71.md` get stamp rows (round-70 pattern). The candidate
    stamps only the entry. Without the trial's pin, its bytes can change with no stamp drift.
30. **N — `LOG.md`** round-71 entries and `corpus/lessons/round-71.md` (the plan's `## Mistakes` item):
    not in the candidate.
31. **N — `SHONEN.md`**: boxes stay `[~]` (plan disposition 5). No SHONEN line names PKI, depth or round 29,
    so nothing in SHONEN goes stale.
32. **O — `corpus/QUALITY.md`**: no criterion change is proposed by this round's plan.
