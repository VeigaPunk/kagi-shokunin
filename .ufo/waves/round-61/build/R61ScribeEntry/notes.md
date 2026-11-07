# R61ScribeEntry — notes: claims this seat could not ground

Seat: `R61ScribeEntry` (scribe, kagi round 61 attempt 1). Files owned:
`corpus/knowledge/openbao-seal-key-custody.md` and the two `corpus/README.md` coverage-map
rows. Everything below is a claim the entry or the README rows make that this seat did not
observe, with what would ground it.

## 1. The trial half — landed, read from the receipts

The executor's receipts landed before this entry's final pass:
`.ufo/waves/round-61/build/R61ExecTrial/receipt-real-1.txt` and `receipt-real-2.txt` are
byte-identical (sha256 `421689decca5043a369988922e0e8bd6d4a45c16edf3222b13c02d5952f44c56`),
both end `OPENBAO_SEAL_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2` with rc 0, and every
value in the entry's §Mechanics table is copied from those lines. The shim, no-`bao` and
selftest receipts are quoted from `receipt-shim-SH1..SH5.txt`, `receipt-nobao.txt`,
`receipt-selftest.txt` (`SEAL_SELFTEST: PASS (cases=63)`, rc 0) and
`receipt-selftest-mutant.txt` (`FINDING F-STUB-SH1-VEC` / `FINDING F-SHIM-MATRIX`,
`SEAL_SELFTEST: FAIL (cases=63 failed=2)`, rc 1).

Not independently verified by this seat (the receipts do not carry them):

- The trial's own implementation details the entry describes: `storage "raft"` for the main
  run, `storage "inmem"` for the T5 second leg, `tls_disable = 1`, `setpriv --pdeathsig KILL`,
  and the storage-sweep scope. These are read from the trial script and the frozen plan; this
  seat did not re-run the trial.
- The meaning of each receipt flag is read from the trial script's code (`shares=`, `status=`,
  `nopersist=`, `progress=`, `same-share-again=`, `seal=`, `auth503=`, `status200=`, `req3=`,
  `prog=`, `dec=`, `wrong=`, `tlen=`, `ls=`, `ss=`, `wl=`, `wls=`, `wdrc=`, `raft405=`,
  `mem405=`), not from the receipt alone.
- `wdrc=0` is the wrong-`-decode` CLI exit code: the CLI exits 0 even with a wrong OTP and
  prints a 26-character string; the entry records the flag without claiming the CLI signals
  the error.

## 2. Capture provenance

- The three `.body` captures under `.ufo/waves/round-61/capture/` were produced by the
  round-61 scout. No fetch receipt (headers, command, user agent) for the scout's fetch was
  present in the wave tree when this seat read it, so the entry states the capture's
  provenance as the scout's word plus the bytes, and records only this seat's own independent
  fetch (byte-identical via `cmp`, HTTP/2 200, no `Set-Cookie`/`Cookie` header line).
- The `Version 2.7.x` label is grounded (`count=3` on each capture).

## 3. Citation chain

- `corpus/SOURCES.md` has no S125/S126/S127 rows at the time of writing
  (`grep -cE '^\|[[:space:]]*S12[5-7][[:space:]]*\|' corpus/SOURCES.md` ⇒ 0). The entry's
  `source:` line cites them because the L1 appends the registry rows; until that append
  lands, the `Reverify: R21-02` chain does not resolve and the sources-census gate would
  report the entry's ids as unknown. This is a declared dependency on the L1, not a defect
  this seat can fix (SOURCES.md is not in this seat's write scope).

## 4. README rows

- The entry row says the trial is "executed by `openbao-seal-trial.sh`" — true as of the
  landed receipts.
- The round-61 lesson row describes `lessons/round-61.md`, which the L1 writes. The
  description follows the plan's §C1/§C2 content and may need to be narrowed to whatever the
  lesson actually records.

## 5. What is grounded

- Every page sentence quoted with a `(count=…)` annotation: 61 spans (57 distinct), all
  located `count=1` against the named capture by `python3 corpus/rendered-text-v1.py locate`.
- The absence checks (`duplicate`, `already`, `same share`, `503`, `service unavailable`,
  `seal-status`, `persisted`, `not stored`, `never stored`, `405`, `unsupported operation`,
  `hvs.`, `token length`, `disable_unauthed_rekey_endpoints`, `unauthenticated`,
  `rotate-keys`): each `count=0` except `rotate-keys` (2 on S125, 2 on S126, 1 on S127).
- The capture hashes and sizes, the `Version 2.7.x` labels, and the independent-fetch
  byte-identity.
- The five measured rows, the five shim vectors, the no-`bao` leg and the selftest: copied
  from the receipts named in §1.

## 6. What the Revenger grounded (D1–D7, and the custody rekey paragraph)

The round's Revenger receipt `.ufo/waves/round-61/build/R61Revenger/rekey.md` is the evidence
for the rekey mechanism and the `rotate-keys` rotation. This seat read it; it did not re-run
any of it. The claims the entry takes from it, with its sections:

- §1.2/§1.3: the 405 `unsupported operation` on `raft` and `inmem`, every method, anonymous
  and bogus-token requests included; the CLI exit 2; the backup routes' 400/204.
- §2.1–§2.6: the handlers are linked (not stubs); `rekeyPaths()` has no callbacks; the
  framework maps a nil callback to `ErrUnsupportedOperation`; the mux mounts the endpoints
  only behind `disable_unauthed_rekey_endpoints = false`; the paths are declared
  `Unauthenticated`.
- §4/§5: the three-way flag experiment and the full `rotate-keys` rotation (old shares refused
  at reconstruction, new shares unseal, root token survives).
- §7: the Revenger's own limits — the instruction-level branch is an inference;
  `-target=recovery` was measured only on shamir; string presence/absence is not route
  evidence.

The entry's §Bounds carries those limits. This seat did not verify the Revenger's source line
numbers or its `go tool` output; it cites the receipt, not the binary.
