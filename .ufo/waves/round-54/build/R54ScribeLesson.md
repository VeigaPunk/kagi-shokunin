# R54ScribeLesson — prose review of the round-54 landing text against its evidence

Seat: `R54ScribeLesson` (leaf). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE `1a0f43a9220bb0e995462c2aef745ac0124c3317`; predeclaration `27aa53fd40b0b385b3cf2ffeea49977f9e0ff690`; candidate `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14`.
Scratch `/fast/scratch/hyaku/kagi-r54/R54ScribeLesson`. No lane file written except this report; all reads/commands were read-only.

Reviewed: `corpus/lessons/round-54.md`; `LOG.md` §Round 54 (`:1906-1912`); `SCORECARD.md` §Round 54 — post-move (`:1815-1826`); `corpus/QUALITY.md:252-253` (QM69/QM70); `corpus/knowledge/op-ref-consumption.md` §11.2 (`:399-411`); `SKILL.md:48,787`; `PROVINCE.md:75`; plus every receipt/file those sentences cite.

## Verdict

The landing text is substantially accurate. The frozen predicate reproduces at BASE 0 and candidate 2; the capture digest/size/offset/quote/title counts match; the registry and clock counts (111→112, on-release 31→32, clocks 31→32, fired 13→14, 31 re-observation notes) match; the selftest is 116 at BASE and 121 at candidate; the op receipt is the one the text cites; the skips/routing statements match the receipts. I found **1 rule-level conflict (H), 7 low-severity defects (L), and 3 information-level evidence-scope gaps (I)**. No sentence claims op is installed at 2.42.0, that R21-01 measures 2.42.0, or that the parser accepts arbitrary multi-word titles.

## Defects

Severity: **H** = a rule the landing now contradicts; **L** = stated fact/number/pointer is wrong or under-specified; **I** = claim is true only at the lane's declared ceiling, or a receipt cannot show it.

| id | sev | file:line | stated (short) | observed (short) | proposed wording (short) |
|---|---|---|---|---|---|
| D1 | H | `corpus/QUALITY.md:252`/`:253`; `corpus/SOURCES.md:79`; `corpus/lessons/round-54.md:26` | QM69: identity-only rows keep a cadence | S072 is identity-only and moved to `on-release`; QM70 requires it; QM69 unamended | Add QM70 carve-out to QM69 or record the exception |
| D2 | L | `corpus/lessons/round-54.md:41` | R38-03 reads 11 rows (10 at BASE) | `quote-locate` rows=10 (9 at BASE); 11/10 lines incl. header | `rows=10` (`rows=9` at BASE) |
| D3 | L | `LOG.md:1908` | eleven forgery/fail-closed controls | 16 controls; 14 are K1-F fail-closed | "fourteen (K1-F1–K1-F14)" or name the 11 |
| D4 | L | `corpus/QUALITY.md:253` | c1-base shows op 2.42.0 live | c1-base has no `2.42.0`; capture/fetch row does | Split the citation |
| D5 | L | `corpus/QUALITY.md:253` | `plans/round-54-c1.sh` K1-0 | K1-0 is in `plans/round-54-controls.sh` | Cite the controls script |
| D6 | L | `corpus/lessons/round-54.md:26` | feed listed 2.42.0 since 2026-11-04 | item `pubDate` 2026-11-04; capture 2026-11-07; page says released 2026-11-03 | "newest item, pubDate 2026-11-04" |
| D7 | I | `corpus/lessons/round-54.md:27` | first overlay had paraphrased anchor; run 1 on it | run-1 receipt has no header; old text not committed; run-2 header asserts correction | Cite run-2 header; retain/declare the old text |
| D8 | I | `corpus/lessons/round-54.md:9`; `LOG.md:1910`; `SCORECARD.md:1821`; `corpus/knowledge/op-ref-consumption.md:403` | signature checked/verified | receipt has only `gpg_validsig=` and sha256s | "receipt records the key fingerprint" or attach gpg output |
| D9 | L | `.ufo/waves/round-54/capture/rejections/*.meta:1`; `corpus/lessons/round-54.md:32` | status/type/size/sha256 + body | `bytes=` 74323/20250 vs body 528203/96166 | Label `bytes_compressed=` or record decoded size |
| D10 | I | `corpus/lessons/round-54.md:14` | HTTP 200, `text/xml` | fetch row has 200, no content-type; capture has no headers | Record header or say "RSS XML body" |
| D11 | L | `corpus/lessons/round-54.md:39` | Round-53 items 1–3, 5, 6 stand | item 3 is taken by C1 (prefix + clock) | "items 1–2, 5, 6; item 3 taken for the op feed" |

