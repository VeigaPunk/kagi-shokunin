# RevLedgerCounts — round-23 count-pin falsification

Seat: `KagiR23.RevLedgerCounts` (falsification, leaf). Base `d218603b74099ddca0bd8f869516fc41db0979bf`
plus the uncommitted round-23 tree. Read-only on the lane: no lane file was edited; the only lane
write is this report. Scratch copies were made under `/tmp/atk-*` from the lane tree; public
documentation was re-fetched with the operator-provided curl profile. No host gates, no legacy
`claim-ledger.sh verify`, no host-bound rows, no secrets.

**Headline: at the snapshot below (2026-10-21T04:18Z) all five assigned count pins are green, but the
tree moved under measurement, one pin was re-pinned in-flight (`R12-03` 70 → 79), and each count can
be kept green by a count-preserving edit that removes the thing it is supposed to pin.** The
59-case selftest was green while the live census was red for ~4.5 minutes; that window is the
decisive demonstration that the case count is not live-shape coverage.

All path:line references are against the snapshot at the end of §1 unless marked "dispatched epoch".

---

## 1. The measurement target moved during the falsify wave

The dispatch tree was not frozen. Files under judgment were rewritten between 00:57:55 and 01:16:35
local (UTC−03:00), i.e. after the 00:56 dispatch. Recorded `stat` mtimes and content changes:

| local mtime | path | observed change |
|---|---|---|
| 00:57:55 | `corpus/sources-census.sh` | rewritten to a version with `SUPERSEDED[$fid]=1` and no array declaration — live gate red (see §2). sha256 at that state: `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781`. |
| 01:02:21 | `corpus/sources-census.sh` | rewritten again; the whole `SUPERSEDED` block was deleted (fix). current sha256 `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057`. |
| 01:02:31 | `SCORECARD.md`, `corpus/closure-dispositions.json` | rewritten. current SCORECARD sha256 `1d7210b366f3ce636c4d68dccf54a1edb87d87278b1370a99f10f091d5958cc7`. |
| 01:02:56 | `corpus/claim-ledger.tsv` | `R12-03` expectation changed `^70$` → `^79$`; `R22-03` expectation `added=7` → `added=16`; `R23-01` note rewritten. current sha256 `0d3d75008122c49c58e3a6ff8a1b481ad1accda6f717cc2eb74b5a05b8e3b866`. |
| 01:03:02 | `corpus/fixtures/cells-hermetic/SCORECARD.md` | `<!-- D9: hermetic cells fixture ... -->` comment added. |
| 01:03:17 | `corpus/fixtures/cells-hermetic/corpus/adjacency.tsv`, `.../claims.tsv` | adjacency rows changed from space to TAB after `# no-enumerate` (same 9 lines / 307 bytes, new sha `fa15a53c…`); R90-02 timeout `10` → `30`. |
| 01:03:24 | `corpus/fixtures/cells-hermetic/stamps.tsv` | restamped to `fa15a53c…` after the adjacency edit. |
| 01:04:15 | `corpus/lessons/round-23.md` | `"over seven distinct URLs"` → `"over nine distinct URLs"` (line 170), and the "no cross-capture equality is enforced" sentence added at line 54. |
| 01:04:32 | `corpus/source-fetches.tsv`, `corpus/stamps.tsv` | fetch header bound rewritten (lines 18–21); S022 location `"JWT verification, Vault 1.17 note"` → `"Introduction, Vault 1.17 Note"`; top-level stamps regenerated, 79 rows, sha `882d2c6acc8236144580e76121bd3891d8a0a7c0bce5d5c7d57f2c4755d41471`. |
| 01:06:58 | `corpus/source-fetches.tsv`, `corpus/stamps.tsv` | D7 header scope corrected to “bind every mined row WITHOUT an in-row pin”; stamps regenerated again, 79 rows, sha `e1781a08315d68b95f1efe5adf25e7f1de1fce9e7368382e07529ed2aa8ad8e2`; source-fetches sha `846b203734bcddce6c16e8346eea20bb1613b23c6607366b608c7afd41a4ae76`. |
| 01:10:37–01:11:27 | `corpus/source-fetches.tsv`, `corpus/claim-ledger.tsv`, `corpus/sources-census.sh`, `corpus/stamps.tsv`, `SCORECARD.md` | quote bound narrowed to “shape-checked only … not verified against the page bytes”; normalization redefined as Python Unicode `\s`; the same-URL agreement code deleted and `fetch-disagree` findings `2` → `1`; `R21-03` note rewritten; stamps/SCORECARD re-pinned. Hashes then: census `511deb27…`, fetch `6e26e140…`, ledger `59869459…`, stamps `dd05e975…`, SCORECARD `7dc220f6…`. |
| 01:15:27–01:16:35 | `corpus/closure-dispositions.json`/`.py`, `corpus/claim-ledger.tsv`, `SCORECARD.md`, `corpus/sources-census.sh`, `corpus/stamps.tsv` | D3 reclassified `fixed` → `reported`, live tuple `7/2` → `6/3`; `R23-02` expectation updated; closure selftest `13` → `14` cases; dead `FDIG`/`FNRM` declarations removed; stamps re-pinned. Final hashes: JSON `d6239244…`, py `d79b08a7…`, ledger `ed125ca5…`, SCORECARD `94a34c9f…`, census `2d1bbbe3…`, stamps `8089e2bb…`. `LOG.md:1193` was left stale at `fixed=7 reported=2`. |

