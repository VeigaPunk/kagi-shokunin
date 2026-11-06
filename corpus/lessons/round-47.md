# Round 47 — the registry's self-description agrees with the lane census again (C1, calibration); the teaching of the eleven fired Vault/OpenBao clocks re-verified on the served docs (C2, freshness)

Frozen plan: `plans/round-47.md` (predeclaration `b020d978bac91284a431710148ebb7a7950eaab8`; BASE `252ef1cac9f41d84639c0d1f211d0e0911196112`). Counters `plans/round-47-c1.sh`, `plans/round-47-c2.sh`; pre-freeze controls `plans/round-47-controls.py` (17 controls, all MATCH, `.ufo/waves/round-47/controls/controls-prefreeze.txt`). Build wave: `.ufo/waves/round-47/build/` (12 seats, all settled). Candidate-side legs and final receipts: `.ufo/waves/round-47/final/`. No predicate, counter, target or kill rule changed after the freeze.

## Claims

- **C1 calibration — lane census 3 findings → 0.** At BASE `bash corpus/sources-census.sh` read FAILED: the registry said `corpus/lessons/round-43.md` uses S094 and `round-44.md` uses S099, but neither lesson named them in a `source:` field, and S099 (opened round 44) had no fetch-provenance row. Fix: one `source:` line at the head of each lesson (prepended, not appended: `round-44.md` has no trailing newline, so an EOF append would rewrite its last line and fire the frozen "no `-` line" kill rule — seat K47ExecC1), one 16-column S099 row in `corpus/source-fetches.tsv`, and the capture `.ufo/waves/round-47/capture/S099.body` (byte-identical to the fleet blob `75dd2612:.ufo/prompts/kagi-round-44.md`). The `used-by` cells were not narrowed (control K1-F1).
- **C2 freshness — 11 fired rows re-verified, 0 → 11.** S012–S016 and S021–S026 sit behind `on-release` clocks that read `fired` (Vault 2.2.1, OpenBao 2.7.2 are past the anchors). Each row's declared column-13 quote was located with `corpus/rendered-text-v1.py` in a live capture fetched 2026-11-06T19:34:14–15Z (seat K47ExecC2), and each `teaches` cell was judged against the rendered text around the quote: 11 × `teaching-holds` (`.ufo/waves/round-47/build/K47ExecC2/teaching-notes.md`). Record: new `corpus/fired-reverify.tsv`; bodies under `.ufo/waves/round-47/capture/`. The clocks themselves are not re-armed (`release-clocks.tsv` byte-unchanged).

## Gate

