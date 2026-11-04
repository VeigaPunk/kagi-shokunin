# corpus/README.md — round-33 NIST frontier removal and Core sentence (draft; the L1 installs)

## Delete (byte-exact; current lines 115–117, including the now-empty section intro)

```
Areas being explored, not held as lane knowledge:

- **NIST key-management draft status** — distinguish final guidance from IPDs before adopting controls; see `SOURCES.md` §Leads (unopened), SP 800-57 Rev. 5/Rev. 6 and SP 800-133 Rev. 3.
```

Keep `## Frontier` (line 111), its blank line (112) and the `- **Observable release clocks** …` bullet (113), which is the only residual frontier entry. Delete the blank line at 114 together with 115–117 so the section ends at the release-clocks bullet and the `## Known gaps` heading follows after one blank line.

## Insert (byte-exact; coverage map, as one standalone paragraph)

Placement: after the last coverage-map table row (current line 91, `| Round-21 lesson | \`lessons/round-21.md\` | … |`) and its blank line, and before the paragraph beginning `The **overlap table is machine-checked** since round 16:` (current line 93). It is a sentence, not a table row, because it names the move rather than a single artifact.

```
Held core since round 33: NIST key-management guidance status and the Part 2/Part 3 withdrawal record — `knowledge/nist-key-management-guidance-status.md` (SP 800-57 Part 1 Rev. 5 final vs the Rev. 6 IPD held as S049; SP 800-133 Rev. 2 final vs the Rev. 3 IPD) and `knowledge/nist-key-management-parts-withdrawal.md` (the 2005 Part 2 and the 2009 Part 3 withdrawn; Part 2 Rev. 1 and Part 3 Rev. 1 current; SP 800-131A Rev. 2 the transition reference), rows S073–S082, every source re-opened 2026-11-04. The round-21 frontier lead is discharged, so the frontier list holds release clocks only.
```

## Landing checks for the L1

1. C2's frozen Frontier reading is `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md | grep -c 'NIST'` → must print `0`.
2. The sentence must stay outside the `## Frontier` section: SD2 scans only lines between `## Frontier` and the next `## ` heading for `moved to core`, and the sentence deliberately does not use that phrase.
3. `corpus/self-description-sweep.sh` must keep `SD1=0 SD2=0`; the expected total remains `n=2`, both lines SD6 and integrator-owned.
4. Round-22+ README sections below `## Known gaps` (the active correction/contract records) are untouched by this move.
