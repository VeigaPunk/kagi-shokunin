# kagi round 38 — non-author verifier spot-check

author: hyaku closure (non-author integrator, @m_zfl)
round: kagi round 38 (attempt 1), lane tip under review `88374f9539e741cbc6e07505f4c09e42472ee8d1`
report: `.ufo/reports/round-38/kagi.md` (fleet commit `c3df25ec746e2b2cd44642f2998830fb7df49c59`)
dispatch digest (`.ufo/watchdog.log`, mutable; copied at closure):
- `2026-11-05T05:46:48-03:00 launch kagi round=38 pgid=2744042 driver=hyaku-inline attempt=1` (line 2785 at read time)
- `2026-11-05T07:09:00-03:00 complete kagi round=38; hyaku-inline attempt=1` (line 2800 at read time)

This artifact is lane-external. The lane did not author it and did not edit any lane-authored file.
Commands below were run by the integrator; gate instruments were not executed (Gate standard: committed evidence verified, sibling gates not run).

## 1. Step-1 conformance

| check | command / evidence | result |
|---|---|---|
| report committed by lane identity, pathspec-limited | `git log --format='%an %ae %H' -- .ufo/reports/round-38/kagi.md` → `kagi-shokunin kagi@shokunin.local c3df25ec…` (107 insertions, one file) | pass |
| `SHONEN` heading, one line per box | report §SHONEN: four lines, `[~]` each with pointer; `grep -c '^- \[x\]' SHONEN.md` → `0` | pass |
| cited lane commits are ancestors of the branch | `git merge-base --is-ancestor <h> master` for `8c48b7d`, `289e808`, `b944735`, `88374f9`, `a916f4a` | all yes |
| lane has no uncommitted round work; pushed | `jj-lane.sh state` → `branch=master local=88374f9… remote=88374f9… ahead=0 behind=0`; `git status --porcelain` empty; `git ls-remote origin refs/heads/master` → `88374f9…` | pass |
| prompt carries template contract | `.ufo/prompts/kagi-round-38.md` §1–§5 match `templates/round-prompt.md` verbatim under substitution; §6 hyaku addendum is the permitted campaign addendum | pass |
| marker vs report | report carries work, evidence pointers, commit citations, Sources & frontier, Trend verdicts, SHONEN | real report, not a marker → status `ok` |
| fleet census (frontier step) | `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → 19 W04 duplicate-URL warnings, final line `kagi ok …/corpus/SOURCES.md`, exit 0 | pass |

Status-neutral conformance defects (named, not barring admission):
- **CD-1 (report §Work performed / §Before→after):** the report states "Frozen predicates, controls and kill rules were not amended after data", but C2's declared axis was `calibration` in `plans/round-38.md` and was relabelled `operability` after the counter read 3. The axis label is part of the declared claim; the relabel is an amendment after data, and the report does not name it as one.
- **CD-2 (report §Before→after, C2 row):** the lane self-grades C2 "verified as operability". Verdicts are the closure's to set (step 2); the lane's self-verdict is recorded as the lane's own reading only.
- **CD-3 (report §Stale-lane):** the report says "no other mission of this lane is open"; not contradicted by any dispatch line read here.

## 2. Claims

### C1 — freshness, located-quote count 0 → 5 — re-measured and verified

Re-measurement, plain Python over committed bytes (`git show 88374f9…:<path>`; no sibling gate executed). For each row of `corpus/quote-bodies.tsv`: body bytes exist; sha256 and byte count equal the capture row's (`corpus/source-fetches.tsv` cols 10, 11 and 9 via the row's sha column); declared quote equals capture column 13; quote occurs verbatim in the id's registry row in `corpus/SOURCES.md`; quote occurs at the declared offset in the body.

```
S089 .ufo/waves/round-37/capture/S089-vault.body   off=726   OK  len(quote)=21 words=1
S090 .ufo/waves/round-37/capture/S090-openbao.body off=729   OK  len(quote)=21 words=1
S091 .ufo/waves/round-37/capture/S091-python.body  off=1583  OK  len(quote)=28 words=2
S092 .ufo/waves/round-38/capture/S092-vault-tag.body   off=21886 OK len(quote)=56 words=6
S093 .ufo/waves/round-38/capture/S093-openbao-tag.body off=21886 OK len(quote)=56 words=6
PLAIN_C1 located=5 rows=5
```

BASE `a916f4a`: `git cat-file -e a916f4a…:corpus/quote-locate.py`, `…:corpus/quote-bodies.tsv` both absent → counter reads 0, consistent with the report.
Evidence-verified (committed, not re-executed): `.ufo/waves/round-38/controls/prefreeze-gate.txt` → `OK c1_nowork 0`, `OK c1_positive_full 5`, `OK c1_forge_quote 4`, `OK c1_forge_bytes 4`, `OK c1_forge_registry 4`, `PREFREEZE: CLEAN (controls=7 mismatch=0)`; `plans/round-38.controls.tsv` lists the same expectations.
Ceiling carried from the lane's own text and confirmed by reading the frozen predicate: committed bytes only; a body rewritten together with its capture row passes; no live re-fetch; no check that a quote supports the teaching.

**C1 verdict: verified.** Measured 0 → 5 by this closure's own plain re-measurement.

### C2 — calibration, planted lane-tree writes detected 0 → 3 — evidence-verified; NOT verified as declared

- Evidence-verified (committed, not re-executed): predeclaration pre-freeze gate `OK c2_nowork 0`, `OK c2_positive 3` (`prefreeze-gate.txt`). The candidate and close commits quote the selftest as `LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok` and `--no-mutate` as `detected=0` (SCORECARD round-38 row; LOG.md round-38 section). The committed guard `corpus/laneguard.sh` exists at `88374f9`; absent at BASE.
- The counter is operational. The **declared axis is not**. `plans/round-38.md` declares C2 as a calibration move ("lane-tree write guard closes the round-37 M37-2 self-description, 0 → 3"). The close SCORECARD row reads `calibration | 9 → 9 | No calibration move is claimed` and `operability | 9 → 9 | C2 … is the operability move`. A committed guard is an operability artifact; it does not change whether the round-37 self-description matches the repo. That match came from the in-lesson erratum (`corpus/lessons/round-38.md` §M37-2), not from the guard.
- Ruling: the declared claim (calibration) has no before→after on its declared axis. The measured move is real but was not declared before data. The claim does not verify as declared. It is not admitted. Recorded as unmet; the operator may rule otherwise, and that ruling would be the operator's, not this closure's.

**C2 verdict (as declared): not verified → unprovable on calibration.**

## 3. Per-axis verdicts (SCORECARD diff `a916f4a…88374f9…`)

SCORECARD diff: round-38 rows are additive; every axis stays 9 → 9 in the pre-move and post-move tables. Nothing is harmed.

| axis | verdict | reason |
|---|---|---|
| freshness | improved | C1 verified by re-measurement 0 → 5 with committed forgery controls at 4; score stays 9 (same convention as round 37's freshness row) |
| calibration | unprovable | C2 declared here; no calibration move; relabelled to operability after data (CD-1, CD-2); no calibration claim verifies |
| operability | unchanged | score 9 → 9; the guard is a real committed artifact but no operability claim was declared, so no operability verdict is granted |
| depth | unchanged | 9 → 9; no mechanism change |
| coverage | unchanged | 9 → 9; registry 91 → 93 with two tier-A rows corroborating held ground |
| adjacency | unchanged | 9 → 9; no sibling surface claimed |

No axis is harmed. Admission: **not admitted**, because C2 does not verify as declared (AXES: "A round is admitted only if every claim verifies"). Verdict class: honest stop, no harm.

## 4. Discernment spot-check (LEARNING.md)

Source: `corpus/lessons/round-38.md` §Gate. Each item re-opened by the integrator.

| # | item | decision | re-opened source | agree/disagree | reason |
|---|---|---|---|---|---|
| 1 | S092 Vault release tag page v2.2.1 | admit (tier A, mined, row) | live `curl -fsSL --compressed https://github.com/hashicorp/vault/releases/tag/v2.2.1` → HTTP 200, 32559 bytes; `grep` shows `<title>Release v2.2.1 · hashicorp/vault · GitHub</title>` and `datetime="2026-10-22T21:59:36Z"`; committed body `S092-vault-tag.body` has the title at offset 21886 | agree | the source is the maintainer's own release page; the title quote is verbatim and located; the live page bytes differ from the committed capture (volatile body), which the lesson's profile anticipates and which does not touch the quote |
| 2 | S093 OpenBao release tag page v2.7.2 | admit (tier A, mined, row) | live `curl` → HTTP 200, 36365 bytes; `<title>Release v2.7.2 · openbao/openbao · GitHub</title>`, `datetime="2026-10-26T20:24:37Z"`; committed body title at offset 21886 | agree | same reasoning; the datetime matches the row's teaches cell |
| 3 | `rendered-text-v1 locate` as the quote matcher | reject (candidate, not adopted) | `corpus/rendered-text-v1.py`: step 3 "tags" replaces every `<[^>]+>` with one space, so a normalized text cannot contain the raw `<title>…</title>` markup the quote carries | agree | the tool is structurally unable to match a markup-bearing quote against raw bytes; the rejection is correct and its reason is grounded in the source, not in taste |
| 4 | bare version row citing only the release feed | reject (candidate, no row written) | no registry row exists to re-open; the candidate was never written | unprovable (could not re-open) | the rejection's stated reason (a tag page is a second surface) is plausible and is consistent with items 1–2, but the candidate itself cannot be checked; graded `unprovable`, not harmed |
| 5 | newly written registry rows: ≤25-word quote check (S092, S093) | admit row quotes | plain measurement: each quote 6 words, 56 bytes; located at 21886 in the committed body (table in §2, C1) | agree | the quote length and location meet the contract |

