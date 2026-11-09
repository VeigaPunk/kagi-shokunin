# Round 71 — kagi (secrets & vault ops) — predeclaration (frozen)

Lane: kagi. Round 71, attempt 1. L1 `KagiR71` (holds the §3 planner seat; the validator rejects a
`planner` swarm role). Claim BASE `e0e9603a924d73d9621924cc507b50474d11dae7` (lane tip at round
start = round-70 spot-check tip). Host: this Linux/omp host; OpenBao 2.7.2 official release
binary at `~/.local/bin/bao` (sha256 `9c5f3628…b788`, the pin rounds 49–57 and 70 used),
OpenSSL 3.6.5.

## Pre-move state

All six axes stand at 9 (SCORECARD `## Round 70 — post-move`); any claim meets the lowest-axis
duty. A capability entered at round 70, so the stagnation nudge does not fire. Depth is the axis
untouched longest (last change round 29). Round 70 executed single-issuer PKI mechanics (T1–T5);
its knowledge entry lists multi-issuer behaviour under "does not establish", and its spot-check
routed the counter blind spots (count does not prove the observable; shim-byte map; same-uid
sniffing) to the next PKI counter (`corpus/lessons/round-70-verifier-spotcheck.md` §5 item 3).

## C1 — depth: OpenBao PKI issuer and revocation channels, executed and artifact-checked

Surface moved: the lane's PKI ground deepens from one default issuer to the issuer-level and
revocation-channel mechanics — issuer NotAfter policy, per-issuer CRL routing, the token-less OCSP
responder, and proof-of-possession revocation of a `no_store` leaf. None is executed, entered or
counted at BASE (no `corpus/openbao-pki-issuer-trial.sh`, no
`corpus/knowledge/openbao-pki-issuer-revocation-channels.md`, no S173 row). Command that would show
it unmoved: the frozen counter on the BASE revision (`value=0 absent=1`).

**Frozen predicate (the same sentence as the header of `plans/round-71-c1.sh`):**
`C1_PKI_ISSUER_TRIAL: value = number of tests T in {T6..T9} that DISCRIMINATE and whose ARTIFACT
check passes, when PINS = 1 and SETUP_OK = 1 and NOSECRET = 1 and NOLEAK = 1 and SOURCED = 1,
else 0; target 4 (BASE 0).`

