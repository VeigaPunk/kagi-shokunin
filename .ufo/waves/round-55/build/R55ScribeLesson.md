# R55ScribeLesson — accuracy review of the round-55 prose against committed bytes

- Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master.
- Measured revision (candidate): `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f` (`git -C … rev-parse 348aa3b8…` → same 40-hex; `git rev-parse master` → same; candidate is HEAD).
- BASE: `ebe095857a734caf5efdd7bd776feb22b4e23972`.
- Predeclaration: `f2b986fadd8f8551e760cc89f59e0ae0edb0d499` (`git cat-file -t` → commit; `merge-base --is-ancestor` → ancestor of candidate; `git diff --stat f2b986fa 348aa3b -- plans/round-55.md plans/round-55-c1.sh plans/round-55-c2.sh plans/round-55-controls.sh` → empty, i.e. no amendment).
- Scratch: `/fast/scratch/hyaku/kagi-r55/R55ScribeLesson` (all archives, fixtures, TMPDIR).
- Receipts: `.ufo/waves/round-55/build/R55ScribeLesson.d/` (copies of every command output cited below).
- Scope: prose only. No lane file was edited; nothing was fetched from the network (all checks read committed bytes or committed captures).

## Verdict

The two claim numbers and the census arithmetic reproduce exactly at the candidate: C1 25 → 0, C2 0 → 2, selftest 70 → 78, registry 112 → 114, 20 rows touched / 25 used-by paths, 10 `cites:` entries, 22 controls all MATCH. Four accuracy defects and three wording notes were found; none changes a claim value. Five items cannot be checked from committed bytes (two prose claims, one LOG observation, one forward-looking SCORECARD line, one carried ledger set) and are listed separately, not scored as defects.

## Defects

