# CritLegacyBound — round-23 falsification of C2's legacy in-row bound

Seat: critic, leaf, read-only. Target: C2 (freshness/D7). The bound under attack is
"legacy in-row pins (S001–S016) are classified historical and never compared". It appears in:

- `plans/round-23.md:25-26`
- `corpus/sources-census.sh:67-69`
- `corpus/source-fetches.tsv:35-37`
- `corpus/lessons/round-23.md:108-119`

Assigned questions:

- Can a stale in-row pin be reported as satisfying provenance?
- Does the verdict line show which rows rely on historical pins and which on declared
  captures?

**Primary state measured.** Committed `HEAD def9bc2e12534ae2c2492bae1034eb8122c2c179`
(01:11:47), with these file hashes:

- `sources-census.sh` `511deb27…`
- `SOURCES.md` `c6ea91ab…`
- `source-fetches.tsv` `6e26e140…`

Unless marked otherwise, every line number below refers to this state.

## Verdict

Two findings, then two structural defects. The code really does never compare the 16 pins.
The claim built on that bound still overstates what the gate checks.

1. **A stale pin is reported as satisfying provenance. This is the live state.**
   - 12 of the 16 in-row pins do not reproduce under the declared request profile today,
     and the census still prints CLEAN.
   - Five of them are mined, cited rows with no declared capture and no superseding row:
     S001, S002, S003, S004 and S015.
   - The lesson names only S012–S016 as non-reproducing, plus S008 as reproducing
     (`lessons/round-23.md:110-117`). It does not say that S001–S007 also fail to reproduce,
     or that S009–S011 do reproduce.
2. **The verdict line does not show the active/historical split.**
   - Test: delete `corpus/source-fetches.tsv` entirely and give S017–S026 64-zero in-row pins.
   - Result: the census prints a CLEAN line byte-for-byte the same as the honest tree's.
   - Both ledger rows, R21-02 and R21-03, pass when replayed from that tree.
   - So "10 declared + 16 historical" is not measured by any row.
3. **The "historical" class is not closed in code.**
   - The exemption predicate (`sources-census.sh:279`) is "the row has an in-row pin
     string", not "the row is one of S001–S016".
   - A new mined row opened 2026-10-21 passes with only a fabricated pin (CE4).
   - The active row S026, with its declared capture removed, passes because its teaches
     cell *quotes* S016's historical pin (CE8).
   - Legacy rows re-pointed to never-fetched URLs still pass (CE3).
4. **The selftest never exercises the in-row branch.** 0 of 59 fixtures contain
   `Fetch sha256:`. Three mutants of the branch survive all 59 cases, including one where
   in-row pins stop counting at all.

## Measured states (the tree moved and was committed during the audit)

| Time (-03:00) | State | census | `SOURCES.md` | TSV | Live `bash corpus/sources-census.sh` / findings |
|---|---|---|---|---|---|
| 00:58 | worktree | `80966e20…` | `06dde644…` | `ccc9ae6e…` | **exit 1**, `line 242: S007: unbound variable`, no verdict; `--selftest` PASS (59) on the same bytes. Corroborates `MutFetchRemove.md` and `ScoutS001.md`; fixed by 01:02 |
| 01:02:32–01:07:05 | worktree | `24d834cc…` | `06dde644…` | `ccc9ae6e…` → `846b2037…` | exit 0 CLEAN; the full case suite below ran here (snapshots C and D) |
| 01:10:29 | worktree | `6d4190a7…` | `06dde644…` | `7101bdd0…` | CE2, CE4, CE8, Ma and Mb reproduced |
| **01:11:56** | **HEAD `def9bc2e`** | **`511deb27…`** | **`c6ea91ab…`** | **`6e26e140…`** | **exit 0 CLEAN; `--selftest` PASS (59). Every case and mutant below was re-run here and is reported here** |

- **Commits during the audit.** Between the 24d834cc runs and HEAD, commit `638d44c4`
  ("remove cross-capture equality, align case counts") deleted the same-URL agreement code.
  That changes only CE6 (see below). None of the in-row findings depends on it.
- **How experiments ran.** Each run used a copy of the lane's `corpus/` under `/tmp`,
  checked with `verify --root <mutated copy>`. No lane file was written.

## Strongest counterexample

**CE2 — zero declared provenance gives the same verdict, and both ledger rows pass.**

