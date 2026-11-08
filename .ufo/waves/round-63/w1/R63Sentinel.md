# R63Sentinel — scoped findings (round 63, wave 1)

Seat `R63Sentinel` (sentinel). Read-only audit; receipt with every command and its
output: `.ufo/waves/round-63/build/R63Sentinel/audit.md`.
Snapshot **2026-11-07T23:03:49Z**, lane HEAD `966c469`, wave still running.

## Verdict

| check | result |
|---|---|
| 1. credential shapes (counts only) | **clean** — 29 hits over 19 files, **0 value-shaped**; every hit is a pattern name in the seat brief or a sha256 digest |
| 2. receipt paths | **clean** — every report/receipt target is under `.ufo/waves/round-63/`; no `/tmp`, `/var/tmp` or scratch path cited as evidence |
| 3. write scope | **clean** — no sibling-lane write, no host-path write, no write outside a seat's declared paths |
| 4. scratch discipline | **3 violations** — V1 (medium) 206 MB BASE tree at `/tmp/c1ck`; V2 (low) `/tmp/r63routed-task.txt`; V3 (low) stray `claims-declared.tsv.bak` at the wave scratch root |

## Violations

- **V1 (medium)** `/tmp/c1ck` — 206 MB extracted BASE tree, created 20:01:39 during the
  wave, outside the mandated `$HYAKU_SCRATCH/kagi-r63/<seat>/` root and over the 50 MB
  `/tmp` allowance. Not cited as evidence. Probable owner `R63ExecC1Counter` (its
  mandated scratch is empty and it needs a BASE tree) — `[INFERENCE]`. Fix: delete after
  that seat yields; extract under its own scratch dir.
- **V2 (low)** `/tmp/r63routed-task.txt` (3,110 B) — task-text scratch under `/tmp`,
  outside the mandated root, under the size allowance, not cited as evidence.
- **V3 (low)** `/fast/scratch/hyaku/kagi-r63/claims-declared.tsv.bak` (836 B) — the L1's
  pre-edit backup left at the wave scratch root instead of under a seat dir; byte-
  identical to `HEAD:corpus/claims-declared.tsv`.

No QA5 violation: no secret value, token, session id, vault/item/field name, cookie
value or `op://` reference path in any round-63 artifact.

## Routed to the L1

- **O3 (record defect).** The wave milestone string in `w1-spec.json` and
  `w1/swarm-registry.json` reads `C2_REFUSAL killed 0->6 … six named surviving
  mutants`, while the frozen plan's Amendment A2 (`plans/round-63.md:300`) sets
  **population 5, target killed=5** (L5 vacuous at BASE). The dispatch text predates A2.
  Frozen predicate is authoritative; the registry and seat briefs carry the stale 6.
  Reported, not amended.
- **O2.** `M corpus/claims-declared.tsv` (rounds 62/63 rows, QM64) is the only modified
  tracked lane file; no seat spec names it — the L1's own edit, in scope.
- **O1.** `base/census.md:4` names the L1 scratch tree as its measurement location; the
  plan pre-declares it "not citable evidence". Method note, not a receipt path.

## Snapshot boundary

`.ufo/waves/round-63/capture/` and `.ufo/waves/round-63/final/` did not exist at
snapshot, so QM72 (cookie removal in fetch receipts) and the `db` gate receipts are not
audited. Re-run checks 1–2 at landing.

SEAT-STATUS: complete
