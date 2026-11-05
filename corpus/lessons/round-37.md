source: S089 (Vault releases Atom feed), S090 (OpenBao releases Atom feed), S091 (python.org downloads RSS) — all three opened 2026-11-05 with located quotes in §Gate

# Round 37 — release-feed registry anchors re-verified against the live observation

Frozen plan: `plans/round-37.md` at `e2030d2794b…` (plan alone). Frozen instrument, receipt and executed controls: predeclaration `04489d4184edb25a01ec8983b3ccedb45c683564`. Claim BASE: lane HEAD `911ab519b6b07694c3cb9f7d9a7c56e142ad957c` (round-36 landing). Shipped pre-freeze gate over the predeclaration: `PREFREEZE: CLEAN (controls=6 mismatch=0)` (`.ufo/waves/round-37/controls/prefreeze-gate.txt`).

Fresh-start reads, before freezing: the last three rejected closures and their spot-checks — round 34 (`round-34-verifier-spotcheck.md`, C3 arithmetic and coupled populations), round 35 (`round-35-verifier-spotcheck.md`, calibration axis fit withheld), round 36 (`round-36-verifier-spotcheck.md`, C1 rejected as an instrument; routed R36-1..R36-5). Rounds 32–33 read for the same routes.

## Claims

- **C2 freshness — release-feed registry anchors 3 → 0.** `bash plans/round-37-c2.sh` counts the release-feed surfaces (vault releases.atom, openbao releases.atom, python.org feed.rss) with no `SOURCES.md` row naming both the feed URL and the receipt version. BASE **3** at `04489d4` and `911ab51`; the frozen controls and the landing candidate are in §Before → after below. Not calibration: see the lesson's §Calibration hold.

## Calibration hold (not a claim)

`bash plans/round-36-c1.sh` reads **0** at HEAD (`911ab51`), so the round-36 target "4 → 0" is reached by a no-work tree and cannot be a claim this round. Routed to round 38 with its prerequisite: measure every candidate claim's BASE at HEAD before choosing it. The reviewer conditions on that instrument (R36-4) are not re-claimed here.

## Gate

For each new registry row: URL, access date, located quote (≤25 words, located in the bytes fetched 2026-11-05), and the row's `teaches` note on what it supersedes. Feed bytes were fetched with `curl -sS --max-time 60` and their sha256 recorded.

- **ADMIT S089** — `https://github.com/hashicorp/vault/releases.atom`, opened 2026-11-05 (HTTP 200, body sha256 `3cbfdd86d1b45309…`). Located quote, byte offset 726: “`<title>v2.2.1</title>`”; entry updated `2026-10-23T17:34:44Z`. The receipt's vault observation `2.2.1` matches. Supersedes S034 (`v2.2.0` anchor).
- **ADMIT S090** — `https://github.com/openbao/openbao/releases.atom`, opened 2026-11-05 (HTTP 200, body sha256 `a54d1a5314ca7016…`). Located quote, byte offset 729: “`<title>v2.7.2</title>`”; entry updated `2026-10-26T20:24:37Z`. The receipt's openbao observation `2.7.2` matches. Supersedes S035 (`v2.7.1` anchor).
- **ADMIT S091** — `https://www.python.org/downloads/feed.rss`, opened 2026-11-05 (HTTP 200, body sha256 `9ba8856e586659ab…`). Located quote, feed byte offset 1583: “`<title>Python 3.15.2</title>`”; item pubDate `Sun, 25 Oct 2026 04:15:38 +0000`. The feed holds 10 items and is not ordered by release: `3.15.2` is the newest stable item; `3.16.0a1` is a prerelease and `3.14.10` a backport series. Supersedes S039 (`3.15.1` feed anchor).
- **REFUSE (candidate) — a bare version row without the feed URL.** Appending a row that names `v2.2.1` but cites an unrelated URL, or a version only in `knowledge/`, is what the counter's G2/G3 controls refuse. Refused; no row of that shape is in the registry.
- **REFUSE (candidate) — keeping S036 or S039 as the python anchor.** Their anchors name `3.15.0` and `3.15.1`, both superseded by the observed `3.15.2`. The new row supersedes; no existing row's mutable cells change.
- **Mutable cells: none.** `status`, `recheck` and `used-by` of S034, S035 and S039 are unchanged; the supersession lives in the new rows' `teaches`, per CORPUS SOURCES rule 2.

