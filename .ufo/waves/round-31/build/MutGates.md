# MutGates — round-31 kill-rule evidence (mutation tester)

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (READ ONLY for this seat).
Fixture: lone `git clone --shared` of the lane at `2d46e57` (commits `4767b04`+`2d46e57` touch only
`plans/round-31.md` and `.ufo/waves/round-31/` controls, so `corpus/` and `SCORECARD.md` in the clone
are byte-identical to frozen BASE `655e620`). Two clones: `lane` (heading + census probes) and
`lane-v` (row-expectation probe, full `verify`). Scratch root `/fast/scratch/hyaku/kagi-r31/MutGates/`
(deleted at the end of this seat; receipts copied here first).

Detector discipline: pristine → mutant → restored, each a full re-run; the pristine and restored
receipts for every probe are byte-identical (`diff` empty), and the mutated file is restored from a
`cp --preserve=all` snapshot and re-hashed. Every receipt quoted below is committed beside this report
as `mut-*.txt` in this directory.

Fixture hashes (before any mutation; lane copies re-hashed at the end and equal):

```
f4eb6ec481f1552108c6a3030ff7838beef7dc50cb51ee5d49f2444a90b62fbf  SCORECARD.md            (BASE)
23363843b898f52004298d1d3fafa07b946258ea4db204364e10282bf14c9047  corpus/claim-ledger.tsv  (BASE)
156c292a5aa26f875dd0c374ec6434b0f7fe4b38928ce1118ea226887bd2f6c6  corpus/source-fetches.tsv(BASE, before state)
ec915f604ba6dce33672263ef53e7f79912f4af94bd42ffb1fc32b6eefbc8da5  corpus/claim-ledger.sh   (gate, unmodified)
8d30d627021cd70947bfec6a3984418ff1e7f1a8a16d8b5ab580a56898a0968a  corpus/sources-census.sh (gate, unmodified)
```

---

## 1. C1 counter — `bash corpus/claim-ledger.sh cells` (round-heading parser)

Pristine state for this probe = BASE + the five plan rewrites (content-preserving heading reshape),
since the claim is that the re-armed audit *runs* at the landing. Mutant = one of the five reshapes
missing.

| state | SCORECARD hash | exit | `unrecognised round heading` | `^CELL_AUDIT:` | wall |
|---|---|---|---|---|---|
| BASE (no rewrites) | `f4eb6ec4…` | **2** | 1 (Round 26) | 0 | 2.8 s |
| pristine (5 rewrites) | `ea0ba36f…` | **2** | **0** | **1** | 37.3 s |
| mutant (Round 27 loses `post-move`) | `3aa21871…` | **2** | **1** (Round 27) | **0** | 2.8 s |
| restored | `ea0ba36f…` (identical) | **2** | 0 | 1 | 37.3 s |

