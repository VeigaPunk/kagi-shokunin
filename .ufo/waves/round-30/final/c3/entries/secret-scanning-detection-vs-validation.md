source: S053 — https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md — README intro paragraph, the maintainer status banner, and the §"Configuration" rule fields `regex`, `secretGroup`, `entropy`; repo HEAD `5f6ec56cfa6f8c67648d863582c7ae2f206d5c1c`, README bytes unchanged since the campaign's pinned `b58d3f102cf3a2c84cb7f923d05c25c9b1aed84b` — opened 2026-11-03
  source: S054 — https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md — §"Validation ✅", §"What is credential verification?" and §"1: Scan a repo for only verified secrets"; repo HEAD `240ccdd9061905ed3d7cbe05c01565f0ccf0cd0a` — opened 2026-11-03
verified-at: 2026-11-03 — sources re-opened in-round by the lane's fetch profile (see .ufo/waves/round-30/final/c3/src-open/)
recheck: 180d — re-open both READMEs with the lane's fetch profile and re-locate the quoted sentences, e.g. `curl -fsSL --compressed 'https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md' | grep -cF 'it can also log in to confirm if that secret is live or not'` -> 1 (ran 2026-11-03); a changed status vocabulary or a changed rule-field list falsifies the sections below
Reverify: R21-02

# Secret scanning: a detection is a pattern match, a validation is a live check

Two tools in this class are routinely treated as interchangeable, and the
difference between them is the difference between a hypothesis and a fact.

## Detection: pattern and entropy over text

Gitleaks "is a tool for **detecting** secrets like passwords, API keys, and
tokens in git repos, files, and whatever else you wanna throw at it via
`stdin`" (README intro paragraph) [S053]. Its documented engine is a Golang
regular expression per rule, with an optional `entropy` check applied to the
extracted `secretGroup`: the configuration block defines `regex` as a "Golang
regular expression used to detect secrets", `secretGroup` as the group the
secret is extracted from, and `entropy` as the "minimum shannon entropy a
regex group must have to be considered a secret" (§"Configuration" rule fields)
[S053]. None of those documented rule fields contacts the issuer of the
credential.

So a Gitleaks finding asserts exactly one thing: **a string that looks like a
credential of this type exists in this text.** It does not assert that the
credential works, that it was ever valid, that it was ever used, or that it
was exposed to anyone. A committed test fixture, a documentation example, a
rotated key and a live production key are indistinguishable to it.

Status note (observed 2026-11-03, same README bytes as the campaign capture):
the same README opens with a maintainer banner — "Gitleaks is feature
complete. I'm not merging new features into Gitleaks. Future releases will be
security patches only. I'm shifting my focus to Betterleaks" (README status
banner) [S053]. The detection semantics above are therefore stable rather
than moving, and the field's Gitleaks example is a maintenance line, not a
withdrawal of the engine.

## Validation: log in and find out

TruffleHog adds a validation step: "For every secret TruffleHog can classify,
it can also log in to confirm if that secret is live or not" (§"Validation ✅")
[S054]. The README frames this as the step that distinguishes an active present
danger or not [S054].

Its result vocabulary is three statuses, and the README defines each of them
[§"What is credential verification?": "Verification eliminates false positives
and provides three result statuses"] [S054]:

| status | the README's own definition | safe to treat as "no exposure"? |
|---|---|---|
| `verified` | "Credential confirmed as valid and active by API testing" | no — this is the worst case |
| `unverified` | "Credential detected but not confirmed valid (may be invalid, expired, or verification disabled)" | yes, for *this* credential, at this time |
| `unknown` | "Verification attempted but failed due to errors, such as a network or API failure" | **no** — unproven is not proven |

The `--results` flag selects among these plus a fourth output value,
`filtered_unverified` — "unverified but would have been filtered out" — and
defaults to `verified,unverified,unknown` (§"1: Scan a repo for only verified
secrets", `--results` flag help) [S054].

`unknown` is the trap. The README's own example of how one is produced is a
network or API failure [S054]; a network-restricted CI runner or a missing
permission is the same shape of event, and it is the state most likely to be
silently collapsed into "fine" by a results filter. A report that counts only
`verified` and reports nothing about `unknown` has silently converted "could
not check" into "checked and clean".

## The operational rule

1. **A detection is a triage trigger, not an incident.** Escalate on the
   strength of the finding, never on its existence alone.
2. **Only a live check establishes validity.** If validity matters to the
   decision, the tool must be able to attempt it, and the report must state
   whether it did.
3. **`unknown` must be counted and reported separately.** An `unknown` bucket
   that is not reported is indistinguishable from a clean scan.
4. **Validity is a timestamp, not a property.** A credential validated at T
   can be revoked at T+1; a finding with no validation time is not evidence of
   current exposure.
5. **The scan window matters.** A secret that was committed and later removed
   was still in git history; the scan must cover history, not just the working
   tree.

## What this entry does not establish

- It does not compare the two tools' rule quality, false-positive rate, or
  coverage: the two READMEs do not publish comparable measurements, and a
  benchmark would be needed rather than a documentation reading.
- It does not extend to GitHub's own secret-scanning product, whose
  detection-versus-validity semantics the lane holds as a separate registry
  row (S048).
- It does not cover the Betterleaks project's stage model (validation and
  analysis as opt-in stages); that is the subject of the sibling entry
  `corpus/knowledge/betterleaks-detection-vs-validation.md`.
- It does not claim a vendor policy over the three statuses. The README
  defines what each status means [S054]; it says nothing about which one to
  report or how to triage it, so rules 1–5 are this lane's operational
  reading, not the vendor's.

## Adoption notes (round 30)

- Adopted from the staged campaign package's
  `secret-scanning-detection-vs-validation.md`; the campaign's in-body row
  citations (its S066/S067) are re-pointed to this lane's S053/S054.
- The campaign text claimed the README "exposes the flags but does not define
  the distinction" between `unverified` and `unknown`. That claim is not
  carried: the README has a §"What is credential verification?" section that
  defines all three statuses, and that section is present at the campaign's
  own pinned commit as well as at today's HEAD. The status table above is
  therefore sourced to the vendor's own definitions.
- The campaign's `unknown` gloss ("validation could not be attempted or
  failed") is narrowed to the README's wording ("attempted but failed due to
  errors"); the broader reading is the lane's, not the vendor's.

## Falsifier

This entry is falsified if the TruffleHog README stops defining
`verified`/`unverified`/`unknown`, or the `--results` vocabulary changes so
that `unknown` is no longer a reportable state (rule 3 loses its object); if
the Gitleaks README documents an issuer-contact step in its rule pipeline (the
detection claim fails); if the Gitleaks status banner is withdrawn and new
detection features are merged (the status note fails).

Ground: Moves the round-21 frontier lead (registry ground S048) into admitted knowledge — the staged campaign package's round-1 CANNOT-ANSWER item on detection versus verification, adopted with per-entry gates this round.
