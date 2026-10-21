# SourceS002: S002 source-bound provenance audit

Seat SourceS002 (scout, leaf), wave `kagi-r23-parent-build`. Axes: calibration, freshness, operability. Read-only; this file is the only write. Window 2026-10-21T03:40–03:59Z. This is advisory, not admission.

## 1. Observed revision

- Base `HEAD` = `d218603b74099ddca0bd8f869516fc41db0979bf`. In this commit S002 is `corpus/SOURCES.md:8`. Its line sha256 `41b6308840538d24f9b876d79744a7ec5d9259ec66320a1044632d73e12d9a78` is identical in three places: HEAD, `.ufo/waves/round-22/frozen/before/corpus/SOURCES.md:8` and the live worktree.
- HEAD `corpus/SOURCES.md` is `a5e1c13e…` (118 lines, 23 rows). The used-by entry `corpus/knowledge/onepassword-machine-credentials.md` (`8380b359…`) and `corpus/claim-ledger.tsv` (`e6806968…`) are the same live as at HEAD.
- The live worktree changed during the audit. These are L1's uncommitted integration edits, so every live citation below has a time attached.
  - SOURCES.md went from `50dfd6c8…` (25 rows) to `06dde644…` (26 rows, S024–S026).
  - New or changed files: `plans/round-23.md` (`cb1287ba…` at 03:58Z), `corpus/source-fetches.tsv` (`ccc9ae6e…`), `corpus/lessons/round-23.md` (`d5520988…`), `corpus/closure-dispositions.json` and `corpus/sources-census.sh` (`80966e20…` at 03:58Z).
- Supersession: the live `supersedes` targets are S006, S007, S012, S013, S014 and S016. **No row supersedes S002.** It is active, mined and unsuperseded.

## 2. Opens

All were public GETs. Every one succeeded and none was skipped.

| # | target | UTC | observation |
|---|---|---|---|
| O1 | `https://www.1password.dev/connect` | 03:42:56 (`Date`) | 200, 0 redirects, `text/html`. Decoded body 1,186,855 B, sha256 `9b5dc190d03d118e2e956a83e157477a6d88cf568aeb9179c0c29f717ac4a975`. Seven decoded GETs returned identical bytes: `--compressed` ×2, a browser UA, `/connect/`, `Accept-Encoding: identity`, and the round-23 profile `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'` ×2 at 03:55Z. Headers: `ETag W/"rl7zve6lflpfod"`, `x-mintlify-client-version 0.0.3908`, `cf-cache-status HIT`, `age 10730`. Wire bytes depend on the encoding: gzip `2874e15c…`, br `526f3d13…` |
| O2 | `https://www.1password.dev/connect.md`, advertised by `<link rel="alternate" type="text/markdown" href="/connect.md"/>` | 03:43:43 | 200 `text/markdown`, 3,792 B, `ee60a0dfb3d41e15d52e8229b7b7a00a8b9dabfed181c0a5acb6057f1c60fe48` on both fetches. `last-modified` is the `Date` plus 1 s, so it is not a revision stamp |
| O3 | the quoted image's `src`, `mintcdn.com/…/connect-diagram.png` | ~03:50 | 200 PNG, 886×971, 17,127 B, `e5febee165a6e880be4256bbb81a47e5aef8e2332d582852d7d961a2a51da9b2`. I viewed it |
| O4 | Wayback CDX for `/connect` and `/connect.md` | ~03:46 | `/connect` has no capture between 2026-10-15 and 10-21; the last is 2026-10-10. `/connect.md` has one capture, 2026-06-07T17:51:30Z |
| O5 | `id_` replay of that `.md` capture | ~03:47 | 200, 7,302 B, `384cfff8bdf91d7ef492f48a6829356369e56bdba67453c259a06830dbf9b0de` |

None of the opens recovered the 2026-10-19 bytes.

## 3. Row-field verdicts (HEAD `corpus/SOURCES.md:8`)

The public quote is the S002 page's diagram image alt text, under H1 "1Password Connect". The page displays no date; URL as in O1; accessed 2026-10-21:

> “The Connect server is part of your environment, and communicates to Your Apps using access tokens and a REST API.” (20 words, computed)

