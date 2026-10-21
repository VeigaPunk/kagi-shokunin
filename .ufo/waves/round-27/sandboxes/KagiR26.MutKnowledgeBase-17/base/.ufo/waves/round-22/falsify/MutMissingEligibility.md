# MutMissingEligibility — omitted Broker eligibility

## Axes and bounded result

- **Calibration (C1):** challenge eligibility preservation with one independently submitted typed claim, retaining its valid paired control. Count correct decisions, not authored records or repeated executions.
- **Freshness (C2):** identify the exact frozen integrated inputs and preserve their bytes. This seat did not run revision accounting or claim source currentness from a digest.
- **Mutant verdict: KILLED.** Removing only the top-level `eligibility` member from a valid Broker claim produced exit **1**, `decision=reject:bar-fail`, and **`FC-ELIGIBILITY-QUALIFIER`**. Pristine and restored copies admitted with exit **0**. The separately retained valid control also admitted while the mutant was present.

This is an input-record mutation probe, not an implementation mutation, overall round admission, or independent verification of vendor truth. No exit-2 outcome was observed or credited.

## Exact read revision and frozen inputs

Observed read-only command:

```text
git rev-parse refs/heads/master 8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3^{tree}
```

Actual stdout, exit 0:

```text
8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3
d12afd7a545e86f21eb9acac567d10de774df50f
```

Thus the observed master tip was the measured integration landing, and the second line is that landing's Git tree. Historical base `c2cab35bc92e57e39e5489bac3386db078345b3f` was not used as the falsification input.

Freeze manifest: `.ufo/waves/round-22/integration-manifest.json`, SHA-256 **`31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`**. Relevant manifest entries matched observed production bytes before and after the probe:

| Input | Bytes / lines recorded by manifest | Observed SHA-256 |
|---|---:|---|
| `corpus/feature-claims.py` | 45532 / 1040 | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` |
| `corpus/feature-claims.json` | 47434 / 995 | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` |
| `plans/round-22.md` | 1804 / 10 | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` |
| `corpus/lessons/round-22.md` | 15700 / 192 | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` |

Read the round plan and lesson before execution. Interface inspection covered `feature-claims.py:624-739` (semantic decisions), `848-858` (input exit mapping), and `948-1040` (CLI and dispatch). The actual CLI accepts `--root`, `--claims`, and `--input`; `--input` evaluates one unlabeled claim against the separately loaded, pinned review artifact. No flags were inferred from other tools.

## Isolated fixture and one-record delta

All gate executions used copied files beneath:

```text
/tmp/kagi-r22-w2-MissingEligibility
```

Only `corpus/feature-claims.py` and `corpus/feature-claims.json` were copied from production. Their bytes were unchanged throughout. No production gate was executed.

`inputs/valid-control.json` was created from **`AFTER-GITHUB-BOUNDED.claim`**, inspected at `corpus/feature-claims.json:671-705`. It contains only the typed claim, not the record's ID, expected decision, phase, authority, defect label, or reference envelope. A data comparison observed `valid_equals_bounded_after_claim=true`.

`inputs/claim.json` initially contained exactly the valid control bytes. The sole mutation deleted its entire top-level `eligibility` member. Actual record comparison:

```json
{
  "removed_keys": ["eligibility"],
  "added_keys": [],
  "changed_common_keys": [],
  "eligibility_before": {
    "scope": "source_bounded",
    "plans": ["enterprise_password_manager_business"],
    "requirements": ["business_account_connected", "github_com_org"],
    "documented_exclusions": [
      "github_enterprise_server",
      "github_enterprise_cloud_data_residency",
      "github_free_private_repositories"
    ]
  },
  "eligibility_after": "ABSENT",
  "evidence_unchanged": true
}
```

Product, feature, path, release status, runtime constraints, fact, and the entire evidence map remained identical. In particular, `evidence.eligibility.plans`, `evidence.eligibility.requirements`, and `evidence.eligibility.documented_exclusions` remained present. This isolates omission of the asserted qualifier rather than missing citations or an unknown feature. The trusted JSON's catalog, embedded controls, transitions, and digest pins were never changed. A manifest-tamper refusal was neither induced nor counted.

## Expected detector and exact executions

For every invocation:

- Working directory: `/tmp/kagi-r22-w2-MissingEligibility`.
- Subprocess deadline: 15 seconds.
- Explicit environment: `PATH=/usr/bin:/bin`, `LC_ALL=C`.
- Interpreter: `/usr/bin/python3`, with `-I -B`; no launcher or additional runtime.