### D1 — H — rule conflict: QM69's identity-row cadence sentence vs QM70 and the S072 move

- File:line: `corpus/QUALITY.md:252` (QM69) and `:253` (QM70); `corpus/SOURCES.md:79` (S072); `corpus/lessons/round-54.md:26` (M54-1 rationale).
- Stated (QM69, verbatim): "A row that only records a release identity ("the 2.41.1 release") keeps a cadence."
- Stated (QM70, verbatim): "A knowledge line that declares `recheck: on-release of <tool>` cites a registry row that is `on-release` with a bound release clock (feed or rendered-quote) in the same commit; a prose on-release with no clock reads as watched while nothing watches it. When the clock fires, the line's measurement is re-run on the observed release (or the line is scoped down) in the landing that records the fire."
- Observed: S072's teaching cell is `op CLI 2.41.1 release identity (the version token `op --version` prints; the article's build number `#2410101` is not printed by the binary)` — an identity-only row, and QM69's own example names "the 2.41.1 release". The landing moves S072 to `on-release` (`corpus/SOURCES.md:79`), and `corpus/QUALITY.md` adds QM70 as a single `+` line with no amendment to QM69 (QUALITY diff has no `-`/`+` on the QM69 line). M54-1's "captured-by" cell argues only that QM69's *first* sentence ("whose teaching states currency") does not bind S072; it does not address the second sentence.
- Consequence: applying QM69 literally reverts S072 to a cadence and breaks QM70 / the frozen counter's WATCHED clause (a), which requires `recheck on-release` on S072; the quality manual now contains two rules that prescribe opposite cells for the same row.
- Proposed wording (amend QM69's second sentence): "A row that only records a release identity ("the 2.41.1 release") keeps a cadence **unless a knowledge line's `recheck: on-release` cites it (QM70)**." Add the same carve-out to M54-1's fix cell and to the QUALITY row's provenance, e.g. "QM70 narrows QM69's identity-row sentence: a cited identity row joins its line's clock."

### D2 — L — R38-03 row count is off by one

- File:line: `corpus/lessons/round-54.md:41`.
- Stated: "R38-03's `rows=5` expectation reads 11 rows on this landing (10 at BASE)".
- Observed: `python3 -I -B corpus/quote-locate.py` prints `QUOTE_LOCATE: CLEAN located=10 rows=10` (rc 0). At BASE the same tool prints `rows=9` (run from the BASE archive; the 9 data rows are also countable in `git show 1a0f43a:corpus/quote-bodies.tsv`). The file has 11 lines / **10 data rows** at candidate and 10 lines / 9 data rows at BASE; the R38-01 migration in `.ufo/waves/round-54/expectation-migrations.json` records `^9$` → `^10$` for the same population. The `rows=` field counts data rows, not the header line.
- Proposed wording: "R38-03's `rows=5` expectation would read `rows=10` on this landing (`rows=9` at BASE) — `corpus/quote-bodies.tsv` has 11/10 lines including the header, and `quote-locate.py` prints `rows=` over data rows. Operator-routed, not migrated."

### D3 — L — "eleven forgery/fail-closed controls" is not the receipt's count

- File:line: `LOG.md:1908`.
- Stated: "16 MATCH in both runs incl. eleven forgery/fail-closed controls".
- Observed: `plans/round-54-controls.sh` declares `K1-0`, `K1-P`, and `K1-F1`–`K1-F14` = 16 controls; **14** are `K1-F` fail-closed controls. Both receipts (`controls-prefreeze-run1.txt`, `controls-prefreeze.txt`) print `CONTROLS: match=16 mismatch=0`. No subset of 11 is named in the plan or either receipt.
- Proposed wording: "16 MATCH in both runs incl. fourteen fail-closed controls (`K1-F1`–`K1-F14`)" — or, if a specific 11 is intended, name the ids.

### D4 — L — QM70's evidence pointer cannot support "op 2.42.0 was live"

- File:line: `corpus/QUALITY.md:253`.
- Stated: "... with S072 on `180d` and no op clock while op 2.42.0 was live (`.ufo/waves/round-54/controls/c1-base.txt`)".
- Observed: `c1-base.txt` contains **zero** occurrences of `2.42.0`; its line is `C1_OP_CLOCK: value=0 watched=0 measured=0 guard=1 (bad=watched:s072-recheck=180d ... gate-line=RELEASE_CLOCK: CLEAN (on_release=31 ... fired=13 ...))`. The 2.42.0 liveness is evidenced by the S112 capture (`<item><title>1Password CLI 2.42.0</title>...`, `pubDate Wed, 04 Nov 2026`) and `corpus/source-fetches.tsv:155`, not by c1-base.
- Proposed wording: "... with S072 on `180d` and no op clock (`.ufo/waves/round-54/controls/c1-base.txt`), while the S112 capture's newest item is 2.42.0 (`.ufo/waves/round-54/capture/S112.body`; `corpus/source-fetches.tsv:155`)."

### D5 — L — QM70 attributes K1-0 to the counter, not the controls script

- File:line: `corpus/QUALITY.md:253`.
- Stated: "check able to fail: `plans/round-54-c1.sh` K1-0 reads 0, K1-F1 (S072 flipped to on-release with no clock) reads 0".
- Observed: `K1-0` is defined only in `plans/round-54-controls.sh:69-70` (`d=$(mk k0); check K1-0 0 "$(C1 "$d")"`); `plans/round-54-c1.sh` has no `K1-0` string. The result is real: `controls-prefreeze.txt` prints `CONTROL K1-0 expect=0 got=0 MATCH`; the counter on BASE (`c1-base.txt`) also reads `value=0`.
- Proposed wording: "check able to fail: `bash plans/round-54-c1.sh 1a0f43a9…` reads 0 (`.ufo/waves/round-54/controls/c1-base.txt`); `plans/round-54-controls.sh` K1-0 and K1-F1 read 0 (`.ufo/waves/round-54/controls/controls-prefreeze.txt`)."

### D6 — L — "listed 2.42.0 since 2026-11-04" is a pubDate inference, not a listing history

- File:line: `corpus/lessons/round-54.md:26` (M54-1 evidence cell); the same date-only claim appears in `LOG.md:1909` ("lists 2.42.0 (2026-11-04)") and `plans/round-54.md` (not reviewed as landing text).
- Stated: "the vendor feed listed 2.42.0 since 2026-11-04".
- Observed: the capture item reads `<pubDate>Wed, 04 Nov 2026 00:00:00 +0000</pubDate>`; the capture was fetched 2026-11-07; the CLI2 release-notes page says `2.42.0 ... – released 2026-11-03`. A `pubDate` is the item's declared publication date, not a receipt that the item was continuously present from 2026-11-04.
- Proposed wording: "the vendor feed's newest item is 2.42.0, `pubDate Wed, 04 Nov 2026 00:00:00 +0000` (capture fetched 2026-11-07)".

### D7 — I — M54-2's pre-correction cell text is not retained by any committed artifact

- File:line: `corpus/lessons/round-54.md:27`.
- Stated: "first reference overlay, `.ufo/waves/round-54/controls/controls-prefreeze-run1.txt` was run on it; corrected before the freeze (run 2)"; the class names the old cell `pubDate Wed 04 Nov 2026`.
- Observed: `controls-prefreeze-run1.txt` has **no header/timestamp** and its 16 control results are value-identical to run 2; the corrected S112 anchor is what is committed in the predeclaration overlay and the candidate tree; the only committed statement that the cell was corrected is the run-2 header line `controls-prefreeze.txt:1` ("run 2, after the S112 anchor cell was re-derived from the capture (pubDate wording)"). The pre-correction overlay text is not in git (the fixture was committed after the correction) and the paraphrased string `Wed 04 Nov 2026` occurs nowhere in the round-54 receipts.
- Proposed wording: "the pre-correction cell text is not retained; the run-1 receipt (16 MATCH, no header) and the run-2 header (`.ufo/waves/round-54/controls/controls-prefreeze.txt:1`) are the evidence that the S112 anchor cell was re-derived from the capture before the freeze" — or retain a copy of the first overlay for the record.

### D8 — I — "signature checked/verified" is not re-runnable from the cited receipt

- File:line: `corpus/lessons/round-54.md:9`; `LOG.md:1910`; `SCORECARD.md:1821`; `corpus/knowledge/op-ref-consumption.md:403`.
- Stated: "op 2.42.0 (official archive, signature checked against key `3FEF9748469ADBE15DA7CA80AC2D62742012EA22` …)" (lesson); "signature verified (key …)" (LOG); "(signature-verified vendor binary, run from scratch)" (SCORECARD); "its detached signature verified against the 1Password code-signing key …" (entry §11.2).
- Observed: `corpus/op-dotenv-bytes-2.42.0.txt` records only `gpg_validsig=3FEF9748469ADBE15DA7CA80AC2D62742012EA22` plus `zip_sha256`, `op_sha256`, `op_version=2.42.0`; it carries no `.sig` URL, no gpg invocation and no gpg output. The frozen counter's MEASURED only validates that line, and the plan's named ceiling says "a hand-written op receipt scores MEASURED". This is not a false claim from the lane's instrument, but it is unverifiable from the committed receipt alone.
- Proposed wording (or attach evidence): "the receipt records the signing-key fingerprint `gpg_validsig=3FEF…` (and the archive/binary sha256); no `.sig` URL or gpg output is retained" — or add the detached-signature URL and the `gpg --verify` status line to the receipt.

### D9 — L — rejection `.meta` `bytes=` is not the size of the retained body

- File:line: `.ufo/waves/round-54/capture/rejections/app-updates_agilebits_com_product_history_CLI2.meta:1`; `.ufo/waves/round-54/capture/rejections/releases_1password_com_developers_cli_.meta:1`; the consequence is in `corpus/lessons/round-54.md:32` (D2 closure) and `:15-16`.
- Stated: D2 closure "both rejections this round keep a status/type/size/sha256 receipt and the body"; the Gate bullets give `528203 B decoded` and `96166 B decoded`.
- Observed: `CLI2.meta` says `bytes=74323`, body is `528203` B; `releases…meta` says `bytes=20250`, body is `96166` B. `sha256=` in each meta matches its body (verified with `sha256sum`), so only `bytes=` disagrees with the retained body; under the declared `curl-fsSL-compressed-v1` profile it is consistent with the compressed transfer length, but the field is unlabelled.
- Proposed wording: label the field `bytes_compressed=` (or record the decoded size too); then the D2 sentence can say "status/type/sha256 receipt and the retained decoded body".

### D10 — I — `text/xml` is not recorded by the landing's capture or fetch row

- File:line: `corpus/lessons/round-54.md:14`.
- Stated: "`https://releases.1password.com/developers/cli/index.xml`, HTTP 200, `text/xml`, decoded body sha256 …".
- Observed: `corpus/source-fetches.tsv:155` records `http_status=200` but has no content-type column; `.ufo/waves/round-54/capture/S112.body` is a headerless body whose first bytes are `<?xml version="1.0" encoding="utf-8" standalone="yes"?><rss …`. No S112 `.meta` was kept (unlike the two rejections). A peer build receipt (`.ufo/waves/round-54/build/R54ScoutFeed-receipts.txt:8`) records `content-type: text/xml`, but it is not the landing receipt.
- Proposed wording: "HTTP 200 (`corpus/source-fetches.tsv:155`); the captured body is an RSS XML document (starts `<?xml version="1.0" …`)" — or record the response headers in a S112 `.meta` and cite it.

