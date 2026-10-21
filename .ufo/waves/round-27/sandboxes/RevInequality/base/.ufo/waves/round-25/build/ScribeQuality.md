# ScribeQuality — QM21–QM23 draft for corpus/QUALITY.md

Revision read: BASE `4587c61a348e4528717404a68912c373f3ef4d03` (HEAD matches). Lane tree not modified. No sandbox experiments. `claim-ledger.sh verify`/`cells` NOT run (UNRUN, per contract).

## Insertion point

- File: `corpus/QUALITY.md` (112 lines at BASE; last row QM20 at line 107; QM18-application paragraph ends line 112).
- Append at EOF, after line 112, with one blank line before the heading. Existing rows unchanged (append-only).
- Next free ids: QM21, QM22, QM23 (`grep -o '^| QM[0-9]*'` ends at QM20).
- Stamp: `corpus/stamps.tsv:66` pins `corpus/QUALITY.md` at 112 lines / 17508 bytes. Restamp only after review (QM5); the stamp goes stale on this append.

## Draft text (verbatim, paste after line 112)

```markdown
## Criteria from the round-25 build (C1–C3)

Supplements are named per row; no existing row changes. The lesson cell cites
`corpus/lessons/round-25.md`, which is NOT present at BASE; it must land in the
same commit as this section (see the report's note). Until then the backing
evidence is `plans/round-25.md` §Claims and §Frontier step.

| id | criterion | weak signal | lesson |
|---|---|---|---|
| QM21 | Supplements QA6 and QM1: a present-tense number in a committed doc (a count of stamps, claims, rows, ids, gates, cases or sources) is bound to the live value it describes. Each such number has one `corpus/self-counts.tsv` row whose live source is `rows:PATH` (non-blank, non-`#` lines of a committed file) or `ledger:ID` (that non-host ledger row's own command, run without a shell, with the number taken from its last non-empty line by a declared regex). The check passes a number only when the doc's value equals the live value; an unlocated or ambiguous number is never CLEAN. A round label beside a number (`… round 21`) does not make it historical: a historical number says it was true at that round. Historical numbers that do say so, in LOG, lessons or SCORECARD history, are out of population by a stated rule and named as such. | a count in a current-tense sentence that no row binds; "63 stamps + 39 claims … round 21" in `SKILL.md:46` beside a ledger that measures 83 stamps and 61 rows; a gate that prints CLEAN while a doc number is UNLOCATED | `corpus/lessons/round-25.md` §C1 (pending); backed now by `plans/round-25.md` §Claims 1 and §Frontier step (stale `SKILL.md:46` count; captured-by: none) |
| QM22 | Supplements QM15 and QM3: a ledger row whose result depends on a layout absent from the checkout (the fleet tree, a sibling lane, or a fleet `.ufo/` path) carries the `[fleet]` tag. When the implementation's layout marker shows that layout absent, `verify` and `cells` print `LAYOUT-SKIP ID (fleet layout absent)`, count `layout_skipped=N` in the verdict line, and never credit the row as passing. A verdict with `layout_skipped>0` or `fleet_absent>0` is never CLEAN. In a lone clone `citations` classifies unresolved `ufo` and `sibling` tokens as FLEET-ABSENT (counted, never UNRESOLVED) and ends `CITATION_GATE: INCOMPLETE (… fleet_absent=N)` with exit 1. A lane-local miss stays UNRESOLVED in every layout; a fleet layout runs every row unchanged. | a fleet-only row red on a lone clone and documented only in its note ("fails by design"); `unresolved=88` for misses that are all layout; a LAYOUT-SKIP counted as a pass; a CLEAN verdict beside `layout_skipped=1` | `corpus/lessons/round-25.md` §C2 (pending); backed now by `plans/round-25.md` §Claims 2 and §Routed defects D2 (`corpus/claim-ledger.tsv:22`, R11-08, "fails by design" in its note only) |
| QM23 | Supplements QA4 and QM14: every `on-release` clock names one release identity and is observed. The population is stated in the gate, not chosen by the author: every registry row whose recheck column reads `on-release`, and every sourced entry, lesson or prose line whose `recheck:` reads `on-release`. Each binds to one clock: `feed`, an official release feed opened as its own SOURCES row together with the version its anchor names; or `rendered-quote`, for an unversioned live page whose quote must still locate in a fresh fetch under the named normalizer. A trigger naming a page footer, "a release" or "a docs change" with no identity fails. A fired clock is re-verified and recorded as a dated observation; the pin is not silently re-pinned. | "on a SOPS release or a change to the pages' 'Last modified' footer" (`corpus/knowledge/sops-age-key-rotation.md:5`); 28 registry rows marked on-release with no identity (`corpus/SOURCES.md` S005–S032); a clock never observed to fire; a gate that counts only registry rows while 10 other occurrences of `recheck: on-release` stay unbound | `corpus/lessons/round-25.md` §C3 (pending); backed now by `plans/round-25.md` §Claims 3 (`on_release=28 bound=0 unbound=28`) |
```

## Findings the draft rests on (verified by read/grep only)

1. `SKILL.md:46` reads "(63 stamps + 39 claims + claim ids, round 21)". Live rows: `corpus/stamps.tsv` non-blank non-`#` = 83; `corpus/claim-ledger.tsv` = 61 (`grep -cv '^\s*\(#\|$\)'`, exit 0). The "round 21" label is not a historical marker; QM21 says so explicitly.
2. On-release occurrences: `grep -rn 'on-release' corpus` = 38 lines: 28 registry rows (`corpus/SOURCES.md:11-38`, S005–S032), 9 header/prose lines (`corpus/knowledge/onepassword-machine-credentials.md:4`, `op-ref-consumption.md:371`, `sops-age-key-rotation.md:5`, `vault-openbao-token-lease-lifecycle.md:5`, `feature-bound-credential-review.md:3`, `corpus/lessons/round-22.md:4`, `round-22-source-errata.md:3`, `round-23.md:3`, `round-24.md:4`), and 1 fixture (`corpus/sources-census.sh:387`). The plan's `on_release=28` counts registry rows only; QM23 requires the population to be stated. Planner decision: count 38 or exempt the 10 by rule.
3. Lesson file gap: `corpus/lessons/round-25.md` does not exist at BASE (`ls corpus/lessons | grep 25` empty). The new lesson cells dangle until it lands. UNRUN: whether `claim-ledger.sh citations` flags a missing lesson path in QUALITY.md (expected, not checked).
4. Plan ambiguity, C2: the plan does not state the verdict for `verify` with `layout_skipped=1`. QM22 says never CLEAN, which follows QM3's "a CLEAN last line with skipped= … is weak". Planner to confirm and align `plans/round-25.md` §Claims 2.
5. Supplement check: QM21 (historical/current numbers) is not QM1 (absent-file facts) or QM6 (round identity); QM22 (layout absence) is not QM15 (host-private reads; fails by presence, not absence); QM23 (identity) tightens QA4's "release event" and QM14's no-silent-re-pin.
6. Draft avoids `<…>`, `TODO`, `FILL` tokens (QM7).

Tooling: none installed or updated. Commands: `read` of QUALITY.md, plans/round-25.md, corpus/lessons (listing), SKILL.md:44-48, SOURCES.md:11; `grep`/`sed`/`wc`/`ls` read-only, exit 0. Nothing written in the lane.
