# ClockS019 — round 26 C1 freshness, S019 (Credential Broker integration eligibility)

Seat: KagiR26.ClockS019 (leaf scout, no dispatch). Observed BASE `1bf3eec48d3761580ffd375c88143232485ae814` (`git rev-parse HEAD`; only `.ufo/waves/round-26/` and `plans/round-26.md` untracked). Access 2026-10-21T13:36:52Z. Writes: this file, plus fetch artifacts in `.ufo/waves/round-26/sandboxes/ClockS019/`. Production, the registry, and git were not touched.

## Bounded result
- **Clock not fired; teaching still holds.** The declared clock (`corpus/release-clocks.tsv:16`, `rendered-quote`, verdict `quote-located`) reproduces. The fresh HTML is byte-identical to the registered capture (`corpus/source-fetches.tsv:46`), and the declared quote locates with count=1.
- **Python 3.15.1 drift: not applicable to S019.** S019 is an unversioned 1Password guide with no Python dependency. The S027/S028 3.15.1 vs 3.15.0 comparison belongs to those seats. Nothing here bears on the round-25 receipt or the lone-clone INCOMPLETE/48. Both are left untouched.
- **Freshness is limited to what the clock checks.** The clock checks only the introduction quote. It cannot fire if the GitHub Actions requirements block changes (see counterexample 1).

## Fetch evidence (sandbox `.ufo/waves/round-26/sandboxes/ClockS019/`)
Fetch tools: curl 8.23.0 and Python 3.14.8. Each fetch ran as `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home curl -fsSL --compressed -A 'kagi-shokunin-round26/1.0 (documentation verification)'`.

- **F1. HTML, `https://www.1password.dev/brokered-access`, fetched twice.**
  - Both fetches: http=200, no redirect, wire 166493 B, decoded 1199447 B.
  - sha256 `67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312`, identical across both fetches. This equals `source-fetches.tsv:46` (sha256 and bytes columns) and round-25 E1.
  - Headers: `etag: W/"z6d2q9klrgppcp"` (same as round 25), `server: Vercel`, `x-vercel-cache: MISS`, `age: 46374`.
- **F2. Normalizer copy.** `rendered-text-v1.py` sandbox copy sha256 `7d6bfe81…dc7bf` equals `corpus/rendered-text-v1.py`. `--selftest` → `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`, exit 0.
- **F3. Digest.** `digest body1.html` → normalized_sha256 `f3861c172c370dd10ef8a9289857b0b59c5b07a9d16f2f7cf25aeb02738cc6e9`, normalized_bytes 6049. This equals `source-fetches.tsv:46` (normalized digest column).
- **F4. Markdown alternate, `https://www.1password.dev/brokered-access.md`.**
  - http=200, 6841 B, sha256 `b4de0ea02db016ecaab7fe033f47a3b74b158626bcafcb41074b9865450f91e3`.
  - This is the same hash as round-25 E6.
  - `last-modified` equals the response time, so it is a cache artifact and not a content date.
- **F5. JSON-LD.** `dateModified` is `2026-08-17T22:36:47.823Z` (2 occurrences), unchanged. The `<title>` still ends "(public preview)".
- **F6. Feed named in the clock note, `https://releases.1password.com/` (page 1 only).**
  - http=200, sha256 `0f06cb1f178f2f3f7cb3948b782213c1834cc8abf000958367ec4e33e5d6ab80`, the same hash as round-25 page 1.
  - Latest entry: "Updated to 8.12.42 on …".
  - Zero matches for `credential broker` or `brokered` on page 1. Pages 2–6 were not re-fetched.

## Quote locates (`python3 -B rendered-text-v1.py locate body1.html '<q>'`, case-sensitive)
| Quote (registry location) | count / exit |
|---|---|
| "administrators can set up a supported integration in their 1Password Business account" (clock quote, `source-fetches.tsv:46` col 13) | 1 / 0 |
| "Administrators can …" (case control) | 0 / 1 |
| "a supported integration in their 1Password Business account" (`feature-claims.json:154` S019-business) | 1 / 0 |
| "Your GitHub organization must be hosted on GitHub.com." (`:155` S019-github-com) | 1 / 0 |
| `:156` S019-enterprise-host, ASCII `aren't` | **0 / 1** |
| same with U+2019 `aren’t` | 1 / 0 |
| `:157` S019-free-private, ASCII `won't`, "organizations," | **0 / 1** |
| "your team won’t be able to use this integration for workflows in private repositories." (U+2019) | 1 / 0 |
| "The token value is your integration key" (S032 row, same URL; context only) | 2 / 0 |

