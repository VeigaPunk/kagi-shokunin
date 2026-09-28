# Claim ledger, revision stamps, citation durability

Source basis: written 2026-09-28 (round 11) from the shipped gate itself —
`corpus/claim-ledger.sh` (436 lines at the frozen wave revision, sha256
`d63c60b0821b5388…`; the shipped revision is stamped in `corpus/stamps.tsv`),
`corpus/claim-ledger.tsv` (9 rows), and the runs quoted below. Nothing here is
copied from a draft: every verdict string in this entry was produced by a
command in the round-11 evidence set.

## Why this gate exists (the measured calibration failure)

Calibration was the lane's lowest cell after round 10. Three facts set the
score, each checkable against the repo, not felt:

- The round-10 *report* made 62 claims that were adjudicated **by hand** by one
  reviewer lane (49 VERIFIED / 9 STALE / 4 UNCHECKABLE) because no claim carried
  a command. A claim that carries no command cannot be re-checked by the next
  reader at a fixed cost.
- Two committed citations named session-scoped scratch: the scratch URI
  `local://round-10/connector.md` at `SCORECARD.md:54`, and a second scratch
  scratch URI `local://round-10/critic.md` at `corpus/lessons/round-10.md:50`. Neither
  resolves in a fresh session; the protocol lane logged the same class for
  another repo (`.ufo/reports/round-10/protocol.md` D-19, OPEN, 9 occurrences).
- The scorecard cells were self-scored. `AXES.md` asks the score to be "the
  strength of a *verifiable* claim about this repo" — with prose pointers, the
  reader re-derives the claim instead of re-running it.

The gate makes the three classes mechanical: a **revision** is a hash row, a
**claim** is a command row with a verdict, a **citation** is a resolver result.

## Class 1 — revision stamps (`corpus/stamps.tsv`)

```
path <TAB> sha256 <TAB> lines <TAB> bytes
```

- One row per artifact the round cites. `lines` is `wc -l` (a file without a
  trailing newline counts one less — the same measurement is used when writing
  and when verifying, so the comparison is consistent; it is a *line-count*
  assertion, not a byte assertion, though sha256 covers bytes too).
- `verify` recomputes sha256 + lines and prints `STALE <path> sha=<old12>-><new12>`
  or `MISSING <path>` (or `NOT-A-FILE` for a symlink/non-regular file) — one line
  per drifted artifact, exit 1; `CLAIM_LEDGER: CLEAN (claims=N stamped=M)` when
  both classes pass.
- Regenerating is `stamp PATH... [--out F]` — a reviewed commit. There is no
  auto-re-pin: a drifted stamp is a question ("was this edit intended?"), and
  the default answer must be visible in the report, not silently repaired.
- Refusals: absolute path args, whitespace/TAB in a path, the output file
  itself, missing files, non-regular files. `--out` is not constrained to the
  repo (a wave-input stamp may be written to scratch); the *committed* default
  is `corpus/stamps.tsv`.

Why stamps and not "git is enough": a reviewer must be able to state the
revision it read. `git` gives that only if the artifact is committed; the
stamp makes it answerable while the round is still in flight (the L2 wave is
dispatched against a stamped revision, and the round report cites the hash
prefix). Round 10's loss was exactly this: the critic read an in-flight
mid-edit revision and four of its clauses described files that never shipped.

## Class 2 — claims (`corpus/claim-ledger.tsv`)

```
id <TAB> command <TAB> expect <TAB> exit <TAB> timeout <TAB> note
```

A claim passes **only when both hold**:

1. the command's exit code equals `exit` (exact integer; `R11-06` carries
   `1` because the recorded baseline of the transcript gate *is* a firing
   gate); and
2. `expect` (an ERE) matches the **last non-empty line** of combined
   stdout+stderr.

The last-line half exists because a verdict is a summary line by construction:
a command that prints `SURFACE_CENSUS: CLEAN` at minute one and dies later
still ends with its own error or progress line, so the token alone cannot pass.
`reason=verdict-not-final` is the verdict for that class, and selftest case 16
pins it with a fixture that prints the expected token then a trailer.

Per-row verdicts: nothing on success (`OK` is silence), else
`FAIL <id> reason=verdict-not-final|exit-mismatch|timeout exit=<rc> [want=<n>]`,
or `POLICY <id> reason=first-token:<w>|metachar|backslash|empty-quotes|inline-shell|denied-verb:<v>`.
Exit codes: 0 clean · 1 any FAIL/STALE/MISSING · 2 any POLICY/malformed
row/missing file. The gate never echoes a claim's output (that output can
contain anything); it prints only id, reason, exit code and timeout.

Timeouts: each row declares its own bound (300 s for the gates, 120 s for
drift); the runner adds `timeout -k 5`, so a hung claim is killed at
`tmo`+5 s and reported `reason=timeout` with rc 124 (TERM) or 137 (KILL).

