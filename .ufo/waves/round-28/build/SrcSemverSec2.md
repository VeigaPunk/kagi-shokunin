# SrcSemverSec2 — SemVer 2.0.0 §2 (leading zeroes), round-28 source opening

BASE `3553d499577084a6c98d7078906017840bbf7b28`; `git diff --stat BASE HEAD` → only
`plans/round-28.md` + `.ufo/waves/round-28/census-start.txt`, so `corpus/` lines below are BASE
lines. Page lines are the saved artifact `.ufo/waves/round-28/sandboxes/SrcSemverSec2/semver.html`.

## Receipt

- `curl -sS -L -o semver.html -w 'status=%{http_code} url=%{url_effective} bytes=%{size_download}' https://semver.org/spec/v2.0.0.html`
  → exit 0, **HTTP 200**, final URL `https://semver.org/spec/v2.0.0.html`, **31121** bytes,
  access date **2026-10-21** (17:07Z), saved body sha256
  `f9d4b8b1a5e9a0de6621dbbc70d69fdf05310b7a737509317b94a7bddfb9409e`.
- Headers: `text/html; charset=utf-8`; `last-modified: Fri, 16 Oct 2026 23:30:38 GMT` (deployment
  metadata, not a spec revision date); `server: GitHub.com`. Exact title
  **`Semantic Versioning 2.0.0 | Semantic Versioning`** (`<title>`, semver.html:10); one `<h1>` =
  `Semantic Versioning 2.0.0` (:382); `og:title` same (:12). Register the short form, as S042 does.

## Findings

**F1 — the page is byte-identical to round-27's capture; no re-capture is needed.** S042's capture
row (`corpus/source-fetches.tsv:85`) records decoded-body sha256 `f9d4b8b1…b9409e` (col 10) and
31121 bytes (col 11) — both reproduced. Re-implementing the declared `rendered-text-v1` normalizer
(strip script/style, tags→space, `html.unescape`, collapse whitespace, trim, UTF-8) over my body also
reproduced the recorded normalized digest `5e0f0d9a…634b3a` (col 15; 16911 chars). That digest is
the sha256 of the **whole normalized page**, not of the quote (the §11.2 quote alone hashes to
`4f5c15d1…`), so per-quote hashes must not be written as provenance. `fetched=2026-10-21` stays valid.

**F2 — quote that grounds the purpose (23 words, verbatim, located once).**
`A normal version number MUST take the form X.Y.Z where X, Y, and Z are non-negative integers, and MUST NOT contain leading zeroes.`
Locator **§Semantic Versioning Specification (SemVer), item 2**, anchor
`#semantic-versioning-specification-semver` (h2 semver.html:431; text :444-445). Verbatim under the
declared whitespace collapse; one occurrence in raw HTML and one in normalized text (offset 3366).
The page declares RFC 2119 keywords at :432-435, so "MUST NOT" is normative; `3.15.01` is therefore not a normal version number under this spec.

**F3 — official BNF and regex for numeric identifiers.** BNF §"Backus–Naur Form Grammar for Valid
SemVer Versions" (h2 :554): `<numeric identifier> ::= "0" | <positive digit> | <positive digit> <digits>`
(:589-591), `<positive digit> ::= "1" | … | "9"` (:608). Regex §FAQ (h3 :740): both variants encode
no-leading-zero as `(0|[1-9]\d*)` per position — named-group :748, numbered-group :758 — linking
`regex101.com/r/Ly7O1x/3/` and `regex101.com/r/vkijKf/1/`. The regexes are **FAQ suggestions,
non-normative**; cite §2 + the BNF as the parser ground, not the regex.

