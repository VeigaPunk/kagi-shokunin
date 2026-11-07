# R53ScoutFeeds — independent live re-opening of the round-53 C1 sources

Seat: `R53ScoutFeeds` (scout, leaf member — no subagent dispatch).
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Scope: read-only re-observation of S111 (new), S033, the S103/S104 tag pages, the rejected 1Password CLI feeds, and the S111 registry row at CANDIDATE `36d0a86a7539890eb079d893c9a58e37e84d953d`.
Scratch: `$HYAKU_SCRATCH/kagi-r53/R53ScoutFeeds/` (`HYAKU_SCRATCH=/fast/scratch/hyaku`). Receipt copies: `.ufo/waves/round-53/build/R53ScoutFeeds-receipts/` (with `SHA256SUMS.txt`).
No lane file was edited; no token, secret, `op://` path, vault or account was read or written.

**No tool was installed or upgraded** this seat (nothing in the RULES.md tooling chain was needed; all checks ran on the host's existing `curl`, `python3`, `git`).

---

## 1. Fetches — every request, exact command, exit code, status, bytes, sha256

Request profile used for every GET (as assigned):
`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`

| # | URL | exit | HTTP | bytes | sha256 |
|---|---|---|---|---|---|
| F1 | `https://github.com/FiloSottile/age/releases.atom` | 0 | 200 | 40379 | `32517112c2ecb63ce97dfbbdf9c47569678738fda984da524b2cd38129d8f21d` |
| F2 | `https://github.com/getsops/sops/releases.atom` | 0 | 200 | 253037 | `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6` |
| F3 | `https://github.com/getsops/sops/releases/tag/v3.13.3` | 0 | 200 | 176342 | `45a0f7312a7b45bcf427e98a8e70576fd4da84de66741c5bbd80f0ac5a730d34` |
| F4 | `https://github.com/FiloSottile/age/releases/tag/v1.3.2` | 0 | 200 | 153082 | `8c83a46ab2c9ba0418c90d86458a95f4120d94fa0614966693088955307e0f63` |
| F5 | `https://releases.1password.com/developers/cli/index.xml` | 0 | 200 | 45175 | `2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2` |
| F6 | `https://github.com/FiloSottile/age/releases.atom` (repeat, byte-stability probe) | 0 | 200 | 40379 | `32517112c2ecb63ce97dfbbdf9c47569678738fda984da524b2cd38129d8f21d` |
| F7 | `https://github.com/getsops/sops/releases/tag/v3.13.3` (repeat) | 0 | 200 | 176341 | `f6ba680304978375b7b0f6e4362580473d050524e5c7b537839ff9cb819bce2f` |
| F8 | `https://github.com/FiloSottile/age/releases/tag/v1.3.2` (repeat) | 0 | 200 | 153078 | `6cba275a64d70759a84fb322b36e81fd32e7815ebcf670de4a9df3fe94d9c7a8` |
| F9 | `https://github.com/FiloSottile/age/releases/tag/v1.3.1` (control) | 0 | 200 | 152581 | `1abc8cf1d589fde537837c3babb4b9ef06ff518b97f0014f5be1b1c6c61357ad` |
| F10 | `https://app-updates.agilebits.com/product_history/CLI2.rss` | 22 | **404** | 25 | `90485e790b854d3285bcbcb40fbd99ddd6322bec34f66127f1cb6c7972fd1247` |

**Failed fetch, recorded with its error text (F10):**
```
curl: (22) The requested URL returned error: 404
```
Body of the 404 (fetched separately without `-f`, same URL, HTTP 404, 25 bytes): `Unknown product: CLI2.rss`
This reproduces the lesson's recorded rejection: *"HTTP 404, 'Unknown product: CLI2.rss'"*. **Rejection (b) holds.**

**F1 vs the L1 capture.** `sha256sum .ufo/waves/round-53/capture/S111.body` = `32517112c2ecb63ce97dfbbdf9c47569678738fda984da524b2cd38129d8f21d`, 40379 bytes — **byte-identical to my independent F1**. The capture is not stale and not doctored; my live body and the lane's capture are the same bytes.

**Byte-stability of the feeds vs the tag pages.** F6 == F1 byte-for-byte (same sha256). F7 != F3 and F8 != F4: the two GitHub *release HTML pages* differ between two consecutive fetches. The first differing byte is at offset 17649 and is the per-response nonce:
```
A: <meta name="fetch-nonce" content="v2:4afc3675-f567-5236-464d-fd61b5dbd5e2">
B: <meta name="fetch-nonce" content="v2:701e5288-6e63-559c-2570-403c05bc5e04">
```
[INFERENCE] The tag pages carry a per-response nonce, so their sha256 is inherently volatile; the Atom feeds do not (same bytes on repeat). This is consistent with the lane's own capture profiles: S103/S104 use `decoded-http-body-v1`, while the feed rows S033/S111 use `decoded-http-body-volatile-v1`.

---

## 2. Newest stable parsed vs the pins

I parsed the newest stable `X.Y.Z` myself (entry titles, prereleases excluded), independently of the gate, and then cross-checked with the gate's own parser `corpus/release-clock.py:parse_latest_version` (imported and run read-only against my fetched bytes).

### age feed (F1)
Entries, in feed order, with their `<updated>` and tag link:

| # | title | `<updated>` | tag link |
|---|---|---|---|
| 0 | `age v1.3.2` | 2026-08-29T18:12:38Z | `/releases/tag/v1.3.2` |
| 1 | `age v1.3.1` | 2026-08-29T17:55:50Z | `/releases/tag/v1.3.1` |
| 2 | `age v1.3.0: post-quantum (and more)!` | 2026-02-02T16:30:34Z | `/releases/tag/v1.3.0` |
| 3 | `age v1.2.1: security fix` | 2025-12-31T15:10:08Z | `/releases/tag/v1.2.1` |
| 4 | `age v1.2.0` | 2025-12-31T15:12:29Z | `/releases/tag/v1.2.0` |
| 5 | `age v1.1.1` | 2022-12-26T20:40:35Z | `/releases/tag/v1.1.1` |
| 6 | `age v1.1.0: plugin and YubiKeys support` | 2022-12-26T15:02:27Z | `/releases/tag/v1.1.0` |
| 7 | `age v1.1.0-rc.1: plugin and YubiKeys support` | 2022-06-11T16:44:04Z | `/releases/tag/v1.1.0-rc.1` — **prerelease, excluded** |
| 8 | `age v1.0.0 🏁` | 2021-09-07T17:27:12Z | `/releases/tag/v1.0.0` |
| 9 | `Never two without three` | 2021-09-06T16:49:22Z | `/releases/tag/v1.0.0-rc.3` — **prerelease tag, excluded** |

- My own parse: **newest stable = 1.3.2**.
- Gate parser on the same bytes: `parse_latest_version(age.atom) -> 1.3.2`.
- Lane pin (S104 / release-clocks.tsv row S104): **1.3.2** → **AGREE**.

### sops feed (F2)
Entries: `v3.13.3` (2026-07-23T05:29:11Z), `v3.13.2` (2026-06-30T05:18:19Z), `v3.13.1` (2026-05-16T14:33:57Z), `v3.13.0` (2026-05-08T18:11:59Z), then 3.12.x, 3.11.0, 3.10.2, 3.10.1, … — **no prerelease titles present**.
- My own parse: **newest stable = 3.13.3**.
- Gate parser: `parse_latest_version(sops.atom) -> 3.13.3`.
- Lane pin (S103 / clock row S103): **3.13.3** → **AGREE**.

Both pins hold on the live feeds. The round-53 C1 claim ("the pins are watched by live release clocks and have not fired") is confirmed by independent re-fetch.

---

## 3. Quote counts (assignment item 2)

| where | `<title>age v1.3.2</title>` count | byte offset |
|---|---|---|
| my live body (F1) | **1** | 725 |
| L1 capture `.ufo/waves/round-53/capture/S111.body` | **1** | 725 |

Identical, count 1, offset 725 — matching the lesson's declared located quote (count 1, offset 725). `raw-literal-v1` locating is reproduced exactly. For comparison, `<title>v3.13.3</title>` count = 1 in the sops feed.

---

## 4. Are the tag pages still marked "Latest"? (assignment item 3)

| URL | page title | `Latest` badge (`Label--success Label--large">Latest</span>`) | release line | still Latest? |
|---|---|---|---|---|
| F3 sops `v3.13.3` | `Release v3.13.3 · getsops/sops · GitHub` | **2** (desktop + mobile variants, both pointing at `/getsops/sops/releases/latest`) | `released this 23 Jul 05:27` (`datetime="2026-07-23T05:27:57Z"`) | **YES** |
| F4 age `v1.3.2` | `age v1.3.2` | **2** (both pointing at `/FiloSottile/age/releases/latest`) | `released this 29 Aug 17:55` (`datetime="2026-08-29T17:55:36Z"`) | **YES** |
| F9 age `v1.3.1` (control) | `age v1.3.1` | **0** | `datetime="2025-12-28T12:03:04Z"` | no (correctly superseded) |

The two "Latest" occurrences per page are the desktop and mobile renderings of the same badge (one `d-none d-md-inline-block`, one `d-md-none`), not two releases. The S103/S104 quotes are still located in the live pages: `v1.3.2 is a minor release with a wide range of fixes and hardening` → 4 occurrences in F4; `Release v3.13.3 · getsops/sops · GitHub` → the `<title>` of F3. The age release commit `b74dce4` is present in F4 (`b74dce4cdbe35b5e5f66c06d9612b72f89028758`).

**Both pins remain the projects' current stable releases.**

---

## 5. The 1Password CLI feed (assignment item 4)

F5 `https://releases.1password.com/developers/cli/index.xml`, HTTP 200, 45175 bytes, sha256 `2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2`, `lastBuildDate Wed, 04 Nov 2026 00:00:00 +0000`. 27 `<item>`s.

**Newest op CLI version listed: 2.42.0** (`pubDate Wed, 04 Nov 2026`, i.e. **after** the lane's S072 pin 2.41.1 of 2026-10-21). Full ordered tail: 2.39.0 (2026-08-14), 2.40.0 (2026-10-01), 2.41.0 (2026-10-12), 2.41.1 (2026-10-21), 2.42.0 (2026-11-04).

**Does the lane's rejection reason hold?** Yes, on both of its stated grounds:

1. *"the lane's op CLI row S072 states the 2.41.1 release identity, not that 2.41.1 is current, so there is no currency statement to watch."* — **Holds.** I grepped the whole candidate tree for a claim that op 2.41.1 is current/newest/latest: no lane document asserts it. S072's own `scope` cell reads *"op CLI 2.41.1 release identity (the version token `op --version` prints…)"*, and `corpus/QUALITY.md:252` (QM69) explicitly classifies a release-identity row as keeping a cadence. `corpus/knowledge/op-ref-consumption.md:393` cites S072 *"for the installed release's identity, not as evidence about bytes"*. There is no `on-release` clock bound to any 1Password URL: `corpus/release-clocks.tsv` has no feed row for `releases.1password.com` (only S007/S019 `rendered-quote` rows for `www.1password.dev` guide pages), and no S-row in `corpus/SOURCES.md` points at `releases.1password.com` at all. So no clock exists to fire and no currency statement exists to falsify.

2. *"the gate's title rule takes at most one leading word, so it reads 'feed has no stable X.Y.Z release entry' on this body."* — **Holds, confirmed empirically.** Running the lane's own parser on my F5 bytes:
   ```
   opcli.html -> ERROR ValueError feed has no stable X.Y.Z release entry
   ```
   The titles are `1Password CLI 2.42.0` — two leading words (`1Password CLI `), while `STABLE_TITLE_RE` is `^(?:[A-Za-z]+ )?v?([0-9]+\.[0-9]+\.[0-9]+)…`, at most **one** leading word. The feed's `<link>`s are `/developers/cli/2.42.0/`, which do not match `STABLE_TAG_HREF_RE` (`/releases/tag/v?X.Y.Z`). So the parser refuses the body. The lesson's "titles such as '1Password CLI 2.25.1'" is confirmed present in the live feed (count 1).

   Note the flip the lesson records is therefore exactly right: a currency statement *plus* a parser rule for multi-word product titles under its own selftest case.

**Additional live fact the lesson does not record (worth the lane's attention):** the feed now lists **2.42.0**, published 2026-11-04, which is *newer* than the pinned 2.41.1 of 2026-10-21. `corpus/knowledge/op-ref-consumption.md:395` scopes its claims to 2.41.1 and says *"a later release is unmeasured until the `on-release` clock fires"*, and line 371/397 carry `recheck: on-release of op`. But there is no op feed clock to fire, so nothing will fire on 2.42.0. [INFERENCE] This is the exact gap the lesson's flip names, now live and one release behind rather than hypothetical. The rejection itself remains correct; only the "Flip" condition has become reachable.

---

## 6. The S111 registry row at CANDIDATE — is every factual cell true of the live body? (assignment item 5)

Row as committed (`corpus/SOURCES.md:118` at `36d0a86`):

> `| S111 | age releases, GitHub release Atom feed — https://github.com/FiloSottile/age/releases.atom | code | A | age release identity (newest stable X.Y.Z tag) for the on-release clock of S104; release metadata only, not age behaviour | Entry titled age v1.3.2, tag link /releases/tag/v1.3.2, updated 2026-08-29T17:55:50Z; feed fetched 2026-11-07 | The newest stable age release is v1.3.2, so the S104 pin has not fired; a newer stable entry title fires it. Quote: "<title>age v1.3.2</title>" (first stable entry). | mined | 2026-11-07 | 90d | corpus/lessons/round-53.md |`

| cell | claim | live body (F1) | verdict |
|---|---|---|---|
| source | `https://github.com/FiloSottile/age/releases.atom` | F1 is that URL, HTTP 200 | **TRUE** |
| kind / tier / status | `code` / `A` / `mined` | not a body fact | n/a |
| anchor | "Entry titled **age v1.3.2**" | entry 0 title is `age v1.3.2` | **TRUE** |
| anchor | "tag link **/releases/tag/v1.3.2**" | entry 0 link is `https://github.com/FiloSottile/age/releases/tag/v1.3.2` | **TRUE** |
| anchor | "**updated 2026-08-29T17:55:50Z**" | the `age v1.3.2` entry's `<updated>` is **2026-08-29T18:12:38Z** (capture line 10 / live line 10). `2026-08-29T17:55:50Z` is the `<updated>` of the **next** entry, `age v1.3.1` (capture line 23 / live line 23) | **FALSE — off by one entry** |
| anchor | "feed fetched 2026-11-07" | today is 2026-11-07 | **TRUE** |
| teaches | "The newest stable age release is v1.3.2" | newest stable = 1.3.2 (my parse and the gate's) | **TRUE** |
| teaches | "so the S104 pin has not fired" | receipt row S104: `verdict: not-fired`, `parsed_version: 1.3.2` | **TRUE** |
| teaches | "a newer stable entry title fires it" | consistent with `parse_latest_version` semantics | **TRUE** |
| teaches | Quote `"<title>age v1.3.2</title>"` (first stable entry) | count 1, offset 725; it is the first entry | **TRUE** |
| recheck | `90d` | row value; gate refuses `on-release` for a feed row (BADFEED, `release-clock.py:613`) | consistent |

### The one false cell, in detail

The S111 anchor cell attributes the timestamp **2026-08-29T17:55:50Z** to the `age v1.3.2` entry. In the live body — and in the byte-identical L1 capture — that timestamp is the `<updated>` of the **`age v1.3.1`** entry; the `age v1.3.2` entry carries **2026-08-29T18:12:38Z**.

Raw live body (head), showing the two `<updated>` elements in document order:
```
 8  <entry>
 9    <id>tag:github.com,2008:Repository/187403699/v1.3.2</id>
10    <updated>2026-08-29T18:12:38Z</updated>     <- age v1.3.2 entry
11    <link … href="…/releases/tag/v1.3.2"/>
12    <title>age v1.3.2</title>
…
21  <entry>
22    <id>tag:github.com,2008:Repository/187403699/v1.3.1</id>
23    <updated>2026-08-29T17:55:50Z</updated>     <- age v1.3.1 entry
24    <link … href="…/releases/tag/v1.3.1"/>
25    <title>age v1.3.1</title>
```
The string `2026-08-29T17:55:50Z` occurs exactly **once** in the body — inside the v1.3.1 entry. The lesson's Gate section repeats the same attribution: *"the entry's `<updated>` is 2026-08-29T17:55:50Z, the same release day the S104 tag page shows."*

The S104 tag page (F4) shows `released this 29 Aug 17:55` (`datetime="2026-08-29T17:55:36Z"`) — so the *release day* (2026-08-29) and the published-at time (17:55) match the claimed timestamp to the minute, and both are 2026-08-29. But the *feed entry's* `<updated>` is a different field from the tag page's published-at, and for the v1.3.2 entry it is 18:12:38Z. [INFERENCE] The anchor was most likely written from the tag page's release time (or from the wrong `<updated>` line) rather than from the v1.3.2 entry's own `<updated>`.

**Impact.** The wrong timestamp does **not** touch the C1 measurement: the gate's binding test reads only the anchor cell's *version tokens* via `STABLE_TOKEN_RE`, and I confirmed on the live cell that `STABLE_TOKEN_RE.findall(anchor) == ['1.3.2','1.3.2']` → `derived_anchor_bound(anchor, '1.3.2') == True`. The date substring carries no `X.Y.Z` token, so the binding holds and the C1 predicate is unaffected. The defect is confined to one factual cell of one registry row (and its restatement in the lesson's Gate section). It is a **stated-fact accuracy** defect — the kind this lane's own C2 (self-count calibration) is about for numbers — not a gate-breaking one.

**Also note (minor):** the S111 row's `scope` cell says "for the **on-release clock** of S104", but S111 itself carries `recheck 90d`, and a feed row may never be `on-release` (the gate raises `BADFEED`, `release-clock.py:613`). The wording refers to S104's clock (S104 *is* `on-release`, and its clock row's `feed_source_id` is `S111` with `feed_url` = the age atom — correct), so the sentence is defensible, but "on-release clock of S104" could be misread as describing S111's own cadence. [INFERENCE] Worth a wording pass, not a correctness fix.

---

## 7. Cross-checks against the committed receipt and the counter

- Receipt `.ufo/waves/round-53/final/observe-r53.json`: 31 observations, file sha256 `f927b4318dee90ad3e2a8e2f899fcd2e37c43e833e7c3c3705aa5b5723d37c9a` — matches `DEFAULT_RECEIPT_SHA256` in `corpus/release-clock.py`. Rows S103 and S104 in that receipt carry `parsed_version` 3.13.3 and 1.3.2, `verdict: not-fired`, and sha256 values **identical to my independent fetches** (sops `47a224ad…`, age `32517112…`). The receipt is corroborated by a second, independent fetch path.
- `bash plans/round-53-c1.sh 36d0a86a7539890eb079d893c9a58e37e84d953d` → exit 0, last line:
  `C1_CURRENCY_CLOCKS: value=2 watched=2 gate=1 guard=1 (ok=S103 S104; bad=; gate-line=RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17))`
- `bash plans/round-53-c1.sh c1953d4afc19a5a336a58685c00ab5260bcfea1c` (BASE) → exit 0, last line:
  `C1_CURRENCY_CLOCKS: value=0 watched=0 gate=1 guard=1 (ok=; bad=S103:recheck=90d S104:recheck=90d; gate-line=RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15))`
  BASE 0 → CANDIDATE 2, target 2, both as declared.
- C1's own named ceiling says the *live leg* — "an independent re-fetch of both feeds, newest stable compared with the pins" — is the non-author check that catches a forged receipt. This seat ran exactly that leg, independently of the lane's tooling, and it agrees: 1.3.2 and 3.13.3, both not-fired.

---

## 8. Summary table — URL, status, bytes, sha256, newest stable parsed, pin, agree/disagree

| URL | HTTP | bytes | sha256 | newest stable parsed | pin | agree? | reason |
|---|---|---|---|---|---|---|---|
| `https://github.com/FiloSottile/age/releases.atom` (S111) | 200 | 40379 | `32517112c2ec…f21d` | **1.3.2** | 1.3.2 | **AGREE** | entry 0 `age v1.3.2`; v1.3.1 (17:55:50Z) and v1.1.0-rc.1 / v1.0.0-rc.3 excluded as prereleases; body byte-identical to the L1 capture |
| `https://github.com/getsops/sops/releases.atom` (S033) | 200 | 253037 | `47a224ad…ff6` | **3.13.3** | 3.13.3 | **AGREE** | first entry `v3.13.3`; no prerelease titles in the feed |
| `https://github.com/getsops/sops/releases/tag/v3.13.3` (S103) | 200 | 176342 | `45a0f731…0d34` | page is v3.13.3 | 3.13.3 | **AGREE** | still carries the `Latest` badge; `released this 23 Jul 05:27`; sha is per-response volatile (nonce) |
| `https://github.com/FiloSottile/age/releases/tag/v1.3.2` (S104) | 200 | 153082 | `8c83a46a…7f63` | page is v1.3.2 | 1.3.2 | **AGREE** | still carries the `Latest` badge; `released this 29 Aug 17:55`; sha is per-response volatile (nonce) |
| `https://releases.1password.com/developers/cli/index.xml` (rejected) | 200 | 45175 | `2dce505a…05e2` | **2.42.0** (2026-11-04) | S072 = 2.41.1 | **no currency claim to check** | newest listed is 2.42.0, newer than the pin; rejection holds on both grounds (no currency statement in the lane; parser refuses the two-word title) |
| `https://app-updates.agilebits.com/product_history/CLI2.rss` (rejected) | **404** | 25 | `90485e79…1247` | n/a | n/a | **REJECT holds** | body `Unknown product: CLI2.rss`; curl exit 22, `curl: (22) The requested URL returned error: 404` |

---

## 9. Findings

**F1 — CONFIRMED (supports the candidate).** Both SOPS and age pins are the projects' current stable releases on live feeds, and both feed bodies are byte-identical to the lane's captured/observed bytes. The round-53 C1 change (2 currency statements moved from a `90d` cadence to live release clocks) is materially sound: `S103 → S033` and `S104 → S111` bind the right feed to the right pin, the feed rows are `90d` (never `on-release`, as `BADFEED` requires), and the receipt's digests are reproduced by an independent fetch.

**F2 — DEFECT (factual cell, gate-neutral).** `corpus/SOURCES.md:118` (S111), anchor cell: the timestamp `2026-08-29T17:55:50Z` is the `<updated>` of the **`age v1.3.1`** entry, not of the `age v1.3.2` entry the cell describes; the v1.3.2 entry's `<updated>` is `2026-08-29T18:12:38Z`. The same misattribution is restated in `corpus/lessons/round-53.md` §Gate ("the entry's `<updated>` is 2026-08-29T17:55:50Z"). The error is present in the L1 capture itself (byte-identical body), so it is an authoring slip, not feed drift. The C1 measurement is unaffected (the gate binds on version tokens only — verified `derived_anchor_bound(anchor,'1.3.2') == True`). Everything else in the S111 row — source URL, entry title, tag link, feed-fetched date, the "newest stable is v1.3.2" teaching, the "pin has not fired" teaching, the located quote and its offset — is true of the live body.

**F3 — GAP (live, reachable).** The 1Password CLI release feed now lists **2.42.0** (2026-11-04), newer than the pinned 2.41.1 (2026-10-21). The lane's rejection of that feed is still correct — but `corpus/knowledge/op-ref-consumption.md:371,395,397` already say `recheck: on-release of op` / "unmeasured until the `on-release` clock fires", while **no op feed clock exists** in `corpus/release-clocks.tsv` and no registry row points at `releases.1password.com`. Nothing in the lane will fire on 2.42.0. This is the exact condition the lesson's own flip names (currency statement + multi-word-title parser rule), now one release live rather than hypothetical.

**F4 — OBSERVATION.** The two GitHub *release HTML pages* are not byte-stable across responses (per-response `fetch-nonce`); the two Atom *feeds* are (identical sha on repeat). The lane's capture profiles already distinguish these (`decoded-http-body-v1` for the tag pages vs `decoded-http-body-volatile-v1` for the feeds), so the S103/S104 digests are correctly classified as volatile and must not be expected to reproduce — only the feed digests (the ones the gate binds to) are reproducible, and they reproduce exactly.

**F5 — MINOR (wording).** S111's `scope` cell says "for the on-release clock of S104" while the S111 row itself is `90d`. The sentence is defensible (it is S104 that is `on-release`, and S104's clock names S111 as its feed source), but a reader could take it as describing S111's own cadence; S111 can never be `on-release` (`BADFEED`).

**Nothing observed contradicts the frozen C1 predicate or the BASE 0 → 2 movement.** The single actionable item is F2 (one timestamp in one registry cell, plus its restatement in the lesson's Gate section), and it is gate-neutral.

---

## 10. Unknowns / limits of this seat

- I did **not** attempt to make the op CLI feed admissible, did not modify the gate or its selftest, and did not draft the flip the lesson describes — that is an authoring decision for the lane, not a scout finding. I only established that the flip's *precondition* (a currency statement) is still absent and that the parser refuses the body today.
- `corpus/release-clock.py` was imported read-only to reuse `parse_latest_version`; I did not run `--observe` (which would fetch and write a receipt) and did not run the lane's `claim-ledger.sh verify` (not named by my item; host-heavy).
- The per-response volatility of the GitHub tag pages is measured on two consecutive fetches from one host at one time; [INFERENCE] that it is a nonce, not content drift — the only differing bytes are the `fetch-nonce` meta value, and the tail bytes are equal.
- I could not observe whether a newer age or sops release appears after this run; the feeds are read at 2026-11-07 and the S104/S103 clock rows will fire on the next newer stable entry title.

**Tooling:** none installed or upgraded this seat (no pacman, `uv tool install`, release binary, `cargo` or `npm -g` action was taken).
