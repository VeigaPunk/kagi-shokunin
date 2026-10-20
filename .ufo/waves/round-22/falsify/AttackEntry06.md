# AttackEntry06 — falsification of integrated C2 for `corpus/knowledge/config-layering.md`

Axes: **calibration** (correct feature-specific adjudication, not authored row
counts) and **freshness** (stamp/revision integrity, not source currentness).
Seat: leaf reviewer, no subagent dispatch. No production file, lane state, or
host-private surface was written or probed; no gates were run.

## Read revision (exact, frozen-input method)

- Integration landing: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`
  (`git rev-parse HEAD`, subject `round-22: feature-bound review capability
  and audited revision repairs`); one commit above base
  `c2cab35bc92e57e39e5489bac3386db078345b3f`. Working tree `git status` is
  clean for both audited paths — working bytes equal HEAD bytes, so no
  mid-wave lane drift contaminates this measurement.
- Historical BEFORE is the frozen snapshot, not the falsification input.
  All current-state claims below name hashes read at the landing tree.

## Measured file state vs frozen manifest (freshness)

`integration-manifest.json` pins this entry:

```
corpus/knowledge/config-layering.md  bytes=8088 lines=136
sha256=9d4ac8c24981a64b02a2a67cdd54fd5102c62d516224965392fb422aada18cf0
```

Measured at the landing tree: `sha256sum` →
`9d4ac8c24981a64b02a2a67cdd54fd5102c62d516224965392fb422aada18cf0`,
`wc -c -l` → `136 8088`. **Exact match — zero drift since the frozen
integration manifest.** The HEAD blob (`git show HEAD:<path> | sha256sum`)
hashes identically, so blob and working bytes agree. No CRLF, no control
characters, no trailing-byte anomaly; line 109 ends exactly `. \n`.

## Frozen-before bytes and prefix proof

`frozen/before/` contains only the two C1 surfaces
(`onepassword-machine-credentials.md`,
`vault-openbao-token-lease-lifecycle.md`) — this entry is not among them,
consistent with it never having been in-flight C1 work. Frozen
`frozen/before/corpus/stamps.tsv` row 14 (whole-file sha256
`0ce7fa4f…`, equal to the `c2cab35` blob, so frozen==base verbatim):

```
corpus/knowledge/config-layering.md	848b8e502ea2046aacd3f8ae1717d6a4882b07c9317d13d012eb5bae6c88fe83	109	6621
```

Current `corpus/stamps.tsv` row 16:

```
corpus/knowledge/config-layering.md	9d4ac8c24981a64b02a2a67cdd54fd5102c62d516224965392fb422aada18cf0	136	8088
```

The stamp now matches the real bytes exactly — the stale tuple this entry
carried at base (`before.json` lists the path in its six `stale_stamps`)
is repaired. Row moved 14→16 because six new-member rows were inserted
above it; membership is preserved, `removed rows = 0` across the whole
table, non-blank count 63→69 (all six additions are declared new C1
capability files: `corpus/feature-claims.json`,
`corpus/feature-claims.py`, `corpus/knowledge/feature-bound-credential-review.md`,
`corpus/lessons/round-21-verifier-spotcheck.md`,
`corpus/lessons/round-22.md`, `corpus/revision-audit.py` — none is this
entry, so no restoration/laundering question arises for it).

**Unchanged-prefix proof (original bytes preserved, no laundering):**
`head -c 6621 corpus/knowledge/config-layering.md | sha256sum` →
`848b8e502ea2046aacd3f8ae1717d6a4882b07c9317d13d012eb5bae6c88fe83` —
byte-identical to the frozen-before stamp. The growth is a pure append:
lines 111–136 (`## Historical-source erratum — round-16 re-dispatch
(2026-10-15)`), preceded by a blank line; byte 6621 is the newline ending
line 109 (`… the merge.`), byte 6622 is a blank line, byte 6623 starts
`#`. Original lines 1–109 are untouched under their own hashes; the
original-text and `Source-status: historical` markers coexist as required.

## Stamp-record migration evidence (QM14 accounting)

`historical-correction-pins.json` and `historical-migrations.json` do **not**
record this entry's stamp update — both journals cover only the earlier
`c41af82… → e1544c19…` span. The round-22 restamping evidence instead lives
in the integrated falsify-input chain itself, and it is complete for this
row:

1. Old tuple preserved verbatim: frozen `stamps.tsv` (sha256 `0ce7fa4f…`,
   equal to the `c2cab35` blob) and `expected.json` `/inputs/corpus/stamps.tsv`
   → `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b`.
