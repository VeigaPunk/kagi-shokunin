# XSrcOpen — C3 source re-opening (8 rows, round-30 BUILD wave)

Seat: executor, C3 auxiliary. Date: 2026-11-03. Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`
(BASE `f67232c`, plan commit `b7482b4`). Source package: `/home/vgpnk/Projects/shokuknow/merge/kagi`
(read-only). Receipts: `.ufo/waves/round-30/final/c3/src-open/S066..S073.txt` + `measurements.tsv`.

Every row was fetched this round from the host, with the declared profile
`curl -fsSL --max-time 30 <url>`, and its staged quote located by fixed-count grep.
The campaign's 2026-10-23 dates were taken as claims only, never as evidence.

## Table — 8 rows

`grep_c` = `grep -c` (matching LINES) on the raw body; `occ` = literal occurrences (a line may
carry two when the archbee client payload duplicates the rendered prose). Prefix verdict compares
today's sha256 against the staged sha16 (prefix-only).

| id | url | fetched | bytes | sha16 today | staged sha16 | prefix | quote | grep_c | first line | verdict |
|---|---|---|---|---|---|---|---|---|---|---|
| S066 | gitleaks/gitleaks `master` README | 200 | 29328 | `65e87e68f4a16aef` | `65e87e68f4a16aef` | **MATCH** | LOCATED (rendered) | 0 raw / 1 rendered | 35 | ok |
| S067 | trufflesecurity/trufflehog `main` README | 200 | 38524 | `7cf6efb50ab89234` | `068fbb5c93eb993d` | **MISMATCH** | LOCATED | 1 | 53 | ok, digest moved |
| S068 | betterleaks/betterleaks `main` README | 200 | 13252 | `f61c3993fd48dfb9` | `f61c3993fd48dfb9` | **MATCH** | LOCATED | 1 | 66 | ok |
| S069 | api.github.com search `betterleaks` | 200 | 64526 | `b7e19953ecde88d0` | `0c8bdbd04508489c` | **MISMATCH** | LOCATED | 1 | 9 | assertion holds; numbers stale |
| S070 | trufflesecurity.com/docs/verification-caching | 200 | 102006 | `0beb84fec97fa0ac` | `b1eb8215a66933f9` | **MISMATCH** | LOCATED | 1 (occ 2) | 12 | ok, digest un-attributable |
| S071 | trufflesecurity.com/docs/how-we-handle-your-data | 200 | 161061 | `2c85abe9e3f842a7` | `aef5f76a64c9565a` | **MISMATCH** | LOCATED | 2 (occ 2) | 12 | ok, digest un-attributable |
| S072 | trufflesecurity.com/docs/reverify-secrets | 200 | 99172 | `b4790c43398da9db` | `2997de910834f751` | **MISMATCH** | LOCATED | 1 (occ 2) | 12 | ok, digest un-attributable |
| S073 | trufflesecurity.com/docs/notify-results | 200 | 144104 | `8c0a977c75286c17` | `417032af5635ef39` | **MISMATCH** | LOCATED | 2 (occ 2) | 16 | ok, expected 2 lines confirmed |

Fetch failures: **none**. All eight returned HTTP 200 with the declared profile, first attempt,
no redirect off the registered URL.

Quote drift: **none on any row** — every staged quote still locates in today's bytes, at the
authored anchor. What moved is bytes around the quotes and, on two rows, the recorded numbers.

## The six mismatches, attributed

**S066 — MATCH, and stronger than the row claims.** Today's `master` is
`5f6ec56cfa6f8c67648d863582c7ae2f206d5c1c` (2026-10-23T20:44:59Z) and the README at that HEAD is
byte-identical to the README at the staged pin `b58d3f10…` and to today's `master`: 29328 bytes,
`65e87e68f4a16aef`. The moving ref advanced; the document did not.

**S067 — the staged digest is TRUE, at the pinned commit.** README at `d6ea4a52…` is 38515 bytes,
`068fbb5c93eb993d` — reproduces the staged sha16 exactly. Today's `main` HEAD
`240ccdd9…` (2026-11-03T17:38) is 38524 bytes, `7cf6efb50ab89234`, and differs from the pin by
**one line** (573): HuggingFace "models and spaces." → "models, spaces and buckets." The quote and
the three-valued flag vocabulary are untouched. So: digest correctly pinned, `main` moved one
unrelated line — not a drift finding against the source.

**S069 — volatile ranked endpoint, assertions intact.** `items[0].full_name ==
"betterleaks/betterleaks"` TRUE; `items[0].fork == false` TRUE (corroborated at
`/repos/betterleaks/betterleaks`: fork false, parent null). Three consecutive fetches today were
byte-identical (`b7e19953ecde88d0`, 64526 bytes) and returned the same `items[0]`. But the staged
numbers are dead: stars **2322 → 2774**, `pushed_at` **2026-10-22T21:28:27Z → 2026-11-03T00:45:58Z**
(`total_count` 39). The row must not carry stars/push-date as taught facts; only `full_name` and
`fork` are durable, and `fork` is better pinned from the versionless `/repos/…` object.

**S070–S073 — un-attributable, not contradicted.** All four pages are byte-stable *within* today
(5 consecutive curl fetches identical, and identical across two seats), carry `last-modified:
Tue, 03 Nov 2026 10:20:23 GMT` and a shared Next.js `buildId` `7B9L9Z6Go3Rwt4xNufx2f` — the docs
site was rebuilt after 2026-10-23, so a 10-23 digest of the same URL legitimately differs. I
could not reproduce the staged digests under **any** variant tried: gzip-wire bytes, brotli-wire
bytes, gzip/brotli-decoded bodies, Cloudflare-insights-beacon-stripped HTML, the `.md` route,
CRLF, tag-stripped, `www.`/`http://`/trailing-slash hosts, and 15 UA × Accept-Encoding
combinations. `archive.org` answered HTTP 429 on every query, so no 2026-10-23 snapshot was
reachable to settle attribution either way.