### D11 — L — routed item 3 is taken, not "standing"

- File:line: `corpus/lessons/round-54.md:39`.
- Stated: "Round-53 routed items 1–3, 5 and 6 stand (round-51/52 trial defects; self-counts summary precedence; C1/C2 counter hardening for the C2 class; QM69's mechanical antecedent)."
- Observed: round-53 routed item 3 is "The op CLI release feed (Gate rejection): parser support for multi-word product titles, only together with a currency statement to watch" (`corpus/lessons/round-53.md:59`). C1 supplies exactly that for the op feed: `FEED_TITLE_PREFIXES` declares `1Password CLI` for the S112 URL and S072 is moved to an `on-release` clock, which is the "currency statement to watch". The parenthetical lists only items 1, 2, 5 and 6 topics; item 3 is absent. (General multi-word support for other feeds remains unclaimed, but that is a different, still-open edge than item 3 as written.)
- Proposed wording: "Round-53 routed items 1–2, 5 and 6 stand; item 3 is taken for the op feed by C1 (a per-feed declared prefix with a clock); general multi-word title support for other feeds remains unclaimed."

## Conflict quoted verbatim for the judge

`corpus/QUALITY.md:252` — QM69: "A registry row whose teaching states that a version is the project's current release is `on-release` with a bound feed clock in the same commit (QM63); a fixed `NNd` cadence on a currency statement lets it go false with every gate green. A row that only records a release identity ("the 2.41.1 release") keeps a cadence."

