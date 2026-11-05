# K43ScoutS094 — S094 re-open (round 43)

Seat: scout K43ScoutS094. Round 43, attempt 1. Read-only against the lane; the only writes are
this directory.

## 1. Source identity

- **Registry row:** S094, `corpus/SOURCES.md` line 101.
- **URL:** `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`
- **Access date:** 2026-11-05 (today).
- **HTTP status:** `200` (HTTP/2, `content-type: text/plain; charset=utf-8`, `content-encoding: gzip`).
- **Redirects:** 0 (`num_redirects=0`; `url_effective` == the requested URL).
- **Byte count:** **11296** bytes of decoded body on disk (`stat -c %s`); the wire transfer was
  5073 bytes gzipped (`content-length: 5073`), `curl` reported `size_download=5073`.
- **sha256:** `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`

Command (exit 0):

```
curl -fsSL --compressed -D headers.txt -w 'HTTP_STATUS=%{http_code}\nSIZE_DOWNLOAD=%{size_download}\n...' \
  'https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md' \
  -o body.md
# HTTP_STATUS=200 SIZE_DOWNLOAD=5073 SIZE_HEADER=921 NUM_REDIRECTS=0
```

## 2. Compare against the committed capture — MATCH, no drift

```
cmp .ufo/waves/round-43/build/K43ScoutS094/CORPUS-live.md .ufo/waves/round-39/capture/S094.body
# exit 0
```

Both files are 11296 bytes and both sha256 to
`88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`.
This reproduces the round-42 spot-check's re-verification exactly (same sha, same byte count, same
`cmp` result), so the source has not moved since the round-39 capture was committed.

**Verdict: MATCH — byte-identical, no drift.**

Two further independent corroborations, both read-only:
- `corpus/source-fetches.tsv` line 137 (the declared fetch-provenance row for S094) carries the
  same URL, HTTP 200, method `curl-fsSL-compressed-v1`, date `2026-11-05`,
  `decoded-http-body-v1`, the same sha256 and the same `11296` byte count.
- The fleet-root copy `/home/vgpnk/Projects/shokunin/CORPUS.md` is also 11296 bytes with the same
  sha256 (`cmp` exit 0) — the lane's own local copy of the served contract.

**Third, strongest corroboration — git blob identity (observed).** The live body's git blob SHA-1
(`git hash-object body.md`) is `882d6ca87fac60c0df1c038711c21259c873a39e`, which is **exactly** the
`CORPUS.md` blob sha the GitHub tree API reports for revision
`f47ad6ba8d306f8125597401cb2ce45c1297a593` (`api.github.com/repos/VeigaPunk/shokunin/git/trees/f47ad6ba…`,
`CORPUS.md` → sha `882d6ca87fac60c0df1c038711c21259c873a39e`, size 11296). The commit itself exists
upstream and its committer date is `2026-10-25T12:29:03Z`. So the bytes served today are not merely
identical to the lane's capture — they are the *same git object* that revision pins, which proves
the pinned revision is still reachable and unmodified.

## 3. The append-only rule — located

