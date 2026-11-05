# K40ScoutDocs — live re-observation of the two C2 sources (round 40)

Seat: scout `K40ScoutDocs` (kagi round-40 build wave, attempt 1).
Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` @ candidate `cb3f642479a09644a03874909bb7e44b52697a8d`
(BASE `6cc8850dfc5757927699e5a53a876f47c8df21aa`, predeclaration `f687504767ce9ed56b848dfde83e03a1ec6cedd3`,
frozen plan `38a118f9cf15729e7732cc3cafe1011e3a899ee4`).
Observation date: 2026-11-05. Network fetches only; nothing written outside this seat dir.

**Verdict: NO DRIFT.** All four live observations reproduce the committed capture bytes and the
plan-declared offsets exactly. Zero drift evidence; nothing to fix.

---

## 1. Exact commands executed

All run from the seat scratch `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r40/K40ScoutDocs/`
(created; deleted at end of run).

```
mkdir -p "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r40/K40ScoutDocs/fresh-bodies" \
         /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-40/build/K40ScoutDocs

cd "${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r40/K40ScoutDocs"
curl -fsSL https://docs.python.org/3/library/re.html    -o fresh-bodies/re.body    # exit 0
curl -fsSL https://docs.python.org/3/library/html.html  -o fresh-bodies/html.body  # exit 0
curl -fsSL https://www.python.org/downloads/feed.rss     -o feed.txt                # exit 0

sha256sum fresh-bodies/re.body fresh-bodies/html.body feed.txt
cmp fresh-bodies/re.body   <lane>/.ufo/waves/round-40/capture/S095.body   # exit 0
cmp fresh-bodies/html.body <lane>/.ufo/waves/round-40/capture/S096.body   # exit 0
grep -bo '<title>[^<]*</title>' fresh-bodies/re.body fresh-bodies/html.body
grep -bo 'Matches Unicode whitespace characters (as defined by' fresh-bodies/re.body
grep -bo 'This function uses the rules defined by the HTML 5 standard' fresh-bodies/html.body
grep -bo '<title>Python 3.15.2</title>' feed.txt
python3 -c "…XML parse of feed.txt, item title/pubDate table…"
bash <lane>/plans/round-40-c2.sh          # exit 0, printed 3
```

No `pacman` transaction was run. **Tool installs: none** (curl 8.23.0, sha256sum, cmp, grep,
python3 — all preinstalled on the host; no install or upgrade was performed or needed).

## 2. Served `<title>` lines — byte-exact

Fetched body `fresh-bodies/S095.body` (re.html), byte offset of the `<title>` element = **1569**:

```
<title>re — Regular expression operations &#8212; Python 3.15.2 documentation</title>
```

Fetched body `fresh-bodies/S096.body` (html.html), byte offset of the `<title>` element = **1591**:

```
<title>html — HyperText Markup Language support &#8212; Python 3.15.2 documentation</title>
```

Byte-exact repr from `python3` over the raw bytes (note the **literal U+2014 em dash** after the
module name, and the **HTML entity `&#8212;`** — not a literal em dash — before "Python"):

```
b'<title>re \xe2\x80\x94 Regular expression operations &#8212; Python 3.15.2 documentation</title>'
b'<title>html \xe2\x80\x94 HyperText Markup Language support &#8212; Python 3.15.2 documentation</title>'
```

Observation (not a defect, not a drift): the frozen plan (`plans/round-40.md`, "Sources (this
round)") renders both titles with two literal em dashes, e.g. `re — Regular expression
operations — Python 3.15.2 documentation`. The **served bytes** use a literal em dash (U+2014)
in the first separator and the numeric entity `&#8212;` in the second. The plan's rendering is a
human-readable normalization of the entity; the visible text is identical. The registry rows
S095/S096 in `corpus/SOURCES.md` quote only the fragment `title Python 3.15.2 documentation`,
which is present in both served titles. No claim depends on the byte-exact separator form, and
the C2 counter does not test titles at all — so this is recorded as a fidelity note on the
plan's prose, not a defect. Confidence: high (verified from raw bytes).