- **S099 — re-opened 2026-11-06** (pinned raw URL `https://raw.githubusercontent.com/VeigaPunk/shokunin/75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md`): HTTP 200, sha256 `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`, 97077 bytes, identical to the fleet git blob (L1 19:28:59Z; K47ExecC1 19:34:00Z; K47ScoutSources 19:34:21Z). Located quote (16 words): "The claim is judged on the counter, kill rule and predicate declared before data. A rule" — byte offset 52924, line 561, once. Admit (provenance row added; registry row unchanged).
- **S094 — re-opened 2026-11-06** (`https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`): HTTP 200, sha256 `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`, 11296 bytes, `cmp` against `.ufo/waves/round-39/capture/S094.body` exit 0. Quote "Only `status`, `recheck` and `used-by` change in place" at offset 6172, line 116. Admit (no row change).
- **S012–S016, S021–S026 — re-opened 2026-11-06** (URLs = column 4 of `corpus/source-fetches.tsv`; six distinct pages). Quotes are each row's column-13 quote, all ≤ 25 words, `count=1` (S024 `count=3`). Three lane fetches agree by sha256 on all 11 (L1 19:29:56Z, K47ExecC2 19:34:14Z, K47ReviewerLive 19:34:42Z). Example: S012/S022 quote "the associated bound_audiences for the "jwt" role must exactly match at least one of the aud claims declared for the JWT." on `https://developer.hashicorp.com/vault/docs/auth/jwt` (386833 bytes).
- **S040/S041 — re-opened 2026-11-06** (docs.python.org `re.html` 257722 bytes sha256 `29fca9b7…7cf1`, `html.html` 20100 bytes sha256 `38832171…e615`; served "Python 3.15.2 documentation"). Quotes "Matches Unicode whitespace characters (as defined by str.isspace() )." and "This function uses the rules defined by the HTML 5 standard for both valid and invalid character references" each `count=1`. Registry change (rule 2, in place): S040 `recheck` `2026-11-05` → `90d`; S041 `recheck` `2026-11-05` → `90d` (successors S095/S096 carry `90d`; `on-release` would make the clock gate read UNBOUND — K47ExecS040 counterfactual `RELEASE_CLOCK: FAILED (… unbound=2 …)`). Status stays `mined` (`corpus/lessons/round-26.md` cites both).
- **Rows added:** none (102 → 102). **Rows touched:** S040, S041 (`recheck`, old → new above).
- **Discernment sample (LEARNING.md):** admit — S099 provenance bound to the fleet blob (re-openable: the pinned URL and `git show 75dd2612:.ufo/prompts/kagi-round-44.md`). Reject — `on-release` as the new S040/S041 cadence (refused: their clock rows were retired in round 46, so the gate would read UNBOUND; flip: a successor clock is bound to them). Reject — K47CriticCeiling's Amendment B ("digest must equal the live-leg digest") as this round's predicate: a lane seat's receipt is not non-author evidence (LEARNING.md "A subagent the lane dispatched is still the lane") and its own forged-receipt fixture still scored 11; routed to round 48 as a counter amendment only together with Amendment A.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M47-1 | number-drift | `SCORECARD.md:1695` says the declared-claim gate's `--selftest` went "(8 → 11 cases)" and cites "cases 9–11"; `git show f4a33d3d:corpus/claims-declared.sh \| grep -n 'cases" -eq'` → line 122 `-eq 12` (`build/K47ScribeLesson/case-count-check.txt`); round-46 closure routed 1 | none — no lane gate compares a SCORECARD case count with the gate's own assertion (SD1–SD9 audited, `build/K47ScribeLesson/mistakes.md`) | appended SCORECARD erratum E47-1; proposed SD10 shown able to fail both ways (`build/K47ScribeLesson/sd10-real-tree.txt` `SD10: MISMATCH n=1`, `sd10-with-erratum.txt` `SD10: CLEAN n=0`), routed — not landed in the sweep this round |
| M47-2 | attribution | `corpus/lessons/round-46.md:12` and `:23` call seat K46ReviewerLive's re-fetch "non-author"; round-46 closure routed 2 | `LEARNING.md` §Discernment: "A subagent the lane dispatched is still the lane." | this lesson and the report name seat re-fetches "the lane's independent live leg"; the non-author leg is the closure's |
| M47-3 | instrument-trust (caught after freeze, before the candidate) | both frozen counters execute the measured tree's own `corpus/sources-census.sh`, `corpus/rendered-text-v1.py` and `corpus/release-clock.py`; a candidate that stubs one scores the target with no work (K47ReviewerPlan K47RP-01/02 forgeries FB → C1 3, FC3 → C2 11; critic D-7 M7/M8; sentinel S-01..S-03) | none — QM56 pins a producer's exit code, not its bytes; the pre-freeze controls covered a missing producer (K1-F4, K2-F7), not a lying one | candidate-side leg L1 (`final/candidate-legs.sh`): instrument bytes identical to BASE and to `controls/instrument-sha256.txt`, so the scored values ran BASE instruments; shown able to fail (`final/leg-l1-negative.txt`, a stubbed normalizer reads FAIL); QM58 |
| M47-4 | stale-premise (plan text) | `plans/round-47.md` §C2 says the eleven rows "have never had their teaching re-checked after the clock fired"; false for S012 (`corpus/lessons/round-25.md` re-verified it on 2.2.0; round 39 re-located its quote 2026-11-05) — critic D-5 | the critic seat | erratum E47-2 below; the target and predicate are unchanged |

