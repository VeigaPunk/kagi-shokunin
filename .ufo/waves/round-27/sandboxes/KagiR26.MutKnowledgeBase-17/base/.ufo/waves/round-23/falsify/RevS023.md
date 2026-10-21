# RevS023 — round-23 falsification (S023 provenance, C1/C2/C3 re-measurement)

Seat: `RevS023` (falsification, leaf). Read-only review: no lane edits, no installs, no
host gates, no credential reads; scratch only under `/tmp/revs023`. The parent's 43-row
ledger audit was not re-run.

Measured tree: HEAD `def9bc2e12534ae2c2492bae1034eb8122c2c179`
("round-23: lead disposition, frontier/correction row wording", 2026-10-21T01:11:47-03:00),
clean at HEAD, base `d218603b74099ddca0bd8f869516fc41db0979bf`; `corpus/lessons/round-23.md`
and `corpus/stamps.tsv` carried uncommitted wording edits at measurement (re-checked against
the working tree; they do not affect the findings). The lane was edited
concurrently during this review (commits `e1884c6` → `ea5b734` → `b55e0e7` → `7af07b4` →
`284d40e` → `638d44c` → `def9bc2e`); the findings below were re-measured on the final HEAD.
Pinned review inputs (sha256):

| file | sha256 |
|---|---|
| `corpus/sources-census.sh` | `511deb2730614663c86beb9b6793b54eea75ce8a9dbe4f1cf372999697339b58` |
| `corpus/source-fetches.tsv` | `6e26e14032729070f38b5e0cb90914385f04c0ef9f4fe1db210af6439191094d` |
| `corpus/lessons/round-23.md` | `93df7d345554b99c1daf87fb75234ba273cff0d2fc8be691a4d5df56f0242cb4` |
| `corpus/closure-dispositions.py` | `cfa2c46ae0730730722b62c7078c38b138fc17ac9876ba15e26eff53cdf71de7` |
| `corpus/closure-dispositions.json` | `00fbf48d3ea233d01a7d56ae6ca3291955df82ea522a91e3f3d7dc5644c535e8` |
| `LOG.md` | `57dc73966c6f9e56dcd83b035ca851054ee80fe512866de5607039d1486ef43f` |
| `corpus/SOURCES.md` | `c6ea91ab2468352263a7442a2ff7815084d68374c94433bbb6b4cccc639c632d` |

## Verdict

**S023 is not falsified.** Every declared scalar in `corpus/source-fetches.tsv:44`
reproduces from a fresh fetch: URL, final URL, HTTP 200, decoded byte count, raw digest,
row-identity digest, `rendered-text-v1` normalized digest, declared quote, declared
location, and the row's KV-note/version-route content. No wrong digest and no stale-date
defect were found under the TSV's own `fetched` definition (`corpus/source-fetches.tsv:14`).

C1 and C3 reproduce exactly. C2's named gate reproduces CLEAN/59. Three low-severity
residuals remain (F1–F3); two contradictions found during the review were fixed before the
final HEAD (F4, F5). The parent brief carries three stale numbers (last section).

## S023 independent re-measurement

Command (declared profile, `corpus/source-fetches.tsv:16-17`):

```
curl -fsSL --compressed \
  -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -D headers.txt -o body.html \
  -w '%{url_effective}\t%{http_code}\t%{size_download}\t%{content_type}\n' \
  'https://developer.hashicorp.com/vault/docs/concepts/lease'
# exit 0
# https://developer.hashicorp.com/vault/docs/concepts/lease  200  40416  text/html; charset=utf-8
```

`%{size_download}` = 40416 is the still-compressed wire body (`content-encoding: br`);
the declared representation is the decoded body (`decoded-http-body-volatile-v1`), whose
size is 261632.

