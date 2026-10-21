# RunPinPaths — bounded post-integration path falsification

## Result and axes

**Measured no-change result: no defect found in the assigned path families.** Eight unsafe-path fixture decisions correctly returned cannot-evaluate (`SETUP`, exit **2**); the regular-file control returned `CLEAN`, exit **0**. No case timed out. These are observed decisions, not authored-case counts used as an accuracy proxy.

- **Calibration:** the control distinguishes a functioning audit from blanket rejection. This seat did **not** execute feature-specific vendor/product adjudication and claims no C1 calibration score, outside agreement, or E1/E3 closure.
- **Freshness:** the audit refused symlink traversal and non-regular inputs at both the stamp-table boundary and the pinned-file boundary. No owned outside-root sentinel path appeared in any traced audit/descendant syscall. This establishes the assigned static-fixture read boundary only; it does not establish vendor currentness, live stamp totals, or historical migration correctness.

Proposed correction: **none for these measured cases**. Preserve the evidence; no production implementation was changed or proposed for integration.

## Exact read revision and frozen inputs

The historical BEFORE base is `c2cab35bc92e57e39e5489bac3386db078345b3f`; it was **not** used as the executable input.

Read the measured landing directly with `git show --no-patch --format=fuller 8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (exit 0). Read its tree with `git rev-parse '8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3^{tree}'` (exit 0):

- Landing: `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`
- Tree: `d12afd7a545e86f21eb9acac567d10de774df50f`

The frozen manifest, not a detached HEAD or build-wave report, identifies the actual file inputs. Observed SHA-256 values:

| Input | SHA-256 |
|---|---|
| `.ufo/waves/round-22/integration-manifest.json` | `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911` |
| `corpus/revision-audit.py` | `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977` |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` |

The three implementation/document hashes match the manifest's corresponding entries. The manifest records the audit as 20,857 bytes / 548 newline characters. The source was copied unchanged to `/tmp/kagi-r22-w2-PinPaths/implementation/corpus/revision-audit.py`; setup and every invocation checked its SHA-256 against the frozen value.

Inspected the actual source interface before execution: `--history` requires a full hexadecimal immutable commit ID; `--root` supplies the repository fixture; `--selftest` is a separate mode. Only explicit `--root` + `--history` invocations were used. No default-root audit or stock selftest was run.

## Immutable fixture content and topology

Owned scratch root: `/tmp/kagi-r22-w2-PinPaths` (absent before creation).

Permanent evidence directory: `.ufo/waves/round-22/falsify/PinPaths/`.

`PinPaths/fixture-inputs.json` retains **every fixture file's exact bytes in base64 and its SHA-256**, all directory/FIFO modes, all symlink targets, the copied implementation and frozen manifest bytes, and each case's expected decision and immutable Git history/tree IDs. Its SHA-256 is:

```text
b0725919564318fc21216dfb8898af4da3b997fe483a70d9ba3632975d9dcfe3
```

`PinPaths/fixture-inputs.sha256` retains that digest. Fixture regular files/FIFOs are mode `0444`, directories `0555`, and symlinks are protected by their read-only containing directories. The fixture specification and raw observation files are also read-only.

The regular pin and owned outside-root sentinel contain exactly these 23 bytes:

```python
b'pinpaths-owned-fixture\n'
```

SHA-256: `a8e4348553a4ae70b2facc4332b4f62d553fdabb28832a88325e7f166a9304e5`.

For eight cases the exact stamp bytes are:

```text
corpus/pin.txt\ta8e4348553a4ae70b2facc4332b4f62d553fdabb28832a88325e7f166a9304e5\t1\t23\n
```

For `pin-parent-symlink`, the first field is instead `corpus/linked/pin.txt`; every other byte is identical. Here `\t` and `\n` display literal tab/newline byte positions; the specification retains the actual bytes.

Each fixture has a self-contained synthetic Git object database. The immutable historical tree contains the pin as a regular file and its matching stamp. Current membership remains equal to historical membership, so no dropped/added/stale finding masks the assigned path decision. Git objects were deterministically encoded locally, without invoking `git init`, `git add`, `git commit`, `git commit-tree`, checkout, or any production-index operation.

| Fixture family | Immutable history commit | Immutable history tree |
|---|---|---|
| All except `pin-parent-symlink` | `4708f65767bad3eb40a132667a808fd2385a939a` | `2163792204a8aee09e9d2eb935ca7a0ebd3740fc` |
| `pin-parent-symlink` | `8423b8018eca2cc3787179a207539dacea2d3093` | `3e757563aedf164a1fa031eac5d0ff31f2d642be` |

