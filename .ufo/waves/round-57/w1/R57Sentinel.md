# R57Sentinel — policy review: instruments, drafts and receipts (round 57 / w1 / attempt 1)

Seat: sentinel (attack share 5/12). Report only: no production edit, no lane git mutation,
no subagent dispatch. Lane `kagi-shokunin`, branch `master`, claim BASE
`1cda9e7ae4767b4133e283bfbc08266d4c86362d`, frozen predeclaration commit
`7aa1f4726e1f6bcdc8411d1a8b21828d49785173` (`2026-11-07T11:10:19-03:00`).

Read: `plans/round-57.md` (HEAD and working tree), `plans/round-57-c1-check.py`,
`plans/round-57-c1.sh`, `plans/round-57-c2.sh` (both versions), `plans/round-57-controls.sh`
(both versions), both control receipts, `w1-spec.json`, `w1-dispatch.json`, `swarm-registry.json`,
`corpus/current-claims.py`, `corpus/openbao-audit-trial.sh`, `w1/R57ExecTrial.d/*`,
`w1/R57ExecGate.md`, `w1/R57Labrat.md`, `w1/R57ScribeEntry.d/**`, `corpus/recheck-replay.py`.

Environment: Linux 7.2.11-arch1-1; bash 5.3.20(1); Python 3.14.8; git 2.56.0; grep
(pi-uu-grep) 0.2.0; sha256sum 0.8.0. Installs/updates: none. Scratch
`/fast/scratch/hyaku/kagi-r57/R57Sentinel/` only, deleted before yield.
Answering model: no in-session self-identification mechanism exists; the harness session
metadata states `amr/deepseek-v4.1-flash`, which is what I observe, not a guess.

**Headline.** C1's instruments are intact (`c1.sh`, `c1-check.py` byte-identical to the
freeze). The C2 contract moved twice after the freeze — A1 (lane `TRIAL T<n>` vocabulary)
and A2 (the labrat's measured default-refusal) — and the three affected frozen files (plan,
C2 counter, C2 controls) were edited **in place** and then committed as a disclosed second
freeze epoch, `03cbf656` at **11:20:45**: before any `plans/round-57-c2.sh` scoring of the
candidate (no counter run on the candidate exists), but after the labrat probe (11:13–11:15),
after the trial appeared (11:15:43) and after the executor's first receipts (11:16:55); the
plan's own A1 sentence "before the trial existed and before any candidate measurement" is
therefore false as written, and the wave's "do not amend in place" rule was breached. Target 5
and the kill rules did not move, both epochs are cited with hashes, and the epoch-B battery
re-read 11 MATCH; the harm is bounded but the round-57 tree no longer contains an unmodified
predeclaration — a non-author must read `7aa1f47` to recover it. Separately: the production
trial violated the plan's "no secret on any argv" invariant until 11:25:22 (**fixed and
re-verified after this review**), the frozen C1 checker prints a constant `unbound=0`
(confirmed, deliberately left frozen), and `R57Connector.md` carries a false "instruments
untouched / 10 selftest cases" claim.

## Timeline (mtimes and hashes, all observed)

| Time (-03:00) | Event | sha256 |
|---|---|---|
| 11:10:19 | freeze commit `7aa1f47` carries plan + 4 instruments + `controls/controls-prefreeze.txt` (11 MATCH, K2-MOCK **5**) | plan `5773c1a4…`, c2 `3de6b4de…`, controls `6796ae70…` |
| ~11:13–11:15 | `R57Labrat` probe: records the frozen hashes as unchanged (plan `5773c1a4…`, c2 `3de6b4de…`, controls `6796ae70…`); falsifies the default-server enable path (its F5) | — |
| 11:15:43 | production `corpus/openbao-audit-trial.sh` appears (new `TRIAL T<n> HOLDS` vocabulary) | `3e8bcc4c…` |
| 11:16:29 | `plans/round-57-c2.sh` edited in place; header says "Amendment A1 (pre-candidate … before the trial existed)" | `3de6b4de…` → `140a8f2b…` |
| 11:16:55 | `w1/R57ExecTrial.d/openbao-audit-trial.sh` (executor draft, **plan** vocabulary `TEST T<n>:`, `AUDIT_TRIAL: CLEAN`) | `b7082309…` |
| 11:18:45 | `plans/round-57.md` edited in place: C2 predicate + POP rewritten, amendments section added, controls paragraph re-pointed to "epoch B" | `5773c1a4…` → `b130bb83…` |
| 11:19:02 | `plans/round-57-controls.sh` edited in place: K2-STUB/K2-MOCK fixtures and expectations changed; **K2-MOCK 5 → 0** | `6796ae70…` → `09f334cb…` |
| 11:19 | `controls/controls-prefreeze-epochB.txt` written (11 MATCH, K2-MOCK 0) | — |
| **11:20:45** | **epoch B committed: `03cbf656943b33bf93607f607bbbeb55d500b0f9`** — carries the amended plan, counter, controls and the epoch-B receipt (4 files, +180/−62). No `c2.sh` scoring of the candidate exists at any time | plan `b130bb83…`, c2 `140a8f2b…`, controls `09f334cb…` |
| 11:25:22 | production trial fixed after this seat's H-3: `hashof` sends its JSON body on stdin (`bao write … -`), `count_plain` uses `grep -cF -f -` | `3e8bcc4c…` → `7e645194…` |

