# SourceS009 — S009 source-bound provenance audit

Seat `SourceS009` (leaf scout, read-only, no subagent dispatch). The only write is this report.
Target: row **S009**, `corpus/SOURCES.md:15`, at revision
`d218603b74099ddca0bd8f869516fc41db0979bf` (frozen base named in `plans/round-23.md:3`).
Row-line sha256 `b97d9d7517be7431eda3f0d8eb2d20d5340c241857ed21299d42336d05f73477`. This matches the
R22 record (`.ufo/waves/round-22/falsify/ReopenSource09.md:58-59`), so the row is byte-immutable.
Tree: `corpus/SOURCES.md` and `corpus/knowledge/sops-age-key-rotation.md` are clean at HEAD. The only
untracked paths are `.ufo/waves/round-23/` and `plans/round-23.md`.

Verdict: **S009 is supported as written** (tier A docs, `mined`, anchor/quote/teaching reproduced
2026-10-21). No row supersedes it, and none is warranted. There is one real C2 contradiction (§4).

## 1. Opens (2026-10-21 UTC; read-only HTTP GET plus the public GitHub REST API)

| representation | path on `https://getsops.io` | status / type | bytes | sha256 | h2 anchor | row quote |
|---|---|---|---|---|---|---|
| canonical HTML (identity, `--compressed`, Mozilla UA all equal) | `/docs/usage/identities/age/` | 200 `text/html; charset=UTF-8` | 29301 | `a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76` | present | present |
| wire bytes, `Accept-Encoding: gzip`, undecoded | same | 200 | 8944 | `8ccc6ad227b91a5d6b9de73845ac45a5aa988e6af87873a072b2be75966a0488` | — | — |
| advertised `rel=alternate type=application/rss+xml` | `/docs/usage/identities/age/index.xml` | 200 `application/xml`, root `<rss` | 446 | `6cebe2c208b6d5508a396c68ed7f0c7606fbc44acfe77bb3b6d4cf9a979fd44f` | **absent** | **absent** |
| advertised `rel=alternate type=text/html` (print view) | `/_print/docs/usage/identities/age/` | 200 `text/html; charset=UTF-8` | 20043 | `1f8776b0c687e23c7453900fe35436ab324ff2c264a716312dd091159f11ac4a` | present | present |
| no trailing slash | `/docs/usage/identities/age` | **301** → `/docs/usage/identities/age/` | — | — | — | — |

Canonical headers: `etag: "1095229ea5f2c31a0d4a6c751b1c1cb0-ssl"`, `vary: Accept-Encoding`,
`cache-status: "Netlify Edge"; hit`, `age: 107231`, `date: Wed, 21 Oct 2026 03:42:46 GMT`.
Harness `read` of the canonical URL reported `Method: alternate-feed`. It used `…/age/index.xml`
and returned only the feed title. This reproduces the R22 caveat (`falsify/ReopenSource09.md:61-64`);
the feed is **RSS**, not the "Atom" that caveat names.

Revision facts: the page footer shows a Last-modified date of May 15, 2026, with a commit link to
`getsops/docs@9b7b84e297bdabc9c78e571c1e6db43dcd69454a`. GitHub API for that commit:
- author date `2026-05-15T17:05:01Z`, committer date `2026-06-23T20:04:48Z`;
- message "Add page descriptions."; 19 modified pages, including `content/en/docs/usage/identities/age/_index.md`;
- it is the newest commit on that path (the path history lists 9b7b84e, then 7fffe3e on 2026-05-15).

Latest SOPS release: v3.13.3, published `2026-07-23T05:27:57Z`. It predates the row's open date.

## 2. Field-by-field recheck of row S009

Public quote used (one per source, 13 words). Source: `Age on SOPS`, §Encrypting using age,
served 2026-10-21, https://getsops.io/docs/usage/identities/age/. Quote: "It is also possible to use
`updatekeys`, when adding or removing age recipients." In the HTML, `updatekeys` is an inline
`<code>`. The row's backticks normalize that markup and do not change the text.

