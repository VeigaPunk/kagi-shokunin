author: hyaku closure (non-author integrator, @m_zfl)

# Round 46 — verifier spot-check (non-author closure)

Lane-round: kagi r46. BASE `f5977284a8ce5bab09252be8196ee5dc18489926` → lane HEAD `f4a33d3df3996f947114743b9f6317ad7dc323e6`.
Report: fleet `.ufo/reports/round-46/kagi.md`. Dispatched prompt: fleet `.ufo/prompts/kagi-round-46.md`.
Driver digest (copied from the mutable `.ufo/watchdog.log`):
`2026-11-06T15:39:15-03:00 launch kagi round=46 pgid=1080996 driver=hyaku-inline attempt=1`;
`2026-11-06T16:20:57-03:00 complete kagi round=46; hyaku-inline attempt=1`.
Closure measurements: 2026-11-06, about 19:05–19:25Z.

## 1. Step-1 conformance

| check | command | observed | result |
|---|---|---|---|
| report committed by lane identity | `git log --format='%an %H %cI' -- .ufo/reports/round-46/kagi.md` (fleet) | `kagi-shokunin 77ecdf2f745c13fcb1c25fb2fff317eab93c3301 2026-11-06T16:20:40-03:00` | pass. Filed after the landing commit (16:17:15) and before the driver complete line (16:20:57). |
| cited commits exist + ancestors of `master` | `git cat-file -t <h>`; `git merge-base --is-ancestor <h> master` for f5977284, 44808ced, 0bd88889, f4a33d3d, 4776f71 | all `commit`, all `anc=yes` | pass |
| lane pushed, clean | `scripts/hyaku/jj-lane.sh state …/kagi-shokunin`; `git status --porcelain`; `git ls-remote origin refs/heads/master` | `state branch=master local=f4a33d3d… remote=f4a33d3d… ahead=0 behind=0 head=detached tracked=0 untracked=0`; porcelain empty; ls-remote `f4a33d3d…` | pass |
| `SHONEN` heading, one line per box | `grep -c '^- \[' SHONEN.md` → 4; report `## SHONEN` has 4 `[~]` lines | 4 = 4 | pass |
| prompt carries template contract | the template's `^## ` headings (§1, §2, §2b, §3, §4, §5) match the prompt's lines 3/9/42/80/99/131; hyaku addendum §6 at line 141 | present, in order | pass |
| misroot sweep (M46-3) | `ls .ufo/waves/round-46` (fleet) → absent; fleet `git status --porcelain` → only ` M .scratch/run15-state.json` (orchestrator-owned) | cleanup holds | pass |
| append-only LOG | `git diff BASE TIP -- LOG.md \| grep -c '^-[^-]'` → 0 | no removed lines | pass |

Status: **ok**. This is a real report with checkable commits, not a marker.

## 2. Claims — re-check

Gate standard binds here: `corpus/claims-declared.sh` and `corpus/release-clock.py` are lane-owned gates, so I did not execute them or the lane counters that wrap them. Each claim below is split into the legs I **re-measured** with plain commands over committed bytes or live public GETs, and the legs I only **evidence-verified** from committed receipts.

### C1 operability — the declared-claim gate's self-test kills its three plan-to-manifest mutants (0 → 3)

- Re-measured:
  - `git show <rev>:corpus/claims-declared.sh | grep -n 'cases" -eq'` reads `-eq 8` at BASE (line 102) and `-eq 12` at TIP (line 122). The four new `chk` cases are `no-manifest-row`, `in-flight-round`, `landed-floor` and `same-claim-second-axis` (TIP lines 108/112/117/121).
  - `git diff -U0 BASE TIP -- corpus/claims-declared.sh` has hunks `@@ -40,0 +41`, `@@ -70,0 +72,2`, `@@ -102,2 +105,19`. The self-test block runs from `if [ "${SELFTEST:-0}" = 1 ]` (line 36) to `fi` (TIP line 128), so every hunk lies inside it and the checking logic after line 128 is byte-identical. This holds the frozen kill rule.
  - `git diff --stat 0bd88889 f4a33d3d -- corpus SKILL.md PROVINCE.md SCORECARD.md LOG.md plans` is empty. The candidate receipts therefore describe the TIP's gate bytes.
