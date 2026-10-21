# SourceS010 — row S010 provenance re-audit (round 23, C2)

Seat: `SourceS010` (leaf scout, read-only; no delegation, no subagents).
Scope: **S010 only** (`corpus/SOURCES.md:16`) plus its one `used-by` entry pointer and the
supersession question. Advisory only: nothing here admits, promotes, re-curates or re-stamps a row.

- Observed revision: `d218603b74099ddca0bd8f869516fc41db0979bf`
  (`git rev-parse HEAD`; commit date `2026-10-20T21:11:59-03:00`, "round-22 verifier spot-check").
- At audit start the working tree was identical to HEAD for every file touched here (verified by
  hashing the working file and `git show HEAD:<path>`): `corpus/SOURCES.md` `a5e1c13e…`,
  `sops-age-key-rotation.md` `a6b14ff7…`, `stamps.tsv` `febcdf46…`. **Mid-audit, sibling lanes
  appended S024–S026** to `corpus/SOURCES.md`; the file is now `06dde644…` / 121 lines / 24995
  bytes uncommitted. The `| S010 |` line was re-diffed against HEAD after that write:
  **byte-identical** (`diff` of the single row → empty). Nothing in S024–S026 supersedes S010;
  they add Vault KV v2 (S024) and supersede S014/S016 (S025/S026).
- Access date: **2026-10-21** (HTTP `date: Wed, 21 Oct 2026 03:43:07 GMT`). Writes: this report only.
  Installs: none. No gate, SOPS command, or repo script executed.

## 1. Live fetch of the canonical URL

```
GET https://getsops.io/docs/usage/identities/key-groups/
HTTP/2 200 · server: Netlify · content-type: text/html; charset=UTF-8
content-length: 36366 · etag: "7d057e9afbb0ada43c13fdd8ebb42071-ssl"
sha256(entity body, identity encoding, no decoding) = fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e
```

Registered pin at `corpus/SOURCES.md:16` is `fed6b2e145246ebcd2de4d8133945a8cb744331a20f5ef509980b77ef112192e`.
**Exact match, 36366 bytes.** This is an independent second reproduction, not a first: round-22's
`.ufo/waves/round-22/build/Source10.md` measured the same digest on 2026-10-20, though that round's
registry-wide capture-precision note lists only S017/S018/S019/S013/S021 as re-captured.

Stability measured this session: six identity-encoding GETs (no UA, `curl/8`, Googlebot UA, random
query cache-buster, explicit `Accept-Encoding: identity`, plus a repeat) → same digest and size
36366; one gzip response decoded client-side → same digest. Footer, `dateModified` meta and sitemap
lastmod all read 2026-05-15; no per-request nonce observed.

> Footer: “Last modified May 15, 2026: Add page descriptions. (9b7b84e)” — §footer, 2026-05-15,
> https://getsops.io/docs/usage/identities/key-groups/

The footer's link `href` carries the **full** commit id
`https://github.com/getsops/docs/commit/9b7b84e297bdabc9c78e571c1e6db43dcd69454a` — the row's
full hash is therefore machine-extractable from the served page, not inferred from the short label.

## 2. Row adjudication (`corpus/SOURCES.md:16`)

Every page quotation in this section (table rows and block quotes): URL
`https://getsops.io/docs/usage/identities/key-groups/`, §Key groups, page date 2026-05-15.

