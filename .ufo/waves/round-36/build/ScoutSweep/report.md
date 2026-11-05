# ScoutSweep — report (kagi round 36, attempt 2)

Seat: `ScoutSweep` (scout). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Read-only on the lane; all experiments ran on copies under
`/fast/scratch/hyaku/kagi-r36/ScoutSweep/`.

Full evidence with quoted code and `path:line` refs:
[`.ufo/waves/round-36/build/ScoutSweep/recon.md`](recon.md).

## Verdict

**The candidate as specified in the seat brief (F1–F4, "Nothing else changes") does not
reach C1 = 0 on the tree the round actually lands.** F1+F2 alone on the frozen BASE
measures C1 = 0, but the landing tree also carries three new ledger rows
`R36-01..R36-03`, and that moves the live claim-row count 79 → 82, which makes three
*other* self-count cells stale — a second population the plan's C1 section does not name.
Measured on the L1's candidate tree: **C1 = 3**. Measured after the three doc cells are
migrated 79 → 82: **C1 = 0**. The L1 has since applied exactly that migration; the
current lane tree measures **C1 = 0** and **C2 = 0**.

The L1's landing is therefore correct as it now stands. The finding below is what the
plan froze wrongly and what the L1 had to add beyond the stated F1–F4 set.

## Numbers (all measured, never estimated)

| reading | BASE `cb8cb65` | L1 candidate tree | L1 landing tree (live) |
|---|---|---|---|
| `bash plans/round-36-c1.sh` | **4** | **3** | **0** |
| `bash plans/round-36-c2.sh` | 15 (committed control) | — | **0** |
| sweep SD5 | 3 | 0 | **0** |
| sweep SD6 | **3** | 3 | **3** (unchanged) |
| `self-counts.py` `stale` | 1 | 3 | **0** |
| `self-counts.py` `unlocated` / `ambiguous` | 0 / 0 | 0 / 0 | **0 / 0** |
| `cells` verdict | `POLICY (cells=258 … policy=2)` | — | `POLICY (cells=270 … policy=2)` |

The two `policy=2` entries are pre-existing (`R29-01`/`R29-02` use `python`, not
`python3`, so `ledger_command()` refuses them) and are the routed reds the plan names.

## Findings

**F-1 (decisive).** The candidate's residual 3 is *not* SD5 — SD5 was already 0. It is
three new stale cells: `SC-SKILL-CLAIMS` (`SKILL.md:46`), `PV-CLAIMS` (`PROVINCE.md:73`)
and `RD-LEDGER-ROWS` (`corpus/README.md:64`), all bound to `ledger:R21-04`, whose live
command `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` returns 82 once
`R36-01..R36-03` exist. **Minimal extra edit set: move `79` → `82` in those three cells,
plus `R21-04`'s expect `^79$` → `^82$` (the latter is needed for `verify`, not for C1).**
Measured: with the three doc cells migrated, C1 = 0.

**F-2.** Three further ledger rows pin counts/digests over memberships the round changes,
and the plan names none of them: `R13-01` (`grep -c '^## Round ' SCORECARD.md`,
44 → 46), `R24-06` (`row-identity.sh scorecard-rounds` digest 44 → 46), `R24-14`
(`row-identity.sh ledger-ids` digest 79 → 82). They are re-run as pointer evidence by
`cells`, so leaving them stale makes the new section's cells unresolvable. The L1
migrated all three.

**F-3 (SD5 code proof).** SD5 reads the **last** `## Round` heading *in file order*, not
the highest round number (`grep -nE '^## Round' | tail -n 1`), and only the calibration
row **inside** that section. Measured: swapping the round-36 `pre-move`/`post-move`
sections returns SD5 to 3. Two further traps: the calibration row must literally start
`| calibration |` (SD5's regex `^\| *calibration *\|` does **not** strip `*`, unlike
`claim-ledger.sh`'s cell parser), and the row must be in the last section, not an
earlier one. A `## Round 36 — post-move` calibration row naming the three reds satisfies
SD5 **iff** post-move is the file's last `## Round` section — the landing tree satisfies
this (heading at `SCORECARD.md:1398`, calibration row at `:1404`).

**F-4 (armed row / locator).** `SA-CAP-CENSUS-SELFTEST` (`corpus/self-counts.tsv:87`) binds
`SCORECARD.md` with locator `^\| source registry \+ census gate \|.*?`--selftest` ([0-9]+)
cases\b` and `ledger:R21-03`, and the live value comes from **executing** that row's
command and matching its **last non-empty output line**. The locator is a leftmost
`re.search`: a second bare number later in the cell is harmless, but a **second
`` `--selftest` `` occurrence earlier in the cell wins**. The L1's phrasing (70 right
after the first `` `--selftest` ``, with the historical 59 later as bare prose) captures
70 correctly — verified against the regex directly.

**F-5 (fail-open in the frozen counter).** `plans/round-36-c1.sh:22-24` extracts only the
`stale=` field. A population that was **not measured** still reports `stale=0`, so:
renaming the capability cell (`UNLOCATED`) or duplicating it (`AMBIGUOUS`) makes the C1
counter print **0**, rc 0. Both measured. The landing tree is not in that state
(`unlocated=0 ambiguous=0`), but the counter cannot prove it from its own stdout.
**Recommendation: land the full `SELF_COUNTS:` summary line beside the integer in the
receipt** so `unlocated=0 ambiguous=0` is on the record. (The frozen instrument is
read-only to me; no patch proposed.)