The plan's own A1 sentence ("before the trial existed and before any candidate
measurement") is contradicted by the 11:15:43 trial mtime, and A2 in the same plan admits
it was made "after the labrat's independent probe" — i.e. after a candidate measurement.
`plans/round-57.md:102` still reads "## Pre-freeze controls (executed before this commit,
receipt under the wave dir)" while the body now cites epoch B, which was executed 9 minutes
after that commit.

## Controls — one line each, exact command (cwd = lane root)

Freeze-time verdicts are from the surface as committed at `7aa1f47`; the current-surface
verdict re-reads the same control against the working tree at 11:20–11:25.

| # | Control | Command | Verdict |
|---|---|---|---|
| C-01 | Frozen instruments unamended relative to the predeclaration | `sha256sum plans/round-57.*` vs `grep '^INSTRUMENT' .ufo/waves/round-57/controls/controls-prefreeze.txt`; `git diff --stat -- plans/` | **FAIL (predeclaration)** — 3/5 differ from `7aa1f47`: plan `b130bb83`, c2 `140a8f2b`, controls `09f334cb`; `c1.sh 3104b06f` and `c1-check.py 19d75337` still match. The three are now **committed** as epoch B `03cbf656` (11:20:45), so `git diff` is empty and the tree is self-consistent; the divergence is historical, not dirty |
| C-02 | Freeze predates candidate work | `git log -1 --format=%H%x20%cI 03cbf656`; `stat -c '%y %n'` on candidate files | **FAIL as to measurement, PASS as to scoring** — epoch B commit 11:20:45 is after the labrat probe (11:13–11:15), the trial (11:15:43) and the executor's first receipts (11:16:55), but no `plans/round-57-c2.sh` run on the candidate exists at any time, so no score precedes it. Freeze `7aa1f47` (11:10:19) predates all candidate work |
| C-03 | Claim BASE single-sourced | `grep -n '1cda9e7' plans/round-57.*` | **PASS** — plan:3, c1.sh:27, c2.sh:21, controls.sh:13; checker takes `--root` |
| C-04 | C1 checker reads only the measured-tree files | python audit hook over `runpy(plans/round-57-c1-check.py --root <BASE extract>)` | **PASS** — 109 `open` events: 10 under the root, 96 stdlib, 3 the checker source. 1 `Popen('/usr/bin/python3')` |
| C-05 | Counters do not execute candidate-controlled code | `bash plans/round-57-c1.sh --tree <BASE extract + marker-writing corpus/recheck-replay.py>` | **FAIL** — marker created, counter rc=0 (see H-3) |
| C-06 | Printed `unbound` is truthful | `python3 -I -B plans/round-57-c1-check.py --root <BASE minus epochF receipt + plans/round-56.md>` | **FAIL** — 5 `STMT … UNBOUND`, final line `unbound=0` (M-1) |
| C-07 | Instrument docstring matches its authority | `sed -n '20,24p' plans/round-57-c1-check.py` vs `grep -n 'epoch_declared' …` | **FAIL** — docstring says receipt-file count, code counts plan tokens (M-3); independently observed by `R57ExecGate.md:97` |
| C-08 | C1 reproduces BASE 3 | `python3 -I -B plans/round-57-c1-check.py --root <pristine BASE extract>` | **PASS** — `value=3 population=16 mismatches=3 … guard=1`, rc=1 |
| C-09 | Checker/gate parity at the tip | `python3 -I -B corpus/current-claims.py --root .` vs the checker | **PASS on value/population** (both `value=0 population=16`, rc=0); `unbound` diverges on an UNBOUND tree (0 vs 5) |
| C-10 | C2 reads 0 at BASE | `bash plans/round-57-c2.sh --tree <pristine BASE extract>` | **PASS** — `value=0 … (absent)`; also `(absent)` with the amended counter |
| C-11 | C2 rejects a shim-agnostic trial | `bash plans/round-57-c2.sh --tree <BASE + 8-line constant-FAIL trial>` | **FAIL at freeze** (`value=5`), **PASS after the A1 amendment** (`value=0`, H-1/H-2) |
| C-12 | C2 measures its declared population | `grep -n 'tests=5' plans/round-57-c2.sh` | **FAIL at freeze** (`tests=5` literal, no per-test parse); amended counter parses `TRIAL T<n>` vectors but still prints a literal `tests=5` |
| C-13 | C2 cannot echo token-shaped output | `grep -n 'LAST\|printf\|nosecret' plans/round-57-c2.sh` | **PASS after A1** — the amended counter greps its own log dir for `r57-[0-9a-f]{24}`, `hvs|hvb\.`, `s\.[A-Za-z0-9]{20,}` and forces `value=0` on a hit; it does not scan argv (see H-3, fixed in the trial). At freeze: **FAIL** (raw `(last=%s)` echo) |
| C-14 | Counter scratch discipline | `grep -n 'TMPDIR\|mktemp\|HYAKU_SCRATCH' plans/round-57-c*.sh`; `git archive 1cda9e7 \| wc -c` | **FAIL** — `c1.sh:38` still `mktemp -d "${TMPDIR:-/tmp}/…"` and each run materialises 181,780,480 bytes; amended `c2.sh` now uses `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r57/c2-counter.$$` (fixed) |
| C-15 | Secret-shape sweep over planned files, drafts, receipts | `grep -nE 'op://\|hvs\.\|hvb\.\|BAO_\|s\.[A-Za-z0-9]{20,}\|ghp_\|xox[bap]-' <round surface: 78 files at 11:28>` | **PASS** — 0 credential material; every hit is the `BAO_` substring of `OPENBAO_AUDIT_TRIAL` or the quoted denial-class sentence (L-2) |
| C-16 | HTTP captures carry bodies only | `grep -rniE 'authorization:\|set-cookie\|cookie:\|www-authenticate\|x-vault' .ufo/waves/round-57` | **PASS (now exercised)** — 2 browser captures (`audit.browser.html` 41,787 B, `commands_audit.browser.html` 33,338 B, both start `<!doctype html>`) + 4 `.body` captures in `R57ScribeLesson.d/capture/` + `fetch-receipt.txt` (http/bytes/sha256 only): 0 header shapes, 0 secret shapes |
| C-17 | Trial never prints a token or the written value | `grep -nE 'echo\|printf' corpus/openbao-audit-trial.sh \| grep -iE 'token\|value'`; receipts | **PASS on stdout** — only counts/flags are echoed (`raw-value-plaintext=<n>`, `raw-token-cleartext=<n>`); receipts carry no token shape; argv now clean after the 11:25:22 fix (H-3, verified) |
| C-18 | No credential/header shapes in committed artifacts | C-15 + `[A-Za-z0-9_-]{24,}` sweep + C-16 | **PASS** — remaining long literals are identifiers, the BASE (40 hex) and instrument digests (64 hex) |
| C-19 | No host mutation by this seat | `git status --porcelain` before/after (11:17 → 11:24); scratch-only writes | **PASS** — at 11:24 only my two paths under `w1/` had been added by me; the L1's landing edits that appear later (`corpus/knowledge/openbao-audit-device-custody.md`, `corpus/README.md`, `corpus/SOURCES.md`, `corpus/claim-ledger.tsv`, `.ufo/waves/round-57/capture/`) are not mine |
| C-20 | Wave composition inside the band | `python3` over `w1-spec.json`/`w1-dispatch.json` | **PASS** — 12 items; `waveMinLanes=8`, `waveMaxLanes=16`, `maxLanes=256`; `counts.spawn=12`; attack = reviewer/critic/mutation-tester/sentinel/labrat = 5/12; no model passed |
| C-21 | Seat write-path discipline | 12 `Report:` trailers from `w1-dispatch.json` | **PASS** — 12/12 under `.ufo/waves/round-57/w1/`; scribe draft target `…/R57ScribeEntry.d/` with "do not edit corpus/" |
| C-22 | Drafts and receipts present | `find .ufo/waves/round-57/w1 -type f` (11:27) | **COMPLETE for the attack/scout/scribe seats observed** — `R57ExecTrial.md` + draft + 12 receipts, `R57ExecGate.md` + gate draft, `R57Labrat.md` + 19 `.d` files, `R57ScribeEntry.md` + entry draft + 2 captures + precondition receipt, `R57ScribeLesson.md` + lesson draft + 4 body captures + 2 receipt files, `R57Connector.md`, `R57Sentinel.md`; also `.ufo/waves/round-57/final/trial-shims.txt`; reports still absent for ScoutSurface, ScoutSources, ReviewC1, CriticC2, MutChecker |
| C-23 | Counter inherits no vault credentials | `env \| grep -oE '^(BAO_[A-Z_]*\|VAULT_[A-Z_]*)='`; `grep -n 'env -i' plans/round-57-c2.sh` | **PASS** — none set; the amended counter runs the trial under `env -i HOME=… PATH=… TMPDIR=… LANG=C`; the trial itself unsets inherited `BAO_*`/`VAULT_*` (trial:66) |
| C-24 | bao pin is real | `sha256sum ~/.local/bin/bao` vs `PIN_BAO=plans/round-57-c2.sh:22` | **PASS** — `9c5f3628…bd41b788`, OpenBao 2.7.2, 181,848,661 B; no `/usr/bin/bao` or `/bin/bao` |
| C-25 | Committed controls still describe the on-disk counter | `bash plans/round-57-c2.sh --tree <K2-MOCK tree from the freeze-era receipt>` | **FAIL against epoch A, MATCH against epoch B** — the freeze-era fixture reads `value=0` where `controls-prefreeze.txt` (epoch A) says 5; the authoritative epoch-B receipt says 0. Two receipts, two contracts, one instrument |
| C-26 | Plan predicate == counter predicate | `git diff -- plans/round-57.md plans/round-57-c2.sh` | **FAIL** — both rewritten at 11:16–11:18; the predeclared sentence no longer exists in either file (H-1) |
| C-27 | Landed C1 gate is the reviewed artifact | `sha256sum corpus/current-claims.py .ufo/waves/round-57/w1/R57ExecGate.d/corpus/current-claims.py` | **FAIL (traceability)** — landed `e36472b3…` (15,816 B, 391 lines, `--selftest` PASS 13 cases) ≠ reviewed port `40ec0c64…` (22,604 B, 10 cases); no seat report names the landed hash (M-4) |

