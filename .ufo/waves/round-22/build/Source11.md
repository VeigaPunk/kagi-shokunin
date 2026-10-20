# Source11 — S011 (SOPS key management) versus `sops-age-key-rotation.md`

Axes: **calibration (C1)** and **freshness (C2)**.
Seat: read-only. No source-registry edits, no entry edits, no installs, no host gates run.

Read revision: repo HEAD `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Source fetch: `https://getsops.io/docs/usage/key-management/` at **2026-10-20T21:33:27Z**
(HTTP 200, 33,153 bytes), sha256 `d0ab8b201f1a6d5f5751e1f261f904822492c530bdcdc5a4db9a8e178c2e180c`
— byte-identical to the fetch sha recorded in the S011 row.
Registry: at HEAD `corpus/SOURCES.md` is `db134917…` (43 lines / 14,261 bytes), matching
`corpus/stamps.tsv`. The working tree is dirty (`a4edd52c…`, 53 / 16,757) from uncommitted
S017–S020 additions; the **S011 row is byte-identical at both** (`565fcf51…`, one line).
Used-by entry: `corpus/knowledge/sops-age-key-rotation.md` at HEAD `ea99430f…` (99 / 6,796),
matching `stamps.tsv` row 27.

---

## 1. Registered row (immutable, read verbatim)

| field | value (HEAD) |
|---|---|
| id / source | S011 — *Key management on SOPS* — <https://getsops.io/docs/usage/key-management/> |
| kind / tier | `docs` / `A` |
| scope | Recipient synchronization versus data-key rotation and compromise response order |
| anchor | §Adding and removing keys, §`updatekeys` command, §`rotate` command, §Rotating secrets after a key in a key group has been compromised; last modified 2026-05-15, docs commit `9b7b84e297bdabc9c78e571c1e6db43dcd69454a` |
| teaches | SOPS distinguishes recipient changes from creating a new data key and documents compromise sequencing. Quote: “Use `updatekeys` if you want to add a key without rotating the data key.” (§`rotate` command) |
| status / opened / recheck | `mined` / 2026-10-19 / `on-release` |
| used-by | `corpus/knowledge/sops-age-key-rotation.md` |

All four anchor sections exist on the page, in the registered order, under those headings
(docs source headings at lines 7, 25, 48, 114); §Direct Editing is at line 68. Confidence: high (direct read).

## 2. Located evidence, 2026-10-20 (every quote ≤25 words)

Page is built from `getsops/docs@9b7b84e…`, file
`content/en/docs/usage/key-management/_index.md` (sha256 `214d6685…`, 131 lines); the same
file at `main` is byte-identical. Rendered-HTML body lines refer to the text extraction.

| id | heading | quote | words | location |
|---|---|---|---|---|
| q1 | §`rotate` command | “Use `updatekeys` if you want to add a key without rotating the data key.” | 14 | source l.58 |
| q2 | §`rotate` command | “The `rotate` command generates a new data encryption key and reencrypt all values with the new key.” | 17 | source ll.50–51 |
| q3 | §`rotate` command | “can be used to add and remove keys from a file” | 11 | source ll.53–54 |
| q4 | §Direct Editing | “When removing keys, it is recommended to rotate the data key using `-r`” | 13 | source l.95 |
| q5 | §Direct Editing (sic) | “owners of the removed key may have add access to the data key in the past” | 16 | source ll.96–97 |
| q6 | §Rotating secrets after a key in a key group has been compromised | “first the compromised key is removed from the list of keys that has access to the per-file data key” | 19 | source l.125 |
| q7 | same, footnote 1 | “doing it the other way is only a problem in two specific situations” | 13 | source l.127 footnote |
| q8 | same | “Only after this is done, should you start rotating the actual passwords, API keys and other secrets” | 17 | source l.131 |
| q9 | §Adding and removing keys | “That information is stored in the file under the `sops` section” | 11 | source ll.12–13 |
| q10 | page footer | “Last modified May 15, 2026: Add page descriptions. (9b7b84e)” | 9 | rendered footer |

The two footnote cases are: “the secret.sops.yaml file is checked in between the two sops
calls above” (12 words), or “the compromised key is with a cloud provider (AWS, Azure, GCP, HWC, Vault) which is
compromised itself” (17 words, docs source footnote). Quotes reproduced with the page's `add` typo
preserved (q5).

## 3. Status / eligibility / product / path qualifiers

- **Status:** stable documentation page, not preview/beta, no feature flag, no licence or
  plan gate. Tier `A` is justified: primary vendor documentation. The page is **unversioned**
  (no per-release selector); its revision clock is the docs footer commit, not a SOPS version.
