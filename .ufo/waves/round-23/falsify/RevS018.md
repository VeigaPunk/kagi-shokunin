# RevS018 — S018 provenance falsification (round 23)

Seat: `RevS018` (leaf reviewer, falsification). Axes: **calibration**, **freshness**,
**operability**. Scope: the S018 registry row, its `corpus/source-fetches.tsv`
provenance row, and the C2 gate behavior exercised to check them. No other source
row's captures were re-fetched; no claim-ledger row was executed.

Base: `d218603b74099ddca0bd8f869516fc41db0979bf` plus the uncommitted round-23
tree. **The tree moved during this review** (see §6); every measurement below is
timestamped and snapshot-pinned. Lane was treated read-only: the only lane write is
this report; all scratch work is under `/tmp/revS018`. No commits, installs, host
gates, vault/account commands, or secret reads.

## Verdict

**The S018 row itself reproduces exactly on 2026-10-21 and is not falsified.** URL,
final URL, HTTP status, byte count, raw digest, row-identity digest, normalization
digest, quote, location, status, and anchor set all match independent measurement.
The defects found are in the C2 gate/accounting around it, and the two that were
live when observed were repaired by concurrent integration during this review:

| id | severity | status at observation | current snapshot |
|---|---|---|---|
| F1 gate cannot run: `SUPERSEDED` unbound at `corpus/sources-census.sh:242` | Critical (operability) | reproduced, exit 1, no verdict | **fixed** (loop deleted); verify exit 0 CLEAN |
| F2 lesson claimed 10 rows over "seven" URLs; actual is 9 | Medium (calibration) | reproduced at lesson line 165 | **fixed** in lesson (:174 "nine"); wave claim text still says 7 |
| F3 S018 has a third, unregistered consumer | Low (calibration/pointer) | reproduced | inherited, unchanged |
| F4 round-end census expectation conflates two tools | Low (reproducibility) | reproduced | persists |

---

## 1. S018 row: independent re-measurement (passes)

Registry row: `corpus/SOURCES.md:24` (S018), line sha256
`d90338be21feff283ce72f1715670a880e97c8ba134a2680334d7ca6f7ce0390`, 569 B including
the trailing LF. Provenance row: `corpus/source-fetches.tsv:39` (line 38 before an added comment line),
line sha256 `39b9697df3aa6fc8a00c4019a8ba75950df40f35b4ee3c53d2fe7acc0f968278`, NF=16.
Both row byte sequences were stable across every snapshot observed (§6); only the
TSV line number moved 38→39.

Fetch (exact declared profile, 2026-10-21T03:58Z; response `cf-ray: a4dd58266812a484-GRU`):

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -D headers.txt -o body.html -w 'http=%{http_code} redirects=%{num_redirects} final=%{url_effective}\n' \
  'https://www.1password.dev/brokered-access/custom-workflow/'
# exit 0; http=200 redirects=1 final=https://www.1password.dev/brokered-access/custom-workflow
# headers: 308 -> location: /brokered-access/custom-workflow ; final 200
#          content-type: text/html; charset=utf-8 ; content-encoding: br
#          cf-cache-status: HIT ; age: 11649 ; date: Wed, 21 Oct 2026 03:58:31 GMT
```

| field | declared (`source-fetches.tsv:38`) | independent measurement | match |
|---|---|---|---|
| `url` | `https://www.1password.dev/brokered-access/custom-workflow/` | identical to URL extracted from `SOURCES.md:24` | yes |
| `final_url` | `https://www.1password.dev/brokered-access/custom-workflow` | `%{url_effective}` identical (308 strips slash) | yes |
| `http_status` | 200 | 200 (final) | yes |
| `bytes` | 1,283,173 | `wc -c body.html` = 1,283,173 | yes |
| `sha256` | `a06175824184168a9ed053c28be84e078eae9b256a5ede3f71d3aa223f31b450` | identical | yes |
| row identity | `ddb614c5d10e69bf33707d9696a66a702dfe2dcd1891027a94ecead73479bcf2` | `printf 'S018\tmined\t<url>\n' \| sha256sum` identical | yes |
| `normalized_sha256` | `d493bd815016219da8da33e18fb673aed3414155c6634a9139c7083ba7bae0fc` | identical (6,383 chars) | yes |
| `quote` | “Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta)” | exact text of `<h1 id="page-title">`; literal (not tag-split); 14 words | yes |
| `location` | `page title/H1` | H1 exists with `id="page-title"`; `<title>` is the same plus ` - 1Password Developer` | yes |
| `status` | mined | registry status mined | yes |

