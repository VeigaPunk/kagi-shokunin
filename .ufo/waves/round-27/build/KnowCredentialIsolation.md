# KnowCredentialIsolation — C1 inventory of `corpus/knowledge/credential-isolation.md`

Seat: `KagiR26.KnowCredentialIsolation-17` (leaf member, no dispatch). Round 27
build, axes **calibration** and **freshness**. Frozen BASE
`0a47dd189356ea66ec83c3891eed54526e95b89b`.

Target read at BASE: `corpus/knowledge/credential-isolation.md`, 78 lines /
3986 bytes, sha256 `03570c6578e3c9232e0babc23f3c249347502526cdddfa9e612fc3f126e113b3`
(`wc -lc`, `sha256sum`, `git show BASE:… | wc -lc`). The integration worktree
also carries this path byte-identical (`git status --porcelain --
corpus/knowledge/credential-isolation.md` is empty; `git diff --stat HEAD -- …`
is empty) and the stamp row `corpus/stamps.tsv:34` matches the same three
values. Last content edit is `2486643` (round 14); `git diff --stat 2486643
BASE -- corpus/knowledge/credential-isolation.md` is empty.

No host-private read, no gate/selftest run, no `stamp`, no Git/jj mutation, no
install. This report is advice; nothing under production paths was edited.

## 1. Result — zero in-population numbers, zero bindings

Applying the QM21 current-tense rule (`corpus/QUALITY.md:118` at BASE), R25-C6
(`corpus/lessons/round-25.md`), and the round-27 `KN-*` population rule
(`corpus/self-counts.tsv` header: current-tense numbers about this lane's own
artifacts, *excluding* host/substrate observations — the round-27 header is in
the integration worktree, post-BASE):

**The entry states no current-tense number about a lane-owned repo artifact.**
It has no selftest case count, no ledger/stamp/claim row count, no data-file row
count, no knowledge-declaration count, and no line/byte count of a lane-owned
repo file. Every numeric statement about a file's size or content is a
2026-09-28 observation of the host janitor substrate
(`~/.local/bin/the-janitor`,
`~/.config/the-janitor/opencode.json`,
`~/.config/opencode/agents/janitor.md`,
`~/.config/opencode/tools/janitor_auth.ts`,
`~/.local/state/tac/handoff-status.json`). `PROVINCE.md:10-15` at BASE declares
those surfaces HISTORICAL and the substrate measured absent; the round-25
inventory classified this entry `HISTORICAL (host; no erratum)`
(`.ufo/waves/round-25/build/SelfInvKnowledge2.md:52`).

Consequently the C1 binding table for this entry is empty:

| id | doc | locator | source | extract | note |
|---|---|---|---|---|---|
| *(none)* | `corpus/knowledge/credential-isolation.md` | — | — | — | 0 in-population numbers at BASE and in the round-27 after table |

`corpus/self-counts.tsv` contains **0** rows for this path at BASE
(`git show BASE:corpus/self-counts.tsv | grep -c credential-isolation` → `0`)
and **0** in the integration worktree. The 18 `KN-*` rows present at read time
bind seven other knowledge entries, not this one.

This is not a pass on the entry's host facts. It means no `rows:` / `ledger:` /
`expect:` binding exists, or can legally be written under the lane's own
population rule, for what this entry states (see §3).

## 2. Candidate numbers and their nearest lane-local sources

These are the only numbers that could be mistaken for lane-artifact counts. All
are recorded here with a unique locator so a future review does not have to
re-derive them; **none is proposed as a binding**.

