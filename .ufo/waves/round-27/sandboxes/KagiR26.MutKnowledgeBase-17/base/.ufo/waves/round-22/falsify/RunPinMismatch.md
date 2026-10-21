# RunPinMismatch — revision-audit field falsification

## Scope and decision

Assigned axis: C2 freshness. I inspected `plans/round-22.md`, `corpus/lessons/round-22.md`, the frozen integration manifest, and the `revision-audit.py` interface. The auditor accepts `--root DIR --history FULL_COMMIT_ID`; its root must be a Git repository containing `corpus/stamps.tsv`. It fingerprints each stamped file as `(SHA-256, count of LF bytes, byte length)`, emits `STALE <path>` when any field differs, and exits 1 for stale drift.

The field-isolated fixture cases all produced exactly one stale finding and exit 1. No production implementation, corpus, or lane state was edited. The only repository file written for this task is this report; the copied runner and fixtures are retained under `/tmp/kagi-r22-w2-PinMismatch/`.

## Frozen input identity

Measured after integration; these match the corresponding entries in the frozen manifest:

| Input | SHA-256 | Lines | Bytes |
|---|---|---:|---:|
| `.ufo/waves/round-22/integration-manifest.json` | `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911` | — | — |
| `corpus/revision-audit.py` | `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977` | 548 | 20,857 |
| `corpus/stamps.tsv` | `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29` | 69 | 7,213 |
| `corpus/claim-ledger.tsv` | `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a` | 58 | 17,770 |

The copied runner at `/tmp/kagi-r22-w2-PinMismatch/corpus/revision-audit.py` has SHA-256 `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977`, identical to the frozen input. Manifest expected full-tree audit counts are stale=0, missing=0, dropped=0, added=6, invalid=0; I did not invoke that audit against the live tree.

## Fixture and exact evidence

Fixture root is `/tmp/kagi-r22-w2-PinMismatch/fixtures/{digest,newline,byte-count}`. All three are independent copies of one minimal local Git fixture. The synthetic history commit is `baddd68ec8292d32e767aa885bc9d42a41a05c72`; its baseline has the sole member `corpus/probe.txt` and the correct stamp row. Probe bytes are UTF-8 `alpha\nbeta\n` (2 LF bytes, 11 bytes), SHA-256 `e49c81e2d2f84e259d40e2fb8192f3bcd198b355184845d76d8f58807d0d78ee`.

Baseline `corpus/stamps.tsv` row:

```text
corpus/probe.txt\te49c81e2d2f84e259d40e2fb8192f3bcd198b355184845d76d8f58807d0d78ee\t2\t11
```

Baseline stamps file SHA-256: `b09597938accc90795d4d0611fae00696b2409b2cdb775e1fad0eccd268786fe` (1 line, 87 bytes). Case-specific rows changed only the indicated stamped field:

| Case | Exact fixture stamp row | Stamps SHA-256 |
|---|---|---|
| Digest only | `corpus/probe.txt\t0000000000000000000000000000000000000000000000000000000000000000\t2\t11` | `f504fecf6cf2968a6c8f1e28ef6a7a42a639e9c3a062855b52a270c2e60bfbe6` |
| LF/newline count only | `corpus/probe.txt\te49c81e2d2f84e259d40e2fb8192f3bcd198b355184845d76d8f58807d0d78ee\t3\t11` | `dbf3bb5969bb13e5f86b3afe33b07799c836113f9a6475e444bd7ae1da1a84f1` |
| Byte count only | `corpus/probe.txt\te49c81e2d2f84e259d40e2fb8192f3bcd198b355184845d76d8f58807d0d78ee\t2\t12` | `0a2466e6857babe5fe2cdedf7d89113da14267a6159989b2741a2a43a8a16143` |

Each case's probe file retained the same SHA-256 above. Each mutated `stamps.tsv` is 1 LF-terminated line and 87 bytes. The runner was invoked with `GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null`; no system or global Git configuration was needed.

Exact runner argv and observed result (stdout and exit):

```text
python3 /tmp/kagi-r22-w2-PinMismatch/corpus/revision-audit.py --root /tmp/kagi-r22-w2-PinMismatch/fixtures/digest --history baddd68ec8292d32e767aa885bc9d42a41a05c72
STALE corpus/probe.txt
REVISION_AUDIT: DRIFT (stale=1 missing=0 dropped=0 added=0 invalid=0)
exit=1

python3 /tmp/kagi-r22-w2-PinMismatch/corpus/revision-audit.py --root /tmp/kagi-r22-w2-PinMismatch/fixtures/newline --history baddd68ec8292d32e767aa885bc9d42a41a05c72
STALE corpus/probe.txt
REVISION_AUDIT: DRIFT (stale=1 missing=0 dropped=0 added=0 invalid=0)
exit=1

python3 /tmp/kagi-r22-w2-PinMismatch/corpus/revision-audit.py --root /tmp/kagi-r22-w2-PinMismatch/fixtures/byte-count --history baddd68ec8292d32e767aa885bc9d42a41a05c72
STALE corpus/probe.txt
REVISION_AUDIT: DRIFT (stale=1 missing=0 dropped=0 added=0 invalid=0)
exit=1
```

No stderr text was present in the captured outputs. The `EXIT=1` marker printed by the shell wrapper confirmed each command's exit status. Fixture initialization emitted `warning: templates not found in /dev/null` when selecting `/dev/null` as the template directory; the fixture commit was successfully created and the audit invocations themselves emitted no warning.

## Limits, risks, blockers

This verifies the three fingerprint dimensions independently against the frozen integrated runner using an isolated synthetic Git history. It does not assert full-tree stale/member counts, historical nine-line migration membership, or C1 feature adjudications; no live-tree gate or host-private read was performed. The manifest's zero-stale/six-added expectation remains unverified by this task. No blocker encountered. No tools were installed or updated.