Normalization implementation used (per `source-fetches.tsv:25-29` and
`lessons/round-23.md`): remove `<script>…</script>` / `<style>…</style>` elements
with content, replace tags with a single space, `html.unescape`, collapse `\s+` to
one space, trim, UTF-8 encode → 6,383 chars, digest above. Two further same-session
GETs were byte-identical (`cmp` exit 0; body2/body3 sha256 identical), and the
parent-build capture at 03:43Z recorded the same 1,283,173 B /
`a0617582…` (`parent-build/SourceS018.md`, §1 and §3).

Row anchors also re-checked in the live normalized text (all present): introduction
(“If an administrator has connected an OIDC provider to your 1Password Business
account”), Step 1 (“make sure you have the latest beta release of the 1Password
desktop app”), Step 3 note (“1Password Credential Broker is only supported in the
1Password JavaScript SDK at this time.”), and the H1.

Gate reachability: on a scratch fixture copy
(`/tmp/revS018/root`, TSV `url` mutated for S018 only), the SC_FETCH loop emitted
`FINDING SC_FETCH id=S018 url-mismatch` and exit 1. So the row is actually walked by
the gate, and the clean runs below are not a skipped-row artifact.

---

## 2. Findings

### F1 — Critical when observed: the C2 gate aborted before any verdict

Snapshot A of `corpus/sources-census.sh` (sha256
`80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781`, 613 lines,
mtime 2026-10-21 00:57:55 local) failed on the production tree:

```
$ bash corpus/sources-census.sh
corpus/sources-census.sh: line 242: S007: unbound variable
$ echo $?
1
```

No `SOURCES_CENSUS:` verdict line was produced. Cause, read from the file:

- `set -uo pipefail` at `corpus/sources-census.sh:107`.
- The fetch-provenance block declares only
  `declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()` at `:229`.
- `:242` is `while IFS= read -r fid; do [[ -n $fid ]] && SUPERSEDED[$fid]=1; done < <(awk …)`,
  and `SUPERSEDED` is never declared anywhere (`grep -n SUPERSEDED` matched only
  this line). Under `set -u`, an undeclared `name[subscript]` assignment is an
  *indexed* array whose subscript is arithmetic, so the first value `S007` is
  evaluated as a variable name and aborts the shell function.
- Minimal repro: `bash -c 'set -u; a=(x); i=S007; a[$i]=1'` →
  `bash: line 1: S007: unbound variable`.
