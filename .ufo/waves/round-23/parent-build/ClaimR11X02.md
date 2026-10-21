# ClaimR11X02 — audit of row R11-02 (`surface-census.sh --verbs`)

- Revision checked: kagi HEAD `d218603b74099ddca0bd8f869516fc41db0979bf` (jj `@` 4410ccad8829). The only untracked items are `.ufo/waves/round-23/`, `plans/round-23.md` and `corpus/closure-dispositions.json`.
- Production root: `/home/vgpnk/Projects/shokunin/kagi-shokunin`. Every short path below is relative to it.
- Mode: read-only and static. I did not run the census, the ledger, any gate or the handler.
- What I did run:
  - `sha256sum`, plus read-only `git log`, `git show` and `diff` on kagi.
  - Python JSON reads.
  - Two pure bash language checks: how bash imports environment variables, and how `[[ =~ ]]` matches the row's regex.
  - One host presence check, `ls ~/.local/bin/the-janitor`, which returned "No such file".
- Row bytes (`corpus/claim-ledger.tsv:16`) are identical to `.ufo/waves/round-22/frozen/before/corpus/claim-ledger.tsv:16` (checked with `diff`).

```
R11-02  bash corpus/surface-census.sh --verbs  ^SURFACE_CENSUS_VERBS: CLEAN \(pass=[1-9][0-9]* skip=[0-9]+\)  0  300  write-side verb probes, scratch overrides only, no op exec [substrate]
```

## 0. Verdicts

| Question | Finding |
|---|---|
| Verdict, last line, exit and timeout justified? | **Supported, with one gap.** The CLEAN line follows causally from what the handler does, and exit 0 occurs only with CLEAN. The gap: the probe counts are not pinned, so a run that has silently been escalated to the deep probes also matches (§2, §4). |
| `[substrate]` deferral keeps the obligation? | **Supported as an open obligation.** Today the row is deferred (`DEFER`) and never executed. However, the presence check and the thing being measured are different binaries (§3). |
| SKIP-SELF | **Not applicable, which is correct.** The command does not contain `claim-ledger.sh`. |
| Synthetic (no-host) mode | **There is none for this row's content.** Round 22 skipped the row explicitly by ID, so the obligation stays open rather than being counted as passed. |
| Consumer-visible risk | **False clean on the safety half of the obligation.** An ambient `DEEP` environment variable turns the default probe set into the `--deep` set, and the row still passes (§4). |

## 1. What the row promises

The obligation has two halves.

**(a) Functional.** Seven default probes must PASS against the handler:
- `cdp-ensure-scratch` (`corpus/surface-census.sh:477`)
- `cdp-ensure-missing-support` (`:505`)
- `refs-redaction` (`:518`)
- `refs-shape-table` (`:535`)
- `refs-redaction-prefix-only` (`:568`)
- `usage-guards` (`:652`)
- `status-contract` (`:674`)

This is a characterization of recorded behavior, not a correctness proof. For example, `refs-redaction-prefix-only` passes only while the known redaction leak F1 is still present. Fixing the handler flips the row to FAIL on purpose (`:560-567`). CLEAN means "behaves as recorded", not "safe".

**(b) Safety.** Scratch overrides only, and no `op` is executed. Sources:
- the row note
- `SKILL.md:36`, which lists "running `--deep` unattended" as an anti-pattern
- `corpus/knowledge/surface-census.md:144-146`

## 2. Expected tuple: what causes the last line

**How CLEAN is produced.** The script prints `CLEAN (pass=N skip=M)` only when `PROBE_FAILS==0 && PROBE_PASSES>0` (`surface-census.sh:869-873`).
- The counters change only through `check()` and `probe_close()` (`:445-463`).
- A probe PASSes only if none of its checks failed. Those checks compare what the handler actually produced: exit codes, files, modes, JSON fields and stdout substrings.
- So CLEAN is downstream of real handler behavior, not a printed constant.

**Other outcomes, all fail-closed:**
- `DEGRADED (pass=0 …)` exits 1 (`:874-881`). This is the round-11 CE1 fix (`corpus/lessons/round-11.md:151`).
- `FAILURES …` exits 1 (`:883-884`).
- `die` exits 2 when the handler cannot be resolved (`:469`) or the scratch root is bad (`:470-473`).

The ledger checks exit equality first, then matches the last non-empty line against the regex (`corpus/claim-ledger.sh:426-443`).

**The `[1-9]` floor** duplicates the script's own fail-closed branch. That is defense in depth: supported.

