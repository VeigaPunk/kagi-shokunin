# K48CriticCeiling — round 48, attempt 1 (kagi)

Scope: C1 counter ceiling probe (numeric) and real sops 3.13.3 blind spots not covered by
`corpus/sops-age-trial.sh` T1–T5. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE
`76da518fcc3029e738648bd6fd4ba5571df01c1c`. No lane file was edited; all work in scratch
`/fast/scratch/hyaku/kagi-r48/K48CriticCeiling`. Tools were not installed or replaced; the pinned
binaries were used in place (`sops` sha256 `e5bec334…7fef6b`, `age-keygen` sha256 `0a0009db…37899`,
re-verified with `sha256sum` in this seat, matching the counter's pins). Every identity was generated
in scratch; no private key, real secret, vault or account was touched; receipts contain no
`AGE-SECRET-KEY` (grep rc=1, below).

## 1. Ceiling probe — the shim-detecting trial passes, value 5

Ceiling named in `plans/round-48.md` §C1: "a trial that detects the counter's shims (e.g. by reading
its own PATH or the shim bytes) and answers BROKEN only under them passes". Probe script
`.ufo/waves/round-48/build/K48CriticCeiling.cheat-trial.sh` (sha256 `9722efe8…6d50`):

```bash
s=$(command -v sops 2>/dev/null) || { echo "SOPS_AGE_TRIAL: SETUP holds=0 broken=0 error=0 reason=sops-not-on-PATH"; exit 2; }
magic=$(head -c2 -- "$s" 2>/dev/null)
if [ "$magic" = '#!' ]; then
  for i in 1 2 3 4 5; do echo "TRIAL T$i BROKEN shim-detected(magic=$magic path=$s)"; done
  echo "SOPS_AGE_TRIAL: BROKEN holds=0 broken=5 error=0 sops=shim age-keygen=shim"; exit 1
fi
for i in 1 2 3 4 5; do echo "TRIAL T$i HOLDS real-binary(magic=$(printf %s "$magic" | od -An -tx1 | tr -d ' '))"; done
echo "SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=real age-keygen=real"; exit 0
```

Tree assembled as specified: `corpus/knowledge/sops-age-key-rotation.md` = the entry with
`controls/fixtures/ref-entry-measured.md` appended; `corpus/sops-age-trial.sh` = the script above.

Command (absolute paths, run from the fleet root):

```
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-48-c1.sh \
  --tree /fast/scratch/hyaku/kagi-r48/K48CriticCeiling/tree
```

Exit code 0; stdout verbatim (receipt `K48CriticCeiling.counter.txt`):

```
C1_SOPS_AGE_TRIAL: value=5 discriminating=5 pins=1 setup_ok=1 nosecret=1 real_rc=0 none_rc=2 T1:real=HOLDS,shim=BROKEN,entry=1,ok=1 T2:real=HOLDS,shim=BROKEN,entry=1,ok=1 T3:real=HOLDS,shim=BROKEN,entry=1,ok=1 T4:real=HOLDS,shim=BROKEN,entry=1,ok=1 T5:real=HOLDS,shim=BROKEN,entry=1,ok=1
```

**Value = 5.** The ceiling is confirmed numerically: the probe never executes `sops` or
`age-keygen` (it only reads the first two bytes of the file `command -v sops` resolves to — ELF
magic under the real bin dir, `#!` under each shim), yet it satisfies every conjunct: real run
prints one HOLDS per T1–T5, each shim run one BROKEN, the entry has the five `## Measured (round 48`
lines, the no-sops PATH run exits 2 with no HOLDS, and no run prints the secret prefix. The entry
half of the predicate is satisfied entirely by the fixture file, so the counter's value here
measures shim detection alone. The second named ceiling (an explicit `--config` bypassing SH5) was
not run — not required by this seat; it remains [UNMEASURED].

## 2. Blind spots — executed sops 3.13.3 behaviours the trial does not test

