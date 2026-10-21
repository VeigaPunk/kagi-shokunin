# M23-5 — round-23 real-tree `cells` safety deviation

## Scope and method

- Frozen checkout identity observed read-only: `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse HEAD` → `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (exit 0). Findings below distinguish the round-23 event from BASE and use the committed lesson/wave evidence and static source reads only.
- No `cells`, `verify`, `drift-pins.sh`, host gate, or test was run for this report. No host-private contents were read. The cited `DRIFT_PINS`/`CELL_AUDIT` results are historical evidence, not this seat’s execution.
- LSP was unavailable (`read xd://lsp` returned “No such tool”); grep was used only to locate evidence, and conclusions below rely on direct reads of the cited source/evidence.

## Reconstructed event and row accounting

The incident was a **direct real-tree `cells`** invocation. The cited evidence does not retain the shell transcript/full argv; the best-supported command is `bash corpus/claim-ledger.sh cells`, the exact R13-03 command (`corpus/claim-ledger.tsv:38`). Treat the full argv as **[INFERENCE]**. The reported line was:

```text
CELL_AUDIT: CLEAN (cells=156 row_pointed=104 stamp_pointed=87 uncited=0
missing_ids=0 rows_run=37 row_deferred=10 row_failures=0 stale_pointers=0
self_skipped=6 orphans=0)
```

The report records CLEAN, but its quoted excerpt does not record an exit code; exit 0 is inferred from the gate’s CLEAN contract/R13-03 expectation, not independently witnessed here. The committed static replication reports 43 distinct cited row IDs, six self-skips, 37 selected rows, ten deferred rows, and 27 executed rows; it explicitly identifies R18-01 as executed (`.ufo/waves/round-23/falsify/RevD1D9Intent.md:374-417`). `cells` selected cited IDs; self-invoking `claim-ledger.sh` rows were excluded, and only `[substrate]` rows were deferred when the substrate was absent (`RevD1D9Intent.md:386-397`).

**Exact row set reconstructed from the cited-ID count, the self-skip/defer sets, and the 45-row ledger.** The 27 executed IDs were:

`R11-05, R11-07, R11-10, R11-11, R12-02, R12-03, R13-01, R13-02, R15-02, R15-03, R15-04, R15-05, R16-02, R16-04, R16-05, R16-06, R17-02, R17-03, R18-01, R18-02, R21-01, R21-02, R21-03, R22-01, R22-02, R22-03, R23-02`.

This is a **static derivation**, not a preserved per-row run receipt: 43 cited IDs less six `SKIP-SELF` IDs (`R11-09, R11-08, R13-03, R14-01, R18-03, R23-01`) and ten substrate deferrals yields 27. The two ledger rows not cited in SCORECARD and therefore outside the selection are R21-04 and R22-04 (`.ufo/waves/round-23/falsify/RevD1D9Intent.md:412-417`; `.ufo/waves/round-23/parent-build/ClaimR15X03.md:96-100`).

### SCORECARD-cited host rows at BASE

The exact host-bound set reachable from the checked SCORECARD cells is **12 IDs**:

- Substrate-tagged: `R11-01, R11-02, R11-03, R11-04, R11-06, R12-01, R13-03, R15-01, R16-01, R16-03, R17-01`.
- Host-private but untagged at the incident revision: `R18-01` (`bash corpus/drift-pins.sh`).

The same list is enumerated in the round-23 safe-row account (`RevD1D9Intent.md:376-405`); the 11 tagged rows are named in the SCORECARD carried-debt cell (`SCORECARD.md:331-335`), while the `R18-01` citation is in the Round-18 post-move section (`SCORECARD.md:318-323`). On the reported substrate-absent run, ten non-self `[substrate]` rows deferred; R13-03 was `SKIP-SELF`; **R18-01 was the host-private row actually executed**. The safe-row substitute separately listed R18-01 as skipped (`.ufo/waves/round-23/final-verification.json:5-17`); that separate skip did not constrain the direct `cells` invocation. At BASE the ledger text now carries `[host]` on R18-01 (`corpus/claim-ledger.tsv:48`), but the incident revision described it as untagged, and the pre-protection `cells` path did not apply the safe-row list. A tag is not a gate unless the gate enforces it.