**Counts are not pinned.** The script's hash still matches its stamp: `corpus/stamps.tsv:63` = `275d8294…`, recomputed today. Given that, a legitimate default run that reaches CLEAN can only print `pass=7 skip=3`:
- probes 1-4b, 8 and 9 can only PASS or FAIL;
- probes 5-7 SKIP unless `DEEP` is non-empty.

The regex, however, also accepts `CLEAN (pass=10 skip=0)` and `CLEAN (pass=9 skip=1)` (checked with bash `[[ =~ ]]`, the same matcher the ledger uses at `:441`). So the row cannot tell a default run from a deep run.

**No `$` end anchor.** Harmless, given the fixed printf at `:872`.

**Timeout 300.** No wall time has ever been recorded for the default mode; `--deep` was "≤25 s" (`corpus/knowledge/surface-census.md:251`). 300 s is a generous bound, not a measured one. Even with a leaked `DEEP`, the internal bounds (20 + 25 + 20 s at `:590`, `:612`, `:634`) fit inside 300 s, so the timeout would not catch the escalation either.

## 3. Deferral, SKIP-SELF and synthetic mode

### Deferral

- On this host `$HOME/.local/bin/the-janitor` is absent, so `substrate_present()` (`claim-ledger.sh:140-146`) is false.
- The ledger then prints `DEFER R11-02 reason=substrate-absent` and never runs the command (`:415-418`).
- A deferred row is not a pass (`corpus/knowledge/substrate-deferral.md:59-61`). The obligation is carried, not discharged.

### Presence check vs. measured binary

The ledger defers based on the *file* `-x $HOME/.local/bin/the-janitor`. The census measures whatever `command -v ${THE_JANITOR_BIN:-the-janitor}` resolves to (`surface-census.sh:82,469`). These can differ in two ways:

1. **Pinned file present but not on PATH: false fail.** Already reported by `ClaimR11X03.md` §3-4; not repeated here.
2. **Different binary earlier on PATH, or `THE_JANITOR_BIN` set (new for this row).** R11-02 then certifies that other binary. `substrate-deferral.md:62-64` says "a poisoned stub at the pinned path un-defers them into real FAILs". For R11-02 that does not hold: a poisoned pinned stub plus a working binary earlier on PATH gives CLEAN.
   - The aggregate ledger still goes red only if R11-04's hash pin on the pinned path fires.
   - Status: the bound is refuted as written for this row [static inference].

### Undeclared third-party dependency (false fail; secondary)

- Probe 1 leaves BrowserSupport at its host default (`:485`, `:498`) and expects success.
- Probe 2 (`:509`) asserts that the handler *correctly refuses* exactly that input when BrowserSupport is missing.
- So if the handler comes back on a host without 1Password's BrowserSupport, probe 1 fails by construction even though the handler follows its contract. The result is `FAIL … exit-mismatch exit=1`.
- `[substrate]` does not cover this dependency: it means the handler plus its state/config tree (`substrate-deferral.md:27-29`).
- The dependency is currently satisfied according to round 22's observation (`.ufo/waves/round-22/build/Entry03.md:37`: present, `1password-beta 8.12.42_34.BETA-1`, 2026-10-20). That is historical; I did not re-check it.

### SKIP-SELF

- Not applicable: the skip triggers only on commands containing `claim-ledger.sh` (`claim-ledger.sh:816`).
- So `cells` re-runs or defers R11-02 whenever a cell cites it.
- The only cell that cites it is `SCORECARD.md:50` (Round 10 post-move, operability; heading at `:45`).
  - It cites only R11-02 and R11-03, both `[substrate]`, and contains no stamped artifact.
  - On a host without the handler, that cell has no live evidence. It is still counted as `row_pointed`, and `CELL_AUDIT: CLEAN` can print (`:1011`).
- `rows_run` is set from `C_N` (`:828`), and `C_N` is incremented *before* the DEFER branch (`:415-416`). So `rows_run` also counts deferred rows and overstates execution whenever `row_deferred>0`.

### Synthetic (no-host) mode

None exists for the probes' content:
- The census selftest's verb cases either run the real handler or print `skip-case` (`surface-census.sh:815-824`).
- The ledger selftest proves only the deferral mechanism, on a synthetic row (`claim-ledger.sh:1422-1424`).
- Round 22 listed R11-02 explicitly by ID as "Not executed": `.ufo/waves/round-22/safe-row-plan.json:233-238` and `.ufo/waves/round-22/final-verification.json:523-526`. It stayed open; nothing counted it as passed.

