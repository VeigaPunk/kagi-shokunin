# Round-60 AppRole capture notes (S123, S124)

Seat: `R60ScoutApprole` (scout, wave-1 of round 60, attempt 1). Lane: `kagi-shokunin`.
Scope: open the two AppRole documentation sources this round declares, live, and record the
located-quote evidence the registry rows and the lesson Gate need. No registry, lesson,
SCORECARD or plan file is edited by this seat.

## 0. Fetch record (both sources)

Common request profile — one desktop-browser user agent, `curl -fsSL --compressed`:

```
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36'
curl -fsSL --compressed -A "$UA" -D <sid>.rawheaders -o <sid>.body \
     -w '%{http_code} %{url_effective} %{size_download}\n' "<url>"
```

The `-w` template above is the fetch command for each source, run from the seat scratch
`/fast/scratch/hyaku/kagi-r60/R60ScoutApprole/`. `--compressed` makes curl remove
`Content-Encoding: gzip`, so the saved `.body` is the **decoded** HTTP body
(lane representation `decoded-http-body-v1`).

| id | url | http_status | final_url (`%{url_effective}`) | wire bytes (`%{size_download}`, gzip) | decoded body bytes | sha256 of decoded body | access date |
|---|---|---|---|---|---|---|---|
| S123 | `https://openbao.org/docs/auth/approle/` | `200` | `https://openbao.org/docs/auth/approle/` (unchanged; no redirect) | 12566 | 78543 | `d16f639a0b0fff901707f56ad1b916f70665e7e0675197a6a40d6473e50c0187` | 2026-11-07 (server `date:` header `Sat, 07 Nov 2026 18:10:24 GMT`) |
| S124 | `https://openbao.org/docs/api/auth/approle/` | `200` | `https://openbao.org/docs/api/auth/approle/` (unchanged; no redirect) | 14329 | 145203 | `e663c1d0f956edea896db404bba7e92c7f248f74e98857a717ab063a7aae7207` | 2026-11-07 (server `date:` header `Sat, 07 Nov 2026 18:10:24 GMT`) |

Bodies live at `.ufo/waves/round-60/capture/S123.body` and
`.ufo/waves/round-60/capture/S124.body`.

Digest/byte-count reproduction (run from the lane root):

```
sha256sum .ufo/waves/round-60/capture/S123.body .ufo/waves/round-60/capture/S124.body
wc -c    .ufo/waves/round-60/capture/S123.body .ufo/waves/round-60/capture/S124.body
```

```
d16f639a0b0fff901707f56ad1b916f70665e7e0675197a6a40d6473e50c0187  .ufo/waves/round-60/capture/S123.body
e663c1d0f956edea896db404bba7e92c7f248f74e98857a717ab063a7aae7207  .ufo/waves/round-60/capture/S124.body
 78543 .ufo/waves/round-60/capture/S123.body
145203 .ufo/waves/round-60/capture/S124.body
```

**Secret hygiene (QM72).** Neither response carries a `set-cookie:` or `cookie:` header
(`grep -in cookie` over both raw header files ⇒ 0 matches, exit 1), so no cookie value was
removed; nothing in this file or in the captured bodies is a cookie, session id or
credential. The per-request correlation ids the origin sends (`x-github-request-id`,
`x-fastly-request-id`) are server-issued and are deliberately not copied into this file.

**Pages opened.** Exactly these two. No third URL was fetched this round.

**Doc version.** Both pages carry `docs-version-2.7.x` in their `<html class=…>` attribute
and the S124 sidebar shows `Version: Version 2.7.x`, matching the plan's "OpenBao docs
2.7.x".

### How the quotes below resolve

Two locator families, both resolved **against the captured body bytes**:

* **raw-literal** — the quoted phrase is a literal byte substring of the `.body` file.
  Resolve with `grep -c -F '<phrase>' <body>`; the byte offset and line number are given.
