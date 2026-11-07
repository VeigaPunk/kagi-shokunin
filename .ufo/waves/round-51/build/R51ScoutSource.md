# R51ScoutSource — S108 independent re-open (frontier step)

Seat: R51ScoutSource. Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master.
BASE `214d8bf530a0c87c00686493f21af15396284793`; predeclaration `4ad8ab7cd5bf8949d125ac96ccef45e69dabc567`.
Scratch: `/fast/scratch/hyaku/kagi-r51/R51ScoutSource/`. Tooling: none installed (no pacman, no uv/cargo/npm).
All OpenBao servers were throwaway `bao server -dev` on 127.0.0.1 with a random root token generated in
scratch, killed before yield; no token/nonce value was printed to stdout, any artifact, or any log.

## 1. Independent re-open of S108 — status / sha256 / bytes

Command profile (same as the lane's declared `curl-fsSL-compressed-v1`):

```
curl -fsSL --compressed -w '%{http_code} %{url_effective}' -o s108.html \
  https://openbao.org/docs/concepts/response-wrapping/
```

| URL | HTTP | final URL | raw sha256 | bytes | vs L1 capture |
|---|---|---|---|---|---|
| https://openbao.org/docs/concepts/response-wrapping/ | 200 | same | `a555301e8f61a407130515449309b05c4e2c7a936f8f1bdf1921e2f9cc32ed55` | 37186 | **IDENTICAL** to `.ufo/waves/round-51/capture/S108.body` (declared sha256 `a555301e…f9cc32ed55`, 37186 B) |
| https://openbao.org/docs/api/system/wrapping-lookup/ | 200 | same | `baa2501c8c9956cc5f4d519db5815126107147513b69d1e4e495b8de72b05586` | 38444 | new capture (no L1 capture exists) |
| https://openbao.org/docs/api/system/wrapping-unwrap/ | 200 | same | `daa3028f5efc452e4c53e088446a35224a4b91b18069f4e513ead73ac5161dd0` | 38589 | new capture |
| https://openbao.org/docs/api/system/wrapping-rewrap/ | 200 | same | `7173f3a6b1bcf004e7cd2888b46874911b2573c577e0e9d944a7bafef42a3ee9` | 38748 | new capture |
| https://openbao.org/docs/api/system/wrapping-wrap/ | 200 | same | `ae606220e9d2780c6bf36968e6b43f3ccc803eab6e0080a0ad4c345bf76d7f6c` | 38865 | new capture |

`Last-Modified` on all five: `Fri, 06 Nov 2026 09:06:37 GMT` (unwrap: `09:07:02 GMT`) — the
documentation set was rebuilt the day before this re-open, so the sha equality with the L1 capture
is a same-build identity, not a stale mirror. **S108 did not drift.**

`python3 corpus/rendered-text-v1.py digest` on my own fetch reproduces the lane's recorded
normalized digest for S108 exactly:
`raw_sha256=a555301e…f9cc32ed55 bytes=37186 normalized_sha256=133496495ea72d2ac1fa7e1a8f04661beb2aa0df5e6b16e917f9e93432f4868a normalized_bytes=10424`
— identical to the `normalized-digest` cell of the pending S108 row in `corpus/source-fetches.tsv`
(`133496495ea7…32f4868a`). The pending fetch row's `row_identity_sha256`
`b7ed6ba7eed103207e3745a3b954a847b69476276bab94f3d3f05f84aede270f` is reproduced by
`printf 'S108\tmined\thttps://openbao.org/docs/concepts/response-wrapping/\n' | sha256sum` (verified,
matches). The pending row's `quote` cell is the same 13-word quote the sources-row carries.

### Redirect claim in the task brief — CORRECTED
The brief said "the /api-docs/ URLs redirect there". They do **not** HTTP-redirect. Measured:

```
curl -sSI --compressed https://openbao.org/api-docs/system/wrapping-lookup/
  → HTTP/2 200, x-redirect: none; body is a 364-byte meta-refresh stub:
    <meta http-equiv="refresh" content="0; url=/docs/api/system/wrapping-lookup/">
    <link rel="canonical" href="/docs/api/system/wrapping-lookup/" />
    window.location.href = '/docs/api/system/wrapping-lookup/' + search + hash
```

`-L` reports `num_redirects=0` for all four `/api-docs/` URLs: the redirect is **client-side
(meta-refresh + JS)**, so any capture of the `/api-docs/` form would store the 364-byte stub, not the
page. All four stubs were fetched and hashed for the record:

| stub URL | HTTP | bytes | raw sha256 |
|---|---|---|---|
| /api-docs/system/wrapping-lookup/ | 200 | 364 | `5ad4f149756bd73b8e6cd800ed7d85f4a7a7b2fc7f910464b7fee7a65e7c58ab` |
| /api-docs/system/wrapping-unwrap/ | 200 | 364 | `c53dd6f12eec36cc8fe3761edf220cb1094975457898927374b1371a12b1abd3` |
| /api-docs/system/wrapping-rewrap/ | 200 | 364 | `44da72f6a13a26532bc793052817382f1287f169ca94bdb1005e69408539847f` |
| /api-docs/system/wrapping-wrap/ | 200 | 358 | `4037ec7b96f2f1f732b18d245c51511a86e1208c1ffdd5296e4dacc15e8078d5` |

**Registry consequence:** a new source row must carry the canonical `/docs/api/system/wrapping-*/`
URL, never the `/api-docs/` form — the census's `SC_FETCH` compares `url` to the row's registered
URL and `final_url` to `%{url_effective}`, and a `/api-docs/` row would pin a redirect stub.

## 2. Located-count per quote (S108 body = the L1 capture)

All counts from `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-51/capture/S108.body "<quote>"`;
word counts from `printf '%s' "<q>" | wc -w`. rc=0 means count≥1.

### 2a. sources-row.md (`…/controls/fixtures/ref/sources-row.md`)
| quote | words | rc | located count |
|---|---|---|---|
| `only a single party can ever unwrap the token and see what's inside` | 13 | 0 | **1** |

The row's own quote (the one after `Quote:`, anchored `§Overview`) is the only quoted string in
sources-row.md, and it locates exactly once. It is the same string the pending S108 fetch row
carries as its `quote` cell — consistent.

### 2b. The five test comments of the reference trial (`…/ref/corpus/openbao-wrap-trial.sh`)
| test | quoted string in the comment | words | rc | located count |
|---|---|---|---|---|
| T1 | `only a single party can ever unwrap the token` | 9 | 0 | **1** |
| T2 | `is separate from the wrapped secret` | 6 | 0 | **1** |
| T3 | `This path is unauthenticated` | 4 | 0 | **1** |
| T3 | `This immediately tells you if the token has already been unwrapped` | 11 | 0 | **1** |
| T4 | `migrat[es] the wrapped data to a new response-wrapping token` | 9 | **1** | **0** |
| T5 | *(no quoted string in the comment)* | — | — | — |

Supporting quotes I located for the same claims (plain, un-bracketed):
| quote | words | rc | count |
|---|---|---|---|
| `migrating the wrapped data to a new response-wrapping token` | 9 | 0 | **1** |
| `the data contained inside was read and then put into a new response-wrapping token` | 14 | 0 | **1** |
| `the path starts with cubbyhole or sys/wrapping/wrap` | 7 | 0 | **1** |
| `validate that the creation path matches expectations` | 7 | 0 | **1** |

**Defect (minor, worth an upstream fix):** the T4 comment quotes `migrat[es] the wrapped data to a
new response-wrapping token` with a scholarly bracket. That bracketed form does **not** locate
(count=0, rc=1); the page's actual string is `migrating the wrapped data to a new response-wrapping
token`. Bracketed elision is not a locator-supported convention in this corpus. The un-bracketed
form locates count=1, so the *claim* is true — only the *quoted spelling* is wrong.

Rendered-text offsets of the located S108 quotes (from my own `normalize_text` of the capture):
`2805` (T1), `3202` (T2), `5365` (T3 "This path is unauthenticated"), `9076` (T5 read-and-rewrap
sentence), `9186` (`the path starts with cubbyhole or sys/wrapping/wrap`).

## 3. T3 and T5: stated by the pages, or only inferred?

**T3 — "lookup is unauthenticated": STATED, not inferred.** S108 §Response-Wrapping token operations,
Lookup bullet, verbatim: *"This allows fetching the response-wrapping token's creation time,
creation path, and TTL. This path is unauthenticated and available to response-wrapping tokens
themselves."* Located count=1 for `This path is unauthenticated`. The "does not consume / tells you
if already unwrapped" half is also stated: §Response-Wrapping token validation, *"Perform a lookup on
the response-wrapping token. This immediately tells you if the token has already been unwrapped or is
expired (or otherwise revoked)."* (count=1).

**T5 — "creation path `sys/wrapping/wrap` after a read-and-rewrap": STATED in substance, but the
*exact literal* is stated only on the API pages, not on S108.**
- S108 §Response-Wrapping token validation states the mechanic: *"If the path is not what you expect,
  it is possible that the data contained inside was read and then put into a new response-wrapping
  token. (This is especially likely if the path starts with `cubbyhole` or `sys/wrapping/wrap`.)"*
  (count=1 for both the read-and-rewrap sentence and the `cubbyhole`/`sys/wrapping/wrap` clause).
  S108 says the path *starts with* those prefixes; it does not print the literal string
  `sys/wrapping/wrap` as the whole creation-path value.
- The exact literal appears in the **sample responses** of three API pages:
  `wrapping-lookup` (`"creation_path": "sys/wrapping/wrap"`), `wrapping-rewrap` and `wrapping-wrap`.
  Note: `rendered-text-v1 locate` on the *raw HTML* of those pages does **not** find the JSON
  fragment `"creation_path": "sys/wrapping/wrap"` (count=0) because the JSON is split across
  lines in the served HTML; it finds the single token `creation_path` (count=1) and
  `sys/wrapping/wrap` (count=8 in wrap.html). Any quote for these pages must therefore be a
  prose string, not a JSON fragment.
- S108's own field-name table capitalises them ("Creation Path", "Creation Time", "TTL") — the
  snake_case wire names `creation_path` / `creation_time` / `creation_ttl` appear **only** in the
  API pages' sample responses. `grep -c creation_path` on the S108 capture = **0**.

## 4. Empirical check against a throwaway OpenBao 2.7.2 dev server (T1–T5)

Run under `/fast/scratch/hyaku/kagi-r51/R51ScoutSource/`, `bao v2.7.2 (9e0a0d3c3504a0a00b45e61355afac5e35c78379)`,
`bao server -dev` on a random free 127.0.0.1 port, root token a fresh `secrets.token_hex(16)` kept
only in scratch, `setpriv --pdeathsig KILL`, `trap` on EXIT. Nothing printed except booleans and
non-secret path strings; the server was killed and its scratch dir removed before yield.

Measured results (all values are paths/booleans, no token values):
```
T3 unauth_lookup_creation_path=[secret/data/t5] matches_expected=1
T3 unwrap_after_lookup_value_matches=1
T5 rewrap_creation_path=[sys/wrapping/wrap] equals_sys_wrapping_wrap=1
T4 tokens_differ=1 old_still_usable=0 new_value_matches=1
T1 first_unwrap_rc=0 ; T1 second_unwrap_rc=2
T2 wrap token obtained (ttl 2s)=yes ; unwrap_after_4s_rc=2 (refused) ; secret_still_readable=1
```
**All five T-tests of the reference trial hold empirically on OpenBao 2.7.2** — T1 single use
(second unwrap rc=2), T2 wrap TTL lapses while the secret stays readable, T3 unauthenticated
lookup that does not consume, T4 rewrap that spends the old token, T5 creation-path detection.
(The trial itself, `corpus/openbao-wrap-trial.sh`, was **not** executed by this seat — the C1
counter does that; these are independent re-derivations of the same mechanics against the same
pinned binary.)

Raw-HTTP confirmation that lookup is genuinely unauthenticated (not merely "no token supplied"):
```
POST /v1/sys/wrapping/lookup with NO X-Vault-Token header            → 200, creation_path present
POST /v1/sys/wrapping/lookup with X-Vault-Token: not-a-real-token      → 200, creation_path present
POST /v1/sys/wrapping/unwrap  with NO header and token in the body    → 403
```
So lookup ignores the client credential entirely (a *wrong* token still returns 200), while
unwrap genuinely requires the wrapping token as the client token. That asymmetry is exactly what
S108 §Response-Wrapping token operations describes.

### 4a. IMPORTANT DOC/BEHAVIOUR DIVERGENCE FOUND (new, not in the frozen fixtures)
The **rewrap** endpoint's sample response on the API page shows the *new* token's
`"creation_path": "sys/wrapping/wrap"`. **Measured, that is not what OpenBao 2.7.2 does.** Measured:

```
A fresh wrap token lookup path                      = [secret/data/t4]
rewrap RESPONSE wrap_info.creation_path             = [secret/data/t4]   <-- preserved, not sys/wrapping/wrap
lookup of the REWRAPPED token path                  = [secret/data/t4]   <-- preserved
lookup of a sys/wrapping/wrap token path            = [sys/wrapping/wrap]
```

`sys/wrapping/rewrap` **preserves the original creation path** (the source path the data came from);
only the manual `sys/wrapping/wrap` helper stamps `sys/wrapping/wrap`. The API page's rewrap sample
response is therefore a **misleading illustration** (it reuses the wrap endpoint's sample
`creation_path` verbatim, presumably as boilerplate). This matters because the trial's T5 test
correctly uses `sys/wrapping/wrap` (not rewrap) — so the frozen trial is right and the *doc sample*
is wrong. It also means **no new source row should quote the rewrap page's sample `creation_path`
as if it documented rewrap's behaviour.**

### 4b. Second divergence: rewrap's TTL
The rewrap page states *"The new token will use the same creation TTL as the original token"* and
*"can be used to rotate a wrapping token and refresh its TTL"* — these two sentences are mutually
tensioned and only the first is testable as written. Measured: the rewrapped token's
`creation_ttl` = 60 s, equal to the original 60 s wrap TTL (so "same creation TTL" holds; "refresh
its TTL" does not describe a TTL *increase*). Not a defect in the trial; worth a note if a
future round wants to assert rewrap TTL semantics.

## 5. ADMIT / REJECT decision per API page

Decision rule applied: **ADMIT** only if the page states something the trial's teaching *rests on*
that S108 does not state, and the support is a *located, ≤25-word prose quote* with a named anchor.
**REJECT** otherwise, with a flip condition naming what would change the verdict.

### `wrapping-lookup` — **ADMIT** (as a new source row, e.g. S109)
*Why it adds something beyond S108:* S108 names the wire fields only in prose with title case
("Creation Path", "Creation Time") and never prints the snake_case JSON names the trial's `lookup()`
helper actually parses. The page's sample response is the only place the wire contract
`creation_path` / `creation_time` / `creation_ttl` appears as literal field names — which is exactly
what T3 and T5 assert on.
*Located quote (≤25 words, 10 words, rc=0 count=1):*
> `This endpoint looks up wrapping properties for the given token.`
*Anchor:* §Wrapping lookup → "This endpoint looks up wrapping properties for the given token."
*Located support quote for the field names:* `creation_path` (1 word, rc=0 count=1) — plus
`creation_time` (count=1) and `creation_ttl` (count=1).
*Fetch row data (if admitted):*
url `https://openbao.org/docs/api/system/wrapping-lookup/`, final_url same, http_status 200,
request_profile `curl-fsSL-compressed-v1`, representation `decoded-http-body-v1`,
sha256 `baa2501c8c9956cc5f4d519db5815126107147513b69d1e4e495b8de72b05586`, bytes 38444,
revision `-`, quote `This endpoint looks up wrapping properties for the given token.`,
normalization `rendered-text-v1`, normalized-digest
`97ce6be48365b8c9c0315e1ae73a145767130909d458ef16b876875e7de27bb5` (normalized_bytes 2651),
location `§Wrapping lookup, endpoint description; rendered-text offset 1528`.
`row_identity_sha256` for id S109/status mined =
`01669e92793149a859e86bc8d4e880c42f977028f7c28abc453472085c317537`
(computed as `printf 'S109\tmined\thttps://openbao.org/docs/api/system/wrapping-lookup/\n' | sha256sum` — **placeholder id S109, the id is the L1's to assign**; the other three candidates: S110/unwrap `eedd1a6612b2a4f9825c950c3233d70c38bc866b19c2f0ec79ebdcefde2b1388`, S111/rewrap `4f5cf267a9c9640379f96e388bb7fbf9e1a1e60e6d9de730baa41fca73743303`, S112/wrap `fe6deb0a05304f8eda1825d1a444963103f0d1f00a56fcdeff26c8d952e09fd2`).

### `wrapping-rewrap` — **REJECT**
*Reason:* S108 §Response-Wrapping token operations already states the rewrap mechanic in the words
the trial uses ("Allows migrating the wrapped data to a new response-wrapping token"), and the
trial's T4 assertions (new token differs, unwraps to the same value, old token spent) are all
covered by S108 §Rewrap plus the measured behaviour. The page's only *additional* content beyond
S108 is (a) the exact request/response JSON shape and (b) the claim "The old token will be
invalidated" — which S108 implies ("migrat[es] … to a new response-wrapping token", i.e. the data
moves) but does not state as a sentence. That single sentence *is* the strongest documentary
support for T4's "old token is spent" assertion, so this is a genuine near-miss.
*Located quote that would have supported it (6 words, rc=0 count=1):* `The old token will be invalidated.`
*Flip condition:* ADMIT if the trial ever has to distinguish "rewrap moves the data" (S108) from
"rewrap invalidates the old token" (page-only) — i.e. if a future round asserts old-token
invalidation as a distinct property rather than as the corollary of data migration. Until then it
is a duplicate teaching, and the page's sample `creation_path` is actively misleading (§4a), so
admitting it would import a wrong illustration into the corpus.

### `wrapping-unwrap` — **REJECT**
*Reason:* the trial's T1 uses `bao unwrap`, and S108 §Response-Wrapping token operations states the
unwrap operation and the single-party property ("only a single party can ever unwrap the token and
see what's inside"). The page adds two things S108 lacks: (a) *"Unlike simply reading
`cubbyhole/response` (which is deprecated), this endpoint provides additional validation checks"*
and (b) the double-use hazard *"Do not use the wrapping token in both locations; this will cause
the wrapping token to be revoked but the value to be unable to be looked up"* (rc=0 count=2).
Neither is something the trial rests on: the trial never reads `cubbyhole/response` and never
double-uses a token, and the trial's own comment already flags the no-client-token unwrap.
*Flip condition:* ADMIT if a future trial asserts the `cubbyhole/response` deprecation or the
double-use revocation hazard — either is a genuine, separately-testable mechanic not on S108.

### `wrapping-wrap` — **ADMIT** (as a new source row, e.g. S112)
*Why it adds something beyond S108:* T5's whole point is the *exact* creation-path literal
`sys/wrapping/wrap` produced by this endpoint. S108 states only that the path *starts with*
`cubbyhole` or `sys/wrapping/wrap` (a prefix heuristic) and never states that this endpoint stamps
that exact literal. The page's sample response shows `"creation_path": "sys/wrapping/wrap"` as the
wrap endpoint's own creation path, which is the value the trial asserts (and which I measured to be
exact, not a prefix).
*Located quote (≤25 words, 11 words, rc=0 count=1):*
> `This endpoint wraps the given user-supplied data inside a response-wrapped token.`
*Anchor:* §Wrapping wrap → endpoint description.
*Located support quote for the literal path:* `sys/wrapping/wrap` (rc=0 count=8 in wrap.html).
*Fetch row data (if admitted):*
url `https://openbao.org/docs/api/system/wrapping-wrap/`, final_url same, http_status 200,
representation `decoded-http-body-v1`,
sha256 `ae606220e9d2780c6bf36968e6b43f3ccc803eab6e0080a0ad4c345bf76d7f6c`, bytes 38865, revision `-`,
quote `This endpoint wraps the given user-supplied data inside a response-wrapped token.`,
normalization `rendered-text-v1`, normalized-digest
`cb21367146ca691def724b75c1e21e468aba4b217652a1284da8e20c5b918f83` (normalized_bytes 2794),
location `§Wrapping wrap, endpoint description; rendered-text offset 1535`.
`row_identity_sha256` for id S112/status mined =
`fe6deb0a05304f8eda1825d1a444963103f0d1f00a56fcdeff26c8d952e09fd2`
(placeholder id; `printf 'S112\tmined\thttps://openbao.org/docs/api/system/wrapping-wrap/\n' | sha256sum`).

**Summary: 2 ADMIT (wrapping-lookup, wrapping-wrap), 2 REJECT (wrapping-rewrap, wrapping-unwrap),
each with a flip condition.**

## 6. Registry-census finding on the pending candidate (read-only check, run by me)

I ran the lane's own read-only registry gate on the **working tree** (it writes nothing outside a
temp dir):

