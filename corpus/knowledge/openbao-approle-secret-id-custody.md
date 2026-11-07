# OpenBao AppRole: the SecretID is the secret half, its reuse bounds (`secret_id_num_uses`, `secret_id_ttl`), and the accessor as the non-secret custody handle

source: S123 (https://openbao.org/docs/auth/approle/, §Credentials/Constraints — RoleID, SecretID, Pull and push SecretID modes, Further constraints; §Configuration; §User lockout; OpenBao docs Version 2.7.x, opened 2026-11-07); S124 (https://openbao.org/docs/api/auth/approle/, §Create/Update AppRole, §Generate new secret ID, §Read AppRole secret ID, §Read AppRole secret ID accessor, §Destroy AppRole Secret ID Accessor, §Login with AppRole, §Read, update, or delete AppRole properties; Version 2.7.x, opened 2026-11-07)
verified-at: 2026-11-07 (both pages fetched as decoded bodies and read as rendered text; every quoted page sentence below is located by `python3 corpus/rendered-text-v1.py locate <capture> QUOTE` against the round-60 capture, with the locate count stated; the five T-mechanics were executed against OpenBao 2.7.2 by `corpus/openbao-approle-trial.sh`, whose receipt lines are the only behavioural evidence in §Mechanics)
recheck: 180d — on the next cadence re-open S123 §Credentials/Constraints and §User lockout and S124 §Create/Update AppRole / §Generate new secret ID / §Read AppRole secret ID accessor, compare the docs `Version` label to 2.7.x, and re-run `bash corpus/openbao-approle-trial.sh --work <scratch dir>` against the then-current binary (the lane has no bound on-release clock for these pages; S090 is a 90d feed row)
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the page or run OpenBao; `recheck:` is the content clock, the executed trial named there is the behaviour check.)

Scope: OpenBao 2.7.2 only, the AppRole auth method at its default `approle/` mount, one role per
test, and the credential properties the trial varies (`bind_secret_id`, `secret_id_num_uses`,
`secret_id_ttl`, `secret_id_bound_cidrs`, and the accessor endpoints). A Vault fact is never
extended to OpenBao or the reverse. This entry is written in two voices and keeps them apart: the
documented mechanics are the pages' sentences, each with a located quote, while §Mechanics is only
what a receipt line from the round-60 run shows. Where a page sentence has no receipt behind it,
the entry says `documented, not measured` and the claim does not become behavioural.

## Why it matters for secrets operations

AppRole is the machine-identity path: the method "allows machines or apps to authenticate with
OpenBao-defined roles" (count=1), and a workload proves who it is with a credential pair instead
of a human session. What the pair buys is stated in one sentence — "An "AppRole" represents a set
of OpenBao policies and login constraints that must be met to receive a token with those
policies" (count=1) — which is why the credential's properties are a policy question and not a
transport question. Everything an operator does to make that safe is a statement about which half
is secret. The design is a deliberate asymmetry. `role_id` is a *selector* — it names which
role's constraints get evaluated — and `secret_id` is the *secret* that satisfies the default
constraint. That split is what makes the credential deliverable: the selector can be baked into an
image, printed in a manifest, or derived from the machine's own identity, while the secret half is
handed over once, under a use count and a clock, and can be killed without touching the role.

Two consequences follow and both are operational rather than theoretical. First, a leaked
`secret_id` is a *bounded* exposure only if the reuse bounds were set: with the documented
defaults (`secret_id_num_uses=0`, `secret_id_ttl=""`, i.e. unlimited and non-expiring) a stolen
secret is a permanent credential, and the page's own example sets `secret_id_ttl=10m` and
`secret_id_num_uses=40` precisely because the defaults do not bound anything. Second, the
`secret_id_accessor` is the operator's handle: it reads a secret's properties and destroys it
without the operator ever holding the secret value, which is the difference between a custody
process a human can run and one that requires the secret to be copied into a ticket.

## Documented mechanics (S123/S124, Version 2.7.x, opened 2026-11-07)

Captures: `.ufo/waves/round-60/capture/S123.body`, decoded body sha256
`d16f639a0b0fff901707f56ad1b916f70665e7e0675197a6a40d6473e50c0187` (78543 B), rendered-text-v1
sha256 `4230771520d9749e67efe7dd42d57e30ebfbfd105206f142227d6023003b687a` (12089 B); and
`.ufo/waves/round-60/capture/S124.body`, decoded body sha256
`e663c1d0f956edea896db404bba7e92c7f248f74e98857a717ab063a7aae7207` (145203 B), rendered-text-v1
sha256 `966641e895fb723695d66fd870f39731b43bb47b08dec2ed2601da1443f65935` (21214 B). Both pages
carry the label `Version 2.7.x`. The captures were fetched by the round-60 scout with a desktop
browser user agent; this seat's independent fetch produced byte-identical bodies (same raw
sha256), and no `set-cookie:`/`cookie:` header line was present in either response. The normalizer
is the one declared in `corpus/rendered-text-v1.py`; it replaces every HTML tag with a space, so a
quote that spans an inline `<code>` element shows that space (that is why `(via role_id )` and
`(bool: true)` carry the spacing they do below). Each quote below was located against the capture
named here; where a sentence occurs in more than one parameter list, the locate count is stated.
The per-quote locate index (quote → capture → count) is recorded beside this draft as
`.ufo/waves/round-60/build/R60ScribeEntry/quote-locations.md`.

