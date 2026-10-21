# CritFeedNotSemantics — "3.15.1 on the feed ⇒ re/html teaching changed" (round 26, C1)

Seat: `KagiR26.CritFeedNotSemantics` (critic, leaf). Axes judged: **freshness, calibration**.
Observed BASE: `git rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814` (= frozen BASE);
`git status --short` → only `?? .ufo/waves/round-26/` and `?? plans/round-26.md`.
Mode: read-only over files already on disk. No network fetch, no production code executed,
no build/lint/test, no installs. Every command below is a local read (`sha256sum`, `wc`, `grep`,
`sed`, `diff`, `cmp`, `ls`, `git show/log/rev-parse/status`).

## Verdict

**Overclaim rejected, with one fixable trap.** The S036 feed firing for S027/S028 is
*release-identity* drift (3.15.0 → 3.15.1). On the evidence in the wave, neither row's teaching
changed. But two nearby statements would also be overclaims: "re did not change in 3.15.1" and
"the docs digest changed, so it drifted". The C1 counting instrument must keep three
dispositions separate: anchor drift, teaching drift, and representation drift.

## The attack and its evidence

**Claim under attack.** `observe-1.json` (round 26) records S027 and S028 as `"parsed_version": "3.15.1"`,
`"verdict": "fired"` (entries at lines 247–267; feed sha256 `11c86a34…`). The inference
"fired ⇒ the re `\s` / `html.unescape` teaching changed" does not follow.

1. **The feed is identity only.** `corpus/SOURCES.md:42` (S036) scopes it as "CPython release identity
   (newest stable X.Y.Z item)". The fetched feed (`build/ClockS028-evidence/feed.rss`, sha256
   `11c86a34…`, 3357 B) shows `Python 3.15.1` with pubDate Wed, 21 Oct 2026 09:59:50, and a newer-dated
   `Python 3.14.9` above it. A feed title says nothing about module semantics. The round-25 lesson
   already bounds this: "a release feed misses docs-only/footer edits" (`corpus/lessons/round-25.md:222-224`).
