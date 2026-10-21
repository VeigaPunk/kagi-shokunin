# CritDigestDomain — round 23 falsification: the digest-domain declaration

Seat: `KagiR23.CritDigestDomain` (critic, leaf). Judged axes: calibration, freshness, operability.
Measurement window: 2026-10-21, 04:01Z to 04:16:37Z.
Base `d218603b74099ddca0bd8f869516fc41db0979bf`.
**Final pinned state: HEAD `58bd8d70d310ecaac0316e4b576073cc75142332`**. For every tracked file cited below (`corpus/*`,
`LOG.md`, `SCORECARD.md`; `git status --short` empty), the working tree equals HEAD. The `.ufo/waves/round-23/`
seat reports cited here (`parent-build/Source*.md`, `falsify/*.md`) are untracked working-tree files.

## What I attacked

The declaration that `sha256` and `bytes` are of the **decoded** HTTP body, and the normalized-digest and
same-URL rules attached to it. Locations at the final state:

- `corpus/source-fetches.tsv:12-23` (request profile, representation, sha256, bytes) and `:27-30` (rendered-text-v1)
- `corpus/sources-census.sh:56-75` (SC_FETCH header)
- `corpus/lessons/round-23.md:38-54` (quotation rule, hash domain), `:148`, `:177`

I asked two questions:

1. Can wire bytes and decoded bytes be confused, given the header and lesson?
2. Does any row's `bytes` or digest contradict the declared profile
   `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' <url>`?

## The tree moved during the falsify wave: three snapshots

| snapshot | `sources-census.sh` | `source-fetches.tsv` | lesson | census `verify` / `--selftest` |
|---|---|---|---|---|
| S1: uncommitted tree, 04:01–04:07Z | `24d834cc…` (was `80966e20…` at 03:57:55Z, where `ScoutS016.md:18-20,82` records `verify` exit 1: `line 242: S007: unbound variable`. I did not run that snapshot.) | `ccc9ae6e…` → `846b2037…` (only the S022 `location` changed) | `d5520988…` → `993e114a…` | exit 0 `CLEAN (rows=26 …)` / exit 0 `PASS (59 cases)` |
| S2: commit `284d40e` | `6d4190a7…` | `7101bdd0…` | `7a8e3b45…` | not run as a whole; agreement block read with `git show 284d40e:…` |
| S3: commit `638d44c` "remove cross-capture equality", then `def9bc2` and `58bd8d7` | `511deb27…` → `2d1bbbe3…` (`58bd8d7` only drops the now-unused `FDIG`/`FNRM` declarations at `:229`) | `6e26e140…` | `49632920…` → `ae29c16c…` | at `def9bc2`, 04:12:34Z: exit 0 `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` / exit 0 `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`. At `58bd8d7`, 04:16:37Z: same CLEAN line as the only output line (no W04) / exit 0 `PASS (59 cases)`. |

- The 10 data rows keep the same digest, bytes, URL, final URL, status and normalized digest in S1, S2 and S3.
  Only the S022 location text changed.
- Row line numbers shifted by +1 starting at S2: S017–S026 are TSV `:38-47` at S3 (`:37-46` at S1).
- `SOURCES.md` changed to `c6ea91ab…` at `def9bc2` and is unchanged at `58bd8d7`. Row identity still verifies there
  (census exit 0, plus my own recomputation below).
- Lesson line numbers are for `58bd8d7` (`ae29c16c…`): M23-1 is `:148` and "nine distinct URLs" is `:177`. They were
  `:145` and `:174` at `def9bc2`. Lines `:41` and `:45-54` are unchanged across all S3 commits.

## Verdict at the final state (S3, `58bd8d7`)

