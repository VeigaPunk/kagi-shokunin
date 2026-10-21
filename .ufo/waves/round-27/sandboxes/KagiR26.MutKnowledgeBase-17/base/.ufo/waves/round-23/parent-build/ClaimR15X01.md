# ClaimR15X01: R15-01 semantic audit (critic, round-23 parent build)

Seat: `ClaimR15X01`. Read-only leaf. Axes: calibration, freshness, operability.
Installs: none. No tool, version, channel or reason to record.
This seat ran: `sha256sum`, `ls`, presence probes (`test -x/-e`, `command -v`), a
Python sweep that printed only paths and counts, and one `grep` over synthetic
stdin. It did **not** run `checklist-run.sh` in any mode, any checklist row,
`claim-ledger.sh`, any sibling gate, the handler, or `op`.

## Observed revision

| object | identity (2026-10-21, -03:00) |
|---|---|
| repo | `.git/HEAD` = `d218603b74099ddca0bd8f869516fc41db0979bf`, detached and JJ-colocated. L1 has uncommitted round-23 edits in the tree. |
| frozen-population ledger | `corpus/claim-ledger.tsv` `e6806968…8305`, 43 rows, read 00:46. Equals `stamps.tsv:5`. |
| in-flight ledger | `6fa0c24f…ee0b` at 00:54, 45 rows (adds R23-01 and R23-02). |
| R15-01 row bytes | sha256 `9569969a…f1cd`, at `:33` in round-22 `frozen/before` (c2cab35), in the pre-r23 ledger and in the in-flight ledger. Identical in all three: the row has not changed. |
| runner, declaration, items | `checklist-run.sh` `7e5ec98b…` = `stamps.tsv:2`. `checklist.tsv` `28bd238e…` = `:3`. `SKILL.md` `00d6202f…` = `:70`. SKILL.md has 16 `- [ ] ` items at `:434-459` under the heading at `:423`. |
| ledger gate | `claim-ledger.sh` `cf56f9ea…` (pre-r23, = `stamps.tsv:4`), now `c20c2d04…` in-flight. The deferral lines (`:140-146`, `:416-419`) and SKIP-SELF lines (`:816-820`) are unchanged. |
| host, presence only (00:59) | handler not executable (`test -x` → 1), so R15-01 DEFERs here. `~/.local/state/tac/handoff-status.json` absent. `op` on PATH. |

## Verdict

| question | finding |
|---|---|
| Are the expected line, exit and timeout justified? | **As a contract, yes. As current evidence, only historically.** On success the runner prints `CHECKLIST_RATIO` (`checklist-run.sh:281-282`), then exactly `CHECKLIST_RUN: CLEAN (items=%s runnable=%s by_hand=%s failed=0)` (`:294`), and returns 0 (`:296`; dispatch `:501-507`). So the ledger's exit plus last-line rule (`claim-ledger.sh:425-444`) binds to counts computed from real inputs: items from SKILL.md (`:100-116`), runnable/by_hand from the TSV, and `failed=0` only when `BAD=0`. **Historical evidence:** CLEAN with exit 0 in ~2.3 s at round 15, 2026-09-28 (`LOG.md:539-542`). Since 2026-10-14 the recorded full run is `BROKEN (failed=6)` exit 1 (`knowledge/substrate-deferral.md:8-11`, which its erratum `:95-115` marks historical). Round 22 skipped the row (`safe-row-plan.json:272-279`; `final-verification.json:547-551`, "Not executed."). **Timeout:** 300 s is about 130× the measured run. Each row's own limit is `CHECKLIST_TIMEOUT`, default 240, read from the caller's environment (`:72`). Two or more hung rows become a ledger `reason=timeout`, and the runner's own ITEM-FAIL lines never print. An exported `CHECKLIST_TIMEOUT` changes R15-01's verdict. |
| Does `[substrate]` deferral preserve the obligation? | **Partly.** The declaration half (counts, lead bijection, POLICY, RATIO) is still covered by the untagged rows R15-03, R15-04 and R15-05: `--ratio` runs every declaration check, then returns before the run loop (`:248-255`). The execution half is not covered. Six rows read the absent substrate (E1, E5, E8, H1, H3, H4; prior round `build/Entry04.md:128-130`). **E4 is the only runnable item that does not depend on the substrate, and it is skipped along with the whole row** (F2). |
| SKIP-SELF? | **Not applicable, and not needed.** The command does not contain `claim-ledger.sh` (`claim-ledger.sh:816`). Checklist rows cannot name it (`checklist-run.sh:75,149`). The four delegated gates contain no `claim-ledger` reference (grep: 0 matches). Consequence: a `cells` run on a host with the substrate re-executes the whole live checklist through R15-01, because seven cells cite it. That is why R13-03 must stay tagged. |
| Hermetic / synthetic mode? | **Covers the runner, not R15-01's checks.** R15-02's 34 cases use synthetic `printf`/`sleep`/`exit` rows (`checklist-run.sh:358-407`) and never the nine real check strings. The in-flight R23-01 fixture (`corpus/fixtures/cells-hermetic/claims.tsv:1-2`) has no tagged rows and pins `row_deferred=0`. Its note's "no substrate probe" is accurate: `substrate_present` only runs for tagged notes (`claim-ledger.sh:416`). But it never exercises a deferred row inside `cells` (F3), and neither mode can see F1. |

