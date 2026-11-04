# Round-34 gate registry draft — observed lane bytes

Paste these three one-line rows into the existing eight-column registry (`name`, `kind`, `entry command`, `verdict map`, `selftest`, `pinned values`, `write scope`, `owner`). Counts below are executed readings, not round-34 target counts.

| pre-freeze BASE controls (`corpus/prefreeze-control.sh`) | gate | `bash corpus/prefreeze-control.sh run --base <rev> --controls <tsv> [--work <dir>] [--timeout <s>]` | 0 `PREFREEZE: CLEAN (controls=N mismatch=0)`; 1 `PREFREEZE: MISMATCH (controls=N mismatch=M)`; 2 `PREFREEZE: SETUP <reason>` | `bash corpus/prefreeze-control.sh --selftest` (11 cases observed) | caller-selected BASE commit and controls TSV (`id`, integer `expect`, command); timeout default 300 seconds; final digit run on last nonempty stdout line | extracts BASE and stores stderr under temporary `--work`/`TMPDIR`, removed on exit; executes caller-supplied commands, not a write sandbox; selftest isolated temporary Git fixtures | kagi |
| self-description sweep (`corpus/self-description-sweep.sh`) | gate | `bash corpus/self-description-sweep.sh [--root DIR] [--selftest]` | 0 `SELF_DESCRIPTION: CLEAN n=0`; 1 `SELF_DESCRIPTION: MISMATCH n=N (SD…)`; 2 `SELF_DESCRIPTION: SETUP <reason>` | `bash corpus/self-description-sweep.sh --selftest` (7 cases observed) | code-held SD1–SD6 predicates; root defaults to current directory; `PROVINCE.md`, `corpus/README.md`, `SHONEN.md`, `corpus/lessons/round-31.md`, `SCORECARD.md`, and citations output | reads selected working-tree files and invokes that root's citations gate; no direct normal-mode file writes; selftest temporary fixtures removed on exit | kagi |
| differential feed-token agreement (`corpus/feed-token-agree.py`) | gate | `python3 -B corpus/feed-token-agree.py [--instrument FILE]`; `--selftest` selects synthetic offline cases only | 0 `FEED_TOKEN_AGREE: AGREE (shapes=N disagreements=0)`; 1 `FEED_TOKEN_AGREE: DISAGREE (shapes=N disagreements=N)`; 2 `FEED_TOKEN_AGREE: SETUP (…)` (argparse usage errors also exit 2) | `python3 -B corpus/feed-token-agree.py --selftest` (4 cases observed) | 12 code-held `SHAPES`; imports three extractor regexes and `STABLE_TOKEN_RE` from sibling `corpus/release-clock.py` by default or selected instrument | no explicit file writes or network calls; imports executable instrument code (not sandboxed); `-B` suppresses Python bytecode writes; selftest synthetic in-memory extractors | kagi |

Paste-under-table paragraph: These are counters and extraction-agreement checks, not vault access or vendor-truth checks. Pre-freeze controls execute reviewed caller-supplied shell commands, ignore their exit codes except timeout, and compare the final digit run on the last nonempty stdout line. SD6 counts citations-gate `UNRESOLVED` lines, including the three integrator-owned residual lines explicitly excluded from round-34 C1's SD7–SD9 target; that exclusion does not make the whole sweep CLEAN. The inspected sweep reads the selected working tree, not committed bytes: do not assert committed-only behavior without implementation evidence. The observed selftests prove 11/7/4 cases respectively, not the round-34 12/10 targets.

## Cell provenance and quoted code

All source paths below are absolute. Owner `kagi` is registry convention, not an executable assertion: `/home/vgpnk/Projects/shokunin/kagi-shokunin/SKILL.md:748-754` supplies the eight-column header and the last three eight-column rows (rendered-text helper, row-identity helper, source census), each ending `kagi`. The later round-25 addition uses three columns, so its shape was not copied. Kind `gate` follows each script's verdict-emitting check behavior, not a separately encoded owner/kind field.

### Pre-freeze

Source: `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/prefreeze-control.sh`.

- Name/kind/pins: lines 7–15 quote `PREFREEZE: CLEAN (controls=N mismatch=0)` and `id<TAB>expect<TAB>command`, with extraction of `--base <rev>`; lines 29–34 quote `numeric counters only` and `FINAL digit run`. Line 61 quotes `MODE=run BASE_REV='' CONTROLS='' WORK='' TIMEOUT=300`.
- Entry/parser: lines 67–85 accept `run`, `--selftest`, `--base`, `--controls`, `--work`, `--timeout`; lines 80–81 quote `run --base <rev> --controls <tsv> [--work <dir>] [--timeout <s>]` and `--selftest`.
- Verdicts: lines 264–273 quote `PREFREEZE: SETUP %s` / `exit 2`, `PREFREEZE: MISMATCH (controls=%d mismatch=%d)` / `exit 1`, `PREFREEZE: CLEAN (controls=%d mismatch=0)` / `exit 0`.
- Selftest: lines 87–102 quote `mktemp -d`, `git -C "$repo" init -q`, `[ "$top" = "$phys" ] || die fixture-toplevel-mismatch` before commit. Lines 176–181 quote `PREFREEZE_SELFTEST: PASS (%d cases)` / return 0, or FAIL / return 1. The count is supported by execution below, not inferred from a target.
- Write scope: lines 222–243 quote `WORK_ROOT=${WORK:-${TMPDIR:-/tmp}}`, `BASE_DIR=$EXTRACT/tree`, `RECEIPTS=$EXTRACT/stderr`, `trap 'rm -rf -- "$EXTRACT_TMP"' EXIT`, and `BASE=$BASE_DIR LANE=$REPO timeout "$TIMEOUT" bash -c "$cmd"`. Arbitrary command effects are not confined by this code. Lines 18–20 explicitly say command exit codes are ignored and stderr is temporary.