The introduction carries the REST half: “private REST API” (`.md` line 7). That brings the S002 words quoted in this report to 23.

| field | verdict | basis |
|---|---|---|
| URL, kind `docs` | supported | O1: 200 with no redirect. This is vendor documentation for its own product |
| tier A (QA1 "for that scope", `corpus/QUALITY.md:20`) | supported | The scope is the documented app→server access path. The page is not community or marketing material |
| scope | supported | Introduction plus caption. There is no token lifecycle, scope, rotation, status or plan text: `Business`/`Enterprise` occur 0 times; `Beta`/`Early Access` appear only in a CSS comment; there are 0 badge elements |
| teaches | **supported (current)** | The quote is verbatim at `.md:21` (image-alt syntax). In the HTML it occurs 3 times: one `img alt=` attribute and two serialized JSX `OptimizedImage alt:` props inside `Frame`. The 2026-06-07 `.md` capture has the same sentence (line 73, `<img alt>` in `<Frame>`), so the support has held since at least June 2026 |
| anchor "Connect-server diagram caption" | supported, imprecise | There is no `<figcaption>` and no Frame caption prop. The sentence is **alt text only**, with 0 occurrences in rendered text. **New:** the rendered diagram (O3) visibly puts REST API on the Connect Server box and Access Tokens on the arrow between the server and Your Apps, inside Your Environment. This closes unknown (3) at `.ufo/waves/round-22/build/Entry15.md:229`. It also lifts the evidence above that file's "diagram-metadata strength" (:91-93): the teaching is rendered in pixels; only the exact sentence is metadata |
| "no displayed version/date" | supported | Nothing is displayed. Machine fields `dateModified`/`lastModified` = `2026-10-19T21:23:28.086Z` (5 occurrences; `gitLastModified $undefined`) exist but are neither displayed nor editorial dates (§4) |
| `Fetch sha256: 68017d4c…` | **historical; representation unrecorded; unreproducible** | It matches none of 10 derivations: decoded HTML, `.md`, `.md` without the trailing NL, `.md` from the H1, `.md` with CRLF, rendered text, rendered text plus NL, gzip wire, br wire, and the 2026-06-07 `.md` capture. It entered in commit `c41af82` at 2026-10-19T22:29:35Z, 66 min after the served stamp. The fetch time was never recorded, so which build it hashed is UNKNOWN |
| status `mined`, opened 2026-10-19, recheck 90d | supported | The row is consumed (§5). Recheck falls due 2027-01-17 |
| used-by | supported | §5 |

## 4. Four separate layers for S002

| layer | finding |
|---|---|
| Historical bytes | `68017d4c…` is a 2026-10-19 point observation with no documented representation. No capture exists from 10-11 to 10-21, so it cannot be adjudicated. Keep it as written. Do not label it STALE or DRIFT |
| Current semantic support | Supported. On 2026-10-21 the quote was located in the `.md` and in raw HTML, the introduction's REST sentence is in the rendered text, and the diagram labels are visible. The support has been stable across 2026-06-07, the two round-22 seats on 10-20, and today |
| Transport and raw-HTML volatility | **Measured, not hypothesized.** Decoded HTML was `9e00e86d…` (1,186,550 B) at 2026-10-20T21:34Z and 22:16Z (`build/Source02.md`, `falsify/ReopenSource02.md`). It was `9b5dc190…` (1,186,855 B) at 03:42Z, at most 5 h 26 min later, from the same workstation. Over that span the `.md` (`ee60a0df…`) and `dateModified` (`2026-10-19T21:23:28.086Z`) did not change, while the ETag went `ewomuil5oqpffw`→`rl7zve6lflpfod` and the client went `0.0.3902`→`0.0.3908`. So round-22's model, where the stamp advances with each build, is incomplete: raw HTML also moves without a stamp change. [INFERENCE] the extra 305 B is platform chrome. I could not byte-diff it because the 10-20 bytes were not kept, and CDN edge variance is not excluded. The `.md` is no content pin either: between 2026-06-07 (MDX source with JSX, 7,302 B) and 2026-10-20 (rendered markdown, 3,792 B, adding "Related topics") its serializer changed while the prose stayed the same. Wire bytes vary with `Content-Encoding` |
| Deployed-product proof | **None.** S002 is documentation plus an illustration. It shows no token format, scoping or enforcement, and no behavior of a deployed server. No Connect server, API, CLI or account was exercised, per the contract |

