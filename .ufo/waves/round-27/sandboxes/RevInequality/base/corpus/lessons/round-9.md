# round-9 lesson — a printer is not a gate: baselines, symbol pins, and what a hash may not reveal

## What this round closed

Rounds 6–8 left the corpus citing host files with a script that printed live
fingerprints and stored nothing, so every line ref was unverifiable in a fresh
process. `PROTOCOL.md` §Evidence standard names the rule and this repo as the
example: "a pin only counts if its expected values are persisted inside the
repo… round-8 audit found kagi's pins verifiable for only 2 of 13 files." The
same stale-ref class had already cost four rounds of `MODEL_ENDPOINT` L17
citations (round-8 lesson §5). Round 9 landed the missing half: committed
baselines plus per-symbol claim pins, a real exit code, and a self-proving
selftest.

Landed: `corpus/drift-pins.sh` v2 (451 lines), `corpus/drift-baseline.tsv`
(15 rows: mode/lines/sha256), `corpus/drift-symbols.tsv` (19 claim pins,
incl. a count+shape pin and two count pins), `corpus/knowledge/drift-gate.md`,
`SCORECARD.md` (first one; the axis contract needed it), regenerated
`SHONEN.md`, `PROVINCE.md` surface census.

## Lessons

1. **A gate needs a stored expectation, and the expectation needs a schema with
   teeth.** Two files, one job each: bytes (`path mode lines sha256`) and claims
   (`path line ERE`). The first answers "did anything change?", the second
   answers "did the *citation* break?" — a sha diff alone cannot tell you a line
   ref rotted, which is the failure that actually cost rounds here.

2. **File-level hash and symbol-level pin answer different questions — keep
   both, and make the symbol the load-bearing one.** Verified by construction:
   when the corpus's known-open drift (the dead `8080` endpoint) is remediated,
   the file row says `DRIFT … sha a318e719d913-><new>` while the symbol row says
   `GONE …:16 (pattern no longer present)`. The second is the one that forces a
   documentation sweep; the first would have passed as "expected edit".

3. **Pin the *defect*, not just the key.** The endpoint rows assert the literal
   `http://127.0.0.1:8080/v1` in both declarations, deliberately. A key-presence
   pin would let the operator's fix land silently and leave the corpus claiming a
   dead endpoint; the value pin makes the remediation a red gate until the citing
   text is re-read. General rule: pin the claim the reader acts on, not the
   claim that is convenient to pin.

4. **A private file's hash is a public oracle.** A committed sha256 of a
   low-entropy private file lets anyone test candidate content offline (round-9
   sentinel demonstrated identifier recovery from a hash with zero host
   contact). Six 0600 files are therefore pinned by mode+lines only — `op.env`
   (values and refs), `config.json`, `~/.agents/AGENTS.md`, `handoff-status.json`
   and the two TAC receipt/custody records — with the cost stated in the corpus:
   their content drift is invisible. Compensating controls exist only because
   they were named (`tac-check` binds `receipt_sha256` itself; `config.json`'s
   inertness is proven; the handoff field names are asserted by count).
   Sentinel's own refinement — only `op.env` strictly *requires* this — is
   recorded next to the decision, because "we were more conservative than
   necessary" is a fact a reader deserves.

5. **Private files deserve count pins, not line pins.** Two `handoff-status.json`
   pins started as `:42`/`:46`; the durable artifact then published that private
   file's line layout. Converted to `#1` count pins: the published field names
   (`boundaries`, `credentials_in_evidence`) are asserted exactly once without
   publishing where they live or how the file is arranged.

6. **A claim pin must be able to *refuse*.** `--pin` absorbs a location move
   (`MOVED`) but refuses a claim change: `GONE`, `AMBIG`, and — after the round-9
   critic's objection — a changed **count**. A count that moves means a key
   appeared or disappeared in a credential file; auto-absorbing that would make
   one `--pin` a silent credential-inventory edit. The same discipline covers
   symlinked and hardlinked sources, an empty/unreadable symbol file, and a
   baseline row that is not in `FILES`: exit 2, nothing written.

