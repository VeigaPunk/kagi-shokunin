# RevCensusCases — round 23 falsify: `corpus/sources-census.sh` SC_FETCH selftest cases

Seat: KagiR23.RevCensusCases (reviewer, falsification). Axes: calibration, freshness, operability.
Target: the 12 SC_FETCH selftest cases plus the SC_FETCH check block. Attack vectors: (1) inert mutation,
(2) an expected finding count that hides a second real defect, (3) SC_FETCH checks that cannot fail.
The verdict below is a recommendation, not an admission.

## Verdict (recommendation)

- **Case count confirmed:** `--selftest` reports `PASS (59 cases)`, of which 12 are SC_FETCH cases (E:542-553).
  That holds on all four script versions I ran.
- **Not mutation-adequate.** On the current bytes (E, `511deb27…`), 17 mutants survive the 59-case selftest:
  - 11 of the 22 `finding SC_FETCH` sites survive single-site deletion.
  - 6 semantic mutants survive.
- **One inert case.** `fetch-disagree` is functionally the same as `fetch-duplicate`. The 12 SC_FETCH cases
  therefore exercise only **11 distinct checks**.
- **Hidden second defect.** Round 23 raised the expected counts of 9 pre-existing cases so they silently absorb
  14 SC_FETCH side findings.
- **Production gate:** CLEAN on the real tree (exit 0). No production false-CLEAN was found on current data.
  Every finding is either a test-strength gap or a shape-only weak check. The one production break I observed,
  a crash, was fixed while I was measuring (F8).

## Bytes measured (the tree changed four times during the seat)

| ver | `sources-census.sh` sha256 | lines | mtime (-03:00) | observed |
|---|---|---|---|---|
| A | not pinned | 598 | ~00:5x | `SUPERSEDED=()` declared; no agreement code; `fetch-disagree` expected 1 |
| B | `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781` | 613 | 00:57:55 | agreement code added; **`verify` crashed** (F8); selftest PASS 59 |
| C | `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057` | 608 | 01:02:21 | SUPERSEDED parse deleted; verify CLEAN; selftest PASS 59 |
| D | `6d4190a7302eb001c728860e8825c12f0641dafc5cf242cefcb8a4d282ffa236` | 608 | 01:08:48 | snapshot used for the first matrix (24 sites) |
| **E** | **`511deb2730614663c86beb9b6793b54eea75ce8a9dbe4f1cf372999697339b58`** | **592** | **01:10:59** | **current at report time**; same-URL agreement deleted; `fetch-disagree` back to 1 |

`corpus/source-fetches.tsv`: `ccc9ae6e…0af` until about 01:10, then `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d`.
Both versions have the same 10 data rows (S017–S026), all `decoded-http-body-volatile-v1`.
All E line numbers below are `corpus/sources-census.sh:<line>` at hash `511deb27…`.

## Commands and exits (all run from `/home/vgpnk/Projects/shokunin/kagi-shokunin`)

| # | command | exit | output tail |
|---|---|---|---|
| 1 | `bash corpus/sources-census.sh --selftest` (A) | 0 | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` |
| 2 | `bash corpus/sources-census.sh verify` (B, 00:59) | **1** | `corpus/sources-census.sh: line 242: S007: unbound variable` (no verdict line) |
| 3 | `bash corpus/sources-census.sh --selftest` (B, same batch) | 0 | `PASS (59 cases)` |
| 4 | `bash corpus/sources-census.sh verify` (C, 01:03:54) | 0 | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` |
| 5 | `bash corpus/sources-census.sh --selftest` (E) | 0 | `PASS (59 cases)`, 59 lines `: ok` |
| 6 | `bash corpus/sources-census.sh verify` (E) | 0 | same CLEAN line as #4 |
| 7 | `git show d218603b…:corpus/sources-census.sh` (read-only) | 0 | base has 48 cases; diff of the case tables quoted in F3 |
| 8 | mutant matrix: copies of D and E under `mktemp -d`; each mutant ran `bash <mutant> --selftest` and `bash <mutant> verify --root <lane>` | per row | tables below |
| 9 | targeted fixtures: copies of the script's own `base_fixture` (E:329-380); then `bash <snapshot> verify --root <fixture>` | per row | F2–F6 |

