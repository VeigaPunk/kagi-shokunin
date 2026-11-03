# MAttackEol — C2 counter mutation test (round-30 build wave)

Seat: mutation-tester. Scope: mutate the smallest behavior-bearing point in isolated scratch
mirrors of the lane, run the same bounded detector on pristine / mutated / restored bytes, and
report killed / survived / inconclusive with before→after hashes.

Method: `git -C <lane> archive HEAD | tar -x -C <scratch>/<tree>/kagi-shokunin`, then strip CR on
`SKILL.md`, `corpus/SOURCES.md`, `corpus/claim-ledger.tsv` (the three routed D5 files). Mirror parent
carries a one-line `shokunin.conf` (`kagi|kagi-shokunin|…`) because the fleet census resolves a lane
arg through it (without it: exit 2 `config not found` / `unknown lane`). Each mutation ran on a
FRESH copy (`cp -a` of the pristine mirror); the mutated file was then copied back from the pristine
mirror and `cmp -s`-verified byte-identical before re-running the detector.
Receipts: `.ufo/waves/round-30/final/attack-eol/` (index in its `README.txt`).
Pristine LF mirror hashes (before and after every probe):

```
c5206b7c04996ddcc0805140f61e59b775e9373a7d89fa860e55c93734ff2162  SKILL.md
7d0aad4fef9aee947335e20d4a97853f6742808aaea371868a2bbcb6784e1e93  corpus/SOURCES.md
3419c6d50ea0c81c44d568446569675e40755945f37ce83c549b095b52701c7d  corpus/claim-ledger.tsv
```

Mutants M1/M2/M3 reproduce the BASE bytes exactly (SOURCES `f63eb591…`, SKILL `56b567cd…`,
ledger `5676ced7…`) — the mutation is the real defect, not a proxy.

## Baseline (pristine LF mirror) — recorded exactly

`/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root <mirror> kagi`

```
exit=0, 15 lines: W04 ×14 (duplicate-URL warnings, allowed) + `kagi	ok	<mirror>/kagi-shokunin/corpus/SOURCES.md`
```

No E12, no E01–E11, no W01–W03. Matches the plan's "0 modulo used-by/entry artifacts".
`bash corpus/checklist-run.sh --ratio` →

```
CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6      exit=0
```

`bash corpus/row-identity.sh ledger-ids` →

```
ROW_IDENTITY: ledger-ids count=67 sha256=917ef251a13141cab409f36f5a601c8f0e9b1244d14344d254ae7e4390586b85   exit=0
```

## M1 — CR back into `corpus/SOURCES.md` only → fleet census

**Verdict: KILLED.**

```
mutant sha256 f63eb5911ec54bdc…  (== BASE bytes)
census exit=1, 52 lines, all E12:
kagi	E12	S001 row outside Registry section
…
kagi	E12	S052 row outside Registry section
census-mode rows = 0 (the registry vanishes entirely, not just 52 findings)
restored: exit=0, E12=0, 14 × W04 + ok
```

Sensitivity matrix (each a fresh copy; all restored before the next):

| mutation of `SOURCES.md` | census exit | E12 | rows | verdict |
|---|---|---|---|---|
| full-file CRLF (M1) | 1 | 52 | 0 | **KILLED** |
| CR on `## Registry` heading only (M1b) | 1 | 52 | 0 | **KILLED** |
| CR on one data row S030 (M1c) | 0 | 0 | 52 | survived |
| CR on mined row S001 (has used-by) (M1d) | 0 | 0 | 52 | survived |
| CR on header + separator rows (M1e) | 0 | 0 | 52 | survived |
| CR inside the used-by cell (M1f) | 0 | 0 | 52 | survived |
| CR on ALL table rows, heading left LF (M1g) | 0 | 0 | 52 | survived |

Mechanism (read at `scripts/sources-census.sh:581`, confirmed by the matrix): the census's only
EOL-sensitive line is the `## Registry` heading — `trim()` strips `[ \t]`, not `\r`, so
`"Registry\r" ≠ "Registry"` and `in_registry` stays false. Row-level CR is absorbed by
`trim()`/`trim_cell()`, which strip `[:space:]`. So the detector is a **heading tripwire**, not a
row-drift detector: an EOL conversion that somehow left the heading LF would be invisible here
(counter 2 in its scoped form still catches it — M1g: scoped counter 2 = 1).

## M2 — CR back into `SKILL.md` only → `checklist-run.sh --ratio`

**Verdict: KILLED.**

