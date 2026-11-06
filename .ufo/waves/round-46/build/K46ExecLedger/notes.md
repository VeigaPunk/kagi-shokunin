# K46ExecLedger — how the ledger evaluates one row, and what R46-01 must satisfy

All line numbers are `corpus/claim-ledger.sh` at BASE `f5977284a8ce5bab09252be8196ee5dc18489926`
(1807 lines; `corpus/release-clock.py` is 2151 lines). Reads are from the lane tree; every run happened in a `git archive` copy of BASE at
`$HYAKU_SCRATCH/kagi-r46/K46ExecLedger/base-pristine` (default `/fast/scratch/hyaku`).

## 1. There is no `--row` / `--id` / filter mode

`claim-ledger.sh` accepts modes `verify|citations|cells|docs|stamp|--selftest` and the options
`--stamps --claims --scorecard --docs --root --out --prune --orphans --allow-host-rows`
(argument loop, lines 332-353). `verify` is a fixed sequence `verify_stamps; verify_claims;
idref_audit` (lines 1213-1216) — it always walks the whole claims file. The only way to make the
real gate evaluate ONE row is `--claims <file>` pointing at a claims file that holds that row, which
is what the red witness does. `verify` also refuses to run nested (`CLAIM_LEDGER_DEPTH>0`,
lines 375-377), so a row can never be `bash corpus/claim-ledger.sh verify`.

## 2. The per-row evaluation, in order (verify_claims, lines 539-625)

| step | code | effect on R46-01 |
|---|---|---|
| split on TAB, keep empty fields | 545 `split_tab`, 153-161 | 6 fields, no empty column |
| field count 5..6 | 546 | ok |
| `want` numeric, `tmo` positive int | 549-550 | `0`, `120` |
| `expect` must assert a literal, not only anchors | 553 | the ERE carries `RELEASE_CLOCK: CLEAN …` |
| **policy_check first, for every row** | 557 → `policy_check` 272-330 | see §3 |
| untagged-host refusal | 562-566 | command is `python3`, not a `HOST_SCRIPT_RE` bash script |
| symlinked script word | 569-573 | n/a |
| host rows skipped unless `--allow-host-rows` | 574-577 | the note carries no `[host]`/`[substrate]` |
| substrate deferral | 578-582 | n/a |
| run | 592-595: `timeout -k 5 "$tmo" bash -o pipefail -c "$cmd"`, cwd `$ROOT`, `2>&1` | rc 1 at BASE |
| timeout verdict | 596-599 (`124`/`137`) | not hit (0.07 s) |
| layout-incomplete carve-out | 604-611 | not hit |
| **exit leg** | 612-614 `rc -ne want` → `FAIL <id> reason=exit-mismatch` | **fires at BASE** |
| empty output | 617-620 | n/a |
| **final-line leg** | 616 + 621-624: last non-empty line of combined stdout+stderr must match `expect` (ERE, unanchored match, so `^…$` in the row is what anchors it) | would also fail: `FAILED` ≠ `CLEAN` |

Verdicts are printed, never the command's output (header §Secret hygiene), and the summary line is
`CLAIM_LEDGER: FAIL (claims=… failed=… …)` with exit 1 (lines 1222-1224).

## 3. Why the command is `python3 corpus/release-clock.py` and not `python3 -B …`

`ALLOWED_RE` (262) admits `python3`; `PYTHON_SCRIPT_RE` (263) is
`^python3[[:space:]]+corpus/(feature-claims|revision-audit|closure-dispositions|rendered-text-v1|self-counts|release-clock)\.py([[:space:]]|$)`
— `corpus/…` must follow `python3 ` directly. Line 276-278 refuses anything else as
`POLICY … reason=python-script`. Measured (witness §3): `python3 -B corpus/release-clock.py` →
`POLICY R46-T1 reason=python-script`, gate exit 2, row never run.

`-B` is also unnecessary: the default replay imports `corpus/rendered-text-v1.py` through
`importlib` and the run leaves no bytecode behind — `find base-pristine -name __pycache__ -o -name
'*.pyc'` → 0 entries after the run. `--observe` would be refused as `network-mode` (281-283), which
is correct: the ledger must never fetch.

