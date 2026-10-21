# ClockS008 — round 26 C1 freshness re-verification, SOURCES row S008 (SOPS upstream README)

Seat: `KagiR26.ClockS008` (scout, leaf). Lane-authored advice, not non-author closure.
Observed BASE: `git rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814` (matches frozen BASE);
`git status --short` → only `?? .ufo/waves/round-26/` and `?? plans/round-26.md` untracked.
Production files read only. Writes: this report, plus captures in
`.ufo/waves/round-26/sandboxes/ClockS008/` (`README.rst`, `readme.headers`, `releases.atom`, `feed.headers`).

## Bounded result

**NOT FIRED, teaching unchanged, rejection stands.** Both public URLs return bytes identical to the
retained records: the README matches the in-row/fetch pin, and the S033 feed matches the round-25
retained receipt. This is not a Python row; the Python 3.15.1 drift has no bearing on S008.

## Rows under test (production, BASE)

- `corpus/SOURCES.md:14` S008: REJECTED, tier C, recheck `on-release`. The row says the README
  "contains no age-recipient, key-group, or data-key rotation procedure for E2". Flip condition:
  "an upstream README revision that restores lifecycle mechanics". Quote: "You can find the SOPS
  documentation on getsops.io" (§Documentation). Fetch sha256 `63cb0a46…3440`.
- `corpus/release-clocks.tsv:5` S008: `feed`, feed source `S033`,
  `https://github.com/getsops/sops/releases.atom`, anchored `3.13.3`, observed `3.13.3`, `2026-10-21`, `not-fired`.
- `corpus/source-fetches.tsv:61` S008: sha256 `63cb0a46…3440`, 1909 bytes, revision
  `453e7e6ab01b1340dca9f9025fd8430229320f97`, profile `raw-literal-v1`.
- `corpus/inrow-pins.tsv:14` S008: `reproduces-raw`.
- Round-25 retained receipt `.ufo/waves/round-25/observe-1.json` (file sha256
  `b74c8ee30aaeaf7a867f9bbad39ea42e94f199da69ebd01d0e391d2e8b349f92`). Its S008 record is:
  `clock=feed, http_status=200, observed_at=2026-10-21T11:31:49Z, parsed_version=3.13.3,
  sha256=47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6, verdict=not-fired`.
  I read it and did not modify it.

## Commands and observed outputs (2026-10-21T13:36:33Z UTC)

Run in the sandbox directory:

```
curl -fsSL --compressed -D readme.headers -o README.rst https://raw.githubusercontent.com/getsops/sops/main/README.rst   → rc=0
curl -fsSL --compressed -D feed.headers  -o releases.atom https://github.com/getsops/sops/releases.atom                 → rc=0
sha256sum README.rst releases.atom
  63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440  README.rst      (1909 bytes)
  47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6  releases.atom   (253037 bytes)
```

I ran curl without the `-A` user agent from `curl-fsSL-compressed-v1`, so this request profile is
not byte-identical to the declared one. The digests still match.

HTTP metadata:

| URL | status | etag | date | other |
|---|---|---|---|---|
| README (raw.githubusercontent) | HTTP/2 200 | `W/"f904779240411d2fd4ee8b53178c223698f791b8ad2e61c76c5fd7ee0675467a"` | Wed, 21 Oct 2026 13:36:33 GMT | text/plain; content-length 988 (compressed); x-github-request-id `D482:199731:8A8A:B64D:6AD88145` |
| releases.atom | HTTP/2 200 | `W/"47a224ad71435b7f5cae863bc96c0146"` | Wed, 21 Oct 2026 13:36:32 GMT | application/atom+xml; content-length 253037; x-github-request-id `5861:1369AA:21BCF8:349AD0:6AD8BFE1` |

Additional probes:

- `git hash-object README.rst` → `bde72ff8d679829966c37933c3b67a5a1582d0be`. This is the git blob id of
  the captured bytes, not the commit stored in `revision`.
- `grep -n 'You can find the SOPS documentation on' README.rst` → line 18, 1 match.
- `grep -niE 'rotat|key.?group|recipient|age|data key|updatekeys|shamir' README.rst` matched only:
  - line 5, "…HuaweiCloud KMS, age, and PGP." (`age` as a backend name)
  - line 8, `i.imgur.com/X0TM5NI.gif`
  - line 12, a pkg.go.dev badge
  - line 56, `docs/images/cncf-color-bg.svg`

  The last three are substring hits on "age" inside image/badge names. None of the matches is a
  recipient, key-group, or rotation procedure.
