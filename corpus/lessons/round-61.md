# Round 61 — kagi (secrets & vault ops)

Lane: kagi. Round 61, attempt 1. Claim BASE `c940f51689d702f1786989d56ad4663833c1452e`
(round-60 verifier spot-check tip). Frozen plan `plans/round-61.md` (predeclaration
`8595018164f7421864254c6c5ca762b8f201e8be`). Wave `kagi-r61-w1`, 16 seats (v1 band 8–16;
plan §Wave plan).

Claims: **C1 calibration** — the seven round-60 routed record defects are resolved and
re-checkable (`C1_ROUTED` 7 → 0, population 7). **C2 operability** — an executed OpenBao
seal / unseal key-share custody trial with its own fixture-driven `--selftest`
(`C2_SEAL_TRIAL` 0 → 5).

## Gate

Three rows were opened live this round (S125–S127) and admitted; one further OpenBao page
was opened by the scribe and refused. The scout's capture notes
(`.ufo/waves/round-61/capture/notes.md`, §0–§5) carry the fetch record, the raw-literal
anchor and the `rendered-v1` count for every quote below; each quote is cited from that
ledger and was re-resolved by the scribe with
`python3 corpus/rendered-text-v1.py locate <capture> QUOTE` ⇒ `count=1` (receipt
`build/R61ScribeLesson/gate-quotes.txt`). Access date for all three is 2026-11-07; the
capture sha256s and byte counts agree with the scout's fetch record
(`build/R61ScoutSealDocs/fetch-record.txt`, `digest.txt`).

| row | URL | access date | located quote (≤25 words) | decision | reason / flip |
|---|---|---|---|---|---|
| S125 | https://openbao.org/docs/concepts/seal/ | 2026-11-07 | "A certain threshold of shares is required to reconstruct the unseal key, which is then used to decrypt the root key." (§Shamir seals; 21 words; notes §1c, raw anchor byte 24781 line 30 of `S125.body`; capture sha256 `643c78c9…`, 44279 B) | admit, tier A | grounds the row's `teaches` (the unseal key, its shares, the threshold) and C2's T1/T2 arithmetic; flip: a revision that drops the Shamir share/threshold sentence |
| S126 | https://openbao.org/docs/commands/operator/rekey/ | 2026-11-07 | "operator rekey command is deprecated, please use rotate-keys instead." (§operator rekey warning; 9 words; notes M3.1, raw anchor byte 29121 line 13 of `S126.body`; capture sha256 `53a4574a…`, 44328 B) | admit, tier A | grounds T5's docs-vs-binary divergence: the page documents `operator rekey` and marks it deprecated in favour of `rotate-keys`, and states no backend caveat, so a 405 on a given build is a divergence from the documentation. Second quote, same row: "The operator rekey command generates a new set of unseal keys." (11 words; notes M3.2, byte 29249 line 14). flip: the warning removed, or `rotate-keys` withdrawn |
| S127 | https://openbao.org/docs/commands/operator/generate-root/ | 2026-11-07 | "The resulting token is XORed with this value when it is returned. Use the -decode flag to output the final value." (§operator generate-root; 21 words; notes M4.3–M4.4, anchors byte 29489 line 18 and byte 29555 line 19 of `S127.body`; capture sha256 `4adb6eb4…`, 38368 B) | admit, tier A | grounds T4's OTP second factor and `-decode`; second quote: "Nonce value provided at initialization. The same nonce value must be provided with each unseal key." (16 words; notes M4.6, byte 34359 line 69) grounds the per-share nonce. flip: the OTP/XOR sentence removed |

Rejected candidate (opened by the scribe, no row):

