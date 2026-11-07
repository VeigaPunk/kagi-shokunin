# Round 54 — frozen plan (kagi, attempt 1)

BASE (claim tip at declaration): `1a0f43a9220bb0e995462c2aef745ac0124c3317` (branch `master`; the
round-53 verifier spot-check landed at this tip and admitted round 53).
Counter: `plans/round-54-c1.sh` (frozen; the predicate sentence below is the same sentence as the
counter's header comment). Pre-freeze controls: `plans/round-54-controls.sh` (reference overlay
`.ufo/waves/round-54/controls/fixtures/ref/c1/`; receipt `.ufo/waves/round-54/controls/controls-prefreeze.txt`).
Census at round start: `.ufo/waves/round-54/controls/census-start.txt` (`kagi ok`, rc 0). Predeclaration
commit: recorded in the report. No earlier attempt of this round exists (`.ufo/watchdog.log`: one launch
line for round 54, nothing inherited: `jj-lane.sh state` at start `ahead=0 tracked=0 untracked=0`).

## Axes, claim count and the stagnation nudge

All six axes sit at 9 = the saturation line (`SCORECARD.md` §Saturation). Capabilities entered in
rounds 51 and 52, inside the window of rounds 51–53, so the nudge does not fire. Every axis is tied
lowest at 9, so the claim works a lowest-scoring non-retired axis: freshness, one of the lane's two
owned axes. No axis is retired or split.

One claim this round. The second owned axis (calibration) was measured for a cheap, separable
mismatch and none was found that this round can land: `python3 corpus/self-counts.py` at BASE reads
`stale=0` (`SELF_COUNTS: POLICY (claims=63 stale=0 … policy=2 …)`, the two operator-routed rows); the
lane-owned unresolved citations behind R11-08 sit in non-owned closure spot-checks (SD6 history,
`.ufo/waves/round-52/build/R52ExecHarm-r11-08-full.txt`), which the lane never edits; and a second
clock claim would be the same freshness surface (two claims on one axis = one claim). Re-measuring the
§11 byte contract on the new op release is the same freshness surface as the clock that fires it
(round 32 scored that re-measure under freshness), so it is a conjunct of C1, not a second claim.

## C1 — freshness: the op-ref entry's `recheck: on-release of op` is watched by a live release clock, and the release it observes is measured, 0 → 2

Problem (measured at BASE): `corpus/knowledge/op-ref-consumption.md:371` and `:397` declare
`recheck: on-release of op`, and §11.1 scopes its byte measurement to op 2.41.1, but no clock watches op:
S072 (the 1Password CLI release-notes row that records the 2.41.1 identity) sits on a fixed `180d`
recheck, the lane holds no op feed row, and the release-clock gate's title rule takes at most one
leading word, so it refuses the vendor feed's `1Password CLI X.Y.Z` titles (round-53 lesson §Gate
rejection; routed item 4; round-53 closure D4). The vendor feed already lists 2.42.0 (2026-11-04), so
the entry's on-release statement is false today with every gate green.

Source (opened this round, 2026-11-07, request profile `curl-fsSL-compressed-v1`):
https://releases.1password.com/developers/cli/index.xml — HTTP 200, decoded body 45175 B, sha256
`2dce505aedfb66f207701c4d96cb1c337f025cb6305817885c6c7f74665405e2` (byte-identical to the body
R53ScoutFeeds recorded), capture `.ufo/waves/round-54/capture/S112.body`; newest item title
`<title>1Password CLI 2.42.0</title>` (byte offset 37215, count 1).

