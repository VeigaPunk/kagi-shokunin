# ScoutRowsClassify — round-23 falsification: rows, pins, tsv URLs, coverage

Seat: falsification scout (leaf, no dispatch). Lane root
`/home/vgpnk/Projects/shokunin/kagi-shokunin`, base
`d218603b74099ddca0bd8f869516fc41db0979bf` + uncommitted round-23 tree.
Measured 2026-10-21T04:00Z–04:06Z. **The tree changed under me during the audit**;
every number is pinned to a file hash below.

## What I attacked

C2/D7 row accounting:

1. all 26 registry rows in `corpus/SOURCES.md`;
2. the partition into in-row `Fetch sha256:` pins vs declared rows in
   `corpus/source-fetches.tsv`;
3. the tsv's distinct-URL cardinality ("10 declared captures S017-S026 over
   7 URLs" as dispatched);
4. row coverage: every registry row exactly once by one provenance form.

## Commands and exits (all run from the lane root)

### Independent parser (primary measurement)

`python3 - <<'PY' … PY` — exit **0**. Full script in the appendix.
Output (tsv snapshot `a78fde7b…`; the earlier `ccc9ae6e…` snapshot gave the
same cardinalities and zero mismatches):

```
M rows=26 unique=26 pinned=16 tsv=10 tsv_unique_ids=10
M coverage_values=[1] not_once=[]
M tsv_bad=[] dup_ids=[] tsv_distinct_urls=9 registry_distinct_urls=19
M total_fields=[16]
M URL https://1password.com/blog/1password-credential-broker-public-preview <- S020
M URL https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2 <- S024
M URL https://developer.hashicorp.com/vault/docs/auth/jwt <- S022
M URL https://developer.hashicorp.com/vault/docs/concepts/lease <- S023
M URL https://openbao.org/docs/auth/jwt/ <- S025
M URL https://openbao.org/docs/concepts/tokens/ <- S021,S026
M URL https://www.1password.dev/brokered-access <- S019
M URL https://www.1password.dev/brokered-access/custom-workflow/ <- S018
M URL https://www.1password.dev/brokered-access/github-actions/ <- S017
```

The script parses `^\| (S\d{3}) ` rows, takes the URL after the final em dash,
takes status from column 8, parses the tsv (non-`#`, 16 fields), checks
`status` and exact `url` equality against the registry, recomputes
`sha256(id<TAB>status<TAB>url<LF>)` from **registry** values and compares it to
the tsv `row_identity_sha256`, and counts per-row provenance forms.

### Count commands

| command | output | exit |
|---|---|---|
| `grep -cE '^\| S[0-9]{3} ' corpus/SOURCES.md` | `26` | 0 |
| `grep -c 'Fetch sha256:' corpus/SOURCES.md` | `16` | 0 |
| ``grep -oE 'Fetch sha256: `[0-9a-f]{64}`' corpus/SOURCES.md \| wc -l`` | `16` | 0 |
| `awk -F'\t' '!/^#/ && NF>=16 {u[$4]++} END{print length(u)}' corpus/source-fetches.tsv` | `9` | 0 |
| `awk -F'\t' 'NF>0 && !/^#/ && NF!=16 {print NR, NF}' corpus/source-fetches.tsv` | (no output) | 0 |

Anchors: pinned rows are `corpus/SOURCES.md:7-22` (S001–S016); unpinned rows
are `corpus/SOURCES.md:23-32` (S017–S026); tsv data rows are
`corpus/source-fetches.tsv:37-46` (S017–S026).

### Named gate

| command | snapshot | output | exit |
|---|---|---|---|
| `bash corpus/sources-census.sh` | census `24d834cc…` | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` | **0** |
| `bash corpus/sources-census.sh --selftest` | census `24d834cc…` | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)` (12 `fetch-*` cases included) | **0** |
| `bash corpus/sources-census.sh` | census `80966e20…` (mtime 00:57:55 -0300) | `corpus/sources-census.sh: line 242: S007: unbound variable` (twice, deterministic; 0 FINDING lines, no verdict) | **1** |
| `BASH_ENV=/tmp/r23_preamble.bash bash corpus/sources-census.sh` (`declare -A SUPERSEDED=()`) | census `80966e20…` | `SOURCES_CENSUS: CLEAN (rows=26 …)` | **0** |

The `80966e20…` crash was `SUPERSEDED[$fid]=1` on an undeclared associative
array under `set -uo pipefail` (`sources-census.sh:107`); bash evaluated the
subscript `S007` arithmetically and nounset killed it. The `24d834cc…` snapshot
removed that block entirely (`grep -n SUPERSEDED` is empty) and passes. See F3.

## Findings

