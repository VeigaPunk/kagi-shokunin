# ScoutSweep — round-36 C1 reading recon (kagi lane)

**Seat:** `ScoutSweep` (scout) · **Lane:** `kagi-shokunin` · **Round:** 36, attempt 2
**Scope:** reconnaissance of the **C1 calibration reading**, exact line references.

**Full evidence:** `.ufo/waves/round-36/build/ScoutSweep/recon.md` ·
`.ufo/waves/round-36/build/ScoutSweep/report.md`

## Verdict

**The candidate as specified in the brief (F1–F4, "Nothing else changes") does not reach
C1 = 0 on the tree the round lands.** F1+F2 alone on the frozen BASE measures C1 = 0, but
the landing tree also carries three new ledger rows `R36-01..R36-03`, moving the live
claim-row count 79 → 82, which makes three *other* self-count cells stale — a population
the plan's C1 section does not name. The L1's candidate tree measures **C1 = 3**; after the
three doc cells are migrated 79 → 82 it measures **C1 = 0**. The L1 has since applied that
migration; the current lane tree measures **C1 = 0** and **C2 = 0**.

## Numbers (all measured)

| reading | BASE `cb8cb65` | L1 candidate | L1 landing (live) |
|---|---|---|---|
| `bash plans/round-36-c1.sh` | **4** | **3** | **0** |
| `bash plans/round-36-c2.sh` | 15 (committed control) | — | **0** |
| sweep SD5 | 3 | 0 | **0** |
| sweep SD6 | **3** | 3 | **3** (unchanged) |
| `self-counts.py` `stale` | 1 | 3 | **0** |
| `unlocated` / `ambiguous` | 0 / 0 | 0 / 0 | **0 / 0** |
| `cells` | `POLICY (cells=258 … policy=2)` | — | `POLICY (cells=270 … policy=2)` |

`policy=2` is pre-existing (`R29-01`/`R29-02` use `python`, refused by the allowlist) —
the routed reds the plan names.

## Key findings

1. **The candidate's residual 3 is not SD5** (SD5 was already 0) but three new stale
   cells: `SC-SKILL-CLAIMS` (`SKILL.md:46`), `PV-CLAIMS` (`PROVINCE.md:73`),
   `RD-LEDGER-ROWS` (`corpus/README.md:64`), all bound to `ledger:R21-04`. **Minimal extra
   edit: `79` → `82` in those three cells** (plus `R21-04`'s expect, for `verify`).
2. **Three unnamed ledger rows also move** — `R13-01` (44 → 46), `R24-06`
   (`scorecard-rounds` digest), `R24-14` (`ledger-ids` digest) — and `cells` re-runs them
   as pointer evidence.
3. **SD5 reads the last `## Round` heading in file order**, and only that section's
   `| calibration |` row. Swapping the round-36 sections returns SD5 to 3. The row must
   not be bolded (SD5's regex does not strip `*`).
4. **The armed row's locator is a leftmost `re.search`** — a second bare number later in
   the cell is harmless; a second `` `--selftest` `` occurrence earlier in the cell wins.
5. **Fail-open in the frozen C1 counter:** an `UNLOCATED` or `AMBIGUOUS` armed row still
   reports `stale=0`, so the counter prints **0**, rc 0 (both measured). The landing tree
   is clean, but land the full `SELF_COUNTS:` summary beside the integer.
6. **The plan's SD6 figure is wrong:** instrument reads **3**, not 5, at BASE and at
   landing. Preservation holds; the literal "differs from 5" kill condition is violated at
   BASE already. SD6 does not enter C1.
7. **`stamp` refuses a partial path list** (exit 2) and `--prune` silently drops the
   other rows (112 → 1) — both measured. Only the **full 112-path list** is safe. Six
   paths need re-pinning, including `corpus/self-counts.tsv`, which was **already stale at
   BASE** (the instrument commit added the armed row without re-pinning).
8. **Open item:** `corpus/lessons/round-36.md` is untracked and unpinned; landing it
   changes the stamp count and re-breaks `R12-03` and the three "112 stamps" cells.

## Dead ends / limits

* `row-identity.sh revision-added` is unevaluable here (history commit unreachable);
  `R24-15` is red at BASE for that reason — pre-existing.
* `verify`/`cells` exit 141 on the inherited `MISSING-ID` history, present at BASE.
* SD1–SD4, SD7–SD9 read 0 (summary only); C2 measured only as the counter's integer.
* **No tools installed or upgraded** — existing host tooling sufficed.

Scratch `/fast/scratch/hyaku/kagi-r36/ScoutSweep/` removed after receipts were copied
into the build dir. Lane files untouched by this seat.
