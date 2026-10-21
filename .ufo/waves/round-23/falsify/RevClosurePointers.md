# RevClosurePointers — falsification of round-23 closure dispositions

Seat: falsification, closure-pointer sub-seat. Lane:
`/home/vgpnk/Projects/shokunin/kagi-shokunin` (uncommitted round-23 tree on base
`d218603b74099ddca0bd8f869516fc41db0979bf`). Production edits: none. This file is the
only write. No git/jj mutation, no installs, no pacman, no host/package/compositor/
service/boot commands, no vault/account/handler commands, no credential or live-config
reads, no network.

Attack target: every disposition in `corpus/closure-dispositions.json` (15 rows), each
row's `pointer`, its target path:line, and whether the obligation id token is present at
the target; plus the pointer resolver in `corpus/closure-dispositions.py` and the
D1/D6/D7/D9 artifacts the pointers name.

Method note: no LSP device is mounted. `read xd://lsp` returns `No such tool: xd://lsp`
and the mounted-device list contains no language server. All resolution below is literal
file reading plus a mirror of the gate's own regex
(`(^|[^A-Za-z0-9_])<id>([^0-9]|$)`); no `lsp` status, `references`, `definition`, or
`diagnostics` call was possible, so absence is "no literal occurrence", never a
semantic-server claim.

## The tree moved during the review

The parent integrated fixes while this seat measured. Six snapshots were taken; the
report pins bytes because the dispositions file, the lesson, the census, the provenance
TSV, and the verdict file all changed under the seat.

| snapshot | time (-03:00) | `sources-census.sh` | `closure-dispositions.json` | `round-23.md` | state |
|---|---|---|---|---|---|
| A | 01:02:01 | `80966e20…` | `f20f00d1…` | `d5520988…` | census crashes; verdict absent; D9 pointer = `claim-ledger.tsv` |
| B | 01:03:18 | `24d834cc…` | `5de116d1…` | `bce51c92…` | census fixed; verdict still absent |
| C | 01:05:34 | `24d834cc…` | `00fbf48d…` | `2f53cf69…` | census CLEAN; verdict present with `measured_commit: "pending"`; D9 pointer = fixture scorecard |
| D | 01:07:31 | `24d834cc…` | `00fbf48d…` | `993e114a…` | census CLEAN; verdict carries real commit `e1884c6`; D9 pointer = fixture scorecard |
| E | 01:09:56 | `6d4190a7…` | `00fbf48d…` | `7a8e3b45…` | census CLEAN, no W04; verdict still `e1884c6`; resolver semantics unchanged |
| F (post-pin) | 01:13:57 | `511deb27…` | `00fbf48d…` | `93df7d34…` | census exit 0, 0 W04; closure CLEAN; D1 five-W04 text, verdict `e1884c6`, D9 comment unchanged |
| G (repair) | 01:19:14 | `2d1bbbe3…` | `67ac1a42…` | `4e971e3d…` | HEAD `57776b2`; D1 now five-at-base/seven-at-end and quotes all seven; D3 moved to `reported`; selftest 14; bounds say "reported"; lane census still 0 W04 |

Snapshot E full hashes:

```
6d4190a7302eb001c728860e8825c12f0641dafc5cf242cefcb8a4d282ffa236  corpus/sources-census.sh
cfa2c46ae0730730722b62c7078c38b138fc17ac9876ba15e26eff53cdf71de7  corpus/closure-dispositions.py
00fbf48d3ea233d01a7d56ae6ca3291955df82ea522a91e3f3d7dc5644c535e8  corpus/closure-dispositions.json
7a8e3b451fa014ea3a7d1b50db3b3f511684a7a4902617deb3ae26cfc5c84939  corpus/lessons/round-23.md
7101bdd0c69c6d15cedce3ff193db44ae605e36c1cc2a0b6a15c5b36004d3f5b  corpus/source-fetches.tsv
3634eb710fc42dbe180474ece92932f7b11bbed5f3cb2eb0ee081d58249fd9c7  corpus/claim-ledger.tsv
06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29  corpus/SOURCES.md
2358325254a1e7eae0d8b0a6a6b201c7a3b5ea4766a24af3b4849564eb58566e  corpus/fixtures/cells-hermetic/SCORECARD.md
72764bf32fe0600619be9e2c7b780de25c6454489cd2a61ccca1176888874cd7  .ufo/waves/round-23/final-verification.json
3fb7261569f46423dd80ecc23e0a23789a7926f667c7a3fc559d2439d4a64e30  /home/vgpnk/Projects/shokunin/scripts/sources-census.sh
```

