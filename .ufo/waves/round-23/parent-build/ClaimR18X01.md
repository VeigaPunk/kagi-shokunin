# ClaimR18X01 — R18-01 `bash corpus/drift-pins.sh` (read-only critic audit)

Seat ClaimR18X01 (critic), round 23 parent-build. Read-only: no gate, ledger row, handler, op/vault
or host command executed; no `$HOME` path probed. This report is the only write. Installs/updates: none.

Paths: `K/` = `/home/vgpnk/Projects/shokunin/kagi-shokunin/`, `U/` = `/home/vgpnk/Projects/shokunin/.ufo/`.

**Observed revision.** Frozen base `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20 21:11:59 -0300).
HEAD blobs: `corpus/drift-pins.sh` `8a2903dc`, `drift-baseline.tsv` `0a4dd3c8`, `drift-symbols.tsv` `36003532`,
`claim-ledger.tsv` `51d676d1`, `claim-ledger.sh` `f41ae333`. These files were read while the worktree equalled HEAD;
line numbers below are HEAD lines (re-checked with `git show d218603:…`). L1's later in-flight edits leave the
R18-01 row byte-identical and shift no cited `claim-ledger.sh` line (§8).
Row history: R18-01 was added at `fecee87` (2026-10-14) and never edited (`git log -G'^R18-01'`). Gate code
dates from `e64e81b` and symbols from `4b8c018` (both 2026-09-28), so the 2026-10-14 measurement and HEAD use
the same code and data.

Row (`K/corpus/claim-ledger.tsv:48`): expect `^DRIFT_PINS: DRIFT \(files_ok=0 files_bad=15 symbols_ok=0 symbols_bad=20\)$`,
exit 1, timeout 120, untagged. The note says "all-GONE summary is the measured state 2026-10-14; when the substrate returns this row fails on both exit and verdict, which IS the return-detection signal".

## 1. Verdicts

| Question | Verdict | Basis |
|---|---|---|
| Last line reproducible from code and data when no pin holds | **supported** | printf `drift-pins.sh:253-254`. 15 = `drift-baseline.tsv:1-15` = `FILES` `:45-63`, closed both ways at `:168-189`. 20 = `drift-symbols.tsv:11-30` |
| Exit 1 | **supported** | `:252-255`; dispatch `:448-452` |
| Timeout 120 | **supported** [INFERENCE] | Work is at most 15 `stat`/`wc`/`sha256sum` and 20 `grep` calls. Non-regular and symlinked paths are never read (`:130-140`, `:202-203`). Based on code shape, not a timed run |
| "all-GONE … measured state 2026-10-14" | **refuted (historical; found in earlier rounds)** | Same-day record: `~/.config/opencode/opencode.json` was present (`K/corpus/lessons/round-18.md:18-21`), with mode 600 vs pin 644 (`U/waves/shokunin12h-20261014-p1-repair/members/KagiScopeAudit.md:47-57`) |
| "fails on both exit and verdict … IS the return-detection signal" | **refuted** | Exit returns to 0 only if all 35 pins hold. The verdict changes only if at least one pin holds exactly. See §3 |
| `[substrate]` deferral preserves the row | **supported, with a dependency the docs rely on but the row does not provide** | The row is untagged, so it never defers (`claim-ledger.sh:416-419`), and R18-02 (=11) guards that. But the deferral design relies on R18-01 to signal substrate return (`substrate-deferral.md:55`, Bound 2 `:62-64`); see §4 |
| SKIP-SELF | **not applicable**, so `cells` executes R18-01 live | `claim-ledger.sh:816-820` matches only `claim-ledger.sh`. `SCORECARD.md:322` cites R18-01, so a real `cells` run re-runs it (`:802-829`) |
| Hermetic synthetic mode can preserve the obligation by *executing* the row | **refuted** | Live run reads private host files, scratch `HOME` passes by construction, fixture root has no gate (exit 127). See §5 |
| Pinned line true on the live host today (2026-10-21) | **unresolved** | No run or probe was allowed. Last credited run: 2026-10-14 (`K/LOG.md:733-735`). 2026-10-20 evidence is a static reproduction only (`K/.ufo/waves/round-22/build/Entry20.md:26-27`). The round-22 full-verify runs that did execute it are explicitly uncredited (`K/.ufo/waves/round-22/review-evidence-quarantine-closure.json:8`); I do not use them |

## 2. What actually produces the expected line

- `15`: number of rows in `drift-baseline.tsv`, with `FILES` membership closed. This is a repository count, not a host measurement.
- `20`: number of rows in `drift-symbols.tsv`. Also a repository count.
- `files_ok=0`: true when no row passes all of: regular file, not a symlink, `nlink=1`, mode, line count, and either the sha or `-` for NOHASH rows (`:127-161`).
- `symbols_ok=0`: true when no symbol pin holds. A pin holds when its file is a regular non-symlink file and the ERE matches exactly once at the pinned line, or the count pin matches (`:198-245`).

So the row's only host-dependent claim is **"0 of 35 pins hold"**. Absence implies that; it does not imply absence. Summary counters lump MISSING, DRIFT, LINK and POLICY together as files_bad, and GONE (absent or symlinked file), GONE (pattern missing), MOVED, AMBIG, COUNT and SHAPE together as symbols_bad (`:131-158`, `:203-243`). No line count or authored prose changes this. Side effects:

- An empty scratch `HOME` reproduces the line exactly.
- A reviewed baseline or symbol row edit changes the row's result with no host change. This also makes R18-01 the only exact membership pin (agreeing with `ClaimR11X04.md` §6.5).
- None of the 13 drift selftest cases (`:408-438`) asserts any summary count. They only grep verdict words.

## 3. When R18-01 changes result (from code, plus local evidence)

| Host event | R18-01 |
|---|---|
| Any hashed file comes back byte-identical, or a NOHASH file comes back with the same mode and line count | changes (FAIL) |
| Any symbol pin coincides by chance | changes (FAIL) |
| All 35 pins hold | exit 0, FAIL (the only "both exit and verdict" case) |
| Substrate returns upgraded or edited (DRIFT, MOVED or GONE pattern) | **stays green** |
| Substrate returns as symlinks (dotfile manager): LINK, and symbols report GONE `:202` | **stays green** |
| Substrate returns as hardlinks (`:134-137`) or at a different path | **stays green** |
| Shared NOHASH path `~/.agents/AGENTS.md` (pin 600/75/-, kotoba-owned `adjacency.tsv:84`) exists with mode 600 and 75 lines | **FAIL with no janitor substrate present** |

Strongest local evidence: R18-01 has already stayed green while pinned paths existed.
- 2026-10-14: 1/15 present (`lessons/round-18.md:18-21`).
- 2026-10-20: 2/15 present, `opencode.json` 0600 and `AGENTS.md` 0644, and the static reproduction still matches exactly (`Entry20.md:26-27`).

Both of those were shared, non-owned paths, so the green result was right for the janitor substrate but wrong for the note's "all-GONE" claim.

## 4. New: how R18-01 combines with deferral (false-clean at ledger level)

- `substrate_present()` checks one condition: `[[ -x $HOME/.local/bin/the-janitor ]]` (`claim-ledger.sh:145`). Bound 2 accepts that "a restored binary at a different path keeps rows deferred" (`substrate-deferral.md:62-64`). The same entry promises "Substrate return flips the verdict AND the exit, failing the row loudly" (`:55`, about R18-01).
- With the handler absent, every live drift observer that could see a returned substrate component is gone:
  - R11-04 is DEFERred (`:416-418`).
  - R18-01 stays green for any return that does not match a pin exactly (§3).
- Result: `CLAIM_LEDGER: CLEAN (… deferred=11 …)` while the drift gate's own output contains `DRIFT`, `COUNT` or `SHAPE` findings for a returned owned-prefix path (`adjacency.tsv:48-52`). That includes count and shape changes to the dotenv inventory, which the gate was built to catch (`drift-pins.sh:332-334`).
- Someone already relies on the overclaimed property. In `K/considerthese/2026-10-20.md:93-95`, the lane withdrew its own proposal for an explicit "substrate absent" verdict because "R18-01 already pins … and fails when it returns". `Entry20.md:37` also calls it "a valid absence pin" despite its own 2/15 observation at `:27`.

## 5. SKIP-SELF and the hermetic modes

| Mode | What happens to R18-01 | Preserves the obligation? |
|---|---|---|
| bare `verify` / real `cells` | Executed live. `cells` reaches it through `SCORECARD.md:322` | Yes, but it reads private host files including the dotenv count and shape (`drift-pins.sh:209,222`), which is outside authorization (`K/corpus/QUALITY.md:60`, `K/SKILL.md:713-716`) |
| `KAGI_SUBSTRATE=absent` | Still executed live, because the row is untagged | No hermeticity (agreeing with `ClaimR11X04.md` §5) |
| `--root <fixture>` | `cd $ROOT` only (`claim-ledger.sh:426`). Paths still resolve under `$HOME`. If the fixture lacks the gate, exit 127 and a **false FAIL** | No |
| Scratch `HOME` | Always prints the exact pinned line (F4) | **No**: it passes by construction. It proves the 15/20 membership hermetically, never the host claim |
| Not executed, id listed with reason (QM12; round-22 `final-verification.json:572-576`) | Carried | **Yes**. This is the only honest disposition |

Real `cells` counts each **cell** as pointed (`claim-ledger.sh:775`). The `SCORECARD.md:322` cell also cites R18-02 and R11-09, so leaving out R18-01 silently would leave cell counters unchanged. It must be accounted for per row. `rows_run=$C_N` (`:828`) also counts deferred and POLICY rows (`C_N` is incremented at `:415`), so it is not evidence of execution. I mention this only as an R18-01 accounting constraint; the R13-03 owner handles the rest.

## 6. One consumer-visible risk and a minimal synthetic falsifier (proposed for L1; not executed)

**Risk (false-clean; calibration and freshness).**
- **Setup:** the janitor substrate partly returns, for example the `~/.config/the-janitor/` config tree is restored or upgraded, while the handler is absent or at another path.
- **What R18-01 shows:** it keeps printing "substrate absent", and R11-04 stays deferred.
- **Ledger result:** `verify` is CLEAN.
- **Who is misled:** readers of R18-01's note, `substrate-deferral.md:55` and `SCORECARD.md:322`.

Here `S` is a fresh `mktemp -d` used as `HOME`, and every command runs from `K`. The gate reads only `$S` and the repository TSVs. The fixtures contain no secret material.

- **F1 (row level, hermetic).** Create `$S/.config/the-janitor/opencode.json` containing `{}` with mode 644, then run `HOME="$S" bash corpus/drift-pins.sh`.
  - Expected from the code: 14 MISSING; 1 `DRIFT … lines 29->1 sha …` (mode matches); 3 `GONE … (pattern no longer present)` from `drift-symbols.tsv:19-21`; 17 `GONE … (file absent or a symlink)`.
  - Last line: `DRIFT_PINS: DRIFT (files_ok=0 files_bad=15 symbols_ok=0 symbols_bad=20)`, exit 1. That satisfies R18-01.
  - Falsifier assertion, which follows the note's own claim: "an existing owned-prefix pinned path makes R18-01 fail". The current code violates it, so the fixture goes red.
- **F2 (ledger level, optional).** Use the same `S` and a claims fixture holding `claim-ledger.tsv:18` and `:48` byte for byte, with stamps and docs fixtures built the way the selftest builds them (`claim-ledger.sh:1422-1424`). Do not set `KAGI_SUBSTRATE`.
  - Expected from the code: `DEFER R11-04 reason=substrate-absent`, R18-01 passes, `CLAIM_LEDGER: CLEAN (claims=2 deferred=1 …)`, exit 0.
- **F3 (mirror false-fail).** Create `$S/.agents/AGENTS.md` with `seq 75` and mode 600.
  - Expected: `DRIFT_PINS: DRIFT (files_ok=1 files_bad=14 symbols_ok=0 symbols_bad=20)`, so R18-01 reports `FAIL reason=verdict-not-final`, which reads as "substrate returned".
  - In fact no owned-prefix path exists and the 11 tagged rows still DEFER. The ledger then reports return and absence at the same time.
  - Live relevance [INFERENCE]: `AGENTS.md` was 0644 on 2026-10-20 (line count not recorded). If its owner sets it to 0600 and it has 75 lines, this fires.
- **F4 (C3 trap).** Run with an empty `$S`. Output is exactly R18-01's line, exit 1, with no host contact.
  - C3 acceptance falsifier: a hermetic cells fixture whose only cited row is an R18-01 clone must **not** print `CELL_AUDIT: CLEAN … rows_run=1 … row_failures=0`. It must print an explicit unexecuted host-bound line for that id and count it on the verdict line (QM3).

## 7. What C3 and C1 integration must retain for R18-01

**C3**
1. R18-01 is never executed in hermetic runs, whether live, with scratch `HOME`, or at a fixture root. It stays an explicit skipped id with the reason "untagged; reads `$HOME` drift surfaces incl. dotenv count/shape".
2. It is never counted in `rows_run`, and R23-01's CLEAN is never credited for `SCORECARD.md:322`.
3. Any C3 classifier that relies only on `[substrate]` misses this row, so a command-surface or explicit-id class is required (agreeing with ClaimR11X04).
4. R13-03's host skip must stay as long as any scored cell cites R18-01.

**C1** (follow pointers, not counts)
- **O1, the note overclaim.** Found by KagiScopeAudit §2 (High) and by `KagiGateRepair.md:119,127`, both 2026-10-14. Still **open**: the row is unchanged since `fecee87`, and R18-01 is absent from the round-22 `claim_changes` list.
- **O2, `SCORECARD.md:322` describes R18-01 as "`sha256sum` on the handler path, exit 1 'No such file'".** Entry20 C4 (`Entry20.md:47`) was closed **only for R18-02** (`K/.ufo/waves/round-22/pin-migrations-integration.json:424-426`). SCORECARD has no erratum, so the R18-01 part is open. Counting "C4 → migration exists" would wrongly close it.
- **O3, deferral's reliance on R18-01** (`substrate-deferral.md:55`, `:62-64`). New in this report.
- **O4, `Entry20.md:37` "valid absence pin".** Mark it superseded: it is an active claim contradicted by `:27` of the same file.
- **O5, bare `verify`/`cells` still execute R18-01 live** (`:416`, `:816`). The in-flight D3 disposition marked "fixed" covers the token guard, not this default path, and must not be read as closing it.
- **Scope gap.** O1–O5 come from outside the round-22 spot-check's 15 obligations, so a C1 CLEAN says nothing about them.
- **Reverify links are not re-checks.** `substrate-deferral.md:13` `Reverify: R18-01, R11-09` is a row link, not a re-check of that entry's counters (Entry20 freshness gap; found in an earlier round).

**Separating fixable defects from claims to reject.**
- Fixable defects: O1, O2, O3, O4, and the C3 accounting.
- Claims a judge must reject if anyone asserts them: R18-01 as a substrate-return detector, a scratch-`HOME` R18-01 pass as host evidence, and D3/D9 "fixed" as covering R18-01's exposure.

## 8. In-flight observation (uncommitted worktree, 2026-10-21; not audited)

- `plans/round-23.md:35-42` and the R23-01 row use `corpus/fixtures/cells-hermetic/` with only two synthetic rows. R18-01 is neither executed there nor carried there. It must therefore be carried by the safe-row skip list (§7 C3.1).
- R18-01 is unchanged in the worktree.
- In-flight R23-01 and R23-02 notes do not contain the literal tag, so R18-02 stays at 11.

## 9. Smallest safe correction

1. **Rewrite the R18-01 note in place with an old/new journal** (QM14). Leave expect, exit and timeout unchanged. Proposed text:
   > no-pin-holds pin (files_ok=0 symbols_ok=0; 15/20 = committed baseline/symbol rows, so it also pins membership). At the 2026-10-14 measurement 1/15 path was present but drifted. Flips only when some pin holds exactly; drifted, upgraded, symlinked, hardlinked or relocated returns stay green; a mode+lines match of the shared no-hash AGENTS.md flips it without substrate return. Reads `$HOME` drift surfaces; skipped by id in hermetic and safe-row runs; untagged by design.

   **Trap:** the note must not contain the literal bracket tag. If it does, `claim-ledger.sh:416` defers R18-01 and R18-02 reads 12.
2. **Append-only errata:**
   - `SCORECARD.md`: the Round-18 post-move freshness cell's R18-01 description.
   - `substrate-deferral.md`: line 55, plus a Bound 2 note that a partial non-identical return with the handler absent leaves `verify` CLEAN.
3. **C3 / QM12:** apply §7 C3.1–4.
4. **Optional gate change** (needs a host-authorized re-measurement, so it is not "smallest"):
   - Add per-class counts (missing, present) to the DRIFT summary.
   - Scope the absence claim to the five owned prefixes.
   - Add a selftest case that asserts summary counts.
   - Only R18-01 would need to migrate. R11-04 and checklist E1 pin the CLEAN line. Docs to update: `knowledge/drift-gate.md:86-87`, `SKILL.md:206-207`.

**Axes:**
- Calibration: the note, entry and scorecard all overstate what the row measures.
- Freshness: a partial or non-identical return is invisible.
- Operability: the row cannot be preserved by execution in any hermetic mode, and the note edit has the tag trap.

## 10. Overlap with earlier rounds and other seats (not re-derived here)

- The note "all-GONE" overclaim and the `SCORECARD.md:322` mismatch: KagiScopeAudit §2, KagiGateRepair #3, Entry20 C4.
- The `-x` directory predicate, and the summary being unable to tell "13 absent + 2 diverged" from "15 absent": Entry20 C1, `ClaimR11X04.md` §8.
- `KAGI_SUBSTRATE` cannot make R18-01 hermetic: `ClaimR11X04.md` §5.

**New here:** the causal decomposition (§2), the ledger-level false-clean from combining with deferral and the documented reliance on it (§4), the evidence that a consumer already relied on it (`considerthese:93-95`), the per-row accounting gap and `--root` false-fail (§5), the F1–F4 fixtures, the partial C4 closure, and the note-edit tag trap.

## 11. Limits

- I ran no gate, row or fixture. Every expected output above is derived from the HEAD code.
- I did not probe the host. The 2026-10-14 and 2026-10-20 states come from other seats' records and static reproductions.
- The current host truth of the pinned line is unresolved.
- I did not judge the correctness of the in-flight C1/C3 files.
- No public sources were used.

Report: .ufo/waves/round-23/parent-build/ClaimR18X01.md
