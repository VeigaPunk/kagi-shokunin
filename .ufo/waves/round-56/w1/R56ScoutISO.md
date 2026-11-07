# R56ScoutISO — independent re-open of the ISO/IEC recheck rows (S101/S113/S114) and the rendered-text locate clock's source (S070/S018)

**Seat:** R56ScoutISO (scout) · **Lane:** kagi, round 56 attempt 3, wave 1 · **Axis:** freshness
**Lane tree:** `/home/vgpnk/Projects/shokunin/kagi-shokunin` — **epoch-B predeclaration `5d9a1571911ec38a456a40b443e19640abb9a88b`** (the lane was re-frozen mid-round; my earlier receipts 01–12 were taken against epoch A `42070de…` and are re-anchored in §6)
**Scratch:** `/fast/scratch/hyaku/kagi-r56/R56ScoutISO/` (deleted before yield; no bodies left in the lane or under /tmp)
**Observed answering model:** `provider=minimax-code`, `model=MiniMax-M3.1-Flash` — read from this seat's own session file (96/96 assistant records) and the launcher log line `"Configured subagent runtime model fallback chain" role=subagent:R56ScoutISO requested=["minimax-code/MiniMax-M3.1-Flash:high"]`. Not guessed from the prompt. Receipt `10-model-and-environment.txt`.

**Tool inventory (all pre-installed; no install was performed, no pacman transaction was run — all pacman transactions are PAUSED):** curl 8.23.0, python3 3.14.8, GNU grep 3.12-modified (`/usr/bin/grep`; the gate resolves `grep` via PATH to the same binary), poppler `pdftotext` 26.10.0. Host `Linux 7.2.11-arch1-1 x86_64`.

**Discipline observed:** no production file in the lane was edited; the only lane writes are this report and `.ufo/waves/round-56/w1/R56ScoutISO.d/*.txt`. No `git`/`jj` mutation in the lane, the fleet or a sibling. No secret, cookie or vault material was read, captured or printed; every fetch was a public GET with **no `-D`/`-i`**, so no response header was written to disk (QM72). Bodies stayed in scratch.

---

## 1. Headline: every stated clock in this seat's scope is TRUE on the live page today

All four URLs were re-fetched on 2026-11-07 with the user agent the clocks declare. Every stated count reproduced exactly, every live body is byte-identical to the committed capture the manifest names, and every digest matches its `corpus/recheck-captures.tsv` row.

### Digest + count table

| id | URL | stated pattern / quote | stated N | live count | verdict | live sha256 | manifest sha256 | bytes | live == committed capture |
|---|---|---|---|---|---|---|---|---|---|
| S101 | `https://www.iso.org/standard/60237.html` | `Withdrawal of International Standard` | 2 | **2** | MATCH | `2e4c1524ec05865536f819db68c56494d97fc67cb490df4f5d4b1ca85b7b0c80` | `2e4c1524…7b0c80` | 85615 | yes (`cmp` rc=0) |
| S113 | `https://www.iso.org/standard/82709.html` | `ISO/IEC 11770-3:2021/Amd` | 3 | **3** | MATCH | `d8dfe35408b17b02845dc0cf19f774bc6cc6b8dcbfe1636e22bb6b13dfa64357` | `d8dfe354…a64357` | 90604 | yes (`cmp` rc=0) |
| S114 | `https://www.iso.org/standard/85929.html` | `International Standard published` | 2 | **2** | MATCH | `8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf` | `8bb88d88…49bdf` | 85138 | yes (`cmp` rc=0) |
| S070 | `https://www.1password.dev/brokered-access/custom-workflow` | rendered-text locate of *"The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator"* | 1 | **1** | MATCH | `5c226c06413854281f229aa0831f3fa7b9e63cdd3d2a4bf761f2226652a1c0dd` | `5c226c06…c0dd` | 268454 | yes (`cmp` rc=0) |

