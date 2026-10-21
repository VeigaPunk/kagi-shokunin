# SourceS011 — S011 source-bound provenance audit

Seat `SourceS011` (leaf scout, read-only, no subagent dispatch). This report is the only write.
Axes: calibration, freshness, operability.

**Target.** Row **S011**, `corpus/SOURCES.md:17`, at the frozen base
`d218603b74099ddca0bd8f869516fc41db0979bf` (`plans/round-23.md:3`).
- At HEAD, `corpus/SOURCES.md` is `a5e1c13e…cc30`, which equals `corpus/stamps.tsv:61`.
- Row-line sha256 is `565fcf51fe9747714bbc2bb6aedad0dce5bd673e399d137f2f5cfa765aba6598` with the
  trailing LF. The row is byte-identical at `c41af82`, `e1544c1`, `c2cab35` and `d218603`, and in
  the working tree as observed at 2026-10-21T03:55Z.
- Used-by entry: `corpus/knowledge/sops-age-key-rotation.md` is `a6b14ff7…07a7` (112 lines,
  7,591 B), which equals `stamps.tsv:30`. HEAD and the working tree are the same.

**Verdict.** S011 is **supported as written**:
- tier A, `docs`, `mined`;
- anchor, quote and teaching located on 2026-10-21;
- no superseding row exists at HEAD or in the in-flight tree, and none is warranted.

S011 is **active public evidence**. Its in-row Fetch sha256 is a 2026-10-19 point observation that
**reproduces byte-for-byte today**. It is not merely historical with an undocumented representation.
No deployed-product proof exists, and none is claimed.

There are two measured C2 contradictions (§4.1 and §4.2). The second was also sent to
`agent://KagiR23` because `rendered-text-v1` is still in flight.

## 1. Opens (2026-10-21 UTC, public HTTPS only)

| what | request | observed |
|---|---|---|
| canonical HTML, identity | `curl -sSL`, no Accept-Encoding, 03:43Z, twice | 200 `text/html; charset=UTF-8`, **33,153 B**, `d0ab8b201f1a6d5f5751e1f261f904822492c530bdcdc5a4db9a8e178c2e180c`. This equals the row. The two bodies are `cmp`-identical. |
| L1 profile `curl-fsSL-compressed-v1` | `curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)'`, 03:53Z | 200. The final URL equals the registered URL. Decoded body: 33,153 B, `d0ab8b20…`. Curl's `%{size_download}` reported **9,328** B, the wire size, not the body. |
| gzip, undecoded | `-H 'Accept-Encoding: gzip'` | `content-encoding: gzip`, 9,989 B, `d7642a70…a5d5`. Gunzip gives `d0ab8b20…`. |
| br, undecoded | `-H 'Accept-Encoding: br'` | 9,355 B, `7568cb58…937f` |
| no trailing slash | `…/key-management` | **301** to the slash URL |
| harness `read` of the URL | default reader | **Failed to open the article.** The reader took the advertised RSS alternate `index.xml` (468 B, `2ea1de3d…b110`), which carries only the channel title, with no anchor and no quote. It is not used as evidence; this alternate-feed class is covered in `SourceS009` §4. |
| docs source | `raw.githubusercontent.com/getsops/docs/9b7b84e…/content/en/docs/usage/key-management/_index.md` | 200, 5,037 B, 131 lines, `214d668554e9a84d8e950868300b6c9d9ca09f00084052f56ea54d358e364f47`. The same file at `main` is byte-identical. |
| SOPS releases | `github.com/getsops/sops/releases.atom` and `tags.atom` | Newest is **v3.13.3** (2026-07-23T05:29:11Z). Before it: v3.13.2 (2026-06-30) and v3.13.1 (2026-05-16). |
| SOPS changelog | `raw.githubusercontent.com/getsops/sops/main/CHANGELOG.md` | 200, 61,040 B, `d2531645…aa20` |

Transport facts:
- The ETag differs by encoding: identity `"ac822f490132c93fcee7b7efd1b2a8ef-ssl"`, compressed
  `"…-ssl-df"`.