## 3. Quote offsets — fresh vs committed vs plan-declared

| source | quote | fresh offset | committed `.ufo/waves/round-40/capture/*.body` offset | plan-declared |
|---|---|---|---|---|
| S095 `re.html` | `Matches Unicode whitespace characters (as defined by` | **75897** | **75897** | 75897 |
| S096 `html.html` | `This function uses the rules defined by the HTML 5 standard` | **13521** | **13521** | 13521 |

Both `grep -bo` searches exited 0 (unique match each — no duplicate occurrence of either quote
in its body). Offsets match to the byte.

## 4. sha256 — fresh vs committed captures

| body | fresh sha256 | committed sha256 | plan-declared sha256 | identical? |
|---|---|---|---|---|
| S095 (re.html) | `ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1` | `ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1` | `ef2d8abe698b74bbee5259f02599f9b6bf023733d47bb4c7003ac1277bf469b1` | **yes** |
| S096 (html.html) | `570d72c3910b313e905246e75b3238522d6c26194ffd33c1f4112c4f0d3fbab5` | `570d72c3910b313e905246e75b3238522d6c26194ffd33c1f4112c4f0d3fbab5` | `570d72c3910b313e905246e75b3238522d6c26194ffd33c1f4112c4f0d3fbab5` | **yes** |

Sizes: S095 fresh 257722 bytes (= committed 257722), S096 fresh 20100 bytes (= committed 20100).
`cmp` reported the two fresh bodies byte-identical to the committed captures (exit 0 both).

**No drift evidence.** The committed captures still equal the live served pages today.

## 5. S091 identity — python.org release feed

Fetched `https://www.python.org/downloads/feed.rss` (3354 bytes), sha256
`9ba8856e586659ab78349c3963aa1de178636c0f08772d6196fadbaa92bcea1e`, which **equals** the sha256
stored in `corpus/source-fetches.tsv` for S091. Channel `lastBuildDate` = `Sun, 25 Oct 2026 21:02:29 +0000`.

Items parsed (title | pubDate):

| # | title | pubDate |
|---|---|---|
| 1 | Python 3.11.18 | Sun, 25 Oct 2026 21:02:29 +0000 |
| 2 | Python 3.13.18 | Sun, 25 Oct 2026 19:09:44 +0000 |
| 3 | Python 3.12.16 | Sun, 25 Oct 2026 18:35:25 +0000 |
| 4 | Python 3.14.10 | Sun, 25 Oct 2026 04:15:45 +0000 |
| 5 | **Python 3.15.2** | Sun, 25 Oct 2026 04:15:38 +0000 |
| 6 | Python 3.13.17 | Wed, 21 Oct 2026 14:22:30 +0000 |
| 7 | Python 3.14.9 | Wed, 21 Oct 2026 13:08:09 +0000 |
| 8 | Python 3.15.1 | Wed, 21 Oct 2026 09:59:50 +0000 |
| 9 | Python 3.16.0a1 | Tue, 13 Oct 2026 19:02:12 +0000 |
| 10 | Python install manager 26.4 | Fri, 09 Oct 2026 14:58:02 +0000 |

**Newest stable X.Y.Z item title = `Python 3.15.2`** — matches the S091 identity (`Python 3.15.2`)
recorded in `corpus/SOURCES.md` row S091. Exclusions applied exactly as the row specifies:
`Python 3.16.0a1` is a prerelease (excluded) and `Python install manager 26.4` is an
install-manager item, not an X.Y.Z CPython release (excluded). The S091 row's own quote
`<title>Python 3.15.2</title>` locates at **byte offset 1583** in the fresh feed — identical to
the offset recorded in the row (1583). The feed sha also matches the committed fetch table, so
the feed has not moved since the capture.

Note: "newest" here is resolved as *highest stable version number* among the feed's stable
X.Y.Z items, which is how the S091 row is worded ("newest stable X.Y.Z item"); the feed's
*pubDate* order is by maintenance release, and the top-by-date item (3.11.18, 2026-10-25 21:02)
is a lower version. 3.15.2 is the highest stable X.Y.Z present, and it is also the item the
served 3.15.2 documentation pages correspond to. No ambiguity affects the S091 identity.

