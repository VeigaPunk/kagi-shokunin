# Feed token extraction boundaries and the extractor agreement gate

source: S052 (https://www.rfc-editor.org/rfc/rfc4287.txt, §4.2.14 The "atom:title" Element, RFC 4287 December 2005, opened 2026-10-31); S045 (https://semver.org/spec/v2.0.0.html, item 2 of the Semantic Versioning Specification, fetched 2026-10-21)
verified-at: 2026-10-31 (RFC 4287 fetched by the L1 with the declared curl profile and located once under raw-literal-v1; the extractor behavior was probed against an export of the frozen BASE `c49023b` and the repaired tree — receipts `.ufo/waves/round-29/final/`)
recheck: 180d — re-open §4.2.14 and SemVer §2; re-run `corpus/feed-token-agree.py` and the release-clock selftest after any change to `corpus/release-clock.py`
Reverify: R29-01, R29-02
(R29-01/R29-02 re-run the agreement gate's selftest and its live run; the frozen counting receipts for the boundary move itself are `.ufo/waves/round-29/final/c1-before.json` and the appended after-receipt, measured by `.ufo/waves/round-29/tools/c1-measure.py`.)

## The extraction contract (round 29 C1)

The three feed extractors (`STABLE_TITLE_RE`, `STABLE_TAG_HREF_RE`,
`TEXT_VERSION_RE`) decide WHICH text of a feed body can name a release; the
canonicality judge (`newest_stable`, the text-release check) decides WHAT the
extracted token means (S045). An Atom entry title is a Text construct (S052
§4.2.14): its trailing sentence punctuation is CONTENT, not a token boundary,
so the extractors' right boundary is the one `STABLE_TOKEN_RE` already uses —
`(?![A-Za-z0-9+-]|\.[0-9])` — and never a `$` anchor. Before round 29 the
`$`-anchored extractors silently DROPPED a period-suffixed token: a feed
newest entry `Python 3.15.01.` beside `Python 3.15.0` parsed as `3.15.0`
(the non-canonical token never reached the judge, which would have typed it
`NON-CANONICAL`), and a canonical `Python 3.15.1.` alone read as
"feed has no stable X.Y.Z release entry". After the boundary change every
such token is extracted and then judged: canonical tokens are observed,
non-canonical ones are typed `NON-CANONICAL`, and the shapes the boundary
excludes (a dotted numeric suffix such as `3.15.1.2`, prerelease
`3.15.1rc1`, build `3.15.1+build.2`) still refuse identically.

## The agreement invariant (round 29 C2)

A token shape the shared token grammar (`STABLE_TOKEN_RE`) adjudicates — it
extracts exactly one X.Y.Z core — must be extracted, unchanged, by every
feed extractor; a shape outside that grammar must be refused by every feed
extractor. `corpus/feed-token-agree.py` imports the live extractors and the
live grammar (never copies them), runs one fixed shape corpus through all
three extractors in their natural wrappers (Atom title, `/releases/tag/`
href, text `Version:` line), and fails naming shape and extractor when any
extractor's extracted-vs-refused decision or token deviates. This is the
standing form of the round-28 closure's D1 finding ("one scanner trusting a
token shape another scanner never extracts"): the defect class was that all
three extractors had drifted the same way, so extractor-vs-extractor
comparison alone would have agreed; the grammar is the arbiter.

## Bounds

1. Extraction agreement only: the gate never orders versions, decides
   canonicality, resolves references, fetches, or reads anything but the
   instrument file named by `--instrument` (default: beside the script).
2. The gate's `--selftest` runs on synthetic extractors only, so it stays
   green on a tree whose live instrument still disagrees (separability:
   demonstrated at the round-29 pre-fix commit).
3. Dropping the `$` anchor WIDENS acceptance on prose-suffixed lines
   (a text line `Version: 8.23.0 is out` now yields `8.23.0` where the old
   right anchor refused the line): declared, deliberate, and judged
   downstream by the same canonicality/ordering rules as before.
4. The 18-digit component bound and the non-canonical typing rules are
   round-28 contracts (QM27) and are unchanged here.
5. The selftest's receipt-mode case asserts `0o600` on POSIX hosts only;
   Windows/NTFS carries no POSIX mode bits (measured, committed round-29
   BASE probe), so a non-POSIX host prints an explicit SKIP line and the
   case's fields assertions still run.
6. Real feeds observed so far carry no period-suffixed stable tokens (the
   round-28 tag history sweep); the boundary move is proven on synthetic
   feeds and declares no current-vendor drift.

## Falsifiers

- A feed whose newest entry is titled `Python 3.15.1.` that still reads
  "no stable X.Y.Z release entry" falsifies the boundary contract.
- A feed with `Python 3.15.0` and `Python 3.15.01.` that ends `CLEAN`
  (exit 0) falsifies the typed-refusal contract.
- `FEED_TOKEN_AGREE: DISAGREE` on the committed tree falsifies the
  agreement invariant; a shape corpus entry the gate cannot express (for
  example a title carrying BOTH a period and a comma suffix in one token)
  is a corpus gap, not a pass.
- An RFC 4287 revision that redefines `atom:title` as something other than
  a Text construct invalidates S052's teaching and reopens the boundary.
