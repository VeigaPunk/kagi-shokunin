# K37ReviewFresh — independent re-verification of candidate rows S089/S090/S091 (kagi round 37, wave build)

Seat: reviewer (non-author freshness re-verification). Date of execution: 2026-11-05.
Method: I fetched all three feeds myself with curl into my scratch dir; I did not trust the lane's capture bodies for the verdict, and I ran a read-only `cmp` against them only as a capture-vs-live consistency check.

## What I executed (exact commands, exit codes, output)

Cwd for all fetches: `/fast/scratch/hyaku/kagi-r37/K37ReviewFresh` (created with `mkdir -p`, removed at end by `trap 'rm -rf -- "$S"' EXIT`; nothing written outside it and the seat report dir).

```
curl -fsSL --compressed --max-time 90 -o "$S/vault.atom" https://github.com/hashicorp/vault/releases.atom
curl -fsSL --compressed --max-time 90 -o "$S/openbao.atom" https://github.com/openbao/openbao/releases.atom
curl -fsSL --compressed --max-time 90 -o "$S/python.rss" https://www.python.org/downloads/feed.rss
```

All three exit=0, http_code=200 (verified twice — once in the parallel batch, once sequential with `-w '%{http_code}'`; both refetches returned byte-identical bodies, same sha256).

My fetched bytes:

| feed | sha256 | bytes |
|---|---|---|
| vault.atom | 3cbfdd86d1b4530999d9ab7ed15f395f2757ce0f8a2ae835798878bbe1957fce | 297221 |
| openbao.atom | a54d1a5314ca701684fe65b3e4687c0519d45164c8cd177c950ff75bfd5f2e0e | 543805 |
| python.rss | 9ba8856e586659ab78349c3963aa1de178636c0f08772d6196fadbaa92bcea1e | 3354 |

## 1. Capture-body consistency check (read-only `cmp`)

`cmp -s "$S/<name>" .ufo/waves/round-37/capture/<name>.body`:

```
S089 body IDENTICAL
S090 body IDENTICAL
S091 body IDENTICAL
```

Lane capture shas equal my live shas for all three; the tsv rows in `corpus/source-fetches.tsv` carry the same sha256 (S089 `3cbfdd86…`, S090 `a54d1a53…`, S091 `9ba8856e…`) and byte counts 297221/543805/3354. The tsv column-3 fetch-id shas are internal per-fetch ids, not body shas, and match across the S089/S090/S091 rows' own body-sha column; no discrepancy.

## 2. Per-row verification

Registry rows read at lane HEAD `9efcea7` (verified: `git rev-parse HEAD` → `9efcea722bdc…`). Receipt `observe-r37.json` sha256 verified = `cb96cfb2…` (pinned value), format `release-clock-observations-v1`, 30 records; receipt parsed versions: vault `2.2.1`, openbao `2.7.2`, python.org `3.15.2`.

### S089 — vault releases.atom

| check | result | evidence |
|---|---|---|
| quote `grep -c -F '<title>v2.2.1</title>' vault.atom` | 1 (located; python byte offset 726) | `grep -c` → `1`; offset check → `offset 726` |
| anchor = newest stable in feed | AGREE | first-stable title order: `v2.2.1` (entries[0], updated 2026-10-23T17:34:44Z) > `v2.2.0` > `v2.2.0-rc1` (prerelease) > `v2.1.2` … ; `sdk/v0.26.0` module entry excluded per row scope |
| receipt match | AGREE | receipt: `2.2.1` |
| superseded claim (teaches) | TRUE | `v2.2.0` IS an entry in my live bytes (`grep -c -F '<title>v2.2.0</title>'` → 1), it IS what S034 anchors (S034 anchor cell: "Entry titled v2.2.0 … updated 2026-10-15T18:50:14Z"), and the v2.2.0 entry's updated date (2026-10-15T18:50:14Z) matches S034's recorded one exactly |
| verdict | **AGREE** | quote located, anchor is the live newest stable, supersession claim verified exemplarily |

### S090 — openbao releases.atom