| field | observed | verdict | confidence |
|---|---|---|---|
| source/title | Title is "Key groups"; page H1 and H2 are both "Key groups" | supported | high |
| kind/tier `docs`/`A` | First-party upstream docs (`getsops.io`), not a repo README or third-party summary | supported | high |
| scope "Shamir key-group fragments and configurable decryption threshold" | Page: Shamir split, one fragment per group, configurable threshold | **supported but narrower than the page** — the page's intro sentence covers **editing** as well | high |
| anchor "§Key groups" | Resolves: `<h2 id=key-groups>` exists (unquoted attr); `…/key-groups/#key-groups` returns 200 | supported | high |
| anchor date "last modified 2026-05-15" | Footer text, `<meta … dateModified content="2026-05-15T19:05:01+02:00">`, sitemap `<lastmod>` all agree | supported **as an author date**, not a commit date (see §4) | high |
| anchor commit `9b7b84e297bd…` | Commit page HTTP 200; embedded `"oid"` = `9b7b84e297bdabc9c78e571c1e6db43dcd69454a` | supported | high |
| teaches "split a file's data key into fragments … configured threshold of groups" | “data keys are split into parts … each key group has a fragment” and “a configurable number of fragments (threshold)” | supported | high |
| quote “keys from multiple groups are required to decrypt a file.” | Verbatim in the `#key-groups` section; occurs exactly **once** in visible text | supported | high |
| status `mined` | No superseding row names S010; the path line (`corpus/SOURCES.md:37` after the concurrent append, `:34` at HEAD) still routes S009 → S010 → S011 | supported | high |
| recheck `on-release` | Latest SOPS release `v3.13.3`, published 2026-07-23 — **before** the 2026-10-19 open; trigger quiescent on 2026-10-21 | supported / untriggered | high |

> “data keys are split into parts such that keys from multiple groups are required to decrypt a
> file.” — §Key groups, 2026-05-15,
> https://getsops.io/docs/usage/identities/key-groups/

> “By default, the threshold is set to the number of key groups.” — §Key groups, 2026-05-15,
> https://getsops.io/docs/usage/identities/key-groups/

**One calibration gap, under-description not overclaim:** the scope field says "decryption
threshold" while the page states key groups “require multiple identities together to edit or
decrypt a file”. The row does not overstate anything; it omits the edit-side gate. The same gap was
already recorded against the entry in `.ufo/waves/round-22/build/Source10.md` C7; it is restated
here only as a row-scope observation, not re-litigated as an entry decision.

**No refutation found.** Every immutable field of the row is true of the served bytes.

## 3. Used-by pointer (`corpus/knowledge/sops-age-key-rotation.md`)

Pointer exists and is live: `source:` line 3 and §"Key groups and the threshold" lines 40–50.
Page quotations below: same URL as §2, §Key groups, 2026-05-15.

| entry claim (line) | page ground | verdict |
|---|---|---|
| 42–43: no key groups → data key to each master key; any one master key decrypts | “if any of the master keys is available, the file can be decrypted” | supported |
| 44–45: Shamir fragment per group; any key in the group opens that fragment | “each key group has a fragment, each key in the key group can decrypt that fragment” | supported |
| 46–47: default threshold = number of groups; overridable per invocation or creation rule | “By default, the threshold is set to the number of key groups.”; `--shamir-secret-sharing-threshold`; `shamir_threshold` | supported |
| 98 erratum: “independent custodians” → “independent key groups” | Page never speaks of people or custodians | supported |

No `used-by` pointer outside the knowledge entry: `corpus/lessons/round-21.md:64` and
`plans/round-21.md:33` mention S010 but are historical lesson/allocation records, not consumers.
The round-21 lesson's quote (“By default, the threshold is set to the number of key groups.”) is a
*different* sentence from the row's teaching quote and is still present verbatim — historical
assertion remains semantically supported, not superseded.

Consumer stamp is current: `corpus/stamps.tsv:30` `a6b14ff7… / 112 / 7591` equals the working
file (re-hashed after the sibling writes — unchanged). The stale round-22 `SOURCES.md` stamp was
already repaired: `stamps.tsv:61` recorded `a5e1c13e… / 118 / 22843`, which equalled `SOURCES.md`
at audit start. **It no longer does**: the concurrent S024–S026 append makes the working file
`06dde644… / 121 / 24995`. This is a fresh, uncommitted expectation gap created by sibling
round-23 rows, not by S010 and not by this seat; the integrator must record old→new with the
motivating append rather than silently re-pin.

## 4. C2 fetch+quote provenance — exact expectations for S010