## Errata (append-only; the superseded text is kept in the cited file)

- **E47-1 (SCORECARD round-46 operability row).** Appended to `SCORECARD.md` §Errata; the row's line 1695 is kept.
- **E47-2 (plan text, critic D-5).** Read `plans/round-47.md` §C2 "have never had their teaching re-checked after the clock fired" as "have not been re-verified since the round-36 re-observation of 2026-11-04"; S012's marginal freshness is lower than the other ten's. The plan's separability sentence "C1's counter reads none of C2's files" is a universal no counter enumerates; the evidence for it is the pair K1-P = 3 / K2-P = 11.

## Amendment notes (candidate side; no frozen sentence changed)

All legs are in `.ufo/waves/round-47/final/candidate-legs.sh`, receipt `final/measured-at-candidate.txt`:
- L1 instruments unchanged (K47RP-01/02, S-01..S-03, D-7). L2 lessons only gained lines (frozen C1 kill rule). L3 `release-clocks.tsv` unchanged (frozen C2 kill rule). L4 source cells of F, S094, S099 unchanged (K47RP-05, S-08). L5 ledger header exact (K47RP-04, S-07). L6 bodies are regular blobs first added by the candidate commit (S-04; D-3 date authority). L7 no capture blob occurs among BASE blobs (K47CriticCeiling: old committed bodies score 11 under the frozen counter, `build/K47CriticCeiling.md`). L8 three lane live legs agree by sha256.
- Named ceilings that remain on the frozen counters (routed): hand-typed in-window times over byte-correct bodies (K2-C); quote-only bodies (K47RP-03); duplicate registry rows (mutant C1-M6) and `count ≥ 0` (C2-M7, equivalent) survive (`build/K47MutCounters.md`: C1 5/14, C2 7/17 killed by the frozen controls; 13/14 and 16/17 with the seat's probes).
- Critic rulings recorded, not prettified: C1 "weakened as calibration; falsified as a measurement" and C2 "holds on the axis; falsified as a measurement" (`build/K47CriticClaims.md` verdict table) — both "measurement" rulings rest on the instrument-trust class that L1 answers for this candidate; the weakened-axis ruling for C1 stands for the operator.

## Routed (named, not claimed this round)

1. Counter amendments for round 48: execute BASE instrument bytes (or SETUP on sha drift); check the ledger header; pin registry URL cells at BASE; capture digest not among BASE blobs (Amendment A); refuse duplicate registry rows; restate C2-class targets by distinct URL/quote (critic D-3: 6 URLs / 7 quotes).
2. SD10 (SCORECARD case-count tuple vs gate assertion) into `corpus/self-description-sweep.sh` (M47-1).
3. Carried: S098 is a `rejected` row carrying `on-release` (round-46 D-7); sentinel S-05/S-06 (caller-declared `C2_ASOF`, unvalidated controls `OUT`); normalizer gap on the Vault lease page's MDX block (K47ExecC2 N1).

## Frontier

Census `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → `kagi ok`, rc 0, at round start (`controls/census-start.txt`) and at the candidate (`final/measured-at-candidate.txt`); 102 rows. The lane-local census moved FAILED (3) → CLEAN. Frontier rows advanced: none.

## Assimilation

None: K47ScoutSources read `merge/kagi/MERGE-REPORT.md` and found no staged theme on fired-clock re-verification or registry provenance (`build/K47ScoutSources.md` §2).

## considerthese

Newest file `considerthese/2026-10-26.md`; its four proposals are landed (2), operator policy (1), refused in round 32 (4) or carry a premise that no longer reproduces (3, `build/K47ScribeLesson/regex-test.txt`). None taken (`build/K47ScribeLesson/considerthese.md`).
