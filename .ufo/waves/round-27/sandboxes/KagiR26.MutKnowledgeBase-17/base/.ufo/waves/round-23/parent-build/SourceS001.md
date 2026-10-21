# SourceS001 — S001 source-bound provenance audit (round 23, parent-build)

Axes: calibration · freshness · operability. This is an advisory report, not an admission.
Scope: row S001, its `used-by` entry, and the S001 values for planned C2. I did not audit any other
source row; I only scanned the registry for rows that supersede S001.

## Observed revision

- Repository `/home/vgpnk/Projects/shokunin/kagi-shokunin`. HEAD is `d218603b74099ddca0bd8f869516fc41db0979bf`, the same base named in `plans/round-23.md:3`.
  The working tree at read time had only two untracked paths, `.ufo/waves/round-23/` and `plans/round-23.md`. No tracked file was modified.
- `corpus/SOURCES.md:7` (S001): the line's sha256 including its trailing LF is `052aa61b03d95d4723c63abdb3f82b0e3e20af72cdd7f72b6950483d2cb06a80`.
  It matches the hash recorded in `.ufo/waves/round-22/falsify/ReopenSource01.md:49-50`. The line is also string-equal to
  `.ufo/waves/round-22/frozen/before/corpus/SOURCES.md:7`, so the row has not changed since the round-22 freeze.
- Git disclosure: I ran `git rev-parse HEAD` and `git status --porcelain=v1` once each, intending read-only use. `git status` can
  refresh the index stat cache as a side effect. I ran no other Git or JJ command.

## Opens on 2026-10-21 (every request returned HTTP 200; none failed)

| # | request | observed |
|---|---|---|
| 1 | Canonical HTML `https://www.1password.dev/cli/secrets-scripts` fetched with `curl -sSL`, `--compressed`, user agents curl and Mozilla, explicit `Accept: text/html`, and Python urllib (more than 5 fetches) | 1,228,087 decoded bytes, sha256 `e72ab5f3f85e238bc109a1737161eec8425a016f003b7c84be09990d62cf4e0b`, identical on every fetch. HTTP `Date` 03:42:32Z and 03:44:19Z. ETag `W/"14087qndwbgqbh5"`. `cf-cache-status: HIT`, age 10704 s. `x-served-version: dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP` |
| 2 | `<canonical>.md` fetched 3 times, and the canonical URL with `Accept: text/markdown` | 7,187 bytes, `text/markdown; charset=utf-8`, sha256 `43b9a0c7cbfe76e17b76e003497e8303874731cf12c2d9b175e77fe81675e95a` every time |
| 3 | Wayback CDX for the HTML URL (2026-09-01 to 2026-10-21) and for the `.md` URL | HTML: one capture, `20260908142005`. `.md`: no captures |
| 4 | Wayback `20260908142005id_` | gzip body. Decoded: 1,200,164 bytes, sha256 `94553c66b2b80aaad04fc6c0badea62b8f8151fd2517094b2b0063d8466a1b3d`, JSON-LD `dateModified` 2026-09-04T17:57:16.231Z, anchored sentence present |
| 5 | Feature-qualifier pages (not registry rows): `/environments.md`, `/cli/secrets-environment-variables.md`, and the H1 of the `/environments` HTML | The H1 of `/environments` and of S001 carries no beta or preview badge. The only "(beta)" on `/environments` belongs to a linked AWS sync sub-feature |

Measurement note: one early pipeline (`curl … | tee >(sha256sum) | wc -c`) printed 1,228,155. The extra 68 bytes
were the `sha256sum` output line itself being counted by `wc`; this is not a page variant. Four direct variants all gave 1,228,087.

## Located public text (≤25 words)

- Heading: §Use `op run` to pass environment variables from a 1Password Environment
- Locator: <https://www.1password.dev/cli/secrets-scripts#use-op-run-to-pass-environment-variables-from-a-1password-environment>
- Date: the page displays no date; I opened it 2026-10-21T03:42Z.