- `S007` is the first superseded id printed by the accompanying awk (`:242-246`);
  it comes from `SOURCES.md:25` (S019's teaches field starts “supersedes S007 —”).
- The block is new in the round-23 diff: `git diff -U3 -- corpus/sources-census.sh`
  shows the `SUPERSEDED[$fid]=1` loop as an added (`+`) hunk. The base gate runs
  clean on the same tree: `git show HEAD:corpus/sources-census.sh > /tmp/revS018/base-census.sh`
  then `bash /tmp/revS018/base-census.sh verify --root …` → exit 0,
  `SOURCES_CENSUS: CLEAN (rows=26 …)`. So this was a round-23 regression, not a
  pre-existing condition.
- The value written to `SUPERSEDED` was never read (`grep -n SUPERSEDED` has no
  consumer). The loop was dead code, and `grep` shows the loop's only effect was
  the crash.

Why the 59-case selftest did not catch it: `bash corpus/sources-census.sh --selftest`
→ exit 0, `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` even at snapshot A. The
fixture registry rows use teaches values `teaches one/two/three/four`
(`corpus/sources-census.sh:355-356,392-393` for the current file); `supersedes`
appears **nowhere** in the selftest fixtures (`grep -n supersedes corpus/sources-census.sh`
matched only the production awk at `:245`). The feature that crashed production was
outside the 59 cases, so the green selftest was not evidence the gate ran on the
real registry.

Blast radius: claim row `R21-02` (`corpus/claim-ledger.tsv:52`) executes exactly
`bash corpus/sources-census.sh` and requires the exact CLEAN line
`^SOURCES_CENSUS: CLEAN \(rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21\)$`.
At snapshot A that row could not pass. (The ledger row itself was not executed —
contract.)

Diagnostic, not production fix: a `/tmp` copy of snapshot A with one token added
(`SUPERSEDED=()` on `:229`) ran

```
$ bash /tmp/revS018/census-fixed.sh verify --root /home/vgpnk/Projects/shokunin/kagi-shokunin
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit 0
```

with zero `SC_FETCH` findings. This proves the S018 data row was clean and the only
blocker was the undeclared array.

Current state: snapshot B (`corpus/sources-census.sh` sha256
`24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057`, 608 lines,
mtime 01:02:21 local) **deletes the SUPERSEDED loop**. Current run:

```
$ bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)
exit 0
```

and the last line matches R21-02's expected regex exactly (checked with `grep -Ex`;
`MATCH`). `diff -u` between my `/tmp` fixed copy and snapshot B shows only the
deletion of that loop plus my added declaration token, so no other semantic change
entered with the repair. Deletion is fail-closed: the array was never read, and the
superseded rows S006/S007/S012/S013/S014/S016 all still carry in-row `Fetch sha256:`
pins, so `missing-provenance` coverage is unaffected. The latest census snapshot
(`511deb2730614663c86beb9b6793b54eea75ce8a9dbe4f1cf372999697339b58`, 592 lines,
mtime 01:10:59 local) keeps the deletion and additionally drops the now-unused
`FDIG`/`FNRM` same-URL comparisons; verify is still exit 0 CLEAN and the selftest
still passes 59 cases. A fresh URL mutation of S018 against this latest copy still
yields `FINDING SC_FETCH id=S018 url-mismatch` (exit 1).

Residual action for integration: pin the landed census to snapshot B or later. Any
claim or report that measured the census before 01:02:21 was measuring a gate that
could not run; snapshot A's `S007: unbound variable` is reproducible from the
preserved copy `/tmp/revS018/census-snapshotA.sh` (sha256 re-verified to
`80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781`).

### F2 — Medium when observed: the "seven distinct URLs" accounting was false

At snapshot A, `corpus/lessons/round-23.md:165` read: “`source-fetches.tsv` carries
10 declared provenance rows (S017-S026) over seven distinct URLs.” Measurement:

```
$ awk -F'\t' '$0!~/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l
9
$ awk -F'\t' '$0!~/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort | uniq -d
https://openbao.org/docs/concepts/tokens/
```

10 rows, 9 distinct URLs. S021 and S026 share the OpenBao tokens URL and have
identical raw and normalized digests (`5229521866…` / `ed949658…`), so snapshot
B's same-URL agreement checks (`corpus/sources-census.sh:282,288` then) passed;
the latest census removes those comparisons entirely (`FDIG`/`FNRM` are declared
but unread), leaving a per-row gate.
The subset S017–S023 is seven rows over seven distinct URLs, which likely explains
where the number came from, but the written range S017–S026 is false.

Current state: the lesson now reads **nine**. Snapshot B (sha256
`2f53cf690d81666a4b2510e6b611bd55cdf61a260020c28c6480d788183dcf53`, mtime
01:04:15 local) had it at line 170; the latest observed snapshot E (sha256
`49632920e11189562ade4410c002f51206b33c66e9ce57805efcc940fa81f699`, mtime
01:11:27 local) still reads nine at line 174. The registry-side accounting in the same
paragraph (26 rows over 19 distinct URLs; 16 in-row pins + 10 provenance rows) was
independently verified and is correct.

Residual action: the wave's C2 claim text still says “10 declared captures S017-S026
over 7 URLs” (`.ufo/waves/round-23/falsify-spec.json:3`,
`falsify-dispatch.json:805`). It should say **9** before it is quoted as the C2
claim; the lesson alone is now correct.

### F3 — Low, inherited: S018 has a third consumer that neither side registers

