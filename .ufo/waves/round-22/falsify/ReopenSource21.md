# ReopenSource21 — independent reopen of S021 (OpenBao token lifecycle)

Seat: `KagiR22.ReopenSource21` (leaf scout; no subagents).
Wave: round-22 falsify (fresh attack of the integrated tree; no production edits).
Question: reopen S021 OpenBao token lifecycle; verify Version 2.7.x, token-type
scope, its own TTL anchor quote and the absence of unsupported dynamic-engine/KV
claims; compare the active `feature-bound-credential-review.md` OpenBao row to
the source.

## Read revision and frozen inputs (observed bytes)

- `git rev-parse HEAD` = `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (the measured
  integration landing). Working tree clean for production inputs; only wave
  `.ufo` falsify files are untracked/modified.
- Frozen manifest `.ufo/waves/round-22/integration-manifest.json` sha256
  `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.
- `corpus/SOURCES.md` sha256 `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7`
  (86 lines / 19721 bytes) — equals the manifest input and the `corpus/stamps.tsv`
  row.
- `corpus/feature-claims.json` sha256 `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa`
  (995 / 47434) — equals manifest and stamp.
- `corpus/knowledge/feature-bound-credential-review.md` sha256
  `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` (43 / 4440)
  — equals manifest and stamp.
- `corpus/lessons/round-22.md` sha256
  `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` (192 / 15700)
  — equals manifest and stamp.
- `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` sha256
  `f633d004100b5d440685770f6be6635f460c28673a2e353b554a64afd42c8610` (158 / 11319)
  — equals the manifest input.
- `corpus/stamps.tsv` sha256 `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29`
  (69 rows) — equals the manifest input.

No production file was written or modified by this seat.

## Source reopened

- URL: `https://openbao.org/docs/concepts/tokens/`
- Read: 2026-10-20 (public documentation GET only; no OpenBao/Vault server,
  account, vault or host loopback probe).
- Fetch evidence: raw bytes 47384; sha256
  `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`;
  response `last-modified: Tue, 20 Oct 2026 07:50:18 GMT`,
  `etag: "6ad71d3a-b918"`, `content-length: 47384`. This matches the
  `feature-claims.json` S021 `sha256`, `digest_observed_at: 2026-10-20`, and the
  build-side capture (`.ufo/waves/round-22/build/Source16.md`, two byte-identical
  fetches). The S016 registry digest `c083fdca8645f6248a3c42a8c0b912b356de281dc2da0099668a7850ba348380`
  is retained as `prior_registry_sha256`; it is not silently replaced.

Located quotes (each ≤25 words, heading + 2026-10-20):

