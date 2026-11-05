source: S092 (Vault release tag page v2.2.1, GitHub), S093 (OpenBao release tag page v2.7.2, GitHub) — both opened 2026-11-05 with located quotes in §Gate; S089–S091 re-opened by byte digest in §Gate

# Round 38 — located-quote gate (C1, freshness) and lane-tree write guard (C2, calibration)

Frozen plan: `plans/round-38.md` at `289e8082ef80e9e14694fcf68f1296bfff26ad9d` (plan alone). Predeclaration (instruments, frozen controls, capture bodies, live re-observation receipt, START census receipts): `8c48b7df71066b969ac078205b5ed18cf5f53286`. Pre-freeze gate over the predeclaration: `PREFREEZE: CLEAN (controls=7 mismatch=0)` (`.ufo/waves/round-38/controls/prefreeze-gate.txt`). Claim BASE: lane HEAD `a916f4a56a08a6dea9a1a2318bbe6406fd0ac97c`.

Fresh-start check: not a fresh-start round (r37 closed `verifier-spotcheck`, C2 verified, no rejection). The round-37 closure's routed items R37-V1..V5 were read and dispositioned below.

## Claims

- **C1 freshness — located-quote gate over committed capture bodies, 0 → 5.** `bash plans/round-38-c1.sh` → `5` (`QUOTE_LOCATE: CLEAN located=5 rows=5`, `python3 -I -B corpus/quote-locate.py`, exit 0). BASE `a916f4a` → `0` (no manifest, no gate). Frozen forgeries at the predeclaration: quote 4, bytes 4, registry 4.
- **C2 calibration — lane-tree write guard, 0 → 3.** `bash plans/round-38-c2.sh` → `3` (`LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok`, `bash corpus/laneguard.sh --selftest`, exit 0). BASE `a916f4a` → `0` (no guard). The do-nothing control (`--no-mutate`) reads `0`.

Both are on the frozen predicates in `corpus/quote-locate.py` and `corpus/laneguard.sh` headers.

## Gate — new registry rows and re-opened sources (round 38)

Access: `curl -fsSL --compressed` (the census profile `curl-fsSL-compressed-v1`), 2026-11-05.

- **ADMIT S092** — `https://github.com/hashicorp/vault/releases/tag/v2.2.1`, opened 2026-11-05, HTTP 200, 161306 bytes, body sha256 `1e0346160e6679f1f5f4f9b6d763cd05235d422ecb1ca1231331b5d9528ba468` (`.ufo/waves/round-38/capture/S092-vault-tag.body`). Located quote at byte offset 21886: “<title>Release v2.2.1 · hashicorp/vault · GitHub</title>”. The page body carries `datetime="2026-10-22T21:59:36Z"` (one match). Corroborates S089.
- **ADMIT S093** — `https://github.com/openbao/openbao/releases/tag/v2.7.2`, opened 2026-11-05, HTTP 200, 192563 bytes, body sha256 `a69db25645f08a09bf48a0ed4c98aaf27fc8692e35651e513351496f1b0f6165`. Located quote at byte offset 21886: “<title>Release v2.7.2 · openbao/openbao · GitHub</title>”. Datetime `2026-10-26T20:24:37Z` (one match). Corroborates S090.
- **RE-OPENED, no row change — S089, S090, S091** (round-37 captures): the committed bodies were re-hashed (not re-fetched). Their sha256 equals the capture rows (`3cbfdd86…`, `a54d1a53…`, `9ba8856e…`) and the quotes sit at offsets 726, 729 and 1583; `quote-locate.py` `located=5` covers all five rows.
- **REFUSE (candidate) — a bare version row citing only the feed.** A tag page is a second surface for the same version; refused as the sole support for C1's quote check.
- **REFUSE (candidate) — `rendered-text-v1 locate` as the quote matcher.** Measured: `python3 -I -B corpus/rendered-text-v1.py locate <file> '<title>v2.2.1</title>'` → `count=0` on a file that contains that exact string, because `locate` strips markup before matching. The gate therefore matches the declared quote byte-for-byte at the declared offset, after the body sha256 and byte count equal the capture row's.
- **REFUSE (candidate) — keeping the feed-only S092 without a tag page.** Not admitted; the tag pages are the second surface.

