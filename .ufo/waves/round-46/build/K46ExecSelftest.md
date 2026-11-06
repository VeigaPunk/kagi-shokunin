# K46ExecSelftest — round 46 C1 candidate draft (`claims-declared.sh --selftest`)

Seat: K46ExecSelftest (executor, leaf). Assignment: C1 candidate draft in scratch — new
`--selftest` cases in `corpus/claims-declared.sh` for the round-45 plan-to-manifest leg.
C2 is outside this seat; no C2 claim is made here.

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
- BASE `f5977284a8ce5bab09252be8196ee5dc18489926`; predeclaration `44808ced56359c98f35995178fb24a6482899263`
  (lane HEAD when read).
- The lane tree was **not** edited: `git status --porcelain -- corpus/claims-declared.sh` printed nothing,
  rc 0. HEAD stayed `44808ce…`.
- Measured tree: `git archive 44808ce… | tar -x` into `$S/tree`, with
  `$S=/fast/scratch/hyaku/kagi-r46/K46ExecSelftest`. The only byte difference from the
  predeclaration is `corpus/claims-declared.sh`: base sha256 `ec0adffe…` (238 lines), patched
  sha256 `8053c85a…` (254 lines).

## Change — only inside the `--run-selftest` block

Three fixture cases, all run through the gate behaviourally (no grep of the gate's bytes):

- **case 9** `no-manifest-row`: `mfix`, then the manifest keeps only `90 C1 freshness` while
  `plans/round-90.md` and the round-90 post-move section keep the C2 heading. The landed round's
  C2 plan heading has no manifest row → expect rc 1 and `MISMATCH 90 C2 no-manifest-row`.
- **case 10** `in-flight-round`: `mfix` plus `plans/round-91.md` with a `## C1 — freshness:` heading
  and no `## Round 91 — post-move` section and no manifest row → the round is in flight, expect
  rc 0 and `CLAIMS_DECLARED: CLEAN (claims=2)`.
- **case 11** `landed-floor`: `mfix` plus a landed round 39 (plan heading + `## Round 39 — post-move`
  section, no manifest row) → the floor is inclusive, expect rc 1 and
  `MISMATCH 39 C1 no-manifest-row`.
- `mfix` now removes the two synthetic plan files (`rm -f "$s/plans/round-39.md"
  "$s/plans/round-91.md"`), so every fixture reset — existing and new cases alike — starts from the
  same lane; case order is no longer load-bearing for these files.
- `chk`'s named ceiling is stated in the block: it checks rc plus one token, so a mutant that also
  prints the expected token (with spurious extra output) is not refused here.
- Case-count assertion moved `8 → 11`, and the PASS line now prints the count from `$cases`
  (`printf 'CLAIMS_DECLARED_SELFTEST: PASS (%d cases)\n' "$cases"`), leaving the literal count in
  one place; the FAIL line is unchanged.

## Measurements (verbatim; transcripts in `receipts.txt`)

Baseline on the pristine predeclaration tree (`$S/tree-base`):

```
C1_SELFTEST_KILLS: value=0 killed=0 positive=1 equiv=1 real=1 (rc e1=0 e2=0 e3=0 e4=0 m1=0 m2=0 m3=0; selftest-rc=0 selftest-last='CLAIMS_DECLARED_SELFTEST: PASS (8 cases)'; real-rc=0 real-last='CLAIMS_DECLARED: CLEAN (claims=17)')
rc 0
CLAIMS_DECLARED_SELFTEST: PASS (8 cases)
rc 0
CLAIMS_DECLARED: CLEAN (claims=17)
rc 0
```

Patched tree:

```
C1_SELFTEST_KILLS: value=3 killed=3 positive=1 equiv=1 real=1 (rc e1=0 e2=0 e3=0 e4=0 m1=1 m2=1 m3=1; selftest-rc=0 selftest-last='CLAIMS_DECLARED_SELFTEST: PASS (11 cases)'; real-rc=0 real-last='CLAIMS_DECLARED: CLEAN (claims=17)')
rc 0
```

```
CLAIMS_DECLARED_SELFTEST: PASS (11 cases)
rc 0
CLAIMS_DECLARED: CLEAN (claims=17)
rc 0
```

`bash -n corpus/claims-declared.sh` rc 0. `git show 44808ce…:corpus/claims-declared.sh | diff -u -
<patched>` rc 1 (files differ; expected).

## Diff confinement

The diff is three hunks: `@@ -38,6 +38,7 @@`, `@@ -68,6 +69,8 @@`, `@@ -99,8 +102,21 @@`.
In the base file the `--run-selftest` block is lines 36–108 (`manifest=` starts at 109); in the
patched file it is lines 36–124 (`manifest=` starts at 125). Changed base lines 38–43, 68–73,
99–106 and patched lines 38–44, 69–76, 102–122 therefore all lie inside the `--run-selftest`
block. **The diff stays inside the selftest block**; the plan-to-manifest loop
(the bijection code) is byte-identical, and the per-mutant diffs in `receipts.txt` show each frozen
sed program still hits exactly its intended region (E1 header/comment, E2 floor, E3 echo, E4
post-move test; M1 echo+bad line, M2 floor, M3 post-move test).

## Kill / equivalence evidence (per-mutant `--selftest`)

```
e1 rc=0 CLAIMS_DECLARED_SELFTEST: PASS (11 cases)
e2 rc=0 CLAIMS_DECLARED_SELFTEST: PASS (11 cases)
e3 rc=0 CLAIMS_DECLARED_SELFTEST: PASS (11 cases)
e4 rc=0 CLAIMS_DECLARED_SELFTEST: PASS (11 cases)
m1 rc=1 SELFTEST-FAIL no-manifest-row rc=0 out=CLAIMS_DECLARED: CLEAN (claims=1)
       SELFTEST-FAIL landed-floor rc=0 out=CLAIMS_DECLARED: CLEAN (claims=2)
       CLAIMS_DECLARED_SELFTEST: FAIL (passed=9/11)
m2 rc=1 SELFTEST-FAIL no-manifest-row rc=0 out=CLAIMS_DECLARED: CLEAN (claims=1)
       SELFTEST-FAIL landed-floor rc=0 out=CLAIMS_DECLARED: CLEAN (claims=2)
       CLAIMS_DECLARED_SELFTEST: FAIL (passed=9/11)
m3 rc=1 SELFTEST-FAIL no-manifest-row rc=0 out=CLAIMS_DECLARED: CLEAN (claims=1)
       SELFTEST-FAIL in-flight-round rc=1 out=MISMATCH 91 C1 no-manifest-row
       SELFTEST-FAIL landed-floor rc=0 out=CLAIMS_DECLARED: CLEAN (claims=2)
       CLAIMS_DECLARED_SELFTEST: FAIL (passed=8/11)
```

`chk` asserts rc **and** a token, so M3 is caught by rc (it reports where the real gate is silent
and is silent where the real gate reports). Round 39 is the floor boundary: the real gate checks it,
M2's floor 99 skips it, and E2 (`-le 38`) checks it identically, so one fixture serves the kill and
the equivalence leg; M2/case 9 (round 90) is likewise skipped by floor 99.

## Risks, ceilings, notes

- The new cases use fixture text only; they do not read lane files, and the selftest scratch is
  under `HYAKU_SCRATCH` (`$S/...`), never the host default.
- K46Connector's static-audit residues were applied at the candidate: the count duplication is
  gone (PASS derives from `$cases`), `chk`'s presence-only ceiling is stated in the block, and
  `mfix` resets the synthetic plan files so a case inserted later cannot inherit `round-91.md`.
- Not covered by this draft: fenced/HTML-comment heading treatment inside the plan-to-manifest leg
  (the frozen mutants do not exercise it). The plan's named C1 ceiling stands: a self-test keyed on
  another byte property than E2–E4 is not refused by the counter; the diff review remains the leg.
- Drafting note: my private mutant driver first transcribed E4 without the leading `!`; the frozen
  program was then verified byte-exact with `cat -A` against `plans/round-46-c1.sh` and the driver
  corrected. The final measurement and the quoted e4 diff use the exact frozen program
  (`if ! awk … ${rname}`).
- No tool was installed or upgraded. No mutating git/jj command ran; the only git use was
  `archive`, `show`, `status --porcelain` and `rev-parse`.

## Files

- `.ufo/waves/round-46/build/K46ExecSelftest/claims-declared.sh` — patched gate, sha256
  `8053c85a777c533554ce4509b40d893335fe6c8586f8617fd5c8d12a4e9d66a8`, mode 755.
- `.ufo/waves/round-46/build/K46ExecSelftest/claims-declared.diff` — `diff -u` base → patched.
- `.ufo/waves/round-46/build/K46ExecSelftest/receipts.txt` — every command, rc and last line
  (base counter/selftest/real, patched counter/selftest/real, diff, `bash -n`, per-mutant evidence,
  lane cleanliness, sha256, block bounds).

SEAT-STATUS: complete
