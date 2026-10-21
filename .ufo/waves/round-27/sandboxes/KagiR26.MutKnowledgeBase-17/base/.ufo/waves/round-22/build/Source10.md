# Source10 — S010 re-open and calibration/freshness reconciliation

Seat: `KagiR22.Source10` (leaf, read-only; no delegation). Source in scope: **S010 only**.
Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD`), working tree
dirty only from sibling round-22 writes (modified registry/entries; untracked `.ufo/`,
`plans/round-22.md`, round-22 lesson/review files that appeared during the seat). None of those
writes touches S010 or its entry.
Access date: **2026-10-20**. No production file, registry row, stamp, or gate was written; this
report is the only write. Installs: none.

Axes: **calibration** (source/status/eligibility/product/path adjudication, decisions not rows)
and **freshness** (pin/expectation reconciliation, historic evidence preserved).

## 1. Evidence measured

Page, fetched twice (second with cache-buster), byte-identical both times:

```
GET https://getsops.io/docs/usage/identities/key-groups/
HTTP/2 200 · server: Netlify · date: Tue, 20 Oct 2026 21:33:36 GMT · content-length: 36366
sha256 = fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e
```

Registered S010 pin: `fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e`
(`corpus/SOURCES.md:16`). **Exact match; no byte drift.**

Page footer (located, 2026-10-20): “Last modified May 15, 2026: Add page descriptions. (9b7b84e)”
— footer, URL above. The full committed hash in the row,
`9b7b84e297bdabc9c78e571c1e6db43dcd69454a`, resolves in **getsops/docs** with title
“Add page descriptions. · getsops/docs@9b7b84e” (opened 2026-10-20); metadata shows
`authoredDate 2026-05-15T19:05:01+02:00`, `committedDate 2026-06-23T22:04:48+02:00`.
So “last modified” is the docs page's authorship date, and the hash is a **docs-site commit,
not a SOPS release**.

## 2. Source facts for S010 (located quotes, ≤25 words each)

URL for all: `https://getsops.io/docs/usage/identities/key-groups/`; accessed 2026-10-20.

| # | location | quote |
|---|---|---|
| 1 | page introduction (also meta description) | “Key groups allow to require multiple identities together to edit or decrypt a file.” |
| 2 | §Key groups | “each of the master keys, such that if any of the master keys is available, the file can be decrypted” |
| 3 | §Key groups | “SOPS uses Shamir's Secret Sharing to split the data key” |
| 4 | §Key groups | “each key group has a fragment, each key in the key group can decrypt that fragment” |
| 5 | §Key groups | “keys from multiple groups are required to decrypt a file” |
| 6 | §Key groups | “By default, the threshold is set to the number of key groups.” |
| 7 | §Key groups | “one master key from each of the three groups will be required to decrypt the file” |
| 8 | §Key groups | “optionally provide the --shamir-secret-sharing-threshold command line flag if we want to override the default threshold” |
| 9 | §Key groups | “Alternatively, you can configure the Shamir threshold for each creation rule in the .sops.yaml config” (key name `shamir_threshold`) |
| 10 | §Key groups | “Management of key groups is done with the sops groups command.” |
| 11 | §Key groups | “you can add a new key group with 3 PGP keys and 3 KMS keys to the file” |

Qualifier scan (word-boundary grep over rendered text): **no `age` mention in page body**; the
only “Age” is the docs navigation entry. Examples are PGP and KMS. No SOPS version, release,
preview, beta, plan, or account text appears.

## 3. Qualifiers carried (status / eligibility / product / path)

- **Status:** live unversioned docs page; tier A, status `mined` (source registry). Not a release
  note, not a release-status claim. Revision evidence is a docs commit; the row's
  `recheck: on-release` remains a release trigger, not a version pin.
- **Eligibility:** none stated on this page (no plan, account, or deployment prerequisite).
- **Product:** SOPS / `getsops.io` docs; backend-generic wording, PGP and KMS demonstrated.
- **Path:** `/docs/usage/identities/key-groups/` §Key groups (Hugo source
  `content/en/docs/usage/identities/key-groups/_index.md`, getsops/docs).

## 4. Calibration decisions against `corpus/knowledge/sops-age-key-rotation.md`

Entry re-read at the frozen base; it is unchanged from base (`git diff --name-only c2cab35…`
returns none) and its stamp matches (`ea99430f…`, 99 lines, 6796 bytes = `stamps.tsv:27`).

