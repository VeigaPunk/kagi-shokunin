# RevPinDomain — round-23 falsification: did the historical in-row digests have a declared representation?

Seat: falsification (leaf), read-only on the lane. This report is the only lane write.
No production edit, no git/jj mutation, no install, no host gate, no secret read. Public
documentation re-fetch used only the contract profile
`curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`.

Target: round-23 C2's provenance claim for the legacy in-row `Fetch sha256:` values
(S001–S016) and the domain reconstruction for **S012/S013/S014/S016**, plus the honesty of
the round's stated bound.

## 0. Artifact revisions measured (the tree moved during the audit)

The round-23 tree was being integrated while this seat measured it. Every finding below is
pinned to a revision; transient states are labelled as such and are not counted as final
defects.

| time (-03) | `corpus/sources-census.sh` | `corpus/source-fetches.tsv` | `corpus/lessons/round-23.md` |
|---|---|---|---|
| 00:57:55 | `80966e208321348a…` | `ccc9ae6ec1b4bfa2…` | (earlier revision) |
| 01:02:21 | `24d834cc85344b76…` | `ccc9ae6e…` | `2f53cf690d81666a…` |
| 01:09–01:10 | `6d4190a7302eb001…` | `846b203734bcddce…` / `7101bdd0c69c6d15…` | `cf79cd0c85d981a0…` |
| 01:12–01:15 (final measured) | `511deb2730614663…` | `6e26e14032729070…` | `93df7d345554b99c…` |

Final measured digests of the other authorities:
`LOG.md 57dc73966c6f9e56…`, `SCORECARD.md 7dc220f625bea841…`,
`corpus/closure-dispositions.py cfa2c46ae0730730…`,
`corpus/closure-dispositions.json 00fbf48d3ea233d0…`,
`corpus/fixtures/cells-hermetic/{SCORECARD.md 2358325254a1e7ea…, claims.tsv 1a0737717ddc5b0c…, stamps.tsv 401ebb3c8b15888c…}`.
Line numbers below are from these revisions; quoted text identifies each anchor if a line
moved after this report.

## 1. Commands and exits actually run

All fetches are public documentation; no target execution, no account/vault action.

```text
# declared fetch profile, 16 historical-pin URLs and the 10 capture URLs
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url> -o <file>
→ every GET HTTP 200, curl exit 0; decoded-body sha256 + byte count computed with sha256sum/wc -c

bash corpus/sources-census.sh
→ SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
→ EXIT=0   (at 24d834cc, 6d4190a7, 511deb27)
→ at 80966e20 only: corpus/sources-census.sh: line 242: S007: unbound variable → EXIT=1, no verdict line

bash corpus/sources-census.sh --selftest
→ SOURCES_CENSUS_SELFTEST: PASS (59 cases) → EXIT=0 (also at 80966e20)

python3 corpus/closure-dispositions.py
→ CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15) → EXIT=0
python3 corpus/closure-dispositions.py --selftest
→ CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases) → EXIT=0
python3 corpus/closure-dispositions.py verify
→ CLOSURE_DISPOSITIONS: SETUP (unknown argument: verify) → EXIT=2   (there is no `verify` subcommand)

bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic \
  --claims .../claims.tsv --stamps .../stamps.tsv --scorecard .../SCORECARD.md --docs .../SCORECARD.md
→ CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0) → EXIT=0
# /tmp copies only, control + two mutations:
#   missing-id cell (R90-99 appended to the existing round table)
→ MISSING-ID SCORECARD.md:14 R90-99 / CELL_AUDIT: BROKEN (… missing_ids=1 …) → EXIT=1
#   failing row (R90-01 expected ^FX: NO$)
→ FAIL R90-01 reason=verdict-not-final exit=0 / CELL_AUDIT: BROKEN (… row_failures=1 …) → EXIT=1

# representation audit (Python, exit 0)
#   raw sha256, byte count, rendered-text-v1 digest and quote membership for all 10 capture rows
#   eight candidate representations × {today's body, Wayback raw body} for S012/S013/S014/S016
#   row-identity sha256 recompute for all 10 provenance rows
```

## 2. Finding 1 (confirmation): no historical in-row digest ever had a declared representation

- `corpus/SOURCES.md:18-22` (S012–S016) carry only `Fetch sha256: <64 hex>` inside the row.
  There is no representation, request profile, normalization, byte count, or fetch-client
  field. S001–S011 are the same shape.