### F1 — DEFECT (claim text): "7 URLs" is false; the tsv covers **9** distinct URLs

At measurement time the claim appeared in:

- `corpus/lessons/round-23.md:164-165` (snapshot sha256 `e111cd59…`,
  mtime 00:56:17): "`source-fetches.tsv` carries 10 declared provenance rows
  (S017-S026) over seven distinct URLs."
- `LOG.md:1202` (pre-rewrite content, mtime 00:54:08): "(10 declared captures
  over 7 URLs)".
- `SCORECARD.md:840` (pre-rewrite content): "S024-S026 are correction rows over
  seven distinct URLs, not new coverage ground."
- the wave C2 sentence as dispatched to this seat: "10 declared captures
  S017-S026 over 7 URLs".

Measured on `corpus/source-fetches.tsv` sha256 `ccc9ae6e…` (mtime 00:55:22) and
again on `a78fde7b…` (mtime 01:04:32): **10 rows over 9 distinct URL strings**.

The 9 (covering rows):

1. `https://www.1password.dev/brokered-access/github-actions/` — S017
2. `https://www.1password.dev/brokered-access/custom-workflow/` — S018
3. `https://www.1password.dev/brokered-access` — S019
4. `https://1password.com/blog/1password-credential-broker-public-preview` — S020
5. `https://openbao.org/docs/concepts/tokens/` — S021 **and** S026
6. `https://developer.hashicorp.com/vault/docs/auth/jwt` — S022
7. `https://developer.hashicorp.com/vault/docs/concepts/lease` — S023
8. `https://developer.hashicorp.com/vault/api-docs/secret/kv/kv-v2` — S024
9. `https://openbao.org/docs/auth/jwt/` — S025

Diagnosis: **7** is exactly the distinct-URL count of S017–S023 (seven rows,
seven URLs — the tsv before S024–S026 were appended). S024 adds a ninth URL;
S025 adds another; S026 reuses S021's. The registry-level count is correct:
**26 rows over 19 distinct URLs** (18→19, only KV v2 new), matching
`corpus/lessons/round-23.md:164-165`'s "Distinct URLs: 18 → 19".

Mid-wave correction observed (this is flux, not agreement): `LOG.md` and
`SCORECARD.md` were rewritten at 04:02:31Z and the lesson at 04:04:15Z to say
"nine"/"9". Current snapshots: lesson `2f53cf69…:170` ("over nine distinct
URLs"), LOG `b7d33029…:1202` ("over 9 distinct URLs"), SCORECARD
`1d7210b3…:840` ("the 10 captures cover nine distinct URLs"). The wave C2
sentence in the dispatch still says 7 and must be restated before booking.

### F2 — CONFIRMATION: every one of the 26 rows is covered exactly once

- In-row pins: **16** rows, S001–S016, `corpus/SOURCES.md:7-22`; each has
  exactly one `Fetch sha256:` and one 64-hex digest (16/16 shape).
- Declared provenance: **10** rows, S017–S026,
  `corpus/source-fetches.tsv:37-46`; every row has exactly 16 tab-separated
  fields, ids unique, all statuses `mined` matching the registry.
- The two sets are disjoint (pins stop at S016; tsv starts at S017), and the
  coverage histogram is `{1: 26}` — no row has zero forms and no row has two.
- All 10 tsv rows match their registry row on `status` and exact URL string,
  and the recomputed `row_identity_sha256` equals the declared value
  (`tsv_bad=[]`: zero status/url/row-digest mismatches).
- Independent of the census, and corroborated by the current gate:
  `SOURCES_CENSUS: CLEAN … rows=26` exit 0, 0 FINDING lines, and the 12
  `fetch-*` selftest cases inside the passing 59-case run.

So the "ten registry rows without an in-row pin" reading
(`plans/round-23.md:22`, `corpus/lessons/round-23.md:61`) holds; only the URL
cardinality attached to it (F1) was wrong.

### F3 — Flux boundary (no current defect, but claims must pin snapshots)

The tree was edited during this audit (table mtimes are local -0300; UTC = local + 3h):

| file | hash | mtime | note |
|---|---|---|---|
| `corpus/SOURCES.md` | `06dde644…` | 00:49:17 | stable throughout; 26 rows |
| `corpus/source-fetches.tsv` | `ccc9ae6e…` → `a78fde7b…` → `846b2037…` | 00:55:22 → 01:04:32 → 01:06:58 | cardinalities unchanged across all three; header wording and S022 `location` changed (`JWT verification, Vault 1.17 note` → `Introduction, Vault 1.17 Note`); quotes/normalized digests unchanged in the columns compared |
| `corpus/sources-census.sh` | `80966e20…` → `24d834cc…` | 00:57:55 → 01:02:21 | intermediate snapshot crashed (F3 command table); current exits 0 |
| `corpus/lessons/round-23.md` | `e111cd59…` → `2f53cf69…` → `cf79cd0c…` | 00:56:17 → 01:04:15 → 01:08:16 | "seven" → "nine" distinct URLs (the latest rewrites keep nine) |
| `LOG.md` | pre-rewrite → `b7d33029…` | 00:54:08 → 01:02:31 | "7" → "9" |
| `SCORECARD.md` | pre-rewrite → `1d7210b3…` | → 01:02:31 | "seven" → "nine" |

Last check 2026-10-21T04:08:19Z, after two further rewrites of the tsv and
lesson: re-running the verifier on tsv `846b2037…` reproduced
`rows=26 pinned=16 tsv=10 fields=[16]`, `cover=[1] not_once=[] bad=[] dup=[]`,
`urls=9 regurls=19`, and the lesson still reads "over nine distinct URLs".
A claim that cites the census must name the hash: `24d834cc…` exits 0;
`80966e20…` does not (S007 unbound). The tsv representation/normalization
semantics are the digest-domain seat's call; I only record that the file
changed after my first measurement.

## Bound the claim must state

- "10 declared provenance rows S017–S026 over **9 distinct URLs** (S021 and
  S026 share the OpenBao tokens URL); 16 historical in-row pins S001–S016;
  registry 26 rows over 19 distinct URLs."