Post-pin re-checks. F (01:13:57; lesson `93df7d34…`, census `511deb27…`, TSV `6e26e140…`,
ledger `59869459…`): `bash corpus/sources-census.sh` exits 0 with one stdout line and **0**
W04 lines; `python3 corpus/closure-dispositions.py` is still `CLEAN (obligations=15 fixed=7
... pointers=15)`; `corpus/lessons/round-23.md:66` says "five W04"; the verdict carries
`e1884c6`; the D9 fixture comment is unchanged. The Source-accounting and
falsification-bounds sections shifted +1 line at F.

G (01:19:14, HEAD `57776b2`; lesson `4e971e3d…`, JSON `67ac1a42…`, py `d79b08a7…`, census
`2d1bbbe3…`) is the parent's repair pass. `corpus/lessons/round-23.md:66-75` now says the
**fleet census wrapper** prints five W04 at the base and seven at round end, and quotes all
seven; `:183-184` separates base five from round-end seven; the JSON D1 note matches
("five base ... seven round-end"). D3 moved to `reported` (gate now
`fixed=6 reported=3`), the closure selftest now passes **14** cases, and the bounds section
changed "confirmed the three claims" to "reported on the three claims". The lane census
still prints only the CLEAN line with **0** W04. F1 and F8 are repaired at G; F3-F7 persist;
F2 holds (`measured_commit` still `e1884c6`).

A final check at 01:23:20 (HEAD `31f24e0`, lesson `cfb4d5e9…`) still shows the fleet-wrapper
D1 wording at `:66`, `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 ...
pointers=15)`, and `SOURCES_CENSUS: CLEAN (rows=26 ...)`; no headline finding moved.

`git status --short` at measurement showed `M corpus/SOURCES.md`,
`M corpus/claim-ledger.sh`, `M corpus/claim-ledger.tsv`, `M corpus/sources-census.sh`,
`M corpus/stamps.tsv`, `M corpus/surface-census.sh`,
`M corpus/knowledge/op-ref-consumption.md`, plus untracked
`corpus/closure-dispositions.{json,py}`, `corpus/source-fetches.tsv`,
`corpus/lessons/round-23.md`, `corpus/fixtures/`, `corpus/__pycache__/`. Findings are
pinned to snapshot E; F (01:13:57) confirmed the headline facts and G (01:19:14, HEAD
`57776b2`) is recorded as the repair pass; later edits can still change them without
changing this file.

## Commands and exits

Snapshot E unless noted; F re-checks are called out.