## 5. Used-by pointer chain

I followed the chain locally and ran no gate.

- `SOURCES.md:8` used-by → `corpus/knowledge/onepassword-machine-credentials.md`.
- That entry's `source:` line (2) cites S002 with the row's own anchor. Item 3 (line 14) cites `[S002, S003]`.
- The round-22 appends (lines 74 and 82-86) already narrow S002 to the app access-token/REST boundary and mark the custody-boundary conclusion as [INFERENCE]. I carried these over rather than redoing them.
- `Reverify: R21-02` (line 5) → `corpus/claim-ledger.tsv:52` (`bash corpus/sources-census.sh`, a count-only CLEAN line).
- The HEAD census handshake (`src_field` :121, loop :184-232) is structural only, with 0 `sha256`/`digest` references. R21-02 would therefore stay CLEAN even if S002's quote, anchor or URL target were wrong.

**Gap:** the entry's `## Falsifier` (lines 28-30) has no clause for S002. Its only Connect condition, "setup no longer separates deployment credentials…", is S003 content. A C1 checker that follows pointers finds no falsifier bound to S002.

## 6. C2 expectations for S002

State of L1's live contract at 03:58Z:
- `plans/round-23.md:25-32` classifies the legacy in-row pins S001–S016 as historical and counts "10 active declared-provenance rows". S002 is covered by its historical pin.
- In the census coverage loop (`for fid in "${!ST[@]}"`), an in-row 64-hex value triggers `continue`. The CLEAN printf has no counter that separates active from historical.
- S002 is missing from the lesson's list of confirmed-unreproducible legacy pins (S008/S012/S013/S014/S016, `lessons/round-23.md:109-113`).

If L1 gives S002 an active row, these are the values. They are a point attestation only; L1 should re-fetch at integration and record its own.

| column | value |
|---|---|
| id / status | `S002` / `mined` |
| row_identity_sha256 | `7cbef2899a5311008aa3ac5ffc65c08ad6bdfec7f4ad1b4bcceabddc3e3c1547` (from `printf 'S002\tmined\thttps://www.1password.dev/connect\n'`) |
| url / final_url / http_status | `https://www.1password.dev/connect` / the same / `200` |
| request_profile / fetched | `curl-fsSL-compressed-v1` / `2026-10-21` |
| representation | `decoded-http-body-volatile-v1`. Daily chrome is observed (§4); there is no per-response token (7 identical GETs within the hour) |
| sha256 / bytes / revision | `9b5dc190d03d118e2e956a83e157477a6d88cf568aeb9179c0c29f717ac4a975` / `1186855` / `-` |
| quote | The 20-word sentence in §3. Do not substitute the introduction, which lacks the token half |
| normalization / normalized_sha256 | `raw-literal-v1` / `-`. See §7: under `rendered-text-v1` the quote is not locatable |
| location | `Connect-server diagram image alt text (img alt, connect-diagram.png)`. Do not use the bare word "caption" |

Do not:
- pin wire bytes;
- treat `9e00e86d…` or `9b5dc190…` as an expected value (check 2 in round-22 `build/Source02.md` is now refuted);
- record the `.md` `last-modified` or `dateModified` as a revision date;
- put `/connect.md` in `final_url`. The profile fetches the registered URL and the column means `%{url_effective}`. Using `.md` would need a new declared representation.

## 7. One real contradiction: the C2 encoding cannot represent S002 consistently

These facts were measured on 2026-10-21:
- S002's teaching quote exists only as alt text in volatile HTML.
- My replica of `rendered-text-v1`, written from the TSV header prose (strip script/style, tags to a single space, unescape, collapse, trim, UTF-8), gives 2,362 B, `b82b2b2c…`.
- That text contains **0** copies of the quote and **0** occurrences of "access token". `raw-literal-v1` finds the quote 3 times.

