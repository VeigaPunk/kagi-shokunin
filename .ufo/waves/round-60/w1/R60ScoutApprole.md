# R60ScoutApprole — round 60 wave 1 (scout): AppRole documentation capture, located quotes

Seat: `R60ScoutApprole` (scout). Round 60, attempt 1, wave 1, v1 (16 seats, §A2).
Lane: `kagi-shokunin`. Scope: open the two AppRole documentation sources this round
declares, live, and produce the located-quote evidence the registry rows and the lesson
Gate need. Non-goals (not done): no edit to `corpus/SOURCES.md`, no trial design, no
`corpus/lessons/*` edit, no plan/instrument edit, no git/jj mutation.

## 1. What I produced

| path | what |
|---|---|
| `.ufo/waves/round-60/capture/S123.body` | decoded HTTP body of `https://openbao.org/docs/auth/approle/`, 78543 B, sha256 `d16f639a0b0fff901707f56ad1b916f70665e7e0675197a6a40d6473e50c0187` |
| `.ufo/waves/round-60/capture/S124.body` | decoded HTTP body of `https://openbao.org/docs/api/auth/approle/`, 145203 B, sha256 `e663c1d0f956edea896db404bba7e92c7f248f74e98857a717ab063a7aae7207` |
| `.ufo/waves/round-60/capture/notes.md` | the located-quote evidence: one section per source, five mechanics each, login request fields, refused-login shape, coverage matrix |
| `.ufo/waves/round-60/build/R60ScoutApprole/fetch-receipt.txt` | sanitized response headers + digests for both pages (QM72) |
| `.ufo/waves/round-60/build/R60ScoutApprole/verify_quotes.py` | end-to-end quote checker (19 rows) |
| `.ufo/waves/round-60/build/R60ScoutApprole/quote-verify.txt` | its receipt: `QUOTE_VERIFY: rows=19` … `failures=0` |

## 2. Fetch record

```
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36'
curl -fsSL --compressed -A "$UA" -D <sid>.rawheaders -o <sid>.body \
     -w '%{http_code} %{url_effective} %{size_download}\n' "<url>"
```

| id | url | status | final_url | wire B (gzip) | decoded B | sha256 | access date |
|---|---|---|---|---|---|---|---|
| S123 | `https://openbao.org/docs/auth/approle/` | 200 | unchanged | 12566 | 78543 | `d16f639a…c0187` | 2026-11-07 |
| S124 | `https://openbao.org/docs/api/auth/approle/` | 200 | unchanged | 14329 | 145203 | `e663c1d0…7207` | 2026-11-07 |

* User agent string (verbatim): `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36`.
* Request profile is `curl -fsSL --compressed` **with that desktop browser UA**. It is
  *not* the lane's `curl-fsSL-compressed-v1` profile (that one uses
  `-A 'kagi-shokunin-round23/1.0 (documentation verification)'`). The representation domain
  is nevertheless the lane's `decoded-http-body-v1` (Content-Encoding removed by curl), so
  the digest/byte-count columns are comparable with the S120–S122 rows.
* **No cookie was present to remove**: neither response carries a `set-cookie:` or
  `cookie:` header (`grep -in cookie` over both raw header files ⇒ 0 matches, exit 1).
  The server-issued correlation ids (`x-github-request-id`, `x-fastly-request-id`) were
  replaced by a placeholder in the receipt (2 per page), per QM72.
* **Pages opened: exactly these two.** No third URL was fetched, so there is no
  rejection record for the Gate this round.