**F4 — duplicate URL: EXTEND S042, do not add a row.** `grep -ni semver corpus/SOURCES.md` at BASE
matches only `:49` (S042), `:50` (S043, different URL), `:76` (search log) — the URL is registered
once. Fleet rule `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh:645`: a later row repeating
a normalized URL under a **different** scope prints `W04 … duplicate url semver.org/spec/v2.0.0.html
across scopes`; under the **same** scope it is a hard `E04` error (`:649`, exempt only by
`supersedes S0nn`). A new row either adds a 12th W04 to the 11-line START census
(`.ufo/waves/round-28/census-start.txt:2-12`) or fails. Extension does neither. *[INFERENCE: read
from the census rule, not executed.]*

**F5 — the frozen plan's own citation dangles at BASE.** `plans/round-28.md:22` (live tree; absent at
BASE — `git cat-file -e BASE:plans/round-28.md` → exit 128; added by claims commit `bdf90f58`, whose
tree adds only that plan and the START census) cites "SemVer S042 §2", but S042's anchor cell
(`corpus/SOURCES.md:49`, col 6) names only `§11 Precedence, item 11.2` and its teaches cell has no §2
sentence. `grep -rn -i 'leading zero' corpus/ *.md` at BASE → no matches, so nothing else already
teaches this; the extension is new content, not duplication.

