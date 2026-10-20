# Falsify — AttackEntry01: corpus/knowledge/adjacency-breadth.md

Axes: **calibration (C1)**, **freshness (C2)**. Wave: falsify (integrated tree frozen by `integration-manifest.json`). No host gate, launcher, package manager, loopback/CDP probe, or installation was run; only read-only byte/git inspection of the frozen clone. Observed tree hashes recorded below under the wave freeze.

Observed integration landing: `git rev-parse HEAD master` = `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (matches `falsify-start.json.integration_landing`). Base `c2cab35bc92e57e39e5489bac3386db078345b3f` present.

## 1. Byte identity at all four comparison points — UNCHANGED, zero edits

| point | sha256 | lines | bytes |
|---|---|---|---|
| live worktree (`sha256sum`/`wc` 2026-10-20) | `94ee01d7f0b010316d3d21d1103cb3f9c93459fbaec0ea22546637b670c35e36` | 161 | 7729 |
| frozen-before stamp row (`frozen/before/corpus/stamps.tsv:9`) | same | 161 | 7729 |
| base blob (`git show c2cab35…:corpus/knowledge/adjacency-breadth.md`) | same | — | — |
| landing blob (`git show 8ada17a…:…`) | same | — | — |
| `integration-manifest.json` entry (path key, lines 112–116) | same | 161 | 7729 |

- `git log -- corpus/knowledge/adjacency-breadth.md`: exactly one commit, `bc1af88` 2026-09-29 (round 17). `git diff c2cab35 8ada17a -- <path>` empty. **Unchanged prefix = the whole file**; no appended correction exists and none was owed.
- Entry01's "appended correction not needed" prediction is confirmed: the doc self-dates its only host observation (2026-09-29, `:5`) and bounds host-dependence (`§Bounds` 7 "Host access is required") and no-scheduling (9).

## 2. Stamp record — pointer fresh, no deletion, no laundering

- Stamp row identical at base, frozen-before, and live `corpus/stamps.tsv:11`: `94ee01d7… 161 7729`.
- `frozen/before/corpus/stamps.tsv` sha256 = `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b` = `git show c2cab35:corpus/stamps.tsv` — frozen-before **is** the base snapshot, not a doctored middle state.
- Membership base→live (LC_ALL=C sort, comm): **6 added** (`feature-claims.json`, `feature-claims.py`, `feature-bound-credential-review.md`, `round-21-verifier-spotcheck.md`, `round-22.md`, `revision-audit.py`), **0 removed**. 63→69; `R12-03` expectation now `^69$`.
- Full-set restamp recorded: `integration-pin-check.json` `STAMPED: n=69`, stamp_exit 0; audit `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`, exit 0. Live stamps.tsv = `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` / 69 / 7213 = manifest value.
- Nine dropped lines: `round21-migrations.json` `removed_members: []`; the nine `changed_stamp_records` are LOG, PROVINCE, SCORECARD, SHONEN, SKILL, corpus/README, corpus/claim-ledger.tsv, op-ref-consumption.md, op-ref-probe.sh — **this entry's path is not among them**, and its row was never deleted on master (count 28→63 monotonic per Entry01; this seat confirms the row present and value-identical at base and landing).

## 3. Dependency closure — all byte-fresh to the same pins

`scope-gate.sh` `078a260184e25282096ef5f611b01ac1fb97deddb52d78facc1d551ff61f8082`/1129/55002; `adjacency.tsv` `4d9bfb1145aa46290b1184f24a8b230db71fc71b72d5d688eac9dfa7811f9549`/83/5660; `surface-census.tsv` `4af0dbcc81fdb7229f816bf23920174b1d699ba279405272fb78c5922f368992`/54/4752 — each equal live = base = manifest = stamped row. No stale-byte edge in the entry's cited basis.

## 4. Pointer freshness vs unavailable source facts

- **Pointer freshness: FRESH (byte-provable).** Stamp certifies bytes, lines, size only; no date, no verdict.
- **Source facts: UNAVAILABLE, honestly bounded.** The only host observation is dated 2026-09-29 (21 days old); `182/8/174` and aggregate `94/2, 15/2, 48/1, 2/1` cannot be re-verified without a host gate (prohibited this wave). This is not a hidden defect: the doc itself carries the date and the two bounds. Restamping unchanged bytes would have added zero evidence — correctly not done.
- Byte-fresh ≠ re-verification: `claim-ledger.sh verify` compares hash/lines/bytes only. Consistent with the round contract's "historic statements remain historic."

## 5. Calibration metadata (Entry01 F1) — correction landed, append-only

- Old claim: `corpus/README.md:46` and `SCORECARD.md:306` said "13 bounds". Recount on live tree: `§Bounds` = **9** numbered items (awk `^[0-9]+\. \*\*` in the Bounds section); distinct failure tokens = **13**. Entry01's mismatch is real, not a build artifact.
- Landed correction: `corpus/README.md` appended block (lines ~129–131): "the old '13 bounds' index claim refers to failure tokens, not the adjacency-breadth Bounds list (Entry01 audit)" + "All old index totals retain their recorded-round context". `SCORECARD.md:719-720` appended the same historical-locator correction naming Entry01. **No in-place rewrite** of either historical index cell — the round-17 context rows still read as filed history; nothing laundered.
- Live hashes match manifest exactly: README `59271ca00241959c92aa34a258b6e1e42a4bf46b0dc7d40e9e16b8b57b1707f3`/136/23615; SCORECARD `748790b416547fbbc66dcdc33907c7a2aa3fcb01badb1dd99965398a82bf132d`/771/93172; LOG `fffb1e46f539795ab0fb1e1879546b0461472f280cfc54e7251da4029fbc3538`/1102/78729.

## 6. Findings

### F-A1 — Low (calibration): unqualified "live leaf ratios" survives in the historical index row
`corpus/README.md:44` still reads "live leaf ratios 20/4, 105/2, 4/1, 53/1". The appended correction fixes the "13 bounds" label but not this wording; the doc dates the measurement 2026-09-29. Evidence: live README bytes above, `grep -n 'live leaf'`. Proposed: a future append-only erratum adding the qualifier ("pinned leaf ratios, 2026-09-29") beside the existing block; do not edit the historical row in place. No laundering occurred — the old text is preserved and disclosed, so this is residual wording, not a violation.

### F-A2 — Informational: exact old R16-01 expected line is not printed in the live note
`R16-01`'s ledger note says "plus breadth extension" without the exact old expected string; the old→new tuple set lives in `round21-migrations.json` (`rewritten_claim_rows` = R12-02, R12-03, R13-01, R13-02, R14-01) and the old regex is recoverable from `git show aea7a4301:corpus/claim-ledger.tsv`. Historic statements remain historic; no expectation was rewritten for this entry. Acceptable under QM14; optional future hardening: print the old R16-01 line in the migration note.

## 7. Admissibility verdict

**ADMIT (C2 pass for this entry).** Pointer freshness is proven byte-exact at base, frozen-before, landing, and manifest; the file is unchanged since its round-17 introduction; the stamp row survived every snapshot with value identity and zero member loss; unavailable host currentness is honestly bounded by the entry's own dated text rather than restamped into false currency; the Entry01 calibration correction landed append-only with named provenance and intact history.

## 8. Limits

- Host gate outputs (`182/8/174`, aggregates, selftest/falsify PASSes) unobserved — prohibited this wave; parent may run `corpus/scope-gate.sh [--selftest|--falsify]` post-integration (selftest is hermetic; `--falsify` is operator-only).
- No external source exists for this host-observation contract (no `SOURCES.md` S-row) — structural, not a defect.
- Revision-audit rerun not executed here (parent's single global rerun); recorded `integration-pin-check.json` results cited as landed evidence.

Report trailer: `.ufo/waves/round-22/falsify/AttackEntry01.md` (relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`).
