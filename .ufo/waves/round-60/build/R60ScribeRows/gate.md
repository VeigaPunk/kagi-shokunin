## Gate

Registry effect: `corpus/SOURCES.md` moves 122 → 124 data rows (S123, S124; both `docs`, tier A,
`mined`), and `corpus/source-fetches.tsv` gains 2 `S123`/`S124` rows —
`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` reads 122 at the claim BASE
and 124 once both rows are appended; the append adds exactly two `S` lines, so
`git diff a677c78e -- corpus/source-fetches.tsv | grep -c '^+S'` reads 2 over the appended tree.
Neither id carried a registry row before (`grep -c '| S123 |' corpus/SOURCES.md` = 0, same for
S124). Both rows are appended; no earlier row's cell changes, so the append-only rule (contract v1
§Rules 2) is untouched. Over a copy of `corpus/SOURCES.md` with the two rows appended the frozen
census reads 124 rows, 0 malformed (`NF!=13`), no duplicate id, no enum or tier-inflation violation,
and every `source-fetches.tsv` row has 16 fields; the census's missing-`used-by` check reports
`corpus/knowledge/openbao-approle-secret-id-custody.md` missing until the entry lands, so the entry
is committed with or before these rows.

Capture provenance, both pages, 2026-11-07:

```
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36'
curl -fsSL --compressed -A "$UA" -D <sid>.rawheaders -o <sid>.body \
     -w '%{http_code} %{url_effective} %{size_download}\n' "<url>"
```

The decoded body is the digest/byte domain (`decoded-http-body-v1`, Content-Encoding removed by
curl); `curl %{size_download}` on the wire was 12566 B (S123) and 14329 B (S124) gzip-compressed and
is not the recorded byte count. Neither response carried a `Set-Cookie` or `Cookie` header
(`grep -in cookie` over both raw header files = 0 matches), so nothing was redacted; no
`secret_id`, token or request body appears in any receipt. Quote location, digests and byte counts:
`.ufo/waves/round-60/build/R60ScribeRows/locate-receipt.txt` (all ten quotes read `count=1` under
`python3 corpus/rendered-text-v1.py locate`).

- **Admit S123** — https://openbao.org/docs/auth/approle/, opened 2026-11-07 with a desktop browser
  user agent (HTTP 200, final URL unchanged, decoded body 78543 B, sha256
  `d16f639a0b0fff901707f56ad1b916f70665e7e0675197a6a40d6473e50c0187`,
  `.ufo/waves/round-60/capture/S123.body`; rendered-text-v1 normalized sha256
  `4230771520d9749e67efe7dd42d57e30ebfbfd105206f142227d6023003b687a`). Located quotes (each
  `count=1`, same receipt): “SecretID is a credential that is required by default for any login”
  (§Credentials/Constraints, 12 words) — T1's default binding; “requiring a SecretID can be disabled
  via an AppRole's bind_secret_id parameter” (§Credentials/Constraints, 11 words) — T1's
  `bind_secret_id=false` leg; “secret_id_bound_cidrs will only allow logins coming from IP addresses
  belonging to configured CIDR blocks” (§Further constraints, 14 words) — T5; “Similarly to tokens,
  SecretIDs have properties like usage-limit, TTLs and expirations.” (§Credentials/Constraints, 11
  words) — the existence claim behind T2 and T3, not their semantics. Tier A for OpenBao 2.7.x
  AppRole custody mechanics; the page is the vendor's own concept text and states the version
  selector as `Version 2.7.x` (3 occurrences in the captured body).
- **Admit S124** — https://openbao.org/docs/api/auth/approle/, opened 2026-11-07 with a desktop
  browser user agent (HTTP 200, final URL unchanged, decoded body 145203 B, sha256
  `e663c1d0f956edea896db404bba7e92c7f248f74e98857a717ab063a7aae7207`,
  `.ufo/waves/round-60/capture/S124.body`; rendered-text-v1 normalized sha256
  `966641e895fb723695d66fd870f39731b43bb47b08dec2ed2601da1443f65935`). Located quotes (each
  `count=1`, same receipt): “role_id is always required; if bind_secret_id is enabled (the default)
  on the AppRole, secret_id is required too.” (§Login with AppRole, 17 words) — T1's observable;
  “Number of times any particular SecretID can be used to fetch a token from this AppRole”
  (§Create/Update AppRole, 16 words) — T2; “after which by default any SecretID expires”
  (§Create/Update AppRole, 8 words) — T3; “Reads out the properties of a SecretID. Method Path POST
  /auth/approle/role/:role_name/secret-id-accessor/lookup” (§Read AppRole secret ID accessor, 11
  words) and “Destroy an AppRole secret ID by its accessor.” (§Destroy AppRole Secret ID Accessor, 8
  words) — T4's two endpoints; “specifies blocks of IP addresses which can perform the login
  operation” (§Create/Update AppRole, 11 words) — T5. Tier A; it is the documented endpoint set the
  trial calls, and the page states `Version 2.7.x` (3 occurrences in the captured body).
- **Reject: the AppRole concepts page as the anchor for the accessor custody mechanic** (T4). The
  captured S123 body carries 0 occurrences of `secret-id-accessor`
  (`grep -c -F 'secret-id-accessor' .ufo/waves/round-60/capture/S123.body` = 0) and no
  `secret_id_accessor` path or endpoint: the token appears only as a value in the secret-id CLI
  output and in the response example (“The response will look like: { "data" : {
  "secret_id_accessor" : …”), never with a lookup or destroy path. A row claiming the accessor
  handle from this page would assert a mechanic the page does not state, so the T4 anchor is S124
  only and S123's `scope` stops at the RoleID/SecretID split, the binding switch, the
  usage-limit/TTL properties and the CIDR constraint. Flip: a concepts-page section that names
  `secret-id-accessor/lookup` or `secret-id-accessor/destroy` and states that the accessor addresses
  a SecretID without revealing it.
- **Reject: both pages as the anchor for the refused-login shape the trial observes** (T1, T2, T3,
  T5). The trial's falsifiers read a named refusal on a login missing, spent, expired or
  CIDR-mismatched `secret_id`; neither captured page states that refusal. S123's only
  `permission denied` is the user-lockout paragraph (“returning immediately with a permission denied
  error”, §User lockout), which is a lockout behaviour, not a credential check; S124 has 0
  occurrences of `permission denied` and 0 of `error`, and its §Login with AppRole states the
  required fields and a success response only. The refusal strings are therefore the trial's own
  measurement, not a documented claim, and no row's `teaches` cites them. Flip: a page section that
  states the error string or HTTP status returned when `secret_id` is absent, spent, expired or
  outside `secret_id_bound_cidrs`.
- **No third page this round.** The scout opened exactly the two pages above; no page it found
  anchors zero tested mechanics, so the assignment's “page that anchors no tested mechanic”
  rejection slot has no candidate and is recorded as empty rather than filled with an invented page.
  Flip: a third page opened this round that anchors none of T1–T5 is a rejection with its own
  located-count evidence.
