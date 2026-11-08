# R63ScribeEntry — scoped findings (round 63, wave 1)

Seat `R63ScribeEntry` (scribe). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`
at BASE `0c07aab8df64b673a54a5113aebd7f34b622adbc` (lane HEAD at write time
`aeafc0e`, plan Amendment A3). Read-only on every file this seat does not own; no
`git add/commit/push`, no mutating `jj`, no host mutation, no tool installs.
Receipts: `.ufo/waves/round-63/build/R63ScribeEntry/` (`entry.md`, `census-base.txt`,
`census-base.json`, `falsifiers-base.txt`, `falsifiers-hardened.txt`,
`c1-counter-selftest.txt`, `controls-selftest.txt`, `c1-verdict-candidate.txt`,
`fixtures.json`). Scratch `/fast/scratch/hyaku/kagi-r63/R63ScribeEntry` deleted before
yield.

## 1. What was written

| file | change | shape |
|---|---|---|
| `corpus/knowledge/negation-scope-grammar.md` | new, 187 lines | `source:` (S135 + S137 + S130, each with URL, anchor, capture digest and a `count=1` locate), `verified-at:` (2026-11-07, BASE extraction and this seat's own 17-line census), `recheck:` (180d); §The rule (four conditions, closed lists, contrastive `but`, quotation mask), §The two-sided test (F1..F10 recall, P1..P6 precision, measured before→after), §Bounds (seven named ceilings), §Falsifiers (two sentences, both measured) |
| `corpus/QUALITY.md` | appended `## Criteria from the round-63 negation-scope work` | QM83 (asserting position over the sentence scope, closed lists, quotation masked) and QM84 (a negative vector per leg; a zero-match needle is SETUP); both cite `corpus/lessons/round-63.md`; no existing row rewritten |
| `SKILL.md` | appended `## Gate registry — round-63 additions` | three `kind: gate` rows: `plans/round-63-c1.sh`, `plans/round-63-c2.sh`, `plans/round-63-controls.sh`; each with a runnable `--selftest`, the exit map, the falsifiers/legs and the named ceilings; no `none of its own` |

## 2. Measured readings this seat produced

- **BASE census, own run** (`census-base.txt`, 17 lines): the unmodified copy
  `C1_ROUTED: value=0 … i1..i7=1 guard=0` rc 1; F1..F10 each `value=0` (accepted);
  P1..P6 each `value=1` (rejected; `i3=0` P1/P2, `i4=0` P3/P4, `i5=0` P5/P6) —
  **accepted=10 rejected=6 population=10/6**, reproducing the L1's committed census
  (`.ufo/waves/round-63/base/census.md`, `966c469`) line for line from bytes this seat
  extracted. BASE checker sha256 `f2afd9b8…`, 1710 lines.
- **Falsifiers, own run** (`falsifiers-base.txt`, `falsifiers-hardened.txt`):
  `**A3 item 2 is withdrawn in the abandoned draft alone**` is accepted at BASE and by
  the hardened checker (`value=0 i3=1`) — the closed-list floor;
  `**Without objection, A3 item 2 is withdrawn**` is accepted at BASE (`value=0`; the
  five-token window does not reach `without`, six tokens back) and rejected by the
  hardened checker (`value=1 i3=0`, digest `cc92d8a9…`) — the over-read.
- **Selftest readings**: C1 counter `C1_RESIDUAL_SELFTEST: PASS (28/28 checks)` rc 0
  (20:18 post-A3 bytes; the 20:09 pre-A3 bytes read 10/10); C2 counter
  `C2R63_SELFTEST: PASS (cases=13)` rc 0 (20:21 bytes); controls battery
  `CONTROLS_SELFTEST: PASS (cases=25)` rc 0 (20:19 bytes; the 20:04 bytes failed 3/25).
- **Checker selftest**: `C1_CHECK_SELFTEST: PASS (cases=102)` at sha256 `eb08094c…`,
  2031 lines (floor 91).
- **`grep -c 'C1-F8\|C2-F6' plans/round-62-controls.sh` ⇒ 0** (the round-62 battery has
  no stub-counter control).
- **Locates**: S135 termination-term quote `count=1`; S137 equivalent-mutant quote
  `count=1`; both capture digests re-computed (`cdbb4173…`, `21893b04…`).

## 3. Conflicts and defects reported (not amended)