Executed consequence (the one that matters): `R12-03` at dispatch pinned
`grep -c '[^[:space:]]' corpus/stamps.tsv` = `^70$`; the current file has **79** non-blank lines and
the row now expects `^79$` (`corpus/claim-ledger.tsv:28`). The note on that same row still reads
`"original 63 retained, six reviewed integration additions and one late source-errata lesson pin"`
— arithmetic 63 + 6 + 1 = **70**, not 79. `R22-03`'s note was updated to "sixteen reviewed pin
additions (seven in round 22, nine in round 23)" = 63 + 16 = 79, which is internally consistent;
`R12-03`'s note was not. A closure measured at 04:18Z is therefore a closure over a different object
than the one dispatched at 03:56Z.

The same churn also transiently broke `R23-01`: a cells run at ≈01:03:0x local printed

```
STALE-POINTER corpus/adjacency.tsv sha=c17f7e17ff89->fa15a53c7e58 lines=9->9 bytes=307->307
CELL_AUDIT: BROKEN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=1 self_skipped=0 orphans=0)
exit 1
```

after the fixture bytes were edited but before the fixture-local stamp caught up (01:03:24). It is
`CLEAN` again now, but the window is real and is a direct operability counterexample during the
wave.

---

## 2. Live re-measurement, exact commands and exits

Final snapshot, 2026-10-21T04:05:09Z, re-confirmed 04:08:02Z, 04:12:01Z and 04:18:00Z, `bash` 5.3.20(1):

| row | command | value / last line | exit | matches row? |
|---|---|---|---|---|
| R13-01 | `grep -c '^## Round ' SCORECARD.md` | `27` | 0 | yes, `^27$` (`claim-ledger.tsv:29`) |
| R21-02 | `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` | 0 | yes (`:52`) |
| R21-03 | `bash corpus/sources-census.sh --selftest` | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` | 0 | yes (`:53`) |
| R21-04 | `grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv` | `45` | 0 | yes (`:54`) |
| R12-03 | `grep -c '[^[:space:]]' corpus/stamps.tsv` | `79` | 0 | yes, but row says `^79$` only since 01:02:56; dispatched row said `^70$` |
| R23-01 | `bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic ...` | `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)` | 0 | yes (`:59`) |
| R23-02 | `python3 corpus/closure-dispositions.py` | `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)` | 0 | yes, after row update at 01:15:27 (`:60`) |
| R23-02 selftest | `python3 corpus/closure-dispositions.py --selftest` | `CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)` | 0 | capability row (SCORECARD:851) |

Corroborating values: `corpus/stamps.tsv` is 79 non-blank lines, 79 distinct paths, 0 comment
lines, 0 blank lines, all 79 paths exist; `corpus/claim-ledger.tsv` has 45 `^R#-#` rows and 45
distinct ids at the final snapshot. `awk` recomputation of all ten `source-fetches.tsv`
`row_identity_sha256` values against `id<TAB>status<TAB>url` produced no mismatch.

