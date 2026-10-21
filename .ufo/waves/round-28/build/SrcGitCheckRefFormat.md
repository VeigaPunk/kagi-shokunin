# SrcGitCheckRefFormat — git-check-ref-format source opening

Verdict: **ADMIT, tier A**, new URL (no duplicate), narrow scope. It grounds C1's *permission*
side (git will not stop an upstream tag named `v3.15.01`); it does **not** ground the canonical
rule C1 invokes (see F7). BASE `3553d499577084a6c98d7078906017840bbf7b28`.

## Findings

**F1 — fetch (accessed 2026-10-21).** `GET https://git-scm.com/docs/git-check-ref-format`,
HTTP **200**, final URL **identical** (no redirect), `content-type: text/html; charset=utf-8`,
decoded body **37201 bytes**, sha256 **`4f0c6bb34dda79c71c1a04528da75644266f3dc069446b71cf63e3bee90b65ea`**.
Saved at
`.ufo/waves/round-28/sandboxes/SrcGitCheckRefFormat/check-ref-format.html`. A second fetch under
the lane's declared profile (`curl -fsSL --compressed -A 'kagi-shokunin-round28/1.0 …'`) gave
7123 on-wire bytes and a **byte-identical decoded body** (`cmp` exit 0, same sha256), so the
capture fits `decoded-http-body-v1` without a volatility claim (two fetches minutes apart are
not a drift series).

**F2 — exact title and locators.** `<title>Git - git-check-ref-format Documentation`
(`check-ref-format.html:31`). NAME section: “git-check-ref-format - Ensures that a reference name
is well formed”. The page is **versioned**, not "unversioned live docs": footer reads
“git-check-ref-format last updated in 2.52.0” and “2.53.0 → 2.56.0 no changes”
(extracted-text lines 148–150 of the saved body). Anchor: `§DESCRIPTION`, `h2 id="_description"`
(`check-ref-format.html:1669`).

**F3 — quote (verbatim, located).** Primary, 10 words:
“Git imposes the following rules on how references are named:” — `§DESCRIPTION`
(h2 `_description`). Corroborating, 12 words: “a tag is stored in the refs/tags hierarchy of the
ref namespace” — same section. Both locate under the lane's own normalizer:
`collapse_quote(q) in rendered-text-v1.normalize_bytes(body)` → `True`/`True`. Note the second
quote spans a `<code>` span in raw HTML, so `raw-literal-v1` would **fail** it; declare
`rendered-text-v1`.

**F4 — what it grounds, with executed evidence (git 2.56.0).** `git check-ref-format` exit codes:
`refs/tags/v3.15.01` → **0**; `refs/tags/v3.15.1` → **0** (both legal, so two distinct tags whose
version tokens are string-unequal but int-equal); `refs/tags/３.15.01` (fullwidth digit) → **0**;
`refs/tags/3.15..01` → 1; `refs/tags/3.15.01.` → 1; `refs/tags/3.15.01 ` (trailing space) → 1.
The documented list bans characters and shapes only (`§DESCRIPTION` items 1–10); it contains no
numeric-canonicality rule and no ASCII-only leaf rule. Combined with the exhaustive phrasing
(F3 quote), this is the premise C1 needs: an upstream may legally publish tag `v3.15.01`, so a
feed title cannot be assumed canonical and must be refused as a typed finding.

**F5 — what it does NOT ground.** (i) It says nothing about release feeds, titles or GitHub; that a
feed `<title>` equals the tag name is `[INFERENCE]` from the lane's own S033–S035 rows
(`corpus/SOURCES.md:39-41`, quotes `<title>v3.13.3</title>` beside `/releases/tag/v3.13.3`).
(ii) Unicode *names* are legal, but C1's tokens are ASCII `[0-9]` (`corpus/release-clock.py:30-31`,
`:366`), so a fullwidth-digit title is not a version token at all. Row scope must stop at
"permitted name space".

**F6 — duplicate check.** `grep -c -i 'git-scm' corpus/SOURCES.md` → **0** over 43 rows
(S001–S043), same in the lane working tree. No row or lesson cites this manual
(`grep -rn 'check-ref-format'` hits only round-25/27 wave reports about a different repo). A new
row adds **no** W04. (W04 is the fleet census warning, not `corpus/sources-census.sh`; START
census lists 11.)

**F7 — calibration gap, C1-side, not repaired by this row.** `plans/round-28.md:22` cites
“SemVer S042 §2” for the no-leading-zero rule, but S042's registered locator is **§11.2 only**
(`corpus/SOURCES.md:49`, quote “Major, minor, and patch versions are always compared
numerically.”), and `grep -rn 'leading zero' corpus/` at BASE returns nothing. **§2 is not located
by any registry row.** C1's lesson must open a §2 locator this round or state the canonical rule
as the lane's own bound; otherwise the citation is a locator overreach of the S022/S023 kind.
This git row cannot substitute — git is silent on canonical versions.

