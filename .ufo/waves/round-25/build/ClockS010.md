# ClockS010 — C3 per-row release clock for S010

Seat KagiR25.ClockS010-2 · base 4587c61a348e4528717404a68912c373f3ef4d03 · observed_at 2026-10-21 · lane read-only (only this file written); experiments in /fast/scratch/kagi-r25/ClockS010 (sandbox clone of BASE).

## Correction (after ClockS016-2 IRC)
An earlier draft took Atom `<updated>` as the publish time. It is not. For SOPS, `<updated>` runs +57 s to +123 s after `published_at` on eight entries and +42969 s (about 12 h) on v3.12.1. Publish times below come from the tag-page release header (datetime after "released this"). That equals API `published_at` on all five releases checked (v3.12.1, v3.13.0–v3.13.3). The verdict is unchanged. The feed route is now `/releases/latest` (302), which needs no module-tag or prerelease filter.

## Verdict
- Governing identity: (a) SOPS latest release (getsops/sops). S010's recheck is `on-release`, and its trigger names "a SOPS release" (corpus/knowledge/sops-age-key-rotation.md:5). The page is unversioned, but the teaches is SOPS behaviour. (b) rendered-quote rejected: it proves presence only (.ufo/waves/round-25/build/CritC3.md:7).
- Feed: https://github.com/getsops/sops/releases/latest → 302 → …/releases/tag/v3.13.3 (no API quota).
- Anchored version: **v3.13.0**, derived. S010's anchor names no SOPS version (SOURCES.md:16: "§Key groups; last modified 2026-05-15, docs commit 9b7b84e…"). v3.13.0 is the newest release published on or before 2026-05-15 (published 2026-05-08T18:10:42Z).
- Observed: **v3.13.3**, published 2026-07-23T05:27:57Z. The tag page shows "v3.13.3 Latest" and "47 commits to main since this release", so unreleased work is pending.
- Verdict: **fired**. v3.13.1 (published 2026-05-16T14:32:59Z), v3.13.2 (2026-06-30T05:17:22Z) and v3.13.3 all postdate the anchor. The boundary is not close: v3.13.0 is a week before 2026-05-15 and v3.13.1 a day after.
- Re-verification: the teaches **still holds** on v3.13.3 and matches v3.13.0 (below). No S010 text change is needed. The re-verification is recorded here, not silently re-pinned.

## Fetch evidence (curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)')
- S010 page https://getsops.io/docs/usage/identities/key-groups/: HTTP 200, no redirect, wire 8344 B (br), decoded 36366 B, sha256 fed6b2e1…2192e (= registry fetch sha and source-fetches.tsv:63). Rechecked 2026-10-21, latest at 10:58Z: same decoded sha, quote count=1, wire size varies (8379 B). The SOPS redirect at 10:58Z still points to v3.13.3.
- rendered-text-v1 digest d1ef84f1…50a9a4 (= TSV col 15). `locate` "keys from multiple groups are required to decrypt a file." → count=1. `locate` "By default, the threshold is set to the number of key groups." → count=1.
- Footer, normalized: "Last modified May 15, 2026: Add page descriptions. (9b7b84e)". Page text, normalized (tag replacement leaves the spaces): "The threshold ( shamir_threshold ) is set to 2, so this configuration will require master keys from two of the three different key groups".
- Redirect capture https://github.com/getsops/sops/releases/latest (followed): HTTP 200, final …/releases/tag/v3.13.3, raw 220181 B, sha256 872d0377…8c37 (volatile: a 10:4x capture differed, sha 85172557…). rendered-text-v1 normalized sha256 8bc419ca…d134, 7871 B. `locate` "v3.13.3 Latest" → count=1 (lane rendered-text-v1.py, exit 0). Release-header datetime 2026-07-23T05:27:57Z.
- Atom https://github.com/getsops/sops/releases.atom (rechecked 2026-10-21, sha 47a224ad…ff6): not a publish-time source (see Correction). All ten entries have plain `vX.Y.Z` titles. v3.12.0 is in the Atom feed but not in the API list, and its tag page has no release header. No verdict uses it.
- api.github.com (fetched 10:36Z, before the quota ran out): releases/latest HTTP 200, sha256 d96c4282…c693, tag v3.13.3, published_at 2026-07-23T05:27:57Z. Quota is now exhausted per peer ClockS016-2 (HTTP 403, reset 11:25:01Z); peer-reported, not re-verified by me.
- Revisions (`git ls-remote --tags`): v3.13.0 → 7fe6e4c2… (tag object), v3.13.3 → 3be48d73…. Commit of v3.13.0: af88df5c… (partial clone). Docs commit 9b7b84e… is absent from getsops/sops (`bad object`, `upload-pack: not our ref`), so the docs live in another repo and the anchor is date-derived.

