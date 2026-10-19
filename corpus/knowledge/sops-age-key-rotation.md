# SOPS with age: recipient access vs data-key rotation vs value rotation

source: S009 (https://getsops.io/docs/usage/identities/age/, §Encrypting using age, last modified 2026-05-15 commit 9b7b84e); S010 (https://getsops.io/docs/usage/identities/key-groups/, §Key groups, last modified 2026-05-15 commit 9b7b84e); S011 (https://getsops.io/docs/usage/key-management/, §updatekeys command, §rotate command, §Direct Editing, §Rotating secrets after a key in a key group has been compromised, last modified 2026-05-15 commit 9b7b84e)
verified-at: 2026-10-19 (the three rendered getsops.io pages above, read in full; the raw upstream README.rst was also opened and is not cited — it now carries no usage text, only a pointer to getsops.io)
recheck: on-release — on a SOPS release or a change to the pages' "Last modified" footer (9b7b84e), re-open S011 §updatekeys/§rotate/§compromise order, S010 §Key groups threshold default, S009 identity lookup
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
