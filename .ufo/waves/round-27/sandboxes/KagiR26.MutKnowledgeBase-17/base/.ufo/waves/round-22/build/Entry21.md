# Entry21 — `knowledge/surface-census.md` stamp + freshness audit (read-only)

Base read: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`HEAD` == base at read; blob-verified below).
Seat: leaf scout, read-only. No host gate executed (`surface-census.sh`, `drift-pins.sh`, `claim-ledger.sh`
were never invoked). No production file touched; this report is the only write. No installs.
Axes named: **calibration** = are this entry's source/status/count claims true at base; **freshness** =
byte-pin state vs substantive vintage.

## Verdict

1. **No stale-byte mismatch.** At base the stamp row is byte-exact: `e07750f1c61e…647f`, 287 lines,
   19435 bytes — identical to `sha256sum`/`wc -lc` of `corpus/knowledge/surface-census.md` and to
   `git cat-file blob c2cab35:corpus/knowledge/surface-census.md`. Re-pinning it now would be laundering,
   not freshness.
2. **Not a dropped stamp.** The path is present in all nine revisions of `corpus/stamps.tsv`
   (r11 → r21), and its tuple was deliberately re-pinned only on real content changes:
   r11 `2dc519fa/285/19335` → r13 `bcd4217e/285/19385` → r14 `e07750f1/287/19435` → unchanged through
   r21. r14's +2 lines is exactly the `Reverify:` line added by `2486643`.
3. **Substantive freshness has drifted even though bytes did not.** The entry describes the round-10
   script, but `corpus/surface-census.sh` changed in r11 (`301b9ec`: fail-closed `DEGRADED`) and r18
   (`fecee87`: substrate-absent selftest skip), and `corpus/drift-symbols.tsv` changed in r13
   (`4b8c018`: 19 → 20 rows). Seven present-tense claims are contradicted at base (B1–B7); one more is a
   host-state count that the absent substrate makes unverifiable (B8).
4. **An appended errata is needed**, scoped to those items, not a rewrite (§Proposed correction).
5. **Absent-source limit is total for live claims.** The handler, `tac-check`, `client.py`, the DB and
   the log are all absent; `the-janitor` is not on `PATH`. The entry's 2026-09-28 gate results and
   `Reproduction` block are therefore historic only; the Reverify rows `R11-01`/`R11-02` are
   `[substrate]`-tagged and **defer**, they cannot pass or fail on this host.

## A. Byte pin (observed at base)

| item | value |
|---|---|
| doc sha256 | `e07750f1c61e793344816d95a8ba9269975b71292c28a0644c70bf18ba64247f` |
| doc lines / bytes | 287 / 19435 |
| stamp row (verbatim) | `corpus/knowledge/surface-census.md \t e07750f1…647f \t 287 \t 19435` |
| stamp file sha256 | `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b` (63 rows) |
| doc vs base blob | identical (`git diff --quiet c2cab35 -- …` exit 0) |

## B. Substantive mismatches (observed at base; each is source-bound)

