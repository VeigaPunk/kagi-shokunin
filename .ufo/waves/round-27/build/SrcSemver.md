# SrcSemver — C2 source curation: SemVer 2.0.0 §11 precedence

BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`. Read-only lane work: no
production file was edited; no registry row was written. This report is advice
to the L1, not a closure.

## 1. Fetch record (one URL, opened this round)

| field | observed |
|---|---|
| URL | https://semver.org/spec/v2.0.0.html |
| access (UTC) | 2026-10-21T15:15:58Z; re-fetched 2026-10-21T15:19:06Z for headers |
| HTTP | 200 on both fetches, `num_redirects: 0`, `url_effective` identical |
| representation | `content-type: text/html; charset=utf-8`, `content-length: 31121`, `server: GitHub.com`, `cache-control: max-age=600` |
| server revision markers | `last-modified: Fri, 16 Oct 2026 23:30:38 GMT`, `etag: "6ad2b39e-7991"` |
| decoded body | 31121 bytes, sha256 `f9d4b8b1a5e9a0de6621dbbc70d69fdf05310b7a737509317b94a7bddfb9409e` on both fetches |
| rendered-text-v1 | normalized sha256 `5e0f0d9a085f59734cc846bf4b0d94182341154db9a216cf437d2afda4634b3a`; reproduces the 24-hex prefix in the uncommitted S042 receipt (`corpus/source-fetches.tsv:85`; S042 is absent at BASE) |
| page-displayed date | none. The only self-identity is h1/id `semantic-versioning-200` "Semantic Versioning 2.0.0" and the URL path `spec/v2.0.0.html`; the JSON-LD WebPage object carries author/headline/url but no `datePublished`/`dateModified`. |

The body digest is identical to the lane's S042 capture, so the two independent
fetches agree on the decoded representation. The page exposes **exactly one**
fragment id in its specification section: `#semantic-versioning-specification-semver`
(h2). There is no `#11`, `#11.2` or per-clause id; clause 11 is the 11th
top-level `<li>` of the specification `<ol>` (DOM-counted: 11 top-level
clauses), and 11.2 is the second nested `<li>` of clause 11. Any anchor cell
saying "§11.2" is positional, not a fragment link.

## 2. Located quotes (each collapsed and located under rendered-text-v1)

| role | quote | words | location | count |
|---|---|---|---|---|
| primary | “Major, minor, and patch versions are always compared numerically.” | 9 | §11 Precedence, item 11.2 (second nested item of the 11th clause) | 1 |
| support | “Precedence MUST be calculated by separating the version into major, minor, patch and pre-release identifiers in that order (Build metadata does not figure into precedence).” | 22 | §11, item 11.1 | 1 |
| support | “When major, minor, and patch are equal, a pre-release version has lower precedence than a normal version:” | 17 | §11, item 11.3 | 1 |
| support | “Build metadata MUST be ignored when determining version precedence.” | 8 | §10 (10th clause) | 1 |
| support | “A pre-release version indicates that the version is unstable and might not satisfy the intended compatibility requirements as denoted by its associated normal version.” | 22 | §9 (9th clause) | 1 |
| support | “A normal version number MUST take the form X.Y.Z where X, Y, and Z are non-negative integers, and MUST NOT contain leading zeroes.” | 23 | §2 (2nd clause) | 1 |
| support | “Once a versioned package has been released, the contents of that version MUST NOT be modified. Any modifications MUST be released as a new version.” | 21 | §3 (3rd clause) | 1 |
| support | “Each element MUST increase numerically. For instance: 1.9.0 -> 1.10.0 -> 1.11.0.” | 12 | §2 | 1 |

The primary quote is a complete sentence in the source. §11.2's preceding
sentence is “Precedence is determined by the first difference when comparing
each of these identifiers from left to right as follows:”; the example line is
“Example: 1.0.0 < 2.0.0 < 2.1.0 < 2.1.1.” (§11.2, also located once).

## 3. What the source supports for the rule

Rule under curation: *“an observed newest-stable release numerically below the
anchored X.Y.Z is a regression finding, not a release event.”*

Supported premise — ordering only:

- **S1. Numeric, per-component, first-difference ordering of strict cores.**
  §11.1 fixes the comparison order (major, minor, patch, then pre-release);
  §11.2 says the first difference decides and that major/minor/patch are
  compared numerically. §2's example (`1.9.0 -> 1.10.0 -> 1.11.0`) is the
  anti-lexical case. Therefore, for strict X.Y.Z strings `o` and `a`,
  `o < a` numerically implies `precedence(o) < precedence(a)`. This is what
  justifies `is_regression` (`corpus/release-clock.py:382-386` in the
  uncommitted after state) and the selftest `numeric not lexical`
  (`:1035` in the same after state).
