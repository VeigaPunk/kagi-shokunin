# Entry04 — freshness/calibration audit of `corpus/knowledge/checklist-execution.md`

Seat: `KagiR22.Entry04` (read-only scout; no subagents; no host gates run).
Base read: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`HEAD`, matches frozen base).
Axes: **freshness** (stamp/pin integrity, historic-vs-current) and **calibration**
(source/provenance adjudication of the entry's own claims).
Installs: none. No vault/account/credential operation; only repository reads, git
object reads, and `test -x/-e` presence probes.

## Verdict

| Question | Finding |
|---|---|
| Stale-byte mismatch for this file? | **No.** `corpus/stamps.tsv` row 12 is byte-exact: sha256 `2216efe217a9dc6ccd47f4372f485efb0cae81613da7650c788c06f7a52e58c8`, 190 lines, 13369 bytes, equal to `git show HEAD:corpus/knowledge/checklist-execution.md` and to the worktree file. |
| Pin churn / dropped history for this row? | **None.** The file has exactly one touching commit (`587fda0`, 2026-09-28); the row was created there and never re-stamped. It is not among the six stale rows at base and not among the nine round-21 re-stamped rows. |
| Is the entry substantively fresh? | **Partly.** Its structural claims still match the shipped gate, but two provenance sentences are not reproducible and the entry omits the substrate-loss event that changed what its baseline means. See D1–D5. |
| Appended correction needed? | **Yes, one append-only errata block**, not a rewrite and not a silent re-pin. Proposed text in §6. |

## 1. Exact revisions read

| Object | Revision / date |
|---|---|
| Target file + worktree | `HEAD` = `c2cab35` |
| Target introduction | `587fda0` (2026-09-28, round-15 landing) |
| Pre-round-21 stamp state | `c41af82^` (parent of the round-21 landing) |
| Round-21 landing / correction | `c41af82`, `e1544c1` (2026-10-19) |
| Historic SKILL.md / SCORECARD | `e64e81b` (r9), `03477c0` (r10), `301b9ec` (r11), `4b8c018` (r13), `2486643` (r14), `587fda0` (r15) |
| Later file touches | `f4a8dd9` (2026-10-15), `bad9088` (r19), `584dd67` (2026-10-17), `c2cab35` |

Method: `git show <rev>:<path>` hashes/line/byte counts, static reads of
`corpus/checklist-run.sh` and `corpus/checklist.tsv`, and git-history queries.
No `corpus/*.sh` gate was executed.

## 2. Pin state, exact

`corpus/stamps.tsv` line 12:

```
corpus/knowledge/checklist-execution.md	2216efe217a9dc6ccd47f4372f485efb0cae81613da7650c788c06f7a52e58c8	190	13369
```

Measured on `HEAD` blob: `2216efe2…a52e58c8`, `190`, `13369` — all three columns match.
Basis files this entry cites are themselves pin-current at base:

| Basis | stamp match | value |
|---|---|---|
| `corpus/checklist-run.sh` | yes | `7e5ec98b…fd576bf`, 506 lines, 24697 bytes |
| `corpus/checklist.tsv` | yes | `28bd238e…f39972f04`, 40 lines, 11694 bytes |
| `SKILL.md` | yes | `df05677f…12e14d0b`, 665 lines, 58395 bytes |

So the byte layer is clean: there is no stale-byte mismatch to reconcile for this file.

## 3. Static contract re-check (claims that still hold at base)

Re-derived without executing any gate:

- `SKILL.md` still has **16** `- [ ]` items in `## Credential-hygiene checklist`
  (L423 heading, items L434–456, section ends before L461).
- `corpus/checklist.tsv` still has **16** declaration rows; class split **9 runnable /
  7 by-hand**; the seven by-hand ids are exactly E2, E3, E6, E7, H2, H5, H6.
- Delegation split still **delegated=3 direct=6**: E1, E5, H7 delegate; E4, E8, H1,
  H3, H4, H8 are direct.
- `--selftest` case register is still **34** (33 `run "…"` lines plus the
  `CT=1 run "row timeout"` line that increments the same counter).
- Reason policy is exactly as documented in §2: the ERE is
  `^(class): .{24,}$` on the text and the text must also carry **>=20 non-space**
  characters; both classes require a `note`.
- Deny list is the documented set (`op.env`, `op run|read|inject`, handler
  start/stop/run, `claim-ledger.sh`); `ITEM-FAIL` echoes at most 6 output lines
  (`tail -n 6`).
- E4's pin was re-measured repo-only: `raw=5`, non-excluded `hits=0`,
  `excluded=5`; three `[reference metadata redacted]` matches, one `[reference metadata redacted]`, one `[reference metadata redacted]`.
- E1/H7/H8 pinned last-line EREs are present in `checklist.tsv` unchanged
  (`DRIFT_PINS: CLEAN (files=15 symbols=20)`, H7 `0|1|2` with `HITS=2` or
  `db not found`, H8 `password_refs=0 … non_loopback=0 established=0`).

These are why the entry is still usable as a description of the shipped gate. They do
not make it current about the host.

## 4. Substantive findings (calibration, not bytes)

### D1 — the header's line span is not reproducible (major provenance)

Line 4 says: “16 items, L420–447 at the round-15 revision”. No shipped `SKILL.md`
revision has that span:

| Revision | heading line | item lines | next heading |
|---|---|---|---|
| `4b8c018` (r13) | 406 | 409–431 | — |
| `2486643` (r14) | 419 | 422–444 | — |
| `587fda0` (r15) | **420** | **431–453** | 458 |
| `c2cab35` (base) | 423 | 434–456 | 461 |

The 16-item count is correct; the closing line `447` is not a checklist endpoint in any
revision (at `587fda0` L447 is blank text inside the Handler group; the last item is
L453). Historic label or not, this citation was never true as shipped.

### D2 — “round-9/10/11 scorecard” misattributes the quoted sentence (minor)

Line 18 says “the round-9/10/11 scorecard said ‘12 checklist items are still operator
judgement’”. Occurrence counts of that phrase in `SCORECARD.md`:

| Revision | count |
|---|---|
| `e64e81b` (r9) | **0** |
| `03477c0` (r10) | 1 |
| `301b9ec` (r11) | 2 |
| `4b8c018` (r13) | 3 |

It first appears at round 10 and is present through round 13 (removed at `587fda0`).
The surrounding claim that the list held 14 items at r9/10/11 is correct (14 at each).

### D3 — the baseline is historic, and the substrate it measured is gone (major freshness)

The entry states cleanly that its basis is 2026-09-28, but it never records the
substrate-loss event that makes the §4 baseline non-reproducible:

- `corpus/knowledge/substrate-deferral.md` (measured 2026-10-14) records that the
  entire janitor substrate is absent and states the checklist gate then reported
  `checklist BROKEN (failed=6) exit 1`. `corpus/README.md` carries the same erratum.
- Confirmed read-only on 2026-10-20: `$HOME/.local/bin/the-janitor` absent;
  `~/.config/the-janitor`, `~/.local/state/the-janitor`,
  `~/.config/opencode/agents/janitor.md`, `~/.local/state/tac` absent.
- `R15-01` (the reverify pointer's whole-run claim) carries the `[substrate]` tag, so
  `claim-ledger.sh verify` **defers** it on this host (`DEFER … reason=substrate-absent`)
  rather than running it. `R15-02..R15-05` are substrate-independent (scratch selftest,
  `--list`, a TSV count, `--ratio`) and remain re-runnable.
- The six failing rows implied by `BROKEN (failed=6)` are E1, E5, E8, H1, H3, H4:
  absent inputs or delegates. H7 passes legitimately via its second accepted state
  (`db not found`, exit 2 is in the row's `0|1|2`).
- **H8 passes vacuously on that host** [INFERENCE: static reading of the check string
  and pin, not executed]. Its `pw` is the sum of `grep -c` over two files; both are
  absent, so `grep` prints nothing, `awk` yields `0`, the socket counts are `0`, and
  the row exits 0 with `CONTROL_PLANE: password_refs=0 …`, matching its pin. On a
  substrate-absent host `password_refs=0` therefore measures **missing inputs**, not
  the handler's code path. §6.5's “asserts its scope” does not hold there, and the
  entry never says so.

This is the substantive freshness gap the byte stamp cannot express: pin-exact text
describing a host that no longer exists, with no pointer to the later measurement.

### D4 — E4 allowlist provenance is off by one line class (minor)

§6.3 says `vault` appears “on the three documented example lines”. Actual matches:

| Path:line | Kind |
|---|---|
| `corpus/knowledge/op-env-refs.md:14` | documented example |
| `corpus/lessons/round-5-aggregator-audit.md:19` | documented example |
| `corpus/transcript-scan.sh:202` | `--selftest` INSERT fixture |

`FakeVault` is in `corpus/surface-census.sh`; `wal` is in `corpus/transcript-scan.sh`.
The pinned counts (`hits=0 excluded=5 raw=5`) are correct and were re-measured; only
the “three documented example lines” attribution is wrong (2 documented + 1 fixture).

### D5 — the modes sentence omits `--ratio` (completeness)

§3 lists `verify`, `--list`, `--only ID`, `--selftest`. The script's own usage block
also lists `--ratio`; the same section documents the `CHECKLIST_RATIO` line and
`R15-05` invokes the mode. Not a false statement, but a reader cannot discover the
axis-defining mode from the modes sentence.

### Calibration parallel to the known E1/E3 overclaims

`corpus/lessons/round-21-verifier-spotcheck.md` records that the E1/E3 source admits
failed their own bar at landing (feature status/eligibility conflated; cross-product
docs stretched) and were corrected by append. D1 and D2 are the same failure class in
this entry: claims that were never true at their own cited revision. They are small,
but they are exactly what a non-author spot-check samples. The correct response is an
appended erratum that keeps the historic sentence visible, not a silent edit.

## 5. Absent-source limits (not verifiable in this seat)

1. Live-host gate facts behind every runnable row: E1 census/drift, E5 `op-ref-probe`,
   E8 `handoff-status.json`, H1 lock mode, H3 config contents, H4 agent front-matter,
   H7 transcript DB `HITS=2`, H8 sockets. Not run here; executing them is a
   host-authorised lane action, and the substrate is absent anyway.
2. Scheduling claim (§6.2, `systemctl --user list-timers` / `crontab -l`): historic
   host observation, not re-measured.
3. The “second lane … 8/8, exactly the floor” reading (§5) is recorded only in this
   entry; the committed lesson records the 3/13 strict reading and the E5 flag
   (`corpus/lessons/round-15.md:69`) but not the 8/8 variant. Arithmetic is
   consistent (E5 by-hand ⇒ 8/8); provenance is self-recorded.
4. The `op run`/fixture boundary for E5 is documented, not independently re-executed.

## 6. Proposed correction (append-only)

Append one block at the end of `corpus/knowledge/checklist-execution.md`; do not edit
§1–§7. It presumes the integration owner accepts the errata.

```
## Round-22 freshness audit (appended 2026-10-20; no text above is revised)

This entry's byte pin is exact at base c2cab35: the stamps.tsv row
2216efe2…a52e58c8 / 190 / 13369 equals the committed file. The items below
correct provenance and currency, not history.

1. The span "L420–447 at the round-15 revision" is not reproducible at 587fda0:
   the heading is L420, the 16 items run L431–453, and the next heading is L458.
   At base c2cab35 the section is L423–460 (heading L423, items L434–456). The
   16-item count is correct.
2. The "round-9/10/11 scorecard" attribution is off by one revision: the quoted
   phrase is absent from the round-9 SCORECARD (e64e81b), first appears at round
   10 (03477c0), and runs through round 13 (4b8c018). It is removed at 587fda0.
3. Substrate status changed after the round-15 measurement: since 2026-10-14 the
   janitor substrate is absent (knowledge/substrate-deferral.md; README Round-18
   erratum; test -x on the handler is false on 2026-10-20). The checklist gate
   then reported BROKEN (failed=6) — E1, E5, E8, H1, H3, H4 — so the CLEAN line
   in §4 is a 2026-09-28 measurement, never re-run since. H7's db-not-found state
   remains a legitimate pass (row pin 0|1|2). H8 is not among the six failures and
   would pass vacuously there: both files it greps are absent, so
   password_refs=0 measures missing inputs, not the handler. Read H8's
   CONTROL_PLANE line as a handler assertion only when the CLI and client files
   exist.
4. The E4 allowlist provenance in §6.3 is 2 documented lines plus 1 selftest
   fixture line: op-env-refs.md:14, round-5-aggregator-audit.md:19, and
   transcript-scan.sh:202 (a --selftest INSERT); FakeVault is in surface-census.sh
   and wal in transcript-scan.sh. The pinned hits=0 excluded=5 raw=5 are correct.
5. The modes sentence in §3 omits --ratio, which the same section's
   CHECKLIST_RATIO line and claim row R15-05 use; the script's usage block lists it.

Reverify at this append: R15-01 defers on a substrate-absent host
(DEFER … reason=substrate-absent); R15-02..R15-05 remain substrate-independent.
```

Append-only preservation requirement:

1. Append at EOF only; preserve every historic sentence, including the wrong span, so
   the erratum remains auditable against what was shipped.
2. Any append changes bytes. In the **same reviewed commit**, update only this path's
   row in `corpus/stamps.tsv` with the new sha256/lines/bytes. Do not touch other rows.
3. Record the superseded triple `sha256=2216efe2…a52e58c8, lines=190, bytes=13369`
   in that commit message and in the round-22 `LOG.md` entry. Do not delete the old
   triple; the ledger itself has no history column.
4. If the append is rejected, **do not restamp**: the current pin is exact and the
   entry remains a correct historic artifact. Record this audit only in the wave
   report/lesson.
5. Never “restore” a historic pin by copying it over a current one; that pins
   superseded bytes and is the laundering C2 forbids.

## 7. Nine dropped stamps — exact ledger evidence (context, not this file)

Measured by diffing stamps at the last pre-round-21 commit against base:

```
diff <(git show c41af82^:corpus/stamps.tsv) <(git show c2cab35:corpus/stamps.tsv)
```

Result: **9 rows with changed values, 0 membership (path) changes**. These are the
“nine dropped historical stamps”: nine pre-round-21 revision pins that no longer exist
anywhere in the ledger (only in git).

| Path | pre-round-21 pin (sha12/lines/bytes) | base pin | old pin valid at `c41af82^`? |
|---|---|---|---|
| `corpus/claim-ledger.tsv` | c8369a51869b / 49 / 13981 | 8a4019cfc1ee / 54 / 16986 | yes |
| `corpus/knowledge/op-ref-consumption.md` | dcd9389415ef / 307 / 21164 | b195cc69840b / 372 / 25290 | yes |
| `corpus/op-ref-probe.sh` | 509f084ad332 / 660 / 28660 | 0f1945e8d8a8 / 788 / 34362 | no (already stale) |
| `corpus/README.md` | 6ddda47d8bab / 86 / 18689 | 6837d22b1e14 / 118 / 22365 | no (already stale) |
| `LOG.md` | e6db90d2a37c / 762 / 56847 | 60a8fd366c83 / 1043 / 74864 | no (already stale) |
| `PROVINCE.md` | ffe644a7b2ce / 53 / 8172 | 4a346e2df81f / 62 / 10586 | yes |
| `SCORECARD.md` | f3e61bfe2e78 / 446 / 66069 | 29f9f0231f2f / 691 / 87010 | no (already stale) |
| `SHONEN.md` | efe81fa75cc1 / 11 / 4695 | 1bb89fc5c006 / 12 / 1312 | yes |
| `SKILL.md` | c2b3151c58dd / 663 / 57062 | df05677fe0dc / 665 / 58395 | yes |

Interpretation: five old pins were accurate for their own tree at `c41af82^` and four
were already stale before round 21. Re-stamping during round 21 therefore erased five
valid historic expectations and replaced four stale ones. The correct preservation is a
migration record (old triple, valid-for revision, superseding commit), not a second pin
row: `stamps.tsv` carries one row per path and `claim-ledger.sh stamp` refuses duplicate
paths within an invocation, so historic and current pins cannot coexist there.
Candidate append-only locations: the round-22 lesson/LOG with this table, or a new
`corpus/stamps-history.tsv`
(`path, old sha/lines/bytes, valid_from_commit, superseded_by`), owned by the
integration owner.

Six stale rows at base, with causes (none is this file):

| Path | pin set at | file changed at |
|---|---|---|
| `corpus/knowledge/config-layering.md` | `2486643` | `f4a8dd9` |
| `corpus/knowledge/handler-on-disk-state.md` | `2486643` | `f4a8dd9` |
| `corpus/knowledge/handler-trust-boundary.md` | `2486643` | `f4a8dd9` |
| `corpus/knowledge/janitor-env-contract.md` | `2486643` | `f4a8dd9` |
| `corpus/lessons/round-18.md` | `fecee87` | `bad9088` |
| `LOG.md` | `e1544c1` | `584dd67`, `c2cab35` |

`.ufo/waves/round-22/before.json` records the same six. The plan's “five stale stamps”
is the outside verifier's earlier count; the sixth (`LOG.md`) appeared when the log was
appended after its round-21 re-stamp. Both numbers are explainable; no row is hidden.

## 8. Exact recheck scope (for the integration owner)

All commands are read-only and repo-bounded; A–D may be re-run by any seat, E is
host-authorised only.

A. Pin identity (target file):
```
p=corpus/knowledge/checklist-execution.md
test "$(git show HEAD:$p | sha256sum | cut -d' ' -f1)" = "$(awk -F'\t' -v p="$p" '$1==p{print $2}' corpus/stamps.tsv)"
test "$(git show HEAD:$p | wc -l)" = "$(awk -F'\t' -v p="$p" '$1==p{print $3}' corpus/stamps.tsv)"
test "$(git show HEAD:$p | wc -c)" = "$(awk -F'\t' -v p="$p" '$1==p{print $4}' corpus/stamps.tsv)"
```
Expected: all three pass (verified today).

B. Structural claims:
```
grep -c '^- \[ \]' SKILL.md                                            # 16
grep -cE $'^[EH][0-9]+\t' corpus/checklist.tsv                         # 16
awk -F'\t' 'NR>1 && $1 ~ /^[EH][0-9]+$/{c[$2]++} END{print c["runnable"], c["by-hand"]}' corpus/checklist.tsv   # 9 7
grep -cE '^[[:space:]]*(CT=1 )?run "' corpus/checklist-run.sh          # 34
```
Expected: 16 / 16 / `9 7` / 34 (verified today).

C. Provenance:
```
git show 587fda0:SKILL.md | grep -n '^## Credential-hygiene checklist'
git show 587fda0:SKILL.md | grep -n '^- \[ \]' | sed -n '1p;$p'
git show e64e81b:SCORECARD.md | grep -c '12 checklist items'           # 0
git show 03477c0:SCORECARD.md | grep -c '12 checklist items'           # 1
git show 4b8c018:SCORECARD.md | grep -c '12 checklist items'           # 3
```
Expected: heading 420, bullets 431/453, counts 0/1/3 (verified today).

D. Nine-pin migration:
```
diff <(git show c41af82^:corpus/stamps.tsv) <(git show c2cab35:corpus/stamps.tsv)
```
Expected: 9 removed + 9 added value lines, same path set.

E. Host-authorised only (do not run in a read-only seat; substrate absent today):
```
bash corpus/checklist-run.sh            # expect BROKEN (failed=6), exit 1 — not CLEAN
bash corpus/claim-ledger.sh verify      # expect DEFER R15-01, R15-02..05 executed
systemctl --user list-timers --all      # scheduling bound §6.2
crontab -l
```
These would re-measure the host half; they cannot restore the round-15 baseline.

## 9. Remaining unknowns

- Whether the round-15 `L420–447` span came from a pre-commit draft cannot be
  established from git; no shipped revision contains it.
- The 8/8 E5-boundary lane result has no committed artifact beyond this entry.
- Whether the integration owner prefers errata-in-entry vs a `stamps-history.tsv` for
  the nine pins is a round-22 integration decision; this report supplies the exact
  evidence for either.


Integration privacy note (round 22): reference-shaped example metadata was redacted before first landing under corpus QUALITY QA5. No original reference path is retained in this report.
