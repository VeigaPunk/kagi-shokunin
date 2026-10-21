# ClaimR11X07 — R11-07 `transcript-scan.sh --selftest` (semantic audit)

Seat: ClaimR11X07 (scout, leaf, read-only). Lane revision read: `d218603b74099ddca0bd8f869516fc41db0979bf`
(2026-10-20T21:11:59-03:00); working tree clean except the untracked `.ufo/waves/round-23/`.
Not executed: R11-07, any sibling gate, any ledger mode, the handler, `op`, or the vault. What ran:
`git log/show/diff`, `sha256sum`/`wc`, `grep`, JSON parsing of committed receipts, `test -x` on the
substrate path (the same stat `claim-ledger.sh:145` performs), and one Bash-semantics probe
(`if (exit N); then :; else echo $?; fi`). The probe printed 1 and 2 and created no files.
Installs: none. Host tools observed: sqlite3 3.54.0 (2026-10-09), Python 3.14.8,
GNU bash 5.3.20, GNU coreutils `timeout` 9.12. Only write: this file. No judgment or admission authority.

## 0. Verdicts

| question | verdict |
|---|---|
| exit `0` | **supported** |
| last-line ERE `^SELFTEST OK` | **supported** as the check that separates the selftest path from the live-scan path; **weak** as a coverage pin. The line is static (`:256`), and this is the only selftest row of the 11 that pins no case count. |
| timeout `300` | **supported**. The r22 receipt measured 2.715 s, so this is a hang guard with more than 100× headroom. |
| note: "seeded-hit + wal-resident detection on scratch DBs" | **partly supported**. The wal-resident case runs only if `python3` is present. "Seeded hit" passes if either of two seeds fires. |
| script header `:16-19`: "asserts the gate fires on each" | **refuted** for the credential tripwire. It is never asserted independently (§2, §5). |
| `[substrate]` untagged | **supported**. Correct, and R18-02's tag count of 11 guards against a stray tag. |
| SKIP-SELF | **does not apply** (supported). The command has no `claim-ledger.sh`, so `cells` re-runs the row. |
| hermetic | **supported**, with two couplings: `python3` presence, and `--db` parsing at `:41` (§7). |
| consumer-visible false-clean | **yes**. Primary: tripwire detection is unasserted (§5). Secondary: when `python3` is absent the static OK line still claims the wal case ran (§6). |
| false-fail | **none supported by evidence**. A missing `sqlite3` or `mktemp` correctly fails closed. |

## 1. The frozen obligation and its pointer chain

- Row: `corpus/claim-ledger.tsv:21`: `R11-07  bash corpus/transcript-scan.sh --selftest  ^SELFTEST OK  0  300  seeded-hit + wal-resident detection on scratch DBs`.
  - The row bytes are identical at every ledger commit since `301b9ec` (round 11, 2026-09-28).
  - It is identical in `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:21`.
  - Ledger file sha256 is `e6806968…8305` (17844 B), equal to `.ufo/waves/round-22/final-verification-inputs.json`.
- How the ledger consumes it (`corpus/claim-ledger.sh`):
  - `:415` counts the row.
  - `:416-419` defers it only on `[substrate]` + absent.
  - `:427` runs `cd "$ROOT"` then `timeout -k 5 300 bash -o pipefail -c`.
  - `:433` fails on any exit other than 0.
  - `:436-442` matches the ERE against the last non-empty line of stdout+stderr.
- Referent: `corpus/transcript-scan.sh` has sha256 `2d60981b…a23`, 282 lines / 14709 B. This equals `corpus/stamps.tsv:65` and is byte-identical at `e64e81b` (r9), `8ada17a` (r22 H1), `4be5da3` and HEAD.
- Inbound pointers, from the actual docs (not a count). All three SCORECARD cells sit in sections that `SEC_RE` (`claim-ledger.sh:690`) scores:
  - `SCORECARD.md:28`, under heading `:23` "Round 9 — post-move". Co-cites `R11-05` and the stamp `corpus/drift-pins.sh`.
  - `SCORECARD.md:40`, under `:34` "Round 10 — pre-move". Co-cites `R11-04` **[substrate]**.
  - `SCORECARD.md:62`, under `:56` "Round 11 — pre-move". Co-cites `R11-04` and `R11-06`, both **[substrate]**.
  - `corpus/knowledge/transcript-hygiene.md:12`: `Reverify: R11-06, R11-07`.
  - No other committed doc cites `R11-07` (grep over the root docs, `corpus/knowledge`, `corpus/lessons`).

## 2. Causality: what actually produces exit 0 + `SELFTEST OK`

The verdict line at `:256` is a static string. It is reached only through four steps.