- Setup: on a copy of HEAD's corpus I deleted `corpus/source-fetches.tsv`. In the teaches
  cell of each of S017–S026 I appended ``Fetch sha256: `0000…0` `` (64 zeros).
- Result:

```
$ bash <snapH>/corpus/sources-census.sh verify --root <trees>/CE2
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)   # exit 0
# replayed from the CE2 tree root, exactly as the ledger rows run:
$ bash corpus/sources-census.sh            -> exit 0, the same line; R21-02's regex matches (claim-ledger.tsv:52)
$ bash corpus/sources-census.sh --selftest -> exit 0, SOURCES_CENSUS_SELFTEST: PASS (59 cases)   (R21-03, claim-ledger.tsv:53)
```

- Control CE2c: deleting the TSV without adding pins gives exit 1,
  `FAILED (findings=10 rows=26)` and ten `missing-provenance` findings. So the gate does
  detect absence; it does not detect substitution.
- **What this undercuts.** These statements claim a split that no ledger row measures:
  - R21-02's note "10 declared provenance rows … and 16 historical in-row pins"
    (`claim-ledger.tsv:52`).
  - SCORECARD's freshness cell, which cites R21-03 for "10 declared provenance rows"
    (`SCORECARD.md:842`).
  - The lesson's "16 legacy pins + 10 declared provenance rows" (`lessons/round-23.md:61`).
- The only by-hand number that moves is `grep -c 'Fetch sha256:' corpus/SOURCES.md`
  (16 → 26). That is the lesson's *before* command, not a ledger row.

## Supporting counterexamples (HEAD; `bash <snapH>/corpus/sources-census.sh verify --root <trees>/<case>`)

| Case | Mutation (copy only) | Exit | Last line | Same verdict as honest tree |
|---|---|---|---|---|
| CE3 | S015 and S016 URLs re-pointed to `https://example.invalid/never-fetched` and `…/also-never-fetched` | 0 | CLEAN rows=26 … | yes |
| CE3b | S015 pin replaced by 64 zeros | 0 | CLEAN rows=26 … | yes |
| CE4 | new **mined** S027 (opened 2026-10-21, tier A) with only a zero pin, cited from `onepassword-machine-credentials.md:2` | 0 | `CLEAN (rows=27 A=25 … mined=25 …)` | — (a new row passes) |
| CE4c (control) | the same S027 without the pin | 1 | `SC_FETCH id=S027 missing-provenance` | — |
| CE5 | S015 pin moved from teaches into the scope cell | 0 | CLEAN rows=26 … | yes |
| CE7 | S016 pin set to zeros, while S021/S026 declare `52295218…` for the same URL | 0 | CLEAN rows=26 … | yes |
| **CE8** | S026's TSV row removed; S026 teaches gains "S016's legacy Fetch sha256: `c083fdca…` (full 64) stays historical." | 0 | CLEAN rows=26 … | yes |
| CE9 (control) | S015 pin truncated to 63 hex | 1 | `SC_FETCH id=S015 inrow-digest-malformed` | — |
| CE6 | S021's raw and normalized digests changed (a second declared capture of S026's URL) | 0 at HEAD (1 at `24d834cc`, `same-url-normalized-disagreement`) | CLEAN rows=26 … | yes at HEAD |

CE8 is the one that gives an active row false provenance:

- S026 supersedes S016. With its declared capture removed, a prose mention of S016's
  non-reproducing digest is enough to satisfy S026.
- Why it works:
  - The extractor (`sources-census.sh:239`) takes the first ``Fetch sha256: `<hex>` `` match
    anywhere in the row line (`match($0, …)`).
  - The branch at `:278-284` accepts any 64-hex value (`:280`) and skips the provenance
    requirement (`:281` `continue`).
  - No URL, status, row identity or representation is bound to the pin.

CE6 at HEAD shows that `638d44c4` widened "never compared" from historical pins to all
captures. Two declared captures of one URL may now disagree without any finding. The header
says so (`:64-66`), and so does `source-fetches.tsv:21`. The variables `seen_key`, `FDIG` and
`FNRM` are still declared (`:228-229`) but no longer used.

## Re-measurement of the 16 in-row pins

