# CritSourceRegistry — falsify: six source rows, census 49, W04 12, append-only, provenance, Gate citations

Candidate `62a33b1bd15217ed729df2ca40c8a30aba3076c0` (vs BASE `3553d499…`), committed tree only.
Lane-authored advice, not closure. Impacted axes: freshness (registry/provenance), calibration (self-description).

## Verdict: FAIL (Gate/source-citation sub-clause); counting sub-clauses PASS

| Sub-clause | Result |
|---|---|
| six rows S044–S049, registry 43 → 49 | PASS |
| lane census rows=49, matches ledger pin R21-02 | PASS |
| fleet W04 11 → 12, only new W04 is S045 | PASS |
| append-only: no registry/fetch line removed or changed | PASS |
| provenance present for all 49 rows, six new captures reproduce | PASS |
| Gate/source citations correct | **FAIL** (F1, F2); F3 is an overreach |

## Findings (candidate path:line)

**F1 — Search log says every exclusion has a flip in the Gate; most have none.**
- `corpus/SOURCES.md:87` says: "excluded 13 as rows (decisions with reason and flip in `corpus/lessons/round-28.md` §Gate …)".
- Only `corpus/lessons/round-28.md:37` (Rev. 5 final) and `:38` (PyPA) carry a `Flip:`.
- `:39` Go x/mod/semver, `:40` npm node-semver, `:41` GitHub releases REST, `:42` git-check-ref-format, `:43` CVE-2020-10735 and `:44` the five re-opened feeds have no flip.
- So 6 of the 8 exclusion rows have no flip, covering 11 of the 13 excluded items.
- Counterexample: read `:39`. It has a reason ("Go orders an invalid version below a valid one") but no flip condition.
- Smallest safe correction (append-only): either add a flip to each of `:39–:44`, or append an erratum to the Search log saying flips exist only for `:37–:38`. Do not rewrite line 87.

**F2 — the CVE Gate row cites a URL that did not supply its quote.**
- `corpus/lessons/round-28.md:43` cites `https://nvd.nist.gov/vuln/detail/CVE-2020-10735`. The same cell says that HTML page "answered 403 to the declared profile".
- The quoted NVD description was fetched from `https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2020-10735` (HTTP 200, `.ufo/waves/round-28/build/SrcCve202010735.md:67,73`).
- `cpython#95778` (`…/python/cpython/issues/95778`, SrcCve202010735.md:81) counts toward "Identified 19" at `SOURCES.md:87`, yet the Gate gives it no URL and no separate decision.
- The 19 only reconciles if NVD and cpython are counted as two items: 6 admitted + Rev. 5 + PyPA + Go + npm + REST + git + NVD + cpython + 5 feeds = 19.
- Correction: append the API URL and the cpython issue URL to the `:43` decision. Not a registry change.

**F3 — S049 teaches status facts its own capture does not contain (overreach, fixable).**
- `corpus/SOURCES.md:56` scope says "no Rev. 6 final at fetch". Its anchor says "Rev. 5 final remains the published Part 1". Its teaches says "must cite Rev. 5 final".
- In capture `.ufo/waves/round-28/captures/S049.body`, under rendered-text-v1, `Rev. 5` occurs 0 times and `Supersedes` 0 times. The only `Final` (1 hit) is the CSRC navigation menu. Revision 5 is named only in "proposed changes from Revision 5".
- The page that would support the claim (the Rev. 5 final page) was opened but deliberately NOT REGISTERED at `corpus/lessons/round-28.md:37`. The Gate itself says it "cannot establish currency".
- The page's located facts (Date Published December 5, 2025; comments CLOSED, due February 5, 2026) do support "closed-comment draft".
- "No Rev. 6 final" is an absence inference, not a located quote.
- Correction: mark that clause `[INFERENCE]` in an appended note, or register the Rev. 5 final page. Do not edit the S049 cell in place.

