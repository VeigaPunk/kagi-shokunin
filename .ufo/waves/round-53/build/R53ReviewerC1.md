# R53ReviewerC1 — round 53 C1 review (freshness: S103/S104 on live release clocks)

Seat: R53ReviewerC1 (leaf reviewer, no dispatch). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
BASE `c1953d4afc19a5a336a58685c00ab5260bcfea1c`; predeclaration `39460f8676954f135d15fa99b43cd882360b3eee`;
candidate `36d0a86a7539890eb079d893c9a58e37e84d953d`. Scratch: `/fast/scratch/hyaku/kagi-r53/R53ReviewerC1/`
(`cand/` = `git archive 36d0a86…`, `base/` = `git archive c1953d4…`; both extracted with
`git -C <lane> archive <rev> | tar -x -C <dir>`). Read-only git only; no lane write outside this report.

## Verdict

C1's frozen value is reproduced independently: **2** at the candidate, **0** at BASE, gate CLEAN and guard 1 in
both runs. All six assigned checks pass. Three low-severity defects found (one evidence timestamp misattributed
in two artifacts; one ledger row whose migrated expectation now sits against its own "target 0" note; one
SKILL.md historical-precision wording). **None changes C1's value or the gate verdict.**

## Assigned checks

### 1. S111 row parses as 11 cells — PASS