## F1 (primary): false-clean, because E4 exempts whole lines instead of individual matches

**Evidence.** E4 (`corpus/checklist.tsv:29`) counts *lines* matching its reference-literal pattern as `raw`. It then removes every line that contains an allowlisted vault prefix (`vault`, `FakeVault`, `wal`) before counting `hits`, and requires raw = 5 and hits = 0. A line holding both an allowlisted placeholder and a non-allowlisted reference is therefore removed whole.

- **Demo:** one such mixed line on synthetic stdin (literal built at runtime) counts as raw 1, hits 0.
- **Contradicts the docs:** the row note (`checklist.tsv:29`) and bound 3 of `knowledge/checklist-execution.md` (`:123-124`) both say "a live-looking path under any other vault name still hits". For a mixed line it does not.
- **Not covered elsewhere:** no R15-02 case reaches it, and the bounds name only the case of a vault literally called `vault` (`:125-126`).

**How a consumer sees it.** One of the five allowlisted lines is in `corpus/lessons/round-5-aggregator-audit.md`, and that file has **no row in `corpus/stamps.tsv`**. Append a real reference to that line and the scan still reads `hits=0 excluded=5 raw=5`. Nothing else in the lane notices:

- no STALE pin, because the file is unstamped;
- R22-03 audits stamped membership only;
- `SC_CREDENTIAL` scans only SOURCES.md and sourced entries (`sources-census.sh:54-55,82-85`, in-flight copy);
- there is no active `.git/hooks` hook (only `.sample` files).

The result is `CHECKLIST_RUN: CLEAN (items=16 runnable=9 by_hand=7 failed=0)` on a substrate-present host, and DEFER on this host.

**Minimal synthetic falsifier.** For L1 or the falsification wave; not run by this seat. Run it in a scratch tree only. The literals are built from fragments because a committed literal would itself move E4's pin.

```
t=$(mktemp -d); s="o""p:"
for i in 1 2 3 4 5; do printf '%s//vault/ex%s\n' "$s" "$i" >>"$t/doc.md"; done
E4=$(awk -F'\t' '$1=="E4"{print $4}' corpus/checklist.tsv)       # run from repo root
( cd "$t" && bash -c "$E4" ); echo "rc=$?"   # control: hits=0 excluded=5 raw=5 rc=0
{ printf '%s//vault/ex1 %s//Synth0/item0\n' "$s" "$s"; tail -n +2 "$t/doc.md"; } >"$t/x" && mv "$t/x" "$t/doc.md"
( cd "$t" && bash -c "$E4" ); echo "rc=$?"   # mutant today: hits=0 excluded=5 raw=5 rc=0 (FALSE-CLEAN)
                                             # after fix:   hits=1 excluded=5 raw=6 rc=1
```

**Smallest safe fix.** Count per match: change `-RInE` to `-RIonE` in both greps, so the allowlist filters individual matches.

- Today's tree has 5 matches on 5 lines and 0 non-allowlisted (sweep under F2). The pinned `REF_PATH_SCAN: hits=0 excluded=5 raw=5` stays as it is.
- Re-stamp `checklist.tsv` in the same commit (QM5).
- Correct the "still hits" wording with an appended erratum.

## F2: deferral removes E4's only executor on this host

- **Evidence.** Deferral happens before policy or execution (`claim-ledger.sh:416-419`), and the tag covers the whole row. E4 reads only the repository. No other ledger row runs E4:
  - R15-02 is synthetic;
  - R15-03 only loads rows (`checklist-run.sh:300-318`);
  - R15-04 counts rows;
  - R15-05 runs no row (selftest case "ratio mode runs no row", `:483-484`);
  - R23-01 and R23-02 are unrelated.
- **Freshness.** On this host, no ledger row has run the repo-wide reference sweep since 2026-10-14. The latest measurements are:
  - **Historical:** round-22 Entry04, measured by hand "repo-only" at c2cab35 (`Entry04.md:71-72`).
  - **Current (this seat):** at 00:52:28 and 00:58:23 over the on-disk tree, excluding `.git` and the gitignored `.ufo/interactive-sessions/`, and skipping binary or non-UTF-8 files the way `-I` does. Result: 5 lines / 5 matches in `knowledge/op-env-refs.md` (1), `lessons/round-5-aggregator-audit.md` (1), `surface-census.sh` (1) and `transcript-scan.sh` (2). 0 non-allowlisted, 0 mixed lines, nothing under `.ufo/waves/`.
  - So the pin holds today on the scanned scope. The gap is latent, not a present violation.
