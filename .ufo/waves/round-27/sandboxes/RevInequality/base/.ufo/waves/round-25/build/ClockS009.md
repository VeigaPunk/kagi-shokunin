# ClockS009 — S009 per-row release clock (C3)

Seat: KagiR25.ClockS009-2 (leaf scout). Base 4587c61a348e4528717404a68912c373f3ef4d03. Access date 2026-10-21.
Sandbox: /fast/scratch/kagi-r25/ClockS009-2 (lane clone at BASE; lane tree not touched). Re-checks ran under `env -i PATH=/usr/bin:/bin HOME=<sandbox>/home`.

## Verdict
- Governing identity: SOPS release line (official feed), not the docs page. Clock: `feed`.
- Anchored version: v3.13.0. Derived, not named: the S009 anchor names no SOPS version. v3.13.0 (published 2026-05-08) is the latest release at its docs revision (2026-05-15).
- Observed: v3.13.3 (published 2026-07-23T05:27:57Z). **FIRED**: v3.13.1 (2026-05-16), v3.13.2 (2026-06-30) and v3.13.3 all follow the anchor.
- S009 teaches: **still holds** on v3.13.3 (static re-verification; behavioural run UNRUN). Not re-pinned.

## Why feed, not rendered-quote
1. The page shows no SOPS version. Its only identity is the footer "Last modified May 15, 2026: Add page descriptions. (9b7b84e)".
2. The teaching (`updatekeys` recipient sync, age identity lookup) is SOPS CLI behaviour. It changes only with a SOPS release.
3. Counterexample to rendered-quote: v3.13.1 changed the GPG-agent cache for age key passwords (release body, PR 2180) while the page stayed byte-identical (decoded sha256 a840727e…). A rendered-quote clock would report "located, not fired" across three SOPS releases.
4. The knowledge file already names this trigger: corpus/knowledge/sops-age-key-rotation.md:5 ("on a SOPS release or a change to the pages' 'Last modified' footer").
5. Docs-side trigger not fired: getsops/docs path history for content/en/docs/usage/identities/age/_index.md is newest-first 9b7b84e, 7fffe3e; main head 3aa2b69 (2026-10-14).

## Fetch evidence (2026-10-21)
- `curl -fsSL --compressed -A 'kagi-shokunin-round25/1.0 (documentation verification)' https://getsops.io/docs/usage/identities/age/` → exit 0, HTTP 200, final URL unchanged. Decoded body sha256 a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76, 29301 bytes. Matches source-fetches.tsv:62 cols 10–11 (also under env -i).
- `python3 lane/corpus/rendered-text-v1.py digest` → exit 0, normalized_sha256 189d5ba9145e71f4a41dae10a42b9176fa660c58f3df5cb2774a145d11728d95, 3570 bytes. Matches col 15.
- `… locate` rendered quote "It is also possible to use updatekeys , when adding or removing age recipients." → count=1, exit 0.
- `… locate` SOURCES.md markdown form (with backticks) → count=0, exit 1.
- `… --selftest` → RENDERED_TEXT_V1_SELFTEST: PASS (cases=22), exit 0.
- `curl … https://github.com/getsops/sops/releases.atom` → HTTP 200, sha256 47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6 (identical on re-fetch). Feed title "Release notes from sops"; 10 entries; newest "v3.13.3" updated 2026-07-23T05:29:11Z.
- API (captured before quota exhaustion): releases/latest → 200, sha256 d96c4282…, tag_name v3.13.3, published_at 2026-07-23T05:27:57Z, prerelease false. releases?per_page=30 → 200, sha256 a011d0be…, 30 entries.
- `curl … https://api.github.com/rate_limit` → 200: core limit 60, remaining 0, used 60, reset 1792581901 (= 2026-10-21T11:25:01Z). Later API calls returned 403.
- `git clone --depth 1 --branch v3.13.3 https://github.com/getsops/sops.git` → exit 0. Tag object 3be48d73…; peeled commit 26e2f4784ca61353082c32dbd987c25eda086dc9. Warning "is not a commit!" printed (annotated tag), exit still 0.
- `git clone --filter=blob:none --no-checkout https://github.com/getsops/docs.git` → exit 0. `git log -1 9b7b84e…`: author_date 2026-05-15T19:05:01+02:00, committer_date 2026-06-23T22:04:48+02:00, "Add page descriptions."

## Proposed release-clocks.tsv line
Columns: id, clock, feed_url, anchored_version, observed_version, observed_at, verdict
S009	feed	https://github.com/getsops/sops/releases.atom	v3.13.0	v3.13.3	2026-10-21	fired

