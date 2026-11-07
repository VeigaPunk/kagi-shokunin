# R53MutCounters — mutation test of the frozen round-53 counters

Seat: R53MutCounters (kagi round 53, attempt 1). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
read-only. Targets: `plans/round-53-c1.sh` (C1 freshness) and `plans/round-53-c2.sh` (C2 calibration),
frozen by `plans/round-53.md`. Controls under test: `plans/round-53-controls.sh` (22 checks — 12 C1,
10 C2; pre-freeze receipt `.ufo/waves/round-53/controls/controls-prefreeze.txt`, 22 MATCH).

## Method

- Scratch: `$HYAKU_SCRATCH/kagi-r53/R53MutCounters/` (`HYAKU_SCRATCH=/fast/scratch/hyaku`).
  `git clone --shared` of the lane; clone HEAD =
  `36d0a86a7539890eb079d893c9a58e37e84d953d` (candidate), BASE objects present.
- Slim copies of that clone (`.git`, `plans/`, `.ufo/waves/round-53/controls/fixtures/ref/c1/` only,
  2.3 MB) are the per-mutant trees. The controls rebuild every fixture from BASE with
  `git archive`, so a trimmed working tree reproduces the sweep exactly — checked: the slim tree
  reads 12/12 MATCH on `c1`, same as the full clone.
- Per mutant: copy the slim tree, apply ONE line replacement
  (`R53MutCounters-mutations.py`; asserts the expected substring on the named line first, prints
  sha256 before/after), then run `bash plans/round-53-controls.sh c1|c2` **inside that copy** with
  `HYAKU_SCRATCH` explicit. A mutant is KILLED when at least one control's `got=` differs from the
  `expect=` written into the runner before the freeze; the killing control ids are listed with the
  observed values.
- No mutant touched the lane. Every mutant's `before=` sha256 equals the lane's counter sha256
  (`c1 010d3803…2400`, `c2 6be495ba…dffb`), and `git status --porcelain -- plans/` in the lane is
  empty (the counters were never written). Late in the seat, `corpus/SOURCES.md`,
  `corpus/claim-ledger.tsv` and `corpus/lessons/round-53.md` show working-tree modifications in the
  lane — sibling seats' edits, outside my write scope; my trees are clones of commit
  `36d0a86a…`, so none of the readings above depend on the lane worktree.
- The assignment floor is 8 mutants per counter. C1: 20. C2: 13 run (a `c2` sweep costs 21-24 min
  under the host load, 9 counter invocations of 60-120 s each); under the coordinator's cap only the
  13 mutants already in flight were run, and four further planned mutants are marked
  `NOT RUN (time cap)` rather than guessed.

## Baseline (pristine candidate)

| sweep | checks | result | wall |
|---|---|---|---|
| `bash plans/round-53-controls.sh c1` (full clone) | 12 | 12 MATCH, rc 0 | 96 s |
| `bash plans/round-53-controls.sh c2` (full clone) | 10 | 10 MATCH, rc 0 | 713 s |
| `bash plans/round-53-controls.sh c1` (slim clone) | 12 | 12 MATCH, rc 0 | 81 s |

## C1 mutants (20, one line each)

Counter lines are candidate `plans/round-53-c1.sh` line numbers. Each run is a full `c1` control
sweep (12 checks) in an isolated copy.

