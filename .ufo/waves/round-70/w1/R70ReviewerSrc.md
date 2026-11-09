Author: R70ReviewerSrc (reviewer)

# Non-author source spot-check — registry delta S170–S172

Re-opened all three URLs live (curl -fsSL --compressed, browser UA, into scratch
`/fast/scratch/hyaku/kagi-r70/R70ReviewerSrc`) on 2026-11-08. Byte-compared each
live body against the committed capture
`.ufo/waves/round-70/capture/S17x.body` and the `corpus/source-fetches.tsv` row,
located each row's quote with `rendered-text-v1.py locate`, checked the
`corpus/SOURCES.md` registry rows (11 cells, status/used-by, tier), judged the
three gate decisions, and verified the five `## Measured` statements of
`corpus/knowledge/openbao-pki-certificate-lifecycle.md` against S170/S171 text.

## Live re-open (all byte-identical)

| id | URL | HTTP | committed capture | live body | TSV row | quote locate |
|---|---|---|---|---|---|---|
| S170 | https://openbao.org/docs/api/secret/pki/ | 200 (effective same) | 620683 B sha256 `9fa76939…e5c1123` | 620683 B sha256 `9fa76939…e5c1123` | same sha256/bytes; quote 16 words | count=2 |
| S171 | https://openbao.org/docs/secrets/pki/ | 200 (effective same) | 27950 B sha256 `c0ec7fbc…66ab695` | 27950 B sha256 `c0ec7fbc…66ab695` | same sha256/bytes; quote 15 words | count=1 |
| S172 | https://developer.hashicorp.com/vault/api-docs/secret/pki | 200 (effective same) | 2518415 B sha256 `65104f6b…061ddd` | 2518415 B sha256 `65104f6b…061ddd` | same sha256/bytes; quote 8 words | count=2 |

Normalized digests re-computed with `rendered-text-v1.py digest` on committed and
live bodies all match the TSV `normalized_sha256` (S170
`0419f2a3…66eae93` 164032 norm bytes; S171 `93bb8048…169879f` 3149; S172
`bc75882d…af5c630` 187678). The TSV `row_identity_sha256` for S170
(`ddbf3a57…`) was not recomputed; the census (below) recomputes it and passes.
`curl %{size_download}` reports the on-the-wire compressed size (S170 68891,
S171 6908, S172 165006); `decoded-http-body-v1` and `--compressed` mean the
digest/byte domain is the decompressed body, which is what matches — no
discrepancy. Receipts copied to
`.ufo/waves/round-70/w1/R70ReviewerSrc/live-fetch-receipts.txt` and
`quote-locates.txt`.

## Registry rows (SOURCES.md)

Header is the 11-column form. All three rows split into exactly 11 cells:

- S170: `docs | A | mined | 2026-11-08 | on-release | corpus/knowledge/openbao-pki-certificate-lifecycle.md` (used-by).
  Entry `source:` line names S170 and S171; the entry file exists and carries
  both ids, satisfying SC_USEDBY_NOCITE / SC_ENTRY_CITE (census CLEAN, §census).
- S171: `docs | A | mined | 2026-11-08 | on-release | corpus/knowledge/openbao-pki-certificate-lifecycle.md`.
  Same used-by; the entry's `source:` line names S171. Tier A: the overview
  page is OpenBao's own documentation stating design rationale directly
  (the S171 quote is verbatim on the page) — A is the vendor-primary tier used
  throughout this registry for OpenBao docs, consistent with S014/S016/S025/S026.
- S172: `docs | A | rejected | 2026-11-08 | 180d | corpus/lessons/round-70.md`.
  Status `rejected` with `REJECTED:` + `flip:` in teaches (SC_REJECT_SHAPE
  passes). Used-by points at the lesson file for the rejection record —
  precedent: S156 (rejected → lessons/round-65.md) and S169 (rejected →
  lessons/round-69.md) do the same; most rejected rows use `—`. The lesson
  file `corpus/lessons/round-70.md` does not yet exist on disk (L1 writes it
  on integration; the census does not require rejected-row used-by paths to
  exist — SC_USEDBY_MISSING applies to mined rows only, and the census is
  CLEAN). Rejected-row used-by is tolerated by the gate but points at a
  not-yet-written path — noted, not counted as a defect against the candidate
  tree (the census explicitly passes it).

No cell-count, enum, tier or status defects. S170/S171 `mined` ↔ entry
`source:` ↔ used-by triangle closes both ways.

## Gate decisions

**S170 admit — AGREE.** The page is the OpenBao PKI secrets-engine API
documentation (docs, tier A, OpenBao 2.7.x). It states every mechanism the
round relies on: `internal` vs `exported` key generation (§Generate key),
role `max_ttl` / `allowed_domains` / `allow_any_name` / `no_store`
(§Create/Update role), the `ttl` bound (§Generate certificate and key), and
revoke-by-serial + CRL rotation (§Revoke certificate). Quote locate count=2
(§Generate key and §Generate intermediate, same sentence). The legacy path
`/api-docs/secret/pki/` answering a 328 B meta-refresh stub is recorded in the
fetch receipt and the entry — correct handling, not a redirect risk.

