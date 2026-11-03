# Kagi reading queue 02: detection, suppression and verification are different

Curated 2026-11-03. **Unassimilated candidate for post-hyaku review.** This adds a public reading reference only. The existing lane hold is unchanged; no credential, vault, host, repository scan, account verification, installation or training was performed or authorized.

## Candidate: Yelp detect-secrets

- **Official repository:** https://github.com/Yelp/detect-secrets
- **Pinned reading:** [README at 5e141933554a0b74e7341841f318be21e895339c](https://github.com/Yelp/detect-secrets/blob/5e141933554a0b74e7341841f318be21e895339c/README.md), opened 2026-11-03.
- **Why this adds value:** The first queue covered lifecycle auditing and an explicit-exposure API. This source adds a different question: how detector rules, exclusions and baselines affect what is reported. It separates baseline creation, hooks for new findings and manual classification. Its README also describes network-backed verification, so detection and permission to check a credential must not be conflated.
- **Read precisely:** README sections Usage, Configuration → Plugins/Filters, Inline Allowlisting, and the scan/hook verification-option descriptions. Compare the stated behavior of a saved baseline with the currently selected plugins rather than treating a quiet result as coverage.
- **Currency:** GitHub identifies v1.5.0 as the latest release, published 2024-05-06. The reading pin is a separately verified default-branch commit, not a claim that a new release shipped or that the tool is installed.
- **License:** [Apache-2.0 at the reading pin](https://github.com/Yelp/detect-secrets/blob/5e141933554a0b74e7341841f318be21e895339c/LICENSE). This note includes no copied code or source prose.

## A useful future question, not an execution plan

Could a detector's apparent success be explained entirely by its exclusions or saved baseline?

For a later paper-only review, define an original matrix using invented labels, not credential-shaped values: detected/ignored, baseline/new, classified/unclassified, and network verification disabled/unknown. Require each hypothetical result to name which layer produced it. A masked report or detector miss must never become a claim that real secrets are absent or revoked.

The project can perform verification network calls and audit reports can expose findings. Do not run its quickstart against this lane, user files or any real repository as part of curation. Any later experiment needs its own approved scope and a strictly synthetic, no-network design; a flag alone is not an isolation guarantee.

## Duplicate and boundary checks

The nine public considerthese notes on the curation branch were checked, including the first source queue. They contain no Yelp/detect-secrets link or project mention. Earlier reflections already discuss scanners and validity checks, so this is a new implementation reference, not a claim that detection is a new domain.

Full-corpus duplicate checking remains unperformed under the existing hold. This candidate neither releases that hold nor resumes any refused work. Future licensing, dependency review, execution authority and secret-handling permissions remain separate decisions.
