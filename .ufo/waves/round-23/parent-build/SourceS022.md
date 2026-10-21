# SourceS022 — S022 provenance audit (read-only)

Scope: EXACT row `S022` in `corpus/SOURCES.md`, its one `used-by` pointer, and the
supersession it declares. No other source row was audited; S012 was touched only
for the supersession/digest question S022 itself raises. No gate was executed, no
Vault runtime or account was contacted, no production file was edited. This
report is the only write. **Installs: none.**

## Observed revision

- HEAD `d218603b74099ddca0bd8f869516fc41db0979bf` (matches `plans/round-23.md` base).
  Worktree clean except untracked `.ufo/waves/round-23/`.
- `corpus/SOURCES.md` = `a5e1c13e95bafbdd7cbfdf2352fda7a6ba76b620fc2873f93031700f5f99cc30`,
  118 lines / 22,843 B; `git show HEAD:corpus/SOURCES.md` is the same digest.
  `corpus/stamps.tsv:61` pins exactly that digest.
- `S022` row at line 28, byte offset 14,635, 563 B + newline,
  line sha256 `d39cbeb414b32a0c857ba5e5e8572ad7becfe627c210f195b53e61d5349c681a`;
  13 `|` fields; **no `Fetch sha256:` field in the row**.
- `corpus/lessons/round-22-source-errata.md` (the `used-by` target) =
  `20e9bb06096d1e5819feab755df9bee1b7244efcf21834e212d8fa0ef26097c2`,
  pinned at `corpus/stamps.tsv:48`.
- Read-only observations only; no `pacman`, no repo/jj/index write.

## Row fields vs the served page (reopened 2026-10-21)

URL opened: https://developer.hashicorp.com/vault/docs/auth/jwt — HTTP 200,
`text/html; charset=utf-8`, decoded body 386,400 B,
sha256 `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa`.
Page `<link rel="canonical">` is exactly the row URL (no trailing slash).
JSON-LD `datePublished` = `dateModified` = `2026-04-15T00:14:24.000Z`.

| field | row value (abbrev.) | observation | verdict |
|---|---|---|---|
| `kind` | `docs` | vendor's own documentation page | supported |
| `tier` | `A` | primary vendor doc for the mechanism; census enums A/B/C, A+`docs` not inflation (`SC_INFLATION` fires only on `community`) | supported |
| `scope` | “Vault JWT roles from 1.17: audience match when aud is present; separate OIDC-role optional setting” | intro Note states the rule for the `"jwt"` role, starting Vault 1.17; troubleshooting bullet makes it optional for OIDC roles | supported |
| `anchor` | “Introduction Vault 1.17 note; OIDC configuration troubleshooting; served page opened 2026-10-20” | both locations exist; the intro Note has **no fragment id** (page-top Note before the first H2 `id="oidc-authentication"`); the second is `id="oidc-configuration-troubleshooting"` | supported, but see A2 |
| `teaches` | “supersedes S012 — exact bound-audience matching is the JWT-role path, not a mandatory bound_audiences setting for OIDC roles; OIDC keeps its documented optional qualifier.” | rule is role-type specific on the page; OIDC bullet retains the optional qualifier | supported; one wording hazard (A5) |
| `status` | `mined` | `used-by` file exists, carries `S022` on its column-1 `source:` line (`round-22-source-errata.md:1`) and both located quotes with dates (lines 16–17) | supported by inspection (census not executed) |
| `opened` / `recheck` | `2026-10-20` / `on-release` | digest of today's bytes equals the 2026-10-20 capture; latest stable Vault is 2.2.0, so no release trigger has fired since the open | supported |

Located quotes (same URL, observed 2026-10-21; each ≤25 words):

| heading | quote | words |
|---|---|---|
| page-introduction Note (no fragment) | “the associated `bound_audiences` for the "jwt" role must exactly match at least one of the `aud` claims declared for the JWT” | 21 |
| §OIDC configuration troubleshooting | “`bound_audiences` is optional for OIDC roles and typically not required” | 10 |

No row supersedes S022. S023 corrects a different URL (the lease page) and is a
sibling, not a supersession. The `## Paths` entry “S022 → S023” matches both rows.

## Version boundary — independently corroborated

- `https://developer.hashicorp.com/vault/docs/v1.17.x/auth/jwt`: HTTP 200,
  364,027 B, sha256 `f8253fbe31b1dcf076e4399358eb57454bd73abbe2d650861985017a77fd725e`;
  contains “Starting in Vault 1.17” and “must exactly match at least one”.