| id | line | mutation (single) | verdict | killed by (expect→got) |
|---|---|---|---|---|
| C1M01 | 148 | drop WATCHED (a) `recheck = on-release` conjunct | SURVIVED | — 12/12 MATCH |
| C1M02 | 148 | invert (a): require `recheck = 90d` | KILLED | K1-P 2→0, K1-F5 1→0, K1-F8 1→0, K1-F9 1→0 |
| C1M03 | 78 | drop `guard = 1` from the GATE conjunction | SURVIVED | — 12/12 MATCH |
| C1M04 | 69 | drop the gate line-count equality (`if true &&`) | SURVIVED | — 12/12 MATCH |
| C1M05 | 130 | drop the receipt floor `floor <= e` | KILLED | K1-F8 1→2 |
| C1M06 | 130 | drop the ASOF upper bound `e <= asof` | SURVIVED | — 12/12 MATCH |
| C1M07 | 159 | drop WATCHED (b) `anchored_version = pin` conjunct | SURVIVED | — 12/12 MATCH |
| C1M08 | 157 | drop WATCHED (b) `clock = feed` conjunct | SURVIVED | — 12/12 MATCH |
| C1M09 | 155 | drop WATCHED (b) 9-TAB-field conjunct | SURVIVED | — 12/12 MATCH |
| C1M10 | 122 | accept any receipt `http_status` (not just 200) | SURVIVED | — 12/12 MATCH |
| C1M11 | 125 | drop receipt `verdict = not-fired` conjunct | SURVIVED | — 12/12 MATCH |
| C1M12 | 78 | drop the `RELEASE_CLOCK: CLEAN` last-line conjunct | SURVIVED | — 12/12 MATCH |
| C1M13 | 113 | drop the receipt sha256 comparison | SURVIVED | — 12/12 MATCH |
| C1M14 | 153 | accept ≥ 1 clock row instead of exactly 1 | SURVIVED | — 12/12 MATCH |
| C1M15 | 175 | drop the GATE coupling on `value` (`value=$n` always) | KILLED | K1-F4 0→1, K1-F6 0→1, K1-F7 0→1 |
| C1M16 | 136 | start the watched counter at 1 | KILLED | K1-0 0→1, K1-P 2→3, K1-F5 1→2, K1-F8 1→2, K1-F9 1→2, K1-C2ONLY 0→1 |
| C1M17 | 167 | drop WATCHED (c) feed-row `status = mined` conjunct | KILLED | K1-F5 1→2 |
| C1M18 | 147 | drop WATCHED (a) registry `status = mined` conjunct | SURVIVED | — 12/12 MATCH |
| C1M19 | 168 | drop WATCHED (c) `recheck != on-release` conjunct | SURVIVED | — 12/12 MATCH |
| C1M20 | 165 | drop WATCHED (c) feed-row URL conjunct | SURVIVED | — 12/12 MATCH |

C1 kill score: 5/20 killed by the committed controls; 15 survivors.

### C1 survivors — proposed killing controls (built and validated)

Each fixture is the frozen C1 reference overlay (`.ufo/waves/round-53/controls/fixtures/ref/c1/`)
on BASE plus one edit; the pristine candidate counter and the mutant counter were both run on the
same bytes (`R53MutCounters-proposed.py`, receipt `R53MutCounters-verify.jsonl`). Expected: the
pristine reading is what the new control would freeze; the mutant must move off it.

| for | proposed control (runner line) | fixture | pristine | mutant | gate |
|---|---|---|---|---|---|
| C1M03 | K1-M03: `expect=0`, ref overlay + gate line 2 `Check and observe`→`Verify and observe` (GUARD=0, gate stays CLEAN) | comment-only gate edit | `value=0 gate=0 guard=0` | `value=2 gate=1 guard=0` | CLEAN |
| C1M06 | K1-M06: `expect=0`, ref overlay run with `C1_ASOF=1794014400` (`2026-11-07T00:00:00Z`) | none (as-of clamp) | `value=0` (`S103/S104:receipt-time-window`) | `value=2` | CLEAN |
| C1M10 | K1-M10: `expect=1`, ref overlay + receipt `S104.http_status=204` + re-digest of gate line 28 | receipt status 204 | `value=1` (`S104:receipt-status`) | `value=2` | CLEAN (gate accepts any 2xx, line 486) |
| C1M18 | K1-M18: `expect=1`, ref overlay + registry `S103` status cell `queued` | status cell | `value=1` (`S103:status`) | `value=2` | CLEAN (gate never reads the status cell) |

### C1 survivors that are equivalent under GATE = 1 (no control can kill them)

The frozen predicate only counts when GATE = 1, and GATE pins `corpus/release-clock.py` to BASE
outside the three receipt lines. For these mutants the dropped conjunct is already enforced by the
gate itself, so every fixture that would expose the difference also turns GATE to 0. Verified with
one fixture per mutant (`eq-*` in the receipt): in each case the gate exits 1 / prints FAILED and
both the pristine and the mutated counter read `value=0` — the mutant is dead on the value only
because GATE is 0.

