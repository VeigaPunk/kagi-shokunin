Author: R71Revenger (revenger)

# R71Revenger — forgery reconstruction for C1 (round 71)

Scope: reverse-engineer how the frozen counter `plans/round-71-c1.sh` could reach `value=4`
without OpenBao executing the mechanics. Three forgery trials were built in scratch only, each
replacing `corpus/openbao-pki-issuer-trial.sh` in a copy of the P1 positive-control tree
(`.ufo/waves/round-71/controls/p1`), and each was scored with
`bash plans/round-71-c1.sh --tree <fixture>`. Counter receipts and forgery scripts are copied
into this directory. Nothing was committed; no lane file was edited.

## Results

| forgery | class | what it does | counter | copy |
|---|---|---|---|---|
| A | wrapper-byte sniff + local openssl minting | reads the bytes of the `bao` on PATH to pick the broken test (the same needle map as control F2), then mints every artifact with a local CA (`openssl x509 -req`, `openssl ca -gencrl`, `openssl ocsp -index/-rsigner`). `bao` is never called for the mechanics. | `value=4 discriminating=4 … art=1 ×4` (rc 0) | `counter-a.txt`, `forgery-a.sh` |
| B | transport bypass (curl) | starts a real `bao server -dev`, drives every mechanic over HTTP with curl/urllib instead of the `bao` CLI, sniffs the shim state from the wrapper bytes, and applies the shim by dropping the named field from the JSON body. Artifacts are real OpenBao output. | `value=4 discriminating=4 … art=1 ×4` (rc 0) | `counter-b.txt`, `forgery-b.sh` |
| C | wrong observable | starts a real dev server and never reads wrapper bytes. Verdicts come from config readbacks (T6 `pki/issuer/r71short` `leaf_not_after_behavior`, T7 `pki/roles/t7` `issuer_ref`, T8 `pki/config/crl` `ocsp_disable`) and from the exit status of a `revoke-with-key` call (T9). Artifacts are the real evidence of a child run of the landed trial, copied byte for byte. | `value=4 discriminating=4 … art=1 ×4` (rc 0) | `counter-c.txt`, `forgery-c.sh`, `c-child-landed-copy.sh` |

Scoring notes:
- A reached 4 only after the local chain was made to match OpenBao's shape. The first version
  signed the 2h intermediate with the default CA and scored `value=3` (T6 `art=0`). The
  counter verifies the leaf directly against `t6-issuer.pem` as trust anchor, which requires
  the issuer to be a self-signed root, as `pki/root/generate/internal` produces. Making the
  intermediate self-signed (`openssl x509 -req -signkey`) gave T6 `art=1`. This is recorded as
  the reason the scripts look as they do, not as a counter defect.
- B and C pass `DISCRIMINATE` (real HOLDS, shim BROKEN, other shims HOLDS), `SOURCED`,
  `NOSECRET`, `NOLEAK` and `SETUP_OK` with no change to the counter.

## Does the landed trial do A, B or C?

Read in full: `corpus/openbao-pki-issuer-trial.sh` (landed at `39e76bc7`, bytes identical to the
P1 control).

- A (wrapper-byte reads, local minting): **no.** The trial never reads the bytes of `bao`
  (`command -v bao` and `bao version` only). `openssl` is used only read-only: `openssl x509
  -noout`, `openssl crl -noout/-text`, `openssl ocsp -no_nonce … -respout` against the dev
  server's own responder, and `openssl verify`-style checks in the counter. No `openssl ca`,
  `openssl x509 -req`, key generation for issuance, or other minting.
- B (transport bypass): **no.** Every mechanic goes through the `bao` CLI (`q`, `bao read`,
  `bao write`). There is no curl or HTTP call in the trial.
- C (wrong observable): **no.** The verdicts are taken from the mechanic outputs, not from
  configuration readbacks: T6 compares the issued leaf's NotAfter with the issuer's; T7 reads the
  second and default issuers' CRLs; T8 reads the two OCSP responses; T9 requires the serial
  revoke to be refused and then reads the issuer CRL after `revoke-with-key`.
- Caveat inside the trial (not a forgery route): T9's refusal check treats "revoke by serial
  returned non-zero" as the refusal, which is a call-status observable, though the trial pairs it
  with the CRL listing. T8 parses the first line of `openssl ocsp -url` output.

