# ScoutLane — round-34 read-only insertion and count inventory

Axes: calibration, operability, coverage. Observed working tree HEAD was `5a2f145ee80b6879a833c2e70d16f2671d103367` (plan commit); frozen BASE remains unchanged. No tracked files edited; no network, vault contact, installs, or subagents.

Semantic device unavailable: `read("xd://lsp")` returned “No such tool”. All findings below are literal source/data observations, not semantic-reference proof.

Commands: source excerpts used `functions.read`/`functions.grep` at absolute paths and Python `Path.read_text().splitlines()` for complete literal inventory extraction. Each excerpt below names its precise read command. Long source lines are split into consecutive verbatim fragments, each at most 20 whitespace-delimited words; concatenate fragments without adding separators. This preserves full requested rows and their whitespace.

## 1. SKILL gate registries

`wc -l /home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md` printed **813**. Two registries have the same exact eight-column order: `name | kind | entry command | verdict map | selftest | pinned values | write scope | owner`. For new current rows, insert after line 754 and before blank 755; the earlier historical registry ends at 701.

**SKILL.md:694** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md:694:raw")`.
```text
## Gate registry — round-22 changed contracts
```

**SKILL.md:696** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md:696:raw")`.
```text
| name | kind | entry command | verdict map | selftest | pinned values | write scope | owner 
```
```text
|
```

**SKILL.md:700** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md:700:raw")`.
```text
| claim ledger and cell parser | gate | `bash corpus/claim-ledger.sh docs`; other documented modes retain their scopes | 0 
```
```text
clean; 1 failed; 2 could-not-evaluate/setup/policy | `bash corpus/claim-ledger.sh --selftest` | `corpus/claim-ledger.tsv`, `corpus/stamps.tsv` | reads declared surfaces; reviewed `stamp` replaces only 
```
```text
the owned TSV; selftest isolated | kagi |
```

**SKILL.md:701** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md:701:raw")`.
```text
| source registry/citation census | gate | `bash corpus/sources-census.sh` | 0 clean; 1 failed; 2 could-not-evaluate/setup | `bash corpus/sources-census.sh --selftest` 
```
```text
| `corpus/SOURCES.md` and literal selftest expectations | read-only owned corpus; selftest isolated temporary files, no network | kagi |
```

**SKILL.md:746** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md:746:raw")`.
```text
## Gate registry — round-23/24 contracts (routed D2)
```

**SKILL.md:748** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md:748:raw")`.
```text
| name | kind | entry command | verdict map | selftest | pinned values | write scope | owner 
```
```text
|
```

**SKILL.md:753** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md:753:raw")`.
```text
| row identity reader | helper | `bash corpus/row-identity.sh <selector>` (R24-03..R24-16) | 0 prints `ROW_IDENTITY: <selector> count=N [blank=B ]sha256=<64hex>`; 2 
```
```text
setup (unknown selector, missing file, failed inner gate) | none of its own: each R24 row is pinned to an 
```
```text
exact digest and `.ufo/waves/round-24/tools/identity-swap.py` is its mutation harness | selector→membership table in the script header | reads one repo file 
```
```text
or runs a host-free python gate; prints counts/digests only | kagi |
```

**SKILL.md:754** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md:754:raw")`.
```text
| source registry/citation census (round 24) | gate | `bash corpus/sources-census.sh` (R21-02) | 0 clean; 1 failed (incl. SC_FETCH, SC_INROW); 
```
```text
2 setup | `bash corpus/sources-census.sh --selftest` (R21-03) | `corpus/SOURCES.md`, `corpus/source-fetches.tsv`, `corpus/inrow-pins.tsv`; historical in-row set S001-S016 in the script | read-only 
```
```text
owned corpus; selftest isolated temporary files, no network | kagi |
```

## 2. README coverage-map insertion

Coverage map has **3 columns** (Area, Entry, Source basis); final row is 95, followed by blank 96 and a prose paragraph at 97. Insert coverage rows immediately after 95, not into paragraph 97.

**corpus/README.md:20** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/README.md:20:raw")`.
```text
| Credential isolation of the handler | `knowledge/credential-isolation.md` | `the-janitor` `cmd_serve`, `~/.config/the-janitor/opencode.json`, `~/.config/opencode/agents/janitor.md`, `~/.config/opencode/tools/janitor_auth.ts` |
```

**corpus/README.md:92** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/README.md:92:raw")`.
```text
| Pre-freeze BASE controls (gate + entry, round 33) | `corpus/prefreeze-control.sh`, `corpus/knowledge/prefreeze-controls.md` | `run --base <rev> --controls <tsv>` extracts the 
```
```text
revision, runs each declared counting command in it and compares the last integer; `--selftest` proves ten cases; red witness on 
```
```text
`plans/round-32.controls.tsv` (`MISMATCH 2/2`) |
```