**F-6 (plan/instrument mismatch).** `plans/round-36.md:35,43` states the SD6 class is
**5** citations "preserved unchanged at 5", and the kill rule is "SD6 differs from 5 at
the landing revision → C1 fails". **The instrument reads SD6 = 3 at BASE and 3 at the
landing revision** (`bash corpus/claim-ledger.sh citations` → `unresolved=3`). The
*preservation* property holds; the literal "differs from 5" condition is violated at BASE
already, for a reason unrelated to the candidate. The five non-owned verifier files were
not edited (`git diff` shows none). Recommend the plan's SD6 figure be recorded as the
observed 3 — SD6 does not enter C1 (`plans/round-36-c1.sh` reads only SD5 and `stale`).

**F-7 (`stamp` semantics).** `stamp` **replaces** the row set and refuses a partial path
list (exit 2, `refusing to shrink … 'LOG.md' is pinned and would be dropped`) — measured.
`--prune` accepts a partial list but **drops every un-named row** (112 → 1) — measured.
The only safe re-pin is the **full 112-path list** — measured working
(`STAMPED: n=112`). The five paths that must be re-pinned after the candidate's edits:
`SCORECARD.md` (row 3), `corpus/SOURCES.md` (8), `corpus/claim-ledger.tsv` (13),
`corpus/release-clock.py` (98), `corpus/release-clocks.tsv` (99). Plus
`corpus/self-counts.tsv` (105), which was **already stale at BASE** — the frozen
instrument commit `cb8cb65` added the armed row without re-pinning its stamp
(`STALE corpus/self-counts.tsv sha=5fff91ce…->77ad6e22… lines=81->87`). The L1's
re-pin cures it.

**F-8 (open item for the L1).** `corpus/lessons/round-36.md` exists in the lane tree as
an **untracked** file and is **not** in `corpus/stamps.tsv` (32 lesson files are pinned;
`round-36.md` is not). If it is landed it must be pinned — and adding one stamp row
changes the stamp count, which `R12-03` pins as `^112$` and which `SKILL.md:46` /
`PROVINCE.md:73` / `corpus/README.md:65` quote as "112". **Same cascade class as F-1.**
Also: `R25-04` was re-purposed (from the round-26 `RELEASE_CLOCK: CLEAN` verdict to a
`sha256sum` byte pin of the retained round-26 receipt, sha verified `13b8540c…`); the row
note records the migration, but no `.ufo/waves/round-36/expectation-migrations.json`
journal exists (the round-26 pattern) — `.ufo/waves/round-36/` holds only `build/`,
`controls/`, `final/` and dispatch files.

**F-9 (`cells` requirements).** `claim-ledger.sh cells` needs, for each new round-36
section: heading exactly `## Round 36 — pre-move|post-move` (em dash, `SEC_RE`), **all
six axes exactly once** (`section_check` dies otherwise), and every axis cell pointed at
a resolving `R<n>-<n>` id or a `corpus/stamps.tsv` path. Pointers are then *re-run*
(`cells_evidence`), so a cell citing `R36-01` makes `cells` contingent on the C1 landing
(its command is `bash plans/round-36-c1.sh`, expect `^0$`). A `## Round…` heading that
matches neither `SEC_RE` nor the blocked round-20 line is fatal.

## Dead ends / limits (stated honestly)

* `row-identity.sh revision-added` cannot be evaluated on this host
  (`ROW_IDENTITY: SETUP (revision-audit --history failed)` — history commit `c2cab35b…`
  unreachable in this clone). `R24-15` is red at BASE for that reason; pre-existing, not
  round-36's.
* Full `claim-ledger.sh verify` was run to completion on BASE (stamp section captured);
  on the landing tree I relied on the L1's receipt plus my own recomputation of all 112
  stamp rows — the same comparison `verify` makes. `verify`/`cells` exit 141 on the
  inherited `MISSING-ID` history (`LOG.md:1683 R32-1` etc.), present at BASE.
* `cells` on the F1–F4-only fixture exits 141 with `MISSING-ID` (its new row cites
  `R36-01`, absent on that tree). I did not build a variant citing only pre-existing
  ids; the contingency point is established from the code path.
* SD1–SD4 and SD7–SD9 read 0 on both trees (summary line only; not measured
  individually).
* C2 was measured only as the counter's integer; I did not re-observe the 20 feeds.
* **No tools installed or upgraded** — the whole job ran on the host's existing `bash`,
  `python3`, `git`, `rsync`, `sha256sum`, `awk`, `sed`, `grep`. Nothing to record under
  the operator's tooling directive.

## Files delivered

* `.ufo/waves/round-36/build/ScoutSweep/recon.md` — full recon with quoted code and `path:line` refs
* `.ufo/waves/round-36/build/ScoutSweep/report.md` — this file
* `.ufo/waves/round-36/build/ScoutSweep.md` — seat report (the `Report:` trailer path)

Scratch `/fast/scratch/hyaku/kagi-r36/ScoutSweep/` was removed after the receipts above
were copied into the build dir. No file in the lane repo was edited, moved or deleted by
this seat (the only lane write by this seat is inside
`.ufo/waves/round-36/build/ScoutSweep/`, which is this seat's own build directory).
