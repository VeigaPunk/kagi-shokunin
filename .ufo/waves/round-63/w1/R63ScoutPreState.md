# R63ScoutPreState — scoped findings (round 63, wave 1)

Seat `R63ScoutPreState` (scout — pre-state census). Read-only: **no lane file was
edited**; every measurement ran on copies under
`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ScoutPreState/`, deleted before
this seat yielded. Full receipt (every command and its exact output):
`.ufo/waves/round-63/build/R63ScoutPreState/prestate.md`.

Claim BASE `0c07aab8df64b673a54a5113aebd7f34b622adbc`. Frozen predeclaration read:
`plans/round-63.md` (commit `12c9e4284d6de52ba61fcc656165cd24e8b74480`), plus
`corpus/lessons/round-62-verifier-spotcheck.md` §2/§6 and `corpus/lessons/round-62.md`.
Every number below is derived by a command shown beside it; nothing is quoted
from the plan.

## Verdict

| claim | metric | derived at BASE | seat's reading |
|---|---|---|---|
| C1_RESIDUAL | accepted (forgeries reading `value=0`) | **10 / 10** | the BASE checker accepts every forged tree |
| C1_RESIDUAL | rejected (benign rewrites reading `value>=1`) | **6 / 6** | the BASE checker rejects every benign rewrite |
| C1_RESIDUAL | unmodified copy | `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0` rc 1 | the seven round-61 corrections still resolve |
| C1_RESIDUAL | checker `--selftest` cases | **75** | (`C1_CHECK_SELFTEST: PASS (cases=75)` rc 0) |
| C2_REFUSAL | L1 (CM2a) | **not killed** — `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0 | mutant survives |
| C2_REFUSAL | L2 (CM2b) | **not killed** — `C1_COUNTER_SELFTEST: PASS (8/8 checks)` rc 0 | mutant survives |
| C2_REFUSAL | L3 (D12) | **not killed** — stub prints the target verdict line `C2_REFUSAL: killed=5 population=5 guard=1 (l1=1 l2=1 l3=1 l4=1 l6=1 selftest=1 real=1)` rc 0; battery carries no such control (`grep -c 'C1-F8\|C2-F6' plans/round-62-controls.sh` ⇒ **0**) | undetectable at BASE |
| C2_REFUSAL | L4 (D-6) | **not killed** — stub prints `C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1 (real=1 selftest=1 prior=1 para=1 stub=1)` rc 0; no battery control for it | undetectable at BASE |
| C2_REFUSAL | L6 (GM5) | **not killed** — `C1_CHECK_SELFTEST: PASS (cases=75)` rc 0 | mutant survives |
| C2_REFUSAL | L5 (S3) | **already fires at BASE** — `C2_HARDENED: SETUP needle-ma` rc 2 | **vacuous leg** |

**Both claims' BASE pre-state is re-derived: C1 accepted 10 / rejected 6; C2 killed 0**
over the live population. Every derivation is independent of the plan's own census.

## What was measured (method)

1. `git -C … archive 0c07aab8 | tar -x -C <scratch>/base` (read-only against the lane).
   BASE `plans/round-61-c1-check.py` sha256 `f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0`,
   **1710** lines.
2. Sixteen fixture copies (F1..F10 forgeries, P1..P6 benign) built by a
   `cp -a` of the BASE tree plus **one** byte-exact substitution, applied by a helper
   that counts the anchor and fails closed unless the count is exactly 1. Every
   anchor counted **1**; every fixture read
   `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --no-challenge`.
3. C2 legs on copies of `plans/round-62-c1.sh`, `plans/round-61-c1-check.py` and
   `plans/round-61-c2.sh`; the two stub counters were written as scratch files that
   print the target verdict line and exit 0.

## Findings for the L1

### F-1 (blocking for the C2 target wording) — L5 is vacuous at BASE; the C2 target is 5, not 6

Independently measured on a BASE tree whose `plans/round-61-c2.sh` carries neither
the `# BEGIN-DECIDE` marker block nor the BASE aggregation text:

```
$ bash plans/round-62-c2.sh --tree <S3 tree>
C2_HARDENED: SETUP needle-ma
rc=2
```

`plans/round-62-c2.sh:279` (`[ "$ma_applied" = 1 ] || setup needle-ma`) already
refuses the zero-match needle, so **L5 already fires at BASE** and cannot count
toward `killed` under kill rule K1. The live population is therefore **5**
(L1, L2, L3, L4, L6) and the target is **killed=5**, not 6. This seat's measurement
agrees with `plans/round-63.md` §Amendment A2 (commit `81bd56c`) — reported here as
independent confirmation, not as an amendment.

**Consequence:** the seat briefs, the wave milestone string and the registry still
say `C2_REFUSAL killed 0->6` and "six named surviving mutants" — a stale,
pre-amendment count carried into the dispatch. The frozen predicate is
authoritative; the briefs are stale. The L1 should reconcile the wording so the
counter's own output (`C2_REFUSAL: killed=K population=5 guard=G (l1=… l2=… l3=… l4=… l6=… …)`)
matches the brief the seats are graded against.

### F-2 — the BASE C2 counter's fallback needle does not match BASE bytes

`plans/round-62-c2.sh`'s `apply_base_mut` looks for the BASE aggregation text
`value=0\n[ "$pass" = 5 ] && [ "$shims_ok" = 5 ] && …`. That literal occurs **0**
times in the BASE `plans/round-61-c2.sh` (built in Python, `count` ⇒ 0). Only the
marker path matches at BASE (1 occurrence each of `# BEGIN-DECIDE`/`# END-DECIDE`).
So on an S3 tree both needles miss and the counter SETUPs — which is F-1's
mechanism. A candidate's S3 leg must use a needle the BASE tree actually carries,
or L5 stays vacuous on the candidate too.

### F-3 (note for the candidate author) — the BASE checker has no `--fleet` flag

The plan's §C1 predicate invokes the checker with `--fleet <fleet-root>`; the BASE
`plans/round-61-c1-check.py` rejects it —
`unrecognized arguments: --fleet /home/vgpnk/Projects/shokunin`, rc 2. The round-63
checker must accept `--fleet` and read
`/home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md` §Stale-lane (that
file carries `launch 15:09:28 -03` with an **ASCII** hyphen, exactly once, while
the lesson anchor uses U+2212 — the I6 derivation should compare the `HH:MM:SS`
set, not the offset glyph).

### F-4 — the benign fixtures fail closed on the expected items

P1/P2 unresolved `i3`, P3/P4 `i4`, P5/P6 `i5`; every forgery leaves all seven items
HOLD. The six benign rewrites are rejected by the item each rewrite perturbs — the
fixtures are non-vacuous in both directions (kill rule K2's precondition holds at
BASE for the C1 side: each forgery reads accepted on the BASE checker, each benign
reads rejected).

## Boundary notes

- Pre-state only: no candidate was built, no `plans/round-63-c1.sh` /
  `plans/round-63-c2.sh` was run (neither exists at BASE — verified), and no
  candidate verdict was evaluated.
- The C2 real-trial leg (`value=5 … shims=5 vectors=ok/5`) and the candidate guard
  legs are candidate-side readings and were **not** attempted; the C2 counter's
  `--selftest` on a candidate tree likewise.
- No tool was installed or upgraded (no pacman/uv/cargo/npm transaction), so there
  is no tool/version/channel row to report.
- Scratch hygiene: all artefacts under
  `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r63/R63ScoutPreState/`, deleted before
  this seat yielded; no citable evidence under `/tmp`; no secret value, token,
  cookie, session id or vault/item/field name in this report or the receipt.

SEAT-STATUS: complete
