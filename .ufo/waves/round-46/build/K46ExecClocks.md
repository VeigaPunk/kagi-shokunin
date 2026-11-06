# K46ExecClocks — C2 candidate draft: release clocks rebound and re-observed live

Scope: C2 (freshness) candidate draft only, built in scratch
`$HYAKU_SCRATCH/kagi-r46/K46ExecClocks` from predeclaration `44808ced…`. The lane tree was
not edited; nothing was committed. Frozen predicates/targets/kill rules untouched.

## Files changed (draft; mirror the lane paths)

| Path | Change |
|---|---|
| `corpus/release-clocks.tsv` | S040 and S041 clock rows retired (their registry rows are no longer `on-release`; recheck `2026-11-05` since round 39); S098 appended as a `rendered-quote` clock (declared capture quote, `raw-literal-v1`); all 29 on-release rows synced from the new receipt |
| `corpus/release-clock.py` | `DEFAULT_RECEIPT_SHA256` → `e7a2769…7413`; `receipt_path` default → `.ufo/waves/round-46/final/observe-r46.json`; `--receipt` help text names the round-46 default and keeps round-36 citable |
| `.ufo/waves/round-46/final/observe-r46.json` | new live receipt, 29 records, sha256 `e7a2769586056b09cd6f826ec15bb776bf564ff4a1ac36617e7aadeaad207413`, 10575 bytes |
| round-36 receipt | untouched (history, still citable with `--receipt/--receipt-sha`) |

Artifacts: `.ufo/waves/round-46/build/K46ExecClocks/{release-clocks.tsv, release-clock.py,
observe-r46.json, release-clock.diff, skill-lines.md, receipts.txt}`.

## Behavior, measured

| Check | Command | rc | Last line |
|---|---|---|---|
| BASE gate | `python3 -B corpus/release-clock.py --root $S/base` | 1 | `RELEASE_CLOCK: FAILED (on_release=29 bound=28 unbound=1 observed=28 fired=13 derived=15)` — ORPHAN S040/S041, RECEIPT-MISMATCH S040/S041, UNBOUND S098 |
| Observation | `python3 -B corpus/release-clock.py --root $S/tree --observe .ufo/waves/round-46/final/observe-r46.json` | 1¹ | `RELEASE_CLOCK_OBSERVE: wrote 29 observations (failed=0 fired=13 regressed=0) …` |
| Default gate | `python3 -B corpus/release-clock.py --root $S/tree` | 0 | `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)` |
| PINNED gate | `… --receipt .ufo/waves/round-46/final/observe-r46.json --receipt-sha e7a2769…` | 0 | same CLEAN line |
| Self-test | `python3 -B corpus/release-clock.py --selftest` | 0 | `RELEASE_CLOCK_SELFTEST: PASS (116 cases)` |
| C2 counter (candidate) | `C2_TREE=$S/tree bash plans/round-46-c2.sh` | 0 | `C2_FRESH_CLOCKS: value=29 fresh=29 default=1 pinned=1 kept=1 (… missing=none)` |
| C2 counter (BASE) | `bash plans/round-46-c2.sh f5977284…` | 0 | `C2_FRESH_CLOCKS: value=0 fresh=0 default=0 pinned=0 kept=1` |
| Quote-locate | `python3 -B corpus/quote-locate.py --root $S/tree` | 0 | `QUOTE_LOCATE: CLEAN located=8 rows=8` |
| Fleet census | `bash scripts/sources-census.sh validate --file $S/tree/corpus/SOURCES.md` | 0 | `file ok …/SOURCES.md` (W04 only) |
| Lane census | `bash $S/tree/corpus/sources-census.sh --root $S/tree` | 1 | `SOURCES_CENSUS: FAILED (findings=3 rows=102)` — identical to the unedited predeclaration tree |

¹ The observe invocation prints its own observe line and then the default-mode verdict, which
still read the round-36 receipt at that instant; its rc 1 is that stale binding, not a fetch
failure (failed=0). After the repoint the same command exits 0.

