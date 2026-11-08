# Round 68 — R68Reviewer: C1 freshness, re-derived and attacked

Seat: R68Reviewer (reviewer, attack). Lane `kagi-shokunin`, branch `master`, claim BASE
`d3b2a4e8eed710277951e430efd3d27b5983033c`, frozen predeclaration
`23a8e0290d8d3a6f1de16eafce40fd1a189ef636` (the plan file was amended at `4251519b`; see L2).
Read-only on the lane: every measurement ran on copies under
`${HYAKU_SCRATCH}/kagi-r68/R68Reviewer*/`; no lane byte was written, no git command mutated
anything, no fleet path touched. No tool installed or upgraded (system `python3` 3.14.8,
`bash`; pacman paused, not run). Scratch deleted before yield; receipts in
`.ufo/waves/round-68/w1/R68Reviewer/receipts/`.

**The candidate moved through the whole review.** I measured `corpus/sources-census.sh` at
twelve sha256 values in ~70 minutes (`e7aacecd` BASE, `79fb03f2`, `1f91d36d`, `6173eab7`,
`d74a4183`, `fd3cb598`, `6f18c608`, `dd977de5`, `b93f0614`, `5b9e1b37`, `e48fc6a7`,
`690b0c2e`), the C1 counter at three (`60e3f680 → 4461be43 → d353cf36`), the C2 counter at
three (`bc6ba170 → 9b32226f → ba9d74b4`), and the ledger/claims/stamps several times. Every
number names the bytes it measured. **Final readings** — gate
`690b0c2ec2a469fee0424f56ccc35b52168d391e225cfa1142b183e4b02ea5c6`, counter
`d353cf36683f02d09649b570d383d9ec4af3b2a83ccbb0ae70cc44c011877021`:

```
SOURCES_CENSUS_SELFTEST: PASS (98 cases)
LEGS (anchor S167, frozen copy): caught=6/6
LANE: C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1     (guard d=1 on the lane)
```

## 0. Bottom line

- The instrumented C1 capability is **real and green** on the final bytes: six mutation
  classes refused, census and captures summaries clean
  (`SOURCES_CENSUS: CLEAN (rows=158 …)`, `SOURCES_CAPTURES: CLEAN (path_rows=38 bound=38
  located=38 prose=120)`).