| # | heading | quote |
|---|---|---|
| Q1 | version badge | “Version: Version 2.7.x” |
| Q2 | §Token types | “The features in the following sections all apply to service tokens, and their applicability to batch tokens is discussed later.” |
| Q3 | §Token Time-To-Live, periodic tokens, and explicit max TTLs | “Every non-root token has a time-to-live (TTL) associated with it” |
| Q4 | same heading | “After the current TTL is up, the token will no longer function -- it, and its associated leases, are revoked.” |
| Q5 | §Service vs. batch token lease handling | “Leases created by service tokens (including child tokens' leases) are tracked along with the service token and revoked when the token expires.” |
| Q6 | §Service vs. batch token lease handling | “Leases created by batch tokens are constrained to the remaining TTL of the batch tokens” |

The comparison table also carries `Can be Renewable: No`, `Manually Revocable: No`
and `Can have Explicit Max TTL: No (always uses a fixed TTL)` for batch tokens.

## Verification against the assigned checks

1. **Version 2.7.x — verified.** The raw banner is
   `<span ...>Version: Version 2.7.x</span>` and the page metadata carries
   `meta-docsearch:version: 2.7.x` / `docs-default-2.7.x`.
2. **Token-type scope — verified.** Q2 is the page's own scope statement, and Q3
   sits in a following section; the TTL/lease claims are therefore service-token
   claims. Q6 and the batch-token chart independently mark batch lease handling
   as separate.
3. **Own TTL anchor — verified.** Q4 appears verbatim (including the `--`
   continuation) under the named heading; Q5 independently repeats the
   service-token lease revocation.
4. **No unsupported dynamic-engine or KV claim — verified for S021 and the
   active OpenBao row.** The page contains no KV/Key-Value-engine text (the sole
   `Kv` substring occurs inside an example token string in the page's
   token-format sample block; `vault` appears only in meta keywords). Its single
   `Dynamic Secrets` reference
   is the chart row `Dynamic Secrets Lease Assignment | Self | Parent (if not
   orphan)`; it does not state dynamic-secret issuance and the active row does
   not quote or use it. The active row expressly rejects “infer KV
   deletion/retention”.

## Active review row vs. source

`corpus/knowledge/feature-bound-credential-review.md:19` (OpenBao service tokens):

- “In OpenBao 2.7.x's service-token context, non-root tokens have TTL” — Q1 +
  Q2 + Q3, and non-root is correctly distinguished from root tokens (the page
  says root tokens may have TTL 0). **Supported.**
- “after TTL the service token no longer functions and its associated leases are
  revoked” — Q4 exactly; Q5 supplies the same service-token lease statement.
  **Supported.**
- “Batch-token renewal/manual-revocation limits and lease handling are separate;
  this row does not generalize service-token lease behavior to batch tokens” —
  the chart's `No` cells plus Q6/the separate batch-lease section. The sentence is
  a conservative scope limit, not an affirmative batch claim. **Supported.**
- Reject column (“extend this to Vault tokens, infer KV deletion/retention, or
  erase token-type distinctions”) matches the known E1/E3 overreach classes and
  is supported by the product-scoped page and absent KV content.

**Verdict: ADMIT.** The row is a bounded, product-scoped OpenBao 2.7.x
service-token control; I found no overclaim and no need to reject or narrow its
bounded reading. It correctly refuses Vault-token extension, KV-retention
inference and token-type erasure. No dynamic-engine claim is attributed to S021.

## Freshness and revision accounting (observed, not a gate run)

- S021 is present once in `corpus/SOURCES.md` (`:27`), status `mined`, opened
  `2026-10-20`, `used-by` the lesson and the active review; its byte pin is
  reproduced independently above.
- S016's historical row (`:22`) is still present with its 2026-10-19 digest; no
  source row was deleted to make the new pin.
- Stamp membership base→current: `git show c2cab35…:corpus/stamps.tsv` has 63
  unique paths, current has 69; **added 6, removed 0, duplicates 0** — matching
  the manifest's `revision_audit.added: 6, dropped: 0`.
- Historical nine-line claim, independently replayed from
  `aea7a4301`→`e1544c194fddf1bb073b3946847b4526f326ad73`: 56→63 stamp rows,
  **zero removed members**, **nine changed rows for the same paths** (LOG.md,
  PROVINCE.md, SCORECARD.md, SHONEN.md, SKILL.md, corpus/README.md,
  corpus/claim-ledger.tsv, corpus/knowledge/op-ref-consumption.md,
  corpus/op-ref-probe.sh), plus seven genuinely new paths. This matches
  `round21-migrations.json` (`removed_members: []`,
  `changed_stamp_records: 9`) — replacements, not nine lost members.
- Expectation migrations replayed from the same two revisions:
  R12-02 29→36, R12-03 56→63, R13-01 20→23, R14-01 21/18→24/21 declarations;
  R13-02 retains expectation 35 with a note-only change. This matches the
  lesson and `round21-migrations.json`'s five rewritten claim rows. No
  expectation was rewritten silently in that span.
- Limits of this check: membership/expectation comparison only, not vendor
  currentness and not the official `revision-audit.py` run; the official
  R22-03/R22-04 checks remain for the parent.

## Findings (bounded; none falsifies the OpenBao row)

- **F1 — freshness traceability, low.** `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:120`
  says “Reopened S016 on 2026-10-20”, while the registry's 2026-10-20 reopen is
  S021 and S016 remains the 2026-10-19 row with digest `c083fdca…`. This is not a
  source-truth error (same URL, same quote), but a reader following S016's row
  gets the old date/digest. Proposed correction: “Reopened the OpenBao tokens
  page on 2026-10-20 (registered as S021; S016's 2026-10-19 row and digest are
  retained).”
- **F2 — ledger transparency, low.** The S021 registry row does not say it is a
  re-pin of S016's URL; the migration is documented only in
  `feature-claims.json` (`prior_registry_sha256`) and build evidence, unlike
  S019/S020's inline “supersedes” notes. Proposed correction: append to S021's
  `teaches` field: “Re-pin of S016's URL; S016's 2026-10-19 row and Fetch sha256
  `c083fdca…` are retained; the S016 fact is unchanged.” This preserves history
  and makes the two same-URL rows self-explanatory.
- **F3 — anchor completeness, low.** The review's `source:` line (line 1) lists
  S021 anchors “Token Time-To-Live and Token type comparison, Version 2.7.x” but
  omits `§Token types`, which is the anchor of the typed
  `runtime_constraints: service_token_scope` binding and of the row's
  “service-token context” clause. The row's Evidence cell does name “Token
  types”. Proposed correction: add “Token types” to the header anchor list; no
  prose change.
- **F4 — anchor completeness, low.** The row's “lease handling are separate”
  clause is supported by `§Service vs. batch token lease handling`, which is not
  among the row's three named anchors (nor the S021 registry `anchor`). Proposed
  correction: add that heading to the row's Evidence cell (and optionally the
  registry anchor). This is an under-citation, not an overclaim.
