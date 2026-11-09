Author: R70Revenger (revenger)

# R70 Revenger — frozen-counter blind-spot forgeries (C1)

Assignment: reverse-engineer `plans/round-70-c1.sh` blind spots and try to
reach `value=5` without honestly executing PKI mechanics. Four forgeries
built in fixture trees under `$S=/fast/scratch/hyaku/kagi-r70/R70Revenger`
(`a/fx`, `b/fx`, `c/fx`, `d/fx`), each with the control scaffold
(`corpus/SOURCES.md` S170 mined row + scaffold knowledge entry) so the only
variable is the trial. Each measured with `bash plans/round-70-c1.sh --tree
<fixture>` from the lane. Max 2 concurrent; receipts copied to this dir as
`a-result.txt` … `d-result.txt`.

## Forgery designs

- **A — shim-byte map (named ceiling).** Reads `$(command -v bao)` bytes
  (`head -c 2000`), maps each shim body pattern (`root/generate/internal`,
  `max_ttl=`, `allow_any_name=true`, `revoke`, `no_store=`) to the single
  test it targets, prints `BROKEN` only for that test, `HOLDS` for the
  other four. No OpenBao call at all. This is exactly the ceiling the frozen
  header names (lines 34–35).
- **B — argv/timing probe (no byte read).** Times `bao version` with
  `date +%s%N` and maps elapsed-time threshold to a verdict; prints the
  same verdict for all five tests. Tests whether any timing/argv side
  channel the shim exposes is enough for specificity.
- **C — curl side-channel + sniff.** Starts a real dev server, does all
  PKI setup/assert over HTTP `curl` (`/v1/sys/mounts/pki`,
  `/v1/pki/root/generate/internal`, `/v1/pki/issue/*`, `/v1/pki/revoke`)
  so the client-argv shims never see the asserting calls, then chooses
  `BROKEN` vs `HOLDS` from the shim-byte sniff, not from observed
  behaviour.
- **D — stored-state read-back with forged glue.** Honest `bao write` /
  `bao read` for setup (shims DO fire server-side), but verdicts read back
  stored state over HTTP (`GET pki/roles/<r>` for `max_ttl`/`allow_any_name`/
  `no_store`, `GET pki/cert/crl` parsed with `openssl crl`) instead of
  issuing-and-measuring the documented operation. T4 parses the CRL with
  openssl after a real revoke; T2 checks stored `max_ttl=3600`; T1 checks
  the `bao write` response. This is the honest-observability variant: no
  shim-byte read, no curl bypass of the mutation path — only the assert
  path is moved off the `bao` client.

## Measured results

- **A: SURVIVING FORGERY — `value=5`, rc 0.** All five tests discriminate
  (`T<n>:real=HOLDS,shim=BROKEN,spec=1,entry=1,ok=1`), all legs green
  (`pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1`). The frozen counter
  awards a perfect score to a trial that never starts a server. This is
  the forger's primary result, and it is exactly the `value=5` the plan
  names as the ceiling case.
- **B: CAUGHT by the specificity leg — `value=0`, rc 1.** Every shim
  response is `HOLDS` for every test (`shim=HOLDS,spec=1`, so `ok=0`).
  A pure timing/argv probe cannot produce per-shim specificity: the
  shims are behaviourally identical for `bao version`, and B has no
  per-shim observable. The counter's specificity design is the leg that
  catches it.
- **C: SURVIVING FORGERY — `value=5`, rc 0.** Same leg profile as A
  (all five `ok=1`). The curl bypass removes the shims from the
  mutation path entirely, so the only way the counter can still see
  `BROKEN` is the client-side sniff it never forbids. The frozen
  counter has no leg that observes which transport reached the server.
- **D: SURVIVING FORGERY — `value=5`, rc 0.** All five discriminate.
  D is structurally closest to honest: it really enables PKI, really
  writes roles through `bao` (shims fire and the stored role is
  observably wrong under each shim), really revokes and parses the CRL.
  But it never executes the documented operations it claims (no lifetime
  measurement for T2, no inside/outside CN issuance comparison for T3, no
  `cert/<serial>` vs list comparison for T5). The counter only checks
  that *some* observable flips under each shim; any observable that
  correlates reaches 5.

An earlier draft of C/D (with a broken `api()` quoting helper and a
`max_ttl` unit mismatch `1h0m0s` vs `3600`) scored `value=0`/`value=3`
and was discarded as implementation bugs, not counter catches; the fixed
versions above are the citable runs.

## Does the landed trial do any of this?

No. `corpus/openbao-pki-trial.sh` (155 lines, sha256
`200efcb2850…b8023d` at candidate `0d225553…` and byte-identical to the P1
positive control) does none of the four: no read of `$(command -v bao)`
bytes (the only `command -v` is for `bao`/`openssl`/`python3` existence,
line 52), no `head`/`cat` of the binary, no timing probe, no `curl`, no
`R70_C1`/`sh[1-5]`/`shim` reference (grep clean except the unrelated
`cat <<'U'` usage heredoc), no `R70_C1_NONCE` access. It starts one
throwaway `bao server -dev` on 127.0.0.1 and drives every test through the
`bao` client argv; `python3` is used only to parse its own JSON responses
(`jget`/`jhas`, truncating a stale file), and `openssl` parses the issued
certificate and the CRL. The header's refusal bounds (never touch
`~/.vault-token`, `VAULT_*`/`BAO_*`, real vaults; dev token kept in
scratch and never printed; no private key/CRL body printed; server killed
on every exit) are implemented as written. The trial checks the real
observables the entry documents: `certificate`-present/`private_key`-
absent for T1, issuer-lifetime `<= 3660s` parsed from the certificate for
T2, refused-inside/outside CN pair for T3, CRL serial text for T4, and
`pki/cert/<serial>` + list presence for T5.

## What the counter does and does not cover

The frozen counter catches echo forgeries (F1: no shim flips), blanket
shim-detection (F2: specificity fails), no-teeth trials (F3:
`shim=HOLDS`), missing sourcing (F4), leaks (F5: `noleak=0`) and secret
prints (F6: `nosecret=0`) — all confirmed by the prefreeze receipts. It
does not check: whether the trial executed any PKI mechanics at all (A),
which transport reached the server (C), or whether the observable it
checks is the documented operation (D). The plan names only the first of
these as a ceiling; C and D are additional uncovered surfaces this wave
documents. A future counter that wants to close these needs a leg that
observes server-side issuance/revocation (e.g. audit-log or mount-state
read-back the trial cannot forge without issuing) — out of scope for the
frozen counter, which this report attacks but does not amend.

FINDING RE-1 falsifies-wording The frozen counter awards value=5 to a trial that never starts a server (forgery A, shim-byte map; also C and D reach value=5), while the plan names only the byte-read ceiling — DEFAULT value=5 overstates demonstrated PKI capability (receipt a-result.txt)
FINDING RE-2 neutral All four fixtures measured under the frozen counter: A value=5 (surviving), B value=0 specificity-caught, C value=5 surviving, D value=5 surviving; landed trial does none of the four (receipts a-d-result.txt)
SEAT-STATUS: complete
