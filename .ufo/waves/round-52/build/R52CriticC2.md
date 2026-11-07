# R52CriticC2 — falsification review of the frozen C2 counter (calibration axis)

Seat: R52CriticC2 (leaf; no subagent dispatch). Assignment: make `plans/round-52-c2.sh` read 0 (or
less than the true count) without a truthful correction; distinguish rewrite (GUARD-tripping) attacks
from append-only ones; name a ceiling or a new finding for each.

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b`,
predeclaration `52ebb412561d9601ad8658c30d1cfa0087af64d4`. The frozen instrument, plan, controls and
fixtures were read only and never edited. Nothing in `corpus/`, `plans/`, `.ufo/state` or any registry
row was modified; the lane working tree was measured read-only once for context.

Scratch: `/fast/scratch/hyaku/kagi-r52/R52CriticC2/` (BASE archive extracted with
`git -C lane archive BASE | tar -x -C base`; one attack per copied fixture; removed entries below).
Receipts: `.ufo/waves/round-52/build/R52CriticC2/receipts/` (`RESULTS-pristine.txt`, one `.out` per run,
`fixture-edits.diff`).

Environment: gawk 5.4.1, python 3.14.8, `~/.local/bin/bao` sha256
`9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (= `PIN_BAO`; not replaced). Every
run used `HYAKU_SCRATCH=/fast/scratch/hyaku` and `--tree <fixture>`; each probe bound its own random
127.0.0.1 port and the counter killed its own server. No token value was printed or stored.

Invocation for every row (rc as recorded):

```
HYAKU_SCRATCH=/fast/scratch/hyaku bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-52-c2.sh \
  --tree /fast/scratch/hyaku/kagi-r52/R52CriticC2/fx/<fixture>
```

## 0. Harness calibration (must pass before any attack counts)

| fixture | edit | rc | value | verbatim last line |
|---|---|---|---|---|
| a00-base | none — pristine BASE bytes | 0 | **2** | `C2_REWRAP_STATEMENTS: value=2 assertions=2 guard=1 probe=1 obs_helper=sys/wrapping/wrap obs_kv=secret/data/<path> uncorrected=[corpus/knowledge/vault-openbao-token-lease-lifecycle.md:292 corpus/lessons/round-51.md:22]` |
| a01-ref | the two frozen reference corrections appended (`fixtures/ref/corrections/{entry,lesson}.txt`) | 0 | **0** | `C2_REWRAP_STATEMENTS: value=0 assertions=2 guard=1 probe=1 obs_helper=sys/wrapping/wrap obs_kv=secret/data/<path> uncorrected=[]` |

Both K2-0 and K2-P reproduce exactly, so the counter demonstrably sees both endpoints on this host and
every 0 below is a live falsification, not a broken probe. (Context only, not a verdict: the lane
working tree measured with the pristine counter also reads `value=0 assertions=2 guard=1`.)

## 1. Attack table

`beats` = does the attack make the counter report less than the true number of uncorrected
lane-authored assertions. `append-only` = no BASE byte changes; `rewrite/identity` = BASE bytes or the
BASE path's file identity changes, i.e. GUARD's jurisdiction.