## 4. The row's expected line

`^RELEASE_CLOCK: CLEAN \(on_release=29 bound=29 unbound=0 observed=29 fired=[0-9]+ derived=[0-9]+\)$`

- `print_result` (corpus/release-clock.py:715-722) emits exactly
  `RELEASE_CLOCK: <CLEAN|FAILED> (on_release=%d bound=%d unbound=%d observed=%d fired=%d derived=%d)`;
  `passed = not errors and bound == len(on_release)` (line 711), and `main` returns 0 only when
  `passed and observation_failures == 0` (2147). So CLEAN already implies zero error rows.
- `on_release=29 bound=29 unbound=0 observed=29` is C2's frozen ON29 set (plan §C2: S005-S032 and
  S098; target 29). BASE reads `on_release=29 bound=28 unbound=1 observed=28`.
- `fired`/`derived` are left as `[0-9]+` on purpose: at BASE they are `13`/`15` and the plan says
  "fired clocks stay fired", but S098's new clock may land as fired or derived, so pinning either
  number would make the row's verdict depend on a choice C2 has not frozen. `fired+derived` equals
  `observed` in the BASE reading, so the pair is already constrained by `observed=29`.

## 5. Consequences of appending the row (measured in a scratch copy of BASE, not the lane)

Appending exactly these bytes to `corpus/claim-ledger.tsv`:

- `R21-04` (`grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv`, expects `^86$`) → reads **87**;
  the row must be migrated in the same candidate.
- `R24-14` (`bash corpus/row-identity.sh ledger-ids`, expects `count=86
  sha256=3728b4c4…`) → reads `count=87
  sha256=e7a97e968d685a7a023ac37a66c116a02f2a6718628e2351b47df9f022e69940`.
- `corpus/stamps.tsv` line 5 pins `corpus/claim-ledger.tsv`
  (`e99dea7e… 104 49374`); after the edit `verify_stamps` reports it STALE until the reviewed
  re-stamp, and a re-stamp moves `R24-05`'s `row-identity.sh stamps` pin as well.
- `R18-02` counts `[substrate]` rows and `R13-02` counts `^R1` rows: R46-01 changes neither
  (note carries no tag; the id starts `R4`).
- `R25-02`'s `claims=` is `len(claims)` over `corpus/self-counts.tsv` (corpus/self-counts.py:308,
  365-373), not the ledger row count; `corpus/claim-ledger.tsv` is read there only as an id→command
  lookup (line 310). A new ledger row therefore does not move `claims=60` unless the self-counts
  table gains a `ledger:R46-01` row — not measured here (self-counts is host-heavy and out of this
  seat's scope).
- `corpus/claims-declared.sh` links `plans/round-<N>.md` and `SCORECARD.md` through
  `corpus/claims-declared.tsv`; it never reads `corpus/claim-ledger.tsv`, so the row needs no
  declaration there. The `idref` leg only requires that a doc citing `R46-01` resolves — a row cited
  nowhere is an ORPHAN (informational), not a failure.

## 6. Pre-existing red found while probing (not this seat's fix)

`R24-05` is already failing at BASE: it expects `ROW_IDENTITY: stamps count=122 sha256=3586872e…`
and the tree reads `count=123 sha256=47fa2d50…` (witness §6, `receipt-gate-R2405-pin.out`:
`FAIL R24-05 reason=verdict-not-final exit=0`). Any candidate that runs the ledger's `verify` will
carry that failure unless the pin is migrated — it must be named, not silently inherited.

## 7. Bounds

- The red witness proves the row is able to fail. It does not prove the row can pass: no CLEAN tree
  exists in the lane yet (that is C2's candidate work). Pattern satisfiability was checked against a
  synthetic CLEAN line only, and is labelled as such in `red-witness.txt` §5.
- The `verify` runs used `--claims` fixtures, so `stamped=123` is the archive's stamp set and
  `unresolved_ids` counts the lane docs' id references; neither is a claim about R46-01.
- Nothing in the lane tree was written, checked out, reset or stashed; the only lane writes are this
  directory and `.ufo/waves/round-46/build/K46ExecLedger.md`.