## Secret-shape sweep — all hits triaged

Command (cwd = lane root; 19 files: 5 instruments, `corpus/current-claims.py`,
`corpus/openbao-audit-trial.sh`, spec, dispatch, registry, both control receipts,
`R57ExecTrial.d/*` trial + 2 receipts, `R57ExecGate.md`, `R57ExecGate.d/current-claims.py`,
`R57ScribeEntry.d` entry + 2 captures):

    grep -nE 'op://|hvs\.|hvb\.|BAO_|s\.[A-Za-z0-9]{20,}|ghp_|xox[bap]-' <files>

Snapshot at 11:28 over the whole round surface (78 files: `plans/`, the five `corpus/` files
in play, every file under `.ufo/waves/round-57/`):
**122 matching lines, 186 matches, 0 credential material.**
Per class: `BAO_` 142, `op://` 13, `ghp_` 13, `hvs.` 10, `hvb.` 8, `s.`+20-alnum 0.
The count grows with the wave: the seat prompts, each scribe/executor/labrat report that
documents the sweep, and this report all quote the class list, and every artifact that names
`OPENBAO_AUDIT_TRIAL` matches `BAO_`. No file contains a value after any class prefix —
`op://` and `ghp_` appear only in the sentinel seat prompt and in sweep documentation;
`hvs.`/`hvb.` only inside "no `hvs.`/`hvb.` token values"-style sentences.

