Author: R71Connector (connector)

# R71Connector — sibling/registry overlap scan and pre-move falsity check

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`; BASE `e0e9603a`, freeze `1199295`, candidate
`39e76bc7`. All reads read-only (`git show/diff/log/cat-file`, `grep`, the lane's own read-only
gates); no git/jj mutation, no `bao` server started by this seat, no tool installs.

## 1. What was measured

| check | command | result |
|---|---|---|
| candidate file set (excl. `.ufo`) | `git diff --name-only e0e9603 39e76bc \| grep -v '^\.ufo/'` | 8 files: `corpus/SOURCES.md`, `corpus/knowledge/openbao-pki-issuer-revocation-channels.md`, `corpus/openbao-pki-issuer-trial.sh`, `corpus/source-fetches.tsv`, `corpus/stamps.tsv`, `plans/round-71.md`, `plans/round-71-c1.sh`, `plans/round-71-controls.sh` |
| frozen counter | `sha256sum plans/round-71-c1.sh` | `4d77f19c…b8117b` = `controls/receipts/counter.sha256` = dispatch value |
| pin / tooling | `sha256sum ~/.local/bin/bao`; `openssl version` | `9c5f3628…b788` = `PIN_BAO`; OpenSSL 3.6.5; `bao version` = v2.7.2 |
| captures | `sha256sum .ufo/waves/round-71/capture/{S173,S170}.body` vs round-70 copies | S173 `42ef7582…5047a` both copies; S170 `9fa76939…1123` both copies (byte-identical as the plan states) |
| S173 provenance | `python3 corpus/rendered-text-v1.py digest .ufo/waves/round-71/capture/S173.body`; `… locate <body> <quote>` | raw 96207 B, normalized `b0c82c39…980f` / 38323 B, `count=1` — all three equal the `corpus/source-fetches.tsv` S173 row (cols 10/11/15) |
| lane census | `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=164 … mined=142 rejected=19 …)`, captures 44/44 located |
| doc audit | `bash corpus/claim-ledger.sh docs` | `DOC_AUDIT: CLEAN (entries=51 row_linked=48 … unpinned=0)` — the new entry is declared, row-linked and stamped |
| self-description sweep | `timeout 240 bash corpus/self-description-sweep.sh` | did not finish in 240 s on this host; **not measured** (not a finding) |
| controls vs plan table | `.ufo/waves/round-71/controls/receipts/{f0-base,p1,f2,f7}.txt` | P1 `value=4 … all art=1` rc0; F0 `value=0 absent=1` rc1; F2 `spec=1 shim=BROKEN art=0`; F7 `value=3` with `T7 … art=0` — each equals the frozen table |

## 2. Sibling and registry overlap (adjacency evidence)

- Fleet-wide scan for the round's ground tokens (`leaf_not_after_behavior`, `revoke-with-key`,
  `ocsp_disable`, `pki/issuer`, `issuer_ref`, `openbao.*pki`, `vault.*pki`; `*.md|*.sh|*.tsv`,
  `.ufo/` excluded) over every `*-shokunin` other than kagi: **0 hits in all 20 sibling lanes**.
  Round-70's conclusion stands: kake owns TLS as a *consumer*; mado owns credential material;
  chousa owns research method — none holds PKI-engine issuer or revocation-channel ground.
- No sibling registry carries either URL: `grep -rln "pki/considerations"` outside kagi → none;
  `openbao.org/docs/api/secret/pki` appears only in kagi rows S105/S170.
- Lane registry, same-URL rows (W04 question): `https://openbao.org/docs/secrets/pki/considerations/`
  occurs on **S173 only** (`grep -n` on `corpus/SOURCES.md` → line 173). The `api/secret/pki` URL is
  the pre-existing cross-scope duplicate S105/S170.