2. Stale-before observation: `before.json` `stale_stamps` includes this path
   (6 stale, 0 dropped/added/invalid).
3. New tuple: current row 16, equal to the landing blob.
4. No silent deletion: row present at base, present at HEAD; zero removed
   members; `historical-migrations.json` `deleted_stamps: []`.

Gap (documentation, not integrity): the one-hop old→new restamp for this row
is evidenced by the chain above but is not named in either migrations JSON.
The parent's global revision-audit rerun should treat the frozen-before
snapshot + `before.json` + landing row as the exact historic evidence for
this member; no member was lost, so no restoration is owed.

## Cross-check against build/Entry06.md (advisory, pre-landing)

The build report already predicted exactly this state: pinned tuple
`848b8e50… 109 6621` = pre-erratum blob, landing tuple
`9d4ac8c2… 136 8088`, append `+27 −0` at commit `f4a8dd9`, prefix proof via
`head -c 6621`, QM5/QM12-based verdict that the stale pin was a defect
needing in-place re-pin with no entry edit. Every checkable prediction
matches the landing tree; the report's advisory status does not weaken the
agreement because its claims are independently reproduced above. Two
caveats apply to that report, not to the landing: its live-tree contamination
note (its "eight stale" moment) is build-time observation only, and the
landing's own `before.json` six-stale accounting is the authoritative
before-state.

## Residual stale rows adjacent to this finding (out of my seat, flagged)

Same comparator, same landing tree: `handler-on-disk-state.md` row says
287/19837 vs real 288/19837 (hash matches; one-line undercount), and
`handler-trust-boundary.md` row says 316/19410 vs real 317/19410 (same
off-by-one line count). Hashes match; the line fields are stale by one.
If the parent's global audit counts "stale" by all three columns these
remain two open mismatches; if hash-only, they pass. Flagged for the
single global revision-audit rerun — not adjudicated further here.

## Pointer freshness vs unavailable source facts (calibration)

The entry's cited host sources (`~/.local/bin/the-janitor`,
`~/.config/the-janitor/client.py`, `~/.config/the-janitor/config.json`,
janitor agent layer) are unavailable to this seat, and the tightened
observation boundary forbids host probes — no source currentness is claimed
or measured. What freshness measures here is only that the stamp points at
the bytes the tree actually carries, which it now does. The erratum's own
boundary is intact: `Source-status: historical` (lines 113–114), enumerated
qualification of original ranges 3-6/8-22/24-46/48-54/56-66/68-81/83-101,
explicit "preserved, not re-asserted as current properties" (119–120), and
reuse blocked until restored-source review ("Restoration alone is not a
pass", line 136). The line-58 abbreviated `af8873ca…` hash sits inside the
qualified 56–66 range and is not re-asserted as a current property —
consistent with QM14's rule that byte hashes never promote absent source
facts to current.

## Admissibility verdict (one, for this entry)

**ADMIT — the integrated C2 repair for this entry is correctly bounded and
non-laundering.** The stale stamp was repaired in place to the true landing
bytes (136/8088, `9d4ac8c2…`); the original 109/6621 pre-erratum bytes are
proven preserved as a strict prefix; membership is retained with zero
deletions; the erratum bounds every source-derived claim as historical
without re-asserting absent-source facts as current; and no new prose
append was needed (the round-16 erratum already carries the qualification).
Pointer freshness and source currentness are correctly distinguished.

## Verification gaps / residual risk

- Restamp hop not itemized in the migration JSONs (span mismatch
  `c41af82→e1544c19` vs this landing `c2cab35→8ada17a`); chain evidence
  above substitutes for this row only.
- Off-by-one line-count staleness in the two sibling handler entries is
  open until the global audit adjudicates it.
- No source bytes, resolver output, or host state was read (boundary);
  currentness of the historical source facts remains unknowable here, by
  design and by contract.

## Suggested parent checks

1. Global revision-audit rerun (single rerun, parent duty): expect this
   entry fresh (hash+lines+bytes all matching row 16).
2. `grep -c '[^[:space:]]' corpus/stamps.tsv` → `69` at the landing tree
   (63→69 via six declared additions, zero removals); update `R12-03`
   expectation 63→69 with old/new evidence per QM14.
3. Decide the stale predicate for the two sibling off-by-one rows and
   record the adjudication.
4. `git diff c2cab35..8ada17a -- corpus/knowledge/config-layering.md`
   must show append-only growth (no removed lines) — confirmed here.
