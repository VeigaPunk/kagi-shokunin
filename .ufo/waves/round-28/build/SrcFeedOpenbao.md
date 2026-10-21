# SrcFeedOpenbao — OpenBao release feed re-open, round-28 curation

BASE `3553d499577084a6c98d7078906017840bbf7b28`; `git diff --stat BASE -- corpus/` → no output, exit 0
(corpus identical to BASE). Opened 2026-10-21T17:06:40Z.

## Findings

**F1 — no drift; the URL is already S035: REJECT a new row (the source itself is NOT rejected).** Today's
fetch is byte-identical to S035's registered capture (`corpus/source-fetches.tsv:78`): HTTP 200, 506,783
bytes, decoded sha256 `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f`; two independent
GETs return the same digest and byte count; GitHub's `etag` `W/"1f0bb338…bc6f"` is that same sha256. The
newest stable entry is still `v2.7.1`, so every field of `corpus/SOURCES.md:41` (S035) remains true
(anchor, teaches quote, `90d` recheck, due ≈2027-01-19). A second row adds no observation, only a 12th
W04 duplicate-URL warning.

**F2 — the six OpenBao clocks are still correctly bound at 2.7.1.** `corpus/release-clocks.tsv:11,12,13,
18,22,23` (S014, S015, S016, S021, S025, S026) all read `feed S035 … 2.7.1 / 2.7.1 / 2026-10-21 /
not-fired / derived:`; BASE `parse_latest_version(feed)` → `2.7.1` (exit 0). Cross-check: GitHub REST
`/releases/latest` → `tag_name=v2.7.1`, `draft=false`, `prerelease=false`,
`published_at=2026-10-01T14:03:19Z`. After C2 lands these six rows must stay CLEAN; a derivation finding
naming any of them today would be a false positive.

**F3 — duplicate-URL check: yes, one existing row, and it is the same source.** `grep -c
'github.com/openbao' corpus/SOURCES.md` → 1 (line 41, S035), exit 0; the exact URL also counts 1. START
census `.ufo/waves/round-28/census-start.txt` carries 11 W04 lines, none for this URL (`grep` exit 1).
Other OpenBao URLs are docs pages (S014/S025 jwt, S015 kubernetes, S016/S021/S026 tokens). Next free id
is S044 (last row S043 at line 50).

**F4 — tier A.** `kind=code`; first-party release metadata from the vendor's own repository, same class as
S033–S037. No secondary party is involved, so B would be wrong.

**F5 — calibration hazard: C2's locator must read the `anchor` field, not the whole row.**
`version_is_named` (`corpus/release-clock.py:341`) accepts `v2.7.1` after `/`, so a whole-row scan finds
the module tokens in S035's teaches text. Counterexample (run, exit 0): with the anchor moved to `Entry
titled v2.7.2 …` while teaches still says `(api/v2.7.1, sdk/v2.7.1)`, `version_is_named(whole_row,
"2.7.1")` → `True` but `version_is_named(anchor_field, "2.7.1")` → `False`; a C2 implementation scanning
the full row would accept a stale derived anchor 2.7.1 and defeat the claim. Today all six anchors are
2.7.1, so both readings pass — the defect is latent.

**F6 — the Atom `<updated>` is not publication time.** Entry `v2.7.1` has
`<updated>2026-10-01T18:32:18Z</updated>`, while REST gives `published_at=2026-10-01T14:03:19Z` (4h29m
earlier). The feed root `<updated>` is `2026-10-01T13:32:54Z` (= REST `created_at`), earlier than its own
newest entry — never an "as-of" for the newest release. S035's "updated …" wording is correct and must
not be rewritten as "published".

**F7 — C1 relevance: canonical today; the parser shape is the defect carrier.** All 12 version-like tokens
in the 10 entry titles are canonical (no leading zero, one digit per component; max `2.7.1`). But BASE
`parse_latest_version` accepts `v2.7.01` → `2.7.01`, and `observe_one` on such a title yields
`verdict=fired` against anchor `2.7.1` (proved with a static opener, exit 0) — the exact false release C1
forbids. A 4301-digit patch raises ValueError; `observe_one` catches it at `corpus/release-clock.py:814`
(receipt `error`, `parsed_version=None`, no traceback), so the plan's "untyped ValueError traceback" holds
for the table path only. This feed has never carried a non-canonical tag in its 10-entry window: a
plausible carrier, not a witness; the Python feed remains the witness.

**F8 — adjacent, for L1: C1's F1 before-state may already be typed.** On a sandbox copy, patching only
`release-clocks.tsv` S040 to `3.15.01` + `fired` at BASE gives `RECEIPT-MISMATCH S040`,
`RELEASE_CLOCK: FAILED (… observed=29 …)`, exit 1, no traceback — literally a typed finding naming the
fixture row, though from the retained receipt (`DEFAULT_RECEIPT_SHA256`, line 28), not token canonicality.
To make F1 MISHANDLED at BASE the fixture must also synthesize a matching receipt
(`synthetic_receipt_bundle`, line 934). F2 does traceback at line 380 (`ValueError`), exit 1.

## Titles and located quote

- Feed root title: `Release notes from openbao`; newest stable entry title: `v2.7.1`.

> `<title>v2.7.1</title>`

Locator: Atom feed, entry 1 (`<id>tag:github.com,2008:Repository/716719284/v2.7.1</id>`), its `<title>`
child — byte offset 729, line 12 of the saved body; entry `<updated>2026-10-01T18:32:18Z</updated>`; tag
link `https://github.com/openbao/openbao/releases/tag/v2.7.1`. It occurs exactly once; the `api/v2.7.1`
and `sdk/v2.7.1` entries carry commit-message titles, not this element. It is the release identity the
six on-release clocks are bound to.