| item | S1 / S2 | S3 (final) |
|---|---|---|
| Q1: wire vs decoded confusion | none in the data | **none: confirmed** (10/10 bytes = decoded length; 0/10 = wire) |
| Q2: any row contradicting the profile (bytes, digest, final URL, status, row identity) | none | **none** (9/10 raw digests reproduce 8/8; S020 is declared per-response volatile and reproduces 0/8; bytes and normalized match 8/8) |
| Defect A: whitespace class in rendered-text-v1 not pinned | open at all three declaration sites | **partly fixed.** `source-fetches.tsv:28` now says "collapse Unicode whitespace (Python \s)". `sources-census.sh:74` and `round-23.md:41` still say only "collapse whitespace". |
| Defect B: same-URL agreement contradicted its declarations, was date-blind, and was untested on real rows | open (demonstrated) | **resolved by `638d44c`.** Code removed; demos D1–D3 are CLEAN, consistent with `source-fetches.tsv:21`, `sources-census.sh:64-66`, `round-23.md:52-54` and `:148`. |
| Bounds B-1 to B-4 | open | open; listed below |

## Commands and exits

All `curl` runs used argv lists from Python `subprocess`, with no shell; stdout was kept in memory.
UA = `kagi-shokunin-round23/1.0 (documentation verification)`. The 9 distinct URLs come from the TSV data rows.

| # | command (shell-equivalent) | runs | exit |
|---|---|---|---|
| 1 | `curl -fsSL --compressed -A "$UA" <url>` (exact declared profile) | 9 | 0 ×9 |
| 2 | Same request plus `-v -w '%{stderr}META\t%{url_effective}\t%{http_code}\t%{size_download}\t%{content_type}\t%{http_version}\t%{num_redirects}\t%{size_header}\n'` | 9 | 0 ×9 |
| 3 | `curl -fsSL -A "$UA" -H 'Accept-Encoding: deflate, gzip, br, zstd' -v -w '<META>' <url>`. No `--compressed`, so these are wire bytes, decoded locally with `brotli -d -c` or Python `gzip`. | 9 | 0 ×9 |
| 4 | `curl -fsSL --compressed -A "$UA" -H 'Accept-Encoding: <enc>' -v -w '<META>' <url>`, enc ∈ {identity, gzip, deflate, br, zstd} | 45 | 0 ×45 |
| 5 | `curl -fsSL --compressed -A "$UA" <final_url>` (S017, S018) | 2 | 0 ×2 |
| 6 | `curl -fsS --compressed -A "$UA" -w '%{stderr}%{http_code} %{size_download}\n' <registered url>` (no `-L`; S017, S018) | 2 | 0 ×2; returned `308 15` and body `Redirecting...\n` |
| 7 | `bash corpus/sources-census.sh` and `--selftest` | at S1 and S3 | 0 / 0 each time (verdict lines in the snapshot table) |
| 8 | Mutants M1–M4 against S1: one textual change each to a scratch copy of census `24d834cc…`, then `bash <copy> --selftest` and `bash <copy> verify --root <lane>` | 8 | see Defect B |
| 9 | Demos D0–D2 at S1 and D0–D3 at S3 (census `511deb27…`; `58bd8d7` changes only unused declarations): an unmodified census copy run as `verify --root <scratch>` over copies of `SOURCES.md`, `knowledge/`, `lessons/` and `source-fetches.tsv`, with only the S026 row mutated | 3 + 4 | S1: 0 / 1 / 0. S3: 0 / 0 / 0 / 0. |
| 10 | `awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv \| sort -u \| wc -l`, plus `$5` and `$9 … \| uniq -c` | 3 | 0. Results: `9`, `9`, `10 decoded-http-body-volatile-v1` |
| 11 | `git show 284d40e:corpus/sources-census.sh \| sed -n '64,66p;279,290p'`; `git log`; `git show HEAD:<f> \| sha256sum` | — | 0 (read-only) |
| 12 | `grep -rln 53dfeac5 .` (excluding `.git`); `git grep -n 'html.unescape\|unescape(' HEAD -- 'corpus/*.py' 'corpus/*.sh' corpus/fixtures` | 2 | 0. The `git grep` found one hit, the prose comment `sources-census.sh:74`, so no normalizer is committed. |