7. **Enforce a privacy policy in code, not in data.** The first verify
   implementation trusted the TSV's `sha` column (`-` vs a hash). A hand-edited
   row would then have made the gate *hash a secret file and print a digest
   prefix*. Now the policy is checked by path before the file is read
   (`POLICY` verdict). Lesson: never let a data file select its own privacy
   policy.

8. **The gate's own selftest is part of the deliverable.** 13 cases on a
   `mktemp -d` tree through `--baseline`/`--symbols` (+ `DRIFT_EXTRA_NOHASH`):
   content drift, mode drift, missing, symlink, symbol moved/gone/ambiguous,
   count drift, dotenv shape drift, plus clean/restored/final-clean. Without it,
   the new verdicts (`POLICY`, `SHAPE`, `EMPTY`, `EXTRA`, `DUP`) would be
   untested prose. A landing window did fire `UNPINNED` ×2 for real while `FILES`
   grew to 15 and the baseline still had 13 rows — the designed behaviour, caught
   by the second L2 lane rather than by the owner.

9. **The axis contract is an artifact, not an attitude.** Six rounds of
   self-assessment lived in prose because `SCORECARD.md` was never created;
   `SHONEN.md` had drifted out of the protocol's mark form (four bare `[x]`, no
   named verifier). Both are now files with evidence pointers. Calibration
   improvements are cheap *only* when someone checks the format.

10. **Third-party L2 lanes found what the owner's own verification could not.**
    Concretely: the `REPIN` audit line never fired (old-row map keyed literally,
    lookups expanded); `--baseline` with no argument exited 1 instead of 2; a
    missing symbols file could be replaced by an empty one; symbol scans followed
    symlinks; the hardlink variant of the symlink case was undetected; the
    `op.env` count pin did not assert dotenv *shape*; and the corpus carried a
    four-round-old overclaim ("every cited host file" while 4 were unpinned).
    All fixed, all verified, all attributed.

## Verification evidence (2026-09-28, script sha256 `c138d34c…0feb`, 451 lines)

- `bash corpus/drift-pins.sh` → `DRIFT_PINS: CLEAN (files=15 symbols=19)`, exit 0.
- `bash corpus/drift-pins.sh --selftest` → `DRIFT_SELFTEST: PASS (13 cases)`, exit 0.
- `--baseline` with no argument → `drift-pins: --baseline needs a path`, exit 2.
- Falsified baseline copy (one sha → `deadbeef`) → `DRIFT … sha
  deadbeef0b7e->2408b0c90b7e` + `DRIFT_PINS: DRIFT (files_ok=14 files_bad=1 …)`,
  exit 1.
- `op.env` row carrying a hash → `POLICY … baseline sha must be `-` …`, exit 1.
- `--pin` against a falsified baseline → three `REPIN` lines (audit output
  proven live), `DRIFT_PINS: PINNED (files=15 symbols=19 line_updates=0)`.
- Count pin forced to `#9` → `count pin changed (…:#9->#10), refusing to pin`,
  exit 2.
- Hardlinked twin of a scratch file → `LINK … (hardlink count 2 …)`, exit 1.
- Patched endpoint copies → `GONE` ×2, exit 1 (remediation signal).
- Independent corroboration: scout re-derived all 15 fingerprints and 19 symbol
  pins on the host before the baseline existed (byte-identical); sentinel
  verified `transcript-scan.sh` remains counts-only; scribe verified the TSVs
  contain 0 `op://` refs and 0 `op.env` key names; reviewer re-verified the
  corpus's line-ref claims (VERIFIED/WRONG table) and confirmed the delivered
  gate is green after flagging a broken in-flight revision.
- Transcript gate re-verification (same round, after the escape fix; script
  sha256 `2d60981b…3a23`, 282 lines): `TRANSCRIPT_SCAN: HITS=2 (cells=888
  patterns=32+5 warns=2 schema-absent=0)`, exit 1, all 5 tripwires empty;
  `--classify` → `key_shaped=0 prose=1` for both rows; `--selftest` OK
  (seeded hit + wal-resident hit detected, clean db passed). Literal
  `gsk\_` ESCAPE `'\'` = 0 rows vs the unescaped wildcard's 7.