Attribution: `op://` and `ghp_` occur **only** in the seat prompt (spec/dispatch) and in my own
report/receipt (which quote the class list as instructed); `hvs.`/`hvb.` occur **only** in prose
denial-class mentions (`R57Labrat.md` leak-check line, `R57ScribeLesson.d/round-57.md`, my
report); `BAO_` occurs only inside the identifier `OPENBAO_AUDIT_TRIAL`; no file contains an
`s.`-prefixed 20+ character payload. No draft, receipt or capture carries credential material.

| Hits | Class | Triage |
|---|---|---|
| `openbao-audit-trial.sh` 18, `c2.sh` 6, `controls.sh` 3, `round-57.md` 1, `R57Connector.md` 1, `R57ExecTrial.md` 1, ExecTrial draft 2, `receipt-ref-{real,real2,none}.txt` 2 each, `R57Labrat.md` 1, `R57Labrat.d/probe{2,3,4}.sh` + `probe.sh` + `probe4.py`, `R57ScribeLesson.d/round-57.md` 1 | `BAO_` | **Prose/identifier collision** — every hit is the substring `BAO_` inside `OPENBAO_AUDIT_TRIAL` (`OPEN`+`BAO_`+`AUDIT_TRIAL`). No `BAO_TOKEN=`, `BAO_ADDR=`, or env value anywhere |
| `w1-spec.json:92`, `w1-dispatch.json:210` | `op://`, `BAO_`, `ghp_` | **Prose collision** — the sentinel seat prompt quotes the denial-class list: ``grep -nE` for the handler's denial classes (op://, hvs\\.\|hvb\\.\|BAO_\|s\\.[A-Za-z0-9]{20,}\|ghp_\|xox[bap]-)`` |
| `R57Labrat.md` (`hvs\.`, leak-check line), `R57ScribeLesson.d/round-57.md` (`hvs\.`/`hvb\.` in the denial list), my `R57Sentinel.md`/`sweep.txt`/`argv-leak.txt` | `hvs.` 3, `hvb.` 2, `op://`/`ghp_` | **Prose collision** — pattern text, no value follows any of them |

No `s.`+20-alnum payload exists in any file; no `BAO_TOKEN=`, `hvs.<key>`, `op://<vault>/<item>`
or `ghp_<token>` value exists in any artifact. The 64-hex instrument digests and the 40-hex
BASE are the only long literals; `r57-<24 hex>` appears only as a regex in the amended
counter's guard, never as a value. The `hvs.`/`hvb.` hits are prose because the *definition*
of the class is quoted in the labrat report, the lesson draft, my report, and the seat prompt —
a self-reference that makes any wave-wide sweep of this regex noisy (L-2).

Post-snapshot additions (landed by the L1 at 11:21–11:27, swept separately):
`corpus/knowledge/openbao-audit-device-custody.md` (7,699 B) has `BAO_DEV_ROOT_TOKEN_ID` /
`BAO_TOKEN` / `OPENBAO_AUDIT_TRIAL` prose, 0 header shapes, 0 token values;
`corpus/lessons/round-57.md`, `corpus/README.md`, `corpus/SOURCES.md`,
`corpus/claim-ledger.tsv`: 0 credential shapes (the lesson's single hit is the
`token-on-argv` mistake title); `.ufo/waves/round-57/final/trial-shims.txt` (4 `BAO_` hits,
all `OPENBAO_AUDIT_TRIAL`); `capture/S115.body`, `capture/S116.body` (41,787 / 33,338 B) and
`capture/fetch-receipt.txt` (196 B, `http=200 bytes=<n> sha256=<hex>` only): 0 hits, 0 header
shapes. The fixed trial (`7e645194…`) adds no shapes.**No credential material entered any
artifact.**

