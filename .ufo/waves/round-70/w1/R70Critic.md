Author: R70Critic (critic)

# R70Critic: falsification of C1 wording against the frozen trial and counter

Scope: C1 (coverage, capability acquisition) claim text in plans/round-70.md and the frozen counter plans/round-70-c1.sh (sha256 8412b665ff181265794cd94db4a28f11ef1878d0fe9a77fbff954020fd7192ed, matches the receipt). Candidate tree 0d22555. Seat evidence: `.ufo/waves/round-70/w1/R70Critic/receipts/` (copies of the prefreeze control receipts) and `.ufo/waves/round-70/w1/R70Critic/mytrial.out` (my own trial run).

## Run

`bash corpus/openbao-pki-trial.sh --work <scratch>` (scratch under /fast/scratch/hyaku/kagi-r70/R70Critic, removed on exit), run once:

```
TRIAL T1 HOLDS certificate-returned no-private_key
TRIAL T2 HOLDS requested=86400s lifetime=3630s max=3600s
TRIAL T3 HOLDS outside-cn-refused inside-cn-issued
TRIAL T4 HOLDS serial-on-crl
TRIAL T5 HOLDS no_store-cert-unreadable-unlisted stored-control-readable
OPENBAO_PKI_TRIAL: HOLDS holds=5 broken=0 error=0 bao=v2.7.2 openssl=3.6.5
```
rc 0, about 2 s wall. The trial script is byte-identical to the P1 positive control (sha256 200efcb2…8023d, both paths). The `bao` on PATH has the pinned sha256 9c5f3628…b788.

## What the instrument enforces (the counter's legs, read from plans/round-70-c1.sh)

- Trial verdict per test: `TRIAL Tn HOLDS` on the real binary; `BROKEN` under the test's own shim; `HOLDS` under each other shim (specificity).
- Entry leg `entry_line`: a line in the `## Measured (round 70` section that begins `- Tn ` and contains the substring `OpenBao 2.7.2`. Nothing else in the entry is read.
- SOURCED: a `source:` line naming S170 plus a `mined` status in the S170 SOURCES row. The quote is not located in the capture body by the counter (the QM39 quote-locate gate covers that separately, not this counter).
- NOSECRET, NOLEAK, SETUP_OK, PINS: as frozen.

Anything outside those legs is not enforced by the counter. The trial's own checks are: T1 `certificate` non-empty and `private_key` absent; T2 lifetime <= 3660 s; T3 outside CN refused and inside CN issued; T4 serial string present in openssl-parsed CRL text; T5 `pki/cert/<serial>` read fails and the serial is absent from `bao list pki/certs`, with a stored control readable and listed.

## Sentence-by-sentence classification of corpus/knowledge/openbao-pki-certificate-lifecycle.md

Class key: (a) enforced by trial+counter (a shim would flip it); (b) stated, not enforced; (c) unsupported by any measurement in the lane.

Title (one sentence, four or five general claims)
- "an internal CA key never leaves the mount": (b)/(c). T1 measures one `root/generate/internal` call on one mount. "never" is a general contract; nothing tests other paths.
- "a role's max_ttl clamps (not refuses) a longer request": (a) for the single 24h-on-1h case (T2; SH2 flips it).
- "allowed_domains refuses outside names": (a) for one exact domain with allow_subdomains (T3; SH3 flips it). The title states it generally; the Does-not-establish list narrows it.
- "revocation lands on the CRL": (a) for one serial on one mount (T4; SH4 flips it).
- "no_store certificates cannot be found by serial": (a) for the read-and-list path only (T5; SH5 flips it).

