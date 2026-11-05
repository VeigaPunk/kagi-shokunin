# Round 45 — plan↔manifest bijection for the declared-claim gate (C1, calibration); one assimilated ISO/IEC 11770-3 knowledge entry with located quotes (C2, coverage)

Frozen plan: `plans/round-45.md` (predeclaration `307fb50da825d6e6f2b5c7981c71556d35611142`; BASE `0d0192f63eb5e49826d75af1e5293004dc691a18`). Amendment A1 `c74ca51b9e867ac2d18e92664662f2115705c099` (pre-candidate, nine items). Counters `plans/round-45-c1.sh`, `plans/round-45-c2.sh`. Build wave: `.ufo/waves/round-45/build/` (11 seats). Candidate: the round-45 landing commit recorded in the report.

## Claims

- **C1 calibration — the declared-claim gate is a bijection with landed plan headings.** `corpus/claims-declared.sh` read CLEAN with a landed plan claim missing from the manifest (M44-9, routed in round 44). The gate now checks, for every round R ≥ 39 that carries a SCORECARD `## Round R — post-move` section, that each plan heading `## C<k> — <axis>:` has exactly one manifest row. Frozen predicate: `C1_BIJECTION: value = DETECTED when POSITIVE = 1 and REAL = CLEAN, else 0; target 2.` BASE `value=0 detected=0 positive=1 real=CLEAN`; candidate `value=2 detected=2 positive=1 real=CLEAN (rc A=1 B=1 C=1; real-last 'CLAIMS_DECLARED: CLEAN (claims=17)')`. `--selftest` 8 cases PASS.
- **C2 coverage — one assimilated knowledge entry on ISO/IEC 11770-3 edition status, every quote located.** The lane held no ISO/IEC 11770 entry at BASE. Frozen predicate: `C2_LOCATED: value = LOCATED when census=0, quote-locate exit 0, entries ≥ 1 and LOCATED ≥ 3; else 0; target 3.` BASE `value=0`; candidate `value=3 added=3 entries=1 census=0 located=3 (quote-locate rc=0)`; `quote-locate.py` `QUOTE_LOCATE: CLEAN located=8 rows=8`.

## Gate

Sources opened this round (access date 2026-11-05; decoded bodies committed under `.ufo/waves/round-45/controls/capture-r45/`; raw sha256 and byte counts in `corpus/source-fetches.tsv`):

- **S100** — https://webstore.iec.ch/en/publication/62160 (IEC record of ISO/IEC 11770-3:2015/AMD1:2017). Located quote, ≤25 words: "ISO/IEC 11770-3:2015/AMD1:2017" (decoded body offset 187). Body sha256 `9ef61b3f…736298`, 430686 bytes. Staged id S159.
- **S101** — https://www.iso.org/standard/60237.html (ISO catalogue record of ISO/IEC 11770-3:2015). Located quote: "Withdrawal of International Standard" (offset 45752). Fetched with a browser user agent: the default user agent returned HTTP 403 on the same day; body sha256 `2e4c1524…7b0c80`, 85615 bytes. Staged id S170; the archived snapshot `web.archive.org/web/20260212133408id_/…` timed out at 30 s and is not cited.
- **S102** — https://webstore.iec.ch/en/publication/71650 (IEC record of ISO/IEC 11770-3:2021). Located quote: "ISO/IEC 11770-3:2021" (offset 187). Body sha256 `31238656…ce0be`, 434303 bytes. Staged id S171.

Paraphrased, not quoted: the 2015 catalogue's scope statement (no key lifecycle management; no asymmetric key-pair generation or validation); the 2021 publication date and edition 4.0; the amendment's withdrawal date and the newer amendment named on its page. These are cited to S100–S102 by row, not counted as located quotes.

Renumber map (by document, first citation order in the staged entry; staged ids collide with lane ids S052–S099 and are not reused): S159 → S100, S170 → S101, S171 → S102. Staged S172 and S173 (IEC records 107179 and 21094) were fetched read-only as a supplementary check and are **not** admitted: no admitted claim rests on them, and admitting uncited rows is refused by CORPUS rule 4.

