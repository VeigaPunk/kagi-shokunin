# K42ScribeLesson — round-42 lesson, SCORECARD block, LOG entry and QUALITY rows (drafts for the L1)

Seat: scribe. Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`. Claim BASE
`e8265c0d90b01fcce0447d2f70615b0592ed145f`; predeclaration `98dd4de`; amendment A1 `fdbb83d`.
Prose only — no lane file was edited; the deliverables are a file set under the seat directory and the
L1 copies, commits and measures.

## Deliverables (absolute paths, under the seat directory)

| file | status |
|---|---|
| `.ufo/waves/round-42/build/K42ScribeLesson/lesson-draft.md` | Complete: `## Claims` (C1 and C2, each with the frozen predicate sentence copied verbatim from `plans/round-42.md`, the BASE readings, the target, the kill rule and the declared ceilings), `## Gate` (S094 with URL, access date 2026-11-05, the 8-token located quote and a FILL for the re-open verdict), `## Mistakes` (table id · class · evidence pointer · captured-by · fix, with M41-4 and M41-5 as specified plus M41-6 and M41-7), `## Frontier`, `## Routed` (the plan's §Routed item names verbatim), `## considerthese` (proposals 1 and 3 unimplemented, no separable slot), `## Assimilation` (none, with reason). |
| `.ufo/waves/round-42/build/K42ScribeLesson/scorecard-block.md` | Complete: `## Round 42 — pre-move` (six axes at 9, evidence pointers to the BASE receipts) and `## Round 42 — post-move` (two rows — calibration for C1, freshness for C2 — with the candidate readings carried only as `<<FILL: …>>`, and a FILL-key list for the L1). |
| `.ufo/waves/round-42/build/K42ScribeLesson/log-entry.md` | Complete: one `## Round 42 (2026-11-05)` entry naming predeclaration `98dd4de`, amendment A1 `fdbb83d`, and FILLs for the candidate commit, the candidate readings, the S094 verdict, the landing measurements and the round verdict. |
| `.ufo/waves/round-42/build/K42ScribeLesson/quality-rows.md` | Complete: two rows in the `corpus/QUALITY.md` criterion-table format — QM44 (a ledger row removed from the candidate without a journal form is refused) and QM45 (a committed receipt is re-derived from the revision it names by a committed runner), each with a weak-signal cell and a lesson pointer. |
| `.ufo/waves/round-42/build/K42ScribeLesson/gate-receipt.txt` | Supporting receipt for the Gate block: the live re-open of S094 with commands, exit codes, digest, byte count, quote offset and the `cmp` result. |

## Measured evidence used (every value re-derived by this seat, not copied from prose)

- BASE receipts read as committed under `.ufo/waves/round-42/controls/`: `c1-base.txt` 4,
  `c1-control-refuse-all.txt` 0, `c1-control-accept-all.txt` 0, `c2-base.txt` 0,
  `c2-derivation-D.txt` 1, `c2-worktree-at-base.txt` 3; the stale committed receipt
  `.ufo/waves/round-41/controls/c2-base-19025d9.txt` reads 1.
- Ledger population at the claim BASE: 86 ids at `6cc8850`, at P0 `6f1588c` and at `e8265c0`; the id
  sets differ by 0 removed and 0 added (`comm -23` empty both ways). `R17-02` is present in all three
  and appears in neither the round-40 nor the round-41 migration journal (`git grep` → no match).
- Census: `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` exits 0
  with the final line `kagi ok`; the registry at BASE carries 98 rows (A 94, B 2, C 2).
- S094 re-open (2026-11-05): HTTP 200, decoded 11296 bytes, sha256
  `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`; `cmp` against
  `.ufo/waves/round-39/capture/S094.body` exits 0 (byte-identical); the declared quote
  "Only \`status\`, \`recheck\` and \`used-by\` change in place" (8 whitespace tokens) locates at raw
  offset 6172, count 1. The S094 teaches cell's derived clause "an in-place anchor rewrite violates
  this rule" does not occur in the served body (count 0) — M40-1 / QM42 stand.
- F4 erratum evidence: `corpus/claim-ledger.sh:262` (`ALLOWED_RE='^(bash|grep|sha256sum|wc|test|python3)$'`)
  and `:275` (first-token refusal) against `plans/round-41.md` §C1's "accepts F1–F4 by construction".
- The round-41 verifier spot-check's §6 item 4 (row deletion) and item 3 (the controls runner's C2 BASE
  line) are the upstream routed items behind M41-6 and M41-4.

## Findings the L1 must decide on

1. **M41-7 (new, named by this seat).** After amendment A1 the plan body and the counter header no
   longer carry the same predicate sentence: `plans/round-42.md` §C2 still reads "(`plans/round-41-c2.sh`,
   copied from the candidate)" while `plans/round-42-c2.sh`'s header reads "as frozen at predeclaration
   5142b52, read with git show, never the candidate's copy", and the plan asserts they are the same
   sentence. Measured from `git show fdbb83d -- plans/round-42-c2.sh plans/round-42.md`: A1 changed the
   counter and added the A1 section and left the plan's sentence body unchanged. A1's behaviour governs
   (D is read from `5142b52` in the counter and in the controls runner); the frozen bytes are not
   rewritten after the freeze, so this is recorded, not fixed.
2. **M41-6 (named by this seat).** The journal gate's blind spot — a deleted ledger row is in neither
   population of the frozen classes — is the defect C1 of this round claims, and it is the lesson pointer
   for QM44. It is distinct from the two mistakes the plan names (M41-4, M41-5) and needed an id.
3. **FILLs are the L1's to close.** Every value measured after the predeclaration is a `<<FILL: …>>`
   token: `c1 candidate reading`, `c2 candidate reading`, `c1 gate and selftest receipts`, `s094 reopen
   verdict`, `candidate commit`, `landing measurements`, `round verdict`. QM7 fails a stamp on a
   placeholder token in a tracked file, so all of them must be replaced before commit.

## Out of scope (not touched)

- No lane file was edited: `corpus/expect-journal.sh`, `plans/round-41-controls.sh`, `corpus/QUALITY.md`,
  `SCORECARD.md`, `LOG.md`, `corpus/lessons/` and the wave receipts are unmodified. The drafts are
  text files for the L1 to integrate, copy and commit.
- No git mutation in the lane (no add/commit/checkout/stash/reset/push) and no mutating `jj` command;
  the seat's own clone lives in `$HYAKU_SCRATCH/kagi-r42/K42ScribeLesson/work` and was deleted at yield.
- The lane's full claim-ledger verify and self-counts were not run (host-heavy, > 300 s); only the
  scripts and receipts this item names were used.
- Tooling: no install or update was needed or performed this session — `curl`, `git`, `python3` and
  `grep` (all pre-installed) covered the work; no pacman transaction, no host service change. The
  operator's tooling directive (`/home/vgpnk/.omp/agent/RULES.md`) and the pacman guard were read and
  respected.

## Sandboxing

`S=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r42/K42ScribeLesson`; `git clone --shared` of the lane
plus `git -C "$S/work" checkout --detach 98dd4de`; `git -C "$S/work" rev-parse --show-toplevel` printed
`/fast/scratch/hyaku/kagi-r42/K42ScribeLesson/work` before any write. All git calls named `-C`. The
scratch tree is removed before this seat yields; every receipt the deliverables depend on was copied
into the deliverable directory first (`gate-receipt.txt`).
