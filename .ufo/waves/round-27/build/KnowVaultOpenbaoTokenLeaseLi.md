# KnowVaultOpenbaoTokenLeaseLi — C1 inventory + C2 freshness, `knowledge/vault-openbao-token-lease-lifecycle.md`

Seat: `KagiR26.KnowVaultOpenbaoTokenLeaseLi-17` (leaf scout; no dispatch, no production edits).
BASE: `0a47dd189356ea66ec83c3891eed54526e95b89b` (HEAD == BASE, verified with `git rev-parse HEAD`).
Target: `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` — 176 lines, 12404 bytes,
sha256 `4932f37f6e4bc0cf312f9d844b1ab215cb66248846664715515e0fa8d7b17298`; worktree bytes equal
`git show 0a47dd18:…` (identical sha256); `git status --porcelain` for the file empty; the stamp
row `corpus/stamps.tsv:51` carries the same sha/lines/bytes. No gate, selftest, ledger row,
release clock, formatter or host probe was executed; ledger pins were read as text.

## Verdict

**Zero in-population current-tense numbers about this lane's own artifacts.** No row for this
entry belongs in `corpus/self-counts.tsv`; every digit-bearing line falls in an excluded class.
The four nearest numeric candidates (`exit 1` at `:78`; `0`/`1` at `:89`; `3` at `:90`) are
regex-locatable with one capture group but are **dated 2026-10-19 observations** (a local grep
result and vendor-page text sweeps), not artifact present sizes. The two nearest spelled
candidates (`the five pages above` at `:4`; `Four clocks` at `:13`) fail on *representation*
(the binder captures only `[0-9]+`) and on *absent lane-local source*, not merely on judgment.
Adding a `KN-*` row here would need an invented source.

C2 freshness: four of this entry's five sources (S013, S014, S015, S016) are bound to strict
numeric anchors (`2.2.0`, `2.7.1`) and gain the REGRESSED refusal; S012's anchor is the
non-numeric `v1.21.x`, the exact declared limit named in `corpus/lessons/round-27.md:75-76`.
That limit is already recorded (`corpus/lessons/round-25.md:118-126`) and is mitigated by
numeric successors in the same domain (S022/S023/S024 at `2.2.0`, S025/S026 at `2.7.1`).
No freshness defect attributable to this entry was found.

This entry is a counterexample to "has digits ⇒ has bindable numbers": 131 digit tokens across
56 of 176 lines, none a lane-artifact count with a lane-local source. It is also a coverage
counterexample: the round-27 binder covers 7 of the lane's knowledge entries, not this one.

## Method

Rule applied: `corpus/QUALITY.md:118` (QM21) and the round-27 addition QM26
(`corpus/QUALITY.md:133` in the round-27 worktree), read with `corpus/lessons/round-25.md:49-58`
(R25-C6) and `corpus/lessons/round-27.md:37-67` (§C1 and the named debt). A number is CURRENT
when it states an artifact's present size with no newer value in the same clause; dated
measurements, Erratum/Evidence/Round-N history, host/substrate observations, positional case
indexes, vendor facts, and numbers with no lane-local pinned source are out.

I enumerated every digit token with `re.findall(r"[0-9]+", line)` over all 176 lines: **131
tokens on 56 lines**, then classified each line. Source forms allowed by
`corpus/self-counts.py:120-152`: `rows:<repo file>` (nonblank, non-comment data lines),
`ledger:<ID>` (the row's live last line), `expect:<ID>` (the row's committed pin, never
executed). A `ledger:` row carrying `[host]`/`[substrate]` is refused by the binder
(`corpus/self-counts.py:259-260`), which is why the ticket names `expect:` for those.

## 1. Binding rows (`corpus/self-counts.tsv` format) — none

```
id	doc	locator	source	extract	note
# (no rows: empty current-tense lane-artifact population for this entry)
```

That block is illustrative only: appending it verbatim would leave the table empty, and the
binder rejects an empty table (`corpus/self-counts.py:150-151`, `SETUP: empty binding table`).

At BASE `corpus/self-counts.tsv` has 38 data rows and no knowledge-entry block. The round-27
worktree adds 18 `KN-*` rows over 7 documents (`adjacency-breadth`, `adjacency-scope`,
`checklist-execution`, `claim-ledger`, `drift-gate`, `op-ref-consumption`, `surface-census`);
`grep -ni 'vault\|openbao' corpus/self-counts.tsv` is empty in both BASE and worktree. No
`rows:` source, no `ledger:` row and no `expect:` pin in the repo defines a quantity this
entry states, so there is nothing to bind and nothing to mark STALE/OK.

## 2. Candidate numbers examined, exact text and disposition

The `value/status at BASE` column reports what the entry says and whether it matches a
checkable quantity; `OUT` means out of the C1 population, with the class in the next column.
Locators were executed against the 176-line entry; "1 line" means exactly one matching line.