| field | declared (`source-fetches.tsv:44`) | re-measured | result |
|---|---|---|---|
| `url` | `https://developer.hashicorp.com/vault/docs/concepts/lease` | same; equals the URL in `corpus/SOURCES.md:29` | match |
| `final_url` | same string | `%{url_effective}` same (no redirect) | match |
| `http_status` | `200` | `200` | match |
| `bytes` | `261632` | `wc -c body.html` = `261632` | match |
| `sha256` (decoded body) | `de5f8836b268372b5af165fa46d3c80195554f110f881723d606c6cc8bcc3802` | `sha256sum body.html` = same, exit 0 | match |
| `row_identity_sha256` | `131e6a2015a202cebc9305a0943b4d62d66de343bfc97e2211ad7fc66cfed5b2` | `printf 'S023\tmined\t<url>\n' \| sha256sum` = same | match |
| `normalized_sha256` | `0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76` | same (script below), normalized length 7354 chars | match |
| `quote` | `All dynamic secrets in Vault are required to have a lease.` | present exactly once at normalized offset 3808 | located |
| `location` | `Lease, renew, and revoke` | H1 at 3134; next H2 `Lease IDs` at 4804; quote between them | located |
| `fetched` | `2026-10-21` | local fetch date 2026-10-21 (response `date` 2026-10-20 17:04:06 GMT, `age: 39208`) | date semantics match `source-fetches.tsv:14` |

Normalization re-computation (`rendered-text-v1`: strip `script`/`style`, tags → single
space, `html.unescape`, collapse whitespace, trim, UTF-8):

```
python3 - <<'PY'
import re, html, hashlib
s = open('/tmp/revs023/body.html', encoding='utf-8').read()
t = re.sub(r'(?is)<script\b.*?</script\s*>', ' ', s)
t = re.sub(r'(?is)<style\b.*?</style\s*>', ' ', t)
t = re.sub(r'(?s)<[^>]+>', ' ', t)
t = html.unescape(t)
t = re.sub(r'\s+', ' ', t).strip()
print(hashlib.sha256(t.encode('utf-8')).hexdigest(), len(t))
PY
# 0e62e05612eaa7ddb5145fb8d17618f37a503b20c5ee58b46ab3476d8a4e7b76 7354
```

Content checks beyond the gate (all positive):

- The row's "static KV no-lease note" is supported by the visible text:
  `Note : The Key Value Backend which stores arbitrary secrets does not issue leases
  although it will sometimes return a lease duration` (normalized offset 4637, still under
  the H1, before the first H2 at 4804).
- The row's "served version-route locator" is supported: the visible edit anchor is
  `https://github.com/hashicorp/web-unified-docs/blob/main/content/vault/v2.x/content/docs/concepts/lease.mdx`
  (one occurrence in the anchor plus one in the `githubFileUrl`).
- Headers recorded: `content-encoding: br`, `etag: W/"mhehieftta5lvi"`,
  `x-vercel-cache: HIT`, `age: 39208`, `set-cookie: hc_geo=...`. The volatile label is
  honest. Caveat: equality is same-cache-generation, not an origin regeneration.

## Findings (current HEAD)

### F1 — Low: `fetch-disagree` is now a duplicate of `fetch-duplicate`, not a disagreement test

`638d44c` removed the cross-capture equality rule but left the selftest case. Current
`sources-census.sh`:

- `m_fetch_duplicate` (`:422-425`) copies the S002 row, producing `duplicate-provenance`.
- `m_fetch_disagree` (`:426-430`) appends the S002 row with `$10` (raw digest) changed;
  with the same-URL check gone, the only finding is again `duplicate-provenance` — the
  changed digest is never inspected. The two cases (`:552-553`) now exercise the same
  check and expect the same count (1).
- The harness asserts only the finding class and count (`:576-592`: `grep -q "^FINDING
  $xid "` plus `findings=$xn`), so it cannot distinguish the two cases.

Impact: the "12 SC_FETCH cases" / "59 cases" counts are numerically true
(`SOURCES_CENSUS_SELFTEST: PASS (59 cases)`) but one case is vacuous and the name is
misleading. `fetch-duplicate` already covers duplicate ids; either delete
`fetch-disagree`/`m_fetch_disagree` or repurpose it to a live check (e.g. the row-identity
digest or representation branch).

