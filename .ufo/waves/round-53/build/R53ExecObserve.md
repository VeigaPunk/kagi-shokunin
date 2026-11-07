# R53ExecObserve — independent live observation of all 31 release clocks (round 53, candidate 36d0a86)

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, candidate `36d0a86a7539890eb079d893c9a58e37e84d953d`, BASE `c1953d4afc19a5a336a58685c00ab5260bcfea1c`.
Scratch: `/fast/scratch/hyaku/kagi-r53/R53ExecObserve` (git-archive extraction of the candidate; removed on exit by trap).
Receipts copied: `.ufo/waves/round-53/build/R53ExecObserve/obs.json` (my live run), `receipt-observe-r53.json` (landed receipt).

## Commands run (exact, with exit)

| # | Command (cwd = scratch tree unless noted) | Exit | Last output line |
|---|---|---|---|
| 1 | `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 36d0a86… \| tar -x -C $S/tree` | 0 | `archive exit=0` |
| 2 | `python3 corpus/release-clock.py` | 0 | `RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17)` |
| 3 | `python3 corpus/release-clock.py --observe $S/obs/obs.json` | 0 | `RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17)` (stdout also: `RELEASE_CLOCK_OBSERVE: wrote 31 observations (failed=0 fired=13 regressed=0) to …/obs.json`) |

Note on the spec's "expect CLEAN on_release=31": confirmed, `on_release=31`. The spec's "RECEIPT-MISMATCH on observed_at is expected if the date changed": **did not occur** — both runs stayed CLEAN on 2026-11-07, same UTC date as the landed receipt (receipt `observed_at` 2026-11-07T03:02:31Z–03:02:3xZ; mine 2026-11-07T03:51:38Z–03:51:4xZ). No mismatch of any kind, including `observed_at` date.

## 31-row table: my live observation vs landed receipt `.ufo/waves/round-53/final/observe-r53.json`

Compared record-by-record on `url, http_status, parsed_version, verdict, located` (and `sha256` separately). Order identical. **All 31 agree on all five fields; sha256 drift: none** (zero ids differ).

| id | receipt verdict / version | my verdict / version | agree | notes |
|---|---|---|---|---|
| S005 | quote-located / null | quote-located / null | YES | http 200, located true, same URL |
| S006 | quote-located / null | quote-located / null | YES | http 200, located true, same URL |
| S007 | quote-located / null | quote-located / null | YES | http 200, located true, same URL |
| S008 | not-fired / 3.13.3 | not-fired / 3.13.3 | YES | SOPS releases.atom, http 200 |
| S009 | not-fired / 3.13.3 | not-fired / 3.13.3 | YES | same feed URL |
| S010 | not-fired / 3.13.3 | not-fired / 3.13.3 | YES | same feed URL |
| S011 | not-fired / 3.13.3 | not-fired / 3.13.3 | YES | same feed URL |
| S012 | fired / 2.2.1 | fired / 2.2.1 | YES | Vault releases.atom |
| S013 | fired / 2.2.1 | fired / 2.2.1 | YES | Vault releases.atom |
| S014 | fired / 2.7.2 | fired / 2.7.2 | YES | OpenBao releases.atom |
| S015 | fired / 2.7.2 | fired / 2.7.2 | YES | OpenBao releases.atom |
| S016 | fired / 2.7.2 | fired / 2.7.2 | YES | OpenBao releases.atom |
| S017 | quote-located / null | quote-located / null | YES | http 200, located true |
| S018 | quote-located / null | quote-located / null | YES | http 200, located true |
| S019 | quote-located / null | quote-located / null | YES | http 200, located true |
| S020 | quote-located / null | quote-located / null | YES | http 200, located true |
| S021 | fired / 2.7.2 | fired / 2.7.2 | YES | OpenBao releases.atom |
| S022 | fired / 2.2.1 | fired / 2.2.1 | YES | Vault releases.atom |
| S023 | fired / 2.2.1 | fired / 2.2.1 | YES | Vault releases.atom |
| S024 | fired / 2.2.1 | fired / 2.2.1 | YES | Vault releases.atom |
| S025 | fired / 2.7.2 | fired / 2.7.2 | YES | OpenBao releases.atom |
| S026 | fired / 2.7.2 | fired / 2.7.2 | YES | OpenBao releases.atom |
| S027 | fired / 3.15.2 | fired / 3.15.2 | YES | python.org/downloads/feed.rss |
| S028 | fired / 3.15.2 | fired / 3.15.2 | YES | python.org/downloads/feed.rss |
| S029 | not-fired / 8.23.0 | not-fired / 8.23.0 | YES | curl.se/info |
| S030 | quote-located / null | quote-located / null | YES | http 200, located true |
| S031 | quote-located / null | quote-located / null | YES | http 200, located true |
| S032 | quote-located / null | quote-located / null | YES | http 200, located true |
| S098 | quote-located / null | quote-located / null | YES | http 200, located true |
| S103 | not-fired / 3.13.3 | not-fired / 3.13.3 | YES | SOPS releases.atom (new row, S033) |
| S104 | not-fired / 1.3.2 | not-fired / 1.3.2 | YES | age releases.atom (new row, S111) |

