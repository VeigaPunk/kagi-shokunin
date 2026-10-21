# SourceS048 — GitHub secret-scanning concept row (candidate 62a33b1b)

**VERDICT: PASS** — the registered S048 source, scope, anchor, capture identity, raw-byte count,
normalized digest and Gate quote reproduce against a fresh fetch of the page. No scope overclaim
found. No production edit; one scout-run fetch, no lane gate/selftest executed.

Row under test (candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0`):
- `corpus/SOURCES.md:55` — S048 registry row (source/scope/anchor/teaches/status/recheck/used-by).
- `corpus/source-fetches.tsv:91` — capture row (identity / sha256 / bytes / normalized sha / quote / location).
- `corpus/lessons/round-28.md:35` — Gate admission: "ADMIT tier A docs, 90d, frontier lead (detection versus verification) ... (located once)".
- BASE `3553d499`: `git show 3553d49:corpus/SOURCES.md | grep -c S048` = 0, so S048 is candidate-introduced and has no older row to diff.

## Findings

1. **No falsification of the registered content claims.** My own fetch (not prior scout text) returned
   HTTP 200 at the exact registered URL, `<title>Secret scanning - GitHub Docs</title>`, H1
   `Secret scanning`, h2 `Customizability` → h3 `About validity checks`
   (`id="about-validity-checks"`), and the Gate quote inside that h3.
2. **Raw-digest volatility is declared, not a defect.** Fresh body raw sha256 `a4e0abaf…` vs registered
   `d3a6953d…`; both are 579783 decoded bytes. `cmp -l` shows 76 differing bytes in 4 runs, all Next.js
   deployment chrome: `buildId` `RFHaKDekHOOUtf5ZK8clQ` (capture) vs `tKruMSpttzVE7ytzANYAL` (fresh),
   plus `webpack-*.js`, `_buildManifest.js`, `_ssgManifest.js` names. The row declares
   `decoded-http-body-volatile-v1` ("No cross-capture equality is enforced"). The retained capture
   `.ufo/waves/round-28/captures/S048.body` reproduces the registered raw sha and byte count exactly,
   and both bodies normalize to `039e5c9c…`, quote count 1.
3. **Locator prefix is suffix-conventional, not false.** The anchor's "requested
   /introduction/about-secret-scanning 301s here" holds with the full legacy prefix:
   `https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning` → `301`
   `Location: https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning`;
   the bare `https://docs.github.com/introduction/about-secret-scanning` → `404`. Same suffix notation
   the lane uses at S044/S046; recorded as a locator imprecision, not a falsification.
4. **No scope overclaim.** "automatic" is literal ("Secret scanning automatically detects credential
   leaks…"; "runs automatically for free" for public repositories). "opt-in" is a paraphrase of
   "When you enable validity checks" — the page does not use the word. "GitHub Secret Protection's
   distinction" is narrower than the page, which describes secret scanning generally (the product name
   appears in the access section for private/internal repositories); the row's own bound "GitHub only,
   concept level, no scanner-independent verification semantics" is correct. The teaching adds one
   inference the page does not state literally ("a detection alone is not proof of a live credential"),
   which follows from validity checks testing whether a detected secret is still active; recorded as
   inference, not page text.
5. **Status/eligibility/lead qualifiers are present and correct.** status `mined` (matches capture field 2
   and the census enum), kind `docs`, tier `A` first-party documentation, `recheck: 90d`, used-by
   `corpus/lessons/round-28.md` (carries S048 at :1 and :35). No draft/IPD claim (contrast S049);
   `corpus/SOURCES.md:72` marks it a frontier lead with "mechanism adoption stays future work", and no
   C1/C2 claim cites it.
6. **Capture identity binds.** `sha256("S048\tmined\t<registered-url>\n")` = `d8bca984…`, equal to
   `corpus/source-fetches.tsv:91` field 3 and to `.ufo/waves/round-28/captures/metadata.json` S048
   identity. Decoded bytes 579783 = row field 11 = both body files. curl `size_download` 34767 is the
   compressed transfer, consistent with the declared decoded-body digest domain.

## Commands run (my sandbox `/fast/scratch/hyaku/kagi-r28/SourceS048`; exit codes shown)

```
curl -sS -L --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o s048.body -w 'http=%{http_code} final=%{url_effective} bytes=%{size_download}\n' \
  https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning
# exit 0; http=200; final = registered URL; decoded file 579783 bytes
sha256sum s048.body
# exit 0; a4e0abafa97f82c3136125b57964e062bde5f9e2f2831d14088a9f22b5dfc1d2 (fresh raw)
sha256sum .ufo/waves/round-28/captures/S048.body            # from lane root
# exit 0; d3a6953dfa6f61512e7bf2bcc17804401eb3bd82bf25eb74731c4a5a27784c1a (registered raw)
python3 -I -B corpus/rendered-text-v1.py digest <body>       # both bodies
# exit 0; normalized_sha256=039e5c9c8923a10ea72053be1c957bf4a15084b8a08afd82eda0930354e0e19f normalized_bytes=16719
python3 -I -B corpus/rendered-text-v1.py locate <body> '<quote>'   # both bodies
# exit 0; RENDERED_TEXT_V1_LOCATE: count=1
printf '<quote>' | wc -w                                     # exit 0; 19 words (Gate <=25)
printf 'S048\tmined\t<registered-url>\n' | sha256sum         # exit 0; d8bca984… (matches field 3)
cmp -l captures/S048.body s048.body | wc -l                  # exit 0; 76 (buildId/chunk names only)
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' \
  https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning
# exit 0; 301 https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning
curl … https://docs.github.com/introduction/about-secret-scanning   # exit 0; 404
```

## Not checked

- No `corpus/sources-census.sh` / selftest / lane gate executed (scout bounds); SC_FETCH shape rules read
  at `corpus/sources-census.sh:255-286`, not run.
- Did not open the linked child pages (`/concepts/secret-security/validity-checks`, the
  enable-validity-checks how-to, partner program); no claim from them is used.
- Did not test raw-body stability beyond the single capture/fresh pair; no deferred second fetch.
- No other registry row touched; no vault/account/handler/CDP contact; no host-private reads; no tool
  installs; no production writes or git/jj mutation.

**Concrete counterexample: none found.** Strongest candidates were (a) fresh raw sha mismatch,
(b) bare legacy path 404, (c) "opt-in" not literal — each is explained by the declared volatile
representation, the lane's suffix locator convention, and paraphrase respectively; none contradicts a
registered field.