`corpus/QUALITY.md:253` — QM70: "A knowledge line that declares `recheck: on-release of <tool>` cites a registry row that is `on-release` with a bound release clock (feed or rendered-quote) in the same commit; a prose on-release with no clock reads as watched while nothing watches it. When the clock fires, the line's measurement is re-run on the observed release (or the line is scoped down) in the landing that records the fire."

`corpus/SOURCES.md:79` — S072 teaching: "op CLI 2.41.1 release identity (the version token `op --version` prints; the article's build number `#2410101` is not printed by the binary)"; recheck cell: `on-release`.

## Checks performed (exact commands and last lines)

Scratch root `S=/fast/scratch/hyaku/kagi-r54/R54ScribeLesson`; `mkdir -p "$S/root"`.

1. Frozen counter, BASE: `HYAKU_SCRATCH="$S/root" TMPDIR="$S/root" bash plans/round-54-c1.sh 1a0f43a9220bb0e995462c2aef745ac0124c3317` → `C1_OP_CLOCK: value=0 watched=0 measured=0 guard=1 (bad=watched:s072-recheck=180d measured:oprcpt-missing-or-symlink; gate-line=RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17))`, rc 0.
2. Frozen counter, candidate: same with `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14` → `C1_OP_CLOCK: value=2 watched=1 measured=1 guard=1 (bad=watched:OK measured:OK; gate-line=RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17))`, rc 0.
3. `python3 corpus/release-clock.py --selftest` → `RELEASE_CLOCK_SELFTEST: PASS (121 cases)` rc 0. BASE archive (`git archive 27aa53f corpus` in scratch) → `RELEASE_CLOCK_SELFTEST: PASS (116 cases)` rc 0.
4. `python3 corpus/release-clock.py` → `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)` rc 0.
5. `python3 -I -B corpus/quote-locate.py` → `QUOTE_LOCATE: CLEAN located=10 rows=10` rc 0. BASE archive → `QUOTE_LOCATE: FAIL located=0 rows=9` rc 1 (bodies absent in the archive), data-row count 9.
6. Capture: `sha256sum .ufo/waves/round-54/capture/S112.body` → `2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2`; size 45175 B; Python byte search `count=1`, `offset=37215`; 27 `<item>` elements, all 27 item titles match `^1Password CLI [0-9]+\.[0-9]+\.[0-9]+$`; newest `<pubDate>Wed, 04 Nov 2026 00:00:00 +0000</pubDate>`, link `https://releases.1password.com/developers/cli/2.42.0/`.
7. Parser: BASE module on the capture with no prefix → `ValueError: feed has no stable X.Y.Z release entry`; HEAD module with the declared prefix → `2.42.0`; HEAD with no prefix → same ValueError.
8. Rejections: bodies `528203 B` (`bb179199…`) and `96166 B` (`0cfbd208…`); metas record `http=200`, `type=text/html;charset=utf-8` / `type=text/html`, `parse(prefix=None) refused: XML DTD and entity declarations are not allowed`, and `count("2.42.0")=68` / `5`; CLI2 body starts `<!DOCTYPE html>` and contains the rendered 2.41.1 heading `2.41.1 (build <a …>#2410101</a>) – released 2026-10-21`.
9. Registry/clock: `corpus/SOURCES.md` rows 111 at BASE → 112 at HEAD (`grep -cE '^\| S[0-9]{3}'`); rows with `| on-release |` 31 → 32; `corpus/release-clocks.tsv` 31 → 32 rows, one added row (`S072 feed S112 … 2.41.1 2.42.0 2026-11-07 fired`), columns 1–8 byte-identical for the 31 old rows, 31 notes changed, 32 rows cite `observe-r54.json`.
10. Receipt `observe-r54.json`: 32 observations, ids equal the table's 32 ids, all HTTP 200, all `observed_at` 2026-11-07, verdicts `{fired: 14, quote-located: 11, not-fired: 7}`, S072 record `200 / feed URL / 2.42.0 / fired / sha256 = capture / observed_at 2026-11-07T05:54:19Z`; `sha256sum` = `9513690e…` = `DEFAULT_RECEIPT_SHA256`.
11. Instrument integrity: `git diff --stat 27aa53f ede4373 -- plans/round-54.md plans/round-54-c1.sh plans/round-54-controls.sh .ufo/waves/round-54/controls .ufo/waves/round-54/capture/S112.body` is empty; the 8 reference-overlay files (`SOURCES.md`, `source-fetches.tsv`, `quote-bodies.tsv`, `release-clocks.tsv`, `release-clock.py`, entry, receipt, op receipt) are `diff -q` identical to the candidate tree.
12. Journal/migrations: `.ufo/waves/round-54/expectation-migrations.json` has exactly 10 rows `R13-01 R21-02 R24-06 R25-03 R31-02 R33-02 R34-03 R36-02 R36-03 R38-01`; `R25-03` old/new 116/121, `R36-03` old/new 31/13 → 32/14, `R38-01` old/new ^9$/^10$.
13. Stamps: `corpus/stamps.tsv` 125 nonblank lines at BASE and HEAD; 12 stamped paths changed (SKILL, PROVINCE, LOG, SCORECARD, QUALITY, claim-ledger, SOURCES, source-fetches, quote-bodies, release-clocks, release-clock.py, op-ref-consumption.md); `claims-declared.tsv` adds exactly `54 C1 freshness`.
14. Census: `census-start.txt` has `kagi ok` and rc 0; `grep -c W04` = 19.
15. Watchdog: `grep -c 'launch kagi round=54' /home/vgpnk/Projects/shokunin/.ufo/watchdog.log` = 1.
16. Installed op: `op --version` → `2.41.1`; receipt `installed_op=/usr/bin/op 2.41.1`.
17. Assimilation: `grep -rilE 'releases\.1password|product_history/CLI2|op-ref|dotenv' /home/vgpnk/Projects/shokuknow/merge/kagi | wc -l` = 0; wider pattern = 4 (`knowledge/corpus/knowledge/cdp-bridge-1password-oidc-workflow.md`, `SOURCES.append.md`, `MERGE-REPORT.md`, `MERGE-REPORT.json`); `SOURCES.append.md` release rows are S152 betterleaks, S178 TruffleHog, S137 Claude Code.
18. Ledger verify receipts (read only): `verify-base.txt` and `verify-candidate-tree.txt` both end `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)` rc 2, with the same `FAIL R11-08`, `FAIL R25-02`, `FAIL R36-01`, `POLICY R29-01`, `POLICY R29-02`, `POLICY R38-03`; the FAIL/POLICY id set is identical at BASE and candidate.
19. `git log --oneline` shows exactly two commits over BASE: predeclaration `27aa53f` and candidate `ede4373`; no amendment commit.

