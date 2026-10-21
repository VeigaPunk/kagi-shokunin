# MutCrossProduct — round-22 isolated mutation probe

## Axes and scope

- **Calibration (C1):** challenge product-specific evidence attribution with a Vault-only fact binding on an otherwise bounded OpenBao-token claim. Expected result: semantic `reject:bar-fail`, stable finding `FC-CROSS-PRODUCT`, exit **1**. Retain the valid independent-input control at exit **0**.
- **Freshness (C2):** identify the exact frozen bytes examined. This seat does not execute the revision-stamp audit, reopen vendor documentation, or claim source currentness from hashes.

Leaf seat `KagiR22.MutCrossProduct`; no delegation, integration, production implementation edits, or repository-state operations. Execution was confined to `/tmp/kagi-r22-w2-CrossProduct`. No network, host-private gate, launcher, package manager, installation, service, account, vault, or credential operation was used. Installs/updates: **none**.

## Exact read revision

The historical base `c2cab35bc92e57e39e5489bac3386db078345b3f` was not the execution input. The task identifies measured integration landing `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`; this seat binds its observations to the frozen input hashes, not a detached HEAD or an earlier build report.

Freeze authority: `.ufo/waves/round-22/integration-manifest.json`, observed SHA-256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.

Observed by `sha256sum .ufo/waves/round-22/integration-manifest.json corpus/feature-claims.py corpus/feature-claims.json plans/round-22.md corpus/lessons/round-22.md` from the lane repository:

| Input | Observed SHA-256 | Freeze comparison |
|---|---|---|
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | Matches manifest |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | Matches manifest |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` | Matches manifest |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` | Matches manifest |

The gate and its entire trusted JSON were copied byte-for-byte into the private fixture. The copied gate and JSON retained the listed hashes at all three executions.

## Inspected interface and expected detector

Read the integrated implementation before invoking it:

- `corpus/feature-claims.py:948-1009`: supported `--root`, `--claims`, and `--input`; no invented flags.
- `corpus/feature-claims.py:1023-1028`: validate the unchanged trusted review artifact, then evaluate a separate input record.
- `corpus/feature-claims.py:709-717`: an existing source/quote whose product differs from the claim feature returns `reject:bar-fail` / `FC-CROSS-PRODUCT`.
- `corpus/feature-claims.py:848-858`: admit is exit 0, semantic rejection is exit 1, cannot-evaluate is exit 2.

Trusted catalog mappings, read locally rather than fetched: `S013` is `hashicorp_vault`, with `S013-dynamic` under the lease page's §Lease, renew, and revoke (`https://developer.hashicorp.com/vault/docs/concepts/lease`, artifact observation date 2026-10-20); `S021` is `openbao`, with `S021-ttl` under §Token Time-To-Live, periodic tokens, and explicit max TTLs (`https://openbao.org/docs/concepts/tokens/`, artifact observation date 2026-10-20). These are catalog provenance, not new public-source verification by this seat.

## Mutant and before → after record delta

`input.json` is one unlabeled typed claim, semantically equal to `records[id=AFTER-OPENBAO-TTL].claim` in the copied JSON. Equality was asserted before the first execution. No record ID, expected decision, authority label, catalog, source declaration, control record, or digest pin was changed.

The valid input bytes were:

```json
{
  "product": "openbao",
  "feature": "openbao_token_ttl",
  "path": "openbao/docs/concepts/tokens",
  "release_status": "not_asserted",
  "eligibility": {
    "scope": "not_assessed",
    "plans": [],
    "requirements": [],
    "documented_exclusions": []
  },
  "runtime_constraints": ["service_token_scope"],
  "fact": "openbao_service_token_nonroot_ttl_revokes_token_and_associated_leases",
  "evidence": {
    "product": [["S021", "S021-title"]],
    "feature": [["S021", "S021-title"]],
    "path": [["S021", "S021-title"]],
    "release_status": [],
    "eligibility.plans": [],
    "eligibility.requirements": [],
    "eligibility.documented_exclusions": [],
    "runtime_constraints": [["S021", "S021-service-scope"]],
    "fact": [["S021", "S021-ttl"]]
  }
}
```

The sole changed leaf was **`evidence.fact`**, at scratch `input.json:23`:

```diff
-    "fact": [["S021", "S021-ttl"]]
+    "fact": [["S013", "S013-dynamic"]]
```

Thus the token-TTL fact has exclusively Vault support; its OpenBao identity, service-token scope, and other qualifiers remain unchanged. This is one plausible borrowed-product citation defect, not a new fact claim. The mutated object was asserted equal to the original object with only that replacement. It exercises the independent-input interface for the known cross-product defect; it is not credited as a novel defect class.

## Exact bounded executions and actual output

All three runs used the **same argv**, working directory, and 20-second subprocess timeout:

```json
["/usr/bin/python3", "corpus/feature-claims.py", "--root", "/tmp/kagi-r22-w2-CrossProduct", "--claims", "corpus/feature-claims.json", "--input", "input.json"]
```

Working directory: `/tmp/kagi-r22-w2-CrossProduct`.

| Stage | Exit | Exact stdout, excluding its final newline | stderr |
|---|---:|---|---|
| Pristine bounded control | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` | Empty |
| Cross-product mutant | 1 | `FEATURE_CLAIMS: REJECT decision=reject:bar-fail finding=FC-CROSS-PRODUCT` | Empty |
| Exact-byte-restored control | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` | Empty |

Assertions checked the exact exits, full stdout including final newline, and empty stderr. No run returned exit 2, timed out, or relied on a manifest-tamper refusal. Decision evidence is one valid control and one semantic rejection; the restored control is restoration evidence, not another independent decision.

## Hashes, restoration evidence, and verdict

| Bytes | Before SHA-256 | Mutated SHA-256 | Restored SHA-256 |
|---|---|---|---|
| `input.json` | `582c988b9502f36f938d066ca426593ffc0508221293cd0ab94f1535a6869d8d` | `851b3d5d76595e59e47440483565ba8d43316dce1402c9551bb1e863fce496f4` | `582c988b9502f36f938d066ca426593ffc0508221293cd0ab94f1535a6869d8d` |
| Copied gate | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` | Same | Same |
| Entire trusted catalog/control JSON | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` | Same | Same |

After restoring the one line, the original input bytes were compared directly to restored bytes, and equality was asserted. The gate and entire trusted catalog were likewise compared directly against their initial byte snapshots and remained equal. The restored detector then admitted the valid claim again.

**Mutation verdict: KILLED.** The baseline passed, the assigned bad claim was rejected for the specific semantic/bar-fail reason at exit 1, and exact restoration passed. No source-integration correction is proposed for this probe. Keep the explicit product-attribution guard and unchanged trusted catalog; the parent may retain this input/control pair as an independent-interface regression case if integrating further changes.

Limits: a bounded typed-record attribution result does not establish arbitrary-prose understanding, vendor truth, source freshness, outside-verifier agreement, a global accuracy scalar, score changes, or C2 revision-accounting correctness. No builds, linters, formatters, broad selftests, or other mutation probes were run. After any parent-owned integration, the relevant follow-up check is this same bounded `--input` control/rejection pair in a fresh isolated copy; no host-private gate is implied.

Report: .ufo/waves/round-22/falsify/MutCrossProduct.md
