# SourceS008 — S008 provenance audit (round 23, attempt 1)

Seat: `SourceS008` (reviewer, leaf, read-only). Axes: **calibration**, **freshness**,
**operability**. Scope: row S008 only; no other source row audited; no gate run
(contract forbids behavioral gate execution), no SOPS execution, no installs, no
production writes beyond this file.

- Observed revision: git `HEAD` = `d218603b74099ddca0bd8f869516fc41db0979bf`
  (matches `plans/round-23.md` base). Live `corpus/SOURCES.md` is byte-identical to
  `git show HEAD:corpus/SOURCES.md` (sha256 `a5e1c13e…cc30`); 23 rows; S008 at line 14.
- Frozen row identity: S008 line sha256 `771e4306…321b` (raw line incl. trailing LF)
  equals the round-22 `frozen/before` copy — the row text did not move into round 23.
- Method: exact registered URL reopened 2026-10-21 (read/curl only), digest compared,
  anchor and quote located, GitHub path-commit history via public API, local pointers
  followed. No claim of re-running any census or ledger verification.

## 1. Reopen record (2026-10-21)

| field | observed |
|---|---|
| URL (exact registered) | `https://raw.githubusercontent.com/getsops/sops/main/README.rst` |
| HTTP | `200`, `content-type: text/plain; charset=utf-8`, `content-length: 1909` |
| Decoded body | 1909 bytes, 60 LF lines |
| sha256 (decoded body) | `63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440` — **equals the row's recorded Fetch sha256** |
| Commit-pinned reproduction | `…/getsops/sops/453e7e6ab01b1340dca9f9025fd8430229320f97/README.rst` → same 1909 bytes, same sha256 |
| Transport metadata (not identity) | `etag: "90bfe9e7…bec7c3"` ≠ body sha256; `cache-control: max-age=300`; `x-cache: HIT`; `source-age: 8`; `vary: Authorization,Accept-Encoding`; `date: Wed, 21 Oct 2026 03:42:40 GMT` |
| Gzip wire representation | 988 bytes on the wire, sha256 `fe72c8b5…5090`; decoded entity body still `63cb0a46…3440` |
| Anchor | `Documentation` heading at RST lines 15–16; pointer sentence at line 18 |
| Pointer liveness | `https://getsops.io/docs/` → HTTP 200 (the delegation target resolves) |
| Latest commit touching `README.rst` | `50c790bf3e03…`, 2026-05-15T12:53:29Z, “Fix minimum Go version in contributor docs.”; current `main` head `453e7e6…` (2026-10-20) — `main` advanced with no README change |

## 2. Scoped fields rechecked

| field / assertion (row line 14) | observed public text | verdict |
|---|---|---|
| `teaches`: “contains no age-recipient, key-group, or data-key rotation procedure for E2” | body lists formats/backends, §Documentation pointer, §Security, §License (MPL-2.0), §Authors, §Credits; no command/config/recipient/key-group/rotation text | **supported** |
| Quote “You can find the SOPS documentation on getsops.io” (§Documentation) | line 18, rendered text: “You can find the SOPS documentation on `getsops.io <https://getsops.io/>`_ under `"Docs" <https://getsops.io/docs/>`_.” (8 words quoted; ≤25) | **supported as rendered text**, see C2 finding M1 |
| `anchor`: “§Documentation; upstream `main` snapshot opened 2026-10-19, no commit/version displayed” | heading present; file displays no commit/version — literally true | **supported**; commit identity now available (`50c790bf…`) as an *addition*, not a correction |
| `status: rejected` | flip condition (“an upstream README revision that restores lifecycle mechanics”) unmet; last README change 2026-05-15 predates round-21 opening | **supported; rejection stands** |
| `tier: C` | pointer-stub content carries no anchorable mechanism; QA1 (`corpus/QUALITY.md:20`) allows tier C only as non-sole support | **consistent**; row is cited by nothing (`used-by: —`) |
| `scope`: “SOPS recipient, key-group, and data-key rotation mechanics” | text is absent, which the `teaches` cell records; scope names the sought mechanics | **acceptable**; optional one-word clarification only if L1 re-curates (not a defect) |
| Explicit supersession | `supersedes` markers exist only on S019→S007, S020→S006, S022→S012, S023→S013 (`corpus/SOURCES.md:25,26,28,29`); none names S008. Coverage replacement is the separate `S009 → S010 → S011` path, which claims no supersession | **no superseding row** |
| Local pointers | `plans/round-21.md:31,65`; `corpus/lessons/round-21.md:49,62`; `corpus/lessons/round-21-verifier-spotcheck.md:13`; `LOG.md:1001–1004`; `corpus/knowledge/sops-age-key-rotation.md:4` (“opened and is not cited”). No ledger, knowledge, README, SKILL or PROVINCE reference; `corpus/claim-ledger.tsv` contains none | **no active dependency; historical mentions only** |

Deployed-product proof: none. The artifact is project documentation, not the released
binary; even its formats/backends list cannot prove runtime behavior. With status
`rejected` and `used-by: —`, no claim rests on it — correct.

