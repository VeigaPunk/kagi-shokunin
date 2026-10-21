# FRecapS006 — S006 C2 row check (2026-10-21)

## Scope and bounds
- Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; original BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- Cloned with `git clone --no-hardlinks` under `/fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS006-9/repo` and checked out the frozen revision there; executions used `env -i PATH=/usr/bin:/bin` and an empty sandbox `HOME`.
- Bound to S006 in `corpus/SOURCES.md:12`, its fetch row `corpus/source-fetches.tsv:59`, classification `corpus/inrow-pins.tsv:12`, and `build/RecapS006.md`. No production file was changed; the fresh body remained in the sandbox.
- Axes: row-level freshness and pin classification examined; full 16-row census/selftest, C1 operability, and C3 calibration were not run (unknown/out of scope).

## Fresh source observation
- Re-opened the registered URL with `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`; exit 0, final URL unchanged, HTTP 200. Output body: 190261 bytes; `sha256sum`: `373561683ef8504f11557143116784c378657b04d524712754aa2855072b5e33`.
- `python3 corpus/rendered-text-v1.py digest <body>` exited 0: raw SHA-256 above, bytes 190261; normalized-text-v1 SHA-256 `20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f`, normalized bytes 9530.
- `locate` on that body returned count=1 (exit 0) for each registered quote: `unlike a service account token that carries standing access, the organization-wide integration key is an encryption key`; and `is in public preview`.
- Full scope quotes also located once each (exit 0): `1Password Credential Broker is in public preview, and available now for all 1Password EPM Business customers`; `Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows`.
- One initial grouped optional lookup passed literal backslash-u0027 instead of an apostrophe, so that query returned count=0/overall exit 1; retry with the apostrophe returned count=1/exit 0. This was command quoting, not source evidence.

## Findings
- The registered historical pin is `39a869df8807696009d98bd6d0a86bc27524af65f94f235d37e6dd5a6e514c1f`. The declared 2026-10-21 receipt gives raw `fe37e1f3ef4465fe2aa420b4c4bfbc278c7f6747887ddc272fa9ea246e4901e7` and normalized `20b4…1804f`; neither equals the pin. `non-reproducing` is therefore correct for the two declared comparisons. This is not proof that the historical fetch was false: `SOURCES.md:95-96` explicitly leaves its old pin representation undocumented and rejects changed raw hashes as semantic proof.
- Metadata traceability caveat (low severity): `build/RecapS006.md:15-16` instead reports raw `d6e2ea9eec883f7da1870a77e5d8e17492830859376e45e5aa3b504a88873838`; its byte count and normalized digest match the TSV receipt. My independent live fetch produced a third raw digest, while retaining the same normalized digest and byte count. The TSV explicitly labels its body `decoded-http-body-volatile-v1`; no evidence links the build note and TSV to the identical response, so the raw mismatch is a concrete artifact-identity gap, not proof of content drift or a wrong historical pin.
- No undocumented representation is called current here: the new raw hash identifies only my observed response; normalized output is explicitly `rendered-text-v1`; the old in-row hash remains representation-unknown.
- Row-local result: quote presence and the pin's `non-reproducing` classification are supported; the recap's dated-announcement scope is supported by the observed text, including Business eligibility and the custom-OIDC beta split. This does not establish current release status outside this dated announcement.

## Verdict / falsifier / remaining unknowns
- C2-S006: **PASS for the bounded quote and declared raw-vs-normalized classification checks; WARN for raw-artifact linkage**. Severity: low, traceability only. Falsifier of any assertion that the recap raw hash and TSV raw hash identify the same bytes: the two raw SHA-256 values differ. Whether they were intended to identify one fetch remains unknown; the normalized content agrees.
- Historical pin reproduction: **non-reproducing** against both registered capture representations; historical capture validity remains **unknown** because the original representation is undocumented. Full C2 population and other axes remain unassessed.