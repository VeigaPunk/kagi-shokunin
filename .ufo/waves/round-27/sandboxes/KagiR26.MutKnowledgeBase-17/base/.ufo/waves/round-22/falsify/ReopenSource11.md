# ReopenSource11 — S011 plus S017–S020 under the integrated round-22 tree

Seat: `KagiR22.ReopenSource11` (independent leaf attack; no W1 credit claimed, no W1 seat replaced).
Axes: calibration and freshness. No depth or legacy-header-count claim.

## Read revision and frozen inputs named

- HEAD / integrated landing: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` ("round-22: feature-bound review capability and audited revision repairs").
- Freeze record: `.ufo/waves/round-22/integration-manifest.json`, sha256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.
- Frozen input hashes re-measured and matching the manifest:
  - `corpus/SOURCES.md` — `3ba44518e2508f517d117c4678b3225f36b787ad645d9baf456c2a2da9023af7` (19,721 B, 86 lines)
  - `corpus/lessons/round-22.md` — `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` (15,700 B, 192 lines)
  - `corpus/knowledge/feature-bound-credential-review.md` — `0d186f58836b8edcaadd675c8e74640ce2e66ec19f88adc10247cbfd194a24fe` (4,440 B, 43 lines)
  - `corpus/feature-claims.json` — `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` (47,434 B, 995 lines)
  - `corpus/feature-claims.py` — `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` (45,532 B, 1,040 lines)
  - `corpus/knowledge/sops-age-key-rotation.md` — `a6b14ff7555fb972368d23e1e57bfb62170daa65ee4f2bd34521ff6819d407a7` (7,591 B, 112 lines)
  - `corpus/stamps.tsv` — `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` (7,213 B, 69 lines)
- Frozen BEFORE input `corpus/SOURCES.md` at base `c2cab35bc92e57e39e5489bac3386db078345b3f` — `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332`, matching `.ufo/waves/round-22/frozen/before/expected.json`.
- Production inputs were not modified by this seat. `git status` before/after shows only untracked `.ufo/waves/round-22/falsify*` artifacts.

Method: exact-URL public documentation GETs with `curl` (no launchers, version managers, npm/npx, package managers, loopback/health/CDP probes, account or vault contact); byte artifacts in `/tmp/r22-s011.html` and `/tmp/r22src11/`. No installation was needed or performed.

## S011 — SOPS key management (original row; reopened independently)

URL reopened: `https://getsops.io/docs/usage/key-management/` (raw HTML GET, 33,153 B), 2026-10-20.

| Check | Observed | Confidence |
|---|---|---|
| Row is byte-identical base→HEAD | `git show c2cab35:corpus/SOURCES.md \| grep '^\| S011'` equals the HEAD line; full SOURCES base→HEAD diff has **0 removed lines**, 43 added | high |
| Title / page identity | `<title>Key management \| SOPS: Secrets OPerationS</title>` | high |
| Revision stamp | `<meta itemprop=dateModified content="2026-05-15T19:05:01+02:00">`; footer links `getsops/docs/commit/9b7b84e297bdabc9c78e571c1e6db43dcd69454a` — matches the row's “last modified 2026-05-15, docs commit `9b7b84e…`” | high |
| Located anchors | raw HTML contains `id=adding-and-removing-keys`, `id=updatekeys-command`, `id=rotate-command`, `id=rotating-secrets-after-a-key-in-a-key-group-has-been-compromised` (and `id=direct-editing`, cited by the knowledge entry) | high |
| Quote location | “Use updatekeys if you want to add a key without rotating the data key.” appears inside `<h3 id=rotate-command>` as `Use <code>updatekeys</code> …` (§`rotate` command) | high |
| Recorded Fetch sha256 | row's `d0ab8b201f1a6d5f5751e1f261f904822492c530bdcdc5a4db9a8e178c2e180c` reproduces **byte-identically** from the raw HTML GET (same 64-hex, 33,153 B) | high |
| Teaching support | §`rotate` command: “The rotate command generates a new data encryption key and reencrypt all values with the new key.” plus the updatekeys sentence; §Rotating secrets… orders remove-key → `updatekeys` → `rotate` → rotate actual secrets. The row's teaching (“distinguishes recipient changes from creating a new data key and documents compromise sequencing”) is supported | high |

