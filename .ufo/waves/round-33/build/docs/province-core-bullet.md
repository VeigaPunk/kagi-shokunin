# PROVINCE.md — round-33 NIST frontier-to-core move (draft; the L1 installs)

## Delete (byte-exact; current line 90)

```
- **Frontier — explored, not held:** NIST key-management draft status (`corpus/README.md` §Frontier; leads in `corpus/SOURCES.md` §Leads (unopened)).
```

There is no replacement Frontier line: QM33 requires the frontier entry to go in the same round as the Core entry.

## Insert (byte-exact; a new bullet under `## Core / Frontier / Adjacent (round 21)`)

Placement: immediately after the round-31 Core bullet (current line 89, the bullet ending `the NIST leads stay leads.`) — i.e. where the deleted Frontier bullet stood. The `Adjacent — report, don't absorb` bullet stays where it is.

```
- **Core, round 33 — NIST key-management guidance status:** the publication status and currency signals of the key-management family — SP 800-57 Part 1 Rev. 5 final against the Rev. 6 IPD the lane already held as S049, and SP 800-133 Rev. 2 final against the Rev. 3 IPD — plus the Part 2/Part 3 withdrawal-and-successor record (the 2005 Part 2 and the 2009 Part 3 withdrawn; Part 2 Rev. 1 and Part 3 Rev. 1 current, both carrying the 07/01/2025 planning note "This publication is currently being reviewed."; SP 800-131A Rev. 2 the transition reference) — `knowledge/nist-key-management-guidance-status.md` and `knowledge/nist-key-management-parts-withdrawal.md`; rows S073–S082 in `corpus/SOURCES.md`, every source re-opened 2026-11-04. Moved from the frontier list in round 33 by the §10 assimilation; the round-21 frontier lead is discharged and the Frontier bullet is removed, not kept as history (QM33). Source ground is sole: the round-33 connector sweep found 0 of 20 sibling lanes holding any NIST key-management source ground (`.ufo/waves/round-33/build/ConnOverlap.md`). The round lesson records C2's census verdict (M33-3, a plan-side `captures` figure); the ground itself is held.
```

## Landing checks for the L1

1. Connector result confirmed at 10:35: `ConnOverlap.md` §1/§4 reports 0 of 20 sibling lanes on the NIST source ground (so `Source ground is sole` is measured) and one capability-class neighbor for C1 — kasegi's `corpus/instruments/freeze-check.py` — which this bullet does not claim or absorb. Keep the receipt path; if the L1 re-runs the sweep and a claimant appears, name that lane instead of the claim.
2. The bullet's `every source re-opened 2026-11-04` must match the capture rows the L1 installs in `corpus/source-fetches.tsv`; if a row's access date differs, use the row's date.
3. `corpus/self-description-sweep.sh` SD1 has no NIST theme in its list, so this bullet does not add an SD1 hit; the deleted Frontier line was also not an SD1 hit at BASE (`SD1=0` at `76f4eea`). The sweep's total must stay `n=2` with the same two SD6 lines.
