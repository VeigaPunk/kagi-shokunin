source: S044, S045, S046, S047, S048, S049
verified-at: 2026-10-21 — six pages fetched by the L1 at 17:27Z with the declared curl profile; quotes located under rendered-text-v1; no vault/account/handler/CDP contact
recheck: 90d — re-open the six pages; re-run `.ufo/waves/round-28/tools/c1-measure.py` and `c2-measure.py` and the release-clock selftest after any change to `corpus/release-clock.py`

# Round 28 — canonical version tokens; derived anchors bound to their feed rows

Frozen BASE: `3553d499577084a6c98d7078906017840bbf7b28` (round27 admitted,
fleet MANIFEST rounds[425]). The claims file `plans/round-28.md` and the START
census `.ufo/waves/round-28/census-start.txt` (exit 0, 11 W04) were committed
alone in `bdf90f58e43fdcae6291224197afe17812a16b55` before any work. Two plan
corrections were appended before any tool or patch commit (`b9a42c0e`: fixtures
mirror the receipt; `2dfb534b`: axis booking narrowed, sourcing clarified).

Declared: C1 freshness (canonical version tokens) and C2 calibration (derived
anchors bound to feed rows). CritC2Axis showed C2 binds a registry/release
value, which this lane has always booked as freshness; the L1 accepted it, so
the round reports ONE freshness claim measured by two frozen counting commands,
and calibration carries no claim. Axis scores stay 9.

## Gate — sources opened and decided this round

The six admitted pages were fetched by the L1 on 2026-10-21T17:27Z with
`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`
(HTTP 200 at the registered URL); digests in `corpus/source-fetches.tsv`
(all `decoded-http-body-volatile-v1`: the NIST page varied between two GETs,
the others are recorded the same way as S042/S043). BUILD scouts opened every
candidate first (`.ufo/waves/round-28/build/Src*.md`).

