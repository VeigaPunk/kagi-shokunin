# Round 11 lesson — a claim without a command is not a claim

Axis moved: **calibration 7 → 8**. Round 10's own plan named the target: the
round's 62 report claims were adjudicated by hand (49 VERIFIED / 9 STALE /
4 UNCHECKABLE) because none carried a command, and the L2 critic burned a lane
reviewing an in-flight revision. Both are calibration failures: a claim nobody
can re-run, and a revision nobody can name.

## What landed

`corpus/claim-ledger.sh` (436 lines) + `corpus/claim-ledger.tsv` (9 rows) +
`corpus/stamps.tsv` (revision stamps) + `knowledge/claim-ledger.md`.

Three classes, one gate:

- **revision** — `stamps.tsv` rows (`path sha256 lines bytes`); `verify`
  recomputes and prints `STALE`/`MISSING`/`NOT-A-FILE`. Regeneration is a
  reviewed `stamp` commit; there is deliberately no auto-re-pin.
- **claim** — `claim-ledger.tsv` rows (`id command expect exit timeout note`);
  a row passes only when the exit code matches **and** the expected ERE matches
  the **last non-empty output line**.
- **citation** — committed Markdown must cite durable evidence; five checked
  classes by shape, brace sets expanded, and stale tokens allowed only when the
  citing line labels them (`scratch|ephemeral|relocat|formerly|no longer|
  removed|renamed|historical`).

Measured at the shipped revision (2026-09-28):

```
bash corpus/claim-ledger.sh verify     → CLAIM_LEDGER: CLEAN (claims=11 stamped=28)   exit 0
bash corpus/claim-ledger.sh citations  → CITATION_GATE: CLEAN (cites≈505 docs=39 unresolved=0 ephemeral=0 labeled=13)  exit 0
bash corpus/claim-ledger.sh --selftest → SELFTEST: PASS (39 cases)                   exit 0
```

Sibling gates unchanged: `DRIFT_PINS: CLEAN (files=15 symbols=19)`,
`SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2
skipped=0)`, `TRANSCRIPT_SCAN: HITS=2` (exit 1 by design — the recorded
baseline is a firing gate).

## The citation gate found real rot on first contact

Round 11's plan was written before this scan; the scan found four defects, all
in **committed** docs, all fixed in place:

1. `SCORECARD.md:54` cited `local://round-10/connector.md` — a scratch URI.
2. `corpus/lessons/round-10.md:50` cited a scratch URI at
   `local://round-10/critic.md` (scratch) — same class, and the one that
   *matters*:
   round 10's lesson is exactly the place a future reader goes to learn what
   the critic said, and the pointer resolved for nobody.
3. `corpus/README.md:61` cited kotoba's file as `corpus/knowledge/…` — a
   sibling repo's path wearing this repo's anchor.
4. `corpus/README.md:157` cited a host file bare (`AGENTS.md.bak-20260908`);
   now `$HOME/.agents/AGENTS.md.bak-20260908`.

The class is not kagi's alone: the protocol lane logged 9 instances in one
sibling corpus (`.ufo/reports/round-10/protocol.md` D-19, still OPEN). kagi
fixed its own four and **reports** the fleet-wide shape — the mechanism
(a committed doc may cite only durable evidence; a dead token must be labelled
where it is cited) is stated here, not imposed on other lanes.

Before → after, same defects counted both ways:

| Scan | Result |
|---|---|
| pre-fix docs, v1 rule set | `BROKEN (cites=268 docs=37 unresolved=3 ephemeral=2)` |
| pre-fix docs, v2 class-aware rules | `BROKEN (cites=374 docs=37 unresolved=2 ephemeral=2 labeled=1)` |
| post-fix docs + gate fixes (shipped) | `CLEAN (cites≈505 docs=39 unresolved=0 ephemeral=0 labeled=13)` — `docs` grew 37→39 because this gate's own entry and lesson are scanned, and `labeled` is 14 because the rule documentation itself contains labelled scratch tokens (each one enumerated in the L2 review) |

The residual `labeled=1` is intentional and stays: the round-5 aggregator
lesson cites the **relocated** `.ufo/reports/round-2/AGGREGATE.md` on a line
that already says so — the token is dead, the line labels it, and the reader
is not misled.

## Four gate defects, three caught before landing

The selftest did not catch them all; real runs did. Recorded because that
ordering is the lesson:

1. **`read` consumed a detail line as the summary** (verify's counters came
   from a command substitution while `verify_claims` printed FAIL lines to the
   same stream). Symptom: `line 255: exit: unbound variable` — bash evaluating
   `reason=exit-mismatch` as arithmetic. Fixed by making the counters globals
   and printing only the summary from the dispatcher. Caught by the first
   selftest run.
2. **A quiet command cannot pass a claim** (`grep -q` prints nothing, so
   "last non-empty line" is empty). That is the rule working, not a bug — the
   fixture was wrong. Recorded because it shows the rule rejects verdict-less
   commands by construction.
