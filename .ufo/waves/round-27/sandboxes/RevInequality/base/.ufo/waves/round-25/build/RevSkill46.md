# RevSkill46 — why SKILL.md:46 went stale (round-25 build, input to C1)

Seat: KagiR25.RevSkill46-2 (revenger, leaf, read-only). Lane BASE 4587c61a348e4528717404a68912c373f3ef4d03 = HEAD; `git status --porcelain` empty for SKILL.md, corpus/stamps.tsv, corpus/claim-ledger.tsv, corpus/claim-ledger.sh. Experiments only in sandbox /fast/scratch/kagi-r25/RevSkill46-2/lane. Tools installed: none. Axes: calibration (doc number = live value), freshness (live change to doc rebind), operability (a gate can turn red on the doc number).

## Verdict
SKILL.md:46 reads "`bash corpus/claim-ledger.sh verify` (63 stamps + 39 claims + claim ids, round 21)". Live at BASE: stamped=83, claims=61. It matched only at 4b8c018 (r13), bc1af88 (r17) and c41af82 (r21). It was stale in r14–r16, r18–r20, and from 8ada17a (r22) to HEAD. The same totals are pinned by ledger rows (R12-03, R13-02, R21-04) that go red and get fixed each round. The prose copy has no pin, so it cannot go red, and no gate reads it.

## L46 timeline (`git show <rev>:SKILL.md` plus ledger rows, parsed per commit)
| commit (round) | SKILL L46 says | ledger stamps/claims | match |
|---|---|---|---|
| 301b9ec (r11) | "(stamps + claims)" | 28/11 | n/a |
| 4b8c018 (r13) | "(stamps + claims + claim ids)"; exit example `claims=17` | 33/17 | yes |
| 2486643 (r14) | unchanged (`claims=17`) | 44/18 | NO |
| 587fda0 (r15) | unchanged (`claims=17`) | 48/23 | NO |
| 8a6ec16 (r16) | unchanged (`claims=17`) | 52/29 | NO |
| bc1af88 (r17) | "(54 stamps + 32 claims + claim ids)" | 54/32 | yes |
| fecee87 (r18) | unchanged ("54 stamps + 32 claims") | 56/35 | NO |
| c41af82 (r21) | "(63 stamps + 39 claims + claim ids, round 21)" | 63/39 | yes |
| 8ada17a (r22) | unchanged | 69/43 | NO |
| 4be5da3 (r22) | unchanged | 70/43 | NO |
| e1884c6 (r23) | unchanged | 79/45 | NO |
| a3eb6c7 (r24) | unchanged | 83/61 | NO |
| 4587c61 (r24, BASE) | unchanged | 83/61 | NO |

`git log -L46,46:SKILL.md` → c41af82, bc1af88, 4b8c018, 301b9ec. `git log -S'63 stamps' --oneline` → 4be5da3, 8ada17a, 16919f5, c41af82; only c41af82 writes the phrase into SKILL.md, the others copy it into wave or reflection files.

## Rounds that changed counts without touching L46
r14 2486643 · r15 587fda0 · r16 8a6ec16 · r18 fecee87 · r22 8ada17a and 4be5da3 · r23 e1884c6 · r24 a3eb6c7. r19–r20 changed no counts and L46 stayed stale. Same-file edits elsewhere: 7af07b4 ("stale count corrections") made one count hunk, SKILL.md:47 `--selftest` 47→59 cases; a3eb6c7 changed :47 59→70 and added registry rows; e1884c6 changed :643 OP_REF 29→36. None touched L46.

## Why (mechanism)
1. Red-driven pins versus unpinned prose. Green pins at BASE: R12-03 `grep -c '[^[:space:]]' corpus/stamps.tsv` = `^83$` (changed in 12 commits); R13-02 `grep -c '^R1'` = `^35$` (tracked the total claims 17→35 through r18, while every row was R1x); R21-04 `grep -cE '^R[0-9]+-[0-9]+'` = `^61$`. Reflection 16919f5 (2026-10-20): "The pins I found failing on 2026-10-18 were reconciled: `R12-02` 29 → 36 cases, `R13-01` 20 → 23 headings, `R12-03` 56 → 63 stamps, `R14-01` 21 → 24 entries." L46 is absent from that list because no row covers L46. [INFERENCE: red-driven updating as the general rule; the list is the observed instance.]
2. Re-stamp is byte-only. SKILL.md's stamp row was regenerated in 9 commits while L46 was stale: 2486643, 587fda0, 8a6ec16, 8ada17a, 4be5da3, e1884c6, 7af07b4, a3eb6c7, 277a0d4. Each passed, because `verify` checks bytes.
3. Recorded, never gated. corpus/lessons/round-19-recensus.md:34 (file created in 5b0d4b7, 2026-10-14): "`SKILL.md:46` "54 stamps + 32 claims" … are superseded counts". 8ada17a committed .ufo/waves/round-22/build/ReviewLedger.md (H2: "`SKILL.md` row 46's … needs the same in-place count correction") and CriticNoTrade.md §4 ("freeze them as "at round 21""). The same commit left L46 at 63/39. No corpus/lessons file for r22–r24 mentions it. Round 12 fixed 16 such rows by sweep (corpus/lessons/round-12.md:116); no count sweep is recorded after r21.
4. Row-local edits. The commit titled "stale count corrections" (7af07b4) fixed the census count on SKILL.md:47 and left the stamps/claims row alone.
5. Present-tense command cell with a round tag. "round 21" is a parenthetical in a present-tense procedure. QA6 ("A count carries its command", QUALITY.md:25) is satisfied by naming `verify`, not by reproducing the number.