| command | exit | observed |
|---|---|---|
| `python3 corpus/closure-dispositions.py --selftest` | 0 | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (13 cases)` |
| `python3 corpus/closure-dispositions.py` | 0 | `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)` |
| `sha256sum corpus/lessons/round-22-verifier-spotcheck.md` | 0 | `65a5b3de…b55869f7`, equals the JSON `source_sha256` |
| `bash corpus/sources-census.sh --selftest` | 0 | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` |
| `bash corpus/sources-census.sh` | 0 | 102 stdout bytes: `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`; no `W04` line |
| `grep -n 'W04' corpus/sources-census.sh` | 1 | no match: the lane gate has no W04 producer |
| `bash corpus/sources-census.sh` at snapshot A | 1 | stdout 0 bytes; stderr `corpus/sources-census.sh: line 242: S007: unbound variable` |
| `bash corpus/sources-census.sh verify --root .` at snapshot A | 1 | same line-242 error; stdout 0 bytes |
| `cd /home/vgpnk/Projects/shokunin && timeout 120 bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | 0 | 8 stdout lines: **7** `W04` lines (S019, S020, S021, S022, S023, S025, S026) plus `kagi ok .../corpus/SOURCES.md` |
| `test -e .ufo/waves/round-23/final-verification.json` | 1 at A/B; 0 at C/D | C line 3 was `"measured_commit": "pending"`; D line 3 is the commit below |
| `grep -n measured_commit .ufo/waves/round-23/final-verification.json` | 0 | `3:  "measured_commit": "e1884c6ecb7ccd717965b0d748bc193137118dbf"` |
| `git cat-file -t e1884c6ecb7ccd717965b0d748bc193137118dbf` | 0 | `commit` |
| `git merge-base --is-ancestor e1884c6 HEAD` | 0 | true; HEAD is `b55e0e7` (`round-23: S015 debt, D7 wording, relocated seat reports`) |
| `git cat-file -t f4a8dd9 bad9088 584dd67 c2cab35` (each) | 0 | each resolves as `commit` |
| `bash -uc 'A[x]=1'` | 127 | `bash: line 1: x: unbound variable` — minimal repro of the snapshot-A failure |
| `awk -F'\t' '!/^#/ && NF{print $4}' corpus/source-fetches.tsv \| sort -u \| wc -l` | 0 | `9` distinct request URLs for 10 rows |
| `grep -c '^S0' corpus/source-fetches.tsv` | 0 | `10` |
| `grep -c 'Fetch sha256:' corpus/SOURCES.md` | 0 | `16` of 26 registry rows |

Pointer experiments against the shipped resolver, in `/tmp/ptrlab/p1` and `/tmp/ptrlab/p2`
(not the lane), run against all resolver versions observed (`6cc82278…`, `bf6154b1…`,
and `cfa2c46a…`):

- P1: anchor heading exists, but `D1` occurs only in a section after it → exit 0,
  `CLEAN (...) pointers=1`.
- P2: no heading at all; the anchor text appears only as `#` inside a fenced shell block →
  exit 0, `CLEAN (...) pointers=1`.

## Per-disposition pointer resolution (snapshot E)

"Token" is the gate regex found anywhere in the target; "in section" is the subset inside
the section the anchor names. No pointer is dangling and no anchor heading is missing.

| id | disposition | pointer (JSON line) | resolution site | token | in section |
|---|---|---|---|---|---|
| SPOT-01 | no-action | `corpus/SOURCES.md` (:11) | file exists; S018 row `:24` | **no** | n/a, unanchored |
| SPOT-02 | no-action | `corpus/SOURCES.md` (:18) | file exists; S017 row `:23` | **no** | n/a |
| SPOT-03 | no-action | `corpus/SOURCES.md` (:25) | file exists; S020-S023 rows `:26-29` | **no** | n/a |
| SPOT-04 | no-action | `corpus/knowledge/feature-bound-credential-review.md` (:32) | rejection table `:14-18` | **no** | n/a |
| SPOT-05 | no-action | `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` (:39) | erratum `:113` | **no** | n/a |
| ADJ | reported | `corpus/lessons/round-23.md` (:46) | `:137` | yes | n/a, unanchored |
| D1 | fixed | `corpus/lessons/round-23.md#Routed defect dispositions` (:53) | heading `:64`; body `:66` | yes (`:15`, `:66`, `:178`) | yes (`:66`) |
| D2 | reported | same anchor (:60) | heading `:64`; body `:78` | yes (`:78`) | yes |
| D3 | fixed | same anchor (:67) | heading `:64`; body `:84` | yes (`:84`) | yes |
| D4 | fixed | same anchor (:74) | heading `:64`; body `:92` | yes (`:92`) | yes |
| D5 | fixed | same anchor (:81) | heading `:64`; body `:98` | yes (`:98`) | yes |
| D6 | fixed | same anchor (:88) | heading `:64`; body `:102` | yes (`:102`) | yes |
| D7 | fixed | `corpus/source-fetches.tsv` (:95) | header comment `:2`; rows `:37-46` | yes, comment only (`:2`) | n/a |
| D8 | operator-owned | same anchor (:102) | heading `:64`; body `:121` | yes (`:121`) | yes |
| D9 | fixed | `corpus/fixtures/cells-hermetic/SCORECARD.md` (:109) | HTML comment `:1`; fixture cites `R90-01`/`R90-02`, never `R23-01` | yes, comment only (`:1`) | n/a |

Counts: 15/15 target files exist; 7/15 rows are anchored and all 7 resolve to the single
`## Routed defect dispositions` heading at `corpus/lessons/round-23.md:64`; 10/15 targets
contain the id token; 5/15 (all SPOT) contain none; 2/15 tokens (D7, D9) live only in a
comment line, not in machine rows. At G, D3 changes from `fixed` to `reported`; all other
rows and targets are unchanged, and the gate reports `fixed=6 reported=3`.

