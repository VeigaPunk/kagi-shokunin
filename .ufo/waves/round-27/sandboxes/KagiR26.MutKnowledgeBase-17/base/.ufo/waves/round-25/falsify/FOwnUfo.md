# FOwnUfo — `.ufo` ownership heuristic

Revision: `82745e2c60e726b49499b8f309529935dc4eff2b` (BASE `4587c61a348e4528717404a68912c373f3ef4d03`). Confirmed in the isolated clone with `git rev-parse HEAD`.

Axes: calibration (expected class vs observed class), operability (real `citations` argv and captured exit), freshness (frozen candidate checked out, no working-tree substitution). Fixtures were under `/fast/scratch/kagi-r25/FOwnUfo-4/fixtures/lane`; this lone root had `.ufo/waves/round-25/`, lacked its cited files, and had no fleet-root markers in its parent. Each command ran from the frozen clone with `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FOwnUfo-4/home`.

## Probes

**PASS — absent file directly under an existing lane-owned round directory should remain UNRESOLVED.**

```text
argv: env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FOwnUfo-4/home bash corpus/claim-ledger.sh citations --root /fast/scratch/kagi-r25/FOwnUfo-4/fixtures/lane --docs /fast/scratch/kagi-r25/FOwnUfo-4/fixtures/lane/corpus/existing-owned-dir.md
stdout:
UNRESOLVED corpus/existing-owned-dir.md:1 .ufo/waves/round-25/missing.md (ufo)
CITATION_LAYOUT: lone-clone fleet_absent=0 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: BROKEN (cites=1 docs=1 unresolved=1 ephemeral=0 labeled=0)
exit: 1
```

**FAIL — missing nested directory beneath that owned round directory must not become FLEET-ABSENT.**

```text
argv: env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FOwnUfo-4/home bash corpus/claim-ledger.sh citations --root /fast/scratch/kagi-r25/FOwnUfo-4/fixtures/lane --docs /fast/scratch/kagi-r25/FOwnUfo-4/fixtures/lane/corpus/nonexistent-nested-dir.md
stdout:
FLEET-ABSENT corpus/nonexistent-nested-dir.md:1 .ufo/waves/round-25/nonexistent/missing.md (ufo)
CITATION_LAYOUT: lone-clone fleet_absent=1 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: INCOMPLETE (cites=1 docs=1 unresolved=0 ephemeral=0 labeled=0 fleet_absent=1)
exit: 3
```

**PASS — absent shared top-level `.ufo/waves/round-1.json` is classified fleet-only in a lone clone.**

```text
argv: env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FOwnUfo-4/home bash corpus/claim-ledger.sh citations --root /fast/scratch/kagi-r25/FOwnUfo-4/fixtures/lane --docs /fast/scratch/kagi-r25/FOwnUfo-4/fixtures/lane/corpus/shared-wave-root.md
stdout:
FLEET-ABSENT corpus/shared-wave-root.md:1 .ufo/waves/round-1.json (ufo)
CITATION_LAYOUT: lone-clone fleet_absent=1 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: INCOMPLETE (cites=1 docs=1 unresolved=0 ephemeral=0 labeled=0 fleet_absent=1)
exit: 3
```

## Finding and limits

**Severity: MINOR** — classification/diagnosis defect; the tested paths still exit nonzero (1 or 3), so no clean-pass bypass is demonstrated.
Concrete falsifier: `corpus/claim-ledger.sh:704-719` classifies `.ufo/` misses using only whether the exact parent directory `$ROOT/.ufo/$d` exists (`d` is the immediate directory containing the cited file). For the nested miss, `d=waves/round-25/nonexistent`; its absence causes `fleet_only_token` to return true despite the existing owned ancestor `.ufo/waves/round-25`. Result: lone-clone citations are INCOMPLETE rather than exposing this lane-local missing citation as UNRESOLVED/BROKEN. The direct-child and shared-top-level controls behave as expected.

LSP status was unavailable: attempted `read xd://lsp`, which returned “No such tool” and listed mounted devices without LSP. No grep output is used as semantic proof; classification above is from executed gate output. **UNRUN:** full `--selftest`, real-tree `citations`, `verify`, `cells`, and a fleet-layout counterpart. No production files were changed except this assigned report; no tools installed.
