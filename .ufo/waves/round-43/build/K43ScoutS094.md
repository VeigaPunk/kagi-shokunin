# K43ScoutS094 — S094 re-open, round 43 (scout)

**Seat:** K43ScoutS094 (scout). **Scope:** re-open registry source S094 and record its current
used-by cell; read-only except this seat's deliverable directory.
**Full receipt:** `.ufo/waves/round-43/build/K43ScoutS094/notes.md`
**Deliverables:** `.ufo/waves/round-43/build/K43ScoutS094/` → `notes.md`, `CORPUS-live.md`,
`CORPUS-live.headers.txt`.

## 1. Key values (all measured today, 2026-11-05)

| item | value |
|---|---|
| URL | `https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md` |
| HTTP status | **200** (HTTP/2, `text/plain; charset=utf-8`, gzip, **0 redirects**) |
| byte count (decoded body on disk) | **11296** |
| byte count (wire, gzipped) | 5073 (`content-length: 5073`, `size_download=5073`) |
| sha256 | **88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8** |
| git blob sha1 (live body) | `882d6ca87fac60c0df1c038711c21259c873a39e` — **equals** the upstream `CORPUS.md` blob sha at revision `f47ad6ba` |
| match verdict vs committed capture | **MATCH — byte-identical, no drift** (`cmp` exit 0) |
| quote | ``Only `status`, `recheck` and `used-by` change in place`` |
| quote line number | **116** (served body; identical in the committed capture) |
| quote byte offset | **6172** (`grep -b -o -F`) |
| quote occurrence count | 1 (`grep -c -F`) |
| quote whitespace tokens | **8** (≤ 25) |

## 2. Commands run and their results

```
$ curl -fsSL --compressed -D headers.txt -w 'HTTP_STATUS=%{http_code}\nSIZE_DOWNLOAD=%{size_download}\n\
    SIZE_HEADER=%{size_header}\nNUM_REDIRECTS=%{num_redirects}\nURL_EFFECTIVE=%{url_effective}\n' \
    'https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md' \
    -o body.md
HTTP_STATUS=200
SIZE_DOWNLOAD=5073
SIZE_HEADER=921
NUM_REDIRECTS=0
URL_EFFECTIVE=https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md
exit 0

$ stat -c %s body.md            → 11296
$ sha256sum body.md             → 88556402940e7a0f1dbbed3abef9e00c87a90db6f80eaed03269e371f50050b8
$ git hash-object body.md       → 882d6ca87fac60c0df1c038711c21259c873a39e

$ cmp .ufo/waves/round-43/build/K43ScoutS094/CORPUS-live.md .ufo/waves/round-39/capture/S094.body
exit 0          # identical

$ grep -n 'Only `status`, `recheck` and `used-by` change in place' CORPUS-live.md
116:2. **Append-only.** Only `status`, `recheck` and `used-by` change in place, and each change
exit 0

$ grep -b -o -F 'Only `status`, `recheck` and `used-by` change in place' CORPUS-live.md
6172:Only `status`, `recheck` and `used-by` change in place
exit 0

$ grep -c -F 'Only `status`, `recheck` and `used-by` change in place' CORPUS-live.md
1
$ printf '%s' '<quote>' | tr -s ' ' '\n' | grep -c .      → 8
$ grep -c -F 'an in-place anchor rewrite violates this rule' CORPUS-live.md
0
```

Last output line of each receipt is recorded in `notes.md`; every command above exited 0.

## 3. S094 row — current text, verbatim (read-only; not edited)

`corpus/SOURCES.md` line 101, unchanged by this seat:

```
| S094 | CORPUS.md — https://raw.githubusercontent.com/VeigaPunk/shokunin/f47ad6ba8d306f8125597401cb2ce45c1297a593/CORPUS.md | own-work | A | registry append-only discipline: which cells may change in place | SOURCES.md Rules item 2, line 116, revision f47ad6ba8d306f8125597401cb2ce45c1297a593 | Only status, recheck and used-by change in place; an in-place anchor rewrite violates this rule | mined | 2026-11-05 | 90d | corpus/lessons/round-39.md |
```

11 columns: `S094` | source URL+title | `own-work` | `A` | `registry append-only discipline: which cells may change in place` |
`SOURCES.md Rules item 2, line 116, revision f47ad6ba8d306f8125597401cb2ce45c1297a593` |
`Only status, recheck and used-by change in place; an in-place anchor rewrite violates this rule` |
`mined` | `2026-11-05` | `90d` | **`corpus/lessons/round-39.md`**.

### used-by cell — the old→new log input for the L1

