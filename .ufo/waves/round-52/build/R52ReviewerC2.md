# R52ReviewerC2 — correctness review of the frozen C2 counter (round 52)

Seat: R52ReviewerC2. Subject: `plans/round-52-c2.sh` (predicate `C2_REWRAP_STATEMENTS`, `plans/round-52.md` §C2).
Report status: complete. All writes are under `.ufo/waves/round-52/build/R52ReviewerC2*` and
`/fast/scratch/hyaku/kagi-r52/R52ReviewerC2/`; nothing in `corpus/`, `plans/`, or the frozen fixtures was touched.

## Instrument identity and method

- Lane `HEAD` at review time: `52ebb412561d9601ad8658c30d1cfa0087af64d4` (predeclaration).
  `git diff --stat 52ebb41 -- plans/` is empty: the counter and plan are unchanged since predeclaration.
- `plans/round-52-c2.sh` sha256 `82093e0def38377b0a0f8df5f86d280b58a5fb71c54ffdf901ceabd4d620c0e0`.
- Reference corrections: `entry.txt` sha256 `d6010577…6726a9f`, `lesson.txt` sha256 `486951dc…880e5c57`.
- Pinned binary `/home/vgpnk/.local/bin/bao`, sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788`,
  `OpenBao v2.7.2 (9e0a0d3c3504a0a00b45e61355afac5e35c78379)`.
- Base fixtures are `git archive 1d984ada… | tar -x` copies under my scratch; the counter was always run
  with `--tree <fixture>` or with the BASE rev. Every reproduction is a read-only execution of the frozen
  counter. Receipts: `.ufo/waves/round-52/build/R52ReviewerC2-receipts/` (`k2-0-base.txt`, `k2-p-ref.txt`,
  `battery.log`, `inline.log`, `k2f3-k2f8-b9-b10.txt`, `cleanup-run.out`, `conc-a.out`, `conc-b.out`,
  `digests.txt`, plus the two driver scripts). Scratch: `/fast/scratch/hyaku/kagi-r52/R52ReviewerC2`.

## Headline (asked-for values)

- **K2-0 (BASE) reads 2.** `bash plans/round-52-c2.sh 1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b` →
  `C2_REWRAP_STATEMENTS: value=2 assertions=2 guard=1 probe=1 obs_helper=sys/wrapping/wrap obs_kv=secret/data/<path> uncorrected=[corpus/knowledge/vault-openbao-token-lease-lifecycle.md:292 corpus/lessons/round-51.md:22]`
  (rc 0; reproduced five times in this seat, incl. twice concurrently — both concurrent runs printed
  the same line, rc 0).
- **K2-P (reference corrections appended) reads 0.** BASE archive + `entry.txt` appended to
  `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` and `lesson.txt` to `corpus/lessons/round-51.md` →
  `C2_REWRAP_STATEMENTS: value=0 assertions=2 guard=1 probe=1 obs_helper=sys/wrapping/wrap obs_kv=secret/data/<path> uncorrected=[]` (rc 0).

So the frozen instrument does what the plan claims for the two controls it names. The findings below are
instrument weaknesses; none of them changes K2-0 or K2-P, and none is exercised by the two reference
corrections.

## Findings (severity, direction, evidence)

### F1 — MEDIUM, fail-open: the `<basename>:<n>` pointer is a substring test, so a correction naming a different file with the same basename counts

`plans/round-52-c2.sh:121` builds `ptr="$(basename "$f"):$n"`; `:138–140` accept it when
`index(t,ptr)>0` (and the next char is not a digit). There is no path anchoring. If two scoped files share
a basename, a correction line in file F that explicitly points at the *other* file (or at a nonexistent path)
still clears F's assertion.

Reproduction (fixture `cases/b9-wrongfile-basename`, receipt `k2f3-k2f8-b9-b10.txt`): append to root
`SCORECARD.md` line 1781 the assertion `Appendix: the rewrap page sample response is misleading.` and then

```
Correction (round 52, D1) to corpus/fixtures/cells-hermetic/SCORECARD.md:1781: helper-origin rewrap reads `sys/wrapping/wrap` and KV-origin rewrap reads `secret/data/<path>`.
```

→ `value=2 assertions=3`, and `SCORECARD.md:1781` is **absent** from `uncorrected=[…]`, i.e. the assertion
was treated as corrected by a pointer to a different file. The same fixture with
`zzz/nowhere/SCORECARD.md:1781` (nonexistent path) also reads `value=2`: the correction clears the line
even though the named file does not exist.

Live duplicate basenames in scope at BASE (so the hole is reachable in this tree): `README.md`
(`README.md`, `corpus/README.md`) and `SCORECARD.md` (`SCORECARD.md`,
`corpus/fixtures/cells-hermetic/SCORECARD.md`). At BASE neither duplicate holds an assertion
(the population is the two lines the predicate names), so F1 does not move K2-0/K2-P; it is a hole for any
new assertion appended to one of those files — and the plan itself plans a SCORECARD erratum this round.
Suggested hardening (not applied: instrument is frozen): match the pointer against a path-qualified
`<file>:<n>` or require the pointer to be preceded by start-of-line / non-path characters.

### F2 — MEDIUM, fail-open on rendered prose: the assertion skip is case-insensitive while correction recognition is case-sensitive

`plans/round-52-c2.sh:99–101` sets `IGNORECASE=1` for the whole `assertions()` awk, so the skip
`l ~ /^Correction \(round 52, D1\)/` also matches `CORRECTION (ROUND 52, D1)`. The correction check
(`:138`) uses `index(t,"Correction (round 52, D1)")==1`, which is case-sensitive. A line that begins with
the marker in a different case is therefore neither an assertion (skipped) nor a correction (not
recognised): it is invisible to `U` although it is rendered prose that matches the assertion ERE.

Reproduction (case `t7-uppercase-marker`, receipt `inline.log`): append at top level
`- CORRECTION (ROUND 52, D1) to vault-openbao-token-lease-lifecycle.md:292: the rewrap sample is misleading`
→ `value=2 assertions=2` (the line is missing from both the count and the uncorrected list). Under the
frozen predicate the line matches the case-insensitive assertion ERE and is not a correction line (its text
does not start with the literal `Correction (round 52, D1)`), so the predicate's value is 3.

### F3 — LOW-MEDIUM, fail-open: the per-line code-span mask can hide a genuine HTML comment opener, so a commented-out correction counts

`plans/round-52-c2.sh:123–128` masks code spans by toggling on every backtick, per line; `:130–136` then
looks for `<!--` in the masked string. An unmatched backtick before a real comment opener hides it from the
scan while the visible-text reconstruction (`vis`) keeps the original characters, so text a renderer shows
inside a comment can be read as a correction.

Reproduction (case `t10-stray-backtick`, receipt `inline.log`): entry file gets

```
`<!-- stray backtick hides this opener
Correction (round 52, D1) to vault-openbao-token-lease-lifecycle.md:292: helper-origin rewrap reads `sys/wrapping/wrap` and KV-origin rewrap reads `secret/data/<path>`.
-->
```

