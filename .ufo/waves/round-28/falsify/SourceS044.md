# SourceS044 — S044 registry row reopened against its page (round 28 falsify)

**Verdict: PASS.** `corpus/SOURCES.md:51` and its provenance row `corpus/source-fetches.tsv:87` reproduce against the live page and the retained capture; no falsifying scope overclaim (one embedded inference flagged).

Candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`, exported read-only to `.ufo/waves/round-28/sandboxes/SourceS044/cand`; the two cited lines there are byte-identical to the lane checkout (sha256 `db23ab04…` for SOURCES.md:51, `10060033…` for source-fetches.tsv:87).

Qualifiers: status **mined** (registry and provenance agree), tier **A docs**, recheck **180d**, opened **2026-10-21**, used-by `corpus/lessons/round-28.md`. No **draft** qualifier: the page is the released Python 3.15.1 docs build, not an IPD; this round's draft row is S049, not S044.

## Observed page facts (commands, exits)

- **Fetch.** `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o stdtypes.profile.html https://docs.python.org/3/builtins/stdtypes.html` → exit 0; `HTTP/2 200`; `content-type: text/html`; `<title>Built-in Types — Python 3.15.1 documentation</title>`. The row's source label (section title + "Python built-in types") matches h2 + H1.
- **Redirect.** `curl -sS -D - https://docs.python.org/3/library/stdtypes.html` → exit 0; `HTTP/2 301`; `location: https://docs.python.org/3/builtins/stdtypes.html`. The anchor's "requested /3/library/stdtypes.html answers 301 here" is exact.
- **Section.** `#integer-string-conversion-length-limitation` exists (h2 "Integer string conversion length limitation") and says: "When an operation would exceed the limit, a ValueError is raised"; "This limit only applies to decimal or other non-power-of-two number bases. Hexadecimal, octal, and binary conversions are unlimited."; "PYTHONINTMAXSTRDIGITS=0 python3 to disable the limitation".
- **Registered quote** (11 ASCII words ≤25): "The default limit is 4300 digits as provided in sys.int_info.default_max_str_digits ." `python3 -I -B corpus/rendered-text-v1.py locate <body> '<quote>'` → `count=1`, exit 0, on both the live body and the retained capture.
- **Second Gate quote:** "The lowest limit that can be configured is 640 digits as provided in sys.int_info.str_digits_check_threshold ." → `count=1`, exit 0.
- **Disclaimer check.** The anchored section has zero hits for "leading zero", "canonical", "feed", "SemVer", so the row's "not a canonicality or feed rule" limitation matches the page.

## Identity, sha, bytes

- **Row identity:** `printf 'S044\tmined\t<url>\n' | sha256sum` → `5cb1b37e07b5025c2caa71b90ddffaf26cafa1cd1eba9d0590704450d45cbc55` = col 3 (`corpus/sources-census.sh:262-263`); exit 0.
- **Retained capture** `.ufo/waves/round-28/captures/S044.body`: raw `7dcb450d84d0176f7d7d996853d7be8b19b3e9a49479f67c5f8efc74627e1ff2`, **814482 bytes**, normalized `c6c84fedcf90996487ec8bd7d20ed025134db15a7495b22c04deac5cd97bd938` (197388) — equal to cols 10/11/15 (`sha256sum`, `stat`, `rendered-text-v1.py digest`; all exit 0).
- **Live refetch, declared UA:** raw `2fc068875253c9be2a1b45ce1c4eb8855760af1bd738841ad6e4ed7c7cbffd74`, **814482 bytes**, normalized `c7e7f151e4cf7e4ac3bf99fbd5988c92fd974104bf3770c7d120ac0beeee373d`. `cmp -l` vs the capture: 3 differing bytes near offset 814230, all inside the Sphinx footer `Last updated on Oct 21, 2026 (13:02 UTC)` vs `(17:41 UTC)`; nothing else differs. An earlier default-UA fetch gave raw `f5bacc800b0ab6145c0e8f049e124bcc15e72bd691a8c1db943f86eb7884d3a2`, normalized `c01d95271174ad53edd0f33beea9ea0a0790bb703933140b88787fad728fe0b0` (same 814482 bytes, footer 17:22 UTC).
- **Contract, not defect:** `decoded-http-body-volatile-v1` (`corpus/source-fetches.tsv:19-21`) calls the normalized digest "still chrome-sensitive, never a drift pin. No cross-capture equality is enforced." The concrete counterexample to a reproducible-digest reading is the footer minute alone; the quote still locates once on the live body.

## Scope overclaim

- **None material.** Every factual clause maps to the page: default 4300, ValueError above it, lowest configurable 640, disable-able, decimal / non-power-of-two bases only, CPython only.
- **[INFERENCE]** The scope clause "why a release clock must bound version components lexically before any int()" (`corpus/SOURCES.md:51`) and the teaches' "so a version component must be rejected by length before conversion" are the lane's design rule, not page text: the page states the ValueError, and catching ValueError would also avoid a traceback. It is offered as rationale and the same cell disclaims canonicality/feed rules, so it is not a falsifying overclaim; L1 should not restate "lexically before any int()" as something this page says.

## Census (sandbox copy only)

- `git archive 62a33b1 | tar -x -C .ufo/waves/round-28/sandboxes/SourceS044/cand` → exit 0; `bash corpus/sources-census.sh` in that copy → exit 0, `SOURCES_CENSUS: CLEAN (rows=49 A=47 B=0 C=2 queued=1 mined=45 rejected=3 entries_sourced=4 legacy=21 captures=49 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, no `S044` finding. Those checks (`corpus/sources-census.sh:253,266,277-285`) are shape checks, not digest verification; the digest comparison above is manual.

## Not checked

- Other rows (S045–S049), C1/C2 fixtures and predicates; `/3/` under locales or UAs beyond the declared UA; permanence of the 301 (one observation); 3.14/3.16 page variants; whether `VERSION_COMPONENT_MAX_DIGITS=18` is the right lane bound (out of item scope).
- Prior scout advice (`.ufo/waves/round-28/build/ScribeSourcesRows.md`, `SrcPythonIntBuiltin.md`) was not used as verification; all claims above come from the live page and the retained capture.
- No production edits; no tool installs.