## 3. Planned C2 source-fetch provenance — exact expectations

Requirements the planned `corpus/source-fetches.tsv` + `SC_FETCH` check should state,
using S008 as the worked example (all values observed above):

1. **Identity:** exact registered URL string, plus the row id, `status` (`mined` |
   `queued` | `rejected`) and the row-text sha256 so a provenance record cannot be
   re-pointed to a different row.
2. **Representation:** for a raw file, “decoded HTTP entity body, literal bytes,
   LF endings, `content-type` as served”; record observed `content-encoding` when
   present. Hash the decoded body, never the wire bytes (S008: gzip wire = 988 B /
   `fe72c8b5…` vs body = 1909 B / `63cb0a46…`). HTML captures must say whether the
   digest covers raw HTML or normalized text.
3. **Hash + size:** full 64-hex sha256 over that representation plus exact byte count;
   state the hash domain for any *row-line* hash (trailing LF included or trimmed).
4. **Moving refs:** record the resolved immutable revision (commit SHA, or the
   path's last content commit) alongside a `main`/`HEAD` URL, so the fetch is
   re-checkable against an immutable object; a ref-only URL is not content-addressable.
5. **Anchor + quote:** the anchor must be a literal locator in the declared
   representation (here the RST heading `Documentation`), and the ≤25-word quote must
   be locatable under an explicitly stated normalization (see M1).
6. **Date + non-claims:** UTC fetch date; a field stating the digest is a *point
   attestation of the fetched representation*, not a content-drift pin (already the
   plan's wording), and not a deployed-product proof.

Gap to close: `plans/round-23.md` §2 scopes added provenance to “the seven mined rows
that lack it”. S008 is `rejected`; if `SC_FETCH` checks only `mined` rows, a rejected
row's historical digest stays outside every machine check. Recommend either covering
non-queued rows (status column included) or an explicit, documented exemption.

## 4. Findings by severity

**M1 (medium, calibration/provenance).** The recorded quote is rendered text and is
**not** a byte-literal substring of the recorded representation:
`grep -cF 'You can find the SOPS documentation on getsops.io' <fetched body>` → `0`
(the body carries reST link markup). A naive “quote located in fetched bytes” check
either false-fails S008 or must silently normalize. This is a real contradiction
between the row's provenance fields as literally written.
*Fix:* declare the normalization (strip reST inline-link markup / compare rendered
text) or store the excerpt as served; do not leave the rule implicit.

**M2 (medium, operability).** `recheck: on-release` does not bound staleness for this
row: the registered URL is mutable `main`, and `main` moves without touching
`README.rst` (head `453e7e6…` 2026-10-20 vs README last change `50c790bf…`
2026-05-15). A commit restoring mechanics could sit unreleased indefinitely, so an
on-release clock would not fire. *Fix:* widen the trigger to “SOPS release **or
README.rst change on main**”, or re-point the row's provenance at the commit-pinned
URL — L1 decision, not a unilateral edit.

**M3 (low→medium, provenance hygiene).** Two round-22 artifacts label different
byte-domains as “the S008 line” hash: `.ufo/waves/round-22/registry-census-details.json`
→ `immutable_original_full_line_sha256.S008 = 24d193c7…fe99` (line **without** trailing
LF, 732 B) while `.ufo/waves/round-22/falsify/ReopenSource08.md:48–49` and
`.ufo/waves/round-22/build/Source08.md:81` publish `771e4306…321b` (line **with** LF,
733 B). Both reproduce; neither names its domain. *Fix:* C2 must print the hash domain
next to every digest.

**I1 (info).** Transport metadata is not content identity: the served `etag`
`90bfe9e7…` is a Fastly opaque value, and cache fields (`x-cache`, `source-age`,
`x-fastly-request-id`, `expires`) vary per response. C2 should record but never key
on them.

**I2 (info, calibration confirmation).** 1/1 correct reject; digest reproduced exactly;
pointer target resolves; no supersession; no overclaiming caller found. Nothing in
this review changes the row's `rejected` status — that is L1's call alone.

## 5. Residual risk and verification gaps

- The 2026-10-19 bytes are not independently provable; equality with today's digest
  plus an unchanged `README.rst` path history (`50c790bf…`, 2026-05-15) is inference
  from GitHub's API, not an independent mirror/archive check.
- “No README revision between 2026-05-15 and 2026-10-21” rests on the unauthenticated
  public commits API (`/commits?path=README.rst`); no Software Heritage or local
  clone check was made.
- No census/gate/selftest was executed (contract), so `SC_REJECT_SHAPE` compliance for
  S008 (prefix `REJECTED:` + `flip:`) is read statically from `corpus/sources-census.sh`
  logic plus the row text, not observed as a passing run.
- `SC_FETCH` and `corpus/source-fetches.tsv` do not exist yet (verified absent), so
  §3 is a specification for round-23 implementation, not a description of running code.
- No SOPS execution, no other source row audited, no sibling-domain reads, no packages
  installed or updated.

**Report: `.ufo/waves/round-23/parent-build/SourceS008.md`**