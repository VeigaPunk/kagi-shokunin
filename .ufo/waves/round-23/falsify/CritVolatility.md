# CritVolatility: round-23 falsification of the volatile-representation rule (SC_FETCH)

Seat: `KagiR23.CritVolatility` (critic, leaf). Axes judged: calibration, freshness, operability.
Base `d218603b74099ddca0bd8f869516fc41db0979bf` plus the uncommitted round-23 tree. I wrote nothing in the lane except this file.
My scratch work lives in `/tmp/critvol.PqmXzg`, outside the lane: runner `run-x.sh`, mutants, and fetched bodies.
I installed nothing.

## What I attacked

The claim under test: the `decoded-http-body-volatile-v1` rule in `corpus/sources-census.sh` SC_FETCH, together with the C2 text that describes it.
That text says a volatile row's raw HTML is not comparable, so "the normalized digest is the stable declared identity" (TSV header at `ccc9ae6e…`).

The hypothesis to falsify: if normalized digests are only shape-checked, then a different page or a fabricated normalized digest passes the gate.

The tree moved four times while I was measuring. I pin every finding to a content hash.

| artifact | versions observed (sha256 prefix, local mtime) |
|---|---|
| `corpus/sources-census.sh` | `80966e20…` (00:57:55), then `24d834cc…` (01:02:21), then `6d4190a7…` (current at 01:08:52; header comment lines 64-66 only, code identical to `24d834cc`) |
| `corpus/source-fetches.tsv` | `ccc9ae6e…` (00:55:22), then `a78fde7b…` (01:04:32; header lines 19-21 reworded, S022 location changed), then `846b2037…` (current; header line 2 reworded) |
| `corpus/lessons/round-23.md` | `d5520988…`, then `bce51c92…`, then `88d0c7dc…`, then `2f53cf69…`, then `cf79cd0c…` (current; M23-1 moved to `:145`, wave-confirmation sentence to `:183`) |
| `corpus/claim-ledger.tsv` | `6fa0c24f…`, then `0d3d7500…`, then `3634eb71…` (current; R21-03 text at `:53` unchanged) |

## Verdict

**Defect confirmed.** The hypothesis holds on all three census versions: `80966e20`, `24d834cc` and `6d4190a7`.

- **Volatile rows are shape-checked only.** All 10 provenance rows are `decoded-http-body-volatile-v1` + `rendered-text-v1` (`awk -F'\t' '!/^#/ && NF==16 {print $9, $14}' | uniq -c` gives `10`). For these rows the gate checks the raw digest, normalized digest, final URL, HTTP status, bytes, fetch date and quote only for shape.
- **Only one cross-row check exists, and it is weak.** It compares normalized digests between rows whose registered URL string is identical. One pair qualifies (S021/S026). Copying, re-spelling the URL, or choosing `raw-literal-v1` all defeat it.
- **The same rule false-fails honest data.** An honest recapture from a different day fails it, while copying the earlier digest passes.
- **The selftest proves none of the volatile rule.** The fixture has zero volatile rows. 12 of 24 SC_FETCH finding sites, and 5 of 5 semantic mutants of the volatile/same-URL rule, survive the 59-case selftest. Every mutant also keeps R21-02's exact CLEAN line on the real tree.
- **The C2 text contradicts the code and itself.** At `6d4190a7` the census header (:64-66) itself says "no cross-capture equality is enforced", while the same file's code (:275-290) enforces it. The C2 text also contains a premature "falsification wave confirmed" sentence.

The declared *data* is honest today. All 10 normalized digests reproduce from fresh fetches, and 9/10 raw digests reproduce. The *gate* would accept the same rows with fabricated values just as readily.

## What the gate actually enforces for a volatile row (`24d834cc…`)