### Dispatched-epoch vs broken window (freshness contradiction)

Before the 00:57:55 rewrite, the first measurement of the same five rows returned the same five
values (27 / CLEAN / 59 / 45 / 70). Then, between 00:57:55 and 01:02:21 local, `R21-02` was **red**
on the live registry while `R21-03` was **green**:

```
$ bash corpus/sources-census.sh
corpus/sources-census.sh: line 242: S007: unbound variable
exit 1                        # reproduced twice, 03:58–04:00Z

$ bash corpus/sources-census.sh --selftest | tail -1
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
exit 0
```

Root cause in the 80966e20 version: line 242 wrote `SUPERSEDED[$fid]=1` but the associative array was
never declared; with `set -u` the string subscript is evaluated arithmetically, so the first
`supersedes S0xx` row (`S007` in `corpus/SOURCES.md:13`) aborts the verify path. In a scratch copy,
adding `SUPERSEDED=()` to the `declare -A` line (the later fix is deletion of the block) restored
the exact expected line at exit 0:

```
$ bash corpus/sources-census.sh      # scratch repair
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit 0
```

Why the 59-case selftest could not see it: the selftest base fixture's four registry rows carry
`teaches one/two/three/four` in field 8, never `supersedes S…` (`sources-census.sh:515-575`,
fixture rows built at `:387-395`), so the `supersedes` loop is never executed by any case. **A live
gate can be red while `R21-03` is green; the count 59 certifies the fixture set, not the live row
shape.** The current script removed the `SUPERSEDED` block entirely, so the immediate bug is gone
but the blind spot (no selftest case with a `supersedes` field) remains.

---

## 3. Executed count-preserving attacks

Every attack was applied to a `/tmp` copy of the tree; no lane file was touched. E1–E3 and E6 were
re-run against fresh copies of the final 04:18Z tree (`/tmp/atk-Ef` E1–E3, `/tmp/atk-E4b` E4,
`/tmp/atk-E5b` E5, `/tmp/atk-E6c` E6); the values below are the re-run values or, where noted, the
epoch-B value with unchanged code/row bytes.
Each attack keeps the pinned command's expected value while removing identity, membership, or
semantic coverage.

### E1 — R13-01: duplicate round identity, count 27 (Low)
Scratch edit: renamed `## Round 21 — pre-move …` to `## Round 20 — pre-move …`.

```
$ grep -c '^## Round ' SCORECARD.md
27            exit 0
$ grep -n '^## Round 20 ' SCORECARD.md
558:## Round 20 — interactive attempt; blocked, not completed (2026-10-15)
615:## Round 20 — pre-move (repo `HEAD` `aea7a43`, round-20 attempt close)
```

Round 21's pre-move heading became a second Round 20 pre-move heading (its record now masquerades
as round 20) while cardinality stayed pinned. `cells` also has no
round-number uniqueness check: `ROUND_RE`/`SEC_RE` (`corpus/claim-ledger.sh:692`) accept a duplicate
`Round 20 — pre-move` heading and only require six axes per section (`:705-713`, `:735-746`)
[INFERENCE from code; the real scorecard `cells` run is host-bound and was not executed]. The
round-23 SCORECARD already names this debt: “`R13-01`'s identity-free round-heading count”
(`SCORECARD.md:862`). The note also contains the sentence “Includes the preserved blocked round-20
attempt … still fail closed.” twice (`claim-ledger.tsv:29`).

### E2 — R12-03: comment line substituted for a stamp row (Low; semantic pin unpinned)
Scratch edit: replaced one valid stamp row with `# retired pointer: …` (one non-blank line).

```
$ grep -c '[^[:space:]]' corpus/stamps.tsv
70            exit 0        # data_rows=69, comment_rows=1
```

The row's own semantics are “non-comment stamp row count”, but `[^[:space:]]` counts comments and
any other non-blank line. In the live file there are currently 0 comments and
`grep -c '[^[:space:]]'` = 79 = 79 data rows, so the value is exact *today*; it stops being a
membership count the moment a comment substitutes for a pin. A comment row would also trip
`load_stamps` (“malformed stamps row (fields=1)”, `claim-ledger.sh:326-329`) in every ledger gate,
so this exact substitution is caught elsewhere — but the count pin itself cannot see it.