## Findings

### H-1 — **High** (was filed Critical; recalibrated on the L1's evidence) — the predeclaration and two frozen instruments were amended in place after the freeze, then committed as a disclosed epoch B
- Evidence: mtimes 11:16:29 / 11:18:45 / 11:19:02 against the 11:10:19 freeze; hashes
  `3de6b4de→140a8f2b`, `5773c1a4→b130bb83`, `6796ae70→09f334cb`; the amendments were
  **committed** as `03cbf656943b33bf93607f607bbbeb55d500b0f9` at **11:20:45** together with
  `controls/controls-prefreeze-epochB.txt` (4 files, +180/−62), so `git status` no longer
  shows them modified and the working tree's hashes equal the commit's.
  `R57Labrat.md` records the frozen hashes as unchanged at probe time and its F5 falsifies
  the frozen T1 path; the plan diff rewrites the C2 "Frozen predicate (verbatim…)" and the
  POP and adds an "Amendments" section whose A1 claims "before the trial existed and before
  any candidate measurement" while the trial's mtime is 11:15:43 and the executor's first
  receipts are 11:16:55, and A2 admits "after the labrat's independent probe";
  `plans/round-57.md:102` still asserts "Pre-freeze controls (executed before this commit…)"
  over an epoch-B receipt produced 9 minutes after that commit.
- Calibration — what the L1's disposition establishes and I verified: target 5, BASE 0 and
  both kill rules are unchanged; the epoch-B battery re-ran 11 MATCH under the amended
  instruments; **no `plans/round-57-c2.sh` run on the candidate exists at all** (the only
  `C2_AUDIT_TRIAL:` lines in the wave are the two control receipts and seat quotations), so
  no score was taken under a superseded predicate; the predicate change was motivated by the
  labrat's measurement of the *binary* (default-server refusal), not by a candidate result;
  and the change is disclosed with both epochs and their hashes in the plan, the counter
  header and the lesson draft. That bounds the harm: the C2 claim is falsifiable under epoch
  B, not hindsight-fitted to a candidate score. What survives as defect: (a) the A1
  provenance sentence is false as written; (b) the wave rule "do not amend them in place"
  was breached, and the round-57 tree no longer contains an unmodified predeclaration — a
  non-author must know to read `7aa1f47`; (c) commits made mid-wave cannot be distinguished
  from predeclaration by content alone, only by timestamp.
- This seat's dissent, verbatim (as filed at 11:24, before the epoch-B commit was known to
  me): *"the round's predeclaration and two of its frozen instruments were amended in place
  after the freeze and after measurements"* and *"the round's C2 claim is unfalsifiable as
  published"*. I withdraw the second clause on the L1's evidence (epoch B is committed,
  disclosed, and no candidate score precedes it); I maintain the first: the amendment
  happened after the freeze and after the labrat's measurement, the A1 sentence asserting
  otherwise is false, and the remediation I proposed (keep `7aa1f47` as the round-57 record)
  was declined.
- Smallest remediation (as filed): restore the three files from `7aa1f47` as the round-57
  record; carry the improved counter/predicate as a **new** instrument with its own dated
  predeclaration committed before any measurement of the new contract. **L1 disposition
  (11:26): declined** — "the pre-A1 counter is the one the lane's conventions made wrong …
  reverting would hide a measured binary fact"; the round is recorded as the round-56 D8
  process-defect class with both epochs cited, and no further epoch will be created after
  candidate measurement. Accepted as a recorded, bounded defect; the dissent stands in this
  report for the closure reader.

### H-2 — **High** — three incompatible C2 vocabularies; the amended counter rejects a trial that satisfies the predeclared predicate
- Evidence: the predeclared plan and the executor draft speak `TEST T<n>:` + `AUDIT_TRIAL:
  CLEAN (tests=5 pass=5)` (`R57ExecTrial.d/openbao-audit-trial.sh`, sha `5f74da86…`, 9,073 B,
  11:19:10; its 11:19 receipts show the real run `TEST T1..T5: HOLDS` +
  `AUDIT_TRIAL: CLEAN (tests=5 pass=5)` rc=0, and exactly one `BROKEN` per shim). An earlier
  revision of the same draft (8,369 B, `b7082309…`, 11:16:55) failed all five with
  `fatal: audit enable failed`; the 11:19 receipts supersede it. The amended counter and the
  production trial speak `TRIAL T<n> HOLDS|BROKEN|ERROR` + `OPENBAO_AUDIT_TRIAL: HOLDS
  holds=5 …`. Demonstration: a tree whose trial prints `TEST T<n>: HOLDS` for all five and
  `AUDIT_TRIAL: CLEAN (tests=5 pass=5)` (the predeclared form, i.e. exactly the executor's
  CLEAN run) reads `C2_AUDIT_TRIAL: value=0 … vectors=0/5` under the on-disk counter (rc=1);
  the committed K2-MOCK fixture reads `value=0` where the committed receipt says `5`.
- Exploit path: an honest trial written to the predeclared contract scores 0; only the
  post-hoc vocabulary scores. A round could therefore "land" a capability by rewriting the
  contract rather than by making the trial work.