| # | line | exact text (backtick markup omitted) | number | nearest lane-local source | committed/live value | verdict | locator |
|---|---|---|---|---|---|---|---|
| 1 | L18 | `unsets 20 model/API credential` variables | 20 | none. `corpus/knowledge/claim-ledger.md:407` (BASE) names this count among the sentences *no row touches*; `corpus/drift-symbols.tsv:16` pins only source line 214 (`^  unset ANTHROPIC_API_KEY`), not the operand count | no pin; substrate absent | OUT — host/substrate observation; no lane-local source | `L18` |
| 2 | L31 | `~/.config/the-janitor/opencode.json` (759 bytes, read 2026-09-28) | 759 | none. `corpus/drift-baseline.tsv:3` pins mode 644, **29 lines** and a sha256, not bytes; `rows:` would return 15 data rows, not a cell | no pin; substrate absent | OUT — host/substrate observation; no lane-local source | `L31` |
| 3 | L42 | `steps: 4`, permission … | 4 | three committed assertions agree: `corpus/drift-symbols.tsv:23` (`^steps: 4` at janitor.md line 6), `corpus/surface-census.tsv:27` note ("steps 4"), `corpus/checklist.tsv:37` expected last line (`JANITOR_PERMS: OK (entries=2 steps=4)`) | 4 in all three committed cells | OUT — host agent config; file under the **unresolved** `$HOME/.config/opencode` group (`corpus/adjacency.tsv:81`), not lane-owned; no ledger row prints it | `L42` |
| 4 | L44 | `~/.config/opencode/tools/janitor_auth.ts` (14 lines) | 14 | `corpus/drift-baseline.tsv:8` column 3 = **14** (mode 644, sha `2382d5af…`); but `rows:` counts data lines (15), it cannot extract the cell; no ledger row prints it | 14 in the committed baseline | OUT — cross-lane file, and no *existing* legal source expression; committed data agrees | `L44` |
| 5 | L64 | `## The steps: 4 cap is load-bearing` | 4 | same fact as row 3 | 4 | OUT — duplicate of the same bound, not a second number | `L64` |
| 6 | L68 | `needs >4 model steps dies` | 4 | same fact as row 3 | 4 | OUT — duplicate of the same bound | `L68` |
| 7 | L7 | `Reverify: R11-01, R11-04` | (2 IDs) | `corpus/claim-ledger.tsv:32` (`R14-01`, `DOC_AUDIT` per-entry `row_linked`); both ids resolve | identity, not a stated cardinality; the row's **last line** reports the total `row_linked=22` (BASE), not this entry's 2 | OUT — membership, not a number; cardinality would be the weak QM18 projection | — |

Locators (Python regex, exactly one capture group; each verified at BASE with
`re.search` to match exactly one line — hit line shown):

```text
L18  unsets ([0-9]+) model/API credential          -> line 18
L31  ^`~/\.config/the-janitor/opencode\.json` \(([0-9]+) bytes   -> line 31
L42  ^`steps: ([0-9]+)`                            -> line 42
L44  ^`~/\.config/opencode/tools/janitor_auth\.ts` \(([0-9]+) lines\)  -> line 44
L64  ^## The `steps: ([0-9]+)` cap                 -> line 64
L68  needs >([0-9]+) model steps                   -> line 68
```

The regexes are correct as written; the backticks are literal characters in the
document. They are recorded for a future promotion, not as rows of
`corpus/self-counts.tsv`.

## 3. Why no binding can be written today

- **`rows:` cannot bind a cell.** At BASE `corpus/self-counts.py:142-148`
  accepts `rows:<path>` only with extract `-`, and the path is counted as
  nonblank, non-comment data lines (header, `corpus/self-counts.tsv:11-14` at BASE).
  `rows:corpus/drift-baseline.tsv` is 15; `rows:corpus/drift-symbols.tsv` is 20.
  Neither is the claimed number.
- **`ledger:` cannot be used for the source rows.** The entry's two reverify
  rows are `[substrate]` (`corpus/claim-ledger.tsv:15` R11-01, `:18` R11-04);
  QM15 (`corpus/QUALITY.md:97` at BASE) makes `verify`/`cells` skip them unless
  the caller passes a per-invocation consent flag. They are not run here. No
  other non-host row prints 20, 759, 14 or 4 with this meaning.
- **`expect:` has no literal to read.** R11-01's committed expect is
  `^SURFACE_CENSUS: CLEAN \(assets=[1-9][0-9]* runtime=…` and R11-04's is
  `^DRIFT_PINS: CLEAN \(files=[1-9][0-9]* symbols=[1-9][0-9]*\)`; neither
  contains 20, 759, 14 or 4. `expect:` applies the extract to the committed
  **expect column**, not to a host measurement.