The shipped rows (round 11) verify the three sibling gates end-to-end:
`surface-census.sh` verify/`--verbs`/`--selftest`, `drift-pins.sh`
verify/`--selftest`, `transcript-scan.sh` baseline/`--selftest`, plus this
gate's own `citations` and `--selftest` modes. A future claim about a knowledge
entry (a sqlite row floor, a JSON key set) is a row here — the ledger is the
place claims go to be re-runnable.

## Class 3 — citation durability (`citations`)

Checked classes, by token shape (a token is the first word inside a backtick
span, after stripping `./`, trailing `,.:;` and line refs `:N`, `:N-M`,
`:N,:M,…`, `:N-M,:K`):

| Shape | Resolves against | Example |
|---|---|---|
| `corpus/…`, root docs (`SKILL.md` …) | `$ROOT/…` | `corpus/knowledge/drift-gate.md:12-20` |
| `knowledge/…`, `lessons/…` | `$ROOT/corpus/…` (the two corpus shorthands) | `lessons/round-9.md` |
| `<lane>-shokunin/…` | `$ROOT/../…` (sibling lane repo) | `kotoba-shokunin/corpus/knowledge/alwayson-checklist-round7.md:25-33` |
| `ufo/…`, `.ufo/…` | `$ROOT/../.ufo/…` (main-repo tree) | `.ufo/reports/round-10/protocol.md` |
| `{a,b}` brace set | every alternative must resolve | `lessons/round-{4,5}.md` |

Anything else is a *reference*, not a path, and is not checked by rule: bare
filenames (`PROTOCOL.md`, `janitor.md`), host paths and fragments
(`~/.config/…`, `xdg-data/…`, `usr/bin/op`), API routes (`v1/models`,
`session/{id}/shell`), `$VAR/…` templates. No rule can anchor those without a
host, and the corpus convention is a full path at first mention.

A token that fails to resolve, and any session-scoped scratch URI — `local://`,
`artifact://` / `agent://` / `proc://` (all scratch) — fails the run as
`UNRESOLVED` / `EPHEMERAL` — **unless the citing line labels it** with one of the markers `scratch`, `ephemeral`,
`relocat`, `formerly`, `no longer`, `removed`, `renamed`, `historical`. A
labelled token prints a `LABELED <doc>:<line> <token> (session URI|unresolved, labelled on its line)` line and counts into `labeled=`. The line is the audit path: `labeled` is a count of *tolerated* tokens, not of defects.

The marker rule is the honest half: dead citations happen (a file is moved,
a scratch artifact is not retained), and the rule is not "no dead citations
ever" but "**a dead citation must be labelled dead where it is cited**". The
`labeled=1` residual in the round-11 baseline is real: the round-5 aggregator
lesson cites the **relocated** `.ufo/reports/round-2/AGGREGATE.md` on a line
that already says so — labelled, resolved, kept.

Both counter kinds mean the same thing mechanically, which is why they are one
class: the reader's question is "can I open this?".

## Round-11 before → after (same defects, measured both ways)

| Scan | Result |
|---|---|
| gate v1 rule set, pre-fix docs | `CITATION_GATE: BROKEN (cites=268 docs=37 unresolved=3 ephemeral=2)` — v1 also treated bare names (`README.md`, `AGENTS.md.bak-20260908`) as paths |
| gate v2 (class-aware, pre-fix docs) | `BROKEN (cites=374 docs=37 unresolved=2 ephemeral=2 labeled=1)` — the two remaining *doc* defects plus one gate bug (line-ref stripper) |
| after the doc fixes + gate fixes, end of round | `CITATION_GATE: CLEAN (cites≈500 docs=39 unresolved=0 ephemeral=0 labeled=13)` — `cites`/`docs`/`labeled` move with **every** edit (this entry and the round-11 lesson are themselves scanned), so the shipped figure is quoted in the round report next to the revision stamp it was measured at; the ledger row asserts only the verdict + the non-zero shape of the counts |

Defects fixed: `SCORECARD.md:54` and `corpus/lessons/round-10.md:50` (dead
scratch URIs → durable pointers, with the class named in place);
`corpus/README.md:61` (kotoba's file cited as if local → `kotoba-shokunin/…`,
which the sibling class now resolves); `corpus/README.md:157` (bare host file
`AGENTS.md.bak-20260908` → `$HOME/.agents/…`). The gate bug: the line-ref
stripper's greedy `.*` left the separator behind (`…:136,:164,`), fixed by
dropping the trailing `[,:]` after each match — found by real data
(`corpus/lessons/round-6-aggregator-audit.md:110`), pinned by selftest case 21.

**Counting a gate that reads its own docs.** `cites`/`docs`/`labeled` change
whenever any scanned doc changes — including the LOG entry that quotes them. So
this corpus quotes those figures with `≈` and lets the *verdict* and the count
*shape* (non-zero, `unresolved=0`, `ephemeral=0`) be the claims; the exact tuple
is measured once, last, and quoted in the round report (which is outside the
scanned set). Measured this way in round 11: `CITATION_GATE: CLEAN (cites=515
docs=39 unresolved=0 ephemeral=0 labeled=13)`.

## Reproduction

