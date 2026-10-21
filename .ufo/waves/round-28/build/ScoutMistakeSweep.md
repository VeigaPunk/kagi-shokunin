# Mistake sweep — rounds 22–27 vs `corpus/QUALITY.md` (round-28 BUILD)

Seat: KagiR28.ScoutMistakeSweep-7. BASE `3553d499577084a6c98d7078906017840bbf7b28`.
`git diff --stat 3553d499… -- corpus/lessons/round-2*.md LOG.md corpus/QUALITY.md`
is empty (only `plans/round-28.md` differs), so every lesson/LOG/QUALITY line
below is a BASE line. Fleet reports are cited at their only location,
`/home/vgpnk/Projects/shokunin/.ufo/reports/round-N/kagi.md`.

## The three named defects — all CONFIRMED

1. **Round-27 START census missing — CONFIRMED.** No
   `.ufo/waves/round-27/census-start.*` exists at BASE or in any commit
   (`git log --all -- .ufo/waves/round-27/census-start.txt` → empty, exit 0).
   The lesson's own correction says so: `corpus/lessons/round-27.md:262-267`
   ("no round-27 start census file was written"), and the report admits it at
   `.ufo/reports/round-27/kagi.md:51`. This is not new: round 23 retains no
   start census, round 22's `before.json` keeps only the `kagi ok` line and
   drops its five W04 warnings, and round 24's was reproduced late
   (`corpus/lessons/round-24.md:151`; `.ufo/reports/round-24/kagi.md:227-228`).
2. **Plan first committed with candidate code — CONFIRMED, and systemic.**
   `git log --diff-filter=A --format='%h %s' -- plans/round-27.md` → `144babc
   … (candidate)` (exit 0). `git show --stat 144babc` lists `plans/round-27.md`
   alongside `corpus/release-clock.py | 148 +-`, `corpus/QUALITY.md`,
   `SCORECARD.md`, `LOG.md`, `SKILL.md`, `PROVINCE.md` — 17 production paths in
   the same commit. The probe below shows the same for rounds 22–26: **6/6
   rounds violated plan-before-code**; only round 28 is clean (`bdf90f5`, 0
   production files). Round-28's plan statement is accurate but understates the
   age: the defect predates round 27 by five rounds and had no gate.
3. **Frozen C2 widened mid-round — CONFIRMED.** Frozen text
   `plans/round-27.md:31`: "non-numeric anchors keep the inequality rule as a
   declared limit". Appended correction `plans/round-27.md:50-55`: "C2 scope
   widened … a non-numeric anchor such as S012 `v1.21.x` **IS** ordered against
   its feed's numeric floor". The correction also falsifies frozen
   `plans/round-27.md:39` ("disjoint production files") at `:57`. The amendment
   landed in `3fb7727` (12:59:43), 28 minutes after the frozen/candidate commit
   `144babc` (12:31:36). C1's population also changed in the same block. Note
   the frozen C2 counting command says "**a** downgrade fixture" while
   `c2-before.json` measures four; the fixture set grew with the rule.
   Append-only text was preserved (probe `APPEND_ONLY` PASS 22–28), so a
   hash/append check cannot catch this — only a semantic gate can.

## Uncaptured mistakes (no QUALITY row; nearest row named)