- Other headers: `vary: Accept-Encoding`, `cache-status: "Netlify Edge"; hit`, `age: 110303`,
  `cache-control: public,max-age=0,must-revalidate`, `date: Wed, 21 Oct 2026 03:43:17 GMT`.

Page identity:
- The `<title>` is the page "Key management" on the SOPS site.
- `meta itemprop=dateModified` is `2026-05-15T19:05:01+02:00`.
- The footer shows a last-modified date of 2026-05-15 and links
  `getsops/docs/commit/9b7b84e297bdabc9c78e571c1e6db43dcd69454a`.
- `og:url` is `/docs/usage/key-management/`. There is no `rel=canonical`.
- There is no script nonce and no Cloudflare email-protection fragment.

The raw HTML carries the whole docs sidebar (42 `m-docs…` ids). Its digest is therefore coupled to
each docs-site deploy, not only to this article.

## 2. Row adjudication (`corpus/SOURCES.md:17` at `d218603`)

| field | observed | decision |
|---|---|---|
| source/URL | 200. The final URL equals the registered string; the no-slash form returns 301. | supported |
| kind `docs` / tier A | Official SOPS documentation site; the footer revision links into `github.com/getsops/docs`. Tier A covers the documented procedure, not a runtime guarantee. | supported |
| scope | §`updatekeys` command: syncs the access set from `.sops.yaml`. §`rotate` command: new data key plus re-encryption, with add/rm flags. §Rotating secrets…: remove the key from its group, then `updatekeys`, then `rotate --in-place`, then commit, and only then rotate the real secrets. Footnote `fn:1` limits the reverse-order risk to two situations. | supported |
| anchor | The four cited sections exist as `h2#adding-and-removing-keys`, `h3#updatekeys-command`, `h3#rotate-command` and `h3#rotating-secrets-after-a-key-in-a-key-group-has-been-compromised` (under `h2#key-rotation`). Date and commit match the footer and meta. The anchor omits §Direct Editing; round 22 already adjudicated that as no-action (`round-22/build/Entry19.md:109-128`, `falsify/AttackEntry19.md:110`), so it is not re-litigated here. | supported |
| teaches + quote | Quote located **exactly once**, inside `h3#rotate-command` (§4.1 covers its typography). | supported |
| status `mined` | The used-by path exists, and the entry's `source:` line (`:3`) cites S011, so reciprocity holds. | supported |
| opened 2026-10-19 | Historical. The round-21 Gate (`corpus/lessons/round-21.md:65`) records the same quote. | consistent |
| recheck `on-release` | No SOPS release after 2026-10-19 (newest v3.13.3, 2026-07-23), so a recheck is **not due**. Caveat: docs commits are independent of releases (`9b7b84e` is docs-only). The cadence alone would miss a docs-only edit; the entry's recheck (`:5`) also watches the footer. | holds, with caveat |
| Fetch sha256 | Reproduced on three separate days: the round-21 capture (2026-10-19); `round-22/build/Source11.md:7-9` and `falsify/ReopenSource11.md:34,61` (2026-10-20); and this seat (2026-10-21) under the identity, gzip-decoded and L1-profile fetches. | reproduces |
| supersession | At HEAD only S006, S007, S012 and S013 are superseded. The in-flight rows supersede S014 (S025) and S016 (S026). There is no `supersedes S011` anywhere. | S011 stays active |

**Four evidence classes, kept separate**
- **Historical bytes.** The in-row digest is the 2026-10-19 observation of the decoded HTML body. It
  is reproduced, not merely asserted.
- **Current semantic support.** On 2026-10-21 the quote is located in §`rotate` command. The docs
  source blob is unchanged since `9b7b84e` (`main` is identical).
- **Transport/raw-HTML volatility.** Wire digests differ by negotiated encoding, and the ETag carries
  an encoding suffix. The site-wide sidebar can change the raw digest without any article change.
  Equal digests mean identical bytes, so the 2026-10-19 reading still holds. Unequal digests do
  **not** imply semantic drift.
