# ScoutContract — S024/S025/S026 against frozen SOURCES contract v1

Round-23 falsification seat. Measured 2026-10-21 03:59–04:09 UTC. Read-only on the lane;
the only lane write is this report. No legacy claim-ledger verify, no host-bound row, no
git/jj mutation, no installs. Public documentation re-fetch used exactly the allowed
profile.

## Target blobs (pinned)

| path | sha256 at report time | note |
|---|---|---|
| `corpus/SOURCES.md` | `06dde644801bee13736fca21d9ecadec83086ea1f5de77043394a62d2d525b29` | 121 lines, 24,995 B; stable across every measurement |
| `corpus/source-fetches.tsv` | `846b203734bcddce6c16e8346eea20bb1613b23c6607366b608c7afd41a4ae76` | rows 44-46 byte-identical across the file-hash changes; the header was edited (C5) |
| `corpus/sources-census.sh` | `24d834cc85344b762b485ef2b1c44cdbddab4e641f96acbaf2853823b02af057` | current; earlier blob `80966e20…` was broken (C1) |
| `corpus/lessons/round-23.md` | `cf79cd0c85d981a0d062eaa306bddee4de4fc31291c81c84699e135e4be535de` | last observed at 04:09Z; ≥7 blobs during measurement; line numbers pinned here |
| `LOG.md` | `b7d330298e82b15cce61ace2b496d2e66911d9241adf992f9e831d603297a290` | — |
| `SCORECARD.md` | `1d7210b366f3ce636c4d68dccf54a1edb87d87278b1370a99f10f091d5958cc7` | — |

`corpus/SOURCES.md` and the S024-S026 rows in `corpus/source-fetches.tsv` were
byte-identical across every measurement; the TSV header and the script/prose files were
edited by the author during this measurement (timeline in C; header/code tension in C5).
Line references are to the blobs above.

## What I attacked

The three round-23 registry rows (`corpus/SOURCES.md:30-32`), their Gate rows
(`corpus/lessons/round-23.md:27-29`), their provenance rows
(`corpus/source-fetches.tsv:44-46`), and the `SC_FETCH` gate that validates them. I
re-opened all three URLs with the declared request profile and recomputed both declared
representations; I ran the frozen contract's §Census one-liners, the lane gate, and its
selftest. No row from the parent's 43-row claim-ledger audit was re-run.

## Commands and exits

```
# append-only / no in-place edits
git diff --numstat d218603 -- corpus/SOURCES.md                 -> 3	0	corpus/SOURCES.md
git show d218603:corpus/SOURCES.md | grep -E '^\| S0(0[1-9]|1[0-9]|2[0-3]) ' | sha256sum
                                                                -> a22a95ed51ea5b75338a4913b9e469d26ae819deb1490c88a6e60b15a233c746
grep -E '^\| S0(0[1-9]|1[0-9]|2[0-3]) ' corpus/SOURCES.md | sha256sum
                                                                -> a22a95ed… (identical)

# frozen contract v1 §Census one-liners (verbatim)
rows            -> 26
malformed NF!=13-> 0
tier histogram  -> A=24 C=2
status histogram-> mined=24 queued=1 rejected=1
duplicate ids   -> (empty)
enum/inflation  -> (empty)
mined used-by   -> (empty; exit 0)

# lane gate
bash corpus/sources-census.sh
  at blob 80966e20 (04:00:58Z) -> stderr "corpus/sources-census.sh: line 242: S007: unbound variable", stdout empty, EXIT=1
  at blob 24d834cc (04:02:35Z) -> "SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)", EXIT=0
bash corpus/sources-census.sh --selftest
  both blobs -> "SOURCES_CENSUS_SELFTEST: PASS (59 cases)", EXIT=0

# independent re-fetch, declared request profile, one pipeline per URL
set -o pipefail
for u in <S024-url> <S025-url> <S026-url>; do
  curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' "$u" |
  python3 -c 'import sys,re,html,hashlib
b=sys.stdin.buffer.read(); t=b.decode("utf-8","replace")
t=re.sub(r"(?is)<script\b[^>]*>.*?</script\s*>"," ",t)
t=re.sub(r"(?is)<style\b[^>]*>.*?</style\s*>"," ",t)
t=re.sub(r"<[^>]*>"," ",t); t=html.unescape(t)
t=re.sub(r"\s+"," ",t).strip()
print(hashlib.sha256(t.encode()).hexdigest(), len(t), len(b), hashlib.sha256(b).hexdigest())'
done
  -> all three pipeline_exit=0 (values in B)

# provenance cardinality
awk -F'\t' '$0!="" && $0!~/^#/ {c++} END{print c}' corpus/source-fetches.tsv      -> 10
awk -F'\t' '$0!="" && $0!~/^#/ {print $4}' corpus/source-fetches.tsv | sort -u | wc -l -> 9
grep -c 'Fetch sha256:' corpus/SOURCES.md                                          -> 16
```

