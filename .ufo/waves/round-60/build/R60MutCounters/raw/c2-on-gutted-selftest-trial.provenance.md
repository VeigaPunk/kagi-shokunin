# Provenance — counter reading on the gutted-selftest trial (T-M3)

trial bytes: mut3/T-M3-selftest-no-assertions/openbao-approle-trial.sh
  sha256 051cb396f26083886082d0cbf83692e93d698fc29ca90f80a1938b927f82b4ff
  (built from corpus/openbao-approle-trial.sh 49ea928f28f42c7cce91459fe577a6d80023db3844229047718f483bfed0e54f;
   the only edit is the run_selftest body replaced by
   `echo "APPROLE_SELFTEST: PASS (cases=42)"; return 0`)
mutant `--selftest`: APPROLE_SELFTEST: PASS (cases=42), rc 0
clean `--selftest` (same base bytes): APPROLE_SELFTEST: PASS (cases=45), rc 0

command: HYAKU_SCRATCH=<seat-isolated> bash repo-clean/plans/round-60-c2.sh \
           --tree fix/tree-m3b
counter bytes: plans/round-60-c2.sh a6fc9825972a20e87a35cef89032365b3611bb909606bd7738e54d1a653501f2
result (rc 0, 87 s):
  C2_APPROLE_TRIAL: value=5 tests=5 pass=5 shims=5 vectors=ok/5 selftest=1 guard=1 (real=1 real2=1 ambient=1 none=1 secret=1 sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH sh5=HHHHB)
  (byte-identical to c2-on-gutted-selftest-trial.txt, whose one line is authoritative)

The clean counter accepts a trial whose self-test asserts nothing: the only selftest
conjunct is `PASS (cases=N)` with N >= 8, and the gutted body prints 42.