## No-defect checks (the assignment's named overclaim examples)

- **"op is installed" at 2.42.0 — not claimed.** `op --version` is `2.41.1`; the receipt says `installed_op=/usr/bin/op 2.41.1`; lesson §Routed 2 and entry §11.2 say the installed CLI stays 2.41.1 and the 2.42.0 binary came from round scratch via `OP_REF_OP_BIN` ("nothing installed").
- **"R21-01 measures 2.42.0" — not claimed.** The ledger row runs `bash corpus/op-ref-probe.sh --dotenv-bytes` on the installed op; the lesson says it measures 2.41.1 until the host package moves; §11.2 repeats that.
- **"the parser accepts arbitrary multi-word titles" — not claimed.** The code `FEED_TITLE_PREFIXES` maps exactly the S112 URL to `1Password CLI`; `prefixed_title_re` is `^<prefix> v?X.Y.Z$`; undeclared feeds keep `STABLE_TITLE_RE` (`^(?:[A-Za-z]+ )?v?X.Y.Z…`); the selftest includes "undeclared feed keeps the one-word rule", "declared prefix is anchored and space-delimited", and "declared prefix does not widen a python feed".
- The frozen predicate string is byte-identical in `plans/round-54.md`, the `plans/round-54-c1.sh` header, and `corpus/lessons/round-54.md:10`.
- The 16 pre-freeze controls are 16 MATCH in both receipts; the K1-0/K1-P/K1-F1–K1-F14 ids are present in both.
- The S112 capture digest/size/quote/offset/items and the S072 feed row/URL/anchor/observed/verdict match the prose.
- The 32 observations, 0 failures, fired 13 → 14, and the new S072 record match the prose and the gate line.
- The selftest 116 → 121 and the five new prefix cases match; the counts are bound in `corpus/self-counts.tsv` (`SC-CLOCK-SELFTEST`, `PV-CLOCK-SELFTEST`) and the candidate `self-counts` receipt reads `121` for both.
- Registry 111 → 112 (S112: docs, tier A, mined, `90d`), rows touched 1 (S072 recheck only; status `mined`, opened `2026-11-03`, used-by `corpus/lessons/round-32.md` unchanged), on-release rows 31 → 32, clocks 31 → 32, 31 notes changed, fired 13 → 14.
- The journal's 10 ids and old/new expectations match the assignment; R38-01's 9 → 10 is the quote-body row population.
- `SKILL.md:48`, `SKILL.md:787`, `PROVINCE.md:75` are the lines the SCORECARD names, and their statements about the round-54 default receipt, 32 clocks, `121` cases, and the historical receipts are true.
- `corpus/QUALITY.md:253` QM70's rule sentence and `corpus/QUALITY.md:252` QM69's first sentence are consistent with the change; the second QM69 sentence is D1.
- `corpus/knowledge/op-ref-consumption.md` §11.2's claims about the receipt, the six PASS, `CLEAN`, `exit=0`, the installed 2.41.1 and the falsifier match the receipt; the signature sentence is D8.
- The round-53 references (`Gate` rejection of the feed, routed item 4, closure D4) exist at `corpus/lessons/round-53.md:17,59` and `corpus/lessons/round-53-verifier-spotcheck.md:98`.
- The D1–D5 closure claims: D1 correction backed by the run-2 header (D7 notes the pre-correction text is not retained); D2 receipts/body exist (D9 notes the `bytes=` label); D3 counter hardenings are present (`plain_file`/symlink checks, fence-aware read, ASOF-bound reading, pinned receipt/digest; K1-F12/K1-F14 controls); D4 is this claim; D5 stays routed.
- The `considerthese/2026-10-26.md` newest-file claim and the assimilation counts match.
- The `LOG.md`/`SCORECARD.md` statements about the candidate, the receipt, the 31 notes, the manifest row `54 C1`, and the six 9→9 axes match; the 125-stamp and 86-claim counts in `SKILL.md:46`/`PROVINCE.md` match `corpus/stamps.tsv` (125 lines) and the verify receipts (`stamped=125`, `claims=86`).