Why table
- "T1: response has certificate, no private_key": (a).
- "exported returns the CA private key in an API response — it is then in logs, shells and clipboards": (c). The logs/shells/clipboards consequence is rhetoric, not measured.
- "(or an external KMS)": (c) recommendation, not measured.
- "T2: a 24h request on a max_ttl=1h role is issued, clamped to 1h, with a warning": "issued" and "clamped to 1h" are (a) within the 3660 s bound; "with a warning" is (b), see below.
- "callers that read only the exit status believe they got 24h": (c). No test reads what a caller believes.
- "without max_ttl the mount/system max applies": (c). Not measured; no shim or test covers an absent max_ttl.
- "T3: evil.example refused, ok.r70.test issued": (a).
- "allow_any_name=true lets the role sign any CN": (a) only via SH3, which adds allow_any_name to the trial's role. The "any CN" generalisation is outside the one-domain measurement.
- "T4: the revoked serial is on the mount CRL": (a).
- "a revoke that never reached the server leaves the serial off the CRL": (a) in the sense that SH4 flips T4.
- "T5: the no_store leaf is not readable at cert/<serial> and not listed; a stored control is": (a).
- "a no_store leaf cannot be revoked by serial — the only bound left is its TTL": (c). T5 never calls revoke on a no_store leaf. The statement rests on the S170 quote only, and the lane does not measure it.
- Why-table "safe default" column ("role max_ttl set explicitly", "never allow_any_name", "only for short-lived, never-revoked leaves"): prescriptive guidance, not measured. Neutral as guidance, but it is presented in the measured table.

Measured section (round 70)
- Header "exit 0, OPENBAO_PKI_TRIAL: HOLDS holds=5 broken=0 error=0": (a). Reproduced by my run above.
- T1 "returned certificate, issuer_id, key_id and no private_key field": (a) for certificate and private_key absence. (b) for issuer_id and key_id, which no leg reads.
- T1 "the same call on .../exported returns private_key and private_key_type": private_key is (a) indirectly, because SH1 turns the call into exported and T1 then reads BROKEN only if private_key is present. private_key_type is (b).
- T2 "exited 0": (a) in effect. T2 HOLDS requires the issue command to succeed, else ERROR.
- T2 "issued a leaf whose notAfter − notBefore is 3630 s": the exact 3630 is (b). The trial only enforces <= 3660, and the counter does not read the number. My run printed 3630 s; that is one observation, not a leg.
- T2 "(1h plus the engine's 30 s notBefore backdate)": (c) as a causal attribution. Nothing in the lane measures the backdate; the 30 s is the inferred gap between 3630 and 3600. Note that the lifetime is printed, the backdate is not.
- T2 "with the response warning `TTL "24h0m0s" is longer than permitted maxTTL "1h0m0s", so maxTTL is being used`": (b). The trial never captures issue stdout or stderr beyond the JSON; the warning is not read by any test or leg, and no receipt in the lane contains the warning text. I did not re-check the warning against a live bao run in this seat.
- T2 "The API page's 'Cannot be greater than the role's max_ttl value' is therefore enforced as a clamp, not a refusal": (a) for the clamp; "is therefore enforced" reads the doc sentence as a contract, which is a generalisation beyond one role and one call.
- T3 "common_name=evil.example was refused (non-zero exit)": (a) for refusal; the "non-zero exit" wording is (b), since the trial tests `q` (exit status discarded) and never reads the exit code value.
- T3 "with allow_any_name=true added (shim SH3) the outside name is issued": (a) via SH3's BROKEN verdict.
- T4 "pki/revoke serial_number=<serial> returned `state revoked`": (b). The trial discards revoke output (`q write`). The string `state revoked` appears only inside shim SH4's fake output in the counter; no test reads the real server's state field.
- T4 "the serial appears in openssl crl -text of the CRL read from pki/cert/crl": (a).
- T5 "absent from pki/certs and pki/cert/<serial> answers 'No value found'": absent from pki/certs is (a); the "No value found" text is (b). The trial checks only that `q read` fails (nonzero exit).
- T5 "a leaf from an otherwise identical stored role is listed and readable": (a) (stored control).

Does not establish
- All entries are honest negative scopes (HashiCorp Vault, intermediates, cross-signing, leaf_not_after_behavior, ACME, OCSP, delta CRLs, auto-tidy, BYOC, CRL honoured by relying parties, glob/wildcard/IP/URI SANs, no_store performance). Neutral. The counter does not enforce them, and it need not.