- Round-22 recorded exactly this and did not invent a recipe:
  - `.ufo/waves/round-22/build/Source13.md:88` — S013's pin has “no representation, download
    mode, or normalization recorded”.
  - `.ufo/waves/round-22/falsify/ReopenSource12.md:54` — S012's pin “not reproduced;
    representation unknown”.
  - `.ufo/waves/round-22/build/Source16.md:93,192` — S016 tested against a 32-combination
    normalization matrix; “The pin extraction recipe was never documented”.
  - `.ufo/waves/round-23/parent-build/SourceS014.md:67,231-233` — S014 “seven tested
    representations”, none match; “evidence of an undocumented representation, not proof of
    which one it was”.
- The round-23 artifacts preserve the same bound rather than back-filling a representation:
  `corpus/source-fetches.tsv:35-37`, `corpus/sources-census.sh:67-69`, lesson
  `corpus/lessons/round-23.md:106-120`, `LOG.md:1213-1214`.

**Answer to the reconstruction question: no — the historical in-row digests did not have a
declared representation, in-row or in the round-22 record.** The field is a bare digest.

## 3. Finding 2 (domain hypothesis): the field domain is the decoded HTTP entity body

Re-fetching all 16 in-row-pinned URLs with the contract profile on 2026-10-21 gives:

| id | in-row pin | decoded body today | bytes | result |
|---|---|---|---|---|
| S008 | `63cb0a462ce23574…` | `63cb0a462ce23574…` | 1909 | **MATCH** |
| S009 | `a840727ea1a8faa0…` | `a840727ea1a8faa0…` | 29301 | **MATCH** |
| S010 | `fed6b2e145246ebc…` | `fed6b2e145246ebc…` | 36366 | **MATCH** |
| S011 | `d0ab8b201f1a6d5f…` | `d0ab8b201f1a6d5f…` | 33153 | **MATCH** |
| S001–S007, S012–S016 | (pins) | (different) | — | DIFF |

Four of sixteen reproduce **byte-exactly** as SHA-256 of the decoded body under the same
curl profile. These four span a raw-text file (S008, `raw.githubusercontent.com`) and three
static HTML docs pages (S009–S011), so the match is not a single-content-type accident.

The same-URL pairing sharpens it. Every active correction row for a target URL declares the
digest of today's decoded body, while the historical pin on the same URL does not:

| historical pin | same-URL active capture | today's decoded body | bytes |
|---|---|---|---|
| S012 `ec6e7b25…` | S022 `9a65b9d1…` | `9a65b9d1…` | 386400 |
| S013 `ae321512…` | S023 `de5f8836…` | `de5f8836…` | 261632 |
| S014 `e9472324…` | S025 `449ef132…` | `449ef132…` | 63046 |
| S016 `c083fdca…` | S021/S026 `52295218…` | `52295218…` | 47384 |

**Hypothesis H-BODY:** each historical in-row value is the SHA-256 of the decoded HTTP entity
body (Content-Encoding removed) as fetched on 2026-10-19, under an unrecorded request
profile, with no normalization.

