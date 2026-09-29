# Round 15 — operability: the checklist becomes an executed declaration

Axis-move: **operability 8 → 9**. Target: the last large prose surface in this
repo — the 16-item credential-hygiene checklist in `SKILL.md` — was 16 `- [ ]`
bullets with no command attached, so "the checklist is done" had no artefact and
the checked/judged split was assertion. Now each item is a row of
`corpus/checklist.tsv` executed by `corpus/checklist-run.sh`.

## 1. Pre-state, measured (at `HEAD` `2486643`)

| Claim | Measurement |
|---|---|
| items | 16 (`awk '/^## Credential-hygiene checklist/,/^## Evidence-receipt patterns/' SKILL.md \| grep -c '^- \[ \]'`) |
| items with a verdict-producing command | 0 (`ls corpus/checklist*` ⇒ nothing; `grep -rl 'hygiene checklist' corpus/*.sh` ⇒ nothing) |
| items naming a command in their text | 5 (census/drift in E1, `op-ref-probe.sh` in E5, `transcript-scan.sh` in H7, plus the ledger/`--pin` mentions) |
| count asserted anywhere | `SCORECARD.md:16` says "a 15-item hygiene checklist" — wrong by 2 when written (`ea77bf0` held 13) and stale by 3 now; no revision in the item-count history (10 → 12 → 13 → 14 → 16) ever held 15 |
| `SCORECARD.md:40/62/84` "12 checklist items are still operator judgement" | wrong at every revision it appears in (the list held 14 items and ≥3 items already named a live gate) |
| lock attribution | `PROVINCE.md:12` + `corpus/surface-census.tsv:22` filed the lock under `client.py`; `grep -nic lock client.py` ⇒ 0, flock is `the-janitor` L12/L130-131/L139-140/L175-176 |

## 2. What landed

`corpus/checklist.tsv` (16 rows, 8 columns `id class lead check expect_exit
expect_last reason note`) + `corpus/checklist-run.sh`
(`verify` | `--ratio` | `--list` | `--only ID` | `--selftest`). Three teeth
beyond "run 16 commands":

1. **bijection** — each row's `lead` ERE must match exactly one of the 16 items
   and each item exactly one row; `UNMATCHED-ITEM`/`DUPLICATE-ITEM`/
   `UNMATCHED-LEAD`/`DUPLICATE-LEAD`/`UNDECLARED`/`EXTRA` all exit 1. Adding a
   bullet to SKILL.md without a row fails the gate.
2. **declared split** — `by-hand` rows must carry a closed class plus a unique
   ≥24-char reason; the ratio floor is `ceil(items/2)` and the ratio line splits
   `delegated` (rows that call an existing gate) from `direct` (new assertions).
   Baseline: `runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6`.
3. **policy** — a `check` naming a denied surface (`op.env`, `op run|read|inject`,
   handler start/stop/run, `claim-ledger.sh`) is refused before execution; the
   ref-path sweep prints counts only, because printing the matched line is the
   leak the item forbids.

## 3. Defects found by execution, before commit

Every one of these was caught by a lane or by the gate's own selftest, on a
revision that was otherwise "green in my head":

| # | Defect | Caught by | Verdict it produced |
|---|---|---|---|
| 1 | `dup_reasons=$(for … \| sort \| uniq -d)` — the loop's last iteration returned 1 under `pipefail`, and `uniq -d` exits 1 on an empty result ⇒ `set -e` killed the script **before any verdict line** | scribe lane (`bash -x` trace ending at `+ dup_reasons=`), executor lane (independently) | exit 1, **zero bytes** on stdout/stderr |
| 2 | same class at the `last=$(… \| grep -v … \| tail -1)` site: a row printing nothing killed the run | executor lane | silent exit 1 |
| 3 | H4's front-matter capture returned a body whose last line has no trailing newline ⇒ the permission matcher read only the first entry | scribe lane (exact regex diagnosis) | `JANITOR_PERMS: DEFECT (entries=1 steps=4)` **on a correct host** |
| 4 | E4's sweep found 3 undeclared reference-shaped literals (`op-env-refs.md:14`, `round-5-aggregator-audit.md:19`, `transcript-scan.sh:202`) | the gate itself, first contact | `REF_PATH_SCAN: hits=3` |
| 5 | the rewritten E4 check swallowed its own verdict (`n=$(raw=…; printf …; test …)` — nothing reached stdout) | scribe lane, verbatim re-run | `ITEM-LASTLINE E4 (got …)`, no verdict line |
| 6 | H8 accepted a **wildcard** listener on 40961 (any listener count passed) | scout lane, branch-proven on scratch ports | `CONTROL_PLANE … listeners=1 established=0` ⇒ PASS when it must fail |
| 7 | H1 was satisfiable by comment text (`grep -c 'flock 9'` counts a comment) | critic lane, fake-`HOME` fixture | `CLIENT_LOCK flock=2 declared=1 mode=absent` ⇒ rc 0 with no lock |
| 8 | H7 declared `expect_exit 0\|1` while the DB-absent state the item itself prescribes exits 2 | scout lane, executed against a missing DB | `ITEM-FAIL H7` on a legitimate purge |
| 9 | selftest re-invoked itself as `"$0"` ⇒ exit 127 from a foreign cwd | labrat lane | selftest unusable outside the repo root |