| id | location | stated | observed (command → output) | proposed fix | severity |
|---|---|---|---|---|---|
| D1 | `corpus/lessons/round-55.md:16` (S113 bullet) and `:17` (S114 bullet) | `Quote (4 words, printf '%s' … \| wc -w)` / `Quote (4 words)` for `ISO/IEC 11770-3:2021/Amd 1:2025` | `printf '%s' 'ISO/IEC 11770-3:2021/Amd 1:2025' \| wc -w` → `3` (tokens: `ISO/IEC`, `11770-3:2021/Amd`, `1:2025`) | state `Quote (3 words, …)` in both bullets; the counting rule at `:23` already names the command, so no other change | **material** — a stated count that its own rule contradicts (the same class as round-49 E49-1 / M53-6) |
| D2 | `corpus/lessons/round-55.md:16` (S113 bullet) | “the default user agent receives HTTP 403, receipt `capture/rejections/default-ua_85929.meta`” | `git show 348aa3b:.ufo/waves/round-55/capture/rejections/default-ua_85929.meta` → `403 text/html; charset=UTF-8`; the `85929` in the name is the **S114** URL. `git ls-tree -r 348aa3b -- .ufo/waves/round-55/capture \| grep default-ua` → only `default-ua_85929.{body,meta}`; no default-UA probe of `82709` is committed | move the receipt to the S114 bullet (“the default user agent receives HTTP 403 on the 85929 URL, receipt `capture/rejections/default-ua_85929.meta`”) and in the S113 bullet either drop the receipt or add the 82709 probe; the S113 row's same assertion (“the default user agent receives HTTP 403”) then needs the 82709 probe as its pointer | **material** — an evidence pointer attached to the wrong URL |
| D3 | `corpus/lessons/round-55.md:53` (Assimilation) | “Sweep `grep -rlE '11770\|iso\.org/standard/(82709\|85929)' /home/vgpnk/Projects/shokuknow/merge/kagi` ⇒ 10 files” | same command re-run → `22` files: `MERGE-REPORT.json`, `MERGE-REPORT.md`, `SOURCES.append.md`, and 19 `knowledge/corpus/knowledge/*.md` (8 GB/T 17901 / China entries, 5 ISO 11770-3, 2 ISO 11770-8, 4 series). Every hit has mtime `2026-10-24T23:33`, i.e. the package did not grow after the sweep | state `⇒ 22 files` and keep the same description of what the hits are; or narrow the command (e.g. `--include='*.md'` on the staged entry files) and state the count that command gives | **material** — a stated command result that the command does not give |
| D4 | `corpus/lessons/round-55.md:18` (S101 bullet) | “`grep -c 'Withdrawal of International Standard'` gives 2 on both (byte offsets 45705 stage line, 62733 life-cycle list)” | `grep -bo 'Withdrawal of International Standard' S101.raw` → `45752`, `62765`; `grep -bn …` → `45705`, `62733` (line starts). The S101 row itself states “byte offset 45752” | write “line-start offsets 45705 and 62733 (`grep -bn`; match offsets 45752 and 62765, `grep -bo`)”, so the parenthetical does not read as the match offsets used in the S113/S114 bullets | low — the numbers are reproducible, but only under a different flag than the sentence implies, and they disagree with the row's own offset |
| D5 | `LOG.md:1917` (Round 55, predeclaration bullet) | “22 MATCH incl. two no-work BASE controls and eighteen forgery/fail-closed controls” | `controls-prefreeze.txt`: 22 `CONTROL` lines = 2 BASE (`K1-BASE`, `K2-BASE`) + 2 reference (`K1-REF`, `K2-REF`) + 18 fail-closed (`K1-F1..F9`, `K2-F1..F9`); `CONTROLS: match=22 mismatch=0`. 2 + 18 = 20 ≠ 22 | “22 MATCH: two no-work BASE controls, two reference controls, eighteen forgery/fail-closed controls” (the plan §Controls already counts all four groups) | low — each number is true; the decomposition omits the two reference controls |
| D6 | `corpus/lessons/round-55.md:37` (D3) | “feed-URL normalisation stay routed” | round-54 routed item 5 D is “feed-URL **uniqueness** is exact-string (a trailing-slash or `?query` twin row scores; the gate has no feed-URL uniqueness check)”; round-54 spot-check D3 says “feed-URL uniqueness” | “feed-URL uniqueness (round-54 routed item 5 D) stay routed” | low — wording drift from the routed item it names |
| D7 | `corpus/lessons/round-55.md:16` | “with the browser user agent the S101 row already declares” | the S101 row says only “fetched 2026-11-05 with a browser user agent”; the UA **string** is declared in the entry's `recheck:` line (`Mozilla/5.0 (X11; Linux x86_64) … Chrome/124.0 Safari/537.36`) | “with the browser user agent the entry's `recheck:` line declares (the S101 row records only that a browser user agent was used)” | low — pointer is one hop off |

## No defect (checked item → command → output)