### F2 — Low: dead `FDIG`/`FNRM` declarations remain after the rule removal

`sources-census.sh:229` still declares `FDIG=() FNRM=()`; no code reads or writes them
after `638d44c` (`grep FDIG\|FNRM` returns only line 229). No behavior change, but it is
dead weight and suggests the removal was incomplete. Delete the two arrays with the
removed rule.

### F3 — Low: the five W04 warnings are attributed to the lane census but are not produced by it

`corpus/lessons/round-23.md:66` says "The census prints five W04 duplicate-URL warnings",
and `:178-179` says "Census at round start: exit 0 with five W04 warnings". The named C2
command, `bash corpus/sources-census.sh`, emits **zero** findings and has no `W04` string
(`grep -c W04 corpus/sources-census.sh` → `0`; verify output is only the CLEAN line).
`command -v kagi` → absent. The round-22 record attributes those lines to
`kagi ok …/corpus/SOURCES.md`, not to this gate
(`corpus/lessons/round-22-verifier-spotcheck.md:115`). The defect is the attribution and
the unverified quotation; the gate result itself is clean. `LOG.md:1206` repeats the
shorthand.

## Resolved during the review (not current defects, recorded for the verdict)

### F4 — Cross-capture equality contradiction (fixed in `638d44c`)

At `ea5b734`–`284d40e` the committed census enforced same-URL equality (`FDIG`/`FNRM`,
`same-url-digest-disagreement` / `same-url-normalized-disagreement`) while the committed
census header (then `:64-66`), `corpus/source-fetches.tsv:21-22`, and
`corpus/lessons/round-23.md:50-54` all said "no cross-capture equality is enforced"; the
lesson itself records that S017/S023 normalized digests moved between days
(`round-23.md:193`). Reproduction at sha `6d4190a7…` on a `/tmp` copy (S026 normalized
digest changed to simulate honest chrome drift): exit 1,
`FINDING SC_FETCH id=S026 same-url-normalized-disagreement url=https://openbao.org/docs/concepts/tokens/`,
`SOURCES_CENSUS: FAILED (findings=1 rows=26)`. `638d44c` removed the enforcing code; the same
`/tmp` drift copy now exits 0 CLEAN, and the lesson's M23-1 records the rule as a mistake
(`round-23.md:146`). Residual: F1/F2 above.

### F5 — Unbound `SUPERSEDED` gate crash (fixed at 01:02:21, before `638d44c`)

At sha `80966e208321348aad0ae6dd5b65987bccc4901e99fcba9f94feedd150228781`
(mtime 00:57:55), `bash corpus/sources-census.sh` exited **1** with
`corpus/sources-census.sh: line 242: S007: unbound variable` and **no verdict line**
(no `FINDING` output either). The then-line 242 executed `SUPERSEDED[$fid]=1`, but
`SUPERSEDED` was missing from the `declare -A FURL=() FINROW=() FSEEN=() FDIG=() FNRM=()`
at line 229; under `set -uo pipefail` (line 107) and bash 5.3.20, assignment to an
undeclared associative array aborts with that message. The 59-case selftest stayed green
because the base fixture rows (`sources-census.sh:360-363` at that sha) have no
`supersedes S…` teaches cell, so the loop never ran in the selftest. The dead loop was
deleted at 01:02:21; current HEAD exits 0. Process note: the `LOG.md` verdict recorded at
00:54:08 predated the breaking edit, so the named gate must be re-run after the last edit
and the measured commit/sha pinned in the verdict (the final commit is clean).

## C1 / C2 / C3 final measurements

C1 (`python3 corpus/closure-dispositions.py`, exit 0):

```
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
CLOSURE_DISPOSITIONS_SELFTEST: PASS (14 cases)
```

