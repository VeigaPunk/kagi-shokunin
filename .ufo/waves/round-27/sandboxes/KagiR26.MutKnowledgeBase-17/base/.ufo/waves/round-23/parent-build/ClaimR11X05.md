# ClaimR11X05 — R11-05 `drift-pins.sh --selftest` (semantic audit)

Seat: ClaimR11X05 (leaf, read-only). Base/HEAD read: `d218603b74099ddca0bd8f869516fc41db0979bf`
(2026-10-20T21:11:59-03:00, "round-22 verifier spot-check (integrator, hyaku): non-author
admit/reject"). Row owner: this seat only; no judgment/admission authority claimed.
No installs were needed (nothing recorded). No gate, handler, `op`, vault or host command was
executed; no production file was modified. Everything below is static read of committed bytes
plus read-only `git rev-parse` / `sha256sum` / `wc` / `grep` measurements.

## 1. The obligation as frozen

`corpus/claim-ledger.tsv:19`
```
R11-05  bash corpus/drift-pins.sh --selftest
        ^DRIFT_SELFTEST: PASS \(13 cases\)   0   300
        drift selftest, case count pinned
```

How the ledger actually consumes it (`corpus/claim-ledger.sh:424-444`): run the command with
`cd "$ROOT"`, `timeout -k 5 300`, capture stdout+stderr, drop blank lines, take the **last**
line, then Bash-regex match against `expect`; exit must equal `want` exactly. A timeout
(124/137) is a FAIL, not a defer.

## 2. Is the expectation justified? — supported (calibrated)

| element | evidence | verdict |
|---|---|---|
| `13 cases` | `corpus/drift-pins.sh:374-438` has exactly 13 `run "…"` calls (`grep -c '^  run "'` = 13); the count is emitted by `printf 'DRIFT_SELFTEST: PASS (%d cases)' "$cases"` at :444 | supported |
| PASS-gating is causal, not decorative | `cases` increments per `run` call (:399); `fails` increments on any exit or verdict mismatch (:402,:404); the PASS branch (:444) is reachable only when `fails==0` — so `PASS (13 cases)` entails "all 13 `run` bodies executed and none observed a mismatch" | supported |
| `exit 0` | `selftest` returns 0 on PASS (:445), 1 on FAIL (:442); no other exit path under `set -euo pipefail` except setup death (see §8) | supported |
| `^…PASS` start anchor | the FAIL branch prints `DRIFT_SELFTEST: FAIL (n/13 cases)` (:442), which cannot match the PASS ERE | supported (no cross-branch acceptance) |
| `timeout 300` | only observed executed receipt: `.ufo/waves/round-22/final-verification.json:6-20` — `seconds: 0.205`, stdout exactly `DRIFT_SELFTEST: PASS (13 cases)\n`, stderr empty, exit 0. 13 calls each re-enter the script over 3 scratch baseline + 4 scratch symbol rows with `stat`/`wc`/`sha256sum` | justified with ~1400x headroom |

The last-line rule cannot be satisfied by a *trailing* cleanup message: the only statement after
PASS is `return 0` plus the `RETURN` trap `rm -rf "$d"` (`:377`), which prints nothing.

## 3. Historical vs current evidence

- **Row**: byte-identical since creation at `301b9ec` (round-11). Verified at `301b9ec`,
  `4be5da3`, and `HEAD`; only one commit in `git log -S` history. Not a stale assertion.
- **Gated artifact**: `corpus/drift-pins.sh` blob is `8a2903dc977a1ef6ea0430b21d1760392ccc2827`
  at `4be5da3`, `8ada17a5`, and `HEAD` — identical. `sha256` = `c138d34c…e6c70feb`, 451 lines,
  matching the knowledge entry's pointer (`corpus/knowledge/drift-gate.md:2-4`).
- **Receipt**: `.ufo/waves/round-22/final-verification.json:6-20` is an *executed* pass, but its
  file-level `.h1` is `8ada17a5` while the measured run is `4be5da3` (defect D6 in
  `corpus/lessons/round-22-verifier-spotcheck.md:177-179`). For this row the mislabel is
  causally immaterial (script bytes identical at both commits) but the receipt itself binds no
  digest of `drift-pins.sh` — its provenance is `argv` + observed stdout only. Treat the
  receipt as *historical evidence for byte-identical input*, not as a current run.
- **Docs at HEAD**: `drift-gate.md:189-193` enumerates the 13 case names and matches the script
  exactly; `drift-gate.md:88,170` show the same PASS form. The `Reverify: R11-04, R11-05` line
  (`drift-gate.md:9`) resolves (`corpus/claim-ledger.sh:861-880` doc audit path). Doc pointers
  are current, not stale.
- No executed round-23 receipt exists and none may be created by this seat.

## 4. `[substrate]` deferral, SKIP-SELF, hermetic mode — obligation preserved

- **Deferral**: R11-05 is one of 32 untagged rows (11 of 43 carry `[substrate]`, e.g. R11-04).
  That is correct and load-bearing: `--selftest` is host-free, so it must run on a
  substrate-absent host. Tagging it by analogy with R11-04 would convert a hermetic proof into
  `DEFER R11-05 reason=substrate-absent` (`claim-ledger.sh:416-418`) and a `deferred=` digit.
- **Hermeticity, argued from code**: the scratch invocation passes `--baseline/--symbols`
  (`drift-pins.sh:400`), which skips the `FILES` membership closure (`:168`); every baseline
  and symbol row addresses `$d/…`; `is_nohash` only string-compares against `NOHASH` (never
  stats it); `DRIFT_EXTRA_NOHASH` is overwritten inside the selftest (`:396`), so an inherited
  value cannot leak in. No `$HOME` path is read or written. Caveat: `mktemp -d` needs a writable
  `TMPDIR` — the only environmental dependency.
- **SKIP-SELF**: the predicate is `[[ ${TF[1]:-} == *claim-ledger.sh* ]]`
  (`claim-ledger.sh:817`). R11-05's command names `corpus/drift-pins.sh`, so it is **not**
  skipped in `cells`; it is re-run for real. The obligation is therefore preserved in both
  `verify` and `cells`.

## 5. What C3 (hermetic cells) must retain for this row

1. `cells` runs cited rows through the ordinary claims machinery, so the production `cells` audit
   executes R11-05 because `SCORECARD.md:28` (Round 9 post-move, operability) cites it. A
   hermetic fixture `cells` run must **not** become the only cell evidence for that round-9 cell.
2. R13-03 (`bash corpus/claim-ledger.sh cells`) is `[substrate]`-tagged; on a substrate-absent
   host it DEFERs, i.e. the cell audit itself is unproven there. The new host-free fixture row
   is the right fix, but it does not replace R11-05's production re-run.
3. If the fixture scorecard is copied from `SCORECARD.md`, it will cite R11-05 and the fixture
   must (a) carry row R11-05 in its claims file, else `missing_ids` → `CELL_AUDIT: BROKEN`, and
   (b) carry a resolvable `corpus/drift-pins.sh`, else exit 127 → `row_failures=1` → BROKEN.
   Both are loud, so this is a fixture-design constraint, not a hidden false-clean.
4. Do not widen the SKIP-SELF predicate to `corpus/*.sh` for fixture convenience: R11-05 would
   then be silently skipped and `CELL_AUDIT: CLEAN … self_skipped=N` (`claim-ledger.sh:1011`)
   would still match, because R13-03's ERE pins `self_skipped=[0-9]+`, not an exact value
   (`claim-ledger.tsv:38`). If C3 wants that protection, pin the exact self-skip count in the
   fixture row (R23-01) where it is stable.

## 6. What C1 (closure-disposition) must retain for this row

- D6 (`round-22-verifier-spotcheck.md:177-179`) is the only routed defect that touches this
  row's evidence, because `final-verification.json` *is* the file D6 says is mislabelled. The
  working-tree disposition (`corpus/closure-dispositions.json`, untracked at read time) records
  D6 as `fixed` → `corpus/lessons/round-23.md#Routed defect dispositions` with the note "this
  round's verdict file carries measured_commit itself". That is prospective only: the historical
  R11-05 receipt keeps `.h1=8ada17a5`. C1 must not let round-23's new verdict file silently
  supersede it without saying the round-22 receipt's label is known-wrong-but-byte-equivalent.
- If any `fixed` pointer for D6/D9 names a commit or file, the checker's pointer rule
  (`corpus/closure-dispositions.py:104-120` — pointer must exist, heading must exist, `fixed`
  must name the id) and its source-drift pin (`:148-149`) should be extended or bypassed deliberately for this receipt; as written it
  proves *a record mentions D6*, not that R11-05's observed pass was re-bound to the measured
  commit. That gap is inherited from the design, not introduced by this row.
- C1's "source drift" pin is the round-22 spot-check digest
  (`source_sha256=65a5b3de…`); it does not cover `final-verification.json`. R11-05's evidence
  chain therefore remains: ledger row (stable) + script blob (stable) + historical receipt
  (label-imprecise). Any round-23 "After" claim must name a *new* executed receipt for R11-05 if
  it wants currentness — a static re-read cannot supply it.

## 7. Finding F1 — consumer-visible false-clean (supported by source, no execution)

**Claim that fails:** `corpus/README.md:36` advertises the `--selftest` as
`13 cases: content/mode drift, missing, symlink+hardlink, symbol moved/gone/ambiguous, count
drift, dotenv shape drift, clean`.

**Refutation:** the hardlink leg has no case. The hardlink verdict is printed only by
`drift-pins.sh:135-136` (`nlink>1`), reached after the `-L` test at `:130`. The sole link case is
`drift-pins.sh:428` (`mv … && ln -s b.real b.txt`), which exits through the symlink branch at
`:131` and never reaches `:135`. The only `ln` invocation in the script is this `ln -s`
(`grep -nE '(^|[^A-Za-z0-9_])ln([[:space:]]|$)'` → `:428` once). The 13 cases' own names (`drift-gate.md:189-193`) say "symlink", not
hardlink — the knowledge entry is accurate; the README is not. This branch was added for a
round-9 L2 critic finding (`drift-gate.md:73`), so the one regression the review demanded has
zero selftest protection while the row still reports `PASS (13 cases)`.

**Why the row cannot see it:** the expectation pins cardinality, not identity. `cases` counts
`run` calls; replacing the `count drift` case (`:432`) with a duplicate of `restored` (`:412`)
leaves `cases=13`, `fails=0`, and prints the identical PASS line. The same substitution would
retire the only exercise of the `#N` count pin that guards the unhashed `op.env` row.

**Minimal synthetic falsifier for L1 (proposal — deliberately NOT executed here):**
1. `T=$(mktemp -d); cp corpus/drift-pins.sh "$T/dp.sh"` (copy, never the production file).
2. Mutation: in `$T/dp.sh` delete `:133-136` (the `nlink` branch).
3. `bash "$T/dp.sh" --selftest` → predicted `DRIFT_SELFTEST: PASS (13 cases)`, exit 0. If
   observed, the 13 cases do not exercise hardlink detection and the README sentence is false.
4. Killer case to add (makes step 3 exit 1): after the symlink restore at `:430`, insert
   `ln "$d/b.txt" "$d/b.hl"` / `run "hardlink" 1 'LINK.*hardlink'` / `rm "$d/b.hl"`; then bump the
   ledger row to `^DRIFT_SELFTEST: PASS \(14 cases\)`.
5. Identity variant (optional): duplicate a CLEAN case in place of `count drift`; expect the
   same unchanged PASS line — proves count-only pinning cannot detect case substitution.

Recommended fix owner: L1 (this seat is advisory only). The minimal correct move is to add the
hardlink case and update row R11-05's count; the README's `symlink+hardlink` then becomes true.

## 8. Minor observation — setup exit code deviates from the documented map

`drift-pins.sh:19` documents `2 usage/setup error`; in `--selftest`, a `mktemp -d` failure
(`:376`) dies under `set -e` with exit **1**, which the ledger reports as
`FAIL R11-05 reason=exit-mismatch`, not `POLICY`. Fail-closed, so no evidence risk; noted only so
a future fixture that sandboxes `TMPDIR` does not misread the cause.

## 9. Limits / unresolved

- No execution: the "does the mutated copy print PASS" prediction in §7 is reasoned from the
  PASS-gating structure (`cases`/`fails`/`printf`), not observed; L1 must run the fixture.
- Only one executed receipt was found (round-22). I did not search outside the repo for host
  logs, and I did not re-run any sibling gate.
- Working-tree note (observed, outside my row): at HEAD `d218603` neither `plans/round-23.md`
  nor `corpus/closure-dispositions.{py,json}` is tracked; the three appeared untracked during
  this audit (closure files mtime 00:46), `corpus/fixtures/` does not exist, and no `R23-*` row
  exists. Concurrent lanes were also editing tracked files while I read (`corpus/SOURCES.md`,
  `corpus/sources-census.sh`), so this worktree is not a stable read basis: C1/C3 "Before/After"
  must be adjudicated against the final commit, not here.
- Not checked (other owners): R11-04's host run, R11-09's ledger selftest, the 12 skipped IDs,
  and the truth of `final-verification.json`'s other 30 rows.
