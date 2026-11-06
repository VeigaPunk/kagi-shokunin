# K47ScoutSources — round 47 independent re-open of S094, S099, S040, S041 + assimilation check

Seat: `K47ScoutSources` (leaf, no subagents). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`
(branch `master`, BASE `252ef1cac9f41d84639c0d1f211d0e0911196112`).
Scratch: `HYAKU_SCRATCH=/fast/scratch/hyaku` → `S=/fast/scratch/hyaku/kagi-r47/K47ScoutSources`
(`mkdir -p`; removed on exit by `trap 'rm -rf -- "$S"' EXIT`).
Receipts copied before exit to `.ufo/waves/round-47/build/K47ScoutSources-receipts/`.

Axes exercised: **calibration** (C1) and **freshness** (C2). Nothing in `corpus/`, `plans/`,
`SCORECARD.md`, `LOG.md`, registry rows, `MANIFEST.json`, `.ufo/state` or any sibling repo was
written or mutated. Only this report dir and the scratch dir were created. No git mutation was run
(`git cat-file` / `git ls-tree` / `git rev-parse` / `git log` only).

---

## 1. Re-open table (four rows)

Profile for every fetch: `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation
verification)' <url>` (the profile the registry's `request_profile` column declares). Two
independent fetches per URL were taken (19:34:20–21Z and 19:37:01Z); the second was compared byte
for byte with the first and was **identical** in all four cases.

| id | fetched_at (UTC) | http | sha256 | bytes | quote | located at | verdict |
|---|---|---|---|---|---|---|---|
| S094 | 2026-11-06T19:34:21Z (recheck 19:37:01Z) | 200 (curl exit 0) | `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8` | 11296 | `Only \`status\`, \`recheck\` and \`used-by\` change in place` | raw byte offset **6172**, line **116** (Rules item 2) | **reproduced exactly** — sha256 and byte count equal the registry row and the round-39 capture; `cmp` vs `.ufo/waves/round-39/capture/S094.body` exit **0**; also byte-identical to the fleet git blob `f47ad6ba…:CORPUS.md` (`cmp` exit 0) |
| S099 | 2026-11-06T19:34:21Z (recheck 19:37:01Z) | 200 (curl exit 0) | `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c` | 97077 | `The claim is judged on the counter, kill rule and predicate declared before data. A rule` | raw byte offset **52924**, line **561** (§6 item 9 "Claim sizing") | **reproduced exactly** — sha256/bytes equal the fleet git blob `75dd2612:.ufo/prompts/kagi-round-44.md` (`git cat-file -p` → sha256 `e62e259c…1b80c`, 97077 bytes; `cmp` exit **0**) |
| S040 | 2026-11-06T19:34:20Z (recheck 19:37:01Z) | 200 (curl exit 0) | `29fca9b710ae0c857165f68a8c8e62587862c979e1fe4135037a397a8cdf7cf1` | 257722 | col-13 quote `Matches Unicode whitespace characters (as defined by str.isspace() ).` | raw-body start offset **75897**; rendered-text-v1 normalized offset **22569** (normalized_bytes 69356) | **teaching holds** — `rendered-text-v1.py locate` → `RENDERED_TEXT_V1_LOCATE: count=1` (exit 0). Body differs from the stored S040 capture only by served version 3.15.1→3.15.2 plus the 2-byte "Last updated on" date stamp |
| S041 | 2026-11-06T19:34:20Z (recheck 19:37:01Z) | 200 (curl exit 0) | `388321714e199e3a93849040754819d21b7ca9b36a5c17748a7218e8f300e615` | 20100 | col-13 quote `This function uses the rules defined by the HTML 5 standard for both valid and invalid character references` | raw-body start offset **13521**; rendered-text-v1 normalized offset **1234** (normalized_bytes 2395) | **teaching holds** — `rendered-text-v1.py locate` → `RENDERED_TEXT_V1_LOCATE: count=1` (exit 0). Body differs from the stored S041 capture by the same 2-byte date stamp only |