**S171 admit — AGREE.** The overview page's opening section states the
short-TTL rationale verbatim ("By keeping TTLs relatively short, revocations
are less likely to be needed, keeping CRLs short", 15 words, locate count=1).
It is admitted for that rationale only (scope: "design rationale: short-lived
certificates instead of revocation-heavy operation"); the entry cites it for
the checklist's short-TTL motivation, not for any API parameter. Admitting a
second page from the same product line for a narrower, statable claim is
sound; the plan's "opened for the same mechanics — decision recorded in the
lesson Gate" matches the scope cell.

**S172 reject — AGREE.** The page documents HashiCorp Vault's PKI API — a
different product line since the 2023 fork. The identical sentence "Cannot be
greater than the role's max_ttl value" exists on both pages (verified: S170
has it three times in the `ttl` parameters, S172 twice), so the page is a
tempting but illegitimate authority for an OpenBao claim. The rejection
reason ("the lane does not cite Vault pages as evidence for OpenBao
behaviour… every behaviour this round needs is stated on the OpenBao page")
is the right bar, and the entry's Scope + "Does not establish" sections
enforce it both ways. Flip recorded: "a claim about Vault itself, measured on
a Vault binary." Agreeing is not automatic: had the round's five behaviours
been absent from S170, rejecting S172 would have left the claim unsourced and
the reject would have been wrong. They are all on S170 — checked, not assumed.

## The five `## Measured` statements

Each statement is either supported by S170/S171 text or explicitly marked as
measured-only (the clamp vs "Cannot be greater" split):

- **T1 root-internal** — S170-supported: "if it is `internal` the private key
  will not be returned and cannot be retrieved later" (5 occurrences across
  §Generate key / §Generate intermediate / §Generate root). The statement
  adds the exported-side control (`private_key` returned) which is the same
  sentence's first half. No measured-only overreach.
- **T2 ttl-clamp** — correctly split: the doc-sourced part is the bound
  ("Cannot be greater than the role's `max_ttl` value" — 3 occurrences in
  S170); the produced behaviour (issued, lifetime 3630 s, warning
  `TTL "24h0m0s" is longer than permitted maxTTL…`) is presented as a
  measurement ("is therefore enforced as a clamp, not a refusal") and flagged
  in the plan as measured, not sourced. This is the one statement where the
  doc alone would mislead (it reads as a refusal), and the entry says so
  explicitly. Compliant.
- **T3 domain-refuse** — S170-supported: `allowed_domains` "Specifies the
  domains this role is allowed" + the `allow_any_name` additivity ("When
  `allow_any_name` is used, this attribute has no effect"). The measured
  inside/outside control is the shipped trial's positive control, not an
  unsourced doc claim.
- **T4 revoke-crl** — S170-supported: "A successful revocation will rotate the
  CRL" (§Revoke certificate). The openssl-parsed CRL read is the shipped
  trial's measurement, stated as such.
- **T5 no-store** — S170-supported: "certificates issued in this way cannot be
  enumerated or revoked via serial number" (§Create/Update role, `no_store`).
  The "No value found" read and list-absence are the trial's measurement with
  a stored control.

No measured value is passed off as a doc quote, and no doc quote is silently
replaced by a measurement. The entry title/header ("clamps (not refuses)")
states the measured-only finding at the top, which is how the entry earns the
distinction rather than burying it.

## Census runs

| command | stdout | stderr | rc |
|---|---|---|---|
| `bash corpus/sources-census.sh` (lane) | `SOURCES_CAPTURES: CLEAN (path_rows=43 bound=43 located=43 prose=120)` + `SOURCES_CENSUS: CLEAN (rows=163 A=145 B=2 C=16 queued=3 mined=141 rejected=19 entries_sourced=29 legacy=21 captures=163 inrow=16 inrow_only=0 inrow_nonreproducing=12)` | empty | 0 |
| `/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` (fleet) | 26 `W04` lines + `kagi ok …/corpus/SOURCES.md` | empty | 0 |

Census exit codes confirm: the lane gate is CLEAN; the fleet validator's
`kagi ok` line is the passing verdict, and W04 are warnings that "do not
affect clean lanes" (fleet script header). The +1 W04 vs the round-start
baseline (25 → 26) is `kagi W04 S170 duplicate url openbao.org/docs/api/secret/pki across scopes`:
S105 (round-49 `generate_lease` scope) and S170 (round-70 lifecycle scope)
share the URL with different scopes, so the W04 fires by design — the same
class as the 25 pre-existing W04s (S019 duplicates S007's URL across scopes,
etc.). It is informational, not a gate failure, and the S105/S170 scopes are
genuinely different (one parameter vs the whole lifecycle). The plan's
§Routed-defects recorded that the round-start census's 25 W04 lines go to
stdout; this run reproduces that (stderr empty on both runs). Receipts at
`.ufo/waves/round-70/w1/R70ReviewerSrc/lane-census.{stdout,stderr}.txt`,
`fleet-validate.{stdout,stderr}.txt`, `.rc` files.

## Candidate bytes

`corpus/openbao-pki-trial.sh` is byte-identical to the P1 positive-control
fixture (`diff -q` identical; sha256 `200efcb2…8023d` both). S170's capture
sha256 `9fa76939…` also equals the round-49 S105 in-row pin (`9fa76939…`,
620683 B) — same page, same bytes, correctly re-captured rather than carried
forward by reference.

FINDING SR-1 falsifies-wording S172 used-by points to corpus/lessons/round-70.md, which does not yet exist on disk (tolerated by the gate per S156/S169 precedent; L1 writes it on integration).
FINDING SR-2 falsifies-number Fleet W04 count 25→26 (+1 S170 duplicate-url-across-scopes vs S105) is benign-by-contract (warnings do not affect clean lanes) but not mentioned in the plan's after-census line.
SEAT-STATUS: complete All three live re-opens byte-identical to captures and TSV rows; quotes located (2/1/2, all ≤25 words); 11-cell rows, mined/used-by triangles, tier A, gate decisions (admit/admit/reject) and the five Measured statements all verified; both census runs CLEAN/ok with receipts saved.
