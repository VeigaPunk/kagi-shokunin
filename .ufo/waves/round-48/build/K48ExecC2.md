# K48ExecC2 — C2 candidate material (calibration readings line + `SKILL.md:826`)

Seat: `K48ExecC2` (leaf executor). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (read-only).
Claim BASE `76da518fcc3029e738648bd6fd4ba5571df01c1c`; predeclaration `164f0ea5ed8b76a671f9b076158d1d8022881813` + amendment A1 `52991e5da64cbacaa724b28b407cf5765fd21b41`.
Measured on a scratch clone under `$HYAKU_SCRATCH/kagi-r48/K48ExecC2/repo` (toplevel asserted = the clone), fixture commit `d7517aa191cfca034bb0884e800199e7644184f4`, tree `fc3705939dfb06e14e303aa71625674cb8b4ea10`.

## Result

| revision | `bash plans/round-48-c2.sh <rev>` | keys |
|---|---|---|
| predeclaration `52991e5da64cbacaa724b28b407cf5765fd21b41` | **value=3** (K02, K07, K10 DIFF) | 10 |
| fixture `d7517aa191cfca034bb0884e800199e7644184f4` | **value=0** | 10 |

Counter bytes were verified identical across the lane, the clone and the measured tree:
`sha256 plans/round-48-c2.sh = 15f7a0c3a6050a575365cec3bb5b586da7a396e1a1dde45ed3154b98e59a4fce` (all three).

### Fixture commit — verbatim

```
C2_CAPABILITY_READINGS: value=0 keys=10 rev=d7517aa191cfca034bb0884e800199e7644184f4
  K01 MATCH stated=[FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)] executed=[FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)]
  K02 MATCH stated=[QUOTE_LOCATE: CLEAN located=8 rows=8] executed=[QUOTE_LOCATE: CLEAN located=8 rows=8]
  K03 MATCH stated=[LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok] executed=[LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok]
  K04 MATCH stated=[detected=0] executed=[LANE_GUARD_SELFTEST: detected=0 mutants=3 clean=ok]
  K05 MATCH stated=[ANCHOR_PINS: CLEAN (pins=4)] executed=[ANCHOR_PINS: CLEAN (pins=4)]
  K06 MATCH stated=[3] executed=[3]
  K07 MATCH stated=[CLAIMS_DECLARED: CLEAN (claims=23)] executed=[CLAIMS_DECLARED: CLEAN (claims=23)]
  K08 MATCH stated=[3] executed=[3]
  K09 MATCH stated=[ANCHOR_PINS_SELFTEST: PASS (8 cases)] executed=[ANCHOR_PINS_SELFTEST: PASS (8 cases)]
  K10 MATCH stated=[CLAIMS_DECLARED_SELFTEST: PASS (12 cases)] executed=[CLAIMS_DECLARED_SELFTEST: PASS (12 cases)]
rc=0
```

### Predeclaration — verbatim

```
C2_CAPABILITY_READINGS: value=3 keys=10 rev=52991e5da64cbacaa724b28b407cf5765fd21b41
  K01 MATCH stated=[FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)] executed=[FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)]
  K02 DIFF stated=[QUOTE_LOCATE: CLEAN located=5 rows=5] executed=[QUOTE_LOCATE: CLEAN located=8 rows=8]
  K03 MATCH stated=[LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok] executed=[LANE_GUARD_SELFTEST: detected=3 mutants=3 clean=ok]
  K04 MATCH stated=[detected=0] executed=[LANE_GUARD_SELFTEST: detected=0 mutants=3 clean=ok]
  K05 MATCH stated=[ANCHOR_PINS: CLEAN (pins=4)] executed=[ANCHOR_PINS: CLEAN (pins=4)]
  K06 MATCH stated=[3] executed=[3]
  K07 DIFF stated=[CLAIMS_DECLARED: CLEAN (claims=2)] executed=[CLAIMS_DECLARED: CLEAN (claims=21)]
  K08 MATCH stated=[3] executed=[3]
  K09 MATCH stated=[ANCHOR_PINS_SELFTEST: PASS (8 cases)] executed=[ANCHOR_PINS_SELFTEST: PASS (8 cases)]
  K10 DIFF stated=[CLAIMS_DECLARED_SELFTEST: PASS (8 cases)] executed=[CLAIMS_DECLARED_SELFTEST: PASS (12 cases)]
rc=0
```

The predeclaration reading reproduces the frozen BASE set exactly (K02, K07, K10), so this candidate moves
only the declared predicate.

## The four changes carried by the fixture

### 1. Readings line in `SCORECARD.md` §`## Capabilities`

Inserted as one paragraph after the §Capabilities narrative paragraph, immediately before `## Saturation` —
i.e. inside the section and after the table, so it is the LAST occurrence of each of the three stated pairs.
Exact bytes (`readings-line.txt`, 362 bytes incl. newline:
`sha256 5f7aacd5733e3235fbdbae65f13548a9c174a7c43a4a44a91414c93b18d21ff5`):