> "runs the application or script in a subprocess with the environment variables stored in your 1Password Environment provisioned for the duration of the process." (24 words)

Location in the `.md`: the heading is line 35, the sentence is line 39, and the next `## ` heading is line 41. In the HTML there is exactly one
`<h2 id="use-op-run-to-pass-environment-variables-from-a-1password-environment">`.

## Row field verdicts

| field | row value | verdict | evidence |
|---|---|---|---|
| source/URL | Load secrets into scripts — canonical URL | SUPPORTED | H1 and `<title>` say "Load secrets into scripts"; the exact URL returns 200 |
| kind / tier | docs / A | SUPPORTED | This is the vendor's own developer documentation for its own CLI |
| scope | 1Password CLI process-lifetime Environment-variable delivery | SUPPORTED | The quote above; the claim is confined to the Environment section |
| anchor | §Use `op run`…; "no displayed version/date" | SUPPORTED, with a precision note | The heading text is verbatim. There is no visible date or "last updated". A machine-only JSON-LD `dateModified` (2026-10-19T21:23:28.252Z) exists but is not displayed |
| teaches and in-row quote | "Process-lifetime delivery"; in-row quote of 7 words | SUPPORTED | Verbatim, including the final period. It occurs once in the `.md` and twice in the HTML: once in the rendered `<span>` and once in the RSC/JSX payload |
| teaches: `Fetch sha256:` | `9f9d7283…c439` | HISTORICAL; does not reproduce | Differs from today's HTML (`e72ab5f3…`), today's `.md` (`43b9a0c7…`) and the archive capture (`94553c66…`). Round 22 also found it differed from that day's HTML (`24d1aecd…`) |
| status | mined | SUPPORTED, no change | The used-by file resolves and cites S001 |
| opened / recheck | 2026-10-19 / 90d | FRESH | Recheck due 2027-01-17. Nothing in today's text calls for an early reopen |
| used-by | `corpus/knowledge/onepassword-machine-credentials.md` | SUPPORTED | The file exists and its `source:` line (line 2) cites S001 |
| supersession | none | SUPPORTED | `supersedes` appears only in S019→S007, S020→S006, S022→S012 and S023→S013. Round-22 `Source01.md:100` proposed an S001 re-pin numbered "S022", but it never landed; the live S022 is the Vault JWT row |
| feature status | none stated | SUPPORTED (by absence) | The `.md` contains no beta, preview, version or "new" label, and neither S001's H1 nor `/environments`' H1 carries a badge. Absence of a label is not proof of general availability |

## Four separate kinds of evidence

1. **Historical bytes.** `9f9d7283…` is a single observation from 2026-10-19 of a representation that was never recorded
   (`onepassword-machine-credentials.md:77-79`; `corpus/lessons/round-22.md:105-107`). The bytes cannot be recovered:
   Wayback has no capture between 2026-09-08 and today. Keep the digest as history and never use it as a drift pin.
2. **Current semantic support.** The anchored sentence is present verbatim today in both the HTML and the `.md`, and in the
   2026-09-08 archive capture. So the teaching held at each point observed from 2026-09-08 to 2026-10-21. Content between those
   captures is unknown.
3. **Transport and raw-HTML volatility (new since round 22).**
   - What changed: the HTML went from 1,227,782 bytes, `24d1aecd…`, ETag `W/"i8hkm8rx5oqb8o"` (2026-10-20T21:34Z, `Source01.md:63`) to 1,228,087 bytes, `e72ab5f3…`, ETag `W/"14087qndwbgqbh5"` today.
   - What stayed the same over that interval:
     - JSON-LD `dateModified` (2026-10-19T21:23:28.252Z both times).
     - Next.js buildId `6ad68a298cdc29c1c7fdf7e9`. Round 22 recorded it on the S004 page; today it is on S001.
     - The `.md` bytes (`43b9a0c7…` on both days).
   - The HTML body embeds the deployment id `dpl_8AUWT8nFRmT7D3RgoEGEPVymfFQP` 1,227 times, in asset `?dpl=` query strings. Round 22 recorded
     `dpl_CTd5b4pFwfRrzK28Ja6L7zK5VbfH` for the same site at 2026-10-20T21:33:43Z (`Source04.md:12-15`).
   - [INFERENCE] A site redeploy changes every page's HTML bytes even when neither the content nor the stamp changes.
   - Unexplained: the +305-byte growth cannot come from swapping two deployment ids of equal length. The old bytes were not kept, so it cannot be diffed.
   - Gzip and brotli are a further transport layer; only decoded bytes are comparable.