## 4. Consumer-visible risk: `DEEP` from the environment turns the safe set into the deep set (false clean)

**Cause (static, current bytes, unchanged since `03477c0`).**
- `DEEP` is missing from the defaults block (`surface-census.sh:75-83`).
- Only `--deep` sets it (`:91`).
- It is read as `${DEEP:-}` at `:584`, `:604` and `:626`.
- Bash imports environment variables as shell variables. My language check (bash 5.3.20, `set -euo pipefail`) gave `deep-set` with `DEEP=1` in the environment and `default-set` without it.
- The ledger passes its environment straight to the child (`claim-ledger.sh:426-427`).
- `DEEP` is not in the census's documented environment list (`surface-census.sh:65-69`).

**Effect, on a host where the handler is present.** If `DEEP=<non-empty>` is in the environment, `bash corpus/claim-ledger.sh verify` (or `cells`) runs R11-02 as the deep set:
- it runs `"$JANITOR" run -- sh -c …`, which runs `op run` (`:590`, `:612`);
- it can raise the 1Password desktop prompt;
- it hashes the real custody record and runs the real `tac-register` (`:625-636`).

The last line becomes `CLEAN (pass=10 skip=0)`, or `pass=9 skip=1` if the custody record is absent. Both match R11-02's regex (§2), so the row PASSes. A reader sees R11-02 green and assumes "scratch only, no op exec". The only visible trace is `skip=0` instead of `skip=3`, which nothing asserts.

**This is not the accepted environment bound.** `substrate-deferral.md:70-73` accepts tampering with `KAGI_SUBSTRATE`, which is namespaced, documented and changes only the *verdict*. `DEEP` is generic, undocumented and changes *side effects*.

**External corroboration.** Tameshi's round-12 BashWitness ran over the same bytes (sha `275d8294…`, source `fecee87`). It removed `DEEP` from the environment before running, together with `THE_JANITOR_BIN`, `SQLITE3_BIN`, `CENSUS_BREAK` and `ONEPASSWORD_BROWSER_SUPPORT`. See `/home/vgpnk/Projects/shokunin/tameshi-shokunin/.ufo/evidence/round-12/BashWitness/summary.json:65` (generated 2026-10-20T03:54:26Z).

**Exposure today:** none. The handler is absent and the row is deferred. The risk is live from the moment the substrate returns. I sent this to `agent://KagiR23`.

### Minimal synthetic falsifier (proposal for L1; NOT run; no passing result claimed)

It uses a stub binary, a scratch HOME and a scratch tmux directory. It touches no live handler, `op`, tmux server or custody record.

```bash
F=$(mktemp -d); mkdir -p "$F/home"
printf '#!/bin/sh\nprintf "%%s\\n" "$*" >>"$F_LOG"\nexit 0\n' >"$F/stub"; chmod 700 "$F/stub"
F_LOG="$F/calls" HOME="$F/home" TMUX_TMPDIR="$F" THE_JANITOR_BIN="$F/stub" DEEP=1 \
  bash corpus/surface-census.sh --verbs --verb-root "$F/v" >"$F/out" 2>&1
grep -c 'requires --deep' "$F/out"   # contract (row note, SKILL.md:36): 3
grep -c '^run -- sh -c' "$F/calls"   # contract: 0   (probe 8's `run -- true` is excluded)
```

- **Prediction for current source** [static inference]: `0` and `2`. Probes 5 and 6 call `run -- sh -c`; probe 7 SKIPs because the scratch HOME has no custody record.
- **Control:** the same command without `DEEP=1` should give `3` and `0`.
- The final line will be `FAILURES`, because the stub fails the content checks. The falsifier asserts the side effects, not the verdict.
- As an L1 selftest case: it fails today and passes after the fix. Adding it changes R11-03's case count, which needs a re-pin per QM14.

### Fix options (L1's call)

1. Add `DEEP=""` to the defaults block (`surface-census.sh:75-83`).
2. Tighten R11-02's regex to `^SURFACE_CENSUS_VERBS: CLEAN \(pass=7 skip=3\)$`.
   - This loses nothing for legitimate runs while the script stays stamp-pinned.
   - It turns any escalation, or any change to the probe set, into a loud row FAIL.
   - It needs a QM14 migration record.

## 5. What C3 (synthetic `cells`, R23-01) must keep for this row

