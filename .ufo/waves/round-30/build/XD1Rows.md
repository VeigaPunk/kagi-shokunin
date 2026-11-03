# XD1Rows — round-30 C1 pre-integration: ledger row measurement and migration draft

Seat: XD1Rows (executor, leaf). Lane: `kagi-shokunin`. Tree measured:
`b7482b4acc42413fbb3d49ab6e4f811fb18e9f0c` (frozen BASE `f67232c` + the plan commit).
All numbers below were produced by this seat's own runs; nothing was copied from a plan,
a lesson, or a sibling report. Values are **PROVISIONAL**: they move again when C2 (EOL
repair + re-stamp) and C3 (8 registry rows, 3 knowledge files) land.

## Method

Each of the 12 rows was read from `corpus/claim-ledger.tsv` (the file is CRLF today; only the
terminal `\r` of the *note* field is affected, so all five structural fields parse correctly)
and executed with the gate's own row semantics — `cwd=<tree root>`,
`timeout -k 5 <timeout> bash -o pipefail -c "<command>" 2>&1`, pass requires exit equality
**and** the expectation ERE matching the last non-empty line (`corpus/claim-ledger.sh:595-620`).
The replication was then cross-checked by running the gate itself over an unmodified 12-row
extract (`.ufo/waves/round-30/final/c1/_gate-subset-original-rows.txt`) and over the drafted
migration file (`.ufo/waves/round-30/final/c1/_draft-verify.txt`). Both agree with the
per-row runs line for line.

No file outside `.ufo/waves/round-30/final/c1/` was written. `git status` before/after is
identical apart from the wave's own untracked files. No clone, no worktree, no lane git
mutation, no install (no pacman/uv/npx transaction at all).

## Result

| Row | Pin (old) | Live at `b7482b4` | Drafted new | Delta kind |
|---|---|---|---|---|
| R12-03 | `91` | `94` | `^94$` | count |
| R13-01 | `34` | `35` | `^35$` | count |
| R14-01 | `entries=25 row_linked=22` | `entries=26 row_linked=23` | full verdict line | count (2 cells); line also carries an unpinned trailing field |
| R21-02 | `rows=51 A=49 mined=47 entries_sourced=4 captures=51` | `rows=52 A=50 mined=48 entries_sourced=5 captures=52` | full verdict line | count (5 cells, `B`/`C`/`queued`/`rejected`/`legacy` unchanged) |
| R21-04 | `65` | `67` | `^67$` | count |
| R22-03 | `added=28` | `added=31` | full verdict line | count |
| R24-05 | `count=91 sha256=14663dcd…` | `count=94 sha256=94df9364…` | full identity line | count + digest |
| R24-06 | `count=34 sha256=567453c9…` | `count=35 sha256=92016a58…` | full identity line | count + digest |
| R24-14 | `count=65 sha256=f06ca9d5…` | `count=67 sha256=917ef251…` | full identity line | count + digest |
| R24-15 | `count=28 sha256=80f8f3d7…` | `count=31 sha256=b0d0f6f5…` | full identity line | count + digest |
| R29-01 | cmd `python -I -B …`; `PASS (4 cases)` | value still `PASS (4 cases)`; gate reads `POLICY reason=first-token:python` | cmd `python3 -B corpus/feed-token-agree.py --selftest`; same expect | **not a number move** — static policy; see §Flags |
| R29-02 | cmd `python -I -B …`; `AGREE (shapes=12 disagreements=0)` | value unchanged; gate reads `POLICY reason=first-token:python` | cmd `python3 -B corpus/feed-token-agree.py`; same expect | **not a number move** — same |

Exact last lines observed (stdout+stderr, last non-empty):