| # | class | evidence at BASE | captured-by | proposed fix, failing witness |
|---|---|---|---|---|
| U1 | plan added in the candidate/landing commit, so the claim was never frozen before work (22–27; 6/6) | probe `PLAN_FIRST`; `git log --diff-filter=A` per round | none | plan commit must touch no `corpus/`/top-level doc; probe FAIL on `144babc` (17 files), PASS on `bdf90f5` |
| U2 | start census absent, truncated, untimestamped, or not revision-bound | R27/R23 absent; R22 `before.json` holds only the `ok` line (five W04 dropped); 24 late; 25/24 no timestamp; 28 no revision | none (M24-4 cites only the prompt §2b) | receipt must carry timestamp + declared BASE + full stdout; probe fails R27 presence, R28 revision; R26 revision PASS, R28 timing PASS are the controls |
| U3 | frozen claim scope amended after freeze without a machine-readable supersession edge | `plans/round-27.md:31` vs `:54`, `:39` vs `:57`; `plans/round-24.md:82-96` (R24-C5 rejects the frozen env-var consent) | none (QM8 is wave-data freeze) | corrections must contain `supersedes: plans/round-N.md:<line>` + re-declared counting command; `awk '/## Plan corrections/,0' plans/round-27.md \| grep -c supersedes:` → 0 (exit 1) |
| U4 | receipt/verdict names a revision other than the measured bytes | `corpus/lessons/round-22-verifier-spotcheck.md:177` D6 (`.h1` 8ada17a5 vs 4be5da3); `round-23-verifier-spotcheck.md:189` D3 (`measured_commit` stale after 3764bc57) | QM8 nearest (wave lanes only, not receipts) | every verdict file embeds the measured revision; `census-start.json` R26 is a passing control; round-22 D6 is the red witness |
| U5 | wave evidence committed after the fleet report and driver `complete` | `corpus/lessons/round-23-verifier-spotcheck.md:201` D7 (`46fac5a` landed after) | none | report may cite only commits reachable from its named revision, committed before it; fails on round 23's ordering |
| U6 | quoted fleet-gate summary omits warning lines (report says `kagi ok` only) | `corpus/lessons/round-22-verifier-spotcheck.md:165` D1; `grep -c W04 .ufo/reports/round-22/kagi.md` → 0 (exit 1) while 5 warnings existed | none (QA6/QM3 cover counts/fails, not warnings) | quoted block must equal the retained receipt; round-26 report (19 W04 lines) is the green control, round-22 the red one |
| U7 | parser rule validated only against synthetic fixtures, not a real body | `corpus/lessons/round-25.md:156` M25-5; recurrence `round-26.md:91` M26-2 | none (QM9 = wired modes) | each rule needs a captured real body as a failing-capable fixture; first-entry rule on `.ufo/waves/round-26/captures/S039.body` (3.14.9 first, 3.15.1 max) is the witness |
| U8 | fixture set never exercises the final token, so a silent skip survives | `corpus/lessons/round-25.md:153` M25-2 (last token unchecked since round 11, +175 citations) | none | one case whose only violation is the line-final token; red on the old `printf '%s' \| read` pipeline |
| U9 | comment/guarantee promises more than code proves | `round-24.md:149` M24-2, `:153` M24-6; `round-27.md:106` M27-3 ("never an un-fire" unbacked) | QM9 partial (documented modes only) | every `refus*`/`never` comment names its selftest case id; `policy-split-verb` never fed one backslash (witness), and `grep "never an un-fire"` had no fixture before the feed floor |
| U10 | seat reports written to the fleet root instead of the assigned lane path | `round-22.md:36` M22-4; `round-23.md:155` M23-4; `round-27.md:107` M27-4 | none (wave context prose) | post-wave fleet-root sweep + `cmp` against the lane path; `.ufo/waves/round-27/misroot-sweep.txt` is the red witness, empty sweep the control |
| U11 | one label reused for two wave seats (130 spawn ids, 129 names) | `corpus/lessons/round-22-verifier-spotcheck.md:175` D5 | none (QM6 = round ids only) | roster check `len(ids)==len(names)` with duplicate names printed; fails on round-22's 130/129 |
| U12 | canonical skill/protocol loaded after implementation began | `corpus/lessons/round-25.md:230-233` ("load-order defect … disclosed, not claimed conformant") | none | plan commit carries hashes of the canonical skill/protocol files read before it; fails on round 25's ordering, passes once the receipt is in the plan commit |
| U13 | supersession/used-by edges stay prose, so pointer closure misses consumers | `corpus/lessons/round-23.md:153` M23-2 (S012 consumers found by grep in `corpus/feature-claims.json:63-77,915-932`) | none (QA10 qualifiers, QM16 provenance) | a `supersedes:` column checked for reciprocity + consumer closure; fails on S012 until the edges are machine rows |
| U14 | install/action record omits a side effect that wrote host config outside the sanctioned channel | `corpus/lessons/round-22-verifier-spotcheck.md:167` D2 (mise wrote `~/.config/mise/config.toml`, unrecorded) | none | the record lists every host path written and its channel; check compares it against the captured write list; fails on round-22's missing mise line |
| U15 | a count depends on the clone's directory name/parent contents, not only the command | `corpus/lessons/round-25.md:155` M25-4 (73 lone misses at round-24 closure vs 88 on `/fast/scratch`) | none (QM2 nearest: command/host, not path shape) | pins the resolved tree path and parent listing beside the count; the 73→88 delta is the red witness |

