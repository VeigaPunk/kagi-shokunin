# CritPlanScope — round-23 plan-scope falsification (critic seat)

Attacked: the frozen claim wording in `plans/round-23.md` (sha256 `cb1287ba…6b007ac`, unchanged for the whole
seat) against the implemented tree. Lenses: active vs historical provenance, pointer strength, host-free
coverage. Axes judged: calibration, freshness, operability. All tree content was treated as data.

## 0. The target moved during the seat (an identity finding in its own right)

| time (-03:00) | HEAD | what I observed |
|---|---|---|
| 00:56:29 | — | `falsify-spec.json` / `falsify-dispatch.json` mtime (wave dispatched) |
| 00:57:16 | `d218603` + dirty tree | first digests; `closure-dispositions.py` `6cc82278…`, `.json` `f20f00d1…` |
| 01:03:51 | (dirty) | fixture files, `stamps.tsv`, `.py`/`.json`, lesson and census all re-hashed to new values |
| 01:04:19 | `e1884c6` | integration commit (committer date); later named as `measured_commit` by the verdict file |
| 01:05:47 … 01:18:44 | `ea5b734`, `b55e0e7`, `7af07b4`, `284d40e`, `638d44c`, `def9bc2`, `58bd8d7`, `57776b2` | 8 more commits. They change gates and claim wording, several in response to falsify reports |
| 01:19:27 | `57776b2859638d3af26d5443e7fc4b54131b6eab` | final measurement. `git diff --quiet HEAD -- plans corpus` reported clean |

Final digests (01:19:27):
- `corpus/closure-dispositions.py` `d79b08a7…`, `.json` `67ac1a42…`
- `corpus/source-fetches.tsv` `6e26e140…`, `corpus/sources-census.sh` `2d1bbbe3…`
- `corpus/claim-ledger.tsv` `ed125ca5…`, `corpus/claim-ledger.sh` `c20c2d04…`
- `corpus/SOURCES.md` `c6ea91ab…`, `corpus/lessons/round-23.md` `4e971e3d…`
- fixture `SCORECARD.md` `23583252…`
- `.ufo/waves/round-23/final-verification.json` `72764bf3…`, last changed in `ea5b734`

Every finding below names the revision where it holds. "OPEN" means it still holds at `57776b2`.

Line-number basis: `round-23.md:N` means `57776b2:corpus/lessons/round-23.md` (sha `4e971e3d…`); other
`path:N` citations are at `57776b2` unless a revision is named.

After my final measurement, HEAD moved again: `d736adf` (01:24:13), then `3f9fe72` (01:24:32). Those two commits
reword lesson D3 to "authored by this lane" and annotate the LOG. Lesson lines after about :86 shift by +1.
I did not re-measure these two commits, and no finding below depends on them.

## 1. Commands I ran (cwd = lane root unless noted)

