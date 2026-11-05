# ScoutRegistry — round 37 (attempt 1), seat report

Lane: `kagi-shokunin`. Seat: **K37ScoutRegistry** (scout, read-only registry
survey). Candidate `9efcea7`, BASE `911ab51`. All lane reads were done in
`git archive` extractions under the seat's scratch root; the lane's tracked
files, git/jj state and index were not touched.

## Verdict

The registry survey is **clean for the claim**: all three in-claim release-feed
surfaces are held by a `corpus/SOURCES.md` row at the candidate, and the
frozen counter reads **0** there. Two out-of-claim feed rows exist (`sops`,
`whatwg/html`); one is current against the available receipt, one has **no
receipt record at all** and cannot be checked without fetching new bytes
(which this seat did not do).

**Frontier input for the next round (not part of this claim):**

1. **`corpus/release-clocks.tsv` was not re-pointed to the new rows.** It still
   binds the feed clocks to the *superseded* rows `S034/S035/S036/S039`.
   Re-pointing `feed_source_id` to `S089/S090/S091` **fails** the lane's own
   clock tool with 10 `DERIVATION` findings, because `derived_anchor_bound()`
   requires the feed row's anchor cell to name *exactly one* stable X.Y.Z and
   the clock rows' `anchored_version` values (`2.2.0`, `2.7.1`, `3.15.0`,
   `3.15.1`) no longer match (§5.1).
2. **The round-37 receipt `observe-r37.json` is not consumable by
   `release-clock.py`.** 10 of its 30 records carry
   `error: "source row has no declared capture quote"` and `verdict: null`;
   the other 20 carry `observed_at` dates `2026-11-05` while
   `release-clocks.tsv` says `2026-11-04`. Feeding it to the tool yields
   `RELEASE_CLOCK: FAILED (observed=0 …)`, exit 1 — *not* a verdict the claim
   depends on (the C2 counter reads `parsed_version` only), but a trap for any
   round that makes the new rows the clock's source rows. The offline
   reproduction (§5.2) shows the 10 errors are exactly what `parse_captures`
   produces when `corpus/source-fetches.tsv` is absent from the tree the
   observation ran in.
3. **`corpus/stamps.tsv` was not re-pinned by the candidate.** It still pins the
   BASE sha of `corpus/SOURCES.md` and `corpus/source-fetches.tsv`, so
   `revision-audit.py` reads `REVISION_AUDIT: DRIFT (stale=2 …)` at the
   candidate where it reads `CLEAN (stale=0 …)` at BASE, and `row-identity.sh
   revision-added` returns `SETUP` at the candidate (it works at BASE). The
   candidate also moved the census row count `88 → 91` while four ledger rows
   (`R21-02`, `R31-02`, `R33-02`, `R34-03`) still expect the literal
   `rows=88 …captures=88` string, so all four now FAIL `verdict-not-final`.

These are landing-integrity findings for the L1 (the only writer of lane
production files), not defects in the C2 claim, which the frozen counter
measures independently of all three.

## 1. Column index — verified before counting

The frozen counter `plans/round-37-c2.sh` splits a `SOURCES.md` row on `|`
**including the leading empty column** and reads `cells[2]` (source) and
`cells[6]` (anchor). Verified against one row (`S089`, 13 split fields) before
counting: `cells[2]` = `Vault releases, GitHub release Atom feed — https://github.com/hashicorp/vault/releases.atom`;
`cells[6]` = `Entry titled v2.2.1, tag link /releases/tag/v2.2.1, first st…`;
`cells[7]` = `supersedes S034 — the newest stable Vault release…`. All 91
registry rows split into exactly 13 fields, so the indices are well-defined for
every row; the seat's survey uses the same ones.

## 2. Registry rows with a feed-style URL in the source cell

Pattern (seat spec): `releases\.atom|/releases|feed\.rss|releases/`, applied to
the **URLs extracted from the source cell** (`cells[2]`), not the whole cell.