- Command: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>`,
  2026-10-21T01:00:40-03:00. All 16 GETs exited 0.
- Each digest is the sha256 of the decoded body (`decoded-http-body-v1` domain). The in-row
  pin values are unchanged at HEAD (`grep -c 'Fetch sha256:' corpus/SOURCES.md` → 16).

| id | status | in-row pin | decoded body now | bytes | result | active capture, same URL |
|---|---|---|---|---|---|---|
| S001 | mined | `9f9d7283…` | `e72ab5f3f85e238bc109a1737161eec8425a016f003b7c84be09990d62cf4e0b` | 1228087 | DIFF | — |
| S002 | mined | `68017d4c…` | `9b5dc190d03d118e2e956a83e157477a6d88cf568aeb9179c0c29f717ac4a975` | 1186855 | DIFF | — |
| S003 | mined | `7f6d3b49…` | `2e697420d1d63ed12a32e204501914a7861cbdff3dec432ee382510f306c00c5` | 1369709 | DIFF | — |
| S004 | mined | `19bcf13e…` | `beb67f2d0b8b4e77108766f134fb9bf21943331d9ab4d9bdbe083f655336b055` | 1221922 | DIFF | — |
| S005 | queued | `f7ba8254…` | `1198eb7a7b1a13fad768417d9725ec4ff47b3e0d0e59ad14083804ba03a0d385` | 196082 | DIFF | — |
| S006 | mined | `39a869df…` | `a902cc1b68b68fb383b0be41415381eb7bfcbf38dc6393573cae78988fc49381` | 190261 | DIFF | S020 `53dfeac5…` ≠ now (per-response blog) |
| S007 | mined | `e4aef238…` | `67f690e21116a3644be8cff57058293150b8b03fc305ffa15dc3af63fa43c312` | 1199447 | DIFF | S019 `67f690e2…` = now |
| S008 | rejected | `63cb0a46…` | same | 1909 | MATCH | — |
| S009 | mined | `a840727e…` | same | 29301 | MATCH | — |
| S010 | mined | `fed6b2e1…` | same | 36366 | MATCH | — |
| S011 | mined | `d0ab8b20…` | same | 33153 | MATCH | — |
| S012 | mined | `ec6e7b25…` | `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa` | 386400 | DIFF | S022 `9a65b9d1…` = now |
| S013 | mined | `ae321512…` | `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802` | 261632 | DIFF | S023 `de5f8836…` = now |
| S014 | mined | `e9472324…` | `449ef132ba380948398c03cd96b0a10f80572b734c381897e681b3609d1785d9` | 63046 | DIFF | S025 `449ef132…` = now |
| S015 | mined | `a0a2b227…` | `4e3fdb7d2628f11584690f7eb856186283c688bad09ec8a77e509ab133edbf2f` | 55824 | DIFF | — |
| S016 | mined | `c083fdca…` | `5229521866ce21fa8cd8f8ecf63d696877b8cb0a2ec25e89de683557b385f82c` | 47384 | DIFF | S021/S026 `52295218…` = now |

**Totals.** 12 DIFF, 4 MATCH (S008–S011). All 16 count as provenance-satisfying.

**Same URL, two digests.** In five pairs (S007/S019, S012/S022, S013/S023, S014/S025,
S016/S021+S026), the declared capture equals today's body while the historical pin differs.
One tree therefore holds two different digests for one URL, and nothing reports it.

**Load-bearing rows.**

- `onepassword-machine-credentials.md:3` reads: "recorded their fetched-byte digests in
  `corpus/SOURCES.md`". Its re-verification pointer is `Reverify: R21-02` (`:5`). Every
  digest it relies on (S001–S004, S006, S007) is DIFF.
- `vault-openbao-token-lease-lifecycle.md:3-6` cites S012–S016 with `Reverify: R21-02`;
  all five are DIFF.

**Calibration caveat (no content drift found).** I located each row's quote in today's page
with a rendered-text pass. All 16 quotes were found, with two notes:

- S002's quote is an `<img alt>` attribute, so it is present in the raw HTML only.
- S009's quote only matches after allowing for the space that tag-stripping inserts around
  `updatekeys`.

The 12 DIFFs are therefore representation or page-chrome drift, not evidence that the
knowledge is wrong. They do mean the digests certify nothing anyone can reproduce, and the
gate cannot tell "stale" from "a different representation" from "fabricated" (CE3b).

## Selftest blind spot (QM9, `QUALITY.md:47`)

- `Fetch sha256` appears in `sources-census.sh` only at `:57` (header) and `:239`
  (extractor). The selftest region (`:325` to end) has **0** occurrences. The base fixture
  and all 12 `fetch-*` cases (`:542-553`) use TSV rows only.
- Each mutant below is a copy of HEAD's census. For each I ran
  `bash <mutant> --selftest` and `bash <mutant> verify --root <HEAD copy>`:

| Mutant | Change | Selftest | Live-tree verify | Status |
|---|---|---|---|---|
| Ma | delete `:280` (in-row shape check) | exit 0, PASS (59) | exit 0, CLEAN | **survives** |
| Mb | delete `:281` `continue` (in-row pins no longer satisfy) | exit 0, PASS (59) | exit 1, `FAILED (findings=16)` | **survives the selftest**; only R21-02 notices |
| Md | `:280` accepts hex of any length | exit 0, PASS (59) | exit 0, CLEAN | **survives** |
| Mc (control) | `:283` missing-provenance replaced by `:` | exit 1, FAIL (59 cases, 4 failed) | CLEAN | killed |

At `24d834cc` I also tested Me: the agreement keys included `$fid`. It survived the selftest
(no fixture puts two different ids on one URL). It is moot at HEAD, because the agreement
code was removed.

## Contradictions with the lane's own criteria

- **QM3 and the "nothing is skipped" header.**
  - `QUALITY.md:41` (QM3): "Every skip, unverified branch … is counted in the verdict line
    or fails the run."
  - `sources-census.sh:98-99`: "Nothing is skipped … no `skipped=` count to carry (QM3)".
  - Yet 16 rows pass through a branch that is explicitly never compared (`:67-69`,
    `:278-284`). The CLEAN format (`:94`, `:317-318`, selftest `:492`) has no count for it.
- **Pointer subject (QM11, `QUALITY.md:49`).** `SCORECARD.md:842` cites R21-03 for
  "10 declared provenance rows". R21-03 is a fixture-only selftest and measures nothing
  about the live TSV (see the CE2 replay).
- **D7 wording is now self-exempting.** `source-fetches.tsv:2` reads "bind every mined row
  WITHOUT an in-row pin", and `lessons/round-23.md:106` says the same. CE4 and CE8 show that
  any row can opt out of D7 by carrying a pin string.
- **Stamps.** `stamps.tsv:8,74,75` pin the bytes of `SOURCES.md`, `source-fetches.tsv` and
  `sources-census.sh`. [INFERENCE, not run, because claim-ledger is prohibited] An edit made
  after pinning would show up as stamp drift. A substitution that is present when the pin is
  taken, or one re-pinned under a QM14 journal, would not. Stamps pin bytes; they do not
  check the provenance split.

## Impacted axes

- **Freshness (primary).** Stale or unverifiable pins are accepted as provenance, and the
  declared/historical split is not measured.
- **Calibration.** A score cell's pointer does not measure the number it states (QM11).
  An unverified branch is not counted in the verdict (QM3).
- **Operability.** The selftest leaves the branch that admits 16 of 26 live rows untested.

## Fixable defects versus a tradeoff the judge must reject

**Fixable defects:**

- The historical class is open (CE4, CE8).
- In-row pins are bound to no row identity, URL or column (CE3, CE3b, CE5, CE7).
- The verdict line and R21-02 do not see the split (CE2).
- The selftest skips the in-row branch (Ma, Mb, Md).
- `:98-99`'s QM3 statement is false for SC_FETCH.

**Tradeoff that must be stated, not fixed.**

- The representation behind the legacy digests cannot be recovered, and 12 of 16 do not
  reproduce.
- "SC_FETCH CLEAN" must not be read as "every row has verified or current provenance".
- Five mined, cited rows have only a non-reproducing digest: S001–S004 and S015.
- The lesson's named debt covers only S015 (`lessons/round-23.md:114-117`). S001–S004 are
  the same kind of debt and are not named.

## Smallest safe correction

1. **Freeze the historical set as data.** Use 16 `(id, url, inrow_sha256)` tuples for
   S001–S016, either as rows in `source-fetches.tsv` or as a literal in the census.
   - At `:279`, replace "has a pin" with "is a frozen id whose current URL and pin equal the
     frozen tuple".
   - Any other row with only an in-row pin becomes `SC_FETCH id=X inrow-not-historical`.
   - A changed URL or pin becomes `historical-url-changed` / `historical-pin-changed`.
   - This kills CE2, CE3, CE3b, CE4, CE5, CE7 and CE8.
2. **Expose the split in the verdict.** Add `declared=10 historical=16` to the CLEAN line
   (`:317-318`). Update R21-02's regex (`claim-ledger.tsv:52`) and `CLEAN_LINE` (`:492`)
   with QM14 old/new records. CE2 then fails R21-02, and the QM3 contradiction goes away.
3. **Add selftest cases.**
   - A frozen-historical control that stays CLEAN.
   - A non-historical in-row-only row, which must give a finding.
   - A historical URL re-point, which must give a finding.
   - A historical pin change, which must give a finding.

   These kill Ma, Mb and Md.
4. **Re-point the SCORECARD freshness cell** (`:842`) to the row that measures the split
   (R21-02 after step 2). Name S001–S004 next to S015 as historical-pin debt.

## Bound the claim must state if it is not fixed this round

> SC_FETCH treats any 64-hex ``Fetch sha256: `…` `` string anywhere in a registry row line,
> on any row, as complete provenance. It never compares that value and binds it to no URL,
> status or representation, and the verdict line does not count such rows. "Historical
> S001–S016" is prose, not enforced. R21-02 and R21-03 both pass with zero declared captures.
> Of the 16 in-row pins, 12 (S001–S007, S012–S016) do not reproduce under
> curl-fsSL-compressed-v1 on 2026-10-21, and 4 (S008–S011) do. S001–S004 and S015 are mined,
> cited rows with no declared capture and no superseding row.

## Commands and exits (cwd = lane root unless stated)

| Command | Exit | Result |
|---|---|---|
| `git status --short`; `git diff --stat d218603b…`; `git diff d218603b… -- corpus/SOURCES.md corpus/claim-ledger.tsv corpus/claim-ledger.sh`; `git log -3`; `git show --stat HEAD` (all read-only) | 0 | round-23 tree, then commits `284d40e0`, `638d44c4`, `def9bc2e` |
| `bash corpus/sources-census.sh` @ `80966e20` | 1 | `line 242: S007: unbound variable`, no verdict |
| `bash <snapshot copy>/corpus/sources-census.sh --selftest` @ `80966e20` | 0 | PASS (59 cases) |
| `bash corpus/sources-census.sh` @ `24d834cc` (01:02:32) and @ `6d4190a7` (01:09:53) | 0; 0 | CLEAN rows=26 … legacy=21 |
| `grep -c 'Fetch sha256:' corpus/SOURCES.md`; `grep -c '^S0' corpus/source-fetches.tsv` | 0; 0 | 16; 10 |
| 16× `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <S001…S016 url>` | 0 (each) | see the re-measurement table |
| `bash <snapH>/corpus/sources-census.sh verify --root <trees>/{P0,CE2,CE2c,CE3,CE3b,CE4,CE4c,CE5,CE6,CE7,CE8,CE9}` @ HEAD | 0/0/1/0/0/0/1/0/0/0/0/1 | as tabled above |
| `bash <snapH>/corpus/sources-census.sh --selftest` @ HEAD | 0 | PASS (59 cases) |
| CE2 replay (cwd = CE2 tree): `bash corpus/sources-census.sh`; `bash corpus/sources-census.sh --selftest` | 0; 0 | R21-02 line; PASS (59) |
| `bash <mutants>/{Ma,Mb,Mc,Md}.sh --selftest` @ HEAD | 0/0/1/0 | as tabled above |
| The same case suite and Ma–Me @ `24d834cc` (snapshots C and D) | same as HEAD, except CE6 → 1 | superseded by the HEAD run |

- **Orchestration.** I created the mutated copies and invoked the commands from a Python
  subprocess, with the same argv as shown.
- **Lane writes.** None, except this report.
- **Scratch.** Scratch directories `/tmp/critlegacy.QX7XDu`, `/tmp/critlegacy2.rx70ze0z` and
  `/tmp/critlegacy3.lmve__uq` were all removed after use (`test ! -e` checked).
- **Not run.** No installs, no pacman, no claim-ledger `verify`/`cells`/rows, no host gates,
  no credential reads.
- **Tools.** No tool was installed or updated; the operator pause forbids it.
