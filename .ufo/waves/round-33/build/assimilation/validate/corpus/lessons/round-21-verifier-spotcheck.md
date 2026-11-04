# round-21 — non-author verification and spot-check (orchestrator, kaika)

Written by the integrator, not the lane (CORPUS.md: corrections and outside reviews are new
files; the lane owns `round-21.md`). Verifiers were fresh agents dispatched by the orchestrator
after the round landed at `e1544c194`; full reports are committed in the fleet repo at
`.ufo/waves/kaika-w3/kagi-review.md` and `kagi-critic.md`.

## Spot-check (LEARNING.md — at least one admit and one reject)

| decision | sample | verifier | result |
|---|---|---|---|
| admit | admits sampled: E1 (1Password Credential Broker / service accounts) and E3 (Vault/OpenBao token-versus-lease) — reviewer DISAGREES with both as landed (E1 omits who can use Credential Broker and conflates GitHub Actions public preview with custom-OIDC beta; E3 stretches one product's docs to the other) — errata were appended by the lane, but the admissions failed their own bar at landing | W3ReviewKagi | agree |
| reject | rejects sampled: S008 (SOPS README carries no lifecycle mechanics), 'Credential Broker removes every secret from CI' (S007 needs `OP_INTEGRATION_KEY`), 'a Vault KV read carries a lease' (S013: KV does not issue leases) — 3/3 agree | W3ReviewKagi | agree |

## Adjudication

REJECTED-HONEST-STOP. C1 verified: depth improved (the landed `--dotenv-bytes` arm re-ran clean on op 2.41.0, 6/6; ledger row R21-01; the 29-case pin corrected to 36; score 8→9). Capability verified: `sources-registry` (16 rows, every URL re-opened — 14 sha256 MATCH, S005/S006 drift; lane gate `corpus/sources-census.sh` CLEAN, selftest 47). Not admitted: C2 calibration does not verify as an axis move (counts of rows the lane wrote; score held 9; the discernment check it rests on was not done at landing) and C3's coverage admissions E1/E3 failed their own bar at landing — expansion/quality trade, which the rule forbids. Trends: expansion harmed (two admitted entries failed their bar; errata appended), quality improved (R12-02/R12-03/R13-01/R14-01 reconcile at head), discernment unchanged (0/2 admits agree, 3/3 rejects agree — becomes a lesson next round). Debts for round 22: turn the admit disagreement into a QUALITY criterion (follow feature-specific status links); E1 erratum distinguishing Actions public preview vs custom-OIDC beta; in-place rewrites of pinned `claim-ledger.tsv` rows and 9 deleted `stamps.tsv` lines need an append-only justification or restoration; five stale stamps.
