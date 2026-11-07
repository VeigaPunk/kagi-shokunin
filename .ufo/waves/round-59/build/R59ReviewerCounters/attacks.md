# R59ReviewerCounters — attack record (kagi round 59, attempt 1)

Seat: reviewer (counters), leaf. Read-only on the lane; every run below measures a
scratch copy under `/fast/scratch/hyaku/kagi-r59/R59ReviewerCounters/` (deleted before
yield; the builder scripts are kept as receipts next to this file). No lane file was
written by any attack; the only lane writes are this file, `R59ReviewerCounters.md`,
and the four receipt scripts.

Claim BASE `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`. Frozen plan `plans/round-59.md`
(commit `af7b6651`). Nothing below amends a predicate, item, target, POP or kill rule.

## Instruments measured (sha256; re-hash before trusting any line)

| file | sha256 | note |
|---|---|---|
| `plans/round-59-c1-check.py` | `6844c1d46545ca0f1bd9819128830717249480dadf0a7038bcc37ffba10a7743` | at 14:12Z-03; an earlier revision `e6c079f6…` (14:05) was also measured — the I5 last-occurrence fix landed between them (see A23) |
| `plans/round-59-c1.sh` | `73a2fc68693a37ec62fcff80b2d46c33e76c86570d10f0c92cc8a1c21e56f2e3` | |
| `plans/round-59-c2.sh` | `454a4177dcb6ae2dedd367b9409358b45a25fbac0692b5c3c05510d1ac6c525c` | |
| `corpus/openbao-transit-trial.sh` | `e11e98f6cfc924131a52713fa496481e80efb89ffcdb9b6bc47b3234d8cc3e01` | |
| `plans/round-59-controls.sh` | `0d8647a0b6cce42a287e6f3faf074a0524b8b1c10273045a401790d9abb7fa96` | at 14:16 (run E); the 14:07 revision `5f6c576f…` (runs B, D) was also measured |

Fixture builders and run transcripts (receipts in this directory): `mkbref.py`
`8e970092…` builds `trees/bref` — verbatim the battery's own `fixed_tree()` text — plus
the `g*` forgeries; `mkw.py` `f993b927…` builds `w1_cont..w5_cont` and `sym`; `mkc2.sh`
`3491339d…` is the builder before the token/nonce redaction; the shipped receipt is
`db09cb76…`; `stub-trial.sh` `b0a9b49a…` builds the C2 stubs. `trees/base` is
`git archive 5fa6e658… | tar -x`; all other trees are `cp -al` of it with one atomic
rewrite (no shared inode is truncated in place). The only lane writes by this seat are
this file, `R59ReviewerCounters.md`, and these receipts.

Common environment for every C1 line below:

```bash
S=/fast/scratch/hyaku/kagi-r59/R59ReviewerCounters
L=/home/vgpnk/Projects/shokunin/kagi-shokunin
export HYAKU_SCRATCH=$S/hs; mkdir -p $S/hs/chal
C1_CHALLENGE_PARENT=$S/hs/chal python3 -I -B $L/plans/round-59-c1-check.py \
  --root "$S/trees/<tree>" --repo "$L"
```

Common environment for every C2 line below:

```bash
env HYAKU_SCRATCH=$S/hs bash $L/plans/round-59-c2.sh --tree "$S/trees/<tree>"
```

Environment for the battery runs: `env HYAKU_SCRATCH=$S/hsd bash
$S/lane/plans/round-59-controls.sh <REF>` where `$S/lane` is a scratch clone of the lane
at `5fa6e655` carrying the battery bytes being measured (run E: `$S/snap3`, battery
`0d8647a0`; runs B/D: `$S/snap2`/`$S/ref`, battery `5f6c576f`), with
`$S/hsd/kagi-r59/R59ExecCounterC1` pre-created.

## Readings that anchor the scale