* Both pages are `docs-version-2.7.x` (S124's sidebar reads `Version: Version 2.7.x`),
  matching the plan's "OpenBao docs 2.7.x".

## 3. The five mechanics — where each is documented, and the located quote

Each quote is ≤ 25 words and resolves **in the captured body**, with the resolving command
shown. Two locator families, both against the captured `.body` bytes:

* **raw-literal** — the phrase is a literal byte substring; resolved with
  `grep -c -F '<phrase>' <body>`; byte offset and line given.
* **rendered-v1** — the phrase is prose; resolved with the lane's own committed normalizer
  `python3 corpus/rendered-text-v1.py locate <body> '<phrase>'` (reads only the named
  file, no network, no writes), **plus** a raw-literal anchor that *is* a byte substring of
  the same body with its byte offset and line, so the quote's position in the captured
  bytes is verifiable without normalizing.

Full detail, all commands, and all offsets are in
`.ufo/waves/round-60/capture/notes.md`. Summary:

| mechanic | S123 (concept) | S124 (API) |
|---|---|---|
| **M1 `bind_secret_id`** default + meaning | prose only: required by default, can be disabled — **default value NOT STATED** (§1.1) | **default `true`** written out (§2.1) |
| **M2 `secret_id_num_uses`** | **prose NOT STATED**; CLI example values only (§1.2) | default `0`, "zero will allow unlimited uses", overridable by request `num_uses` (§2.2) |
| **M3 `secret_id_ttl`** | **prose NOT STATED**; CLI example values only (§1.3) | default `""`, expiry, overridable by request `ttl` (§2.3) |
| **M4 accessor lookup + destroy** | **NOT STATED** — 0 occurrences of `secret-id-accessor` (§1.4) | both paths + destroy sentence + lookup response field set, no `secret_id` value (§2.4) |
| **M5 `secret_id_bound_cidrs`** | prose (§1.5) | prose + default `[]` (§2.5) |

Located quotes (the resolving command for each is in `notes.md`; all resolve `count=1`):

* **M1** — S124 §Create/Update AppRole › Parameters: *"bind_secret_id (bool: true) -
  Require secret_id to be presented when logging in using this AppRole."* (15 words);
  raw anchor `<code>bind_secret_id</code> <code>(bool: true)</code> - Require` at
  **S124 byte 22728, line 39**.
  Also S123 §Further constraints: *"The bind_secret_id constraint requires secret_id to be
  presented at the login endpoint."* (12 words), raw anchor at **S123 byte 44813,
  line 119**.
  Also S124 §Login with AppRole: *"role_id is always required; if bind_secret_id is enabled
  (the default) on the AppRole, secret_id is required too."* (17 words), raw anchor at
  **S124 byte 117685, line 293**.
* **M2** — S124 §Create/Update AppRole › Parameters: *"secret_id_num_uses (integer: 0) -
  Number of times any particular SecretID can be used to fetch a token"* (17 words); raw
  anchor at **S124 byte 23092, line 44**.
* **M3** — S124 §Create/Update AppRole › Parameters: *"secret_id_ttl (string: "") - Duration
  in either an integer number of seconds ( 3600 ) or an integer time unit ( 60m )"* (23
  words); raw anchor at **S124 byte 23451, line 48**.
* **M4** — S124 §Generate new secret ID: *"the response will also contain a
  secret_id_accessor value which can be used to read the properties of the SecretID without
  divulging the SecretID itself"* (24 words), raw anchor at **S124 byte 55969, line 149**.
  Raw literals: `Destroy an AppRole secret ID by its accessor.` (**S124 byte 102892,
  line 246**), `/auth/approle/role/:role_name/secret-id-accessor/lookup` (**byte 91018,
  line 233**), `/auth/approle/role/:role_name/secret-id-accessor/destroy` (**byte 103108,
  line 247**) — both `POST`.
* **M5** — S124 §Create/Update AppRole › Parameters: *"secret_id_bound_cidrs (array: []) -
  Comma-separated string or list of CIDR blocks; if set, specifies blocks of IP addresses
  which can perform the login operation."* (24 words); raw anchor at **S124 byte 22885,
  line 41**. Also S123 §Further constraints: *"secret_id_bound_cidrs will only allow
  logins coming from IP addresses belonging to configured CIDR blocks on the AppRole."* (17
  words), raw anchor at **S123 byte 45127, line 123**.

### Login request body fields for `auth/approle/login`

Exactly two documented fields, both `<required>`:

* **role_id** — *"role_id (string: <required>) - RoleID of the AppRole."* (8 words), raw
  anchor at **S124 byte 118330, line 299**.
* **secret_id** — *"secret_id (string: <required>) - SecretID belonging to AppRole."* (8
  words), raw anchor at **S124 byte 118431, line 300**.

