# FRecapS013-9 — falsification of C2 S013 (fresh reopen)

Revision: frozen lane `c5ef9e92201b6c36396301f12b23740565bf86a0` (== lane HEAD; BASE `4f94b52a…` untouched, no lane writes besides this report).
Sandbox: `/fast/scratch/kagi-r24-recovery/FRecapS013-9` (clone/checkout at frozen rev; fetch and Python checks used its empty `HOME` and `env -i PATH=/usr/bin:/bin`).
Tools: curl 8.23.0, Python 3.14.8 (preinstalled; no installs). Reopen date: 2026-10-21.

## Assigned artifacts read (frozen tree)
- `corpus/SOURCES.md:19` — S013: mined, opened 2026-10-19, in-row pin `ae321512d37ae70bc19e7b8698217ce8af0d3000bb76fe04039870bff25b8bf5`, quote "All dynamic secrets in Vault are required to have a lease." (§Lease, renew, and revoke).
- `corpus/source-fetches.tsv:66` — S013 capture: row-identity `58ca84c2…`, registered URL == final URL, HTTP 200, `curl-fsSL-compressed-v1`, 2026-10-21, `decoded-http-body-volatile-v1`, raw `ac99140f11ac…` 261632 B, `rendered-text-v1`, normalized `0e62e05612ea…`, location §Lease, renew, and revoke.
- `corpus/inrow-pins.tsv:19` — S013 `ae321512…` / 2026-10-21 / non-reproducing / "pin ae321512d37a vs capture raw ac99140f11ac / normalized 0e62e05612ea".
- `.ufo/waves/round-24/build/RecapS013.md` — committed seat receipt; `.ufo/waves/round-22/build/Source13.md` and `falsify/ReopenSource13.md` exist (registry lore refs resolve).

## Fresh reopen (this seat, declared profile)
`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>` → exit 0, HTTP 200, final URL == registered URL, decoded body 261632 B, raw sha256 `ac99140f11ac…dcdeb` — **byte-identical to the committed capture and receipt**.
`python3 corpus/rendered-text-v1.py digest S013.body` exit 0: raw `ac99140f…` bytes=261632, normalized `0e62e056…` normalized_bytes=7354 — equals committed row 66 exactly.
Normalizer integrity: `--selftest` PASS (cases=20); sandbox script sha256 `a0b980b8…` == `corpus/stamps.tsv` pin.
Quote: `locate` exit 0, count=1. Heading "Lease, renew, and revoke": count=2 (H1 at normalized offset 3134; page-title tail at 7090); quote at 3808; no "Lease durations and renewal" heading between — receipt's H1-proximity claim verified.
KV note "does not issue leases although it will sometimes return a lease duration": count=1 — the knowledge entry's static-KV exception stays grounded on today's page.
S023 supersession check: raw body contains `content/vault/v2.x/content/docs/concepts/lease.mdx` (count=1) — a v2.x route IS served today; S013's "no displayed version/date" caveat is stale exactly as S023 records. Later observation, not proof the 2026-10-19 capture was false.

## Verdicts (axes: operability, freshness, calibration)
- Freshness: **PASS**. Independent reopen reproduces both committed digests byte-exactly; quote locates once under the declared heading; no drift observed 2026-10-21.
- Operability (metadata consistency): **PASS**. SOURCES pin == inrow-pins col2; capture date matches fetches date; note digests == fetch row raw/normalized; fetches col3 reproduces as sha256("S013\tmined\t<url>\n") = `58ca84c2…`; committed verdict column counts 12 non-reproducing / 4 reproduces-raw / 0 reproduces-normalized, matching census R21-01 expectation `inrow=16 inrow_nonreproducing=12`.
- Calibration (classification): **PASS**. `ae321512…` matches neither declared representation (raw `ac99140f…`, normalized `0e62e056…`) → "non-reproducing" is the correct verdict; header pins such values as historical point observations of undocumented representation, kept, explicitly not evidence of page change; consistent with round-23 "no tested representation" wording.

## Counterexamples / residual notes (none falsify)
1. [low] Same-day raw duality: S023's round-23 row (same URL, 2026-10-21) records raw `de5f8836…` 261632 B while S013's round-24 row and this reopen record `ac99140f…` — same length, identical normalized digest. Corroborates `decoded-http-body-volatile-v1`; raw equality on this URL is meaningless, as the TSV header already declares ("no cross-capture equality is enforced").
2. [low] `corpus/feature-claims.json` S013 `"sha256": de5f8836…` (`digest_observed_at` 2026-10-20, introduced commit `8ada17a`) equals the S023 volatile raw capture and no longer matches today's raw body. Documented: `prior_registry_sha256: ae321512…` and the file-level limit "SHA-256 values attest captured response bytes, not live drift pins"; the gate never fetches. No per-field representation declaration inside the artifact — historical attestation, never called current.
3. [info] S013's row text retains the stale caveat without an in-row supersession marker; supersession is documented at `SOURCES.md:29,106-116`, the round-22 errata lesson, and RecapS013.md ("does not revive it").
4. [info] RecapS013.md invoked the normalizer from the real lane path rather than a sandbox copy; its recorded digests reproduce here, so no integrity impact.

**No falsifier found**: committed capture, classification, and receipt for S013 verify at the frozen revision as of 2026-10-21; no undocumented representation is called current in the S013 chain.
