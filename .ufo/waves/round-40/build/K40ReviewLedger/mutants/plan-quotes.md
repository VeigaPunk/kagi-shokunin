Attack 4 judgment material (verbatim quotes extracted 2026-11-05 from the frozen plan):

plans/round-40.md C1 "Frozen predicate" sentence:
  "the count is over exactly the six named ids; no other row's state enters the number; …"

plans/round-40.md C1 "Fail-closed" sentence (Declard claim paragraph):
  "Fail-closed: exit 2 (no integer) when verify produces no `CLAIM_LEDGER:` summary,
   verify dies, or any of the six ids is absent from `corpus/claim-ledger.tsv`."

plans/round-40-c1.sh header (same two clauses):
  "Fail closed (exit 2, no integer): verify produces no `CLAIM_LEDGER:` summary line, verify
   dies before its summary, or any of the six ids is not a row of corpus/claim-ledger.tsv."
  "Non-set rows (R11-08, R22-03, R24-15, R25-02, R36-03 and the historical MISSING-ID classes)
   are outside this population by design and never counted here."
