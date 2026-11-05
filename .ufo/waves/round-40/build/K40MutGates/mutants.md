# K40MutGates — mutation receipts (round 40)

Candidate: `cb3f642479a09644a03874909bb7e44b52697a8d` (lane master HEAD; read with
`git -C <lane> rev-parse HEAD`). Controls BASE: predeclaration `f687504767ce9ed56b848dfde83e03a1ec6cedd3`
(the pre-freeze gate ran against `--base <predec>`). Lane tree never written; candidate and BASE were
read via `git -C <lane> archive <rev> | tar -x -C <scratch>`. Git calls in the lane were read-only
(`rev-parse`, `archive`, `cat-file`, `show`, `branch --show-current`). Scratch tree
`/fast/scratch/hyaku/kagi-r40/K40MutGates` (deleted at finish). Mutant sources: `mutants/`.
Diffs against the candidate: `mutant-diffs.txt` (166 lines). Syntax: `mutant-syntax.txt` (17 × ok).

## 0. Honest reproduction at the candidate

| Instrument | Command (cwd = scratch copy of candidate) | Output | rc | Target | Verdict |
|---|---|---|---|---|---|
| C1 counter | `timeout 600 bash plans/round-40-c1.sh` (elapsed 330 s, stderr 0 bytes) | `0` | 0 | 0 | reproduced (`c1-candidate.stdout`) |
| C2 counter | `bash plans/round-40-c2.sh` | `3` | 0 | 3 | reproduced |
| C3 counter | `bash plans/round-40-c3.sh` | `2` | 0 | 2 | reproduced |
| anchor-pins selftest | `bash corpus/anchor-pins.sh --selftest` | `ANCHOR_PINS_SELFTEST: PASS (8 cases)` | 0 | 8 | PASS |
| claims-declared selftest | `bash corpus/claims-declared.sh --selftest` | `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)` | 0 | 8 | PASS |
| anchor-pins real | `bash corpus/anchor-pins.sh --root .` | `ANCHOR_PINS: CLEAN (pins=4)` | 0 | — | CLEAN |
| claims-declared real | `bash corpus/claims-declared.sh --root .` | `CLAIMS_DECLARED: CLEAN (claims=5)` | 0 | — | CLEAN |

Ledger context for C1 (`bash corpus/claim-ledger.sh verify`, copy of candidate, 330 s, `ledger-verify-candidate.txt`):
exit 2, last line `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=122)`. None of the six debt ids
(R13-01, R21-02, R24-06, R31-02, R33-02, R34-03) appears on any FAIL/STALE/MISSING/MISSING-ID line, so
the frozen count is 0. Out-of-population lines present: `FAIL R11-08`, `FAIL R22-03`, `FAIL R24-15`,
`FAIL R25-02`, `FAIL R36-03`, `POLICY R29-01`, `POLICY R29-02`, `POLICY R38-03`, and `STALE` for eight
stamped files (see §5, O1).

## 1. Gate mutants (`corpus/anchor-pins.sh`, `corpus/claims-declared.sh`)

Selftest battery = each mutant's own `--selftest` (`selftests-mutants.txt`). Real-tree = mutant run with
`--root <candidate>` (`real-tree-gate-mutants.txt`).