| # | attack | fixture | class | rc | counter value | beats | verdict |
|---|---|---|---|---|---|---|---|
| A0 | pristine BASE (control) | a00-base | — | 0 | 2 | n | population = 2 confirmed |
| A1 | truthful corrections, both files | a01-ref | append-only | 0 | 0 | n (intended) | intended route |
| A2 | correction line with both literals + correct pointer, prose **denies** the correction ("no correction is made here… quoted only as rejected material") | a02-deny | append-only | 0 | **0** | **y** | **declared ceiling** ("checks the two literals and the line pointer, not its prose") — zero-cost |
| A3 | correction text inside a fenced code block, labelled "example text, not an errata" | a03-fence | append-only | 0 | **0** | **y** | prose/format tolerance; consistent with A20 (assertions are counted in fences too) → **low severity**, not a semantic beat |
| A4 | correction inside a one-line HTML comment | a04-comment | append-only | 0 | 2 | n | rule holds (matches K2-F2/F8 direction) |
| A5 | correction parked in a **different file with the same basename** (`corpus/notes/round-51.md`) | a05-samebase | append-only | 0 | 2 | n | refuted: the correction must be in `F` itself (`awk … "$T/$f"`), so basename collisions gain nothing |
| A6 | new uncorrected assertion **split over two lines** (`rewrap…` / `is wrong…`) | a06b-realsplit | append-only | 0 | 2 | **y** (for the new claim) | lexical ceiling instance: the new disagreeing sentence is invisible (`assertions=2`, not 3) |
| A6′ | failed split: line 2 contained "rewrapped", so it matched | a06-split | append-only | 0 | 3 | n | documents how narrow the escape is; kept for honesty |
| A7 | new assertion with a **Unicode look-alike** (U+0430 in `rewrаp`) | a07-lookalike | append-only | 0 | 2 | **y** (for the new claim) | lexical ceiling instance |
| A7′ | same sentence in ASCII (control for A7) | a07b-ascii | append-only | 0 | 3 | n | proves A7's invisibility is caused by the look-alike |
| A8 | assertion file **renamed/moved** into an excluded name | a08-move | rewrite/identity | 2 | SETUP `guard missing:…` | n | GUARD catches it |
| A9 | one BASE assertion line **rewritten** | a09-rewrite | rewrite/identity | 2 | SETUP `guard rewritten:…` | n | GUARD catches it |
| A10 | **delete a scoped lane md that held no assertion** (`corpus/QUALITY.md`) | a10-deletefree | append-only | 0 | 2 guard=1 | n (value) | **new finding (low)**: deletions outside GUARD's set are silent — a contradicting doc can be removed without a signal |
| A11 | new ASCII assertion parked in an excluded **name** `corpus/lessons/round-52-verifier-spotcheck.md` | a11-park | append-only | 0 | 2 | **y** (for the new claim) | **new finding**: the `*-verifier-spotcheck.md` glob is an author-chosen hiding place |
| A11b | A11 **plus** the two truthful corrections | a11b-park-corr | append-only | 0 | **0** | **y** | value 0 with a visible disagreeing statement committed in `corpus/` — the number does not certify the axis sentence |
| A13 | correction naming the pointer while saying it "is **NOT** corrected; … literals quoted, not asserted" | a13-ptr-neg | append-only | 0 | **0** | **y** | declared ceiling; the sharpest zero-cost instance |
| A14 | pointer with trailing digit (`round-51.md:222`, `…:2922`) | a14-ptr-digit | append-only | 0 | 2 | n | the `rest !~ /[0-9]/` guard holds |
| A16 | new ASCII assertion parked in an `*aggregator*` name | a16-aggregator | append-only | 0 | 2 | **y** (for the new claim) | same scope hole as A11 |
| **A17** | BASE assertion files kept **verbatim**, but each BASE path becomes a **symlink** to a copy under an excluded name | a17-symlink | identity | 0 | **0 guard=1 assertions=0** | **y** | **fixable defect** (see §2) |
| A17′ | A17 committed in a fixture repo; `git archive HEAD \| tar -x` (rev-mode path) with one file linked | arch./one link | identity | 0 | **1 guard=1 assertions=1** | **y** | commit-able (`120000` tree entry) and preserved by `git archive` → rev mode is exposed identically |
| A18 | symlink indirection with the target **in scope** | a18-symlink-inscope | identity | 0 | 2 (`…round-51-copy.md:22`) | n | only excluded targets hide the line; indirection alone does not |
| A19 | one correction line naming both files, appended to one file | a19-onefile | append-only | 0 | 1 | n | per-file billing correct |
| A20 | new assertion inside a **fenced code block** | a20-fence-assert | append-only | 0 | 3 | n | fences ignored on both sides → internally consistent (demotes A3) |
| A21 | new assertion parked in the excluded **path** `considerthese/` | a21-considerthese | append-only | 0 | 2 | **y** (for the new claim) | path exclusion, same class as A11 |
| A22 | new assertion parked under `.ufo/` | a22-ufopark | append-only | 0 | 2 | **y** (for the new claim) | declared out of scope "by construction" |
| **A24** | **both** BASE assertion paths become symlinks to copies under `considerthese/` | a24-symlink-cst | identity | 0 | **0 guard=1 assertions=0** | **y** | same defect as A17 with no reliance on the name globs |
| A25 | BASE path becomes a **dangling** symlink | a25-dangling | identity | 2 | SETUP `guard missing:…` | n | `-f` follows links, so a dangling one is caught (control) |
| **A26** | symlink-hide the lesson + truthful entry correction + a **decoy** assertion/correction pair, restoring `assertions` to 2 | a26-combined | identity + append-only | 0 | **0 guard=1 assertions=2** | **y** | **worst case**: value 0 with `assertions` looking normal, `corpus/lessons/round-51.md:22` verbatim uncorrected behind the link |

No row produced a value below the number of *visible-and-scanned* uncorrected lines by arithmetic
accident; every `y` rests on a fixture whose diff is captured in
`receipts/fixture-edits.diff`.

## 2. The fixable defect: file identity is unguarded while the scan skips non-regular files

Frozen mechanics involved:

* GUARD (lines ~99–110): for each BASE file that held an assertion it tests `[ ! -f "$T/$f" ]` and
  `cmp -s -n "$bs" "$W/base/$f" "$T/$f"`. **`-f` and `cmp` both follow symlinks.**
* scan (`scoped()`, line 95): `find . -type f -name '*.md' …`. **`find -type f` does not list
  symlinks** (no `-L`), so the same path is scanned from BASE but not from the candidate.

