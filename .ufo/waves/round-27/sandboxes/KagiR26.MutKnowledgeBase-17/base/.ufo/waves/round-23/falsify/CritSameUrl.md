# CritSameUrl: round-23 falsification of the same-URL agreement rule

Seat: `KagiR23.CritSameUrl` (critic). Judged on calibration, freshness and operability.

**What I attacked.** The C2/D7 same-URL agreement rule in `corpus/sources-census.sh`
`SC_FETCH`, against the data in `corpus/source-fetches.tsv`. I also checked how S021/S026
and S019/S007 are handled.

**Constraints observed.** I made no production edits and installed nothing. Every scratch
tree was created under `mktemp -d` (`/tmp/critsameurl-*`) and has been removed. All fetches
used the lane profile `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation
verification)'`.

## Verdict on the current tree (census `511deb27…`, 01:11:26 -03:00)

The census changed five times during my run, and the same-URL rule went through three
states:

- It was added, and that edit crashed the gate on the real tree.
- It was then measurable. In that state I found seven ways two contradictory captures of
  one URL both pass, plus a false failure on honest recaptures.
- It was then **removed** while the wave was running.

The current claim text is now consistent across the gate, the TSV and the lesson: no
cross-capture equality is enforced. That consistency is new:

- Gate `sources-census.sh:64-66`: "Captures are point attestations: no cross-capture equality is enforced, only one provenance row per id".
- `source-fetches.tsv:19-21`: "No cross-capture equality is enforced".
- Lesson `round-23.md:54` and `:61`.
- Lesson M23-1 at `:145`, which now reads "a cross-capture equality rule punished honest recaptures … no cross-capture equality is enforced".

So the claim "same-URL captures must agree" is withdrawn, not proven. What remains open in
the current tree:

1. **W04 count is stale (calibration, open).** The lesson quotes five W04 lines (`round-23.md:66-72`)
   and says the round-end census must show "the same W04 warnings" (`:177-178`). The C1 record D1
   (`closure-dispositions.json:52`, "the five W04 … verbatim") says the same.
   - Measured: 5 W04 lines at base `d218603` and **7 at round end** (S025 and S026 each add
     one; commands 6 and 7).
   - C1's pointer check only resolves the heading, so it cannot see that the content is
     wrong.
2. **The "historical in-row" exemption is enforced only in prose (freshness, open).** The
   bound is documented as S001–S016 (`source-fetches.tsv:35`; gate `:67-69`), but the code
   accepts an in-row `Fetch sha256:` on *any* id (extraction at `:239`; coverage loop
   `:278-284`, which `continue`s at `:281` once the pin passes a shape check).
   - A new row with only a 64-hex in-row pin skips representation, profile, final URL,
     quote and normalization checks.
   - Measured on `511deb27…`: l2 exit 0 CLEAN, r8 exit 0 CLEAN rows=27.
3. **Same-day contradictions now pass (tradeoff the judge must bound).** Removing all
   equality also dropped the sound case.
   - r4b: S026 with raw `ff…` and normalized `ee…` against S021's `52295218…`/`ed949658…`,
     both fetched 2026-10-21 under `rendered-text-v1`. Result: exit 0, CLEAN.
   - The lesson's own evidence says normalized text is stable within one day; S020 gave
     `20b4fd86…` twice (`round-23.md:49-50`). Two such same-day rows cannot both be true
     attestations.
4. **The selftest kept the case name but lost its purpose (calibration, minor).**
   - `fetch-disagree` (`:426-431`, case `:553`) now expects `findings=1`. Its only finding
     is `duplicate-provenance`, the same mechanism as `fetch-duplicate` (`:552`), so the
     59-case count includes a misnamed duplicate.
   - `seen_key` (`:228`) and `FDIG=() FNRM=()` (`:229`) are left over from the removed rule.
5. **The selftest fixture still lacks real-tree shapes (operability, open).** It has no
   `supersedes` registry row, no volatile row and no same-URL pair with distinct ids. The
   missing `supersedes` row is the gap that hid the crash in F1 below.

## Timeline (measured; the target moved while I tested it)

