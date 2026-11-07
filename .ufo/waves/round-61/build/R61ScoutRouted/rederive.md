# R61ScoutRouted — independent re-derivation of `plans/round-61.md` §C1, items I1–I7

Lane: kagi (secrets & vault ops). Round 61, attempt 1, seat `R61ScoutRouted` (scout).
Measured tree: BASE `c940f51689d702f1786989d56ad4663833c1452e`
("round-60 verifier spot-check (integrator, hyaku): non-author admit/reject",
2026-11-07 16:43:53 -0300), exported read-only with
`git archive c940f51 | tar -x -C $SCRATCH/tree`.
Frozen plan: `plans/round-61.md` at commit `8595018164f7421864254c6c5ca762b8f201e8be`
(the lane HEAD; `git diff --stat c940f51 8595018` ⇒ `plans/round-61.md | 193 +++++`
only — the predeclaration is committed alone, as it claims).

Work was read-only in the lane. No lane file was edited, no git/jj mutating command was
run in the lane or any index. Scratch: `${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r61/R61ScoutRouted/`
(extracted tree + raw outputs), deleted before yield. Tools: no install; `git 2.56.0`,
`python3 3.14.8`, `grep (pi-uu-grep) 0.2.0` as shipped.

Notation: every command below was run with absolute paths or from the extracted tree at
`$SCRATCH/tree`; "agree" means the plan's stated number equals the re-derived one.

---

## Per-item table

