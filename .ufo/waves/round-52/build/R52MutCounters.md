# R52MutCounters — mutation test of the frozen round-52 counters

Seat: R52MutCounters (leaf). Date: 2026-11-06.
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` @ `52ebb412561d9601ad8658c30d1cfa0087af64d4`,
BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b`.
Detector: `bash <tree>/plans/round-52-controls.sh c1|c2`. A mutant is **KILLED** when at least one
`CONTROL <id>` line differs from the pristine baseline (MISMATCH), **SURVIVED** when all controls
still match. Binary under test: `/home/vgpnk/.local/bin/bao`,
sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`,
`OpenBao v2.7.2 (9e0a0d3c3504a0a00b45e61355afac5e35c78379)` — not read beyond hashing, not replaced.

## Scratch setup and harness verification

- `S=/fast/scratch/hyaku/kagi-r52/R52MutCounters`.
- `$S/lane` = `git clone -q --shared <lane> $S/lane`; `git -C $S/lane rev-parse --show-toplevel`
  printed `$S/lane`, HEAD printed `52ebb41`, `git status --porcelain` empty, `1d984ad` present.
  A clone (not a bare `git archive`) was used because the controls script itself runs
  `git -C "$LANE" archive "$BASE_REV"` for every fixture, so the scratch tree must be a repository;
  its tree is byte-identical to 52ebb412 (`plans/round-52-c1.sh` sha256 `41c0ac3c…a9f1`,
  `plans/round-52-c2.sh` sha256 `82093e0d…c0e0`, both equal to the blobs at 52ebb412).
- Mutant lanes `$S/lane-M1|M2|M3` (C1) and `$S/lane-C2A…C2J` (C2), cloned `--shared` from `$S/lane`;
  each asserted `--show-toplevel` = its own directory and HEAD `52ebb41`.
- Mutations applied only to the scratch copies of `plans/round-52-c1.sh` / `plans/round-52-c2.sh`;
  `bash -n` passed on all 13 mutated scripts. Per-mutant `git diff` receipts:
  `.ufo/waves/round-52/build/R52MutCounters-artifacts/mut-*.diff`; run logs in the same directory.

Baseline (pristine scratch clone, run before any mutant):

```
bash $S/lane/plans/round-52-controls.sh c2  -> rc=0  CONTROLS: match=10 mismatch=0   (56 s)
bash $S/lane/plans/round-52-controls.sh c1  -> rc=0  CONTROLS: match=10 mismatch=0   (3m56 wall, 4 jobs in parallel)
```

The c1 half is 10 controls (K1-0, K1-P, K1-F1…F8), the c2 half 10 (K2-0, K2-P, K2-F1…F8); this
matches the pre-freeze receipt (`.ufo/waves/round-52/controls/controls-prefreeze.txt`, 20 MATCH).

## C2 mutants (`plans/round-52-c2.sh`) — verdicts

| id | mutation (one behaviour-bearing point) | mutant sha256 | killer(s) observed | verdict |
|----|----------------------------------------|---------------|--------------------|---------|
| A | pointer suffix digit check dropped (`rest=…; if (rest !~ /[0-9]/) found=1` → `found=1`) | `3f2b8687…e086` | none (`match=10 mismatch=0`) | **SURVIVED** |
| B | HTML-comment stripping dropped (`{ vis=$0 }`, comment loop removed) | `93cb0de2…e4e` | `K2-F2` (expect 2 got 0), `K2-F8` (expect 1 got 0) — `match=8 mismatch=2` | killed |
| C | GUARD gate dropped (`[ $guard -eq 1 ] \|\| setup` → `:`) | `f93566cd…bb22` | `K2-F4` (expect SETUP got 0) — `match=9 mismatch=1` | killed |
| D | truth-bound literals dropped (`index(t,n1)>0 && index(t,n2)>0` removed) | `ded1fa0a…af86` | `K2-F1` (expect 2 got 0), `K2-F8` (expect 1 got 0) — `match=8 mismatch=2` | killed |
| E | correction prefix accepted anywhere on the line (`index(…)==1` → `>0`) | `6790dc36…9905` | none (`match=10 mismatch=0`) | **SURVIVED** |
| F | `*-verifier-spotcheck.md` exclusion dropped from `scoped()` | `ed7894e1…ccfe` | `K2-0` (2→5) plus `K2-P`, `K2-F1`, `K2-F2`, `K2-F3`, `K2-F5`, `K2-F6`, `K2-F7`, `K2-F8` — `match=1 mismatch=9` | killed |
| G | optional `- ` strip dropped in `assertions()` (`sub(/^- /,"",l)` removed) | `92d9d648…d175` | none (`match=10 mismatch=0`) | **SURVIVED** |
| H | PROBE-failure gate dropped (`[ -n "$OBS_HELPER" ] && … \|\| setup` → `:`) | `a66f7b58…c76b` | none (`match=10 mismatch=0`) | **SURVIVED** |
| I | `./plans/*` exclusion dropped from `scoped()` | `5570b094…d392` | none (`match=10 mismatch=0`) | **SURVIVED** |
| J | correction pointer uses `$f` (relative path) instead of `basename "$f"` | `10f97aad…1b39` | `K2-P` (0→2), `K2-F3` (1→2), `K2-F6` (1→3), `K2-F7` (1→2), `K2-F8` (1→2) — `match=5 mismatch=5` | killed |

Pristine c2 file sha256 `82093e0d…c0e0`; each mutant differs only by the diff receipt above.
Note on procedure: the first B attempt left the awk action block with an unbalanced brace (an awk
syntax error, invisible to `bash -n`); it reported `match=5 mismatch=5`, i.e. a syntax-broken matcher
fails toward *uncorrected* (U inflates, assertions are never hidden). That run was discarded and B
was re-run with a brace-balanced patch; the table reports only the valid run.

## C1 mutants (`plans/round-52-c1.sh`) — verdicts

| id | mutation | mutant sha256 | killer(s) observed | verdict |
|----|----------|---------------|--------------------|---------|
| M1 | NOARGV enforcement dropped (both `noargv=0` assignments removed; `calls` still printed) | `130381c4…2c8d` | `K1-F2` (expect 0 got 5) — `match=9 mismatch=1` | killed |
| M2 | shim-vector identity dropped (`"$sv" = "${EXPECT_VEC[sh$i]}"` → `-n "$sv"`) | `4e90e3a0…073a` | none (`match=10 mismatch=0`) | **SURVIVED** |
| M3 | SRC gate dropped from the final conjunction | `75136ce7…819c` | `K1-F4` (0→5), `K1-F7` (0→5) — `match=8 mismatch=2` | killed |

Pristine c1 file sha256 `41c0ac3c…a9f1`. C1 halves ran four-at-a-time (baseline + M1…M3), wall 3m44–3m56
each; the pristine and mutant runs report identical `value=` lines except at the listed controls, e.g.
M1/K1-F2: `C1_OPENBAO_KV: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noargv=1(real=31,real2=31) …`
where the baseline reads `value=0 discriminating=5 … noargv=0(real=31,real2=31)`.

## Findings (survivors = coverage gaps, each names the missing control)

1. **A — the correction-pointer digit guard is not exercised.** No fixture has an assertion at line N
   and a correction naming `file:N<digit>` (or any pointer whose suffix begins with a digit), which is
   the only case the `rest !~ /[0-9]/` check rejects. K2-F3 points at `:29` for an assertion at `:292`;
   that text no longer contains the full pointer `…:292`, so the guard cannot fire and the mutant is
   invisible. Missing control: fixture with assertion at `:292` plus a false correction naming `:2921`
   (expect the assertion to stay uncorrected).
2. **E — the "correction starts the line" rule is not exercised.** No fixture contains a line that
   merely quotes `Correction (round 52, D1)` mid-line (e.g. inside prose or a log excerpt) that must
   not count as a correction. Missing control: append such a line to a scoped file and expect it not
   to correct anything (`value` unchanged).
3. **G — the optional `- ` bullet form is untested.** Every reference correction starts `Correction…`
   at column 1, so dropping the `sub(/^- /,"",l)` strip in `assertions()` changes nothing. Missing
   control: a bullet-form correction `- Correction (round 52, D1) to file:N …` (expect the assertion
   corrected), and a bullet-form assertion line (expect it counted).
4. **H — PROBE=1 is not gated by any control.** No fixture makes `OBS_HELPER`/`OBS_KV` empty while the
   pin still matches, so deleting the `probe-failed` SETUP changes no control. Missing control: force a
   probe failure with the pinned binary present (e.g. an unwritable `$W/home`, or a `BAO_ADDR` that
   answers nothing) and expect `SETUP reason=probe-failed…`.
5. **I — the `plans/` exclusion cannot be reached by these fixtures.** Fixtures are `git archive`d from
   BASE `1d984ad`, which predates `plans/round-52*.md`; no `plans/*.md` exists in any fixture, although
   `plans/round-52.md:80` would satisfy the assertion pattern (`rewrapped token, which this binary does
   not do`). Missing control: a fixture that adds a `plans/*.md` assertion line and expects it excluded
   (or, if the exclusion is deliberate, an explicit expectation that it does not count).
6. **M2 — the five-verdict shim-vector identity requirement is masked by NOARGV.** K1-F1 (constant
   `HOLDS` printer) and K1-F8 (reads its own stdout path) both produce `shimvec=HHHHH`, but their
   fixtures call no `bao`, so `noargv=0` already forces `value=0`; F1/F8 stay MATCH with the vector
   check deleted. Missing control: a fixture that prints a wrong vector for one falsifier while still
   issuing ≥20 `bao` invocations per real run (expect `value=0` with `noargv=1`), isolating the
   `EXPECT_VEC` requirement.

No contract change is implied by any survivor: they are control-coverage findings for the next round's
freeze, not counter defects demonstrated by a passing control.

## Restoration / side-effect evidence

- Only scratch copies were mutated; `plans/round-52-c1.sh` and `plans/round-52-c2.sh` in the lane are
  byte-identical to their blobs at `52ebb412…` (sha256 `41c0ac3c…a9f1` and `82093e0d…c0e0` on disk and
  `git cat-file -p 52ebb412…:plans/…`); no `git add/commit/checkout/reset/pull/push` was run anywhere.
- `pgrep -af bao | grep -F R52MutCounters` → no output: every throwaway `bao server -dev` this seat
  started was gone after its driver exited (each counter/controls run sets its own cleanup trap; no
  token value was printed, copied or committed).
- Artifacts: baseline and per-mutant logs plus the 13 mutation diffs under
  `.ufo/waves/round-52/build/R52MutCounters-artifacts/` (28 files). No tool was installed or upgraded.

## Commands run (representative, exact)

```
bash $S/lane/plans/round-52-controls.sh c2                        # rc=0, CONTROLS: match=10 mismatch=0
bash $S/lane/plans/round-52-controls.sh c1                        # rc=0, CONTROLS: match=10 mismatch=0
bash $S/lane-C2A/plans/round-52-controls.sh c2                    # rc=0, CONTROLS: match=10 mismatch=0   (SURVIVED)
bash $S/lane-C2B/plans/round-52-controls.sh c2                    # rc=1, CONTROLS: match=8 mismatch=2
bash $S/lane-C2C/plans/round-52-controls.sh c2                    # rc=1, CONTROLS: match=9 mismatch=1
bash $S/lane-C2D/plans/round-52-controls.sh c2                    # rc=1, CONTROLS: match=8 mismatch=2
bash $S/lane-C2E/plans/round-52-controls.sh c2                    # rc=0, CONTROLS: match=10 mismatch=0  (SURVIVED)
bash $S/lane-C2F/plans/round-52-controls.sh c2                    # rc=1, CONTROLS: match=1 mismatch=9
bash $S/lane-C2G/plans/round-52-controls.sh c2                    # rc=0, CONTROLS: match=10 mismatch=0  (SURVIVED)
bash $S/lane-C2H/plans/round-52-controls.sh c2                    # rc=0, CONTROLS: match=10 mismatch=0  (SURVIVED)
bash $S/lane-C2I/plans/round-52-controls.sh c2                    # rc=0, CONTROLS: match=10 mismatch=0  (SURVIVED)
bash $S/lane-C2J/plans/round-52-controls.sh c2                    # rc=1, CONTROLS: match=5 mismatch=5
bash $S/lane-M1/plans/round-52-controls.sh c1                     # rc=1, CONTROLS: match=9 mismatch=1
bash $S/lane-M2/plans/round-52-controls.sh c1                     # rc=0, CONTROLS: match=10 mismatch=0  (SURVIVED)
bash $S/lane-M3/plans/round-52-controls.sh c1                     # rc=1, CONTROLS: match=8 mismatch=2
```