- **How a consumer sees it.** `CLAIM_LEDGER: CLEAN (… deferred=11 …)`, while a reference on its own new line (raw=6, hits=1) would be committed undetected anywhere outside SOURCES.md and sourced entries.
- **Smallest safe fix (L1's call under the frozen plan).** Add an untagged row: `bash corpus/checklist-run.sh --only E4`, expecting `^CHECKLIST_ROW: CLEAN \(id=E4 `, exit 0, timeout 60.
  - It passes the command policy (`claim-ledger.sh:160-191`).
  - `only_row` runs the declaration audit plus E4 only, and its last line is printed at `checklist-run.sh:292`.
  - Cost: the R21-04 row-count pin moves.

## F3: C3 must keep the cells that rest on R15-01 classed as unverified

- **Evidence.** `SCORECARD.md:219` (Round 15 post-move, freshness) cites only `R11-04` and `R15-01`. Both rows are `[substrate]`, and the cell has no stamped path.
  - `cells` dedupes the cited ids and re-runs them once each (`claim-ledger.sh:757-763,802-829`). Here both rows DEFER, but the cell still counts as `row_pointed` with zero executed pointers.
  - `CELL_AUDIT` reports only an aggregate `row_deferred` row count (`:1011-1012`), not which cells have no executed evidence. QM3 is met per row, not per cell.
  - The other six cells citing R15-01 (`:215,216,228,292,313,621`) each have an executed co-pointer: R15-02..05, R15-05, or the stamped `lessons/round-15.md` at `:216`.
  - No selftest runs `cells` with a deferred row. The `defer-substrate-*` cases (`:1422-1424`) test `verify` only; a grep for a cells+defer case finds 0.
- **What C3 must keep for R15-01:**
  - **(a) Keep real tagged rows out of fixtures.** Never copy R15-01, or any real tagged row, into a fixture. The checklist resolves `$HOME` paths, execs `op run` (E5) and `ss` (H8), and always `cd`s to the runner's own root (`checklist-run.sh:64-66,261`), whatever `--root` is. The in-flight fixture complies.
  - **(b) Don't cite R23-01 for R15-01's cells.** R23-01's CLEAN must not be cited for any real cell that cites R15-01. Round-23 cells cite R15-05 (`:830`) and R23-01 (`:841`), which is consistent.
  - **(c) Smallest fix.** Either add a `--selftest` case, `KAGI_SUBSTRATE=absent … cells`, over a fixture with one deferred-only cell that pins today's behaviour, or add a `deferred_only=N` counter to `CELL_AUDIT`. A ledger row cannot do this: `env` and variable assignments fail the first-token allowlist (`:160`).

## C1: what the closure checker retains for R15-01

- **Not one of C1's obligations.** R15-01 appears only in the round-22 closure's "Exclusions/skips" paragraph (`lessons/round-22-verifier-spotcheck.md:74-77`). `closure-dispositions.py` parses only the Routed defects, Discernment spot-check and Adjudication sections (in-flight `:76-101`), so R15-01 falls outside its 15 obligations by design. `CLOSURE_DISPOSITIONS: CLEAN` must not be read as a disposition of R15-01.
- **What it does retain.** `source_sha256` freezes the skip paragraph, so silently dropping R15-01 from it fails with SETUP.
- **What it cannot prove.** A `fixed` pointer resolves on file, anchor and id token only (`:104-121`; in-flight D9 points at `corpus/claim-ledger.tsv`). It proves a record exists, not that R13-03 and R15-01 are still explicitly deferred.

## Secondary observations (operability)

- **False-fail when only part of the substrate returns.** The tag's stated scope is the-janitor plus its tree (`substrate-deferral.md:27-30`). But E8 reads tac state (absent now) and E5 needs `op` (present now). Restoring only the handler un-defers R15-01 into `FAIL R15-01 reason=exit-mismatch`, with no item id, because the ledger never echoes output (`claim-ledger.sh:84-86`). Bound 2 (`substrate-deferral.md:62-64`) accepts conservative failures. Fix: name tac and `op` in the scope text.
- **Docs and code disagree on the last line.** The code takes it from stdout plus stderr (`checklist-run.sh:261-262`). The docs say stdout (`:15`; `checklist.tsv:10`; `checklist-execution.md:41`). A stderr line printed after a verdict produces ITEM-LASTLINE. Fix: a documentation erratum, not a code change.
- **E4 scans the whole working tree.** That includes `.jj/` (binary files skipped), the gitignored `.ufo/interactive-sessions/`, and every wave report under `.ufo/waves/`, this one too. A round-23 report that quotes an allowlisted-shape placeholder moves `raw`; a non-allowlisted one moves `hits`. This report spells no such literal.

## Limits

- I did not read `.ufo/interactive-sessions/` (private), so E4's true input on this checkout is unresolved; my sweep is a lower bound.
- The sweep approximates `grep -RI` with a NUL and UTF-8 test; it is not the embedded command.
- With the substrate absent there is no current CLEAN or BROKEN observation. Everything about substrate-present behaviour is from reading the code.
- The in-flight digests and line numbers are point-in-time, because L1 is still integrating.
- No public sources were used.