Collision guard (scout K45ScoutSources): 48 staged ids collide with lane ids (S052–S099); the cited staged ids S159, S170, S171 do not. Red witness: a registry copy with one indented row `  | S052 |` yields a non-empty collisions file (51 lines). The guard is proven before the append.

Quarantine (absent-defect register, kagi slice): staged ids S053, S071, S081, S090, S091, S093, S108, S113 (`payload-absent`). None is cited by the admitted entry; the slice is not appended.

Discernment sample (LEARNING.md): admitted — S100–S102 (each re-opened this round; each located quote re-checked by `quote-locate.py` against the committed body). Refused — staged S172 and S173 (fetched, no admitted claim cites them; flip: a claim that needs an IEC record for a 2021 amendment). Refused — the staged entry's "could not be opened" premise (stale for the browser user agent; corrected in the entry's access note, not admitted as a rejection of S101).

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M45-1 | landing (stamp drift undercount, round-44 closure D2) | closure `corpus/lessons/round-44-verifier-spotcheck.md` §1 D2: seven stamp rows out of step at `d54109d`; stamps at `92c394c` re-pinned 123 rows (`M44-10`) | round-44 closure (non-author) | erratum E45-1 (below) and a red witness: `.ufo/waves/round-45/build/K45ExecStampRW/receipts.txt` — unaltered tree `STAMP_DRIFT: rows=123 drift=0` (rc 0); one byte appended to root `LOG.md` `drift=1` (rc 1); one stamp cell flipped `drift=1` (rc 1). The fix counts because the drift check reads non-zero on each altered copy. |
| M45-2 | fail-open (locator exit code ignored) | `plans/round-45-c2.sh` before A1: `locate_rc` captured but not gated; reviewer F-1 HIGH, critic D-5 (`.ufo/waves/round-45/build/K45ReviewerPlan.md`, `K45CriticClaims.md`). A SETUP exit with no NOT-LOCATED lines read every added row as located. | reviewer K45ReviewerPlan and critic K45CriticClaims, before any candidate was scored | A1-2: `value` also requires `quote-locate.py` rc 0; QM56. Shown able to fail: a SETUP-exit fixture is not in the frozen set; the reviewer's harness reproduces the false pass (`value=3` with rc 2) and A1-2 reads 0 on it. |
| M45-3 | self-description / fixture leak (a shared `# fixture` header marker) | `plans/round-45-c1.sh` before A1: fixtures carried `# fixture` headers; reviewer F-2 showed a gate keyed on that marker satisfies the counter (`detected=2 positive=1 real=CLEAN`, value 2, no bijection logic) | reviewer K45ReviewerPlan | A1-4: marker removed; ceiling named (a gate keyed on the synthetic round numbers is not refused by fixtures; REAL leg and `--selftest` are the remaining legs, both pass at the candidate). |

Vocabulary: the round-44 closure asked that classes be drawn from the mistakes vocabulary. The only class list in the fleet is `.ufo/waves/kaika-w1/mistakes.md` §5 (proposals L1–L5, not a closed vocabulary). Mapping used here: M44-2 self-description → L3 (premise re-check); M44-4 landing/fail-open → L1 (a fix shown able to fail) with the prose kept in the fix column; M44-5 environment leak → L4 (one writer; ambient state cleared); M44-7 grammar looseness → L2 (bound, not payload list); M44-8 fail-open contract → L1; M44-9 coverage of the gate itself → L2. The mapping is a ceiling: the lane has no closed vocabulary of its own.

## Errata (append-only; the superseded text is kept in the cited file)

