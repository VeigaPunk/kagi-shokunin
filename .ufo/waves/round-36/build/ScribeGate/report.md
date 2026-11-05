# ScribeGate — round 36 source re-verification report

Seat: ScribeGate (scribe). Lane: kagi-shokunin. Round 36, attempt 2.
Access date for every fetch and quote search: **2026-11-04**.

## What I did

Opened this round's four cited sources directly — no inherited quote counts,
no reuse of the receipt's digests as evidence of presence:

1. Read the four registry rows `S034`, `S035`, `S040`, `S041` in
   `corpus/SOURCES.md` (HEAD `09f27e2`) and recorded each row's URL and
   current recheck cell.
2. Fetched each row's URL with
   `curl -sS --max-time 60 -A 'kagi-shokunin-round36/1.0'` into scratch
   (`/fast/scratch/hyaku/kagi-r36/ScribeGate/fetch/`), public pages only, no
   auth, no credentials.
3. Searched the fetched bytes for each quote — raw-literal for the two Atom
   feed titles, and the lane's own committed normaliser
   `corpus/rendered-text-v1.py locate` for the two rendered-text quotes.
4. Cross-checked the fetched bodies against the committed live receipt
   `.ufo/waves/round-36/controls/observe-live.json`
   (sha256 `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`,
   recomputed by me and matching).
5. Re-ran the lane's own extractor `corpus/release-clock.py::parse_latest_version`
   against the fetched feed bytes to confirm the version each feed now states.

## Numbers

| id | URL | http | bytes | sha256 of fetched body |
|---|---|---|---|---|
| S034 | https://github.com/hashicorp/vault/releases.atom | 200 | 297221 | `3cbfdd86d1b4530999d9ab7ed15f395f2757ce0f8a2ae835798878bbe1957fce` |
| S035 | https://github.com/openbao/openbao/releases.atom | 200 | 543805 | `a54d1a5314ca701684fe65b3e4687c0519d45164c8cd177c950ff75bfd5f2e0e` |
| S040 | https://docs.python.org/3/library/re.html | 200 | 257722 | `064fbcb69853dc814b27732f09c640cd205e8a821e9a695d540a7945bf8f8b89` |
| S041 | https://docs.python.org/3/library/html.html | 200 | 20100 | `1a4f2e2a1f8c1db5949dd85303444654364cc06c3180b2376cf6b307f450bcd8` |
| S039 (clock feed of S040/S041, extra fetch) | https://www.python.org/downloads/feed.rss | 200 | 3354 | `9ba8856e586659ab78349c3963aa1de178636c0f08772d6196fadbaa92bcea1e` |

All five fetches: curl exit 0, HTTP 200, empty stderr.

Located release-identity quotes (≤ 25 words each), access date 2026-11-04:

| id | quote | anchor | release date stated by feed | present at anchor? |
|---|---|---|---|---|
| S034 | `<title>v2.2.1</title>` | first stable entry, byte 726, body line 12 | `<updated>2026-10-23T17:34:44Z</updated>` (no `<published>` in feed) | **yes** (count 1) |
| S035 | `<title>v2.7.2</title>` | first stable entry, byte 729, body line 12 | `<updated>2026-10-26T20:24:37Z</updated>` (no `<published>` in feed) | **yes** (count 1) |
| S040 | `Python 3.15.2 documentation` | page `<title>`, body line 20 | docs page states none; clock feed S039 states `pubDate Sun, 25 Oct 2026 04:15:38 +0000` for `<title>Python 3.15.2</title>` | **yes** (count 1) |
| S041 | `Python 3.15.2 documentation` | page `<title>`, body line 20 | same feed item as S040 | **yes** (count 1) |

## Findings (routed, not edited — I edited nothing in the lane)

