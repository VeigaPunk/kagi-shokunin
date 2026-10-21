# ConnChousa — kagi round-28 sibling-overlap scan (chousa-shokunin)

Read-only; nothing written in the sibling. Kagi BASE `3553d499577084a6c98d7078906017840bbf7b28`
(kagi lines below are `git show BASE:` + `nl -ba`). Sibling `chousa-shokunin` HEAD
`cb895a2bdd259eb38bec29ef70011d8211a508b5` (`git rev-parse`, exit 0); its tree is dirty only in
`corpus/lessons/round-27.md` (+83 appended after :157) and untracked `.ufo/waves/round-27/residual/`,
so every chousa file cited here is HEAD bytes.

## Findings
**F1 — C1/C2 have no mechanism overlap with chousa's secret screen.** Chousa parses no versions:
`grep -rn 'release.clock|anchored_version|leading zero|canonical version'` over its `.md`/`.sh` outside
`corpus/evidence/` and `.ufo/` matched only the gate-banner "version token" contract
(`tools/research-gate.sh:258,261`; `corpus/knowledge/gate-baseline-r12.md:16`; `SCORECARD.md:542,602`) —
an identity word, not version semantics. Its secret mechanism is `scan_secrets()` (`tools/research-gate.sh:686-707`):
eleven shape classes (`op_uri`, `bearer`, `sk_prefix`, `ghp_prefix`, `github_pat`, `aws_akia`, `ssh_key`,
`pem_key`, `server_token_assign`, `api_key_assign`, `password_assign`), emitting `SECRET_SHAPED crit secrecy
"path=$file:$lineno class=$class"` (`:704`) — class only, never the match. Call sites: `:877` (`verify`),
`:1347` (`verify-claims`), `:1650` (`verify-chain`), `:1939` (`verify-sweeps`), `:2197` (`verify-integrity`);
`verify-metadata` (`:2599`+) has none. It never reads `release-clocks.tsv` or a version field.

