Author: R71Scout (scout)
Seat dir: `.ufo/waves/round-71/w1/R71Scout/` (full frontier text: `frontier.md`; receipts: `receipts/`)
Lane: `kagi`, BASE `e0e9603a924d73d9621924cc507b50474d11dae7`. Read-only recon: no lane file edited, no registry row, no commit.
Binary: OpenBao 2.7.2 (`~/.local/bin/bao`), openssl 3.6.5. No tool installed or upgraded this seat.

## Frontier for the next PKI round: three mechanics beyond T1–T9

Each row: located quote (lane normalizer `corpus/rendered-text-v1.py`, `receipts/quote-locate-r71.txt`, 13/13 `count=1`), measured result on a throwaway `bao server -dev`, falsifier shim idea (unmeasured).

**M1 — issuer no longer part of the mount → default CRL.** Quote: S173 "When certificates are revoked and their issuer is no longer part of this PKI mount, OpenBao places them on the default issuer's CRL." (offset 5540). Measured: a revoked leaf of a non-default root shows on its issuer's CRL only; after `bao delete pki/issuer/<ref>` the serial is on the default CRL **immediately**, with no rotate needed; the default CRL verifies under the default root. Delete-then-revoke also lands on the default CRL. Shim: make `delete pki/issuer/*` a no-op; the default-CRL leg goes BROKEN while the issuer-gone read (rc 2) stays as the control.

**M2 — `leaf_not_after_behavior=permit`.** Quote: S170 "permit to allow this issuance to succeed with a NotAfter value exceeding that of this issuer." (offset 93095). Measured: 2h issuer, 10h leaf → issued, leaf NotAfter exceeds issuer by 28800 s; openssl at issuer-end plus 60 s reports `certificate has expired` at depth 1 (the issuer). `truncate` leaves equal the issuer's end (difference 0) and expire at the same instant, so the trial must name the failing depth. `err` refuses (rc 2). Shim: rewrite `permit` to `err` on issuer writes; verdict flips BROKEN.

**M3 — issuer revocation `pki/issuer/<ref>/revoke`.** Quote: S170 "This endpoint allows an operator to revoke an issuer certificate, marking it unable to issue new certificates and adding it to other issuers' CRLs, if they have signed this issuer's certificate." (offset 99587). Measured: revoked intermediate → `issuing-certificates` removed from usage; issuance then **refused with HTTP 500** (usage reason); its serial lands on the signing root's CRL immediately; its own CRL does not list it (S170 "Revoked issuers will not appear on their own CRLs", offset 100169); a revoked self-signed root lands on no CRL in the mount. `read-only` at birth is S170's implicit flag and did not block issuance. Shim: make `issuer/*/revoke` a no-op; usage keeps issuing (issuance succeeds) and the default CRL lacks the entry: both legs BROKEN.

## Receipts and harness notes

- `receipts/probe-frontier.txt` (main probe, artifact CRL signature leg), `receipts/probe-frontier-check.txt` (second pass).
- The first run of the check pass failed on my own chain anchor (leaf verified against the intermediate alone); corrected with the root anchor and rerun. The receipt is the corrected run.
- One `sign-intermediate` call was malformed (no data argument) and is recorded as NOT-MEASURED.
- Dev servers: 127.0.0.1, in-memory, token by env only, killed by the probe traps; `ps` shows zero `bao server -dev` after each run. A transient listener seen on the host during the run was not this seat's.

## Next candidate (not measured)

M3b: a revoked intermediate whose parent has been deleted. S170 says revoked issuers "may not appear on other CRLs if a suitable parent is not present in the same mount point." Dev-server measurable; the branch M3 did not reach.

## Does not establish

Vault PKI or OpenBao releases other than 2.7.2; any relying-party behaviour (client fetches, retries on 500); any shim (ideas only); the meaning of `read-only` beyond S170's usage text; M3b and tidy retention.

SEAT-STATUS: complete frontier recon measured for M1, M2 and M3 on OpenBao 2.7.2 with 13/13 located quotes and the default-CRL signatures verified; shims unmeasured; M3b named as the next candidate.