| id | feed URL | anchor cell (`cells[6]`) | receipt version | anchor names it? | version named | superseded? |
|---|---|---|---|---|---|---|
| S033 | `…/getsops/sops/releases.atom` | Entry titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z; fetched 2026-10-21 | 3.13.3 | **yes (3.13.3)** | v3.13.3 | no |
| S034 | `…/hashicorp/vault/releases.atom` | Entry titled v2.2.0, tag link /releases/tag/v2.2.0, updated 2026-10-15T18:50:14Z; fetched 2026-10-21 | 2.2.1 | no | v2.2.0 | **yes (2.2.0)** |
| S035 | `…/openbao/openbao/releases.atom` | Entry titled v2.7.1, tag link /releases/tag/v2.7.1, updated 2026-10-01T18:32:18Z; fetched 2026-10-21 | 2.7.2 | no | v2.7.1 | **yes (2.7.1)** |
| S036 | `…python.org/downloads/feed.rss` | Item titled Python 3.15.0, pubDate Fri, 09 Oct 2026 13:54:59 +0000; fetched 2026-10-21 | 3.15.2 | no | 3.15.0 | **yes (3.15.0)** |
| S038 | `…/whatwg/html/releases.atom` | Atom feed root title and zero entry elements; fetched 2026-10-21 | *no receipt record* | no | none | n/a |
| S039 | `…python.org/downloads/feed.rss` | Python 3.15.1 item, pubDate Wed, 21 Oct 2026 09:59:50 +0000; fetched 2026-10-21 | 3.15.2 | no | 3.15.1 | **yes (3.15.1)** |
| S089 | `…/hashicorp/vault/releases.atom` | Entry titled v2.2.1, tag link /releases/tag/v2.2.1, first stable entry at byte offset 726; fetched 2026-11-05 (receipt …observe-r37.json) | 2.2.1 | **yes (2.2.1)** | v2.2.1 | no |
| S090 | `…/openbao/openbao/releases.atom` | Entry titled v2.7.2, tag link /releases/tag/v2.7.2, first stable entry at byte offset 729; fetched 2026-11-05 (receipt …observe-r37.json) | 2.7.2 | **yes (2.7.2)** | v2.7.2 | no |
| S091 | `…python.org/downloads/feed.rss` | Item titled Python 3.15.2, pubDate Sun, 25 Oct 2026 04:15:38 +0000; fetched 2026-11-05 (receipt …observe-r37.json) | 3.15.2 | **yes (3.15.2)** | 3.15.2 | no |

Anchor-vs-receipt comparison uses the counter's own regex,
`(?<![0-9.])(?:v|Python\s)VERSION(?![0-9])`, so `v2.2.1`, `Python 3.15.2` and
a bare `2.2.1` all match — identical semantics to `plans/round-37-c2.sh`.
Sanity sweep: 12 source cells mention *release/feed/rss/atom* in any form; the
3 extras are `S052` (RFC 4287 text file), `S037` (`https://curl.se/info` — a
version file, not a feed URL) and `S072` (1Password CLI release-notes page, no
feed path). Only the 9 rows above carry a feed-style URL.

## 3. The three counts, with commands and output

### Count A — rows with a feed URL in the source cell

```
$ grep -cP '^\|\s*S[0-9]{3,}\s*\|.*https?://[^|]*(releases\.atom|/releases|feed\.rss|releases/)' corpus/SOURCES.md
9

$ grep -oP '^\|\s*\K(S[0-9]{3,})' <(grep -P '^\|\s*S[0-9]{3,}\s*\|.*https?://[^|]*(releases\.atom|/releases|feed\.rss|releases/)' corpus/SOURCES.md) | tr '\n' ' '
S033 S034 S035 S036 S038 S039 S089 S090 S091
```

**A = 9.**

### Counts B and C — anchor current / anchor superseded

```
$ python3 survey.py . /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-37/controls/observe-r37.json
=== COUNTS ===
rows with feed-style URL in source cell : 9
row-url pairs whose anchor names the receipt version : 4
row-url pairs whose anchor names a superseded version : 4
```

(`survey.py` and its full output `survey.out` are written beside this report;
sha256 `9618eace…` / `d5cc1a66…`. The script re-implements the counter's own
row parse and version regex and reads the receipt read-only.)