- **Product:** SOPS (`getsops/sops`); docs are built from the separate `getsops/docs`
  repository. The body of the cited sections names PGP, KMS, GCP KMS, HuaweiCloud KMS and
  Azure Key Vault flags only. A word-boundary search finds **zero** occurrences of the age
  tool in the body; the only rendered “Age” is the sidebar link to a sibling page.
  The age `updatekeys` path is S009's authority, not S011's. Key groups are S010's.
- **Path qualifiers:** `updatekeys` runs against `.sops.yaml` creation rules; `rotate`
  add/remove is the CLI-flag path and simultaneously rotates the data key; direct editing
  is `sops edit -s` with manual metadata edits. The compromise order is scoped to “a key in
  a key group” configured in `.sops.yaml` and is backend-agnostic within the page.
- **Version clock:** latest SOPS release at read time is **v3.13.3 (2026-07-23)**. The docs
  moved from README to getsops.io in **v3.13.1 (2026-05-16)**; `CHANGELOG.md` 3.13.1–3.13.3
  has no `rotate`/`updatekeys`/key-group semantic change. The `on-release` recheck was
  therefore satisfied when the row was opened (2026-10-19 > 2026-07-23).

## 4. C1 adjudications (decisions, not row counts)

| claim under review | verdict | source basis | bounded control / correction |
|---|---|---|---|
| `updatekeys` changes the access set without creating a new data key | **admit** | q1, q9 | Applies to `updatekeys` and direct editing only. |
| `rotate` creates a new data key and re-encrypts all values | **admit** | q2 | Same invocation can also add/remove master keys (q3). |
| compromise order is recipients → data key → upstream credential values | **admit** | q6, q8 | Page says “Commit and push” between data-key rotation and value rotation. |
| reversing steps 1–2 is always a live exposure | **admit with qualifier** | q7 | Only two cases: file checked in between the two calls; compromised key held by an already-compromised cloud provider. Not a universal MUST. |
| “removing a recipient alone completes rotation” (round-21 E2 rejection) | **reject — correctly rejected** | q1 vs q4/q6 | Removal is access-set change; the page separately recommends rotating the data key, and the compromised-values step is separate again. |
| “`updatekeys` regenerates the data key” | **reject** | q1 | Contradicted by “without rotating the data key”. |
| “SOPS rotates the upstream passwords/API keys” | **reject** | q8 | Value rotation is the operator's manual step after the file operations. |
| “changing a recipient never changes the data key or encrypted values” | **reject** | q2 + q3 | False for `rotate --add-*`/`--rm-*`, which rotate the data key in the same invocation. This is the entry defect in §5. |
| apply the guide's mechanism to age recipients from S011 alone | **reject** | §3 product qualifier | Age binding must cite S009 §Encrypting using age. |

No count of authored rows is offered as calibration; the table records decisions against
source statements.

## 5. Entry findings (exact lines; proposed append-only corrections)

### D1 — medium: recipient row conflates `updatekeys` with `rotate` add/remove
`corpus/knowledge/sops-age-key-rotation.md:16` (table header line 14):

> `| recipient (who can unwrap the data key) | `updatekeys` against the creation rules, `rotate` add/remove flags, or direct editing | the data key, the encrypted values | S011 §updatekeys, §rotate |`

The “does not change” cell is contradicted by q2 + q3: `rotate --add-pgp` /
`--rm-pgp` (and the KMS equivalents) generate a new data key and re-encrypt all values in
the same command. Only `updatekeys` and direct editing leave the data key and values
untouched. The entry's prose at lines 20–22 is correct; the table is the defect.
Confidence: high.

Proposed append-only erratum (do not rewrite the pinned body):

> - §Three different objects, recipient row (round 22): the “does not change” cell holds
>   only for `updatekeys` and direct editing. `rotate --add-*`/`--rm-*` generates a new data
>   key and re-encrypts all values in the same invocation (S011 §`rotate` command). Read the
>   row as two paths, not one. Under key groups a key opens its group's fragment; the data
>   key is reconstructed from fragments (S010).

### D2 — low: age applicability is attributed to S011, which never names age
Line 16's source cell cites `S011 §updatekeys, §rotate` for a recipient mechanism in an
entry titled “SOPS with age”. S011's body enumerates PGP/KMS/Azure/Huawei flags and contains
no age reference; the age-specific `updatekeys` sentence is S009 §Encrypting using age
(row S009). This is a source-binding gap, not a mechanism overclaim. Confidence: high on the
text, medium on severity (the row may be intended as backend-agnostic).