All symlink targets are owned synthetic payloads under `/tmp/kagi-r22-w2-PinPaths/outside/<case>/`, never account, vault, credential, session, or host-private data. Their bytes match the historical expectations, so following a symlink would not be rescued by an unrelated stale-digest result. Directory cases use actual directories; FIFO cases use actual named pipes with no writers.

## Executed commands and exact observations

Setup, executed once from the project root, exit 0:

```text
/usr/bin/python3 -I -B .ufo/waves/round-22/falsify/PinPaths/setup-fixtures.py
```

The following nine recording-wrapper commands were executed once each in an independent concurrent batch, from the project root. All recording wrappers exited 0; those wrapper statuses mean evidence was recorded, **not** that the audit returned 0.

```text
/usr/bin/python3 -I -B .ufo/waves/round-22/falsify/PinPaths/run-case.py clean-control
/usr/bin/python3 -I -B .ufo/waves/round-22/falsify/PinPaths/run-case.py pin-parent-symlink
/usr/bin/python3 -I -B .ufo/waves/round-22/falsify/PinPaths/run-case.py pin-final-symlink
/usr/bin/python3 -I -B .ufo/waves/round-22/falsify/PinPaths/run-case.py pin-directory
/usr/bin/python3 -I -B .ufo/waves/round-22/falsify/PinPaths/run-case.py pin-fifo
/usr/bin/python3 -I -B .ufo/waves/round-22/falsify/PinPaths/run-case.py stamps-parent-symlink
/usr/bin/python3 -I -B .ufo/waves/round-22/falsify/PinPaths/run-case.py stamps-final-symlink
/usr/bin/python3 -I -B .ufo/waves/round-22/falsify/PinPaths/run-case.py stamps-directory
/usr/bin/python3 -I -B .ufo/waves/round-22/falsify/PinPaths/run-case.py stamps-fifo
```

Each `PinPaths/<case>.json` retains the **exact native audit argv**, exact `strace` argv, cwd, full minimal synthetic environment, timeout, actual exit code, stdout, stderr, elapsed time, and trace digest. Native audit argv consists of `/usr/bin/python3 -I -B`, the absolute copied script path, `--root` with that case's absolute fixture repository root, and `--history` with the immutable fixture commit in the table above. All invocations were traced using `/usr/bin/strace -f -qq -yy -s 256 -o <absolute-case-trace> -- <exact-native-audit-argv>`, with an 8-second bound. No launcher, package manager, health probe, or host-private gate was involved.

Observed audit results:

| Case | Current non-regular path | Exact first output line | Audit exit |
|---|---|---|---:|
| `clean-control` | none | `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=0 invalid=0)` | 0 |
| `pin-parent-symlink` | `corpus/linked` → owned outside directory | `PATH-ESCAPE corpus/linked/pin.txt` | 2 |
| `pin-final-symlink` | `corpus/pin.txt` → owned outside file | `PATH-ESCAPE corpus/pin.txt` | 2 |
| `pin-directory` | `corpus/pin.txt` is a directory | `NOT-FILE corpus/pin.txt` | 2 |
| `pin-fifo` | `corpus/pin.txt` is a FIFO | `NOT-FILE corpus/pin.txt` | 2 |
| `stamps-parent-symlink` | `corpus` → owned outside directory | `PATH-ESCAPE corpus/stamps.tsv` | 2 |
| `stamps-final-symlink` | `corpus/stamps.tsv` → owned outside file | `PATH-ESCAPE corpus/stamps.tsv` | 2 |
| `stamps-directory` | `corpus/stamps.tsv` is a directory | `NOT-FILE corpus/stamps.tsv` | 2 |
| `stamps-fifo` | `corpus/stamps.tsv` is a FIFO | `NOT-FILE corpus/stamps.tsv` | 2 |

The control's one output line ends in a newline. Every unsafe case emits its tabled first line followed by exactly:

```text
REVISION_AUDIT: SETUP (stale=0 missing=0 dropped=0 added=0 invalid=1)
```

Both lines end in a newline. **Stderr is exactly empty for every audit.** Raw bytes are retained separately as `<case>.stdout` and `<case>.stderr`. Every JSON observation has `matches_expected_decision: true`, `timed_out: false`, `outside_fixture_trace_hits: []`, and `no_outside_fixture_path_in_trace: true`.

## Read-boundary evidence

Full child/descendant syscall traces are retained, not merely exit-code assertions. The decisive observed operations are:

- Parent symlinks: `openat(..., "linked"|"corpus", O_RDONLY|O_NOFOLLOW|O_CLOEXEC|O_DIRECTORY)` fails `ENOTDIR`; `newfstatat(..., AT_SYMLINK_NOFOLLOW)` identifies `S_IFLNK`.
- Final symlinks: `openat(..., "pin.txt"|"stamps.tsv", O_RDONLY|O_NONBLOCK|O_NOFOLLOW|O_CLOEXEC)` fails `ELOOP`; non-following stat identifies `S_IFLNK`.
- Directory/FIFO finals: a nonblocking, non-following open is followed by `fstat` showing `S_IFDIR` / `S_IFIFO`; the descriptor is closed without a content read. Neither FIFO invocation hangs.
- Positive tracing control: `clean-control.strace` records successful reads of the 85-byte stamp table and the 23-byte pin. Thus the negative sentinel observation is not based on tracing being disabled.

No line in any complete trace contains `/tmp/kagi-r22-w2-PinPaths/outside/`, including the decoded paths attached to descriptors by `strace -yy`. This supports **no owned outside-root payload access in these executions**. It is not a claim that the process reads literally no files outside its repository: interpreter/system libraries and the explicitly copied script are naturally outside the fixture root. Fixture setup itself deliberately writes and inventories its synthetic outside payloads before tracing begins.

| Retained trace | SHA-256 |
|---|---|
| `clean-control.strace` | `b830b745758bc9c88a60b105e0e101f8e8cb2614318212775919636bc472c675` |
| `pin-parent-symlink.strace` | `fc473622e105e4bf76fbc5ecbb081b637ccb4f7823579677612849226ff25092` |
| `pin-final-symlink.strace` | `1f84230826e24472b280885807862e160402ed0a130973a46b773b8373784a49` |
| `pin-directory.strace` | `1b5bd23788cbce9d5aea1035ef4b56ab74e509a61864b81c224f645f6cec0457` |
| `pin-fifo.strace` | `f857d54e286536248785aebd0648304224fad5fc3973c0245f08fa94ecd881ce` |
| `stamps-parent-symlink.strace` | `3f7c2b0866df3b67f3221c3745b5e01a3a57bab6d5e28f2e2594acc6dc320841` |
| `stamps-final-symlink.strace` | `e37bc47f14defef43c26865290008352f80f5b69d576e3f85e295ac771d8dcc8` |
| `stamps-directory.strace` | `e8e00f92cf949b3a04935ee64de32733665a13e5ef0531ef51370e6d05770813` |
| `stamps-fifo.strace` | `c6aada84a74071270bd63249412e870d349dcaa78c335e0ad2f696777c6e679a` |

Reproduction helpers retained as evidence:

- `setup-fixtures.py`: SHA-256 `66172208715573610e5f216bc95575fb790274d9d302dbd126d8bfcb378e03bc`.
- `run-case.py`: SHA-256 `7a945e9b87f6ee8881395b5619e368cbbc02b1575d5921d150431f29010249da`.

## Limits, risks, blockers, and handoff

- This is a static-fixture, same-device check. No race, bind-mount/cross-device, adversarial Git configuration, or symlinked `--root` scenario is claimed.
- It does not run or substitute for historical migration audits, source-consumption gates, feature-claim adjudication, or a complete integration gate.
- No implementation edits, production document/data edits, live Git/JJ state/index changes, model changes, service actions, credential operations, or external-state remediation were performed. Only this report, its exclusive evidence directory, and the assigned private scratch area were written.
- No installations or updates. Observed native tools: Python **3.14.8**, Git **2.56.0**, strace **7.2**. No builds, linters, formatters, stock selftests, or host-private gates were run.
- Blockers: **none**. Scoped implementation correction: **none warranted by the observations**.
- Parent handoff: consume the exact per-case argv/output/exit and immutable fixture specification; retain the distinction between audit exit 2 and recording-wrapper exit 0. If a later implementation changes these paths, the parent should rerun these scoped fixtures in a fresh owned directory after integration. Full-tree gates remain the parent's responsibility; this seat ran only its explicitly authorized local fixture executions.

Files created in the checkout: `.ufo/waves/round-22/falsify/RunPinPaths.md`; under `.ufo/waves/round-22/falsify/PinPaths/`, `setup-fixtures.py`, `run-case.py`, `fixture-inputs.json`, `fixture-inputs.sha256`, and each of the nine case names' `.json`, `.stdout`, `.stderr`, `.strace` files. **No production files changed.**

Report: .ufo/waves/round-22/falsify/RunPinPaths.md
