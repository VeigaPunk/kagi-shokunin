# kagi round 21 — declared claims, ownership, pre-allocated sources

Steered round 21 (fleet-ledger `.ufo/waves/kaika/steer.md`, kagi row). Base
`aea7a4301034aa9160ada69457a6427f77064169`, branch `kaika/round`, worktree
`/home/vgpnk/Projects/shokunin/.tower/worktrees/kaika/kagi-shokunin`.
Host `op --version` → `2.41.0` (2026-10-19; round 20 measured 2.40.0).

## Claims (1–3, distinct axes, causally separable)

| id | axis / type | move | before (at `aea7a43`) | after target |
|---|---|---|---|---|
| C1 | depth (lowest, 8) | admit the landed `--dotenv-bytes` arm: re-measure on op 2.41.0, ledger row, selftest pin corrected, byte-fidelity section in `knowledge/op-ref-consumption.md` | `grep -c 'DOTENV_BYTES' corpus/claim-ledger.tsv` → 0; R12-02 pins 29 cases; `grep -c 'DOTENV_OBS' corpus/knowledge/op-ref-consumption.md` → 0; probe stamp `660 28660` vs file `788 34362` | R21-01 row (CLEAN checks=6, exit 0); R12-02 pins 36; 6 `DOTENV_OBS` ids; stamp = HEAD sha |
| C2 | calibration (9) | mine own mistakes into `corpus/lessons/round-21.md` `## Mistakes`; append one `QUALITY.md` criterion per unlearned class, each citing its lesson; regenerate `SHONEN.md` canonical (author `[x]` → `[~]`) | 0 mistake rows; 0 mistake-derived criteria; `grep -c '^- \[x\]' SHONEN.md` → 4 (lane-dispatched verifiers = author attestation) | 8 rows (M1–M8), 7 captured-by a criterion; `[x]` → 0 |
| C3 | capability + coverage (9) | `corpus/SOURCES.md` per contract v1 + `corpus/sources-census.sh` gate; admit 3 entries on uncovered ground citing `mined` rows; README `## Frontier` | `test -e corpus/SOURCES.md` → 1; capabilities rows 0; knowledge 21; `## Frontier` 0 | census clean; capability row 1; knowledge 24; Frontier 1 |

Prerequisite (contract repair D1, not a claim): `corpus/QUALITY.md` §Admission
bar QA1–QA8, written by the L1 before dispatch. C2 appends a separate section;
C3 reads only §Admission bar. C1 touches neither.

## Pre-allocated source ids (rows written only after re-opening, rule 1)

| id | source | entry |
|---|---|---|
| S001 | https://www.1password.dev/cli/secrets-scripts | E1 |
| S002 | https://www.1password.dev/connect | E1 |
| S003 | https://www.1password.dev/connect/get-started | E1 |
| S004 | https://www.1password.dev/service-accounts/security | E1 |
| S005 | https://1password.com/product/credential-broker | candidate reject (product page) |
| S006 | https://1password.com/blog/1password-credential-broker-public-preview | E1 |
| S007 | https://www.1password.dev/brokered-access | E1 |
| S008 | https://raw.githubusercontent.com/getsops/sops/main/README.rst | E2 |
| S009 | https://getsops.io/docs/usage/identities/age/ | E2 |
| S010 | https://getsops.io/docs/usage/identities/key-groups/ | E2 |
| S011 | https://getsops.io/docs/usage/key-management/ | E2 |
| S012 | https://developer.hashicorp.com/vault/docs/auth/jwt | E3 |
| S013 | https://developer.hashicorp.com/vault/docs/concepts/lease | E3 |
| S014 | https://openbao.org/docs/auth/jwt/ | E3 |
| S015 | https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/ | E3 |
| S016 | https://openbao.org/docs/concepts/tokens/ | E3 |

If a URL no longer resolves or the quoted mechanism is gone, the row is
`rejected` with reason and flip — never silently dropped, never re-pointed to
a different id.

Entries: E1 `corpus/knowledge/onepassword-machine-credentials.md`,
E2 `corpus/knowledge/sops-age-key-rotation.md`,
E3 `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`.

## File ownership (disjoint)

| owner | files |
|---|---|
| ExecDepth | `corpus/claim-ledger.tsv`, `corpus/knowledge/op-ref-consumption.md`, the `29 cases` mentions in `SKILL.md` and `PROVINCE.md` |
| ExecSources | `corpus/SOURCES.md`, E1, `corpus/README.md` |
| ExecEntries | E2, E3 |
| ExecGate | `corpus/sources-census.sh` |
| Scribe | `corpus/lessons/round-21.md` (`## Mistakes` only), `corpus/QUALITY.md` (append below §Admission bar only), `SHONEN.md` |
| L1 | `corpus/stamps.tsv`, `LOG.md`, `SCORECARD.md`, `PROVINCE.md` appended section, `SKILL.md` registry row + SOURCES pointer, `round-21.md` `## Gate`, ledger rows R21-02/R21-03 |

Read-only: planner, connector, scout, reviewer, critic, sentinel.

## Deviations recorded at landing

- C2 targets moved with the evidence: the scribe mined 12 classes (M9–M12 found beyond the dossier's eight), so 11 criteria, not 7; the honest stop keeps no criterion.
- S005 opened as a tier-C `queued` lead (rejected as mechanism support, not as a row); S008 is the rejected row (the SOPS README is now a pointer stub).
- All executor seats hit provider limits; the ExecDepth slice (ledger rows, entry §11, `PROVINCE.md` count) was finished by the L1, and the ledger reconciliation (`R12-03`, `R13-01`, `R14-01`, `R21-02`–`R21-04`) stayed with the L1.
- The `SKILL.md` change is two decision-table rows plus count corrections, not a registry row: the lane keeps no gate-registry table to add one to.
