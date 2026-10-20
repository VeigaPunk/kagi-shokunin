# BuildQualifierGate — C1 implementation

Axes: calibration and freshness. This implementation covers the assigned C1 qualifier gate only; no C2 revision ledger work was performed.

## Files and behavior

Private-clone files changed:

- `corpus/feature-claims.py`
- `corpus/feature-claims.json`

The clone was created from frozen base `c2cab35bc92e57e39e5489bac3386db078345b3f`. The active round-22 `S017`–`S021` rows and `feature-bound-credential-review.md` were read from the live working tree as uncommitted integration material; they were not copied into or changed in the clone.
For the private FIFO correction, `corpus/feature-claims.py` was synchronized to H1 `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`; its pre-correction SHA-256 matched `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af`. The two H1 `not_asserted` status handling clauses were preserved. The only subsequent implementation change is final-component `O_NONBLOCK` plus FIFO self-invocation cases; JSON and code-held data pins were not changed.

The Python stdlib gate evaluates closed typed records for three topics: Credential Broker GitHub Actions; Credential Broker custom OIDC; and product-separated Vault dynamic-secret leases versus OpenBao token TTL. Claims bind product, named path, status, eligibility, runtime constraints, a typed fact, source ID, and exact quoted anchor. The page URL, quote, digest, and field bindings are pinned in the JSON; the source manifest, feature catalog, before/after records, transitions, and boundary records have separate code-held canonical digest pins. S018 status evidence must include its page-title/H1 binding: a `public preview` occurrence elsewhere on that page cannot override the title's `public beta`.

CLI:

- `python3 corpus/feature-claims.py --phase before` replays frozen known-bad records and exits 1 with per-record stable findings.
- `python3 corpus/feature-claims.py --phase after` (also the default) admits only the bounded corrected records and exits 0 when all are admitted.
- `python3 corpus/feature-claims.py --phase boundary` returns exit 2 for unjudgeable out-of-scope/unknown-feature, unknown-field, and unknown-source controls; these are reported separately, never counted as correct rejects.
- `python3 corpus/feature-claims.py --selftest` uses isolated subprocess fixtures for before/after/boundary, five `--input` decisions (one admit, four rejects), one permutation control, and writer-free FIFO paths through `--claims` and `--input` with one-second watchdogs (12 cases total; not run here).
- `--root DIR` selects a repository/fixture root; `--claims PATH` selects the pinned review artifact; `--input CLAIM.json` evaluates one typed claim without expected-label/authority fields against that immutable catalog (admit/reject/cannot-evaluate exits 0/1/2). Both paths use the same root-confined no-follow reader. Without `--root`, root is derived from the script.

The reader rejects duplicate JSON keys, unknown top-level fields, escaping paths, symlink components, non-regular files, and oversized/changing input. The final component is opened with `O_NONBLOCK | O_NOFOLLOW` and checked with `fstat` on that same descriptor, so a FIFO returns `FC-CLAIMS-FILE` instead of hanging. Sources are inert data: the gate does not open source paths, fetch URLs, or parse arbitrary claim prose. Known false qualifiers return `reject:false-claim`; missing/under-cited qualifiers and cross-product evidence return `reject:bar-fail`; unknown/out-of-scope data returns `cannot-evaluate`/exit 2. Per-case `DECISION` output and `(authority, defect, target)` `CELL` output separate false admissions, misses, misclassification and unjudgeable results rather than publishing one accuracy scalar.

## Retained evidence and controls

The source-page quotes below are each under 25 words and are anchored in the typed artifact:

| ID | anchor and quote | URL / opened | SHA-256 used |
|---|---|---|---|
| S017 | Page title/H1: “Use 1Password Credential Broker to access secrets in GitHub Actions at runtime (public preview)” | `https://www.1password.dev/brokered-access/github-actions/` — 2026-10-20 | `937f6828883599d23c736ae8df57daaa60fd30295c3a300b226caa4ceed10849` |
| S018 | Page title/H1: “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” | `https://www.1password.dev/brokered-access/custom-workflow/` — 2026-10-20 | `d0890c11edaa85d3ec68680d8d9bc867db502229fb3c815ee6b1b62ac62b76e5` |
| S019 | GitHub requirements: “GitHub organizations hosted on GitHub Enterprise Server or GitHub Enterprise Cloud with data residency aren't currently supported.” | `https://www.1password.dev/brokered-access` — 2026-10-20 | `896c780b243ebd1659dea22d6e46a1d4b2b74639adfde7ed22d8b362fc3b4a9f` |
| S020 | §New in this release: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | `https://1password.com/blog/1password-credential-broker-public-preview` — published 2026-07-28; reopened 2026-10-20 | `55bf23fe6e56375aef3daab62aa90d7c60f753b6f1aba631a1cfffdaebfe3eda` |
| S020 | Introduction: “available for all Enterprise Password Manager Business customers to start using right now” | `https://1password.com/blog/1password-credential-broker-public-preview` — published 2026-07-28; reopened 2026-10-20 | `55bf23fe6e56375aef3daab62aa90d7c60f753b6f1aba631a1cfffdaebfe3eda` |
| S013 | §Lease, renew, and revoke: “All dynamic secrets in Vault are required to have a lease.” | `https://developer.hashicorp.com/vault/docs/concepts/lease` — reopened 2026-10-20 | `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802` |
| S021 | §Token Time-To-Live: “After the current TTL is up, the token will no longer function -- it, and its associated leases, are revoked.” | `https://openbao.org/docs/concepts/tokens/` — Version 2.7.x, opened 2026-10-20 | `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` |
| S021 | §Token types: “The features in the following sections all apply to service tokens, and their applicability to batch tokens is discussed later.” | `https://openbao.org/docs/concepts/tokens/` — Version 2.7.x, opened 2026-10-20 | `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` |