### E3 — R21-04: duplicate claim id, count 45 (Low)
Scratch edit: changed `R23-02`'s id to `R23-01` (duplicate).

```
$ grep -cE '^R[0-9]+-[0-9]+' corpus/claim-ledger.tsv
45            exit 0
$ cut -f1 corpus/claim-ledger.tsv | grep -E '^R[0-9]+-[0-9]+$' | sort -u | wc -l
44            # uniq -d -> R23-01
```

The note claims “original 39 …, R22-01..04 …, and R23-01/R23-02” (`:54`), but the executed check
counts rows, not that set. Whether the host-bound ledger verify rejects duplicate ids was not
tested (forbidden); the count pin alone cannot.

### E4 — R21-02: fabricated provenance row, identical CLEAN line (Medium)
Scratch edit: repointed S024 in both `corpus/SOURCES.md` and `corpus/source-fetches.tsv:44` to
`https://example.invalid/fabricated-doc`, recomputed the identity digest
(`sha256("S024\tmined\thttps://example.invalid/fabricated-doc\n")` =
`f66a75b0a979900c5a206bbd299edbb380666aadeebb3fb7d6c7aed07eace044`), and substituted fake raw
(`e…e`) and normalized (`f…f`) digests, 1234 bytes, and a fabricated quote/location.

```
$ bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit 0
```

`SC_FETCH` establishes self-consistency (id/status/URL/identity digest, shapes, quote length,
location) and same-URL agreement among declared rows; it does not authenticate the capture, so an
invented capture passes. This is consistent with the note's stated “no network/content validation
by this command” (`claim-ledger.tsv:52`), but the C2 claim should not be read as a provenance
authenticity check.

Positive counterweight, measured: two declared captures re-fetch byte-exactly today with the
declared request profile and normalization. Commands and values:

```
$ curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
    https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2 -o /tmp/refetch-S024.html
exit 0
sha256 aaf52ac25695b1bb8ac6cba4f5e67abe27a35700619c9fa88b7bb292571c1008
bytes  586146
normalized (strip script/style, tags→space, html.unescape, collapse, trim, UTF-8)
       7c5a19e23f5f857b790cddec058c7eace7df21390058f4a42cc7ce1cf7c3a715
declared S024 raw aaf52a…c1008, bytes 586146, normalized 7c5a19…a715  -> exact match

$ curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
    https://openbao.org/docs/concepts/tokens/ -o /tmp/refetch-S021.html
exit 0
sha256 5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c
bytes  47384
normalized ed949658b434fa769b89c682160f77ad153f5c6657808706db5858506ce0d2e3
declared S021/S026 raw 522952…f82c, bytes 47384, normalized ed9496…d2e3 -> exact match
```

So the current declarations for S024 and S021/S026 are genuine; the gate simply cannot distinguish
them from E4's forgery. E4 was re-run at 04:12Z against the then-current script (sha `511deb27…`) with the
identical CLEAN line and exit 0.

### E5 — R21-03: substitute a case, keep 59 (High for coverage)
Scratch edit: replaced the `fetch-disagree` case with a duplicate `clean` case.

```
$ bash corpus/sources-census.sh --selftest | grep -E 'case clean|SELFTEST'
case clean: ok (exit 0, CLEAN)
case clean: ok (exit 0, CLEAN)
SOURCES_CENSUS_SELFTEST: PASS (59 cases)
exit 0
```

The removed case (`sources-census.sh:553` in the final script, mutation `m_fetch_disagree` at
`:426-431`) is the only case that appends a second S002 row with a different raw digest. In the
`24d834cc` snapshot it exercised `same-url-digest-disagreement` plus duplicate-provenance (2
findings); in the final `511deb27` script the cross-capture check was deleted, so the same case now
expects 1 finding (duplicate-provenance only). Re-run at 04:12Z against `511deb27`: PASS (59 cases)
with the duplicate `clean` case. The case count is computed dynamically (`cases=$((cases+1))`,
`:558`) so the number is honest, but a count is not a manifest: no code compares case names, and 59
survives any 1-for-1 substitution.

