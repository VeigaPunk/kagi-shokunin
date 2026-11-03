# SRegistryRows — C3 registry + index drafts (round 30, kagi-shokunin)

Seat: scribe. Scope: C3 registry rows and index/coverage-map drafts for the
secret-scanning adoption. Production files were NOT edited by this seat; the L1
is the sole integration writer. All drafts live under
`.ufo/waves/round-30/final/c3/registry/`.

## 0. Outcome in one line

The 8-row append block is **already landed byte-identically** in the lane
(commit `064d4b6`); the three index surfaces (README coverage-map row, README
`## Frontier` bullet, PROVINCE Core bullet) are also landed, and the L1 has since
landed the four drafts in §3 verbatim — my three per-entry README index rows, my
README `## Frontier` replacement bullet, and my `corpus/SOURCES.md` round-30
lead-disposition paragraph. **The two live gaps I found in the landed tree
(§4.1, §4.2) are therefore closed.** This report gives the exact paste-ready
text, the per-row used-by set, and the counterexamples that shaped the landing.

## 1. Append block (lands at END of the `## Registry` table)

Source of truth: `.ufo/waves/round-30/final/c3/assimilation/normalized-rows.md`
(XAssimCol). I verified the block independently before adopting it:

| check | result |
|---|---|
| 8 rows, ids S053–S060, no id collision with the lane's S001–S052 | PASS |
| 11 columns each (`awk -F'|'` NF==13) | PASS |
| no `\|` inside any cell | PASS |
| `kind` in the contract enum (`tool`/`code`/`docs`) | PASS |
| `status` = `mined` on every row | PASS |
| `opened` = `2026-11-03` on every row | PASS |
| `recheck` = bare cadence (`180d`×7, `90d`×1), prose stripped | PASS |
| `used-by` = exactly one `corpus/knowledge/*.md` path per row | PASS |
| tier | A×7 (S053–S059), B×1 (S060 — the notify-results switch) |
| placement | after S052, before `## Paths` — the end of the Registry table, ids in order |

**Landed-vs-draft: zero diff.** A row-by-row comparison of the lane's
`corpus/SOURCES.md` against `normalized-rows.md` reports IDENTICAL for all 8
rows. The exact block is in `final/c3/registry/append-block.md`.

## 2. Used-by set per row (derived, then verified against the landed entries)

The census `src_field` is the first column-1 `source:` line plus its
whitespace-led continuations — so `used-by` must match the **source field**, not
the whole file. Measured on the landed entries:

| new id | staged id | used-by | entry source-field ids |
|---|---|---|---|
| S053 | S066 | `corpus/knowledge/secret-scanning-detection-vs-validation.md` | S053 S054 |
| S054 | S067 | `corpus/knowledge/secret-scanning-detection-vs-validation.md` | S053 S054 |
| S055 | S068 | `corpus/knowledge/betterleaks-detection-vs-validation.md` | S055 S056 |
| S056 | S069 | `corpus/knowledge/betterleaks-detection-vs-validation.md` | S055 S056 |
| S057 | S070 | `corpus/knowledge/trufflehog-verification-lifecycle.md` | S057 S058 S059 S060 |
| S058 | S071 | `corpus/knowledge/trufflehog-verification-lifecycle.md` | S057 S058 S059 S060 |
| S059 | S072 | `corpus/knowledge/trufflehog-verification-lifecycle.md` | S057 S058 S059 S060 |
| S060 | S073 | `corpus/knowledge/trufflehog-verification-lifecycle.md` | S057 S058 S059 S060 |

Each row's used-by is exactly the entry whose source field names it, and each
entry's source field names only rows that list it back. **No id in the landed
three entries is dangling**: every `Snnn` in the three files resolves to a
registry row (checked individually against `corpus/SOURCES.md`).

Full derivation with citing-site line numbers: `final/c3/registry/used-by.tsv`.

## 3. Index drafts (exact paste-ready text)

`final/c3/registry/index-drafts.md` holds all four. Summary:

1. **README coverage-map row** (landed at `corpus/README.md:68`) — one row,
   three entry paths, source basis "S053–S060, re-opened 2026-11-03". Matches
   the multi-path rows already in that table.
2. **README index rows, one per new knowledge entry** — three rows in the
   per-entry house style (like the round-21 area rows). NOT landed: the landed
   README has only the combined row (1), so each new entry file is not
   individually indexable by path. See §4.2.
3. **README `## Frontier` bullet** — the secret-scanning bullet must move out of
   "Areas being explored, not held as lane knowledge". See §4.1 (live
   contradiction).
4. **PROVINCE Core bullet** (landed at `PROVINCE.md:88`) — one line, same three
   entries, dated round 30, OIDC and NIST frontier bullets untouched.