1. **Seeded case, `:208-213`.** The inner `bash "$0" --db hit.db` must exit exactly 1. `$?` in the `else` branch is the condition's status; the probe confirmed 1→1 and 2→2.
   - `hit.db` carries **two independent causes**: the op-scheme row in `part.data` (`:202`, the first entry of PATTERNS_HIT at `:84`) and a populated `credential` tripwire (`:203`).
   - The scan exits 1 if *either* fires (`:282`).
   - The printed text "(expect exit 1, 2 hits)" (`:208`) is **never asserted**.
2. **Clean case, `:214-216`.** The inner scan must exit 0 on an all-empty schema.
   - This proves the 888 LIKE queries plus 5 tripwire queries run without a query error, with `absent=0`.
   - It does not prove that non-empty benign text is free of false positives. No near-miss row exists, so the round-9 LIKE-wildcard class (`like_lit`, `:104`) is never exercised.
3. **WAL case, `:217-252`, runs only if `command -v python3` succeeds.**
   - Python switches to WAL, then commits the schema and one op-scheme row (`:224-243`).
   - It then calls `os._exit(0)` (`:244`), so the closing checkpoint never runs.
   - The inner scan copies db+`-wal`+`-shm` (`:266-274`) and must exit 1.
   - [INFERENCE, SQLite semantics in §10, not executed] Because the schema itself lives in the WAL, a reader blind to the WAL would see 16 absent tables. The inner scan would then exit 2 (`:282`) and the selftest would fail at `:251` ("unexpected exit"). That is fail-closed, but the failure reports through exit 2 rather than the `:249` "hit missed" message.
4. **Skip branch, `:253-254`.** It prints a skip line and falls through to the same `:256` line.

What the verdict causally depends on:
- the op-scheme pattern on `part.data`, made causal *only* by step 3;
- the empty-schema clean pass;
- replay of the copied WAL sibling.

What it does **not** depend on:
- any tripwire table (masked in step 1, empty in step 3);
- the other 31 HIT patterns and all 5 WARN patterns (the r22 receipt shows `warns=0` in every case);
- 10 of the 11 scanned tables;
- the exit-2 path for "schema absent, no hit";
- LIKE escaping;
- `--classify`.

## 3. Is the expectation justified?

- **Exit 0.**
  - The only exit-0 path is the success path (`:256-257`).
  - Every asserted failure exits 2: `:185`, `:210`, `:212`, `:216`, `:246`, `:249`, `:251`.
  - Unasserted errors exit non-zero under `set -euo pipefail` (`:32`).
  - Verdict: supported.
- **ERE `^SELFTEST OK`.**
  - It has real teeth against one failure mode. A live scan of a clean DB also exits 0, but its last line is `TRANSCRIPT_SCAN: CLEAN …` (`:278`), which the ERE rejects. So a selftest-dispatch regression that fell through to the live scan cannot pass.
  - It is weak as a coverage pin. The line does not change with the number of cases executed. R11-03/05/09, R12-02, R15-02, R16-02, R18-03, R21-03 and R22-02/04 all pin counts; R11-07 alone does not.
- **Timeout 300.**
  - The r22 receipt measured 2.715 s.
  - [INFERENCE] One run makes about 2.7k `sqlite3` spawns: three scans × (11 `table_exists` + 888 counts + 10 tripwire queries).
  - The timeout covers host load without masking a hang. No change needed.

## 4. `[substrate]` deferral, SKIP-SELF, hermetic mode

- **`[substrate]`.**
  - The selftest touches only `mktemp` paths (`:186`, `:205-207`, `:221`).
  - The default `SD`/`DB` (`:34-35`) is overridden by `--db` in every inner call.
  - So an untagged row is correct. On this host `$HOME/.local/bin/the-janitor` is not executable, so `substrate_present` is false: R11-06 DEFERs and R11-07 still runs. The obligation is preserved.
  - Tagging R11-07 would be a false-defer that loses the only executed transcript evidence. It would also break R18-02's expected count of 11.
- **SKIP-SELF.** `cells_evidence` skips only commands containing `claim-ledger.sh` (`:816`). R11-07 is therefore re-run by `cells` for each of the three scored cells.
- **Hermetic.** The row is natively hermetic, with two couplings that C3 must hold (§7).
  1. The wal clause needs `python3`. Without it, the result is a silent skip followed by the same OK line.
  2. The inner scans are fenced to scratch only by `--db` parsing at `:41`. The selftest never checks the inner `db=` field (`:280`).

## 5. Primary false-clean (consumer-visible) and minimal synthetic falsifier

