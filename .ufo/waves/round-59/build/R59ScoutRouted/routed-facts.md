# R59ScoutRouted — routed facts (round-59 C1 numbers, independently re-derived)

Seat: `R59ScoutRouted` (scout). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch `master`. Claim BASE `5fa6e658f36bd9e440cb567fbbd2bfac88f868b6`; frozen
predeclaration `af7b665106749e24c02758f8d79e39a05aa3c905` (`plans/round-59.md`).
Everything below is a fresh re-derivation from the lane repository; nothing was taken
from the round's own counters except where a counter is itself the measured object.

All commands were run from the lane root with absolute paths; scratch lived in
`/fast/scratch/hyaku/kagi-r59/R59ScoutRouted/` and is deleted at hand-off.

## 1. Command → raw output → plan number it supports

| # | command (run from `/home/vgpnk/Projects/shokunin/kagi-shokunin`) | raw output | plan number supported |
|---|---|---|---|
| 1 | `git show 1b13f5dad921f8901f56d30c428f89614dd74d8a:corpus/SOURCES.md \| grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'` | `117` | plan §C1 I1 base count **117** ✔ |
| 2 | `git show be8705f8:corpus/SOURCES.md \| grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'` | `120` | plan §C1 I1 landing count **120** ✔ |
| 3 | `git show 5fa6e658f36bd9e440cb567fbbd2bfac88f868b6:corpus/SOURCES.md \| grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|'` | `120` | round-59 claim BASE holds **120** rows (plan never states this; it is the number the "Registry 117 → 120" correction must *not* be read against) |
| 4 | `git diff 1b13f5da be8705f8 -- corpus/source-fetches.tsv \| grep -c '^+S'` | `6` | plan §C1 I2 added-row count **6** ✔ (rows S115–S120) |
| 5 | same diff, row listing | `+S115 … +S120` (6 rows) | confirms the 6 are S115–S120, matching plan I2 |
| 6 | `grep -c '^CONTROL ' .ufo/waves/round-58/controls/controls-prefreeze.txt` | `20` | plan §C1 I3(a) total **20** ✔ |
| 7 | `grep -c '^CONTROL C1-F' .ufo/waves/round-58/controls/controls-prefreeze.txt` | `9` | plan §C1 I3(a) C1-F count **9** ✔ |
| 8 | `grep -c '^CONTROL C2-F' .ufo/waves/round-58/controls/controls-prefreeze.txt` | `7` | plan §C1 I3(a) C2-F count **7** ✔ |
| 9 | `grep '^CONTROLS:' .ufo/waves/round-58/controls/controls-prefreeze.txt \| tail -1` | `CONTROLS: match=20 mismatch=0` | r58 battery's own last line (not a plan number, but the receipt I3(a) is read against) |
| 10 | `grep -oE '^CONTROL [A-Za-z0-9-]+' .ufo/waves/round-58/controls/controls-prefreeze.txt \| sort \| uniq -c` | 4 K-legs (`K1-BASE`, `K2-BASE`, `K1-REF`, `K2-REF`) + 9 `C1-F*` + 7 `C2-F*` | plan §Motivating "20 controls: 9 C1, 7 C2, 2 K1, 2 K2" ✔ (4 K-legs = 2 K1 + 2 K2) |
| 11 | `grep -c 'CONTROL C1-F10' .ufo/waves/round-58/controls/controls-prefreeze.txt` / `grep -c 'CONTROL C2-F4' …` | `0` / `0` | plan §Motivating "two documented controls (`C1-F10`, `C2-F4`) never shipped" ✔ |
| 12 | `grep -n 'C1-F10\|C2-F4' plans/round-58.md` | `147:- C1-F10 — a printer stub …` / `150:  C2-F4 — a trial whose real run is single-run …` | the two controls were documented in the r58 plan ✔ |
| 13 | `grep -n 'C1-F10\|C2-F4' corpus/lessons/round-58.md` | 3 hits `C1-F10`, 1 hit `C2-F4` (line 72) | r58 lesson names both ✔ |
| 14 | `grep -c 'ten C1' /home/vgpnk/Projects/shokunin/.ufo/reports/round-58/kagi.md` | `1` (line 85: "positive reference, ten C1 item/fail-closed controls, seven C2 …") | plan §Motivating "the control set is documented three ways" (report says ten C1; lesson says `C1-F10`; script header says `C1-F9/F10`) ✔ |
| 15 | `grep -n 'launch kagi\|complete kagi' corpus/lessons/round-58-verifier-spotcheck.md` | `13:    2026-11-07T11:54:48-03:00 launch kagi round=58 pgid=2514153 …` / `14:    2026-11-07T13:36:19-03:00 complete kagi round=58; hyaku-inline attempt=1` | the two driver-digest timestamps plan I5 derives from ✔ |
| 16 | `python3 -c "datetime.fromisoformat('2026-11-07T11:54:48-03:00')…"` | delta `6091.0 s` = `101 min 31 s` → whole minutes **101** (floor); rounded = 102 | plan §C1 I5 mission duration **101 min** ✔ (checker also derives 101) |
| 17 | `git show 5fa6e658:corpus/lessons/round-58.md \| sed -n '94p'` | `- Registry 119 → 120 at the candidate (S118, S119, S120; all tier A, `mined`, `180d`). The S115–S117` | plan §Motivating quotes `Registry 119 → 120 at the candidate` at `corpus/lessons/round-58.md:94` ✔ (line number exact) |
| 18 | `git show 5fa6e658:corpus/lessons/round-58.md \| grep -n 'Registry\|source-fetches\|controls-prefreeze\.txt'` | `6:Instruments: … controls-prefreeze.txt (\`CONTROLS: match=20 mismatch=0\` …)`, `70:\| M58-3 \| … wrote \`Registry 114 → 120\` …`, `72:\| M58-5 \| … \`C1-F10\` "0", \`C2-F2\` "0" … controls-prefreeze.txt run 1 (17 MATCH / 5 MISMATCH, superseded) …`, `94:- Registry 119 → 120 at the candidate …` | every other BASE lesson line naming `Registry` / `source-fetches.tsv` / `controls-prefreeze.txt` (verbatim in §2 below) |
| 19 | `git show 5fa6e658:corpus/lessons/round-58.md \| grep -c 'source-fetches'` | `0` | the r58 **lesson** names `corpus/source-fetches.tsv` nowhere → I2 must be 0 at BASE ✔ |
| 20 | `git show 5fa6e658:corpus/lessons/round-58.md \| grep -c 'stale-lane'` | `0` | I5 must be 0 at BASE ✔ (also `grep -c 'stale' ` → 5, all `stale_basis`/`stale-premise`/… — no `stale-lane`) |
| 21 | `git show 5fa6e658:corpus/lessons/round-58.md \| sed -n '72p' \| grep -oE '\b[0-9]+\b' \| tr '\n' ' '` | `5 1 0 0 58 1 17 5` | the last lesson line naming `controls-prefreeze.txt` states neither 20 nor 9 nor 7 → I3(a) must be 0 at BASE ✔ |
| 22 | `git ls-tree --name-only 5fa6e658 plans/ \| grep supplement` ; `ls .ufo/waves/round-59/final/supplement-receipt.txt` at BASE | absent / absent | I3(b) inputs absent at BASE → I3 = 0 ✔ |
| 23 | `git ls-tree --name-only 5fa6e658 corpus/lessons/ \| grep round-58-verifier` | `corpus/lessons/round-58-verifier-spotcheck.md` (tracked at BASE) | the spot-check is a committed lane file at BASE (see §Disagreements D1) |
| 24 | `git show 5fa6e658:.ufo/waves/round-58/final/gates.txt \| grep -n 'CITATION_GATE'` | `18:CITATION_GATE: BROKEN (cites=4245 docs=145 unresolved=15 ephemeral=0 labeled=23)` | the r58 committed reading the D4 fix must improve on; no post-fix reading exists at BASE ✔ |
| 25 | `ls -l --time-style=+%H:%M .ufo/waves/round-58/final/gates.txt .ufo/waves/round-58/final/release-clock-candidate.txt` | `13:15` vs `13:30` | the r58 gate reading **predates** the receipt it supposedly fixed → D4 "no post-fix reading" ✔ |
| 26 | `git grep -n 'CITATION_GATE' 5fa6e658 -- '.ufo/waves/round-58/**'` | only `final/gates.txt:18` (all other hits are decoy/exploit fixtures) | no committed post-fix CITATION_GATE reading at BASE ✔ |
| 27 | `git show 5fa6e658:SCORECARD.md \| grep -nE '^\| (depth\|coverage\|operability\|freshness\|calibration\|adjacency) \| 9 \|'` | 6 rows, all `\| 9 \|` (lines 1912–1917, round-58 pre-move) | plan "Axes at BASE: … all 9" ✔ |
| 28 | `git show 5fa6e658:SCORECARD.md \| sed -n '742p'` | "Declared round 21: **saturation line 9, stagnation window N = 3 completed rounds** …" | plan "Saturation line 9, stagnation window N=3" ✔ |
| 29 | `git show 5fa6e658:SCORECARD.md \| grep -oE '\| (4[89]\|5[0-9]) \|\s*$' \| sort \| uniq -c` | 48, 49, 51, 52, 56, 57, 58 (one each) | plan "trials cover token/lease (r49), response wrapping (r51), KV v2 versions (r52), audit devices (r57) and ACL policies (r58)" ✔ |
| 30 | `git show 5fa6e658:SCORECARD.md \| grep -c 'OpenBao audit-device custody trial'` / `… 'OpenBao ACL-policy semantics trial'` | `3` / `2` | capability rows for r57/r58 exist at BASE ✔ |
| 31 | `git grep -rl 'transit' 5fa6e658 -- corpus/knowledge/` | `corpus/knowledge/nist-key-management-parts-withdrawal.md`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | plan "no executed OpenBao transit mechanic" — both matches are prose (see §Disagreements D3) |
| 32 | `git cat-file -e 5fa6e658:corpus/openbao-transit-trial.sh` | `fatal: path 'corpus/openbao-transit-trial.sh' exists on disk, but not in '5fa6e658'` | plan C2 "BASE 0: the trial does not exist at BASE" ✔ |
| 33 | `git show 5fa6e658:SCORECARD.md \| grep -oE '\| 5[78] \|\s*$'` (capability table first-working) | `57`, `58` | plan "a capability entered round 57 (audit devices) and round 58 (ACL policies)" ✔ |
| 34 | `python3 -I -B plans/round-59-c1-check.py --root <BASE tree copy> --repo <lane> --no-challenge` | `C1_ROUTED: value=5 population=5 i1=0 i2=0 i3=0 i4=0 i5=0 guard=0` (item lines: `i1 FAIL registry lesson=119->120 derived base(1b13f5da)=117 land(be8705f8)=120`; `i2 FAIL no lesson line names corpus/source-fetches.tsv`; `i3 FAIL … supplement=missing…`; `i4 FAIL citation gate-U=None lesson-U=None`; `i5 FAIL … lesson_line=missing`) | plan §C1 K2 "the BASE census must print `value=5 population=5`" ✔ |
| 35 | same checker, guard-bearing leg at the BASE tree | `C1_ROUTED: value=FAIL population=5 i1=0 i2=0 i3=0 i4=0 i5=0 guard=0`; JSON: `challenge: copy delta arrow 120->121: value=5 expect=6` | plan §C1 "its guard leg `value=FAIL … guard=0`" ✔ and confirms the plan A3 reading (the +1 challenge cannot fire while I1 is unresolved) |
| 36 | `bash plans/round-59-c1.sh 5fa6e658…` (driver, BASE) | `C1_ROUTED: value=FAIL population=5 i1=0 i2=0 i3=0 i4=0 i5=0 guard=0` + `c1-driver: checker rc=1`, exit 1 | driver and checker agree with the plan's BASE census ✔ |
| 37 | `ls .ufo/waves/round-59/final/` (live) | `citation-gate-r59.txt`, `supplement-receipt.txt` | I3(b)/I4 receipts exist in the candidate tree |
| 38 | `tail -1 .ufo/waves/round-59/final/supplement-receipt.txt` | `SUPPLEMENT: match=2 mismatch=0` | plan §C1 I3(b) frozen line `SUPPLEMENT: match=2 mismatch=0` ✔ (exact) |
| 39 | `grep -n 'C1-F10\|C2-F4' plans/round-58-controls-supplement.sh` | lines 7, 13, 57, 106 (C1-F10) and 108, 126, 156 (C2-F4) | plan I3(b) "names both `C1-F10` and `C2-F4`" ✔ |
| 40 | `tail -1 .ufo/waves/round-59/final/citation-gate-r59.txt` | `CITATION_GATE: BROKEN (cites=1618 docs=48 unresolved=6 ephemeral=0 labeled=9)` | plan I4 receipt form `CITATION_GATE: … unresolved=<U> …` ✔; U = **6** (see §4 scope caveat) |
| 41 | `bash corpus/claim-ledger.sh citations` (live lane, **default** doc set) | last line `CITATION_GATE: BROKEN (cites=4298 docs=146 unresolved=14 ephemeral=0 labeled=23)`, exit **1**; 14 UNRESOLVED lines, 23 LABELED, 0 EPHEMERAL | the plan's plain-invocation reading of the gate (item 7 of my brief): **unresolved=14, ephemeral=0, labeled=23, exit 1 (not 0)** |
| 42 | `bash corpus/claim-ledger.sh citations` (live lane, the scope named in the receipt header) | last line `CITATION_GATE: BROKEN (cites=1618 docs=48 unresolved=6 ephemeral=0 labeled=9)` | U=6 as recorded in the receipt and lesson (I4 satisfied) |
| 43 | `git show 5fa6e658:.ufo/waves/round-58/final/gates.txt \| tail -1` | `CITATION_GATE: BROKEN (cites=4245 docs=145 unresolved=15 ephemeral=0 labeled=23)` | the r58 baseline the r59 reading is compared against (U moved 15 → 14 default-set, or 15 → 6 scoped) |