| # | mechanic | documented rule (anchor, located quote) | what the executed trial asserts (frozen in `plans/round-60.md` §C2) |
|---|---|---|---|
| T1 | `bind_secret_id` decides whether `role_id` alone authenticates | S124 §Create/Update AppRole: "bind_secret_id (bool: true) - Require secret_id to be presented when logging in using this AppRole" (count=1); S123 §Further constraints: "The bind_secret_id constraint requires secret_id to be presented at the login endpoint" (count=1); S123 §SecretID: "requiring a SecretID can be disabled via an AppRole's bind_secret_id parameter" (count=1) and "allowing machines with only knowledge of the RoleID, or matching other set constraints, to fetch a token" (count=1) | With the default `bind_secret_id=true` a login carrying only `role_id` is refused with a named error; after `bind_secret_id=false` on the same role the same body logs in and a token is issued. |
| T2 | `secret_id_num_uses` bounds credential reuse | S124: "secret_id_num_uses (integer: 0) - Number of times any particular SecretID can be used to fetch a token from this AppRole" (count=1) "after which the SecretID by default will expire. A value of zero will allow unlimited uses" (count=1); S123: "Similarly to tokens, SecretIDs have properties like usage-limit, TTLs and expirations" (count=1) | With `secret_id_num_uses=1` the first login succeeds and a second login with the same `secret_id` is refused; a freshly generated `secret_id` logs in. |
| T3 | `secret_id_ttl` retires an unwrapped `secret_id` | S124: `secret_id_ttl` "Duration in either an integer number of seconds" (count=1) "after which by default any SecretID expires. A value of zero will allow the SecretID to not expire" (count=1) | With `secret_id_ttl=1s` a fresh `secret_id` logs in immediately and the same one is refused after expiry (≥3 s later) with a named error; a newly generated `secret_id` logs in. |
| T4 | the accessor is a non-secret custody handle | S124 §Generate new secret ID: a "secret_id_accessor value which can be used to read the properties of the SecretID without divulging the SecretID itself" (count=1) "and also to delete the SecretID from the AppRole" (count=1); §Read AppRole secret ID accessor: "Reads out the properties of a SecretID" (count=2); §Destroy AppRole Secret ID Accessor: "Destroy an AppRole secret ID by its accessor" (count=1) | `secret-id-accessor/lookup` returns metadata (including the remaining use count and TTL — the receipt shows presence only, see §Docs-vs-binary D3) and no `secret_id` value; `secret-id-accessor/destroy` invalidates a still-valid, unused `secret_id`, after which login with it is refused. |
| T5 | `secret_id_bound_cidrs` pins a credential to a source range | S124 §Create/Update AppRole: `secret_id_bound_cidrs` "if set, specifies blocks of IP addresses which can perform the login operation" (count=1); S123 §Further constraints: "secret_id_bound_cidrs will only allow logins coming from IP addresses belonging to configured CIDR blocks on the AppRole" (count=1); S124 §Login with AppRole: "Any other bound authentication values on the AppRole (such as client IP CIDR) are also evaluated" (count=1) | With the role bound to `10.0.0.0/8` a login from 127.0.0.1 is refused with a source-address error; with `127.0.0.1/32` bound the same login succeeds. |

### The selector and the secret

The page is explicit that the pair is asymmetric but not that `role_id` is non-secret. It says
`role_id` "is a required argument (via role_id ) at all times" (count=1) and that it "is an
identifier that selects the AppRole against which the other credentials are evaluated" (count=1);
then it
adds the sentence that makes custody harder to state cleanly: "By default, RoleIDs are unique
UUIDs, which allow them to serve as secondary secrets to the other credential information"
(count=1). So the documentation treats `role_id` as *possibly* secret — a second factor — while
the SecretID paragraph says the secret half "is intended to always be secret" and that it is
"required by default for any login (via secret_id )" (count=1).

The two readings are reconciled by the constraint, not by the credential: with
`bind_secret_id=true` the login needs both, so `role_id` behaves as a second secret; with
`bind_secret_id=false` the login needs only `role_id`, so the same value is a bare selector. That
is exactly what T1 measures, and it is why the trial's `bind_secret_id=false` leg is a deliberate
unsafe configuration rather than a convenience. An operator who sets it has converted a
two-credential login into a one-credential login whose only remaining secrets are whatever other
constraints are enabled.

The page also fixes the delivery model: `secret_id`s are generated by the role ("generation of a
128-bit purely random UUID by the role itself", count=1) in **Pull** mode, or supplied by the
client in **Push** mode; Pull is preferred because in Push mode "some other system" must know the
full credential set, whereas in Pull mode "the SecretID can be kept confidential from all parties
except for the final authenticating client by using Response Wrapping". Response wrapping is the
lane's round-51 subject, not this entry's; the AppRole-specific point is that the page's own
recommended delivery path is a wrapped secret handed to the workload, which is why the accessor
and the TTL matter more than the value's transport.

### The reuse bounds are per-credential, and the role's values are defaults

The API page's phrasing is precise and easy to misread as a role-level switch:
`secret_id_num_uses` is the "Number of times any particular SecretID can be used" (count=1), and
the per-generation `num_uses` parameter "Overrides secret_id_num_uses role option when supplied.
May not be higher than role's secret_id_num_uses" (count=2 — the same sentence is in both the
`secret-id` and the `custom-secret-id` parameter lists). The TTL pair is symmetric:
`secret_id_ttl` is the role default and the per-generation `ttl` "Overrides secret_id_ttl role
option when supplied. May not be longer than role's secret_id_ttl". The role's value is therefore
a **ceiling**, not a setting: an operator cannot issue a longer-lived or more-reusable secret than
the role allows, and a caller who supplies nothing gets the role's value.