## Routed item R37-V2 — release-clock table re-point: not re-pointed; measured reasons

The round-37 closure asked for `corpus/release-clocks.tsv` to be re-pointed to S089–S091 or the trend re-graded. Measured here, in scratch, on `git archive HEAD` with the pinned receipt:

| experiment | command | result |
|---|---|---|
| baseline | `python3 -I -B corpus/release-clock.py` | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=15 derived=15)` |
| S027 feed id only → S091 (anchor kept `3.15.0`) | edit `feed_source_id`, run gate | still `CLEAN`, `fired=15` (the feed row is not the verdict input for this row) |
| S027 feed id → S091 and anchor → `3.15.2` (the value a re-point to the superseding feed implies) | edit both | `INCONSISTENT S027`; `RELEASE_CLOCK: FAILED (… observed=29 fired=14 …)` |

Reading: the superseded feed rows S034/S035/S036/S039 are the feeds the clocks were pinned against. Re-pointing the anchor silently un-fires a fired clock (15 → 14 in the experiment). Re-pointing only the id leaves the gate CLEAN and leaves the derived clocks inconsistent with their feed anchor cell (the round-37 closure's 10 DERIVATION findings). Neither re-point is a freshness move. R37-V2 is therefore **not claimed and not re-pointed**; the round-37 closure's "re-grade" condition is answered in the report rather than by a table edit.

Live freshness check (2026-11-05, committed as evidence): `python3 -I -B corpus/release-clock.py --observe .ufo/waves/round-38/controls/observe-r38.json` → `wrote 30 observations (failed=0 fired=15 regressed=0)`. Compared with the pinned round-36 receipt: **30 of 30** records carry the same `parsed_version`, `verdict` and `located` flag. No clock moved. The pinned default receipt is unchanged; the new receipt is evidence, not a new pin (a new pin would be a new claim).

## Routed item R37-V1 — transcribed freeze hash (erratum, not a rewrite)

The round-37 report and lesson cite the freeze commit as `e2030d2794…`. The commit is `e2030d2799cf46e77dcfef0369d79d8da4130e05` (round-37 closure §6, R37-V1). Erratum: `git cat-file -t e2030d2799cf46e77dcfef0369d79d8da4130e05` → `commit`; the filed round-37 bytes stay as they were. The round-38 report and this lesson cite the full hash only.

## Routed item R37-V5 — pointer

The round-37 lesson's `## Non-author spot-check` said "Pending outside closure." A pointer line to the closure file is appended to that section (append only).

## Routed item R37-V3 — closed by C1

The round-37 closure's "located-quote gate against committed bodies" is C1 (`plans/round-38-c1.sh`, `corpus/quote-locate.py`, manifest `corpus/quote-bodies.tsv`, five rows). Its ceiling is the same as the counter's: committed bytes only; no live re-fetch; no check that a quote supports the teaching.

## Routed item R37-V4 — routed to round 39, not claimed

Anchor immutability for S034/S035/S039 (in-place rewrite reads 0) and the `2.2.10` boundary control (mutant M5) are frozen-counter amendments; they are routed, not claimed here.

## Routed item M37-2 — closed by C2