Required record fields (all measured here, so each is checkable, not aspirational):

1. **Representation.** `GET`, exact URL `/docs/usage/identities/key-groups/`, `Accept-Encoding:
   identity` (or hash *after* decoding). Hash only the **decoded entity body**, never wire bytes;
   record byte length 36366. `Accept: text/markdown` is not an alternate: it returned the same
   `text/html` body, same `fed6b2e1…` digest, 36366 bytes.
2. **Digest.** SHA-256 `fed6b2e1…2192e` over decoded body. Store `Content-Encoding` and the
   `Vary: Accept-Encoding` fact alongside it.
3. **ETag.** Store verbatim *with its encoding*: identity `"7d057e9afbb0ada43c13fdd8ebb42071-ssl"`,
   gzip-requested `"7d057e9afbb0ada43c13fdd8ebb42071-ssl-df"`. ETags are not comparable across
   encodings; a conditional GET revalidation is a cheap drift probe (identity ETag → **304**).
4. **Anchor.** Section `h2#key-groups` body (rendered text, whitespace-collapsed, H1/nav excluded)
   must contain the exact quote, and the quote must occur once in visible text. Digest equality
   alone is not an anchor proof; anchor equality alone is not a content proof. Name that
   normalization explicitly — the round-23 rows S025/S026 already call it **rendered-text-v1**;
   S010's quote is stable under it (one occurrence, no inline markup inside the sentence).
5. **Dates, kept separate.** Anchor/author date `2026-05-15T19:05:01+02:00` (footer, meta,
   sitemap) ≠ docs **commit** date `2026-06-23T22:04:48+02:00` (commit page `committedDate`).
   Never assert "last modified = commit date", and never use the sitemap as an independent
   freshness signal — it mirrors the author date.
6. **Revision proof.** Footer href full oid `9b7b84e…`; commit page 200; source representation
   `content/en/docs/usage/identities/key-groups/_index.md` at that commit is 4206 bytes, sha256
   `57027c5f39ff059ae5b6d68e4115c795a58753a0d1da6e0d9b99ff7d7757eeb3`, and is byte-identical to
   `main` today. That source hash is a stronger, lower-churn pin than the 36 KB rendered page.
7. **Evidence class.** "docs-only, unversioned": the page displays no SOPS version or release
   status. Structural corroboration exists in the release tree (`cmd/sops/subcommand/groups`
   listed at `v3.13.3`; `config/config.go` declares `ShamirThreshold` and `key_groups` YAML tags),
   but that is **source-tree presence, not deployed-product proof** and not a runtime measurement.

### One real contradiction (measured)

The registered pin is reproducible only under an unstated representation. Sending
`Accept-Encoding: gzip` yields a body whose **wire bytes are not stable across fetches**:

| request | wire bytes | sha256 of wire bytes |
|---|---|---|
| identity ×3 | 36366, 36366, 36366 | `fed6b2e1…` (identity digest reproduced in 6 separate hashed fetches today) |
| gzip ×3 | 8978, 8978, **9034** | `4e815f51e30353f77e42c69ea0f6bcd69aac0066a74cfd02186ae6cddc398c3a` (8978-byte sample) |

`HEAD` with `Accept-Encoding: gzip` even advertised `content-length: 9050`. Same document, three
transport lengths. Therefore "Fetch sha256" as written is ambiguous: a checker that hashes wire
bytes produces false drift **and** is non-reproducible against itself, while a checker that hashes
the decoded body reproduces `fed6b2e1…` exactly. This does not refute the row — the row's digest is
correct for the decoded body — it refutes any provenance rule that omits the representation field.
`corpus/SOURCES.md`'s own round-22 note already says original hashes have "undocumented
representation"; S010's representation is now documented above.

### Minimal synthetic failing fixture (proposal for L1; not a result)

Three fixture entries under one manifest, checker fed the manifest, never the network:

- `c2/s010/identity.body` — recorded `content_encoding: identity`, 36366 bytes,
  `sha256: fed6b2e1…` → must PASS.
