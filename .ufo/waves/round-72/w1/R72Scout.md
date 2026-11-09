Author: R72Scout (scout)

# Round 72 — kagi scout: semantic leg (freshness) + next-round leads

Scope: read-only reconnaissance for the semantic leg of C1 and for the next round's
clock population. I read the frozen plan, both counters, the controls runner and their
receipts, the release-clock table, the clock-rearm ledger, the round-47 re-verification
table, the QUALITY bar and the round-71 closure, then re-opened the vendor surfaces myself.
I wrote nothing outside this seat's directory and my report; the lane was not modified.

Read-only tools used: `git show`/`git archive`/`git ls-files` (read-only), `curl -fsSL
--compressed` with the lane's own request profile for public vendor pages, `grep`, `awk`,
`sed`, `python3` (only `corpus/rendered-text-v1.py`, `corpus/release-clock.py` and
`corpus/anchor-pins.sh` from the lane, executed on scratch copies of the tree). No tool was
installed this round, so no tooling record is owed (operator rule 2026-10-19: nothing
installed). No credential, vault, `op` item or secret was read; the four URL classes touched
are public GitHub release pages/feeds, public vendor doc pages and the public 1Password CLI
release-notes article.

## 0. What the frozen claim asserts, and where the semantic leg sits

C1 (`plans/round-72-c1.sh`, header verbatim): "value = number of ids in F = {S013 S014 S015
S016 S021 S022 S023 S024 S025 S026} … that are ARMED, VERIFIED, SOURCED and LIVE, when GATE
= 1, FRESH = 1 and CENSUS = 1, else 0; target 10 (BASE 0)."

The plan names the semantic leg explicitly as an **uncounted** conjunct (U1): "quote location
is not semantics; the round-47 `teaching-holds` verdict is the semantic leg at the same
releases". So my job is to answer a question the counter deliberately does not answer:
**do Vault v2.2.1 and OpenBao v2.7.2 change anything the ten re-armed rows teach?**

Answer in one line: **No — neither release touches any of the five taught mechanics
(JWT/OIDC audience matching, the Kubernetes TokenReview note, token TTL/revocation/child-token
cascade, the lease requirement, or KV v2 `max_versions`).** The evidence is below.

## 1. Semantic leg: what Vault v2.2.1 and OpenBao v2.7.2 actually change

### 1a. Vault v2.2.1 — release notes

Source: https://github.com/hashicorp/vault/releases/tag/v2.2.1 (GitHub release page body,
rendered), accessed 2026-11-09; captured locally as
`.ufo/waves/round-72/w1/R72Scout/release-notes-vault-v2.2.1.txt`
(sha256 `350a9d0b858423030beaf73fb412ff085604eda641ab115b41fb86617f6da5cc`). Released
2026-10-22 (tag commit `0e7c41b`); the repo's `CHANGELOG.md` at tag `v2.2.1` has **no 2.2.x
section** (its newest heading is `## 2.1.1`), so the release page is the only changelog
surface for 2.2.1 — a fact the lane's S174 anchor does not record.

Located lines (each ≤25 words, verbatim):

- "core/policy: Fixed a cache-key collision vulnerability that could cause policy-name aliases to resolve to the immutable root policy."
- "Root-policy aliases are now explicitly rejected at entity, group, token, authentication-response, and agent-registry policy assignment boundaries."
- "core: Bump Go version to 1.27.3 to resolve CVE-2026-111943 ."
- "agent: Add auto auth SPIFFE method."
- "containers/alpine: Upgrade ca-certificates-bundle to 20261020-r0 to distrust eMudhra intermediate chains."

**Verdict against the ten rows: no change.** A sweep of the rendered release-note body for
`aud`, `bound_audiences`, `TokenReview`, `max_versions`, `revoke`, `child.token` returns
**0 hits each** (receipts.txt §4). Every "lease" hit in the file is a substring of
release/released/Freleases/Please — there is no lease-mechanic line. The two security items
are (a) the policy-alias/cache-key collision fix and (b) a container CA trust-store update;
neither is one of the five taught mechanics.

### 1b. OpenBao v2.7.2 — release notes and CHANGELOG

