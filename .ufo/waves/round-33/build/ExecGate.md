# ExecGate — C1 capability: `corpus/prefreeze-control.sh` (round 33 build)

Seat: ExecGate (leaf executor). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Frozen BASE: `76f4eeae7aa9af4dbb9423f5632b55791824253a`. Contract read first:
`/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-33.md` §C1 (commit `880824b`,
`round-33: plan + frozen claims`).

Frozen predicate, as implemented (identical sentence in the script header, the plan and
these receipt labels):

> PREFREEZE: CLEAN (controls=N mismatch=0) — every declared BASE value equals the value its
> own counting command measures on the extracted BASE tree.

## Deliverable

| path | sha256 | lines | mode |
|---|---|---|---|
| `.ufo/waves/round-33/build/prefreeze-control.sh` | `c265a5d82a8b3b0dc588ba3c9e5b5cd887de092127be36835584ee7f8b381e59` | 256 | 755 |

Built and measured in scratch (`/fast/scratch/hyaku/kagi-r33/ExecGate/`), then copied byte for
byte. The L1 installs it at `corpus/prefreeze-control.sh`; no lane-tracked file was written by
this seat. Each receipt records the scratch invocation path (removed at exit, per the scratch
rule) and the `script_sha256` of the bytes that ran; the delivered copy carries the same digest,
so substituting the installed `corpus/prefreeze-control.sh` re-runs the identical gate.

Interface (frozen, implemented as written):

```
prefreeze-control.sh [run] --base <rev> --controls <tsv> [--work <dir>] [--timeout <s>]
prefreeze-control.sh --selftest
```

- Controls row `id<TAB>expect<TAB>command`; blank lines and `#` lines skipped; exactly two TABs
  or `PREFREEZE: SETUP malformed-controls` exit 2; `expect` must be an integer (also
  `malformed-controls`); empty row set → `SETUP empty-controls`; missing/unreadable file →
  `SETUP missing-controls`.
- Extraction: `git -C <repo> archive <rev> | tar -x -C <tree>` into a single `mktemp -d` under
  `${TMPDIR:-/tmp}` or `--work`, removed by the EXIT trap. `BASE=<tree>` and `LANE=<repo>` are
  exported; every command runs through `bash -c` with cwd = the tree, under
  `timeout <s> bash -c` (default 300).
- Measurement: final run of digits on the LAST non-empty stdout line; no integer → `NORESULT`
  (SETUP, never a pass); row timeout → `NORESULT` naming the timeout; exit codes deliberately
  ignored (`grep -c` exits 1 while printing 0 = measured 0). Per-row stderr only when
  non-empty, at `<extraction>/stderr/<id>.stderr`, removed with the scratch tree.
- Verdict: `CLEAN` 0 / `MISMATCH` 1 / `SETUP <reason>` 2; exit codes 0/1/2 only.
- Lane root: derived from the script's own location (`dirname $0/..`, the script ships at
  `<lane>/corpus/`), so a committed copy measures its own lane and the canonical install
  derives exactly `/home/vgpnk/Projects/shokunin/kagi-shokunin`. `PREFREEZE_REPO` is the only
  override (the selftest sets it to its fixture repo; my scratch runs set it to the lane, which
  is recorded as `env=` in every receipt so the exported `LANE` is provably the frozen value).

## Evidence — the three counting commands (measured once each, on the delivered bytes)

| receipt | command | verdict (exact) | exit |
|---|---|---|---|
| `.ufo/waves/round-33/build/prefreeze-33.txt` | `run --base 76f4eea… --controls plans/round-33.controls.tsv` | `PREFREEZE: CLEAN (controls=4 mismatch=0)` | 0 |
| `.ufo/waves/round-33/build/prefreeze-32.txt` | `run --base 32c35fe… --controls plans/round-32.controls.tsv` | `PREFREEZE: MISMATCH (controls=2 mismatch=2)` | 1 |
| `.ufo/waves/round-33/build/prefreeze-selftest.txt` | `--selftest` | `PREFREEZE_SELFTEST: PASS (10 cases)` | 0 |

