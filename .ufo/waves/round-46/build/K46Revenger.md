# K46Revenger — M46-1 provenance reconstruction (release-clock gate, red rounds 39→45)

Seat: K46Revenger (leaf, no subagent dispatch). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch master, BASE `f5977284a8ce5bab09252be8196ee5dc18489926`. Scratch:
`/fast/scratch/hyaku/kagi-r46/K46Revenger`. Read-only git only (`show`, `log`, `archive`,
`merge-base`); no lane mutation. Receipts in `K46Revenger/` beside this file.

All gate re-plays below are `git archive <rev> corpus plans .ufo/waves/round-36/controls | tar -x`
into the seat scratch dir, then `python3 -B corpus/release-clock.py` — the gate's **default** mode,
offline (it reads the pinned round-36 receipt `3f611eec…`; `corpus/release-clock.py:2100-2151` maps
the default to `receipt_path()` → `.ufo/waves/round-36/controls/observe-live.json`,
`corpus/release-clock.py:547-549`). No network, no lane write.

---

## 1. Verdict summary

| Question | Answer |
|---|---|
| Is the frozen claim (`python3 corpus/release-clock.py` FAILED on every committed tip `4776f71`→BASE) true? | **CONFIRMED.** Replayed at 10 tips: CLEAN at `4776f71^` (rc 0) and at round-39 BASE `06144518` (rc 0); FAILED rc 1 from `4776f71` through `f597728`, no exception. |
| Where does the red begin? | **`4776f71` (round 39 landing), 2026-11-05.** Not one commit earlier. |
| First round whose own text *would have* shown FAILED had it run the default gate on its own tip | **round 39** (its landing is the flip; every round-39 verdict it printed was measured pre-flip). |
| First committed capture of the red bytes | **round 40**, `6f1588c:.ufo/waves/round-40/landing/release-clock.txt` (ORPHAN S040/S041 + RECEIPT-MISMATCH + FAILED, rc 1). |
| First round that *named it as a defect* | **none before round 46.** Round 40 read it as an inherited red; rounds 41–45 carried it as an "inherited FAIL row outside the frozen set". |
| M46-1 `captured-by` field as frozen (`none`) | **PARTLY CONFIRMED / needs amendment.** The *finding* had captured-by none; the *bytes* were captured twice (round-40 landing receipt; ledger row `R36-03` exit-mismatch in every verify 40→45). See §7. |

---

## 2. Timeline with pointers (gate state re-measured at every tip)

| Round | Tip replayed | Date | SOURCES `on-release` vs `release-clocks.tsv` rows | Gate (default) |
|---|---|---|---|---|
| ≤38 | `4776f71^` (`943815a`… chain) | 2026-11-05 | 30 / 30 (bijection) | `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` rc 0 |
| 39 BASE | `06144518` | 2026-11-05 | 30 / 30 | `CLEAN …` rc 0 |
| **39 landing** | **`4776f71`** | **2026-11-05** | **28 / 30 → 2 ORPHAN** | **`FAILED (on_release=28 bound=28 unbound=0 observed=28 fired=13 derived=15)` rc 1** |
| 39 spot-check | `6cc8850` | 2026-11-05 | 28 / 30 | `FAILED …` rc 1 |
| 40 landing | `6f1588c` / `97e867f` | 2026-11-05 | 28 / 30 (candidate adds 2 unbound) | `FAILED (on_release=28, unbound=0)`, candidate `unbound=2` |
| 41 landing | `209147c` | 2026-11-05 | **29 / 30 → +1 UNBOUND (S098)** | `FAILED (on_release=29 bound=28 unbound=1 …)` rc 1 |
| 41 spot-check | `e8265c0` | 2026-11-05 | 29 / 30 | `FAILED …` rc 1 |
| 42 tip | `5f3566c` | 2026-11-05 | 29 / 30 | `FAILED …` rc 1 |
| 43 tip | `d54109d` | 2026-11-05 | 29 / 30 | `FAILED …` rc 1 |
| 44 tip | `0d0192f` | 2026-11-05 | 29 / 30 | `FAILED …` rc 1 |
| 45 tip / BASE | `f597728` | 2026-11-05 | 29 / 30 | `FAILED …` rc 1 |

Receipt: `K46Revenger/04-replay-tips.txt`; live lane run at BASE: `K46Revenger/05-lane-base.txt`.

The full BASE output (`K46Revenger/05-lane-base.txt`, rc 1):

