# C3 re-grounding / drift findings — seat XAssimCol, 2026-11-03

All 8 adopted URLs were re-opened in this lane today (2026-11-03) with the lane's
declared profile `curl -fsSL --compressed` (`decoded-http-body-*`), and the byte
digests were compared with the truncated prefixes the staged package recorded on
2026-10-23. Full numbers: `source-fetches-append.tsv`, `capture-notes.md`.

## 1. Digest reproducibility, staged prefix (2026-10-23) vs this lane's capture

| new id | staged id | staged prefix | captured prefix | verdict |
|---|---|---|---|---|
| S053 | S066 gitleaks README | `65e87e68f4a16aef` | `65e87e68f4a16aef` | reproduces byte-for-byte |
| S054 | S067 trufflehog README | `068fbb5c93eb993d` | `7cf6efb50ab89234` | body moved |
| S055 | S068 betterleaks README | `f61c3993fd48dfb9` | `f61c3993fd48dfb9` | reproduces byte-for-byte |
| S056 | S069 GitHub search API | `0c8bdbd04508489c` | `b7e19953ecde88d0` | body moved (live API) |
| S057 | S070 verification-caching | `b1eb8215a66933f9` | `0beb84fec97fa0ac` | body moved (live docs) |
| S058 | S071 how-we-handle-your-data | `aef5f76a64c9565a` | `2c85abe9e3f842a7` | body moved (live docs) |
| S059 | S072 reverify-secrets | `2997de910834f751` | `b4790c43398da9db` | body moved (live docs) |
| S060 | S073 notify-results | `417032af5635ef39` | `8c0a977c75286c17` | body moved (live docs) |

Every *quoted sentence the entries rely on* still reproduces in today's body
(`RENDERED_TEXT_V1_LOCATE: count>=1` for S057-S060; literal substring for
S053-S056). No staged mechanism claim is contradicted. What moved is the byte
digest, not the teaching.

Mechanism of the two README moves:
- S053 gitleaks: `master` tip is `5f6ec56cfa6f8c67648d863582c7ae2f206d5c1c`;
  the README body is *identical* to the staged pin `b58d3f1` — same sha256 at
  both revisions. Only the commit id moved.
- S054 trufflehog: `main` tip `240ccdd90619...` vs staged pin `d6ea4a52…`;
  the README differs by exactly one line
  (`Find credentials in HuggingFace datasets, models and spaces.` →
  `… models, spaces and buckets.`). The staged quote is present in both.

## 2. Substantive scope omission in the gitleaks row/entry (not a quote contradiction)

The re-opened README carries, above the fold and also at the staged pin:

> Gitleaks is feature complete. I'm not merging new features into Gitleaks.
> Future releases will be security patches only. I'm shifting my focus to
> Betterleaks

(24 words, README `> [!WARNING]` block, line 11.) The staged row S066 and the
entry `secret-scanning-detection-vs-validation.md` treat Gitleaks as a live
tool reference and never record that its upstream is closed to feature work and
points readers at Betterleaks — the same project the second entry is about.
The detection-semantics claim survives unchanged; the *maintenance status* is a
tier/scope fact a curriculum row should carry. Recommendation: state it in
S053's `scope` (or `teaches`) instead of leaving it to the entry's prose, and
let the Gate quote the sentence above.

## 3. Volatile numbers in the staged anchor cells are now stale

- S056 (was S069) `anchor` says `stargazers_count` 2322 and
  `pushed_at` 2026-10-22T21:28:27Z. Captured today: **2774** stars,
  `pushed_at` **2026-11-03T00:45:58Z**, `fork: false` unchanged.
  The row's *claim* (Betterleaks is an independent project, not a Gitleaks fork)
  is unaffected; the numbers in the anchor are point-in-time and are already
  wrong. Either drop the counts from the anchor or date them.
- Same class, lower stakes: page stamps quoted in S057/S059 ("Updated 06 Jul
  2026") and S060 ("Updated 14 Aug 2026") still appear on the served pages.

## 4. Evidence-strength notes for the Gate

- S060's captured quote is the bare config field `sendUnverified`; the page has
  no prose sentence stating the default. The row's `teaches` ("… only through an
  explicit switch") is an interpretation of a sample config block, not a
  sentence the page states. Either soften `teaches` or accept the inference
  explicitly in the Gate.
- S056's only honest quote is a JSON key/value (`"full_name":
  "betterleaks/betterleaks"`); the `fork`/stars/pushed_at fields are the actual
  claim, so a JSON fragment quote is expected for a `code` row.

## 5. Truncated in-row digests in the staged rows

Six of the eight staged rows carry `fetch sha256 \`<16 hex>\`` inside
`anchor`/`teaches`. They are truncated campaign digests, they are not full
sha256 values, and (see §1) six of them no longer reproduce. They are not
lane pins: the lane's in-row pin regex is capital `Fetch sha256:` and applies to
S001-S016 only, so nothing trips, but leaving them invites a reader to treat a
dead 16-hex prefix as a pin. Recommendation: delete those fragments from the row
cells; `corpus/source-fetches.tsv` is where provenance belongs and this receipt
carries the real 64-hex digests.
