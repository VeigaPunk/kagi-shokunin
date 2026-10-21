# R11-10 identity-swap probe

## Baseline claim and membership

Scratch clone: `/fast/scratch/kagi-r24/seats/KagiR24.IdentR1110-2`, checked out at BASE `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105`.

`corpus/claim-ledger.tsv:24` claims `grep -cv '^#' corpus/state-shape.tsv` prints `22`; its note says the file has 22 rows and no blank lines, making that expression an exact row count. The note pins cardinality, not identities. At BASE the corresponding membership is the 22 non-comment TSV records at `corpus/state-shape.tsv:27-48` (tuple columns: path | kind | assertion | value):

```text
$STATE/xdg-data/opencode/opencode.db | sqlite | magic | SQLite format 3
$STATE/xdg-data/opencode/opencode.db | sqlite | mode | 600
$STATE/xdg-data/opencode/opencode.db | sqlite | size_min | 1
$STATE/xdg-data/opencode/opencode.db | sqlite | tables_min | 12
$STATE/xdg-data/opencode/opencode.db | sqlite | tables_required | session,message,part,event,account,credential,permission
$STATE/xdg-data/opencode/opencode.db | sqlite | rows_min | session:2
$STATE/xdg-data/opencode/opencode.db | sqlite | rows_min | message:13
$STATE/xdg-data/opencode/opencode.db | sqlite | rows_min | part:18
$STATE/xdg-data/opencode/opencode.db | sqlite | rows_min | event:79
$STATE/xdg-data/opencode/log/opencode.log | log | mode | 600
$STATE/xdg-data/opencode/log/opencode.log | log | size_min | 16384
$STATE/xdg-data/opencode/log/opencode.log | log | lines_min | 1
$STATE/client.lock | lock | mode | 600
$STATE/session-id | marker | mode | 600
$STATE/tac-daybreak-blue.json | json | mode | 600
$STATE/tac-daybreak-blue.json | json | keys | schema_version,custodian,receipt_path,receipt_sha256,registered_at,verification_method,evidence_scope
$STATE/xdg-cache/opencode/models.json | json | mode | 600
$STATE/xdg-cache/opencode/models.json | json | size_min | 65536
$HOME/.local/state/tac/handoff-status.json | json | mode | 600
$HOME/.local/state/tac/handoff-status.json | json | keys | schema_version,recorded_at,access_receipt,receipt_sha256,janitor_custody,commands,verification,janitor_provenance,future_l1_context_files,current_l1_relay,runner_capacity,boundaries,quiet_operation,temporary_smoke_files_removed
$HOME/.local/state/tac/daybreak-blue-access.json | json | mode | 600
$HOME/.local/state/tac/daybreak-blue-access.json | json | keys | schema_version,recorded_at,operator_statement,catalog_evidence,client_login_evidence,live_model_check,interpretation,prior_check_failures
```

## Mutant and execution

One count-preserving member rename in the scratch clone, `corpus/state-shape.tsv:40`:

```diff
-$STATE/session-id\tmarker\tmode\t600\tconversation id, not a credential (client.py chmod 0600 L61-63); mode unverified while absent
+$STATE/session-id.identity-swap\tmarker\tmode\t600\tconversation id, not a credential (client.py chmod 0600 L61-63); mode unverified while absent
```

The mutated file was stamped in BASE (`corpus/stamps.tsv:76`). A narrow `bash corpus/claim-ledger.sh stamp corpus/state-shape.tsv` exited 2 before mutation of the stamp set: `claim-ledger: refusing to shrink ... (existing 79 rows, new 1; pass --prune to accept)`. This is the stamp script's all-pinned-path preservation rule (`corpus/claim-ledger.sh:255-275`). Re-stamped the existing 79 paths, including the changed file, preserving the full membership; command exited 0 with `STAMPED: n=79`:

