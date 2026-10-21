# ScribeMistakes — round-25 Mistakes draft (kagi)

Base `4587c61a348e4528717404a68912c373f3ef4d03`. Seat `KagiR25.ScribeMistakes-2`, leaf, read-only on the lane. The lane file `corpus/lessons/round-25.md` does not exist yet and was NOT written by this seat (the contract allows only this report). The draft below is for L1 to paste.

## Commands and results

| command | exit | result |
|---|---|---|
| `git clone -q --no-hardlinks …/kagi-shokunin …/ScribeMistakes/lane && git checkout -q 4587c61a…` | 0 | sandbox `/fast/scratch/kagi-r25/ScribeMistakes/lane` |
| `env -i PATH=/usr/bin:/bin HOME=…/ScribeMistakes/home bash corpus/claim-ledger.sh citations` (in sandbox) | 1 | `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)`; 88 UNRESOLVED lines = 57 `(sibling)` + 31 `(ufo)`; 62 unique tokens |
| `grep -v '^#' corpus/claim-ledger.tsv \| grep -c ''` | 0 | 61 claim rows |
| `grep -v '^#' corpus/stamps.tsv \| grep -c ''` | 0 | 83 stamp rows |
| `sed -n 46p SKILL.md` | 0 | `63 stamps + 39 claims + claim ids, round 21` |
| `grep -n 'LAYOUT\|lone' corpus/claim-ledger.sh` | 1 | no layout marker in the gate; only the R11-08 note carries the lone-clone statement (`corpus/claim-ledger.tsv:22`) |
| MANIFEST.json, kagi round 24 closure record (python json) | 0 | notes list closure caveats; `unresolved` cited there as 73 |

Not run (UNRUN): default `verify` and `cells` in the lone clone; host-tripwire, identity and gate-regression re-measures. No installs, no host reads, no vault/handler/CDP/op, no `--allow-host-rows`.

## Draft text (paste into `corpus/lessons/round-25.md`)

## Mistakes

| id | class | evidence | captured-by | fix |
|---|---|---|---|---|
| M25-1 | current-tense self-description not bound to the live value it describes | `SKILL.md:46` reads "63 stamps + 39 claims + claim ids, round 21"; `corpus/stamps.tsv` has 83 rows and `corpus/claim-ledger.tsv` 61 claim rows (`.ufo/waves/round-25/build/ScribeMistakes.md` command table) | none: the ledger pins artifacts and claim results, never the doc's own count statement | C1: `corpus/self-counts.py` + `corpus/self-counts.tsv` bind each number to a live source; planned, UNRUN; a one-digit doc mutation must exit 1 |
| M25-2 | operability limit recorded only as a ledger note, not as a gate outcome | `corpus/claim-ledger.tsv:22` (R11-08 "fails by design" in a lone clone); sandbox lone-clone `citations` at BASE exit 1, `unresolved=88` (57 sibling + 31 ufo); `claim-ledger.sh` has no layout marker | none: the gate prints `BROKEN`/`UNRESOLVED` with no layout tag, so the red reads as a defect | C2: `CITATION_LAYOUT: lone-clone` line, `FLEET-ABSENT` counted as `fleet_absent=N` (never `unresolved`), `[fleet]` rows print `LAYOUT-SKIP`; planned, UNRUN |
| M25-3 | closure record quotes a count the measurement does not reproduce | MANIFEST kagi round-24 closure notes: "73 unresolved fleet-relative cites"; sandbox run at BASE gives 88 occurrences, 62 unique tokens (`citations` exit 1); the discrepancy is unexplained | none: the closure's recheck list did not carry the command's own `unresolved=` line | closure counts must quote the exact command output line; C2 records `unresolved=` from the run; cause of 73 open, not inferred |
| M25-4 | an instrument counts a proxy while its label names the property | `.ufo/waves/round-24/tools/host-tripwire.sh:1-16` counts invocations of six stubbed scripts ("depth=… <script> <args>"); closure note: "tripwire counts stub invocations (attempts), not host reads" | none: disclosed in the closure note only; the round-24 C1 "total=0" is a stub-invocation count | label the metric as "population invocations of the six stubbed scripts" wherever cited; a read-level counter is a separate, unbuilt instrument |
| M25-5 | a regression control identical by construction, reported as an identity check | `.ufo/waves/round-24/tools/gate-regression.py:17,24,27`: the fixture suffix is taken from the new file and written into both revisions, so `fixtures_identical=True` is forced; closure note: "identity holds by construction … not identical committed fixtures" | none: disclosed in the closure note; the gate logic itself is still exercised on both revisions | compare the committed fixture digests read from each revision's own tree and fail on mismatch; until then label the result "same-suffix regression" |
| M25-6 | a seat edited the live lane tree (wrong relative path) | `corpus/lessons/round-24.md:156-158`: IdentR1111 edited the lane's `corpus/surface-census.tsv` once, restored it from BASE; a stamp taken in that window was wrong and re-taken at `ce9c544d` | the seat's own admission and the lead's restore; no mechanical guard | prompt contract: seats write only their Report path; lead checks lane status before and after each seat; re-stamp after any restore |
| M25-7 | isolation enforced by instruction, not by the tool | `corpus/lessons/round-24.md:159-161` and `.ufo/waves/round-24/build/IdentR1604.md:44`: an extra default `verify` ran in a BASE scratch clone without an empty HOME; the default reaches R18-01's host-path reads at BASE; no tool-level refusal | none mechanical; the round-24 C1 tripwire measured the default path after the fix, not this run | every gate invocation in a scratch clone carries `env -i … HOME=<empty>`; a planned gate check to refuse a non-empty HOME is out of scope for this round |

Already recorded, not duplicated: M24-4 (late census), M24-13 (dead seats), M24-15 (quote count), M24-16 (working-tree repairs before reports settled).

## Insertion points

- `corpus/lessons/round-25.md` (new file, L1 writes it): place `## Mistakes` after the round title block and before any measured-outcome section, mirroring `corpus/lessons/round-24.md:144`.
- `plans/round-25.md` "Frontier step" already names M25-1 (stale SKILL.md:46); add M25-2 to it only if L1 keeps the C2 route.
- No change to `SKILL.md`, `claim-ledger.tsv` or `MANIFEST.json` from this seat; those are L1-integrated.

## Findings and limits

- M25-1 and M25-2 are confirmed at BASE by the commands above. Their fixes (C1, C2) are not built here; each is UNRUN.
- M25-3 is a real discrepancy: 73 (closure) versus 88 (measured). The cause is unknown; the draft does not infer it.
- M25-4 to M25-7 come from the closure caveats and seat notes. Their evidence is the cited files; the seat did not re-run the instruments.
- Wave-level recovery/censuses from round 24 were not re-run.