Proposed erratum line: cite S009 for the age path; keep S011 for the backend-agnostic
sops-metadata mechanism.

### D3 — low: S011 row anchor omits §Direct Editing
The entry cites §Direct Editing twice (`source:` line 3 and the compromise paragraph at
lines 60–64), and the “may have add access” recommendation that bounds removal lives only
there. The row's anchor lists four sections and omits it. No factual field is wrong; a
verifier following only the row anchor will miss the support for “removal alone does not
excuse rotation.” Confidence: high.

## 6. C2 freshness ledger

| object | pinned / prior | observed 2026-10-20 | verdict |
|---|---|---|---|
| S011 rendered page | `d0ab8b…` (33,153 B) | `d0ab8b…` | **current; no re-stamp needed** |
| docs source at `9b7b84e` | `214d6685…` (131 lines) | same as `main` | current |
| page footer | May 15, 2026 / `9b7b84e` | identical | current |
| used-by entry | `ea99430f…` (99 / 6,796) | `ea99430f…` | current |
| `SOURCES.md` at HEAD | `db134917…` (43 / 14,261) | matches pin | current at base |
| `SOURCES.md` working tree | — | `a4edd52c…` (53 / 16,757) | **integration pin debt** |
| `stamps.tsv` membership | 63 rows | 63 rows | no membership loss |

**F1 — no stale source stamp.** The recorded fetch sha is reproducible byte-for-byte. The
Netlify edge served a cached copy (`age: 84372`, `cache-status: hit`); this is not masking a
change because the raw docs source at `main` is byte-identical to the pinned commit and the
docs file has no commit after `9b7b84e`. A cache-buster was not used; the raw-source
cross-check is the stronger evidence.

**F2 — commit provenance, not drift.** `9b7b84e297bd…` is a **`getsops/docs`** commit (the
row says “docs commit” without naming the repo; `getsops/sops` returns “No commit found”).
Author date **2026-05-15T17:05:01Z**; committer date **2026-06-23T20:04:48Z**. The commit
adds `description:` front matter to 26 `_index.md` files (one change for key-management); the
mechanism text comes from the earlier same-day commit `7fffe3e1…` (2026-05-15T16:55:37Z).
So “last modified 2026-05-15” is the footer/author date; a verifier looking at the GitHub
commit page sees June 23. Record both, do not re-date the row.

**F3 — the “nine deleted stamp lines” are nine in-place re-pins, not lost members.**
Commit `e1544c1` (2026-10-19 19:45:42 -0300) changes **13** stamp rows: 13 `-` lines and 13
`+` lines (9 under `corpus/`, 4 root: `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SKILL.md`).
Every removed line has a same-path replacement; **0 removals** across
`c41af82→e1544c1` and `e1544c1→HEAD`; 63 rows at `c41af82`, `e1544c1`, and HEAD (56 at
`aea7a43`; the 7 new rows are the round-21 additions). The outside reviewer's “nine
deleted lines” matches the nine `corpus/...` delete/add pairs in that diff; the other four
pairs are root-level files.

The S011 dependency's exact pair:

- path `corpus/knowledge/sops-age-key-rotation.md`
- old (at `c41af82`): `9d73d218aabcfc708fca03bb09221ba6f57f9963b6e6de0df3a975bbf3241599`, 94 lines, 6,257 bytes
- new (at `e1544c1`): `ea99430f0417f67a644f50309f08f0f4ce42bec526b1d909a6f932b5c7ff81a2`, 99 lines, 6,796 bytes
- delta: +5 lines / +539 bytes, motivated by the appended round-21 erratum.
- at `e1544c1→HEAD`: 0 changes (current).

This pair is **not** in `.ufo/waves/round-22/round21-migrations.json`
`changed_stamp_records`: that array is the `aea7a43→e1544c1` net set (9 changed paths +
7 added; the three round-21 entries appear only as “added” because they did not exist at
`aea7a43`). `historical-migrations.json` (`c41af82→e1544c1`) records
`deleted_stamps: []` — consistent with the count above — but carries no per-path old→new.
Both records are individually accurate for their declared ranges; neither captures this
transition. Add the triple above to the migration record (QM14: previous state, motivating
correction, observed check), and do **not** restore the old pin — the erratum is the
motivation.

