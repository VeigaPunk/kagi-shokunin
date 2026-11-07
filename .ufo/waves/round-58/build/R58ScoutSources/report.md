# R58ScoutSources — seat report (scout: open the two declared policy sources + probe two more, located quotes)

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master. BASE `1b13f5dad921f8901f56d30c428f89614dd74d8a`
(`git cat-file -t` → `commit`, present). Read-only git by this seat: no `git add/commit/stash/push`,
no mutating `jj`, nothing written outside this seat's build dir and the round's capture dir.

Predeclaration read before work: `plans/round-58.md` (frozen; C2 POP T1–T5 names S118/S119 and the
five mechanics), `corpus/lessons/round-57-verifier-spotcheck.md`, and the L1's amendment A2
(the S117 quote test compares after collapsing whitespace runs). **No frozen predicate, target, POP
or kill rule was amended by this seat.** Am I an L1? No — `KagiR58` holds the canonical planner
seat and is the sole committer; this seat only returns findings and files.

Tools / versions / channel / reason — **no installs were made** (ALL pacman transactions are PAUSED host-wide):

| tool | version | channel | reason |
|---|---|---|---|
| `curl` | 8.23.0 (x86_64-pc-linux-gnu), OpenSSL/3.6.5, zlib/1.3.2 | system binary (preinstalled) | the live GETs of the four pages |
| `python3` | 3.14.8 (GCC 16.2.1) | system binary (stdlib only, `-I -B`) | HTML→text extraction for quoting only; no library installs |
| `sha256sum` | GNU coreutils | system binary | byte identity of the fetched bodies |
| `corpus/rendered-text-v1.py` | lane-committed normalizer | lane file (read-only) | the lane's **one** declared quote/page normalizer — used to locate every quote below |

Answering model observed for this seat: **minimax-code/MiniMax-M3.1-Flash** (harness-declared model id;
this report is my own work, not a delegated answer).

---

## 1. Fetch records

Command shape used verbatim for every fetch (browser UA; the lane's canonical profile also re-fetched
and compared, see §2):

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
     -D <headers> -o <body> -w '%{http_code} %{url_effective} %{size_download}' <URL>