`corpus/SOURCES.md:118` is the only S111 row (`grep -cE '^ {0,3}\| S111 \|'` = 1). Split on `|` with the
strip used by the counter and the gate: **11 cells** = id | source | kind `code` | tier `A` | scope
("age release identity (newest stable X.Y.Z tag) for the on-release clock of S104") | anchor
("Entry titled age v1.3.2, tag link /releases/tag/v1.3.2, updated 2026-08-29T17:55:50Z; feed fetched
2026-11-07") | teaches | status `mined` | opened `2026-11-07` | recheck `90d` | used-by
`corpus/lessons/round-53.md`. Gate cells it feeds (`anchor`=cell 5, `recheck`=cell 9) parse correctly.

`bash corpus/sources-census.sh` (candidate tree): `SOURCES_CENSUS: CLEAN (rows=111 A=107 B=2 C=2 queued=1
mined=106 rejected=4 entries_sourced=16 legacy=21 captures=111 inrow=16 inrow_only=0 inrow_nonreproducing=12)`,
exit 0 — the registry row, its URL, its fetch handshake and its used-by citation are structurally accepted.

### 2. Fetch-row identity hash = sha256(`S111<TAB>mined<TAB><url><LF>`) — PASS

Recomputed: `printf 'S111\tmined\thttps://github.com/FiloSottile/age/releases.atom\n' | sha256sum` ⇒
`646ef9b9cbc330f65bd12752026e7a07d8057ee3a5ac937e02b19fb37e3cd221`, byte-identical to column 3 of
`corpus/source-fetches.tsv:154` (16 fields, one S111 row). The rest of the capture chain also holds:

- `corpus/quote-bodies.tsv:10` = `S111  .ufo/waves/round-53/capture/S111.body  725  <title>age v1.3.2</title>`.
- Committed body `.ufo/waves/round-53/capture/S111.body`: 40379 bytes, sha256
  `32517112c2ecb63ce97dfbbdf9c47569678738fda984da524b2cd38129d8f21d` — equals fetch column 10/11 and equals
  receipt S104's `sha256`.
- Quote occurs **once**, at byte offset **725**, byte-exact (`b[725:725+21] == b'<title>age v1.3.2</title>'`).
- `python3 corpus/quote-locate.py`: `QUOTE_LOCATE: CLEAN located=9 rows=9`, exit 0 (body sha, byte count,
  capture quote, registry-row containment and offset all re-checked by the gate, S111 included).

### 3. S103/S104 clock rows satisfy the derived-anchor rule — PASS

Loaded the candidate `corpus/release-clock.py` as a module and called its own `derived_anchor_bound` on the
committed registry cells:

- S103 anchored `3.13.3`, feed anchor cell S033 (`corpus/SOURCES.md:39`): stable-token set = `{3.13.3}`
  ⇒ `derived_anchor_bound` **True**.
- S104 anchored `1.3.2`, feed anchor cell S111 (`corpus/SOURCES.md:118`): stable-token set = `{1.3.2}`
  ⇒ **True** (the cell's `2026-08-29T17:55:50Z` contributes no version token; only `v1.3.2` twice).

Clock rows `corpus/release-clocks.tsv:31-32` are 9-TAB-field rows with `clock=feed`, `feed_url` equal to the
registry URL, `anchored_version` = the pin, `observed_version` = the pin, `observed_at 2026-11-07`,
`verdict not-fired`, `derived:` notes naming S033/S111. The whole table is 31 rows, no duplicate ids, every row
9 fields. End-to-end: `python3 corpus/release-clock.py` ⇒
`RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17)`, exit 0.

### 4. Receipt digest in line 28 = sha256 of observe-r53.json — PASS

`corpus/release-clock.py:28`: `DEFAULT_RECEIPT_SHA256 = "f927b4318dee90ad3e2a8e2f899fcd2e37c43e833e7c3c3705aa5b5723d37c9a"`.
`sha256sum .ufo/waves/round-53/final/observe-r53.json` ⇒ same
`f927b4318dee90ad3e2a8e2f899fcd2e37c43e833e7c3c3705aa5b5723d37c9a`. The receipt has `format
release-clock-observations-v1`, 31 observations, 31 unique ids (S005–S032, S098, S103, S104), every
`http_status` 200, `observed_at` all `2026-11-07T03:02:31Z`–`03:02:40Z` (before the candidate's committer time
`2026-11-07T03:49:25Z`), S103 `{parsed_version 3.13.3, verdict not-fired, url sops feed}` and S104
`{parsed_version 1.3.2, verdict not-fired, url age feed}`, and no `error` keys. Default-receipt wiring was also
exercised through `corpus/release-clock.py:547` (path) and `:2136-2138` (digest chosen only when `--receipt` is
absent).

### 5. Nothing else in the gate changed — PASS

`git diff -U0 BASE CAND -- corpus/release-clock.py` shows exactly three one-line hunks: `@@ -28 +28 @@`
(digest), `@@ -547 +547 @@` (`receipt_path` default round-46→round-53), `@@ -2105 +2105 @@` (`--receipt` help
text). File stays 2151 lines. The C1 counter's GUARD deletes exactly those three lines from both trees and
`cmp`s the rest: `guard=1` in both the candidate and BASE runs, i.e. the rest of the gate is byte-identical.
Regression: `python3 corpus/release-clock.py --selftest` ⇒ `RELEASE_CLOCK_SELFTEST: PASS (116 cases)`, exit 0.
Explicit `--receipt` still requires `--receipt-sha` (`:2116-2122`), so the help text's "citable with
`--receipt/--receipt-sha`" is behaviour, not just prose.

### 6. SKILL.md / PROVINCE.md sentences true at the candidate — PASS (one wording defect, D3)

- `SKILL.md:46` "125 stamps + 86 claims": `corpus/stamps.tsv` = 125 data rows (stamp check below), and
  `corpus/claim-ledger.tsv` = 86 non-comment claim rows (`grep -vc '^#'`), bound by `corpus/self-counts.tsv`
  rows `SC-SKILL-STAMPS` (ledger:R12-03) / `SC-SKILL-CLAIMS` (ledger:R21-04).
- `SKILL.md:48` / `SKILL.md:787`: default receipt `.ufo/waves/round-53/final/observe-r53.json`, "31 clocks
  observed live 2026-11-07" — receipt has 31 records all dated 2026-11-07; round-46/36/26 receipts all still
  present (`.ufo/waves/round-46/final/observe-r46.json`, `.ufo/waves/round-36/controls/observe-live.json`,
  `.ufo/waves/round-26/{frozen,rearmed}/*.json`).
- `PROVINCE.md:73` "125 revision stamps + 86 claim rows": true (same counts).
- `PROVINCE.md:75` default round-53 receipt; "round 53 binds the S103/S104 SOPS and age current-release pins to
  the S033/S111 feeds": true (field-level registry diff of `corpus/SOURCES.md:110-111`: S103/S104 changed cell 9
  only, `90d`→`on-release`).
- `PROVINCE.md:37` "116 cases" for the release-clock selftest: true (run above).
- Adjacent doc rows changed by the same landing are also true: `corpus/README.md:65` "125 rows" (125 stamp
  rows), `:67` "34 row-linked / 3 by-hand / 37 pinned" (`bash corpus/claim-ledger.sh docs` ⇒ `DOC_AUDIT: CLEAN
  (entries=37 row_linked=34 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)`, exit 0).

Wording defect D3 below: the phrase "pins added in round 53" (SKILL.md:48) misstates history.

## Counter readings and kill-rule checks

- `HYAKU_SCRATCH=/fast/scratch/hyaku bash plans/round-53-c1.sh 36d0a86…` ⇒
  `C1_CURRENCY_CLOCKS: value=2 watched=2 gate=1 guard=1 (ok=S103 S104; bad=; gate-line=RELEASE_CLOCK: CLEAN
  (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17))`, exit 0 — byte-identical to
  `.ufo/waves/round-53/final/c1-candidate-tree.txt`.
- Same counter on BASE ⇒ `value=0 watched=0 gate=1 guard=1 (ok=; bad=S103:recheck=90d S104:recheck=90d …)`,
  exit 0 — byte-identical to `.ufo/waves/round-53/controls/c1-base.txt`.
- Kill rule "plan/counters differ from the predeclaration": `git diff --stat 39460f86 36d0a86 --
  plans/round-53.md plans/round-53-c1.sh plans/round-53-c2.sh plans/round-53-controls.sh` is **empty**.
- Kill rule "C1 reference overlay": `git diff --stat 39460f86 36d0a86 --
  .ufo/waves/round-53/controls/fixtures/ref` is **empty**, and each overlay file is sha256-identical to the
  candidate tree (`corpus/{SOURCES.md,release-clocks.tsv,source-fetches.tsv,quote-bodies.tsv,release-clock.py}`,
  `.ufo/waves/round-53/final/observe-r53.json`, `.ufo/waves/round-53/capture/S111.body`).
- Clock-table causality: field diff BASE→candidate shows the 29 pre-existing rows changed only
  `observed_at` (2026-11-06→2026-11-07) and their note text; `anchored_version`, `observed_version` and
  `verdict` are unchanged (fired 13 → 13, quote-located 11 → 11, not-fired 5 → 7 because the two new rows are
  not-fired). Derived 15 → 17 (the two new derived rows). Matches `plans/round-53.md` §C1.
- Live (non-author) re-observation, plain GET of public pages only, 2026-11-07:
  sops feed `http=200 size=253037 sha=47a224ad…b072ff6` (= receipt S103 sha), first titles
  `<title>Release notes from sops</title>` / `<title>v3.13.3</title>`;
  age feed `http=200 size=40379 sha=32517112…8d8f21d` (= receipt S104 sha and committed S111.body), first titles
  `<title>Release notes from age</title>` / `<title>age v1.3.2</title>`. Both newest stable versions equal the
  pins, so the receipt's contradiction set is empty today. S104 tag page `http=200`, its release datetime
  `2026-08-29T17:55:36Z`, release commit token `b74dce4` present.

## Consequences outside the scoped diff

- **Stamps**: all 125 rows of `corpus/stamps.tsv` recompute byte-exact against the candidate tree (sha256,
  newline count, byte count): `stamped rows 125 bad 0`. 12 paths were re-pinned in the candidate (24 changed
  stamp lines). No STALE pin was introduced by the edit.
- **Nine journaled migrations** replay MATCH one by one from the candidate tree (exit 0, last line shown):
  R13-01 `71`; R21-02/R31-02/R33-02/R34-03 census line `rows=111 … captures=111`; R24-06
  `count=71 sha256=385e89bc…`; R36-02 `2`; R36-03 `RELEASE_CLOCK: CLEAN (on_release=31 …derived=17)`;
  R38-01 `9`. Journal `.ufo/waves/round-53/expectation-migrations.json` carries the matching old/new pairs.
- **Committed verify receipts** (`.ufo/waves/round-53/final/verify-candidate-tree-run1.txt` records
  `real 12m34.969s`; `.ufo/waves/round-53/final/verify-candidate-tree.txt` is the final summary, `rc=2`): none
  of the nine migrated ids appears on a non-PASS line; the non-PASS set (R11-08/R22-03/R24-15/R25-02/R36-01
  FAIL, R29-01/R29-02/R38-03 POLICY, host skips) is the lane's previously declared inherited state, and the
  summary line `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)` agrees with the doc counts. The earlier
  run-1 receipt's `MISSING-ID corpus/lessons/round-53.md:44 R25-01-class` is gone from the final receipt
  (lesson now says "C2-class").

## Defects

### D1 — LOW — feed anchor timestamp misattributed (no effect on C1)

- `corpus/SOURCES.md:118` (S111 anchor cell): "Entry titled age v1.3.2, tag link /releases/tag/v1.3.2,
  **updated 2026-08-29T17:55:50Z**".
- `corpus/lessons/round-53.md:16`: "the entry's `<updated>` is 2026-08-29T17:55:50Z".
- Evidence: in the committed feed (`S111.body`, byte-identical to today's live feed) `2026-08-29T17:55:50Z`
  occurs **once**, as the `<updated>` of the **v1.3.1** entry; the entry titled `age v1.3.2` carries
  `<updated>2026-08-29T18:12:38Z</updated>` (feed-level updated `17:40:19Z`). The v1.3.2 *release page* shows
  `2026-08-29T17:55:36Z`, so 17:55:50Z is neither the page time nor the v1.3.2 feed entry time.
- Effect on C1: none. `derived_anchor_bound` reads version tokens only (`{1.3.2}`), no gate or counter reads
  this timestamp, and the S104 clock matches the receipt's `parsed_version 1.3.2`/`not-fired`. Value stays 2.
  Suggested fix: cite `18:12:38Z` (feed entry) or drop the timestamp and keep "release day 2026-08-29".

### D2 — LOW — R36-02's migrated expectation contradicts its own note (calibration hygiene; C1 unaffected)

- `corpus/claim-ledger.tsv:99` (R36-02) now expects `^2$` (was `^0$`). Its command counts feed rows whose
  observation disagrees with the **frozen** 2026-11-04 receipt `.ufo/waves/round-36/controls/observe-live.json`;
  the two new rows S103/S104 are simply absent there, so the row now passes with two "drift" rows while its own
  note still says "target 0. A row the receipt does not carry counts as drift." The round-53 journal records
  this as a measured population rebinding ("not a claim"), so it is declared, but the row no longer measures
  agreement; any future row added on a watched feed will keep raising the count.
- Same note-staleness (no round-53 sentence) at `corpus/claim-ledger.tsv:100` (R36-03), which still names
  `DEFAULT_RECEIPT_SHA256 3f611eec` / the round-36 receipt while its expectation is now the round-53 verdict.
- Effect on C1: none — C1 is measured by `plans/round-53-c1.sh` (value 2, guard 1) and R36-03 passes with the
  round-53 line. It is a ledger/documentation precision issue, not a C1 defect.

### D3 — LOW — SKILL.md history wording (no effect on C1)

- `SKILL.md:48` says "…including the S103/S104 SOPS and age release **pins added in round 53**". The registry
  pins (S103 v3.13.3, S104 v1.3.2) date from round 48 (both rows' used-by is `corpus/lessons/round-48.md`); round
  53 added their **clock bindings**, not the pins. `PROVINCE.md:75` states it correctly ("round 53 binds … to
  the S033/S111 feeds").
- Effect on C1: none.

## Residual risk and verification gaps

- **Named ceiling survives**: the counter checks committed bytes; a self-consistent fabricated receipt whose
  digest is written into the gate would still score. My non-author plain-GET re-fetch today reproduces both feed
  bodies byte-for-byte and both newest-stable titles, which rules out "the receipt's content is false today",
  but it cannot witness that the fetch happened at 03:02Z. The observed timeline is consistent (BASE
  02:53:03Z < observed 03:02:31–40Z < predeclaration 03:18:50Z < candidate 03:49:25Z), and the predeclaration
  commit already carried the capture and the reference-overlay copy of the receipt.
- **Feed rows store only sha256**, no raw body, so future feed drift can only be detected by re-fetch; the
  rendered-quote rows' live pages were not re-fetched (out of scope; `quote-locate` checks the committed
  captures and the receipt carries `located: true` for them).
- **Full `claim-ledger.sh verify` was not run** (13 min host-heavy, and the assignment scopes this seat out of
  it). Compensating evidence: the committed verify receipts (12m34s run), direct replay of the nine migrated
  rows, all 125 stamp pins, the census, quote-locate and docs audits above.
- The 29 legacy rows' verdicts are unchanged and the fired set is identical (13), but their `observed_at`
  advanced by one day on the strength of the same 03:02Z observation batch; I verified the receipt records
  (all 200, all dated 2026-11-07) rather than the individual vendor pages.

## Commands (all from the candidate tree unless noted; exit codes shown)

- `git -C <lane> archive 36d0a86… | tar -x -C cand`; `… c1953d4… | tar -x -C base` (0/0)
- `python3 corpus/release-clock.py` → `RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17)` (0)
- `python3 corpus/release-clock.py --selftest` → `RELEASE_CLOCK_SELFTEST: PASS (116 cases)` (0)
- `python3 corpus/quote-locate.py` → `QUOTE_LOCATE: CLEAN located=9 rows=9` (0)
- `bash corpus/sources-census.sh verify` → `SOURCES_CENSUS: CLEAN (rows=111 A=107 B=2 C=2 queued=1 mined=106 rejected=4 entries_sourced=16 legacy=21 captures=111 inrow=16 inrow_only=0 inrow_nonreproducing=12)` (0)
- `bash corpus/claim-ledger.sh docs` → `DOC_AUDIT: CLEAN (entries=37 row_linked=34 by_hand=3 …)` (0)
- `bash plans/round-53-c1.sh 36d0a86…` → `C1_CURRENCY_CLOCKS: value=2 watched=2 gate=1 guard=1 …` (0); same on `c1953d4…` → `value=0 …` (0)
- nine migrated rows replayed individually → 9× MATCH, exit 0 each (last lines listed above)
- `sha256sum .ufo/waves/round-53/final/observe-r53.json` → `f927b431…d37c9a` (= gate line 28)
- `printf 'S111\tmined\t<url>\n' | sha256sum` → `646ef9b9…3cd221` (= fetch row column 3)
- live: `curl -sS -A <declared UA> <feed>` → sops 200/253037/47a224ad…; age 200/40379/32517112…; S104 tag page 200 (153079 B, datetime 2026-08-29T17:55:36Z)

SEAT-STATUS: complete