Fixes: guarded substitutions + `awk` last-line extraction; `fm + "\n"`; a
three-name placeholder vault allowlist **plus** `hits/excluded/raw` printed and
pinned; `non_loopback=0` asserted; H1 line-anchored (`^[[:space:]]*flock 9`,
`^[[:space:]]*exec 9>"$LOCK_FILE"`); H7 accepts exactly two states (`HITS=2` or
`db not found`); `$SELF` absolute. Selftest grew 0 → 34 cases, each fixture
rebuilt from scratch instead of mutated by `sed`.

## 4. The L2 wave, and what it changed

14 lanes, one batched call: planner, connector, 2 scouts, scribe, 2 executors,
reviewer, critic, sentinel, labrat, mutation-tester, simplifier, distiller.

- **planner** produced the competing classification: `runnable=3 by_hand=13` on a
  strict "the item's own stated outcome" reading, and flagged E5 because the
  delegated probe execs `op run`. Both are recorded, not smoothed: the shipped
  criterion is "is there a command whose verdict is a defect signal for this
  item", the row's `note` names what is left to the operator, and the E5
  deviation is written on the row.
- **scout (H)** measured the host facts and found the wildcard-bind hole; **scout
  (items)** did the item census, the count-defect sweep, and A1–A6 attacks.
- **scribe** caught two silent-death bugs and the H4 boundary bug with exact
  diagnoses; **executor** independently reproduced them; **executor 2** drafted
  the report from measured facts only.
- **critic** produced three executed counterexamples: comment-text matching (H1,
  fixed), an unexamined env file carrying the password (H8, recorded as a scope
  bound), and a 16-row constant-`printf` TSV passing `CLEAN (runnable=16/16)`
  (recorded as the axis ceiling — no guard can tell a meaningful assertion from a
  well-formed one; the `delegated`/`direct` split is the only mechanical signal).
- **sentinel** passed all four policy questions and confirmed the E4 sweep found
  no concrete ref path or pasted run output in the repo.
- **labrat** proved the port check works via a scratch listener, timed the
  aggregate gates (2.2 s for the whole checklist), and empirically confirmed
  **nothing schedules any `corpus/*.sh`** — so the operability ceiling is
  unchanged and this round does not claim it.
- **simplifier** argued E1 should be deleted (the item already names both gates)
  and proposed a minimal honest set of 6 runnable rows; kept as a recorded
  dissent — the row is count-pinned and produces the item's verdict, and 9 ≥ 8
  with the reason stated.
- **distiller** collapsed the wave to 9 unique moves, 3 duplicates, and no
  unresolved contradictions.
- **connector** mapped sibling verifiers (kotoba's checklist→disposition
  checker, kumitate's doc-coverage score, kasegi's anchor checker): none
  implements an item→command→verdict contract, so this is adjacent, not
  duplicated; the shared shape (a stable-ID outcome ledger) is reported to the
  integrator.

## 5. Bounds and falsifiers

The full set is `corpus/knowledge/checklist-execution.md` §6 (12 bounds) and §7
(10 falsifiers). The two that matter for the score: a runnable row verifies the
item's machine-checkable **premise**, not the operator's duty — the `note`
column carries that admission and is not gate-enforceable; and nothing schedules
the gate, so the remaining operability increment (scheduling, and the 7 by-hand
duties) is explicitly not claimed.