* **rendered-v1** — the quoted phrase is prose and is resolved with the lane's own
  committed normalizer `corpus/rendered-text-v1.py locate <body> '<phrase>'`
  (which reads only the named file; no network, no writes). Every such quote additionally
  carries a **raw-literal anchor** that *is* a byte substring of the same body, with its
  byte offset and line, so the quote's position in the captured bytes is verifiable
  without normalizing.

Quote length: every quote below is at most 25 words (the lane's `source-fetches.tsv`
quote-cell bound).

---

## 1. S123 — `https://openbao.org/docs/auth/approle/` (AppRole auth method, concept page)

Body: `.ufo/waves/round-60/capture/S123.body`, 78543 B, sha256
`d16f639a0b0fff901707f56ad1b916f70665e7e0675197a6a40d6473e50c0187`.

Section headings on this page: `Authentication` (› `Via the CLI`, `Via the API`),
`Configuration` (› `Via the CLI`, `Via the API`), `Credentials/Constraints` (› `RoleID`,
`SecretID`, `Pull and push SecretID modes`, `Further constraints`), `User lockout`,
`API`, `Code example`.

### 1.1 M1 — `bind_secret_id` (default and meaning)

> "The bind_secret_id constraint requires secret_id to be presented at the login endpoint."
> — §Further constraints (12 words)

Resolve:

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S123.body 'The bind_secret_id constraint requires secret_id to be presented at the login endpoint.'
grep -c -F '<code>bind_secret_id</code> constraint requires' .ufo/waves/round-60/capture/S123.body
```

```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `<code>bind_secret_id</code> constraint requires` at **byte 44813, line 119**
of `S123.body`.

Second, independent statement of the same mechanic on the same page, §SecretID:

> "requiring a SecretID can be disabled via an AppRole's bind_secret_id parameter, allowing machines with only knowledge of the RoleID"
> — §SecretID (19 words)

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S123.body 'requiring a SecretID can be disabled via an AppRole'"'"'s bind_secret_id parameter, allowing machines with only knowledge of the RoleID'
```

```
RENDERED_TEXT_V1_LOCATE: count=1
```

Raw anchor `requiring a SecretID can be disabled via an AppRole's` at **byte 42555, line 96**
of `S123.body` (`grep -c -F` ⇒ 1).

**What this page does *not* state:** the literal default value of `bind_secret_id` (`true`).
S123 says the SecretID "is required by default for any login" and that the requirement "can
be disabled", but it never writes the token `bind_secret_id=true`. The explicit default
`(bool: true)` appears only on S124 (§2.1). **NOT STATED on S123.**

### 1.2 M2 — `secret_id_num_uses`

S123 mentions `secret_id_num_uses` only as a CLI example argument, never as prose:

* `secret_id_num_uses=40` — §Configuration › Via the CLI, role-creation example
  (raw anchor at **byte 30302, line 44**; `grep -c -F 'secret_id_num_uses=40'` ⇒ 1);
* `secret_id_num_uses      40` — §Configuration › Via the CLI, `bao write -f
  auth/approle/role/my-role/secret-id` output (raw anchor at **byte 32844, line 58**).

**Meaning / default / bound of `secret_id_num_uses`: NOT STATED on S123.** No sentence on
this page states what the number counts, what the default is, or what an exhausted
SecretID does. The prose form of that mechanic is on S124 (§2.2). S123 does say, generically:

> "Similarly to tokens, SecretIDs have properties like usage-limit, TTLs and expirations."
> — §Pull and push SecretID modes (11 words)

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S123.body 'Similarly to tokens, SecretIDs have properties like usage-limit, TTLs and expirations.'
```

```
RENDERED_TEXT_V1_LOCATE: count=1
```

Raw anchor `mode). Similarly to` at **byte 42947, line 100** of `S123.body`.

### 1.3 M3 — `secret_id_ttl`

Same shape as M2 on this page: `secret_id_ttl` appears only inside CLI example output, as

* `secret_id_ttl=10m` — §Configuration › Via the CLI, role-creation example
  (raw anchor at **byte 29870, line 44**; `grep -c -F 'secret_id_ttl=10m'` ⇒ 1);
* `secret_id_ttl           10m` — §Configuration › Via the CLI, `secret-id` generation output
  (raw anchor at **byte 32731, line 58**).

**Meaning / default / expiry semantics of `secret_id_ttl`: NOT STATED on S123.** The prose
form of that mechanic is on S124 (§2.3). The generic sentence quoted in M2 above ("usage-limit,
TTLs and expirations") is the closest prose this page carries.

### 1.4 M4 — secret-id-accessor lookup and destroy

**NOT STATED on S123.** `grep -c -F 'secret-id-accessor' .ufo/waves/round-60/capture/S123.body`
⇒ **0**. The token `secret_id_accessor` occurs twice, and neither occurrence is a lookup or
a destroy:

* line 58, byte 32585 — the CLI output field of the `secret-id` generation example:

```
secret_id_accessor      c454f7e5-996e-7230-6074-6ef26b7bcf86
```

* line 81, byte 39384 — the `"secret_id_accessor"` key of the §Configuration › Via the API
  sample response for `POST /v1/auth/approle/role/my-role/secret-id`.

The concept page never names a lookup path, a destroy path, or any accessor lookup/destroy
semantics. The whole mechanic is on S124 (§2.4).

### 1.5 M5 — `secret_id_bound_cidrs`

> "secret_id_bound_cidrs will only allow logins coming from IP addresses belonging to configured CIDR blocks on the AppRole."
> — §Further constraints (17 words)

Resolve:

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S123.body 'secret_id_bound_cidrs will only allow logins coming from IP addresses belonging to configured CIDR blocks on the AppRole.'
grep -c -F '<code>secret_id_bound_cidrs</code> will only allow logins coming from IP addresses' .ufo/waves/round-60/capture/S123.body
```

```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `<code>secret_id_bound_cidrs</code> will only allow logins coming from IP addresses`
at **byte 45127, line 123** of `S123.body`.

### 1.6 Login request body field names — `auth/approle/login`

The `auth/approle/login` request body field names are **role_id** and **secret_id**. On this
page they appear as: the CLI form `role_id=… secret_id=…` (§Authentication › Via the CLI,
byte 20938 / 21074, line 22) and the API example body, quoted verbatim as a raw literal:

> `--data '{"role_id":"988a9df-...","secret_id":"37b74931..."}'`
> — §Authentication › Via the API (1 token; the field-name pair is `role_id` and `secret_id`)

```
grep -c -F -- '--data '"'"'{"role_id":"988a9df-...","secret_id":"37b74931..."}'"'"'' .ufo/waves/round-60/capture/S123.body
```

```
1
```

Raw literal at **byte 23100, line 26** of `S123.body`. This page also states that the
RoleID "is a required argument (via `role_id`) at all times" (§RoleID) and that "SecretID is
a credential that is required by default for any login (via `secret_id`)" (§SecretID).

### 1.7 Refused login — exact documented text / HTTP shape

**The HTTP shape of a refused login is NOT STATED on S123.** The page documents no HTTP
status code for a failed `auth/approle/login` (`grep -cE '\b4[0-9][0-9]\b'` ⇒ 0), no error
body, and no error string specific to a refused AppRole login (`grep -c '"errors"'` ⇒ 0,
`grep -c 'errors'` ⇒ 0).

The only refusal-shaped sentence on the page is in §User lockout, and it describes the
*lockout* path (repeated bad credentials), not the ordinary "wrong secret_id" refusal:

> "instead returning immediately\nwith a permission denied error."
> — §User lockout (8 words; raw literal including the source line break)

```
python3 - <<'EOF'
b = open(".ufo/waves/round-60/capture/S123.body", encoding="utf-8").read()
q = "instead returning immediately\nwith a permission denied error."
print("count=%d byte=%d line=%d" % (b.count(q), b.find(q), b.count("\n", 0, b.find(q)) + 1))
EOF
grep -c -F 'with a permission denied error.' .ufo/waves/round-60/capture/S123.body
```

```
count=1 byte=45623 line=127
1
```

Raw literal at **byte 45623, line 127** of `S123.body` (the phrase itself, `permission
denied error`, is at byte 45660, line 128).

**Summary for this page:** the refusal *text* the page contains is the phrase
`permission denied error` (in the lockout context). The refusal *HTTP status* and the
refusal *error body* are **NOT STATED on S123**.

---

## 2. S124 — `https://openbao.org/docs/api/auth/approle/` (AppRole auth method, API)