→ `value=0 assertions=2`: the commented-out correction cleared the entry's assertion. (A renderer treats the
unmatched backtick as literal and `<!--` as a comment opener.) The pre-freeze fix is correct for the live
case (`corpus/lessons/round-51.md:15` carries the balanced span `` `<!--` ``; T9 control with the same
construct reads 0), so the hole needs an unbalanced backtick before the opener.

### F4 — LOW, fail-open (unrendered text): a line inside an HTML comment that starts with the correction marker is dropped in both directions

`assertions()` skips it (`:100–101`, no comment awareness); the correction scan cannot see it (the comment
is stripped at `:130–137`, so `:138` sees no marker). The predicate says such a line is *not* a correction
line (correction lines are "outside any HTML comment") and therefore *is* an assertion line.

Reproduction (case `b11-comment-assertion`, receipt `battery.log`): append

```
<!--
- Correction (round 52, D1) to vault-openbao-token-lease-lifecycle.md:292: the rewrap sample is misleading
-->
```

→ `value=2 assertions=2`; the predicate's count is `value=3 assertions=3`.

### F5 — LOW, fail-closed: a leading inline HTML comment plus one space defeats correction recognition

The correction anchor is `index(t,"Correction (round 52, D1)")==1` after only an optional `- ` strip
(`:137–138`); stripping a leading comment leaves its trailing space in `t`, so the marker sits at index 2.

