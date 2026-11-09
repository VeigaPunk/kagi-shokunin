# corpus/README.md — proposed coverage-map row and count changes (round 71)

Proposal, not an edit.

## 1. Coverage-map row

Insert after the round-70 row `| OpenBao PKI certificate lifecycle (executed) | …; round 70 |`
(corpus/README.md line 95). Exact shape of that row: `| Area | Entry + trial | what it measures … | round |`.

| OpenBao PKI issuer and revocation channels (executed) | `knowledge/openbao-pki-issuer-revocation-channels.md` + `corpus/openbao-pki-issuer-trial.sh` | issuer `leaf_not_after_behavior` clipping (`truncate`), per-issuer CRL routing for a non-default `issuer_ref`, token-less OCSP `revoked`/`good`, proof-of-possession revocation of a `no_store` leaf — four verdicts on OpenBao 2.7.2 each flipped by a falsifier shim (`plans/round-71-c1.sh`) and each public artifact re-checked with openssl; S173 opened 2026-11-08 (S170 re-opened); round 71 |

Admission condition: this row lands only with the round-71 counter reading at `value=4`
(plan kill rule: `value < 4` means C1 missed, and then no coverage row is entered).

## 2. Counts that change, with the live numbers read at candidate `39e76bc`

Read-only counts are in `counts-readonly.txt` in this directory (commands listed there).

| README line | Current text | Live at candidate | Proposed text | Bound by |
|---|---|---|---|---|
| 65 `Revision stamps (data)` | `177 rows (round 70: …)` | 178 data rows (`grep -cv '^#' corpus/stamps.tsv`); the freeze `1199295` read 177 | `178 rows (round 71: the live count was 177 at the freeze; the candidate adds the new entry's pin) …` — **but** see corrections: trial, counter and controls runner are not pinned, so the final integer depends on the stamp decision; re-read `claim-ledger.sh verify` `stamped=` at integration | `RD-STAMPS` (`ledger:R12-03`) |
| 67 `Knowledge-entry declarations (data)` | `47 row-linked / 3 by-hand / 50 pinned` | 51 files in `corpus/knowledge/*.md` (was 50 at round 70); the new entry is row-linked to `R21-02` | `48 row-linked / 3 by-hand / 51 pinned (round 71: the OpenBao PKI issuer and revocation-channels entry is row-linked to R21-02 and pinned; …)` | `RD-DOCS-ROWLINKED`, `RD-DOCS-BYHAND`, `RD-DOCS-ENTRIES` (`ledger:R14-01`) |

No other README count changes:
- Ledger rows: `corpus/claim-ledger.tsv` non-blank lines stay 120 at candidate, so the README
  `102 rows` statement and the claim count stay at 102 (unchanged).
- Registry: README names no registry count (it links `corpus/SOURCES.md` only). The registry grows
  163 → 164 (grep `^ {0,3}\| *S[0-9]{3}`), which SCORECARD carries, not README.
- The round-71 lesson row does not exist yet (`corpus/lessons/round-71.md` is not in the candidate);
  no lesson row is drafted.
