# Round 48 — frozen plan (kagi, attempt 1)

BASE (claim tip at declaration): `76da518fcc3029e738648bd6fd4ba5571df01c1c` (branch `master`; the
round-47 verifier spot-check landed at this tip and admitted round 47).
Counters: `plans/round-48-c1.sh`, `plans/round-48-c2.sh` (frozen; the predicate sentences below are
the same sentences as the counters' header comments). Pre-freeze controls: `plans/round-48-controls.sh`
(each expected value written before it ran; fixtures `.ufo/waves/round-48/controls/fixtures/`; receipt
`.ufo/waves/round-48/controls/controls-prefreeze.txt`). BASE receipts: `.ufo/waves/round-48/controls/`
(`c1-base.txt`, `c2-base.txt`, `census-start.txt`, `instrument-sha256.txt`, `tool-install.txt`).
Predeclaration commit: recorded in the report.

## Axes and the stagnation nudge

All six axes sit at 9 = the saturation line (`SCORECARD.md` §Saturation: line 9, window N = 3
completed rounds). The latest capability entered in round 40; rounds 41–47 added none. The nudge
therefore fires: the lowest-axis obligation is waived and the round should be a capability move.
C1 is that capability acquisition (axis verdict: operability). C2 still works an owned tied-lowest
axis (calibration). No axis is retired or split.

Causal separability: C1 lands `corpus/sops-age-trial.sh` (new) and a `## Measured (round 48 …)`
section appended to `corpus/knowledge/sops-age-key-rotation.md`; C2 lands one current-readings line
inside `SCORECARD.md` §Capabilities. C1's counter reads neither SCORECARD.md nor any C2 key's output;
C2's counter executes ten frozen commands none of which reads the trial script or the SOPS entry, and
reads only the `## Capabilities` section, where a new C1 capability row adds no K01–K10 pair. Controls
K1-P (C1 change only, C2 absent) = 5 and K2-P (C2 change only, C1 absent) = 0.

## C1 — operability: capability acquisition — the lane executes the SOPS/age rotation mechanics its entry documents, 0 → 5

Problem (measured): `corpus/knowledge/sops-age-key-rotation.md` says "Nothing here was executed on
this host; every mechanism is documented, not measured", and two of its decision-relevant readings are
marked `[INFERENCE]` (creation-rule edits do not reach existing files; pre-removal copies stay
decryptable). The lane has no SOPS or age binary and no way to check whether a SOPS release still
behaves as the entry says (its own §Falsifier names exactly that case). BASE reading:
`C1_SOPS_AGE_TRIAL: value=0 absent=1`.

Tools (installed this round, official release binaries into `~/.local/bin`, pacman paused):
sops v3.13.3 (`sops-v3.13.3.linux.amd64`, sha256 `e5bec334…7fef6b`, matched the release's
`sops-v3.13.3.checksums.txt` and the GitHub asset digest); age v1.3.2 (`age-v1.3.2-linux-amd64.tar.gz`,
sha256 `cbe24006…6ac10` = the GitHub asset digest; `age-keygen` sha256 `0a0009db…37899`). Receipt
`controls/tool-install.txt`.

Frozen predicate: `C1_SOPS_AGE_TRIAL: value = number of tests T in {T1..T5} that DISCRIMINATE, when
PINS = 1 and SETUP_OK = 1 and NOSECRET = 1, else 0; target 5.`
- PINS: the sops and age-keygen binaries the counter puts on PATH carry the pinned sha256 above;
  otherwise SETUP (exit 2).
- DISCRIMINATE(T): the measured tree's `corpus/sops-age-trial.sh`, run under `env -i` with PATH =
  <counter bin dir>:/usr/bin:/bin, prints exactly one `TRIAL T HOLDS …` line with the real binaries
  AND exactly one `TRIAL T BROKEN …` line with T's designated falsifier shim (T1 updatekeys also
  rotates; T2 rotate is a no-op; T3 updatekeys is a no-op; T4 decrypt leaks plaintext to a refused
  identity; T5 encrypt collapses key groups into one) AND the entry has a `## Measured (round 48`
  section holding a line that starts `- T<n> ` and names `sops 3.13.3`.
- SETUP_OK: with no sops on PATH the trial exits 2 and prints no HOLDS line.
- NOSECRET: no run's stdout/stderr contains `AGE-SECRET-KEY`.
- Fail closed: a real run with no final `SOPS_AGE_TRIAL: ` line is SETUP; an absent trial script reads
  `value=0 absent=1` (the BASE state).

Tests T1–T5 (what each one makes measured; sources S009/S010/S011, re-opened this round):
T1 `updatekeys` adds a recipient without rotating the data key (S011 §rotate); T2 `rotate` re-encrypts
every value (S011 §rotate); T3 removal by `updatekeys` refuses the removed identity on the synced file
while a pre-removal copy still opens and the data key is unchanged (S011 §Direct Editing, compromise
order; entry [INFERENCE] on history copies); T4 editing creation rules alone leaves an existing file's
access unchanged until `updatekeys` (entry [INFERENCE]); T5 with two key groups the default threshold
is 2 and one group alone is refused (S010 §Key groups).