- 10 L2 lanes, one batch (`planner`, `connector`, `scout`, `executor`, `scribe`,
  `reviewer`, `critic`, `sentinel`, `labrat`, `distiller`).

## Addenda — findings from the re-verification wave

11. **A gate's matching semantics are part of its correctness.** Re-running the
    round-8 transcript gate as this round's freshness re-verification produced
    `HITS=3` on a DB whose row census had not changed since round 8. Root cause:
    SQL `LIKE` treats `_` as "any single character", so the pattern `gsk_`
    matched `gsk` + any 4 alnum chars in 7 event rows. `gsk\_` with
    `ESCAPE '\'` returns 0. The script's header had *documented* the wildcard as
    "acceptable for these prefix families" — documented wrongness still trains
    operators to ignore the HIT tier (round-8 lesson §1). Fix: `like_lit()`
    escapes `\`, `%`, `_` and every query carries `ESCAPE '\'`.
    Classification before alarm: measuring the run length after the literal
    `gsk` gave 4 characters in all 7 rows (a Groq key is `gsk_` + ~52) — shape
    metadata, no content, no export.

12. **A recorded baseline must name the shipped revision.** Round 8 recorded
    "0 HIT, 4 WARN, 270 cells × 25+5 patterns"; the revision committed that
    round carries 888 cells × 32+5 patterns and reports 2 HITs. The measurement
    predates the last edits (it shipped under "uncommitted on fleet pause"), so
    the corpus's clean-baseline claim described a gate that is not the one on
    disk. Two consequences, both now rules: (a) any baseline entry states the
    script hash + pattern/cell counts it was measured against; (b) the pattern
    set growing *re-fires on old rows* — the round-9 HITs sit in rows that
    predate round 8 (census unchanged: 7 sessions / 39 messages / 55 parts /
    238 events). Third rule, from the same finding: the read design had also
    moved (the shipped gate snapshots db+wal into `mktemp` rather than opening
    `?immutable=1`), so a doc describing a gate's *mechanism* is as drift-prone
    as one citing its lines.

13. **Triage must be mechanical, not a manual peek.** The round-8 lesson allowed
    an 80-char prefix peek as a bounded exception. Round 9 replaces the peek
    with `--classify`: per firing pattern it prints `rows`, `key_shaped` (the 32
    characters after the literal prefix are all key characters) and `prose` —
    all derived from shapes, so "material or prefix collision?" is answered
    without reading content. Current output on the real DB:
    `CLASSIFY part.data pattern=xai- rows=1 key_shaped=0 prose=1` and the same
    for one `event.data` row; every other HIT class is zero. **No secret
    material rests in the transcript DB**; the two remaining HITs are the
    `xai-` prefix colliding with provider naming, kept fail-closed and recorded
    as a known false-positive class rather than silently dropped.

14. **Nothing in-flight is evidence.** The L2 reviewer caught an intermediate
    revision of `drift-pins.sh` (18:02–18:10) that was outright broken — a bash
    parse error, exit 2 on both plain and `--selftest` runs — because the owner
    was editing while lanes verified. The delivered 445-line revision is green
    (verified repeatedly: `CLEAN 15/19`, 13-case selftest), and the lane's
    independent observation is retained here as the round's process lesson:
    a gate must be committed before it is cited, exactly as PROTOCOL's
    evidence-before-commit ordering already requires.

## Open / residual (recorded, not hidden)

- Nothing runs the gate on a schedule; coverage = the enumerated claims; the 6
  no-hash files are content-drift-blind; count pins are value-swap blind at
  constant count; baseline freshness depends on the reported re-pin discipline.
- `drift-gate.md` §Bounds lists all of the above with the compensating control
  for each.
- The round-5 aggregator lesson's `corpus/drift-pins.sh:19` citation is now dead
  (v2 stores `$HOME`-relative paths) — reported for the integrator rather than
  edited in place, per the append-only rule for aggregator-owned lessons.

No vault access, no secret values, no ref paths, no account-identifying values,
and no private-file content in any artifact of this round.