# K46ExecLedger — M46-1 fix draft: one ledger row that runs the release-clock gate's default mode

Seat: `K46ExecLedger` (executor, round 46 attempt 1). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`,
branch `master`, BASE `f5977284a8ce5bab09252be8196ee5dc18489926` (predeclaration `44808ced…`).
Scope: draft ONE `corpus/claim-ledger.tsv` row (bytes only, in the build dir — the lane's ledger was
NOT edited) plus its red witness at BASE and the evaluation path.

## Deliverables

| path | what |
|---|---|
| `.ufo/waves/round-46/build/K46ExecLedger/ledger-row.tsv` | the exact row bytes, 6 TAB fields, 1317 bytes, sha256 `7df8de37777fb88d4848b5c561e085993540b8cfeeac942c9ba61427eae2a36c`, LF only |
| `.ufo/waves/round-46/build/K46ExecLedger/red-witness.txt` | BASE red witness: commands, exit codes, last lines |
| `.ufo/waves/round-46/build/K46ExecLedger/notes.md` | how `claim-ledger.sh` evaluates a row, with line refs; consequences of appending |
| `.ufo/waves/round-46/build/K46ExecLedger/receipt-*.out` | raw gate/command receipts copied from scratch |

## The row

| field | value |
|---|---|
| id | `R46-01` (next free in the `R46-*` series; no `R46-` row exists at BASE, last row is `R38-04`) |
| command | `python3 corpus/release-clock.py` |
| expect | `^RELEASE_CLOCK: CLEAN \(on_release=29 bound=29 unbound=0 observed=29 fired=[0-9]+ derived=[0-9]+\)$` |
| exit | `0` |
| timeout | `120` (BASE run: 0.07 s) |
| note | names M46-1 (`instrument-drift`), the round-36 R25-04 migration that removed the only default-replay row, the BASE red reading, why `fired`/`derived` stay loose, why `-B` is omitted, and the two membership pins the append moves |

Placement: append after `R38-04` (the ledger is read in file order; ids need not be sorted — `R25-03`/`R25-04`
already sit out of order at lines 82-83).

`python3 -B corpus/release-clock.py` — the form the plan's C2 predicate uses — is **refused by the
ledger's own command policy** (`PYTHON_SCRIPT_RE`, `corpus/claim-ledger.sh:263`, refusal at 276-278:
`POLICY … reason=python-script`, gate exit 2). The shipped row therefore omits `-B`; the default
replay leaves no bytecode behind (`find` → 0 `__pycache__`/`*.pyc` entries after the run), so nothing
is lost. `--observe` would be refused as `network-mode` (281-283), which is correct.

## Evaluation path (no single-row mode exists)

`claim-ledger.sh` has modes `verify|citations|cells|docs|stamp|--selftest` and no `--row`/`--id`
filter (argument loop 332-353). `verify` is a fixed `verify_stamps; verify_claims; idref_audit`
(1213-1216) and refuses to run nested (375-377). The only way to make the real gate evaluate one row
is `--claims <file>` pointing at a claims file holding that row — that is what the witness does, and
it is the ledger's own code path, not a re-implementation.

Per row (`verify_claims`, 539-625): TAB split keeping empty fields (545 → `split_tab` 153-161),
field count 5-6 (546), numeric `want`/positive `tmo` (549-550), `expect` must assert a literal (553),
**policy check first for every row** (557 → `policy_check` 272-330), untagged-host refusal (562-566),
symlinked script word (569-573), host-row skip (574-577), substrate deferral (578-582), then
`timeout -k 5 "$tmo" bash -o pipefail -c "$cmd"` with cwd `$ROOT` and `2>&1` (592-595), timeout
verdict (596-599), **exit leg** (612-614), **final non-empty line must match `expect`** (616, 621-624).
The row's `^…$` anchors are what make the ERE a whole-line verdict; the ledger itself matches
unanchored.

## Retained evidence (all runs in a `git archive` copy of BASE, never the lane tree)

| # | command | rc | last output line |
|---|---|---|---|
| 1 | `python3 corpus/release-clock.py` (BASE) | **1** | `RELEASE_CLOCK: FAILED (on_release=29 bound=28 unbound=1 observed=28 fired=13 derived=15)` |
| 2 | `bash corpus/claim-ledger.sh verify --claims <one-row R46-01>` (BASE) | **1** | `FAIL R46-01 reason=exit-mismatch exit=1 want=0` then `CLAIM_LEDGER: FAIL (claims=1 failed=1 deferred=0 stamped=123 stale=0 missing=0 unresolved_ids=1254 labeled_ids=158 host_skipped=0)` |
| 3 | same, row written with `-B` | **2** | `POLICY R46-T1 reason=python-script` |
| 4 | manual replication of 592-624 | rc 1 | `verdict=FAIL reason=exit-mismatch`; `[[ $last =~ $expect ]]` → `REGEX=NO-MATCH` |
| 5 | `bash corpus/row-identity.sh stamps` (BASE) | 0 | `ROW_IDENTITY: stamps count=123 sha256=47fa2d50…` vs R24-05's expected `count=122 sha256=3586872e…` |
| 6 | `bash corpus/claim-ledger.sh verify --claims <R24-05>` (BASE) | **1** | `FAIL R24-05 reason=verdict-not-final exit=0` |

Row 2 is the acceptance reading: the row is **red at BASE on both legs** — exit mismatch fires first,
and the final line (`FAILED …`) cannot match the CLEAN ERE. Row 5 is the pattern-satisfiability check
only (a synthetic CLEAN line matches); it is not a tree reading.

## Consequences for the candidate (measured in a scratch copy of BASE)

Appending exactly these bytes to `corpus/claim-ledger.tsv`:

- `R21-04` (`grep -cE '^R[0-9]+-[0-9]+'`) 86 → **87**; must be migrated in the same candidate.
- `R24-14` (`row-identity.sh ledger-ids`) count=86 → **count=87
  sha256=e7a97e968d685a7a023ac37a66c116a02f2a6718628e2351b47df9f022e69940**.
- `corpus/stamps.tsv:5` pins `corpus/claim-ledger.tsv` (`e99dea7e… 104 49374`): `verify_stamps` will
  report it STALE until the reviewed re-stamp, and a re-stamp moves `R24-05`'s `stamps` pin too.
- `R13-02` (`^R1`) and `R18-02` (`[substrate]`) are unaffected (id starts `R4`; the note carries no
  host tag). `R25-02`'s `claims=` counts `corpus/self-counts.tsv` rows, not ledger rows
  (`corpus/self-counts.py:308,365-373`; the ledger is only an id→command lookup at 310) — not
  measured here because self-counts is host-heavy and out of this seat's scope.
- `corpus/claims-declared.sh` reads `corpus/claims-declared.tsv`, never the claim ledger, so no
  declaration is needed for the row; citing `R46-01` in the round report resolves, and leaving it
  uncited is an ORPHAN (informational).

## Risks / named defects

1. **R24-05 is already red at BASE**, independently of this row (`count=122` pinned vs `123` live).
   Any candidate `verify` will carry `failed>=1` from it unless the pin is migrated. Named, not fixed
   here (out of seat scope, and it is not C1/C2's surface).
2. `fired`/`derived` are deliberately `[0-9]+`: pinning them would make the row's verdict depend on
   whether S098's new clock lands as fired or derived, a choice C2 has not frozen. The frozen
   `observed=29` plus `CLEAN` still forces the gate's own zero-error condition.
3. The row cannot be shown **green** in this seat: no CLEAN tree exists in the lane yet. Only the
   red leg and pattern satisfiability were measured; the green leg is the candidate's C2 reading.
4. If the candidate's receipt leaves `bound != on_release` or any error row, the row fails by
   construction — that is the M46-1 property, not a defect.
5. The witness `verify` runs used `--claims` fixtures, so `stamped=123` and `unresolved_ids=…` are the
   archive's own stamp/doc set and say nothing about R46-01.

## Discipline

No lane file outside `.ufo/waves/round-46/build/K46ExecLedger*` was written. No `git add/commit/
checkout/reset/stash/pull/push`, no `jj` mutation; the lane's `git` was used read-only (`archive`,
`rev-parse`, `show`-class reads). All clones/fixtures live under
`$HYAKU_SCRATCH/kagi-r46/K46ExecLedger` (`/fast/scratch/hyaku` default). No tool installs, no host
mutation, no network fetch, no vault/op contact.

SEAT-STATUS: complete
