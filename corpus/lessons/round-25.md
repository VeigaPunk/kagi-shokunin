source: S033, S034, S035, S036, S037
verified-at: 2026-10-21 (five public release feeds fetched over HTTPS with the declared request profile; every on-release registry row observed once; no account, vault, handler or CDP contact)
recheck: 90d — refetch the five feeds; re-run `python3 corpus/release-clock.py --observe <new receipt>` whenever a feed shows a newer stable release.

# Round 25 — numbers bound to their source, the lone clone made explicit, release clocks that can fire

Frozen starting revision: `4587c61a348e4528717404a68912c373f3ef4d03` (round 24
admitted, MANIFEST closure `CloseKagi24`). Claims frozen in `plans/round-25.md`:
C1 calibration (current-tense self-description numbers bound to live values,
routed D1), C2 operability (lone-clone layout explicit in `citations`/`verify`,
routed D2), C3 freshness (every `on-release` recheck bound to a fireable clock
and observed; sourced by S033–S037). All six axes sit at 9; the stagnation
nudge does not fire (one completed round since the last capability, window 3).
The L1 held the frozen planner seat; the planning data walk rode the wave-1
scouts, reviewers, revengers and connectors (`.ufo/waves/round-25/build/`).

## Plan corrections (named, append-only)

- **R25-C1 (C2 shape).** The plan's `[fleet]` row tag with a whole-row
  `LAYOUT-SKIP` is withdrawn before landing: a skipped R11-08 would also hide
  lane-local citation defects in a lone clone (SentLayoutSkip F2) and could end
  `CLAIM_LEDGER: CLEAN` exit 0 (SentLayoutSkip F1, CritC2, RevR1108 CE2,
  RLayoutMarker). Landed instead: per-token classification. The row still
  RUNS; only unresolved sibling/fleet-only tokens become `FLEET-ABSENT`; the
  gate ends `CITATION_GATE: INCOMPLETE` exit 3; `verify` names the row
  `LAYOUT-INCOMPLETE` and ends `CLAIM_LEDGER: INCOMPLETE` exit 1. No tag, so no
  free label to launder (SentLayoutSkip F3).
- **R25-C2 (C2 counts).** The plan's `fleet_absent=88` is wrong: 42 of the 88
  BASE lone misses were committed `kagi-shokunin/…` self-references that only
  fail when the clone is not named `kagi-shokunin` (RCiteTargets, RFleetRows
  F1). Self-references now resolve in-tree first. The lone count is therefore
  name-invariant.
- **R25-C3 (C2 marker).** `$ROOT/../.ufo` AND `MANIFEST.json` was unsafe on a
  partial fleet (7 safety failures in RLayoutMarker's 22 fixtures). Landed:
  lone only when neither parent view holds `.ufo`, `MANIFEST.json`,
  `MISSION.md`, `AXES.md` or another `*-shokunin` lane (0 safety failures).
- **R25-C4 (C2 scope, found while building).** The citation tokenizer never
  read the last token of a line (`printf '%s'` without a newline; reported by
  RQualityCriteria). Fixed in the same gate because it changes what
  "unresolved" counts: the fleet layout now checks 1546 citations instead of
  1371 and surfaced exactly one malformed citation (`LOG.md:1202`,
  a slash-joined pair of the closure script and its `.json` record —
  spacing only, now two tokens; no meaning change).
- **R25-C5 (C1 sources).** `ledger:<ID>` execution refuses host/substrate rows,
  so present-tense counts pinned only by such rows (R11-03 surface-census
  selftest; R12-02, which executes `op`) were unbindable (XSelfCounts blocker).
  Added `expect:<ID>`: the doc is bound to the row's committed pin and nothing
  is executed; the ledger's own consented run re-measures the pin.
- **R25-C6 (C1 population).** The plan's history exemption ("round-dated, in
  LOG/lessons/SCORECARD") is undecidable on SKILL.md's own lines (RHistoricalVsCurrent,
  CritC1 CE3/CE4): a "round N" tag alone would have exempted SKILL.md:46, the
  motivating defect. Landed rule: a number is CURRENT when it states an
  artifact's present size and no newer value sits in the same clause; an
  explicit history clause ("63 at round 21", the dated Round-N bullets of
  §Falsification history) is out. The bound population is the 37 rows of
  `corpus/self-counts.tsv` over SKILL.md, PROVINCE.md and corpus/README.md;
  completeness over all docs is NOT claimed (knowledge entries are named debt
  below).