- Impact: the wave's only compliant trial draft (5/5 with five one-test falsifiers) and the
  wave's only counter disagree by vocabulary alone; the nine `R57ExecTrial.d` receipts are
  evidence the on-disk counter cannot read.
- Smallest remediation: one vocabulary, declared once and frozen (the `TRIAL T<n>` form is
  the better contract — it carries per-test identity); re-point the executor draft to it and
  re-run the receipts under the frozen instrument, or revert the counter (H-1) and keep the
  plan's form.

### H-3 — **High**, fixed after review and verified — the production trial put the value and the root token on child-process argv
- Evidence: `corpus/openbao-audit-trial.sh:117` — `out=$(bao write -format=json
  "sys/audit-hash/$1" input="$2" …)` puts the KV value nonce on `bao`'s argv (T2, T4);
  `:122` — `count_plain() { grep -cF -- "$2" "$1" …; }` with `:168-169`
  `count_plain "$RLOG" "$BAO_TOKEN"` puts the dev **root token** on `grep`'s argv (and the
  nonce too, at `:160`). The trial's header (`:29-33`) claims "no token or value on any
  argv". `ps`/`/proc/<pid>/cmdline` exposes both for the duration of each call to any
  same-user process; the amended counter's guard scans output logs only and cannot see it.
  The executor draft is better on the token (it reads it from `<work>/.root-token` into the
  environment only — draft `:127-164`) but still greps the written nonce:
  `grep -qF -- "$NONCE1" "$LOG_DEF"` (`:197`), `grep -qF -- "\"value\":\"$NONCE2\"" …`
  (`:207`), `grep -qF -- "$NONCE2" "$LOG_DEF"` (`:208`).
- Exploit path: a co-resident same-user process polls for `grep`/`bao` cmdlines during the
  trial and harvests the dev root token (full authority over the throwaway server) and the
  written value — the exact material the plan promises never to expose.
- Impact: a stated invariant of the C2 POP is false in the implementation; the receipts
  themselves are clean, but the guarantee is not — and the landed production entry
  `corpus/knowledge/openbao-audit-device-custody.md:33-34` (7,699 B, 11:22) now repeats the
  claim ("is on any argv: the random root token reaches the server through
  `BAO_DEV_ROOT_TOKEN_ID` and the client through `BAO_TOKEN`, values are written as `v=-`
  from stdin"), so the false invariant is on its way into a committed artifact.
- **Resolution (verified 11:27)**: the trial was fixed at 11:25:22 —
  `corpus/openbao-audit-trial.sh` sha `3e8bcc4c…` → `7e645194…` (10,922 B); `hashof()` now
  sends `{"input":"…"}` as a JSON body on stdin (`bao write -format=json "sys/audit-hash/$1" -`,
  line 118) and `count_plain()` reads its pattern through `grep -cF -f -` (lines 123-126).
  Re-scan: no `input=` on any argv, no nonce/token as a grep argument; `kv put` still uses
  `v=-` on stdin. The `(detail)` fields remain counts/flags only. The landed entry's sentence
  is now true of the current trial (it was false when written at 11:22 against `3e8bcc4c…`).

### H-4 — **Medium** — a committed seat report asserts the frozen instruments are untouched, and its verification numbers belong to other artifacts
- Evidence: `w1/R57Connector.md` (14,453 B, mtime **11:21:06**, i.e. after the 11:16–11:19
  amendments) §4.4: "The frozen instruments (`plans/round-57-c1-check.py`,
  `plans/round-57-c1.sh`, `plans/round-57-c2.sh`, `plans/round-57-controls.sh`) remain
  completely untouched" — three of the four are modified (`git status`), and the claim lists
  no hash. Its §4.5 verification: `python3 corpus/current-claims.py --selftest` "passes 10/10"
  — the landed gate prints `CURRENT_CLAIMS_SELFTEST: PASS (13 cases)` (my run); and
  `bash corpus/openbao-audit-trial.sh` "prints `OPENBAO_AUDIT_TRIAL: HOLDS …`" — that is the
  production trial, while the executor draft it shares a wave with prints `AUDIT_TRIAL: CLEAN`.
  So the report's three numbers describe three different artifacts and none of them the frozen
  set at that timestamp.
