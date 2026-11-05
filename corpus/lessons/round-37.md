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
