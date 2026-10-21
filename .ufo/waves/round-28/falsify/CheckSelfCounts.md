# CheckSelfCounts — round-28 FALSIFY (self-counts 60 / stamps 91 / clock selftest 106)

**Verdict: PASS (narrow) on the three bound counts; two non-blocking findings below.**
Target `kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0`; BASE `3553d499577084a6c98d7078906017840bbf7b28`.
Trees exported read-only to `.ufo/waves/round-28/sandboxes/CheckSelfCounts/{cand,base,mut-M1..M3}`; deleted after this report.

## 1. self-counts = 60 — PASS
- cand `python3 corpus/self-counts.py` → `SELF_COUNTS: CLEAN (claims=60 stale=0)`, **exit 0**; 60 `OK` lines, 0 `STALE/UNLOCATED/AMBIGUOUS` (grep counts 60 / 0).
- BASE same command → `SELF_COUNTS: CLEAN (claims=60 stale=0)`, exit 0 (binding did not move this round). `corpus/self-counts.tsv` byte-identical BASE↔cand (`diff -q` SAME): 19 comment + **60 data rows**.
- `corpus/claim-ledger.tsv:81` (R25-02) expects `^SELF_COUNTS: CLEAN \(claims=60 stale=0\)$` — matches.
- Doc bindings all `claimed=… live=…` equal: `corpus/self-counts.tsv:15,16,22,34,35,38,46,47` (91/65/106 stamps-claims-clock on SKILL.md, PROVINCE.md, corpus/README.md).

## 2. stamp count = 91 — PASS (membership + digests + doc bindings)
- `grep -c '[^[:space:]]' corpus/stamps.tsv` → **91**, exit 0. `corpus/claim-ledger.tsv:28` (R12-03) expects `^91$` — matches.
- `bash corpus/row-identity.sh stamps` → `ROW_IDENTITY: stamps count=91 sha256=14663dcd2ee9f3528c6c233cf426f13b6db93ca9767eda0758fd7a2196d4b264`, exit 0. `corpus/claim-ledger.tsv:68` (R24-05) pins that exact count **and** digest — matches byte-for-byte.
- My own re-derivation of all 91 rows (sha256 + `wc -l` lines + bytes): **91 ok, 0 bad** (no MISSING/DIGEST/SIZE). The new `corpus/lessons/round-28.md` row (107 lines / 12228 B) matches the live file.
- Path membership BASE→cand: **removed ∅**, **added {corpus/lessons/round-28.md}** — equals `.ufo/waves/round-28/expectation-migrations.json` → `stamp_membership`.
- Docs resolve: `SKILL.md:46` "91 stamps + 65 claims", `PROVINCE.md:52` "91 revision stamps + 65 claim rows", `corpus/README.md:65` "91 rows" — all `claimed=91 live=91`.
- Every round-28-changed artifact except the two unstamped by design (`corpus/stamps.tsv` itself, `plans/`) carries a live-matching digest: LOG.md, PROVINCE.md, SCORECARD.md, SKILL.md, corpus/QUALITY.md, corpus/README.md, corpus/SOURCES.md, corpus/claim-ledger.tsv, corpus/lessons/round-28.md, corpus/release-clock.py, corpus/source-fetches.tsv.