## A. Contract v1 conformance of S024-S026

**A1. New rows only / no in-place edits to S001-S023 — PASS.**
`git diff --numstat d218603 -- corpus/SOURCES.md` is exactly `3 0`; the three added lines
are `SOURCES.md:30-32`. Rows S001-S023 extracted from `d218603` and from the working tree
hash identically (`a22a95ed…`), so no `status`/`recheck`/`used-by` field of an existing row
changed and no old→new log entry is owed. S024-S026 were unused at the base
(`git show d218603:corpus/SOURCES.md | grep -c 'S024\|S025\|S026'` → 0) and are sequential.

**A2. status / recheck / used-by shape — PASS.**
All three rows are `mined | on-release | corpus/lessons/round-23.md`
(`SOURCES.md:30-32`, columns 8/10/12). The used-by path exists and its `source:` line
(`corpus/lessons/round-23.md:1`) carries S024, S025 and S026; the gate's cross-file check
(used-by citation plus tier A/B support) passes in the current CLEAN run. `on-release` is a
contract cadence.

**A3. Tier A scope — PASS.**
`kind=docs`, `tier=A` for official HashiCorp developer documentation (S024) and OpenBao
documentation (S025/S026), each scoped to a named mechanism: KV v2 config retention (S024),
JWT/OIDC authentication and claim validation (S025), token policy/TTL/revocation (S026).
No `community` row, no tier inflation; the contract census prints `A=24 C=2` and no
`SC_ENUM`/`SC_INFLATION` finding.

**A4. Gate quote requirement — PASS on URL/quote/length/location; strict access-date gap.**
- Gate URLs equal the registered URLs for all three (`round-23.md:27-29` vs
  `SOURCES.md:30-32`).
- Quotes are byte-identical across the registry `teaches` cell, the Gate table and
  `source-fetches.tsv` (all True), and are ≤25 whitespace words: 12 / 18 / 22.
- Each quote is a literal substring of the declared `rendered-text-v1` normalization of
  the live page: S025/S026 once, S024 three times (first under the config endpoint — see B).
- Location grounding verified by normalized-text order: S024 config heading 3095 < quote
  3270; S025 H1 0 < quote 640; S026 heading 4713 < quote 4921.
- STRICT GAP: the Gate table (`round-23.md:25-29`) has no access-date column. The date is
  only at `round-23.md:2` (`verified-at: 2026-10-21 …`) and in each row's anchor
  (`opened 2026-10-21`). Contract Rule 1 says the `## Gate` records, for every new row, the
  URL, **the access date**, and a ≤25-word quote. If the lane accepts the file-level
  `verified-at` line as the recording, this is satisfied; under the literal clause it is
  not. Low severity; the date is unambiguous.
