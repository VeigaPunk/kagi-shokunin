# ClaimR11X11 — audit of claim-ledger row R11-11

Read-only, advisory; no judgment/admission authority. **Not executed:** the row,
any sibling row/gate, any handler/op/vault/host command. Counts below are static
or synthetic; the only host contact was a `test -x` existence check.

## 0. Observed revision and scope

- `HEAD` **`d218603b74099ddca0bd8f869516fc41db0979bf`**, audit time
  `2026-10-21T03:50Z`. Working tree has in-flight, not-mine changes: `M
  corpus/SOURCES.md`, `M corpus/sources-census.sh`; untracked
  `corpus/closure-dispositions.{py,json}`, `corpus/source-fetches.tsv`,
  `plans/round-23.md`, `.ufo/waves/round-23/`, `corpus/__pycache__/`.
- Row (`corpus/claim-ledger.tsv:25`; 43 command rows in the ledger):
  `R11-11` / `grep -cv '^#' corpus/surface-census.tsv` / `^35$` / `0` / `30` /
  `surface-census.tsv declares 35 rows (20 asset / 15 runtime)`.
- Subject `corpus/surface-census.tsv`: sha256
  `4af0dbcc81fdb7229f816bf23920174b1d699ba279405272fb78c5922f368992`, 4752 B,
  `wc -l` 54 but 55 logical lines (last line has no trailing newline); comment
  lines 1–20 (four `# scan` at 17–20); declarations on lines 21–55 = 35 rows,
  20 `asset` / 15 `runtime`, **0 blank lines**. Stamp `corpus/stamps.tsv:64`
  pins exactly that sha/lines/bytes; live bytes match.
- R11-11 carries **no `[substrate]`** tag. The runner reads only that literal
  from a note (`corpus/claim-ledger.sh:416`); the parenthetical is inert.

## 1. Expected verdict / last line / exit / timeout — SUPPORTED today

- Runner: runs in `$ROOT`, exit must equal column 5, then the ERE must match the
  last non-empty combined-output line (`corpus/claim-ledger.sh:404-445`, esp.
  `:426-427` exec, `:432-434` exit, `:436` last-line, `:441-443` ERE).
- `grep -cv '^#'` prints exactly one line (`35`) and exits 0 when ≥1 line is
  selected; a zero count exits 1 *and* prints `0`, failing both halves. Command
  is policy-clean (allowlisted `grep`, no metachar/backslash/denied verb;
  `claim-ledger.sh:170-188`).
- Counts: 35 non-comment lines, and all 35 are declarations (no blank lines).
  30 s timeout vs **0.002 s** measured in the round-22 receipt — justified.
- Persisted evidence: `.ufo/waves/round-22/final-verification.json` safe-row
  R11-11 records argv, exit 0, `stdout "35\n"`, `last "35"`, `passed true`,
  `seconds 0.002`. `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:25`
  is byte-identical to the current row. Live `corpus/claim-ledger.tsv` sha256
  `e6806968…` equals the digest in
  `.ufo/waves/round-22/final-verification-inputs.json`; the census sha is also
  the round-22 `integration-manifest.json` entry and is unchanged since
  `587fda0` (r15).
- Lineage (read-only `git show`): row introduced `301b9ec` (r11), identical at
  `8a6ec16` (r16), `bc1af88` (r17), `4be5da3` (r22); command/expect/exit/timeout
  never edited. Historical census revisions are only `03477c0` (r10 creation)
  and `587fda0` (r15, note-only), both 35 rows / 20 asset / 15 runtime / 0 blanks.

## 2. Causality — the row asserts a line count, not a declaration set

Boundary: `grep -cv '^#'` selects every physical line whose first byte is not
`#`, **including empty lines**. The gate this row is meant to pin skips empty
lines (`corpus/surface-census.sh:156`) and parses declarations
(`surface-census.sh:157-174`); its CLEAN counts come from parsed `ROW_CLASS`,
not physical lines (`surface-census.sh:859-863`).

Synthetic replication over the current bytes (in-memory; the row was not run):

| variant | non-`#` lines (row) | parsed declarations (gate) | asset/runtime |
|---|---|---|---|
| current | 35 → PASS | 35 | 20/15 |
| +1 blank line only | 36 → **FAIL** | 35 | 20/15 |
| delete 1 declaration + add 1 blank | 35 → **PASS** | 34 | 19/15 |
| 1 `asset`→`runtime` class flip | 35 → **PASS** | 35 | 19/16 |
| delete 1 declaration only | 34 → FAIL | 34 | 19/15 |

- **False-fail:** a semantically neutral blank line makes R11-11 fail
  (`verdict-not-final`, 36) although the gate still sees 35 declarations and
  20/15.
- **False-clean:** one declaration deleted plus one blank line keeps 35. If the
  deleted row is outside the four `# scan` dirs — 10 of 35 rows are (4
  `~/.config/opencode`, 2 `~/.local/bin`, 3 musketeer profile, 1
  `~/.agents/AGENTS.md`) — no `UNLISTED` path exists, the gate simply evaluates
  one fewer surface, and R11-01's ERE (`assets=[1-9][0-9]* runtime=[1-9][0-9]*`,
  `claim-ledger.tsv:15`) still matches. With the substrate absent (as here),
  R11-01/02/03 and R16-01 all DEFER (`claim-ledger.sh:416-419`), so no executed
  row notices; `verify` stays CLEAN.
