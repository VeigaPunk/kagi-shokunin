# ScoutHost — round-30 per-surface reconnaissance (host state + gates)

Seat: ScoutHost (leaf). Lane: `kagi-shokunin`. BASE `f67232cd3ae682ea1fb14d447667016f2b6ed336`
(plan commit `b7482b4`). All work read-only against the lane; every experiment ran in
`/fast/scratch/hyaku/kagi-r30/ScoutHost/` (trees built with `git archive`, never a clone of the
lane into a build dir). No lane git/jj mutation. No credential read; `op --version` only.

Receipts land in `.ufo/waves/round-30/final/host/`.

## 1. Substrate absence receipt

Receipt: `final/host/substrate-absence.txt`.

| Surface | Observed |
|---|---|
| `ls ~/.local/bin/the-janitor` | `No such file or directory`, exit **2** |
| `ls ~/.config/the-janitor` | `No such file or directory`, exit **2** |
| `ls ~/.local/state/the-janitor` | `No such file or directory`, exit **2** |
| `op --version` | `2.41.1` at `/usr/bin/op` — nothing signed in, no vault/account contact |
| `sqlite3 --version` | `3.54.0 2026-10-09 …` |
| `python3 --version` | `Python 3.14.8` |
| `git --version` | `git version 2.56.0` |
| `jj --version` | `jj 0.45.1-7c41cdeb…` |
| `uname` | `Linux 7.2.11-arch1-1 x86_64` |

Substrate **ABSENT** (3× exit 2) — matches the plan's host declaration. Nothing installed,
provisioned, or signed in.

## 2. Round-29 cross-host debt retirement — all 11 gates PASS

Run from the lane repo root, cwd `kagi-shokunin`, each gate's own scratch.

| Gate | Result | Cases | Wall |
|---|---|---|---|
| `claim-ledger.sh --selftest` | **PASS** | 170 | **3.68 s** |
| `release-clock.py --selftest` | **PASS** | 116 | 0.07 s |
| `sources-census.sh --selftest` | **PASS** | 70 | 2.56 s |
| `scope-gate.sh --selftest` | **PASS** | 61 | 5.91 s |
| `self-counts.py --selftest` | **PASS** | 48 | 1.12 s |
| `op-ref-probe.sh --selftest` | **PASS** | 36 | 1.15 s |
| `checklist-run.sh --selftest` | **PASS** | 34 | 2.04 s |
| `rendered-text-v1.py --selftest` | **PASS** | 22 | 0.01 s |
| `surface-census.sh --selftest` | **PASS** | 16 | 1.20 s |
| `drift-pins.sh --selftest` | **PASS** | 13 | 0.25 s |
| `feed-token-agree.py --selftest` | **PASS** | 4 | 0.02 s |

Total ≈ 14 s wall for all eleven. The round-29 per-row spawn cost and `ln -s` debt is absent
here. `claim-ledger` finished in **3.68 s**, far inside the 480 s allowance — the 170-case suite
is not a time risk on this host.

*Caveat:* `feed-token-agree.py` was run as a plain `python3 corpus/…py` script, per the seat
spec. `corpus/claim-ledger.sh verify` refuses that invocation shape as `python-script` (see §5).

## 3. C2 — the frozen counter-2 command cannot reach `0`

Measured on a pristine `git archive` of BASE (stable, no sibling interference):

```
grep -rIl $'\r' --exclude-dir=.git --exclude-dir=.jj . | wc -l
  BASE, as archived          135        (plan asserts "before: 3")
  after LF-converting the 3 lane files only   132   (plan asserts "after: 0")
  same, with --exclude-dir=.ufo added          0
```

Cause: `132` tracked files under `.ufo/waves/` carry CRLF **by construction** — they are captured
HTTP response header dumps, e.g. `round-26/build/ClockS018.headers.txt`:

```
HTTP/2 308 ^M$
cache-control: public, max-age=0, must-revalidate^M$
```

The plan's "before: 3" reproduces only with `.ufo` excluded; the frozen command as written can
never print `0` without rewriting captured evidence. **Recommend:** either add
`--exclude-dir=.ufo` to the counter and to row R30-01, or bound the row to
`git ls-files` + `grep -v '^\.ufo/'`. Do not convert the captures.

### The EOL hypothesis itself is confirmed