### Sweep

Source: `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-description-sweep.sh`.

- Name/kind/verdict: lines 26–29 quote the CLEAN/MISMATCH/SETUP verdicts with exits 0/1/2; lines 379–389 implement CLEAN exit 0 and MISMATCH exit 1; line 49 implements SETUP exit 2.
- Entry/parser/pin: lines 46–69 quote `ROOT=.`, `--root`, `--root=*`, `--selftest`, and `usage: %s [--root DIR] [--selftest]`.
- Data/predicates: lines 258–260 quote `province=$ROOT_ABS/PROVINCE.md` and `themes=('OIDC workload-federation' 'secret[- ]scanning')`; lines 285, 308, 327, 339 assign `corpus/README.md`, `SHONEN.md`, `corpus/lessons/round-31.md`, `SCORECARD.md` under `$ROOT_ABS`; lines 361–374 invoke `bash corpus/claim-ledger.sh citations` inside that root and increment SD6 for `UNRESOLVED*`.
- Selftest/write scope: lines 194–196 quote `mktemp -d "${TMPDIR:-/tmp}/sd-sweep-selftest.XXXXXX"` and removal trap; lines 222–238 create clean plus `SD1 SD2 SD3 SD4 SD5 SD6` fixtures; lines 240–245 print `SELFTEST: PASS (%d cases)` / return 0 or FAIL / return 1. Lines 35–36 state `Writes nothing except stdout; selftest writes a fixture tree`.
- Committed-only conflict: lines 68–69 resolve an existing directory; lines 267 and 305 use `done < "$province"` and `done < "$readme"`. These are direct working-tree reads, not Git-object reads. The requested phrase `reads committed bytes only` cannot truthfully describe these inspected bytes.

### Feed agreement

Source: `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/feed-token-agree.py`.

- Name/kind/bounds: lines 2, 24–30 quote `Differential feed-token agreement gate`, `Exit 0 AGREE / 1 DISAGREE / 2 SETUP`, and `EXTRACTION agreement only`.
- Pins/data: lines 47–61 define 12 `SHAPES` and `EXTRACTORS = ("STABLE_TITLE_RE", "STABLE_TAG_HREF_RE", "TEXT_VERSION_RE")`; lines 77–79 require these plus `STABLE_TOKEN_RE` as `re.Pattern`.
- Entry/parser/default: lines 219–239 quote `allow_abbrev=False`, `--instrument`, `--selftest`, rejection of their combination, and `args.instrument or Path(__file__).resolve().parent / "release-clock.py"`.
- Verdicts: lines 140–149 print DISAGREE and return 1, otherwise AGREE and return 0; lines 236–238 print SETUP and return 2. Parser usage errors follow Python argparse behavior, not a custom verdict print.
- Selftest: lines 152–159 quote `synthetic extractors only (never the live file)` and the four cases; lines 179, 186, 195, 204 each increment `cases`; lines 211–216 print failure / return 1 or `FEED_TOKEN_AGREE_SELFTEST: PASS (%d cases)` / return 0.
- Write scope: lines 69–76 quote `spec.loader.exec_module(module)`. No import sandbox is present; the header's no-write characterization should not be interpreted as confinement of arbitrary `--instrument` code. `-B` is the invocation's Python bytecode-write suppression, not a flag parsed by this script.

## Observed selftest receipts

Executed once per lane script, with cwd `/fast/scratch/hyaku/kagi-r34/ScribeRegistry`, `export TMPDIR=/fast/scratch/hyaku/kagi-r34/ScribeRegistry/tmp`, and shell cleanup `trap 'rm -rf -- "/fast/scratch/hyaku/kagi-r34/ScribeRegistry"' EXIT`. No run-mode/full-gate invocation was made.

```text
COMMAND: bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/prefreeze-control.sh --selftest
CASE equal-values               ok
CASE one-differs                ok
CASE two-differ                 ok
CASE no-integer                 ok
CASE malformed-row              ok
CASE missing-controls-file      ok
CASE grep-c-exit1-is-zero        ok
CASE empty-controls             ok
CASE bad-rev                    ok
CASE timeout                    ok
CASE base-isolation             ok
PREFREEZE_SELFTEST: PASS (11 cases)
EXIT: 0
COMMAND: bash /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/self-description-sweep.sh --selftest
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
SELFTEST: PASS (7 cases)
EXIT: 0
COMMAND: python3 -B /home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/feed-token-agree.py --selftest
FEED_TOKEN_AGREE_SELFTEST: PASS (4 cases)
EXIT: 0
```
