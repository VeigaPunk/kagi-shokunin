# K43MutCounters — round-43 counter mutation matrix (pre-measurement attack)

Counter bytes: `plans/round-43-c1.sh`, `-c2.sh`, `-c3.sh` at dd6ccb92bf04a061e9f1e66913d15f097397b1b3
(sandbox clone /fast/scratch/hyaku/kagi-r43/K43MutCounters/work; mutants are untracked copies in its
plans/, so every counter's `git show` fixture calls resolve). Fixture gates built per
`plans/round-43-controls.sh` mk_keyed (K1/K3/fakeC/refuse-all/accept-all/always0/always1 bytes
identical to the runner's). Raw outputs: receipts/c{1,2,3}-*.txt; drivers, gates and mutant scripts
alongside. Baselines: pristine new C1 = 6/0/0/5/0/0, pristine C2 = 1/0/0, pristine C3 = 0/1/0 —
each matches the committed round-43 controls receipts, so no baseline failure contaminates a verdict.

| id | counter | mutation | command (shape) | readings (per gate) | verdict |
|---|---|---|---|---|---|
| m3-new | c1 | P0-guard block (`rc=$(run_gate …); if [ "$rc" != 0 ]…fi`) deleted — runner's frozen GUARD_OLD→GUARD_NEW | `EXPECT_JOURNAL=<gate> bash plans/mut-m3-new.sh` | real 6, **K1 6**, K3 0, fakeC 5, refuse-all 0, accept-all 0 | **killed by c1-new-K1** (6 vs pristine 0); reproduces committed c1-new-m3-K1=6. Survives real/K3/fakeC/blankets by design — K1 is the single load-bearing exposure control |
| m5-new | c1 | per-token check `… && grep -qxF "EXPECT_JOURNAL: REFUSE $4" …` dropped — frozen TOK_OLD→TOK_NEW | same shape | real 6, K1 0, **K3 6**, fakeC 5, blankets 0/0 | **killed by c1-new-K3** (6 vs pristine 0); reproduces committed c1-new-m5-K3=6 |
| x1 | c1 | final `echo "$n"` → `echo 6` | same shape | real **6** (=target, survives), K1 **0** (=pristine, survives — guard exits before the echo), K3 **6** (≠0), fakeC **6** (≠5), refuse-all 0, accept-all **6** (≠0) | **killed by c1-new-K3**; also killed by c1-new-fakeC and c1-blanket-accept |
| x2 | c1 | increment line `    n=$((n + 1))` deleted outright | same shape | P0-accepting paths: no output, rc 2 (`syntax error near unexpected token 'fi'` — empty then-block); P0-refusing paths print 0 | **killed (malformed)** — crash mutant, trivially detected; superseded by x2b |
| x2b | c1 | `n + 1` → `n + 0` (increment deleted, script still runs) | same shape | real **0** (≠6), K1 0 (=0), K3 0 (=0), fakeC **0** (≠5), blankets 0/0 | **killed by c1-new-real**; also killed by c1-new-fakeC |
| y1 | c2 | N1 stale block removed; final condition drops `[ "$N1" = "1" ]` | `CONTROLS_REPLAY_GATE=<gate> bash plans/mut-y1-non1.sh` (CAND=dd6ccb9) | c2gate (my correct §C2 gate) **1** (=target), always0 0, always1 0 | **SURVIVOR** on the frozen battery (c2-base 0 / c2-blanket-0 0 / c2-blanket-1 0 all reproduce). Extra probe: accept-stale gate → pristine 0, y1 **1** — only a stale-accepting negative fixture gate kills it; none is in the frozen battery |
| y2 | c2 | N2 silent block removed; final condition drops `[ "$N2" = "1" ]` | same shape | c2gate **1** (=target), always0 0, always1 0 | **SURVIVOR** on the frozen battery. Extra probe: accept-silent gate (commit-compare, no replay) → pristine 0, y2 **1** — only a silent-accepting negative fixture gate kills it |
| y3 | c2 | final condition accepts P1 rc ∈ {0,1}: `[ "$P1" = "0" ]` → `{ [ 0 ] \|\| [ 1 ]; }` | same shape | c2gate 1, always0 0, **always1 1** (≠0) | **killed by c2-blanket-1** |
| z1 | c3 | executed selftest leg (3) deleted from check() | `C3_ROOT=<tree> bash plans/mut-z1-noleg3.sh` | lane dd6ccb9 0, pos 1, **blanket 5** (sabotaged PASS token invisible) | **killed by c3-blanket** (5 ≠ 4; plan says "never 5") |
| z2 | c3 | leg (1) grep pattern `'TMPDIR:-/tmp'` → `'/tmp'` | same shape | lane dd6ccb9 0, pos 1, **blanket 3** (≠4) | **killed by c3-blanket** — corpus/prefreeze-control.sh keeps 3 residual `/tmp` byte-sequences (`"$tmp/tmp"`, `TMPDIR=$tmp/tmp` ×2) in the all-greps-fixed tree, so the mutant under-counts the blanket control |

## Surviving defects (named)

- **y1 (C2 N1-skip) and y2 (C2 N2-skip) survive the entire frozen C2 battery**: the battery's
  negative gates are only the two blankets, and blanket-1 refuses on every invocation, which kills
  only a P1-weakening (y3). A counter mutant that drops exactly one of the two negative-shape
  checks reaches target N=1 at the candidate and reproduces every committed C2 receipt. Kill
  requires one targeted negative fixture gate per shape (accept-stale, accept-silent — both built
  and demonstrated under receipts/gates/). This is a counter-side coverage gap, distinct from the
  plan's declared gate-side special-casing ceiling; a later round can close it by adding the two
  negative fixture gates to the C2 battery. Named finding, not a contract change.
- No C1 or C3 mutant survived: every frozen receipt class that the plan credits (K1/K3 exposure,
  blanket accept, real-gate target, c3-blanket "never 5") killed its mutant exactly as frozen.