```
R12-03  94
R13-01  35
R14-01  DOC_AUDIT: CLEAN (entries=26 row_linked=23 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)
R21-02  SOURCES_CENSUS: CLEAN (rows=52 A=50 B=0 C=2 queued=1 mined=48 rejected=3 entries_sourced=5 legacy=21 captures=52 inrow=16 inrow_only=0 inrow_nonreproducing=12)
R21-04  67
R22-03  REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=31 invalid=0)
R24-05  ROW_IDENTITY: stamps count=94 sha256=94df9364048a72da259278023e74fe5e6658efa289e2a4dc2a3af0c6c3abc72c
R24-06  ROW_IDENTITY: scorecard-rounds count=35 sha256=92016a58b685618543b1eda6a6f0159d5a8de376e082f2a05af0ea5cf2edf89a
R24-14  ROW_IDENTITY: ledger-ids count=67 sha256=917ef251a13141cab409f36f5a601c8f0e9b1244d14344d254ae7e4390586b85
R24-15  ROW_IDENTITY: revision-added count=31 sha256=b0d0f6f582c22195d6613738db919b95938afe804884081777b59483a0eeac57
R29-01  FEED_TOKEN_AGREE_SELFTEST: PASS (4 cases)          (exit 0, but the gate refuses the row as POLICY)
R29-02  FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0) (exit 0, ditto)
```

All twelve rows exit 0. Ten fail the pin only on the stated values; two never execute under
the gate because `policy_check` refuses them statically before running.

## Why each value moved (verified against the tree, not inferred from the plan)

- **R12-03 / R24-05 / R22-03 / R24-15 (91→94, added 28→31).** `corpus/stamps.tsv` held 91
  rows at the round-28 close (`fdbe306`) and 94 at this tree; the three additions are exactly
  `corpus/feed-token-agree.py`, `corpus/knowledge/feed-token-boundaries.md`,
  `corpus/lessons/round-29.md` (path-set comparison, both revisions). `revision-audit
  --history c2cab35…` therefore reads `added=31` (28+3), and the `stamps` identity digest
  follows the sorted path set. Matches the round-29 verifier spot-check D1 (which read 94
  and added=31 at the then-tip).
- **R21-04 / R24-14 (65→67).** The ledger gained `R29-01` and `R29-02` last round and this
  membership pin was never migrated. Matches spot-check D1 (67). The 67 ids digest is the
  sorted id list, so the digest move is the two new ids only.
- **R13-01 / R24-06 (34→35).** Round 29 added its bounded-response `## Round ` heading to
  `SCORECARD.md`. Matches spot-check D1 (35).
- **R14-01 (25/22→26/23).** `corpus/knowledge/` now holds 26 entries; the new one is
  `feed-token-boundaries.md`, which carries `Reverify: R29-01, R29-02` (line 6) and is cited
  as S052's `used-by`. The row-linked count moves with it. This row is **not** one of D2's six
  named doc cells; it is the docs-audit pin itself, routed here by the round-30 plan scope.
- **R21-02 (51→52 across five counters).** S052 (RFC 4287, tier A, mined) with its capture and
  the knowledge entry that sources it: `rows`+1, `A`+1, `mined`+1, `captures`+1,
  `entries_sourced`+1. `B=0 C=2 queued=1 rejected=3 legacy=21 inrow=16 inrow_only=0
  inrow_nonreproducing=12` are unchanged.

## Flags — observations that are not a moved number

1. **R29-01 / R29-02: the plan's prescribed fix does not make the rows pass.** The plan's C1
   scope says re-host the token `python -I -B` → `python3 -I -B`. Measured, that is
   **insufficient**, on two independent grounds:
   - `PYTHON_SCRIPT_RE='^python3[[:space:]]+corpus/(feature-claims|revision-audit|closure-dispositions|rendered-text-v1|self-counts|release-clock)\.py([[:space:]]|$)'`
     (`corpus/claim-ledger.sh:263`) requires the script word **immediately** after `python3 `,
     so any leading `-I -B` (or `-B`) re-triggers `POLICY reason=python-script` — including for
     an already-registered script (`python3 -I -B corpus/revision-audit.py --selftest` →
     `POLICY reason=python-script`; `python3 corpus/revision-audit.py --selftest` → allowed).
   - `feed-token-agree.py` is **not** in that alternation, so even the flagless form
     `python3 corpus/feed-token-agree.py --selftest` still reads `POLICY reason=python-script`.
   Receipt: `_policy-matrix.txt` (4-row probe through the gate). Consequence: passing these two
   rows requires editing gate code (`PYTHON_SCRIPT_RE`, one alternation member) — a change to
   the gate's *semantics*, not to a recorded value. C1's kill rule says such a row is reported
   as not migrated and C1 is not claimed CLEAN. **Integrator decision required.** The draft
   keeps `-B` and drops `-I`: `-I` is not load-bearing (`python3` with and without `-I -B`
   gives the same exit 0 and the same verdict lines in both modes — `_feed-token-no-flags.txt`,
   measured in a `git archive` copy), while `-B` is: the live mode without it writes
   `corpus/__pycache__/release-clock.cpython-314.pyc` into the tree (selftest mode writes
   none). That path is gitignored (`.gitignore:2 __pycache__/`), so it would not dirty
   `git status`, but a ledger row should not write into the repo it audits —
   `_bytecode-attribution.txt`.
   Also note the coupling: `feed-token-boundaries.md` declares `Reverify: R29-01, R29-02`, so
   that entry's declared re-verification pointer is only executable once these two rows pass.