```
ORPHAN S040
ORPHAN S041
RECEIPT-MISMATCH S040
RECEIPT-MISMATCH S041
UNBOUND S098
RELEASE_CLOCK: FAILED (on_release=29 bound=28 unbound=1 observed=28 fired=13 derived=15)
```

Two independent error classes, from two different rounds:

- **ORPHAN S040 / S041** — round 39 flipped the SOURCES recheck cell but left the binding rows.
- **UNBOUND S098** — round 41 added a row with `recheck: on-release` and no `release-clocks.tsv` row.
- **RECEIPT-MISMATCH S040 / S041** — the pinned receipt still carries records for the two unbound-by-SOURCES ids (`corpus/release-clock.py:699-701` fails any receipt record outside `bound_ids`); a consequence of the ORPHAN pair, not a third defect.

Mechanism in the instrument: `on_release` is computed purely from `SOURCES.md` recheck == `on-release`
(`corpus/release-clock.py:560-563`); every binding row whose source is absent *or* no longer
`on-release` yields `("ORPHAN", id)` (`corpus/release-clock.py:564-568`); `passed` requires
`not errors and bound == len(on_release)` (`corpus/release-clock.py:709-716`); the verdict line and
exit code are `corpus/release-clock.py:718-721` and `:2147`.

### 2.1 Item 1 — `4776f71` (round 39 landing): the flip that starts the red

`git show 4776f71 -- corpus/SOURCES.md` changes exactly two rows, each by one cell
(`K46Revenger/01-r39-diff.txt`):

| Row | File line at BASE | Field 10 (recheck) before | after |
|---|---|---|---|
| S040 | `corpus/SOURCES.md:47` | `on-release` | `2026-11-05` |
| S041 | `corpus/SOURCES.md:48` | `on-release` | `2026-11-05` |

`corpus/release-clocks.tsv` was **not** touched by `4776f71` (`git show --name-only 4776f71 | grep -c
release-clocks` → 0; receipt `01-r39-diff.txt` last line). Its two rows for the same ids survive
unchanged at BASE, still `verdict=fired`, `observed_version=3.15.2`:

- `corpus/release-clocks.tsv:30` — S040, anchor `3.15.1`, observed `3.15.2`, `fired`.
- `corpus/release-clocks.tsv:31` — S041, anchor `3.15.1`, observed `3.15.2`, `fired`.
- `release-clocks.tsv` last changed at `00bbe66` (round 36); no commit between `4776f71` and
  `f597728` touched it.

The commit message says "S040/S041 recheck marked". The operation is arithmetically coherent
(a fired clock closes with a dated recheck) but the gate models a fired clock as still bound to an
`on-release` source; the binding rows should have been retired in the same commit, or the recheck
left alone as round 36 left it. Neither happened: the landing retired the *source* side of a
bijection and kept the *binding* side. That is the whole of M46-1's red for rounds 39 and 40.

### 2.2 Item 2 — `00bbe66` (round 36): the row that used to observe it, and its replacement

`corpus/claim-ledger.tsv:83` — R25-04, before (`00bbe66^`) and after (`K46Revenger/02-r36-r25-04.txt`):

| | command | expected | rc | timeout |
|---|---|---|---|---|
| **before** | `python3 corpus/release-clock.py` | `^RELEASE_CLOCK: CLEAN \(on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15\)$` | 0 | 60 |
| **after** | `sha256sum .ufo/waves/round-26/observe-2.json` | `^13b8540c…169$` | 0 | 60 |

Before the migration a ledger row **ran the default gate and pinned its whole verdict line**; after
it, the ledger only pins the superseded receipt's bytes. The row's own note states the reason
honestly: the clock table moved to the round-36 observation, so the old assertion "is historical by
construction".

Round 36 did install a successor that runs the gate — `corpus/claim-ledger.tsv:100` R36-03,
`bash plans/round-36-c3.sh` (the wrapper is `exec python3 corpus/release-clock.py`,
`plans/round-36-c3.sh:9`), expecting
`^RELEASE_CLOCK: CLEAN \(on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15\)$`, rc 0.
That row is a *population-pinned* verdict: it hard-codes `on_release=30`, so **any** change to the
`on-release` population — a legitimate rearm included — turns it red. It went red at `4776f71`
(30→28) for exactly the right underlying reason and was, from that round on, indistinguishable from a
stale-constant red. That identity is the capture failure: the loudest witness was pre-classified as
noise.