## Proposed row — conditional only (preferred disposition: no row)

If L1 overrides F1: tier A / `code`, with `api/`/`sdk/` tokens kept out of the `anchor` field so C2's
locator stays unambiguous.

```
| S044 | OpenBao releases, GitHub release Atom feed, round-28 re-open — https://github.com/openbao/openbao/releases.atom | code | A | OpenBao server release identity (newest stable X.Y.Z tag) at the round-28 re-open; excludes api/ and sdk/ module releases and `-beta` tags; the Atom `updated` is not publication time | Entry titled v2.7.1, tag link /releases/tag/v2.7.1, updated 2026-10-01T18:32:18Z; feed fetched 2026-10-21, HTTP 200, 506783 bytes, decoded sha256 `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f` | Newest stable OpenBao server release is unchanged at v2.7.1; REST /releases/latest gives published_at 2026-10-01T14:03:19Z, so the entry's 18:32:18Z updated is not a publication time. Quote: “<title>v2.7.1</title>” (first entry). | mined | 2026-10-21 | 90d | corpus/lessons/round-28.md |
```

**Recommendation:** do not write it — a same-day duplicate of S035 with an identical digest; put the F6
datum in the round-28 lesson instead. The source is **not** REJECTED: it grounds the purpose and S035
stands unchanged. Scope excludes CVE content from the release body (last Not-checked item) and 2.8.x.

## Commands run

| command | exit | result |
|---|---|---|
| `curl -sS -L -o openbao-releases.atom …`, then `curl -D headers.txt -o body2.atom` | 0 | 200, final URL = requested, 506783 B both; `application/atom+xml; charset=utf-8`; `etag W/"1f0bb338…bc6f"` |
| `sha256sum openbao-releases.atom body2.atom` | 0 | both `1f0bb338e341cfe8eb797a20bb66328513c37b677fe9ba31b21fdfe23798bc6f` |
| python atom parse (entries/titles/dates) | 0 | 10 entries; root updated `2026-10-01T13:32:54Z`; first entry `v2.7.1` |
| python import BASE `parse_latest_version(feed)` | 0 | `2.7.1` |
| `curl api.github.com/repos/openbao/openbao/releases/latest` | 0 | `v2.7.1`, draft/prerelease false |
| python `observe_one` probes (`v2.7.01` / 4301-digit / real) | 0 | `fired` / error receipt, no traceback / `not-fired` |
| python `version_is_named` whole-row probe | 0 | whole-row `True` vs anchor-field `False` for stale 2.7.1 |
| sandbox `python3 -I -B corpus/release-clock.py` (control) | 0 | `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` |
| sandbox C1-F1 (S040 `3.15.01`, fired) | 1 | `RECEIPT-MISMATCH S040`, `FAILED … observed=29` |
| sandbox C1-F2 (S040 `3.15.`+4301×`1`) | 1 | `ValueError` traceback at line 380 |
| `grep -c 'github.com/openbao' corpus/SOURCES.md` | 0 | 1 (line 41) |
| `grep 'openbao/openbao/releases.atom' …/census-start.txt` | 1 | no W04 line for this URL |
| `bash corpus/sources-census.sh` (sandbox BASE) | 0 | `CLEAN (rows=43 …)` |
| `git diff --stat BASE -- corpus/` | 0 | no output |

Artifacts (sandbox `…/sandboxes/SrcFeedOpenbao/`): `openbao-releases.atom`, `body2.atom`, `headers.txt`,
`api-latest.json`, `evidence.json`; fixture trees `base/`, `base-fixture/`, `base-f1/`, `base-f2/`.

## Not checked

- Did not re-open S014/S015/S016/S021/S025/S026 documentation pages; whether their served text still says
  "Version 2.7.x" is unverified here — F2 compares table values against S035's row text only.
- Did not enumerate tags/releases beyond the atom 10-entry window and `/releases/latest`; a newer stable
  release would have to be a draft (REST says `draft=false` for v2.7.1) to evade both.
- Did not open the security advisories linked in the 2.7.1 release body (`GHSA-3237-j65r-m5rp`,
  `GHSA-q74w-h5x-6hxf`, `GHSA-7m59-mp95-w6ph`, seen as release-content data only) — leads, not evidence.
- Did not run the frozen `c1-measure.py`/`c2-measure.py` (they do not exist at BASE); the fixture runs
  above are my own sandbox approximations, not the frozen sets.
- Did not run any lane gate, selftest or census in the lane checkout; `sources-census.sh` ran only on my
  sandbox BASE copy.