| # | Mutant | Mutation | Selftest output (exact) | Verdict | Real-tree at candidate |
|---|---|---|---|---|---|
| G1 | ap-nodup | dup check (lines 134–138) cut | `SELFTEST-FAIL dup-row rc=0 out=ANCHOR_PINS: CLEAN (pins=3)` / `ANCHOR_PINS_SELFTEST: FAIL (passed=7/8)` rc=1 | CAUGHT (selftest) | `CLEAN (pins=4)` rc 0 — defect absent on real tree, equal |
| G2 | ap-noshape | shape check (139–143) cut | `SELFTEST-FAIL tab-indent rc=0 out=ANCHOR_PINS: CLEAN (pins=3)` / FAIL (passed=7/8) rc=1 | CAUGHT (selftest) | CLEAN rc 0 |
| G3 | ap-noschema | schema check (144–148) cut | `SELFTEST-FAIL extra-cell rc=0 out=ANCHOR_PINS: CLEAN (pins=3)` / FAIL (passed=7/8) rc=1 | CAUGHT (selftest) | CLEAN rc 0 |
| G4 | ap-nonewline | `|| [ -n "${id:-}" ]` dropped from read (111) | `SELFTEST-FAIL no-final-newline rc=0 out=ANCHOR_PINS: CLEAN (pins=2)` / FAIL (passed=7/8) rc=1 | CAUGHT (selftest) | CLEAN (pins=4) rc 0 — equal on real tree |
| G5 | ap-const-clean | `echo CLEAN (pins=4); exit 0` inserted before real check | seven `SELFTEST-FAIL …` lines with `rc=0 out=ANCHOR_PINS: CLEAN (pins=4)`, `SELFTEST-FAIL constant-mutant real=0 mutant=0`, `ANCHOR_PINS_SELFTEST: FAIL (passed=0/8)` rc=1 | CAUGHT (selftest) | CLEAN rc 0 (constant CLEAN is correct on the clean tree; the selftest is the only detector) |
| G6 | cd-nodup | dup-row check (127–131) cut | `SELFTEST-FAIL dup-row rc=0 out=CLAIMS_DECLARED: CLEAN (claims=3)` / FAIL (passed=7/8) rc=1 | CAUGHT (selftest) | CLEAN (claims=5) rc 0 |
| G7 | cd-nofence | fence toggle (135) cut | `SELFTEST-FAIL fence-heading rc=0 out=CLAIMS_DECLARED: CLEAN (claims=2)` / FAIL (passed=7/8) rc=1 | CAUGHT (selftest) | CLEAN (claims=5) rc 0 |
| G8 | cd-nowindow | tag count without section window (`insec &&` removed, line 152) | `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)` rc=0 | **SURVIVED selftest** (see §3.1) | **MISMATCH ×4**: `MISMATCH 39 C1 tagged-rows-2`, `MISMATCH 39 C2 tagged-rows-2`, `MISMATCH 40 C1 tagged-rows-2`, `MISMATCH 40 C2 tagged-rows-2`; `CLAIMS_DECLARED: MISMATCH (claims=5 mismatch=4)` rc 1 — a false red, not a false clean |
| G9 | cd-padded | padded axis cell trimmed before compare (161) | `SELFTEST-FAIL padded-cell rc=0 out=CLAIMS_DECLARED: CLEAN (claims=2)` / FAIL (passed=7/8) rc=1 | CAUGHT (selftest) | CLEAN (claims=5) rc 0 |
| G10 | cd-const-clean | `echo CLEAN (claims=5); exit 0` before manifest read | seven `SELFTEST-FAIL` lines `rc=0 out=CLAIMS_DECLARED: CLEAN (claims=5)`, `constant-mutant real=0 mutant=0`, `CLAIMS_DECLARED_SELFTEST: FAIL (passed=0/8)` rc=1 | CAUGHT (selftest) | CLEAN rc 0 |

## 2. Counter mutants (C1, C2, C3)

Control battery = `BASE=<tree> bash <tree>/plans/round-40-controls.sh <mode>` (the frozen runner), with the
mutant placed at the counter path of a copy of the predeclaration (`mb-*` trees, scratch). Output in
`controls-battery.txt`. Honest predeclaration rows (no mutant) match their frozen expectations: C2
`c2_nowork 0`, `c2_positive_pin 1`, `c2_forge_rows 1`; C3 `c3_nowork 0`, `c3_selftest_anchor 8`,
`c3_selftest_claims 8`, `c3_forge_missing_gate 0`.