## Findings

### F1 HIGH — D1's "five W04 warnings" is unreproducible at round end

The disposition (`corpus/closure-dispositions.json:49-53`, note at `:52`) was `fixed` at
snapshots A-F on "the five W04 duplicate-URL warnings". The lesson repeated it at
`corpus/lessons/round-23.md:66` ("The census prints five W04 duplicate-URL warnings") and
`:177-179` ("census at round end must exit 0 with the same W04 warnings"). Measured at E/F:

- The lane gate named by the lesson, `bash corpus/sources-census.sh`, exits 0 and prints
  only the 102-byte CLEAN verdict. `grep -n 'W04' corpus/sources-census.sh` exits 1 with
  no match: the gate has no W04 producer at all.
- The fleet gate named by the falsification dispatch,
  `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`,
  exits 0 and prints **seven** W04 lines: the five quoted plus S025 and S026.

The five backticked lines at `corpus/lessons/round-23.md:68-72` match the fleet output
verbatim (no paraphrase; a literal set comparison leaves `quote_not_in_census` empty), but
two real warnings are omitted:

```
missing_from_quote: ['W04 S025 duplicate url openbao.org/docs/auth/jwt across scopes',
                     'W04 S026 duplicate url openbao.org/docs/concepts/tokens across scopes']
```

The lesson's own parenthetical at `:73-76` names S025/S026 as correction rows over the two
URLs the census flags, so the omission is not a scope decision. Against the lane gate the
count is zero, against the fleet gate seven; neither is five at F. Repair status: at G
(HEAD `57776b2`) the lesson and the JSON note were rewritten to "five at the base, seven at
round end" and the quote lists all seven warnings. The disposition is now reproducible from
the **fleet** wrapper it names, while the lane gate named in the round's before/after table
(`bash corpus/sources-census.sh`) still prints 0 W04. F1 is repaired at G; the residual is
a naming split between the two census commands, not a count error.

### F2 MEDIUM — D6 was certified `fixed` while its artifact was absent, then pending

At snapshot E the claim finally holds: `.ufo/waves/round-23/final-verification.json`
(`72764bf3…`) line 3 is
`"measured_commit": "e1884c6ecb7ccd717965b0d748bc193137118dbf"`, `git cat-file -t` returns
`commit`, and `git merge-base --is-ancestor e1884c6 HEAD` exits 0 (HEAD `b55e0e7`). The
lesson's future tense at `corpus/lessons/round-23.md:102-104` is now satisfied.

The falsification target is the timeline, not the final byte: the disposition was already
`fixed` at snapshots A and B, when `test -e .ufo/waves/round-23/final-verification.json`
exited 1 and only round-22 verdict files existed, and at snapshot C, when the file's only
measured commit value was the literal `"pending"`. The gate passed D6 in every snapshot
because the token `D6` occurs at `round-23.md:102` inside the anchored section; a
presence-only test cannot distinguish an absent file, a placeholder, and a real
measurement. D6 therefore reproduces F9's bound rather than violating it, but the `fixed`
label carried no evidence at the time it was asserted.

### F3 MEDIUM — D9's pointer moved to a fixture input that never names the row it claims

Snapshot A: D9 pointed at `corpus/claim-ledger.tsv`, where row `R23-01` existed at `:59`
with `D9` in field 6. Snapshots C-F: the pointer is
`corpus/fixtures/cells-hermetic/SCORECARD.md` (`corpus/closure-dispositions.json:109`),
whose only `D9` occurrence is an HTML comment at line 1
(`<!-- D9: hermetic cells fixture; rows are declared in claims.tsv -->`). The fixture
scorecard cites `R90-01` and `R90-02` only; it never names `R23-01`. The disposition note
says the "cells row R23-01 executes the parser host-free", but the pointer target is the
fixture input, not the ledger row that executes.

This is not an unrelated file — the fixture is what the row reads — but it is the wrong
evidence site for the claim: the pointer proves the fixture exists, not that `R23-01`
runs or what it prints. The pointer has no anchor, the token is a comment, and the same
disposition changed targets within three minutes of the review. The row remains at
`corpus/claim-ledger.tsv:59` (hash `0d3d7500…`); I did not execute it (C3 seat).

