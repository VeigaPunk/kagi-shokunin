# ClockS011 — S011 on-release clock (C3)

Seat KagiR25.ClockS011-2 · date 2026-10-21 (UTC) · lane `kagi-shokunin` · revision: frozen BASE 4587c61a348e4528717404a68912c373f3ef4d03 (lane read-only, not re-resolved) · sandbox `/fast/scratch/kagi-r25/ClockS011` · installs/upgrades: none (curl, python3, sha256sum pre-existing) · no auth, no cookies sent, no lane edits.

## Verdict
- **Governing identity: (a) SOPS release feed.** S011 is `recheck: on-release`; its consumer `corpus/knowledge/sops-age-key-rotation.md:5` defines the trigger as "a SOPS release or a change to the pages' 'Last modified' footer (9b7b84e)". The rendered nav shows no version selector (S011.normalized.txt:1).
- **Anchored version: v3.13.3** [INFERENCE]: the row names no SOPS version. Derived as the newest SOPS release on or before the row's last verification (opened 2026-10-19, re-opened 2026-10-21 with pins reproduced). v3.13.3 was published 2026-07-23T05:27:57Z.
- **Observed 2026-10-21: v3.13.3 → not-fired.** Three independent sources agree (fetch evidence 7–8).
- **Footer trigger: not fired.** Rendered footer still reads "Last modified May 15, 2026: Add page descriptions. (9b7b84e)".
- **Teaches: still holds.** Pins unchanged; S011 stays `reproduces-raw`.

## Proposed `corpus/release-clocks.tsv` line (TAB-separated: id, clock, feed_url, anchored_version, observed_version, observed_at, verdict)
```
S011	feed	https://github.com/getsops/sops/releases.atom	v3.13.3	v3.13.3	2026-10-21	not-fired
```
- Feed URL is the Atom feed, not the REST URL the brief suggests: REST `releases/latest` returned 200 at 10:36:39Z, then 403 (quota exhausted, finding 3). Parse rule: first `<entry>`'s `<title>` (version) and `<updated>` (publish time).
- Fallback if the planner rejects a derived anchor: bind S011 to `rendered-quote` (quote locates, count=1; digest unchanged).
- Rejected alternative: footer date 2026-05-15 as anchor. Newest release then was v3.13.0 (2026-05-08), so v3.13.1–v3.13.3 would read "fired". Re-verification below covers that reading too: the claim still holds. Rejected because the clock measures releases after the last verification, which post-dates v3.13.3.

## SOURCES candidate (feed row; registry ends at S032 = SOURCES.md:38, so S033 is next free; planner confirms id)
```
| S033 | SOPS releases, GitHub release Atom feed — https://github.com/getsops/sops/releases.atom | release-feed | A | SOPS release identity (newest tag and publish time) for the on-release clock of S009–S011 | feed entry 1 `v3.13.3`, updated 2026-07-23T05:29:11Z (feed updated 2026-07-23T04:56:54Z); human page https://github.com/getsops/sops/releases/tag/v3.13.3 (HTTP 200); opened 2026-10-21 | Clock source only; teaches no mechanism. Quote: "<title>v3.13.3</title>" (releases.atom:12, entry 1). Fetch sha256: `47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6`. | mined | 2026-10-21 | per-observe | corpus/release-clocks.tsv |
```
Tier A: the getsops org is the SOPS maintainers' own release channel.