Exact commands, exit codes and last output lines are in
`.ufo/waves/round-47/build/K47ScoutSources-receipts/fetch-receipts.txt`
(one block per id: `exit_code: 0`, `http_status: 200`, `fetched_at_utc`, `sha256`, `bytes`,
`last_output_line:`). Raw bodies are in the same dir (`S094.body`, `S099.body`, `S040.body`,
`S041.body`); their sha256 sums are the ones in the table.

### Receipt index (`.ufo/waves/round-47/build/K47ScoutSources-receipts/`)

| file | content |
|---|---|
| `fetch-receipts.txt` | per-id curl command, exit code, HTTP code, UTC time, sha256, bytes, last output line, second-fetch identity |
| `locate-receipts.txt` | `rendered-text-v1.py locate`/`digest` outputs, `grep -abo`/`grep -n` offsets, every `cmp` with its exit code, and the read-only `git cat-file`/`git ls-tree` commands |
| `registry-checks.txt` | registry row count, `source-fetches.tsv` S099 absence, `source:` counts in the four lessons, col-10/11/13/15 values, recomputed `row_identity_sha256` |
| `assimilation-receipt.txt` | every read-only grep/find/python keyword scan of `/home/vgpnk/Projects/shokuknow/merge/kagi/` with counts and cited line numbers |
| `S094.body`, `S099.body`, `S040.body`, `S041.body` | the raw fetched bodies (sha256 as tabulated) |

No fetch failed, so there is no failure error text to record.

### 1.1 S094 — drift check against the committed capture

```
cmp /fast/scratch/hyaku/kagi-r47/K47ScoutSources/S094.body \
    /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-39/capture/S094.body
→ exit 0 (identical)
```

Additional binding check (read-only git, fleet root `/home/vgpnk/Projects/shokunin`):
`git ls-tree f47ad6ba8d306f8125597401cb2ce45c1297a593 CORPUS.md` → blob `882d6ca87fac60c0df1c038711c21259c873a39e`;
`git cat-file -p f47ad6ba…:CORPUS.md` → sha256 `88556402…50b8`, 11296 bytes; `cmp` against the live
fetch exit **0**. The live body is the pinned blob, not a re-render.

### 1.2 S099 — provenance binding (this is C1's BOUND predicate)

The BOUND predicate in `plans/round-47.md` requires the S099 provenance row's sha256/bytes to equal
the fleet git blob `75dd2612:.ufo/prompts/kagi-round-44.md` **computed live from the fleet repo**.
Measured here, independently:

```
cd /home/vgpnk/Projects/shokunin
git cat-file -p 75dd26121698f10cf111120f6cbcd2b2125598f1:.ufo/prompts/kagi-round-44.md | sha256sum
→ e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c
git cat-file -s 75dd26121698f10cf111120f6cbcd2b2125598f1:.ufo/prompts/kagi-round-44.md
→ 97077
cmp <live fetch> <blob>  → exit 0
```

The live fetch and the fleet blob agree **byte for byte**, so the round-47 capture
`.ufo/waves/round-47/capture/S099.body` may be the fetched body (its sha256 is `e62e259c…1b80c`,
97077 bytes) and the quote occurs in it at raw offset 52924, count 1.

