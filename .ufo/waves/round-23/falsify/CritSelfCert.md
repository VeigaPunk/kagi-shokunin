# CritSelfCert — round 23 falsification: does C1 consume outside decisions?

Seat: CritSelfCert (critic, round 23 falsify). I attacked the core of C1, the claim that
`corpus/closure-dispositions.py` will "Consume the non-author closure's decisions instead of
self-certifying agreement" (`plans/round-23.md:9-10`). I also checked whether its stated bound
(`corpus/closure-dispositions.py:41-45`) is honest enough for that claim.

**Binding revisions.** The lane committed four times while I was reviewing. Each result below
names the revision it was measured on.

| revision | committer time | gate script | dispositions JSON | lesson `round-23.md` |
|---|---|---|---|---|
| working tree (first read) | — | `6cc82278…` (00:46) | `f20f00d1…` (00:56; D9 → `corpus/claim-ledger.tsv`) | — |
| `e1884c6` | 01:04:19 | `bf6154b1…` | `00fbf48d…` | `2f53cf69…` |
| `ea5b734` | 01:05:47 | `bf6154b1…` | `00fbf48d…` | `2f53cf69…` |
| `b55e0e7` | 01:07:08 | `bf6154b1…` | `00fbf48d…` | `993e114a…` |
| `def9bc2` (HEAD at write) | 01:11:47 | `cfa2c46a…` (selftest-only diff) | `00fbf48d…` | `49632920…` |

The source closure `corpus/lessons/round-22-verifier-spotcheck.md` has sha256 `65a5b3de…`,
which equals the pinned `source_sha256`.

**Housekeeping.**
- Installs: none. The contract pauses installs host-wide, and no tool was needed.
- Lane writes: this file only.
- Scratch: every `mktemp -d /tmp/critselfcert-r23-*` directory and the two census capture
  files were removed afterwards. The last cleanup ran `rm -rf …` (exit 0), and
  `ls -d /tmp/critselfcert-*` then returned exit 2 (nothing left).

## Verdict

- **Confirmed, as a record-coverage capability.** The gate gives one typed disposition per
  parsed obligation and checks that each pointer is present (E0 and E1, at every revision
  above). The capability row at `SCORECARD.md:851` is worded accurately.
- **Refuted as worded: "consumes outside decisions instead of self-certifying".**
  - The gate consumes the closure's obligation **ids**. It consumes none of the outside
    **decisions**. I flipped all five outside verdicts to `disagree` and the adjudication to
    `REJECTED` without touching the dispositions. The output was still byte-for-byte R23-02's
    pinned CLEAN line (X56).
  - A `fixed` disposition can be discharged by:
    - the dispositions file itself (X1);
    - the outside reviewer's own defect list (X2);
    - 98 bytes that say "Not fixed" (X3);
    - a tree from which every fix artifact has been deleted (X8);
    - and, in the committed tree, by D3, whose own note and pointed-to prose both disown the
      fix.
- **Docstring bound: not honest enough for the claim.** "A `fixed` pointer proves a reviewed
  record exists at that path" overclaims in three ways (§4).
- **Premature attribution of the falsify outcome.** Commits `e1884c6`, `ea5b734` and
  `b55e0e7` say: "The 64-seat falsification wave **confirmed** the three claims". In each
  case most seats had not reported, this one included. At `638d44c` the word became
  "reported on". That is still premature at HEAD: 46 of 64 reports existed at 01:12:02, and
  this one did not (§3 F7).

## 1. Commands and exits

How the snapshots were made:

```
S=$(mktemp -d /tmp/critselfcert-r23-…)
git -C kagi-shokunin archive --format=tar <rev> corpus .ufo/waves/round-23/final-verification.json | tar -x -C $S
```

The archive step exited 0 every time. Each gate call was
`python3 $S/corpus/closure-dispositions.py --root <root> [--source <abs>] [--dispositions <abs>]`,
always run on the snapshot's own script and with `PYTHONDONTWRITEBYTECODE=1`. Mutations were
applied only to copies.