## 6. Cross-check of the C2 counter against the live pages (read-only)

`bash plans/round-40-c2.sh` run at the candidate from the lane root: **exit 0, printed `3`**
(target 3 — met at the candidate).

Independently of the counter, I re-derived its item2/item3 quote predicates against the **fresh**
bodies rather than the committed captures:

- S095 row teaches-cell quote = `Matches Unicode whitespace characters (as defined by`
  (7 whitespace-separated words) → **locates in the fresh re.html body** = True;
  row carries `supersedes S040` = True; row shape `| docs | A |` = True.
- S096 row teaches-cell quote = `This function uses the rules defined by the HTML 5 standard`
  (11 words) → **locates in the fresh html.html body** = True;
  row carries `supersedes S041` = True; row shape `| docs | A |` = True.
- `corpus/source-fetches.tsv` rows S095/S096 carry sha256 equal to the fresh bodies
  (`ef2d8abe…` / `570d72c3…`), so the counter's capture handshake also holds against live bytes.

So the C2 claim's evidence base holds on freshly fetched sources, not only on the committed
capture files.

## 7. Findings / defects

- **No drift.** Every fresh sha256, byte offset, size, and title matches the committed capture
  and the plan's declared values.
- **No surviving defect in the C2 evidence chain** as observed from the network side.
- **Fidelity note (non-blocking, prose only):** the frozen plan renders the served `<title>`
  separators as two literal em dashes; the served bytes use one literal U+2014 and one
  `&#8212;` entity. Visible text identical; no claim or counter depends on it. Left unchanged
  by instruction (report only; do not fix).

## 8. Scope, gaps, and confidence

- **Observed:** the four network responses, their hashes/offsets/titles, the committed capture
  bytes, the S091/S095/S096 registry rows, the `source-fetches.tsv` shas, and the C2 counter's
  printed value at the candidate — all directly executed and quoted above.
- **Inferred (explicitly):** that "newest stable X.Y.Z" means highest stable version number
  (from the S091 row's own wording and its `3.16.0a1`-is-a-prerelease note); confidence high.
- **Not observed / outside this seat's scope:** C1 and C3 counters, the ledger verify run,
  the anchor-pins gate, the census, and the selftests — this seat was assigned the two C2
  sources only and did not execute them. The C2 counter value `3` reported above is a
  single counter reading, not a claim that the whole round's gates hold.
- **Residual unknown (named ceiling, not a defect):** the frozen plan's own ceiling — the
  counter binds registry rows to committed capture bytes and cannot prove the capture equals the
  live page at closure time; my re-observation narrows but does not close that gap, and the
  plan's F7/QM40 pin/row co-rewrite class remains undetected by this method too.
- Confidence: **high** for items 1–3 and 5 (byte-level, hash-verified, deterministic);
  **high** for item 4 (the C2 counter reading, single execution, deterministic script).

## 9. Receipts (durable, under this seat dir)

- `.ufo/waves/round-40/build/K40ScoutDocs/fresh-bodies/S095.body` — fresh `re.html` body, 257722 bytes, sha256 `ef2d8abe…69b1`
- `.ufo/waves/round-40/build/K40ScoutDocs/fresh-bodies/S096.body` — fresh `html.html` body, 20100 bytes, sha256 `570d72c3…bab5`
- `.ufo/waves/round-40/build/K40ScoutDocs/offsets.txt` — measured vs committed vs plan-declared offsets
- `.ufo/waves/round-40/build/K40ScoutDocs/sha.txt` — fresh vs committed vs plan-declared sha256, `cmp` results, sizes
- `.ufo/waves/round-40/build/K40ScoutDocs/feed.txt` — fresh `feed.rss`, sha256 `9ba8856e…a1e`, matching S091's stored sha

Scratch tree `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r40/K40ScoutDocs/` deleted at end of run.
No git/jj mutation was performed anywhere; no fixture repository was created.