Controls (pre-freeze, expected values written before the first run): K1-0 do-nothing (BASE) 0;
K1-P reference trial + entry section 5; K1-F1 constant-HOLDS script 0; K1-F2 reference with the real
binaries forced onto PATH (shims bypassed) 0; K1-F3 reference without the entry section 0; K1-F4 silent
producer SETUP; K1-F5 reference with T5's threshold/single-group checks removed 4; K1-F6 entry naming
`sops 3.12.0` 0; K1-F7 unpinned sops binary SETUP; K1-F8 trial that prints an identity file 0.
Named ceilings: a trial that detects the counter's shims (e.g. by reading its own PATH or the shim
bytes) and answers BROKEN only under them passes; a trial that passes `--config` explicitly bypasses
the SH5 shim's `.sops.yaml` read. Both are visible in a reading of the script (reviewer leg).
Kill rules (frozen): C1 is killed if value < 5 at the candidate, if the counter exits 2 at the
candidate, if any committed file at the candidate contains `AGE-SECRET-KEY`, or if the candidate
removes or rewrites any pre-existing line of `corpus/knowledge/sops-age-key-rotation.md`
(`git diff BASE candidate -- <entry>` shows no `-` line).
Sourced: S009, S010, S011 (getsops.io docs; re-opened 2026-11-06 with located quotes in the lesson
§Gate), plus the release rows the scribe opens for sops v3.13.3 and age v1.3.2.

Target: value 5 at the candidate.

## C2 — calibration: the capabilities table's stated evidence readings agree with the commands' executed output, 3 → 0

Problem (measured): `SCORECARD.md` §Capabilities carries ten literal evidence pairs
"`<command>` ⇒ `<output>`". Executed at BASE in a clean checkout, three disagree:
`python3 -I -B corpus/quote-locate.py` states `located=5 rows=5`, executes `located=8 rows=8`;
`bash corpus/claims-declared.sh --root .` states `claims=2`, executes `claims=21`;
`bash corpus/claims-declared.sh --selftest` states `PASS (8 cases)`, executes `PASS (12 cases)`.
The lane's own repertoire table describes its gates with readings the gates no longer produce.

Frozen predicate: `C2_CAPABILITY_READINGS: value = MISMATCH, the number of the ten frozen BASE
evidence keys K01..K10 whose stated reading is MISSING or does not MATCH the executed reading at the
measured revision; target 0 (BASE 3).`
- Stated reading: the LAST occurrence of "`<command>` ⇒ `<output>`" inside the measured revision's
  `## Capabilities` section; none = MISSING (deleting a pair is not a fix).
- Executed reading: last nonempty stdout line of the key's frozen exec command in a clean
  `git clone --shared` checkout of the measured revision; empty/timeout/clone failure = SETUP.
- MATCH: byte-exact, except K04 (`detected=0`, a token of the laneguard selftest line).

BASE measured: `value=3` (K02, K07, K10 DIFF). Controls (pre-freeze): K2-0 do-nothing 3; K2-P
reference (one current-readings line inside the section) 0; K2-F1 stale pairs deleted 3; K2-F2 correct
readings outside the section 3; K2-F3 K10 only 2; K2-F4 K07 stated as `claims=22` 1.
Kill rules (frozen): C2 is killed if value > 0 at the candidate, if the counter exits 2 at the
candidate, if the candidate changes any byte of `corpus/*.sh`, `corpus/*.py` or `plans/round-39-c*.sh`
(the gates must not be bent toward the stated text), or if it removes any line of
`corpus/claims-declared.tsv` or `corpus/quote-bodies.tsv`. The table rows keep their historical
first-working readings; the fix is an added current-readings line (history is not rewritten).
Named ceiling: K07 reads a revision-bound count (`claims=N` grows by the round's own claim rows), so the
stated reading is correct only at the revision it names; the line says so.

Target: value 0 at the candidate.

## Non-claim work (no counter; recorded in the lesson)

- Frontier step: census before/after; `corpus/SOURCES.md` rows for the sops v3.13.3 and age v1.3.2
  release identities the trial pins (opened this round, located quotes); S009–S011 re-opened.
- Mistake mined into the lesson (`## Mistakes`), with a fix shown able to fail.
- Round-47 routed items: SKILL.md:826 states `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)` (executes 12) —
  corrected in place as a current-tense line; S098 (`rejected`, `on-release`) and the counter
  amendments of round-47 routed 1 are answered in this plan's counters only where named above
  (BASE-pinned binaries, fail-closed producers); the rest stays routed.

## Amendment A1 (pre-candidate, before any seat ran; no predicate, counter, control or target changes)

The C1 kill rule "if any committed file at the candidate contains `AGE-SECRET-KEY`" fires on the frozen
instruments themselves: this plan, `plans/round-48-c1.sh` and the reference trial name the literal as a
pattern (predeclaration `164f0ea5`, `grep -c AGE-SECRET-KEY` → plan 2, counter 2, fixture 1). Read the
rule as: "if any file committed at the candidate contains a key-shaped string, i.e. a match of the ERE
`AGE-SECRET-KEY-1[0-9A-Z]{58}` (a full Bech32 age identity)". At the predeclaration the whole lane tree
has 0 matches (`grep -rnE 'AGE-SECRET-KEY-1[0-9A-Z]{58}' . --exclude-dir=.git` → no output). The
counter's NOSECRET conjunct is unchanged (it reads run output, where the bare prefix never appears
legitimately). Recorded as mistake class "kill rule matches its own instrument" in the round lesson.