```
bash corpus/claim-ledger.sh verify      # stamps + claims     → CLAIM_LEDGER: CLEAN (claims=11 stamped=28)
bash corpus/claim-ledger.sh citations   # citation durability → CITATION_GATE: CLEAN (cites≈505 docs=39 …) at the end-of-round revision
bash corpus/claim-ledger.sh --selftest  # 39 scratch cases    → SELFTEST: PASS (39 cases)
bash corpus/claim-ledger.sh stamp corpus/claim-ledger.sh …    # re-pin (reviewed commit)
```

## Bounds (what this gate cannot see)

1. **Claims inherit the runner's environment.** A claim can be green on this
   host and red on another (paths, ports, host state). `R11-06` is the sharp
   case: the transcript baseline is host state, and a legitimate new session
   would flip it — the note says to re-baseline, not to trust it as a
   regression.
2. **The deny-list is a text guard, not a sandbox.** It refuses a closed list
   of verbs and every shell metacharacter; a future row is reviewed by a human,
   and review is the real control. (The round-11 sentinel and labrat lanes
   attacked this surface; see the lesson.)
3. **The last-line rule trusts the *gate's own* summary line.** If a sibling
   gate's summary degrades while still printing the expected token (e.g. a
   `CLEAN` line over zero probes), the claim is green. The countermeasure is
   the sibling gate's own selftest, not this one.
4. **A stamp is a point check.** Restoring a file to the stamped bytes (after a
   real change) re-verifies; the stamp says "this is the revision I read", not
   "this file never changed".
5. **No mode in a stamp row.** A mode-only change under an unchanged hash is
   invisible here; `surface-census.tsv` owns modes for the host surfaces.
6. **Bare names are unchecked by rule** (see above) — a stale `PROTOCOL.md`
   reference is invisible to this gate by construction, stated here so the
   bound is not discovered later as a surprise.
7. **Markdown only.** The shell scripts' own citations (header comments, `# ---`
   sections) are not scanned; scripts cite via variables and are covered by the
   census/drift gates.
8. **One root.** `--root` defaults to this repo; the sibling/`.ufo` classes
   assume the checkout layout (`…/shokunin/<lane>-shokunin`, `…/shokunin/.ufo`)
   — a relocated checkout turns those rows UNRESOLVED, which is a real signal
   about the reader's tree, not about the cited file.
9. **Claims are not scheduled.** Nothing runs `verify` on a timer; the round
   discipline is "run it before you cite it".
10. **`POLICY` rows are not run at all** — a policy refusal is a failure of the
    ledger, not of the claim (exit 2, distinct from FAIL's exit 1).
11. **`bash <reviewed script>` is still arbitrary execution.** The allowlist
    (five commands) and the refusal of `bash -c`, backslashes, empty quote pairs
    and denied verbs shrink the surface that the round-11 sentinel and executor
    probed; they do not close it. The control is that the ledger is a reviewed,
    committed file.
12. **`--out` can overwrite a regular file** and an `expect`-crafted row is a
    1-bit oracle over anything the runner can read (sentinel F6/F8). Both are
    operator/review surfaces, not sandbox properties.
13. **The selftest cannot prove its own honesty.** It exercises the shipped code
    paths on scratch data; the *default wiring* is pinned by the claim row that
    runs the real docs (`R11-08`) and by the case count (`R11-09`), and a liar
    stub that prints `SELFTEST: PASS` is caught by the reviewer lane reading the
    `FAIL-case` lines it printed alongside (critic CE4).
14. **The marker rule is line-granular.** A line that says "removed" for one
    reason also excuses a different dead token on the same line; every tolerated
    token is printed as `LABELED`, which is the audit path (critic CE3).
15. **A citation of a generated file is order-dependent.** `corpus/stamps.tsv`
    is cited in this corpus and does not exist before the first `stamp` — the
    citation is `UNRESOLVED` until then (reviewer addendum, observed live).

## Falsifiers (each must break something, or the claim behind it is wrong)

```
bash -c 'cp corpus/claim-ledger.sh /tmp/g.sh; sed -i "s/CLEAN/STILL_CLEAN/" /tmp/g.sh'   # selftest must notice? (no — it asserts its own strings; check)
bash -c 'printf "x\n" >> corpus/claim-ledger.tsv; bash corpus/claim-ledger.sh verify'    # malformed row → POLICY exit 2
bash -c 'cp corpus/stamps.tsv /tmp/s.tsv; printf "\n" >> corpus/claim-ledger.sh'        # STALE + exit 1 on the shipped stamp
bash -c 'bash corpus/claim-ledger.sh stamp --out corpus/stamps.tsv corpus/stamps.tsv'    # refused: output file itself
bash -c 'bash corpus/claim-ledger.sh citations --root /tmp'                              # die: doc not found (setup error, exit 2)
bash -c 'bash corpus/claim-ledger.sh verify --stamps /dev/null'                          # EMPTY stamp set → is that CLEAN? (size bound)
bash -c 'bash corpus/claim-ledger.sh verify --claims <(printf "c1\tbash x\tY\t0\t5\n")'  # process substitution as a claims file
```