2. **html.html — the teaching is identical between the pinned 3.15.0 build and the 3.15.1 build.**
   - The pinned 3.15.0 body is `ClockS028-evidence/html3150rel.body` (sha256 `ed0ca0ad…`, 19540 B,
     `last-modified: Fri, 09 Oct 2026 11:46:16 GMT`, title "… Python 3.15.0 documentation").
   - The current body is `html.body` (sha256 `8a541381…`, 20100 B, title "… Python 3.15.1 documentation").
   - I extracted the `id="html.unescape"` definition block from both with `sed` and ran `diff` → "identical".
   - The S028 quote ("Convert all named and numeric character references (e.g. &gt; , &#62; , &#x3e; )
     in the string s to the corresponding Unicode characters.") occurs once in each normalized text
     (`grep -c` → 1 for both `html-3.15.0.norm.txt` and `html-3.15.1.norm.txt`).
   - `cmp -l` over those normalized texts (both 2395 B) shows 8 differing bytes, at offsets
     60, 317, 1795 and 2333–2347. Every one falls in either "3.15.0/3.15.1 documentation" or the footer
     "Last updated on Oct 09/21, 2026 (…)".
   - The raw-body `diff` (24 changed lines) is all page chrome: og/twitter meta, the
     `documentation_options.js?v=` hash, an analytics script, `switchers.js`, version labels and the footer.
3. **The 3.15.1 changelog has no entry for `html` / `html.entities` / `html.unescape`.**
   - The 3.15.1 section was cut from `ClockS027-artifacts/chlog.body` (title "Changelog — Python 3.15.1
     documentation"; section `python-3-15-1-final` runs from line 1752 to line 2545, where 3.15.0 final starts).
   - It is retained as `build/CritFeedNotSemantics-changelog-3.15.1.html` (sha256 `52e7079a…`, 793 lines).
   - Searches for links into `../library/html*.html`, `unescape`, `charref`, `character reference`
     and `entit` found nothing.
   - The only `html` token is `<!DOCTYPE html>` inside gh-157406, which is an `xml.etree` fix.
4. **re.html — the teaching text is present at 3.15.1, and the normalizer avoids the one real re change.**
   - `ClockS027-artifacts/re3.body:780` (title "… Python 3.15.1 documentation") still reads
     "For Unicode (str) patterns: Matches Unicode whitespace characters (as defined by str.isspace())."
   - The changelog's only `re` entry is **gh-156444** (extract lines 345–348, chlog.body ≈2096–2099):
     "Fix matching of a negated character set in a bytes pattern compiled with both re.IGNORECASE and
     re.LOCALE."
   - The normalizer at BASE uses only str patterns: `corpus/rendered-text-v1.py:65-67`, with
     `(?is)…[^>]*…`, `<[^>]+>` and `\s+`. Its byte hash `7d6bfe81…` is identical in the working tree
     and at `git show 1bf3eec4:`. No bytes pattern and no LOCALE flag is used (LOCALE is not allowed
     on str patterns anyway).
   - So gh-156444 lies outside both S027's teaching ("str patterns") and the normalizer.

## Counterexamples the disposition must survive

- **CE1 — the U+00A0 bait (strongest).** **gh-156658** (extract lines 329–335) says "xml.dom and
  xml.etree.ElementTree no longer treat characters which are not white space in XML (such as U+00A0)
  as white space."
  - S027's teaching is that `\s` includes no-break spaces (`SOURCES.md:33`). A reader matching on
    "whitespace / U+00A0 / 3.15.1" will conclude S027 changed.
  - It did not. The entry concerns XML whitespace in xml.dom/xml.etree, not `re` or `str.isspace()`.
  - Fix: the disposition must name gh-156658 as *considered and out of scope*. Ignoring it silently
    is not acceptable.
- **CE2 — "re unchanged in 3.15.1" is false.** gh-156444 is a real re behaviour change. The
  calibrated statement is: "re changed in 3.15.1 only for bytes+IGNORECASE+LOCALE negated sets,
  which is disjoint from S027's str-pattern `\s` teaching and from rendered-text-v1's patterns."
- **CE3 — false provenance by filename.** The files named for 3.15.0 contain 3.15.1 bytes:
  - `ClockS028-evidence/html3150.body` is byte-identical to `html.body` (both sha256 `8a541381…`,
    both titled 3.15.1, same etag `"6ad8b85e-4e84"`).
  - `ClockS027-artifacts/re315.body` is identical to `re3.body` (sha256 `0724d815…`,
    etag `"6ad8b85d-3d7a3"`, title 3.15.1).
  - Diffing either pair "3.15.0 vs 3.15.1" compares 3.15.1 with itself. ClockS028 caught this by
    fetching `html3150rel.body`. **No pinned 3.15.0 re.html body exists in the wave**, so S027 has no
    doc-to-doc diff. Its evidence is quote presence at 3.15.1 plus the changelog scan; it must not be
    called "docs unchanged 3.15.0→3.15.1".
- **CE4 — a digest mismatch is not drift.** The recorded S028 normalized digest is `7a19837f…`
  (`corpus/source-fetches.tsv:71`). It matches neither the pinned 3.15.0 normalized text
  (`d3e59063…`) nor the 3.15.1 one (`ef8996ed…`), because the normalized text includes the version
  label and the footer timestamp. A digest-equality check would therefore call even the
  3.15.0 docs "drifted". This repeats the round-25 volatile-representation precedent
  (`round-25.md:131-134`).

## Smallest safe correction (bounded disposition)

For S027 and S028, record in the **new** round-26 receipt and lesson (do not edit
`release-clocks.tsv:24-25`, `source-fetches.tsv:70-71`, or round-25's `observe-1.json`):

- `anchor-drift: 3.15.0 → 3.15.1 (S036 feed, 2026-10-21T13:36:36Z)`.
- `teaching: unchanged (bounded)`, with the evidence each row actually has:
  - S028: an identical `html.unescape` block between the pinned 3.15.0 and 3.15.1 builds, plus the
    changelog scan.
  - S027: the quote present at 3.15.1 (`re3.body:780`), plus the changelog scan with gh-156444 and
    gh-156658 named and judged out of scope. Also state that no pinned 3.15.0 re.html body was retained.
- `representation drift: digests moved (version label + footer); not semantic`.

Impact on the counting instrument: count these as **two anchor-drift dispositions with zero teaching
changes**, never as teaching drift. If the plan supersedes the stale "Python 3.15.0 documentation"
anchors with new rows, those rows MUST carry the teaching text verbatim and say "teaching unchanged".
A superseding row MUST NOT imply a semantic correction. The S012 precedent applies: anchor stale,
teaching holds (`round-25.md:118-127`).

Limits, stated plainly:
- Documentation is not runtime. No CPython 3.15.1 interpreter was run; that is consistent with the
  plan's "No assertion of … installed Python upgrade".
- The changelog lists curated news entries, not every commit.
- A quote locating proves only the quoted sentence holds (`round-25.md:222`).

## Impacted axes

- **Calibration:** at risk from CE1, CE2 and CE4 (overclaiming either drift or no change).
- **Freshness:** at risk from CE3 (stale evidence labelled current under a 3.15.0 filename).
- No harm to other axes. The round-25 receipt and the lone-clone INCOMPLETE/48 are untouched by this
  seat.

## Process disclosure

- I briefly wrote the changelog extract to `/tmp/kagi-r26-crit-3151.html`, which is outside my
  permitted write area. I moved it with `mv` to `build/CritFeedNotSemantics-changelog-3.15.1.html`,
  so no copy remains in `/tmp`.
- Files written: this report and that one artifact. No installs.
- UNRUN:
  - `release-clock.py`, `rendered-text-v1.py` and all gates and selftests. The normalized texts I
    compared were produced by sibling ClockS028, not by me.
  - Any fetch of a pinned 3.15.0 `re.html`.
