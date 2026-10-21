# ConnSourceGate — SC_FETCH vs SOURCES contract v1 and the fleet source-gate chokepoints

**Seat.** Falsification, round 23, leaf (no dispatch). Read-only on the lane; all mutations were made on
copies under `/tmp` and passed to the gate with `verify --root`. No network fetch was needed.

**Stamp.** Measured 2026-10-21T04:09Z (01:09 −03) against the working tree; the last artifact change in the table is 01:08:16. SHA-256 of the bytes measured:

| artifact | sha256 (first 16) | mtime (−03) |
|---|---|---|
| `corpus/sources-census.sh` | `24d834cc85344b76` | 01:02:21 |
| `corpus/SOURCES.md` | `06dde644801bee13` | 00:49:17 |
| `corpus/source-fetches.tsv` | `846b203734bcddce` | 01:06:58 |
| `corpus/lessons/round-23.md` | `cf79cd0c85d981a0` | 01:08:16 |
| `corpus/claim-ledger.tsv` | `0d3d75008122c49c` | 01:02:56 |
| `SKILL.md` | `982ae1102f816063` | — |
| `SCORECARD.md` | `488fc9940f296d47` | — |
| `LOG.md` | `b7d330298e82b15c` | 01:02:31 |

The tree moved under this seat during the attack (F5, and the 7→9 URL correction noted in F1). Every
finding below names the bytes it was run on; the snapshot hashes are reproducible.

**Post-stamp revision (measured 2026-10-21T04:11:56Z; last change 01:11:27).** The tree changed twice while
this report was written. At `corpus/sources-census.sh` `511deb2730614663…`, `corpus/source-fetches.tsv`
`6e26e14032729070…`, `corpus/lessons/round-23.md` `49632920e1118956…` the cross-capture equality code is
**withdrawn**: the gate header now reads “Captures are point attestations: no cross-capture equality is
enforced, only one provenance row per id” (`sources-census.sh:64-66`), matching `source-fetches.tsv:19-21`
and `round-23.md:53-54`; the lesson records the removal as M23-1 (`round-23.md:145`). Re-measured on those
bytes: gate CLEAN exit 0; selftest PASS 59 exit 0; **E6 now exits 0 CLEAN** (no agreement check); E3 and E4a
are unchanged. `corpus/SOURCES.md` moved to `c6ea91ab24683522…` in the same window (prose only: S024 is
called a new frontier row; S001 at `:7` and the 16 in-row pins are unchanged). The dead
`FDIG=() FNRM=()` declarations remain at `sources-census.sh:229`; the 12 fetch cases still have no
volatile-representation fixture row.

## What I attacked

`SC_FETCH`, the round-23 fetch-provenance addition in `corpus/sources-census.sh` (block starts
`corpus/sources-census.sh:226`, documented at `:56-69`), and its sidecar `corpus/source-fetches.tsv`.
The question posed: does the new check follow SOURCES-CONTRACT-v1, or establish a second method?
Comparison surfaces: the frozen contract (`/home/vgpnk/Projects/shokunin/.ufo/waves/kaika/SOURCES-CONTRACT-v1.md`),
the fleet contract census (`/home/vgpnk/Projects/shokunin/scripts/sources-census.sh`), the lane-local
frozen census in another lane (`game-dev-2d-shokunin/reports/round-105/r105-sources-census.sh`), and the
contract's named research method (`chousa-shokunin/SKILL.md`).

## Commands and exits