- **R25-C7 (C3 shape).** The executor's tool required feed rows of kind `feed`
  (not in the census enum), parsed only a feed's first entry (GitHub Atom
  mixes `sdk/v0.26.0`, `api/v2.7.1` and `-rc` entries), took quotes from the
  registry `teaches` cell (backticks never locate: ClockS009/S011/S012), and
  its secret-path heuristic refused the 1Password blog slug of S006/S020.
  Landed: feed rows are ordinary registry rows (docs/code/dataset, not
  themselves on-release); the newest stable `X.Y.Z` over every entry wins; a
  plain-text `Version:` file is read; rendered-quote clocks use the declared
  capture quote and profile from `corpus/source-fetches.tsv`; a hyphenated
  word slug is not a token. The GitHub REST API is not used: unauthenticated
  quota was exhausted on this egress (403, every Clock seat) and `latest` sorts
  by date, not semver.
- **R25-C8 (C3 anchors).** 15 of the 18 feed-bound rows name no release in
  their anchor. Their anchored release is DERIVED — the newest stable release
  on the feed when the row was opened — and the clock row's note says so
  (`derived:`); the gate counts them (`derived=15`) instead of calling them
  named. Alternatives the seats raised are recorded, not silently chosen:
  ClockS009/S010 derived from the docs' last-modified date (v3.13.0), which
  reads FIRED; ClockS010 then ran official sops v3.13.0 and v3.13.3 binaries
  on throwaway age identities and found the key-group teaching unchanged
  (26/26 decrypt checks). Under either derivation the teaching holds.

## Gate — sources opened and decided this round

All five rows were opened by the L1 with
`bash .ufo/waves/round-25/tools/capture-feeds.sh` (declared profile
`curl-fsSL-compressed-v1`; HTTP 200; quote byte-located in the decoded body;
rows in `corpus/source-fetches.tsv`), access date 2026-10-21.

| id | URL | decision | quote (located) | location |
|---|---|---|---|---|
| S033 | https://github.com/getsops/sops/releases.atom | admit, tier A (maintainer release feed), mined | “<title>v3.13.3</title>” (1 word) | first stable entry, updated 2026-07-23T05:29:11Z |
| S034 | https://github.com/hashicorp/vault/releases.atom | admit, tier A, mined | “<title>v2.2.0</title>” (1 word) | first stable entry, updated 2026-10-15T18:50:14Z; the same feed carries `v2.2.0-rc1` and `sdk/v0.26.0` |
| S035 | https://github.com/openbao/openbao/releases.atom | admit, tier A, mined | “<title>v2.7.1</title>” (1 word) | first stable entry, updated 2026-10-01T18:32:18Z; `api/` and `sdk/` module releases excluded |
| S036 | https://www.python.org/downloads/feed.rss | admit, tier A (vendor release feed), mined | “<title>Python 3.15.0</title>” (2 words) | newest stable item, pubDate Fri, 09 Oct 2026; `Python 3.16.0a1` above it is a prerelease |
| S037 | https://curl.se/info | admit, tier A (maintainer release file), mined | “Version: 8.23.0” (2 words) | line 1; `Date: 2026-10-14`, `Next release: 2026-12-09` |

Rejected, not registered: the GitHub REST `releases/latest` endpoints
(unauthenticated 403 on this egress; `latest` is date-sorted, so a backport can
become "latest"; flip: an authenticated, semver-sorted listing); the
`releases.1password.com` index (client/SDK releases, never the S005–S007 or
S017–S020/S032 guides; flip: a per-guide changelog); the WHATWG commit Atom
feeds (per edit, not per release; flip: a tagged release stream); python.org's
JSON release API (equivalent content, chosen RSS for one parser).
Supporting check for S037's teaching: `include/curl/curlver.h` on curl master
reads `LIBCURL_VERSION "8.23.1-DEV"` and `LIBCURL_TIMESTAMP "[unreleased]"`, and
the S029 man page says "curl 8.23.1": S029's anchor names a development label.

**Registry cell changes (status / recheck / used-by), old → new:** none. No
existing row was edited; the five new feed rows carry `recheck: 90d` so a feed
is never itself an on-release row (no clock for the clock).

## Clock observations (C3)

`python3 corpus/release-clock.py --observe` wrote
`.ufo/waves/round-25/observe-1.json` (28 observations, failed=0): 18 feed
clocks parsed their feed's newest stable release and 10 rendered-quote clocks
located their declared capture quote. One clock **fired**:

- **S012** (Vault JWT/OIDC) names "newest pinned version v1.21.x"; the feed's
  newest stable release is v2.2.0 (2026-10-15). Re-verification (ClockS012,
  fresh fetch 2026-10-21, decoded sha256 `62556bf0…`, normalized digest equal
  to the row's capture): the served page is the `v2.x (latest)` route, the
  1.17+ JWT-role audience note still reads "must exactly match at least one of
  the `aud` claims", and no 2.0.0–2.2.0 changelog entry changes audience
  handling. The row's teaching holds on 2.2.0; its anchor is stale. S022
  already supersedes S012's scope; no new superseding row is needed for the
  rule, and the stale "v1.21.x" anchor is recorded here rather than rewritten
  (append-only).
- Not fired, with re-verified teachings (wave-1 Clock seats): SOPS S008–S011
  at v3.13.3; OpenBao S014–S016/S021/S025/S026 at v2.7.1; Vault
  S013/S022–S024 at v2.2.0; Python S027/S028 at 3.15.0; curl S029 at 8.23.0.
  Rendered-quote rows S005–S007, S017–S020, S030–S032 locate their capture
  quote. ClockS027/S028 observed that the Python docs were rebuilt at 07:27 UTC
  (footer timestamp only): decoded digests moved, quotes still locate — a
  volatile representation, not drift.

## Routed defect dispositions (round-24 closure `CloseKagi24`)

- **D1 — SKILL.md:46 "63 stamps + 39 claims, round 21" vs 83/61:** fixed and
  bound (C1: rows SC-SKILL-STAMPS/SC-SKILL-CLAIMS bind the line to ledger rows
  R12-03/R21-04; R25-02 runs the binder in `verify`).
- **D2 — make R11-08/citations lone-clone behaviour explicit in the verify
  output:** fixed (C2: `LAYOUT-INCOMPLETE R11-08` + `CLAIM_LEDGER: INCOMPLETE`;
  `citations` prints `FLEET-ABSENT` and `CITATION_LAYOUT`, ends `INCOMPLETE`
  exit 3; R11-08's note and `knowledge/claim-ledger.md` bound 8 updated).
- No round-24 verifier spot-check lesson and no operator teaching lesson
  exist in `corpus/lessons/`. Nothing further routed.

## Mistakes

| id | class | evidence | captured-by | fix (shown able to fail) |
|---|---|---|---|---|
| M25-1 | number-drift (current-tense self-description) | SKILL.md:46 said 63 stamps / 39 claims at BASE `4587c61a` while R12-03/R21-04 pinned 83/61; also SKILL.md:243 and corpus/README.md:63 "97 cases" (151), README:64/65 39/63 rows, README:67 21/24 and floor 12 (MutCountRows: four doc-number mutations survive every existing gate) | none — the ledger pins live values, never a document's statement of them (RevCountRowsOrigin) | `corpus/self-counts.py` + R25-02; a one-digit doc mutation turns it STALE exit 1 (`.ufo/waves/round-25/tools/c1-measure.sh --mutate`) |
| M25-2 | silent-skip (tokenizer) | `corpus/claim-ledger.sh` piped `printf '%s'` into `read`, so the last token of every line was never checked since round 11; fixing it adds 175 checked citations in the fleet layout | none — every citation fixture ended its line with a plain word | `printf '%s\n'` + selftest `cite-eol-token-checked`, which fails on the old pipeline |
| M25-3 | documented-not-enforced | R11-08's note alone said a lone clone "fails by design"; `verify` printed a bare `FAIL R11-08 reason=exit-mismatch` | none | C2 verdicts + selftests `cite-lone-*`/`verify-layout-*` |
| M25-4 | measurement-context-missing | the round-24 closure quoted 73 lone misses, this round measured 88 on `/fast/scratch`: the count depended on the clone's directory name and parent contents | none | self-references resolve in-tree (R25-C2); the lone count no longer depends on the directory name |
| M25-5 | parser-assumption | the delivered C3 parser read a feed's first entry only, and its URL heuristic refused a word slug — both would have mis-clocked real feeds (L1 integration against the five live feeds) | L1 integration run against real bodies, not the synthetic fixtures | max-stable parser + slug rule, eleven new selftest cases (`module tag and rc skipped`, `rss product titles`, `word slug accepted`, …) |

Named debt, not fixed this round (calibration, not concealment): current-tense
numbers inside knowledge entries that the wave found stale and that C1's
population does not cover — `knowledge/claim-ledger.md:81` (case 16 vs 27),
`knowledge/sops-age-key-rotation.md:68-70` (grep now exits 0),
`knowledge/vault-openbao-token-lease-lifecycle.md:78`,
`knowledge/op-ref-consumption.md:276,283,296`,
`knowledge/credential-isolation.md:120-122`, and the errata-conceded body
numbers of `knowledge/surface-census.md` (SelfInvKnowledge1/2). One knowledge
count was hand-corrected because the code proves it: the ledger allowlist is
six commands, not five (`knowledge/claim-ledger.md` bound 11). SKILL.md:363
"eight of the line shapes" is left unchanged: the probe's divergent contract
counts five keys, but the sentence may count a different quantity (measured
by hand in round 12) — unresolved, not "fixed".

## Before → after

Measured on the committed candidate and recorded with exact commands, exits
and stdout in the SCORECARD round-25 outcome section (appended after the
candidate lands, so the measurement names a pushed revision).