2. **R14-01 pins a prefix of its verdict line.** The pin stops at `unpinned=0`; the live line
   continues ` duplicate_reasons=0)`. The field is not new — it exists since round 14
   (`git log -S duplicate_reasons`) — and the prefix form would still match if the two numbers
   were right, so the failure is number-only. The draft pins the whole observed line instead of
   the prefix.
3. **R21-02 is CRLF-independent — the plan's separability claim holds.** The census reads
   `corpus/SOURCES.md` (CRLF at this tree) and exits 0 with `SOURCES_CENSUS: CLEAN (rows=52 …)`.
   So R21-02's mismatch cannot be caused by D5's byte drift.
4. **R29-01/02 values did not move at all.** The runtime values (`PASS (4 cases)`,
   `AGREE (shapes=12 disagreements=0)`) are identical under `python` and `python3`. On this
   host `/usr/bin/python` exists and is Python 3.14.8, so the declared command also exits 0 —
   the refusal is purely static policy. The "no working python3" note is a round-29 Windows-host
   fact, not a fact about this host.

## Provisionality — what the integrator must re-measure at the measured revision

These drafts are a snapshot at the plan commit. Expected movements once C2/C3 land
(marked as inference, not measurement):

| Row | Will move if | Direction |
|---|---|---|
| R12-03, R24-05 | C3 stamps 3 new knowledge files | 94 → 97 (path-set digest changes) |
| R13-01, R24-06 | round 30 adds a `## Round 30` heading | 35 → 36 |
| R14-01 | C3 admits 3 entries (each with a Reverify row) | 26/23 → 29/26 |
| R21-02 | C3 appends 8 registry rows | 52 → 60 |
| R21-04, R24-14 | new ledger rows (C2's standing EOL row `R30-01`, any C1 selftests) | 67 → 68+ |
| R22-03, R24-15 | every new stamp path since `c2cab35` shows as ADDED | 31 → ≥35 |
| R29-01/02 | only the command/policy question above | value unchanged |

Note R24-05's digest covers the **path column only** (`corpus/row-identity.sh:71-74`), so C2's
re-stamp of the three repaired files changes those rows' byte/line cells but not this digest.
The three CRLF files are stamped today (`SKILL.md` 813 lines/75510 bytes,
`corpus/SOURCES.md` 193/52215, `corpus/claim-ledger.tsv` 85/29905), so the LF repair must be
followed by `stamp` or those three rows go STALE. `claim-ledger.sh verify` reported
`stamped=94` with zero STALE/MISSING on the subset runs, i.e. the stamps currently match the
CRLF bytes.

## Cross-finding outside my twelve rows (advisory, measured)

C2's frozen counting command #2 —
`grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj . | wc -l` — prints **166** at this tree,
not `0` and not the plan's stated `3`. Breakdown measured with the same predicate:
3 production files (`corpus/claim-ledger.tsv`, `corpus/SOURCES.md`, `SKILL.md`) + **163
committed evidence files under `.ufo/`** (round-26..29 header captures, JSON receipt bodies,
node_modules fixtures — CRLF there is the captured bytes, not drift). The literal frozen
command therefore cannot reach `0` without rewriting committed capture evidence, which C2's
own kill rule forbids. Classification: **counting-population defect in the frozen counter**,
not an EOL-repair defect. If it becomes standing row `R30-01`, its command needs a population
that names the production surface (the three known files, or a `git ls-files` filter that
excludes `.ufo/`) — that is L1's call; this seat did not edit anything.

For the record, the fleet census cause is visible independently: the lane census
(`bash corpus/sources-census.sh`) exits 0 over CRLF, so E12 ×52 at the fleet parser is a
fleet-parser section-anchor effect, consistent with C2's hypothesis but not proven by me.

## C1 kill-rule computation (honest)

- Ten of twelve rows are pure value migrations and pass under the gate's own runner with the
  drafted expectations: the draft verify printed **zero** `FAIL` lines for them
  (`_draft-verify.txt`).
- Two rows (R29-01/R29-02) cannot pass without a gate-code change (script registration +
  flag tolerance), which the kill rule classes as semantics, not value. Until the integrator decides, C1 is **not**
  claimable CLEAN on the plan's prescribed delta alone.
- The `CLAIM_LEDGER: POLICY (claims=12 policy=2 stamped=94)` / exit 2 verdict in both subset
  runs is expected: the policy counter dominates. The 543 `MISSING-ID` lines in those receipts
  are an artefact of overriding `--claims` with a 12-row file (the idref audit then sees every
  other id as unregistered); they say nothing about ledger state.

## Evidence

All under `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-30/final/c1/`:

- `migrations.tsv` — 12 drafted rows, same six columns, LF, `Round 30: <old> -> <new>, <reason>`
  appended to each note.
- `<row-id>.txt` ×12 — per-row receipt: declared command/expect/exit/timeout, observed exit and
  last line, whether the pin matched, classification, drafted command/expect, and the full
  captured output. For R29-01/02 also the runtime variants and the policy matrix lines.
- `_gate-subset-original-rows.txt` — `claim-ledger.sh verify` over the twelve unmodified rows:
  `FAIL … verdict-not-final` ×10, `POLICY … first-token:python` ×2,
  `CLAIM_LEDGER: POLICY (claims=12 policy=2 stamped=94)`, exit 2.
- `_draft-verify.txt` — the same gate over `migrations.tsv`: no `FAIL` lines, `POLICY
  reason=python-script` ×2 for R29-01/02 only, exit 2.
- `_policy-matrix.txt` — the four-command policy probe proving the flags and the missing
  registration each independently cause `python-script`.
- `_feed-token-no-flags.txt` — flagless `python3` runs in a `git archive` copy, both modes,
  exit 0 with identical verdicts.
- `_bytecode-attribution.txt` — selftest writes no `__pycache__`; the live mode does
  (`corpus/__pycache__/release-clock.cpython-314.pyc`), and `.gitignore:2` covers it. This is
  why the draft keeps `-B`.

Scratch drivers (ephemeral, `/fast/scratch/hyaku/kagi-r30/XD1Rows/`): `run-rows.py`,
`gen-drafts.py`, `rows12.tsv`, `results.json`, `raw-*.txt`; the temporary `git archive` copy
(`tree/`) was removed after measurement.

## Tooling

Nothing installed or upgraded. No pacman transaction was attempted (host-wide pause respected);
no uv/npx/official-binary install was needed. `python3` 3.14.8, `bash`, `grep`, `sha256sum`,
`git` (read-only) sufficed.

## Risks / blockers

- **Blocker (decision, not information):** R29-01/R29-02 cannot pass by value migration. Passing
  needs `feed-token-agree` registered in `PYTHON_SCRIPT_RE` **and** that pattern to admit leading
  flags (both are gate code). If the integrator declines, C1 stays honestly not-CLEAN and both
  rows keep reading `POLICY`.
- **Drift risk:** the four count rows and four identity rows reread committed bookkeeping that
  every subsequent commit moves; the drafts are only valid at the revision they were measured.
- **Not touched, by scope:** the six D2 doc cells, the D3/D4 lesson records, `.gitattributes`,
  and every production file — all belong to other seats / the L1.
