# RunPinMalformed — bounded integrated revision-parser falsification

## Axes and result

- **Calibration (C1):** no feature/source/status/eligibility/product decision was exercised by this seat; no C1 improvement or overall accuracy claim follows.
- **Freshness (C2):** challenged the integrated revision audit's refusal of malformed current stamp tables, duplicate path identifiers, and a malformed row following a valid prefix.
- **Observed result:** each of the three assigned attacks returned **exit 2 / SETUP**, with the expected specific diagnostic. The valid control returned **exit 0 / CLEAN**. No defect was found in these bounded cases; no implementation correction is proposed.

This measures executed refusal/control decisions, not authored fixture counts. It does not establish live-corpus freshness, source currentness, historical migration correctness, or a legacy-header/depth claim.

## Exact read revision and frozen input provenance

The observed `refs/heads/master` and explicitly resolved integration commit were both:

`8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`

The commit's observed Git tree object was:

`d12afd7a545e86f21eb9acac567d10de774df50f`

The historical BEFORE base `c2cab35bc92e57e39e5489bac3386db078345b3f` was **not** the falsification input. Actual working-file hashes were measured and matched the frozen manifest's entries for the implementation and required round documents:

| input | observed SHA-256 |
|---|---|
| `.ufo/waves/round-22/integration-manifest.json` | `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911` |
| `corpus/revision-audit.py` | `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977` |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` |

The manifest records the audit implementation as 20,857 bytes / 548 newline characters. The copied implementation at `/tmp/kagi-r22-w2-PinMalformed/corpus/revision-audit.py` independently produced the same SHA-256. Each fixture runner also pinned that copied implementation hash before execution. No earlier build report was used as authority for its bytes.

Read interface: `corpus/revision-audit.py:525-544` accepts mutually exclusive `--history` and `--selftest`, plus `--root`; ordinary audit execution needs a full history commit ID. All executions below supplied an explicit owned fixture root and full synthetic history ID. No default/live-tree audit or built-in selftest was run.

## Owned fixture construction and immutable content

Scratch root: `/tmp/kagi-r22-w2-PinMalformed`.
Retained evidence root: `.ufo/waves/round-22/falsify/PinMalformed`.

Each case used a separate local Git repository under the scratch root. The runner created only synthetic fixture Git objects using `init`, `hash-object`, `mktree`, and `commit-tree`; it did not stage files, update production refs/indexes, or create a production commit. Every setup argv, stdin bytes, stdout, stderr and exit status is retained in that case's result JSON.

All four fixture histories have the same observed synthetic identities:

- History commit: `f4dc520c064d997b51949c919e27636b1084ba6a`.
- History tree: `1c4e992b2b66909821f0f80b1b69cc01741c2f83`.
- History contains exactly `corpus/keep.txt` and its valid `corpus/stamps.tsv`.

The following Python byte notation specifies every input byte, including tabs and terminal newlines:

```python
K = b"keep\n"
R = b"corpus/keep.txt\tf660a7996deacfbc7560e4240054a8ad82eb02fe25a95064257e07084bcacb85\t1\t5\n"

# Retained history payload and stamps:
history_keep = K
history_stamps = R

