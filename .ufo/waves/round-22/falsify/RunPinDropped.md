# RunPinDropped — historical pin disappearance

## Scope and frozen input

- Axis exercised: **freshness** only. This is the assigned bounded `revision-audit.py` check: one historical member absent from the current pin set, expected `DROPPED`, and no false-clean.
- Read revision: `refs/heads/master` resolved to `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3`, matching the recorded integration landing. No lane revision was inferred from detached `HEAD`.
- Frozen manifest: `.ufo/waves/round-22/integration-manifest.json`, SHA-256 `31e604021a0b7d9409b238cbbfceaaf5735066f82b3e0e450d73bafb6a1b5911`.
- Relevant frozen inputs, measured against that manifest:
  - `plans/round-22.md` — `37b8eb0b8a6dd949dbf421039d9a9691b4035716ec994e1f6b9ae85cfd905e06`
  - `corpus/lessons/round-22.md` — `f88d0d7e269db1d1e1077bb5a9dab3007a14387b17f06deb64c0cbac76ac0de4`
  - `corpus/QUALITY.md` — `dc2f5fe27935c3e238c0992cb14a4285bbee5edd902e2174b963561bcc84c09d`
  - `corpus/revision-audit.py` — `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977` (matches the private copy and frozen manifest)
  - `corpus/stamps.tsv` — `88bbe15bf708283e7ee2dc0b6eda15671bb0d4352d3a935a634001853a314a29`
  - `corpus/claim-ledger.tsv` — `87fed349b7086893ea0a554f99bf857077db921d19dac82c0f68525777c3989a`

## Fixture and execution

Used only the private fixture directory `/tmp/kagi-r22-w2-PinDropped`; no production inputs were written. The fixture has a synthetic local Git history commit `bc3e48d05e252a98ca17429ad4c19fa4d04542af`. Its historical `corpus/stamps.tsv` contained these two members:

```text
corpus/keep.md\t46fda6a7f2144e8dd447938b64a5bab278f60d80f5b21ae1981d38c38c60d8b2\t1\t13
corpus/dropped.md\t1dd18047565aa67f759816f6efa436d54a28511b6806ca26f17f89c579e131a4\t1\t24
```

The fixture worktree's current `corpus/stamps.tsv` contained only the `keep.md` row. `dropped.md` remained present, so the scenario isolates removal from the current membership set, not missing-file behavior. Fixture content and SHA-256:

| fixture object | bytes/lines | SHA-256 |
|---|---:|---|
| copied `corpus/revision-audit.py` | 20,857 / 548 | `ac19e186ce6f8e70ad6443058f0569222519d501a55106c813fa5f71ed1f8977` |
| historical `corpus/stamps.tsv` at the fixture commit | 173 / 2 | `4cfce15beaa0fa578ec9ddb59fd224bafc31e6f41be1d20246d527faa1625a73` |
| current fixture `corpus/stamps.tsv` | 85 / 1 | `188caa04bad8fc5dfb375e32e4faa57a812769da5c18a1b95b5cd8c710e3b6df` |
| `corpus/keep.md` (`keep fixture\n`) | 13 / 1 | `46fda6a7f2144e8dd447938b64a5bab278f60d80f5b21ae1981d38c38c60d8b2` |
| `corpus/dropped.md` (`historical-only fixture\n`) | 24 / 1 | `1dd18047565aa67f759816f6efa436d54a28511b6806ca26f17f89c579e131a4` |

Exact audit argv:

```text
python3 /tmp/kagi-r22-w2-PinDropped/corpus/revision-audit.py --root /tmp/kagi-r22-w2-PinDropped/fixture-root --history bc3e48d05e252a98ca17429ad4c19fa4d04542af
```

Observed stdout:

```text
DROPPED corpus/dropped.md
REVISION_AUDIT: DRIFT (stale=0 missing=0 dropped=1 added=0 invalid=0)
```

Observed stderr: empty. Exit: **1**.

## Finding, limits, handoff

The tested disappearance is reported as `DROPPED corpus/dropped.md`; the auditor returns `DRIFT`, not `CLEAN`, with no unrelated stale, missing, added, or invalid findings. **No false-clean in this bounded case.** No implementation change, tool installation, live-tree gate, host-private check, or calibration decision was made.

This synthetic one-member fixture does not establish that the full historical nine-member migration ledger is complete or correctly justified, and it does not audit current source truth or ledger expectation migrations. No correction is indicated for the exercised behavior. No blocker.

Parent-owned follow-up after all reports land: run the full read-only comparison against the frozen historical base on an isolated integrated-tree fixture (`python3 corpus/revision-audit.py --root <integrated-tree> --history c2cab35bc92e57e39e5489bac3386db078345b3f`) and reconcile every result with the recorded migration evidence; do not substitute this one-member result for the full round-22 freshness assessment.

## Files changed

- Report only: `.ufo/waves/round-22/falsify/RunPinDropped.md`.
- Private test data and copied implementation are confined to `/tmp/kagi-r22-w2-PinDropped`.
