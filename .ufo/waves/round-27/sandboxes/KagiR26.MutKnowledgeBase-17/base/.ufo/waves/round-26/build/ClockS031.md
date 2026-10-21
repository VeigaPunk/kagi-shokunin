# ClockS031 — round 26 C1 freshness re-open of S031 (HTML Standard §13.1.6 Comments)

Seat KagiR26.ClockS031 · observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD` in production; worktree has only untracked `.ufo/waves/round-26/` and `plans/round-26.md`) · production read-only · no registry/production writes · no installs or upgrades · no build/lint/test/selftest/gate runs · only public URL fetched: the S031 URL.

## Bounded result
- **Clock (declared):** `corpus/release-clocks.tsv:28` — `S031 rendered-quote - - - - 2026-10-21 quote-located` with the note "living standard; whatwg/html publishes no releases". There is no feed clock for S031.
- **This round's observation:** the clock is **not fired**. The declared quote is located `count=1` under `rendered-text-v1`. The decoded body is **byte-identical** to the round-24 capture (`corpus/source-fetches.tsv:74`): same raw sha256 and size, and the same normalized sha256.
- **Teaching (`corpus/SOURCES.md:37`, "HTML comment data may contain `>`"):** this **still holds**, with the placement qualification below. Nothing in the source has drifted.
- **Python 3.15.1 / S027 / S028:** **not applicable to S031.** S031 is the WHATWG HTML living standard, with no Python dependency. The Python 3.15.1-versus-3.15.0 comparison is out of this row's scope, and I did not fetch any Python documentation.
- **Round-25 receipt:** preserved. I did not edit `.ufo/waves/round-25/build/ClockS031.md` or `.ufo/waves/round-25/falsify/FClockS031.md`. This round's observation agrees with both reports.

## Fetch (declared profile `curl-fsSL-compressed-v1`)
Command (cwd `/home/vgpnk/Projects/shokunin/kagi-shokunin`, D=`.ufo/waves/round-26/build/ClockS031-evidence`):
`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -D $D/headers.txt -o $D/syntax.html -w 'final_url=%{url_effective} http=%{http_code} size_download=%{size_download} content_type=%{content_type}\n' https://html.spec.whatwg.org/multipage/syntax.html`

Observed output:
- `final_url=https://html.spec.whatwg.org/multipage/syntax.html http=200 size_download=15070 content_type=text/html; charset=utf-8` and curl exit 0. Access time `2026-10-21T13:36:51Z` (`$D/fetched-at.txt`).
- Headers (`$D/headers.txt`): `HTTP/2 200`, `date: Wed, 21 Oct 2026 13:36:51 GMT`, `last-modified: Tue, 20 Oct 2026 12:58:33 GMT`, `etag: W/"6ad76579-15c6c"`, `content-encoding: gzip`.
- Decoded body: `sha256sum` gives `04b65bf0b4b5f3bb3815999ab499af980fa09b8832f02c1686c544ab8e79a52d`, and `wc -c` gives `89196`. Both equal `source-fetches.tsv:74` columns 10–11.
- ETag check: `0x6ad76579`=1792501113, which is `Tue 20 Oct 2026 12:58:33 PM UTC` (equal to Last-Modified). `0x15c6c`=89196, which equals the decoded byte count. [INFERENCE] The served file has not changed since 2026-10-20 12:58:33Z, so the round-24, round-25 (10:37:41Z and 12:10:19Z) and round-26 captures are all the same deployment.
- Row identity: `printf 'S031\tmined\thttps://html.spec.whatwg.org/multipage/syntax.html\n' | sha256sum` gives `9f75df3da25f56d105b4b2504f28a4360c94cdaa9bd345ea0a48c17898f1dc11`, which equals `source-fetches.tsv:74` column 3.

## Normalizer (read-only use of the committed `corpus/rendered-text-v1.py` on the local capture)
- `python3 corpus/rendered-text-v1.py digest $D/syntax.html` gives `RENDERED_TEXT_V1: raw_sha256=04b65bf0…a52d bytes=89196 normalized_sha256=f89746831eae2fbc13a24f8a59565fd23a31e8ec1653e30a0bdc00c2b7f046c8 normalized_bytes=31992`. The normalized sha256 equals `source-fetches.tsv:74` column 15.
- `python3 corpus/rendered-text-v1.py locate $D/syntax.html 'The text is allowed to end with the string " <! ", as in <!--My favorite operators are > and <!--> .'` gives `RENDERED_TEXT_V1_LOCATE: count=1`, with exit 0.
- Volatile caveat (`decoded-http-body-volatile-v1`): this equality is a point attestation only, not a stability pin.

