# RevScorecardShape — compliant round-28 SCORECARD.md section skeleton

Companion artifact to `RevScorecardShape.md` (the report). **PLACEHOLDER text —
not committed, not staged, no file written.** Every `<…>` is an unresolved
placeholder; L1 fills only with measured values.

Findings F1–F9 and the required-content checklist are in
`.ufo/waves/round-28/build/RevScorecardShape.md`.

## Shape rules this skeleton obeys

* Two sections, both with `SEC_RE`-conforming headings
  (`## Round 28 — pre-move (…)` / `## Round 28 — post-move (…)`), each carrying
  its own six-axis table — F1, F2.
* Every axis cell carries a pointer `is_row`/`stamp_index` accepts: a resolving
  `R<d>-<d>` ledger row id **or** a path present in `corpus/stamps.tsv`
  (e.g. `corpus/lessons/round-28.md`). `S0xx`/`QM2x`/`M28-x` are **not**
  pointers — F3.
* The frozen counting commands are quoted **verbatim**, `<out.json>` included —
  F9.
* Stagnation statement and planned-next present; no capability row — F7, F8.

## The skeleton

```markdown
## Round 28 — pre-move (repo HEAD `<BASE-sha>`, round-27 close)

Frozen BASE `<BASE-sha>`; claims file `plans/round-28.md` committed alone first
(`<claims-sha>`); START census `.ufo/waves/round-28/census-start.txt` (exit 0,
<n> W04). All six axes sit at 9; the last capability entered round 25, so with
window3 (rounds 26-28 without one) the stagnation nudge cannot fire before
round 29; no waiver, capability, retirement or promotion is claimed. Round 28
declares <n> claim(s): C1 (<axis>), C2 (<axis>).

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| depth | 9 | `<row-id-or-stamped-path>` | <round> |
| coverage | 9 | `<row-id-or-stamped-path>` | <round> |
| operability | 9 | `<row-id-or-stamped-path>` | <round> |
| freshness | 9 | `<row-id-or-stamped-path>` | <round> |
| calibration | 9 | `<row-id-or-stamped-path>` | <round> |
| adjacency | 9 | `<row-id-or-stamped-path>` | <round> |

## Round 28 — post-move (claims <ids>; measured, falsification follows)

| Axis | Before -> after | Evidence and bounded interpretation |
|---|---|---|
| freshness | 9 -> 9 | C1: `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py <rev> <label> <out.json>`: BASE <before-n> -> after <after-n> (<predicate words>). Sourced <S-ids>. `<row-id-or-stamped-path>` |
| calibration | 9 -> 9 | C2: `python3 -I -B .ufo/waves/round-28/tools/c2-measure.py <rev> <label> <out.json>`: BASE <before-n> -> after <after-n>. `<row-id-or-stamped-path>` |
| depth | 9 -> 9 | <unchanged-claim>. `<row-id-or-stamped-path>` |
| coverage | 9 -> 9 | <unchanged-claim>. `<row-id-or-stamped-path>` |
| operability | 9 -> 9 | <unchanged-claim>. `<row-id-or-stamped-path>` |
| adjacency | 9 -> 9 | <unchanged-claim>. `<row-id-or-stamped-path>` |

Measured revision `<measured-sha>`; exact argv/exits and receipts
`.ufo/waves/round-28/final/<files>`; separability overlays `<paths>`. Axis
scores stay as stated (9 -> 9); no capability, retirement or promotion is claimed.

Planned next (not executed): <1-3 claims, each with its target axis or capability>.
```

## Notes for the integrator

* `pre-move` pointers should be the **BASE** values of the rows named;
  `post-move` pointers the **after** values. `cells_evidence`
  (`corpus/claim-ledger.sh:1052-1092`) re-runs cited rows against the *current*
  tree, so a pointer whose expectation moved between BASE and after can go red.
* `R13-01` (heading count 33→34) and `R24-06` (heading digest) must be
  re-migrated **after** the final heading text is fixed — renaming 26/27 to the
  conforming form changes the digest again (F4).
* `corpus/SCORECARD.md` is stamp-pinned (`corpus/stamps.tsv` row 3); re-stamp
  with the **full** path list, `stamp` refuses to shrink (F5).
* Round 26/27's own headings (`SCORECARD.md:1017`, `:1081`) must be repaired for
  the cell audit to reach round 28 at all (F1).