| check | line | enforcement | killed by the 59-case selftest? |
|---|---|---|---|
| TSV line has 16 fields | 243-244 | shape | **no** (mutant survives) |
| id is a registry row | 248 | binding | yes |
| status equals registry | 249 | binding | yes |
| url equals the first `https?://` in the registry source cell | 250 | binding (exact string) | yes |
| `row_identity_sha256` | 251-252 | redundant: hashes the registry `(id,status,url)` that 248-250 already equate, so it binds no captured content | yes |
| final URL | 253 | shape `^https?://\S+$`, any host | **no** |
| HTTP status | 254 | shape `^[0-9]{3}$` (`404` passes) | **no** |
| request profile | 255 | literal | **no** |
| fetched date | 256 | shape (`0000-00-00` passes) | **no** |
| representation ∈ {v1, volatile-v1} | 257 | enum; "volatile" needs no evidence | **no** |
| raw sha256 | 258 | shape | yes |
| bytes | 259 | shape | **no** |
| revision / moving-ref revision | 261, 264 | shape | **no / no** |
| quote ≤25 words | 267 | length only; never located in any page or text | yes |
| normalization enum | 268 | enum; volatile may pick `raw-literal-v1` | yes |
| normalized digest when `rendered-text-v1` | 270 | shape | yes |
| normalized digest `-` otherwise | 272 | shape | **no** |
| location ≥8 chars | 274 | length | yes |
| raw same-URL agreement | 279-284 | **skipped for volatile**; applies to 0/10 real rows | yes, but only through a same-id duplicate (see Mb) |
| normalized same-URL agreement | 285-290 | key `"$furl\|norm\|$fnorm"` = exact registered URL string; ignores `fetched`; applies to 1 pair (S021/S026) | **no** |
| one row per id | 291 | binding | yes |
| in-row pin malformed | 296 | shape | **no** |
| coverage (pin or provenance row) | 299 | binding | yes |

`volatile` appears in the census only at 257 and 279. It is not defined in the header, whose lines 70-75 define only `decoded-http-body-v1` and `rendered-text-v1`. It never appears in the selftest fixture (`base_fixture` lines 392-395 use `decoded-http-body-v1` only).

## Counterexamples

Each mutation is applied to a scratch copy of the lane's real `SOURCES.md`, `knowledge/`, `lessons/` and `source-fetches.tsv`. The real gate then runs against that copy:
`bash /tmp/critvol.PqmXzg/run-x.sh /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh` (runner exit 0).
Each case runs `bash <census> verify --root <scratch copy>`.
I ran it at census `24d834cc` + TSV `a78fde7b`, and again at the current `6d4190a7` + TSV `846b2037` (01:09). Every row had the same exit and the same verdict both times. Identical results also came earlier from `census.v3.sh` (`24d834cc`) and from `census.fix.sh`, which is `80966e20` plus one added `declare -A SUPERSEDED=()`.