| line | exact text (fragment) | candidate quantity | class / disposition | value / status at BASE | one-group locator; match count |
|---|---|---|---|---|---|
| 4 | `verified-at: 2026-10-19 (the five pages above, fetched and read as tag-stripped text)` | source-page count = 5 | OUT: dated verification record ("2026-10-19"); spelled word; no `rows:`/`ledger:`/`expect:` source (see §3.1) | value is 5: `source:` names 5 distinct ids S012–S016 (S012 occurs twice, 6 occurrences); all 5 registry rows are `mined` and `used-by` this entry (`corpus/SOURCES.md:18-22`) | `the ([0-9]+) pages above` → **0 lines** (unbindable without a digit rewrite); `^verified-at: 2026-10-19 \(the five pages above` → 1 line, 0 groups |
| 13 | `## Four clocks a "short-lived" claim can mean (QA8)` | table row count = 4 | OUT: structural heading; spelled word; no live source; the table it heads is declared historical/defective at `:105-118` | 4 data rows at `:17-20` | `^## Four clocks` → 1 line, 0 groups; `^## ([0-9]+) clocks` → 0 lines |
| 33 | `- OpenBao 2.7.x (S014 §JWT verification): three methods — static keys, JWKS,` | vendor method count = 3 | OUT: vendor fact, not a lane artifact; spelled word | vendor claim (S014) | `three methods` has no integer to capture |
| 55 | `TTL (default 32 days, configurable), mount tuning, and the auth method's value;` | vendor default TTL | OUT: vendor fact | vendor claim (S016) | `default ([0-9]+) days` → 1 line, captures `32` |
| 78 | `→ no file, exit 1 (2026-10-19). Use this as a review checklist when a workload` | local sweep result `exit 1` | OUT: dated local measurement; unreproducible today (see §4) | recorded 2026-10-19; today the same command returns a file and exit 0 | `^→ no file, exit ([0-9]+) \(2026-10-19\)` → 1 line, captures `1` |
| 89 | `2026-10-19): "tokenreview" 0 in S012 and 0 in S014; "jwks pairs" 1 in S012, 0 in` | vendor-page text counts 0/0/1/0 | OUT: vendor page text, not a lane artifact; dated | not re-verified (no page fetch) | `"tokenreview" ([0-9]+) in S012` → 1 line, captures `0`; `"jwks pairs" ([0-9]+) in S012` → 1 line, captures `1` |
| 90 | `S014; "exactly match" 3 in S012, 0 in S014. Command, with `U` = page URL and` | vendor-page text count 3/0 | OUT: same class | not re-verified (no page fetch) | `"exactly match" ([0-9]+) in S012` → 1 line, captures `3` |
| 109 | `… Two sources, two products, not one fact.` | source/product counts 2/2/1 | OUT: round-21 erratum history; spelled words | historical | no integer; `Two sources, two products` → 1 line, 0 groups |
| 92 | `` `curl -sL "$U" \| python3 -c … ` `` | none (`python3` token) | OUT: command literal | — | not a quantity |
| 3, 5, 28, 33, 42, 49, 98, 99, 120, 163, 168 | `v1.21.x`, `2.7.x`, `Vault 1.17`, `2.x` | vendor version labels | OUT: vendor facts (explicitly outside C1) | vendor | not bound; version labels are not release counts |
| 3, 4, 78, 89, 120, 145 | `2026-10-19`, `2026-10-20` | dates | OUT: dates, not counts | — | — |
| 6, 7, 10, 17-20, 24, 30, 36, 40, 42, 44, 59, 65, 72, 86, 103, 107-110, 113, 115, 118, 125, 128, 138, 140, 144, 150, 154, 157-160, 166, 170, 172 | `S012`…`S026`, `R21-02`, `QA8`, `QA10`, `E3`, `round 21/22`, `Source14.md` | identifiers | OUT: IDs, round markers, paths; not quantities | — | — |

Line-level classification of all 56 digit-bearing lines (identifier/date/vendor/command
classes summarized above): 0 lines state a present-tense count, size, bound or membership of a
lane-owned file.

## 3. Nearest candidates in detail

### 3.1 `the five pages above` (`:4`)

- **Observed:** the `source:` line (`:3`) names S012, S013, S014, S015, S016 (distinct 5;
  `S012` appears twice). `corpus/SOURCES.md:18-22` marks all five `mined`, `on-release`, with
  `used-by` = this entry. So the number is *true* at BASE, but truth is not binding.