| # | command (cwd = lane root unless noted) | exit | result |
|---|---|---|---|
| 1 | `bash corpus/sources-census.sh` | 0 | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` |
| 2 | `bash corpus/sources-census.sh --selftest` | 0 | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` |
| 3 | `bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | 0 | 7×`W04` + `kagi ok …/corpus/SOURCES.md` |
| 4 | `grep -c 'Fetch sha256:' corpus/SOURCES.md` | 0 | `16` |
| 5 | `grep -c '^S0' corpus/source-fetches.tsv` | 0 | `10` |
| 6 | `awk -F'\t' '…{print $4}' corpus/source-fetches.tsv \| sort -u \| wc -l` | 0 | `9` distinct URLs (S017–S023 alone = 7) |
| 7 | recompute `sha256(id\tstatus\turl\n)` for all 10 rows vs column 3 | 0 | **10/10 match** |
| 8 | `bash /tmp/r23-snap-80966e2….sh verify --root <lane>` (00:57:55 bytes) | **1** | stderr `line 242: S007: unbound variable`; **no verdict line** |
| 9 | `bash /tmp/r23-snap-80966e2….sh --selftest` (same bytes) | **0** | `PASS (59 cases)` |
| 10 | `bash -uc 'declare -A A=(); while read -r x; do UNDECLARED[$x]=1; done <<< S007'` | 127 | `S007: unbound variable` (minimal repro) |
| 11 | E3: append a fabricated S001 capture to a `/tmp` copy, then `verify --root` | **0** | `CLEAN (rows=26 …)` despite S001's in-row digest `9f9d7283…` |
| 12 | E4a: set S024 registry status `mined`→`queued` in a `/tmp` copy | **1** | `findings=2`: `status=mined registry=queued`, `row-identity-digest-mismatch` |
| 13 | E4b: also set the TSV status cell to `queued` | **1** | `findings=1`: `row-identity-digest-mismatch` |
| 14 | E4c: also regenerate column 3 | **0** | `CLEAN (rows=26 … queued=2 mined=23 …)` |
| 15 | E6: add an S016 capture of S021's URL with a different `normalized_sha256` | **1** at `24d834c`; **0** at `511deb27` | `same-url-normalized-disagreement …` then CLEAN after the check was withdrawn |

E3/E4/E6 were run against fresh copies of `corpus/` under `/tmp` with the current gate script
(`24d834cc…`) and TSV (`846b2037…`), and re-run after the 01:06:58 TSV rewrite; the lane was never written. Command 8/9 used an exact byte snapshot of the
00:57:55 script (`/tmp/r23-snap-80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781.sh`).

## Findings

### F1 — Contract form is preserved; in substance it is a second provenance method (verdict, not a defect by itself)

Contract v1 is **frozen** (`SOURCES-CONTRACT-v1.md:1`), declares `## Registry  the one table below`
(`:13`), fixes the row-grounding record as “The round lesson's `## Gate` records … the URL, the access
date, and a ≤25-word quote with its location” (`:45-48`), allows in-place change of only
`status`/`recheck`/`used-by` (`:49-51`), and ships exactly seven census one-liners (`:64-81`) with no
fetch, digest, or representation clause anywhere.

SC_FETCH does **not** replace or alter that census: the seven awk programs are still embedded verbatim
(`corpus/sources-census.sh:7-9`), the 11-column table still passes `NF==13` (row 1 above; fleet gate row 3,
exit 0), and the gate itself labels the block “fetch provenance (**round 23**, routed D7)” (`:56`).
So the check is an **addition**, consistent with the gate's stated design (“adds the cross-file checks the
one-liners cannot make”, `:9-12`).

In substance, though, it is a **second method**, not a contract-v1 check:

- a new sidecar artifact with its own 16-column schema (`source-fetches.tsv:4-30`) outside the contract's
  four-section Shape (`SOURCES-CONTRACT-v1.md:9-16`);
- a second digest vocabulary (`decoded-http-body-v1`, `decoded-http-body-volatile-v1`, `rendered-text-v1`,
  `curl-fsSL-compressed-v1`) defined nowhere else in the fleet — `grep -rl
  'decoded-http-body\|rendered-text-v1\|curl-fsSL-compressed-v1'` over all lanes returns only
  `kagi-shokunin/corpus/{SOURCES.md,sources-census.sh,source-fetches.tsv}` and the round lesson;
- a second copy of rule 1's four grounding fields (URL, fetch date, quote, location: `source-fetches.tsv:9,14,25-30`)
  with no reconciliation to the lesson or to the row's `teaches` cell. Measured: 7 of the 10 TSV quotes
  (S017–S023) are **not** present in their current registry cells; the lesson calls these reopen quotes
  with “fields unchanged”, so the divergence is deliberate, but the gate checks neither that the TSV quote
  matches the row nor that it appears on the page;
