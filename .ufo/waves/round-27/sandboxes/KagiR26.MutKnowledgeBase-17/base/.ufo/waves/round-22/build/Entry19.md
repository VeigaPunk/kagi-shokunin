# Entry19 — freshness/calibration audit: `corpus/knowledge/sops-age-key-rotation.md`

Read-only leaf audit. No host gate was executed (ad-hoc read-only digest
comparisons and public GETs only), no SOPS/Vault/op command was run, no package
or configuration change was made, and no install occurred.

## Read state (exact)

| item | value |
|---|---|
| repo | `/home/vgpnk/Projects/shokunin/kagi-shokunin` |
| frozen base | `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD; parent `knmpxnyl`) |
| audit time | 2026-10-20T21:38Z (18:38 −03:00) |
| entry bytes | `sha256 ea99430f0417f67a644f50309f08f0f4ce42bec526b1d909a6f932b5c7ff81a2`, 99 lines, 6796 bytes |
| entry blob | `e2adc83979fc31f80b6fb2913c6fbb6148ae9ba8`; worktree == HEAD (empty diff) |
| stamp row | `corpus/stamps.tsv:27` — path, same sha256, `99`, `6796` |
| stamps file | `sha256 0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b`, 63 rows (the file has no header row) |
| sources read | `corpus/SOURCES.md` rows S009–S011 at HEAD; 16 rows at HEAD |
| concurrency | other seats held four uncommitted tracked files plus untracked round-22 files at snapshot time; the audited file and `stamps.tsv` were not among them |

## Verdict

| axis | finding | decision |
|---|---|---|
| freshness — bytes | stamp sha256/lines/bytes equal current bytes; no stale-byte mismatch | **current** |
| freshness — substance | all three cited pages refetched 2026-10-20 are byte-identical to the recorded fetch digests; footer commit unchanged; no SOPS release since the 2026-10-19 verification | **fresh; no content correction** |
| calibration | entry keeps recipient / data key / values apart; names the documented-not-measured scope; carries falsifier, recheck and two already-appended errata; no product/status/eligibility claim to overreach | **correctly bounded; no new erratum** |
| appended correction needed? | none for content. One provenance asymmetry (§ enumeration) is **not** a contract violation and cannot be repaired in place under contract rule 2 | **no action** |

## 1. Stale-byte check — none

The stamp row is not merely present, it is exact:

```
wc -lc corpus/knowledge/sops-age-key-rotation.md      -> 99 6796
sha256sum corpus/knowledge/sops-age-key-rotation.md   -> ea99430f…81a2
grep -n sops-age-key-rotation corpus/stamps.tsv       -> 27: …\tea99430f…81a2\t99\t6796
```

Historic lineage (all observed by reading committed blobs):

| revision | file state | stamp row |
|---|---|---|
| `c41af82` (round 21 admission) | `9d73d218…1599`, 94 lines, 6257 bytes | `9d73d218…`, 94, 6257 — exact |
| `e1544c1` (post-landing correction, erratum appended) | `ea99430f…81a2`, 99, 6796 | re-pinned to `ea99430f…`, 99, 6796 — exact |
| `c2cab35` (base) / worktree | same `ea99430f…81a2` | same row, unchanged |

So the pin was moved with the bytes in the same commit (QM5 met for this path),
and nothing after `e1544c1` touched either side. The audited path is absent
from both the committed stale set and the in-flight worktree edits (see
§Adjacent ledger snapshot).

## 2. Substantive freshness — sources unchanged on 2026-10-20

Recorded fetch digests (SOURCES rows, captured with the method logged at
`LOG.md:1004`: `curl -sL --max-time 30 <url> | sha256sum`) reproduce exactly
today with `curl -sL --max-time 20`:

| row | URL | recorded | live 2026-10-20 | match |
|---|---|---|---|---|
| S009 | https://getsops.io/docs/usage/identities/age/ | `a840727ea1a8…b50b76` | same | yes |
| S010 | https://getsops.io/docs/usage/identities/key-groups/ | `fed6b2e14524…21192e` | same | yes |
| S011 | https://getsops.io/docs/usage/key-management/ | `d0ab8b201f1a…2e180c` | same | yes |

All three pages carry the same footer, read live:

> "Last modified May 15, 2026: Add page descriptions. (9b7b84e)" — footer,
> https://getsops.io/docs/usage/key-management/ (and the other two URLs), 2026-10-20.

That is the committed docs hash the entry names, unchanged. Release check:
GitHub's `releases.atom` (the REST API returned HTTP 403, rate-limited) lists
**v3.13.3, 2026-07-23**, as the newest release — before the entry's 2026-10-19
verification, so the `on-release` trigger has not fired since the read.

The uncited S008 README check also still holds: `raw.githubusercontent.com/
getsops/sops/main/README.rst` is `63cb0a46…e3440` (S008's recorded digest) and
has 0 matches for `updatekeys|key group|rotate` — the "pointer only, no usage
text" note in the entry's `verified-at` line remains accurate.

Spot-check of the entry's load-bearing wording against the live pages (each is
present verbatim):

- S009 §Encrypting using age: "Each identity will be tried in sequence until one is able to decrypt the data." (https://getsops.io/docs/usage/identities/age/, 2026-10-20)
- S010 §Key groups: "By default, the threshold is set to the number of key groups." (https://getsops.io/docs/usage/identities/key-groups/, 2026-10-20)
- S011 §rotate command: "Use updatekeys if you want to add a key without rotating the data key." (https://getsops.io/docs/usage/key-management/, 2026-10-20)
- S011 §rotate command: "generates a new data encryption key and reencrypt all values with the new key" (same page, 2026-10-20)
- S011 §Direct Editing: "When removing keys, it is recommended to rotate the data key using -r" (same page, 2026-10-20)
- S011 §Rotating secrets…: "Only after this is done, should you start rotating the actual passwords" (same page, 2026-10-20)
- S011 footnote (compromise section): "only a problem in two specific situations: the secret.sops.yaml file is checked in between the two calls"; second case: "the compromised key is with a cloud provider ... which is compromised itself" (same page, 2026-10-20)

Limits of that check are stated in §4; it did not execute SOPS.

## 3. Calibration adjudication

**No E1/E3-class overclaim exists here.** The entry is a documentation
comparison, not a deployment or eligibility claim: it explicitly says nothing
was executed, names the comparison-not-adoption status, separates recipient
access / per-file data key / secret values (QA8), and closes with
`## Does not establish` plus a falsifier. It asserts no SOPS version, plan,
preview status or host measurement (QA2/QA9/QA10 are not engaged).

