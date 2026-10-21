# ClaimR21X04 — R21-04 pins claim-row cardinality, not claim-row identity

**Observed revision:** HEAD `d218603b74099ddca0bd8f869516fc41db0979bf` (2026-10-20T21:11:59-03:00).
The working tree was **mid-r23-integration** during this audit (first observed 2026-10-21T00:46, last
2026-10-21T00:54:31-03:00): `M corpus/claim-ledger.tsv` sha256
`8d3703274d104546766fcdabe45e5216639f398e3f72b1117fe6ff1e457644ca`, 60 lines / 19,451 bytes, plus
`M` on `LOG.md SCORECARD.md SKILL.md corpus/SOURCES.md corpus/claim-ledger.sh corpus/knowledge/op-ref-consumption.md
corpus/sources-census.sh` and untracked `corpus/closure-dispositions.{py,json}`, `corpus/fixtures/`,
`corpus/lessons/round-23.md`, `corpus/source-fetches.tsv`, `plans/round-23.md`. Both epochs are audited
below; frozen-population evidence is HEAD bytes.

## 1. Row under audit — `corpus/claim-ledger.tsv:54`

Six fields: `R21-04` | `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` | `^43$` | exit `0` |
timeout `30` | note *"current claim-row membership: original 39 retained plus R22-01 through R22-04 for
executable feature review and revision audit. Counts rows, not calibration or source truth; old/new value
recorded in round-22 journal."*

## 2. Verdict, last line, exit, timeout — supported at the frozen epoch

1. **Last line.** `grep -c` emits exactly one line, the count. `verify_claims` takes the last non-empty
   line (`corpus/claim-ledger.sh:436-443`) and matches it as an ERE; `43` matches `^43$`. Reproduced in
   the persisted receipt (below), not re-executed here.
2. **Exit 0.** Positive count ⇒ grep exits 0. Zero matches ⇒ exit 1 *and* last line `0`, so both
   conjuncts fail. Missing file ⇒ exit 2, stderr is last, `verdict-not-final`. All fail closed.