| URL | access date | measurement | decision | reason / flip |
|---|---|---|---|---|
| https://openbao.org/docs/configuration/seal/ | 2026-11-07 | HTTP 200, 36231 bytes, sha256 `fcc490965738b7cfa146fd0016f1e0f7e26b5fbf5aaeec87786f664eadf7de59`; over the tag-stripped body `threshold`=0, `key shares`=0, `progress`=0, `405`=0, `rekey`=0, `generate-root`=0 (`build/R61ScribeLesson/reject-candidate.txt`) | reject | it is the Auto Unseal stanza reference: it states no share count, threshold, unseal-progress or rekey/generate-root observable the trial measures, and it defers to the concept page ("Read more about seals in OpenBao on the concept page", S125), so a row here would duplicate S125's `teaches` with nothing measurable. Flip: a revision that states the Shamir share/threshold arithmetic or the unseal progress contract |

The scout's negative checks (`build/R61ScoutSealDocs/quote-resolution.txt`, notes §1d–§4)
measure that S125 states no `key-shares`/`key-threshold` flag, no
`progress`/`seal-status` field and no `nonce`, and that S126 and S127 state no
`405`/`unsupported`/`refused`/`not implemented` text — so every refusal, progress and
status string the trial quotes is measured, never cited from these pages.

