# Round 24 C1 — host-row safety review

**Scope:** Static review of `plans/round-24.md` §C1 and the checked-in `corpus/claim-ledger.sh`/`claim-ledger.tsv` snapshot. No commands, gates, tests, or host probes were run; no runtime result is claimed.

## Findings

### HIGH — Ambient environment consent is inherited, and expands through nested audits

**Exploit path:** The plan authorizes host rows whenever `KAGI_HOST_ROWS=run` (plan:16–17). Any exported value inherited from a login shell, wrapper, CI job, or parent claim process is indistinguishable from deliberate consent. A later ordinary `claim-ledger.sh verify`/`cells` can therefore run every tagged host row. Claim commands inherit exported variables: `verify_claims` sets only `CLAIM_LEDGER_DEPTH` before `timeout bash -o pipefail -c "$cmd"` (claim-ledger.sh:526–527). A tagged row that invokes nested `claim-ledger.sh cells` can pass that same opt-in to the nested audit, which may run other cited host rows.

**Evidence / impact:** The plan's env-based consent conflicts with the source snapshot's safer contract: the header says no environment variable is honoured (claim-ledger.sh:105–113), the parser enables rows only for `--allow-host-rows` (line 294), and the selftest has an env-not-consent case (line 1556). Nested `verify` is refused by the depth guard (lines 317–325), but nested `cells` is not; `SKIP-SELF` at lines 918–929 only skips the row invoking the gate while `cells_evidence` runs. The planned environment opt-in would make consent ambient and permit nested host-row execution, not just one top-level check.

**Smallest remediation:** Keep the explicit top-level `--allow-host-rows` switch and reconcile the plan to it; do not treat `KAGI_HOST_ROWS=run` as authorization. Also refuse nested `cells` from claim execution (except the explicitly host-free fixture mode), or ensure nested audits cannot inherit host authorization. Environment-based consent cannot distinguish a deliberate setting from an inherited one.

### HIGH — Tag parsing plus an incomplete script inventory leaves unclassified Bash rows executable

**Exploit path:** Add a host-reading script not in the declared list, e.g. `bash corpus/new-host-reader.sh`, and put a misspelled tag (`[hots]`) in its note or place `[host]` in a non-note column. The general policy accepts `bash` (claim-ledger.sh:234); `is_host_note` recognizes only literal `[host]`/`[substrate]` in the note argument (lines 164–166), and the note is read only from field 6 (line 496). The host-invocation backstop covers only the seven script names in `HOST_SCRIPT_RE` (lines 168–185, 214–220). An unlisted command is neither classified nor refused and reaches execution (lines 504–527).

**Precision:** A typo/misplaced tag on one of the currently listed host-reading scripts is refused as `untagged-host` (lines 511–514); the gap is the open-ended `bash` command allowance and incomplete inventory, not every misspelling in every case.

**Impact:** A new host reader or renamed script can silently run by default despite a nearly-correct/misplaced tag. A tag in the wrong field is not a schema error.

**Smallest remediation:** Make tag data a closed, validated field (or validate exact tag tokens only in the note and reject reserved tags elsewhere); reject unknown tag spellings. Put Bash script/mode classification behind a closed registry: each executable script/mode must be explicitly host-free or host-bound, with unknown scripts refused before execution. Do not rely on a growing regex as the only backstop.

### HIGH — `KAGI_SUBSTRATE=present` is an unrestricted test override

**Exploit path:** The host-presence function accepts `KAGI_SUBSTRATE=present` or `absent` in every mode, not only selftest (claim-ledger.sh:146–162). With the plan's ambient host opt-in also inherited, `KAGI_SUBSTRATE=present` makes `[substrate]` rows eligible to run even when the actual handler is absent. It must not become a second authorization switch or defeat host-row skipping.