- **S2. Core comparison precedes the prerelease suffix.** §11.1's ordering of
  identifiers means a lower core is lower precedence even when the higher core
  carries `-rcN`: `1.2.2` (and `1.2.2-rc1`) `< 1.2.3`.
- **S3. Build metadata is precedence-neutral.** §11.1 parenthetical and §10:
  two versions differing only in build metadata have *equal* precedence.
- **S4. A prerelease is below its own normal version.** §11.3 and §9:
  `1.0.0-alpha < 1.0.0`; a prerelease “indicates that the version is unstable”.

## 4. What the source does NOT support

- **N1. Chronology / publication order.** Precedence is an order over version
  *strings*, not over release *events* or timestamps. A later-published
  version can have lower precedence. “Below the anchor” ⇒ “lower precedence”,
  not “older in time”.
- **N2. Feed completeness or monotonicity.** The page never mentions feeds,
  registries, “latest”, pagination, or observation. Nothing in §11 says a feed
  lists every release, that a feed's maximum is stable, or that a feed cannot
  drop entries.
- **N3. “Not a release event.”** That classification needs three premises the
  spec does not supply: (i) the anchor names an actually published release;
  (ii) the feed is one version stream, not a union of maintenance lines;
  (iii) the observation is the maximum-precedence stable version, not merely
  the newest-dated entry. With (i)–(iii) the classification is sound; absent
  any one it can mislabel a genuine publication.
- **N4. Yank / withdrawal.** SemVer has no yank concept. §3 forbids *modifying*
  released contents, which is not withdrawal. A yank is neither a release
  event nor a regression, and the spec cannot distinguish a yank from a stale
  feed.
- **N5. That an anchored X.Y.Z exists as a release.** A version string is not
  an existence proof. §11 orders `8.23.0 < 8.23.1`; it does not say `8.23.1`
  was ever released.
- **N6. Stable-channel policy.** §11 orders prereleases too: `3.15.1 <
  3.16.0a1 < 3.16.0`. Excluding `3.16.0a1` from “newest stable” is a lane
  policy; §9's “unstable” sentence supports the *same-core* stable/prerelease
  split (§11.3), not a cross-core channel filter.
- **N7. Vendor SemVer adoption.** The page binds “software using Semantic
  Versioning” (§1). Vault, OpenBao, SOPS, curl and CPython are not asserted by
  this source to follow SemVer's API semantics; the rule borrows only the
  numeric-core convention.
- **N8. Leading-zero forms.** §2 forbids leading zeroes, so `01.2.3` is not a
  version at all and the spec does not order it.

## 5. Case analysis

**Prerelease.** §11 orders lower cores below higher ones regardless of suffix
(S2), so a lower-core prerelease observation *is* lower precedence than the
anchor. The after state declines to type it REGRESSED: `numeric_version`
returns `None` on any `-`/`+` suffix (`corpus/release-clock.py:369-380`), so a
hand-authored row `anchored=1.2.3, observed=1.2.2-rc1, verdict=fired` falls to
the string-inequality branch and is accepted as a fired release at BASE
(`corpus/release-clock.py:524-525`) and after (`:553-555`). Reachability: the
feed parser cannot emit a prerelease — `STABLE_TITLE_RE`/`STABLE_TAG_HREF_RE`
require an end-anchored bare X.Y.Z (`corpus/release-clock.py:649-651` at BASE)
and `parse_latest_version` takes the max over those (`:699`). So this is a
hand-authored-row/future-parser path, not a live-feed path. The declared limit
(“prerelease ordering keeps the inequality rule”) is therefore *narrower than
the source permits* for cross-core comparisons; that is a lane choice, not a
spec requirement. The selftest's live-feed case (feed `v1.2.2` plus
`v1.2.3-rc1`, anchor `1.2.3` → REGRESSED) is consistent with §11.3/§11.2.