Captured, therefore not listed: M22-1/2/3/5 (QA10/QM13/QM14), M23-1/3/5
(QM16/QM19/QM15), M24-1/3/5/7/8/9/10/11 (QM16/QM18/QM20/QM19/QM15),
M25-1/3 (QM21/QM22), M26-1/3 (QM14/QM23/QM24), M27-1/2 (QM25/QM26),
round-23 D1/D2/D4–D6/D8 (QM5/QM15/QM16/QM17), round-22 D3/D4/D7–D9
(QM12/QM13/QM14/QM16/QM19). The round-21 spot-check's defects are
QA10/QM13 (already absorbed).

## Executed probe (falsifiable draft, sandbox only)

`.ufo/waves/round-28/sandboxes/ScoutMistakeSweep/round-conformance.py`; run
`python3 -I -B round-conformance.py <lane> bdf90f5 3553d499… | tee probe-base.txt`
→ **exit 1**, `ROUND_CONFORMANCE: FAIL (28 failing checks)` (intended red).
Per-check: `PLAN_FIRST` FAIL R22–R27 / PASS R28; `APPEND_ONLY` PASS 22–28
(proves append-only is not the missing rule); `CENSUS_START` FAIL R22, R23,
R27; `CENSUS_REVISION` PASS only R26; `CENSUS_TIMING` PASS only R28; combined
`CENSUS_RECEIPT` 0/7. No round yet ships both timestamp and revision.
**Round-28 finding:** `census-start.txt` starts `2026-10-21T13:38:30-03:00`
(plan commit `bdf90f5` at `13:44:04`), so timing binds, but the file carries no
`revision=` line; append `revision=3553d499…` before the END census or the
receipt is not self-binding. Fixes for U4–U15 were not implemented as probes;
their failing witness is the cited artifact.

## Commands (all exit 0 unless stated)

`git log --diff-filter=A --format='%h %s' -- plans/round-27.md`; `git show
--stat 144babc`; per-round first-add loop (22–28); `git diff --stat 3553d499…
-- corpus/lessons/round-2*.md LOG.md corpus/QUALITY.md` (empty); `grep -c W04
.ufo/reports/round-22/kagi.md` → 0 (**exit 1**); `awk … grep -c supersedes:` →
0 (**exit 1**); probe run (**exit 1**). Read-only git only; no lane gate,
selftest, release clock, ledger, census, vault, handler or host-private read
was run. No tools installed.

## Not checked

No source/feed re-open; no correctness audit of the round-22..27 claims; only
rounds 21/22/23 spot-check files and the six fleet reports were swept, not
every seat report under `.ufo/waves/round-2{2..7}/`; rounds before 22 only
where a defect persisted (M24-4 chain); no test that QUALITY's captured rows
actually fail when violated; round-28 frozen C1/C2 counting commands and
fixture sets were not executed (not this seat's claim).