- **Composition:** a class flip keeps 35 and is invisible to every executed row:
  R11-01 is shape-only, scope-gate uses class only for informational
  `asset_absent` (`corpus/scope-gate.sh:409`), R16-01 pins census/owned/shared
  (`claim-ledger.tsv:39`). Yet the row note, `corpus/README.md:41`,
  `PROVINCE.md:8`, `corpus/knowledge/surface-census.md:4-5`,
  `SCORECARD.md:49` all state 20/15, and 12 scored SCORECARD cells cite R11-11
  (lines 61, 83, 105, 117, 183, 197, 205, 218, 227, 240, 291, 705).
- Precedent, same class: round 12 already fixed a blank-line substitution that
  passed a `grep -c` count while `verify` lost a row
  (`corpus/lessons/round-12.md:107`); the stamps row now counts non-blank lines
  (`corpus/knowledge/claim-ledger.md:374-377`; `R12-03`,
  `corpus/claim-ledger.tsv:28`), and `R16-05` already applies the corrected
  `grep -cE '^[^#[:space:]]'` form to `corpus/adjacency.tsv`
  (`corpus/claim-ledger.tsv:43`). R11-11 (r11) predates round 12 and is a
  residual instance of the class, not a new one.
- Prior finding, not duplicated: `.ufo/waves/round-22/build/Entry21.md` §D
  already records that R11-11 pins only the total and R11-01 accepts any
  positive counts; the total itself is not the declaration set. `corpus/knowledge/adjacency-scope.md:245-247`
  states the intended role ("a row deleted from the census … the row count is
  pinned outside by `R11-11` (35)"); under blank substitution that pin does not
  hold. **No historical instance** of either false outcome: composition/row
  count never changed across the two census revisions, so this is latent
  (supported by code + synthetic counts; historical absence observed).

## 3. `[substrate]` deferral, SKIP-SELF, hermetic cells

- **Deferral:** R11-11 is untagged and host-free (one committed-file read), so
  it runs when the substrate is absent (`substrate_present`
  `claim-ledger.sh:140-146`; defer `:416-419`). This host is substrate-absent
  (`test -x ~/.local/bin/the-janitor` → false). It must stay untagged: on this
  host R11-01/02/03 and R16-01 defer, leaving R11-10/R11-11 as the only
  executed total pins; tagging it would silently remove the last executed
  census-count check. Deferral preserves the obligation only because it is not
  applied to this row.
- **SKIP-SELF:** the exemption applies only when the command contains
  `claim-ledger.sh` (`claim-ledger.sh:816-820`). R11-11's command does not, so
  `cells` re-runs it whenever a cell cites it (`cells_evidence`, `:802-828`);
  12 scored cells do. The obligation is preserved and would fail the cell
  audit if the count moved.
- **Hermetic synthetic (C3, not built at HEAD — no `corpus/fixtures`):** to
  preserve R11-11 the fixture must
  1. carry the row verbatim (id/command/expect/exit/timeout);
  2. include a fixture `corpus/surface-census.tsv` with exactly 35
     non-comment, non-blank lines under the fixture root;
  3. cite R11-11 in a fixture Round cell so `CEL_IDS` includes it — `cells`
     only runs cited ids (`:805-822`), otherwise the row vanishes silently;
  4. make the mutation change the non-comment count (delete without
     substitution → 34, or duplicate → 36); a blank-compensated deletion leaves
     R11-11 green and is exactly the false-clean in §2, so it cannot serve as
     this row's mutation (expected `CELL_AUDIT: BROKEN … row_failures=1`);
  5. run with `KAGI_SUBSTRATE=absent` (or an equivalent explicit fixture
     policy) so `row_deferred` and the exact CLEAN line are host-independent;
  6. reconcile `rows_run + row_deferred + self_skipped` with the fixture row
     count, with R11-11 in `rows_run`. C3-wide tension: a verbatim 43-row
     fixture would execute untagged host readers (round-22 skipped R18-01 as
     host-private, `.ufo/waves/round-22/safe-row-plan.json`), so "preserve all
     command-row obligations" has to be an explicit, counted classification,
     not verbatim execution; R11-11 is on the host-free side.

  Summary: deferral and SKIP-SELF preserve R11-11; hermetic mode preserves it
  only if the fixture census holds 35 declarations and the mutation is
  count-changing.

## 4. C1 closure-disposition integration — what it must retain

- Obligation set: 9 routed defects (`corpus/lessons/round-22-verifier-spotcheck.md:165-184`),
  5 discernment decisions (`:103-107`), 1 adjudication (`:157`) = 15
  (`corpus/closure-dispositions.py:76-101`). **R11-11 is not one of them; do not
  invent an obligation or quota item for it.**
- Point-in-time observation on untracked, in-flight files (not committed, not
  part of the frozen population): `corpus/closure-dispositions.json` assigns
  one disposition per obligation (fixed=7, no-action=5, reported=2,
  operator-owned=1); **all 7 `fixed` pointers** point at
  `corpus/lessons/round-23.md#Routed defect dispositions`, a file that does not
  exist yet. `resolve_pointer` (`closure-dispositions.py:104-122`) accepts a
  `fixed` pointer if the target file exists and merely contains the obligation
  id token (optional heading anchor) — one prose lesson can resolve all seven
  fixes without the actual artifacts existing. That is record-level assurance,
  not the "actual source/row pointers" the round-23 Goal requires
  (`plans/round-23.md:9-14`). For D9 (`:32-36`) the actual fix is
  `corpus/fixtures/cells-hermetic/` **plus ledger row `R23-01`**; the resolver
  as written follows neither. Advisory only; another seat owns that build.
- Retention for this row: any disposition/journal statement that the
  census/rows are preserved must resolve to `corpus/claim-ledger.tsv` row
  R11-11 (and, for C3, the fixture census) and to an executed cell-run
  accounting — not to a count (35/43) or a prose note that merely names an id.
- Freshness pin: `closure-dispositions.json.source_sha256` `65a5b3de…` equals
  the live spotcheck sha256 — the obligation source is bound. R11-11 is not
  parsed from it, so source drift cannot launder the row.

## 5. One consumer-visible risk + minimal synthetic falsifier

**Risk:** R11-11 pins “35” as non-comment *lines*, so it is satisfiable by a
blank line, blind to which declarations remain and to their class. A consumer
reading `CLAIM_LEDGER: CLEAN` plus the note/docs (“20 asset / 15 runtime”) gets
assurance that a reduced or reclassified declaration set no longer supports: a
cosmetic blank line blocks a harmless commit (false-fail), while a
blank-for-declaration substitution ships green (false-clean).

**Minimal failing fixture proposal for L1** (not executed; exact contents):

- *Fixture A — must fail after the fix, passes today:* copy the 35 declarations
  into the fixture census, delete one non-scan-dir declaration (e.g. the
  `$HOME/.agents/AGENTS.md` row) and insert one empty line. Result: 35
  non-comment lines → `grep -cv '^#'` = 35 / exit 0; the gate parses 34 rows,
  19 asset / 15 runtime. Correct disposition: row fails (or a companion
  composition row fails) and `CELL_AUDIT` is `BROKEN` with `row_failures=1`;
  today's row passes.
- *Fixture B — must pass after the fix, fails today:* the unchanged 35
  declarations + one empty line → the row prints 36 and fails
  `verdict-not-final`, although the parser still sees 35 declarations and
  20/15. This is the false-fail control.
- Pair A/B with a fixture claim-ledger row R11-11 verbatim and a fixture
  scorecard cell citing it, per §3.

**Minimal fix options** (integration-owned; row owners differ):

- **Primary — established form, closes the line/declaration asymmetry:** change
  R11-11's command to `grep -cE '^[^#[:space:]]' corpus/surface-census.tsv`
  with the same `^35$`, exit 0, timeout 30. Statically verified 35 on current
  bytes (every declaration starts with `$`; no leading-whitespace lines); blank
  and whitespace-led lines are no longer counted, so Fixture B passes and
  Fixture A fails as it should. Policy-clean (no metachar/backslash/`$`), and
  this is the form `R16-05` already uses (`claim-ledger.tsv:43`) and the class
  round 12 fixed for stamps (`lessons/round-12.md:107`;
  `knowledge/claim-ledger.md:374-377`).
- **Composition (separate Entry21 §D item):** keep R11-11 as the total and add
  blank-immune composition pins:
  `grep -c '^[^#]*[[:space:]]asset[[:space:]]' corpus/surface-census.tsv` →
  `^20$`, same with `runtime` → `^15$`. Statically verified 20/15 on current
  bytes; the patterns contain no policy metachars/backslash/`$`, and no note
  contains a bare `asset`/`runtime` word. New rows move R21-04 (43→46) and
  stamps membership, so that is an explicit integration decision.
- Or tighten R11-01's expectation to `assets=20 runtime=15` (cross-row owner
  R11-01; Entry21 §D proposed a future static row).
- Until migrated/pinned, reword R11-11's note so the parenthetical is marked
  informational/unpinned (or drop it); the docs at `README.md:41`,
  `PROVINCE.md:8`, `knowledge/surface-census.md:4-5`, `SCORECARD.md:49` repeat
  it as fact.

## 6. Limits

- No gate/handler/ledger row executed; no host/private content read. Evidence:
  static code reading plus `sha256sum`/`wc`/`grep -c ''`/`git show` and
  in-memory synthetic counts. GNU grep counts the final unterminated line
  (observed: `grep -c ''` = 55 vs `wc -l` = 54; round-22 receipt = 35).
- In-flight artifacts (`closure-dispositions.*`, `plans/round-23.md`,
  `source-fetches.tsv`, `SOURCES.md`/`sources-census.sh` edits) may change;
  statements about them are point-in-time observations, not committed findings.
- No admission, score, or prose-honesty judgment is made.
