# R58ExecCounterC1 — C1 instrument receipts (round 58, kagi lane)

Seat: R58ExecCounterC1 (C1 counter instruments). Instruments:
- plans/round-58-c1-check.py  sha256 d37829c017aabe789336c853bb09604d0c30978c84914a20a2d4de185040c77f
- plans/round-58-c1.sh        sha256 48eab526ff9bb8c10a7ed9462addafe9f035223f835c7540c0b044e958df0d15
(taken after the final full re-measurement pass, 12:26:35 -03; see 60-sha256.txt for the
12:24:11 byte-change provenance note.)

Measured-tree provenance:
- BASE leg: git -C <lane> archive 1b13f5dad921f8901f56d30c428f89614dd74d8a (read-only), extracted to
  ${HYAKU_SCRATCH}/kagi-r58/R58ExecCounterC1/base-direct (9740 files). Scratch is deleted before yield;
  these receipts are the durable record.
- Current-tree leg: tar copy of the lane working tree (VCS internals excluded, uncommitted bytes included).
- Positive-fixture leg: synthetic all-hold root built by the checker's own mkroot() in scratch.

Predicate/conformance: plans/round-58.md §C1 with amendments A1 (five INSTRUMENT pins + match>=13
mismatch=0), A2 (whitespace-collapsed quote <=25 words), A3 (I4 two count classes: Registry arrow pinned
at landing 117; tip-count/end-rows equal the measured live count; gates.txt attributions equal the
file's carried rows= with the predates-S117 predication, checked per bullet; each location needs >=1
count statement), plus the L1 conformance rulings: printed value is the unresolved count ONLY when
GUARD=1, else FAIL (A4: the "BASE 8" is the diagnostic leg's count; the citable BASE line is
value=FAIL guard=0 with its companion); --no-challenge is a diagnostic leg printing the numeric count
with guard=0; I8 runs scope-gate.sh with --lane-root /home/vgpnk/Projects/shokunin; I6's round-56
literal scan excludes the module docstring, --selftest fixture bodies and .replace/.write/.remove
fixture-plumbing arguments (L1 review pass, verified in the landed bytes); challenge scratch is
TMPDIR-confined with an in-tree refusal (M58-3 closure). Printed convention: iN=1 iff item N
holds, iN=0 iff evaluated and not holding, x iff input absent (population<8).
