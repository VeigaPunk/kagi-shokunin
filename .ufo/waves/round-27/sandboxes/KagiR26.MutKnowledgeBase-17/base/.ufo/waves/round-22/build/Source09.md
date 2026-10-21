# Source09 — S009 re-open and feature-bound adjudication

Seat `KagiR22.Source09` (leaf, read-only; no delegation, no subagent dispatch). Source in scope:
**S009 only**, `corpus/SOURCES.md` §Registry line 15. Associated entry:
`corpus/knowledge/sops-age-key-rotation.md`. Access date **2026-10-20**. No production file,
registry row, stamp, ledger row, gate, or sibling artifact was written; this report is the only
write. Installs: **none**.

Axes: **calibration** (feature-specific source/status/eligibility/product/path decisions on
S009-scoped claims, counted as decisions) and **freshness** (exact pin reconciliation, historic
statement preservation).

## 1. Evidence measured

Page fetched twice on 2026-10-20 (second fetch for byte stability), both identical:

```
GET https://getsops.io/docs/usage/identities/age/
HTTP/2 200 · server: Netlify · date: Tue, 20 Oct 2026 21:37:00 GMT
content-length: 29301 · etag: "1095229ea5f2c31a0d4a6c751b1c1cb0-ssl"
sha256 = a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76
```

Registered S009 pin (`SOURCES.md:15`, frozen base):
`a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76`. **Exact match; no byte
drift.** Both fetches produced 29,301 bytes with that hash; the etag shown is from the second
response, where response headers were captured.

Page revision evidence:

- Page footer (site-wide): “Last modified May 15, 2026: Add page descriptions. (9b7b84e)”.
- Head metadata: `dateModified=2026-05-15T19:05:01+02:00`.
- Full commit `9b7b84e297bdabc9c78e571c1e6db43dcd69454a` resolves in **getsops/docs**, author
  date `2026-05-15T19:05:01+02:00` (2026-05-15T17:05:01Z), subject “Add page descriptions.”
  (patch opened 2026-10-20).
- The commit's diff to the age page is **+1 line only**: front-matter
  `description: You can use age keys to encrypt data.`. The body text is therefore older than
  the footer marker; the served bytes, not the subject line, are the content evidence.
- Page history for `content/en/docs/usage/identities/age/_index.md` shows `9b7b84e` as the
  latest commit; no later docs commit touches this page (checked 2026-10-20).
- The Hugo source at the pinned commit
  (`.../docs/9b7b84e.../content/en/docs/usage/identities/age/_index.md`, 88 lines, 3,169 bytes)
  renders to the same text as the live page; no hidden eligibility note.