- **A new host-printing row would recreate the excluded class.** Adding a row
  that prints the credential-variable count or the byte size would bind the doc
  to a host read the lane cannot re-measure while the substrate is absent
  (QM1), and the round-27 population explicitly excludes host/substrate
  observations. For `14`/`4`, a new **non-host** row that prints the committed
  `drift-baseline`/`drift-symbols` cell is technically possible, but the files
  sit under `$HOME/.config/opencode`, which `corpus/adjacency.tsv:81` leaves
  `unresolved` and assigns to the integrator as arbiter, not to this lane as
  owner.

## 4. Calibration counterexamples — false admits to refuse

1. **L18's 20 vs `rows:corpus/drift-symbols.tsv` = 20.** The data file has 20
   symbol-pin rows; the entry counts unset credential variables. A binding here
   reads OK today and stays green after a count-preserving swap of one drift
   symbol for another — the exact QM18 weak signal. Reject.
2. **L42/L64/L68's 4 vs `ledger:R16-05` = 4.** R16-05 runs
   `grep -cE '^[^#[:space:]]' corpus/adjacency.tsv` and expects `^4$`
   (`corpus/claim-ledger.tsv:43`): four *group rows*, not a model-step cap. A
   locator capturing the 4 in "steps: 4" would bind a host agent bound to the
   ownership partition and read OK. Reject.
3. **L44's 14 vs `rows:corpus/drift-baseline.tsv` = 15.** The source grammar
   returns the row count, not column 3; the cell is 14 and the row count is 15.
   Binding the row count is off by one, and a deleted baseline row would flip it
   green for the wrong reason. Reject.
4. **The implicit 2 reverify ids vs `ledger:R14-01` `row_linked=22`.** The
   binder applies the extract to the row's last nonempty output line, which is
   the `DOC_AUDIT` *summary* (22 row-linked entries at BASE), not the per-entry
   line. A `row_linked=([0-9]+)` extract would compare 2 with 22. Reject as a
   count binding; membership identity is a different projection.
5. **759 vs any other `759`.** No other 759-byte object exists in the lane;
   the substring occurs in unrelated values (e.g. the 7591-byte stamp total at
   `corpus/stamps.tsv:46`) and in old interactive-session text, none of which is
   this file. Any match is coincidental. Reject.

These are static counterexamples. The binder was **not** executed (see §7), so
they are reasoned from the grammar and the committed cells, not measured
receipts.

## 5. Exclusion census — every numeric line of the entry

Classes: **H** host/substrate observation (absent substrate; round-27 exclusion);
**D** dated measurement/date; **I** identifier or literal, not a size/count;
**M** membership, not a stated cardinality; **W** word-form count, not
representable by the binder's `[0-9]+` capture.