## 2. BASE lesson lines naming `Registry` / `source-fetches.tsv` / `controls-prefreeze.txt` (verbatim, at BASE `5fa6e658`)

```
  6: Instruments: `plans/round-58-c1-check.py`, `plans/round-58-c1.sh`, `plans/round-58-c2.sh`, `plans/round-58-controls.sh`; pre-freeze receipt `.ufo/waves/round-58/controls/controls-prefreeze.txt` (`CONTROLS: match=20 mismatch=0`; the earlier run that read `match=17 mismatch=5` is kept superseded as `controls-prefreeze-run2-superseded.txt`, M58-5).
 70: | M58-3 | `landing` — the C1 checker's challenge made its "broken copy" next to the measured tree (the fleet root) and one leg wrote `Registry 114 → 120` into the live `SCORECARD.md` | observed in `git diff` at 12:20; the counter's own A3 check then read `i4=0` | none | scratch is `TMPDIR`-confined, `run_challenge` refuses a copy that resolves at/inside the measured root, the wrapper asserts the same, and the battery's C1-F1..C1-F10 re-run the legs; QM74 |
 72: | M58-5 | `overclaim` — the first control set carried expectations its instruments could not produce (`C1-F4` "1", `C1-F10` "0", `C2-F2` "0"), so five controls mismatched on the first battery | `.ufo/waves/round-58/controls/controls-prefreeze.txt` run 1 (17 MATCH / 5 MISMATCH, superseded) | the reviewer's control review | the expectations are corrected before the recorded reading (A5): F4 reads FAIL by structure, the wrapper prints FAIL when its guard fails, and C2-F2/F4 became the load-bearing pair for the counter's conjunction |
 94: - Registry 119 → 120 at the candidate (S118, S119, S120; all tier A, `mined`, `180d`). The S115–S117
```

