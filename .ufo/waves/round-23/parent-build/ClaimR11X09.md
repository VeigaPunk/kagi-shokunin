# ClaimR11X09 — semantic audit of ledger row R11-09

Scope: one frozen command obligation, read-only and advisory. I executed nothing: no selftest,
`verify`, `cells`, sibling gate, handler or host probe. I used only `git show`, `grep`,
`sha256sum` and static Python parsing of committed text. I installed or updated no tools; none
were needed. No public source bears on this row, so nothing is quoted.

**Observed revision.** The base is `HEAD` `d218603b74099ddca0bd8f869516fc41db0979bf`.

| File at base | sha256 | Lines / bytes | Stamps row |
|---|---|---|---|
| `corpus/claim-ledger.sh` | `cf56f9ea75d512f6…` | 1428 / 88425 | `corpus/stamps.tsv:4` (matches) |
| `corpus/claim-ledger.tsv` | `e6806968436375870…` | 58 / 17844 | `corpus/stamps.tsv:5` (matches) |

The lane's L1 changed the working tree while I audited. As observed at 2026-10-21T01:01-03:00:

| In-flight file | sha256 prefix |
|---|---|
| `corpus/claim-ledger.sh` | `c20c2d04…` |
| `corpus/lessons/round-23.md` | `d5520988…` |
| `corpus/closure-dispositions.json` | `f20f00d1…` |
| `corpus/closure-dispositions.py` | `6cc82278…` |

The R11-09 and R18-03 row text is byte-identical at base and in-flight. All line citations below
are to the base revision unless marked *in-flight*.

## 1. The obligation as frozen

`corpus/claim-ledger.tsv:23` has four fields:

- **Command:** `bash corpus/claim-ledger.sh --selftest`
- **Expected ERE:** `^SELFTEST: PASS \(121 cases\)`, with no `$` anchor.
- **Exit and timeout:** exit `0`, timeout `300`.
- **Note:** 108 at H1, plus 8 heading visibility/control cases, 2 pre-surface positional cases
  and 3 Round-word/token-boundary cases.

R18-03 (`:50`) is the same command with a `$`-anchored ERE. The two rows always pass or fail
together.

## 2. Causal trace (static)

- **Dispatch.** `--selftest` sets the mode (`:197`). The positional guard is `:222-225`. The
  selftest flag is set at `:1024-1025`. The prelude is `:1031-1038`: `mktemp`, an EXIT trap,
  `unset CLAIM_LEDGER_DEPTH` at `:1037` and `CLAIM_LEDGER_DEPTH_IN=0` at `:1038`.
- **Counting.** `tcase` and `tcase_last` (`:1258-1287`) each add one to `cases` (`:1261`,
  `:1278`). There are 121 top-level calls (`:1291-1424`), none inside a loop or conditional.
- **Verdict.** `SELFTEST: PASS (%d cases)` and `exit 0` are printed only when `failures=0`
  (`:1426`). Otherwise the script prints FAIL and exits 1 (`:1427`). Nothing prints after the
  verdict; the EXIT trap only runs `rm`.
- **As a ledger row.** Under `verify`, the row runs from the repo root as
  `CLAIM_LEDGER_DEPTH=$((IN+1)) timeout -k 5 300 bash -o pipefail -c "$cmd" 2>&1` (`:426`). The
  ERE is matched as a prefix against the last non-empty line of combined stdout and stderr
  (`:436-443`).

**Verdict: supported.** The expected count, last line and exit code all follow from the cases
that actually ran, not from an authored string.

- **Timeout.** 300 s against a measured 2.316 s is about 130× headroom. That only delays hang
  detection and never masks a verdict.
- **Missing `$`.** R11-09's ERE is weaker than R18-03's. For the one printf at `:1426` the two are
  equivalent. Adding `$` for parity is optional.

## 3. Freshness and causality of "121" (historical vs current)

**Expectation history.** Every epoch is committed with its old and new values, so QM14 holds:

- 97: `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:23`
- 97→108: `.ufo/waves/round-22/pin-migrations-integration.json:404-406`
- 108→121: `.ufo/waves/round-22/pin-migrations-falsifier-repairs.json:104-106`

**The 13 added cases.**

- H1 (`8ada17a`) has 108 `tcase` lines; base has 121. The name diff is +13 / −0.
- None of the 108 shared cases changed its assertion text, so no count-preserving weakening
  happened in this epoch.
- The 13 additions match the note's 8 + 2 + 3 split.
- I replayed each new case statically against the H1 parser and argument loop. 12 of the 13 would
  fail there, so they detect the old behaviour. The 13th, `cells-exact-blocked-control`, passes
  under both and is a control by design. This is static inference, not execution.

**Round-22 receipt** (`.ufo/waves/round-22/final-verification.json:53-68`).