- Cosmetic: S025's location is `§JWT/OIDC auth method` in the row but `H1 JWT/OIDC auth
  method` in the Gate/TSV. Same anchor, different prefix.

**A5. Correction-row shape — S025/S026 PASS; S024 is mislabeled.**
S025's `teaches` opens `supersedes S014 — ` and S026's opens `supersedes S016 — `, as Rule
2 requires. S024's `teaches` opens `KV v2 config caps…` and carries no supersession marker,
which is correct for a new row. However the prose calls S024 a correction row:
`round-23.md:11` ("plus three correction rows"), `round-23.md:171` ("three A/mined
correction rows: S024 …"), `LOG.md:1184` ("S024-S026 correction rows"), and
`SCORECARD.md:840` ("S024-S026 are correction rows"). `plans/round-23.md:15` calls S024
"one new frontier row". Under the contract's Rule 2 definition, S024 is a new row, not a
correction. Wording defect, not row invalidity.

**A6. Anchor shape — S025/S026 PASS; S024 strict gap.**
S025/S026 anchors carry `Version 2.7.x`, and the live normalized text carries
`Version 2.7.x`. S024's anchor (`SOURCES.md:30`) is `POST /:secret-mount-path/config
parameters, max_versions; served live docs opened 2026-10-21`: the section is exact, but
there is no version/commit/publication revision, only the access date. The live page
exposes `"datePublished":"2026-04-15T00:13:54.000Z"` / `"dateModified"` in JSON-LD, a
`Vault v2.x (latest)` / `v1.21.x` version selector, and an upstream edit link to
`content/vault/v2.x/content/api-docs/secret/kv/kv-v2.mdx`. Contract anchor clause: "plus
revision (version, commit, or publication date)". An access date is not a publication date.
Low severity; the row's scope is config-only and the capture digest is declared, but the
anchor is weaker than the available revision (compare S023's recorded served source route).

**A7. Leads ledger — DEFECT at `corpus/SOURCES.md:54`.**
The `## Leads (unopened)` bullet still says the "Vault KV v2 API (version deletion
settings)" lead is "not opened by the row author, lead only, not evidence". S024 now mines
exactly that page. The round-22 precedent recorded a lead disposition note at
`SOURCES.md:57-60` when the custom-workflow lead became S018; round 23 has no equivalent
note for the KV v2 lead, so the lead ledger is false at `:54`.

## B. Independent provenance re-measurement — PASS

| row | declared raw sha256 / bytes | re-fetched | declared norm sha256 / chars | re-fetched | quote literal |
|---|---|---|---|---|---|
| S024 | `aaf52ac2…` / 586,146 | match | `7c5a19e2…` / 24,327 | match | yes, 3× |
| S025 | `449ef132…` / 63,046 | match | `ca496ad8…` / 15,911 | match | yes, 1× |
| S026 | `52295218…` / 47,384 | match | `ed949658…` / 14,571 | match | yes, 1× |

- `row_identity_sha256` recomputed for all three —
  `43e67594…` / `e91b8e3c…` / `0be2cff9…` — matches `source-fetches.tsv:44-46`.
- S024: the three quote occurrences are the config parameters (offset 3,270), the metadata
  update (19,988) and the patch endpoint (21,911). The Gate/TSV location disambiguates to
  the config endpoint. The same normalized text contains
  `delete_version_after (string:"0s") – If set, specifies the length of time before a
  version is deleted.`, which supports the `teaches` clause.
- S025: raw HTML carries `The <code>jwt</code> auth method can be used to authenticate
  with OpenBao using OIDC or by providing a JWT`, confirming the "renders `<code>jwt</code>`"
  claim and the continuation.
- S026: the quote occurs once, after the §Token hierarchies and orphan tokens heading.
- Two consecutive same-day GETs per URL were byte-identical. The tsv's
  `decoded-http-body-volatile-v1` is substantively supportable because the pages carry
  deployment-coupled build identifiers (S024 `"buildId":"build-TfctsWXpff2fKS"`;
  S025/S026 content-hashed assets such as `main.aa34622e.js`). Bound: the lesson explains
  volatility only for S020 (`round-23.md:45-54`), not for S024-S026; the label skips the
  raw same-URL agreement check, while the normalized identity is stable and S021/S026
  agree (`ed949658…`).

## C. Gate operability — measured FAIL then PASS; the tree moved during measurement

C1. At 04:00:58Z, blob `80966e20…` of `corpus/sources-census.sh`:
`bash corpus/sources-census.sh` printed no stdout, and stderr was exactly
`corpus/sources-census.sh: line 242: S007: unbound variable`, exit 1. Root cause: the
round-23 `SC_FETCH` block added the dead line
`while IFS= read -r fid; do [[ -n $fid ]] && SUPERSEDED[$fid]=1; done < <(awk … 'supersedes S…')`
(`sources-census.sh:242`) but `SUPERSEDED` was not in the
`declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()` list at `:229`. Under `set -u`,
the non-numeric subscript `S007` is evaluated as an unset arithmetic variable. The array is
read nowhere, so the loop was dead; it fired because the registry has six supersession rows
(S019→S007, S020→S006, S022→S012, S023→S013, S025→S014, S026→S016).