Every live fetch returned HTTP 200 with the expected content type; `curl` rc=0 in all four cases. Each ISO body was fetched three times independently and all three digests were identical (`S101.r1/r2/r3` = `2e4c1524…`, `S113.r1/r2/r3` = `d8dfe354…`, `S114.r1/r2/r3` = `8bb88d88…`), so the counts are not a one-shot artefact.
**Receipts:** `01-iso-live-fetch.txt`, `02-digest-vs-manifest.txt`, `03-live-grep-counts.txt`, `04-s070-locate.txt`.

### Where each count comes from (the counts are the counts, not coincidences)

- **S101 → 2.** Line 751 is the status block (`Stage : Withdrawal of International Standard [95.99]`); line 1071 is the life-cycle list entry. Byte offsets 45752 and 62765. The entry's own reading — "the page carries the stage twice, in the stage line and in the life-cycle list" — reproduces exactly, and the S101 row's quoted offset **45752** is the first occurrence, as stated.
- **S113 → 3.** Lines 917 (`indexReference_cs85929`), 918 (`itemReference_cs85929`) and 1224 (the `Amendments` block `<h4><a href="/standard/85929.html">`). The `Amendments` block on the live S113 page lists **exactly one** amendment (`ISO/IEC 11770-3:2021/Amd 1:2025` → `/standard/85929.html`), so the entry's rationale — "counts every amendment of the 2021 edition the record lists, so a new amendment moves it" — holds against today's page. The S113 row's quoted offset **53493** reproduces.
- **S114 → 2.** Line 848 (`Stage : International Standard published [60.60]`) and line 1072 (life-cycle list). Offsets 49075 and 60840. The S114 row's quoted offset **541** for `ISO/IEC 11770-3:2021/Amd 1:2025` reproduces.
- **S070 → 1.** `RENDERED_TEXT_V1_LOCATE: count=1` on the live stream, on the live body saved to scratch, and on the committed capture `.ufo/waves/round-56/capture/S070.body`. The count is the *normalised* count; the raw HTML carries the sentence twice (the sentence spans an anchor element), so the `rendered-text-v1` normaliser is doing exactly the work the clock depends on.

**Receipts:** `03-live-grep-counts.txt` (counts, matching lines, byte offsets, three-fetch stability), `04-s070-locate.txt` (locate verbatim on live/offline/live-body), `06-registry-row-claims.txt` (status/publication-date/stage blocks and every quoted offset), `09-pattern-discriminating-power.txt` (cross-presence matrix + the single-amendment block).

### Discriminating power (a "true but non-discriminating pattern" would score — checked)

Pattern counts across the three ISO bodies (`grep -c`, live bytes):

| pattern | S101 body | S113 body | S114 body |
|---|---|---|---|
| `Withdrawal of International Standard` | 2 | 2 | 2 |
| `ISO/IEC 11770-3:2021/Amd` | 0 | 3 | 13 |
| `International Standard published` | 1 | 2 | 2 |

Each clock's pattern is **not** constant across the three pages, so the count is discriminating, not a page-independent constant. Note one nuance worth recording: the S101 pattern happens to give 2 on all three bodies — but for different reasons (S101: the 2015 record's own stage line + its life-cycle list; S113: a life-cycle entry "Withdrawal of International Standard proposed by TC or SC" at line 1195 plus the 2015 edition's withdrawal at 1212; S114 likewise). Each clock still binds its own URL, so this does not affect the gate — but a reader should know the S101 pattern is not unique to the 2015 record's stage line.
**Receipt:** `09-pattern-discriminating-power.txt`.

---

## 2. Default-UA 403 on 82709: **it reproduces** — and the tree already carries a receipt for it

Round-55 spotcheck **D3** asked: *"The S113 row asserts 'the default user agent receives HTTP 403', but the only default-UA receipt is for the S114 URL. Either probe S113 with the default UA and store the receipt or narrow the row text."*

