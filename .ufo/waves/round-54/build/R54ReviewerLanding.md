# R54ReviewerLanding — review of the landed registry/clock/receipt bytes and the §11.2 entry text

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE `1a0f43a9220bb0e995462c2aef745ac0124c3317`, predeclaration `27aa53fd40b0b385b3cf2ffeea49977f9e0ff690`,
candidate `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14` (committer time `2026-11-07T03:16:28-03:00` = `2026-11-07T06:16:28Z`).
Working tree clean for every reviewed path (`git status --porcelain` shows only untracked `.ufo/waves/round-54/` build/final files).
Scratch `/fast/scratch/hyaku/kagi-r54/R54ReviewerLanding`; no lane file written except this report.

## Frozen reading (measured, not read from a receipt)

```
$ HYAKU_SCRATCH=/fast/scratch/hyaku bash plans/round-54-c1.sh ede4373afa07a33e24cbd35e9fd33fc2fddf2f14
C1_OP_CLOCK: value=2 watched=1 measured=1 guard=1 (bad=watched:OK measured:OK; gate-line=RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17))
rc=0
$ HYAKU_SCRATCH=/fast/scratch/hyaku bash plans/round-54-c1.sh 1a0f43a9220bb0e995462c2aef745ac0124c3317
C1_OP_CLOCK: value=0 watched=0 measured=0 guard=1 (bad=watched:s072-recheck=180d measured:oprcpt-missing-or-symlink; gate-line=RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17))
rc=0
```

Candidate 2, BASE 0, target 2 — the frozen predicate holds, and the BASE reading is the do-nothing control.

```
$ python3 corpus/release-clock.py --selftest
RELEASE_CLOCK_SELFTEST: PASS (121 cases)                     rc=0
$ bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=112 A=108 B=2 C=2 queued=1 mined=107 rejected=4 entries_sourced=16 legacy=21 captures=112 inrow=16 inrow_only=0 inrow_nonreproducing=12)   rc=0
$ python3 -I -B corpus/quote-locate.py
QUOTE_LOCATE: CLEAN located=10 rows=10                       rc=0
```

Selftest 116 → 121 is the five new prefix cases (`corpus/release-clock.py:1404-1440`: declared prefix, anchored/space-delimited prefix, undeclared feed keeps the one-word rule, declared prefix does not widen a python feed, no prefix declared for an undeclared feed) plus the four-case loop and the sops assertion.

## PASS/FAIL table

