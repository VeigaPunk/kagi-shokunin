# R59SentinelTrial — w1 report (security audit: transit trial + round-59 artifacts)

Lane kagi, round 59 attempt 1, claim BASE `5fa6e658…`, frozen predeclaration `af7b6651`
(`plans/round-59.md`). Seat scope held: read-only on the lane; the only writes are this report,
`build/R59SentinelTrial/audit.md` and the receipts beside it; no commits.

## Audited bytes

| artifact | sha256 |
|---|---|
| `corpus/openbao-transit-trial.sh` | `e11e98f6cfc924131a52713fa496481e80efb89ffcdb9b6bc47b3234d8cc3e01` |
| `plans/round-59-c2.sh` | `454a4177dcb6ae2dedd367b9409358b45a25fbac0692b5c3c05510d1ac6c525c` |
| `plans/round-59-controls.sh` | `0d8647a0b6cce42a287e6f3faf074a0524b8b1c10273045a401790d9abb7fa96` |
| `bao` | `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (v2.7.2) |

HEAD was `af7b6651` at audit time; the artifacts above are the working-tree bytes the L1 commits.

## Verdicts (one row per assigned check; full commands, raw output and recipes in `audit.md`)

| # | check | verdict |
|---|---|---|
| 1 | secret shapes over every `.ufo/waves/round-59/` file and the trial (`hvs.`/`hvb.`, `r59-`+24 hex, PEM, token assignments) | **CLEAN** — `hv`/PEM/token-assign = 0; the one `r59-`+24-hex hit is the reviewer's deliberate synthetic mutation fixture (`R59ReviewerCounters/mkc2.sh:31`, sequential placeholder, labelled "secret scan must bite"), not a captured token or the trial's marker; `X-Vault-Token` only as the docs placeholder `...` |
| 2 | fetch receipts carry no cookie value (QM72) | **CLEAN** — no `Cookie:`/`Set-Cookie:` lines; QM72 removal note in both files; correlation ids replaced |
| 3 | no secret/plaintext on any argv | **CLEAN** — 3103-line execve trace + 42-call PATH wrapper: 0 token/plaintext/ciphertext/context entries; data rides stdin JSON, token rides env |
| 4 | server confinement | **CLEAN** — `setpriv --pdeathsig KILL`, `-dev-listen-address=127.0.0.1`, port checked against own pid; SIGKILL of the trial shell reaped its server (`ORPHAN=no`), no leftovers |
| 5 | ambient `BAO_*`/`VAULT_*` cannot change a reading | **CLEAN** — counter legs all under `env -i`; hostile-env counter `value=5 … guard=1` rc 0; trial output byte-identical to the clean run |
| 6 | scratch confinement | **CLEAN** — 0 write-mode opens under the lane, 37 under `--work`; copied tree and counter `--tree` manifests unchanged |
| 7 | no key material on disk | **CLEAN** — cleanup-disabled probe: one 178-B error-text file (mode 600 in a 700 dir), 0 secret/key shapes; receipts carry no ciphertext value |

**Findings: none.** Ceilings and hardening notes C1–C9 are in `audit.md`; the security-relevant ones:

- The printed `TRIAL CLEANROOM` line is refusal-only (no error-text assertion). Independence is evidenced by two
  distinct server pids/ports (non-author probe: cross-server decrypt rc=2, `* encryption key not found`) and the
  executor's driver receipt.
- The counter's `value=5` is output consistency, not execution proof (R59CriticClaims Q1-C2); execution is
  evidenced by my non-author runs and the receipts, not by the counter.
- The counter's K3 scan covers captured stdout/stderr, not the trial's self-deleted work dir; my cleanup-disabled
  probe covers the real trial.
- Trial `bao` is PATH-resolved and not sha-pinned (declared D4/K2); the counter enforces the 2.7.2 pin.
- The revenger's probe transcripts record fixed, declared non-secret fixture plaintext on argv; no token and not
  the trial's marker.
- **C10 (LOW, operability, not a secret leak)** — `R59ReviewerCounters/mkc2.sh:31` embeds a nonce-shaped
  synthetic literal (sequential 24-hex) for its A7 mutation, so a whole-tree secret scan of the wave will hit
  it; the same file assembles its A6 token prefix at runtime. Fix: generate the A7 nonce at runtime (the
  counter's regex only needs the shape), removing the literal without weakening the mutation.
- Counter scratch is predictable `${HYAKU_SCRATCH}/…/c2-counter.$$` with default umask (logs 644); no secret is
  printed. Hardening: `umask 077` + `mktemp -d`.

## Non-author probes run

Two independent real trial runs (clean and hostile env, identical output), execve argv trace, PATH-wrapper argv
log, SIGKILL-at-A and SIGKILL-at-2.5 s orphan probes, write-syscall trace, copied-tree and counter-tree manifest
checks, cleanup-disabled work-dir inspection, and an independent two-server clean-room refusal.

Evidence: `.ufo/waves/round-59/build/R59SentinelTrial/` (`audit.md`, `scan-secrets.txt`, `final-scan.txt`,
`fetch-headers.txt`, `argv-hygiene.txt`, `confinement-runtime.txt`, `ambient-env.txt`, `scratch-confinement.txt`,
`key-material.txt`). Scratch deleted before yield; no tool installed or upgraded.

SEAT-STATUS: complete