| # | entry claim (line) | decision | ground |
|---|---|---|---|
| C1 | lines 42–43: no key groups → data key encrypted to each master key; “if any of the master keys is available, the file can be decrypted” | **ADMIT** | quotes 2, 5 |
| C2 | lines 44–45: Shamir fragment per group; any key in a group opens that group's fragment | **ADMIT** at mechanism level | quotes 3, 4 |
| C3 | lines 46–47: “By default, the threshold is set to the number of key groups”; overridable per invocation or creation rule | **ADMIT** | quotes 6, 8, 9 |
| C4 | lines 48–50: “adding recipients *within* a group widens who can open that fragment” | **BOUND** — true only for a file (re)encrypted with that group; S010 does not state that adding a key to an existing group rewrites an existing file's fragment | quote 4; §Key groups documents `sops groups add|delete --file`, not key membership on existing ciphertext |
| C5 | lines 48–50: “adding a *group* raises the number of independent custodians needed only if the threshold rises with it” | **REJECT as written** | “independent custodians” is not in S010 (already errata'd round 21); and under the default the threshold *is* the group count, so adding a group under the default does raise the required count. S010 does not state threshold recomputation for an existing file |
| C6 | entry framing “SOPS **with age**” + S010 citation for key groups | **BOUND** — S010 has no age body text; it is admissible for backend-generic group/threshold mechanics only, never as age key-group eligibility | word-boundary scan; quotes 10–11 (PGP/KMS examples) |
| C7 | entry omits the edit-side gate | **ADMIT the bounded control** — S010's first sentence makes key groups gate *editing* as well as decryption; the entry's §Key groups covers decryption only | quote 1 |

Decision counts (QM13: decisions, not authored rows): **4 admits, 2 bounds, 1 reject**; no
registry row was added to alter any count.

S010 row itself (`SOURCES.md:16`): scope “Shamir key-group fragments and configurable decryption
threshold” and teaching are **true but narrower** than the page (editing gate omitted; no age
example). This is under-description, not an overclaim; the anchored quote (quote 5) is verbatim
and correctly located at §Key groups.

## 5. Freshness and pin reconciliation (C2)

- **S010 pin:** measured digest equals `fed6b2e1…`; two fetches identical; footer date/commit
  unchanged. **No restamp and no superseding row are warranted on freshness grounds.**
- **Scope of the nine-member reconciliation:** the nine dropped historical stamp members are the
  C2 ledger seat's work, not re-derived here. Seat-scoped result: S010's registry pin and its
  entry's stamp membership are both intact; the only adjacent drift observed is the later
  round-22 append to `corpus/SOURCES.md`.
- **No dropped S010 membership:** row present in both base and working tree (base registry has
  16 rows; working tree 20 after sibling S017–S020 appends); entry stamp row present;
  `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=20 A=18 B=0 C=2
  queued=1 mined=18 rejected=1 entries_sourced=3 legacy=21)`, exit 0. The one `queued` row is
  S005 (pre-existing), not S010.
- **Historic evidence preserved:** S010's `opened 2026-10-19`, `recheck: on-release`, and the
  entry's `verified-at: 2026-10-19` are left as historic statements. This 2026-10-20 re-open
  confirms the same bytes; it does not rewrite the earlier read date (QM14: a fresh hash does
  not make historical source facts current — here the facts did not move).
- **S010 row history (exact):** introduced at `c41af82` and byte-identical at `c2cab35…`
  (`diff` of the `| S010 |` line is empty); the working-tree diff does not touch it
  (`git diff -U0 -- corpus/SOURCES.md | grep -c S010` = 0). No S010 expectation migration exists
  to document.
- **Prior stamp migration already committed (example the round can cite):** at `e1544c1`
  (round-21 post-landing erratum) `corpus/knowledge/sops-age-key-rotation.md` moved
  `9d73d218…` / 94 lines / 6257 bytes → `ea99430f…` / 99 / 6796, and `corpus/SOURCES.md` moved
  `1cd6d240…` / 41 / 13863 → `db134917…` / 43 / 14261. Both old and new values are recoverable
  from git, so the erratum is visible as an expectation change, not a silent re-pin.
- **Adjacent stale stamp, not S010's, observed for the integration owner:**
  `stamps.tsv` row `corpus/SOURCES.md` = `db134917…`, 43 lines, 14261 bytes, which **exactly
  matches the committed base**; the working tree is `a4edd52c…`, 53 lines, 16757 bytes because
  round-22 appended S017–S020 plus a six-line lead disposition (10 insertions). This is a later
  change by another lane, not inherited drift. Expectation migration (QM14): record
  old→new with the motivating append and the observed check; do not silently auto-repin.
- Docs-commit metadata nuance: footer "May 15, 2026" is the authored date; the commit was
  committed 2026-06-23. No content implication; keep documenting the footer value as the
  page states it.

## 6. Proposed correction (not applied; read-only seat)

**No superseding registry row.** Rationale: every immutable S010 field remains true; the gaps
are entry-level (edit gate, age-example absence, inference scoping) and would not be fixed by a
new row. Adding one now would also have no `used-by` consumer and would be a row-count move,
not a decision (QM13).

Append to `corpus/knowledge/sops-age-key-rotation.md` (erratum style, text above unchanged):

1. §Key groups bullet 4: replace the “custodians” reading with key groups/master keys (already
   round-21 erratum) and mark both clauses **[INFERENCE]** for existing files: default threshold
   equals group count; an explicit `shamir_threshold` decouples the two; S010 does not state that
   editing a file's groups recomputes its threshold.
2. Add the edit-side bound: S010 states key groups require “multiple identities together to edit
   or decrypt a file”; the entry's §Key groups describes decryption only.
3. Add the product-path bound: S010 demonstrates PGP and KMS and contains no age key-group
   example; cite it for generic group mechanics, not age recipient eligibility.
4. Add the status bound: the revision stamp is a **getsops/docs** commit (“Add page
   descriptions.”), not a SOPS release, and the page displays no SOPS version.

## 7. Falsifier for this report

The served S010 page stops matching `fed6b2e1…`, or its footer commit/date changes; or the page
states a default threshold other than the number of key groups, allows a key outside a group to
open that group's fragment, drops the edit-side gate, or gains age-specific key-group semantics.
Any of these re-opens C1–C7.

## 8. Limits / remaining unknowns

- S010 does not say whether key groups work with **age** recipients; that requires S009/S011
  (other seats' sources) or a SOPS execution, which this seat did not perform.
- S010 does not state existing-file behaviour when a group's keys or a file's threshold change;
  C4/C5 remain bounded inferences until S011 or a measured SOPS run settles them.
- Whether `updatekeys` must satisfy the group threshold is S011 territory; not read here.
- GitHub API was rate-limited; commit metadata came from the public commit page HTML, which
  supplied dates and title (no code execution).
- Verification not run by this seat: builds/tests/formatters were out of scope; parent should
  run `bash corpus/sources-census.sh` and the claim-ledger checks after integration.