None of these writes inside the lane. The selftest and every mutant wrote only under `mktemp -d`. I ran no network
fetch, no claim-ledger rows and no host gates.

## Per-case table (E): which SC_FETCH check each case actually kills

Harness assertion (E:574-575): at least one `^FINDING SC_FETCH ` line plus an exact total count. It never checks
the finding **detail**.

| case (E line) | mutation | findings on E | distinct site |
|---|---|---|---|
| fetch-missing (542) | drop S002 TSV row | `id=S002 missing-provenance` | :283 |
| fetch-url | f4 → wrong URL | `url-mismatch` | :250 |
| fetch-status | f2 → queued | `status=queued registry=mined` | :249 |
| fetch-rowdigest | f3 → deadbeef | `row-identity-digest-mismatch` | :252 |
| fetch-digest | f10 → deadbeef | `digest` | :258 |
| fetch-quote-long | f13 → 26 words | `quote` | :267 |
| fetch-norm (415) | f14 → bad-norm-v1 **and** f15 → `-` | `normalization` | :268 |
| fetch-normsha | f15 → `-` | `normalized-digest` | :270 |
| fetch-location | f16 → empty | `location` | :274 |
| fetch-unknown | append S099 | `id=S099 not-a-registry-row` | :248 |
| fetch-duplicate (422) | append copy of S002 | `id=S002 duplicate-provenance` | :275 |
| **fetch-disagree** (426, 553) | append S002 with f10 = 9×64 | `id=S002 duplicate-provenance` | **:275, same as fetch-duplicate** |

None of the 12 mutations is byte-inert. The QM9 guard (E:565, `diff -rq` against base) passes for all of them.
`fetch-disagree` is inert in effect, which that guard cannot detect (F1).

## Findings

### MEDIUM

**F1 — `fetch-disagree` is inert with respect to its name; 12 cases cover 11 checks.**
- **Evidence:**
  - On E, `fetch-disagree` and `fetch-duplicate` emit identical finding lists. My check `EOUT['fetch-disagree']==EOUT['fetch-duplicate']` returned `True`.
  - Mutant I01 replaces the body of `m_fetch_disagree` (E:426) with `m_fetch_duplicate`'s (E:422). Selftest: `PASS (59 cases)`, exit 0.
  - So the case's distinguishing edit (field 10 = `9…9`) is inert. The QM9 guard at E:565 only catches byte-identical fixtures, so it cannot see this.
- **History:**
  - In D the case expected `2`: same-url-digest-disagreement plus duplicate-provenance.
  - E deleted the agreement code (old D:275-290). The E header now says "no cross-capture equality is enforced, only one provenance row per id" (E:64-66).
  - The case was reset to `1` (E:553) but neither removed nor renamed.
- **Effect:** "12 SC_FETCH cases" overstates coverage. Distinct SC_FETCH sites killed by fetch cases: 11.

**F2 — 11 of 22 SC_FETCH checks can be deleted without failing the selftest.**
- For each surviving deletion I built a fixture where the original fires and the deletion mutant is CLEAN. So these
  checks can fail on real input, but the selftest cannot detect their removal.
- In every row below, deleting the site keeps the selftest at `PASS (59)` and production `verify` at CLEAN.

| E site | detail | fixture input; original finding |
|---|---|---|
| :244 | NF≠16 line | extra 3-field S002 row; `line=5 nf=3` |
| :253 | final-url | final_url `-`; `final-url` |
| :254 | http-status | `2xx`; `http-status` |
| :255 | request-profile | `wget-v1`; `request-profile` |
| :256 | fetched | `yesterday`; `fetched` |
| :257 | representation | `raw-html-v9`; `representation` |
| :259 | bytes | `0`; `bytes` |
| :261 | revision | `main`; `revision` |
| :264 | moving-ref-revision | `github.com/o/r/blob/main/…` without revision; `moving-ref-revision` |
| :272 | normalized-digest-not-applicable | raw-literal-v1 with a 64-hex normalized digest; finding fires |
| :280 | inrow-digest-malformed | in-row pin `` `abc` ``; `inrow-digest-malformed` |

