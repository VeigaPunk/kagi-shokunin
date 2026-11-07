# R62ExecC1Grammar — C1 checker grammar hardening receipt
Seat: R62ExecC1Grammar (kagi round 62, wave w1).
File owned/changed: `plans/round-61-c1-check.py` (in place; no new file).
sha256: `f2afd9b8f5382cdf8b8914546bb8fcb73d135854e6e546c5012fb7df63eca9c0`
wc -l: 1710 (was 1454).
Grammar implemented: plans/round-62.md §C1 five rules, exactly; I6 clause (d) per §Amendment A1 (L1 message 2026-11-07): no `times are correct` / `times are right` / `is correct` / `are correct` (case-insensitive) on the correction line. I7 pairing tested after stripping `"..."` spans (the quoted superseded arithmetic is the forgery of record, not the assertion — QM79).

## Selftest
Command: `cd /home/vgpnk/Projects/shokunin/kagi-shokunin && python3 -I -B plans/round-61-c1-check.py --selftest`
Output: `C1_CHECK_SELFTEST: PASS (cases=75)`
rc=0
(predicate spelling `cases=N`; 75 >= 57. Existing 52 cases kept; +23 new: B3..B7, B6 whole-line variant, I6 benign conclusion, P3..P5 item + full-tree, K5 needle uniqueness + negator-removed witness, 7 grammar unit cases.)

## I6 readings (L1 Amendment A1 ask)
- real line 179 (unmodified copy): `c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=none`
- B6 tail-only denial (`the paragraph's times are correct.`): `c1: i6 FAIL launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=are correct|times are correct`
- reviewer whole-line variant (no launch line, no superseded stamp, denial phrase): `c1: i6 FAIL the line does not name the driver launch line`; tree reads `C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0`, rc=1

## BASE census with the round-61 checker (pre-change bytes, accepted=5 witness)
Command per copy: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --no-challenge` (copies built under scratch by tar of the lane tree, --exclude=.git/.jj, anchor->replacement applied exactly once).
- base: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- base: `rc=1`
- b3: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- b3: `rc=1`
- b4: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- b4: `rc=1`
- b5: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- b5: `rc=1`
- b6: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- b6: `rc=1`
- b7: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- b7: `rc=1`
- p3: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- p3: `rc=1`
- p4: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- p4: `rc=1`
- p5: `C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
- p5: `rc=1`

## Hardened checker battery (the deliverable readings)
Command per copy: `python3 -I -B plans/round-61-c1-check.py --root <copy> --repo <lane> --no-challenge` (same copy recipe).
### base
`c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance`
`c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three`
`c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=absent`
`c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=none`
`c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-fraction-percentage-pairs-present`
`C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
`rc=1`
### b3
`c1: i3 FAIL a7-at-line=331 block-end=331 amendment=incomplete lesson-line=second-instance`
`c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three`
`c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=absent`
`c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=none`
`c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-fraction-percentage-pairs-present`
`C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=0 i4=1 i5=1 i6=1 i7=1 guard=0`
`rc=1`
### b4
`c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance`
`c1: i4 FAIL candidates=1 last-line=missing-quote-ids-or-negated-three`
`c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=absent`
`c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=none`
`c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-fraction-percentage-pairs-present`
`C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=0 i5=1 i6=1 i7=1 guard=0`
`rc=1`
### b5
`c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance`
`c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three`
`c1: i5 FAIL derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=present`
`c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=none`
`c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-fraction-percentage-pairs-present`
`C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=0 i6=1 i7=1 guard=0`
`rc=1`
### b6
`c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance`
`c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three`
`c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=absent`
`c1: i6 FAIL launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=are correct|times are correct`
`c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-fraction-percentage-pairs-present`
`C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0`
`rc=1`
### b7
`c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance`
`c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three`
`c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=absent`
`c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=none`
`c1: i7 FAIL derived 3/16=18.75 4/16=25 last-line=pair-missing-or-swapped`
`C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=0 guard=0`
`rc=1`
### p3
`c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance`
`c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three`
`c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=absent`
`c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=none`
`c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-fraction-percentage-pairs-present`
`C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
`rc=1`
### p4
`c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance`
`c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three`
`c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=absent`
`c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=none`
`c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-fraction-percentage-pairs-present`
`C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
`rc=1`
### p5
`c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance`
`c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three`
`c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=absent`
`c1: i6 HOLD launch=yes distinct-stamps=5 in-derived=4 derived-set=9 superseded-stamp=15:09:28,16:34:37 denial=none`
`c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-fraction-percentage-pairs-present`
`C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=0`
`rc=1`

## Guard-mode on the unmodified copy (challenge + stub legs)
Command: `cd <copy of base> && python3 -I -B plans/round-61-c1-check.py --root . --repo <lane> --verbose`
Output: `c1-guard: copy delta deletions 1->2 on the evaluated I5 line: value=1 expect=1; stub value=0 fails=True`
`C1_ROUTED: value=0 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=1 i7=1 guard=1`
rc=0

## Whole-line variant tree (scratch evidence)
`=== b6wholeline`
`c1: i1 HOLD derived results=16 output=3824 supersedes-lines-after=1 last-line=states-derived-count-and-names-mutants.md`
`c1: i2 HOLD selftest[rc=0 cases=36 PASS-line] registry[selftest-cell='`bash plans/round-60-c2.sh --selftest` ⇒' none-own=absent] mutation[mutated rc=1 finding=yes]`
`c1: i3 HOLD a7-at-line=331 block-end=331 amendment=names-item-form-probe-asserts-withdrawn lesson-line=second-instance`
`c1: i4 HOLD candidates=1 last-line=quotes-names-D1-D2-D3-and-asserts-three`
`c1: i5 HOLD derived insertions=1 deletions=1 stated=1/1 revs=both mechanism=rewritten-in-place negator=absent`
`c1: i6 FAIL the line does not name the driver launch line`
`c1: i7 HOLD derived 3/16=18.75 4/16=25 last-line=both-fraction-percentage-pairs-present`
`C1_ROUTED: value=1 population=7 i1=1 i2=1 i3=1 i4=1 i5=1 i6=0 i7=1 guard=0`
`rc=1`
