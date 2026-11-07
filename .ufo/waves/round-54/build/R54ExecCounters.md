# R54ExecCounters — independent re-measurement: frozen C1 counter, kill rules, pre-freeze controls

Seat: R54ExecCounters, kagi round 54 (attempt 1). Scratch root: `/fast/scratch/hyaku/kagi-r54/R54ExecCounters` (all scratch under it; counter/controls drivers clean up via their own traps). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`. Report written early and updated as results land.

## 1. Counter re-measurement (item 1)

Command form (HYAKU_SCRATCH set to the seat scratch root; script git-archives the revision into its own `c1.$$` scratch):

```
HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r54/R54ExecCounters bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-54-c1.sh <REV>; echo rc=$?
```

| Revision | Label | Output line (verbatim) | rc |
|---|---|---|---|
| `1a0f43a9220bb0e995462c2aef745ac0124c3317` | BASE | `C1_OP_CLOCK: value=0 watched=0 measured=0 guard=1 (bad=watched:s072-recheck=180d measured:oprcpt-missing-or-symlink; gate-line=RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17))` | 0 |
| `27aa53fd40b0b385b3cf2ffeea49977f9e0ff690` | predeclaration | `C1_OP_CLOCK: value=0 watched=0 measured=0 guard=1 (bad=watched:s072-recheck=180d measured:oprcpt-missing-or-symlink; gate-line=RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17))` | 0 |
| `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14` | candidate | `C1_OP_CLOCK: value=2 watched=1 measured=1 guard=1 (bad=watched:OK measured:OK; gate-line=RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17))` | 0 |

Expected BASE 0 / predeclaration 0 / candidate 2: **MATCH** on all three. Guard holds at all three revisions (BASE `corpus/op-ref-probe.sh` unchanged and selftest PASS), so the value moves are attributable to WATCHED+MEASURED, not a guard flip. The gate-line deltas are consistent with the claim: 31 -> 32 clocks, 13 -> 14 fired at the candidate (new S112 row / S072 fired).

## 2. Kill rules (item 2)

Command:

```
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff --stat 27aa53fd40b0b385b3cf2ffeea49977f9e0ff690 ede4373afa07a33e24cbd35e9fd33fc2fddf2f14 -- plans/round-54.md plans/round-54-c1.sh plans/round-54-controls.sh .ufo/waves/round-54/controls .ufo/waves/round-54/capture/S112.body
```

Result: empty diff, `KILLRULE-DIFF-EMPTY-RC=0` (rc 0, zero output lines). Frozen plan, counter, controls driver, controls dir, and S112 capture are byte-identical predeclaration -> candidate: **PASS**.

Overlay-vs-candidate comparison (`git show ede4373afa07a33e24cbd35e9fd33fc2fddf2f14:<path>` piped to `diff -q -` against the working-tree overlay file). Candidate commit lists exactly these 8 files under `controls/fixtures/ref/c1/`; every one is byte-identical:

| Fixture path (under `.ufo/waves/round-54/controls/fixtures/ref/c1/`) | Result |
|---|---|
| `.ufo/waves/round-54/final/observe-r54.json` | IDENTICAL |
| `.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt` | IDENTICAL |
| `corpus/SOURCES.md` | IDENTICAL |
| `corpus/knowledge/op-ref-consumption.md` | IDENTICAL |
| `corpus/quote-bodies.tsv` | IDENTICAL |
| `corpus/release-clock.py` | IDENTICAL |
| `corpus/release-clocks.tsv` | IDENTICAL |
| `corpus/source-fetches.tsv` | IDENTICAL |

8/8 identical, 0 different: **PASS**.

## 3. Pre-freeze controls re-run (item 3)

Command: `HYAKU_SCRATCH=/fast/scratch/hyaku/kagi-r54/R54ExecCounters bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-54-controls.sh; echo rc=$?`

Summary line (verbatim, last output line before rc): `CONTROLS: match=16 mismatch=0` — `rc=0`, wall time 21.05 s. MISMATCH lines: none. Full per-control verdicts:

```
CONTROL K1-0 expect=0 got=0 MATCH        (BASE do-nothing)
CONTROL K1-P expect=2 got=2 MATCH        (reference overlay = planned candidate)
CONTROL K1-F1 expect=0 got=0 MATCH       (recheck flipped alone -> 0)
CONTROL K1-F2 expect=1 got=1 MATCH       (printer gate -> 1, measured only)
CONTROL K1-F3 expect=1 got=1 MATCH       (BASE gate + moved receipt lines -> 1)
CONTROL K1-F4 expect=1 got=1 MATCH       (re-anchored not-fired, digest rewritten -> 1)
CONTROL K1-F5 expect=1 got=1 MATCH       (op_version 2.41.1 -> 1)
CONTROL K1-F6 expect=1 got=1 MATCH       (one FAIL case, summary left CLEAN -> 1)
CONTROL K1-F7 expect=1 got=1 MATCH       (entry left at BASE -> 1)
CONTROL K1-F8 expect=1 got=1 MATCH       (S112 row moved to another URL -> 1)
CONTROL K1-F9 expect=1 got=1 MATCH       (observation relabelled pre-floor -> 1)
CONTROL K1-F10 expect=0 got=0 MATCH      (probe bytes changed -> guard 0, value 0)
CONTROL K1-F11 expect=1 got=1 MATCH      (gpg_validsig changed -> 1)
CONTROL K1-F12 expect=1 got=1 MATCH      (receipt removed -> 1)
CONTROL K1-F13 expect=1 got=1 MATCH      (capture bytes changed -> 1)
CONTROL K1-F14 expect=1 got=1 MATCH      (receipt body digest unlinked -> 1)
CONTROLS: match=16 mismatch=0
```

Verbatim counter lines behind each verdict are in `R54ExecCounters-receipts.txt` (same dir). 16/16 MATCH reproduces the pre-freeze receipt `controls-prefreeze.txt` (16 MATCH): **PASS**. Notably K1-F10 shows the guard kills the value (0, not 1) when the BASE probe bytes are touched, and K1-F2/K1-F3 show a lying gate still cannot reach value 2 without the receipt/measure leg.

## 4. Candidate-tree gate and selftest (item 4)

`git archive ede4373afa07a33e24cbd35e9fd33fc2fddf2f14` extracted to `$S/cand-tree` (output `ARCHIVED`), then run from that tree with `TMPDIR=$S`:

- `python3 corpus/release-clock.py` — last line: `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)`, exit code `GATE-rc=0`.
- `python3 corpus/release-clock.py --selftest` — last line: `RELEASE_CLOCK_SELFTEST: PASS (121 cases)`, exit code `SELFTEST-rc=0`.

The 121-case selftest confirms the FEED_TITLE_PREFIXES addition (116 -> 121 cases), and the live gate in the candidate tree reports all 32 clocks bound and observed with 14 fired: **PASS**. The gate line is byte-identical to the gate-line embedded in the candidate counter output (item 1), i.e. the counter's embedded gate reading matches a direct gate run on the same tree.

## 5. Verdict

| Check | Result |
|---|---|
| Counter BASE `1a0f43a9` | value=0 (expected 0) PASS |
| Counter predeclaration `27aa53fd` | value=0 (expected 0) PASS |
| Counter candidate `ede4373a` | value=2 watched=1 measured=1 (expected 2) PASS |
| Guard at all three revisions | 1 (probe bytes unchanged, selftest PASS) PASS |
| Kill rule: frozen files byte-identical predec -> cand | empty diff, rc=0 PASS |
| Kill rule: 8/8 overlay fixtures identical to candidate bytes | PASS |
| Controls re-run | `CONTROLS: match=16 mismatch=0`, rc=0 PASS |
| Candidate-tree gate | `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)`, rc=0 PASS |
| Candidate-tree selftest | `RELEASE_CLOCK_SELFTEST: PASS (121 cases)`, rc=0 PASS |

No drift, no calibration failure, no kill-rule breach. The frozen predicate (BASE 0 / predeclaration 0 / candidate 2, guard 1) is independently reproduced from committed bytes. No tools were installed or upgraded this seat (none needed). Receipts: verbatim command outputs saved in `R54ExecCounters-receipts.txt` in this directory; scratch tree at `/fast/scratch/hyaku/kagi-r54/R54ExecCounters/cand-tree` left for the parent's inspection, counter/controls scratch self-cleaned via their traps.
