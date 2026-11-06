# K48ScribeEntry — report (round 48, measured-section / capability-row / province-line drafts)

Seat: K48ScribeEntry (scribe). Lane: /home/vgpnk/Projects/shokunin/kagi-shokunin, branch master, BASE
76da518fcc3029e738648bd6fd4ba5571df01c1c. Date: 2026-11-06. No product file was edited; every
deliverable is a draft under `.ufo/waves/round-48/build/K48ScribeEntry/`.

## What was done (behaviour)

1. Read the frozen trial fixture `.ufo/waves/round-48/controls/fixtures/ref-sops-age-trial.sh` and the
   whole entry `corpus/knowledge/sops-age-key-rotation.md`; read the S009/S010/S011 rows of
   `corpus/SOURCES.md` (S009 §Encrypting using age, S010 §Key groups, S011 §updatekeys/§rotate/§Direct
   Editing/§compromise order, all anchored at docs commit 9b7b84e, last modified 2026-05-15).
2. Executed the trial myself in scratch and recorded the output verbatim (`trial-run.txt` §1):
   `env -i HOME=… PATH=… TMPDIR=… bash …/ref-sops-age-trial.sh --work "$S"` → five `TRIAL T<n> HOLDS`
   lines and `SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2`, RC=0.
3. Independently measured the Shamir threshold refusal (`trial-run.txt` §2): two-group rule, control
   `sops encrypt` rc 0 with encrypted metadata `shamir_threshold: 2`; probe
   `sops encrypt --shamir-secret-sharing-threshold 1` rc 1, empty stdout, stderr exactly
   `Could not generate data key: [could not split data key into parts for Shamir: threshold must be at least 2]`.
4. Drafted the append-only `## Measured (round 48 — …)` section, one SCORECARD capabilities row and one
   PROVINCE.md core bullet, all matching the lane's house formats and the frozen reference shape
   `.ufo/waves/round-48/controls/fixtures/ref-entry-measured.md`.
5. Verified the drafts locally against the counter's entry condition replicated from
   `plans/round-48-c1.sh` `entry_line()` (awk: section heading `/^## Measured \(round 48/`, line starts
   `- T<n> `, contains `sops 3.13.3`): T1..T5 all 1. Also scanned the drafts for secret shapes
   (an age secret-key prefix, an age recipient address, a private-key block header): no hits.

## Gates / checks run, with outcomes

| check | command (as run) | outcome |
|---|---|---|
| reference trial | `env -i HOME="$S/h" PATH=$HOME/.local/bin:/usr/bin:/bin TMPDIR="$S" bash …/ref-sops-age-trial.sh --work "$S"` | rc 0, 5/5 HOLDS, last line `SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2` |
| candidate trial (landing artifact) | `env -i HOME="$S/h5" PATH=/home/vgpnk/.local/bin:/usr/bin:/bin TMPDIR="$S" bash …/build/K48ExecTrial/sops-age-trial.sh --work "$S"` | rc 0, output byte-identical to the fixture run (5/5 HOLDS, same tokens, same final line); final sha256 `09f304ec…` |
| fixture identity | `sha256sum …/ref-sops-age-trial.sh` | `fa281506e343064b8786b59b9626f5ebb9f6d1ce193a3f408b68673db3bdf81c` = `controls/instrument-sha256.txt` entry |
| binary pins | `sha256sum ~/.local/bin/sops ~/.local/bin/age-keygen` | `e5bec334…fef6b`, `0a0009db…7899` — equal to the assignment's pins; nothing installed, upgraded or replaced |
| versions | `sops --version --disable-version-check`; `age-keygen --version` | `sops 3.13.3`; `v1.3.2` |
| threshold control | `sops encrypt --filename-override f.yaml plain.yaml` (two key groups) | rc 0, metadata `shamir_threshold: 2` |
| threshold refusal | `sops encrypt --shamir-secret-sharing-threshold 1 …` | rc 1, 0 bytes out, exact stderr quoted above |
| entry-check shape on draft | replicated awk from `plans/round-48-c1.sh` `entry_line()` over `measured-section.md` | `entry_check T1=1 T2=1 T3=1 T4=1 T5=1` |
| secret-shape scan | `grep -nE` over the four drafts with three character-class patterns (age secret-key prefix, age recipient address, private-key block header) | no hits |

Not run, deliberately: `plans/round-48-c1.sh`, `plans/round-48-c2.sh`, the lane's claim-ledger verify
and self-counts (host-heavy; the seat may run only the scripts its item names).

## Touched surfaces

Written (all inside seat scope):
- `.ufo/waves/round-48/build/K48ScribeEntry/measured-section.md`
- `.ufo/waves/round-48/build/K48ScribeEntry/capability-row.md`
- `.ufo/waves/round-48/build/K48ScribeEntry/province-line.md`
- `.ufo/waves/round-48/build/K48ScribeEntry/trial-run.txt`
- `.ufo/waves/round-48/build/K48ScribeEntry.md` (this report)

Read-only: the frozen fixture, `plans/round-48-c1.sh`, `plans/round-48-c2.sh`,
`corpus/knowledge/sops-age-key-rotation.md`, `corpus/SOURCES.md` (S009–S011, S033),
`SCORECARD.md` §Capabilities, `PROVINCE.md`, `controls/instrument-sha256.txt`,
`controls/fixtures/ref-entry-measured.md`, `.ufo/waves/round-48/build-spec.json`,
`.ufo/waves/round-48/build/K48ExecTrial/sops-age-trial.sh` (read-only; executed from its build path),
`git status --porcelain` on the lane (read-only). Scratch
`/fast/scratch/hyaku/kagi-r48/K48ScribeEntry` was created, used and removed; no private key,
plaintext or ciphertext left it.