## Fetch evidence (2026-10-21 UTC)
1. `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' -D S011.headers -o S011.body -w '%{http_code}' https://getsops.io/docs/usage/key-management/` → 200, exit 0, wire 9328 B, decoded 33153 B, **sha256 d0ab8b201f1a…180c = pin** (source-fetches.tsv:64, inrow-pins.tsv:17). Netlify edge `age: 209552`, etag `ac822f49…-ssl-df`, date 10:37:07Z.
2. Cache-bust `?r25-cb=20261021`: 200, same sha, edge `age: 224320`. The query does not refresh the edge.
3. `rendered-text-v1.py digest` exit 0 → normalized **4a71dbc959fc…c536**, 5451 B = pin. `--selftest` exit 0, PASS (cases=22).
4. `locate` with the source-fetches plain quote: exit 0, **count=1**. With the SOURCES.md:17 quote (markdown backticks): exit 1, **count=0**.
5. Raw source `raw.githubusercontent.com/getsops/docs/main/content/en/docs/usage/key-management/_index.md`: 200, 5037 B, sha256 214d6685…4f47; the quote is verbatim at line 58.
6. Footer commit 9b7b84e lives in `getsops/docs`: `github.com/getsops/docs/commit/9b7b84e…` → 200. `api.github.com/repos/getsops/sops/commits/9b7b84e…` → 422 "No commit found for SHA".
7. REST `repos/getsops/sops/releases/latest` (10:36:39Z, 200, x-ratelimit-remaining 26): sha256 d96c4282…c693; tag v3.13.3, published 2026-07-23T05:27:57Z, prerelease false, draft false. REST `releases?per_page=15` (200, sha256 cf3a9f87…9940): v3.13.3 07-23, v3.13.2 06-30, v3.13.1 05-16, v3.13.0 05-08, v3.12.2 03-18 …; no prereleases.
8. Atom `github.com/getsops/sops/releases.atom` (10:39:36Z, 200, 253037 B, sha256 47a224ad…2ff6): feed updated 2026-07-23T04:56:54Z; entry 1 = v3.13.3. `github.com/getsops/sops/releases/latest` → 1 redirect → `/releases/tag/v3.13.3`, 200.
9. REST `repos/getsops/docs/commits/9b7b84e…` → 403 "API rate limit exceeded" (≈10:39Z). `/rate_limit`: core limit 60, remaining 0, reset 1792581901 = 2026-10-21T11:25:01Z.

## Teaches check: HOLDS
- Raw source and rendered text both carry: §Adding and removing keys (raw :7); §`updatekeys` command (:25); §`rotate` command (:48); "Use `updatekeys` if you want to add a key without rotating the data key." (:58); §Direct Editing, removed keys → rotate, "owners of the removed key may have add access to the data key in the past" (:68, :95–97); §Key Rotation (:99); §Rotating secrets after a key in a key group has been compromised: remove the key from the group, then `updatekeys`, then `rotate` (:114–125).
- Release notes after the anchor (v3.13.1, v3.13.2, v3.13.3): keyword scan (rotat|updatekeys|key group|recipient|compromis|data key) has no hits. Other hits are unrelated: "GPG agent for age key passwords…" (v3.13.1), "test: unset all age env vars…" (v3.13.2), container-image boilerplate.

## Operability and calibration findings
1. **Quote-form trap.** SOURCES.md's quote carries markdown backticks; rendered-text-v1 (steps 5–6 only) locates 0. A rendered-quote check must read the plain quote from source-fetches.tsv or strip markdown first; otherwise a false "missing".
2. **Anchor gap.** S011 names no version, so "the version the row's anchor names" is empty. `release-clock.py` needs an explicit derivation rule (newest release at last verification) or an `unanchored` class.
3. **Shared REST quota.** Unauthenticated REST is 60/h per egress IP, shared with other agents on this host [INFERENCE]: 200 at 10:36:39Z (remaining 26), 403 at ≈10:39Z. A 403 must record UNOBSERVED, never not-fired. Atom and `/releases/latest` returned 200 after the 403 and use no REST quota.
4. **Repo identity.** S011's footer commit is in `getsops/docs`, not `getsops/sops` (422 from the sops repo). Keep the docs-footer clock separate from the sops release clock; S011's anchor should name the repo.
5. **CDN lag.** Edge copies aged 58–62 h; etag unchanged; cache-bust ineffective. Raw `main` is the fresher origin for quote checks.

## Not run / out of scope
- `corpus/release-clock.py` and `.ufo/waves/round-25/tools/c3-measure.py` do not exist in the lane → UNRUN. No `--observe` receipt written; no lane file edited; no SOURCES row added (planner integrates S033).
- GitHub `Set-Cookie` headers in responses were not stored or re-sent (no `-b`/`-c`).