Round-33 rows (all four agree with the L1's committed `controls/base-values.txt`):

```
OK nist_entries expect=0 measured=0
OK registry_rows expect=72 measured=72
OK prefreeze_artifact expect=0 measured=0
OK frontier_nist expect=1 measured=1
```

Round-32 red witness — the M32-2 replay, the fix shown able to fail:

```
MISMATCH sd5 expect=3 measured=1
MISMATCH total expect=10 measured=8
```

`total` came from `sed -n 's/.*n=\([0-9][0-9]*\).*/\1/p'` over the sweep's
`SELF_DESCRIPTION: MISMATCH n=8 (SD1=2 SD2=2 SD3=0 SD4=1 SD5=1 SD6=2)`; `sd5` from
`grep -o 'SD5=[0-9]*'` → 1. Wall time ≈ 195 s (two sweep invocations), as the plan predicted.
An independent hand probe of the same revision printed the same `n=8` / `SD5=1`.

Selftest cases (fixture repo: `git init` in `$TMPDIR`, `rev-parse --show-toplevel` asserted
equal to the fixture BEFORE the single commit, user.name/email passed with `-c` only):

1. equal values → CLEAN, exit 0;
2. one differing value → MISMATCH, exit 1, names `lines expect=4 measured=3`;
3. two differing values → `mismatch=2`;
4. command printing no integer (`echo no-digits-here`) → SETUP `noresult`, exit 2;
5. row without three TAB fields → SETUP `malformed-controls`, exit 2;
6. missing controls file → SETUP `missing-controls`, exit 2;
7. `grep -c` printing 0 and exiting 1 → measured 0, CLEAN, exit 0;
8. controls file with only comments/blank lines → SETUP `empty-controls`, exit 2;
9. unknown revision → SETUP `bad-rev`, exit 2;
10. `sleep 5; echo 0` under `--timeout 1` → `NORESULT slow expect=0 (timeout 1s)`, SETUP
    `timeout`, exit 2.

`--work` honoured (run-mode probe, not one of the three named receipts):
`run --base 76f4eea… --controls plans/round-33.controls.tsv --work <scratch>/wprobe` →
`PREFREEZE: CLEAN (controls=4 mismatch=0)` exit 0, and the work dir was empty afterwards
(the trap removed the extraction and the stderr dir). Both scratch `TMPDIR` roots were empty
after all runs: no prefreeze directory is left on the host.

## L1 review (KagiR33) — three must-fix items, all applied

1. **Portability**: hardcoded lane root replaced by derivation from the script's own location;
   `PREFREEZE_REPO` kept as the override, selftest fixture path unchanged.
2. **Fail-closed count bound**: header "Named ceiling" now states that measurement is the FINAL
   digit run of the last non-empty line, so a command whose final number is not the counted
   value is misread, and that the rule is deliberately not widened (a wider match would accept
   prose and version tokens). The extractor itself is unchanged.
3. **No host residue**: receipt dir moved under the extracted tree
   (`<extraction>/stderr/<id>.stderr`), inside the one `mktemp` tree the trap removes.

## Bounds and residuals

- **Named ceiling (declared in the header)**: numeric counters only; the gate cannot judge
  whether the declared predicate is the right one, and a command that prints the expected
  number for the wrong reason still passes. That class is a review matter on the frozen
  controls file, not something the gate can falsify.
- **Final-digit misread**: a multi-number trailing line (`wc -l a b` → `2 b`, `5 total`) is read
  as its last number. Deliberate; the frozen controls all end on the counted value.
- **Background child holding stdout**: `timeout` signals only the direct `bash -c` child, so a
  command that backgrounds a process inheriting stdout can keep the capture pipe open past the
  row timeout (a hang, never a false pass). Not exercised by either frozen controls file; not
  hardened, because changing the capture path after review would have re-cut the measured bytes
  for a class no control row uses. Recorded as the one residual I could not make fail.
- **Controls file is trusted input**: it is frozen and committed before data (`plans/*.controls.tsv`),
  so the gate binds declared values to measured ones; it cannot detect a hand-edited file.

## Cases I could not make fail

- A trivially true command (`echo 72`) passes: the gate has no access to intent.
- A command whose output is numeric but not the counter (last-number misread above) passes.
- A background grandchild that inherits stdout can outlive the row timeout (hang, not a pass).
- Author-inaccessible-file targets (the R32-2 counter half): the gate can only measure files it
  can extract; a target that counts an author-inaccessible file is a plan defect it cannot see.

## Artifact integrity (read this before committing)

```
6e7a3768470ea3bf9f7c3e139096f71335ee4fbb9ae906fc2e1bc82a2c330950  prefreeze-32.txt
92707c64d36959fd0c2596984461b3237edd2313b7283bfdc1f5603f7ed0af60  prefreeze-33.txt
8e8f2a8c6cb3536b5646bea13a20d286141fa54ec57eb7cc3ce04e4a2d5e458c  prefreeze-selftest.txt
c265a5d82a8b3b0dc588ba3c9e5b5cd887de092127be36835584ee7f8b381e59  prefreeze-control.sh
```

`prefreeze-32.txt` was written twice by something outside this seat, and both times restored
to the measured bytes (the digests above are the bytes that were produced by the run and
`cmp`-verified against the measured scratch copy before it was removed):

1. first landing: the first 32 bytes were replaced by `MISMATCH sd5 expect=3 measured=1` with
   the header shifted (not truncated) — a write at offset 0 of a file whose header began at
   offset 0, not an append;
2. at 10:36:37, one extra `exit=1` was appended to the verified file.

Both events post-date the measurement and neither came from a command of this seat (this seat
only read the file after the run). The wave does hold sibling copies of the gate
(`build/assimilation/validate/corpus/prefreeze-control.sh`, `build/mut/` with
`MutGate` patches/replicas), so a sibling tool that replays the receipt command and appends
`exit=` is the plausible writer. Treat this as a live collision on the shared `build/` dir,
not as a measurement doubt: the verdict lines and per-row values come from the single run,
and the digest above pins them.

The L1 should `sha256sum` the four files immediately before committing and compare with the
block above. If `prefreeze-32.txt` differs, re-run the named command (≈195 s; ≈1 s for round 33
and the selftest) rather than trusting an edited receipt. Other files in this directory are
sibling seats' and were not touched by this seat.

## Scope, contact, tooling

- No lane-tracked file written; no `git add/commit/checkout/reset/...`; read-only git only
  (`show`, `log`, `rev-parse`, `archive`). Fixture repo committed only inside the selftest
  scratch tree, after the toplevel assertion.
- No vault contact: `op` was not invoked at all (handler absent, as expected); no `op.env`,
  `~/.config/the-janitor` or reference value was read or printed.
- No network use (C1 needs none; the NIST URLs were other seats' scope).
- No tool installs or upgrades — nothing was needed, so nothing is recorded.
- No sub-spawns, no other lane or fleet-root writes.
- Per contract I ran only the measurement commands above: no shellcheck, lint, build or
  full-suite run. Shell discipline is by eye: `set -u`, every expansion quoted, no `eval`, no
  hardcoded `/tmp` (honours `TMPDIR` and `--work`), `mktemp -d` + trap for every scratch tree,
  exit codes 0/1/2 only.
- Scratch `/fast/scratch/hyaku/kagi-r33/ExecGate/` removed before yield.
