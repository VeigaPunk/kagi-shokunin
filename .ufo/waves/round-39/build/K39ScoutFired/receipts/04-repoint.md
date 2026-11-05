# 04 — the 15 fired clocks and the R37-V2 derivation dependence (independent re-derivation)

## The 15 fired rows, from corpus/release-clocks.tsv (candidate == BASE, file unchanged)
id    feed   anchored  observed  verdict   note starts 'derived:'?
S012  S034   v1.21.x   2.2.1     fired     no
S013  S034   2.2.0     2.2.1     fired     YES
S014  S035   2.7.1     2.7.2     fired     YES
S015  S035   2.7.1     2.7.2     fired     YES
S016  S035   2.7.1     2.7.2     fired     YES
S021  S035   2.7.1     2.7.2     fired     YES
S022  S034   2.2.0     2.2.1     fired     YES
S023  S034   2.2.0     2.2.1     fired     YES
S024  S034   2.2.0     2.2.1     fired     YES
S025  S035   2.7.1     2.7.2     fired     YES
S026  S035   2.7.1     2.7.2     fired     YES
S027  S036   3.15.0    3.15.2    fired     no
S028  S036   3.15.0    3.15.2    fired     no
S040  S039   3.15.1    3.15.2    fired     no
S041  S039   3.15.1    3.15.2    fired     no
Counts: 15 fired; 10 of them derived, 5 not. Exactly 15 rows in the whole table carry a
'derived:' note (the fired 10 plus S008,S009,S010,S011,S029), so the gate's baseline
'derived=15' is a different population from 'fired=15' — the two counts coincide numerically
but not as sets.

## Why each fired row fires (mechanism, from corpus/release-clock.py evaluate())
For a feed row, verdict 'fired' requires observed_version != anchored_version, the row to be
INCONSISTENT-free, and no REGRESSED/DERIVATION/NON-CANONICAL finding. All 15 fired rows have
observed > anchored:
  Vault    v2.2.0 -> v2.2.1   (S013,S022,S023,S024) ; S012 v1.21.x -> 2.2.1 (series anchor)
  OpenBao  v2.7.1 -> v2.7.2   (S014,S015,S016,S021,S025,S026)
  Python   3.15.0 -> 3.15.2   (S027,S028) ; 3.15.1 -> 3.15.2 (S040,S041)
The two Python generations are the same feed (S036 then S039, S039 supersedes S036), so the
Python feed fires 4 rows; S034 fires 5 and S035 fires 6.

## The derivation dependence (why a re-point is a DERIVATION failure)
Only the 10 'derived:' rows are bound to their feed row's anchor cell:
  derived_anchor_bound(feed_anchor, anchored) is True iff the feed row's anchor cell names
  exactly that one stable X.Y.Z (release-clock.py:349, used at :619).
So for a derived row the anchored_version is DEFINED by the feed row's anchor cell; re-point
the feed id and the binding breaks. The 5 non-derived rows are anchored in their OWN registry
anchor cell and are inert to a feed-id swap (release-clock.py:616).

## Independent re-point experiment (candidate tree, all 15 feed ids re-pointed, anchors kept)
S034->S089, S035->S090, S036->S091, S039->S091 in corpus/release-clocks.tsv:
  DERIVATION S013
  DERIVATION S014
  DERIVATION S015
  DERIVATION S016
  DERIVATION S021
  DERIVATION S022
  DERIVATION S023
  DERIVATION S024
  DERIVATION S025
  DERIVATION S026
  RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=20 fired=5 derived=5)   rc 1
=> reproduces the round-38 lesson's table row exactly, including the finding count (10) and
   the ids (S013..S026). The 10 findings are exactly the 10 derived fired rows; the 5
   non-derived fired rows (S012,S027,S028,S040,S041) produce no finding.