- **Current (old) value, verbatim:** `corpus/lessons/round-39.md`
- **Observed** lane files citing S094 today: `corpus/lessons/round-39.md` (3), `round-39-verifier-spotcheck.md` (7),
  `round-40.md` (4), `round-42.md` (8), `round-42-verifier-spotcheck.md` (3). No `round-43.md` lesson exists yet.
- **Proposed (new) value, inference for the L1 to land:**
  `corpus/lessons/round-39.md, corpus/lessons/round-42.md` — plus `corpus/lessons/round-43.md` once this
  round's lesson is written. The comma-space-separated form matches the served spec (line 107:
  "repo-relative paths of the knowledge entries or lessons citing the row, comma-separated, or `—`") and
  the existing multi-path cells in `corpus/SOURCES.md` (S017-S021, S045, S066, S088).
  The `*-verifier-spotcheck.md` files are excluded from the proposal because **no** existing used-by cell
  names one — that part of the candidate list is genuinely ambiguous.
- **Operational constraint for the L1 (observed):** census check `E11-dangling-usedby`
  (`/home/vgpnk/Projects/shokunin/scripts/sources-census.sh`, lines 560-570) tests every comma-separated
  used-by path of a `mined` row with `[ -e "$dir/$path" ]` and emits `E11 <lane> <id> missing used-by <path>`
  otherwise. So `corpus/lessons/round-43.md` must be written *before* the census is re-run, or left out of the cell.
- **Rule basis:** CORPUS rule 2 permits a used-by in-place change but requires it logged old→new in the round
  lesson. This notes file supplies the inputs; **the L1 applies the edit and the lesson log.** This seat did not edit
  `corpus/SOURCES.md`.

## 4. What the rule permits to change in place — one sentence

CORPUS rule 2 (served body line 116) permits exactly three registry cells to change in place — `status`,
`recheck` and `used-by` — each such change must be logged old→new in the round lesson, and every other
correction (including the `anchor` and `teaches` cells) must land as a **new** row whose `teaches` opens
`supersedes S0NN —` instead of an in-place rewrite.

## 5. Findings the L1 should carry

1. **No drift.** The live body is byte-identical to the committed round-39 capture and reproduces the
   round-42 spot-check's sha256 and byte count exactly. The pinned revision is still reachable and unmodified
   (git blob sha1 identity).
2. **`teaches` cell still mixes quote with a derived clause.** `an in-place anchor rewrite violates this rule`
   occurs **0** times in the served body. This is the round-40 M40-1 defect class. Because `teaches` is not
   one of the three changeable cells, rule 2 forbids repairing it in place — a fix must be a new row. **Not
   repaired by this seat** (the row is append-only). Named limit from round-42 (critic F7) stands: S094 governs
   `corpus/SOURCES.md`, not `corpus/claim-ledger.tsv`; C1's use of it on the ledger is by analogy.
3. **The anchor cell's `SOURCES.md` is a cross-reference, not the served filename.** The served file is
   `CORPUS.md`; `raw.githubusercontent.com/.../f47ad6ba.../SOURCES.md` returns **HTTP 404** and the upstream tree
   at that revision has no top-level `SOURCES.md`. The reference resolves inside `CORPUS.md` itself: line 64
   opens `## SOURCES.md — where a shokunin learns`, line 110 `### Rules`, line 116 the append-only rule. So the
   anchor is accurate, but a reader who fetches `SOURCES.md` upstream gets a 404. Recorded, not changed (anchor
   is not a changeable cell).
4. **Quote token count is 8, not the round-39 Gate's "9 words."** Re-derived; matches round-40 M40-4's
   correction and round-42's Gate. No action needed beyond keeping 8 in this round's Gate.
5. **Two independent corroborations of the fetch row:** `corpus/source-fetches.tsv` line 137 already declares
   this URL/status/sha/byte count; the fleet-root `CORPUS.md` is the same 11296 bytes and sha256.

## 6. Untouched / scope

Read-only against the lane: `corpus/SOURCES.md`, `corpus/lessons/`, `corpus/source-fetches.tsv`,
`plans/round-43.md`, `scripts/sources-census.sh` were read only. No git mutation was performed in the lane
or in any scratch clone; no `git add/commit/checkout/stash/reset/push` anywhere. The scratch fetch dir
`$HYAKU_SCRATCH/kagi-r43/K43ScoutS094` was removed after the receipts were copied into this deliverable
directory. No tool was installed or upgraded this round (no tooling need arose; the fetch used the host's
pre-existing `curl`, `sha256sum`, `cmp`, `grep`, `awk`, `git`).

SEAT-STATUS: complete