So a candidate that makes a BASE assertion path a symlink to the identical bytes parked under an
excluded name/path satisfies GUARD byte-for-byte and vanishes from the population: A17 → 0,
A24 → 0, A26 → 0 with `assertions=2`. This is an **identity change with false provenance**: the
counter's `guard=1` asserts "the BASE bytes are intact at that path", which is true only through a
link it never sees, while `assertions` proves the path was not examined. The output can even hide the
tell (A26 keeps `assertions=2` by adding a decoy assertion the candidate itself wrote).

Not covered by any pre-freeze control: `controls-prefreeze.txt` holds K2-0/P/F1–F8 and none of them
touches file type, links, deletion outside GUARD, or the excluded-name/path population; the GUARD
comment in the counter itself speaks only of "appended bytes (no BASE line deleted or rewritten)", i.e.
of bytes, not of identity.

### Smallest safe correction (measured, not asserted)

Two candidate patches were applied to **scratch copies** of the frozen script (`LANE` pinned so the
copy still archives the real BASE; the frozen file was never touched) and re-run:

1. **Link rejection inside GUARD** (1 line, after the `continue` for files without BASE assertions):

   ```bash
   if [ -L "$T/$f" ]; then guard=0; gdetail="$gdetail symlink:$f"; continue; fi
   ```

   Measured: a00 → `value=2` (unchanged), a01 → `value=0` (unchanged), a17 → `SETUP
   reason=guard symlink:./corpus/knowledge/vault-openbao-token-lease-lifecycle.md
   symlink:./corpus/lessons/round-51.md`, a24 → same SETUP, a18 → SETUP, a02 → 0 (unchanged).
   Receipts: `receipts/a17-symlink.fix.out`, `a24-symlink-cst.fix.out`, `a00-base.fix.out`,
   `a01-ref.fix.out`, `a26-combined.fix.out` (`SETUP reason=guard symlink:./corpus/lessons/round-51.md`).

2. **Assertions floor** (`total >= BASE assertion count`, 3 lines: accumulate `BT` in the GUARD loop,
   `setup assertions-below-base` before the echo). Measured: catches a17 and a24 (`SETUP
   reason=assertions-below-base(total=0 base=2)`), leaves a00=2, a01=0, a18=2 unchanged — but **does
   not** catch A26 (`value=0 assertions=2`), because the decoy restores the count.

Conclusion: patch 1 is the necessary fix; patch 2 is a cheap backstop against the naive form of the
attack and will not catch a deliberate one. A plan-level alternative that closes A11/A16/A21 as well
is to replace the `*-verifier-spotcheck.md` / `*aggregator*` / path globs with an explicit allowlist
of the files that were already excluded at BASE, and to echo a `parked=<n>` count for excluded-name
files that match the assertion pattern — at BASE the excluded names hold three truthful lines
(`corpus/lessons/round-51-verifier-spotcheck.md:92,100,104`, quoted corrections/defect text) and
`.ufo/waves/round-51/build/R51ScoutSource.md:185` (declared out of scope), so the exclusion is
justified today but is author-chosen tomorrow.

Since the counters are frozen this round, none of this is an edit request: it is a routed finding for
the round-52 closure and a harden rule for the next round's counter. What it forbids is any closure
sentence stronger than the predicate: `value=0` certifies "the two named lines at the two named paths
carry a correction line naming them and both probe literals", not "the lane's statements agree".

## 3. Impacted axes

* **Calibration (C2, the owned axis)**: a candidate can reach the target 0 with the population
  uncorrected (A17/A24/A26) and with zero truthful correction (A2/A13, declared ceiling). The number
  is sound only for the literal predicate; the plan's sentence is broader than the instrument.
* **Harm baseline / provenance**: `guard=1` is reported as evidence of byte integrity while a path's
  identity is unexamined (A17/A24/A26) — the same class of over-read this round is correcting (D1).
  This is the reason the finding is a defect and not a tradeoff: the counter's own output asserts
  something the code does not check.
* Not impacted: C1's counter path (no shared file), the bao pin, the probe (OBS values are
  attacker-independent; every run observed the same two literals), and the frozen controls, all of
  which matched their expected values.

## 4. Honest limits of this review

* The symlink attack was measured with `--tree` on extracted/committed trees; rev mode uses the same
  code path, and A17′ additionally proves the `120000` entry survives `git archive | tar -x`, but no
  rev-mode run was made (it would need a commit in the lane, which this seat may not create).
* Attacks on the *probe* (env manipulation, `R52_BAO`, port races) were not attempted: they are
  verifier-side, not candidate-side, and the assignment is candidate falsification.
* No claim is made that a truth-free path to 0 exists for the two BASE lines without either (a) a
  correction line carrying the pointer and both literals, (b) an identity change (A17/A24/A26), or
  (c) a rewrite/rename, which GUARD catches. Within its declared scope the counter is closed; the
  holes are the declared prose ceiling, the name/path population, and file identity.
