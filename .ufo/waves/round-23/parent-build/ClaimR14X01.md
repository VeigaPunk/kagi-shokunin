# ClaimR14X01 — R14-01 docs/knowledge-declaration obligation audit

Seat `ClaimR14X01` (leaf, read-only, no dispatch). Only write: this report.
Audit target: row **R14-01** at `corpus/claim-ledger.tsv:32`, revision
`d218603b74099ddca0bd8f869516fc41db0979bf` (`.git/HEAD`, read directly; `plans/round-23.md:3`).
Row line: 440 bytes (with newline), sha256 `b11aafe4…4bb2`.
Audited trees are at their stamps: `corpus/claim-ledger.tsv` sha256 `e6806968…8305`, 58 lines /
17844 bytes (`corpus/stamps.tsv:5`); `corpus/claim-ledger.sh` sha256 `cf56f9ea…6c2c`, 1428 lines /
88425 bytes (`corpus/stamps.tsv:4`; same bytes the round-22 spotcheck bound at `4be5da3`,
`corpus/lessons/round-22-verifier-spotcheck.md:69`). No gate, handler, op, vault or host command
was executed; no production write. In-flight untracked `corpus/closure-dispositions.{py,json}`
(mtime 00:46) are not committed evidence and were not read.

## 1. Row and causal chain

```
R14-01  bash corpus/claim-ledger.sh docs
        ^DOC_AUDIT: CLEAN \(entries=25 row_linked=22 by_hand=3 undeclared=0 missing_ids=0 unpinned=0
        exit 0   timeout 300   note: current declaration snapshot … (no [substrate] tag)
```

- Mode/arg handling: `corpus/claim-ledger.sh:196` (mode), `:218-221` (at most one positional),
  `:986` (`doc_audit "${POS[0]:-corpus/knowledge}"`), verdict/exit `:987-993`.
- Implementation `doc_audit()`: `corpus/claim-ledger.sh:861-965`. Entry glob `:874`; hidden-entry
  refusal `:879`; one-declaration rule `:890-903`; id form `:870`, resolution `:906-919`
  (`is_row` → `load_ids`, `:606-624`, which skips comment lines so a comment-named id is not a
  row); by-hand class/floor `:920-950`; stamp **membership** `:952-955`; counts `:956-959`;
  `DOC_AUDIT_RATIO` `:960-961`.
- Enforcement (the only thing that checks the last line and exit): `verify_claims`
  `:400-444` — `timeout -k 5 300 bash -o pipefail -c` at `:426-427`, exit equality `:430-434`,
  last non-empty line `:436-444`. Deferral branch `:416-419` reads the note's `[substrate]` tag;
  `substrate_present()` is `:140-148`.
- `cells`: R14-01 is inside `CEL_IDS` (cited by `SCORECARD.md:193,207,229,293,622,642,643`) and is
  **SKIP-SELF** (`:810-820`, summary field `self_skipped` at `:997-1010`).
- `docs` mode never runs a claim row and never calls `substrate_present` — the only substrate read
  in this script is inside `verify_claims`.

## 2. Verdict / last line / exit / timeout — justified

**Recomputed from the tree at HEAD (read-only counters, not a gate run):**

| quantity | code path | observed |
|---|---|---|
| entries | `:874` glob | 25 `corpus/knowledge/*.md`; no hidden `.[!.]*.md`; each file exactly one `^Reverify: ` line and `^Reverify` count equals it (`:896`) |
| row_linked | `:913-919`, `:956` | 22 = 13 entries whose declared ids include a non-substrate row + 9 whose ids are all `[substrate]`-tagged; every declared id resolves (ids are whole-word `R<d>-<d>` tokens and `load_ids` drops comments) |
| by_hand | `:920-950` | 3: `config-layering` (opencode-internal), `control-plane-hardening`, `handler-trust-boundary` (both control-plane-scratch); reasons 207/178/112 chars, distinct after case-fold+space-collapse → `duplicate_reasons=0` |
| unpinned | `:952-955` | 0 — all 25 have a `corpus/stamps.tsv` row (`:11-35`), and all 25 rows are **fresh** at HEAD (sha256+lines+bytes recomputed) |
| floor | `:959` | 13; `2*22 >= 25` |

Expected verdict string therefore matches the shipped expectation exactly; nothing else can be
printed on the CLEAN path (`:992` prints the literal and the three counts). The ERE prefix is
tight, not lax: each pinned field is followed by a literal space+next-field, so `entries=250` /
`row_linked=220` cannot match. `duplicate_reasons=0` is omitted from the ERE but is implied by
the CLEAN branch (`:987-992`).