- **Why out of population:** (i) it is spelled `five`, and the binder's locator and extract
  must yield a nonnegative integer (`corpus/self-counts.py:110-124`; the TSV header line 2 of
  `corpus/self-counts.tsv`); (ii) no lane-local defining source exists in the allowed forms:
  `R21-02` pins aggregate census cells (`rows=43 A=41 … mined=39 … captures=43` in the
  round-27 worktree `corpus/claim-ledger.tsv:52`; `rows=41 … mined=37` at BASE), not a
  per-entry page count; `R14-01` pins `entries=25 row_linked=22 by_hand=3` (aggregate); a
  `rows:` source counts all data lines of one file, and no data file has 5 lines for this
  entry. The sources census checks presence/identity/used-by per cited id
  (`corpus/sources-census.sh:339-356`), never the length of the page list.
- **Residual risk (not a defect I can close):** adding a sixth source to `:3` would not fail
  any gate; `SC_ENTRY_CITE` would check the new id only. If L1 wants coverage, the entry needs
  the word rewritten as `5` **and** a new reviewed ledger row that defines a per-entry page
  count. No such row exists at BASE, and inventing one is L1's integration decision, not this
  seat's. Left out of population per QM26 (dated/verification metadata) and named here.

### 3.2 `Four clocks` (`:13`)

- The table has four data rows (`:17-20`), so 4 is structurally true; but the heading is a
  word, there is no live source (the only "source" would be the table counting itself), and the
  round-21 erratum declares the table a merged, defective reading, not an operational table
  (`:105-118`; round-22 erratum `:113-118`). The active corrected reading is
  `corpus/knowledge/feature-bound-credential-review.md:1-6` (pointer at this entry
  `:142-143`). OUT: Erratum history + no source + representation.

### 3.3 `exit 1` and the absence sweeps (`:78`, `:89-90`)

These are the only Arabic-digit results about lane-held text, and each is a dated observation,
not a present size:

- `:78` records a local grep result `→ no file, exit 1 (2026-10-19)`.
- `:89-90` record vendor-page text counts (`tokenreview` 0/0, `jwks pairs` 1/0,
  `exactly match` 3/0) under a dated tag-stripped/lower-cased profile.

Per QM21/QM26 they are history, not current numbers. The round-27 lesson already records the
local sweep as retained debt (`corpus/lessons/round-27.md:61-65`). See §4 for the concrete
non-reproduction; the vendor counts were **not** re-measured (no page fetch).

## 4. Counterexample: the dated sweep no longer reproduces

The entry's command (`:76-77`), run read-only on the current tree:

```
grep -rliE 'sops|openbao|hashicorp' corpus/knowledge \
  --exclude=sops-age-key-rotation.md --exclude=vault-openbao-token-lease-lifecycle.md
```

returns `corpus/knowledge/feature-bound-credential-review.md` and **exit 0**, not the recorded
`no file, exit 1` of 2026-10-19. The matching entry was added in round 22 (`verified-at:
2026-10-20`, see its `:2-6`) and mentions OpenBao; the entry's `--exclude` list predates it.
The recorded result was true on 2026-10-19; it is not a current fact, and the lead-in
`kagi runs neither product:` is present tense while its evidence command is not reproducible.

Advice (no production edit made): keep the date and treat it as a receipt (it is already
dated), or re-run with the added `--exclude=feature-bound-credential-review.md` and re-date.
Do **not** put this in `self-counts.tsv`: it is a QM10 absence claim about corpus text, not an
artifact size. The round-27 lesson's debt note (`:61-65`) remains accurate.

## 5. C2 freshness for this entry's sources

The entry's prose is not clock input: `corpus/release-clock.py` binds each
`corpus/SOURCES.md` row whose `recheck` is exactly `on-release` to exactly one
`corpus/release-clocks.tsv` row (`corpus/release-clock.py:509-521` in the worktree; the same
structure exists at BASE), and the row must name a feed that is itself a registry row. For this
entry that is:

| entry source | clock row | feed (registry row) | anchor | observed | verdict | numeric anchor? | C2 after behavior |
|---|---|---|---|---|---|---|---|
| S012 | `corpus/release-clocks.tsv:9` | S034 `…/hashicorp/vault/releases.atom` (`corpus/SOURCES.md:40`) | `v1.21.x` | `2.2.0` | `fired` | **no** (`numeric_version` returns `None`, worktree `corpus/release-clock.py:369-379`) | a below-`v1.21.x` observation still reads `fired`/CLEAN — declared limit, not REGRESSED |
| S013 | `:10` | S034 | `2.2.0` | `2.2.0` | `not-fired` | yes | observation `< 2.2.0` → `REGRESSED`, exit 1 (worktree `:542-547`) |
| S014 | `:11` | S035 `…/openbao/openbao/releases.atom` (`corpus/SOURCES.md:41`) | `2.7.1` | `2.7.1` | `not-fired` | yes | observation `< 2.7.1` → `REGRESSED` |
| S015 | `:12` | S035 | `2.7.1` | `2.7.1` | `not-fired` | yes | same |
| S016 | `:13` | S035 | `2.7.1` | `2.7.1` | `not-fired` | yes | same |

