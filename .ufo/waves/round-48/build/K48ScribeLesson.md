# K48ScribeLesson — round-48 lesson draft (scribe seat)

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, BASE
`76da518fcc3029e738648bd6fd4ba5571df01c1c`; predeclaration `164f0ea5ed8b76a671f9b076158d1d8022881813`,
Amendment A1 `52991e5da64cbacaa724b28b407cf5765fd21b41` (both `git cat-file -t` → `commit`).
Scratch `/fast/scratch/hyaku/kagi-r48/K48ScribeLesson` (`$HYAKU_SCRATCH` default), created with `mkdir -p`,
`trap 'rm -rf -- "$F"' EXIT` in every script. Read-only everywhere outside the seat's build dir.

## Behavior

Wrote the round-48 lesson as a draft for the L1 to integrate into `corpus/lessons/round-48.md`, mined the
round's mistakes from committed receipts and from two demonstrations run here, and left every frozen object
untouched. No product code, counter, control, predicate, target, kill rule, registry row, SCORECARD line,
LOG line or sibling file was edited. No git mutation, no remote write, no account or vault contact, no real
key read or copied; the only identity-shaped string in this seat is a fabricated 74-character fixture built in
scratch (prefix + 58 `Z`), deleted on exit and never printed.

Shape follows `corpus/lessons/round-47.md`: H1 title, frozen-plan paragraph, `## Claims`, `## Gate`,
`## Mistakes`, `## Errata`, `## Amendment notes`, `## Routed`, `## Frontier`, `## Assimilation`,
`## considerthese`, then a placeholder list for the L1.

## Artifacts (all under the seat's build dir unless stated)

| path | what it is | bytes |
|---|---|---|
| `.ufo/waves/round-48/build/K48ScribeLesson/round-48-draft.md` | the lesson draft (87 lines, `<<…>>` placeholders named in its own last section) | 20924 |
| `.ufo/waves/round-48/build/K48ScribeLesson/mistake-receipts.txt` | the three mistake receipts, verbatim, with exit codes | 3497 |
| `.ufo/waves/round-48/build/K48ScribeLesson/m48-1-capability-readings.sh` | C2 class: stated-reading extractor exercised on scratch copies of the section | 3307 |
| `.ufo/waves/round-48/build/K48ScribeLesson/m48-1-receipt.txt` | its output + `rc=0` (last line `rc=0`) | — |
| `.ufo/waves/round-48/build/K48ScribeLesson/m48-2-killrule.sh` | M48-2: bare literal vs key-shaped ERE, fixture built in scratch | 2513 |
| `.ufo/waves/round-48/build/K48ScribeLesson/m48-2-receipt.txt` | its output + `rc=0` | — |
| `.ufo/waves/round-48/build/K48ScribeLesson/m48-3-successor-claim.sh` | M48-3: does the r47 counter header's claim hold against the registry | 1528 |
| `.ufo/waves/round-48/build/K48ScribeLesson/m48-3-receipt.txt` | both runs (FLAG `rc=1`, CLEAN `rc=0`) | — |

## Gates

Each mistake row in the draft carries class, evidence pointer, captured-by and a fix shown able to fail:

- **M48-1 `number-drift`** — `SCORECARD.md:708/711/712` state `located=5 rows=5`, `claims=2`, `PASS (8 cases)`;
  the commands print `located=8 rows=8`, `claims=21`, `PASS (12 cases)` (`controls/c2-base.txt`, K02/K07/K10 DIFF).
  Captured-by none: `corpus/self-counts.tsv` binds `PROVINCE.md` (18 rows), `corpus/README.md` (11), `SKILL.md` (11)
  and knowledge-entry numbers, and no row of it reads `SCORECARD.md` §Capabilities.
  Fix = the frozen C2 counter; non-vacuity shown two ways — control K2-F4 (`K07` stated as `claims=22` ⇒ `1`,
  `controls/controls-prefreeze.txt`) and the extractor run here: base ⇒ `claims=2`, a current line stating
  `claims=22` ⇒ `claims=22` (DIFF), the same line with `claims=21` ⇒ MATCH.
- **M48-2 `vacuous` (kill rule matches its own instrument)** — the bare literal occurs on 2 lines of
  `plans/round-48.md`, 2 of `plans/round-48-c1.sh`, 1 of the controls fixture at the predeclaration.
  Fix = Amendment A1's ERE `AGE-SECRET-KEY-1[0-9A-Z]{58}`, shown able to fail: the fixture matches (74-char line,
  1 match), the plan/counter/fixture read 0, and the whole predeclaration tree reads 0 files.
- **M48-3 `stale-premise` (frozen instrument header)** — `plans/round-47-c2.sh:4,9` claim "no successor row";
  four of the eleven F ids have one (S022←S012, S023←S013, S025←S014, S026←S016). Captured-by none (the
  non-author closure caught it; round 47 routed the erratum, round 48 has not appended it).
  Fix = erratum text E48-1 in the draft plus the checker, shown able to fail both ways (`FLAG 4/11` on the real
  header, `CLEAN` on a scratch copy with the corrected sentence).

