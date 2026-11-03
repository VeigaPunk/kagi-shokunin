# RAttackC3 — C3 attack report (round-30 build)

Seat RAttackC3, reviewer. Attacked the C3 coverage claim (secret-scanning
detection-vs-verification adoption) per-entry and per-row against the frozen plan
`plans/round-30.md`, `PROVINCE.md`, `corpus/QUALITY.md`, and the read-only package
`/home/vgpnk/Projects/shokuknow/merge/kagi/`. Independent re-open receipts:
`final/c3/RAttackC3-src-reopen.md` (8/8 sources re-opened 2026-11-03; 2 formal).

Tooling installed: none (pacman transactions paused host-wide; nothing needed —
curl/sha256sum/python3 + the lane's own `corpus/rendered-text-v1.py` sufficed).
Scratch `/fast/scratch/hyaku/kagi-r30/RAttackC3/` used for all fetches; raw files never
left scratch; receipts copied into the wave dir first.

## 1. Per-entry verdicts

### Entry 1 — `secret-scanning-detection-vs-validation.md` (rows S053, S054): ADMIT (2 mandatory edits)

Scope (PROVINCE): IN. "Secret-scanning detection vs verification" is the lane's declared
round-21 frontier (PROVINCE §Core/Frontier/Adjacent; registry leads S048, and the
§Leads-unopened Gitleaks/Betterleaks and TruffleHog lines this adoption converts);
README round-28 contract line 241-243 states S048 et al. are "registry rows only; no
knowledge entry or coverage ground" — C3 is exactly the planned move past that line.
No sibling ground absorbed: kumitate/chousa/kasegi tripwires are output-hygiene
filters and research method, not third-party scanner semantics; the entry makes no
process claim about the lane's own gates.

QUALITY bar: quotes verified in-round (receipt file): S053 quote locates verbatim
including the `**` markers; §"Configuration" fields `secretGroup`/`entropy` present at
README lines 290-293; S054 full validation sentence locates at the pinned commit;
both section anchors (`## Validation ✅` L51, `## 1: Scan a repo…` L183) exist.
QA2/QA3/QA4/QA5/QA8 hold; the three-valued-status table is explicitly flagged by the
entry itself as the lane's reading of the flag vocabulary, not a vendor quotation —
honest as staged.

Mandatory edits before append (Gate records both):
1. "whose validity-check semantics the lane already holds as a **prose-absent lead**
   (row S048)" — S048 is not a lead; it is an opened, mined round-28 row with a located
   quote ("Validity checks help you prioritize…", §About validity checks). The
   "prose-absent" half is true (no knowledge entry covers GitHub's scanning); the word
   "lead" is wrong. Reword to "opened-but-unwritten row S048" or similar.
2. "It does not cover the **Betterleaks fork**, which this round did not open; the row
   stays a lead, not a source." — contradicts adopted entry 2's headline fact
   (`fork: false`, verified live 2026-11-03). Two admitted entries asserting
   opposite fork statuses is an internal contradiction. Reword to "the Betterleaks
   project"; the "not opened by this entry" clause survives as is.
Census-shape normalization (applies to all three entries): the staged frontmatter has
TWO column-1 `source:` lines; `sources-census.sh` SC_ENTRY_HEADER fails any sourced
entry with more than one (`nsrc -le 1`). Merge to one line
(`source: S053 (…); S054 (…)` per the census selftest shape), and re-date
`verified-at:`/`recheck:` in-round — the staged 2026-10-23 dates are campaign dates and
prove nothing here (plan text). The underlying needles still locate (receipts), so
re-dating is evidence-backed, not decorative.

### Entry 2 — `betterleaks-detection-vs-validation.md` (rows S055, S056): REFUSE as staged; flip stated → admissible after one fix

Scope (PROVINCE): IN — same named frontier lead; the S056 row is narrowly scoped to
"the repository's own fork status… as recorded by the code host" (code-host metadata
about the domain object, not kasegi method absorption).

QUALITY bar — the blocking defect (QA1, weak signal verbatim from QUALITY.md M12:
"a citation whose target does not carry the claim"):
> "one of those articles describes the rule language as CEL while the README itself
> says Expr [S068]"

S068's anchor covers the README §Usage opening line and four §Features rows. It cannot
carry what a Substack article says. Verified in-round: today's README (sha256
`f61c3993fd48dfb9…` — byte-identical to the campaign pin) contains `CEL` exactly once,
inside the blog-title pun "Express YourCELf" (line 8, the blog index). The article
itself was opened by nobody; no registered row covers it. As staged, the sentence
asserts article content on a README citation.
**Flip (any one makes it admissible):** (i) delete the CEL clause and keep the
"README wins over community write-ups" caution anchored to the blog-list line;
(ii) reword to the README-visible fact — "the blog index itself puns 'Express
YourCELf' while the features table says Expr"; (iii) open the Substack article and
register it, then cite that row for the CEL attribution.

Secondary edit (same entry, not blocking alone): "It does not compare Betterleaks'
rule set with Gitleaks' [the round-1 row S066] or TruffleHog's [round-2 rows
S070-S073]" — S070-S073 (→S057-S060) are verification-lifecycle docs pages; they hold
no rule set. QM11: the pointer should name the records' actual subject (verification
behavior) or be dropped.

