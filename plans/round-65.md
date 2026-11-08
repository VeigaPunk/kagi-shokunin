# Round 65 — frozen plan (kagi-shokunin)

Lane: kagi (secrets & vault ops). Round 65, attempt 1. Claim BASE
`b17887f03179b61d49e3e0f10ce1a9add21829e7` (round-64 verifier spot-check tip,
`corpus/lessons/round-64-verifier-spotcheck.md`). This file is the predeclaration:
committed alone before any candidate work. The candidate moves; this file does not.

Axes at BASE: depth 9, coverage 9, operability 9, freshness 9, calibration 9,
adjacency 9. Saturation line 9, stagnation window N=3; capabilities entered rounds
57–64, so no stagnation waiver is claimed. All claims name distinct axes
(calibration, operability, freshness); each is verifiable without the others landed.

Motivating evidence: SCORECARD.md §Round 64 — planned (next) items 1–3, verified
against the round-64 spot-check §2/§5 and the sealed instruments. The round-64
plan's named ceilings are this round's claims. At least one claim works the lowest
non-retired axis — all six tie at 9; C1 works calibration (the named ceiling of
the round-64 instrument, the trend furthest behind: discernment).

## C1 — calibration: the vehicle needle becomes structural + the checker carries a class matrix

Target axis: calibration (mismatch between the C1 instrument's claim — a polarity
grammar over shape classes, not a fixture lookup — and observed behaviour: the
A4 vehicle is a 15-string literal lookup with a constant `PASS (cases=91)`
export needle, and the round-64 falsification ledger records the vehicle
reduction as total).