Supporting evidence:
- 4/16 exact reproductions (above), including the raw README and three static docs pages.
- The active captures on the same four URLs are decoded-body digests today; the quotes and
  anchored text on those pages are unchanged (all four historical quotes are present in
  today's normalized text — measured below). The historical value therefore attests
  *different bytes at an earlier time*, not a different field.
- The OpenBao site redeployed between the pin and the correction capture:
  `last-modified: Tue, 20 Oct 2026 07:50:18 GMT` on both
  `openbao.org/docs/auth/jwt/` and `.../concepts/tokens/` (measured HEAD, 01:08), matching
  the round-22 build's “site-wide redeploy 2026-10-20T07:50:18Z”
  (`.ufo/waves/round-22/build/Source14.md:132`).
- HashiCorp raw HTML is shell-sensitive while its article text is stable: round-22 measured
  identical body text but different raw hashes across Wayback 2026-09-23, 2026-10-07 and live
  (`ReopenSource13.md:99-101`); S012's `dateModified` remains `2026-04-15T00:14:24Z`.

Not excluded: an unrecorded browser/DOM or reader-mode collector, an encoding variant, or a
bad/fabricated value on an individual row. The 4 exact matches make a *uniformly* fabricated
field implausible, but a per-row bad value is not excluded by any in-lane evidence.

**Confidence:** high that nothing was declared; medium-high that H-BODY is the field domain
(4/16 exact plus the same-URL pairs); low on the exact 2026-10-19 recipe.

## 4. Finding 3: S012/S013/S014/S016 — exact recipe is unrecoverable, and why

For each target URL I tested eight candidate representations of today's decoded body and of
the closest Wayback `id_` raw body: raw; `rendered-text-v1`; tags removed without inserting
spaces; lowercase rendered text; raw with LF→CRLF; raw with whitespace collapsed; `<main>`
text; `<article>` text. I also tested row-line, URL, and each quote string (with/without
backticks, trailing period, whitespace collapse). **Zero hits for all four pins.**

| row | pin | today raw / bytes | today normalized | Wayback raw nearest | hits |
|---|---|---|---|---|---|
| S012 | `ec6e7b25…` | `9a65b9d1…` / 386400 | `06d2508c…` | `02e9d1a2…`, 368816 B, 2026-09-18 | 0 |
| S013 | `ae321512…` | `de5f8836…` / 261632 | `0e62e056…` | `6d720336…`, 245553 B, 2026-10-07 | 0 |
| S014 | `e9472324…` | `449ef132…` / 63046 | `ca496ad8…` | `f0e346bf…`, 62952 B, 2026-06-17 | 0 |
| S016 | `c083fdca…` | `52295218…` / 47384 | `ed949658…` | `e721ea7e…`, 47121 B, 2026-09-18 | 0 |

Wayback availability/ CDX returned no 2026-10-19 snapshot for any of the four URLs (closest
dates above; the OpenBao JWT CDX list was empty and the availability API returned
2026-06-17). There is therefore **no 2026-10-19 byte snapshot in the lane** against which the
pins could be recomputed. The Wayback raw bodies are date- and shell-different and cannot
substitute for it.

Consequences that the claim must carry:
- Non-reproduction is **not** evidence of staleness, content drift, or a wrong quote. S012's
  page metadata and all four quotes are unchanged; S013's body text was stable across 27 days
  (round-22); S014/S016's site redeployed on 2026-10-20, after the 2026-10-19 pin.
- Non-reproduction is also **not** proof of a different representation. The exact recipe is
  underdetermined by the available evidence.
- A future capture must be compared on the decoded-body domain (H-BODY), never by
  recomputing the historical pin.

## 5. Finding 4: the round's bound is the honest conclusion

The bound is stated in four authorities and is consistent:

- `corpus/source-fetches.tsv:35-37` — “Legacy in-row `Fetch sha256:` values (S001-S016) are
  historical point observations with undocumented representation; the census requires their
  presence but does not compare them to these captures.”
- `corpus/sources-census.sh:67-69` — “STATED BOUND: legacy in-row digests are historical point
  observations with undocumented representation -- required for coverage, never compared to
  captures.”
- `corpus/lessons/round-23.md:106-120` — the same bound, plus the per-row audit evidence
  (S008 reproduces; S012/S013, S014, S016, S015 do not).
- `LOG.md:1213-1214` — “Historical in-row digests stay historical: S008 reproduces,
  S012/S013/S014/S016 do not reproduce under any tested representation”.

**Verdict: the bound is honest and is the correct comparison policy.** The round does not
claim a reproduction it did not obtain, does not restamp the old rows, and does not treat the
pins as drift pins. Digests in `source-fetches.tsv:33-34` are explicitly “point attestation
… never a content-drift pin and never a deployed-product proof”.

The claim is nonetheless **incomplete** in one respect: it presents the representation as
wholly unknown, while the tree's own evidence establishes the domain for the reproducing
subset. The bound the claim must state, in addition to the current text:

1. The domain hypothesis: decoded-body SHA-256 at fetch time, unrecorded client;
   evidenced by 4/16 exact reproductions (S008–S011, with byte counts) and the same-URL
   active captures.
2. The full non-reproducing set is **12 of 16** — S001–S007, S012–S016, and S015. The lesson
   currently names S008, S012–S016 and S015; S001–S007 are not named anywhere in the
   round-23 bound text.
3. No 2026-10-19 snapshot exists in the lane (Wayback nearest 2026-09-18/10-07/06-17), so the
   exact recipe cannot be reconstructed in principle from in-lane evidence.
4. Non-reproduction ≠ staleness, ≠ content drift, ≠ a different declared domain, and ≠
   fabrication. The gate cannot distinguish those (CritLegacyBound's CE3b reaches the same
   conclusion independently).
5. “Located quote” is attestation only. `corpus/source-fetches.tsv:25-26` now says
   “shape-checked only: <=25 ASCII words, not verified against the page bytes or the
   location”; the census checks word count and location length only
   (`corpus/sources-census.sh:266-267`). Keep that qualifier in the claim.

## 6. Finding 5 (live defect): the normalized-text recipe has three non-identical authorities

The normalized digest is the declared stable identity for the volatile captures
(`corpus/source-fetches.tsv:19-21`), and `S020` is the only row whose raw digest is
per-response variable. The recipe is therefore load-bearing.

Measured on the final TSV (`6e26e140…`), using the declared capture bodies:

| whitespace reading | normalized digests reproduced |
|---|---|
| Unicode `\s+` (Python `re.sub(r'\s+',' ')`) | **10/10** |
| ASCII `[ \t\n\r\f\v]+` (the census's `LC_ALL=C` `[[:space:]]` idiom) | **7/10** — S022, S023, S024 fail |

The failures are U+00A0 non-breaking spaces after HTML unescape. The three authorities do not
agree:

- `corpus/source-fetches.tsv:27-28` — “collapse Unicode whitespace (Python \s)” (the 10/10
  reading).
- `corpus/sources-census.sh:73-74` — “collapse whitespace” only.
- `corpus/lessons/round-23.md:41-42` — “collapse whitespace” only.

A conformant implementer following the census/lesson wording can produce different normalized
digests for three of ten rows. The gate never recomputes the normalized digest from bytes, so
it cannot detect the divergence. Independently corroborated by
`.ufo/waves/round-23/falsify/CritDigestDomain.md` Defect A (same 7/10 measurement, same
three rows).

**Fix (smallest):** copy the TSV's “collapse Unicode whitespace (Python \s)” into
`sources-census.sh:74` and `round-23.md:42`; optionally commit the normalizer with S022's
U+00A0 as a test vector. Until then the claim must state that the normalized identity is
reproducible only under the TSV wording, not under any “collapse whitespace” reading.

## 7. Other bounds the C2 claim must carry

1. **No cross-capture equality is enforced by the current gate.** `source-fetches.tsv:21` and
   `sources-census.sh:64-66` both say so and the code matches (there is no same-URL comparison
   at `511deb27…`). The two provenance rows for one URL (S021/S026) are manually consistent
   today — raw `52295218…` and normalized `ed949658…` agree — but nothing checks that. The
   selftest case named `fetch-disagree` now fails via duplicate provenance
   (`m_fetch_disagree` appends a second `S002` row, `sources-census.sh:426-430`, case
   `:553`), not via disagreement; the 12 `SC_FETCH` cases contain no agreement test. The
   round's M23-1 (`round-23.md:146`) documents the withdrawal; the claim must not imply
   machine agreement.
2. **“Volatile” is a conservative label, not a per-row measurement.** All 10 rows are
   `decoded-http-body-volatile-v1`. Measured today: S017, S018, S019, S024 reproduce their
   raw digests exactly; S021–S026 are byte-identical to the 2026-10-20 captures recorded in
   round-22 build/falsify reports; only S020 shows per-response variation (this seat's one
   re-fetch: same 190,261 bytes, different raw digest, matching normalized digest;
   `CritDigestDomain.md` independently measured 0/8 raw matches and 8/8 normalized and
   localized the difference to a 44-byte `cdn-cgi/l/email-protection` token). The “daily chrome or per-response token” rationale is
   evidenced only for S020; for the rest the label means deployment-coupled, not
   response-unstable. The claim should say the label is conservative.
3. **`final_url` is shape-checked, not origin-checked.** `sources-census.sh:253` accepts any
   `https?://…` string; a redirect to another origin would pass. The registered `url` equality
   *is* checked (`:250`), and the row-identity digest is checked (`:251-252`; recomputed
   10/10). The claim should say `final_url` is attested, not verified.
4. **The 59-case selftest does not exercise the in-row branch.** The clean fixture and all
   `fetch-*` cases use provenance rows only; the 16-row in-row branch is exercised only by
   the real-tree run (`round-23.md:205-208` states this). The transient crash at
   `80966e20…` is the concrete demonstration: `--selftest` passed 59 while
   `bash corpus/sources-census.sh` exited 1 with no verdict line. The final revisions pass,
   but the case count does not certify the legacy branch.
5. **The C2 record's “located quote” is manual.** The captures' quotes are present in today's
   normalized text (10/10 checked by this seat), but the gate checks only `<=25` tokens and a
   location length ≥8. The claim already has the right qualifier in the lesson; keep it in the
   plan's frozen wording too (`plans/round-23.md:28-29` says “a located ≤25-word quote”, which
   overstates what is gated).

## 8. Gate results at the final measured revision

| check | command | result | exit |
|---|---|---|---|
| C2 census verify | `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` | 0 |
| C2 selftest | `bash corpus/sources-census.sh --selftest` | `PASS (59 cases)` | 0 |
| C1 verify | `python3 corpus/closure-dispositions.py` | `CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)` | 0 |
| C1 selftest | `python3 corpus/closure-dispositions.py --selftest` | `PASS (14 cases)` | 0 |
| C3 exact row | `bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --claims …/claims.tsv --stamps …/stamps.tsv --scorecard …/SCORECARD.md --docs …/SCORECARD.md` | exact `CELL_AUDIT: CLEAN (cells=6 … missing_ids=0 … rows_run=2 row_deferred=0 row_failures=0 … self_skipped=0 …)` | 0 |
| C3 mutation (missing id) | `/tmp` copy, `R90-99` cell | `BROKEN (missing_ids=1)` | 1 |
| C3 mutation (failing row) | `/tmp` copy, `R90-01` expected altered | `BROKEN (row_failures=1)` | 1 |
| TSV shape | row count / distinct URLs | 10 rows / **9 distinct URLs**; 10/10 row-identity sha256 | — |
| Capture audit | raw, bytes, normalized, quote | 10/10 normalized, 10/10 quote present, 9/10 raw (S020 excepted, as declared) | — |
| Historical pins | decoded-body sha256 | 4/16 exact (S008–S011), 12/16 differ | — |

**C1 obligation count independently checked:** 9 `^- D[0-9]` bullets + 5 discernment decisions
+ 1 adjudication = 15; the dispositions file's `source_sha256` equals the actual
`round-22-verifier-spotcheck.md` digest; 7 `fixed` pointers resolve. The plan's “`verify`
exits 0” is prose: the runnable command is the no-argument invocation used by R23-02
(`corpus/claim-ledger.tsv:60`); passing `verify` as an argument exits 2 with SETUP.

## 9. Live claim/count mismatches (defects, low severity)

1. **`LOG.md:1194` says “with a 13-case selftest” while the delivered gate prints
   `PASS (14 cases)`.** `corpus/lessons/round-23.md:60,206` and `SCORECARD.md:851` say 14;
   `python3 corpus/closure-dispositions.py --selftest` prints 14. The 14th case is the
   `pointer-symlink` regression named at `round-23.md:206`. The frozen plan also says 13. The
   LOG after-state must be updated (or a migration note appended) so the count carries its
   command, which is exactly QA6.
2. **The earlier lesson revision said “10 declared provenance rows … over seven distinct
   URLs”.** Measured: 10 rows / 9 distinct URL strings (S021 and S026 share
   `https://openbao.org/docs/concepts/tokens/`). `LOG.md:1202` and the final lesson
   `:175` now say nine; the transient seven was corrected during integration. No live defect;
   recorded because the claim was false for at least one integrated revision.
3. **Transient only:** at census `80966e20…` the real verify crashed at line 242
   (`SUPERSEDED[$fid]=1` on an undeclared associative array under `set -u`) while the
   selftest passed 59; at an earlier fixture state the exact R23-01 command printed
   `MISSING-ID SCORECARD.md:1 R23-01` / `BROKEN`, exit 1. Both were mid-integration states;
   the final revisions above pass. The claim's “after” must be pinned to artifact digests,
   because the tree changed at least six times between 00:55 and 01:15.

## 10. Confidence and limits

- High confidence: no historical in-row representation was declared; the round's
  “undocumented representation / never compared / not a drift pin” bound is honest.
- Medium-high: H-BODY (decoded HTTP body at fetch time, unrecorded profile) is the field
  domain, from 4/16 exact reproductions and the same-URL active captures.
- Low: the exact 2026-10-19 recipe for S012/S013/S014/S016. No 2026-10-19 snapshot exists in
  the lane (Wayback nearest dates above); the served shells changed between pin and capture
  (OpenBao redeploy 2026-10-20T07:50:18Z; HashiCorp shell drift with unchanged article text).
- Not excluded: an unrecorded non-curl client (browser/DOM, reader mode) or a per-row bad
  value. The gate and this seat cannot distinguish “different bytes in time”, “different
  client”, and “fabricated value” without the missing snapshot.
- This seat ran no network beyond public documentation, no host/private gate, no vault or
  account action, and made no production edit. The only lane write is this report.
