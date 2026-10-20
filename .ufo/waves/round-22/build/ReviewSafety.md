# Round 22 — ReviewSafety

## Scope and read revision

Axes: **calibration** (C1) and **freshness** (C2). Review slice: command allowlists and preventing host-private reads. Read-only review; no host command, gate, test, runtime, or installation was run. Assignment freeze: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`plans/round-22.md:3`, `.ufo/waves/round-22/build-spec.json`). The historical round-21 verifier identifies its comparison as `aea7a4301` → `e1544c194`; that is separate from the round-22 freeze. I did not run VCS commands, so I cannot independently establish the live checkout's exact revision.

I reviewed the lane `SKILL.md`, `SCORECARD.md`, `corpus/QUALITY.md`, source/claim registries, relevant gate code, the round-21 lesson, and the prior non-author verifier/critic. At inspection, `.ufo/waves/round-22/build/` contained `swarm-registry.json` and `SafetyPaths.md`, but no round-22 implementation diff, so findings below are acceptance conditions and inherited safety hazards—not a verdict on unobserved implementation. The mounted tools have no `lsp` device (`read xd://lsp` returned “No such tool”); no LSP status/references/definition/diagnostics are available. Literal text lookups were used only to locate reviewed lines, not as semantic proof.

## Findings by severity

### High — The claim-ledger allowlist is not a host-private-read boundary

`corpus/claim-ledger.sh:158-185` accepts `bash` as a first token and denies selected words/metacharacters; it does not constrain the script path or prove what the script reads. Accepted claims are run through `timeout … bash -o pipefail -c "$cmd"` (`:401-408`). Thus `bash corpus/drift-pins.sh` passes the text policy even though it reads the host paths in `corpus/drift-pins.sh:45-63`; the symbol loop reads matched files at `:198-246`, including the private env-file path when present. The current ledger has precisely that command as untagged `R18-01` (`corpus/claim-ledger.tsv:48`). This is corroborated by the lane's own round-21 named debt: full `claim-ledger.sh verify` was not run because R18-01 reads host files (`corpus/lessons/round-21.md:84`).

**Acceptance condition for C2:** do not use whole-ledger `verify` or run R18-01 on the live host. Preserve QM12's substitute (`corpus/QUALITY.md:60`): enumerate and re-run only individually reviewed safe rows against the commit tree, check the stamp file with `sha256sum --check`, and list every skipped row ID with its reason. The C2 detector itself must stay on local corpus/fixture data. A claim that the lexical allowlist alone proves no private reads is false; `SKILL.md:297-301` already calls it a text guard, not a sandbox.

**Falsifier:** if the proposed round-22 path executes the full verifier or R18-01 while asserting “no host-private read,” it fails this boundary. A safe demonstration must show that row is listed as skipped before execution, with an explicit host-private-surface reason; do not run the row to prove the skip.

### High — Nine deleted stamp members require historic row-level reconciliation, not a count repair

The prior independent review records `corpus/stamps.tsv` had **nine lines deleted** between the round-21 base and head (`.ufo/waves/kaika-w3/kagi-review.md:18-20`). It reports 9 checksum mismatches at base and 5 at head (`:66`), but its summary does not enumerate the nine deleted row identities or their old values. Separately, the lane lists five deliberately unpinned stale entries (`corpus/lessons/round-21.md:85`): `knowledge/config-layering.md`, `knowledge/handler-on-disk-state.md`, `knowledge/handler-trust-boundary.md`, `knowledge/janitor-env-contract.md`, and `lessons/round-18.md`. Those five are not evidence that the other nine stamp members were restored or justified.

**Acceptance condition for C2:** derive the nine exact old stamp rows from the stated historical tree and account for each path individually—restore membership or record an explicit, evidence-backed removal decision. Preserve old/new path, digest, line and byte fields, reason, and the check that motivated each change. A count-only `9→0`, a fresh hash, or silently re-pinning current content cannot establish that no history was dropped or laundered. Keep the five already named stale entries distinct from the nine missing members, and do not convert historic host facts into current facts merely by updating stamps.

