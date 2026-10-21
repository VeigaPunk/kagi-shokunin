# ScoutS008 — S008 provenance and SC_FETCH legacy-bound attack (round 23)

Seat: `KagiR23.ScoutS008` (leaf falsification, read-only). Scope: S008 only, plus the
`SC_FETCH` path that is supposed to cover it. Read-only on the lane: the only lane write
is this report. No production edits, no `git`/`jj` mutation, no host gate, no legacy
claim-ledger verify, no credential reads, no installs. One `/tmp` copy of the census
was patched for a mutation test and removed; all `/tmp` scratch was deleted.

Verdict in one line: **one concrete blocker found** — the shipped census dies at
`corpus/sources-census.sh:242` with `S007: unbound variable` under `set -u`, before
`SC_FETCH` runs, so the live gate never reaches S008's legacy bound. The bound's
*wording* is honest; its *execution* cannot be observed. The 59-case selftest is green
only because its fixture contains no `supersedes` row.

## 1. Attacked surface

- `corpus/SOURCES.md:14` — S008 row: `rejected`, URL
  `https://raw.githubusercontent.com/getsops/sops/main/README.rst`, quote
  “You can find the SOPS documentation on getsops.io” (§Documentation), in-row
  `Fetch sha256: 63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440`.
- `corpus/source-fetches.tsv` — the 10 declared captures (S017–S026).
- `corpus/sources-census.sh` — the new round-23 `SC_FETCH` code, its claimed
  59-case selftest, and the legacy in-row-pin branch.
- `corpus/lessons/round-23.md:105–110` (D7 disclosure) and `:61` (C2 verification claim).
- `plans/round-23.md:20–32` (C2 scope).

## 2. Exact commands and exits

All commands run with cwd `/home/vgpnk/Projects/shokunin/kagi-shokunin`.