**F1 — S034/S035 anchor cells are stale past the recheck cell.**
`S034`'s anchor cell still reads "Entry titled v2.2.0 … feed fetched 2026-10-21"
and `S035`'s "Entry titled v2.7.1 … feed fetched 2026-10-21". Both recorded
title strings are still literally in the fetched bodies (count 1 each), but
their *locator* "first stable entry" no longer holds: `v2.2.0` is now the
second Vault entry and `v2.7.1` the third OpenBao entry (entry 1 is `v2.6.5`,
updated `2026-10-26T20:23:12Z`, so entry order is not newest-version order).
The anchor cells' `updated` timestamps for the old entries are still exactly
what the feed states (`2026-10-15T18:50:14Z`, `2026-10-01T18:32:18Z`).
Recheck cells are `90d` for both rows, so a 90-day recheck does not fire on
this move; the drift was found only by re-opening the sources. Under QM23 an
`on-release` recheck names one observable release identity and is observed —
these rows govern the on-release clocks of S012/S013/S022-S024 and
S014-S016/S021/S025/S026, so the `90d` cell and the "first stable entry"
locator are worth the L1's attention in the Frontier step (the plan already
names `S034`, `S035`, `S040`, `S041` as rows touched, `recheck`/`used-by`/
observation cells only).

**F2 — S040/S041 anchor titles are absent; the pages now carry 3.15.2.**
Both rows' anchor cells name "title Python 3.15.1 documentation". Under the
lane's own normaliser, `Python 3.15.1 documentation` returns **count 0** on
both fetched pages; the pages now serve
`re — Regular expression operations — Python 3.15.2 documentation` and
`html — HyperText Markup Language support — Python 3.15.2 documentation`.
Stated as `absent` with what the page now serves; no paraphrase substituted
for a quote. Both pages state only `Last updated on Nov 04, 2026 (23:57 UTC)`
— a page-update stamp, **not** a release date; the release date comes from the
clock feed S039 (`Sun, 25 Oct 2026 04:15:38 +0000`).

**F3 — the two teaching quotes are unchanged and still located.**
`Matches Unicode whitespace characters (as defined by str.isspace() ).`
(S040) and `This function uses the rules defined by the HTML 5 standard for
both valid and invalid character references` (S041) both return
`rendered-text-v1 locate count=1` (exit 0). Caveat for anyone checking by
hand: in the **raw** S041 HTML the sentence wraps across a newline
("…HTML 5 standard\nfor both valid…"), so a raw single-line substring search
returns 0 — it is located only under the declared normaliser. The S040 quote
likewise spans markup (`str.isspace` is a link) and is a rendered-text quote.
Both facts are recorded in `evidence/locate-evidence.txt`.

**F4 — my independent fetch reproduces the committed receipt's bytes exactly.**
For all three feeds the sha256 of my body equals the sha256 the receipt
records for that URL: Vault `3cbfdd86d1b45309…` (receipt rows S012/S013/
S022/S023/S024), OpenBao `a54d1a5314ca7016…` (S014/S015/S016/S021/S025/
S026), python.org RSS `9ba8856e586659ab…` (S027/S028/S040/S041). The receipt
row for `S040`/`S041` names the **feed** https://www.python.org/downloads/feed.rss
with `parsed_version 3.15.2`, `verdict fired`, `observed_at 2026-11-04T23:42:58Z`
— reproduced byte-identically by my fetch of the same URL. The receipt's own
file sha256 recomputes to the declared `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`.

**F5 — the lane's extractor agrees with the quotes on these bytes.**
`corpus/release-clock.py::parse_latest_version` run on the bodies I fetched
returns `2.2.1` (Vault), `2.7.2` (OpenBao), `3.15.2` (python.org RSS) — the
same versions the receipt records, from bytes I fetched independently of the
receipt.

**F6 — the feed scope guards are still live, not historical.**
Vault feed still carries `sdk/v0.26.0` and `v2.2.0-rc1`; OpenBao feed still
carries `api/v2.7.1: Add changelog entry for v2.7.1 CVE fixes`,
`sdk/v2.7.1: Bump kms/transit (#4064) (#4072)` and `v2.7.0-beta20260909`.
Both rows' "excludes module tags / prereleases" scopes still exclude live
content, and the python.org feed still carries the `Python 3.16.0a1`
prerelease and the `Python install manager 26.4` non-release item. All entry
lists are in `evidence/feed-entries.txt`.

