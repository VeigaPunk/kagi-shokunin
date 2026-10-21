# SrcPep440 — C2 source curation: PyPA version specifiers

BASE `0a47dd189356ea66ec83c3891eed54526e95b89b`. Leaf source seat; no subagents.
Verdict: **ADMIT as S043, tier A, scope narrowed** (the working-tree draft at
`corpus/SOURCES.md:50` is admissible but four wordings over-read the page). No
rejection: the page carries the ordering statement the C2 comparator uses.
I did not write the registry; row text below is advice to L1.

## 1. Fetch receipt (observed)

| field | value |
|---|---|
| URL | `https://packaging.python.org/en/latest/specifications/version-specifiers/` |
| access (UTC) | 2026-10-21T15:16:23Z |
| HTTP | 200, no redirect (`%{url_effective}` identical) |
| decoded body | sha256 `4e53ed8342a069865ad05d26f5e492ecbca45ddc78abb58fd7dc6bf630eb5442`, 116603 bytes |
| rendered-text-v1 | sha256 `31e3f241a30e8d5928a38971904d31c96dde9bc6f76b79fa0f053d8f42411666`, 49801 bytes |
| locate | `python3 corpus/rendered-text-v1.py locate …` → `count=1` |
| page date | “Last updated on Oct 12, 2026”; History last entry Jan 2026; edit link `pypa/packaging.python.org/blob/main/source/specifications/version-specifiers.rst`, no commit displayed |

These reproduce the declared capture at `corpus/source-fetches.tsv:86` (working
tree, uncommitted) exactly: body digest, byte count, normalized digest, locate.
That row's `row_identity_sha256` `0865363f…` is sha256 of
`S043\tmined\t<url>\n`, which I recomputed and match. My curl omitted the
declared `-f -L -A` flags (used `--compressed -sS`); with no redirect and an
identical decoded body this does not change the representation the lane records. Two fetches (L1 at 15:13:51Z, mine at
15:16:23Z) agree byte-for-byte; that is a same-day pair, not a stability claim.

## 2. Located quote and anchor

> “Comparison and ordering of release segments considers the numeric value of each
> component of the release segment in turn.” — 19 words.

§Final releases, an `<h3>` inside `<section id="final-releases">` under the
`Version scheme` H2 (`#final-releases`). The next sentence: “When comparing
release segments with different numbers of components, the shorter segment is
padded out with additional zeros as necessary.”

Supporting sentences, each located exactly once:
- “The same version with and without the v is considered equivalent.” (§Preceding v character)
- “X.Y and X.Y.0 are not considered distinct release numbers” (§Final releases, Note)
- “A version identifier that consists solely of a release segment and optionally an epoch identifier is termed a” final release (§Final releases)
- “all versions from a later epoch are sorted after versions from an earlier epoch” (§Version epochs)

## 3. What the page supports for the C2 rule

Rule under test (`plans/round-27.md:29-31`): “an observed newest-stable release
numerically below the anchored X.Y.Z is a typed `REGRESSED` finding (exit1, never
CLEAN, never a release event)”.

| rule clause | verdict | basis |
|---|---|---|
| a strict-X.Y.Z final release below another strict-X.Y.Z is **older** | **SUPPORTED** | component-wise numeric release-segment ordering (quote above); numeric, not text, comparison is also stated in §Public version identifiers |
| therefore it cannot be a **newer release than the anchor**, so treating it as the clock firing is wrong | **SUPPORTED** | same ordering; a lower final release cannot be a newer release than the anchor under this precedence |
| the observation is a **typed regression finding with its own exit code** | **NOT SOURCED — lane policy** | the spec supplies precedence only; it prescribes no consumer finding/exit disposition. Nothing in it forbids a tool from reporting “older”. |
| it is **not a release event** in the sense “the vendor published nothing” | **NOT SUPPORTED** | a lower final release is a real final release of its own series. §Final releases: “A release series is any set of final release numbers that start with a common prefix. For example, 3.3.1, 3.3.5 and 3.3.9.45 are all part of the 3.3 release series.” |
| the feed is **stale or cropped** | **NOT SUPPORTED** | the word “feed” occurs 0 times in the specification body. No statement about feed completeness, entry retention, or monotonicity. |
| only a **final** release can be the newest-stable observation | **SUPPORTED** | final/pre/post/dev are disjoint defined kinds; only the release-segment form is a “final release” |
| `v`-prefix equality used by `norm_version` | **SUPPORTED** | §Preceding v character |
| two-component anchors are unorderable | **NOT SUPPORTED — the spec orders them** | zero padding makes X.Y == X.Y.0; §Final releases Note |

One adjacent normative sentence is supporting but not dispositive: “Final
releases within a project MUST be numbered in a consistently increasing fashion,
otherwise automated tools will not be able to upgrade them correctly.”
(§Final releases, located once). It establishes that a non-increasing final
release breaks automated upgrade comparison — the direction the rule refuses —
but it is a MUST on project numbering, not a licence to call a lower-series
maintenance release a violation, and it says nothing about feeds.

