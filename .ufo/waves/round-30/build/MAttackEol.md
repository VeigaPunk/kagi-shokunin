# MAttackEol — mutation test of C2's counters (scoped findings)

Full report: `.ufo/waves/round-30/MAttackEol-report.md`; receipts in
`.ufo/waves/round-30/final/attack-eol/`. Method: LF scratch mirror from `git archive HEAD`
(strip CR on the three D5 files), each mutation on a fresh copy, restored byte-identical after
each probe, same detector run on pristine / mutant / restored.

## Verdicts

| mutation | detector (as assigned) | output | verdict |
|---|---|---|---|
| **M1** CR into `corpus/SOURCES.md` only | fleet `sources-census.sh validate --root <mirror> kagi` | exit **1**, `E12 ×52` (S001–S052), census rows 0 | **KILLED** |
| **M2** CR into `SKILL.md` only | `bash corpus/checklist-run.sh --ratio` | exit **2**, `SETUP no '## Credential-hygiene checklist' section…` | **KILLED** |
| **M3** CR into `corpus/claim-ledger.tsv` only | `bash corpus/row-identity.sh ledger-ids` | identical `count=67 sha256=917ef251…` | **NOT KILLED by this probe** (CR-blind by construction: ids are field 1) |
| **M4** `.gitattributes` `*.md text eol=crlf` | `git check-attr eol -- …` | `SKILL.md: eol: crlf`, `corpus/SOURCES.md: eol: crlf`, `corpus/claim-ledger.tsv: eol: unspecified` | **ruling observable → wrong pattern is detectable, and destructive if committed** |

Baseline (pristine LF mirror): census exit 0 (14 × W04 + `ok`), `--ratio` exit 0 with
`CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`, ledger-ids `count=67
sha256=917ef251…`. Mutants M1/M2/M3 reproduce the BASE bytes byte-for-byte (`f63eb591…`,
`56b567cd…`, `5676ced7…`). Restoration verified by `cmp -s` + re-run to the pristine verdict in
every case; hashes above are both before and after.

## Additional killed / survived detail

- **Census is a heading tripwire.** CR on the `## Registry` heading alone → exit 1, E12 ×52
  (killed). CR on one data row, on all table rows with the heading left LF, on header/separator
  rows, or inside a used-by cell → exit 0, rows 52, E12 0 (survived). Mechanism:
  `scripts/sources-census.sh:581` trims only `[ \t]`.
- **Checklist is a second heading tripwire.** CR on the checklist heading alone → SETUP exit 2
  (killed); CR on item lines with the heading intact → `--ratio` exit 0 and the full checklist
  output is byte-identical to pristine (survived; the full run is red on both arms from absent
  substrate, so it cannot discriminate).
- **M3 is killed by two other detectors, one conditionally.** Counter 2 scoped form 0 → 1
  (killed). `claim-ledger.sh verify` only after C2 re-stamps: at BASE the three stamp pins equal
  the CRLF bytes (round-29 re-pinned drift at `fc65112` / `bc2f3fd`), so STALE ×0 at BASE; with
  LF pins, CR back in the ledger prints `STALE corpus/claim-ledger.tsv sha=3419c6d50ea0→5676ced76cd3`.
- **M4 blast.** Wrong draft on a fresh clone checks out **99 non-`.ufo` `*.md` files CRLF** while
  `git status` stays clean; census exit 1 / E12 ×52 and checklist SETUP. `--renormalize .` with
  the live 5-line draft stages **8** paths (3 production + 5 round-29 evidence JSONs);
  `* text=auto eol=lf` touches **135** (kills authentic CRLF captures). Attributes alone do not
  repair committed `i/crlf` blobs — a clone under correct attributes still checks out CRLF.

## Findings against C2

1. **Frozen counter 2 cannot reach 0.** Literal command reads 135 (raw BASE) / 132 (repaired
   mirror, 165 live) because committed `.ufo/waves/**` captures are CRLF evidence. Scoped form
   (`--exclude-dir=.ufo`) reads 3 → 0 and mutants 0 → 1 — the satisfiable, discriminating form
   (already adopted by plan correction 1 item 5; independently corroborated here with counts).
2. **No committed gate reads `.gitattributes`.** Correction 1 item 6's R30-02 line-count
   (`grep -cE '^\*\.(md|tsv|sh|py|json) text eol=lf$'` == 5) is defeated by an appended
   `*.md text eol=crlf` override: count stays 5 while `check-attr` says `crlf` (measured).
   Per-file assertion `git check-attr eol -- SKILL.md corpus/SOURCES.md corpus/claim-ledger.tsv |
   awk '{print $3}' | grep -cx lf` expect 3 observes the actual ruling.
3. **Re-stamp ordering is load-bearing**: without `claim-ledger.sh stamp` after the byte rewrite
   the stamp gate is red on its own repair and blind to the next drift.
4. Row-level EOL drift (census/checklist blind) is caught only by counter 2 scoped — measured
   0 → 1 for every partial mutant.
