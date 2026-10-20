# Falsify — AttackEntry24: `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`

Axes: **calibration** (does the landed round-22 reading reject the known E3 overclaims and admit correctly bounded text?) and **freshness** (frozen-before vs landed bytes, stamp reconciliation without deletion or laundering). Seat: falsify-wave reviewer, read-only. No gate, build, lint, test, formatter, vault/account/credential operation, package transaction, launcher, npm/npx, host loopback or CDP probe was run; public documentation GETs and owned local file reads only. All observations are this seat's, on the frozen tree (freeze observed in `.ufo/waves/round-22/falsify-start.json`: `integration_landing = 8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`, `write_freeze = integration-manifest.json; production input edits paused until fresh wave returns`).

## One admissibility verdict

**ADMIT-WITH-FINDINGS.** The landed round-22 append is provably append-only over an unchanged frozen prefix, its stamp row was migrated in the same commit with exact old→new evidence, and its two substantive OpenBao corrections are independently confirmed against the live 2.7.x servings. It is not laundered: nothing was deleted, and the pre-existing false readings are explicitly marked as historical rather than silently rewritten. Three residual defects keep it from plain admit: (a) the "following sentence" quote-location error in the first block is landed as written; (b) the Vault v1.21.x → v2.x (latest) serving drift is unaddressed by any landed text; (c) two dangling-at-authorship citations (`corpus/knowledge/feature-bound-credential-review.md`, `corpus/lessons/round-22.md`) only resolve because integration landed those files in the same commit, which is documented nowhere in the entry's text.

## Frozen base and manifest hashes (named)

- Frozen base revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (blob of this entry at that rev: `ac553d93…` per build/Entry24; re-derived here: `git show c2cab35:…` sha256 = **5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb**, 111 lines, 8597 bytes).
- `.ufo/waves/round-22/integration-manifest.json`: `base_revision` = `c2cab35…`; input for this path (manifest lines 232–235): **f633d004100b5d440685770f6be6635f460c28673a2e353b554a64afd42c8610 / 158 lines / 11319 bytes**. Companion manifest inputs for the coupled files: `corpus/stamps.tsv` = `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` / 69 lines / 7213 bytes; `corpus/claim-ledger.tsv` = `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a`; `corpus/QUALITY.md` = `dc2f5fe27935c3e238c0992cb14a4285bbee5edd902e2174b963561bcc84c09d`; `corpus/SOURCES.md` = `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7`.
- `.ufo/waves/round-22/frozen/before/expected.json`: `revision` = `c2cab35…`; `inputs["corpus/knowledge/vault-openbao-token-lease-lifecycle.md"]` = **5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb**; `expected_stale_original` = config-layering, handler-on-disk-state, handler-trust-boundary, janitor-env-contract, lessons/round-18, LOG.md — **this entry is not among them**; `outside_admission` = E1 reject, E3 reject.
- Frozen-before snapshot file `.ufo/waves/round-22/frozen/before/corpus/knowledge/vault-openbao-token-lease-lifecycle.md`: sha256 `5fd53351…`, 111 lines, 8597 bytes — byte-identical to the base blob. The frozen snapshot IS the before state; nothing had to be reconstructed from a mid-build report.
- Measured landing commit (falsify-start's `integration_landing`, = HEAD): **8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3**, "round-22: feature-bound review capability and audited revision repairs", 2026-10-20 18:30:53 −0300. Working tree is clean for both audited paths (`git status --porcelain` → empty).

## Byte comparison: unchanged prefix proven, append-only

| object | sha256 | lines | bytes |
|---|---|---|---|
| frozen base blob / frozen-before snapshot | `5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb` | 111 | 8597 |
| landed/working file (HEAD `8ada17a` == manifest pin == observed disk) | `f633d004100b5d440685770f6be6635f460c28673a2e353b554a64afd42c8610` | 158 | 11319 |

- `head -c 8597 <landed> | sha256sum` → `5fd53351…` — **the first 8597 bytes of the landed file hash exactly to the frozen-before digest: the prefix is unchanged, byte for byte.** `cmp` reports EOF on the frozen file after byte 8597 and no earlier mismatch; `diff -u` shows a single hunk `@@ -109,3 +109,50 @@` (3 trailing context lines, then +47 added lines, 0 removed); `git diff --numstat c2cab35…HEAD -- <path>` = `47 0`. The append begins after the round-21 erratum's final line (`… (as in the SOPS entry's erratum).`).
- The landed append consists of two blocks: `## Erratum (round 22 — outside admit disagreement retained)` (+~33 lines) and `### Further product/path precision (round 22)` (+~14 lines), both purely additive.
- Build/Entry24.md (advisory) observed the same file in flight at snapshots `d193a944`/`00c8c4e2…` (138/10131) and `854dd291`/`ff019fed…` (158/11291). The landed 158/11319 bytes differ from the last build snapshot (11319 ≠ 11291) while line counts coincide; per the freeze contract the manifest pin (f633d004/158/11319) is authoritative and the final landing differs from every observed in-flight snapshot. No mid-build bytes were used as evidence.

