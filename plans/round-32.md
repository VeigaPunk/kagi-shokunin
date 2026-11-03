# Round 32 — frozen claims contract (kagi, attempt 1)

Frozen BASE: `32c35fe5ed44f2017d6a662c7fd13f7e63a7ce9b` (round-31 verifier spot-check, lane `master`).
Frozen before any round-32 data: this file is committed alone, first, under `round-32: plan + frozen claims`.
Any later change to a predicate, counter, kill rule or target is a new lane commit that names this file's
commit and is not a re-freeze. Lane identity: `kagi-shokunin <kagi@shokunin.local>`.

## Scope read from the round-31 verifier spot-check (`corpus/lessons/round-31-verifier-spotcheck.md`)

Routed to this round by the non-author closure: R1 (PROVINCE.md frontier bullet still lists core themes),
R2 (round-31 late-seat evidence uncommitted), R3 (lesson count precision, by corrigendum), R4 (Mistakes
table lacks M31-6, by corrigendum), R5 (calibration 9 beside a non-clean row), R6 (README frontier tombstones).
Plus the BASE `citations` gate reading `BROKEN (unresolved=2)` on 2026-11-03 (`claim-ledger.sh citations`).

## Claims (2; distinct axes; both on owned, tied-lowest axes at 9)

### C1 — calibration: self-description mismatches counted and closed

Declared self-assessment versus observed repo state. Counter: `bash corpus/self-description-sweep.sh`
(new, bash, committed in this round; its exact checks are the list below). Predicate, identical in the
counter's code, this plan and the receipt label:

> SELF_DESCRIPTION: CLEAN n=0 — the sum of checks SD1–SD6 is zero at the measured revision.

| check | counts | BASE expected (before any round-32 edit) |
|---|---|---|
| SD1 | PROVINCE.md lines that name a theme in a `Frontier` bullet while a `Core` bullet in the same file names the same theme; themes (case-insensitive ERE): `OIDC workload-federation`, `secret[- ]scanning` | 2 (line 90 names both) |
| SD2 | corpus/README.md lines inside `## Frontier` containing `moved to core` | 2 (lines 117, 118) |
| SD3 | SHONEN.md evidence tokens of the form `corpus/…`, `LOG.md`, `SKILL.md`, `PROVINCE.md` whose file does not exist | 0 (observed; a 0 is a valid BASE) |
| SD4 | distinct `M31-n` ids named anywhere in corpus/lessons/round-31.md with no row `^\| M31-n ` in that file | 1 (M31-6) |
| SD5 | red ids named in the SCORECARD `lane-status:` line (`R25-02,R29-01,R29-02`) that are absent from the latest `calibration` row of the latest `## Round` section | 3 at BASE |
| SD6 | `UNRESOLVED` lines printed by `bash corpus/claim-ledger.sh citations` | 2 (observed) |

BASE sum = 2+2+0+1+3+2 = **10** (to be measured by the sweep itself; the sum is the counted number).

Target: n = 0 after the round's landed edits. Kill rule: any SD check nonzero at the measured revision
→ C1 not admitted (reported as a partial move, never re-scoped). Do-nothing control: the BASE sweep
output itself (n > 0 with no edits) — the claim cannot be met by leaving the tree alone. Fix-pinning:
each SD check gets a planted-mismatch fixture in the sweep selftest that must make it exit 1 with that
check named; a fixture that stays clean is a defect.

The mistake this claim captures is M32-1 (below). Named ceiling: SD5 counts naming, not the score's
honesty; the score remains author-assigned. SD3 covers path existence only, not the claims the lines cite.

### C2 — freshness: byte-evidence version pin re-verified on the installed op

Installed CLI: `op --version` → `2.41.1` (observed 2026-11-03, read-only). The byte contract in
`corpus/knowledge/op-ref-consumption.md` §11 was measured on op 2.41.0 (round 21). Counter, predicate
identical in code, plan and receipt:

> BYTE_PIN: CURRENT — `op --version` (its first field, V) appears as `` op `V` `` in the §11 range
> (from the `## 11.` heading to the next `## ` heading, including `###` subsections) AND
> `bash corpus/op-ref-probe.sh --dotenv-bytes` exits 0 with last line `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`.

Counting commands (run from the lane root):

    V=$(op --version | awk '{print $1}')
    awk '/^## 11\./{f=1;next} /^## /{f=0} f' corpus/knowledge/op-ref-consumption.md | grep -c "op \`$V\`"
    bash corpus/op-ref-probe.sh --dotenv-bytes; echo "exit=$?"