No BASE line names `corpus/source-fetches.tsv` (count 0) and none matches `stale-lane` (count 0).

In the **live candidate** tree the same file additionally carries the round-59
append-only correction block (lines 109–137): `115:- Correction D1: Registry 117 → 120 at the candidate …`,
`119:- Correction D2: \`corpus/source-fetches.tsv\` added 6 rows …`,
`121:- Correction D3: \`…controls-prefreeze.txt\` census is 20 \`CONTROL \` lines total: 9 \`CONTROL C1-F\` and 7 \`CONTROL C2-F\` …`,
`123:- Correction D5: stale-lane: the round-58 mission ran … = 101 whole minutes and the row reads progressing …`.
Checker on the live tree: `i1 HOLD registry lesson=117->120`, `i2 HOLD … first-int-after-name=6`,
`i3 HOLD … supplement=ok receipt_end=SUPPLEMENT: match=2 mismatch=0`, `i4 HOLD citation gate-U=6 lesson-U=6`,
`i5 HOLD stale-lane … lesson_line=stated`.

## 3. BASE item readings (does each condition already hold at BASE? — it must not)

| item | BASE reading | deciding line / file |
|---|---|---|
| I1 | `BASE i1=0` | `corpus/lessons/round-58.md:94` reads `Registry 119 → 120`; derived base=117 / land=120 → 119 ≠ 117 |
| I2 | `BASE i2=0` | no BASE lesson line names `corpus/source-fetches.tsv` (count 0) → no line can carry the delta 6 |
| I3 | `BASE i3=0` | (a) last naming line `corpus/lessons/round-58.md:72` states `17 MATCH / 5 MISMATCH`, not 20/9/7; (b) `plans/round-58-controls-supplement.sh` and `.ufo/waves/round-59/final/supplement-receipt.txt` absent at BASE |
| I4 | `BASE i4=0` | `.ufo/waves/round-59/final/citation-gate-r59.txt` absent at BASE; no BASE lesson line names it |
| I5 | `BASE i5=0` | no BASE lesson line matches `stale-lane` (count 0) |