## Is the teaching still true? (`SOURCES.md:25`)
- **"The guide-level preview label does not determine custom-workflow status": holds.**
  - The guide title and labels still say "(public preview)" (count=6 in rendered text).
  - The guide's own related link in the `.md` alternate, line 86, reads "…access secrets in custom workflows at runtime (public beta)".
  - Limit: "public beta" is absent from the rendered HTML text, which returns -1. The S018 page itself was not re-fetched, since that URL is outside this seat.
- **Business setup qualifier: holds.** The introduction quote locates (count=1).
- **GitHub.com and private-repository requirements are a separate qualifier block: holds.**
  - The rendered text reads: "Before you connect your 1Password Business account to your GitHub organization, review the following requirements: Your GitHub organization must be hosted on GitHub.com."
  - The full sentence is ≤25 words. Both exclusion clauses follow it, located in their U+2019 forms.
- **What does not apply to this row:** it has no version or feed to compare. The 1Password release index is a client/SDK feed and does not carry this page's text (F6). This is a feed limitation, not a teaching change.

## Actionable counterexamples (for L1; not live edits)
1. **The clock's blind spot is still open.**
   - `release-clock.py` checks rendered-quote rows only against `source-fetches.tsv` col 13 (`release-clock.py:130-150, 736-749`).
   - That quote sits in the introduction. A change to the GitHub Actions requirements, such as a new exclusion or lifting the Enterprise or Free limits, would leave S019 `quote-located`.
   - The bindings that would notice (`feature-claims.json:156-157`) do not locate in the HTML today, so they cannot serve as a tripwire as written either.
   - This was reported in round 25 (`.ufo/waves/round-25/build/ClockS019.md`, "Calibration defect"). At BASE it is unrepaired: `rg "aren.t currently supported|won.t be able" corpus` finds only the ASCII forms at `:156-157`.
2. **Correction to the round-25 diagnosis of `:157`; the historical report is not rewritten.**
   - The space in "organizations ," is authored in the source and is not only a tag artifact. The `.md` alternate line 37 has `[GitHub Free for organizations ](…)`, and the HTML anchor text is `GitHub Free for organizations <svg …`.
   - Any superseding quote should therefore use the clause after the comma, which locates (count=1), rather than editing in a space.
   - Round 25 also quoted the requirements lead-in ending with "requirements.". It actually ends with "requirements:", and the period form gives count=0.
3. **Not a drift: dating mismatch, unchanged from round 25.** `SOURCES.md:25` says "opened 2026-10-20" with recheck 2026-10-20. `release-clocks.tsv:16` and `source-fetches.tsv:46` carry 2026-10-21. This is not a clock fire.

## Proposed L1 action (advice only)
- Keep `release-clocks.tsv:16` at `quote-located` for 2026-10-21; the observation is reproduced.
- If L1 wants requirements coverage, add a new superseding quote row. Do not rewrite the existing one. Use the located U+2019 forms:
  - "GitHub organizations hosted on GitHub Enterprise Server or GitHub Enterprise Cloud with data residency aren’t currently supported." (17 words)
  - "your team won’t be able to use this integration for workflows in private repositories." (14 words)

## Scope inspected and unrun checks
- **Inspected:**
  - Rows `SOURCES.md:25`, `release-clocks.tsv:16`, `source-fetches.tsv:46`, and `feature-claims.json:146-170`.
  - `rendered-text-v1.py` and the rendered-quote paths in `release-clock.py`.
  - The round-25 S019 report.
  - Fetches F1, F4 and F6.
- **UNRUN:**
  - `release-clock.py` in any mode (counting is L1-only).
  - Gate `verify`/`cells`.
  - Pages 2–6 of the release index.
  - The S018 custom-workflow page.
- **Installs/updates:** none. Tools used: curl, python3, grep, rg, sha256sum.
