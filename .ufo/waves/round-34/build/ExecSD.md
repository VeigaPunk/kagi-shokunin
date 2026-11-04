# ExecSD — round-34 C1 deliverable

Axes: calibration, operability, coverage. Implemented only assigned C1 sweep bytes; no lane-tracked files changed.

## Files delivered

- `.ufo/waves/round-34/build/self-description-sweep.sh`
- `.ufo/waves/round-34/build/ExecSD.md`
- `.ufo/waves/round-34/build/receipts/selftest-new.txt`
- `.ufo/waves/round-34/build/receipts/base-new.txt`
- `.ufo/waves/round-34/build/receipts/tip-new.txt`

Implementation starts from `git show f9dc06fd8f6b43c175193c76dc6350468f551634:corpus/self-description-sweep.sh`. SD1–SD6 check bodies remain unchanged. Added literal basename-registry SD7, line/token-specific lesson-range SD8 (full and abbreviated endpoints; cross-round ignored), and presence-only provenance-trio SD9. Updated header, verdict, expected-verdict regex, and three planted fixtures. SD8 reports one failed condition per token, ordered missing lesson, missing upper endpoint, higher row; this follows the frozen counter's short-circuit order. SD9 follows the explicit Work #3 and frozen counter: first literal `^Reverify: ` line, including its space. Empty provenance values satisfy the presence-only predicate.

## Exact authorized readings

Each command ran once against delivered bytes; command, complete stdout/stderr, and exit are retained in the named receipt.

| Reading | Result | Exit |
|---|---|---|
| `bash <deliverable> --selftest` | `SELFTEST: PASS (10 cases)` | 0 |
| `bash <deliverable> --root <BASE extraction>` | `SELF_DESCRIPTION: MISMATCH n=8 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=3 SD7=3 SD8=1 SD9=1)` | 1 |
| `bash <deliverable> --root /home/vgpnk/Projects/shokunin/kagi-shokunin` | same exact verdict as BASE | 1 |

The clean case printed `CASE clean ok`; all nine planted cases printed `ok`. SD7 identifies prefreeze-control.sh, self-description-sweep.sh, feed-token-agree.py; SD8 identifies README line 95 and M33-4 exceeding M33-3; SD9 identifies prefreeze-controls.md missing all three keys. Three named SD6 exclusions remain untouched. These are pre-install readings, not a claim that landing SD789_SUM is already zero.

## Mutation evidence

Three independent scratch copies of delivered bytes were changed using surgical edits. Each mutant ran `--selftest` once. Complete command/output/exit transcripts follow below. SD7: deleted its script loop. SD8: widened range validation to any same-round lesson row, removing endpoint/high-water constraints. SD9: removed the trio test and emission. Each yields exactly its corresponding `CASE SDn FAIL (rc=0 last=SELF_DESCRIPTION: CLEAN n=0)`, `SELFTEST: FAIL (10 cases)`, exit 1.

## Bounds, risks, handoff

No network, vault contact, tool installs, subagent dispatch, fixture git mutation, lint, formatter, build, or full-suite execution. LSP is unavailable in the mounted tool inventory; no symbol service was invoked. Work used scratch-local TMPDIR, with cleanup after preserving evidence. The edit tool warned of a Bash parse error near comment line 2; authorized execution proved the exact artifact parses and runs, and the tool inconsistency was reported.

Reviewer raised multi-Reverify and no-space Reverify cases; those are intentionally excluded by Work #3's first-line/literal-space binding and the freeze counter. No predicate or counter was changed. The script still reads the selected --root tree, not git objects; BASE evidence uses an explicit git-archive extraction, retaining the mandated interface and SD1–SD6 behavior. The plan's 'committed bytes only' wording should not be interpreted as a new git-index read mode.

L1 owns installation, post-integration full gates, and the landing SD789_SUM counter. No implementation blockers.

## SD9 hardening addendum (MutSweep M5/M6 survivors closed)

KagiR34 routed two selftest survivors from MutSweep against the original delivery: M5 (trio required for every entry) and M6 (source key only). Closed without changing the frozen 10-case tally or any predicate; the run-mode check code is byte-identical (verified by diff of the checks/verdict region), so the base-new/tip-new 3/1/1 readings above remain exact for this artifact.

Delta, all inside fixture/selftest code only:

- Clean common fixture now carries `corpus/knowledge/legacy-entry.md` (`Reverify: R29-01`, no trio). Real SD9 skips r<30, so the clean case stays `n=0`; M5 flags it, breaking the clean assertion.
- SD9 fixture now plants a second entry `fixture-source-only.md` (`source:` present; `verified-at:`/`recheck:` absent) beside the all-missing `fixture-entry.md`, so the real check counts 2 and M6 counts 1.
- `run_case` gains optional `expected_n` (default 1) and asserts it in the verdict regex; the SD9 case expects n=2. M6's n=1 now fails the SD9 case.

Authorized readings, complete transcripts retained in the named receipts:

| Reading | Result | Exit |
|---|---|---|
| `bash <deliverable> --selftest` | `SELFTEST: PASS (10 cases)`, clean case plus all nine `ok` | 0 |
| M5 mutant (`qualifies=0`→`1`, fixed bytes + one line) `--selftest` | `CASE clean FAIL`, `SELFTEST: FAIL (10 cases)` | 1 |
| M6 mutant (`for key in source` only) `--selftest` | `CASE SD9 FAIL`, `SELFTEST: FAIL (10 cases)` | 1 |

Mutation procedure note: M5/M6 are the fixed bytes plus exactly the one-line mutation; an initial mis-built pair (mutations applied to the pre-hardening delivery) survived vacuously for lack of the new fixtures and was discarded, not retained; the receipts above are the corrected reproductions. Installed `corpus/self-description-sweep.sh` untouched; L1 installs the candidate from this build path.

## Self-evaluation

Accuracy 4/5: the three exact authorized readings and three mutants support the implementation; abbreviated/cross-round paths were not separately exercised by this seat. Completeness 5/5: all assigned checks, fixtures, verdict/header changes, receipts and mutants delivered. Clarity 4/5: report separates pre-install readings from landing acceptance, but command paths make transcripts long. Actionability 5/5: final bytes ready for L1 installation with retained receipts. Conciseness 4/5: full mutation logs intentionally repeat unaffected cases. Overall 4.4/5; strongest future improvement is parent-owned edge-case coverage, without expanding this seat's authorized runs. User agreement expected on evidence and bounds.

### Retained mutant transcripts

```text
$ bash /fast/scratch/hyaku/kagi-r34/ExecSD/mut-sd7.sh --selftest
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
CASE SD7 FAIL (rc=0 last=SELF_DESCRIPTION: CLEAN n=0)
CASE SD8 ok
CASE SD9 ok
SELFTEST: FAIL (10 cases)
EXIT=1

$ bash /fast/scratch/hyaku/kagi-r34/ExecSD/mut-sd8.sh --selftest
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
CASE SD7 ok
CASE SD8 FAIL (rc=0 last=SELF_DESCRIPTION: CLEAN n=0)
CASE SD9 ok
SELFTEST: FAIL (10 cases)
EXIT=1

$ bash /fast/scratch/hyaku/kagi-r34/ExecSD/mut-sd9.sh --selftest
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
CASE SD7 ok
CASE SD8 ok
CASE SD9 FAIL (rc=0 last=SELF_DESCRIPTION: CLEAN n=0)
SELFTEST: FAIL (10 cases)
EXIT=1
```