## 3. clock selftest = 106 — PASS; counted, not silently altered
- cand `python3 corpus/release-clock.py --selftest` → `RELEASE_CLOCK_SELFTEST: PASS (106 cases)`, exit 0. BASE → `PASS (79 cases)`, exit 0. Delta **+27**.
- `corpus/claim-ledger.tsv:82` (R25-03) expects `^RELEASE_CLOCK_SELFTEST: PASS \(106 cases\)$` — matches.
- **The +27 is fully accounted for and the ledger's decomposition is exact.** The counter is a plain increment (`corpus/release-clock.py:2026`), so I enumerated every increment site: 16 new `run_case(...)` labels (8 C2-derived, 8 C1-non-canonical) + 11 standalone cases (5 in the new feed-parser `for` loop, 1 "older oversize entry", 3 `--observe`, 1 leading-zero receipt, 1 derived-observe) = 27. 79+27=106 ≡ R25-03's "+ eighteen NON-CANONICAL token/feed cases (C1) and nine DERIVATION cases (C2) -> 106" (18+9).
- **No pre-existing case removed or weakened.** Structural diff of all `run_case(...)` call sites (base vs cand): every one of BASE's 40 case bodies still present and textually identical after normalising the shared `feed_anchor` default; the only base-vs-cand call difference is the `def run_case(...)` signature line.
- **The one shared-fixture change is disclosed, and the disclosure is accurate.** `corpus/release-clock.py:1062-1076` changes the default feed-anchor cell from BASE `"Latest release"` to `"Latest release 1.2.0; series 1.2.x"` so three pre-existing derived cases keep their expectations under the new DERIVATION rule. R25-03's note says exactly this ("three round-25 derived cases keep their expectations with a feed-row anchor that names their version"). Verified by mutant M1 (revert only that default): exactly those three base cases fail — `derived anchor counted`, `non-numeric anchor keeps inequality`, `feed floor lifts non-numeric anchor` (exit 1); the other 37 are inert to the cell, which is read only on `is_derived` rows.
- **Count is non-vacuous** (mutants, own copied trees, selftest only): M1 (base anchor restored) → FAIL exit 1; M2 (`non_canonical_version`→`False`) → FAIL on `leading-zero observation refused`, `leading-zero anchor refused`, `derived leading-zero anchor refused`, `zero-padded middle component refused`, `nineteen-digit component refused`, `oversize observation refused`, exit 1; M3 (`derived_anchor_bound`→`True`) → FAIL on `derived anchor must name feed anchor`, `derived anchor rejects suffix sibling`, `derived anchor needs a named version`, exit 1. Neither C1 nor C2 predicate can be dropped without failing the 106.
- Default control identical BASE↔cand: `python3 corpus/release-clock.py` → `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)`, exit 0 both trees (the plan's control string).

## Findings
**F1 (LOW) — `corpus/stamps.tsv` row order changed, unrecorded, and locale-dependent.** BASE file was C-collation sorted; the candidate is not: `LC_ALL=C sort -c corpus/stamps.tsv` → exit **1**, `disorder: corpus/stamps.tsv:16: corpus/fixtures/cells-hermetic/SCORECARD.md …`; `LC_ALL=en_US.UTF-8 sort -c` → exit 0; BASE file `LC_ALL=C sort -c` → exit 0. Cause: `corpus/claim-ledger.sh:438` writes stamps with a bare `sort -o "$STAMP_TMP" "$STAMP_TMP"` (no `LC_ALL=C`), so order follows the writer's locale (this host `LANG=en_US.UTF-8`). Effect: ≥10 rows repositioned in the candidate stamp commit (the eight former top rows LOG.md…corpus/SOURCES.md, plus `corpus/fixtures/cells-hermetic/SCORECARD.md` and `corpus/lessons/round-21-verifier-spotcheck.md`), while `expectation-migrations.json` → `stamp_membership` records only `added:[corpus/lessons/round-28.md]`, `dropped:[]` — membership-true, reordering unrecorded. **No gate breaks**: R12-03 counts rows, R24-05 hashes the *sorted* member list (`corpus/row-identity.sh:75-78` sorts before hashing), and `claim-ledger.sh` reads rows order-independently, so count-91/digest-91 stay correct. Counterexample: regenerating the reviewed stamp file on a C-locale host emits a different file than the candidate's.
**F2 (INFO) — `corpus/README.md:65` history chain skips round 27.** Reads "91 rows (89 at round 26, 88 at round 25, 63 at round 21, …)": live count 90→91 is right but "90 at round 27" is omitted, breaking the consecutive chain. The authoritative chain is in the ledger notes (`corpus/claim-ledger.tsv:28` and `:68`: "Round 27 … -> 90", "Round 28 … -> 91"); the parenthetical is history prose, out of the self-counts population by rule (`corpus/self-counts.tsv:6-11`).

## Commands run (in my exported trees; no host-private row executed)
`git archive` of BASE and the pinned candidate into my sandbox (read-only `git`); `grep -c`; `LC_ALL=… sort -c`; my own in-tree sha256/lines/bytes re-derivation script; `python3 corpus/release-clock.py [--selftest]`; `python3 corpus/self-counts.py`; `bash corpus/row-identity.sh {stamps,scorecard-rounds,ledger-ids}`; `bash corpus/sources-census.sh`; three in-tree selftest mutants. No network, no vault/account/handler/CDP contact, no `claim-ledger.sh verify|cells|citations` (they re-measure host/substrate rows), no writes to the lane checkout, no git/jj mutation.

## What I did NOT check
- `bash corpus/claim-ledger.sh verify` / `cells` / `citations` — deliberately not run (host rows / fleet-layout dependent).
- R22-03 `revision-audit --history c2cab35…` (R24-15 `revision-added`): in my exported tree `row-identity.sh revision-added` → `ROW_IDENTITY: SETUP (revision-audit --history failed)` (no `.git` in the export) ⇒ **UNPROVABLE here**; the added=28 binding is unverified by me (consistent with the membership diff, but not executed).
- The other 34 falsify carriers (C1/C2 token+derived carriers, S044-S049, mutation items) — out of scope.
- Whether 60/91/106 survive a later round-28+ edit — pinned candidate only.
- `corpus/source-fetches.tsv` capture/quote integrity and the S044-S049 registry rows' own claims.

## Residual risk
F1's locale dependence is a latent trap for the next round: regenerating stamps under a different locale silently reshuffles ~10+ rows of a reviewed pin file, and the migration record's membership-only view will not show it.
