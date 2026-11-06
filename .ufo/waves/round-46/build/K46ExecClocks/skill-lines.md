# Drafted doc edits for the round-46 receipt repoint (K46ExecClocks)

Status: DRAFTED, not applied. `SKILL.md` and `PROVINCE.md` are outside this seat's write
scope; the lane owner applies these with the diff in `release-clock.diff`.

The lane's grep (`grep -n 'round-36' SKILL.md corpus/README.md`) finds exactly two lines;
`corpus/README.md` has no `round-36` occurrence (its default-receipt lines 193 and 212 are
round-25/round-26 history, still true). One further current-tense line lives in
`PROVINCE.md`, outside the assigned doc pair, and is listed because it states the same fact.

## SKILL.md:48 — decision table, "Judge whether a source's `on-release` recheck fired"

Before (fragment):

    `python3 corpus/release-clock.py` replays the **pinned round-36 rearmed receipt** (the round-26 receipt is retained as history), not live vendor truth;

After (drafted):

    `python3 corpus/release-clock.py` replays the **pinned round-46 observe-r46 receipt** (the round-36 and round-26 receipts are retained as history and stay citable with `--receipt/--receipt-sha`), not live vendor truth;

Rest of the row unchanged (including "`--selftest` 116 cases").

## SKILL.md:787 — evidence table, "source release clocks"

Before (fragment):

    default is the byte-pinned **round-36 rearmed receipt** (round-26 retained as history), not live release state. `--receipt FILE --receipt-sha SHA256` selects a receipt against the selected root's table;

After (drafted):

    default is the byte-pinned **round-46 observe-r46 receipt** (round-36 and round-26 retained as history), `.ufo/waves/round-46/final/observe-r46.json`, not live release state. `--receipt FILE --receipt-sha SHA256` selects a receipt against the selected root's table;

Rest of the line unchanged.

## PROVINCE.md:75 — outside the assigned pair, same fact (flag only)

Before (fragment):

    default is the pinned round-36 rearmed receipt (round-26 retained as history)

After (drafted):

    default is the pinned round-46 observe-r46 receipt (round-36 and round-26 retained as history)

## Lines deliberately not drafted

- `SKILL.md:790-795` ("The default … replays the **pinned round-26 rearmed receipt** …")
  is a round-26 historical paragraph whose own subject is the round-26 migration; it was
  already stale before this round (BASE default was round-36) and is not made stale by the
  repoint. Left for the lane owner to date-label or retire.
- `corpus/README.md:193` and `:212` name round-25/round-26 receipts as historical evidence;
  neither claims to be the current default.
- `corpus/release-clock.py` line 1160 ("accepted CLEAN at round-26") is a selftest history
  comment, not a default binding.
