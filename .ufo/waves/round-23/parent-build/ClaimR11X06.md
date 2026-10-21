# ClaimR11X06 — R11-06 transcript-baseline obligation (critic)

Seat `ClaimR11X06` (critic, leaf, read-only, no subagents). This file is the seat's only write.
Observed revision: HEAD `d218603b74099ddca0bd8f869516fc41db0979bf` (`plans/round-23.md:3`).
Row `corpus/claim-ledger.tsv:20`: line sha256 `d77e2c5a…6388` (177 B). It is byte-identical to
`.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:20` and unchanged in the in-flight tree at 00:53.
At first read, five files matched their `corpus/stamps.tsv` rows: `transcript-scan.sh` `2d60981b…a23` (282 L / 14709 B),
`claim-ledger.tsv` `e6806968…`, `claim-ledger.sh` `cf56f9ea…`, `checklist.tsv` `28bd238e…` and
`knowledge/transcript-hygiene.md` `4e041fd8…`. Later, L1 changed three files in flight. `claim-ledger.tsv` gained
R23-01/02. In `claim-ledger.sh`, only the python allowlist (`:161`) changed; lines 140-146, 416-419, 816-820 and 828,
all cited below, are unchanged. `SCORECARD.md` gained appended round-23 sections; its R11-06 cells are unchanged.
I executed no gate, handler, op, vault, sqlite3 or host-state command. Every outcome below comes from code and
committed receipts.

## Verdict

- **Supported:** the expectation is a real historical measurement. Exit 1 and the 300 s timeout are justified.
- **Refuted as checked properties:** the note claims "2 prose collisions" and "5 credential tripwires empty". The
  ERE plus exit certify only one thing: exactly **two non-empty members out of 773**. Those are 768 HIT cells
  (24 columns × 32 patterns) plus 5 tripwire tables. The row never checks which two members fired, how many rows,
  prose versus key, or whether the tripwires are empty.
- **Self-contradiction:** the gate's own committed must-fire selftest database satisfies R11-06 exactly (§3).
- **Unresolved:** the current host state. The database that was measured was gone by 2026-10-14. Nobody has
  re-measured since then.

## 1. Causal chain

- **Row:** `bash corpus/transcript-scan.sh` | ERE `^TRANSCRIPT_SCAN: HITS=2 \(cells=[1-9][0-9]*` | exit 1 | 300 s |
  tag `[substrate]`. The rationale is in the ledger header, `claim-ledger.tsv:7-10`.
- **Runner (`claim-ledger.sh`):**
  - `:416-419` defers the row when `substrate_present()` (`:140-146`) is false. That function tests
    `-x $HOME/.local/bin/the-janitor` or `KAGI_SUBSTRATE`.
  - The policy check passes (`:160-192`).
  - The command runs under `cd $ROOT; timeout -k 5 300 bash -o pipefail -c` with the inherited environment
    (`:425-427`).
  - The row passes only if the exit code matches and the ERE matches the last non-empty line (`:428-444`).
  - The runner never prints the output or the scanned `db=` (`:84-86`). A pass therefore records no database
    identity.
- **Gate (`transcript-scan.sh`):**
  - The database is `${THE_JANITOR_STATE_DIR:-$HOME/.local/state/the-janitor}/xdg-data/opencode/opencode.db`
    (`:34-35`).
  - If the file is missing, the gate prints `db not found` and exits 2 (`:261`).
  - It takes a mktemp snapshot of the database (`:266-274`).
  - `hits` goes up by 1 for each firing (table.column, HIT-pattern) cell (`:143-152`) and by 1 for each
    populated tripwire table (`:169-177`). **It counts cells, not rows.**
  - The summary line is printed at `:278-280`.
  - Exit is 1 whenever hits > 0, **even when `schema-absent>0`** (`:282`).