**corpus/README.md:95** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/README.md:95:raw")`.
```text
| Round-33 lesson | `lessons/round-33.md` | capability + coverage moves, the Gate, M33-1..M33-3, the migration record |
```

**corpus/README.md:97** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/README.md:97:raw")`.
```text
Held core since round 33: NIST key-management guidance status and the Part 2/Part 3 withdrawal record — `knowledge/nist-key-management-guidance-status.md` (SP 800-57 
```
```text
Part 1 Rev. 5 final vs the Rev. 6 IPD held as S049; SP 800-133 Rev. 2 final vs the 
```
```text
Rev. 3 IPD) and `knowledge/nist-key-management-parts-withdrawal.md` (the 2005 Part 2 and the 2009 Part 3 withdrawn; Part 2 Rev. 1 and 
```
```text
Part 3 Rev. 1 current; SP 800-131A Rev. 2 the transition reference), rows S073–S082, every source re-opened 2026-11-04. The round-21 
```
```text
frontier lead is discharged, so the frontier list holds release clocks only.
```

## 3. PROVINCE prefreeze bullet

Line 77 uses exactly: “`--selftest` proves ten cases.” This contradicts the executed eleven-case output below.

**PROVINCE.md:77** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/PROVINCE.md:77:raw")`.
```text
- `corpus/prefreeze-control.sh` — freeze-time BASE controls (round 33): `run --base <rev> --controls <tsv>` extracts the named revision with `git archive` 
```
```text
into scratch, runs every command listed as `id<TAB>expect<TAB>command` with that extraction as cwd (`BASE`/`LANE` exported) and compares the last non-empty 
```
```text
stdout line's final integer with the declared value; `--selftest` proves ten cases. Verdict `PREFREEZE: CLEAN|MISMATCH (controls=N mismatch=M)` exit 0/1, `SETUP 
```
```text
<reason>` exit 2 — a `NORESULT` row is SETUP, never a pass. Red witness: `plans/round-32.controls.tsv` at `32c35fe` reports `MISMATCH` on 
```
```text
both declared values the round-32 plan froze (`sd5 expect=3 measured=1`, `total expect=10 measured=8`).
```

## 4. Complete same-line case-count inventory

Extraction scans all four documents for `corpus/[\w.-]+\.(sh|py)` and a digits/English-number case phrase; includes hyphenated case claims as a conservative superset. Historical numbers are retained as history, not automatically recommended for replacement. PROVINCE:79 assigns its 22-case claim to rendered-text, not the row-identity helper; SCORECARD:111 assigns 43 to claim-ledger, not op-ref-probe. `≥8` is a floor, not an exact mismatch.

