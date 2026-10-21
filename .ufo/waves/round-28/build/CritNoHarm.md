# CritNoHarm — attack on "no axis harmed" for round-28 C1/C2

Seat `KagiR28.CritNoHarm-7` (critic). BASE `3553d499577084a6c98d7078906017840bbf7b28`; all `path:line` are BASE.
No candidate C1/C2 code exists yet (no draft `release-clock.py` newer than the plan, `.ufo/waves/round-28/tools/` empty),
so I probed BASE code plus a minimal reference predicate (`sandboxes/CritNoHarm/probe.py`, `probe2.py`; outputs `probe.out`, `probe2.out`).

## Verdict

**"No axis harmed" holds on today's tree and today's upstreams, but with three declarable tradeoffs and one authority gap.**
The frozen control (CLEAN30, `plans/round-28.md:42-43`) and F1–F4/G1–G4 cannot tell apart policies that differ
on the inputs below, so the frozen counts will not catch these. None of them is a reject-level regression versus BASE.
H1 and H2 should be fixed or declared in `corpus/lessons/round-28.md`.

## Findings

**H1 (coverage, C1, medium tradeoff): the plan's per-entry wording throws away a feed that BASE observes correctly.**
`plans/round-28.md:19-23` says a feed entry token "must be canonical … otherwise the row or feed gets a typed finding". BASE
`parse_latest_version` takes the max over every stable entry (`corpus/release-clock.py:746-760`). Counterexample (E6): an OpenBao
Atom feed with entries `[v2.7.1, v2.07.0]`. BASE returns `2.7.1`, which gives `not-fired`, the correct answer. A policy that refuses the feed
whenever any entry is non-canonical gives a typed failure instead, which drops the observation for all six derived OpenBao rows
(`corpus/release-clocks.tsv:11-13,18,22-23`). A value-scoped policy avoids this. It types the feed only when a non-canonical
token is ≥ the canonical maximum, and otherwise uses the canonical max. Measured: it gives `2.7.1` on `[v2.7.1, v2.07.0]` and TYPED on
`[v2.7.1, v2.7.01]`, `[v2.7.01, v2.7.1]` and `[v2.7.1, v2.7.02]`. Under BASE the last two read `fired` (`2.7.01`, `2.7.02`). Value-scoping keeps F3 and F4
TYPED: `3.15.01` ties the canonical max and a 4301-digit component exceeds it. Exposure today is zero. Across 21 retained live
feed bodies (round-26 `build/Clock*` and today's `SrcFeed*`, `XTagHistory/raw`), BASE stable candidates contain 0 non-canonical
tokens, and no body contains any leading-zero dotted token at all. Upstream tag histories (`sandboxes/XTagHistory/*-tags.txt`)
also show 0 non-canonical stable tags: SOPS 0/45, Vault 0/246, OpenBao 0/30.
*Smallest safe correction:* make the C1 feed finding value-scoped, and name the feed and the offending entry. If L1 instead keeps
the per-entry policy, declare it as a limit ("one malformed historical entry blinds the whole feed for that run").

**H2 (operability/expansion, C2, low–medium tradeoff): rearming a single derived row now costs a duplicate-URL feed row.**
E5′ scenario: SOPS 3.13.4 ships. All four SOPS rows observe it as fired, and BASE stays CLEAN with fired=7. S009 alone is then rearmed
(anchor 3.13.4, not-fired). BASE: CLEAN. With C2, `DERIVED-UNBOUND S009`, because S033 names v3.13.3 (`corpus/SOURCES.md:39`).
The only fixes are:
(a) Edit S033 in place to v3.13.4. This flags the three un-rearmed siblings S008/S010/S011, which was measured.
(b) Open a superseding feed row for the same Atom URL. This is the S039 precedent and costs a W04 duplicate-URL warning
(`.ufo/waves/round-28/census-start.txt` lists `S039 duplicate url www.python.org/downloads/feed.rss`; census exit stays 0).
The rearm path BASE already supports therefore gains a mandatory registry step and a standing warning.
*Correction:* declare in the lesson and README that a derived rearm opens a superseding feed row (W04 expected), and that feed
rows bound by derived rows are never refreshed in place. History supports this convention: S033–S037 were touched only by
`82745e2` (round 25), and S036 was superseded by S039 rather than edited.

**H3 (calibration, C2, authority gap, not a regression): C2 binds to the less-pinned of two declared authorities.**
For each feed row there are two declarations of its version. One is the registry anchor cell (`corpus/SOURCES.md:39-43`, free text).
The other is the capture quote in `corpus/source-fetches.tsv:76-80` (`<title>v3.13.3</title>`, `raw-literal-v1`, pinned to the body
sha). E8: I rewrote S033's anchor cell to v3.13.0, lowered S008–S011 to 3.13.0 and mirrored the receipt. Result: BASE CLEAN, anchor-cell C2 CLEAN,
and `sources-census.sh verify --root <clone>` returns `SOURCES_CENSUS: CLEAN` (exit 0), even though the capture quote still says v3.13.3.
So a coordinated edit of the anchor cell defeats C2. The plan's term "located anchor" (`plans/round-28.md:52`) arguably means
the located capture quote. *Correction:* require the derived anchor to equal the single X.Y.Z named by both the anchor cell and the
feed row's capture quote. A mismatch between those two is itself typed.

**H4 (freshness, residual, not new harm): the CLEAN "repair" after an in-place refresh un-fires clocks.**
E3: Vault 2.2.1 ships and the table records it as fired (fired=7). Then S034's anchor is edited in place to v2.2.1. C2 flags S013 and S022–S024. That is correct,
because their binding is gone. E4: rewriting those four derived anchors to 2.2.1, which forces `not-fired`, is CLEAN under both BASE and
C2 and drops fired from 7 to 3 with no teaching re-verification. BASE accepts the same un-fire with *fewer* edits, so C2 is a
strict improvement here. It is a declared limit: C2 binds one author-editable cell to another. H3's correction narrows it.

**H5 (refuted): "new findings make default runs fail on a future legitimate upstream tag."**
The default run replays the byte-pinned round-26 receipt (`corpus/release-clock.py:495-499,1742-1747`, digest `:28`). No upstream tag
can reach it. `--observe` already exits 1 at BASE on *any* new legitimate release until the table is updated. E1 (Vault 2.2.1
receipt, table unchanged) gives 5× `RECEIPT-MISMATCH` and `FAILED`, via `:613-615` and `:1754`. A non-canonical newest tag is also already
exit 1 at BASE, through a `fired` receipt against a `not-fired` table. C1 changes the category to a typed one. It adds no new failure class.
After a legitimate canonical release with the table updated and historical derived anchors kept (E2), BASE and C2 are both CLEAN
(fired=7, C2 adds nothing). C2 never reads the observed version, so upstream releases cannot trip it.

**H6 (guarded): a naive strict anchor-canonicality check breaks the control.**
`S012 anchored_version=v1.21.x` (`corpus/release-clocks.tsv:9`). A "canonical X.Y.Z required" check on anchors flags S012 (E7). A check
limited to numeric-shaped tokens flags nothing. The frozen control CLEAN30, required at both revisions, catches this, so the harm only arises if an implementation is admitted
without the control.

**H7 (operability, pointer): the length bound must not depend on the environment.**
The ledger runs `python3 corpus/release-clock.py` without `-I` (`corpus/claim-ledger.tsv:83`), so `PYTHONINTMAXSTRDIGITS` and `-X int_max_str_digits` change whether
`int()` at `:380` and `:760` raises. [INFERENCE] The ledger host env decides F2/F4 behaviour unless the bound is a string-length check.
RevC1Bound (`.ufo/waves/round-28/build/RevC1Bound.md` F1/F2) measured this. I agree with its 640-digit, string-checked cap.

Bookkeeping, which is not harm: the selftest growth moves `claim-ledger.tsv:82` (79 cases), `self-counts.tsv:22,38` and `stamps.tsv:77-78` together.
The plan acknowledges this at `plans/round-28.md:82-84`. Derived count stays 15 on the control (E0: C2 adds no findings).

## Axis table

| axis | effect of C1/C2 as planned | status |
|---|---|---|
| freshness | C1 types leading-zero and oversize tokens. With value scoping, no correct observation is lost (H1). | improves; H1 tradeoff |
| calibration | C2 binds 15 derived anchors. It binds to the anchor cell, not the capture quote (H3). | improves; gap H3 |
| coverage/observation | Per-entry C1 refusal can blind 6 rows on one malformed lower entry (H1). Exposure is 0 today. | latent harm, avoidable |
| operability | Default run is unaffected (H5). Rearm costs a W04 row (H2). Bound must not depend on env (H7). | tradeoff, declare |
| expansion/adjacency | No new capability. In-lane consumers are the ledger, self-counts and SKILL/PROVINCE pins, all frozen-guarded. | neutral |
| depth | Control counts unchanged (E0 CLEAN30). | neutral |

## Commands (sandbox `.ufo/waves/round-28/sandboxes/CritNoHarm/`, never the lane checkout)

| command | exit |
|---|---|
| `git -C <lane> archive 3553d49 \| tar -x -C …/CritNoHarm/base` | 0 |
| `git -C <lane> log --format=%h 3553d49 -G '^\| S03[3-7] \|' -- corpus/SOURCES.md` (read-only) | 0 (only `82745e2`) |
| tag-history scan over `sandboxes/XTagHistory/*.txt` (python3 -I -B) | 0 |
| BASE `parse_latest_version` + candidate scan over 21 retained feed bodies | 0 |
| `python3 -I -B probe.py` (E0–E8) → `probe.out` | 0 |
| `python3 -I -B probe2.py` (E5′, E9) → `probe2.out` | 0 |
| `bash base/corpus/sources-census.sh verify --root work/e0-*` / `work/e8-*` | 0 / 0 (both CLEAN) |
| fleet-wide grep for `release-clock` outside the lane | interrupted (timed out), no result |

Host: CPython 3.14.8. No tools installed or upgraded.

## Status at close (L1 request: bounded finish)

All findings above are pinned to BASE `3553d49` plus my sandbox reference predicates. No candidate existed when I ran them.
I did **not** examine the repaired candidate `5e847472`. To verify H1–H3 against it:
- H1: feed the candidate `[v2.7.1, v2.07.0]` and confirm it is not refused as a whole feed.
- H2: confirm the lesson declares the superseding-row rearm path.
- H3: confirm the anchor cell and capture quote are cross-bound (rerun E8).

No further probes were run.

## Not checked

- Any real C1/C2 implementation or the frozen `c1-measure.py`/`c2-measure.py`, since none exist yet. The C2 predicate here is my reading
  (single distinct X.Y.Z in the feed row's anchor cell, equal after stripping `v`). Policies in H1 are reference variants, not L1's code.
- Live feeds. I fetched nothing and relied on peer-retained bodies and tag lists. Python and curl tag histories beyond the retained feed and info file were not checked.
- Adjacency outside the lane: the fleet grep was interrupted. Connector seats own that.
- Whether `claim-ledger.sh` sanitizes env (`env -i`) before running ledger rows (H7 is marked [INFERENCE]).
- Lane gates, selftests and the census in the lane checkout (not run, by contract). Selftest counts were not measured.
