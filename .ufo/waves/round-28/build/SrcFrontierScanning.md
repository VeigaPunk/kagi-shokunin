# SrcFrontierScanning — round-28 source opening: GitHub secret scanning

Seat SrcFrontierScanning (leaf, no subagents). BASE `3553d499577084a6c98d7078906017840bbf7b28`, citations below are at that revision. Access date **2026-10-21**. No tool installs, no lane gate run in the lane checkout.

## Verdict

**ADMIT, tier A, bounded scope** — this is GitHub's own documentation of its own feature and it does state the detection-versus-validity distinction. It is **not** evidence about any other scanner and **not** mechanism authority; reject that use (finding 8).

## Findings

1. **Fetch.** Requested `https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning` → HTTP **301** (92 B, sha256 `64b8a5422c28ad61b0a4382afe1e3e1c2f8a8c5fda472151882e57478ab04db8`, `location: /en/code-security/concepts/secret-security/secret-scanning`). Followed → HTTP **200**, final URL `https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning`, `text/html; charset=utf-8`, **579,783 B**, sha256 `d3a6953dfa6f61512e7bf2bcc17804401eb3bd82bf25eb74731c4a5a27784c1a`, server `date: Wed, 21 Oct 2026 17:06:40 GMT`. A second fetch ~100 s later was byte-identical (`cmp` exit 0, same sha256). No `Content-Encoding`, so the digest is over the identity body. Artifacts: `.ufo/waves/round-28/sandboxes/SrcFrontierScanning/{body.html,body2.html,headers.txt,headers_final.txt,rendered.txt,receipt.json}`.

2. **Exact title.** H1 `Secret scanning` (`<h1 id="title-h1">`); document `<title>` is `Secret scanning - GitHub Docs`.

3. **Quote — 19 words, verbatim, unique in rendered text.** Locator **§Customizability → About validity checks** (`<h3 id="about-validity-checks">`, byte 448,979 of `body.html`; quote at byte 449,097; `rendered.txt:589`). Rendered-text occurrence count **1**; raw-body count 3 (1 HTML + 2 escaped JSON/RSC payloads), so a raw-byte grep locator would over-count — the row must declare the rendered count.
   > “Validity checks help you prioritize which secrets to remediate first by verifying whether a detected secret is still active.”
   This is the explicit split: detection happens automatically; validity checking is a separate, opt-in step that verifies whether a *detected* secret is still active. The following sentence (not quoted) adds that, when enabled, scanning may contact the secret's issuing service to learn whether the credential was revoked.

4. **Duplicate URL: none.** `grep -n -F 'docs.github.com' corpus/SOURCES.md` → exit **1** (no match); `grep -n -F 'concepts/secret-security' corpus/SOURCES.md` → exit **1**; `grep -c '^| S'` = 43 rows S001–S043, ids gapless. No new W04 duplicate (census baseline 11 W04, `.ufo/waves/round-28/census-start.txt:2-12`).

5. **CALIBRATION — the `recheck` cell is load-bearing for C1/C2's frozen control.** `release-clock.py` enumerates *every* SOURCES row whose recheck is `on-release` (`corpus/release-clock.py:509-512`) and requires exactly one clock binding per such row (`:529-532` emits `UNBOUND`; `:640` sets `passed` only when `bound == len(on_release)`). BASE is exactly 30/30 (`corpus/release-clocks.tsv` = header + 30 rows; all 30 `on-release` rows bound, no `90d`/`180d` row bound). Hence a new registry row **must use `90d`** (like S042/S043, `corpus/SOURCES.md:49-50`) or the plan's frozen control `on_release=30 bound=30 unbound=0` (`plans/round-28.md:37,42-43`) breaks. **Observed in sandbox copies of BASE, default command, no `--observe`, no network:**
   - S044 with `on-release` → `UNBOUND S044` + `RELEASE_CLOCK: FAILED (on_release=31 bound=30 unbound=1 observed=30 fired=3 derived=15)`, exit **1**.
   - S044 with `90d` → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit **0** (frozen control string preserved).
   S044 must also never be a clock `feed_source_id`: `docs` is in `FEED_KINDS` (`corpus/release-clock.py:358`) and a `90d` row passes the `on-release` guard (`:559-560`), so the kind check would admit it and the anchor check would then fail; it publishes no release stream and its anchor names no version.

6. **Locator defects to record.** (a) The routed URL is a permanent redirect — put the **final** URL in the source cell and note the alias in the anchor cell, or every recheck pays a 301. (b) `og:url` is `https://docs-internal.github.com/...` (byte 2,661) and there is **no** `<link rel="canonical">`; do not use `og:url` as the locator. (c) No displayed version or date (`datePublished`, `dateModified`, `Last updated` all absent); the page is live, unversioned vendor documentation.

7. **Census blind spot (small, real).** W04 compares URL strings; the alias and the final URL are different strings, so two rows for the same page (one per URL) would not raise the warning. If a sibling admits `/introduction/about-secret-scanning`, dedupe manually.