## Stamp record: exact old→new migration, atomic, no deletion

- Frozen row (`frozen/before/corpus/stamps.tsv` line 32): `corpus/knowledge/vault-openbao-token-lease-lifecycle.md⇥5fd53351…⇥111⇥8597`.
- Landed row (HEAD `stamps.tsv` line 35; disk line 35 identical): `corpus/knowledge/vault-openbao-token-lease-lifecycle.md⇥f633d004…⇥158⇥11319`.
- `pin-migrations-integration.json` records exactly this entry (record at lines 348–356): `old_stamp` = `…5fd53351…111 8597`, `base_observed.sha256` = `5fd53351…`, `new_stamp` = `…f633d004…158 11319`, disposition "Reviewed current round-22 artifact; historical source facts remain historical. See round-22 lesson and named per-entry audit." Header counts: `old_members: 63`, `new_members: 69`, `removed_members: []` — six new members are the five new files plus `corpus/revision-audit.py`; no member was dropped.
- Atomicity: the landing commit touches this file (+47) and `corpus/stamps.tsv` (70 rows changed); at HEAD the stamps file hashes to `88bbe15b…`, identical to the manifest pin; the row appears exactly once (`grep -c` → 1). There is no window where file and row disagree.
- `integration-pin-check.json`: `stamp_exit: 0` ("STAMPED: n=69"), audit = `python3 corpus/revision-audit.py --history c2cab35…` → exit 0, `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`; the six ADDED paths are the round-22 files, not this entry. Per wave contract the parent reruns the revision-audit once globally; this seat reports the recorded result and its own row-level verification without rerunning the audit.

## Laundering check: corrections appended, every historical defect marked

Nothing was deleted; the diff is +47/−0. Every previously identified false reading is either marked historical or superseded in the appended text:

| pre-existing false reading | landed disposition |
|---|---|
| four-clocks table merging products/paths (E3 core overclaim) | first block: "historical defective readings, not an operational table. The product-separated round-21 erratum is authoritative." |
| outside verifier's rejection of E3 as landed | first block: "rejected E3 **as landed**; the round-21 erratum did not retroactively make that admission pass" — the reject is preserved, not converted into agreement |
| "Vault/OpenBao" token-TTL product conflation | round-21 erratum (unchanged prefix) withdraws the label; first block confirms S016 supports "OpenBao token claims only" |
| "an operator must revoke it" as universal issuer-revocation rule | first block: "is not a universal lifecycle rule: tokens can also expire and parent/service-token lifecycle rules apply"; missing product-specific source = "unverified/withdrawn, never implicit parity" |
| "periodic tokens renew indefinitely" (unqualified) | second block withdraws it unless the qualifiers travel: timely successful renewal, capped by explicit max TTL |
| KV "no lease" read as retention guarantee | first block: "no KV value-retention guarantee is admitted here"; second block separates S016 token/lease statements from engine/KV behavior |
| S014 claims-as-metadata over-generalization | second block: copying requires configured `claim_mappings`; JSON-pointer mapped claims must exist, non-pointer optional |
| corpus-only absence sweep (host runtime not covered) | round-21 erratum (unchanged prefix) already states the bound |