| id | dropping… | why it cannot score under GATE=1 |
|---|---|---|
| C1M01 | WATCHED (a) `recheck = on-release` | a clock row whose registry row is not on-release is an `ORPHAN` gate error (release-clock.py:565-571); fixture gate: `ORPHAN S103`, `RECEIPT-MISMATCH S103`, rc 1 |
| C1M04 | gate line-count equality | `cmp` of the same three deleted line numbers already forces equal line counts; appended-line fixture read guard=0 for pristine **and** mutant, both `value=0` |
| C1M07 | WATCHED (b) `anchored_version = pin` | gate forces receipt parsed = table observed (490-496) and observed = anchored for not-fired (651-652); the counter forces parsed = pin ⇒ anchored = pin; fixture gate: `DERIVATION S104`, `REGRESSED S104` |
| C1M08 | WATCHED (b) `clock = feed` | gate typecasts any other clock as `INCONSISTENT` (656-670), and a rendered-quote row needs `-` feed columns, which the counter's feed-URL pin rejects anyway; fixture gate: `INCONSISTENT S104`, `RECEIPT-MISMATCH S104` |
| C1M09 | WATCHED (b) 9 TAB fields | gate treats a malformed row as `INCONSISTENT` (590-592); fixture gate: `INCONSISTENT S104`, `RECEIPT-MISMATCH S104` |
| C1M11 | receipt `verdict = not-fired` | gate requires receipt verdict = table verdict (484), and the table verdict must be version-consistent (645-655); fixture (receipt verdict `fired`) gate: `RECEIPT-MISMATCH S104`, rc 1, both counters 0 |
| C1M12 | `RELEASE_CLOCK: CLEAN` last line | `main` returns 0 iff `passed` (2146-2147) and `print_result` prints CLEAN iff `passed` (715-722); GUARD pins that code, so exit 0 ⇒ CLEAN. No fixture can hold GATE=1 with a non-CLEAN last line |
| C1M13 | receipt sha256 comparison | the gate loads the default receipt against `DEFAULT_RECEIPT_SHA256` (2136-2140) and turns a digest mismatch into `RECEIPT-MISMATCH` (673-675); the counter's check uses the same line-28 value, so it can only fire where the gate also fails; fixture (204 without re-digest) gate: `RECEIPT-MISMATCH` on every bound id (31), rc 1, both 0 |
| C1M14 | exactly one clock row (accept ≥1) | gate rejects `len(matches) != 1` (585-587); the counter's own field-count read also sees multi-row output as `clock-fields`; duplicate-row fixture: gate `INCONSISTENT S104` (`bound=30`), both 0 |
| C1M19 | WATCHED (c) `recheck != on-release` | gate raises `BADFEED` when the feed source is on-release (610) and `UNBOUND` for the on-release row's missing clock (581-583); fixture gate: `BADFEED S104`, `UNBOUND S111` (`on_release=32 … unbound=1`), rc 1, both 0 |
| C1M20 | WATCHED (c) feed-row URL | gate raises `BADFEED` when `feed_source["url"] != feed_url` (612); fixture (feed_source S033, row feed_url = age) gate: `BADFEED S104`, `DERIVATION S104`, rc 1, both 0 |

**C1 calibration finding.** The counter's independent work under GATE = 1 is narrower than its 15
independent conjuncts suggest: the gate re-validates the same receipt, row shape, feed binding and
verdict, so 11 of the 20 mutants are equivalent. What the counter adds beyond the gate is exactly
(a) the registry/feed `status` cells (C1M17 killed by K1-F5; C1M18 not covered — control above),
(b) the `2026-11-07T00:00:00Z` floor (C1M05 killed by K1-F8 — control above for the missing ceiling),
(c) the ASOF ceiling + the exact-`200` receipt status (C1M06, C1M10 above), and (d) the GUARD
byte-identity of the gate itself (C1M03 above). This is consistent with the named ceiling: a forged
receipt self-consistent with the gate scores, and only the non-author live re-fetch can catch it.

## C2 mutants (13 one-line mutants run; 4 further planned mutants NOT RUN under the coordinator time cap)

Counter lines are candidate `plans/round-53-c2.sh` line numbers. Each run is a full `c2` sweep
(10 checks) in an isolated copy; wall time 1284-1466 s per sweep (BASELINE C2M00: 10/10 MATCH,
1325 s — the slim tree reproduces the full-clone 10/10).

