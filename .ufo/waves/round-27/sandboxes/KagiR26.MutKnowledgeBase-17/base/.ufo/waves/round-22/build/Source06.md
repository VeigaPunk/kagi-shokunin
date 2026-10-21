# Source06 — S006 re-open and entry-claim adjudication

- Seat: KagiR22.Source06, scout, read-only, leaf (no dispatch).
- Axes: calibration (C1) and freshness (C2). No depth move, no source-registry edits, no host gates run.
- Report path: `.ufo/waves/round-22/build/Source06.md`.
- Frozen base: `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD at read; `git status` shows the
  round-22 working tree uncommitted and being edited by concurrent seats).

## Exact read revision

The working tree moved while this audit ran, so this is a named snapshot, not the integration tree.
All values below were read at **2026-10-20T21:40:34Z** unless stated:

| file | sha256 | lines | bytes |
|---|---|---|---|
| `corpus/SOURCES.md` | `ebf8864654b7cf1669ffb8944d7682cdefbea3234bca3adbbcb32157488f4de2` | 66 | 18222 |
| `corpus/knowledge/onepassword-machine-credentials.md` | `e885081e4d566af05080edde8e92de7692db4dc974b678b6020f2e30e68f96af` | 68 | 8328 |
| `corpus/lessons/round-22.md` | `64f562d78226580b408727984e4142cb15dd06cbac51c1cc79d5250933450e54` | — | — |
| `corpus/knowledge/feature-bound-credential-review.md` | `213b246eec59d8285f181e649895abe2bdf2c714b50c895d4e7c2e2b34bf49e5` | — | — |

`corpus/SOURCES.md` held 21 registry rows at that instant (S001–S021). Two intermediate reads during
the same audit produced `e4afe6d0…`/53 lines/20 rows and then `ebf88646…`/66 lines/21 rows, so the
parent must re-hash before integrating; do not treat the table above as the landing revision.

S006 was fetched five times between 21:33 and 21:35 UTC from
`https://1password.com/blog/1password-credential-broker-public-preview` with `curl -sL`: HTTP/2 200,
no redirect, 190261 bytes on every response, `content-type: text/html; charset=utf-8`,
`cf-cache-status: DYNAMIC`, no `ETag` and no `Last-Modified`. Page metadata:
`article:published_time = 2026-07-28T00:00:00.000Z`, `article:modified_time = 2026-07-28T00:00:00.000Z`;
visible byline “July 28, 2026”. Title/H1: “1Password Credential Broker is now in public preview”.

## Re-opened scoped teaching (accessed 2026-10-20)

All quotes are located, verbatim from the fetched text, and at most 25 words:

| # | quote | location | words |
|---|---|---|---|
| Q1 | “available for all Enterprise Password Manager Business customers” | introduction, immediately before the H2 “How 1Password Credential Broker works” | 8 |
| Q2 | “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” | §New in this release: Custom OIDC workflows | 19 |
| Q3 | “The workload can retrieve only the approved credential during the authorized job, without receiving standing access to the vault.” | §How 1Password Credential Broker works | 19 |
| Q4 | “unlike a service account token that carries standing access, the organization-wide integration key is an encryption key” | §How 1Password Credential Broker works | 17 |
| Q5 | “1Password Credential Broker is in public preview, and available now for all 1Password EPM Business customers.” | §Try 1Password Credential Broker today | 16 |

The quoted §Try heading and the §How-it-works heading both exist in the fetched page; the two anchors
named by the S006 row and by the round-21 erratum are present.

### Status / eligibility / product / path qualifiers

- **Status (announcement-time, 2026-07-28):** Credential Broker is “now in public preview” (H1), but
  the announcement itself splits the paths: GitHub Actions support is **public preview**; custom OIDC
  workflows are **beta** (“slowly rolling out a new capability in beta”, Q2). A blanket “Credential
  Broker public preview” is not supported for every path.
- **Eligibility:** Enterprise Password Manager (EPM) Business customers (Q1); §Try restates “available
  now for all 1Password EPM Business customers” (Q5). No other plan or deployment eligibility is stated
  on this page.
- **Product:** 1Password Credential Broker, part of the Unified Access Platform; the page distinguishes
  adjacent 1Password Privileged Access (formerly Apono). No conflation is licensed.
- **Path:** GitHub Actions is the first official integration; custom OIDC extends the trust model to
  any OIDC-capable platform (beta); further integrations and AI-agent controls are described as future
  work without a release status.
- **Temporal limit:** this is a July 28 announcement, not a live status page. It cannot establish
  post-announcement status; `article:modified_time` remains 2026-07-28. Current feature status must be
  read from the feature-specific pages (S017/S018 in the working tree; not re-opened by this seat).