Source: https://github.com/openbao/openbao/releases/tag/v2.7.2, accessed 2026-11-09; copied as
`.ufo/waves/round-72/w1/R72Scout/release-notes-openbao-v2.7.2.txt`
(sha256 `035bfc55f104684a3fb925da09e06e74b48cedbdbccc7fd8ff5ba931d8855d51`). Cross-read
against the repo's `CHANGELOG.md` at tag `v2.7.2` (copied as
`CHANGELOG-openbao-v2.7.2.md`, sha256 `5995764b1315b92dffd15ff0d5cc3d46454e488687c3f26b4cc069e90f83a328`),
whose `## 2.7.2` section is identical to the release-page body — so for OpenBao the two
surfaces agree, unlike Vault's.

Located lines (≤25 words each, verbatim):

- "auth/cert: Add resolve path canonicalization to CRL paths. GHSA-736f-82w7-hj22 ."
- "secrets/approle: Add resolve path canonicalization in Role ID paths. GHSA-736f-82w7-hj22 ."
- "secrets/identity: Ensure `client_type=public` is denied with `client_credentials=true` in the OIDC provider. GHSA-q824-44ff-f5j5 ."
- "secrets/ssh: Deny wildcards ( * ) in SSH certificate identity templating by default."
- "secrets/transit: Ensure imported key backup does not allow clobbering arbitrary keys through path traversal. GHSA-5pmx-2p74-x478 ."
- "core: Fix sudo-capable tokens failing sudo checks on their final use. [ GH-4158 ]"
- "auth/oidc: Fix login in direct callback mode by including the namespace in the redirect URI. [ GH-4199 ]"

**Verdict against the ten rows: no change.** Sweep for `aud`, `bound_audiences`, `TokenReview`,
`max_versions`, `revoke`, `child.token` on the rendered release body: **0 hits each**. The
nearest neighbours are deliberately *other* surfaces: the `client_type=public` denial is the
identity secrets engine's OIDC provider (OpenBao as an issuer), not the JWT auth method's
audience check that S014/S025/S022 teach; the `auth/oidc` fix is the OIDC *login* method
(redirect URI namespace), not `auth/jwt`; the `core` sudo fix concerns sudo capability on a
token's final use, not the parent→child revocation cascade S016/S021/S026 teach.

### 1c. Cross-check: the ten teaching pages themselves did not move

The re-arm binds the clocks to release identities, but the teaching rows are `rendered-quote`/
`derived:` rows over **version-branch** doc routes, not over release-pinned pages. I measured
whether the taught text moved between the round-47 capture, the round-72 capture and a live
re-fetch by me today:

- OpenBao pages: **byte-identical** to their round-47 captures (S014/S025 63046 B, S015 55824 B,
  S016/S021/S026 47384 B — all `cmp` clean).
- Vault pages: raw bytes differ only in a per-request nonce string (33 occurrences) and one
  timestamp; the **rendered text is unchanged** — `corpus/rendered-text-v1.py digest` gives the
  same `normalized_sha256` for r47, r72 and my live fetch on S013/S023
  (`0e62e056…`), S022 (`53f5230c…`), S024 (`7c5a19e2…`), and the same for the OpenBao rows
  (`ca496ad8…` S014/S025, `2732189767…` S015, `ed949658…` S016/S021/S026).
- Every taught quote **locates on the pages I fetched live today** (receipts.txt §6): lease
  count=1, bound_audiences count=1, child-token count=1, TTL count=1, TokenReview count=1,
  `max_versions` count=3.

**Semantic conclusion.** The round-47 `teaching-holds` verdicts still stand at 2.2.1/2.7.2, and
the two releases add nothing to any taught mechanic. The re-arm is therefore *semantically
sound* on the count of ten. Two residual semantic facts the plan does not name, which matter
for the next round:

1. **The taught pages are branch routes, not release-pinned pages.** The Vault JWT route
   renders `v2.x (latest)` in its own version selector (verified live today in the raw body:
   `"versions":[{…"label":"v2.x (latest)"…},{"name":"v1.21.x"…}]`), and the OpenBao pages
   render `Version: Version 2.7.x`. So re-arming at 2.2.1/2.7.2 binds a clock to a release
   whose *documentation branch* keeps moving independently of the release. A future 2.7.3 can
   ship with the 2.7.x docs unchanged, and the docs can change inside 2.7.x with no release
   at all. The clock measures *release identity*, not *doc content*; the semantic leg is
   therefore carried by re-reading the branch, which the round-47 table did for 2.2.1/2.7.2 and
   which I re-verified live today, not by the release notes.