Round-22 usage of S011: `corpus/lessons/round-22.md` does not cite S011. `corpus/knowledge/sops-age-key-rotation.md` gained a 13-line “Clarification (round 22 — command-specific recipient changes)” whose S011 claims I re-checked: “rotate … can combine recipient additions/removals with creation of a new data key and re-encryption; updatekeys alone is the recipient-synchronization operation” — supported by the `rotate` section's flag list and the updatekeys sentence; “The footer commit is a docs repository revision” — the footer link is `github.com/getsops/docs/commit/…`, so this is supported. Stamp accounting for this path is not silent: `historical-correction-pins.json` records `9d73d218…` (94/6257) → `ea99430f…` (99/6796), `pin-migrations-integration.json` records `ea99430f…` → `a6b14ff7…` (112/7591), and the live `corpus/stamps.tsv:30` row equals `a6b14ff7… / 112 / 7591`. High confidence; no restamp was needed or made.

## S017–S020 — feature-specific status and eligibility, examined separately

Each page was reopened at its exact row URL. Status was read only at the feature's own title/H1/status badge; eligibility only from the named introduction/setup/requirements text.

| Row | Status anchor and text | Eligibility anchor and text | Verdict |
|---|---|---|---|
| S017 `github-actions` | H1 “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)”; body badge “Public Preview” | introduction: “If an administrator has connected your GitHub organization to your 1Password Business account” | supported |
| S018 `custom-workflow` | H1 “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)”; body badge “Beta” | introduction: “If an administrator has connected an OIDC provider to your 1Password Business account”; Step 1: “latest beta release of the 1Password desktop app”; Step 3 note: “Credential Broker is only supported in the 1Password JavaScript SDK at this time.” | supported |
| S019 `brokered-access` guide | H1 “Set up 1Password Credential Broker … (public preview)”; body badge “Public Preview” — the row's scope explicitly refuses a uniform per-feature label | introduction: “administrators can set up a supported integration in their 1Password Business account”; §Add an integration exists; §GitHub Actions requirements: “Your GitHub organization must be hosted on GitHub.com.”, Enterprise Server/Enterprise Cloud-with-data-residency unsupported, GitHub Free orgs cannot use private-repository workflows | supported as written |
| S020 announcement | Introduction: “moving Credential Broker from closed beta to public preview”; §New in this release: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | introduction: “available for all Enterprise Password Manager Business customers to start using right now” | supported; published 2026-07-28 (`meta-article:published_time`, body “July 28, 2026”) |

Consequences for the known overclaims:

- **Uniform Broker preview status is falsified at the feature anchors.** S017's own H1 says public preview; S018's own H1 says public beta. The S019 guide title/badge cannot override S018. The lesson's E1 correction is source-grounded.
- **Eligibility-free Broker availability is falsified.** S019's introduction and GitHub requirements and S020's EPM Business sentence independently state plan/setup limits.
- **Cross-product attribution is refused at the row level.** S020's split sentence names both statuses in one vendor sentence; S019's scope says “not uniform per-feature release status”; the knowledge review repeats the split with per-product limits.
- **Original rows are not mutated.** S006 and S007 (the superseded rows) are byte-identical at base and HEAD (zero removed SOURCES lines), and the appended round-22 disposition note records the supersession without rewriting them.

## Freshness measurements (pointer integrity only)

| Source | Recorded digest | My exact-URL raw GET | Result |
|---|---|---|---|
| S011 (SOURCES row) | `d0ab8b20…c2e180c` | `d0ab8b20…c2e180c`, 33,153 B | **reproduces byte-identically** |
| S017 (`feature-claims.json`) | `937f6828…ceed10849` | `937f6828…ceed10849`, 1,215,155 B | **reproduces byte-identically** |
| S018 | `d0890c11…ac62b76e5` | `d0890c11…ac62b76e5`, 1,282,825 B | **reproduces byte-identically** |
| S019 | `896c780b…fc3b4a9f` | `896c780b…fc3b4a9f`, 1,199,099 B | **reproduces byte-identically** |
| S020 | `55bf23fe…ebfe3eda` | two successive GETs: `202caee9…`, then `e8f93690…` (190,261 B class) | **not reproducible; render is non-deterministic** |