Falsifiers list
- The five falsifiers correspond to SH1–SH5 and are (a). Item 2 says "or is refused outright", which SH2 does not test; it tests only the longer-lifetime branch. Neutral.

## Findings against the claim wording

CR-1 (falsifies-wording): The frontier claim "the lane can execute the OpenBao PKI certificate-lifecycle mechanics its knowledge entry documents" exceeds what the counter measures. The counter counts five boolean verdicts on five chosen behaviours. The entry documents many more mechanics (the Why-table failure modes, the warning text, the exact 3630 s, the revoke state string, the backdate attribution, the no_store revoke bound). "Lifecycle" also implies issue, renew, expire and tidy; none of the lifecycle transitions beyond issue and revoke are exercised. The narrowest honest wording is: "the lane executes five OpenBao 2.7.2 PKI behaviours (T1–T5) named in the entry's Measured section, each against a falsifier shim".

CR-2 (falsifies-wording): Title "an internal CA key never leaves the mount" states a general contract; T1 measures one call on one mount. Narrow to: "root/generate/internal returned no private_key in OpenBao 2.7.2's dev server, one call measured".

CR-3 (falsifies-wording): Title "allowed_domains refuses outside names" and the Why-table "allow_any_name=true lets the role sign any CN" generalise from one exact domain with allow_subdomains (T3). Narrow to "one domain (r70.test) with allow_subdomains: a CN outside it was refused".

CR-4 (falsifies-wording): The exact "3630 s" and the causal "30 s notBefore backdate" are presented as measured. The counter reads only the substring `OpenBao 2.7.2` on a line starting `- T2 `; any text with that prefix passes the entry leg, so the 3630 figure and the backdate attribution are not enforced. The trial enforces only <= 3660 s. Narrow to: "lifetime 3630 s on the one measured run (bound <= 3660 s is what the trial enforces); the 30 s backdate is not measured".

CR-5 (falsifies-wording): The quoted warning text "TTL ... so maxTTL is being used" has no enforcing leg, is not captured by the trial, and no receipt in the lane carries it. Narrow to: "issued with a lifetime <= 3660 s; a warning is reported by the server (not captured by the trial; text not re-verified)" or drop the quote.

CR-6 (falsifies-wording): "returned `state revoked`" is the output of a shim's fake, not a trial read. The string `state revoked` in the knowledge entry is therefore unenforced, and the only place that string exists in the instrument is inside SH4's body. Narrow: drop "state revoked" or mark it as an unread observation.

CR-7 (falsifies-wording): Field-list claims beyond `certificate` and absence of `private_key` (issuer_id, key_id, private_key_type) are not read by any leg. Narrow the T1 sentence to the two fields the trial reads.

CR-8 (falsifies-wording): "answers 'No value found'" (T5) is not checked; the trial checks only that `bao read` fails. Narrow to "the read fails (nonzero exit)".

CR-9 (falsifies-wording): T3 "refused (non-zero exit)": the trial tests refusal through `q`, which discards the status value. The claim is coarse-true (refusal is what the test checks), but the "non-zero exit" quantity is not read. Narrow to "refused".

CR-10 (falsifies-wording): Unsupported statements in the Why table and the no_store row: "a no_store leaf cannot be revoked by serial — the only bound left is its TTL", "without max_ttl the mount/system max applies", "callers that read only the exit status believe they got 24h", the KMS recommendation, and the logs/shells/clipboards consequence. None is measured. Either mark them as S170/S171-sourced statements (quote the source) or remove them from the measured table.

CR-11 (falsifies-wording): The C1 axis name "coverage" implies a fraction of the PKI surface. The value is a count of five self-selected tests (target 5, BASE 0), with no denominator of PKI operations. The value cannot distinguish a 5-of-5 self-chosen set from a 5-of-50 surface. Under QM41 the axis label is frozen, so this is a wording/label attack, not a counter attack. Narrowest honest axis wording: "capability" with the note "5 of 5 self-selected T1–T5"; or keep "coverage" and state the denominator as "the five behaviours chosen in S170".