"R23-02 ≡" means two things held:
- `re.search` with column 3 of R23-02 (`corpus/claim-ledger.tsv:60`) matched the last line;
- the exit code equalled R23-02's expected exit (column 4).

| id | rev | mutation (copies only) | exit | last line |
|---|---|---|---|---|
| E0 | live tree (≈00:57), e1884c6, ea5b734, b55e0e7, def9bc2 | none | 0 | `CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)`; R23-02 ≡ |
| E1 | live tree, ea5b734 / def9bc2 | `--selftest` (def9bc2 run with `TMPDIR` set to a private scratch dir) | 0 / 0 | `PASS (13 cases)` / `PASS (14 cases)`; after exit, `outside.md` was left in `TMPDIR` (F8) |
| X1 | ea5b734, def9bc2 | D1–D9 set to `fixed`, pointer `corpus/closure-dispositions.json` | 0 | `CLEAN (obligations=15 fixed=9 reported=1 operator_owned=0 no_action=5 …)` |
| X2 | ea5b734, def9bc2 | D1–D9 set to `fixed`, pointer `corpus/lessons/round-22-verifier-spotcheck.md#Routed defects` | 0 | same as X1, `fixed=9` |
| X3 | ea5b734, def9bc2 | new 8-file root (see note 1 below the table) | 0 | R23-02 ≡ |
| X4 | ea5b734, b55e0e7, def9bc2 | D6 pointer changed to `corpus/lessons/round-23.md#Source accounting`; that section has no D6 token (checked) | 0 | R23-02 ≡ |
| X5 | ea5b734 | control: `**ADMITTED.**` → `**REJECTED.**`, ADJ row removed | 1 | `DISPOSITION MISSING ADJ`, so REJECTED is parsed at `bf6154b1` (see note 2) |
| X5a | b55e0e7 script, lane root | adjudication flipped to `**REJECTED.**`; ADJ row unchanged (`reported`, note "closure ADMITTED …") | 0 | R23-02 ≡ |
| X6 | ea5b734 | SPOT-01 outside verdict changed `agree` → `disagree`; disposition stays `no-action` | 0 | R23-02 ≡ |
| X56 | b55e0e7 script, lane root; def9bc2 | all 5 spot verdicts → `disagree` plus `**REJECTED.**`; dispositions unchanged | 0 | R23-02 ≡ |
| X7 | ea5b734 | one bullet `- D5 ` → `- **D5** `, D5 row dropped, re-pinned | 0 | `CLEAN (obligations=14 fixed=6 …)`; R23-02's `obligations=15` catches this case |
| X8 | ea5b734, b55e0e7, def9bc2 | see note 3 below the table | 0 | R23-02 ≡ |

1. X3's root holds the closure (sha256 equal to the pin), the unchanged JSON, and six stubs
   totalling 98 bytes:
   - `round-23.md` = `## Routed defect dispositions\n\nNot fixed: D1, D3, D4, D5, D6.\n`
   - `source-fetches.tsv` = `Not fixed: D7.\n`
   - fixture `SCORECARD.md` = `Not fixed: D9.\n`
   - the three SPOT targets = `x\n`
2. X5's history: when I first read the script (`6cc82278…`, about 00:57), the parse line only
   matched `**ADMITTED.**`, not `**REJECTED…**` as the docstring says. That was fixed in
   flight. No selftest case covers REJECTED.
3. X8 deletes, inside the snapshot:
   - `.ufo/waves/round-23/final-verification.json`;
   - the fixture's `claims.tsv`, `stamps.tsv`, `corpus/fx-ok.sh` and `corpus/adjacency.tsv`;
   - every non-`#` row of `source-fetches.tsv`;
   - the `R23-01` ledger row.

   Only the fixture `SCORECARD.md` and the `#` comment lines remain.

Other checks:

| command | exit | result |
|---|---|---|
| `find .ufo/waves/round-23 -name 'final-verification*'` (≈00:57, same batch as the first E0) | 0 | empty |
| `grep -rln --include='*.json' measured_commit .ufo/waves/round-23` (same batch) | 1 | no match |
| same `find` at 01:05:54 | 0 | file present: mtime 01:05:35, committed in `ea5b734`, `.measured_commit` = `e1884c6…` |
| `for r in 8ada17a 4be5da3 254d632 d218603; do git show $r:corpus/claim-ledger.sh \| grep -c -E 'tcase (mode-unknown-revision\|verify-extra-positional)'; done` | 0 | `0 2 2 2`: the guard cases were added in `4be5da3` (round 22) |
| `grep -n -E "tcase [^ ]+ [0-9] '[^']*' \"\$0\" (verify\|cells\|revision) R[0-9]{2}-[0-9]{2}" corpus/claim-ledger.sh` | 1 | no tcase uses an id-shaped positional argument |
| `git diff d218603 -- corpus/claim-ledger.sh` | 0 | only the python3 allowlist comment and regex change (:91-92, :161) |
| `jq -r .context .ufo/waves/round-23/parent-build-spec.json \| grep -c -E '\.ufo/state\|MANIFEST\.json'` | — | `0` |
| same check over all 66 item prompts / over the falsify-spec context | — | `0` / `1` |
| `ls /home/vgpnk/Projects/shokunin/.ufo/reports/round-23/` | 0 | `kotodama.md` only; no kagi report |
| `timeout 120 bash corpus/sources-census.sh` (01:05:18) | 0 | `SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)` |
| `git show -s --format='author %ad \| committer %cd' --date=iso e1884c6` | 0 | author `2026-10-20 21:11:59` (identical to d218603's), committer `2026-10-21 01:04:19` |
| `ls .ufo/waves/round-23/falsify/*.md \| wc -l` | 0 | 19 at 01:03:28; 46 at 01:12:02 (of 64 seats in `falsify-spec.json`); `find … ! -newermt '2026-10-21 01:02:31'` gives 11 |
| `ls -la /tmp/outside.md` (01:08:58) | 0 | 28 B, mtime 01:08:37 (the lane's own selftest run) |

## 2. The assigned counterexample: a `fixed` disposition that proves nothing about the fix

### Real tree, no mutation: D3

The disposition is at `corpus/closure-dispositions.json:63-69` (identical bytes from
`e1884c6` through `def9bc2`):
- `"disposition": "fixed"`;
- note: "… the mode-token positional guard is selftest-covered, **while id-shaped positionals
  remain routed debt (ClaimR11X09)**";
- pointer: `corpus/lessons/round-23.md#Routed defect dispositions`.

The pointed-to prose (`round-23.md:84-90` at def9bc2) says the id-shaped gap is "routed debt …
**not claimed as fixed**".

What the closure demanded (`round-22-verifier-spotcheck.md:170-172`): "Make every wave context
name the forbidden paths. The new guard must reject the exact tokens (`revision`, positional
ids) under a selftest case id."

What I measured:
- **Guard half.** The only guard cases are `claim-ledger.sh:1292-1293`, and they already
  existed in `4be5da3`, before the closure was written. Round 23 changed `claim-ledger.sh` only
  in the python3 allowlist. No case uses an id-shaped positional argument (grep exit 1).
- **Wave-context half.** `round-23.md:84-86` claims every wave context names `.ufo/state` and
  `MANIFEST.json`. That is false for the 66-seat parent-build wave: there are 0 hits in its
  context and in all 66 prompts. RevClosurePointers reached the same finding independently
  (F7).

The gate still prints CLEAN. For `fixed` its only test is that the file exists, that some `#`
line contains the anchor, and that a `D3` token appears anywhere in the file
(`closure-dispositions.py:104-127`, token check at `:123-126`). So the record's own note and
its own pointer both disown the fix, yet it still counts toward "7 fixed" in
`SCORECARD.md:843` and R23-02's pinned `fixed=7`.

### Synthetic, decisive: X3 and X8

The X3 stubs ("Not fixed: D1, D3, D4, D5, D6." and so on) reproduce R23-02's pinned verdict,
and so does X8's tree with every fix artifact removed. R23-02 passing therefore tells you
nothing about whether any of the seven fixes exists.

### The other `fixed` pointers, as committed

- **D7** → `corpus/source-fetches.tsv`. The only D7 token is the `#` header comment at `:2`.
  None of the 10 provenance rows carries an id, and X8 deletes them all with no effect on the
  verdict.
- **D9** → `corpus/fixtures/cells-hermetic/SCORECARD.md`. The only D9 token is the HTML
  comment at `:1`, `<!-- D9: hermetic cells fixture; rows are declared in claims.tsv -->`.
  - D9 was moved here from `corpus/claim-ledger.tsv` between 00:56 (JSON `f20f00d1…`) and
    01:02:31 (JSON `5de116d1…`); the fixture's mtime is 01:03:02.
  - ConnClosurePatterns.md:36 saw a different comment text (`executable via R23-01 in
    corpus/claim-ledger.tsv`).
  - So the token is placed and maintained in a **C3 test input** to satisfy the C1 gate.
    Deleting the fixture's executable files leaves D9 resolved (X8).
- **D6** → lesson prose `round-23.md:102-104`, which says "This round writes `measured_commit`
  into …".
  - My first E0 printed CLEAN with D6 `fixed` while that file did not exist.
  - It appeared at 01:05:35 (`ea5b734`), and RevClosurePointers.md:73 saw an intermediate
    `"measured_commit": "pending"`.
  - The fix is genuinely in place at HEAD (`measured_commit` = `e1884c6…`). But the gate's D6
    verdict never depended on it (X8).
- **D1 and D5.** The notes say "round report quotes" and "report states", but no kagi round-23
  fleet report exists. The pointer is the lane's own lesson.

### Summary

All seven `fixed` ids resolve through prose or comments the lane wrote this round. Six point at
the lane's own lesson; D7 and D9 resolve through comment lines. None points at an executable
row, a selftest case name, or a pinned artifact.

## 3. Findings

| # | axis | finding | class |
|---|---|---|---|
| F1 | calibration | A `fixed` disposition can certify itself: X1 (the dispositions file names its own ids), X2 (the outside defect list discharges itself), X3/X8 (prose that negates the fix, or no artifacts at all). | fixable defect |
| F2 | calibration | **Outside decisions are not consumed.** The spot-check verdict column (`round-22-verifier-spotcheck.md:101-107`, column 4) is never read; the row detector is the lane's own `admit`/`reject` cell (`closure-dispositions.py:95`). The adjudication word only creates the id `ADJ` (`:99`). X5a, X6 and X56 all match R23-02. `round-23.md:136-139`'s "the reviewer agreed with the sampled admits and rejects" is unverified by any gate. | fixable defect (the core of the claim) |
| F3 | calibration | The id token is not bound to the anchored section (X4; also RevClosurePointers P1), and `#`-prefixed lines inside code fences count as headings (P2). | fixable defect |
| F4 | calibration | Label inflation: D3 is `fixed` although its own note says it is debt. `SCORECARD.md:843` "7 fixed" and R23-02 `fixed=7` count lane-asserted labels as if they were measured outcomes. | fixable defect (relabel) |
| F5 | operability | Parse brittleness: one bolded bullet silently drops an obligation (X7, obligations=14, CLEAN). R23-02's count pin catches only count-changing edits, not count-preserving rewrites (ConnClosurePatterns M8). | bound to state |
| F6 | freshness | Pointer targets are unpinned, so the verdict is a point-in-time presence check. D6 was CLEAN before its artifact existed, and the D9 target was edited to keep the token. | fixable (pin target bytes) |
| F7 | calibration | **Premature attribution of the falsify outcome** (details below). | defect: corrected in part; keep "pending" until the wave closes |
| F8 | operability | **New scratch residue in the committed selftest** (details below). | fixable defect |

**F7 in detail.**
- `round-23.md` "## Falsification bounds" read "The 64-seat falsification wave **confirmed**
  the three claims and named these bounds, which the report repeats". That text was in the
  working tree by 01:02:31, when 11 reports were on disk, and was committed in `e1884c6`
  (01:04:19), `ea5b734` and `b55e0e7`. At 01:03:28, 19 reports were on disk; this seat's was
  not one of them.
- In the same window, a sibling recorded the C2 gate failing: `bash corpus/sources-census.sh`
  exited 1 with `line 242: S007: unbound variable` (RevClosurePointers.md:70, :272-276). The
  lane repaired it in flight, and my run at 01:05:18 exits 0.
- `638d44c` changed the word to "**reported on**" (`round-23.md:183` at def9bc2). At 01:12:02,
  46 of 64 reports existed, still without this one.
- A pre-written summary of an outside outcome is the self-certification C1 says it removes.
- Ordering caveat: `e1884c6`'s author date equals `d218603`'s
  [INFERENCE: jj change-creation timestamp], so use committer dates.

**F8 in detail.**
- `closure-dispositions.py:281-282` (committed in `638d44c`/`def9bc2`) writes
  `root.parent / "outside.md"`, which is `$TMPDIR/outside.md`, i.e. `/tmp/outside.md`. That is
  outside the `TemporaryDirectory`, and nothing removes it.
- Proven twice: E1 with a private `TMPDIR` exited 0 and left `outside.md` behind, and
  `/tmp/outside.md` (28 B) has existed since the lane's run at 01:08:37.
- It overwrites any user file with that name and races between concurrent selftests. This is
  the same class as D8.
- The case count also drifts: `LOG.md:1194` still says "13-case selftest", while
  `SCORECARD.md:851` and `round-23.md:60,205` say 14.

## 4. Is the docstring bound honest enough?

The text at `closure-dispositions.py:41-45`:

> "Bounds: the gate checks record shape, obligation coverage and pointer resolution. It does
> not judge whether a disposition's prose is honest, rerun the fix, or reach the network; …
> A `fixed` pointer proves a reviewed record exists at that path, not that its content is
> correct."

The first two sentences are accurate. The last one is not:
1. **"reviewed".** Nothing ties the record to a reviewer. Six of the seven `fixed` pointers
   target prose the lane wrote this round. The dispositions file itself (X1) and the closure
   (X2) also pass.
2. **"record … at that path".** The id can sit anywhere in the file (X4), including in a `#` or
   HTML comment (D7, D9). It can also deny the fix (X3, live D3).
3. **"pointer resolution" reads as durable.** The targets are not pinned, so the check is a
   point-in-time presence check (D6 timing, X8).

The module title (`:2`), "Turn a non-author closure's decisions into a machine-checked
obligation set", also overstates: what it consumes is ids, not decisions.

Related wording elsewhere:
- **The lesson's bound** (`round-23.md:183-190`) is more honest: "presence-only … file plus
  anchor substring plus id token, not fix content", and "source digest … pinned in the same
  lane-writable JSON". It still omits three things: self or closure targets, ignored outside
  verdicts, and lane-asserted label counts. It also attributes the bound to a wave that had not
  reported (F7).
- **R23-02's note** "Records existence, not fix quality." (`claim-ledger.tsv:60`) is honest.
- **Not honest:** `SCORECARD.md:843` ("resolves 15 outside obligations with 7 fixed") and
  `plans/round-23.md:9-10`.

Suggested replacement for the last sentence:

> "A `fixed` pointer proves only that the file exists in the tree, that some line starting
> with `#` contains the anchor, and that the id occurs as a token somewhere in the file
> (comments count). It does not bind the id to the anchored section, pin the target, exclude
> the closure or this file as targets, read the reviewer's verdicts, or verify any fix. Counts
> are lane-asserted labels."

## 5. Extra evidence a `fixed` would need

| id | demanded (closure line) | accepted today | evidence that would prove the fix |
|---|---|---|---|
| D1 | report quotes W04 warnings verbatim (:165-166) | `D1` token in the lesson | Each warning line printed by `scripts/sources-census.sh validate … kagi`, present verbatim in the kagi round-23 fleet report. RevClosurePointers.md:72 counts **7** warnings; the lesson quotes 5. Until then the disposition is `reported`. |
| D3 | guard rejects exact tokens including id-shaped positionals; every context names forbidden paths (:170-172) | `D3` token in the lesson | A `tcase` with an id-shaped positional (currently absent), and each round-23 `*-spec.json .context` containing the named paths (parent-build has 0). Until then `reported`. |
| D4 | per-tuple drift commit in an appended journal (:173-174) | `D4` token in the lesson | Journal rows `{path, cause_commit}`, each checked with `git log -1 --format=%H <c> -- <path>` and `merge-base --is-ancestor`. |
| D5 | state 130 IDs / 129 names (:175-176) | `D5` token in the lesson | A count derived from the round-22 dispatch JSONs, or the fleet report line. |
| D6 | measured commit inside the verdict file (:177-179) | `D6` token in the lesson | A JSON-key check: `final-verification.json .measured_commit` equals the commit holding the measured bytes. True at HEAD, but never checked. |
| D7 | per-row provenance for S017+ (:180-181) | `# D7` comment | A ledger-row id (column 1) running the census with its exact CLEAN regex, plus a digest pin of `source-fetches.tsv`. |
| D9 | hermetic, host-free `cells` run over committed fixtures (:183-184) | `<!-- D9 -->` comment | `R23-01` resolved by its column-1 id and not skipped, plus a digest pin of the fixture tree. |

## 6. Smallest safe correction

1. **Must, claim honesty.**
   - Set D3 to `reported`, since its own note calls it debt. That makes `SCORECARD.md:843`
     "6 fixed", and R23-02 becomes `fixed=6 reported=3`.
   - Narrow `plans/round-23.md:9-10` and `SCORECARD.md:843` to "consumes the closure's
     obligation ids", and say plainly that the fixed labels are lane-asserted.
   - Keep `round-23.md:181-190` marked "pending" until the falsify wave closes.
2. **Docstring.** Rewrite `:2` and `:41-45` as in §4.
3. **Code, about 15 lines plus 5 selftest cases (X1, X2, X4, X6, X5a):**
   - refuse a `fixed` pointer whose path equals the source or the dispositions file;
   - require an anchor for `fixed`, and search for the id only between that heading and the
     next heading of the same or higher level;
   - parse the verdict column and the adjudication word into the obligation, and allow
     `no-action` only when the verdict is `agree`.
4. **F8.** Create the fixture root as `Path(tmp)/"root"` and the outside file as
   `Path(tmp)/"outside.md"`, so the `TemporaryDirectory` cleanup covers both. Also align
   `LOG.md:1194`.
5. **Stronger, not minimal.** Give `fixed` dispositions typed evidence: a ledger-row id, an
   artifact plus sha256, or a JSON-key check. That is the only way the gate can say anything
   about a fix.

**Defect vs tradeoff.** Checking only presence is a legitimate tradeoff if the capability is
named "record coverage", and the canonical judge can credit it under that name. The judge
should not credit "consumes outside decisions / instead of self-certifying", and should not
treat "7 fixed" as measured: X56 and live D3 refute both as written. F7 and F8 are defects,
not tradeoffs.

## 7. Bounds of this review

- **What I ran:**
  - `closure-dispositions.py` (gate and selftest) on the live tree and on archived snapshots
    of `e1884c6`, `ea5b734`, `b55e0e7` and `def9bc2`, plus temp copies;
  - the lane's `corpus/sources-census.sh` once (a named gate);
  - read-only git (`show`, `log`, `diff`, `archive`, `cat-file`, `rev-parse`).
- **What I did not run:** legacy verify, host-bound rows, any fleet script (so the D1 W04 count
  comes from RevClosurePointers.md:72, not my own measurement), or anything over the network.
- **Unverifiable history.** The `6cc82278…` script was untracked and has been overwritten. Its
  ADMITTED-only parse comes from my read output, not a rerun.
- **Report counts.** These come from file mtimes and directory listings. Upper bounds use the
  listing times stated in §1.
- **Scope.** C2 and C3 content was judged only where C1 pointers depend on it.
