# ClaimR16X06 — R16-06 semantic audit (read-only, advisory)

**Observed revision.** HEAD `d218603b74099ddca0bd8f869516fc41db0979bf` (frozen base, `plans/round-23.md:3`).
Row inputs at HEAD:

| file | sha256 | lines / bytes |
|---|---|---|
| `corpus/claim-ledger.tsv` | `e6806968…8305` | 58 / 17844 |
| `corpus/adjacency.tsv` | `4d9bfb11…9549` (= `corpus/stamps.tsv:1`) | 83 / 5660 |
| `corpus/scope-gate.sh` | `078a2601…` | — |
| `corpus/claim-ledger.sh` | `cf56f9ea…` | — |

I re-checked the working tree at 2026-10-21T01:05-03:00:
- `adjacency.tsv`, `scope-gate.sh`, `stamps.tsv` and `surface-census.tsv` are byte-identical to HEAD.
- L1's in-flight edits touch `claim-ledger.tsv` rows :29, :51–54 and the new :59–60, plus `claim-ledger.sh` :91–92 and :161. Row :44 and the code paths it uses are unchanged.
- `adjacency.tsv` has had the same bytes at 8ada17a (round-22 `h1`), 4be5da3 (measured), 254d632 and d218603, and has not changed since bc1af88 (round 17).

**Row** (`corpus/claim-ledger.tsv:44`): `grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv`, expect `^8$`, exit 0, timeout 30, no `[substrate]` tag. Its tuple is identical to R17-03's (`:47`). ClaimR17X03 §2 already reports the duplicate; I agree and do not repeat it.

## 1. Verdicts

| aspect | status | evidence |
|---|---|---|
| expect `^8$`, exit 0, last line | **supported** | Eight directive lines at `adjacency.tsv:67–74`. I checked each byte by byte: `# no-enumerate`, one TAB (0x09), then `$HOME/…`, with no CR or trailing whitespace. `grep -c` prints one line. Deleting all of them gives `0` and exit 1, which fails. A missing file gives exit 2, which fails (`claim-ledger.sh:426–443`). |
| timeout 30 | supported (generous) | The round-22 executed receipt took 0.002 s (`.ufo/waves/round-22/final-verification.json:302`). |
| policy | supported | First token is `grep` (`claim-ledger.sh:160`). No `$` or other metacharacter (`:163`, `:177`), no backslash (`:184`), no denied verb. `.HOME` stands in for `$` because policy forbids the literal. |
| note: the three R10 clauses | supported, incomplete | `scope-gate.sh:469–497` implements all three: census row or ancestor, not a scan dir, not inside an `# own` prefix. The note leaves out the round-17 whole-HOME refusal (`:484–485`). |
| note: "103 unclaimed children" and "13 unclaimed **live** children" | **historical, presented as live** | These are host measurements from 2026-09-29 (`adjacency-scope.md:56–57, 308–310`; `round-16.md:73–80`; `scope-gate.sh:728–731`). The round-22 Erratum labels them historical (`adjacency-scope.md:315–318`), but the ledger note still says "live". `SCORECARD.md:312` (round 18) records three of the four pinned dirs as absent. I did not measure the current host. |
| causality: the counted set equals the enforced set | **refuted** | See §2. |

## 2. Causality: the count is not the set the gate parses

- **How the gate parses.** `scope-gate.sh:191` reads directives with `IFS=$'\t'`. At `:196`, `if [[ -z "${f2:-}" ]]; then continue; fi` treats any `#` line without a TAB as a prose comment and drops it silently (the contract comment is at `:194–195`).
  - Only lines that survive this reach `noenum` (`:206`), the R10 checks (`:469–497`) and the leaf derivation (`:499–517`).
- **What the row counts.** `[[:space:]]+` also accepts a SPACE. A line written `# no-enumerate $HOME/…` is counted by R16-06 and ignored by the gate.
- **R16-06 is the only pin, and it pins the wrong set.** No gate summary reports how many no-enumerate directives were parsed.
  - The `ADJACENCY_SCOPE` fields (`:641–651`) have no such count.
  - `BREADTH_AUDIT required=` counts leaves only.
  - So R16-06 (and the identical R17-03) is the only pin of "8 declared", and it pins grep's looser set.
