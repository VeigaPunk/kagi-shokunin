# Round 44 — controls-receipt corrections register

The round-43 verifier spot-check (item 3) and the committed receipt
`.ufo/waves/round-43/controls/c2-manifest-rederive-base.txt` disclose three round-42-era
control receipts that do not re-derive as committed. Corrections are new records, never
rewrites (fleet `CORPUS.md`; registry rule 2 per S094): the filed bytes under
`.ufo/waves/round-42/controls/` are untouched; this register supersedes their reading and
names, per row, the committed value, the re-derived value (re-executed by
`plans/round-44-c3.sh` at the pinned revision), and the superseding record.

Basis: S099 (fleet repo `.ufo/prompts/kagi-round-44.md` at fleet commit 75dd2612, §9 Claim
sizing) — the claim is judged on the counter, kill rule and predicate declared before data;
these rows are the declared before-values, and the row-level legs re-execute them.

| receipt | committed | re-derived | re-derive-at | via | disposition |
|---|---|---|---|---|---|
| .ufo/waves/round-42/controls/c1-base.txt | 4 | 5 | 5f3566c4cfe65a74da4d201d74d28b403929807b | plans/round-42-controls.sh | superseded-by: .ufo/waves/round-43/controls/c2-manifest-rederive-base.txt |
| .ufo/waves/round-42/controls/c2-base.txt | 0 | 1 | 5f3566c4cfe65a74da4d201d74d28b403929807b | plans/round-42-controls.sh | superseded-by: .ufo/waves/round-41/controls/c2-base-19025d9.txt |
| .ufo/waves/round-42/controls/c2-worktree-at-base.txt | 3 | — | 5f3566c4cfe65a74da4d201d74d28b403929807b | none | not-written-by-any-committed-runner (sweep: git grep c2-worktree-at-base 5f3566c4cfe65a74da4d201d74d28b403929807b -- plans/*.sh corpus/*.sh prints nothing) |