```
mutant sha256 56b567cdb744a797… (== BASE bytes)
SETUP no `## Credential-hygiene checklist` section with `- [ ] ` items in …/SKILL.md
exit=2
restored: CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6   exit=0
```

Sensitivity: CR on the checklist heading alone (M2b) → same SETUP exit 2 (**killed**). CR on 5
checklist item lines with the heading intact (M2c) → `--ratio` exit 0 clean, and the FULL
checklist run is byte-identical to pristine (`CHECKLIST_RUN: BROKEN (items=16 runnable=9 by_hand=7
failed=7)`, exit 1 both — the 7 failures are the absent-substrate/host rows, identical on both
arms). This gate is a second heading tripwire; item-line drift survives `--ratio`, and the full
mode cannot discriminate it because the B-side baseline is red for a non-C2 reason.

## M3 — CR back into `corpus/claim-ledger.tsv` only → `row-identity.sh ledger-ids`

**Verdict: NOT KILLED by the assigned probe.** Recorded honestly, as instructed.

```
pristine   ROW_IDENTITY: ledger-ids count=67 sha256=917ef251a13141cab409f36f5a601c8f0e9b1244d14344d254ae7e4390586b85
M3 mutant  ROW_IDENTITY: ledger-ids count=67 sha256=917ef251a13141cab409f36f5a601c8f0e9b1244d14344d254ae7e4390586b85
restored   identical again
```

The selector digests the id list (`awk -F'\t' '$1 ~ /^R[0-9]+-[0-9]+$/{print $1}' | sort`); the CR
sits at the end of the LAST field, never in field 1 — so `ledger-ids` is structurally CR-blind, and
so are all 12 other file-based row-identity selectors (measured: pristine vs mutant identical for
each; `scorecard-rounds` IS CR-sensitive when `SCORECARD.md` itself converts — `92016a58…` →
`6add9e12…` — it just does not read the ledger).

Two other committed detectors DO kill M3:

- **counter 2 scoped form**: 0 → 1 (killed; see below).
- **`claim-ledger.sh verify` stamp detector**: only *after* the C2 re-stamp. Measured bracket:
  at BASE the three stamp rows were **re-pinned on the drifted bytes** (round-29: `fc65112`
  for SKILL+ledger, `bc2f3fd` for SOURCES — `pin == bytes` for all three), so `verify` prints
  **0 STALE** for SKILL.md / corpus/SOURCES.md / corpus/claim-ledger.tsv and is blind at BASE.
  In a scratch tree with the repair committed and stamps re-taken on LF bytes, adding CR back to
  the ledger yields exactly:

```
STALE corpus/claim-ledger.tsv sha=3419c6d50ea0->5676ced76cd3 lines=85->85 bytes=29820->29905
```

  (then `CLAIM_LEDGER: POLICY`, the pre-existing R29 rows). Restoring the LF bytes → 0 STALE.

Calibration consequence: the stamp gate's kill power for EOL drift depends on C2's own re-stamp step
— a repairing round that skips `claim-ledger.sh stamp` leaves the gate blind for the next round.

## M4 — `.gitattributes` draft with a wrong pattern (`*.md text eol=crlf`)

**Verdict: the wrong ruling IS observable, and it is catastrophic if committed.**

`git check-attr eol -- SKILL.md corpus/SOURCES.md corpus/claim-ledger.tsv` in an LF-index fixture
carrying only `*.md text eol=crlf`:

```
SKILL.md: eol: crlf
corpus/SOURCES.md: eol: crlf
corpus/claim-ledger.tsv: eol: unspecified
```

Consequence (measured, not inferred):

- A fresh checkout under that draft materializes CRLF in the worktree while **`git status` stays
  clean** — the drift is invisible to the one tool a reviewer is most likely to trust
  (`worktree_CR=813/193`, `idx=i/lf`, `git status --short` empty).
- A fresh `--no-local` clone under that draft checks out **all 99 tracked `*.md` files as CRLF**
  (SKILL.md, SOURCES.md, every lesson/knowledge/plan/consider-these file; fixture has `.ufo`
  removed, so 99/99); census exit 1 / E12 ×52, checklist SETUP exit 2, `git status` clean
  (`final/attack-eol/M4-exact-pattern.txt`).
- Control with the correct five-line draft (`*.md|*.tsv|*.sh|*.py|*.json text eol=lf`):
  `eol: lf` for all three, fresh clone CR-free, census exit 0 (14 × W04), checklist exit 0.

Two `.gitattributes` pitfalls measured that are not in the frozen text:

1. **`git add --renormalize .` is not a plain add.** With the live 5-line draft on a drifted index it
   stages **8** paths, not 3: the three production files **plus five round-29 evidence JSONs**
   (`.ufo/waves/round-29/final/c1-after.json`, `c1-before.json`, `c2-after.json`, `c2-base-gate.json`,
   `c2-base-plain.json`) — `866` changed lines in one of them. `* text=auto eol=lf` is worse:
   **135** files (70 `.headers`, 41 `.txt`, 12 `.hdr`, …). That is the plan's kill-rule trigger —
   use plain `git add -A` of the intended paths, never a blanket `--renormalize`.
2. **Attributes do not repair already-committed CRLF blobs.** `i/crlf` blobs + correct `eol=lf`
   attributes + fresh `--no-local` clone still checks out CRLF (813/193/85). Only a commit that
   rewrites the blobs (`git add` of the LF bytes, or `--renormalize` on exactly those paths) plus
   attributes prevents the next checkout from re-materializing CRLF.

## Counter-level findings against C2 (beyond the four assigned mutations)

1. **Counter 2 as frozen cannot print 0.** Measured with the plan's literal command
   (`grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj . | wc -l`):

   | tree | frozen form | + `--exclude-dir=.ufo` |
   |---|---|---|
   | raw BASE archive `f67232c` | 135 | **3** |
   | pristine LF mirror | 132 | **0** |
   | M1 / M2 / M3 mutants | 133 | **1** |
   | all-CR-stripped tree | 0 | 0 |
   | live lane worktree (15:45) | 165 | **0** |

   132–164 of those files are committed or wave-written `.ufo/waves/**` CRLF evidence (round-26/27
   `curl --dump-header` captures where CRLF is the RFC-correct byte shape, round-29 `final/*.json`,
   retained-probe `node_modules`, plus live round-30 receipts): the 132 in the repaired mirror are
   all under `.ufo/`, the raw BASE 135 = those 132 + the 3 drifted files, and the live worktree
   measured 165, all under `.ufo/` (non-`.ufo` 0 after the L1's in-progress repair). The plan's
   "before: 3" is only reproducible with `--exclude-dir=.ufo`. The scoped form is the satisfiable
   and discriminating one (3 → 0, mutants 0 → 1). Plan correction 1 (`d163290`) already re-scopes
   it; this measurement independently corroborates it.
2. **No committed gate reads `.gitattributes`.** `grep -rln gitattributes corpus/*.sh corpus/*.py`
   → empty; no ledger/self-counts row mentions it. Plan correction 1 item 6 adds R30-02
   (`grep -cE '^\*\.(md|tsv|sh|py|json) text eol=lf$' .gitattributes` == 5) — that form counts
   LINES and is defeated by a later override: five correct lines + one appended
   `*.md text eol=crlf` still counts **5** while the ruling flips to `crlf` (measured). A
   path-specific override (`SKILL.md text eol=crlf`) also keeps the count at 5. Preferred row:
   `git check-attr eol -- SKILL.md corpus/SOURCES.md corpus/claim-ledger.tsv | awk '{print $3}' | grep -cx lf`
   expecting `3` — that observes the actual ruling (control 3, override 2 for the md pair).
   Minor: trailing spaces or uppercase `eol=LF` drop the line-count form to 4 while the ruling is
   still `lf` (false red).
3. **Re-stamp ordering is load-bearing.** At BASE the stamp pins equal the CRLF bytes, so
   `claim-ledger.sh verify` reports 0 STALE for all three (blind). A repair that removes CR but
   forgets `claim-ledger.sh stamp` turns the gate red on its own repair (3 × STALE) and, worse,
   leaves the next round's drift unpinned. C2's text already names the re-stamp; this is the
   measured reason it must be ordered after the byte rewrite.

## Not established / limits

- M3's assigned detector (`row-identity.sh ledger-ids`) genuinely survives; the sentence "the
  ledger EOL drift is caught" is only true of counter 2 (scoped) and of the stamp gate **after**
  re-stamping. Do not cite `row-identity` as an EOL gate.
- M1c–M1g show the census is a heading tripwire; a partial row-level conversion passes census and
  checklist. Counter 2 (scoped) is the only committed counter that catches every one of these:
  measured scoped = 1 for each of M1c, M1d, M1e, M1f, M1g and M2c against pristine 0, while
  census exit = 0 and `--ratio` exit = 0 on all six.
- All mutation probes ran against `git archive HEAD` at `b7482b4` (the lane later advanced to
  `d163290`, plan-correction-1, which touches only `plans/round-30.md`; the three C2 files are
  untouched by it). In the live lane only read-only gates were run (fleet census, `checklist-run.sh
  --ratio`, `row-identity.sh ledger-ids`, `git check-attr`, `git status`, `sha256sum`); nothing in
  the lane was written by this seat other than its own report/receipt files, and no lane git
  mutation was performed.

## Housekeeping

Scratch `/fast/scratch/hyaku/kagi-r30/MAttackEol/` was removed after the receipts above were copied
into `.ufo/waves/round-30/final/attack-eol/`. No installs (no pacman, no uv, no npm); tooling used:
`git 2.56.0`, `python3 3.14.8`, `gawk 5.4.1`, `bash 5.2.37`. No credential material, no vault/`op`
sign-in, no `op://` values, no feed-token/release-clock work.