Also note the two nine-path sets differ: `round21-migrations.json` lists
`LOG.md, PROVINCE.md, SCORECARD.md, SHONEN.md, SKILL.md, corpus/README.md,
corpus/claim-ledger.tsv, corpus/knowledge/op-ref-consumption.md, corpus/op-ref-probe.sh`;
the `e1544c1` commit's nine `corpus/` rows are `claim-ledger.tsv,
onepassword-machine-credentials.md, sops-age-key-rotation.md,
vault-openbao-token-lease-lifecycle.md, round-21.md, QUALITY.md, README.md,
sources-census.sh, SOURCES.md`. A reconciliation keyed only to the JSON would miss the S011
dependency.

**F4 — registry pin debt from uncommitted integration work.** Working-tree `SOURCES.md`
(53 / 16,757, `a4edd52c…`) versus the committed pin (43 / 14,261, `db134917…`) = S017–S020
rows plus a six-line lead-disposition note. `claim-ledger.sh verify` calls `verify_stamps`,
which compares **every** row, so it will print
`STALE corpus/SOURCES.md sha=db134917dab9->a4edd52c4fb6 lines=43->53 bytes=14261->16757`
until re-pinned. `stamp` replaces the whole row set and aborts if any pinned path is
dropped: re-pin by naming all 63 paths (e.g. the current `cut -f1 corpus/stamps.tsv` set),
never `stamp corpus/SOURCES.md` alone, never `--prune`; journal old→new. The S011 row itself
is byte-identical in both states, so this debt must not be used to re-date or re-hash S011.

**F5 — census expectation migration.** `R21-02` pins
`rows=16 A=14 B=0 C=2 queued=1 mined=14 rejected=1 entries_sourced=3 legacy=21`. The
integrated registry has 20 rows, so the census expectation must move by an **appended
successor row** with old/new values; leave `R21-02` as the historic expectation. Do not
loosen the pattern to “more rows” (QM13/QM14).

## 7. Superseding row: not needed (decision)

The S011 row's factual immutable fields — URL, scope, teaches, quote, fetch sha, status,
opened date, recheck, used-by — are all still correct at 2026-10-20. The only defects are
D3 (anchor enumeration) and the missing repo name in “docs commit”. Cutting a new registry
row for those props would:

- add no freshness information (same bytes, same dates);
- create the appearance of a re-stamp with a fresh access date (laundering risk);
- perturb the census row-count expectations for zero calibration gain.

Decision: **do not supersede now.** If a substantive re-source ever justifies a supersede,
fold in `getsops/docs@9b7b84e…` (author 2026-05-15 / committed 2026-06-23) and add
§Direct Editing to the anchor. The entry-side corrections belong in the append-only erratum,
not in a rewritten pinned body.

## 8. Falsifier

- A future fetch whose sha256 differs from `d0ab8b…` or whose footer commit changes, in
  which `updatekeys` regenerates the data key, `rotate` stops re-encrypting values, the
  compromise order is reordered or loses a step, or the footnote's two-case limitation is
  removed.
- A SOPS release whose changelog changes those semantics without a docs update (that would
  make the docs page insufficient authority).
- In the entry: any edit that reasserts “recipient change never touches the data key” as a
  blanket rule, or applies the compromise order to a backend the page does not cover.

## 9. Limits / remaining unknowns

- Documentation-level only: SOPS was not installed or executed; no runtime measurement of
  `updatekeys`/`rotate`, no host credential or vault operation.
- GitHub API rate limit was hit after the release list; per-tag release bodies were read
  from `CHANGELOG.md` at `main` instead.
- Netlify served a cached page (`age: 84372`); mitigated only by the raw-source comparison,
  not by a cache-busting fetch.
- The provenance commit is a docs-site commit, not the `sops` release commit; the site's
  build pin beyond the footer link and identical raw source was not inspected.
- Key-group mechanics were not re-opened here (S010 authority).
- The full nine-path stamp audit beyond the S011 dependency belongs to the stamp/ledger
  review seats; this report only resolves the S011-linked path and the base mismatch.
- The working-tree `SOURCES.md` additions are not mine; they were read as observed state.

## 10. Checks for the parent after integration (not run here)

1. `sha256sum` and `wc -lc` on the integrated `SOURCES.md`, entry, and stamps rows; confirm
   the S011 row still hashes to `565fcf51…` unless a substantive correction was applied.
2. `bash corpus/claim-ledger.sh verify` — will report `STALE corpus/SOURCES.md` until the
   full-set re-pin; confirm old→new values were journaled and no row was dropped.
3. `bash corpus/sources-census.sh` and `--selftest` with the appended `R21-02` successor
   expectation; `R21-02` itself unchanged.
4. Confirm the migration record now carries the
   `sops-age-key-rotation.md` `9d73d218…→ea99430f…` triple with the erratum motivation.

Tool installs/updates: none.
