# XSrcOpen — C3 source re-opening, round-30 BUILD wave

**Assignment:** re-open all 8 staged C3 source rows with the declared fetch profile, record
HTTP/sha256/size, locate each staged quote with a fixed-count grep, and compare the staged sha16
prefix. Report fetch failures and quote drift explicitly.

**Result in one line:** 8/8 fetched HTTP 200; 8/8 quotes still locate; 2/8 staged digest prefixes
match; **zero quote drift, zero fetch failures** — the six mismatches are a pinned-commit
advancement, one volatile ranked API, and four rebuilt vendor pages whose staged digests are
un-attributable from this host.

- Receipts (one per row): `.ufo/waves/round-30/final/c3/src-open/S066.txt` … `S073.txt`
- Machine table: `.ufo/waves/round-30/final/c3/src-open/measurements.tsv`
- Scoped findings: `.ufo/waves/round-30/build/XSrcOpen.md`

## Table

`grep_c` = `grep -c` matching **lines** on the raw body; `occ` = literal occurrences (the archbee
JSON payload can duplicate rendered prose, so a line can carry two). Prefix verdict compares today's
sha256 against the staged sha16, prefix-only.

| id | fetched | located | prefix-match | bytes | sha16 today | staged sha16 | grep_c | 1st line |
|---|---|---|---|---|---|---|---|---|
| S066 | ✅ 200 | ✅ rendered | **✅ MATCH** | 29328 | `65e87e68f4a16aef` | `65e87e68f4a16aef` | 0 raw / 1 rendered | 35 |
| S067 | ✅ 200 | ✅ | ❌ MISMATCH | 38524 | `7cf6efb50ab89234` | `068fbb5c93eb993d` | 1 | 53 |
| S068 | ✅ 200 | ✅ | **✅ MATCH** | 13252 | `f61c3993fd48dfb9` | `f61c3993fd48dfb9` | 1 | 66 |
| S069 | ✅ 200 | ✅ (assertion) | ❌ MISMATCH | 64526 | `b7e19953ecde88d0` | `0c8bdbd04508489c` | 1 | 9 |
| S070 | ✅ 200 | ✅ | ❌ MISMATCH | 102006 | `0beb84fec97fa0ac` | `b1eb8215a66933f9` | 1 (occ 2) | 12 |
| S071 | ✅ 200 | ✅ | ❌ MISMATCH | 161061 | `2c85abe9e3f842a7` | `aef5f76a64c9565a` | 2 (occ 2) | 12 |
| S072 | ✅ 200 | ✅ | ❌ MISMATCH | 99172 | `b4790c43398da9db` | `2997de910834f751` | 1 (occ 2) | 12 |
| S073 | ✅ 200 | ✅ | ❌ MISMATCH | 144104 | `8c0a977c75286c17` | `417032af5635ef39` | 2 (occ 2) | 16 |

## Fetch failures

**None.** All eight URLs answered HTTP 200 on the declared profile
`curl -fsSL --max-time 30 <url>`, first attempt, at the registered URL (no redirect:
`final-url` == registered URL on every row).

## Quote drift

**None.** Every staged quote locates in today's bytes at its authored anchor. Two quotes require
care but are present:

- **S066** — the README bolds the verb (`for **detecting** secrets like passwords, API keys, and
  tokens`), so a raw `grep -c` on the staged quote prints **0** while the lane's
  `rendered-text-v1.py locate` prints **1** (line 35). The quote is intact; the staged needle
  cannot see through the markup.
- **S073** — `sendUnverified` returns **2** lines, exactly as the row expects (yaml example at
  line 16, archbee payload at line 25).

## Why the six mismatches are not drift