- **Quote (verbatim, backticks preserved):** `Only `status`, `recheck` and `used-by` change in place`
- **Line number:** **116** of the served body (`grep -n` → `116:2. **Append-only.** Only ...`).
- **Byte offset:** **6172** (`grep -b -o -F` → `6172:Only \`status\`, \`recheck\` and \`used-by\` change in place`).
- **Occurrence count:** **1** (`grep -c -F` → 1) — the phrase is unique in the body.
- **Whitespace tokens:** **8** (≤ 25 as the registry's rule 1 requires). Confirmed by
  `printf '%s' '<quote>' | tr -s ' ' '\n' | grep -c .` → 8.
- Same offset and count hold in the committed capture `.ufo/waves/round-39/capture/S094.body`
  (`grep -b -o -F` → `6172:`), consistent with the byte-identity above.

Full rule line as served (line 116):

```
2. **Append-only.** Only `status`, `recheck` and `used-by` change in place, and each change
   is logged old→new in the round lesson. A correction is a new row whose `teaches` opens
   `supersedes S0NN —`.
```

It is item 2 of the `### Rules` list under the `## SOURCES.md — where a shokunin learns` section
of the served `CORPUS.md` (that section opens at line 64; `### Rules` at line 110).

## 4. Verbatim current S094 row text (from `corpus/SOURCES.md` line 101, unmodified)

```
| S094 | CORPUS.md — https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md | own-work | A | registry append-only discipline: which cells may change in place | SOURCES.md Rules item 2, line 116, revision f47ad6ba8d306f8125597401cb2ce45c1297a593 | Only status, recheck and used-by change in place; an in-place anchor rewrite violates this rule | mined | 2026-11-05 | 90d | corpus/lessons/round-39.md |
```

Cell split (11 columns, `awk -F'|'` on field 2..12):

| # | cell | value |
|---|---|---|
| 1 | id | `S094` |
| 2 | source | `CORPUS.md — https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md` |
| 3 | kind | `own-work` |
| 4 | tier | `A` |
| 5 | scope | `registry append-only discipline: which cells may change in place` |
| 6 | anchor | `SOURCES.md Rules item 2, line 116, revision f47ad6ba8d306f8125597401cb2ce45c1297a593` |
| 7 | teaches | `Only status, recheck and used-by change in place; an in-place anchor rewrite violates this rule` |
| 8 | status | `mined` |
| 9 | opened | `2026-11-05` |
| 10 | recheck | `90d` |
| 11 | **used-by** | **`corpus/lessons/round-39.md`** (single path, no comma-separated list) |

### used-by old→new log input for the L1

Current used-by cell text, verbatim: `corpus/lessons/round-39.md`

**Observed** — lane files that cite S094 today (grep `S094` over `corpus/lessons/`):

| path | cites | on disk |
|---|---|---|
| `corpus/lessons/round-39.md` | 3 | yes |
| `corpus/lessons/round-39-verifier-spotcheck.md` | 7 | yes |
| `corpus/lessons/round-40.md` | 4 | yes |
| `corpus/lessons/round-42.md` | 8 | yes |
| `corpus/lessons/round-42-verifier-spotcheck.md` | 3 | yes |

No `corpus/lessons/round-43.md` exists yet (this round's lesson is not written; it will be created
by the L1 when the round lands).

**Inferred** (flagged as inference, not observed): the round-42 spot-check's routed item 2 asks that
the used-by cell move old→new this round, since the round-42 lesson and the round-43 claim cite
S094 while the cell still names only round-39. The natural old→new log line is:

- **old:** `corpus/lessons/round-39.md`
- **new:** `corpus/lessons/round-39.md, corpus/lessons/round-42.md` (and `corpus/lessons/round-43.md`
  once this round's lesson exists)

**Precedent for the shape of that cell** (observed): the registry's own `used-by` spec (served body
line 107) says "repo-relative paths of the knowledge entries or lessons citing the row,
comma-separated, or `—`". Existing multi-path cells in `corpus/SOURCES.md` use that exact
comma-space-separated form — S017/S018/S019/S020/S021 (`corpus/lessons/round-22.md,
corpus/knowledge/feature-bound-credential-review.md`), S045, S066, S088
(`corpus/knowledge/prefreeze-controls.md, corpus/lessons/round-35.md`). No existing cell names a
`*-verifier-spotcheck.md` file, so the spot-check files are the ambiguous part of the candidate
list and are excluded from the proposed new value above.

**Operational constraint the L1 must satisfy** (observed in
`/home/vgpnk/Projects/shokunin/scripts/sources-census.sh`, check `E11-dangling-usedby`, lines
560-570): for every `mined` row, each comma-separated used-by path is checked with `[ -e "$dir/$path" ]`
and a missing path emits `E11 <lane> <id> missing used-by <path>`. So any path added to the cell
must exist on disk at census time. `corpus/lessons/round-43.md` therefore must be written before
the census is re-run, or it must be left out of the cell.

**Not done by this seat:** the row was not edited. CORPUS rule 2 permits a used-by in-place change
but requires it to be logged old→new in the round lesson; this notes file supplies the old→new
inputs for the L1's lesson log and the L1 applies the edit.

## 5. What the rule permits to change in place — one sentence

CORPUS rule 2 (served body line 116) permits exactly three registry cells to change in place —
`status`, `recheck` and `used-by` — and every such change must be logged old→new in the round
lesson, while any correction to any other cell (including the `anchor` and `teaches` cells) must be
made as a **new** row whose `teaches` opens `supersedes S0NN —` rather than by rewriting the
existing row in place.

**Consequence for S094's `teaches` cell:** the clause `an in-place anchor rewrite violates this
rule` does **not** occur in the served body (`grep -c -F 'an in-place anchor rewrite violates this
rule'` → **0**). It is a derived clause mixed into the teaches cell — the round-40 M40-1 defect
class. Because `teaches` is not one of the three changeable cells, it cannot be repaired in place;
per rule 2 a fix must land as a new row. This is recorded, not repaired, by this seat.

## 6. Calibration notes / limits of this re-open

1. **The anchor cell names `SOURCES.md`, the served file is `CORPUS.md`.** The anchor cell reads
   `SOURCES.md Rules item 2, line 116`. The fetched resource is `CORPUS.md`; there is no
   `SOURCES.md` at that upstream revision — `raw.githubusercontent.com/.../f47ad6ba.../SOURCES.md`
   returns **HTTP 404**, and the upstream tree at `f47ad6ba` (`api.github.com/repos/VeigaPunk/shokunin/git/trees/f47ad6ba…`)
   contains `CORPUS.md` and no `SOURCES.md` at top level. The reference is nonetheless correct as a
   *cross-reference*: `CORPUS.md` line 64 opens `## SOURCES.md — where a shokunin learns` and its
   `### Rules` list (line 110) item 2 is the append-only rule at line 116. So "SOURCES.md Rules
   item 2, line 116" resolves inside the served `CORPUS.md`; the upstream file `SOURCES.md` does not
   exist at that revision. **Confidence: high** (both the 404 and the tree listing were observed).
2. **The served body is the registry contract of the upstream project, not this lane's registry.**
   The lane's own registry is `kagi-shokunin/corpus/SOURCES.md`; the served `CORPUS.md` is the
   template contract the lane follows (it carries the `## SOURCES.md — where a shokunin learns`
   section, the 11-column header and the census awk recipes). S094 is tier `A` `own-work` because
   the served file is the specification of the registry it governs — the round-39 and round-42
   lessons both record this reading, and this re-open reproduces it.
3. **Named limit carried forward from round-42 (critic F7):** S094 governs
   `corpus/SOURCES.md`; it does not govern `corpus/claim-ledger.tsv`. C1's application of the
   append-only principle to the ledger is by analogy; the ledger's own migration discipline is
   what the journal gate enforces.
4. **The quote count is 8 whitespace tokens, not the "9 words" of the round-39 Gate.** The round-39
   lesson Gate said "9 words"; round-40 lesson M40-4 recorded the correction to 8, and this
   re-open re-derives 8. The round-42 Gate and round-42 spot-check both say 8. Consistent.

## 7. Receipts in this directory

- `CORPUS-live.md` — the live re-fetch, decoded body, 11296 bytes, sha256 `885564…50b8`.
- `CORPUS-live.headers.txt` — the response headers of the re-fetch (HTTP/2 200, gzip, etag
  `W/"e71237fff9db9a064035955618e06a7150f28d54decc6effb7a67c5e90b446fd"`).

Nothing in the lane tree was modified by this seat: `corpus/SOURCES.md`, `corpus/lessons/` and
`corpus/source-fetches.tsv` were read only; the scratch clone/scratch dir used for the re-fetch was
removed before this report was written.