**F2 — The closest structural sibling to C1 is the anchor token-boundary rule, and it names a live C2
false-positive class.** `corpus/knowledge/anchor-boundaries-r4.md:52-85` (rule; `:80` "Matching stays
**byte-exact and case-sensitive**; no normalization") plus `corpus/lessons/2026-10-15-anchor-token-boundaries.md`.
At kagi BASE, `version_is_named` (`corpus/release-clock.py:341-346`) uses
`(?<![A-Za-z0-9.])v?<escaped>(?![A-Za-z0-9.])`; `-` and `/` are boundaries, so it prefix-binds inside
prerelease/module tags. Measured (python3 3.14.8, exit 0): anchor `"Entry titled v2.2.0-rc1, sdk/v0.26.0"`
binds `2.2.0` → `True` and `0.26.0` → `True`. Chousa's r4 rule makes `-`/`'` a boundary only when it does not
join two word characters; the C2 analogue is a right edge excluding `-`/`+` followed by an alphanumeric.
This is live: S034's **teaches** cell contains `sdk/v0.26.0` and `v2.2.0-rc1` (`corpus/SOURCES.md:40`) while
its anchor cell names only `v2.2.0`, so a whole-row scan would falsely bind a lowered Vault fixture.

**F3 — C2's binding target is a fixed column index with no header contract; chousa falsified exactly this class.**
`parse_sources` (`corpus/release-clock.py:68-96`) takes `"anchor": cells[5]` (`:88`) and enforces only
`len(cells)==11` (`:78-80`) and unique IDs (`:82-83`); it never reads the header row (`corpus/SOURCES.md:5-6`)
or column names. Chousa's round-26 registry checker was **withdrawn** after measured counterexamples: stale
columns accept/misbind an unnamed table, occurrence rescan invents S-ids, and the filesystem-path class escapes
the refusal (`corpus/knowledge/registry-link-r26.md:43-60`; fixes R27-M4/M5 at `corpus/lessons/round-27.md:38-39`).
Kagi's current `SOURCES.md` is one 45-line table, every row NF=13 (`awk -F'|'` over BASE, exit 0), so this is a
maintainability risk, not a present defect — but C2's new finding rests on `cells[5]`.

**F4 — Detection-versus-verification: chousa supplies the limits vocabulary, not a verification mechanism.** Its
coverage is declared incomplete: "Secret scan doesn't cover cited local source files (scan_secrets runs on
record+claims, not resolved source paths)" (`corpus/knowledge/verification-r16.md:35`, row 40); `MINT.md:112-115`
says the screen "must not echo a match" and "must cover those forms before it can be trusted as a screen". Custody
is routed out — "secret values in any record (→ kagi for custody; shape-only here)" (`PROVINCE.md:14-15`;
`SKILL.md:57`). The same discipline appears in `registry-link-r26.md:36-41` ("local declaration relations … not
source support") and `metadata-screen-r25.md:71-75` ("screens key presence and value shape, not criterion 6
itself"). Kagi's own poles: `corpus/transcript-scan.sh:2-11` counts shapes, never prints matched text;
`path_carries_secret` (`corpus/release-clock.py:155-173`) *sanitizes* secret-shaped URL path segments with no
finding at all.

**F5 — The frontier lead is adjacent, not occupied.** Kagi lists "secret-scanning detection vs verification" as
frontier/explored-not-held (`PROVINCE.md:66`), `README.md:113`, leads-only (`corpus/SOURCES.md:81-82`), deferred at
`corpus/lessons/round-21.md:42` "adjacent to chousa/kasegi/kumitate hygiene tripwires". Chousa's ground is a
record/claims hygiene filter with a named coverage gap; it cannot supply verification (it refuses secret values
outright). C1/C2 do not touch the lead, and the lead's ground does not touch C1/C2.

**F6 — Two claim-scope risks, no mechanism contradiction.** (a) C2 binds a derived anchor to an authored registry
cell — a local declaration relation, not feed truth; chousa's wording at `registry-link-r26.md:36-41` is the
reusable limit. (b) `S042` is SemVer in kagi (`corpus/SOURCES.md:49`) but an own-work registry-regression row in
chousa (`corpus/SOURCES.md:52`); lane-local registries make this legal, but the lesson must scope the citation to
kagi's `SOURCES.md`.

## Absorb / contradict (PROVINCE + adjacency)
- **C1:** no absorb, no contradict — kagi's own clock/table; chousa owns research method and keeps secret material out (`PROVINCE.md:14-15`).
- **C2:** no absorb, no contradict — a kagi-local relation between two kagi files. Kagi's adjacent clause says chousa owns the research method and "`SOURCES.md` restates neither method nor admission bar" (`PROVINCE.md:67`); C2 must stay a release-clock declaration check. Do not cite chousa's withdrawn checker as admitted prior art — cite the withdrawal (`registry-link-r26.md:43-60`).
- **Frontier:** chousa/kasegi/kumitate own their output hygiene filters (`PROVINCE.md:67`); chousa routes secret values to kagi (`PROVINCE.md:14-15`). A kagi move on the lead must be verification/custody-side, not a new shape filter over sibling-style records; borrowing `scan_secrets` would invert the routing and still inherit its coverage gap.

## Reusable prior art → this round
| chousa evidence | use |
|---|---|
| `anchor-boundaries-r4.md:52-85` (edges; conditional `-`/`'`; first delimited occurrence; fail-closed) | C2: exclude `-`/`+` continuations; `v2.2.0-rc1`/`sdk/v0.26.0` do not bind `2.2.0`/`0.26.0` |
| `registry-link-r26.md:43-60`; `round-27.md:38-39` (R27-M4/M5) | C2: bind by parsed row identity/column, never text rescan; require the header/column contract |
| `round-27.md:37` (R27-M3: normalize only after a safe-magnitude bound) | C1: length-bound components on the string before any `int()` (peer `RevC1Bound` F2/F4 measures the sites) |
| `research-gate.sh:704`, `:3503-3505`, `:4002` | C1/C2: class+row findings, never the 4301-digit token; add a no-echo assertion |
| `metadata-screen-r25.md:71-75`; `registry-link-r26.md:36-41` | lesson wording: anchor binding is a declaration relation, not feed truth |

## Measured counterexamples (this seat)
- python3 3.14.8, exit 0: `int("1"*4301)` → `ValueError: Exceeds the limit (4300 digits)`; `int("1"*4300)` → ok.
  Confirms the crash sites `corpus/release-clock.py:380`, `:760`. Receipt masking of F1/F4 is already measured by
  peer `RevC1Bound` (its F4/F5); I did not re-run it. The pinned receipt is `sha256 13b8540c…a169` =
  `DEFAULT_RECEIPT_SHA256` (`corpus/release-clock.py:28`), S040 `parsed_version=3.15.1`
  (`.ufo/waves/round-26/observe-2.json`), so a table-only F1 edit trips `RECEIPT-MISMATCH` (`:606-615`) before
  release semantics unless the harness rewrites the receipt and its digest.
- Frozen C2 G2 has the same under-specification in fixture form: because S034's teaches cell contains
  `0.26.0`/`v2.2.0-rc1` (`corpus/SOURCES.md:40`), a "lower canonical version" of `0.26.0` would be falsely
  ACCEPTED by a whole-row scanner. The lowered fixture value must be grep-absent from the whole row (not merely
  lower), or the fixture cannot distinguish anchor-cell binding from row scanning. Reported, not redefined.

## Proposed move (one, bounded)
One shared canonical-version-token edge function for both claims: (1) string-first — bound component digits
before any `int()`, reject a multi-digit leading-zero component on the **raw** token, never normalize-then-accept;
(2) C2 reads only `sources[feed_source_id]["anchor"]` (column-verified) and accepts a version only when its right
edge is not `-`/`+` + alphanumeric, so prerelease/module tags do not bind; (3) findings are class+row only
(`NONCANONICAL`, `OVERSIZE`, `DERIVED-ANCHOR`), never the token — chousa's `SECRET_SHAPED` no-echo precedent.
Affected axes: freshness (C1 total, no traceback) and calibration (C2 exact binding); it improves both, harms
neither. It adds selftest cases only; frozen commands, fixtures and the control string are unchanged.

## Risks
- Prerelease/build false rejects if the edge rule is applied outside the anchor cell: no current `S033-S037` anchor cell carries `-rc`/`-DEV` (those live in S034's teaches cell and S029's row note), so bind `cells[5]` only and say so.
- Header/column reorder silently misbinds `cells[5]`; mitigate with a header-name lookup or a sources-census precondition, not a fixture change.
- Overclaiming: binding to a registry cell does not make it feed truth and does not verify a release; state the declaration-relation limit.

## Verification
- Frozen `c2-measure.py` G1-G4 unchanged; control default `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` exit 0.
- Supplementary (not counted) selftest cases: version only in `teaches`; anchor `v2.2.0-rc1`; anchor `sdk/v0.26.0`; 4301-digit component; raw `3.15.01` — each a typed finding, no traceback, no token echoed. Selftest count grows only by added cases.

## Commands run (exits) and not checked
`git -C chousa rev-parse HEAD` 0 → `cb895a2b…`; `git status --porcelain` 0 (one modified lesson, one untracked dir);
`git show BASE:corpus/release-clock.py | nl -ba | sed …` 0; `git show BASE:corpus/SOURCES.md | awk -F'|' …` 0
(45 pipe lines, all NF=13); `git show BASE:.ufo/waves/round-26/observe-2.json | sha256sum` 0 (matches
`DEFAULT_RECEIPT_SHA256`); `grep -n scan_secrets` on the chousa gate 0 (five call sites); `grep -rn` for
version/release-clock ground on chousa 0 (banner-only hits); python probe above 0. No lane gate, selftest,
measure script or network run.

**Did NOT check:** chousa's full 287 KB `research-gate.sh` (coverage statements rely on the five call sites and the
named r16 row); chousa's gate/selftest behaviour (contract: not in the lane checkout); kasegi/kumitate scanners
(outside target); kagi's `c1-measure.py`/`c2-measure.py` (absent at BASE); peer reports other than
`SrcFrontierScanning.md` and `RevC1Bound.md`; any live feed or external source; the remaining `S033-S037`
semantics beyond their anchor cells.