| file:line | verbatim count quote | script | executed count | printed line |
|---|---|---|---:|---|
| SKILL.md:35 | `61 cases` | `corpus/scope-gate.sh` | 61 | `SCOPE_SELFTEST: PASS (61 cases)` |
| SKILL.md:36 | `16 cases` | `corpus/surface-census.sh` | 16 | `SELFTEST: PASS (16 cases)` |
| SKILL.md:47 | `48 cases` | `corpus/self-counts.py` | 48 | `SELF_COUNTS_SELFTEST: PASS (48 cases)` |
| SKILL.md:48 | `116 cases` | `corpus/release-clock.py` | 116 | `RELEASE_CLOCK_SELFTEST: PASS (116 cases)` |
| SKILL.md:49 | `70 cases` | `corpus/sources-census.sh` | 70 | `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` |
| SKILL.md:140 | `16 cases` | `corpus/surface-census.sh` | 16 | `SELFTEST: PASS (16 cases)` |
| SKILL.md:183 | `13 cases` | `corpus/drift-pins.sh` | 13 | `DRIFT_SELFTEST: PASS (13 cases)` |
| SKILL.md:751 | `14 cases` | `corpus/closure-dispositions.py` | 14 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)` |
| SKILL.md:752 | `22 cases` | `corpus/rendered-text-v1.py` | 22 | `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)` |
| PROVINCE.md:67 | `16 cases` | `corpus/surface-census.sh` | 16 | `SELFTEST: PASS (16 cases)` |
| PROVINCE.md:70 | `36 cases` | `corpus/op-ref-probe.sh` | 36 | `OP_REF_SELFTEST: PASS (36 cases)` |
| PROVINCE.md:71 | `34 cases` | `corpus/checklist-run.sh` | 34 | `CHECKLIST_SELFTEST: PASS (34 cases)` |
| PROVINCE.md:72 | `61 cases` | `corpus/scope-gate.sh` | 61 | `SCOPE_SELFTEST: PASS (61 cases)` |
| PROVINCE.md:73 | `170 cases` | `corpus/claim-ledger.sh` | 170 | `SELFTEST: PASS (170 cases)` |
| PROVINCE.md:74 | `48 cases` | `corpus/self-counts.py` | 48 | `SELF_COUNTS_SELFTEST: PASS (48 cases)` |
| PROVINCE.md:75 | `116 cases` | `corpus/release-clock.py` | 116 | `RELEASE_CLOCK_SELFTEST: PASS (116 cases)` |
| PROVINCE.md:76 | `4 cases` | `corpus/feed-token-agree.py` | 4 | `FEED_TOKEN_AGREE_SELFTEST: PASS (4 cases)` |
| PROVINCE.md:77 | `ten cases` | `corpus/prefreeze-control.sh` | 11 | `PREFREEZE_SELFTEST: PASS (11 cases)` |
| PROVINCE.md:78 | `70 cases` | `corpus/sources-census.sh` | 70 | `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` |
| PROVINCE.md:79 | `22 cases` | `corpus/rendered-text-v1.py` | 22 | `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)` |
| corpus/README.md:33 | `34 cases` | `corpus/checklist-run.sh` | 34 | `CHECKLIST_SELFTEST: PASS (34 cases)` |
| corpus/README.md:36 | `13 cases` | `corpus/drift-pins.sh` | 13 | `DRIFT_SELFTEST: PASS (13 cases)` |
| corpus/README.md:40 | `16 cases` | `corpus/surface-census.sh` | 16 | `SELFTEST: PASS (16 cases)` |
| corpus/README.md:43 | `61 cases` | `corpus/scope-gate.sh` | 61 | `SCOPE_SELFTEST: PASS (61 cases)` |
| corpus/README.md:63 | `170 cases` | `corpus/claim-ledger.sh` | 170 | `SELFTEST: PASS (170 cases)` |
| corpus/README.md:74 | `36 cases` | `corpus/op-ref-probe.sh` | 36 | `OP_REF_SELFTEST: PASS (36 cases)` |
| corpus/README.md:92 | `ten cases` | `corpus/prefreeze-control.sh` | 11 | `PREFREEZE_SELFTEST: PASS (11 cases)` |
| SCORECARD.md:44 | `13 cases` | `corpus/drift-pins.sh` | 13 | `DRIFT_SELFTEST: PASS (13 cases)` |
| SCORECARD.md:87 | `39 cases` | `corpus/claim-ledger.sh` | 170 | `SELFTEST: PASS (170 cases)` |
| SCORECARD.md:109 | `29 cases` | `corpus/op-ref-probe.sh` | 36 | `OP_REF_SELFTEST: PASS (36 cases)` |
| SCORECARD.md:111 | `43 cases` | `corpus/claim-ledger.sh` | 170 | `SELFTEST: PASS (170 cases)` |
| SCORECARD.md:131 | `72 cases` | `corpus/claim-ledger.sh` | 170 | `SELFTEST: PASS (170 cases)` |
| SCORECARD.md:660 | `47-case` | `corpus/sources-census.sh` | 70 | `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` |
| SCORECARD.md:666 | `36 cases` | `corpus/op-ref-probe.sh` | 36 | `OP_REF_SELFTEST: PASS (36 cases)` |
| SCORECARD.md:701 | `59 cases` | `corpus/sources-census.sh` | 70 | `SOURCES_CENSUS_SELFTEST: PASS (70 cases)` |
| SCORECARD.md:703 | `14 cases` | `corpus/closure-dispositions.py` | 14 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)` |
| SCORECARD.md:705 | `4 cases` | `corpus/feed-token-agree.py` | 4 | `FEED_TOKEN_AGREE_SELFTEST: PASS (4 cases)` |
| SCORECARD.md:706 | `≥8 cases` | `corpus/prefreeze-control.sh` | 11 | `PREFREEZE_SELFTEST: PASS (11 cases)` |
| SCORECARD.md:820 | `12 cases` | `corpus/feature-claims.py` | 12 | `FEATURE_CLAIMS_SELFTEST: PASS cases=12` |
| SCORECARD.md:871 | `14 cases` | `corpus/closure-dispositions.py` | 14 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)` |
| SCORECARD.md:1318 | `seven-case` | `corpus/self-description-sweep.sh` | 7 | `SELFTEST: PASS (7 cases)` |
| SCORECARD.md:1345 | `≥8 cases` | `corpus/prefreeze-control.sh` | 11 | `PREFREEZE_SELFTEST: PASS (11 cases)` |

Additional count phrases with intervening adjectives (outside literal `<number> cases` grammar, included for hand-fix completeness):

| file:line | quote | script | executed count |
|---|---|---|---:|
| SKILL.md:245 | `170 scratch cases` | `corpus/claim-ledger.sh` | 170 |
| PROVINCE.md:80 | `14 isolated cases` | `corpus/closure-dispositions.py` | 14 |

### Once-only execution receipts

All ran with lane cwd, explicitly set `TMPDIR=/fast/scratch/hyaku/kagi-r34/ScoutLane/tmp` and `PYTHONDONTWRITEBYTECODE=1`; each had a 120-second process-group deadline. No test reruns. Commands and printed lines:

- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/checklist-run.sh --selftest` — exit 0, 1.97 s; `CHECKLIST_SELFTEST: PASS (34 cases)`.

- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh --selftest` — exit 0, 3.42 s; `SELFTEST: PASS (170 cases)`.

- `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/closure-dispositions.py --selftest` — exit 0, 0.3 s; `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)`.

- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/drift-pins.sh --selftest` — exit 0, 0.22 s; `DRIFT_SELFTEST: PASS (13 cases)`.

- `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/feature-claims.py --selftest` — exit 0, 0.35 s; `FEATURE_CLAIMS_SELFTEST: PASS cases=12`.

- `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/feed-token-agree.py --selftest` — exit 0, 0.02 s; `FEED_TOKEN_AGREE_SELFTEST: PASS (4 cases)`.

- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/op-ref-probe.sh --selftest` — exit 0, 0.95 s; `OP_REF_SELFTEST: PASS (36 cases)`.

- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/prefreeze-control.sh --selftest` — exit 0, 1.1 s; `PREFREEZE_SELFTEST: PASS (11 cases)`.

- `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/release-clock.py --selftest` — exit 0, 0.08 s; `RELEASE_CLOCK_SELFTEST: PASS (116 cases)`.

- `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/rendered-text-v1.py --selftest` — exit 0, 0.01 s; `RENDERED_TEXT_V1_SELFTEST: PASS (cases=22)`.

- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/scope-gate.sh --selftest` — exit 0, 5.29 s; `SCOPE_SELFTEST: PASS (61 cases)`.

- `python3 /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-counts.py --selftest` — exit 0, 1.12 s; `SELF_COUNTS_SELFTEST: PASS (48 cases)`.

- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-description-sweep.sh --selftest` — exit 0, 0.16 s; `SELFTEST: PASS (7 cases)`.

- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh --selftest` — exit 0, 2.37 s; `SOURCES_CENSUS_SELFTEST: PASS (70 cases)`.

- `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/surface-census.sh --selftest` — exit 0, 1.22 s; `SELFTEST: PASS (16 cases)`.

Observed hand-fix candidates: README:92 and PROVINCE:77 ten→11 now (12 after C2 lands); SCORECARD:701 59→70. SCORECARD:87/109/111/131/660 describe dated rounds and should remain historical unless the L1 deliberately changes their framing. Sweep SCORECARD:1318 seven-case is round-32 history; future current claim becomes ten only after C1 implementation.

## 5. Ledger, stamps, stamp usage, self-counts

R32-01 is **absent** from the entire 94-line ledger (literal exact first-field search, no matches); do not fabricate a row. R33 rows are at 93–94.

**corpus/claim-ledger.tsv:1** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv:1:raw")`.
```text
# claim-ledger.tsv — one row per durable claim: id <TAB> command <TAB> expect <TAB> exit <TAB> timeout <TAB> note
```

**corpus/claim-ledger.tsv:3** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv:3:raw")`.
```text
# combined stdout+stderr; the exit code must equal the fifth column. Both must
```

**corpus/claim-ledger.tsv:93** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv:93:raw")`.
```text
R33-01	bash corpus/prefreeze-control.sh --selftest	^PREFREEZE_SELFTEST: PASS \(11 cases\)$	0	120	round 33 C1 (capability): the freeze-time BASE control gate proves 
```
```text
its own verdict paths on throwaway fixture repositories — equal values CLEAN, one and two mismatches, a command printing no 
```
```text
integer (NORESULT -> SETUP), a malformed row, a missing controls file, `grep -c` exiting 1 while printing 0 (still a 
```
```text
measured 0), an empty controls file, an unresolvable revision, a timeout, and --base isolation (a second fixture commit changes the 
```
```text
counted file, so a harness that ignores --base and measures the worktree reports 4 instead of 3 — the round-33 
```
```text
MutGate M7 escape, closed). Fixtures live under TMPDIR and are removed; the gate never reads the live tree in run 
```
```text
mode except through `--base`.
```