## Source anchors (raw lines of `$D/syntax.html`)
- Line 16: `Living Standard — Last Updated <span class=pubdate>20 October 2026</span>`.
- Line 880: `<h4 id=comments><span class=secno>13.1.6</span> Comments`. Line 883 is `<dfn id=syntax-comments>Comments</dfn> must have the following format`.
- Lines 885–887 (normative list), located quote (≤25 words): "the text must not start with the string ">", nor start with the string "->", nor contain the strings "<!--", "-->", or "--!>"".
- Lines 890–892 (`<p class=note>`), located quote, 22 whitespace tokens in rendered form: "The text is allowed to end with the string " <! ", as in <!--My favorite operators are > and <!--> ."

## Teaching: still holds, qualified
- **Unchanged teaching:** an interior `>` is legal comment text. The normative list forbids only a *leading* `>` or `->`, and the note's example puts `>` in the middle of the text. So the bound the row records still applies: v1's tag-only rule (`rendered-text-v1.py` step 3, with no comment pass) can leak the tail of a comment.
- **Qualification (carried from round 25, still unapplied at BASE):** the teaching should read "may contain `>` (not as the first character, nor as part of `->`, `-->` or `--!>`)". The current wording "may contain `>`" is true but does not mention the leading-position ban.

## Counterexamples and actionable findings
1. **Calibration, new this round:** the registered quote comes from a **non-normative note** (`<p class=note>`, line 890), not the normative format list. The tier-A teaching is still supported, but only because the normative list at lines 885–887 permits an interior `>`. The row should cite the normative list as its normative anchor. Today the quote is the only located evidence, and it is non-normative.
2. **Anchor wording, carried over and still present at BASE:** `SOURCES.md:37` says "living standard as served 2026-10-21, no revision displayed", but line 16 shows "Last Updated 20 October 2026". This is a displayed update date, not a revision identifier. Round 25 flagged it in both `ClockS031.md` (proposed correction 1) and `FClockS031.md` ("anchor ambiguity"), and BASE has not applied a fix. Fixing it would be a new superseding row or note for L1, not a rewrite of the round-25 receipts.
3. **Anchor id precision:** the section heading id is `#comments` (line 880). The row's `#syntax-comments` is the `<dfn>` id inside that section (line 883). Both resolve, but the row cites the definition id as the section id.
4. **Clock limitation (not drift):** `rendered-quote` checks only that the note sentence is present. A change to the normative restriction list (lines 885–887) that leaves the note intact would not fire it. Because the declared digest representation is volatile, there is no grammar-level drift pin.

## Feed limitation (not re-observed this round)
The note "whatwg/html publishes no releases" rests on S038 (`SOURCES.md:45`, rejected; empty `releases.atom`) and on two round-25 observations: entry count 0 at `2026-10-21T10:39:24Z` (`round-25/build/ClockS031.md`) and at `feed_updated=2026-10-21T12:10:18Z` (`round-25/falsify/FClockS031.md`). I did **not** re-fetch `releases.atom` this round, because the fetch scope was S031's URL only, so the no-release rationale is **UNRUN for round 26**.

## Inspected scope and UNRUN
- Inspected: `corpus/SOURCES.md:37,45,56`, `corpus/release-clocks.tsv:28`, `corpus/source-fetches.tsv:6-30,74`, the `corpus/rendered-text-v1.py` header and functions, `plans/round-26.md:7`, `.ufo/waves/round-25/{build,falsify}/*ClockS031.md`, and the live §13.1.6 raw lines 16 and 880–892.
- UNRUN: `rendered-text-v1.py --selftest`, `release-clock.py`, `sources-census.sh`, any gate, the `releases.atom` and GitHub API routes, Python documentation, and any HTML parser or browser conformance check.
- Artifacts: `.ufo/waves/round-26/build/ClockS031-evidence/{syntax.html,headers.txt,fetched-at.txt}`.
- Installs: none.