15 disposition rows, 15 unique ids (9 routed + 5 spot + 1 adjudication); declared
`source_sha256` equals the actual sha256 of
`corpus/lessons/round-22-verifier-spotcheck.md`
(`65a5b3dee667146c47c158d344dad7c2a9307d6997a0a9800d92b7dbb55869f7`). Pointers are
presence-only by design: D7 points at the TSV it certifies (`source-fetches.tsv:2`) and
D9's token is an HTML comment inside the fixture it certifies
(`corpus/fixtures/cells-hermetic/SCORECARD.md:1`). That is the disclosed presence-only
bound (`round-23.md:182-190`), not a gate defect.

C3 (exact `R23-01` command from `corpus/claim-ledger.tsv:59`), exit 0:

```
CELL_AUDIT: CLEAN (cells=6 row_pointed=6 stamp_pointed=1 uncited=0 missing_ids=0 rows_run=2 row_deferred=0 row_failures=0 stale_pointers=0 self_skipped=0 orphans=0)
```

The line matches the ledger regex exactly. Fixture: 5 files, 2 claims rows, 2 stamps. Rows
run with `cd "$ROOT"` (`corpus/claim-ledger.sh:426`); the fixture root has its own
`corpus/adjacency.tsv` and `corpus/fx-ok.sh`, so the run is hermetic. Mutation tests on
`/tmp` copies fail as claimed: uncited cell (`R90-01` → `R90-99`) gives exit 1,
`CELL_AUDIT: BROKEN (... uncited=2 missing_ids=3 ...)`; failing row (`^FX: OK$` → `^FX: NO$`)
gives exit 1, `row_failures=1`.

C2 (final tree): 26 registry rows, 16 in-row `Fetch sha256:` pins, 10 provenance rows,
**9** distinct provenance URLs. `bash corpus/sources-census.sh` exits 0 with
`SOURCES_CENSUS: CLEAN (rows=26 A=24 B=0 C=2 queued=1 mined=24 rejected=1 entries_sourced=4 legacy=21)`
and 0 findings; `--selftest` exits 0 with `PASS (59 cases)`, 12 `fetch-*` cases.

## Parent-brief drifts (do not repeat these in the final report)

1. **"10 declared captures S017–S026 over 7 URLs."** The final artifacts say **nine**:
   `round-23.md:175`, `LOG.md:1202`, `SCORECARD.md:840`; measured distinct `url` values =
   9. Seven was true only for S017–S023 (7 rows, 7 URLs); S024–S026 add two distinct URLs
   and one duplicate (S026 = S021's OpenBao tokens URL).
2. **C1 "selftest 13."** The final gate reports `PASS (14 cases)` and `round-23.md:60`
   says 14; the 14th case is the `pointer-symlink` escape regression
   (`closure-dispositions.py:314,328`).
3. **"the located quote."** The final artifacts now claim less: the TSV defines `quote`
   as "declared quote, shape-checked only: <=25 ASCII words, not verified against the page
   bytes or the location" (`source-fetches.tsv:25-26`), and the lesson D7 says the same
   (`round-23.md:108`). This review independently located S023's quote (above), but the
   gate does not locate any row's quote. Do not describe `SC_FETCH` as verifying location.
4. **"same-URL agreement"** was removed in `638d44c`; if the parent's brief still lists it
   as a C2 feature, that is stale (the lesson M23-1 records the removal).

## Residual risk and verification gaps

- The S023 raw body came from the same Vercel cache generation (`x-vercel-cache: HIT`,
  `age: 39208`, weak ETag). Equality proves the declared representation existed at that URL
  under the declared profile, not an origin regeneration; the `volatile` label covers this.
- The gate does not locate quotes or locations; the S023 location was independently checked
  here, no other row was re-located. `round-23.md:191-193` states this bound.
- C1 pointer resolution is presence-only by design; no fix content was judged.
- `kagi` is absent, so the five W04 lines (F3) remain unverified here.
- The lane was edited concurrently; every statement above is tied to the pinned shas. If
  the tree advances, re-pin HEAD and re-run the three named gates before quoting verdicts.
- Lane hygiene: only `.ufo/waves/round-23/falsify/RevS023.md` was written; no lane file was
  modified, no install was performed, scratch lives under `/tmp/revs023`.