4. **Deployed-product proof: none.**
   - The page documents what the vendor intends the CLI to do, and names no CLI version. It does not prove how any installed
     `op` behaves, how the janitor's path behaves, or how long a token lives.
   - `onepassword-machine-credentials.md:20` correctly keeps the local caller separate.
   - The janitor runs `op run --env-file`, which is the secret-reference method. The page's section for that method (`.md` lines 41–45)
     contains no duration sentence, so S001 cannot support a duration claim for that path. This is consistent with `ReopenSource01.md:39-42`.

## Following the used-by pointers locally

- `onepassword-machine-credentials.md:2`: the `source:` locator for S001 matches the row (anchor, no displayed date, opened 2026-10-19).
- `onepassword-machine-credentials.md:10`, item 1:
  - Sentence 1 is supported by the quote.
  - Sentence 2 cites `[S001, S004]` for "not the lifetime of the Service Account token". S001 supports only the first half (the delivered process environment); the token negative rests on absence.
  - Round-22 `Source01.md:53` proposed narrowing that citation, and `ReopenSource01.md:39-46` judged the calibration correct.
  - I did not re-adjudicate. It is carried forward unintegrated, low severity.
- `onepassword-machine-credentials.md:24` ("Does not establish"): supported. The S001 `.md` has no text about token lifetime. Its only token mentions are the Service Account
  recommendation (lines 11–13) and a shell-plugin sentence about personal tokens (line 87).
- The entry's `Reverify: R21-02` points to `corpus/claim-ledger.tsv:52`, the sources-census row, whose note says "no network/content validation".
  - The only executable obligation that touches S001 is therefore syntactic: the used-by / cite handshake.
  - Migrating R21-02's expected counts after C2 is that row owner's job.

## C2: S001 values for `corpus/source-fetches.tsv`

Recommended representation: the vendor Markdown, hashed over decoded bytes.

- `id`: S001
- `url`: `https://www.1password.dev/cli/secrets-scripts`. Must be byte-equal to the row URL: no `.md`, no fragment, no trailing slash.
- `representation`: `GET; Accept: text/markdown; response text/markdown; charset=utf-8; decoded`. The `<url>.md` request gave identical bytes today.
- `sha256` / `bytes`: `43b9a0c7cbfe76e17b76e003497e8303874731cf12c2d9b175e77fe81675e95a` / 7187.
  - Observed on 2026-10-20 (round 22) and again on 2026-10-21. L1 must record its own reopen, not copy these values.
- `quote`: the in-row 7-word quote. Exactly one occurrence in the file.
- `location`: heading line 35 (`## Use \`op run\` to pass environment variables from a 1Password Environment`) → quote at line 39, before the next `## ` at line 41.
  HTML fragment `#use-op-run-to-pass-environment-variables-from-a-1password-environment`.
- Legacy in-row `9f9d7283…`: record it as `historical`, representation `unrecorded`. It is not current provenance.
- Do not use any of these as a revision date:
  - the `.md` `Last-Modified` header, which equals response time (03:44:20Z);
  - the weak ETag;
  - JSON-LD `dateModified`, which stayed fixed while the bytes changed.

If L1 prefers HTML:

- Same URL, `Accept: text/html`, decoded: 1,228,087 bytes, `e72ab5f3…` as of today. Expect it to change at every deploy, since `dpl_…` appears 1,227 times.
- Match the heading by fragment id. The rendered h2 text starts with U+200B.
- The quote appears twice as a raw substring, so require it to sit inside the section after that h2 rather than requiring exactly one occurrence.