**Measured 2026-11-07, default UA (`curl/8.23.0`, no `-A`), `curl -sSL --max-time 60`:**

| id | URL | HTTP | bytes | body |
|---|---|---|---|---|
| S113 | `…/standard/82709.html` | **403** | 5448 | `<title>Just a moment...</title>` (Cloudflare interstitial) |
| S114 | `…/standard/85929.html` | **403** | 5448 | `<title>Just a moment...</title>` |
| S101 | `…/standard/60237.html` | **403** | 5448 | `<title>Just a moment...</title>` |

All three rc=0. Three further default-UA fetches of **82709** returned 403/5448 bytes each time, with three *different* sha256 values — the Cloudflare interstitial carries a per-request token, so it is **not byte-reproducible**; a receipt on it is a status+length observation, not a digest pin. This is a fact the lane's own S018 lesson text already anticipates for volatile representations, and it matters for how any future receipt on a 403 body should be phrased.

**The frozen tree already answers D3.** `git ls-tree -r 42070de…` lists `.ufo/waves/round-56/capture/rejections/S113-default-ua.body` — a receipt **taken on the S113 URL (82709)**, 5448 bytes, sha256 `ce3cb7f2eb0efeba38faff1ded3186218ad9df51e4b22b795d0688fa2eb3893c`, title `Just a moment...`, and a clean header-byte scan (`HTTP/` status line: 0, `set-cookie:` line: 0). My independent default-UA fetch of 82709 confirms the same status and the same 5448-byte length. So D3's request is satisfied by committed bytes plus an independent non-author re-fetch; no row text needs narrowing.

**Why the clock must keep the browser UA (the false-fire mechanism, measured).** Against the default-UA 403 body every stated pattern counts **0**:

- S101 `Withdrawal of International Standard` → 0
- S113 `ISO/IEC 11770-3:2021/Amd` → 0
- S114 `International Standard published` → 0

and the clock run *as written* (`curl -fsSL … | grep -c …`) makes curl exit **22** (`-f` refuses the 403 page), so the pipe prints `0` — a **false change** against a stated 2/3/2. This is exactly round-55 lesson item 6 (R55ScoutISO D6): a `curl -fsSL` against the Cloudflare 403 prints `0`, which fails safe but reads as drift. The ISO clocks' `-A 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36'` is therefore load-bearing, and the entry's stated command keeps it.
**Receipts:** `05-default-ua-403.txt`, `11-frozen-tree-and-d3-receipt.txt`.

---

## 3. The S070 / S018 pair — the locate clock's source, and one freshness finding

**The pair is two registry rows for one page.** `corpus/SOURCES.md` S018 carries the **trailing-slash** URL `https://www.1password.dev/brokered-access/custom-workflow/`; S070 carries the **no-slash** URL `https://www.1password.dev/brokered-access/custom-workflow`. The clock in `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md:3` uses the **no-slash** form, so it is S070's URL and S070's manifest row. Measured: the slash form **redirects (1 redirect)** to the no-slash form and serves **byte-identical** bytes (`cmp` rc=0, both `5c226c06…`), so both registry rows describe the same live document today.

**The gate's id↔URL binding is strict, and I probed it** (scratch fixture copy of `corpus/{rendered-text-v1.py, SOURCES.md, recheck-replay.py}` + the lane's S070 capture; the lane was not touched):