**Backport.** A backport is a new publication with lower precedence. With
`observed` defined as the *maximum* stable core (`:699`), a backport entry
cannot become the observation while the anchor's core remains in the feed, so
the live feed path is protected. But that protection is the lane's max rule,
not SemVer: §11 cannot say which of two releases happened later, and the spec
describes a single incrementing stream (§2/§6-§8) while never mentioning
maintenance lines or backports [INFERENCE from the spec's silence]. A
series-scoped or cropped feed whose max is a backport
line would be typed REGRESSED while a real release occurred in that line.

**Yank.** SemVer is silent (N4). If the anchored release is withdrawn and the
feed's max drops below it, REGRESSED fires. That is a safe *stop*
(never CLEAN), but the finding means “anchor is not the max stable present”,
not “the vendor rolled back”; the four indistinguishable causes are stale/
cropped feed, yanked anchor, wrong/unreleased anchor, and series/backport feed.

## 6. Concrete counterexamples

1. **Backport vs “not a release event” — CPython.** `corpus/SOURCES.md:46`
   (S039, at BASE) records that the Python feed's *first* item is the
   older-series `3.14.9` backport, while the max stable is `3.15.1`; the same
   row records `3.16.0a1` as a prerelease. Reading “newest” by feed order or
   pubDate (a reading §11 does not forbid, because it says nothing about
   feeds) yields `3.14.9 < 3.15.1` and the rule would call a genuine
   `3.14.9` publication a REGRESSED, not a release event. The live path avoids
   this only through the max selection at `corpus/release-clock.py:699`.
2. **Unreleased anchor — curl.** `corpus/SOURCES.md:43` (S037) and
   `corpus/release-clocks.tsv:26` (S029) record that `8.23.1` is curl's
   `8.23.1-DEV` label and the released version is `8.23.0`. An anchor of
   `8.23.1` would now be REGRESSED against the released `8.23.0`: §11 supports
   `8.23.0 < 8.23.1`, but not the inference “the feed regressed”. The cause is
   an anchor naming no release (N5). The current table uses `8.23.0`, so this
   is a latent, not live, misfire.
3. **Build metadata — equal precedence is unrepresentable.** §10 makes
   `2.2.0+ci.7` equal in precedence to `2.2.0`. A row
   `anchored=2.2.0, observed=2.2.0+ci.7, verdict=not-fired` is rejected
   INCONSISTENT (string inequality, `corpus/release-clock.py:527-530` at
   BASE; `:556-560` after), while `verdict=fired` is accepted — the exact
   false release the rule exists to prevent, in a case the source explicitly
   decides. Feed parsing cannot emit `+` (`:649-651`), so this is a
   hand-authored-row path. [INFERENCE from code read; not executed.]
4. **Leading zeroes.** `NUMERIC_VERSION_RE` (`:366` after state) and
   `STABLE_TITLE_RE` (`:649` BASE) accept `01.2.3`, which §2 says is not a
   version. Ordering it as `(1,2,3)` is outside the spec.
5. **Higher-core prerelease hidden by the stable filter.** Anchor `3.15.1`
   with feed max stable `3.15.1` and an entry `3.16.0a1` reads CLEAN, although
   §11 orders `3.15.1 < 3.16.0a1`. This is the declared stable-channel policy
   (S036/S039), not a SemVer claim (N6).
6. **Un-fire that lands on the anchor.** C2's REGRESSED is anchor-relative,
   not history-relative. A rollback from `3.15.1` to `3.15.0` makes S027/S028
   (`anchored=3.15.0`, previously `fired` at `3.15.1`) read `not-fired` with
   equality — `is_regression(3.15.0, 3.15.0)` is false, and the equality
   branch accepts (`:556-557`), so no finding is emitted for those rows; only
   the `3.15.1`-anchored successors S040/S041 trip REGRESSED. The plan's
   After clause (“an observation below the anchor” is REGRESSED) is
   implemented as written; “never un-fires an already fired predecessor” is
   not fully delivered for predecessors whose anchor equals the rollback
   target. The un-fire requires the row to be re-observed from the cropped
   feed (observed rewritten to `3.15.0`, receipt regenerated) — exactly what
   a re-observation run does; a stale row still carrying the old `3.15.1`
   observation is caught by RECEIPT-MISMATCH instead. The lesson's Limits
   sentence (“does not detect a feed that
   silently drops the newest release while still showing an equal or newer
   version”) is the correct declaration. [INFERENCE from code read; the
   selftest was not run.]

## 7. Proposal

**Admit the spec row (ordering authority).** The numeric-ordering premise is
genuinely spec-grounded and is the load-bearing half of the rule; the URL
should be registered. Cells proposed (id TBD — next free after S043; do not
write the registry):

| cell | proposed value |
|---|---|
| id | TBD |
| source | Semantic Versioning 2.0.0, §11 precedence — https://semver.org/spec/v2.0.0.html |
| kind | spec |
| tier | A (normative primary specification) |
| scope | Numeric precedence of strict X.Y.Z cores only (§11.1-§11.2). Excludes chronology, feed completeness/monotonicity, yank/withdrawal, backport lines, stable-channel selection, build-metadata equality, and vendor SemVer adoption. |
| anchor + revision | §11 Precedence, items 11.1-11.2 = 11th top-level specification clause, second nested item; page has no per-clause fragment id (only `#semantic-versioning-specification-semver`) and no displayed date/revision; h1 “Semantic Versioning 2.0.0”; fetched 2026-10-21T15:15:58Z, HTTP 200, 31121 B, decoded-body sha256 `f9d4b8b1…b9409e`, normalized sha256 `5e0f0d9a…634b3a`; server `last-modified: 2026-10-16T23:30:38Z`, etag `6ad2b39e-7991` |
| teaches | For two strict X.Y.Z cores the first differing component decides by numeric value, so an observation below the anchor has lower precedence and cannot be recorded as a newer release. The page does not establish publication order, feed completeness, yank state, backport lines, stable-channel selection or build-metadata equality, and no vendor is asserted to follow SemVer's API semantics. Quote: “Major, minor, and patch versions are always compared numerically.” (§11.2, 9 words, located once). |
| status / opened / recheck | mined / 2026-10-21 / 180d |

**Rejection with flip (for the stronger claim).** The candidate “a
release-ordering spec proves a vendor's feed is complete or monotonic” is
REJECTED: §11 orders two version strings and is silent on feeds, registries
and withdrawal (N1-N4); a REGRESSED finding is a typed stop for
re-verification, not proof of a vendor rollback. Flip: a vendor-published
feed-completeness or yank/withdrawal policy, scoped to that vendor's feed, or
a feed API with explicit pagination/withdrawal semantics — none opened this
round.

**Integration note re S042 (uncommitted, `corpus/SOURCES.md:49`).** S042 uses
the same URL, the same 9-word quote and a correct ordering teaching. Its only
overclaim is the clause “so an observed newest-stable core below the anchored
core is older, not a release”: “older” in precedence order is supported;
“not a release” needs the lane's max-stable definition and fails for
multi-line/backported feeds (counterexample 1) and unreleased anchors
(counterexample 2). Cheapest integration is to amend S042's `scope`/`teaches`
to the formulation above before admission; a near-duplicate new row is not
needed. If S042 is admitted unchanged, a superseding correction row should
carry the text above and say which clause it replaces.

## 8. What I did not check (unrun checks are not passes)

- Did not run `corpus/release-clock.py`, its `--selftest`, `c2-measure.py`,
  `sources-census.sh`, any gate, linter or formatter. No claim here is a run
  result except the two HTTP fetches and the direct `rendered-text-v1` locate.
- Did not execute the counterexamples in 6.3/6.6; they are code-read
  inferences from the cited lines.
- Did not verify the plan's “live default receipt still CLEAN30”. By table
  inspection every numeric anchor in `corpus/release-clocks.tsv` is ≤ its
  observed value, so no REGRESSED would fire from the current rows, but the
  receipt was not produced.
- Did not open S043's PyPA page; I take no position on its locatedness or on
  the zero-padding limit beyond what `corpus/lessons/round-27.md` states.
- Did not open any vendor yank/registry policy (npm/PyPI/GitHub release
  withdrawal), so the yank section rests on SemVer's silence plus
  [INFERENCE], not on a yank primary source.
- Did not inspect feed pagination/truncation behavior (GitHub Atom entry
  caps), so “cropped feed” is treated as a hypothesis, not a measured
  mechanism.
- Did not capture HTTP redirect history beyond `num_redirects: 0` and
  `url_effective`; no conditional GET (`If-None-Match`) was attempted, so the
  ETag's stability is not tested.
- Did not date the page's revision beyond the server `last-modified` header;
  the body displays no date.

## 9. Confidence

High on the fetch record, quote locatedness, §11 text and the
support/non-support split. High on counterexamples 1-2 (BASE sources cited).
Medium on 3-6 as *reachability* claims: they are exact code reads at the cited
lines, but unexecuted, and 3/4/5 require a hand-authored row or a future
parser rather than a live feed. Medium on the yank analysis (source silence is
observed; the classification is inference).
