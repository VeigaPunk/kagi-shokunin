# C3 capture notes — declared profile curl-fsSL-compressed-v1, decoded-http-body-v1
# capture date: 2026-11-03 (this lane opening; campaign dates 2026-10-23 are not reused)

## S053
url: https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md
http: 200  final: https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md
raw sha256: 65e87e68f4a16aefa1f1fba55b2e7a9b9bc8716393b7ddb013fc7c7bef4e4bc1
bytes: 29328
revision (ls-remote refs/heads/master): 5f6ec56cfa6f8c67648d863582c7ae2f206d5c1c
normalization: raw-literal-v1  normalized sha256: -
quote (16 words, located): is a tool for **detecting** secrets like passwords, API keys, and tokens in git repos, files
location: README intro paragraph (line 35)

## S054
url: https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md
http: 200  final: https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md
raw sha256: 7cf6efb50ab892347b1fa3bee77592603b371b066b6b1659fcc2c56a62e6eff7
bytes: 38524
revision (ls-remote refs/heads/main): 240ccdd9061905ed3d7cbe05c01565f0ccf0cd0a
normalization: raw-literal-v1  normalized sha256: -
quote (13 words, located): can also log in to confirm if that secret is live or not
location: README Validation section

## S055
url: https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md
http: 200  final: https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md
raw sha256: f61c3993fd48dfb973652b9676697f4d37404fad9f30748c2003127eb81a73b1
bytes: 13252
revision (ls-remote refs/heads/main): 6cd808f299a81b19fdbd196b04a64e63565c8c5c
normalization: raw-literal-v1  normalized sha256: -
quote (9 words, located): Scans detect secrets without credential provider requests by default
location: README Usage, opening line

## S056
url: https://api.github.com/search/repositories?q=betterleaks&per_page=10
http: 200  final: https://api.github.com/search/repositories?q=betterleaks&per_page=10
raw sha256: b7e19953ecde88d0ea2b9b248d9424fd817fa8cf9cde4ba6050d762d281ac21c
bytes: 64526
revision (ls-remote n/a): -
normalization: raw-literal-v1  normalized sha256: -
quote (2 words, located): "full_name": "betterleaks/betterleaks"
location: response items[0] object

## S057
url: https://trufflesecurity.com/docs/verification-caching
http: 200  final: https://trufflesecurity.com/docs/verification-caching
raw sha256: 0beb84fec97fa0ac2cb2c8c8b1cb0e1616ea7b8485b6848da1771d109c9d44d1
bytes: 102006
revision (ls-remote n/a): -
normalization: rendered-text-v1  normalized sha256: 5e697b14d10802cbb06d2c2eba91aaca206f10827360cc04206c21e8b397bc9c
quote (7 words, located): Each cache entry expires after three hours
location: section Verification caching, cache-expiry paragraph

## S058
url: https://trufflesecurity.com/docs/how-we-handle-your-data
http: 200  final: https://trufflesecurity.com/docs/how-we-handle-your-data
raw sha256: 2c85abe9e3f842a703ea0a8671230f63ed223233b3590c3c7a3da3f0151b5914
bytes: 161061
revision (ls-remote n/a): -
normalization: rendered-text-v1  normalized sha256: b7c2613aec83674b6a34945264f5c17db6cb055a861b7f0906727ee670f130c8
quote (8 words, located): Credentials are verified using safe, read-only API calls
location: Verification Safety panel, What We Do not Do

## S059
url: https://trufflesecurity.com/docs/reverify-secrets
http: 200  final: https://trufflesecurity.com/docs/reverify-secrets
raw sha256: b4790c43398da9db6aa07b2dd883ecbad33e2e593c8f5cd4a30a90328eae3e0a
bytes: 99172
revision (ls-remote n/a): -
normalization: rendered-text-v1  normalized sha256: df607e982176c63e8118f491aeddebb7eeaa527fe942dd752a4223331ce2fb00
quote (6 words, located): Secret reverification is currently only supported
location: section Reverify secrets, closing scope sentence

## S060
url: https://trufflesecurity.com/docs/notify-results
http: 200  final: https://trufflesecurity.com/docs/notify-results
raw sha256: 8c0a977c75286c178ce3cc6c296fa46cc70ac676f329b926c5e387e0ee9e4752
bytes: 144104
revision (ls-remote n/a): -
normalization: rendered-text-v1  normalized sha256: e4a550c4a9a6e25f1fb7bdc69468b4b2f1e8215f7b769c3f5dbbfb1f2fadd822
quote (1 words, located): sendUnverified
location: section Notify results, configuration snippet field sendUnverified