Body: `.ufo/waves/round-60/capture/S124.body`, 145203 B, sha256
`e663c1d0f956edea896db404bba7e92c7f248f74e98857a717ab063a7aae7207`.

Section headings on this page: `List roles`, `Create/Update AppRole`, `Read AppRole`,
`Delete AppRole`, `Read AppRole role ID`, `Update AppRole role ID`, `Generate new secret ID`,
`List secret ID accessors`, `Read AppRole secret ID`, `Destroy AppRole Secret ID`,
`Read AppRole secret ID accessor`, `Destroy AppRole Secret ID Accessor`,
`Create custom AppRole secret ID`, `Login with AppRole`,
`Read, update, or delete AppRole properties`, `Tidy tokens`.

### 2.1 M1 — `bind_secret_id` (default and meaning)

> "bind_secret_id (bool: true) - Require secret_id to be presented when logging in using this AppRole."
> — §Create/Update AppRole › Parameters (15 words)

Resolve:

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S124.body 'bind_secret_id (bool: true) - Require secret_id to be presented when logging in using this AppRole.'
grep -c -F '<code>bind_secret_id</code> <code>(bool: true)</code> - Require' .ufo/waves/round-60/capture/S124.body
```

```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `<code>bind_secret_id</code> <code>(bool: true)</code> - Require` at **byte 22728,
line 39** of `S124.body`. **The default is `true`** — that is the documented default, and it
is the only place the default is written.

Independent confirmation of the same default at the login endpoint:

> "role_id is always required; if bind_secret_id is enabled (the default) on the AppRole, secret_id is required too."
> — §Login with AppRole (17 words)

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S124.body 'role_id is always required; if bind_secret_id is enabled (the default) on the AppRole, secret_id is required too.'
grep -c -F 'if <code>bind_secret_id</code> is enabled (the default) on the AppRole,' .ufo/waves/round-60/capture/S124.body
```

```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `if <code>bind_secret_id</code> is enabled (the default) on the AppRole,` at
**byte 117685, line 293** of `S124.body`.

### 2.2 M2 — `secret_id_num_uses`

> "secret_id_num_uses (integer: 0) - Number of times any particular SecretID can be used to fetch a token"
> — §Create/Update AppRole › Parameters (17 words)

Resolve:

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S124.body 'secret_id_num_uses (integer: 0) - Number of times any particular SecretID can be used to fetch a token'
grep -c -F '<code>secret_id_num_uses</code> <code>(integer: 0)</code> - Number of times any particular SecretID' .ufo/waves/round-60/capture/S124.body
```

```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `<code>secret_id_num_uses</code> <code>(integer: 0)</code> - Number of times any particular SecretID`
at **byte 23092, line 44** of `S124.body`.

Default is `0`, and the page continues on the same parameter entry: "… after which the
SecretID by default will expire. A value of zero will allow unlimited uses. However, this
option may be overridden by the request's 'num_uses' field when generating a SecretID."
(§Create/Update AppRole › Parameters; the sentence `A value of zero will allow unlimited
uses.` occurs 3× on this page, so it is not a unique locator on its own — the parameter
entry above is the anchored quote).