### Medium — Ledger expectation migrations need old and measured new values

The prior verifier records four in-place expectation changes: `R12-02` 29→36 cases, `R12-03` 56→63 stamp rows, `R13-01` 20→23 scorecard headings, and `R14-01` 21/18→24/21 declarations/row-linked entries (`.ufo/waves/kaika-w3/kagi-review.md:19, 131`). It found the new values matched observed head output, but required the lesson to say they were measured outputs, not targets (`:131`). `corpus/QUALITY.md:73` now requires prior and new revision-pin/expectation state plus the motivating correction and observed checks.

**Acceptance condition for C2:** preserve each old expectation and tie the new value to a specific historic observation/revision; append the migration record rather than presenting only the current green value. For each of the nine stamp removals, require the same itemized before/after evidence.

### Medium — Calibration must test decisions, not criterion/row volume

The previous non-author verifier found the round-21 admits E1 and E3 disagreed with the source-grounded reading, while its three sampled rejects agreed (`corpus/lessons/round-21-verifier-spotcheck.md:12-17`; details in `.ufo/waves/kaika-w3/kagi-review.md:98-110`). Its critic documents the concrete E1 problem: the body omitted EPM Business eligibility and collapsed the GitHub Actions and custom-OIDC status; it also found E3 widened product/path-specific claims (`.ufo/waves/kaika-w3/kagi-critic.md:21-27`). The current admission bar adds QA10 and QM13 (`corpus/QUALITY.md:71-72`), and the source registry now separates the feature/eligibility evidence in S017–S020 (`corpus/SOURCES.md:23-26`). The round-21 source census is only a structural citation-chain gate; its own row states it does not re-open vendor pages (`corpus/claim-ledger.tsv:52`).

**Acceptance condition for C1:** report correct decisions over named candidates with source-grounded expected outcomes, misses, and false admissions. For each Broker feature, require its own opened status/eligibility evidence and do not borrow one product/feature's qualifiers for another; for E3, keep Vault and OpenBao, provider path, and KV/lease claims distinct. Also admit at least one correctly bounded positive control. QM13 explicitly bars using authored row counts, selftests, or lane-L2 consensus as calibration or outside agreement.

**Falsifier:** replay the known defective E1 admission (generic “Broker is public preview” without Business eligibility and with the two workflows conflated) against the new decision mechanism. It must reject that record while admitting a properly separated, feature-specific bounded control grounded in S017–S020. If it accepts the old overclaim, or rejects every bounded control, C1 fails; adding more criteria/rows cannot repair that result.

## Residual risk and verification gaps

- No round-22 implementation diff was visible in the build directory at the time of review; behavior of new gates/detectors is therefore unverified.
- The prior verifier's summary establishes nine deleted stamp lines but does not name them. C2 must consult the exact historical stamp file/revision; this report does not invent the missing row identities.
- No `lsp` server/device was available. No caller/definition/diagnostics evidence exists for this read-only review.
- No vendor URLs were fetched or re-opened in this review. S017–S020 are cited as local registry evidence only; QA10's source-opening requirement remains for the C1 adjudication.
- No gate, checksum command, test, or runtime was executed. Main integration should check the final row-by-row safe-ledger report, the nine-row migration ledger, and the source-bound reject/control outcomes after the implementation diff is available; do not run whole-ledger `verify` on this host under the current R18-01 behavior.

## Proposed correction

Keep the round-22 detector corpus/fixture-local. For C2, provide the historic nine-row stamp membership diff, itemized expectation migrations, and QM12-compliant explicit safe-row/skipped-row accounting. For C1, use a finite candidate/control decision table tied to S017–S020, preserve the known E1/E3 bad reads as reject cases, and report observed correct decisions rather than authored-row totals. Treat the census and selftests as representation checks, not vendor-truth evidence or outside agreement.

---

Report path: `.ufo/waves/round-22/build/ReviewSafety.md`