- **Hashes, normalization, row identity:** computed with Python 3.14.8 `hashlib`, `re` and `html`, in memory.
- **Host tools:** curl 8.23.0 (brotli, zstd, HTTP2) sends `Accept-Encoding: deflate, gzip, br, zstd` and `Accept: */*`. All responses were HTTP/2.
- **Scratch writes:** commands 8–9 used `tempfile.mkdtemp` under `/tmp`, outside the lane, the same way the gate's own
  selftest works. Every directory was removed: `os.path.exists` → False, and `ls -d /tmp/critdigest-r23-*` → exit 2.
- **Lane writes:** this report only.
- **Installs:** none. curl, python3 and the brotli CLI were already present.
- **Not run:** no claim-ledger verify, host gate, account, vault or credential read.

## Per-row re-measurement (final TSV lines)

Each URL yielded 8 bodies:

- 2 exact-profile GETs (commands 1–2)
- 1 wire GET, decoded locally (command 3)
- 5 GETs with a forced `Accept-Encoding` (command 4)

"Raw" and "normalized" in the table count how many of those 8 bodies match the TSV digest.

| id (TSV line) | TSV bytes = decoded length | `%{size_download}` on the profile GET (served coding) | raw | normalized | final URL / status |
|---|---|---|---|---|---|
| S017 (:38) | 1215460 | 164494 (br) | 8/8 | 8/8 | = / 200 after 308 |
| S018 (:39) | 1283173 | 167892 (br) | 8/8 | 8/8 | = / 200 after 308 |
| S019 (:40) | 1199447 | 166493 (br) | 8/8 | 8/8 | = / 200 |
| S020 (:41) | 190261 (8/8) | 39097 (gzip) | **0/8** (8 distinct) | 8/8 | = / 200 |
| S021 (:42) | 47384 | 12527 (gzip; `content-length: 12527`) | 8/8 | 8/8 | = / 200 |
| S022 (:43) | 386400 | 53338 (br) | 8/8 | 8/8 | = / 200 |
| S023 (:44) | 261632 | 40416 (br) | 8/8 | 8/8 | = / 200 |
| S024 (:45) | 586146 | 43087 (br) | 8/8 | 8/8 | = / 200 |
| S025 (:46) | 63046 | 13325 (gzip; `content-length: 13325`) | 8/8 | 8/8 | = / 200 |
| S026 (:47) | 47384 | 12527 (gzip) | 8/8 | 8/8 | = / 200 |

- **Row identity:** `sha256(id\tstatus\turl\n)` matches 10/10.
- **Wire is never the recorded value.** For every URL, wire length ≠ TSV bytes and wire sha256 ≠ TSV sha256.
  Examples: S017 wire `7f71326e…`, 164,494 B; S021 wire `5ae6661f…`, 12,527 B.
- **Content coding does not change the decoded body.** For every non-S020 URL, the identity, gzip and br responses
  decode to the same bytes, so the curl build's `Accept-Encoding` list cannot move the domain.
- **`bytes` counts bytes, not characters.** Every body contains non-ASCII text (S017: 1,215,460 B but 1,215,288
  characters), so a character count would show up as a mismatch.
- **No body ends in LF**, so shell `$(…)` trimming does not change any recorded count.
- **Redirect bodies are excluded.** The `-L` body equals a direct GET of the final URL.
- **S020 volatility is confined to one token.** Two S020 bodies differ in exactly 44 bytes at offsets 68,525–68,568,
  inside `href="/cdn-cgi/l/email-protection#<hex>"`. The normalized digest `20b4fd86…` matches 8/8.

## Defect A — whitespace class in rendered-text-v1 (medium at S1/S2; partly fixed at S3)