```sh
LC_ALL=C bash corpus/claim-ledger.sh stamp \
  LOG.md PROVINCE.md SCORECARD.md SHONEN.md SKILL.md \
  corpus/QUALITY.md corpus/README.md corpus/SOURCES.md corpus/adjacency.tsv \
  corpus/checklist-run.sh corpus/checklist.tsv corpus/claim-ledger.sh corpus/claim-ledger.tsv \
  corpus/closure-dispositions.json corpus/closure-dispositions.py corpus/drift-baseline.tsv \
  corpus/drift-pins.sh corpus/drift-symbols.tsv corpus/feature-claims.json corpus/feature-claims.py \
  corpus/fixtures/cells-hermetic/SCORECARD.md corpus/fixtures/cells-hermetic/claims.tsv \
  corpus/fixtures/cells-hermetic/corpus/adjacency.tsv corpus/fixtures/cells-hermetic/corpus/fx-ok.sh \
  corpus/fixtures/cells-hermetic/stamps.tsv \
  corpus/knowledge/adjacency-breadth.md corpus/knowledge/adjacency-scope.md \
  corpus/knowledge/cdp-bridge-1password.md corpus/knowledge/checklist-execution.md \
  corpus/knowledge/claim-ledger.md corpus/knowledge/config-layering.md \
  corpus/knowledge/control-plane-hardening.md corpus/knowledge/credential-isolation.md \
  corpus/knowledge/drift-gate.md corpus/knowledge/feature-bound-credential-review.md \
  corpus/knowledge/handler-on-disk-state.md corpus/knowledge/handler-trust-boundary.md \
  corpus/knowledge/janitor-command-surface.md corpus/knowledge/janitor-env-contract.md \
  corpus/knowledge/janitor-lifecycle.md corpus/knowledge/onepassword-machine-credentials.md \
  corpus/knowledge/op-cli-surface.md corpus/knowledge/op-env-refs.md corpus/knowledge/op-ref-consumption.md \
  corpus/knowledge/sops-age-key-rotation.md corpus/knowledge/substrate-deferral.md \
  corpus/knowledge/surface-census.md corpus/knowledge/tac-evidence-integrity.md \
  corpus/knowledge/transcript-hygiene.md corpus/knowledge/vault-openbao-token-lease-lifecycle.md \
  corpus/lessons/round-10.md corpus/lessons/round-11.md corpus/lessons/round-12.md \
  corpus/lessons/round-13.md corpus/lessons/round-14.md corpus/lessons/round-15.md \
  corpus/lessons/round-16.md corpus/lessons/round-17.md corpus/lessons/round-18.md \
  corpus/lessons/round-21-verifier-spotcheck.md corpus/lessons/round-21.md \
  corpus/lessons/round-22-source-errata.md corpus/lessons/round-22.md corpus/lessons/round-23.md \
  corpus/lessons/round-4.md corpus/lessons/round-5.md \
  corpus/lessons/round-6-aggregator-audit.md corpus/lessons/round-8-aggregator-box3-coldrun.md \
  corpus/lessons/round-8.md corpus/lessons/round-9.md corpus/op-ref-probe.sh \
  corpus/revision-audit.py corpus/scope-gate.sh corpus/source-fetches.tsv \
  corpus/sources-census.sh corpus/state-shape.tsv corpus/surface-census.sh \
  corpus/surface-census.tsv corpus/transcript-scan.sh
```

Final `git diff -- corpus/state-shape.tsv corpus/stamps.tsv` exited 0 and showed only the path rename above plus the fresh stamp row at `corpus/stamps.tsv:76` (old SHA-256 `abf9ca142221bf9ad5511ef951fe7998f019f9effc209492483ab4aed971ecac`, new `88aa69688ca4a87ba84ab541ed75e256e77a4aaedb2e9c1a0eb1d94e929f961b`; size 4567 → 4581 bytes). Thus stamp drift was not the cause.

Executed the ledger command on the mutant (captured status):

```sh
set +e; grep -cv '^#' corpus/state-shape.tsv; rc=$?; printf 'EXIT=%s\n' "$rc"
```

Output: `22`, `EXIT=0`; last command-output line `22`. **R11-10 SURVIVES**: the expected `^22$` still matches despite a member identity changing. Literal search for `corpus/state-shape.tsv` in the ledger found only R11-10's command at line 24; no other ledger command names this file, so no companion row was run. No host row was invoked.

## Identity selector proposal

For a `state-shape` selector, enumerate every line not beginning with `#` (same exact comment rule as the count command); reject empty/whitespace-only lines instead of ignoring them, since grep would count a blank as a phantom row and the note claims there are none. Require exactly five tab-separated columns. Define an operational member by columns 1-4 (path, kind, assertion, value); leave column 5 (prose note) out of identity. Preserve duplicate rows, serialize each member as those four raw fields joined by tabs and one LF, bytewise-sort the serialized records (`LC_ALL=C`), then SHA-256 the concatenated bytes. This makes file order/comments irrelevant while any active member/path replacement changes the digest. Count the accepted records separately; BASE must yield 22.

Using that precise selector, the unchanged BASE digest is `2ce4f677308d0a74b82b311e7e34db50b6b19983371d9362cbfe99dca74240cf`; the mutant digest is `3dc54f2d8e58b861fa696a9df57113f7b237b6204bd5b9f7368fe48fad7893e4` (both count 22). Thus the same BASE tree reproduces one fixed digest while the rename is caught. `corpus/row-identity.sh` is absent from the BASE corpus inventory; these are proposal-calculation digests, not output from that reader.

## Residual risk and verification gaps

- LSP is not mounted: `read xd://lsp` returned “No such tool”. No definition/references/diagnostics check was available. The path search above is literal-only and is not semantic proof of indirect callers.
- Only R11-10 was exercised, as required by the exact-path ledger search; no broad ledger verify, host row, build, lint, or test was run.
- No tools were installed or updated.