`S018.used-by` (`corpus/SOURCES.md:24`) lists only
`corpus/lessons/round-22.md, corpus/knowledge/feature-bound-credential-review.md`.
`corpus/knowledge/onepassword-machine-credentials.md` (sha256 `8380b359…`, mtime
2026-10-20 19:40 local) consumes S018 at `:42` (bare `S018 (custom-workflow feature
page, title and Steps 1/3)`), `:52` (`[S018]`), and `:55` (`[S018]`), but its
`source:` line (`:2`) plus its continuations contains zero occurrences of S018 —
the only S018 references in the file are body lines 42/52/55 — and its path is
absent from S018's used-by. The census checks only the `source:` field (`src_field` at
`corpus/sources-census.sh:141`; `SC_USEDBY_NOCITE` at `:219-221`; `SC_ENTRY_CITE`
at `:300-309` on the latest observed census), so the body-only consumer is
invisible to the gate. This is a
round-22 pointer gap inherited by the round-23 capture row, not a defect in the
S018 digest row; it matters only if C2 is read as a consumer-complete provenance
enumeration (it is not).

### F4 — Low, persists: the round-end census expectation mixes two tools

Current `corpus/lessons/round-23.md:177-179` requires “census at round end … exit 0
with the same W04 warnings and `rows=26`.” No single tool produces both:

- `grep -c W04 corpus/sources-census.sh` → **0**. The lane gate prints
  `rows=26` (verified exit 0) and never W04.
- W04 is emitted by the fleet tool
  `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh:645` as
  `printf "%s\tW04\t%s duplicate url %s across scopes\n",lane,id,u` — a
  lane-prefixed, tab-separated record. That tool has no `rows=` output
  (`grep -n "rows=" /home/vgpnk/Projects/shokunin/scripts/sources-census.sh` is
  empty; it emits `lane<TAB>rows<TAB>N` at `:691`).
- The lesson's five quoted W04 lines omit the lane field and use spaces, so the
  “quotes them verbatim” claim does not match the `:645` emitter either.

This does not invalidate the lane gate or the W04 warnings; it makes the stated
round-end acceptance check non-executable as written. The expectation should name
both invocations (`bash corpus/sources-census.sh` for the `rows=26` verdict; the
fleet census for the five lane-prefixed W04 lines) and quote each format exactly.

---

## 3. Confirmed bounds (not defects)

- **Volatile representation.** `decoded-http-body-volatile-v1` is declared for S018.
  Same-session raw identity was 3/3, but the round-22 pin (`d0890c11…` at
  `corpus/feature-claims.json:123`, observed 2026-10-20; 1,282,825 B per
  `parent-build/SourceS018.md` §3) differs from today's 1,283,173 B with unchanged
  JSON-LD `dateModified` (`2026-08-17T22:36:47.822Z`, verified in the fetched body),
  so raw equality across days is not a valid expectation. The declared normalized
  digest matched today; the lesson's own new bounds section records that normalized
  digests for S017/S023 moved between days, so it is a same-day declared identity,
  not a cross-day pin. The volatile marker is conservative, not contradicted.
- **Single-quote coverage.** The TSV quote binds only the H1 status conjunct of the
  row's `teaches` (public beta). The other three conjuncts (Business/OIDC
  prerequisite, beta desktop app, JavaScript SDK only) were re-verified in the live
  normalized text here, but no TSV quote machine-binds them;
  `corpus/feature-claims.json:127-131` records four separate anchors for this row.
  C2's one-quote schema is a floor, not coverage (parent-build M3, inherited).
- **CDN cache.** `cf-cache-status: HIT`, `age: 11649` (~3.2 h), one host/edge. The GET
  attests the served representation, not origin generation; the row's `fetched` date
  is the GET date, which is what the schema claims.
- **Normalization is prose, not code.** My element-removal implementation reproduces
  the declared digest exactly (6,383 chars). A plausible variant that strips tags
  before removing script bodies yields 1,136,743 chars / `84da1b38…`, not the
  declared value. The declared digest is consistent with the documented
  “strip `script`/`style`” (element-with-content) reading; the recipe should state
  element-vs-tag semantics explicitly. This is a reproducibility caveat around the
  row, not a wrong digest in the row. (For S018 this ambiguity does not affect the
  quote: the chosen quote is literal in the H1 and `<title>`, unlike the
  introduction/Step 3 sentences, which are normalization-only.)
