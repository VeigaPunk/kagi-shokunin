# KnowOpEnvRefs — round-27 C1 inventory: `corpus/knowledge/op-env-refs.md`

**Agent:** `KagiR26.KnowOpEnvRefs-17`
**BASE:** `0a47dd189356ea66ec83c3891eed54526e95b89b`
**Target:** `corpus/knowledge/op-env-refs.md` — 69 lines; working-tree blob `57ac4cbdfa18915f8f2dd89e46902a11dd1d2f2b` equals `HEAD:corpus/knowledge/op-env-refs.md` (unmodified at BASE).
**Scope:** C1 inventory for this one entry only. No production edit.

## Godspeed axes (named)

| Axis | This slice |
|---|---|
| **Correctness** | No digit dropped silently: all 36 numeral tokens on 20 lines were censused and classified; every proposed locator was machine-checked for exactly one matching line and exactly one capture group. |
| **Calibration** | Empty binding set defended against QM21/QM26 and the entry's own Erratum; no `KN-*` row added that would bind a different quantity. |
| **Freshness** | The entry has no release anchor/observation pair, so C2's REGRESSED rule cannot apply; the residual (cross-doc handler line-range disagreement) is named, not papered over. |
| **Surface / YAGNI** | One report; no new binder source type, no host read, no ledger row. |

## Verdict

**0 current-tense lane-artifact numbers are in population.** The entry states no selftest case count, row/stamp/claim/pin count, finding count, or bound; its only digits are dated handler/`op.env` observations of the absent host substrate, the round-22 Erratum's own round tag, positional list indexes, and regex/path characters.

Binding table (format per `corpus/self-counts.tsv` header: id, doc, locator, source, extract, note) — **no data rows**:

```
id	doc	locator	source	extract	note
```

No `KN-OPENVREF-*` id is proposed; the `KN-*` block in the after table correctly has no row for this entry (`grep op-env-refs corpus/self-counts.tsv` → none).

## Population rule applied

- `plans/round-27.md` §C1: current-tense numbers in `corpus/knowledge/*.md` about this lane's own artifacts; stale ones corrected with a history clause.
- `corpus/QUALITY.md:133` QM26: "a dated measurement section, Evidence/Erratum history or a positional case index is excluded by rule and named".
- `corpus/lessons/round-25.md:53-58` R25-C6: a number is current when it states an artifact's present size with no newer value in the same clause; an explicit history clause is out.

The entry satisfies the exclusion clauses explicitly rather than by silence. `corpus/knowledge/op-env-refs.md:59-60`: **"Source-status: historical — original file size/mode, line references, version and handler outcomes above are not remeasured current facts while the substrate is unavailable."** The `stat` that produced them is itself dated (`:4`, "taken 2026-09-28"), and the substrate-absence premise is the recorded lane position (`PROVINCE.md:11-16`; `corpus/README.md:119`).

## Complete numeral census and exclusions

36 numeral tokens / 20 lines / 29 clusters. The 26 locators below (one per non-identifier cluster) were verified against the file: each matches exactly one line, yields exactly one group, and the group equals the stated number. The 3 remaining clusters are the three claim IDs on `:8`, which contain digits but state no integer.