New-clock spot-check (C1 targets): my live fetch of `https://github.com/getsops/sops/releases.atom` → 3.13.3, `not-fired` vs anchor 3.13.3; of `https://github.com/FiloSottile/age/releases.atom` → 1.3.2, `not-fired` vs anchor 1.3.2. Both match the landed receipt exactly, including sha256 (so the two feeds are byte-stable between 03:02Z and 03:51Z on 2026-11-07).

## Old-row TSV diff summary (`corpus/release-clocks.tsv`, BASE → candidate)

Method: extracted BASE TSV via `git archive c1953d4…` and parsed both TSVs with Python `csv` (tab delimiter), keyed by `id`.

- BASE rows: 29 (id, clock, feed_source_id, feed_url, anchored_version, observed_version, observed_at, verdict, note). Candidate rows: 31.
- New rows: **S103** (feed/S033, SOPS releases.atom, anchor 3.13.3, observed 3.13.3, 2026-11-07, not-fired) and **S104** (feed/S111, age releases.atom, anchor 1.3.2, observed 1.3.2, 2026-11-07, not-fired). No rows removed.
- For each of the 29 old rows, the changed columns are **exactly** `observed_at` (2026-11-06 → 2026-11-07) and `note` (pure append). Verified programmatically: candidate note starts with the full BASE note for every old id, and no other column differs (no verdict/observed_version/anchored_version/feed change anywhere).
- The appended suffix on all 29 old rows is a single round-53 re-observation note, in two forms:
  - quote rows (S005–S007, S017–S020, S030–S032, S098): `; re-observed by the round-53 receipt observe-r53.json (2026-11-07, quote located)`
  - feed rows (S008–S016, S021–S029): `; re-observed by the round-53 receipt observe-r53.json (2026-11-07, observed <version>)` where `<version>` equals the row's unchanged `observed_version`.
- Per-row list (id → appended suffix, truncated): S005/S006/S007 quote; S008–S011 observed 3.13.3; S012/S013 observed 2.2.1; S014/S015/S016 observed 2.7.2; S017–S020 quote; S021 observed 2.7.2; S022/S023/S024 observed 2.2.1; S025/S026 observed 2.7.2; S027/S028 observed 3.15.2; S029 observed 8.23.0; S030/S031/S032 quote; S098 quote.

## Verdict

Independent re-observation at 2026-11-07T03:51Z confirms the landed receipt on all 31 clocks with zero disagreement and zero sha256 drift. The candidate TSV change is exactly: 29 old rows bumped `observed_at` + appended re-observation note (no verdict/version change), plus the 2 new rows S103/S104. No discrepancy found.

## Risks / blockers

- None. No fetch failures (failed=0), no RECEIPT-MISMATCH. Tooling: no installs (stock python3 + git + tar used); no pacman run.