- "Every registry row has exactly one provenance form (16 pins + 10 declared
  rows, disjoint)" — independently verified and enforced by `SC_FETCH`
  (`missing-provenance`, `duplicate-provenance`).
- Any census exit-0 assertion must cite `corpus/sources-census.sh` sha256
  `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057`
  (59-case selftest PASS); do not cite `80966e20…`.
- The wave C2 text (and any artifact copy of it) must say **9**, not 7; the
  lesson/LOG/SCORECARD have been corrected in-tree during the wave, but the
  dispatch claim consumed by this seat still read 7.

## Not verified (bounds of this seat)

- No network re-fetch; tsv digests, quotes and normalization were not
  re-derived from the live pages (digest-domain peers' question). I verified
  only shape/identity/URL/coverage.
- Did not re-run the parent's 43 claim-ledger row audits; did not execute a
  host-bound row.
- Line numbers are pinned to the hashes above; the tree was in flux and later
  edits can move them.

## Appendix — verbatim verifier

```python
import hashlib, re
rows = []
for ln, line in enumerate(open('corpus/SOURCES.md', encoding='utf-8'), 1):
    m = re.match(r'^\| (S\d{3}) ', line)
    if not m: continue
    cells = [c.strip() for c in line.strip().strip('|').split('|')]
    rows.append((cells[0], cells[1].rsplit('—',1)[1].strip(), cells[7], ln,
                 'Fetch sha256:' in line))
by = {r[0]: r for r in rows}
data = []
for ln, line in enumerate(open('corpus/source-fetches.tsv', encoding='utf-8'), 1):
    if line.startswith('#') or not line.strip(): continue
    data.append((ln, line.rstrip('\n').split('\t')))
seen, bad = {}, []
for ln, f in data:
    rid, status, rowid, url = f[0], f[1], f[2], f[3]
    seen[rid] = seen.get(rid,0)+1
    r = by.get(rid)
    if not r: bad.append(('id-not-in-registry', rid)); continue
    if status != r[2]: bad.append(('status', rid))
    if url != r[1]: bad.append(('url', rid))
    calc = hashlib.sha256(f'{rid}\t{r[2]}\t{r[1]}\n'.encode()).hexdigest()
    if rowid != calc: bad.append(('rowdigest', rid))
cover = {r[0]: int(r[4]) + (1 if r[0] in seen else 0) for r in rows}
urls = {}
for ln, f in data: urls.setdefault(f[3], []).append(f[0])
print('M rows=%d unique=%d pinned=%d tsv=%d tsv_unique_ids=%d' % (
    len(rows), len(by), sum(r[4] for r in rows), len(data), len(seen)))
print('M coverage_values=%s not_once=%s' % (
    sorted(set(cover.values())), [k for k,v in cover.items() if v!=1]))
print('M tsv_bad=%s dup_ids=%s tsv_distinct_urls=%d registry_distinct_urls=%d' % (
    bad, [k for k,v in seen.items() if v!=1], len(urls), len({r[1] for r in rows})))
print('M total_fields=%s' % sorted({len(f) for _,f in data}))
for u, ids in sorted(urls.items()): print('M URL %s <- %s' % (u, ','.join(ids)))
```

`PY_EXIT=0`.
