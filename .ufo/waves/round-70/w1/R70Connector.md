Author: R70Connector (connector)

# R70Connector — sibling-overlap scan for the new PKI ground (kagi round 70, attempt 1)

Seat: section-8 adversary (connector), read-only. Claim under scan: C1 coverage —
`C1_PKI_TRIAL: value = number of tests T in {T1..T5} that DISCRIMINATE, when PINS = 1 and
SETUP_OK = 1 and NOSECRET = 1 and NOLEAK = 1 and SOURCED = 1, else 0; target 5 (BASE 0).`
Nothing frozen was edited; no git/jj mutation; no bao server started; no sibling lane written.

## Axes named

1. **coverage** — C1's five discriminating tests (the round's declared move).
2. **calibration/record** — the axis rounds 68 and 69 were rejected on: whether a sentence the
   lane writes about its own prior state survives contact with its own registry.
3. **sourcing** — QA1/QA6 (`corpus/QUALITY.md`): every claim carries a tier-A row, an anchor, and
   a count carries its command; a negative claim carries its sweep.
4. **lane fit** — QA7: "the ground is secrets & vault ops and no sibling lane's `PROVINCE.md` or
   corpus claims it; contested ground is reported, not absorbed."

## Method (read-only; receipts in `.ufo/waves/round-70/w1/R70Connector/`)

Surfaces searched in **all 21 `*-shokunin` lanes**: `PROVINCE.md` (21 present), `SKILL.md`
(19 present), `corpus/README.md` (21 present), and every file under `corpus/knowledge/` (21
lanes). Commands and full output: `pki-sweep.txt` (108 matched lines in a 112-line receipt) and
`url-registration.txt` (URL registration + capture identity + registry cells + round-49 PKI
callsites). Terms: `PKI`, `X.509`, `CRL`, `OCSP`, `ACME`, `cert-manager`, `step-ca`,
`Let's Encrypt`, `certificate authority`, `certificate`, plus the PKI engine field names
`allow_any_name|allowed_domains|max_ttl|no_store|root/generate|pki/revoke|pki/cert` swept over
the whole fleet (all file types, `reports/`, `census/`, `.ufo/` and `node_modules` excluded).

## 1. Sibling table — every hit that is not a named false positive

| lane | path:line | term | class |
|---|---|---|---|
| kake | `corpus/knowledge/render-static-sites.md:6` | `custom domains and TLS` (coverage line) | **complement** — platform-issued TLS on a hosting service, consumer side |
| kake | `corpus/knowledge/render-static-sites.md:55-66` | TLS cert issuance/renewal, Let's Encrypt + Google Trust Services, CAA records | **complement** |
| kake | `corpus/knowledge/render-static-sites.md:118-122` | GitHub Pages issuer/renewal absence | **complement** |
| kake | `PROVINCE.md:106` | "dashboard response headers, custom domains and TLS. It is knowledge only" | **complement** — the only written TLS claim in the fleet; consumer side |
| kaidoku | `corpus/SOURCES.md:171` (S254) | RFC 6962, Certificate Transparency | **complement** — transparency logging, not issuance |
| kasegi | `PROVINCE.md:48` | "kagi — secrets and vault handling" | partition affirmation (kagi is named owner) |
| kasegi | `corpus/source-snapshots/round-41/S063.txt:587,595,764,769-770` | X.509 handshake validation, OCSP RFC 6960 | **complement** — an RFC snapshot, not a held entry |
| chousa | `corpus/knowledge/quote-reopen-r30.md:48` | "TLS keeps SNI and the certificate host check (S055)" | **complement** — client-side hostname verification |
| tsukuroi | `corpus/knowledge/pause-lift-gate-r24.md:23,64`; `host-health-report-r3.md:667`; `update-safety-note.md:544` | `ca-certificates-mozilla` | **complement** — OS trust-store package state |
| kagi | `corpus/knowledge/openbao-pki-certificate-lifecycle.md:1-52` | PKI / CRL / `no_store` | the new entry (subject of the scan) |
| kagi | `corpus/SOURCES.md:112` (S105) | OpenBao PKI secrets engine (API), **same URL as S170** | **duplicate of kagi's new entry** — see §4 |
| kagi | `PROVINCE.md:94` | "the round-49 PKI role row" | pre-existing mention inside the round-49 token bullet |