| # | command | exit | observed |
|---|---|---|---|
| 1 | `bash corpus/sources-census.sh` | **1** | stderr `corpus/sources-census.sh: line 242: S007: unbound variable`; no `FINDING`, no `SOURCES_CENSUS:` verdict line |
| 2 | `bash -x corpus/sources-census.sh` | **1** | xtrace reaches `+ [[ -n S007 ]]` then `+ SUPERSEDED[$fid]=1`, then the same unbound-variable abort; no fetch-table loop executed |
| 3 | `bash corpus/sources-census.sh --selftest` | 0 | 59 `: ok`, 0 `: FAIL`, `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` |
| 4 | `grep -n 'S008' corpus/source-fetches.tsv` | 1 | no match — S008 has no capture row |
| 5 | `grep -nF 'raw.githubusercontent.com/getsops/sops' corpus/source-fetches.tsv` | 1 | no capture of the S008 URL |
| 6 | `awk -F'\|' … S008 row …` (gate's own digest/URL extraction) | 0 | `digest=63cb0a46…3440 len=64`, `url=https://raw.githubusercontent.com/getsops/sops/main/README.rst` |
| 7 | `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' https://raw.githubusercontent.com/getsops/sops/main/README.rst` | 0 | 1909 bytes; `sha256sum` = `63cb0a462ce23574365c0b692aa09ea2f632f4b4df2b5f4186d8c004b57e3440` — exact in-row match |
| 8 | `grep -cF 'You can find the SOPS documentation on getsops.io' <fetched body>` | 0 matches | quote is **not** a raw-byte substring |
| 9 | `grep -nF 'You can find the SOPS documentation' <fetched body>` | 0 | body line 18: ``You can find the SOPS documentation on `getsops.io <https://getsops.io/>`_ under ...`` (reST link markup) |
| 10 | `printf '%s' 'You can find the SOPS documentation on getsops.io' \| wc -w` | 0 | 8 words (≤25) |
| 11 | `/tmp` copy of the script with `declare -A SUPERSEDED=()` inserted before the assignment; `bash /tmp/sources-census-s008.sh --root <lane>` | 0 | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`; **no `SC_FETCH` finding** |
| 12 | `git show HEAD:corpus/sources-census.sh \| grep -n SUPERSEDED` | 1 | base commit has no `SUPERSEDED`; `git diff -U0 HEAD -- corpus/sources-census.sh` shows the block added by the round-23 tree |

Line-citation anchors: `set -uo pipefail` at `corpus/sources-census.sh:107`; the new
`SUPERSEDED` block at `:242–246`; the legacy coverage branch at `:300–304`; fixture at
`:345–380`; case table at `:510–570`; header claims “VERDICT (last line, always)” and
“Nothing is skipped” at `:93–99`.

## 3. Finding F1 (blocker, operability): live census aborts before SC_FETCH

`SUPERSEDED` is assigned as an array at `corpus/sources-census.sh:242`:

```bash
while IFS= read -r fid; do [[ -n $fid ]] && SUPERSEDED[$fid]=1; done < <(awk ...
```

There is no `declare -A SUPERSEDED=()` (the other arrays at `:203` and `:229` are
declared). Under `set -u` (`:107`), `SUPERSEDED[$fid]=1` with `fid=S007` is parsed as an
arithmetic subscript naming variable `S007`, not an associative key, and bash aborts:

```
corpus/sources-census.sh: line 242: S007: unbound variable
```

The trigger is in the live registry: `corpus/SOURCES.md:25` (`S019`, teaches
`supersedes S007`) is the first supersedes cell emitted by the awk at `:242–246`. Six
such cells exist (`S019→S007`, `S020→S006`, `S022→S012`, `S023→S013`, `S025→S014`,
`S026→S016`). The abort happens before `if [[ -f $fetchf ]]` at `:247`, so the entire
round-23 `SC_FETCH` check — including the S008 presence check — never executes. The
script's own contract says the verdict is the last line “always” (`:93`) and that
“nothing is skipped” (`:98`); on the live tree neither is true.

`SUPERSEDED` is also dead code: `grep -n SUPERSEDED corpus/sources-census.sh` returns
only the assignment at `:242`; it is never read. The block therefore adds no behavior,
only a crash. `git show HEAD:corpus/sources-census.sh | grep SUPERSEDED` exits 1: this is
a round-23 regression, not a pre-existing gate property.

Why the selftest is green: the fixture registry (`:345–380`) has no `supersedes` cell,
and the 59-case table (`:510–570`) has no supersedes case. The awk at `:242–246` emits
nothing for the fixture, the assignment loop never runs, and the crash path is
unreachable. The suite proves 59 mutations; it does not prove the new supersedes input
path, which is exactly the path that fires on the real registry.

## 4. S008 provenance comparison — what the captures do and do not cover

- **No S008 capture exists.** `corpus/source-fetches.tsv` declares exactly ten rows,
  `S017`–`S026` (`awk` on the table: lines 37–46). `grep 'S008'` and a grep for the S008
  URL both exit 1. There is therefore no declared `representation`, `sha256`, `bytes`,
  `normalization`, `normalized_sha256` or `location` for S008 to compare against.
- **The in-row digest is genuine for the current decoded body.** The exact registered
  URL returned 1909 bytes on 2026-10-21, sha256
  `63cb0a46…3440`, identical to the row. This is a live point observation, not proof of
  the 2026-10-19 fetch; the row itself declares no representation.
- **The in-row quote is rendered text, not a raw-byte substring.** The raw README line
  18 is reST: ``You can find the SOPS documentation on `getsops.io
  <https://getsops.io/>`_ under ...``. The literal quote appears 0 times in the fetched
  bytes; the quote is an 8-word prefix of the rendered sentence. So the digest domain
  (raw decoded body) and the quote domain (reST-rendered text) differ. The legacy bound
  does not compare them, and does not claim to.
- **The captures are not an S008 fallback.** None of S017–S026 has the S008 id or URL;
  the table cannot supply an S008 representation. S008's only provenance carrier is the
  row's own 64-hex `Fetch sha256:`.

## 5. Is the legacy bound honest?

The *stated* bound is accurate. `corpus/source-fetches.tsv:34–36` says legacy in-row
`Fetch sha256:` values (S001–S016) are “historical point observations with undocumented
representation; the census requires their presence but does not compare them to these
captures.” S008 is inside S001–S016, its digest is present and 64-hex, and the gate's
coverage branch (`corpus/sources-census.sh:300–304`) would accept it by presence alone.
The lesson goes further and names the exact S008 caveat: digest reproduces (1909 B,
`63cb0a46…`) but the quote is reST-rendered (`corpus/lessons/round-23.md:105–110`).
Nothing in that wording claims a raw-literal quote, a declared representation, or a
capture comparison for S008. On its own terms, the bound is honest.

The *executed* bound is unobservable. Because of F1, `bash corpus/sources-census.sh`
never gets to `:300–304` on the live registry; the C2 claim at
`corpus/lessons/round-23.md:61` (“census `SC_FETCH` enforces shape, identity, URL,
row-line digest and same-URL agreement; selftest 59 cases”) is only half-observed: the
selftest passes, the live command exits 1 with no verdict. A patched `/tmp` copy (test
11 above) shows the intended behavior — CLEAN, no `SC_FETCH` finding, S008 accepted by
presence — so the defect is the missing declaration/dead block, not an S008 data
misrepresentation.

Secondary observation (not the verdict): the coverage branch at `:300–304` accepts any
row with a 64-hex in-row digest, not only S001–S016. That matches the census header's
“every registry row needs an in-row `Fetch sha256:` or at least one
`corpus/source-fetches.tsv` row” (`:56–70`) and D7's “every row without an in-row pin”,
so it is a documented alternative, not a mismatch; it does mean the “legacy S001–S016”
range in the TSV header is descriptive rather than enforced. S008 is in range, so this
does not affect it.

## 6. Fix / what would change the verdict

- Declare `declare -A SUPERSEDED=()` before `:242` (or remove the dead block, since it
  is never read). Re-run `bash corpus/sources-census.sh`; expected CLEAN with no
  `SC_FETCH` finding, as the patched-copy test showed.
- Add a selftest case whose fixture row teaches `supersedes S00N`; without it the
  supersedes path remains untested and the 59-case green is not evidence for it.
- If the intent of `SUPERSEDED` was to exempt superseded rows from coverage, the array
  must actually be consulted in the `:300–304` loop; today it is write-only dead code.

## 7. Residual unknowns

- I did not re-fetch the 2026-10-19 bytes; the digest match is a 2026-10-21 observation
  of the same moving `main` URL. The row is a point attestation, as stated.
- I did not run a legacy claim-ledger verify or any host-bound row; no such row was
  needed.
- The patched-copy test is outside the lane and was not a shipped-gate run; it isolates
  the one-line cause and confirms S008's intended acceptance, but it is not a claim that
  the patched tree is integrated.

Report: `.ufo/waves/round-23/falsify/ScoutS008.md`
