# S006 — live recapture (2026-10-21)

## Registered row and fetch

- Registry: `corpus/SOURCES.md:12`; S006 URL: `https://1password.com/blog/1password-credential-broker-public-preview`.
- In-row `Fetch sha256`: `39a869df8807696009d98bd6d0a86bc27524af65f94f235d37e6dd5a6e514c1f`.
- Fetched once into `/fast/scratch/kagi-r24/seats/RecapS006-2/s006-body.html` with this command (curl exit 0):

  ```sh
  curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o s006-body.html -w '%{url_effective} %{http_code}\n' 'https://1password.com/blog/1password-credential-broker-public-preview'
  ```

- Curl result: final URL `https://1password.com/blog/1password-credential-broker-public-preview`; HTTP `200`.
- Decoded response-body bytes: `190261` (`wc -c` and normalizer `bytes` agree).
- Raw SHA-256: `d6e2ea9eec883f7da1870a77e5d8e17492830859376e45e5aa3b504a88873838` (`sha256sum` and `rendered-text-v1.py digest` agree).
- Normalized-text-v1 SHA-256: `20b4fd86dada5f63406432238384aa475b0cf8cb3a8e4045bd021cae0691804f`; normalized bytes: `9530`.
- Command: `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest s006-body.html` (run from the scratch directory); output recorded both hashes and byte counts; exit `0`.
- Pin comparison: raw match **no**; normalized match **no**. The registry explicitly says original Fetch hashes have undocumented representation and a changed raw hash is not proof of semantic drift (`corpus/SOURCES.md:87-89`).

## Quote locations

Both commands used the committed `corpus/rendered-text-v1.py locate` on the fetched body and exited `0`:

| Row quote | Count | Nearest preceding heading in normalized text |
|---|---:|---|
| `unlike a service account token that carries standing access, the organization-wide integration key is an encryption key` | 1 | `How 1Password Credential Broker works` |
| `is in public preview` | 1 | `Try 1Password Credential Broker today` |

The first quote occurs within: “Additionally, unlike a service account token that carries standing access, the organization-wide integration key is an encryption key, meaning if it were ever leaked, an attacker still couldn't access your secrets.”

## Live-page scope/teaches assessment: PARTLY

The historical announcement still supports the integration-key-versus-standing-token distinction and its own preview announcement. It states: “1Password Credential Broker is in public preview, and available now for all 1Password EPM Business customers.” But its release scope is feature-specific: “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” Thus S006's key-custody teaching and dated announcement claim remain supported, while an unqualified/current reading of “public-preview status” is incomplete; the feature split and eligibility qualify it. This is consistent with S020 and the registry caveat that the dated announcement is not a live status oracle (`corpus/SOURCES.md:26,83-89`).
