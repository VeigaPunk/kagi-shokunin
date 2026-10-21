# S004 — live recapture (2026-10-21)

## Findings

- Registry row: `corpus/SOURCES.md:10`. Registered URL: `https://www.1password.dev/service-accounts/security`; declared teaches: Service Account vault permissions and token rotation/revocation are separate controls. The historical in-row `Fetch sha256` pin is `19bcf13eacd212b54db578ed7b1fdaa7341756ab73a6bd4f61d4b0012c7d2d60`.
- Re-opened URL/result: final URL `https://www.1password.dev/service-accounts/security`; HTTP `200`; curl exit `0`.
- Body saved at `/fast/scratch/kagi-r24/seats/RecapS004-2/S004.body`. `curl --compressed` supplied decoded body bytes to the renderer: **1,221,922 bytes**. Raw SHA-256: `beb67f2d0b8b4e77108766f134fb9bf21943331d9ab4d9bdbe083f655336b055`. Rendered-text-v1 normalized SHA-256: `ed6f87eb0ff199bba950554fe7cffae41a0f8b52e50b1571a7425f1c6e309c4a` (8,654 normalized bytes).
- Pin comparison: **raw match: no**; **normalized match: no**. The old pin matches neither observed digest; its representation is undocumented in the row.
- Both quoted spans locate once in normalized text. The closest preceding heading for `“you choose the vaults it can access and its level of access.”` is **Access control**. The closest preceding heading for `“You can rotate or revoke service account tokens.”` is **Token rotation and revocation**.
- Scope/teaches verdict: **yes**. The live page states: “When creating a service account, you choose the vaults it can access and its level of access.” It separately states: “You can rotate or revoke service account tokens.” Those exact sentences support the row's distinction between vault-access permissions and token lifecycle actions.

## Reproduction and source evidence

- `corpus/rendered-text-v1.py:10-34` defines v1 normalization on decoded HTTP-body bytes; `:90-112` defines `digest`/`locate` outputs and return codes.
- Fetch command (exit `0`; output was final URL and HTTP code):
  ```sh
  curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24/seats/RecapS004-2/S004.body -w '%{url_effective} %{http_code}\n' 'https://www.1password.dev/service-accounts/security'
  ```
- Digest command (exit `0`; emitted the raw hash, `bytes=1221922`, and normalized hash above):
  ```sh
  python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS004-2/S004.body
  ```
  Independent `wc -c` / `sha256sum` (exit `0`) returned `1221922` and the same raw hash.
- Locate commands (each exit `0`, each emitted `count=1`):
  ```sh
  python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS004-2/S004.body 'you choose the vaults it can access and its level of access.'
  python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS004-2/S004.body 'You can rotate or revoke service account tokens.'
  ```
- The normalized-text context probe in the isolated scratch clone (base `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`, with the named renderer copied in) exited `0`; it showed each quote immediately after the corresponding heading text above.
- LSP was unavailable: `read xd://lsp` returned `No such tool` (the mounted device list contained no LSP tool). No language-server semantic result is claimed.
- No tools were installed or updated.