Registry effect: `corpus/SOURCES.md` 124 → 127 data rows (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'`
⇒ 124 at BASE `c940f516`, 127 now), `git diff --numstat c940f516 -- corpus/SOURCES.md
corpus/source-fetches.tsv` ⇒ `3 0` / `3 0` (appends only, no existing cell rewritten); the
three rows are tier A, `mined`, `180d`, `used-by` naming `corpus/knowledge/openbao-seal-key-custody.md`.
Census: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` ⇒
`kagi ok`, rc 0, 127 rows, the standing W04 duplicate-URL warnings.

## Mistakes

| id | class | evidence pointer | captured-by | fix (and how it can fail) |
|---|---|---|---|---|
| M61-1 | record vs artifact — two lesson lines assert a seat produced nothing while the committed results file and build tree carry its output | `corpus/lessons/round-60.md:108` (R37 "produced no artifacts and no report") and `:128` (§Bounds "produced nothing"); `.ufo/waves/round-60/w1-results.json` ⇒ 16 results, `R60MutCounters` output 3824 B; `git ls-tree -r --name-only 818d2a82 .ufo/waves/round-60/build/R60MutCounters/` ⇒ 15 files (`mutants.md` + 14 under `raw/`). Receipt `build/R61ScribeLesson/mistakes-evidence.txt` | round-60 verifier spot-check D1 (non-author) | I1's appended `supersedes R37` line at `:176` states `results=16 output=3824` and names `mutants.md`; **able to fail**: control C1-F1 (a R37 correction carrying the wrong result count) must read 1 on the diagnostic leg, and the checker derives both numbers from `w1-results.json` rather than reading a constant |
| M61-2 | arithmetic vs population — a share stated over a list that contains a seat the wave does not have | `/home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md:10` reads "attack share 4/16 = 25 % on the addendum's literal list (reviewer, critic, mutation-tester, labrat — no labrat exists)"; the results file's `agent` fields give three present literal-list seats ⇒ 3/16 = 18.75 %, and 4/16 = 25 % counts the sentinel. Receipt `build/R61ScribeLesson/mistakes-evidence.txt` | round-60 verifier spot-check D7 (non-author); the lesson's own R36 already carried both readings | I7's appended correction at `:180` states both fractions and both percentages, with 3 derived from `w1-results.json`; **able to fail**: control C1-F7 (a correction with the wrong fraction) must read 1 |
| M61-3 | arithmetic vs population, sibling half — the same report sentence's second figure counts five attack seats as six | `/home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md:12` reads "6/16 = 38 % counting sentinel and revenger"; the results file's `agent` fields give reviewer + critic + mutation-tester + sentinel + revenger = 5 ⇒ 5/16 = 31.25 %, and `6/16` is 37.5 % even if the count were right. Receipt `build/R61ScribeLesson/mistakes-evidence.txt` | R61ScoutRouted residual 1 (`build/R61ScoutRouted/rederive.md`), re-derived by the scribe | **routed, not fixed**: the frozen item set quotes only the `4/16` half, so I7's correction does not reach this figure; the next round's report must state 5/16 = 31.25 %. **able to fail**: the derivation counts the five roles from the file and prints 5 and 31.25 %, so a report repeating 6 is contradicted by the same command |
| M61-4 | write scope — derived artifacts written outside the seat's scratch (two instances) | (a) `.ufo/waves/round-61/capture/` held `S125.body.txt`, `S126.body.txt`, `S127.body.txt` at 16:52 and the three bodies only after `rm -f`; the capture sha256s are unchanged (`build/R61ScribeLesson/mistake-writescope.txt`). (b) `/tmp/r61-trace.txt` (3001 B, 17:06) is a `bash -x` trace of `plans/round-61-controls.sh`, outside lane and scratch (R61Sentinel F4) | R61ScribeLesson (self, instance a) and R61Sentinel (instance b) | the scribe's locator output path goes through `outpath.sh`, which refuses any path outside `${HYAKU_SCRATCH}/kagi-r61/R61ScribeLesson`; the controls battery must redirect `bash -x` under `${HYAKU_SCRATCH}`. **able to fail**: the guard refuses the exact path that slipped with rc 2 and accepts a scratch path with rc 0 |
| M61-5 | instrument syntax — a brace group passed in argument position aborts the trial's selftest definition | `build/R61Reviewer/findings.md` §C2-1: `bash -n corpus/openbao-seal-trial.sh` ⇒ rc 2, `syntax error near unexpected token '}'` at line 839; post-fix `bash -n` ⇒ rc 0 (`build/R61ScribeLesson/mistake-trial-syntax.txt`) | R61Reviewer | the brace group became a `ck`-compatible form and the selftest runs; **able to fail**: the same `bash -n` check that failed now passes, and the trial's selftest executes its cases instead of dying at the definition |
| M61-6 | instrument parse/format — the C1 checker's two I2 legs could not pass on a correct tree | `plans/round-61-c1-check.py:377` splits the SKILL row on the pipe character without honouring the escaped pipe in the entry-command cell ⇒ 9 cells where the header has 8, so cell 4 (the verdict map) was read as the selftest cell; `C2_PASS_RE` expects `(N cases)` while the script prints `(cases=N)`. Checker reading at 17:11: `i2 FAIL selftest[rc=0 cases=None no-PASS-line] registry[selftest-cell='0 …C2_APPROLE_TRIAL: value=5 …']` (`build/R61ScribeLesson/c1-checker-i2-legs.txt`) | R61ScribeLesson (running the checker) | the 17:12 checker (sha256 `d525ee28…`) reads `i2 HOLD selftest[rc=0 cases=36 PASS-line] registry[selftest-cell='bash plans/round-60-c2.sh --selftest' …]`; **able to fail**: the same command that read `i2=0` now reads `i2=1` |
| M61-7 | instrument route — the trial's T4 authentication probe used a 404 route, so a valid token failed to authenticate | `build/R61ExecTrial/receipt-real-1.txt` read `T4 BROKEN req3=1 prog=1 dec=0 wrong=1` and `BROKEN holds=4 broken=1`; the sentinel's report §State note records the same (`token/lookup-self` 404 where 200 is required); the trial's report records the measured route (`/v1/token/lookup-self` is a 404 route on this build; the canonical self-lookup is `/v1/auth/token/lookup-self`) | R61ExecTrial (own receipts) and R61Sentinel | the probe was repointed at the canonical route; **able to fail**: the same receipt's T4 line moved from `BROKEN … dec=0` to `HOLDS`, and the summary from `BROKEN holds=4 broken=1` to `HOLDS holds=5 broken=0 error=0`, while the wrong-OTP leg still asserts the frozen "does not yield that token" |
| M61-8 | instrument oracle — the C2 counter has no independent oracle, so a printer-stub trial reads `value=5 guard=1` | `build/R61Reviewer/findings.md` §C2-3 (a 30-line stub that never touches OpenBao reads `value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1`), §C2-4 (`guard=1` is near-constant), §C2-5 (the counter's own selftest never executes the aggregation; two mutations pass) | R61Reviewer | **routed**: the frozen predicate's "real run" is a declared ceiling, so the fix belongs to the next round's counter — an independent oracle (a `bao` process/socket check, or a `bao=<ver>` requirement inside `holds5`) plus a selftest case that executes the aggregation. **able to fail**: the reviewer's stub tree reads `value=5` today, so the proposed oracle must read 0 on that same tree |

## Routed dispositions

The seven round-60 routed defects, the round-61 item that carries each, the file the fix
lives in, and the state measured at the time this lesson was written. The state column is a
read of the tree, not a verdict: the frozen checker's own reading is the L1's to take on the
committed revision.

| id | item | round-60 defect | file that carries the fix | state at write |
|---|---|---|---|---|
| D1 | I1 | the lesson says the mutation-tester produced nothing; the results file and build tree carry its 3824-byte output and `mutants.md` | `corpus/lessons/round-60.md` (appended `supersedes R37` line) | landed at `:176` (after R37 at `:108`); states `results=16 output=3824` and names `mutants.md`; checker `i1=1` |
| D2 | I2 | `SKILL.md` registers `plans/round-60-c2.sh` with selftest `none of its own` | `plans/round-60-c2.sh` (fixture-driven `--selftest`) and its `SKILL.md` row | landed: `bash plans/round-60-c2.sh --selftest` ⇒ `C2_SELFTEST: PASS (cases=36)` rc 0; `SKILL.md:855` carries `bash plans/round-60-c2.sh --selftest` and no `none of its own`; checker `i2=1` on the repaired checker (`d525ee28…`) |
| D3 | I3 | `plans/round-60.md` §A3 item 2 asserts a form-encoded-body behaviour its cited receipt does not carry | `plans/round-60.md` (`## Amendment A7`) and `corpus/lessons/round-60.md` (M60-2 second instance) | landed: `plans/round-60.md:331` `## Amendment A7` names `A3 item 2`, `form`, `l1-probe.txt` and states the item is withdrawn; lesson `:177` names `M60-2`, `A3 item 2`, `second instance`; checker `i3=1` |
| D4 | I4 | the round-60 report's quality-trend sentence denies the new record defects D1–D3 | `corpus/lessons/round-60.md` (appended quality-trend correction) | landed at `:178`; quotes `no new record defect`, names `D1`, `D2`, `D3` and states `three`; checker `i4=1` |
| D5 | I5 | the round-60 `LOG.md` wave line was rewritten in place at `818d2a82` (1 insertion, 1 deletion against `14a6c07d`) | `LOG.md` (appended `supersedes the round-60 LOG wave line`) | landed at `LOG.md:1982`; states `insertions=1 deletions=1` and the mechanism (`rewritten in place`); checker `i5=1` |
| D6 | I6 | the report's stale-lane paragraph quotes `launch 15:09:28` where the driver line reads `15:03:17` | `corpus/lessons/round-60.md` (appended stale-lane correction) | landed at `:179`; names the driver launch line and four `-03:00` stamps that map to `%ci`'s ` -0300` form by the normalisation receipted in `build/R61ExecFixRecords/rederive.md` §I6; checker `i6=1` (5 distinct stamps, 4 in the derived set) |
| D7 | I7 | the report's attack-share sentence reads `4/16 = 25 %` on a literal list with three present seats | `corpus/lessons/round-60.md` (appended attack-share correction) | landed at `:180`; states `3/16`, `4/16`, `18.75` and `25`, with 3 derived from the results file's `agent` fields; checker `i7=1` |