## Conflicts observed (verbatim, for the canonical Rust judge)

No conflict between seats was observed. One conflict between *sources* was
observed and is recorded verbatim above: the `S034`/`S035` anchor cells name a
first stable entry that the served feed no longer serves in first position
(F1), and the `S040`/`S041` anchor titles are absent from the served pages
(F2). These are source-vs-registry staleness, not seat-vs-seat disagreements.

## Out of scope (not done, by instruction)

- No lane production file was created, edited, moved or deleted: not
  `SCORECARD.md`, `LOG.md`, `SKILL.md`, `PROVINCE.md`, `corpus/*`, `plans/*`.
- No registry edit: the `recheck`/`used-by`/`opened` cells for the four rows
  were left as another seat's in-flight work had them (the working tree
  already shows `opened 2026-11-04` for S034/S035/S040/S041 from an edit
  that is not mine; at HEAD `09f27e2` they read `2026-10-21`).
- No git mutation in the lane: only `git -C <abs> status/log/show/diff`,
  all read-only. No commit, push, checkout, switch, reset, stash or clean.
- No writes to the fleet root, `.ufo/state`, `.ufo/watchdog.log`,
  `MANIFEST.json`, or the fleet root's `templates/` and `scripts/`.
- No subagent dispatch, no swarm, no `agent://all`.

## Tooling

No tool was installed or upgraded: the assignment needed only `curl`,
`sha256sum`, `python3` and the lane's own committed scripts, all already
present. Nothing to record against the operator tooling directive.

## Limits / dead ends

- The two Atom feeds carry `<updated>` but **no `<published>` element**
  (grep count 0 in both bodies), so the "release date" I report for S034/S035
  is the entry's `<updated>` timestamp — the only date the feed states. I did
  not open the GitHub release *pages* to look for a separate published date;
  the assignment names the feed URLs.
- `S040`/`S041`'s own pages state no release date, only `Last updated on Nov
  04, 2026 (23:57 UTC)`. The release date I report for Python 3.15.2 comes
  from the clock feed the clock rows name (`S039`), fetched separately; its
  sha256 matches the receipt's byte-for-byte.
- The `S040`/`S041` normalised digests I record (`79e22ea7…`, `b5ae6977…`)
  are **not** comparable to the historical `corpus/source-fetches.tsv` values
  for those rows (`bbeb9d7c…`, `ef8996ed…`) — the pages now serve 3.15.2, so
  the normalised bytes necessarily differ. I did not rewrite `source-fetches.tsv`;
  whether the round's plan wants that capture row re-written is the L1's call.
- The scratch tree `/fast/scratch/hyaku/kagi-r36/ScribeGate/` was removed
  after the receipts were copied into the build directory (see the evidence
  files listed below).

## Artifacts (all under `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-36/build/ScribeGate/`)

| path | what |
|---|---|
| `gate.md` | one Gate section per S-id: URL, access date, located quote, release date, body sha256, presence verdict |
| `fetch-sha256.tsv` | id, url, http_status, bytes, sha256 |
| `report.md` | this file |
| `evidence/locate-evidence.txt` | `rendered-text-v1` locate/digest output for S040/S041, including the count-0 results |
| `evidence/quote-excerpts.txt` | raw byte/line excerpts of each located quote |
| `evidence/feed-entries.txt` | every entry title, `<updated>` and tag link of both Atom feeds as served |
| `evidence/python-feed.rss` | the python.org RSS body as fetched (sha256 `9ba8856e586659ab78349c3963aa1de178636c0f08772d6196fadbaa92bcea1e`) |

The Report: trailer for this seat is `.ufo/waves/round-36/build/ScribeGate.md`.
