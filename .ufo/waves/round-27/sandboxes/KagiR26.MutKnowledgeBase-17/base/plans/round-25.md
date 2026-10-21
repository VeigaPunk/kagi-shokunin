# Round 25 — frozen claims

Base: `4587c61a348e4528717404a68912c373f3ef4d03` (round 24 admitted, MANIFEST
closure `CloseKagi24`). L1 holds the frozen planner seat; the planning
data-walk rides wave-1 scout/reviewer/revenger/connector items. All six axes
sit at 9 (saturation line 9). The stagnation nudge does not fire: the last
capability entered in round 23 and only one completed round (24) has passed
since, below window N=3. Every axis is tied lowest, so each claim below works a
lowest non-retired axis; the three claims name three distinct axes. No
vault/account/handler/CDP action, no credential read, no `--allow-host-rows`.

Routed by the round-24 closure (MANIFEST notes): (D1) `SKILL.md:46` still says
"63 stamps + 39 claims + claim ids, round 21" while the ledger measures
83/61; (D2) make the R11-08/citations lone-clone behaviour explicit in the
verify output (default `verify`/`citations` go red in a lone clone by design,
documented only in the R11-08 note).

## Claims

1. **C1 calibration — the corpus's current-tense numeric self-descriptions
   are bound to the live value they describe (routed D1).** New
   `corpus/self-counts.py` with table `corpus/self-counts.tsv`: each row
   locates exactly one current-tense number in a committed doc (Python regex,
   one capture group, must match exactly one line) and names its live source:
   `rows:<path>` (non-blank, non-`#` lines) or `ledger:<ID>` (run that
   non-host ledger row's own command, argv without a shell, and extract the
   number from its last non-empty line with a declared regex — the ledger
   stays the single definition of each live quantity). Output: `OK`/`STALE`/
   `UNLOCATED`/`AMBIGUOUS` lines and `SELF_COUNTS: CLEAN (claims=N stale=0)`
   exit 0; `SELF_COUNTS: STALE (claims=N stale=K unlocated=J)` exit 1;
   POLICY/SETUP exit 2; `--selftest` on synthetic roots; `--root DIR`.
   Historical numbers (explicitly round-dated, in LOG/lessons/SCORECARD
   history) are out of population by rule, not by omission.
   Counting: the after tool and table run against the BASE docs vs the after
   docs (`.ufo/waves/round-25/tools/c1-measure.sh <rev>`): before `stale>=1`
   (SKILL.md:46 at least), after `stale=0`; a one-digit doc mutation turns
   it red (exit 1).
2. **C2 operability — lone-clone layout is an explicit, counted outcome
   (routed D2).** `corpus/claim-ledger.sh` detects the fleet layout (marker
   fixed by the implementation, documented); in a lone clone `citations`
   prints `CITATION_LAYOUT: lone-clone (…)`, classifies unresolved
   `ufo`/`sibling` class tokens as `FLEET-ABSENT` (counted `fleet_absent=N`,
   never as `unresolved`) and ends `CITATION_GATE: INCOMPLETE (…
   fleet_absent=N)` exit 1 — never CLEAN; lane-local misses stay
   `UNRESOLVED`. Ledger rows tagged `[fleet]` (R11-08 and any other row the
   wave proves layout-bound) print `LAYOUT-SKIP <id> (fleet layout absent)`
   in `verify`/`cells` and count `layout_skipped=N` in the summary — never
   credited as passing. In the fleet layout behaviour is unchanged
   (`fleet_absent=0`, rows run).
   Counting (scratch lone clone, empty HOME, `env -i`): `citations`
   before `unresolved=88` (57 sibling + 31 ufo, all layout) → after
   `unresolved=0 fleet_absent=88`; `verify` before `FAIL R11-08` exit 1 →
   after `LAYOUT-SKIP R11-08` + `layout_skipped=1`; controls: a planted
   lane-local broken cite stays `UNRESOLVED` (exit 1) in both layouts; in a
   fleet layout a planted missing `.ufo/…` cite stays `UNRESOLVED`.
3. **C3 freshness — every `on-release` recheck clock is bound and fired
   today (sourced).** 28 registry rows carry `recheck: on-release` with no
   named release identity, so the clock can never be observed to fire. New
   `corpus/release-clocks.tsv` binds each such row to one clock: `feed`
   (an official release feed opened this round as its own SOURCES row, plus
   the version the row's anchor names) or `rendered-quote` (unversioned live
   docs: the row's quote must still locate in a fresh fetch under
   rendered-text-v1). New `corpus/release-clock.py` checks bindings offline
   (`RELEASE_CLOCK: CLEAN (on_release=N bound=N unbound=0 observed=N
   fired=K)`) and `--observe` records a dated observation receipt; fired rows
   are re-verified and recorded, not silently re-pinned.
   Counting: `python3 corpus/release-clock.py --root <tree>` (or the
   independent `.ufo/waves/round-25/tools/c3-measure.py <rev>`): before
   `on_release=28 bound=0 unbound=28` → after `bound=28 unbound=0` with a
   2026-10-21 observation for every row. Sourced: the feed rows S033+ opened
   this round.

## Separability

C1 touches docs + new self-counts files; C2 touches `claim-ledger.sh`
layout logic and R11-08's tag; C3 adds release-clock files and S033+ rows.
Shared bookkeeping (stamps, ledger rows, SKILL registry) is integrated once.
Each counting command runs on a claim-only overlay of BASE.

## Frontier step

New SOURCES rows: the release feeds C3 binds (opened this round, Gate quotes
in `corpus/lessons/round-25.md`). Mined mistake: the stale SKILL.md:46 count
(class: current-tense self-description drift; captured-by: none — the ledger
pins live values, never the doc's statement of them; fix: C1, shown able to
fail by mutation).
