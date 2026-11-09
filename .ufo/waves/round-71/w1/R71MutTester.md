Author: R71MutTester (mutation-tester)

# Mutation test of the frozen C1 counter (`plans/round-71-c1.sh`, sha256 4d77f19c…8117b)

Scope: the counter's ARTIFACT, NOSECRET, SOURCED and specificity legs, and whether the T6–T9 trial verdicts they gate can be made to pass while the claimed mechanic is absent. Counter and plan were not edited; the lane copy was never written. The counter was copied to scratch and every mutant is a one-line change to that copy. Each fixture is `controls/p1` (or a copy) with one targeted change to its trial or corpus files. Every run is `bash <counter> --tree <fixture>`. The frozen counter was run on every fixture as the reference.

Verified before use: the frozen counter on `controls/p1` gives `value=4 rc=0`, matching the receipt. The pinned `bao` (sha256 9c5f3628…b788, OpenBao v2.7.2) was used for every real-run leg; the `bao` in every fixture run is a wrapper script that execs the real binary, as the counter does.

## Table: mutant, fixture, frozen value, mutant value, verdict

Frozen value is the counter run on the fixture. Mutant value is the mutated counter run on the same fixture. "killed" means frozen < 4 and mutant = 4 (a fixture separates them). Evidence: `.ufo/waves/round-71/w1/R71MutTester/matrix/` (receipts) and `diffs/` (exact changes).

| # | mutant (single change to the counter copy) | fixture (change to p1) | frozen | mutant | verdict |
|---|---|---|---|---|---|
| M1 | ARTIFACT T7 drops `! vfy t7-default.pem t7-leaf.pem` | f-m1: trial mints a same-subject, same-key twin CA (openssl); leaf verifies against both certs, fingerprints differ, only second CRL lists the leaf | 3 (T7 art=0) | 4 | killed |
| M2 | ARTIFACT T7 drops `! lists t7-default-crl.pem <serial>` | f-m2: honest revoke on `r71second`; default CRL re-signed with the exported default root key and lists the leaf; verdict forced by wrapper grep for `issuer_ref` (SH7 → BROKEN) | 3 (T7 art=0) | 4 | killed |
| M3 | ARTIFACT T8 `ocsp_is` accepts `good` or `revoked` for the leaf | f-m3: offline-minted OCSP DER for the revoked leaf says `good` (signature valid) | 3 (T8 art=0) | 4 | killed |
| M4 | ARTIFACT T8 drops only the `grep -qx 'Response verify OK'` line | f-m4: OCSP responses signed by an attacker key, correct status words | 3 (T8 art=0) | 3 | **survives** (redundant; see MT-2) |
| M4b | ARTIFACT T8 `ocsp_is` with no signature requirement at all (no verify grep, no `|| return 1`) | f-m4 | 3 (T8 art=0) | 4 | killed |
| M5 | ARTIFACT T6 drops `issuer lifetime < 36000` | f-m5: 20h truncate issuer, 30h leaf request (role max 48h); leaf NotAfter == issuer NotAfter | 3 (T6 art=0) | 4 | killed |
| M6 | ARTIFACT T9 drops `crlok t9-crl.pem t9-issuer.pem` | f-m6: T9 CRL signed by a fresh key, issuer name copied from the root, lists the real leaf serial | 3 (T9 art=0) | 4 | killed |
| M7 | NOSECRET drops the evidence-dir scan | f-m7 (= control F6): T9 private key copied into evidence | 0 (nosecret=0) | 4 | killed |
| M8 | SOURCED drops the S173 URL conjunct | f-m8: S173 registry row URL replaced in `corpus/SOURCES.md` | 0 (sourced=0) | 4 | killed |
| M9 | specificity loop removed (`spec` never 0) | f-m9: T7 also prints BROKEN when the wrapper contains `leaf_not_after_behavior` (SH6) | 3 (T7 spec=0) | 4 | killed |
| M10 | real run without the wrapper script | not built (see MT-5) | — | — | not tested |
| M11* | (extra, not in the seat list) trial never attempts revoke-by-serial of the `no_store` leaf; the T9 verdict still prints `serial-revoke-refused` | f-m11: `elif q write pki/revoke …` replaced by `elif false` | **4** | — | **frozen counter passes it — gap** (MT-1) |

Honest control: every mutant run on `controls/p1` gives 4 (receipts `matrix/mutant-*-on-p1.txt`), and the frozen counter gives 4 on p1. No mutant breaks the honest path, so each change is a relaxation, not a broken build.

## Findings

Notes on method. Fixtures M1–M4b, M6 and M11 are forged evidence or forged verdicts. The counter reads evidence files and trial verdict lines that the same-uid trial writes, so these fixtures are within the named ceiling (`plans/round-71.md`, "a same-uid trial can … mint look-alike certificates, CRLs and OCSP responses"). They show what each conjunct does; they do not show a new route to a false pass beyond that ceiling, except MT-1, which needs no forgery.

MT-1 (falsifies-wording): the T9 verdict claims "a no_store leaf refused revocation by serial", and the knowledge entry's measured row says "a `no_store` leaf refused by serial was revoked by proof of possession". The frozen counter does not check the refusal. Its ARTIFACT leg `art9` checks only that the PoP-revoked leaf is on the issuer's CRL, and SH9 (dropping `private_key`) breaks the PoP step, not the serial step. So a trial that never attempts revoke-by-serial and prints `TRIAL T9 HOLDS serial-revoke-refused …` still scores the full value. Receipt: `matrix/frozen-on-f-m11.txt` (`counter-frozen.sh --tree fixtures/f-m11` → `value=4 discriminating=4 … T9:real=HOLDS,shim=BROKEN,spec=1,entry=1,art=1,ok=1`); the wrapper run prints `TRIAL T9 HOLDS serial-revoke-refused pop-revoked serial-on-crl`. Trial diff: `diffs/trial-f-m11.diff`. This is the "count does not prove the observable" class from round 70, which the round-71 ARTIFACT leg does not close for the refusal sub-claim. Remedy for the successor counter: a shim that makes revoke-by-serial succeed (e.g. drop `no_store=true` from the role), or an artifact that records the serial-revoke error text and is checked.

