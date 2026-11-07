# R60ScribeEntry — per-quote locate index for `openbao-approle-secret-id-custody.md`

Every double-quoted span in the draft that is presented as a page sentence or a page parameter
token, with the capture it was located against and the `count` the lane's normalizer printed.
Command, run from `/home/vgpnk/Projects/shokunin/kagi-shokunin`:

```
python3 corpus/rendered-text-v1.py locate .ufo/waves/round-60/capture/<S123|S124>.body "<quote>"
```

A quote is listed once even when the draft repeats it. `count=0` would mean not located; no row
below has that. Spans of one or two words that are parameter names or JSON keys are marked as
tokens, not treated as page sentences. Every quoted span is at most 25 words (the largest below is
22).

Captures: S123 `.ufo/waves/round-60/capture/S123.body` (raw sha256
`d16f639a0b0fff901707f56ad1b916f70665e7e0675197a6a40d6473e50c0187`, 78543 B; normalized
`4230771520d9749e67efe7dd42d57e30ebfbfd105206f142227d6023003b687a`, 12089 B); S124
`.ufo/waves/round-60/capture/S124.body` (raw sha256
`e663c1d0f956edea896db404bba7e92c7f248f74e98857a717ab063a7aae7207`, 145203 B; normalized
`966641e895fb723695d66fd870f39731b43bb47b08dec2ed2601da1443f65935`, 21214 B).

Both bodies were fetched twice independently — once by the round-60 scout into the lane capture
path, once by this seat into its scratch — and the two fetches are byte-identical (same raw
sha256). No `set-cookie:` or `cookie:` header line was present in either response; the
server-issued request-id headers (`x-github-request-id`, `x-fastly-request-id`,
`x-github-edge-region`, `x-served-by`, `x-cache`, `x-cache-hits`, `x-timer`, `x-proxy-cache`) are
not reproduced in any artifact of this seat.

