Author: R71ExecReplica (independent replication)

# Independent replication of round-71 C1 trial from the frozen plan + entry alone

## What I did

I wrote a fresh `openbao-pki-issuer-trial.sh` implementing T6–T9 from `plans/round-71.md`
§C1 and the entry's `## Measured (round 71` section only, reusing the round-70 trial's
boilerplate pattern (dev-server launch, port ownership, env-only token) as a shape. I did
not read `corpus/openbao-pki-issuer-trial.sh` or the controls' trial bytes (`p1` was only
listed, never opened; only its `SOURCES.md` and scaffold entry header were shown). The
trial was placed in a copy of the `p1` fixture tree in my scratch (`fixture/`), replacing
the control trial, and scored with the frozen counter.

## Result (frozen counter, verbatim)

`bash plans/round-71-c1.sh --tree <fixture>` (run from the lane root) on the final trial:

```
C1_PKI_ISSUER_TRIAL: value=4 discriminating=4 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1 real_rc=0 none_rc=2 T6:real=HOLDS,shim=BROKEN,spec=1,entry=1,art=1,ok=1 T7:real=HOLDS,shim=BROKEN,spec=1,entry=1,art=1,ok=1 T8:real=HOLDS,shim=BROKEN,spec=1,entry=1,art=1,ok=1 T9:real=HOLDS,shim=BROKEN,spec=1,entry=1,art=1,ok=1
```

rc=0. Four counter iterations were needed; intermediate readings (all retained in my
scratch history, final one above) were `value=3` twice with T8 `shim=ERROR`, then `value=4`.
Real run: `OPENBAO_PKI_ISSUER_TRIAL: HOLDS holds=4 broken=0 error=0` (OpenBao v2.7.2,
OpenSSL 3.6.5). No leftover `bao server` process after any run.

## Files

- `R71ExecReplica/openbao-pki-issuer-trial.sh` — my independent trial (sha256
  `7d2055e9…a9d65`, 14108 bytes).
- `R71ExecReplica/counter-output.txt` — the frozen counter's final verdict line.
- `R71ExecReplica/fixture/` — the scored fixture tree (p1 scaffold + my trial).

## Where the plan/entry was insufficient to implement (executability gaps found)

None of these blocked the replication, but each cost probes against a live dev server.
A fresh implementer reading only the plan + entry would hit the same six seams:

1. **Per-issuer CRL is read, not written.** The plan says "per-issuer CRL routing" and the
   entry names `pki/issuer/<ref>/crl`, but does not say the method. `bao write
   pki/issuer/<id>/crl` fails ("Must supply data or use -force"); `bao read
   -format=json pki/issuer/<id>/crl` returns `{"crl": "<pem>"}`. A writer-side guess
   fails on every CRL fetch. The counter's own shims match `*/issuer/*` only for the SH6
   issuer write, so the read choice is shim-safe — but nothing in the frozen text says so.
2. **The issuer-CRL payload key is `crl`, not `certificate`.** `jget json certificate`
   gives "" (which my `[ -s file ]` check correctly caught as a 1-byte file). The mount
   path `pki/cert/crl` returns `{"certificate": …}` in round 70's shape but NOT the CRL —
   its data keys were `certificate`/`revocation_time`; the CRL is not there. Only
   `pki/issuer/<id>/crl` carries the CRL, under key `crl`.
3. **Single-field issuer write wipes `issuer_name` (entry documents this; the mechanism
   does not).** The entry's table records the observed reset but not that the issuer
   *name* is then unresolvable: `pki/issuer/r71short` reads rc=2, and a role with
   `issuer_ref=r71short` gets only a warning and signs elsewhere. A correct T6 must
   reference the issuer **by id** afterwards. Also: re-sending the full body with
   `certificate=…` as a CLI operand FAILS to parse ("invalid key/value pair") because the
   PEM contains newlines — a full-body CLI write is impossible; the single-field write
   works and the id survives. The plan does not state that a single-field write preserves
   `certificate` (it does; verified).
4. **`openssl ocsp` request exits 1 by design.** The request prints `Response Verify
   Failure … Verify error: self-signed certificate` (the dev responder is self-signed)
   yet still writes the DER. Any trial that treats request rc≠0 as a setup fault reads
   ERROR on the REAL run. The entry says the requests "carried no token" but not that the
   request rc is meaningless; only the respin (`Response verify OK`, rc=0 on success)
   arbitrates. The respin output line I compare against is `<path>: revoked/good` —
   correct per the counter's `ocsp_is`.
5. **SH8's disabled responder returns `Responder Error: unauthorized (6)`** in a 5-byte
   DER; respin then fails rc=1. A trial that reads any respin failure as ERROR misclassifies
   the falsifier as a setup fault (my first counter run: T8 `shim=ERROR`, value=3). The
   plan/entry do not state the disabled-OCSP response shape; the correct classification
   needs an explicit probe. The landed trial must classify a Responder Error as BROKEN
   and an unparseable respin as ERROR — a subtlety neither frozen document names. (Also:
   the T8 verdict dispatcher must treat `broken-*` tags as BROKEN; my first version
   matched only bare `broken` and shed the tag into ERROR.)
6. **SH6's stripped write is not an error.** Under SH6 the issuer write loses its only
   operand and OpenBao rejects it (no data). A trial that treats the write rc≠0 as setup
   reads ERROR under SH6 instead of the falsifier's BROKEN. The plan says nothing about
   write-rc semantics under shims; the trial must proceed and let the 10h refusal read
   BROKEN.

## Executability verdict

The frozen plan + entry **are** sufficient to implement a counter-green trial, but only
after empirical probing of six seams (CRL read method, CRL key name, issuer-id (not name)
reference after the name wipe, OCSP request-rc semantics, SH8's Responder-Error shape,
SH6 write-rc semantics). Two of the six (items 5–6) are about classifying falsifier effects
as BROKEN vs ERROR — the plan's DISCRIMINATE predicate requires exactly
`TRIAL T BROKEN` under the own shim, yet no frozen sentence states the request/write/rc
semantics under the shims. That is the executability defect: a careful re-implementer gets
the mechanics right (items 1–4) and still scores `value=3` until items 5–6 are probed.

## Process notes

- No tools installed or upgraded (official `bao` v2.7.2 and OpenSSL 3.6.5 already present;
  nothing to record under the tooling directive).
- Read-only lane access throughout; no git/jj mutation anywhere. Fixture tree lived in
  `/fast/scratch/hyaku/kagi-r71/R71ExecReplica/` (since removed with the receipts copied
  above). Every `bao server -dev` was started by the trial under `setpriv --pdeathsig KILL`
  and reaped by its EXIT trap; two hand-started probes were killed explicitly (checked
  `pgrep -af 'bao server'` empty after each).
- Evidence hygiene: the trial writes no private key into `--evidence` (T9's key stays in
  the scratch work dir); counter NOSECRET=1 confirms.

SEAT-STATUS: complete Independent replication reached value=4 rc=0 on the frozen counter; gaps G1–G6 reported.