| case | mutation | exit | verdict |
|---|---|---|---|
| control | none | 0 | `CLEAN (rows=26 … legacy=21)` |
| fabricated normalized digest | S017 `normalized_sha256 := sha256("fabricated normalized text")` | **0** | **CLEAN** |
| different page (swap) | S017↔S018: final URL, status, sha, bytes, quote, normalized, location | **0** | **CLEAN** |
| wholly different page | S024: final `https://example.com/`, status `404`, fake sha, bytes 1, quote "Tokens never expire and are never revoked.", fake normalized, location "somewhere else" | **0** | **CLEAN** |
| same-URL raw disagreement (volatile) | S026 raw sha fabricated (S021 unchanged; same URL) | **0** | **CLEAN** |
| volatile with no stable identity | S026 raw fabricated, `raw-literal-v1`, normalized `-` | **0** | **CLEAN**: no raw or normalized comparison remains |
| representation split | S021 → `decoded-http-body-v1`, S026 stays volatile with a different raw sha | **0** | **CLEAN** |
| coordinated fabrication | S021 and S026 normalized := the same fabricated value | **0** | **CLEAN** |
| status/date/final URL | S022: final URL → `/vault/docs/auth/oidc`, status `404`, fetched `0000-00-00` | **0** | **CLEAN** |
| URL re-spelling | S026 registered as `…/concepts/tokens` (no slash, row identity recomputed), normalized fabricated | **0** | **CLEAN** |
| normalized = raw digest | S019 `normalized_sha256 := sha256` | **0** | **CLEAN** |
| control: one-sided normalized | S026 normalized fabricated, S021 honest | 1 | `FINDING SC_FETCH id=S026 same-url-normalized-disagreement` |
| control: non-volatile raw | both rows non-volatile, S026 raw fabricated | 1 | `FINDING SC_FETCH id=S026 same-url-digest-disagreement` |
| **honest cross-day recapture** | new S013 row for the lease URL, fetched 2026-10-07, normalized `80d6c61d…` (the lane's own Wayback-derived value, `parent-build/SourceS023.md:125`) | **1** | `FINDING SC_FETCH id=S013 same-url-normalized-disagreement`, a **false failure** |
| **copied digest** | same row, normalized copied from S023 (`0e62e056…`) | **0** | **CLEAN**: the fabrication passes |

Two further facts back these cases:
- The URL re-spelling case uses a real alias. `https://openbao.org/docs/concepts/tokens` makes 1 redirect to `/tokens/`, returns 200, and has the identical sha256 `5229521866ce…` / 47,384 B (curl at 01:03:34).
- The cross-day case matches real behavior. The lane's audits show whole-page `rendered-text-v1` moving with chrome between days: S017 `7227ed88…` on 10-06/10-12 vs `2a39cb16…` on 10-21 (`parent-build/SourceS017.md:80`); S021 `6a77cb9c…` on 2026-09-18 (`SourceS021.md:123`); S023 three values (`SourceS023.md:124-128`). So the same-URL normalized rule punishes honest recaptures and rewards copying, which is exactly the fabrication the gate cannot see.

## Selftest mutation test (operability)

Method: for each of the 24 `finding SC_FETCH` sites I created one mutant (`finding SC_FETCH` replaced by `: SC_FETCH`), then ran `bash <mutant> --selftest` and `bash <mutant> verify --root <lane>`.

**12 of 24 sites survive (selftest PASS 59/59).** They are:
- 244 (NF≠16)
- 253 (final-url)
- 254 (http-status)
- 255 (request-profile)
- 256 (fetched)
- 257 (representation)
- 259 (bytes)
- 261 (revision)
- 264 (moving-ref-revision)
- 272 (normalized-digest-not-applicable)
- **288 (same-url-normalized-disagreement)**
- 296 (inrow-digest-malformed)

I got the same 12/24 on `80966e20` at its own line numbers (249/258/…/293/301).

Semantic mutants of the volatile/same-URL rule, built on `24d834cc`. **All 5 survive the selftest, and all 5 print R21-02's exact `CLEAN (rows=26 …)` on the lane:**

| mutant | change | result |
|---|---|---|
| Ma | `if [[ $frep != …volatile-v1 ]]` → `if true` (volatile bypass removed) | survives; real tree unchanged, because the only same-URL pair is raw-identical |
| Mb | raw key `"$furl\|$frep"` → `"$fid\|$frep"` | survives: the only "agreement" case, `fetch-disagree` (`m_fetch_disagree`, line 442; case line 569), duplicates the *same id* S002, so the selftest cannot tell same-URL keying from duplicate-id |
| Mc | normalized key by id | survives |
| Md | normalized agreement deleted | survives |
| Me | representation enum → any non-empty string | survives |

Across all 29 mutants the lane verify printed exactly one distinct line: `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`. So R21-02 cannot detect any of them either.

**A crash that passed the selftest.** At `80966e20` the census crashed while its selftest passed:
- `bash corpus/sources-census.sh` printed `corpus/sources-census.sh: line 242: S007: unbound variable`, exit 1, **no verdict line**. The "VERDICT (last line, always)" contract in header lines 93-97 was broken.
- At the same moment, `bash corpus/sources-census.sh --selftest` printed `PASS (59 cases)`, exit 0.
- Cause: an undeclared `SUPERSEDED[$fid]=1` under `set -u`. Probe `bash -uc '…SUP[$x]=1…'` failed with `S014: unbound variable`, exit 127.
- The fixture has no `supersedes S…` row, so the selftest could not see this path.
- `24d834cc` removed the loop. `bash corpus/sources-census.sh` then exits 0 CLEAN rows=26, and `--selftest` passes 59, exit 0.

This is direct evidence that "selftest 59 green" is not evidence for real-tree paths.

## Live re-measurement (freshness)

I made 18 GETs: 9 URLs × 2, at 01:00:54–56 −03:00, using the allowed profile `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`. All returned rc 0, HTTP 200, and the declared final URLs.

**Raw digests.** 9/10 rows (S017-S019, S021-S026) are byte-identical across both GETs and equal to the declared sha256 and bytes. Only S020 is raw-volatile: `ae1bc386627e…` and `722cc2e74880…` vs declared `53dfeac555f8…`, at a constant 190,261 B.

So the volatile label is earned within a minute only by S020. Because it is applied to every row, the advertised raw same-URL rule covers 0 rows. The one pair it would cover (S021/S026) is raw-identical, so the exemption (Ma) changes nothing today and only weakens future checks.

**Normalized digests.** I recomputed `rendered-text-v1` in 5 implementations.
- All 10 declared normalized digests reproduce when "collapse whitespace" means Unicode `\s+` + `strip()`. All 10 quotes are present in the normalized text.
- With ASCII-only `[\t\n\r\f ]+`, 3/10 differ: S022 `37a4eaf103c0…` (18,611 chars vs 18,609), S023 `3410ba6d8b3d…` (7,356 vs 7,354), S024 `463ddab2f913…` (24,329 vs 24,327).
- The prose spec (TSV:26-28, census:73-74, lesson:40-41) does not name the whitespace class. The "declared identity" therefore depends on an undocumented implementation choice. (Bound only; the CritNormalizer seat owns the depth.)

## Where the C2 text overstates or contradicts the code

These are the current versions unless a hash is given.

1. **Census header vs code vs TSV vs lesson (duplicate, contradictory authorities).**
   - At `24d834cc`, `sources-census.sh:64-66` said "Two provenance rows for one URL must agree on the raw digest and, when rendered-text-v1, on the normalized digest". That is false for raw digests on volatile rows (case *same-URL raw disagreement* is CLEAN).
   - At `6d4190a7` the same header lines now say "Captures are point attestations: no cross-capture equality is enforced, only one provenance row per id". The code at :275-290 (FDIG/FNRM) is unchanged and *does* enforce cross-capture equality: cases *one-sided normalized*, *non-volatile raw* and *honest cross-day* still exit 1 at `6d4190a7`.
   - So the header contradicts its own code. The code also contradicts `source-fetches.tsv:19-21` (`a78fde7b`/`846b2037`, "No cross-capture equality is enforced") and `lessons/round-23.md:52-54` ("so no cross-capture equality is enforced").
   - The census comment at :275-277, "site chrome … change[s] the bytes, not the article", is contradicted by the lane's own audits (SourceS017/S021/S023): chrome sits inside `rendered-text-v1`.
2. **Previous TSV wording.** `source-fetches.tsv:19-21` at `ccc9ae6e` said "the normalized digest is the stable declared identity". It is unenforced (shape only), not required (volatile + `raw-literal-v1` escapes), and not stable across days (lane audits above). The wording was softened at `a78fde7b`; the code still treats it as an identity.
3. **D7 at `lessons/round-23.md:106-108`.** It says SC_FETCH "bind[s] every row … to a declared representation, URL, final URL, HTTP status, row-line digest and located quote".
   - Only id, status and URL are bound; the row-line digest is a redundant function of them.
   - Final URL, status and quote are free text of the right shape. "Located" is never checked (cases *wholly different page* and *status/date/final URL*).
4. **M23-1 fix at `lessons/round-23.md:145` (`cf79cd0c`; `:142` at `2f53cf69`).** "Same-URL captures must agree" is true for normalized digests of one exact-URL-string pair only. For raw digests it covers 0 of 10 rows, and it is untested (surviving mutants 288, Mb–Md).
5. **R21-03 at `claim-ledger.tsv:53`.** It says "twelve SC_FETCH coverage/shape/agreement cases". The single agreement case is a same-id duplicate (Mb survives), and 12/24 SC_FETCH sites are unproven.
6. **Premature provenance at `lessons/round-23.md:183` (`cf79cd0c`; `:179` at `2f53cf69`).** It says "The 64-seat falsification wave confirmed the three claims and named these bounds".
   - At 01:07:01, `.ufo/waves/round-23/falsify/` held 28 reports and none from CritVolatility, CritSameUrl or CritNormalizer.
   - This seat does not confirm C2 as worded.
7. **Count drift.** The dispatch context and the earlier lesson said "10 declared captures … over 7 URLs". The measured count is **9** distinct URLs (`awk … $4 | sort -u | wc -l` → `9`); the current lesson:174 and LOG:1202 say nine.
8. **Accurate as frozen.** `plans/round-23.md:27-29` claims "digest shape". `claim-ledger.tsv:52` (R21-02) says "no network/content validation by this command". Lesson:185-188, at `2f53cf69`, now says "shape-and-identity, not content verification". Those bounds are honest; items 1-6 above exceed them.

## Impacted axes

- **Freshness (C2).** Volatile provenance is attestation-only. A fabricated or different-page capture passes. The only cross-row rule false-fails an honest cross-day recapture and passes a copied digest.
- **Calibration.** Gate behavior is described in incompatible ways: at `6d4190a7` the census header contradicts the census code, and both TSV and lesson disclaim the rule the code enforces. D7 and M23-1 claim bindings the code lacks. Lesson:183 asserts falsification-wave confirmation in advance.
- **Operability.** The selftest proves 12/24 SC_FETCH sites and none of the volatile rule. The `80966e20` crash shipped green through the selftest. R21-02's pinned CLEAN line cannot distinguish any of the 29 mutants.

## Smallest safe correction

1. **One authority for cross-capture equality.** Given the cross-day evidence, either:
   - delete FDIG/FNRM (lines 275-290) and the comment at :275-278, so the code matches the `6d4190a7` header, the TSV and the lesson ("no cross-capture equality"); or
   - key FNRM by `(final_url, fetched)` (same-day duplicate captures must agree) and say exactly that in all three places.
   Do not keep a rule that the text disclaims.
2. **Volatile ⇒ `rendered-text-v1`.** Make this a hard rule (one line after 268). It closes the *volatile with no stable identity* escape. Define `decoded-http-body-volatile-v1` in the census header.
3. **Selftest cases.** Add a volatile fixture row plus cases that kill Ma–Me and the 12 surviving sites:
   - a cross-id same-URL raw disagreement (kills Mb);
   - a volatile pair with raw disagreement but normalized agreement (CLEAN);
   - a normalized disagreement (FAIL);
   - a bad representation, final URL, status, date, bytes, revision, moving-ref, normalized-not-applicable, in-row-malformed, and an NF≠16 line;
   - a `supersedes S…` registry row (the `80966e20` crash class).
4. **Text repairs.**
   - D7 (`lessons/round-23.md:106-108`): "binds id/status/URL; declares final URL, status, quote".
   - M23-1 (`:145`): qualify or drop "same-URL captures must agree".
   - R21-03 (`claim-ledger.tsv:53`): drop "agreement" or add the real case.
   - Remove `:183`'s "confirmed the three claims" until the seat reports exist, and replace it with measured counts.
5. **Name the whitespace class in `rendered-text-v1`.** For example, Python `re.sub(r'\s+', ' ', t).strip()`, Unicode, including U+00A0. Otherwise S022/S023/S024 do not reproduce under an ASCII reading.
6. **Optional, only if C2 wants a real "identity".** Commit the normalized text, or the content-area slice proposed in `parent-build/SourceS017.md` fix option 1. The census can then recompute its sha256 and substring-check the quote offline, with no network.

**For the canonical judge.** Shape-only digest checking with no network is a declared tradeoff and admissible as frozen. Three items are fixable defects that should block admission if they land unrepaired:
- the contradictory equality authority (item 1 in the overstatement list);
- the D7/M23-1/R21-03 overstatements;
- lesson:183's pre-written wave confirmation.

## Commands run (exact) and exits

All commands ran from `/home/vgpnk/Projects/shokunin/kagi-shokunin` unless noted.

1. `wc -l corpus/sources-census.sh …; git -C . rev-parse HEAD; git -C . status --short` → 0 (HEAD `d218603b…`).
2. `git diff d218603b74099ddca0bd8f869516fc41db0979bf -- corpus/sources-census.sh` → 0.
3. `bash corpus/sources-census.sh` at `80966e20` → `line 242: S007: unbound variable`, **exit 1**, no verdict line.
4. `bash /tmp/critvol.PqmXzg/census.snap.sh verify --root /home/vgpnk/Projects/shokunin/kagi-shokunin` → same, exit 1.
   `bash -uc 'f(){ while read -r x; do [[ -n $x ]] && SUP[$x]=1; done < <(printf "S014\n"); echo after; }; f; echo end'` → exit 127.
5. `bash corpus/sources-census.sh --selftest` at `80966e20` → `PASS (59 cases)`, exit 0.
6. The 18 `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' -o … -w '%{url_effective} %{http_code}' <url>` calls → all rc 0.
   2 alias GETs (`…/concepts/tokens`, `…/github-actions`) → rc 0.
7. `bash /tmp/critvol.PqmXzg/census.fix.sh verify --root <lane>` → CLEAN rows=26, exit 0.
8. `bash /tmp/critvol.PqmXzg/run-x.sh` against `census.fix.sh`, then `census.v3.sh`, then the live lane script → the case table above (exits per row; the final runner exit was 0).
9. Python mutation harness (24 site mutants + 5 semantic; `bash <mutant> --selftest` and `bash <mutant> verify --root <lane>`) on `80966e20` and `24d834cc` → 12/24 survive; 5/5 semantic survive; lane verify exit 0 CLEAN for all.
10. `bash corpus/sources-census.sh` at `24d834cc`, and again at `6d4190a7` → CLEAN rows=26, **exit 0**. `bash corpus/sources-census.sh --selftest` at both → `PASS (59 cases)`, **exit 0**.
    `diff census.v3.sh census.v4.sh` → only comment lines 64-66 differ, so the 12/24 mutation result carries over to `6d4190a7` unchanged.
11. `awk -F'\t' '!/^#/ && NF==16 {print $9, $14}' corpus/source-fetches.tsv | sort | uniq -c` → `10 decoded-http-body-volatile-v1 rendered-text-v1`.
    `awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l` → `9`.

Not run: no legacy claim-ledger verify, no host-bound row, no parent-row audits, no install.
