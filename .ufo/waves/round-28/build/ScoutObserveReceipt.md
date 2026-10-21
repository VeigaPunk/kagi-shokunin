# Scout — `--observe` / `--receipt` flow map for C1+C2

BASE `3553d499577084a6c98d7078906017840bbf7b28`; lane HEAD `bdf90f58…` (code identical; read-only git). Target `corpus/release-clock.py`; line numbers are BASE. Probe runs are drafts in `.ufo/waves/round-28/sandboxes/ScoutObserveReceipt-7/`.

## Findings

**1. All three modes converge on `evaluate` — observe writes evidence first.**
- default verify: `main:1742-1747` → `receipt_path:495-499` (default `.ufo/waves/round-26/observe-2.json`:497) bound to `DEFAULT_RECEIPT_SHA256` (:28; file digest verified equal) → `evaluate:1748`.
- `--receipt/--receipt-sha`: same loader, digest from the flag (:1744-1747); a relative `--receipt` resolves against `--root`, not cwd (:495-499).
- `--observe`: `run_observe` (:1739) fetches (`observe_one:767-825`) → `write_receipt` (:889 → :828-859; atomic temp+`os.link`:838-845; refuses existing path/symlink:836-837; 0600) → `load_receipt_bundle(Path(out))` with **no digest** (:1740) → `evaluate:1748`.
- Re-verification: `load_receipt_bundle:458-493` (digest 469-474, format 480-483, duplicate ids 484-492); `receipt_matches:425-456` (feed branch 440-446; equality at 444 is `norm_version` **string** equality); orphan ids 628-630; regressed receipt verdict 616-618.

**2. C1 feed-entry token: one producer, no typed channel.**
`parse_latest_version:715-760` accepts `[0-9]+` per component (regexes 710-712; text branch 726-730) and int-converts every match at 760. Reproduced:
- leading zero becomes a **fired release**: observe over a python feed whose newest item is `Python 3.15.01` writes `S027/S028/S040/S041 = parsed_version 3.15.01, verdict fired`; the entire test is `norm_version` string inequality (798-801).
- oversize: a 4301-digit patch raises `ValueError` in the `max` key (760), caught at 822-823; the receipt records a generic `error="Exceeds the limit (4300 digits)…"`, no verdict, and `run_observe` prints only counts (894-896). No traceback, no typed finding.
- mixed feeds are XML-order dependent: `[3.15.1, 3.15.01]` → `3.15.1`; reversed → `3.15.01` (direct calls). A "tighten regex / filter, then max" fix returns a clean version and emits **no finding** whenever a canonical twin exists — a silent skip of the feed-entry obligation.

**3. C1 table tokens: the anchor is unchecked; floors pre-empt the row loop.**
- `numeric_version:369-381` int-converts at 380; `is_regression:383-388` and `feed_floors:390-410` call it; `feed_floors` runs at `evaluate:523` **before** the row loop and at `run_observe:885` **before** any fetch.
- oversize `anchored_version` tracebacks at `feed_floors:404` in all modes (callers 523/885; no receipt is written in observe). Guarding only 576-579 does not fix this: make `numeric_version` total for oversize and let the row check type the finding.
- non-canonical anchor: BASE accepted `anchored_version=3.15.01`, `observed_version=3.15.1`, `verdict=fired`, with S040's SOURCES.md anchor cell edited in the sandbox to name `Python 3.15.01` (a registry typo, mirroring a mistyped feed title), plus a digest-pinned matching receipt → `CLEAN`, exit 0, `fired=4`. With the unmodified canonical source cell the row is `INCONSISTENT` only because `version_is_named:341-347` (566) misses the typo in prose; there is no canonicality rule.
- `derived:` rows are exempt from naming: `anchor_ok = is_derived or …` (:565-566). `derived:` notes are the C2 trust surface.

