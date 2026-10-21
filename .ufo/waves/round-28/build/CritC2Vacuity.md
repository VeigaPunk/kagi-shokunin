# CritC2Vacuity — does C2's feed-row binding just move the forgery one file over?

Seat: KagiR28.CritC2Vacuity-7 (critic, advice only). BASE `3553d499…` extracted read-only to
`.ufo/waves/round-28/sandboxes/CritC2Vacuity/base`; plan read at lane HEAD `b9a42c0` (`plans/round-28.md`).
Axes: calibration (primary), freshness. Artifacts: `sandboxes/CritC2Vacuity/{forge.py,fab.py,forge-results.json,fixtures/}`.

## Verdict
Yes, mostly. Against an adversary who can edit the repo, the binding only moves the trust anchor from one
author-written cell (`release-clocks.tsv` col 5) to another (`SOURCES.md` anchor cell, `cells[5]`, `corpus/release-clock.py:88`).
Both cells are stamped the same way (`corpus/stamps.tsv:8` SOURCES.md, `:78` release-clocks.tsv), so a stamp
migration is needed either way. What C2 actually buys is **detecting one-file drift**, which is real for calibration
(for example, an author bumps a tsv anchor and forgets the registry). It does not bind anything to evidence. Worse, the
cheapest forgery after the rule does not touch SOURCES.md at all (counterexample 1).

## Counterexamples (all in the sandbox, BASE clock + overlay rule; table + mirrored receipt, as the plan correction describes)
I tested two candidate implementations of the frozen rule. NAMED is `version_is_named(feed_anchor, anchored)`, the
idiom BASE already uses at `corpus/release-clock.py:341-346,566`. EXACT requires the feed anchor cell to name exactly
one version, and that version must equal `anchored`.

| fixture | BASE | NAMED | EXACT | census |
|---|---|---|---|---|
| control | CLEAN30 | CLEAN | CLEAN | CLEAN |
| G1–G4: lower every derived row on one feed (frozen shape) | CLEAN | FAILED 4/4 | FAILED 4/4 | CLEAN |
| B1–B4: G plus one `SOURCES.md` anchor-cell substitution (`3.13.3→3.13.2`, `2.2.0→2.1.0`, `2.7.1→2.7.0`, `8.23.0→8.22.0`) | CLEAN | **CLEAN 4/4** | **CLEAN 4/4** | CLEAN |
| M2: G2 plus append `; prior stable v2.1.0` to the S034 anchor | CLEAN | **CLEAN** | FAILED | CLEAN |
| **R1: S013/S022–S024 repointed to `feed_source_id=S037`, `https://curl.se/info`, 8.23.0** | CLEAN | **CLEAN** | **CLEAN** | CLEAN |
| R2: S040/S041 note gets `derived:`, repointed to stale sibling S036, 3.15.0 | CLEAN (derived=17) | CLEAN | CLEAN | CLEAN |
| A1: append a cloned feed row S044 (v3.13.2), repoint the SOPS rows | CLEAN | CLEAN | CLEAN | FAILED (SC_USEDBY_NOCITE, SC_FETCH) |

1. **The cheapest forgery after the rule is R1. It edits the table and receipt only, and SOURCES.md stays untouched.**
   The binding resolves through `feed_source_id`, and `feed_source_id` is itself a tsv cell. BADFEED
   (`corpus/release-clock.py:556-564`) only checks that the cited row is a non-on-release feed kind whose URL equals
   `feed_url`. Nothing checks that the feed belongs to the row's product. S037's scope says it serves "S029" only
   (`corpus/SOURCES.md:43`), and S034's says "S012, S013 and S022-S024" (`:40`).
   - R1's verdict line is byte-identical to control: `CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`.
   - That means it also satisfies ledger pin R25-04 (`corpus/claim-ledger.tsv:83`).
   - Unlike the lowering forgeries, R1 survives a live `--observe`. `observe_one` fetches `values["feed_url"]` and
     compares against `anchored_version` (`corpus/release-clock.py:769,789-799`), so curl's 8.23.0 reads not-fired.
     [INFERENCE from code; not run, because my item permits no network.]
   - Effect: four Vault-documentation clocks never fire on a Vault release. This is a freshness loss with zero
     calibration signal.
2. **"Edit both" (B1–B4) passes NAMED and EXACT and the source census.** The forged anchor cell now contradicts its own
   row's teaches quote (`“<title>v3.13.3</title>”`, `corpus/SOURCES.md:39`) and its capture quote and body digest
   (`corpus/source-fetches.tsv:76`, col 13 `<title>v3.13.3</title>`, col 10 `47a224ad…`). No gate compares them.
3. **A NAMED implementation is also defeated by appending a version inside one cell (M2).** EXACT closes this.
   However, the frozen predicate (plan lines 64-67, "EXACT when … name exactly that group's row ids") scores NAMED and
   EXACT identically (4/4 on G1–G4), so the frozen measurement cannot see the difference.
4. **Stale siblings (R2).** The binding uses whatever row `feed_source_id` names and ignores supersession: S039
   "supersedes S036" (`corpus/SOURCES.md:46`), yet S036 still binds. Any row can opt into the bypass, because
   `derived:` is a free-text prefix (`corpus/release-clock.py:565-566`). In this fixture only the ledger's `derived=15`
   pin (R25-04) notices.

## What the binding buys over the round-27 feed floor (honest credit)
- The feed floor (`corpus/release-clock.py:390-410`, `567-575`) only compares rows on one URL with each other. Moving
  the whole group together (G1, G3, G4) defeats it. G2 is the same, because S012's anchor `v1.21.x` is non-numeric and
  sets no floor (`corpus/release-clocks.tsv:9`).