## Comparison to associated entry claims

The associated entry is `corpus/knowledge/onepassword-machine-credentials.md` (E1), with its round-21
erratum and the in-flight round-22 erratum; the superseding registry row is S020.

1. **E1 item 4, first sentence — SUPPORTED.** “public preview … published 2026-07-28 … trust policy
   determines which credentials it may retrieve during the authorized job, without standing vault
   access.” Q3 supplies the no-standing-vault clause verbatim; the introduction supplies the preview
   status and Q1 the eligibility; the byline/meta supply the date. The paraphrase “determines which
   credentials it may retrieve” is faithful to “delivers only the specific credentials that job is
   approved to retrieve.”
2. **E1 item 4, feature status — OVERBROAD AS WRITTEN, corrected in flight.** The bold heading
   “Credential Broker public preview” and the round-21 erratum’s “custom-OIDC status unverified” are
   both contradicted by S006’s own Q2. The round-22 erratum’s per-path reading is correct, and its
   statement that “even the announcement has a feature-specific beta section” is exactly reproduced
   here. The correction does not depend only on S017/S018.
3. **E1 item 4, “says a valid OIDC identity is also needed to decrypt” — NOT LITERAL.** The fetched
   page contains zero occurrences of “decrypt”. It says a leaked integration key alone “is a dead
   end” and the attacker “would also need a valid OIDC token from GitHub, tied to a specific repo,
   branch, and workflow, that expires when the job ends.” “Needed to decrypt” is a reasonable
   mechanism inference from “encryption key”, but it is attributed to the announcement as if literal.
   Treat it as `[INFERENCE]` or use the source wording (“couldn't access your secrets” / “would also
   need a valid OIDC token”).
4. **E1 round-22 erratum, eligibility and split — ACCURATE.** Q1/Q2 support it. Q5 independently
   confirms the eligibility restatement in §Try.
5. **E1 round-22 erratum, “Workflow-duration delivery is not expiry of a Service Account token” —
   correctly bounded but under-cited.** S019/S020 do not establish the negative token-lifetime fact;
   S020 only supplies the contrast (“unlike a service account token that carries standing access”).
   The negative claim belongs with S001/S004 (the entry’s own §Does not establish already says so), or
   should be labelled a distinction/inference. This corroborates Source01’s note on the same sentence.
6. **Eligibility locator — I do NOT reproduce Entry15’s K1.** Entry15 calls the round-21 erratum’s
   locator false because the quoted sentence is in the introduction, not §Try. But the erratum says
   “S006 (introduction and §Try 1Password Credential Broker today)”, and §Try contains its own
   eligibility sentence (Q5). The verbatim quote Q1 is in the introduction; §Try is a parallel
   statement of the same eligibility. The two-anchor parenthetical is accurate for the eligibility
   claim. At most this is a precision note (“Q1 is in the introduction; §Try restates it”), not a
   false locator, and §Try must not be removed. This is a calibration decision against a peer’s
   high-severity finding.
7. **S020 row — substantively correct, evidentially incomplete.** Its scope (“EPM Business eligibility
   and announcement-time Actions preview versus custom-OIDC beta”) and its supersedes note are
   supported by Q1/Q2. But the row carries no `Quote:` and no fetch digest; the quote exists only in
   the round-22 lesson’s Gate table. The registry row is the pinned artifact, so the superseding row
   currently inherits the pin gap it was meant to close.
8. **Citation wiring.** S020’s `used-by` now includes `corpus/knowledge/feature-bound-credential-review.md`
   (the active review entry), which cites S020 on its `source:` line. E1’s body erratum also cites
   S017–S020, but E1’s `source:` header still lists only S001–S004, S006, S007. `SC_ENTRY_CITE` reads
   only the header `source:` line, so the body erratum is outside the gate’s machine coverage. This
   corroborates Source07’s wiring finding; it is a provenance gap, not currently a gate failure.

## Calibration decisions (C1)

These are source-bound decisions, not authored row counts; they are not claimed as outside agreement.