All five unresolved at BASE ⇒ `value=5 population=5` as the plan requires, and the
guard leg reads `value=FAIL … guard=0` because the +1 challenge cannot fire while
I1 is itself unresolved (plan A3 reading confirmed by the checker JSON).

## 4. Scope caveat on I4's `U` (for the L1, not an amendment)

The plan's I4 text pins only "the receipt's last line matches `CITATION_GATE: … unresolved=<U> …`
and the lesson's last line naming that path states the same `U`" — it does **not** pin the
document scope of the gate. Measured:
* the landed receipt runs the gate over a **narrowed 48-doc scope** (its own header names it:
  `AGENTS.md PROVINCE.md SCORECARD.md SHONEN.md SKILL.md corpus/README.md corpus/knowledge/*.md
  corpus/lessons/round-58.md corpus/lessons/round-59.md`) → `unresolved=6`;
* `bash corpus/claim-ledger.sh citations` with the **default** set on the same live tree →
  `unresolved=14` (docs=146), exit 1;
* the committed r58 baseline is `unresolved=15` (docs=145).

So `U` is scope-dependent (6 / 14 / 15), and the frozen I4 condition is satisfied by any
self-consistent pair. A reader who re-runs the plan's own plain invocation will not
reproduce the receipt's `U=6`. Flagging for the L1's calibration call; the frozen text
itself is unchanged and I did not touch it.

