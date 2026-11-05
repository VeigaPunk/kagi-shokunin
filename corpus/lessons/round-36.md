source: S034 (Vault releases Atom feed), S035 (OpenBao releases Atom feed), S040 and S041 (Python documentation pages) — all four re-opened 2026-11-04; located quotes in §Gate

# Round 36 — self-assessment population and re-observed clocks

Frozen claim: `plans/round-36.md` at `09f27e2e16c26484b2675aa2a2b1e2ca4d3d1d8d`. Frozen instrument bytes and the executed predeclaration controls: `cb8cb659e84240a8db12e4f7b4a0def5068baf7e`. Motivating rejected closures: round32 at `76f4eeae7aa9af4dbb9423f5632b55791824253a`, round33 at `f9dc06fd8f6b43c175193c76dc6350468f551634`, round34 at `063c407494276d0c616e6c712a2e5d7aeb7e3768`. They remain rejected; no new control backdates old evidence.

## Claims


- **C1 calibration.** `bash plans/round-36-c1.sh` = SD5 (red ids the `lane-status:` line declares that the latest calibration row omits) + `stale` (declared self-count rows whose claimed integer differs from the live source). BASE `4`, target `0`. Kill rules: SD6 must stay at its BASE value and no non-owned verifier file may be edited; the counter must not print 0 on a tree where either population is non-empty; a wrong-number forgery (capability count 71) or a red-id forgery planted in an earlier round row must still be counted. Population separation: SD5 and `stale` are lane-owned SCORECARD bytes; the SD6 class (citations inside non-author verifier spot-check files) is excluded from the reading and preserved.
- **C2 freshness.** `bash plans/round-36-c2.sh` = `clock=feed` rows in `corpus/release-clocks.tsv` whose `observed_version` or `verdict` differs from the committed live receipt `.ufo/waves/round-36/controls/observe-live.json` (sha256 `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`, observed 2026-11-04T23:42Z), plus rows the receipt does not carry. BASE `15`, target `0`. Kill rules: the gate's own verify must print CLEAN at the landing revision against the repointed default receipt; a table value above the receipt value must not be counted; no historical receipt may be rewritten or deleted.

## Gate