Reproduction (cases `b1-twocomments-nospace` / `b2-twocomments-space`, receipt `battery.log`):
`<!-- n -->Correction …<!-- t -->` → `value=0`; `<!-- n --> Correction …<!-- t -->` → `value=2`.
Overcount only; cannot produce a false 0. The same applies to `- <!-- c --> Correction …`.

### F6 — LOW, fail-closed: the mask is single-backtick and per-line

(i) A `<!--` on the continuation line of a multi-line code span opens a comment (case `t8-multiline-codespan`
→ `value=1`, `uncorrected=[…:292]`); (ii) a double-backtick code span `` ``<!--`` `` opens one (case
`t11-double-backtick` → `value=1`). Both mask the appended correction and overcount. Receipt `inline.log`.

### F7 — LOW, scope divergence: `--tree` counts untracked `*.md`; the predicate says "tracked"

`plans/round-52-c2.sh:94–96` uses `find` on the directory. Rev mode (`git archive`) can only yield tracked
files, but a `--tree` fixture with an untracked `corpus/untracked-notes.md` containing an assertion reads
`value=3 assertions=3` (case `b14-untracked`, receipt `battery.log`). Overcount only; the controls and my
fixtures use `--tree`, so a control that accidentally leaves an untracked md in a fixture would inflate the
count (never deflate it).

### F8 — INFO, ceiling not named: a correction inside a fenced code block is accepted

