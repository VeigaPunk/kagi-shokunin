# Draft — `considerthese` section for `corpus/lessons/round-47.md`

## Inventory (read at `/home/vgpnk/Projects/shokunin/kagi-shokunin/considerthese/`)

```
2026-10-19.md   5725 B
2026-10-20.md   9048 B
2026-10-21.md   9455 B
2026-10-22.md  10626 B
2026-10-23.md   3065 B
2026-10-24.md   2295 B
2026-10-25.md   5255 B
2026-10-26.md   3681 B   <- newest (8 files, all dated; no BACKLOG.md, no undated file)
```

`ls -la considerthese/` mtimes are 2026-10-19 … 2026-10-29 00:36; the newest *content* date is
`2026-10-26.md`. The directory is operator-authored input and was not edited.

## Newest file: `considerthese/2026-10-26.md`

Its four `## Self-improvement suggestions (proposals only, not applied)` items
(`considerthese/2026-10-26.md:47`), one line each — open? / does it fit round 47's claims?

| # | proposal (line) | state measured at round-47 BASE `252ef1ca` | fits this round? |
|---|---|---|---|
| 1 | repair-only release path under a HOLD (`:49`) | **open, unbuilt.** No mechanism in the lane; and the premise expired — `SCORECARD.md:14` reads `lane-status: open — as-of:2026-11-04 — dispatch unblocked`, so there is no HOLD to release from. Operator policy, never lane-built. | **No.** It is a dispatch-posture change; round 47's claims are C1 census calibration and C2 fired-clock re-verification (`plans/round-47.md`), neither of which is served by a release path. |
| 2 | machine-readable lane status in one file (`:55`) | **landed, round 31.** `SCORECARD.md:14` is the `lane-status:` line and `SCORECARD.md:16-18` records it as "mined from `considerthese/2026-10-26.md` proposal 2"; SD5 reads it for red ids (`corpus/self-description-sweep.sh:19-21`, `:379-395`). Residual: only SD5 reads it — no gate reports the as-of date. | **No.** Already landed; the residual is a new surface, not a claim this round can hold. |
| 3 | `KNOWN_DEFECT: D1` qualifier on a `CLEAN` verdict (`:60`) | **open as stated, but its motivating symptom is stale.** `grep -c 'KNOWN_DEFECT' corpus/release-clock.py` → `0`; and the quoted fail-open does not reproduce at BASE (`corpus/release-clock.py:789` matches `Python 3.15.1.` and `Python 3.15.01.`; executed, `build/K47ScribeLesson/regex-test.txt`), a closure already committed at `corpus/lessons/round-33.md:17`. | **Touches C2's instrument, not taken.** C2's frozen GATE leg is `python3 corpus/release-clock.py` exiting 0 with `RELEASE_CLOCK: CLEAN` (`plans/round-47.md` §C2); a qualifier line would require that match to be pinned differently — a counter amendment, and the predicate is frozen. |
| 4 | `considerthese/BACKLOG.md` (`:64`, carried from 2026-10-24) | **open, refused in round 32** as a second, operator-owned status surface (`corpus/lessons/round-33.md:17`); the file is absent (`ls considerthese/BACKLOG.md` → `No such file or directory`). | **No.** Bookkeeping in an operator-authored directory; no claim surface. |

Carried older set: the five 2026-10-25 suggestions — differential tokenizer test, gate-output receipts,
round-shape validation at plan freeze, `provider_events` in wave records, claim sensitivity pre-flight —
are still "not acted on" per `considerthese/2026-10-26.md:39-42`. None is a claim this round holds: the
nearest, round-shape validation at plan freeze, would police `plans/round-47.md` itself, and this
round's frozen plan is already predeclared.

## Proposed section text

```markdown
## considerthese

The latest file is `considerthese/2026-10-26.md` (newest of eight dated files, 2026-10-19 … 2026-10-26).
Its proposals: **1** (repair-only release path under a HOLD) is unbuilt operator policy and its premise
has expired (`SCORECARD.md:14`, `lane-status: open — as-of:2026-11-04`); **2** landed in round 31 and
SD5 reads it; **3** (`KNOWN_DEFECT` qualifier) is still absent from `corpus/release-clock.py`
(`grep -c` → 0), while its quoted symptom no longer reproduces at BASE (`corpus/release-clock.py:789`,
executed in `build/K47ScribeLesson/regex-test.txt`) — the split is recorded as M47-3; **4** was refused
in round 32. **No proposal is taken this round — reason: no claim slot.** The two frozen claims are C1
census calibration and C2 fired-clock re-verification; proposal 3 is the only one that touches a claimed
surface (C2's GATE leg reads `RELEASE_CLOCK: CLEAN`), and accommodating it would amend a frozen
predicate. `considerthese/` is operator-authored input and was not edited.
```

## One caution for the integrator

Proposal 3's stated premise is stale, but "the qualifier is absent" and "the defect is live" are two
different facts; rounds 41–44 carried only the first as "remain unimplemented"
(`corpus/lessons/round-41.md:231`, `corpus/lessons/round-44.md:63`). Keep them split in the committed
text, or the next round re-reads a closed defect as open.
