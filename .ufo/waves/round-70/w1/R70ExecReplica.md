Author: R70ExecReplica (executor)

# R70ExecReplica — held-out replication of the round-70 C1 PKI trial

## Result

Independent implementation from S170 reaches the frozen counter's target:

- Command: `cd /home/vgpnk/Projects/shokunin/kagi-shokunin && bash plans/round-70-c1.sh --tree /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-70/w1/R70ExecReplica/fixture`
- Output (saved verbatim at `.ufo/waves/round-70/w1/R70ExecReplica/counter-replica.txt`, rc 0 in `counter-replica.rc.txt`, stderr empty):
  `C1_PKI_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1 real_rc=0 none_rc=2 T1..T5: real=HOLDS, shim=BROKEN, spec=1, entry=1, ok=1`
- Direct run of the replica trial against the real bao 2.7.2 (`.ufo/waves/round-70/w1/R70ExecReplica/smoke/real-run.txt`): `OPENBAO_PKI_TRIAL: HOLDS holds=5 broken=0 error=0`, rc 0.
- Replica file: `.ufo/waves/round-70/w1/R70ExecReplica/fixture/corpus/openbao-pki-trial.sh`, with the lane's entry and `SOURCES.md` copied beside it as instructed.

The counter's generality claim survives one independent author: a from-source implementation that never opened the reference trial satisfies all five discrimination legs and the four gate legs (pins, setup, no-secret, no-leak, sourced) without any counter change.

## Independence

I did not open `corpus/openbao-pki-trial.sh` or any `controls/p1` copy. I read the plan, the frozen counter (`plans/round-70-c1.sh`, lines 40-156 after the header), `corpus/QUALITY.md`, the knowledge entry (which the assignment includes in the read list, and which I copied into the fixture as instructed), and the S170 capture body `.ufo/waves/round-70/capture/S170.body` via keyword extraction. The counter's contract was the only spec for the output format; the S170 capture was the only source for engine behaviour.

Note on the copied entry: the fixture's `corpus/knowledge/openbao-pki-certificate-lifecycle.md` is the lane's entry byte-for-byte. The counter's entry leg checks only that a `## Measured (round 70` line starts with `- T<n> ` and contains `OpenBao 2.7.2`; it does not compare the entry's prose to the trial's output. See RX-3.

## Ambiguities the contract left to me

1. **T2 bound.** The counter's T2 result depends on my own pass/fail threshold; the frozen plan says "issued with a lifetime ≤ 1h + 60s", and the counter only reads the trial's HOLDS/BROKEN word. I used `0 < life ≤ 3660` (seconds), matching the plan's stated bound. The measured lifetime on the replica run was 3630 s.
2. **T2 shim-sensitivity.** The SH2 shim drops `max_ttl=` from role writes. My T2 then sees a 24h leaf; the bound check flips it to BROKEN. The counter's shim-run result confirms this (`T2:shim=BROKEN`). Ambiguous only in that the plan does not say which signal is the falsifier; I used the lifetime bound, not a refusal exit code.
3. **Date parsing.** `openssl x509 -startdate` pads single-digit days with two spaces (`Nov  8`). A naive `strptime` on the raw string fails; I normalised whitespace before parsing. The plan does not specify how notBefore/notAfter are to be read, so this was an implementation choice. A replica that fails this step returns ERROR (not HOLDS), which the counter reads as non-discriminating, so the choice is load-bearing.
4. **CRL serial comparison.** `bao` prints serials colon-separated and lowercase; `openssl crl -text` prints them uppercase, undelimited, sometimes with leading zeros. I normalised both sides (strip colons, uppercase, strip leading zeros). The counter does not constrain this; the plan says only "openssl-parsed".
5. **`pki/cert/crl` format.** Reading the CRL with `-format=json` returns the PEM in `data.certificate`. I used that field rather than the raw PEM body; the plan says "read from `pki/cert/crl`" and does not name the format.
6. **Dev server flags.** The plan says "throwaway `bao server -dev`" and does not name the root-token flag. I used `-dev-root-token-id` on a 127.0.0.1 random port, with the token held only in the environment and never printed.
7. **No-bao exit.** The contract says exit 2 with no HOLDS line when bao is absent. My script prints one `OPENBAO_PKI_TRIAL: ERROR ... reason=bao-absent` line and no `TRIAL` lines. The counter accepts that (`none_rc=2`, `setup_ok=1`), so the form of the diagnostic line is not constrained.
8. **Pre-run corrections (by inspection, not by run).** My first draft (a) used `bao secrets enable pki` without `-path=pki`, and (b) parsed the openssl date string without normalising whitespace. I corrected both before the first run. Both defects would have produced ERROR verdicts on a real run, so the counter value would have been below 5. No run of the first draft was executed.

## Operator-facing notes

- No tool was installed or upgraded. Used the existing `~/.local/bin/bao` (OpenBao v2.7.2, the pinned sha256 per the counter's PIN check), `/usr/bin/openssl` (3.6.5), and `/usr/bin/python3`. No pacman transaction.
- Dev servers: the replica trial and the counter both kill their own `bao server -dev`. After the replica run, `pgrep -fa 'bao server -dev'` returned no processes.
- Scratch: `/fast/scratch/hyaku/kagi-r70/R70ExecReplica` was created and removed by trap. The counter's own scratch was removed by its own trap.
- No secret, token, private key, or `r70-<hex>` string appears in any file I wrote. The replica trial's `server.log` (under the scratch `--work`, not copied into the wave dir) was not read.
- No git or jj mutation in the lane or the fleet repo.

## Findings

FINDING RX-1 neutral Independent from-source replica reaches `C1_PKI_TRIAL: value=5 ... rc 0`; the counter did not reject a correct implementation, so the instrument's generality holds for one author.
FINDING RX-2 neutral The T2 pass threshold (`≤ 3660 s`) is chosen by the replica from the plan's prose bound (1h + 60s); the counter reads only the HOLDS/BROKEN word and does not enforce the bound, so a different bound would pass or fail without a counter-visible difference.
FINDING RX-3 neutral The entry leg checks only the `- T<n> ` prefix and the `OpenBao 2.7.2` substring on a `## Measured (round 70` line; it does not compare the entry's stated numbers (e.g. "3630 s") to the trial's output, so an entry that states a wrong measured value would pass the entry leg as long as the trial discriminates.
FINDING RX-4 neutral Five ambiguities the contract leaves open (T2 threshold, date parsing, CRL serial normalisation, CRL read format, dev-server flag) all resolve to implementation choices that the counter does not constrain; the counter's verdict depends on each one being handled correctly, not on which correct handling is chosen.
FINDING RX-5 neutral Not exercised by this seat: the counter's behaviour on a replica that prints the dev root token or leaves its server running (F5/F6 controls); the replica's own cleanup path was exercised only on the success path (server killed by `cleanup` before the final echo).

SEAT-STATUS: complete replica ran to value=5 with the frozen counter; all five findings neutral, no counter rejection or acceptance of a wrong implementation observed.