**corpus/claim-ledger.tsv:94** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.tsv:94:raw")`.
```text
R33-02	bash corpus/sources-census.sh	^SOURCES_CENSUS: CLEAN \(rows=82 A=79 B=1 C=2 queued=1 mined=78 rejected=3 entries_sourced=12 legacy=22 captures=82 inrow=16 inrow_only=0 inrow_nonreproducing=12\)$	0	120	
```
```text
round 33 C2: the adopted NIST key-management shape — ten rows S073-S082 appended, ten captures, two entries (one own-work entry 
```
```text
is outside the sourced population, so entries_sourced is 12 while the corpus holds 34 entries). The census checks citation structure 
```
```text
and the capture handshake, never vendor truth; an own-work entry without a machine `source:` line stays outside its entry checks.
```

`corpus/stamps.tsv` has **no header row**: line 1 is data. Schema is documented by claim-ledger.sh:14 as path, sha256, lines, bytes. `wc -l` printed 109; Python nonblank/noncomment row count also 109.

**corpus/stamps.tsv:1** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/stamps.tsv:1:raw")`.
```text
corpus/adjacency.tsv	4d9bfb1145aa46290b1184f24a8b230db71fc71b72d5d688eac9dfa7811f9549	83	5660
```

**corpus/claim-ledger.sh:14** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh:14:raw")`.
```text
#   revision — `corpus/stamps.tsv`: path <TAB> sha256 <TAB> lines <TAB> bytes,
```

Stamp usage (read only; not executed): `bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh stamp PATH… [--root DIR] [--out FILE] [--prune]`. Paths are the entire reviewed membership, not just changed files; shrink/drop protection requires existing membership unless pruning is explicitly intended. The source has no separate “Usage:” block; its header and parser define usage.

**corpus/claim-ledger.sh:19** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh:19:raw")`.
```text
#              `stamp PATH…` regenerates the WHOLE row set from the paths given
```

**corpus/claim-ledger.sh:20** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh:20:raw")`.
```text
#              (it replaces the file, it does not merge), so a run that names
```

**corpus/claim-ledger.sh:21** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh:21:raw")`.
```text
#              fewer paths than the file holds is refused unless `--prune` is
```

**corpus/claim-ledger.sh:336** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh:336:raw")`.
```text
    stamp) MODE="stamp"; shift ;;
```

**corpus/claim-ledger.sh:341** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh:341:raw")`.
```text
    --root) [[ $# -ge 2 ]] || die "--root needs a dir"; ROOT="$2"; shift 2 ;;
```

**corpus/claim-ledger.sh:342** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh:342:raw")`.
```text
    --out) [[ $# -ge 2 ]] || die "--out needs a file"; OUT="$2"; shift 2 ;;
```

**corpus/claim-ledger.sh:343** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh:343:raw")`.
```text
    --prune) PRUNE=1; shift ;;
```

**corpus/self-counts.tsv:1** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-counts.tsv:1:raw")`.
```text
# self-counts.tsv — id<TAB>doc<TAB>locator<TAB>source<TAB>extract<TAB>note
```

**corpus/self-counts.tsv:15** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-counts.tsv:15:raw")`.
```text
SC-SKILL-STAMPS	SKILL.md	^\| Re-run a claim .*?\(([0-9]+) stamps \+ 	ledger:R12-03	^([0-9]+)$	decision table: current stamp membership
```

**corpus/self-counts.tsv:16** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-counts.tsv:16:raw")`.
```text
SC-SKILL-CLAIMS	SKILL.md	^\| Re-run a claim .*?\([0-9]+ stamps \+ ([0-9]+) claims\b	ledger:R21-04	^([0-9]+)$	decision table: total claim rows (routed D1: 
```
```text
said 63/39 at BASE)
```

**corpus/self-counts.tsv:18** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-counts.tsv:18:raw")`.
```text
SC-SCOPE-SELFTEST	SKILL.md	^\| Own vs read a shared surface .*?`--selftest` proves ([0-9]+) cases\b	ledger:R16-02	^SCOPE_SELFTEST: PASS \(([0-9]+) cases\)$	scope gate 
```
```text
selftest
```

**corpus/self-counts.tsv:23** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-counts.tsv:23:raw")`.
```text
SC-LEDGER-SELFTEST	SKILL.md	^\s+bash corpus/claim-ledger\.sh --selftest # ([0-9]+) scratch cases\b	ledger:R11-09	^SELFTEST: PASS \(([0-9]+) cases\)$	command example; its '94 until round 
```
```text
18, 151 until round 25' tail is history
```