| row | attribution |
|---|---|
| S067 | Staged digest `068fbb5c93eb993d` **reproduces exactly** at the pinned commit `d6ea4a52…` (38515 B). Today's `main` HEAD `240ccdd9…` differs by **one line** (HuggingFace "spaces" → "spaces and buckets"). Pin advanced, quote and flag vocabulary untouched. |
| S069 | Live ranked search endpoint. `items[0].full_name == "betterleaks/betterleaks"` ✅ and `fork == false` ✅ (corroborated at `/repos/betterleaks/betterleaks`: fork false, parent null). But stars 2322 → **2774** and `pushed_at` → 2026-11-03, so the staged numbers are stale and the digest cannot reproduce. |
| S070–S073 | All four pages carry `last-modified: 2026-11-03T10:20:23Z` and a shared Next.js `buildId` `7B9L9Z6Go3Rwt4xNufx2f`: the docs site was **rebuilt after 2026-10-23**. Bytes are stable within the day (5 identical curl fetches; corroborated by a second seat) but changed since capture. No variant reproduced the staged digests — gzip/brotli wire bytes, decoded bodies, beacon-stripped HTML, the `.md` route, CRLF, tag-stripped, `www.`/`http://`/trailing-slash hosts, 15 UA × Accept-Encoding combinations — and `archive.org` returned HTTP 429 on every query, so no 2026-10-23 snapshot was reachable to settle attribution. |

**The only body-level variance** trufflesecurity.com introduces is a Cloudflare-insights beacon
`<script type="module" src="…beacon.min.js…">` injected for non-curl User-Agents (curl UA 102006 B
vs `curl/8`/browser UA 102367 B). Neither equals a staged digest.

## Named hazards for the append

1. **S066 quote is markup-sensitive** — the recheck needle must include `**detecting**` or run
   through `rendered-text-v1.py`.
2. **Page stamps are not greppable raw** — `Updated 06 Jul 2026` is served as
   `Updated<!-- --> <!-- -->06 Jul 2026`; raw grep → 0, comment-stripped → 1. Stamp *values* are
   unchanged today (06 Jul / 12 May / 06 Jul / 14 Aug 2026).
3. **S068's CEL clause is unsupported** — "CEL" occurs once, inside a linked post title
   `Express YourCELf`; the README prose says **Expr**. Citing `[S068]` for that clause attributes
   content S068 does not carry. (Independently reached by RAttackC3.)
4. **S071's anchor is mis-attributed** — the quote is §Key Security Principles item 3
   ("Immediate Verification"), not §"What We Don't Do"/Verification Safety, which carry
   "Read-only API calls only" and "No state-changing operations".
5. **Quote counts are route- and needle-dependent** — the `.md` sibling route
   (`<url>.md`, byte-stable, no duplicate payload) gives 1 uniformly, which would make S073 **1,
   not 2**. A capture row must declare its route and its needle.
6. **Staged shapes fail lane gates as-is** — staged entries carry 2/2/4 column-1 `source:` lines
   (`SC_ENTRY_HEADER` fires above 1) and staged rows S068–S073 are `NF=14` from a `\|`-escaped pipe
   (`SC_MALFORMED`). The sibling `normalized-rows.md` is NF=13 clean, and its 8 row-identity digests
   all recompute.
7. **Staged recheck expectations are sound** — run verbatim today they return 1 / 1 / 2 / 1 / 2 for
   S068 / S070 / S071 / S072 / S073, exactly as declared.

## Tooling

No installs or upgrades; no pacman transaction. Used host `curl`, `python3` 3.14.8
(`/usr/bin/python3`), `sha256sum`, `grep`, and the lane's own `corpus/rendered-text-v1.py`. No
credential, vault, `op://` or secret material read; S073's vendor placeholder fields
(`trufflehogScannerToken: thog-agent-XXXX…`) were never copied into any artifact.

## Boundaries observed

Lane production files read-only; no lane git/jj mutation; wrote only my receipt directory, my
`build/XSrcOpen.md`, and scratch under `/fast/scratch/hyaku/kagi-r30/XSrcOpen/` (removed after the
receipts were copied into the wave dir). No sibling seat's files touched.