| line | exact text (snippet; backtick markup omitted) | numeric tokens | class | why excluded |
|---|---|---|---|---|
| L3 | Source: ~/.local/bin/the-janitor cmd_serve (L186–226) … | 186, 226 | H | line positions in an absent host file; not a count of a lane artifact |
| L5 | All read 2026-09-28. | 2026-09-28 | D | dated read; a date, not a size |
| L7 | Reverify: R11-01, R11-04 | 11, 01, 04 | M | row ids; two members, not a stated number |
| L11 | _serve runs … Two auth paths (L194–210) | Two; 194, 210 | H/W | host code paths + line range; spelled count cannot be captured by the binder |
| L17 | authorization process_memory_only, L170) | 170 | H | line position in an absent host file |
| L18 | unsets 20 model/API credential variables | 20 | H | host operand count; no lane-local source (see §2 row 1) |
| L20 | L214–219). Comment at L212–213: | 214, 219, 212, 213 | H | line positions; only L214 has a symbol pin, not a count |
| L23 | 127.0.0.1:40961 (--hostname 127.0.0.1 --port 40961 | 127, 0, 0, 1, 40961 (twice) | I | IP/port literals, not sizes |
| L24 | L225) with --log-level ERROR | 225 | H | line position |
| L25 | (chmod 700, | 700 | I | mode literal |
| L26 | L190–191, L222–224): handler state … | 190, 191, 222, 224 | H | line positions |
| L31 | ~/.config/the-janitor/opencode.json (759 bytes, read 2026-09-28) | 759; 2026-09-28 | H/D | host byte size with a dated read; no byte pin (see §2 row 2) |
| L34 | qwen-local/Qwen3-Coder-30B-A3B-Instruct-UD-IQ2_XXS | 3, 30, 3, 2 | I | digits inside a model identifier, not counts |
| L35 | http://127.0.0.1:8080/v1 | 127, 0, 0, 1, 8080, 1 | I | endpoint literal |
| L42 | steps: 4, permission: … | 4 | H | host agent-config bound; cross-lane file (see §2 row 3) |
| L44 | ~/.config/opencode/tools/janitor_auth.ts (14 lines) | 14 | H | host line count; cross-lane file; committed cell agrees but no legal source (see §2 row 4) |
| L46 | exactly AUTH_OK (exit 0) or AUTH_REQUIRED | 0 | I | exit-code literal |
| L47 | mapped to a two-word string | two | W | host behavior count; word form |
| L49 | Agent invariants (janitor.md L14–30) | 14, 30 | H | line positions in an absent host file (41 lines per drift-baseline.tsv:7, so the range is internally in bounds) |
| L55 | ## Caveat: … (round 7) | 7 | I | round label, not a size; QM21's "round N" note concerns size numbers, and this is not one |
| L58 | the HTTP control plane on 127.0.0.1:40961 | 127, 0, 0, 1, 40961 | I | endpoint literal |
| L64 | ## The steps: 4 cap is load-bearing | 4 | H | same fact as L42, not a second number |
| L68 | needs >4 model steps dies | 4 | H | same fact as L42, not a second number |
| L75 | endpoint http://127.0.0.1:8080/v1 | 127, 0, 0, 1, 8080, 1 | I | endpoint literal |
| L77 | shows all three stdio streams | three | W | host behavior count; word form |

Counting note: 25 lines carry digits or spelled numbers; after removing
identifiers, duplicates and line positions, four distinct numeric facts survive
(20, 759, 14, and one `steps: 4` bound) plus a two-ID membership. None is a
lane-owned repo artifact.

Population ambiguity, stated rather than hidden: `credential-isolation.md:5`
dates the whole source read. If a reviewer treats that header as an explicit
history clause for every body number, all are historical by QM21. If a reviewer
requires the history clause beside the number (the stricter reading), L18/L31/
L44 stay current-tense. Under **both** readings the C1 outcome is the same —
either excluded as dated, or in-scope but unbindable because no legal lane-local
source exists. The conclusion (0 bindings) does not depend on resolving that
judgement call.

## 6. Freshness findings (QM1/QM26), kept separate from C1

**F1 — the round-25 debt pointer does not resolve.** `corpus/lessons/round-25.md:164`
names `knowledge/credential-isolation.md:120-122` among the stale numbers. The
entry is 78 lines at BASE (`wc -lc`; sha `03570c65…`; stamp `corpus/stamps.tsv:34`),
its last content edit is `2486643` (round 14), `git diff --stat 2486643 BASE --
<path>` is empty, and it is byte-identical at the round-25 base `4587c61`. The
four revisions that ever changed the file are 67 lines (`9b3e49f`), 76
(`51c9d30`), 76 (`e64e81b`) and 78 (`2486643`); no revision had lines 120–122.
`corpus/lessons/round-27.md:66` already records the pointer as stale; this
report independently confirms it. The numbers a fresh review must qualify are
L18/L31/L44 (and the host line ranges), not 120–122. Do not restate 120–122 as
current, and do not edit the append-only round-25 lesson to “fix” it.