| # | proposition | decision | source-bound reason |
|---|---|---|---|
| D1 | At announcement time (2026-07-28), GitHub Actions support was public preview for EPM Business customers, while custom OIDC workflows were in beta. | **ADMIT (bounded)** | Q1 + Q2, both located; Q2 is the page’s own split. |
| D2 | “Credential Broker is public preview” without a path qualifier. | **REJECT** | Q2 contradicts uniform status; the page’s H1 is not a per-path status oracle. |
| D3 | “The custom-OIDC path’s release status is unverified.” | **REJECT** | Q2 states beta; the round-21 erratum’s unverified conclusion is refuted by the entry’s own cited source. |
| D4 | The integration key is an encryption key, not a standing Service Account token; a leaked key alone is a dead end because a valid job-scoped OIDC token is also required. | **ADMIT** | Q4 plus the adjacent “dead end”/“would also need a valid OIDC token” sentences; “dead end” is the page’s wording, not an inference. |
| D5 | S006 says a valid OIDC identity is needed “to decrypt”. | **REJECT as literal** | Zero “decrypt” occurrences; the page says “couldn't access your secrets” and “would also need a valid OIDC token”. Inference at best. |
| D6 | The round-21 eligibility locator is false because the quote is in the introduction, not §Try. | **REJECT (peer K1)** | The locator names both sections; §Try carries Q5. The quote’s exact home is the introduction, and the erratum names it. Precision note, not a false anchor. |

## Freshness and pin debt (C2)

### Measured pin instability and a usable replacement

- Five fetches of the registered URL returned **four distinct raw SHA-256 values** in five responses
  (one value repeated). The only byte difference between two consecutive responses was one
  `/cdn-cgi/l/email-protection#<hex>` `href` generated by Cloudflare; the `<hex>` key is per-response.
  This is the concrete cause of the S006 “drift” the outside verifier recorded at round 21 — not
  content change and not Next.js nonces/build data.
- Normalizing only that email-protection token makes all five responses byte-identical:
  full-HTML normalized sha256 `c9de8a8122bcfbf76e3e241e370178f601447817dcd1aad1cb8883d2f63adaa0`.
- A content-scoped pin is stable 5/5 and is the recommended replacement. Method: fetch with `curl -sL`;
  take the slice from the first `<h1` through the byte before the first subsequent `Continue Reading`;
  strip `<script>`/`<style>` and tags, HTML-unescape, collapse whitespace to single spaces, trim; hash
  the UTF-8 text. Result: **`bbfbd7ce87eeffd15938dd1074911c9e6db120729a105c6be141f372bb4c6c36`**
  (7547 chars; the slice is the article, excluding related posts and footer). This excludes the
  unrelated-chrome class of drift while still covering the whole article body.
- The registered S006 digest `39a869df8807696009d98bd6d0a86bc27524af65f94f235d37e6dd5a6e514c1f`
  is therefore **unreproduced / representation undocumented**, not a verified match and not evidence of
  content drift. It must be preserved verbatim in the immutable S006 row; do not restamp S006.
- The page also has no `ETag`/`Last-Modified`; `article:modified_time` (2026-07-28) is the only date
  hook, and it is unchanged. Do not infer current product status from it.

### Superseding row still lacks the pin

S020 has no quote and no digest (`NF=13`, but its teaches cell has neither). The quote is recoverable
from the round-22 Gate table; the digest is not recorded anywhere. Proposed replacement cell below
completes the row without touching S006. Because S020 is new and uncommitted at the frozen base, it is
not an “existing immutable row” and can be completed in place before landing. If the integration owner
treats it as already landed, a new S022 row carrying the same text is the alternative — do not rewrite
S020 after landing.

### Stamp / expectation migrations with exact old→new evidence

- `corpus/stamps.tsv:23` (`onepassword-machine-credentials.md`): old pin
  `7635be813a930c43c233f378f31d8d80f8feb0e599ba61ec05985785a9b69adb` / 35 lines / 6240 bytes matched
  the frozen base file exactly (`frozen/before/...` has the identical triple). After the in-flight
  round-22 erratum the file is `e885081e…` / 68 lines / 8328 bytes: +33 lines, +2088 bytes, 0 deletions.
  The stamp row is now stale because of an append, not a source change. Record old→new with the reason
  “round-22 append-only erratum”, and keep the old value as history; do not silently restamp and do not
  delete the row.
- `corpus/stamps.tsv:54` (`SOURCES.md`): old pin
  `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` / 43 lines / 14261 bytes / 16
  rows. Current snapshot: `ebf88646…` / 66 lines / 18222 bytes / 21 rows (S017–S021 added): +23 lines,
  +3961 bytes, +5 rows. The `R21-02` 16-row and frozen `expected_source_rows: 16` expectations need a
  QM14 migration to the new count; that is an expectation change, not a re-verification of S006.
- Both deltas are append-only and must be expressed as migrations, not as “the hash now matches”.
  A fresh hash does not make the 2026-07-28 announcement current.

### Recheck-surface migration

E1’s header still says `recheck: 90d for S001–S004; on-release for S006–S007` without naming an
observable surface. The round-22 erratum adds a trigger that names the two feature pages, which is the
right migration; the header can remain historic. If the header is migrated, do it as a separate reviewed
change with old→new text, and name: S017 GitHub Actions title/introduction, S018 custom-workflow
title/Steps 1 and 3, S019 introduction/GitHub requirements, S020 introduction/§New in this release,
plus the 90d floor (due 2027-01-17). Never make digest equality the verdict.