**Risk.** A change that disables the credential/account tripwires still yields
`SELFTEST OK (seeded hit + wal-resident hit detected; clean db passed)`, exit 0, and a silent R11-07 pass in `verify` and `cells`.

Three consumers see that pass as proof:
- the operator following `transcript-hygiene.md:100-102`: "run it after editing the pattern or table lists";
- `SKILL.md:44`: "`--selftest` checks the gate itself";
- the script header `:16-19`.

No other gate catches the change:
- R11-06 and checklist H7 are live scans. At their baseline every tripwire is empty, so their output does not change.
- `stamps.tsv:65` catches the byte change, but not the meaning of it. After a reviewed re-stamp, nothing objects.

Current bytes do detect tripwires today: the r22 receipt shows the seeded scan at `HITS=2` with the `credential` HIT line. That detection is not protected by any assertion.

**Falsifier F1 — proposal for L1, NOT executed here.** Run in scratch only, never against host state:
```sh
S=$(mktemp -d); mkdir "$S/state" "$S/home"
cp corpus/transcript-scan.sh "$S/ts.sh"
sed -i '66s/ credential / /' "$S/ts.sh"            # M1: the "table list" edit the entry says --selftest validates
grep -c '^TRIPWIRE_TABLES=.*credential' "$S/ts.sh" # 0 = mutation applied
THE_JANITOR_STATE_DIR="$S/state" HOME="$S/home" bash "$S/ts.sh" --selftest; echo "exit=$?"
```
- **Required after a fix:** exit ≠ 0 and the last line does not match `^SELFTEST OK`.
- **Predicted on current bytes** (static trace of `:169-181`, `:202-213`, `:242`, `:282`): exit 0 with the full OK line. The mutant survives.
- **Variant M2:** delete `hits=$((hits+1))` at `:177`. It also survives. The inner summary would read `HITS=1` while still printing a tripwire HIT line.

**Fix (owned by L1).** Each step should count only once it is shown able to fail; F1 and F2 are those demonstrations.
1. Make each seeded cause independently causal. Either split `hit.db` into a pattern-only fixture and a tripwire-only fixture, each asserting exit 1 and the inner last line `^TRANSCRIPT_SCAN: HITS=1 `, or keep the combined fixture and assert `^TRANSCRIPT_SCAN: HITS=2 `.
2. Count the executed cases and print `SELFTEST OK (cases=N)`. Make `python3` absence exit 2. Re-pin R11-07 to `^SELFTEST OK \(cases=N\)$` and record old→new.
3. Build the needles from fragments, following r22 `build/SafetyFixture.md`: no new literal reference-shaped or session-shaped strings.
4. Narrow, or make true, the claims at `:16-19`, `transcript-hygiene.md:100-102` and `SKILL.md:44`.
5. Optional: add one non-empty clean near-miss row, so that reverting `like_lit` (`:104`) fails the selftest. This is needed only if the entry keeps "run it after editing the pattern … lists".

## 6. Secondary risk (host-conditional): when `python3` is absent, the OK line is static

The skip branch at `:253-254` falls through to `:256`, which claims "wal-resident hit detected". The row's ERE and exit both pass, so the wal clause in the row's note is reported as proven when it never ran.

**Falsifier F2 — proposal, NOT executed:**
```sh
S=$(mktemp -d); mkdir "$S/bin" "$S/state" "$S/home"
for t in bash mktemp cat cp rm sqlite3; do ln -s "$(command -v "$t")" "$S/bin/$t"; done
THE_JANITOR_STATE_DIR="$S/state" HOME="$S/home" PATH="$S/bin" "$S/bin/bash" corpus/transcript-scan.sh --selftest; echo "exit=$?"
```
- **Predicted:** the `:254` skip line appears, then exit 0 with the full-run OK line.
- **Required after the fix:** a non-zero exit, or a line the re-pinned ERE rejects.
- **Bound:** today `python3` is present. Ledger rows R22-01..04 would fail on a host without `python3`, so `verify` as a whole would not be clean there. The false-clean is therefore row- and receipt-level. It matters most if C3 builds a minimal PATH.

## 7. What the C3 hermetic cells proof must retain for R11-07

1. **Run the real row.** Use the exact argv with cwd at the lane root, because the selftest re-invokes itself via a relative `$0` (`:209`, `:215`, `:248`). Check the script bytes against `stamps.tsv:65` before running. Never stub, defer or SKIP-SELF the row.
2. **Classify by the row's own `[substrate]` tag (absent), not by script name.** R11-06 runs the same script and *is* `[substrate]`.
3. **Run with `THE_JANITOR_STATE_DIR` and `HOME` pointed at empty scratch directories.** A regression in `--db` parsing would then fail as `db not found` (exit 2) instead of letting the inner scans read the private default DB (`:34-35`).
4. **Require `python3`, or record the reduced coverage.** Retain the full stdout:
   - the three case markers (`:208`, `:214`, `:247`);
   - the three `TRANSCRIPT_SCAN:` lines.

   A receipt containing the `:254` skip line is not wal-resident evidence. The last line alone cannot tell a 3-case run from a 2-case run.