```
Current readings at round 48 (revision-bound counts are true at the revision that carries this line): `python3 -I -B corpus/quote-locate.py` ⇒ `QUOTE_LOCATE: CLEAN located=8 rows=8`; `bash corpus/claims-declared.sh --root .` ⇒ `CLAIMS_DECLARED: CLEAN (claims=23)`; `bash corpus/claims-declared.sh --selftest` ⇒ `CLAIMS_DECLARED_SELFTEST: PASS (12 cases)`.
```

Each quoted output is the byte-exact last nonempty stdout line of that command run in the fixture tree
(`QUOTE_LOCATE: CLEAN located=8 rows=8`; `CLAIMS_DECLARED: CLEAN (claims=23)`; `CLAIMS_DECLARED_SELFTEST: PASS (12 cases)`, all rc=0).

### 2. `corpus/claims-declared.tsv` — two rows appended

```
48	C1	operability
48	C2	calibration
```

Manifest rows 22–23. `bash corpus/claims-declared.sh --root .` reads `CLAIMS_DECLARED: CLEAN (claims=23)`
at the fixture (21 base rows + 2), so both new rows pass the plan-heading and tagged-row legs:
`plans/round-48.md` already carries `## C1 — operability:` / `## C2 — calibration:` (frozen, untouched).

### 3. `SCORECARD.md` — minimal `## Round 48 — post-move` section (exact text, `postmove-min.md`)

```
## Round 48 — post-move (claims C1 operability, C2 calibration)

Candidate: the round-48 candidate commit (recorded in the report; this section is written before the candidate's hash is known and names the content it measures). Claim BASE `76da518fcc3029e738648bd6fd4ba5571df01c1c`; predeclaration `164f0ea5ed8b76a671f9b076158d1d8022881813` + amendment A1 `52991e5da64cbacaa724b28b407cf5765fd21b41` (frozen plan `plans/round-48.md`, counter `plans/round-48-c1.sh`, pre-freeze controls `plans/round-48-controls.sh`). Measured receipts: `.ufo/waves/round-48/final/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| operability | 9 → 9 | [C1] `bash plans/round-48-c1.sh <candidate>` (BASE 0, target 5): the lane executes the SOPS/age access-and-rotation mechanics its entry `corpus/knowledge/sops-age-key-rotation.md` documents; the trial `corpus/sops-age-trial.sh` runs T1..T5 against the real `sops` 3.13.3 / `age-keygen` 1.3.2 and each test flips to BROKEN under its designated falsifier shim. | `plans/round-48-c1.sh`; `.ufo/waves/round-48/` |
| calibration | 9 → 9 | [C2] `bash plans/round-48-c2.sh <candidate>` 3 → 0 (target 0): the `## Capabilities` table's stated evidence readings agree with the commands' executed output at the measured revision for the ten frozen keys K01..K10; the current-readings line is inserted in that section. | `plans/round-48-c2.sh`; `.ufo/waves/round-48/build/K48ExecC2/readings-line.txt` |
| coverage | 9 → 9 | No claim. | `plans/round-48.md` |
| depth | 9 → 9 | No claim. | `plans/round-48.md` |
| freshness | 9 → 9 | No claim. | `plans/round-48.md` |
| adjacency | 9 → 9 | No claim. Connector: no sibling registry row teaches SOPS/age; no sibling trial tooling. | `.ufo/waves/round-48/build/` |
```

Notes for the integrator, deliberate and visible:
- The C1 cell states **BASE 0 and target 5 only**, not a landed value: no C1 measurement existed when this
  candidate text was written. The C1 owner must fill the after-value (and receipt path) from the executed
  `plans/round-48-c1.sh` run, or the row is a claim the candidate cannot support.
- The C2 cell states `3 → 0` because both ends were measured here (predeclaration 3, fixture 0).
- `.ufo/waves/round-48/final/` does not exist yet; it is the declared landing receipt directory, not a
  current receipt.
- The section is the last one in the file and is not referenced by the §Capabilities reading; `claims-declared`
  reads only the header prefix and the tagged first cell.

### 4. `SKILL.md:826` — stated selftest count corrected (current-tense, one line)

`skill-826.patch` (single-line hunk, `@@ -823,7 +823,7 @@`):

```
-selftest 0 `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)`, 1 FAIL
+selftest 0 `CLAIMS_DECLARED_SELFTEST: PASS (12 cases)`, 1 FAIL
```

Only the number changed; the executed output at the fixture is `CLAIMS_DECLARED_SELFTEST: PASS (12 cases)`
(rc=0). The row's later `⇒ CLEAN (claims=5) at the round-40 landing` clause was left alone: it is explicitly
scoped to the round-40 landing, where the manifest held five rows, so it is not a false current-tense claim.
(The executed count at the fixture is `claims=23`, carried by the new readings line instead.)

## Attacks actually run (counter not constant)

All on scratch fixture commits derived from `d7517aa`, counter invoked from the mutated clone so `LANE`
resolved there:

| attack | commit | counter | reading |
|---|---|---|---|
| A1 delete the readings line (falls back to the three table rows) | `12e9a7c2cc00887290a03f50df0bbdef8f3587c1` | **value=3** (K02 DIFF `located=5`→`8`, K07 DIFF `claims=2`→`23`, K10 DIFF `8`→`12` cases) | deletion is not a fix |
| A2 forge the stated quote-locate count `located=9 rows=9` | `aaaed8a6640ca1a8de42ca5cb008d0a9449de412` | **value=1**, K02 DIFF stated=[located=9 rows=9] executed=[located=8 rows=8] | a stated reading is compared to execution, not trusted |
| A3 delete the whole `## Round 48 — post-move` section, keep the two manifest rows | `3fe30fa21e7227a6005a7882056b50256dcd701b` | **value=1**, K07 DIFF stated=[CLEAN (claims=23)] executed=[MISMATCH (claims=23 mismatch=2)] | the readings line is bound to a live gate, not a frozen string |

