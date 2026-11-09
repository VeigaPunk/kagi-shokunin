# considerthese — the one proposal that fits round 71

Source: `considerthese/2026-10-26.md`, proposal 3, lines 60–62:

> 3. **Mark known-defective instrument output.** Until D1 is fixed, have
> `release-clock.py` (or its wrapper) append a `KNOWN_DEFECT: D1` qualifier to a
> CLEAN verdict, so nobody quotes a CLEAN result without the caveat.

Why this one: proposals 1, 2 and 4 do not touch an instrument's verdict. Proposal 1 is operator
policy under a HOLD. Proposal 2 already landed in round 31 (`lane-status:` in `SCORECARD.md`,
per `corpus/lessons/round-32-verifier-spotcheck.md`). Proposal 4 (`considerthese/BACKLOG.md`) was
rejected in round 32 as operator input. Proposal 3 is the only one about how a verdict is quoted,
which is the round-71 gap (M71-3: the counter's named ceiling is not beside its value).

Status, measured at the lane tree this seat read:

- Mechanism: not implemented. `git grep -c KNOWN_DEFECT -- corpus/release-clock.py` → 0.
- Rule: already a criterion. QM55 (`corpus/QUALITY.md:238`) cites this proposal and states the
  quoting rule for an instrument with an open named defect.
- Premise: stale. The proposal says `STABLE_TITLE_RE` matches `Python 3.15.1` but not
  `Python 3.15.1.`. At HEAD the regex is `corpus/release-clock.py:789`:
  `^(?:[A-Za-z]+ )?v?([0-9]+\.[0-9]+\.[0-9]+)(?![A-Za-z0-9+-]|\.[0-9])`. Measured with Python
  (`re.match` on the string): `Python 3.15.1.` matches; `Python 3.15.1-rc1` does not. Round 48 already
  recorded that round 47 found this D1 premise no longer reproducing
  (`corpus/lessons/round-48.md:80`, `build/K47ScribeLesson/regex-test.txt`). The regex alone is what
  was measured here; whether the whole clock then prints CLEAN was not run (not exercised).

Can it land as a QUALITY.md criterion this round?

- The proposal as written: no. Its mechanism needs a release-clock predicate that no frozen round-71
  plan names, and its premise is retired. Landing a `KNOWN_DEFECT` qualifier would add code for a
  defect the lane no longer has. Recommend the operator retire it in `considerthese` (not edited here).
- The transferable part: yes, as a text-only row, because it governs quoting and needs no counter
  edit. Proposed QM102 (derived from M71-3; the counter is frozen and must not change this round):
  a quoted value of a frozen counter carries its named ceiling beside it in the quoting artifact.
  Its check, a grep over the quoting file, is in `mistakes-draft.md` M71-3 and is not yet run on a
  report. A QUALITY row landed this round would be the operator's or the integrator's call; this
  seat does not edit `QUALITY.md`.