### 2.3 Item 3 — `209147c` (round 41): S098, a second, independent red

`corpus/SOURCES.md:105` at BASE (added by `209147c`; receipt `K46Revenger/03-r41-s098.txt`):

```
S098 | UTS #18 … | spec | A | … | rejected | 2026-11-05 | on-release | —
```

- `recheck = on-release` on a **rejected** row, and no `corpus/release-clocks.tsv` binding row was
  added (`209147c` touches `release-clocks.tsv` not at all).
- Effect measured at `209147c` vs its own BASE: `on_release` 28→29, `unbound` 0→1, new line
  `UNBOUND S098`. The round's own lesson reports the *other* two unbound rows it created and fixed
  (S095/S096, `corpus/lessons/round-40.md:85`) and never notices S098 — round 41's only gate-facing
  text is the ledger's `FAIL R36-03 reason=exit-mismatch exit=1 want=0`
  (`.ufo/waves/round-41/verify-landing-final.txt:20`), i.e. the instrument fired and the round
  recorded the row as out-of-set.

So rounds 39 and 41 each *added* a red; 40 and 41 *observed* reds and classified them away; 42–45
observed nothing.

---

## 3. Item 4 — every release-clock verdict line, rounds 39–45, and the tree it was measured on

`LOG.md` states **no** release-clock verdict for rounds 39–45 (last occurrence at `LOG.md:1614`,
round 36 region; `grep -n clock LOG.md | awk -F: '$1>1740'` → empty). All verdicts live in plans,
lessons and wave receipts.