MT-2 (neutral): M4, the literal removal of `grep -qx 'Response verify OK'`, survives. `ocsp_is` also has `|| return 1` on the `openssl ocsp -respin` exit status, and `openssl ocsp` exits 1 on a failed responder signature (observed: "Response Verify Failure", rc=1, with the status line still printed). The explicit grep is therefore redundant with the exit gate, not a gap. The signature check holds only while the exit gate stays; M4b (both removed) is killed. Not a wording falsifier.

MT-3 (neutral): ARTIFACT conjuncts M1, M2, M3, M4b, M5 and M6 are each killed only by evidence an honest OpenBao 2.7.2 run never produces (a twin-key CA, a re-signed CRL under the default key, a `good` OCSP for a revoked serial, a 20h-issuer lifetime, an unrelated-key CRL). They are correct checks against a forger, and the honest p1 path is 4 with or without them, so they add no protection against an honest-run regression. This is the ceiling already named in `plans/round-71.md`, not a new gap.

MT-4 (neutral): M7 (NOSECRET evidence scan), M8 (SOURCED URL) and M9 (specificity loop) are each killed by a control: F6 (receipt `controls/receipts/f6.txt`), the new f-m8 (`sourced=0`) and the new f-m9 (`spec=0` on T7). M9's kill needs a trial that reads wrapper bytes to choose its verdict, which is the named ceiling's class (F2), so the specificity leg is only as strong as the wrapper-bytes ceiling allows.

MT-5 (neutral, coverage gap in this matrix): M10 (real run without the wrapper script) was not built. A fixture that separates it needs a trial that tells a binary `bao` from a script `bao` in the real run and not in the shim runs; that changes the trial's verdict logic class rather than a counter conjunct, and it did not fit this pass. The counter's own header states the wrapper is uniform across real and shim runs, so this is a design property that stays uncovered by mutation here.

MT-6 (neutral): "token-less" in T8 is not a counted property. The trial's OCSP request runs under `unset BAO_TOKEN`, and `openssl ocsp` never reads `BAO_TOKEN`, so the request carries no token by construction. The knowledge entry says this in its own words ("openssl does not read it in any case"). A trial that attached a token would not be caught, and nothing in the counter would notice. Disclosed in the entry; not a wording falsifier.

## Tooling and hygiene

- Tools used, none installed or upgraded: `bash`, `openssl` 3.6.5, `python3` with `cryptography` 50.0.2 (already present), `bao` v2.7.2 at `~/.local/bin/bao` (pinned binary, not replaced). No pacman, no uv, no npm, no cargo.
- No `bao server -dev` was started by hand. Each trial run starts and kills its own server under `setpriv --pdeathsig KILL`. A post-run sweep of `/proc` found no live `bao server -dev`.
- At most two counter runs ran concurrently (the matrix runner used `xargs -P 2`).
- Scratch `/fast/scratch/hyaku/kagi-r71/R71MutTester` removed at the end. Copied into the wave dir: the matrix receipts (`matrix/`), per-mutant counter diffs and per-fixture trial diffs (`diffs/`), the counter's sha256 (`counter-frozen.sha256`, matches the frozen digest), and the fixture trials that carry the findings (`fixture-trials/`).
- No secret: the `diffs/counter-m7.diff` file contains the counter's own evidence regex, not a key; no key, token or `r71-` string is in any receipt.
- No lane file, sibling file, fleet-root file or `~/.omp` file was written. The lane's frozen plan and counter were not edited.

## Conclusion for the C1 claim

The counter's ARTIFACT, NOSECRET and SOURCED legs each separate their conjunct from the honest path (M1–M8 killed). The specificity leg is killed (M9). One gap is real and falsifies wording: the T9 "refused by serial" sub-claim is not counted (MT-1, f-m11 frozen=4). Recommended successor check, not applied here: a T9 artifact or shim that fails the serial-revoke step.

FINDING MT-1 falsifies-wording T9 "no_store leaf refused revocation by serial" is not counted: a trial that never attempts serial revocation (fixture f-m11) scores the frozen counter value=4; no ARTIFACT or shim checks the refusal
FINDING MT-2 neutral M4 literal (drop only the "Response verify OK" grep) survives because openssl -respin's exit gate (rc 1 on verify failure) already enforces the signature; redundant, not a gap
FINDING MT-3 neutral ARTIFACT conjuncts (T7 !vfy default, T7 !lists default, T8 any-status, T8 no-signature, T6 lifetime, T9 crlok) are killed only by forged evidence (fixtures f-m1..f-m6), within the named same-uid ceiling
FINDING MT-4 neutral NOSECRET evidence scan, SOURCED URL and specificity loop are killed by F6, f-m8 and f-m9; the specificity kill needs wrapper-byte reading (named ceiling class)
FINDING MT-5 neutral M10 (real run without the wrapper) was not built; a separating fixture needs a binary-vs-script trial verdict class, outside this pass
FINDING MT-6 neutral "token-less" OCSP is not a counted property; the request has no token by construction (openssl never reads BAO_TOKEN); disclosed in the entry

SEAT-STATUS: partial M10 not built (needs binary-vs-script trial fixture); all other mutants built and run; MT-1 gap is verified on the frozen counter
