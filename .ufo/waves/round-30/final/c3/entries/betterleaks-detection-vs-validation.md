source: S055 — https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md — §Usage opening line, the §"Notable Features" table rows "Secrets Validation", "Secrets Analysis", "Expr-based filtering", "BPE filtering", "Simple Prioritization", "Secrets Revocation", and the `main`-is-v2 branch note; repo HEAD `6cd808f299a81b19fdbd196b04a64e63565c8c5c` — opened 2026-11-03
  source: S056 — https://api.github.com/search/repositories?q=betterleaks&per_page=10 — `items[0]` object: `full_name` `betterleaks/betterleaks`, `fork` false, `stargazers_count` and `pushed_at` as point-in-time fields only — opened 2026-11-03
verified-at: 2026-11-03 — sources re-opened in-round by the lane's fetch profile (see .ufo/waves/round-30/final/c3/src-open/)
recheck: 180d for S055; 90d for S056 — re-open the README and re-locate the stage sentences, e.g. `curl -fsSL --compressed 'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md' | grep -cF 'Scans detect secrets without credential provider requests by default'` -> 1 (ran 2026-11-03), and re-read `items[0].fork` from the search API; the API row moves daily, so the README cadence does not cover it
Reverify: R21-02

# Betterleaks is not a Gitleaks fork, and its findings are stage-tagged

## The premise was wrong

The staged campaign package's round-1 ledger recorded Betterleaks as "a
Gitleaks fork" and asked whether it changed detection semantics. The repository
record says otherwise: the GitHub repository search returns
`betterleaks/betterleaks` with `"fork": false` (search response `items[0]`)
[S056]. It is an independent project with its own design, not a patch set on
Gitleaks, and its rules therefore cannot be read through Gitleaks's
documentation.

The star count and last-push date in the same response are point-in-time
fields, not the claim. The staged campaign's 2026-10-23 capture recorded
`stargazers_count` 2322 and `pushed_at` 2026-10-22T21:28:27Z; this lane's
2026-11-03 re-open of the same endpoint recorded `stargazers_count` 2774 and
`pushed_at` 2026-11-03T00:45:58Z, with `fork` still false and three
consecutive fetches byte-identical within the day [S056]. Those two numbers are
therefore reported here as the campaign's and this round's observations
respectively, and the durable part of the claim is `fork: false`: Betterleaks
is an independent project, so its rules are a separate design and not a patch
set.

That distinction matters for the lane's curriculum, because a fork inherits its
upstream's meaning while an independent project defines its own.

## The stage model

Betterleaks' README describes a **default-off** model rather than a default-on
one. "Scans detect secrets without credential provider requests by default"
(§Usage opening line) [S055]; validation and analysis are stages the operator
asks for explicitly, with `-v` / `--validate` to check credentials, or `-a` /
`--analyze` to also resolve identity and permissions, and "Analysis implies
validation" (§Usage) [S055]. Both stages can also be switched on through the
environment (`BETTERLEAKS_VALIDATE=true` or `BETTERLEAKS_ANALYZE=true`), with
explicit flags overriding the corresponding variable [S055].

The features table then adds four capabilities the staged round-1 corpus had
no row for:

| Capability | What the README says | Effect on triage |
|---|---|---|
| Secrets Validation | "Validate if a detected secret is active by making asynchronous HTTP requests directly from within the rule definition using Expr." (§"Notable Features" table) [S055] | validation is a rule-level concern, not a separate tool |
| Secrets Analysis | "Enrich valid credentials with provider-neutral identity, account, capability, and severity information" (§"Notable Features" table) [S055] | a validated credential carries an identity, not just a truth value |
| Expr-based filtering | "Write contextual rule filters that evaluate fragment (data chunks) attributes (like git author, commit message, and file path) and finding data to reduce false positives" (§"Notable Features" table) [S055] | false positives are cut with repository context, not only with patterns |
| BPE filtering | "Filter out natural language false positives by using BPE tokenization to measure how \"rare\" or non-human a string is" (§"Notable Features" table) [S055] | natural-language false positives are filtered statistically |

