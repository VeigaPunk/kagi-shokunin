# R12-03 C3 identity-swap probe

## Result
- Scratch clone: `git clone -q --no-hardlinks /home/vgpnk/Projects/shokunin/kagi-shokunin /fast/scratch/kagi-r24/seats/IdentR1203 && git -C /fast/scratch/kagi-r24/seats/IdentR1203 checkout -q 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105 && git -C /fast/scratch/kagi-r24/seats/IdentR1203 rev-parse HEAD` returned `4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105` (exit 0).
- BASE `corpus/claim-ledger.tsv:28` (R12-03) says the pin membership is the original 63 retained entries plus seven round-22 and nine round-23 additions; the nine are described as five fixture files, closure script/records, source-fetches, and the round-23 lesson. It clarifies the outside-verifier artifact was pre-existing but unstamped, and that this is pointer membership, not source currentness (79 entries total).
- Literal search for `corpus/stamps.tsv` in the BASE ledger found only R12-03; no other ledger row names that file. This row is not host-tagged; no host row was run.

## Mutant and row result
- In the clone, changed only `corpus/stamps.tsv:64`:
  ```diff
  -corpus/lessons/round-23.md  f33abe81ce24ef4115d295b7fadf208a4c159dcc6d493983f68f6d581c01d728  235  18244
  +plans/round-23.md           cb1287ba303a26942b94094be26751b8d86cc967deb49dfcddb25afee6b007ac  49   3490
  ```
  (Tabs separate columns.) The replacement is a real, previously unlisted path with its measured SHA-256, line count, and byte count. Exactly one membership key was replaced; the number of nonblank rows stayed 79. `corpus/stamps.tsv` is not itself a path in its stamp inventory (literal search found no `^corpus/stamps.tsv<TAB>` entry), so no restamp was needed.
- BASE count: `git show 4f94b52a3cdfaa289d779bd8a2afcd0b1fcd9105:corpus/stamps.tsv | grep -c '[^[:space:]]'` → last line `79`, exit 0.
- Mutant R12-03 command, `grep -c '[^[:space:]]' corpus/stamps.tsv` → last line `79`, exit 0 — **SURVIVES**. The count-only row does not detect the identity swap.

## Identity selector recommendation
For a `stamps` selector, parse `corpus/stamps.tsv`; ignore whitespace-only lines and comment lines whose first non-whitespace character is `#`. Every other line must have exactly four TSV fields and a nonempty path in column 1; reject duplicate paths. Hash only the exact column-1 path bytes (the claimed pointer identities), not the SHA/line/byte columns, so this stays a membership check rather than a source-currentness claim. Sort keys bytewise under `LC_ALL=C`, preserve each key (do not `uniq`), serialize each with one LF, and SHA-256 the resulting byte stream. This is independent of file order and harmless blank/comment lines, while a path substitution changes the digest.

Using that canonicalization on BASE gives 79 keys and `sha256=2163410b5a8cd53853ce835add13e3b96ae489aab44b280d5f6d03bf5ba9793b`; the mutant gives `sha256=e107de808a9ba3698cb66e8539756ba97b9fa99128cc0fd2a763bdfd511a27c4`. Thus an unchanged BASE tree reproduces one fixed digest and this count-preserving swap is caught by an identity row.

## Residual risk / verification gap
`read xd://lsp` returned “No such tool” and listed no LSP device, so references/definition/diagnostics were unavailable; the ledger lookup was literal search only, not semantic proof. No tools were installed or updated.