- **The documented syntax is the form the gate drops.**
  - `scope-gate.sh:24`, `adjacency.tsv:32,34` and `adjacency-scope.md:98–99` all write `# no-enumerate <dir>` with a space.
  - Only the 7-column row schema and the breadth count fields say `<TAB>`.
- **Regex-class probe** (neutral synthetic stdin; no repo file read, nothing written):
  - `[[:cntrl:]]+` matched TAB, TAB TAB and VT, but not SPACE. `[[:space:]]+` matched all of them.
  - The result is the same for the harness builtin grep (pi-uu-grep 0.2.0) and for `/usr/bin/grep` (GNU 3.12), under en_US.UTF-8, C and C.UTF-8.
  - The ledger runs rows with `bash -c`, and an `env -i bash -c` resolves `grep` to `/usr/bin/grep`.

## 3. `[substrate]`, SKIP-SELF and hermetic mode

- **`[substrate]`: correctly absent.** The row reads one committed file.
  - It must stay untagged. A tag would defer the only cardinality pin and change R18-02 (`:49`, `^11$`).
- **Effect of deferral on hosts without the substrate.** The tagged rows defer there (`claim-ledger.sh:140–146, 416–418`), which includes R16-01, R16-03 and R17-01 (`:39, :41, :45`). On such a host:
  - Nothing exercises the note's "R10 gives it teeth" against the shipped data.
  - R16-02 runs R10 only on a scratch fixture that has three leaf directives and no aggregates (`scope-gate.sh:859–861, 1009–1016`).
  - The aggregate-ancestor clause the note credits is exercised only by `--falsify` case 5b (`:728–734`), which is deferred.
  - In the round-22 safe-row run, R16-06 passed and R16-01, R16-03 and R17-01 were skipped (`round-22-verifier-spotcheck.md:74`).
- **SKIP-SELF: does not apply.** `claim-ledger.sh:816–819` matches `*claim-ledger.sh*`. Production `cells` does re-run R16-06, because `SCORECARD.md:237` (the Round 16 post-move adjacency cell) cites R16-01 through R16-06. It runs at the production ROOT (`:426`).
- **Hermetic mode.** R16-06 is already host-free. Its production obligation needs no fixture and only means something at the repo root, against the `stamps.tsv:1` bytes.

## 4. Consumer-visible false-clean and minimal falsifier

**Risk.** R16-06 and R17-03 can print `8` and exit 0 while the gate enforces only 7 (or 0) no-enumerate boundaries. The row note and `SCORECARD.md:237` ("8 `# no-enumerate` declarations … fail closed on … a meaningless `# no-enumerate`") would still read as enforced.

**M1 — production-shaped, one byte (proposed, not executed).** Take a scratch copy of `corpus/adjacency.tsv` and change the 0x09 on line 72 to 0x20, giving `# no-enumerate $HOME/.local/state`. Lines and bytes stay at 83 / 5660; the sha changes. Predicted from the cited code (inference, not observed):
- **R16-06 and R17-03:** `8`, exit 0, PASS.
- **Gate parse:** line 72 is skipped (`:196`), so only 7 directives are parsed. `.local/state` is an aggregate (its scan descendants are at `surface-census.tsv:18–20`), so `breadth_required=4` does not change. With the substrate present, the R16-01 and R17-01 summary lines would stay byte-identical CLEAN.
- **R16-03 case 5b** (`# own $HOME/.local/state`): no ENUM-CLASH, only OWN-UNLISTED from R11. The result is `SCOPE_FALSIFY: FAIL (caught=17/18 failed=1)`. This is the only detector on the gate side, and it is deferred without the substrate.
- **`verify` stamps:** STALE on the sha until a reviewed re-stamp. After a re-stamp, nothing on a host without the substrate detects the change.

**M2 — observed in the C3 fixture, now repaired by L1.**
- At 00:53–00:57, `corpus/fixtures/cells-hermetic/corpus/adjacency.tsv` (sha `c17f7e17…`, 9 lines / 307 B) had all eight `# no-enumerate` lines SPACE-separated, with 0 tab bytes. The gate would have parsed zero directives, while R90-02 (the R16-06/R17-03 tuple) printed `8`. I sent this to KagiR23.
- By 01:03 the fixture was TAB-separated (8 of 8; sha `fa15a53c…`, still 9 / 307, re-stamped at `stamps.tsv:1` of the fixture), and R90-02's timeout was 30.
- R90-02 still uses `[[:space:]]+`, so the M1 class still applies to the fixture: a TAB→SPACE mutant still counts `8`.

