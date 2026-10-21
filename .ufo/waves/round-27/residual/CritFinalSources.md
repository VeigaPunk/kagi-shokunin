# CritFinalSources — residual re-open of S042 and S043 (round 27)

Seat: KagiR26.CritFinalSources-27-t3 (lane-authored advice, not non-author closure).
Candidate: `144babcb892f0a30154880a9f94aa59ca8ddf9c5` (frozen BASE `0a47dd18…`).
Production files untouched; scratch only under `/fast/scratch/CritFinalSources/`.
Tools installed/updated: none.

## Verdict

| row | quote | locator / date | tier + scope | overclaim | verdict |
|---|---|---|---|---|---|
| S042 SemVer 2.0.0 | AGREE: exact, located once | AGREE: §11 item 2 (11.2) | AGREE: tier A for SemVer precedence | PARTIAL DISAGREE: the teaches cell says more than SemVer does (points A, B and C below) | agree with the admission; fix the teaches wording |
| S043 PyPA version specifiers | AGREE: exact, located once | AGREE: Version scheme → Final releases; "Last updated on Oct 12, 2026" located | AGREE: Python software distributions; the CPython and feed/yank disclaimers are accurate | AGREE for the row. The lesson's gate-table wording widens it (point D) | agree |

Neither row claims that a feed is complete. S043 says so explicitly. S042 says nothing about feeds, and the lesson's REJECT row ("ordering … does not say a feed lists every release") is accurate. Neither row claims vendor SemVer **API** adoption. The open question is S042's narrower assumption: it treats SemVer ordering as applying to non-SemVer vendors (point B).

## Evidence (exact commands, exits, last lines)

1. Rows at candidate:
   `git show 144babcb…:corpus/SOURCES.md | grep -E '^\| S04[23] '`, exit 0. Rows quoted in full and checked; `source-fetches.tsv` pins: S042 body `f9d4b8b1…409e` (31121 B, normalized `5e0f0d9a…4b3a`); S043 body `4e53ed83…5442` (116603 B, normalized `31e3f241…1666`).
2. Live re-fetch, 2026-10-21. My profile differs from the declared one: `curl -sSL -A 'Mozilla/5.0'`, without `--compressed`.
   - `https://semver.org/spec/v2.0.0.html`: http=200, size=31121, exit 0
   - `https://packaging.python.org/en/latest/specifications/version-specifiers/`: http=200, size=116603, exit 0
   - `sha256sum`: `f9d4b8b1a5e9a0de6621dbbc70d69fdf05310b7a737509317b94a7bddfb9409e` and `4e53ed8342a069865ad05d26f5e492ecbca45ddc78abb58fd7dc6bf630eb5442`. Both match the pins.
   - `cmp` against the candidate's `.ufo/waves/round-27/captures/S042.body` and `S043.body`: exit 0 and exit 0, so the files are byte-identical.
3. Normalizer at candidate (`corpus/rendered-text-v1.py`):
   - `digest semver.html`: exit 0, `normalized_sha256=5e0f0d9a…4b3a`, matching the pin
   - `digest vs.html`: exit 0, `normalized_sha256=31e3f241…1666`, matching the pin
   - `locate semver.html 'Major, minor, and patch versions are always compared numerically.'`: `count=1`, exit 0
   - `locate vs.html 'Comparison and ordering of release segments considers the numeric value of each component of the release segment in turn.'`: `count=1`, exit 0
   - Scope and limit phrases, each `count=1`, exit 0: `the shorter segment is padded out with additional zeros as necessary` (vs), `Last updated on Oct 12, 2026` (vs), `Build metadata does not figure into precedence` (semver), `MUST NOT contain leading zeroes` (semver), `is not a semantic version` (semver), `pre-release version has lower precedence than a normal version` (semver).
4. Locator structure (python `html.parser` stack at the quote):
   - semver: `[ol, li, ol, li]`. 13 `<li>` openings sit between the spec `<h2>` and the quote: items 1–11 plus nested 11.1 and 11.2, so §11.2 is correct.
   - vs: `[section#version-specifiers, section#version-scheme, section#final-releases]`. "Version scheme → Final releases" and `#final-releases` (one `id`) are correct.
5. Round-27 C2 instrument:
   `python3 .ufo/waves/round-27/tools/c2-measure.py 144babcb892f0a30154880a9f94aa59ca8ddf9c5 candidate /fast/scratch/CritFinalSources/c2-candidate.json`, exit 0. Last line: `C2_MEASURE candidate: downgrades_accepted_clean=0/4 regressed_exact=4/4 control_clean=True default_exit=0`.
6. My probe, using the same harness with fixtures swapped (`/fast/scratch/CritFinalSources/lzprobe.py`, which imports c2-measure.py from its lane path and swaps `FIXTURES`/`EXPECTED_REGRESSED`):
   `python3 lzprobe.py 144babcb… /fast/scratch/CritFinalSources/lzprobe.json`, exit 0.
   - `lz_equal_fired` (S040 observed `3.15.01`, verdict fired): exit 0, `RELEASE_CLOCK: CLEAN (… observed=30 fired=4 …)`, no findings
   - `lz_equal_notfired` (S040 observed `3.15.01`, not-fired): exit 1, `INCONSISTENT S040`
   - `lz_below_floor` (S027 observed `03.15.0`, fired): exit 1, `REGRESSED S027`
   - `control`: exit 0, `CLEAN (… fired=3 …)`. Default receipt: exit 0, CLEAN.
7. Vendor-scope probe (public primary docs only):
   - `https://curl.se/docs/versions.html`: http=200, exit 0, sha256 `0b870934…c84d`
   - `https://devguide.python.org/developer-workflow/development-cycle/`: http=200, exit 0, sha256 `e4d810c6…1c16`