**B = 4** row–URL pairs whose anchor names the current receipt version: `S033`
(sops 3.13.3), `S089` (vault 2.2.1), `S090` (openbao 2.7.2), `S091` (python
3.15.2). **C = 4** row–URL pairs naming a superseded version: `S034` (2.2.0),
`S035` (2.7.1), `S036` (3.15.0), `S039` (3.15.1). `S038` names no version and
has no receipt record, so it is in neither count. Restricted to the three
in-claim surfaces: **B_in-claim = 3** (`S089`, `S090`, `S091`),
**C_in-claim = 4** (`S034`, `S035`, `S036`, `S039`) — the python surface has
two superseded rows (`S036`, `S039`) against one current row (`S091`), which is
why C is 4 and not 3.

### Independent cross-check of the claim's own number

The frozen counter, run in a `git archive` extraction of the candidate:
`bash plans/round-37-c2.sh` → `0`, EXIT=0. At the predeclaration commit
`04489d4` (BASE `SOURCES.md` + the same counter and receipt): `3`, EXIT=0.
Re-running the counter's exact predicate against the BASE `SOURCES.md` with
the candidate's receipt reproduces the same three per-surface misses
(`vault 2.2.1 held by NONE`, `openbao 2.7.2 held by NONE`,
`python 3.15.2 held by NONE` → `BASE stale surfaces: 3`), so the 3 → 0
movement is attributable to rows `S089`–`S091` alone.

## 4. Feed URLs with a registry row that are NOT in the three-surface claim population

**S033** — `https://github.com/getsops/sops/releases.atom`; anchor `Entry
titled v3.13.3, tag link /releases/tag/v3.13.3, updated 2026-07-23T05:29:11Z;
feed fetched 2026-10-21`. **Current against the available receipt:** the
receipt observes this URL 4× at `parsed_version 3.13.3` and the anchor names
v3.13.3; the receipt's body sha256 `47a224ad71435b7f…` equals the `S033`
capture row's body sha, so the receipt saw the same bytes the row cites.

**S038** — `https://github.com/whatwg/html/releases.atom`; anchor `Atom feed
root title and zero entry elements; fetched 2026-10-21`. **Cannot be checked:**
the receipt contains **no record** for this URL
(`https://github.com/whatwg/html/releases.atom → ABSENT FROM RECEIPT`); its
only whatwg records are `infra.spec.whatwg.org` and `html.spec.whatwg.org`,
which are the `S030`/`S031` rendered-quote clocks. The row is `status=rejected`
(empty feed, zero entries) — an intentional rejection, not a stale anchor.
Determining whether the feed still publishes entries would require fetching
new bytes, which this seat did not do and did not attempt.

