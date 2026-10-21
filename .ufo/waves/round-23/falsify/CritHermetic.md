# CritHermetic — round-23 falsification (C3 / D9 / R23-01)

Seat: critic. I attacked the hermetic claim of `corpus/fixtures/cells-hermetic/` and `R23-01`. I looked for a reachable default path, `$HOME` read, substrate probe, or `SKIP-SELF` path, and tested whether `rows_run=2` proves real execution rather than deferral.
Axes judged: operability (C3), calibration (wording/attribution), freshness (target identity).

## Target, pinned (the target moved during the wave)

The lane was committed while I was measuring: `e1884c6` (01:04:19), `ea5b734`, `b55e0e7`, `7af07b4`, and `638d44c` (01:11:12, final HEAD). From `e1884c6` to `638d44c`, the fixture blobs, `corpus/claim-ledger.sh`, and the R23-01 row stayed byte-identical. I checked the sha256 of each file in my HEAD snapshot against the blobs at `638d44c`, and all of them match:

| file | sha256 |
|---|---|
| `corpus/claim-ledger.sh` | `c20c2d04a354…` |
| fixture `SCORECARD.md` | `2358325254a1…` |
| fixture `claims.tsv` | `1a0737717ddc…` |
| fixture `stamps.tsv` | `401ebb3c8b15…` |
| fixture `corpus/fx-ok.sh` | `29f98fbaaa24…` |
| fixture `corpus/adjacency.tsv` | `fa15a53c7e58…` |

- R23-01 is at `corpus/claim-ledger.tsv:59`. Its command and expectation are unchanged. Its note at HEAD already says "rows_run counts selected rows" (RevFixtureRun F1).
- The final live run used the exact R23-01 command from the lane root at 2026-10-21T01:11:29, HEAD `638d44c`. It exited **0**, and its last line is byte-equal to the ledger ERE literal:
  `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)`.

## Commands and exits

How the experiments ran:
- Each run used `bash -o pipefail -c '<R23-01 command>'` with `CLAIM_LEDGER_DEPTH=1`, exactly as the ledger runner does at `claim-ledger.sh:426-427`. A Python subprocess captured stdout, stderr and exit.
- Mutations were made only in scratch copies under `/tmp/kagi-r23-crithermetic.*`. That scratch directory was removed after this report was written.
- "Scratch lane" means a copy holding `corpus/claim-ledger.sh` plus the fixture. All overrides are explicit, so `SCRIPT_DIR` defaults are never read.
- The strace runs used `strace -ff -qq -s 512 -e trace=%file,%network,%process`.