Scratch fleet clone (BASE lane + fleet root markers), real fleet census:

| State | `sources-census.sh validate --root … kagi-shokunin` |
|---|---|
| BASE bytes | exit **1**, `E12` ×**52** |
| the 3 lane files LF-converted, nothing else | exit **0**, `E12` = **0** |

Counter 3 likewise: BASE `checklist-run.sh --ratio` → `SETUP … no '## Credential-hygiene
checklist' section`, exit 2; after LF → `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7
delegated=3 direct=6`, exit 0. Root cause is exact: `checklist-run.sh:104` compares
`[[ "$line" == '## Credential-hygiene checklist' ]]` byte-for-byte, and `SKILL.md:425` ends in
`\r`.

Counter 1 must run at the real fleet root: a lone clone reports
`unknown lane (not a dir, not in conf or root): kagi`, and needs `shokunin.conf`.

### `.gitattributes` blast radius — `*.json` is too broad

The set now present in the worktree includes `*.json text eol=lf`. Renormalizing BASE under it:

| Attribute set | paths rewritten |
|---|---|
| `*.md *.tsv *.sh *.py *.json` (as landed) | **9** — the 3 lane files **+ 5 tracked round-29 JSON receipts** |
| `*.md *.tsv *.sh *.py` (no `*.json`) | **4** — only the 3 lane files + `.gitattributes` |
| adding `.ufo/** -text` | **4**, and the round-26 header captures keep their 42 CR bytes |

`.ufo/waves/round-29/final/c1-before.json` holds **437** CR-terminated lines at BASE; under
`*.json eol=lf` it is rewritten 20061 → 19624 bytes, purely EOL. Those receipts are committed
evidence of the round-29 measurements and are not in `stamps.tsv`, so the rewrite is silent.
This is the plan's own kill-rule case ("if `.gitattributes` renormalizes unrelated tracked
files … the attribute set is narrowed"). **Recommend dropping `*.json`** (or `\.ufo/** -text`).

## 4. C1 — twelve enumerated rows are incomplete and one fix is a no-op

Live ledger after the EOL repair already present in the worktree:

```
FAIL R12-03 exit=0 verdict-not-final      FAIL R13-01 verdict-not-final
FAIL R14-01 verdict-not-final             FAIL R21-02 verdict-not-final
FAIL R21-04 verdict-not-final             FAIL R22-03 exit=1 want=0
FAIL R24-05 verdict-not-final             FAIL R24-06 verdict-not-final
FAIL R24-14 verdict-not-final             FAIL R24-15 exit=2 want=0
FAIL R25-02 exit=2 want=0
POLICY R29-01 first-token:python          POLICY R29-02 first-token:python
CLAIM_LEDGER: POLICY (claims=67 policy=2 stamped=94)
```

`R11-08` (citations) and `R15-05` (ratio) cleared with the EOL repair alone — 13 FAIL → 11.

Live values the rows need (measured, not asserted):

| Row | Pinned | Live |
|---|---|---|
| R12-03 stamps | 91 | **94** |
| R13-01 round headings | 34 | **35** |
| R14-01 docs | entries=25 row_linked=22 | **entries=26 row_linked=23** |
| R21-02 census | rows=51 A=49 entries_sourced=4 captures=51 | **rows=52 A=50 entries_sourced=5 captures=52** |
| R21-04 ledger rows | 65 | **67** |
| R22-03 revision added | 28 | **31** |
| R24-05/R24-06/R24-14/R24-15 | count+sha pinned | 94/35/67/31, sha re-measured |

### 4a. `R25-02` is a thirteenth failing row, outside the plan's C1 enumeration

`R25-02` pins `^SELF_COUNTS: CLEAN \(claims=60 stale=0\)$`; live is `claims=62`. If it is not
migrated, `self-counts.py` cannot exit 0 and C1's counting command fails regardless of the twelve.
**Add R25-02 to the enumeration.**

### 4b. The planned R29-01/R29-02 re-host does not clear POLICY

`python -I -B …` → `python3 -I -B …` changes the first token, but the refusal is not
`first-token`:

```
PYTHON_SCRIPT_RE='^python3[[:space:]]+corpus/(feature-claims|revision-audit|closure-dispositions|rendered-text-v1|self-counts|release-clock)\.py([[:space:]]|$)'
```

