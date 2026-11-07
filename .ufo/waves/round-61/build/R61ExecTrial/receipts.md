# R61ExecTrial — receipt index (round 61, C2 seal trial)

Trial: `corpus/openbao-seal-trial.sh`, 1123 lines,
sha256 `a3bc882597ccaebca66d23d5a76cf6a6d4810822fe774f43ff2dace8cb60b535`.
Binary: ambient `bao` resolved through PATH = OpenBao v2.7.2
(9e0a0d3c3504a0a00b45e61355afac5e35c78379) — the trial reports `bao=<ver>`
and owns no pin (the counter/battery owns the pin, per plans/round-61.md).
All runs on throwaway servers bound to 127.0.0.1 under
`setpriv --pdeathsig KILL`, work dirs under the seat scratch, each run's
per-run directory `rm -rf`'d by the trial's EXIT trap.

T5 config condition (reproducibility): both T5 servers run the DEFAULT
config — no `disable_unauthed_rekey_endpoints` stanza — under which the
rekey route is unmounted and `operator rekey -init` exits non-zero with
HTTP 405 `unsupported operation` before any token check (measured on both
the raft and the inmem server in every run below).

| receipt | invocation | verdict (last lines) | rc |
|---|---|---|---|
| `receipt-real-1.txt` | `bash corpus/openbao-seal-trial.sh --work <scratch>/run1` | `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2`; T1–T5 all HOLDS; T2 carries `progress=1/3`, duplicate `progress=1/3`, `progress=2/3`, `sealed=false t=3 n=5` | 0 |
| `receipt-real-2.txt` | same, independent run (`--work <scratch>/run2`) | byte-identical to real-1 | 0 |
| `receipt-shim-SH1.txt` | `KAGI_SEAL_SHIM=SH1` | `BROKEN holds=4 broken=1`; vector BHHHH — only `T1 BROKEN shares=0` | 1 |
| `receipt-shim-SH2.txt` | `KAGI_SEAL_SHIM=SH2` | `BROKEN holds=4 broken=1`; vector HBHHH — only `T2 BROKEN` | 1 |
| `receipt-shim-SH3.txt` | `KAGI_SEAL_SHIM=SH3` | `BROKEN holds=4 broken=1`; vector HHBHH — only `T3 BROKEN auth503=0` | 1 |
| `receipt-shim-SH4.txt` | `KAGI_SEAL_SHIM=SH4` | `BROKEN holds=4 broken=1`; vector HHHBH — only `T4 BROKEN dec=0` | 1 |
| `receipt-shim-SH5.txt` | `KAGI_SEAL_SHIM=SH5` | `BROKEN holds=4 broken=1`; vector HHHHB — only `T5 BROKEN mem405=0` | 1 |
| `receipt-nobao.txt` | `env -i PATH=/nonexistent-r61-no-bao-here /usr/bin/bash trial --work <scratch>/nobao` | `OPENBAO_SEAL_TRIAL: SETUP no bao on PATH`; zero TRIAL/HOLDS lines | 2 |
| `receipt-selftest.txt` | `bash trial --selftest --work <scratch>/selftest-work` | `SEAL_SELFTEST: PASS (cases=63)` — stub-bao harness, no OpenBao binary, no network | 0 |
| `receipt-selftest-mutant.txt` | mutated copy (scratch only): `shim_flip` SH1 rerouted to flip T2's `dup` flag | `FINDING F-STUB-SH1-VEC`, `FINDING F-SHIM-MATRIX`, `SEAL_SELFTEST: FAIL (cases=63 failed=2)` | 1 |

Shim vector line: `sh1=BHHHH sh2=HBHHH sh3=HHBHH sh4=HHHBH sh5=HHHHB`
(baseline HHHHH — both real receipts).

Secret discipline attestation: every receipt above carries flags, counts,
lengths and http codes only. No unseal share, root token, OTP or nonce value
appears in any receipt; the trial prints none and removes its per-run work
directory on exit (init payload, header files, server logs, raft storage and
stub state never outlive a run).

T4 detail fields in the receipts (shapes, not secrets): `tlen` = decoded
token length (26 incl. the `s.` prefix), `ls`/`ss` = http codes for
`/v1/auth/token/lookup-self` and `/v1/sys/seal-status` with the decoded
token, `wl` = wrong-OTP decode output length, `wls` = the lookup refusal
code observed for the garbage token (varies 403/400 per run; recorded, not
asserted), `wdrc` = wrong-OTP decode rc.
