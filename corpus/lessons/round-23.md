source: S008, S014, S016, S017, S018, S019, S020, S021, S022, S023, S024, S025, S026
verified-at: 2026-10-21 (public documentation pages reopened over HTTPS; no account, vault, or handler probe)
recheck: on-release — reopen the featured Broker pages and the KV/OpenBao docs when a release or docs version route changes.

# Round 23 — outside decisions become obligations; source provenance becomes declared

Frozen starting revision: `d218603b74099ddca0bd8f869516fc41db0979bf` (round-22
non-author spot-check). Claims are frozen in `plans/round-23.md`: C1 calibration
(consume the closure's decisions through a resolving disposition gate), C2
freshness/D7 (declared fetch provenance for registry rows without an in-row
pin, plus three correction rows), C3 operability/D9 (a hermetic committed-fixture
`cells` row). No depth takeover, no legacy-header migration, no host/private
gate, no account or vault operation.

The round-22 closure admitted the lane with routed defects D1-D9. Those are
evidence of debt, not agreement: each gets exactly one typed disposition below,
and `corpus/closure-dispositions.py` fails if one is missing, duplicated,
unknown, or its `fixed` pointer no longer resolves in the tree.

## Gate — sources opened and admitted this round

New rows (all tier A, mined; the registry cell carries no digest — the declared
provenance lives in `corpus/source-fetches.tsv`):

| row | URL | located quote (≤25 words) | admission scope |
|---|---|---|---|
| S024 | https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2 | “max_versions (int: 0) – The number of versions to keep per key.” (POST /:secret-mount-path/config parameters) | KV v2 backend-level version retention; `delete_version_after` is a separate parameter; configuration only, not deployment or retention proof |
| S025 | https://openbao.org/docs/auth/jwt/ | “The jwt auth method can be used to authenticate with OpenBao using OIDC or by providing a JWT” (H1 JWT/OIDC auth method, rendered text) | supersedes S014's under-declared anchor/quote; page renders `<code>jwt</code>`; both OIDC and direct-JWT paths |
| S026 | https://openbao.org/docs/concepts/tokens/ | “When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well.” (§Token hierarchies and orphan tokens, rendered text) | supersedes S016's undocumented-representation pin; OpenBao token revocation only |

Search: question = can the KV v2 retention parameters and the OpenBao token/JWT
locators be bound to declared representations; where = the two HashiCorp API
pages and the OpenBao docs routes already in the registry; identified 3,
screened 3, included 3, excluded 0. Stop: each row's named scope is resolved
and no unrelated federation or scanning material is absorbed.

Re-opened rows used for the provenance table (not new rows, fields unchanged):
S017-S023 were reopened 2026-10-21; the exact per-row digests and quotes are in
`corpus/source-fetches.tsv`. Quotation rule: quotes are located under the
declared `rendered-text-v1` normalization (strip `script`/`style`, tags to a
single space, `html.unescape`, collapse whitespace, trim both ends, UTF-8 encode); they are not claimed to be
raw-byte substrings. S008's rendered-text quote and S014's uppercased quote stay
historical; S025/S026 are the corrected active locators.

Hash domain: `decoded-http-body-v1` is the HTTP entity body after curl removes
`Content-Encoding`, and `bytes` is that body's length. S020 is declared
`decoded-http-body-volatile-v1`: its raw HTML carries a per-response Cloudflare
email-protection fragment (two same-day GETs gave `56ade2d0…` and `cbd70b29…`
at constant 190,261 B), while its normalized-text digest was stable across two same-day GETs
(`20b4fd86…` twice). A provenance digest — raw or normalized — is a point
attestation of the declared representation, never a content-drift pin, and
never a deployment or vendor-truth proof; page chrome can move the normalized
digest between days (S017's sidebar changed while its article did not), so no
cross-capture equality is enforced.

## Before → after

| claim | before (frozen base) | after | counting command |
|---|---|---|---|
| C1 | `test -e corpus/closure-dispositions.py` → 1; 9 `^- D[0-9]` obligations with no machine record | gate present; `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 ...)`; selftest 14 cases | `python3 corpus/closure-dispositions.py`; `--selftest` |
| C2 | `grep -c 'Fetch sha256:' corpus/SOURCES.md` = 16 of 23 rows; 0 `source-fetches` references in the census | 26 rows; 16 legacy pins + 10 declared provenance rows; census `SC_FETCH` enforces shape, identity, URL and row-identity digest; captures are point attestations; selftest 59 cases | `bash corpus/sources-census.sh`; `--selftest`; `grep -c '^S0' corpus/source-fetches.tsv` |
| C3 | 0 ledger rows executing `cells` host-free; R13-03 skipped for host rows | `R23-01` runs `cells` at a committed fixture root and must print `CELL_AUDIT: CLEAN`; a fixture mutation fails | `bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic ...` |

## Routed defect dispositions

D1. The census prints five W04 duplicate-URL warnings; the round report quotes
them verbatim, not only the `kagi ok` line:
`W04 S019 duplicate url www.1password.dev/brokered-access across scopes`,
`W04 S020 duplicate url 1password.com/blog/1password-credential-broker-public-preview across scopes`,
`W04 S021 duplicate url openbao.org/docs/concepts/tokens across scopes`,
`W04 S022 duplicate url developer.hashicorp.com/vault/docs/auth/jwt across scopes`,
`W04 S023 duplicate url developer.hashicorp.com/vault/docs/concepts/lease across scopes`.
(The duplicate-URL warnings are expected: S019/S020/S022/S023 are
correction rows over URLs already registered by S007/S006/S012/S013, and
S025/S026 add further correction rows over `docs/auth/jwt/` and
`docs/concepts/tokens/`; W04 is a warning, not a failure.)

D2. No install was performed this round. The round-22 install record's host
side effect is named here for the record: mise wrote the global
`~/.config/mise/config.toml` (node latest) outside the directive's channel
list. That write is outside this lane's authority; revert stays operator-owned.
This round's only network use was `curl` against public documentation pages.

D3. Every wave context this round names the forbidden paths (host-private
files, vault refs/tokens, live config contents, sibling lanes, `.ufo/state`,
MANIFEST.json) and the no-prompt-injection rule. The pre-surface guard that rejects a mode token is exercised by the ledger
selftest case `mode-unknown-revision` (`unexpected positional argument for
verify`). It does not yet cover an id-shaped positional (`R1-01`); that gap is
routed debt from the parent audit (`ClaimR11X09`), not claimed as fixed, and no
wave in this round may run a legacy verify.

D4. Stale-pin dispositions cite the drift-causing commit per tuple, re-measured
from lane history: four knowledge pins drifted at `f4a8dd9` (round-16 source
qualification), the round-18 lesson at `bad9088` (round-19 audit corrections),
and `LOG.md` at `584dd67`/`c2cab35`. Restamping proves pointer integrity, not
source currentness.

D5. Round-22 wave accounting is stated as it was: 130 spawn IDs under 129
names; `CriticNoTrade` was reused as a fresh `-2` identity in the second wave,
so the id count and the name count differ by one. No seat was replaced.

D6. The measured commit belongs in the verdict file itself, not only in an
input-digest sidecar. This round writes `measured_commit` into
`.ufo/waves/round-23/final-verification.json`.

D7. `corpus/source-fetches.tsv` + `SC_FETCH` bind every row without an in-row
pin to a declared representation, URL, final URL, HTTP status, row-identity
digest and a declared quote (shape-checked only, not verified against the page). Bound, stated: legacy in-row digests (S001-S016) remain
historical point observations with undocumented representation. The audits this
round confirmed that bound is real, not theoretical: S008's in-row digest
reproduces (1909 B, `63cb0a46…`) but its quote is reST-rendered; S012/S013's
in-row digests do not reproduce under any tested representation; S014's
`e9472324…` matches none of seven representations; S016's `c083fdca…` matches
neither raw `52295218…` nor normalized `ed949658…`; the parent audit also
measured S015's active in-row `a0a2b227…` against 520 representations with no
match, so S015 remains a named historical-pin debt (fix: a declared capture,
not a restamp). Superseding rows S025/S026
carry the corrected active locators and declared digests; the old rows keep
their historical values and are never silently rewritten.

D8. `/tmp/kagi-shokunin` scratch residue from round 22 still exists. Cleanup is
operator-owned (host scratch ground); this lane neither deletes it nor claims
it restored.

D9. `R23-01` runs `cells` against a committed fixture
(`corpus/fixtures/cells-hermetic/`) with no host file, no `$HOME`, and no
substrate dependency. `R13-03` keeps its skip for host-bound rows. The known
`SKIP-SELF` bound is reported rather than laundered: a scorecard cell citing a
row that re-invokes the gate is skipped and counted in `self_skipped`, so
`CELL_AUDIT: CLEAN` with `self_skipped>=1` does not verify that row. This round
found, from the parent-held audit, that `R11-08` (citations) is red at the base
revision because the round-22 spot-check file adds three class-shaped tokens
that do not resolve; the row is inherited evidence, not this round's claim, and
is reported unverified instead of credited.

The outside spot-check's five discernment decisions (SPOT-01..05) and its
`ADJ` adjudication are recorded `no-action`/`reported`: the reviewer agreed
with the sampled admits and rejects, so no source row is rewritten to
manufacture agreement.

## Mistakes

| id | class | evidence pointer | captured-by before | fix |
|---|---|---|---|---|
| M23-1 | a digest with no declared representation was treated as provenance; a cross-capture equality rule punished honest recaptures | `corpus/SOURCES.md` in-row pins S012/S013/S014/S016; parent audit reports `SourceS012.md`, `SourceS013.md`, `SourceS014.md`, `SourceS016.md`; `source-fetches.tsv` re-captures | QA6 ("a count carries its command") did not distinguish a digest value from its representation | `SC_FETCH` requires representation, request profile, final URL, status and row-identity; legacy pins are explicitly bounded as historical; captures are point attestations and no cross-capture equality is enforced |
| M23-2 | supersession and used-by edges were prose-only, so a pointer closure could miss real consumers | S012's consumers in `corpus/feature-claims.json:63-77,915-932` and `corpus/README.md:78`; S018 body citations in `onepassword-machine-credentials.md:42,52,55` | QA10 covered qualifier travel, not machine-readable supersession/used-by | recorded as routed debt with named consumers; the census keeps its declared used-by shape, and no silent widening is claimed |
| M23-4 | seat reports misrooted to the fleet root | `.ufo/waves/round-23/falsify/RevS019.md`, `ScoutMigration.md`, `parent-build/ClaimR11X11.md` were found under the fleet root and byte-copied into the lane (`cmp` equal) before deletion | assigned absolute Report paths in every wave context | relocate and keep the fleet root clean; report names the misroot |
| M23-3 | `cells` can print CLEAN while a cited row is self-skipped and red | `claim-ledger.sh` `SKIP-SELF` path; `R11-08` red at `d218603` per parent audit `ClaimR11X08.md` | QM3 counted skips in verdict lines but not the self-skip exemption | reported as unverified; the hermetic fixture deliberately cites no self-invoking row, and the real-tree claim is not made |

Sweep that looked for a fourth mistake and found none:
`git -C kagi-shokunin diff --stat d218603..HEAD -- corpus/lessons corpus/QUALITY.md`
shows only this round's appends, so no silently rewritten lesson body exists.

## C3 fixture contract

`corpus/fixtures/cells-hermetic/` holds a five-file fixture: a six-axis
scorecard whose cells cite the illustrative fixture rows `R90-01` and
`R90-02`, a claims file with two local-only rows, two stamped fixture rows, and
`corpus/fx-ok.sh`. `stale_pointers=0` covers only paths a cell cites, so the
`fx-ok.sh` stamp is inert in this run (stated bound). `R23-01` runs
`bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic
--claims .../claims.tsv --stamps .../stamps.tsv --scorecard .../SCORECARD.md
--docs .../SCORECARD.md` and must print the exact `CELL_AUDIT: CLEAN` line.
The fixture is copied by the falsify wave, mutated (uncited cell, bad row id,
failing row) and must fail. `rows_run` counts selected rows including deferred
rows, so the ledger pins `row_deferred=0` and `self_skipped=0`, not `rows_run`
alone. No real host path is read.

## Source accounting

Registry: 23 → 26 rows (one new frontier row, S024 KV v2 API; two correction
rows, S025 OpenBao JWT locator and S026 OpenBao tokens locator). Distinct URLs: 18 → 19
(only the KV v2 API URL is new). `source-fetches.tsv` carries 10 declared
provenance rows (S017-S026) over nine distinct URLs. The census gate's
`SC_FETCH` covers every registry row by in-row pin or declared provenance.

Tool installs: none this round. Census at round start: exit 0 with five W04
warnings (quoted under D1); census at round end must exit 0 with the same W04
warnings and `rows=26`.

## Falsification bounds (round 23)

The 64-seat falsification wave reported on the three claims and named these
bounds, which the report repeats: C1's pointer test is presence-only (a
`fixed` pointer proves a file plus anchor substring plus id token, not fix
content); the obligation source digest is pinned in the same lane-writable
JSON, so the gate proves internal consistency, not that nobody deleted an
obligation; anchor matching is a substring over any `#`-prefixed line; and only
`fixed` dispositions require the id token. C2's SC_FETCH is shape-and-identity,
not content verification: a 64-hex in-row digest passes on presence (the
historical bound), quote text and location are not checked against the page (a changed-word quote, a blank quote, or 60 thin-space-joined words pass; only ASCII word count and a non-empty location are shape-checked), and captures are point
attestations (page chrome moved S017's and S023's normalized digests between
days while their articles did not). C3's fixture proves the `cells` mechanics
host-free; it does not replicate all 43 ledger rows, and `rows_run` counts
selected rows, so only `row_deferred=0`/`self_skipped=0` exclude an unexecuted
fixture.

Late falsify-report bounds (post-landing sentinel `SentHostReads`): R23-01's
hermeticity is per-row, not enforced by `cells` (a row using `~`/an absolute
argument passes `policy_check`), so the fixture's rows are the guarantee, not
the checker; the closed-pointer containment is path-based and an in-root
hardlink to an outside inode would still be read; Python startup stats
`$HOME/.local/lib/...` without opening files, and `mktemp` writes one `/tmp`
file that is removed. The symlink-escape guard now has a regression case
(selftest 14 cases). The 59-case census selftest exercises the declared-provenance
branch; the 16-row in-row branch is exercised only by the real-tree run, so the
selftest count does not certify that half of `SC_FETCH`.