5. **Keep `0` / `^SELFTEST OK` / `300` unchanged** until L1 lands and re-pins §5's fix.
6. **Cross-row (owner R13-03).** `CELL_AUDIT rows_run` includes deferred and POLICY rows, because the count at `:415` comes before the DEFER check at `:416`. C3 should report executed rows separately from deferred rows.

## 8. What C1 closure-disposition must retain (follow the pointers, not a count)

- **Scope of an R11-07 pass.** It shows only that the scratch mechanism detects the op-scheme pattern, including content that lives only in the WAL (when step 3 ran), and that an empty schema passes clean. It shows nothing about tripwires on their own, the other 36 patterns, the other 10 tables, the schema-absent path, or any fact about the live DB.
- **`transcript-hygiene.md`.** Its host facts (schema census, baselines, row counts) can be re-verified only through R11-06, which DEFERs on this host. R11-07 cannot close them. This matches the entry's own erratum (`:151+`, "Source-status: historical").
- **`SCORECARD.md:40` and `:62`.** With the substrate absent, R11-07 is the only *executed* pointer for both cells. `cells` counts them `row_pointed` with `row_failures=0`, because DEFER is not a failure (`:416-419`). C1 must record per-pointer status — R11-07 executed-pass (mechanism), R11-04/R11-06 deferred — and must not record "closed".
- **`SCORECARD.md:28`.** "(the two selftests re-run today)" is a round-9 statement dated 2026-09-28, not current freshness.
- **Synthetic C1 fixture.**
  - Setup: a six-axis Round section whose operability cell cites exactly one `[substrate]` row and one hermetic selftest row, run with `KAGI_SUBSTRATE=absent`.
  - Today `cells` reports CLEAN with `row_deferred=1`.
  - C1 must emit `executed-pass(scope=mechanism)` plus `deferred(substrate-absent)`, giving a disposition of partial, not closed.

## 9. Historical vs current evidence

| evidence | when / revision | standing |
|---|---|---|
| `lessons/round-9.md:122-127`, `LOG.md:205`: `--selftest` OK, seeded + wal | 2026-09-28; script `2d60981b…` | historical; same script bytes |
| row introduced (`301b9ec`) | 2026-09-28 | row bytes current and unchanged |
| `lessons/round-19-recensus.md:15` | 2026-10-14 | historical; abbreviated quote of the line |
| r22 `safe-row-plan.json:13-17`; `final-verification.json` `safe_rows` R11-07 | H1 `8ada17a`; committed `4be5da3` 2026-10-20 20:13 -0300 | latest execution. Exit 0, 2.715 s, three cases including wal, seeded `HITS=2`. Run directly with the same exit+last-line rule. Script and row bytes are identical at HEAD; host tool versions at run time were not recorded. |
| ledger-machinery or `cells` run of R11-07 | — | none current: r22 credited no verify/cells run (`SCORECARD.md:803-806`) |
| this audit | HEAD `d218603`, 2026-10-21 | static only; nothing executed |

## 10. Public source (WAL semantics behind the §2 inferences)

SQLite, "Write-Ahead Logging", page last updated 2026-08-25, accessed 2026-10-21, https://www.sqlite.org/wal.html
- §2 "How WAL Works": "A COMMIT occurs when a special record indicating a commit is appended to the WAL."
- §3.1 "Automatic Checkpoint": "SQLite will automatically checkpoint … when the last database connection on a database file closes."

## 11. Cross-row notes (not counted here) and limits

- **`SKILL.md:44`** describes the gate as "(immutable, counts-only)". That contradicts the snapshot design at `transcript-scan.sh:26-31` and `:263-274`, and it is a live-gate document issue (R11-06 / doc integration).
- **`:271`.** A failed `-wal` copy is ignored silently (`|| true`). This is a live-scan concern only. In the selftest it fails closed, via step 3's inference.
- **Limits.** No execution. Predicted outcomes come from code tracing. The WAL-residency of the fixture is inferred from default checkpoint behaviour; the fixture never shows that the row is absent from the main file. Page counts were not measured. Not re-litigated here: r22's fixture-literal finding (`build/SafetyFixture.md`) and Entry23's R11-06 baseline findings.
