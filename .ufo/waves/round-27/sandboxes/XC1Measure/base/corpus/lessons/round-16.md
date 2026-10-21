# Round 16 — adjacency: prose ownership becomes an enforced partition

Axis-move: **adjacency 8 → 9**. At the round-15 close three axes stood at 8
(depth, coverage, adjacency) and three at 9. Adjacency was the only 8 with **no
mechanical support at all**: it lived in three prose places (the
`corpus/README.md` overlap table, two `PROVINCE.md` refusals, one `mode = -`
census row) and no command could falsify any of them. The move gives the census
a partition with an owner, a claim, and a resolving citation per shared surface.

## 1. Pre-state, measured at `HEAD` `587fda0`

| Claim | Measurement |
|---|---|
| ownership is prose | 3 places named above; `ls corpus/*scope*` ⇒ nothing; no gate mentions `adjacency` |
| the overlap table's kake citation is stale | `sed -n '104,107p' kake-shokunin/SKILL.md \| grep -c musketeer` ⇒ **0** (that slice is `webzites status` exit-semantics text); the lease claim is `:161` ⇒ 1. `corpus/README.md:76` cited `104-107` |
| the census partitions nothing | 35 rows, 4 `# scan` directives, one `mode = -` row; no owner column, no group, no basis |
| the shared surfaces are unnamed | 8 of the 35 rows sit outside every domain-owned path: 4 under `~/.config/opencode`, 3 in the musketeer profile, 1 `~/.agents/AGENTS.md` |
| every other axis has a gate | depth → `op-ref-probe.sh`; coverage → `surface-census.sh`; freshness → `drift-pins.sh` + the `docs` audit; operability → 7 gates; calibration → `claim-ledger.sh` |

Tie-break, recorded because three axes were tied: depth is capped by an explicit
refusal (vault-side masking) that round 12 already re-measured; coverage's
remaining increment is enumeration breadth over *shared* dirs, which is an
ownership decision and therefore belongs to this move, not to coverage; adjacency
had no ceiling written and no gate.

## 2. What landed

- `corpus/adjacency.tsv` — 5 `# own` prefixes (27 of 35 census rows), 4 group
  rows covering the other 8, 4 `# owner` / 4 `# status` / 2 `# claim` /
  8 `# no-enumerate` directives. Columns
  `path owner status claim basis token note`.
- `corpus/scope-gate.sh` — `verify` (default), `--map`, `--selftest`,
  `--falsify`; rules R1–R11; verdicts `BAD-ROW`, `FOREIGN`, `ORPHAN`,
  `UNKNOWN-OWNER`, `BAD-VALUE`, `OWNER-MISMATCH`, `NOT-A-FILE`, `STALE-BASIS`,
  `BASIS-ESCAPE`, `OVERCLAIM`, `FOREIGN-SCAN`, `ESCAPE`, `INBOUND`,
  `UNVERIFIED`, `ENUM-CLASH`, `OWN-UNLISTED`; exit 0/1/2.
- `corpus/knowledge/adjacency-scope.md` (14 bounds), `corpus/README.md` overlap
  table + coverage map rewritten and machine-checked, `PROVINCE.md` gate
  registration, a SKILL.md decision-table row, six ledger rows `R16-01..06`.

Evidence on the shipped revision:

```
bash corpus/scope-gate.sh
  ADJACENCY_ABSTAIN: rows=1
  ADJACENCY_SCOPE: CLEAN (census=35 owned=27 shared=8 groups=4 owners=4
    unresolved=1 contested=1 escapes=0 inbound=0 foreign=0 orphans=0
    stale_basis=0 basis_escape=0 own_unlisted=0)                    exit 0, ~0.5 s
bash corpus/scope-gate.sh --selftest  ⇒ SCOPE_SELFTEST: PASS (43 cases)
bash corpus/scope-gate.sh --falsify   ⇒ SCOPE_FALSIFY: PASS (caught=9/9 failed=0)
bash corpus/scope-gate.sh --map       ⇒ 35 SCOPE_MAP: lines (27 owned / 8 shared)
```

## 3. Defects found by execution before commit

Nine in the gate itself, plus two in the verification harness that was supposed
to catch them — the harness defects are the more interesting half.

