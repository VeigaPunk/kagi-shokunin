# K41ConnOverlap — commands and exit codes

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`, HEAD `5142b52`. Scratch dir: none created (read-only scan, nothing staged). Tool installs: none. Lane writes: this directory only (`overlap.md`, `notes.md`) plus the report named in the seat spec. No git mutation; no `claim-ledger.sh verify` run.

## Bash commands (exit codes observed)

| # | Command (abridged) | Exit | Result |
|---|---|---|---|
| B1 | `cd /home/vgpnk/Projects/shokunin && ls -d *-shokunin` | 0 | 21 entries including kagi (20 sibling lanes) |
| B2 | `git -C …/kagi-shokunin rev-parse --short HEAD`; `git log --oneline -3` | 0 | `5142b52` |
| B3 | `for d in *-shokunin; do … test -d "$d/corpus" … test -f "$d/corpus/SOURCES.md" … test -f "$d/SKILL.md" … ls "$d" \| grep -ci province; done` | 0 | corpus and SOURCES.md present in all 21; SKILL.md present in 19 (audio and game-dev-2d lack it, kagi has it); one PROVINCE file per lane |
| B4 | `ls -1 *-shokunin/ \| grep -i province`, then per-lane listing | 0 | 21 × `PROVINCE.md` |
| B5 | `mkdir -p …/build/K41ConnOverlap && test -d …` | 0 | — |
| B6 | `git -C …/kagi-shokunin rev-parse --short HEAD` (before writing) | 0 | `5142b52` |

## Search calls (grep tool; the tool reports no exit code, so the output footer is recorded)

Path scope: the 20 sibling `corpus/` trees, the 18 existing sibling `SKILL.md` files, and the 20 sibling `PROVINCE.md` files. kagi excluded. `gitignore=false`. `.ufo/` not in scope unless a sweep hit it.

| # | Pattern (abridged) | Footer / coverage | Used for |
|---|---|---|---|
| S1 | `expectation-migration\|expect-journal\|expect_journal\|old_expect\|new_expect` over whole fleet, incl. `.ufo` | not recorded; multi-page noise | first sweep; surfaced tameshi `.ufo` `old_expect` and kasegi/tsukuroi `.ufo` receipt fields |
| S2 | `expectation-migration…\|expect-journal…\|old_expect\|new_expect\|migration journal\|expect-gate\|literal-anchored\|literal anchor` (corpus, SKILL, PROVINCE) | no footer; one page, complete | (a); mado and mori "literal anchor" near-misses only |
| S3 | `claim-ledger\|claim_ledger\|expect-gate\|expectation gate…\|literal-anchored\|loosen` (corpus, SKILL, PROVINCE) | page read; no paging footer seen in the output | ledger ownership; surfaced kengaku round-11 connector line on kagi `claim-ledger.sh`; kake QUALITY:899; kasegi README:53-55 |
| S4 | `rendered-text\|isspace\|White_Space\|UTS #18\|tr18\|Unicode whitespace\|…\\s` (corpus, SKILL, PROVINCE) | `Showing files 1-20 of 78`; page 1 read, pages 2+ not read | (b) first pass; code-dominated |
| S5 | `str\.isspace\|rendered-text\|White_Space\|UTS #18\|tr18\|Unicode whitespace\|…backslash-s\|special sequence` | `Showing files 1-20 of 78`; page 1 read | (b) refined; surfaced kengaku S046 chain and kama `round86-rendered-cells` |
| S6 | `docs\.python\.org/3/library/stdtypes\.html\|…re\.html\|unicode\.org/reports/tr18` (corpus, SKILL, PROVINCE) | `Showing files 1-20 of 26`; page 2 (skip=20) read | (c) — complete (26 files, 2 pages) |
| S7 | PROVINCE scan `journal\|expect\|whitespace\|normaliz\|isspace\|UTS\|tr18\|rendered\|…\\s` over `*-shokunin/PROVINCE.md` | output truncated at 49.9 KB, `Showing lines 1-433 of 438`; continuation `:434` not read | PROVINCE ownership — partial; owner lines read directly (kama 406-410; kake 32-73; kengaku 51-105, 683-684; mado 20-35; mori 8-57; tabi; tsukuroi 120-127) |
| S8 | `rendered-text-v1\|rendered-text normal\|normaliz… rendered…` with `isspace` | `Showing files 1-20 of 89`; page 1 read, code noise only | confirmed page-1 hits are code (`ln[0].isspace()`, C `isspace`) |
| S9 | `UTS #18\|UTS#18\|tr18\|White_Space\|str\.isspace\|rendered-text-v1\|Python \`re\` whitespace\|re \`\\s\`\|\\s matches` (corpus, SKILL, PROVINCE) | no footer; one page, complete | precise token pass; surfaced **kumitate** QUALITY:1447-1450, README:265-266, SOURCES:215-216, knowledge/receipt-invisible-prefix-fields.md, lessons/round-90-verifier-spotcheck.md:70-71 |
| S10 | documentation-only broad pass (`!**/*.py;!**/*.c;!**/*.sh;!**/*.json;!**/*.diff;!**/*.tsv;!**/*.js;!**/*.mjs;!**/*.gd;!**/*.html;!**/*.txt`) | `Showing files 1-20 of 120`; page 1 read | documentation-only pass; pages 2+ not read; named tokens taken from S9 |

## Peer message

ReviewerV4 sent an informational IRC note during the scan (round-94 pin verification in its own lane). It asks for no reply from this seat. Not answered; not acted on.

## Limits

- S4, S7 (PROVINCE page 2+), S8, S10 pages 2+ were not read to the end. Named-token coverage rests on S9 (one page, no footer) and on the PROVINCE owner lines read directly.
- No sibling `.ufo/` tree was assessed for declarations; only receipt-level hits are noted.
- Kagi's own rows S095, S097, S098 and `rendered-text-v1.py` were not read.