## Proposed exact corrections (integration owner; not applied here)

1. **S020 `teaches` cell** (replace only that cell; keep the current id/source/kind/tier/scope/anchor,
   status `mined`, opened `2026-10-20`, recheck `on-release`, and current `used-by`):

   `Supersedes S006: eligibility and feature split. Quotes: “available for all Enterprise Password Manager Business customers” (introduction); “Alongside GitHub Actions support in public preview, we're slowly rolling out a new capability in beta: custom OIDC workflows.” (§New in this release). Content sha256: `bbfbd7ce87eeffd15938dd1074911c9e6db120729a105c6be141f372bb4c6c36` (H1→pre-“Continue Reading” text, tags stripped and whitespace collapsed; 5/5 fetches stable 2026-10-20; raw HTML is per-response unstable via a Cloudflare email-protection token).`

   Also add `article:modified_time 2026-07-28` to the anchor if the anchor cell is being completed.
2. **E1 round-22 erratum — append only** (do not rewrite the base or the round-21 erratum):
   - “Locator precision: the verbatim eligibility sentence is in the announcement introduction; §Try
     Credential Broker today restates it as ‘available now for all 1Password EPM Business customers.’
     Both anchors named above carry the eligibility claim.”
   - “Wording: ‘needed to decrypt’ is an inference, not an S006 sentence; the page never says ‘decrypt’.
     S006 says a leaked integration key alone is ‘a dead end’ and the attacker ‘would also need a valid
     OIDC token.’”
   - “The S006/S020 fetch digest is a point observation; raw HTML varies per response. The operative
     content pin is the article-body sha256 above with its stated extraction method, and the 90d/feature-
     page recheck, not digest equality.”
3. **Citation wiring (optional, machine coverage):** if E1 is to be gate-covered for the new citations,
   append S017–S020 to E1’s `source:` line and add `corpus/knowledge/onepassword-machine-credentials.md`
   to S017–S020’s `used-by`. Otherwise record that the active review entry is the registered consumer;
   the current gate passes either way because it reads only the header `source:` line.
4. **Do not edit** S006’s immutable cells, delete the S005/S006 drift record, or rewrite the historic
   `39a869df…` value. The correction is a superseding row plus a migration record.

## Falsifier

S020’s teaching is falsified if the announcement no longer carries the public-preview title/status, no
longer contains Q1 or Q2 at those anchors, or changes the EPM Business eligibility; it is also falsified
if a feature-specific page changes the per-path status or eligibility (S017/S018/S019, outside this
re-open). The proposed content pin is falsified if a later fetch under the stated method yields a
different body digest (content change) or no longer yields a stable digest across consecutive fetches
(method invalid). The E1 bounded reading is falsified by the same feature-page changes.

## Limits

- Only S006 was re-opened here. S007, S017, S018 and S019 were not re-opened by this seat; their
  current-status claims are taken from the working tree and must stand on their own opens.
- No JavaScript executed; the page was read as fetched HTML/text. No account, workflow, SDK, vault or
  credential was touched.
- The raw-pin fetch environment for 2026-10-19 (UA, headers, exact time, serialization) was not
  recorded, so `39a869df…` cannot be reproduced even in principle; this report does not claim either a
  content change or a byte match.
- The working tree changed during the audit. The hashes in §Exact read revision are the read snapshot;
  re-hash before integrating. This report does not adjudicate the nine-stamp ledger history beyond the
  S006/S020-affected files.

## Checks the parent should run after integration

- `bash corpus/sources-census.sh` → expect `SOURCES_CENSUS: CLEAN`; confirm S020/S021 row shape and
  `used-by` resolution after the final edits.
- `bash corpus/sources-census.sh --selftest` → exit 0.
- Re-run the S006 body-digest method once at integration; expect `bbfbd7ce…` and note the access date.
- Verify `corpus/stamps.tsv` rows 23 and 54 carry a QM14 old→new migration record (or are explicitly
  recorded as pending), and that the `rows=16` expectation is migrated to the final count, not silently
  edited.
- `git diff --check` on the integrated tree.
- No builds, lint, tests or formatters were run by this seat.

## Report trailer

Relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`: report written at
`.ufo/waves/round-22/build/Source06.md`. Read revision: frozen base
`c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD), working tree snapshot at 2026-10-20T21:40:34Z with
the hashes table above. S006 accessed 2026-10-20. No production file, source registry, stamp file,
ledger, lane state, host configuration, account or vault was modified.