| checked item | command | output |
|---|---|---|
| C1 value at candidate | `bash plans/round-55-c1.sh 348aa3b8…` | `C1_USEDBY_GAP: value=0 gap=0 citations=90 entries=37 guard=1 (bad=none)` |
| C1 value at BASE | `bash plans/round-55-c1.sh ebe09585…` | `C1_USEDBY_GAP: value=25 gap=25 citations=88 entries=37 guard=1 (bad=none)` |
| C2 value at candidate | `bash plans/round-55-c2.sh 348aa3b8…` | `C2_ISO_CURRENT: value=2 amd=1 recheck=1 guard=1 (bad=none)` |
| C2 value at BASE | `bash plans/round-55-c2.sh ebe09585…` | `C2_ISO_CURRENT: value=0 amd=0 recheck=0 guard=1 (bad=amd:a-rows=0,recheck:S101-count-2-stated-1)` |
| 25 (row, entry) pairs at BASE | `c1-base.txt` | 25 `GAP` lines; `value=25 gap=25` |
| all 25 cells now list the entry | python over `SOURCES.md` @ candidate vs the 25 GAP pairs | `cells missing entry: []` |
| 20 rows touched, 25 added paths, append-only, all `corpus/knowledge/*.md` | python diff of used-by cells BASE→candidate | `touched rows 20`, `added paths 25`, `removed-paths: none`, `NON-KNOWLEDGE PATH` never printed |
| only used-by cells changed (status/recheck unchanged) | python cell-by-cell compare of the 20 rows | `bad: none` |
| registry 112 → 114 | python row count on `SOURCES.md` at both revisions | `rows base 112 cand 114`; new ids `['S113','S114']` |
| rows added 2, tier A 2 | `SOURCES.md` S113/S114 cells | both `A`; recheck `180d` |
| ten entries, one column-1 `cites:` line each | `git grep -c '^cites:' 348aa3b -- corpus/knowledge` | 10 files, each `1`; BASE → 0 files |
| selftest 70 → 78 | `git archive` of each revision, `bash corpus/sources-census.sh --selftest` | BASE `SOURCES_CENSUS_SELFTEST: PASS (70 cases)`; candidate `PASS (78 cases)` |
| SKILL.md:49 / PROVINCE.md:78 count sentences | `git show 348aa3b:SKILL.md \| sed -n 49p`; `…:PROVINCE.md \| sed -n 78p` | both “78 cases”; PROVINCE decomposition `40+7+12+11+8 = 78`; BASE both “70 cases” |
| eight round-55 census cases | selftest table lines 649–656 | `body-cite-unrecorded`, `body-cite-legacy`, `body-cites-control`, `body-cites-usedby-omits`, `body-cites-not-a-row`, `body-cites-two-lines`, `usedby-via-cites-control`, `body-digit-suffix-control` = 8 |
| M55-1's five fail-closed case names | same table | all five present, each `|1|SC_BODY_CITE|1` (exit 1) |
| K1-F8 / K1-F9 / K2-F1 | `controls-prefreeze.txt` | `K1-F8-base-census … MATCH` (FAIL), `K1-F9-one-record-withdrawn … MATCH` (FAIL), `K2-F1-stale-expectation … value=1 amd=1 recheck=0` |
| 22 controls all MATCH | `controls-prefreeze.txt` | 22 `CONTROL` lines, `CONTROLS: match=22 mismatch=0`, `exit=0` |
| predicates verbatim | `plans/round-55.md:15,27`; `c1.sh:7`; `c2.sh:7` | identical to the two lesson quotes |
| S113 capture size/hash/offset | `wc -c`; `sha256sum`; python `find` | `90604`; `d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357`; offsets `[53493, 53739, 69404]` (first = 53493) |
| S113 recheck `-> 3` | `grep -c 'ISO/IEC 11770-3:2021/Amd 1:2025' S113.body` | `3` |
| S113 stage line after tag stripping | python tag-strip of `S113.body` | `Stage : International Standard published [ 60.60 ]` |
| S114 capture size/hash/offset/subtitle | `wc -c`; `sha256sum`; python `find` | `85138`; `8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf`; title offset `541`; subtitle `Amendment 1: TFNS identity-based key agreement` offset `670` |
| S114 refetch digest | `S114-refetch.meta` | `sha256 8bb88d88… (refetch 2026-11-07T04:36:13-03:00, body identical …, not kept)` |
| S114 date/stage after tag stripping | python tag-strip of `S114.body` | `Publication date : 2025-04`; `Stage : International Standard published [ 60.60 ]` |
| S101 capture size/hash/count | `wc -c`; `sha256sum`; `grep -c` | `85615`; `2e4c1524ec05865536f819db68c56494d97fc67cb490df4f5d4b1ca85b7b0c80`; `2` |
| S101 `-> 1` at BASE | `git show ebe09585:corpus/knowledge/iso-11770-3-edition-status.md \| sed -n 3p` | `… grep -c 'Withdrawal of International Standard'` -> 1 (ran 2026-11-05)` |
| S101 entry `-> 2` and S113 `-> 3` at candidate | `sed -n 3p` of the candidate entry | `-> 2 (ran 2026-11-07; the round-45 line said 1 …)`; `'https://www.iso.org/standard/82709.html' \| grep -c 'ISO/IEC 11770-3:2021/Amd 1:2025'` -> 3` |
| BASE entry quoted phrase | `grep -n 'newer amendment' iso-entry-base.md` | `names a newer amendment to the 2021 edition as the version that now exists`; BASE entry contains no `Amd 1:2025` (`grep -c` → 0) |
| RSS rejection body | `wc -c`; `sha256sum`; `grep -o` | `1371`; `d17018559e7eb539576647995a41a3555f71917ce8a4eec9795154f4db152475`; `reached stage 60.60 on 2021-10-22`; `<item>` count `1`; no `Amd`/`Amendment` |
| IEC rejection body | `wc -c`; `sha256sum`; python `find` | `429695`; `6a557e1d8c4eab3d0af3b75265457feb9edab272b06047247efbfed9e68cc6b9`; `ISO/IEC 11770-3:2021/AMD1:2025` at `187` |
| S172 staged at `SOURCES.append.md:127` | `sed -n '125,129p'` | line 127 = `| S172 | IEC Webstore — ISO/IEC 11770-3:2021/AMD1:2025 — https://webstore.iec.ch/en/publication/107179 …` |
| S161 iTeh preview | `grep -n '^| S161 '` | `ISO/IEC 11770-3:2021 (fourth edition) — foreword and Scope, in the iTeh Standards document preview` |
| QM71 present | `git show 348aa3b:corpus/QUALITY.md \| grep -n -A12 'QM71'` | row at `:254`, gate `SC_BODY_CITE (round 55)`, BASE evidence 25 pairs |
| migrations journal 8 rows | python `json.load` | `migrations len 8`; ids `R13-01, R21-02, R21-03, R24-06, R31-02, R33-02, R34-03, R38-01` |
| ledger diff = the 8 journaled rows | `git diff ebe09585 348aa3b -- corpus/claim-ledger.tsv` | 8 insertions / 8 deletions, same 8 ids; `R21-03` 70→78, `R38-01` 10→12, census `rows=112`→`rows=114` |
| D4 FAIL/POLICY set | `.ufo/waves/round-54/final/verify-tip.txt` | `FAIL R11-08`, `FAIL R25-02`, `FAIL R36-01`, `POLICY R29-01`, `POLICY R29-02`, `POLICY R38-03` — matches the lesson's D4 |
| spot-check pointer `:88-93` | `sed -n '86,90p'` + `grep -n '^- \*\*D[1-4]'` | line 88 = `## 5. Defects routed to the lane (next round)`, 89 blank, D1–D4 at 90–93 — the range covers the section and all four defects |
| round-54 routed items 1–8 | `sed -n '43,52p'` of round-54.md | items 1–8 present; item 1 names round-53 items 3 (op feed parser) and 4 (op on-release with no clock) as closed by round-54 C1 |
| six other `grep -c` entries, one `locate` | python over `recheck:` lines of `corpus/knowledge/*.md` @ candidate | `grep -c`: 7 entries incl. `iso-11770-3-edition-status.md` → six others; `locate`: 1 (`cdp-bridge-1password-oidc-workflow.md`, `rendered-text-v1.py locate`) |
| E49-1 counting rule | `git grep -n 'E49-1'` | erratum defined at `corpus/lessons/round-49.md:51`; cited by rounds 49–54 lessons — lane convention, not a QUALITY id |
| LEARNING.md exists | `ls -l /home/vgpnk/Projects/shokunin/LEARNING.md` | `5562` bytes, fleet root — the `(LEARNING.md)` pointer resolves |
| considerthese newest + proposal 5 | `git ls-tree considerthese`; `sed -n '98,126p'` | newest `2026-10-26.md`; proposal 5 = “Check quotes, not page hashes, for source freshness” |
| corpus README ISO row | `git diff ebe09585 348aa3b -- corpus/README.md`; `git show 348aa3b:README.md \| grep -n -i 'iso\|11770'` | row gains “round 55: the 2021 edition carries ISO/IEC 11770-3:2021/Amd 1:2025 (S113, S114, opened 2026-11-07)” — S113/S114/date correct. The lane-root `README.md` has no ISO/11770 text (grep → no output), so the ISO row is `corpus/README.md` |
| manifest rows `55 C1`/`55 C2` | `git show 348aa3b:corpus/claims-declared.tsv \| grep 55` | `55	C1	calibration`, `55	C2	freshness` (the lane's claims manifest; the fleet `MANIFEST.json` has no kagi round-55 entry yet, which is the orchestrator's admission step, not a lane file) |
| counter hardening (D3) | `grep -n` in `c1.sh`/`c2.sh` | `python3 -I -B - …` at `c1.sh:71`, `c2.sh:76`; fence-aware registry parse at `c1.sh:79-85`, `c2.sh:100-106`; per-component symlink check in `safe()` at `c2.sh:96` |
| 32 release clocks | `grep -c '| on-release |' SOURCES.md` @ candidate | `32` — matches the LOG's “32 release clocks” |
| no staged row/entry appended | `git diff --name-only ebe09585 348aa3b` | no `shokuknow` path, no `considerthese` path in the candidate tree |

