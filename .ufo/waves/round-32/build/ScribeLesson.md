# ScribeLesson — round-32 lesson draft

seat: ScribeLesson (scribe, leaf; no sub-spawn).
base: `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b`; plan `507dd9f` (`plans/round-32.md`).
output: `.ufo/waves/round-32/build/lesson/round-32-lesson.md` (draft the L1 lands at
`corpus/lessons/round-32.md`).

## Behavior

Drafted the round-32 lesson in the round-31 header/Gate/Mistakes shapes with the seven
required sections in the required order:

1. header block (author lane kagi, round 32, plan `507dd9f`, BASE `32c35fe`, the sources it
   reads) — front matter `source: S072`, `verified-at: [L1-FILL]`, `recheck: 180d`;
2. `## Gate` — S072 ADMIT row (URL, access date, located quote), considerthese proposal 4
   REJECT with reason and flip condition, NIST SP 800-57 DEFERRED with reason, and the
   non-author spot-check line verbatim `pending — the round's non-author verifier records
   agree/disagree here`;
3. `## Mistakes` — M32-1 with the plan's class/evidence/captured-by/fix text;
4. `## Corrigenda` — appended R3 (S063 `Audience` lines 343/593) and R4 (the M31-6 row,
   reproduced from the round-31 Corrigenda text), each citing its superseded text;
5. `## Registry changes` — S072 old→new (new row only), the capture-row note, and the
   pre-existing-row expectation marked `[L1-FILL]`;
6. `## Measurements` — the plan's exact C1/C2/census/row-count commands with every measured
   cell `[L1-FILL]`;
7. `## Limits` — SD5 naming-only, SD3 path-existence-only, C2 six-class fidelity, the C2
   string-match ceiling, no vault, the-janitor absent, S072-as-metadata, sweep scope, draft
   status.

## Gates

None run. This is a scribe seat: the L1 runs the full gates. Unrun checks are not passed.

## Commands run (with exit codes)

| Command | Exit |
|---|---|
| `mkdir -p /fast/scratch/hyaku/kagi-r32/ScribeLesson/tmp /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/lesson && ls -la …/build` | 0 |
| `python3 - <<'PY' … bs4 extract of article v2410101 h3/paragraphs/h4 … PY` (read the saved capture; also used to confirm the source's tag/space form) | 0 |
| `wc -l …/lesson/round-32-lesson.md && grep -n '^## ' …` | 0 (131 lines; sections at 24, 45, 51, 74, 87, 103) |
| `rm -rf -- /fast/scratch/hyaku/kagi-r32/ScribeLesson` (scratch cleanup, committed scope) | 0 |

Read-only tool calls (no exit codes): `plans/round-32.md`; `corpus/lessons/round-31.md`
(header/Gate/Mistakes; raw Corrigenda M31-6 at lines 214–229); `corpus/lessons/round-31-verifier-spotcheck.md`;
`considerthese/2026-10-26.md`; `corpus/SOURCES.md` (header/S071 shape); `corpus/source-fetches.tsv`
(lines 104–114); the round-32 build outputs `probe/{op-version,base-probe,base-counter,selftest}.txt`,
`fix/fix-frontier-readme.patch`, `knowledge/op-ref-11.1.md`, `ReviewOp.md`, `ConnOverlap.md`,
`src-open/S072-body.html`, `swarm-registry.json`. No claim counter, probe, census or gate was run.

## Touched surfaces

- Written: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/lesson/round-32-lesson.md`
- Written: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-32/build/ScribeLesson.md` (this report)
- No lane-tracked file edited; no git mutation; no vault contact; scratch dir removed.

## Verdicts the item asks for

- Draft exists with all seven sections: **yes** (131 lines; order as specified).
- Every number cited or `[L1-FILL]`: **yes** — BASE SD counts from the plan table, the 71/72
  census expectation from the plan, the locator lines/dates from the capture and spot-check,
  and all measured cells `[L1-FILL]`.
- S072 quote copied from ScoutOp's capture in the lane's locating form:
  `2.41.1 (build #2410101 ) – released 2026-10-21` (10 tokens; locate count=1; the space
  before `)` is required by `rendered-text-v1` — without it ScoutOp measured count=0).
- Corrigenda R3/R4 appended, not rewritten: **yes**.
- Non-author spot-check line: **pending** (verbatim).

## Findings / landing dependencies

1. **ScoutOp's report is missing; its row and capture-row drafts landed.** `S072-row.md`
   and `S072-capture-row.tsv` are on disk and agree with the seat's direct record (HTTP 200,
   decoded-body sha256 `d1fc423ba0ec4119679d9f9631031fb30834fb4da13cd701a410057b256d8209`,
   516927 bytes, access 2026-11-03, quote `2.41.1 (build #2410101 ) – released 2026-10-21`).
   `ScoutOp.md` was still absent at last check (glob at 19:43); the lesson states this and
   asks the L1 to re-cite it if it lands. If it never lands, that is a seat delivery gap for
   the L1, not a lesson claim.
2. **C1's counter is a build draft, not yet in `corpus/`.** `corpus/self-description-sweep.sh`
   does not exist at draft time; the ExecSweep draft is
   `build/sweep/self-description-sweep.sh` (13.0 KB) and must be landed before the
   `## Measurements` C1 command is runnable. `corpus/rendered-text-v1.py` exists (ScoutOp's
   locate command is real).
3. **C2's predicate ceiling (reported, not edited).** `ReviewOp.md` F2/F3: the §11 string
   half counts any `` op `2.41.1` `` mention (the §11.1 scope disclaimer alone satisfies it)
   and the probe never reads the version, so the pin is a string match plus two receipts in
   sequence. Recorded in `## Limits`; the frozen predicate is untouched.
4. **R4 row content** reproduces the round-31 Corrigenda item 2 verbatim in substance
   (class, evidence including the Japanese quote, captured-by QA6/QM10, fix with the
   English-needle sweep as the red witness). No table cell contains a `|`.
5. **Registry changes**: the plan expects S072 only; `ConnOverlap.md` recommends no second
   `SOURCES.md` row (S072 stays the single sourced row; a second row moves the census off 72).
   The lesson logs this as the expected state, not as a landed fact.

## Out of scope

No edit to `corpus/lessons/round-32.md` (L1 lands it), `corpus/SOURCES.md`,
`corpus/source-fetches.tsv`, `corpus/knowledge/`, `SCORECARD.md`, any sibling repo or
`considerthese/`. No predicate/counter change. No installs.