Everything else verified strongly in-round: default-off quote locates (count 1);
`main`=v2-dev / v1.x claim at README line 31; Expr×5 / BPE×1 / env-var×1; blog index =
3 Substack + 1 vendor article as claimed; fork premise re-verified live — `fork: false`
reproduces 2026-11-03, while stars 2322→2774 and pushed_at 2026-10-22→2026-11-03T00:45Z
moved (old→new must land in the lesson Gate; the row's point-in-time scope and digest
pin keep it honest). Census normalization: merge the two `source:` lines; re-date
verified-at/recheck in-round.

### Entry 3 — `trufflehog-verification-lifecycle.md` (rows S057–S060): ADMIT (normalization only)

Scope (PROVINCE): IN — converts the "TruffleHog discovery-versus-verification behavior —
lead only, not evidence" line into admitted ground; four distinct vendor pages opened
per feature (QA10 shape).

QUALITY bar: all four load-bearing needles locate in-round with counts matching the
strip file (cache 1, safety 2, reverify 1 — full GitHub/Slack scope sentence, notify
2); all three anchor stamps reproduce in-round ("Updated 06 Jul 2026" on S057/S059
pages, "Updated 14 Aug 2026" on S060 — rendered with react comment markers, so plain
`grep 'Updated 06 Jul 2026'` misses; the stamps are real). The entry's honesty section
explicitly declines the unverified/unknown policy distinction, precision/recall, the
hosted-product vocabulary, and any cache design-flaw claim — QA3 strong. "currently
only supported for secrets that have been detected within a GitHub or Slack
integration" carries its currency qualifier (QA2). Read-vs-write custody kept distinct
(QA8).

Required normalization (gate mechanics, not content): FOUR column-1 `source:` lines
staged — SC_ENTRY_HEADER would fail; merge to one `source: S057 (…); S058 (…); S059
(…); S060 (…)` line; re-date `verified-at:`/`recheck:` in-round (S057/S059 needles
re-verified today; re-run the exact frontmatter commands for the dated receipts).

Residual note for the Gate (not a defect): rule 1's "a cached verification is up to
three hours old" is the vendor-DOCUMENTED bound (S057). The package holds later,
non-adopted entries reporting a docs-vs-code divergence for that bound
(`trufflehog-cache-expiry-docs-vs-code-r39`, `…-not-configurable-r40`,
`…-flag-surface-r41`) and a round-3/4 challenge to the `unknown` status vocabulary
(`secret-scanner-measured-detection-vs-validation`, `trufflehog-result-status-model`).
Adopting the round-2 entry must record that those qualifications stay unadjudicated
in the package and the 3h claim stays documentation-scoped (QA9) — one Gate sentence,
no entry text change required.

## 2. Per-row findings (append block S053–S060)

Conformance, all 8 rows: 11-column schema; `opened 2026-11-03` ✓; bare cadences
(180d×7, 90d×1) ✓; `used-by` = exactly one admitted entry, exact
`corpus/knowledge/<name>.md` path ✓; no `|` in any cell ✓; status `mined` ✓; tier
A×7 + B×1 (S060; legal — its entry also cites tier A rows, SC_ENTRY_CITE needs ≥1 A/B)
✓. Row set = exactly the rows the three entries cite (2+2+4); no extra, none missing.

- **Anchors still carry campaign provenance** ("fetched 2026-10-23", campaign sha
  prefixes, "page stamp Updated …") beside `opened 2026-11-03`. This pair is honest
  ONLY because the capture TSV separately carries this round's 2026-11-03 captures;
  the lesson Gate must say the in-round captures (not the anchor cells) carry
  currency. Recommendation: leave the historical pins in the anchors, add the Gate
  sentence; do not silently overwrite the campaign pin (QM14 keeps old→new).