3. **The line-ref stripper left the separator behind** (`…SKILL.md:136,:164,`)
   — greedy `.*` includes the trailing `,` before the last `:N`. Found by real
   data (`lessons/round-6-aggregator-audit.md:110`, a four-ref citation);
   fixed by dropping the trailing `[,:]` after each match; selftest case 21 now
   pins multi-ref stripping.
4. **The stamp trap read an out-of-scope `local`** (`set -u` → `tmp: unbound
   variable` at EXIT). Found by the **first real `stamp` invocation** — the
   selftest had never exercised `stamp` at all. Fixed with a global temp +
   cleanup trap, and the selftest grew cases 22–24 (`stamp` writes, a fresh
   stamp verifies, an absolute path is refused). The general lesson: a
   subcommand that only the operator path calls is untested until a case calls
   it.

## Design calls that were not obvious

- **Last-line, not any-line.** Any-line matching lets a command print the
  expected verdict early and fail later. A verdict is a summary line by
  construction; the rule is falsifiable (selftest 16, 21) and the failure
  reason is explicit (`verdict-not-final`).
- **Exit code equality is the primary half.** The token is the human-readable
  half; the exit code is what makes `CLEAN`-with-degradation attempts visible.
- **No auto-re-pin.** `stamp` is a reviewed commit because a drifted stamp is a
  question ("intended?"), and the answer must be in the report, not in a
  silent rewrite.
- **The marker rule, not a ban.** Dead citations happen; banning them produces
  rewrites of history. Requiring the citing line to label the token keeps the
  trail honest and makes the reader's question ("can I open this?") the verdict.
- **Checked classes by shape.** Only tokens that name a file in this repo, a
  sibling lane repo, or the main `.ufo` tree are checked. Bare filenames and
  host/route fragments are references; guessing their anchor would produce
  false positives at scale (an independent census measured the skip mass —
  see the wave section).
- **The deny-list is a text guard.** Claims must be one simple command with an
  allowlisted first token and no shell metacharacters; `POLICY` refuses without
  running (exit 2, distinct from FAIL). The control is review of a committed
  file, and the gate says so in §Bounds instead of implying a sandbox.

## L2 wave (9 lanes, one batched call, frozen revision)

Dispatched against stamped revision r1
(`corpus/claim-ledger.sh` `d63c60b0…` 436 lines, ledger `3d6fe4ba…`, plus the
seven artifacts the lanes read), so every lane states the revision it read —
the round-10 loss (a critic reviewing a moving file) is mechanically excluded.
Eight of the nine lanes reported; three of them hash-verified r1 and *then*
reported which artifacts had moved mid-window, which is the mechanism working.

The wave cost me one thing immediately: **the reviewer's first pass was WRONG
about three claims** (C1 `verify` CLEAN, C2 the citation tuple, C8 stamp
coverage) — not because the mechanism lied, but because I had written those
numbers **before** the artifacts existed (no `stamps.tsv` until 19:38) and
before the docs the gate scans were finished. The scout independently
re-ran every row and saw the same thing. That is the round-9 "gate-before-cite"
lesson recurring at the *prose* level: a number written ahead of its run is a
claim with no evidence. The fix is procedural and is now in §Axis note: numbers
in docs are quoted **with the stamped revision they were measured at**, and the
final measure happens after the last edit.

### What the wave changed in the gate (each item is a counterexample I could reproduce)

