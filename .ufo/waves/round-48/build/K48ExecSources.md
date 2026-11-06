# K48ExecSources — registry plumbing for S103 / S104

Seat: K48ExecSources (executor, leaf). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch master.
BASE `76da518`; frozen tree extracted from predeclaration amendment A1 `52991e5da64cbacaa724b28b407cf5765fd21b41`.
Judge axes touched: calibration (registry rows are the evidence the C2 readings rest on), operability (the trial pins the two binaries' release identity).
Nothing outside my write scope was modified: the lane's `corpus/`, `plans/`, `SCORECARD.md` and every registry row are untouched. All edits were made **in the scratch mirror**; the exact bytes to apply are saved under `build/K48ExecSources/`.

## What was produced

| id | source | kind/tier | status | used-by |
|---|---|---|---|---|
| S103 | SOPS release v3.13.3, GitHub release page — `https://github.com/getsops/sops/releases/tag/v3.13.3` | code / A | mined | `corpus/knowledge/sops-age-key-rotation.md` |
| S104 | age release v1.3.2, GitHub release page — `https://github.com/FiloSottile/age/releases/tag/v1.3.2` | code / A | mined | `corpus/knowledge/sops-age-key-rotation.md` |

S103 is confirmed the next free id: the highest row before this wave is S102 (`grep -o '^| S[0-9]*' corpus/SOURCES.md | tail` → S097…S102), and `grep -c '^| S103 '` returned 0 (rc=1) before the append.

Each row is an 11-column registry row (NF=13 under `FS='|'`, no `|` inside any cell — asserted in the generator) modelled on S033/S102, `recheck` `90d`, `verified-at` 2026-11-06. Each has a matching 16-column `corpus/source-fetches.tsv` row modelled on S099/S094, with column 3 recomputed as `sha256(printf 'S103\tmined\t<url>\n')`.

## Fetch provenance (exact)

`curl -sSL --compressed -A 'Mozilla/5.0'`, run 2026-11-06T20:20:27Z:

| id | HTTP | final URL | bytes | raw sha256 |
|---|---|---|---|---|
| S103 | 200 | `.../getsops/sops/releases/tag/v3.13.3` (no redirect) | 177586 | `8dbbadc01a2a4f4402073fdd38570181c352f8798e9db5ff3547e329c5981ba1` |
| S104 | 200 | `.../FiloSottile/age/releases/tag/v1.3.2` (no redirect) | 154312 | `652f8c81e8f4db3b62574a6d3e55b3117e63c310ea959b63647965c5ee20bc09` |

`rendered-text-v1` (`corpus/rendered-text-v1.py digest`):
- S103 normalized sha256 `9ea60ad68e5c90e3c94c03d4138a53e204cdcc051459ef0c105de6928c31ef53` (7688 bytes)
- S104 normalized sha256 `d9d15f4659bfc367b413ca5678dea8744a33c1b049ad6a47e442fa9253f9364b` (3512 bytes)

Quote location, both `RENDERED_TEXT_V1_LOCATE: count=1` (≥1 as required):
- S103 “Release v3.13.3 · getsops/sops · GitHub” — 6 words, rendered offset 0 (page title).
- S104 “v1.3.2 is a minor release with a wide range of fixes and hardening” — 13 words, rendered offset 2251 (release notes body).

Row-identity digests (column 3), recomputed independently:
- S103 `db9eea5d4dfa82c068f46570a6285fa7b345fb30dd2924e576dba9f9a601a8e2`
- S104 `da9d408cfc2d97263bcf07b8b3ff430c5ecdd1cf5db56a9e5857e3f3835f023c`

## Behaviour / corroboration

The release identities are not just page titles: the installed binaries the counter pins report them.
- `~/.local/bin/sops --version` → `sops 3.13.3 (latest)`; sha256 `e5bec334…7fef6b` (matches the pinned digest).
- `~/.local/bin/age-keygen --version` → `v1.3.2`; sha256 `0a0009db…37899` (matches the pinned digest).

So an S103/S104 citation can back the trial's version expectation without re-deriving it from the binary alone. Both pages carry the GitHub `Latest` badge and a release line (“released this 23 Jul 05:27” / “released this 29 Aug 17:55”, commit `b74dce4`), recorded in each row's evidence cell (metadata only — no SOPS/age behaviour is claimed from these rows).

## Validation (both quoted, with rc)

1. **Lane gate** — `(cd $S/tree && bash corpus/sources-census.sh; echo rc=$?)`
   `SOURCES_CENSUS: CLEAN (rows=104 A=100 B=2 C=2 queued=1 mined=99 rejected=4 entries_sourced=15 legacy=21 captures=104 inrow=16 inrow_only=0 inrow_nonreproducing=12)` → `rc=0`.
   Rows went 102 → 104, `captures` 102 → 104, `A` 98 → 100; no finding lines at all, so SC_FETCH, SC_INROW, SC_ENTRY_CITE, SC_CREDENTIAL and the shape checks all pass with the two new ids and the extended `source:` line.
2. **Fleet validator** — `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --file "$S/tree/corpus/SOURCES.md"; echo rc=$?`
   Last line `file	ok	/fast/scratch/hyaku/kagi-r48/K48ExecSources/tree/corpus/SOURCES.md` → `rc=0`; 19 preceding lines are all `W04 duplicate url` warnings on **pre-existing** rows (S019…S091); `grep -c 'S10[34]'` on that output = **0**, i.e. no warning attaches to the new rows.

## Exact change to apply (bytes saved in this dir)

1. `corpus/SOURCES.md`: insert the two lines of `rows.md` immediately after the `| S102 |` row and before the blank line preceding `## Paths` (registry tail stays the last table in `## Registry`).
2. `corpus/source-fetches.tsv`: append the two lines of `fetch-rows.tsv` at end of file (the file already ends with a newline; order is append-order, as for S099/S102).
3. `corpus/knowledge/sops-age-key-rotation.md` line 3: replace with `source-line.txt` — the previous `S009 …; S011 (…)` field with `; S103 (https://github.com/getsops/sops/releases/tag/v3.13.3, release page title, fetched 2026-11-06); S104 (https://github.com/FiloSottile/age/releases/tag/v1.3.2, release notes, fetched 2026-11-06)` appended. Exactly one column-1 `source:` line remains (SC_ENTRY_HEADER).
4. `.ufo/waves/round-48/capture/S103.body` and `S104.body`: copy the two saved bodies (sha256 above, matching the fetch rows' column 10).

## Files saved

- `build/K48ExecSources/rows.md` — exact S103/S104 registry lines (`c10e3918…b70ba`)
- `build/K48ExecSources/fetch-rows.tsv` — exact source-fetches lines (`36449085…4d90`)
- `build/K48ExecSources/source-line.txt` — the entry's new `source:` line (`a517e6bb…49e95`)
- `build/K48ExecSources/S103.body` (`8dbbadc0…81ba1`, 177586 B), `S104.body` (`652f8c81…0bc09`, 154312 B)
- `build/K48ExecSources/receipts.txt` — every command, rc, digest, and the census outputs
- `build/K48ExecSources.md` — this report

## Risks / limits

- The evidence cells abbreviate the raw digest (`8dbbadc0…c5981ba1`); the full 64-hex value lives in `source-fetches.tsv`, exactly as S100/S102 do. No digest is rounded or invented.
- Both captures are point attestations (the census enforces nothing stronger). GitHub release HTML is volatile; `representation` is `decoded-http-body-v1` with `rendered-text-v1` normalization, so a re-fetch may legitimately differ — that is why the quote normalization is declared, not a drift pin.
- `sops --version` emits a deprecation warning about future update-checking; the row pins the release identity, not that warning's text.
- No credential, key, token, `op://` path or vault field was read, produced or written; the artifact scan for `AGE-SECRET-KEY-`/`ghp_`/`hvs.` shapes over all five saved artifacts returned 0. No network write, no `op`, no vault contact. No package install was needed (both binaries already present and pinned), so there is no tooling receipt to record.
- Not mine to run: the C1 trial script, the C2 counter, `plans/round-48-*.sh`, and the lane's claim-ledger verify. Only `corpus/sources-census.sh` and the fleet validator were executed, as named.

SEAT-STATUS: complete