## Atom `<updated>` vs publish time (SOPS, computed from the captures)
- Atom − API published_at: +57 s to +123 s on eight entries (v3.13.3 +74, v3.13.2 +57, v3.13.1 +58, v3.13.0 +77, v3.12.2 +62, v3.11.0 +57, v3.10.2 +91, v3.10.1 +123); v3.12.1 +42969 s.
- Tag-page release datetime = API published_at on v3.12.1 and v3.13.0–v3.13.3 (5 of 5).

## Behaviour check (sandbox; throwaway age identities; HOME=sandbox; SOPS_AGE_KEY_FILE only)
- Binaries: sops v3.13.0 (f2e5ed5e…0157) and v3.13.3 (e5bec334…fef6), official release assets; sha256 equal to each release's checksums.txt (`sops-v3.13.3.linux.amd64: OK`). `sops --version` → 3.13.0 and 3.13.3.
- Matrix: 2-group default; 3-group default; 3-group `shamir_threshold: 2`; 3-group CLI `--shamir-secret-sharing-threshold 2`. 26 of 26 decrypt checks match on both versions (MISMATCHES=0). Failures are rc=128 "Failed to get the data key required to decrypt the SOPS file."
- Default threshold equals the number of groups: 2-of-2 needs both; 3-of-3 needs all three. Configured 2-of-3 (config and CLI) decrypts from the tested pairs A+B and B+C; A alone fails.
- Not claimed by S010: threshold 1 is refused on both versions ("threshold must be at least 2", rc=1). The normalized page states no minimum.
- Release notes (per-entry parse of the Atom bodies): v3.13.0–v3.13.3 have 0 hits for key group|threshold|shamir. v3.11.0 (2025-09-28) has 3 hits; it predates the anchor.

## S010 teaches (SOURCES.md:16): still holds
"Key groups split a file's data key into fragments and require a configured threshold of groups." The quote still locates in the fresh page, and behaviour agrees on v3.13.0 and v3.13.3. The knowledge file's threshold line (sops-age-key-rotation.md:46) also matches.

## Proposed corpus/release-clocks.tsv line (TAB-separated; canonical 9 columns, build-spec.json XReleaseClock)
S010	feed	S033	https://github.com/getsops/sops/releases/latest	v3.13.0	v3.13.3	2026-10-21	fired	anchor v3.13.0 needs S010 anchor amendment (Handoff 4); publish 2026-07-23T05:27:57Z from tag-page datetime (= API published_at); re-verified 2026-10-21: teaches holds (26/26 matrix v3.13.0 and v3.13.3; quote located)

- S033 is a placeholder id (Handoff 1). Spec checker: fired iff observed_version != anchored_version; the publish-date guard (publish after 2026-05-15) also holds here.
- Publish-time rule: datetime attribute of the first `<relative-time>` preceded by "released this" on the tag page, never Atom `<updated>`.

## SOURCES candidate S033 (census-tested in sandbox; L1 renumbers)
| S033 | SOPS latest release, GitHub redirect (getsops/sops) — https://github.com/getsops/sops/releases/latest | code | A | Latest SOPS release tag and publish time as the release clock for S010 (S009 and S011 share its anchor text) | redirect target releases/tag/v3.13.3; tag-page release datetime 2026-07-23T05:27:57Z (equals API published_at); opened 2026-10-21 | The latest SOPS release is the redirect target (v3.13.3, published 2026-07-23T05:27:57Z); S010's clock anchors to v3.13.0 (published 2026-05-08T18:10:42Z, the newest release on or before its 2026-05-15 last-modified date) and fires on later releases such as v3.13.1 (published 2026-05-16T14:32:59Z). Quote: “v3.13.3 Latest” (tag page visible text). | mined | 2026-10-21 | 90d | corpus/lessons/round-25.md |

Quote “v3.13.3 Latest” is visible tag-page text (count=1 under rendered-text-v1). Tier A: the maintainers' official getsops org, via GitHub's own redirect. recheck 90d, not on-release, to avoid a clock for the clock. No in-row `Fetch sha256:`: a post-S016 in-row pin needs an inrow-pins classification (SC_INROW).