## Counterexamples and findings

**A. S042 "is older, not a release" overstates what SemVer says. Fixable wording; the code fails closed.**
SemVer §11 defines *precedence*: "how versions are compared to each other when ordered". It does not define chronology or release status. S043's own page gives a primary-source counterexample under §Version epochs: a project that changes its numbering ("date based versions like 2014.04 … switch to semantic versions like 1.0") publishes a release that is newer but numerically lower. Without an epoch, "the normal version ordering rules will give the wrong answer".
- The round-27 rule would type such a legitimate release `REGRESSED`. That is safe, because exit 1 forces human re-verification.
- But the S042 cell asserts it "is older, not a release". So does the code comment at `corpus/release-clock.py:569-572`: "never a newer-stable clock event".
- The lesson's REJECT row is already correct ("a typed stop for re-verification, not a claim that the vendor rolled back").
- Lesson §Limits names branch-scoped rows, but not a numbering-scheme reset.
- Smallest correction: S042 teaches "…an observed newest-stable core below the anchored core has lower SemVer precedence; the round-27 rule stops it as REGRESSED for re-verification (a numbering-scheme reset would also land here)". Add "numbering-scheme reset" to lesson §Limits.
- Axes: source fidelity (QA3), freshness (C2 limits).

**B. S042 applies SemVer ordering to vendors that have not adopted SemVer, unsourced per vendor. This is a QA9 gap; fixable by narrowing or adding vendor rows.**
SemVer scopes itself to adopters: "Software using Semantic Versioning MUST declare a public API". The FAQ says "“v1.2.3” is not a semantic version", only a tag name carrying one. The row disclaims API semantics for Vault, OpenBao, SOPS, curl and CPython, but "only the numeric core ordering is used" still assumes SemVer's ordering governs their version strings. QA9 says a sentence spanning products cites a source for each part. The lesson honestly lists vendor tagging policies as unopened leads; the row does not carry that qualifier.
- Evidence that the leg is sourceable for curl: curl's own page states numeric ordering. Quotes: "After 1.2.9 comes 1.2.10." and the hex version number "is always a greater number in a more recent release".
- CPython's devguide confirms it is *not* SemVer: "Python uses a major.minor.micro nomenclature…"; "new major versions are exceptional". So the API disclaimer is warranted. That page gives no explicit ordering rule.
- [INFERENCE] Every routed feed uses numerically increasing X.Y.Z in practice, so this is a provenance gap, not a behaviour bug.
- Smallest correction: append to S042 teaches "Applying this order to the five vendors' version strings is a lane assumption (vendor numbering policies are unopened leads, lesson §Gate)". Alternatively, open the curl page as its own row later.
- Axis: source fidelity (QA1/QA9).

**C. The code is not "strict" in the sense S042's scope claims. Executed counterexample; fixable in code.**
S042 scope says "strict MAJOR.MINOR.PATCH". SemVer §2 says normal versions "MUST NOT contain leading zeroes". `NUMERIC_VERSION_RE = [0-9]+\.[0-9]+\.[0-9]+` (`release-clock.py:366`) accepts them, and `numeric_version` integer-casts them. Fired versus not-fired then uses *string* inequality (`:581`, `:584`, `:796`).
- Result (probe 6): S040 observed `3.15.01` is numerically equal to the anchor `3.15.1`. Under SemVer it is invalid, and under PEP 440 it is equal (S043 page, §Integer Normalization). It is accepted CLEAN as a **fourth fired clock**. Recording it honestly as not-fired yields INCONSISTENT.
- Neither source supports calling it a release.
- `STABLE_TITLE_RE` (`:709`) also admits `[0-9]+`, so a feed title could produce it. [INFERENCE] Realism is low: no routed feed is known to spell leading zeros.
- Smallest correction (next round; production is frozen): when both values parse as numeric, decide equality by `numeric_version(a) == numeric_version(b)`. Or tighten the regex to `(0|[1-9][0-9]*)` per component and type a non-strict observation as INCONSISTENT. Add one selftest case.
- Axis: freshness (C2).

**D. The lesson widens S043 beyond the row. Wording only.**
`corpus/lessons/round-27.md` §Gate reads "ADMIT tier A for CPython-style release-segment ordering". The row (correctly) says "Not a CPython interpreter release policy", and the page's scope sentence covers "versions of Python software distributions". Smallest correction: "…for release-segment ordering of Python distributions (supporting evidence only; not CPython policy)". Axis: QA9.

**E. Confirmations, so the row text is not disputed further.**
- S043 "PEP 440 lineage": the page History says "August 2014: This specification was approved through PEP 440."
- The zero-padding and prerelease limits are real. `numeric_version` returns None for two-component and suffixed values.
- Kind `spec` is in the census enum (`sources-census.sh:191`).
- Recheck 180d suits frozen SemVer 2.0.0. For the living PyPA page (edits in May 2025, Nov 2025 and Jan 2026, none to final-release ordering), 180d is a tradeoff, not a defect.
- "Final releases within a project MUST be numbered in a consistently increasing fashion" binds PyPA projects only. The row correctly does not borrow it as a feed-monotonicity claim.

## Not checked

- I did not run `c1-measure.py` or `separability.py`; they are outside S042/S043. I did not run the selftest, census or any gate in the lane checkout.
- I did not fetch Vault, OpenBao or SOPS versioning-policy pages, and did not look at Go module semver rules for their tags.
- I did not test whether a live feed can actually emit leading-zero titles; that would need a feed fixture through `--observe`.
- I used the Mozilla UA rather than the declared `curl -fsSL --compressed` profile. The bytes still matched the pins exactly.
- I did not verify the selftest count 67→76 or the stamps and ledger pins.
