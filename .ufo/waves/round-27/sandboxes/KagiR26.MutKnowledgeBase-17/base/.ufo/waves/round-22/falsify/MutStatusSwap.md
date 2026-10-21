# MutStatusSwap — integrated Broker status holdout

## Axes and verdict

- **Calibration:** challenge feature-specific release-status adjudication, while preserving all eligibility, runtime, fact and evidence qualifiers.
- **Freshness:** bind this observation to frozen integrated bytes; this seat does not audit revision stamps or independently reverify vendor documentation.
- **Verdict: KILLED.** Both valid independent inputs exited 0; the reciprocal status swap made both exit 1 with exactly `FC-STATUS-MISMATCH` / `reject:false-claim`; exact restoration recovered both exit-0 controls. No exit-2 result receives decision credit.

## Read revision and observed input hashes

The historical BEFORE base is `c2cab35bc92e57e39e5489bac3386db078345b3f`, not this probe's input. The task identifies measured integration landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`. This seat identifies its actual read snapshot by the frozen manifest and measured file hashes below, not by detached HEAD or an inferred branch tip.

SHA-256 of `.ufo/waves/round-22/integration-manifest.json`:

`31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`

| Input relative to repository | Observed SHA-256, matching manifest |
|---|---|
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` |

Production hashes were identical before and after the probe. The copied gate and trusted JSON matched these hashes at pristine, mutated and restored stages.

## Interface, invariant and smallest mutant

Inspected `corpus/feature-claims.py` before execution: argument parsing/help at lines 948–1009; input dispatch at 1023–1028; semantic status comparison at 648–653; input result/exit mapping at 848–858. The supported interface accepts one bare typed claim with `--input PATH`, beneath `--root`. It is not necessary to edit the pinned catalog or controls.

Created the unique owned fixture `/tmp/kagi-r22-w2-StatusSwap`, copying only the integrated gate and its trusted JSON into `corpus/`. Wrote two bare claim objects, reformatted from these bounded after-record `.claim` objects without their expected-decision labels or record metadata:

| Independent input | Derived from trusted after-record | Feature |
|---|---|---|
| `input-status-github.json` | `AFTER-GITHUB-BOUNDED` | `op_cb_github_actions` |
| `input-status-custom.json` | `AFTER-CUSTOM-BETA-BOUNDED` | `op_cb_custom_oidc` |

The single assigned defect is the reciprocal release-status swap. Each input changes only line 5, its scalar `/release_status`; every other qualifier and source/quote reference remains unchanged. The expected detector is the semantic finding `FC-STATUS-MISMATCH`, decision `reject:false-claim`, exit **1**, not a manifest refusal or unknown/out-of-scope exit 2.

Observed record deltas (`diff --unified=0`, each comparison returned 1 because the files differ):

```diff
--- pristine-status-github.json
+++ input-status-github.json
@@ -5 +5 @@
-  "release_status": "public_preview",
+  "release_status": "public_beta",
```

```diff
--- pristine-status-custom.json
+++ input-status-custom.json
@@ -5 +5 @@
-  "release_status": "public_beta",
+  "release_status": "public_preview",
```

The trusted `corpus/feature-claims.json` remained byte-identical throughout. Its sources, feature catalog, controls, labels and digest pins were not edited. This was an independent-input semantic probe, not a tamper test or a code mutation.

## Exact detector execution

For every stage, working directory was `/tmp/kagi-r22-w2-StatusSwap`. Each command had a 10-second subprocess timeout and environment `PATH=/usr/bin:/bin`, `HOME=/tmp/kagi-r22-w2-StatusSwap`, `LANG=C.UTF-8`. `/usr/bin/python3` resolved directly to `/usr/bin/python3.14`; no launcher was invoked. The two independent commands ran concurrently within each stage. Stages remained ordered: pristine, swap, mutated, restoration, restored.

Exact argv, unchanged across the three stages:

```json
["/usr/bin/python3", "-I", "-B", "/tmp/kagi-r22-w2-StatusSwap/corpus/feature-claims.py", "--root", "/tmp/kagi-r22-w2-StatusSwap", "--input", "input-status-github.json"]
["/usr/bin/python3", "-I", "-B", "/tmp/kagi-r22-w2-StatusSwap/corpus/feature-claims.py", "--root", "/tmp/kagi-r22-w2-StatusSwap", "--input", "input-status-custom.json"]
```

| Stage | Input | Actual exit | Actual stdout, followed by one LF |
|---|---|---:|---|
| pristine | GitHub | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` |
| pristine | custom OIDC | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` |
| mutated | GitHub | 1 | `FEATURE_CLAIMS: REJECT decision=reject:false-claim finding=FC-STATUS-MISMATCH` |
| mutated | custom OIDC | 1 | `FEATURE_CLAIMS: REJECT decision=reject:false-claim finding=FC-STATUS-MISMATCH` |
| restored | GitHub | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` |
| restored | custom OIDC | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` |

All six stderr values were empty; no timeout occurred. Executed assertions required the pristine controls' exact exit/stdout/stderr, both mutated claims' exact exit-1 semantic finding, and both restored controls' exact exit-0 admission. All assertions passed. The two bad decisions concern one reciprocal-swap defect, not two independent mutation classes; restored runs are recovery evidence, not additional calibration cases.

## Hash and restoration evidence

| Independent input | Pristine SHA-256 | Mutated SHA-256 | Restored SHA-256 |
|---|---|---|---|
| GitHub | `b07d54ce3914b828ef53d353267ef6c7cbd237983b7b8a3af69ad895e4807949` | `12256ded41b9c1aa4c79bcd31dddd192b692731c3d0541840b5979330be7fb00` | `b07d54ce3914b828ef53d353267ef6c7cbd237983b7b8a3af69ad895e4807949` |
| custom OIDC | `2faa6a4573db1e92c2a0ee61b01cfff12c7cc4cd3349e441460b48d2577224b8` | `33fde6d54d2e62b1820e98ca9fc9b6b1d094aaaf062aa58d9767d4fd894df5bc` | `2faa6a4573db1e92c2a0ee61b01cfff12c7cc4cd3349e441460b48d2577224b8` |

Preserved the original fixture bytes as `pristine-status-github.json` and `pristine-status-custom.json` before mutation. Restored the two scalar values, then executed this chain in the owned fixture; it exited **0** and printed the restored hashes shown above:

```sh
cmp --silent pristine-status-github.json input-status-github.json && cmp --silent pristine-status-custom.json input-status-custom.json && sha256sum corpus/feature-claims.py corpus/feature-claims.json input-status-github.json input-status-custom.json pristine-status-github.json pristine-status-custom.json
```

The gate and trusted JSON retained their frozen hashes in that command. Both pristine snapshots and the restored valid `--input` controls remain in the private fixture. No production implementation was modified.

## Limits, correction and parent handoff

- The interface represents the assigned case: two separate invocations each accept one arbitrary unlabeled typed claim. Both swap directions are semantically rejected, rather than excluded as unjudgeable.
- This demonstrates status binding against the unchanged pinned authority. It does not independently establish vendor truth, arbitrary-prose handling, outside-verifier agreement, aggregate accuracy, revision-ledger correctness or source currentness.
- **Proposed correction:** none indicated for this assigned defect; retain the exact `FC-STATUS-MISMATCH`/exit-1 expectation and these valid exit-0 controls if the parent later integrates gate changes. Do not weaken the invariant or credit manifest-tamper refusals as qualifier decisions.
- Parent checks after any subsequent source integration: rerun this same pristine/mutated/restored `--input` pair in an owned isolated copy; run the gate's documented `--selftest` there if a broader gate change requires it. This seat did not run a selftest, build, linter, formatter or host-private gate.
- No network, account, vault, loopback/health/CDP, service, package-manager, installation or configuration operation was performed. No subagents were dispatched. Installs/updates: **none**.