## Divergences from the named ceiling

The plan's named ceiling (`plans/round-71.md` §C1, and the counter header) says two things:
a same-uid trial can read the wrapper bytes and mint look-alike artifacts (A), and that "the
trial executes the mechanics through `bao`" is a reviewed property, not a counted one. A is
named. B is covered by the "through `bao`" sentence, so it is reported as neutral. C is not
named. The artifact leg proves that the artifacts are real OpenBao output, but nothing binds a
verdict to an artifact. The counter reads whatever observable flips under the shim (a config
readback, a call status) and accepts it as long as the real-run artifacts pass their own checks.
F7 (swapped CRLs) only shows that artifacts are checked, not that verdicts are derived from them.

Suggested tightening for the lane (proposal, not applied; the plan is frozen): bind each verdict
to the artifact it claims to measure (T7 HOLDS only if the artifact CRL listing that serial is
the one read), or add a control in which the verdict observable is a config readback and the
counter must return 0 on it.

## Findings

Ids are RE-n. Each forgery's reach to value=4 is recorded above; the findings below are the
ones that the named ceiling does not already cover.

RE-1 — C (wrong observable) reaches value=4 with real OpenBao artifacts and no wrapper read or local minting; the verdict observable is a config readback or a call status, not the artifact-bearing mechanic. Not named by the plan's ceiling (`counter-c.txt`, `forgery-c.sh`).

RE-2 — A (wrapper sniff + local minting) reaches value=4. This is the named ceiling sentence in `plans/round-71.md` §C1; recorded for the receipt (`counter-a.txt`).

RE-3 — B (curl transport, shim sniffed from wrapper bytes, real OpenBao artifacts) reaches value=4. It bypasses the `bao` CLI, which the ceiling's "through `bao`" sentence covers as reviewed-only; it still reads wrapper bytes, so it is also an A variant (`counter-b.txt`).

FINDING RE-1 falsifies-wording C reaches value=4 by reading config fields and call status while the artifacts are real OpenBao output; the named ceiling covers wrapper reads and local minting only, and the counter does not bind verdicts to artifacts (counter-c.txt).
FINDING RE-2 neutral A (wrapper-byte sniff plus local openssl minting) reaches value=4, as the named ceiling already states (counter-a.txt).
FINDING RE-3 neutral B (curl transport with sniffed shims and real artifacts) reaches value=4; covered by the named "executes through bao is reviewed" sentence (counter-b.txt).
FINDING RE-4 neutral Landed trial does none of A, B or C: no wrapper read, no local minting, all mechanics through the bao CLI, verdicts from mechanic outputs (corpus/openbao-pki-issuer-trial.sh read in full).

## Tooling and process

- Installed or upgraded: nothing. Used the existing `bao` 2.7.2 (`~/.local/bin/bao`, pin unchanged), OpenSSL 3.6.5, Python 3.14.8, curl, setpriv, ss.
- No `bao server -dev` survived: the forgeries' servers were trap-killed; a final `/proc` sweep found zero `bao server -dev` processes.
- No secret, token, private key or token-shaped string was printed or written to this directory. The forgery scripts use random dev tokens in environment variables and in curl headers on throwaway loopback servers.
- Counter runs: three (A, B, C) plus one rescore after the chain-shape fix; no more than one concurrent.
- Scratch `/fast/scratch/hyaku/kagi-r71/R71Revenger` removed before yield.

Confidence: high on the numbers (each counter receipt is in this directory); medium on C being named-by-omission rather than named (reading of the ceiling sentence is mine).

FINDING RE-1 falsifies-wording C reaches value=4 with real OpenBao artifacts using config readbacks and a call status for verdicts; the named ceiling does not cover verdict-observable binding.
FINDING RE-2 neutral A (wrapper-byte sniff plus local openssl minting) reaches value=4, already named in plans/round-71.md §C1.
FINDING RE-3 neutral B (curl transport plus sniffed shims, real artifacts) reaches value=4, covered by the named "through bao is reviewed" sentence.
FINDING RE-4 neutral the landed trial does none of A, B or C; verdicts come from mechanic outputs and all mechanics go through the bao CLI.
SEAT-STATUS: complete all three forgeries scored and copied; landed trial read in full; no servers left; scratch removed.
