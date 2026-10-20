# SafetyFixture — round 22

## Axis read

- **Calibration:** The planned C1 artifact is typed, not prose, and must adjudicate only its declared product/feature/status/eligibility/evidence relations. It must not admit an unrecognized field or silently default an omitted qualifier. A row count or schema pass is not decision calibration.
- **Freshness:** A new revision stamp proves bytes, not that the bytes contain no credential/session/reference material. The new JSON artifact must be inside an explicit privacy check; the existing source census does not give it that coverage.

## Findings

### MEDIUM — Planned typed-claim JSON is outside the existing credential scan

**Exploit path.** The planned `corpus/feature-claims.json` carries source facts, quotes, URLs and digests. An author or copied source excerpt can place a sensitive value, session identifier, reference path, or credential-bearing URL in any free-text/unknown field. The current `sources-census.sh` checks `SOURCES.md` and sourced Markdown entries only; it neither traverses arbitrary corpus JSON nor validates such JSON. A clean source-census result would therefore not protect this input.

**Evidence.** `build-spec.json:214` assigns the typed JSON artifact and asks it to pin source facts/quotes/URLs/digests; `corpus/sources-census.sh:57-65,206-233` bounds the credential scan to the registry and sourced `corpus/knowledge/*.md` entries (legacy entries are also outside that scan); `corpus/QUALITY.md:24` and `corpus/README.md:12-13` prohibit credential, session and reference material in the corpus. No `corpus/feature-claims.*` file existed in the inspected tree.

**Impact.** If copied into the new artifact, private material can become durable repository content or be reflected in gate diagnostics. A fresh hash/stamp would pin the leak rather than detect it.

**Smallest remediation.** Give the new gate an explicit, offline validation boundary for the complete JSON document: reject duplicate keys, unknown keys/fields/sources, and values outside closed enums or exact pinned source records; avoid arbitrary notes/free text; accept only the planned public source URLs and bounded quotes. Reject URL userinfo/query credentials and never fetch input URLs. Add the typed JSON to the corpus privacy sweep or make the gate perform the same complete scan. Diagnostics must report only a stable finding ID and field/record locator, never the submitted value.

### MEDIUM — Existing transcript selftest persists a reference-shaped fixture literal

**Exploit path.** A maintainer copies the existing seeded transcript fixture into a new test or review artifact as the convenient example of a detected reference. This normalizes a durable reference-shaped path in corpus source despite the corpus-wide hygiene rule. The inspected fixture is explicitly fake; no live secret or real account/session data was observed.

**Evidence.** `corpus/transcript-scan.sh:16-19,202,242` documents and seeds synthetic reference-shaped rows in its selftest; line 202 also uses a session-shaped test label. The corpus rules in `corpus/lessons/round-1.md:32-35` and `corpus/QUALITY.md:24` prohibit persisting reference paths/session IDs, including examples. As a safer existing pattern, `corpus/sources-census.sh:67-71,107-115,289-300` assembles detector needles from fragments, stages mutations under `mktemp`, and at line 435 verifies the needle is absent from output.

**Impact.** No current credential compromise is evidenced; the issue is a durable test fixture that weakens the corpus's stated no-reference/no-session-material invariant and is easy to propagate into C1 fixtures.

**Smallest remediation.** Do not copy the literal into `feature-claims.json` or other durable examples. For any detector regression that requires a matching shape, construct a non-secret synthetic canary only inside a disposable scratch fixture, assert that neither stdout nor stderr contains the canary, and remove the scratch tree. Prefer neutral test identifiers over session-shaped labels.

## Attack cases parent should apply (not run in this review)

1. **Every string sink:** In scratch-only inputs, place a harmless generated canary separately in a quote, URL, note, nested value and unknown field. Require the documented non-clean/cannot-evaluate result and a stable finding ID; assert the canary never appears in stdout, stderr, exception text or generated review output. Never use a real credential, account/session value, vendor example credential, or actual vault/item/field path.
2. **Closed-schema and parser ambiguity:** Unknown top-level and nested keys (including credential/session/reference field names), unknown source/feature IDs, duplicate JSON keys in both orders, missing qualifiers, wrong JSON types, and extra array/object nesting must all fail closed. No duplicate-key last-value-wins behavior and no fallback/default eligibility or status.
3. **Encoded and multiline input:** Repeat the canary as escaped JSON text, with CR/LF, case changes, whitespace/control characters and Unicode lookalikes. Either reject the whole value/record under the closed schema or prove the raw-value detector catches it; do not log the decoded text. A better design is to eliminate arbitrary strings rather than rely on an incomplete secret-pattern blacklist.
4. **URL/quote boundary:** A non-allowlisted URL, a URL with userinfo or credential-bearing query/fragment, and a quote with injected extra text must be rejected without network access and without echoing the value. Valid controls should use only exact pinned public-source records and bounded source excerpts.
5. **No laundering through test expectations:** Expected decisions must be independent literals/source-bound controls, not copied from the gate's own parser output. Require known bad C1 cases to fail while valid bounded controls pass; report decision correctness/misses/false admissions, not the number of fixtures.
6. **C2 scratch/data boundary:** Historical stamp fixtures and migration examples should use synthetic repo-relative names and synthetic digests/counts only. No host-private paths, source contents, session identifiers or reference paths; malformed/rejected rows must not be reflected in diagnostics. A new stamp or expected-output update alone is not a privacy check.
7. **Fixture cleanup/isolation:** Selftests should create any generated canary only under their own temporary root, never invoke `op`, the handler, a live account/vault, a network fetch, or host-private data, and verify cleanup and absence of canary output on both success and rejection paths.

## Scope and evidence limits

Read-only review of the Kagi corpus and the round-22 build specification at Git `HEAD` `c2cab35bc92e57e39e5489bac3386db078345b3f`. The relevant inspected file digests were:

- `corpus/QUALITY.md` — `3753d4fb28a0a934d08f721d0874f43d90b9f11a9158f8c9f4e86a8cfae6dccd`
- `corpus/README.md` — `6837d22b1e14a1ace6956f74e2f02c5c171039e03f2a6ba7658334a3c6614c6d`
- `corpus/transcript-scan.sh` — `2d60981b198cef41b9263a1427b41f92d98b65eb26ff71c28057bea0ad823a23`
- `corpus/sources-census.sh` — `03fb300a74157232978525c6bc4b028d7ed9159bccbb47d32333deb48ba76b3c`
- `corpus/claim-ledger.sh` — `93c5827202b9cdecd6874e75c5dac5281eeae07eddeeff3883bd0da14bfbcd29`
- `.ufo/waves/round-22/build-spec.json` — `631385b7392b4c55f3044118f2fc88898b49e7fcd4c0076b1c2dab7261ba341e`

The worktree's `QUALITY.md` changed during the audit; the digest above identifies the final bytes reviewed. The C1/C2 implementation was not present in `corpus` at inspection time, so findings about it are prospective, not a verdict on the builder's private clone. No tests/builds, live targets, host-private files, credentials, vault/account operations, or external pages were accessed. A scoped search found no Kagi `resume_continuity_v1` implementation or rejection path; historical/report/template mentions elsewhere in the parent project do not establish runtime behavior. This review therefore makes no runtime zero-mutation claim.

**Parent checks after integration:** add/run C1 `feature-claims.py --selftest`, C2 `revision-audit.py --selftest`, and the full local corpus privacy scan including the new JSON and scratch-only rejection/output-suppression cases. Do not treat those checks as exercised by this report.