## Live domain recheck (read-only fetch, 2026-11-05) — the concrete next domain recheck
Using the lane's own extractor (corpus/release-clock.py parse_latest_version over the live
feed bodies, User-Agent 'kagi-shokunin-round25/1.0'):
  https://github.com/hashicorp/vault/releases.atom    newest_stable = 2.2.1
  https://github.com/openbao/openbao/releases.atom    newest_stable = 2.7.2
  https://www.python.org/downloads/feed.rss           newest_stable = 3.15.2
  https://github.com/getsops/sops/releases.atom      newest_stable = 3.13.3
  https://curl.se/info                                newest_stable = 8.23.0
=> No vendor has moved past the version the lane already recorded: the 15 fired clocks are
   still fired, none has become stale-but-unreported, and no new clock has opened. The live
   state equals the round-37/38 receipts (S089=v2.2.1, S090=v2.7.2, S091=3.15.2, S033=3.13.3,
   S037/S029=8.23.0). The R37-V2 re-point therefore has no NEW information to gain from the
   feeds; its cost is entirely the coupled edit to 10 derived anchored_version cells plus the
   5 non-derived rows' own anchor cells (and their receipt re-observation, whose date binding
   is separately broken: the round-38 receipt is not a usable pin, 30 RECEIPT-MISMATCH).
   This is the concrete next domain recheck: re-observe the three feeds and the two
   documentation surfaces, and if the versions are unchanged, record that R37-V2 is not a
   freshness move rather than re-pointing.

## Live documentation surfaces (the other half of the "trial on real domain work")
  docs.python.org/3/library/re.html    title: 're — Regular expression operations — Python 3.15.2 documentation'
  docs.python.org/3/library/html.html  title: 'html — HyperText Markup Language support — Python 3.15.2 documentation'
  Both pages still serve 3.15.2 (the version S040/S041's recheck cadence is on-release), and both
  registered quotes still locate on the live pages with the lane's own locator:
    python3 -I -B corpus/rendered-text-v1.py locate <live re.html> 'Matches Unicode whitespace characters (as defined by str.isspace() ).'   -> count=1 rc 0
    python3 -I -B corpus/rendered-text-v1.py locate <live html.html> 'This function uses the rules defined by the HTML 5 standard for both valid and invalid character references' -> count=1 rc 0
  BUT the live docs are now 3.15.2 while registry rows S040/S041 name 'Python 3.15.1 documentation'
  in their scope cell (fetched 2026-10-21) and S027/S028 name 'Python 3.15.0 documentation'. The
  on-release recheck these rows carry (recheck=on-release) is therefore already due: the served
  Python documentation has moved one version past what the registry names. The committed
  round-26 capture bodies differ from the live bodies (sha256 DIFFER for S040.body and
  S041.body), so the drift is in the served surface, not in the recorded quotes.

  developer.hashicorp.com/vault/docs/auth/jwt  (the S012/S022 surface)
    HTTP 200; the page's version switcher now offers: latest, 1.9.3, v2.x, v1.21.x, v1.20.x, …
    'Currently viewing v2.x (latest).'  and the versions array is
      [{name: latest, label: 'v2.x (latest)', isLatest: true}, {name: v1.21.x}, {name: v1.20.x}, …]
    -> the S012 anchor cell says "version switcher's newest pinned entry v1.21.x" and the
       scope cell says "unversioned 'latest' page as served 2026-10-19". As of 2026-11-05 the
       unversioned /latest URL serves the v2.x documentation, and the switcher's newest
       non-'latest' pinned entry is v1.21.x. The registered S012 quote
       'must exactly match at least one of the `aud` claims declared for the JWT.' does NOT
       locate on the live page as a rendered-text string (locate -> count=0 rc=1), because the
       live MDX source renders the inline code as `` `aud` `` inside a JSX payload rather than
       as literal backticks; the same sentence locates as plain text (count=2) on all three of
       the live latest, v1.21.x and v2.x pages. The registered quote's byte form is a
       historical-representation artifact, the same class the census already labels
       'non-reproducing' for S012 in corpus/inrow-pins.tsv.

## Round-37 counter on the re-pointed table (unchanged semantics)
  $ (in the re-pointed tree) bash plans/round-37-c2.sh -> 0 rc 0
