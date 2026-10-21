# S011 legacy pin recapture

Source row: `corpus/SOURCES.md:17` — S011, “Key management on SOPS.”

## Fetch and digests

- Exact registered URL: `https://getsops.io/docs/usage/key-management/`
- Scratch body: `/fast/scratch/kagi-r24/seats/RecapS011-2/S011.body`
- Fetch command: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24/seats/RecapS011-2/S011.body -w '%{url_effective} %{http_code}' 'https://getsops.io/docs/usage/key-management/'`
- Fetch result / exit: final URL `https://getsops.io/docs/usage/key-management/`, HTTP `200`, exit `0`.
- Digest command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS011-2/S011.body` (exit `0`).
- Decoded body bytes: `33153`; raw SHA-256: `d0ab8b201f1a6d5f5751e1f261f904822492c530bdcdc5a4db9a8e178c2e180c`.
- Normalized bytes: `5451`; normalized SHA-256: `4a71dbc959fc4a0dd596c973d90001e894b28558db0774d6d0f8653c1af4c536`.
- S011 in-row pin: `d0ab8b201f1a6d5f5751e1f261f904822492c530bdcdc5a4db9a8e178c2e180c`; raw match **yes**, normalized match **no**.

## Quote location and live claim

S011 quote: “Use `updatekeys` if you want to add a key without rotating the data key.”

- Locate command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS011-2/S011.body 'Use `updatekeys` if you want to add a key without rotating the data key.'` (exit `1`, the documented not-found result); output `RENDERED_TEXT_V1_LOCATE: count=0`.
- The normalized page renders the same sentence without the source quote’s code-format backticks, while `locate` collapses whitespace only in the supplied quote (`rendered-text-v1.py:73-74,101-112`). Closest live sentence: “Use updatekeys if you want to add a key without rotating the data key.” Nearest preceding heading in normalized text: `rotate command`.
- Scope/teaches: **yes**. Under `updatekeys command`, the live page says, “The updatekeys command uses the .sops.yaml configuration file to update (add or remove) the corresponding secrets in the encrypted file.” Under `rotate command`, it says, “The rotate command generates a new data encryption key and reencrypt all values with the new key,” followed by, “Use updatekeys if you want to add a key without rotating the data key.” For compromise sequencing it says, “This ensures that first the compromised key is removed from the list of keys that has access to the per-file data key, and only then rotates the data key.” These sentences support recipient synchronization versus data-key rotation and the documented compromise order.
- Freshness observation: normalized page footer says “Last modified May 15, 2026: Add page descriptions. (9b7b84e),” matching the date and commit recorded in S011.

No tools were installed or updated.