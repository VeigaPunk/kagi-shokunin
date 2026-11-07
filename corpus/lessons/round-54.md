# Round 54 — the op-ref entry's `recheck: on-release of op` is watched by a live release clock (S072 → S112), and the op release that clock observes (2.42.0) is measured (C1, freshness)

source: S112 (https://releases.1password.com/developers/cli/index.xml, newest stable item `<title>1Password CLI 2.42.0</title>`, opened 2026-11-07)

Frozen plan: `plans/round-54.md` (predeclaration `27aa53fd40b0b385b3cf2ffeea49977f9e0ff690`; BASE `1a0f43a9220bb0e995462c2aef745ac0124c3317`; no amendment). Counter `plans/round-54-c1.sh`; pre-freeze controls `plans/round-54-controls.sh` (16 controls, all MATCH in both runs: `.ufo/waves/round-54/controls/controls-prefreeze-run1.txt`, and run 2 after the S112 anchor cell was re-derived from the capture, `controls-prefreeze.txt`). BASE reading `.ufo/waves/round-54/controls/c1-base.txt` (`value=0`). One attempt (`.ufo/watchdog.log`: one launch line for round 54).

## Claims

- **C1 freshness — the op-ref entry's on-release recheck is watched, and the release it observes is measured, 0 → 2.** `corpus/knowledge/op-ref-consumption.md:371,397` declared `recheck: on-release of op` with no clock: S072 (the release-notes row recording the 2.41.1 identity) sat on `180d`, the lane held no op feed row, and the release-clock parser refused the vendor feed's `1Password CLI X.Y.Z` titles (round-53 Gate rejection; round-53 routed item 4; closure D4). Change: `FEED_TITLE_PREFIXES` in `corpus/release-clock.py` declares the prefix `1Password CLI` for exactly the S112 feed URL (a title counts only when it is exactly `<prefix> [v]X.Y.Z`; undeclared feeds keep the one-word rule; five selftest cases, 116 → 121); new registry row S112 with fetch and quote-body rows; S072 `180d` → `on-release`; clock row `S072 feed S112 … 2.41.1 2.42.0 2026-11-07 fired`; all 32 clocks observed live into the new default receipt `.ufo/waves/round-54/final/observe-r54.json` (0 failures; fired 13 → 14, the new one S072); op 2.42.0 (official archive, signature checked against key `3FEF9748469ADBE15DA7CA80AC2D62742012EA22`, run from round scratch through `OP_REF_OP_BIN`, nothing installed) measured by the unchanged `corpus/op-ref-probe.sh --dotenv-bytes`: six PASS, `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0 (`.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt`); entry §11.2 added.
  - Frozen predicate (verbatim, plan §C1 and counter header): `C1_OP_CLOCK: value = WATCHED + MEASURED when GUARD = 1, else 0; target 2 (BASE 0).`

## Gate

- **S112 — new, opened 2026-11-07** (capture `.ufo/waves/round-54/capture/S112.body`, fetched by the L1 with the declared request profile `curl-fsSL-compressed-v1`): `https://releases.1password.com/developers/cli/index.xml`, HTTP 200, `text/xml`, decoded body sha256 `2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2`, 45175 B (byte-identical to the body R53ScoutFeeds recorded on the same day). Located quote (byte search, `raw-literal-v1`, count 1, offset 37215): "<title>1Password CLI 2.42.0</title>" (3 words: `printf '%s' '<title>1Password CLI 2.42.0</title>' | wc -w` prints 3). The item's `<pubDate>` is `Wed, 04 Nov 2026 00:00:00 +0000` and its link `https://releases.1password.com/developers/cli/2.42.0/`, read from the capture bytes (round-53 closure D1: the anchor cell is re-derived from the capture; the first draft wrote `pubDate Wed 04 Nov 2026`, corrected before the freeze, controls run 2). The feed has 27 release items, every title `1Password CLI X.Y.Z`; the gate's own parser reads `2.42.0` under the declared prefix and refuses the body without it (`feed has no stable X.Y.Z release entry`). Admitted: the primary vendor feed for the op identity S072 records.
- **Rejected — `https://app-updates.agilebits.com/product_history/CLI2` as the clock's feed** (the S072 page itself; L1, 2026-11-07T06:01:52Z: HTTP 200, `text/html;charset=utf-8`, 528203 B decoded, sha256 `bb179199193f3dfd7cd773dd35a0dab1e5c0edbe671c3be7ceb3cda901c0e7a5`; receipt `.ufo/waves/round-54/capture/rejections/app-updates_agilebits_com_product_history_CLI2.{meta,body}`): an HTML page with a DOCTYPE, which the gate's feed parser refuses by rule (`XML DTD and entity declarations are not allowed`); a rendered-quote clock on it would only watch whether the 2.41.1 heading stays present, which it does after 2.42.0 shipped. Flip: none needed while S112 exists (the page stays S072's identity source, not its clock).
- **Rejected — `https://releases.1password.com/developers/cli/`** (the HTML index of the same releases site; L1, 2026-11-07T06:01:53Z: HTTP 200, `text/html`, 96166 B decoded, sha256 `0cfbd2083159445b8d2d116e396a92b73fc1e69fbb9eb803ee9e9dc0d1e49acf`; receipt `.ufo/waves/round-54/capture/rejections/releases_1password_com_developers_cli_.{meta,body}`): HTML, refused by the same parser rule; the RSS feed S112 is the machine-readable form of this index. Flip: the RSS feed disappears.
- **Rows touched (old → new):** S072 recheck `180d` → `on-release` (the entry's on-release statement needs a clock on the row it cites; S072's teaching — the 2.41.1 identity — stays true after the fire). Status and used-by unchanged.
- **Discernment sample (LEARNING.md):** admit — S112 (quote located count 1; the gate parses the clock's release from the body). Reject — the CLI2 release-notes page as a feed (HTML, refused by the parser; it remains S072's identity source).
- **Counting rule (E49-1):** every word count in this `## Gate` is `printf '%s' "<quote>" | wc -w`, run on each quote before writing it.
- **Rows added:** 1 (S112; tier A 1). **Rows touched:** 1 (S072 recheck). Registry 111 → 112.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M54-1 | `unbound-on-release` (a knowledge line declares `recheck: on-release of <tool>` while no registry row it cites is on-release with a clock, so the statement reads as watched and nothing watches it) | `corpus/knowledge/op-ref-consumption.md:371` (round 21) and `:397` (round 32) at BASE `1a0f43a9`; S072 `180d`; no op clock row (`grep -c '^S072' corpus/release-clocks.tsv` ⇒ 0); the vendor feed listed 2.42.0 since 2026-11-04 | none — QM69 binds registry rows whose teaching states currency, not prose rechecks in entries; the release-clock gate only sees registry `on-release` cells | C1 binds the declaration to a clock; QM70 makes it a landing rule. **Shown able to fail:** `controls/c1-base.txt` reads `value=0`; K1-F1 (S072 flipped to on-release with no clock) reads 0. |
| M54-2 | `anchor-paraphrase` (an anchor cell restated a feed field in its own words — `pubDate Wed 04 Nov 2026` — instead of the captured bytes `Wed, 04 Nov 2026 00:00:00 +0000`) | first reference overlay, `.ufo/waves/round-54/controls/controls-prefreeze-run1.txt` was run on it; corrected before the freeze (run 2) | round-53 closure D1 (re-derive anchor timestamps from the capture) applied as a pre-freeze read | anchor cell now quotes the capture field; no counter reads the cell, so the correction is recorded here, not scored |

## Closure defects of round 53 (spot-check `corpus/lessons/round-53-verifier-spotcheck.md:95-99`)

- D1 → the S112 anchor cell's date was re-derived from the capture before the freeze (M54-2).
- D2 → both rejections this round keep a status/type/size/sha256 receipt and the body (`.ufo/waves/round-54/capture/rejections/`).
- D3 → the C1 counter adopts the routed hardenings: pinned receipt path and basename, symlink refusal on every read path (K1-F12), revision-bound frozen reading, fence-aware registry read, receipt-to-body digest link (K1-F14).
- D4 → this round's claim.
- D5 → stays routed (`self-counts.py` summary precedence; a mechanism change with its own selftest and ledger migration, not taken this round).

## Routed (named, not claimed this round)

1. Round-53 routed items 1–3, 5 and 6 stand (round-51/52 trial defects; self-counts summary precedence; C1/C2 counter hardening for the C2 class; QM69's mechanical antecedent).
2. Ledger `R21-01` runs the installed `op` (2.41.1); it moves to 2.42.0 only when the host package moves (pacman is paused). §11.2 measured a verified vendor binary from scratch.
3. Operator-routed R25-02 FAIL and R29-01/R29-02/R38-03 POLICY untouched; R38-03's `rows=5` expectation reads 11 rows on this landing (10 at BASE) — operator-routed, not migrated.

## Frontier

Census at round start (`.ufo/waves/round-54/controls/census-start.txt`): `kagi ok`, rc 0, 19 W04 warnings. Frontier move: the lane's release-clock gate reads a vendor RSS feed whose titles carry a multi-word product name, under a per-feed declared prefix, and the op CLI joins SOPS, age, Vault, OpenBao, CPython and curl under live clocks (on-release rows 31 → 32); the op-ref byte contract is measured on the newest op release (2.40.0, 2.41.0, 2.41.1 → + 2.42.0).

## Assimilation

None: `grep -rilE 'releases\.1password|product_history/CLI2|op-ref|dotenv' /home/vgpnk/Projects/shokuknow/merge/kagi | wc -l` prints `0` (L1, 2026-11-07, over the staged package of campaign corpus-expansion-1 as it stood that day). The wider pattern `'1password|op cli|releases\.1password|op-ref|dotenv'` hits 4 files (`MERGE-REPORT.json`, `MERGE-REPORT.md`, `SOURCES.append.md`, `knowledge/corpus/knowledge/cdp-bridge-1password-oidc-workflow.md`); none stages an op CLI release feed or an op-ref/dotenv theme (the staged release rows found by `grep -niE 'release' SOURCES.append.md` are betterleaks, TruffleHog and Claude Code sources).

## considerthese

Newest file `considerthese/2026-10-26.md`; none taken (its proposals — repair-only release path, machine-readable lane status, the backlog table, carried-over items — touch neither a release clock nor the op-ref entry).