C2. `bash corpus/sources-census.sh --selftest` passed 59/59 at **both** blobs. Every
fixture's `teaches` lacks a `supersedes` marker, so no selftest case executes the
supersession loop. The 59-case selftest therefore did not, and does not, prove the gate
runs on the real registry; only the real invocation did.

C3. At 04:02:35Z, blob `24d834cc…` removed the dead loop. Current invocation:
`SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1
entries_sourced=4 legacy=21)`, exit 0; selftest `PASS (59 cases)`, exit 0. Before the fix I
also ran a hypothetical patched copy via process substitution
(`bash <(sed '242,246d' corpus/sources-census.sh) verify --root <lane>`), which printed the
same CLEAN line, exit 0 — evidence the crash was the only blocker, not a semantic failure
of `SC_FETCH`. This patched run is not the production gate and is labelled hypothetical.

C4. Residual bound: the gate now has no supersession handling and no regression case;
S025/S026's `supersedes` markers were verified by manual regex, not by the census.

C5. Header/code/claim tension (current blobs): `corpus/source-fetches.tsv:21` says the
volatile normalized digest is "never a drift pin. No cross-capture equality is enforced";
the C2 row (`corpus/lessons/round-23.md:61`) now says captures are point attestations and
no longer claims same-URL agreement; but `corpus/sources-census.sh:282` and `:288` still
emit `same-url-digest-disagreement` and `same-url-normalized-disagreement` findings, and
M23-1 (`corpus/lessons/round-23.md:145`) says "same-URL captures must agree". The code
enforces cross-capture equality; the header denies it. The S024-S026 rows are unaffected
(S021/S026 share a URL and their normalized digest agrees, `ed949658…`), but a future
same-URL disagreement would fail the gate despite the header. Documentation/implementation
contradiction in the C2 artifact; low-medium.

## D. Count claim — measured 9 distinct URLs; artifacts corrected from 7

`10` provenance rows cover **9** distinct URLs (`S021` and `S026` share
`https://openbao.org/docs/concepts/tokens/`). The task brief and the earlier lesson/LOG
said "over 7 URLs". During measurement the artifacts were corrected:
`corpus/lessons/round-23.md:174` now says "nine distinct URLs", `LOG.md:1202` says the
same, and `SCORECARD.md:840` says "the 10 captures cover nine distinct URLs". If the
parent's claim ledger or dispatch still carries "7", it is false by two; the correct
statement is 10 rows / 9 distinct URLs.

## Bottom line

- No row-level violation of the frozen contract in S024-S026: append-only, A/mined,
  correct `status`/`recheck`/`used-by`, exact and ≤25-word Gate quotes, and provenance that
  reproduces byte-for-byte (raw and normalized) on the live pages.
- Four documentation-shape gaps persist: the stale KV v2 lead at `SOURCES.md:54`; S024
  mislabeled a correction row (`round-23.md:11,171`; `LOG.md:1184`; `SCORECARD.md:840`);
  S024's anchor lacks an available revision; and the Gate table lacks a per-row access date
  under the strict Rule 1 reading.
- The current census is CLEAN and the 59-case selftest passes, but the selftest does not
  cover the supersession path that crashed the gate at blob `80966e20…`; the claim must not
  cite the selftest as proof the real-registry gate runs.
- The provenance claim must state point-attestation bounds (not drift pins), the volatile
  representation for S024-S026, and 9 distinct URLs, not 7.
- The C2 artifact contradicts itself on cross-capture equality: `source-fetches.tsv:21`
  says none is enforced, while `sources-census.sh:282,288` still fail same-URL
  digest/normalized disagreements and M23-1 says captures must agree (C5).

## Remaining unknowns

- The lesson/LOG/SCORECARD and the TSV header were edited concurrently; the lesson and TSV
  hashes changed repeatedly while I measured (at least seven lesson blobs observed). Line
  numbers are pinned to the last observed blobs and may shift. The S024-S026 row bytes were
  stable throughout.
- Whether the lane treats a served-route plus access-date anchor as satisfying the anchor
  revision clause (S023 precedent); I report the strict reading.
- Whether "correction row" is intentional loose usage for `S024`; the contract's Rule 2
  definition and `plans/round-23.md:15` say otherwise.