Not touched: `corpus/` (no `corpus/sops-age-trial.sh` was created — the path did not exist in the tree
when this receipt was taken; it belongs to the exec seat), `plans/`, `SCORECARD.md`, `PROVINCE.md`,
`LOG.md`, `SOURCES.md`, `MANIFEST.json`, `.ufo/state`, `.ufo/watchdog.log`, templates/scripts, any
sibling repo, `~/.local/bin` or any PATH directory. No git mutation anywhere.

## Findings

- F1 (resolved for vocabulary, open only for landing): the measured section cites
  `bash corpus/sops-age-trial.sh --work <dir>` as the re-run command; that path did not exist when the
  receipt was taken, so the observed claims trace to (a) the frozen fixture the counter pins
  (sha256 `fa2815…`, the artifact `plans/round-48-c1.sh` executes as `$T/corpus/sops-age-trial.sh`) and
  (b) the candidate `K48ExecTrial/sops-age-trial.sh` (final sha256 `09f304ec…`, 12120 bytes; an earlier
  draft `2147fe9c…` was also run and emitted the identical block) that is to be landed there.
  Both produced byte-identical output today — 5/5 HOLDS, same detail tokens, same final line — so the
  bullets' quoted tokens bind to the script that will land; only the `corpus/` write itself remains
  with the exec/L1 seats.
- F2: the entry-check awk keeps `insec` true only until the next line matching `^## `; my draft's
  `**Does not establish:**` block uses nested `  - ` bullets and no `## ` line, so appending the draft
  at the end of `corpus/knowledge/sops-age-key-rotation.md` preserves the check. Appending anything
  after it with a `## ` heading would not break it either (the check only needs the section to exist),
  but a `## ` line *inside* the draft would.
- F3: the assignment's quoted refusal text omits the wrapper. Observed stderr is
  `Could not generate data key: [could not split data key into parts for Shamir: threshold must be at least 2]`;
  the draft quotes the whole line so the claim is byte-traceable to `trial-run.txt`.
- F4: T5's designated falsifier cannot be a threshold-1 shim (the tool refuses threshold 1 outright);
  the counter's SH5 collapses the key groups instead, which matches what the draft now records.
- F5: no key-shaped string is present in any draft; the section names no recipient, identity or
  ciphertext, only counts and booleans from the trial's own detail strings.
- F6 (routing, not a fix): C2's ten frozen K01..K10 pairs are untouched by the new row — its evidence
  pointer uses a command string outside the frozen set, so `stated_of()`'s "last occurrence" rule for a
  frozen key cannot be shadowed. If the L1 wants the row to carry an exact `` ⇒ `` pair, the one used is
  the trial's verbatim final line.

- F7 (process risk, observed): a peer's build artifact moved during the wave — the first candidate I
  hashed and ran (`2147fe9c…`, an earlier draft whose size I did not record) was superseded by
  `09f304ec…` (12120 bytes) after two edits
  (`SOPS_CONFIG` added to the unset list, two shellcheck annotations). Output was identical in both, so
  no draft text changed, but any receipt that pins a digest must be re-hashed and re-run when the
  artifact moves. Both revisions are recorded in `trial-run.txt` §1b; the run there is the final one.

## Out of scope (not attempted)

- Creating `corpus/sops-age-trial.sh`, editing `corpus/knowledge/sops-age-key-rotation.md`,
  `SCORECARD.md`, `PROVINCE.md` or `SOURCES.md` — drafts only; landing belongs to the L1/exec seats.
- New SOURCES rows for a sops 3.13.3 release page or the age-keygen release (S033 already carries the
  v3.13.3 release identity; K48ExecSources owns the source rows).
- Any change to the frozen plan, counters, controls or targets (`plans/round-48.md`,
  `plans/round-48-c1.sh`, `plans/round-48-c2.sh`, `plans/round-48-controls.sh`): findings against them
  are routed to the L1 verbatim, never edited here.
- The lesson draft (K48ScribeLesson) and the sources rows (K48ExecSources): other seats own them.

## Artifact paths (all under /home/vgpnk/Projects/shokunin/kagi-shokunin/)

- `.ufo/waves/round-48/build/K48ScribeEntry/measured-section.md` — append-ready `## Measured (round 48 — …)` draft (heading verbatim as specified; `- T1 `..` - T5 ` at column 0; 6th bullet = measured refusal; `**Does not establish:**` with 5 nested bullets).
- `.ufo/waves/round-48/build/K48ScribeEntry/capability-row.md` — one `## Capabilities` table row (Capability | What it can now do | Evidence pointer | First-working round = 48).
- `.ufo/waves/round-48/build/K48ScribeEntry/province-line.md` — one PROVINCE.md core bullet (`- **Core, round 48 — SOPS/age access, rotation and key groups, now executed:**`).
- `.ufo/waves/round-48/build/K48ScribeEntry/trial-run.txt` — commands, exit codes and verbatim output for the trial, the threshold probe and the version reads; also the binary and fixture sha256 bindings.
- `.ufo/waves/round-48/build/K48ScribeEntry.md` — this report.