**F2 — no historical-source erratum, unlike its siblings.** Two neighbours
carry the round-16 re-dispatch marker: `corpus/knowledge/janitor-env-contract.md:92`
and `corpus/knowledge/handler-trust-boundary.md:288` (“Historical-source
erratum — round-16 re-dispatch (2026-10-15)”, `Source-status: historical`).
They record `ENOENT`/absent for `~/.local/bin/the-janitor`,
`~/.config/the-janitor/client.py`, `~/.config/the-janitor/config.json`, and the
cited paths under `~/.config/opencode` (`janitor-env-contract.md:101-104`;
`handler-trust-boundary.md:299-305`). `PROVINCE.md:10-15` at BASE records the same
absence. `credential-isolation.md:3-5` has only “All read 2026-09-28” and no
`Source-status`/erratum; its body remains present tense at L18, L23, L31 and
L44. That is QM1's weak signal — “a sha256 prefix, mode or line count stated in
present tense about a path `test -e` no longer finds”
(`corpus/QUALITY.md:39` at BASE). Round-25's `HISTORICAL (host; no erratum)`
line is a reader classification, not an in-document marker.
*Conditional:* I did not probe the host; the finding rests on the lane's own
2026-10-15 records. If the substrate has been restored since, the present tense
could be current and this finding flips. A restored source still would not make
the numbers current without a fresh read.

**F3 — the named recheck is default-skipped and does not measure the counts.**
L7 names R11-01/R11-04. Both are `[substrate]`
(`corpus/claim-ledger.tsv:15,18`) and are HOST-SKIP by default under QM15
(`corpus/QUALITY.md:97` at BASE): a plain `verify` does not run them. R11-04
checks sha/mode/lines of 15 baseline files and 20 symbol lines; it does not
print “20 vars” or “759 bytes”. `corpus/knowledge/claim-ledger.md:407` at BASE
explicitly names the 20-var count among the sentences no row touches, and
`.ufo/waves/round-22/build/Entry08.md:165` calls `759 bytes` a Class-6 gap
(confirmed at `:288`). So no default gate can tell a reader whether these
numbers are stale; only a restored, authorized fresh read can.

**F4 — no release-clock interaction.** The entry has no `on-release` line, no
feed/registry row, and no `X.Y.Z` anchor. The model identifier's digits and the
two ports are identifiers, not versions. C2's REGRESSED rule neither covers nor
exempts a number in this entry. (C2 code was not run; it is not this item.)

## 7. What I did NOT check — unrun is not a pass

- **No host-private read or probe.** I did not read, `stat`, `test -e` or
  otherwise touch `~/.local/bin/the-janitor`, `~/.config/the-janitor/*`,
  `~/.config/opencode/*`, `~/.local/state/tac/*`, `op.env`, sessions, vault,
  account or handler. The absence claim is inherited from `PROVINCE.md:10-15`
  and the 2026-10-15 sibling errata, not measured this round. Disclosure: a
  repo-wide `grep` for the literal `759` traversed `.ufo/interactive-sessions/`
  and printed two old tool-result snippets; they are chat transcripts, not host
  state, and no content from them is used as evidence here.
- **No gate or selftest execution.** `corpus/self-counts.py`,
  `claim-ledger.sh` (`verify`/`docs`/`citations`/`cells`), `drift-pins.sh`,
  `scope-gate.sh`, `checklist-run.sh` and `release-clock.py` were not run. No
  binder receipt and no mutation control exist for this report; the zero-binding
  result is a static reading of the table, the grammar and the committed cells.
- **No `stamp`, no production edit, no Git/jj mutation.** Only read-only
  `git log`, `git show`, `git diff --stat` and `git status`.
- **No check of the other 24 knowledge entries** beyond the two sibling errata
  and `claim-ledger.md` §Bounds used as precedent. No fleet `MANIFEST.json`, no
  sibling-lane file, no fleet root write.
- **No re-measurement of 333/41/29/14 lines.** Those are taken from the
  committed `corpus/drift-baseline.tsv` cells (rows 1, 7, 3, 8), not from the
  host files.
- **No tool install or upgrade** (none was needed).

## 8. Advice for L1 (not applied; production edits are L1's)