| # | doc line | claim (quoted, ≤25 words) | contradicting source | confidence |
|---|---|---|---|---|
| B1 | 5 | “`corpus/state-shape.tsv` (22 rows: 9 sqlite / 9 json / 3 log / 1 lock / 1 marker)” | file has **9/8/3/1/1 = 22**; the listed parts sum to **23**, so the sentence is self-contradictory. `state-shape.tsv` rows 41–48 are the 8 json rows | observed |
| B2 | 32 | “(15 files, 19 symbol pins)” | 15 baseline files is still true, but `drift-symbols.tsv` has **20** non-comment rows at base; it had 19 at r10 (`git show 03477c0:…`) and became 20 in `4b8c018` (r13) | observed |
| B3 | 76 | “the baseline keeps the **16 published hashes**” | `drift-baseline.tsv` has **9** sha256 fields and 6 `-` rows (15 files); `drift-gate.md:143` says “6 of 15 files are content-unhashed”. No file, commit or lesson supports 16 | observed |
| B4 | 92 | “`PASS` / `FAIL` / `SKIP` \| verbs \| per-probe verdict” | script prints a fourth verdict `SURFACE_CENSUS_VERBS: DEGRADED (pass=0 skip=N)` + exit 1 (`surface-census.sh:872-881`, added r11 `301b9ec`). The entry’s verdict vocabulary and exit-code paragraph (L94) omit it | observed |
| B5 | 257–262 | “Selftest cases (verbose output names each; 16 total)” | count is right (static recount = 16), but the list omits the r18 substrate-absent path: two `skip-case … substrate-absent (handler not on PATH)` messages (`surface-census.sh:821,823`) replace the two verb cases when the handler is absent — the current host state | observed |
| B6 | 280 | “(this exact case is selftest 10)” | dropped-required-table is **case 11**; case 10 is the `SQLITE3_BIN=<absent>` `UNVERIFIED` case (doc itself says so at L117, and `lessons/round-10.md:30` says “Selftest case 11 now pins `SHAPE (missing tables)`”) | observed |
| B7 | 119–121 | “Floors are one third of the observed value (… `tables_min 12` vs 20, log `size_min 16384` vs 33687 B)” | the two cited non-row floors contradict “one third”: 12/20 = 0.60, 16384/33687 = 0.486. `models.json` (65536 vs 4,709,964 B ≈ 0.014) is a third counterexample the sentence omits. Same rule is repeated in `state-shape.tsv` header, so the owning fix is not this entry alone | observed |
| B8 | 55, 200 | “`~/.config/opencode` (20 children, 4 declared paths)” | 20/4 was pinned in `adjacency.tsv:75` (r16); at base the directory has **3** children (`cli.json`, `opencode.json`, `service.json`) and the three declared sub-tree files are gone. Shared surface, outside this lane’s ownership — the count is host-state, not a census declaration | observed |

### C. Checked and correct (do not “fix”)

- L14 `Reverify: R11-01, R11-02, R11-03, R11-10, R11-11` — all five ids resolve in
  `corpus/claim-ledger.tsv:15-17,24-25`; entry is a stamps row, so `claim-ledger.sh docs` remains satisfied.
- L117 “`--selftest` case 10 proves this path” — correct (case 10 = `sqlite-unavailable`).
- L139/225 “found by selftest case 11” and “selftest case 14 pins the refusal” — correct.
- L257 “16 total” — correct static count (12 `run_case` + 4 explicit case blocks, incl. 2 skip-cases).
- L71 L204 “single `mode = -` row (the contested chrome-profile dir)” — correct (1 of 35 rows).
- L54 “`$STATE` (5) … 16/16 declared” — **not asserted as an error.** The declared set has 6 direct
  children (4/6/5/2 = 17) because `$STATE/xdg-state` is declared `runtime`; the parenthetical reads as
  *live* children, which is consistent with one runtime child absent. Live count is unverifiable now
  (substrate absent). [INFERENCE, not observed]
- L74-76 cross-check sentence: `CROSSCHECK` compares modes only, which matches `surface-census.sh`;
  only the “16 hashes” figure inside it is wrong (B3).

### D. Reverify-row calibration gap

`R11-01`’s expectation is `assets=[1-9][0-9]* runtime=[1-9][0-9]* … ok=[1-9][0-9]*` — it accepts any
positive counts, so the entry’s headline figures (`assets=20 runtime=15 ok=34 absent=2 skipped=0`) are
**not pinned by the row the entry cites**. `R11-11` pins only the 35-row total; `R11-10` only the 22-row
total. A future static row could pin the split, but that is an integration decision, not a re-stamp.

## E. Absent-source limits (read-only evidence)

Observed at audit time (no gate run):

- `~/.local/bin/the-janitor` — **ABSENT**; `~/.local/bin/tac-check` — ABSENT;
  `~/.config/the-janitor/client.py` — ABSENT; `…/xdg-data/opencode/opencode.db` — ABSENT;
  `…/log/opencode.log` — ABSENT; `command -v the-janitor` → not on PATH.
- Corroborating ledger evidence: `R18-01` recorded `DRIFT_PINS: DRIFT (files_ok=0 files_bad=15
  symbols_ok=0 symbols_bad=20)`, “measured state 2026-10-14”; `SCORECARD.md:324` calls six live verdicts
  “fail-closed readings of the absent substrate”.
