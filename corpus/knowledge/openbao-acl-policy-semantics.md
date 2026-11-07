# OpenBao ACL policy authorization: deny is the default, `*` only ends a path, `+` spans one segment, a deny outranks the other capabilities, and same-pattern policies union

source: S118 (https://openbao.org/docs/concepts/policies/, the page introduction — the
  deny-by-default sentence; §Policy syntax — the exact/`*`/`+` examples, the priority-rules
  warning and the canonicalization warning; §Capabilities — the `deny` bullet, the `sudo`/`scan`
  bullets and the list/scan prefix paragraph; §Templated policies → §Examples; §Fine-grained
  control; §Path expiration; §Filtering list or scan results; §Parameter constraints; §Built-in
  policies → §Default policy and §Root policy; §Root protected API endpoints; §Tokens; OpenBao
  docs Version 2.7.x, opened 2026-11-07); S119 (https://openbao.org/docs/commands/policy/,
  §Examples and §Usage; Version 2.7.x, opened 2026-11-07)
verified-at: 2026-11-07 (both pages fetched as decoded bodies and read as rendered text; every quote below is located at `count=1` by `python3 corpus/rendered-text-v1.py locate <capture> QUOTE`; capture bytes and digests below)
recheck: on-release — on an OpenBao release, re-open S118 §Policy syntax and §Capabilities and S119 §Usage, compare the docs "Version" label to 2.7.x, and re-run `bash corpus/openbao-policy-trial.sh --work <scratch dir>` against the new binary
Reverify: R21-02
cites: S120
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the page or run OpenBao; `recheck:` is the content clock, the executed trial named in the recheck line is the behaviour check.)

Scope: OpenBao 2.7.2 only, the KV secrets engine version 2 at the dev server's default
`secret/` mount, and the ACL policy layer as the pages describe it. Nothing here is a Vault fact
extended to OpenBao or the reverse, and nothing here is a deployment: the token, the policy and
the path are the whole system under test. The five mechanics in the table are the *documented*
rules, each with a located quote; the executed check for them is
`corpus/openbao-policy-trial.sh` (round 58), whose receipts carry the verdicts. This entry
asserts no measured result — the round-58 wave's trial receipts, not this prose, are the
behavioural evidence.

## Why it matters for secrets operations

A token's whole authority is the ACL that matches its request path, and five small rules
generate most production surprises. An allow written on `secret/foo` does not cover
`secret/foo/bar`, so a policy meant to read one mailbox secret silently fails on the nested key;
a `*` placed anywhere but the end of the path is not a glob at all, so a policy that looks like
a tree grant can be an exact-match grant; a `deny` beats the other capabilities, so a broad tree
allow plus a narrow deny is a hole-making pattern rather than a safety net; a `+` is bounded to
one segment and is not an alias for `*`; and when two policies match the same pattern their
capabilities union while two *different* matching patterns hand the decision to one winner, so
attaching one more policy is not a monotone grant. On KV v2 the paths also carry the engine's
own route segments (`data/` for values and versions, `metadata/` for listing), so a policy can
allow the value and still refuse the directory that finds it.

## Documented mechanics (S118/S119, Version 2.7.x, opened 2026-11-07)

Captures, fetched for this round from the same two pages the scout opens:
`.ufo/waves/round-58/build/R58ScribeEntry/capture/S118.body`, decoded body sha256
`a55ff1a4caf12c3a62bcaab61ff95fef1d382cba01da5dbd4521dbfbca6e1468` (122498 B), rendered-text-v1
sha256 `9e6355bb51a3f6385c1345f0e2162dc10de8e46fd61110d7f41e195e38173292` (34984 B); and
`.ufo/waves/round-58/build/R58ScribeEntry/capture/S119.body`, decoded body sha256
`0472f29373a98f6dd1260aa6ca4d1bd80de9d4642a75c8df94bd22e47e0263e7` (32520 B), rendered-text-v1
sha256 `b0dbef2282defcfbafe1bff9553f5c10cdd637b880e654d77a5f34b364a725f1` (1826 B). The
normalizer is the one declared in `corpus/rendered-text-v1.py`; it replaces every HTML tag with
a space, so a quote that spans an inline `<strong>`, `<code>` or `<a>` shows the space in the
located text, and each quote below sits inside a plain-text run wherever a tag boundary would
otherwise fall inside it.