| census sha256 | when (-03:00) | same-URL rule | real-tree `bash corpus/sources-census.sh` | `--selftest` |
|---|---|---|---|---|
| `80966e20…` (mtime 00:57:55) | 01:00–01:01:22 | present (raw for non-volatile, keyed `url\|rep`; normalized for rendered-text-v1, keyed `url\|norm`) | **exit 1**, stderr `corpus/sources-census.sh: line 242: S007: unbound variable`, **no verdict line** | exit 0, PASS (59) |
| `24d834cc…` | 01:05:46, 01:07:54 | present; the crash was fixed by deleting the never-read `SUPERSEDED` loop (5 lines) | exit 0, CLEAN rows=26 | exit 0, PASS (59) |
| `6d4190a7…` | ~01:08 | (seen only by sha) | — | — |
| `6f202fce…` | 01:10:40–01:10:58 | **removed** | exit 0, CLEAN rows=26 | **exit 1**, `case fetch-disagree: FAIL (… want SC_FETCH findings=2; last=… findings=1 …)`, `FAIL (59 cases, 1 failed)` |
| `511deb27…` | 01:11:26 | removed; `fetch-disagree` re-expected at `findings=1` | exit 0, CLEAN rows=26 | exit 0, PASS (59) |

Other files at 01:11:26:

| file | sha256 |
|---|---|
| `source-fetches.tsv` | `6e26e140…` (data rows unchanged; only comments changed) |
| `round-23.md` | `03d17afb…` |
| `claim-ledger.tsv` | `59869459…` (the R21-03 note now says "twelve SC_FETCH coverage/shape cases") |
| `closure-dispositions.json` | `00fbf48d…` (unchanged) |
| `SOURCES.md` | `06dde644…` (unchanged) |

**F1, transient blocker.** At `80966e20…`, line 229 dropped `SUPERSEDED=()` from the
`declare -A` line while the loop still ran. S019's `supersedes S007` cell was then read as
an arithmetic subscript under `set -u`, and the gate died. That broke the header contract
"VERDICT (last line, always)" (`:93`). Command 3 reproduces the mechanism. The 59-case
selftest stayed green because the fixture has no `supersedes` row.

**Transient selftest failure.** At `6f202fce…` the live selftest exited 1. The ledger row
R21-03 expects `PASS (59 cases)`, so it would have failed if run at that moment.

## Attack on the rule as shipped mid-wave (`24d834cc…`)

These measurements explain why the rule failed. They also give the design a sound rule
would need. In every case the comparison is between two registry ids that share one URL.

**Table A: minimal fixture.**
- Registry: a valid `SOURCES.md` with all four sections and two tier-A mined rows,
  S101/S102, both used by `corpus/knowledge/e1.md`.
- Entry: `e1.md` cites both and carries `verified-at:` and `recheck:`.
- TSV: 16-column rows with correct row-identity digests, both on
  `U=https://example.invalid/page`.
- Abbreviations: NV = `decoded-http-body-v1`, VO = `decoded-http-body-volatile-v1`.

| case | S101 vs S102 | exit @`24d834cc` | exit @`511deb27` |
|---|---|---|---|
| c1 control | NV, raw differs | 1 `same-url-digest-disagreement` | **0 CLEAN** |
| c2 control | VO, normalized differs | 1 `same-url-normalized-disagreement` | **0 CLEAN** |
| a1 volatile bypass | VO, raw `aa…` vs `bb…`, same normalized | **0 CLEAN** | 0 |
| a2 | VO, same raw, bytes 47384 vs 1 | **0 CLEAN** | 0 |
| a3 representation keying | NV raw X vs VO raw Y | **0 CLEAN** | 0 |
| a4 normalization keying | VO+rendered N1 vs VO+`raw-literal-v1` raw Y | **0 CLEAN**, nothing compared | 0 |
| a5 | NV+rendered vs VO+raw-literal | **0 CLEAN** | 0 |
| a6 / a7 | NV, same raw; status 200 vs 404 / final URL elsewhere | **0 / 0 CLEAN** | 0 / 0 |
| a8 URL string | `…/page/` vs `…/page`, same final URL, raw and normalized differ | **0 CLEAN**; fleet census W04 calls it the same URL | 0 |
| a9 URL string | `…/page#one` vs `…/page#two`, same final URL | **0 CLEAN**; fleet W04 same URL | 0 |
| d1 / d2 date-blind | 2026-10-21 vs 2026-11-30 honest recapture, VO-normalized / NV-raw | **1 / 1** false failure | 0 / — |
| l2 in-row path | S101 has only an in-row `Fetch sha256: ee…`; S102 has a TSV capture | **0 CLEAN** | **0 CLEAN** |
| l1 | as l2, with S102 `supersedes S101` | 0 (crash at `80966e20`: `line 242: S101: unbound variable`) | — |

**Table B: copies of the real tree** (`cp -R corpus` with mutations to the TSV or registry).

