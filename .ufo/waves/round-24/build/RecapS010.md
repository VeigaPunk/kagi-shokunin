# S010 live re-open

## Registry row and fetch

- Registry source: `corpus/SOURCES.md:16`, “Key groups on SOPS,” URL `https://getsops.io/docs/usage/identities/key-groups/`; scope is Shamir key-group fragments and a configurable decryption threshold. The row's historical `Fetch sha256` pin is `fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e`.
- Exact fetch command (exit 0):
  ```sh
  cd /fast/scratch/kagi-r24/seats/RecapS010-2 && curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o S010-body.html -w '%{url_effective} %{http_code}\n' 'https://getsops.io/docs/usage/identities/key-groups/'; echo "curl_exit=$?"
  ```
- `curl -w` result: final URL `https://getsops.io/docs/usage/identities/key-groups/`, HTTP 200; final URL unchanged. Captured decoded response body: `/fast/scratch/kagi-r24/seats/RecapS010-2/S010-body.html`.
- `wc -c /fast/scratch/kagi-r24/seats/RecapS010-2/S010-body.html && sha256sum /fast/scratch/kagi-r24/seats/RecapS010-2/S010-body.html` (exit 0): **36,366 decoded bytes**; raw SHA-256 `fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e`.
- `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS010-2/S010-body.html` (exit 0; implementation/output contract: `corpus/rendered-text-v1.py:66-103`): raw SHA-256 `fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e`, bytes `36366`, normalized SHA-256 `d1ef84f175c6b77902ac9804b1cb70d7915d378232fa63e5c54fd4a21b50a9a4`, normalized bytes `4138`.
- Pin comparison: **raw match: yes**; **normalized match: no**. The legacy in-row pin matches the fetched decoded body hash, not its rendered-text-v1 digest.

## Quote, heading, and scope

- Exact row-quote check (exit 0):
  ```sh
  python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS010-2/S010-body.html 'keys from multiple groups are required to decrypt a file.'
  ```
  Result: `RENDERED_TEXT_V1_LOCATE: count=1` (`corpus/rendered-text-v1.py:106-117`). The nearest preceding heading text in normalized text is **Key groups**; the page's `Key groups` heading is in `S010-body.html:18`, and the unique quote occurs at `S010-body.html:22-23`. Heading lookup used the normalizer's text rules at `corpus/rendered-text-v1.py:66-71`.
- The exact live sentence containing the quote is: “When using key groups in SOPS, data keys are split into parts such that keys from multiple groups are required to decrypt a file.” (`S010-body.html:22-23`).
- The live page also states: “SOPS uses Shamir's Secret Sharing to split the data key such that each key group has a fragment, each key in the key group can decrypt that fragment, and a configurable number of fragments (threshold) are needed to decrypt and piece together the complete data key.” (`S010-body.html:23-27`). It further says the default threshold is the number of key groups (`S010-body.html:32-35`) and gives a `shamir_threshold: 2` example requiring keys from two of three groups (`S010-body.html:70-73,96-98`).
- **Scope/teaches: yes.** The live page supports both the Shamir fragments and configurable threshold claim; the cited threshold is expressed as a number of fragments, with one fragment per key group. Its footer still identifies the 2026-05-15 last modification and docs commit `9b7b84e297bdabc9c78e571c1e6db43dcd69454a` (`S010-body.html:100`), consistent with the row locator.

No tools were installed or updated.