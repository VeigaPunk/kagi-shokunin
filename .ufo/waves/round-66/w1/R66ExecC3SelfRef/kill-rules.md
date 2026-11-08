## plan kill rules
K1 BASE: plans/round-66-c3.sh on the pre-repair lane tree reads
  `C3_SELFREF: resolved=0 checks=1 failures=1 guard=0` (exit 1) with
  the named failure `designated S148 cites-no-carrier-path pin=3b8d4e159a0b`.
  A do-nothing tree cannot read failures=0; see base-counter.txt.
K2 arXiv at carrier path: guard leg (b) `k2-arxiv failures=2
  named=digest-mismatch` (BASE) and `failures=4 named=digest-mismatch`
  (candidate fixture). The counter fails on a real byte mismatch, not
  only on a missing path.
K3 population: `c3-selfref: rows=155` (BASE) / `rows=156` (candidate
  with the appended superseding row); shrinkage below 155 is SETUP
  (exit 2), never a pass. The counter asserts rows from the plan's
  own awk, re-derived at each run.
K4 census: lane census verdict printed every run
  (`SOURCES_CENSUS: FAILED (findings=4 rows=155)` at BASE,
  `SOURCES_CENSUS: CLEAN (rows=156 …)` after the fixture repairs);
  guard leg (d) stays 0 until the L1 repairs the four round-65
  findings (R66Reviewer F3).
Selftest: `C3_SELFREF_SELFTEST: PASS (cases=19)` (exit 0). Parsers,
  punctuation scratch-off, pin extraction and verify() refusal on
  missing/wrong-byte files all pass; the synth repair row parses.
Fixture note: `candidate-counter.txt` is the plan-faithful C1 repair
  on an isolated copy (S148 verbatim + appended superseding row citing
  round-64/capture/S143.body, fetch col16 + census repairs) and is
  NOT a lane write. It proves `resolved=1 checks=3 failures=0
  guard=1` is reachable, with the four round-65 census findings
  repaired on the fixture only — lane still reads failures=1.