- **Deployed-product proof: none.** `sops` is not on PATH (`command -v`; nothing was executed). The
  page is unversioned, but its example syntax is version-scoped:
  - CHANGELOG §3.9.0: "Add separate subcommands for encryption, decryption, rotating, editing, and
    setting values" (the `sops rotate` form);
  - CHANGELOG §3.12.0: "Add support for HuaweiCloud KMS" (the `--hckms` flag family on this page).

  The page therefore attests current documentation, not any deployed or older SOPS. The entry
  already says "documented, not measured" (`:9-10`), and its Clarification (`:101-112`) disclaims
  release and runtime versions. No overclaim was found.

## 3. Used-by pointer chain (`corpus/knowledge/sops-age-key-rotation.md`)

| entry line | S011 attribution | located in (live, 2026-10-21) | result |
|---|---|---|---|
| 16 | three ways to change recipients | §Adding and removing keys | located. Age attribution was round-22 D2 (`build/Source11.md:114-122`); not redone. |
| 17, 20 | rotate creates a new data key and re-encrypts; the row quote | `h3#rotate-command` | located |
| 28-29 | key information persists in the file's `sops` section (entry quotes it without backticks) | `h2#adding-and-removing-keys` | located in rendered text; **not** literal in the docs markdown, where `_index.md:13` has `sops` in backticks |
| 52-58 | compromise order and its two quoted ordering fragments | `h3#rotating-secrets…` | located |
| 60-62 | footnote: two situations | `li#fn:1`, reached through `fnref:1` in that section | located. An anchor resolver must follow `fnref` to `fn`. |
| 62-64 | Direct Editing add-access warning | `h3#direct-editing` | located |
| 101-112 | Clarification: `rotate` add/rm changes recipients and the data key | `h3#rotate-command` | supported |
| 6 | `Reverify: R21-02` | `corpus/claim-ledger.tsv:52` | resolves. It checks the citation chain only; not run. |
| 111-112 | `Reviews: kagi-shokunin/.ufo/waves/round-22/build/Source1{0,1}.md` | resolves from the fleet root `/home/vgpnk/Projects/shokunin`; **does not** resolve from the repo root | operability note for any C1 pointer resolver |

Some S011 consumers are absent from `used-by`. That is legitimate under the census semantics, where
used-by means files whose `source:` line cites the row. They belong to the same class as in-flight
M23-2 (`corpus/lessons/round-23.md:140`):
- `corpus/lessons/round-21.md:39` (E2 admission), `:46` (rejection rationale), `:65` (Gate quote);
- `corpus/README.md:77`;
- `plans/round-21.md:34`.

They are listed so that a pointer closure can name them. No action is required unless used-by
semantics widen.

## 4. C2 fetch+quote provenance for S011 — exact expectations

L1 currently keeps S011 as a legacy in-row pin (`corpus/source-fetches.tsv:32-34`). If S011 is given
a declared row, it should carry the values below (16-column schema in `source-fetches.tsv:4-28`):

| column | expected value |
|---|---|
| id / status | `S011` / `mined` |
| row_line_sha256 | `565fcf51fe9747714bbc2bb6aedad0dce5bd673e399d137f2f5cfa765aba6598` (with LF). The no-LF form `680c8468…514b` is the convention used in `round-22/registry-census-details.json:77`. |
| url / final_url / http_status | `https://getsops.io/docs/usage/key-management/` / same / `200` |
| request_profile / fetched | `curl-fsSL-compressed-v1` / `2026-10-21` |
| representation | `decoded-http-body-v1` (non-volatile: identical on 3 days, no per-response token, no daily chrome; coupled to site deploys through the sidebar) |
| sha256 / bytes | `d0ab8b201f1a6d5f5751e1f261f904822492c530bdcdc5a4db9a8e178c2e180c` / `33153`. Never use curl's `%{size_download}` (9,328) for bytes. |
| revision | `-` (stable URL). Optional chrome-independent pin: getsops/docs `9b7b84e…` `_index.md`, 5,037 B, `214d6685…4f47`. |
| quote / normalization | "Use updatekeys if you want to add a key without rotating the data key." (14 words, rendered form) / `rendered-text-v1` |
| normalized_sha256 | **Unresolved until `rendered-text-v1` is pinned (§4.2):** `4a71dbc959fc4a0dd596c973d90001e894b28558db0774d6d0f8653c1af4c536` (5,451 B) with unescape, then Unicode `\s+` collapse, then trim; `03a8b8cd7d20fcea8f0432680c06e044ad359b764b01a6dc33ceec3bf7996459` (5,453 B) if collapse comes first or `\s` is ASCII-only; `2eafccac95420392e641e3baf2d7a69b9f36971ae6e870ba4f2ea0efe0fb4fa3` (5,453 B) with no trim |
| location | §`rotate` command (`h3#rotate-command`; the quote occurs once on the page) |

