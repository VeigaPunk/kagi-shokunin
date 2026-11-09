Author: R71Scout (scout)
Seat dir: `.ufo/waves/round-71/w1/R71Scout/`
Lane: `kagi` (`/home/vgpnk/Projects/shokunin/kagi-shokunin`), BASE `e0e9603a924d73d9621924cc507b50474d11dae7`. Read-only frontier recon: no lane file was edited, no registry row was written.
Binary: OpenBao 2.7.2 (`~/.local/bin/bao`, the round's pin), `openssl 3.6.5`. No tool was installed or upgraded by this seat (tool installs this round: none).
Scope: three PKI mechanics that `corpus/openbao-pki-issuer-trial.sh` (T6 notafter-truncate, T7 nondefault-crl, T8 ocsp-unauth, T9 revoke-with-key) does not touch: M1 issuer-no-longer-in-mount, M2 `leaf_not_after_behavior=permit`, M3 issuer revocation. Every row carries a located quote (lane normalizer `corpus/rendered-text-v1.py`), the measured result, and a falsifier shim idea. The shim ideas are **unmeasured**: no shim was written or run.

## Receipts (all in `receipts/`)

| file | what | result |
|---|---|---|
| `probe-frontier.sh` | the main probe: M1, M1b, M2, M3, artifact CRL signature leg | rc 0; output `receipts/probe-frontier.txt`; all three CRL signatures verify under the default root (`ART.*` lines) |
| `probe-frontier-check.sh` | second pass: M3 usage flags across the issuer's life, M2 depth-resolved verify | rc 0; output `receipts/probe-frontier-check.txt` |
| `quote-locate-r71.py` | locates 13 quotes with the lane normalizer | rc 0, 13/13 `count=1`; `receipts/quote-locate-r71.txt` |

Harness notes, stated so they are not read as OpenBao results: (a) the first run of `probe-frontier-check.sh` verified the leaf against the intermediate alone and failed (rc 2) — my anchor was wrong (the root was missing); the fixed run anchors the root with the intermediate as `-untrusted` and passes (`C1.pre-leaf-verifies-root-anchor rc=0 ... OK`). The receipt is the fixed run. (b) one call (`sign-intermediate` with no data argument) was malformed and is **not measured**; it is recorded as `NOT-MEASURED` in the receipt, not as a result. (c) A `bao` listener was seen transiently on the host during the run; it was not mine (my dev servers were killed by the probe traps, and `ps` shows zero `bao server -dev` processes after each run).

Dev server: `bao server -dev` on 127.0.0.1, in-memory, random dev root token by `BAO_DEV_ROOT_TOKEN_ID` env only, never on argv, never printed; `setpriv --pdeathsig KILL`; listener pid checked with `ss`. Private keys stayed in scratch (`/fast/scratch/hyaku/kagi-r71/R71Scout`, removed at yield). Only certificates, CRLs and the root certificate were copied to `receipts/`.

## M1 — issuer no longer part of the mount: where the revoked serial lands

**Located quotes**
- S173 (`capture/S173.body`): "When certificates are revoked and their issuer is no longer part of this PKI mount, OpenBao places them on the default issuer's CRL." — `count=1 offset=5540`.
- S170 Delete issuer: "This endpoint deletes the specified issuer." — `count=1 offset=101407`.
- S170 Rotate CRLs: "Mirroring the behavior of earlier OpenBao versions, we add certificates revoked by an unknown issuer to the default issuer's CRL." — `count=1 offset=139296`.

**Measured (2.7.2, `receipts/probe-frontier.txt`)**
- Self-signed non-default root `r72gone`, role `issuer_ref=r72gone`, leaf `m1a` issued (rc 0). Before revoke: serial on neither the issuer's CRL (0 entries) nor the default CRL (0 entries).
- `pki/revoke` rc 0. Serial on `r72gone`'s own CRL (`entries=1`); **not** on the default CRL (`entries=0`).
- `bao delete pki/issuer/r72gone` rc 0, with a warning line. Reading the issuer then gives rc 2; its CRL endpoint gives rc 1.
- **Default CRL immediately after the delete, before any rotate: serial present (`entries=1`).** A `pki/crl/rotate` changes nothing (still present, `entries=1`). So on 2.7.2 the rebuild happens at delete time; no operator rotate is needed for the S173 sentence to hold.
- Default CRL signature verifies under the default root (`ART.m1-default-crl-after-delete ... verify OK`, `ART.m1-default-crl-after-rotate ... verify OK`).
- M1b (delete first, then revoke a leaf of the deleted issuer): issue rc 0, delete rc 0, revoke rc 0, serial on the default CRL (`entries=2`, the M1 serial also present). Revoke after delete lands on the default CRL.

**Verdict:** the S173 sentence reproduces for the ordering it describes (revoke while in the mount, then delete). It also holds for delete-then-revoke (M1b).

**Falsifier shim idea (unmeasured):** a PATH `bao` wrapper that turns `delete pki/issuer/*` into a no-op. The serial then stays only on the issuer's own CRL, the default CRL leg flips to BROKEN, and the issuer-gone read (rc 2) is the control that must stay as observed. Check the default CRL and the issuer-gone read as separate legs so the verdict is specific. A second shim that swallows the revoke puts the serial on no CRL at all.

## M2 — `leaf_not_after_behavior=permit`: a leaf outliving its issuer

**Located quotes**
- S170 Update issuer: "permit to allow this issuance to succeed with a NotAfter value exceeding that of this issuer." — `count=1 offset=93095`.
- S170: "Not all values result in leaf certificates that can be validated through the entire validity period." — `count=1 offset=93203`.
- S173: "should OpenBao err , preventing issuance of a longer-lived leaf cert than issuer, silently truncate to that of the issuer's NotAfter value, or permit longer expirations." — `count=1 offset=20051`.

**Measured (2.7.2, `receipts/probe-frontier.txt` M2 rows and `receipts/probe-frontier-check.txt` C2 rows)**
- 2h self-signed root `r72spermit`; readback `leaf_not_after_behavior=permit`; role `max_ttl=87600h`; leaf requested `ttl=10h` → issued (rc 0).
- Leaf NotAfter minus issuer NotAfter = **+28800 s (8 h)**: the leaf outlives its issuer (`leaf_outlives_issuer=yes`).
- openssl verify at issuer-end minus 60 s: OK. At issuer-end plus 60 s: `error 10 at 1 depth lookup: certificate has expired` — **depth 1, the issuer**. The leaf is still inside its own window by 8 h at that time (`C2.permit-leaf-window leaf_valid_past_issuer_end_by_s=28800 ... =yes`).
- `truncate` control, same 2h issuer, same request: leaf NotAfter equals the issuer's (difference 0). Its verify at issuer-end plus 60 s also says expired, because the leaf equals the issuer's end. So "expired at +60 s" does not discriminate by itself: the trial must name the failing depth and compare leaf and issuer NotAfter.
- `err` control: issuance refused (rc 2).
- Readback of `issuer_name` after the behaviour write was preserved in this run, because the write re-sent `issuer_name`. The T6 build note (a bare `bao write pki/issuer/<ref> leaf_not_after_behavior=…` reset `issuer_name`) is therefore not re-tested here.

**Verdict:** `permit` lets a leaf outlive its issuer by the requested excess (8 h here) with openssl reporting the issuer, not the leaf, as expired.

**Falsifier shim idea (unmeasured):** a PATH wrapper that rewrites `leaf_not_after_behavior=permit` to `err` on `pki/issuer/*` writes (or drops the setting, so the default `err` applies). The permit issuance is then refused, and the "leaf outlives issuer" verdict flips to BROKEN while T6 (`truncate`) keeps its own verdict. The artifact leg must check leaf NotAfter greater than issuer NotAfter, and the depth-1 expiry, not just "expired".

## M3 — issuer revocation `pki/issuer/<ref>/revoke`: where the issuer lands

**Located quotes**
- S170 Revoke issuer: "This endpoint allows an operator to revoke an issuer certificate, marking it unable to issue new certificates and adding it to other issuers' CRLs, if they have signed this issuer's certificate." — `count=1 offset=99587`.
- S170: "Revoked issuers will not appear on their own CRLs." — `count=1 offset=100169`.
- S170: "Revoked issuers may not appear on other CRLs if a suitable parent is not present in the same mount point." — `count=1 offset=100220`.
- S170 usage option: "Valid options are: read-only , to allow this issuer to be read; implicit; always allowed;" — `count=1 offset=94876`.
- S170 usage soft-delete note: "preventing new certificate issuance" — `count=1 offset=95687`.

**Measured (2.7.2, `receipts/probe-frontier.txt` M3 rows; `receipts/probe-frontier-check.txt` C1 rows)**
- Intermediate generated (`pki/intermediate/generate/internal`), signed by the default root `r72root` (`pki/issuer/r72root/sign-intermediate`), installed with `pki/intermediate/set-signed` (rc 0; the issuer came back with an id and no name). Usage at birth: `crl-signing,issuing-certificates,ocsp-signing,read-only`.
- Leaf issued through a role with `issuer_ref=<intermediate>` (rc 0); the leaf verifies under the root anchor with the intermediate as untrusted (`C1.pre-leaf-verifies-root-anchor rc=0 ... OK`).
- Before revoke: intermediate serial on the default CRL: no (2 entries). On its own CRL: no (0 entries).
- `POST pki/issuer/<ref>/revoke` rc 0. Readback: usage now `crl-signing,ocsp-signing,read-only` (`issuing-certificates` removed), `revocation_time` set.
- Default CRL, immediately after revoke: intermediate serial **present** (3 entries). The intermediate's own CRL is readable (rc 0) and does **not** list its own serial (0 entries). So on 2.7.2 the revoked issuer lands on its signing parent's CRL, not on its own.
- Issuing from the revoked intermediate: refused. **HTTP 500**, message `requested usage issuing-certificates for issuer [...] but only had usage crl-signing,ocsp-signing,read-only`. The refusal is a 500, not a 4xx, which matters for any client that retries on 5xx.
- Control: self-signed root `r72self` revoked (rc 0). Its serial is **not** on the default CRL (3 entries, unchanged), matching "if they have signed this issuer's certificate": the default root did not sign it, so it lands nowhere in the mount.
- `read-only` at birth is an implicit flag (S170: "read-only , to allow this issuer to be read; implicit; always allowed"); its presence did not block the pre-revoke issuance. The gate that changed is `issuing-certificates`.
- Artifact leg: the default CRL after the issuer revoke verifies under the default root (`ART.m3-default-crl-after-issuer-revoke ... verify OK`).

**Verdict:** revoking an issuer (a) stops it issuing (HTTP 500 with the usage reason), (b) puts it on its signing parent's CRL in the same mount, immediately, (c) keeps it off its own CRL, and (d) puts a self-signed root on no CRL.

**Falsifier shim idea (unmeasured):** a PATH wrapper that makes `POST pki/issuer/*/revoke` a no-op. The usage keeps `issuing-certificates` (issuance succeeds) and the default CRL lacks the intermediate serial. Both legs flip to BROKEN, and the self-signed-root control (no entry on the default CRL) should stay as observed, so the verdict remains specific.

## Frontier candidates for the next PKI round (ranked; none measured here)

1. **M3b — a revoked intermediate whose parent is absent from the mount.** S170 says revoked issuers "may not appear on other CRLs if a suitable parent is not present in the same mount point." Combine M1 and M3: delete the parent, then revoke the intermediate, then read the default CRL. Dev-server measurable; this is the branch M3 did not reach. Not measured in this seat.
2. **Auto-tidy retention (R70 F4)** — still open; wall-clock cost. Not measured here.

## Does not establish

- Anything about HashiCorp Vault's PKI engine, or OpenBao releases other than 2.7.2.
- Relying-party behaviour: nothing here shows a client fetches the default CRL, or that a 500 causes a retry.
- The shim ideas: none was written or executed. They are falsifier suggestions only.
- The M3 "read-only at birth" meaning beyond S170's usage text; the observation is recorded, not explained further.
- M3b (parent absent) and tidy retention: not measured.

SEAT-STATUS: complete frontier recon measured for M1, M2 and M3 on OpenBao 2.7.2 with 13/13 located quotes and the three default-CRL signatures verified; shims unmeasured; M3b left as the named next candidate.