2. **The semantic leg's authority is the round-47 verdict plus the page re-fetch, not the
   release notes.** No release-note line in either release can falsify a taught sentence
   here, because the taught sentences live in docs, not in release notes. The falsifiers for
   these rows are doc-branch edits, not ship notes.

## 2. Feed identity re-verification (the ARMED/SOURCED legs' ground truth)

Independently fetched today (2026-11-09) with the lane's request profile:

| feed | my fetch sha256 | lane capture | equal? | lane parser's newest stable |
|---|---|---|---|---|
| `https://github.com/hashicorp/vault/releases.atom` | `3ead3d0f906c3a6a4467080bb991b747fa29a2604e10411921090b2e7a0e6ffc` | `.ufo/waves/round-72/capture/S174.body` | **yes** (`cmp` clean) | 2.2.1 |
| `https://github.com/openbao/openbao/releases.atom` | `a54d1a5314ca701684fe65b3e4687c0519d45164c8cd177c950ff75bfd5f2e0e` | `.ufo/waves/round-72/capture/S175.body` | **yes** (`cmp` clean) | 2.7.2 |

The lane's own BASE-pinned `corpus/release-clock.py` parser on my independent bytes returns
2.2.1 and 2.7.2 — the same identities S174/S175 claim. The first stable entry in each feed is
`<title>v2.2.1</title>` / `<title>v2.7.2</title>` (raw-literal, count 1 each), and the parser
excludes `sdk/` module tags and `-rc` prereleases as S174/S175 state.

**One gap the plan's "supersedes" wording papers over:** the OpenBao feed's newest stable by
*publication order* is v2.7.2 (updated 2026-10-26T20:24:37Z) but it sits **immediately above
v2.6.5** (updated 2026-10-26T20:23:12Z) — a maintenance release on the older 2.6 line, one
minute earlier, published from the same security batch. I checked the OpenBao **v2.6.5**
release page: it carries the same five GHSAs (`GHSA-736f-82w7-hj22`, `GHSA-q824-44ff-f5j5`,
`GHSA-h76r-48x5-36hg`, `GHSA-5pmx-2p74-x478`) plus `auth/ldap`/`auth/radius` path
canonicalization. Consequence for the next round: the derived clocks anchored at 2.7.2 will
**not** fire on a future 2.6.x maintenance release, because the parser takes the numerically
newest stable across the whole feed (`max` over X.Y.Z), and 2.6.x < 2.7.2. The lane's next
"the clock fires again" fixture should therefore name a **2.7.3-or-later** stable, not "the next
tag". (Confirmed empirically with the lane parser on a synthetic feed body: injecting a later
`v2.6.6` entry leaves the parsed newest stable at 2.7.2; injecting `v2.7.3` moves it to
2.7.3.)

## 3. The other four fired clocks (S012, S027, S028, S072) and what each needs next round

Measured at candidate `a947a42c`: `plans/round-36-c3.sh` → `RELEASE_CLOCK: CLEAN
(on_release=32 bound=32 unbound=0 observed=32 fired=4 derived=17)` rc 0; the four `fired`
rows are exactly **S012, S027, S028, S072** (BASE had 14 fired). All four are *not* in F and
are *not* `derived:` — each is an original named anchor whose successor row exists but is not
release-driven:

| id | feed today | anchored | observed | why it still fires | what it would need |
|---|---|---|---|---|---|
| **S012** Vault JWT/OIDC audience (docs) | S034 (anchor cell `v2.2.0`) | `v1.21.x` (a docs-branch label, not a release) | 2.2.1 | anchor names the *page's pinned docs version*; the live route now serves `v2.x (latest)`, so the label is stale in the other direction | either retire the clock row (the teaching survives in S022/S023, already re-armed) or re-point it at S174 like S022; either way the registry anchor cell needs a successor row, not an in-place edit (CORPUS.md SOURCES rule 2) |
| **S027** Python `re` whitespace | S036 (`3.15.0`) | 3.15.0 | 3.15.2 | Python ships 3.15.1/3.15.2 on the same branch the docs now serve (`Python 3.15.2 documentation`, verified live) | successor rows S095/S096 already carry the 3.15.2 docs teaching but sit at `recheck 90d` with **no clock row**; making them release-driven needs the S091 feed row bound + derived: notes + a re-fetch of the two docs pages (I re-fetched both live today: whitespace quote count=1, HTML-5-rules quote count=1, both pages labelled "Python 3.15.2 documentation") |
| **S028** Python `html.unescape` | S036 (`3.15.0`) | 3.15.0 | 3.15.2 | same | same as S027 |
| **S072** op CLI release identity | S112 (`2.42.0`) | 2.41.1 | 2.42.0 | the 2.42.0 release shipped and the clock fires as designed; §11.2 of `op-ref-consumption.md` was already re-measured on op 2.42.0 | retire or re-arm: the article at `https://app-updates.agilebits.com/product_history/CLI2` now carries the 2.42.0 entry ("2.42.0 (build #2420001 ) – released 2026-11-03"), so a successor row quoting that entry is available; the 1Password CLI RSS feed carries `<title>1Password CLI 2.42.0</title>` as newest stable (lane parser with the declared `1Password CLI` prefix → 2.42.0; **without** the prefix the same feed is REFUSED — "feed has no stable X.Y.Z release entry", so the prefix declaration is load-bearing) |

**Mechanics worth knowing before the next freeze (measured on scratch copies of the candidate
tree, lane not touched):**

- The default receipt is digest-pinned: `corpus/release-clock.py:28`
  `DEFAULT_RECEIPT_SHA256 = "022e8299…c2f9"` must equal the sha256 of
  `.ufo/waves/round-72/final/observe-r72.json` (it does today). Hand-editing the receipt to
  drop a retired id makes the **whole** bundle invalid and every row reads
  `RECEIPT-MISMATCH`; a retirement needs a fresh `--observe` run (new receipt, new pin).
- `plans/round-36-c2.sh` compares the **historical** round-36 receipt (`.ufo/waves/round-36/
  controls/observe-live.json`), not the default one, so its number moves when the *table's*
  feed ids change: BASE 3 → candidate 13 (the ten re-armed rows name S174/S175 and anchors
  the round-36 receipt never recorded). Any next-round retirement moves it again.
- `plans/round-36-c3.sh` expects the default receipt, so it is the row that moves with a
  re-pointed table (BASE `fired=14` → candidate `fired=4`), and the migration journal at
  `.ufo/waves/round-72/expectation-migrations.json` already records both moves old→new.

## 4. A gap I found in the integration state: anchor pins for the newly superseded S089/S090