8. **Lead boundary.** The open lead is "TruffleHog discovery-versus-verification behavior — lead only, not evidence" (`corpus/SOURCES.md:82`; Gitleaks at `:81`). This page is first-party GitHub documentation and does not address TruffleHog. **REJECT condition:** if the round-28 lesson needs scanner-independent verification semantics, or mechanism detail (which secret types, partner vs non-partner, check frequency, alert lifecycle, per-secret outcome), this page must not be cited; it defers those to `/en/code-security/concepts/secret-security/validity-checks`, which I did not open.

## Proposed registry row

Insert after `corpus/SOURCES.md:50` (S043). 11 pipe-separated cells, no `|` inside any cell; `corpus/release-clock.py:78-80` rejects any row with a different field count.

```md
| S044 | Secret scanning, concept overview — https://docs.github.com/en/code-security/concepts/secret-security/secret-scanning | docs | A | GitHub Secret Protection's concept-level distinction between automatic secret detection and opt-in validity checks; GitHub-only, no mechanism, no third-party scanner behavior | §Customizability → About validity checks (#about-validity-checks); H1 Secret scanning; no displayed version/date on the page as served 2026-10-21; requested /introduction/about-secret-scanning 301s here | When enabled, validity checks verify whether a detected secret is still active and may contact the secret's issuing service to learn whether the credential was revoked; overview only — mechanics are deferred to /concepts/secret-security/validity-checks, and no per-secret result or other vendor's discovery/verification split follows. Quote: “Validity checks help you prioritize which secrets to remediate first by verifying whether a detected secret is still active.” (§About validity checks, rendered text, count 1). | mined | 2026-10-21 | 90d | corpus/lessons/round-28.md |
```

Optional, per S001–S026 precedent, append `Fetch sha256: \`d3a6953dfa6f61512e7bf2bcc17804401eb3bd82bf25eb74731c4a5a27784c1a\`.` to the teaches cell; the round-27 rows S042/S043 omit the digest, so either matches a precedent. `teaches` is written for a page whose only claim is the distinction; do not widen it. Status `mined` is conditional on `corpus/lessons/round-28.md` actually citing S044; otherwise `queued`.

## Proposed search-log line (round 28)

> Round 28 (2026-10-21). Question — does GitHub's own secret-scanning documentation ground a detection-versus-validity distinction? Where searched — the routed URL only (requested `/introduction/about-secret-scanning`, 301 to `/concepts/secret-security/secret-scanning`). Identified 1, screened 1, included 1 (S044), excluded 0. Not opened: the linked `/concepts/secret-security/validity-checks` mechanism page and the secret-types page. Stop: one located sentence asserts the distinction; mechanism, secret-type coverage and per-secret outcomes stay leads, and S044 is not a release feed and carries no clock binding.

## Commands run

- `curl -sS -D headers.txt -o raw.html -w ...` requested URL → HTTP 301, 92 B, exit **0**.
- `curl -sSL -D headers_final.txt -o body.html ...` → HTTP 200, `REDIRECTS 1`, 579,783 B, exit **0**; `sha256sum` → `d3a6953d…`.
- `curl -sSL -o body2.html ...` refetch → 579,783 B, exit **0**; `cmp -s body.html body2.html` → **0**.
- `grep -n -F 'docs.github.com' corpus/SOURCES.md` → **1**; `grep -n -F 'concepts/secret-security' corpus/SOURCES.md` → **1**; `grep -n -F 'about-secret-scanning' corpus/SOURCES.md` → **1**.
- `git archive 3553d499… | tar -x -C .../base` → **0**; `cp -a base trial-onrelease|trial-90d`; row inserted after S043.
- `python3 -I -B trial-onrelease/corpus/release-clock.py --root trial-onrelease` → `UNBOUND S044`, `RELEASE_CLOCK: FAILED (on_release=31 bound=30 unbound=1 observed=30 fired=3 derived=15)`, exit **1**.
- `python3 -I -B trial-90d/corpus/release-clock.py --root trial-90d` → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit **0**.
- Parses of `corpus/SOURCES.md` / `corpus/release-clocks.tsv` (row counts, recheck histogram, binding set difference) in plain Python → 43 rows, 30 `on-release`, 30 bindings, exact match, exit **0**.

## Not checked

- The linked `/en/code-security/concepts/secret-security/validity-checks` mechanism page, the secret-types/supported-patterns pages, and any partner-program page — unopened.
- The historical content/title of the pre-redirect URL; only the 301 was observed.
- Whether docs.github.com serves an alternate markdown-body API or locale variants with different bytes.
- `robots.txt`/ToS terms for re-fetch cadence, and any authenticated/plan-dependent rendering.
- No `kagi` census or lane selftest was run (contract: not in the lane checkout); W04 counts are read from `census-start.txt`, and the duplicate-URL answer is grep-based.
- No check that L1 will use id S044 vs another seat's id; `S044` is the next free id at BASE (S001–S043, gapless).