## Observations (no false claim found)

- **S072 post-fire re-open traceability.** The CLI2 page was re-fetched 2026-11-07T06:01:52Z and the 2.41.1 heading is still present, but `corpus/SOURCES.md:79` (`opened` 2026-11-03) and the S072 clock note (`corpus/release-clocks.tsv:30`) do not record the re-open/re-check; only the lesson and the rejection receipt do. Suggest adding the re-check sentence with the receipt path (compare S012's inline note).
- **`SCORECARD.md:1822` calibration `stale=0`.** This is compliant with QM68, which says to read the per-line findings and `stale=`/`unlocated=`/`ambiguous=` fields, never the verdict word; the plan discloses the `POLICY (claims=63 stale=0 … policy=2 …)` frame. No claim of CLEAN is made.
- **`SCORECARD.md:1821` "Ceiling"** discloses the forged-receipt/hand-written-op-receipt limit; the prose's "observed live" is therefore within the declared ceiling, not a hidden overclaim.
- **`corpus/QUALITY.md:253` QM70 "in the same commit"** is satisfied: the S072 recheck and the S112 clock row land in `ede4373`.

## Not run / limits

- Full `bash corpus/claim-ledger.sh verify` was **not** run (the assignment forbids it unless named; host load). I read the committed [verify-base.txt] and [verify-candidate-tree.txt] receipts only. They are `POLICY (claims=86 policy=3 stamped=125)` rc 2 with three `FAIL` rows (`R11-08` timeout, `R25-02` exit-mismatch, `R36-01` verdict-not-final) and three `POLICY` rows (`R29-01`, `R29-02`, `R38-03`), identical at BASE and candidate; the landing text does not claim a clean ledger verify.
- Full `bash corpus/sources-census.sh` was not run; registry counts were measured with `grep -cE '^\| S[0-9]{3}'` (111/112) and the round-start census receipt (19 W04, `kagi ok` rc 0) was read. The lesson/LOG/SCORECARD do not claim a candidate census CLEAN.
- The op 2.42.0 archive was **not** re-downloaded and the `--dotenv-bytes` probe was **not** re-run on it; the signed archive, `op_sha256`, `gpg_validsig`, six PASS lines and `exit=0` are read from `.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt` only. The signature claim is therefore D8.
- The vendor feed was **not** re-fetched live; the capture/receipt were read and the capture bytes were re-hashed/re-parsed. The `text/xml` header is therefore D10.
- No lane file was edited; no git mutation was run; no op subcommand other than `--version` was run.

## Artifacts

- This report: `.ufo/waves/round-54/build/R54ScribeLesson.md`.
- Read/used receipts: `.ufo/waves/round-54/controls/c1-base.txt`, `controls-prefreeze.txt`, `controls-prefreeze-run1.txt`, `census-start.txt`, `.ufo/waves/round-54/final/observe-r54.json`, `op-dotenv-bytes-2.42.0.txt`, `c1-candidate-tree.txt`, `c1-candidate-rev.txt`, `verify-base.txt`, `verify-candidate-tree.txt`, `self-counts-candidate-tree.txt`, `.ufo/waves/round-54/capture/S112.body`, `.ufo/waves/round-54/capture/rejections/*`, `.ufo/waves/round-54/expectation-migrations.json`.
- Scratch: `/fast/scratch/hyaku/kagi-r54/R54ScribeLesson` (BASE archive at `$S/base2`, counter scratch at `$S/root`).