Change (reference overlay, all built before this freeze):
- `corpus/release-clock.py`: a feed-scoped title prefix. `FEED_TITLE_PREFIXES` maps exactly the
  1Password feed URL to `1Password CLI`; under a declared prefix a title counts only when it is exactly
  `<prefix> [v]X.Y.Z` (anchored at both ends); an undeclared feed keeps the one-word rule unchanged (the
  CPython feed's `Python install manager 26.4.1` stays refused). Five selftest cases (116 → 121). The
  default receipt moves to the round-54 receipt (digest, path, help text).
- `corpus/SOURCES.md`: new row S112 (the feed; `docs`, tier A, `mined`, `90d`); S072 recheck `180d` →
  `on-release`. `corpus/source-fetches.tsv` and `corpus/quote-bodies.tsv`: S112 rows.
- `corpus/release-clocks.tsv`: row `S072 feed S112 <feed> 2.41.1 2.42.0 2026-11-07 fired`; the 31
  existing rows gain a round-54 re-observation note, no verdict or date changed.
- `.ufo/waves/round-54/final/observe-r54.json`: all 32 clocks observed live 2026-11-07 (0 failures,
  fired 14 = the 13 earlier fired rows + S072).
- `.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt`: the official op 2.42.0 Linux amd64 archive,
  signature verified against the 1Password code-signing key, run by the unchanged
  `corpus/op-ref-probe.sh --dotenv-bytes` through `OP_REF_OP_BIN` from round scratch (nothing installed;
  pacman paused; `/usr/bin/op` stays 2.41.1): six PASS, `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`,
  exit 0.
- `corpus/knowledge/op-ref-consumption.md`: new `### 11.2 Re-measure on op 2.42.0` (§11, §11.1 unchanged).

Frozen predicate:
`C1_OP_CLOCK: value = WATCHED + MEASURED when GUARD = 1, else 0; target 2 (BASE 0).`
WATCHED: S072 `mined`/`on-release`/URL unchanged; exactly one S072 feed clock row on the 1Password feed
URL anchored 2.41.1, observed 2.42.0, `fired`; its feed row is the only registry row on that URL,
`mined`, not on-release; the gate names exactly the round-54 receipt, whose digest matches and which is
no symlink, and its one S072 record reads 200 / feed URL / 2.42.0 / `fired` / body sha256 = the
committed capture's, observed in [2026-11-07T00:00Z, measured commit time]; the capture is intact and the
measured gate's own parser reads 2.42.0 from it under the declared prefix; the gate reads
`RELEASE_CLOCK: CLEAN`. MEASURED: the op receipt names op_version 2.42.0, the signing-key fingerprint,
the BASE probe's sha256, exactly the six PASS case lines, the CLEAN line and `exit=0`, no FAIL/DRIFT/SETUP
line; and the entry's §11 has a `### 11.2` heading naming op `2.42.0`. GUARD: the probe equals BASE and
the measured gate's `--selftest` passes. Details in the counter header.

Controls (expected values written before the run; `plans/round-54-controls.sh`): K1-0 BASE 0;
K1-P reference 2; K1-F1 S072 recheck flipped without clock or measure 0; K1-F2 gate replaced by a
CLEAN/PASS printer 1; K1-F3 BASE parser (no declared prefix) with the receipt lines moved 1; K1-F4 clock
re-anchored on 2.42.0 as not-fired (table + receipt + digest) 1; K1-F5 op receipt names 2.41.1 1;
K1-F6 one case FAIL under a CLEAN summary 1; K1-F7 entry without §11.2 1; K1-F8 S112 row on another URL 1;
K1-F9 S072 observation relabelled 2026-11-06 (table + receipt + digest) 1; K1-F10 probe replaced by a
CLEAN printer with the receipt's probe digest rewritten 0; K1-F11 signature line removed 1; K1-F12 default
receipt replaced by a symlink 1; K1-F13 capture tampered 1; K1-F14 S072 record unlinked from the capture
digest 1.

Hardening adopted from round-53 routed item 5 (R53CriticC1): the receipt path and basename are pinned;
symlinked receipt, capture and op-receipt paths are refused (K1-F12); the frozen reading is
revision-bound (committer time; `--tree` takes C1_ASOF and is never the frozen reading); registry rows
inside code fences are not read; the S072 receipt record is linked to the committed body by digest
(K1-F14).

Kill rules (any fires ⇒ C1 not admitted): `plans/round-54-c1.sh`, `plans/round-54-controls.sh`, this
plan or the reference overlay differ between the predeclaration and the candidate; any overlay file
differs between the overlay and the candidate tree (`corpus/SOURCES.md`, `corpus/source-fetches.tsv`,
`corpus/quote-bodies.tsv`, `corpus/release-clocks.tsv`, `corpus/release-clock.py`,
`corpus/knowledge/op-ref-consumption.md`, `.ufo/waves/round-54/final/observe-r54.json`,
`.ufo/waves/round-54/final/op-dotenv-bytes-2.42.0.txt`); the capture differs from the predeclaration.

Named ceilings: the counter checks committed bytes. A self-consistent forged observation receipt whose
digest is written into the gate and whose S072 record copies the capture digest scores WATCHED, and a
hand-written op receipt scores MEASURED; the non-author live leg (re-fetch the feed; download op 2.42.0,
check its signature, run the probe) is the check that catches both. A clock watches the newest stable
item only: a re-published or yanked release, or a byte change inside the same version, is not seen. The
measure is from a verified vendor binary, not the installed CLI (ledger `R21-01` still measures the
installed 2.41.1). The prefix rule is declared per feed URL in code; a new vendor feed needs its own
declaration and selftest case.

## Frontier step and non-claim work (no counter; recorded in the lesson)

- Sourced claim: C1 rests on S112, opened this round (capture, fetch row, quote located `count=1`), and
  on the op 2.42.0 archive and signature fetched this round.
- Mined mistake: an on-release recheck declared in prose with no clock behind it (`unbound-on-release`;
  `op-ref-consumption.md:371,397` since round 21/32) — the fix shown able to fail is K1-0/K1-F1 (BASE
  0, a recheck flip alone 0); a landing criterion goes into `corpus/QUALITY.md`.
- Round-53 closure defects: D1 → anchor timestamps in the S112 row are re-derived from the capture
  before the candidate; D2 → every rejection this round keeps a status/body receipt; D3 → the counter
  adopts the routed hardenings above; D4 → this claim; D5 stays routed (self-counts summary precedence).
- Harm check: the full ledger verify on the candidate tree (before the candidate commit) and on a
  clean clone of the landed tip, FAIL/POLICY ids compared with BASE; expected expectation migrations
  (journaled): R25-03 (selftest 116 → 121), R36-03 (`on_release=31 … fired=13` → 32/14), the four
  `sources-census.sh` rows R21-02/R31-02/R33-02/R34-03 (rows 111 → 112), and any other row the
  candidate-tree verify shows moved by this landing; operator-routed R25-02, R29-01, R29-02, R38-03 are
  not touched.