Checker reading at write time, on the working tree (uncommitted), by
`python3 -I -B plans/round-61-c1-check.py --root . --repo .`:

```
C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=1
rc=0
```

and the diagnostic leg (`--no-challenge`) reads `value=0 population=7 … guard=0`, rc 1.
Both readings are in `build/R61ScribeLesson/state-at-write.txt`; the committed-revision
reading is the L1's.

## Wave

`kagi-r61-w1`, 16 seats v1 (`.ufo/waves/round-61/w1-dispatch.json`: `counts spawn=16 resume=0
total=16`; reports `.ufo/waves/round-61/w1/`; results `.ufo/waves/round-61/w1-results.json`).

Measured from `w1-results.json` (`python3` over the `results` array; `seats` = 16):

- 16 result records, every `output` non-empty (min 2505 B, max 10110 B) ⇒ **dead seats 0**.
- Role mix (`agent` field): 2 scout, 6 executor, 2 scribe, 1 reviewer, 1 critic, 1
  mutation-tester, 1 sentinel, 1 connector, 1 revenger.
- Attack share: reviewer + critic + mutation-tester = 3/16 = 18.75 % on the addendum's literal
  list (no labrat seat exists); counting the sentinel = 4/16 = 25 %.
- 15 of the 16 wave reports end with an explicit `SEAT-STATUS: complete` line;
  `R61ExecControls.md` ends with its scratch/scope statement and its final message reported
  the completed battery (`CONTROLS: match=18 mismatch=0`), so it is counted as settled, not
  dead.

