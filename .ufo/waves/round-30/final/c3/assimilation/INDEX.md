# C3 assimilation — receipt index (seat XAssimCol, round-30 BUILD, 2026-11-03)

Scratch work tree (not a deliverable, deleted with the seat):
`/fast/scratch/hyaku/kagi-r30/XAssimCol/` — `scratch-mirror/` (lane `corpus/` copy with
LF-restored `SOURCES.md`, the 3 re-pointed entries, the 8 appended rows), `gate-probe/` (same
plus single-line entry headers and the 8 provenance rows), `bodies/` (fetched bytes),
`build.py`, `capture.py`, `report.py`.

| artifact | what it proves |
|---|---|
| `id-lists.txt` | reg-ids / staged-ids / `comm -12` collisions, 0–3-space-tolerant pattern |
| `renumber-map.txt` | 8-row map verified per document (URL in row = URL the entry cites), plus the staged package's own S053–S060 documents |
| `normalized-rows.md` | the 8 rows in fleet schema, append-ready (12 pipes, no `\|`, cadence only) |
| `recheck-prose-stripped.md` | the removed `recheck` prose verbatim, for the lesson Gate |
| `used-by-derivation.txt` | which entry cites which row, with line numbers |
| `c3-counters.txt` | the frozen C3 counters run in the mirror (`8`, 3 files, `rows=60`, `CR=0`) |
| `census-fleet-validate-baseline-crlf.txt` | fleet `validate --file` on the unchanged mirror: exit 1, `E12` ×52 |
| `census-fleet-validate-after.txt` | same mirror, LF-restored + 8 rows appended: exit 0, `ok` (W04 ×14 only) |
| `census-fleet-metrics-after.txt` | `rows=60 tier.A=57 tier.B=1 tier.C=2 mined=56 queued=1 rejected=3` |
| `census-lane-gate-mirror-as-copied.txt` | lane gate on the faithful adoption: `FAILED findings=16` |
| `census-lane-gate-probe-lane-shaped.txt` | lane gate after the two shape fixes: `CLEAN (rows=60 …, captures=60)` |
| `census-lane-gate-production-baseline.txt` | read-only lane gate at BASE: `CLEAN (rows=52 …)` — the delta baseline |
| `source-fetches-append.tsv` | 8 capture rows, 16 fields, declared profile, 2026-11-03 |
| `capture-notes.md` | per-source HTTP/bytes/revision/normalization/quote/location |
| `entry-source-headers-draft.txt` | one-line `source:` headers that make the lane gate accept the entries |
| `drift-findings.md` | digest reproducibility, gitleaks feature-complete status, stale API counts, S060 evidence note |

Report: `.ufo/waves/round-30/build/XAssimCol.md` (identical copy at
`.ufo/waves/round-30/XAssimCol-report.md`).