- **E45-1 (stamp migration undercount, round-44 M44-10 and closure D2).** The round-44 lesson said the stamp verdict was stale because of three gate scripts and attributed four other changed rows to round 44. At `d54109d` the closure measured seven rows out of step (`LOG.md` 1783/148801 recorded vs 1794/151649 actual; `SCORECARD.md` 1595/196478 vs 1629/202119; `corpus/QUALITY.md` 218/38737 vs 227/40705; `corpus/SOURCES.md` 258/92005 vs 258/92061; plus the three scripts). The round-44 landing re-pinned them. Measured current drift at `0d0192f` is 0 (`sha256` over `corpus/stamps.tsv`, 123 rows). This round changes stamped files again; they are re-pinned at this round's landing through `corpus/claim-ledger.sh stamp`, and the re-pin values are recorded in the report.
- **E45-2 (red-witness label, round-44 `controls/amend-a1-redwitness.txt`).** The line `C2 clean four-line receipt at BASE (expect 0: gate absent at BASE? see note): 1` carries an expectation the file does not support: the gate was present at `d54109d` (`git cat-file -e d54109d:corpus/controls-replay.sh` rc 0), and a valid receipt over a present gate reads 1 by design. The stated expectation is restated here as 1; the original line is not rewritten.

## Routed (named, not claimed this round)

1. **B1 (battery always-refuse conjunct undiscriminated, round 44 Routed 1):** not taken; no receipt exercises the blanket leg. Round-46 candidate.
2. **Round-40 report erratum:** still owed; not in this round's write scope.
3. **Revenger SEAT-STATUS line (round-44 closure §5 item 6):** the round-45 revenger seat reports its status; its findings are used only as cited evidence.
4. **Scheduling of `corpus/controls-replay.sh`:** operator scope; refused.
5. **Open L0 lines** (`.ufo/l0-questions.md`, kagi rounds 28, 30, 32, 38, 39, 40, 42): routed around, never assumed answered. Round 45 adds one L0 line about the build wave's dispatch stall (dispatch marker late by about 35 minutes; resolved when the wave dispatched at 17:42).
6. **Assimilation contract (§10):** this round assimilates one theme (ISO/IEC 11770-3 edition status) under the quarantine-first rule and the collision guard; the rest of `merge/kagi/` stays staged and unadopted.
7. **Permanent in-flight scope (critic D-4):** a plan with claim headings and no post-move section is not checked. Round 46 audits round 45 mechanically; any round-45 MISMATCH there is a round-46 finding.
8. **Stale provenance in the staged rows (critic D-2 #3):** the staged rows cite `corpus/README.md` §Frontier for the NIST item, which moved to core in round 33. The admitted entry does not copy that provenance.

## Frontier

- **ISO/IEC 11770-3 edition status:** moved from unheld ground to a knowledge entry for the edition in force and the withdrawn 2015 base. The 2017 amendment's successor is named by the record and is not described here (frontier, not core).
- **Operability ground held:** the located-quote gate covers the new rows; `quote-locate.py` rc 0 is required for the counter's value (A1-2).

## Assimilation

Taken: one theme, one entry (`corpus/knowledge/iso-11770-3-edition-status.md`), three rows (S100–S102), with the renumber map above. The staged entry's dependency premises (GB/T 17901.3-2021 adoption, round 8's S148) are not carried: they were not re-opened this round, and CORPUS rule 1 requires each cited source to be opened in-round. The admitted entry is self-contained on what it cites.

## considerthese