**Fix (minimal, passes policy).**
- Change the ERE in R16-06, R17-03 and R90-02 together to `^# no-enumerate[[:cntrl:]]+.HOME/`. It has no `$` and no backslash, so it passes `claim-ledger.sh:160–190`.
- Expected results:
  - Current production bytes: `8`, so `^8$` still holds.
  - M1: `7`, giving `FAIL R16-06 reason=verdict-not-final`.
  - Current TAB fixture: `8`.
- Record the tuple change in an old/new journal. The round-22 convention is `pin-migrations-integration.json` `claim_changes` (`round-22-verifier-spotcheck.md:88`).
- **Residual limits.**
  - `[[:cntrl:]]` also accepts CR, VT and FF separators that the gate does not split on.
  - `.HOME` still accepts any single character (ClaimR17X03 §4).
  - Checking for an exact TAB and the literal `$HOME` belongs in `scope-gate.sh` (for example a parse-only mode), not in a claim row.
- **Do not use `\$HOME`.** META_RE refuses `$` (`:163`, `:177`) and backslash is refused (`:184`). One POLICY row makes `verify` exit 2 for the whole ledger (`:973–975`). ClaimR17X03 has since amended that proposal.
- **Optional, stronger:** add `no_enumerate=<parsed>` to the `ADJACENCY_SCOPE` fields (`scope-gate.sh:641–651`), so R16-01 pins the parsed set whenever the substrate is present.

**Synthetic failing fixture for L1 (proposal only).**
- **Fixture F:** `corpus/adjacency.tsv` holds eight lines `# no-enumerate<TAB>$HOME/d1` … `d8`.
  - Claims row `R90-02` uses the tightened ERE, `^8$`, exit 0, timeout 30.
  - One cell cites R90-02.
- **Mutant F′:** line 8 changes from TAB to SPACE.
  - Re-stamp the fixture for F′, or have the mutant's cells not cite the stamped file, so that the row is the only cause of failure.
- **Expected:**
  - F gives `CELL_AUDIT: CLEAN (… row_failures=0 …)`.
  - F′ prints `FAIL R90-02 reason=verdict-not-final` and `CELL_AUDIT: BROKEN (… row_failures=1 …)`, exit 1.
  - With today's `[[:space:]]+` ERE, F′ is predicted CLEAN, so this falsifier kills the current row.

## 5. What C3 (hermetic cells) must keep for R16-06

1. **Production-root row.** R16-06 stays a production-root row in safe-row and `verify` runs. It stays untagged, is never skipped as SKIP-SELF, and is never replaced by a fixture copy. Its evidence is the `stamps.tsv:1` bytes.
2. **R90-02 proves mechanics, not the obligation.** It mirrors the tuple's last-line and exit mechanics, not R16-06's obligation, until the ERE is tightened (M1 still applies). R23-01 CLEAN must not be reported as covering R16-06 or R17-03.
3. **The mutation case must assert the row's own line.** Assert `FAIL R90-02 reason=verdict-not-final`, not just exit 1.
   - The fixture's freshness cell cites the stamped fixture adjacency (fixture `SCORECARD.md`, freshness row; fixture `stamps.tsv:1`).
   - So any byte edit also produces `STALE-POINTER`, which would hide whether R90-02 itself tells the cases apart.
4. **The production cell edge stays unexercised.** R23-01 uses the fixture scorecard, so it never exercises the `SCORECARD.md:237 → R16-06` edge. R13-03 stays skipped. Keep both facts stated.
5. **Keep the explicit paths.** R23-01 passes `--claims/--stamps/--scorecard/--docs` explicitly (in-flight `claim-ledger.tsv:59`). `--root` alone would keep the production CLAIMS and STAMPS (`claim-ledger.sh:104–105`) while running rows at the fixture root (`:426`).
6. **In-flight wording.** The fixture contract in `corpus/lessons/round-23.md:152–154` and `LOG.md:1203` were updated to five files. The R23-01 note's "one local script row" is true, but it leaves out the R90-02 count row.

## 6. What C1 (closure dispositions) must keep for R16-06