- Atom parse (ElementTree, `v\d+\.\d+\.\d+` = stable) returned 10 entries, all STABLE. The first
  entry is `v3.13.3`, updated `2026-07-23T05:29:11Z`, link
  `https://github.com/getsops/sops/releases/tag/v3.13.3`, id
  `tag:github.com,2008:Repository/40684033/v3.13.3`. The rest are v3.13.2 (2026-06-30) down to
  v3.10.1 (2025-03-31).

## Source teaching and whether it holds

- **Located quote (8 words, ≤25):** "You can find the SOPS documentation on getsops.io".
  Source: README.rst §Documentation, line 18, URL above, accessed 2026-10-21. The raw line continues
  with RST link markup: `` `getsops.io <https://getsops.io/>`_ under `"Docs" <https://getsops.io/docs/>`_. ``
- **Feed quote:** “<title>v3.13.3</title>”, first stable entry, accessed 2026-10-21.
- **Teaching:** the README is a 60-line landing page covering formats/backends, Documentation,
  Security, License, Authors, Credits, and CNCF. It delegates every lifecycle mechanic to
  getsops.io/docs. The rejection reason still holds verbatim, and the flip condition has not
  triggered.
- **Scope bound:** this re-verifies only the README's §Documentation delegation and the absence of
  rotation, recipient, and key-group text in that one file. It says nothing about the getsops.io
  docs, which were not fetched (outside the permitted URLs), or about SOPS runtime behaviour.
- **Clock:** the newest stable tag is v3.13.3, equal to the anchored version, so the clock is
  `not-fired`. The feed digest equals the round-25 receipt's `sha256`, so the feed did not change
  between 11:31:49Z and 13:36:32Z on 2026-10-21.

## Unchanged teaching vs feed/docs-only limitations (actionable counterexamples)

1. **The feed clock cannot see this row's flip condition.** S008 cites a moving `main` ref. The
   flip is a README revision, and README edits on `main` need not coincide with a release, so the
   `feed` clock (S033) would stay `not-fired` through such an edit. Only the
   `source-fetches.tsv`/`inrow-pins.tsv` raw digest detects it. Counterexample: commit a lifecycle
   section to README on `main` with no new tag. `release-clocks.tsv` S008 still reads `not-fired`
   while the row's rejection has silently become stale. Today the digest reproduces, so this is a
   latent gap, not a current finding. A round-26 receipt for S008 should either carry or
   cross-reference the README raw digest, not just the feed version.
2. **The `revision` column was not re-observed this round.** `453e7e6ab01b…` is the commit for the
   moving ref. Byte identity proves the current README content equals what was captured at that
   revision. It does not prove `main` still points at `453e7e6a`, because main can advance without
   touching README.rst; round 25 observed main tip == anchor and README last touched 2026-05-15.
   api.github.com and git fetch were outside this seat's permitted URLs, so this is UNRUN, not
   passing.
3. **The feed is a 10-entry window.** It currently holds only stable tags. If maintainers publish
   a pre-release such as `v3.14.0-rc1` as the newest entry, a first-entry-title parser must skip
   it. The "only stable tag titles count" rule is stated in the S033 row; I did not re-check that
   `release-clock.py` enforces it this round.
4. **Weak ETags are not content pins.** The README etag is over GitHub's served representation.
   The feed etag happens to equal the first 32 hex digits of the body sha256. Neither should
   replace the sha256 of the decoded body.

## Not run (explicitly)

- `corpus/release-clock.py --observe`, `rendered-text-v1.py digest`, census, tests: not run (L1-only
  or unassigned). I did not recompute the normalized digest `4dd7e969ed6f…`; the raw digest
  reproduces exactly.
- getsops.io docs, api.github.com, git clone/fetch: not contacted.

## Proposed (advice only — L1 integrates)

No superseding registry row is needed for S008: the immutable facts (URL, digest, quote, verdict)
are unchanged. For the new round-26 receipt, the S008 observation would read: `feed`, S033 URL,
http 200, parsed_version `3.13.3`, sha256 `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6`,
verdict `not-fired`, observed 2026-10-21T13:36:32Z. Leave the round-25 receipt untouched.

## Tooling

No installs or updates. Used host `curl`, `sha256sum`, `git hash-object`, `grep`, `python3`
(stdlib `xml.etree`). No pacman transactions.
