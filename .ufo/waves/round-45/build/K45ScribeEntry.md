# K45ScribeEntry — round-45 scribe report

Seat: scribe (wave `kagi-r45-build`, attempt 1, 11 seats). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, HEAD at the predeclaration commit `307fb50da825d6e6f2b5c7981c71556d35611142`; claim BASE `0d0192f63eb5e49826d75af1e5293004dc691a18`. No candidate existed when this seat ran.

## Behavior

Drafted the round-45 lesson prose and the closure errata as placeheld documents for the L1 to verify and place. Prose only; every measured number I did not take myself is a `{NAME}` placeholder.

**Delivered (write scope respected — only `.ufo/waves/round-45/build/K45ScribeEntry*`):**

- `.ufo/waves/round-45/build/K45ScribeEntry/lesson-draft.md` — sections `## Claims` (C1, C2, frozen predicate sentences verbatim from `plans/round-45.md`, `{VALUE_C1}` / `{VALUE_C2}` for the measured values), `## Gate` (per-source table: URL, access date 2026-11-05, ≤25-word located quote, `{OFFSET_*}` placeholder), `## Mistakes` (table id|class|evidence|captured-by|fix; class names drawn from `mistakes.md` §5 vocabulary; M45-1 = `landing`/D2 plus mapping rows M45-2…M45-7 for round-44 classes M44-2, M44-4, M44-5, M44-7, M44-8, M44-9 with the round-44 prose kept in the fix column), `## Errata` (E45-1, E45-2), `## Routed` (B1, round-40 erratum, revenger SEAT-STATUS, controls-replay scheduling, D4/D5 dispositions, plus S099 tier reservation and carried L0 lines), `## Frontier`, `## Assimilation` (`{ADMITTED_ENTRY_PATH}`), `## considerthese` (proposal 3, drafted QM55 text grounded on the S052 row), `## Leads (unopened)` (bullets moved from the round-44 lesson's rejected list).
- `.ufo/waves/round-45/build/K45ScribeEntry/errata-draft.md` — E45-1 and E45-2 as append-only correction entries.
- `.ufo/waves/round-45/build/K45ScribeEntry/receipts.txt` — exact commands, exit codes and last output lines.
- `.ufo/waves/round-45/build/K45ScribeEntry.md` — this report.

**Placeholders.** Every placeholder is written as `{NAME}` so the L1 can find it; the full set is greppable as `{[A-Z0-9_]+}` across the two drafts. The names are: `{VALUE_C1} {VALUE_C2} {LANE_ID_1999} {LANE_ID_2015AMD1} {LANE_ID_2021} {LANE_ID_2021AMD1} {OFFSET_1999} {OFFSET_1999_B} {OFFSET_2015AMD1} {OFFSET_2015AMD1_B} {OFFSET_2021} {OFFSET_2021AMD1} {REGISTRY_ROWS_APPENDED} {CENSUS_VERDICT} {CENSUS_RC} {QUARANTINE_VERDICT} {COLLISION_GUARD_RECEIPT} {ERRATUM_LANDED} {ERRATUM_E45_1_STATUS} {ERRATUM_E45_2_STATUS} {D4_STATUS} {D5_STATUS} {S099_TIER_STATUS} {ADMITTED_ENTRY_PATH} {ASSIMILATION_STATUS} {QM55_STATUS} {ERRATA_PLACEMENT_PATH} {ERRATA_COMMIT}`. No curly-brace token in either draft is unmarked, and none is left as an unfilled literal.

## Gates run by this seat

Only the checks my item names, plus the read-only measurements the lesson's prose asserts. No lane gate, counter, self-count or claim-ledger verify was run.

| check | command | rc | last line |
|---|---|---|---|
| stamp drift, unaltered BASE | `python3 .ufo/waves/round-45/build/K45ExecStampRW/stamp-drift.py $S/base-clean` (archive of `307fb50`) | 0 | `STAMP_DRIFT: rows=123 drift=0` |
| stamp drift red witness | same script on the same archive after `printf 'X' >> $S/base/LOG.md` | 1 | `DRIFT LOG.md` (rows=123 drift=1) |
| stamp drift, live lane tree | same script on the lane | 1 | `DRIFT corpus/SOURCES.md` |
| S170 independent re-open | `timeout 40 curl -fsSL --max-time 35 'https://web.archive.org/web/20260212133408id_/https://www.iso.org/standard/60237.html'` | 28 | `curl: (28) Connection timed out after 35001 milliseconds` (`http=000 bytes=0`) |
| gate presence at round-44 BASE | `git cat-file -e d54109d:corpus/controls-replay.sh` | 0 | present (rc 0) |
| knowledge gap | `grep -l '11770' corpus/knowledge/*.md \| wc -l` | 0 | `0` |
| sources census | `bash scripts/sources-census.sh validate --file corpus/SOURCES.md` | 0 | (no output) |
| quote spans in the executor's raw captures | byte scan of `S159/S171/S172/S173.raw` | 0 | 6 spans located (offsets in receipts) |
| proposal-3 exemplar probe | `git show 5e84747:corpus/release-clock.py` vs `fc65112:…` + regex match probe | 0 | old `$` anchor → `None` on `Python 3.15.1.`; current boundary → `3.15.1` |

## Touched surfaces

Written: `.ufo/waves/round-45/build/K45ScribeEntry/lesson-draft.md`, `.../errata-draft.md`, `.../receipts.txt`, `.ufo/waves/round-45/build/K45ScribeEntry.md`. Scratch (created and removed): `/fast/scratch/hyaku/kagi-r45/K45ScribeEntry/{base,base-clean}` — two `git archive` extractions of the lane at `307fb50`, used only for the stamp-drift red witness; both removed before exit. Nothing else was created or modified. `git status` in the lane shows only the pre-existing `M corpus/SOURCES.md` (another seat's uncommitted staged-lead bullet, present before this seat ran) plus untracked wave dispatch files. No `git add/commit/stash/checkout/switch/reset/pull/push` and no mutating `jj` command was run, in the lane or the fleet.

## Out of scope (not done, deliberately)

- No lane file edited: `corpus/`, `plans/`, `SCORECARD.md`, `LOG.md`, `SHONEN.md`, `corpus/QUALITY.md`, `corpus/SOURCES.md`, `MANIFEST.json`, the fleet root `templates/` or `scripts/`, `.ufo/state`, `.ufo/watchdog.log` — all read-only. The lesson, the errata, the QM55 text, the registry rows and the knowledge entry are **drafts for the L1 to place**, not landed.
- The lane's full claim-ledger verify and self-counts were not run (host-heavy, and the brief forbids them).
- No staged package file was adopted or copied: `/home/vgpnk/Projects/shokuknow/merge/kagi` was read only.
- No secret, token, cookie, vault field or `op://` path was read, printed or written; no account, 1Password, op or the-janitor was contacted; the only network reads were public web pages (the IEC webstore pages, already fetched by the executor seat, and one archive.org retry of a public ISO catalogue snapshot).
- No host sysctl, service, user, package or kernel setting was touched; **pacman was not run** (host-wide pause). No tool was installed or upgraded by this seat, so there is no tool/version/channel/reason to record.

## Findings

1. **C2's sourced-claim kill rule bites on staged S170.** The executor seat's fetch of the ISO catalogue snapshot (staged id S170) timed out; the scribe's independent retry failed the same way (`curl` rc 28, `http=000`). Under the frozen C2 kill rule — "an admitted entry cites a staged id that was not re-opened this round" — the staged file `iso-11770-3-catalogue-record-and-lifecycle-r41.md` (which cites S170–S173) **cannot be adopted unmodified**; the admitted entry must cite only re-opened ids (S159, S171, S172, S173). The Gate draft says so explicitly and records the failed fetch with its error text rather than dropping it.
2. **The Chinese adoption link is not established this round.** The plan's C2 problem statement names "its adoption by GB/T 17901.3", but the SAMR record for GB/T 17901.3-2021 (staged id S148) was **not** re-opened this round, so it cannot be cited under the same kill rule. The lesson's Frontier and Leads sections say so; the adoption link is a lead, not a claim of this round.
3. **The plan's QM55 exemplar is dated, not live.** The plan describes the defect as "`corpus/release-clock.py` $-anchored tokens". Measured: the `$` anchor is the state at `c49023b`/`5e84747`; round 29 (`fc65112`, 2026-11-01) replaced it with the S052 right boundary, so at BASE the clock **extracts** `Python 3.15.1.` as `3.15.1` (probe in receipts). The qualifier mechanism itself is still absent (`grep -c KNOWN_DEFECT corpus/release-clock.py` → 0). The drafted QM55 therefore states the standing quoting rule with the 2026-10-26 defect as a dated exemplar, and says so in a measured note, so the criterion is true at landing rather than resting on a closed defect.
4. **The stamp-drift red witness has a live-tree artifact.** The committed predeclaration tree reads drift 0; the **working tree** reads drift 1 on `corpus/SOURCES.md` only, because that file carries an uncommitted edit made by another seat before this seat ran. The lesson's M45-1 fix proof cites the committed-tree reading and the scratch red witness, not the working tree.
5. **The C1 pre-candidate evidence is scratch-only.** The executor seat's patched `corpus/claims-declared.sh` reads MISMATCH on fixtures A, B and C with the real tree CLEAN — the frozen predicate's shape — but the patch lives in the executor's scratch tree; the lane's `corpus/claims-declared.sh` is untouched. The lesson states the landed C1 value as `{VALUE_C1}` and labels the scratch reading as pre-candidate evidence, not as the claim.
6. **The executor's fixture C reports two mismatches for one planted claim** (the existing axis check plus the new no-manifest-row check), because the fixture's manifest row's axis deliberately differs from the plan heading. Still rc 1, so the counter's positive control is unaffected; recorded here so the L1 knows the reading is two lines, not one.
7. **The staged-id collision set is 48 ids, not 47.** The lane registry holds S001–S099 and the staged package holds S052–S223; the intersection is S052–S099 (48 ids, all with different URLs). The scout seat's `collisions` file agrees. The four staged ids re-opened this round sit above the held range, so the collision grep does not fire on them; the by-document assignment to S100+ is still the plan's contract and is left to the L1.
8. **Round-44's own erratum is still owed** (the in-place amendment of `.ufo/reports/round-40/kagi.md` at `14f47bcd`); it is named in §Routed and is not this round's to place.
9. **S099's tier reservation is live.** S099 is tier A `own-work` for a sentence present in 742 committed prompts; the round's registry touch is the moment to justify or re-tier it. Named in §Routed with `{S099_TIER_STATUS}`.

## Artifacts

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-45/build/K45ScribeEntry/lesson-draft.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-45/build/K45ScribeEntry/errata-draft.md`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-45/build/K45ScribeEntry/receipts.txt`
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-45/build/K45ScribeEntry.md` (this report)
- Scratch (removed): `/fast/scratch/hyaku/kagi-r45/K45ScribeEntry/`