| Candidate | Decision and basis | URL, access date, located quote |
|---|---|---|
| S044 Python integer-string conversion limit | ADMIT tier A docs, 180d: grounds the oversize half — a component must be bounded by length before any int(). | https://docs.python.org/3/builtins/stdtypes.html ; 2026-10-21 (requested /3/library/stdtypes.html, 301); “The default limit is 4300 digits as provided in sys.int_info.default_max_str_digits .” (located once). Second quote, same capture: “The lowest limit that can be configured is 640 digits as provided in sys.int_info.str_digits_check_threshold .” |
| S045 SemVer 2.0.0 §2 normal version | ADMIT tier A spec, 180d: grounds the leading-zero half. Same URL as S042 with a different scope (one more W04 by design); S042 unchanged. | https://semver.org/spec/v2.0.0.html ; 2026-10-21; “A normal version number MUST take the form X.Y.Z where X, Y, and Z are non-negative integers, and MUST NOT contain leading zeroes.” (item 2; located once) |
| S046 Python int() | ADMIT tier A docs, 180d: default-base int() accepts leading zeros, so canonicality is decided on text, never through int(). | https://docs.python.org/3/builtins/functions.html ; 2026-10-21 (301 from /3/library/functions.html); “Base 0 also disallows leading zeros: int('010', 0) is not legal, while int('010') and int('010', 8) are.” (located once) |
| S047 GitHub Actions OIDC concepts | ADMIT tier A docs, 90d, frontier lead (OIDC trust policy), narrowed: claim-condition matching only; no audience rule (prose-absent); the page's `sub` example is the previous format. | https://docs.github.com/en/actions/concepts/security/openid-connect ; 2026-10-21; “the cloud provider checks if the OIDC token's subject and other claims are a match for the conditions that were preconfigured” (located once) |
| S048 GitHub secret scanning concepts | ADMIT tier A docs, 90d, frontier lead (detection versus verification); GitHub only, no scanner-independent semantics. | https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning ; 2026-10-21; “Validity checks help you prioritize which secrets to remediate first by verifying whether a detected secret is still active.” (located once) |
| S049 NIST SP 800-57 Pt 1 Rev. 6 IPD | ADMIT tier A spec, 90d, frontier lead (draft status): Rev. 6 is a closed-comment draft; Rev. 5 final remains the citable text. | https://csrc.nist.gov/pubs/sp/800/57/pt1/r6/ipd ; 2026-10-21; “The initial draft of NIST SP 800-57 Part 1 Revision 6 is available for comment through February 5, 2026.” (located once) |
| NIST SP 800-57 Pt 1 Rev. 5 final | NOT REGISTERED: proves "Rev. 5 is final" but carries no forward reference to Rev. 6, so it cannot establish currency (SrcFrontierNist). Flip: a key-management control that cites Rev. 5 text. | https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final ; 2026-10-21; “SP 800-57 Part 1 Rev. 5 (Final)” (Document History) |
| PyPA integer normalization (S043 URL) | REJECT for C1: it normalizes `09000` to `9000`, i.e. it would make `3.15.01` equal to `3.15.1` and hide the finding; the lane follows SemVer form (S045). Flip: a feed that declares PEP 440 versions. | https://packaging.python.org/en/latest/specifications/version-specifiers/ ; 2026-10-21; “This means that an integer version of 00 would normalize to 0 while 09000 would normalize to 9000” |
| Go x/mod/semver | NOT REGISTERED (tier B prior art): leading-zero exclusion matches, but Go orders an invalid version below a valid one instead of refusing it — the opposite of C1. | https://pkg.go.dev/golang.org/x/mod/semver ; 2026-10-21; “MAJOR, MINOR, and PATCH are decimal integers without extra leading zeros” |
| npm node-semver | NOT REGISTERED (tier B prior art): strict vs loose parsing exists, but the README's only leading-zero sentence is prerelease-scoped. | https://github.com/npm/node-semver#readme ; 2026-10-21; “Be more forgiving about not-quite-valid semver strings.” |
| GitHub releases REST docs | NOT REGISTERED: `tag_name` is documented only as free text, which supports "a feed title is not guaranteed canonical" by omission only; no Atom-feed statement. | https://docs.github.com/en/rest/releases/releases ; 2026-10-21; “The name of the tag.” |
| git-check-ref-format | NOT REGISTERED: shows `refs/tags/v3.15.01` is a legal tag (permission side), not a canonical rule; executed with git 2.56.0 by the scout. | https://git-scm.com/docs/git-check-ref-format ; 2026-10-21; “Git imposes the following rules on how references are named:” |
| CVE-2020-10735 (NVD API; cpython#95778) | NOT REGISTERED: explains why the 4300 default exists (quadratic conversion) but states no limit value; S044 is the primary limit statement. NVD's HTML detail page answered 403 to the declared profile. | https://nvd.nist.gov/vuln/detail/CVE-2020-10735 ; 2026-10-21; “a system could take 50ms to parse an int string with 100,000 digits and 5s for 1,000,000 digits” (NVD description) |
| Re-opened feeds S033, S034, S035, S036/S039, S037 | NO CHANGE: each newest stable entry still equals its feed row's anchor (v3.13.3, v2.2.0, v2.7.1, 3.15.1, 8.23.0); no new row (same URL, zero new information). | registered URLs; 2026-10-21; “<title>v3.13.3</title>”, “<title>v2.2.0</title>”, “<title>v2.7.1</title>”, “<title>Python 3.15.1</title>”, “Version: 8.23.0” |

**Existing registry cells (status/recheck/used-by), old → new:** none.
Sources 43 → 49 (six tier A, mined, used-by this lesson). Frontier: the three
README leads each gained one primary row (S047–S049); no knowledge entry or
coverage ground is claimed from them.

**Outside admit/reject spot-check:** pending parent closure; lane seats are
authors and cannot supply it.

## C1 — canonical version tokens (freshness)

`non_canonical_version` in `corpus/release-clock.py`: a strict X.Y.Z token is
canonical when every component is `0` or has no leading zero (S045) and at most
18 digits (`VERSION_COMPONENT_MAX_DIGITS`; S044's 4300 default and 640 floor
are far above it, and ordering now compares `(length, digits)` without int(),
S046). A non-canonical anchor or observation is `NON-CANONICAL` (exit 1),
never ordered, compared or fired; `--observe` refuses a feed whose newest
stable entry is non-canonical (ties included) and writes no verdict; a
non-canonical entry below the newest canonical one cannot be the newest
release and is ignored. Dead `VERSION_RE` removed. 18 selftest cases
(XC1Patch; each fails on BASE code). The 18-digit bound is lane policy, not a
SemVer rule: a nanosecond-epoch component (19 digits) would be refused; no
real tag on the five feeds exceeds 3 digits (XTagHistory: 1,256 tokens, 0
non-canonical).

## C2 — derived anchors bound to their feed rows (freshness)

`derived_anchor_bound`: a `derived:` row's strict X.Y.Z anchor must be the ONE
stable X.Y.Z that its `feed_source_id` row's anchor cell names (anchor cell
only, never `teaches`, which names curl's 8.23.1 development label; `-rc`/`+`
siblings and longer components are different tokens; a cell naming two
versions binds none). A non-numeric derived anchor must be named by the cell.
Mismatch is `DERIVATION` (exit 1) in verify, `--receipt` and `--observe`. A
non-canonical derived anchor is reported once, as `NON-CANONICAL`. All 15
derived rows bind at BASE and at every historical revision
(RevengeDerivedHistory, 24 revisions replayed). 9 selftest cases (6 XC2Patch,
3 L1: prerelease sibling, two versions in the cell, a bound control).