**Named false positives** (listed so the 112-line sweep is reproducible and the count is not
inflated): `game-dev-2d-shokunin/corpus/fixtures/export_prod_s10.gd:160` (`_fail("export:no_store")`
— a Godot export log label); `kotodama-shokunin/SKILL.md:707-732` (`accept-ca-66…72` gate names);
`kotodama-shokunin/corpus/SOURCES.md:536` (`ACME: An International E-Journal`, a journal title);
`kasegi-shokunin/corpus/source-snapshots/round-38/S055.txt:2101` (`ACME Inc.` as a CSAF example
company); `revenger-shokunin/corpus/snapshots/APPNOTE.TXT:1130-1133,1365` (ZIP APPNOTE PKCS#7/X.509
field names); `mori-shokunin/corpus/evidence/sources-r100/S221-rfc9110-r100.txt:9401,9416` and
`chousa-shokunin/corpus/captures/b1b13a12aee75c6ecc20fb91.txt:16622,16634` (RFC back-matter
bibliographies); the wide `certificate` class in `kake`/`tameshi`/`tsukuroi`/`chousa`/`kaidoku`
`SKILL.md`/`corpus/README.md` lines, where "certificate" is the fleet's *evidence certificate*
vocabulary (uniform with `SEAT-STATUS`/`gate certificate` prose), not X.509.

## 2. URL registration check — the seat's specific question

Command (in `url-registration.txt` §A): `grep -rnI -E 'openbao\.org/(docs/(api/secret|secrets)/pki|api-docs/secret/pki)' --include=*.md --include=*.tsv` over the fleet, excluding the
kagi lane and `.git/.jj/.ufo/node_modules`.

**Result: 0 sibling hits for both URLs.** No sibling `SOURCES.md`, `PROVINCE.md`, `SKILL.md`,
`corpus/README.md` or `corpus/knowledge/` file registers S170's or S171's page, under any id.
The only rows in the whole fleet carrying either URL are kagi's own: `SOURCES.md:112` (S105),
`:170` (S170) for the API page, `:171` (S171) for the overview.

Per-lane id namespaces are independent, so the nine siblings that also use ids `S170`/`S171`
(chousa, kama, kengaku, kotodama, mado, mori, revenger, tabi, tsukuroi — each on unrelated
material) are **not** collisions. The consequence is only that a bare "S170" is fleet-ambiguous
and must stay lane-qualified; all kagi prose already does.

## 3. What the sibling sweep actually establishes

For QA7 the lane needs "no sibling `PROVINCE.md` **or corpus** claims it". Measured:

- **PKI engine mechanics** (role `max_ttl`/`allowed_domains`/`allow_any_name`/`no_store`,
  `root/generate/{internal,exported}`, `pki/revoke`, CRL, `pki/cert/<serial>`): **0 registry rows
  and 0 knowledge-entry claims fleet-wide.** The field-name sweep returns only the Godot
  false positive. Unclaimed ground.
- **Certificate issuance as a host capability** (ACME, cert-manager, step-ca): **0 hits
  fleet-wide** outside the named false positives.
- **The consumption side is claimed**, by kake: `PROVINCE.md:106` plus
  `corpus/knowledge/render-static-sites.md:55-66` hold "certificates are issued and renewed
  automatically", the issuer names, and the CAA requirement — for a *published site on a
  platform*. That is a different object from a self-hosted CA engine's role bounds, and kagi's
  entry keeps clear of it: §Does not establish excludes ACME, OCSP responses, delta CRLs and
  "that a client honours the CRL" (`openbao-pki-certificate-lifecycle.md:48-52`).
- **Adjacent-but-distinct**: trust-store package state (tsukuroi), transparency logging
  (kaidoku S254 = RFC 6962), client-side SNI/hostname verification (chousa
  `quote-reopen-r30.md:48`), certificate-shaped fields inside container formats (revenger).

**Adjacency verdict for kagi's PROVINCE:** *not contested.* The new ground is unclaimed, the
nearest neighbour (kake) is a consumer-side complement that the entry's own exclusions already
respect, and kasegi's province file independently names kagi as the secrets/vault owner. No
absorption is required and none is visible. The only gap is documentary: `PROVINCE.md` carries no
sentence recording the kake boundary, so the next fleet-wide sweep must re-derive it (CN-3).

