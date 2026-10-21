# XTagHistory — C1 false-positive probe: canonical version tokens vs real upstream releases

Seat: KagiR28.XTagHistory-7 · 2026-10-21 · BASE 3553d499577084a6c98d7078906017840bbf7b28.
Question: would the round-28 C1 canonical rule (no leading-zero in a multi-digit component,
≤3 components, ASCII digits only, bounded component length) ever refuse a real upstream
stable release on the five feeds the clock loads (SOURCES.md:39-43)?

## Answer

**No.** 0 counterexamples. Across complete tag histories (git ls-remote, sops 2015→2026,
vault, openbao 2023→2026) and all current release/feed entries, 1,291 names yielded 1,256
version tokens (BASE `corpus/release-clock.py:30-33` grammar): **0** leading-zero
components, **0** tokens with >3 components, **0** non-ASCII digits (incl. raw-name
Unicode-Nd scan), **0** components >9 digits (max seen: 3 digits, in `1.100.0-…`), **0**
near the 4300-digit int-limit. All 231 entries the current stable grammar accepts
(`release-clock.py:710-712`, max at `:760`) are canonical: sops 37, vault 158, openbao 28,
python.org 7, curl.se 1. The rule is safe on these feeds; it fires only on forged
anchors/observations (exactly the F1/F2 fixture class), never on upstream stable data.

## Findings

F1 (harness, mine, corrected): initial `git ls-remote | sed` peel failed to strip annotated
tags' `^{}` suffix (sed brace-escape quirk), inflating tag counts (92/663/240 vs true
49/489/218) and producing a FALSE "GitHub REST /tags is incomplete vs ls-remote" reading.
After Python-peel correction: REST `/tags` == ls-remote exactly for all three repos
(api_missing=0, api_only=0; `tags-api-deficit.txt`). `/tags --paginate` (gh 2.102.0) is
complete here; releases verified complete two independent ways (below). No GitHub-side
coverage defect remains. Lesson: peel suffixes off raw text, not with brace-escape seds.

F2 (upstream, no C1 impact): GitHub publishes some non-stable release objects with
`prerelease:false` — vault `ent-changelog-1.15.9/1.15.8/1.15.7/1.14.12/1.14.11`,
`v1.9.0-rc1`, openbao `v2.2.0-beta20250213` (all `{repo}-releases.txt`). The href/title
shape grammar (`release-clock.py:710-712`) excludes every one by shape, corroborating the
S034/S035 exclusion design; none is canonicalizable as stable identity.

F3 (observation): curl `/info` carries `git tag: curl-8_23_0` — invisible to VERSION_RE
(underscore not a dot separator), harmless since the clock reads only the `Version:` line
(`TEXT_VERSION_RE`, `release-clock.py:712,727`). Python feed carries `Python install
manager 26.4` (2-component) — already excluded by `STABLE_TITLE_RE`'s single-word prefix;
even if accepted it is canonical. Not defects; recorded so nobody "fixes" them into scope.

## Commands (all in sandbox, exit 0 unless noted)

- `gh api repos/{getsops/sops,hashicorp/vault,openbao/openbao}/{tags,releases} --paginate --slurp` ×6 → 0
- `curl -fsSL https://www.python.org/downloads/feed.rss -o raw/python-feed.rss` → 0
- `curl -fsSL https://curl.se/info -o raw/curl-info.txt` → 0 (352 B, `Version: 8.23.0`)
- `git ls-remote --tags https://github.com/<owner>/<repo>` ×3 → 0 (raw kept)
- Independent release count (urllib page loop, per_page=100 until short page) → 0:
  sops 38, vault 187, openbao 36 — equals `--paginate` results.
- `python3 -I -B census.py` (v1) → 0; `python3 -I -B` census-final → 0: names=1291,
  tokens=1256, violations=0, stable=231, stable_violating=0.
- BASE `corpus/release-clocks.tsv` scan: all 30 rows' anchored_version/observed_version
  already canonical → the C1 control run stays CLEAN; no lane-data false positive.
- Exclusions (38 release tags not matching stable shape): all `-rc/-rc.N/-beta…/-alpha…`
  plus `ent-changelog-*`; python feed excluded `3.16.0a1`, `3.15.0rc3`, install-manager.

Tooling: gh 2.102.0 (pre-installed, read-only API), git ls-remote, curl 8.23.0, system
python3. **No installs/updates performed**; pacman pause untouched.

## Evidence files (sandbox `.ufo/waves/round-28/sandboxes/XTagHistory/`)

`raw/` (6 API JSON + 2 fetches), `lsremote-*-raw.txt`, `lsremote-*-tags.txt`,
`{repo}-tags.txt` (API), `{repo}-releases.txt` (tag/flags/date), `tags-api-deficit.txt`
(final: zero deficit), `census-final.json` (full token/stable records), `census.py`.

## BASE citations

- `corpus/release-clock.py:30-33` VERSION_RE (anchor/observation token grammar, `[0-9]+`
  components, 2+, optional `[-+]suffix`); `:362-363` norm_version; `:366` NUMERIC_VERSION_RE;
  `:369-380` numeric_version — `int(part)` at `:380` is the 4300-digit ValueError site C1
  bounds; `:710-712` stable title/href/text grammars (exactly-3 numeric components only);
  `:715-760` parse_latest_version (max over int tuples at `:760`).
- `corpus/SOURCES.md:39-43` S033–S037 feed rows; `:49` S042 SemVer basis.

## What I did NOT check

- Full CPython historical listing (python.org/ftp) — only the rolling feed.rss window
  (11 items); pre-3.x zero-padded tokens, if any, are outside the clock's feed anyway.
- curl historical archive/changelogs and github.com/curl/curl tags — feed is curl.se/info.
- Non-GitHub mirrors/remotes; GitHub treated as origin per SOURCES.md rows.
- Release bodies/assets beyond tag_name/title/draft/prerelease/published_at.
- The future round-28 candidate implementation — I measured the BASE grammar plus the
  plan's stated rule, not built code; C1 patch seats own that verification.
- No labrat spawned (single-seat work; nothing needed one).