Supporting value for the integrator (not written anywhere — for L1's use only): the registry's
`row_identity_sha256` is defined as `sha256("id<TAB>status<TAB>url<LF>")`; for
`S099 / mined / https://raw.githubusercontent.com/VeigaPunk/shokunin/75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md`
that digest is `28481f3e91f371c9e8e3174922f4f27a204243e9ac05dba2a3fcf43c45b4bb42`
(verified by recomputing the same rule against the three existing rows S040/S041/S094 — all three
matched their stored column-3 digests).

### 1.3 C1 calibration corroboration (observations, no edits made)

Both BASE census findings for S094/S099 are confirmed present in the lane's own tree at BASE:

* `SC_USEDBY_NOCITE S094 round-43.md` — `corpus/lessons/round-43.md` has **no** `source:` line
  (`grep -c '^source:'` → 0), while `round-39.md` and `round-42.md` each have one (`grep -c` → 1).
* `SC_USEDBY_NOCITE S099 round-44.md` — `corpus/lessons/round-44.md` has **no** `source:` line
  (`grep -c '^source:'` → 0).
* `SC_FETCH S099 missing-provenance` — `corpus/source-fetches.tsv` contains **0** rows whose id is
  S099 (`grep -c '^S099'` → 0); rows exist for S040/S041/S094/S095/S096.

The registry's `used-by` sets (S094 → round-39, round-42, round-43; S099 → round-44) already name
the two lessons, so the fix is the missing `source:` field plus the one new S099 provenance row —
consistent with the frozen C1 plan (append-only, no `used-by` narrowing).

### 1.4 S040 / S041 — freshness recheck detail

* Served page titles are now **Python 3.15.2** (`<title>re — Regular expression operations
  &#8212; Python 3.15.2 documentation</title>` at raw offset 1569; `html — … 3.15.2 …` at 1591),
  so the registry cells of S040/S041 that say "title Python 3.15.1 documentation, fetched
  2026-10-21" are **stale in their version label**. The successor rows S095/S096 already carry the
  3.15.2 teaching; the S040/S041 *teaching text itself* still locates verbatim (count=1 each).
* Both docs' live bodies are byte-length identical to the round-40 captures S095.body (257722) and
  S096.body (20100) and differ from them in exactly **2 bytes each** — the "Last updated on Nov 05,
  2026 (12:47 UTC)" vs "Nov 06, 2026 (17:47 UTC)" stamp. That is the deployment-coupled chrome the
  `decoded-http-body-volatile-v1` representation class warns about: the raw digest is a point
  attestation, not a drift pin. The raw-body quote offsets (75897 / 13521) are nevertheless
  **identical** to the offsets recorded in the S095/S096 provenance rows (`location` column:
  `backslash-s-unicode-whitespace-raw-byte-offset-75897`, `html5-unescape-rules-raw-byte-offset-13521`).
* Raw vs normalized digests, measured live (`corpus/rendered-text-v1.py digest`):
  * S040 live: `raw_sha256=29fca9b7…f7cf1 bytes=257722 normalized_sha256=084c0da7290b84cf7b4c5d4009c9877602d2da44834e45265708900aec120863 normalized_bytes=69356`
  * S040 stored: col-10 `0724d815…c8aa5`, 251811 bytes, col-15 `bbeb9d7c317cab01806f4238c293fecc424af4c95e91ad9a288f2d0d93d6f544`
  * S041 live: `raw_sha256=38832171…e615 bytes=20100 normalized_sha256=dad09b924b782dd58581d087e1c1233edda151f567722d00f508727924378976 normalized_bytes=2395`
  * S041 stored: col-10 `8a54138162e47f1bb285f07404309df8556f004ff371140bbbb38d9be70a7122`, 20100 bytes, col-15 `ef8996ed93adc1b8f88a14d8c7580712f7c2060ad9e592160c92e84cf2cdb17c`
* The S040/S041 `recheck` cells are ISO dates `2026-11-05` (registry col 9) — i.e. the plan's
  "overdue ISO recheck" item; my re-open supplies the 2026-11-06 observation above.

---

## 2. Assimilation check — `/home/vgpnk/Projects/shokuknow/merge/kagi/`

Read-only; nothing was run there. Package mtime 2026-10-24 23:33 (`MERGE-REPORT.md`,
`MERGE-REPORT.json`, `SOURCES.append.md`, `knowledge/`).

**Verdict: `none`** — no staged theme touches fired-clock re-verification of Vault/OpenBao docs
or registry provenance.

Evidence (cited lines):

* `MERGE-REPORT.md` — keyword scan over the whole file: `vault` **0**, `openbao` **0**,
  `provenance` **0**, `fired` **0**, `release` **0**. Section headings present: `## What gets
  appended to corpus/SOURCES.md` (line 11), `## Knowledge files to add` (15), `## Dangling
  citations` (101), `## Rows no entry rests on` (109), `## Rows whose source the lane's registry
  already holds` (120), `## Adopt checklist` (128). None of these sections is about fired clocks or
  fetch-provenance discipline.
* `MERGE-REPORT.json` — keys `lane, accepted, refused, entries, existing_rows, renumbered,
  first_id`; 81 entries. Keyword scan over the whole serialisation: `vault` 0, `openbao` 0,
  `hashicorp` 0, `provenance` 0, `fired` 0, `reverify`/`re-verify` 0, `release-clock` 0, `lease` 0,
  `token` 0, `TTL` 0.
* `SOURCES.append.md` (172 staged rows, ids S052–S223): `docs.python.org` 0, `vault` 0,
  `openbao` 0, `source-fetches` 0, `fetch provenance` 0. The 35 `raw.githubusercontent.com` staged
  rows are the package's own own-work pins, unrelated to S094/S099.
* `knowledge/` (81 staged files): filenames matching `vault|openbao|lease|token` → **none**; the
  single content hit for "Vault" in the entire staged tree is
  `knowledge/corpus/knowledge/oidc-federation-trust-policy.md:90` — *"It does not cover the
  **Vault-side** audience check on a JWT/OIDC login (lane rows S012/S022), which is the consuming
  side of the same idea."* That is an **explicit exclusion** of the Vault rows, not a theme that
  touches them. (The entry is listed at `MERGE-REPORT.md:19`.)
* The only near-miss that mentions "re-verification" is `MERGE-REPORT.md:24`
  (`corpus/knowledge/trufflehog-verification-lifecycle.md` … "re-verification") — TruffleHog
  credential-cache semantics, unrelated to Vault/OpenBao release clocks or registry provenance.

Two adjacent observations, recorded for completeness and **not** counted as themes:

* `MERGE-REPORT.md:120-126` ("Rows whose source the lane's registry already holds") flags staged
  row `S092` against lane rows S007/S019/S032 — a 1Password broker trust-decision overlap, not a
  clock or provenance item.
* `SOURCES.append.md:150` (staged row **S195**) reads the lane's own
  `corpus/SOURCES.md` as its source for the localisation audit. It consumes the registry as
  *data*; it proposes no provenance/fetch discipline and no re-verification of the fired clocks.

Consequence for the round: the C2 fired-clock re-verification of S012–S016/S021–S026 has **no
staged counterpart to assimilate**, and the C1 S099 provenance binding has **no staged counterpart
either** — the merge package neither supplies nor conflicts with either claim.

---

## 3. What I did NOT do (scope honesty)

* Did not run `corpus/sources-census.sh`, `plans/round-47-c1.sh`, `plans/round-47-c2.sh`,
  `corpus/release-clock.py`, the claim-ledger verify or the self-counts — the seat spec says to run
  only the scripts the item names, and it names none of these.
* Did not create `corpus/fired-reverify.tsv` or any capture under `.ufo/waves/round-47/capture/`
  (outside my write scope); the fetched bodies live only in my receipt dir and my scratch.
* Did not touch `corpus/SOURCES.md`, `corpus/source-fetches.tsv`, `corpus/lessons/round-43.md`,
  `corpus/lessons/round-44.md` or any registry row.
* No package install / tool upgrade was needed, so nothing to record on that axis.

## 4. Remaining unknowns

* The S040/S041 registry cells naming "Python 3.15.1" are stale in version label only; whether the
  lane prefers to re-label S040/S041 or to leave them as historical rows superseded by S095/S096
  is an integrator decision (both are outside my write scope).
* `corpus/fired-reverify.tsv` did not exist at BASE, so I could not cross-check the 11 fired rows'
  quote counts against an existing ledger; that is C2's own scope.
