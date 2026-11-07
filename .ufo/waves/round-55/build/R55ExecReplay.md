# R55ExecReplay — lane-wide recheck replay measurement (§Routed 2)

- Seat: R55ExecReplay (kagi round 55, attempt 1). Measurement only; no lane edit.
- Measured revision: 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f (`git -C /home/vgpnk/Projects/shokunin/kagi-shokunin rev-parse HEAD` and `rev-parse 348aa3b8…` both print it; obtained 2026-11-07). `git status --porcelain` shows 9 dirty entries, all untracked `.ufo/waves/round-55/*` wave files (build-dispatch.json, build-spec.json, build.ready*, build-run.stderr, final/c1-candidate-rev.txt, final/c2-candidate-rev.txt, final/kill-rules.txt, build/) — no tracked file is dirty, so working-tree corpus reads are at the candidate revision.
- Scope: every `corpus/knowledge/*.md` `recheck:` line; extract backticked `curl …` commands with a stated expectation (`-> N` / `-> count=N`); (a) run live (plain GET, `--max-time 60`), (b) map the fetched URL to its registry row in `corpus/SOURCES.md` and replay the filter on the row's committed capture from `corpus/quote-bodies.tsv` `body_path` when the command is exactly `curl … '<URL>' | grep -c '<P>'`; fail closed otherwise.
- Verdict vocabulary: **agree** (stated = live = capture-replay where replayable) / **stale-expectation** (live and capture agree with each other but contradict stated) / **page-changed** (capture-replay agrees with stated but live moved) / **not-replayable** (no committed capture, non-`grep -c` form, or no stated expectation — the capture leg cannot run).

## Table (all 9 recheck curl commands with stated expectations)

| url | stated | live (2026-11-07) | capture-replay | verdict |
|---|---|---|---|---|
| `https://www.iso.org/standard/60237.html` (S101) | `-> 2` | 2 — HTTP 200, 85615 B, live sha256 `2e4c1524…85b7b0c80` = capture sha256 | 2 on `.ufo/waves/round-45/controls/capture-r45/S101.raw` | **agree** |
| `https://www.iso.org/standard/82709.html` (S113) | `-> 3` | 3 — HTTP 200, 90604 B, live sha256 `d8dfe354…dfa64357` = capture sha256 | 3 on `.ufo/waves/round-55/capture/S113.body` | **agree** |
| `https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md` (S055) | `-> 1` | 1 — HTTP 200, 13252 B | none (S055 not in quote-bodies.tsv) | **not-replayable** (no capture; live agrees) |
| `https://www.1password.dev/brokered-access/custom-workflow` (S070/S018) | `-> count=1` | `count=1` — HTTP 200, 268454 B (`rendered-text-v1.py locate`) | none (S070/S018 not in quote-bodies.tsv; locate form) | **not-replayable** (form + no capture; live agrees) |
| `https://csrc.nist.gov/pubs/sp/800/133/r3/ipd` (S074) | `-> 1` | 1 — HTTP 200, 45351 B | none (S074 not in quote-bodies.tsv) | **not-replayable** (no capture; live agrees) |
| `https://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-57p2.pdf` (S078) | `-> 1` | 1 — HTTP 200, 622785 B (`pdftotext -layout` in the pipe) | none (S078 not in quote-bodies.tsv; pdftotext form) | **not-replayable** (form + no capture; live agrees) |
| `https://openid.net/specs/openid-connect-core-1_0.html` (S067) | `-> 1` | 1 — HTTP 200, 437508 B | none (S067 not in quote-bodies.tsv) | **not-replayable** (no capture; live agrees) |
| `https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md` (S054) | `-> 1` | 1 — HTTP 200, 38524 B | none (S054 not in quote-bodies.tsv) | **not-replayable** (no capture; live agrees) |
| `https://trufflesecurity.com/docs/verification-caching` (S057) | `-> 1` | 1 — HTTP 200, 110710 B | none (S057 not in quote-bodies.tsv) | **not-replayable** (no capture; live agrees) |

All nine live runs: HTTP 200, curl exit 0, stated count reproduced. Every command ran as its recheck line states it (the two ISO commands carry the browser user agent the line declares; the default curl UA gets 403 there — not re-probed this seat).

**Count of stale expectations other than the ISO one fixed this round: 0.** The M55-2 fix itself (S101 `-> 1` → `-> 2`) is confirmed true three ways: live gives 2, the committed round-45 capture gives 2, and the live body is byte-identical to that capture. The new S113 `-> 3` reads true on live and capture as well.

## Prototype