A3 direct gate reading at that commit: `MISMATCH 48 C1 section-missing`, `MISMATCH 48 C2 section-missing`,
`CLAIMS_DECLARED: MISMATCH (claims=23 mismatch=2)`, rc=1 (last line).

## Ceilings and risks (stated, not concealed)

1. **Last-occurrence semantics.** The counter takes the last stated pair for each command inside
   §Capabilities. Anything appended after the readings line that repeats one of the three commands becomes
   the stated reading. If the C1 seat (or the integrator) appends to that section, the readings line MUST
   stay last or be re-derived.
2. **Revision-bound counts.** `claims=23`, `located=8`, `PASS (12 cases)` are true at the revision that
   carries the line. Any later manifest row, capture body or selftest case makes the line stale again unless
   it is re-measured; the line says so in its own parenthesis.
3. **The three older table rows still show the old counts** (`located=5 rows=5` at round 38, `claims=2` at
   round 39, `PASS (8 cases)` at round 40). They are first-working-round evidence pointers and the counter
   now prefers the current-readings line, but a human reader sees two vintages. My scope was ONE inserted
   line; rewriting the table rows is the L1's call.
4. **K04's token mode is unchanged**: `detected=0` matches as a token of the selftest line, so a
   `detected=0` fragment cannot distinguish `mutants=3` from a degraded run — frozen predicate, not mine.
5. **Instrument identity, not repo truth.** If a command's script itself changed, both stated and executed
   would move together; the counter reads the revision under test, not a BASE-pinned instrument (QM58 covers
   that class elsewhere).
6. The fixture commit lives only in scratch; `fixture.diff` is the carrier. Verified: it applies cleanly to
   `52991e5da64cbacaa724b28b407cf5765fd21b41` (`git apply --check` → APPLY-CHECK-OK; `diff --stat` =
   `SCORECARD.md +15`, `SKILL.md 2 (1+/1-)`, `corpus/claims-declared.tsv +2`).

## Reproduction

```
S=/fast/scratch/hyaku/kagi-r48/K48ExecC2
git clone -q --shared /home/vgpnk/Projects/shokunin/kagi-shokunin "$S/repo"
git -C "$S/repo" checkout -q --detach 52991e5da64cbacaa724b28b407cf5765fd21b41
git -C "$S/repo" apply /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-48/build/K48ExecC2/fixture.diff
git -C "$S/repo" -c user.name=fixture -c user.email=fixture@scratch.invalid commit -qam fixture
HYAKU_SCRATCH=/fast/scratch/hyaku TMPDIR="$S" bash "$S/repo/plans/round-48-c2.sh" "$(git -C "$S/repo" rev-parse HEAD)"   # value=0
HYAKU_SCRATCH=/fast/scratch/hyaku TMPDIR="$S" bash "$S/repo/plans/round-48-c2.sh" 52991e5da64cbacaa724b28b407cf5765fd21b41  # value=3
```

## Honesty / boundary notes

- Every command above was executed in this session; exit codes and last lines are in `receipts.txt`
  (full counter blocks, all attack runs, direct gate runs, sha256/sha identities).
- No private key, secret, token or vault field was printed, copied or written; no age identity was generated
  (the C1 trial owns that); `~/.config/sops`, `~/.ssh` were not read; no 1Password/op/vault contact.
- No host mutation, no pacman, no package install or upgrade (nothing new was needed; `sops`/`age-keygen`
  shas were only re-read and match the pinned values in `receipts.txt`).
- Write scope respected: only `.ufo/waves/round-48/build/K48ExecC2/` and `$HYAKU_SCRATCH/kagi-r48/K48ExecC2/`
  were written; the lane itself stayed read-only (no `git` mutation in the lane; the clone is scratch).
- The lane's full claim-ledger verify and self-counts were not run (host-heavy), per the seat spec.

## Files written (report dir `.ufo/waves/round-48/build/K48ExecC2/`)

- `readings-line.txt` — exact bytes of the inserted §Capabilities line.
- `postmove-min.md` — exact text of the `## Round 48 — post-move` section.
- `skill-826.patch` — the single-line `SKILL.md` hunk.
- `fixture.diff` — the complete 3-file diff from `52991e5` to the fixture commit.
- `receipts.txt` — commands, rc, full counter output, attack runs, identities.