- **Not an obligation.** R16-06 is not among the obligations (`round-22-verifier-spotcheck.md:155–183`: D1–D9, the decisions, ADMITTED). C1 must not count R16-06 or R17-03 as closure evidence.
- **Latent false-clean through this row's note.**
  - `closure-dispositions.py:117–119` accepts a `fixed` disposition if the id appears anywhere in the pointed file.
  - The note at `claim-ledger.tsv:44` contains "reviewer D2," — a round-16 reviewer finding (`round-16.md:73`). It is not the spot-check's D2 (`:167`, the mise global-config write).
  - **Falsifier (proposed, not executed):** scratch dispositions with D2 changed from reported to fixed (pointer `corpus/claim-ledger.tsv`) and D3 changed from fixed to reported (pointer kept).
  - **Predicted output:** `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)`. That is byte-equal to R23-02's pinned line (in-flight `claim-ledger.tsv:60`), even though no D2 fix exists.
  - **Other collisions of the same kind:** `scope-gate.sh:722` (D2), `scope-gate.sh:80` (round-16 "executor D4"), `adjacency-scope.md:179` and `LOG.md:631`.
  - **Fix:** a TSV pointer must name a row id and match field 1 (as ClaimR17X03 §6 also proposes), and D-ids must be scoped to their source — either required inside the round lesson's disposition section or written with an `r22-` qualifier.
- **Membership.** Editing the ERE in place leaves R13-02 (`^35$`) and R21-04 unchanged. Retiring or merging R16-06 would mean updating `SCORECARD.md:237`, `adjacency-scope.md:19, 192, 263` and `adjacency.tsv:42`.

## 7. Evidence classes

| class | item |
|---|---|
| current (HEAD and working tree, 01:05) | `claim-ledger.tsv:44`; `adjacency.tsv:32, 34, 42, 67–74`; `stamps.tsv:1` (fresh); `scope-gate.sh:24, 191–196, 206, 469–517, 641–651, 722–734, 859–861, 1009–1016`; `claim-ledger.sh:104–105, 140–146, 160–190, 415–443, 816–819, 973–975, 1006–1012`; `SCORECARD.md:237` |
| historical, executed | round-22 `final-verification.json:302`: argv run, exit 0, stdout `8`, 0.002 s. Its `h1` is 8ada17a5 (routed D6). The adjacency bytes are identical at h1, at the measured 4be5da3 and at HEAD. |
| historical, snapshot | `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:44` is byte-identical; `safe-row-plan.json:132` |
| historical, origin | Row text unchanged since `8a6ec16` (round 16). The header line `adjacency.tsv:42` was added in `bc1af88`. |
| historical host facts | 105, 103 and 13 child counts (2026-09-29); labelled historical in the knowledge entry, not in the ledger note |
| in-flight (outside the frozen population) | `corpus/fixtures/cells-hermetic/*` (M2 seen at 00:53, repaired at 01:03); R23-01 and R23-02; `closure-dispositions.{py,json}`; `round-23.md`; LOG and SCORECARD edits |

## 8. Deviations and limits

- **Deviation.** Early in the audit I ran the row's exact command once, plus a `grep -rc` variant, in the tool shell. Both were read-only and wrote nothing; the output was `8`. That shell's `grep` is the harness builtin (pi-uu-grep), not the `/usr/bin/grep` the ledger's `bash -c` uses, so this is not a harness-path verdict and I do not offer it as verification.
- **Git queries.** I ran read-only git queries (`rev-parse`, `log`, `show`, `diff`, and `git status --porcelain` three times). `git status` may refresh the `.git/index` stat cache opportunistically; later queries used `GIT_OPTIONAL_LOCKS=0`.
- **Nothing else run.** No other gate, handler, op/vault command or host probe ran. I did not probe the substrate state; it comes from committed round-18 and round-22 records.
- **Regex probe.** It ran on neutral synthetic stdin only (`^a[[:cntrl:]]+b` and `^a[[:space:]]+b`).
- **Predictions.** The M1, M2-predicate and C1 outcomes are inferred from the cited code. None was executed.
- **In-flight snapshot.** The in-flight files kept changing during integration. §4 M2 and §5.6 describe the 00:53–01:05 snapshots.
- **Tools installed or updated:** none.
- **Messages sent:**
  - KagiR23: M2 and the C1 collision.
  - ClaimR17X03: the `\$HOME` policy refusal (acknowledged and amended).
  - ClaimR16X04 and ClaimR17X02: the same separator class (both acknowledged).
