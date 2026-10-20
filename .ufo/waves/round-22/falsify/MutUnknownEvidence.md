# MutUnknownEvidence — missing fact authority

## Axes and scope

- **Calibration (C1):** a bounded, otherwise valid claim must not be admitted after its fact-specific evidence authority is removed. Measure the decision, not a row count or a manifest-tamper refusal.
- **Freshness (C2):** identify the frozen integrated bytes actually exercised. This seat does not audit revision-stamp membership, source currentness, or ledger migrations and claims no C2 decision credit.
- One assigned mutation probe only; three executions of the same bounded detector, all in `/tmp/kagi-r22-w2-UnknownEvidence`. No production implementation mutation, host-private gate, network request, launcher, installation, package transaction, service, or delegated work occurred.

## Exact read revision and frozen inputs

Historical BEFORE base: `c2cab35bc92e57e39e5489bac3386db078345b3f`; it was **not** the detector input. Read the supplied measured landing with:

```text
git show --no-patch --format='commit=%H%ntree=%T%nsubject=%s' 8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3
commit=8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3
tree=d12afd7a545e86f21eb9acac567d10de774df50f
subject=round-22: feature-bound review capability and audited revision repairs
```

No lane revision was inferred from detached HEAD. The source working-file hashes below were observed directly with `sha256sum`; all four listed source inputs match `.ufo/waves/round-22/integration-manifest.json`.

| Input | Observed SHA-256 |
|---|---|
| `.ufo/waves/round-22/integration-manifest.json` | `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911` |
| `corpus/feature-claims.py` | `9f6a7e355b74d8f051ecbe1c39334280625d8910f2568b567979639264d074af` |
| `corpus/feature-claims.json` | `a506cea7ef26f731721ebd9fa22fb77f50c40b1f4a939cded26e6bb3f2b503aa` |
| `plans/round-22.md` | `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06` |
| `corpus/lessons/round-22.md` | `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4` |

Only the Python gate and complete trusted JSON were copied into the private fixture. Their hashes matched the frozen values before each of the three detector executions. No catalog, source binding, control record, label, expected outcome, digest pin, or gate code was changed.

## Interface and mutant

Inspected `feature-claims.py` before invocation: lines 948–1034 define `--root`, `--claims`, and the independent `--input PATH` mode; lines 848–858 map admit to exit 0, semantic rejection to exit 1, and cannot-evaluate to exit 2. No invented gate flags were used.

The new unlabeled input `corpus/inputs/holdout.json` is exactly the `claim` object from `AFTER-OPENBAO-TTL` (JSON object equality observed as `True`). It asserts the known `openbao_token_ttl` feature with `service_token_scope`, no release-status assertion, and no eligibility assertion. Its fact remains `openbao_service_token_nonroot_ttl_revokes_token_and_associated_leases` throughout.

**Mutant:** remove the sole fact-specific citation while leaving the fact and all its other qualifiers intact. This is the permitted missing-authority variant, not an unknown-ID boundary case.

```diff
-    "fact": [["S021", "S021-ttl"]]
+    "fact": []
```

The complete structural before/after record delta is **only `evidence.fact`**, from `[["S021", "S021-ttl"]]` to `[]`. All non-evidence claim fields are unchanged; the trusted JSON is unchanged. The input loses 20 bytes (771 → 751).

**Expected detector:** `reject:bar-fail`, stable finding **`FC-EVIDENCE-BINDING`**, exit **1**. The known fact has no observed supporting binding once the citation list is empty (`_evaluate_claim`, lines 695–731). This challenges evidence adjudication after trusted-catalog validation, not a catalog-digest refusal.

## Exact command and actual outputs

Working directory for every run: `/tmp/kagi-r22-w2-UnknownEvidence`. The subprocess environment retained the inherited environment with `PYTHONDONTWRITEBYTECODE=1`; each detector had a 15-second timeout and completed normally. The exact argv was identical for all three stages:

```json
["/usr/bin/python3", "corpus/feature-claims.py", "--root", "/tmp/kagi-r22-w2-UnknownEvidence", "--claims", "corpus/feature-claims.json", "--input", "corpus/inputs/holdout.json"]
```

| Stage | Actual exit | Actual stdout (one line, followed by newline) | Actual stderr |
|---|---:|---|---|
| Pristine valid control | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` | empty |
| Missing-authority mutant | 1 | `FEATURE_CLAIMS: REJECT decision=reject:bar-fail finding=FC-EVIDENCE-BINDING` | empty |
| Restored valid control | 0 | `FEATURE_CLAIMS: ADMIT finding=FC-ADMITTED` | empty |

Assertions checked the exact exit, exact stdout including its trailing newline, empty stderr, and unchanged trusted-file hashes at every stage; all three assertions passed. Baseline did not fail. No cannot-evaluate/exit-2 outcome was counted as a semantic decision.

## Verdict and restoration evidence

**KILLED.** The detector admitted the bounded control, rejected its one-field missing-authority mutant with the required semantic/bar-fail finding and exit 1, and admitted the exactly restored control.

| Input state | Bytes | SHA-256 |
|---|---:|---|
| Pristine | 771 | `582c988b9502f36f938d066ca426593ffc0508221293cd0ab94f1535a6869d8d` |
| Mutated | 751 | `6e1a80fb536f91815d605d06f9965b7294fb31ddf95a9182b0fbce5d3f094aaf` |
| Restored | 771 | `582c988b9502f36f938d066ca426593ffc0508221293cd0ab94f1535a6869d8d` |

Restored bytes were compared to the saved pristine bytes: **equal**. Restored structural record delta: `[]`. The valid `--input` control remains at `/tmp/kagi-r22-w2-UnknownEvidence/corpus/inputs/holdout.json`. The copied gate and entire trusted JSON retained their frozen hashes at pristine, mutated, and restored stages.

## Limits, proposed correction, and parent checks

- This is one local, typed under-citation challenge, not a source-truth check, arbitrary-prose verifier, overall calibration scalar, independent vendor-fact adjudication, or freshness audit.
- Unknown source/quote IDs were not separately executed: this seat used its one probe on missing authority to satisfy the semantic exit-1 requirement. Static interface inspection shows unknown source IDs yield `FC-UNKNOWN-SOURCE`/exit 2, which is unjudgeable and excluded from decision credit; that branch is not claimed as exercised evidence here.
- **Proposed correction:** none demonstrated for this assigned invariant. Preserve the missing-authority refusal; no production change is justified by this killed mutant. Source integration remains the parent's responsibility.
- Parent checks after any later integration: repeat this same control/mutant/restored `--input` triple against the unchanged trusted catalog, requiring 0/1/0 and specifically `FC-EVIDENCE-BINDING` for the mutant. The broader `python3 corpus/feature-claims.py --selftest` was not run by this seat.
- Installs/updates: **none**. Production changes: **this requested report only**.

Report: .ufo/waves/round-22/falsify/MutUnknownEvidence.md
