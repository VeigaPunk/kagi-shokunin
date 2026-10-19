# kagi-shokunin — Promotion checklist

Promotion to shokunin requires all of:

- [~] SKILL.md contains real decision tables, error patterns, checklists, cited sources
  Evidence: SKILL.md §Vault-ops decision table, §Failure table, §Credential-hygiene checklist; citation run `CITATION_GATE: CLEAN (cites=891 docs=53 unresolved=0 ephemeral=0 labeled=13)` at LOG.md:758.
- [~] At least one end-to-end domain task executed and logged in LOG.md
  Evidence: LOG.md:20 — round-3 entry: stdin→lock→tmux→serve pipeline to the 1Password auth gate, exit 1, `handler exited before becoming ready`; a completed reply still needs the operator's `op signin`.
- [~] Instructions executable by an agent without oral context
  Evidence: corpus/lessons/round-19-recensus.md §Independent audit erratum (line 45) — all seven safe gates re-ran green (97/13/16/61/29/34-case selftests) with identity, pathspec and record conformance; runnable gates: corpus/claim-ledger.sh, corpus/scope-gate.sh, corpus/op-ref-probe.sh.
- [~] No cross-domain bleed (PROVINCE.md still accurate)
  Evidence: PROVINCE.md §Surfaces plus corpus/scope-gate.sh ownership rules R1–R11 (`SCOPE_FALSIFY: PASS (caught=18/18 failed=0)` at LOG.md:686); contested surfaces (CDP lease, musketeer profile) reported to the integrator, not absorbed.