The **identical argv** below was used on pristine, mutated, and restored `inputs/claim.json`:

```json
["/usr/bin/python3", "-I", "-B", "corpus/feature-claims.py", "--root", "/tmp/kagi-r22-w2-MissingEligibility", "--claims", "corpus/feature-claims.json", "--input", "inputs/claim.json"]
```

Paired valid-control argv, executed once before mutation and again while the mutant was present:

```json
["/usr/bin/python3", "-I", "-B", "corpus/feature-claims.py", "--root", "/tmp/kagi-r22-w2-MissingEligibility", "--claims", "corpus/feature-claims.json", "--input", "inputs/valid-control.json"]
```

Expected behavior: baseline/control/restored exit 0 with `FC-ADMITTED`; the omitted-eligibility claim must exit 1 with the specific semantic/bar-fail finding `FC-ELIGIBILITY-QUALIFIER`. Exit 2 would be inconclusive and excluded, not a killed mutant.

Actual outputs (each stdout line ended in one newline; **stderr was empty in all five executions**):

| Execution | Exit | Complete stdout line |
|---|---:|---|
| Pristine `inputs/claim.json` | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` |
| Paired valid control before mutation | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` |
| Mutated `inputs/claim.json` | 1 | `FEATURE_CLAIMS: REJECT decision=reject:bar-fail finding=FC-ELIGIBILITY-QUALIFIER` |
| Paired valid control during mutation | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` |
| Restored `inputs/claim.json` | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` |

The output checker compared the mutant's exit, complete stdout, and empty stderr against the specific expected rejection; the observed comparison was **true**. The restored admission comparison was also **true**. Repeated controls and restoration checks do not create additional independent decision credit: this is one rejected bad claim plus one admitted bounded control.

## Before/after hashes and exact restoration

| Fixture input | Pristine SHA-256 | Mutated SHA-256 | Restored SHA-256 |
|---|---|---|---|
| `inputs/claim.json` | `b07d54ce3914b828ef53d353267ef6c7cbd237983b7b8a3af69ad895e4807949` | `a48bfb6bdb1c626be61c8c4cf9b8f2e47362fd132b4778bc2c62c1f5dc78f97c` | `b07d54ce3914b828ef53d353267ef6c7cbd237983b7b8a3af69ad895e4807949` |
| `inputs/valid-control.json` | `b07d54ce3914b828ef53d353267ef6c7cbd237983b7b8a3af69ad895e4807949` | `b07d54ce3914b828ef53d353267ef6c7cbd237983b7b8a3af69ad895e4807949` | `b07d54ce3914b828ef53d353267ef6c7cbd237983b7b8a3af69ad895e4807949` |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` |

Restoration pasted back the exact captured eligibility block, not a reconstructed approximation. The restored input matched the pristine SHA-256. A byte comparison returned `restored_exact_valid_control_bytes=true`; additionally, this command completed with exit 0 and no comparison output:

```text
cmp -- /tmp/kagi-r22-w2-MissingEligibility/inputs/claim.json /tmp/kagi-r22-w2-MissingEligibility/inputs/valid-control.json
```

The same bounded detector then admitted restored bytes. The valid paired record remains retained in the private fixture. Production input and freeze-manifest hashes were unchanged at closure.

## Limits, correction, and handoff

- **No production correction is indicated by this particular probe.** Preserve the absent-eligibility rejection and its separation from `cannot-evaluate`. Parent owns all integration decisions.
- This checks a missing top-level eligibility qualifier for one in-scope GitHub Actions Broker claim. It does not establish arbitrary-prose parsing, all qualifier permutations, vendor accuracy, or full C1 agreement. The record is derived from a trusted bounded after-claim, not claimed as a novel vendor-source judgment.
- C2 evidence here is input identity only. No stale/dropped-stamp census, migration adjudication, source freshness claim, depth move, or legacy-header count claim was attempted.
- If the parent subsequently changes the gate, parent-owned checks to run after integration are the copied paired `--input` executions above and the documented `corpus/feature-claims.py --selftest` interface. This seat did not execute that broader selftest, builds, linters, formatters, or host-private gates.
- No installations, package transactions, services, network/loopback probes, credential/account operations, other runtime, or production implementation edits occurred. The only repository write by this seat is this report; all other writes stayed in the assigned scratch fixture.

Report: .ufo/waves/round-22/falsify/MutMissingEligibility.md