**Classification rule.** S011 is active: it is `mined` and has no `supersedes S011 —` row. Outcomes
for a re-check:
- **Hash match:** the bytes are identical, so the 2026-10-19 reading holds.
- **Hash mismatch:** re-fetch under the declared profile and re-locate the quote inside
  `h3#rotate-command` before claiming any drift.
- **Quote absent from that section:** semantic recheck.
- **HTTP failure:** the source is unreachable, not refuted.

### 4.1 Real contradiction A (S011-specific, measured): the in-row quote is located under neither declared normalization

| representation | row/Gate quote with backticks (`SOURCES.md:17`, `round-21.md:65`) | backtick-free form |
|---|---|---|
| decoded HTML bytes (`raw-literal-v1`), text is `Use <code>updatekeys</code> if …` | 0 matches | 0 matches |
| `rendered-text-v1` text | **not located** | located once |
| docs markdown `_index.md:58` at `9b7b84e` | located (literal) | not located |

The entry's quote at `:28-29` runs the other way: it is located in rendered text but not in the
markdown. S011's quotes therefore mix two representations, and no single literal normalization
locates both.

The in-flight round-23 lesson lists legacy quote/representation cases only for S008 (reST-rendered)
and S014 (uppercased), and names only S008 as a reproducing legacy digest
(`corpus/lessons/round-23.md:39-43,103-113`). S011 belongs in both lists:
- its quote uses markdown-source typography;
- its digest reproduces exactly under the L1 profile.

The two lists understate S011, and the round-22 registry prose does the same: `corpus/SOURCES.md:101-106`
at HEAD names the reproduced captures without S011, although commit `4be5da3` added that prose
together with `ReopenSource11.md:34,61,69`, which reproduced it.