| # | words | quote | capture locate |
|---|---|---|---|
| 1 | 13 | "The approle auth method allows machines or apps to authenticate with OpenBao-defined roles" | S123 count=1 |
| 2 | 22 | "An "AppRole" represents a set of OpenBao policies and login constraints that must be met to receive a token with those policies" | S123 count=1 |
| 3 | 12 | "the RoleID is a required argument (via role_id ) at all times" | S123 count=1 |
| 4 | 14 | "is an identifier that selects the AppRole against which the other credentials are evaluated" | S123 count=1 |
| 5 | 19 | "By default, RoleIDs are unique UUIDs, which allow them to serve as secondary secrets to the other credential information" | S123 count=1 |
| 6 | 22 | "SecretID is a credential that is required by default for any login (via secret_id ) and is intended to always be secret" | S123 count=1 |
| 7 | 6 | "is intended to always be secret" | S123 count=1 |
| 8 | 11 | "requiring a SecretID can be disabled via an AppRole's bind_secret_id parameter" | S123 count=1 |
| 9 | 17 | "allowing machines with only knowledge of the RoleID, or matching other set constraints, to fetch a token" | S123 count=1 |
| 10 | 20 | "SecretIDs can be created against an AppRole either via generation of a 128-bit purely random UUID by the role itself" | S123 count=1 |
| 11 | 11 | "Similarly to tokens, SecretIDs have properties like usage-limit, TTLs and expirations" | S123 count=1 |
| 12 | 12 | "The bind_secret_id constraint requires secret_id to be presented at the login endpoint" | S123 count=1 |
| 13 | 17 | "secret_id_bound_cidrs will only allow logins coming from IP addresses belonging to configured CIDR blocks on the AppRole" | S123 count=1 |
| 14 | 3 | "some other system" | S123 count=1 |
| 15 | 19 | "the SecretID can be kept confidential from all parties except for the final authenticating client by using Response Wrapping" | S123 count=1 |
| 16 | 20 | "The default values for "lockout threshold" is 5 attempts, "lockout duration" is 15 minutes, "lockout counter reset" is 15 minutes" | S123 count=1 |
| 17 | 19 | "OpenBao will stop trying to validate their credentials for a while, instead returning immediately with a permission denied error" | S123 count=1 |
| 18 | 17 | "is reset to zero after a few minutes without login attempts, or upon a successful login attempt" | S123 count=1 |
| 19 | 5 | "The default path is /approle" | S123 count=1 |
| 20 | 1 | `secret_id_ttl=10m` (parameter token in the configuration example) | S123 count=1 |
| 21 | 1 | `secret_id_num_uses=40` (parameter token in the configuration example) | S123 count=1 |
| 22 | 15 | "bind_secret_id (bool: true) - Require secret_id to be presented when logging in using this AppRole" | S124 count=1 |
| 23 | 20 | "secret_id_num_uses (integer: 0) - Number of times any particular SecretID can be used to fetch a token from this AppRole" | S124 count=1 |
| 24 | 16 | "after which the SecretID by default will expire. A value of zero will allow unlimited uses" | S124 count=1 |
| 25 | 6 | "the SecretID by default will expire" | S124 count=1 |
| 26 | 12 | "secret_id_ttl (string: "") - Duration in either an integer number of seconds" | S124 count=1 |
| 27 | 18 | "after which by default any SecretID expires. A value of zero will allow the SecretID to not expire" | S124 count=1 |
| 28 | 15 | "can be used to read the properties of the SecretID without divulging the SecretID itself" | S124 count=1 |
| 29 | 9 | "and also to delete the SecretID from the AppRole" | S124 count=1 |
| 30 | 13 | "if set, specifies blocks of IP addresses which can perform the login operation" | S124 count=1 |
| 31 | 17 | "role_id is always required; if bind_secret_id is enabled (the default) on the AppRole, secret_id is required too" | S124 count=1 |
| 32 | 16 | "Any other bound authentication values on the AppRole (such as client IP CIDR) are also evaluated" | S124 count=1 |
| 33 | 17 | "It is required to have at least one of them enabled while creating or updating a role" | S124 count=1 |
| 34 | 13 | "Number of times this SecretID can be used, after which the SecretID expires" | S124 count=2 (secret-id and custom-secret-id `num_uses` parameter lists) |
| 35 | 12 | "Overrides secret_id_num_uses role option when supplied. May not be higher than role" | S124 count=2 (same two parameter lists) |
| 36 | 6 | "May not be longer than role" | S124 count=2 (same two `ttl` parameter lists) |
| 37 | 8 | "Destroy an AppRole secret ID by its accessor" | S124 count=1 |
| 38 | 7 | "Reads out the properties of a SecretID" | S124 count=2 (heads both the `secret-id/lookup` and the `secret-id-accessor/lookup` sections) |
| 39 | 8 | "secret_id (string: <required>) - SecretID belonging to AppRole" | S124 count=1 (login parameter list) |
| 40 | 10 | "secret_id (string: <required>) - Secret ID attached to the role" | S124 count=2 (lookup and destroy parameter lists) |
| 41 | 11 | "secret_id_accessor (string: <required>) - Secret ID accessor attached to the role" | S124 count=2 (accessor lookup and accessor destroy parameter lists) |
| 42 | 19 | "the list of CIDR blocks listed here should be a subset of the CIDR blocks listed on the role" | S124 count=2 (same two generation parameter lists) |
| 43 | 4 | "must be a subset" | S124 count=2 (the `token_bound_cidrs` generation parameter) |
| 44 | 19 | "This metadata will be set on tokens issued with this SecretID, and is logged in audit logs in plaintext" | S124 count=2 (same two generation parameter lists) |
| 45 | 7 | "is logged in audit logs in plaintext" | S124 count=2 (same two parameter lists) |
| 46 | 2 | "cluster local" | S124 count=1 |
| 47 | 15 | "can only be set during role creation and once set, it can't be reset later" | S124 count=1 |
| 48 | 19 | "specifies blocks of IP addresses which can authenticate successfully, and ties the resulting token to these blocks as well" | S124 count=1 |
| 49 | 3 | "conflicts with token_bound_cidrs" | S124 count=1 |
| 50 | 11 | "to be able to delegate specific endpoints using OpenBao's ACL system" | S124 count=1 |
| 51 | 2 | "unlimited uses" | S124 count=3 (role `secret_id_num_uses`, generation `num_uses`, custom generation `num_uses`) |
| 52 | 8 | "A value of zero will allow unlimited uses" | S124 count=3 (same three parameter lists) |
| 53 | 9 | "Creates a new AppRole or updates an existing AppRole" | S124 count=1 |
| 54 | 8 | "This endpoint supports both create and update capabilities" | S124 count=1 |
| 55 | 1 | `custom-secret-id` (endpoint token) | S124 count=2 |
| 56 | 1 | `bind-secret-id` (per-field endpoint token) | S124 count=1 |
| 57 | 1 | `token_strictly_bind_ip` (parameter token) | S124 count=1 |
| 58 | 1 | `secret_id_num_uses` (parameter token) | S124 count=10 |