```
$ bash corpus/sources-census.sh
FINDING SC_USEDBY_MISSING path=corpus/lessons/round-51.md
SOURCES_CENSUS: FAILED (findings=1 rows=108)
EXIT=1
```

Cause: the pending `| S108 |` row in the working-tree `corpus/SOURCES.md` has
`used-by = corpus/knowledge/vault-openbao-token-lease-lifecycle.md, corpus/lessons/round-51.md`,
but **`corpus/lessons/round-51.md` does not exist yet** (`corpus/lessons/` currently ends at
`round-50.md`). The census's `SC_USEDBY_MISSING` finding fires on the non-existent path.

This is a **landing-order dependency, not a source defect**: the lesson file is being drafted by the
scribe seat (`.ufo/waves/round-51/build/R51ScribeEntry/lesson-round-51.md` exists and cites S108
four times), and once the L1 lands `corpus/lessons/round-51.md` the finding clears — provided the
landed lesson's `source:` field cites S108, which the census checks per used-by path
(`SC_USEDBY_NOCITE`). The sibling scribe seat recorded the same finding independently
(`.ufo/waves/round-51/build/R51ScribeEntry/receipts/census-candidate.txt`, `E11`).

**Note for the L1:** the frozen fixture
`.ufo/waves/round-51/controls/fixtures/ref/sources-row.md` has `used-by =
corpus/knowledge/vault-openbao-token-lease-lifecycle.md` **only** (no lesson path), while the
working-tree row adds `corpus/lessons/round-51.md`. Cell-by-cell diff of the two rows: **13 cells,
exactly one differs — cell 11 (`used-by`)**; every other cell, including the quote, the anchor and
the `mined | 2026-11-07 | 180d` cells, is byte-identical. So the working-tree row is the
fixture's row plus the lesson citation.