The documented defaults are the part that matters in a review. `secret_id_num_uses` defaults to
`0`, which the page defines as "unlimited uses", and `secret_id_ttl` defaults to the empty string,
which the page defines as the SecretID not expiring. A role created without those two parameters
issues permanent, infinitely reusable secrets. The page's own configuration example sets
`secret_id_ttl=10m` and `secret_id_num_uses=40`; the trial's T2/T3 set `1` and `1s` to make the
bound observable inside one run.

One property is documented as irreversible: `local_secret_ids` makes generated secret IDs "cluster
local", "can only be set during role creation and once set, it can't be reset later". That is a
custody decision taken at creation time and not revisitable — `documented, not measured` here,
because the trial runs a single dev server with no cluster.

### The accessor is the custody handle

The accessor is the one value in the system that is designed to be *shown*. The generation
response "will also contain a secret_id_accessor value which can be used to read the properties of
the SecretID without divulging the SecretID itself, and also to delete the SecretID from the
AppRole" (count=1 for each half). The two endpoints are separate on purpose:
`/secret-id-accessor/lookup` is documented as "Reads out the properties of a SecretID" (count=2,
because the same description heads both the `secret-id/lookup` and the `secret-id-accessor/lookup`
sections) and `/secret-id-accessor/destroy` as "Destroy an AppRole secret ID by its accessor"
(count=1). The distinction is that `secret-id/lookup` requires the secret value itself
(`secret_id (string: <required>)`, count=1) while the accessor endpoints require only the handle.

What the page does *not* say is what "properties" contains at read time. Its sample accessor
lookup response carries `cidr_list`, `creation_time`, `expiration_time`, `last_updated_time`,
`metadata`, `secret_id_accessor`, `secret_id_num_uses`, `secret_id_ttl` and `token_bound_cidrs` —
and no `secret_id` field, which is the documented shape of "without divulging the SecretID itself".
Whether `secret_id_num_uses` in that response is the *configured* value or the *remaining* value is
not stated anywhere on either page; the sample shows `0` for a secret created with `num_uses: 50`,
which is consistent with *remaining after the sample login* and with *configured default* both.
T4 measures which one the binary returns, and §Docs-vs-binary keeps the gap.

The accessor also splits the ACL surface. S124's §Read, update, or delete AppRole properties lists
per-field endpoints — `policies`, `secret-id-num-uses`, `secret-id-ttl`, `token-ttl`,
`token-max-ttl`, `bind-secret-id`, `secret-id-bound-cidrs`, `token-bound-cidrs`, `period` — "to be
able to delegate specific endpoints using OpenBao's ACL system". An operator can therefore be
granted the ability to shorten `secret-id-ttl` without being able to write the whole role. That is
a custody-relevant documented fact and it is `documented, not measured` here: the trial runs as a
dev root token and exercises no policy.

### CIDR binding is three layers, and the trial measures one