`R55ExecReplay.d/replay.py` — replay leg (b) only, no network. Parses every `recheck:` line, extracts backticked curl commands and the stated expectation that follows each backtick close, and replays only the exact form `curl … '<URL>' | grep -c '<P>'`: row via first-URL match in `corpus/SOURCES.md`, capture via `corpus/quote-bodies.tsv`, `grep -c -e P` on the capture. Everything else is reported `NOT_REPLAYABLE` with a reason and never attempted (fails closed). Exit 1 on any MISMATCH, 0 otherwise, 2 on setup error.

Run on a `git archive 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f` extraction (captures are tracked at that rev; verified with `git ls-tree -r`): **commands=10, replayed=2, matched=2, mismatched=0, not_replayable=8, errors=0, exit 0** — full JSON receipt `R55ExecReplay.d/replay-run.txt`. First run mapped zero rows (row/URL regexes written against grep output prefixes instead of the file); fixed and rerun — noted in the receipt.

## What cannot be replayed, and why (honest list)

1. **No committed capture for 6 of the 9 URLs.** quote-bodies.tsv carries bodies only for S089–S093, S100–S102, S111–S114. S054, S055, S057, S067, S070/S018, S074, S078 have registry rows but no `body_path`, so leg (b) has nothing to replay against. Note: S054/S055 are pinned by fetch sha256 + upstream commit in their rows, and S073–S075/S078 have captures recorded in `corpus/source-fetches.tsv` (2026-11-04) — a gate could subscribe to those registries, but this measurement used only quote-bodies.tsv as instructed.
2. **Non-`grep -c` filter forms (2 commands).** The cdp-bridge command ends in `python3 corpus/rendered-text-v1.py locate /dev/stdin '…'` and the parts-withdrawal command in `pdftotext -layout - - | grep -c '…'`. Both fail closed in the prototype. The locate form additionally needs its rendered-text normalisation applied to the capture before any string count is meaningful — §Routed 2's "normalisation declared per row" precondition (the normaliser itself is committed, `corpus/rendered-text-v1.py`).
3. **No stated expectation (1 backticked command).** `aliyun-accesskey-credential-custody.md:3` backticks only `curl -fsSL --compressed URL` — parameterized, no `-> N`, so there is nothing to compare even though the five source URLs are named in the entry body.
4. **Recheck lines with no curl command (9 entries).** feature-bound-credential-review, feed-token-boundaries, onepassword-machine-credentials, op-ref-consumption (§11 clock), openbao-kv-v2-version-lifecycle, prefreeze-controls, sops-age-key-rotation, vault-openbao-token-lease-lifecycle, plus aliyun above: on-release/on-change/instruction rechecks with no extractable command+expectation pair.
5. **Mid-line recheck statements in op-ref-consumption.md (lines 372, 398)** begin with a backtick / bold text, not `recheck:` at column 1, so a `^recheck:` parser skips them. Neither carries a curl command, so today's population is unaffected, but a lane-wide gate must decide whether mid-line `recheck:` statements belong to the population.
6. **Outside this measurement's population, noted only:** `nist-key-management-guidance-status.md:101` carries a body-text check `curl … 'https://csrc.nist.gov/pubs/sp/800/57/pt1/r5/final' | grep -c 'SP 800-57 Part 1 Rev. 4 (01/28/2016)' -> 1` that is not on a `recheck:` line; not fetched, not counted.

## Receipts (all in `R55ExecReplay.d/`, each headed with the measured 40-hex revision)

- `capture-replay.txt` — grep -c on S101.raw (2) and S113.body (3); sha256 of S101.raw, S113.body, S114.body (all equal the lesson's registered digests).
- `live-iso60237.txt`, `live-iso82709.txt`, `live-betterleaks.txt`, `live-op-custom-workflow.txt`, `live-csrc-800133r3.txt`, `live-nist-800-57p2-pdf.txt`, `live-oidc-core.txt`, `live-trufflehog-readme.txt`, `live-th-verification-caching.txt` — one per live leg: command, HTTP code, bytes, count, exit codes.
- `replay-run.txt` — prototype run output on the candidate extraction, exit 0.
- `replay.py` — the prototype.

## Method notes

- Live fetches were made with the stated flags plus `--max-time 60`; bodies saved under scratch (`/fast/scratch/hyaku/kagi-r55/R55ExecReplay/live/`, removed at seat exit). The ISO live bodies hash byte-identical to their captures, so "live" and "capture" legs for those two URLs measure the same bytes today.
- Registry-row mapping assumption in the prototype: the first `https?://…` token on a `| SNN | …` row line is the row's URL; trailing `/` normalized. All 9 URLs mapped to exactly one row each.
- No lane file was edited; scratch and the seat's report dir are the only writes.