## 4. Findings — counterexamples and gaps

Status note: §4.1 and §4.2 were live gaps in the landed tree when I found them;
the L1 has since landed both fixes (my drafts, verbatim). §4.3 and §4.4 are
recorded as the evidence for why the landing looks the way it does.

### 4.1 (CLOSED) the README `## Frontier` bullet said the lead was unopened

`corpus/README.md:114` read (now replaced by my draft):

```
- **Secret scanning: detection versus verification** — adjacent to the hygiene tripwires in chousa, kasegi, and kumitate; see `SOURCES.md` §Leads (unopened), Gitleaks/Betterleaks and TruffleHog.
```

It sits under "Areas being explored, **not held** as lane knowledge", and its
pointer `SOURCES.md §Leads (unopened), Gitleaks/Betterleaks and TruffleHog` is
now false on two counts: those three are opened as S053–S060, and the §Leads
bullets still claim them as "leads only, not evidence"
(`corpus/SOURCES.md:103-104`). The landed PROVINCE Core bullet says the lead
moved to core; the README index says the same. Only this Frontier bullet
disagrees, and it is the one a reader lands on when asking "is this held or
explored?". The lesson (L126) records the choice as deliberate — "Frontier
bullets in PROVINCE and README keep their history" — but PROVINCE's own Core
bullet reconciles it in the same breath ("The frontier bullet below keeps its
history"), whereas README's has no such reconciliation and its pointer is
actively wrong.

**Recommended fix** (draft 2 in `index-drafts.md`): replace the bullet so the
lead is marked moved-to-core and the stale §Leads pointer is dropped. The OIDC
and NIST bullets stay byte-identical, as the plan requires.

`corpus/SOURCES.md` §Leads additionally has **no round-30 lead disposition
paragraph**, while round 28 (L111) and round 23 (L119) both closed their opened
leads with one. Draft 4 in `index-drafts.md` supplies a matching paragraph.
Not required by the plan text — a consistency recommendation.

### 4.2 (CLOSED) README index rows for the three new entries were missing

`corpus/README.md` is the corpus **index** (title line 1: "kagi-shokunin corpus
— index"), and every other knowledge entry has its own row there. The three new
entries are reachable only through the one combined row, which lists three
paths — so `grep 'knowledge/secret-scanning-detection-vs-validation.md'
corpus/README.md` hits one multi-path row rather than the per-entry row the
other 25 entries have. The `| Feed-token boundaries |` case is the same shape:
that entry is the one existing file with no README row at all.

Draft 2 in `index-drafts.md` supplies the three per-entry rows. This is the
part of my brief ("add index rows for the three new knowledge entries") that is
not yet satisfied by the landed tree.

### 4.3 The staged package as shipped FAILS the lane census — 16 findings

This is the load-bearing counterexample against "just append the staged rows".
Measured on the staged package exactly as delivered
(`.ufo/waves/round-30/final/c3/assimilation/`), reproduced here in a scratch
mirror:

- **8 × `SC_ENTRY_HEADER` "multiple source: lines"** — the staged entries carry
  2, 2 and 4 column-1 `source:` lines. The census `src_field` reads only the
  first line plus whitespace-led continuations, so the extra ids were invisible:
  S054, S056, S058, S059, S060 raised `SC_USEDBY_NOCITE` (their used-by file
  did not cite them), and every entry with 2+ source lines raised
  `SC_ENTRY_HEADER`.
- **8 × `SC_FETCH` "missing-provenance"** — no capture row in
  `corpus/source-fetches.tsv` for any of the 8 ids. The census requires a
  capture row for every mined row without an in-row pin, and in-row pins are
  historical-only (S001–S016); a non-historical row carrying `Fetch sha256:`
  raises `SC_INROW` "inrow-pin-not-historical".

Verdict with the append alone and nothing else: `SOURCES_CENSUS: FAILED
(findings=16 rows=60)`. The landed tree has 8 capture rows and merged source
lines, and measures `SOURCES_CENSUS: CLEAN (rows=60 A=57 B=1 C=2 queued=1
mined=56 rejected=3 entries_sourced=8 legacy=21 captures=60 inrow=16
inrow_only=0 inrow_nonreproducing=12)` — exit 0. **The landed state is
correct; the staged package was not landable as shipped.** The lesson records
this as M30-7.

### 4.4 Six of eight campaign anchor digests no longer reproduce

Measured in-round, 2026-11-03, `curl -fsSL --compressed` with the lane's
declared UA:

| row | campaign pin | today | reproduces? |
|---|---|---|---|
| S053 | `65e87e68f4a16aef` | `65e87e68f4a16aef` | YES (at pinned commit `b58d3f10`, and at `master` HEAD `5f6ec56c`) |
| S054 | `068fbb5c93eb993d` | `7cf6efb50ab89234` at `main` HEAD | only at the pinned commit `d6ea4a52`; `main` moved (one README line: "spaces" → "spaces and buckets") |
| S055 | `f61c3993fd48dfb9` | `f61c3993fd48dfb9` | YES |
| S056 | `0c8bdbd04508489c` | `7387064618752b50` | NO — GitHub search API is per-IP rate limited and the response moved (stars 2322 → 2774, push date 2026-10-22 → 2026-11-03) |
| S057 | `b1eb8215a66933f9` | `0beb84fec97fa0ac` | NO |
| S058 | `aef5f76a64c9565a` | `2c85abe9e3f842a7` | NO |
| S059 | `2997de910834f751` | `b4790c43398da9db` | NO |
| S060 | `417032af5635ef39` | `8c0a977c75286c17` | NO |

The S057–S060 pages are byte-stable across three consecutive fetches today, so
this is real content drift since 2026-10-23, not fetch noise. **No quote
contradicts its staged claim**: every staged quote locates verbatim in today's
body (rendered-text-v1 `locate` count=1 for all of S053/S054/S055/S057/S058/
S059/S060; S058's `sendUnverified`-style needles match 2 lines as the staged
recheck prose predicted), and the page stamps still hold (S057/S059 "Updated
06 Jul 2026", S060 "Updated 14 Aug 2026"). The four drifted rows are the
TruffleHog vendor pages, whose representation class is
`decoded-http-body-volatile-v1` — a digest is a point attestation, never a drift
pin; quotes and anchors are the content check.

The lane's anchor cells still carry the campaign pins **on purpose** (lesson
L119-120 records this), and the in-round capture rows carry the 2026-11-03
digests. I flag it because a reader comparing the row's anchor digest to the
capture row's digest will see two different values with no in-row marker
explaining which is load-bearing; the lesson does explain it, but the row does
not. The `S056` star count and push date in the anchor (2322, 2026-10-22) are
campaign-era and now stale against today's API — the entry's body labels them
as such.

## 5. Gates — measured, not asserted

All run on this host (Linux/Arch, python3 3.14.8), 2026-11-03:

| gate | result |
|---|---|
| `bash corpus/sources-census.sh` (landed lane) | `SOURCES_CENSUS: CLEAN (rows=60 A=57 B=1 C=2 queued=1 mined=56 rejected=3 entries_sourced=8 legacy=21 captures=60 inrow=16 inrow_only=0 inrow_nonreproducing=12)` exit 0 |
| C3 counting cmd 1: `grep -cE '^ {0,3}\|\|[[:space:]]*S(05[3-9]\|060)[[:space:]]*\|' corpus/SOURCES.md` | `8` |
| C3 counting cmd 2: `ls corpus/knowledge/{secret-scanning-detection-vs-validation,betterleaks-detection-vs-validation,trufflehog-verification-lifecycle}.md` | 3 files present |
| C3 counting cmd 3: `bash corpus/sources-census.sh` | see row 1, exit 0 |
| fleet `scripts/sources-census.sh validate --today 2026-11-03 <lane>` | exit 0, **0 E-codes** (W04 duplicate-URL warnings only, pre-existing) |
| fleet `scripts/sources-census.sh validate --today 2026-11-03 --file <SOURCES.md>` | exit 0, `file ok` |
| `bash corpus/claim-ledger.sh docs` (landed lane) | `DOC_AUDIT: CLEAN (entries=29 row_linked=26 by_hand=3 undeclared=0 missing_ids=0 unpinned=0 duplicate_reasons=0)` exit 0 |
| `python3 corpus/self-counts.py` (landed lane) | 8 STALE cells — **C1's migration surface, not C3's** (see §6) |
| `bash corpus/claim-ledger.sh citations` — my 3 drafted README index rows, A/B measured on two scratch mirrors of the same HEAD tree (only difference: my 3 rows) | baseline `cites=1889 unresolved=58`; with my rows `cites=1892 unresolved=58` — **+3 cites, +0 unresolved**. The gate is BROKEN in a lone clone either way (R11-08's pre-existing FLEET-ABSENT/lone-clone state, routed by the plan), so this is a delta measurement, not a pass claim. All three `knowledge/*.md` shorthands resolve against `corpus/knowledge/`. |

Scratch-mirror counterexamples I ran to establish the counterexamples above
(scratch tree only; lane untouched):
append alone, no capture rows, staged entries as shipped → 16 findings; staged
entries with merged source lines but no capture rows → 8 findings; merged source
lines + 8 capture rows + `Reverify:` + stamps → CLEAN, rows=60.

Measurement hygiene note: my first A/B citation comparison was **invalid** — a
Python bug wrote the rows as a string instead of a list, so the "with my rows"
tree received a mangled 1009-line README and the two runs coincidentally
matched. I rebuilt the mirror with an insertion assertion (unique anchor,
row present, line count 244→247) and re-ran; the numbers above are from the
corrected run. Flagging it because an unasserted A/B measurement that reads
"identical" is exactly the shape that hides a bug.

## 6. Coupling to C1 — the honest boundary

C3's landing moves four numbers that C1's migration must read at the measured
revision. Measured on the landed lane (post-C3) vs BASE:

| cell | BASE claim | BASE live | post-C3 live | whose |
|---|---|---|---|---|
| stamps rows | 91 | 94 | 97 | C1 (R12-03 / PV-STAMPS / RD-STAMPS / SC-SKILL-STAMPS) |
| ledger rows | 65 | 67 | 67 | C1 (R21-04 / PV-CLAIMS / RD-LEDGER-ROWS / SC-SKILL-CLAIMS) |
| docs entries | 25 | 26 | 29 | C1 (R14-01 / RD-DOCS-ENTRIES) |
| docs row-linked | 22 | 23 | 26 | C1 (R14-01 / RD-DOCS-ROWLINKED) |

C3 moves entries 26→29 and row-linked 23→26 (the three new entries, each
`Reverify: R21-02`), and stamps 94→97 (the three new entry files). It does **not**
move the ledger row count. The landed commit already carries the migrated README
cells ("26 row-linked / 3 by-hand / 29 pinned", "99 rows" stamps, "68 rows"
ledger). C1's remaining work is the ledger/expectation pins; C3 did not touch
them. **`self-counts.py` still reports 8 STALE cells on the landed lane** — that
is C1's open surface, and my seat did not migrate it.

Note the plan's "causally separable" claim for C1 is only true for the byte
surface. C3 *does* change three of the numbers C1's migration reads
(entries, row-linked, stamps), so C1's R14-01/R12-03 expectations must be
measured at the post-C3 revision, not at BASE. My measured post-C3 values are in
the table above.

## 7. Used-by / SOURCES.md cell changes

The plan asks for used-by back-references for adopted rows to be logged old→new
in the lesson. Measured: **no existing row's used-by cell changed.** The three
new rows are new; S048 (GitHub secret scanning) keeps `used-by =
corpus/lessons/round-28.md`. The secret-scanning entry mentions S048 in its
**body** (line 69, "an opened-but-unwritten row (S048)") and not in its source
field, so it creates no used-by obligation — the census agrees (CLEAN).
This is recorded in the lesson's C3 section.

## 8. Artifacts written by this seat

- `.ufo/waves/round-30/final/c3/registry/append-block.md` — the 8-row block + verification table
- `.ufo/waves/round-30/final/c3/registry/index-drafts.md` — README ×2, PROVINCE ×1, SOURCES.md lead disposition ×1
- `.ufo/waves/round-30/final/c3/registry/used-by.tsv` — per-row used-by set + citing sites
- `.ufo/waves/round-30/final/c3/registry/capture-rows.tsv` — my independent 8 capture rows, built from my own 2026-11-03 fetches. **Superseded by the landed `corpus/source-fetches.tsv`** and kept only as the independent-reproduction receipt: 7 of 8 digests and all 8 revisions are byte-identical to the landed rows; S056 differs (`7387064618752b50` mine vs `b7e19953ecde88d0` landed) because that GitHub search response is volatile per fetch — its star count moved 2772 → 2774 → 2776 across three fetches today. Both are point attestations of the same representation class; the landed row is authoritative and the census accepts it (it recomputes the row-identity digest, not the body digest).
- `.ufo/waves/round-30/SRegistryRows-report.md` — this report
- `.ufo/waves/round-30/build/SRegistryRows.md` — same content at the task's `Report:` path

Scratch: `/fast/scratch/hyaku/kagi-r30/SRegistryRows/` (mirror trees `crlf/`,
`nocap/`, `fetch/`); removed on exit per the seat contract.

## 9. Tools

No installs. No pacman transaction (host-wide pacman is paused). Used only what
the host already had: `bash`, `awk`, `grep`, `sed`, `python3` 3.14.8,
`curl` (public documentation GETs only), `sha256sum`, `git archive`/`git show`
(read-only). No `op` call beyond nothing at all — no vault/account/handler/CDP
contact. No lane git mutation by this seat (`git log`/`show`/`diff` read-only;
the one commit `064d4b6` is the L1's).
