# FRecapS005 — C2 S005 freshness

## Bounds

- Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- Read only the S005 row in `corpus/SOURCES.md`, its rows in `corpus/source-fetches.tsv` and `corpus/inrow-pins.tsv`, `.ufo/waves/round-24/build/RecapS005.md`, and the registered public URL. Fresh fetch and normalizer ran only in `/fast/scratch/kagi-r24-recovery/FRecapS005-9` from a no-hardlinks clone checked out at the frozen revision; `HOME` was the empty sandbox directory and execution used `env -i PATH=/usr/bin:/bin`. No installs.

## Observed facts

- S005's historical registry pin is `f7ba8254b1109111c42429eb896b9ba767a7320c20c5a9c5fc6f1d993bdffd2f`, opened 2026-10-19. The row calls it `Fetch sha256` but does not identify its byte representation; it is not described as a current digest.
- The 2026-10-21 fetch row records HTTP 200, `curl-fsSL-compressed-v1`, raw representation `decoded-http-body-volatile-v1`, 196,082 bytes, raw SHA-256 `0be7a540048cd4cc69129f7e148f86541d81ff470dc3af1f73887aa36f390b25`, and `rendered-text-v1` SHA-256 `f439a0eb0411a3d5191849b5b7f8d20d3fe4634656e7589d281378e0e8934c2a`.
- `inrow-pins.tsv` classifies S005 as `non-reproducing`: the historical pin equals neither the recorded raw nor normalized digest. This is the correct classification against that capture; it does **not** establish that the historical capture was false, nor reveal whether its undocumented digest was raw or normalized.
- The committed `RecapS005.md` reports a separate 2026-10-21 curl capture with the same 196,082-byte length and normalized digest, but raw digest `f1319513a95fd351ad89a493b98d9f7384d0d3e53583640fbb574a09bb3bace5`, not the fetch TSV's `0be7…`. Its exact fetch identity is not tied to the TSV row.
- Independent reopen command (exit 0): `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r24-recovery/FRecapS005-9/home /usr/bin/curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24-recovery/FRecapS005-9/s005-current-body.html -w '%{url_effective} %{http_code}\n' 'https://1password.com/product/credential-broker'`. Stdout: `https://1password.com/product/credential-broker 200`.
- The frozen `rendered-text-v1.py digest` on that fetched body (exit 0) returned raw SHA-256 `2eacce7b516b41397df284ed0fa5e6fb37172cd151bcc6e7861465307e1fcaa6`, 196,082 bytes, normalized SHA-256 `f439a0eb0411a3d5191849b5b7f8d20d3fe4634656e7589d281378e0e8934c2a`, 5,818 normalized bytes. `locate` (exit 0) returned `count=1` for the exact S005 quote. The reopened public page shows it under H3 “The platform identifies the job”: “Credential Broker checks the workload's identity against your policy, then delivers the exact credentials that specific job is approved for.”
- The quote still supports S005's bounded high-level policy-checked workload identity / approved-delivery scope, not configuration mechanics. Both committed and fresh capture records name the raw representation; the historical registry pin is retained as historical, not called current.

## Judgment

- **PASS — quote, anchor, and scope (C2/S005):** exact sentence and H3 reappear; confidence high. **PASS — pin classification:** `non-reproducing` accurately means no equality with either recorded capture digest.
- **UNKNOWN — capture metadata linkage (low severity):** the build receipt and TSV have different raw hashes despite equal date, byte count, and normalized hash; the fresh reopen has yet another raw hash while retaining that normalized hash. The TSV explicitly marks raw bodies volatile, so these observations do not prove the historic capture false or the TSV wrong. No capture ID/byte artifact linkage establishes whether the build receipt and TSV refer to the same request. If they are asserted to be one capture, that raw-hash disagreement is a metadata inconsistency; a shared capture ID or preserved body would resolve it.
- **PASS — representation naming:** no undocumented historical representation is promoted as current; current TSV raw and normalized domains are explicitly named. Do not use raw digest drift alone as source-content drift evidence.

No broad census or C1/C3 behavior was tested; no tests/builds were run.