| # | Mutant | Battery output (exact, expect in parens) | Battery verdict | Landing (candidate) value | Verdict |
|---|---|---|---|---|---|
| C1a | c1-echo0 (`echo 0`) | `c1-echo0 c1_nowork out=[0] rc=0` (6) | CAUGHT (pre-freeze control only) | `0` = target | CAUGHT at BASE; SURVIVES the landing target (§3.5) |
| C1b | c1-echo6 (`echo 6`) | `c1-echo6 c1_nowork out=[6] rc=0` (6) | **SURVIVED** all frozen controls (no constant-6 control exists) | `6` ≠ 0 target | CAUGHT only by the landing target (§3.6) |
| C2a | c2-const3 (`echo 3`) | `c2_nowork out=[3]` (0); `c2_positive_pin out=[3]` (1); `c2_forge_rows out=[3]` (1) | CAUGHT ×3 | `3` = target | CAUGHT at BASE; not at landing |
| C2b | c2-nosha (sha equality dropped, line 49) | `c2_nowork out=[0]` (0); `c2_positive_pin out=[1]` (1); `c2_forge_rows out=[1]` (1) | **SURVIVED** ×3 | `3` (see probe P-sha) | SURVIVED controls; CAUGHT by probe P-sha (§3.2) |
| C2c | c2-noquote (quote location dropped, lines 51–60) | `c2_nowork out=[0]`; `c2_positive_pin out=[1]`; `c2_forge_rows out=[1]` | **SURVIVED** ×3 | `3` (see probe P-quote) | SURVIVED controls; CAUGHT by probe P-quote (§3.3) |
| C3a | c3-const2 (`echo 2`) | `c3_nowork out=[2]` (0); `c3_forge_missing_gate out=[1]` (0); `c3_selftest_*` out=[8] (unaffected) | CAUGHT ×2 | `2` = target | CAUGHT at BASE; not at landing |
| C3b | c3-noselftest (selftest execution removed, lines 34–39) | `c3_nowork out=[0]` (0); `c3_forge_missing_gate out=[0]` (0) | **SURVIVED** ×2 (the `c3_selftest_*` controls exercise the gates, not the counter) | `2` (see probe P-c3) | SURVIVED controls; CAUGHT by probe P-c3 (§3.4) |

## 3. Probes for surviving defects (scratch copies of the candidate)

Commands run exactly as listed; outputs verbatim (`probes-gates-and-counters.txt`, `probes-quote.txt`).

### 3.1 P-window — claims-declared tag-outside-section (for G8)
Fixture: `fixtures/claims-declared-window/` (manifest `90 C1 freshness`; tag `[C1]` only in the
`## Round 89 — post-move` row; the `## Round 90 — post-move` section has no tag).
- real: `bash corpus/claims-declared.sh --root <fixture>` → `MISMATCH 90 C1 tagged-rows-0` / `CLAIMS_DECLARED: MISMATCH (claims=1 mismatch=1)` rc 1
- G8 mutant: `bash cd-nowindow.sh --root <fixture>` → `CLAIMS_DECLARED: CLEAN (claims=1)` rc 0
⇒ CAUGHT by this fixture; the shipped selftest (8 cases) cannot distinguish the two.

### 3.2 P-sha — tampered capture body (for C2b)
`printf 'x' >> S095.body` (one byte, fetch-row sha now mismatches); mutant copied to the same tree.
- real `bash plans/round-40-c2.sh` → `2` rc 0
- `c2-nosha` → `3` rc 0
- `c2-noquote` (sha check intact) → `2` rc 0
⇒ CAUGHT by probe (2 ≠ 3).

### 3.3 P-quote — located quote removed from row (for C2c)
Scratch copy of `corpus/SOURCES.md`, line 102 (S095 row) changed `whitespace characters` → `zebra characters` in the
quote; fetch sha unchanged (`fixtures/quote-probe-S095.diff`).
- real `bash plans/round-40-c2.sh` → `2` rc 0
- `c2-noquote` → `3` rc 0
⇒ CAUGHT by probe (2 ≠ 3).

### 3.4 P-c3 — broken registered selftest (for C3b)
Anchor-pins gate replaced in a scratch copy by the constant-CLEAN mutant (its selftest FAILs).
- real `bash plans/round-40-c3.sh` → `1` rc 0
- `c3-noselftest` → `2` rc 0
⇒ CAUGHT by probe (1 ≠ 2).

### 3.5 Landing-target survivor for `echo 0` (C1a)
The candidate's honest value is 0, so `c1-echo0` prints exactly the landing value. The only catcher is the
pre-freeze control `c1_nowork` (BASE expects 6). Nothing re-runs a BASE control at landing.

### 3.6 `echo 6` (C1b) against the landing target
`c1-echo6` prints 6 at the candidate; the target is 0 ⇒ fails the landing kill rule. It passes every
frozen BASE control because no control is a constant 6.

