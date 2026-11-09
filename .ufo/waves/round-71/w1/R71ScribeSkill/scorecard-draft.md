# SCORECARD.md — proposed round-71 sections (draft, not an edit)

Reconciliation first. The working tree of `SCORECARD.md` already carries an uncommitted 27-line
insertion (`git diff --stat`: 27 insertions): the round-70 freshness errata and the `## Round 71 —
pre-move` section. Section C below reproduces that pre-move text so integration can diff it; if the
working-tree text differs, keep the working-tree text. Sections A, B and D are not in the working
tree and are proposed.

Placeholders (`<…>`) are filled only from the final counter reading and the landed revision. Nothing
here carries a counter number.

## A. Capabilities table — one row (after the round-70 row, the last row of `## Capabilities`, line 728)

Row shape: `| capability | what it can now do | evidence pointer | first-working round |`. The paragraph
after the table says rows enter only through demonstrated execution; this row enters only when the
final reading is `value=4` (kill rule: `value < 4` → C1 missed, no row).

| OpenBao PKI issuer and revocation-channel trial | execute four issuer and revocation-channel mechanics against a throwaway OpenBao 2.7.2 dev server (127.0.0.1, random root token only in the environment, `setpriv --pdeathsig KILL`, port checked to be held by the started server, synthetic names under `r71.test`): an issuer set to `truncate` issues a 10h leaf from a 2h issuer with the issuer's NotAfter; a revoked leaf of a non-default issuer (role `issuer_ref`) is on its own issuer's CRL and absent from the default's; token-less OCSP reports `revoked` and `good`; a `no_store` leaf is refused revocation by serial and revoked by proof of possession. Each verdict flips under its own falsifier shim and each public artifact is re-checked with openssl. The counter alone does not prove OpenBao produced the artifacts (plan §C1 named ceiling); relying-party fetching is not shown | `bash plans/round-71-c1.sh <rev>` ⇒ `<FINAL COUNTER LINE>` (ledger: none; receipts `.ufo/waves/round-71/final/`); `corpus/knowledge/openbao-pki-issuer-revocation-channels.md` | 71 |

Paragraph after the table, the round-49-style note (appended, the existing text not rewritten): the
sentence "The latest first-working round in this table is 62" was already stale when the round-70 row
(`| 70 |`) landed. Proposed appended note: "Round 71 note (appended): the latest first-working round
in this table is 71 (OpenBao PKI issuer and revocation-channel trial), if the final reading is
`value=4`; the round-62 sentence above is history."

## B. Round 71 — post-move (claim C1 depth — capability acquisition)

Candidate `39e76bc700cf05e7772711f703bdbc3c6e7ac469` (trial, entry, S173, the stamp row, the S173
capture, the L1 probe receipt) plus the round-71 integration commit `<integration rev>`. Wave `w1`
(12 seats, attempt 1); receipts `.ufo/waves/round-71/final/`, `.ufo/waves/round-71/controls/receipts/`.