### 2.3 M3 — `secret_id_ttl`

> "secret_id_ttl (string: "") - Duration in either an integer number of seconds ( 3600 ) or an integer time unit ( 60m )"
> — §Create/Update AppRole › Parameters (23 words)

Resolve:

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S124.body 'secret_id_ttl (string: "") - Duration in either an integer number of seconds ( 3600 ) or an integer time unit ( 60m )'
grep -c -F '<code>secret_id_ttl</code> <code>(string: "")</code> - Duration in either an integer number of' .ufo/waves/round-60/capture/S124.body
```

```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `<code>secret_id_ttl</code> <code>(string: "")</code> - Duration in either an integer number of`
at **byte 23451, line 48** of `S124.body`.

Default is the empty string `""`; the same parameter entry continues "… after which by
default any SecretID expires. A value of zero will allow the SecretID to not expire.
However, this option may be overridden by the request's 'ttl' field when generating a
SecretID." (§Create/Update AppRole › Parameters.)

### 2.4 M4 — secret-id-accessor lookup and destroy

The accessor is documented as a non-secret handle over the SecretID:

> "the response will also contain a secret_id_accessor value which can be used to read the properties of the SecretID without divulging the SecretID itself"
> — §Generate new secret ID (24 words)

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S124.body 'the response will also contain a secret_id_accessor value which can be used to read the properties of the SecretID without divulging the SecretID itself'
grep -c -F 'the response will also contain a' .ufo/waves/round-60/capture/S124.body
```

```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `the response will also contain a` at **byte 55969, line 149** of `S124.body`.

The two accessor endpoints, as raw literals:

> "/auth/approle/role/:role_name/secret-id-accessor/lookup"
> — §Read AppRole secret ID accessor (Method/Path table; the method is `POST`)

```
grep -c -F '/auth/approle/role/:role_name/secret-id-accessor/lookup' .ufo/waves/round-60/capture/S124.body
```

```
1
```

Raw literal at **byte 91018, line 233** of `S124.body`.

> "Destroy an AppRole secret ID by its accessor."
> — §Destroy AppRole Secret ID Accessor (8 words)

```
grep -c -F 'Destroy an AppRole secret ID by its accessor.' .ufo/waves/round-60/capture/S124.body
```

```
1
```

Raw literal at **byte 102892, line 246** of `S124.body`.

> "/auth/approle/role/:role_name/secret-id-accessor/destroy"
> — §Destroy AppRole Secret ID Accessor (Method/Path table; the method is `POST`)

```
grep -c -F '/auth/approle/role/:role_name/secret-id-accessor/destroy' .ufo/waves/round-60/capture/S124.body
```

```
1
```

Raw literal at **byte 103108, line 247** of `S124.body`.

The lookup response's documented field set (§Read AppRole secret ID accessor › Sample
Response) is `cidr_list`, `creation_time`, `expiration_time`, `last_updated_time`,
`metadata`, `secret_id_accessor`, `secret_id_num_uses`, `secret_id_ttl`,
`token_bound_cidrs` — it carries **no `secret_id` value**. Measured on the captured body
(this is a structural read of the sample-response block, not a located quote):

```
python3 - <<'EOF'
import re, json
b = open(".ufo/waves/round-60/capture/S124.body", encoding="utf-8").read()
lines = b.split("\n")
for ln in (218, 244):                      # secret-id/lookup, secret-id-accessor/lookup
    t = re.sub(r"(?s)<[^>]+>", "", lines[ln-1])
    d = json.loads(re.sub(r"\s+", " ", t))["data"]
    print(ln, sorted(d.keys()), "secret_id" in d)
EOF
```

```
218 ['cidr_list', 'creation_time', 'expiration_time', 'last_updated_time', 'metadata', 'secret_id_accessor', 'secret_id_num_uses', 'secret_id_ttl', 'token_bound_cidrs'] False
244 ['cidr_list', 'creation_time', 'expiration_time', 'last_updated_time', 'metadata', 'secret_id_accessor', 'secret_id_num_uses', 'secret_id_ttl', 'token_bound_cidrs'] False
```