| check | result | evidence |
|---|---|---|
| quote `grep -c -F '<title>v2.7.2</title>' openbao.atom` | 1 (located; byte offset 729) | as above |
| anchor = newest stable in feed | AGREE | first-stable title order: `v2.7.2` (updated 2026-10-26T20:24:37Z) > `v2.6.5` > `v2.7.1` > … ; `api/v2.7.1` and `sdk/v2.7.1` commit-message module titles and `v2.7.0-beta20260909` prerelease excluded per row scope |
| receipt match | AGREE | receipt: `2.7.2` |
| superseded claim (teaches) | TRUE | `v2.7.1` present in live bytes (count 1), matches S035's anchor cell ("Entry titled v2.7.1, tag link /releases/tag/v2.7.1, updated 2026-10-01T18:32:18Z") — the feed's v2.7.1 entry updated date is exactly `2026-10-01T18:32:18Z` |
| verdict | **AGREE** | all predicates hold against my own fetch |

### S091 — python.org downloads feed.rss

| check | result | evidence |
|---|---|---|
| quote `grep -c -F '<title>Python 3.15.2</title>' python.rss` | 1 (located; byte offset 1583) | as above |
| anchor = newest stable in feed | AGREE | parsed all 10 items with pubDates: `3.15.2` pubDate `Sun, 25 Oct 2026 04:15:38 +0000`; the only newer-pubDate items (3.13.18, 3.12.16, 3.14.10, 3.11.18 — 2026-10-25 evening) are older-series backports; highest major.minor with stable X.Y.Z is 3.15.2 > 3.15.1. `Python 3.16.0a1` is a prerelease (title read directly: alpha suffix), `Python install manager 26.4` is an install-manager item — both correctly excluded |
| receipt match | AGREE | receipt: `3.15.2` |
| feed not ordered by release (plan's caveat) | CONFIRMED | item 1 is `3.11.18`; 10 items total, matching the lesson's count |
| backport-series claim | TRUE | `Python 3.14.10` item exists (pubDate 2026-10-25T04:15:45Z), older-series backport relative to 3.15.2 dev series; consistent with row text |
| prerelease claim | TRUE | `<title>Python 3.16.0a1</title>` present (pubDate 2026-10-13); caught by exclusion rule |
| supersedes S039 claim | TRUE | S039 anchor cell: "Python 3.15.1 item, pubDate Wed, 21 Oct 2026 09:59:50 +0000" — `Python 3.15.1` present in live bytes (count 1) and its pubDate in the feed is exactly `Wed, 21 Oct 2026 09:59:50 +0000`, matching S039's recorded item |
| verdict | **AGREE** | all predicates hold against my own fetch |

## 3. Robustness checks (prevention of test-oracle ошибки)

- I did NOT read `corpus/SOURCES.md` before fetching; my fetches were blind.
- Quote counts in raw fetched bytes (not the capture copies): S089 vault = 1, S090 openbao = 1, S091 python = 1 — located at byte offsets 726/729/1583 annotated in both the rows and `corpus/lessons/round-37.md` §Gate.
- 2026-11-05 is the round's access date; my own access date is also 2026-11-05, so no drift window.

## 4. Registry hygiene (read-only)

- `git show 911ab519b6b07694c3cb9f7d9a7c56e142ad957c:corpus/SOURCES.md` has 88 rows; current has 91; `git diff 911ab519b6b07694c3cb9f7d9a7c56e142ad957c 9efcea7 --stat -- corpus/SOURCES.md` = `3 +(` — only insertions. Diffing the extracted S034/S035/S039 lines: `IDENTICAL` — mutable cells of superseded rows untouched, per CORPUS rule 2.
- `used-by` of the new rows points at `corpus/lessons/round-37.md`, which I read; it gates all three rows and names their quote + offsets consistently.

## FRESH VERDICT: AGREE

All three candidate rows verified against live bytes I fetched myself; every row's quote, anchor-newest-stable, rc/sdk/alpha exclusions, and superseded-row identity check pass; capture bodies byte-identical to my own fetches.

No residual doubts worth a DISAGREE. Note for integration: `teaches` cells correctly open with `supersedes S0NN`; superseded rows' status/recheck/used-by unchanged; ids S089/S090/S091 do not collide with the quarantined absent-defect-register names (recorded as hazard in the lesson).
