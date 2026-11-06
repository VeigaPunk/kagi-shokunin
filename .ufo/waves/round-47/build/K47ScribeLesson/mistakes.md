# Draft — `## Mistakes` for `corpus/lessons/round-47.md`

Shape: the lane's table (`corpus/lessons/round-46.md` §Mistakes header;
`/home/vgpnk/Projects/shokunin/CORPUS.md:171-176` — "class · evidence pointer · captured-by (the
`QUALITY.md` criterion or protocol rule that should have caught it, or `none`) · fix", classes from the
`mistakes.md` §5 vocabulary). Every pointer below is a path:line this seat opened. Nothing here is
measured by a gate I did not run; where a claim rests on execution, the receipt is named.

## Proposed `## Mistakes` section

```markdown
## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M47-1 | number-drift | `SCORECARD.md:1695` states the declared-claim gate's `--selftest` went `(8 → 11 cases)` and cites "cases 9–11"; the committed block asserts 12 (`git show f4a33d3d:corpus/claims-declared.sh \| grep -n 'cases" -eq'` → `122:  if [ "$passed" -eq "$cases" ] && [ "$cases" -eq 12 ]; then`), case 12 exists (`f4a33d3d` lines 118–121, `same-claim-second-axis`), and the same two numbers are right in `corpus/lessons/round-46.md:7` (`8 → 12 cases`) and `LOG.md:1827` (`PASS (12 cases)`). | **none** — no lane gate compares a SCORECARD numeric case count with the gate's own assertion. Audited, all read: SD1–SD9 (`corpus/self-description-sweep.sh:8-31`) check paths, README frontier text, SHONEN tokens, M31 ids, red ids on the `lane-status:` line, citation lines, shipped-selftest naming, range tokens and provenance trios — no count tuple; `cells` in `corpus/claims-declared.sh` checks that a post-move section and an axis tag exist (`corpus/claims-declared.sh:181`, `:223`); `cell` in `corpus/claim-ledger.sh` checks that each axis row carries a resolving pointer, not that its numbers match bytes (`corpus/claim-ledger.sh:80-88`). | Proposed SD10: every `(A → B cases)` tuple in a `## Round <N> — post-move` row must equal the `$cases -eq N` guard of the gate script named on that row, exempting a line a later `supersedes SCORECARD.md:<line>` marker names (append-only errata). Demonstrated both ways: `python3 build/K47ScribeLesson/proposal-sd10-demo.py .` → `MISMATCH SD10 SCORECARD.md:1695 says (… → 11 cases) but corpus/claims-declared.sh asserts $cases -eq 12` / `SD10: MISMATCH n=1`, rc 1 (`build/K47ScribeLesson/sd10-real-tree.txt`); the same run against a scratch copy with one appended `supersedes SCORECARD.md:1695` line → `SD10: CLEAN n=0`, rc 0 (`build/K47ScribeLesson/sd10-with-erratum.txt`). Without the supersedes clause the check stays red forever on an append-only file, so the exemption is part of the fix, not an escape hatch. |
| M47-2 | attribution | `corpus/lessons/round-46.md:12` calls seat K46ReviewerLive's work "the non-author re-observation `build/K46ReviewerLive/obs.json`" and `:23` "the non-author seat located the same eleven quotes independently"; the round-46 closure records it as routed 2 (`corpus/lessons/round-46-verifier-spotcheck.md:105`). | `LEARNING.md:42-46` — "Each round a non-author — a fresh reviewer or the operator — spot-checks a sample of that round's gate decisions … **A subagent the lane dispatched is still the lane.**" A lane-dispatched seat cannot fill the out-of-lane leg by construction. | Reserve "non-author" for closure and operator checks. Name a lane-dispatched seat's work "the lane's independent live leg" — the term the frozen plan already uses (`plans/round-47.md` §Non-claim work, terminology bullet). Round-46's lesson is committed and is not rewritten; the correction lands as this round's §Errata (naming `round-46.md:12` and `:23`) and as the wording of round 47's own live leg. |
| M47-3 | stale-premise | `considerthese/2026-10-26.md:26-30` says "The C1 fail-open is still live at HEAD" and "`STABLE_TITLE_RE` matches `Python 3.15.1` but not `Python 3.15.1.` or `Python 3.15.01.`"; at the round-47 BASE `corpus/release-clock.py:789` reads `... (?![A-Za-z0-9+-]|\.[0-9])` (the anchor was dropped), and the module's own regex, executed, returns `3.15.1` for `Python 3.15.1`, `3.15.1` for `Python 3.15.1.` and `3.15.01` for `Python 3.15.01.` (`build/K47ScribeLesson/regex-test.txt`, rc 0). The quoted symptom does not reproduce at BASE; the disposition is already committed at `corpus/lessons/round-33.md:17` ("#3's defect is closed"). | **none** — no gate re-reads `considerthese/` prose; the nearest check is SD8, which covers range tokens only (`corpus/self-description-sweep.sh:28-30`). The round lessons' §considerthese carried "proposals 1 and 3 remain unimplemented" from round 41 (`corpus/lessons/round-41.md:231`) through round 44 (`corpus/lessons/round-44.md:63`) without re-testing the premise. | Keep the proposal-3 status split in this round's §considerthese: the qualifier is still absent (`grep -c 'KNOWN_DEFECT' corpus/release-clock.py` → 0) while its motivating symptom is closed since round 33 — so "unimplemented" must not be read as "defect live". `considerthese/` is operator-authored input and is not edited. A zero-padded capture (`3.15.01`) still string-differs from `3.15.1`; whether that can move a verdict was **not** checked this round (`[not verified]`). |
```

## Notes for the integrator

- Two of the three rows have `captured-by: none`, and both name the audit that establishes it. That is
  the load-bearing part of each row: M47-1 is the reason the SCORECARD drift survived a whole round,
  M47-3 the reason the operator note reads as live.
- M47-1's fix satisfies the lane's "a fix is shown able to fail before it counts"
  (`CORPUS.md:177-184`): the demonstrably failing state is the real tree today, the only delta is one
  appended erratum line, and both outputs are committed under
  `.ufo/waves/round-47/build/K47ScribeLesson/`.
- The class tokens used are from the §5 vocabulary (`CORPUS.md:173-175`): `number-drift`,
  `attribution`, `stale-premise`.
- These rows are written to be appended by the L1; this seat wrote drafts only, and no lane file was
  touched.