(S123 has no accessor section at all — see §1 M4 — so this field set is S124-only.)

### 2.5 M5 — `secret_id_bound_cidrs`

> "secret_id_bound_cidrs (array: []) - Comma-separated string or list of CIDR blocks; if set, specifies blocks of IP addresses which can perform the login operation."
> — §Create/Update AppRole › Parameters (24 words)

Resolve:

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S124.body 'secret_id_bound_cidrs (array: []) - Comma-separated string or list of CIDR blocks; if set, specifies blocks of IP addresses which can perform the login operation.'
grep -c -F '<code>secret_id_bound_cidrs</code> <code>(array: [])</code> - Comma-separated string or list of CIDR' .ufo/waves/round-60/capture/S124.body
```

```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `<code>secret_id_bound_cidrs</code> <code>(array: [])</code> - Comma-separated string or list of CIDR`
at **byte 22885, line 41** of `S124.body`. Default is `[]`.

### 2.6 Login request body field names — `auth/approle/login`

The endpoint is `POST /auth/approle/login` (§Login with AppRole, Method/Path table; the path
literal `<code>/auth/approle/login</code>` is at **byte 118059, line 296** of `S124.body`).
The documented request body fields are exactly two, both required:

> "role_id (string: <required>) - RoleID of the AppRole."
> — §Login with AppRole › Parameters (8 words)

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S124.body 'role_id (string: <required>) - RoleID of the AppRole.'
grep -c -F '<code>role_id</code> <code>(string: &lt;required>)</code> - RoleID of the AppRole.' .ufo/waves/round-60/capture/S124.body
```

```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `<code>role_id</code> <code>(string: &lt;required>)</code> - RoleID of the AppRole.`
at **byte 118330, line 299** of `S124.body`.