- It records bare argv, exit 0, last line `SELFTEST: PASS (121 cases)` and 2.316 s.
- `final-verification-inputs.json` binds `claim-ledger.sh` sha `cf56f9ea…`. That equals the base
  bytes, so this historical receipt still describes the current script.
- `.h1 = 8ada17a` is not the measured commit (spot-check D6 already routes this).
- The receipt's 121 `ok-case` names equal the static case list, in order. That is stronger
  evidence than the count. It was not re-executed this round.

## 4. `[substrate]` deferral — preserved

- The note has no literal `[substrate]`, so the check at `:416` never defers the row. That is
  correct.
- The selftest is scratch-only:
  - every case passes `--root "$R"`;
  - the Python stubs live in `$R`;
  - absolute or `..` paths are refused before any read.
- The three deferral cases force `KAGI_SUBSTRATE` per case (`:1422-1424`). No other fixture row
  is tagged, so a host's `HOME` or `KAGI_SUBSTRATE` cannot change any case verdict.

## 5. SKIP-SELF — bounded, does not discharge R11-09

- **The skip.** `cells` skips any row whose command contains `claim-ledger.sh` (`:816`). R11-09
  and R18-03 are skipped, along with R11-08, R13-03 and R14-01.
- **Cells resting on it.** I emulated `cells()` (`:715-793`) statically over base
  `SCORECARD.md`; I did not run it.
  - Seven Round cells cite R11-09: `:74`, `:95`, `:115`, `:118`, `:193`, `:195`, `:322`.
  - Three of them rest only on skipped rows: `:74`, `:118` (with R13-03) and `:195`.
  - Those three count as `row_pointed`, but nothing is re-run for them. R13-03's ERE accepts any
    `self_skipped` and `rows_run` value.
  - This is a documented bound (`corpus/knowledge/claim-ledger.md:193-197` and bound 26 at
    `:428`), not a defect. But `cells` never discharges R11-09.
- **The selftest proves the skip.** `cells-self-row-skip` (`:1374`) uses R3-01, which is R11-09's
  exact command (`:1131`), in a root that has no script. If the skip were removed, R3-01 would
  exit 127, fail `exit-mismatch`, and the case would catch it.
- **Optional, L1's call.** The skip is broader than bounding needs. `--selftest` never runs `cells`
  or `verify` on the real ledger, so R11-09 and R18-03 could be re-run inside `cells` in about
  2.3 s. Narrowing the skip to rows that run `cells` or `verify` would give `:74` and `:195` an
  executed pointer.

## 6. Hermetic/safe-row mode — does NOT preserve the nested-row obligation

**R11-09's second job.** The code gives R11-09 a second obligation (`:229-235`, `:1032-1036`).
Run as a claim row, it is the regression test that the selftest clears `CLAIM_LEDGER_DEPTH`
(`:1037`). Without that, every inner `"$0" verify` dies at `:236-237`.

**What round 22 actually ran.**

- Round 22 ran R11-09 through the safe-row harness, invoking each row directly
  (`.ufo/waves/round-22/safe-row-plan.json:321`). The receipt records no environment.
- Nothing committed shows `CLAIM_LEDGER_DEPTH=1` was set. [INFERENCE: not set.]
- The only case that sets the variable is `nested-audit-refused` (`:1373`). It tests the refusal,
  not the unset.

**Falsifier** (synthetic, not run). The mutant deletes `:1037`.

- `bash <mutant> --selftest` (safe-row shape): predicted `SELFTEST: PASS (121 cases)`, exit 0. The
  mutant survives, so the receipt reads clean.
- `env CLAIM_LEDGER_DEPTH=1 bash <mutant> --selftest` (the environment `:426` gives the row):
  `claims-pass` (`:1291`) gets exit 2 "refusing a nested self-audit". Predicted
  `SELFTEST: FAIL (k/121 cases)`, exit 1. The mutant is caught.

**Fix.** This needs no code change and adds no host exposure. The safe-row or hermetic runner
should run R11-09 and R18-03 under `verify`'s own contract and record the environment in the
receipt:

- run from the repo root with `CLAIM_LEDGER_DEPTH=1`;
- use `timeout -k 5 300 bash -o pipefail -c "$cmd" 2>&1`;
- take the last non-empty line of the combined stream.

## 7. Consumer-visible false-clean risk: positional IDs (C1 × R11-09)

**What D3 requires.** D3 (`corpus/lessons/round-22-verifier-spotcheck.md:170-172`) says the guard
must reject the exact tokens `revision` and positional ids under a selftest case id. The
round-22 incident was exactly ignored positional IDs causing a full run
(`.ufo/waves/round-22/review-evidence-quarantine-closure.json:6`).

**Observed at base.**

- `mode-unknown-revision` (`:1292`) passes `revision`.
- `verify-extra-positional` (`:1293`) passes `extra`.
- No case passes an id-shaped (`R<d>-<d>`) positional to any mode; a grep finds 0.
- The guard (`:222-225`) rejects any positional today. The behaviour is correct; the test for the
  id token is missing.