- C2 catches all four one-file group moves. That is real error detection, and my measurements confirm 0/4 → 4/4 is
  reachable.
- It is not tamper evidence. Against an editor it adds one cell plus one stamp line, and those land inside the
  SOURCES.md stamp migration that every round already performs when it appends registry rows.
- Lowering forgeries were never durable anyway: a live `--observe` reads them as `fired`
  (`corpus/release-clock.py:797-801`). The forgery class that survives observation is repointing (R1), and C2 as frozen
  does not address it.

## Stronger correction available from local evidence (smallest safe change)
The retained feed bodies already exist at BASE and are digest-linked. The receipt `sha256` for each feed row equals
`source-fetches.tsv` col 10 and equals a committed body. For example, `e41bc579…` (S013/S034) is
`.ufo/waves/round-26/build/ClockS013-evidence/feed.atom`, and `cfa106be…` is `ClockS029-evidence/info.body`. My
sandbox indexes 664 retained files under rounds 25–27.

I measured two overlay rules beyond the frozen one:
- **BODY.** Re-parse the retained body that each feed receipt's `sha256` names with the clock's own
  `parse_latest_version` (`corpus/release-clock.py:715-760`). It must equal `parsed_version`. For a derived anchor,
  re-parse the body named by the feed row's capture digest; it must equal `anchored`.
  - Control: CLEAN.
  - Fails G1–G4, B1–B4, M2, R2 and A1.
  - R1 is still CLEAN, because the curl body really says 8.23.0.
- **SERVES.** A derived row's id must appear in its feed row's scope list (`S008-S011`, `S012, S013 and S022-S024`, …).
  - Control: CLEAN.
  - Fails R1 and R2.
  - Caveat: S039's scope (`corpus/SOURCES.md:46`) lists neither S040 nor S041. That is harmless only because they are
    not derived.
- **BODY+SERVES** closes every counterexample above except the residual below.

Residual tradeoff: the judge must accept this as a limit, not a fixable defect. With BODY, the cheapest passing forgery
fabricates a feed body: the real SOPS atom with `v3.13.3→v3.13.2` byte-replaced and committed. It also re-digests the
receipt, `source-fetches.tsv` col 10, and col 13, plus the teaches quote. `fab.py` shows that this passes NAMED, EXACT,
COH, BODY, SERVES and the census, all CLEAN. No offline rule defeats a writer of every file. Only a non-author live
re-fetch does. BODY raises the cost from editing one cell to forging and committing an upstream artifact.

A cheap partial check, COH (rows sharing a `feed_url` must record one `parsed_version` and `sha256`), catches G2, B2,
M2 and R2 with no SOURCES.md dependency, because S012 keeps observing 2.2.0 on the Vault feed. It misses the rest.

## Measurement defects (reported, not redefined)
- D1. The frozen fixture set (plan lines 61-67, "SOURCES.md untouched") only measures the one-file move. A
  0/4 → 4/4 result cannot show resistance to B, R or M; "EXACT 4/4" is satisfied by the M2-vulnerable NAMED rule.
- D2. [INFERENCE] Round 27's `c2-measure.py` defined EXACT as *all* finding lines equal to the expected set
  (`.ufo/waves/round-27/tools/c2-measure.py`, `findings == ["REGRESSED " + i …]`). If round 28's tool, which does not
  exist yet (`.ufo/waves/round-28/tools/` is empty), copies that, adding COH or BODY would emit extra findings on G2
  (FEED-INCOHERENT S012…, BODY-MISMATCH). The predicate would then punish the stronger rule. The plan wording
  ("typed derivation findings name exactly…") supports filtering by category; the tool should do that.
- D3. "located anchor" is ambiguous. It could mean the anchor cell (`cells[5]`) or the located capture quote
  (`source-fetches.tsv` col 13). The two agree at BASE and diverge only under forgery (B1). The implementer should name
  which one, or require both.

## Impacted axes
- Calibration: the claim "the declared value is bound to its pinned source, as QM21 binds numbers" overstates C2. The
  pinned source is another declaration. Call it a cross-declaration consistency check.
- Freshness: R1 silences on-release clocks durably and is unaffected by C2.

## Commands run (sandbox only; none in the lane checkout)
- `git -C <lane> rev-parse HEAD` → `b9a42c0…`, exit 0. `git archive 3553d499… | tar -x -C …/base`, exit 0.
- `python3 -B forge.py`, exit 0: 13 fixtures, each run as a BASE `release-clock.py --root F --receipt F/receipt.json --receipt-sha <sha>` subprocess (all exit 0 CLEAN at BASE), plus `bash corpus/sources-census.sh verify --root F` (exit 0 everywhere except A1, exit 1).
- `python3 -B fab.py`, exit 0: the fabricated-body forgery is CLEAN under every overlay rule; census exit 0.
- `sha256sum` over the BASE tree, to find the retained bodies that match the receipt and capture digests.

## Not checked
- No live `--observe` or network fetch. R1's survival under a live observation is inferred from code
  (`corpus/release-clock.py:767-801`).
- I did not run BASE `--selftest`, the ledger, stamps or `revision-audit.py`. Stamp and ledger effects are read from
  the pins (`corpus/stamps.tsv:8,77,78`; `corpus/claim-ledger.tsv:83`).
- I only read `revision-audit.py`, not ran it. Its findings are whole-file (`STALE`, `ADDED`, `DROPPED`,
  `HISTORY-NOT-TRACKED`; `corpus/revision-audit.py:362-387`), and I found no row-level immutability check for mined
  SOURCES rows, so an in-place edit of the S033 cell costs the same as a tsv edit. [Read only.]
- I wrote no production patch. The overlay rules are sandbox drafts, not candidate code.
- No tools installed.