| # | Item | Verdict | Evidence |
|---|---|---|---|
| 1 | S112 row in `corpus/SOURCES.md` | **PASS** | `corpus/SOURCES.md:119`, 11 cells (`awk -F'|'` NF=13 incl. edge pipes). kind `docs`, tier `A`, status `mined`, recheck `90d`, used-by `corpus/lessons/round-54.md` (file exists, cites S112 at `:1,:14`). Quote `<title>1Password CLI 2.42.0</title>` occurs exactly once in the capture at byte 37215. Anchor fields re-derived from the capture: title, link path `/developers/cli/2.42.0/`, `pubDate Wed, 04 Nov 2026 00:00:00 +0000` (capture's item `<pubDate>`, and 2026-11-04 is a Wednesday). Census CLEAN. |
| 2 | `corpus/source-fetches.tsv` S112 row | **PASS** | `corpus/source-fetches.tsv:155`, 16 TAB fields. `row_identity_sha256 = 231707f1388d8f6acf80f71242bab4e11c044dc7d7fca8927f39b1e91a0936e6` = `printf 'S112\tmined\thttps://releases.1password.com/developers/cli/index.xml\n' \| sha256sum` (formula cross-checked on S111 → `646ef9b9…`). `sha256 2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2`, `bytes 45175` — both equal `sha256sum`/`wc -c` of `.ufo/waves/round-54/capture/S112.body`. |
| 3 | `corpus/quote-bodies.tsv` S112 | **PASS** | `corpus/quote-bodies.tsv:11` → `.ufo/waves/round-54/capture/S112.body` offset `37215`; `dd bs=1 skip=37215 count=33` returns exactly `<title>1Password CLI 2.42.0</title>`. `quote-locate.py` CLEAN located=10 rows=10. |
| 4 | `corpus/release-clocks.tsv` S072 + 31 notes | **PASS** | S072 row (`:30`): 9 fields, clock `feed`, feed_source_id `S112`, feed_url = the feed, anchored `2.41.1`, observed `2.42.0`, `2026-11-07`, `fired`. Scripted BASE↔candidate comparison: 31 → 32 rows, 13 → 14 fired, **columns 1–8 byte-identical for all 31**; every note is a pure append whose single round-54 sentence claims `observed <row observed_version>` (feed rows) or `quote located` (rendered-quote rows) and carries nothing after it. |
| 5 | `.ufo/waves/round-54/final/observe-r54.json` | **PASS** | 32 observations, ids equal to the table's 32 ids; all `http_status` 200; all `observed_at` on 2026-11-07; all 21 feed records carry a body sha256. S072 record: `200 / feed URL / 2.42.0 / fired / sha256 = capture / observed_at 2026-11-07T05:54:19Z`. `sha256sum` = `9513690e3b58ad2198038df888ccb12537553d12ba4f141f9a9d8d0121ce98af` = `DEFAULT_RECEIPT_SHA256` (`corpus/release-clock.py:28`); regular file, no symlinked component (counter `plain_file`, and `ls -l`). Window: floor 2026-11-07T00:00Z ≤ 05:54:19Z ≤ committer time 06:16:28Z. |
| 6 | `### 11.2` claims vs the op receipt | **PASS** (one evidence gap, D4) | `corpus/knowledge/op-ref-consumption.md:399`, inside `## 11.` (`:310`) to the next `## `. Receipt `.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt`: `op_version=2.42.0`, `op_url` = the archive named in the entry, `gpg_validsig=3FEF9748469ADBE15DA7CA80AC2D62742012EA22`, `probe_sha256=0f1945e8…` = `sha256sum corpus/op-ref-probe.sh` = BASE probe (probe unchanged), exactly the six `DOTENV_BYTES_CASE … status=PASS` lines, `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, `exit=0`, `installed_op=/usr/bin/op 2.41.1`, `measured_at=2026-11-07T05:54:46Z`; no FAIL/DRIFT/SETUP line. Lines 371 and 397 still read `recheck: on-release of op`. |
| 7 | S072 teaching after the fire; should S072 have changed further? | **PASS** for the row bytes/teaching; **D1** is a rule-level defect | The round-54 re-fetch of the S072 page (`.ufo/waves/round-54/capture/rejections/app-updates_agilebits_com_product_history_CLI2.body`, fetched 2026-11-07T06:01:52Z) still carries `2.41.1 (build #2410101 ) – released 2026-10-21` with the Go/base-image + `op read` help content and **zero** occurrences of `op run`, `env-file` or `dotenv` in that entry — the teaching (`corpus/SOURCES.md:79`) is still true. Only the recheck cell changed (180d → on-release); status, anchor, teaches, opened, used-by unchanged. The change is what QM70 requires, but it contradicts QM69's second sentence, which was not amended (D1). |

## Defects

### D1 — MEDIUM — `corpus/QUALITY.md:252` (QM69) and `:253` (QM70) now prescribe opposite recheck cells for S072

QM69's second sentence: *"A row that only records a release identity ("the 2.41.1 release") keeps a cadence."* — its own example is literally S072's identity.
QM70: *"A knowledge line that declares `recheck: on-release of <tool>` cites a registry row that is `on-release` with a bound release clock … in the same commit."*

`corpus/knowledge/op-ref-consumption.md:371,397` declare `recheck: on-release of op` and cite S072, so QM70 requires S072 `on-release` (and the counter's WATCHED clause (a) requires it too), while QM69 says an identity-only row keeps a cadence. The landing moved `corpus/SOURCES.md:79` to `on-release` and added QM70 without touching QM69 (the QUALITY diff is a single `+` line). The lane's own M54-1 note (`corpus/lessons/round-54.md:26`) only argues QM69's *first* sentence does not bind S072; it does not address the second.

Consequence: a future round applying QM69 literally reverts S072 to a cadence and breaks QM70 and the frozen counter; the manual the calibration axis is scored on now contradicts the landing it records.
Fix: amend QM69's second sentence with the carve-out, e.g. *"… keeps a cadence unless a knowledge line's `recheck: on-release` cites it (QM70)."*

### D2 — LOW — `corpus/lessons/round-54.md:41` misstates the quote-locate row count by one

Text: *"R38-03's `rows=5` expectation reads 11 rows on this landing (10 at BASE)"*.
Measured: `QUOTE_LOCATE: CLEAN located=10 rows=10`; `corpus/quote-bodies.tsv` has 10 data rows now (11 lines incl. header) and 9 at BASE (10 lines). R38-01's own migration in this landing is `^9$` → `^10$`, which contradicts the lesson's "10 at BASE". Correct text: "reads 10 rows on this landing (9 at BASE)". The lesson appears to count the header line.

### D3 — LOW — the two rejection `.meta` files record a `bytes=` value that is not the size of the `.body` beside it

`.ufo/waves/round-54/capture/rejections/app-updates_agilebits_com_product_history_CLI2.meta:1` → `bytes=74323`, but the committed body is 528203 B; `…/releases_1password_com_developers_cli_.meta:1` → `bytes=20250`, body 96166 B. The `sha256=` in each meta does match its body, so only the size is wrong/mislabeled — it is the compressed transfer length, and nothing in the meta says so. The lesson itself (`corpus/lessons/round-54.md:15-16`) gives the decoded sizes (528203 B, 96166 B), so the two receipts disagree. Fix: label the field `bytes_compressed=` or record the decoded size.

### D4 — INFO (evidence gap) — the signature claim in §11.2 is not re-runnable from the receipt

`corpus/knowledge/op-ref-consumption.md:401` says *"its detached signature verified against the 1Password code-signing key `3FEF…`"*, but the receipt records only `gpg_validsig=3FEF…` — no `.sig` URL, no gpg invocation, no gpg output — and no `op --version` output line (only `op_version=2.42.0`). This is inside the counter's named ceiling (a hand-written op receipt scores MEASURED); the non-author live leg is the check that closes it. Not a false claim, an unverifiable one from the receipt alone.

### D5 — INFO — the fired row's re-open is not traceable from the row or the clock note

S072's `recheck: on-release` is due for a re-open once the clock fires. The re-open happened (the CLI2 page fetched 2026-11-07T06:01:52Z, sha256 `bb179199…`, filed under `capture/rejections/`), but neither `corpus/SOURCES.md:79` (anchor still cites the 2026-11-03 fetch; `opened` still 2026-11-03) nor the S072 note in `corpus/release-clocks.tsv:30` records that the row was re-opened and its teaching re-verified after the fire; only `corpus/lessons/round-54.md:15,17` does. Compare S012's note, which records its re-verification inline. Low: the evidence exists, it is one hop away.

## Observations (no defect found)

- **`op run` in the observed release.** The 2.42.0 entry's notes name an `op run` change (`op item get`, `op run`, `op inject` now return an address-field value when parts of the address are empty, `{DI-1185}`). §11.2 does not mention it, but its "Does not establish" already excludes item reads and ref-resolved values, so no false claim is made; naming it would sharpen the entry.
- **`--format dotenv` is a beta, not the observed release.** The bullet *"The output `--format` flag now includes a `dotenv` format option for 1Password Environment secrets. {DW-1443}"* sits in the **2.43.0-beta.02** entry of the same page (byte range 26972–31316), not in 2.42.0 (dotenv count 0). The clock watches the newest **stable** item by design, so this is not a miss — but when a stable release carries it, it is a dotenv-surface change the six input-byte cases do not cover. Worth a routed item.
- **Anchor link form.** S112's anchor records the item link as a path (`/developers/cli/2.42.0/`) where the capture holds the absolute URL; identical to S111's convention, so consistent, not a defect.
- **Vendor date inconsistency.** The feed's item `pubDate` for 2.42.0 is `Wed, 04 Nov 2026` while the release-notes page says "released 2026-11-03". The row quotes the feed (the clock's source) faithfully; the discrepancy is the vendor's.
- **Saturation honesty.** `SCORECARD.md:1819-1826` books the move on freshness only (9 → 9 on all six axes) and explicitly says the operability change is "counted under C1, not booked twice"; `corpus/claims-declared.tsv` adds exactly one row (`54 C1 freshness`). No double-booking.
- **Stamps.** `corpus/lessons/round-54.md` is not in `corpus/stamps.tsv`, consistent with every lesson after round 42 (stamps hold 34 lessons, last round-42); not a regression.

## Residual risk and verification gaps

- The op receipt is author-written. I did **not** re-fetch the feed, download op 2.42.0, check its signature or re-run the probe — the live leg is a separate seat's check, and the counter's named ceiling (forged receipt / hand-written op receipt) applies until it lands.
- I did **not** run `corpus/claim-ledger.sh verify` (not named by this item). The harm check was read off the author's receipts: `grep -E '^(FAIL|POLICY)'` over `.ufo/waves/round-54/final/verify-base.txt` and `verify-candidate-tree.txt` yields the **same six ids** (R11-08, R25-02, R29-01, R29-02, R36-01, R38-03; md5 over the sorted FAIL/POLICY/STALE/MISSING-ID lines identical in both receipts: `eb5b7a89…`). Not independently re-executed.
- I did **not** re-run `python3 corpus/self-counts.py`; the author's receipt `.ufo/waves/round-54/final/self-counts-candidate-tree.txt` ends `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` rc=2, with every `OK` line, including `SC-CLOCK-SELFTEST … claimed=121 live=121` and `PV-CLOCK-SELFTEST … claimed=121 live=121`.
- The prefix rule is per-feed-URL in code (`FEED_TITLE_PREFIXES`, `corpus/release-clock.py:800-802`); a new vendor feed still needs its own declaration and selftest case — unchanged, named ceiling.
- `corpus/lessons/round-54.md:41`'s off-by-one (D2) means the routed-item note for R38-03 should be corrected before it is cited in a later round.