Precise wording that is defensible from this page: *the observation is older than
the anchor, so this clock has not fired and cannot be accepted CLEAN.* The words
“regression”, “stale”, “cropped”, “rolled back”, and “no release” are lane
vocabulary, not this source.

## 4. Prerelease / backport / yank

**Prerelease.** Supported: a pre-release is a different kind and is not a final
release, so a stable clock must not take it as the newest stable. Not covered:
the rule's “below” test only makes sense on cores of final releases. The spec's
own ordering example puts `1.0.post456 < 1.0.15 < 1.1.dev1`, i.e. a prerelease of
a **higher core sorts above a lower core's final release**. So `3.16.0a1` is
**above** `3.15.1`, not below it. The lane avoids the question because
`STABLE_TITLE_RE` (BASE `corpus/release-clock.py:649`) rejects `3.16.0a1` and
`v2.2.0-rc1`; that regex is load-bearing, not cosmetic. If prereleases were ever
admitted to `parse_latest_version`, the inequality rule would report a prerelease
as a firing (observed SELFTEST control at working tree
`corpus/release-clock.py:1130-1140` keeps them out).

**Backport.** The page does **not** define an upstream maintenance release in an
older series. Its only two “backport” mentions are downstream rebuilds carrying a
local label (`1.0+ubuntu.1`), §Local version identifiers and the upstream/
downstream definition. What it does give: `3.14.9` is a final release in the
`3.14` series (common-prefix definition) and `3.14.9 < 3.15.1`. Consequence for
the rule: with anchor `3.15.1`, a feed whose newest stable is `3.14.9` is
correctly typed older — but the finding means “this clock cannot confirm a newer
release”, **not** “the vendor regressed” and **not** “3.14.9 is not a release”.
Live analogue: the CPython RSS first item is `3.14.9` (S039 row,
`corpus/SOURCES.md:46`, working-tree draft), while `corpus/release-clocks.tsv:24-25`
records S027/S028 anchored at `3.15.0` firing on `3.15.1`; only the max-stable
parse keeps `3.15.1` as the observation.

**Yank.** The page does not define it: “yank” occurs 0 times in the body; its only
two occurrences are sidebar links to `../file-yanking/`, a separate spec I did not
open. A withdrawn release that makes the feed's newest stable fall below the
anchor still satisfies the ordering (the visible newest is older), so `REGRESSED`
remains *safe* (never CLEAN); but this page cannot source “yanked” as a cause,
and the lesson must not name yank without opening the File Yanking specification
(flip: add that row and cite it).

## 5. Counterexamples against the current draft rule

Concrete, from the code at working tree `corpus/release-clock.py` (uncommitted
round-27 draft; BASE has no `is_regression`, see §7):

1. **Two-component anchor false fire.** anchor `2.2`, observed `2.2.0`,
   verdict `fired` → `is_regression` returns False (anchor not strict X.Y.Z,
   `numeric_version` at `:369-379`), then `norm_version("2.2.0") != "2.2"` →
   row counted fired (`:542-556`). PEP 440 says these are not distinct. No such
   anchor exists in `corpus/release-clocks.tsv` today (all feed anchors are
   three-component except `v1.21.x`, `:9`), so the limit does not bite yet.
2. **Two-component anchor missed regression.** anchor `3.15`, observed `3.14.9`,
   verdict `fired` → fires, although PEP 440 orders `3.14.9 < 3.15.0`.
3. **Backport is not causation.** anchor `3.15.1`, observed `3.14.9` → `REGRESSED`
   (ordering correct), while `3.14.9` is a genuine final release of series 3.14.
4. **Higher-core prerelease.** anchor `3.15.1`, observed `3.16.0a1` → unparsed by
   `STABLE_TITLE_RE` (`BASE corpus/release-clock.py:649`), so no observation;
   if a looser regex admitted it, PEP 440 orders it **above** `3.15.1` and the
   inequality rule would call it fired.
5. **Epoch.** anchor `3.15.1`, observed `1!1.0` → `!` is rejected by the strict
   regexes, so the feed yields no observation. PEP 440 says `1!1.0` is newer.
   Safe (not CLEAN) but a limit; stripping the epoch before comparison would
   invert the result into a false `REGRESSED`.
6. **Leading-zero normalization.** anchor `3.15.1`, observed `03.15.1` → parses
   (`[0-9]+`), `norm_version` strings differ → fired. §Integer Normalization says
   `09000` normalizes to `9000`. Low likelihood in vendor tags; same class as (1).
7. **Yank.** anchor `3.15.1`, `3.15.1` withdrawn, feed max becomes `3.14.9` →
   `REGRESSED`; ordering holds, cause is not attributable from this page.

## 6. Proposed registry row (advice; not written)

Keep id **S043** (already drafted at `corpus/SOURCES.md:50`; the fetch row at
`corpus/source-fetches.tsv:86` is correct and reproduced). Recommended field
changes: drop “CPython-style” (the page scopes itself to “versions of Python
software distributions”; CPython interpreter releases are not distributions, and
S042 carries the generic numeric-core claim), and add the explicit
non-support clauses.

