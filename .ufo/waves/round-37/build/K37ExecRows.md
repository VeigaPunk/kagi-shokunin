# K37ExecRows — round-37 build wave: registry + capture row verification (C2 freshness)

Seat: K37ExecRows (executor), wave `build`, kagi round 37 attempt 1. Date: 2026-11-05.
Under test: candidate 9efcea7 (BASE 911ab519b6b07694c3cb9f7d9a7c56e142ad957c), frozen claim C2
(`plans/round-37.md` at e2030d2; predeclaration 04489d4; frozen counter `plans/round-37-c2.sh`).
Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin. No lane, fleet, git/jj, or index writes. Nothing installed.

## Method

- Scratch: S=/fast/scratch/hyaku/kagi-r37/K37ExecRows (created, deleted before yield).
- Fresh extraction: `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 9efcea7 | tar -x -C $S/cand`
  and `... archive 911ab519b6b07694c3cb9f7d9a7c56e142ad957c | tar -x -C $S/base`.
- The frozen counter and receipt were never edited. The BASE run transports the frozen instrument
  (counter at 9efcea7) and the frozen receipt into the BASE extraction — the same recipe as the
  frozen no-work control recorded at 04489d4 (`.ufo/waves/round-37/controls/c2-controls.txt`:
  `nowork rc=0 out=[3]`; BASE tree itself predates both files, see check 13).

## Checks

| # | check | command (cwd unless noted) | expect | got | verdict |
|---|---|---|---|---|---|
| 1 | Receipt sha at candidate | `sha256sum $S/cand/.ufo/waves/round-37/controls/observe-r37.json` | cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203 | same | PASS |
| 2 | S089 registry row shape | `grep -P '^\| S089 \|' corpus/SOURCES.md` then `awk -F'|'` | 11 columns (awk NF==13) | pipeNF=13 cols=11 | PASS |
| 3 | S090 registry row shape | same | 11 columns | pipeNF=13 cols=11 | PASS |
| 4 | S091 registry row shape | same | 11 columns | pipeNF=13 cols=11 | PASS |
| 5 | S089 source cell names feed URL; anchor names receipt version | raw row read: source cell `… — https://github.com/hashicorp/vault/releases.atom`; anchor `Entry titled v2.2.1, tag link /releases/tag/v2.2.1, … fetched 2026-11-05 (receipt …)` | URL + v2.2.1 | present | PASS |
| 6 | S090 source cell + anchor | raw row read | URL + v2.7.2 | `…openbao/releases.atom`; `Entry titled v2.7.2 …` | PASS |
| 7 | S091 source cell + anchor | raw row read | URL + Python 3.15.2 | `…downloads/feed.rss`; `Item titled Python 3.15.2 …` | PASS |
| 8 | Capture row field counts | `awk -F'\t' '$1==id{print NF}' corpus/source-fetches.tsv` for S089/S090/S091 | 16 each | 16 / 16 / 16 | PASS |
| 9 | Row-identity digest col3 | `printf '%s\t%s\t%s\n' <id> <mined> <url> \| sha256sum` vs col3 | equal | S089 ec82f849…25a9; S090 f911b24d…b338; S091 44554690…d986 — all MATCH=YES | PASS |
| 10 | Body bytes vs col10/col11 | `sha256sum` + `wc -c` on `.ufo/waves/round-37/capture/S089-vault.body`, `S090-openbao.body`, `S091-python.body` | col10 sha, col11 bytes | S089 3cbfdd86…57fce / 297221; S090 a54d1a53…f2e0e / 543805; S091 9ba8856e…cea1e / 3354 — SHA-MATCH=YES, BYTES-MATCH=YES ×3 | PASS |
| 11 | Located quote col13 in body | `grep -c -F -- "<quote>" <body>` | ≥1 | 1 / 1 / 1 (`<title>v2.2.1</title>`, `<title>v2.7.2</title>`, `<title>Python 3.15.2</title>`) | PASS |
| 12 | BASE registry lacks S089–S091 | `grep -c -P '^\| S0(89|90|91) \|' $S/base/corpus/SOURCES.md` | 0 | 0 | PASS |
| 13 | C2 counter at BASE | naive `bash plans/round-37-c2.sh` in $S/base | 3 | exit 127 — `plans/round-37-c2.sh: No such file or directory` (BASE predates the instrument; not a counter result) | n/a — retried per frozen recipe |
| 13b | C2 counter at BASE, frozen recipe | copied counter+receipt into $S/base (receipt sha re-verified cb96cfb2…9203), `cd $S/base && bash plans/round-37-c2.sh` | 3, exit 0 | `3`, exit 0 | PASS |
| 14 | C2 counter at candidate | `cd $S/cand && bash plans/round-37-c2.sh` | `0`, exit 0 | `0`, exit 0 | PASS |
| 15 | Lane census at candidate | `cd $S/cand && bash corpus/sources-census.sh` | CLEAN, exit 0 | `SOURCES_CENSUS: CLEAN (rows=91 A=87 B=2 C=2 queued=1 mined=87 rejected=3 entries_sourced=14 legacy=21 captures=91 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, exit 0 | PASS |
| 16 | Fleet census (read-only) | `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` (cwd $S/cand) | exit 0, `kagi ok …/corpus/SOURCES.md` | exit 0, 19 W04 lines, last line `kagi	ok	/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md` | PASS |
| 17 | Superseded anchors unchanged at candidate | raw rows: S034 anchor `v2.2.0`, S035 `v2.7.1`, S039 `Python 3.15.1` | stale rows untouched | as frozen plan states | PASS |

Full fleet-validate output retained: `.ufo/waves/round-37/build/K37ExecRows/fleet-validate.out` (copied from scratch before deletion).

## Reading

- All three candidate rows are well-formed (11-column registry rows, 16-field capture rows), their
  identity digests, body hashes, byte counts and located quotes all reproduce from the committed
  capture bodies, and every anchor names the receipt version for its own feed URL.
- The counter prints 3 at BASE and 0 at the candidate, exit 0 both times, with the receipt sha
  verified — C2's declared direction (3 → 0) and the census kill rules (lane CLEAN, fleet exit 0)
  both hold at 9efcea7.
- The only anomaly (check 13) is operational, not evidential: BASE 911ab51 predates the round-37
  counter and receipt, so "3 at BASE" is only measurable by transporting the frozen instrument,
  which is exactly what the frozen no-work control did (`nowork rc=0 out=[3]` at 04489d4).

ROWS VERDICT: AGREE