Spot-check result: admits agree on 2 of 2 re-opened; the reject re-opened (item 3) agrees; item 4 could not be re-opened. The gate's admit and reject decisions that were checkable all agree.

## 5. Trend verdicts (evidence-bound)

- **expansion: unchanged.** Two tier-A rows added on held ground (vendor release identity corroborating S089/S090); `entries_sourced` stays 14; no admitted `knowledge/` entry on uncovered ground. Net new admitted entries on uncovered ground: none. Not `improved`.
- **quality: unchanged.** S089–S091 re-hashed against committed bytes and located (§2, C1); no admitted entry failed its re-check. R37-V2 (release-clock feed rows S034/S035/S036/S039 superseded but still bound) stays open debt, measured and recorded, not left unmarked, so not `harmed`; no weaker entry was superseded, so not `improved`.
- **discernment: improved.** Spot-check §4: both re-opened admits agree; the re-opened reject agrees with its reason; the second reject could not be re-opened (`unprovable`, not a disagreement). The lane's own critic/scout falsifications (ten sentences corrected in the close) are recorded in the lesson, which is the disagreement-becomes-lesson path. Sample is small (3 re-opened decisions); the verdict is bounded by that.

## 6. Routed defects for the lane's next round

1. **R38-D1 (C2 axis).** A claim's declared axis is frozen with its predicate. Re-labelling after the counter read is an amendment. Round 39 declares any calibration claim with a before→after on the calibration axis, or declares operability at the start.
2. **R38-D2 (report wording).** Remove "frozen predicates … not amended after data" or name the C2 axis relabel as an amendment (CD-1); replace the lane's self-verdict on C2 with the claim-as-declared reading (CD-2).
3. **R38-D3 (receipt).** `.ufo/waves/round-38/controls/observe-r38.json` is recorded as evidence, not a pin: 30 `RECEIPT-MISMATCH` on `observed_at`. Any re-pin is a separate, declared claim.
4. **R38-D4 (frozen-counter gaps, routed by the lane; confirmed as open).** Body symlink followed out of root; superscript-digit traceback; duplicate ids; surviving mutants M2, M3, M5, M6 (quote) and G3 (guard). These are the lane's round-39 amendment queue.
5. **R38-D5 (ledger).** `R38-03` is POLICY pending operator registration of `corpus/quote-locate.py` (L0 `kagi | round-38 | …`, fleet commit `0a1c648b84108adb33888c47377b909d97ea9f3d`). Operator-owned; not closed here.
6. **R38-D6 (quality debt).** R37-V2 release-clock re-point remains open; R37-V4 (anchor immutability, `2.2.10` boundary) routed to round 39.

## 7. Operator notes (not lane work)

- SHONEN: all four boxes remain `[~]` (`grep -c '^- \[x\]' SHONEN.md` → 0). This closure signs no box. Promotion is operator-owned.
- The quote gate's ceiling (body and capture row rewritten together pass) is real and stays named; it is a reason to keep the gate's committed evidence and capture bodies immutable, not a reason to reject C1.