Product-status check (for the status qualifier, not for the entry's claims): latest SOPS release
is **v3.13.3, published 2026-07-23T05:27:57Z**; v3.13.1 (2026-05-16), v3.13.2 (2026-06-30) and
v3.13.3 all postdate the page's 2026-05-15 marker. The page declares **no SOPS version**.

## 2. Located quotes (≤25 words each)

URL for quotes 1–8: `https://getsops.io/docs/usage/identities/age/`; accessed 2026-10-20; all in
§Encrypting using age.

| # | location | quote |
|---|---|---|
| 1 | §Encrypting using age, `updatekeys` paragraph | “It is also possible to use `updatekeys`, when adding or removing age recipients.” |
| 2 | §Encrypting using age, identities paragraph | “Each identity will be tried in sequence until one is able to decrypt the data.” |
| 3 | §Encrypting using age, SSH paragraph | “Note that only `ssh-rsa` and `ssh-ed25519` are supported.” |
| 4 | §Encrypting using age, key-file paragraph | “The contents of this key file should be a list of age X25519 identities, one per line.” |
| 5 | §Encrypting using age, SSH command Note | “The output of this command must provide a key that is not password protected.” |
| 6 | §Encrypting using age, `.sops.yaml` paragraph | “A list of age recipients can be added to the `.sops.yaml`” |
| 7 | §Encrypting using age, `--age` paragraph | “You can encrypt a file for one or more age recipients (comma separated)” |
| 8 | §Encrypting using age, default lookup paragraph | “SOPS will look for a text file name `keys.txt` located in a `sops` subdirectory of your user configuration directory.” |

Product-source quotes, used only as qualifiers beyond S009's scope:

| # | location | quote |
|---|---|---|
| 9 | SOPS `CHANGELOG.md` at v3.13.3, §3.13.0 (`https://raw.githubusercontent.com/getsops/sops/v3.13.3/CHANGELOG.md`, opened 2026-10-20) | “`SOPS_AGE_KEY` can now contain space-separated public keys” |
| 10 | SOPS `CHANGELOG.md` at v3.13.3, §3.12.0 (same URL/date) | “Age: support hybrid post-quantum identities” |
| 11 | SOPS `age/keysource.go` at v3.13.3 (`https://raw.githubusercontent.com/getsops/sops/v3.13.3/age/keysource.go`, opened 2026-10-20), constant comment | “can be set as an environment variable with a string list of age keys” |

`keysource.go` `parseIdentity` additionally accepts `AGE-SECRET-KEY-PQ-1` (hybrid post-quantum)
and `AGE-PLUGIN-` identities; the page documents only X25519 key-file contents. This is the
page's under-description, not an entry contradiction (the entry repeats no X25519-only limit).

## 3. Qualifiers carried — status / eligibility / product / path

| qualifier | what S009 says | what the entry carries | verdict |
|---|---|---|---|
| **Status** | Live unversioned docs page; last modified 2026-05-15; no SOPS version, release, preview, beta or GA statement. Footer commit is a docs commit, and for this page a metadata-only +1-line commit. | `source:` header pins the docs commit; `verified-at` says documentation, not measured; `recheck: on-release`. | **Correctly bounded, one qualifier absent:** the page cannot supply a product-version or release-status claim, and the row/entry do not claim one. The page predates current releases; entry claims remain docs-scoped. |
| **Eligibility** | Recipients comma-separated (`--age` or `SOPS_AGE_RECIPIENTS`); key file is X25519 identities, one per line, `#` comments ignored; SSH recipients limited to `ssh-rsa`/`ssh-ed25519`; SSH private key from env file, env command, `~/.ssh/id_ed25519`, `~/.ssh/id_rsa`; command output must not be password-protected. | Carries the SSH **public-key type** limit (lines 37–38). Does **not** carry the X25519/comment rules, the SSH private-key source list, or the password-protection limit. | **No false claim; omission only.** The entry makes no exhaustive-eligibility claim, so this is additive, not an overclaim. |
| **Product** | SOPS docs for SOPS's age backend (`Encrypting with SSH keys via age is also supported by SOPS`); not age-encryption.org docs and not any other product. | Frames the entry “SOPS with age”; the only 1Password/`op run` comparison is separately sourced to `corpus/knowledge/op-env-refs.md` §The pattern/§Two verbs. | **Correct.** No cross-product attribution. |
| **Path** | Default `keys.txt` is per-OS: Linux `$XDG_CONFIG_HOME/sops/age/keys.txt` → `$HOME/.config/sops/age/keys.txt`; macOS `$XDG_CONFIG_HOME/...` → `$HOME/Library/Application Support/sops/age/keys.txt`; Windows `%AppData%\sops\age\keys.txt`. Overrides: `SOPS_AGE_KEY_FILE`, `SOPS_AGE_KEY`, `SOPS_AGE_KEY_CMD` (the command receives `SOPS_AGE_RECIPIENT`). | “a key file in the user configuration directory, overridable by a key-file path, an inline key variable, or a key-producing command”. It asserts no single OS path. | **Correct summary; lossy but not wrong.** One modifier, “inline”, is not located on S009 (see D3). |

## 4. Calibration decisions on S009-scoped claims

Entry read at the frozen base and at the working tree; the entry file is unchanged in both
(`sha256 ea99430f…`, 99 lines, 6,796 bytes). Line references are to
`corpus/knowledge/sops-age-key-rotation.md`.

| # | decision | expected (source-grounded) | observed | verdict |
|---|---|---|---|---|
| D1 | Admit the S009 registry row's scope, anchor and teaching | Tier-A docs row; quote verbatim at named section; revision pin resolves; teaching matches the page | Quote 1 verbatim; commit `9b7b84e…` resolves and touches the page; scope/teaching match | **ADMIT** |
| D2 | Recipient configuration is encryption-side, per file, via `--age`/environment or `.sops.yaml` creation rule (lines 26–28) | Page names all three mechanisms | Quotes 6, 7; `--age` and `SOPS_AGE_RECIPIENTS` named in the same paragraph; `creation_rules:` shown | **ADMIT** |
| D3 | Identity lookup: default user-config `keys.txt`; override by file path, inline key, or key command; identities tried in sequence (lines 33–36) | Page names default + three overrides + sequential trial | Quotes 2, 8; overrides `SOPS_AGE_KEY_FILE`, `SOPS_AGE_KEY`, `SOPS_AGE_KEY_CMD` listed. “inline” is **not** stated by S009; SOPS source confirms `SOPS_AGE_KEY` is a string list (quote 11) | **ADMIT WITH QUALIFIER** — source-scope of “inline” |
| D4 | SSH public keys may be recipients; only `ssh-rsa` and `ssh-ed25519` (lines 37–38) | Page states both | Quote 3; SSH paragraph also says public keys are usable as recipients | **ADMIT** |
| D5 | [INFERENCE] editing creation rules alone leaves existing files' access unchanged until `updatekeys`/`rotate` (lines 30–32) | Inference labelled, and grounded outside S009 | Label present; the sentence cites S011's “stored in the file under the sops section”; S009 alone does not establish file persistence | **ADMIT AS LABELLED INFERENCE** (not S009 evidence) |
| D6 | Registry teaching: “`updatekeys` can apply recipient additions/removals” | Page supports both directions | Prose says “when adding or removing”; worked example demonstrates **addition** (`+++` line) only, with an interactive confirmation | **ADMIT WITH QUALIFIER** — removal is stated, not demonstrated |
| D7 | Any use of S009 as evidence for E1 (1Password Broker status/eligibility) or E3 (Vault/OpenBao lease/TTL) | S009 must be rejected on product/path grounds | §Encrypting using age body has no 1Password/Broker/Vault/OpenBao mechanism text; the only Vault/OpenBao occurrences are sidebar navigation links. The entry's only 1Password reference is separately sourced to `op-env-refs.md` | **REJECT attribution** (QA9/QA10 control) |
| D8 | Add a superseding S009 row | Only if the row's immutable fields are contradicted or the page moved | Row line byte-identical at `c41af82`, `e1544c1`, `c2cab35` and the working tree (hash `b97d9d75…`); page hash matches; no contradiction | **REJECT new row** (no row inflation) |
| D9 | S009 freshness at access date | Registered digest equals live digest | Two fetches, 29,301 bytes, `a840727e…` = registered pin | **CONFIRM FRESH** at the pinned docs revision |
| D10 | Status/version qualifier | A docs page must not be read as a release-status source; on-release trigger checked | Page has no version/release status; latest release v3.13.3 (2026-07-23) postdates the page; row verified 2026-10-19, after that release; no newer release as of 2026-10-20 | **QUALIFIER REQUIRED** — page predates current product; S009 claims unaffected |
| D11 | Path qualifier | Must not collapse OS-specific paths into one | Entry says “user configuration directory” generically; no OS path asserted | **ADMIT** |
| D12 | Product qualifier | SOPS age integration only; SSH-via-age stays SOPS-attributed | Entry title/frame “SOPS with age”; “via age” preserved; no age-docs or other-product claim | **ADMIT** |

Decision count (QM13: decisions, not authored rows): **12 adjudications — 6 admit (D1, D2, D4,
D5, D11, D12), 2 admit-with-qualifier (D3, D6), 2 reject (D7, D8), 1 freshness confirm (D9),
1 qualifier-required (D10).** No count of authored registry rows is offered as calibration
evidence.

### E1/E3 overclaim boundary (scoped, no re-adjudication)

The known E1/E3 failures (uniform Broker preview label, omitted EPM Business eligibility,
Vault/OpenBao clock and path merging) are not repeatable from S009: the page body carries no such
product, plan, path or status text (Vault/OpenBao appears only as a sidebar nav link). My
rejection is an **admissibility** decision about S009, not a re-reading of
S006/S007/S012–S016; those pages were not reopened by this seat, so I make no
claim about their own content or about the round-22 corrections to E1/E3.

## 5. Freshness and pin reconciliation (C2)

- **S009 row pin:** live digest `a840727e…` equals the row's fetch sha256; two fetches identical.
  **No restamp, no superseding row, and no expectation migration are warranted for S009.**
- **Row history (exact):** the `| S009 |` line is byte-identical at `c41af82`, `e1544c1`,
  `c2cab35` and the working tree; line hash
  `b97d9d7517be7431eda3f0d8eb2d20d5340c241857ed21299d42336d05f73477`. No silent rewrite or
  deleted membership.
- **Entry stamp:** `corpus/stamps.tsv:27` records `ea99430f0417f67a644f50309f08f0f4ce42bec526b1d909a6f932b5c7ff81a2`,
  99 lines, 6,796 bytes — exactly the live entry and exactly the frozen-before snapshot
  (`.ufo/waves/round-22/frozen/before/corpus/stamps.tsv:27`). The entry is **not** one of the six
  stale stamps in `.ufo/waves/round-22/before.json`.
- **Entry stamp history (exact):** at `c41af82` the same row read
  `9d73d218aabcfc708fca03bb09221ba6f57f9963b6e6de0df3a975bbf3241599`, 94 lines, 6,257 bytes;
  at `e1544c1` it moved to `ea99430f…`, 99/6,796. The delta is exactly the +5/−0 append of the
  round-21 erratum section (`@@ -92,3 +92,8 @@`), so the expectation change is visible in git,
  not a silent re-pin.
- **Registry stamp history (exact):** `corpus/SOURCES.md`'s own `stamps.tsv` row moved at
  `e1544c1` from `1cd6d240…`/41/13,863 to `db134917…`/43/14,261 (a two-line append); both values
  are recoverable from git and neither was deleted.
- **Historic statements preserved:** the row's `opened 2026-10-19` and the entry's
  `verified-at: 2026-10-19` remain historic reads. Today's identical-byte re-open confirms them;
  it does not rewrite them as a new verification date.
- **Release clock:** the entry's `on-release` trigger is not newly due: the latest SOPS release
  (v3.13.3, 2026-07-23) predates the 2026-10-19 verification, and no later release exists as of
  2026-10-20. The page itself is 158 days old at access and has no later docs commit.
- **Docs-revision nuance:** the footer's `9b7b84e` is a docs-site commit, not a SOPS release; its
  only change to this page was the `description:` front-matter line. The row correctly calls it
  “docs commit”. It should not be read as a content review of the body.

### Integration observation (not S009 content, not executed)

`corpus/SOURCES.md` was being modified in place by another lane during this seat's read. Measured
at 2026-10-20T21:40:39Z:

- HEAD (`c2cab35…`): 43 lines, 14,261 bytes, sha256 `db134917…` — exactly the `stamps.tsv`
  `corpus/SOURCES.md` row.
- Working tree: 66 lines, 18,222 bytes, sha256 `ebf88646…`, `git diff --numstat` +23/−0, 21
  `| S0` rows (S001–S021). Earlier observations were 65/17,417/`e4afe6d0…` and then 66/18,222.
  The `| S009 |` line stayed `b97d9d75…` throughout.
- If that append lands, the `stamps.tsv` row for `corpus/SOURCES.md` and the pinned expectation in
  `corpus/claim-ledger.tsv:52` (`R21-02`, which currently expects
  `rows=16 A=14 … mined=14`) will no longer describe the integrated file. QM14 requires an exact
  old→new migration record and a recomputed expectation, not a silent auto-repin; the final
  counts are unresolved until the integration owner runs the census. This is a flag on another
  lane's in-flight change, not a finding against S009, and no gate was run here.
- The row-count delta is a **pin-expectation** observation only; it is not offered as calibration
  evidence (QM13).

## 6. Falsifier

S009-scoped claims above fail if any of the following is observed:

1. The served page's bytes/hash change, or its footer moves past `9b7b84e`, or §Encrypting using
   age no longer contains quote 1.
2. SOPS documentation or release behavior says `updatekeys` regenerates the data key, or that
   identities are not tried in sequence, or that SSH recipients include types other than
   `ssh-rsa`/`ssh-ed25519`.
3. SOPS documentation defines `SOPS_AGE_KEY` as a *path* rather than key material, or moves the
   default `keys.txt` location/override set.
4. Any corpus claim cites S009 for 1Password Broker status/eligibility or Vault/OpenBao
   lease/TTL behavior (product/path mismatch).
5. A later SOPS release changes age recipient/identity behavior while this page stays at
   `9b7b84e`; a page-hash check alone would miss this, so a product-source check is required at
   the next release.

## 7. Limits and unresolved

- I did not reopen S010/S011 or any E1/E3 source; cross-references in the entry to those rows are
  not re-verified here (out of the assigned S009 scope).
- GitHub's unauthenticated API rate-limited mid-session after the release/commit queries
  succeeded. Latest-release and commit-author facts above come from those successful responses
  and the fetched `CHANGELOG.md` at tag v3.13.3. The **committer** date of `9b7b84e` was not
  verified; the author date is `2026-05-15T19:05:01+02:00`. (A peer report cites committed
  `2026-06-23`; I neither confirm nor rely on it.)
- No SOPS binary was executed; every mechanism statement is documented or source-read, not
  measured on this host.
- The working-tree `SOURCES.md` is mutable by another lane; its final hash and row count are
  unknown. All S009 conclusions are anchored to the `| S009 |` line, which was byte-stable
  across every observation.

## 8. Proposed correction (for the integration owner; no edits made here)

1. **No superseding S009 row.** The page is byte-identical to the registered pin, the row's
   anchor/teaching are accurate, and the entry makes no claim contradicted by the page. A
   duplicate row would add registry width without a new source object.
2. **Optional low-severity append-only qualifier to the entry** (not a rewrite): the word
   “inline” in the identity-lookup sentence is not located on S009; the page only names
   `SOPS_AGE_KEY`. Support is SOPS `age/keysource.go` (string list of age keys). If the parent
   wants strict source-bound wording, either cite that source or mark the clause `[INFERENCE]`.
3. **Optional eligibility additions** (additive, not corrections): S009's X25519/one-per-line and
   `#`-comment rules, the SSH private-key lookup paths, and the password-protection limit are
   absent from the entry. Also record that the page is under-descriptive relative to SOPS
   ≥3.12.0 (hybrid post-quantum and plugin identities) and ≥3.13.0 (space-separated
   `SOPS_AGE_KEY` values).
4. **Pin expectation flag:** if the in-flight `SOURCES.md` append lands, re-stamp `SOURCES.md`
   with a documented old→new migration and recompute `R21-02`'s expected census line; do not
   silently auto-repin. S009's own pin and entry stamp need no change.

## 9. Exact read revision

- Repository base / HEAD: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
- `corpus/SOURCES.md` at HEAD: 43 lines, 14,261 bytes, sha256
  `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332`.
- Working-tree `corpus/SOURCES.md` at 2026-10-20T21:40:39Z: 66 lines, 18,222 bytes, sha256
  `ebf8864654b7cf1669ffb8944d7682cdefbea3234bca3adbbcb32157488f4de2`, `+23/−0`.
- `| S009 |` row line sha256:
  `b97d9d7517be7431eda3f0d8eb2d20d5340c241857ed21299d42336d05f73477`.
- `corpus/knowledge/sops-age-key-rotation.md`: sha256
  `ea99430f0417f67a644f50309f08f0f4ce42bec526b1d909a6f932b5c7ff81a2`, 99 lines, 6,796 bytes
  (blob `e2adc83979fc31f80b6fb2913c6fbb6148ae9ba8`).
- Served S009 page: 29,301 bytes, sha256
  `a840727ea1a8faa05e547f59766f608cbff81b28a66d1507a614d18d25b50b76`, accessed 2026-10-20.
- Docs revision: `9b7b84e297bdabc9c78e571c1e6db43dcd69454a` (getsops/docs), author date
  2026-05-15T19:05:01+02:00.
- Product release read: SOPS v3.13.3, 2026-07-23T05:27:57Z; `CHANGELOG.md` at tag v3.13.3 and
  `age/keysource.go` at v3.13.3.