> "secret_id (string: <required>) - SecretID belonging to AppRole."
> — §Login with AppRole › Parameters (8 words)

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S124.body 'secret_id (string: <required>) - SecretID belonging to AppRole.'
grep -c -F '<code>secret_id</code> <code>(string: &lt;required>)</code> - SecretID belonging to AppRole.' .ufo/waves/round-60/capture/S124.body
```

```
RENDERED_TEXT_V1_LOCATE: count=1
1
```

Raw anchor `<code>secret_id</code> <code>(string: &lt;required>)</code> - SecretID belonging to AppRole.`
at **byte 118431, line 300** of `S124.body`.

The page's own sample payload for the endpoint is
`{ "role_id" : "59d6d1ca-47bb-4e7e-a40b-8be3bc5a0ba8" , "secret_id" : "84896a0c-1347-aa90-a4f6-aca8b7558780" }`
(§Login with AppRole › Sample Payload, line 303) — same two field names, no third.

Note the interaction the trial must respect: the parameters table marks `secret_id` as
`<required>`, while the same section's prose says the requirement holds "if
bind_secret_id is enabled (the default)". The documented *request* shape is two fields;
which of them the server actually demands depends on the role's `bind_secret_id`.

### 2.7 Refused login — exact documented text / HTTP shape

**NOT STATED on S124.** The AppRole API page documents no error response for a refused
login: no HTTP status code for a failed login (`grep -cE '\b4[0-9][0-9]\b'` over the raw
body ⇒ 0 — the only `4xx`-shaped strings are substrings of sample UUIDs), no `"errors"`
array, no error message body. `§Login with AppRole` carries only a `Sample response`
(success) block.

The only refusal-shaped text across the two pages is the S123 §User lockout sentence quoted
in §1 above (`permission denied error`, in the lockout context). **The refusal HTTP status
and the refusal error body are NOT STATED on either page.** The trial must obtain the
refusal status and message from the running server, not from these documents; the plan's
"named error" for T1/T2/T3/T5 is therefore a measurement obligation, not a documented
constant.

### 2.8 Per-field role endpoints (write paths the trial will call)

From §Read, update, or delete AppRole properties (all `GET/POST/DELETE`, line 313 of
`S124.body`), each verified with `grep -c -F` ⇒ 1:

| path | byte | line |
|---|---|---|
| `/auth/approle/role/:role_name/bind-secret-id` | 129241 | 313 |
| `/auth/approle/role/:role_name/secret-id-bound-cidrs` | 129406 | 313 |
| `/auth/approle/role/:role_name/secret-id-num-uses` | 128584 | 313 |
| `/auth/approle/role/:role_name/secret-id-ttl` | 128753 | 313 |

---

## 3. Coverage matrix — where each mechanic is documented

| mechanic | S123 (concept) | S124 (API) |
|---|---|---|
| M1 `bind_secret_id` | prose: required by default, can be disabled (§SecretID, §Further constraints). **Default value NOT STATED.** | prose + **default `true`** (§Create/Update AppRole, §Login with AppRole) |
| M2 `secret_id_num_uses` | **prose NOT STATED**; CLI example values only | prose + default `0`, "zero will allow unlimited uses", overridable by the request's `num_uses` |
| M3 `secret_id_ttl` | **prose NOT STATED**; CLI example values only | prose + default `""`, expiry/"zero will allow the SecretID to not expire", overridable by the request's `ttl` |
| M4 accessor lookup/destroy | **NOT STATED** (0 occurrences of `secret-id-accessor`; only the CLI output field `secret_id_accessor`) | prose + both paths + the lookup response field set (no `secret_id` value) |
| M5 `secret_id_bound_cidrs` | prose (§Further constraints) | prose + default `[]` (§Create/Update AppRole) |
| login request body fields | `role_id`, `secret_id` (CLI + API example body) | `role_id`, `secret_id`, both `<required>` (§Login with AppRole) |
| refused login text / HTTP shape | refusal *text* only: `permission denied error` in the **lockout** context; HTTP status **NOT STATED**, error body **NOT STATED** | **NOT STATED** entirely |

## 4. Notes and bounds for the registry rows / lesson Gate

* Both pages are tier-A-able OpenBao 2.7.x documentation and were opened live on
  2026-11-07 with a desktop browser user agent; both bodies are captured with byte count
  and sha256 pinned above.
* The two bodies differ from each other in size and digest; the digests above are of the
  decoded bodies, not of the gzip wire bytes (`%{size_download}` was 12566 / 14329).
* Nothing in either body is a secret, token or session id: the sample values are
  documentation fixtures (`role_id`/`secret_id`/accessor UUIDs and a `client_token`-shaped
  sample UUID), and no live credential was requested, fetched or recorded.
* **Named gap for the trial (C2):** the refusal HTTP status and error text are documented
  nowhere on these two pages; T1/T2/T3/T5's "named error" must be measured against the
  running OpenBao 2.7.2 dev server, and this notes file must not be cited as its source.
* The `secret_id_bound_cidrs` refusal on a source-IP mismatch is likewise undocumented in
  error form; only the constraint's effect ("will only allow logins coming from IP
  addresses belonging to configured CIDR blocks") is stated.

## 5. Reproduction

Every locating command in this file is reproduced by:

```
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
sha256sum .ufo/waves/round-60/capture/S123.body .ufo/waves/round-60/capture/S124.body
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S123.body 'The bind_secret_id constraint requires secret_id to be presented at the login endpoint.'
grep -c -F '<code>bind_secret_id</code> constraint requires' .ufo/waves/round-60/capture/S123.body
```

The seat's own end-to-end quote checker (19 quote rows, all resolving) is kept at
`.ufo/waves/round-60/build/R60ScoutApprole/verify_quotes.py` with its receipt
`.ufo/waves/round-60/build/R60ScoutApprole/quote-verify.txt`.
