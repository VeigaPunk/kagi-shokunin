# Entry02 — `corpus/knowledge/adjacency-scope.md` freshness / calibration audit

Seat: `KagiR22.Entry02` (read-only scout, leaf). Axes: **calibration** and **freshness**.
Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD` at read time,
2026-10-20). Audited paths were unmodified in the worktree (`git status --porcelain` shows no
entry for either); other dirty paths in `git status` are concurrent lane work, not this seat.

Targets:

- artifact `corpus/knowledge/adjacency-scope.md` — live `sha256sum` `45ced1ed96ff888d71b392ba40357d02e20ed0c2e1d005e9d943374d8d5c0284`, `312` (-l) / `21973` bytes, blob `f65fd38fb8fe2957176ed71ba347fe3460cd53bf`, last changed `bc1af88`.
- stamp row `corpus/stamps.tsv:10` — `corpus/knowledge/adjacency-scope.md	45ced1ed96ff888d71b392ba40357d02e20ed0c2e1d005e9d943374d8d5c0284	312	21973`.
- ledger identity: `corpus/stamps.tsv` live hash `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b` = the frozen `expected.json` input value; `63` rows; no duplicate path; all `24` `corpus/knowledge/*.md` have a row.

## 1. Verdict

**Byte level: NO stale-byte mismatch.** All three stamped columns match exactly. The row is
identical to the frozen pre-measurement copy (`.ufo/waves/round-22/frozen/before/corpus/stamps.tsv`)
and `adjacency-scope.md` is not in `before.json`'s six stale stamps
(`config-layering.md`, `handler-on-disk-state.md`, `handler-trust-boundary.md`,
`janitor-env-contract.md`, `lessons/round-18.md`, `LOG.md`). `git log -S'corpus/knowledge/adjacency-scope.md' -- corpus/stamps.tsv`
returns only `8a6ec16` (introduction); the row was re-pinned once (`bc1af88`) and never removed.

**Substantive level: STALE at a byte-fresh revision.** The stamp is honest about *which bytes*
were read; it says nothing about whether those bytes still describe the host or the stamped
script. Six claim-level defects survive the exact pin (F1–F6 below). This is the C2 class the
scorecard has carried since round 18: a correct hash is not a current fact (QUALITY.md QM14:
"a fresh hash does not make historical source facts current").

**Correction: yes — one appended erratum is required**, because F1 (dead resolution base) and
F3 (child counts stated in the present tense) are wrong independently of any host-regate, and
F2 (`Current gates:`) presents a 2026-09-29 run as current. The correction must be append-only
and must land with an atomic re-stamp; the original bytes (1–21973) are not rewritten.

**Calibration metric (decisions, not authored rows):** 13 claim-level decisions —
**7 confirmed, 3 stale, 1 dead-anchor, 1 unverifiable, 1 partial**. Plus one parent-premise
correction (the "nine dropped stamps", §3). No row was authored or edited by this seat.

## 2. Evidence table

Checks are read-only. Static checks use the live files at the frozen revision; host checks are
direct `find`/`test` reads, not gate executions.

| # | claim (locator) | check | observed | verdict |
|---|---|---|---|---|
| 1 | stamp sha256 (`stamps.tsv:10`) | `sha256sum corpus/knowledge/adjacency-scope.md` | `45ced1ed…5c0284` | **OK** |
| 2 | stamp lines / bytes | `wc -l -c` | `312` / `21973` | **OK** |
| 3 | partition 27 owned / 8 shared; groups `4/1/2/1` (table, lines 20–26) | independent longest-prefix re-derivation over `adjacency.tsv` + `surface-census.tsv` (Python, text-prefix semantics) | `owned 27`, `shared 8`, coverage `4/1/2/1`, `uncovered []` | **OK** |
| 4 | directive counts 5 own / 4 groups / 4 owner / 4 status / 2 claim / 8 no-enumerate / 4 breadth (lines 3–9) | the doc's own grep recipes | 5 / 4 / 4 / 4 / 2 / 8 / 4 | **OK** |
| 5 | census 35 rows / 4 `# scan` / `mode` column (line 6) | `grep -vc '^#'`, `grep -cE '^# scan'`, header read | 35 / 4 / present | **OK** |
| 6 | both data files end without newline (line 311–313) | `tail -c 1 … \| od -c` | `e`, `)` — neither is `\n` | **OK** |
| 7 | `kake-shokunin/SKILL.md:104-107` ⇒ 0; `:161` ⇒ 1 (lines 36–42) | `sed -n … \| grep -c musketeer`; sibling repo present | 0 / 1 | **OK** |
| 8 | "`lane:` resolves under `~/projects/shokunin/<lane>-shokunin/`" (line 92) | `grep -n 'LANE_ROOT="' corpus/scope-gate.sh`; `-d ~/projects` | script line 91 derives `$SCRIPT_DIR/../..`; `~/projects` absent, `~/Projects/shokunin` present | **STALE (F1)** |
| 9 | "`$HOME/.local/bin` holds 105 children … other 103" (lines 56–57; repeated at 308–309) | `find ~/.local/bin -mindepth 1 -maxdepth 1 \| wc -l` | 50 direct children; both owned paths (`the-janitor`, `tac-check`) absent ⇒ 50 unowned | **STALE (F3)** |
| 10 | "Current gates: `ADJACENCY_SCOPE: CLEAN (… breadth_* =0)`" (lines 11–18; Evidence 295–299) | static derivation from R13 + read-only child counts; SCORECARD round-18 carried-debt row | pins 20/105/4/53 vs live 3/50/3/absent; `ADJACENCY_SCOPE: DEFECT` already recorded as the correct round-18 output | **STALE (F2, derived)** |
| 11 | `Reverify: R16-01 … R17-03` (line 19) | tag lookup in `claim-ledger.tsv`; `substrate_present()` predicate | 3 of 9 tagged `[substrate]`; `~/.local/bin/the-janitor` absent ⇒ `substrate_present()` false | **UNVERIFIABLE / DEFER (F4)** |
| 12 | historical `corpus/README.md:76` / `:161` anchors (lines 36–42) | `wc -l corpus/README.md`; `sed -n '76p'` | README is 118 lines; `:161` out of range; `:76` is an unrelated table row | **DEAD-ANCHOR (F5, low)** |
| 13 | "`grep -oE 'run_case …'` names them" for 61 cases (line 114) | `grep -oE 'run_case [a-z0-9-]+' \| wc -l`; count `cases=$((cases…` increments | 56 named + 5 harness/mode cases = 61 | **PARTIAL (F6, nit)** |

Additional confirmed constants: `total=18` in `--falsify` (`scope-gate.sh:677`); the
`ADJACENCY_SCOPE` field list in the doc matches `scope-gate.sh:641-651` token-for-token and in
order; `SCOPE_SELFTEST`/`SCOPE_FALSIFY` format strings match lines 1121/805. `corpus/scope-gate.sh`
itself is also byte-current against its stamp row (`078a2601…`, 1129 lines, 55002 bytes), so the
doc's claims about the script are claims about the stamped script, not a drifted one.

## 3. The "nine previously dropped stamps" — bounded cross-check (C2)

This file's row is **not** one of them. The class is also misnamed in the parent premise, and the
exact evidence is already in the round-22 artifacts:

- `git log --numstat -- corpus/stamps.tsv` at `c41af82` (round-21) shows **16 added / 9 deleted**.
- The nine deleted **lines** name `claim-ledger.tsv`, `knowledge/op-ref-consumption.md`,
  `op-ref-probe.sh`, `README.md`, `LOG.md`, `PROVINCE.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`
  — i.e. nine *re-pinned records*, not nine vanished members.
- Path-set diff `c41af82^` → `c41af82`: additions only (7 new members), **zero removals**.
- `.ufo/waves/round-22/round21-migrations.json` carries exactly those nine in
  `changed_stamp_records` with old and new rows, `removed_members: []`, and the interpretation
  that "nine deleted lines in diff, not nine lost stamp members."
- Frozen base → live: stamps sets are identical (`63` rows), and `stamps.tsv`'s hash equals
  `expected.json`.

So no restoration is owed for this class, and `adjacency-scope.md` was untouched by it. The
parent's C2 phrase should be re-stated as "nine re-pinned records (nine deleted lines)", or the
migration record cited as the reconciliation. This seat does not adjudicate the other stamp
members.

## 4. Absent-source limits

1. **No host gate was executed** (seat contract). No live `ADJACENCY_SCOPE`, `--breadth`,
   `--selftest`, `--falsify`, `claim-ledger verify`, or `docs` verdict is claimed. F2 is a
   *derivation* from the stamped R13 rules plus measured counts, labelled as such.
2. **Substrate absent**: `~/.local/bin/the-janitor` and `~/.local/bin/tac-check` do not exist;
   `substrate_present()` is false, so `R16-01`, `R16-03`, `R17-01` DEFER rather than run. They
   cannot discharge the `Reverify:` line on this host.
3. **Host drift measured but not gate-adjudicated**: `~/.config/opencode` 3 (pin 20),
   `~/.local/bin` 50 (pin 105), `~/.agents` 3 (pin 4), `~/.local/share/the-musketeer/chrome-profile`
   absent (pin 53), `~/.local/state` 16 (evidence bullet says 15). The two owned `state` subtrees
   are absent.
4. **Case-sensitive path**: lowercase `~/projects` is absent; `~/Projects/shokunin` exists. The
   reproduction block correctly uses `~/Projects` (line 252); only the schema sentence at line 92
   is wrong.
5. **Sibling repo**: `kake-shokunin` present; both cited slices still reproduce (0 / 1).
6. **Historical replay**: the round-16 pin (`8a6ec16`: `21758e40…`, 303 lines, 21149 bytes) is
   available only through git; the round-17 diff (`bc1af88`) changed line 11 from
   "Gates observed this round:" to "Current gates:" — the current-tense wording is a round-17
   edit, not a round-16 inheritance.

## 5. Proposed correction — appended erratum (exact scope, no rewrite)

Append after line 313 (the file's last byte is `.` with **no trailing newline**; the append must
start with `\n` or the heading fuses into the last sentence). Nothing above is edited.

Qualified original ranges: **11–18** (the `Current gates:` sentence), **19** (`Reverify:`),
**56–57** and **308–310** (child counts), **92** (`lane:` base), **295–299** (`--falsify`
evidence and the CLEAN claim).

Proposed text:

```markdown
## Historical-source erratum — round-22 pin audit (2026-10-20)

Source-status: historical — the counts and verdicts above were measured on the
2026-09-29 host. The revision preserved by this pin is sha256
`45ced1ed96ff888d71b392ba40357d02e20ed0c2e1d005e9d943374d8d5c0284`
(312 lines, 21973 bytes). Every count and verdict above is preserved verbatim,
not re-asserted as current.

1. The `lane:` base at line 92 is wrong independently of host drift: the stamped
   gate derives `LANE_ROOT` from `$SCRIPT_DIR/../..`
   (`corpus/scope-gate.sh:91`), i.e. `~/Projects/shokunin`; a `lane:` basis
   resolves as `<LANE_ROOT>/<lane>-shokunin/<path>`. Lowercase `~/projects`
   does not exist on this host (case-sensitive).
2. "Current gates: CLEAN" is the 2026-09-29 reading. A read-only child count on
   2026-10-20 measured `~/.config/opencode` 3 (pin 20), `~/.local/bin` 50
   (pin 105), `~/.agents` 3 (pin 4), and the chrome-profile root absent
   (pin 53); `~/.local/state` is 16 (evidence said 15). R13's rules compare live
   counts to pins, so those four roots would yield child drift and a
   host-missing root, not CLEAN. No gate was executed in this audit; that
   outcome is a derivation from the counts and the stamped rule, not a run.
3. The reverify ids `R16-01`, `R16-03` and `R17-01` carry the `[substrate]` tag
   in `corpus/claim-ledger.tsv`. With `~/.local/bin/the-janitor` absent,
   `substrate_present()` is false and those rows DEFER; they cannot discharge
   the `Reverify:` line until the substrate returns and the four breadth pins
   are re-measured in a reviewed commit.
4. The `--falsify` result at lines 298-299 measures live child counts in two
   breadth mutations (the `R16-03` ledger note says so); only `--selftest` is
   scratch-hermetic. Neither was run in this audit.
5. The historical anchors `corpus/README.md:76` and `:161` (lines 36-42) no
   longer address the cited text: the README is 118 lines, so `:161` is out of
   range and `:76` is an unrelated table row. The narrative and its round-16
   correction are preserved, not re-verified.

Re-verification requires `bash corpus/scope-gate.sh` (and `--breadth`,
`--selftest`, `--falsify`) on a restored host or after a reviewed re-pin, then
`bash corpus/claim-ledger.sh verify`. No CLEAN verdict, child count or reverify
result in this entry is currently claimed.
```

Do **not** add a new claim row: the erratum changes no testable assertion, and the nine
`Reverify:` ids stay as historical pointers. Do not touch the frozen
`.ufo/waves/round-22/frozen/before/` inputs.

## 6. Append-only preservation and re-stamp requirement

1. Original bytes 1–21973 (lines 1–313) are preserved verbatim; only an addition after EOF.
   The old sha `45ced1ed…` is recorded **inside** the erratum, so the historic revision identity
   survives replacement of the ledger row; it also survives in git at `bc1af88`.
2. Because the file changes, `corpus/stamps.tsv` must be regenerated **in the same commit**
   (QUALITY.md QM5: artifact + stamp + claim row together; `docs` reports `UNPINNED` otherwise).
   `stamp` replaces the whole row set, so it must be given every existing path — running it with
   only this path dies on the shrink guard:
   ```bash
   mapfile -t P < <(cut -f1 corpus/stamps.tsv)
   bash corpus/claim-ledger.sh stamp "${P[@]}"
   ```
   `63` rows in, `63` rows out; **`--prune` must not be used**. Re-read the new row and confirm
   `sha256sum` / `wc -l -c` equal its three columns.
3. Record the migration (QM14) in the round-22 migration record (extend
   `.ufo/waves/round-22/historical-migrations.json` or a sibling file) with:
   `path`, `old` = the exact row above, `new` = the regenerated row, and the motivating
   correction (F1–F4 + this audit's locators). QM14 explicitly rejects silent expectation
   rewrites and fresh hashes that launder historical facts.
4. Run `bash corpus/claim-ledger.sh verify` and `bash corpus/claim-ledger.sh docs` before commit
   (parent, after integration). Expected: no `STALE` line for this path; `docs` `unpinned=0`.
   The erratum does not authorize re-running the host gate or un-deferring the three
   `[substrate]` rows.

## 7. Exact proposed recheck scope (after integration)

Static, substrate-free (safe anywhere):

1. `sha256sum corpus/knowledge/adjacency-scope.md`; `wc -l -c`; compare the new row's three columns.
2. `git diff bc1af88 -- corpus/knowledge/adjacency-scope.md` — the only `-` lines may be the
   diff header; any removed content line is a rewrite defect.
3. `git log -S'corpus/knowledge/adjacency-scope.md' --oneline -- corpus/stamps.tsv` — must show
   the introduction plus the new re-pin only, no removal.
4. The nine declaration counts of §2 rows 3–5, unchanged.
5. `grep -n 'LANE_ROOT="' corpus/scope-gate.sh` must still read `$SCRIPT_DIR/../..`; the erratum's
   line 92 correction must agree with it.
6. `grep -oE 'run_case ' corpus/scope-gate.sh | wc -l` = 56; selftest `cases` arithmetic = 61.

Host observations (read-only; no gate):

7. Four `find -mindepth 1 -maxdepth 1 | wc -l` counts and `[ -e chrome-profile ]`; if the host
   has been restored, the counts may return to 20/105/4/53, which would make the erratum's
   numeric paragraph itself outdated — the erratum is dated, so that is acceptable, but a
   later round must re-measure rather than copy these numbers forward.
8. `[ -x ~/.local/bin/the-janitor ]` — governs whether the three rows still DEFER.

Gate-dependent (**authorized parent only**, not this seat):

9. `bash corpus/scope-gate.sh` — if pins are still the 2026-09-29 ones, expect `DEFECT` with
   `BREADTH-CHILDREN-DRIFT` (three roots) and `BREADTH-HOST-MISSING` (chrome-profile);
   do not record it as a pass, and do not re-pin to the shrunken host without a motivating
   migration record (SCORECARD round-18 kept the old pins deliberately).
10. `bash corpus/scope-gate.sh --breadth` — same drift, `BREADTH_AUDIT: DEFECT`.
11. `bash corpus/scope-gate.sh --selftest` — expected `PASS (61 cases)`; scratch-tree, hermetic.
12. `bash corpus/scope-gate.sh --falsify` — expected `PASS (18/18)` only where the live-count
    mutations hold; currently not presumed.
13. `bash corpus/claim-ledger.sh verify` — expect `DEFER` for `R16-01`, `R16-03`, `R17-01`
    (substrate absent) and no `STALE` for this path.
14. `bash corpus/claim-ledger.sh docs` — expected `unpinned=0`, `entries=24`.

## 8. Confidence and remaining unknowns

- **High confidence (observed):** stamp-byte equality; partition/directive/census counts;
  trailing-newline facts; kake slices; lowercase-`~/projects` absence; script-derived
  `LANE_ROOT`; substrate absence; four live child counts; nine-deleted-lines accounting.
- **High confidence (static derivation):** `--falsify`'s live-count dependence; 56/61 case
  naming; `Current gates:` not reproducible (R13 comparisons cannot pass with 3≠20, 50≠105,
  3≠4, and an absent root).
- **Unknown / not adjudicated:** whether the parent chooses to land the erratum this round or
  record it as carried debt; whether other stamp consumers key on this path's hash; whether the
  host changes between this read and integration; whether any *other* historical claim in the
  doc (e.g. the `D-96` correction at lines 74–80) has a decaying citation not covered by the
  listed checks. Those are outside this seat's assigned question.

## 9. Installs

None. No package, uv, npm, cargo, or binary install/update was performed.

---

Report path relative to `/home/vgpnk/Projects/shokunin/kagi-shokunin`:
`.ufo/waves/round-22/build/Entry02.md`. Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
