# ScoutVerifierSpotchecks — round-28 build scout (kagi)

Question: for every disagreement or routed defect in `corpus/lessons/round-2{1,2,3}-verifier-spotcheck.md`,
does a lesson-backed `corpus/QUALITY.md` criterion (QA/QM id) or a committed fix exist?
BASE `3553d499577084a6c98d7078906017840bbf7b28`. All four target files are byte-identical to BASE
(`git diff --stat BASE -- <4 paths>` empty, exit 0), so working-tree line numbers are BASE numbers.
Method: read the three spotchecks, QUALITY, fix records at BASE; no gate or selftest executed.

## Findings

**F1 (calibration, structural).** The nine round-22 routed defects produced *zero* QUALITY rows.
Within `corpus/QUALITY.md`, `verifier-spotcheck` citations name only the round-21 file (`:71,72`)
and the round-23 file (`:91,97,98,99`); no row cites `round-22-verifier-spotcheck.md`. Its defects
were retired as per-item dispositions at
`corpus/lessons/round-23-verifier-spotcheck.md:127-131` ("D1, D4, D5, D6, D7 and D9 were fixed on
substance. D2 … and D8 … are named and operator-owned"), not as reusable bars. Consequence: five
round-22 classes have no criterion that can fail on a recurrence (F3).

**F2 (no QUALITY bar, no durable fix).** Three routed items have neither a QUALITY id nor a fix
that can fail again on recurrence (D2's naming duty was discharged in the round-23 report):
- `round-22-verifier-spotcheck.md:167-169` D2 (mise wrote global `~/.config/mise/config.toml`):
  named at `/home/vgpnk/Projects/shokunin/.ufo/reports/round-23/kagi.md:106-108`, revert
  operator-owned. Host ground; no corpus rule (QUALITY keyword sweep `mise` = 0).
- `round-22-verifier-spotcheck.md:182` D8 (`/tmp/kagi-shokunin` residue): named at the same report
  line 108, operator-owned; no corpus rule (`/tmp` = 0, `scratch` = 0).
- `round-23-verifier-spotcheck.md:201-202` D7 (wave evidence must land before the fleet report):
  `corpus/lessons/round-24.md:118-120` records it as "**D7 process**" — a prose commitment, with no
  command, ledger row or fixture that fails when evidence lands after the report. `W04`, `spawn` and
  `fleet report` sweeps over `corpus/claim-ledger.tsv` return 0/0/0; the two `wave evidence`/`spawn`
  hits in `corpus/claim-ledger.sh` (lines 537, 662) are comments, not checks.

**F3 (fixed, never codified).** Five items have a committed one-off fix but no criterion that would
catch the class again: round-22 D1 warnings dropped (`W04` count in `corpus/claim-ledger.tsv` = 0;
nearest QM19 `corpus/QUALITY.md:106` enumerates exit/summary/population/skips/failures, not
warnings), D4 boilerplate drift dispositions (QM14 `:73` requires old/new migration values, not the
drift-causing commit), D5 duplicate wave ids/names (QM18 `:100` is scoped to "a ledger row", not a
wave roster), D7 missing per-row capture fields (QM16 `:98` covers classification of in-row pins,
not registry prose freshness), round-23 D2 Gate-registry row (QM5 `:43` says "claim ledger", the
missing surface was `SKILL.md` §Gate registry).

**F4 (reflected).** Round-21's two disagreements both map: E1/E3 admission failure
(`round-21-verifier-spotcheck.md:12`) → QA10 (`QUALITY.md:71`) and QM13 (`:72`); the round-22
spotcheck's debt record also names QM14 (`:73`), whose text covers revision-pin/expectation
migration, not the admission decision. C2 non-admission (`:17`, "counts of rows the lane wrote") →
QM13. Round-23 D4/D5/D6/D8 and M23-5 → QM15/QM16/QM17 (`:97-99`), each row citing the exact
defect id.

**F5 (residual, not in the D lists).** `round-23-verifier-spotcheck.md:69` records "Supersession is
prose only (S014/S016 stay `mined` and cited)". At BASE both still carry status `mined`
(`corpus/SOURCES.md:20,22`); the demotion exists only in the round-24 Gate recapture table
(`round-24.md:91,93`) and `corpus/inrow-pins.tsv`. QM17 (`QUALITY.md:99`) forces the Gate record,
which exists, but no criterion requires the registry status cell to transition. [INFERENCE] The
Gate satisfies QM17, yet a reader of `SOURCES.md` alone still sees `mined` for the two demoted
locators; the demotion is only in lesson prose and the pin TSV.

**F6 (operator lessons).** None exist: `git ls-tree -r --name-only BASE | grep -i operator` → exit 1
(no match); `corpus/lessons/operator-*` glob → no files. Nothing to honour under round-prompt §5.

## Mapping (BASE line references)

| item | disposition | criterion / fix evidence |
|---|---|---|
| R21 spot-check :12 E1/E3 admits disagreed | reflected | QA10 `QUALITY.md:71`, QM13 `:72` (QM14 `:73` covers pin migration only); record `round-22-verifier-spotcheck.md:119-121` |
| R21 adjudication :17 C2 not an axis move | reflected | QM13 `QUALITY.md:72` |
| R22 D1 :165-166 W04 warnings omitted | fix only | report quotes seven W04 lines at `.ufo/reports/round-23/kagi.md:85-91` (grep `W04` = 14 lines, incl. a seat filename at :112) |
| R22 D2 :167-169 mise global config write | **none** | named report :106-108; operator-owned |
| R22 D3 :170-172 verify token guard | reflected | QM15 `QUALITY.md:97`; any positional refused `claim-ledger.sh:359-364`; case `:1585` `mode-unknown-revision` |
| R22 D4 :173-174 boilerplate dispositions | fix + QM14 (partial) | per-tuple drift commits `round-23.md:98-100`; QM14 `QUALITY.md:73` |
| R22 D5 :175-176 130 ids / 129 names | fix only | report :119; no criterion (QM18 `:100` is ledger-row scoped) |
| R22 D6 :177-179 `.h1` vs measured bytes | reflected | QM8 `QUALITY.md:46`; `measured_commit` in `.ufo/waves/round-23/final-verification.json` = `57776b28`, round-24 = `6c23a56d` |
| R22 D7 :180-181 per-row capture fields | reflected (capture half) | QM16 `QUALITY.md:98`; `corpus/source-fetches.tsv` 43 data rows incl. S017-S026, `inrow-pins.tsv` 16 rows. Prose half: `round-22.md:23` still says "S017-S020 added" against its own S017-S021 table; the corrected total sits at `:89-91`, unmarked beside the stale sentence |
| R22 D8 :182 `/tmp` residue | **none** | named report :108; operator-owned |
| R22 D9 :183-184 cells skip beside parser change | reflected (fix) | R23-01 `corpus/claim-ledger.tsv:59`; nearest QM4 `QUALITY.md:42` |
| R23 D1 :183-185 SCORECARD main table | reflected | QM5 `QUALITY.md:43`; row `SCORECARD.md:687`, prose `:690` |
| R23 D2 :186-188 Gate registry / census pins | fix only | `SKILL.md:751`; pins now name `source-fetches.tsv`/`inrow-pins.tsv` at `:754` |
| R23 D3 :189-192 closure selftest binding | reflected | QM5 `:43`, QM8 `:46`; R24-02 `claim-ledger.tsv:65`; measured commits above |
| R23 D4 :193-195 cells executes host rows | reflected | QM15 `:97` (cites D4), QM20 `:107`; `claim-ledger.sh:180-190,574-575`; R18-01 `[host]` `claim-ledger.tsv:48` |
| R23 D5 :196-198 silent legacy pins | reflected | QM16 `:98` (cites D5); `sources-census.sh:362` prints `captures= inrow= inrow_only= inrow_nonreproducing=` |
| R23 D6 :199-200 normalizer declared three ways | reflected | QM16 `:98` (cites D6); `corpus/rendered-text-v1.py` exists (`git cat-file -e` exit 0), cited in the TSV header |
| R23 D7 :201-202 evidence before report | **process only** | `round-24.md:118-120`; no check |
| R23 D8 :203-205 Gate logged no rejects | reflected | QM17 `:99` (cites D8); `round-24.md:53-72,121` records rejects and the S014/S016 demotion |
| R23 M23-5 :150-158 untagged R18-01 ran | reflected | QM15 `:97` (cites M23-5); same fix surface as D4 |

No QUALITY bar and no durable fix: R22 D2, R22 D8 (host-owned), R23 D7 (process only).
Fixed but not codified as a bar: R22 D1, D4 (partial), D5, D7 (prose half), R23 D2.

## Commands run (all at BASE unless noted; exit in brackets)

- `git diff --stat BASE -- <4 target paths>` → empty `[0]`; `git status --porcelain` on them → empty `[0]`.
- `git ls-tree -r --name-only BASE | grep -i operator` → no output `[1]`; `corpus/lessons/operator-*` glob → no files.
- `grep -n verifier-spotcheck corpus/QUALITY.md` → 71,72,91,97,98,99 (round-21/round-23 files; no round-22 citation) `[0]`;
  cross-references elsewhere: `round-22-verifier-spotcheck.md:56`, `round-22.md:33`, `round-23-verifier-spotcheck.md:47`.
- `grep -c -i <kw> corpus/QUALITY.md` for `W04|warning|mise|spawn|scratch|/tmp|wave evidence|Gate registry` → 0 each `[0]`.
- `grep -c -i <kw> corpus/claim-ledger.tsv` for `W04|spawn|CriticNoTrade|wave evidence|fleet report` → 0 each `[0]`.
- `git cat-file -e BASE:corpus/rendered-text-v1.py` → `[0]`; `source-fetches.tsv` data rows 43 `[0]`; `inrow-pins.tsv` 16 `[0]`.
- `git show BASE:SCORECARD.md | grep -n 'closure disposition review'` → 687, 690 `[0]`.
- `git show BASE:SKILL.md | grep -nE 'closure-dispositions|source-fetches|inrow-pins'` → 751, 754 `[0]`.
- `git show BASE:corpus/claim-ledger.sh | sed -n '359,364p'` → `unexpected positional argument for $MODE`; `grep -n mode-unknown-revision` → 1585 `[0]`.
- `grep -c W04 /home/vgpnk/Projects/shokunin/.ufo/reports/round-23/kagi.md` → 14 `[0]`; `grep -n '130\|129'` → 119 `[0]`.
- `git show BASE:corpus/lessons/round-23.md | grep -n 'f4a8dd9\|bad9088\|584dd67'` → 98-100 `[0]`.
- `git show BASE:.ufo/waves/round-2{3,4}/final-verification.json | grep measured_commit` → `57776b28…`, `6c23a56d…` `[0]`.
- `git show BASE:corpus/SOURCES.md | sed -n '20p;22p' | grep -o '| mined'` → both `mined` `[0]`.

## What I did NOT check

- No lane gate, selftest or census was executed (contract): every fix above is read from committed
  bytes; "case exists" is not "case passes", so QM19-style receipts are absent here by design.
- I did not read the round-22 fleet report at its own commit, so D1's "five W04 omitted" is taken
  from the round-23 spotcheck and checked only against the corrected round-23 report.
- I did not verify the host-side mise config write or `/tmp/kagi-shokunin` (host ground; operator-owned).
- I did not re-open vendor pages; no source-truth claim is re-verified.
- No `round-24/25/26/27-verifier-spotcheck.md` exists (`corpus/lessons/` listing), so the mapping
  stops at round 23.
- Round-21 spot-check's "reject 3/3 agree" and round-22/23 verdicts were read as dispositions, not
  re-adjudicated.

Tool installs: none (no install or upgrade was needed).