### 3.7 Latent C1 population defect (not one of the assigned mutants; found while reading the counter)
`plans/round-40-c1.sh` matches ids with `grep -q " $id "` (trailing space required). Verify prints several
ids at end-of-line (e.g. `MISSING-ID corpus/lessons/round-37.md:7 R36-1`). Exact pipeline probe:
- `printf 'MISSING-ID corpus/lessons/x.md:3 R13-01\n…' | grep -E '^(FAIL|STALE|MISSING|MISSING-ID)' | grep -q " R13-01 "` → rc 1 (NOT counted)
- `printf 'FAIL R13-01 reason=exit-mismatch exit=1 want=0\n' | …` → rc 0 (counted)
At the candidate no six-id line exists, so no current number is affected; the defect is latent (a future
end-of-line MISSING-ID for a debt id would be undercounted to a false 0). No frozen control covers it.

## 4. Surviving defects — summary

| ID | Instrument / mutant | Survived | Caught by | What would catch it in the battery |
|---|---|---|---|---|
| S-1 | claims-declared `cd-nowindow` (G8) | claims-declared selftest 8/8 PASS | P-window (CLEAN vs MISMATCH) | add a selftest case: tag only in a previous round's section, expect `tagged-rows-0` |
| S-2 | C2 `c2-nosha` (C2b) | all 3 frozen controls | P-sha (2 vs 3) | control `c2_tampered_body` (one byte appended to a committed capture; expect 2) |
| S-3 | C2 `c2-noquote` (C2c) | all 3 frozen controls | P-quote (2 vs 3) | control `c2_absent_quote` (quote changed, sha intact; expect 2) |
| S-4 | C3 `c3-noselftest` (C3b) | `c3_nowork`, `c3_forge_missing_gate` | P-c3 (1 vs 2) | control `c3_broken_selftest` (a registered gate whose selftest fails; expect 1) |
| S-5 | C1 `c1-echo0` | landing target (0 = 0); constant-0 control runs only the driver's own mutant | pre-freeze `c1_nowork` (0 ≠ 6) | a landing-time check of the counter's integer against an independent count of the six ids' non-PASS lines in verify output |
| S-6 | C1 `c1-echo6` | all frozen BASE controls | landing target (6 ≠ 0) | control `c1_mutant_six` (constant 6 vs landing target 0) |
| S-7 | C1 latent end-of-line id match (§3.7) | no control | direct pipeline probe only | control: a verify fixture with `MISSING-ID … R13-01` as the last token; expect 1 |

Assigned mutants caught by their selftests with no survivor: G1–G7, G9, G10 (§1). Real-tree behaviour of
G1–G7, G9, G10 is identical to the candidate's (the defect is not present on the real tree), so their only
detector is the selftest; a selftest regression would therefore be silent on the real tree.

## 5. Observations (not mutants; reported as found)

- **O1 — candidate stamps are stale.** At cb3f642 the committed `corpus/stamps.tsv` row for
  `corpus/laneguard.sh` is `7ca9fcabb7c4…`, while the committed file is `99eeb50a9083…` (checked by
  `sha256sum` of the archive and `git show cb3f642:corpus/laneguard.sh`). `verify` reports `STALE` for
  eight stamped files (claim-ledger.tsv, laneguard.sh, QUALITY.md, source-fetches.tsv, SOURCES.md, LOG.md,
  SCORECARD.md, SKILL.md) and exits 2 with `CLAIM_LEDGER: POLICY`. The frozen C1 population excludes these
  by design, and the counter still prints an integer when the summary line exists (no check on the verify
  verdict). Read as a calibration ceiling of C1: the counter reports only its six-row population.
- **O2 — counter does not check verify's verdict or exit.** `plans/round-40-c1.sh` refuses only when no
  `CLAIM_LEDGER:` line exists; `POLICY` or rc 2 still yields an integer (above).

## 6. Tools installed

None. No package, binary, or runtime was installed or upgraded. (`pacman` paused per the host guard;
none attempted.)

## 7. Execution notes

- The C1 counter and the verify run (330 s each) were issued as foreground bash calls with `timeout 600`;
  the harness moved both to system background jobs (`bg_5674`, `bg_5675`) after 60 s. I did not spawn,
  poll, or sleep on any job; results were delivered by the harness.
- Fixture edits: the S095 quote change and the window fixture were applied with the `edit`/`write` tools
  to scratch copies only. The one-byte tamper for P-sha was an append (`printf 'x' >>`) to a scratch copy.
- Mutant scripts: `mutants/` (17 files; `ap-*`, `cd-*`, `c1-echo0/echo6`, `c2-const3/nosha/noquote`, `c3-const2/noselftest`).