**Evidence / impact:** Current order is fail-closed for the default path: host authorization is checked before substrate deferral (lines 516–523), and the current selftest explicitly expects `KAGI_SUBSTRATE=present` alone to produce `HOST-SKIP` (lines 1554–1555). Preserve that property. However, the comment says the substrate override is for selftest (lines 154–155) while the function itself does not enforce that scope; a test override can falsify the real substrate premise once a caller has enabled host rows.

**Smallest remediation:** Keep host authorization independent and first. Restrict the substrate override to scratch selftest fixtures (or inject the predicate directly into fixture tests); outside selftest, use observed presence only. Test `KAGI_SUBSTRATE=present` alone as a no-run case, and test that `absent` cannot be overridden into execution by ambient state.

### MEDIUM — Selftest does not establish an environment-clean boundary

**Exploit path:** `--selftest` clears `CLAIM_LEDGER_DEPTH` but does not clear a prospective `KAGI_HOST_ROWS` opt-in before launching its many `$0` subprocess cases (claim-ledger.sh:1141–1150, 1386–1397). Under the plan's env design, a caller invoking selftest from an opted-in parent passes consent into every fixture audit. The existing `host-env-not-consent` case (line 1556) would also cease to assert the plan's behavior if the env variable becomes authorization.

**Impact:** The selftest's “scratch-only” guarantee becomes dependent on caller environment and future fixture contents; it can execute rows instead of proving their default rejection. Existing `tcase` checks exit/output only, not absence of side effects (lines 1386–1397).

**Smallest remediation:** At selftest entry, clear host authorization and any substrate override before running cases. Exercise positive authorization only in isolated scratch fixtures. For every refusal/skip case, use a fixture probe that would create a marker only if invoked and assert the marker (and fixture file set/digest) is unchanged. Do not accept a passing refusal string as proof of zero mutation.

### LOW — A skipped host row can still yield a `CLEAN` summary

`verify` and `cells` count `HOST-SKIP` without failing; the summary can still be `CLAIM_LEDGER: CLEAN` / `CELL_AUDIT: CLEAN` with `host_skipped=N` (claim-ledger.sh:1089–1095, 1118–1124). This is not an execution bypass, but a caller matching only `CLEAN` can treat an incomplete check as fresh. Prefer an explicit `PARTIAL`/incomplete status when host rows were skipped, or require full-verification callers to assert `host_skipped=0`.

## Minimum selftest matrix

All cases must use a scratch-only probe that writes a marker inside the scratch root; rejected or skipped cases assert no marker/change, not just exit/output.

1. `verify` and `cells`: exact `[host]` and `[substrate]` rows are skipped by default; `KAGI_SUBSTRATE=present` alone still skips; skipped count is explicit. With explicit opt-in, only a synthetic scratch row runs.
2. Bad tag spellings and `[host]`/`[substrate]` in every non-note field are malformed/refused before the probe runs. Include an unregistered Bash reader to prove unknown scripts fail closed, plus a listed reader control to retain the existing `untagged-host` check.
3. Substrate matrix in scratch: absent substrate defers without running; present override is honored only by the selftest fixture path, never as real-mode authorization. Host opt-in remains a separate condition.
4. A claim row that invokes nested real-tree `cells` is refused or constrained to the host-free fixture root. A nested fixture containing another tagged probe must not run merely because the parent has opt-in; direct nested `verify` remains refused.
5. Invoke selftest with host opt-in and substrate override inherited; assert it clears them before fixture audits and produces no probe marker outside its scratch root. A separate controlled positive fixture proves explicit opt-in.
6. For every POLICY/skip/defer rejection above, snapshot the scratch fixture before and after and assert zero mutation. Report `CLEAN` only when the result is complete, or assert/check the `host_skipped` count explicitly.

**Disposition:** The current explicit `--allow-host-rows` approach is safer than the plan's inherited env consent. Retain that choice, close tag/script classification, scope substrate overrides to selftest, and make rejected cases prove zero mutation.