## source-fetches.tsv candidate row (16 TAB-separated fields)
S033	mined	2b7bbaaee6c4120ecf9c28611c725dc38c5c88fc670c92bdd86954d9675a8f8a	https://github.com/getsops/sops/releases/latest	https://github.com/getsops/sops/releases/tag/v3.13.3	200	curl-fsSL-compressed-v1	2026-10-21	decoded-http-body-volatile-v1	872d0377451e02c3e6c5cd8c9f0f0136a63299212bf3cf5fee271c191e8f8c37	220181	-	v3.13.3 Latest	rendered-text-v1	8bc419cae0ca5c774f06ad770cb3adcabb9b3ba7c94864f64cf5352dacd5d134	release header and Latest badge

## Census (sandbox clone of BASE; the lane tree was not gated)
- Base: exit 0, `SOURCES_CENSUS: CLEAN (rows=32 A=30 … mined=29 … captures=32 …)`.
- Candidate (redirect-route S033 row + fetch row + release-clocks.tsv + lesson stub `source: S033`): exit 0, `CLEAN (rows=33 A=31 … mined=30 … captures=33 …)`, zero FINDING lines. Field widths 16 and 8; row identity digest matches.
- Earlier attempts: used-by `corpus/release-clocks.tsv` → `SC_USEDBY_MISSING` (used-by must be `corpus/(knowledge|lessons)/<name>.md`, sources-census.sh:35-38). The Atom-based row was CLEAN and is superseded.

## Handoff to L1 (planner)
1. Id collision: S033 is claimed by at least eleven seats for different feeds (ClockS005, S011, S013, S014, S015, S022, S025, S026, S029, S031, RCensusRecheck, plus this seat). Assign distinct ids at integration. ClockS011 and RCensusRecheck propose the same SOPS feed, so one SOPS row should serve S009, S010 and S011.
2. Integrate the SOPS row, its fetch row, and the TSV line(s), one per on-release row sharing that feed_row. Create corpus/lessons/round-25.md with a `source:` line naming the feed id. The sandbox stub is not for merge.
3. Record the S010 fired re-verification in that lesson (feed entries, page digests, matrix result). Keep anchored v3.13.0 in the TSV. Any re-pin to v3.13.3 is a recorded decision.
4. Required decision: S010's anchor names no SOPS version, so under the spec anchored_version is `-` and S010 cannot bind. Amend the S010 anchor to name "SOPS v3.13.0", the newest release on or before its stated content date (2026-05-15 last-modified). Use one date rule for all rows: the newest release on or before the page's stated content date, or the capture date where no date is stated, and say which. ClockS016's exact-verified-tag rule cannot apply to S010: the page names no version, and its docs commit 9b7b84e is absent from getsops/sops. Do not bind S010 until this is made.
5. Bind clocks to `/releases/latest` (302, no quota) plus the tag-page release datetime. Do not use api.github.com (quota exhausted for this IP) or Atom `<updated>`.
6. source-fetches.tsv:15 shows a round-23 UA example; captures used the round-25 UA the contract prescribes. Align the header wording.
7. Observed, not mine: corpus/__pycache__/rendered-text-v1.cpython-314.pyc (mtime 10:38:17Z) appeared during this session as an untracked file. My commands ran the normalizer as __main__ or with `python3 -B`, which write no bytecode, so another process imported it. .gitignore has no pycache rule. Clear it or add the rule.
8. Schema: the canonical columns are id, clock, feed_source_id, feed_url, anchored_version, observed_version, observed_at, verdict, note (build-spec.json XReleaseClock). ClockS016 has adopted them. At my last check about a dozen seats' lines used the 7-column form. Normalize every line at integration; ClockS006's 9-field line already conforms.

## Tooling and installs (recorded per operator directive)
- pyrage 1.4.0: `uv venv` + `uv pip install pyrage` in the sandbox venv (PyPI, channel uv, reason: throwaway age identities). Sandbox only. uv 0.13.0 pre-existing.
- sops v3.13.0 and v3.13.3 linux/amd64: official GitHub release assets, sha256-verified against checksums.txt. Sandbox only, not on PATH or in ~/.local/bin.
- git partial clone (`--filter=tree:0`) of getsops/sops in the sandbox, for lookups only.
- No pacman, no host config change, no credential or vault access. Throwaway identities deleted after the run.

## UNRUN
- release-clock.py, `--observe`, c3-measure.py, mutation controls: not on disk, not run.
- sops v3.13.1 and v3.13.2 binaries: release notes only.
- Sigstore bundles for the checksums not verified (cosign absent).
- Census `verify` on the lane tree: not run (forbidden); sandbox clone only.