`corpus/anchor-pins.tsv` pins **S034 S035 S036 S039** — the release-feed rows that are
superseded. At BASE and at the candidate commit, the superseded release-feed rows are exactly
those four and all four are pinned. In the **integration working tree** S174/S175 now supersede
**S089/S090** (the L1's own fix for M72-1, per `.ufo/waves/round-72/w1/R72ExecReplica.md`), so
S089 and S090 become superseded release-feed rows that are **not pinned**.

Measured on a full scratch copy of the candidate tree with S089's anchor cell rewritten in
place (`v2.2.1` → `v2.2.0`, i.e. exactly the QM40 invisible-rewrite class):

- `bash corpus/anchor-pins.sh` → `ANCHOR_PINS: CLEAN (pins=4)` rc 0
- `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=166 …)` rc 0
- `bash plans/round-36-c3.sh` → `RELEASE_CLOCK: CLEAN (… fired=4 derived=17)` rc 0

So a rewrite of a superseded feed row's anchor cell is invisible to every gate once that row
is superseded and unpinned. Adding S089 and S090 to `corpus/anchor-pins.tsv` (with their
anchor-cell digests) closes it; the pin file is a plain `id<TAB>anchor_sha256` list and
`corpus/anchor-pins.sh` reads it as its whole population. This is a next-round lead, not a
defect in the frozen claim (the candidate commit's S174/S175 supersede S034/S035, which are
pinned, so the candidate tree is clean under the pin gate as it stands).

## 5. Sibling-lane-irrelevant ground found while re-opening the two releases (out of scope, reported not absorbed)

The OpenBao 2.7.2 / Vault 2.2.1 notes carry ground this lane does not own:

- **Go toolchain CVE** — "core: Bump Go version to 1.27.3 to resolve CVE-2026-111943 ." —
  dependency-CVE triage, not secret custody. No sibling `PROVINCE.md` claims Go CVE triage
  (checked all 21 lanes); the lane's own adjacent list names chousa (research method),
  kasegi/kumitate (secret-shaped tripwires) and mori/tsukuroi/kotoba/souji/tabi/mado/kama/
  kake/kaidoku/kengaku/lore/kotodama/kumitate/tabi/tameshi domains — none of them is
  OpenBao/Vault secret custody. So this ground is *unclaimed* rather than *contested*: report
  it, do not absorb it.
- **GHSA advisory triage as a workflow** (five advisories in 2.7.2) — kasegi's declared ground
  is "bounty & security research" and its F36 row is the GitHub repository-advisories API
  contract; the *severity/prioritisation* reading of these GHSAs is kasegi's, the *mechanics*
  ("approle Role ID paths are canonicalised", "the identity OIDC provider denies
  client_type=public with client_credentials=true") are kagi's product ground and belong to a
  future kagi round on those engines — but note the lane already holds approle custody
  (`corpus/knowledge/openbao-approle-secret-id-custody.md`, round 60) whose scope line says
  "OpenBao 2.7.2 only", so the GHSA-736f-82w7-hj22 Role-ID path canonicalisation is a real
  re-measure target for that entry.
- **SSH certificate identity templating** (`secrets/ssh`, GHSA-h76r-48x5-36hg) and **transit
  imported key backup** (GHSA-5pmx-2p74-x478) — OpenBao engines the lane does not yet cover
  (its PKI core is rounds 70–71; transit/SSH are unclaimed ground).
- **Vault 1.17-vs-2.21 docs version selector** — `v1.21.x` is still listed in the Vault JWT
  page's version menu alongside `v2.x (latest)`; the lane's S012 anchor names that pinned
  label. This is lane-internal (S012's own successor), not sibling ground.

No sibling lane claims the Vault/OpenBao release feeds or the ten teaching pages: across all
21 sibling `PROVINCE.md` files, the only mentions of vault/openbao/hashicorp are other lanes
declaring kagi's ownership ("kagi owns secrets, vault operations, and credential-hygiene
evidence" — mori; "Credentials, secrets, tokens, vault refs — kagi-shokunin's province" —
souji). Overlap = 0, consistent with the round-37 connector's finding.

## 6. Next-round leads (sources I would open), in priority order

1. **Retire or re-arm S012** (the only remaining fired row whose anchor is a *docs label*
   rather than a release). Sources: `https://developer.hashicorp.com/vault/docs/auth/jwt`
   (version menu now `v2.x (latest)`), S022/S023 (the already re-armed successors), and the
   round-47 `teaching-holds` row for S012 in `corpus/fired-reverify.tsv` (which already
   re-verifies S012's audience teaching at 2.2.1 — the semantic leg for S012 exists and is
   unused by any clock).
2. **Make the Python pair release-driven**: S027/S028 → successor rows S095/S096 (both
   already carry the 3.15.2 docs teaching and the quotes locate live), bound to feed row
   **S091** (whose anchor cell names `Python 3.15.2` exactly — QM28's derived-anchor binding
   is satisfiable without a new feed row), with `derived:` notes and `recheck on-release`.
   Sources: `https://docs.python.org/3/library/re.html`, `.../html.html` (both served
   "Python 3.15.2 documentation" today), `https://www.python.org/downloads/feed.rss` (newest
   stable 3.15.2, 3.16.0a1 still a prerelease).
3. **Close S072**: successor row quoting the 2.42.0 article entry (verified live today:
   "2.42.0 (build #2420001 ) – released 2026-11-03"), bound to S112 with the declared
   `1Password CLI` title prefix (without that prefix the feed is refused by the parser).
4. **Add S089 and S090 to `corpus/anchor-pins.tsv`** once their supersession lands (§4 above);
   the pin file's population should be "every superseded release-feed row".
5. **Pin the "next release" fixture to a numerically newer stable** (2.7.3+ / 2.2.2+), not
   "the next tag": OpenBao's parallel 2.6.x line publishes maintenance releases that carry the
   same advisories and would not fire a 2.7.2-anchored clock (§2).
6. **Re-verify the ten teaching rows on their doc branches** (not on release notes) whenever
   the branch moves: the branch is `v2.x (latest)` for the four Vault rows and
   `Version 2.7.x` for the six OpenBao rows, so a doc edit inside a branch can change the
   taught sentence with no release event at all.

## 7. What I did not do

- I did not re-run the frozen C1/C2 counters (the L1's receipts already record
  `value=10` / `value=0`, and the counters are the attack seats' and integrator's instrument,
  not the scout's).
- I did not write to the lane, to the fleet repo outside my seat dir, or to any sibling lane;
  I did not commit, push, or run any mutating git/jj command.
- I did not read or print any credential, vault, `op` item or token-shaped value; the public
  1Password release-notes article contains only build numbers and release dates.

FINDING R72SCOUT-1 neutral — Neither release changes any taught mechanic: sweep of the rendered Vault v2.2.1 and OpenBao v2.7.2 release-note bodies for `aud`/`bound_audiences`/`TokenReview`/`max_versions`/`revoke`/`child.token` returns 0 hits each, and the taught quotes still locate on the pages re-fetched live on 2026-11-09 (receipts.txt §4, §6).
FINDING R72SCOUT-2 neutral — The taught doc pages are branch routes, not release-pinned pages (Vault `v2.x (latest)`, OpenBao `Version: Version 2.7.x`); the re-arm binds a clock to a release while the taught text lives on a branch that moves independently, so release notes can never falsify these rows and doc-branch edits can.
FINDING R72SCOUT-3 falsifies-wording — The next-release fixture must name a numerically newer stable (2.7.3+/2.2.2+), not "the next tag": OpenBao's feed carries v2.6.5 (one minute before v2.7.2) on the older 2.6 line with the same five GHSAs, and the lane parser takes the max X.Y.Z, so a 2.6.x maintenance release cannot fire a 2.7.2-anchored clock.
FINDING R72SCOUT-4 neutral — Adding S089/S090 to corpus/anchor-pins.tsv is needed once the integration's `supersedes S089/S090` change lands: with the candidate tree and S089's anchor cell rewritten in place, anchor-pins.sh, sources-census.sh and round-36-c3.sh all read CLEAN (measured on a scratch copy), so the rewrite is invisible.
FINDING R72SCOUT-5 neutral — The four remaining fired rows are S012, S027, S028, S072, and their semantic legs are already available or one page-re-fetch away: round-47's fired-reverify.tsv re-verifies S012 at 2.2.1, S095/S096 carry the 3.15.2 Python teaching with live quotes locating, and the 1Password article's 2.42.0 entry is quotable.
FINDING R72SCOUT-6 neutral — Ground in these two releases that this lane does not own: the Go 1.27.3 CVE bump (dependency-CVE triage) and the GHSA severity/prioritisation workflow (kasegi's declared bounty-and-security-research ground); the mechanics themselves (approle Role ID canonicalisation, identity OIDC provider client_type denial, SSH cert identity wildcards, transit key-backup traversal) are unclaimed lane-adjacent product ground.
FINDING R72SCOUT-7 neutral — Vault's repo CHANGELOG.md at tag v2.2.1 has no 2.2.x section (newest heading 2.1.1), while OpenBao's CHANGELOG.md at v2.7.2 does carry 2.7.2; a next-round note-level source must use the GitHub release page for Vault and may use either for OpenBao.
FINDING R72SCOUT-8 neutral — Independent feed re-fetch on 2026-11-09 is byte-identical to the lane's S174.body/S175.body captures and the BASE-pinned parser returns 2.2.1/2.7.2 from my bytes, so the ARMED/SOURCED legs' ground truth reproduces off the lane's own captures.
SEAT-STATUS: complete