## 7. Freshness / drift assessment

- S108 body is byte-identical to the L1 capture (same sha256, same 37186 bytes) and the
  normalized digest reproduces the pending fetch row exactly. No drift since the predeclaration.
- Re-fetched with the **declared request profile** (including the corpus user agent
  `kagi-shokunin-round23/1.0 (documentation verification)`) → HTTP 200, no redirect,
  sha256 `a555301e…f9cc32ed55`, 37186 B, **byte-identical** to my no-UA fetch
  (`cmp` → identical). The body carries the `docs-version-2.7.x` marker once.
- All five pages carry a `Last-Modified` of 2026-11-06 09:06–09:07 GMT (the day before the fetch),
  so the four API pages are the current published set and are contemporaneous with S108. Caveat
  measured: `wrapping-lookup`'s `Last-Modified` was observed as both `09:06:37` and `09:07:02 GMT`
  across two HEAD requests while its decoded-body sha256 stayed identical — the Pages build
  timestamp varies, the served content does not. So `Last-Modified` is not a reliable drift pin for
  these pages; the body sha256 is. (Recorded in `fetch-status.txt`.)
- The API pages are *not* in the registry yet (registry ends at S108) and have no `source-fetches`
  rows; §5's ADMIT decisions are the frontier step that could add them (ids S109/S110/S111/S112
  are unclaimed — `grep -rn "S109\|S110\|S111" corpus/` returns nothing).
