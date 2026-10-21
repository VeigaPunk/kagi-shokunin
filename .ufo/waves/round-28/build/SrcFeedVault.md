# SrcFeedVault — round-28 source opening: https://github.com/hashicorp/vault/releases.atom

Scout: `KagiR28.SrcFeedVault-7`. BASE `3553d499577084a6c98d7078906017840bbf7b28`.
Access date 2026-10-21 (HEAD/GET at 17:08Z). Production files untouched; no tool installs.

## Findings (observed, in priority order)

**F1 — Feed re-opened today; newest stable is v2.2.0, equal to S034's anchor.**
Fetch: `curl -sS -L` → HTTP 200, final URL unchanged (`https://github.com/hashicorp/vault/releases.atom`),
`Content-Type: application/atom+xml; charset=utf-8`, **303995 bytes**,
sha256 `e41bc5793403136a07c68d7d107fe3e9d68b834f51bd4d77cad5c13a388670ba`
(ETag `W/"e41bc5793403136a07c68d7d107fe3e9"`; a second GET was byte-identical, `cmp` exit 0).
Saved: `.ufo/waves/round-28/sandboxes/SrcFeedVault/vault-releases.atom`.
Root `<title>` = `Release notes from vault`; 10 entries, in feed order:
1 `v2.2.0` updated `2026-10-15T18:50:14Z`; 2 `v2.2.0-rc1`; 3 `v2.1.2`; 4 `sdk/v0.26.0`;
5 `v2.1.1`; 6 `v2.1.0`; 7 `v2.0.4`; 8 `v2.0.3`; 9 `v2.0.2`; 10 `v2.0.1`.
BASE's own parser `parse_latest_version` (`corpus/release-clock.py:715`) run on the saved
body returns `2.2.0`; `is_regression("2.2.0","2.2.0")` is False, `norm_version` equal is True.
S034's anchor cell (`corpus/SOURCES.md:40`) names `v2.2.0`, `2026-10-15T18:50:14Z` — **exact
equality, unchanged since round-25** (`corpus/lessons/round-25.md:91`). The four derived rows
on this feed — S013 (`corpus/release-clocks.tsv:10`), S022 (`:19`), S023 (`:20`), S024 (`:21`) —
carry anchored `2.2.0` / observed `2.2.0` / `not-fired`: consistent with today's feed, no typed
finding arises for them under C2. S012's `fired` row (`corpus/release-clocks.tsv:9`) is
unaffected (`numeric_version("v1.21.x")` is None, so no REGRESSED path).

**F2 — S034's teaches cell overstates what "first-entry parsing" would misread.**
`corpus/SOURCES.md:40` teaches: "…the same feed carries sdk/v0.26.0 and v2.2.0-rc1, so
first-entry or any-version parsing would misread it." At this snapshot the **first entry is
`v2.2.0`**; the `sdk/` tag is entry 4 and the rc is entry 2. Counterexample: first-entry
parsing reads `v2.2.0` correctly today. The supported claim is narrower: *any-version* parsing
misreads today, and first-entry parsing misreads only once an `sdk/` or `-rc` release sits
above the stable entry. This is a calibration wording defect in the row, not a feed defect;
it does not change any clock verdict.

**F3 — C2 locator hazard: bind to the anchor cell (`cells[5]`), not the whole feed row.**
S034's *teaches* cell names `sdk/v0.26.0` and `v2.2.0-rc1`. Probe against BASE helpers
(`.ufo/waves/round-28/sandboxes/SrcFeedVault/c2-binding-probe.py`, exit 0):
`version_is_named(S034.anchor_cell, "0.26.0") = False` but
`version_is_named(S034_whole_row, "0.26.0") = True` (same via the teaches cell alone).
So an implementation that scans the whole SOURCES.md row would **ACCEPT a forged derived
anchor `0.26.0` on feed S034** — a canonical token (C1 would not reject it) that names no
located anchor. The frozen G1–G4 fixtures (lower every derived anchor on a feed to one lower
canonical version) do not exercise this shape and would not catch it. Recommended
implementation: `version_is_named(sources[feed_source_id]["anchor"], anchored)` only; optional
extra mutant for L1 (not a redefinition of the frozen fixtures): one derived row on S034
anchored `0.26.0` must yield a typed derivation finding.
Related regex property, same family: `version_is_named("Entry titled v2.2.0-rc1", "2.2.0") = True`
(the lookahead `(?![A-Za-z0-9.])` at `corpus/release-clock.py:343` treats `-` as a boundary), so a
feed row whose anchor cell named only an rc would still "name" its stable core. Harmless at
BASE because S034's anchor cell holds no rc/sdk token.

**F4 — C2 control compatibility holds at BASE.** All 15 `derived:` rows name a version present
in their `feed_source_id` row's anchor cell: probe summary `fail=0/15` — S033 S008–S011
(3.13.3), S034 S013/S022–S024 (2.2.0), S035 S014–S016/S021/S025/S026 (2.7.1), S037 S029 (8.23.0).
A C2 implementation bound to the anchor cell keeps the default control
`CLEAN (on_release=30 … derived=15)` (plan `plans/round-28.md` C2) unchanged.