**Counterexample.** The normalized digests are the "more stable point attestation" (`source-fetches.tsv:19-21`) for
all 10 rows. Whether they reproduce depends on how "collapse whitespace" is read:

| reading | TSV normalized digests reproduced |
|---|---|
| declared order. Script/style removed with `<tag\b[^>]*>.*?</tag\s*>` (DOTALL, IGNORECASE) replaced by a space; `<[^>]+>` → space; `html.unescape`; `re.sub(r'\s+',' ')` on `str`; `.strip()` | **10/10** |
| same, but whitespace = ASCII `[ \t\n\r\f\v]+` (the census's `LC_ALL=C` `[[:space:]]` idiom) | **7/10.** Fails S022, S023, S024: after unescape they contain U+00A0 ×2, ×2, ×3. |
| `' '.join(s.split())` | 10/10 |
| no trim / tags → empty string | 0/10 / 0/10 |
| also strip `noscript`/`svg`/`template` | 9/10 (fails S020) |
| script/style → empty string; case-sensitive; `<[^>]*>`; comments removed first | 10/10 |
| the corpus's only executable recipe, `knowledge/vault-openbao-token-lease-lifecycle.md:92`, without `.lower()` | 4/10 |

**Status at S3.** `source-fetches.tsv:28` pins "collapse Unicode whitespace (Python \s)", which matches the 10/10
reading. Two of the three declaration sites still say only "collapse whitespace": `sources-census.sh:74` and
`round-23.md:41`. No normalizer is committed.

**Smallest safe correction.** Copy the TSV `:28` wording into `sources-census.sh:74` and `round-23.md:41`, so the three
authorities cannot drift. Optionally commit the normalizer with S022's U+00A0 as a test vector. Axes: calibration, freshness.

## Defect B — same-URL agreement (open at S1/S2; resolved at S3)

At S1 and S2, the census enforced same-URL agreement (`sources-census.sh:279-290` at `284d40e`):

- raw-digest agreement only for rows that are not volatile, and all 10 real rows are volatile
- normalized agreement keyed on `"$furl|norm|$fnorm"`, with no date

At `284d40e` this contradicted the declarations committed alongside it: `source-fetches.tsv:21` and
`sources-census.sh:64-66` both say "no cross-capture equality is enforced", and so does `round-23.md:52-54`.

S1 demos (unmodified census over scratch copies, only S026 mutated):

| demo | change to S026 | result at S1 |
|---|---|---|
| D0 | none | exit 0, CLEAN |
| D1 | a truthful later capture: `fetched` = 2026-10-22, different normalized digest | **exit 1:** `FINDING SC_FETCH id=S026 same-url-normalized-disagreement url=https://openbao.org/docs/concepts/tokens/` |
| D2 | same-day capture with raw `000…0`, bytes 47390, normalized unchanged | exit 0, CLEAN |

S1 mutants (one textual change each to a census copy):

| mutant | selftest | real-tree verify |
|---|---|---|
| M1: normalized check replaced by `:` | exit 0, PASS (59) | exit 0 |
| M2: agreement keyed by `$fid` instead of `$furl` | exit 0, PASS (59) | exit 0 |
| M3: volatile exemption removed | exit 0, PASS (59) | exit 0 |
| M4: every row exempt | exit 1 (`fetch-disagree`: findings=1, want 2) | exit 0 |

- **Why D1 matters.** Whole-page normalized digests do move between days: S017 was `7227ed88…` on 10-06 and 10-12,
  then `2a39cb16…` on 10-21 (`parent-build/SourceS017.md:80`). So the gate would have false-failed an honest
  recapture, and the cheapest way to pass would have been to copy the old digest.
- **Why M1–M3 survive.** The selftest fixture contained only `decoded-http-body-v1` rows, and `m_fetch_disagree`
  duplicated a single id, so no case exercised the paths the real rows take.

**Resolution at S3.** Commit `638d44c` removed the block and set `fetch-disagree` to expect 1 finding
(`sources-census.sh:553`). D1, D2 and D3 all exit 0 CLEAN at S3 (census `511deb27…`). D3 relabels S026 `decoded-http-body-v1` with raw
`000…0` and bytes 47390. The code now matches every declaration, and `round-23.md:148` (M23-1) records the old rule as
a mistake.

**Bound the claim must keep.** The `decoded-http-body-v1` / `-volatile-v1` label no longer has any machine effect (D3).
S021 and S026 agree because I measured them to agree (47,384 B, `52295218…`, `ed949658…`), not because the gate
enforces it.

## Bounds the claim must state (open at S3)

**B-1 — the `bytes` instrument (low).** `source-fetches.tsv:23` says only "byte count of the representation".

- curl's own `%{size_download}` is the content-coded transfer size. The same S017 body reports 164,494 (br), 251,207
  (gzip) or 1,215,460 (identity).
- `Content-Length` is also the wire size (OpenBao: 12,527 and 13,325).
- A verifier using either would "falsify" 10/10 rows.

Add: "bytes = `wc -c` of curl stdout after `--compressed` decoding; never `%{size_download}` or `Content-Length`."

**B-2 — one volatile label covers two different behaviors (low; calibration).** `round-23.md:45-47` singles out S020,
but all 10 rows are `decoded-http-body-volatile-v1` (`uniq -c` → 10). The measured behavior differs:

- **Per-response (S020):** 8 distinct raw digests in 8 GETs at a constant 190,261 B.
- **Per-deployment (the other 9 rows):** raw digest reproduced 8/8 today. The OpenBao bytes changed at the
  2026-10-20T07:50Z site redeploy (`round-22/build/Source14.md:132`). S017 changed within one build
  (`parent-build/SourceS017.md:193`).

The lesson should say that all 10 rows carry the label, and that a raw mismatch is expected for S020 but signals a
redeploy for the other nine.

**B-3 — S020's raw digest cannot be verified and has no recorded capture (low; provenance).**

- `source-fetches.tsv:41` records `53dfeac5…`. That is neither of the two GETs the lesson cites at `round-23.md:48`
  (`56ade2d0…`, `cbd70b29…`).
- `grep -rln 53dfeac5 .` (excluding `.git`) finds it only in `source-fetches.tsv` and in audit reports that flag it as
  untraceable. `parent-build/SourceS020.md:60-61,180-182` (untracked, mtime 04:00:40Z) independently reports this as
  F7: "a third capture the lesson does not mention". No file records the GET that produced it.
- 0/8 of my GETs reproduce any of the three values.

State that only `bytes` (190,261) and `normalized_sha256` (`20b4fd86…`) can be checked for S020.

**B-4 — counts and pinning (info).**

- **URL count.** The dispatch context's "10 declared captures … over 7 URLs" is false; I measured 9 (command 10).
  The tree fixed this during the run: lesson snapshot `d5520988…` said "seven", while `round-23.md:177`,
  `LOG.md:1202` and `SCORECARD.md:840` now say nine. The registry has 19 distinct URLs over 26 rows.
- **Pinning.** The census changed five times during the falsify wave (`80966e20…` → `24d834cc…` → `6d4190a7…` →
  `511deb27…` → `2d1bbbe3…`). Its verdict must be read against `58bd8d7`, not the dispatch-time tree.
- **W04 count (outside this seat; corroborates `RevClosurePointers.md`).** At `58bd8d7`,
  `bash corpus/sources-census.sh 2>&1` prints exactly one line (the CLEAN verdict) and zero W04 lines.
  `grep -n W04 corpus/sources-census.sh` exits 1, because the lane census has no W04 code. Yet `round-23.md:66`
  says "The census prints seven W04 duplicate-URL warnings", so it should name the fleet script that prints them.
  I did not run the fleet script.
