# kagi-shokunin — Promotion checklist

Promotion to shokunin requires all of:

- [x] SKILL.md contains real decision tables, error patterns, checklists, cited sources
  (rounds 2–5: decision table, failure table w/ exits, env contract,
  rotation/revocation matrix, hygiene checklist, falsification list)
- [x] At least one end-to-end domain task executed and logged in LOG.md
  (round 3: `the-janitor request` ran the full stdin→lock→tmux→serve pipeline;
  failed at the 1Password auth gate with the documented boundary text, exit 1 —
  executed and logged; a successful model reply still needs operator signin)
- [x] Instructions executable by an agent without oral context
  (SKILL.md is self-contained: verbs, exact failure texts, corpus pointers;
  round-3/4/5 additions trace to named corpus entries with line refs)
- [x] No cross-domain bleed (PROVINCE.md still accurate)
  (round-5 re-verified: CDP 9222 + musketeer profile still reported to
  integrator, not absorbed; vault structure still deliberately unmapped)