- Consequence: the entry’s live figures (gate summaries, host line counts 333/88/117, `~/.config/opencode`
  20 children, obs. `7/39/55/238`, log 33,687 B) cannot be re-measured here; they are 2026-09-28 readings.
- `op` is present at `/usr/bin/op`; it was not executed (no vault operation).

## Proposed correction (append-only; exact scope, wording owned by the scribe)

Append one §Errata block after the existing `Reproduction`/`Falsification` content — never edit the
round-10 sentences or the `Gates observed this round` block. Minimal items, each citing the source it
corrects:

1. `state-shape.tsv` kind split is **9 sqlite / 8 json / 3 log / 1 lock / 1 marker** (L5; cite
   `corpus/state-shape.tsv` base sha `c84939050de8…`).
2. `drift-symbols.tsv` is **20** pins at base; the entry’s 19 is the round-10 count (L32; cite
   `4b8c018`).
3. `drift-baseline.tsv` holds **9** hashes of 15 files, not 16 (L76; cite `corpus/drift-baseline.tsv`
   sha `90c2d7a52360…` and `drift-gate.md` §Bounds).
4. Verbs vocabulary gained **`DEGRADED`** in r11, exit 1 (L92/94; cite `surface-census.sh:874-881`).
5. Selftest omits the r18 **substrate-absent skip** for the two verb cases; case-number citation at L280
   is **11**, not 10 (cite `surface-census.sh:821,823`; `lessons/round-10.md:30`).
6. Floor derivation is not uniformly “one third” (`tables_min`, log `size_min`, `models.json`); state the
   floors as declared values and stop deriving them from the observed value (L119-121 + `state-shape.tsv`
   header — route the header half to its owner).
7. Label the 2026-09-28 gate figures and the `~/.config/opencode` 20-child count as historic, with
   “substrate absent since r18; not re-measured” (L9-13, L55, L200).

Do **not** append: a new gate result, a re-verified host count, or a depth/score claim. This seat makes
none of those.

## Exact proposed recheck scope (parent/integrator)

A. **Byte sweep, zero host contact, at base:**
`sha256sum corpus/knowledge/surface-census.md` → `e07750f1…`; `wc -lc` → 287/19435; compare to the
stamps row above. Expect OK; do not `stamp` it.

B. **Static source reconciliation, zero host contact** (all blobs at base):
`grep -cv '^#' corpus/surface-census.tsv` → 35, classes 20 asset/15 runtime, 4 `# scan` dirs, direct
children 4/6/5/2; `grep -cv '^#' corpus/state-shape.tsv` → 22 with kinds 9/8/3/1/1;
non-comment `corpus/drift-symbols.tsv` → 20; `corpus/drift-baseline.tsv` → 15 rows / 9 sha256.
Static script semantics: `grep -n 'DEGRADED\|substrate-absent' corpus/surface-census.sh` →
`821,823,880`; selftest case order 1–16 with case 10 = sqlite-unavailable, 11 = required-table-gone.

C. **Host rows — do not run by this/any read-only seat.** `R11-01`, `R11-02`, `R11-03` are
`[substrate]`-tagged; `claim-ledger.sh:397-398` prints `DEFER id reason=substrate-absent` and does not
run them. Re-running the census on this host would produce `GONE`/`FAILURES`, not the entry’s CLEAN, and
would prove only substrate absence. If substrate returns, re-run R11-01/02/03 and re-measure the
2026-09-28 figures in one reviewed commit.

D. **Post-append gate (after integration):** `claim-ledger.sh docs` (24 entries / 21 row-linked, ids
resolve, entry still stamp-pinned), `claim-ledger.sh stamps` (row matches new bytes), `R12-03` count
(`grep -c '[^[:space:]]' corpus/stamps.tsv` must stay 63 unless the migration is documented).

## Provenance (exact revisions)

- Base `c2cab35bc92e57e39e5489bac3386db078345b3f`; doc last content change `2486643` (r14, added the
  `Reverify:` line); doc unchanged since.
- `corpus/surface-census.sh` sha `275d8294a94e…` (886 lines); behavior changes: `301b9ec` (r11,
  DEGRADED) and `fecee87` (r18, skip-case).