| # | Command or variant | Exit | Observed |
|---|---|---|---|
| C0 | **Live** exact R23-01, 01:02:3x (uncommitted tree; fixture `SCORECARD.md` = sha `d511a05e53a1…`, 413 B, mtime 01:02:31.317, line 1 `<!-- D9: hermetic cells fixture; executable via R23-01 in corpus/claim-ledger.tsv -->`) | **1** | `MISSING-ID SCORECARD.md:1 R23-01` and `CELL_AUDIT: BROKEN (… missing_ids=1 rows_run=2 row_deferred=0 … self_skipped=0 …)` |
| C1 | Live exact R23-01, 01:03:08 (line 1 changed at 01:03:02 to `…rows are declared in claims.tsv -->`) and again at 01:06:55 and 01:11:29 | 0 | Exact pinned line |
| C2 | strace of exact R23-01 on the HEAD snapshot | 0 | See the strace summary below |
| C3 | `HOME` = real, empty scratch dir, scratch dir with executable `.local/bin/the-janitor`, or unset | 0 ×4 | Byte-identical stdout in all four cases. The fake janitor never ran. |
| C4 | Both fixture notes + ` [substrate]`: `KAGI_SUBSTRATE=absent` | 0 | `DEFER R90-01…`, `DEFER R90-02…`, `CELL_AUDIT: CLEAN (… rows_run=2 row_deferred=2 …)`. Zero executions; the ERE does not match. |
| C4 | Same copy with `KAGI_SUBSTRATE=present`, or unset with a fake-janitor `HOME` | 0 | **Exact pinned line**. The unset run probes `faccessat2(<HOME>/.local/bin/the-janitor)` ×2. With an empty `HOME` it defers. |
| C5 | Fixture `corpus/fx-ok.sh` replaced by `ls -A -- "$HOME" > home-listing.txt 2>&1; printf 'FX: OK\n'` | 0 | **Exact pinned line**. strace shows `statx` + `openat` on `$HOME`. The listing was written. The fixture stamp is stale (`29f98fba→e1beef83`) but never compared. |
| C5d | C5 plus the fixture operability cell citing `` `R90-01` and `corpus/fx-ok.sh` `` (original script, then modified) | 0 / **1** | Original: `CLEAN (… stamp_pointed=2 …)`. Modified: `STALE-POINTER corpus/fx-ok.sh sha=29f98fbaaa24->e1beef835a8b lines=2->3 bytes=38->79` and `BROKEN` |
| C6a | Scratch outer root: six-axis scorecard citing `R99-01`, whose command is **byte-identical to R23-01's**. No fixture is present. | 0 | `SKIP-SELF R99-01 …` and `CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=0 … rows_run=0 … self_skipped=1 orphans=0)` |
| C6b | Real `SCORECARD.md` (`git show <rev>:SCORECARD.md`), claims restricted to the real ledger's self-invoking rows, so zero rows can execute. Command: `bash corpus/claim-ledger.sh cells --root <lane> --claims <scratch>/self.tsv --stamps <lane>/corpus/stamps.tsv --scorecard <scratch>/SC.md --docs <scratch>/SC.md` | 1* | HEAD `b55e0e7`: `SKIP-SELF R11-08 R11-09 R14-01 R13-03 R18-03 R23-01`, `rows_run=0 self_skipped=6`. Base `d218603`: the same set **without R23-01**, `self_skipped=5`. *Exit 1 is caused only by the restricted claims file (other ids are missing). |
| C6c | Byte-exact replay of the C0 transient fixture (reconstructed sha `d511a05e53a1de16…` equals the observed sha): direct R23-01 vs `cells` over a scorecard citing that byte-identical command | **1** / **0** | Direct run: `BROKEN … missing_ids=1`. Cell audit: `SKIP-SELF R99-01` and `CELL_AUDIT: CLEAN (… rows_run=0 … self_skipped=1 …)` |
| C7 | R90-01 → `cat corpus/fx-ok.sh` | 2 | `POLICY R90-01 reason=first-token:cat` and `CELL_AUDIT: POLICY (cells=6 row_pointed=6 stamp_pointed=1 policy=1)` |
| C8 | `BASH_ENV=<scratch>/benv.sh` (appends `$0 $*` to a scratch log) | 0 | Exact line. `BASH_ENV` was sourced **5×**: caller wrapper, `corpus/claim-ledger.sh`, R90-01 wrapper, `corpus/fx-ok.sh`, R90-02 wrapper. |
| C9 | Exact command run from a non-lane cwd | 127 | `bash: corpus/claim-ledger.sh: No such file or directory`. The row is cwd-relative and fails closed. |
| C10 | `PATH=<scratch>/shadowbin:$PATH` with a logging `grep` wrapper | 0 | Exact line. 18 `grep` calls went through the shadow, including the R90-02 row. |
| C11 | R90-01 → `grep -c claim-ledger.sh corpus/fx-ok.sh` / `^0$` (a reader row, not an invocation) | 0 | `SKIP-SELF R90-01` and `CLEAN (… rows_run=1 … self_skipped=1 …)`. The ERE rejects it. |
| C12 | Fixture `stamps.tsv` emptied | 2 | `claim-ledger: no stamp rows in … (refusing to report coverage with an empty stamp set)` |
| C13 | Caller env `BASH_FUNC_timeout%%='() { case "$*" in *fx-ok.sh*) printf "FX: OK\n";; *adjacency.tsv*) printf "8\n";; esac; }'` | 0 | **Exact pinned line, 0 row executions**: no `timeout`, no `bash corpus/fx-ok.sh`, no row `grep` execve |
| C13b | C13 plus `PATH=/usr/bin:/bin HOME=/nonexistent-kagi-crit` | 0 | **Exact pinned line, 0 row executions** |
| C13c | C13 env, but the gate is launched as `env -i PATH=/usr/bin:/bin HOME=/nonexistent-kagi-crit LC_ALL=C CLAIM_LEDGER_DEPTH=1 <cmd>` | 0 | Exact line. Both rows really executed. |