**Checked and holding (no counterexample found):**
- Registry diff BASE → candidate: only rows S044–S049 were added (`SOURCES.md:51–56`). 0 removed lines in `SOURCES.md` and in `source-fetches.tsv`.
- The disposition note at `SOURCES.md:100–106` follows the round-22/23 convention: lead lines `:91–:94` are kept, not deleted.
- Each new row is `A`, `mined`, used by `corpus/lessons/round-28.md`. Recheck is 180d for S044–S046 and 90d for S047–S049, matching Gate `:31–:36`.
- Provenance: 49 fetch rows, no duplicate ids. For S044–S049:
  - row identity sha256(`id\tstatus\turl\n`) recomputes;
  - body sha256 and byte count equal the declared values;
  - the rendered-text-v1 normalized digest equals the declared value;
  - each declared quote is located with `count=1`.
- S044's second quote (640 digits) is also located with `count=1`.
- S044/S046 canonical links point to `/3/builtins/…`, and their titles read "Python 3.15.1 documentation". The 301 from `/3/library/` is evidenced in `build/SrcIntMaxStrDigits.md:9`.
- S047 "previous format" and "July 15, 2026" are each located once. S047's "no audience rule" is consistent with the capture: `audience` occurs 0 times.
- The S049 dates are located: "December 5, 2025" once, "February 5, 2026" twice.
- Paths `SOURCES.md:71–72` and lesson `source:` line `:1` cite all six ids.
- Ledger `R21-02` (`corpus/claim-ledger.tsv:52`) pins exactly the rows=49 verdict I reproduced.
- Timing: captures were fetched 17:27:21Z (14:27 −03:00), after plan corrections `2dfb534` (14:23) and before the candidate commit (14:44).

## Commands run (exit codes)

All runs used read-only exports of the BASE and candidate trees under `/fast/scratch/hyaku/kagi-r28/CritSourceRegistry/`. Nothing ran in the lane checkout.
- `git archive <rev> | tar -x` for BASE and the candidate → 0.
- `bash corpus/sources-census.sh`:
  - BASE → exit 0, `SOURCES_CENSUS: CLEAN (rows=43 A=41 B=0 C=2 queued=1 mined=39 rejected=3 entries_sourced=4 legacy=21 captures=43 inrow=16 inrow_only=0 inrow_nonreproducing=12)`;
  - candidate → exit 0, `SOURCES_CENSUS: CLEAN (rows=49 A=47 B=0 C=2 queued=1 mined=45 rejected=3 entries_sourced=4 legacy=21 captures=49 inrow=16 inrow_only=0 inrow_nonreproducing=12)`.
- `bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --file <tree>/corpus/SOURCES.md --today 2026-10-21`:
  - BASE → exit 0, 11 W04 (identical to `.ufo/waves/round-28/census-start.txt:2–12`);
  - candidate → exit 0, 12 W04, the new one being `S045 duplicate url semver.org/spec/v2.0.0.html across scopes`.
- `… census --file …`: BASE rows 43 / A41 / C2; candidate rows 49 / A47 / C2; missing 0. Both exit 0.
- `python3 -I -B corpus/rendered-text-v1.py digest|locate <S04x.body> …` → exit 0 for all six declared quotes. For absence probes, `count=0` was read from the output.
- `diff` and `sha256sum` against `source-fetches.tsv`, as described above.

## Not checked

- No live re-fetch. My item did not ask for network access, so the 301s, the NVD 403 and the absence of a Rev. 6 final are unverified beyond the committed captures and scout reports.
- Census selftest counts (70 cases), C1/C2 measures and the release-clock: not run (not in scope).
- END census: not committed at the candidate (`plans/round-28.md:78`). Round 27 kept it in `final/`, so I did not count its absence against the candidate; it is outstanding for final.
- Whether the SOURCES contract v1 requires a flip on non-row exclusions: F1 rests only on the registry's own claim at `:87`.
- Tooling installs: none.
- Scratch: both exported trees (213 MB) were removed at completion.
