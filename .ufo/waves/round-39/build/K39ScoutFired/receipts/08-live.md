# 08 — live vendor re-observation (read-only) and the S036 control

## Live feeds, 2026-11-05, with the lane's own parser
  python3 -I -B (corpus/release-clock.py parse_latest_version) over the fetched bodies:
    vault releases.atom  -> 2.2.1      (feed body also carries v2.2.0, v2.2.0-rc1, v2.1.2, sdk/v0.26.0)
    openbao releases.atom-> 2.7.2      (also v2.6.5, v2.7.1, v2.6.4, api/v2.7.1)
    python.org feed.rss   -> 3.15.2     (titles: 3.11.18 3.13.18 3.12.16 3.14.10 3.15.2 3.13.17 3.14.9 3.15.1 3.16.0a1, install manager 26.4)
    sops releases.atom    -> 3.13.3
    curl.se/info          -> 8.23.0
  No vendor moved past the lane's recorded identity; 3.16.0a1 is still a prerelease and does not
  move the Python clock. The pinned round-37 receipt (observe-r37.json) records exactly
  2.2.1 / 2.7.2 / 3.15.2 / 3.13.3 / 8.23.0 — the live state is unchanged since that receipt.

## The S036 control (my own; not one of the three frozen mutants)
  cp -a candidate -> mut/M4_S036 ; sed -i '/^| S036 |/ s/Python 3\.15\.0/Python 3.15.2/g' corpus/SOURCES.md
  (this rewrites S036's anchor cell "Item titled Python 3.15.0, pubDate Fri, 09 Oct 2026 …" AND
   its teaches cell)
  Results:
    corpus/anchor-pins.sh    -> ANCHOR_PINS: CLEAN (pins=3)         rc 0   (S036 is not pinned)
    plans/round-37-c2.sh     -> 0                                     rc 0   (blind)
    corpus/release-clock.py  -> RELEASE_CLOCK: CLEAN (… fired=15 derived=15) rc 0
    corpus/sources-census.sh -> SOURCES_CENSUS: CLEAN (rows=94 …)    rc 0
    self-description-sweep   -> n=8 (SD5=3 SD6=5) — same as the unmutated candidate, no new finding
  i.e. an in-place rewrite of the superseded feed anchor S036 is invisible to every committed
  gate at the candidate, while the same class of rewrite on S034/S035/S039 is caught (S034/S035
  already by release-clock.py at BASE; S039 by the new anchor-pins gate).

## Which rows does an S036 rewrite actually break? (none that are measured)
  S036 is the feed of S027 and S028, whose anchored_version is 3.15.0 and whose notes do NOT
  start with 'derived:' — so their anchor binding is to their OWN registry anchor cells, and
  release-clock.py compares observed_version (3.15.2) != anchored_version (3.15.0), which stays
  'fired' either way. The rewritten S036 cell only misstates a historical fetch date/version.
  Consequence: the registry's own append-only rule (CORPUS.md rule 2, which this round's own
  S094 row registers) is violated in place with no gate and no counted finding, on the one
  superseded feed row that C1 did not pin.