CR-12 (neutral): The BASE control F0 exercises only the absent-trial exit (counter lines 70–72), which runs before any shim is built and before the entry or SOURCED legs. F0 therefore shows value=0 on a no-work tree, which is a valid do-nothing reading; it does not exercise the discrimination code. The discrimination code is exercised by F1–F4 and P1 on the candidate-shaped fixtures. Neutral: F0 is adequate for "BASE 0", not for "the counter cannot be fooled by a no-work tree that contains a trial".

CR-13 (neutral): Receipt provenance. `.ufo/waves/round-70/controls/receipts/README.txt` discloses that f5.txt reaped-process lines had the dead throwaway dev-server root token masked after the run. The counter-side `value` and legs are unchanged, but the f5 receipt is not raw run output. Neutral for C1 wording (the claim does not cite receipt bytes); noted because the seat rule is "receipts are as produced".

CR-14 (neutral): The "Named ceiling" in the frozen plan (a trial that reads the shim's own bytes can pass the specificity leg) is honest. I checked the landed trial: it reads no bytes of the bao binary and reads only JSON fields and openssl output. Neutral.

CR-15 (neutral): Pinned to OpenBao 2.7.2 with the binary sha pin. The entry and claim are scoped to 2.7.2 in the Scope paragraph. Honest.

Nothing in the trial or counter reads a secret or token, and I found no leak in my run (the trial prints no token or key).

## Summary of how the instrument falsifies the claim wording

The instrument makes real claims (a)-class for five boolean behaviours, each with a falsifier shim and a specificity check. It does not enforce the numbers, quoted strings, causal attributions, and general contracts that the knowledge entry states around those five behaviours. The C1 claim sentence ("executes the mechanics its knowledge entry documents", "coverage") is wider than the five verdicts; the frozen predicate itself is narrower and honest, so the overreach sits in the claim's summary sentence and in the entry's prose.

FINDING CR-1 falsifies-wording claim sentence "executes the mechanics its knowledge entry documents" exceeds the five measured verdicts and implies lifecycle transitions beyond issue and revoke that are not exercised
FINDING CR-2 falsifies-wording entry title states "an internal CA key never leaves the mount" as a general contract; T1 measures one call on one mount
FINDING CR-3 falsifies-wording title and allow_any_name row generalise allowed_domains from one exact domain with allow_subdomains to any name
FINDING CR-4 falsifies-wording exact 3630 s and "30 s notBefore backdate" are unenforced; entry leg is a substring presence check and the trial enforces only lifetime <= 3660 s
FINDING CR-5 falsifies-wording quoted max_ttl warning text is never captured, read or receipted by the lane
FINDING CR-6 falsifies-wording "returned state revoked" is unread by the trial; the string exists only in shim SH4's body
FINDING CR-7 falsifies-wording T1 field list (issuer_id, key_id, private_key_type) is unread by any leg
FINDING CR-8 falsifies-wording T5 "No value found" text is unread; the trial checks only read failure
FINDING CR-9 falsifies-wording T3 "non-zero exit" is unread; the trial checks refusal through a discarded status
FINDING CR-10 falsifies-wording Why-table consequences (no_store not revocable, without max_ttl mount max applies, callers believe 24h, KMS, logs/shells/clipboards) are unmeasured and presented in the measured table
FINDING CR-11 falsifies-wording axis name "coverage" implies a surface denominator; the value is a count of five self-selected tests
FINDING CR-12 neutral F0 BASE control exits on the absent-trial path before discrimination code runs; adequate as a no-work reading, not as a test of the discrimination logic
FINDING CR-13 neutral f5 receipt token masking after the run is disclosed in README.txt; C1 wording does not cite receipt bytes
FINDING CR-14 neutral named ceiling (shim-byte reading) checked against the landed trial: no read of bao bytes
FINDING CR-15 neutral OpenBao 2.7.2 pin and Scope paragraph honestly bound the claim

SEAT-STATUS: complete (trial run once, rc 0, HOLDS 5/5; full sentence audit done; the one unverified item is the exact max_ttl warning text, which this seat did not re-check against a live server)
