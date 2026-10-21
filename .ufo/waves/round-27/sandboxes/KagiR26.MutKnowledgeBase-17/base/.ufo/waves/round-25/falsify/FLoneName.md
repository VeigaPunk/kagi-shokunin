# Round 25 C2 — directory-name independence

- **Axes:** calibration (C1), operability (C2), freshness (C3). This probe tests C2 only.
- **Candidate:** `82745e2c60e726b49499b8f309529935dc4eff2b`.
- **BASE control:** `4587c61a348e4528717404a68912c373f3ef4d03`.
- **Result:** PASS — no directory-name-dependent citation count or final summary on the candidate. No concrete falsifier observed.

## Isolated setup and runs

The two candidate clones were `.../parents/x-parent/x` and `.../parents/kagi-parent/kagi-shokunin`; BASE clones were `.../parents/base-x-parent/x` and `.../parents/base-kagi-parent/kagi-shokunin`, all below `/fast/scratch/kagi-r25/FLoneName`. Parent-marker checks printed `marker-free parent hierarchy: PASS` and `baseline marker-free parents: PASS` (both commands exit 0). Each clone was made with `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin <path> && git -C <path> checkout -q <revision> && git -C <path> rev-parse HEAD`; each printed its requested hash. No package/tool install or update.

For each clone, from its clone root, the exact invocation was:

```text
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/FLoneName/home bash corpus/claim-ledger.sh citations
```

Candidate `x` (stdout excerpt; exit 3):

```text
CITATION_LAYOUT: lone-clone fleet_absent=48 (no fleet-root entry or sibling lane beside the root; fleet-only citations were not checked)
CITATION_GATE: INCOMPLETE (cites=1624 docs=68 unresolved=0 ephemeral=0 labeled=19 fleet_absent=48)
```

Candidate `kagi-shokunin` printed the same two summary lines and exited 3: `unresolved=0`, `fleet_absent=48`, `cites=1624`, `docs=68`, `labeled=19`. The detailed `FLEET-ABSENT` records also matched in the observed outputs.

BASE `x` (stdout summary; exit 1): `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=88 ephemeral=0 labeled=25)`.
BASE `kagi-shokunin` (stdout summary; exit 1): `CITATION_GATE: BROKEN (cites=1371 docs=67 unresolved=46 ephemeral=0 labeled=18)`.
BASE has no `FLEET-ABSENT` summary; 88 vs 46 are its unresolved counts. The 42-count delta is present in BASE-x output as `UNRESOLVED ... kagi-shokunin/...` self-paths (e.g. `LOG.md:873`, `corpus/lessons/round-1-aggregator-seed.md:20`); BASE-kagi resolves those names against its own basename. Candidate resolver lines `corpus/claim-ledger.sh:668-674` explicitly resolve `kagi-shokunin/*` under `$ROOT` first, independent of root basename.

## Falsifier and limits

A candidate difference between `x` and `kagi-shokunin` in unresolved/FLEET-ABSENT counts or final gate summaries would falsify name independence; none occurred. BASE reproduces the former 88-vs-46 behavior, consistent with the 42 self-reference cause. Scope is only these two names, separate marker-free parents, these two revisions, and the `citations` command. `verify`, selftests, other parent-marker layouts, C1, and C3 were **UNRUN**. No `lsp` device/status route was exposed: LSP status/references/definition/diagnostics were **UNRUN**; literal search was used only on captured BASE stdout to locate the self-path examples, not as semantic proof.