| id | plan's number (quoted from `plans/round-61.md`) | re-derived number | command (abridged) | agree? |
|---|---|---|---|---|
| I1 | `results=<R> output=<B>`, "R = the number of result records in `.ufo/waves/round-60/w1-results.json` and B = the byte length of the `R60MutCounters` record's final output" (§C1 table); motivating text: "carries its 3824-byte output" | **R = 16**, **B = 3824** (bytes of the record's `output` field, UTF-8; the whole `output` string; its last line is `}` = 1 byte) | `python3 -c "import json;d=json.load(open('.ufo/waves/round-60/w1-results.json'));r=[x for x in d['results'] if x['name']=='R60MutCounters'][0];print(len(d['results']),len(r['output'].encode()))"` | **agree** (R=16, B=3824) |
| I1 (anchor) | "after the line containing `R37`" | `R37` occurs on exactly one line, `corpus/lessons/round-60.md:108`; §Bounds at `:116`; the §Bounds mutation-tester bullet at `:128` | `grep -n 'R37\|^## Bounds' corpus/lessons/round-60.md` | agree (anchors unique) |
| I2 | SKILL.md gate row "whose name cell contains `plans/round-60-c2.sh`"; the row "carries `--selftest` in its selftest cell and no longer carries `none of its own`" | exactly one row: **`SKILL.md:855`**; name cell = "AppRole custody counter (`plans/round-60-c2.sh`)"; selftest cell (col 7) = `none of its own — it runs the trial's \`--selftest\` as a conjunct`; `none of its own` occurs on exactly 2 lines in SKILL.md (754, 855); `--selftest` already occurs **twice** inside row 855's selftest cell | `grep -n 'round-60-c2.sh' SKILL.md`; `sed -n '855p' SKILL.md`; `grep -n 'none of its own' SKILL.md` | agree on the numbers (row 855, 1 row) — but see **Ambiguity A2** (the `--selftest` conjunct is already true at BASE) |
| I2 (does the script accept `--selftest`?) | I2 requires `bash <tree>/plans/round-60-c2.sh --selftest` to exit 0 printing `C2_SELFTEST: PASS (cases=N)`, N ≥ 6 | **No.** `plans/round-60-c2.sh` has no `--selftest` branch: its parser is `case "${1:-}" in --tree) …; "") REV=$BASE;; *) REV=$1;; esac`, so `--selftest` falls into `*)` and is treated as a revision. Executed: `C2_APPROLE_TRIAL: value=0 tests=5 pass=0 shims=0 vectors=0/5 selftest=0 guard=0 (bad-revision)`, **rc=1**. The script contains **0** occurrences of `FINDING`; the trial's own selftest prints `APPROLE_SELFTEST: PASS (cases=45)` (rc 0, fixture-driven, no `bao` on PATH). | `sed -n '79,88p' plans/round-60-c2.sh`; `HYAKU_SCRATCH=$S/scr bash plans/round-60-c2.sh --selftest` (rc=1); `grep -c FINDING plans/round-60-c2.sh` ⇒ 0; `env PATH=/usr/bin:/bin bash corpus/openbao-approle-trial.sh --selftest --work $S/work` ⇒ `APPROLE_SELFTEST: PASS (cases=45)` rc=0 | agree with D2's premise (the defect exists) — see **Ambiguity A3** for the `C2_SELFTEST`/`FINDING` token gap |
| I3 | "`plans/round-60.md` carries, after its §A6 block, an appended amendment whose heading matches `^## Amendment A7` that names `A3 item 2`, `form` and `l1-probe.txt` and states the item is withdrawn (the word `withdrawn`)"; lesson "carries a line naming `M60-2` and `A3 item 2` and `second instance`" | `plans/round-60.md` has **no** `Amendment A7` (count 0); last amendment block is `### A6 — 2026-11-07, before the recorded candidate reading (I5's scope token)` at line 321 and it is the **last** block of the file (EOF after it). §A3 item 2 text (lines 234–238): "**Every request carries `Content-Type: application/json`.** A form-encoded body parses as empty: role creation returns 204 with defaults and every login reads 400 `invalid role or secret ID`." `grep -niE 'form\|content-type' .ufo/waves/round-60/final/l1-probe.txt` ⇒ **no match, rc=1** (the receipt carries no form/content-type leg — D3's premise holds). Lesson: `M60-2` heading at line 80, its evidence names **A3 item 4** (not item 2); `A3 item 2` does not occur in the lesson; `second instance` does not occur in the lesson | `grep -c 'Amendment A7' plans/round-60.md`; `grep -n '^### A[0-9]' plans/round-60.md`; `grep -niE 'form\|content-type' .ufo/waves/round-60/final/l1-probe.txt`; `grep -n 'M60-2\|A3 item 2\|second instance' corpus/lessons/round-60.md` | agree (all three conditions currently false) — but see **Ambiguity A4** (heading form vs the file's `### A<n> —` convention) |
| I4 | lesson line "matching `supersedes the round-60 quality-trend sentence` that quotes `no new record defect`, names `D1`, `D2` and `D3`, and states `three` new record defects"; the report's quality-trend sentence is the one at fleet `.ufo/reports/round-60/kagi.md` | report lines 163–166: "**quality: improved** — … The round introduced **no new record defect** that it did not itself route (R32–R43)." — the required quoted substring `no new record defect` is present verbatim; the report (fleet-tracked, commit `99b401380287ecdfa7846e94201881984aa279a3`, sha256 `12ce5343…`) is the D4 source; lesson has **no** `supersedes the round-60 quality-trend sentence` line (count 0); §Bounds text at lesson lines 116–129 includes the false bullet ":128 The wave's 16th seat (mutation-tester) produced nothing…" | `sed -n '163,166p' /home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md`; `grep -rn 'supersedes the round-60 quality-trend sentence' .` ⇒ 0; `grep -n 'no new record defect' /home/vgpnk/Projects/shokunin/.ufo/reports/round-60/kagi.md` | agree |
| I5 | "states `insertions=1 deletions=1`"; "when `--repo` is given the checker derives the two numbers with `git diff --numstat 14a6c07d 818d2a82 -- LOG.md`"; the LOG correction line must come "after the round-60 wave line" | `git diff --numstat 14a6c07d 818d2a82 -- LOG.md` ⇒ `1\t1\tLOG.md` ⇒ **insertions = 1, deletions = 1** (agrees with the plan). The diff is a **rewrite in place** of one line: the wave line's `dead seats 1` → `dead seats 0` (the mechanism the plan names). The round-60 wave line is uniquely anchored: exactly **one** line in LOG.md matches `kagi-r60-w1`, at **:1981**; it is the **last** line of LOG.md at BASE (`git diff --numstat 818d2a82 c940f51 -- LOG.md` ⇒ empty ⇒ LOG.md identical at BASE and at 818d2a82). Lesson/LOG contain **no** `supersedes the round-60 LOG wave line` (count 0) | `git -C /home/vgpnk/Projects/shokunin/kagi-shokunin diff --numstat 14a6c07d 818d2a82 -- LOG.md`; `git -C … diff 14a6c07d 818d2a82 -- LOG.md`; `git -C … show c940f51:LOG.md \| grep -n 'kagi-r60-w1'`; `grep -rn 'supersedes the round-60 LOG wave line' .` ⇒ 0 | agree |
| I6 | lesson line "matching `supersedes the round-60 stale-lane paragraph` that names the driver launch line `2026-11-07T15:03:17-03:00 launch kagi round=60` and at least three `-03:00` timestamps that each occur in `git log --format='%ci' a677c78e..818d2a82`" | driver lines (fleet `.ufo/watchdog.log`, git-ignored, not tracked): `:3217 2026-11-07T15:03:17-03:00 launch kagi round=60 pgid=134532 driver=hyaku-inline attempt=1`, `:3222 2026-11-07T16:34:37-03:00 complete kagi round=60; hyaku-inline attempt=1`; `15:09:28` does **not** occur in the watchdog log (the report's figure is unsupported). The launch string **is** asserted by the measured tree at `corpus/lessons/round-60-verifier-spotcheck.md:13`. `git log --format='%ci' a677c78e..818d2a82` ⇒ **9** lines, in the form `2026-11-07 16:33:44 -0300` — **space** separator, offset **`-0300`**, and **0** literal `-03:00` substrings; the `-03:00`/T form is `%cI` (`2026-11-07T16:33:44-03:00`). The nine committer times: 16:33:44, 16:33:16, 16:32:34, 16:26:52, 16:01:05, 15:47:01, 15:18:26, 15:14:19, 15:06:58 (all -0300). Lesson has **no** `supersedes the round-60 stale-lane paragraph` (count 0) | `grep -nE 'kagi round=60' /home/vgpnk/Projects/shokunin/.ufo/watchdog.log`; `grep -n '15:09:28' /home/vgpnk/Projects/shokunin/.ufo/watchdog.log` ⇒ none; `git -C … log --format='%ci' a677c78e..818d2a82`; `git -C … log --format='%ci' a677c78e..818d2a82 \| grep -c -- '-03:00'` ⇒ **0**; `git -C … log --format='%cI' a677c78e..818d2a82 \| head -1` | **disagree on format only — see Ambiguity A1** (the condition as written is literally unsatisfiable against `%ci`) |
| I7 | "3 = the number of attack roles from `{reviewer, critic, mutation-tester, labrat}` present …, 4 = that number plus the sentinel, and 16 = the result count (all derived from that file)"; the line must state `3/16`, `4/16`, `18.75` and `25` | role mix from the file's **`agent`** field (there is no `role` key): scout 2, executor 6, scribe 2, reviewer 1, critic 1, mutation-tester 1, sentinel 1, connector 1, revenger 1 = **16**; `seats` field = 16; `len(results)` = **16**. Literal list `{reviewer, critic, mutation-tester, labrat}` present: **reviewer, critic, mutation-tester = 3** (no `labrat` seat exists — the validator refuses the role). 3/16 = **18.75 %**; 4 (3 + sentinel) /16 = **25 %** | `python3 -c "import json,collections;d=json.load(open('.ufo/waves/round-60/w1-results.json'));print(collections.Counter(x['agent'] for x in d['results']))"`; `… len(d['results']), d['seats']` | agree (3, 4, 16, 18.75, 25) |

### Population census at BASE — hand-checked (the plan says it "must be measured, not assumed")

The round-61 checker does not exist at BASE (only `plans/round-61.md` is present; `git ls-tree
c940f51` shows no `plans/round-61-*` instrument), so the census was verified structurally by
checking each item's condition against the exported tree:

| item | condition true at BASE? | evidence |
|---|---|---|
| I1 | no | `grep -rn 'supersedes R37' .` ⇒ 0 hits |
| I2 | no | `round-60-c2.sh --selftest` ⇒ rc 1 `(bad-revision)`; SKILL.md:855 selftest cell still carries `none of its own` |
| I3 | no | `grep -c 'Amendment A7' plans/round-60.md` ⇒ 0; lesson has no `A3 item 2` and no `second instance` |
| I4 | no | `grep -rn 'supersedes the round-60 quality-trend sentence' .` ⇒ 0 hits |
| I5 | no | `grep -rn 'supersedes the round-60 LOG wave line' .` ⇒ 0 hits |
| I6 | no | `grep -rn 'supersedes the round-60 stale-lane paragraph' .` ⇒ 0 hits |
| I7 | no | `grep -rn 'supersedes the round-60 attack-share arithmetic' .` ⇒ 0 hits |

⇒ **7 of 7 unresolved at BASE**, i.e. the plan's `value=7 population=7` (K2) is consistent with
the tree, and the plan's "BASE 7" is right. (The plan's census sentence omits that the census is
taken with `--no-challenge` — see Ambiguity A6.)

### BASE commit and plan-commit claims

- Plan's BASE: `c940f51689d702f1786989d56ad4663833c1452e`. Verified: it exists, it is the
  round-60 verifier spot-check tip, subject `round-60 verifier spot-check (integrator, hyaku):
  non-author admit/reject`, committer date `2026-11-07 16:43:53 -0300` (the plan's "2026-11-07
  16:4x -03"), and it is the parent of the frozen plan commit `8595018`. **Agree.**
- Plan's frozen predeclaration commit `8595018164f7421864254c6c5ca762b8f201e8be`: `git diff --stat
  c940f51 8595018` ⇒ `plans/round-61.md | 193 +++++` — the plan file alone. **Agree** with the
  plan's "this file is committed alone as the predeclaration".
- The spot-check lesson the plan leans on (`corpus/lessons/round-60-verifier-spotcheck.md`,
  183 lines, added at BASE) exists and routes **7** defects D1–D7 (7 `| D… |` rows). **Agree.**

---

## Ambiguities

Named with the exact sentence from `plans/round-61.md` that is affected.

**A1 — I6: the `-03:00` timestamps cannot literally occur in `%ci` output (highest risk).**
Sentence: *"…and at least three `-03:00` timestamps that each occur in
`git log --format='%ci' a677c78e..818d2a82` (derived when `--repo` is given)."*
`%ci` emits `2026-11-07 16:33:44 -0300` — space separator, offset `-0300`, **zero** literal
`-03:00` substrings (measured: `git log --format='%ci' a677c78e..818d2a82 | grep -c -- '-03:00'`
⇒ 0). The `-03:00`/T form belongs to `%cI`. A checker that matches the lesson's timestamps
literally against the `%ci` lines finds **nothing** and I6 can never hold ⇒ the claim would be
vacuously unsatisfiable, contradicting K2's "any lower reading means an item is vacuous".
Resolution the L1 must take (the plan's condition is frozen, so this is a defect to report, not
to amend): the checker must compare **instants** — parse `%ci` (or read `%cI`) and match the
lesson's timestamps after normalising the offset to `-03:00` — and the plan/§C1 text should
name `%cI` (or state the normalisation) so the requirement is readable from bytes alone. Nine
candidate instants exist, so "at least three" is satisfiable once normalised.

**A2 — I2: the "`--selftest` in the selftest cell" conjunct is already TRUE at BASE.**
Sentence: *"…the `SKILL.md` gate-registry row whose name cell contains `plans/round-60-c2.sh`
carries `--selftest` in its selftest cell and no longer carries `none of its own`."*
Row 855's selftest cell is `none of its own — it runs the trial's \`--selftest\` as a conjunct`
and already contains the token `--selftest` **twice**. A checker implementing only the
"`--selftest` present" half reads I2 as satisfied on the BASE text, which would make that
conjunct vacuous (K1's spirit) and would let a forgery keep the old cell text. The
discriminating conjunct is the removal of `none of its own`; the condition should require the
cell to name **the counter's own** invocation (e.g. `bash plans/round-60-c2.sh --selftest`),
not merely the token `--selftest`.

**A3 — I2 / K4: two output tokens the plan mandates do not exist anywhere in the lane.**
Sentence: *"…exits 0 printing `C2_SELFTEST: PASS (cases=N)` with N >= 6 …; a copy of that
script whose verdict mapping is broken exits non-zero printing a named `FINDING`."*
Measured: `grep -c FINDING plans/round-60-c2.sh` ⇒ **0** — the counter never emits a `FINDING`
line, so the "named FINDING" leg has no existing convention to reuse and the finding-id
namespace is unspecified in the plan (lane precedents: `C1_CHECK_SELFTEST:` for
`plans/round-60-c1-check.py`, `APPROLE_SELFTEST:` for the trial, `FINDING <ID>` in the trial's
`ck()` helper). The `C2_SELFTEST:` token is likewise new; note it must not collide with round
61's own C2 counter (`plans/round-61-c2.sh`) or with the seal trial's mandated
`SEAL_SELFTEST:` token (§C2). The L1 should fix the token strings and the finding-id shape
before the candidate reading, or state them in the amendment.

**A4 — I3: the mandated heading form contradicts the file's own amendment convention.**
Sentence: *"…`plans/round-60.md` carries, after its §A6 block, an appended amendment whose
heading matches `^## Amendment A7`…"*.
Every existing amendment in `plans/round-60.md` is `### A<n> — <date>, <purpose>` (h3, `A1`…
`A6`; there is no `## Amendment …` heading anywhere in the file). A fixer who follows the
file's convention writes `### A7 — …`, which does **not** match `^## Amendment A7`; the plan's
regex forces an h2 `## Amendment A7` line. Also "after its §A6 block" is a positional
requirement with no anchor: §A6 is the **last** block of the file, so the amendment must be
appended at EOF. Both are checkable from bytes once the exact heading is fixed; recommend the
L1 write the heading exactly as `## Amendment A7` and additionally state "last block in the
file", or record the deviation as a plan defect.

**A5 — I1: "the record's final output" has two byte readings.**
Sentence: *"…B = the byte length of the `R60MutCounters` record's final output (both derived
from that file)"*. The record's `output` field is **3824** bytes; the **final line** of that
field is `}` (**1** byte); the whole serialised record is 4097 bytes. The spot-check's own
evidence ("`R60MutCounters` output 3824 B") and the plan's motivating text ("its 3824-byte
output") both mean the whole `output` field, so a checker must be told that explicitly
("the `output` field of the record, in bytes") or it may measure the wrong thing.
Same class of slack, smaller: I1's R is "the number of result records" — measured 16 as
`len(results)`, and the file's `seats` field is also 16, so the two agree (no divergence).

**A6 — the population-census sentence omits the flag it depends on.**
Sentence: *"**Population census at BASE (must be measured, not assumed):** the checker on the
BASE tree prints `value=7 population=7`."* and *"The BASE census is taken with `--no-challenge`."*
The two are only compatible under `--no-challenge`; on the BASE tree the guard challenge cannot
fire (there is no I5 correction line to mutate), so a challenge-enabled run at BASE prints
`value=FAIL … guard=0` (the round-60 instrument's own semantics: `value_token = str(count) if
guard == 1 else "FAIL"`). The census sentence should say "with `--no-challenge`". Hand-check
confirms 7/7 unresolved at BASE (table above), so the **number** 7 is right; only the flag is
unstated.

**A7 — I7: the role field is `agent`, and 16 is triply redundant.**
Sentence: *"…3 = the number of attack roles from `{reviewer, critic, mutation-tester, labrat}`
present in `.ufo/waves/round-60/w1-results.json`…"*. The JSON records have keys
`name, agent, output, note` — there is **no** `role` key; the role lives in **`agent`**. A
checker must be told this, or a `record["role"]` read raises. `16` is available three ways
(`len(results)`, the `seats` field, the dispatch `counts.total`) and all three agree, so the
number is unambiguous; the *source* is not named. (Also note `4/16 = 25 %` is defined in the
plan as "3 + the sentinel" — the sentinel seat is present (`R60SentinelTrial`), so the
derivation holds; but the plan's separate claim that the report's own `6/16 = 38 %`
"sentinel and revenger" figure is *also* wrong is not an item — see the residual below.)

---

## Residuals the frozen item set does not cover (observations, not plan defects)

1. **The report's second attack-share number is also wrong and unrouted.** The same report
   sentence that carries `4/16 = 25 %` (fleet `.ufo/reports/round-60/kagi.md:10-12`) also says
   *"and 6/16 = 38 % counting sentinel and revenger"*. Measured role mix: the seats are
   reviewer + critic + mutation-tester + sentinel + revenger = **5**, so the correct figure is
   **5/16 = 31.25 %**; `6/16` is 37.5 % and the seat count is one too high. The spot-check's
   D7 and the plan's I7 both quote only the `4/16 = 25 %` half, so after I7 is satisfied the
   report still carries a wrong sibling number and the next round's report must not repeat it.
   (The report lives in the fleet repo, not the lane; the correction belongs in the lane's
   lesson and in the next report.)
2. **The plan's motivating grep is literally true only in a weak sense.** *"`grep -rlE
   'unseal|shamir' corpus/knowledge/` matches no entry that measures the Shamir seal."* — the
   grep actually matches **6** entries: `openbao-acl-policy-semantics.md`,
   `openbao-approle-secret-id-custody.md`, `openbao-audit-device-custody.md`,
   `openbao-transit-engine.md`, `sops-age-key-rotation.md`,
   `vault-openbao-token-lease-lifecycle.md`. Five mention seal/unseal only to disclaim it; the
   sixth (`sops-age-key-rotation.md`) does measure a Shamir threshold — SOPS's age
   key-group split (`shamir_threshold=2`, `--shamir-secret-sharing-threshold 1` refused) — so
   the accurate statement is "matches 6 entries; none measures an OpenBao seal/unseal share,
   and the only Shamir threshold measured is SOPS's age key-group split, not a Vault seal".
   This is in §Motivating evidence, outside §C1's seven items, so it does not affect the
   C1 numbers — but a checker or critic repeating the sentence verbatim will be falsified by
   the grep's own output.

## Numbers the plan states wrongly

Only one, and it is a format not a value: **I6's "`-03:00` timestamps that each occur in
`git log --format='%ci'`"** — `%ci` never emits `-03:00` (it emits `-0300` with a space
separator); measured literal matches = 0. Every *value* the plan states for I1–I7 re-derives
exactly: R=16, B=3824, row 855, numstat 1/1, 9 commit times in range, 3 / 4 / 16 /
18.75 / 25, BASE `c940f51`, and the BASE census of 7 unresolved.

SEAT-STATUS: complete