`secret_id_bound_cidrs` is the login-time source filter. The page states the rule twice, once as a
constraint ("secret_id_bound_cidrs will only allow logins coming from IP addresses belonging to
configured CIDR blocks on the AppRole", count=1) and once as a parameter ("if set, specifies
blocks of IP addresses which can perform the login operation", count=1). Two further layers sit
beside it and are *not* the same control: the per-generation `cidr_list` narrows a single secret
("the list of CIDR blocks listed here should be a subset of the CIDR blocks listed on the role",
count=2), and `token_bound_cidrs` binds the *issued token* rather than the login ("specifies blocks
of IP addresses which can authenticate successfully, and ties the resulting token to these blocks
as well"). `token_strictly_bind_ip` adds a fourth variant and "conflicts with token_bound_cidrs".

T5 measures the role-level layer only. The subset rule, the token-level binding and the
strict-IP variant are `documented, not measured`. This matters for a review because a runbook that
sets `token_bound_cidrs` believing it restricts *login* has set the wrong layer: the login still
succeeds from any source and only the token is pinned.

### User lockout is the confounder this subject has to name

S123 documents a defence that can silently change the observable of every negative test in T1–T5.
"If a user provides bad credentials several times in quick succession, OpenBao will stop trying to
validate their credentials for a while, instead returning immediately with a permission denied
error" (count=1), with defaults "lockout threshold" 5 attempts, "lockout duration" 15 minutes and
"lockout counter reset" 15 minutes (count=1), enabled by default and disableable per mount or
globally via `BAO_DISABLE_USER_LOCKOUT` (count=1). The counter "is reset to zero after a few
minutes without login attempts, or upon a successful login attempt".

The consequence is a measurement hazard, not a curiosity: this is the *only* place either page
names an error string for a refused login, and it is `permission denied`. A trial that makes five
or more failed logins against one role in quick succession will start receiving the lockout
refusal instead of the refusal it is trying to observe, and a trial that classifies refusals by
`permission denied` alone would then pass for the wrong reason.

The trial's exposure is bounded and stated rather than assumed. Its source has exactly one
deliberate failed-login site per test — T1's `role_id`-only attempt, T2's second use of the same
secret, T3's post-expiry attempt, T4's post-destroy attempt and T5's out-of-CIDR attempt — so no
role sees two consecutive failures and the documented threshold of 5 is never approached; each
receipt line shows its own refusal flag at 1 (`aref=1`, `ref2=1`, `expref=1`, `revoked=1`,
`deny=1`), which is consistent with one refusal per test but does not itself count attempts. The
trial neither disables lockout nor measures it. What protects the reading is the classifier:
`named_refusal` requires the *specific* text (`missing secret_id`, `invalid role or secret ID`, or
the CIDR text), so a lockout-induced `permission denied` would make the test read BROKEN rather
than silently pass. The lockout itself — its threshold, duration and reset — is
`documented, not measured`.

## Mechanics (measured, round 60 — OpenBao 2.7.2 dev server, 127.0.0.1, approle)

Executed by `corpus/openbao-approle-trial.sh` (round 60): a throwaway `bao server -dev` bound to
127.0.0.1 under `setpriv --pdeathsig KILL`, in-memory storage, a per-run dev root token delivered
through the environment, and `bao` resolved through PATH only. The credential values (`role_id`,
`secret_id`) and every login and secret-id request body travel as JSON on **stdin**, never on argv
and never printed; only non-secret role configuration fields (`bind_secret_id`,
`secret_id_num_uses`, `secret_id_ttl` and the CIDR lists) are passed as `k=v` arguments to `bao
write`. Receipts:
`.ufo/waves/round-60/build/R60ExecTrial/receipt-ref-real.txt` and `receipt-ref-real2.txt` (two
independent runs), the five shim runs `receipt-shim-SH1.txt`–`receipt-shim-SH5.txt`, the
fail-closed leg `receipt-none.txt`, and the fixture-driven `receipt-selftest.txt`. The lines below
are quoted from the real-run receipts; no number in this table comes from a page.

| # | mechanic | measured on 2.7.2 | receipt line |
|---|---|---|---|
| T1 | `bind_secret_id` decides whether `role_id` alone authenticates | the role was created with `bind_secret_id=true` plus `token_bound_cidrs=127.0.0.1/32` (the constraint that satisfies the server's at-least-one rule, §Docs-vs-binary D7); a login carrying only `role_id` was refused with the server's `missing secret_id`; `POST auth/approle/role/r60-t1 {"bind_secret_id":false}` on the same role succeeded; the identical `role_id`-only body then returned a token | `TRIAL T1 HOLDS aref=1 upd=1 ctok=1` |
| T2 | `secret_id_num_uses` bounds credential reuse | with the role at `secret_id_num_uses=1`, the first login with a generated secret returned a token; a second login with the same secret was refused with `invalid role or secret ID`; a freshly generated secret logged in | `TRIAL T2 HOLDS first=1 ref2=1 fresh=1` |
| T3 | `secret_id_ttl` retires an unwrapped `secret_id` | with the role at `secret_id_ttl=1s`, a freshly generated secret logged in immediately; after a 3 s wait the same secret was refused with `invalid role or secret ID`; a newly generated secret logged in. Both the immediate and the post-expiry legs allow up to three attempts, each with a **newly generated** secret, because a 1 s TTL is shorter than a `bao`/`python3` round trip under load (see §Bounds) | `TRIAL T3 HOLDS imm=1 expref=1 fresh=1` |
| T4 | the accessor is a non-secret custody handle | on a role at `secret_id_num_uses=3 secret_id_ttl=600s`, `secret-id-accessor/lookup` returned a body carrying `secret_id_num_uses` and `secret_id_ttl` (both non-empty) and no `secret_id` key, and the secret's own value was not a substring of the response; `secret-id-accessor/destroy` on a still-valid, unused secret then made that secret's login fail with `invalid role or secret ID` | `TRIAL T4 HOLDS meta=1 cust=1 revoked=1` |
| T5 | `secret_id_bound_cidrs` pins a credential to a source range | with the role bound to `10.0.0.0/8`, a login from 127.0.0.1 was refused with a source-address error; after rebinding the same role to `127.0.0.1/32`, the **same** `role_id`+`secret_id` body — no fresh secret — returned a token | `TRIAL T5 HOLDS deny=1 upd=1 allow=1` |

Both runs end `OPENBAO_APPROLE_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` and exit 0, and
the two receipt files are byte-identical (sha256
`506a44a2a2cc89878c26a98d71f43b49c3cabacfc94a61aa896565c868c49c8d`), so every row above is
backed twice by the same bytes. The five `TRIAL` lines appear exactly once each per run.

The refusal texts the rows quote are the trial's slugs of the server's error text, not the server's
bytes: `aerr=missing-secret-id` is the slug of `missing secret_id`, and
`invalid-role-or-secret-id` is the slug of `invalid role or secret ID`. The unslugged texts are in
the L1 feasibility probe `.ufo/waves/round-60/final/l1-probe.txt` (`T1 login role_id only
(bind=true): http=400 err=missing secret_id`; `T2 second login: http=400 err=invalid role or
secret ID`; `T4 login after destroy: http=400 err=invalid role or secret ID`), which is an
independent measurement by a different seat on a different dev server. The T5 slug is truncated at
the trial's 48-character limit (`source-address-127-0-0-1-unauthorized-by-cidr-re`), so the receipt
itself does not show the tail of the server's message; the probe does, and §Docs-vs-binary D6
records it.

The five shims each flip exactly their designated test and nothing else, and each shim run exits 1
with `holds=4 broken=1 error=0`:

| shim | receipt line that moved | vector |
|---|---|---|
| SH1 | `TRIAL T1 BROKEN aref=1 upd=1 ctok=0 aerr=missing-secret-id berr=` | `BHHHH` |
| SH2 | `TRIAL T2 BROKEN first=1 ref2=0 fresh=1 err2=invalid-role-or-secret-id` | `HBHHH` |
| SH3 | `TRIAL T3 BROKEN imm=1 expref=0 fresh=1 err=invalid-role-or-secret-id` | `HHBHH` |
| SH4 | `TRIAL T4 BROKEN meta=1 cust=1 revoked=0 err=invalid-role-or-secret-id` | `HHHBH` |
| SH5 | `TRIAL T5 BROKEN deny=1 upd=1 allow=0 err=source-address-127-0-0-1-unauthorized-by-cidr-re` | `HHHHB` |

What a shim proves has to be stated precisely, because it is weaker than it looks: the shim is a
`KAGI_APPROLE_SHIM` value that makes the trial force its own designated flag to `0`
(`shim_flip "$SHIM" 1 ctok && ctok=0` in T1, and the same shape in T2–T5). It therefore
demonstrates that each test's verdict is computed from its own flag and that flipping one flag
changes exactly one test's verdict — a **verdict-mapping** falsifier. It does not simulate a
different binary response, so it cannot by itself distinguish *the binary held* from *the trial
read the binary's answer into the wrong flag*; that distinction rests on the two real runs, the L1
probe and the sentinel's independent probe, not on the shims.

A PATH with no `bao` prints `OPENBAO_APPROLE_TRIAL: SETUP no bao on PATH` and exits 2 with no
`TRIAL` line (`receipt-none.txt`), so the trial is not silently scoring a missing binary. The
fixture-driven `--selftest` (no `bao`, no network) prints `APPROLE_SELFTEST: PASS (cases=45)` and
exits 0; the mutated copy whose shim resolution is broken prints
`FINDING F-SHIM-MATRIX` / `APPROLE_SELFTEST: FAIL (cases=45 failed=1)` and exits 1
(`receipt-selftest-mutant.txt`), so the selftest can fail with a named finding id.


## Custody: which half is the secret, what bounds it, and what revokes it

**The secret half is `secret_id`.** The page's own sentence is unconditional — it "is intended to
always be secret" (count=1) — while `role_id` is defined by function, as the identifier "that
selects the AppRole against which the other credentials are evaluated" (count=1). The page's
qualification that unique RoleIDs "serve as secondary secrets" (count=1) is a statement about
*uniqueness*, not about custody: a value being unguessable does not make it a secret the operator
must protect, and the trial's T1 is the discrimination — with `bind_secret_id=false` the same
`role_id` authenticates with no second value at all, so its secrecy was never the control.
Operationally: bake `role_id` into the image, treat `secret_id` as a credential with a lifetime.

**What bounds reuse is per-credential, ceilinged by the role.** Two role parameters set the
ceiling — `secret_id_num_uses` (default `0`, documented as "A value of zero will allow unlimited
uses", count=3) and `secret_id_ttl` (default empty, documented as "A value of zero will allow the
SecretID to not expire", count=3) — and the per-generation `num_uses` / `ttl` may only narrow
them: "May not be higher than role's secret_id_num_uses" and "May not be longer than role's
secret_id_ttl" (each locates count=2, once in each generation parameter list). A role left at its
defaults therefore issues credentials that never expire and never run out; the bound is a
deliberate act, not a default. The trial's T2 and T3 set the ceiling to `1` and `1s` so that the
bound is observable inside one run; §Mechanics records what the binary did at the boundary and
§Docs-vs-binary records where the page's wording ("will expire") is narrower than the observed
state. Whether the *default* behaves as documented is `documented, not measured` (§Docs-vs-binary
D9): no test creates a role at the defaults.

**A non-secret handle revokes it.** `secret_id_accessor` is returned beside the secret at
generation and is documented as usable "to read the properties of the SecretID without divulging
the SecretID itself, and also to delete the SecretID from the AppRole" (count=1 for each half).
`/secret-id-accessor/destroy` takes only `secret_id_accessor` (count=2 for the parameter line,
once per accessor endpoint) and is documented as destroying "an AppRole secret ID by its
accessor" (count=1). This is the custody primitive: an operator who has never seen the secret can
enumerate it, read its recorded use-count and TTL fields and kill it, so revocation does not
require the secret to be escrowed anywhere. What the page does not state, and this entry does not
claim as documented, is whether an accessor can itself authenticate (neither page says it can, and
the login parameter list names only `role_id` and `secret_id`); the trial does not test that, so it
stays a named bound rather than a measured line.

Two documented custody hazards belong here rather than in §Bounds. First, `metadata` on a
SecretID "will be set on tokens issued with this SecretID, and is logged in audit logs in
plaintext" (count=2, once per generation endpoint): metadata is a *non-secret* field by design, so
a runbook that puts a host credential or a ticket number there has published it into the audit
device. Second, `local_secret_ids` is irreversible ("can only be set during role creation and once
set, it can't be reset later", count=1): a role created cluster-local cannot later be widened, so
the decision is made once, at creation, and `documented, not measured` here because the trial runs
one dev server with no cluster.

The delivery path the page recommends is response wrapping — in Pull mode "the SecretID can be
kept confidential from all parties except for the final authenticating client by using Response
Wrapping" (count=1) — which is the lane's round-51 subject, not this entry's; the AppRole-specific
consequence is that the wrapped secret is still a `secret_id` with the same reuse bounds, so the
TTL and use count are what limit the window after unwrapping.

## Docs-vs-binary (what the page says and what the run shows)

These rows are the places where a page sentence and the executed run pull apart, or where the
page is narrower than what the trial had to do. The binary side of each row cites a receipt line
from `.ufo/waves/round-60/build/R60ExecTrial/`, or — where the trial's receipt does not carry the
fact — the L1 feasibility probe `.ufo/waves/round-60/final/l1-probe.txt` or the sentinel's
independent probe `.ufo/waves/round-60/build/R60SentinelTrial/probe-groundtruth.txt`, named as
such. The page side cites a located quote from the capture named in the previous section.

| # | topic | page says | run shows | reading |
|---|---|---|---|---|
| D1 | whether `secret_id` is required at login | S124's §Login with AppRole parameter list states `secret_id (string: <required>) - SecretID belonging to AppRole` (count=1) unconditionally, while the same section's prose says "role_id is always required; if bind_secret_id is enabled (the default) on the AppRole, secret_id is required too" (count=1) | T1: with `bind_secret_id=true` the `role_id`-only body was refused `missing secret_id`; after the same role was updated to `bind_secret_id=false`, the identical body returned a token (`TRIAL T1 HOLDS aref=1 upd=1 ctok=1`) | the page contradicts itself and the run settles it: `secret_id` is *conditionally* required. The parameter table is the narrower reading; a client generated from it will always send a secret, even where none is required. |
| D2 | what "expire" means for a spent `secret_id` | S124: "Number of times this SecretID can be used, after which the SecretID expires" (count=2) and "after which the SecretID by default will expire. A value of zero will allow unlimited uses" (count=1); neither page says whether a spent secret is deleted, retained-but-refused, or still visible to an accessor lookup | T2: the second login with a `secret_id_num_uses=1` secret was refused `invalid role or secret ID`, and a fresh secret logged in (`TRIAL T2 HOLDS first=1 ref2=1 fresh=1`). The trial takes no accessor lookup on the spent secret, so the receipt cannot say whether it still exists | the page's "expire" is observable only as a login refusal whose text is identical to an unknown credential's. *Expired*, *destroyed* and *never existed* are indistinguishable from the login endpoint — which is the right design and is *not* what the page's word "expire" suggests. The post-expiry enumerability stays unmeasured. |
| D3 | the semantics of `secret_id_num_uses` in an accessor lookup | S124's accessor-lookup sample response carries `secret_id_num_uses` and `secret_id_ttl` but no sentence says whether they are the configured values or the remaining budget; the sample shows `0` for a secret created with `num_uses: 50`, which is consistent with both readings | T4's lookup ran on a role at `secret_id_num_uses=3 secret_id_ttl=600s` **before any login**, and returned both fields non-empty (`TRIAL T4 HOLDS meta=1 cust=1 revoked=1`) | the page is ambiguous and the trial does **not** resolve it: with no login yet, *configured 3* and *remaining 3* predict the same number. The receipt establishes presence and a positive value, not which quantity it is. `documented, not measured` for the "remaining" reading. |
| D4 | the refusal text for each negative login | neither page names a credential refusal. The only named login error on either page is the lockout sentence, "OpenBao will stop trying to validate their credentials for a while, instead returning immediately with a permission denied error" (count=1); `invalid role or secret ID`, `invalid secret id` and `missing secret_id` each locate `count=0` on both captures | T1 refused with `missing secret_id`; T2, T3 and T4 refused with `invalid role or secret ID` (the trial's slugs `missing-secret-id` and `invalid-role-or-secret-id` in the receipts; the unslugged texts are in `l1-probe.txt`) | the page is narrower: every refusal this entry reports is measured, not documented, and the one documented refusal text (`permission denied`) belongs to the lockout confounder, not to a credential error. A trial that classified refusals by `permission denied` would pass for the wrong reason. |
| D5 | the state of an accessor after a destroy | S124 documents `Destroy an AppRole secret ID by its accessor` (count=1) and nothing about the accessor's own subsequent state; `not found`, `destroyed` and `deleted` each locate `count=0` on both captures | T4: after `secret-id-accessor/destroy` the still-valid secret's login failed `invalid role or secret ID` (`revoked=1`). The trial performs no accessor lookup after the destroy. The sentinel's probe does, and reads HTTP 404 on the accessor lookup (`probe-groundtruth.txt` §D) | the destroy's effect on the **secret** is measured; the accessor's own post-destroy state is measured only by the non-author probe. The page's silence is the gap: an operator writing a *revoke then verify* runbook has no documented second step. |
| D6 | the refusal text for a CIDR-bound login | S123: "secret_id_bound_cidrs will only allow logins coming from IP addresses belonging to configured CIDR blocks on the AppRole" (count=1); `source address` and `not permitted` each locate `count=0` on both captures | T5's refusal matched the trial's `unauthorized by CIDR|CIDR restrictions` pattern (`deny=1`); the receipt's slug is truncated at 48 characters (`err=source-address-127-0-0-1-unauthorized-by-cidr-re`). The full text, from `l1-probe.txt`, is `source address "127.0.0.1" unauthorized by CIDR restrictions on the role: %!w(<nil>)` | the page states the rule and not the observable, and the measured text carries a Go formatting defect: `%!w(<nil>)` is an unformatted error verb, not a message. A runbook that matches a clean sentence will not match this string, and a log consumer that parses it will see a broken tail. This is the sharpest page-vs-binary gap in the round. |
| D7 | the *at least one constraint* rule | S124: "It is required to have at least one of them enabled while creating or updating a role" (count=1) — "them" being the role's constraints, with no list of which parameters count | T1's role was created with `token_bound_cidrs=127.0.0.1/32` and the later `{"bind_secret_id":false}` update succeeded (`upd=1`); the L1 probe §A4 reproduces it. The sentinel's probe measured the complement: `bind_secret_id=false` **alone** is refused HTTP 500 `at least one constraint should be enabled on the role` (`probe-groundtruth.txt` §A/§B/§C) | the page does not enumerate "them", and the binary's answer is that a role-level CIDR constraint satisfies the rule while `bind_secret_id=false` alone does not. This is why T1's setup carries `token_bound_cidrs`, and it is the one place where the trial's own setup is a documented rule the page states only in outline. |
| D8 | whether an accessor can authenticate | neither page says an accessor cannot be used at the login endpoint; the login parameter list names only `role_id` and `secret_id` (count=1 each) | not measured — the trial never presents an accessor at `/auth/approle/login` | a page gap this entry deliberately leaves open: §Custody's *non-secret handle* claim rests on the documented purpose and on the measured destroy behaviour, not on a measured login refusal. A future round can close it with one request. |
| D9 | the `secret_id_ttl` and `secret_id_num_uses` defaults | S124 gives `secret_id_num_uses (integer: 0)` and `secret_id_ttl (string: "")`, with "A value of zero will allow unlimited uses" (count=3) and "A value of zero will allow the SecretID to not expire" | no test creates a role at the defaults: T2 sets `1`, T3 sets `1s`, T4 sets `3` and `600s` | `documented, not measured`. The operational point — a role created without these two parameters issues credentials that never expire and never run out — is the page's, not this run's. |
| D10 | the page's own `curl` examples and the request content type | S123's API examples pass `--data '{"type": "approle"}'` and `--data '{"policies": ...}'` with only an `X-Vault-Token` header; no example sets `Content-Type: application/json` | the trial never exercises this: every request goes through the `bao` CLI, which sends JSON, and the trial's header records that as the rule it relies on. `plans/round-60.md` §A3 item 2 asserts — quoting the plan, not a page — that a form-encoded body "parses as empty: role creation returns 204 with defaults and every login reads 400 invalid role or secret ID", but the receipt that amendment cites (`l1-probe.txt`) contains no form-encoded leg | the page's example is narrower than a working client: copied verbatim, `curl --data` sends `application/x-www-form-urlencoded`. This entry does **not** claim the failure as measured, because the cited receipt does not show it; the assertion is flagged in `.ufo/waves/round-60/build/R60ScribeEntry/notes.md` as a record gap for the L1. |
| D11 | when the role's CIDR binding is evaluated | S124 describes the role parameter as blocks "which can perform the login operation" (count=1) and the per-generation `cidr_list` as "enforcing secret IDs to be used from specific set of IP addresses" (count=2); neither page says whether a role-level rebind applies to secrets that were already issued | T5 reuses the **same** `role_id`+`secret_id` body after the role is rebound from `10.0.0.0/8` to `127.0.0.1/32`, and it logs in (`TRIAL T5 HOLDS deny=1 upd=1 allow=1`) | the role binding is evaluated at **login time**, not frozen into the secret at generation, so a rebind retroactively governs every outstanding secret. The page's login-time language is consistent with this but never states it; the reverse direction (a rebind that excludes a working source) is not measured. |

### Page gaps the trial had to measure (absence checks, this seat's counts)

The strings below are what a reader would expect to find if the pages documented the observable.
Each locates `count=0` on both captures except where noted; the last column names the measured row
that fills the gap. The full table with both per-capture counts is
`.ufo/waves/round-60/build/R60ScribeEntry/quote-locations.md` §Absence checks.

| gap | page does not state | absence check | measured row that fills it |
|---|---|---|---|
| G1 | the refusal for a login carrying only `role_id` while `bind_secret_id=true` | `invalid role or secret ID` 0/0, `missing secret_id` 0/0, `invalid role` 0/0 | T1 (`missing secret_id`) |
| G2 | what a spent `secret_id` returns at login | `expired` 0/0, `invalid secret id` 0/0 | T2 (`invalid role or secret ID`) |
| G3 | what an expired `secret_id` returns at login | `expired` 0/0 | T3 (`invalid role or secret ID`) |
| G4 | whether an accessor lookup exposes the secret value | no absence check needed: S124's accessor-lookup sample carries no `secret_id` field, and the page's promise is "without divulging the SecretID itself" (count=1) | T4 (`cust=1`) |
| G5 | whether a destroy-by-accessor invalidates a still-valid secret | `not found` 0/0, `destroyed` 0/0, `deleted` 0/0 | T4 (`revoked=1`) |
| G6 | the refusal for a login from outside the bound CIDR | `source address` 0/0, `not permitted` 0/0 | T5 (`deny=1`) |
| G7 | whether the accessor lookup's use count is remaining or configured | `remaining` 0/0, `uses remaining` 0/0, `no uses` 0/0 | T4 (`meta=1`) — presence only, see D3 |
| G8 | whether a spent or destroyed secret remains enumerable | `revoke` 0/0, `deleted` 0/0 | **no receipt line** — the trial takes no lookup after a spend or a destroy; `documented, not measured` |
| G9 | which parameters satisfy the at-least-one-constraint rule | `at least one constraint` 0/0, `constraint should be enabled` 0/0 | T1's setup plus the sentinel probe (D7) |
| G10 | the request content type the API requires | `Content-Type` 0/0, `application/json` 0/0 on both captures | **no receipt line** — see D10 |

## Bounds (does not establish)

- One binary (OpenBao 2.7.2), one host, one throwaway `bao server -dev` bound to 127.0.0.1 under
  `setpriv --pdeathsig KILL` per run, in-memory storage, a per-run dev root token delivered through
  the environment. No seal/unseal, no HA, no performance replication, no namespaces, no listener
  tuning, no audit device enabled during the run.
- One mount: AppRole at its default `approle/` path. A mount at another path changes the endpoint
  prefix only (`The default path is /approle`, count=1) and is not exercised.
- **The `bind_secret_id=false` leg is a deliberate unsafe configuration**, made only on a
  throwaway dev server and only on a dedicated role (`r60-t1`) that no other test uses, so the
  unsafe setting never touches the roles T2–T5 depend on. It is a measurement of what the flag
  does, not a recommendation; a production role with `bind_secret_id=false` and no other
  constraint is refused outright (D7), and one with another constraint is a one-credential login.
- **T3's `1s` TTL is shorter than a CLI round trip under load, and the trial retries.** Both T3
  immediate legs allow up to three attempts, each with a newly generated secret, and the executor
  recorded one battery run that read `T3 BROKEN imm=1 expref=1 fresh=0` before the retry was
  added: the fresh secret had expired between generation and login. The retry does not change the
  mechanic (a fresh secret logs in; an expired one does not), but it means the receipt's
  `imm=1`/`fresh=1` is *one of at most three attempts succeeded*, not *the first attempt
  succeeded*. A TTL this short is not a usable production bound; the trial uses it to make expiry
  observable inside one run.
- **The CIDR rebind is measured in one direction only.** T5 goes from a binding that excludes
  127.0.0.1 to one that admits it, and the already-issued secret then logs in. The reverse — a
  rebind that excludes a source, invalidating a secret that was working — is not measured, and
  neither is the per-generation `cidr_list` subset rule.
- **Proxy and CIDR interactions are unmeasured.** T5 sends its login from 127.0.0.1 and binds
  `10.0.0.0/8` then `127.0.0.1/32`; it does not place a proxy, a load balancer or an
  `X-Forwarded-For`-rewriting hop between the client and the listener, does not test whether the
  evaluated source address is the socket peer or a forwarded header, and does not test IPv6 or a
  dual-stack listener. The per-generation `cidr_list` subset rule, `token_bound_cidrs` and
  `token_strictly_bind_ip` are `documented, not measured`.
- **The user-lockout interaction is bounded, not eliminated.** The trial neither disables nor
  measures lockout: it makes one deliberate failed login per role (see §User lockout), and its
  refusal classifier demands the specific credential or CIDR text, so a lockout refusal would read
  BROKEN rather than pass. It does not measure the lockout's threshold, duration or reset, and it
  does not establish that the mount's counter never approached the threshold.
- **Push mode, custom secret IDs and `local_secret_ids` are unmeasured.** Every secret in the run
  is Pull-mode generated by the role; `custom-secret-id`, the `metadata` field, `token_num_uses`,
  `token_ttl`/`token_max_ttl`/`token_period`/`token_type` and the per-field
  `secret-id-num-uses`/`secret-id-ttl`/`bind-secret-id` endpoints are documented and not exercised.
- **Response wrapping, token renewal and the issued token's own bounds are unmeasured.** The trial
  asserts that a token is issued and (where a test needs it) that a login is refused; it does not
  renew, revoke or inspect a token's policies, and it enables no audit device, so the
  "logged in audit logs in plaintext" sentence is documented and not observed here.
- **One page label.** Both pages say Version 2.7.x; a later release can change any rule above, and
  the `recheck:` line is the clock that would notice.

## Falsifiers

Each line names an observation that would break the measured claim it sits under.

- T1: a login carrying only `role_id` that succeeds while the role still has the default
  `bind_secret_id=true`; or a login carrying only `role_id` that is still refused after
  `bind_secret_id=false` on the same role; or a `bind_secret_id=false` login that returns no
  token. Any of these breaks "the flag, not the credential, decides whether `role_id` alone
  authenticates".
- T2: a second login with a `secret_id_num_uses=1` secret that succeeds; or a first login that is
  refused; or a freshly generated secret that cannot log in (which would mean the refusal was the
  role or the lockout, not the use count). A refusal that carries the lockout text rather than a
  credential error would break the attribution, not the mechanic.
- T3: a `secret_id_ttl=1s` secret that still logs in after the wait; or one that is refused
  *before* the wait (which would mean the TTL was already spent by the first login); or a fresh
  secret that is refused after the wait (which would mean the role expired, not the credential).
  Because the immediate legs retry up to three times, the falsifying observation is all three
  attempts failing — a single failed attempt is the recorded latency flake, not a broken mechanic.
- T4: an accessor lookup that returns the `secret_id` value itself; an accessor lookup that
  returns no use-count or TTL field; a destroy-by-accessor after which the secret still logs in; a
  destroy that removes the accessor but leaves the secret usable. Also: an accessor lookup that
  still returns metadata after the secret has been destroyed (the non-author probe reads 404 at
  that point, so a 200 would break the reading).
- T5: a login from 127.0.0.1 succeeding while the role is bound to `10.0.0.0/8`; or the same login
  refused while the role is bound to `127.0.0.1/32`; or a refusal whose text is the credential
  error rather than a source-address error (which would mean the CIDR was never evaluated).
- Accessor semantics: an accessor that authenticates at `/auth/approle/login` (which would make
  the *non-secret* handle a credential and break §Custody's central claim).
- Bounds: any claim here that a proxy hop, an IPv6 source, Push mode, `local_secret_ids`, an audit
  device, token renewal or a non-default mount was exercised by this round.

SEAT-STATUS: complete