## R18-01 host-private path set (static, not probed)

`drift-pins.sh` declares 15 `FILES` paths, expands literal `$HOME` paths, walks the committed baseline, checks symlink/hardlink/file status and—when present—uses `stat`/`wc` plus `sha256sum` or no-hash mode (`corpus/drift-pins.sh:45-77,93-115,127-162`). The 15 targets, matching `corpus/drift-baseline.tsv:1-15`, are:

1. `$HOME/.local/bin/the-janitor`
2. `$HOME/.config/the-janitor/client.py`
3. `$HOME/.config/the-janitor/opencode.json`
4. `$HOME/.config/the-janitor/config.json`
5. `$HOME/.config/the-janitor/op.env`
6. `$HOME/.config/opencode/opencode.json`
7. `$HOME/.config/opencode/agents/janitor.md`
8. `$HOME/.config/opencode/tools/janitor_auth.ts`
9. `$HOME/.config/opencode/plugin/fnm-nudge.js`
10. `$HOME/.local/bin/tac-check`
11. `$HOME/.local/state/tac/daybreak-blue-access.json`
12. `$HOME/.local/state/the-janitor/tac-daybreak-blue.json`
13. `$HOME/.local/state/tac/handoff-status.json`
14. `$HOME/.agents/AGENTS.md`
15. `$HOME/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts/com.1password.1password.json`

The separate symbol pass reads `drift-symbols.tsv` and greps its pinned source paths (a subset of the same 15 targets), including the dotenv count/shape path (`drift-pins.sh:191-246`; `drift-symbols.tsv:11-30`). It emits paths/verdicts/counts and digest prefixes, not file contents (`round-23-verifier-spotcheck.md:150-154`). These are configured path targets, not evidence that all contents were opened during the historical incident: the committed `files_bad=15` summary is aggregate, and the spot-check labels path absence/content-unread as inference (`RevD1D9Intent.md:420-425`).

## Divergence and gate-level prevention

- The frozen round plan said no host/private gate; the direct `cells` run nevertheless re-derived the rows selected by SCORECARD, without reapplying QM12’s safe-row exclusion (`corpus/lessons/round-23.md:154`; `RevD1D9Intent.md:376-405`). This is why the separate verdict can mark R18-01 “skipped” while the later direct audit still executes it.
- The gate-level prevention is to enforce the safe-row/host classification **inside every entry point that executes cited rows**, including `cells`: host rows default to a counted `HOST-SKIP` (no invocation), and only an explicit authorized opt-in can execute them; a host-reading script without a host tag must fail closed as `POLICY untagged-host`. The round-23 spot-check’s routed D4 independently names the minimum: tag R18-01 and peers or refuse untagged host rows in `cells`, with a selftest (`round-23-verifier-spotcheck.md:193-195`). Lesson M23-5 further says direct runs must reselect against the safe list (`round-23.md:154`). A tag alone is insufficient if the `cells` execution path ignores it.
- Also refuse `~` and absolute row arguments in policy, as D4 says (`round-23-verifier-spotcheck.md:193-195`); that is an adjacent hardening, not the direct cause of this incident.
- The safe-row substitute already demonstrated the right disposition for the known row: it omitted R18-01 and recorded it skipped (`final-verification.json:5-17`). The missing safeguard was making the gate itself preserve that exclusion.

## Confidence and bounds

High confidence in the deviation, the 12-row host set, the 15 configured target paths, and the 27-row static reconstruction. Medium confidence in exact original argv and per-row execution: the committed account preserves an aggregate summary and a static reproduction, not a transcript/individual receipt (`RevD1D9Intent.md:407-425`; `round-23.md:154`). No checks were run; no tool was installed or updated.