| # | mechanic | documented rule (anchor, located quote) | what the executed trial asserts (frozen in `plans/round-58.md` §C2) |
|---|---|---|---|
| T1 | deny by default, and an exact path reaches only itself | page introduction (before §Policy-authorization workflow): "Policies are deny by default"; "so an empty policy grants no permission in the system"; §Policy syntax, the read-only example says of a `read`-only token on `secret/foo` that "the token cannot update or delete" it, and an exact grant on `secret/foo` gives a token that "an attached token cannot read \"secret/food\"". | A token whose attached policies grant nothing on a KV v2 data path is refused (403 `permission denied`) there; a token granted `read` on a path reads it and is refused an update on the same path. |
| T2 | `*` is a prefix glob only as the last character of the path | §Policy syntax, the danger box: "It is not a regular expression and is only supported as the last character of the path"; the documented example grants `secret/bar/*` and reads `secret/bar/zip` and `secret/bar/zip/zap` "but not \"secret/bars/zip\"". | A `secret/data/bar/*`-granted token reads both descendants and is refused the sibling `bars`; an exact grant on `secret/data/food` reads it and is refused a longer name that shares its prefix. |
| T3 | a deny takes precedence over the other capabilities at the matching pattern | §Capabilities, `deny` bullet: "This always takes precedence regardless of any other defined capabilities"; the bullet continues "including sudo". | A token carrying a broad allow and a narrower `deny` stanza is refused at the denied path and allowed elsewhere. |
| T4 | `+` is bounded to one path segment | §Policy syntax: a `+` "can be used to denote any number of characters bounded within a single path segment", with the examples `secret/+/teamb` and `secret/+/+/teamb`. | `secret/data/+/teamb` allows exactly one intermediate segment, refuses two segments, and refuses zero. |
| T5 | same pattern in several policies unions; different patterns take one highest-priority match | §Policy syntax, the warning note: "we take the union of the capabilities"; "we take only the highest-priority match from those policies". | Same pattern split across two policies: `read` from one and `update` from the other both work and `delete` stays refused. Different patterns: an exact `update` outranks a glob `read`, so the read is refused and the update works. |

### The five priority rules (documented, §Policy syntax)

The page states the tie-break as a numbered comparison of two matching patterns `P1` and `P2`,
applied in order: the pattern whose first wildcard (`+`) or glob (`*`) occurs earlier is lower
priority; a pattern ending in `*` is lower than one that does not; a pattern with more `+`
segments is lower; a shorter pattern is lower; and a lexicographically smaller pattern is lower.
Its own worked example puts `secret/*` above `secret/+/+/foo/*` by the third rule. These rules
are the machinery behind T5's second half, and they are why reading a narrower-looking pattern
as the automatic winner is wrong: priority is positional, not semantic.

### `sudo` and `scan` are documented here, measured elsewhere

`sudo` "Allows access to paths that are root-protected" and S118 §Root protected API endpoints
lists which paths need it (audit enable/disable, `sys/raw`, remount, rotate, seal, and others).
`scan` "Allows recursively listing (\"scanning\") values at the given path" and carries the same
warning as `list`: the keys returned are not filtered by policies, so a key name is not a
secret. Neither capability is measured by the round-58 trial: both need a root-protected path or
a recursive-list backend, which is outside the trial's five tests and is listed under §Bounds.

## KV v2 path mapping (the lane's mapping, not a page quote)

Under KV v2 the policy path is not the logical key path: the engine owns two route prefixes
under the mount, and the policy must name them. The lane's mapping is:

- `secret/data/<name>` — create, read, update, patch, delete of a value and its versions. This
  is the half the round-58 trial exercises: its test policies name `secret/data/...` paths only.
- `secret/metadata/<name>` — `list` of the keys under the mount (and the metadata operations
  that are not part of the five tests). The page's templated example writes it this way, but the
  trial has no `list` test, so on the lane's own evidence this half is documented-by-example and
  **not measured**.

S118 §Templated policies → §Examples corroborates the split without stating it as a rule: its own
KV v2 template grants the value capabilities on `secret/data/{{identity.entity.id}}/*` and
`list` on `secret/metadata/{{identity.entity.id}}/*`. That is an example on a templated-policy
page, so it is evidence of how OpenBao's own authors write a KV v2 ACL, not a sentence that
defines the mapping; the executed half of the mapping is the trial's business. The sibling entry
`corpus/knowledge/openbao-kv-v2-version-lifecycle.md` covers what the version operations do once
the path is reached; this entry covers only which path an ACL has to name to reach it.

Three documented consequences sit around that mapping:

- Listing is a prefix operation. §Capabilities: "listing always operates on a prefix" and, in
  the same paragraph, "OpenBao will sanitize request paths to be prefixes", so a `list` grant is
  matched against a prefix even when the author wrote a key path.
- Parameter constraints do not apply at KV v2. §Parameter constraints warns that
  `allowed_parameters`, `denied_parameters` and `required_parameters` "are not supported for
  policies used with the version 2 kv secrets engine"; the page's parameter examples are KV v1
  paths. A KV v2 policy that relies on a parameter allow-list has no such control.