- Evidence-verified:
  - `.ufo/waves/round-46/controls/c1-base.txt` has `value=0 killed=0 … m1=0 m2=0 m3=0 … PASS (8 cases)`.
  - `final/measured-at-candidate.txt` has `value=3 killed=3 positive=1 equiv=1 real=1 (… e1..e4=0 m1=1 m2=1 m3=1 … PASS (12 cases) … CLEAN (claims=19))`.
  - Per-mutant self-test runs record `FAIL (passed=9/12)`, `9/12`, `8/12`, and axis-blind `11/12`, each with rc 1.
- Reported 0 → 3. Re-measured and evidence agree → **operability: improved**. The SCORECARD score stays at 9; the verdict grades the verified move.

### C2 freshness — every BASE on-release clock re-observed live; release-clock gate CLEAN (0 → 29)

- Re-measured:
  - The on-release ids from `corpus/SOURCES.md` at BASE and at TIP, extracted with awk column 11 = `on-release`, number 29 at each tip. Both sets equal the receipt's id set exactly (`diff` empty both ways).
  - `jq '.observations|length'` on `final/observe-r46.json` → 29. Format is `release-clock-observations-v1`. Records with `http_status != 200`: 0. All `observed_at` values fall from `2026-11-06T19:01:14Z` to `19:01:23Z`, which is before the candidate commit at 19:16:33Z. Verdicts: `fired=13 not-fired=5 quote-located=11`.
  - `sha256sum` of the committed receipt is `6091c529…8765fa7`, which equals `DEFAULT_RECEIPT_SHA256` at `corpus/release-clock.py:28`.
  - Clock rows (`corpus/release-clocks.tsv` col 1): BASE has S005–S032 plus S040 and S041. TIP has S005–S032 plus S098. This matches the reported retire/bind.
  - My own live re-observation, 2026-11-06 ~19:20Z, public GETs:
    - sops atom newest `<title>v3.13.3</title>`, which matches S008–S011 `3.13.3`.
    - vault atom newest `<title>v2.2.1</title>`, which matches S012/S013/S022–S024 `2.2.1`.
    - `https://curl.se/info` reads `Version: 8.23.0`, which matches S029.
    - UTS #18 contains `Revision 25` once, and the live body's sha256 `68e34b8b…98c70d` equals the round-41 capture `.ufo/waves/round-41/capture/S098.body`.
- Evidence-verified:
  - `controls/c2-base.txt` has `value=0 … default-rc=1 'RELEASE_CLOCK: FAILED (on_release=29 bound=28 unbound=1 …)'`.
  - The candidate reading is `value=29 fresh=29 default=1 pinned=1 kept=1`, with `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)` and self-test `PASS (116 cases)`.
  - `final/r36-03-red-witness.txt` shows the BASE `ORPHAN S040/S041`, `RECEIPT-MISMATCH S040/S041`, `UNBOUND S098` and FAILED rc 1.
  - The critic D-6 leg records no fired row's anchor or verdict changed BASE→candidate. Only S040/S041 were retired and S098 was added.
- Reported 0 → 29. Re-measured and evidence agree → **freshness: improved**.

### Harm check

- `git diff BASE TIP -- SCORECARD.md` only appends a `## Round 46 — post-move` section. Every axis reads `9 → 9`, and no earlier row was edited.
- `corpus/SOURCES.md` is byte-unchanged at 102 rows.
- `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → `kagi ok`, rc 0. It also prints 19 `W04 duplicate url across scopes` warnings, which are cross-scope reuse of feed and doc URLs (warnings only).
- The lane-local census FAILED with 3 findings (S094/S099) at both BASE and candidate. This was pre-existing, and the lane routed it.
- Spot reads:
  - `PROVINCE.md:75` and `SKILL.md:48,787` now name the round-46 receipt.
  - `corpus/claim-ledger.tsv` R36-03 expect migrated `30/15 → 29/13`, with a journal and a red witness.
  - No `R46-*` ledger row exists.
- No axis harmed.

### Per-axis verdicts

| axis | verdict | basis |
|---|---|---|
| operability | improved | C1, re-measured (case count, hunk scope) + evidence-verified (mutant kills) |
| freshness | improved | C2, re-measured (ids, receipt records/dates/digest, 4 live sources) + evidence-verified (gate readings) |
| calibration | unchanged | no claim; stale self-descriptions corrected, but SCORECARD:1695 carries a new miscount (routed 1) |
| coverage | unchanged | no claim; README rows index held entries |
| depth | unchanged | no claim |
| adjacency | unchanged | no claim |

## 3. Discernment spot-check (LEARNING.md)

Source: `corpus/lessons/round-46.md` `## Gate`, "Discernment sample".

