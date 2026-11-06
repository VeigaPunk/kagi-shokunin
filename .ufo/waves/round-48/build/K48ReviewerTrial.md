# K48ReviewerTrial — independent review of the C1 reference trial

- Seat: K48ReviewerTrial (kagi round 48, attempt 1). Date: 2026-11-06.
- Target: `.ufo/waves/round-48/controls/fixtures/ref-sops-age-trial.sh` (173 lines) as the C1
  candidate for `corpus/sops-age-trial.sh`; entry `corpus/knowledge/sops-age-key-rotation.md`;
  rows S009/S010/S011 in `corpus/SOURCES.md`; frozen counters `plans/round-48-c1.sh`,
  `plans/round-48-c2.sh`.
- Binaries verified before any run (pins match the frozen counter and the assignment):
  `sha256sum ~/.local/bin/sops ~/.local/bin/age-keygen` →
  `e5bec3346a873ae91d871550f3e698c1aad962aff462a080e40f25fde17fef6b`,
  `0a0009db842259d6717f7eeb30acb6b90d2a2eb924c6acd0a0db0ca1f1537899`;
  `sops --version --disable-version-check` → `sops 3.13.3`; `age-keygen --version` → `v1.3.2`.
- Method: all legs run in scratch `/fast/scratch/hyaku/kagi-r48/K48ReviewerTrial/…` with
  `trap 'rm -rf -- "$S"' EXIT`; identities generated fresh in scratch per leg; no private key or
  synthetic plaintext printed anywhere (decoy output screened for `AGE-SECRET-KEY`).
- Companion artifact (repro script for the DEK probe): this dir, `K48ReviewerTrial-dek-probe.sh`.

## Verdict up front

The fixture is a sound C1 candidate. All five HOLDS conditions test the documented mechanism with
the right observable, all five designated falsifier shims flip their target test to BROKEN
(measured), refusal bounds hold under a poisoned caller environment (measured), the live run is
5/5 HOLDS rc=0 (measured), and the no-sops SETUP path is rc=2 with no HOLDS line (measured).
Findings below are soundness notes and one residual sufficiency gap (K48RT-02); nothing blocks.

## Per-test soundness (T1..T5)

### K48RT-01 — T1 `updatekeys-add`: HOLDS condition is the right observable. SOUND, with a measured upgrade.