- **The gate is shape-only on digests.** On a scratch copy, replacing S018's
  `sha256` and `normalized_sha256` with 64 zeros still yielded
  `SOURCES_CENSUS: CLEAN` (exit 0) and no S018 finding. The digest *values* are never
  compared; this matches the TSV header's “point attestation” bound. The value
  check in this report is the live re-fetch, not the gate.
- **No deployed-product proof.** No account, OIDC provider, desktop app, SDK, or
  workflow was exercised; the page is documentation only.

---

## 4. Residual risk and verification gaps

- **Moving tree.** F1 and F2 were live at snapshot A and were fixed by concurrent
  edits at 01:02:21, 01:04:15, 01:06:58, 01:08:16/01:08:48 and 01:10:37/01:10:59/
  01:11:27 local (last observation before this report was written). Any later edit
  can invalidate the line citations; integration should pin the snapshot hashes in
  §6 and re-run the two named commands once on the landed tree. The lesson's new
  `## Falsification bounds (round 23)` section (`:181-194`) already states the wave
  “confirmed the three claims” while the census repair, the lesson edits and this
  report were still in flight; that sentence should be re-read against the settled
  tree, not quoted as a pre-existing result. Its C2 bounds (shape-only, quote not
  substring-checked, point attestations) agree with the mutation result in §3.
- The census's 59-case selftest still has no case with a `supersedes S…` teaches row
  (the feature that caused F1 is now deleted, so this is a latent coverage note, not
  an open failure). If supersession logic is reintroduced, add a fixture with a
  superseded id and a `SUPERSEDED` consumer before trusting the selftest.
- One host/CDN edge and one network path were exercised; no Wayback/Software
  Heritage or second-geo check was made. The S018 fetch was a cache HIT at ~3.2 h
  age.
- I did not run the claim ledger, `feature-claims.py`, closure obligations, C3
  fixtures, or any host-bound row (contract). R21-02's expected verdict line was
  compared as text against the current census output only.
- No installs or updates were performed. Scratch artifacts live under
  `/tmp/revS018` (`body.html`, `census-snapshotA.sh`, `census-fixed.sh`, mutation
  roots); none is in the lane.

---

## 5. Command log (exits and observed output)

```
# S018 fetch (exact declared profile)
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -D headers.txt -o body.html -w 'http=%{http_code} redirects=%{num_redirects} final=%{url_effective}\n' \
  'https://www.1password.dev/brokered-access/custom-workflow/'
# exit 0; http=200 redirects=1 final=https://www.1password.dev/brokered-access/custom-workflow
wc -c body.html; sha256sum body.html
# 1283173 ; a06175824184168a9ed053c28be84e078eae9b256a5ede3f71d3aa223f31b450
printf 'S018\tmined\thttps://www.1password.dev/brokered-access/custom-workflow/\n' | sha256sum
# ddb614c5d10e69bf33707d9696a66a702dfe2dcd1891027a94ecead73479bcf2   (row identity)
sed -n '24p' corpus/SOURCES.md | sha256sum
# d90338be21feff283ce72f1715670a880e97c8ba134a2680334d7ca6f7ce0390   (569 B incl LF)
python3 (script/style element removal, tags->space, unescape, \s+->space, trim)
# 6383 chars ; d493bd815016219da8da33e18fb673aed3414155c6634a9139c7083ba7bae0fc

# C2 gate
bash corpus/sources-census.sh                    # snapshot A: exit 1, "line 242: S007: unbound variable"
bash /tmp/revS018/census-snapshotA.sh verify --root <lane>   # exit 1, same message (preserved copy, sha 80966e20…)
bash /tmp/revS018/census-fixed.sh verify --root <lane>       # exit 0, CLEAN rows=26, zero SC_FETCH findings
bash corpus/sources-census.sh                    # snapshots B–E: exit 0, CLEAN rows=26
bash corpus/sources-census.sh --selftest         # exit 0, PASS (59 cases), every snapshot observed
bash /tmp/revS018/census-latest.sh verify --root <scratch>   # latest copy: url mutation -> exit 1, id=S018 url-mismatch; digest zeros -> exit 0 CLEAN
git show HEAD:corpus/sources-census.sh > /tmp/revS018/base-census.sh
bash /tmp/revS018/base-census.sh verify --root <lane>        # exit 0, CLEAN rows=26 (base isolates regression)

# Mutation checks on scratch root
# url -> https://example.invalid/wrong : exit 1, FINDING SC_FETCH id=S018 url-mismatch
# sha256 + normalized_sha256 -> 64 zeros : exit 0, CLEAN (no S018 finding; shape-only)
# (both re-run against /tmp/revS018/census-latest.sh, the 01:10:59 snapshot: same results)

# Cardinalities
awk -F'\t' '$0!~/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l   # 9
awk -F'\t' '$0!~/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv | sort | uniq -d       # openbao tokens
grep -c 'Fetch sha256:' corpus/SOURCES.md        # 16
grep -c '^| S[0-9][0-9][0-9] ' corpus/SOURCES.md # 26
awk -F'|' '… URL extraction …' corpus/SOURCES.md | sort -u | wc -l   # 19 distinct registry URLs
grep -c W04 corpus/sources-census.sh             # 0
```