1. **C2 population 6 vs 5.** The wave spec, the wave `milestone` string and this seat's
   assignment say `killed 0->6` over six legs; plan Amendment A2 (`81bd56c`) and A3 item
   5 (`aeafc0e`) set **population 5** (L5/S3 vacuous at BASE: `plans/round-62-c2.sh:279`
   already carries `setup needle-ma`, measured `C2_HARDENED: SETUP needle-ma` rc 2).
   Independently found by the Sentinel (O3), the critic (C2-1/C2-2), the connector
   (§1.8) and the records scribe (R5). A3 is authoritative; the milestone wording is
   stale.
2. **The frozen C1 command line names `--fleet`, which the BASE checker rejects** (rc 2,
   usage). The L1's BASE census and this seat's census use the BASE checker's supported
   interface. A3 item 2 makes the counter pass `--fleet` only when the checker lists it.
   (Critic C1-2.)
3. **Plan §C1 I6 text cannot reject B6** without the round-62 A1 denial clause
   (`times are correct`, …); A3 item 3 keeps the clause as part of the frozen guard.
   (Critic C1-3.)
4. **Plan §C1 I4/I5 name no line scope**; the implemented items read the LAST matching
   line (round-62 A2). A3 item 4 restates it. (Critic C1-4.)
5. **S135 duplicates S130's URL and bytes** (`cdbb4173…`, 189603 B): the scout records it
   as a new lesson on §3.1.2 and the records block appends it as a new row (census emits
   a `W04` duplicate-URL warning). The L1 decides the row's final form; this entry's
   `source:` line cites both S135 and S130 and says S130 is the same deposit.
6. **S139 admit/reject disagreement**: the scout admits the Jia & Harman PDF via its text
   layer (`S139.txt`); the records block rejects it because the captured body is a PDF
   and `rendered-text-v1 locate` prints SETUP. Not this seat's row; reported verbatim.
7. **C1 counter stub-leg crash at 20:12**: `plans/round-63-c1.sh: line 472: STUB:
   unbound variable` under `set -u`; the 20:18 bytes no longer carry that line. This
   seat's verdict run on the 20:12 bytes captured the crash; no `C1_RESIDUAL:` line.
8. **Reviewer F-3**: a counter whose `--selftest` is replaced by a constant PASS line is
   not refused by the controls battery. Named as a ceiling in the C1 registry row.
9. **Critic C1-1 lookup-table checker**: it passed the pre-A3 guard with
   `accepted=0 rejected=0 guard=1`; A3's leg (f) refuses a checker with no negator set
   (needle 0 ⇒ leg 0). The narrower ceiling — a memorizer that also carries a
   negator-dependent selftest still passes — is in the entry §Bounds.
10. **Reviewer X15 mask regression**: `**A3 item 2 is "not" withdrawn**` is rejected at
    BASE and accepted by the hardened checker (the scare-quoted negator is masked as a
    quotation). Named in the entry §Bounds with the reviewer's 17/19 open classes.
11. **Instrument bytes moved during the wave** (reviewer §6: checker `53acc21d` →
    `cc92d8a9` → `eb08094c`; counter `a78a7c47` → … → `652665ec`; battery `d489600a` →
    … → `74ed1624`). The selftest counts in the registry rows are point reads with their
    times; the L1 re-reads at integration.
12. **Scratch load**: this seat's counter runs reached ~11 GB under wave load and were
    deleted; two verdict runs were starved (the reviewer recorded the same class). The
    Sentinel's V1 (`/tmp/c1ck`, 206 MB) is another seat's.

## 4. Out of scope (not done by this seat)

No edit to `plans/*`, `corpus/SOURCES.md`, `corpus/lessons/round-63.md`,
`corpus/README.md`, `LOG.md`, `SCORECARD.md` or any instrument; no gate run as a verdict
(the counters are the verdicts); no commit, push or jj mutation; no tool install; no
`agent://all` message.

## 5. Checks a reader can re-run

```
python3 -I -B plans/round-61-c1-check.py --selftest                  # PASS (cases=102)
bash plans/round-63-c1.sh --selftest                                 # PASS (N/N checks)
bash plans/round-63-c2.sh --selftest                                 # PASS (cases=13)
bash plans/round-63-controls.sh --selftest                           # PASS (cases=25)
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-63/capture/S135.body "Certain words, or termination terms, in a sentence can signal the end of the scope of a trigger term."
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-63/capture/S137.body "A mutant is deemed equivalent if, for all possible test cases, it exhibits the same behavior as the original program under test."
```

SEAT-STATUS: complete