### E6 — R23-02: exchange disposition classes, aggregate counts identical (Medium)
Scratch edit in `closure-dispositions.json`: D1 `fixed` → `reported`, D2 `reported` → `fixed`
(both keep the resolving pointer `corpus/lessons/round-23.md#Routed defect dispositions`; the
target text contains both D1 and D2, so the `fixed` POINTER-ID check passes). Re-run at 04:18Z on
the current JSON (sha `d6239244…`, where D3 is already `reported`) with the identical CLEAN tuple
and exit 0.

```
$ python3 corpus/closure-dispositions.py
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)
exit 0
```

The row's aggregate tuple cannot detect that D1 rather than D3 is now the reported obligation. The
gate checks that a `fixed` pointer names the obligation id and resolves, not that the disposition
kind matches the obligation's evidence; C1's “6 fixed / 3 reported” is therefore a distribution
count, not a per-id record.

### E7 — R23-01: vacuous expect refused (positive result)
Scratch edit: R90-01 command → `bash -c 'true'`, expect `^$`.

```
$ bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic ...
claim-ledger: claims row R90-01: expect must assert a literal, not just anchors
exit 2
```

The claims machinery refuses an anchor-only expectation, so `rows_run=2` cannot be satisfied by a
trivially empty row this way. (The cells run still re-executes cited rows and compares exit and
last-line, so a fully vacuous fixture row is rejected at the claims layer.) The fixture is still
self-authored and editable — the 01:03:17 in-place mutation shows that — but this attack class is
closed.

---

## 4. Findings by severity

**High — measurement target mutated mid-wave.** `corpus/sources-census.sh`, `SCORECARD.md`,
`corpus/claim-ledger.tsv`, `corpus/stamps.tsv`, `corpus/source-fetches.tsv`, the round-23 lesson, and
the cells fixture were all rewritten between 00:57:55 and 01:16:35 local, after the 00:56 dispatch.
`R12-03` was re-pinned `^70$` → `^79$` at 01:02:56 while its note still describes 70 membership
(`claim-ledger.tsv:28`), and `R22-03` was re-pinned `added=7` → `added=16` (`:57`). A count
expectation that follows the artifact is exactly the count-preserving move this seat was asked to
attack. Any verdict must name the snapshot hash; the dispatch snapshot and the 04:18Z snapshot are
different trees.

**High — R21-02 red while R21-03 green; selftest has no `supersedes` case.** The broken 80966e20
script failed live with `line 242: S007: unbound variable` (exit 1, twice) while the 59-case
selftest passed. Scratch repair with `SUPERSEDED=()` restored the exact CLEAN line. The fixture
rows never put `supersedes S…` in field 8, so no case can reach that branch. The current script
removed the block, but the structural blind spot remains for any future `supersedes`-dependent
logic.

**Medium — R23-02 aggregate counts are class-swap blind and moved in-wave.** The live tuple changed
from `fixed=7 reported=2` to `fixed=6 reported=3` at 01:15:27 (D3 reclassified); the row and
`SCORECARD.md:843` were updated, but `LOG.md:1193` still records
`fixed=7 reported=2 … exit0`, which no longer reproduces. E6's D1/D2 swap keeps the current
`fixed=6 reported=3` with a different obligation classified fixed. C1's capability claim is about
one typed disposition per obligation; the row proves only the multiset.

**Medium — R21-02 provenance is self-consistency, not authentication.** E4's invented URL and
digests pass with the identical CLEAN line. Two real captures (S024, S021/S026) re-fetch exactly,
so the current data is genuine for those two, but the gate cannot tell a capture from a forgery.

**Medium — C2's same-URL agreement was deleted inside the wave.** At 01:04:32–01:06:58
`corpus/source-fetches.tsv:18-21` and `corpus/lessons/round-23.md:48-54` said “No cross-capture
equality is enforced” while `corpus/sources-census.sh` still enforced
`same-url-digest-disagreement`/`same-url-normalized-disagreement` and `fetch-disagree` asserted two
findings. At 01:10:59 the enforcement code was removed (the `FDIG`/`FNRM` arrays remain declared but
unused at `:229`), and the case now expects one finding. The final tree is self-consistent, but the
duplicate captures S021/S026 are no longer checked to agree; the agreement is now an unverified
claim. This is a capability change made during falsification, not a documentation-only fix.