| id | line | mutation (single) | verdict | killed by (expect→got) |
|---|---|---|---|---|
| C2M01 | 68 | drop g1 command-cell equality (`[ -n "$bc" ] \|\| setup`) | SURVIVED | — 10/10 MATCH. On K2-F2 the mutant no longer trips g1 but the same forged fixture reads `SETUP guard:g5:PV-FEEDTOKEN-SELFTEST PV-FEEDTOKEN-SHAPES PV-STAMPS RD-STAMPS SC-SKILL-STAMPS` (g5, not g1) |
| C2M03 | 72 | drop g1 expect-cell equality | SURVIVED | — 10/10 MATCH |
| C2M04 | 75 | drop g2 (`claim-ledger.sh` byte equality) | SURVIVED | — 10/10 MATCH |
| C2M05 | 76 | drop g3 (stamp path population) | KILLED | K2-F4 SETUP→2 (`STALE:RD-DOCS-ROWLINKED STALE:RD-DOCS-ENTRIES`) |
| C2M06 | 77 | drop g4 (knowledge-entry file list) | SURVIVED | — 10/10 MATCH |
| C2M07 | 89 | weaken g5 to "policy list non-empty" | SURVIVED | — 10/10 MATCH |
| C2M08 | 86 | drop `claims = 63` | SURVIVED | — 10/10 MATCH |
| C2M09 | 87 | drop `setup = 0` | SURVIVED | — 10/10 MATCH |
| C2M10 | 81 | accept empty checker output as `value=0, exit 0` | SURVIVED | — 10/10 MATCH |
| C2M11 | 79 | read the measured `corpus/self-counts.tsv` instead of the BASE table | KILLED | K2-F3 5→SETUP (`summary:SELF_COUNTS: SETUP (empty binding table)`) |
| C2M14 | 93 | count only STALE in `value` (`value=$s`) | KILLED | K2-F5 7→0 (7 UNLOCATED dropped) |
| C2M15 | 83 | do not enforce the summary shape | KILLED | K2-0, K2-P, K2-F1, K2-F3, K2-F5, K2-C1ONLY, K12-C2 → empty (counter aborts: line 84 `BASH_REMATCH[1]: unbound variable`, exit 1) |
| C2M16 | 79 | run the measured `corpus/self-counts.py` instead of the BASE checker | NOT RUN (time cap; applier substring mismatch `$SCR/b/…`, no sweep) |
| C2M02 | 65 | accept ≥1 ledger row instead of exactly 1 | NOT RUN (time cap) |
| C2M12 | 85 | drop single-summary-line check | NOT RUN (time cap) |
| C2M13 | 92 | drop summary arithmetic (`m = s+u+a`) | NOT RUN (time cap) |

C2 kill score: 3/13 run mutants killed by the committed controls; 8 survivors.

Note on C2M01: the command forged by K2-F2 (`echo 125`) is not in the checker's
`ALLOWED_COMMANDS = {bash, grep, python3}` (self-counts.py:54), so it raises a POLICY finding for
the claim and the *policy-set* guard g5 rejects the fixture even with g1's command check removed.
The committed control therefore does not isolate the g1 command-cell equality.

### C2 survivors — proposed killing controls (not run under the cap)

All fixtures start from the C2 reference edit (`c2_ref`: the four stated counts corrected) unless
noted, so the pristine reading is the one the control would freeze.

