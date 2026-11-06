## Measured (round 48 — sops 3.13.3, age-keygen v1.3.2, synthetic identities in scratch)

Measured 2026-11-06 on this host by executing the round-48 trial
(`corpus/sops-age-trial.sh`; the run recorded here used the identical frozen
fixture `.ufo/waves/round-48/controls/fixtures/ref-sops-age-trial.sh`, sha256
`fa281506e343064b8786b59b9626f5ebb9f6d1ce193a3f408b68673db3bdf81c`). Two
throwaway `age-keygen` identities were generated inside a scratch tree and
deleted with it, over two synthetic values (`k1`, `k2`); `HOME` and
`XDG_CONFIG_HOME` pointed into that tree, under `env -i` with every
`SOPS_AGE_*`, `SOPS_PGP_FP`, `SOPS_KMS_ARN`, `SOPS_VAULT_URIS` variable
unset. Versions read from the tools: `sops 3.13.3` (`sops --version
--disable-version-check`, first line) and `age-keygen` `v1.3.2`
(`age-keygen --version`, first line). The trial printed one
`TRIAL T<n> HOLDS …` line per test and ended
`SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2`
at exit 0. Each test has a designated falsifier shim in `plans/round-48-c1.sh`
(SH1..SH5) that must flip it to BROKEN; a HOLDS row is therefore a ceiling,
not a proof.

- T1 updatekeys-add: with sops 3.13.3, a file was encrypted to recipient A through a `path_regex` creation rule, B was then added to that rule, and `sops updatekeys -y f.yaml` ran with A's identity; observed `updatekeys-rc=0 added-recipient-decrypts=yes values-unchanged=yes mac-unchanged=yes` — B decrypts to the same plaintext while both `k1:`/`k2:` value ciphertext lines and the `mac:` line hash identically before and after. This measures S011 §`updatekeys` command and §`rotate` command ("Use `updatekeys` if you want to add a key without rotating the data key"), and the *recipient* row of §Three different objects: the access set changes, the data key and the encrypted values do not.
- T2 rotate: with sops 3.13.3, `sops rotate -i f.yaml` ran with A's identity on the same encrypted file; observed `rotate-rc=0 both-values-reencrypted=yes plaintext-unchanged=yes` — both value ciphertext lines changed, and A still decrypts to the byte-identical plaintext. This measures S011 §`rotate` command, "generates a new data encryption key and reencrypt all values": re-encryption is per value and the secret values themselves are unchanged.
- T3 updatekeys-rm: with sops 3.13.3, a file encrypted to A and B was copied aside, B was removed from the creation rule, and `sops updatekeys -y` ran; observed `removed-recipient-on-synced-file=refused removed-recipient-on-old-copy=decrypts values-unchanged=yes` — B is refused on the synced file, B still decrypts the pre-removal copy, and the removal left the value ciphertexts unchanged. This measures S011 §Direct Editing and step 1 of §Rotating secrets after a key in a key group has been compromised, and it resolves the [INFERENCE] under §Does not establish: a copy encrypted before the removal (as before a rotation) stays decryptable by the removed recipient, so removal is an access-set change on the file it is run against, not a history purge.
- T4 rules-only: with sops 3.13.3, B was added to the creation rule with no `updatekeys` run; observed `rules-edit-only=refused file-unchanged=yes after-updatekeys=decrypts` — B is refused, the encrypted file's sha256 is unchanged by the rule edit, and B decrypts only after `updatekeys`. This measures the [INFERENCE] under §Recipients vs identities (age) — "Editing creation rules alone therefore leaves existing files' access unchanged until `updatekeys`" — which is now executed rather than inferred.
- T5 group-threshold: with sops 3.13.3, `sops encrypt` ran under a creation rule carrying two key groups (one age recipient each) and no explicit threshold; observed `groups=2 shamir_threshold=2 single-group=refused both-groups=decrypts` — the encrypted metadata records `shamir_threshold: 2`, A alone and B alone are refused, A plus B decrypts. This measures S010 §Key groups, "By default, the threshold is set to the number of key groups", and its decision consequence: a second group adds a required fragment only because the default threshold follows the group count.
- Refusal, measured: with the same two-group rule, sops 3.13.3 rejects an explicit lower threshold — `sops encrypt --shamir-secret-sharing-threshold 1` exits 1, writes no output, and prints `Could not generate data key: [could not split data key into parts for Shamir: threshold must be at least 2]` (the same invocation without the flag succeeds and records `shamir_threshold: 2`). A threshold of 1 over two groups is not a reachable configuration here, which is why T5's falsifier collapses the groups instead of lowering the threshold.

Re-run: `bash corpus/sops-age-trial.sh --work <dir>` (throws every identity, plaintext and encrypted file away on exit; needs `sops` and `age-keygen` on `PATH`).

**Does not establish:**

- One host, one version pair: everything above is `sops 3.13.3` with `age-keygen` `v1.3.2` on this host; another SOPS release may implement `updatekeys`, `rotate`, key groups or `--shamir-secret-sharing-threshold` differently, and nothing was run on another platform.
- Synthetic identities and synthetic values only: x25519 identities generated in scratch over two literal test strings; the SSH-recipient path (S009's ssh-rsa/ssh-ed25519 note), passphrase-protected identities and the documented identity-lookup order are not exercised — every decrypt in the trial sets `SOPS_AGE_KEY_FILE` explicitly, so "each identity will be tried in sequence" is untested.
- No KMS, PGP, age-plugin or Vault/OpenBao backend, and no account, `op` or vault contact: the cloud-KMS and HashiCorp Vault paths S011 mentions remain unmeasured.
- No history and no shared custody: the "old copy" of T3 is a local file copy in the same scratch directory, so this measures that a pre-removal copy stays decryptable — not a git history purge, a backup tier, a CI cache or a remote readers' copy.
- A trial that detects its designated shims is a ceiling: T1..T5 passing excludes the five named falsifiers under these conditions; it does not establish that no other implementation or configuration could satisfy the entry's sentences for a different reason.