| Axis | Before → after | What moved | Evidence |
|---|---|---|---|
| coverage | 9 → 9 | No claim. Registry 163 → 164 (S173 admit, tier A, mined; S170 used-by extended). | `bash corpus/sources-census.sh` ⇒ `<SOURCES_CENSUS line at integration>` |
| depth | 9 → 9 | [C1] `bash plans/round-71-c1.sh <rev>` ⇒ BASE `value=0 absent=1` rc 1 → candidate `<FINAL COUNTER LINE>` rc `<rc>`; every test T6–T9 `real=HOLDS,shim=BROKEN,spec=1,entry=1,art=1`. The issuer NotAfter policy, per-issuer CRL routing, the token-less OCSP responder and proof-of-possession revocation of a `no_store` leaf move from unexecuted to executed and artifact-checked. Named ceiling (plan §C1, not closed by the counter): a same-uid trial can read the wrapper bytes and mint look-alike artifacts with local openssl; F2 closes the wrapper-read alone, not the minting. Relying-party fetching of CRL/OCSP is not measured. Target 4, kill rule `value < 4` → C1 missed (honest stop; no capability row). | `corpus/knowledge/openbao-pki-issuer-revocation-channels.md` §Measured; `corpus/openbao-pki-issuer-trial.sh`; `plans/round-71-c1.sh`; `.ufo/waves/round-71/controls/receipts/` (P1, F0–F7) |
| operability | 9 → 9 | No claim. One new runnable trial; nothing schedules it. | `corpus/openbao-pki-issuer-trial.sh` |
| freshness | 9 → 9 | No claim. S173 and S170 carry a `180d` registry recheck; the new entry's `recheck:` line names `on-release` as its own content clock. That clause is text only: `corpus/release-clocks.tsv` has no S170/S173 row. | `corpus/SOURCES.md` (S170, S173 recheck column); `corpus/release-clocks.tsv` |
| calibration | 9 → 9 | No claim. Adds manifest row `71<TAB>C1<TAB>depth` to `corpus/claims-declared.tsv` (plan heading `## C1 — depth:` in `plans/round-71.md`; post-move carries one `[C1]` row whose first cell is `depth`). The round-69 MISMATCH pair is carried, not claimed. | `bash corpus/claims-declared.sh` |
| adjacency | 9 → 9 | No claim. Connector sweep: `<R71Connector seat report, pending>`. | `.ufo/waves/round-71/w1/R71Connector.md` (pending) |

Declared claim: **C1 depth** (capability acquisition). The post-move reading stands only with the
final counter reading on the landed revision.

## C. Round 71 — pre-move (matches the working-tree text; reference for the diff)

Claim BASE `e0e9603a924d73d9621924cc507b50474d11dae7`; freeze `1199295573a4eb1791e965178c8643213312943d`
(plan, counter, runner and nine executed prefreeze controls landed together, before any candidate
byte). All six axes stand at 9, so any claim meets the lowest-axis duty; a capability entered at
round 70, so the stagnation nudge does not fire. Depth is the axis untouched longest.

| Axis | Score | Evidence pointer | Last change |
|---|---|---|---|
| coverage | 9 | 163 registry rows at BASE (`bash corpus/sources-census.sh` ⇒ `SOURCES_CENSUS: CLEAN (rows=163 …)`); PKI held for one default issuer only (round 70). Fleet census `kagi ok` rc 0, 26 W04 lines on stdout (`.ufo/waves/round-71/base/census-round-start.stdout.txt`). | round 70 |
| depth | 9 | Unchanged from round 29 (`R29-01`). The round-70 PKI entry lists multi-issuer chain behaviour, `leaf_not_after_behavior`, OCSP and revocation with a private key under "Does not establish". | round 29 |
| operability | 9 | Unchanged; nothing schedules any gate. | round 67 |
| freshness | 9 | Unchanged (see the errata above for the round-70 sentence). | round 68 |
| calibration | 9 | `corpus/claims-declared.sh` carries the round-69 MISMATCH pair; not claimed. | round 67 |
| adjacency | 9 | Ownership partition gate green (`R17-02`). | round 58 |

Declared claim: **C1 depth** — `C1_PKI_ISSUER_TRIAL: value=4` (BASE 0). No retirement, split or
stagnation waiver is claimed.

Drafting notes against the working-tree text (not edits): the coverage row's "round 70" last-change
cell is consistent with the round-70 post-move coverage row (`9 → 9`, with a capability row); the
pre-move coverage row is the only place that cites the round-70 trial; the depth row's round-29 claim
is true at BASE and is replaced at the round-71 post-move by section B.

## D. Errata to append (not rewriting any line)

The round-70 errata is already in the working tree (`## Errata — round 70 post-move freshness
sentence`). One further append is proposed if integration wants the round-70 PKI entry's scope
pointed at round 71:

"## Errata — round 70 PKI entry, `Does not establish` (appended round 71; the round-70 entry is not
rewritten): `leaf_not_after_behavior`, OCSP responses, multiple issuers' chain building and
revocation with a private key are listed there as not established at round 70. Round 71 executes
the issuer NotAfter policy (T6), per-issuer CRL routing (T7), token-less OCSP (T8) and
proof-of-possession revocation (T9) in `corpus/knowledge/openbao-pki-issuer-revocation-channels.md`;
chain building and multi-issuer CRL fetching by a relying party remain not established."