- `.../v1.16.x/auth/jwt`: HTTP 200, 356,461 B,
  sha256 `a78e2086f1fb7d1dacd62aff8fe36364f6d88c1052bf6b88463b01dc2a5e9a20`;
  contains neither phrase, but **does** contain “optional for OIDC roles”.
  So the mandatory clause is the 1.17 addition and the OIDC optionality predates it.
- Version switcher: “Currently viewing v2.x (latest).”; `v1.21.x` is the first
  non-latest entry with `found:true`; `v1.15.x` and older are `found:false`
  (not served). The row's “from 1.17” is documentary, not a deployment claim.
- Release clock: `releases.hashicorp.com/vault/index.json` latest stable = 2.2.0;
  no later version exists, so `on-release` is not currently due.

## Findings, by severity

### F1 (medium) — S022 carries no representation/hash/byte count (the D7 gap)
Observation: the row has no `Fetch sha256:` and no provenance row exists
(`corpus/source-fetches.tsv` absent; `grep -c 'Fetch sha256:'` = 16 of 23 rows,
the seven missing are S017–S023). `corpus/lessons/round-22-verifier-spotcheck.md:180`
already names this as D7. This is the pre-state the round-23 C2 plan targets, and
the planned `SC_FETCH` would fail S022 today by static inspection (not executed).
Fix: add the S022 provenance row with the exact values in §C2 below.

### F2 (medium, serious for C2) — “fetched bytes” is self-contradictory as written
The plan says the table records “SHA-256 and byte count of the fetched bytes”.
For this one URL, on 2026-10-21, I measured two honest values for the same content:

| request | bytes on the wire/file | digest |
|---|---|---|
| `curl --compressed` (br negotiated) or plain GET | 386,400 (decoded; plain response sends `Content-Length: 386400`) | `9a65b9d1…` |
| `curl -H 'Accept-Encoding: gzip'` (no `--compressed`) | 56,633 gzip stream, footer “original size 386400” | `deb71f55725357160be7633fa8e116a27c293d34f8d828b36ca8fea02fe5d993` |

The `ETag` `"989fbb89c19fdad8a8a4da184f1acb16"` (weak `W/` on the encoded
response) is a third digest-shaped string and is **not** the body digest.
Consequence: two conformant operators record different `SHA-256`/byte-count pairs
for identical content, and neither the “digest shape” nor the “quote bound” check
can detect it. Fix: make `representation` normative and non-empty, e.g.
`html/utf-8; GET; Content-Encoding removed; curl --compressed` and define the
recorded digest/bytes as the **decoded entity body**. Never record the transfer
stream, and never treat `ETag` as the digest.

### F3 (medium) — one URL, two registry rows, two different digests
S012 and S022 register the same URL. S012's immutable row records
`Fetch sha256: ec6e7b250d181c5c3cbbffb482e96f96649b9f556884e069fb62f64798357c45`
(2026-10-19; round-22 build evidence could not reproduce it) while today's bytes
hash to `9a65b9d1…`, with `dateModified` unchanged at 2026-04-15.
Counterexample to a URL-keyed table: a check asserting one digest per URL, or
comparing a provenance digest to an in-row historical hash, fails on the immutable
S012 row. Fix: key `source-fetches.tsv` by registry **id**, allow several rows for
one URL (distinct date/representation), and compare only
`provenance.url == row.url`; in-row hashes stay historical point attestations and
are never re-validated against fresh bytes (as `corpus/SOURCES.md` §Search-log
erratum already states). This is also why S022 must not inherit S012's digest.

### F4 (low–medium) — the `used-by` graph points at the lesson, not the consumer entry
S022's `used-by` is the errata lesson (correct: it carries the id and both
quotes). But the knowledge entry that restates the correction,
`corpus/knowledge/vault-openbao-token-lease-lifecycle.md`, lists
`S012 (…S016)` on its column-1 `source:` line and mentions S022 only in prose
(“S022 records that correction to S012”, line 166; the version-scoped bullet at
line 28 still attributes the rule to S012's page note).
Consequence: `SC_ENTRY_CITE` resolves the **superseded** row as that entry's
support, and a later re-point of the entry's `source:` line to S022 (the correct
authority for the qualifier) would fail because S022's `used-by` does not list the
entry. Fix: if L1 re-points or extends that entry's citations, extend S022's
`used-by` in the same append-only operation; otherwise record explicitly that the
entry is intentionally still keyed to S012 for the mechanism and to prose for the
qualifier.