Yes: self-counts already binds many `--selftest` case counts (e.g. SC-SCOPE-SELFTEST line18 to ledger:R16-02; SC-LEDGER-SELFTEST line23 to ledger:R11-09). No prefreeze/self-description binding exists in this file (literal search of all rows).

## 6. Fetch provenance: schema and executable order

Header is a commented declaration, not a TSV data header. Last data row is S082 at125; append at126.

**corpus/source-fetches.tsv:6** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:6:raw")`.
```text
# 16 tab-separated columns, no tabs inside a cell:
```

**corpus/source-fetches.tsv:7** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:7:raw")`.
```text
#   id                 registry row id
```

**corpus/source-fetches.tsv:8** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:8:raw")`.
```text
#   status             registry status at capture time (must match the row)
```

**corpus/source-fetches.tsv:9** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:9:raw")`.
```text
#   row_identity_sha256 sha256 of `id<TAB>status<TAB>url<LF>`; re-pointing a
```

**corpus/source-fetches.tsv:10** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:10:raw")`.
```text
#                      provenance row to another id/status/URL changes it
```

**corpus/source-fetches.tsv:11** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:11:raw")`.
```text
#   url                exact registered URL string from the row's source cell
```

**corpus/source-fetches.tsv:12** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:12:raw")`.
```text
#   final_url          %{url_effective} after redirects
```

**corpus/source-fetches.tsv:13** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:13:raw")`.
```text
#   http_status        final HTTP status code
```

**corpus/source-fetches.tsv:14** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:14:raw")`.
```text
#   request_profile    curl-fsSL-compressed-v1: curl -fsSL --compressed
```

**corpus/source-fetches.tsv:15** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:15:raw")`.
```text
#                      -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>
```

**corpus/source-fetches.tsv:16** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:16:raw")`.
```text
#   fetched            ISO date the bytes were fetched (2026-10-21)
```

**corpus/source-fetches.tsv:24** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:24:raw")`.
```text
#   sha256             sha256 of the representation bytes
```

**corpus/source-fetches.tsv:25** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:25:raw")`.
```text
#   bytes              byte count of the representation
```

**corpus/source-fetches.tsv:26** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:26:raw")`.
```text
#   revision           40-hex immutable revision for a moving-ref URL, else -
```

**corpus/source-fetches.tsv:27** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:27:raw")`.
```text
#   quote              declared quote, shape-checked only by the census: <=25 ASCII words.
```

**corpus/source-fetches.tsv:31** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:31:raw")`.
```text
#   normalization      rendered-text-v1: declared ONCE in corpus/rendered-text-v1.py
```

**corpus/source-fetches.tsv:32** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:32:raw")`.
```text
#                      (round 24, routed D6; it reproduces all ten round-23 normalized
```

**corpus/source-fetches.tsv:33** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:33:raw")`.
```text
#                      digests); raw-literal-v1: the decoded body bytes, no transform
```

**corpus/source-fetches.tsv:34** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:34:raw")`.
```text
#   normalized_sha256  sha256 of the normalized text (rendered-text-v1 only), else -
```

**corpus/source-fetches.tsv:125** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/source-fetches.tsv:125:raw")`.
```text
S082	mined	1a6a3219022cbd3e961ce1a519bc439b71d0d1e414d54e6991db7f4500709434	https://csrc.nist.gov/pubs/sp/800/131/a/r2/final	https://csrc.nist.gov/pubs/sp/800/131/a/r2/final	200	curl-fsSL-compressed-v1	2026-11-04	decoded-http-body-volatile-v1	2d62fd992cbca3b62f157285f33587b0c2f6868059380a1de9d15a95df607322	45595	-	An initial public draft of Revision 3 has 
```
```text
been posted for public comment through December 4, 2024.	rendered-text-v1	ff257649b6da6458d998f25b35d62cfbd1c1bf102b5367124f0d3e5b2b35ea39	csrc publication page, Documentation block: "Planning Note (10/21/2024)" (same 
```
```text
block: "Date Published: March 2019 Supersedes: SP 800-131A Rev. 1 (11/06/2015)"; Document History "03/21/19: SP 800-131A Rev. 2 (Final)"; "Publication: 
```
```text
https://doi.org/10.6028/NIST.SP.800-131Ar2")
```

**Authoritative read order** (16 variables): fid, fstatus, frow, furl, ffinal, fhttp, fprof, ffet, frep, fsha, fbytes, frev, fquote, fnorm, fnsha, floc. Thus final URL/HTTP status precede request profile; do not infer physical order from narrative prose.

