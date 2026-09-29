# adjacency scope — the ownership partition, as a checked claim

Source basis: `corpus/scope-gate.sh` (v2, round 17) +
`corpus/adjacency.tsv` (5 `# own` prefixes, 4 group rows covering the 8 census
rows outside them, 4 `# owner` / 4 `# status` / 2 `# claim` / 8
`# no-enumerate` / 4 `# breadth` directives) +
`corpus/surface-census.tsv` (35 rows, 4 `# scan`, `mode` column), all read-only
on 2026-09-29. Prose replaced in round 16: `corpus/README.md`'s overlap table,
`PROVINCE.md`'s CDP refusal, and the one `mode = -` census row. Round 17 extends
the same gate with checked breadth; its detailed contract is
`corpus/knowledge/adjacency-breadth.md`. Current gates: `ADJACENCY_SCOPE: CLEAN
(census=35 owned=27 shared=8 groups=4 owners=4 unresolved=1 contested=1
escapes=0 inbound=0 foreign=0 orphans=0 stale_basis=0 basis_escape=0
own_unlisted=0 breadth_required=4 breadth_pins=4 breadth_checked=4 breadth_ok=4
breadth_missing=0 breadth_invalid=0 breadth_drift=0 breadth_exceeds=0
breadth_unverified=0)`; `SCOPE_SELFTEST: PASS (61 cases)`;
`SCOPE_FALSIFY: PASS (caught=18/18 failed=0)`.

Reverify: R16-01, R16-02, R16-03, R16-04, R16-05, R16-06, R17-01, R17-02, R17-03

## Why this gate exists

Rounds 1–15 kept "cross-domain awareness — evidence belonging to another domain
is reported, never absorbed" in three prose places, and nothing could falsify any
of them:

1. `corpus/README.md` — a two-row overlap table naming kotoba and kake.
2. `PROVINCE.md:34` (the CDP surface, "contested with kake") and `:44` (the
   refusal: the lease/profile question "is reported to the integrator, never
   adjudicated here").
3. One `mode = -` census row (the musketeer profile dir — declared, not checked).

Nothing fired when a census row drifted into another lane's tree, when a shared
surface lost its named owner, or when a basis citation decayed into a pointer at
unrelated text. The last was **live**: `corpus/README.md:76` cited
`kake-shokunin/SKILL.md:104-107` for the musketeer lease, and that slice matches
`musketeer` **0 times** (it is `webzites status` exit-semantics text); the claim
is at `:161` (⇒ 1). The partition makes each prose place a row a command
re-reads, and the citation decay a verdict (`STALE-BASIS`). The README was
corrected in the same commit as the gate.

## The partition (measured, not asserted)

| fact | count | token if it breaks |
|---|---|---|
| census rows | 35 | — |
| owned by the 5 `# own` prefixes | 27 | `OWN-UNLISTED` (a prefix that is not a declared surface) |
| shared (covered by a group row) | 8 | `FOREIGN` (uncovered) |
| group rows | 4 | `ORPHAN` (a row covering 0 census rows) |
| owner directives | 4 (`integrator`, `kagi`, `kake`, `kotoba`) | `UNKNOWN-OWNER`, `OWNER-MISMATCH` |
| status / claim directives | 4 / 2 | `BAD-VALUE` |
| `# no-enumerate` directives | 8 | `ENUM-CLASH` |

Prefix coverage is **5 / 1 / 1 / 17 / 3** (config/the-janitor,
bin/the-janitor, bin/tac-check, state/the-janitor, state/tac) = 27. The two
`bin` entries are **exact files**, not directories — `$HOME/.local/bin` holds 105
children, of which this domain's two tools are owned and the other 103 are not
(one of them is kake's `musketeer-chrome` launcher symlink). The 4 group rows,
with longest-match coverage:

| group row | owner | status | claim | census rows |
|---|---|---|---|---|
| `$HOME/.config/opencode` | integrator (arbiter of the owed ruling) | unresolved | declared | 4 |
| `$HOME/.local/share/the-musketeer/chrome-profile` | kake | contested | presence-only | 1 (the dir) |
| `…/chrome-profile/NativeMessagingHosts` | kagi | writer | declared | 2 (NMH dir + manifest) |
| `$HOME/.agents/AGENTS.md` | kotoba | shared-read | declared | 1 |

8 = 4 + 1 + 2 + 1, no `FOREIGN`, no `ORPHAN` on the landed data. Two
non-obvious ownership calls, made from evidence: the NMH row's `owner` is
**kagi** because the only documented writer of the NMH dir + manifest is this
domain's `cdp-bridge ensure` (`corpus/lessons/round-8-aggregator-box3-coldrun.md:64`,
a mutation note recording the in-place rewrite), so a `writer` row names the lane
that *writes* while the enclosing profile dir stays `owner=kake, contested,
presence-only`; and an `unresolved` row's `owner` (`integrator`) names the lane
that owes the **ruling**, not a found owner — no fleet artifact names a single
owner of `$HOME/.config/opencode` (kotoba, kama, kengaku and kumitate all have
artifacts in it). Round 17 corrected the prior `D-96` attribution: that ledger
row concerns sibling `SKILL.md` discovery roots, not this ownership question.

## Schemas

### `corpus/adjacency.tsv` — 7 columns

`path <TAB> owner <TAB> status <TAB> claim <TAB> basis <TAB> token <TAB> note`

| column | values | meaning |
|---|---|---|
| `path` | `$HOME/...` or absolute | a surface **root**; the longest matching path covers a census row, so one row can cover a subtree (the NMH row covers the manifest) |
| `owner` | a lane id declared by `# owner` **and** in the script's literal set | on a `writer` row the lane that writes; on an `unresolved` row the arbiter that owes the ruling; otherwise the owning lane |
| `status` | `contested` / `shared-read` / `writer` / `unresolved` | what the overlap *is* |
| `claim` | `presence-only` / `declared` | what **this** domain asserts — see R7 |
| `basis` | repo-relative `path[:N\|N-M]`, or `lane:<lane>/<path>[:N\|N-M]` | the citation establishing the owner lane's claim; `lane:` resolves under `~/projects/shokunin/<lane>-shokunin/` |
| `token` | a short plain ERE (`^[^\s]{1,60}$`, no `://`) | must match **at least one** line of the cited range (a `:N-M` citation is satisfied by any matching line; no `:N` means the whole file — the stricter "every cited line" reading is not what is implemented); a citation that resolves to unrelated text is `STALE-BASIS`; the token is echoed in defect output, so it may carry no secret |
| `note` | free text | no tabs, no secret value, no vault ref path, no account identifier. **Not parsed by the gate** — review-only (bound 13) |

Directives: `# own <prefix>`; `# owner`/`# status`/`# claim` declare the three
closed vocabularies (which the script also holds as literals, so a directive
cannot *create* a new value); `# no-enumerate <dir>` records a directory
deliberately **not** scanned; `# breadth <dir> children=N declared=M` measures
the four derived leaf boundaries. There is deliberately no `--pin`: scope and
breadth edits are reviewed commits.

### `corpus/surface-census.tsv` — read, not owned here

The gate reads `path` (the universe of rows to partition), `class`, `kind`,
`mode` (`-` vs an exact octal — R7's other half), the `# scan` directives (R8,
R11) and the row set (R3, R4, R10). The census is unchanged this round and still
green. Both data files end **without a trailing newline**, so every reader must
use `while IFS=… read -r … || [[ -n "$f1" ]]`; a naive loop silently drops the
last row (`--falsify` run 1 proved the append-side of the same class).

## Rules, with a failing input each

Each failing input is a selftest case (`grep -oE 'run_case [a-z0-9-]+'
corpus/scope-gate.sh` names them) or a `--falsify` mutation, so every falsifier
is runnable.

| | rule | token | failing input |
|---|---|---|---|
| R1 | schema + directive vocabulary | `BAD-ROW` | a 6-field row, an 8th column (or a fused line), a duplicate group path, a duplicate directive, an unknown directive, a token with a URL scheme |
| R2 | every census row is `owned` (prefix) or `shared` (covered; longest match wins) | — (classification, not a guard) | its failure modes surface as R3/R4; a *removed* census row is the census's claim (`R11-11` pins 35), not this gate's |
| R3 | shared census row with no covering row | `FOREIGN` | append a census row under no group path (or delete a group row) → exit 1 |
| R4 | group row covering 0 census rows | `ORPHAN` | a group row for `$HOME/.local/share/other-lane` → exit 1 |
| R5 | `owner`/`status`/`claim` inside the literal sets; a `lane:` basis names the owner's lane | `UNKNOWN-OWNER`, `BAD-VALUE`, `OWNER-MISMATCH` | owner `newlane` *declared in the file* but not in the script's set; status `bogus-status`; `owner=kotoba` with `basis=lane:kake/…` |
| R6 | `basis` resolves, stays inside its root, **and** `token` matches the cited line(s) | `NOT-A-FILE`, `STALE-BASIS`, `BASIS-ESCAPE`, `BAD-ROW` | `basis=missing.md`; `basis.md:1` where the token is on line 3; `kake-shokunin/SKILL.md:104-107` with token `musketeer` (the README:76 decay); `../../priv/secret.env:1`; a `lane:` root symlinked out of the lane tree |
| R7 | `claim ↔ mode` is biconditional | `OVERCLAIM` | (a) give the presence-only profile row `claim=declared`; (b) give a `declared` row a census row whose mode is `-` — either direction, exit 1 |
| R8 | every `# scan` dir lies inside an `# own` prefix | `FOREIGN-SCAN` | move a `# scan` onto `$HOME/.config/opencode` → exit 1 |
| R9 | resolution containment, **both** directions, through anchor identity | `ESCAPE`, `INBOUND`, `UNVERIFIED` | symlink an owned path out → `ESCAPE`; symlink a shared path into an owned prefix → `INBOUND`; dangling symlink or unresolvable path → `UNVERIFIED`, exit 1 |
| R10 | `# no-enumerate` names a census row or ancestor, is neither `$HOME` nor a `# scan` dir, and is not inside an `# own` prefix | `ENUM-CLASH` | unrelated path; scan dir; whole HOME; or `# own $HOME/.local/bin` while the dir is declared unscanned |
| R11 | an `# own` prefix must be a declared census surface, and a directory prefix must be a `# scan` dir | `OWN-UNLISTED` | `# own $HOME/projects` (the whole fleet checkout, undeclared) → exit 1 |
| R12 | exact breadth schema + one pin for each derived leaf no-enumerate dir; no aggregate/scan/foreign targets | `BAD-ROW`, `BREADTH-MISSING`, `BREADTH-NOENUM`, `BREADTH-SCAN`, `BREADTH-SCOPE`, `BREADTH-INVALID` | delete all pins; add a pin on `$HOME/.config`; reorder count fields |
| R13 | root is a real enumerable dir inside HOME and live children/declared counts equal pins | `BREADTH-HOST-MISSING`, `BREADTH-NOT-DIR`, `BREADTH-UNVERIFIED`, `BREADTH-CHILDREN-DRIFT`, `BREADTH-DECLARED-DRIFT`, `BREADTH-EXCEEDS` | remove/symlink a root; change a pin; add a census row below an already-live direct child |

Measured before the gate ran: all 4 `# scan` dirs are owned (4/4); all 35
declared paths `realpath` to themselves (0 symlinks under the 3 host scan roots);
the 4 scan dirs hold 4/5/5/2 = 16 children, all declared; `~/.config/opencode`
holds 20 children (4 declared) by `find … -mindepth 1` — 19 by `ls -1`, the delta
being a dotfile, so an audit must say which command it counts with;
`~/.agents` 4 (1 declared); each `# no-enumerate` dir is a census row or an
ancestor of ≥1 row, and none is a scan dir or inside an owned prefix.

## Verdicts, exit codes, and the summary line

| line | exit | meaning |
|---|---|---|
| `ADJACENCY_SCOPE: CLEAN (census=… owned=… shared=… breadth_required=… breadth_pins=… breadth_checked=… breadth_ok=… breadth_*=0)` | 0 | partition and breadth are complete and self-consistent |
| `BREADTH_AUDIT: CLEAN (required=4 pins=4 checked=4 ok=4 children=182 declared=8 undeclared=174 …)` | 0 | live count-only breadth result; terminal line of `--breadth` |
| `ADJACENCY_BREADTH: dir=… children=N declared=M undeclared=K` | — | per-leaf measured counts; no child names |
| `SCOPE <TOKEN> …` (one line per defect, above the summary) | 1 | a defect; the token is from the R-table |
| `ADJACENCY_SCOPE: DEFECT (…)` | 1 | always printed when defects exist — no silent death |
| `ADJACENCY_ABSTAIN: rows=N` | — | exit-neutral: a `runtime` census row legitimately absent abstains from R9 |
| `ADJACENCY_ASSET_ABSENT: rows=N` | — | named asset absence; breadth may independently turn it into drift |
| `SCOPE_MAP: <path>\t owned\|shared \t <prefix>\t[<owner>]` | — | `--map` prints the partition, then verifies |
| `ADJACENCY_SCOPE: SETUP (…)` / `scope-gate: <msg>` | 2 | setup or usage error |
| `SCOPE_SELFTEST: PASS (61 cases)` / `SCOPE_FALSIFY: PASS (caught=18/18 failed=0)` | 0 | scratch proof / shipped-data mutations |

## The decisions that make it honest

- **`unresolved` and `contested` are declared classes, exit-neutral.** The
  integrator has not ruled on `$HOME/.config/opencode` and kake/kagi both claim
  the musketeer profile in writing; the gate does not pretend otherwise — the
  counts are printed and pinned. Precedent: the census's `skipped=N` is printed
  and exit-neutral while an unreadable shape class is `UNVERIFIED` and fails
  closed; this gate inherits the split (`unresolved`/`contested`/`ABSTAIN`/
  `ASSET_ABSENT` neutral; `UNVERIFIED` fails).
- **R7 makes the profile/manifest boundary drift-proof.** The profile **dir** is
  `presence-only` and must be the census's `mode = -` row; the NMH dir and
  manifest are `declared` with exact modes (700 / 600). Because the rule is a
  biconditional, either direction fires — an editor cannot quietly promote the
  profile to "pinned" or demote the manifest to "unchecked" without moving both
  the census `mode` and the row `claim` in one reviewed commit.
- **R9 runs in both directions, and through the anchor.** `ESCAPE` catches this
  domain's own asset resolving outside the owned set; `INBOUND` catches a
  **foreign** surface symlinked *into* it. `resolve_anchor` keeps an `# own`
  prefix's final component literal, so a prefix displaced by a symlink no longer
  contains its rows.
- **Ownership requires a declared surface (R11).** Before it, `# own
  $HOME/.local/bin` was byte-identically CLEAN while claiming 105 foreign
  children (reviewer D2, sentinel S2, mutation M13 — three lanes proved it).
  Ownership can now only be as wide as a census row, and a directory prefix must
  be one of the enumerable ones.
- **`basis` cannot leave its root (R6).** A traversal (`../`) or a symlinked
  `lane:` root would have made the verdict a boolean oracle over private bytes —
  `../../.config/the-janitor/op.env` is reachable from the repo root at
  sufficient depth (sentinel S1). Declared `..`/absolute paths and resolved
  escapes are `BASIS-ESCAPE`, exit 1.
- **`token` closes the citation-decay class.** A `basis` is not accepted on
  resolution alone; the cited line(s) must match an ERE — aimed exactly at the
  `README.md:76` class.
- **The summary is never the only evidence.** `--map` prints the per-row
  partition, `--selftest` proves every rule on scratch, `--falsify` mutates the
  shipped pair; the counts are pinned by ledger rows (`R16-01` … `R16-06`).

## Bounds — what this gate does NOT check

1. **Ownership is a governance fact.** The gate checks the *declaration* is
   complete and self-consistent, not that kake leases the profile, that kotoba is
   the sole claimant of `AGENTS.md`, or that kagi writes the NMH manifest. An
   *invented* foreign census row plus an invented group row with a plausible
   owner and a token-matching basis still passes (critic CE-A1: `census=36
   owned=27 shared=9`, CLEAN) — the adjudication stays with the integrator.
2. **The openness of a shared dir cannot be verified here.** `status` is a label
   the data carries, not an observation.
3. **The census is the declared universe, but breadth sees its cardinality
   boundary.** A host child no census row names remains unidentified; net child
   count changes now fire, while a same-cardinality name swap remains invisible
   by design (name manifests are refused for privacy).
4. **`# no-enumerate` is a local declaration, not fleet enforcement.** Another
   lane scanning that dir is not detectable here.
5. **Longest-match is textual.** Coverage is a string prefix, not a filesystem
   walk. R11 closed the *prefix* over-breadth class; an over-broad **census
   row** (e.g. declaring `$HOME/.local/bin` as a surface and a `# scan` dir)
   remains a review-level claim about breadth, owned by the census declaration.
6. **`token` is a floor, not a relevance proof.** A line that mentions the
   surface without asserting a claim passes. Executed: the first landed NMH row
   cited `lane:kake/corpus/knowledge/mirror-pitfalls.md:48` with token
   `musketeer`, and that line reads `` `(musketeer-chrome &)` dies with the
   shell `` — resolvable, token-matching, and about a launcher, not the
   manifest-writing claim. Re-based on the round-8 lesson; the *rule* still
   accepts a token drawn from a path's parent noun. A `note`-embedded citation
   is checked by nobody (the same class re-entering through a column with no
   rule).
7. **R9's owned branch asserts containment in the owned *set*, not identity.** A
   path resolving from one `# own` prefix into another owned prefix passes
   (`CLEAN`, reproduced on a scratch tree); an out-of-set target is `ESCAPE` and
   a shared row landing inside the set is `INBOUND`.
8. **`realpath` is the only link test, and its flags decide the verdicts.** A
   hardlink to an owned file is indistinguishable from the file; a bind mount is
   not detected; `realpath -m` is fail-open and must never be used (`-e` and the
   `-e`/`-L` pre-check separate the dangling, absent and unreadable classes).
   An unreadable *middle* component is treated as absent (an `ABSTAIN` for a
   runtime row) rather than `UNVERIFIED`.
9. **`unresolved`/`contested` are exit-neutral by construction**, with the count
   as the counterweight.
10. **`basis` cites sibling repos, which are read-only surfaces here.** The
    grammar has repo-relative and `lane:` forms only, so an integrator-tree
    citation (`.ufo/reports/round-10/kagi.md:86-88`, which states three of the
    four ownerships in one sentence) is not expressible.
11. **Nothing schedules this gate** (`checklist-execution.md` bound 2).
12. **R7 needs the census's `mode` values**, so census mode hygiene is
    load-bearing; the census cross-checks those modes against
    `drift-baseline.tsv` (`CROSSCHECK`) and this gate does not repeat that.
13. **The `note` column is parsed into nothing.** It is review-only; a stale
    citation written inside a note is invisible to R6 (bound 6's second half).
14. **The gate re-reads the census; it does not re-verify it.** A row deleted
    from the census lowers `census=` and stays CLEAN — the row count is pinned
    outside by `R11-11` (35) and by the census gate itself.

## Reproduction (2026-09-29)

```bash
cd ~/Projects/shokunin/kagi-shokunin
bash corpus/scope-gate.sh            # CLEAN partition + breadth, exit 0
bash corpus/scope-gate.sh --breadth  # 4 rows; 182/8/174; CLEAN, exit 0
bash corpus/scope-gate.sh --map      # 35 SCOPE_MAP lines, then CLEAN
bash corpus/scope-gate.sh --selftest # SCOPE_SELFTEST: PASS (61 cases)
bash corpus/scope-gate.sh --falsify  # SCOPE_FALSIFY: PASS (caught=18/18 failed=0)

# independent declaration counts:
grep -vc '^#' corpus/surface-census.tsv                           # 35
grep -cE '^# own[[:space:]]+.HOME/' corpus/adjacency.tsv          # 5
grep -cE '^[^#[:space:]]' corpus/adjacency.tsv                    # 4 groups
grep -cE '^# no-enumerate[[:space:]]+.HOME/' corpus/adjacency.tsv # 8
grep -cE '^# breadth[[:space:]]+.HOME/' corpus/adjacency.tsv      # 4
```

## Falsification

Every listed defect turns the gate red; `--falsify` runs 18 mutations against
the shipped data+census (scratch copies, repo and host unchanged):

1. Add a census row under a shared tree with no covering group row → `FOREIGN`.
2. Add a group row for a path with no census row under it → `ORPHAN`.
3. Declare a new owner in the file and use it → `UNKNOWN-OWNER` (the script holds
   the literal set, so a directive cannot widen the vocabulary).
4. Cite `kake-shokunin/SKILL.md:104-107` with token `musketeer` → `STALE-BASIS`
   (the README:76 decay, now a verdict; `--falsify` mutation 1).
5. Cite `../../priv/secret.env:1`, or a `lane:` root symlinked out of the lane
   tree → `BASIS-ESCAPE`, exit 1 (mutations 8 and 9).
6. Give the presence-only profile row `claim=declared` → `OVERCLAIM`; and the
   reverse direction on a `-` census row → `OVERCLAIM`.
7. Append `# scan $HOME/.config/opencode` → `FOREIGN-SCAN` (mutation 4).
8. Symlink an owned path out (or `# own $HOME/.local/bin` while it is declared
   unscanned) → `ESCAPE` / `ENUM-CLASH` (mutations 5 and 6).
9. Append `# own $HOME/projects` → `OWN-UNLISTED` (mutation 7).
10. Give a row an 8th column, duplicate a census row, or add a field to a
    directive → `BAD-ROW`.
11. Remove/change a breadth pin, target an exempt/foreign dir, widen to HOME,
    or add a census-linked direct child → one of the R12/R13 breadth tokens.
12. Absent `session-id` while the handler is stopped → `ADJACENCY_ABSTAIN:
    rows=1` and exit 0 (named abstention, not a silent skip).

## Evidence

- `bash corpus/scope-gate.sh` ⇒ `BREADTH_AUDIT: CLEAN (required=4 pins=4
  checked=4 ok=4 children=182 declared=8 undeclared=174 missing=0 invalid=0
  drift=0 exceeds=0 unverified=0)` then `ADJACENCY_SCOPE: CLEAN (...)`, exit 0.
- `--selftest` ⇒ `SCOPE_SELFTEST: PASS (61 cases)`; `--falsify` ⇒
  `SCOPE_FALSIFY: PASS (caught=18/18 failed=0)`.
- Independent partition re-derivation (executor lane, own harness) ⇒
  `census_rows 35 owned 27 shared 8`; groups cover `4 / 1 / 2 / 1`;
  `orphan_rows []`, `uncovered_shared []`; and the landed gate on that
  independently derived file ⇒ the same CLEAN line.
- `sed -n '104,107p' kake-shokunin/SKILL.md | grep -c musketeer` ⇒ `0`;
  `sed -n '161p' … | grep -c musketeer` ⇒ `1`; the same check on
  `kake-shokunin/corpus/knowledge/mirror-pitfalls.md:48` ⇒ matches a launcher
  line (bound 6).
- `find ~/.config/opencode -mindepth 1 -maxdepth 1 | wc -l` ⇒ `20`;
  `~/.local/bin` ⇒ `105`; `~/.agents` ⇒ `4`;
  `~/.local/state` ⇒ `15` (2 this domain's).
- `tail -c 1 corpus/{surface-census,adjacency}.tsv | od -c` ⇒ neither file ends
  in a newline — the guard every reader needs, and the class `--falsify`'s first
  run tripped over.