| # | Defect | Caught by | Symptom |
|---|---|---|---|
| 1 | `local rest="${cur#lane:}" lname="${rest%%/*}"` — bash word-expands the RHS before assigning under `set -u` | scribe lane (exact repro `bash -c 'set -u; f(){ local a=x b="${a}"; }; f'`) | every `verify`/`--map` run died at the `lane:` branch with **no verdict line**, exit 1 |
| 2 | `token_hits` defaulted the cited range to `1-1` when no `:N` was given | selftest (`clean` case) | 3× `STALE-BASIS` on a correct data file |
| 3 | selftest fixtures were mutated, not rebuilt | selftest | a symlink from case *n* leaked into case *n+1*: 11/29 false failures |
| 4 | R9 compared an owned row against its **own** prefix, and the prefix was resolved through the same symlink | reviewer (D2 precursor) | `escape-exact-file` stayed CLEAN after the anchor was symlinked away |
| 5 | a dangling symlink resolved "successfully" (`readlink -f` canonicalizes a non-existent leaf) | selftest | CLEAN on a path whose target did not exist |
| 6 | `--falsify` was defined but never wired into the parser or the dispatch | scribe lane | `unknown argument: --falsify`, exit 2 — dead code at every revision it observed |
| 7 | `--falsify`'s own copies appended to files that **have no trailing newline** | `--falsify` run 1 | 3 of 5 mutations merged into the last row and silently no-opped |
| 8 | `mutate_case` counted successes but not failures | `--falsify` run 2 | summary printed `PASS (caught=7/7)` while a `FALSIFY FAIL` line sat above it — the repo's own "verdict swallowed" class, inside the verification tool |
| 9 | the EXIT trap in `falsify()` referenced a function-local `R` | `--falsify` run 2 (stderr) | `line 1: R: unbound variable` after the function returned |

Design changes forced by the wave, each from an executed counterexample:

- **R10's third clause** (reviewer D2, sentinel S2, mutation M13): `# own
  $HOME/.local/bin` produced a *byte-identical* CLEAN summary while covering 105
  foreign children. Fixed by refusing an `# own` prefix that sits over a
  `# no-enumerate` dir.
- **R11** (sentinel S2): the same creep one level up (`# own $HOME/.local/state`,
  13 unclaimed children) is now `OWN-UNLISTED` because ownership must name a
  declared, enumerated surface. This is the guard that turned `# own
  $HOME/projects` from a documented bound into a caught mutation.
- **R6 containment** (sentinel S1): `basis` had no containment check, so
  `lane:kake/../../priv/secret.env:1` — or `../../.config/the-janitor/op.env`
  from the repo root — was `sed`-read and turned the verdict into a boolean
  oracle over private bytes. Now `BASIS-ESCAPE`, and the root is compared through
  `resolve_anchor` so a symlinked lane checkout cannot move with the file.
- **Literal vocabularies** (mutation M19): the closed sets were *self-declared*
  by directives, so an edit could widen the vocabulary without a code review. The
  script now holds the literal sets and the directives must agree.
- **`OWNER-MISMATCH`** (mutation M20): a row could claim `owner=kotoba` and cite
  `lane:kake/…`. Now a `lane:` basis must name the row's own owner (unless the
  row is `unresolved`, where the arbiter is not the owner).
- **Field-overflow guard** (mutation M03/M16r, distiller, simplifier): a row with
  an 8th column, or a *fused* line, was absorbed into `note` silently. Now
  `BAD-ROW`; the same guard covers a duplicate census row.
- **`ADJACENCY_ASSET_ABSENT`** (planner): absent rows were all silently
  exit-neutral, including `asset` rows whose absence is the census's `GONE`
  claim. Now named separately, still exit-neutral, never silent.
- **`ADJACENCY_SCOPE: SETUP`** (mutation M12, distiller contradiction 4): a
  missing data file died with exit 2 and **no** terminal line, while the
  broadcast contract promised one. It now prints a terminal `SETUP` line.

## 4. The L2 wave (14 lanes, one batched dispatch)