Gate block: five rows with `<<SCOUT: …>>` placeholders (S009/S010/S011 re-open; sops v3.13.3 and age v1.3.2
release identities as new rows) and four discernment candidates — 2 admit (sops 3.13.3 release row; age 1.3.2
release row with the unverified `.proof` named), 2 reject (a separate `checksums.txt` row; the `.proof` asset as
a verified-provenance row).

## Commands run (exact; rc and last output line)

```
$ bash .ufo/waves/round-48/build/K48ScribeLesson/m48-1-capability-readings.sh
rc=0
last line:   -> the renamed pair is invisible to K01; the old pair still supplies the reading

$ bash .ufo/waves/round-48/build/K48ScribeLesson/m48-2-killrule.sh
rc=0
last line:   KILL-RULE(key-shaped) on the plan: passes (grep rc=1)

$ bash .ufo/waves/round-48/build/K48ScribeLesson/m48-3-successor-claim.sh
rc=1
last line:   VERDICT: FLAG (the header's claim is false for 4/11 ids)

$ bash .ufo/waves/round-48/build/K48ScribeLesson/m48-3-successor-claim.sh corpus/SOURCES.md <scratch corrected header>
rc=0
last line:   VERDICT: CLEAN
```

Read-only inspections cited in the draft, all executed (no reruns of lane gates or counters):

```
$ awk -F'\t' 'NR>1 && $1 !~ /^#/ {print $2}' corpus/self-counts.tsv | sort | uniq -c | sort -rn | head
     18 PROVINCE.md / 11 corpus/README.md / 11 SKILL.md / then knowledge entries   # no SCORECARD.md row

$ grep -n 'SD' corpus/self-description-sweep.sh | head -2
2:# self-description-sweep.sh — round 34, self-description counter (SD1–SD9).      # SD10 still absent

$ grep -nE '^\|[[:space:]]*S098[[:space:]]*\|' corpus/SOURCES.md | cut -c1-40
105:| S098 | ... | rejected | 2026-11-05 | on-release | — |                        # carried, unchanged

$ ls -d merge
(none)                                                                           # no merge/kagi/ tree
```

Tool installs: none. No `pacman`, no binary replaced; `~/.local/bin/sops` and `age-keygen` were read only through
the committed `controls/tool-install.txt` receipt.

## Touched surfaces

- Wrote: `.ufo/waves/round-48/build/K48ScribeLesson/*` (8 files) plus this report `.ufo/waves/round-48/build/K48ScribeLesson.md` (1 file), and `/fast/scratch/hyaku/kagi-r48/K48ScribeLesson`
  (removed per script by `trap`; the two scratch files that remain are the corrected-header copy from the M48-3
  demonstration and the seat's scratch root — both outside the repo).
- Read only: `corpus/lessons/round-46,47*.md`, `corpus/knowledge/sops-age-key-rotation.md`,
  `plans/round-47-c2.sh`, `plans/round-48*.md`, `plans/round-48-c1.sh`, `plans/round-48-c2.sh`,
  `plans/round-47.md`, `SCORECARD.md`, `CORPUS.md` (fleet), `corpus/SOURCES.md`, `corpus/self-counts.*`,
  `corpus/self-description-sweep.sh`, `considerthese/2026-10-26.md`, `.ufo/waves/round-48/controls/*`.
- Not touched: `corpus/lessons/*` (the draft lives in the build dir), `plans/`, `SCORECARD.md`, `LOG.md`,
  `SHONEN.md`, `SKILL.md`, `PROVINCE.md`, `README.md`, `QUALITY`, `SOURCES.md`, `MANIFEST.json`, `.ufo/state`,
  `.ufo/watchdog.log`, the fleet root, any sibling repo.

## Out of scope (left as found)

- The frozen predicates, counters (`plans/round-48-c1.sh`, `plans/round-48-c2.sh`), controls
  (`plans/round-48-controls.sh`, receipt 16 MATCH), kill rules and targets — none edited or re-run.
- Candidate readings: the build wave was in flight, so `<<C1-CANDIDATE>>`, `<<C2-CANDIDATE>>` and
  `<<CENSUS-END>>` are placeholders, as are the five Gate rows' URLs, dates, digests and quotes.
- Round-47 routed items are recorded as routed, not closed: SD10 absent; E48-1 not appended to
  `plans/round-47.md`; S098 `rejected` + `on-release`; R25-02/R29-01/R29-02 open; the Vault-lease MDX
  normalizer gap; the two C1 named ceilings; K07's revision-bound count.
- Not done, by instruction: the lane's full claim-ledger verify, self-counts, and the counters themselves.

## Findings

1. The C1 kill rule was unpassable as frozen and is only passable under Amendment A1 — verified, not assumed:
   the bare literal names itself three times in the instruments, and the ERE separates them.
2. `SCORECARD.md` §Capabilities was outside every existing self-description binding; C2 is the first gate over
   it, and its stated-reading extractor makes command *spelling* load-bearing (K01's `python` vs `python3`), which
   the draft surfaces as a landing hazard rather than letting a renamed pair silently pass.
3. The round-47 C2 header's "no successor row" survived one round of routing; the checker here turns it into a
   reproducible FLAG/CLEAN pair so the erratum has a witness.
4. Nothing in this seat's artifacts contains a key-shaped string (`grep -cE 'AGE-SECRET-KEY-1[0-9A-Z]{58}'` → 0
   across the draft, the receipts and all three scripts).

SEAT-STATUS: complete