The live contract offers two encodings for S002, and each one breaks a stated property:
- **`rendered-text-v1`** matches the lesson's quotation rule (`lessons/round-23.md:39-42`, "quotes are located under the declared rendered-text-v1 normalization"). But the quote is absent from that text, so the locator is false. The hermetic census never compares quotes with bytes, so this would be a false CLEAN.
- **`raw-literal-v1`** locates the quote, but the normalized digest is then `-`. The row has no "stable declared identity", which `source-fetches.tsv` (header lines 17-20) promises for `decoded-http-body-volatile-v1`. It is also exempt from same-URL raw agreement.

The census (`80966e20…`, lines 262 and 273-277) admits volatile plus raw-literal with no cross-check. The contract's volatile-identity property therefore fails silently for S002-shaped rows.

Fix, append-only and L1's choice:
- (a) Declare S002 as raw-literal and amend the volatile clause to say that a raw-literal row has point-only identity.
- (b) Add an alt-preserving normalization, a new convention that emits `img@alt` as text, so that a volatile row with alt-text quotes keeps a normalized digest.

In both cases, publish the normalizer as code, not prose. As it stands, normalized digests are not reproducible from the tree.

Secondary observations, not S002-unique:
- The CLEAN line cannot distinguish an active row from a historical-only one.
- `SUPERSEDED` is filled (census :243) but never read, so the Goal's "superseded" distinction is prose-only.

All three points were sent to `agent://KagiR23`. My first message, which framed the conflict at plan-text level, was corrected at 03:58Z after the plan update.

## 8. Synthetic minimal failing fixtures for L1

These are proposals and were not executed. Both are hermetic and use `example.invalid`.

- **F-S002-ALT** (false locator; this is the §7 contradiction):
  - Representation fixture body: `<h1>Two</h1><p>Apps use a private REST API.</p><img alt="Apps reach the server with access tokens and a REST API." src="d.png">`
  - Provenance row: S002 declared `decoded-http-body-volatile-v1` + `rendered-text-v1`, with the alt sentence as its quote and a 64-hex normalized digest.
  - Expected today, from static reading: SC_FETCH is CLEAN, because it checks shape, URL and identity only.
  - Required: a selftest located-quote check over the fixture body reports `quote-not-located normalization=rendered-text-v1`.
  - Paired control: the same row declared `raw-literal-v1` passes. A volatile row with raw-literal is then either flagged or explicitly marked point-only.
- **F-S002-LEGACY** (an active claim backed only by historical provenance):
  - Mutant: in the census selftest's clean root, append `` Fetch sha256: `eeee…e` `` (64 × `e`) to fixture S002's teaches cell, and delete its `source-fetches.tsv` line.
  - Expected today: exit 0, with a CLEAN line byte-identical to the control's.
  - Required: the output differs, through `fetch_active`/`fetch_historical` counters or an explicit legacy-only status for a row cited by a sourced entry.

## 9. Recommendations

All are append-only and owned by L1.

1. Resolve §7 with (a) or (b), and publish the rendered-text-v1 normalizer as code.
2. Add S002 to the lesson's list of confirmed-unreproducible legacy pins, using the 10 derivations in §3.
3. Append a falsifier to the entry: S002 is falsified if neither the Connect page's diagram alt text nor its rendered labels place access tokens and a REST API between Your Apps and the Connect server.
4. Keep row :8 byte-identical, including `68017d4c…`, `opened 2026-10-19` and `mined`. Any new S002 record should say "diagram image alt text plus rendered diagram labels".

## 10. Limits

- The HTML bytes from 2026-10-19 and 2026-10-20 are gone, so the delta has no byte diff and its cause is [INFERENCE].
- "Rendered text" means a regex replica of a normalization defined only in prose, not a browser render. The diagram was checked from its PNG.
- Not opened: S003, `/connect/get-started`, `/connect/manage-connect`, the API reference and the SDK pages. No other source row was audited.
- No gate, census, selftest or repo script was run. Live integration files kept changing, and their line numbers are as of 03:56–03:58Z.
- The `.md` opens with a three-line vendor preamble addressed to agents. I treated it as data and did not follow it.
- Overlap: SourceS012, S016 and S022 raised the in-row-pin structure for their own rows. This report adds S002-specific measurements and the alt-text encoding conflict.
- Tools: none installed or updated. I used curl, sha256sum, the python3 standard library, and read-only `git show`/`git log`.

Report: .ufo/waves/round-23/parent-build/SourceS002.md