- **Root cause:** the selftest fixture (E:329-380) contains **0** in-row `Fetch sha256:` pins, **0** volatile
  rows, **0** `supersedes` cells and **0** moving-ref URLs. Production has 16, 10, 6 and 1 (S008) respectively.
- **Consequence:** the in-row coverage path, which covers 16 of 26 production rows, is never executed by the selftest.
  Mutant S05 makes the awk ignore in-row pins. It passes the selftest (`PASS 59`), but production `verify` gives
  exit 1, `FAILED (findings=16 …)`.
- **Freshness relevance:** `fetched`, `representation` and `request-profile` are the D7 freshness declarations, and none of them is pinned.

**F3 — expected counts that hide a second real defect.**
- Diff of the case tables, base `d218603b` → E (command #7). Nine pre-existing cases were raised to absorb SC_FETCH side findings:

| case | count | findings absorbed |
|---|---|---|
| `zero` (E:498) | 1→5 | 4 × `not-a-registry-row` |
| `malformed` (E:499), `row-leading-space`, `row-two-digit-id`, `row-lowercase-id` | 1→2 | 1 × `not-a-registry-row` each |
| `enum-status` (E:505) | 1→3 | `status=queued registry=pending` and `row-identity-digest-mismatch` |
| `mined-unused-dash` (E:512), `mined-unused-empty` | 1→2 | `id=S005 missing-provenance` each |
| `cite-tier-c-sole` (E:527) | 1→2 | `id=S005 missing-provenance` |

- In each case the mutation now creates a second real defect: an orphaned or stale TSV row, or a registry row without provenance. The count conceals it.
- These absorbed counts add kill power: they help kill D248, D249, D252 and D283.
- They also make the oracle (E:574-575) accept any composition that contains one target-ID line.
- **Detail-blindness is demonstrated by surviving mutant S04:**
  - S04 deletes the `url-mismatch` check (E:250) and hashes the TSV-side URL into the row-identity digest.
  - Selftest: `PASS 59`. Under S04, `fetch-url` still produces exactly one SC_FETCH finding, but it is `row-identity-digest-mismatch` instead of `url-mismatch`.
  - Fixture EX3 (wrong URL with the row digest recomputed from that wrong URL): original gives `url-mismatch | row-identity-digest-mismatch` (exit 1); S04 gives CLEAN (exit 0).
- **Related, D only:**
  - `fetch-disagree` expected 2, which baked a duplicate-id defect into the only agreement case.
  - Cross-id agreement, the only production shape (S021/S026 share `https://openbao.org/docs/concepts/tokens/`), was never tested.
  - Mutants S01, S02, S03, S07 and D288 all survived on D. On fixtures X1/X2 the original fired, while those mutants were CLEAN.
  - This is moot on E, where the check was deleted and disclaimed.
- **Also:** `fetch-norm`'s second edit (f15 → `-`, E:415) suppresses the `normalized-digest-not-applicable` branch. That is why :272 is unpinned.

### LOW

**F4 — the quote-emptiness arm cannot fire for an empty quote cell.**
- `IFS=$'\t' read` (E:245) treats tab as IFS whitespace, so consecutive tabs collapse and later cells shift left.
- EX8 (empty f13): output is `normalization | normalized-digest-not-applicable | location`, with **no** `quote` line. Exit is still 1 (fail-closed) but the findings are misattributed.
- Other empty middle cells:
  - empty f5 → 11 findings
  - empty f12 → 4 findings
- `-n $fquote` (E:267) can only be false when 4 or more cells are empty.

**F5 — shape-only checks accept impossible or contradictory values.** Each of these returns CLEAN, exit 0:
- `http_status` `404` (contradicts `curl -f` in the declared profile)
- `http_status` `000`
- `fetched` `2026-99-99`
- `fetched` `2099-01-01` (future)
- `final_url` on a different host

Mutant S08 (`^[0-9]+$`) also survives. For freshness, this means the `fetched` check (E:256) cannot fail for an impossible or future date.

**F6 — the moving-ref check is narrower than the header claim.**
- E:64 claims "A moving-ref URL needs a 40-hex revision". E:263 only matches `raw.githubusercontent.com`, `*/main/*` and `*/main`.
- These return CLEAN without a revision (EX6): `github.com/o/r/blob/master/README.md` and `gitlab.com/o/r/-/raw/HEAD/README.md`. The `blob/main` control fires.
- Mutant S09 (keep only the raw-GH arm) survives.
- Production: no TSV row is affected. The registry's only moving-ref URL, S008 (`raw.githubusercontent.com/getsops/sops/main/README.rst`, SOURCES.md:14, "no commit/version displayed"), is covered only by a legacy in-row pin. That is inside the stated legacy bound (E:67-69), but it means the one moving-ref source in the registry is exempt.

**F7 — dead code after E's deletion.**
- `seen_key` (E:228) and `FDIG=() FNRM=()` (E:229) are declared but never used.
- The `registry=${ST[$fid]:-absent}` default (E:249) is unreachable. ST (E:224) and FURL (E:234-235) are filled from the same row filter, and `[[ -v FURL[$fid] ]] || continue` (E:248) runs first.
- Mutant S06 (`-lt 25`) also survives, so the 25-word upper bound is pinned only from above. There is no exactly-25-word case. Production's maximum is 22 words (S026).

### INFO

**F8 — observed transient production crash, now resolved.**
- At B (`80966e20…`), `verify` exited 1 with `line 242: S007: unbound variable` and printed no verdict line. In the same batch, `--selftest` reported `PASS (59 cases)`.
- **Cause:** E:229's predecessor dropped `SUPERSEDED` from `declare -A`, while the population loop still wrote to it under `set -u`. Minimal repro: `bash -uc 'while …; do SUPERSEDED[$fid]=1; …'` → `S007: unbound variable`.
- The selftest could not catch it because its fixture has no `supersedes S…` teaches cell.
- C (`24d834cc…`) fixed it by deleting the parse.
- **Residual risk:** a green selftest does not imply the production gate runs. Only `verify` on the real tree guards production-only shapes (F2).

**F9 — C2 URL count.**
- On both TSV hashes I measured 10 data rows over **9** distinct `url`. The counts of distinct `final_url`, raw digests and normalized digests are also 9 each.
- At about 00:59, LOG.md:1202 said "10 declared captures over 7 URLs" and corpus/lessons/round-23.md:165 said "over seven distinct URLs". Both were corrected at 01:11:27 (LOG.md:1202, lesson :174, SCORECARD.md:840 now say nine).
- The dispatch context (falsify-spec) still says 7.
- [INFERENCE] S021 and S026 declare a volatile representation yet share raw digest `5229521866…` and 47384 bytes, which is consistent with one fetch reused for two rows. If so, "10 captures" would be 9 fetches; I could not prove this either way.

## Survivor list (E, `511deb27…`): 17

- **Deletions (11):** D244, D253, D254, D255, D256, D257, D259, D261, D264, D272, D280.
- **Semantic (6):** I01 (disagree≡duplicate), S04 (url-check folded into TSV-side row digest), S05 (in-row pins ignored; production FAILED 16), S06 (quote ≤24), S08 (http any digits), S09 (moving-ref raw-GH only).
- **Killed (11):** D248, D249, D250, D252, D258, D267, D268, D270, D274, D275, D283.
- For comparison, D had 19 survivors (12/24 deletions plus 7 semantic). On D, D288 and S01–S03/S07 survived against the agreement code that E later deleted.

## Bounds and verification gaps

- **No production false-CLEAN found.** Every SC_FETCH check is still present and fires on the original fixtures, and real-tree `verify` is CLEAN. The survivors show what the selftest cannot prove, not wrong data.
- **Flux:** results are pinned to E. Any later edit makes line numbers stale.
- **Not attacked:** quote truth against live pages, digest reproduction, and representation/normalization semantics (no network fetch from this seat; owned by the RevS0xx / ScoutContract / CritNormalizer seats).
- **Not touched:** claim-ledger rows and host gates were not run; no lane file was edited.
- **Tool installs:** none.