1. **Append a round-27 historical-source erratum** to
   `corpus/knowledge/credential-isolation.md`, modelled on
   `janitor-env-contract.md:92-122`: source-status historical; the 2026-09-28
   read, not current handler guarantees; substrate absent per
   `PROVINCE.md:10-15` / the 2026-10-15 probe; no current hash, line count, byte
   size, env or endpoint behavior claimed; re-verification requires restored,
   authorized reads. Qualify the source basis (L3–5), the auth/XDG/ranges
   (L11–26), the model overlay (L31–37), the agent config/tool (L42–53), and the
   steps-cap section (L64–70). Preserve every number with its date. This
   satisfies QM1/QM26 without inventing a binding. An edit changes the **tuple**
   of the existing stamp row (`corpus/stamps.tsv:34`: sha, lines, bytes), so it
   must be re-stamped and the old/new tuple journalled (QM14); `R12-03`'s
   *membership* count is unchanged by editing an already-stamped path, so do not
   invent a row-count movement.
2. **Do not add `KN-CRED-VARS` or `KN-CRED-BYTES`.** There is no lane-local
   live source, and the tempting `rows:corpus/drift-symbols.tsv = 20` is a QM18
   false admit. If the substrate is restored and a consented host row prints the
   counts, add `expect:` bindings then, with the old/new migration journal
   (`QM14`).
3. **For `14 lines` and `steps: 4`, prefer the erratum over a binding.** Both
   files are under `$HOME/.config/opencode`, whose owner is unresolved
   (`corpus/adjacency.tsv:81`). If a binding is required, first add a non-host
   ledger row that prints the `drift-baseline`/`drift-symbols` cell and whose
   note says it is a committed baseline value, not a host read; then bind with
   `ledger:`. Never bind through `rows:` (row count, not cell) or `R16-05`
   (a different 4).
4. **Keep the round-27 correction of the 120–122 pointer**
   (`corpus/lessons/round-27.md:66`) and the append-only round-25 lesson
   untouched. If a lesson errata line is added, state that the pointer was
   non-resolving, name the real numbers (L18/L31/L44), and do not present the
   entry's host facts as current.

## 9. Receipts (read-only)

```text
wc -lc corpus/knowledge/credential-isolation.md
  78 3986 corpus/knowledge/credential-isolation.md
sha256sum corpus/knowledge/credential-isolation.md
  03570c6578e3c9232e0babc23f3c249347502526cdddfa9e612fc3f126e113b3
git show 0a47dd18…:corpus/knowledge/credential-isolation.md | wc -lc
  78 3986
git show 0a47dd18…:corpus/stamps.tsv | grep credential-isolation
  34  corpus/knowledge/credential-isolation.md  03570c65…  78  3986
git show 0a47dd18…:corpus/self-counts.tsv | grep -c credential-isolation
  0
grep -c credential-isolation corpus/self-counts.tsv        # integration worktree
  0
git log --oneline --follow -- corpus/knowledge/credential-isolation.md
  2486643 round-14: freshness axis-move …
  e64e81b round-9: …
  51c9d30 round-7
  9b3e49f round-2: …
git diff --stat 2486643 0a47dd18… -- corpus/knowledge/credential-isolation.md
  (empty)
git show 4587c61a…:corpus/knowledge/credential-isolation.md | sha256sum
  03570c6578e3c9232e0babc23f3c249347502526cdddfa9e612fc3f126e113b3  -
grep -cv '^#' corpus/drift-baseline.tsv   -> 15 data rows
grep -cv '^#' corpus/drift-symbols.tsv    -> 20 data rows
```

`git status --porcelain` at read time lists L1's round-27 integration edits
(`LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SKILL.md`, `corpus/QUALITY.md`,
`corpus/README.md`, `corpus/SOURCES.md`, `corpus/claim-ledger.tsv`,
`corpus/knowledge/claim-ledger.md`, `corpus/knowledge/op-ref-consumption.md`,
`corpus/knowledge/surface-census.md`, `corpus/release-clock.py`,
`corpus/self-counts.tsv`, `corpus/source-fetches.tsv`, `corpus/stamps.tsv`,
plus the untracked round-27 wave/lesson/plan and `corpus/__pycache__/`).
`corpus/knowledge/credential-isolation.md` is **not** in that list: this
report's target is BASE-identical.

No claim in this report is a PASS for the entry's host facts. The entry has no
lane-local number to bind; its missing historical marker is the actionable
freshness item.