- The `.ufo/waves/round-51/controls/fixtures/ref/corpus/openbao-wrap-trial.sh` fixture is
  byte-identical to the untracked working-tree `corpus/openbao-wrap-trial.sh`
  (`diff` → identical), so the reference trial and the candidate are the same file today.
- The `bao` binary I measured with is sha256
  `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`, **identical** to the
  `PIN_BAO` value in `plans/round-51-c1.sh` (line 37) — the C1 counter's pinned binary is the one
  on PATH, and I did not touch `~/.local/bin`.

## 8. What remains unknown / not done by this seat

- The C1 counter (`plans/round-51-c1.sh`) and C2 counter were **not** run by this seat (not my
  item; the brief forbids running the lane's full `claim-ledger.sh verify`, and the counters are
  the L1's to run).
- I did not attempt a registry edit: `corpus/SOURCES.md`, `corpus/source-fetches.tsv` and every
  other registry row are outside my write scope. §5's ADMIT data is handed over as ready-to-paste
  fetch rows; the row ids are placeholders for the L1 to assign.
- The **L1 lands the candidate after this wave**, so the pending working-tree
  `corpus/SOURCES.md` / `source-fetches.tsv` / `claims-declared.tsv` / knowledge-file edits that
  `git status` shows as modified were not authored or altered by me.
- Whether the OpenBao maintainers consider the rewrap sample response's `creation_path` a
  documentation bug is upstream's call; I only report the measured divergence (§4a) — the
  page and the 2.7.2 binary disagree.

## 9. Receipts

All receipts live in `.ufo/waves/round-51/build/R51ScoutSource/` (copied from scratch before exit):

| file | content |
|---|---|
| `fetch-status.txt` | curl status/sha/bytes for all 9 URLs (5 canonical + 4 `/api-docs/` stubs) + `Last-Modified` + redirect behaviour |
| `locate-counts.txt` | every locate run with rc, word count and count |
| `empirical.txt` | dev-server measurements for T1/T2/T3/T4/T5 + raw-HTTP unauthenticated-lookup proof |
| `api-page-digests.txt` | raw + normalized digests for the four API pages, row-identity hashes, S108 row-identity check |
| `census-working-tree.txt` | `bash corpus/sources-census.sh` output on the working tree (the `SC_USEDBY_MISSING` finding) |
| `drivers/check.sh` | dev-server driver for T1/T3/T4/T5 (throwaway server, random port, random root token, EXIT trap) |
| `drivers/raw.sh` | raw-HTTP driver proving `sys/wrapping/lookup` is unauthenticated |
| `drivers/rewrap3.sh` | driver for the rewrap-vs-wrap `creation_path` divergence (§4a) |
| `drivers/t2.sh` | driver for T2 (wrap TTL lapses, secret stays readable) |

The `drivers/` scripts contain no token, nonce or secret value; the root token is generated at run
time inside each script and never echoed.

## 10. Tooling

**No tool was installed, upgraded or replaced by this seat.** No `pacman`, no `uv tool install`, no
`cargo`/`npm -g`, no writes to `~/.local/bin` or any PATH directory. The `bao` binary was used
read-only from `~/.local/bin/bao` (sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`,
which equals the C1 counter's `PIN_BAO`). `curl` and `python3` were the only other binaries used.

**Process hygiene:** every `bao server -dev` I started (all bound to 127.0.0.1 on a random free
port, under `setpriv --pdeathsig KILL`, with a fresh random root token that lived only in my
scratch dir) was killed by its `EXIT` trap before the script returned. Verified after the fact:
`pgrep -af "bao server" | grep -v "dev-root-token-id=r51-"` returns **nothing** — every still-running
`bao server` belongs to another seat's run of the reference trial (which mints `r51-`-prefixed root
tokens), and none of my hex-prefixed (`secrets.token_hex(16)`) servers survived. I did not kill any
process I did not start.
No root token, wrapping token, nonce, password or plaintext secret value appears in this report,
in any receipt, or in any file I wrote.

