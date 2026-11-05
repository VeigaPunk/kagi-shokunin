# K42ScoutS094 — S094 live re-open (round 42, attempt 1)

Seat: scout. Scope: re-open registry source S094 this round and locate the append-only
rule (plans/round-42.md §C1 sourced claim; CORPUS.md §SOURCES.md rule 2).
Read-only on the lane except this deliverable directory.

## 1. The row

`corpus/source-fetches.tsv` (lane, master @ `fdbb83d`), header line 5 declares
**16 tab-separated columns**. Row 137, id `S094`, fields as parsed:

| col | name | value |
|---|---|---|
| 1 | id | `S094` |
| 2 | status | `mined` |
| 3 | row_identity_sha256 | `2b8fec43b007b3c9fe0208051534708090f2ab21cb98a1d9702fe9f1f5b27ea7` |
| 4 | url | `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md` |
| 5 | final_url | identical to col 4 |
| 6 | http_status | `200` |
| 7 | request_profile | `curl-fsSL-compressed-v1` |
| 8 | fetched | `2026-11-05` |
| 9 | representation | `decoded-http-body-v1` |
| 10 | **sha256** | **`88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`** |
| 11 | **bytes** | **`11296`** |
| 12 | revision | `f47ad6ba8d306f8125597401cb2ce45c1297a593` |
| 13 | quote | `Only \`status\`, \`recheck\` and \`used-by\` change in place` |
| 14 | normalization | `raw-literal-v1` |
| 15 | normalized_sha256 | `-` |
| 16 | location | `SOURCES.md Rules item 2, line 116` |

Row identity re-derived (read-only): `printf 'S094\tmined\t<url>\n' | sha256sum`
= `2b8fec43b007b3c9fe0208051534708090f2ab21cb98a1d9702fe9f1f5b27ea7` — matches col 3.

The lane's registry row (`corpus/SOURCES.md` line 101) is `S094`, kind `own-work`, tier `A`,
status `mined`, opened `2026-11-05`, recheck `90d`, used-by `corpus/lessons/round-39.md`
(path exists). Anchor cell: `SOURCES.md Rules item 2, line 116, revision f47ad6ba…`.
`git diff e8265c0..HEAD -- corpus/source-fetches.tsv corpus/SOURCES.md` is empty: the row
is byte-identical at the claim BASE and at lane HEAD.

## 2. Live re-open (today, 2026-11-05)

Command (profile per col 7; `-D` and `-w` added for receipts):

```
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -D CORPUS-live.headers -o CORPUS-live.md \
  -w 'http_status=%{http_code}\neffective_url=%{url_effective}\nsize_download=%{size_download}\ncontent_type=%{content_type}\nnum_redirects=%{num_redirects}\n' \
  https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md
```

- exit code **0**; stderr empty.
- **HTTP status: 200** (`HTTP/2 200`, `content-type: text/plain; charset=utf-8`,
  `content-encoding: gzip`, `date: Thu, 05 Nov 2026 16:55:44 GMT`).
- **Final URL: `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md`**
  — `url_effective` equals the registered URL; `num_redirects=0`.
- **Byte count (decoded body): 11296** (`size_download=5073` is the gzip-encoded wire
  size; the declared representation is `decoded-http-body-v1`, so the decoded body is
  the attestation domain).
- **sha256: `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`**
- **Access date: 2026-11-05.**

## 3. Match verdict vs the committed capture

Committed capture found by `find .ufo/waves/round-{39,40,41}/capture` and
`git ls-files`: **`.ufo/waves/round-39/capture/S094.body`** (tracked). Round-40 and
round-41 capture dirs hold S095/S096 and S097/S098 only — no S094 body there.

- `cmp .ufo/waves/round-42/build/K42ScoutS094/CORPUS-live.md .ufo/waves/round-39/capture/S094.body`
  → **exit 0, identical** (no drift).
- Capture sha256 = `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8`,
  11296 bytes — same as the live body and as TSV cols 10/11.
- Cross-check (read-only): `git -C /home/vgpnk/Projects/shokunin show f47ad6ba8d306f8125597401cb2ce45c1297a593:CORPUS.md | sha256sum`
  = `88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8` — the fleet blob
  at the pinned revision equals the live body equals the committed capture.
  (The lane repo `kagi-shokunin` does not contain object `f47ad6ba`; the pinned revision
  lives in the fleet-root repo `/home/vgpnk/Projects/shokunin`.)

**Verdict: MATCH — no drift.** Live body == committed capture == TSV row sha/bytes ==
fleet blob at the pinned revision.

## 4. The rule text

Located at **line 116** of the fetched body (the `### Rules` heading is line 110, inside
the `## SOURCES.md — where a shokunin learns` section carried in CORPUS.md from
`.ufo/waves/kaika/SOURCES-CONTRACT-v1.md`).

Verbatim rule line (with the following continuation line for context):

```
116: 2. **Append-only.** Only `status`, `recheck` and `used-by` change in place, and each change
117:    is logged old→new in the round lesson. A correction is a new row whose `teaches` opens
```

**Quote (8 words, ≤25, verbatim, includes the words that say only status, recheck and
used-by change in place):**

> Only `status`, `recheck` and `used-by` change in place

- `grep -c -F 'Only \`status\`, \`recheck\` and \`used-by\` change in place' CORPUS-live.md`
  → **1** (exit 0). Unique in the body.
- `grep -b -o -F` → **byte offset 6172** (exit 0).
- Broader form `**Append-only.** Only \`status\`, \`recheck\` and \`used-by\` change in place`
  → count **1**, byte offset **6155** (also recorded in `receipts.txt`).
- `grep -n -F 'Append-only'` → `116` only (count 1).
- The declared quote in TSV col 13 is identical to the quote above; the declared location
  col 16 (`SOURCES.md Rules item 2, line 116`) matches the located line.

## 5. Does the rule forbid deleting a registry row?

**Yes.** The rule makes the registry append-only: only `status`, `recheck` and `used-by`
change in place, and a correction must be a *new* row whose `teaches` opens
`supersedes S0NN —`, so deleting an existing row is not one of the permitted in-place
changes and contradicts the append-only discipline.

## 6. Freshness note (axis C2)

The row's URL is pinned to an immutable commit (`f47ad6ba…`), so content drift is not
expected and none was observed; the row's `recheck` cadence is `90d` with `opened
2026-11-05`, and this re-open is the same-day live confirmation of the declared
`decoded-http-body-v1` attestation (sha/bytes unchanged). Today's re-open therefore
confirms the C1 sourced claim still holds at the source; it does not itself move a score.

## Files in this deliverable directory

- `CORPUS-live.md` — the decoded body fetched today (11296 bytes).
- `CORPUS-live.headers` — response headers.
- `curl-summary.txt` — `curl -w` output; `curl-stderr.txt` — empty stderr.
- `receipts.txt` — the full command/rc/last-output-line receipt set.

## Tooling

No installs, no upgrades, no host changes. Everything used was already present
(`curl`, `sha256sum`, `cmp`, `grep`, `git` read-only, `awk`, `sed`). `git` was used
read-only (`show`, `log`, `ls-files`, `diff`, `rev-parse`) — no mutating git command was
run anywhere; no commit was made. Scratch (`/fast/scratch/hyaku/kagi-r42/K42ScoutS094`)
was used for helper scripts and removed at exit.