The S020 blog HTML differs between two immediately successive GETs (Next.js `buildId` and empty nonces present), so its recorded `sha256` is a point observation of a volatile render, not a drift pin. The two quoted sentences are present verbatim in both fetches (grep count 2 each), and `corpus/feature-claims.py` only shape-checks the hex (`re.fullmatch(r"[0-9a-f]{64}")`, lines 341/343) without fetching, so nothing load-bearing depends on that digest.

Bounded correction to the round-22 freshness caveat: the erratum says “Original Fetch hashes remain historical point observations with undocumented representation”. For S011 and the static docs pages S017–S019 the representation is now documented and reproducible (raw HTML GET), so those four digests *are* usable as local byte-identity pins today. The caution remains correct for S020 and for legacy rows whose representation is unknown. This is a strengthening of the freshness mechanism, not a restamp claim; digest identity never proves vendor currentness.

## Attempted attacks that did not land

- “S011 is stale / the footer moved” — refuted by byte-identical raw HTML and unchanged `dateModified`/commit.
- “S017–S020 apply one guide-level status to both features” — refuted at S018's H1 and S020's split sentence.
- “S017–S020 omit eligibility” — refuted at S019 introduction/requirements and S020 introduction.
- “Round 22 rewrote an immutable original row” — refuted: zero removed lines in `corpus/SOURCES.md` base→HEAD; S006/S007 unchanged.

## Observations that remain (limits, not observed false admissions)

1. **S019/S020 `teaches` cells carry a supersession relation that is not source text.** `corpus/SOURCES.md:25-26` begin “supersedes S007 — …” / “supersedes S006 — …”. The source pages do not say “supersedes”. The vendor facts in the same cells are supported; the relation is a registry statement whose support is S018/S020 and the preserved original rows. Calibration consequence: the `teaches` column is not purely a located teaching for these two rows, so a reader must not treat that clause as page evidence. Confidence high in the observation, high that no vendor fact is wrong.
2. **Latent, non-load-bearing cross-feature bindings in the typed catalog.** `corpus/feature-claims.json:157` binds `op_cb_custom_oidc`'s `feature` field to the quote “Your GitHub organization must be hosted on GitHub.com.” (S019-github-com); line 159 binds the custom-OIDC `path` to S019-business; line 162 binds `oidc_provider_connected` to S019-business. Those quote texts do not carry the bound values. They are **not** used by the custom-OIDC feature's `evidence_requirements` (line 238 uses `S018-intro`, which does state provider + Business), and the gate's binding check is text-blind (`corpus/feature-claims.py:624-744`, value match at 725-726, matches declared `(feature, field, quote_id)` bindings, not quote text). I observed no false admission from them; the risk is future reuse. If reused, re-anchor to a §Custom Workflow (OIDC) quote such as the issuer-URL instruction. Confidence high in the file/line facts, medium in the practical risk.
3. **S020 digest is not a pin.** Stated above; no claim of content drift or content stability beyond the two verbatim quoted sentences, which are present today.

## One concrete supported claim and one scope limit

**Supported claim (S011, §`rotate` command, https://getsops.io/docs/usage/key-management/, last modified 2026-05-15):** “Use updatekeys if you want to add a key without rotating the data key.” This is present verbatim in the reopened page and supports the row's distinction between recipient synchronization and data-key rotation.

**Scope limit (S011, §Rotating secrets after a key in a key group has been compromised):** the page says reversing the order can expose data “in some cases”, and its footnote restricts that to two situations: “doing it the other way is only a problem in two specific situations” — the file is checked in between the two calls, or the compromised key belongs to a provider that is itself compromised. A claim that the wrong order *always* leaks, or any per-provider (age/KMS) guarantee, is outside S011; S011 also does not establish data-key retention or plaintext handling beyond the documented command semantics.

## Remaining unknowns

- S020's recorded digest representation is unrecoverable (non-deterministic render); I can neither confirm nor refute that the page changed since its 2026-10-20 observation. Content-level checks rest on the two verbatim sentences only.
- I did not execute the feature/ledger gates (not assigned) and did not reopen S021 or the OpenBao pages (not assigned); no gate result is claimed. S006/S007 were checked only for byte-unchangedness, not re-adjudicated.
- The static docs pages' digests reproduced on the same day as observation; longer-horizon stability is not measured.

No production file was written; this report is the only artifact. No installs, no live vault/account operations, no host-private gates.