- Fleet contrast gate: `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
  ⇒ rc 0, 26 `W04` lines (S170 among them, from S105) and **no `W04` line for S173** — the new row
  adds no duplicate-URL warning and satisfies QM101's search-before-append duty.
- Id reuse across lanes is normal (chousa's `S173` is chousa's own-work row); the census keys rows
  per lane and reports no collision, so nothing is inherited from that name clash.

## 3. Does PROVINCE.md cover this ground?

Partially, at candidate: `PROVINCE.md:97` carries the round-70 core bullet for single-issuer PKI
(`openbao-pki-certificate-lifecycle.md`, T1–T5) and its own text says the round-70 entry lists
multi-issuer behaviour, `leaf_not_after_behavior`, OCSP and private-key revocation under
"Does not establish". No bullet names the round-71 entry, issuer-level `leaf_not_after_behavior`,
per-issuer CRL routing, the unauthenticated OCSP responder or BYOK/BYOC revocation. That is not a
candidate defect: the round-70 bullet entered at the **integration** commit `ba8c730`, after
candidate `0d22555`, so the same obligation (extend or add the round-71 core bullet) falls on
integration. Second-order effect to schedule: once round-71 lands, `PROVINCE.md:97`'s clause
"lists … under Does not establish" becomes stale — it must be extended append-only (QM97), never
rewritten.

## 4. Pre-move and freeze sentences checked against the tree

True and receipted: "All six axes stand at 9" (`SCORECARD.md:2476-2491`); "Depth … last change
round 29" (`:2509`); "its knowledge entry lists multi-issuer behaviour under 'does not establish'"
(`corpus/knowledge/openbao-pki-certificate-lifecycle.md:54-63`); "capture byte-identical to the
round-70 scout capture"; "no S173 row"/"no `corpus/openbao-pki-issuer-trial.sh`" at BASE
(`git show e0e9603:corpus/SOURCES.md | grep -c '^| S173 '` ⇒ 0); "`value=0 absent=1`" at BASE
(`controls/receipts/f0-base.txt`).

Two sentences are **false** against the tree the freeze measures:

1. **"S170 … for the T6/T8/T9 anchors without a row change."** The candidate changes the S170
   row's `used-by` cell: BASE tail ends `…openbao-pki-certificate-lifecycle.md |`, candidate tail
   ends `…openbao-pki-certificate-lifecycle.md, corpus/knowledge/openbao-pki-issuer-revocation-channels.md |`
   (`git diff e0e9603 39e76bc -- corpus/SOURCES.md`, the one `| S170` line pair). The extension is
   *required* by QM71 (a used-by cell that omits a citing entry is a self-description defect), so
   the landed row is right and the frozen sentence is wrong.
2. **"None is executed, entered or counted at BASE."** Only *entered* (no `corpus/knowledge/`
   entry) and *counted* (no counter) are true. All four observables were already measured on
   OpenBao 2.7.2 in round 70 and the receipt is **inside the BASE tree**:
   `.ufo/waves/round-70/w1/R70Scout/receipts/probe-frontier-final.txt` (blob at `e0e9603`) carries
   `PROBE F3 YES … nondefault_leaf default_crl=absent own_issuer_crl=present` (T7),
   `PROBE F7 YES ocsp_before=good ocsp_after_revoke=revoked unauthenticated=true` (T8) and
   `PROBE F10 YES revoke-with-key http=200 state=revoked` (T9); `probe-frontier-focused.txt`
   carries `F1.permit/F1.truncate/F1.err` with the three-way split (T6: `truncate` clips to the
   issuer's expiry, `err` ⇒ `issue_rc=2`). `R70Scout.md:98-100` states SC-1/SC-2/SC-3 as measured.
   The round's real novelty is therefore *entered + shim-discriminated + openssl-artifact-checked*,
   not first execution. Note the scout's two T6 receipts disagree (`probe-frontier-final.txt` shows
   permit/truncate/err all issuing with one expiry; only the *focused* receipt discriminates), so a
   cross-reference must cite the focused rows and say so.

Also noted (neutral): the S170 row's `scope`/`anchor` cells still enumerate only the round-70
sections (key generation, role params, `ttl`, revoke-by-serial, "§Revoke certificate"), while the
new entry's `source:` cites S170 §Update issuer, §Set revocation configuration, §OCSP request and
§Revoke certificate with private key. No gate reads a row's `scope` (sources-census is CLEAN), so
this is an unread self-description gap, not a green-gate break.

## 5. Affected axes

- **calibration** — a false frozen sentence is quoted by the round's own record; left uncorrected
  it is the exact class QM78/QM97 exist for (a record line no command re-derives). Fixing it
  append-only costs nothing and closes the gap.
- **depth** — the C1 count is unaffected (it stays 4 and its control battery still separates 0/3/4),
  but the *evidence depth* statement changes: with the scout receipts named, three of four
  observables are replicated across two independent instruments on the same binary (2 h vs 30-day
  issuer shapes) and one (T8) is measured once; that is a stronger, honest depth claim than
  "4 tests, first time".
- **freshness / adjacency** — untouched by the move; no new source, clock or URL.
- **coverage / operability** — untouched.

## 6. Proposed move (one, bounded)

At integration (not now, and never by editing the frozen plan or counter): append a
**"Prior observation (round 70, unentered)"** paragraph to
`corpus/knowledge/openbao-pki-issuer-revocation-channels.md` and one SCORECARD/lesson correction
line, stating:

- the four observables were seen on 2.7.2 at round 70, with `probe-frontier-focused.txt`
  F1.permit/F1.truncate/F1.err (T6, 30-day issuer), `probe-frontier-final.txt` F3 (T7), F7 (T8),
  F10 (T9);
- what round 70 did *not* have: an entry, a falsifier shim, or an openssl artifact check —
  which is what C1 measures;
- the T6 disagreement between the two scout receipts, so the citation points at the focused rows.

This is a synthesis of two already-present artifacts (the round-70 scout receipt and the round-71
counter) and needs no new run and no gate change. Insert it outside the `## Measured (round 71`
section (the counter's `entry_line` reads only lines beginning `- T<n> ` inside that section, so
placement there would create a second matching line for no benefit).