DISCRIMINATE(T): `corpus/openbao-pki-issuer-trial.sh` prints exactly one `TRIAL T HOLDS` line with
the real binary, exactly one `TRIAL T BROKEN` line under T's falsifier shim and `TRIAL T HOLDS`
under each of the other three shims, AND the entry carries a `## Measured (round 71` line
`- T<n> …OpenBao 2.7.2…`. Every run, the real one included, sees a wrapper *script* named `bao`
(the real run's wrapper only execs the binary). Shims: SH6 issuer-drops-leaf_not_after_behavior,
SH7 role-drops-issuer_ref, SH8 crl-config-disables-ocsp, SH9 revoke-with-key-drops-private_key.
ARTIFACT(T) (new this round; closes the round-70 "count does not prove the observable" class for
the artifact-bearing part): the counter itself checks with openssl the public artifacts the real
run left in `--evidence` — T6 leaf verifies against the issuer and its NotAfter equals the
issuer's, issuer lifetime < 10h; T7 leaf verifies against the second issuer and not the default,
the second issuer's signed CRL lists the serial and the default issuer's signed CRL does not; T8
two signed OCSP responses report `revoked` and `good` for the two leaves; T9 the issuer-signed CRL
lists the PoP-revoked leaf. NOSECRET now also scans every evidence file. SOURCED: the entry's
`source:` names S173 and the registry holds an S173 row, status `mined`, URL
`https://openbao.org/docs/secrets/pki/considerations/` (opened this round — the round's sourced
claim, §2b item 4).

- Counter: `plans/round-71-c1.sh` (frozen; sha256 in `.ufo/waves/round-71/controls/receipts/counter.sha256`).
- Counting command: `bash plans/round-71-c1.sh <landed lane revision>`.
- Target: `value=4`, rc 0. **Kill rule:** `value < 4` on the landed revision → C1 missed (honest
  stop; never narrowed after landing).
- Tests (measured on the reference trial before freezing):
  T6 notafter-truncate — on an issuer whose `leaf_not_after_behavior` is `truncate`, a 10h leaf
  from a 2h issuer is issued with NotAfter equal to the issuer's (default `err` refuses it);
  T7 nondefault-crl — a revoked leaf of a non-default issuer (role `issuer_ref`) is on its own
  issuer's CRL and absent from the default issuer's CRL;
  T8 ocsp-unauth — with `pki/config/crl ocsp_disable=false`, token-less OCSP requests report the
  revoked leaf `revoked` and an unrevoked control `good`;
  T9 revoke-with-key — a `no_store` leaf is refused revocation by serial, revoked by proof of
  possession (certificate + key by @file), and listed on the issuer's CRL.

### Prefreeze controls (executed; receipts committed with this freeze)

Runner `plans/round-71-controls.sh`; receipts `.ufo/waves/round-71/controls/receipts/`; fixtures
`.ufo/waves/round-71/controls/{p1,f1..f7}`. Expected verdicts were written into the runner header
before its first run; observed equals expected for all nine:

| control | what it is | expected | observed |
|---|---|---|---|
| F0 | BASE `e0e9603a` (do no work) | `value=0 absent=1` rc 1 | `value=0 absent=1` rc 1 |
| P1 | positive reference trial | `value=4` rc 0 | `value=4` rc 0, all `art=1` |
| F1 | echo forgery | `value=0 discriminating=0` rc 1 | as expected (shim=HOLDS ×4, art=0) |
| F2 | shim-byte-map forgery (reads wrapper, runs nothing) | `value=0 discriminating=0` rc 1, spec=1 shim=BROKEN art=0 | as expected — DISCRIMINATE alone is passed; ARTIFACT kills it |
| F3 | no-teeth trial (BROKEN → HOLDS) | `value=0` rc 1 | as expected |
| F4 | P1 trial, no entry, no S173 row | `value=0 sourced=0` rc 1 | as expected |
| F5 | dev server detached, never killed | `value=0 noleak=0` rc 1 | as expected (5 servers reaped) |
| F6 | T9 private key copied into evidence | `value=0 nosecret=0` rc 1 | as expected |
| F7 | T7 evidence CRLs swapped, verdicts unchanged | `value=3` rc 1 (T7 art=0) | as expected |

Named ceiling (not closed by this counter): a same-uid trial can read the wrapper bytes to learn
the active shim (F2 shows this alone now fails) **and** mint look-alike certificates, CRLs and OCSP
responses with local openssl; nothing in the artifacts proves OpenBao produced them. The attack
wave reads the landed trial for wrapper reads and local CA minting; that the trial executes the
mechanics through `bao` is a reviewed property, not a counted one.

## Routed defects from the round-70 spot-check (dispositions)

1. SCORECARD freshness sentence stale (S170/S171 recheck `on-release` vs landed `180d`): a
   correction is appended to SCORECARD this round; the round-70 sentence is not rewritten.
2. Wave-results name binding: this round's wave id is `w1`, so the driver's
   `w1-results.json` is the prefile tool's default; the mismatch is also named in
   `.ufo/l0-questions.md` as operator-side tooling.
3. Counter blind spots: the ARTIFACT leg, the wrapper-script real run and the evidence NOSECRET
   scan are carried into this freeze with controls F2/F6/F7 that fail without them; the remaining
   ceiling is named above.
4. Counter header date (CN-5): comment-only; this round's counter header carries no open date.
5. SHONEN: boxes stay `[~]`; promotion is operator-owned.

## Frontier step

Census before/after with stdout/stderr/rc (`.ufo/waves/round-71/base/`); new row S173 (admit,
tier A — OpenBao PKI considerations; capture byte-identical to the round-70 scout capture, sha256
`42ef7582…5047a`); S170 re-opened (byte-identical, sha256 `9fa76939…1123`) for the T6/T8/T9 anchors
without a row change; one mistake mined into `corpus/lessons/round-71.md` `## Mistakes`;
considerthese: at most one proposal, or a line.

## Amendment A1 — post-wave narrowing (appended 2026-11-09 after the wave's attack reports; the frozen predicate, counter, target and kill rule above are unchanged)

The counter's number is unchanged (`value=4` on the candidate, target met); the claim's
**wording** is narrowed to what the instrument enforces, citing the wave artifacts that falsify the
wider sentence (Amendment 59 option (i)):

- **C1 as filed:** the frozen counter reads `C1_PKI_ISSUER_TRIAL: value=4` on the landed tree — the
  four named verdicts T6–T9 of `corpus/openbao-pki-issuer-trial.sh` each read HOLDS with the real
  OpenBao 2.7.2 binary behind a pass-through wrapper, flip to BROKEN under their own shim and stay
  HOLDS under the other three, and the real run's public artifacts pass the counter's own openssl
  checks, with SETUP_OK, NOSECRET (the fixed regex), NOLEAK and SOURCED at 1. The heading words
  "executed and artifact-checked" mean exactly this; they do not mean that the counter proves the
  verdicts were computed from the artifacts it checks.
- **Verdict–artifact binding is not counted** (`.ufo/waves/round-71/w1/R71Revenger.md` RE-1,
  forgery C, receipt `R71Revenger/counter-c.txt`: verdicts from config read-backs and call
  statuses, real artifacts, `value=4`). The named ceiling above covered wrapper reads and local
  minting (forgery A, RE-2) but not this class. That the landed trial takes each verdict from the
  mechanic's own output (CRL listing, OCSP status, leaf dates, revoke response) is a reviewed
  property (R71Reviewer RV-5, R71Revenger RE-4), not a counted one. Transport bypass (forgery B,
  RE-3) is likewise outside the count.
- **NOSECRET is the literal regex** (`.ufo/waves/round-71/w1/R71Sentinel.md` SE-7: raw DER keys,
  bare base64, `hvb.`/`hvr.` prefixes and some byte contexts escape it). The plan's gloss "scans
  every evidence file" means that regex over those files, not "no secret in any encoding".
  R71Sentinel found the landed evidence clean in every encoding it tried.
- **Pre-move sentence corrected** (`.ufo/waves/round-71/w1/R71Connector.md` CN-2): "None is
  executed, entered or counted at BASE" is false as to "executed" — R70Scout measured all four
  observables on OpenBao 2.7.2 and its receipts are in the BASE tree
  (`.ufo/waves/round-70/w1/R70Scout/receipts/probe-frontier-final.txt` F3/F7/F10,
  `probe-frontier-focused.txt` F1.*). True at BASE: no trial, no knowledge entry, no counter and no
  S173 row for them; the scout's probe was a seat's one-off reconnaissance, not a lane instrument.
- **Frontier-step sentence corrected** (CN-1): "S170 re-opened … without a row change" is false;
  the candidate extends S170's `used-by` to the new entry, and integration also extends its anchor
  cell (M71-2). Both are logged old → new in `corpus/lessons/round-71.md` §Gate.
- **Entry wording** (R71Critic CR-1, R71ReviewerSrc SR-2): the T6 table cell now says what the
  counter checks (date equality, issuer lifetime < 10h) and labels the 10h/2h TTLs as the trial's
  requests; the OCSP "anyone can query" consequence is marked `[INFERENCE]`. Tokenlessness of the
  OCSP requests (CR-2) is the trial's property, confirmed by R71Sentinel SE-2, not an artifact leg.
- **Stamps** (SR-1, CN-6): the trial, the counter and the controls runner are pinned in
  `corpus/stamps.tsv` at integration, as round 70 did for its trial and counter.

## Amendment A2 — mutation findings (appended after WAVE-DONE; frozen predicate, counter, target and kill rule unchanged)

- **T9's serial-refusal conjunct is not counted** (`.ufo/waves/round-71/w1/R71MutTester.md` MT-1:
  fixture f-m11, a trial that never attempts revoke-by-serial, reads `value=4` on the frozen
  counter). C1 as filed therefore does not include "a `no_store` leaf is refused revocation by
  serial"; that refusal is a property of the landed trial's HOLDS condition, read by non-authors
  (R71Reviewer RV-5), and the entry's T9 line and the SKILL row say so.
- The ARTIFACT conjuncts are killed only by forged-evidence fixtures (MT-3), i.e. inside the named
  same-uid ceiling; this is consistent with A1 and adds no wider sentence.
