# K41ScribeLesson — round-41 lesson and scorecard drafts (scribe seat)

Deliverables (all under `.ufo/waves/round-41/build/K41ScribeLesson/`):
`lesson-round-41.md`, `scorecard-round-41-pre.md`, `scorecard-erratum-round-40.md`,
`log-entry-round-41.md`, `notes.md` (13 numbered slots the L1 fills, with the exact command for each).

Behavior: no lane tree file was edited; no `git add/commit/stash/checkout/switch/reset/pull/push` and no
mutating `jj`; scratch `/fast/scratch/hyaku/kagi-r41/K41ScribeLesson` was created, used for live
re-opens, and removed before this yield. Tool installs: **none**. `claim-ledger.sh verify` was **not**
run by this seat.

Gates and counts measured (read-only, all rc 0 unless stated):
- C1 BASE **0** — no gate file at `5142b52` (`git ls-tree` empty); receipts
  `.ufo/waves/round-41/controls/c1-control-{no-gate,refuse-all,accept-all}.txt` → 0/0/0. Target 4.
- C2 BASE **1** — `.ufo/waves/round-41/controls/c2-base-19025d9.txt` → 1; decoy control → 2 (N ≤ 2). Target 3.
- Registry rows at BASE and at `5142b52`: 96; S097/S098 do not yet exist.
- Id-collision guard (`comm -12`): registry ids vs {S097,S098} → empty; {S097,S098} vs the eight
  round-37 quarantined ids → empty; lane ids vs those eight names → S053 S071 S081 S090 S091 S093 (the
  known pre-existing spelling collision; the register file itself is absent on this host).
- S095 re-open: byte-identical to the committed round-40 capture (sha256 `ef2d8abe…469b1`, 257722 bytes),
  quote at raw offset 75897, `locate` count=1. S097 body sha256 `e2992e17…62e2b3` (815447 bytes), isspace
  sentence `locate` count=1, raw offsets 295179/296702/296299. S098 body sha256 `68e34b8b…8c70d`;
  `\p{White_Space}` absent (locate count=0, rc 1). `str.isspace()` (29) vs UTS #18 `White_Space` (25):
  difference exactly {U+001C, U+001D, U+001E, U+001F}.
- Watchdog launch line (fleet `.ufo/watchdog.log`, the lane has none):
  `2026-11-05T12:05:41-03:00 launch kagi round=41 pgid=3037435 driver=hyaku-inline attempt=1`;
  no completion line yet.

Touched surfaces: only this seat's deliverable directory and its report file. Out of scope and not
attempted: every lane corpus file, `SCORECARD.md`, `LOG.md`, `plans/`, `corpus/`, MANIFEST/state/watchdog
files, and any git/jj mutation.

Defects routed (not fixed here): plan §C1's existing-gate-control sentence overstates F4 acceptance
(reviewer finding 2); the C1 gate's row-deletion blind spot (attack A6); five gates still default their
selftest scratch to `${TMPDIR:-/tmp}`; the round-40 report was amended in place and needs an appended
erratum; `SCORECARD.md:1516` carries the round-40 "not amended after data" sentence that M40-3 contradicts
(erratum drafted, not applied); the controls runner's `c2-base-19025d9.txt` measures the working tree
rather than the pinned BASE (critic defect 1); the C1 landing-check base ledger is ambiguous (critic
ambiguity 2, resolved to `6cc8850`); the C2 kill rule's 22-case floor needs an explicit count at the
landing (critic gap 3).

Report: `.ufo/waves/round-41/build/K41ScribeLesson.md`