- **Observation, not a defect (E3 wording).** `vault-openbao-token-lease-lifecycle.md:122`
  says “Its following sentence includes associated leases”, but the lease
  clause is the same sentence's post-dash continuation (Q4), not a separate
  sentence. The lesson's “Additional bounded findings” already states this
  qualification, so no further correction is required; I note it to prevent the
  wording from being read as an independent source statement.
- **Observation, not a defect.** S021's SOURCES row carries no inline
  `Fetch sha256:` (S001–S016 do); the verified pin lives in
  `feature-claims.json` and the build capture. If registry consistency is
  desired, add the reproduced pin with representation/date, or state that new-row
  digests live in the typed artifact. No currentness inference follows from a
  digest either way.

## Residual unknowns / out of scope

- I did not re-open S017–S020 or re-adjudicate the Broker rows; this seat covers
  the OpenBao S021 row only.
- I did not run `feature-claims.py`, `revision-audit.py`, `sources-census.sh` or
  any other gate; no gate output is claimed.
- The raw-page digest is a point observation at 2026-10-20; it does not prove
  future or deployed OpenBao behavior.

## Checks for the parent after integration

- `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f`
  — expect `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`.
- `python3 corpus/revision-audit.py --selftest` — expect
  `REVISION_AUDIT_SELFTEST: PASS (cases=11 failed=0)`.
- `python3 corpus/feature-claims.py --phase after` — expect
  `FEATURE_CLAIMS: CLEAN phase=after admitted=4 false_claims=0 bar_failures=0
  false_admissions=0 misses=0 unjudgeable=0` (ledger R22-01). `--phase before`
  must reject the ten bad records (exit 1), and `--selftest` must report
  `FEATURE_CLAIMS_SELFTEST: PASS cases=10` (R22-02).
- `bash corpus/sources-census.sh` — expect the current 21-row census, including
  S021's used-by edges.
- If F1–F4 are applied, re-stamp the changed files and record the old/new rows.

Installs/updates: none. No package, launcher, service or host-state operation.