- **S012 is the named limit, already recorded.** `v1.21.x` is the round-27 lesson's own
  non-numeric example (`corpus/lessons/round-27.md:75-76`), and the stale anchor was recorded
  with its 2.2.0 observation in round 25 (`corpus/lessons/round-25.md:118-126`). It is not a
  new defect, and the entry's teaching was re-verified on the served v2.x page in that round.
  **Mitigation in the same domain:** the Vault JWT/lease/served-route domain also has numeric
  successors S022 (2.2.0, `corpus/release-clocks.tsv:19`), S023 (2.2.0, `:20`) and S024 (2.2.0,
  `:21`), and OpenBao has S025/S026 (2.7.1, `:22-23`). A cropped Vault or OpenBao feed below
  those anchors is therefore caught as REGRESSED even though S012's own row stays
  inequality-only. The limit is real (S012 alone would not catch it) but not unmitigated.
- **BASE accepted the downgrade; the after rule refuses it.** At BASE, the fired branch is
  `norm_version(observed) != norm_version(anchor)` with no ordering (`corpus/release-clock.py`
  BASE `:524-527`; observe at BASE `:730-734`). The recorded BASE measurement
  (`.ufo/waves/round-27/c2-before.json`, read but not re-run) has a single-row downgrade lie
  (S040 3.15.0 < 3.15.1) and a whole-feed rollback both ending `RELEASE_CLOCK: CLEAN`, exit 0
  (fired=4 and fired=3). After, `is_regression` (worktree `:382-386`) gates the row
  (`:542-547`) and the observe path types it `regressed` (`:762-763`). For S013–S016 this is
  the exact behavior change; for S012 it cannot apply by construction.
- **The entry's `recheck:` prose** (`:5`) names "a Vault or OpenBao release" but no feed; the
  observable release identity is supplied by S034/S035 through `release-clocks.tsv`. The
  entry's "compare the docs `Version` label to 2.7.x" is human prose: the machine clock
  observes the S035 feed (`2.7.1`), not the docs label. No QM23 defect at the clock level; a
  docs-label-only move without a release would not fire any clock, which is a declared scope
  of the feed clock, not a number this entry states.

No freshness defect attributable to this entry's knowledge text was found.

## 6. Binder blindness (acceptance consequence)

`corpus/self-counts.py:315-326` reads only documents named by table rows. BASE has 38 data
rows; the round-27 worktree has 56, of which 18 `KN-*` rows cover 7 entries. No row names this
document. Consequence (INFERENCE from the code path, **not executed**): a one-digit mutation
anywhere in this entry leaves `SELF_COUNTS: CLEAN`. The plan's one-digit mutation demonstration
(`corpus/lessons/round-27.md:86`, M27-2) is therefore shown on `KN-LEDGER-REPRO-SELFTEST`, not
on this entry. That is consistent with an empty population, but it means this entry's dated
counts and exit code are unguarded: the 2026-10-19 sweep can drift (and has, §4) with no gate.

## 7. What I did NOT check (unrun ≠ pass)

- Did not run `corpus/self-counts.py`, `c1-measure.py`, `c2-measure.py`, the claim ledger, the
  sources census, or the release-clock selftest; no gate receipt exists from this seat.
- Did not fetch any vendor page (no HTTP at all), so the `0/1/3` sweep counts, the quoted
  S012/S014/S015/S016 text and the "Version 2.7.x" labels were not re-verified.
- Did not contact Vault, OpenBao, a vault, an account, a handler or CDP; no deployment/probe.
- Did not audit the other knowledge entries, the stamp/declaration counts, or the round-22
  errata's vendor claims.
- Did not verify that `feature-bound-credential-review.md` semantically covers the same ground
  beyond reading its header and first 40 lines; §4's counterexample rests on the command's
  observed result (file + exit 0), not on a content equivalence claim.

## 8. Confidence

- **OBSERVED:** file identity at BASE and stamp match; 131 digit tokens on 56 lines; zero
  `rows:`/`ledger:`/`expect:` source for any lane-artifact quantity in this entry; five
  distinct cited ids, all mined/used-by; clock rows, anchors, observations and verdicts;
  BASE-vs-worktree release-clock code paths; the dated sweep now matching
  `feature-bound-credential-review.md` (exit 0); no `KN-*` row for this doc.
- **INFERENCE:** the population judgment (excluded classes); binder blindness; mitigation of
  S012's non-numeric anchor by numeric successors (read from the table, not executed).
- **UNKNOWN / left open:** whether L1 wants `five pages` digitized and bound with a new row;
  whether the round-21/22 erratum should rewrite the `Four clocks` heading (it already demotes
  the table); whether a future round re-anchors S012 numerically instead of relying on S022.

Tool installs/updates this seat: none.
