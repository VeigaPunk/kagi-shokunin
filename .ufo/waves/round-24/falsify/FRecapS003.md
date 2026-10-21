# FRecapS003 — C2 S003 freshness falsification

**Frozen revision:** `c5ef9e92201b6c36396301f12b23740565bf86a0` (sandbox checkout HEAD verified). Scope is S003 only; this does not establish C2 for the other rows. No production files were changed; the live re-open and digest work ran in `/fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS003-9`.

## Findings

- **Fresh S003 capture: PASS for this row; no capture-metadata counterexample.** The committed `corpus/source-fetches.tsv:56` declares the registered URL and same final URL, HTTP 200, `curl-fsSL-compressed-v1`, 2026-10-21, `decoded-http-body-volatile-v1`, 1,369,709 decoded bytes, raw SHA-256 `2e697420d1d63ed12a32e204501914a7861cbdff3dec432ee382510f306c00c5`, and `rendered-text-v1` SHA-256 `915a222d374324128b3f00ee88484b2713b0e23f04a6e8f1233c4ed02fe3902d`. A fresh GET on 2026-10-21 reproduced the final URL/status, byte count, and both digests. The declared volatile representation makes this a point reproduction, not a claim of cross-response or cross-day stability.
- **Quote/scope: PASS, with a locator-precision caveat.** Both S003 quotes in `corpus/SOURCES.md:9` occur exactly once in the fresh normalized text. The credential quote is in the Step 1 list item describing `1password-credentials.json`; the current raw heading is `Step 1: Create a Secrets Automation workflow`. The token quote follows text saying requests use an access token under `Step 3: Set up applications and services to get information from 1Password`. This supports the deployment-credentials vs per-application-token distinction. The registry's `§Deployment` and capture row's `§Secrets Automation deployment` are shorthand, not exact visible heading text; this is not evidence the quote is false or that the old capture was false.
- **Historical in-row pin: declared comparison PASS; original provenance UNKNOWN.** `corpus/inrow-pins.tsv:9` correctly classifies `7f6d3b49ac3019073c37360c4771ebad2bad43a0f87ce314eb94bb0e0debe7ff` as `non-reproducing` against the declared 2026-10-21 alternatives: fresh/captured raw `2e697420…` and normalized `915a222d…`. The original 2026-10-19 representation/bytes are not supplied here. Therefore this establishes only “matches neither declared current representation,” not that the original capture was erroneous or that the page drifted.
- **Undocumented representation called current: no explicit instance found, with a wording caveat.** The S003 registry cell calls the old value `Fetch sha256` without naming a representation or explicitly calling it current. The in-row TSV header defines such pins as historical point observations of undocumented representation; the new fetch row separately names the decoded-body and normalizer domains. Read the bare registry label with that historical definition, not as a current digest.

**Severity:** No confirmed S003 freshness failure. Low residuals: the old pin's provenance cannot be reconstructed from available bytes, and the registry anchor is less exact than the current Step 1 heading. **Falsifiers:** a mismatch in the same-profile fetch's URL/status/bytes/raw or normalized digest/row identity would overturn the capture pass; original 2026-10-19 bytes plus their documented digest representation are required to resolve the pin's provenance. Later-page drift alone would not falsify the historical capture.

## Reproduction evidence

The local clone was made with `git clone --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS003-9/repo`, checked out detached at the frozen revision; `git rev-parse HEAD` printed `c5ef9e92201b6c36396301f12b23740565bf86a0`.

Commands ran with `env -i HOME=/fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS003-9/home PATH=/usr/bin:/bin`:

```sh
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -w '%{url_effective} %{http_code}\n' 'https://www.1password.dev/connect/get-started' -o /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS003-9/S003.body
python3 /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS003-9/repo/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS003-9/S003.body
python3 /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS003-9/repo/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS003-9/S003.body 'credentials necessary to deploy 1Password Connect Server'
python3 /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS003-9/repo/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24-recovery/KagiR24-2.FRecapS003-9/S003.body 'Create a new token for each application or service you use.'
printf 'S003\tmined\thttps://www.1password.dev/connect/get-started\n' | sha256sum
```

All exited 0. Stdout, in order: `https://www.1password.dev/connect/get-started 200`; `RENDERED_TEXT_V1: raw_sha256=2e697420d1d63ed12a32e204501914a7861cbdff3dec432ee382510f306c00c5 bytes=1369709 normalized_sha256=915a222d374324128b3f00ee88484b2713b0e23f04a6e8f1233c4ed02fe3902d normalized_bytes=11318`; `RENDERED_TEXT_V1_LOCATE: count=1` for each quote; and row identity `5c9e2761503028c25ea7ecd21a59f4e38e8de4047c619194258f393506833116`, matching `source-fetches.tsv:56`.