The errata preserve the original defective table in place as history (append-only) and route authority to the corrected reading; nothing was erased or silently re-pinned. Stamp values were updated only to pin actually-landed bytes with documented old→new tuples.

## Independent primary-source adjudication of the appended claims (public GETs, 2026-10-20)

Sources re-opened: S016 `https://openbao.org/docs/concepts/tokens/`, S015 `https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/`, S014 `https://openbao.org/docs/auth/jwt/`, S012 `https://developer.hashicorp.com/vault/docs/auth/jwt`, S013 `https://developer.hashicorp.com/vault/docs/concepts/lease`; releases via `api.github.com/repos/{hashicorp/vault,openbao/openbao}/releases`. Stripped-text searches; no probes beyond documentation.

- **S016 version label**: "Version 2.7.x" — matches the entry's recorded scope. Latest OpenBao release `v2.7.1` (2026-10-01, non-prerelease): still 2.7.x.
- **S016 TTL sentence**: the serving reads "After the current TTL is up, the token will no longer function -- it, and its associated leases, are revoked." — token revocation with associated leases confirmed.
- **S016 §The general case**: "outside of direct operator interaction, OpenBao will never revoke a token before the returned TTL has expired" — present. Renewal factors list the system max TTL "32 days but can be changed", and the mount max TTL "is allowed to override the system max TTL -- it can be longer or shorter, and if set this value will be respected" — **mount-override correction confirmed**.
- **S016 Periodic tokens**: "as long as the token is successfully renewed within each of these periods of time, it will never expire"; the explicit-max-TTL section states it "has an effect even when using periodic tokens to escape the normal TTL mechanism". The phrase "renew indefinitely" does not occur on the serving (0 hits), and the token-type table shows service tokens "Can be Renewable: Yes" vs batch "No". **Withdrawal of the unqualified phrase, with the two qualifiers, is supported.**
- **S016 batch tokens**: "Batch tokens are encrypted blobs…" present; the comparison table carries "Manually Revocable: Yes / No" for service/batch — the entry's batch non-renewability/non-revocability rows still hold on this serving.
- **S015 (Kubernetes note)**: "The JWT auth engine does not use Kubernetes' TokenReview API during authentication" and "revoked by Kubernetes will still be considered valid by OpenBao until their expiry time" — present, verbatim.
- **S014 claims as metadata**: "If a claim is configured in `claim_mappings`, it must exist in the JWT when using JSON pointer syntax (beginning with a `/`) or else the authentication will fail. Claim mappings which do not begin with a `/` are optional." — **exactly supports the second block's correction** (copying requires configured claim_mappings; pointer-mapped required, non-pointer optional; no every-mapping-must-be-pointer implication). Version label "Version 2.7.x".
- **S012 (Vault)**: "Starting in Vault 1.17, if the JWT in the authentication request contains an `aud` claim … the associated bound_audiences … must exactly match at least one of the aud claims declared for the JWT" — the 1.17 audience note survives; "exactly match" ×3, "OIDC validation criteria (e.g. iss, aud, etc.)" present. The cited S012 body facts still exist on the current serving.
- **S013 (Vault)**: "The Key Value Backend which stores arbitrary secrets does not issue leases although it will sometimes return a lease duration" and "The requested increment is completely advisory", "every dynamic secret and service type authentication token" — present; cited facts survive.

**Freshness finding (pointer vs source facts).** Both unversioned Vault pages currently serve `v2.x (latest)` with `v1.21.x` in the version switcher (each label observed 4–5 times in page chrome), and `hashicorp/vault` published `v2.2.0` on 2026-10-15 (non-prerelease). The entry's header records the 2026-10-19 reading as "unversioned 'latest' page … newest pinned entry v1.21.x" — now a historical point observation whose serving has advanced to 2.x. This is **pointer freshness**, distinguishable from **source facts**: the specifically cited S012/S013 sentences were re-read and remain present on the v2.x serving, so no content drift is proven — but the entry's provenance line describes a serving that no longer exists, and no landed text records the 2026-10-20 observation. OpenBao's recorded 2.7.x scope still matches the live label, so its freshness holds within scope.

## Findings (by severity)