## 5. §Disagreements — plan statements my measurement contradicts

**No numeric disagreement.** Every number the round-59 C1 items compare re-derives
exactly as the plan states: I1 117/120, I2 6, I3 20/9/7, I5 101, BASE census
`value=5 population=5` with guard leg `value=FAIL … guard=0`, and the r58 control-set
composition 20 = 9 C1 + 7 C2 + 2 K1 + 2 K2.

Four **prose** statements in the (amended, uncommitted) plan are contradicted by the tree
and are reported, not amended:

* **D1 — plan §Motivating evidence, "no committed line states the `corpus/source-fetches.tsv`
  delta that the spot-check measured as 6 rows".** Contradicted as written: the spot-check
  file is itself tracked in the lane at BASE (`git ls-tree 5fa6e658 corpus/lessons/` →
  `round-58-verifier-spotcheck.md`) and its line 170 states "the BASE→tip diff adds **six**
  rows (S115–S120; rows 114 → 120)" with the command `git diff 1b13f5da 0a9b52ba … ⇒ 6`.
  The defensible narrower statement is "no committed line of the round-58 **lesson** names
  `corpus/source-fetches.tsv`" (measured count 0). The number 6 itself is correct.
* **D2 — plan §Motivating evidence, "the round-58 report carries no stale-lane line".**
  Contradicted: the report carries `- Stale-lane: respawn-per-round driver; no other
  mission of this lane is open. This round ran \`launch kagi round=58\` 11:54:48 −03:00 and
  completed after the report lands.` at
  `/home/vgpnk/Projects/shokunin/.ufo/reports/round-58/kagi.md:146`, identically at the
  spot-check's cited commit `d7875c9` and at fleet HEAD. What the report lacks is the
  progressing/silent determination and the 101-minute duration (D5's substance) — not the line.
* **D3 — plan §Motivating evidence, "`grep -rl 'transit' corpus/knowledge/` matches only
  entries that mention the Vault transitive trust boundaries or NIST key-management prose".**
  The NIST half is right (`nist-key-management-parts-withdrawal.md`, matches on "transition").
  The other match, `vault-openbao-token-lease-lifecycle.md`, matches on the word "transit" in
  the lease-scope sentence "no database, transit or other engine" — no knowledge entry
  contains the string "transitive" (measured count 0). The load-bearing claim (no transit
  engine mechanic in `corpus/knowledge/`) holds.
* **D4 — plan A4 item 1, "K1-BASE, K1-BASE-GUARD, K2-BASE, K1-REF, C1-F1..C1-F8,
  C2-F1..C2-F8 — 20 controls".** The landed `plans/round-59-controls.sh` has **21** report
  legs / 21 distinct ids: the enumeration omits `C1-F7b` (the printer-stub leg, line 138)
  that the script actually reports. A1–A4 are uncommitted amendments, so this is the L1's to
  correct before committing.

* **D7 — the receipt's `U` no longer reproduces against the current tree (measurement drift).**
  The landed receipt `.ufo/waves/round-59/final/citation-gate-r59.txt` was written at
  `14:33:26` and reads `CITATION_GATE: BROKEN (cites=1618 docs=48 unresolved=6 …)`.
  `SCORECARD.md` was then edited at `14:34:47` (the post-move table replaced the
  `c1-candidate-tree` / `c2-candidate-tree` citation rows), and the round-58 lesson was
  edited to add its `Correction D4` line. Re-running the **same scope** named in the
  receipt header at `14:37` now yields
  `CITATION_GATE: BROKEN (cites=1631 docs=48 unresolved=5 ephemeral=0 labeled=9)` — the
  two `SCORECARD.md:1971/1972` UNRESOLVED rows are gone and one
  `corpus/lessons/round-58.md:122` row appears instead: 6 → **5**. The receipt and the
  lesson still agree with each other (both say 6) so plan I4 reads HOLD and the checker's
  `i4` is 1, but the receipt is a snapshot of a tree state that no longer exists. Any
  later re-run of the gate will not reproduce `U=6`. The L1's call; I did not touch the
  receipt, the lesson or the plan.

Two further observations that are not contradictions of plan numbers:

* **D5 — plan §Motivating evidence, "where the claim BASE holds 117 rows".** Measured:
  the round-59 claim BASE `5fa6e658` holds **120** rows; 117 is the count at the **round-58**
  claim BASE `1b13f5da`. The number is right for the D1 reading the sentence serves, but
  "the claim BASE" is ambiguous inside a round-59 plan whose own claim BASE is `5fa6e658`.
* **D6 — plan §C2 POP / §Pre-freeze prose** refers to S121/S122 (the transit sources opened
  this round). At BASE the registry stops at S120 (measured), so S121/S122 are round-59
  additions; the plan's C2 prose is forward-looking and consistent with that.

## 6. Tooling

No installs were performed by this seat; no pacman/uv/npm transaction was run. The only
tools used were the pre-existing `git`, `grep`, `sed`, `python3` and `bash` in the host
image. Nothing was written into the lane's tracked files, the fleet root, or any sibling
lane; the only writes are this seat's two artifacts under
`.ufo/waves/round-59/` (build receipt + wave report) and the scratch tree, which was removed.

### 6.1 One supplementary measurement was aborted, and nothing cited depends on it

I additionally launched a *synthetic fleet-root* copy of the BASE tree (a `git archive` of
`5fa6e658` under a scratch parent carrying `MANIFEST.json` + `.ufo/`) to obtain a
lane-shaped BASE reading of the citation gate. That run was still walking the doc set when
I deleted the scratch tree at hand-off, so it produced no verdict and I cite nothing from
it. The gate readings I do cite are the two completed runs on the live lane tree
(unresolved=14, cites=4298 then 4320 as the tree grew, exit 1) and the committed r58
baseline in `.ufo/waves/round-58/final/gates.txt` (unresolved=15) — none of which depends
on the aborted run.

SEAT-STATUS: complete