## Quarantine — absent-defect register slice for `kagi`

`awk` over `/home/vgpnk/Projects/shokuknow/.ufo/waves/corpus-expansion-1/absent-defect-register.md` (data rows with a `kagi` lane cell, a round cell and an S-id cell): 8 rows, all class `payload-absent`, none adopted this round, each quarantined until hand-checked in a later round:

| round | id | class |
|---|---|---|
| round1 | S053 | `payload-absent` |
| round2 | S071 | `payload-absent` |
| round2 | S081 | `payload-absent` |
| round3 | S090 | `payload-absent` |
| round3 | S091 | `payload-absent` |
| round3 | S093 | `payload-absent` |
| round5 | S108 | `payload-absent` |
| round5 | S113 | `payload-absent` |

Hazard recorded: the register's `S090` and `S091` are campaign ids for the kagi round-3 package and collide in spelling with this lane's new `S090`/`S091`. Nothing from the register is appended, so no collision reaches the registry; a later adoption must run the id-collision guard (`CORPUS.md` assimilation contract) first.

Assimilation: none this round (the quarantine above adopts nothing; `considerthese/` has no unimplemented proposal left).

## Before → after

- Counter `bash plans/round-37-c2.sh` at BASE `911ab51`, measured in a `git archive` extraction with the frozen counter: **3**.
- Counter at the landing candidate (lane working tree, S089–S091 present): **0**.
- Controls (frozen, `plans/round-37.controls.tsv`, `CLEAN 6/6`): no-work 3, forgery G1 (superseded vault version) 3, forgery G2 (wrong URL) 3, forgery G3 (knowledge-only holder) 3, positive partial 2, positive full 0. Setup controls: receipt missing → exit 2; receipt sha-tampered → exit 2 (`.ufo/waves/round-37/controls/c2-controls.txt`).

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M37-1 | number-drift | the round-36 report's Sources & frontier says "warnings only: five pre-existing `W04 duplicate url across scopes`" (`.ufo/reports/round-36/kagi.md:61`); the same command prints 16 W04 lines at BASE and at the tip (`scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi | grep -c W04` → 16, exit 0). | `none` | the counting command and its output are pasted in this round's report and in §Corrigenda below; the claim is re-derived each round from the command, not from a remembered count. Red-before: the report's "five" against the live "16" is the failing state. |
| M37-2 | landing (harness) | the first control battery's forgery loop executed `plans/round-37-f*.sh` with the lane tree as cwd, not a scratch extraction; the job was stopped before its forgery step ran, and the lane's tracked tree was verified unchanged (`git status --porcelain` empty; `master` tip `911ab51`) before any commit. | `none` | every control now runs only in a `git archive` extraction (`plans/round-37-controls.sh`), and the battery prints `LANE-GUARD` comparing the lane's tracked status and `master` before and after. Not yet shown able to fail: a red-before run of the guard against a deliberate lane write is routed to round 38. |
| M37-3 | stale-premise | the round-36 C1 claim "4 → 0" was planned against a BASE that HEAD had already brought to 0 by round 36's own landing (`bash plans/round-36-c1.sh` at `911ab51` → 0). | `none` | this round declares no calibration claim; §Calibration hold names the prerequisite (measure BASE at HEAD before choosing a claim). |

## Corrigenda

- **Round-36 report, Sources & frontier (`.ufo/reports/round-36/kagi.md:61`) — "five pre-existing W04".** Superseded: the command prints 16 W04 lines (M37-1). The filed report is not rewritten; this lesson is the erratum.
- **Round-36 lesson, Mistakes row M36-3 — the pointer `(M36-4)`.** The discarded attempt-1 edit it describes is recorded in row M36-3 itself; no row M36-4 exists in `round-36.md`. Superseded pointer named here; the round-36 lesson is not rewritten.

## Census