Matching rule for `SC_FETCH`:

- The same URL returns two different byte sets depending on `Accept`. So a URL plus a correctly shaped sha256 cannot identify the bytes.
- URL equality must be byte-equality with the registry URL.
- The request `Accept`, the response content-type and the decoding must each have their own required field.

## One real contradiction (C2, shown concretely by S001; also messaged to KagiR23)

`plans/round-23.md:20-31` conflicts with itself:

- The planned `SC_FETCH` passes on "in-row `Fetch sha256:` **or** a complete provenance row".
- The After condition is "provenance for all mined rows, missing = 0".
- The same item says `source-fetches.tsv` records "for every mined row … representation", and that "Digests are point attestations of the fetched representation".

S001 shows why this matters:

- S001 has an in-row digest whose representation was never recorded (`onepassword-machine-credentials.md:77-79`).
- That digest matches none of the tested representations: today's HTML, `.md` and archive capture, plus round 22's set.
- The in-row branch therefore counts S001 as provenanced, and `missing = 0` comes out falsely clean for S001.
  - [INFERENCE] The same branch covers the other 13 legacy mined rows that carry in-row digests; I did not audit them.

The plan's before-count is correct: `grep -c 'Fetch sha256:' corpus/SOURCES.md` = 16 (lines 7–22, S001–S016). Those 16 include queued S005 and rejected S008, so 14 are mined, and 7 mined rows (S017–S023) lack the field.

Fix: require a complete `source-fetches.tsv` row for every mined row. Treat an in-row `Fetch sha256:` as historical only, never enough
to pass `SC_FETCH` alone, and report it separately, e.g. `legacy_inrow=14` in the CLEAN line.

Minimal synthetic failing fixture (a proposal for `sources-census.sh --selftest`; I did not run it):

- **Mutant `fetch-inrow-only`:**
  - Setup: the base fixture plus one mined row `| S001 | T — https://example.test/a | docs | A | s | §H | Quote: “q q.” (§H). Fetch sha256: \`<64 lowercase hex>\`. | mined | 2026-01-01 | 90d | <fixture used-by entry> |`.
  - `source-fetches.tsv` has its header and no S001 row.
  - Expected: exit 1 with `SC_FETCH id=S001` (in-row digest only, no representation). The OR-branch as planned would print CLEAN; that is the false clean.
- **Control:** the same row plus a complete fetch row (byte-equal URL; representation `GET; Accept: text/markdown; text/markdown; decoded`; 64-hex sha256; byte count; quote ≤25 words; location). Expected: CLEAN.
- **Optional second mutant:** a fetch row whose URL is `https://example.test/a.md`. Expected: an `SC_FETCH` URL-mismatch finding.

## Claims that should stay rejected

- "S001's pin `9f9d7283…` still verifies" / "the source is unchanged": refuted, because no representation reproduces it.
- "An HTML digest change means a content change": refuted today. The digest changed while the anchored text and the `.md` bytes did not.
- "`dateModified` dates the served bytes": refuted today. The stamp stayed fixed while the bytes changed.
- "S001 proves how the deployed CLI, or the janitor's `--env-file` path, behaves": unsupported.

## Limits

- Edge caching: Cloudflare served a cache HIT about 2 h 58 m old. All values are as served to this host.
- The 2026-10-20 HTML bytes were not kept, so the cause of the +305 bytes is unknown. Attributing the change to a redeploy is [INFERENCE]
  and relies on the deployment id round 22 recorded from another page (S004) of the same site.
- I executed nothing: no CLI, account, vault or `op`, and no gates, selftests or ledger commands. I installed or updated no packages or tools.
- I audited no other source row. The extension to the other 13 legacy rows follows from the same OR-branch and was not checked row by row.
- S001's status, tier and teaches are unchanged. This report is advisory, not admission.

Report: .ufo/waves/round-23/parent-build/SourceS001.md