**Refuted in-flight claim.**

- *In-flight* `corpus/lessons/round-23.md:84-89` says positional ids are "already exercised by the
  ledger selftest case `mode-unknown-revision`". The argv at `:1292` contradicts that.
- *In-flight* `closure-dispositions.json` marks D3 `fixed`, pointing at a lesson anchor.
  `closure-dispositions.py:104-118` checks only that the file exists, has the heading and names
  the id. C1 CLEAN therefore cannot see this gap.

**Falsifier** (synthetic, not run). The mutant replaces the test at `:223-224` with:

```
for p in "${POS[@]}"; do [[ $p =~ ^R[0-9]+-[0-9]+$ ]] || die "unexpected positional argument for $MODE"; done
```

This ignores id-shaped tokens, which is H1's behaviour for ids. Predicted: all 121 verdicts are
unchanged, because only `:1292` and `:1293` pass positionals to these modes and neither is
id-shaped. R11-09 and R18-03 pass and D3 stays CLEAN. Yet
`bash corpus/claim-ledger.sh verify R11-01` again runs all 43 rows, including the 12
host/transitive ones.

**Fix for L1** (not applied). Add this case:

```
tcase verify-positional-id-refused 2 'unexpected positional argument for verify' "$0" verify R1-01 --root "$R" --claims "$S/nope.tsv" --stamps "$R/stamps.tsv"
```

- On base, the guard dies at `:224`, before `:228` and before any read, so the case passes.
- Under the mutant, or with any guard moved after reads, the run reaches `verify_claims` and dies
  "claims file not found". The substring no longer matches, so the case fails.
- Because the claims file is absent, no claim row can execute under any mutant.

Then complete the follow-ups:

1. Migrate R11-09 and R18-03 together from 121 to 122, with a QM14 old/new record.
2. Name the new case in D3's note and pointer.
3. Expect the receipt's stdout to contain `ok-case N verify-positional-id-refused exit=2`.

## 8. What C3 and C1 integration must retain for this row

**C3**

1. *In-flight* R23-01 (`claim-ledger.tsv:59`) uses fixture rows R90-01 and R90-02 with
   `self_skipped=0`. It neither runs nor skips R11-09, so R23-01 CLEAN is not evidence for
   R11-09. R11-09 is still discharged only by its own safe-row run, with the environment from §6.
2. Keep `cells-self-row-skip` and `nested-audit-refused` in the selftest. They are the only
   executed proof of the skip and nesting bounds.
   - Don't read the fixture's `self_skipped=0` as a statement about the real scorecard. At base,
     real `cells` would skip five rows: R11-08, R11-09, R13-03, R14-01 and R18-03 (static
     emulation).
3. Any new `claim-ledger.sh` selftest case must move R11-09 and R18-03 together.

**C1**

4. Apply the D3 fix in §7.
5. *In-flight* `PYTHON_SCRIPT_RE` (`claim-ledger.sh:161`) now admits
   `corpus/closure-dispositions.py`, but no selftest case allows it. The *in-flight* case count is
   still 121.
   - The existing pattern is one allow case per script (`:1300-1301`).
   - If the safe-row runner bypasses `policy_check` [INFERENCE from the receipt's fields], nothing
     executed in round 23 shows that `verify` admits R23-02.
   - A regex slip would make `verify` exit 2 with `CLAIM_LEDGER: POLICY` for the whole ledger
     (`:974`).
   - Add `policy-python-closure-allowed` and migrate the count by one more.
6. A C1 `fixed` pointer cannot point at a `tcase` line, because the anchor rule needs a `#` line.
   For selftest-backed fixes, cite case names that can be checked in the R11-09 receipt's
   `ok-case` list, as §3 does for all 121 names. "121 cases" alone is not closure evidence.

## 9. Other latent observations (low; trigger not observed)

- **`SELFTEST` is never initialized.** Only `:1025` assigns it, and `:1030` reads
  `${SELFTEST:-0}`.
  - If a runner exported `SELFTEST=1`, every mode would append a full selftest, and the children
    would recurse.
  - The result would be a false R11-09 timeout failure, and R11-08 and R14-01 would end on the
    wrong last line.
  - Fix: initialize `SELFTEST=0` alongside the other globals (`:103-112`).
- **Executable bit.** Every case executes `"$0"` directly (`:1291-1424`), so R11-09 depends on the
  committed 100755 mode. `corpus/stamps.tsv` pins only sha, lines and bytes, not the mode. A copy
  that drops `+x` turns all 121 cases into exit 126, which is a false failure.

## 10. Limits

- Nothing was executed. Every predicted verdict comes from static code-path reasoning; the only
  executed evidence is the round-22 receipt.
- The safe-row harness code is not committed. Its environment and whether it applied policy are
  inferred from receipt shape and plan text.
- The in-flight tree was changing during this audit. In-flight facts are labelled and
  hash-stamped above; they are not frozen evidence.