## Bounds

- The `## Gate` quotes are the scout's located rows in `capture/notes.md`, re-resolved by
  the scribe; the scout opened exactly the three admitted pages, and the rejected candidate
  is the scribe's own fetch.
- The `## Routed dispositions` state column is a tree read taken at write time; it is not
  the frozen checker's verdict, and a state that reads "landed" here does not by itself
  satisfy an item's condition (the checker derives each number from the measured tree or a
  named revision). The checker's `i2=1` depends on the checker's own I2 legs having been
  repaired during the wave (M61-6); on the 17:11 checker the same tree read `i2=0`.
- M61-4 records the scribe's own write-scope slip beside the controls seat's `/tmp` trace;
  the capture bytes were not modified and the three `.body` sha256s are unchanged.
- The trial's real-run receipts and the C2 counter's reading are the trial and counter
  seats' evidence; this lesson cites them as state, not as a C2 verdict.

## Findings not covered by the frozen item set

Reported, not amended (the plan is frozen; these are defects for the next round's plan and
report):

1. **I6's `-03:00` timestamps cannot literally occur in `git log --format='%ci'` output.**
   `%ci` emits `2026-11-07 16:33:44 -0300` (space separator, `-0300`); the literal substring
   `-03:00` occurs **0** times in that range (`git log --format='%ci' a677c78e..818d2a82 |
   grep -c -- '-03:00'` ⇒ 0). The item is satisfiable only if the checker compares instants
   after normalising the offset; the fix seat receipted that normalisation and the landed
   correction quotes the `-03:00` form. A checker that matches bytes literally reads I6
   unresolved.
2. **The report's `6/16 = 38 %` sibling figure is wrong and unrouted** — see M61-3: five
   attack seats, 5/16 = 31.25 %.