| item | decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|
| S098 clock = `Revision 25` quote | admit | live `https://www.unicode.org/reports/tr18/` (sha256 `68e34b8b…98c70d`, identical to the round-41 capture); capture `.ufo/waves/round-41/capture/S098.body` byte offset 197172 reads `b'Revision 25'`, `grep -c` = 1 | agree | The quote is located exactly once at the declared offset in both the capture and the live body. A revision cell changes when UTS #18 is revised, so the clock can fire. |
| S098 clock = page title | reject | same live body: `<title>UTS #18: Unicode Regular Expressions</title>` | agree | The title carries no revision, so a title clock could never fire on a new revision. Refusing it is correct. |
| ledger row R46-01 (duplicate default-gate row) | reject | `corpus/claim-ledger.tsv`: R36-03 already runs `bash plans/round-36-c3.sh` (the default-mode gate) with the migrated expect; `grep -c '^R46'` → 0 | agree | A second row over the same verdict line would be a duplicate authority. Migrating R36-03 keeps one authority. |

Newly written `SOURCES.md` rows: none, so nothing could be re-opened. Rows stay 102 → 102, checked with `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'` at BASE and TIP. I re-opened the one touched registry-side row, `corpus/source-fetches.tsv` S098 (quote `Revision 25`, two words, ≤25). Its location `document header table, Revision cell (raw byte offset 197172 …)` resolves as shown above → agree.

## 4. Trend verdicts

- **expansion: unchanged.** There are no new `knowledge/` entries and no new SOURCES rows (102 → 102). The README coverage rows index entries that already exist.
- **quality: improved.** 29 held on-release clocks re-verified live, and a held gate that was red since `4776f71` is CLEAN. No admitted entry failed its re-check (my live sample of 4 sources agrees). Two stale self-descriptions were corrected.
- **discernment: improved.** The non-author spot-check agrees with the gate on 1 admit and 2 rejects. QM57 is lesson-backed (M46-1).

## 5. Routed defects (lane fixes next round)

1. `SCORECARD.md:1695` (round-46 operability row) says `--selftest` "(8 → 11 cases)" and cites "cases 9–11". The committed gate asserts `-eq 12` and prints `PASS (12 cases)`, and the lesson and LOG say 8 → 12. The append-only correction should be logged as a new SCORECARD/LOG entry.
2. The report and lesson call seat K46ReviewerLive a "non-author live re-observation". Per LEARNING.md §Discernment, a seat the lane dispatched is still the lane. The term should be reserved for closure or operator checks; this closure's own live sample of 4 sources stands in for the out-of-lane leg.
3. S098 is a `rejected` SOURCES row carrying an `on-release` clock. The lane already routed this as critic D-7; it stays open.
4. The counter weaknesses the lane named (K46MutCounters survivors; FRESH has no upper date bound; PINNED digests the file it measures) are routed to round 47. The non-author live leg is what catches a hand-written receipt.
5. The lane-local census is red (S094/S099 used-by/no-cite and S099 fetch provenance). It is carried, under QM57 as routed, not inherited.

## 6. Promotion note (operator-owned)

All four SHONEN boxes are `[~]`. Each cites evidence a non-author can run: `bash corpus/claims-declared.sh --selftest`, `python3 corpus/release-clock.py`, `SKILL.md:48`, `PROVINCE.md:75`. They look checkable by a non-author. Promotion stays operator-owned, and this closure writes no `[x]`.