- **Capture TSV (`source-fetches-append.tsv`): gate-conformant.** All 8 row-identity
  digests recomputed by me = match (`printf '%s\t%s\t%s\n' id status url | sha256sum`);
  all rows NF=16; profile string, http 200, 64-hex digests, positive bytes, quote ≤25
  words, location ≥8 chars, normalization enum + `-`/64-hex rules all correct; 40-hex
  revisions present for the two moving-ref raw URLs (S053's `5f6ec56c…` matches my
  independent `git ls-remote` exactly); `-` revision legal for the API/docs URLs.
- **Representation over-declared but legal:** `decoded-http-body-volatile-v1` is used
  even where bytes proved stable across independent fetches (S053/S055 raw identical
  to the 2026-10-23 campaign pins; S057/S058/S059/S060 identical across my repeat
  fetches). Only S054's `main` genuinely moved (new revision captured). No gate impact;
  noting it because volatile-v1 weakens nothing but proves nothing either.
- **S056 drift:** pinned stars/last-push moved in-round (values above); `fork: false`
  stable. Gate logs old→new; entry text needs no change (its sentence is dated).
- **`renumber-map.txt` header defect:** "staged package holds S052-S085" is wrong —
  the package holds S052-S223, 172 rows (MERGE-REPORT "proposed rows accepted: 172";
  my id extraction: 172, last id S223). The map's 8 verdict lines themselves are
  correct and the per-document (non-arithmetic) renumber is REQUIRED and verified:
  staged S053-S060 are the AWS/GCP/Aliyun/Tencent/CRYPTREC/CRYPTREC-ja documents
  (SOURCES.append.md lines 8-15), so arithmetic S066→S053 would have seated the wrong
  documents. Fix only the header count.
- **`used-by-derivation.txt`: verified EXACT** against the staged entries — all line
  lists match ([S066]@16,18; [S067]@29,31,34; [S068]@25,28,30,36,37,38,39,45,59,62;
  [S069]@15; [S070]@22,24,25,28,33,80,100 — line-based list, two citations share
  line 24; [S071]@46,48,83; [S072]@59,62,65,85; [S073]@71,73).
- **`recheck-prose-stripped.md`: complete, nothing lost.** The two rows absent from it
  (S053, S054) genuinely carry bare-cadence cells in the staged package (verified raw,
  SOURCES.append.md lines 21-22); the six stripped commands + the S056 rate-limit
  caveat are preserved verbatim for the lesson Gate as the plan requires.

## 3. Independent quote re-location (item 3)

Done — 2 formal (S053, S059) + 6 auxiliary, all on 2026-11-03 with the declared
profile; full commands/outputs in `final/c3/RAttackC3-src-reopen.md`. Headline:
S053/S054/S055 campaign pins byte-reproduce; S057/S058/S060 raw digests match the
executor's fresh capture TSV; both rendered normalized digests I attempted (S057,
S059) reproduce EXACTLY with the lane's one committed normalizer; every needle
locates; all three stamps confirm; S059's campaign raw pin (2997de91…) is superseded
by today's bytes (point attestation, no content contradiction).

**Comparison to `final/c3/src-open/` receipts: NOT PERFORMED at first pass — the
directory did not exist at any of my checks (last: ~15:2x).** Closed by the §8
addendum after XSrcOpen's receipts landed; my peer message flagged the two
observations that intersect its assignment (S056 drift; CEL only in the pun).

## 4. Row-set discipline (item 4)

Append block = ONLY the 8 cited rows ✓ (no queued/unused package rows such as S129/
S134-S136 or the S092 duplicate-target row enter the lane). used-by exact ✓. opened
2026-11-03 ✓. Cadences bare; the stripped prose is slated for the lesson Gate and is
preserved in `recheck-prose-stripped.md` + `capture-notes.md` — not lost ✓.

## 5. Refusal-boundary check (item 5)

PASS. No entry claims token totality, scanner completeness, or feed-token surface:
each has an explicit "What this entry does not establish" section; precision/recall/
coverage are explicitly declined; the 2026-10-21 boundary (feed-token derivation,
token totality, release-clock tokenizers) is untouched. No credential material
(QA5): flag names, env-var names and field names only; no `op://` refs, no secret
values anywhere in rows, entries, or this report.

## 6. Verification gaps / residual risk