### F4 MEDIUM — five of fifteen pointers are existence-only (declared, but still empty)

SPOT-01..05 (`corpus/closure-dispositions.json:7-40`) are unanchored whole-file pointers,
and the gate regex finds zero occurrences of `SPOT-01`…`SPOT-05` in any of the five
targets. The only record of each decision is the JSON note, plus the aggregate phrase
`SPOT-01..05` at `corpus/lessons/round-23.md:136`. The two knowledge targets do not even
carry the literal rejected-reading terms the notes name: no `uniform` (any case) in
`corpus/knowledge/feature-bound-credential-review.md`, no `borrowed` in
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md`; both carry paraphrased
rejections (table `:14-18`; erratum `:113`).

The lesson's bounds section discloses the rule at `:188-189` ("only `fixed` dispositions
require the id token"), so this is no longer an undisclosed gate secret. It remains a
calibration gap against any reading in which "one typed disposition each" implies the
disposition is locatable at its pointer: one third of the set is locatable only in the
JSON itself.

### F5 LOW — D7's pointer is a comment line; the coverage mapping itself holds

`corpus/source-fetches.tsv:2` is the header comment `# D7: bind every mined row WITHOUT an
in-row pin to a declared representation; ...`; it is the only `D7` occurrence. The ten
data rows (`:37-46`) carry no obligation id, so the `fixed` token is prose in a data file.
The enforcement is `SC_FETCH` in `corpus/sources-census.sh` (header at `:56`; the check
block inside `verify()`), which the pointer does not name; it now executes (gate exit 0).

The coverage mapping is correct: 26 registry rows, 16 with in-row `Fetch sha256:` pins
(S001-S016), and exactly the 10 unpinned rows S017-S026 are the 10 TSV rows. The lesson's
URL count, wrong at snapshot A ("seven distinct URLs"), is corrected to "nine"
(`corpus/lessons/round-23.md:174`); I measured `9` distinct request URLs for the 10 rows
(S021 and S026 share the tokens URL).

### F6 LOW — D3's first sentence still says "every wave context" names paths one omits

The JSON note now reads (snapshot E, `corpus/closure-dispositions.json:66`): "wave
contexts name forbidden paths; the mode-token positional guard is selftest-covered, while
id-shaped positionals remain routed debt (ClaimR11X09)". The lesson's second sentence was
updated to match (`corpus/lessons/round-23.md:86-90` explicitly routes the `R1-01` gap).
The first sentence is unchanged at `:84-86`: "Every wave context this round names the
forbidden paths (host-private files, vault refs/tokens, live config contents, sibling
lanes, `.ufo/state`, MANIFEST.json)".

Measured on the single `context` string of each wave spec:
`.ufo/waves/round-23/parent-build-spec.json` (2438 chars) contains `MANIFEST.json` 0,
`.ufo/state` 0, `forbidden` 0, `live config` 0, `sibling` 1, `vault` 2, `credential` 1.
`.ufo/waves/round-23/falsify-spec.json` (1807 chars) contains `MANIFEST.json` 1,
`.ufo/state` 1, `sibling` 1, `vault` 1, `credential` 1. The falsify wave names them; the
parent-build wave does not. The note's second clause holds: `mode-unknown-revision` is at
`corpus/claim-ledger.sh:1292` with `unexpected positional argument for verify`. At G the
disposition is `reported`, so the label no longer claims the fix; the lesson's first
sentence remains the only overstated text in this row.

### F7 LOW — D5's literal `CriticNoTrade-2` is not in the pointer target

`corpus/closure-dispositions.json:80` says the report "names the reused CriticNoTrade-2
identity". `corpus/lessons/round-23.md:98-100` says only "`CriticNoTrade` was reused as a
fresh `-2` identity". The literal `CriticNoTrade-2` appears in
`corpus/lessons/round-22.md:224-227` and round-22 evidence, not in the D5 target. The
numeric substance reproduces: 64 distinct `agentId`s in
`.ufo/waves/round-22/build/swarm-registry.json` plus 66 in
`.ufo/waves/round-22/falsify/swarm-registry.json` = 130, consistent with "130 spawn IDs
under 129 names".

### F8 LOW — the lesson asserts the falsification wave's conclusion while the wave runs

`corpus/lessons/round-23.md:181-196` ("Falsification bounds (round 23)") opens at `:183`:
"The 64-seat falsification wave confirmed the three claims and named these bounds". At
measurement the wave's own spec has 64 items (`.ufo/waves/round-23/falsify-spec.json`) and
the report directory held 24 report files; this seat was still writing. The
"confirmation" is written inside the artifact under test, before the seats reporting
against D1 and D9 landed, and while D1's quoted evidence is contradicted (F1). The bounds
paragraph itself is accurate about the gate's presence-only semantics (F9); the
"confirmed" verb is not supported by the artifacts at measurement time. Repair status: at G
the sentence was changed to "reported on the three claims"
(`corpus/lessons/round-23.md:188`), closing the timing concern; the "confirmed" wording is
kept here as snapshot-E evidence.

### F9 INFO — the resolver's presence-only semantics are disclosed and reproduce

`corpus/closure-dispositions.py:107-124` resolves a pointer as: path exists and stays
inside the root; any `#`-prefixed line contains the anchor substring; for `fixed` only, the
id token occurs anywhere in the file. P1 and P2 both return exit 0 `CLEAN (...) pointers=1`
against the current resolver (`cfa2c46a…`, and `bf6154b1…` earlier): P1 puts the id outside the anchored section;
P2 puts the anchor text in a fenced shell comment with no heading. The lesson now states
both properties (`:184-189`: "presence-only", "anchor matching is a substring over any
`#`-prefixed line", "only `fixed` dispositions require the id token"). The disclosure is
accurate, so these are declared bounds, not hidden defects; F1/F2/F3 are the concrete
instances where a presence-only pass certifies prose that is stale, unfilled, or filed at
the wrong site. The new realpath containment check (`:112-120`) is an improvement over the
snapshot-A resolver (`6cc82278…`), which had no symlink/root containment check; no pointer
escapes either way in the current set.

### F10 INFO — snapshot A's census crash and the selftest gap that hid it

At snapshot A (`sources-census.sh` `80966e20…`), `bash corpus/sources-census.sh` exited 1
with `line 242: S007: unbound variable` and zero stdout bytes; `verify --root .` did the
same. Root cause: `set -uo pipefail` at `:107`, `declare -A` lists at `:203`/`:229` that
omitted `SUPERSEDED`, and a `SUPERSEDED[$fid]=1` assignment at `:242`; `bash -uc 'A[x]=1'`
returns the same message. The trigger was real registry content: `corpus/SOURCES.md:25`,
`:26`, `:28`, `:29` have teaches cells beginning `supersedes S...`, and S007 aborted the
first iteration. The 59-case selftest did not catch it because its fixture registry
(snapshot-A `corpus/sources-census.sh:358-363`) has no `supersedes S...` cell, so the line
was never executed.

Snapshots B-E (`24d834cc…` through `6d4190a7…`) removed the block: no `SUPERSEDED`
reference remains, the gate
exits 0 with `SOURCES_CENSUS: CLEAN (rows=26 ...)`, and the 59 cases still pass. Recorded
because the wave was first handed the crashing version and because the selftest's fixture
still does not exercise registry-driven `supersedes` parsing (that code is now gone, so
the immediate exposure is closed).

## Fixed dispositions whose pointer is only prose

At snapshot E, **all seven** `fixed` rows point at prose or comments; at G, D3 is
`reported`, leaving six fixed rows (D1, D4, D5, D6, D7, D9), and none of the six points at a
machine-checkable artifact that binds the obligation:

| id | pointer target | prose form | independent check |
|---|---|---|---|
| D1 | lesson `:64` section | quoted warnings + narrative | at E/F the quote was five vs fleet seven; at G it quotes seven and matches the fleet wrapper; lane gate still 0 W04, F1 |
| D3 | lesson `:64` section | narrative; second sentence now routes the id-shaped gap | parent-build context lacks two named paths, F6 |
| D4 | lesson `:64` section | narrative citing four hashes | all four commits resolve, `git cat-file -t` exit 0 each |
| D5 | lesson `:64` section | narrative counts and identity | 64+66=130 reproduces; literal `CriticNoTrade-2` absent, F7 |
| D6 | lesson `:64` section | narrative, future tense | at E the verdict carries `e1884c6`, an ancestor of HEAD; absent/pending at A-C, F2 |
| D7 | TSV header comment `:2` | comment line, no row binding | coverage mapping correct; `SC_FETCH` runs, F5 |
| D9 | fixture HTML comment `:1` | fixture input, never names `R23-01` | row is at `claim-ledger.tsv:59`; not executed (C3 seat), F3 |

D4 holds; D5 holds in substance but not in the literal naming; D6 holds at snapshot E
after being absent and pending earlier. At E/F D1 was contradicted by the census (repaired
at G); D9 points at the
wrong evidence site, and D7/D3 are comment/prose evidence whose prose is partly stale.
This is consistent with the gate's own declared bound ("does not judge whether a
disposition's prose is honest", `corpus/closure-dispositions.py:34-37`); it also means the
`fixed` labels carry no stronger guarantee than presence.

Final status at G (HEAD `57776b2`, 01:19:14): F1 and F8 are repaired by the parent; F2 holds
(`measured_commit e1884c6`); F3-F7 persist as stated; the closure selftest is now 14 cases
and the gate reports `fixed=6 reported=3` because D3 moved to `reported`.

## Residual risk and verification gaps

- Moving target: hashes changed at every visit, A to G. Dispositions JSON
  `f20f00d1…` → `5de116d1…` → `00fbf48d…` → `67ac1a42…`; lesson `d5520988…` →
  `bce51c92…` → `2f53cf69…` → `993e114a…` → `7a8e3b45…` → `4e971e3d…`; census
  `80966e20…` → `24d834cc…` → `6d4190a7…` → `2d1bbbe3…`; resolver `6cc82278…` →
  `bf6154b1…` → `cfa2c46a…` → `d79b08a7…`; provenance TSV `ccc9ae6e…` → `a78fde7b…` →
  `846b2037…` → `7101bdd0…` → `6e26e140…`; ledger `6fa0c24f…` → `0d3d7500…` →
  `3634eb71…` → `ed125ca5…`; verdict absent → `e6c11f49…` (`pending`) → `72764bf3…`
  (`e1884c6`). Every finding is pinned to the snapshot named in its section; the G repair
  is recorded above, and later edits can still change the outcome.
- The fleet census is a different script generation (mtime 2026-10-19 21:22,
  `3fb72615…`) from the lane's round-23 script. It is the correct witness for the seven
  quoted lines (five base + S025/S026 at round end) because they match it verbatim, but it
  cannot certify the lane's `SC_FETCH` version.
- No LSP: `xd://lsp` does not exist in this session. Token/anchor absence is literal text
  search, not semantic resolution; no `diagnostics`, `references`, or `definition`
  requests were possible.
- Not run: the 43 claim-ledger row audits (explicitly out of scope), row `R23-01` (C3
  seat), any host-bound row, any legacy `claim-ledger verify`, any network fetch, any
  install. Tool record: no installs.
- `resume_continuity_v1`: there is no resume path in this assignment; the gate and check
  are N/A here, not passed.
- Anchors use literal spaces (`#Routed defect dispositions`), which no markdown renderer
  resolves; only the gate's substring rule does. This is a design risk, not a dangling
  pointer: the one anchor exists at `corpus/lessons/round-23.md:64`.

## Read set (read-only)

`corpus/closure-dispositions.json`, `corpus/closure-dispositions.py`,
`corpus/lessons/round-22-verifier-spotcheck.md`, `corpus/lessons/round-23.md`,
`corpus/lessons/round-22.md`, `corpus/SOURCES.md`, `corpus/source-fetches.tsv`,
`corpus/claim-ledger.tsv`, `corpus/sources-census.sh`, `corpus/claim-ledger.sh`
(grep only), `corpus/fixtures/cells-hermetic/{SCORECARD.md,claims.tsv,stamps.tsv}`,
`corpus/knowledge/feature-bound-credential-review.md`,
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md`,
`.ufo/waves/round-23/parent-build-spec.json`, `.ufo/waves/round-23/falsify-spec.json`,
`.ufo/waves/round-23/final-verification.json`,
`.ufo/waves/round-22/*/swarm-registry.json`,
`.ufo/waves/round-23/parent-build/ClaimR11X05.md` (one cited line),
git metadata via `git cat-file`/`git merge-base`/`git log` (read-only),
`/home/vgpnk/Projects/shokunin/scripts/sources-census.sh` (executed read-only).
