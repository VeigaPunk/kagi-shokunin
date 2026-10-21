# Round 24 — host surface classification (static)

## Method and classification rule

- **Observed:** searched before reading the four implementations and their ledger callers; used only static `grep`/`read`/directory inspection. No script mode, host gate, `op`, network command, or check was executed. No test result is asserted (exit code: N/A; not run).
- **Observed:** the requested `lsp` device is unavailable here: `read xd://lsp` returned “No such tool”; only literal search plus source reading was available, not semantic LSP proof.
- **Rule:** HOST means the effective read target is a host-private surface (e.g. `$HOME` config, transcript, external host tree); HOST-FREE means reads stay in this checkout or an isolated scratch/fixture tree. An arbitrary `--root`/working directory is therefore conditional, not safe merely because its script name is known.
- **Tooling:** no tool installed or updated.

## CLI modes and read surfaces

### `corpus/sources-census.sh`

- **`bash corpus/sources-census.sh` / `bash corpus/sources-census.sh verify` — HOST-FREE in this checkout.** `verify` is the default and `ROOT` defaults to the script's parent repository (122–135). Reads `corpus/SOURCES.md` (163–175, 180–210, 234, 243–251, 331), optional `corpus/source-fetches.tsv` (237–288) and `corpus/inrow-pins.tsv` (295–315), each `corpus/knowledge/*.md` (335–358), and in-shape `used-by` corpus files (215–231). It validates URL strings; it does not fetch them (247–251). No HOME/config/transcript/socket/op/Janitor access is in the verify path.
- **`verify --root DIR` (or `--root DIR` alone) — conditional.** Same reads under `DIR` (160–165 onward): HOST if `DIR` points at host-private data; HOST-FREE when it is the checkout or an isolated repo-shaped fixture. The script accepts the root without confinement (131, 161–165), so the flag itself cannot be allowlisted without checking the effective root.
- **`--selftest` — HOST-FREE.** It builds its base/case trees under `mktemp` (556–559, fixture contents 374–425), passes only those fixtures as roots (641–648), and removes the temp tree (371–372). `--root` is accepted but unused when selftest is the final selected mode. `verify` and `--selftest` are parsed in order, with the last mode token selecting the branch (127–135, 672–675).
- **`-h` / `--help` — HOST-FREE.** It prints the script header through `sed` from `SELF` (122–123, 132); no corpus check runs.
- **Other/invalid arguments — setup error, no verify scan.** Unknown arguments exit through `setup` (120, 127–134). A preceding `--root` is not used unless verify is selected.

### `corpus/feature-claims.py`

- **Bare `-h` / `--help` — HOST-FREE;** help is rejected if combined with any parsed option (1007–1008), and otherwise prints literal help (1018–1021) without resolving a root or reading an artifact (1024–1031).
- **Normal evaluation:** `--phase before|after|boundary` (or no phase, default `after`), optionally `--claims PATH`, optionally `--input PATH`; `--claims` may accompany `--input`, while an explicit `--phase` and `--input` cannot (960–1015). With no `--root`, root is the repository containing the script (214–225); the default artifact is `corpus/feature-claims.json` (23–24, 228–247). Evaluation reads that claims artifact, and also the selected input when `--input` is given (1032–1043). **HOST-FREE** for the default checkout root; **HOST** if `--root` selects a host-private tree. Claims/input are confined beneath that root, reject traversal/backslashes and open regular files without following symlinks (228–281).
- **`--selftest [--root DIR] [--phase after]` — conditional on root.** Selftest first reads the default feature-claims artifact under its selected root (884–890), then makes temp fixtures and re-invokes the script on those fixtures (893–954). It rejects `--claims`, `--input`, or any non-`after` phase; explicit `--phase after` is accepted because `after` is the default (1011–1014). Repo default is HOST-FREE; an explicit host root makes the seed-artifact read HOST. `--help` with other options is invalid.

### `corpus/revision-audit.py`

- **`--history FULL_OID [--root DIR]` — conditional on root.** With no root, it selects the repository containing the script (326–338). It reads the repository's `corpus/stamps.tsv` and the paths named by that file (343–394, safe open/fingerprint at 143–235), plus the selected commit's tree/blob through `git ls-tree`, `cat-file`, and `rev-parse` (240–279). Root-file paths reject absolute/traversal/admin paths, symlinks, cross-device directories and hardlinks (67–82, 143–203). Git's system/global config and lazy fetch are disabled (39–47); this code requests no network fetch. **HOST-FREE** for this checkout; **HOST** if explicit `--root` is a host repository.
- **`--selftest` — HOST-FREE.** It creates isolated temp Git repositories/files and audits only those fixtures (423–582); `--root` with selftest is rejected before the selftest (593–597). `--history` and `--selftest` are mutually exclusive; `--root` alone/no mode produces `HISTORY-INVALID`, and malformed history IDs are rejected before root access (586–604, 326–328).
- **`-h` / `--help` — HOST-FREE** (argparse help; no audit target is opened). No HOME/config/transcript/op/Janitor access is declared. The checked-in stamp list includes repo artifacts named `corpus/knowledge/transcript-hygiene.md` and `corpus/transcript-scan.sh` (current `corpus/stamps.tsv:49,79`); these are in-tree documentation/code, not host session transcripts. No `.git/objects/info/alternates` file was present in the checkout's listed objects/info directory; other repositories supplied via `--root` are not covered by that observation.