The fixture infers "data key not rotated" (S011 §rotate: "Use updatekeys if you want to add a key
without rotating the data key.") from: updatekeys rc=0 ∧ added recipient B decrypts to the original
plaintext ∧ value lines (`^k[12]: `) byte-identical ∧ MAC line byte-identical.

- BROKEN direction is cryptographically airtight: if the data key changed, AES-256-GCM value
  ciphertexts + tags and the MAC could not be reproduced byte-identically.
- HOLDS direction measured DIRECTLY (beyond inference) by unwrapping the data key — the
  `sops.age[].enc` armor block age-decrypts to the 32-byte data key, hashed, never printed
  (`bash .ufo/waves/round-48/build/K48ReviewerTrial-dek-probe.sh`, snapshots 1→2):
  DEK sha256-16 `5b56e5aa39a9ce05` → `5b56e5aa39a9ce05` (identical) across `sops updatekeys`,
  while `lastmodified` did not advance (same-second) and the MAC line hash stayed
  `4c8f608edec155d3`.
- The alternative observable named in the assignment — comparing `sops.age[].enc` blocks — is
  UNSUITABLE and the fixture rightly avoids it: with the DEK provably unchanged, A's `enc` wrap
  blob changed anyway (`abfb1bb7f260e027` → `61a58ab3cb53e401`, enc_len 385 both), because age
  wrapping uses a fresh ephemeral key per save. `enc` blocks are not a stable fingerprint of
  anything; value ciphertext + MAC are.
- Designated falsifier SH1 (updatekeys also rotates) flips T1 — observed:
  `TRIAL T1 BROKEN updatekeys-rc=0 added-recipient-rc=0 values-unchanged=no mac-unchanged=no`.

### K48RT-02 — T2 `rotate`: HOLDS is necessary for the S011 §rotate claim but NOT sufficient for its "new data encryption key" half. RESIDUAL GAP (no fixture change; frozen).

HOLDS = rotate rc 0 ∧ both value lines changed ∧ plaintext preserved. This catches the designated
falsifier SH2 (rotate no-op) — observed: `TRIAL T2 BROKEN rotate-rc=0 k1-changed=no k2-changed=no
decrypt-rc=0` — and the plaintext-preservation half is correct. But "both values changed" cannot by
itself distinguish *new DEK* from *same DEK re-encrypted with fresh nonce/ephemeral material* —
and K48RT-01's probe shows sops 3.13.3 produces fresh wrap material on every save, so a shim that
"rotates" by re-saving under the old DEK would pass T2. On the pinned binary the documented
mechanism does hold, measured directly: across `sops rotate -i` the unwrapped DEK hash changes
`5b56e5aa39a9ce05` → `fd34d55b876c63d5` (probe snapshots 2→3), the MAC line changes
(`4c8f608edec155d3` → `7b5acc003d67d276`), and `sops decrypt --extract '["k1"]'` still returns
`synthetic-trial-value-one` (rc=0). Recommendation (entry Measured-section wording, not the frozen
fixture): state that T2's HOLDS is re-encryption evidence, and cite the DEK-hash probe as the
new-data-key measurement.

### K48RT-03 — T3 `updatekeys-rm`: SOUND.

Matches S011 compromise-order step 1 (remove from rules, then updatekeys) and upgrades the entry's
[INFERENCE] that pre-removal copies stay decryptable. HOLDS requires: pre-decrypt by B ok, B
refused (rc≠0) on the synced file, B still decrypts the pre-removal copy, values unchanged. Live:
`TRIAL T3 HOLDS removed-recipient-on-synced-file=refused removed-recipient-on-old-copy=decrypts
values-unchanged=yes`. Falsifier SH3 (updatekeys no-op) flips it — observed:
`TRIAL T3 BROKEN pre-rc=0 updatekeys-rc=0 synced-rc=0 old-copy-rc=0 values-unchanged=yes`.
Defense-in-depth note: SH4 (a decrypt-side plaintext leak) also breaks T3 — its refusal check
catches the leak class (`synced-rc=0` under SH4); the C1 counter only checks the target test, so
this collateral is harmless and actually good.

### K48RT-04 — T4 `rules-only`: SOUND, two soft spots noted (neither affects discrimination).

- The "creation rules edit" is realized as ADDING a `.sops.yaml` (the file was created via
  `--age` with no config present). The entry's [INFERENCE] speaks of editing rules; add-a-config is
  the weaker instance of the same claim. Acceptable; worth a sentence in the Measured section.
- `file-unchanged` (s0=s1) brackets only the `sops decrypt` call, which never writes — a
  near-tautological guard. Harmless.
- Falsifier SH4 flips T4 exactly through its refusal check — observed:
  `TRIAL T4 BROKEN rules-edit-only-rc=0 file-unchanged=yes updatekeys-rc=0 after-rc=0` (the shim's
  stash-and-leak makes the refused identity "decrypt" to the original plaintext, and the fixture's
  `dec()` plaintext-hash guard is what exposes it — the guard is doing real work).

### K48RT-05 — T5 `group-threshold`: SOUND.

Two key groups in `.sops.yaml`, no explicit threshold → measures `shamir_threshold: 2` in the file
(S010 §Key groups: "By default, the threshold is set to the number of key groups") plus the access
consequence: A alone refused, B alone refused, A+B decrypt to the original plaintext. Live:
`TRIAL T5 HOLDS groups=2 shamir_threshold=2 single-group=refused both-groups=decrypts`. Falsifier
SH5 (collapse to one group with both recipients) flips it — observed:
`TRIAL T5 BROKEN shamir_threshold=absent a-only-rc=0 b-only-rc=0 both-rc=0`. Note the counter's
comment is correct that a threshold-1 shim is unreachable (sops 3.13.3 refuses threshold 1), and
T5 catches the reachable collapse via both the metadata line and the access flip. T5 is the only
test that reads a metadata line rather than value ciphertexts — appropriate, since its claim is
about config semantics.

## K48RT-06 — Refusal bounds: VERIFIED (measured, not just code-read).

- Env isolation: the fixture unsets 11 `SOPS_*` vars covering every age identity channel
  (`SOPS_AGE_KEY`, `SOPS_AGE_KEY_FILE`, `SOPS_AGE_KEY_CMD`, `SOPS_AGE_SSH_PRIVATE_KEY_FILE/_CMD`,
  `SOPS_AGE_RECIPIENTS`) plus PGP/KMS/GCP/Azure/Vault/HC-Vault channels, then repoints
  `HOME`/`XDG_CONFIG_HOME` into the scratch tree and sets `SOPS_DISABLE_VERSION_CHECK=1` (no
  update phone-home). Decoy leg: caller env poisoned with a real scratch-generated decoy identity
  on all four age channels (`SOPS_AGE_KEY`, `SOPS_AGE_KEY_FILE`, `SOPS_AGE_KEY_CMD`,
  `SOPS_AGE_RECIPIENTS`), run WITHOUT `env -i` → output byte-identical 5×HOLDS, rc=0, and
  `grep -c 'AGE-SECRET-KEY'` over combined stdout+stderr = 0. The caller's identity is ignored.
- No secret on any output path: `dec()` captures stdout and compares a sha256; on failure the
  captured text is discarded; `report()` echoes verdict tokens only; keygen/pubs never echoed
  (`case "$A$B" in *AGE-SECRET-KEY*) setup_fail "pub-shape"` guards against a keygen shape change).
- Scratch hygiene: everything lives under `mktemp -d` in the `--work` parent, `trap rm -rf` on
  exit; the fixture never touches `git`, the lane, or anything outside its work tree.
- shellcheck: only two info-level SC2094 on `enc()`/T5 encrypt (read `$W/plain.yaml`, write
  `f.yaml` — different files in different dirs; false positive). No unquoted-expansion defects in
  security-relevant positions.

## K48RT-07 — Live legs and exit-code contract: VERIFIED.

Leg 1 — real binaries (`env -i PATH=/home/vgpnk/.local/bin:/usr/bin:/bin`, `--work` in scratch):

```
TRIAL T1 HOLDS updatekeys-rc=0 added-recipient-decrypts=yes values-unchanged=yes mac-unchanged=yes
TRIAL T2 HOLDS rotate-rc=0 both-values-reencrypted=yes plaintext-unchanged=yes
TRIAL T3 HOLDS removed-recipient-on-synced-file=refused removed-recipient-on-old-copy=decrypts values-unchanged=yes
TRIAL T4 HOLDS rules-edit-only=refused file-unchanged=yes after-updatekeys=decrypts
TRIAL T5 HOLDS groups=2 shamir_threshold=2 single-group=refused both-groups=decrypts
SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2
rc=0
```

Leg 2 — poisoned caller env (decoy identity on all four SOPS_AGE_* channels, no `env -i`): same
six lines, rc=0, zero `AGE-SECRET-KEY` occurrences in output.

Leg 3 — no sops on PATH (`env -i PATH=/usr/bin:/bin`):

```
SOPS_AGE_TRIAL: SETUP holds=0 broken=0 error=0 reason=sops-not-on-PATH
rc=2
```

Leg 4 — designated falsifier shims (rebuilt verbatim from the frozen counter's `mkshim` bodies,
run against the fixture):

```
SH1 rc=1: T1 BROKEN (values-unchanged=no mac-unchanged=no)   others HOLDS
SH2 rc=1: T2 BROKEN (k1-changed=no k2-changed=no)            others HOLDS
SH3 rc=1: T3 BROKEN (synced-rc=0) T4 BROKEN (after-rc=1)     rest HOLDS
SH4 rc=1: T4 BROKEN (rules-edit-only-rc=0) + collateral T3, T5 BROKEN
SH5 rc=1: T5 BROKEN (shamir_threshold=absent a-only-rc=0)    others HOLDS
```

All five targets flip to exactly one BROKEN line each; every run still ends in a well-formed
`SOPS_AGE_TRIAL: BROKEN …` line (rc=1), which is what the C1 counter's `verdict()` parses (exactly
one verdict per test per run — holds). Exit-code contract confirmed on all three paths (0/1/2; the
ERROR→rc=2 branch is code-read only — no ERROR occurred in any leg).