Endpoint: `POST /auth/approle/login` (§Login with AppRole; path literal at **S124 byte
118059, line 296**). The page's own sample payload is `{ "role_id" : "59d6d1ca-…" ,
"secret_id" : "84896a0c-…" }` (line 303) — same two names, no third. S123 shows the same
pair as a raw-literal CLI/API example: `--data '{"role_id":"988a9df-...","secret_id":"37b74931..."}'`
(**S123 byte 23100, line 26**).

### Refused login — exact documented text / HTTP shape

**NOT STATED on either page, for the HTTP shape.** Measured on the captured bodies:

* `grep -cE '\b4[0-9][0-9]\b'` ⇒ **0** on both bodies (the only `403`/`404` byte sequences
  are substrings of sample UUIDs, e.g. `…-15e7-403a-a480…`, `…b5ca4044b8`).
* `grep -c '"errors"'` ⇒ **0** on both bodies; there is no documented error array, no
  error status, no error message body, and no error section on either page.
* §Login with AppRole carries only a *success* `Sample response` block.

The only refusal-shaped text anywhere in the two pages is on S123 §User lockout — and it
describes the *lockout* path (repeated bad credentials), not the ordinary "wrong
secret_id" refusal:

> "instead returning immediately\nwith a permission denied error." (8 words)

raw literal at **S123 byte 45623, line 127** (the phrase `permission denied error` is at
byte 45660, line 128).

**Consequence for the C2 trial (named to the L1, not a frozen change):** the plan's T1/T2/T3/T5
"refused with a named error" is a *measurement* obligation, not a documented constant. The
two pages this round declares do not state the refusal HTTP status or the refusal error
text; the trial must obtain both from the running OpenBao 2.7.2 dev server, and neither
`notes.md` nor the registry rows may be cited as their source.

## 4. Extra facts a trial may want (all located)

* Per-field role write paths, all `GET/POST/DELETE`, S124 §Read, update, or delete AppRole
  properties (line 313): `/auth/approle/role/:role_name/bind-secret-id` (byte 129241),
  `…/secret-id-bound-cidrs` (byte 129406), `…/secret-id-num-uses` (byte 128584),
  `…/secret-id-ttl` (byte 128753).
* The `secret-id-accessor/lookup` and `secret-id/lookup` sample responses carry the field
  set `cidr_list, creation_time, expiration_time, last_updated_time, metadata,
  secret_id_accessor, secret_id_num_uses, secret_id_ttl, token_bound_cidrs` and **no
  `secret_id` value** — measured on the captured body (the JSON block, lines 218 and 244).
  This is the documentation-side basis for the plan's T4 "the accessor is a non-secret
  custody handle".
* S123's `secret_id_num_uses` / `secret_id_ttl` appear **only** as CLI example values
  (`secret_id_num_uses=40`, `secret_id_ttl=10m`, and the matching output fields), never as
  prose. The registry row for S123 must not claim it documents their semantics.

## 5. Verification I ran

```
sha256sum .ufo/waves/round-60/capture/S123.body .ufo/waves/round-60/capture/S124.body
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/S123.body 'The bind_secret_id constraint requires secret_id to be presented at the login endpoint.'
grep -c -F '<code>bind_secret_id</code> constraint requires' .ufo/waves/round-60/capture/S123.body
python3 .ufo/waves/round-60/build/R60ScoutApprole/verify_quotes.py
```

Results: the two sha256 values equal the ones recorded in `notes.md`; the locator prints
`RENDERED_TEXT_V1_LOCATE: count=1`; the `grep -c -F` prints `1`; and the seat's checker
prints `QUOTE_VERIFY: rows=19` … `QUOTE_VERIFY: failures=0` (exit 0). Every byte offset and
line number stated in `notes.md` was re-measured against the captured bodies with a
script that compares the claimed offset/line against `str.find` — **29 offset claims, 0
mismatches** after I corrected three offsets I had mistyped (byte 42495→42555,
42946→42947, and the S124 login-path 118154→118059).

## 6. Secret discipline

* No secret value, token, cookie, session id or `secret_id` value was written by this
  seat. The only identifiers appearing in the notes are the pages' own **documentation
  fixture** values (sample `role_id`/`secret_id`/accessor UUIDs), quoted as part of the
  located quotes and the field-set measurement.
* No Set-Cookie/Cookie value existed to redact (0 occurrences).
* Scratch (`/fast/scratch/hyaku/kagi-r60/R60ScoutApprole/`) deleted before yield; no
  citable evidence was written under `/tmp`.

## 7. Tools

No tool was installed, upgraded or removed by this seat — the work needed only `curl`,
`python3` and the lane's committed `corpus/rendered-text-v1.py`, all already present.
(No pacman / uv / cargo / npm transaction; nothing to record on the tooling channel.)

## 8. Notes for the L1 (no frozen item changed)

* Registry rows S123/S124 can now be written with, for each, the located quote and the
  located offsets in `notes.md`; the quote-cell bound of ≤ 25 ASCII words holds for every
  quote I recorded.
* `notes.md` is the only file this seat authored under `capture/`; the two `.body` files
  are the fetched bytes.
* One honest gap to carry into the lesson Gate: the **refusal HTTP status and error body
  are undocumented on both pages**, so the trial's "named error" legs must be measured, not
  cited.

SEAT-STATUS: complete
