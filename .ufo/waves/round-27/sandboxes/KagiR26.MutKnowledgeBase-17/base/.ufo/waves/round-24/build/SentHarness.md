# Round-24 host-tripwire safety review

**Verdict: do not treat `HOST_TRIPWIRE: ... total=0` alone as proof of a hermetic or successful measurement.** Static code review only; no commands or gates were run. The isolated ledger invocation is materially safer than the real-tree gate, but the harness has caller-controlled path traversal and a live external `op` execution; one reachable repo scanner also follows candidate-controlled symlinks.

## Confirmed isolation and row reachability

- `host-tripwire.sh:27` recreates `$base` and makes `$base/home`; the ledger runs in the clone at `:28-29`. Each ledger process is started with `env -i`, setting only inherited `PATH`, scratch `HOME`, `LANG`, `TRIPWIRE_LOG`, and `KAGI_SUBSTRATE` (`:52-54`). The four modes are `verify`/`cells` × absent/present (`:48-54`).
- Six row scripts are replaced by log-only stubs (`:31-34`): `surface-census.sh`, `drift-pins.sh`, `transcript-scan.sh`, `op-ref-probe.sh`, `checklist-run.sh`, and `scope-gate.sh`. This also intercepts their selftest/list/fixture modes, not just their host-reading modes.
- `claim-ledger.sh` itself is deliberately not stubbed: it is the gate under test. Its own substrate probe reads `$HOME/.local/bin/the-janitor` only when `KAGI_SUBSTRATE` is unset (`corpus/claim-ledger.sh:156-161`); the harness always sets it. The gate checks command policy before host-row handling, skips tagged rows without `--allow-host-rows`, and refuses untagged host invocations (`:504-522`; host script/host-free mode declarations at `:168-220`). The harness supplies no `--allow-host-rows`.
- On the frozen ledger, bare tagged host modes (including R11-04, R11-06, R12-01, R15-01, R16-01/03, R17-01) are skipped before their scripts run; R18-01 is untagged but its bare `drift-pins.sh` invocation is POLICY-refused. R13-03's real-root `claim-ledger.sh cells` is also POLICY-refused; R23-01 uses the committed fixture-root cells mode. R21-02/03 (`sources-census.sh`) and R22-03/04 (`revision-audit.py`) are not stubbed, but their reviewed code is repo/fixture-local and has no network call.
- Specifically, `sources-census.sh --selftest` creates/mutates only a `mktemp` fixture and invokes itself on that fixture (`corpus/sources-census.sh:325-380,488-586`); its verifier reads `SOURCES.md` and `corpus/knowledge` below its selected root (`:150-221`). Its example URLs are data, not fetches. `revision-audit.py` calls local `git -C root` operations, strips inherited `GIT_*`, disables system/global config and lazy fetch (`:39-64`), and its selftest commits only a temporary fixture with hooks disabled (`:443-469`). The reachable feature/closure Python rows likewise use local rooted data; feature selftest subprocesses itself on a temp fixture (`feature-claims.py:867-897`), and closure pointer resolution checks root containment (`closure-dispositions.py:106-129`).
- R23-01 nested cells points at `corpus/fixtures/cells-hermetic`; its only fixture claims are `bash corpus/fx-ok.sh` and a local `grep` (`corpus/claim-ledger.tsv:59`, `corpus/fixtures/cells-hermetic/claims.tsv:1-2`). Transcript `--selftest` is stubbed, not exercised by this harness (`host-tripwire.sh:31-34`).

## Findings

### HIGH — scratch boundary is bypassable by harness arguments

**Exploit path:** an unvalidated `LABEL` containing parent components escapes the fixed scratch prefix before `rm -rf`; the subsequent `mkdir` and clone use the same escaped base. Optional `SRC`/`FILE` overlays are also unconfined: `cp "$src/$f" "$base/tree/$f"` can read an arbitrary source path and a traversal destination can overwrite outside the clone. Evidence: `host-tripwire.sh:23-30` (`label`, `src`, `f` are used without validation; destructive `rm -rf` at `:27`).

**Impact:** a caller-supplied label can make this supposedly scratch-only tool recursively delete an unrelated host directory; overlay arguments can read private host files or write outside scratch. This breaks the lane's explicit scratch-only guarantee independently of the ledger rows.

