# Round 67 — kagi (secrets & vault ops)

Lane: kagi. Round 67, attempt 1. Claim BASE
`076701a11a58e3eb58d996b4c76c5e18071fb179` (round-66 verifier spot-check
tip). Frozen predeclaration `plans/round-67.md` (landed
`aa8807e443166f45485e1aada2989f646efc707c`; Amendment A1 recorded in the
plan after the first C2 lane reading — no target, predicate, kill rule or
population changed).
Wave `kagi-r67-w1`, 13 seats (plan §Wave).

Claims (as frozen):

- **C1 freshness** — the lane's own source census reads each capture-path
  row's declared bytes and locator quote; `C1_READTHROUGH` located 35 → 36 and
  caught 0/6 → 6/6, with `bound` 36 at BASE as a row property and 0 as a gate
  reading (Amendment A2.6 states both readings; the bare "0 → 36" milestone is
  never used). The BASE gate is blind to the class: its only capture test is
  the location string's length, so a repointed capture reads
  `SOURCES_CENSUS: CLEAN`.
- **C2 calibration** — the lane's record surfaces match the state they
  describe; `C2_FIDELITY` mismatches 7 → 0 over the seven record defects the
  round-66 closure routed (legs L1–L7 of `plans/round-67.md` §C2).

## Gate (rows written this round)

One source was opened this round, at the plan's frontier step. One row is
admitted; it grounds C1's entry `corpus/knowledge/source-capture-binding.md`.

| row | URL | access date | located quote (≤25 words) | decision | reason / flip |
|---|---|---|---|---|---|
| S166 | https://www.rfc-editor.org/rfc/rfc9530.txt | 2026-11-08 | "Receivers can validate the digest for integrity purposes." (§1.2 Concept Overview, 9 words) | admit, tier A | RFC 9530 §1.2 is the primary source for the two digest layers the entry separates (Content-Digest over message content, Repr-Digest over selected representation data); a receipt row for the standard itself is what grounds the digest-over-named-bytes binding. Capture: `.ufo/waves/round-67/capture/S166.body`, raw sha256 `544dbb7d9afceafa8c9931d9924ca6cff2b4807274166d7ed2483342ef2cdd6a`, 67152 B (`sha256sum`, `wc -c <`); rendered-text-v1 normalized sha256 `652d311657f00e1eab513b15db807d773b42294d7032e179f63d04909943436b`, 58365 normalized bytes (`python3 corpus/rendered-text-v1.py digest`). The declared quote locates `count=1` under rendered-text-v1 (`python3 corpus/rendered-text-v1.py locate .ufo/waves/round-67/capture/S166.body "Receivers can validate the digest for integrity purposes."` ⇒ `RENDERED_TEXT_V1_LOCATE: count=1`, rc 0) and does **not** locate as a raw literal (`grep -c -F` ⇒ 0 — the RFC body wraps the sentence across two lines). The landed fetch row therefore declares normalization `rendered-text-v1` with exactly the normalized digest above, which is the profile under which the quote locates. |

The registry row and its fetch row are landed (the L1's append). The fetch
row's location column is **prose** — it names the section and the capture
path in a sentence — so S166's capture is **not** inside the census's
capture-path population and the gate does not read it; its sha256, byte
count and the quote's location are verified by hand and recorded in this
cell (`plans/round-67.md` Amendment A3, item 3, records that consequence
and its flip: a path-shaped registration is a round-68 capability move).
No other source was opened this round. Any in-place registry change the
landing makes (`status`, `recheck`, `used-by`) is logged old→new in the
round lesson per contract v1 rule 2 — see the pointer below.

## Corrigendum — round 66 (pointer; the pairs live in the round-66 lesson)

The round-66 closure's routed defect 7 (`corpus/lessons/round-66-verifier-spotcheck.md`
§6.7) found that round 66's in-place `used-by` edits were never logged
old→new and that the round's lesson never named **S113** at all, so the
SOURCES contract v1 rule 2 obligation — "only `status`, `recheck` and
`used-by` change in place, and each change is logged old→new in the round
lesson" — was not met by the landing. The repair is landed in
`corpus/lessons/round-66.md` §Corrigendum — round 66 (appended in round 67):
seven rows were touched between `d549ee6` and `076701a` — six existing
`used-by` cells changed (S113, S143, S145, S148, S152, S156) and one row
(S164) appeared — and each is listed there as old→new, with **S113** named
explicitly. The pairs are deliberately **not** duplicated here; this
paragraph is the pointer and the statement of the rule it repairs. The
derivation is re-runnable from the two commits:

```
git show d549ee6:corpus/SOURCES.md  vs  corpus/SOURCES.md   # per-id used-by cell
```

## Mistakes

### M67-1 — a plan cited receipts that existed only in the author's scratch