Case `b12-fence`: the two reference corrections wrapped in ``` fences read `value=0`. The predicate excludes
only HTML comments, so this is predicate-conformant, but the named ceilings do not list fenced blocks.

### F9 — LOW, probe hygiene (repeats round-51 routed classes)

- `plans/round-52-c2.sh:67–68` starts the server as
  `env -i HOME="$W/home" PATH=… BAO_DEV_ROOT_TOKEN_ID="$root" setpriv --pdeathsig KILL "$BAO_BIN" server …`.
  The throwaway root token therefore rides in `env`'s argv element for the life of the `env` process
  (S-1 class), while the header at `:59` says "no secret on argv". The counter prints no token value, and
  the exposure window is the transient `env` process; the token is not in `bao`'s own argv.
- `:65` picks a free port by bind-then-close, and `:68`+ never verify that the port is held by `$SRV`
  (S-3 class, the fix round 51 required of the C1 trial). A same-host process could answer on the port
  between the close and the server's bind, or if the server dies silently. Single-user host: theoretical,
  but the check is absent by construction, not by ceiling.
- `setpriv --pdeathsig KILL` covers the server on script death; no orphaned `bao server` with ppid 1 was
  observed after my runs, and the cleanup probe showed every child PID gone after exit.

### F10 — INFO, harness robustness: `HOME` unset breaks the protocol line

`env -u HOME bash plans/round-52-c2.sh <rev>` → `line 36: HOME: unbound variable`, rc 1, no
`C2_REWRAP_STATEMENTS:` line (`set -u` aborts before `setup`). `HOME=` empty → `SETUP reason=bao-missing`
(rc 2, fail-closed). A harness that parses the protocol line should treat rc 1 as SETUP, or the counter
should guard `HOME` explicitly.

### F11 — INFO, fail-closed only: first-occurrence pointer scan

`:139` uses `index(t,ptr)` (first occurrence). A correction that mentions a longer same-prefix pointer before
the real one (e.g. `F:292` before `F:29`) is rejected even when the exact pointer is present later. Only
inflates `U`; not reproduced as a false 0, code-read.

## Behaviours verified correct (receipts in the report dir)

- Prefix collision in the direction that matters: assertion at line 29, correction naming `:292` → stays
  uncorrected (`value=3`, case `b7-prefix-collision`); the correct `:29` clears it (`value=2`, case
  `b8-prefix-correct`). The "next char is not a digit" rule at `:139–140` works.
- Multi-line HTML comments: a correction wrapped in `<!-- … -->` across lines is not recognised
  (`value=2`, case `b3`), and a real correction after a closed multi-line comment is recognised
  (`value=0`, case `b4`).
- Two comments on one line: the stripping loop handles both (`value=0`, case `b1`); the only failure is the
  leading-space case of F5.
- Pointer moved into an inline comment while the literals stay visible → uncorrected (`value=1`, case `b13`).
- Control analogs: K2-F3 (entry pointer `:29`) → `value=1`, `uncorrected=[…:292]`; K2-F8 (both literals in a
  same-line comment) → `value=1`, `uncorrected=[…:292]`; both match the pre-freeze receipt's expected values.
  Receipt `k2f3-k2f8-b9-b10.txt`.
- GUARD: a changed BASE byte → `SETUP reason=guard rewritten:./corpus/knowledge/vault-openbao-token-lease-lifecycle.md`
  (T1); a truncated BASE file → same SETUP (T2); a deleted assertion file →
  `SETUP reason=guard missing:./corpus/knowledge/vault-openbao-token-lease-lifecycle.md` (B16); removing only
  appended bytes keeps `guard=1` and drops the correction to `value=1` (B15), exactly "BASE bytes followed
  only by appended bytes". A rewrite of a scoped BASE file that held no assertion leaves `guard=1` and
  `value=2` (B17) — by the predicate, GUARD does not police those files.
- PROBE fail-closed: `R52_BAO=/nonexistent/bao` → `SETUP reason=bao-missing` (rc 2);
  `R52_BAO=/bin/true` → `SETUP reason=bao-pin-mismatch` (rc 2); a failing `python3` on `PATH` (port picker
  and JSON parse fail) → `SETUP reason=probe-failed(helper= kv=)` (rc 2). Bad rev, missing tree, no args →
  SETUP rc 2. Receipt `inline.log`.
- Server lifecycle: during a run the counter's children (incl. the dev server) are killed by the EXIT trap;
  after `wait`, every recorded child PID is gone (`cleanup-run.out`), and no orphaned `bao server` with
  ppid 1 was observed. Two simultaneous runs both read `value=2` with rc 0 (`conc-a.out`, `conc-b.out`).
- Separability spot-check: today's new `corpus/knowledge/openbao-kv-v2-version-lifecycle.md` and
  `corpus/lessons/round-52.md` contain no assertion-pattern line (grep + the assertion awk over both), so
  the C1 files do not move C2's population; the two scoped additions to `corpus/README.md`/`SOURCES.md`
  carry no rewrap/judgement text either.
- `SCORECARD.md:1778` at BASE does not match the assertion ERE (tested), consistent with the plan's
  named-ceiling note that it is not counted.

## Residual risk and verification gaps

- The instrument checks a pointer and two literals, not prose (named ceiling). F1 and F2 extend that
  ceiling in directions the header does not name: F1 lets a *wrong-file* pointer count, F2 lets a
  *differently-cased* marker line disappear.
- I did not run `plans/round-52-controls.sh` end-to-end (its C1 controls run the trial for 70–120 s each);
  I reproduced K2-0, K2-P, K2-F3, K2-F8 and the GUARD/probe failure classes directly instead.
- I did not run `claim-ledger.sh verify` (not named for this item) and did not measure any Vault binary or
  a second OpenBao version; the probe's observations are from the one pinned 2.7.2 on this host.
- F9's argv exposure is reasoned from the source line, not observed in `/proc` (the window is transient);
  no token value was printed or read at any point.
- One stale scratch dir, `/fast/scratch/hyaku/kagi-r52/c2-counter.fdv9cj` (BASE archive + empty `home`,
  mtime 23:05:54), exists and is not attributable to my runs (all of mine removed their own dirs; the
  cleanup test shows the trap works). Probably a sibling seat's killed run; noted, not claimed as a counter
  defect.
- Working-tree state observed (context, not judged here): the two C2 corrections are already appended in the
  lane (`git diff --stat 1d984ada` on the two files: 4 insertions), and the working tree also carries C1's
  files; I did not measure the in-flight uncommitted tree because other seats are editing it.

## Bottom line

The frozen C2 counter reproduces the claim it exists to measure on this host: **K2-0 reads 2 and K2-P reads
0**, with the pinned OpenBao 2.7.2 and the reference corrections, and with GUARD and PROBE failing closed on
the paths I could exercise. F1 (wrong-file basename pointer) and F2 (case-insensitive assertion skip vs
case-sensitive correction) are the two findings worth carrying into the next round's ceilings or into a
v2 instrument; F3–F11 are lower-severity edges, all fail-closed except F3 and F4. No finding contradicts
the pre-freeze control receipt, and no finding is exercised by the candidate's two corrections.
Verdict (recommendation only): C2's instrument supports the headline calibration claim; C2's own admission
remains the main agent's judgment.