## Mistakes

| id | class | evidence | captured-by | fix (shown able to fail) |
|---|---|---|---|---|
| M28-1 | conformance (claims and census not frozen before work) | round27's plan first landed in `144babcb` with 1,873 other paths; no round-27 START census; C2 scope widened by an appended correction after the first measurement (`RevengeR27Timeline.md`). The plan-with-code pattern holds for rounds 22–27, 6/6 (`ScoutMistakeSweep.md`) | none | QM29 + `.ufo/waves/round-28/tools/round-conformance.py`: round 27 → `VERDICT FAIL` exit 1 (first-commit scope, census missing); round 28 → PASS exit 0; synthetic negatives fail (`XConformance.md`). Limit: its frozen-line check is vacuous on prose commands (CritConformanceFix); the hardened draft is kept as evidence. |
| M28-2 | survivor (non-canonical token read as a release or crash) | `.ufo/waves/round-28/build/XC1Measure-base-c1.json`: at BASE F1 `3.15.01` → CLEAN fired=4, F2 → ValueError traceback, F3 → written fired receipt; round27 named both as debt | QM25 orders values, not token form | QM27 + NON-CANONICAL; frozen `c1-measure.py` must read MISHANDLED 0/4 at the measured revision |
| M28-3 | discernment (a checkable value called "unverifiable by design") | round27 lesson §Residual rejected CritFinalC2 #1 as "derived anchors are author-declared and unverifiable by design", yet every derived anchor names its feed row's located release; `XC2Measure-c2-base.json`: G1–G4 accepted CLEAN 4/4 at BASE | none | QM28 + DERIVATION; frozen `c2-measure.py` must read ACCEPTED 0/4 |
| M28-4 | overclaim in the L1's own frozen plan | plan cited "SemVer S042 §2" (S042 locates §11.2 only); fixtures written table-only would have measured the receipt pin, not the behaviour; C2 booked calibration | BUILD critics (ScribeSourcesRows, SrcSemverSec2, RevC1Fixtures, CritC2Axis) | corrections appended before any work commit; S045 registered; measured by the conformance check above |

## Limits

- One claim, freshness: C1 and C2 are two mechanisms on one axis.
- C2 is error detection, not tamper evidence: editing the feed row's anchor
  cell together with the table and receipt still passes, and re-pointing a
  derived row to another feed whose anchor matches passes (CritC2Vacuity). A
  derived row's id is not yet required in its feed row's scope list — named
  next step.
- C2 binds to the feed row's dated snapshot (90d), not "newest when the row
  was opened"; rearming a derived feed group now needs a new feed row and the
  group together (RevRearmFlow).
- The 18-digit bound refuses legitimate 19+-digit components; none observed.
- Frozen F3/F4 cannot reach a local feed through the CLI (public-HTTPS policy);
  `c1-measure.py` substitutes `request_body` in-process, as the selftest does.
- Unchanged inherited limits: equal-to-floor observations, unorderable
  anchors, branch-scoped rows (round 27).