**4. C2 binds the FEED row's anchor, in `evaluate`.**
- `parse_sources:58-97` stores cells[5] as `anchor` (:87); resolve `feed_source` at 556 and bind at 565-566.
- Do **not** reuse `sources[row_id]["anchor"]`: all 15 derived rows fail that test (S029's own anchor names 8.23.1, S009-S011 name only a docs commit) → 15 false findings and a failed control. All 15 bind correctly to their feed row at BASE (S008-S011→S033, S013/S022-S024→S034, S014-S016/S021/S025/S026→S035, S029→S037; S037's cell names `8.23.0`, not the note's `8.23.1`).
- `BADFEED` (:556-564) does not `continue`, so an unguarded `feed_source["anchor"]` on a `derived:` row naming an absent id (`S999`) raises `TypeError` (reproduced) — guard `feed_source is not None`.
- Series anchor `v1.21.x` (`release-clocks.tsv:9`, S012) must stay legal: a blanket "anchor must be canonical X.Y.Z" flips the control to `NONCANONICAL S012`, exit 1 (reproduced). Apply canonicality only to tokens matching the permissive `[0-9]+\.[0-9]+\.[0-9]+` shape; non-numeric anchors keep the inequality rule.

**5. Modes where a new check is silently skipped.**
| check lives in | default | `--receipt` | `--observe` |
|---|---|---|---|
| `evaluate` row loop (C1 row/anchor, C2) | fires | fires | fires, **after** `write_receipt:889` |
| `receipt_matches` / receipt re-verification | fires | fires | fires |
| `parse_latest_version`/`observe_one`/`run_observe` | **skipped** | **skipped** | fires |
| `feed_floors` | no finding channel (shared by 523/885) | same | same |
| `--selftest` | `main:1714-1719` returns before parse/evaluate | — | — |

- `--observe` with an existing output path: `write_receipt:836-837` → `SetupError` → `main:1749-1751`, exit 2 **before** evaluate; no C1/C2 finding (a measure reusing a path reads exit 2, not EXACT).
- Observe persists a receipt before evaluate sees the TSV (889 vs 1748), so a row-level-only C1 check still permits a fired observation to be written (the frozen predicate's "written fired observation"). The guard must be in `parse_latest_version`/`observe_one` **and** printed by `run_observe` (only the summary prints at 894-896; the receipt `error` string is not a category). Probe model: raise at the parse gate, print `NONCANONICAL <row-id>` after 890 — receipt then has `error="non-canonical release token in feed"`, no verdict.
- Receipt-mode token gap: a retained receipt with `parsed_version=3.15.01` while the TSV is canonical `3.15.1` yields only `RECEIPT-MISMATCH S040` (probe). If a *typed* receipt-token finding is required, check canonicality of `receipt["parsed_version"]` around :613 or return a reason from `receipt_matches:440-446` (that helper is bool-only).
- Observe re-reads its own output with no digest (:1740) — a post-write swap changes what evaluate re-verifies. Not a C1/C2 skip, but explicit `--receipt` is digest-bound and observe is not.

**6. Frozen fixtures interact with the pinned receipt (measure design).**
- C1 F1 under the default command at BASE exits 1 only via `RECEIPT-MISMATCH S040` (pinned round-26 receipt). With a matching digest-pinned receipt (receipt mode) BASE is `CLEAN`, exit 0, `fired=4`: the row-level lie is accepted. F1 is otherwise counted TYPED at BASE for the wrong reason; the measure must assert the canonicality category.
- F3 observe at BASE already exits 1 (receipt mismatches); its mishandling is visible only in the written receipt (fired/3.15.01). F4 observe exits 1, no traceback, generic error — literally "TYPED" under the frozen predicate despite no canonicality finding.
- C2 G1…G4 as "release-clocks.tsv edits only" cannot be ACCEPTED at BASE under the default command: the pinned receipt yields `RECEIPT-MISMATCH S008-S011`, exit 1. A receipt synthesized from the mutated TSV and passed as `--receipt`+`--receipt-sha` reproduces `CLEAN`, exit 0 (G1 proved). The measure must build that receipt (selftest does this at 934-957) or the "before ACCEPTED" premise is false.
- "local copy of the python.org feed" cannot be a file URL: `valid_public_https_url` (:176) and `request_body` (:669) require public HTTPS. The measure must import the module and stub `request_body`/`opener` (selftest: `StaticOpener` 1421-1430, global replacement 1588-1590). `--observe` needs a fresh output path each run.
- C2 vs selftest fixture: `fixture_source("S002", …, "Latest release", …)` (:987; recapture :1564) names no version, so a feed-row-bound C2 check fails the three existing derived cases — "derived anchor counted" (:1052), "non-numeric anchor keeps inequality" (:1073), "feed floor lifts non-numeric anchor" (:1084) — reproduced (`DERIVATION S001`, count changes). Those fixtures need a per-case feed anchor (series cases must name `1.2.x`) before new C1/C2 cases are added.

## Commands run (sandbox only, `python3 -I -B`)
- control `base/… --root base` → `CLEAN (…observed=30 fired=3 derived=15)`, exit 0.
- F1 default → `RECEIPT-MISMATCH S040`, exit 1; F1 + matching receipt → `CLEAN … fired=4`, exit 0.
- F2 (4301-digit observed) → `Traceback` `ValueError` at 380 via `is_regression:386`/`evaluate:567`, exit 1; F2b (4301-digit anchor) → `Traceback` at `feed_floors:404` via `evaluate:523`; same fixture `--observe` → `Traceback` at `run_observe:885`, exit 1, no receipt.
- F1c (anchor `3.15.01`, SOURCES.md names it) + matching receipt → `CLEAN … fired=4`, exit 0.
- F3 observe (stub, newest `Python 3.15.01`) → receipt `S027/S028/S040/S041 = 3.15.01/fired`, exit 1; F4 observe → generic error receipt, no verdict, no traceback, exit 1.
- G1 (S008-S011 lowered to 3.12.0) + matching receipt → `CLEAN`, exit 0; same TSV with the default receipt → `RECEIPT-MISMATCH S008-S011`, exit 1.
- direct `parse_latest_version`: mixed order → `3.15.1` / `3.15.01`; text `Version: 8.23.01` → `8.23.01` (no finding).
- probe draft (parse+row canonical gate, feed-row C2): control `CLEAN`; F1/F2/F1c/F2b → `NONCANONICAL S040`, exit 1; G1 → exactly `DERIVATION S008 S009 S010 S011`, exit 1; F3/F4 observe → `NONCANONICAL S027/S028/S040/S041`, error receipts; `--selftest` → the 3 failures of §6; unguarded C2 → `TypeError` at `feed_source["anchor"]`, exit 1.

## Not checked
- No live network, vault, account, handler or CDP contact; feeds were stubbed.
- `.ufo/waves/round-28/tools/c1-measure.py` / `c2-measure.py` do not exist yet (`tools/` absent), so the frozen counting commands were not run; §6 is from direct fixture construction.
- Did not run the lane selftest in the lane checkout; selftest ran only on sandbox copies (BASE and my probe draft).
- Did not audit `rendered-text-v1`, `source-fetches.tsv` or `parse_captures` beyond the observe harness; my quote stub caused unrelated `RECEIPT-MISMATCH` noise in observe runs (ignored; focus rows cited).
- Did not verify SOURCES.md at BASE beyond the `git archive` tree.
- No tool installs or upgrades.