| field | observed | verdict |
|---|---|---|
| anchor `§Encrypting using age` + footer date/commit | The page has one `<h1>` (Age) and one `<h2 id=encrypting-using-age>` at byte 22107, with no other `<h1-6>`. The quote is at byte 26031, inside that h2. The footer shows 2026-05-15 and `9b7b84e`. | **supported** |
| quote | Exact match after markup normalization | **supported** |
| teaches: recipients | `--age`, `SOPS_AGE_RECIPIENTS`, and a recipient list in `.sops.yaml` | **supported** |
| teaches: identity lookup | Per-OS `keys.txt` defaults plus overrides `SOPS_AGE_KEY_FILE`, `SOPS_AGE_KEY`, `SOPS_AGE_KEY_CMD`. The page states that identities are tried in sequence until one decrypts. | **supported** |
| teaches: `updatekeys` add/remove | The prose states both directions. The worked example shows only a `+++` addition inside Group 1, with no removal line. | **supported, qualifier kept** (R22 D6, not re-decided) |
| kind/tier/scope | The product's own docs, so primary for this SOPS scope (`/home/vgpnk/Projects/shokunin/.ufo/waves/kaika/SOURCES-CONTRACT-v1.md` §Shape, tier A). Not community, not a homepage. | **supported** |
| status `mined` | Cited on the `source:` line of `corpus/knowledge/sops-age-key-rotation.md:3` and in its body at lines 27, 36 and 37. Gate record: `corpus/lessons/round-21.md:63`. No other corpus file cites S009; `corpus/README.md:77` and `corpus/SOURCES.md:34` only point at it. | **supported** |
| supersession | No row text contains `supersedes S009`. S019, S020, S022 and S023 supersede only S007, S006, S012 and S013. | **none applies** |
| opened/recheck `on-release` | No release after v3.13.3. The page bytes are equal at all three observations: the 2026-10-19 pin, the R22 reopen on 2026-10-20, and this audit. | **fresh; trigger unfired** |
| historical vs current | The historical pin equals the current bytes in a now-documented representation (decoded `text/html`). Round-22's general "unknown representation" sentence (`corpus/lessons/round-22.md:146-147`) does not describe S009. | **no drift** |
| deployed-product proof | No version, release or status text on the page. The footer commit is docs housekeeping, not a SOPS release. The entry says "documented, not measured" (`sops-age-key-rotation.md:9-10`). | **correctly absent; none claimed** |

Exactness note: the Windows default path is served with doubled backslashes
(`%AppData%\\sops\\age\\keys.txt`, confirmed with `od -c`). Earlier summaries normalized it to single
backslashes. The difference is immaterial here, because neither the row nor the entry asserts that path.

## 3. C2 expectations for S009 (`plans/round-23.md` §C2)

Baseline matches the plan: `corpus/source-fetches.tsv` is absent, and 16 of 23 rows carry
`Fetch sha256:` (S001–S016, including S009 at line 15). Under the planned OR, S009 already passes
through its in-row pin, but that pin **records no representation**. To meet the plan's own
"point attestation of the fetched representation", add an append-only provenance row. Do not edit the row.

- **URL:** `https://getsops.io/docs/usage/identities/age/`, with the trailing slash. Record the final
  URL after redirects. The no-slash form returns 301.
- **Representation:** HTTP GET with the entity-decoded body and `text/html; charset=UTF-8`. Page
  alternates (RSS, `_print`) and undecoded wire bytes are not acceptable.
- **Hash:** `29301` bytes, `a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76`.
  This is a point attestation, not a drift pin (QM13, `corpus/QUALITY.md:72`: a typed gate checks
  only its declared representation).
- **Anchor:** `h2#encrypting-using-age` "Encrypting using age". The quote offset must fall after the
  anchor and before the next heading. For S009 that means 22107 < 26031, with no next heading.
- **Quote:** the row quote. Compare on a recorded basis: entities decoded, inline tags stripped,
  whitespace collapsed, backslashes literal.
- **Revision:** footer date `2026-05-15` plus `getsops/docs@9b7b84e…`. Store the repo with the commit,
  which the row omits. Compare against the GitHub **author** date. The committer date is 2026-06-23,
  so using it would flag a false mismatch.