**corpus/sources-census.sh:253** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh:253:raw")`.
```text
    out=$(awk -F'\t' 'length($0)>0 && $0 !~ /^#/ && NF!=16 {print "line=" NR " nf=" NF}' "$fetchf")
```

**corpus/sources-census.sh:255** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh:255:raw")`.
```text
    while IFS=$'\t' read -r fid fstatus frow furl ffinal fhttp fprof ffet frep fsha fbytes frev fquote fnorm fnsha floc; 
```
```text
do
```

**corpus/sources-census.sh:262** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh:262:raw")`.
```text
      line=$(printf '%s\t%s\t%s\n' "$fid" "${ST[$fid]:-}" "${FURL[$fid]}" | sha256sum)
```

**corpus/sources-census.sh:266** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh:266:raw")`.
```text
      [[ $fprof == curl-fsSL-compressed-v1 ]] || finding SC_FETCH "id=$fid request-profile"
```

**corpus/sources-census.sh:267** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh:267:raw")`.
```text
      [[ $ffet =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || finding SC_FETCH "id=$fid fetched"
```

**corpus/sources-census.sh:287** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh:287:raw")`.
```text
    done < <(awk -F'\t' 'length($0)>0 && $0 !~ /^#/ && NF==16' "$fetchf")
```

## 7. Prefreeze entry front matter and selftest

First twelve lines are a title and prose “Source basis”, not YAML or column-1 provenance fields. Reverify is line12.

**corpus/knowledge/prefreeze-controls.md:1** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:1:raw")`.
```text
# Pre-freeze BASE controls — declared values are measured, never estimated
```

**corpus/knowledge/prefreeze-controls.md:2** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:2:raw")`.
```text

```

**corpus/knowledge/prefreeze-controls.md:3** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:3:raw")`.
```text
Source basis: written 2026-11-04 (round 33) from the shipped gate itself —
```

**corpus/knowledge/prefreeze-controls.md:4** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:4:raw")`.
```text
`corpus/prefreeze-control.sh` (stamped in `corpus/stamps.tsv`), the two frozen controls
```

**corpus/knowledge/prefreeze-controls.md:5** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:5:raw")`.
```text
files `plans/round-33.controls.tsv` and `plans/round-32.controls.tsv`, and the runs quoted
```

**corpus/knowledge/prefreeze-controls.md:6** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:6:raw")`.
```text
below. The motivating defect is round 32's: `plans/round-32.md` froze `SD5=3` and a total of
```

**corpus/knowledge/prefreeze-controls.md:7** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:7:raw")`.
```text
`10` at BASE `32c35fe`, while the counter it shipped measured `SD5=1` and `8`
```

**corpus/knowledge/prefreeze-controls.md:8** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:8:raw")`.
```text
(`corpus/lessons/round-32.md` §Mistakes M32-2; `corpus/lessons/round-32-verifier-spotcheck.md` §2).
```

**corpus/knowledge/prefreeze-controls.md:9** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:9:raw")`.
```text
Nothing here is copied from a draft: every verdict string in this entry was produced by the
```

**corpus/knowledge/prefreeze-controls.md:10** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:10:raw")`.
```text
committed script at the revision that carries it.
```

**corpus/knowledge/prefreeze-controls.md:11** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:11:raw")`.
```text

```

**corpus/knowledge/prefreeze-controls.md:12** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:12:raw")`.
```text
Reverify: R33-01
```

**corpus/knowledge/prefreeze-controls.md:31** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:31:raw")`.
```text
    corpus/prefreeze-control.sh --selftest
```

**corpus/knowledge/prefreeze-controls.md:50** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:50:raw")`.
```text
- `--selftest` builds throwaway fixture repositories under `$TMPDIR` and proves one case per
```

**corpus/knowledge/prefreeze-controls.md:51** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:51:raw")`.
```text
  verdict path plus the exit-code and empty-population cases; it prints
```

**corpus/knowledge/prefreeze-controls.md:52** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:52:raw")`.
```text
  `PREFREEZE_SELFTEST: PASS (<k> cases)` exit 0 or `... FAIL (<k> cases)` exit 1.
```

**corpus/knowledge/prefreeze-controls.md:89** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/prefreeze-controls.md:89:raw")`.
```text
    bash corpus/prefreeze-control.sh --selftest
```

## 8. Round-33 Mistakes table

Header at21; four rows at23–26. README:95 range ends atM33-3 but actual terminal row is M33-4.

**corpus/lessons/round-33.md:19** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-33.md:19:raw")`.
```text
## Mistakes
```

**corpus/lessons/round-33.md:21** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-33.md:21:raw")`.
```text
| id | class | evidence | captured-by | fix shown able to fail |
```