S013 preserves its 2026-10-19 registry digest `ae321512d37ae70bc19e7b8698217ce8af0d3000bb76fe04039870bff25b8bf5` and records the reopened Vault bytes as `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802`. The prior OpenBao tokens page was S016 with registry digest `c083fdca8645f6248a3c42a8c0b912b356de281dc2da0099668a7850ba348380`; its reopened S021 bytes are `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c`. S006 (`39a869df8807696009d98bd6d0a86bc27524af65f94f235d37e6dd5a6e514c1f`), S007 (`e4aef238bb5c93080bc0e1cc2156d0f8d19c9291dbbee60193bd42485686f818`), and S012 (`ec6e7b250d181c5c3cbbffb482e96f96649b9f556884e069fb62f64798357c45`) retain their existing 2026-10-19 registry pins; S006/S007 appear only as under-cited historical support and S012 only as an out-of-scope boundary.

The non-author expected E1/E3 reject labels cite frozen `corpus/lessons/round-21-verifier-spotcheck.md`, §Spot-check, digest `6e4fa622ae953f343c294e3ce401303b6b6fa377e8800f9164047b08711f1ffb`. Its short findings are “E1 omits who can use Credential Broker and conflates GitHub Actions public preview with custom-OIDC beta” and “E3 stretches one product's docs to the other.” The remaining before controls are marked `construction-rule`; corrected controls are `verbatim-pin`; the three unjudgeable boundaries are labeled `author` and excluded from scoring. These provenance labels are not a claim of outside agreement for the new gate or semantic truth from schema validation.

The before/after transitions require only the listed eligibility, status, runtime-constraint, or evidence paths to change. The discriminating failures include E1 plan omission, custom-OIDC status conflation, a true beta claim under-cited by S006/S007, the same-page S018 wrong-status claim despite its title anchor, and E3's Vault-only OpenBao support. Corrected controls include bounded GitHub Actions, custom OIDC, Vault dynamic-secret leases, and OpenBao non-root service-token TTL; OpenBao admission requires the explicit service-token context and does not generalize the lease fact to batch tokens.

## Use, limits, registry/integration note

`--claims` selects the complete pinned review artifact, not an open-ended author-editable truth set. `--input CLAIM.json` accepts one typed claim object without expected labels or authority metadata and adjudicates it against the code-pinned source/feature catalog. Eligibility/runtime lists and source-reference lists are set-like: a permutation is immaterial, but duplicates, malformed values, and unknown qualifiers are not normalized into a pass. Any source, feature, control, label, or transition change requires a reviewed update to the JSON and code-held pins. The gate cannot prove the vendor page still says the quote, establish runtime behavior, decide arbitrary prose, or assert Vault/OpenBao parity. No tests, selftest, build, lint, or formatter were run in this editing wave; no packages/tools were installed.

Registry handoff: the latest `SOURCES.md` rows read for S017–S021 list both `corpus/lessons/round-22.md` and `corpus/knowledge/feature-bound-credential-review.md` as `used-by`; no reciprocity repair is indicated by that read. Those rows still lacked standalone located-quote and `Fetch sha256` fields; this artifact records them, but this seat changed no source registry or claim ledger. A future ledger row should not be invented here: the frozen-base `claim-ledger.sh` runnable-command allowlist excludes `python3`, so the parent must choose an allowed by-hand/registration treatment or explicitly own any allowlist change.

Checks for the parent after integration (not run here):

```text
python3 corpus/feature-claims.py --selftest
python3 corpus/feature-claims.py --phase before
python3 corpus/feature-claims.py --phase after
python3 corpus/feature-claims.py --phase boundary
```

Report: `.ufo/waves/round-22/build/BuildQualifierGate.md`