**Persisted receipt (historical, executed):** `.ufo/waves/round-22/final-verification.json`
`safe_rows[10]` — argv `["bash","corpus/claim-ledger.sh","docs"]`, exit 0, 28 stdout lines
(25 `ENTRY` + ratio + verdict), last line exactly
`DOC_AUDIT: CLEAN (entries=25 row_linked=22 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`,
ratio `row_linked=22/25 floor=13 by_hand=3 duplicate_reasons=0`, **0.057 s**. The old/new pair for
this expectation is recorded at `.ufo/waves/round-22/pin-migrations-integration.json`
`claim_changes[3]` (24/21 → 25/22). *Caveat:* the verdict file's `.h1` binding is itself routed as
D6 (`corpus/lessons/round-22-verifier-spotcheck.md:177-179`: recorded `8ada17a5`, measured
`4be5da3`), so the receipt is used only as an observed stdout, not as a commit attestation; the
counts were independently reproduced from HEAD above.

**Historical vs current:** the frozen pre-round-22 row is
`.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:32`, sha256 `89e5e65d…d1c`,
`entries=24 row_linked=21` — a *different* expectation, correctly superseded by the 25/22
migration after `corpus/knowledge/feature-bound-credential-review.md` was added and pinned
(new entry's `Reverify: R21-02`, `:4`; its stamp is `corpus/stamps.tsv:20`). The frozen tree holds
only 2 knowledge files, so the old population is evidenced by the frozen row plus the migration
JSON, not by a full frozen tree.

**Timeout 300 — justified with ~5 000× margin.** `docs` reads 25 small Markdown files, 70 stamp
rows and 58 ledger lines; measured 0.057 s. It spawns no `op`, no handler, no network, and no
`HOME` path, so the cap is not a flake surface.

## 3. Deferral / SKIP-SELF / hermetic mode

- **[substrate]** — correct that R14-01 carries no tag: `doc_audit` is host-free. But the tag would
  not reach it anyway: only `verify_claims:416` consults `[substrate]`, so `docs` is
  **substrate-blind**. Measured consequence: 9 of the 22 row-linked entries declare *only*
  substrate-tagged rows — `cdp-bridge-1password`, `credential-isolation`, `handler-on-disk-state`,
  `janitor-command-surface`, `janitor-env-contract`, `janitor-lifecycle`, `op-cli-surface`,
  `op-env-refs`, `tac-evidence-integrity` (tags in the note column of `corpus/claim-ledger.tsv`;
  11 tagged rows in total, matching R18-02 at `claim-ledger.tsv:49`). On the host state this
  ledger itself pins (`R18-01`,
  `claim-ledger.tsv:48`, all-GONE), those entries have no runnable re-verification, while
  R14-01 still reports `row_linked=22`.
- **SKIP-SELF** — R14-01 is cited by seven scorecard cells, so a live `cells` run reports
  `SKIP-SELF R14-01` and counts it in `self_skipped`; it is **not** re-executed there, and that is
  the correct bounded behaviour (the row's command re-enters the same gate). The obligation is
  therefore discharged only by `verify` (which cannot pin its own summary, `:229-238`) or by an
  external safe-row harness; round 22 used the latter and classified R14-01 as a safe row
  (`.ufo/waves/round-22/safe-row-plan.json`, `safe_rows`).
- **Hermetic synthetic mode** — R14-01's command has no `--root`/`--stamps`; `ROOT`, `STAMPS`,
  `CLAIMS` are derived from the script's own location (`:103-105`). Its expected counts are bound
  to the *live* tree at that location. A fixture root with substitute data prints different
  counts and can only false-fail this row. Host-free replay is possible only by (a) running the
  real tree through the external safe-row harness, or (b) copying the real
  `corpus/knowledge/` + `stamps.tsv` + `claim-ledger.tsv` into the root and recording their
  digests. The planned `corpus/fixtures/cells-hermetic/` (`plans/round-23.md:32-40`) does not
  exist yet (`ls corpus/fixtures` empty) and cannot stand in for this row.

## 4. What C3 / C1 must retain for R14-01

C3 (hermetic cells proof):
1. Keep the row bytes intact in the frozen 43; any future re-pin needs a QM14 old/new record —
   the current pair already exists at `pin-migrations-integration.json` `claim_changes[3]`.
2. Do not run R14-01 at a synthetic root. It is host-free, so it belongs in the real-tree
   host-free safe-row set; a synthetic-data replay is a guaranteed false fail.
3. If the fixture's claims file omits R14-01, say so explicitly; if it includes it, expect and
   report `SKIP-SELF`/`self_skipped` rather than counting it as run. A fixture `cells` run cannot
   discharge this row.
4. Never add `[substrate]` to R14-01 — the mode has no host dependence, and the tag would silently
   defer the declaration audit.
5. Fixture text under `corpus/fixtures/` is outside every doc scan (`default_docs` `:518-534`;
   `doc_audit` glob `:874`), so a fixture cannot carry citation/idref coverage: cite the new
   `R23-01` row, not the fixture path.

C1 (closure dispositions):
6. Follow row → `docs` → each entry's `Reverify` line → the *cited row's* disposition (including
   `DEFER`). Do not accept `row_linked=22` or the row's exit 0 as closure: `docs` runs no row.
7. Type the `corpus/knowledge/claim-ledger.md` → `R14-01` edge (`:12`, explained at `:243-245`)
   as self-referential contract text, not as host-fact re-verification for that entry.
8. If any disposition's `fixed` pointer resolves into `corpus/claim-ledger.tsv`, bind it to the row
   **id** and re-derive; a whole-file hash pointer goes stale on every expectation re-pin.

## 5. Consumer-visible risk (false-clean) and minimal falsifier

**Risk.** `DOC_AUDIT: CLEAN … row_linked=22` is declaration coverage, not runnable verification.
`docs` executes no row, and 9 of the 22 linked entries declare only `[substrate]` rows. A consumer
that follows R14-01 as freshness evidence (C1's closure checker is exactly that consumer, or the
scorecard wording "every knowledge entry declares how its host-fact base is re-verified") can read
it as "22 entries can be re-verified here" while none of those 9 can be on the host the ledger
pins. This is a *stated* bound in `corpus/knowledge/claim-ledger.md:234-236` ("coverage claim, not a
relevance claim") — the risk is the consumer-visible inference, not a hidden bug.

**Minimal synthetic falsifier (proposed; not executed by this seat; no live substrate command).**

```sh
F=$(mktemp -d); mkdir -p "$F/corpus/knowledge"
printf 'fixture\nReverify: R11-01\n' > "$F/corpus/knowledge/a.md"
printf 'R11-01\tgrep -c EXPECTED corpus/absent.txt\t^1$\t0\t30\tfixture [substrate]\n' > "$F/claims.tsv"
# one stamps row for corpus/knowledge/a.md (sha256, wc -l, wc -c) into "$F/stamps.tsv"

# A: the cited row runs and fails
KAGI_SUBSTRATE=present bash corpus/claim-ledger.sh verify --root "$F" \
  --claims "$F/claims.tsv" --stamps "$F/stamps.tsv" --docs "$F/claims.tsv"
# B: the cited row never runs
KAGI_SUBSTRATE=absent  bash corpus/claim-ledger.sh verify --root "$F" \
  --claims "$F/claims.tsv" --stamps "$F/stamps.tsv" --docs "$F/claims.tsv"
# C: the declaration audit, identical in both states
bash corpus/claim-ledger.sh docs --root "$F" --claims "$F/claims.tsv" --stamps "$F/stamps.tsv"
```

[INFERENCE from the code paths `:416-444` and `:987-993`, to be observed by L1]:
A prints `FAIL R11-01 reason=exit-mismatch exit=1 want=0`, exit 1; B prints
`DEFER R11-01 reason=substrate-absent` then `CLAIM_LEDGER: CLEAN (claims=1 deferred=1 …)`, exit 0;
C prints `DOC_AUDIT: CLEAN (entries=1 row_linked=1 by_hand=0 undeclared=0 missing_ids=0 unpinned=0
duplicate_reasons=0)`, exit 0 — in **both** A and B, including the state where the only declared
row fails. `KAGI_SUBSTRATE` is the documented override (`:141-145`), so neither arm consults the
handler.

**Fix recommendation (one, not both):** emit `row_linked_substrate_only=N` on the
`DOC_AUDIT_RATIO` line (`:960`) — informational, no new failure class, same "the counts ARE the
claim" style; and/or have C1 require a per-entry `verify` disposition when it follows a
`row_linked` pointer. Do not fail `docs` on substrate state: the declaration audit must stay
host-independent.

**Secondary, note-level (freshness).** The row note says "Old/new expectation preserved in
round-22 journal", but `corpus/lessons/round-22.md:64-70` records only 21/18 → 24/21; the current
24/21 → 25/22 pair is at `.ufo/waves/round-22/pin-migrations-integration.json` `claim_changes[3]`
and observed at `final-verification.json` `safe_rows[10]`. Low severity (note fields are not
machine-checked); fix by naming the artifact.

## 6. Limits

- No gate or row was executed; counts come from reading the data with `awk`/`grep`/`sha256sum`/`wc`.
  The three fixture outputs are code-derived predictions, marked [INFERENCE], for L1 to run.
- Substrate presence was not probed (forbidden host read); the "9 of 22 have no runnable row"
  statement is explicitly conditional on R18-01's pinned all-GONE state.
- `verify` cannot pin its own summary (`:229-238`), so no committed gate currently executes
  R14-01 on a schedule; this audit neither changes that bound nor claims a fresh execution.
- The in-flight C1 script was not read; C1 statements are derived from `plans/round-23.md:9-19`
  and the committed D-list (`round-22-verifier-spotcheck.md:165-184`).

Report: .ufo/waves/round-23/parent-build/ClaimR14X01.md
