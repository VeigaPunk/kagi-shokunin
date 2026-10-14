# substrate-deferral — the lane's claims when the substrate is absent

Source basis: host census re-run 2026-10-14 under the OMP/ufo-fsd re-census.
The entire janitor substrate is gone from this host:
`$HOME/.local/bin/the-janitor` (absent), `~/.config/the-janitor/` (absent),
`~/.local/state/the-janitor/` (absent), `~/.config/opencode/agents/janitor.md`
(absent), `~/.local/state/tac/` (absent), `tac-check` (absent). Every live gate
correctly fails closed: census `DRIFT (gone=23 absent=37)` exit 1, drift-pins
`DRIFT (files_bad=15 symbols_bad=20)` exit 1, transcript-scan `db not found`
exit 2, op-ref-probe `SETUP` exit 2, checklist `BROKEN (failed=6)` exit 1,
scope-gate `DEFECT (breadth_drift=6)` exit 1.

Reverify: R18-01, R11-09

## The problem

A committed claim row is a *promise about a host fact*. When the substrate the
fact lives on is absent, re-running the row yields `exit-mismatch` — which the
ledger reports identically to a genuine regression. On a substrate-absent host
the ledger's FAIL verdict could not distinguish "the claim is false" from "the
thing the claim measures is not installed here". Eleven rows fell into that
class on 2026-10-14 (0 code changes could make them pass, because every one
reads the missing surface).

## The contract

- A claims row whose note field contains the literal tag `[substrate]` declares
  that its command measures the substrate (`the-janitor` + its state/config
  tree). The tag lives in the data file, so the dependence is reviewable per
  row rather than inferred from the command text.
- `substrate_present()` returns true iff `$HOME/.local/bin/the-janitor` is an
  executable file. `KAGI_SUBSTRATE=present|absent` overrides detection —
  required so the selftest can prove both arms on any host.
- Absent substrate + `substrate` tag ⇒ `DEFER <id> reason=substrate-absent`,
  counted in `deferred=N` on the `CLAIM_LEDGER:` summary line, never a FAIL.
  The row is *not executed* — running it on an absent substrate is a false
  finding, not evidence.
- Absent substrate + no tag ⇒ normal run. A substrate-independent row that
  fails still fails; deferral cannot launder a real regression.
- `cells` re-runs rows through the same machinery, so its summary gains
  `row_deferred=N` between `rows_run` and `row_failures`.
- The census selftest's two verb cases execute the real handler (that is the
  probe's subject, not a fixture); substrate-absent they print `skip-case`
  rather than `bad-case`. The case count is unchanged (16), the line shape is
  the verdict.
- `substrate-deferral` is implemented as an explicit `[substrate]` bracket tag
  in the row note (tightened from a whole-word regex at landing: prose mentions
  like "substrate-deferral" falsely matched the word-boundary form).
- `R18-01` is the absence pin: it runs `corpus/drift-pins.sh` and pins the
  all-GONE `DRIFT_PINS: DRIFT (files_ok=0 files_bad=15 …)` verdict at exit 1.
  It carries no tag (it must run everywhere) and it CANNOT use a direct
  `test -x`/path probe: the policy deny-word list contains `the-janitor`, so a
  row naming the handler path is refused before it runs — an honest lesson in
  why the substrate's name is itself a denied verb in claim commands.
  Substrate return flips the verdict AND the exit, failing the row loudly.

## Bounds

1. Deferral records an *absence*, not a *pass*. A `deferred=N` summary is not
   evidence the claim holds; it is evidence the claim was honestly not
   measurable here. The substrate-return event un-defers the rows in one run.
2. The detection check is presence+exec-bit of ONE file. A restored binary at a
   different path keeps rows deferred; a poisoned stub at the pinned path
   un-defers them into real FAILs — which is the correct conservative outcome.
3. The tag is the literal bracket `[substrate]` anywhere in the note field.
   Prose mentions ("substrate-deferral", "substrate handler") do NOT tag a row;
   that word-boundary form was the round-18 in-flight defect — it deferred
   count rows and selftest rows whose notes discuss the mechanism. Brackets
   make tagging an authoring act, never an accident of phrasing.
4. `substrate_present` is env-overridable; a hostile `KAGI_SUBSTRATE=absent`
   could defer a present-substrate row silently. Accepting that: the env var is
   the selftest's only hermetic lever, and a runner that tampers with its own
   environment can forge any result anyway.
5. Deferred rows still pass `policy_check` parsing? No — deferral happens
   BEFORE policy_check and execution. A malformed substrate row defers instead
   of dying POLICY. Accepted bound: the row set is reviewed at commit time and
   the selftest pins both arms, so a malformed row cannot silently enter.

## Reproduction

```
KAGI_SUBSTRATE=absent  bash corpus/claim-ledger.sh verify   # DEFER lines, deferred=N
KAGI_SUBSTRATE=present bash corpus/claim-ledger.sh verify   # rows run normally
test -x "$HOME/.local/bin/the-janitor" && echo present || echo absent
bash corpus/claim-ledger.sh --selftest   # cases 95-97 prove both arms
```

## Falsifiers

- a `substrate`-tagged row reporting FAIL on an absent-substrate host;
- a non-tagged row reporting DEFER;
- `deferred` absent from the summary while a DEFER line printed;
- the census selftest failing the two verb cases on a host without the handler.