**Frozen predicate (this sentence is the plan's, the counter's code and the
receipt's label):**

```
C1_MATRIX: matrix = the number of the round-65 class-matrix fixtures
(M1..M8, ids R65-H1..H5 forgery and R65-Q1..Q3 benign, in
plans/round-65-heldout.tsv) on which the hardened checker
(plans/round-61-c1-check.py --no-challenge on a fixture-applied copy of the
measured tree) reads `C1_ROUTED: value=0` for a forgery or `value>=1` for a
benign rewrite. POP = 8 (5 forgery + 3 benign); target matrix=0 (BASE 5: the five forgery
copies read value=0 at BASE and the three benign copies already read value=0
— the parenthetical/idiom classes resolve them, so they are non-harm controls). GUARD = 1 iff,
on the same measured tree: (a) the unmodified copy prints `value=0` with
i1..i7 all 1; (b) `--selftest` exits 0 printing `C1_CHECK_SELFTEST: PASS
(cases=N)` with N >= 111; (c) the round-63 residual counter still reads
`C1_RESIDUAL: accepted=0 rejected=0 population=10/6 guard=1`; (d) a
printer-stub checker reading `value=0` verbatim is refused (no C1 verdict line,
non-zero exit); (e) the STRUCTURAL vehicle — a checker carrying
`NEGATORS = frozenset(())`, a constant `PASS (cases=91)`, and value computed
as `1 if any(anchor-token in corpus for anchor-token in TOKENS) else 0` over
the committed-table tokens (never a per-fixture literal) — reads accepted=0
rejected=0 on the committed tables AND reads matrix=0 on the round-65 held-out
set but reads matrix>=1 on a SEALED negative control (the round-64 held-out
population, which the structural vehicle has not been fitted to). A structural
vehicle that does NOT read matrix>=1 on the sealed control cannot be the
witness, and the leg reads 0.
```

The class matrix: each forgery fixture exercises one distinct mechanism the
checker claims (denial-after-pair I7, duplicate-pair-unbound I7, quoted-denial
I4, duplicated-mechanism I5, negated-subject I7); each benign fixture a benign
class (parenthetical, em-dash, idiom `not less than`). Fixtures are formed in
the sealed file `plans/round-65-heldout.tsv` from round-60 correction lines,
distinct from the round-64 held-out strings (no shared 24-char substring with
`plans/round-64-heldout.tsv`). Held-out from the checker: the checker and its
selftest are built without reading the sealed file; the wave's checker seat
names it and is forbidden from reading it (a seat that reads it must disclose
it; the L1 records that as a defect, not a pass).

**Commands:**
```
bash plans/round-65-c1.sh [revision]          # BASE when omitted; --tree DIR also accepted
bash plans/round-65-c1.sh --selftest [revision|--tree DIR]
python3 -I -B plans/round-61-c1-check.py --root <tree> --repo <lane> --fleet <fleet-root> --no-challenge
```
Output line: `C1_MATRIX: matrix=A population=8 guard=G (real=… selftest=… resid=… stub=… vehicle=…)`.
Exit 0 iff guard=1 and matrix=0; 1 otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: a tree byte-identical to BASE must read `matrix=5 population=8`; any
  lower reading means a held-out fixture is vacuous and voids the claim.
- K2: each forgery reads accepted on the BASE checker and rejected on the
  hardened one; each benign rewrite the reverse. Both polarities are live.
- K3: a printer-stub checker is refused (guard leg d).
- K4: the round-63 `C1_RESIDUAL` verdict still reads `accepted=0 rejected=0`
  on the candidate (guard leg c); a hardening that regresses a committed
  fixture fails the guard, not the claim.
- K5: the STRUCTURAL vehicle reads `matrix=0` on the round-65 held-out set
  only because it carries the committed-table tokens; it MUST read
  `matrix>=1` on the sealed negative control (the round-64 population). A
  structural vehicle whose needle is a counter-asserted constant reads
  `matrix=0` on a mutation that empties its TOKENS set? No — the mutation
  empties TOKENS and the vehicle must then read `matrix=8`. If it does not,
  the needle is decorative and the guard leg reads 0.

**Population census at BASE (measured, not assumed):** the L1 measured, at
BASE `b17887f`, on slim fixture copies under
`/fast/scratch/hyaku/kagi-r65/L1Base/` — the five forgery copies each read
`value=0` (accepted), the three benign copies each read `value=0` (already
resolved by the round-64 parenthetical/idiom classes), the unmodified copy
reads `value=0`, and the checker `--selftest` prints `PASS (cases=111)`.
=> `matrix BASE = 5` over population 8 (the benign copies are non-harm
controls, not targets; a hardening that regresses one fails the guard).
Measured at `.ufo/waves/round-65/base/census-c1.md`.

**Named ceilings:** eight fixtures remain eight fixtures — the matrix is a
class matrix over claimed mechanisms, not a grammar proof. A lookup carrying
the eight fresh strings verbatim would also read `matrix=0`; the structural
leg (e) plus the sealed control is the only guard that sees the needle, and
it falsifies the structural vehicle class, not every lookup. A structural
read cannot prove a corrected sentence true (QM79/QM81).

## C2 — operability: the routed-leg population becomes the five receipts the tree holds

Target axis: operability (a runnable artifact whose verdict is reachable —
here, a routed-leg receipt whose cited population exists on disk).

**Frozen predicate:**

```
C2_ROUTED: routed = 1 iff `bash plans/round-65-routed.sh --tree <candidate>`
prints exactly one `ROUTED: d1=1 d2=1 d3=1` line and exits 0 inside
`timeout 900`, where d3=1 iff the six round-64 final receipts exist under
`.ufo/waves/round-64/final/` — c1-heldout, c2-refusal, controls, release-clock,
doc-audit, claims-declared — each carrying its label line, AND the round-64
lesson `corpus/lessons/round-64.md` and `LOG.md` each cite all six stems.
Target routed=1 (BASE 0: leg d3 at BASE cites the round-63 population, of
which `controls.txt` is absent — `.ufo/waves/round-63/final/` holds five
receipts, and the round-63 battery's receipt lives under
`build/R63ExecControls/`, so `ROUTED: d3=0` by construction, QM57).
GUARD = 1 iff, on the same measured tree: (a) the routed battery's own
`--selftest` exits 0 printing `ROUTED_SELFTEST: PASS`; (b) a tree with the
round-64 final directory removed reads `d3=0` naming the absent receipt (the
leg is shown able to fail and the failure is a named defect reading, never a
hidden SETUP and never a pass); (c) legs d1 and d2 still fire individually
(the A4 structural vehicle reads heldout>=1 on the sealed set; the
recursion-bound refutation still holds within the leg's own 240 s budget).
```

**Commands:**
```
bash plans/round-65-routed.sh [--tree DIR] [--repo DIR]
bash plans/round-65-routed.sh --selftest
```
Output line: `ROUTED: d1=1 d2=1 d3=1`. Exit 0 iff all three read 1; 1
otherwise; 2 SETUP.

**Kill rules (each must be able to fire):**
- K1: at BASE the counter reads `d3=0` naming the absent round-63
  `controls.txt`; a tree that reads `d3=1` at BASE is vacuous and voids the
  claim.
- K2: with `.ufo/waves/round-64/final/` removed, `d3=0` naming the first
  absent receipt.
- K3: legs d1 and d2 still fire individually on the candidate.
- K4: the round-64 routed battery's `d1` vehicle leg and `d2` bound leg
  still read 1 on the same tree below (the delegation is not a deletion).

**Population census at BASE (measured, not assumed):** at BASE,
`ls .ufo/waves/round-63/final/` lists five receipts (c1-residual, c2-refusal,
claims-declared, doc-audit, release-clock) and no `controls.txt`; the
round-63 battery's committed receipt lives under
`build/R63ExecControls/`. Measured at `.ufo/waves/round-65/base/census-c2.txt`.

**Named ceilings:** d3=1 is a presence-and-citation claim, not a freshness
claim about the receipt contents; a receipt carrying a stale label line
still counts. The leg names what it proves; the closure's falsification
ledger is the witness for a stale-content forgery.

## C3 — freshness: the S143 carrier becomes reproducible (volatile shape, not digest)

Target axis: freshness (re-verification of a drifted endpoint claim).

**Frozen predicate:**

```
C3_VOLATILE: volatile = 1 iff a single run of
`python3 corpus/volatile-shape.py --url <BioC URL> --receipt <path>` against
the live endpoint prints `VOLATILE_SHAPE: match=1 passages=182 texts=180
date_skew=0-3` and exits 0, AND the committed receipt records the served
body's sha256, `<date>` stamp, and the byte-diff against the S148 pin
bounding the drift to the date stamp only. Target volatile=1 (BASE 0: no
such artifact exists — S143→S148 supersession is a prose note, and a reader
cannot reproduce the re-verification without refetching and hand-diffing).
GUARD = 1 iff: (a) the receipt's recorded byte-diff is exactly the date-stamp
bytes (offset 127, one byte) with `<passage>` 182 and `<text>` 180
unchanged; (b) the script refuses a body whose `<text>` count differs
(mutation refutation, named in the receipt); (c) the S143 and S148 rows
still read as written with S148 `supersedes S143 —` (append-only discipline
intact); (d) `SOURCES_CENSUS: CLEAN` and the sources-census validate command
exits 0.
```

The SOURCED claim: a row opened this round — the BioC endpoint re-opened on
the current date, its `≤25`-word located quote grounding `teaches` — yields
the volatile-shape row in `corpus/SOURCES.md` (a new row `S155` whose
`teaches` opens `supersedes S148 —` only if the shape changed; otherwise a
`mined` row recording the reproducible shape). The claim's evidence cites
that `S###`.

**Commands:**
```
python3 corpus/volatile-shape.py --url https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_xml/PMC2757457/unicode --receipt .ufo/waves/round-65/capture/volatile-shape-receipt.json
python3 corpus/volatile-shape.py --selftest
```
Output line: `VOLATILE_SHAPE: match=1 passages=182 texts=180 date_skew=0-3`.
Exit 0 iff guard conditions hold; 1 otherwise; 2 SETUP (no network).

**Kill rules (each must be able to fire):**
- K1: a body with a changed `<text>` count (mutated fixture) reads `match=0`
  and exits 1.
- K2: a body at a date 4+ days from the pin reads `date_skew>3` and exits 1
  (the skew bound is real, not decorative).
- K3: an unreachable endpoint reads SETUP exit 2, never a pass.
- K4: `SOURCES_CENSUS` at round end exits 0 with the new row present and
  the `S148` row unedited except its `recheck`/`used-by`.

**Population census at BASE (measured, not assumed):** at BASE no
`corpus/volatile-shape.py` exists and no receipt under
`.ufo/waves/round-65/capture/`; S148's `teaches` records the one-byte drift
in prose. Measured at `.ufo/waves/round-65/base/census-c3.txt`.

**Named ceilings:** the shape census is a count of `<passage>`/`<text>`
elements and the date-stamp byte — it does not verify the deposit's textual
content. A body that preserves counts while changing wording reads match=1;
the user's §3.1.2 trigger/termination-term reading is the prose quarter, not
the counter's.

## Frontier step

Candidate sources to open this round (≥3 opened, ≥1 admitted, ≥1 rejected,
each with a ≤25-word located quote + access date in the lesson's `## Gate`):

1. The BioC endpoint re-opened on the current date (the C3 source; a `mined`
   row `S155` or a `supersedes S148 —` row if the shape changed).
2. The ConText PMC2757457 deposit re-opened (S135's carrier; `recheck`
   refresh if the digest still matches).
3. One mutation-testing survey / equivalent-mutant source as the weak lead
   (the reject: a vendor blog or an unopened citation chain).
4. One fresh `considerthese/` proposal still unimplemented (mine at most one;
   the latest file is `considerthese/2026-10-26.md`).

## Assimilation

`Assimilation: none` this round (no package adoption; the `merge/kagi/`
package stays unadopted until its collision check passes — recorded in the
report's Sources & frontier section, no penalty).

## considerthese

At most ONE still-unimplemented proposal per round. The latest file is
`considerthese/2026-10-26.md`; if proposal 3 is already mined (round 63
QM83/QM84), no new proposal is mined this round — recorded in the report.

## Wave

`kagi-r65-w1`, 16 seats v1 (band 8–16, policy
`.ufo/waves/round-65/w1-dispatch.json`, reports
`.ufo/waves/round-65/w1/`): 2 scout, 5 executor, 2 scribe, 1 reviewer,
1 critic, 2 mutation-tester, 1 connector, 1 sentinel, 1 revenger. Attack
share 4/16 = 25 % literal (reviewer, critic, mutation-tester ×2; no labrat
seat exists), 5/16 = 31.25 % counting the sentinel. The L1 holds the
canonical planner seat and is the sole integration owner and committer.
Roles span the host route table (checker/counter seats to `executor` where
they write or run code; prose drafting to `scribe`; attacks to
reviewer/critic/mutation-tester/revenger/scout).

## Scratch discipline

Every seat's scratch root is `$HYAKU_SCRATCH/kagi-r65/<seat-name>/` with
`HYAKU_SCRATCH=/fast/scratch/hyaku` (explicit `mkdir -p`, explicit
`TMPDIR=… --work …`). Seats delete their scratch on exit
(`trap 'rm -rf -- "$S"' EXIT`); receipts are copied into
`.ufo/waves/round-65/w1/` first. `/tmp` is for files under 50 MB only.
Counters MUST honour `TMPDIR` and accept a scratch argument (QM74).

## Bounds

- The counters are the verdicts; the BASE census is the L1's own measurement
  (`.ufo/waves/round-65/base/`, committed) and is re-derived by the
  committed counters.
- Round-65 held-out fixtures are sealed at predeclaration (sha256 of the
  TSV committed alongside this plan); a seat that reads them must disclose it.
- A counter whose fixture tree-copy cost exceeds its budget reads SETUP,
  never a pass.
