# S013 legacy recapture (2026-10-21)

Source row: `corpus/SOURCES.md:19` registers `https://developer.hashicorp.com/vault/docs/concepts/lease`, teaches Vault's dynamic-secret/service-token lease lifecycle and a static KV exception, and has the historical in-row pin `ae321512d37ae70bc19e7b8698217ce8af0d3000bb76fe04039870bff25b8bf5`.

## Capture

Fetched with the declared documentation profile (curl exit 0):

```sh
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o /fast/scratch/kagi-r24/seats/RecapS013-2/S013.body -w '%{url_effective} %{http_code}\n' 'https://developer.hashicorp.com/vault/docs/concepts/lease'
```

`curl -w` result: final URL `https://developer.hashicorp.com/vault/docs/concepts/lease`; HTTP `200`. The saved, content-decoded response body is `261632` bytes. `sha256sum /fast/scratch/kagi-r24/seats/RecapS013-2/S013.body` (exit 0): `ac99140f11acbae6debf592f08fffaaadecb67d6b406a4044a3254e30d4dcdeb`.

Ran `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS013-2/S013.body` (exit 0; normalizer implementation: `corpus/rendered-text-v1.py:56-70,90-98`):

```text
RENDERED_TEXT_V1: raw_sha256=ac99140f11acbae6debf592f08fffaaadecb67d6b406a4044a3254e30d4dcdeb bytes=261632 normalized_sha256=0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76 normalized_bytes=7354
```

Against the row's in-row `Fetch sha256` pin: raw match **no**; normalized match **no**. The old pin matches neither current representation.

## Quote and live claim

Ran `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS013-2/S013.body 'All dynamic secrets in Vault are required to have a lease.'` (exit 0): `RENDERED_TEXT_V1_LOCATE: count=1`. In the normalized text, the nearest preceding heading is H1 **“Lease, renew, and revoke”**.

Scope/teaches still holds: **yes**. The live page's normalized sentences state: “With every dynamic secret and service type authentication token, Vault creates a lease : metadata containing information such as a time duration, renewability, and more.” “All dynamic secrets in Vault are required to have a lease.” “The Key Value Backend which stores arbitrary secrets does not issue leases although it will sometimes return a lease duration; see the documentation for more information.” The page uses “Key Value Backend” rather than the row's shorthand “static KV.”

The old S013 anchor/locator wording about no displayed version/date is separate from this scope/teaches result and is superseded by `corpus/SOURCES.md:29,106-108`; this recapture does not revive it.