1. **[MEDIUM, freshness/provenance] Vault serving drift not marked by any landed text.** Header still asserts "version switcher's newest pinned entry v1.21.x" (2026-10-19); both Vault pages now serve `v2.x (latest)` and Vault 2.2.0 published 2026-10-15. Build/Entry24 §5 correctly identified this and §7 drafted a fix block, but nothing was appended to the landed file. The round-21 lesson (`corpus/lessons/round-21.md`, E3 admit row) requires "S012–S016 re-opened" on release; a version-selector advance is that trigger. A dated provenance note (scope-limited: named sections re-read on the v2.x serving; no 2.x-specific behavior admitted) is owed.
2. **[MEDIUM, calibration] Quote-location error landed.** First block: "§Token Time-To-Live states: 'After the current TTL is up…'. Its following sentence includes associated leases." The live serving shows the lease clause is in the **same** sentence after the dash. The lesson's own QA discipline treats exact-source location as part of the bounded reading; the claim is true but its location pointer is wrong and landed uncorrected (build §4a flagged it; the landed text was not amended).
3. **[LOW, calibration] "No lease ≠ no deletion" not stated as a direct sentence.** First block says "no KV value-retention guarantee is admitted here", and the round-21 erratum says a KV read carries no lease, but the explicit distinction build §4b proposed (S013 establishes only absence of a lease; retention/expiry/delete-destroy behavior unopened for both products) is not landed. The round-21 erratum's own lead (Vault KV v2 API, `corpus/SOURCES.md` §Leads) stays open.
4. **[LOW, freshness] Two citations were dangling at authorship and resolve only via the integration commit.** The append cites `corpus/knowledge/feature-bound-credential-review.md` and `corpus/lessons/round-22.md`; both were untracked/absent when the text was authored (build §4c), and `corpus/QUALITY.md` QA10 existed only as a dirty edit. The single commit `8ada17a` landed all of them (verified in-commit), so nothing dangles at HEAD — but the entry's text nowhere records this coupling, and a reader of the append alone cannot see that its anchors are same-commit artifacts. Commit provenance exists; textual provenance does not.
5. **[INFO] `.ufo` build-report citations are lane-working-tree pointers.** The second block cites `.ufo/waves/round-22/build/Source14.md` / `Source16.md` as "Source review". Both are tracked at HEAD (`git ls-files` confirms), but the wave contract keeps production inputs frozen while `.ufo` reports are advisory; the durable evidence remains the named S014/S016 sections. Acceptable as provenance pointers, not as citation anchors.
6. **[INFO] No depth or count claim detected in the landed text.** The append claims no score movement, no new admission, and measures no deployed behavior; consistent with the round plan's "No depth claim".

## Residual risk and verification gaps

- Parent duty: one global rerun of `corpus/revision-audit.py --history c2cab35…` (not run by this seat); per wave contract it should reproduce `stale=0 missing=0 dropped=0 added=6 invalid=0`.
- The registry's `Fetch sha256` canonicalization remains undocumented; raw re-fetches cannot reproduce them, and no drift claim is made from that (consistent with build §5 and the lesson's source-epoch accounting).
- The exact transition time of the Vault serving from v1.21.x to v2.x is unrecorded (build §9); unknowable without vendor logs.
- The appended text does not name the authoring seat/decision; integration-commit provenance exists only in the wave records, not in the entry.

## Checks the parent should run after integration

- `bash corpus/sources-census.sh` and `bash corpus/claim-ledger.sh docs` — corpus-only, no network.
- Targeted four-field compare: `sha256sum`/`wc -l`/`wc -c` of `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` against its `stamps.tsv` row.
- `bash corpus/claim-ledger.sh verify` only under QM12 with the known host-private row handled; no auto-`stamp`.
- No rerun of the revision-audit by this seat; parent's single global rerun covers it.

## Limits

Public documentation and release-API GETs only; no deployed Vault/OpenBao, no account, no credential, no service, no package transaction, no installation. Quotes ≤25 words each, URL and date named inline. Read revisions: frozen base `c2cab35…` (via `git show`), landing/HEAD `8ada17a5…`, manifest/frozen-before as named above. One seat, one entry; the global audit rerun and cross-entry integration are the parent's.