**F5 — C1 debt corroborated while here (BASE `corpus/release-clock.py`).**
`numeric_version("3.15.01")` returns `(3, 15, 1)` (same as `3.15.1`), yet the fired comparison
at `:582` is a string compare via `norm_version` (`:362`): `"3.15.01" != "3.15.1"` → a fired row
exits CLEAN. Oversize component: `numeric_version("3.15." + "1"*4301)` raises untyped
`ValueError: Exceeds the limit (4300 digits) for integer string conversion` at `:378`
(`tuple(int(part) …)`) — no typed finding. Both match the plan's frozen fixtures F1/F2.

**F6 — Duplicate URL: this feed already has exactly one row.** `grep -c` of the URL in
`corpus/SOURCES.md` = 1, at `:40` (S034). A new round-28 row for the same URL would add a
12th W04 duplicate-URL warning (START census carries 11, `.ufo/waves/round-28/census-start.txt:2-12`).
Nothing in the feed changed since S034 was written (same anchor term, same timestamp, same
sha-prefix ETag); a new row would add no information and one warning.

## Return fields

- **Exact title:** root `Release notes from vault`; first entry `v2.2.0`.
- **Verbatim quote (1 word, ≤25):** `<title>v2.2.0</title>`
  **Locator:** first Atom `<entry>` of 10, raw body line 12 (entry `<id>` line 9,
  `<updated>` line 10), tag link `/releases/tag/v2.2.0`.
  Note: byte-identical to S034's existing quote at `corpus/SOURCES.md:40`; if L1 ever needs a
  distinct quote, use the verbatim entry identity
  `<id>tag:github.com,2008:Repository/31288958/v2.2.0</id>` (raw body line 9) instead.
- **Tier:** A, kind `code` — vendor-published release metadata, same class as S034; grounds
  release identity only, no Vault behaviour.
- **Duplicates an existing URL:** yes — S034, `corpus/SOURCES.md:40`; sole occurrence.
- **Proposed scope (unchanged from S034, still accurate):** "Vault release identity (newest
  stable X.Y.Z tag) for the on-release clocks of S012, S013 and S022-S024; excludes `sdk/`
  module tags and `-rc` prereleases".
- **Proposed teaches (in-place amendment of S034, fixes F2):** "Newest stable Vault on the feed
  re-opened 2026-10-21 is v2.2.0 (first entry, updated 2026-10-15T18:50:14Z); the feed also
  carries v2.2.0-rc1 and sdk/v0.26.0, so any-version parsing misreads and first-entry parsing
  misreads as soon as an `sdk/` or `-rc` release sits above the stable entry. Quote:
  “<title>v2.2.0</title>” (first stable entry)." Keep the existing quote, opened date
  2026-10-21 and recheck `90d`.
- **Recommendation: ACCEPT the source, but do NOT add a new SOURCES.md row.** The source
  grounds the purpose (newest stable v2.2.0 = S034's anchor, so S013/S022–S024 stay
  `not-fired`), yet a row would duplicate the URL (F6), duplicate the quote, and repeat an
  `opened 2026-10-21` row with zero delta. Use this check as C2 evidence; if the row text is
  to change at all, amend S034 in place for F2 rather than superseding it. No REJECT: the feed
  does ground release identity.

## Commands run (exit codes)

- `curl -sS -L -o vault-releases.atom -w …` → HTTP 200, 303995 B, exit 0; `sha256sum` exit 0.
- `curl -sSI …` (headers, ETag/Content-Length) exit 0; second GET + `cmp` → `IDENTICAL`, exit 0.
- `grep -c 'https://github.com/hashicorp/vault/releases.atom' corpus/SOURCES.md` → `1`, exit 0.
- `git show BASE:corpus/{release-clock.py,SOURCES.md,release-clocks.tsv}` into sandbox, exit 0;
  sha256 of BASE `release-clock.py` = working tree `53823416…a136dc`.
- `python3 -I -B c2-binding-probe.py` → `sources: 43`, `derived rows: 15`, `SUMMARY fail=0/15`,
  exit 0 (also produced the F3/F5 probe lines quoted above).
- `python3 -I -B` inline BASE-parser run on the saved body → `parsed_version 2.2.0`, exit 0.

Sandbox artifacts: `vault-releases.atom`, `vault-releases.refetch.atom`, `release-clock.BASE.py`, `SOURCES.BASE.md`, `release-clocks.BASE.tsv`, `c2-binding-probe.py`.

## Not checked

- No `--observe` network run of the lane clock (only its pure parser on the saved body); no lane gate/selftest executed in the lane checkout.
- Not checked: GitHub API/HTML pages for v2.2.0 beyond the Atom body; release notes content
  semantics; signing/provenance of the tag; whether v2.2.0 is the newest *server* release in a
  channel sense (only the feed's stable-tag set was read).
- Residual, marked inference: if GitHub ever renders a module tag as `sdk v0.26.0` (space), `STABLE_TITLE_RE` (`corpus/release-clock.py:710`) would accept it as stable (no such entry today). Feed root `<updated>` (2026-10-14T19:24:08Z) predates the newest entry, so root-timestamp ordering must not be used — not exercised by the clock.
