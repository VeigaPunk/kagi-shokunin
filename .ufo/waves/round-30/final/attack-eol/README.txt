# MAttackEol C2 counter mutation matrix — receipts index

Executed 2026-11-03 against kagi-shokunin git archive HEAD (b7482b4 at probe start; lane later
advanced to d163290 = plan correction 1, which touches only plans/round-30.md).
Scratch root: /fast/scratch/hyaku/kagi-r30/MAttackEol (deleted after receipts were copied).

Full findings: .ufo/waves/round-30/MAttackEol-report.md

Core brackets:
  matrix.out                        pristine/mutant/restored bracket for M1-M4
  baseline.txt, baseline-exact.out  pristine LF mirror census (exit 0, 14 W04 + ok)
  base-f67232c-census.out           raw BASE archive census: exit 1, E12 x52
  M1-exact.out / M1-census.out      M1 mutant: exit 1, E12 x52 (S001-S052)
  M1-sensitivity.txt                heading tripwire matrix (M1b killed; M1c-g survived)
  M1b-heading-only-census.out       CR on `## Registry` heading alone: killed
  M1c/M1d/M1e/M1f/M1g-*.out         row-level CR mutants: census exit 0 (survived)
  M2-checklist-mutant.out           M2: SETUP exit 2
  M2-sensitivity.txt                M2b killed; M2c survived (ratio and full run identical)
  M3-rowid-mutant.out               M3: ledger-ids unchanged (survived)
  M3-verdicts.txt                   M3 detector bracket incl. post-repair stamp kill
  M3-postrepair-CRLF-stamp-verify.out   STALE on the ledger once pins are LF
  M3-postrepair-restored-stamp-verify.out  0 STALE after restore
  M4-verdict.txt                    wrong pattern rulings + invisible-drift checkout
  M4-exact-pattern.txt              `*.md text eol=crlf` only: 99/99 md CRLF in clone
  M4-check-attr.txt / M4-blast.txt  check-attr outputs, 99-file blast list
  M4-e2e-bracket.txt                wrong vs correct draft end-to-end counters
  M4-live-draft-renormalize-touched.txt   8 paths the live 5-line draft renormalizes
  R30-02-counterexamples.txt        R30-02 line-count blind to a later override
  counter2-table.txt                frozen vs scoped counter 2 on every tree
  partial-mutants.txt               row-level mutants vs counter 2 scoped (all 0->1)
  restoration.txt                   before/after hashes (restored byte-identical)
  D5-mechanism.txt                  attrs/autocrlf/renormalize mechanism bracket
  live-state-1545.txt               observed live lane state at 15:45 (not authored by seat)
