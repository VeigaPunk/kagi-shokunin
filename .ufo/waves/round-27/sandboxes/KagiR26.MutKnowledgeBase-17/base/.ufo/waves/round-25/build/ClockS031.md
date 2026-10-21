# ClockS031 — C3 per-row release clock for S031 (HTML comment syntax)

Seat KagiR25.ClockS031-2 · lane BASE 4587c61a348e4528717404a68912c373f3ef4d03 (lane HEAD equal) · sandbox /fast/scratch/kagi-r25/ClockS031-2 (clone --no-hardlinks, checkout BASE; runs under `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`) · no production edits · no installs or upgrades · no gate verify/cells · no account, vault, CDP, op or credential access.

## Verdict
- Clock: **rendered-quote** (case b). Verdict: **not-fired**: quote located, count=1.
- Teaches **still holds**: the live §13.1.6 still bars a leading `>` or `->` and the substrings `<!--`, `-->`, `--!>`, but a mid-text `>` stays legal; the tag-only leak it bounds still selftests.
- Row defect: S031 anchor says "no revision displayed". The live page shows "Living Standard — Last Updated 20 October 2026" (raw line 16). The committed capture has the same raw sha256, so the label was there at capture too.

## Release identity: (b), not (a)
S031 is the WHATWG HTML Standard, a living standard with no version label. Maintainer routes checked (unauthenticated, no cookies):

| route | HTTP | sha256 (body) | result |
|---|---|---|---|
| github.com/whatwg/html/releases.atom | 200 (496 B) | a4b314fb799c83163ed4d11d5b42d47775e831e6e397c4abcc4cf06aa41935df | 0 `<entry>`; `<updated>2026-10-21T10:39:24Z` |
| github.com/whatwg/html/releases | 200 (28240 B) | 774ae2e39ac9acbcefa63994e7d5aa6ce4dce1497af30e69cc63ab50366a0791 | empty state, raw line 494 |
| github.com/whatwg/html/tags | 200 (27818 B) | 1ad0c957e8ad493bae5875b36b16e82e440a9cdd3f79e2dbd53e7ae03e9be03c | same empty Releases view, raw line 469 |
| api.github.com/repos/whatwg/html/releases/latest | 404 | d9e37600354c1839f6b22cebde497e9d14750d2401a06c9a51b1619baf991613 | `{"message":"Not Found"}` |

- Commit feed rejected as a clock: github.com/whatwg/html/commits/main.atom (200, 27284 B, sha256 251b3ee71ae5fe15b622033ff73f9f6a19d394060c8faebce56d9f0f370da7a1). Its 20 newest entries (2026-10-05 to 2026-10-20) fall on 10 distinct UTC days. These are per-edit commits, not releases.
- Flip condition: any entry in releases.atom. A new round would then have to re-bind S031 to a feed clock, recorded as fired and re-verified, never silently re-pinned.

## Fetch evidence (S031 URL)
- `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -D S031.headers -o S031-live.html -w 'http_code=%{http_code} size_download=%{size_download}' https://html.spec.whatwg.org/multipage/syntax.html` → `http_code=200 size_download=15070` (wire), curl_exit=0.
- Decoded body: sha256 04b65bf0b4b5f3bb3815999ab499af980fa09b8832f02c1686c544ab8e79a52d, 89196 bytes. Identical to source-fetches.tsv S031 cols 10–11.
- Headers: `date: Wed, 21 Oct 2026 10:37:41 GMT`; `last-modified: Tue, 20 Oct 2026 12:58:33 GMT`; `etag: W/"6ad76579-15c6c"`.