BASE: the first command prints `0` (2.41.1 not in §11) and the probe's exit/last line is the
measurement receipt (expected CLEAN on 2.41.1; a DRIFT or SETUP verdict is an honest finding and blocks
C2). Target: first command ≥ 1 and probe `exit=0` CLEAN at the measured revision.

Kill rule: a non-CLEAN probe on 2.41.1 → C2 is reported as harmed/unprovable with the output; the
§11 text is not rewritten to hide it. Do-nothing control: BASE (count 0) — C2 cannot be met by leaving
the entry alone. Historical 2.41.0 text is kept verbatim (append-only); the new measurement is a new
`### 11.1` subsection. Bound: a six-class fixture check on the installed CLI; it shows representation
fidelity for these classes only, and says nothing about ref-resolved values, item reads or the absent handler.

Sourced claim: C2 rests on a new `corpus/SOURCES.md` row (**S072**, 1Password CLI release history
entry for 2.41.1, opened in this round) cited by the `### 11.1` subsection. The row's Gate block records
the URL, access date (2026-11-03) and a ≤25-word located quote.

## Frontier step (`corpus/SOURCES.md` contract v1)

- Census before: `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` →
  exit 0, rows = 71 (`grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md`).
- Census after: exit 0, rows = 72 (S072 only). Registry `status` and `used-by` edits: none expected; any edit logged old→new in the lesson.
- Mistake mined: **M32-1** — class: doc self-description outlived a state change (frontier bullets and a
  tombstone kept after two themes moved to core; a stale citation; a lesson table missing a row named in
  its own text). Evidence: `corpus/lessons/round-31-verifier-spotcheck.md` §7 R1, R4, R6; `citations` BASE
  output (SD6). Captured-by: `none` (no gate compared frontier-vs-core, mistake-table-vs-corrigenda, or
  red-set-vs-calibration cells). Fix: `corpus/self-description-sweep.sh` SD1–SD6, with planted-mismatch
  selftest fixtures that each fail red before the fix (the fix is shown able to fail).
- Sourced claim: C2 (S072).
- Considerthese: `considerthese/2026-10-26.md` proposal **4** (a `considerthese/BACKLOG.md` status table)
  is mined this round and rejected: the lane status already lives in the `SCORECARD.md` `lane-status:` line
  adopted in round 31 from proposal 2; `considerthese/` is operator input and is never edited here. Flip
  condition: a second lane-status surface appears that the SCORECARD line cannot carry.
- Assimilation: none this round. Candidate `merge/kagi/` theme NIST SP 800-57 family status (entries
  `nist-key-management-family-status.md`, `nist-key-management-parts-withdrawal.md`) is deferred to the next
  round: its entries need in-round re-grounding that the two-claim cap cannot absorb with the routed fixes.

## Routed items handled (not claims)

- R1 — remove the two core-held themes from PROVINCE.md line 90's frontier list (move record stays in the Core bullets). Measured by SD1.
- R2 — the uncommitted round-31 late-seat evidence (`.ufo/waves/round-31/build/OidcEntry2.md`, `OidcEntry2-receipts.txt`, `OidcEntry2-report.md`, `build-results.json`) is committed under the round-32 entry, named in the report.
- R3 — corrigendum in `corpus/lessons/round-31.md`: the S063 `Audience` occurrence count is two lines (343 response element, 593 example response). Appended, not rewritten.
- R4 — corrigendum adds the `M31-6` row to the Mistakes table (SD4 measures it).
- R5 — SCORECARD round-32 calibration row names R25-02, R29-01, R29-02 and states the score ceiling (SD5). The 9 is kept with the reason stated; the outside verdict on R25-02 remains operator-owned.
- R6 — remove the two tombstones from corpus/README.md `## Frontier` (SD2).

## Operator-owned (not lane work this round)

R25-02, R29-01, R29-02 remain red (the `PYTHON_SCRIPT_RE` registration is a gate-policy change). Recorded
in the L0 channel, not fixed here. The considerthese proposal 1 (repair-only release path under a HOLD) is
policy and stays with the operator.

## Round shape

One v1 wave `kagi-r32-build` under `ufo-wave-policy.json` (band 8–16): 13 seats — 2 scout (m_antigravity),
3 executor, 3 scribe, 1 connector, 2 reviewer, 1 critic, 1 mutation-tester (m_flash / m_zfl per the run-15
map). Attack seats: reviewer 2 + critic 1 + mutation-tester 1 = 4/13 = 31 % (≥ 25 %); connectors 1 (≤ 2).
Planner seat held by the L1. No residual call. No labrat seat (the validator refuses `labrat`).