- ACL paths are not canonicalized. §Policy syntax warns to "Ensure that any path segments refer
  to an engine's canonicalized variants": inbound request paths are canonicalized before the ACL
  check, the paths written in the ACL are not, so a case-different segment in a policy is a
  silent mismatch rather than an error.

## Operational notes from the same pages

- **A deleted policy acts as an empty policy** (S120, §Delete ACL policy): "A deleted policy set on a token acts as an empty policy". This is the API-side form of T1's consequence — the token keeps working and keeps no access on the paths only that policy granted; deleting the policy is not the same act as revoking the token.
- **A policy update is immediate** (S120, §Create/Update/Patch ACL policy): "Once a policy is updated, it takes effect immediately to all associated users". Documented, not measured by the trial: no test here watches a live token's capabilities change after a policy write.


- A policy name is "the policy's name as a pointer or symlink to its set of rules"; the rules are
  re-read per request, because "the contents of policies are parsed in real-time whenever the
  token is used". An edited policy is live for already-issued tokens — but "There is no way to
  modify the policies associated with a token once the token has been issued.", so changing the
  *policy set* needs a new token while changing a *policy's contents* does not.
- Upload is `bao policy write <name> <file>` (S118 §Creating policies; S119 §Usage lists the
  subcommands, "Uploads a named policy from a file"). `bao policy read` prints the stored
  policy ("Prints the contents of a policy"), and delete is idempotent — "This is an idempotent
  operation." — so a delete of an absent policy is not an error.
- Deny-by-default is not the same as a token with no capabilities. §Default policy: the
  built-in `default` policy "cannot be removed" and "By default, it is attached to all tokens";
  it ships grants for self-lookup and cubbyhole, and the page says OpenBao is not prescriptive
  about its contents. A 403 on a KV path is therefore a statement about that path, not about the
  token having zero capabilities.
- The `root` policy is unremovable and its holder "A root user can do anything within OpenBao.";
  root users alone may attach policies a token's parent does not hold, and the page recommends
  revoking root tokens after setup.
- Capabilities follow the HTTP verb, not the effect: "Capabilities usually map to the HTTP verb,
  and not the underlying action taken." Generating database credentials is a `GET` and therefore
  a `read`. For KV v2 the verb split also means `create`/`update` are near-synonyms — the page
  says very few parts distinguish them, and most operations need both.
- A `list` grant returns key names the token cannot read. §Filtering list or scan results: "By
  granting list or scan capabilities on a path, all results are returned from the plugin",
  "including entries which correlate to paths the token cannot access". The documented way to
  narrow that is the `list_scan_response_keys_filter_path` parameter, whose own example is a KV
  v2 `metadata/` path and whose effect the page describes as restricting the results to "only
  visible entries". Without it, a policy that grants `list` on `secret/metadata/*` discloses the
  key names under the mount whether or not the value paths are readable.
- A path grant can expire. §Path expiration: "Specific paths in a policy can be set to
  automatically remove access at a point in time." — the `expiration` field (RFC3339) on a path
  block, so temporary access does not need a policy rewrite or a cleanup pass.
- Capabilities outrank parameter constraints. §Fine-grained control: "The capabilities
  associated with a path take precedence over permissions on parameters." A `deny` capability at
  a path therefore closes that path whatever the parameter lists say — and at KV v2 the
  parameter lists are not evaluated at all (see §KV v2 path mapping).

## Bounds (does not establish)

- One binary (OpenBao 2.7.2), one host, a throwaway `bao server -dev` with in-memory storage and
  a root token created for the run. A dev server is not a deployment: no seal/unseal, no HA, no
  namespaces, no performance or lockout behaviour.
- The tested engine is KV v2 at `secret/` only. No other secrets engine, no auth-method mapping,
  no identity/group policy attachment.
- Templated policies and identity templating are documented in the source page and **not
  measured**; the `{{identity.entity.id}}` template above is quoted as an example, not as
  behaviour.
- `sudo` on root-protected paths and `scan` are documented and **not measured**; parameter
  constraints at KV v1 are documented and **not measured** (and not applicable at KV v2).
- `list` is not measured: the trial has no `list` test, so both the `secret/metadata/<name>`
  route and the prefix sanitization sentence above are documented, not executed here. `deny`
  outside the tested capability set (create, patch, list, scan on a data path) is likewise
  unmeasured.
- The deny-precedence test (T3) puts the deny on the narrower, higher-priority pattern. Read
  together, the page's two sentences — only "the highest-priority match" is taken, and a deny
  takes precedence "regardless of any other defined capabilities" — imply that a `deny` on a
  *lower-priority* pattern is never consulted; that reading is textual and is not measured here,
  so the combination broad allow + narrower allow + broad deny is left open.