- Pristine receipt `mut-cells-pristine-reshaped.txt`:
  `CELL_AUDIT: POLICY (cells=210 row_pointed=147 stamp_pointed=94 policy=2)` — the audit completes over
  210 cells (the claim's floor) with no setup error.
- Mutant receipt `mut-cells-heading-mutant.txt`:
  `claim-ledger: unrecognised round heading in …/SCORECARD.md: '## Round 27 — (knowledge numbers bound;
  release clocks refuse silent regression)' (expected '## Round <N> — pre-move|post-move')` — the run
  dies before auditing anything, exactly the BASE setup error class (BASE control reproduced verbatim in
  `mut-cells-base-setup-error.txt`, bar the clone path).
- Restored receipt `mut-cells-restored.txt` is byte-identical to the pristine receipt (`diff` empty).

**Verdict: killable.** One unreshaped heading kills the audit.

Two honest caveats a reviewer should carry:

1. **The exit code does not discriminate here.** BASE, pristine-reshaped, mutant and restored all exit 2
   (the two routed POLICY rows hold the summary at `POLICY`). The claim's counting command
   (`grep -c 'unrecognised round heading'`=0, `grep -c '^CELL_AUDIT:'`=1) is the real tooth; a reviewer
   grading `cells` by exit code alone would see no difference between "setup error" and "audit ran".
2. **The reshaped-only state is not the landing.** With just the five rewrites the audit completes but
   reports `STALE-POINTER SCORECARD.md sha=f4eb6ec481f1->ea0ba36fb843` and `FAIL R22-03 / R24-06 /
   R24-15` — precisely the identity/stamp migrations plan correction 1 widens from 3 to 10 rows. So the
   heading reshape alone does **not** satisfy the predicate (zero STALE-POINTER lines); the stamp
   re-pin and row migrations are load-bearing, and this probe confirms the audit fires on exactly that
   drift. It cannot validate the migrated *values*, only that drift is loud.

## 2. C2 counter — `bash corpus/sources-census.sh` (capture provenance)

Three separate append-shaped mutants, each restored before the next; pristine and restored runs bracket
them. Restored hash = pristine hash `156c292a…`.

| mutant | appended row shape | exit | matching finding | co-findings |
|---|---|---|---|---|
| pristine | — | **0** | `SOURCES_CENSUS: CLEAN (rows=60 … captures=60 inrow=16 inrow_only=0 inrow_nonreproducing=12)` | — |
| A row-identity | copy of S017, field 3 zeroed (`0000…`) | **1** | `FINDING SC_FETCH id=S017 row-identity-digest-mismatch` | `id=S017 duplicate-provenance`, `FAILED (findings=2 rows=60)` |
| B 15-column | copy of S017 with the location field dropped (`NF=15`) | **1** | `FINDING SC_FETCH line=104 nf=15` | `FAILED (findings=1 rows=60)` |
| C quote length | copy of S017, field 13 set to a 26-word quote | **1** | `FINDING SC_FETCH id=S017 quote` | `id=S017 duplicate-provenance`, `FAILED (findings=2 rows=60)` |
| restored | — | **0** | identical CLEAN line to pristine | — |

Receipts: `mut-census-pristine.txt`, `mut-census-rowdigest.txt`, `mut-census-15col.txt`,
`mut-census-quote26.txt`, `mut-census-restored.txt`; mutant-row text and mutant-state file hashes are in
`mut-hashes-and-states.txt` (A `269562ed…`, B `3c431ae5…`, C `a7498a49…`).

**Verdict: killable**, three independent teeth (row-identity digest, column count, quote word bound),
each exit 1 with the named `SC_FETCH` finding.

Caveat: an appended 16-column row must reuse an existing registry id, otherwise the loop hits
`not-a-registry-row` and `continue`s **before** the digest/quote checks. That is why A and C carry the
`duplicate-provenance` co-finding: it is unavoidable collateral of the append shape, not a second
defect. The expected finding is present and exactly named in both cases.

## 3. C1 row-expectation counter — `bash corpus/claim-ledger.sh verify` (R24-06)

Full `verify` was affordable (115–124 s per run, well under the 240 s bound), so **no QM12 substitute**
was needed; the probe used the real gate. Fixture: pristine `lane-v`.

Mutant: R24-06's expected digest changed by one hex char,
`…sha256=1259a3e1c170…` → `…sha256=1259a3e2c170…` (expected-ERE column only; command/exit/timeout and
note untouched).

| state | ledger hash | exit | R24-06 line | other FAIL/POLICY | STALE | wall |
|---|---|---|---|---|---|---|
| pristine | `23363843…` | **2** | *(passes)* | R11-08, R25-02; POLICY R29-01, R29-02 | none | 123.5 s |
| mutant | `1f8c82dc…` | **2** | **`FAIL R24-06 reason=verdict-not-final exit=0`** | +R22-03 (exit=1), +R24-15 (exit=2); R11-08, R25-02; POLICY R29-01, R29-02 | `corpus/claim-ledger.tsv sha=23363843b898->1f8c82dc70bb` | 118.1 s |
| restored | `23363843…` | **2** | *(passes)* | R11-08, R25-02; POLICY R29-01, R29-02 | none | 115.0 s |

Receipts: `mut-rowexpect-pristine-verify.txt`, `mut-rowexpect-mutant-verify.txt`,
`mut-rowexpect-restored-verify.txt` (pristine and restored diff-empty). The row's own command on the
pristine bytes prints exactly
`ROW_IDENTITY: scorecard-rounds count=36 sha256=1259a3e1c170d9e3f3aed1d7aabfb1ef08ada83455d373126dbbde3ec20592b5`
(exit 0, `mut-rowexpect-row-command.txt`), which is what the mutated expectation `…a3e2…` no longer
matches.

**Verdict: killable.** The row FAILs with `reason=verdict-not-final exit=0`: the row's own command ran
and exited 0, and its last non-empty line (`ROW_IDENTITY: scorecard-rounds count=36 sha256=1259a3e1…`)
failed the expected ERE — the expectation comparison itself, not an exit drift.

Attribution caveat: the mutant is **not surgically isolated**. `corpus/claim-ledger.tsv` is itself a
stamped artifact, so changing its bytes emits `STALE corpus/claim-ledger.tsv` and cascades to R22-03 and
R24-15 (both stamp/revision-audit rows). The discriminator that keeps the kill honest is the reason
label: R24-06 is `verdict-not-final exit=0` (ERE mismatch on a clean run), while the cascade rows are
`exit-mismatch` (revision-audit refuses a tree whose stamp moved). A fully isolated variant would also
re-pin the `corpus/stamps.tsv` row for the ledger; it was not run because the reason label already
separates the two causes.

---

## Verdicts

| # | counter | mutation attempted | verdict |
|---|---|---|---|
| 1 | `cells` round-heading parse (C1) | Round 27 heading reverted to pre-reshape form (drops `post-move`) | **killable** — setup error, no `CELL_AUDIT`; restored run identical to pristine |
| 2 | `sources-census.sh` capture rows (C2) | (A) wrong row-identity digest, (B) 15-column row, (C) 26-word quote | **killable** — exit 1 + named `SC_FETCH` finding for each; restored CLEAN |
| 3 | `claim-ledger.sh verify` R24-06 (C1) | expected digest off by one hex char | **killable** — `FAIL R24-06 reason=verdict-not-final`; restored verify identical to pristine |

No counter survived. No gate semantics were changed, no expectation was relaxed, and no mutant was left
in place: every mutated file was restored to its snapshot hash before the next probe, and the lane's own
copies of `SCORECARD.md`, `corpus/claim-ledger.tsv`, `corpus/source-fetches.tsv`,
`corpus/claim-ledger.sh`, `corpus/sources-census.sh` still hash to the frozen BASE values above.

## Environment / layout notes (QM22)

- Both probes ran in **lone clones** (no fleet root, no sibling `*-shokunin` lane beside them). The
  pristine `verify` therefore reports `FAIL R11-08 reason=exit-mismatch exit=1 want=0`, a citation-layout
  artifact of the lone tree, not a lane defect; it is identical in pristine and restored and is unrelated
  to all three counters. `cells` in the clone likewise runs under the lone layout.
- No network use beyond nothing: no `curl` was needed (all mutants are local bytes). No credential reads,
  no `op` invocation, no vault/account contact. No installs or upgrades; no pacman transaction was run.
- Scratch `/fast/scratch/hyaku/kagi-r31/MutGates/` was deleted after the receipts above were copied here;
  `/tmp` unused.
- Read-only originals in the lane were never opened for writing; no lane git/jj command was run in the
  lane (clones only), no commit/push anywhere, no `agent://all` message.

## Receipt index (this directory)

`mut-cells-base-setup-error.txt`, `mut-cells-pristine-reshaped.txt`, `mut-cells-heading-mutant.txt`,
`mut-cells-restored.txt`, `mut-census-pristine.txt`, `mut-census-rowdigest.txt`, `mut-census-15col.txt`,
`mut-census-quote26.txt`, `mut-census-restored.txt`, `mut-rowexpect-pristine-verify.txt`,
`mut-rowexpect-mutant-verify.txt`, `mut-rowexpect-restored-verify.txt`, `mut-rowexpect-row-command.txt`,
`mut-hashes-and-states.txt`.