**corpus/lessons/round-33.md:22** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-33.md:22:raw")`.
```text
|---|---|---|---|---|
```

**corpus/lessons/round-33.md:23** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-33.md:23:raw")`.
```text
| M33-1 | unmeasured BASE expectation frozen as fact | round-32's plan declared SD5=3 and total=10; the delivered counter measured 
```
```text
1 and 8 (`corpus/lessons/round-32-verifier-spotcheck.md` §2 C1; `corpus/lessons/round-32.md` §Mistakes M32-2); replaying the same declared values at `32c35fe` reproduces the gap | 
```
```text
QM34 | `bash corpus/prefreeze-control.sh run --base 32c35fe… --controls plans/round-32.controls.tsv` exits 1 with `PREFREEZE: MISMATCH (controls=2 mismatch=2)` naming `sd5 expect=3 measured=1` 
```
```text
and `total expect=10 measured=8`; a gate with the comparison removed returns CLEAN on that file and fails its own mismatch 
```
```text
cases |
```

**corpus/lessons/round-33.md:24** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-33.md:24:raw")`.
```text
| M33-2 | plan target counts an author-inaccessible file | round-32 C1's frozen `n=0` was unreachable because SD6 counts `corpus/lessons/round-30-verifier-spotcheck.md:41`, 
```
```text
an integrator-owned line (round-32 verifier §2 C1 and §6 residual); this round names the residual at freeze (`plans/round-33.md` §Inputs) instead 
```
```text
of counting it | none | no claimed fix: the row is a disclosure. The only control is the kill 
```
```text
rule — a claim whose target counts that line is reported not admitted while it persists (round 32 did exactly 
```
```text
that at n=1); no counter this lane can run shows the naming itself failing |
```

**corpus/lessons/round-33.md:25** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-33.md:25:raw")`.
```text
| M33-3 | the round that builds the pre-freeze control froze its own plan with an unmeasured census figure | 
```
```text
`plans/round-33.md` declares BASE `captures=101` and target `captures=111`; the census at `76f4eea` measures `captures=72` and at the landing tree `captures=82` (the 
```
```text
`R21-02` expected line already said `captures=72`); C2's fourth reading therefore names a number no tree produces | QM34 | `bash 
```
```text
corpus/prefreeze-control.sh run --base 76f4eeae… --controls <a controls file whose captures row expects 101>` exits 1 with `MISMATCH captures expect=101 measured=72`, 
```
```text
and the same row with `expect=72` is CLEAN — the gate would have caught this plan before it froze; receipt 
```
```text
`.ufo/waves/round-33/final/c1-captures-red.txt` |
```

**corpus/lessons/round-33.md:26** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-33.md:26:raw")`.
```text
| M33-4 | a selftest that cannot witness the behaviour its gate exists to provide | the delivered gate's ten 
```
```text
cases all ran in a fixture whose worktree equals its HEAD, so a mutant that ignores `--base` and measures the 
```
```text
live worktree (`BASE_DIR=$REPO`, extraction removed) kept `PREFREEZE_SELFTEST: PASS (10 cases)` and reported CLEAN — MutGate's M7 escape | QM3 (every 
```
```text
skip/unverified branch counted; here: a declared isolation with no assertion) | an eleventh case commits a SECOND fixture state and 
```
```text
expects the older revision's value; the M7 mutant now prints `CLEAN (controls=1 mismatch=0)` where `MISMATCH` is required, so `--selftest` FAILs. 
```
```text
Receipt `.ufo/waves/round-33/build/mut/MutGate.md` (M7) and `final/c1-final.txt` (`PASS (11 cases)`) |
```

## Comment/code contradictions and bounds

Observed: claim-ledger.tsv:3 says expected exit is the **fifth** column; actual row schema line1 and parser claim-ledger.sh:547 put it in the **fourth**, with timeout fifth.

**corpus/claim-ledger.sh:547** — command: `read("/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/claim-ledger.sh:547:raw")`.
```text
    id=${TF[0]} cmd=${TF[1]} expect=${TF[2]} want=${TF[3]} tmo=${TF[4]} note=${TF[5]:-}
```

Observed: source-fetches.tsv:14–15 documents request-profile curl including a custom `-A`; sources-census.sh:266 only validates the profile label, not the executed curl argv. This is an attestation-validation limitation, not proof the original fetch omitted that header. No SC_FETCH field-order contradiction: executable order and enumerated header agree.

High confidence for literal line locations, schema, and all fifteen printed selftest counts. Unresolved: no semantic server is mounted; no network/content currentness was tested. No predicate/counter changed.