**Smallest remediation:** constrain `LABEL` to a single safe basename (reject `.`/`..`), canonicalize and assert `$base` remains under the fixed tripwire root before any deletion, and validate overlay source/destination paths (source beneath the intended candidate tree; destination relative, canonicalized, and beneath `$base/tree`).

### MEDIUM — R21-01 invokes real `op`; network absence is not established by the harness

**Exploit path/evidence:** R21-01 is reachable from both `verify` (all rows) and `cells` (SCORECARD cites it: `SCORECARD.md:454,641,645`). It is not among the effective host-skip rows: `host_free_args` explicitly allows `op-ref-probe.sh --dotenv-bytes` (`corpus/claim-ledger.sh:178-179`). The byte mode resolves the real `op` from `PATH` (`corpus/op-ref-probe.sh:69,519-526`) and runs it six times (`:532-544`). Its child environment is cleared and HOME/XDG are scratch (`:258-262`); it generates plain-value files (`:535-541`) and supplies no reference URI, account selector, handler, or inherited account token. Thus code shows no deliberate account access or private-file input, but it does **not** prove the external `op` executable cannot contact a service or consult OS-level state. The harness preserves ambient `PATH` (`host-tripwire.sh:52`), and this live row repeats across the four harness runs.

**Impact:** L1 cannot certify the requested “no network” property from this script/code path alone; a PATH-resolved executable can have capabilities beyond the inspected shell code. The `op` probe may also make the whole verifier non-hermetic even though it is not a counted host-row script.

**Smallest remediation:** run this metric in a network-denied sandbox, or replace/disable the `op` executable for this harness run and explicitly treat R21-01 as unmeasured (do not present that as a successful byte probe). No network attempt was observed; this is an unresolved capability boundary, not a claim that network traffic occurred.

### MEDIUM — a `total=0` can be emitted for failed/incomplete gate runs

**Exploit path/evidence:** the harness captures each ledger exit code but always counts the log and prints `HOST_TRIPWIRE` (`host-tripwire.sh:51-62`). `count()` accepts only exact strings from a fixed allowlist (`:35-45`); a newly changed/aliased invocation can be logged by a stub but omitted from the count. The final aggregate does not gate on exit status or unexpected log records.

**Impact:** early setup/policy failure, or an invocation with changed arguments, can leave a plausible zero while the metric itself is invalid or under-counted. Per-run `exit`/`last` fields expose some failures, but the unconditional final number is not a pass/fail assertion.

**Smallest remediation:** reject unexpected stub log entries and make the aggregate explicitly invalid unless each run has an accepted terminal verdict/exit; count every invocation of the stubbed population (or bind counts to row IDs), not only exact spellings.

### MEDIUM — a source-census row can follow an escaping symlink in candidate data

**Exploit path/evidence:** R21-02 and R21-03 are not stubbed. In `sources-census.sh`, a used-by path is shape-checked as `corpus/knowledge|lessons/...`, then the code tests `-e`/`-f` and opens it with `src_field`, without rejecting a symlink or checking canonical containment (`corpus/sources-census.sh:205-221`). A candidate tree containing a symlink at such a path can therefore make the real `sources-census.sh` row read outside the clone. Current registry entries name repo-local files (`corpus/SOURCES.md:7-32`); no such escape was observed in the inspected current entries, but the implementation does not enforce it for candidate trees.

**Impact:** the “repo-local reads only” guarantee is conditional on the cloned/overlaid tree having no hostile symlink at an accepted used-by path.

**Smallest remediation:** open/resolve used-by files without following symlinks and require the resolved path to remain under the canonical `ROOT` (or reject symlinked components before `src_field`).

## Residual host reads / final assessment

- **Direct harness read:** `host-tripwire.sh:25,28` reads the lane repository to clone it; that is expected source-repo access, not a host-private surface. `:30` is a caller-controlled residual read as noted above.
- **Rows:** no explicit host-private file path, account reference, or network client is used by the reachable non-stubbed row code as configured. Exception to a categorical “no network” certification is the live `op` executable in R21-01; exception to a categorical “no external file read” guarantee is the symlink-following source-census path if candidate data is hostile.
- **Do not trust the aggregate alone:** inspect each run's exit/last line and the complete stub log; even that does not eliminate the argument-boundary or live-`op` risks. No tests/builds or live gates were run.