## 7. Risks

- Re-stamping: the entry is in `corpus/stamps.tsv`; any edit must re-stamp it in the same commit
  (QM61) and re-run `claim-ledger.sh docs` (currently `entries=51`, CLEAN).
- The scout's `probe-frontier-final.txt` F1 rows do **not** discriminate (all three issue with the
  same expiry); citing that file for T6 would launder a non-reproducing receipt. Cite the focused
  file for T6 only.
- Do not let the note become a new claim: it reports an unshimmed, unentered observation, so it
  must stay inside the entry's "Does not establish"-adjacent framing, not the measured table.
- The C1 value and kill rule are untouched by this move; the counter is frozen and stays so.

## 8. Verification the L1 should run after the move

`bash plans/round-71-c1.sh 39e76bc7` (expect `value=4` rc 0, unchanged verdict line);
`bash corpus/claim-ledger.sh docs` (`DOC_AUDIT: CLEAN`, entries=51); `bash corpus/sources-census.sh`
(`CLEAN rows=164`); `bash scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi`
(rc 0, 26 `W04`, no S173 line); `grep -n "Prior observation" corpus/knowledge/openbao-pki-issuer-revocation-channels.md`
plus `sha256sum --check` on the re-stamped row.

FINDING CN-1 falsifies-wording plans/round-71.md §Frontier step says S170 was re-opened "without a row change", but the candidate extends S170's used-by cell to the new entry (git diff e0e9603 39e76bc -- corpus/SOURCES.md), and QM71 requires that extension; the frozen sentence, not the row, is wrong.
FINDING CN-2 falsifies-wording plans/round-71.md §C1 says "None is executed, entered or counted at BASE", but all four observables were measured on OpenBao 2.7.2 in round 70 and receipted inside the BASE tree (.ufo/waves/round-70/w1/R70Scout/receipts/probe-frontier-final.txt F3/F7/F10; probe-frontier-focused.txt F1.permit/truncate/err); only "entered" and "counted" hold.
FINDING CN-3 neutral S170's scope/anchor cells still enumerate only the round-70 sections while the new entry's source: cites §Update issuer, §Set revocation configuration, §OCSP request and §Revoke certificate with private key; no gate reads a row's scope (sources-census CLEAN), so the gap must be closed by a scope extension or a lesson statement.
FINDING CN-4 neutral PROVINCE.md at the candidate does not name issuer-level or revocation-channel ground; the round-70 bullet entered at integration ba8c730, so this is an integration obligation, and that bullet's clause "lists … under Does not establish" must be extended append-only once round 71 lands (QM97).
FINDING CN-5 neutral .ufo/waves/round-71/capture/S173.fetch.txt records size=22703 while the registry and source-fetches row state 96207 B; the field is the compressed transfer size (same convention as the same round's S170 receipt size=68891 against 620683 B) and is unlabeled, so it can be misread against the decoded byte count.
FINDING CN-6 neutral corpus/openbao-pki-issuer-trial.sh has no corpus/stamps.tsv row at the candidate (the new entry does); the round-70 candidate 0d22555 likewise landed its trial unstamped and integration ba8c730 added it, so this is the settlement pattern, not a candidate defect, but it must not be forgotten at landing.
SEAT-STATUS: complete no sibling lane or registry row holds the round's PKI issuer/revocation ground and S173 adds no W04; two frozen pre-move sentences are false against the BASE tree, both correctable append-only without touching the frozen plan or counter.
