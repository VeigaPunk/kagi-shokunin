# Seat K38ExecSources — round 38 build wave: S092/S093 live + committed-byte re-verification

Date: 2026-11-05. Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin (branch `master`).
Candidate commit `b944735` = `b94473505e6239cee0073d5be7a1c6f2ee07f564`; `git -C <lane> rev-parse HEAD` at
measurement time printed the same hash, i.e. the candidate is the landed HEAD. No tracked file was
modified by this seat (`git status --porcelain` listed only pre-existing untracked wave files:
`.ufo/waves/round-38/build-dispatch.json`, `build-run.stderr`, `build-run.stdout`, `build-spec.json`,
`build.ready`, `build.ready.dispatched`, `build/`).

## Top-line verdict

**AGREE.** Registry rows S092/S093 are byte-identical to the frozen generator's output; the committed
capture bodies match the capture rows' sha256 and byte counts with the quotes located exactly at the
declared offset 21886; the live pages (fetched 2026-11-05, this seat) still contain each quoted title and
release datetime exactly once; the lane census is CLEAN at rows=93 and the fleet registry validation is ok.
Live page bytes differ from the captures (expected for volatile pages); the identity claims (title +
datetime), not the byte equality, are the claims under test, and both hold.

This file mirrors `build/K38ExecSources/report.md` (same content; written to the assignment-named path).

## Check table (command → exit → observed output)

All commands run 2026-11-05 ~06:30 UTC-local. Scratch root `/fast/scratch/hyaku/kagi-r38/K38ExecSources`
(created with `mkdir -p`, deleted at the end; receipts copied to the seat dir first). Fleet-root cwd.

