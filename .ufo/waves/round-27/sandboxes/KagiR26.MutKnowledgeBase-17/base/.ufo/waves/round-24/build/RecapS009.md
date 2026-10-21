# S009 live re-open

## Registry row and fetch

- Source row: `corpus/SOURCES.md:15`, “Age on SOPS,” registered URL `https://getsops.io/docs/usage/identities/age/`; scope: age-recipient configuration and private identity lookup, plus recipient updates. The row's historical `Fetch sha256` is `a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76`.
- Exact fetch command (exit 0):
  ```sh
  curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -w '\n%{url_effective} %{http_code}\n' 'https://getsops.io/docs/usage/identities/age/' -o /fast/scratch/kagi-r24/seats/RecapS009-2/S009.body
  ```
- `curl -w` result: `https://getsops.io/docs/usage/identities/age/ 200` (HTTP 200; final URL unchanged). Captured body: `/fast/scratch/kagi-r24/seats/RecapS009-2/S009.body`.
- `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS009-2/S009.body` (exit 0): decoded body bytes **29,301**; raw SHA-256 `a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76`; normalized SHA-256 `189d5ba9145e71f4a41dae10a42b9176fa660c58f3df5cb2774a145d11728d95` (normalized bytes: 3,570).
- Pin comparison: **raw match: yes**; **normalized match: no**. The observed `Fetch sha256` matches this fetched body byte-for-byte hash; the registry's legacy pin does not equal the rendered-text-v1 hash.

## Quote, heading, and scope

- Exact row-quote check (exit 1):
  ```sh
  python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS009-2/S009.body 'It is also possible to use `updatekeys`, when adding or removing age recipients.'
  ```
  Result: `RENDERED_TEXT_V1_LOCATE: count=0`.
- The closest live sentence, verbatim (13 words), is: “It is also possible to use `updatekeys`, when adding or removing age recipients.” Its heading is **Encrypting using age** (nearest preceding heading in normalized text). The page HTML has that heading at `S009.body:18` and the sentence at `S009.body:35`.
- Normalized-text cross-check (exit 0): `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS009-2/S009.body 'It is also possible to use updatekeys , when adding or removing age recipients.'` gives count 1; nearest preceding normalized heading: `Encrypting using age`. The count-0 row quote is a representation mismatch, not missing live text: source HTML marks `updatekeys` as `<code>` (`S009.body:35`); rendered-text-v1 removes tags by replacing them with spaces (`corpus/rendered-text-v1.py:14-20`), yielding a space before the comma, while the row quote retains Markdown backticks.
- **Scope/teaches: yes.** In addition to the update sentence above, the live page says: “You can encrypt a file for one or more age recipients (comma separated) using the `--age` option or the `SOPS_AGE_RECIPIENTS` environment variable:” (`S009.body:20-21`), and “When decrypting a file with the corresponding identity, SOPS will look for a text file name `keys.txt` located in a `sops` subdirectory of your user configuration directory.” (`S009.body:23-25`). These support recipient configuration, identity lookup, and recipient updates. The page footer still reports last modified May 15, 2026, commit `9b7b84e297bdabc9c78e571c1e6db43dcd69454a` (`S009.body:43`), consistent with the row's locator metadata.
