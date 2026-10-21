# Round 22 — Entry24: `vault-openbao-token-lease-lifecycle.md` and its stamp row

Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (committed blobs read with
`git show <rev>:<path>`; not the dirty working tree). Audit time 2026-10-20.
Read-only: no host gate, build, lint, test, formatter, service, vault/account/credential
operation, package transaction or installation was run. Public documentation and the two
official release APIs were opened; no deployed Vault/OpenBao was contacted.

Axes: **freshness** (stamp/pin ledger and substantive source currency) and **calibration**
(E3's product/version-specific admit/reject boundary).

## Verdict in one paragraph

At the frozen base the audited entry is **not stale and not deleted**: its stamp row is an
exact four-field match (`5fd53351…`, 111 lines, 8597 bytes) and it is absent from the six
paths that are genuinely stale at `c2cab35`. Its round-21 migration
(`c1d57e6d…`/101/7270 → `5fd53351…`/111/8597) is a documented, append-only erratum migration,
not a silent rewrite. The live working tree, however, is under active edit and now carries a
**new, uncommitted, +47/−0 append in two observed blocks** (latest blob `854dd291…`,
`ff019fed…`, 158 lines, 11291 bytes) while the row still pins the 111-line blob — a real
stale-byte mismatch pending integration, not historical debt. Separately, **substantive
freshness has changed on the Vault side**: on 2026-10-20 both unversioned Vault pages serve
`v2.x (latest)` and list `v1.21.x` below, while the entry's source line records `v1.21.x`;
Vault 2.2.0 was published 2026-10-15. A new appended correction is needed for that provenance
drift, the remaining exact-source defects, and the second block's non-durable citations.

## 1. Frozen-base stamp verdict — PASS

`corpus/stamps.tsv:32`:

```
corpus/knowledge/vault-openbao-token-lease-lifecycle.md	5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb	111	8597
```

Measured from `git show c2cab35:corpus/knowledge/vault-openbao-token-lease-lifecycle.md`
(blob `ac553d93cfe2bfdca9a10afb13892c4909152a91`): sha256 `5fd53351…`, 111 newlines,
8597 bytes. All four fields match. The same tuple matches at `e1544c` (the post-landing
correction commit) and is unchanged at `c2cab35`.

The six rows that are actually stale at the frozen base are **not** this entry:

- `corpus/knowledge/config-layering.md`
- `corpus/knowledge/handler-on-disk-state.md`
- `corpus/knowledge/handler-trust-boundary.md`
- `corpus/knowledge/janitor-env-contract.md`
- `corpus/lessons/round-18.md`
- `LOG.md`

`LOG.md` became the sixth at `c2cab35` itself: the merge appended 7 lines (`1043/74864` →
`1050/75404`) without re-stamping. The first five predate it. None is this entry.

The row is present exactly once at base. It was never dropped: `aea7a43` (pre-round-21)
has no row for this path; `c41af82` adds it; `e1544c` and every later revision keep it.

## 2. Live-tree divergence — real byte staleness, pending integration

Observed during this audit (uncommitted, not written by this seat):

| object | sha256 | lines | bytes |
|---|---|---|---|
| committed base blob `ac553d9` / pinned row | `5fd53351f5395bf2af26d3476503510c5897924284f053b50be55ac44024e6fb` | 111 | 8597 |
| live snapshot 1 (18:34:30) blob `d193a944` | `00c8c4e209b5e07808805943cd8c728044f7466c1fe6f498494e7185d99ea784` | 138 | 10131 |
| live snapshot 2 (18:42:28) blob `854dd291` | `ff019fed04f4d9ead8a8ef9068d4712375f475cef3a888f555d3e0738fcde740` | 158 | 11291 |

`git diff --numstat c2cab35 -- corpus/knowledge/vault-openbao-token-lease-lifecycle.md`
reported `27 0` at snapshot 1 and `47 0` at snapshot 2 — a pure EOF append each time. The
file is under active edit; its current mismatch is +47 lines / +2694 bytes. `jj status`
lists it as `M` under parent `c2cab35`, with no commit. The stamp row was not modified, so
any hash/line/byte comparison flags this path as stale until a final text is frozen and the
row is migrated with it.

This is **not** a byte mismatch to repair in isolation. The two appended blocks are a
substantive round-22 erratum; their provenance (who wrote them, from which seat/decision) is
not recorded in the file or in repository metadata that this audit can read. Integration
must either:

1. accept the append and re-stamp atomically in the same reviewed commit, recording the
   exact migration `5fd53351…/111/8597 → <final sha>/<final lines>/<final bytes>`; or
2. reject it and restore the base blob `ac553d9` (`5fd53351…`/111/8597) with the row left
   unchanged.

A partial landing (file without row, or row without file) is the failure mode C2 is meant to
catch. A global `stamp` invocation now would also re-pin the six base-stale rows and the
other in-flight files (`onepassword-machine-credentials.md`, `SOURCES.md`, `QUALITY.md`) —
that is laundering, not reconciliation. Only a row-level reviewed migration, or a full
invocation after every dirty file is separately adjudicated, is acceptable.

## 3. Historical migration — documented, not laundering

| revision | event | entry sha256 / lines / bytes | row state |
|---|---|---|---|
| `aea7a43` | pre-round-21 | absent | no row |
| `c41af82` | round-21 landing adds the entry | `c1d57e6d74e0fdabc9f72d7e66ceb5f33a6235ed67f572a3b8ffc8748c15696e` / 101 / 7270 | same |
| `e1544c` | post-landing correction appends the round-21 erratum | `5fd53351…` / 111 / 8597 | updated in the same commit |
| `c2cab35` | frozen base | `5fd53351…` / 111 / 8597 | same |

The `c41af82 → e1544c` diff for this file is +10/−0 lines: the round-21 erratum block only.
The stamp row changed in the same commit, and the commit message names “errata on the three
new entries.” The old row value is preserved in the commit history; nothing was deleted.

### The “nine deleted stamps” are nine in-place value updates, not nine lost members

`round21-migrations.json` (`from_revision aea7a4301`, `to_revision e1544c194`) records
`removed_members: []` and exactly nine changed stamp records. Measured directly:

- `git diff aea7a43 e1544c -- corpus/stamps.tsv` has **9** removed non-header row lines and
  **16** added non-header row lines (9 replacements + 7 newly added round-21 rows).
- Path-set difference over that range: **0** removed paths.
- The nine changed paths are: `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`,
  `SKILL.md`, `corpus/README.md`, `corpus/claim-ledger.tsv`,
  `corpus/knowledge/op-ref-consumption.md`, `corpus/op-ref-probe.sh`.

This entry is **not** among the nine `aea7a43 → e1544c` changed rows; it did not exist at
`aea7a43`. It is among the **13** rows changed in the later `c41af82 → e1544c` correction
(which also changed `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SKILL.md`). Conflating the
13-row correction with the nine-row in-place update produces a false “nine dropped members”
reading. Nothing here should be restored to an old hash: an old hash is a stale pin, not a
recovered fact.

## 4. Calibration audit of the live E3 append

The appended blocks get the central E3 correction right:

- It preserves the outside verdict: E3 was rejected as landed; the round-21 erratum did not
  retroactively make the admission pass.
- It makes the round-21 product-separated reading authoritative over the original
  four-clocks table and the first §Does not establish bullet.
- It supports OpenBao token claims from S016 only, and explicitly withholds Vault-token
  evidence and OpenBao KV evidence.
- It withholds other-IdP revocation paths, cross-product TTL parity and any KV
  value-retention guarantee; a missing product-specific source is “unverified/withdrawn.”
- It states the public-document/no-probe limit and cites the lesson/criterion.
- It does not claim depth or a new admission.

This is a correctly bounded control, not a restatement of the overclaim. Three exact defects
remain.

### 4a. Wrong quote location (S016)

The first block says:

> “After the current TTL is up, the token will no longer function”. Its following sentence
> includes associated leases.

On S016 (`https://openbao.org/docs/concepts/tokens/`, Version 2.7.x, read 2026-10-20), the
associated-lease clause is in the **same** sentence, after the dash:

> “After the current TTL is up, the token will no longer function -- it, and its associated
> leases, are revoked.”

The claim is true; the location is wrong. Correct to “the same sentence continues: ‘it, and
its associated leases, are revoked’.” This matters for exact-source calibration because a
reader checking a “following sentence” will not find it.

### 4b. “No lease” is still not explicitly separated from “no deletion”

The first block says “no KV value-retention guarantee is admitted,” which is close, but the
required distinction is stronger: S013’s “does not issue leases” establishes only the
absence of a lease for Vault KV; it does not establish retention, expiry, or deletion
behavior. The round-21 erratum already notes that KV v2 version-deletion and delete/destroy
were not opened; the round-22 append should state the distinction directly rather than rely
on the reader to infer it. Proposed sentence:

> No lease is not no deletion: S013 establishes only that Vault KV does not issue leases;
> KV retention, expiry and delete/destroy/version-deletion behavior were not opened and
> remain unknown, for Vault and OpenBao alike.

This directly answers the DraftE3 requirement and prevents “no lease” from being read as
“the value survives forever.”

### 4c. Citation/provenance coupling

The append cites `corpus/lessons/round-22.md` and `QUALITY QA10`. At audit time
`corpus/lessons/round-22.md` was **untracked** and `corpus/QUALITY.md` was **modified**
(QA10 is at line 71 in the dirty file). If the append lands without those files, the citation
is dangling. The integration commit must include the append, the lesson, and QA10 together,
or the append must cite only already-committed anchors. The live append also does not record
its author/seat; the integration commit or migration record should.

### 4d. Second appended block: correct qualifications, weak citation hygiene

The second block (lines 140–158 of the live 158-line text) adds two accurate corrections:

- **S014 §Claims as metadata:** copying requires configured `claim_mappings`; a mapping
  beginning with `/` is required (JSON-pointer), while non-pointer mappings are optional.
  It does not require every mapping to use JSON-pointer syntax. Re-read 2026-10-20; the
  block's distinction is supported.
- **S016 §The general case / §Periodic tokens:** the mount max TTL may override the system
  max TTL, longer or shorter; a periodic token continues only with successful renewal within
  each period and is still capped by an explicit max TTL. The block withdraws the
  unqualified “periodic tokens renew indefinitely”; the qualifiers are supported by S016.

Two provenance issues arrive with it:

- It cites `.ufo/waves/round-22/build/Source14.md` and `Source16.md` as “Source review.”
  `.ufo` is the wave working tree, not the durable corpus; `corpus/claim-ledger.sh` maps
  `.ufo/*` to its unchecked `ufo` class (`classify`, lines 446 and 460–463), so those
  citations are not validated by the gate. The vendor sections above are the durable
  evidence; keep the build reports as lane provenance, or label them as working notes.
- It cites `corpus/knowledge/feature-bound-credential-review.md`, which was untracked at
  audit time. If that entry is part of the integration it must land in the same change; if
  not, the cross-reference must be removed. A knowledge entry is not a substitute for the
  S014/S016 source sections. If it lands as a knowledge entry, the docs-audit surface
  changes: at audit time the dirty tree already had 25 `corpus/knowledge/*.md` files and 21
  `SOURCES.md` data rows (S001–S021), against base counts of 24 and 16. The pinned R14-01
  `entries=24` and R21-02 `rows=16` expectations are therefore both stale-by-design and
  must be migrated with exact before/after values, not silently re-pinned.

The second block does not address 4a, 4b, or the Vault v2.x provenance in §5.

## 5. Substantive freshness — Vault moved, OpenBao did not

### Vault (S012, S013): provenance is stale; cited text is still present

The entry's source line records S012's “version switcher's newest pinned entry v1.21.x” and
S013 as “same serving as S012.” On 2026-10-20 the unversioned pages
`https://developer.hashicorp.com/vault/docs/auth/jwt` and
`https://developer.hashicorp.com/vault/docs/concepts/lease` both render:

> `v2.x (latest)` … `Vault v2.x (latest)` … `v1.21.x` …

The official releases API reports Vault `2.2.0` published `2026-10-15` (non-prerelease), so
the docs serving has advanced past the entry's recorded v1.21 bound. This is **substantive
freshness**, independent of the local stamp.

What survived re-reading on the v2.x serving:

- S012 still carries the 1.17 audience note and the four verification methods, including the
  exact-match wording and the OIDC Discovery criteria sentence.
- S013 still carries “every dynamic secret and service type authentication token,” the
  token-revokes-its-leases sentence, the advisory-increment sentence, and the KV note
  (“does not issue leases although it will sometimes return a lease duration”).

No Vault 2.x-specific behavior was tested, and the entry does not claim one. The defect is
provenance: the entry says v1.21.x while the page it cites now serves v2.x latest. A reader
cannot tell whether the claims were read on 1.21 or 2.x. The correction is an appended
version note, not a body rewrite and not a new claim.

### OpenBao (S014–S016): current within the recorded scope

- `https://openbao.org/docs/` and all three source pages render `Version 2.7.x`
  (2026-10-20).
- The latest OpenBao release observed was `v2.7.1`, published `2026-10-01`
  (`api.github.com/repos/openbao/openbao/releases`); no post-verification release was seen.
- S016 §Token Time-To-Live, §Token hierarchies and orphan tokens, and §Token type comparison
  were re-read; the quoted TTL/lease sentence, the orphan-token sentence, and the
  service-vs-batch table entries are present. S014’s three verification methods and its
  optional/required claim-mapping rule are present. S015’s TokenReview note and mitigation
  sentence are present.

So the OpenBao half of the entry is fresh at the recorded 2.7.x scope; the Vault half is not
fresh in its provenance.

### Fetch hashes

The registry’s `Fetch sha256` values are fetch-time evidence, not a live gate; `sources-census.sh`
does not verify them. Raw re-fetches today do not reproduce the recorded hashes for S012–S016,
but the registry does not record the canonicalization method used, so this audit does **not**
treat that mismatch as content-drift proof. The direct version-label observation above is the
evidence used.

### Absent-source limits (unchanged and still binding)

- S016 is OpenBao-only; Vault’s token page was not opened.
- OpenBao lease/KV documentation and Vault KV v2 delete/destroy/version-deletion semantics
  were not opened.
- No IdP other than the OpenBao Kubernetes path is covered.
- No deployed probe: documentation only; token expiry/revocation behavior was not measured.

## 6. Exact proposed recheck scope

The current `recheck:` line names S012 §JWT verification, S013 KV note, S015 TokenReview
note, S016 §Token Time-To-Live/§Token type comparison, and the OpenBao version label. It
**omits** S014 entirely and omits S012 §Bound claims/§Claims as metadata, both of which the
entry uses. Proposed scope, by source:

| source | sections actually used | check on trigger |
|---|---|---|
| S012 Vault JWT (`/vault/docs/auth/jwt`) | §JWT verification; §Bound claims; §Claims as metadata; 1.17 audience note; role/policy example | four verification methods and one-per-mount rule; exact `aud` match note; signature-and-expiry prerequisite; missing mapped claim fails login; record the served version selector |
| S013 Vault lease (`/vault/docs/concepts/lease`) | §Lease, renew, and revoke; §Lease durations and renewal; KV note | dynamic-secret/service-token lease; token revokes its leases; advisory increment; KV “does not issue leases”; record the served version selector |
| S014 OpenBao JWT (`/openbao.org/docs/auth/jwt/`) | §JWT verification; §Claims as metadata; role example | three methods/one per backend; metadata copy; leading-slash optional vs JSON-pointer required; version label |
| S015 OpenBao Kubernetes (`/openbao.org/docs/auth/jwt/oidc-providers/kubernetes/`) | §Kubernetes note | no TokenReview; revoked tokens valid until expiry; short-TTL/Kubernetes-auth mitigations; version label |
| S016 OpenBao tokens (`/openbao.org/docs/concepts/tokens/`) | §Token Time-To-Live; §Token hierarchies and orphan tokens; §Token type comparison; §The general case | TTL revokes token and associated leases; renewal bounds/periodic/explicit max; non-token auth orphan; parent revocation; service vs batch renewability/revocability; version label |

Triggers and bounds:

- **Vault release:** compare the release line (official releases API) to the served version
  selector. If the selector advances (as it did to `v2.x (latest)`), re-read the named
  sections, append a dated provenance note, and do not extend old claims to the new line
  without the read. The 2026-10-15 `2.2.0` release is such an event.
- **OpenBao release:** compare the docs Version label to `2.7.x`; if it changes, re-read the
  same sections and append. Latest observed `v2.7.1` (2026-10-01) is still within 2.7.x.
- **No trigger:** a matching local stamp is not a source recheck. A restamp only proves local
  bytes.

## 7. Append-only preservation and provenance requirements

**Proposed append delta** (fold into the pending errata before the first commit; if they have
already landed, append this after the second block verbatim, preserving all prior text):

```
## Erratum (round 22 — freshness and exact-source addendum)

The 2026-10-19 source line recorded S012's newest switcher entry as v1.21.x
and S013 as the same serving. On 2026-10-20 both unversioned Vault pages serve
"v2.x (latest)" and list v1.21.x below; Vault 2.2.0 was published 2026-10-15.
The cited S012 1.17 audience note, four verification methods, and S013 lease/KV
wording were re-read on that serving; no Vault 2.x-specific behavior is admitted
beyond those sections, and the header's 2026-10-19 five-page read is unchanged.

The first round-22 block's "following sentence" is the same S016 sentence:
"After the current TTL is up, the token will no longer function -- it, and its
associated leases, are revoked." No lease is not no deletion: S013 establishes
only that Vault KV does not issue leases; retention, expiry and
delete/destroy/version-deletion behavior were not opened for Vault or OpenBao
and remain unknown.
```

If the live 158-line text (two blocks, latest blob `854dd291…`) lands unchanged, the expected
row is `ff019fed04f4d9ead8a8ef9068d4712375f475cef3a888f555d3e0738fcde740` / 158 / 11291.
If the proposed delta or any further edit changes the final text, recompute the tuple;
observe the file once more immediately before committing, and never copy a draft hash.

1. **Never rewrite** lines 1–111 or the round-21 erratum text at lines 103–111. The live
   append is +47/−0 across two observed blocks and is compliant; corrections must continue
   that form.
2. If the pending errata are still uncommitted, fold the 4a/4b/5 corrections into them
   before the first commit (they are not yet historical text). If they have already landed,
   append a new dated block; do not edit the landed blocks.
3. Do not update the top `verified-at:`/`recheck:` headers to imply a full new five-page
   verification. Record the 2026-10-20 partial re-read (Vault v2.x serving; S016/OpenBao)
   inside the appended text, with its own date and scope.
4. The integration commit must record: base `c2cab35`, the old row
   `5fd53351…/111/8597`, the final file hash/lines/bytes, the fact that the change is an
   append (+N/−0), and the author/seat of the append. Commit the entry, the final stamp row,
   `corpus/lessons/round-22.md`, and `corpus/QUALITY.md` QA10 together.
5. Re-stamp **after** the final text, not the draft. Do not run a full-set `stamp` while the
   six base-stale rows and the other in-flight files are dirty; that would re-pin unreviewed
   bytes. A row-level migration with the exact old→new tuple is the safe form.
6. If the append is rejected, restore blob `ac553d9` exactly and keep the row at
   `5fd53351…/111/8597`; do not leave a half-reconciled pair.

## 8. Checks the parent should run after integration

- `git diff --numstat c2cab35 -- corpus/knowledge/vault-openbao-token-lease-lifecycle.md corpus/stamps.tsv`
  — prove append-only and only intended row movement.
- `bash corpus/claim-ledger.sh docs` — corpus-only declaration/pin check (safe; it does not
  re-verify vendor content).
- `bash corpus/sources-census.sh` — citation-chain check, no network (safe).
- Targeted four-field compare of the final file against the final row
  (`sha256sum`, `wc -l`, `wc -c` vs `awk -F'\t' '$1=="…"' corpus/stamps.tsv`).
- Full `bash corpus/claim-ledger.sh verify` only with the known host-private row handled per
  QM12; do **not** run it blindly on the live host, and do not auto-run `stamp`.

## 9. Remaining unknowns

- Exact time between 2026-10-19 and 2026-10-20 when the Vault pages began serving
  `v2.x (latest)`; the entry’s record and today’s observation differ, but the transition
  timestamp is not recorded.
- Whether Vault 2.2.x changed JWT/lease behavior outside the re-read sections; not tested.
- OpenBao lease/KV and Vault KV v2 deletion/retention semantics; not opened.
- Author/seat and decision provenance of the live +47-line, two-block append; not recorded.
- The canonicalization method behind the registry’s `Fetch sha256` values; not reproduced,
  so no hash-drift claim is made.

## Limits

Public docs and release APIs only; no vault, account, credential, secret, service, host gate,
build, test, formatter or installation. Quotes are at most 25 words each; source URLs and
read date are named above. This report does not claim depth, a new admission, or any score
movement.