All runs: throwaway `age-keygen` identities in scratch, `env HOME=<scratch>/home` per command,
`SOPS_DISABLE_VERSION_CHECK=1`, `SOPS_AGE_KEY_FILE` pointing at scratch key files. Repo cwd was
never used as a work dir; each experiment `cd`'d into its own scratch dir. Full transcripts in the
receipts named under each item.

### B1 (strongest) — `updatekeys` on a Shamir key-group file needs the OLD access set at sync time

Entry sentence narrowed: §Compromise order step 1 — "Remove the key from its key group in the
config, then sync each file (`updatekeys`) so the compromised key loses access to the per-file data
key." The entry states no precondition; the trial's T1/T3/T4 use non-group `age:` files, where any
one recipient unwraps the data key, and T5 never calls `updatekeys` at all.

E7 — file encrypted with `key_groups: [[A],[B]]` (threshold 2), config rewritten to one group `[A]`,
`updatekeys` run with A's identity only:

```
run env SOPS_AGE_KEY_FILE="$D/a.key" sops updatekeys --yes f.yaml
rc=128
... Recovery failed because the file was encrypted with a Shamir threshold of
2, but only 1 part(s) were successfully recovered, one for each successful
key group. In order for SOPS to recover the file, at least 2 groups have to
be successful. ...
-- threshold after: 2
-- A+B still decrypt (compromised key retains access): rc=0
```

E8 — same file class, same rule edit, `updatekeys` run with the OLD set A+B present:

```
run env SOPS_AGE_KEY_FILE="$D/ab.key" sops updatekeys --yes f.yaml
rc=0   (last lines: "--- age1a2kx3…" / "File …/f.yaml synced with new keys")
-- threshold after: 1
-- values unchanged by updatekeys: yes
-- A alone decrypts after: rc=0
-- B alone refused after: rc=128
```

E9 — replacement of a group member (`[A],[B]` → `[A],[C]`): `updatekeys` with new-only A+C exits
`128` (same threshold-2 recovery failure); with A+B+C exits `0`; afterwards B+C is refused (`rc=128`)
and A+C decrypts (`rc=0`).

Bearing: the revocation recipe works only where the file's old threshold is still recoverable — i.e.
the removed key's material must be on the syncing host. Run where only the new/remaining keys are
available, `updatekeys --yes` fails closed with rc=128 **and the file is left untouched** (threshold
2, value ciphertexts unchanged), so the compromised key keeps its access while the operator sees a
non-zero exit after the "changes will be made" banner. That is a real operational narrowing of the
compromise order and is invisible to T1–T5.

### B2 — `updatekeys` when the creation rule no longer matches the file

Entry sentence narrowed: the [INFERENCE] "Editing creation rules alone therefore leaves existing
files' access unchanged until `updatekeys` (or `rotate`) is run on each file." T4 tests a rule edit
that keeps the path regex matching and changes recipients; it never tests a rule edit that stops
matching.

E1: file `f.yaml` encrypted to A under `path_regex: f\.yaml$`; `.sops.yaml` rewritten to
`path_regex: other\.yaml$`; then

```
run env SOPS_AGE_KEY_FILE="$D/a.key" sops updatekeys --yes f.yaml
2026/11/06 17:21:12 Syncing keys for file .../e1/f.yaml
error loading config: no matching creation rules found
rc=1
-- file still decrypts with A after refused updatekeys: rc=0
```

Bearing: "until `updatekeys` is run" is conditional on a still-matching rule. A rule edit that
stops matching leaves the file unchanged *and* leaves the sync path inoperative (rc=1); the operator
must restore a matching rule or use `rotate --add-age/--rm-age` instead. Not covered by T4.

### B3 — decrypting a file whose MAC line was edited

Entry has no sentence on integrity; its table row says "secret values inside the file | an edit by
the owner of the credential", and §Direct Editing is cited only for the data-key recommendation.
Receipt: E2 — one character flipped in the `mac:` line's base64 payload (mac-line sha256 before
`052e2f3b…1588`, after `76a1a52c…5b54`), then