## 4. The one real contradiction: planned `SC_FETCH` can attest bytes that lack the quote

The plan's `SC_FETCH` conditions are: in-row pin **or** complete provenance row, URL equality,
digest shape, quote bound, location present. All of them are satisfied by this row:

`S009 · https://getsops.io/docs/usage/identities/age/ · 2026-10-21 · application/xml · 6cebe2c2… · 446 · <row quote> · §Encrypting using age`

Yet those 446 bytes (S009's own advertised RSS alternate) contain **neither the anchor nor the quote**.
This is the observed outcome, not a hypothetical one:
- The harness default reader, which is how seats "open" sources, lands on that feed.
- The census is offline (`corpus/sources-census.sh` header: "Read-only: no network"), so no check can
  notice the mismatch afterwards.

The print view shows the opposite volatility: the same anchor and quote, but a different digest
(20043 B / `1f8776b0…`).

**Fix:**
1. Make `representation` a closed enum that excludes feed, print and undecoded wire bytes.
2. Require `quote_offset` and `anchor_offset` inside the hashed representation.
3. Leave byte re-verification to an explicit online reverify mode. A mismatch there should re-fetch
   under the declared representation before reporting STALE.

**Synthetic minimal failing fixture for L1 (not run; no result claimed).** It follows the
`base_fixture` and `rep` conventions in `corpus/sources-census.sh:249-288`.

```
# base_fixture adds corpus/source-fetches.tsv (tab-separated):
id	url	fetched	representation	sha256	bytes	quote	location	quote_offset	anchor_offset
S001	https://example.invalid/one	2026-10-21	text/html;charset=UTF-8;decoded	$(rep a 64)	1200	teaches one	§1	300	100
m_fetch_alt_repr() { sed -i '/^S001\t/s#\ttext/html;charset=UTF-8;decoded\t#\tapplication/xml\t#' "$1/corpus/source-fetches.tsv"; }
m_fetch_noslash() { sed -i '/^S001\t/s#\thttps://example.invalid/one\t#\thttps://example.invalid/one/\t#' "$1/corpus/source-fetches.tsv"; }
m_fetch_offset()  { sed -i '/^S001\t/s#\t300\t100$#\t50\t100#' "$1/corpus/source-fetches.tsv"; }
# case table literals: alt_repr → exit 1, SC_FETCH, findings=1; noslash → exit 1, SC_FETCH, findings=1;
# offset (quote before anchor) → exit 1, SC_FETCH, findings=1; base control → CLEAN, exit 0.
```

Against `SC_FETCH` as planned, `m_fetch_alt_repr` and `m_fetch_offset` would return CLEAN, so the
case table fails. That failure is the intended exposure of the gap. `m_fetch_noslash` tests the
planned URL-equality check (the S009 301 analogue).

## 5. Advisory to L1 (no admission authority)

1. Leave row S009 unchanged: `mined`, tier A. Keep the R22 updatekeys add/remove qualifier.
2. C2 rows should carry, per source: URL (requested and final), fetched date, representation enum,
   sha256, bytes, anchor, quote with its basis, offsets, and footer commit with its repo.
3. Optional, and L1's call: the row's `recheck: on-release` omits the docs-footer trigger that the entry
   names (`sops-age-key-rotation.md:5`). Contract rule 2 allows only a logged old→new `recheck` edit.

## 6. Limits

- Documentation text only. No SOPS execution, no version or deployment proof.
- The equality of the Netlify edge build and docs commit `9b7b84e` is [INFERENCE], based on the footer
  and the path history.
- GitHub API calls were unauthenticated and limited to commit, path-history and release facts.
- Scope: S009 and its used-by chain. S019–S023 were read only to rule out supersession. R22 reports are
  cited as prior observations; their decisions were not redone.
- Tools: `curl`, `sha256sum`, `od`, read-only `git`, the GitHub REST API and the harness `read`.
  No installs, no gates, no `op`/vault/host commands.
- One transient scratch file (`/tmp/s009probe.bin`) was created and removed in the same command.
  Nothing else was written besides this report.