| # | check | command (as executed) | exit | observed output |
|---|-------|----------------------|------|-----------------|
| 1 | live fetch vault | `cd $S && curl -fsSL --compressed --max-time 60 -o vault.html -w 'vault http=%{http_code} bytes=%{size_download}\n' https://github.com/hashicorp/vault/releases/tag/v2.2.1` | 0 | `vault http=200 bytes=32559` (wire, compressed); file on disk 161249 bytes |
| 2 | live fetch openbao | `cd $S && curl -fsSL --compressed --max-time 60 -o openbao.html -w 'openbao http=%{http_code} bytes=%{size_download}\n' https://github.com/openbao/openbao/releases/tag/v2.7.2` | 0 | `openbao http=200 bytes=36371`; file on disk 192516 bytes |
| 3 | hashes + byte counts | `python3 -I -B $S/r38_bytes.py` (sha256 of 4 files; counts below) | 0 | `FILE committed-S092 sha256=1e0346160e6679f1f5f4f9b6d763cd05235d422ecb1ca1231331b5d9528ba468 bytes=161306`; `FILE committed-S093 sha256=a69db25645f08a09bf48a0ed4c98aaf27fc8692e35651e513351496f1b0f6165 bytes=192563`; `FILE live-vault sha256=dc431425f6177d539274fd46f09dc8f448715a662b02fbe74fea56237b84f0cb bytes=161249`; `FILE live-openbao sha256=1953ea71a4f3810117202f163b1cdd77264ee7a6e478ac8ce23bd5194e5ce66d bytes=192516` |
| 4 | live identity strings | same script as #3 | 0 | `LIVE vault title_count=1 dt_count=1`; `LIVE openbao title_count=1 dt_count=1` (title = `<title>Release v2.2.1 · hashicorp/vault · GitHub</title>` resp. `<title>Release v2.7.2 · openbao/openbao · GitHub</title>`; dt = `2026-10-22T21:59:36Z` resp. `2026-10-26T20:24:37Z`) |
| 5 | committed identity + offset | same script as #3 | 0 | `COMMITTED S092 title_count=1 dt_count=1 title_at_offset=21886 declared_offset=21886`; `COMMITTED S093 title_count=1 dt_count=1 title_at_offset=21886 declared_offset=21886` |
| 6 | live sha vs committed sha | same script as #3 (`live_sha_equals_committed`) | 0 | `vault=False`, `openbao=False` — live bytes differ from the 2026-11-05 captures (GitHub pages are volatile; the captures' own profile col 9 is `decoded-http-body-volatile-v1`) |
| 7 | registry row equality | `python3 -I -B plans/round-38-rows.py registry` run with cwd = lane (rc=0, no stderr), output compared byte-for-byte against `corpus/SOURCES.md` lines 99/100 by `python3 -I -B $S/r38_rows.py` | 0 | `SOURCES_line99_eq_gen_S092: True`; `SOURCES_line100_eq_gen_S093: True` |
| 8 | capture row equality | `python3 -I -B plans/round-38-rows.py fetch` run with cwd = lane (rc=0, no stderr), output compared against `corpus/source-fetches.tsv` lines 135/136 | 0 | `FETCH_line135_eq_gen_S092: True`; `FETCH_line136_eq_gen_S093: True` |
| 9 | capture col recomputation | same script as #7/#8 (independent re-hash of bodies and re-derivation of col 3 identity hash) | 0 | `S092 cols=16 col3_row_identity_match=True col10_sha_match=True col11_bytes_match=True col12_http=200 col8_date=2026-11-05 col13_quote_in_body=True quote_in_file_at_offset=21886`; same all-True line for `S093` |
| 10 | lane census | `cd $lane && bash corpus/sources-census.sh` | 0 | last line `SOURCES_CENSUS: CLEAN (rows=93 A=89 B=2 C=2 queued=1 mined=89 rejected=3 entries_sourced=14 legacy=21 captures=93 inrow=16 inrow_only=0 inrow_nonreproducing=12)` |
| 11 | fleet registry validation | `bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | 0 | last line `kagi   ok   /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md` |
| 12 | 11-column structure | `awk -F'|' 'NR==99||NR==100{printf "awk line=%d NF=%d\n", NR, NF}' $lane/corpus/SOURCES.md` | 0 | `awk line=99 NF=13`; `awk line=100 NF=13` |
| 13 | quote word count ≤ 25 | `python3 -I -B $S/r38_struct.py` (extracts the string between “ and ” in each row, splits on whitespace; also verifies no `|` inside the quote) | 0 | S092 quote 6 words, `at_most_25=True`, `contains_pipe=False`; S093 quote 6 words, `at_most_25=True`, `contains_pipe=False` |

## What the evidence supports

- **Committed bytes vs capture rows (C1 predicate for S092/S093).** Both committed bodies hash to the
  capture row's col 10 sha256 and have exactly col 11 bytes (161306 / 192563); manifest quotes equal
  capture col 13; the quote sits at declared offset 21886 in both bodies (check #5, #9). The S092/S093
  halves of `bash plans/round-38-c1.sh` → `5` are therefore consistent with these two rows.
- **Live pages vs quoted identity.** Each fetched page (HTTP 200) contains the quoted `<title>` exactly
  once and the registered release datetime exactly once — the identity claims in the registry cells hold
  on the live pages today. Byte-for-byte sha equality with the captures does **not** hold (vault 161249 vs
  161306 bytes; openbao 192516 vs 192563 bytes); this is the documented volatility ceiling of C1
  (`decoded-http-body-volatile-v1`, plan "Ceiling, named before data"), not a refutation of the rows.
- **Generator/landed-row agreement.** `plans/round-38-rows.py registry|fetch` output is byte-identical to
  the landed SOURCES.md and source-fetches.tsv lines; fixtures and landed rows cannot have diverged.
- **Census.** rows=93, A=89, mined=89, captures=93, entries_sourced=14, legacy=21 — exactly the plan's
  expected "after" state (S092/S093 added, nothing else moved); fleet validation ok with 0 exit.

## Scope, bounds and discipline

- Writes: only `.ufo/waves/round-38/build/K38ExecSources/` (`report.md`, `receipts.txt`,
  `live-vault-20261105.html`, `live-openbao-20261105.html`) plus this assignment-named mirror file. No lane
  tracked file touched; no git/jj mutation performed (read-only `rev-parse`, `log`, `status`, `ls-files` only).
- Scratch `/fast/scratch/hyaku/kagi-r38/K38ExecSources/` deleted after receipts were copied (final
  `rm -rf -- "$S"` exit 0). No file >50 MB written under /tmp; TMPDIR/HYAKU_SCRATCH not needed by any
  command run.
- Tooling installs: none (no pacman transaction run — host-wide pause respected; nothing needed installing).
- This seat did not run `plans/round-38-c1.sh`/`round-38-c2.sh` end-to-end; those belong to other seats.
  Checks #9/#5 independently re-verify the S092/S093 inputs those counters consume.

## Risks / caveats

- The live fetch is a point-in-time observation (2026-11-05 ~06:30); GitHub release pages keep mutating
  (asset lists, footers), so the live sha will keep drifting while title+datetime stay stable.
- `bytes=%{size_download}` values (32559/36371) are compressed wire sizes; on-disk decompressed sizes are
  the ones compared with the capture rows.
- Lane working tree carried 7 untracked wave-orchestration entries during measurement (list above); the
  census reads `corpus/` tracked content, which was clean.

## Blockers

None.
