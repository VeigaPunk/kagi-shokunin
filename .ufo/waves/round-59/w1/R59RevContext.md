# R59RevContext — attack seat findings (wave 1)

Seat: revenger, round 59, one v1 wave. Read-only on the lane; writes limited to this file and the
receipts under `.ufo/waves/round-59/build/R59LabratContext/`.

## Target

The plan's C2 POP, T3 and T5 rest on a transit behaviour the plan asserts but nobody measured:
`transit/rewrap` on a convergent key, and `transit/rewrap` against `min_decryption_version`.

Probe: `.ufo/waves/round-59/build/R59LabratContext/probe.md` (verdict, per-leg raw responses,
falsifiers, T1–T5 deltas). Raw evidence: `transcript-run4.txt` (630 lines, canonical; every leg
cited by line), `transcript-run2.txt`, `transcript-run3.txt`, `probe.sh` (re-runnable).

## Verdict on the hypothesis

**HOLDS as stated**, measured on OpenBao 2.7.2 (pinned sha256) with a throwaway `bao server -dev`
under `setpriv --pdeathsig KILL`, three independent servers:

- A convergent key refuses `transit/rewrap` without the context: `400 * missing 'context' for key
  derivation; …`. Wrong context: `400 * cipher: message authentication failed`. Right context:
  succeeds and round-trips.
- A `vault:v1:` ciphertext under `min_decryption_version=2` is refused on rewrap with
  `400 * ciphertext or signature version is disallowed by policy (too old)`; the version gate is
  evaluated before the context and MAC checks, and lowering the value restores the same ciphertext.

**Correction to the mechanism:** the context refusal is the *derived-key* rule, not the convergence
flag. `convergent_encryption=true` cannot be created without `derived=true`
(`400 * convergent encryption requires derivation to be enabled`), and a derived non-convergent key
refuses a context-free rewrap with the byte-identical error. So the sentence is true of convergent
keys only because convergence implies derivation.

## Attack on the plan (reported, not amended)

1. **T3's table row claims something its test cannot show and the engine contradicts.** The
   parenthetical "(so the rewrap did not need a decrypt)" is refuted: rewrap is gated by the
   decryption path (context required for derived keys; MAC failure on wrong context;
   `min_decryption_version` refuses the old version exactly as `transit/decrypt` does). The
   measurable POP line "rewrap migrates ciphertext to the newest version without a decrypt round
   trip" survives if read as "the client never supplies the plaintext", which is what the trial can
   and should assert. **No frozen predicate change is requested** — the POP stays; the explanatory
   sentence must not be repeated in the trial comments, the lesson or the knowledge entry. If T3 is
   extended with a rewrap-after-retirement leg, it must expect the "too old" refusal.
2. **T5's key setup is under-specified.** The trial must create the key with `derived=true` as well
   as `convergent_encryption=true`; the plan's row says only the latter, and the engine refuses that
   combination. And T5's determinism claim must be scoped to one key version: after a rotation the
   same plaintext+context encrypts to a different `vault:v2:` ciphertext. Neither is a POP change;
   both are instrument requirements.

## Also measured (usable by the trial/lesson)

- Rewrap of a convergent ciphertext with the right context is byte-identical to its input at the
  same version, and after a rotation byte-identical to a fresh encryption of the same
  plaintext+context under the new version — a sharper T3/T5 observable than "prefix changed".
- The named `min_decryption_version` error is `ciphertext or signature version is disallowed by
  policy (too old)`; S122 documents that config as controlling what may be *decrypted* and does not
  name rewrap, which is why the rewrap gate is worth recording.
- `convergent_encryption_version` reads `-1` on a freshly created convergent key; S121/S122 do not
  define that value. Recorded as an observation, flagged as inference, not cited as fact.

## Not done

No lane instrument, plan, lesson, SCORECARD or registry file was touched; no git or jj command was
run; no commit. No tool was installed or upgraded. The dev root token was generated per run and
never printed or written. Scratch `/fast/scratch/hyaku/kagi-r59/R59LabratContext/` deleted.

SEAT-STATUS: complete