**F8 — frozen-predicate edge (inference, unrun).** On the observe path a 4301-digit title raises
`ValueError` at `corpus/release-clock.py:760` (`max(..., key=tuple(int(part)…))`), caught at
`:822-823`; the receipt then carries `error`, and `receipt_matches` returns False on `"error" in
receipt` (`:430`). Result: exit 1 with `RECEIPT-MISMATCH S040` and no traceback — which the
frozen predicate (`plans/round-28.md:38-41`) could read as **already TYPED at BASE**, making F4
non-discriminating. The fix must emit a distinct named category, not rely on receipt mismatch.
I did not run it: `.ufo/waves/round-28/tools/` is empty (no `c1-measure.py` yet).

## Proposed rows (advice to L1; next free id S044)

Registry (`corpus/SOURCES.md`):

| S044 | git-check-ref-format — https://git-scm.com/docs/git-check-ref-format | docs | A | Git's refname rule set as the outer bound on legal tag names: only listed characters and shapes are banned, so numeric canonicality is not enforced at the name level; says nothing about feed titles or release names | §DESCRIPTION rules list (h2 id=_description); footer “git-check-ref-format last updated in 2.52.0”, “2.53.0 → 2.56.0 no changes”; fetched 2026-10-21 | Git documents only listed bans, so a tag named refs/tags/v3.15.01 is legal and a title copied from a tag need not be a canonical version token. Quote: “Git imposes the following rules on how references are named:” (§DESCRIPTION). Seeded: git 2.56.0 `git check-ref-format refs/tags/v3.15.01` exits 0, `refs/tags/3.15..01` exits 1. Bounds what git permits, not what any upstream emits. Fetch sha256: `4f0c6bb34dda79c71c1a04528da75644266f3dc069446b71cf63e3bee90b65ea`. | mined | 2026-10-21 | 180d | corpus/lessons/round-28.md |

Capture (`corpus/source-fetches.tsv`, 16 tab-separated columns):
`S044  mined  34cb75dba4f74074f87f695c0858e9dd43e47b635e478c98c2d61ba369763d5d  https://git-scm.com/docs/git-check-ref-format  https://git-scm.com/docs/git-check-ref-format  200  curl-fsSL-compressed-v1  2026-10-21  decoded-http-body-v1  4f0c6bb34dda79c71c1a04528da75644266f3dc069446b71cf63e3bee90b65ea  37201  -  Git imposes the following rules on how references are named:  rendered-text-v1  6e9d5d7b0c2c83d72a9a26d3a5bfec784f9985eafd5ee785d72cb3fc9ae522bd  DESCRIPTION, rules list (h2 id=_description)`
(fields separated by tabs in the real row; `row_identity_sha256` computed as
sha256 of `S044<TAB>mined<TAB>https://git-scm.com/docs/git-check-ref-format<LF>`; normalized
digest computed with the BASE `corpus/rendered-text-v1.py`.)

Tier: **A** — official Git project manual page for the command, normative for what git accepts,
not a third-party summary. `kind=docs`; `recheck=180d` (versioned manual, edits rare; S042 uses
180d).

## Commands (exits)

- `curl -sSL -o check-ref-format.html -w …` → exit 0, http_code=200, size=37201.
- `curl -fsSL --compressed -A 'kagi-shokunin-round28/1.0 …'` → exit 0, size=7123; `cmp` with the
  identity fetch → exit 0 (identical); `sha256sum` both → `4f0c6bb3…`.
- `git check-ref-format <ref>` ×6 → exits 0,0,0,1,1,1 as listed in F4; `git --version` → 2.56.0.
- `grep -c -i 'git-scm' corpus/SOURCES.md` → 0; `grep -c '^| S[0-9]' corpus/SOURCES.md` → 43.
- `grep -rn 'leading zero' corpus/` at BASE → no match (exit 1).
- rendered-text-v1 locate of both quotes → True/True (exit 0).

## Not checked

- No lane gate, selftest or `release-clock.py` run; C1/C2 code untouched and unmeasured here.
- Fleet `sources-census.sh` not run: W04 attribution is from `.ufo/waves/round-28/census-start.txt`
  (exit 0, 11 W04) and my own URL grep.
- Hosting-side tag rules (e.g. GitHub's own validation) and GitHub's documentation on release-name
  defaults; semver.org §2 not opened.
- git other than 2.56.0; the versioned `/docs/git-check-ref-format/2.x` mirrors.
- No tools installed or upgraded.