**Known errata are already present and are append-only.** The round-21
post-landing erratum covers exactly the two soft spots: "independent
custodians" is superseded by "independent key groups" (S010 describes groups,
not people), and the absence sweep is narrowed to *corpus entries*, not host
runtime use. Text above the erratum is unchanged. Both corrections still match
the live sources; no third erratum is warranted.

**Examined and rejected as a defect: section enumeration asymmetry.**
The entry's `source:` header lists S011 §updatekeys, §rotate, §Direct Editing
and §Rotating secrets…; its body also cites §Adding and removing keys. The S011
registry row's `anchor` cell lists §Adding and removing keys, §updatekeys,
§rotate and §Rotating secrets… but omits §Direct Editing. Live S011 contains
all five cited sections. Decision:

- `SOURCES-CONTRACT-v1.md` (copy read at
  `/home/vgpnk/Projects/shokunin/.ufo/waves/kaika/SOURCES-CONTRACT-v1.md`,
  outside the repo) requires `anchor` to be an "exact section / heading /
  page / line plus revision" that grounds the row's `scope`; it does not
  require the cell to mirror every section an entry cites. The row's scope
  ("Recipient synchronization versus data-key rotation and compromise response
  order") covers the §Direct Editing claim, and the row carries commit
  `9b7b84e` + date.
- Rule 2 of that contract makes `anchor`/`scope` immutable in place; the only
  correction path is a new row whose `teaches` opens `supersedes S011 —`.
  Promoting a purely enumerative gap to a superseding row would also force
  `used-by` and the entry's `source:` line to change, for no change in
  substance.
- `corpus/sources-census.sh` checks header presence and the citation chain
  (read from its header; it was **not executed**), not section tokens, so this
  asymmetry is invisible to the gate by design.

Verdict: no action. If the parent later adopts an "anchor must enumerate all
cited sections" rule, the legal migration is a superseding row, logged old→new;
an in-place `anchor` edit is not allowed.

## 4. Absent-source limits

- **No archived source bytes in-repo.** The stamp pins the entry, not the
  vendor pages. The fetch sha256 cells are the only byte-level record of the
  sources; today's match depends on live network and on the recorded method.
  A future offline audit can only re-verify the entry's bytes, not its claims.
- **Method caveat.** The recorded method is logged, and I reproduced it with
  the same `curl -sL` shape (20s vs 30s timeout), but no server-side capture
  proves the page bytes are independent of CDN/UA variation; the match is
  strong, not a formal provenance proof.
- **Release evidence is coarse.** GitHub REST was rate-limited (HTTP 403);
  the atom feed gives tag and date, not release-note content. I did not read
  v3.13.3's notes, so I cannot claim a release-note check of rotate/updatekeys
  behavior — only that no release postdates the verification.
- **Contract file location.** The path named in `sources-census.sh`'s header
  (`.tower/worktrees/kaika/fleet-ledger/.../SOURCES-CONTRACT-v1.md`) does not
  exist on this host; the read copy lives under `.ufo/waves/kaika/` and is not
  in the frozen tree, so the anchor-semantics adjudication above is not
  reproducible from a bare clone.
- **No execution.** Nothing about SOPS runtime behavior, on this host or any
  other, was measured. The entry's "documented, not measured" scope remains the
  correct reading.
- **No re-dating.** `verified-at: 2026-10-19` was not rewritten; today's check
  is a reproduction of that read, not a new verification date.

## 5. Exact proposed recheck scope (next trigger only)

Trigger (unchanged): a SOPS release after **v3.13.3 (2026-07-23)**, or a change
to any of the three pages' footer from **May 15, 2026 / `9b7b84e`**.

1. Re-run, for the three URLs:
   `curl -sL --max-time 30 <url> | sha256sum`, compare against S009
   `a840727e…`, S010 `fed6b2e1…`, S011 `d0ab8b20…`.
2. If all three match: no edit, no re-stamp, no erratum. Record the check only
   if the wave asks for a re-verification event.
3. If any differ: re-read that page in full and re-check, per section:
   - S009 §Encrypting using age — identity lookup order; SSH recipient key
     types limited to ssh-ed25519/ssh-rsa.
   - S010 §Key groups — Shamir fragments; default threshold equals the number
     of key groups; override behavior.
   - S011 §Adding and removing keys — access set stored in the file's `sops`
     section; §updatekeys — access-set sync without a new data key;
     §rotate — new data key + re-encryption of values; §Direct Editing —
     rotate-on-removal recommendation; §Rotating secrets after a key in a key
     group has been compromised — the three-step order and the footnote's two
     exceptions.
4. If mechanics changed, the falsifier fires: append a dated erratum (text
   above unchanged), correct the affected claim, and move `verified-at` /
   `recheck` only as needed.
5. Registry handling on any factual divergence: §status/`recheck`/`used-by`
   may change in place and must be logged old→new in the round lesson; a
   factual `anchor`/`scope`/`teaches` correction is a new `supersedes S011 —`
   row. Never edit those fields in place.
6. Re-stamp `corpus/knowledge/sops-age-key-rotation.md` in the same commit as
   any byte change (QM5). No host gate, no SOPS run, no vault/op operation is
   part of this recheck.

No wider scope is proposed: this entry does not cover age cryptography, KMS/
PGP backends, the SOPS Vault/OpenBao backend, or any measured version.

## 6. Append-only preservation requirement

- Any future substantive correction is a **new dated erratum section appended
  below the existing text**; the text above stays byte-identical (the
  round-21 erratum is the template).
- The stamp row is a mutable pin, not a log: it must be regenerated for this
  exact path in the same commit and must never be refreshed to a value the
  worktree does not carry.
- The source registry is append-only for `teaches`/`anchor`/`scope`; only
  `status`, `recheck`, `used-by` move in place, each logged old→new in the
  round lesson. Rejected readings are preserved, not deleted.
- Ledger expectation changes are explicit migrations: state old regex/old
  count, new measured count and the command; do not silently re-bless an
  obsolete expectation (C2 requirement).

## Adjacent ledger snapshot (outside this entry's remit; exact evidence only)

Recorded at the snapshot time above, for the parent's freshness reconciliation.

1. **Committed stale stamps at HEAD: 6, not 5.** Comparing every stamp row to
   its HEAD blob: `config-layering.md` (pin 109/6621 vs HEAD 136/8088),
   `handler-on-disk-state.md` (247/17609 vs 277/19329),
   `handler-trust-boundary.md` (285/17669 vs 316/19410),
   `janitor-env-contract.md` (90/5111 vs 113/6372), `round-18.md` (73/4216 vs
   80/4557), `LOG.md` (1043/74864 vs 1050/75404). The first four pins match
   revision `2486643`; `round-18.md` matches `fecee87` — inherited pins that
   `e1544c1`'s refresh did not touch. `LOG.md` was made stale by the base
   commit itself: `c2cab35` added 7 lines/540 bytes to `LOG.md` without
   changing `stamps.tsv` (QM5 violation at the frozen base). The audited entry
   is in neither group. This exact six-path list matches
   `.ufo/waves/round-22/before.json` `stale_stamps` at the same revision.
2. **"Nine dropped stamps" is not supported by committed history.** Across
   all nine revisions of `stamps.tsv` the row set is monotonic
   (28→33→44→48→52→54→56→63→63); zero paths were ever dropped. The exact
   round-21 span `aea7a43` (pre-admission) → `e1544c1` (post-correction) shows
   **9 deleted lines / 16 added lines / 0 removed members**; the nine deleted
   lines are nine paths whose pins changed — the same nine the outside
   verifier counted. Broken down: `c41af82` is 9 re-pins + 7 new rows;
   `e1544c1` is 13/13 replacements with the set constant. So the only "nine"
   is a count of deleted diff lines, not deleted rows; if a review saw nine
   rows disappear, that state was uncommitted/private and is not recoverable
   from the frozen base. This independently matches the untracked round-22
   lesson's §"Nine deleted diff lines" at audit time. Do not restore rows that
   were never removed, and do not record a drop count of 9.
3. **Worktree was in flux** (other seats, not me): four tracked files were
   modified but not committed — `QUALITY.md`, `SOURCES.md`,
   `onepassword-machine-credentials.md`,
   `vault-openbao-token-lease-lifecycle.md` — plus untracked
   `corpus/lessons/round-22.md` (mtime 2026-10-20T18:37:51−03:00),
   `corpus/knowledge/feature-bound-credential-review.md`, and
   `plans/round-22.md`. `SOURCES.md` moved during the audit: 16 rows at HEAD,
   20 observed at 18:35 (S017–S020), 21 in the 18:38:24 snapshot
   (`sha256 ebf88646…`; S021 added); S017–S021 each list both
   `corpus/lessons/round-22.md` and the new entry in `used-by`. Stamps were
   not refreshed: in-flight work, not committed staleness. Do not score the
   worktree-only state as debt.
4. **Forward expectation migration.** When those files land, ledger row
   `R21-02`'s expected verdict (`SOURCES_CENSUS: CLEAN (rows=16 A=14 …
   mined=14 … entries_sourced=3 legacy=21)`) can no longer match; it must be
   re-measured on the integration tree and migrated with old→new evidence in
   the same commit. [INFERENCE] shape if all five added rows are tier-A mined
   and the new entry is counted: rows=21, A/mined=19, entries_sourced=4,
   legacy=21 — but whether the lesson counts as an entry, and the exact
   replacement line, must be measured, not blessed.

No depth move and no legacy-header/count claim is made here.

## Reproduction (read-only)

```
cd /home/vgpnk/Projects/shokunin/kagi-shokunin
sha256sum corpus/knowledge/sops-age-key-rotation.md corpus/stamps.tsv
git show HEAD:corpus/knowledge/sops-age-key-rotation.md | sha256sum
grep -n sops-age-key-rotation corpus/stamps.tsv
for u in https://getsops.io/docs/usage/identities/age/ \
         https://getsops.io/docs/usage/identities/key-groups/ \
         https://getsops.io/docs/usage/key-management/; do
  curl -sL --max-time 30 "$u" | sha256sum
done
git log --reverse --format=%h -- corpus/stamps.tsv
```

## Installs

None. No package transaction, tool install or service change was performed.