- **The fixture must contain no `[substrate]` row and no row that calls `surface-census.sh`.**
  - Deferral reads `$HOME`, not `--root` (`claim-ledger.sh:140-146`).
  - A row command cannot pin `KAGI_SUBSTRATE` or clear `DEEP`. The allowlist is `bash|grep|sha256sum|wc|test|python3` (`:160`), it has no `env`, and `the-janitor` is a denied word (`:167`).
  - Plan reference: `plans/round-23.md:32-39`.
- **Pin `row_deferred=0` and a concrete `rows_run`** in R23-01's exact `CELL_AUDIT` line. Then a tagged row that slips into the fixture fails loudly. Remember that `rows_run` includes deferred rows (§3).
- **Account for R11-02 as a carried live obligation that is not covered.** Do not cite R23-01 as evidence for `SCORECARD.md:50`. R13-03 keeps its explicit host skip.
- **Proving the verbs harness without a host** is possible only inside a census selftest. That means a stub via `THE_JANITOR_BIN`, a scratch HOME and tmux directory, and `DEEP` cleared. It proves the harness, not the handler (QM4 wording).

## 6. What C1 (closure-disposition checking) must keep for this row

- **R11-02 is not a closure obligation.** It is not mentioned in `corpus/lessons/round-22-verifier-spotcheck.md`, whose D items are at `:165-183`. The untracked draft `corpus/closure-dispositions.json` covers only SPOT-01..05, ADJ and D1-D9. C1 must neither disposition nor count R11-02.
- **D9's `fixed` pointer stops at R23-01's parser proof.** It does not re-verify `SCORECARD.md:50`, or the six entries linked to R11-02:
  - `cdp-bridge-1password`
  - `janitor-command-surface`
  - `janitor-env-contract`
  - `op-cli-surface`
  - `op-env-refs`
  - `surface-census`

  `janitor-command-surface` and `janitor-env-contract` rest only on R11-02 and R11-04, both `[substrate]`.
- **Allowed state for R11-02** in any report: `deferred(substrate-absent)`. Never `fixed`, `verified` or `pass`.

## 7. Historical vs current evidence

| Date | Evidence | Status |
|---|---|---|
| 2026-09-28, round 10, `03477c0` | `--verbs` gave `CLEAN (pass=7 skip=3)`; `--deep` gave `(pass=10 skip=0)` (`corpus/knowledge/surface-census.md:9-11,250-251`; `SCORECARD.md:50`) | historical author run; `verbs()` body unchanged since this commit (`git log -L`) |
| 2026-09-28, round 11, `301b9ec` | DEGRADED branch added; row created with the anchored `pass=[1-9]` regex (`lessons/round-11.md:151`) | the verbs result logic was last changed here |
| 2026-09-28T23:31–23:36Z, `301b9ec` with uncommitted edits | non-author cold run: `CLEAN (pass=7 skip=3)`, exit 0 (`corpus/lessons/round-8-aggregator-box3-coldrun.md:5,23`) | last affirmative live receipt |
| 2026-10-14, `fecee87` | `[substrate]` tag added to the row (diff); substrate absent | deferred since |
| 2026-10-20, round 22 | skipped by ID, "Not executed" (`final-verification.json:523-526`); BrowserSupport present (`build/Entry03.md:37`) | open obligation; host fact dated |
| 2026-10-21, now, `d218603` | row bytes unchanged; handler absent at the pinned path; script hash = stamp | `DEFER`; no current execution |

## 8. Limits

- **Nothing was executed against the substrate.** Every verdict claim is reasoned from the cited lines. The falsifier outcome is a prediction.
- **The handler source is absent.** Handler-side behavior comes from historical knowledge entries:
  - `corpus/knowledge/cdp-bridge-1password.md`
  - `corpus/knowledge/janitor-command-surface.md`
  - Both carry round-22 "historical" errata.
- **Inference, not run:** the PATH-shadow and BrowserSupport scenarios. BrowserSupport presence was not re-checked.
- **Minor, not escalated:**
  - `--verbs` without `--verb-root` never removes its own `mktemp -d` directory (`:467`; `CLEANUP_DIRS` gets only the snapshot directory, `:275`). It leaks fabricated env files into `/tmp` on every run.
  - The deep probe 6 carries a literal ref-scheme string (`:608`). That contradicts the "assembled at runtime" rule (`:105-109`).
- **Scope:** held to R11-02. The overlap with R11-03 is cited, not redone. No sibling-lane git operations; the tameshi file was read from disk only.
- **Tools:** read, grep, bash, python3, and bash 5.3.20 for the language checks. No installs or updates.

Report: .ufo/waves/round-23/parent-build/ClaimR11X02.md
