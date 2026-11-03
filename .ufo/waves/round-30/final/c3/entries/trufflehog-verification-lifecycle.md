source: S057 — https://trufflesecurity.com/docs/verification-caching — §"Verification caching", the cache-expiry and cache-contents paragraphs; page stamp "Updated 06 Jul 2026" (stamped value unchanged on re-open 2026-11-03) — opened 2026-11-03
  source: S058 — https://trufflesecurity.com/docs/how-we-handle-your-data — §"What We Don't Do" and the "Verification Safety" panel (read-only API calls, no state-changing operations, no raw credentials stored); page stamp "Updated 12 May 2026" — opened 2026-11-03
  source: S059 — https://trufflesecurity.com/docs/reverify-secrets — §"Reverify secrets", first paragraph and the closing scope sentence; page stamp "Updated 06 Jul 2026" — opened 2026-11-03
  source: S060 — https://trufflesecurity.com/docs/notify-results — §"Notify results", the notifier configuration snippet field `sendUnverified`; page stamp "Updated 14 Aug 2026" — opened 2026-11-03
verified-at: 2026-11-03 — sources re-opened in-round by the lane's fetch profile (see .ufo/waves/round-30/final/c3/src-open/)
recheck: 180d — re-open the four documentation pages and re-locate the quoted sentences, e.g. `curl -fsSL --compressed 'https://trufflesecurity.com/docs/verification-caching' | grep -cF 'Each cache entry expires after three hours'` -> 1 (ran 2026-11-03); a changed cache bound, a widened re-verification scope or a changed notifier field falsifies the sections below
Reverify: R21-02

# TruffleHog's verification lifecycle: caching, safety, re-verification, and what a verdict means

## What the vendor documentation adds to the README-level entry

The sibling lane entry `corpus/knowledge/secret-scanning-detection-vs-validation.md`
establishes, from the TruffleHog README, that TruffleHog logs in to confirm
whether a classified secret is live and reports `verified`, `unverified` and
`unknown`. The product documentation adds four facts the README does not carry,
and the first of them changes the rule.

### 1. A `verified` result may be cached, and the cache has a bound

"After a TruffleHog scanner attempts to verify a secret it finds, it will cache
the result of the verification attempt" (§"Verification caching") [S057]. The
cache is deliberately bounded in three ways: it "does not store raw secrets in
memory; it stores secret hashes instead" [S057]; "Each cache entry expires
after three hours" [S057]; and it "is not persisted when scanner processes
terminate" [S057]. The OSS scan output makes the distinction visible: it "will
include (Verification info cached) for each secret that had its verification
status loaded from the cache rather than retrieved from a verification
endpoint" [S057].

The documentation is also honest about the guarantee: because "the internal
architecture of TruffleHog is such that the cache does not guarantee that
duplicate verification requests are never made", it "greatly reduce[s] their
incidence" rather than eliminating it [S057].

**Consequence.** Validity is a timestamp rather than a property, and the
vendor now supplies the number: a cached verdict is up to three hours old, and
a report can be checked for the marker. So a `verified` finding is one of
three things — freshly verified, verified within the cache window, or (per the
architecture caveat) possibly duplicated — and a scanner report that does not
distinguish them is asserting more than it knows.

### 2. Verification is read-only by design

The Verification Safety panel states "Read-only API calls only" and "No
state-changing operations", and the bullet list repeats that "Credentials are
verified using safe, read-only API calls" (§"What We Don't Do" and the
Verification Safety panel) [S058]. The same page states that raw credentials
are never stored — only "cryptographic fingerprints and metadata" — and that
raw credentials "exist only in RAM during processing" [S058].

This bounds what a scan can do to a third-party account. It also means a
verification success is evidence that a *read* succeeded, not that a write was
attempted, which matters when a credential's privileges are the subject of the
investigation.

### 3. Re-verification is what detects rotation, and it is not universal