| case | mutation | @`24d834cc` | @`511deb27` |
|---|---|---|---|
| r0 | none | 0 CLEAN rows=26 | 0 CLEAN rows=26 |
| r1 | S026 raw `ff…`, bytes 999 | **0 CLEAN** | — |
| r2 | S026 set to NV, raw `ff…` | **0 CLEAN** (S021 is VO, so S026 is alone in its key) | 0 (raw+normalized variant) |
| r3 | S026 raw `ff…`, `raw-literal-v1`, normalized `-` | **0 CLEAN** | — |
| r4 | S026 normalized `ee…`, same date | 1 `id=S026 same-url-normalized-disagreement` | **0 CLEAN** |
| r4b | S026 raw `ff…` + normalized `ee…`, same date | — | **0 CLEAN** |
| r5 | S026 honest recapture on 2026-11-30, normalized changed | **1 false failure** | — |
| r6 / r7 | S026 status 404 / final `https://evil.invalid/x`, same digest | **0 / 0 CLEAN** | — |
| r8 | new S027, same URL, only an in-row `Fetch sha256: ff…` | **0 CLEAN** rows=27 | **0 CLEAN** rows=27 |
| r9 | new S027 `https://openbao.org/docs/concepts/tokens` (live 301 to the S021/S026 page) with an NV capture contradicting both raw and normalized | **0 CLEAN** rows=27; fleet `W04 S027 duplicate url openbao.org/docs/concepts/tokens` | — |

**Table C: did the selftest discriminate the rule at `24d834cc`?** Each mutant is a scratch
copy run with `--selftest`.

| mutant | result |
|---|---|
| M1: normalized comparison neutralized | PASS (59), survives |
| M3: volatile exemption removed | PASS (59), survives |
| M4: representation dropped from the key | PASS (59), survives |
| M2: raw comparison neutralized | FAIL, killed by `fetch-disagree` |
| M5: whole same-URL block deleted | FAIL, killed by `fetch-disagree` |
| `80966e20` as shipped | PASS (59) while the real tree crashed |

**What the rule did wrong:**
- **Volatile bypass.** The raw comparison applied to 0 of the 10 rows, because all 10
  rows declare VO with `rendered-text-v1`.
- **Keying.** Mixing representations, or using `raw-literal-v1`, escaped comparison
  entirely.
- **URL identity.** The key was the exact registered URL string, while the fleet census
  `url_of` (`scripts/sources-census.sh:600-605`) canonicalizes URLs. That gives two
  conflicting definitions of "same URL".
- **No date in the key.** Honest recaptures were punished, which the owner now records as
  M23-1.

## S021/S026

- **Data accurate.** I fetched `https://openbao.org/docs/concepts/tokens/` twice at 01:02.
  Both responses were byte-identical and equal to the TSV: `5229521866ce…`, 47,384 B, final
  URL equal, status 200.
- **Normalization reproduces.** My rendered-text-v1 implementation gives `ed949658…` under
  three whitespace variants, matching both rows.
- **Quotes located correctly.** The S021 quote occurs once, under h2 "Token Time-To-Live,
  periodic tokens, and explicit max TTLs". The S026 quote occurs once, under "Token
  hierarchies and orphan tokens".
- **Handling.** Today nothing compares the two rows. A same-day contradiction passes (r4,
  r4b at `511deb27`). Any claim that S021/S026 agreement is machine-checked would be false.
  The current text makes no such claim.
- **Volatile declaration.** It is reasoned from build-scoped asset names
  (`parent-build/SourceS016.md:95-98`), not observed as a change. `SourceS021.md:86` says
  "no claim about this page's bytes changing", and my two GETs were identical.

## S019/S007

- **Data accurate.** `https://www.1password.dev/brokered-access` fetched twice: identical
  bodies equal to the TSV, `67f690e21116…`, 1,199,447 B, final URL equal, status 200.
- **Normalization and quote.** Normalized `f3861c17…` matches. The quote occurs once, in
  the intro before the first h2, so the location "Introduction" is accurate.
- **S007's in-row pin.** `e4aef238…` (`SOURCES.md:13`) differs from S019's capture. It is
  never compared, which matches the stated legacy bound. A third digest for the same URL,
  `896c780b…` from 2026-10-20, is recorded at `parent-build/SourceS019.md:96-102`.
- **Crash window.** At `80966e20…`, S019's `supersedes S007` cell was the exact input that
  crashed the census (F1).
- **Side observation.** S007's third legacy quote, "the token value is your integration
  key", occurs 0 times verbatim. The page reads "The token value is your integration key"
  (2 occurrences). The row is legacy and historical.