```
cluster	line	text (verbatim fragment)	numeral(s)	class	closest lane-local source / pinned value	status	verified locator
C01	corpus/knowledge/op-env-refs.md:3	`cmd_refs` (L228–235)	228	handler line ref (owned host surface)	none: no cmd_refs anchor in corpus/drift-symbols.tsv; drift-baseline.tsv:1 pins mode 755, lines 333, sha256 only — no interior line map	OUT — host substrate + Erratum "line references"	^Source: `~/.local/bin/the-janitor` `cmd_refs` \(L([0-9]+)–235\)
C02	corpus/knowledge/op-env-refs.md:3	(L228–235)	235	handler line ref	none (same)	OUT — same	\(L228–([0-9]+)\) and `cmd_run`$
C03	corpus/knowledge/op-env-refs.md:4	(L237–249); `stat`	237	handler line ref	drift-symbols.tsv:30 pins L248 inside the range, not the start	OUT — host substrate + Erratum	^\(L([0-9]+)–249\);
C04	corpus/knowledge/op-env-refs.md:4	(L237–249)	249	handler line ref	none	OUT — same	^\(L237–([0-9]+)\);
C05	corpus/knowledge/op-env-refs.md:4	taken 2026-09-28	2026-09-28	dated measurement	the date itself is the history clause	OUT — dated measurement	taken ([0-9]{4})-09-28\.
C06	corpus/knowledge/op-env-refs.md:13	awk filter (L234)	234	handler line ref	op-ref-consumption.md:29 repeats L234 (agreement is not a pin); no drift-symbols row	OUT — host substrate + Erratum	awk filter \(L([0-9]+)\):
C07	corpus/knowledge/op-env-refs.md:18	`-rw-------` (0600)	0600	op.env mode	drift-baseline.tsv:5 pins mode 600 for the same path (lane-local, but the binder cannot extract a column from rows:)	OUT — host observation + Erratum "original file size/mode"	\(0([0-9]{3})\), 1078 bytes
C08	corpus/knowledge/op-env-refs.md:18	1078 bytes	1078	op.env byte size	none anywhere: drift-baseline's third column is lines (17), not bytes; `grep -rn 1078 corpus/` finds only this entry and lessons/round-1-aggregator-audit.md:21	OUT — no lane-local source; host observation	, ([0-9]+) bytes, mtime
C09	corpus/knowledge/op-env-refs.md:18	mtime 2026-08-27	2026-08-27	dated observation	the mtime is part of the dated observation	OUT — dated measurement	mtime 2026-08-([0-9]{2})\.
C10	corpus/knowledge/op-env-refs.md:19	default `~/.config/the-janitor/op.env`, L7	7	handler line ref	none	OUT — host substrate + Erratum	op\.env`, L([0-9]+)\)\.
C11	corpus/knowledge/op-env-refs.md:33	exit 2	2	handler outcome	none; no ledger row pins the wrapper exit code	OUT — Erratum "handler outcomes"	exit ([0-9]+);$
C12	corpus/knowledge/op-env-refs.md:34	exit 2	2	handler outcome	none	OUT — same	exit ([0-9]+); no command
C13	corpus/knowledge/op-env-refs.md:35	exit 2	2	handler outcome	none	OUT — same	exit ([0-9]+)\. A locked
C14	corpus/knowledge/op-env-refs.md:40	1. New keys go	1	positional list index	—	OUT — QM26 positional index	^([0-9]+)\. New keys
C15	corpus/knowledge/op-env-refs.md:42	`^[A-Z][A-Z0-9_]*=`	0	regex character class	—	OUT — regex syntax, not a count	\[A-Z([0-9])-9_\]
C16	corpus/knowledge/op-env-refs.md:42	`^[A-Z][A-Z0-9_]*=`	9	regex character class	—	OUT — regex syntax, not a count	\[A-Z0-([0-9])_\]
C17	corpus/knowledge/op-env-refs.md:44	it sits at 0600 in a file	0600	op.env mode restatement	drift-baseline.tsv:5 mode 600	OUT — host observation + Erratum	sits at (0[0-9]{3}) in a file
C18	corpus/knowledge/op-env-refs.md:46	2. `run` is for one-shot	2	positional list index	—	OUT — QM26 positional index	^([0-9]+)\. `run` is for
C19	corpus/knowledge/op-env-refs.md:48	3. Never diff/copy	3	positional list index	—	OUT — QM26 positional index	^([0-9]+)\. Never diff
C20	corpus/knowledge/op-env-refs.md:49	0600) is the only durable fact	0600	op.env mode restatement	drift-baseline.tsv:5 mode 600	OUT — host observation + Erratum	^   (0[0-9]{3})\) is the only
C21	corpus/knowledge/op-env-refs.md:53	awk line at L234	234	handler line ref	none (same as C06)	OUT — host substrate + Erratum	awk line at L([0-9]+)\.
C22	corpus/knowledge/op-env-refs.md:54	→ `600`	600	falsification expectation of host stat	drift-baseline.tsv:5 mode 600 (same value; still a host observation)	OUT — host observation + Erratum "mode"	→ `([0-9]{3})`\.
C23	corpus/knowledge/op-env-refs.md:55	exit 2	2	handler outcome	none	OUT — Erratum "handler outcomes"	`missing command`, exit ([0-9]+)\.
C24	corpus/knowledge/op-env-refs.md:57	## Erratum (round 22	22	round identifier	—	OUT — round tag/identifier, not a size	^## Erratum \(round ([0-9]+)
C25	corpus/knowledge/op-env-refs.md:69	round-22/build/Entry17.md	22	path component	—	OUT — identifier	round-([0-9]+)/build/Entry[0-9]+\.md
C26	corpus/knowledge/op-env-refs.md:69	round-22/build/Entry17.md	17	path component	—	OUT — identifier	round-[0-9]+/build/Entry([0-9]+)\.md
C27	corpus/knowledge/op-env-refs.md:8	Reverify: R11-02, R11-04, R12-01	R11-02	claim identifier (no count stated)	claim-ledger.tsv:16 exists [substrate]	OUT — identifier, not an integer	—
C28	corpus/knowledge/op-env-refs.md:8	Reverify: R11-02, R11-04, R12-01	R11-04	claim identifier	claim-ledger.tsv:18 exists [substrate]	OUT — identifier	—
C29	corpus/knowledge/op-env-refs.md:8	Reverify: R11-02, R11-04, R12-01	R12-01	claim identifier	claim-ledger.tsv:26 exists [substrate]	OUT — identifier	—
```

Word-form numbers (no digit, therefore no binder capture): `single` (`:12`, "the single env file"), `Two` (`:21`, heading "Two verbs, different audiences"), `one-shot` (`:46`). `Two` does state a size (the handler's two verbs) but it is a handler taxonomy statement, not a lane-artifact size with a lane-local count source; the other two are idioms. All out.

## Why no binding row is possible even if one insisted

The binder's three source forms cannot express these digits:

- `rows:<repo file>` counts nonblank, non-comment lines with `extract` = `-` (`corpus/self-counts.py` module docstring). `corpus/drift-baseline.tsv:5` records mode `600` and **lines** `17` for `op.env`; it has no byte-size column. Counting the file's data lines (15) would bind 15, a different quantity.
- `ledger:`/`expect:` apply one regex to a row's last output line / committed expect column. The three referenced rows expose only their own summary integers: `R11-02` `pass=`/`skip=` (`corpus/claim-ledger.tsv:16`), `R11-04` `files=`/`symbols=` (`:18`), `R12-01` `checks=`/`oprun=`/`refs=`/`divergent=` (`:26`). None exposes a handler line number, `op.env` bytes, its mode, or a wrapper exit code.
- Adding a new source form (a field extractor for `rows:`) or a new host-executing ledger row would be a production change outside C1 and would run against an absent substrate; `PROVINCE.md:11-16` says the handler, `~/.config/the-janitor` and `~/.local/state/the-janitor` were measured absent, and `claim-ledger` defers `[substrate]` rows there.

## Freshness / C2 applicability

- The entry has no `recheck:` header and no numeric anchor/observation pair: its only recheck path is event-conditioned (`:67-68`, "restored handler source and a CLI release change"). `corpus/release-clock.py`'s REGRESSED rule (C2) therefore has nothing to order here, and this entry cannot contribute a fired/regressed receipt. That is a structural absence, not a pass.
- Counterexample that the Erratum is load-bearing, not decorative: the entry says `cmd_refs` L228–**235** (`:3`) while the sibling entry records `cmd_refs` L228–**236** (`corpus/knowledge/op-ref-consumption.md:4`, a 2026-09-28 read-only inspection). The entry's own Erratum concedes this ("The handler line-range disagreement remains unverified", `:65-66`). [INFERENCE] Since there is one handler file, at least one of the two committed ranges must be wrong at BASE (both could be); I could not read the handler to say which. No gate in this lane pins or compares those ranges (checked `corpus/drift-symbols.tsv` and `corpus/claim-ledger.tsv`): `corpus/drift-symbols.tsv` pins no `cmd_refs` line; its only `the-janitor` line pins are `:11` (`MODEL_ID=` at L17), `:12` (`MODEL_ENDPOINT` at L19), `:13` (`endpoint $MODEL_ENDPOINT` at L148), `:14-16` (OP/credential references at L194/196/214), and `:30` (`exec op run` at **L248**, inside the `cmd_run` range L237–249). A handler update that moves `cmd_refs` would change the file hash, and drift-pins would report `DRIFT`, but no gate maps that verdict back to this entry's ranges; conversely, a shift that moved `cmd_refs` while leaving L248 and the other pinned shapes in place would leave `drift-symbols` green and both prose ranges silently wrong. This is a named substrate-return debt, out of C1's reach by rule; it is not fixed by inventing a binding.
- If the Erratum (`:57-66`) were deleted, `:18`'s `1078 bytes`/`0600` would become current-tense numbers with **no** lane-local integer source and no gate — exactly the class QM26 excludes by rule and the reason a reviewer should not manufacture a row. The entry's calibration is textual (Erratum + dated source), not machine-checked.

## Recommendations to L1

1. Add **zero** `KN-*` rows for `corpus/knowledge/op-env-refs.md`; nothing in this entry is in the C1 population and no row would survive `self-counts.py`'s "exactly one line / exactly one group" rule with a truthful source.
2. Optional, if a documented zero is wanted: a comment line above the `KN-*` block in `corpus/self-counts.tsv` naming this entry and the Erratum-22/host-substrate exclusion. A data row would bind the wrong quantity.
3. Do not use this entry for the red one-digit mutation control (`c1-measure.py --mutate`): it has no bindable digit, so the control must stay on an entry with a real `KN-*` row.
4. Record the `cmd_refs` L228–235 vs L228–236 disagreement as substrate-return debt in the lesson/debt list; do not "fix" either range from memory.

## What I did NOT check

- Did not read `~/.local/bin/the-janitor`, `~/.config/the-janitor/**`, or `op.env`; did not `stat` any host path. Substrate status is taken from `PROVINCE.md:11-16` / `corpus/README.md:119`, not re-measured.
- Did not run `corpus/self-counts.py`, `c1-measure.py`, any selftest, gate, linter, or formatter; did not execute any ledger row (pins read only).
- Did not resolve whether `cmd_refs` ends at L235 or L236 (needs restored source); did not verify `op-ref-consumption.md`'s other handler line refs.
- Did not audit other knowledge entries, the `RD-DOCS-*` declaration counts, or whether the after `KN-*` population is complete.
- Did not check whether the handler is present now, per contract.

**Tooling:** no installs or upgrades this run.

Report: .ufo/waves/round-27/build/KnowOpEnvRefs.md