### `corpus/closure-dispositions.py`

- **Default verify (`python3 corpus/closure-dispositions.py`) — HOST-FREE for the ledger's repository working directory.** Root defaults to `.` and input defaults are `corpus/lessons/round-22-verifier-spotcheck.md` plus `corpus/closure-dispositions.json` (60–61, 377–380). It reads the source, computes its digest, loads dispositions, and reads each resolved pointer under root (74–75, 106–160, 171–204). Current pointer values are repo files: `corpus/SOURCES.md`, two knowledge pages, `corpus/lessons/round-23.md`, `corpus/source-fetches.tsv`, and the hermetic SCORECARD (dispositions JSON lines 3–4, 11, 32, 39, 46, 53–109). **HOST** if effective root/current working directory is a host-private tree.
- **`--root DIR` with optional `--source REL` / `--dispositions REL` — conditional.** The source and disposition names reject absolute paths and `..` (386–404); pointers additionally check resolved containment beneath root (106–129). Host root means HOST; repo/fixture root means HOST-FREE. **Static limitation:** source and dispositions are opened by joined paths without the resolved-containment check used for pointers (147–162, 132–144); a symlink in those paths could escape a repo root. The default checkout invocation is repo-only by its named targets, but the code does not prove symlink confinement for these two files.
- **`--selftest` — HOST-FREE.** It uses a temporary root and fixture paths (274–374). Accepted `--root`, `--source`, and `--dispositions` values are ignored by the selftest branch (415–424); malformed absolute/escaping source/disposition arguments still fail during parsing (377–412).
- **`-h` / `--help` — HOST-FREE.** It prints the embedded docstring and does not open input files (415–424). Valid extra flags are parsed first but ignored once help is selected. The docstring expressly says the check does not reach the network (41–47).

## Ledger call mapping and note tags

All listed current calls are HOST-FREE in their ledger/repository context; none has a `[substrate]` note tag:

| Row | Exact command (claim-ledger.tsv) | Class | Current tag |
|---|---|---|---|
| R21-02 (`claim-ledger.tsv:52`) | `bash corpus/sources-census.sh` | HOST-FREE; default repo verify | none |
| R21-03 (`:53`) | `bash corpus/sources-census.sh --selftest` | HOST-FREE; scratch fixtures | none |
| R22-01 (`:55`) | `python3 corpus/feature-claims.py --phase after` | HOST-FREE; default repo artifact | none |
| R22-02 (`:56`) | `python3 corpus/feature-claims.py --selftest` | HOST-FREE; reads repo seed artifact then temp tests | none |
| R22-03 (`:57`) | `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` | HOST-FREE; script repository default | none |
| R22-04 (`:58`) | `python3 corpus/revision-audit.py --selftest` | HOST-FREE; temp Git fixtures | none |
| R23-02 (`:60`) | `python3 corpus/closure-dispositions.py` | HOST-FREE; repo CWD/default paths | none |

A script-name-only HOST refusal would wrongly skip **all seven** of those HOST-FREE rows; in particular it would block each script's fixture selftest as well as the repo-only normal check. Rows are located at `corpus/claim-ledger.tsv:52–58,60`.

**Known-row discrepancy:** R18-01 is indeed a HOST row per its current note, but the current `corpus/claim-ledger.tsv:48` ends with `[host]` and states it is HOST-SKIPped. Therefore it is **not currently untagged**; this differs from the assignment's “R18-01 is known” parenthetical if that meant the current file. No untagged HOST row was found among the seven target-script invocations.

## Proposed exact HOST-FREE allowlist for `sources-census.sh`

Allow only these forms without a host tag:

1. `bash corpus/sources-census.sh` (implicit repo-root verify).
2. `bash corpus/sources-census.sh verify` (same mode/root).
3. `bash corpus/sources-census.sh --selftest` (fixture-only; no `--root` needed).
4. `bash corpus/sources-census.sh -h` or `--help` (header-only).
5. `bash corpus/sources-census.sh verify --root DIR` **only after** `DIR` is canonicalized and proven to be the lane checkout or an approved scratch/fixture root; otherwise classify HOST / refuse by root policy. Do not treat an arbitrary absolute `--root` as safe.

Keep the mode decision argument-aware: `--root` is material for verify, but ignored for selftest/help; the parser's last mode token wins. In the present ledger, only forms 1 and 3 are called.

## Confidence and remaining unknowns

- **High confidence:** source-level option behavior and named read families above; current ledger commands/notes; no host modes were executed.
- **Unresolved:** external roots can make the conditional modes HOST; closure source/dispositions symlink escape is not blocked in code; LSP semantic results were unavailable. No dynamic tree or host state was probed to decide those conditional cases.