## 4. The duplicate is in-lane, not sibling — and it is byte-exact (CN-1)

`SOURCES.md:112` (S105) and `SOURCES.md:170` (S170) are the **same URL**,
`https://openbao.org/docs/api/secret/pki/`, with the **same raw digest**
`9fa7693967f32958aff9c96faf5835afa4d72894727a8d63c324e9145e5c1123` at **620683 B**, opened
2026-11-06 and 2026-11-08 respectively. The captures are literally the same file:

```
9fa76939…5e5c1123  .ufo/waves/round-49/capture/S105.body   (620683 B)
9fa76939…5e5c1123  .ufo/waves/round-70/capture/S170.body   (620683 B)
cmp …  →  IDENTICAL
```

(`url-registration.txt` §D; round-49's own build note at
`.ufo/waves/round-49/build/K49ExecSources/rows-proposed.md:33` already recorded two captures
minutes apart as byte-identical.)

So the round did not open a new page — it re-downloaded the page the lane has mined since round 49,
and registered it a second time under a new id whose `teaches` cell restates a wider scope over
identical bytes.

**This falsifies the frozen plan's pre-move sentence as written**
(`plans/round-70.md`, §C1 first paragraph):

> "Before this round the lane holds no knowledge entry, trial, source row or capability for the
> OpenBao PKI secrets engine (X.509 certificate issuance, TTL bounds, name constraints,
> revocation/CRL, `no_store`)."

- "no … **source row** … for the OpenBao PKI secrets engine" — **false**: S105 is exactly that
  page, status `mined`, tier A.
- "no … **capability**" — overstated: `corpus/openbao-token-trial.sh:146-154` already enables
  `pki`, sets `max-lease-ttl`, calls `pki/root/generate/internal`, creates a role with
  `allowed_domains`/`allow_subdomains`/`max_ttl=30m` and issues `pki/issue/trial`. T1's and
  T2/T3's *callsites* have run since round 49. (Weaker leg — the round-49 use reaches the calls
  but asserts nothing about the bounds, issues no outside name, never revokes and never sets
  `no_store`. The finding does not need this leg.)
- "no knowledge **entry**" — **true**. "no **trial**" — true in the sense of a PKI-purpose trial.
- The claim's *predicate* is untouched: the counter on BASE still reads `value=0 absent=1`, and
  the five mechanics (`max_ttl` clamp-vs-refuse, outside-name refusal, CRL membership, `no_store`
  invisibility) have never been asserted by any kagi artifact.

Nothing here is editable: the plan and counter are frozen. The lane's own rule
(`corpus/README.md:148`, `corpus/knowledge/record-supersession.md`) is that a correction
**supersedes** and never **rewrites** — it quotes the superseded sentence verbatim and names the
receipt that supersedes it. That is what the move below lands.

## 5. Proposal — one bounded move

**Declare S170 a byte-bound re-capture of S105 and land the supersession of the pre-move
sentence, in one record.** It improves *calibration/record* and *sourcing* (the two axes the last
two rounds lost on) without touching *coverage*.

Evidence (all re-runnable, `url-registration.txt`):
`SOURCES.md:112` and `:170` carry one URL and one digest; the two captures are `cmp`-identical;
round-49's build note records the same page as byte-stable.

Edits — a triad, because the census gate is bidirectional:

1. `corpus/SOURCES.md` S105 `used-by` gains
   `corpus/knowledge/openbao-pki-certificate-lifecycle.md` (comma-appended to its existing two
   paths). **Required**: `corpus/sources-census.sh:640` raises `SC_ENTRY_CITE … used-by-omits-entry`
   if a `source:` id is not listed by that row.
2. The entry's `source:` line names **S105 as well as S170**, with the roles split — S105: the
   `generate_lease` role row (round 49) and the identical bytes; S170: the same page re-opened
   2026-11-08 for the five mechanics. The frozen `sourced` leg is unaffected: the current line
   already matches `^source:.*S170([^0-9]|$)` (tested, `MATCHES`), and adding `S105` earlier on
   the line cannot break it.