3. **Policy.** First token `grep` is allowlisted (`:160`); no `[;&|<>$`]` metacharacter (`:163`); no
   denied word in `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` under the quote-stripped
   DENY_WORD_RE (`:167`). Statically accepted; the row is never `POLICY`.
4. **Timeout 30 s.** Measured **0.001 s** at `8ada17a` (`final-verification.json` `safe_rows[26]`), i.e.
   30 000× headroom. A stuck read yields 124/137 → `reason=timeout` (`:428-431`).
5. **Value 43 is measured, not authored.** `.ufo/waves/round-22/final-verification.json`
   `safe_rows[26]` records argv, `exit=0`, `stdout="43\n"`, `last="43"`, `passed=true`, `seconds=0.001`.
   An independent predicate (`NF>=6`, non-comment) on the HEAD blob gives 43 rows, **43 distinct ids, no
   duplicates**; the same predicate gives 43 at `8ada17a` and `4be5da3`. The R21-04 line is byte-identical
   at `8ada17a`, `4be5da3`, `d218603` (sha of the line `486d3cdd846341dd…`); the known D6 `.h1` label
   defect therefore does not touch this row's count.
6. **Provenance.** `corpus/stamps.tsv:5` pins `corpus/claim-ledger.tsv` at
   `e680696843637587…`, 58 lines, 17 844 bytes — all three columns match the HEAD file.
   QM14 record: `.ufo/waves/round-22/pin-migrations-integration.json` `claim_changes[R21-04]`
   old `^39$` → new `^43$`, `BASE=c2cab35`; `git log -S"^43$"` names `8ada17a`; `4be5da3` changed other
   rows only. Frozen `before` copy holds the 39 version (`8b867976a2…`).

## 3. Causality — what the count does and does not bind

1. **Set claim is true today.** Frozen r22 `before` ledger: 39 rows, distinct, **39 ⊆ HEAD 43**; the
   difference is exactly `{R22-01, R22-02, R22-03, R22-04}`. The note's "original 39 retained plus
   R22-01 through R22-04" is therefore a *correct set statement*, not just a total — but nothing
   executes it.
2. **`grep -c` counts lines, not ids.** No uniqueness or id-shape check exists: `load_ids`
   (`:606-616`) appends `TF[0]` verbatim, `verify_claims` requires only a non-empty first field
   (`:409`), and the summary prints `ids=$LID_N` (`:982`) — the same line count. A prefix match
   (`^R[0-9]+-[0-9]+`) also accepts ids the whole-word id audit (`:630`) treats as different tokens.
3. **The R1x cohort is pinned separately; the R2x cohort is a difference.** `R13-02`
   (`claim-ledger.tsv:31`) pins `^R1` = 35; with 43 total, R2x (8 rows) exists only by subtraction.
   At the in-flight 45, R1x is still 35, so R2x is 10 — again by subtraction only.
4. **`claims=` is declared, not verified.** `C_N` increments at `:415`, *before* deferral
   (`:416-419`) and policy (`:420-424`). `CLAIM_LEDGER: CLEAN (claims=43 deferred=11 …)` means 32 rows
   ran. C1 must never use `claims=` as an executed or closed count.
5. **The stamp, not the count, enforces atomicity.** Any edit to `claim-ledger.tsv` (append, delete,
   rewrite) makes `verify_stamps` report `STALE` until the row is re-pinned; the count row's job is to
   catch a *stale total after a legitimate re-pin*. That is exactly the window in which a same-count
   change is invisible (see §6).

## 4. `[substrate]`, SKIP-SELF, hermetic

- **`[substrate]` — correctly absent.** The command reads a repo file with coreutils grep: no `$HOME`,
  no handler, no network. Deferral requires the literal tag in the note (`:416-418`), so the row runs on
  every host. It must stay untagged: a tag would defer the population count precisely on absent-substrate
  hosts, where 11 rows are unexecuted.
- **SKIP-SELF — correctly not applied.** The test is `TF[1] == *claim-ledger.sh*` (`:816-820`); this row
  names `claim-ledger.tsv`, and the code comment (`:813-815`) states the distinction: "a row that merely
  greps `corpus/claim-ledger.tsv` is a reader, not a re-invocation." No recursion. Caveat: the test is a
  substring of the whole command column, so a future row that merely *mentions* `claim-ledger.sh`
  (e.g. greps README prose) would be silently skipped and uncounted; R21-04 is not that row.
- **`cells` re-run.** `cells_evidence` replaces `CLAIMS` with the cited subset (`:822-828`) but leaves
  `ROOT` unchanged; if a cell ever cites R21-04, the row still counts `$ROOT/corpus/claim-ledger.tsv` —
  correct for production, and at a fixture root it reads the fixture (exit 2 if absent). Today **no
  scorecard cell cites R21-04** (`grep -c R21-04 SCORECARD.md` = 0), so `cells` never re-runs it and
  `rows_run` does not include it.
- **Hermetic — host-free but not content-free.** Under the round's definition ("never run live substrate
  commands") R21-04 is *already* hermetic: it executes locally with no host state. Its expectation is a
  constant of a **mutable production artifact**, so a fixture copy proves the copy and an authored
  fixture proves nothing about the ledger. `corpus/fixtures/cells-hermetic/claims.tsv` holds one row
  (`R90-01 bash corpus/fx-ok.sh`); its `cells` verdict is `rows_run=1`, and `CELL_AUDIT` exposes no
  `rows_total` (`:1011`). The fixture therefore cannot stand in for this obligation.

## 5. What C3 must retain

1. **Classify R21-04 as executed-host-free, not fixture-covered.** It belongs in the
   executed set of the full-row/safe-row pass (a `final-verification.json`-style record with measured
   output), never in the "preserved by the hermetic cells fixture" set.
2. **Do not let `R23-01`'s fixture `rows_run=1` be read as a population count.** The C3 proof of
   "all command-row obligations retained" must be a separate partition assertion over the frozen 43 ids:
   executed ∪ deferred-by-tag ∪ explicitly-excluded-with-reason = 43, with R21-04 in *executed*.
3. If a fixture analogue is wanted, it must be a **different obligation** (a count-*shape* predicate),
   because `^43$` copied into a fixture is either a re-assertion of the copy or a rewritten expectation.
   A hash-pinned ledger snapshot in the fixture is a *point attestation*, not a hermetic re-derivation;
   label it as such.

## 6. Consumer-visible false-clean + minimal synthetic falsifier (proposed, not executed)

**Risk (false-clean): same-count replacement is invisible.** R21-04 verifies cardinality only. Once the
ledger is legitimately re-stamped — every round does this — a swap that keeps the line count and the id
set leaves `CLAIM_LEDGER: CLEAN (claims=43 ids=43 …)` and `CELL_AUDIT: CLEAN`. In the strong variant the
id is *reused* with a weaker command (e.g. `R22-04`'s `revision-audit.py --selftest` replaced by a
one-line grep): citations still resolve (0 orphans today), no cell cites R22-04 (SCORECARD count 0), and
the stamp is fresh by construction. The obligation disappears; the only signal left is the QM14 journal.

**Minimal synthetic falsifier for L1** (scratch tree, no production write):

```
$F/corpus/claim-ledger.tsv   # the file being counted: three 6-field rows
RX-01<TAB>grep -c . corpus/marker<TAB>^1$<TAB>0<TAB>5<TAB>a
RX-02<TAB>grep -c . corpus/marker<TAB>^1$<TAB>0<TAB>5<TAB>b
RX-03<TAB>grep -c . corpus/marker<TAB>^1$<TAB>0<TAB>5<TAB>c
$F/claims.tsv   # the row under audit, verbatim shape
R21-04<TAB>grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv<TAB>^3$<TAB>0<TAB>5<TAB>fixture
```

- Case A: `verify --root $F --claims $F/claims.tsv --stamps <valid fixture stamps>` → row passes (`3`).
- Case B (mutation): rewrite the counted file to `RX-01, RX-03, RX-04` → the row **still passes** (`3`).
  A correct closure check must flag the set change; the fixed checker (below) must exit 1 / print
  `added=1 removed=1` on case B while case A stays green.

## 7. What C1 must retain

1. **Population = id set, not 43.** The r23 roster already *is* an independent manifest:
   `swarm-registry.json` has 66 members, 43 of which map `ClaimR<r>X<nn>` → ledger id with **exact set
   equality to the 43 HEAD ids** (verified: no missing, no extra, no duplicate) and 23 `SourceS0NN`.
   Use that set equality; treat R21-04 as a tripwire.
2. **Do not make R21-04 an obligation.** The closure set is D1–D9 + SPOT-01..05 + ADJ (15), per
   `corpus/closure-dispositions.json`; it contains **no** `43`/`R21-04` reference today (verified).
   Keep it that way — a row count must never become an obligation id or a pointer target.
3. **`claims=N` is declared.** Closure language must quote executed rows (`claims − deferred`), not
   `claims=`.
4. **Two populations, explicitly.** Frozen audit population = 43 ids (roster). Post-integration tree =
   45 ids = 43 + `R23-01` + `R23-02` (new, L1-owned, outside this wave's audited set). Record the +2 as
   additions; do not merge them into the audited population or into any "43/43 dispositioned" line.
5. **Frozen binding.** There is no round-23 frozen snapshot (`.ufo/waves/round-23/` holds only
   `parent-build-spec.json`, `parent-build-dispatch.json`, `parent-build/`). The only immutable
   bindings are `stamps.tsv:5` (sha `e6806968…`, 58/17 844) and the r22 `frozen/before/` 39-row copy.
   If C1 enumerates from the working tree after 00:53, it enumerates 45, not the audited 43.

## 8. Freshness — historical vs current, with the live drift

| epoch | state | evidence |
|---|---|---|
| frozen / HEAD `d218603` | `^43$`, 43 rows, sha `e6806968…`, 58/17 844 | `claim-ledger.tsv:54`; `stamps.tsv:5`; r22 `final-verification.json` |
| round-21 close `c41af82` | `^39$`, 39 rows | frozen `before` copy (`8b867976a2…`); r22 migration record |
| **in-flight 2026-10-21T00:54:31-03:00** | **`^45$`, 45 rows, sha `8d370327…`, 60/19 451** | working tree |

The in-flight note now names `R23-01`/`R23-02` (correct) but still ends *"old/new value recorded in
round-22 journal."* That pointer is now **stale by one epoch**: the round-22 journal records 39→43
(`pin-migrations-integration.json`), and no round-23 migration record exists under `.ufo/waves/round-23/`
(only spec/dispatch/registry; `corpus/lessons/round-23.md` has no `R21-04`/43→45 entry). QM14 is a
same-commit obligation, so either the note must point at a new round-23 record carrying `43→45`, or the
integration lands an unexplained rewrite — the exact class the round audits. The append itself is
correctly atomic in time: `claim-ledger.sh` and `claim-ledger.tsv` were both written at 00:53:16, and
`R13-02` correctly stays `^35$` (R1x unchanged, so the cohort delta is now 10).

## 9. Proposed move (connector, one bounded)

**Demote R21-04 from population proof to tripwire; bind the population to an id manifest.** Add
`corpus/claim-ids.tsv` (sorted id list, stamped) and one successor row running a small
`bash corpus/claim-ids.sh` that prints
`CLAIM_IDS: CLEAN (rows=N unique=N added=0 removed=0 changed=0)` by diffing the current ledger ids
against the manifest. Keep R21-04 as the cheap cardinality check (it catches an unaccompanied append
before the manifest is touched).

- **Axes.** Calibration: removes count-as-closure and makes the audited population a row-pointer set.
  Operability: the expectation stops moving every round (the per-round literal bump is what forces a
  re-pin and a journal entry). Freshness: the manifest update becomes the reviewed, journaled event
  instead of a silent same-count swap. No axis is harmed: R21-04 is retained, and no substrate/host
  dependency is added.
- **Risks.** One more file + stamp row (R12-03 moves). The manifest is only authoritative if it is
  stamped *and* updated only with a QM14 record; otherwise it becomes a second mutable list. Keep the
  row policy-clean (`bash` allowlisted) and host-free.
- **Verification.** The §6 case B becomes a selftest case; the `R23-01`/`R23-02` append must print
  `added=2 rows=45` in a round-23 record, and HEAD→next must print `added=0 removed=0`.

## 10. Limits and disclosure

- **No gate, row command, handler, substrate, vault, or host command was executed.** In particular I did
  not run `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv`, `verify`, `cells`, or `--selftest`.
  Counts were derived with an independent `NF>=6 && $1 !~ /^#/` predicate, `git show` blobs,
  `sha256sum`, and Python `json`/`re` over committed files; policy acceptance is a static reading of
  `:160/:163/:167`.
- The tree changed **during** the audit (00:46 → 00:54:31); every claim above is timestamped to the
  state it describes. Untracked in-flight files are not HEAD and may change again; the L1 must re-read
  the row at commit time.
- No public sources used, so no external quote applies. No private config/data/vault content read. No
  tool installs or upgrades; campaign pacman pause respected.
- The §6 false-clean is a code-path inference from `:407/:409/:415/:606-616/:977/:982` plus the stamp
  path, not an observed execution; L1 must run the fixture.

Report: .ufo/waves/round-23/parent-build/ClaimR21X04.md
