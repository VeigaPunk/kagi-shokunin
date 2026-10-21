# S003 live-source re-open

Checked 2026-10-21 against the registered row at `corpus/SOURCES.md:9` in `/home/vgpnk/Projects/shokunin/kagi-shokunin`. The row registers `https://www.1password.dev/connect/get-started`, teaches that Connect setup distinguishes deployment credentials from client API tokens, and has the historical in-row pin `7f6d3b49ac3019073c37360c4771ebad2bad43a0f87ce314eb94bb0e0debe7ff`.

## Fetch and digest

Fetched using the declared documentation profile:

```sh
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -w '%{url_effective} %{http_code}\n' 'https://www.1password.dev/connect/get-started' -o /fast/scratch/kagi-r24/seats/RecapS003-2/S003.body
```

Exit 0. `curl -w` reported final URL `https://www.1password.dev/connect/get-started` and HTTP status `200`. `--compressed` was used; the saved response body was the decoded body.

Ran the single committed normalizer (`corpus/rendered-text-v1.py:10-44,90-112`):

```sh
python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py digest /fast/scratch/kagi-r24/seats/RecapS003-2/S003.body
```

Exit 0; output: `raw_sha256=2e697420d1d63ed12a32e204501914a7861cbdff3dec432ee382510f306c00c5`, decoded body `bytes=1369709`, `normalized_sha256=915a222d374324128b3f00ee88484b2713b0e23f04a6e8f1233c4ed02fe3902d`, `normalized_bytes=11318`.

The row's pin matches neither the fetched raw digest nor the rendered-text-v1 normalized digest.

## Quote locations and live scope

Ran `rendered-text-v1.py locate` for both quoted spans in the S003 teaches cell. Both commands exited 0 and returned `count=1`:
```sh
python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS003-2/S003.body 'credentials necessary to deploy 1Password Connect Server'
# output: RENDERED_TEXT_V1_LOCATE: count=1; exit 0
python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py locate /fast/scratch/kagi-r24/seats/RecapS003-2/S003.body 'Create a new token for each application or service you use.'
# output: RENDERED_TEXT_V1_LOCATE: count=1; exit 0
```


- `credentials necessary to deploy 1Password Connect Server` — nearest preceding heading in normalized text: `Secrets Automation`.
- `Create a new token for each application or service you use.` — nearest preceding heading: `Step 3: Set up applications and services to get information from 1Password` (the normalized text has a leading U+200B before this heading).

**Scope/teaches: yes.** The live text says: “It contains the credentials necessary to deploy 1Password Connect Server.” It separately says: “The requests are authenticated with an access token. Create a new token for each application or service you use.” These exact sentences support the deployment-credentials versus per-application-token distinction. The first quote is now under the nearest `Secrets Automation` heading; the second is under Step 3.

Locator behavior and output format are declared at `corpus/rendered-text-v1.py:40-44,101-112`; the registered URL, teaching claim, quotes, and old pin are at `corpus/SOURCES.md:9`.