| lane | what it produced | disposition |
|---|---|---|
| planner | R2 is classification, not a guard (no input can violate it alone); R9's absent-row abstention needed a runtime-only reading; token ranges match ANY cited line | all three landed (R2 labelled, `ASSET_ABSENT`, range semantics documented) |
| connector | no sibling implements a host-path ownership map with a fail-closed foreign-claim gate; kake is the adjacent beneficiary; `README.md:76`'s citation resolves to text but not to the lease claim | kept as adjacency evidence; nothing absorbed |
| scout (sibling) | the four landed bases resolve; the *pre-delta* NMH basis matched a **launcher line** (`(musketeer-chrome &)`) — the README:76 decay caught in the act; `.config/opencode` has 4 fleet claimants and no recorded owner | NMH row re-based on the round-8 lesson with owner `kagi`; the launcher case became bound 6 |
| scout (host) | no ESCAPE/INBOUND can fire today; 0 symlinks in the declared set; **both data files lack a trailing newline**; `~/.local/bin/musketeer-chrome` (kake) and the profile's `SingletonSocket` are symlinks R9 cannot see | newline class landed in the entry and in `--falsify`; the two symlink classes recorded as bounds |
| exec (gate) | a full implementation draft with its own defect log | superseded by the merged implementation; its defects matched mine |
| exec (data) | independent partition derivation, identical on every field; 3-prefix variants are CLEAN while claiming 116 foreign children | Q1 confirmed the creep class; the variant numbers are recorded as the reason R10/R11 exist |
| scribe | entry + lesson drafts in the register of the existing entries; found the unwired `--falsify` | drafts landed with corrections; the wiring was fixed |
| reviewer | all counts reproduced; D2 (creep) proved; double-counting advice: pin `owned/shared/groups/owners` in a row and treat `census=35` as a cross-check | `R16-01` pins the partition; `R11-11` keeps the row count |
| critic | CE-A1: invented foreign census row + invented group row ⇒ CLEAN (ownership truth is not establishable); CE-C: a foreign symlink below an owned non-scan dir ⇒ CLEAN; the exact stale kake citation ⇒ `STALE-BASIS` | CE-C closed by R11; CE-A1 recorded as bound 1; the citation case became `--falsify` mutation 1 |
| sentinel | S1 basis traversal (private-byte oracle), S2 creep, S3 token echoed | S1 → `BASIS-ESCAPE`; S2 → R10/R11; S3 → token hygiene rule |
| labrat | safe prefix idiom; `realpath -m` fail-open; `uniq -d` on empty input exits **0**; timing 0.48–0.52 s | idiom landed; `-m` never used; the `uniq -d` claim corrected (see §6); timing recorded as "sub-second only at this size" |
| mutation | 25 mutants, 14 killed at that revision; survivors listed with reasons | every survivor except the token-relevance bound is now caught (`BAD-ROW` overflow, `UNOWN-OWNER` self-declared sets, `OWNER-MISMATCH`, `OWN-UNLISTED`, duplicate census row, `SETUP` line) |
| simplifier | DELETE/KEEP/MERGE: no production rule should be deleted; literalize the status/claim sets; keep a separate gate this round | literalization landed; the merge proposals recorded as open (a `--scope` mode of `surface-census.sh` would save a file but cost an independent exit/verdict line) |
| distiller | 13 reports read, 19 unique moves, 4 explicit contradictions, 1 evidence-free claim (the lesson TODOs) | contradictions adjudicated one by one; the TODOs are gone from the landed docs |

## 5. Bounds

`corpus/knowledge/adjacency-scope.md` §Bounds carries the full list (14). The
three that decide the score: ownership is a governance fact, so an *invented*
ownership declaration with a token-matching citation still passes (the gate
checks completeness and self-consistency, not truth); `token` is a floor, not a
relevance proof (the launcher-line counterexample); and nothing schedules the
gate. Two live findings are reported rather than absorbed: kake's
`~/.local/bin/musketeer-chrome` launcher symlink sits inside the shared bin dir,
and the contested profile subtree contains a `SingletonSocket` symlink that
leaves `$HOME` — R9 sees only census rows, and the census cannot declare a
symlink without reporting `LINK`.

## 6. Corrigendum to round 15 (measured, not inferred)

`corpus/lessons/round-15.md` attributes the first silent death partly to
"`uniq -d` exits 1 on an empty result". Measured on this host (GNU coreutils
9.x): `printf '' | sort | uniq -d` ⇒ exit **0**, and `printf 'a\nb\n' | uniq -d`
⇒ exit 0. The class is real — the loop's final iteration status and
`grep -v … | tail -1` under `pipefail` (⇒ exit 1 when everything is filtered)
both kill the script — but the **attribution was wrong** and would point a
future fix at the wrong line. Corrected in place with a pointer, and recorded in
the round-16 scorecard's calibration cell.

## 7. Competing readings, kept rather than smoothed

- The planner and the simplifier both proposed collapsing R2 into R3/R4; kept as
  a labelling fix (R2 is the classification) because deleting it loses the place
  where longest-match coverage is specified.
- The critic's CE-A1 is unanswerable by design and is written as bound 1 rather
  than papered over: a partition gate can check that a claim is *declared and
  consistent*, never that it is *true*.
- The executor's Q1 measurement (a 3-prefix file passing CLEAN while claiming 116
  foreign children) predates R10/R11; it is retained as the reason those rules
  exist, not as a live counterexample.
- The distiller's four contradictions: two are now resolved by rule (missing-file
  terminal line; owned-set vs owning-prefix wording), one is a bound
  (`unresolved` vs per-file partition), one is open (documented prefix-ceiling
  versus enforced guard — closed for `# own`, still open for an over-broad census
  row).