## Which gate or criterion should have caught it
- `verify` is blind to prose. Sandbox experiment: L46 changed to "64 stamps + 40 claims". Single-file `stamp SKILL.md` was refused, exit 2: "'corpus/adjacency.tsv' is pinned and would be dropped (existing 83 rows, new 1; pass --prune to accept)". Whole-set `stamp` (83 paths): exit 0, "STAMPED: n=83". Then `verify`: exit 1, `CLAIM_LEDGER: FAIL (claims=61 failed=1 deferred=0 stamped=83 stale=0 missing=0 unresolved_ids=0 labeled_ids=20 host_skipped=12)`, identical to BASE. The only FAIL is R11-08 (lone-clone layout, D2). Before the re-stamp the edit appeared only as `STALE SKILL.md sha=26c1fda02b9e->a5fbc2c3c485`, plus R22-03 exit 1 and R24-15 exit 2. Those are byte signals.
- The bindings exist and are green at BASE: R12-03 → 83, R21-04 → 61, R11-09 → `SELFTEST: PASS (151 cases)` (3.2 s), R21-03 → 70, R12-02 → 36. None is bound to a prose copy.
- Criteria: QA6 applied as reproduction; QM14 (QUALITY.md:73) covers expectation rewrites, not prose; QM5 covers stamp and claim-row freshness, not prose. No criterion covers prose mirrors of live counts. C1 is that criterion.

## Same-class siblings (C1 population; the plan lists only L46)
- SKILL.md:243 "`--selftest # 97 scratch cases … — 94 until round 18`" versus R11-09 `^SELFTEST: PASS \(151 cases\)$`. Stale r18–r20 (fecee87: R11-09 at 97, L243 at 94; fixed in c41af82), then stale again from 8ada17a (108) through HEAD (151). Already named in round-19-recensus.md:34 as "`:241` "--selftest 94 cases"".
- Fresh mirrors: SKILL.md:47 "`--selftest` 70 cases" = R21-03; SKILL.md:643 "OP_REF_SELFTEST: PASS (36 cases)" = R12-02.
- BASE stale count = 3 numbers on 2 lines (L46 ×2, L243 ×1), not "stale ≥ 1".

## Notes for C1
- Scope the round-dated exemption to LOG, lessons and SCORECARD history. A rule keyed on a "round N" token would exempt L46 at every stale round.
- Any binding must survive a whole-set re-stamp; verify-only checking does not.
- Per-commit counts were parsed from git objects, not re-run through `verify`. The method reproduces BASE (61/83) and the r13 example (17). UNRUN: historical `verify` per commit; fleet-layout `verify` (no fleet checkout here).

## Evidence (commands, exit codes)
- `git log -S'63 stamps' --oneline` → 4be5da3, 8ada17a, 16919f5, c41af82 (exit 0). `git log -S'39 claims' --oneline` → 8ada17a, c41af82 (exit 0).
- `git log -L46,46:SKILL.md` → 4 commits (exit 0). `git log -G'^SKILL\.md\t' -- corpus/stamps.tsv` → 14 commits (exit 0).
- Sandbox BASE: `env -i PATH=/usr/bin:/bin HOME=…/home bash corpus/claim-ledger.sh --selftest` → `SELFTEST: PASS (151 cases)`, exit 0. `… verify` → `CLAIM_LEDGER: FAIL (claims=61 failed=1 … stamped=83 stale=0 …)`, exit 1, 81.9 s.
- `GIT_OPTIONAL_LOCKS=0 git status --porcelain -- SKILL.md corpus/stamps.tsv corpus/claim-ledger.tsv corpus/claim-ledger.sh` → empty, exit 0.