- a new mutation duty on a field contract rule 2 says changes in place (F4).

Contract rule 3 (“No second method”, `:52-55`) is scoped to **claim admission** (`QUALITY.md`) and the
**research method** (`chousa-shokunin/SKILL.md:20`: claim → source → the source's own evidence), so this is
not a literal rule-3 violation. It is an **undeclared adjacent method**: the lane's `SKILL.md` source row
still describes only the citation census (`SKILL.md:47`). Other lanes do not do this —
`game-dev-2d-shokunin/reports/round-105/r105-sources-census.sh:2` explicitly freezes at “SOURCES-CONTRACT-v1
§Census” and says “NOT a verdict gate”; the fleet gate's toolset (`scripts/sources-census.sh:3,24-33`) is
E01–E12/W01–W04 with no digest concept.

**Verdict:** follows contract v1 at the registry boundary; establishes a second, lane-local provenance
method alongside it. Not forbidden, but it must be declared as such and must not contradict its own schema.

Note on the routed claim: C2 was given to this seat as “10 declared captures S017-S026 over 7 URLs”.
Measured: **9** distinct URLs (row 6). The current lesson (`round-23.md:174`), `LOG.md:1202` and
`SCORECARD.md:840` now say nine; earlier bytes of the lesson said seven and were corrected at 01:02:56.
The routed “7” is false; “7” is the S017–S023 subset.

### F2 — Contradiction at the 24d834c stamp: the lesson and TSV said no cross-capture equality, the code enforced it (withdrawn in 511deb27)

- `corpus/lessons/round-23.md:50-54`: “A provenance digest — raw or normalized — is a point attestation …
  never a content-drift pin … page chrome can move the normalized digest between days … so **no
  cross-capture equality is enforced**.” The same lesson's mistake table says the opposite:
  `round-23.md:145` — “same-URL captures must agree”.”
- `corpus/source-fetches.tsv:19-21`: “… the normalized digest is a more stable point attestation, still
  chrome-sensitive, never a drift pin. **No cross-capture equality is enforced.**”
- `corpus/source-fetches.tsv:32-33`: “A digest here is a point attestation … **never a content-drift pin**.”
- The code added at 00:57:55 does the opposite: `corpus/sources-census.sh:279-283` fails
  `same-url-digest-disagreement` for any two non-volatile captures of one URL, and `:285-290` fails
  `same-url-normalized-disagreement` for any two `rendered-text-v1` captures of one URL — regardless of
  fetch date. The gate header agrees with the code (`:64-66`), so the gate is internally consistent and the
  **lesson and sidecar header are the stale side**.

Reproduced: E6 (row 15) → exit 1, one finding, on a fabricated second capture of S021's URL. Consequence:
a future honest recapture of a volatile page whose chrome moved the normalized text (the lesson's own S017
sidebar example) now fails the gate, which is exactly the “content-drift pin” the artifacts promise not to
impose. This was a freshness-axis self-contradiction, not just prose drift. **Final revision:** the code side
changed, not the prose — `511deb27…` removes both comparisons and keeps the header/TSV/lesson bound; E6 then
exits 0 CLEAN. F2 is resolved at the cost of the now-dead `FDIG`/`FNRM` arrays (`sources-census.sh:229`).

### F3 — The two provenance channels are unreconciled; a contradictory capture passes CLEAN

`SC_FETCH` accepts **either** an in-row `Fetch sha256:` **or** a TSV row (`corpus/sources-census.sh:56-58`,
coverage loop `:294-300`), and explicitly never compares the two (`:67-69`). E3 (row 11): a fabricated
capture for S001 with `sha256` all-zero, `fetched 1999-01-01`, `final_url https://evil.example/x`, quote
`lorem ipsum dolor sit amet`, location `made-up-section` **passes CLEAN**, while S001's in-row digest is
`9f9d7283…` (`corpus/SOURCES.md:7`). Two contradictory digests for one registry row, one green verdict.

The verdict exposes only `rows=26`: it does not say 16 rows are covered by unverified historical pins and
10 by declared captures. That split is assembled outside the gate by `grep` (rows 4–5), so a CLEAN verdict
cannot tell a reviewer which channel covered which row.

### F4 — `status` is inside `row_identity_sha256`, so a contract-sanctioned status change fails the gate

`source-fetches.tsv:6-8` defines the identity as `sha256(id<TAB>status<TAB>url<LF>)`; the gate recomputes it
from the **registry** status (`corpus/sources-census.sh:250-252`). Contract rule 2 permits exactly this
in-place change (`SOURCES-CONTRACT-v1.md:49-51`). Measured: E4a (row 12) → 2 findings; E4b (row 13) → 1
finding after updating the TSV status; E4c (row 14) → CLEAN only after regenerating the digest. So a
contract-legal `mined`→`queued` edit now carries an undeclared second duty (edit the sidecar and recompute a
digest), and the failure `row-identity-digest-mismatch` does not say which of id/status/url moved. The
TSV header documents the digest inputs, but neither the contract nor the census `FINDINGS` block does.

### F5 — Observed hard failure: the gate could not run on the real tree, and the 59-case selftest could not see it

Between 00:57:55 and 01:02:21 the working tree contained a gate that **crashed on every real-tree run**:
snapshot `80966e2…` exits 1 with `line 242: S007: unbound variable` and prints **no verdict**. Root cause:
the edit replaced `declare -A … SUPERSEDED=()` with `FDIG=() FNRM=()`, but left the
`SUPERSEDED[$fid]=1` fill in place; under `set -u` an undeclared subscript is arithmetic, so the superseded id
`S007` is an unbound variable (minimal repro, row 10). The path only executes when the registry contains a
`supersedes S0NN` teaches cell, which the real registry does (`SOURCES.md:25-32`: S019/S020/S022/S023/S025/S026) and the selftest fixture
does **not** — hence `--selftest` printed `PASS (59 cases)` on the exact broken bytes (row 9). It was fixed
at 01:02:21 (`24d834cc…`) by deleting the dead loop (diff: snapshot lines 239-243 removed).

The defect as delivered is fixed; the durable finding is the **coverage gap**: the selftest never exercises
a registry row carrying `supersedes`, so it cannot distinguish a gate that runs from one that aborts on the
real registry. The 59-case count is not a runnability proof for the real tree.

### F6 — The 12 SC_FETCH cases do not reach the branch the real data uses

The block has **24** distinct failure details (`grep -o 'finding SC_FETCH "[^"]*"'`). The case table
(`corpus/sources-census.sh:558-569`) has **12** fetch cases, covering 12 details; 12 details have no case:
`line=… nf=`, `final-url`, `http-status`, `request-profile`, `fetched`, `representation`, `bytes`,
`revision`, `moving-ref-revision`, `normalized-digest-not-applicable`, `same-url-normalized-disagreement`,
`inrow-digest-malformed`. In particular:

- **0 of 4** fixture rows use `decoded-http-body-volatile-v1` (`:392-395` all use the non-volatile form),
  while **10 of 10** real captures are volatile. The volatile branch (`:279`) and the normalized-agreement
  branch (`:285-290`) — the only same-URL logic that runs on real data — have no fixture at all.
- `m_fetch_disagree` (`:442-447`) exercises only `same-url-digest-disagreement` (non-volatile raw digest).
- The header's “one or more mutations per finding id” (`:101-104`) holds only at the `SC_FETCH` id level,
  not per check.

This is a calibration defect in the claim “59-case selftest” only if the claim implies per-check proof; it
does not prove the two newest checks (added 00:57:55) can fail. **Final revision:** `511deb27…` removes the
`same-url-*` findings, leaving **22** details; `fetch-disagree` now only reproduces `duplicate-provenance`
(findings=1), duplicating `fetch-duplicate`, and `FDIG`/`FNRM` are declared but never used. The
volatile-representation fixture gap and 11 uncovered details remain (shape/NF, final-url, http-status,
request-profile, fetched, representation, bytes, revision, moving-ref-revision,
normalized-digest-not-applicable, inrow-digest-malformed).

### F7 — D1's W04 count is stale (five vs seven)

`corpus/lessons/round-23.md:66` says “The census prints **five** W04 duplicate-URL warnings”, and `:177-178`
says “census at round end must exit 0 with the **same** W04 warnings”. The fleet gate prints **seven**:
S019, S020, S021, S022, S023, **S025, S026** (row 3). The paragraph's own prose names S025/S026 as further
correction rows, so the count is internally stale, not a different measurement. Five was correct at round
start (23 rows); it is false for the 26-row round-end registry.

## Confirmations (what held)

- **10/10** `row_identity_sha256` values recompute exactly as `sha256(id\tstatus\turl\n)`; the documented
  identity definition matches the data.
- The contract census is intact: 26 rows, `NF==13` clean, fleet `validate` exit 0 (W04 only).
- Both sides of the agreement question were observed: at `24d834c` E6 exited 1 with
  `same-url-normalized-disagreement`; at `511deb27` the same probe exits 0 CLEAN.
- `verify` is read-only: no `curl`/`wget` invocation; writes exist only in the selftest fixture path
  (`mktemp -d`, `corpus/sources-census.sh:101-102,343,348-446`).
- Counts: 16 in-row pins, 10 declared captures, 9 distinct capture URLs (matches the corrected lesson/LOG/
  SCORECARD text, not the routed “7”).

## Bound the claim must state

1. **Declaration consistency, not capture truth.** `SC_FETCH` never fetches, never recomputes a digest from
   bytes, never checks the quote occurs on the page, and never compares the two channels. A CLEAN verdict is
   compatible with a fabricated capture and with two contradictory digests for one row (E3).
2. **Channel split is invisible in the verdict.** `rows=26` does not disclose 16 legacy pins vs 10 declared
   captures; the split is an external `grep`.
3. **`status` is bound.** A contract-rule-2 status change requires editing the TSV status *and*
   regenerating `row_identity_sha256` (E4a→E4c), a duty stated only in `source-fetches.tsv:6-8`.
4. **Cross-capture equality.** At `24d834c` the code enforced raw/normalized equality contrary to
   `source-fetches.tsv:19-21` and `round-23.md:50-54`; at `511deb27` both comparisons are removed and E6 is
   CLEAN. The claim must say explicitly: no cross-capture equality is enforced. If an agreement rule is
   reintroduced, the sidecar header, the lesson bound and a fixture case must change in the same edit.
5. **The 59 cases do not cover the volatile representation or `same-url-normalized-disagreement`** (0/4
   fixture rows volatile; 10/10 real captures volatile). The count is not a per-check proof.
6. **Point attestation only.** Even where agreement is enforced, it is a point attestation at the declared
   fetch date, not deployed-product truth.

## Proposed move (bounded, for the integrator)

**Make the provenance declaration self-describing and test the branch the real data uses.** One coherent
change set:

- Remove the now-dead `FDIG=() FNRM=()` declarations (`sources-census.sh:229`) so the gate carries no array
  the header says it does not use (the 511deb27 withdrawal left them behind).
- Add one fixture row using `decoded-http-body-volatile-v1` and one case for the `representation` check
  (the field that distinguishes 10/10 real captures from 4/4 fixture rows), plus a `supersedes S0NN` row
  for the path that crashed in F5. This makes the 59 count cover the branch the real data uses.
- Print a non-verdict `PROVENANCE declared=10 legacy=16` line before the verdict, so the channel split is
  visible without changing the pinned `SOURCES_CENSUS: CLEAN` line (`R21-02` stays green).

Axes: freshness improves (the claim and the bound become true and the real branch is tested); operability
improves (no crash class, no cross-day false positive, no re-pin of R21-02); calibration is not harmed — the
gate's guarantee is narrowed and stated, not widened.