```

A second, independent fetch of the same two declared URLs used the browser UA
`Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36`.
**Both profiles produced byte-identical bodies** for all four pages (same sha256 in both columns below),
so the bodies are not UA-dependent — the same finding the r57 scout recorded for the audit pages.

| id | URL | final URL | HTTP | bytes | sha256 of decoded body | browser-UA bytes/sha256 identical? |
|---|---|---|---|---|---|---|
| **S118** | https://openbao.org/docs/concepts/policies/ | same (no redirect) | 200 | 122498 | `a55ff1a4caf12c3a62bcaab61ff95fef1d382cba01da5dbd4521dbfbca6e1468` | yes |
| **S119** | https://openbao.org/docs/commands/policy/ | same (no redirect) | 200 | 32520 | `0472f29373a98f6dd1260aa6ca4d1bd80de9d4642a75c8df94bd22e47e0263e7` | yes |
| **S120** (probe) | https://openbao.org/docs/api/system/policies/ | same (no redirect) | 200 | 47012 | `9b13c6d9456583a11f51c0aa36fc5896ff66587d980054f1c17120174288542c` | yes |
| **S121** (probe) | https://openbao.org/docs/commands/token/ | same (no redirect) | 200 | 32638 | `37e706c2b2047d474dc84ad20f09b6f35c5d5c328f4fcff1298079c1c17ead28` | yes |

All four carry the docs-version marker `Version: Version 2.7.x` and the `docs-version-2.7.x` body
class — i.e. they are the **2.7.x** branch docs, the same branch as the measured binary OpenBao v2.7.2.

**Independent reproduction of the two declared pages.** The r58 scribe seat had already fetched S118/S119
into `.ufo/waves/round-58/build/R58ScribeEntry/capture/`. My independent fetches are **byte-identical**
to those copies:

```
$ sha256sum .ufo/waves/round-58/build/R58ScribeEntry/capture/S118.body .ufo/waves/round-58/capture/S118.body
a55ff1a4caf12c3a62bcaab61ff95fef1d382cba01da5dbd4521dbfbca6e1468  …/R58ScribeEntry/capture/S118.body
a55ff1a4caf12c3a62bcaab61ff95fef1d382cba01da5dbd4521dbfbca6e1468  …/round-58/capture/S118.body
$ sha256sum .ufo/waves/round-58/build/R58ScribeEntry/capture/S119.body .ufo/waves/round-58/capture/S119.body
0472f29373a98f6dd1260aa6ca4d1bd80de9d4642a75c8df94bd22e47e0263e7  …/R58ScribeEntry/capture/S119.body
0472f29373a98f6dd1260aa6ca4d1bd80de9d4642a75c8df94bd22e47e0263e7  …/round-58/capture/S119.body
```

Two independent fetchers (different seats, different UA, different working directories) produced the
same bytes — the pages are stable at this instant, and the L1's committed provenance digests are right.

### Capture files written (lane, not scratch)

```
.ufo/waves/round-58/capture/S118.body   122498 B  a55ff1a4…e1468
.ufo/waves/round-58/capture/S118.headers            (sanitized, QM72)
.ufo/waves/round-58/capture/S119.body    32520 B  0472f293…63e7
.ufo/waves/round-58/capture/S119.headers            (sanitized, QM72)
.ufo/waves/round-58/capture/S120.body    47012 B  9b13c6d9…542c
.ufo/waves/round-58/capture/S120.headers            (sanitized, QM72)
.ufo/waves/round-58/capture/S121.body    32638 B  37e706c2…ad28
.ufo/waves/round-58/capture/S121.headers            (sanitized, QM72)
.ufo/waves/round-58/capture/fetch-receipt.txt       (URL/status/bytes/sha256 per page)
```

**QM72 (cookie discipline).** The four responses carried **no** `Set-Cookie` and **no** `Cookie`
header (grep over the raw header files: 0 lines each), so there was no cookie value to remove. The
headers files are nevertheless sanitized by a stated rule and say so in their own first lines:
every `Set-Cookie`/`Cookie` line would be replaced by `<header removed (QM72): Set-Cookie/Cookie value
never committed>` (0 applied here), and the two server-issued per-request correlation ids
(`x-github-request-id`, `x-fastly-request-id`) were replaced by `<value removed (QM72): …>`
(1 each). No cookie, session id, token or other credential-shaped string appears in any file this seat
wrote; the only credential-shaped text inside the captured *documentation* bodies is the literal
placeholder `X-Vault-Token: ...` in the API examples (a vendor doc placeholder, not a value) and one
vendor example token UUID inside the `token` command page — neither is a real credential, and the
example UUID is the vendor's published sample, not a secret of this lane. No `bao` server was started,
no vault was opened, no token was created or read by this seat.

---

## 2. Located quotes (the deliverable)

**Verifier = the lane's own committed normalizer**, `corpus/rendered-text-v1.py locate` (one declaration
of the quote/page normalizer; `--selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`). The
full command-by-command transcript with exit codes is in
`.ufo/waves/round-58/build/R58ScoutSources/quote-locate-receipt.tsv`. Every quote below is **≤ 25
words** and returns `count=1` (exit 0) against the saved body in this lane's capture dir.

### S118 — https://openbao.org/docs/concepts/policies/ (200, 122498 B, `a55ff1a4…e1468`)

| # | verbatim quote (words) | heading anchor |
|---|---|---|
| Q1 | "Policies are deny by default" (5) | H1 «Policies» — page introduction, before the first h2 |
| Q2 | "so an empty policy grants no permission in the system" (10) | H1 «Policies» — same paragraph |
| Q3 | "the token cannot update or delete" (6) | §Policy syntax (`#policy-syntax`) — read-only example |
| Q4 | "It is not a regular expression and is only supported as the last character of the path" (17) | §Policy syntax (`#policy-syntax`) — the danger box on `*` |
| Q5 | `"secret/bar/zip", "secret/bar/zip/zap", but not "secret/bars/zip"` (5) | §Policy syntax (`#policy-syntax`) — prefix-glob example |
| Q6 | "This always takes precedence regardless of any other defined capabilities" (10) | §Capabilities (`#capabilities`) — the `deny` bullet |
| Q7 | "including sudo" (2) | §Capabilities (`#capabilities`) — `deny` bullet, same sentence |
| Q8 | "a + can be used to denote any number of characters bounded within a single path segment" (17) | §Policy syntax (`#policy-syntax`) — the `+` paragraph |
| Q9 | "If the same pattern appears in multiple policies, we take the union of the capabilities" (15) | §Policy syntax (`#policy-syntax`) — priority warning note |
| Q10 | "we take only the highest-priority match from those policies" (9) | §Policy syntax (`#policy-syntax`) — priority warning note |

Mapping onto the frozen C2 POP (T1–T5) — every required ground is present **as a located quote**:

| frozen test | ground | quote |
|---|---|---|
| T1 deny-by-default + "cannot update or delete" | S118 intro + §Policy syntax | Q1, Q2, Q3 |
| T2 `*` only as the last character + the `secret/bar/*` example | §Policy syntax danger box + prefix example | Q4, Q5 |
| T3 "this always takes precedence" | §Capabilities `deny` bullet | Q6 (with Q7) |
| T4 the `+` single-segment rule | §Policy syntax `+` paragraph | Q8 |
| T5 "union of the capabilities" vs "only the highest-priority match" | §Policy syntax priority note | Q9, Q10 |

**Two of the plan's own quote strings do NOT locate as written — the located forms are the ones above.**
This matters for the C1 check I3 (which requires a lesson quote that occurs in the capture body) and for
the registry row's `teaches` cell. Measured with the lane's own normalizer:

| string as written in `plans/round-58.md` / as written in the L1's SOURCES row | locate result | why |
|---|---|---|
| "Policies are deny by default, so an empty policy grants no permission" | **count=0** | the page marks "deny by default" in `<strong>`, so the rendered text carries a space before the comma: `…deny by default , so an empty policy grants…`. The located text is Q1 + Q2 as two fragments. |
| "this always takes precedence regardless of any other defined capabilities" (lowercase `this`) | **count=0** | the sentence begins a bullet, so the live text is "**This** always takes precedence regardless of any other defined capabilities" (Q6, capital T). A lower-case `this` does not occur. |
| "a `+` can be used to denote any number of characters bounded within a single path segment" | **count=1** with `+` in backticks removed (Q8) | the page writes `<code>+</code>`, so the plain-text form is "a + can be used…"; the backticked form does not occur verbatim. |

### S119 — https://openbao.org/docs/commands/policy/ (200, 32520 B, `0472f293…63e7`)

| # | verbatim quote (words) | heading anchor |
|---|---|---|
| Q11 | "The policy command groups subcommands for interacting with policies" (9) | H1 «policy» — page introduction |
| Q12 | "write Uploads a named policy from a file" (8) | §Usage (`#usage`) — subcommand list |
| Q13 | "Usage: bao policy <subcommand> [options] [args]" (6) | §Usage (`#usage`) — usage line |

Q12/Q13 are the documented `bao policy write` path the C2 trial uploads its HCL through.

### S120 — https://openbao.org/docs/api/system/policies/ (200, 47012 B, `9b13c6d9…542c`) — third page accepted

| # | verbatim quote (words) | heading anchor |
|---|---|---|
| Q14 | "The /sys/policies endpoints are used to manage ACL, RGP, and EGP policies in OpenBao." (14) | H1 «/sys/policies» — page introduction |
| Q15 | "This endpoint lists all configured ACL policies" (7) | §List ACL policies (`#list-acl-policies`) |
| Q16 | "Once a policy is updated, it takes effect immediately to all associated users" (13) | §Create/Update/Patch ACL policy (`#createupdate-acl-policy`) |
| Q17 | "A deleted policy set on a token acts as an empty policy" (12) | §Delete ACL policy (`#delete-acl-policy`) |

Q17 is the API-level statement of T1's empty-policy consequence (a deleted policy on a token acts as an
empty policy), and Q16 states that a policy update takes effect immediately — the property the trial's
"write the policy, then read" ordering relies on.

### S121 — https://openbao.org/docs/commands/token/ (200, 32638 B, `37e706c2…ad28`) — fourth page, **rejected as a registry row**

| # | verbatim quote (words) | heading anchor |
|---|---|---|
| Q18 | "The token command groups subcommands for interacting with tokens" (9) | H1 «token» — page introduction |
| Q19 | "capabilities Print capabilities of a token on a path" (9) | §Usage (`#usage`) — subcommand list |

---

## 3. Probe verdicts (the two URLs I was asked to probe)

Both probes asked "which exists as a real page (HTTP 200, mechanism text) and which is a stub/redirect".
**Measured answer: both exist as real pages; the stub/redirect form is the *other* URL shape**, which
the r57 lesson already rejected for the audit API page (`openbao.org/api-docs/system/audit/`, 334 B
`meta http-equiv=refresh` stub). Same shape here:

| URL probed | result | byte count | sha256 of decoded body | mechanism text? | verdict |
|---|---|---|---|---|---|
| https://openbao.org/docs/api/system/policies/ | HTTP 200, no redirect | 47012 | `9b13c6d9456583a11f51c0aa36fc5896ff66587d980054f1c17120174288542c` | yes — §List/§Read/§Create-Update-Patch/§Delete ACL policy | **ACCEPT as a registry row (S120)** |
| https://openbao.org/docs/commands/token/ | HTTP 200, no redirect | 32638 | `37e706c2b2047d474dc84ad20f09b6f35c5d5c328f4fcff1298079c1c17ead28` | yes — command-group overview + §Examples + §Usage | **REJECT as a registry row (scoped, not a stub)** |
| https://openbao.org/api-docs/system/policies/ (legacy shape, probed for the contrast) | HTTP 200 but a **343 B `meta http-equiv="refresh"` stub**, canonical `/docs/api/system/policies/`, no mechanism text | 343 | `0f6bae878df5cd74e5afa51f77887b540a26b1358e3d098480f9337646214a57` | none | **REJECT — redirect stub** (the r57 shape) |
| https://openbao.org/api-docs/system/audit/ (the r57 rejected URL, re-probed for the contrast) | HTTP 200, 334 B `meta http-equiv="refresh"` stub | 334 | `6b377e0b6f1b5e33a59cbc55d71cceeb6824ef83dad60e1172792846baa751d3` | none | REJECT — unchanged since r57 |
| https://openbao.org/api-docs/commands/token/ | **HTTP 404** | 3484 | — | none | REJECT — no such path |