```
run env SOPS_AGE_KEY_FILE="$D/a.key" sops decrypt f_bad.yaml
Cannot decrypt MAC: Could not decrypt with AES_GCM: cipher: message authentication failed
rc=51
```

(baseline decrypt of the same file: both values, rc=0). Bearing: the MAC is verified, so an
out-of-band edit of the ciphertext is rejected at decrypt time (rc=51); "an edit by the owner" is
only viable through sops-mediated editing, not a hand edit of the file. A read of the entry alone
does not state this, and no T1–T5 test touches the MAC.

### B4 — `rotate` with `--add-age` and `--rm-age` in one call (confirmation, not a defect)

E4: `sops rotate -i --add-age "$B" --rm-age "$A" f.yaml` → rc=0; value ciphertexts changed
(`k[12]` digest `f2d8da0c…` → `94617658…`); decrypt with B rc=0 (values intact); decrypt with A
rc=128. This matches the round-22 Clarification ("rotate can combine recipient additions/removals
with creation of a new data key and re-encryption") — the §Three different objects table row
(recipient changes only) must be read with that Clarification. No contradiction found.

## 3. Impacted axes, judged against the frozen predicate

- Operability (C1): the ceiling is real and numeric (5). B1 is the decision-relevant gap: the
  compromise-order sentence the entry sells as its operational payload is under-specified exactly
  where the trial has no coverage. B2 narrows the [INFERENCE] the plan lists as one of the two
  decision-relevant readings. B3 is an entry omission (integrity check), lower severity.
- Calibration (C2): untouched — no K01–K10 command reads the trial, the entry's Measured section, or
  these experiments.
- Killed / not killed: nothing here kills C1; value 5 is reachable, and the reference-trial route
  (not the cheat) still has to be produced by the executor. The findings are against the *entry's*
  covered behaviour, routed to the L1; no frozen file was modified.

## 4. Smallest safe correction (routed, not applied)

1. Ceiling: accepted as named; the only guard is the reviewer leg — a trial whose sole sops
   interaction is reading two magic bytes is visible in a read of the script. A numeric guard would
   require changing the frozen counter (e.g. real-run evidence that sops executed); routed to L1,
   not edit here.
2. B1: in the `## Measured (round 48 …)` section (append-only; the kill rule forbids `-` lines in the
   entry), record the precondition: `updatekeys` on a Shamir key-group file must run with enough of
   the OLD fragments to meet the file's current threshold (E7 rc=128 vs E8 rc=0), and the file is
   left unchanged on failure. A T6 exercising this is additive to the new trial and does not affect
   the counter (it greps only T1–T5).
3. B2: same section, one line: a creation rule that no longer matches makes `updatekeys` exit 1
   (`error loading config: no matching creation rules found`) with the file untouched.
4. B3: optional line that the MAC is verified (rc=51) — no ciphertext edit outside sops survives.

## 5. Receipts and integrity

- `K48CriticCeiling.counter.txt` — counter run above (value=5).
- `K48CriticCeiling.cheat-trial.sh` — probe script (sha256 `9722efe8f31022eb3f99e0804e197f73af832ea3125c59549f8179331a586d50`).
- `K48CriticCeiling.experiments1.txt` — flags, E1 (no matching rule), E2 (MAC), E3 (group removal with new-only identity), E4 (rotate combined).
- `K48CriticCeiling.experiments2.txt` — E5/E6 (replacement; updatekeys with old material).
- `K48CriticCeiling.experiments3.txt` — E7/E8/E9 clean isolations.
- Secret-shape check over all receipts: `grep -rE 'AGE-SECRET-KEY-1[0-9A-Z]{58}'` → no output, rc=1;
  `grep -r 'AGE-SECRET-KEY'` → no output, rc=1.
- Scratch `/fast/scratch/hyaku/kagi-r48/K48CriticCeiling` removed after receipts were copied
  (`rm -rf -- "$S"`); trusted `HOME` was passed per command only, never exported into the seat shell.