Fired set re-observed (13, unchanged): S012–S016, S021–S028. All quote clocks
(S005–S007, S017–S020, S030–S032, S098) re-located; `kept=1` (no registry row deleted).

## S098 binding: revision-naming quote investigated, not applied

The UTS #18 page as fetched this round (199607 bytes, sha256 `68e34b8b…8c70d`) is
byte-identical to its 2026-11-05 capture and carries `Version 25`, `Date 2025-01-16`,
`Revision 25`. A revision-naming declared quote is possible, but applying it is a
registry-adjacent edit that this seat cannot carry green:

- raw-literal `<a href="#Modifications">25</a>` (unique, offset 2464) keeps the capture row
  in shape (words ≤ 25, profile enum, normalized digest still `-`), and the lane census adds
  no finding (same 3 pre-existing);
- rendered-text-v1 `Revision 25` also keeps census shape (needs the 64-hex normalized digest
  `53fa58d5…`), but rendered text can never satisfy `quote-locate`'s raw-byte model;
- in **both** variants a `corpus/quote-bodies.tsv` row for S098 fails
  `NOT-LOCATED S098 quote-not-in-registry-row` (`QUOTE_LOCATE: FAIL located=8 rows=9`, rc 1),
  because the quote must also sit in the SOURCES.md S098 teaches cell — a registry edit
  outside this seat's write scope; and the lane census is already red at BASE (S094/S099), so
  "keeps the checks green" cannot be demonstrated.

Decision: S098 is bound with its declared title quote (`raw-literal-v1`). **Named ceiling:**
the title is revision-invariant, so this clock cannot detect a revision bump at the same URL;
turning it into a revision clock needs a coherent recapture row plus a SOURCES.md teaches-cell
edit plus a manifest row with the committed body. S098's freshness this round rests on the
receipt record (http 200, 64-hex sha256, `quote-located`, observed 2026-11-06).

## Doc lines naming the round-36 default (drafted in `skill-lines.md`, not applied)

- `SKILL.md:48` — "replays the **pinned round-36 rearmed receipt** (the round-26 receipt is
  retained as history)".
- `SKILL.md:787` — "default is the byte-pinned **round-36 rearmed receipt** (round-26
  retained as history)".
- `corpus/README.md` — no `round-36` occurrence (its lines 193/212 are round-25/26 history).
- `PROVINCE.md:75` — same fact, outside the assigned pair, flagged with drafted text.

## Residual defects and risks (named, not hidden)

1. The 29 synced rows keep notes that cite the round-36 receipt as their most recent named
   observation ("re-observed unchanged by the round-36 receipt observe-live.json
   (2026-11-04)"). True as history, but the row's `observed_at` is now 2026-11-06 and no note
   names the round-46 receipt. A follow-up may append "; round-46 receipt (2026-11-06)". Not
   edited here because the frozen candidate work names only version/date/verdict.
2. The lane census is red at the predeclaration tree for three unrelated findings
   (S094/S099); this candidate neither fixes nor worsens them.
3. The receipt's feed versions (Vault 2.2.1, OpenBao 2.7.2, Python 3.15.2, SOPS 3.13.3,
   curl 8.23.0) are point observations; a non-author live re-observation later in the round
   must agree on feed clocks that have not released in between (kill rule).
4. Ceiling carried from the plan: the counter cannot tell a fetched receipt from a hand-written
   one with plausible digests (K2-F4 = 29); the non-author live re-observation is that leg.
5. `--observe` exiting 1 before the repoint is an ordering artifact of running the observation
   first; the post-repoint default and pinned gates both read CLEAN at rc 0.

## Commands not run (per seat bounds)

Lane full claim-ledger verify, self-counts, commit/push, any registry or plan edit. No host
state touched; no package operations; no subagent dispatch.

SEAT-STATUS: complete