- The **frozen number is not the delivered number**: the counter prints 38/33 (S166 recut +
  the round's own S167 row); plan §C1 and `claims.json` still say 37/32; ledger `R68-01` and
  A1.2 say 38/33 (B3).
- The claim's **BASE `caught=0/6` is anchor-selection**: the counter's anchor rule admits
  mixed rows and mutates a cell the BASE gate never reads; the frozen rule
  ("capture-path-shaped", A1.1: S156) yields **2/6** at BASE (B1).
- The normalizable-path vacuity I measured mid-wave (`.ufo//waves/…` read as prose) is
  **closed at the final instruments**: the gate normalizes separators (`path_rows=38`, binds)
  and the counter's `_norm_seps` agrees (B4, "closed during the wave", with both receipts).
- The **without-recut control still reads `verified=37`** (guard 0 only via its defect and the
  `a=0` count mismatch), so the frozen 37/32 cannot evidence the recut once S167 exists (B3).
- C2 was **not verifiable inside its own instruments** at write time: four stamps STALE,
  `claim-ledger.sh verify` measured 946 s against the counter's 900 s per-verify budget, and
  the C2 counter produced no verdict within 28 minutes (B6).

---

## 1. Independent recount (my own code, not the counter's, not the gate's)

`receipts/recount.py` walks `corpus/source-fetches.tsv` and binds each row (in-tree regular
file, raw sha256 == col 10, size == col 11, col-13 quote locates count>=1 under col 14; then
recomputes `normalized_sha256` for rendered rows). Two derivations, because the frozen
`verified` bullet admits two readings (B2):

- **literal** — col 16 *is* a capture path **or** *contains* a whitespace-delimited
  `.ufo/waves/` token that binds (the bullet as written);
- **legal** — col 16 is exactly one such path with no other content (the counter's reading;
  the one guard (a)'s count equality forces).

| tree | literal verified/col15 | legal verified/col15 | literal-only |
|---|---|---|---|
| BASE `d3b2a4e` (clean snapshot, TSV `90dd4a2c…`) | 37 / 32 | **36 / 31** | S166 |
| lane worktree (recut + S167, TSV `c14bcd88…`) | 38 / 33 | **38 / 33** | — |
| lane minus the S166 recut | 38 / 33 | **37 / 32** | S166 |
| lane with S164 written `.ufo//waves/…` (lexical recount) | 37 / 32 | 37 / 32 | — |

`receipts/recount-matrix.txt`. The last row is my *lexical* test; the landed gate and counter
both normalize separators now and read that tree as 38/33 (measured — see B4). S166's mixed
cell at BASE binds in every sense (67152 B, `544dbb7d…`, count=1), so under the literal bullet
BASE is already 37/32.

1. The claimed BASE 36/31 exists only under the **legal** reading; the plan's bullet would
   print 37/32 at BASE. Guard (a) forces the legal reading, so the bullet's second branch is
   dead text.
2. The headline "widens the population … to every mined row that names a lane-tree capture"
   does **not** widen `verified` — that count stays shaped-only; what widens is the *defect*
   population. Real capability; the count does not measure it.
3. The **without-recut control reads the frozen target** once S167 exists — §3.

## 2. The six legs, independently

`receipts/legs.py` builds each mutated copy from a frozen clone and judges the tree's own gate
stdout. Anchor is derived per the plan's rule ("the LAST capture-path-shaped row in file order
that binds"): **S156 at BASE** (A1.1; measured file order ends `… S164, S155, S156, S166,
S167`), **S167 at the candidate**. M5 borrows `652d3116…` (another rendered row's digest).

| leg | BASE (gate `e7aacecd`, anchor S156) | candidate (gate `690b0c2e`, anchor S167) |
|---|---|---|
| M1 trailing space | CLEAN — prose, never read | FAILED `capture-whitespace` |
| M2 comma-joined duplicate | CLEAN — prose, never read | FAILED `capture-whitespace` |
| M3 whole-TSV CRLF | CLEAN `path_rows=0` | FAILED `SC_FETCH cr-in-tsv` (+ per-row `capture-whitespace`) |
| M4 one col-10 hex digit | **FAILED `capture-digest-mismatch`** | FAILED `capture-digest-mismatch` |
| M5 borrowed col-15 | CLEAN (never recomputed) | FAILED `normalized-digest-mismatch` |
| M6 body +1 byte | **FAILED `capture-bytes-mismatch` + digest** | FAILED `capture-bytes-mismatch` |
| **caught** | **2/6** | **6/6** |

`receipts/legs-base-S156.txt`, `receipts/legs-frozen-690.txt`.

The counter's own BASE receipt (`R68ExecCounterC1/base-run.txt`) reports `caught=0/6` because
`derive_anchor` deliberately admits **mixed** rows ("Pure and mixed both qualify …; S166
qualifies on both trees"), so at BASE it mutates S166 — a cell the BASE gate classifies prose.
§C1 says "capture-path-shaped" and A1.1 names S156. On the frozen rule the before-number is
**2/6**: the BASE gate already catches digest and byte tampering (round 67's SC_CAPTURE). The
claimed 0/6→6/6 delta is half anchor artefact; the real delta is 2/6→6/6 (four new reasons).
The counter seat discloses the divergence in its own §Dead ends 2 — but the baseline inherits
it.

## 3. The frozen target against its own frontier row

- Recut-only (S166 pure, no S167): `verified=37 col15=32`, caught 6/6 — the frozen numbers
  (`R68ExecCounterC1/cand-run.txt`; my row-C recount).
- Final candidate (recut + the plan's Frontier S167 row): **38/33**
  (`C1_VERIFIED: verified=38 col15=33 caught=6/6 guard=1`; S167 binds: raw `84e14418…`,
  35491 B, count=1, normalized `30194c4f…`).
- The Frontier step is part of the plan ("One row admitted … `checked-out-side capture`"), so
  the frozen `verified=37` cannot be printed by a derivation that includes it. A1.2 says so;
  `plans/round-68.md:55` and `.ufo/waves/round-68/claims.json` still say 37/32; ledger
  `R68-01` pins 38/33.
- **The do-nothing control is falsified.** On a copy without the S166 recut the current
  counter prints `C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=0` (guard a=0, defects=1
  — the mixed cell is a token-shape defect). It *does* read verified=37, the assignment's
  control value, because S167 fills the slot; the recut's own contribution is unmeasurable
  once S167 is present.

## 4. Vacuity constructions (each pasted with its verdict)

**V1 — a defect row classified `prose` while carrying a capture claim (real mid-wave, closed
at the final instruments).** At gate `b93f0614` / counter `4461be43`:

```
S113.col16 = ".ufo//waves/round-55/capture/S113.body"   (also ".ufo/./waves/…")
gate  : CLEAN (path_rows=37 bound=37 located=37 prose=121)   rc 0    <- never read
S164.col16 = ".ufo//waves/round-64/capture/S143.body"   (a rendered row)
counter: C1_VERIFIED: verified=37 col15=32 caught=6/6 guard=1      <- the exact frozen line
```

At gate `690b0c2e` the same spellings are `path` and bind — `CLEAN (path_rows=38 bound=38
located=38 prose=120)` — and the counter (`_norm_seps`, `d353cf36`) reads the demoted tree as
`verified=38 col15=33 caught=6/6 guard=1`. **Closed**; the receipts for both states are
`classification-probes.txt`, `counter-runs-demote.txt` (b93f0614) and
`final-instruments-latest.txt` (690b0c2e). The requirement: keep it closed at commit; the
gate seat's report (which claimed this normalisation before the code did) must match the
landed bytes.

**V2 — a legal pure path refused.** The frozen classification rule has no shape predicate;
the gate and the counter impose `^[A-Za-z0-9._][A-Za-z0-9._/-]*$`. A 19-byte in-lane body
named `a+b.body` with correct col10/col11/col13 under raw-literal-v1, at gate `690b0c2e`:

```
FINDING SC_CAPTURE id=S113 capture-token
SOURCES_CAPTURES: FAILED (defects=1 path_rows=38 bound=37 located=37 prose=120)
```

The cell is exactly one `.ufo/waves/` path with no other content and binds — legal by the
frozen rule, refused by the instrument.

**V3 — guards (a)/(b)/(e) satisfied by a constant printer.** A 6-line stub gate printing the
derived counts and `PASS (98 cases)`, with counter `d353cf36`:

```
c1-verified: guard a=1 b=1 c=1 d=skip e=1 defe defects=0
C1_VERIFIED: verified=38 col15=33 caught=0/6 guard=1
```

Only `caught` refuses it. The counter header's claim that a stub's "fixed counts disagree with
the derivation on the CRLF copy" is false: guard (c) executes the **BASE** tree's gate on the
CRLF copy, never the stub.

**V4 — the CRLF witness passes without blindness.** (i) An all-prose TSV saved CRLF prints
`SOURCES_CAPTURES: CLEAN (path_rows=0 bound=0 located=0 prose=157)` on the BASE gate. (ii) A
BASE gate carrying one `grep -q $'\r'` line prints `FINDING SC_FETCH cr-in-tsv` + FAILED on the
same copy, so guard (c) **fails while the candidate is untouched**: it measures BASE blindness,
not candidate work. `receipts/crlf-witnesses.txt`; the unpatched witness reproduces round 67's
`path_rows=0`.

**V5 — over-refusal of legal prose.** The frozen sentence says prose = a cell naming no
`.ufo/waves/` token, never read. At gate `690b0c2e` (both measured):

```
~/notes   -> FINDING SC_CAPTURE id=S113 capture-token
//notes   -> FINDING SC_CAPTURE id=S113 capture-token
```

The gate seat's report says a `//` form *without* a waves token is prose; the bytes disagree.
No such cell exists in the live TSV; it is a false-positive hazard, not a live failure.

## 5. Findings

### Blocking

**B1 — the claim's baseline is anchor-selected (0/6 → true 2/6 at BASE).** `derive_anchor`
admits mixed rows; §C1/A1.1 say capture-path-shaped (S156). On S156 the BASE gate catches M4
and M6 (measured). `claims.json`, A1.2, the counter header and `base-run.txt` all carry
"BASE caught=0/6". Honest before/after: 2/6 → 6/6.

**B2 — the frozen `verified` bullet is self-contradictory and the counter silently picks one
reading.** Literal: BASE 37/32. Implemented/legal: 36/31 (the claim's number). Guard (a)
forces the legal reading, so the bullet's second branch is dead. State the reading.

**B3 — the frozen target 37/32 is unreachable on the final tree and is the control value.**
Final 38/33; recut-only 37/32; without-recut copy 37/32 (still printed, guard 0 via its
defect). `claims.json` (37/32), plan §C1 (37/32), `R68-01` (38/33) and A1.2 (38/33) disagree.
The L1 must state the target change once and align `claims.json`.

**B5 — the shared BASE extraction is not the claimed BASE bytes.** At 09:26 the L1 extraction
`/fast/scratch/hyaku/kagi-r68/l1/base-d3b2a4e/corpus/source-fetches.tsv` became `aa6fa318…`
(S164 col16 gains a trailing space) while `git show d3b2a4e:corpus/source-fetches.tsv` is
`90dd4a2c…`. My 09:22 snapshot has the committed hash; the counter seat documents the same
contamination. Any receipt that measured that path after 09:26 derives 35/30, not 36/31
(QM96). Regenerate from `git archive` before filing.

**B6 — C2's record surfaces and runtime are not yet claimable.** At 10:26
(`claim-ledger.tsv c5cd548f`, `stamps.tsv ac5bc1e2`, gate `690b0c2e`): `R21-03` pins
`PASS (98 cases)` and the journal is `88 → 98` ✓; `R68-01` pins 38/33 ✓;
`claims-declared.sh` reads `CLEAN (claims=63)` ✓. Still open: **four stamps STALE** —
`corpus/source-fetches.tsv` (`90dd4a2c` pinned vs `c14bcd88`), `corpus/SOURCES.md`
(`9590e7e7` vs `688fbab4`), `SCORECARD.md` (`eefcaa10` vs `9763f913`),
`corpus/sources-census.sh` (`e7aacecd` vs `690b0c2e`). `claim-ledger.sh verify` measured
**946 s** (40 lines, exit 2 on a mid-edit malformed row) — above the C2 counter's 900 s
per-verify budget — and the C2 counter produced no verdict within 28 minutes. Until the stamps
are re-derived and the verify runtime is inside the instrument budget, `CLAIM_LEDGER: CLEAN`
(C2 guard b) cannot be shown.

**B7 — seat receipts are not byte-pinned.** `R68ExecCounterC1/{base-run,cand-run,lane-run,
gate-selftest}.txt` name counts and ids but no sha256 for the gate/normalizer/TSV they
measured, and the gate changed twelve times. A count without bytes is not reproducible
evidence; every seat receipt must carry the gate/normalizer/TSV hashes (QM96). My own first
candidate-leg pass was bitten by this (two gate revisions across six legs); the frozen-copy
runs are the ones cited here.

### Closed during the wave

**B4 (closed) — the normalizable-path vacuity.** At gate `b93f0614` a capture row written
`.ufo//waves/…` was classified prose and the demoted tree printed the exact frozen line
(V1). The gate now binds both `.`-segment and doubled-slash spellings and the counter
normalizes separators; both states are receipted. Keep this re-tested at commit: it is the
one construction that turned the frozen predicate into a pass for a worse tree.

### Medium

**M1 — the gate over-refuses legal prose (`~/`, `//` forms).** V5, measured at `690b0c2e`;
contradicts the gate seat's own report wording. False-positive hazard.

**M2 — a legal pure path whose name holds a non-shape character is refused.** V2, measured at
`690b0c2e`.

**M3 — the counter's documented stub-resistance is overstated.** V3: guards a/b/c/e all pass
under a constant printer; only `caught=0/6` refuses.

**M4 — guard (c)'s polarity is a BASE property, not a candidate tooth.** V4.

**M5 — the captures summary hid a CRLF save on earlier revisions.** At `79fb`/`d74a` the M3
copy printed `SOURCES_CAPTURES: CLEAN (path_rows=38 …)` beside `FINDING SC_FETCH cr-in-tsv`;
later revisions print `FAILED (defects=38 …)` (CR retained). Conforming now; the earlier
receipts remain in the wave as a caution.

**M6 — the instruments are not atomically published.** At 10:04:56 gate `5b9e1b37` read
`FAIL (98 cases, 48 failed)` mid-write; at 10:07 `e48fc6a7` read `PASS (98 cases)`; by 10:23
`690b0c2e` again. My live-tree leg pass caught two gate revisions across six legs (B7). Freeze
a copy first; name its hash in every receipt.

**M7 — the gate selftest was red for most of the wave.** `6173eab7`:
`FAIL (98 cases, 3 failed)` — `capture-symlink-escape` → `capture-missing` not
`-outside-root`; `capture-whitespace-cr` → no finding (CR stripped); `capture-token-slashslash`
→ `capture-outside-root` not `-token`. `6f18c608`: `FAIL (98 cases, 2 failed)` (the last two).
`b93f0614`/`e48fc6a7`/`690b0c2e`: `PASS (98 cases)`. The counter correctly reported `guard=0`
throughout; C1 was unreachable until the gate seat fixed the two reason mismatches. Receipts
`selftest-landed.txt`, `selftest-600.txt`, `gate-1004-transient-red.txt`,
`gate-1007-selftest-pass.txt`.

**M8 — `claim-ledger.sh verify` is unsafe against a tree a seat holds open.** One run against
bytes `5ce3b929…` ended `claim-ledger: malformed claims row (fields=1)` exit 2. Transient, but
the C2 guard-b comparison can be poisoned by a mid-edit read.

### Low

**L1 — anchor parenthetical vs derivation.** §C1's "(S166 at the candidate, S164 at BASE)" was
wrong; A1.1 corrects it to S156/S167, and the counter agrees for the candidate but not for
BASE (mixed-inclusive rule). Cite A1.1 and make `derive_anchor` match it.

**L2 — the amendment landed after the freeze.** `plans/round-68.md` §"Amendment A1" is commit
`4251519b`; the "does not move" file moved and A1.2 restates the target (37/32 → 38/33). It is
honest and recorded before any counter reading, but the wave assignment freezes "predicate,
counter, kill rule, population and target"; the report must state the target change once (B3).

**L3 — inherited ceilings, not re-measured.** Hardlink durability (R67 C2), normalizer-tamper
(C4 — the gate still executes `$SCRIPT_DIR/rendered-text-v1.py`, which in a lane invocation is
the audited tree's own copy; the counter prefers the BASE tree's when `--base-tree` is given),
one-token quotes (C5), point-in-time digests. Unchanged from round 67.

## 6. Ceilings measured, with the input that shows each

| ceiling | demonstrating input | measured verdict |
|---|---|---|
| lexical population (closed) | `.ufo//waves/…` at `b93f0614` vs `690b0c2e` | prose/37 then path/38 — both receipted |
| count is not injective | S164 written `.ufo//waves/…` at `b93f0614` | `verified=37 col15=32 caught=6/6 guard=1` (closed later) |
| shape predicate unstated | `…/capture/a+b.body` (19 B, binds) at `690b0c2e` | `capture-token`, FAILED |
| prose definition vs reason set | `~/notes`, `//notes` at `690b0c2e` | `capture-token`, FAILED |
| guards (a)/(b)/(e) constant printer | stub gate at counter `d353cf36` | `verified=38 col15=33 caught=0/6 guard=1` |
| guard (c) blindness polarity | all-prose+CRLF (`path_rows=0`); patched BASE gate | CLEAN-with-nothing-read; candidate untouched yet guard fails |
| captures summary hides CRLF format | M3 copy at gate `79fb`/`d74a` | `CLEAN (path_rows=38 …)` beside `SC_FETCH cr-in-tsv` |
| ledger gate runtime | `claim-ledger.sh verify` | 946 s > C2's 900 s inner budget |
| instrument publication is not atomic | `5b9e1b37` mid-write | `FAIL (98, 48 failed)` then `PASS (98)` minutes later |
| without-recut control equals the target | copy without S166 recut | `verified=37 col15=32` (guard 0 via defects) |

## 7. Verification gaps and residual risk

- **The C2 counter verdict is not in this report.** It produced no line within 28 minutes
  (two `claim-ledger.sh verify` invocations at ~15 min each) and was stopped at its harness
  cap. C2 is covered only by the three BASE legs measured directly (L1: 88 vs 89 at BASE; L2:
  rows absent at BASE; L3: `cells` rc 2 SETUP at BASE and at lane before the parser fix) and
  by B6's record state at 10:26.
- No final *committed* revision exists yet; all C1 readings are pre-commit (gate `690b0c2e`,
  counter `d353cf36`). The L1 must re-run and file that line.
- The instruments moved throughout; any receipt quoting a count without a sha256 is not
  evidence (B7/M6).
- I did not re-measure the inherited ceilings (L3).
- No network, no `op`, no sibling lane, no fleet write. Scratch removed after receipts.
