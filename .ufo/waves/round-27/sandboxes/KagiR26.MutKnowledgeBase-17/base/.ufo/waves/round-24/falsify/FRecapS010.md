# S010 C2 freshness falsification

- Frozen lane revision: `c5ef9e92201b6c36396301f12b23740565bf86a0`; BASE: `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.
- Bounds: one registry entry (S010), its committed capture/classification/recap, and one fresh public fetch. No full C2 census or C1/C3 gate/calibration behavior was exercised.
- Result: **no S010 counterexample** to the committed raw-vs-normalized classification; this is a row-local finding, not an aggregate C2 pass.

## Evidence

- `corpus/SOURCES.md:16` records S010’s in-row pin `fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e`, the registered key-groups URL, and the quote “keys from multiple groups are required to decrypt a file.” Its scope says Shamir fragments and a configurable threshold; its locator identifies §Key groups and docs commit `9b7b84e297bdabc9c78e571c1e6db43dcd69454a`.
- `corpus/source-fetches.tsv:63` records the same URL/final URL, HTTP 200, capture date `2026-10-21`, `decoded-http-body-v1` raw hash (36,366 bytes), and `rendered-text-v1` normalized hash.
- `corpus/inrow-pins.tsv:16` records the same pin/date and `reproduces-raw`, explicitly comparing it to raw and normalized capture digests.
- Independently re-fetched in `/fast/scratch/kagi-r24-recovery/FRecapS010-9` after `git clone --no-hardlinks` and detached checkout; `git rev-parse HEAD` printed `c5ef9e92201b6c36396301f12b23740565bf86a0`. Execution used `env -i PATH=/usr/bin:/bin` and an empty sandbox `HOME`.
- Fetch command: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24-recovery/FRecapS010-9/S010-body.html -w 'final_url=%{url_effective} http=%{http_code}\n' 'https://getsops.io/docs/usage/identities/key-groups/'`; exit 0; stdout `final_url=https://getsops.io/docs/usage/identities/key-groups/ http=200`.
- `wc -c` printed `36366`; `sha256sum` printed `fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e`. Frozen checkout `corpus/rendered-text-v1.py digest <body>` exited 0 and printed raw hash above, `bytes=36366`, normalized hash `d1ef84f175c6b77902ac9804b1cb70d7915d378232fa63e5c54fd4a21b50a9a4`, `normalized_bytes=4138`. Its `locate <body> 'keys from multiple groups are required to decrypt a file.'` exited 0: `RENDERED_TEXT_V1_LOCATE: count=1` (normalizer definition/locator: lines 66–75, 106–117).
- Live fetched HTML lines 22–27 contain the quoted sentence and explain that Shamir sharing gives each group a fragment and a configurable number of fragments (threshold) is needed to reconstruct the data key. Lines 32–35 state the default threshold is the number of groups. The footer at line 100 gives the same modification date/commit locator. Quote and interpretation are supported.
- `build/RecapS010.md` also records its fetch, raw/normalized comparison, unique quote location, and scope evidence. My fresh fetch independently agrees with its recorded byte count and both digests.

## Axes and limits

- **Freshness:** S010’s 2026-10-21 recapture is current to this check and matches the in-row pin as raw bytes; it does not match the normalized digest.
- **Calibration:** `reproduces-raw` is the right row-local verdict. `decoded-http-body-v1` and `rendered-text-v1` are explicitly named representations; no undocumented representation is presented as the current capture.
- **Operability:** untested here; no gate, census, or ledger entry point was run.
- **Historical boundary:** matching today’s/2026-10-21 body to the older in-row digest establishes digest/metadata consistency and current reproduction of that pin, not independent reproduction of the original 2026-10-19 capture event. No contemporaneous original response body/transport record was examined. This is an evidence limit, not evidence that the original capture was false or that the page drifted.
- **Severity:** none observed for S010; no C2 S010 falsifier. A repeat under the declared capture/normalizer profile that mismatched both hashes while the row remained `reproduces-raw`, or failed to locate the quote in its stated scope, would falsify this row-local result.
- No tools were installed or updated.