## Absence checks behind §Docs-vs-binary

Strings that a reader would expect if the pages documented the observable, and the `count` the
normalizer prints for each. These are the page-shaped holes the measured rows fill; they are not
page statements and must not be cited as support.

| string | S123 | S124 | what its absence means |
|---|---|---|---|
| `invalid role or secret ID` | 0 | 0 | the refusal text for a login missing `secret_id` under `bind_secret_id=true` is undocumented |
| `invalid secret id` | 0 | 0 | the refusal text for a spent or expired `secret_id` is undocumented |
| `missing secret_id` | 0 | 0 | neither page names a missing-credential error |
| `invalid role` | 0 | 0 | neither page names an unknown-`role_id` error |
| `expired` | 0 | 0 | the pages say a SecretID "expires" but never name the resulting error |
| `not found` | 0 | 0 | what an accessor lookup returns after a destroy is undocumented |
| `destroyed` / `deleted` | 0 | 0 | the post-destroy state is undocumented |
| `remaining` / `uses remaining` / `no uses` | 0 | 0 | whether the accessor lookup reports remaining or configured uses is undocumented |
| `source address` / `not permitted` | 0 | 0 | the refusal text for a CIDR-bound login is undocumented |
| `revoke` | 0 | 0 | neither page uses the word for a SecretID |
| `permission denied` | 1 | 0 | the only named login refusal on either page, and it belongs to the lockout paragraph — a confounder, not the credential error |
| `cannot log in` / `login failed` | 0 | 0 | neither page describes a failed login as an observable |

## Additional spans used in the final draft

These were added after the first index pass (fragments used inside §Custody, §Docs-vs-binary
D11 and the §Bounds token list). Same command, same captures, same rule: every span is at most
25 words and locates with a non-zero count.

| # | words | quote | capture locate |
|---|---|---|---|
| 59 | 4 | "serve as secondary secrets" | S123 count=1 |
| 60 | 10 | "is a required argument (via role_id ) at all times" | S123 count=1 |
| 61 | 9 | "required by default for any login (via secret_id )" | S123 count=1 |
| 62 | 9 | "Number of times any particular SecretID can be used" | S124 count=1 |
| 63 | 6 | "the SecretID by default will expire" | S124 count=1 |
| 64 | 8 | "Duration in either an integer number of seconds" | S124 count=1 |
| 65 | 11 | "A value of zero will allow the SecretID to not expire" | S124 count=3 |
| 66 | 5 | "without divulging the SecretID itself" | S124 count=1 |
| 67 | 7 | "May not be longer than role's secret_id_ttl" | S124 count=2 |
| 68 | 4 | "must be a subset" | S124 count=2 |
| 69 | 6 | "which can perform the login operation" | S124 count=1 |
| 70 | 12 | "enforcing secret IDs to be used from specific set of IP addresses" | S124 count=2 |
| 71 | 1 | `custom-secret-id` (endpoint token) | S124 count=2 |
| 72 | 1 | `bind-secret-id` (per-field endpoint token) | S124 count=1 |
| 73 | 1 | `token_strictly_bind_ip` (parameter token) | S124 count=1 |

## Spans that are deliberately not page quotes

Three quoted spans in the draft are not page sentences and carry no locate row: the two candidate
readings in D3 (*remaining after the sample login* / *configured default*, rendered in italics so
they cannot be mistaken for page text), and the one verbatim quote from `plans/round-60.md` §A3
item 2 in D10, which the draft labels "quoting the plan, not a page". Everything else inside
double quotes in the draft is a page span with a row above.
