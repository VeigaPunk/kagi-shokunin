# K47ExecC2 — C2 candidate material (round 47, attempt 1)

Seat: K47ExecC2 (executor, leaf). BASE `252ef1cac9f41d84639c0d1f211d0e0911196112`, predeclaration
`b020d978bac91284a431710148ebb7a7950eaab8`. Scope: C2 freshness material only — the 11 fired
Vault/OpenBao release-clock rows re-verified against live captures; the lane tree was **not** edited.

**No `teaching-changed` verdict.** All 11 rows are `teaching-holds` at the observed release.

## Deliverables (all under `.ufo/waves/round-47/build/K47ExecC2/`)
| file | content |
|---|---|
| `fired-reverify.tsv` | 9-column ledger, header + 11 TAB rows, ready to copy to `corpus/fired-reverify.tsv` |
| `capture/S012.body … S026.body` | 11 live captures, ready to copy to `.ufo/waves/round-47/capture/` |
| `teaching-notes.md` | per-id release, quote count, <=40-word context window, one-sentence judgement, notes N1/N2 |
| `receipts.txt` | exact commands, exit codes, verbatim output lines |
| `fetch-log.tsv`, `locate.tsv` | supporting raw logs (timestamps, http codes, sha256, locate counts) |

## Behavior measured
Fetched each row's column-4 URL (`curl -fsSL --compressed`, HTTP 200 on all 11) with `date -u +%FT%TZ`
taken immediately before the call, 2026-11-06T19:34:14Z–19:34:15Z; located the unchanged column-13
quote with the measured tree's `corpus/rendered-text-v1.py` (rc=0, count>=1 on all 11); judged each
`teaches` cell against the rendered text around the located quote.

| id | release | count | verdict |
|---|---|---|---|
| S012 | 2.2.1 | 1 | teaching-holds |
| S013 | 2.2.1 | 1 | teaching-holds |
| S014 | 2.7.2 | 1 | teaching-holds |
| S015 | 2.7.2 | 1 | teaching-holds |
| S016 | 2.7.2 | 1 | teaching-holds |
| S021 | 2.7.2 | 1 | teaching-holds |
| S022 | 2.2.1 | 1 | teaching-holds |
| S023 | 2.2.1 | 1 | teaching-holds |
| S024 | 2.2.1 | 3 | teaching-holds |
| S025 | 2.7.2 | 1 | teaching-holds |
| S026 | 2.7.2 | 1 | teaching-holds |

Counts are occurrences in the capture, so S024's `quote_count` is 3 (config parameter, key-metadata
override, sample payload) and every other row's is 1.

## Evidence
- `C2_TREE=<scratch>/tree C2_ASOF=<epoch> bash plans/round-47-c2.sh` → rc=0, last line:
  `C2_FIRED_REVERIFIED: value=11 reverified=11 gate=1 (ok=S012 S013 S014 S015 S016 S021 S022 S023 S024 S025 S026; bad=; gate-line=RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15))`
- `(cd <scratch>/tree && python3 corpus/release-clock.py)` → rc=0, last line:
  `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)`
- Copy self-check: 11/11 report-dir bodies match the ledger sha256 and byte count (rc=0).
- Stability: independent re-fetch ~110 s later of the OpenBao tokens and Vault lease pages is
  byte-identical (same sha256, same byte count), so a non-author sha256 live leg re-run soon after
  this seat should reproduce the digests (receipts §8).

## Risks / caveats
1. **N1 — normalizer-bound gap (S013/S023).** The lease page's static-KV exception block is served in
   an MDX payload that `rendered-text-v1` removes at its script-strip step, so the column-13 quote is
   the only visible-text anchor. The KV sentence still exists (`grep -o "does not issue leases"` → 2
   hits in `S013.body`), which is why S013/S023 stay `teaching-holds`; a future verdict that relies on
   the normalizer to see that block would report a false loss.
2. **Five distinct bodies for eleven ids.** S012/S022 (Vault JWT), S013/S023 (Vault lease),
   S014/S025 (OpenBao JWT), S016/S021/S026 (OpenBao tokens) are pairwise identical in sha256 by
   construction; `fetched_at` is still recorded per id. A reviewer treating identical digests as
   copy-paste evidence should note the URL grouping is legitimate.
3. **Served-vs-source-version.** The Vault pages are served at "v2.x (latest)" with observed_version
   `2.2.1` from `corpus/release-clocks.tsv`; the captures contain no other version selector state, so
   the ledger repeats the release clock's own value rather than re-deriving it — my item does not
   re-observe release feeds.
4. No lane gate, build, lint or test was run (parent owns post-integration gates); nothing was committed.

## Blockers
None. All 11 captures fetched on the first attempt; no fetch failed; no retry was needed.

SEAT-STATUS: complete