- Exploit path: a downstream reader (L1 closure, next round's spot-check) takes "untouched"
  and "10/10" at face value and signs a closure whose premise is false — the exact
  stale-self-description failure the round exists to remove.
- Impact: unverified readiness claim in a committed round artifact; it is also the only
  cross-seat statement about instrument integrity in the wave, and it is wrong at its own
  mtime.
- Smallest remediation: the connector (or L1) re-states the integrity check as
  `sha256sum plans/round-57.*` output with the observed hashes and the epoch they belong to,
  and re-runs each quoted command against the artifact it names before the receipt is kept.
- **L1 disposition (11:26)**: accepted as a mistake, not cited as evidence; to be recorded in
  `corpus/lessons/round-57.md` as M57-7 with `R57Connector.md` as the pointer. Verified at
  11:27: the lesson file carries M57-1…M57-6 only (M57-6 is a different, scout-side
  token-on-argv finding), so **M57-7 is still owed** at this report's close.

### M-1 — **Medium** — the frozen C1 checker prints a constant `unbound=0`
- Evidence: `plans/round-57-c1-check.py:250` (`unbound=0` literal) and `:176`; `stmt()`
  counts `population`/`bad` only. On a BASE extract with the epoch-F receipt and
  `plans/round-56.md` removed: five `STMT … UNBOUND` lines, final
  `value=6 population=16 mismatches=6 unbound=0 … guard=1` (rc=1); the planned gate prints
  `unbound=5` on the same tree. `value` is correct (UNBOUND counts into `bad`), so C1's
  predicate and kill rule (c) are not falsified — the field is.
- Exploit path: none for a third party; a reviewer quoting `unbound=0` under-counts.
- Impact: the instrument that audits numeric self-descriptions publishes a false one; the
  gate and the checker disagree on a field of their own contract.
- Smallest remediation: count and print `unbound` in the planned gate (it already does) and
  add "the frozen checker prints `unbound=0` as a constant" to the round's named ceilings;
  do not amend the frozen file.
- **L1 disposition (11:26)**: confirmed and deliberately **not** fixed — the checker is the
  frozen instrument the candidate was measured under, so an edit now would be a
  post-measurement instrument change; recorded as a named diagnostic defect. Verified: the
  landed `corpus/current-claims.py` prints the real number (my runs: 13 selftest cases pass;
  `unbound=5` on my forged tree), so next round's gate inherits the fix.

### M-2 — **Medium** — the counters execute candidate-controlled code with the verifier's privileges
- Evidence: `c1-check.py:100-113` runs `<tree>/corpus/recheck-replay.py --selftest` with
  `cwd=<tree>`; `c2.sh` runs `<tree>/corpus/openbao-audit-trial.sh`. Demonstration: a BASE
  extract whose `recheck-replay.py` writes `MARKER-EXECUTED-BY-CHECKER` and prints
  `PASS (20 cases)` — after `bash plans/round-57-c1.sh --tree <tree>` the marker exists and
  the counter still printed `C1_CURRENT: value=3 …`, rc=0. The amended counter softens this
  for C2 (`env -i`, per-run dirs) but not for C1, and neither restricts filesystem writes.
- Exploit path: a candidate revision supplies the authority script; it can forge the cases
  authority and read/write anywhere the invoking user can. The plan's ceiling covers forged
  *data*, not executed *code*.
- Impact: "reads only lane files" holds for the checker's own 10 opens (C-04) but not for
  the process tree; "no host mutation" is not mechanically guaranteed.
- Smallest remediation: pin the authority script by sha256 to the lane tip and run the
  lane's copy against the extracted tree; run children under `env -i` and a read-only cwd.

### M-3 — **Low** — frozen checker's docstring misdescribes the EPOCHS authority
- Evidence: `plans/round-57-c1-check.py:22-23` says the authority is the number of
  `controls-prefreeze-epoch*.txt` files; `epoch_declared()` (`:124-131`) counts distinct
  `epoch-[A-F]` tokens in `plans/round-56.md` (matching the plan and `c1.sh:14-17`); the
  `--verbose` label `via=receipt-file-count` (`:242`) repeats the wrong description — seen
  live as `via=receipt-file-count UNBOUND` on the M-1 demo. Corroborated independently by
  `w1/R57ExecGate.md:97`. `import glob` is unused in both the checker and the gate.
- Impact: the same documentation/implementation divergence class the round was chartered to
  remove, inside the instrument itself; a reader "fixing" the code to the docstring would
  change the measured population.
- Smallest remediation: state the divergence in the landing note; the new gate's docstring
  is already code-true (keep it that way).

### M-4 — **Low** — the landed C1 gate is not the reviewed gate
- Evidence: `corpus/current-claims.py` sha `e36472b3…`, 15,816 B, 391 lines,
  `--selftest` → `CURRENT_CLAIMS_SELFTEST: PASS (13 cases)`; the seat's reviewed port
  `w1/R57ExecGate.d/corpus/current-claims.py` sha `40ec0c64…`, 22,604 B, 10 cases. No seat
  report names the landed hash; the plan's C1 kill rule (c) binds the *committed* gate.
- Impact: the artifact that will be measured at landing has not been the one reviewed; the
  parity claim in `R57ExecGate.md` covers only its draft.
- Smallest remediation: `R57ReviewC1` (or the L1) re-reads the landed gate and records its
  sha256 in the landing receipt; the gate and the checker must agree on `unbound` (M-1).

### L-1 — **Low** — `c1.sh` still defaults its scratch to `/tmp`
- Evidence: `plans/round-57-c1.sh:38` `mktemp -d "${TMPDIR:-/tmp}/kagi-r57-c1.XXXXXX"`;
  `git archive 1cda9e7 | wc -c` = 181,780,480. The amended `c2.sh` fixed this for C2 only.
  Observed live: `/tmp/kagi-r57-c1.blN0An` existed at 11:24:5x and was gone at 11:25:00 —
  a sibling seat's run of the counter is using the `/tmp` default right now (it cleaned up,
  so the directory is transient, but the 182 MB extraction lives there during the run).
- Impact: a standalone verifier run writes ~182 MB transiently to the host `/tmp`, against
  the wave's "no large /tmp trees" rule.