- The `+` examples all sit mid-path. Whether a `+` matches an empty segment (zero characters)
  follows neither from "any number of characters" nor from "bounded within a single path
  segment"; the trial's zero-segment leg is the check, and the wording alone does not settle it.
- The docs page's Version label is 2.7.x; a later release can change either the rules or the
  route mapping.

## Falsifiers

- A token whose attached policies grant nothing on a KV v2 data path reading that path
  successfully.
- `secret/bar/*` refusing `secret/bar/zip` or `secret/bar/zip/zap`, or allowing
  `secret/bars/zip`.
- An exact `secret/foo` grant reaching `secret/food`.
- A `*` anywhere but the last path character behaving as a glob (or a policy carrying one being
  accepted as a tree grant).
- A narrower `deny` not denying when a broader allow is also attached.
- A broad `deny` overturning a higher-priority narrower allow — this would contradict the
  highest-priority-match sentence as read in §Bounds.
- A `+` matching across a `/`, or a two-segment `+` claim holding.
- Same pattern in two policies where a capability granted by one is refused by the union (for
  example `read` from policy A and `update` from policy B, with the update refused).
- A different-pattern case where a glob `read` outranks an exact `update` (read allowed, update
  refused) — this would invert T5's second half.
- A KV v2 `read`/`update` allow written on `secret/<name>` (no `data/` segment) reaching the
  value, or a `list` allow on `secret/metadata/<name>` without a trailing glob listing the
  mount.
- A policy edit that does not take effect for an already-issued token, contradicting the
  real-time parse sentence.
- A token created with the default policy excluded that still shows self-lookup, or a token
  carrying only the default policy that is refused a self-lookup.

## Measured (round 58, OpenBao 2.7.2 dev server, 2026-11-07)

Executed by `corpus/openbao-policy-trial.sh`: a throwaway `bao server -dev` on 127.0.0.1, in-memory
storage, a random root token held in scratch only, `setpriv --pdeathsig KILL`, `bao` resolved on PATH.
Receipts: `.ufo/waves/round-58/build/R58ExecTrial/receipt-ref-real.txt` and `receipt-ref-real2.txt`
(two independent runs), shims `receipt-sh1.txt`–`receipt-sh5.txt`, legs `receipt-ref-none.txt` and
`receipt-ref-wrap.txt`; counter `plans/round-58-c2.sh`.

| # | documented rule | measured on 2.7.2 | receipt line |
|---|---|---|---|
| T1 | deny by default; a read grant does not update | empty-policy token denied on a KV v2 read; a read-grant token reads its path and is denied an update on it | `TRIAL T1 HOLDS empty-token-denied=1 read-allowed=1 value-roundtrip=1 update-denied=1` |
| T2 | `*` only as the last character; an exact path does not match a longer name | `secret/data/bar/*` reads both descendants and is denied the sibling `bars`; the exact grant reads its path and is denied the longer name | `TRIAL T2 HOLDS descendant=2 sibling-denied=1 exact-allowed=1 longer-name-denied=1` |
| T3 | `deny` outranks the other capabilities | the broad allow works away from the denied path; the denied path is refused with the broad allow still attached | `TRIAL T3 HOLDS broad-allowed=1 denied-path-denied=1` |
| T4 | `+` is bounded to one path segment | one intermediate segment allowed; two segments and zero segments refused | `TRIAL T4 HOLDS one-segment=1 two-segments-denied=1 zero-segments-denied=1` |
| T5 | same-pattern union; different patterns take one highest-priority match | read from one policy and update from another both work with delete still denied; with the exact `update` and the glob `read`, read is refused and update works | `TRIAL T5 HOLDS union-read=1 union-update=1 union-delete-denied=1 prio-read-denied=1 prio-update=1 caps=update` |

Summary `OPENBAO_POLICY_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`. Each of the five
falsifier shims flips exactly its designated test (`BHHHH`, `HBHHH`, `HHBHH`, `HHHBH`, `HHHHB`); a
PATH with no `bao` reads `SETUP` rc 2 with no HOLDS; a PATH wrapper that lies on the client-side
capability introspection flips T5 only (`receipt-ref-wrap.txt`, `TRIAL T5 BROKEN … caps=["read", "update"]`),
which is the leg that shows the trial resolves `bao` through PATH rather than an absolute path.

Measured limits of this table: the denial text for a KV v2 read on 2.7.2 is the preflight
capability message, not the literal `permission denied` (the trial classifies a 403 as denied); the
table covers the `secret/data/…` half only — `secret/metadata/…` listing and `scan` are not
exercised; the dev root token carries every capability, so no test distinguishes `sudo`; and the
`priority` half is measured with one policy pair, not the full five-rule ordering.