Verified in a scratch clone: after the re-host the verdict is still `POLICY … policy=2`, now with
`reason=python-script`. The regex admits **no flags** between `python3` and the script path.
Two working fixes, both verified:

- drop the flags in the rows (`python3 corpus/feed-token-agree.py [--selftest]`) — both still
  emit their expected last lines; or
- extend the regex to tolerate leading `-X` flags,
  `^python3[ \t]+([-][A-Za-z]+[ \t]+)*corpus/(…|feed-token-agree)\.py([ \t]|$)`.

Note the allowlist also omits `feed-token-agree` entirely, so the regex must be extended either
way. Changing a gate's allowlist is a semantics change, not a recorded-value migration — flag it
for the C1 kill rule if the flag-drop route is not taken.

### 4c. C1 is reachable, but only with a fix the plan omits

In a scratch clone I reached the target state:

```
SELF_COUNTS: CLEAN (claims=62 stale=0)          exit 0
```

Required three things beyond the enumerated twelve: R25-02 (§4a), the R29 rows without flags
(§4b), **and** a correction to `corpus/self-counts.tsv` that is in neither the twelve rows nor
the six doc cells. `PV-FEEDTOKEN-SHAPES` pins extract `\tshapes=\(([0-9]+)\t`, but the live line
is `FEED_TOKEN_AGREE: AGREE (shapes=12 disagreements=0)` — the `(` precedes `shapes`. As written
the cell can never match:

```
extract 'shapes=\(([0-9]+)'      -> NO MATCH
extract '\(shapes=([0-9]+)'      -> 12
```

With it corrected, `OK PV-FEEDTOKEN-SHAPES claimed=12 live=12`. **Add this row to C1's scope.**

### 4d. Separability counterexample — C1 is *not* independent of C2's bytes

The plan states "none of the twelve rows depends on C2's bytes". R22-03 and R24-15 do. Repairing
the EOLs changes `SKILL.md`, `corpus/SOURCES.md` and `corpus/claim-ledger.tsv`, all three of
which are stamped; `revision-audit --history c2cab35` then reports
`REVISION_AUDIT: DRIFT (stale=1…7)`, and both rows move from BASE's `verdict-not-final` to
`exit-mismatch exit=1/2`. A `claim-ledger.sh stamp` re-pin is a hard prerequisite for them, and
that re-pin is caused by C2. Ordering: EOL repair → re-stamp → C1 rows. The delta is still
attributable, but the separability sentence must be corrected rather than relied on.

## 5. Citations — 19 unresolved, all CRLF-effect, all lane-authored

Receipt: `final/host/citations-at-base.txt` (77 s).

```
CITATION_GATE: BROKEN (cites=1846 docs=75 unresolved=19 ephemeral=0 labeled=14)
```

Every one of the 19 is a `SKILL.md` line, and every token was produced with the CR attached:

```
UNRESOLVED SKILL.md:52 corpus/knowledge/handler-trust-boundary.md`)^M (local)
UNRESOLVED SKILL.md:630 corpus/claim-ledger.sh^M (local)
```

Verified mechanically: I re-ran the gate's own `norm_tok` over all 19 tokens with and without the
terminating CR.

| Classification | Count | Detail |
|---|---|---|
| **CRLF-effect** | **19 / 19** | strip `\r` → **19/19 resolve** to existing files |
| integrator-spotcheck-file (never editable) | 0 | — |
| lane-authored fixable (content) | 0 | no token is a genuine dead citation |

Full list (all `SKILL.md`, line → target):
52 `knowledge/handler-trust-boundary.md`, 88 `knowledge/control-plane-hardening.md`,
95 `knowledge/handler-on-disk-state.md`, 129 `knowledge/transcript-hygiene.md`,
131 `state-shape.tsv`, 175 `knowledge/surface-census.md`, 177 `drift-symbols.tsv`,
236 `stamps.tsv`, 262 `stamps.tsv`, 268 `knowledge/claim-ledger.md`,
304 `knowledge/claim-ledger.md`, 305 `lessons/round-11.md`,
332 `knowledge/janitor-env-contract.md`, 359 `knowledge/op-ref-consumption.md`,
365 `op-ref-probe.sh`, 408 `knowledge/janitor-lifecycle.md`,
461 `knowledge/control-plane-hardening.md`, 630 `claim-ledger.sh`,
765 `lessons/round-24.md`.

Causal confirmation: after the EOL repair **now present in the worktree**, the live gate reads

```
CITATION_GATE: CLEAN (cites=1846 docs=75 unresolved=0 ephemeral=0 labeled=13)
```

So R11-08 needs no edit of its own — it is discharged by C2, and it is *not* an integrator
spot-check file. The plan's "triage during integration" can close as "no action; CR artefact".

## 6. C3 — baseline confirmed; the append needs a surface the plan does not name

Baseline at HEAD, all three counters as the plan states: grep counter `0`; none of the three
knowledge files exist; `SOURCES_CENSUS: CLEAN (rows=52 …)`.

Collision is real and the mapping's *target* space is free: lane max id is `S052`, and
`S053`–`S060` match `0` rows today.

**Gap:** appending the 8 staged rows (S066–S073 → S053–S060) *inside* the `## Registry` section
makes the grep counter print `8` (verified) but the lane census then fails:

```
FINDING SC_FETCH id=S053 missing-provenance
FINDING SC_FETCH id=S054 missing-provenance
SOURCES_CENSUS: FAILED (findings=10 rows=60)
```

`corpus/sources-census.sh:328` requires every registry id to have a row in
`corpus/source-fetches.tsv` (16 columns, one capture per id). The staged package carries
`SOURCES.append.md` and `knowledge/`, but no provenance rows, and the plan's C3 scope names only
`SOURCES.md` rows, three knowledge files, and index/coverage rows. **C3's executor will need
8 provenance rows as well**, or counter 3 (`SOURCES_CENSUS: CLEAN (rows=60 …)`) cannot pass.
This also means C1's R21-02 migration value (`rows=52`) is read before C3 lands — if C3 lands in
the same revision, the pinned census string must be computed at the measured revision, as the
plan already allows.

## 7. Findings summary

| # | Finding | Severity |
|---|---|---|
| 1 | C2 counter 2's frozen command cannot print `0` — 132 CRLF files under `.ufo/waves/` are captured HTTP headers; needs `--exclude-dir=.ufo` or a `git ls-files`-bounded form | **blocking as written** |
| 2 | Landed `.gitattributes` `*.json` rule silently rewrites 5 round-29 evidence receipts (9 paths vs 4) — plan's narrow-the-set kill rule applies | high |
| 3 | C1's enumeration misses `R25-02` (claims=60 vs 62) and the `PV-FEEDTOKEN-SHAPES` extract regex; without both, `SELF_COUNTS: CLEAN` is unreachable | **blocking as written** |
| 4 | The planned R29 `python`→`python3` re-host does **not** clear POLICY; `PYTHON_SCRIPT_RE` forbids flags entirely and omits `feed-token-agree` | **blocking as written** |
| 5 | C1 is not causally separable from C2: R22-03/R24-15 read `stamps.tsv`, which C2's byte change stales — order is EOL → re-stamp → C1 | medium |
| 6 | C3 needs 8 `source-fetches.tsv` provenance rows not named in the plan, else `SOURCES_CENSUS: CLEAN (rows=60)` fails | high |
| 7 | All 19 citation misses are CR artefacts in `SKILL.md`; 0 integrator-spotcheck, 0 genuine — R11-08 closes with C2 | resolves |
| 8 | All 11 selftests PASS here; round-29 cross-host debt absent | clear |

## 8. Tooling

No installs, no upgrades. `pacman` untouched (host-wide pause respected). Tools observed only:
`op` 2.41.1, `sqlite3` 3.54.0, `python3` 3.14.8, `git` 2.56.0, `jj` 0.45.1.

## 9. Boundaries honoured

Lane production files read-only. No lane git/jj mutation — the worktree changes to `SKILL.md`,
`corpus/SOURCES.md`, `corpus/claim-ledger.tsv` and the new `.gitattributes` are a **sibling
seat's**, observed only. Every experiment ran in `git archive` trees under
`/fast/scratch/hyaku/kagi-r30/ScoutHost/`. No credential read, no `op://` value, no secret
material, no vault/account/handler contact. No feed-token derivation or token-totality work: the
`feed-token-agree.py` runs are the gate's own public selftest/agreement modes, executed to check
an allowlist, not to study the tokenizer.