## Smallest safe corrections (owner's choice; I made no edits)

1. **Update the W04 count.** Make `round-23.md:66-72` and `:177-178` say seven W04 lines at
   round end, and quote S025 and S026. Change `closure-dispositions.json:52` to match.
2. **Enforce the legacy bound in code.** Accept an in-row pin only for the enumerated
   legacy ids S001–S016; any other id needs a TSV row.
3. **Optionally restore the sound part of agreement.** Key on
   `canon(final_url)|fetched|representation|normalization`, with `canon` equal to the fleet
   `url_of`. Within a key, compare normalized digests for `rendered-text-v1` and
   raw digest plus bytes for non-volatile rows. Require volatile rows to use
   `rendered-text-v1`. This rejects r4b and keeps honest recaptures (r5) passing. If this
   is not implemented, state the bound below.
4. **Clean up the selftest.**
   - Rename or drop `fetch-disagree` and update the case count.
   - Delete `seen_key`, `FDIG` and `FNRM`.
   - Add a `supersedes S0…` row and a VO row to `base_fixture`.

## Bound the C2 claim must state, given the current code

`SC_FETCH` checks provenance shape and registry identity per row and compares no two
captures:

- Two provenance rows for one URL may carry contradictory raw or normalized digests and
  both pass. This holds for any representation and any date, including the same date
  (r4b).
- Any row of any id can satisfy coverage with a bare 64-hex in-row pin and skip every
  provenance field (l2, r8).
- Six legacy in-row pins (S006, S007, S012, S013, S014, S016) differ from the later
  captures of the same URLs and are never compared.

**Classification for the judge.**
- Open fixable defects: items 1 (calibration) and 2 (freshness), and item 4 (minor).
- Tradeoff: item 3. Accept it only with the bound stated.
- F1 and the `6f202fce` selftest failure were real but transient; both are fixed at
  `511deb27`.
- Axes affected: calibration (W04 count, misnamed case), freshness (in-row bound, same-day
  contradictions), operability (the crash, the fixture gap).

## Commands and exits

| # | command | exit | result |
|---|---|---|---|
| 1 | `bash corpus/sources-census.sh` @`80966e20` (twice) | 1 | `line 242: S007: unbound variable`, no verdict line |
| 2 | `bash corpus/sources-census.sh --selftest` @`80966e20` | 0 | PASS (59) |
| 3 | `bash -c 'set -uo pipefail; f(){ while read -r fid; do [[ -n $fid ]] && SUPERSEDED[$fid]=1; done < <(printf "S007\n"); }; f'` | 127 | `S007: unbound variable` |
| 4 | live verify @`24d834cc` (01:05:46, 01:07:54), @`6f202fce`, @`511deb27` | 0 / 0 / 0 | CLEAN rows=26 |
| 5 | live `--selftest` @`24d834cc`, @`6f202fce`, @`511deb27` | 0 / **1** / 0 | PASS (59) / FAIL (59 cases, 1 failed) / PASS (59) |
| 6 | (fleet cwd) `bash scripts/sources-census.sh validate /home/vgpnk/Projects/shokunin/kagi-shokunin --today 2026-10-21` | 0 | 7 W04 lines (S019, S020, S021, S022, S023, S025, S026) |
| 7 | `git show d218603:corpus/SOURCES.md` to a temp file, then fleet `validate --file <tmp> --today 2026-10-21` | 1 | 5 W04 lines. Exit 1 comes only from E11, because used-by paths resolve against the temp path |
| 8 | lane curl profile `-o F -w '%{url_effective} %{http_code}'`, 2× each URL | 0 ×4 | values in the S021/S026 and S019/S007 sections above |
| 9 | the same profile on `https://openbao.org/docs/concepts/tokens`; `curl -sS -w 'first-hop %{http_code} -> %{redirect_url}'` | 0, 0 | `301 -> https://openbao.org/docs/concepts/tokens/`, final 200 |
| 10 | Python rendered-text-v1 (drop script/style bodies, tags→space, `html.unescape`, collapse whitespace, trim), 3 whitespace variants | — | `ed949658…` and `f3861c17…` reproduced |
| 11 | `bash <pinned copy> verify --root <fixture or real-tree copy>` (Tables A and B) | as tabled | |
| 12 | `bash <mutant copy> --selftest` (Table C) | as tabled | |
| 13 | fleet `validate` on the a8, a9 and r9 roots | 0 | W04 same-URL lines |