The one body-level variance I could produce: trufflesecurity.com injects
`<script type="module" src="https://static.cloudflareinsights.com/beacon.min.js/…">` when the
request carries a non-`curl` User-Agent (curl UA → 102006 B; `curl/8` or a browser UA → 102367 B,
`a9c48433…`). Neither equals the staged digest. Correct phrasing for the lesson: **"stable within
a day, rebuilt since 2026-10-23"**, not "volatile per request". The staged digests on these four
rows are non-reproducing point attestations and must be recorded as such, never presented as
verified.

## Defects that will bite the append (found by re-opening, not inherited)

1. **S066's quote cannot be `grep -c`-ed as staged.** The README bolds the verb:
   `for **detecting** secrets like passwords, API keys, and tokens`. `grep -cF "detecting secrets
   like passwords, API keys, and tokens"` prints **0**; the lane's `rendered-text-v1.py locate`
   prints 1, and quoting with the markup (`**detecting** secrets …`) greps 1 raw. A recheck needle
   must include the markup or run through the normalizer.

2. **The four page stamps are not greppable in raw HTML.** `Updated 06 Jul 2026` is served as
   `Updated<!-- --> <!-- -->06 Jul 2026`. Raw `grep -cF` on the stamp as written → **0** on all
   four; comment-stripped → 1. So a row whose `anchor` cell names a stamp is naming something a
   plain grep cannot find. (The stamp *values* are unchanged today: 06 Jul / 12 May / 06 Jul /
   14 Aug 2026 — the pages were rebuilt but not re-dated.)

3. **S068's CEL clause is not carried by S068.** "CEL" occurs exactly once in today's README, inside
   a linked Substack title, `3. [Express YourCELf](…)` (line 8). The README prose says **Expr**.
   Any entry claiming "one article describes the rule language as CEL while the README says Expr"
   and citing `[S068]` attributes to S068 content S068 does not contain (independently reached by
   RAttackC3). Drop the clause or cite the article itself.

4. **`grep -c` counts mean different things on the two routes.** For S070/S072 `grep -c` = 1 but
   literal occurrences = 2, because the archbee JSON payload duplicates the prose; S071 and S073
   give 2 lines. But **the staged recheck expectations are all correct as written** (1, 2, 1, 2) —
   the duplication is needle-dependent, so a shorter needle can land 1 where a longer one lands 2.
   The `.md` sibling route (`<url>.md`, e.g. `verification-caching.md`, 1882 B,
   `d6265d99e3e9eef7`, byte-stable, no duplicate payload) gives count 1 uniformly and is the better
   capture representation — but note S073 would then be **1, not 2**, so the expectation must move
   with the route.

5. **S071's anchor is partly wrong even though the quote is right.** The quote
   "Credentials are verified using safe, read-only API calls" is §Key Security Principles item 3
   ("Immediate Verification") — line 17 of the `.md`. The staged anchor points at §"What We Don't Do"
   and the Verification Safety panel; those carry "Read-only API calls only" and "No
   state-changing operations", *not* this sentence. Anchor should name Key Security Principles (or
   both statements should be quoted).