### F5 (low–medium) — “exact bound-audience matching is the JWT-role path” compresses two facts
The page's OIDC bullet continues: “OIDC providers will use the client_id as the
audience and OIDC validation expects this.” (14 words, §OIDC configuration
troubleshooting, 2026-10-21, same URL.) OIDC login therefore still performs an
audience check — against `client_id` — so “the JWT-role path” must be read as
“the **mandatory `bound_audiences`** path”, not “the only audience-validating
path”. Separately, §JWT verification restates the rule as “for the role” with no
role-type word and **no** 1.17 gate; the gate exists only in the introduction
Note the row's anchor names. Unresolved (page is silent on matching semantics when
an OIDC role sets `bound_audiences` optionally); the row is not false, but its
wording is safe only with the “mandatory” qualifier. Recommendation: when this
row is consumed in round-23 prose, write “mandatory `bound_audiences` match (JWT
roles, Vault 1.17+)” and cite the intro Note for the version gate.

## C2 — exact provenance expectations for S022

Proposed row (tab-separated), one row per registry id:

| field | exact expected value |
|---|---|
| `id` | `S022` |
| `url` | `https://developer.hashicorp.com/vault/docs/auth/jwt` (byte-equal to row `source` URL and to the page's canonical link; no trailing slash) |
| `fetched` | `2026-10-21` (today's reopen; the identical 386,400-B digest was independently captured 2026-10-20 in `.ufo/waves/round-22/build/Source12.md`) |
| `representation` | `html/utf-8; GET; Content-Encoding removed; curl --compressed` |
| `sha256` | `9a65b9d12801ebb8339e16ee0a45b0f92bf094260634eb6fc1a6de8cc72e54fa` |
| `bytes` | `386400` (decoded body; matches the plain response's `Content-Length`) |
| `quote` | 21-word intro-note quote above |
| `location` | `introduction-note` (page-top Note, before the first H2 `id="oidc-authentication"`; no fragment id exists) |
| optional 2nd row | same id/url/date/representation, 10-word OIDC quote, `location` = `#oidc-configuration-troubleshooting` |

Checker rules that are honest offline (`sources-census.sh` is documented
“no network”): in-row `Fetch sha256:` **or** a complete provenance row; URL string
equality; `^[0-9a-f]{64}$`; `bytes` a positive decimal; quote ≤25 whitespace
tokens; `location` non-empty and either `introduction-note` or `^#[a-z0-9-]+$`.
Fragment existence and digest correctness cannot be verified without the bytes —
state that as a bound (or have the fixture store an excerpt hash) rather than
implying the gate re-fetches.

Route caveat for any future content check: `https://developer.hashicorp.com/vault/docs/v2.x/auth/jwt`
returned different full HTML (374,658 B, sha256 `dedabe3033d4bd4c6d2877745f222d544f0923b2381b7bf22e46e7f8447b583a`)
though both routes carry both quotes. Digests are route-scoped; record the bare
canonical route only.

Minimal failing fixture proposal for L1 (synthetic, not a fabricated pass): take
the census fixture's clean registry and (a) delete S022's provenance row while
leaving its row hashless → expect exactly one `SC_FETCH` finding for `S022` and
exit 1; (b) mutate the quote to 26 tokens → `SC_FETCH`; (c) mutate the digest to
63 hex chars → `SC_FETCH`; (d) change the provenance URL by a trailing slash →
`SC_FETCH`. Case (a) is the real pre-state today, so it is a regression fixture,
not an invented one. Note the two pinned ledger expectations that must migrate
with C2: `claim-ledger.tsv:52` (`R21-02`, `rows=23 … mined=21`, becomes 24/22 once
S024 lands) and `:53` (`R21-03`, `PASS (47 cases)`, becomes the new case count).

## Limits

- No gate, ledger, or census execution (read-only audit constraint); the
  `SC_FETCH` failure today is a static deduction from file state, not a run.
- The author's 2026-10-20 open was not observed directly; its bytes are attested
  only through the round-22 build record's digest, which today's fetch reproduces.
- `dateModified` is page metadata, not proof that no edit occurred; the
  historical (2026-10-19) bytes are unavailable.
- Digest values are point attestations of the decoded representation, valid for
  2026-10-20 → 2026-10-21 (three same-day fetches identical, plain and
  `--compressed` identical).
- No deployed Vault binary, token, lease, or account was contacted; the 1.17
  boundary is versioned-document evidence only.
- S012 was inspected solely for the supersession digest/path; its other fields
  were not re-audited. No other source row was audited.