A third release-surface URL is in the receipt but has **no feed-style registry
row**: `https://curl.se/info` (observed `8.23.0`, held by `S037`) — a static
version file, not a feed, so the pattern does not select it, but it would
satisfy a widened population. Widening the population to include `whatwg/html`
would make the counter **exit 2 (SETUP)**, because a surface absent from the
receipt fails closed (measured with the counter's own predicate over the
candidate's `SOURCES.md`; no new bytes fetched):

```
--- widened: sops
  https://github.com/getsops/sops/releases.atom: receipt 3.13.3 held_by=['S033']
--- widened: curl
  https://curl.se/info: receipt 8.23.0 held_by=['S037']
--- widened: whatwg html atom
  https://github.com/whatwg/html/releases.atom: SETUP (receipt versions=0) -> counter would exit 2
```

## 5. Frontier measurements (scratch, read-only, no lane writes)

### 5.1 Re-pointing the clock table to the new rows breaks `DERIVATION`

`corpus/release-clocks.tsv` still binds the feed clocks to the superseded rows
(`S012→S034`, `S014→S035`, `S027→S036`, `S040→S039`); no row in the table
references `S089/S090/S091`. Re-pointing only `feed_source_id`:

```
=== re-point feed_source_id S034->S089 S035->S090 S036->S091 only; default receipt ===
DERIVATION S013  (one such line each for S014 S015 S016 S021 S022 S023 S024 S025 S026)
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=20 fired=5 derived=5)
EXIT=1
```

Cause: `release-clock.py`'s `derived_anchor_bound()` (round-28 C2) requires the
feed row's anchor cell to name **exactly one** stable X.Y.Z equal to the clock
row's `anchored_version`. `S089`'s cell names only `v2.2.1`, while `S013`'s
`anchored_version` is `2.2.0` — the derived binding is broken. Adding the
anchored-version update as well (`2.2.0→2.2.1`, `2.7.1→2.7.2`,
`3.15.0/3.15.1→3.15.2`) removes the `DERIVATION` findings but then leaves 11
`RECEIPT-MISMATCH` rows, because `receipt_matches()` compares `observed_at`
(receipt `2026-11-05` vs table `2026-11-04`) and `verdict`. Making the table
agree with the round-37 receipt is a **coupled** change (ids + anchored
versions + verdicts + dates), not a one-cell edit.

### 5.2 The round-37 receipt is not consumable by `release-clock.py`

```
$ python3 corpus/release-clock.py --root . --receipt .ufo/waves/round-37/controls/observe-r37.json --receipt-sha cb96cfb23bda8d1366a184c280aebe767ed09b0bba0934876edeef6fe42c9203
RECEIPT-MISMATCH S005 … (30 rows)
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=0 fired=0 derived=0)
EXIT=1
```

Attributing each mismatch with the tool's own `receipt_matches()` predicates:
the 10 error records are exactly the `rendered-quote` clocks (`S005`, `S006`,
`S007`, `S017`, `S018`, `S019`, `S020`, `S030`, `S031`, `S032`, each with
`error: source row has no declared capture quote`); the 20 `observed_at`-date
mismatches are exactly the `feed` clocks. Offline reproduction (stubbed
network, `capture` lookup driven by `parse_captures`):

```
WITH corpus/source-fetches.tsv: captures=88 rendered-quote ERROR rows=[] OK rows=10
WITHOUT corpus/source-fetches.tsv: captures=0 rendered-quote ERROR rows=['S005','S006','S007','S017','S018','S019','S020','S030','S031','S032'] OK rows=0
```

So the receipt's 10 errors are what the tool writes when the capture table is
not in the tree the observation ran in — the same "harness ran against the
wrong tree" class the round-37 lesson records as M37-2. The C2 counter does
not read those fields, so the claim is unaffected; a future round that wants
the receipt to be the clock's receipt must re-observe it with the capture
table present. The receipt's **feed** records are internally consistent with
the candidate's capture rows — same bytes, same parsed versions: vault
`3cbfdd86d1b45309…` = S089 body sha (2.2.1); openbao `a54d1a5314ca7016…` =
S090 (2.7.2); python `9ba8856e586659ab…` = S091 (3.15.2); sops
`47a224ad71435b7f…` = S033 (3.13.3). The three located quotes are present in
the committed capture bodies at the exact byte offsets the rows claim: S089
`<title>v2.2.1</title>` at 726 (body 297221 B), S090 `<title>v2.7.2</title>`
at 729 (body 543805 B), S091 `<title>Python 3.15.2</title>` at 1583 (body
3354 B) — matching the `source-fetches.tsv` `entry-title-byte-offset-726` /
`feed-item-title-byte-offset-1583` claims.

### 5.3 `corpus/stamps.tsv` was not re-pinned at the candidate

```
$ python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f --root .
STALE corpus/SOURCES.md
STALE corpus/source-fetches.tsv
REVISION_AUDIT: DRIFT (stale=2 missing=0 dropped=0 added=49 invalid=0)
```

Same command at BASE (a `git clone` of the lane checked out at `911ab51`):
`REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=49 invalid=0)`.
`corpus/stamps.tsv` still pins the BASE digests — `corpus/SOURCES.md` pinned
`b974504e40f250aa` vs actual `b8f502a174349e09` (STALE);
`corpus/source-fetches.tsv` pinned `664030780d163cc4` vs actual
`8609b0bd4a765486` (STALE). Consequence: `bash corpus/row-identity.sh
revision-added` returns `ROW_IDENTITY: SETUP (revision-audit --history
failed)` at the candidate, while at BASE it prints `ROW_IDENTITY:
revision-added count=49 sha256=5bc6507a8807280c5dc352e561e65b8beefdd71deeb30c67db0234238fe86412`.

### 5.4 The census row count moved without a ledger migration

`bash corpus/sources-census.sh` prints at the candidate
`SOURCES_CENSUS: CLEAN (rows=91 A=87 B=2 C=2 queued=1 mined=87 rejected=3 entries_sourced=14 legacy=21 captures=91 inrow=16 inrow_only=0 inrow_nonreproducing=12)`
and at BASE `… (rows=88 A=84 … captures=88 …)`. Four ledger rows still expect
the BASE string verbatim (`R21-02`, `R31-02`, `R33-02`, `R34-03`), so
`bash corpus/claim-ledger.sh verify` reports all four as `FAIL … reason=verdict-not-final exit=0`.
The fleet census is fine at the candidate (`scripts/sources-census.sh validate
--root /home/vgpnk/Projects/shokunin kagi` → exit 0, `kagi ok
…/corpus/SOURCES.md`, 19 W04 lines = the 16 pre-existing plus the three new
cross-scope duplicates the lesson records). The pre-existing ledger failures
are **not** candidate-caused: `R11-08` (`CITATION_GATE: BROKEN … unresolved=5`)
and `R25-02` (`SELF_COUNTS: POLICY (claims=63 …)`) fail identically at BASE —
the citations gate's 5 unresolved paths are all pre-existing
`corpus/lessons/round-3x-verifier-spotcheck.md` lines.

### 5.5 Round-37 documents cite paths that do not resolve in-lane

`plans/round-37.md` and `corpus/lessons/round-37.md` cite `CORPUS.md` (fleet
root, not the lane — exists at `~/Projects/shokunin/CORPUS.md`), and the lesson
cites `round-34/35/36-verifier-spotcheck.md` and `round-36.md` without the
`corpus/lessons/` prefix (all exist under that prefix). No missing-file defect;
recorded because the citation gate resolves paths literally.

## 6. Commands executed (all read-only; scratch under the seat root)

| command | exit | result |
|---|---|---|
| `git archive 9efcea7 \| tar -x -C $S` | 0 | candidate tree extracted |
| `grep -cP '…(releases\.atom\|/releases\|feed\.rss\|releases/)…' corpus/SOURCES.md` | 0 | `9` |
| `python3 survey.py . <receipt>` | 0 | counts 9 / 4 / 4 (full output `survey.out`) |
| `bash plans/round-37-c2.sh` (candidate / predeclaration `04489d4` extraction) | 0 / 0 | `0` / `3` |
| `bash corpus/sources-census.sh` (lane) | 0 | `CLEAN (rows=91 …)` |
| `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | 0 | `kagi ok …`, 19 W04 |
| `python3 corpus/release-clock.py --root .` | 0 | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 … fired=15 derived=15)` |
| `python3 corpus/release-clock.py --receipt observe-r37.json --receipt-sha cb96…` | 1 | `RELEASE_CLOCK: FAILED (observed=0 …)` |
| `python3 corpus/revision-audit.py --history c2cab35… --root .` (lane / BASE clone) | 0 / 0 | `DRIFT (stale=2 …)` / `CLEAN (stale=0 …)` |
| `bash corpus/row-identity.sh revision-added` (lane) | — | `SETUP (revision-audit --history failed)` |
| `bash corpus/claim-ledger.sh verify` / `citations` (lane, 180 s cap) | 124 / 1 | timeout; `BROKEN (unresolved=5 …)` — pre-existing |
| re-point experiments in scratch clones of `9efcea7` | 1 | 10 `DERIVATION`; see §5.1 |

## 7. Tools and files

No tool was installed or upgraded by this seat. No network fetch was
performed; every byte examined came from the lane's committed tree or from
the frozen receipt file. Files written by this seat (all under
`.ufo/waves/round-37/build/K37ScoutRegistry/`): `report.md` (this file),
`survey.py` (sha256 `9618eacebd8ada4d661b71a2af62f2e699471e8c009d51c527d70472806fa8b0`,
4296 B), `survey.out` (sha256
`d5cc1a667829627e53a98144f24e833d95722c5afb17c34236c651aaf6fed0e7`, 6251 B).
The seat's scratch root (`/fast/scratch/hyaku/kagi-r37/K37ScoutRegistry/`) was
removed before this report was written.

REGISTRY SURVEY: DONE