`considerthese/2026-10-26.md`, proposal 3 ("mark known-defective instrument output") is taken as QM55, grounded on S052 (the Atom title rule: a title's sentence punctuation is content, so a feed extractor that drops `Python 3.15.1.` is defective). Proposal 1 (repair-only path under HOLD) is operator policy and is not taken. Proposals 2 and 4 are not taken (status line and a BACKLOG file are unscoped in this round).

## Leads (unopened)

The round-44 rejected inventory moved to `corpus/SOURCES.md` `## Leads (unopened)` as bullets (D5 of the round-44 closure). ISO/IEC 11770-3 is partly discharged by this round (S100–S102); the other ISO/IEC 11770 parts and GB/T 17901 remain leads.

## Adjacency

Connector sweep (`.ufo/waves/round-45/build/K45Connector.md`): no sibling gate binds plan headings to a manifest (overlap 0 across 20 siblings); no sibling knowledge entry or registry row holds ISO/IEC 11770 or GB/T 17901 (overlap 0). Adjacent: `kasegi-shokunin`'s claim-package check and `kengaku-shokunin`'s SHA256SUMS manifest view, neither of which binds round plans to a manifest.

## Measured

- `bash plans/round-45-c1.sh <candidate>` → value 2 (see Claims).
- `bash plans/round-45-c2.sh <candidate>` → value 3 (see Claims).
- `CLAIMS_DECLARED: CLEAN (claims=17)`; `CLAIMS_DECLARED_SELFTEST: PASS (8 cases)`.
- `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` → `kagi ok`, rc 0 (registry 99 → 102).
- `python3 corpus/quote-locate.py` → `QUOTE_LOCATE: CLEAN located=8 rows=8`.
- Stamp drift (E45-1): `STAMP_DRIFT: rows=123 drift=0` at the candidate after re-pinning.

Receipts and command output: `.ufo/waves/round-45/final/` (landing-time measurements, committed with the candidate).

## Sentinel review (K45Sentinel, non-author, after the candidate landed at 072bb0bc)

The sentinel seat attacked the frozen instruments after they were scored at the candidate. Under the rule that a frozen counter is not amended after scoring, the findings below are **named ceilings and routed defects**, not silent fixes. Full text: `.ufo/waves/round-45/build/K45Sentinel.md`.

- **S-07, HIGH (C1 forgery).** Raising the scope floor above the real landed rounds (39–44) to a value that skips them passes the counter: fixtures A and B use synthetic rounds 90 and 91, so a shrunk floor still detects them, and the REAL leg reads CLEAN on a tree with no omitted real rows. The counter has no leg that exercises a real round below the floor. Routed: round-46 counter amendment with a real-round planted omission (a copy of a landed round's plan with its row removed in scratch).
- **S-08, HIGH (C1 forgery).** Replacing the new direction with a pass-through that only reads the manifest is caught by fixtures A and B, so this shape is refused; the residual is the S-07 shape above.
- **S-09, HIGH (C1 forgery).** The REAL leg can be satisfied by editing the manifest registry rows rather than the gate. Ceiling named: the manifest is the lane's own record; a row removed together with its plan heading is not seen by any leg. Routed: a non-author bijection check against the landed SCORECARD post-move rows (already partly present) as a second leg.
- **S-10, HIGH (C2 forgery).** LOCATED is satisfied by any committed capture body whose sha256 is declared in `corpus/source-fetches.tsv`; the lane wrote both. The counter binds the quote to a body, not the body to the live page. Ceiling named: a re-fetch check of the body sha against the live page is the freshness path and is not counted this round. Routed: a live re-fetch leg for admitted rows at the next assimilation.
- **S-11, MEDIUM.** The located set is decoupled from the entry's own citations: the counter counts any added row with a located quote, not the rows the entry cites. In this round the two sets coincide (S100–S102); routed for the counter's next amendment.
- **S-12, MEDIUM.** The located quotes are not the entry's sentences. The entry's paraphrases (lifecycle scope, withdrawal date, amendment successor) are cited by row but not located. Ceiling named; the entry says so in its Gate section.
- **S-14, MEDIUM (renumber).** The landed ids S100–S102 collide with staged-reserved ids for other documents in `merge/kagi/SOURCES.append.md` (the staged package's own S100+ numbering). The renumber map is by document, and the package is not appended as-is; the collision is a standing note for any later adoption from that package.
- **S-13, LOW.** The M45-1 red witness is satisfiable by a coordinated edit of the stamp row and the file. Ceiling named; the stamp check verifies bytes, not authorship.
- **S-02, LOW.** Staged registry rows disclose local host paths; the lane's own rows do not (one pre-existing host path in `corpus/SOURCES.md` at line 131, an older search-log line, not touched this round).
- **S-04, LOW.** `op://` appears as a bare scheme in four wave artifacts (documentation text, no reference path). Recorded; no reference path, no secret.
- **S-01, S-03, S-05, S-06, INFO.** No secret-shaped material in the staged entries or in the round's artifacts; the three `1password` hits in staged rows are public vendor titles; captured vendor pages carry session and password identifiers, not values; no privileged, mutating or vault call anywhere in the wave.

Routed to round 46 (named): the S-07 real-round planted-omission leg; the S-09 non-author second leg; the S-10 live re-fetch leg for admitted rows; the S-11 cited-rows-only located set. Round 46's plan is the place for those amendments, before any round-46 scoring.
