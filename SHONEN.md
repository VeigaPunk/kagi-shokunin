# kagi-shokunin — Promotion checklist

Promotion to shokunin requires all of:

- [x] SKILL.md contains real decision tables, error patterns, checklists, cited sources
  Evidence: round-9 reviewer `KagiR9Reviewer` re-ran the citations — 168 claims adjudicated, 149 VERIFIED (decision/failure tables, env contract, rotation matrix, checklist, falsification list); the 6 WRONG / 3 PARTIAL / 5 STALE it found were fixed this round.
- [x] At least one end-to-end domain task executed and logged in LOG.md
  Evidence: LOG.md round-3 entry — full stdin→lock→tmux→serve pipeline to the 1Password auth gate (`handler exited before becoming ready`, ~60 s, exit 1) with the `whoami` root cause; a successful model reply still needs an operator `op signin` plus the endpoint fix.
- [x] Instructions executable by an agent without oral context
  Evidence: round-9 reviewer reproduced ~15 documented probes verbatim (status, cdp-bridge status, tac-check, `drift-pins.sh` + `--selftest`, `transcript-scan.sh` incl. `--classify`, endpoint curls, debug-config recipes); every probe behaved as the corpus predicts.
- [x] No cross-domain bleed (PROVINCE.md still accurate)
  Evidence: round-9 connector/reviewer — no kake/webzites material absorbed; CDP 9222 + musketeer profile reported to the integrator; the two overlapping surfaces (`~/.agents/AGENTS.md` ↔ kotoba, the musketeer manifest ↔ kake) are documented as contested, not ruled.