| for | proposed control | fixture | expect | mutant would read |
|---|---|---|---|---|
| C2M01 | K2-M01 | `corpus/claim-ledger.tsv` R12-03 command → `grep -c '^R' corpus/claim-ledger.tsv` (allowlisted `grep`; live count 86 ≠ the pinned 125) | SETUP (g1) | `value≥1` (claims bound to R12-03 read 86 vs statements of 125) |
| C2M03 | K2-M03 | R12-02 expect cell `PASS \(36 cases\)` → `PASS \(99 cases\)` (the checker applies `extract` to the measured expect cell) | SETUP (g1) | `value≥1` (`expect:` claims extract 99 → UNLOCATED/STALE) |
| C2M04 | K2-M04 | append one inert comment line to `corpus/claim-ledger.sh` | SETUP (g2) | `value=0` (pinned commands' output unchanged) |
| C2M06 | K2-M06 | add `corpus/knowledge/zz-mutant.md` | SETUP (g4) | `value≥1` (knowledge entries 38 vs 37 → `RD-DOCS-ENTRIES`) |
| C2M09 | K2-M09 | remove `corpus/surface-census.tsv` (R11-11 `grep -cv` exits 2) | SETUP (summary `setup>0`) | `value≠SETUP` (whatever the other bindings read) |
| C2M10 | K2-M10 | add a FIFO `corpus/knowledge/zz-fifo.md`; the checker blocks and `timeout 900` kills it → empty output | SETUP (`empty-output`) | `value=0` (one 900 s control run) |

Two C2 survivors have **no fixture that can kill them** while the checker is the BASE bytes and the
guard passes:

- **C2M07 (g5 weakened)** — the POLICY set is produced from the ledger commands, and g1 pins every
  `ledger:`/`expect:` command cell; a fixture that passes g1 cannot change the policy set. g5 is
  redundant with g1 (C2M01's run shows g5 earning its keep only when g1 is weakened). EQUIVALENT.
- **C2M08 (`claims = 63`)** — the claim count is the BASE table's fixed population and the checker
  prints its own row count; any broken tree yields SETUP (no summary) rather than a different
  `claims=` value. The check is defensive against a checker substitution, not fixture-reachable.

**C2 fragility observed.** C2M15 shows that when the summary-shape check is weakened the counter
does not fall back to SETUP: with `set -u` and `BASH_REMATCH` empty it exits 1 with a shell
diagnostic and no output line. The controls still record a mismatch (empty `got`), but a future
counter edit should prefer an explicit `|| setup` before reading `BASH_REMATCH`.

## Cross-cutting findings

1. **C1 is heavily gate-shadowed.** 11 of 20 C1 mutants are equivalent under GATE = 1: the gate
   re-checks the same receipt fields, row shape, feed binding, verdict and row uniqueness, so a
   fixture that exposes those conjuncts also turns GATE to 0. The counter's independent bite is
   confined to (a) registry/feed `status` cells, (b) the `2026-11-07T00:00:00Z` floor, (c) the ASOF
   ceiling, (d) exact `200` vs the gate's 2xx, (e) GUARD byte-identity of the gate. This matches the
   named ceiling: only a live re-fetch can catch a receipt the gate accepts.
2. **C2's guard suite is thinner than its five conjuncts claim.** The committed controls exercise
   g1-command (via F2, masked onto g5), g3 (F4) and the measured-table isolation (F3), plus the
   value tally (F5). g2, g4, g1-expect, `claims=63`, `setup=0` and `empty-output` have no committed
   control; g5 and `claims=63` are not fixture-reachable with an intact g1/checker.
3. **Kill power is concentrated.** C1 kills come from K1-0/P/F4/F5/F6/F7/F8/C2ONLY; K1-F1/F3/F9 do
   not kill any mutant in this set (they test the reference work, not the instrument's switches).
   C2 kills come only from K2-F3/F4/F5.
4. **No committed control kills a GUARD-level C1 mutant.** C1M03 (drop `guard=1` from GATE) passes
   all 12 checks; the validated K1-M03 closes it by editing a gate comment (GUARD=0, gate still
   CLEAN), which is exactly the byte-identity property GUARD exists to enforce.

## Reproduction

Scratch root `S=/fast/scratch/hyaku/kagi-r53/R53MutCounters`, `HYAKU_SCRATCH=/fast/scratch/hyaku`:

```
git clone -q --shared /home/vgpnk/Projects/shokunin/kagi-shokunin "$S/lane"      # HEAD 36d0a86
cp -a "$S/lane/.git" "$S/slim/.git"
git -C "$S/lane" archive HEAD plans .ufo/waves/round-53/controls/fixtures | tar -x -C "$S/slim"
cp -a "$S/slim" "$S/mut/<ID>"; python3 R53MutCounters-mutations.py "$S/mut/<ID>" <ID>
HYAKU_SCRATCH=/fast/scratch/hyaku bash "$S/mut/<ID>/plans/round-53-controls.sh" c1|c2
```

- Every mutant's `before=` sha256 equals the lane's counter sha256 (`c1 010d3803…2400`,
  `c2 6be495ba…dffb`); the applier refuses if the target line does not carry the expected text.
- Lane untouched by this seat: `plans/` is clean in the lane; the three `corpus/` modifications
  present at seat end are sibling edits (see Method).
- Receipts copied to `.ufo/waves/round-53/build/R53MutCounters-receipts/` (`out/<ID>.c1.txt`,
  `out/<ID>.c2.txt`, `out/<ID>.apply.txt`, `out/<ID>.meta.txt`, the two pristine sweeps,
  `verify.jsonl`); scratch `$S` removed after the copy.
- Harness sources kept in this directory: `R53MutCounters-mutations.py` (mutant applier) and
  `R53MutCounters-proposed.py` (validated proposed controls / equivalence fixtures).

