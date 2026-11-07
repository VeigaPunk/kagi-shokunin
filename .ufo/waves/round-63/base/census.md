# Round 63 — L1 BASE census (the no-work control, measured before the freeze)

Claim BASE `0c07aab8df64b673a54a5113aebd7f34b622adbc`. Measured 2026-11-07 by the L1 on
an extracted `git archive` tree at `/fast/scratch/hyaku/kagi-r63/L1-base/base`
(`sha256sum plans/round-61-c1-check.py` ⇒
`f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0`, `wc -l` ⇒ 1710).

## C1 — the sixteen fixtures on the BASE checker

Command (one per fixture; the fixture is a byte-exact substitution of the plan §C1
anchor, asserted to occur exactly once):

```
python3 -I -B plans/round-61-c1-check.py --root <fixture-copy> \
  --repo /home/vgpnk/Projects/shokunin/kagi-shokunin --no-challenge
```

| fixture | rc | line |
|---|---|---|
| F1 | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` |
| F2 | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` |
| F3 | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` |
| F4 | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` |
| F5 | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` |
| F6 | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` |
| F7 | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` |
| F8 | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` |
| F9 | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` |
| F10 | 1 | `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0` |
| P1 | 1 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0` |
| P2 | 1 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0` |
| P3 | 1 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0` |
| P4 | 1 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0` |
| P5 | 1 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0` |
| P6 | 1 | `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0` |

Unmodified copy: `C1_ROUTED: value=0 population=7 i1=1 … i7=1 guard=0`, rc 1.

**Reading: accepted = 10 (F1..F10), rejected = 6 (P1..P6).** Both populations are
non-vacuous: every forgery is accepted and every benign rewrite is rejected at BASE.

## C2 — the legs on the BASE tree

| leg | command | observed | rc |
|---|---|---|---|
| L1 (CM2a) | `bash tree/plans/round-62-c1-cm2a.sh --selftest --tree <tree>` (stub composition → `stub=1`) | `C1_COUNTER_SELFTEST: PASS (8/8 checks)` | 0 |
| L2 (CM2b) | `bash tree/plans/round-62-c1-cm2b.sh --selftest --tree <tree>` (`SL_OK=1` appended) | `C1_COUNTER_SELFTEST: PASS (8/8 checks)` | 0 |
| L3 (D12) | `bash <stub>/plans/round-63-c2-stub.sh` (constant-verdict copy) | `C2_HARDENED: killed=3 population=3 guard=1 (ma=1 mb=1 g=1 selftest=1 real=1)` | 0 |
| L4 (D-6) | `bash <stub>/plans/round-63-c1-stub.sh` (printer-stub copy) | `C1_BYPASS: accepted=0 population=5 guard=1 (real=1 selftest=1 stub=1 paraphrase=1 chal=1)` | 0 |
| L6 (GM5) | `python3 -I -B plans/round-61-c1-check-gm5.py --selftest` (I6 superseded-stamp conjunct dropped) | `C1_CHECK_SELFTEST: PASS (cases=75)` | 0 |
| L5 (S3) | `bash plans/round-62-c2.sh --tree <needle-free tree>` | `C2_HARDENED: SETUP needle-ma` | 2 |

`grep -c 'C1-F8\|C2-F6' plans/round-62-controls.sh` ⇒ `0` (no committed control refuses
either stub).

**Reading: killed = 0 over the five non-vacuous legs (L1, L2, L3, L4, L6).** L5 is
already killed at BASE (`SETUP needle-ma`; `plans/round-62-c2.sh:279` carries the guard),
so it is vacuous and dropped by plan Amendment A2.

## Sources census at round start

`scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` ⇒
`kagi ok …/kagi-shokunin/corpus/SOURCES.md`, rc 0; 134 data rows
(`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`). Full output in
`.ufo/waves/round-63/census-start.txt`.