- `corpus/surface-census.tsv` sha `4af0dbcc81fd…`; note-only change `587fda0` (r15).
- `corpus/state-shape.tsv` sha `c84939050de8…`; unchanged since `03477c0` (r10).
- `corpus/drift-symbols.tsv` sha `dca651da9183…`, 20 rows; changed by `4b8c018` (r13).
- `corpus/drift-baseline.tsv` sha `90c2d7a52360…`, 15 rows / 9 hashes; unchanged since `e64e81b` (r9).
- Stamp tuple history for this path: r11 `2dc519fa/285/19335` · r13 `bcd4217e/285/19385` ·
  r14–r21 `e07750f1/287/19435`.

**Concurrency note (does not affect this audit):** the tree was clean at audit start; between
18:34–18:38 four unrelated files gained uncommitted sibling edits (`corpus/QUALITY.md`,
`corpus/SOURCES.md`, `knowledge/onepassword-machine-credentials.md`,
`knowledge/vault-openbao-token-lease-lifecycle.md`), which is why a *worktree* stamp scan now reports
10 stale rows. All claims here are computed against base blobs; `surface-census.md` and `stamps.tsv`
are unmodified (`git diff --quiet` exit 0). No sibling wrote this seat’s target.

## Append-only preservation requirement

- Preserve the r10 header, `Gates observed this round`, `Why this gate exists`, every §Bounds bullet and
  the `Falsification` list verbatim. Corrections go in a new appended §Errata with dates and citations.
- Preserve the `Reverify:` line and its five ids; if ids are added, they must already exist in
  `corpus/claim-ledger.tsv` (`docs`/`idref` would fail otherwise). Never delete an id to “refresh” the
  entry.
- If the errata changes the doc’s bytes: update the one `stamps.tsv` row in the **same reviewed commit**
  and record the superseded tuple in the round’s migration journal. Never re-pin unchanged bytes; never
  re-pin by `stamp`’s whole-row-set rewrite without naming every path (`claim-ledger.sh:22` records
  round 12 losing 18 rows to an in-flight `stamp` of 10 paths; `R12-03`’s 63-row count is the only guard).
- Do not “repair” B3/B7 by editing `drift-baseline.tsv` / `state-shape.tsv` from this lane; those are
  shared sources owned elsewhere. The errata cites them; it does not restate their numbers as new pins.

## Pin-debt cross-check (fleet-level; brief, evidence only)

- **Base stale rows: 6**, computed against base blobs — `knowledge/config-layering.md`,
  `knowledge/handler-on-disk-state.md`, `knowledge/handler-trust-boundary.md`,
  `knowledge/janitor-env-contract.md`, `lessons/round-18.md`, `LOG.md`. The round-21 lesson lists the
  first five (`lessons/round-21.md:85`); `LOG.md` is the uncounted sixth. The plan’s “five stale stamps”
  is therefore consistent with the corpus-owned five, not with the whole ledger. **This entry is not
  among them.**
- **“Nine deleted stamp rows” is not reproducible from committed history.** `corpus/stamps.tsv` has nine
  revisions; comparing the full path set of every revision in order, **no path ever disappears**;
  ever-stamped set = current set = 63, duplicates 0. Recommendation: the integrator should require the
  verifier to name the nine paths and the revision range before any “restore”; a restore from names
  alone would fabricate pins. The only documented loss class is uncommitted/in-flight
  (`claim-ledger.sh:22`, r12’s 18-row stamp), which committed history cannot show.
- `R18-02` already pins the substrate-tag surface at 11; this entry’s reverify rows are part of that
  deferral set, not a freshness failure.

## Checks parent should run after integration

`sha256sum corpus/knowledge/surface-census.md`; `bash corpus/claim-ledger.sh docs`;
`bash corpus/claim-ledger.sh stamps`; `grep -c '[^[:space:]]' corpus/stamps.tsv` (63). Do **not** run
`corpus/surface-census.sh` or `drift-pins.sh` on this host: substrate absent, no verdict is producible.

## Unresolved

- Whether “16 published hashes” ever had a source outside `drift-baseline.tsv` — nothing in corpus,
  lessons or scorecard supports 16; treated as an authoring error, not drift.
- Live `$STATE` child count (5 vs declared 6) — unverifiable while substrate is absent.
- Identity of the “nine deleted stamps” — no path or revision supplied; not reproducible.