**Why S120 is accepted and S121 is not.** S120 is a mechanism page for the very object the round's C2
claim is about (the ACL policy), it adds the API surface the trial's `bao policy write` reaches, and it
adds two mechanics no other registered row carries: a deleted policy on a token acts as an empty policy
(Q17) and a policy update takes effect immediately (Q16). S121 (`commands/token`) is a real page but its
scope — the token command group (create/lookup/renew/revoke/capabilities) — is already registered by
**S016** (`https://openbao.org/docs/concepts/tokens/`, used by
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md`) and **S021** (the same concepts URL,
product-bound review), and the registry's duplicate-URL discipline would flag a third row on
token-cli/lease scope that the round's C2 claim does not need. Its one ACL-relevant line, Q19
("capabilities Print capabilities of a token on a path"), is the CLI listing of a command the trial
*executes*; the trial's own receipts are the evidence for that command's behaviour, so a documentation
row adds no measured claim. **Rejecting S121 is a scope judgement, not a stub finding** — the page
itself is sound and is captured for the record.

---

## 4. Registry recipe for the L1 (fixture-verified; no lane edit made by this seat)

The L1 has already appended **S118** and **S119** rows to `corpus/SOURCES.md` and their provenance
rows to `corpus/source-fetches.tsv`. Two defects in that landed state were measured and are reported
here for the L1 to fix (this seat writes no lane file besides its own build dir and the capture dir):

**(a) The landed S118/S119 capture-row quotes do not locate.**
`corpus/source-fetches.tsv` col 13 carries `Policies are deny by default, so an empty policy grants no
permission in the system.` for S118 and `The policy command groups subcommands for interacting with
policies.` for S119. The S118 string locates **count=0** against the S118 body (the `<strong>` boundary
puts a space before the comma — see §2). The S119 string locates count=1. The registry row's `teaches`
cell for S118 carries the same non-locating sentence plus a lower-case "this always takes precedence …,
including \`sudo\`" (also count=0), and the S119 row's `teaches` cell carries
"The \`policy\` command groups subcommands …" with backticks (count=0 as written).

This is exactly the class of defect the r57 closure routed as **D4/D12** (a Gate quote that does not
occur in the body / an anchor-label drift), and it is what the round-58 plan's **I3** condition is
built to catch. The located replacements are Q1–Q10 (S118) and Q11–Q13 (S119) above; each is ≤ 25 words
and returns count=1.

**(b) The landed provenance rows point at the scribe's build dir.** Both rows' `location` column reads
`.ufo/waves/round-58/build/R58ScribeEntry/capture/S118.body` / `…S119.body`. Those files exist and are
byte-identical to the canonical capture dir this seat wrote
(`.ufo/waves/round-58/capture/S118.body` / `S119.body`, same sha256), so the digest pin holds either
way — but the round's capture dir is the stable path (the r55/r57 convention) and is the one the
L1's own `SOURCES.md` scope cells should cite. **Recommendation:** re-point both `location` cells to
`.ufo/waves/round-58/capture/<id>.body`. No digest changes.

**(c) The recipe for the two new rows I recommend (S120, and — if the L1 wants it — S121).** I proved
this recipe on a **scratch copy** of the lane corpus (`/fast/scratch/hyaku/kagi-r58/R58ScoutSources/fix3`),
never on the lane: it ends `SOURCES_CENSUS: CLEAN (rows=120 …)` with S120 added and the knowledge
entry carrying the required `cites:` line. The three things that must line up, in the order the census
reads them:

1. `corpus/SOURCES.md` — a 13-column row (11 fields) whose source cell holds the URL, whose status is
   `mined`, whose tier is `A`, and whose `used-by` names the knowledge entry that cites it:
   ```
   | S120 | /sys/policies API — https://openbao.org/docs/api/system/policies/ | docs | A | OpenBao 2.7.x HTTP API for ACL, RGP and EGP policies: list, read, create/update and delete a named ACL policy, and the rule that a deleted policy on a token acts as an empty policy | §List ACL policies, §Read ACL policy, §Create/Update/Patch ACL policy, §Delete ACL policy; Version 2.7.x, opened 2026-11-07 with a browser user agent (decoded body 47012 bytes, sha256 9b13c6d9456583a11f51c0aa36fc5896ff66587d980054f1c17120174288542c, `.ufo/waves/round-58/capture/S120.body`) | The /sys/policies endpoints "are used to manage ACL, RGP, and EGP policies in OpenBao"; a policy update "takes effect immediately to all associated users"; and a deleted policy "acts as an empty policy" on a token | mined | 2026-11-07 | 180d | corpus/knowledge/openbao-acl-policy-semantics.md |
   ```
2. `corpus/source-fetches.tsv` — one 16-column provenance row. The `row_identity_sha256` is
   `sha256("S120\tmined\thttps://openbao.org/docs/api/system/policies/\n")` =
   **`efe4289072b6be149332cb644267198b5e2ab1b0dd045f029a91ab45c41968a4`** (the census recomputes it as
   `printf '%s\t%s\t%s\n' "$fid" "$status" "$url" | sha256sum`; the URL is the exact registered URL
   string, and the trailing `/` matters). `request_profile` must be `curl-fsSL-compressed-v1`,
   `representation` `decoded-http-body-v1`, `quote` ≤ 25 ASCII words, `normalization`
   `rendered-text-v1`, `normalized_sha256`
   `4af1e7f730b3c7548cd37bc10ed39206b96e38fceb1b4922e7dcb7234060c669`, `location`
   `.ufo/waves/round-58/capture/S120.body`. The row I verified, verbatim:
   ```
   S120	mined	efe4289072b6be149332cb644267198b5e2ab1b0dd045f029a91ab45c41968a4	https://openbao.org/docs/api/system/policies/	https://openbao.org/docs/api/system/policies/	200	curl-fsSL-compressed-v1	2026-11-07	decoded-http-body-v1	9b13c6d9456583a11f51c0aa36fc5896ff66587d980054f1c17120174288542c	47012	-	A deleted policy set on a token acts as an empty policy	rendered-text-v1	4af1e7f730b3c7548cd37bc10ed39206b96e38fceb1b4922e7dcb7234060c669	.ufo/waves/round-58/capture/S120.body
   ```
3. `corpus/knowledge/openbao-acl-policy-semantics.md` — the entry must **record** the new id on a
   column-1 `cites:` line (at most one such line; the entry currently has none), otherwise the census
   reports `SC_USEDBY_NOCITE`/`SC_BODY_CITE` for the new row. The line I verified:
   ```
   cites: S120 (https://openbao.org/docs/api/system/policies/, §Delete ACL policy; the API that creates and deletes the named ACL policy the trial writes; Version 2.7.x, opened 2026-11-07).
   ```
   (If the L1 prefers to fold S120 into the entry's existing `source:` line instead, that also
   satisfies the check — one `source:` line naming S118, S119 **and** S120, and no `cites:` line at
   all. Both shapes were exercised; the `cites:` shape is the one I ran.)

**Scratch-fixture verdict (read-only evidence, the lane was not modified):**

```
$ bash corpus/sources-census.sh verify --root /fast/scratch/hyaku/kagi-r58/R58ScoutSources/fix3
SOURCES_CENSUS: CLEAN (rows=120 A=116 B=2 C=2 queued=1 mined=115 rejected=4 entries_sourced=18 legacy=21 captures=120 inrow=16 inrow_only=0 inrow_nonreproducing=12)
```

The same fixture with **no** `cites:` line on the knowledge entry reports exactly the two expected
findings, which is what makes the third step necessary rather than optional:

```
FINDING SC_USEDBY_NOCITE id=S120 path=corpus/knowledge/openbao-acl-policy-semantics.md
FINDING SC_FETCH id=S120 url-mismatch
FINDING SC_FETCH id=S120 row-identity-digest-mismatch
```

(The second and third findings in that run were an artifact of my fixture's own row-string bug — an
un-substituted URL placeholder — and vanished once the URL was interpolated correctly; they are
reproduced here only to show the identity-digest check is live.)

**S121, if the L1 wants it:** identical shape with `https://openbao.org/docs/commands/token/`,
identity `sha256("S121\tmined\thttps://openbao.org/docs/commands/token/\n")`, raw sha256
`37e706c2b2047d474dc84ad20f09b6f35c5d5c328f4fcff1298079c1c17ead28`, bytes `32638`, normalized digest
`4f4d2d073388e546dac3ba1e98608a8a0f2d2fecb424629faad7ad29130c3fd8`, quote
`capabilities Print capabilities of a token on a path`. My recommendation is to **not** add it (the
scope argument in §3); if the L1 adds it anyway, it must carry the same three-step recipe.

---

## 5. Coverage note for the lesson's `## Gate` row

The r57 closure routed **D4** ("S117 lacks a `## Gate` record": URL, access date, and a ≤ 25-word quote
that occurs in the capture body) and **D12** (the lesson cited a *reworded* live heading). The r58
lesson's Gate row for S118/S119 can be written from this seat's table directly:

| id | URL | access date | located quote (≤ 25 words) | heading anchor |
|---|---|---|---|---|
| S118 | https://openbao.org/docs/concepts/policies/ | 2026-11-07 | "Policies are deny by default" / "so an empty policy grants no permission in the system" / "This always takes precedence regardless of any other defined capabilities" / "we take only the highest-priority match from those policies" | page introduction (before the first h2); §Capabilities (`#capabilities`); §Policy syntax (`#policy-syntax`) |
| S119 | https://openbao.org/docs/commands/policy/ | 2026-11-07 | "write Uploads a named policy from a file" / "Usage: bao policy <subcommand> [options] [args]" | §Usage (`#usage`) |
| S120 | https://openbao.org/docs/api/system/policies/ | 2026-11-07 | "A deleted policy set on a token acts as an empty policy" / "Once a policy is updated, it takes effect immediately to all associated users" | §Delete ACL policy (`#delete-acl-policy`); §Create/Update/Patch ACL policy (`#createupdate-acl-policy`) |

Use the **live** heading text, not a reworded one (the D12 lesson): `Policy syntax`, `Capabilities`,
`Usage`, `List ACL policies`, `Create/Update/Patch ACL policy`, `Delete ACL policy`, `Examples`. The
`§` form the lane uses for headings is fine; the *wording* must be the live one.

---

## 6. Files this seat wrote (nothing else in the lane)

```
.ufo/waves/round-58/capture/S118.body  S118.headers
.ufo/waves/round-58/capture/S119.body  S119.headers
.ufo/waves/round-58/capture/S120.body  S120.headers
.ufo/waves/round-58/capture/S121.body  S121.headers
.ufo/waves/round-58/capture/fetch-receipt.txt
.ufo/waves/round-58/build/R58ScoutSources/report.md          (this file)
.ufo/waves/round-58/build/R58ScoutSources/quote-locate-receipt.tsv
.ufo/waves/round-58/w1/R58ScoutSources.md                    (the wave report)
```

Scratch (`${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r58/R58ScoutSources/`) held the raw fetches, the
extracted text and the census fixtures; it is deleted before this seat yields. No file was written to
`corpus/`, to `plans/`, to the fleet root, or to any sibling lane; no `git`/`jj` mutating command was
run anywhere.

---

## 7. What remains unresolved / not mine to do

- The **L1** owns `corpus/SOURCES.md`, `corpus/source-fetches.tsv` and the commit. My recipe in §4 is
  fixture-verified but **not applied to the lane** — the L1 must land it.
- The r58 **lesson** (`corpus/lessons/round-58.md`) does not exist yet; the Gate-row material is in §5
  for the scribe seat.
- The knowledge entry currently names only S118/S119 on its `source:` line; if S120 is added, its
  `cites:` (or `source:`) line must name S120 (§4 step 3).
- I did **not** start an OpenBao dev server or exercise any policy semantics — that is the executor
  seat's C2 trial. Every mechanic claim in §2 is a **documented** claim; the trial receipts are the
  behavioural evidence.