**C2 strace summary (HEAD snapshot):**
- 93 processes and exactly **2** `timeout` row launches:
  - `["timeout","-k","5","10","bash","-o","pipefail","-c","bash corpus/fx-ok.sh"]`
  - `["timeout","-k","5","30","bash","-o","pipefail","-c","grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv"]`
- Both row processes `chdir` into the fixture root and open the fixture's `corpus/fx-ok.sh` and `corpus/adjacency.tsv`.
- 0 network syscalls and 0 `the-janitor` probes.
- Non-lane `$HOME` syscalls: **0 succeeded, 320 failed with ENOENT**. These are `newfstatat` ×38 and `execve` ×2 per directory, over the 8 `$HOME` PATH directories that precede `/usr/bin`: `.grok/bin`, `.kimi-code/bin`, `.local/share/mise/installs/node/latest/bin`, `.local/share/mise/shims`, `.local/share/fnm`, `.local/share/omarchy/bin`, `.opencode/bin`, `.local/bin`.
- Opened files: the fixture files, the gate script, `/etc/ld.so.cache`, `/usr/lib/locale/locale-archive`, `/usr/share/locale/locale.alias`, `/usr/lib/*.so`, and one `/tmp/tmp.*` (created at `claim-ledger.sh:806`, then unlinked).
- Every binary executed came from `/usr/bin`.

Read-only git commands used: `status --short`, `log`, `show`, `diff`, `rev-parse`, `ls-files -s`, `reflog`. Note that `git status` may refresh the index stat cache; it does not change content or history.

## Findings

### F1 — Medium (operability, calibration): the real `cells` audit self-skips the C3 scorecard cell's evidence, and the round does not say so

**Counterexample.**
- `SCORECARD.md:841` is the operability cell inside `## Round 23 — post-move` (`:835`). Its only row pointer is `R23-01`.
- R23-01's command must invoke `corpus/claim-ledger.sh`. The `SKIP-SELF` predicate is a substring test, `${TF[1]:-} == *claim-ledger.sh*` (`claim-ledger.sh:816-820`).
- Every real `cells` run (R13-03) therefore prints `SKIP-SELF R23-01` and counts the cell as `row_pointed` with **no re-run**.
- C6b measures this directly: self-skips go from 5 to **6** (base `d218603` vs HEAD), and R23-01 is the newcomer.
- R13-03's ERE pins `self_skipped=[0-9]+` (`corpus/claim-ledger.tsv:38`), so the change is invisible to every gate.
- C6c replays the red state I observed live (C0): R23-01 run directly is **red (exit 1)**, while a cell audit citing the byte-identical command is **CLEAN (exit 0)**.

**Why it matters.**
- This is the M23-3 bug class ("`cells` can print CLEAN while a cited row is self-skipped and red", `corpus/lessons/round-23.md:148`), newly instantiated by this round's own C3 cell.
- M23-3's mitigation reads "the hermetic fixture deliberately cites no self-invoking row, and the real-tree claim is not made". Yet the real-tree cell `:841` *is* a self-invoking citation.
- D9 (`:125-130`) states the general bound but does not name R23-01 as a member of the class.
- In round 23, R23-01's pass rests only on direct safe-row execution (`.ufo/waves/round-23/final-verification.json:299-303`, `measured_commit` `e1884c6` at `:3`). R13-03 was skipped as host-bound (`:162-165`).

**Smallest safe correction (wording/pointer; no code).**
- State at `SCORECARD.md:841` and in D9/M23-3 that R23-01 self-invokes the gate. R13-03's `cells` self-skips it (self_skipped 5→6 vs `d218603`), so the cell is verified only by direct execution of R23-01.
- Optionally, add a non-self pointer that R13-03 *can* check, e.g. a stamped fixture path such as `corpus/fixtures/cells-hermetic/claims.tsv` (`corpus/stamps.tsv:22`). The real cell audit then verifies at least the fixture's identity.