## Unverifiable from committed bytes (recorded, not scored as defects)

1. `round-55.md:18` “the 2026-11-07 live body is byte-identical to the round-45 capture” — the live 2026-11-07 S101 body is not committed; the committed round-45 capture does match the stated digest and size (`2e4c1524…7b0c80`, 85615 B).
2. `round-55.md:16` “90604 B (identical to an earlier same-day fetch)” — no earlier S113 receipt is committed; only `S113.meta`/`S113.body`/`S113.headers` exist.
3. `LOG.md:1917` “all 32 release clocks re-observed (0 failures, no new release; scratch receipt, not committed)” — 32 is the correct population (`on-release` rows), but the observation receipt is explicitly scratch; the result cannot be checked from the lane.
4. `SCORECARD.md:1830` “the revision-bound readings of the landed commit follow in the round's receipts commit, named in the report” — no receipts commit exists yet (`git log 348aa3b..master` is empty; candidate is HEAD). Forward-looking, pending the wave's receipts commit.
5. The D4 FAIL/POLICY set is carried from the round-54 tip verify receipt, not re-measured in round 55; this seat did not run `claim-ledger.sh verify` (out of scope per the seat's read-only rule).

## Commands run (all read-only; cwd = scratch or lane root)

```
git -C <lane> rev-parse 348aa3b8… ; rev-parse ebe09585… ; rev-parse master
git -C <lane> show <rev>:<path>            # lesson, LOG, SCORECARD, QUALITY, SKILL, PROVINCE, README,
                                           # corpus/README.md, SOURCES.md, iso entry, claims-declared.tsv,
                                           # claim-ledger.tsv, sources-census.sh, plans/*.sh, captures
git -C <lane> diff ebe09585 348aa3b -- corpus/SOURCES.md corpus/claim-ledger.tsv corpus/README.md
git -C <lane> grep -c '^cites:' 348aa3b -- corpus/knowledge
git -C <lane> archive <rev> | tar -x -C <scratch>/tree[-base]
bash corpus/sources-census.sh --selftest          # BASE 70 cases, candidate 78 cases
bash plans/round-55-c1.sh <rev> ; bash plans/round-55-c2.sh <rev>   # BASE 25/0, candidate 0/2
wc -c / sha256sum / grep -bo / grep -bn / grep -c on the committed captures
python3 (stdlib only) for row/cell/offset/word-count checks
grep -rlE '11770|iso\.org/standard/(82709|85929)' /home/vgpnk/Projects/shokuknow/merge/kagi
```

No network fetch, no git mutation, no lane edit, no `op` invocation, no secret material read.

SEAT-STATUS: complete