- **Selftest (R11-07's command):** asserts exit codes only (`:208-256`). It never checks summary fields or the HITS
  count.

## 2. Is the expectation justified?

| Element | Status | Evidence |
|---|---|---|
| `HITS=2 (cells=…` last line | **Supported (historical).** Recorded as `HITS=2 (cells=888 patterns=32+5 warns=2 schema-absent=0)`, exit 1, tripwires 0/5, `--classify` prose for both rows. | `corpus/lessons/round-9.md:122-126` (2026-09-28); `round-6-aggregator-audit.md:39`; `round-12.md:24` is an excerpt without `schema-absent`. |
| ERE precision | **Weak.** Nothing after `cells=` is anchored, and any `cells≥1` passes. A round-22 exact-line proposal exists but was not applied. | `.ufo/waves/round-22/build/Entry23.md:179-189`; `falsify/AttackEntry23.md:81` |
| Exit 1 | **Justified.** Since hits>0 ⇒ 1, it adds nothing beyond HITS>0, and it masks the fail-closed schema exit 2. | `transcript-scan.sh:282` |
| Timeout 300 | **Justified, fail-closed.** About 920 sqlite3 calls. Historically the whole checklist, including H7's scan, took about 2.3 s (round 15). An expired run becomes `FAIL reason=timeout`, never a pass. Not measured against database growth. | `claim-ledger.tsv:33` (R15-01 note); `claim-ledger.sh:428-430` |
| Note "2 prose collisions" | **Not checked.** The prose/key split is `--classify`, and no ledger row runs it (open since round 14). | `lessons/round-14.md:185-187` |
| Note "5 tripwires empty" | **Not checked.** A populated tripwire simply adds to HITS. | `transcript-scan.sh:169-177` |

## 3. Counterexample (false-clean): minimal synthetic falsifier for L1 (not executed)

**F1: the gate's own seeded database.** Use the DDL and inserts of `transcript-scan.sh:187-203` unchanged: 16
tables, one `part` row carrying the selftest's fake vault-reference marker (`:202`), and one `credential` row
(`:203`). Place it at `$S/state/xdg-data/opencode/opencode.db`. Run R11-06's exact command from the repo root:

```sh
env -i PATH=/usr/bin:/bin LC_ALL=C HOME=$S/home TMPDIR=$S/tmp THE_JANITOR_STATE_DIR=$S/state bash corpus/transcript-scan.sh
```

Then apply the row's exit and last-line rule.

Expected output [INFERENCE from code]:
- `HIT part.data …` and `HIT tripwire=credential rows=1` lines.
- Last line: `TRANSCRIPT_SCAN: HITS=2 (cells=888 patterns=32+5 warns=0 schema-absent=0) db=…`.
- Exit 1. **R11-06 passes.**

The row accepts the canonical worst case as its benign baseline. That worst case is a persisted vault ref plus a
populated credential table: the two findings `knowledge/transcript-hygiene.md:16-20,39-46` exists to catch.

Variants and acceptance:

- **F1w** (survives the round-22 exact-line proposal): add the field names `access_token` and `api_key` to that
  part row. This gives `warns=2` while HITS stays 2, so the output equals the proposed exact ERE up to `db=`.
- **F3** (schema masking): take C0 below and drop the `credential` table. Output: `NOTE tripwire=credential ABSENT`,
  `schema-absent=1`, exit **1**. The current ERE passes it; the exact-line ERE catches it.
- **C0** (control that must pass both before and after a fix): one prose `xai-` text in `part.data` and its event
  in `event.data`, two WARN names, empty tripwires. Output: `HITS=2 … warns=2 schema-absent=0`.
- **Acceptance for any fix:** F1, F1w and F3 fail R11-06; C0 passes.

**Realistic host form [INFERENCE, grounded].** The baseline rows lived in a database that no longer exists
(`lessons/round-18.md:16,25`). Suppose the substrate is reinstalled with a fresh database, and one text part
carries a real `xai-` key. That key would land in `part.data` plus `event.data`, the same two cells the 2026-09-28
prose fired (`transcript-hygiene.md:36-37,73-76`; `lessons/round-8-aggregator-box3-coldrun.md:21`). The result
reproduces the baseline signature `HITS=2`, exit 1, while the row's note says "2 prose collisions".

Consumers that would show green:
- `verify`, where a passing row is silent.
- `cells`, for five SCORECARD cells.
- `transcript-hygiene.md:12` (`Reverify: R11-06, R11-07`).
- Checklist H7 (`checklist.tsv:40`), which also pins `HITS=2` and accepts any `warns`/`schema-absent` value.

The documented bound claims the opposite sensitivity:
- `knowledge/claim-ledger.md:311-314` says "a legitimate new session would flip it". That is false for any
  session that only adds rows to cells that already fire, or adds WARN cells.
- Bound 3 says the countermeasure is "the sibling gate's own selftest" (`:319-322`). For this line no such
  countermeasure exists.

## 4. Deferral, SKIP-SELF, hermetic synthetic mode

### `[substrate]` deferral (`claim-ledger.sh:416-419`)

Deferral preserves the obligation only as `deferred=N`. Otherwise the run is `CLEAN`, exit 0
(`substrate-deferral.md:59-61`).

The predicate does not test what the row depends on. It checks the handler binary (`:145`), but R11-06 reads the
state database (`transcript-scan.sh:34-35`), which by design outlives the handler (`transcript-hygiene.md:16-17`;
`lessons/round-7.md:45-53`). Two mismatched states follow:
- **Binary absent, database present:** the row is DEFERred while its surface still exists.
- **Binary present, database absent** (fresh reinstall, or the documented purge at `transcript-hygiene.md:113-115`):
  the row gives `FAIL exit-mismatch exit=2 want=1`. H7 accepts exactly this state (`checklist.tsv:40` note). The
  result is two authorities giving opposite verdicts on one command and one host state.

Both mismatches are latent today. On 2026-10-14 and on 2026-10-20 the handler and the state tree were absent
together (`lessons/round-18.md:16`; `.ufo/waves/round-22/build/Entry16.md:56`).

Bound 2 calls un-deferral via a stub a "correct conservative outcome" (`substrate-deferral.md:62-64`). That does not
hold for this row: with `THE_JANITOR_STATE_DIR` pointed at an F1-class database, un-deferral yields a PASS.

### SKIP-SELF

Not applicable. The command does not contain `claim-ledger.sh` (`claim-ledger.sh:816-820`), so `cells` runs or
defers R11-06 like any other row.

### Hermetic synthetic mode

R11-07 proves exit codes only. Any synthetic database with two firing members turns R11-06 green. A synthetic pass of
R11-06 is therefore fixture provenance, never host evidence. It can only serve as the §3 falsifier set.

## 5. Historical vs current evidence

| When | Observation | Source | Class |
|---|---|---|---|
| 2026-09-28 r9 | full line, exit 1, tripwires 0/5, classify prose ×2 | `lessons/round-9.md:122-126` | historical, measured |
| 2026-09-28 r11–14 | `verify` CLEAN with R11-06 included (claims=11→18) | `lessons/round-11.md:30`; `round-14.md:161` | historical pass |
| 2026-10-14 r18 | `transcript-scan: db not found` exit 2 ⇒ R11-06 FAIL; deferred after the repair | `lessons/round-18.md:25,28`; `LOG.md:738,754` | last host contact |
| 2026-10-20 r22 | R11-06 skipped. The one retained full `verify` shows `deferred=11`, which is the 11-row tag set, so R11-06 did not run. | `.ufo/waves/round-22/final-verification.json:537-541`; `falsify/AttackActiveReview.md:86` | not run |
| d218603 | Row unchanged since r11. It can pass again only if the deleted database is restored. [INFERENCE] | this audit | current, static |

## 6. What C3 and C1 must retain for this row

### C3

I read the in-flight R23-01 fixture at 00:53. It contains only R90-01/02: no R11-06, no transcript scan, no
`[substrate]`. That is hermetic for this row; keep it so. Three things must also hold:

1. **Never put R11-06, a transcript-reading row or `THE_JANITOR_STATE_DIR` into fixtures.** A row command cannot
   scrub its environment, because the allowlist refuses assignments. So any `[substrate]` fixture row would run
   live on a host where the handler is present.
2. **R23-01 does not re-verify the SCORECARD cells that cite R11-06**: lines 62, 71, 84, 106 and 184.
   - Lines 84, 106 and 184 cite only `[substrate]` rows (R11-01/04/06, R12-01). They have zero executed evidence
     on this host, yet `cells` counts them as `row_pointed`.
   - Line 71 cites R11-06 only as a ceiling ("`R11-06` encodes host state"), not as evidence.
3. **`rows_run` includes deferred rows** (`claim-ledger.sh:415,828`; the R13-03 owner's area). Read
   `row_deferred` and the per-row `DEFER` lines instead.

### C1

In the in-flight `closure-dispositions.json` (00:46), no disposition points at R11-06.

- **D3 `fixed` does not bound R11-06.** A bare `verify` or `cells` still copies the private transcript database
  whenever the handler binary is executable. The retained round-22 run was safe for this row only because the
  substrate was absent.
- **D9 `fixed` covers the parser, not R11-06's cells.**

Record R11-06 as follows: deferred; the baseline database has been gone since 2026-10-14; the row is expected to
FAIL when the substrate returns; re-baselining needs a fresh measurement plus `--classify`. Do not record it as
"pending pass".

## 7. Smallest safe correction (tighten-only, no host run)

1. **Now, ledger and docs:**
   - Adopt Entry23's exact-line ERE. It closes F3 and the case where cells or patterns shrink.
   - Narrow the note to what the line proves: two firing HIT/tripwire members; identity, per-cell rows, prose
     versus key and tripwire emptiness are not checked, and F1 passes.
   - Keep a QM14 old/new record.
   - Append errata to `claim-ledger.md` Bound 1 (it overstates sensitivity) and Bound 3 (no selftest backs this
     summary).
2. **Real fix, code backed by selftest** (owners: R11-07 and H7/R15-01; send both a heads-up):
   - Extend the summary with metadata-only identity, e.g.
     `tripwires=0/5 key_shaped=0 fired=event.data:xai-,part.data:xai-` (sorted, no content).
   - Add selftest cases: F1, F1w and F3 must fail; C0 must pass.
   - Re-stamp the script.
   - Migrate the R11-06 and H7 EREs from the 2026-09-28 `--classify` evidence, labelled as historical.
3. **Optional tradeoff:** anchor `db=` to the default `/.local/state/the-janitor/xdg-data/opencode/opencode.db`
   suffix, so runs redirected by environment fail closed. The cost is a false failure when an operator legitimately
   overrides the state directory.

Not recommended: re-baselining HITS from any new host observation, or removing R11-06's `[substrate]` tag.

**Impacted axes:**
- **Calibration:** the note and bounds overclaim, and the row checks a count, not identity.
- **Freshness:** the baseline database is gone; the last host contact was 2026-10-14.
- **Operability:** H7 is a duplicate authority, and the deferral predicate is a proxy for the real dependency.

## Limits

- I did not execute R11-06, R11-07, H7, `verify` or `cells`. Falsifier outcomes are derived from code [INFERENCE];
  L1 should execute them hermetically.
- I did not probe host state, per the contract. Presence and absence come only from committed round-18 and
  round-22 records.
- At the start I ran `git log -1` and `git status --porcelain` once to fix the revision. `git status` may refresh
  the index stat cache; no content changed. I ran no other VCS operation.
- I read the in-flight R23-01 fixture, `closure-dispositions.*` and the round-23 SCORECARD sections as L1 work in
  progress, not as frozen evidence.
- No public source was needed; R11-06 has no SOURCES row.
- Tools installed: none.

Report: .ufo/waves/round-23/parent-build/ClaimR11X06.md