- `c2/s010/gzip.body` — gzip of the same bytes, recorded `content_encoding: gzip`,
  8978/9034-byte variant, expected digest still `fed6b2e1…` → a checker that hashes wire bytes
  must FAIL with `representation_mismatch`, not `content_drift`; a checker that decodes first must
  PASS.
- `c2/s010/moved-quote.body` — digest recomputed in the manifest so **the digest check passes**,
  but the sentence “keys from multiple groups are required to decrypt a file.” is moved into the
  page introduction, outside `h2#key-groups` → must FAIL `quote_outside_anchor`. This is the
  minimal case that proves digest equality cannot substitute for anchor+quote verification.

### Recommended for L1 (advisory; nothing applied here)

1. **Keep S010 `mined`/tier A** and add no superseding row — every immutable field is true and
   already re-measured; a new row would change counts without changing a decision.
2. **If the row is touched at all**, extend only the provenance fields: append
   `#key-groups` to the anchor URL, record `representation: decoded-body, identity` next to the
   digest, and add the docs **source** pin `57027c5f…` (4206 bytes at `9b7b84e`) as the low-churn
   companion to the 36 KB rendered hash. Do not restate the digest as a release or runtime pin.
3. **C2 implementation**: make `content_encoding` + normalization (`rendered-text-v1`) mandatory
   manifest fields before any digest comparison, and emit `representation_mismatch` separately from
   `content_drift`; otherwise the gzip case above will be misreported as source drift.

## 5. Supersession and status

- No row supersedes S010. Supersession markers in the registry are S019→S007 (`:25`),
  S020→S006 (`:26`), S022→S012 (`:28`), S023→S013 (`:29`), S025→S014 (`:31`), S026→S016 (`:32`);
  none concerns SOPS. S024 (`:30`) adds Vault KV v2 retention and does not touch this row.
- S008 (rejected) is a different URL (upstream README) and does not bear on S010.
- **S010 remains `mined`/tier A.** Nothing in this report changes a row, status, tier, recheck
  clock or stamp, and the report is not an admission artifact.
- `recheck: on-release` remains correct: no SOPS release has appeared since `v3.13.3` on
  2026-07-23, so the trigger has not fired since the row was opened.

## 6. Opens, failures, limits (honest record)

- `read` on the canonical URL did **not** open the page: it reported `Content-Type:
  application/feed`, method `alternate-feed`, and returned the `index.xml` alternate. All page text
  and byte measurements above come from `curl` + local HTML parsing, not from that read. This is a
  tooling limitation of the URL reader for this host, not a source failure.
- `https://raw.githubusercontent.com/getsops/sops/v3.13.3/cmd/sops/groups.go` → **404** (wrong
  guess). Corrected via `contents/cmd/sops` and `contents/cmd/sops/subcommand` listings:
  `groups` is a subcommand directory. I did not read that directory's source files, so the groups
  command's behavior remains unverified.
- GitHub commit page 200 (573 KB); dates extracted from embedded JSON. `api.github.com`
  `releases/latest` 200. Sitemap 200. No 429/rate-limit encountered this session.
- Not done (out of scope / prohibited here): no SOPS execution, no `sources-census.sh`, no
  `claim-ledger` run, no `drift-pins.sh`; no other source row audited.
- Remaining unknowns: (a) whether `sops groups`/`shamir_threshold` behave as documented in a
  deployed binary — only docs plus release-tree presence were observed; (b) whether key groups
  apply to **age** recipients at all (this page shows only PGP/KMS examples and never says "age");
  that requires S009/S011 or a measured run; (c) whether the 2026-10-19 capture used identity or
  decoded-gzip bytes — both yield `fed6b2e1…`, so the distinction is moot for this row but remains
  undocumented for other rows.
- Falsifier: any change to the decoded-body digest, the `#key-groups` quote, the footer commit id,
  or a display of a SOPS version on the page re-opens this audit.