```
| S043 | Version specifiers (PyPA packaging specification, PEP 440 lineage) — https://packaging.python.org/en/latest/specifications/version-specifiers/ | spec | A | PEP 440 final-release ordering for Python distribution versions: component-wise numeric release-segment comparison and shorter-segment zero padding; strict X.Y.Z cores used only as a comparator — not CPython's own release policy, not feed completeness, backport-release or yank semantics | §Final releases (#final-releases) under Version scheme; §Version epochs; §Preceding v character; page Last updated on Oct 12, 2026, History last entry Jan 2026; docs source source/specifications/version-specifiers.rst on main, no commit displayed; fetched 2026-10-21 | Final release segments compare by numeric component value in turn, so a final X.Y.Z below the anchor is older: that clock has not fired and cannot be CLEAN. Pre-releases are a distinct kind and never a newest-stable observation; a higher-core pre-release (3.16.0a1) orders above a lower-core final (3.15.1). The page also orders X.Y == X.Y.0 and epochs above every epoch-0 version, which the strict-X.Y.Z comparator does not implement (declared limits). It defines no feed, yank or backport-release semantics. Quote: “Comparison and ordering of release segments considers the numeric value of each component of the release segment in turn.” (§Final releases, rendered text). | mined | 2026-10-21 | 180d | corpus/lessons/round-27.md |
```

Field checks against `corpus/sources-census.sh`: kind `spec`, tier `A`, status
`mined` are in-enum; used-by `corpus/lessons/round-27.md` carries `S043` on its
`source:` line (line 1), so SC_USEDBY_NOCITE passes; anchor/teaches contain no
pipes or tabs. `recheck 180d` matches S042. No capture-row change needed; the
declared representation `decoded-http-body-volatile-v1` is consistent with the
other docs rows (39 of 43), and the census moving-ref rule only forces a 40-hex
revision for `*/main/*`/raw.githubusercontent URLs, so `/en/latest/…` with `-`
passes — but the real pin is the page's Last-updated date, not a commit.

There is no rejection path with a coherent flip: the page does state the
ordering, so declining it would be a redundancy call (the S042 SemVer row,
another seat's curation, already covers numeric cores), not a sourcing failure —
and the registry has no “redundant” status. My recommendation is
admit-and-narrow; if L1 declines, record it as a scope decision in the round
lesson rather than a `rejected` row.

## 7. Calibration notes on the draft lesson and code (not registry)

- `corpus/lessons/round-27.md:26` “CPython-style release-segment ordering” →
  recommend “PEP 440 / Python-distribution release-segment ordering”. The page
  says “This specification describes a scheme for identifying versions of Python
  software distributions”; it is not authority for CPython's release policy.
- `corpus/lessons/round-27.md:74-77` lumps “two-component or series anchors and
  prerelease ordering” into one limit. Sharpen: `v1.21.x` is genuinely
  unorderable (not a valid public version), whereas `2.2` vs `2.2.0` and
  pre-release cores **are** ordered by this page. Those two are implementation
  limits that can produce a false fire or a missed regression; only the series
  anchor is a spec gap.
- Working-tree `corpus/release-clock.py:542-543` comment says “stale/cropped/
  rolled-back feed”. “Rolled back” asserts vendor action the source does not
  support; use a neutral cause list (“older observation: stale, cropped,
  retracted, or a lower-series final release”).
- `norm_version` (`:362-363`) strips `v`, which this page supports, but not
  integer leading zeros or the X.Y == X.Y.0 padding. Either declare both as
  limits in the lesson or implement padding (the spec allows it).
- [INFERENCE, code reading only, not executed] A live `--observe` writes receipt
  verdict `regressed` (`:762-763`), while `receipt_matches` requires
  receipt verdict == TSV verdict (`:435`) and the TSV verdict enum check is
  skipped only inside the `is_regression` branch (`:542-551`). So a genuinely
  regressed row must be recorded with the lower `observed_version` **and**
  `verdict regressed`; leaving `fired` yields `REGRESSED` plus
  `RECEIPT-MISMATCH`. `HEADER` (`:24-27`) does not document `regressed` as a
  third verdict value. Worth one header/README sentence from L1.

## 8. What I did NOT check

- Did not run `corpus/release-clock.py` (`--check`, `--observe`, `selftest`) or
  `corpus/sources-census.sh`; L1 runs final checks. The §5 counterexamples are
  from reading the comparator and regexes, not from executing fixtures.
- Did not open PEP 440 itself (`peps.python.org`), the File Yanking spec linked
  from the nav, or the S042 SemVer page (other curator's item). Yank statements
  above are absence-of-content findings on this page only.
- Did not resolve a git commit for `source/specifications/version-specifiers.rst`
  on `main`; the page displays no revision, and I did not query GitHub. The
  anchor's date is the page's own Last-updated line.
- Did not test long-term byte stability of the capture (two same-day fetches
  only), and did not verify any page elsewhere in the guide that might supersede
  the ordering wording.
- Did not assess C1 knowledge-number bindings; out of this seat's item.
- No tools installed or upgraded; nothing needed.
