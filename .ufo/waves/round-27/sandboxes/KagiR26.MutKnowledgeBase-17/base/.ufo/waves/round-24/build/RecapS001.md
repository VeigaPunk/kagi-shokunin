# S001 live re-open

## Observed

- Registry: `corpus/SOURCES.md:7`. S001 is **Load secrets into scripts**, URL `https://www.1password.dev/cli/secrets-scripts`; its teaches scope is “1Password CLI process-lifetime Environment-variable delivery.” Its quoted span is `provisioned for the duration of the process.` The in-row historical `Fetch sha256` pin is `9f9d7283c2659d23c9ede72d96a31690533678b28437b2b22f73b2b73370c439`.
- Fetch command (profile exactly as declared):
  ```sh
  curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' 'https://www.1password.dev/cli/secrets-scripts' -o /fast/scratch/kagi-r24/seats/RecapS001-2/S001.body -w '%{url_effective} %{http_code}\n'
  ```
  Exit: `0`. `curl -w` result: final URL `https://www.1password.dev/cli/secrets-scripts`, HTTP `200`. Saved response body: `/fast/scratch/kagi-r24/seats/RecapS001-2/S001.body`.
- Digest command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS001-2/S001.body` — exit `0`; output: `raw_sha256=e72ab5f3f85e238bc109a1737161eec8425a016f003b7c84be09990d62cf4e0b bytes=1228087 normalized_sha256=a8be89d90b8c673914b539a7aa9d12d3c63f9c9283865ba08ddb6f2d049ec580 normalized_bytes=7116`. The `bytes` count is the curl-decompressed HTTP body consumed by the normalizer.
- Pin comparison: **raw match: no**; **normalized match: no**.
- Locator command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS001-2/S001.body 'provisioned for the duration of the process.'` — exit `0`; output `RENDERED_TEXT_V1_LOCATE: count=1`.
- In the normalized page, the first hit begins at character offset `2929`. The nearest preceding heading text is `\u200b Use op run to pass environment variables from a 1Password Environment` (leading U+200B ZERO WIDTH SPACE; heading begins at normalized-text offset `2605`). The live sentence containing the hit is: “1Password CLI runs the application or script in a subprocess with the environment variables stored in your 1Password Environment provisioned for the duration of the process.”

## Assessment

**Yes — the row's scope/teaches still holds on the live page.** The located sentence explicitly says the environment variables are provisioned for the subprocess's process duration, supporting S001's process-lifetime delivery claim. The historical pin matches neither current representation; that digest mismatch alone does not establish semantic drift. The normalizer's declared input and rules are at `corpus/rendered-text-v1.py:10-49`; digest/locate behavior is at `:90-112`.

## Method and limits

- S001 was located with literal text search and read directly from `corpus/SOURCES.md:7`; grep was used only to locate the row, not as semantic proof. `read xd://lsp` returned `No such tool: xd://lsp` (no LSP device mounted); this Markdown registry row has no code definitions/callers to trace.
- The old row does not declare whether its historical pin was calculated over raw or normalized content. Current live fetch and quote were re-observed; the old representation cannot be reconstructed from that row.
- No tools were installed or updated.