- Before (round start, `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`): exit 0, `kagi ok …/corpus/SOURCES.md`, 16 W04 lines; lane `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=88 …)`.
- After (landing candidate, lane working tree at `e2030d2` plus rows S089–S091, captures and this lesson): fleet `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → exit 0, `kagi ok …/corpus/SOURCES.md`, **19** W04 lines (16 + the three new cross-scope duplicates of the S034/S035/S039 URLs, expected warnings, no E-finding); lane `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=91 A=87 B=2 C=2 queued=1 mined=87 rejected=3 entries_sourced=14 legacy=21 captures=91 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, exit 0. The three capture rows were appended to `corpus/source-fetches.tsv` after the first lane run failed with `SC_FETCH id=S089 missing-provenance` (findings=3). The bodies are wave evidence in `.ufo/waves/round-37/capture/`. Their digests (`3cbfdd86…`, `a54d1a53…`, `9ba8856e…`) differ from the 2026-10-21 captures of S034/S035/S039 (`e41bc579…`, `1f0bb338…`, `11c86a34…`): the feeds moved between those dates, and the 2026-11-05 digests are new point attestations, not a re-pin of the old ones.

## Non-author spot-check

Pending outside closure. This lesson's Gate is lane-authored. Dispatched seats are lane evidence, not outside agreement (LEARNING.md discernment rule).

## Wave settlement

One v1 wave, `build`, 10 seats, all settled with output (`.ufo/waves/round-37/build-results.json`; none dead). Roles: executor 3 (K37ExecRows, K37ExecCounter, K37ExecEvidence), scribe 1 (K37ScribeDocs), scout 1 (K37ScoutRegistry), connector 1 (K37ConnFeeds), reviewer 2 (K37ReviewFresh, K37ReviewCounter), critic 1 (K37CriticClaim), mutation-tester 1 (K37MutCounter). Attack seats 4/10 = 40 %. The planner seat stayed with the L1 (deviation recorded at plan freeze, as in round 33).

Seat verdicts, each read from the seat's own report under `.ufo/waves/round-37/build/`:

- **ROWS** (K37ExecRows): AGREE. Capture digests, row-identity digests, located quotes at the claimed offsets, both censuses exit 0, counter 0 at candidate and 3 at BASE.
- **COUNTER** (K37ExecCounter): AGREE. Candidate 0, BASE 3, setup exits 2 with no integer.
- **EVIDENCE** (K37ExecEvidence): AGREE. `self-counts` stale 0 with the two operator-owned POLICY rows (PV-FEEDTOKEN-SHAPES, PV-FEEDTOKEN-SELFTEST); census selftest PASS (70 cases); `claim-ledger docs` CLEAN (entries 35); no current count in SKILL/PROVINCE/README says 88 registry rows.
- **FRESH** (K37ReviewFresh, independent re-fetch of all three feeds): AGREE on S089, S090, S091. Quotes located in its own bytes; anchor is the newest stable entry; the superseded versions named in each `teaches` exist in the live feed.
- **COUNTER REVIEW** (K37ReviewCounter, 15 attacks): attacks=15 wrong=0. The counter fails closed on receipt faults and reads the boundary and URL correctly. Named ceilings below.
- **CLAIM CRITIC** (K37CriticClaim): counterfeit_passes=yes, verdict=admissible on its predicate. A counterfeit with invented quotes and the correct URL and version reads 0; no repo gate opens the stored bodies. Discipline condition, recorded in §Ceilings.
- **MUTATION** (K37MutCounter): killed=5 survived=1. M1 (URL), M2 (version equality), M3 (knowledge holder), M4 (SETUP as 0), M6 (column) killed on the frozen set. M5 (boundary `(?![0-9])` dropped) survived the frozen set and was killed by an extra probe (`v2.2.10`) the frozen set does not contain. Routed below.
- **CONNECTOR** (K37ConnFeeds): no sibling lane hits the same feed surface (overlap 0).
- **SCOUT** (K37ScoutRegistry): feed rows outside the claim population: `S033` sops (anchor 3.13.3, current against the receipt's sops record) and `S038` whatwg (empty feed, rejected). Superseded feed anchors: S034, S035, S036, S039.

## Ceilings (named before data, measured by the wave)

- **Quote authenticity is not machine-checked.** No repo gate opens `.ufo/waves/round-37/capture/*.body` or checks a Gate quote against it: the lane census and the fleet census both pass with the bodies deleted (K37CriticClaim, V3). A row can therefore pass the frozen counter with an invented quote (K37CriticClaim counterfeit). What supports C2's substance is this round's independent re-fetch (K37ReviewFresh), not the counter. The critic's discipline condition is adopted: the round's closure must not cite the counter's 0 or either census CLEAN as evidence of quote authenticity. Routed: a located-quote gate against committed bodies (`rendered-text-v1.py locate`), round 38.
- **Append-only is not enforced by the counter.** Rewriting S034's, S035's and S039's anchor cells in place to the current versions reads 0 with no new row (K37ReviewCounter A1, A1c). The candidate does not do this (its three rows are additions; S034/S035/S039 mutable cells are unchanged, checked by diff at `9efcea7`). Routed: a BASE-to-candidate anchor-immutability check, round 38.
- **Looseness of the URL and version match.** `12.2.1`, `.v2.2.1`, `1v2.2.1`, `hashicorp-vault2.2.1`, `python 3.15.2`, `Python  3.15.2` match the version pattern, and a row whose source cell embeds the URL in a longer string counts (K37ReviewCounter A5, A2h). Strict on trailing query strings and schemes (A2, A2b). None of these shapes is in the candidate.
- **Comment and fence blindness.** A row inside an HTML comment or a code fence counts both ways (A6–A6e). Consistent with "any matching row holds the surface"; not exploited by the candidate.
- **The frozen control set does not exercise the boundary.** M5 survives it; the extra `v2.2.10` probe kills it. Routed as a coverage gap for the next round's frozen-counter amendment; this round's claim and controls are not changed after data.

## Migrations and stamps (QM5, QM14)

- **Ledger expectations, old → new**, each row's notes kept verbatim with a migration sentence appended, record `.ufo/waves/round-37/expectation-migrations.json`: `R21-02`, `R31-02`, `R33-02`, `R34-03` — `rows=88 A=84 mined=84 captures=88` → `rows=91 A=87 mined=87 captures=91`. Each new regex matches the live census line (checked: `MATCH` × 4). Word diff against HEAD shows only the count tokens and the appended sentence changed. The frozen round-34 C3 target is NOT amended.
- **Stamps, old → new** (`corpus/stamps.tsv`): `corpus/SOURCES.md` `b974504e…/248/84683` → `b8f502a1…/251/86981`; `corpus/source-fetches.tsv` `66403078…/131/52524` → `8609b0bd…/134/53645`; `corpus/claim-ledger.tsv` re-pinned at the migrated bytes (`2e819250…/100/44320`). `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f --root .` → `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=49 invalid=0)` (was `DRIFT stale=2` before the re-pin; the third stale entry was the migrated ledger). `row-identity.sh revision-added` → `count=49 sha256=5bc6507a8807280c5dc352e561e65b8beefdd71deeb30c67db0234238fe86412` (was `SETUP`).

## Routed to round 38 (not claimed, not hidden)

- **Release clock table not re-pointed.** `corpus/release-clocks.tsv` still binds S012–S028 and S040/S041 to the superseded rows and the round-36 receipt. Re-pointing the feed ids alone breaks `DERIVATION` (10 findings: the derived binding needs the anchored version); updating the anchored versions as well leaves 11 `RECEIPT-MISMATCH` rows on `observed_at` 2026-11-04 vs 2026-11-05. A coupled change, not a one-cell edit. The release-clock gate still reads `CLEAN (…)` at both BASE and the candidate (its default pin is round 36).
- **The round-37 receipt is not consumable by `release-clock.py`.** It was written by `--observe` in a scratch root without `corpus/source-fetches.tsv`, so its 10 rendered-quote records error with "source row has no declared capture quote" (K37Scout §5.2; M37-2 class). The C2 counter does not read those fields and is unaffected; a full-tree re-observation is a separate act, and it would change the pinned sha, so it is not done inside this claim.
- **The calibration hold** (R36-4 reviewer conditions) and the M37-2 guard red-before run, as stated above.
- **Stale prose in SCORECARD** (`R32-4`): the capabilities-table sentence about the latest first-working round is updated this round to 37 because the row is new; the older prose is not otherwise touched.

## Frontier debt carried forward

- The 8 quarantined absent-defect rows (above) remain unadopted; the register's campaign ids `S090`/`S091` are not this lane's rows and must be re-keyed under the collision guard before any adoption.
- `S036` (python `3.15.0`) and `S039` (python `3.15.1`) remain as superseded history rows; their status is unchanged.