- Prerequisite: S009's anchor must name the version. Proposed amendment (planner decides): "§Encrypting using age; last modified 2026-05-15, docs commit 9b7b84e…; SOPS v3.13.0 in force at that revision". Without it the honest state is UNBOUND, not fired.
- Rejected alternative: `S009	rendered-quote	-	-	-	2026-10-21	located` (quote from source-fetches.tsv:62 col 13). It cannot see SOPS releases.
- Sensitivity: anchoring at the registry open date (2026-10-19) gives v3.13.3 and not-fired. The teaching verdict is unchanged.

## SOURCES candidate (proposed id S033; planner assigns)
S033 | SOPS release feed (Atom) — https://github.com/getsops/sops/releases.atom | feed | A | SOPS release identity (tag, update time) for on-release clocks of getsops.io docs rows S009–S011 | Entry 1 v3.13.3 updated 2026-07-23T05:29:11Z; entry 2 v3.13.2 updated 2026-06-30T05:18:19Z; opened 2026-10-21 | Each entry names a SOPS release tag with its update time; the newest entry is the current release identity. Quote: "Release notes from sops" (feed `<title>`); entry 1 `<title>v3.13.3</title>`. Fetch sha256 47a224ad71435b7f5cae863bc96c01468bfed482636045fc307430983b072ff6. | mined | 2026-10-21 | on-release | corpus/knowledge/sops-age-key-rotation.md

## Fired re-verification: what changed, does the claim hold
- Release side: v3.13.1, v3.13.2, v3.13.3 after the anchor. None of the three release bodies has an updatekeys, recipient or key-group line. Age-related lines: v3.13.1 "GPG agent for age key passwords: avoid percent-encoding of cache key…" (passphrase caching, not taught or on the page); v3.13.2 "test: unset all age env vars in make test target" (test only).
- Docs side: unchanged (same decoded body; no path commit after 9b7b84e).
- Page text on the new release, unchanged: "It is also possible to use updatekeys , when adding or removing age recipients." (s009-body.html:35, locate count=1). Also "setting the environment variable SOPS_AGE_KEY_FILE … SOPS_AGE_KEY … SOPS_AGE_KEY_CMD".
- Source at tag v3.13.3 (static reading):
  - cmd/sops/main.go:724-757: `updatekeys` subcommand; :754 calls UpdateKeys.
  - cmd/sops/subcommand/updatekeys/updatekeys.go:62-68 diffs key groups (Added/Removed); :83 prints "The following changes will be made to the file's groups:"; :105-107 sets KeyGroups = conf.KeyGroups and calls UpdateMasterKeysWithKeyServices; :124 "synced with new keys".
  - cmd/sops/common/common.go:404-446 Diff{Added,Removed}; :452-464 PrettyPrintDiffs.
  - age/keysource.go:29,32,35 env names SOPS_AGE_KEY / _FILE / _CMD; :48 "sops/age/keys.txt".

## S009 teaches verdict
Holds on v3.13.3: "Age recipients and identity lookup locations are documented; updatekeys can apply recipient additions/removals." Limits: static reading only; behavioural run UNRUN (no install this wave); per-OS default directories not re-read; release bodies are not a full changelog; "age is one MasterKey type" is inferred from code shape.
Side note (not a fire, pre-anchor): v3.13.0 "Allow to have space-separated keys in SOPS_AGE_KEY" (PR 2086) is absent from the page. A knowledge-file gap, not a teaching failure.

## C3 design findings
1. Feed binding needs the anchored version in the row. S009 names none. Require the TSV anchored_version to appear in the anchor cell, else UNBOUND.
2. api.github.com quota is 60/h per IP and was exhausted at 10:39 GMT (reset 11:25:01Z). An `--observe` on the API gets 403 for seats on that egress [INFERENCE: shared egress]. Use the releases.atom feed (no quota). Whether it includes pre-releases is UNVERIFIED (none in its 10 newest entries).
3. Backticked quotes never locate. Such quotes sit on on-release rows S009, S011, S012, S015 (corpus/SOURCES.md:15,17,18,21). The rendered-quote clock must read source-fetches.tsv col 13 (verified for S009 only).
4. "Last modified" is the git author date (2026-05-15), not the committer date (2026-06-23). Committer-date clocks mis-anchor.
5. Footer-only docs edits are invisible to rendered-quote. decoded-http-body-v1 rows already carry an exact page sha256 (source-fetches col 10). Flag to planner as a stronger unversioned-docs clock.
6. Annotated tags in shallow clones print "is not a commit!" with exit 0. Release tooling must not treat that warning as failure.
7. S010 and S011 share the same docs commit and SOPS feed; same decision expected, not assessed here.

## Bounds and tooling
- Installs: none. Public reads only: curl with the declared UA (no auth, no cookies), git clones into the sandbox.
- No gate run, no `--allow-host-rows`, no vault/account/CDP/op, no credential reads. Lane edits: none; this report is the only lane write.
- UNRUN: sops behavioural test; release-clock.py and self-counts (out of scope).