6. **Two lane-gate rules the append must satisfy, proven against the staged material.**
   - `SC_ENTRY_HEADER` fires on **more than one column-1 `source:` line**. The staged entries carry
     2 / 2 / 4 `source:` lines. The lane's own convention (S052, `feed-token-boundaries.md`) is ONE
     `source:` line carrying several ids parenthesised with URL/anchor/date. The staged headers must
     be collapsed before adoption or the census fails.
   - `SC_MALFORMED` requires `NF==13`. Rows S068–S073 in the staged package are **NF=14** because the
     prose `recheck` cell contains a `\|`-escaped pipe (S066/S067 are clean NF=13). The sibling
     normalized-rows draft is already NF=13 clean and its 8 row-identity digests all recompute
     (`sha256("id\tstatus\turl\n")` verified for all 8) — that strip is the correct resolution.
   - Also verified: the sibling `source-fetches-append.tsv` capture rows carry today's digests
     (0beb/2c85/b479/8c0a, b7e1…, f61c…, 65e8…, 7cf6…) and its 8 rendered-text-v1 normalized
     digests match mine exactly (`5e697b14…`, `b7c2613a…`, `df607e98…`, `e4a550c4…`), and no
     non-historical in-row `Fetch sha256:` pin is present (so `SC_INROW inrow-pin-not-historical`
     will not fire). Rows S057–S060 carry `revision -`, which is valid (these URLs are not
     `raw.githubusercontent.com`/`*/main`); S053–S055 carry 40-hex revisions as required.

7. **Every staged recheck command reproduces as written today — confirmed by running them.**
   Run exactly as the staged cells spell them (`curl -fsSL '<url>' | grep -c '<needle>'`), the
   five prose recheck cells return their declared counts: S068 → **1**, S070 → **1**, S071 → **2**,
   S072 → **1**, S073 → **2**. (The three knowledge `recheck:` headers' needles also return 1, 1, 1.)
   So the recheck mechanism is sound and its expectations are not drift. Caveat carried from §4:
   the counts are needle-dependent, so the *quoted* needle must be what the recheck cell and the
   entry header both contain — a shortened needle changes S071/S073 from 2 to 1.

8. **Frozen C3 baselines re-measured at BASE (unchanged, for the record).** Registry rows 52;
   `grep -cE '^ {0,3}\|[[:space:]]*S(05[3-9]|060)[[:space:]]*\|' corpus/SOURCES.md` → 0; none of the
   three knowledge files exists; `corpus/SOURCES.md` still CRLF (193 CR-containing lines) — C2's
   surface, not mine.

## Retention evidence

- `final/c3/src-open/measurements.tsv` — the 8-row machine table (http, bytes, sha256, sha16,
  staged sha16, prefix verdict, grep_c, first line, occurrences, route).
- `final/c3/src-open/S066.txt` … `S073.txt` — one receipt per row: url, date, http, final URL,
  content-type/last-modified, size, full sha256, staged prefix verdict, quote, located-count
  (raw and rendered), first line, route notes, digest attribution, and the row's own caveat.
- Scratch `/fast/scratch/hyaku/kagi-r30/XSrcOpen/` held the fetched bodies and variant probes and
  was removed after the receipts were copied into the wave dir (no receipt depends on it).

## Tooling

No installs, no upgrades. Used the host's `curl`, `python3` (`/usr/bin/python3`), `sha256sum`,
`grep`, and the lane's own `corpus/rendered-text-v1.py` for normalization. No pacman transaction.
No credential, vault, `op://` or secret material was read; S073's vendor config example contains
published placeholder fields (`trufflehogScannerToken: thog-agent-XXXX…`) which were never copied
into any artifact — only the field name `sendUnverified` is cited.

## Risks

- The four trufflesecurity digests are **un-attributable from this host**. If the integrator records
  them as "verified against the staged pin", that is unsupported. They are non-reproducing; the
  quote-level evidence is what stands.
- S070–S073 quote counts are route- and needle-dependent (1 vs 2). A capture row that does not
  declare its route and its needle will look like drift on the next recheck.
- S069's star/push numbers are already stale; carrying them teaches a fact that is false today.
- The staged entry headers (multi-`source:` lines) and staged row shape (NF=14 on six rows) each
  fail a lane gate as-is; the sibling normalization resolves both, but only if it is what the L1
  appends.

## Verdict per row (for the admission decision)

| row | content verdict | usable as staged? |
|---|---|---|
| S066 | quote + semantics intact; add the maintainer "feature complete → Betterleaks" status line | yes, with quote markup fix |
| S067 | quote + vocabulary intact; pin `d6ea4a52` or `240ccdd9` explicitly | yes, pin the revision |
| S068 | quote + stage model intact; **drop the CEL clause** | yes, with the CEL clause removed |
| S069 | `full_name`/`fork` intact; star/push numbers stale | yes, if decorative numbers are dropped |
| S070 | quote + three-hour cache bound intact | yes, digest labelled non-reproducing |
| S071 | quote intact; anchor mis-attributed | yes, with the anchor corrected |
| S072 | quote + GitHub/Slack scope intact | yes, digest labelled non-reproducing |
| S073 | `sendUnverified` switch + notifier matrix intact | yes, state the 2-line expectation (or 1 on `.md`) |