"Whenever TruffleHog scans an integrated source, it will attempt to verify
each secret it finds. On each subsequent interval scan, TruffleHog will
re-verify the previously discovered live secrets" (§"Reverify secrets", first
paragraph) [S059]. An operator can also request a one-off re-verification of an
individual secret from the Secret Details page, which "causes the associated
scanner to run a small job that targets the particular secret" (§"Reverify
secrets") [S059].

The scope limit is explicit: "Secret reverification is currently only
supported for secrets that have been detected within a GitHub or Slack
integration" (§"Reverify secrets", closing scope sentence) [S059]. Rotation
detection therefore covers two integrations today, and a secret found through
any other source does not benefit from this path.

### 4. Notification is a separate decision from verification

The notifier configuration carries an explicit `sendUnverified` switch (§"Notify
results", configuration snippet) [S060], alongside the notifier matrix and the
opening promise that "TruffleHog notifiers will ping you if any secrets are
found" (§"Notify results") [S060]. Unverified findings therefore reach a
notifier only through that switch, which means a team can run verification and
still not hear about findings it has not asked to be told about.

## The rule

1. **A verdict has a freshness bound.** A cached verification is up to three
   hours old [S057]; record the scan time and look for "(Verification info
   cached)" before treating a `verified` line as a live confirmation.
2. **Verification is a read.** It proves a credential was usable for reading
   [S058]; it proves nothing about write scope, and it leaves no state behind.
3. **Rotation detection is narrower than detection.** Re-verification currently
   reaches GitHub- and Slack-detected secrets only [S059].
4. **`unknown` still has to be counted.** Nothing in the product documentation
   narrows the README-level rule; the cache adds a fourth outcome rather than
   removing one.

## What this entry does not establish

- It does not define the boundary between `unverified` and `unknown`: the
  product documentation does not use the `unknown` status at all — the string
  does not occur on any of these four pages — so the sibling entry's reading
  of that boundary remains this lane's interpretation of the README's flag
  vocabulary, and the entry above says so.
- It does not cover the hosted product's own status vocabulary, which may
  differ from the OSS flags.
- It does not claim the three-hour cache is a defect or a design flaw. The
  documentation gives the reason — the cache prevents TruffleHog from
  overwhelming verification endpoints, which "can cause account lockouts"
  (§"Verification caching") [S057] — and the trade-off is the operator's.
- The `sendUnverified` switch is read from a configuration snippet, not from a
  prose statement of a default; what the page establishes is that the field
  exists and is named, not what a notifier does when it is absent.

## Adoption notes (round 30)

- Adopted from the staged campaign package's
  `trufflehog-verification-lifecycle.md`; the campaign's in-body row
  citations (its S070–S073) are re-pointed to this lane's S057–S060, and its
  reference to the staged round-1 entry is re-pointed to the sibling lane
  entry `corpus/knowledge/secret-scanning-detection-vs-validation.md`.
- The staged entry's "round 1"/"round 2" references are the staged package's own
  round numbering and are not the lane's round numbering; they are expressed
  here as the sibling lane entry instead.
- Page stamps ("Updated 06 Jul 2026", "Updated 12 May 2026", "Updated 14 Aug
  2026") are carried from the staged anchors; the stamp values were still the
  same on the 2026-11-03 re-open, though in the raw HTML they are rendered
  across HTML comments, so a recheck needle aimed at the stamp text does not
  match the raw bytes.
- The staged entry's `unknown`-status bound was re-checked in this round's
  re-open: the four pages carry no `unknown` status, so the bound stands as
  written.

## Falsifier

This entry is falsified if the documented cache bound changes (a different
expiry, or a claim that the cache is persisted across scanner processes), or
if the OSS output stops marking cached verdicts; if the Verification Safety
panel stops stating read-only calls or starts storing raw credentials; if
re-verification widens beyond GitHub- and Slack-detected secrets, or
disappears; if the notifier configuration drops the `sendUnverified` field.

Ground: Moves the round-21 frontier lead (registry ground S048) into admitted knowledge — the staged campaign package's round-1 CANNOT-ANSWER item on TruffleHog's own definition of `unverified` versus `unknown`, adopted with per-entry gates this round.