# Each current worktree has corpus/keep.txt == K:
clean_control_stamps = R
malformed_tsv_stamps = b"corpus/keep.txt\tf660a7996deacfbc7560e4240054a8ad82eb02fe25a95064257e07084bcacb85\t1\n"
duplicate_ids_stamps = R + R
malformed_after_valid_prefix_stamps = R + b"malformed\n"
```

Files are retained below `PinMalformed/fixtures/`. Input files and captured result JSON files were set read-only (mode 0444); their content is additionally pinned by SHA-256 and included verbatim as UTF-8 and base64 in the result records. This is retained digest-addressed evidence, not a claim of filesystem-enforced immutability against a privileged writer.

| relative to `PinMalformed/fixtures/` | bytes | newlines | SHA-256 |
|---|---:|---:|---|
| `history/corpus/keep.txt` | 5 | 1 | `f660a7996deacfbc7560e4240054a8ad82eb02fe25a95064257e07084bcacb85` |
| `history/corpus/stamps.tsv` | 85 | 1 | `5e93a41e562f795afa3858452b0b881d6341d6f33bc0593d2c8afa9c0efc552c` |
| `clean-control/corpus/stamps.tsv` | 85 | 1 | `5e93a41e562f795afa3858452b0b881d6341d6f33bc0593d2c8afa9c0efc552c` |
| `malformed-tsv/corpus/stamps.tsv` | 83 | 1 | `43d1665b1c2d3e36b8fa030422841ba052942b2c1646eae1ed2259ea0b694d3d` |
| `duplicate-ids/corpus/stamps.tsv` | 170 | 2 | `baeb8af121c8cce12a7d46b1108b1ca4604f3bb89b9e1681e27d00eecc30ac50` |
| `malformed-after-valid-prefix/corpus/stamps.tsv` | 95 | 2 | `c2b285467d961acab6f96946ea2b3eefd9d201de51fc7b6c9f5c4c78fbbd74d1` |

## Exact executed audit argv, output and exit

The four owned fixture executions ran concurrently after the implementation copy and retained inputs were ready. Each command's cwd was its explicit `--root` directory. Stdin was empty. **Stderr was empty in all four cases.** The exit codes here are the audit subprocess's actual return codes, not the evidence runner's verdict.

### Valid control

```text
/usr/bin/python3 -I -B /tmp/kagi-r22-w2-PinMalformed/corpus/revision-audit.py --root /tmp/kagi-r22-w2-PinMalformed/fixtures/clean-control --history f4dc520c064d997b51949c919e27636b1084ba6a
```

Stdout, including its final newline:

```text
REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=0 invalid=0)
```

Expected exit **0**; observed exit **0**.

### Malformed TSV — three fields instead of four

```text
/usr/bin/python3 -I -B /tmp/kagi-r22-w2-PinMalformed/corpus/revision-audit.py --root /tmp/kagi-r22-w2-PinMalformed/fixtures/malformed-tsv --history f4dc520c064d997b51949c919e27636b1084ba6a
```

Stdout, including its final newline:

```text
MALFORMED-LINE 1
REVISION_AUDIT: SETUP (stale=0 missing=0 dropped=0 added=0 invalid=1)
```

Expected exit **2**; observed exit **2**.

### Duplicate path identifiers

```text
/usr/bin/python3 -I -B /tmp/kagi-r22-w2-PinMalformed/corpus/revision-audit.py --root /tmp/kagi-r22-w2-PinMalformed/fixtures/duplicate-ids --history f4dc520c064d997b51949c919e27636b1084ba6a
```

Stdout, including its final newline:

```text
DUPLICATE corpus/keep.txt
REVISION_AUDIT: SETUP (stale=0 missing=0 dropped=0 added=0 invalid=1)
```

Expected exit **2**; observed exit **2**. The duplicate is a stamp path identifier, not a claim-ledger row ID.

### Malformed row after a valid prefix

```text
/usr/bin/python3 -I -B /tmp/kagi-r22-w2-PinMalformed/corpus/revision-audit.py --root /tmp/kagi-r22-w2-PinMalformed/fixtures/malformed-after-valid-prefix --history f4dc520c064d997b51949c919e27636b1084ba6a
```

Stdout, including its final newline:

```text
MALFORMED-LINE 2
REVISION_AUDIT: SETUP (stale=0 missing=0 dropped=0 added=0 invalid=1)
```

Expected exit **2**; observed exit **2**. A matching first record did not hide or truncate the malformed second record. This does not claim that every additional valid row must be rejected.

## Retained execution evidence

Relative to `.ufo/waves/round-22/falsify/PinMalformed/`:

| retained file | SHA-256 |
|---|---|
| `run-case.py` | `781f317dc013e8ceb2e93f2d10058de5e804bb60e7f81c201bcdaadc8c43b998` |
| `results/clean-control.json` | `6470aeaa7d213358d8505819e52ff45ffeb36472c2f5533dba3892c9d87fc013` |
| `results/malformed-tsv.json` | `1864b94a99df8c0a41d0f262a7b61370dd086d34594b89307d62632e39ecd1c4` |
| `results/duplicate-ids.json` | `120406ba88f2af4c6ab4c1ac7b47a68fb3547b6bd1efa1d7bdf3c3264258b35b` |
| `results/malformed-after-valid-prefix.json` | `edbc8c026ddc877f0b0a1e50446049b352cee41b5db03ad62e14e0b14a60c80b` |

Every result includes observation time, exact runner argv, runner/implementation digests, complete fixed environment, full setup command captures, fixture contents/digests, full audit argv/cwd/output/exit, and the expected result. All four recorded `matches_expectation` values were `true`.

Exact runner invocation pattern used once for each literal case name listed above:

```text
/usr/bin/python3 -I -B /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-22/falsify/PinMalformed/run-case.py <case-name>
```

The exact expanded argv is also retained per result. The runner intentionally refuses existing case roots/result files rather than silently replacing retained evidence. It is retained reproduction evidence, not a new production gate.

## Limits, correction and handoff

- **No production implementation, tests, documents, stamp snapshots, or ledger rows were changed.** Repository writes were limited to this report and its exclusively assigned evidence subtree; scratch writes were confined to the unique `/tmp` root.
- Setup and audit subprocesses used a fixed minimal environment, an owned empty HOME/template directory, and disabled system/global Git configuration. No ambient environment values or credential/session material were copied into evidence.
- No live-tree gate, host-private gate, account/vault operation, network request, loopback probe, launcher, package manager, service, build, lint, formatter, or unrelated test was run. No tools were installed or updated. No subagents or background jobs were started.
- The three invalid cases return SETUP before member/fingerprint adjudication. Their zero stale/missing/dropped/added counters therefore must **not** be represented as a successful freshness audit. Only the clean control exercised a valid table against its synthetic history.
- Malformed historical tables, path/symlink cases, broader encoding/size boundaries, nine-line migration evidence and source-based C1 decisions remain outside this assigned attack. No findings are inferred for them.
- **Proposed correction:** none for the observed behavior. **Risks/blockers:** no execution blocker; residual coverage is limited to the named fixtures. If the parent later changes this parser, the relevant follow-up checks are these three retained refusal cases plus the clean control against a newly named frozen implementation hash, in fresh owned roots. Do not replay against the production root.

Report: .ufo/waves/round-22/falsify/RunPinMalformed.md