**F6 — the 4300-digit bound is NOT grounded here; keep it off S042.** FAQ "Does SemVer have a size
limit on the version string?" answers `No, but use good judgment. A 255 character version string is
probably overkill` (:726-730). SemVer supplies **no** bound, so C1's oversize arm must cite the
Python integer-string conversion-limit row opened this round; attaching "bounded" to §2 would invent
a requirement.

**F7 — scope limit of §2 (honest counterexample).** §2 constrains a *normal version number*; it does
not say how a consumer must treat a non-canonical token, and it does not claim Vault/OpenBao/SOPS/
curl/CPython publish SemVer (S042 col 7 already carries that caveat). The BASE defect is consumer
acceptance: `corpus/release-clock.py:582` treats `norm_version(observed) != norm_version(anchored)` as
satisfied for a `fired` verdict (so `3.15.01` passes against anchor `3.15.1`), and `:380` maps both to
`(3,15,1)`, so `is_regression` sees no regression. "Type it, never fire it" is C1 policy on the spec's canonical form, not a spec sentence.

**F8 — exact old→new for S042 (`corpus/SOURCES.md:49` at BASE); cols 1-4, 8-10 unchanged.**

| col | old (exact, verified `in` the row) | new (proposed) |
|---|---|---|
| 5 scope | `Precedence of strict MAJOR.MINOR.PATCH version cores: numeric, left-to-right comparison; prerelease/build suffixes excluded from the core` | `Precedence of strict MAJOR.MINOR.PATCH version cores: numeric, left-to-right comparison; canonical numeric identifiers (no leading zero in a multi-digit component); prerelease/build suffixes excluded from the core` |
| 6 anchor | `§11 Precedence, item 11.2; Semantic Versioning 2.0.0 as served, fetched 2026-10-21` | `§11 Precedence, item 11.2; §2 item 2 + §Backus–Naur Form Grammar (<numeric identifier>); Semantic Versioning 2.0.0 as served, fetched 2026-10-21` |
| 7 teaches | `Strict X.Y.Z cores order numerically, so an observed newest-stable core below the anchored core is older, not a release (round-27 REGRESSED rule); Vault, OpenBao, SOPS, curl and CPython are not asserted to follow SemVer's API semantics, only the numeric core ordering is used. Quote: “Major, minor, and patch versions are always compared numerically.” (§11.2).` | `Strict X.Y.Z cores order numerically, so an observed newest-stable core below the anchored core is older, not a release (round-27 REGRESSED rule); Vault, OpenBao, SOPS, curl and CPython are not asserted to follow SemVer's API semantics; only the numeric core ordering and the canonical form of a core component are used. Canonical form: a numeric identifier is 0 alone or a positive digit followed by digits, so a component with a leading zero is not a canonical X.Y.Z core and a token such as 3.15.01 must be a typed finding, never a fired release (round-28 C1 rule). Quotes: “Major, minor, and patch versions are always compared numerically.” (§11.2); “A normal version number MUST take the form X.Y.Z where X, Y, and Z are non-negative integers, and MUST NOT contain leading zeroes.” (§2 item 2; BNF <numeric identifier>).` |
| 11 used-by | `corpus/lessons/round-27.md` | `corpus/lessons/round-27.md, corpus/lessons/round-28.md` |

Old→new log for `corpus/lessons/round-28.md` Gate: `S042 extended in place (round 28, no new row):
scope += canonical numeric identifiers; anchor += §2 item 2 + BNF; teaches += canonical-form rule and
the §2 quote (23 words, located once); used-by += corpus/lessons/round-28.md. Old cells quoted in
.ufo/waves/round-28/build/SrcSemverSec2.md F8.` Proposed `## Search log` entry: `Round 28
(2026-10-21): question — what grounds "a version token with a leading zero is not a canonical core"?
Where searched — the registered SemVer 2.0.0 page (S042), re-opened for §2 and the BNF. Identified 1,
screened 1, included 0 new rows (S042 extended in place; W04 unchanged at 11), excluded 0. Not
opened: the two regex101 links (page-embedded regex text read instead). Stop: §2 gives the canonical
form; it gives no length bound (FAQ says none) and does not govern non-SemVer vendors.`

**F9 — landing constraints read from the census (not executed).** `used-by` entries must match
`^corpus/(knowledge|lessons)/[A-Za-z0-9._-]+\.md$` and the cited file's `source:` header must name
`S042` (`corpus/sources-census.sh:212-232`, `SC_USEDBY_NOCITE`), so `corpus/lessons/round-28.md` must
exist **and** carry `source: … S042 …` when S042 lands. Keep the 11-field contract (`NF==13`, no raw
`|` in a cell). Do **not** add a `Fetch sha256:` token: S042 has no `corpus/inrow-pins.tsv` entry and
is outside the historical S001-S016 exemption, so a bare in-row pin raises `SC_INROW
inrow-pin-not-historical` (`corpus/sources-census.sh:320-328`). Do not replace the §11.2 quote: the
capture row pins it by quote/locator (cols 13/16); use two quoted locators as in F8.

## Tier / duplicate / verdict

- **Tier A** — primary normative specification, RFC 2119 declared on-page; kind `spec` (unchanged).
- **Duplicate:** URL already registered as S042 (`corpus/SOURCES.md:49`); propose no second row.
- **REJECT: no** — the page grounds the purpose directly. Reject instead (a) a duplicate row, per F4,
  and (b) any attempt to source the 4300-digit bound from §2, per F6.

## Commands run

`curl` fetch → 0 (HTTP 200); `grep -c 'MUST NOT contain leading zeroes'` → 1; `git archive BASE | tar -x`
→ 0; `git diff --stat BASE HEAD` → 0 (2 files, `corpus/` untouched); `git cat-file -e BASE:plans/round-28.md`
→ 128 (absent); `git diff-tree --name-status bdf90f58` → 0 (plan + census); `grep -ni semver corpus/SOURCES.md`
→ 0 (:49/:50/:76); `grep -rn -i 'leading zero'` → 1 (none). No installs; no lane writes outside this report.

## Not checked

- Did not run the fleet census or any lane gate; F4/F9 consequences are read from the scripts, so the
  END census must confirm the W04 count stays at 11 *[INFERENCE, not measured]*.
- Did not fetch S043/PEP 440, the Python int-limit docs, or the regex101 links; whether PEP 440 states
  a leading-zero rule, and whether regex101 matches the page text, are unverified.
- Did not run C1's F1–F4 fixtures or edit `corpus/release-clock.py`; the `3.15.01` acceptance is read
  at `:582`/`:380`, not executed. No semver.org repo history; no vault/account/handler/CDP contact.