| Finding (lane) | Verdict | Action |
|---|---|---|
| CE1 unanchored `expect` passes a degraded summary (`…CLEAN (pass=0 skip=10)`) (critic) | **real** | every row's `expect` anchored (`^…`), count-bearing summaries assert non-zero (`pass=[1-9]`, `assets=…`, `files=…`); the sibling gate now *fails closed* on zero passes (`SURFACE_CENSUS_VERBS: DEGRADED` + exit 1) instead of printing CLEAN |
| bytes column never compared — a tampered value re-verified CLEAN (critic) | **real** | all four stamp columns compared; `STALE … bytes=6->999`; selftest case 26 |
| citation extractor checked only the first token of a span (critic/scout) | **real** | the scan now walks **every token on the line**, with a normalizer that loops (backticks, quotes, parens, `./`, `:N`/`:N-M`/`:N,:M`, `#anchor`, `?query`, `=value`, `'s`); 153 class-shaped tokens that were invisible became checked; the whole-doc scan went 3.5 s → ~20 s |
| `{4, 5}` (space after the comma) broke brace sets (critic) | **real** | spaces inside braces are not token separators; alternatives trimmed; cases 20/24 |
| a labelled token was silent (critic) | **real** | every tolerated token now prints a `LABELED <doc>:<line> <token> (reason)` line — `labeled` is auditable, not a black box |
| `IFS=$'\t' read` collapses EMPTY fields → a row with an empty command was CLEAN (executor A15) | **real** | tab-splitting preserves empty fields (`split_tab`), field count must be 5–6 (claims) or exactly 4 (stamps), fusion/empties `die` exit 2; cases 35–36 |
| `tmo=0` disables `timeout` (planner, executor) | **real** | timeout must be a positive integer; case 33 |
| `expect` = a bare anchor (`^`) passes an empty last line (planner) | **real** | `expect` must contain a literal; and empty output is its own failure (`reason=no-output`); cases 32/37 |
| `..` traversal made the committed default root hash a private host file's digest (sentinel F3) | **real, must-fix** | `..` refused, canonical path must stay under the canonical root; sha of a private file can no longer enter a committed stamps file |
| `g''it` / `g\it` / `o"p"` word-splitting defeated the deny-list while the stand-in executed (executor A03/A04, sentinel F2) | **real** | deny words are matched on a quote-stripped copy; backslashes and empty quote pairs refused; `bash -c …` refused; `sqlite3`/`timeout` dropped from the allowlist; case 36 |
| `die` echoed a raw file line (`malformed stamps row: <content>`) (sentinel F4) | **real** | messages carry the field count, never content |
| `stamp --out` could overwrite an arbitrary file / accept a directory (sentinel F6) | **partly real** | `--out` normalizes to absolute; an existing non-regular target is refused; overwriting a regular file stays allowed — it is an operator path, documented |
| `stamp corpus/stamps.tsv` with the default `--out` bypassed the self-stamp guard (reviewer C7) | **real** | guard runs before the write and compares against the resolved output in either argument order; cases 30/31 |
| duplicate paths in one invocation inflated `stamped=` (executor) | **real** | duplicates refused |
| empty stamp set reported `CLEAN (claims=1 stamped=0)` (planner) | **real** | zero rows is a setup error (exit 2); case 39 |
| selftest cannot see the default wiring; a liar stub prints PASS (critic CE4) | **accepted, bounded** | a self-test cannot prove its own honesty; the default wiring is pinned by claim rows (`R11-08` runs the real docs) and the case count by `R11-09`. Recorded in §Bounds |
| `bash <script>` / `test` rows are arbitrary execution; `--out` is an overwrite primitive; an `expect`-crafted row is a 1-bit oracle (sentinel F1/F6/F8, executor A05/A06) | **accepted, bounded** | the ledger is a *reviewed, committed* command list, not a sandbox — stated in §Bounds and in the gate header; the mitigations chosen (narrow allowlist, no inline shell, no backslash) shrink the surface without pretending to close it |
| host-state dependence is wider than `R11-06` (scout: also 01/02/04/08) | **accepted** | §Bounds now says rows are host-state-dependent *as a class* |
| round-10's `49/9/4` adjudication counts are not falsifiable from the repo (critic CE5) | **real, not fixable this round** | named as UNCHECKABLE and recorded as the rule for round 12+: an adjudication that is not committed as rows does not enter a report |

### What the wave confirmed rather than changed

- `corpus/claim-ledger.sh` r1 hash matched at three independent lanes (connector,
  scout, sentinel) — the freeze is real, not a claim.
- POLICY never ran a refused command (reviewer C6: marker file absent).
- The last-line half of the pass rule fires independently of exit equality
  (reviewer C5).
- With erased state, the gate did what it says: a missing `stamps.tsv` is exit 2,
  a post-stamp edit is `STALE` + exit 1 — both observed by the scout within
  minutes of landing.
- Sibling mechanisms exist and overlap *without* duplicating (connector):
  kumitate's `scripts/cite-check.mjs` (citation/ref/pin re-verifier), kotoba's
  `verifiers/verify_corpus_integrity.py` + `verify_harness_claims.py`, kengaku's
  `grader.py` (evidence replay), kasegi's `ops/claim-check.mjs` (bounty package
  gates — different domain). kagi's gate defers to `PROTOCOL.md`'s evidence
  contract and fills the gap that none of those owns: a *revision-stamped,
  command-per-claim* ledger with a citation-durability verdict. The integrator
  is asked (report §Adjacency) whether these five verifiers should share a
  contract, and whether verdict-only output satisfies PROTOCOL's output
  standard.

## Clone smoke test (the committed revision, standalone)

`git clone` of the round-11 commit into `/tmp` (no sibling lane repos, no
`.ufo`):

```
bash corpus/claim-ledger.sh --selftest  → SELFTEST: PASS (39 cases)          exit 0
bash corpus/claim-ledger.sh verify      → FAIL R11-08 reason=exit-mismatch   exit 1
```

The selftest is layout-independent (scratch tree, absolute paths). `verify`
fails on exactly one row — `R11-08` (`citations`) — because the sibling
(`kotoba-shokunin/…`) and main-repo (`.ufo/…`) citations cannot resolve without
the fleet checkout. That is the documented bound (entry §Bounds item 8) doing its
job; the row's note now states the layout requirement. Worth keeping as
fail-closed: a gate that silently shrugged when its citations lost their
resolution root would be the false-clean class this round is about.

## Axis note

Calibration moved to 8, not higher: the *claims* are now machine-checkable, but
the **scores themselves are still author-assigned** — a reader can re-run every
pointer under a cell, not the number. Named ceilings: the stamp is a point
check (a restored file re-verifies); a mode-only change is invisible to a stamp;
claims encode host-state expectations (`R11-06`); nothing schedules the gate.
The next calibration move should make the *cell* falsifiable — e.g. require each
score row to name the claim ids it rests on, so a reader can re-derive the
number instead of the evidence.