| # | Round | Pointer | Verdict printed | Tree measured | Post-flip? |
|---|---|---|---|---|---|
| 1 | 39 | `plans/round-39.md:22` | `CLEAN (on_release=30 … fired=15)` | real tree, BASE `06144518` | no (pre-flip) |
| 2 | 39 | `corpus/lessons/round-39.md:32` | `CLEAN (on_release=30 …)` "Measured again at BASE" | real tree, BASE `06144518` | no |
| 3 | 39 | `.ufo/waves/round-39/build/K39CriticClaims/02-counters-gates-candidate.txt` (last line) | `CLEAN (on_release=30 …)` rc 0 | real tree at candidate `6742fde` | no (candidate precedes the landing flip) |
| 4 | 39 | `.ufo/waves/round-39/build/K39ScoutFired/receipts/04-repoint.md:55` | `FAILED (on_release=30 bound=30 … observed=20 fired=5)` rc 1 | **scratch** re-point experiment (DERIVATION class, not ORPHAN) | n/a |
| 5 | 39 | `.ufo/waves/round-39/build/K39ScoutFired/receipts/08-live.md:21` | `CLEAN (… fired=15)` rc 0 | scratch extraction of the pre-flip tree | no |
| 6 | 40 | `6f1588c:.ufo/waves/round-40/landing/release-clock.txt:1-5` | `ORPHAN S040 / ORPHAN S041 / RECEIPT-MISMATCH ×2 / FAILED (on_release=28 …)` rc 1 | **real tree at landing** | **yes — first committed capture** |
| 7 | 40 | `corpus/lessons/round-40.md:85` (M40-11) | quotes `FAILED (on_release=28 bound=28 unbound=0 …)` as "BASE", attributes it to "R36-03 red since before this round" | real tree | yes, but **mis-attributed** (R36-03's red *is* the round-39 flip) |
| 8 | 40 | `.ufo/waves/round-40/build/K40ScribeLesson/overstatement-audit.md:36` (A7) | names BASE `FAILED (on_release=28 …)` vs candidate `FAILED (on_release=30 … unbound=2)`, `UNBOUND S095`, `UNBOUND S096` | real tree, BASE+candidate | yes — the scribe names the reading, not its cause |
| 9 | 40 | `.ufo/waves/round-40/build/K40ExecLedger/untouched-rows.txt:33-34` | R36-03 expected line byte-identical BASE vs candidate | committed bytes | yes (implicitly: the row driving the gate is red) |
| 10 | 41 | `.ufo/waves/round-41/verify-landing-final.txt:20` | `FAIL R36-03 reason=exit-mismatch exit=1 want=0` | real tree at landing `209147c` | yes (instrument only; gate stdout not printed) |
| 11 | 41 | `corpus/lessons/round-41-verifier-spotcheck.md:33` | repeats the FAIL set "R11-08, R22-03, R24-15, R25-02, R36-03" as context | real tree | yes, as inherited context |
| 12 | 42 | `corpus/lessons/round-42.md:117` | BASE red set "FAIL R11-08, R22-03, R24-15, R25-02, R36-03, POLICY …" | real tree | yes, as inherited context |
| 13 | 43–45 | — | **no gate run, no verdict line anywhere** (`grep -rl RELEASE_CLOCK .ufo/waves/round-4{3,4,5}` → none; wave roots hold only `build-*.json`/`final-stamp.txt`) | — | never observed |
| 14 | 45 | `.ufo/waves/round-45/build/K45ScribeEntry/lesson-draft.md:84` → landed as `corpus/lessons/round-45.md:65` (QM55) | **no verdict** — a rule: "A release-clock `CLEAN` verdict is not quoted without the instrument's open defect state" | — | n/a (the lesson the span produced) |

Tree provenance, summarised: **nobody ever printed FAILED from a scratch or fixture tree** — the
two scratch experiments (rows 4–5) are pre-flip re-point probes and both belong to round 39. Every
post-flip reading came from the real lane tree (rows 6–12), and the last three rounds printed
nothing at all. The failure mode is therefore not "measured the wrong tree"; it is *"measured the
right tree, filed the reading as background"*.

---

## 4. Why six rounds (and how many it actually was)

`plans/round-46.md:103-104` says "FAILED on every committed tip from `4776f71` (round 39) to BASE"
and the ticket says six rounds. Both are defensible but they are not the same count:

- **Round tips that are red: 7** — 39 (`4776f71`/`6cc8850`), 40 (`97e867f`), 41 (`e8265c0`),
  42 (`5f3566c`), 43 (`d54109d`), 44 (`0d0192f`), 45 (`f597728`).
- **Rounds whose own BASE was already red: 6** — 40, 41, 42, 43, 44, 45.
- **Rounds that produced any gate bytes after the flip: 2** — 40 and 41 (41 only through the ledger).
- **Rounds that re-ran the default gate on their own tree: 2** — 40 (landing, `6f1588c`) and 41
  (via R36-03 in `verify-landing-final.txt`). Rounds 42–45: zero.

`plans/round-46.md:104`'s clause "no round re-ran its default mode" is therefore **too strong**: it
is true for rounds 42–45 and false for 40 and 41. Recorded as a plan-prose defect, no predicate
change — the claim under test ("FAILED on every committed tip") is confirmed by replay regardless of
who ran it.

---

## 5. First round whose own text would have shown FAILED

**Round 39.** Its own tip `4776f71` reads FAILED rc 1 (replay, `K46Revenger/04-replay-tips.txt`), and
round 39 landed without ever re-running the gate: the landing commit carries only
`.ufo/waves/round-39/census/landing-*.txt` (no `landing/release-clock.txt`; `git ls-tree -r 4776f71
.ufo/waves/round-39 | grep -i 'landing\|release'` shows the two census files only). All three
round-39 gate statements (rows 1–3 above) were taken at `06144518`/`6742fde`, i.e. before its own
flip — a round that measured its BASE and then changed the population the measurement bounds.

The first round whose **committed** text does contain FAILED is **round 40** — but it contains it as
a red it inherited, not a red it caused, which is precisely why the next five rounds could inherit it
in turn without anyone re-deriving the origin.

---

## 6. Confidence

| Element | Basis | Confidence |
|---|---|---|
| Red starts exactly at `4776f71` | replay at `4776f71^` (CLEAN) and `4776f71` (FAILED), both rc-checked | high (executed) |
| Cause of the ORPHAN pair | diff shows only the two recheck cells; tsv untouched in that commit | high (executed) |
| S098 adds an independent unbound | replay at `209147c` vs round-40 tip; row `corpus/SOURCES.md:105`; no tsv row | high (executed) |
| R25-04 → byte pin removed the only default-replay row | `git show 00bbe66` before/after rows | high (executed) |
| Round 40 observed but mis-attributed | committed receipt bytes + lesson text | high (read) |
| Rounds 42–45 never ran the gate | absence of any RELEASE_CLOCK receipt in those wave trees | medium-high (absence evidence; grep over committed `.ufo/waves/round-4{2,3,4,5}`) |
| Round-39 flip was *intentional clock closure* rather than an accident | inferred from the commit message "S040/S041 recheck marked" and the fired verdicts | medium (`[INFERENCE]`) |

---

## 7. Captured-by verdict for M46-1

**Frozen field:** `Captured-by: none — the round-36 migration of corpus/claim-ledger.tsv R25-04
replaced the only ledger row that ran the default replay with a byte pin of the round-26 receipt.`

**Verdict: mechanism CONFIRMED, `none` OVERSTATED — amend to "partial".**

Confirmed half: the R25-04 migration (`00bbe66`, `corpus/claim-ledger.tsv:83`) is exactly the
instrument-loss event. Before it, a ledger row owned the default replay and its whole verdict string;
after it, ownership passed to R36-03 (`corpus/claim-ledger.tsv:100`), whose expectation pins a
population constant (`on_release=30`) rather than the gate's own pass predicate. When round 39 moved
the population, R36-03 went red with `exit-mismatch exit=1 want=0` — a *correct* red that the ledger
harness reports identically to a stale constant, and that every round from 40 onward listed under
"inherited FAIL rows outside the frozen set" (`plans/round-40.md:78`;
`corpus/lessons/round-41-verifier-spotcheck.md:33`; `corpus/lessons/round-42.md:117`).

Overstated half — the red *was* captured, twice, in committed bytes:

1. `6f1588c:.ufo/waves/round-40/landing/release-clock.txt:1-5` — the complete ORPHAN/RECEIPT-MISMATCH
   set and the FAILED line, rc 1, from the real landing tree. Nothing was hidden; the reading sat in
   the round's own landing directory for six rounds.
2. `.ufo/waves/round-40/build/K40ScribeLesson/overstatement-audit.md:36` (A7) — the round-40 scribe
   named the BASE reading as FAILED and corrected the claim "untouched rows" to "the gate does not
   read as it did at BASE", while accepting the frame that the row "was already FAILing at BASE".

What was **not** captured is the *attribution*, and that is the defect class: round 40's lesson
(`corpus/lessons/round-40.md:85`) wrote "The gate was already FAILED at BASE for other reasons
(R36-03 red since before this round)" — true at its BASE `6cc8850`, false as to origin, because
R36-03's red began in the immediately preceding round's landing. Once a red has a name that is one
round older than the newest commit, every subsequent round has a reason not to open it. That is the
whole M46-1 class: an instrument whose *pass* predicate was replaced by a *population constant*, so
its red carries no attribution and reads as debt.

Proposed wording for the plan's M46-1 captured-by line (no predicate change, evidence only):

> Captured-by: partial — the bytes were captured (`6f1588c:.ufo/waves/round-40/landing/release-clock.txt`,
> ORPHAN S040/S041 + RECEIPT-MISMATCH + FAILED rc 1; `K40ScribeLesson/overstatement-audit.md:36`), and
> ledger row `R36-03` failed with `exit-mismatch exit=1 want=0` in every verify from round 40 to round
> 45 (`.ufo/waves/round-41/verify-landing-final.txt:20`). No round attributed the red to the round-39
> landing, because `R36-03`'s expected line pins `on_release=30` instead of the gate's predicate, and
> the red was therefore indistinguishable from the inherited-red class. Rounds 42–45 ran no gate at all.

**Residual defect named (for the round, not fixed here):** `R36-03` is still a population-constant row
at BASE — it cannot distinguish "the population changed legitimately" from "the gate is broken", which
is why M46-1's prescribed fix (a row that runs the default gate and expects `RELEASE_CLOCK: CLEAN`)
must either replace R36-03 or be accompanied by a retirement of its `on_release=30` literal; otherwise
the round leaves two rows driving the same instrument with different truth conditions.

---

## 8. Reproduce

```
S=/fast/scratch/hyaku/kagi-r46/K46Revenger; L=/home/vgpnk/Projects/shokunin/kagi-shokunin
mkdir -p "$S"
for rev in 4776f71^ 06144518 6cc8850 97e867f 209147c e8265c0 5f3566c d54109d 0d0192f f597728; do
  d="$S/tip-$rev"; rm -rf "$d"; mkdir -p "$d"
  git -C "$L" archive "$rev" corpus plans .ufo/waves/round-36/controls | tar -x -C "$d"
  ( cd "$d" && python3 -B corpus/release-clock.py >/dev/null 2>&1; echo "$rev rc=$?" )
done
```

Last lane-side receipt line (`K46Revenger/05-lane-base.txt`):
`RELEASE_CLOCK: FAILED (on_release=29 bound=28 unbound=1 observed=28 fired=13 derived=15)` / `rc=1`.

SEAT-STATUS: complete
