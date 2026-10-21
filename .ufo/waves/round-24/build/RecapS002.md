# S002 live recapture

## Capture and digest

Registry entry: `corpus/SOURCES.md:8` — `https://www.1password.dev/connect`; historical in-row `Fetch sha256` pin: `68017d4cf1655abb55baec982c2ed89b5a73731bba0275ca2426a25dfcd9d2a6`.

Saved body: `/fast/scratch/kagi-r24/seats/RecapS002-2/S002.body`.

Command (declared documentation profile):

```sh
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' --output /fast/scratch/kagi-r24/seats/RecapS002-2/S002.body --write-out '%{url_effective} %{http_code}' 'https://www.1password.dev/connect'
```

Exit 0; stdout: `https://www.1password.dev/connect 200` (final URL; HTTP 200).

Digest command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS002-2/S002.body` — exit 0. The script reports `raw_sha256=9b5dc190d03d118e2e956a83e157477a6d88cf568aeb9179c0c29f717ac4a975 bytes=1186855 normalized_sha256=b82b2b2cae2805bb4aaa0a4ceeee42709f07f014ff328bd5186fa036dc8779f2 normalized_bytes=2362` (`corpus/rendered-text-v1.py:61-70,90-97`). The byte count is the downloaded body after curl's `--compressed` content decoding.

Pin comparison: historical in-row pin matches neither current digest — raw match: **no**; normalized match: **no**. These are distinct representation-level observations; digest mismatch alone does not establish semantic drift.

## Quote location and live support

The registry's quoted span is: “The Connect server is part of your environment, and communicates to Your Apps using access tokens and a REST API.”

Command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS002-2/S002.body 'The Connect server is part of your environment, and communicates to Your Apps using access tokens and a REST API.'` — exit 1; `RENDERED_TEXT_V1_LOCATE: count=0` (`corpus/rendered-text-v1.py:101-112`).

Closest live sentence grounding the same claim (25 words; verbatim from the normalized capture):

> 1Password Connect Servers allow you to securely access your 1Password items and vaults in your company’s apps and cloud infrastructure using a private REST API.

Nearest preceding heading: **1Password Connect** (h1).

Assessment: **partly**. The live sentence supports application access using a private REST API, but the captured page does not state the access-token part of the row's teaching. The quoted span itself is absent. Thus the row's REST API boundary remains supported, while its access-token detail is not substantiated by this live page. Source row and historical pin remain unchanged.

## Evidence scope

Observed facts above are from the live capture and the registry entry (`corpus/SOURCES.md:8`). No tool was installed or updated; no repository source or registry content was changed.