- Smallest remediation: adopt c2's `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r57/…`
  pattern and refuse when the resolved scratch is under `/tmp`.

### L-2 — **Low** — the `BAO_` denial class collides with the product name and with its own quoted definition
- Evidence: of the 186 matches at 11:28, 142 are `BAO_` and every one of them is inside
  `OPENBAO_AUDIT_TRIAL` — the trial, the C2 counter, the controls, the plan, the
  connector/executor/labrat/lesson reports and the seat prompts all use that identifier — or
  inside the seat prompt's quoted pattern (spec 1, dispatch 1). A genuine `BAO_TOKEN=<value>`
  would be indistinguishable from the noise without human triage, and any artifact naming the
  trial's output prefix self-matches.
- Impact: false positives in every future sweep; a real hit can hide in the noise.
- Smallest remediation: anchor the class to an environment-name shape
  (`(^|[^A-Za-z0-9])BAO_(TOKEN|ADDR|DEV_ROOT_TOKEN_ID)=`) or enumerate the names.

## L1 dispositions (KagiR57, 11:26) and this seat's response

1. **Epoch drift** — kept as disclosed epoch B `03cbf656` (committed 11:20:45, "the final
   predicate freeze"); the 11:10 receipt binds epoch A's bytes, the epoch-B receipt binds
   A1+A2 and is authoritative; recorded as the round-56 D8 process-defect class; no further
   epoch will be created after candidate measurement. **Response: severity recalibrated
   Critical→High** (H-1); I verified the commit, its contents and that no counter run on the
   candidate exists. Dissent retained on the A1 sentence ("before any candidate measurement"
   is false: the trial is 11:15:43 and the first receipts 11:16:55) and on the decision not
   to keep `7aa1f47` as the round-57 record.
2. **No revert to `7aa1f47`** — reason given: the pre-A1 counter could not accept any real
   trial of this lane's shape, and reverting would hide a measured binary fact. **Response:
   noted, dissent recorded verbatim in H-1 for the closure reader.**
3. **Trial argv hygiene** — fixed before the candidate commit; re-ran 5/5 HOLDS, same
   verdicts; entry to state stdin-only. **Response: verified** at 11:27 (trial
   `7e645194…`; stdin-only at lines 118 and 123-126; no secret on any argv remains). H-3
   marked fixed.
4. **`R57Connector.md`** — false claim not cited as evidence; to be recorded as M57-7 in
   `corpus/lessons/round-57.md`. **Response: verified at 11:27 that the lesson carries
   M57-1…M57-6 only; M57-7 is still owed** (H-4).
5. **`c1-check.py` constant `unbound=0`** — confirmed, deliberately not fixed (frozen
   instrument the candidate was measured under); recorded as a named diagnostic defect;
   landed gate prints the real number; next round's gate inherits the fix. **Response:
   accepted** (M-1); the gate does print the real number (5 on my forged tree).

No lane edits were made by this seat in response; the report is the only artifact changed.

## What this review does not establish
- C2's `value=5` was never observed under the on-disk counter: the executor's 11:19 draft and
  its nine receipts read CLEAN 5/5 with five one-test falsifiers (in the predeclared
  `TEST T<n>` vocabulary, which the on-disk counter scores 0), and the production trial's
  reference receipts (`receipt-ref-real.txt`) read `TRIAL T1..T5 HOLDS` +
  `OPENBAO_AUDIT_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` in the amended vocabulary.
  Neither artifact was measured by me with `plans/round-57-c2.sh`: it starts dev servers and
  is the executor/labrat surface, so the amended counter's own reading is **unrun** here.
- The C1 landing (repairs + committed gate) is not yet committed: `SCORECARD.md`, `LOG.md`
  and `corpus/lessons/round-56.md` are modified but uncommitted; the working tree reads
  `value=0 population=16` (both checker and gate), but no landing commit exists to bind it.
- Capture provenance is taken from the scribe's `verified-at` line (each page fetched twice,
  sizes 41,787 / 33,338 B and the stated body sha256s); I did not re-fetch the pages. The
  lesson seat's four `.body` captures and two receipt files arrived after my first pass and
  are covered only by the 11:26 sweep (0 credential shapes), not by a line-by-line review.
- The 11:26 snapshot is a moving target: the wave was still writing when this report closed
  (reports for ScoutSurface, ScoutSources, ReviewC1, CriticC2, MutChecker were absent; the
  lesson file carries M57-1…M57-6, so the promised M57-7 for the connector's false claim is
  still owed), so findings H-1/H-2/H-3/H-4 were true at their stated mtimes and the L1
  should re-check the hashes at closure.

## Receipts
`.ufo/waves/round-57/w1/R57Sentinel.d/`: `index.txt` (hashes, readings, versions),
`audit-classes.txt` (C-04), `unbound-demo.txt` (M-1), `exec-demo.txt` (M-2),
`c2-falsifier.txt` (pre-amendment K2 falsifier), `sweep.txt` (C-15/C-18),
`amendments.txt` (H-1/H-2 evidence), `argv-leak.txt` (H-3).
Scratch deleted; no file written outside `w1/R57Sentinel.md` and `w1/R57Sentinel.d/`.
