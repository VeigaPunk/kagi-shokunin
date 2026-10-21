# Round 24 sibling ledger overlap

## Scope and evidence

Read-only scan of the 20 sibling `*-shokunin` repositories (excluding Kagi). A case-sensitive search for `HOST-SKIP`, a complete `[host]`/`[substrate]` tag token, `KAGI_HOST_ROWS`, and `untagged-host` returned no matches; a filename search found no sibling `claim-ledger.sh`. In the scanned example lanes, I found no reusable bracket-tag spelling or claim-row `policy_check` convention equivalent to Kagi's. Do not treat incidental `[HOST]` headings or `[host]:port` syntax as row tags.

Relevant reusable patterns:

- **Skip is a visible, counted scope—not a pass.** Mado's `--no-live` emits a per-row `SKIP` with reason (`mado-shokunin/tools/mado-verify.sh:3185-3188`), tallies `pass/fail/unknown/skip/note` (`:113-114,4180`), and qualifies CLEAN as “file plane only — live layer skipped” (`:4182-4186`). Its help and environment use a lane/tool namespace and finite values (`:109-127`). This is the closest output convention for Kagi's host-row skips.
- **Exempt records stay in the accounting.** Chousa documents unresolved/exempt hops as counted and specifies `RESOLVED_HOPS=N/M`, with CLEAN based on the non-exempt denominator (`chousa-shokunin/tools/research-gate.sh:83-89`); its integrity tally likewise counts exempt references (`:151-153`).
- **Keep test controls namespaced and scrub behavior-changing inherited values.** Tameshi drops the gate-sensitive environment variables before the sweep and records resolved tool/PATH facts (`tameshi-shokunin/tools/bash-witness-study.py:66-73`); its explicit scrub list is `SCRUB_ENV` (`:117-118`). Tsukuroi documents fixture overrides for each host command/path (`tsukuroi-shokunin/tools/tsukuroi-census.sh:312-328`). These support an exact `KAGI_HOST_ROWS` control and isolated selftests, not a generic `ALLOW_HOST` switch.
- **Tag precedent:** no sibling `[host]`/`[substrate]` claim-row marker was found. Kasegi's `claim-ready/*` tags are provenance-only, not authorization (`kasegi-shokunin/corpus/knowledge/claim-gates.md:95-101`). Thus the `[host]` spelling should remain the frozen Kagi contract, alongside Kagi's established `[substrate]`; there is no sibling tag syntax to copy.

Kagi's frozen C1 requires `[host]`/`[substrate]`, default `HOST-SKIP`, explicit `KAGI_HOST_ROWS=run`, untagged-host refusal, and `rows_run` counting executed rows (`kagi-shokunin/plans/round-24.md:13-24`). **Contradiction:** the current worktree header instead says only `--allow-host-rows` authorizes runs and “no environment variable is honoured” (`kagi-shokunin/corpus/claim-ledger.sh:106-114`); selftest declarations also assert `KAGI_HOST_ROWS=run` does not authorize while the flag does (`:1555-1558`). Those are incompatible opt-in interfaces; neither is evidence that the other works. Separately, `KAGI_SUBSTRATE=present|absent` currently overrides substrate-presence detection (`:147-162`), not host consent, and host skipping is counted separately (`:517-523`). Do not reuse that variable for host authorization.

## Affected axes

- **Operability (primary):** callers can tell a host-safe partial audit from one that checked host rows.
- **Calibration (secondary):** skipped and executed rows remain distinct, countable dispositions.
- **Freshness:** [INFERENCE] no effect if the change stays in C1's ledger reporting; leave the normalizer, capture/in-row census, and frozen 15-row identity population untouched.

## One bounded proposal

Use Mado's scope-disclosing accounting pattern for Kagi's already-required `HOST-SKIP`: retain one `HOST-SKIP <id>` per omitted host row, keep `host_skipped=N` separate from `rows_run` (which remains actual executions), and qualify a CLEAN summary when `host_skipped>0` with the skipped-host scope. Reconcile the summary count to emitted skip rows in selftest. Keep `[host]` and `[substrate]` as specified; use the frozen, namespaced `KAGI_HOST_ROWS=run` opt-in rather than repurposing `KAGI_SUBSTRATE` or inventing another tag. Before landing, resolve the observed plan/worktree opt-in contradiction explicitly.

**Second-order boundary:** [INFERENCE] this is an operability/reporting change inside C1; it should not change host-row execution rules, citation resolution, C2 freshness inputs, or C3's identity population. It will change exact summary strings, so update their selftest pins and any documentation that quotes them. A bare CLEAN with nonzero host skips remains a scope-ambiguity risk unless the output carries the qualification.

## Risks and verification

- The external sibling evidence supplies output/environment patterns, not a `[host]` tag standard or direct claim-ledger implementation; do not claim cross-lane validation of Kagi's gate.
- The current script's flag-only consent behavior may be an intentional parent-environment safety choice, but it contradicts the frozen C1 environment contract. Keep that contradiction visible; do not silently accept both APIs as equivalent.
- Static verification only: read-only repository searches and file reads; no gate, selftest, or host mode was run, so no runtime exit code or pass is claimed. Recommended verification (not run): in a base scratch clone with empty HOME and host scripts stubbed, assert default tagged rows emit one `HOST-SKIP`, execute zero commands, and reconcile `host_skipped`; separately exercise the frozen opt-in using stubs and assert `rows_run` counts only actually executed rows. No tools were installed or updated.
