# R22-03 identity-swap probe

## Claimed membership

Scratch checkout: `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24/seats/IdentR2203` followed by `git -C /fast/scratch/kagi-r24/seats/IdentR2203 checkout -q 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`; both succeeded and `rev-parse HEAD` returned the requested BASE.

`corpus/claim-ledger.tsv:57` says R22-03 audits current bytes/pointers against its immutable history membership: retain all 63 original stamps and have 16 reviewed additions, seven attributed to round 22 and nine to round 23. The command's exact history selector is `c2cab35bc92e57e39e5489bac3386db078345b3f`. At BASE, the 16 `ADDED` path members were:

- `corpus/closure-dispositions.json`, `corpus/closure-dispositions.py`
- `corpus/feature-claims.json`, `corpus/feature-claims.py`
- `corpus/fixtures/cells-hermetic/SCORECARD.md`, `corpus/fixtures/cells-hermetic/claims.tsv`, `corpus/fixtures/cells-hermetic/corpus/adjacency.tsv`, `corpus/fixtures/cells-hermetic/corpus/fx-ok.sh`, `corpus/fixtures/cells-hermetic/stamps.tsv`
- `corpus/knowledge/feature-bound-credential-review.md`
- `corpus/lessons/round-21-verifier-spotcheck.md`, `corpus/lessons/round-22-source-errata.md`, `corpus/lessons/round-22.md`, `corpus/lessons/round-23.md`
- `corpus/revision-audit.py`, `corpus/source-fetches.tsv`

The row's “63 + 16” describes path membership (79 stamp rows), not merely 79 as an unlabelled count. `revision-audit.py:366-371` computes the two path-set differences; `:373-393` checks the current fingerprints and derives exit status. Its ledger expectation only tests the summary counts (`corpus/claim-ledger.tsv:57`).

## Mutant and row results

Before mutation, both ledger commands passed: `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` exit 0, last line `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=16 invalid=0)`; `python3 corpus/revision-audit.py --selftest` exit 0, last line `REVISION_AUDIT_SELFTEST: PASS (cases=17 failed=0)`.

One count-preserving swap in the scratch clone: replace the `corpus/feature-claims.json` record in `corpus/stamps.tsv:19` with `corpus/lessons/round-19-recensus.md`, fingerprinted as `2fda99235b52f40fbe2b831c44ebd781e9d4493816bca290153a20de1e6addd9`, 49 LF lines, 3738 bytes. The replacement is a tracked path present in the history tree and was not in the history stamp membership. Only `corpus/stamps.tsv` changed; its row count remained 79. That file has no self-stamp entry, so I did not run the stamp command.

```diff
-corpus/feature-claims.json\ta66acbfb57181bc12582e5e7b33510e74415fb7bfa80a08ea76d240138449b\t1000\t48164
+corpus/lessons/round-19-recensus.md\t2fda99235b52f40fbe2b831c44ebd781e9d4493816bca290153a20de1e6addd9\t49\t3738
```

After mutation, `python3 corpus/revision-audit.py --history c2cab35bc92e57e39e5489bac3386db078345b3f` exited 0; last line: `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=16 invalid=0)`. Its `ADDED` output replaces `corpus/feature-claims.json` with `corpus/lessons/round-19-recensus.md`; the count remains 16. **R22-03 SURVIVES** the identity swap.

The only other ledger row whose command names `corpus/revision-audit.py` is R22-04 (`corpus/claim-ledger.tsv:58`; no host row): `python3 corpus/revision-audit.py --selftest` exited 0; last line: `REVISION_AUDIT_SELFTEST: PASS (cases=17 failed=0)`. **R22-04 SURVIVES**; its note describes isolated fixtures, not live stamp membership.

## Proposed R22-03 identity selector

For selector `R22-03`, strictly parse all data records in the current `corpus/stamps.tsv` and in `git show c2cab35bc92e57e39e5489bac3386db078345b3f:corpus/stamps.tsv`. Select only column 1 (the path) and compute current-paths minus history-paths. Do not include columns 2–4: this selector is for membership identity, while the audit separately checks file fingerprints. Sort the selected ASCII paths bytewise under `LC_ALL=C`, independent of file order. This is a headerless strict TSV: reject blank lines, comments, malformed records and duplicate paths; do not silently skip or normalize them (consistent with `revision-audit.py:85-140`).

Canonical hash bytes proposed: `ROW-IDENTITY-v1\0R22-03\0ADDED\0` followed by every sorted path and one LF. SHA-256 over those bytes yields `count=16 sha256=4a1637e41ae2a90a8e050b78b977ee274bf6e6338aa983f8d4685cc00c393ecd` for the unchanged BASE tree. The tested mutant yields `count=16 sha256=38fe0f14d55de3594338b707b6c9f9c4145378c0cd29afa48cca436d585900e5`; pinning the BASE count and digest would therefore kill this swap while keeping an unchanged tree reproducible.

## Residual risk and verification gaps

This probe demonstrates one identity substitution; it does not exhaust other malformed-input or reordering mutations. The row-identity reader is not present in this BASE and was not implemented or tested here; its strict parser and pinned digest need implementation-side tests. No host/private row was run and no tool was installed.