3. S170's `teaches`/scope cell states the identity explicitly — "same page and bytes as S105
   (raw sha256 `9fa769…`, 620683 B): a **re-capture**, not an independent source".
   **Do not merge or delete S170**: `plans/round-70-c1.sh:133-136` requires a
   `^ {0,3}\| *S170 *\|` row whose column 9 reads `mined`.

Plus one supersession line quoting the pre-move sentence verbatim, in the round report and in
`corpus/lessons/round-70.md` §Gate, citing the `cmp` receipt above. That is a record edit, not a
plan edit.

Affected axes: calibration/record ↑ (a frozen sentence is superseded with a receipt instead of
standing false), sourcing ↑ (one page counted once, with its two roles named), coverage unchanged
(counter legs byte-identical in behaviour; `value=5` still depends only on the trial and the
entry's `## Measured (round 70` lines).

## 6. Risks and second-order effects

1. **Census handshake is bidirectional** — edit 2 without edit 1 fails `sources-census.sh`
   (`SC_ENTRY_CITE`). The triad must land atomically.
2. **Do not let the fix read as "S170 is not a source"** — it is a source row; it is a re-capture,
   not an independent corroboration. The wording distinction is the whole value.
3. **`SC_DUP` will not catch this class**: the census's duplicate rule is *id*-only
   (`corpus/sources-census.sh:32`, awk duplicate scan over ids at `:452`). A duplicate URL/digest
   is legal to the gate, so the record is the only place this can be held.
4. **`README.md:67` is a bound number** — "46 row-linked / 3 by-hand / 49 pinned (round 69...)",
   bound by `corpus/self-counts.tsv:55` (`RD-DOCS-ENTRIES`) to `ledger:R14-01`'s
   `entries=([0-9]+)`. The tree now has **50** files carrying `^Reverify:` (the +1 is exactly the
   new entry). Whichever counting rule R14-01 implements, the number and R14-01 must be
   **re-derived** (`claim-ledger.sh docs`) in the same landing — never hand-incremented to a
   guess. Two entries also still lack a README index row
   (`claim-instrument-class-matrix.md`, and the new entry), which is pre-existing practice, not a
   new defect.
5. **No axis harm**: nothing in the move touches `plans/round-70-c1.sh`, the trial, the shims, the
   capture bytes, or the entry's `## Measured (round 70` section the `entry_line()` awk reads.

## 7. Verification (for the owner; not run here)

- `cmp .ufo/waves/round-49/capture/S105.body .ufo/waves/round-70/capture/S170.body` → identical
  (already measured; re-runnable).
- `bash corpus/sources-census.sh` → `CLEAN` after the used-by append (this is the leg that fails
  if the triad is split).
- `bash plans/round-70-c1.sh <landed rev>` → `value=5` with
  `pins=1 setup_ok=1 nosecret=1 noleak=1 sourced=1`; confirm the `sourced` leg still fires after
  the `source:` line edit.
- `claim-ledger.sh docs` (or its substitute) → `entries=` re-derived; then `self-counts.py`
  → CLEAN with `README.md:67` updated to the re-derived number.

FINDING CN-1 falsifies-wording the pre-move sentence "no … source row … for the OpenBao PKI secrets engine" is false: S105 (corpus/SOURCES.md:112) is that page and its capture is byte-identical to S170's (sha256 9fa76939…5e5c1123, 620683 B, cmp IDENTICAL); only "no knowledge entry" and "no PKI-purpose trial" survive
FINDING CN-2 neutral no sibling lane registers either PKI URL (0 hits across 21 lanes) and no sibling holds PKI-engine ground; kake's TLS is the consumer side, so kagi's frontier→core move is unclaimed
FINDING CN-3 neutral kagi's PROVINCE.md carries no adjacency sentence for kake's written "custom domains and TLS" claim (PROVINCE.md:106; render-static-sites.md:55-66), so the next sweep must re-derive the complement boundary
FINDING CN-4 neutral README.md:67's bound "49 pinned" now faces 50 files carrying ^Reverify: (the +1 is the new entry); the number and ledger row R14-01 must be re-derived by claim-ledger.sh docs, not hand-incremented
FINDING CN-5 neutral the frozen counter's header comment dates S170 "opened 2026-11-09" (plans/round-70-c1.sh:4) while the S170 registry row and the entry's source: line both say 2026-11-08; a comment-only contradiction, no leg reads it
SEAT-STATUS: complete