- **class**: `landing`
- **evidence**: `plans/round-67.md` §C2 cited
  `.ufo/waves/round-67/base/blind-gate.txt` and `base/census-start.txt` as the
  BASE receipts before either file existed (the readings lived in
  `/fast/scratch/hyaku/kagi-r67/l1/`). `R67ScoutPre` F-1 measured both absent
  from the tree and from every commit; the first `blind-gate.txt` it then found
  was byte-identical to the clean-tree receipt and named no tree or mutation.
- **captured-by**: `R67ScoutPre` (F-1), in the wave, before the report. QM96 —
  landed this round — requires a cited receipt to exist in the tree the report
  names; it was written for the round-66 closure and the L1 violated it while
  closing it.
- **fix**: both receipts regenerated with provenance headers (tree, mutation,
  the mutated body's sha256/bytes, verdict, rc) and committed; the counter's
  guard (c) now names the receipt path it reads.

### M67-2 — a frozen classifier term no implementation could satisfy

- **class**: `vacuous`
- **evidence**: the frozen shape predicate `^[A-Za-z0-9._][A-Za-z0-9._/-]*$`
  cannot match an absolute location, so the plan's own "absolute location"
  mutation was classified prose and never read: strict measure
  `path_rows=35 prose=121`, a perfect gate scores at most 5/6. The landed gate
  had silently widened to `^/[…]` (`cap_is_shaped`), which is why 6/6 was real —
  the frozen text and the bytes disagreed.
- **captured-by**: `R67ScoutPre` F-3 and `R67Reviewer` S1 (receipt
  `A2-absolute-strict-vs-built.txt`), both before the counter's landed reading.
  No criterion required a predicate's classifier to be able to match its own
  falsifier; QM89/QM90 name counters and legs, not classifier terms.
- **fix**: Amendment A2.1 legalizes the two-form classifier (repo-relative or
  absolute) and states that an absolute location is always
  `capture-outside-root`; the strict-only reading and its ≤5/6 ceiling are
  recorded in the same amendment.

### M67-3 — a claim heading the declared-axis gate rejects

- **class**: `landing`
- **evidence**: the frozen §C1 heading was
  `## C1 — freshness (capability): …`; `corpus/claims-declared.sh` requires
  `## <claim> — <axis>:` with the colon directly after the axis, so it read
  `MISMATCH 67 C1 plan-heading-not-freshness` at integration.
- **captured-by**: `bash corpus/claims-declared.sh --root .` run at integration.
  The gate existed and was not run at freeze time; no criterion required the
  declared-axis gate before a plan is committed.
- **fix**: the parenthetical moved after the colon (Amendment A4); the plan
  freeze step now includes `claims-declared.sh` before the predeclaration commit.

### M67-4 — the counter's oracle was supplied by its subject

- **class**: `scope`
- **evidence**: `plans/round-67-c1.sh` derived `located` with
  `<tree>/corpus/rendered-text-v1.py`, the copy inside the tree it measures,
  and guard (a) cross-checked that derivation against the same tree's gate — so
  a tree shipping a normalizer that answers `count=1` moved both sides
  together. Measured: the exploit tree (every quote non-locating, a stub
  normalizer) read `caught=5/6 guard=1` before the fix.
- **captured-by**: `R67Sentinel` V-1 (HIGH, open at report time in its own
  numbering; closed by the fix below), plus its V-2 for the gate's side.
- **fix**: guard f binds the candidate's normalizer to the committed one
  (`git show <BASE>:corpus/rendered-text-v1.py`), and the derivation uses the
  BASE/lane normalizer, never the candidate's; the gate resolves its own
  sibling. The same exploit tree now reads `caught=5/6 guard=0` rc 1.

### M67-5 — six mutation names with no expected reason, id or counting unit

- **class**: `vacuous`
- **evidence**: the plan named six mutations and no expected finding, so a
  correct gate could legally print one of several reasons (truncation prints
  bytes+digest, `defects=2`), and a natural repoint target was byte-identical
  (S130 → S135, `cmp` rc 0) — a correct gate could score below 6/6 by
  construction, while a counter could choose the map to fit its own gate.
- **captured-by**: `R67Reviewer` S3 (receipt `A4-mutation-legs.txt`), before the
  landed counter reading.
- **fix**: Amendment A2.3 fixes the expected reason set per leg, the mutated-id
  match, the `defects` unit (finding lines), the byte-identical SETUP rule, and
  the stub-gate selftest that must read `caught=0/6`.

### Wave-process note (not a mistake of the round's claims)

The census gate changed four times during the wave (`232fd182` → `34cc1064` →
`59350492` → `46de3d8c`, then `e7aacecd` at integration for the normalizer
fix) while attack seats read it. Each attack receipt pins the bytes it tested,
and the integration re-runs every counter on the landed bytes; the moving
target is recorded rather than smoothed.