**Low — R13-01 is identity-free.** E1 keeps 27 with two `## Round 20` headings and no round-21
pre-move heading. `cells` accepts duplicate round numbers (code: `claim-ledger.sh:692`,
`:735-746`); the SCORECARD itself lists this debt (`SCORECARD.md:862`). Note also repeats a
sentence (`claim-ledger.tsv:29`).

**Low — R21-04 is duplicate-id blind.** E3 gives 45 rows with 44 distinct ids. The pin counts rows,
not the set the note names.

**Low — R12-03's command does not match its stated semantics.** `[^[:space:]]` counts comments; E2
keeps 70 with 69 pins. Currently exact (79 = 79 pins, 0 comments), and `load_stamps` would reject a
comment row, but the pin alone cannot enforce “non-comment”.

**Documentation count (observed, then corrected in-flight).** At the dispatched/early-wave epoch,
`corpus/lessons/round-23.md` said “10 declared provenance rows (S017-S026) over seven distinct
URLs” and `LOG.md:1202` repeated “10 declared captures over 7 URLs”. Measured: 10 rows over **9**
distinct URLs (S021 and S026 both `https://openbao.org/docs/concepts/tokens/`); “seven” is the
count for S017-S023 only. At 01:04:15 the lesson was changed to “nine distinct URLs”
(`corpus/lessons/round-23.md:170`) and LOG to “9 distinct URLs” (`LOG.md:1202`), which now matches
the measurement. The scorecard coverage line, which read “S024-S026 are correction rows over seven
distinct URLs” at the early-wave epoch, was rewritten to “the 10 captures cover nine distinct URLs”
(`SCORECARD.md:840`, current snapshot), matching the measurement; the correction landed with the
same 01:02:31/01:04:15 churn.

**Positive, measured.** S024 and S021/S026 re-fetch byte-exact with the declared curl profile and
declared normalization (hashes above); all ten `row_identity_sha256` values recompute; `R23-02`
selftest passes 14 cases; `R23-01` prints the exact pinned line now; the claims layer rejects a
vacuous `^$` expect (E7).

---

## 5. Residual risk and verification gaps

- 8 of 10 declared captures were not re-fetched (only S024 and S021/S026); their digests remain
  unreproduced by this seat, though another seat may cover them.
- The real-scorecard `cells` run (`R13-03`) is host-bound and was not executed; the duplicate-round
  acceptance in cells is code-read, not executed on the real scorecard.
- The legacy `claim-ledger.sh verify` and the parent's 43 claim rows were not run per contract, so
  duplicate-id and stale-note effects outside the five pins are untested here.
- E6/E4/E5 demonstrate only that the *pins* stay green; whether a live verifier elsewhere would
  reject the edits is outside the forbidden legacy path.
- Rewriting continued after 01:16:35: at 04:22Z `corpus/stamps.tsv` (`cb884e2e…`) and
  `corpus/closure-dispositions.json` (`67ac1a42…`) had been rewritten again while the five count
  values stayed 27/45/79/CLEAN/59 and `R23-02` stayed 6 fixed/3 reported. Re-hash before judging;
  the hashes below are the 04:18Z snapshot.
- The tree kept moving through 01:16:35 (final rewrite: closure dispositions, ledger, SCORECARD,
  census, stamps); the values above were re-confirmed at 04:08:02Z, 04:12:01Z and 04:18:00Z.
  Snapshot hashes as of 04:18Z:
  `sources-census.sh 2d1bbbe3…`, `claim-ledger.tsv ed125ca5…`, `stamps.tsv 8089e2bb…`,
  `SCORECARD.md 94a34c9f…`, `source-fetches.tsv 6e26e140…`, `closure-dispositions.json d6239244…`,
  `closure-dispositions.py d79b08a7…`, fixture `adjacency.tsv fa15a53c…`, fixture
  `stamps.tsv 401ebb3c…`. `LOG.md:1193` is stale at `fixed=7 reported=2` at this snapshot.
- Timezone convention: mtimes above are local UTC−03:00; measurement timestamps in the text are UTC.
