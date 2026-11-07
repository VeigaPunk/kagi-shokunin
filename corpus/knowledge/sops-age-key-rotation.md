# SOPS with age: recipient access vs data-key rotation vs value rotation

source: S009 (https://getsops.io/docs/usage/identities/age/, §Encrypting using age, last modified 2026-05-15 commit 9b7b84e); S010 (https://getsops.io/docs/usage/identities/key-groups/, §Key groups, last modified 2026-05-15 commit 9b7b84e); S011 (https://getsops.io/docs/usage/key-management/, §updatekeys command, §rotate command, §Direct Editing, §Rotating secrets after a key in a key group has been compromised, last modified 2026-05-15 commit 9b7b84e)
verified-at: 2026-10-19 (the three rendered getsops.io pages above, read in full; the raw upstream README.rst was also opened and is not cited — it now carries no usage text, only a pointer to getsops.io)
recheck: on-release — on a SOPS release or a change to the pages' "Last modified" footer (9b7b84e), re-open S011 §updatekeys/§rotate/§compromise order, S010 §Key groups threshold default, S009 identity lookup
cites: S103, S104 (the release identities of the measured sops and age-keygen binaries named in the body; recorded round 55)
Reverify: R21-02
(R21-02 is the sources-census row: it re-verifies the citation chain only — every id on `source:` resolves to a `mined` row of `corpus/SOURCES.md` whose `used-by` lists this entry. It does not re-open the pages, run SOPS or re-measure any behaviour; `recheck:` is the content clock.)

Scope: the SOPS documentation as served on 2026-10-19. Nothing here was executed
on this host; every mechanism is documented, not measured.

## Three different objects

| object | what changes it | what it does **not** change | source |
|---|---|---|---|
| recipient (who can unwrap the data key) | `updatekeys` against the creation rules, `rotate` add/remove flags, or direct editing | the data key, the encrypted values | S011 §updatekeys, §rotate |
| per-file data key | `rotate` ("generates a new data encryption key and reencrypt all values") | the secret values themselves | S011 §rotate command |
| secret values inside the file | an edit by the owner of the credential | anything SOPS does | S011 §Rotating secrets … compromised |

S011 §rotate command says it plainly: "Use updatekeys if you want to add a key
without rotating the data key." `updatekeys` is an access-set change, not
rotation (QA8).

## Recipients vs identities (age)

- Recipients are encryption-side and per file: given at creation via the age
  option or environment, or listed per creation rule in the config file (S009
  §Encrypting using age). S011 §Adding and removing keys: the key information
  "is stored in the file under the sops section", so an existing file carries its
  own access set. [INFERENCE] Editing creation rules alone therefore leaves
  existing files' access unchanged until `updatekeys` (or `rotate`) is run on
  each file.
- Identities are decryption-side and per host/user: SOPS looks for a key file
  in the user configuration directory, overridable by a key-file path, an
  inline key variable, or a key-producing command; "Each identity will be tried
  in sequence until one is able to decrypt the data" (S009 §Encrypting using age).
- SSH public keys may serve as age recipients; S009 limits this to ssh-rsa and
  ssh-ed25519.

## Key groups and the threshold

- Without key groups the data key is encrypted to each master key, so "if any of
  the master keys is available, the file can be decrypted" (S010 §Key groups).
- With key groups the data key is split by Shamir's Secret Sharing, one fragment
  per group; any key in a group opens that group's fragment.
- "By default, the threshold is set to the number of key groups" (S010 §Key
  groups); it is overridable per invocation or per creation rule.
- Decision consequence: adding recipients *within* a group widens who can open
  that fragment; adding a *group* raises the number of independent custodians
  needed only if the threshold rises with it.

## Compromise order (S011 §Rotating secrets after a key in a key group has been compromised)

1. Remove the key from its key group in the config, then sync each file
   (`updatekeys`) so the compromised key loses access to the per-file data key.
2. Rotate the data key (`rotate`, written in place), then commit.
3. "Only after this is done" rotate the actual credentials in the file —
   otherwise "the compromised key could still have access to those".

S011's footnote narrows the risk of reversing steps 1–2 to two cases: the file is
checked in between the two calls, or the compromised key sits with a cloud
provider that is itself compromised. S011 §Direct Editing separately recommends
rotating the data key when removing keys, because "owners of the removed key may
have add access to the data key in the past" (sic).

## How kagi uses this

kagi does not run SOPS today: `grep -rliE 'sops|openbao|hashicorp' corpus/knowledge
--exclude=sops-age-key-rotation.md --exclude=vault-openbao-token-lease-lifecycle.md`
→ no file, exit 1 (2026-10-19). This entry is a comparison
reference, not adoption. An encrypted-file workflow is a different custody model
from the-janitor's env file: there, the file holds only vault references resolved
by `op run` in the child process at exec time, and access rides on the caller's
`op` authorization (`corpus/knowledge/op-env-refs.md` §The pattern, §Two verbs).
In SOPS the ciphertext of the values travels with the file and access is the
recipient set baked into each file. Compare the two when a workload asks for
encrypted config; never describe one with the other's revocation story.

## Does not establish

- Removing a recipient is not rotation; rotating the data key is not rotating the
  secret values. Only step 3 above changes what a leaked old copy would reveal.
- [INFERENCE] Copies encrypted before step 2 (e.g. earlier commits in history)
  remain decryptable by the old recipient; S011 states the ordering risk, not a
  history-purge procedure.
- Nothing about age's cryptography or key format beyond what the SOPS pages say.
- Nothing about KMS/PGP backends, the SOPS HashiCorp Vault/OpenBao backend, or
  any measured SOPS version on this host.

## Falsifier

A current SOPS page or release in which `updatekeys` regenerates the data key,
`rotate` stops re-encrypting values, the default threshold differs from the
number of key groups, or the compromise section reorders or drops its three steps.

## Erratum (round 21, post-landing critic; appended, text above unchanged)

- §Key groups and the threshold, last bullet: "independent custodians" is superseded by "independent key groups". S010 describes key groups and a threshold of groups; it says nothing about how many people hold them.
- §How kagi uses this: the sweep supports only that no *other corpus knowledge entry* mentions SOPS, OpenBao or HashiCorp; it is not a sweep of host runtime use. Read "kagi does not run SOPS today" as "no kagi corpus entry documents SOPS use".

## Clarification (round 22 — command-specific recipient changes)

The recipient/data-key/value table describes **separate operations**, not
a promise that every command changing recipients leaves the data key
unchanged. S011's rotate operation can combine recipient additions/removals
with creation of a new data key and re-encryption; updatekeys alone is the
recipient-synchronization operation. Generic key-group examples do not
establish independent human custodians or behavior of an existing file's
threshold without its actual configuration. The footer commit is a docs
repository revision, not a measured SOPS release/runtime version.
Reviews: `kagi-shokunin/.ufo/waves/round-22/build/Source10.md` and
`kagi-shokunin/.ufo/waves/round-22/build/Source11.md`. No SOPS execution occurred.

## Measured (round 48 — sops 3.13.3, age-keygen v1.3.2, synthetic identities in scratch)

Measured 2026-11-06 on this host by executing the round-48 trial
`corpus/sops-age-trial.sh` (hardened by seat K48ExecTrial from the frozen
reference fixture `.ufo/waves/round-48/controls/fixtures/ref-sops-age-trial.sh`;
the five test bodies, tokens and output grammar are unchanged). Two throwaway
`age-keygen` identities were generated inside a scratch tree and deleted with
it, over two synthetic values (`k1`, `k2`); `HOME`, `XDG_*` and `TMPDIR` pointed
into that tree and every caller `SOPS_*` variable was unset. Versions read from
the tools: `sops 3.13.3` and `age-keygen` `v1.3.2` (release identities S103,
S104; binaries checked against the release checksums, round-48 receipt
`.ufo/waves/round-48/controls/tool-install.txt`). The trial printed one
`TRIAL T<n> HOLDS …` line per test and ended
`SOPS_AGE_TRIAL: HOLDS holds=5 broken=0 error=0 sops=3.13.3 age-keygen=v1.3.2`
at exit 0. Each test has a designated falsifier shim in `plans/round-48-c1.sh`
(SH1..SH5) that flips it to BROKEN; a HOLDS row excludes that falsifier, it is
not a proof of the mechanism in general.

Supersession note (append-only entry): the `Scope:` sentence above ("Nothing
here was executed on this host; every mechanism is documented, not measured"),
the round-22 Clarification's "No SOPS execution occurred" and the §Does not
establish bullet "any measured SOPS version on this host" describe the entry
before round 48; for the five mechanisms below they are superseded by this
section. `verified-at: 2026-10-19` remains the date the documentation was read;
the documentation itself was re-opened 2026-11-06 (S009/S010/S011 live bodies
byte-identical to the round-21 captures, footer still 2026-05-15 / 9b7b84e;
`.ufo/waves/round-48/build/K48ScoutSources/located-quotes.txt`).

- T1 updatekeys-add: with sops 3.13.3, a file was encrypted to recipient A through a `path_regex` creation rule, B was then added to that rule, and `sops updatekeys -y f.yaml` ran with A's identity; observed `updatekeys-rc=0 added-recipient-decrypts=yes values-unchanged=yes mac-unchanged=yes` — B decrypts to the same plaintext while both `k1:`/`k2:` value ciphertext lines and the `mac:` line hash identically before and after. This measures S011 §`updatekeys` command and §`rotate` command ("Use `updatekeys` if you want to add a key without rotating the data key"), and the *recipient* row of §Three different objects: the access set changes, the data key and the encrypted values do not.
- T2 rotate: with sops 3.13.3, `sops rotate -i f.yaml` ran with A's identity on the same encrypted file; observed `rotate-rc=0 both-values-reencrypted=yes plaintext-unchanged=yes` — both value ciphertext lines changed, and A still decrypts to the byte-identical plaintext. This measures the re-encryption half of S011 §`rotate` command ("generates a new data encryption key and reencrypt all values"). The trial's observable cannot by itself tell a new data key from the old key re-used with fresh nonces; the new-key half was measured separately by unwrapping the data key and hashing it (never printing it): its sha256 prefix moved `5b56e5aa39a9ce05` → `fd34d55b876c63d5` across `rotate` and stayed `5b56e5aa39a9ce05` across `updatekeys` (seat K48ReviewerTrial, `.ufo/waves/round-48/build/K48ReviewerTrial-dek-probe.sh`). The per-recipient `enc` wrap blocks change on every save even when the data key does not, so they are not a fingerprint of the data key.
- T3 updatekeys-rm: with sops 3.13.3, a file encrypted to A and B was copied aside, B was removed from the creation rule, and `sops updatekeys -y` ran; observed `removed-recipient-on-synced-file=refused removed-recipient-on-old-copy=decrypts values-unchanged=yes` — B is refused on the synced file, B still decrypts the pre-removal copy, and the removal left the value ciphertexts unchanged. This measures S011 §Direct Editing and step 1 of §Rotating secrets after a key in a key group has been compromised, and it resolves the [INFERENCE] under §Does not establish: a copy encrypted before the removal (as before a rotation) stays decryptable by the removed recipient, so removal is an access-set change on the file it is run against, not a history purge.
- T4 rules-only: with sops 3.13.3, B was added to the creation rule with no `updatekeys` run; observed `rules-edit-only=refused file-unchanged=yes after-updatekeys=decrypts` — B is refused, the encrypted file's sha256 is unchanged by the rule edit, and B decrypts only after `updatekeys`. This measures the [INFERENCE] under §Recipients vs identities (age) — "Editing creation rules alone therefore leaves existing files' access unchanged until `updatekeys`" — which is now executed rather than inferred.
- T5 group-threshold: with sops 3.13.3, `sops encrypt` ran under a creation rule carrying two key groups (one age recipient each) and no explicit threshold; observed `groups=2 shamir_threshold=2 single-group=refused both-groups=decrypts` — the encrypted metadata records `shamir_threshold: 2`, A alone and B alone are refused, A plus B decrypts. This measures S010 §Key groups, "By default, the threshold is set to the number of key groups", and its decision consequence: a second group adds a required fragment only because the default threshold follows the group count.
- Refusal, measured: with the same two-group rule, sops 3.13.3 rejects an explicit lower threshold — `sops encrypt --shamir-secret-sharing-threshold 1` exits 1, writes no output, and prints `Could not generate data key: [could not split data key into parts for Shamir: threshold must be at least 2]` (the same invocation without the flag succeeds and records `shamir_threshold: 2`). A threshold of 1 over two groups is not a reachable configuration here, which is why T5's falsifier collapses the groups instead of lowering the threshold.

- Narrowing, measured (seat K48CriticCeiling, `.ufo/waves/round-48/build/K48CriticCeiling.md` §2, not part of the trial): (B1) on a two-group file (threshold 2), `updatekeys` after removing a group from the creation rule exits 128 ("only 1 part(s) were successfully recovered … at least 2 groups have to be successful") when only the remaining group's identity is present, and leaves the file untouched — the removed key keeps access; it succeeds only with the old access set present, after which `shamir_threshold` reads 1. So §Compromise order step 1 on a key-group file needs the old threshold's identities on the syncing host. (B2) when the edited creation rule no longer matches the file's path, `updatekeys` exits 1 ("no matching creation rules found") and the file is unchanged; T4's reading holds only for a rule that still matches. (B3) a one-character edit of the `mac:` payload makes `sops decrypt` exit 51 ("Cannot decrypt MAC: … message authentication failed"): a hand edit of the encrypted file is rejected at decrypt time. (B4) `rotate -i --add-age B --rm-age A` re-encrypts the values and moves access from A to B in one call, matching the round-22 Clarification.

Re-run: `bash corpus/sops-age-trial.sh --work <dir>` (throws every identity, plaintext and encrypted file away on exit; needs `sops` and `age-keygen` on `PATH`).

**Does not establish:**

- One host, one version pair: everything above is `sops 3.13.3` with `age-keygen` `v1.3.2` on this host; another SOPS release may implement `updatekeys`, `rotate`, key groups or `--shamir-secret-sharing-threshold` differently, and nothing was run on another platform.
- Synthetic identities and synthetic values only: x25519 identities generated in scratch over two literal test strings; the SSH-recipient path (S009's ssh-rsa/ssh-ed25519 note), passphrase-protected identities and the documented identity-lookup order are not exercised — every decrypt in the trial sets `SOPS_AGE_KEY_FILE` explicitly, so "each identity will be tried in sequence" is untested.
- No KMS, PGP, age-plugin or Vault/OpenBao backend, and no account, `op` or vault contact: the cloud-KMS and HashiCorp Vault paths S011 mentions remain unmeasured.
- No history and no shared custody: the "old copy" of T3 is a local file copy in the same scratch directory, so this measures that a pre-removal copy stays decryptable — not a git history purge, a backup tier, a CI cache or a remote readers' copy.
- A trial that detects its designated shims is a ceiling: T1..T5 passing excludes the five named falsifiers under these conditions; it does not establish that no other implementation or configuration could satisfy the entry's sentences for a different reason.