---

## 6. Snapshot hashes (tree moved during review; local time -03:00, UTC noted)

| artifact | first observed (~00:58–01:00 local / 03:58–04:00Z) | latest observed (01:12 local / 04:12Z) |
|---|---|---|
| `corpus/sources-census.sh` | sha256 `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781`, 613 lines, mtime 00:57:55; verify exit 1 (`S007: unbound variable`) | sha256 `511deb2730614663c86beb9b6793b54eea75ce8a9dbe4f1cf372999697339b58`, 34,805 B, 592 lines, mtime 01:10:59; verify exit 0 CLEAN, R21-02 regex MATCH, selftest PASS (59). The repair landed at 01:02:21 (`24d834cc…`); later snapshots also drop the unused FDIG/FNRM same-URL comparisons. |
| `corpus/lessons/round-23.md` | line 165: “over seven distinct URLs” (read at ~00:58; snapshot hash not taken before the edit) | sha256 `49632920e11189562ade4410c002f51206b33c66e9ce57805efcc940fa81f699`, 15,426 B, mtime 01:11:27; line 174 “over nine distinct URLs”; W04 expectation :177-179; “Falsification bounds (round 23)” begins :181. Intermediate: 01:04:15 `2f53cf69…` nine at :170; 01:06:58 `993e114a…` nine at :174; 01:08:16 `cf79cd0c…` nine at :174. |
| `corpus/source-fetches.tsv` | sha256 `ccc9ae6ec1b4bfa2ea8d879762a8fca18a84673145b54a04f39530de2d65a0af`, 7,731 B, mtime 00:55:22; S018 at :38, line sha `39b9697d…` | sha256 `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d`, 7,848 B, mtime 01:10:37; S018 at :39, line sha still `39b9697d…`; still 10 rows / 9 distinct URLs. |
| `corpus/SOURCES.md` | sha256 `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29`, 24,995 B, mtime 00:49:17; S018 at :24, line sha `d90338be…` | sha256 `c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d`, 25,330 B, mtime 01:11:27; S018 at :24, line sha still `d90338be…` (the file moved, the row did not). |
| `corpus/knowledge/onepassword-machine-credentials.md` | sha256 `8380b35927e96b89fc0da7832516ecaff2a8e097660b47c599f560344709cf48`, mtime 2026-10-20 19:40 | unchanged (same hash/mtime). |

The S018 bytes themselves were stable across every snapshot: the registry line
(`SOURCES.md:24`, `d90338be…`) and the provenance line (`source-fetches.tsv:39`
after the 38→39 move, `39b9697d…`) did not move while the surrounding files were
being edited.

Tool versions: bash 5.3.20(1), curl 8.23.0 (brotli 1.2.0), Python 3.14.8.

**Final scoped verdict:** S018's capture row is accurate and reproducible today;
the row is **not** falsified. C2's gate was broken in snapshot A and repaired
mid-review (census B, still clean in the latest observed E); the “seven URLs”
accounting was wrong in snapshot A and is corrected to nine in the current lesson
(E, :174), but the wave claim text still repeats seven. F3 and F4 remain low-severity,
inherited/reporting issues. This report is
advisory evidence, not an admission or curation decision.