The round-37 lesson stated that `plans/round-37-controls.sh` prints a `LANE-GUARD` line that compares the lane's tracked state. `grep -rn LANE-GUARD` over the committed tree (excluding `.ufo/waves/`) finds it only in round-37 lesson/report text, never in a committed script (`plans/round-37-controls.sh` ends at `bash plans/round-37-c2.sh`). The measured move is C2: `corpus/laneguard.sh` is committed and detects the three planted writes it was written for (tracked edit, untracked file, new commit), while the clean control and the no-mutate control keep it honest.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M38-1 | number-drift | `/home/vgpnk/Projects/shokunin/.ufo/reports/round-37/kagi.md:31` cites the freeze commit as `e2030d2794…` (fleet repo, not the lane); `corpus/lessons/round-37.md` repeats the prefix (`grep -c 'e2030d2794' corpus/lessons/round-37.md` → 1; the report → 1). The true hash is `e2030d2799cf46e77dcfef0369d79d8da4130e05`. | `none` | this lesson's erratum with the full hash; `git cat-file -t e2030d2799cf46e77dcfef0369d79d8da4130e05` → `commit` (exit 0); filed round-37 bytes not rewritten. |
| M38-2 | attribution (self-description without an artifact) | `git grep -l LANE-GUARD -- ':!.ufo/waves'` → `corpus/lessons/round-37-verifier-spotcheck.md`, `corpus/lessons/round-37.md`, `plans/round-38.md`: text only, no script prints it (`plans/round-37-controls.sh` ends at `bash plans/round-37-c2.sh`). | `none` | C2: `corpus/laneguard.sh` committed; detects 3 of 3 planted writes (`--selftest` → `detected=3`; `--selftest --no-mutate` → `detected=0`). |
| M38-3 | attribution (evidence checked by hand) | round-37 closure §6 R37-V3: no repo gate checks Gate quotes against bodies; the round-37 quote check was performed by hand by the closure. Red-before: the forged quote control reads 4 located of 5 (`c1_forge_quote`), not 5. | `none` | C1: `corpus/quote-locate.py`, manifest `corpus/quote-bodies.tsv`. Forgeries (quote, bytes, registry) each read 4; the gate is shown able to fail. |
| M38-4 | landing (edit drift) | a hashline `PUT` against a stale line number overwrote one line of `plans/round-38.md` (line 33, under `## Why these two claims`) during drafting; caught by reading the range back, and repaired by a targeted `PUT` plus `CUT`; the affected range was re-read before the plan commit. No defect reached a commit. | `none` | re-read the exact range after every edit before the next edit; a whole-file rewrite is used when more than one block moves. |

QM38 and QM39 (appended to `corpus/QUALITY.md`) take M38-2 and M38-3.

## Corrigenda

- **Round-37 report and lesson — freeze hash prefix `e2030d2794…`** → `e2030d2799cf46e77dcfef0369d79d8da4130e05` (M38-1, R37-V1).
- **Round-37 lesson `## Mistakes` M37-2 "the battery prints LANE-GUARD"** → no committed battery prints it at `a916f4a`; the guard is now `corpus/laneguard.sh` (M38-2, C2). The round-37 bytes are not rewritten.
- **Round-37 lesson "quote check performed by hand"** → now measured by `plans/round-38-c1.sh` (M38-3, C1).

## Census

- Before (START, `.ufo/waves/round-38/controls/start-census-*.txt`): fleet `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → exit 0; lane `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=91 A=87 B=2 C=2 queued=1 mined=87 rejected=3 entries_sourced=14 legacy=21 captures=91 inrow=16 inrow_only=0 inrow_nonreproducing=12)`.
- After (landing revision): rows=93, A=89, mined=89, captures=93 (S092, S093); `entries_sourced=14` and `legacy=21` unchanged (no knowledge entry added). The four pinned count rows migrated (old→new in `.ufo/waves/round-38/expectation-migrations.json`); the claim-row count `R21-04` migrated 82 → 86.

## Assimilation and considerthese

- Assimilation: none. The eight `kagi` rows of the absent-defect register remain quarantined; none is appended. The register's campaign ids `S090`/`S091` collide in spelling with this lane's rows, so any future adoption runs the id-collision guard first.
- considerthese: no proposal taken this round; the round-37 plan records the 2026-10-26 proposals as implemented or discharged.

## Non-author spot-check

Pending outside closure. This lesson's Gate is lane-authored. Dispatched seats are lane evidence, not outside agreement (LEARNING.md discernment rule).

## Routed to round 39

- R37-V4: anchor-immutability check and the `2.2.10` boundary control (frozen-counter amendment).
- The quote gate covers the five manifest rows; the 21 legacy in-row pins are not in its manifest.
- Seat dispatch does not yet run through `laneguard.sh` automatically; the L1 runs it on any lane write it wants to attest.
