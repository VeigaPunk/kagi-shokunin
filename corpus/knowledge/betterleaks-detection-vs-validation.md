
source: S055 — https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md — §Usage opening line and §Features table rows "Secrets Validation", "Secrets Analysis", "Expr-based filtering", "BPE filtering" — fetch sha256 `f61c3993fd48dfb9`, fetched 2026-10-23; S056 — https://api.github.com/search/repositories?q=betterleaks&per_page=10 — `items[0]` fields `fork`, `stargazers_count`, `pushed_at` — response sha256 `0c8bdbd04508489c`, fetched 2026-10-23
verified-at: 2026-11-03 — sources re-opened in-round by the lane's fetch profile (receipts .ufo/waves/round-30/final/c3/src-open/); campaign dates 2026-10-23 are not evidence here
recheck: 180d — `curl -fsSL 'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md' | grep -c 'Scans detect secrets without credential provider requests by default'` -> 1 (ran 2026-10-23)
ground: Round-1 CANNOT-ANSWER item 1 — "Betterleaks: does the fork change detection semantics, or add validity checking?"
Reverify: R21-02

# Betterleaks is not a Gitleaks fork, and its findings are stage-tagged

## The premise was wrong

The round-1 ledger recorded Betterleaks as "a Gitleaks fork" and asked whether it
changed detection semantics. The repository record says otherwise: the GitHub
repository search returns `betterleaks/betterleaks` with `"fork": false`,
2322 stars and a push on 2026-10-22 at the campaign capture; re-opened 2026-11-03: 2776 stars and a push on 2026-11-03 (point observations, not properties) [S056]. It is an independent project with its
own design, not a patch set on Gitleaks, and its rules therefore cannot be read
through Gitleaks's documentation.

That distinction matters for the lane's curriculum, because a fork inherits its
upstream's meaning while an independent project defines its own.

## The stage model

Betterleaks' README describes a **default-off** model rather than a default-on
one. "Scans detect secrets without credential provider requests by default" [S055];
validation and analysis are stages the operator asks for explicitly, with
`--validate` to check credentials, `--analyze` to additionally resolve identity
and permissions, and analysis implying validation [S055]. Both stages can also be
switched on through the environment (`BETTERLEAKS_VALIDATE`,
`BETTERLEAKS_ANALYZE`), with explicit flags overriding the variables [S055].

The features table then adds four capabilities the round-1 corpus had no row for:

| Capability | What the README says | Effect on triage |
|---|---|---|
| Secrets Validation | "Validate if a detected secret is active by making asynchronous HTTP requests directly from within the rule definition using Expr." [S055] | validation is a rule-level concern, not a separate tool |
| Secrets Analysis | enriches valid credentials with provider-neutral identity, account, capability and severity information [S055] | a validated credential carries an identity, not just a truth value |
| Expr-based filtering | contextual filters over fragment attributes such as git author, commit message and file path [S055] | false positives are cut with repository context, not only with patterns |
| BPE filtering | BPE tokenization measures how "rare" or non-human a string is [S055] | natural-language false positives are filtered statistically |

## The rule this produces

A Betterleaks finding is a **tuple, not a verdict**: (matched rule, stage that
ran, prioritization score). The README's prioritization row ranks "by confidence,
validation status, and analyzed severity scores" [S055] — three axes, of which
only the first exists before validation runs.

So the operational rule from the round-1 entry survives unchanged but gains a
condition: **a finding's meaning depends on which stage produced it**, and a
report that does not record the stage cannot be interpreted. A scan run without
`--validate` and one run with it produce the same rule hits but different
meanings, and only the second has said anything about whether the credential
works.

Two further cautions follow from the README's own wording:

- **The tool's own blog series is not the documentation.** The README links three
  Substack posts and one vendor article. Where a community write-up and the
  project's README disagree, the README wins [S055].
- **`main` is the v2 development branch.** The README states that v1 maintenance
  and documentation live on the `v1.x` branch [S055], so a version string in a
  scan report is not a sufficient provenance record for a rule set.

## What this entry does not establish

- It does not measure Betterleaks' precision, recall or false-positive rate. The
  README asserts BPE filtering and Expr filtering as features; it publishes no
  benchmark this round could open, so no comparative quality claim is made.
- It does not compare Betterleaks' rule set with Gitleaks' or TruffleHog's rules;
  this entry does not open those rule sets. A comparison needs a shared
  corpus and a shared metric, neither of which exists here.
- It does not describe Betterleaks' optional revocation stage beyond the README's own text: a rule may define an optional `revoke` Expr, `betterleaks revoke --rule <id>` executes it, and "Scans never run revocation" (re-opened 2026-11-03), so a rule hit never means a credential was revoked [S055].
- It does not claim the project is stable: `main` is a development branch, and
  the round-1 Gitleaks fork-network page could not be used to enumerate forks
  (see the round-2 rejection ledger).

---