1. ~~`src-open/` receipts absent at attack time~~ — closed, see §8 addendum.
2. The three renumbered ENTRY drafts (merged single `source:` line, in-round dates,
   the two entry-1 rewordings, the entry-2 CEL fix) do not exist as files yet — my
   verdicts bind the integration step; the census will mechanically catch a verbatim
   copy (SC_ENTRY_HEADER multiple-source-lines), but the CEL clause and the
   fork/lead wordings would pass the census while failing QUALITY — human-level check
   required at append time.
3. Entry-level `recheck:` commands must be re-run in-round for dated receipts; I
   verified the underlying sentences locate, not the exact frontmatter invocations.
4. Package-internal later entries that qualify the adopted three (docs-vs-code cache
   bound; `unknown`-status existence) stay unadopted — Gate sentence recommended
   (entry 3 residual note).

## 7. Suggested checks for the main agent / L1 (post-integration)

- `grep -cE '^ {0,3}\|[[:space:]]*S(05[3-9]|060)[[:space:]]*\|' corpus/SOURCES.md` ⇒ 8.
- `ls corpus/knowledge/secret-scanning-detection-vs-validation.md corpus/knowledge/betterleaks-detection-vs-validation.md corpus/knowledge/trufflehog-verification-lifecycle.md` ⇒ 3 files, each with exactly ONE column-1 `source:` line and 2026-11-03 `verified-at:`/`recheck:`.
- `bash corpus/sources-census.sh` ⇒ `SOURCES_CENSUS: CLEAN (rows=60 …)`.
- Lesson Gate carries: entry-2 CEL fix + flip record, entry-1 fork/lead rewordings,
  S056 old→new values, the 3h documentation-scope note, the renumber-map header
  correction, and the prose-strip preservation pointer.

## 8. Addendum — src-open receipts cross-comparison (landed during attack)

XSrcOpen's receipts (`final/c3/src-open/S066..S073.txt`) landed while this report was
being written; §6 item 1 is hereby closed at headline level. Cross-comparison:

- **Agreement on every overlapping measurement:** S066/S068 staged sha16 prefixes
  MATCH today (mine: byte-exact full digests); S067's staged digest reproduces exactly
  at the pinned commit d6ea4a52 (their extra find: `main` moved by a one-line README
  diff, HuggingFace "spaces" → "spaces and buckets" — no adopted claim or quote
  touched; capture TSV already holds the new revision); S069's load-bearing
  `fork: false` stable (they add a `/repos` check: `parent: null` — strengthens the
  independent-project premise); today's four trufflesecurity raw digests are
  identical across their fetches, my fetches, and the capture TSV (0beb…/2c85…/b479…/8c0a…).
- **Their finding, adopted here as a per-row requirement:** the STAGED package rows
  S068-S073 carry the digest inside a prose `recheck` cell with a `\|`-escaped pipe
  (awk NF=14), so the fleet-schema normalization strip was REQUIRED, not cosmetic.
  Measured closure: the normalized rows are NF=13 clean (my awk check: 8/8 rows
  NF=13). The census SC_MALFORMED class would have fired on a verbatim append of the
  package rows.
- **Plain-grep resistance class:** the S066 quote (bold `**` markers) and the page
  stamps (react comment markers, `Updated<!-- --> <!-- -->06 Jul 2026`) cannot be
  found by the plain-text needles a future recheck might assume; anchors name text
  only a comment-stripped/rendered locate (or a marker-aware needle) can find.
  Corollary for the Gate: future recheck needles should be chosen payload-unambiguous
  or run comment-stripped. My receipt used a marker-aware needle for S066 and a plain
  substring for the stamps (which survives because it excludes the marker span).
- **Count discrepancy resolved as needle-dependence:** their count=2 on S070-S072 was
  on longer quote needles duplicated in the archbee JSON payload; the STRIP-FILE
  recheck needles reproduce their expected counts in raw HTML today (measured by me:
  cache=1, safety=2, reverify-full-sentence=1, sendUnverified=2). No contradiction.
- **Interpretation delta, no operational impact:** "volatile per request" overstates
  it — reverify + verification-caching bytes were identical across three same-day
  fetches by two seats. Defensible form: "stable within today, changed since
  2026-10-23". Either way the staged 2026-10-23 digests are un-attributable, quotes
  locate, and digests stay point attestations.

Verdicts unchanged: entry 1 ADMIT (2 edits + normalization), entry 2 REFUSE as staged
(CEL clause; flip stated), entry 3 ADMIT (normalization). Row set, capture TSV,
strip file, used-by derivation, and the renumber-map header finding all stand.