3. **The plan's motivating grep overstates its negative.** `grep -rlE 'unseal|shamir'
   corpus/knowledge/` matches 6 entries at BASE and 7 now (the round's own entry included);
   one BASE match, `sops-age-key-rotation.md`, does measure a Shamir threshold (SOPS's age
   key-group split), so "matches no entry that measures the Shamir seal" is true only for the
   OpenBao seal. The claim is outside §C1's seven items and does not move a number.
4. **I2's "`--selftest` in the selftest cell" conjunct was already true at BASE** (row 855's
   cell contained the token twice, inside `none of its own — it runs the trial's --selftest as
   a conjunct`); the discriminating half is the removal of `none of its own`. The landed fix
   changes both halves, so the item is not vacuous on the candidate tree, but a checker
   implementing only the token half would have read it satisfied at BASE.
5. **The scout's notes sentence "S126 documents `operator rekey` as a working command with no
   backend caveat at all" omits the deprecation the same file records at M3.1.** The page
   documents the command and marks it deprecated in favour of `rotate-keys`; the accurate
   statement is that it states no *backend* caveat. The lesson's Gate row uses the accurate
   form.

## Corrections (L1, at integration)

- **M61-8 is superseded in part.** The reviewer's C2-3 class (a stub that runs each `bao <op>
  --help` and prints the T2 markers reads `value=5`) was closed in-round after the reviewer's
  reading, not routed: `plans/round-61-c2.sh` (sha256
  `c7d9e272877775a4b74c673680723bac252d393db6631d06fceb7ffdb98c47a6`) now requires each
  real run's ops log to carry the trial's measured argv SHAPES — `server -config=`,
  `operator init -key-shares=5 -key-threshold=3`, `operator unseal` with a 40+-char base64
  share, a bare `operator seal`, `operator generate-root -init`, `operator generate-root
  -decode=`, `operator rekey -init -key-shares=3 -key-threshold=2` — so a help-only stub
  cannot satisfy `ops=1`. The real trial still reads
  `C2_SEAL_TRIAL: value=5 … ops=1 t2w=1 stubctl=1 secret=1 … cases=63` rc 0 on these bytes;
  the battery's `C2-STUB` and `C2-FIXTURE-TRUTH` controls read `value=0` and the added
  `C2-HELPSTUB` control reads `value=0` (receipt `.ufo/waves/round-61/controls/`). The
  remaining C2-4 (guard near-constant) and C2-5 (the counter's `--selftest` does not execute
  the main aggregation) findings stay open and are named as ceilings in the round report;
  they are instrument debts for the next round, not this round's claim.
- **M61-3's sibling figure is corrected in the round-61 report, not in the round-60 bytes.**
  The round-60 report's `6/16 = 38 %` is wrong twice (five attack seats ⇒ 5/16 = 31.25 %;
  `6/16` is 37.5 % even if the count were right). The round-61 report states 5/16 = 31.25 %
  and names the superseded sentence; the round-60 report bytes are not rewritten.
- **Plan §Control plan drafting defect (no amendment).** Its forgery parenthetical lists eight
  descriptions for seven ids (F1..F7); the displaced description is I7's attack-share
  forgery, which the battery does not build as a control. The reviewer's I7 attack (a swapped
  fraction/percentage pairing keeping all four tokens) is the measured witness that the item
  reads a structural condition, and it is recorded as a ceiling below.
- **I6's literal `-03:00` text is unsatisfiable against `git log --format='%ci'`** (which
  emits `-0300` with a space separator; literal count 0). The checker compares instants after
  normalising the offset, which is the only reading under which the item can hold; the
  ambiguity is named in the round-61 report rather than amended into the frozen text.
- **The plan's motivating grep overstates its negative** (finding 3 above): the accurate
  statement is that no entry measures the *OpenBao* Shamir seal, not that no entry measures a
  Shamir threshold.
- **Ceiling recorded from the reviewer's five bypasses (I3–I7).** A tree that keeps every
  token the frozen item names but negates the statement (`not withdrawn`, `no three`, `not
  rewritten in place`) or swaps a pairing (`3/16 = 25 %`) reads the item satisfied. The plan
  declares the items structural reads, not semantic proofs; the round reports the five
  bypasses as a named ceiling and adds `corpus/QUALITY.md` QM79 (a record item must test its
  token in the asserting position) for the next round's hardening. The round's own
  corrections are not negations: the seven records state the defect and the measured values.