**Fix.** No superseding row (anchor, scope and teaches are correct). Either:
- add S011 to the D7 enumeration ("digest reproduces, 33,153 B `d0ab8b20…`; quote is markdown-source
  typography"), or
- give S011 the declared row above with the backtick-free quote.

In either case, state that `rendered-text-v1` quotes are stored without markdown code-span
backticks.

### 4.2 Real contradiction B (C2 contract, measured through S011): `rendered-text-v1` as declared does not reproduce its own recorded digests

**Declaration.** `corpus/source-fetches.tsv:25-26`, `corpus/sources-census.sh:72-74` and
`corpus/lessons/round-23.md:40-41` define it as: strip script/style, tags to a single space,
`html.unescape`, collapse whitespace. They give **no trim** step, no step order and no whitespace
class.

**Control (normalizer calibration only; S021/S026 claims not audited).** The OpenBao tokens page,
fetched with the L1 profile, gave raw `52295218…f82c`, 47,384 B, which equals `source-fetches.tsv:39,44`.
- The literal declaration produces `f094ef74da12556bd9436e2b216d9b7e8ab0fe48d972ead26c2af29d0570e479`
  (14,610 B, with a leading and a trailing space).
- The recorded `ed949658…e2e3` (14,608 B) reproduces **only with trim**.

**S011.** The footnote back-reference contains `&#160;`. The digest therefore splits by step order
and whitespace class (`4a71dbc9…` versus `03a8b8cd…`). The first divergence is the NBSP after the
footnote's final sentence.

**Severity: medium (operability).** Any re-implementer that follows the declaration misses the
digest of every `rendered-text-v1` row because of the trim. On NBSP pages the result also depends
on the implementation.

**Fix.** Pin one reference implementation in all three declarations:
1. `re.sub(r'(?is)<(script|style)\b.*?</\1\s*>',' ',h)`
2. `re.sub(r'<[^>]+>',' ',·)`
3. `html.unescape`
4. `re.sub(r'\s+',' ',·)` (Python `str`, Unicode `\s`)
5. `.strip()`
6. UTF-8

### 4.3 Synthetic minimal failing fixture proposal for L1 (not run; no passing result claimed)

Each vector gives input HTML, then the expected output of the pinned reference, then the sha256 of
that UTF-8 output.
- **V1 trim:** `<p> x </p>` gives `x`, `2d711642b726b04401627ca9fbac32f5c8530fb1903cc4db02258717921a4881`.
  An implementation of the literal declaration yields ` x ` (`fc191eaf…7728`) and must **fail**.
- **V2 NBSP order:** `<p>a&#160; b</p>` gives `a b`,
  `c8687a08aa5d6ed2044328fa6a697ab8e96dc34291e8c2034ae8c38e6fcc6d65`. Collapse-first or ASCII-`\s`
  yields `a\u00a0 b` (`98a0604a…5d87`) and must **fail**.
- **V3 code-span quote:** body `<h3 id=rotate-command>x</h3><p>Use <code>updatekeys</code> if</p>`,
  quote ``Use `updatekeys` if``, location `rotate-command`. The checker must report
  quote-not-located rather than pass silently. The backtick-free quote must be located.

Placement:
- as `--selftest` cases beside the `SC_FETCH` cases (fixture conventions at
  `corpus/sources-census.sh:396-443`);
- or, if the census stays offline and does not compute digests, as declared test vectors in the
  `source-fetches.tsv` header.

Sibling cases are deliberately not duplicated: wire bytes (`SourceS010` §4) and feed alternates and
offsets (`SourceS009` §4).

**Further low item (operability).** The row-line hash domain is inconsistent across artifacts for the
same unchanged S011 line:
- `round-22/registry-census-details.json:77` hashes it without the LF (`680c8468…`);
- `round-22/falsify/ReopenSource01.md:53` and `source-fetches.tsv:7` include the LF (`565fcf51…`).

Any cross-artifact comparison must state which domain it uses.

## 5. Limits

- **Evidence scope.** Public documentation text only. No SOPS execution and no deployed-product proof.
- **No gates run.** No census, ledger, selftest or gate was run. Normalizer digests come from my own
  Python stdlib code under the stated variants.
- **Control page.** The OpenBao page served only as a normalizer control; S021/S026 content was not
  audited.
- **Frozen base.** The audit base is HEAD `d218603`. In-flight round-23 files were read but not
  audited, and may change after 03:55Z:
  - `SOURCES.md` at `06dde644…`, with S024–S026 at `:30-32`;
  - `plans/round-23.md`, `corpus/lessons/round-23.md`, `corpus/source-fetches.tsv`;
  - `sources-census.sh`.
- **Tools.**
  - `curl`, `sha256sum`, `cmp`, `gzip`, the python3 stdlib, `grep`/`sed`/`awk`, and read-only `git`
    (`rev-parse`, `log`, `show`).
  - One early `git status --porcelain` ran without `GIT_OPTIONAL_LOCKS=0` and may have refreshed
    index stat data; no content changed. Later reads set it.
  - No installs. No `op`, vault or host commands.
- **Scratch.** `/tmp/s011-audit/` (fetched bodies, feeds and the changelog) was created during the
  audit and removed before this report was written. Nothing else was written.
- **Quote budget.** About 16 words from the S011 page and 17 from the SOPS CHANGELOG. Round-22
  decisions D1–D3 are cited, not redone.

Report: .ufo/waves/round-23/parent-build/SourceS011.md
