# K38ExecQuote — kagi round 38 wave `build` — C1 re-execution at candidate

Seat: K38ExecQuote (executor). Date: 2026-11-05.
Lane repo: /home/vgpnk/Projects/shokunin/kagi-shokunin (branch master).
Commits pinned this run (git rev-parse, all read-only):
- candidate (landed)  b944735 -> b94473505e6239cee0073d5be7a1c6f2ee07f564
- predeclaration      8c48b7df71066b969ac078205b5ed18cf5f53286
- frozen plan         289e8082ef80e9e14694fcf68f1296bfff26ad9d
- claim BASE          a916f4a56a08a6dea9a1a2318bbe6406fd0ac97c

Scratch: S=/fast/scratch/hyaku/kagi-r38/K38ExecQuote (deleted before yield; nothing written
outside S, the lane's .ufo/waves/round-38/build/K38ExecQuote/, and the two named report paths).
Extraction: `git -C <lane> archive b944735 | tar -x -C "$S"` — corpus/quote-locate.py (4656 B,
mode 755) and corpus/quote-bodies.tsv (500 B) present. All commands below ran in the
extraction unless noted. No tools were installed; pacman untouched.

## TOP-LINE VERDICT: C1 REPRODUCED

The C1 gate and counter reproduce the claim on a fresh extraction of b944735
(`QUOTE_LOCATE: CLEAN located=5 rows=5`, exit 0; counter `5`, exit 0); BASE a916f4a reads 0;
the five frozen no-work/forgery controls behave exactly as predeclared (0/5/4/4/4 via the
prefreeze gate, 5/4/4/4 on direct reruns, see context note on c1_nowork); an independent
sha256/byte-count/byte-search recomputation agrees on all five rows; the predeclaration
freeze is intact (captures and instruments byte-identical; candidate deltas additions-only);
and the predeclaration gate reproduces the frozen receipt verbatim
(`PREFREEZE: CLEAN (controls=7 mismatch=0)`, exit 0). C2 side-observations also reproduce.

## 1. Number table (every check, exact command, output, exit code)

Runs A/B below: A = fresh extraction of b944735 at $S; B = fresh extraction of the
predeclaration 8c48b7df at $S/pre (made only by corpus/prefreeze-control.sh itself, which
extracts the revision it is given).

| # | check | command (cwd in parentheses) | stdout | rc | expect | verdict |
|---|-------|------------------------------|--------|----|--------|---------|
| 1 | C1 gate | python3 -I -B corpus/quote-locate.py (A) | `QUOTE_LOCATE: CLEAN located=5 rows=5` | 0 | CLEAN located=5 rows=5, exit 0 | PASS |
| 2 | C1 counter | bash plans/round-38-c1.sh (A) | `5` | 0 | 5 | PASS |
| 3 | C2 counter (observed, not owned) | bash plans/round-38-c2.sh (A) | `3` | 0 | 3 | PASS |
| 4 | C1 gate at BASE | bash plans/round-38-c1.sh (BASE extraction a916f4a, counters copied in) | `0` | 0 | 0 | PASS |
| 5 | C2 counter at BASE | HYAKU_SCRATCH=$S/hs bash plans/round-38-c2.sh (BASE extraction) | `0` | 0 | 0 | PASS |
| 6 | c1_nowork (frozen context = predeclaration) | via gate row 1 (B) | gate: `OK c1_nowork expect=0 measured=0` | 0 | 0 | PASS |
| 7 | c1_full | BASE=$S/cbase HYAKU_SCRATCH=$S/hs bash $S/plans/round-38-controls.sh c1_full (A); also via gate (B) | `5` / `OK c1_positive_full expect=5 measured=5` | 0 | 5 | PASS |
| 8 | c1_forge_quote | ...controls.sh c1_forge_quote (A); also via gate (B) | `4` / `OK ... measured=4` | 0 | 4 | PASS |
| 9 | c1_forge_bytes | ...controls.sh c1_forge_bytes (A); also via gate (B) | `4` / `OK ... measured=4` | 0 | 4 | PASS |
| 10 | c1_forge_registry | ...controls.sh c1_forge_registry (A); also via gate (B) | `4` / `OK ... measured=4` | 0 | 4 | PASS |
| 11 | c2_nowork | ...controls.sh c2_nowork (A); also via gate (B) | `0` / `OK c2_nowork expect=0 measured=0` | 0 | 0 | PASS |
| 12 | c2_positive | HYAKU_SCRATCH=$S/hs bash $S/cbase/plans/round-38-c2.sh (A); also via gate (B) | `3` / `OK c2_positive expect=3 measured=3` | 0 | 3 | PASS |
| 13 | predeclaration gate | cd <lane root> && TMPDIR=$S/hs HYAKU_SCRATCH=$S/hs bash corpus/prefreeze-control.sh run --base 8c48b7df71066b969ac078205b5ed18cf5f53286 --controls plans/round-38.controls.tsv | 7 OK lines then `PREFREEZE: CLEAN (controls=7 mismatch=0)` | 0 | verbatim frozen receipt | PASS |

Gate stdout, verbatim (run 13):

```
OK c1_nowork expect=0 measured=0
OK c1_positive_full expect=5 measured=5
OK c1_forge_quote expect=4 measured=4
OK c1_forge_bytes expect=4 measured=4
OK c1_forge_registry expect=4 measured=4
OK c2_nowork expect=0 measured=0
OK c2_positive expect=3 measured=3
PREFREEZE: CLEAN (controls=7 mismatch=0)
```

Context notes on rows 6 and 12:
- c1_nowork's frozen "no manifest -> 0" context is the predeclaration: corpus/quote-bodies.tsv
  does not exist at 8c48b7df (verified by ls; gate measured 0). A direct rerun of the same mode
  with BASE pointed at the candidate extraction legitimately printed 5 (the candidate has the
  manifest, and the mode's fixture is "no changes"), rc=0 — that is the unmodified candidate,
  not the control's frozen context. No contradiction with expect=0.
- c2_positive is not a mode of plans/round-38-controls.sh; the frozen controls row calls the
  counter directly (`bash "$BASE/plans/round-38-c2.sh"`). Passing it as a runner mode once
  printed `unknown mode c2_positive`, rc=2; the direct run (row 12) is the faithful one.

## 2. Independent recomputation (sha256sum / wc -c / byte search, not the gate)

Method: python3 in scratch, parsing the extraction's corpus/quote-bodies.tsv and
corpus/source-fetches.tsv directly; body read from the committed capture path; quote located
by bytes.find and confirmed at the declared offset; sha256 and byte count compared to fetch
columns 10 and 11; manifest quote compared to fetch column 13; verbatim presence of the quote
checked in the id's registry line in corpus/SOURCES.md.

| id | body | sha256 match (col 10) | byte count match (col 11) | quote match (col 13) | quote at declared offset | declared=first offset | quote verbatim in registry row |
|----|------|----------------------|---------------------------|----------------------|--------------------------|----------------------|-------------------------------|
| S089 | .ufo/waves/round-37/capture/S089-vault.body | yes | yes (297221) | yes | yes | 726 = 726 | yes |
| S090 | .ufo/waves/round-37/capture/S090-openbao.body | yes | yes (543805) | yes | yes | 729 = 729 | yes |
| S091 | .ufo/waves/round-37/capture/S091-python.body | yes | yes (3354) | yes | yes | 1583 = 1583 | yes |
| S092 | .ufo/waves/round-38/capture/S092-vault-tag.body | yes | yes (161306) | yes | yes | 21886 = 21886 | yes |
| S093 | .ufo/waves/round-38/capture/S093-openbao-tag.body | yes | yes (192563) | yes | yes | 21886 = 21886 | yes |

Fetch-row digests read from corpus/source-fetches.tsv cols 10/11 (candidate):
- S089 3cbfdd86d1b4530999d9ab7ed15f395f2757ce0f8a2ae835798878bbe1957fce / 297221
- S090 a54d1a5314ca701684fe65b3e4687c0519d45164c8cd177c950ff75bfd5f2e0e / 543805
- S091 9ba8856e586659ab78349c3963aa1de178636c0f08772d6196fadbaa92bcea1e / 3354
- S092 1e0346160e6679f1f5f4f9b6d763cd05235d422ecb1ca1231331b5d9528ba468 / 161306
- S093 a69db25645f08a09bf48a0ed4c98aaf27fc8692e35651e513351496f1b0f6165 / 192563
All five recomputed sha256/byte counts equal these values. No disagreement found.

## 3. Freeze integrity: candidate b944735 vs predeclaration 8c48b7df

Byte-identical (diff -q -r, empty): corpus/quote-locate.py, corpus/laneguard.sh,
plans/round-38-c1.sh, plans/round-38-c2.sh, plans/round-38-controls.sh,
plans/round-38-rows.py, plans/round-38.controls.tsv,
.ufo/waves/round-37/capture (whole dir), .ufo/waves/round-38/capture (whole dir).
Kill rule "a committed capture body changed after the predeclaration" — NOT triggered.

Additions-only deltas (diff, predeclaration -> candidate):
- corpus/quote-bodies.tsv: absent at the predeclaration (created by the candidate).
- plans/round-38.md: absent at the predeclaration (committed separately at 289e8082).
- corpus/source-fetches.tsv: 134a135,136 only — the S092 and S093 rows appended; no row
  removed or modified (S089-S091 lines byte-identical).
- corpus/SOURCES.md: 98a99,100 only — the S092 and S093 registry rows appended; no other
  change.
These deltas are exactly the claimed landing content; the frozen instruments, controls,
manifest schema inputs and capture bytes did not move.

## 4. BASE measurements (claim BASE a916f4a)

Fresh `git archive a916f4a56a08a6dea9a1a2318bbe6406fd0ac97c` extraction:
- ls: corpus/quote-locate.py, plans/round-38-c1.sh, corpus/quote-bodies.tsv — all absent
  (matches the predeclaration's "the instruments are absent there").
- Counter scripts (plans/round-38-c1.sh, round-38-c2.sh) copied in from the candidate, as the
  predeclaration describes, then run: c1 -> `0` rc=0; c2 -> `0` rc=0 (HYAKU_SCRATCH=$S/hs).
Claim BASE values 0/0 reproduced.

## 5. Side-observations relevant to the wave (not owned by this seat)

- C2 at the candidate: `bash corpus/laneguard.sh --selftest` was not run standalone here;
  its counters were: c2 counter `3` rc=0 (A), BASE `0`, c2_nowork `0`, c2_positive `3`
  (rows 3, 5, 11, 12). All agree with claim C2's numbers.
- The C2 selftests this seat triggered all ran inside scratch fixture trees under
  $S/hs/laneguard (extraction trees, never the lane). The lane checkout was never mutated:
  `git -C <lane> status --porcelain` shows only 7 untracked `?? .ufo/waves/round-38/…`
  wave-bookkeeping entries (dispatch/ready files and this seat's own report dir); the lane's
  tracked state is clean.

## 6. Deviations and honest-run notes

- First controls batch (BASE=$S with HYAKU_SCRATCH=$S/hs, i.e. fixture scratch inside the
  BASE tree) failed before any measurement: cp refused a directory self-copy, rc=1, for all
  seven modes. Rerun with a separate candidate extraction $S/cbase as BASE; those are the
  numbers reported. The failed batch produced no integers and none were used.
- One accidental stray file `nil` was created at the fleet root by a mistyped write and
  deleted immediately in the same session (verified absent afterwards). No other writes
  outside the permitted paths.
- No git/jj mutation was run against the lane or any clone; only read-only git (rev-parse,
  archive, status) was used. No git init/commit anywhere.
- Tools installed: none. Pacman: untouched (host-wide pause respected).
- An unrun check has not been claimed: every number in section 1 was executed this session,
  with the exact command and exit code shown.

## 7. Acceptance

Table of every number with command and exit code: section 1.
Independent recomputation agreement: section 2 (5/5 rows, zero disagreements).
Top-line verdict: **C1 REPRODUCED** — reason: gate `QUOTE_LOCATE: CLEAN located=5 rows=5`
exit 0 and counter `5` exit 0 at b944735 in a fresh extraction; BASE `0`; forgery controls
0/5/4/4/4 as frozen; independent byte-level recomputation agrees on all five rows; the
predeclaration freeze is intact and the prefreeze gate reproduces
`PREFREEZE: CLEAN (controls=7 mismatch=0)` verbatim.

Scratch $S was removed after this report was written.