| # | command | exit | observed |
|---|---|---|---|
| 1 | `python3 corpus/closure-dispositions.py` (with `PYTHONDONTWRITEBYTECODE=1`) | 0 | until 01:13: `CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)`. At 01:17/01:19: `… fixed=6 reported=3 …` |
| 2 | `python3 corpus/closure-dispositions.py --selftest` | 0 | `PASS (13 cases)` at ~00:58; `PASS (14 cases)` at `def9bc2` and `57776b2` |
| 3 | `bash corpus/sources-census.sh` | 0 | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`, every snapshot |
| 4 | `bash corpus/sources-census.sh --selftest` | 0 | `SOURCES_CENSUS_SELFTEST: PASS (59 cases)`, every snapshot |
| 5 | the R23-01 command (`bash corpus/claim-ledger.sh cells --root corpus/fixtures/cells-hermetic --claims …/claims.tsv --stamps …/stamps.tsv --scorecard …/SCORECARD.md --docs …/SCORECARD.md`) | 0 | `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)`, every snapshot |
| 6 | `env -i PATH=/usr/bin:/bin HOME=/nonexistent LANG=C.UTF-8 <R23-01>` | 0 | same CLEAN line |
| 7 | `strace -f -qq -e trace=openat,execve[,chdir] -e signal=none <R23-01>` | 0 | see F10 |
| 8 | `bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` (cwd fleet root; read-only, stdout only) | 0 | 7 `W04` lines (S019–S023, S025, S026), then `kagi ok …/corpus/SOURCES.md` |
| 9 | Python replica of the fleet `url_of`/W04 logic (`scripts/sources-census.sh:600-653`) over `git show <rev>:corpus/SOURCES.md` | 0 | `d218603`: 5 (S019–S023). HEAD: 7 (adds S025, S026) |
| 10 | `git --no-optional-locks -C kagi-shokunin diff --stat d218603..HEAD -- corpus/lessons corpus/QUALITY.md` (cwd fleet root, HEAD `b55e0e7`) | 0 | only `corpus/lessons/round-23.md \| 196 +` |
| 11 | scratch copy of the working tree (census = e1884c6 SC_FETCH code) → `bash corpus/sources-census.sh verify --root $T`, mutations M1–M4 | 0/1/0/0/1 | see F5, F6 |
| 12 | `git archive e1884c6 corpus .ufo/waves/round-23 \| tar -x -C $T`, then that tree's own `closure-dispositions.py` and `sources-census.sh` | see F1, F2, F5 | `test -e $T/.ufo/waves/round-23/final-verification.json` → 1. Verifier → 0 CLEAN `fixed=7`. Census control → 0. Census M1 → 1 |
| 13 | `git archive HEAD corpus` scratch (HEAD `57776b2`): census control, M1, M2; closure gate with D6 pointer re-targeted to a gitignored path | 0/0/0/0 | see F2, F5, F6; `git check-ignore -v .ufo/interactive-sessions/never-committed.md` → 0 (`.gitignore:1`) |
| 14 | scratch fixture copies: control, uncited cell, bad row id, failing row → R23-01 mechanics | 0/1/1/1 | see F9 |
| 15 | D4 re-measurement: Python over `git show c2cab35:corpus/stamps.tsv` plus `git log`/`git show` per path | 0 | see §4 |
| 15a | `git merge-base --is-ancestor 584dd67 e1544c1` | 1 | see §4 |
| 16 | `git log -S'confirmed the three claims' -- corpus/lessons/round-23.md` | 0 | introduced `e1884c6`, removed `284d40e` |
| 17 | `ls .ufo/waves/round-23/falsify/*.md \| wc -l` | 0 | 20 at 01:04:52; 50 at 01:15:12; 61 of 64 seats at 01:20:04 (this report absent: `test -e` → 1). parent-build: 66 of 66 |
| 18 | `awk -F'\t' '!/^#/ && NF==16 {print $4}' corpus/source-fetches.tsv \| sort -u \| wc -l` | 0 | `9` |
| 19 | `git diff d218603 HEAD -- <path> \| grep -c '^-[^-]'` | 0 | `corpus/knowledge` 2, `SKILL.md` 2, `SCORECARD.md` 1; LOG, PROVINCE, QUALITY, SOURCES, lessons: 0 |
| 20 | `git diff --stat e1884c6 HEAD -- corpus/sources-census.sh corpus/closure-dispositions.py corpus/closure-dispositions.json corpus/source-fetches.tsv corpus/claim-ledger.tsv corpus/stamps.tsv` | 0 | `6 files changed, 46 insertions(+), 53 deletions(-)` |
| 21 | `grep -c cells-hermetic corpus/claim-ledger.sh` | 1 | `0` |
| 22 | `grep -nE 'subprocess\|\bgit\b\|ls-files\|cat-file\|rev-parse' corpus/closure-dispositions.py` | 0 | only `:296-297`, the selftest self-invocation |

Writes: this report, plus scratch trees under `/tmp/critplanscope.*` from `mktemp -d`, each removed by an EXIT trap.

No installs: the lane contract pauses host-wide package changes, and `strace` was already present. No claim-ledger
row audits, legacy verify, host gates, vault/account actions, or credential reads. I did not re-fetch any page:
the per-row seats RevS017–RevS026 own that.

## 2. Findings: wording that exceeds what the artifacts measure

### F1 — "A fresh 64-seat falsification wave follows integration" (plans:7), and the verdict's identity. HIGH. OPEN.

**Counterexample.**
- The wave was dispatched at 00:56:29, before the integration commit `e1884c6` (01:04:19).
- Eight more commits followed during the wave. They removed SC_FETCH code (`638d44c`), added a selftest case
  (`7af07b4`), re-typed D3 (`58bd8d7`), and rewrote claim and bound wording (`b55e0e7`…`57776b2`).
- `final-verification.json` (sha `72764bf3…`, unchanged since `ea5b734`) still says
  `"measured_commit": "e1884c6…"`. Its R23-02 result is `… fixed=7 reported=2 …`.
- The HEAD ledger now pins R23-02 to `… fixed=6 reported=3 …` (claim-ledger.tsv:60).
- Gate and data bytes differ between `e1884c6` and HEAD (command 20: 6 files, +46/−53).

So the committed verdict does not describe the shipped tree. That is the round-22 D6 defect class ("measured
bytes ≠ verdict commit"), and it is back while D6 is still typed `fixed`
(closure-dispositions.json, D6 row; lesson round-23.md:106-108).

**Axes:** calibration, freshness, operability. All three claim verdicts were taken on bytes that no longer ship.

**Smallest correction:**
- Freeze one commit before dispatching falsifiers, or re-run the safe-row verification at the final commit and
  write that commit into `measured_commit`.
- Until then, type D6 `reported`.

**Type:** fixable defect. The judge should not accept `final-verification.json` as evidence for `57776b2`.

### F2 — "resolves every `fixed` pointer in the commit tree" (plans:13). HIGH. OPEN.

**Evidence.**
- `resolve_pointer` (closure-dispositions.py:106-) resolves pointers on the filesystem only (`root / rel`,
  `is_file`, a substring anchor on any `#` line, the id token anywhere).
- No git is consulted. The only `subprocess` is the selftest harness (:296-297).

**Counterexamples.**
- (a) `e1884c6`'s own verifier on the `e1884c6` tree exits 0 with `CLEAN … fixed=7`. D6 is `fixed` there, but
  `.ufo/waves/round-23/final-verification.json` does not exist in that commit (`test -e` → 1). The pointer
  resolved to a lesson sentence promising the file (round-23.md:106-108).
- (b) In a HEAD copy, I re-pointed D6 to `.ufo/interactive-sessions/never-committed.md#Routed defect
  dispositions`. That path is gitignored (`.gitignore:1`, `git check-ignore` → 0), so it can never be in a
  commit tree. Result: `CLEAN … pointers=15`, exit 0.
- (c) The D9 pointer target `corpus/fixtures/cells-hermetic/SCORECARD.md` contains `D9` only in a line-1 HTML
  comment added to the fixture's input data (`grep -n D9` → `1:<!-- D9: hermetic cells fixture; … -->`).

**Bound:** the lane's own docstring now says "contains the id token somewhere (comments count)"
(closure-dispositions.py:41-47). The R23-02 note says "in-tree … Records existence, not fix quality"
(claim-ledger.tsv:60). The plan sentence was never corrected.

**Axis:** calibration.

**Correction:** reword the plan, LOG and SCORECARD as "present in the working tree (presence-only)". For the
stronger claim instead: resolve via `git cat-file -e <commit>:<path>` and require the id under the anchored
heading.

**Type:** wording defect; the stronger reading is a tradeoff the judge should reject.

### F3 — "requires exactly one typed disposition per obligation" (plans:12-13): the type is unmeasured. MEDIUM-HIGH. Partly fixed.

The count is exact, but the type was wrong in at least four places:

- **D3** was `fixed` from `e1884c6` to `def9bc2`, although its own note said id-shaped positionals "remain routed
  debt (ClaimR11X09)". The closure required both tokens under a selftest case id (spotcheck:170-172). It was
  re-typed `reported` only in `58bd8d7`, mid-wave. The verdict commit's `fixed=7` was overstated by at least
  this one.
- **D6:** see F1/F2. It is `fixed` with the fix artifact absent at the commit the verdict names.
- **D7** (`fixed`, OPEN): the routed defect's second half has no round-23 record. That half is the stale round-22
  §Gate prose "S017–S020 added" vs its own table S017–S021 (spotcheck:180-181). I grepped
  `corpus/lessons/round-23.md`, `corpus/SOURCES.md` and `LOG.md` for `S017.S020|S017-S021|S017–S021|stale against`.
  The only hits were round-22 text (SOURCES.md:98, LOG.md:1075); the round-23 lesson has none.
- **D1:** the note claimed "five W04" while the round-end census prints seven (command 8). Corrected in
  `57776b2`.

**Axis:** calibration.

**Correction:** split D7 or type it `reported` for the prose half. SCORECARD.md:843 says "R23-02 resolves 15
outside obligation ids"; that should read "records a typed disposition for 15 ids; types are self-declared".

**Type:** fixable defect. The gate is presence-only by design, so the judge should treat the `fixed=` count as
lane-declared.

### F4 — "no outside-agreement claim" (plans:19). MEDIUM. Softened, still premature.

- At `e1884c6`, `ea5b734`, `b55e0e7` and `7af07b4`, the lesson said "The 64-seat falsification wave confirmed the
  three claims" (command 16). It was written when at most 20 of 64 falsify reports existed (20 `.md` at
  01:04:52).
- At HEAD it reads "reported on the three claims" (round-23.md:188). At 01:20:04 there were 61 of 64 reports,
  and this seat's report did not exist.

**Axis:** calibration.

**Correction:** delete the sentence until the wave closes, or write "N/64 reports at <time>".

**Type:** fixable defect.

### F5 — "Digests are point attestations …, never content-drift pins" (plans:33-34). MEDIUM. Fixed mid-wave; the verdict measured the old code.

**At the verdict commit `e1884c6`:**
- The TSV called the normalized digest "the stable declared identity" (`e1884c6:corpus/source-fetches.tsv:19`).
- The census enforced same-URL normalized equality (`e1884c6:corpus/sources-census.sh:288`).
- Reproduction (command 12): `e1884c6`'s own census on its own tree, with S026's normalized digest made
  different from S021's (the same URL, as a later-day recapture would be), gives
  `FINDING SC_FETCH id=S026 same-url-normalized-disagreement` and exit 1.
- The lesson itself says chrome moves normalized digests between days (round-23.md:52-54, 197). So at that
  commit the digest acted as a cross-capture pin.

**At HEAD:** `638d44c` removed the check. The same mutation now exits 0 (command 13).

**Residue (OPEN):**
- Selftest case `fetch-disagree` now appends a second S002 row (sources-census.sh:426-431) and expects one
  finding (:553). That is `duplicate-provenance`, the same id as `fetch-duplicate` (:552). So the "12 SC_FETCH
  cases" cover 11 distinct finding ids.
- R21-02 and R21-03 in the verdict were measured on the enforcing code.

**Axis:** freshness.

**Correction:** re-verify at the final commit (F1), and rename or remove `fetch-disagree`.

**Type:** fixable.

### F6 — "Make source provenance machine-checked" / "a located ≤25-word quote" (plans:20, 24-25). MEDIUM. Plan wording OPEN.

**Counterexample (command 13, HEAD):** in S024's provenance row I replaced
- sha256 with `a×64`,
- bytes with `1`,
- the quote with "this sentence appears on no page anywhere",
- the normalized digest with `b×64`,
- the location with "nowhere at all".

Result: `SOURCES_CENSUS: CLEAN (rows=26 …)`, exit 0. The pre-`638d44c` census gives the same result.

**Bound:** the TSV header now says "declared quote, shape-checked only … not verified against the page bytes"
(source-fetches.tsv:25-26), and so does the lesson (round-23.md:110-112). The plan still says "located" and
"machine-checked provenance".

**Axis:** freshness.

**Correction:** plan/LOG wording "declared, shape-and-identity-checked provenance". A real located-quote check
needs a committed normalizer plus stored capture text.

**Type:** wording defect. Storing captures is a tradeoff for the judge.

### F7 — Active vs historical: "0 rows without either an active row or a historical in-row pin" (plans:31-32). MEDIUM. OPEN.

The census counts a historical pin as coverage for an active row. At HEAD:
- 14 `mined` rows carry only an in-row pin.
- 8 of those are not superseded by any row: S001–S004, S009–S011, S015. These are active readings whose only
  provenance is historical.
- S015's pin matches none of 520 representations (round-23.md:118-121), and S012/S013 do not reproduce
  (:115-116). [Evidence-verified only, not re-run by me] Peer report `falsify/ScoutS001.md:62-64` states that
  S001's `9f9d7283…` matches none of six domains, citing `parent-build/SourceS001.md:50,59`.
- LOG.md:1213-1216 concedes that the declared captures "are the only active declared provenance". That makes
  10 of 24 mined rows.
- The census verdict line exposes no declared/historical split, so the plan's count is not measured by the gate.

S017–S023's "provenance" is also a re-attestation, not the provenance of the admitted readings:
- Registry `opened=2026-10-20` for all seven (SOURCES.md:23-29), but TSV `fetched=2026-10-21` for all seven.
- The lesson says S017's and S023's normalized digests moved between those days (round-23.md:197).
- So the attested bytes are not the bytes the rows were mined from.

**Axis:** freshness.

**Correction:**
- Have the census print `declared=10 historical=16 historical_unsuperseded_mined=8`.
- Describe S017–S023 rows as "2026-10-21 re-attestation".

**Type:** wording and measurement defect.

### F8 — "legacy in-row pins … never compared to fresh captures" (plans:25-26). LOW-MEDIUM. OPEN.

- The gate does not compare them: the in-row branch just `continue`s (sources-census.sh:279-283).
- The round's own record does compare them: S008 reproduces; S012, S013, S014, S016 and S015 do not
  (round-23.md:113-121; LOG.md:1213-1216).
- Supersession relies on that comparison: S026 "supersedes S016's undocumented-representation pin"
  (round-23.md:29).

**Axis:** freshness.

**Correction:** "never compared by the gate".

### F9 — "a fixture mutation case must fail" / "After: … mutation case fails as expected" (plans:38-42). MEDIUM. OPEN.

**No committed artifact runs a fixture mutation:**
- `claim-ledger.sh` changes vs base touch only the python allowlist.
- `grep -c cells-hermetic corpus/claim-ledger.sh` → 0.
- R11-09 and R18-03 still pin `SELFTEST: PASS (121 cases)` (claim-ledger.tsv:23, 50).
- No ledger row mutates the fixture.
- The lesson delegates the case to "the falsify wave" (round-23.md:170).

**My scratch run (command 14):** every mutation class fails, so the substance holds:

| case | verdict | exit |
|---|---|---|
| control | CLEAN | 0 |
| uncited cell | `CELL_AUDIT: BROKEN … uncited=1` | 1 |
| bad row id | `… missing_ids=1` | 1 |
| failing row | `FAIL R90-01 reason=verdict-not-final`, `row_failures=1` | 1 |

Durability does not hold: the after-state rests on a non-committed, wave-time observation.

**Axis:** operability.

**Correction:** add these three cases to `claim-ledger.sh --selftest` (copying the committed fixture) and re-pin
R11-09/R18-03. Otherwise, bound the claim as "observed by falsifiers, not ledger-pinned".

### F10 — "hermetic, host-free" (plans:35-36); lesson round-23.md:173 "No host file is read". LOW-MEDIUM. OPEN.

**What strace confirms (command 7):**
- The gate `chdir`s into `…/corpus/fixtures/cells-hermetic` before each row.
- Rows open only fixture files.

**What contradicts the absolute wording:**
- `bash` opens `/etc/passwd` and `/etc/nsswitch.conf`, both for the gate shell and for every row shell.
- Resolving `bash` on PATH probes `$HOME/.local/bin`, mise shims, fnm, `~/.opencode/bin` and others (ENOENT).
- `mktemp` creates and then removes `/tmp/tmp.*`.
- Rows inherit the caller's whole environment (262–263 vars).

`env -i` still gives CLEAN (command 6); that run was mine, not a ledger row.

**Fixture blind spot:** fixture R90-02 mirrors R17-03, and its expected `8` equals the live tree's count
(`grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv` → 8 in both trees). So R90-02 cannot detect
a misrooted run; only R90-01 can, because `corpus/fx-ok.sh` is absent at the lane root.

**Axis:** operability.

**Correction:**
- Word it as "no lane-external data or `$HOME` file is opened; system identity files and PATH probing remain".
- Give the fixture a count that differs from the live tree.

### F11 — "Every corpus/log/quality change is an append; only the two executable TSV snapshots … are updated" (plans:47-49). LOW-MEDIUM. OPEN.

**Counterexamples (command 19):**
- `corpus/knowledge/op-ref-consumption.md` was rewritten in place (2 deleted lines vs base).
- `SKILL.md` lost 2 lines and `SCORECARD.md` 1 (the capability-table row "47 cases").
- `corpus/surface-census.sh` got an unplanned code change (`DEEP=""`).

These edits are journaled as `prose_changes` in `.ufo/waves/round-23/expectation-migrations.json`. They are
still non-TSV, in-place, and outside C1–C3.

**Hidden changes behind "census selftest green with the new cases":** the same file's R21-03 entry shows that
9 pre-existing census cases had their expected finding counts rewritten.

**Mistake sweep:**
- The sweep that "found none" (round-23.md:156-158) sits directly under a four-row Mistakes table
  (M23-1..M23-4, :151-154).
- Its command scope (`corpus/lessons`, `corpus/QUALITY.md`) excludes `corpus/knowledge`, where the rewrite is.
- When written at HEAD `d218603`, its `d218603..HEAD` range was empty.

**Stale pointer:** R21-04's note still says "old/new value recorded in round-22 journal" (claim-ledger.tsv:54).

**Axes:** freshness, calibration.

**Correction:** append an erratum to the plan's scope sentence (or restore append-only for the knowledge file),
fix the sweep's scope and sentence, and repoint R21-04.

### F12 — Counts and labels. LOW. Partly fixed.

**Plan:** plans:20-23 says "seven mined rows … and one new frontier row", then "ten registry rows
(S017–S026 after the three correction rows)".
- 7 + 1 ≠ 10.
- S024 has no `supersedes` (SOURCES.md:30), while S025/S026 are the two correction rows (SOURCES.md:31-32;
  SCORECARD.md:840; lesson :177).
- Still inconsistent: lesson :11 "plus three correction rows", and LOG.md:1184 "S024-S026 correction rows" vs
  LOG.md:1204 "S024 … new frontier row".

**Assignment brief:** it says "10 declared captures … over 7 URLs" and "selftest 13". The artifacts show:
- 9 distinct URLs (command 18; LOG.md:1202; lesson :175),
- a 14-case selftest since `7af07b4` (LOG.md:1194 was corrected to 14 in `58bd8d7`).

**Axis:** calibration.

### F13 — "five discernment decisions" (plans:11-12). LOW. OPEN.

**Granularity:**
- The closure tallies "Agreement 5/5 admits sampled, 4/4 rejects" (spotcheck:109) across only 5 table rows
  (:103-107).
- SPOT-03 bundles S020/S021/S022/S023, and SPOT-05 bundles two rejected readings.
- So one disposition stands for up to four sampled decisions.

**Attribution:**
- The SPOT-04 and SPOT-05 notes say "outside reject … stands".
- In the table, `decision` holds `admit`/`reject` and the closure's own column is `verdict: agree`
  (spotcheck:101, 106-107). [INFERENCE] The sampled admit/reject is the lane's call and the closure only agreed,
  so "outside reject" reverses the attribution.

**Axis:** calibration.

**Correction:** "five spot-check rows", or one obligation per sampled item.

## 3. Confirmations (held under re-measurement)

**C1**
- Before:
  - `git cat-file -e d218603:corpus/closure-dispositions.py` → 128 (absent).
  - `grep -c '^- D[0-9]'` on the spot-check → 9.
  - The source sha `65a5b3de…` equals both base and the JSON pin.
- After: verify exit 0 with obligations=15.
- Selftest PASS, 13 → 14 cases. It kills the missing, duplicate, unknown, pointer-missing/id/anchor/escape/symlink,
  bad-kind, note-short, class-mismatch, source-drift and digest mutants, and admits the clean control.

**C2**
- Before: base 16 `Fetch sha256:` in 23 rows, and the base census has 0 `source-fetches` references.
- After: 26 rows and 10 TSV rows (all `mined`, all `decoded-http-body-volatile-v1`). Census CLEAN, selftest 59
  PASS. S024–S026 opened 2026-10-21.

**C3**
- Before: base ledger has 0 `corpus/fixtures/cells`.
- After:
  - 1, with an exact anchored R23-01 regex.
  - CLEAN exit 0 at every snapshot, including under `env -i`.
  - Rows execute in the fixture root.
  - `final-verification.json` records R23-01 pass, and R13-03 skipped with the explicit reason
    "host-bound/substrate row (QM12 safe-row list)".

**W04 (D1):** 5 at base, 7 at round end. At HEAD the lesson D1 block quotes all seven (round-23.md:66-75).

**Parent-build:** 66 of 66 seat reports present.

## 4. D4 re-measurement (attribution confirmed)

| stamped path (`c2cab35:corpus/stamps.tsv`) | pin matches blob at | first later change |
|---|---|---|
| 4 knowledge pins | `2486643` | `f4a8dd9` |
| `corpus/lessons/round-18.md` | `fecee87` | `bad9088` |
| `LOG.md` | `e1544c1` | merge `c2cab35` |

The `c2cab35` merge carries `584dd67`, which is not an ancestor of the pin commit (command 15a → 1). This matches
the closure and the lesson. The lesson still groups the four knowledge files instead of naming them per tuple.

## 5. Not examined

- No page re-fetch or normalizer reproduction (per-row seats own that).
- No claim-ledger row audits (parent-held).
- No host or private gates.

Findings are tied to the revisions named above. The tree was still changing when this report was written.
