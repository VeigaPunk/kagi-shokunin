# S015 live recapture

- Registry row: `corpus/SOURCES.md:21` (S015, historical in-row `Fetch sha256:` pin `a0a2b227a7a91b7af0033a9fc665d319776d2d03aa09341620f9abee2f195fd4`).
- Declared documentation fetch profile: `kagi-shokunin-round23/1.0 (documentation verification)`.
- Fetch command (exit 0):
  ```sh
  mkdir -p /fast/scratch/kagi-r24/seats/RecapS015-2 && curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24/seats/RecapS015-2/S015.body -w '%{url_effective} %{http_code}\n' 'https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/'
  ```
  Curl reported final URL `https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/` and HTTP `200`. The downloaded, content-decoded body is 55,824 bytes.
- Normalizer command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS015-2/S015.body` (exit 0; part of the compound command below). Output: `RENDERED_TEXT_V1: raw_sha256=4e3fdb7d2628f11584690f7eb856186283c688bad09ec8a77e509ab133edbf2f bytes=55824 normalized_sha256=2732189767e6663d9994b7d7f5d20cab6c4d5b28ede6f73c5f2cfb4707a2aab8 normalized_bytes=8724`.
- Pin comparison: **raw match: no**; **normalized match: no**. The in-row pin matches neither live digest.
- Quote locate command (compound command exit 1 because the locate result is not found):
  ```sh
  python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS015-2/S015.body && python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS015-2/S015.body "The JWT auth engine does not use Kubernetes' \`TokenReview\` API during authentication"
  ```
  The digest subcommand returned 0; locate returned 1 with `RENDERED_TEXT_V1_LOCATE: count=0`. The quote-side string retains literal Markdown backticks around `TokenReview`, whereas the fetched HTML uses a `<code>TokenReview</code>` element; v1 removes the HTML tags from the page but quote normalization only collapses whitespace. Thus the count-zero result is a formatting mismatch, not absence of the claim.
- Since count is zero, the closest live sentence grounding the teaches claim (24 words, verbatim) is under the nearest preceding heading **Kubernetes** (H2): “The JWT auth engine does not use Kubernetes' TokenReview API during authentication, and instead uses public key cryptography to verify the contents of JWTs.”
- Scope/teaches still holds: **yes**. The same note states: “This means tokens that have been revoked by Kubernetes will still be considered valid by OpenBao until their expiry time.” Together the sentences support that this JWT path bypasses TokenReview and does not immediately observe Kubernetes revocation.
- No tools installed or updated.