- **ADMIT S034** (Vault releases Atom feed, https://github.com/hashicorp/vault/releases.atom), reopened 2026-11-04. Located quote (first stable entry, byte offset 726): “`<title>v2.2.1</title>`”, entry `<updated>2026-10-23T17:34:44Z</updated>`, body sha256 `3cbfdd86d1b4530999d9ab7ed15f395f2757ce0f8a2ae835798878bbe1957fce`. The lane's own extractor returns 2.2.1 from those bytes, matching the receipt rows S012/S013/S022-S024.
- **ADMIT S035** (OpenBao releases Atom feed, https://github.com/openbao/openbao/releases.atom), reopened 2026-11-04. Located quote (first stable entry, byte offset 729): “`<title>v2.7.2</title>`”, entry `<updated>2026-10-26T20:24:37Z</updated>`, body sha256 `a54d1a5314ca701684fe65b3e4687c0519d45164c8cd177c950ff75bfd5f2e0e`. Scope guards still live in the same feed: `api/v2.7.1`, `sdk/v2.7.1`, `v2.7.0-beta20260909`.
- **ADMIT S040 / S041** (https://docs.python.org/3/library/re.html and /library/html.html), reopened 2026-11-04. Located quote, page `<title>` (rendered-text-v1 locate count 1): “`Python 3.15.2 documentation`”. Both pages now serve the 3.15.2 title and no longer carry the 3.15.1 title their anchor cells name. Their teaching quotes still locate unchanged: “Matches Unicode whitespace characters (as defined by str.isspace() ).” and “This function uses the rules defined by the HTML 5 standard for both valid and invalid character references”. The clock feed named for both rows (S039, python.org downloads RSS) carries `<title>Python 3.15.2</title>`, `pubDate Sun, 25 Oct 2026 04:15:38 +0000`, body sha256 `9ba8856e586659ab78349c3963aa1de178636c0f08772d6196fadbaa92bcea1e`.
- **REJECT the reading “a re-observed feed proves the clock table is correct.”** Scope: the receipt proves what the feed served at one instant; it does not prove the anchored version, the derived-anchor rule or the table's own semantics. Flip: a row whose `anchored_version` moves with the observation, or a receipt that restates the table, would be a different claim and is not made here.
- **Mutable source cells: none.** The planned `recheck` touch on S034/S035/S040/S041 was dropped — see M36-3; the `opened` dates stand at 2026-10-21 and no `status` or `used-by` cell changed. No row was appended; expansion is knowledge, and this round admits no new knowledge entry.
- **Non-author spotcheck: pending outside closure.** Dispatched seats are lane-authored evidence, never outside agreement.
- **Assimilation: none.** `considerthese/2026-10-26.md` was read in-round: proposals 2 (lane-status line) and 3 (feed-token agreement) are already implemented and D1 is discharged, so no unimplemented proposal was taken. `merge/kagi/` staged nothing this round; no entry adopted.

## Mistakes


| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M36-1 | self-declaration | `SCORECARD.md:14` (the `lane-status:` line) names the routed reds `R25-02,R29-01,R29-02`; the round-35 calibration row (`SCORECARD.md:1374` at BASE, the latest `## Round` section) names none of them, so the sweep's SD5 class reads 3 — measured at BASE: `MISMATCH SD5 SCORECARD.md:14 red id 'R25-02' is absent from the latest calibration row (SCORECARD.md:1374)` ×3 (`SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=3 SD6=3 SD7=0 SD8=0 SD9=0)`). The same class was repaired once before — round 32's calibration row (`SCORECARD.md:1314`) says "red-id naming repaired" — and re-opened by the next round's row, because the sweep reads only the *last* `## Round` section. | `none` — QM32 (a plan that touches a gate enumerates every red row that gate prints at BASE, from a measured run) was satisfied in round 33's plan, which read the sweep at BASE; no criterion binds a repaired red-id naming to the *next* round's calibration row, so each round's row silently re-opens the class. | C1's SD5 arm makes the omission countable, and the round-36 calibration row names `R25-02` (FAIL), `R29-01` and `R29-02` (POLICY) with their state instead of clearing them. Shown able to fail: `controls/forge-sd5-early-c1.out` (`4`, rc0 — reds planted in an earlier row only are not counted) and `controls/setup-c1-missing-c1.out` (exit 2, no integer). |
| M36-2 | number-drift | The SCORECARD capability row (`SCORECARD.md:701`) declared the source-census `--selftest` at **59 cases** while the live gate prints `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` (executed 2026-11-04, rc0); ledger `R21-03` has pinned 70 since round 24 (`a3eb6c7`) while the prose copy was last written at round 23 (`7af07b4`). The number was declared once, at the capability's first working round (21, `c41af82`, at 40 cases), and the copy sat outside every self-count check for fifteen rounds (21–35): `corpus/self-counts.tsv` (`82745e2`, round 25) bound SKILL.md, PROVINCE.md, corpus/README.md and later `corpus/knowledge/*.md`, but never SCORECARD.md — so every "self-description" round (32–35) ran a sweep that never compared this cell. | `QM21` (round 25) — "a current-tense number a committed doc states about this lane's own artifacts is bound to the live source that defines it (`corpus/self-counts.tsv` …)"; the criterion named the binding surface but its population excluded SCORECARD.md, and `QM26` extended the population to `corpus/knowledge/*.md` only, so the class stayed uncovered. | The population is extended at BASE with `SA-CAP-CENSUS-SELFTEST` (`corpus/self-counts.tsv:87`), the capability row is corrected to the live 70 with 59 kept as the round-21 record, and the three count declarations that the ledger append invalidated are re-bound in the same landing. Shown able to fail: `controls/forge-stale-c1.out` (`4`, rc0 — a forged 71 leaves stale 1) and `controls/setup-c1-missing-c1.out` (exit 2). |
| M36-3 | frozen-instrument drift | An earlier attempt of this same round edited the frozen counters *after* the freeze commit `cb8cb65`: commit `404a7b94b09af4df692e6d5b04f59b143531462c` (parent `cb8cb65`, kept only as `refs/jj/keep/404a7b9…`, **not** an ancestor of `master`) changed `plans/round-36-c1.sh:12` and `plans/round-36-c2.sh:12` from `root=$(cd "$(dirname "$0")/.." && pwd)` to `root=${LANE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}` (discarded bytes sha256 `bfa1ec8d04c8757dc391be02167ffb4066a3ebf9fe2920c938e59298f53575c2` and `a11034c3d5d3f544d4923d6a42fbbd4e6d168a344e86f7c88aa164d8117e7bde`). The committed instrument bytes are identical at `cb8cb65` and at `09f27e2` (`206cbcc5…`, `ac010f16…`, `grep -c LANE_ROOT` = 0 in both), so the `LANE_ROOT="$BASE"` prefix in `plans/round-36.controls.tsv` is inert against the frozen scripts, which resolve their own root from their own location. | `QM29` — a round's claims file is committed alone before any work commit and its frozen text and counting commands never change afterwards; the edit was made in the working tree and never landed, which is exactly the drift QM29 forbids. | The edit was discarded, not committed; the committed bytes were re-proved by re-execution rather than by assertion — `git archive 09f27e2` extracted and both counters re-run (`4` rc0, `15` rc0), and the same scripts over the candidate tree read `0` rc0 and `0` rc0. The plan-carry commit `91746685ea22552d9b7bef5b52ab87a840eba0e6` has the identical tree to `09f27e2` (`847106900cbd434ea1cfdd703fd5c89e78970c79`), so the attempt-1 predeclaration was carried forward unchanged. || M36-4 | stamp drift | `corpus/self-counts.tsv` was changed by the arming commit `cb8cb65` (81 lines / 12769 B stamped vs 87 lines / 13361 B actual) without re-pinning its `corpus/stamps.tsv` row, so `verify` would have reported it STALE at BASE | `corpus/claim-ledger.sh verify` (stamps mode) — it was never run at `cb8cb65` | Re-pinned this round together with every other changed artifact (112 rows, same membership); `R12-03` still pins 112 |
| M36-5 | race | The L1 rewrote `corpus/claim-ledger.tsv` while a `verify` run was reading it; that run died with `claim-ledger: malformed claims row (fields=1)` and its verdict was discarded | `none` — no gate takes a lock on its inputs | Edits and gate runs are serialized; every verdict reported this round comes from a run made after the last edit to its inputs |

## Migrations


| Surface | Old | New | Where recorded |
|---|---|---|---|
| `corpus/release-clocks.tsv` — 15 drifting `clock=feed` rows | S012 `2.2.0`/2026-10-21/`fired`; S013 `2.2.0`/`not-fired`; S014, S015, S016, S021, S025, S026 `2.7.1`/`not-fired`; S022, S023, S024 `2.2.0`/`not-fired`; S027, S028 `3.15.1`/`fired`; S040, S041 `3.15.1`/`not-fired` | S012 `2.2.1`/`fired`; S013 `2.2.1`/`fired`; S014, S015, S016, S021, S025, S026 `2.7.2`/`fired`; S022, S023, S024 `2.2.1`/`fired`; S027, S028 `3.15.2`/`fired`; S040, S041 `3.15.2`/`fired`; every `observed_at` → 2026-11-04; `anchored_version` untouched; each note names the round-36 receipt | receipt `.ufo/waves/round-36/controls/observe-live.json` (sha256 `3f611eec…`); `plans/round-36.md` §C2 BASE drift list (12 of 15 change verdict, 3 keep `fired`: S012, S027, S028) |
| `corpus/release-clocks.tsv` — 15 further bound rows (values unchanged) | S005–S011, S017–S020, S029–S032 at `observed_at` 2026-10-21 | same `observed_version`/`verdict`, `observed_at` → 2026-11-04, note gains "re-observed unchanged by the round-36 receipt observe-live.json (2026-11-04)" | `corpus/release-clock.py` `receipt_matches` (lines 475–495) compares each bound row's `observed_at` date with the receipt's, so the whole table is re-dated; the counter's population is unchanged (only `clock=feed` rows are counted) |
| `corpus/release-clock.py` — default receipt pin | `DEFAULT_RECEIPT_SHA256` `13b8540c78b9de07bc184894583a368472fd1f2f04a898220bf7c29d2648a169`; `receipt_path` default `.ufo/waves/round-26/observe-2.json`; argparse help "default is the round-26 rearmed receipt" | `DEFAULT_RECEIPT_SHA256` `3f611eec30d4a48f4f389bb1a630551d77110d92fb97eee954eeb6f7c8558727`; `receipt_path` default `.ufo/waves/round-36/controls/observe-live.json`; help "default is the round-36 rearmed receipt" | the round-26 receipt is retained byte-identical (sha256 `13b8540c…`, committed at `d30c989`) and stays citable with `--receipt … --receipt-sha …` — superseded, never rewritten |
| `corpus/claim-ledger.tsv` — claim rows | 79 rows (`R21-04` pins `^79$`) | 82 rows: `R36-01` (C1 counter), `R36-02` (C2 counter), `R36-03` (release-clock verify against the repointed default receipt) | `corpus/claim-ledger.tsv:98-100` |
| `SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:64` — the three count declarations that count the ledger | `79` claims / `79` claim rows / `79 rows` | `82` / `82` / `82` | `corpus/self-counts.py` (rows `SC-SKILL-CLAIMS`, `PV-CLAIMS`, `RD-LEDGER-ROWS`, all bound to ledger `R21-04`); the append itself invalidated them, so they are re-bound in the same landing (measured `stale` 3 → 0) |
| `SCORECARD.md:701` — capability row `source registry + census gate` | `--selftest` 59 cases (`R21-03`) | `--selftest` 70 cases (`R21-03`; the round-21 record said 59, measured stale by round 36 C1) | ledger `R21-03`; live `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` |
| `corpus/SOURCES.md` — S034, S035, S040, S041 date cells | `opened` 2026-10-21 (S034, S035 `recheck` 90d; S040, S041 `recheck` on-release; `used-by` `corpus/lessons/round-25.md` / `round-26.md`) | **no change landed.** An in-round edit wrote 2026-11-04 into these rows' `opened` cell — the wrong column, read as the `recheck` cell — and the census accepted it (exit 0) because both cells accept ISO dates; the edit was reverted (`git diff corpus/SOURCES.md` empty, file sha256 identical to `HEAD`) | `plans/round-36.md` §Frontier step named S034/S035/S040/S041 (`recheck`/`used-by`/observation cells only) — the actual `recheck` cadence cells hold `90d`/`on-release`, not dates, so no dated recheck cell exists to migrate; the `opened` cell remains 2026-10-21. Whether a re-dating of these four rows is wanted at all is **unknown** — the plan's §Frontier step and the landed bytes disagree, and that choice is the L1's, not this seat's. |

## Boundaries and retained debt


- `R25-02` (FAIL) and `R29-01`/`R29-02` (POLICY) remain operator-owned and
  routed; the round-36 calibration row names them, it does not clear them.
- The C1 counter's `stale` producer (`corpus/self-counts.py`) exits 2 at BASE
  and at the candidate because two rows are POLICY (`R29-01`/`R29-02`, "command
  not allowlisted"). The counter reads the `SELF_COUNTS:` summary line, so a
  POLICY exit does not become a zero; the reading is bounded by that producer's
  envelope.
- SD6 is layout-sensitive: at BASE it reads 3 in a `git archive` extraction and
  5 in the live lane (the extra two are the round-34/round-35 verifier
  spot-check files' absolute sibling-path citations, which resolve outside an
  extraction and not inside it). The frozen C1 kill rule names 5; the
  landing-tree value is 5 and is unchanged by this round, but the count is not a
  portable constant.
- S034/S035 anchor cells now describe a superseded first-stable entry (`v2.2.0`
  is the second stable Vault entry, `v2.7.1` the third stable OpenBao entry),
  and S040/S041 anchor titles (`Python 3.15.1 documentation`) are absent from the
  served pages (they serve the 3.15.2 titles). Re-anchoring would trip the
  gate's DERIVATION rule, so it is recorded as debt, not silently repaired.
- No account, vault, credential, private reference, handler or service
  operation is authorized or performed by this round. The four feeds were read
  unauthenticated over public HTTPS.

## Next


Round 36 leaves the lane's calibration population closed at the bytes it
measures — the two self-assessment classes the lane's own documents were
already failing (the lane-status red set and a stale capability count) are now
counted by a counter that fails closed, and the release-clock table is
re-observed against a pinned, independent receipt so drift is a measured
number rather than an unnoticed one — and the next move is the one this round
deliberately did not take: decide, as a claim-level question rather than a
cell-level edit, whether the four cited registry rows should be re-anchored to
the releases the round observed (S034/S035 first-stable-entry, S040/S041
documentation title), since the DERIVATION rule makes that a re-binding of
what the rows teach and not a date refresh, and no counter in this lane
currently measures that class; until then the drift is bounded, named and
routed, and the next round should re-run both counters over committed bytes
before it claims anything about self-description again.

## Landed measurement and handoff

PENDING-FILL