| reading | command | output |
|---|---|---|
| BASE census (diagnostic) | `python3 -I -B $L/plans/round-59-c1-check.py --root $S/trees/base --repo $L --no-challenge` | `C1_ROUTED: value=5 population=5 i1=0 i2=0 i3=0 i4=0 i5=0 guard=0` |
| BASE census (guard leg) | same without `--no-challenge` | `C1_ROUTED: value=FAIL population=5 i1=0 i2=0 i3=0 i4=0 i5=0 guard=0`, rc 1 |
| positive reference (the battery's `fixed_tree` text) | `--root $S/trees/bref` | `C1_ROUTED: value=0 population=5 i1=1 i2=1 i3=1 i4=1 i5=1 guard=1`, rc 0 |
| wrapper, BASE | `env HYAKU_SCRATCH=$S/hs bash $L/plans/round-59-c1.sh` | `c1-driver: verdict value=FAIL guard=0`, rc 1 |
| wrapper, fixed tree | `env HYAKU_SCRATCH=$S/hs bash $L/plans/round-59-c1.sh --tree $S/trees/bref` | `c1-driver: verdict value=0 guard=1 (resolved and re-checkable)`, rc 0 |
| C2 reference (the shipped trial) | `env HYAKU_SCRATCH=$S/hs bash $L/plans/round-59-c2.sh --tree $L` | `C2_TRANSIT_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 cleanroom=1 secret=1)`, rc 0 |
| C2 BASE | `--tree` a tree without the trial | `C2_TRANSIT_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 guard=0 (absent)` |

## C1 attacks — one row per attack

| id | what it attacks | reproducer (tree built by the receipt script named) | observed counter output | verdict |
|---|---|---|---|---|
| A01 | I1 last-occurrence: append a bullet whose first physical line states `Registry 117 → 120 at the candidate` and whose continuation says `the operative registry statement is 119 → 120` | `mkw.py` → `--root $S/trees/w1_cont` | `C1_ROUTED: value=0 population=5 i1=1 i2=1 i3=1 i4=1 i5=1 guard=1`, rc 0 | **SURVIVED** — the wrapped continuation restates the defect invisibly; fix: join indented continuation lines into their parent bullet before the last-occurrence read (the 14:12 fix state was wrapped and read red — D03 history) |
| A02 | I2: first line `` `corpus/source-fetches.tsv` added 6 rows``, continuation `4 rows is the operative figure` | `mkw.py` → `w2_cont` | `value=0 … i2=1 … guard=1`, rc 0 | **SURVIVED** (same fix) |
| A03 | I3(a): first line states `20 control lines, 9 C1 and 7 C2`, continuation `the census is 21 control lines` | `mkw.py` → `w3_cont` | `value=0 … i3=1 … guard=1`, rc 0 | **SURVIVED** (same fix) |
| A04 | I4: first line `…citation-gate-r59.txt reads unresolved=0`, continuation `the committed gate actually reads unresolved=3` | `mkw.py` → `w4_cont` | `value=0 … i4=1 … guard=1`, rc 0 | **SURVIVED** (same fix) |
| A05 | I5: first line `stale-lane: … 101 min … progressing`, continuation `the duration is 96 min and the row is silent` | `mkw.py` → `w5_cont` | `value=0 … i5=1 … guard=1`, rc 0 | **SURVIVED** (same fix) |
| A06 | I3 role-blind read: append `controls-prefreeze.txt: 9 total, 20 C1 and 7 C2` (roles swapped; the line is self-contradictory) | `mkbref.py` → `g3_roles` | `value=0 … i3=1 … guard=1`, rc 0 | **SURVIVED** — `item3` uses `all(n in ints)`; fix: parse labelled roles (`total`, `C1-F`, `C2-F`) and compare each to its own derived count |
| A07 | I1 notation: append `registry 119 → 120 at the candidate.` (lower-case subject) | `mkbref.py` → `g1_lower` | `value=0 … i1=1 … guard=1`, rc 0 | **SURVIVED** — `REGISTRY_LINE_RE` is case-sensitive; fix: `re.I` |
| A08 | I1 notation: append `Registry 119 -> 120 at the candidate.` (ASCII arrow) | `mkbref.py` → `g1_ascii` | `value=0 … i1=1 … guard=1`, rc 0 | **SURVIVED** — fix: accept `->` as well as `→` |
| A09 | I1 notation: append `Registry 119 → 120 at candidate.` (`the` dropped) | `mkbref.py` → `g1_nothe` | `value=0 … i1=1 … guard=1`, rc 0 | **SURVIVED** — fix: make `the` optional |
| A10 | I2 notation: append `` `source-fetches.tsv`: 4 rows added`` (basename only) | `mkbref.py` → `g2_bare` | `value=0 … i2=1 … guard=1`, rc 0 | **SURVIVED** — fix: select on the basename `source-fetches.tsv` |
| A11 | I2 notation: `- source-fetches.tsv gained rows (the corpus/ prefix omitted), 4 added` | `mkbref.py` → `g2_nofile` | `value=0 … i2=1 … guard=1`, rc 0 | **SURVIVED** (same fix) |
| A12 | challenge copy escapes the tree through a symlink: `corpus/lessons/round-58.md` is a symlink to a canary outside the measured root | `mkw.py` → `--root $S/trees/sym` (canary `$S/canary.md` reset first) | counter `value=0 … guard=1`, rc 0; **canary line changed** `Registry 117 → 120` → `Registry 117 → 121` (grep count 1 after) | **SURVIVED** (integrity) — `shutil.copytree(..., symlinks=True)` preserves the link and `_wr_mut` follows it; fix: `symlinks=False` for the challenge copy, or refuse a symlinked lesson / verify each written realpath is under the copy (M58-3/QM74 class) |
| A13 | copy that resolves inside the measured root (`C1_CHALLENGE_PARENT=<root>/sub`) | `--root $S/trees/bref`, `C1_CHALLENGE_PARENT=$S/trees/bref/sub` | `C1_ROUTED: SETUP challenge scratch … resolves at/inside the measured root … (refused, QM74)`, rc 2 | **KILLED** |
| A14 | copy inside the root via the default parent (`HYAKU_SCRATCH=<root>`) | `env HYAKU_SCRATCH=$S/trees/bref … --root $S/trees/bref` | same SETUP line, rc 2 | **KILLED** |
| A15 | challenge scratch parent absent (default fixed path not created) | `env HYAKU_SCRATCH=$S/hsx … --root $S/trees/bref` after `rm -rf $S/hsx; mkdir -p $S/hsx` | `C1_ROUTED: value=FAIL population=5 i1=1 i2=1 i3=1 i4=1 i5=1 guard=0`, rc 1 | **KILLED** (fails closed) — but see D01: this is how the battery's K1-REF reads red on a good tree |
| A16 | vacuous item / item already holds at BASE | `--root $S/trees/base` (diagnostic and full) | `value=5 … i1..i5=0` / `value=FAIL … guard=0` | **KILLED** — no item is vacuous; pop is fixed at 5 |
| A17 | population shrink: measured lesson removed | `mkfix.py` → `s1_nolesson`; full mode | full: `C1_ROUTED: value=FAIL population=5 i1=0 i2=0 i3=0 i4=0 i5=0 guard=0`; diagnostic: `value=5 population=5` | **KILLED** — no SKIP path exists, pop cannot shrink, and the missing lesson is five unresolved items |
| A18 | I1 well-formed wrong last line (`117 → 121`; table-row form `118 → 120`) | `mkbref.py` → `g1_wrong`, `g1_table` | full mode `C1_ROUTED: value=FAIL population=5 i1=0 i2=1 i3=1 i4=1 i5=1 guard=0`, rc 1 (diagnostic: `value=1`) | **KILLED** — the broken item is I1 itself, so the +1 challenge cannot fire and the counter prints FAIL rather than a count; it never reads 0 |
| A19 | I2 wrong last delta (`added 4 rows`) | `mkbref.py` → `g2_wrong` | `value=1 … i2=0 … guard=1` | **KILLED** |
| A20 | I3 wrong last total (`21 control lines, 9 C1 and 7 C2`) | `mkbref.py` → `g3_wrong` | `value=1 … i3=0 … guard=1` | **KILLED** |
| A21 | I4 missing / malformed / mismatched receipt; supplement missing or naming neither id; receipt ending `mismatch=1` | `mkbref.py` → `g4_missing`, `g4_badform`, `g4_wrong_u`, `g4_mismatch_receipt`, `g3c_supnoids`, `g3d_supbad` | `value=1` with `i4=0` (or `i3=0`), `guard=1` on each | **KILLED** — a missing file is UNRESOLVED, never resolved |
| A22 | I5 later wrong / later silent / later number-free `stale-lane:` line | `mkbref.py` → `g5_wrongmin`, `g5_silent`, `g5_dup` | `value=1 … i5=0 … guard=1` on checker `6844c1d4` | **KILLED** — this survived on `e6c079f6` (`value=0`); the executors' last-occurrence fix closed it and the battery's C1-F5 caught it (C03) |
| A23 | the guard's printer-stub leg | `--root $L --repo $L --verbose` (live candidate, count=1) | `c1-guard: copy delta arrow 120->121: value=2 expect=2; stub value=0 fails=True` | **CEILING** — `stub value != value+1` is a tautology for any constant stub (the frozen predicate itself asks for it); the +1 challenge is the only leg that bites |

## C2 attacks — one row per attack

Stub trees replace `corpus/openbao-transit-trial.sh` only; the counter resolves its pin
from `plans/round-57-c2.sh` and starts no server of its own.

| id | what it attacks | reproducer | observed counter output | verdict |
|---|---|---|---|---|
| B01 | a trial that measures nothing: shape-keys the five shim vectors on `KAGI_TRANSIT_SHIM`, gates the no-bao leg with `command -v bao` then executes the **absolute** binary, prints `TRIAL CLEANROOM HOLDS` without starting any second server, prints the summary | `mkc2.sh` → `c2_stub` | `C2_TRANSIT_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 guard=1 (real=1 none=1 cleanroom=1 secret=1)`, rc 0 | **CEILING** — named K2 (shape-keyed output + absolute path) and K4 (clean-room read from printed output); no counter that parses the trial's lines can distinguish it. K2's wording should name the `command -v`-then-absolute-path bypass explicitly |
| B02 | absolute-path binary with no PATH gate | `mkc2.sh` → `a5_absnogate` | `value=0 … none=0 …` | **KILLED** — the no-bao leg sees a trial that ran and demands SETUP; a bare absolute-path trial is refused |
| B03 | clean-room line removed | `mkc2.sh` → `a4_noclean` | `value=0 … cleanroom=0 …` | **KILLED** |
| B04 | clean-room line printed twice | `mkc2.sh` → `c2_dupcr` | `value=0 … cleanroom=0 …` | **KILLED** (DUP verdict) |
| B05 | one shim flips two tests (SH3 flips T3 and T4) | `mkc2.sh` → `a2_twoflips` | `value=0 … shims=4 vectors=4/5 …` | **KILLED** |
| B06 | duplicate `TRIAL T1` line | `mkc2.sh` → `a3_dup` | `value=0 … pass=0 shims=0 vectors=0/5` | **KILLED** |
| B07 | an OpenBao token-shaped string in the transcript (the prefix the counter pins, then a sentinel body) | `mkc2.sh` → `a6_token` | `value=0 … secret=0 …` | **KILLED** |
| B08 | `r59-` + 24-hex nonce in the transcript | `mkc2.sh` → `a7_nonce` | `value=0 … secret=0 …` | **KILLED** |
| B09 | summary line with a contradictory suffix: `… holds=5 broken=0 error=0 error=1 …` | `mkc2.sh` → `c2_sumjunk` | `C2_TRANSIT_TRIAL: value=5 …` | **SURVIVED** — `grep -q '^OPENBAO_TRANSIT_TRIAL: HOLDS holds=5 broken=0 error=0'` is unanchored at the end; fix: require exactly one summary line and an exact/field-parsed `holds=5 broken=0 error=0` |
| B10 | two summary lines (`HOLDS holds=5 …` and `BROKEN holds=0 broken=5 …`) | `mkc2.sh` → `c2_sumdup` | `C2_TRANSIT_TRIAL: value=5 …` | **SURVIVED** — `grep -q` finds the HOLDS line; fix: exact-count the summary (the T-line DUP rule already exists and should apply here) |
| B11 | trial absent | `--tree $S/trees/c2_base` | `value=0 … (absent)` | **KILLED** |
| B12 | single real measurement replayed for the second real leg | subsumed by B01 (a trial that measures nothing at all scores 5) | see B01 | **CEILING** — the counter runs the trial twice with distinct `--work`/`HOME`/`TMPDIR`, but a trial may cache outside them; "two independent runs" is not observable from output shape. Not named in K2/K4 — the plan should extend K2's wording |

## Battery (`plans/round-59-controls.sh`) — attacks on the control set

The battery was revised twice while this seat measured it. Five runs: run A (killed
early: reference tree read red because the default challenge parent was absent — C07);
run B on pins `e6c079f6` + battery `5f6c576f` → `CONTROLS: match=17 mismatch=3`;
run C (REF `$S/ref`, pins `6844c1d4`, battery `5f6c576f`) → aborted at line 165 by a
concurrent edit, but its C1 section is the provenance evidence (C05); run D (REF
`$S/snap2`, same pins) → C1 all MATCH except C1-F7, aborted at C2-F4 by another concurrent
edit; run E on pins `6844c1d4` + battery `0d8647a0` (the 14:16 revision that rewrote
C1-F7 and C2-F2). Run E's final line: `CONTROLS: match=20 mismatch=1`, rc 1 — the sole
mismatch is C1-F7. Raw outputs: `battery-b.txt`, `battery-c.txt`, `battery-d.txt`,
`battery-e.txt` (receipts in this directory).

| id | what it attacks | reproducer | observed | verdict |
|---|---|---|---|---|
| C01 | C1-F7 "the guard fails closed when its challenge scratch cannot be created" — the revised control invokes the copied checker with `bash` | battery run E (`5f6c`→`0d86`): `C1_CHALLENGE_PARENT=/proc/self/no-such-dir HYAKU_SCRATCH=/proc/self/no-such-dir bash "$SCR/k1fixed/plans/round-59-c1-check.py" … \| pick1v`; verbatim replay: `bash "$S/snap3/plans/round-59-c1-check.py" …` | `CONTROL C1-F7 expect=FAIL got= MISMATCH`; run E final `CONTROLS: match=20 mismatch=1`, rc 1; replay prints `/…-c1-check.py: line 41: Registry: command not found` (the checker is Python) and no `C1_ROUTED:` line; with `python3 -I -B` the same tree reads `C1_ROUTED: value=FAIL … guard=0` | **SURVIVED** (battery bug) — one-token fix (`bash` → `python3 -I -B`); until then the battery cannot read `mismatch=0` and the plan's pre-freeze gate fails. The 14:07 revision's C1-F7 (planted stub as the instrument, expect FAIL) was unreachable the same way: `got=0` |
| C02 | C1-F7b "the printer stub itself prints 0" — runs the planted stub as the instrument and expects the stub's own line | battery run E | `CONTROL C1-F7b expect=0 got=0 MATCH` | **SURVIVED** (vacuous control) — always true by construction; it proves nothing about the guard and should be dropped or replaced by the supplement's leg-B delta |
| C03 | C2-F2 "a PATH with no bao reads SETUP" | battery run E (fixed `sed`); run B (broken `sed`) | run B: `expect=SETUP got= MISMATCH`; run E: `expect=SETUP/rc2 got=SETUP/rc2 MATCH` | **KILLED** in the 14:16 revision (the `sed` now matches `^OPENBAO_TRANSIT_TRIAL: SETUP`); the 14:07 revision could not pass |
| C04 | C1-F5 "I5 minutes wrong in the last statement" | run B (checker `e6c0`) → `got=0`; run D (checker `6844`) → `got=1` | see above | **KILLED** (control is right) — it caught the real I5 existential-vs-last-occurrence bug and the executors fixed it; keep the control |
| C05 | battery provenance with a `[REFTREE]` argument | run C: REF `$S/ref` carried checker `e6c079f6`, lane pins printed `6844c1d4`; C1-F5 read `got=0` under the pinned-new bytes | `INSTRUMENT plans/round-59-c1-check.py 6844…` + `C1-F5 got=0` | **SURVIVED** (battery defect) — the `INSTRUMENT` pins hash `$REPO`, while `c1()` executes `$REF`'s copy and `c2()` runs `$REPO`'s counter on `$REF`'s trial. With a `[REFTREE]` argument the receipt names bytes it did not measure. Fix: pin the bytes executed (the copied tree's files), or make `c1()` always use `$CHECKER` |
| C06 | C2-F5 "a fabricated all-HOLDS transcript cannot satisfy the five shim vectors" | battery run B: MATCH; B01 stub: `value=5` | `CONTROL C2-F5 expect=0 got=0 MATCH` vs B01 | **CEILING** (control weaker than its claim) — it rejects only a shim-*blind* fabrication; a shim-aware stub scores 5. The control's text should say it covers the blind class only (K2) |
| C07 | missing challenge parent on a good tree with `HYAKU_SCRATCH` set | direct checker A15; battery run A (partial, killed) | `CONTROL K1-REF expect=0 got=FAIL MISMATCH` in run A; direct: `value=FAIL … guard=0`, rc 1 | **KILLED** (checker's fail-closed default, D01) — but it makes the battery's result depend on another seat's scratch dir; the battery should export `C1_CHALLENGE_PARENT` under its own `$SCR` |
| C08 | the supplement battery (`plans/round-58-controls-supplement.sh`, the I3(b) receipt source) | committed `.ufo/waves/round-59/final/supplement-receipt.txt` | `CONTROL C1-F10 expect=challenge+stub got=value=2 broken=3 stub=0 MATCH`; `CONTROL C2-F4 … got=value=0 MATCH`; `SUPPLEMENT: match=2 mismatch=0` | **KILLED** as a receipt (its leg B delta is real), with one vacuous leg: C1-F10's leg C compares a constant 0 against `value+1 ≥ 1`, so it can never fail (the same tautology as A23) |
| C09 | duplicate `wrap_trial` helper (dead first definition) | `grep -n '^wrap_trial()' plans/round-59-controls.sh` | two definitions (lines 133 and 140 in `5f6c576f`; still two in `0d8647a0`); bash uses the last | **SURVIVED** (hygiene) — delete the first; it also makes line-number citations to the battery ambiguous |

## Defects found (not attacks; false-red / operability / integration)

| id | defect | evidence | fix required |
|---|---|---|---|
| D01 | `challenge_parent()` defaults to the fixed shared path `$HYAKU_SCRATCH/kagi-r59/R59ExecCounterC1` (else `$TMPDIR`) and never creates it; `tempfile.mkdtemp(dir=…)` fails and GUARD reads 0 | A15: `value=FAIL … guard=0`, rc 1 on a fully-resolved tree; the path does not exist (`ls /fast/scratch/hyaku/kagi-r59/R59ExecCounterC1` fails) and the R59ExecCounterC1 seat deletes its scratch at yield | `os.makedirs(par_abs, exist_ok=True)`, or `tempfile.mkdtemp()` under `TMPDIR` and only use a parent when it exists |
| D02 | every item selects a **physical line**; a Markdown-wrapped bullet is invisible to the item (false green, A01–A05), and the 14:12 fix state was wrapped and read red for three items before it was reflowed (D03 history) | A01–A05; D03 | join indented continuation lines into their parent bullet (or paragraph) before the last-occurrence read; add one control per item for the wrapped form |
| D03 | **live candidate reading at 14:24Z-03: `C1_ROUTED: value=1 population=5 i1=1 i2=1 i3=1 i4=0 i5=1 guard=1`** — D3/D5 are single-line and i3/i5 hold (the supplement receipt landed), but `.ufo/waves/round-59/final/citation-gate-r59.txt` was regenerated (1129 B, 8 lines) and still carries **no `CITATION_GATE:` line at all** — its first line is a scope caveat ("the default set … did not complete … (25 min, no output)") and its last line is a `LABELED …` detail — while the lesson's D4 line states `unresolved=13` | `C1_CHALLENGE_PARENT=$S/hs/chal python3 -I -B $L/plans/round-59-c1-check.py --root $L --repo $L --verbose`; `grep -n CITATION_GATE $L/.ufo/waves/round-59/final/citation-gate-r59.txt` → no match | the receipt must end with the ledger's `CITATION_GATE: … unresolved=<U> …` line (the item reads `last_nonempty_line` + the regex) with U equal to the lesson's D4 number (13); if the default ledger cannot complete, D4 must name that ceiling instead of claiming a gate reading. The earlier states (14:12 wrapped bullets, value=3; 14:17 error-line receipt) are history |
| D04 | `item3` role-blind membership | A06 | parse labelled roles |
| D05 | `item1` case/arrow/`the` alphabet; `item2` full-path-only selector | A07–A11 | widen the selectors (case-insensitive, `->`/`→`, optional `the`, basename) |
| D06 | C2 summary line read with `grep -q` (unanchored, first match wins) | B09, B10 | exact one-line, field-parsed summary check |
| D07 | battery C1-F7 unreachable expectation; C2-F2 sed; pins-vs-executed provenance; duplicate helper | C01, C02, C04, C06 | see the C rows |

## Residual risk and verification gaps

- The guard's bite is a printed-number comparison: a checker that detects the
  `c1-challenge-*` copy path (or reads `KAGI_*`) and prints `count+1` would satisfy the
  challenge without measuring. The battery has no control for that (C1-F7 cannot catch
  it; the supplement's C1-F10 stub is a constant 0). Untested here — the mutation seat
  owns the mutant class.
- A01–A11 are predicate-alphabet/structural gaps; if the L1 prefers to keep the frozen
  per-line reading, they become **named ceilings** and the claim must say so instead of
  accepting the green. A12 (symlink write escape) and D01 are unconditional defects.
- One host, one `bao` binary (2.7.2, sha256 pinned by the counter) — no cross-version or
  non-Linux reading. The C2 counter runs the real trial 8× per invocation (~50 s here);
  the battery runs that ~8× (≈7 min).
- The battery is a moving target: the byte I measured is pinned above; re-hash before
  quoting any line.

SEAT-STATUS: complete