## rendered-text-v1 (declared in its header; script sha256 7d6bfe81…, identical in lane and sandbox)
- `digest S031-live.html` → `raw_sha256=04b65bf0… bytes=89196 normalized_sha256=f8974683… normalized_bytes=31992`, exit 0. The normalized digest equals committed col 15 (f89746831eae2fbc13a24f8a59565fd23a31e8ec1653e30a0bdc00c2b7f046c8).
- `locate S031-live.html <quote read from source-fetches.tsv col 13>` → `RENDERED_TEXT_V1_LOCATE: count=1`, exit 0.
- Negative control `locate … 'The text is forbidden to end with the string " <! "'` → count=0, exit 1.
- `--selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exit 0; case comment-gt ok.

## Teaches check (live §13.1.6, normalized; raw lines 883–892)
> "…text must not start with the string " > ", nor start with the string " -> ", nor contain the strings " <!-- ", " --> ", or " --!> ", nor end with the string " <!- ". … The text is allowed to end with the string " <! ", as in <!--My favorite operators are > and <!--> ."

- A `>` in the middle of comment text stays legal, so the teaches ("may contain `>`") holds. The leak mechanism is unchanged: `a<!-- x > y -->b` → `a y -->b` (selftest comment-gt).
- Optional precision for the row: "may contain `>` (not at the start)".

## Row corrections (proposed; lane files are read-only for me)
1. S031 anchor: replace "no revision displayed" with "§13.1.6 Comments (#syntax-comments); Living Standard, Last Updated 20 October 2026, as served 2026-10-21". This matches the S030 anchor pattern.
2. corpus/lessons/round-24.md:4 says "reopen … when a version route changes". That cannot fire for S031, since no version route exists. The rendered-quote binding is its observable clock.

## Proposed corpus/release-clocks.tsv (tab-separated)
```
id	clock	feed_url	anchored_version	observed_version	observed_at	verdict
S031	rendered-quote	https://html.spec.whatwg.org/multipage/syntax.html	unversioned	unversioned;last_updated=2026-10-20;quote_count=1;normalized_sha256=f89746831eae2fbc13a24f8a59565fd23a31e8ec1653e30a0bdc00c2b7f046c8	2026-10-21	not-fired
```
- `anchored_version=unversioned`: the row names no release. "Last Updated" is recorded in observed_version only; it moves per edit, so it is not a fire condition.
- The quote is not duplicated in the TSV. release-clock.py should read source-fetches.tsv col 13 (16 columns verified; `locate` count=1 on that exact cell).

## SOURCES-row-ready lines (feeds opened)
S033, proposed for admission (evidence for the (b) decision):
`| S033 | WHATWG HTML releases — https://github.com/whatwg/html/releases.atom | feed | A | Release identity of the WHATWG HTML Standard: none published; S031 binds to rendered-quote | Atom feed updated 2026-10-21T10:39:24Z with zero entries; releases page empty state; opened 2026-10-21 | No release entry exists, so S031 uses the rendered-quote clock. Quote: “There aren’t any releases here” (releases page empty-state heading, raw line 494). | mined | 2026-10-21 | on-release | corpus/release-clocks.tsv |`

S034, receipt only (recommend not admitting; no clock binds it):
`| S034 | WHATWG HTML commit history — https://github.com/whatwg/html/commits/main.atom | feed | A | Commit activity of the HTML source; not a release identity | Atom “Recent Commits to html:main”, 20 newest entries, newest updated 2026-10-20T12:57:52Z, 10 distinct UTC days; opened 2026-10-21 | Commits move per edit, so they cannot be a release clock. Quote: “Editorial: fix miscellaneous typos in source” (newest entry title). | mined | 2026-10-21 | on-release | — |`

If either is admitted, it also needs a source-fetches.tsv row carrying the sha256 values above.

## API receipts (not feeds)
- `api.github.com/repos/whatwg/html/commits?per_page=1` → 200, sha256 89ff91e031e3564d83adf2ad1f6b092460dfcb4417e4e0a23364b61a4da41837, newest committer 2026-10-20T12:57:52Z.
- `…/tags?per_page=1` and `…/commits?per_page=30` → HTTP 403 rate limit. **UNRUN** through the API: the unauthenticated quota was exhausted. The HTML/Atom routes above replaced them.

## Residual unknowns / UNRUN
- rendered-quote tests that the sentence is still present, not the grammar. A grammar change that keeps the note would not fire it. No parser-level check was run.
- A markup change that stops the quote locating fires the clock. Treat that as re-verify, never re-pin.
- Digests are volatile (decoded-http-body-volatile-v1). Today's equality is a point attestation, not a stability guarantee.
- release-clock.py and release-clocks.tsv do not exist in the lane yet. The TSV line is **UNRUN** against that checker.
- Installs: none. No tool was installed, upgraded or removed.