**Tradeoff for the judge.** Replacing the substring SKIP-SELF test with a depth bound would let a top-level `cells` re-run R23-01 once. That means re-running self rows only at `CLAIM_LEDGER_DEPTH=0`, while `cells` at depth ≥1 keeps skipping. This is a design change with cost: R11-09/R18-03 selftests would run inside `cells`. It is not a this-round fix.

### F2 — Low-Medium (calibration): the exact line proves execution only under a trusted caller environment; the lesson's exclusivity claim is false

**Counterexample.**
- C13 and C13b: one inherited exported-function variable (`BASH_FUNC_timeout%%`) makes R23-01 print the **byte-identical pinned line with zero row executions**. This holds even after sanitizing `PATH=/usr/bin:/bin` and `HOME=/nonexistent`.
- `PATH` shims are the same class (RevFixtureRun's `timeout` shim; my C10 shadow `grep`).
- `BASH_ENV` is sourced by every bash in the run (C8, 5×). A caller with `BASH_ENV` pointing into `$HOME` reads `$HOME` four times inside the gate.
- Only scrubbing the environment closes all three channels (C13c).

**Why it matters.**
- `corpus/lessons/round-23.md:194-196` says "only `row_deferred=0`/`self_skipped=0` exclude an unexecuted fixture". Under an inherited hijack, neither counter excludes it.
- `final-verification.json` records no environment for R23-01's pass.
- The gate cannot defend itself: `env` is not allowlisted (`claim-ledger.sh:160`), `$` is a refused metacharacter (`:163`), and the runner does not scrub the environment (`:426-427`).

**Smallest safe correction.**
- Bound the wording: "the exact line proves two real executions given a trusted environment (system PATH; no `BASH_ENV`; no exported `BASH_FUNC_*`)".
- Record `PATH` and the presence (names only) of `BASH_ENV` / `BASH_FUNC_*` in the verification JSON.
- Code (judge's tradeoff, affects all rows): run row commands under `env -i PATH=/usr/bin:/bin HOME=<scratch> LC_ALL=C`. C13c shows R23-01's line is unchanged under that scrub.

### F3 — Low (calibration): "no `$HOME`" and "No real host path is read" over-claim at syscall level

**Counterexample.** C2 measured the following:
- No `$HOME` file is opened.
- PATH resolution makes 320 ENOENT probes across 8 `$HOME` bin directories, including `$HOME/.local/bin`, the substrate's own directory.
- The selected binaries depend on those directories' contents (C10).
- System loader and locale files are read.
- One temp file is written in `${TMPDIR:-/tmp}`.

**Where the over-claim appears.** "No real host path is read" (`corpus/lessons/round-23.md:167`), "no host file, no `$HOME`" (`:126`), and "no $HOME" (`corpus/claim-ledger.tsv:59` note) are literally false. The late SentHostReads bound (`:198-200`) covers `~`/absolute arguments and `/tmp`, but not PATH probing.

**Smallest safe correction.** Reword to: "no `$HOME` file is opened and no network or substrate probe occurs; tools resolve through the inherited PATH (here 8 `$HOME` directories are probed, all ENOENT); system loader/locale files are read; one `${TMPDIR:-/tmp}` temp file is created and removed".

### F4 — Info/bound (operability): R23-01 does not enforce the fixture's hermetic content

**Counterexample.**
- C5: a fixture-script edit that lists `$HOME` keeps R23-01's exact line.
- `cells` compares only cited stamp paths (`claim-ledger.sh:830-841`), and `corpus/fx-ok.sh` is cited by no fixture cell. RevFixtureStamps and ConnCellsPatterns made the same observation for non-`$HOME` edits.

**Where enforcement actually lives (at HEAD).**
- All five fixture files are pinned in the real `corpus/stamps.tsv:21-25`.
- `python3 corpus/revision-audit.py` re-hashes every current stamp row and reports `STALE` (`corpus/revision-audit.py:373-387`).
- So the hermetic property is guarded by R22-03 (and `verify`), not by R23-01. I did not run R22-03 (parent row).

**Smallest safe correction.**
- Either state the bound "fixture hermeticity is enforced by `corpus/stamps.tsv:21-25` + R22-03, not by R23-01's output",
- or cite `corpus/fx-ok.sh` in one fixture cell. C5d shows that makes the same edit fail inside R23-01. The pin moves to `stamp_pointed=2` and needs an old/new record.

### F5 — Info (observed, corrected before commit): the fixture and production id namespaces are coupled

**Observed.**
- C0: for about 30 s (01:02:31→01:03:02), the live fixture scorecard carried the production id `R23-01` in an HTML comment. R23-01 went **red** (`MISSING-ID SCORECARD.md:1 R23-01`, exit 1).
- It was corrected before `e1884c6`. C6c replays the state byte-exactly.

**Latent rule.**
- Any unlabelled production-id token anywhere in the fixture scorecard breaks R23-01. The reverse direction is ConnCellsPatterns F2 (`R90-01` in a lesson).
- Under F1, that red state would have stayed invisible to R13-03.

**Smallest safe correction.** Add a one-line note in the C3 contract that fixture docs must not carry production ids unless they are labelled (`ID_MARK_RE`, `claim-ledger.sh:641`).

## Confirmations (attacks that failed)

- **No default path is reachable.**
  - All five overrides are given (`claim-ledger.sh:199-203`), so the defaults at `:103-106`, `:240` and `:518-528` are unused.
  - The `--docs` value is a single token without IFS or glob characters, so the unquoted split at `:522` is inert.
  - C2's opened-file list contains no lane file except the gate script and the fixture.
- **No `$HOME` file read in the observed environment.** C2 shows 0 successful non-lane `$HOME` syscalls. C3 shows HOME-independent byte-identical output.
- **No substrate probe from the committed fixture.**
  - `claims.tsv:1-2` notes carry no `[substrate]`, and the `&&` at `claim-ledger.sh:416` short-circuits `substrate_present` (`:140-146`). C2 shows 0 janitor probes.
  - A one-token note edit would make the probe reachable. The outcome would then become host-dependent: absent → `row_deferred=2`, pin fails; present → exact line (C4).
  - That edit is also caught by `corpus/stamps.tsv:22` + R22-03.
- **No network** (C2: 0 socket syscalls).
- **No SKIP-SELF from the committed fixture.** Reaching it needs claims text containing `claim-ledger.sh`. C11 and RevFixtureRun F2 show the exact pin rejects that (`rows_run` drops, `self_skipped` rises).
- **`rows_run=2` vs deferral.**
  - `rows_run` is `C_N` (`claim-ledger.sh:828`), incremented at `:415` *before* DEFER (`:416-419`) and POLICY (`:420-424`). C4 prints `rows_run=2 row_deferred=2` CLEAN with zero executions, so `rows_run` alone is not execution. HEAD's note at `claim-ledger.tsv:59` and lesson `:165-167` already say so (RevFixtureRun F1, confirmed).
  - For the shipped fixture in a clean environment, `rows_run=2 ∧ row_deferred=0 ∧ CLEAN` equals **exactly two real executions**. POLICY cannot co-occur with CLEAN (`:1001-1005`, C7). SKIP-SELF rows are excluded before `C_N` (`:816-821`). strace shows two `timeout` launches with argv equal to `claims.tsv:1-2`, cwd at the fixture root.
  - The residual gap is environmental only (F2).

## Disclosures

- No installs and no network fetches. `strace` was already at `/usr/bin/strace`.
- No lane writes except this report.
- No `verify`, no R13-03, no R22-03, and no host-bound row was executed. C6b ran the real scorecard's `cells` parser with a claims file containing only self-invoking rows, so all of them were SKIP-SELF and zero rows ran.
- Incidental moving-target note: at 01:05:23 the real stamps row for `corpus/claim-ledger.tsv` was stale (`f1a73f09→0d3d7500`) for about 12 s, until `corpus/stamps.tsv` was re-pinned at 01:05:35. This was not pursued further.