## K48RT-08 — Calibration fit with C1/C2: NO CONFLICT.

- C1 DISCRIMINATE needs per test: exactly one HOLDS line (real) + exactly one BROKEN line under
  that test's shim + an entry line `- T<n> ` naming `sops 3.13.3` under `## Measured (round 48`.
  The fixture prints each verdict once per run and stamps `sops=3.13.3` (from field 2 of
  `sops --version`); its `age-keygen=v1.3.2` keeps the leading `v`, which no frozen check cares
  about. The fixture requires the `--work` parent to pre-exist (`work-parent-missing`, rc=2 — hit
  by my own first two legs); the C1 counter pre-creates it (`mkdir -p "$W/tmp"`), but this is a
  future-caller trap worth one line in the Measured section.
- C2: the trial adds no K01–K10 ``cmd` ⇒ `out`` pair and none of the ten C2 exec commands reads
  the trial or the SOPS entry — causal separability as the plan states; no calibration risk.
- Pre-freeze controls receipt is 16/16 MATCH including K1-F5 (a weakened T5 reads discriminating=4,
  not 5), which confirms the counter genuinely depends on each test's individual discrimination —
  and each dependence is now independently verified above.
- Source traceability: T1/T3 rest on the S011 quote stored in SOURCES.md ("Use `updatekeys` if you
  want to add a key without rotating the data key."), T2 on S011 §rotate ("generates a new data
  encryption key and reencrypt all values"), T5 on S010 §Key groups threshold default, T4 on the
  entry's own [INFERENCE] — all four rows are `mined`, `recheck: on-release`, with S033 pinning
  v3.13.3 as the newest stable release (clock not fired).

## Residual risks / verification gaps

1. T2's sufficiency gap (K48RT-02): a same-DEK re-save shim would pass T2. Frozen fixture; mitigated
   by measuring the DEK hash change on the pinned binary (probe) and saying so in the entry.
2. T4's rules edit is config-addition, not config-edit (K48RT-04) — weaker instance of the claim.
3. The ERROR exit path (rc=2 with partial counts) is code-read only; no leg produced an ERROR.
4. `--work` parent must pre-exist (K48RT-08); counter-safe, future-caller trap.
5. The fixture does not verify binary hashes itself — pin enforcement lives entirely in the C1
   counter's PINS gate (by design; standalone runs trust PATH).
6. No-network claim rests on `SOPS_DISABLE_VERSION_CHECK=1` plus offline-observed behavior
   (identical verdicts with `env -i`); not traced with strace.

All scratch trees were removed on exit (trap). No writes outside this build dir and scratch.