| probe | manifest id | manifest url | gate verdict |
|---|---|---|---|
| A | S018 | slash form (S018's own) | **MATCH** — accepted |
| B | S018 | no-slash form (the clock's url) | `BAD-CAPTURE … reason=url-not-in-row:S018` |
| C | S070 | slash form | `BAD-CAPTURE … reason=url-not-in-row:S070` |

So the manifest row must name the registry row that actually carries the clock's URL string; swapping the id or the URL form is refused. The committed manifest row (id=S070, no-slash URL) is the correct binding.
**Receipt:** `07-gate-s018-s070-probes.txt`.

### Freshness finding (not a gate failure): the S070 page changed between 2026-11-03 and 2026-11-07

The entry's `source:` line states for S070: *"page fetch sha256 `a34902cc251b9d9c` (raw body carries per-request markup; **stable rendered-text-v1 sha256 `20fbc423c4faea78`**), fetched 2026-11-03"*. Measured today:

| body | raw sha256 | bytes | normalized sha256 | normalized bytes |
|---|---|---|---|---|
| round-31 in-round capture, 2026-11-03 | `a34902cc251b9d9c9573ff25d7bd9a230494689a4cc9a6c99775c1f1e28eca0b` | 266770 | `20fbc423c4faea7839316780ef28a5fad24e30982cbc9636e3f9c46c26a76271` | 90174 |
| live today / committed round-56 capture | `5c226c06413854281f229aa0831f3fa7b9e63cdd3d2a4bf761f2226652a1c0dd` | 268454 | `7127a2c103b36be3893967db17050533bdac181f0b36cdc5a8d8a5b039f9870d` | 90617 |

The raw digest moved **and** the normalised digest moved (+443 normalised bytes). This is **not** per-request noise: four fetches of S070 across three request profiles (plain `curl -fsSL`, `curl -fsSL --compressed`, and the lane's declared `curl-fsSL-compressed-v1` profile with the `kagi-shokunin-round23/1.0` UA) all returned the **same** raw digest `5c226c06…`, and the trailing-slash URL returned the same bytes again. The page was rebuilt — the live body now carries `buildId 6aed09f917f063f212f7ad66`, `deploymentId 68a8af9a517ab813d3b84097`, `clientVersion 0.0.4076`, `lastModified 2026-11-03T20:48:37.001Z` inside the rendered text.

**Consequences, stated precisely.**
1. **The stated clock still holds.** `count=1` on the live body and on the committed capture. Nothing in the C1 claim is falsified.
2. **The word "stable" in the entry's S070 source line is now stale.** The entry calls `20fbc423c4faea78` the *stable* rendered-text digest; today's page produces `7127a2c1…`. The row's own convention already allows for this — `corpus/source-fetches.tsv` classifies S070 as `decoded-http-body-volatile-v1` and states *"the normalized digest is a more stable point attestation, still chrome-sensitive, never a drift pin. No cross-capture equality is enforced."* — but the entry's prose asserts stability of a specific digest value, and that value no longer reproduces. Under QM1 (a digest presented in current voice about a value that has moved) this is a wording defect in the `source:` line, not a content error in the entry's claim.
3. **The same holds for the sibling row.** S018 was captured 2026-10-21 at **1283173** bytes with normalised digest `d493bd81…`; today's body is **268454** bytes with `7127a2c1…`. The page was rebuilt at least twice since S018 was mined. S018's own quote — the page title — still locates on today's body (`RENDERED_TEXT_V1_LOCATE: count=14`), and its substantive claims still hold: `1Password Credential Broker is only supported in the 1Password JavaScript SDK at this time` (2), `1Password Business account` (2), `beta release of the 1Password desktop app` (2), title `(public beta)` (5).

**Actionable, and squarely in scope for the freshness axis:** the entry's S070 source line and the S018/S070 provenance rows should carry the round-56 capture's digest (`5c226c06…` / `7127a2c1…`, fetched 2026-11-07) or an explicit "as of" date, instead of a present-tense "stable … sha256" that the page no longer produces. This is exactly the class of drift the new C1 capability is meant to make visible — and it is visible only because a non-author re-fetch was run.
**Receipts:** `08-s070-normalized-digest-moved.txt`, `04-s070-locate.txt`.

#### Addendum (receipt `12-landing-safety-checks.txt`): the same drift hits **S069**, on the same source line

`S069` (`https://www.1password.dev/brokered-access`) is named in the **same** `source:` line of the same entry and carries the same "stable rendered-text-v1 sha256" claim. Measured today under the lane's own `curl-fsSL-compressed-v1` profile, three independent fetches, one digest:

| body | raw sha256 | bytes | normalized sha256 |
|---|---|---|---|
| 2026-11-03 attestation (`source-fetches.tsv` S069, cols 8/10/11/15) | `6179e9c1408515293f7fdf9b6445a4318e5a1289fc036fbb7559a21e3c6fa93c` | 215346 | `232239dd8ae8e792148706d72c1c13707a3a6a195046141950e10448cf003b50` |
| live 2026-11-07 | `6b4e78533fb2da34ccd16e08a67033ab8c6642a6a69293d84b12917b8ec75df8` | 216522 | `d12a9bb380029ac05f308a76bd8d8126a113a482c1efb24047c096000cd3796a` |

So the rebuild moved **S069 and S070 together**; a source line that re-dates only S070 leaves half of the same sentence stale.

Landing-safety facts for the L1's edit (all measured, receipt 12):
- **No gate parses an entry's source-line digest prose.** `grep -rl 'rendered-text-v1 sha256' corpus/` and `grep -rl 'page fetch sha256' corpus/` return **knowledge `.md` files only** — no `.sh`/`.py`. `corpus/sources-census.sh`, `corpus/claim-ledger.sh` and `corpus/self-counts.py` read the registry rows and the provenance table, never an entry's prose digest. **The entry-line edit is gate-safe.**
- **No in-row `Fetch sha256:` pin** exists on S018/S070/S101/S113/S114, so no `corpus/inrow-pins.tsv` classification is required (that census cross-check binds only the historical S001–S016 rows).
- If the L1 instead refreshes `corpus/source-fetches.tsv`'s **S070 row**: (a) `row_identity_sha256` is `sha256("id\tstatus\turl")` and does **not** change when digest columns change — computed `58690583e5af268b242e61d642841a40622d3d9c0525b3e8e530dca9debfcf7e` equals the committed col 3 (S018: computed `ddb614c5d10e69bf33707d9696a66a702dfe2dcd1891027a94ecead73479bcf2` = committed col 3); (b) the census refuses a **second** provenance row for one id (`SC_FETCH id=… duplicate-provenance`) — replace the row in place, do not append; (c) `corpus/SOURCES.md`'s S070 row names that capture **by date** ("in-round capture 2026-11-03 in `corpus/source-fetches.tsv`"), so a changed `fetched` date must be mirrored there.
- **SC_BODY_CITE is safe**: S069, S070, S071 and S018 all already list `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md` in their `used-by` cell, so naming S018 in the entry's source line cannot break the census.

---

## 4. Other ISO row claims re-checked against the live bodies

All hold (`06-registry-row-claims.txt`):

- **S101** — Status `Withdrawn`, Publication date `2015-08`, Stage `Withdrawal of International Standard [95.99]`; quote offset 45752 ✓; the row's "the archive snapshot timed out at 30 s and is not cited" **reproduces** today: `curl -sSL --max-time 30 https://web.archive.org/web/2025/…60237.html` → rc=**28**, 0 bytes.
- **S113** — Status `Published`, Publication date `2021-10`, Stage `International Standard published [60.60]`; quote offset 53493 ✓; `2021-10-22` present once, `60.60` three times.
- **S114** — Status `Published`, Publication date `2025-04`, Stage `International Standard published [60.60]`; title `ISO/IEC 11770-3:2021/Amd 1:2025 - Information security — Key management — Part 3: Mechanisms using asymmetric techniques — Amendment 1: TFNS identity-based key agreement` ✓ (the row's "TFNS identity-based key agreement" subtitle ✓); quote offset 541 ✓.
- **S070 row anchors** — title `Use 1Password Credential Broker to access secrets in custom workflows at runtime (public beta) - 1Password Developer` ✓; `Step 2. Connect your Environment to your workflow` (period form) = 3 ✓ and `Step 2: Connect …` (colon form) = **0** ✓ — the row's "the staged colon form locates 0 times, corrected in-round" still holds; `Step 3: Use your Environment in your workflow` (colon form) = 3 ✓.

---

## 5. Gate and manifest state observed on the lane (read-only)

- `python3 corpus/recheck-replay.py` on the working tree: **rc=0**, last line `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)`, with `MATCH … id=S070 form=locate stated=1 replayed=1` and the three ISO `MATCH` lines at stated=replayed=2/3/2. **Receipt:** `11-frozen-tree-and-d3-receipt.txt`.
- The gate resolves `grep` through PATH to `/usr/bin/grep` (GNU grep 3.12), the same binary this seat measured with; the tool shell's `grep` is a pi-uu-grep builtin, but it returned the same three counts. **Receipt:** `10-model-and-environment.txt`.
- All four live bodies carry **no** HTTP status line and **no** `set-cookie:` line (QM72 clean). **Receipt:** `02-digest-vs-manifest.txt`.
- Working-tree drift observed (other seats are landing; **not** this seat's edit): `corpus/recheck-replay.py`, `plans/round-56-c1.sh`, `plans/round-56.md` are modified relative to HEAD `42070de…`. **Receipt:** `11-frozen-tree-and-d3-receipt.txt`.

---

## 6. Epoch-B anchoring and the L1's landing edit, verified

The lane was **re-frozen mid-round**: epoch-B predeclaration `5d9a1571911ec38a456a40b443e19640abb9a88b` carries the re-frozen instruments (`plans/round-56.md`, `plans/round-56-c1.sh`, `plans/round-56-controls.sh`, `corpus/recheck-replay.py`). My receipts 01–12 were taken against epoch A `42070de…`; the split is:

- **Revision-independent** — every live fetch, digest, grep count and locate count in receipts 01–10. These are facts about the live pages on 2026-11-07, not about a lane tree; they hold at any revision. **No re-measurement needed.**
- **Revision-dependent** — the instrument readings (gate run, gate selftest, counter, census, registry/provenance rows). All re-executed against epoch B and against the epoch-B candidate tree; receipts 13 and 14.

**Readings on the candidate tree** (epoch-B instruments + the L1's two content edits, both still uncommitted when measured):

| command | result |
|---|---|
| `bash plans/round-56-c1.sh --tree <lane>` | `C1_REPLAY: value=10 present=10 replayed=10 gate=1 guard=1 (bad=none)` |
| `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=114 A=110 B=2 C=2 queued=1 mined=109 rejected=4 entries_sourced=16 legacy=21 captures=114 inrow=16 inrow_only=0 inrow_nonreproducing=12)` |
| `python3 corpus/recheck-replay.py` | `RECHECK_REPLAY: CLEAN (clocks=10 match=10 mismatch=0 no_capture=0 bad_capture=0 unsupported=0 tool=0)` |
| `python3 corpus/recheck-replay.py --selftest` | `RECHECK_REPLAY_SELFTEST: PASS (13 cases)` |

`git diff --quiet 5d9a157 -- plans/round-56.md plans/round-56-c1.sh plans/round-56-controls.sh corpus/recheck-replay.py` → **byte-identical**, so the kill-rule pathspec holds; the candidate's only deltas against epoch B are `corpus/SOURCES.md` and `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md` (one line each). The epoch-B gate bytes and the counter's pin agree: `2e9dfde326b29fb95f520c5d7f3a671836682b28025e4efc7887333257d4df51`.

**The L1's reported counter readings, re-verified here:** `5d9a157` → `value=10 present=10 replayed=10 gate=1 guard=1`; BASE `832ba6a` → `value=0 … bad=r2-manifest` on all 10 (no manifest at BASE); epoch A `42070de` → `value=0 … bad=r5-gate` on all 10 (epoch A's counter carried no gate digest pin, so the gate was not identity-bound). All three reproduce.

**Answer to the L1's question — the `corpus/SOURCES.md` date mirror is NOT required.** Measured, not argued:
- The census cross-checks that bind for these ids are registry **status**, registry **URL**, and `row_identity_sha256 = sha256(id<TAB>status<TAB>url)`. None of them mentions a fetch date. S070: computed `58690583e5af268b242e61d642841a40622d3d9c0525b3e8e530dca9debfcf7e` = committed col 3; S018: computed `ddb614c5d10e69bf33707d9696a66a702dfe2dcd1891027a94ecead73479bcf2` = committed col 3.
- The census's **date**-bearing cross-check (`corpus/inrow-pins.tsv` vs the capture row's `fetched`) binds only the historical S001–S016 rows. S018/S070/S101/S113/S114 carry no in-row `Fetch sha256:` pin.
- The L1 is not touching `corpus/source-fetches.tsv`, so the S070 provenance row still reads `fetched=2026-11-03, normalized 20fbc423c4faea78…` — a dated point attestation that stays accurate — and `corpus/SOURCES.md`'s S070 row ("in-round capture 2026-11-03 in `corpus/source-fetches.tsv`") remains accurate **as history**. A date mirror would be a no-op for the census.
- Empirical proof: the census run on a scratch copy with the entry file reverted to epoch A (pre-edit) returns the **identical** CLEAN line and tallies as the run with the L1's edit. The edit introduces **zero** census findings.

**The L1's S113 registry-row edit (D3 closure) verified against the committed bytes:** the row now names "HTTP 403, 5448 B, sha256 `ce3cb7f2eb0efeba38faff1ded3186218ad9df51e4b22b795d0688fa2eb3893c`"; the committed `.ufo/waves/round-56/capture/rejections/S113-default-ua.body` is exactly 5448 bytes with that sha256, title `Just a moment...`, no HTTP status line and no `set-cookie:` line. My independent default-UA fetch of 82709 (receipt 05) gives the same status and length. **D3 is closed in the registry text as well as in the tree.**

**Receipts:** `13-landing-verification.txt`, `14-epoch-b-anchoring.txt`.

---

## 7. Unresolved / not covered by this seat

- I did **not** re-fetch the six non-ISO/S070 manifest rows (S054, S055, S057, S067, S074, S078) — they are outside this seat's scope; R56ExecLive's lane covers them.
- I did **not** run `plans/round-56-c1.sh` against BASE or a candidate: the counter's own frozen predicate is a kill-rule-sensitive artefact under active edit by other seats, and running it is the L1's/integration seat's step, not a scout's live-receipt step. My scope was the live leg.
- The **S069/S070 digest-drift wording defect** (§3) is a finding, not a fix: this seat does not edit production files. The L1 has since applied the fix in the working tree (both clauses on the same `source:` line), and I verified that edit against the census and the counter (§6). Whether it is committed is the L1's call.
- The **S018 stale digest** (2026-10-21) lives only in `corpus/source-fetches.tsv` as a dated point attestation — accurate as history, so it needs no change; the L1 has routed it.
- The ISO pages are Cloudflare-fronted: round-55 lesson item 6 recorded 1 interstitial in 43 browser-agent fetches under parallel load. My fetches were sequential and all returned 200; I did not run a parallel burst.

## 8. What I ran vs what I did not

Ran (each with receipt, command, rc): 4 live fetches (browser UA) + 3×3 repeat fetches for stability + 6 default-UA fetches + 1 archive-timeout probe + `sha256sum`/`cmp`/`grep -c`/`grep -abo`/`grep -n` on live and committed bodies + `rendered-text-v1 digest` and `locate` on live, capture and stream + `recheck-replay.py` on the lane + 3 gate probes in a scratch fixture + the gate's own `--root` verdicts.
**Not run:** the counter, the controls script, any commit, any network write, any credential-bearing endpoint.

---

**Report:** `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-56/w1/R56ScoutISO.md`
**Receipts:** `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-56/w1/R56ScoutISO.d/` (01 … 11)
