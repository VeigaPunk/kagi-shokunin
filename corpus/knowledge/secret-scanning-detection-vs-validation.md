
source: S053 — https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md — README intro paragraph and §"Configuration" rule fields — repo HEAD commit `b58d3f102cf3a2c84cb7f923d05c25c9b1aed84b`, fetched 2026-10-23; S054 — https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md — §"Validation ✅" and §"1: Scan a repo for only verified secrets" — repo HEAD commit `d6ea4a52e3f4705989210e60e9f0da0deafe84bf`, fetched 2026-10-23
verified-at: 2026-11-03 — sources re-opened in-round by the lane's fetch profile (receipts .ufo/waves/round-30/final/c3/src-open/); campaign dates 2026-10-23 are not evidence here
recheck: 180d — `curl -fsSL 'https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md' | grep -c 'it can also log in to confirm if that secret is live or not'` -> 1 (ran 2026-10-23)
ground: Secret scanning: detection versus verification — the frontier item the lane holds only as a prose-absent lead on Gitleaks/Betterleaks and TruffleHog
Reverify: R21-02

# Secret scanning: a detection is a pattern match, a validation is a live check

Two tools in this class are routinely treated as interchangeable, and the
difference between them is the difference between a hypothesis and a fact.

## Detection: pattern and entropy over text

Gitleaks "is a tool for **detecting** secrets like passwords, API keys, and tokens
in git repos, files" [S053]. Its documented engine is a Golang regular expression
per rule, with an optional `entropy` check applied to the extracted `secretGroup`
[S053]. Nothing in that pipeline contacts the issuer of the credential.

So a Gitleaks finding asserts exactly one thing: **a string that looks like a
credential of this type exists in this text.** It does not assert that the
credential works, that it was ever valid, that it was ever used, or that it was
exposed to anyone. A committed test fixture, a documentation example, a rotated
key and a live production key are indistinguishable to it.

## Validation: log in and find out

TruffleHog adds a validation step: "For every secret TruffleHog can classify, it
can also log in to confirm if that secret is live or not" [S054]. The README
frames this as the step that distinguishes an active danger from a harmless
match [S054].

Its result vocabulary is three-valued, exposed through the `--results` flag
(`--results=verified`, `--results=verified,unknown`) [S054]:

| status | meaning | safe to treat as "no exposure"? |
|---|---|---|
| `verified` | the tool logged in and the credential worked | no — this is the worst case |
| `unverified` | the credential did not validate | yes, for *this* credential, at this time |
| `unknown` | validation could not be attempted or failed | **no** — unproven is not proven |

`unknown` is the trap. It is what a network-restricted CI runner, a missing
permission or an unrecognised credential type produces, and it is the state most
likely to be silently collapsed into "fine" by a results filter. A report that
counts only `verified` and reports nothing about `unknown` has silently converted
"could not check" into "checked and clean".

## The operational rule

1. **A detection is a triage trigger, not an incident.** Escalate on the strength
   of the finding, never on its existence alone.
2. **Only a live check establishes validity.** If validity matters to the
   decision, the tool must be able to attempt it, and the report must state
   whether it did.
3. **`unknown` must be counted and reported separately.** An `unknown` bucket that
   is not reported is indistinguishable from a clean scan.
4. **Validity is a timestamp, not a property.** A credential validated at T can be
   revoked at T+1; a finding with no validation time is not evidence of current
   exposure.
5. **The scan window matters.** A secret that was committed and later removed was
   still in git history; the scan must cover history, not just the working tree.

## What this entry does not establish

- It does not compare the two tools' rule quality, false-positive rate, or
  coverage: the two READMEs do not publish comparable measurements, and a
  benchmark would be needed rather than a documentation reading.
- It does not extend to GitHub's own secret-scanning product, whose validity-check
  semantics the lane holds only as an opened-but-unwritten row (S048).
- It does not cover the **Betterleaks** project, whose stage model is the subject of the Betterleaks entry (rows S055-S056).
- It does not claim that TruffleHog's `unverified` and `unknown` are undefined by the tool. The README's section "What is credential verification?" (pinned commit `d6ea4a52`, line 422; re-opened 2026-11-03) defines `unverified` as "Credential detected but not confirmed valid (may be invalid, expired, or verification disabled)" and `unknown` as "Verification attempted but failed due to errors, such as a network or API failure". The table above paraphrases those definitions and adds no fourth status.

---