## The rule this produces

A Betterleaks finding is a **tuple, not a verdict**: (matched rule, stage that
ran, prioritization score). The README's prioritization row ranks "by
confidence, validation status, and analyzed severity scores"
(§"Notable Features" table, "Simple Prioritization") [S055] — three axes, of
which only the first exists before validation runs.

So the operational rule from the staged round-1 entry survives unchanged but
gains a condition: **a finding's meaning depends on which stage produced it**,
and a report that does not record the stage cannot be interpreted. A scan run
without `--validate` and one run with it produce the same rule hits but
different meanings, and only the second has said anything about whether the
credential works.

Two further cautions follow from the README's own wording:

- **The tool's own blog series is not the documentation.** The README links
  three Substack posts and one vendor article (§"Notable Features" preamble)
  [S055]. Those pages were not opened by this lane, so nothing is asserted
  here about what they say; where a community write-up and the project's README
  disagree, the README wins.
- **`main` is the v2 development branch.** "The `main` branch is for v2
  development. V1 maintenance and documentation live on the `v1.x` branch"
  (§Installation) [S055], so a version string in a scan report is not a
  sufficient provenance record for a rule set.

## What this entry does not establish

- It does not measure Betterleaks' precision, recall or false-positive rate.
  The README asserts BPE filtering and Expr filtering as features; it publishes
  no benchmark this lane could open, so no comparative quality claim is made.
- It does not compare Betterleaks' rule set with Gitleaks' [S053] or
  TruffleHog's [S057–S060]. A comparison needs a shared corpus and a shared
  metric, neither of which exists here.
- It does not cover the optional revocation stage. The README lists it
  ("Optionally revoke secrets") and, on re-open 2026-11-03, documents it
  operationally: a rule may "define an optional `revoke` Expr for explicit
  credential revocation", `betterleaks config show ids --revocation` finds
  configured support, `betterleaks revoke --rule <id>` executes it, and
  "Scans never run revocation" [S055]. Revocation is therefore a separate
  operator-initiated action outside any scan, not a scan stage.
- It does not claim the project is stable: `main` is a development branch, and
  the fork status is one repository attribute observed on 2026-11-03, not an
  enumeration of the upstream fork network.

## Adoption notes (round 30)

- Adopted from the staged campaign package's
  `betterleaks-detection-vs-validation.md`; the campaign's in-body row
  citations (its S068/S069) are re-pointed to this lane's S055/S056, and its
  cross-references to the other two staged entries are re-pointed to S053 and
  S057–S060.
- The staged entry's claim that one of the linked articles "describes the rule
  language as CEL while the README itself says Expr" is **not carried**: on
  re-open 2026-11-03 the string `CEL` occurs in the README exactly once, and
  only inside a linked post's title, so S055 does not carry the claim and the
  linked article is not a registry row this lane opened. What S055 does carry
  is that the README's own rule language is Expr (§"Notable Features" table,
  "Secrets Validation") [S055].
- The staged entry's bound "it does not extend to Betterleaks' optional
  revocation stage, which the features table lists but the README does not
  describe in operational detail" was withdrawn: the re-opened README does
  describe it operationally, as quoted above.
- The staged entry's star and push numbers are the campaign's 2026-10-23
  capture and are marked as such; this round's re-open values are given beside
  them.

## Falsifier

This entry is falsified if the README stops stating that scans detect without
credential provider requests by default, or if the stage flags and environment
variables change such that a stage can run without being recorded; if
`items[0].fork` becomes true for `betterleaks/betterleaks`, the premise
correction fails; if the README stops describing the revocation path as a
separate operator action.

Ground: Moves the round-21 frontier lead (registry ground S048) into admitted knowledge — the staged campaign package's round-1 CANNOT-ANSWER item on whether the Betterleaks fork changed detection semantics, adopted with per-entry gates this round.
