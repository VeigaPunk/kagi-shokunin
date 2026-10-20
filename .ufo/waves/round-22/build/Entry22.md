# Entry22 — freshness/calibration audit: `corpus/knowledge/tac-evidence-integrity.md`

Seat: `KagiR22.Entry22` (leaf, read-only). Base revision read:
`c2cab35bc92e57e39e5489bac3386db078345b3f` (2026-10-19 22:05:06 -0300), working
tree observed 2026-10-20 18:31–18:36 -0300. No host gate was executed. No files
were modified except this report. No tools were installed.

## Verdict

1. **Byte level: CLEAN. There is no stale-byte mismatch.** The stamp row is
   exact at the working tree, at `HEAD`, and at every revision since it was
   created. It is not stale debt and must not be re-pinned "to get green".
2. **Substantive freshness: DEGRADED, and the gate cannot see it.** All four
   `tac` source paths are absent on this host; the substrate predicate the two
   declared rows depend on (`-x ~/.local/bin/the-janitor`) is false, so
   `R11-01`/`R11-04` take the `substrate-absent` deferral and neither is
   executed (code path read in `claim-ledger.sh`; the gate itself was not run).
   The one present citation target, `~/.agents/AGENTS.md`, no longer
   carries the janitor section the entry quotes. Nothing in the entry's
   historical claims is falsified.
3. **An appended, dated provenance block is required** — append-only, at EOF,
   without touching a byte above it; then a reviewed `stamp` re-pin in a quiet
   tree with the old tuple recorded. No ledger expectation migrates: `R12-03`
   stays `63`, `R14-01` stays `entries=24 row_linked=21`, and the `Reverify`
   line stays `R11-01, R11-04`.

## 1. Byte identity — the row is not stale

Row at `corpus/stamps.tsv:30`:

```
corpus/knowledge/tac-evidence-integrity.md	c77312306f2e6708d47aeaa4a483a27e3dbb9597b6b281f6cab4a71103f89665	80	3757
```

Observed:

| probe | result |
|---|---|
| `sha256sum corpus/knowledge/tac-evidence-integrity.md` | `c7731230…f89665` — exact |
| `wc -lc` | `80 3757` — exact |
| `git show HEAD:corpus/knowledge/tac-evidence-integrity.md \| sha256sum` | `c7731230…f89665` — committed bytes identical |
| `git status --porcelain` for this path | absent — not modified by the live tree |
| file mtime | 2026-10-13 16:51:07 -0300 (checkout artifact; content unchanged since round 14) |

History (measured with `git show <rev>:corpus/stamps.tsv` and
`git show <rev>:corpus/knowledge/tac-evidence-integrity.md`):

- Row **absent** at `301b9ec` (round 11) and `4b8c018` (round 13) — the pin set
  then covered only 7 knowledge entries (round-14 pre-state), so this is a
  later **addition**, not a drop.
- Row **created** at `2486643` ("round-14: freshness axis-move…",
  2026-09-28 22:27:11 -0300) with the tuple above.
- Tuple **byte-identical at every later stamp revision**: `2486643`,
  `587fda0`, `8a6ec16`, `bc1af88`, `fecee87`, `c41af82`, `e1544c1`, `c2cab35`
  (8 revisions, ~3 weeks).
- The file's only content change ever is `9b3e49f` → `2486643`: the round-14
  commit added exactly the `Reverify: R11-01, R11-04` line plus a blank line
  (`a8ee1fd9…`, 78 lines / 3731 bytes → `c7731230…`, 80 / 3757). No edit since.
- The file is **not** one of the nine rows rewritten at `e1544c1` (see §6).

So a "stale stamp" finding for this entry would be a false positive. The
revision stamp is doing exactly what its contract says.

## 2. What the declared re-verification actually does

Declaration at `corpus/knowledge/tac-evidence-integrity.md:7`:

```
Reverify: R11-01, R11-04
```

Both rows exist and are `[substrate]`-tagged (`corpus/claim-ledger.tsv:15,18`):

| row | command | role for this entry |
|---|---|---|
| `R11-01` | `bash corpus/surface-census.sh` | asserts the `tac` assets/dirs exist with declared kinds/modes (`corpus/surface-census.tsv:31–38`) |
| `R11-04` | `bash corpus/drift-pins.sh` | asserts `$HOME/.local/bin/tac-check 755 88 af95ca97…` (`corpus/drift-baseline.tsv:10`) plus two content symbols at `L63`/`L69` (`corpus/drift-symbols.tsv:26–27`) |

Mechanism (read, not executed): `substrate_present()` is
`[[ -x "$HOME/.local/bin/the-janitor" ]]` (`corpus/claim-ledger.sh:138–145`);
a `[substrate]` row is emitted as `DEFER <id> reason=substrate-absent` and is
not run when the predicate is false (`corpus/claim-ledger.sh:397–398`).
`DEFER` is counted, so `verify` can print
`CLAIM_LEDGER: CLEAN (… deferred=N)` while **neither** check ran.
[INFERENCE from code, not from a gate run.]

Consequence for this entry:

- On this host `~/.local/bin/the-janitor` is absent (`~/.local/bin` has 50
  visible entries and lists neither `tac-check` nor `the-janitor`;
  `command -v` is empty for both),
  so both declared rows defer. The entry is *linked* but not *re-verified*.
- The deferral is honest for host-state absence, but it is silent about
  *which* source disappeared: if `the-janitor` were present and `tac-check`
  absent, `drift-pins` would print `MISSING`/`GONE` and exit 1
  (`corpus/drift-pins.sh:140`, `:203` for an absent file, `:232` for a lost
  pattern). In the current state, the
  stronger signal (substrate missing entirely) masks the weaker one.
- This is the exact absent-source limit C2 must keep separate from byte
  staleness: the stamp can be perfect while the reverify path is inert.

## 3. Source state on this host (read-only, metadata only)

| path named by the entry | state at 2026-10-20 ~18:32 -0300 |
|---|---|
| `~/.local/bin/tac-check` | **absent** |
| `~/.local/state/tac/daybreak-blue-access.json` | **absent** (parent `~/.local/state/tac` absent) |
| `~/.local/state/the-janitor/tac-daybreak-blue.json` | **absent** (parent `~/.local/state/the-janitor` absent) |
| `~/.local/state/tac/handoff-status.json` | **absent** |
| `~/.agents/AGENTS.md` | **present**, 949 bytes, mtime **2026-10-20 09:18**, mode 0644 — but it contains only an operator tooling directive |

The entry's `Source:` block names "host `~/.agents/AGENTS.md` janitor section"
(`…tac-evidence-integrity.md:1–5`) and quotes, under
§Custody record semantics: "`the-janitor tac-register` explicitly records a
checksum and never replaces an existing mismatching record." That sentence is
**not present** in the current file, which has no janitor section and no
`tac-register` string. I checked all `AGENTS.md` files under `/home/vgpnk` at
depth ≤3 (`~/.agents`, `~/.config/devin`, `Projects/ufo-fsd-alpha`,
`Projects/opencodeufo`, `Projects/kimi-code`): none contains `tac-register` or
`daybreak`. Within the trees searched (`~/.agents`, `~/.config`, `~/.omp`), the
only current matches are **past OMP session transcripts** under
`~/.omp/agent/sessions/…` — records of earlier reads, not a source. So the
quote's historical existence is attested only by transcripts; its named source
no longer supports it.

No in-repo copy of the script exists: the baseline hash
`af95ca97b3e3542ccd3f3b4fb718b9208254dea7d133e118806aff53e6b2961d` appears only
at `corpus/drift-baseline.tsv:10`, and `LOCAL_RECEIPT_INTEGRITY` occurs only as
quoted output text (`corpus/drift-symbols.tsv`, this entry,
`corpus/lessons/round-8-aggregator-box3-coldrun.md`, `SKILL.md`), never as
script bytes. The entry's "88 lines, read 2026-09-28" therefore rests on that
one committed baseline row; it cannot be re-derived from the corpus alone.

## 4. Adjudication: stale bytes vs substantive freshness

- **Stale-byte mismatch: none.** See §1. A re-pin here would be an
  unjustified revision change and exactly the "refresh to get green" failure.
- **Substantive freshness: two independent defects.**
  1. *Environment:* every source the entry reads is absent, and the
     substrate predicate is false, so the declared reverify path defers. This
     is host state, not a content error.
  2. *Citation:* one source (`~/.agents/AGENTS.md`) is present but no longer
     contains the section the entry attributes to it. This is a content
     pointer that is dangling today, and no gate can detect it: the stamp
     covers the entry's own bytes, and the reverify rows only cover the
     `tac` substrate, not `AGENTS.md`.
- **No overclaim in the historical text.** The entry already bounds itself:
  TAC enrollment is "operator-attested … (stated 2026-09-06)", access is "a
  historical observation, not current entitlement", and its own output block
  says `LIVE_ACCESS_NOW: not rechecked (offline receipt check)` plus
  `LIMIT: locally writable evidence, not a provider signature or TAC token`.
  The only present-tense pointer that has gone stale is the AGENTS.md
  attribution.
- **Date arithmetic:** content read 2026-09-28; stamped the same day
  (2026-09-28 22:27); unchanged for 22 days; sources absent by 2026-10-20.
  This is "the world moved away from the document", not "the document moved
  away from its stamp". The two must not be conflated in the round record.

## 5. Proposed correction — append-only, and how to preserve it

### 5.1 Decision

**Required**, but as a dated provenance erratum appended at EOF — not a
rewrite of any existing line, not a re-interpretation of the 2026-09-28
findings, and not a change to the `Reverify:` line. Without it, a reader who
follows the entry's own pointer reaches a file that no longer contains the
quoted section, and the corpus has no record that the path was checked.

Keep `Reverify: R11-01, R11-04` unchanged. The rows resolve and are the right
pins; the deferral is host state. Converting to
`by-hand: control-plane-scratch — …` would misrepresent a resolvable row as
unverifiable-in-principle and would move `R14-01`'s counts (`row_linked`
21 → 20, `by_hand` 3 → 4) — an expectation migration that is not earned.

### 5.2 Exact proposed append (paste at EOF, nothing above edited)

The outer fence is report formatting only — paste the block content, not the
fence lines.

```markdown
## Provenance recheck — 2026-10-20 (round 22, read-only)

No line above was edited. This block records only what was measurable on the
host on 2026-10-20, because the source block no longer resolves:

- `~/.local/bin/tac-check`, `~/.local/state/tac/daybreak-blue-access.json`,
  `~/.local/state/the-janitor/tac-daybreak-blue.json` and
  `~/.local/state/tac/handoff-status.json` are absent; the directories
  `~/.local/state/tac` and `~/.local/state/the-janitor` are absent too.
- `~/.local/bin/the-janitor` is absent, so the predicate the gate tests for
  the two declared rows (`-x ~/.local/bin/the-janitor`) is false and
  `R11-01`/`R11-04` defer rather than verify. Deferral is host state, not a
  passing check.
- `~/.agents/AGENTS.md` is present (949 bytes) but carries no janitor section
  and no `tac-register` string, so the sentence quoted under §Custody record
  semantics cannot be resolved against it today.
- Consequence: the sections above stand as the 2026-09-28 reading — a dated
  historical record, not currently re-verified facts. Nothing here asserts
  what the check, receipt or custody record contain now.
- recheck: when the-janitor/tac-check are reprovisioned (substrate present),
  or when ~/.agents/AGENTS.md gains a janitor section; then re-read L19–31,
  L36–49, L52–58, L63–71, L83–88 of tac-check, re-run R11-04, and supersede
  this block with a new dated append (never edit it).
```

Constraints that make the append legal under the corpus rules:

- The block must not introduce a line beginning with the literal `Reverify`
  (`corpus/claim-ledger.sh:865–871` refuses any extra `^Reverify` hit, exit 2).
  The draft above avoids it; the `recheck:` line is inert to the parser.
- Append at EOF only. The file's 80 existing lines, including the source block
  and the `Reverify:` declaration, stay byte-identical — the entry's history is
  not rewritten to match the new environment.
- No claims about live access, entitlement, or the receipt's current content
  are added; the block states absence and measurability only.

### 5.3 Re-stamp protocol (do not skip, do not auto-pin)

1. Append, then regenerate the row with the **reviewed** `stamp` subcommand,
   invoked with the full current path list so the row-set shrink guard does not
   fire:
   `bash corpus/claim-ledger.sh stamp $(cut -f1 corpus/stamps.tsv)`.
   `stamp` replaces the row set from the paths given; a partial invocation
   would be refused as a shrink (`round-12` guard) or, with `--prune`, would
   drop unrelated pins — never use `--prune` here.
2. **Do this only in a quiet tree.** At observation time the working tree was
   being edited by other lanes (`M corpus/QUALITY.md`, `M corpus/SOURCES.md`,
   `M corpus/knowledge/onepassword-machine-credentials.md`,
   `M corpus/knowledge/vault-openbao-token-lease-lifecycle.md`, plus untracked
   `corpus/lessons/round-22.md`, `plans/round-22.md`). A full-set re-stamp
   now would pin those in-progress bytes as if reviewed — the laundering the
   round forbids. Sequence: siblings land → tree quiescent → append + stamp in
   one reviewed commit.
3. Record the migration explicitly: old tuple
   `c77312306f2e6708d47aeaa4a483a27e3dbb9597b6b281f6cab4a71103f89665 / 80 / 3757`
   → new `<sha256> / <lines> / <bytes>` in the commit message and the
   append-only journal. Do not delete or rewrite the old tuple anywhere; the
   old row remains the provenance of the 2026-09-28 reading.
4. If the tree cannot be quiet this round: land the append, leave the row at
   `c7731230…`, and record the pending re-stamp as named debt. `verify` will
   then honestly print `STALE` for this one row until the reviewed re-stamp —
   that is the intended signal ("was the edit intended?"), not a failure to
   suppress. Do **not** hand-edit the row to silence it.

### 5.4 Ledger expectation migration

None is required for this entry:

| expectation | current | after append |
|---|---|---|
| `R12-03` `grep -c '[^[:space:]]' corpus/stamps.tsv` | `^63$` | `^63$` (append adds no row) |
| `R14-01` docs audit | `entries=24 row_linked=21 by_hand=3` | unchanged (declaration untouched) |
| `R11-01`, `R11-04` rows | resolvable, `[substrate]` | unchanged |

If an owner instead rewrites the `Reverify:` line, that is an expectation
migration (21 → 20 row-linked, 3 → 4 by-hand) and must be documented with the
same before/after evidence; this report recommends against it.

### 5.5 Append-only preservation requirement (statement for the integrator)

- The correction is **additive only**: no deletion, no in-place edit, no
  reordering, no "silent refresh" of the 2026-09-28 text or of the
  `Reverify:` line.
- The stamp history is preserved by recording the **old tuple in the
  migration record** before the reviewed re-stamp writes the new one. A stamp
  file is a snapshot, not an append-only log; the journal supplies the
  append-only history the file cannot.
- The new block must carry its own date and the read revision, so a later
  reader can tell which environment it describes (`c2cab35…`, 2026-10-20).

## 6. Reconciliation of the "nine previously dropped stamps" (adjacent, feeds C2)

Measured across every commit that touches `corpus/stamps.tsv`
(`301b9ec`, `4b8c018`, `2486643`, `587fda0`, `8a6ec16`, `bc1af88`, `fecee87`,
`c41af82`, `e1544c1`, `c2cab35`):

- Row counts: `28 → 33 → 44 → 48 → 52 → 54 → 56 → 63 → 63 → 63`.
- **Set-membership drops: 0 at every step.** No path ever disappeared from the
  stamp set.
- The only commit with exactly **nine textual line removals** is `e1544c1`
  ("round-21: post-landing correction…", 2026-10-19 19:45:42 -0300): `-9/+9`
  over the same nine paths. These are **in-place re-pins**, not deletions:

| path | old tuple (sha/lines/bytes) | new tuple (sha/lines/bytes) |
|---|---|---|
| `corpus/QUALITY.md` | `2b8ceed8…` / 49 / 8842 | `7425f091…` / 65 / 10642 |
| `corpus/README.md` | `21b7ce09…` / 118 / 22198 | `6837d22b…` / 118 / 22365 |
| `corpus/SOURCES.md` | `1cd6d240…` / 41 / 13863 | `db134917…` / 43 / 14261 |
| `corpus/claim-ledger.tsv` | `873eecf0…` / 54 / 16743 | `8a4019cf…` / 54 / 16986 |
| `corpus/knowledge/onepassword-machine-credentials.md` | `2cc5cfae…` / 30 / 5364 | `7635be81…` / 35 / 6240 |
| `corpus/knowledge/sops-age-key-rotation.md` | `9d73d218…` / 94 / 6257 | `ea99430f…` / 99 / 6796 |
| `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` | `c1d57e6d…` / 101 / 7270 | `5fd53351…` / 111 / 8597 |
| `corpus/lessons/round-21.md` | `4b8e7eac…` / 91 / 13903 | `c256e352…` / 121 / 17099 |
| `corpus/sources-census.sh` | `657cfc0b…` / 406 / 22239 | `03fb300a…` / 450 / 25950 |

(Full hashes are in the commit diff; prefixes are exact matches of the
`git diff c41af82 e1544c1 -- corpus/stamps.tsv` output.)

Implications for the C2 narrative:

- A statement that nine stamps were "dropped/deleted" is a **line-diff
  artifact**. As ledger history they were nine same-path re-pins made by the
  same correction commit that edited those nine artifacts. Nothing needs to be
  "restored"; what is owed is a migration record with the nine tuples above,
  which the commit message (`round-21: post-landing correction — …`) does not
  carry.
- `corpus/knowledge/tac-evidence-integrity.md` is **not** among them and was
  unchanged in that commit; its row is not part of the nine-stamp debt.
- The five stale rows named by the round-21 spot-check
  (`corpus/lessons/round-21-verifier-spotcheck.md`) are a different set and
  remain stale at `HEAD` (see §7); do not fold them into the nine.

## 7. Observed adjacent drift (not this entry's, time-bound)

At `HEAD` `c2cab35` (committed bytes), six stamp rows are stale:

| path | stamp | actual |
|---|---|---|
| `corpus/knowledge/config-layering.md` | `848b8e50…` 109/6621 | `9d4ac8c2…` 136/8088 |
| `corpus/knowledge/handler-on-disk-state.md` | `811572dc…` 247/17609 | `df6a5e5d…` 277/19329 |
| `corpus/knowledge/handler-trust-boundary.md` | `263c7b0e…` 285/17669 | `fa17fff3…` 316/19410 |
| `corpus/knowledge/janitor-env-contract.md` | `88dca63a…` 90/5111 | `dac43ef9…` 113/6372 |
| `corpus/lessons/round-18.md` | `614335f2…` 73/4216 | `b00b7dd8…` 80/4557 |
| `LOG.md` | `60a8fd36…` 1043/74864 | `51e76cf1…` 1050/75404 |

The first five match the round-21 spot-check's "five stale stamps"; `LOG.md`
became stale in the `c2cab35` integration commit itself. At working-tree time
(~18:35) the count was 10 because four files were being edited live by other
lanes (`QUALITY.md`, `SOURCES.md`, the two knowledge entries listed in
`git status`). No corpus-wide count in this report is a gate verdict; the
tree was moving.

`corpus/knowledge/tac-evidence-integrity.md` was **not** in either set, and its
mtime/hash were unchanged throughout the observation.

## 8. Exact proposed recheck scope (read-only; no host gates)

Run only when the substrate is expected back (or when `AGENTS.md` changes).
This is evidence gathering, not the gate; it does not invoke `drift-pins`,
`surface-census`, `claim-ledger`, `tac-check` or `the-janitor`.

```bash
# 1. the exact predicate the corpus uses for deferral
test -x "$HOME/.local/bin/the-janitor" && echo PRESENT || echo ABSENT

# 2. source identity against the committed baseline (drift-baseline.tsv:10)
sha256sum -- "$HOME/.local/bin/tac-check"
wc -l -- "$HOME/.local/bin/tac-check"
# expected: af95ca97b3e3542ccd3f3b4fb718b9208254dea7d133e118806aff53e6b2961d, 88 lines

# 3. content claims, only if (2) matches: read-only line ranges
sed -n '19,31p;36,49p;52,58p;63,71p;83,88p' "$HOME/.local/bin/tac-check"

# 4. the two content pins in drift-symbols.tsv:26-27
grep -nE 'LOCAL_RECEIPT_INTEGRITY: OK' "$HOME/.local/bin/tac-check"   # expected L63
grep -nE 'LIVE_ACCESS_NOW'             "$HOME/.local/bin/tac-check"   # expected L69

# 5. state sources: existence + mode/size only, never receipt contents
stat -c '%a %s %n' \
  "$HOME/.local/state/tac/daybreak-blue-access.json" \
  "$HOME/.local/state/the-janitor/tac-daybreak-blue.json" \
  "$HOME/.local/state/tac/handoff-status.json"

# 6. the quoted sentence's home
grep -n 'tac-register' "$HOME/.agents/AGENTS.md"
```

Falsifiers / next actions:

- Step 1 `ABSENT` with steps 2–5 also absent → current state persists; the
  appended block stands; deferral remains the honest verdict.
- Step 1 `PRESENT` and step 2 mismatch → the entry's `L19–31/L36–49/L52–58/
  L63–71/L83–88` refs may have moved; re-read before citing, expect
  `drift-pins` to report `MISSING`/`MOVED`/`GONE` (exit 1), and append a
  second dated erratum rather than re-pinning content claims.
- Step 1 `PRESENT`, step 2 match, step 4 positions match → the entry's
  source-layer claims are confirmed at that revision; record the new
  observation date without editing the 2026-09-28 text.
- Step 6 finds the sentence → the citation resolves again; note it in a new
  dated append; the earlier block stays.

Out of scope by lane contract: no `bash corpus/drift-pins.sh`,
`bash corpus/surface-census.sh`, `bash corpus/claim-ledger.sh verify/docs`,
no `tac-check`/`the-janitor` invocation, no receipt-content read, no package
install (none was needed).

## 9. Provenance (exact)

| item | value |
|---|---|
| base revision | `c2cab35bc92e57e39e5489bac3386db078345b3f` |
| entry file | `corpus/knowledge/tac-evidence-integrity.md` |
| entry sha256 / lines / bytes | `c77312306f2e6708d47aeaa4a483a27e3dbb9597b6b281f6cab4a71103f89665` / 80 / 3757 |
| stamp row | `corpus/stamps.tsv:30`, same tuple |
| row first landed | `2486643` (2026-09-28 22:27:11 -0300), added to a pre-existing file |
| only content change | `9b3e49f` (round-2) `a8ee1fd9…` 78/3731 → `2486643` `c7731230…` 80/3757 (adds `Reverify:` + blank line) |
| row constant across | `2486643, 587fda0, 8a6ec16, bc1af88, fecee87, c41af82, e1544c1, c2cab35` |
| substrate predicate | `corpus/claim-ledger.sh:138–145`; deferral `:397–398` |
| drift baseline | `corpus/drift-baseline.tsv:10` (`tac-check 755 88 af95ca97…`) |
| symbol pins | `corpus/drift-symbols.tsv:26–27` (`L63`, `L69`) |
| AGENTS.md observed | 949 bytes, mtime 2026-10-20 09:18, no `tac-register` |
| nine re-pins | `git diff c41af82 e1544c1 -- corpus/stamps.tsv` = `-9/+9`, same nine paths |
| six stale at HEAD | §7 table (measured from `git show c2cab35:<path>`) |

## 10. Limits and remaining unknowns

- The gate was **not executed** (lane contract). The `DEFER` behavior and the
  `MISSING`/`GONE` alternative are read from `claim-ledger.sh` and
  `drift-pins.sh`; they are code-derived, not observed output.
- Host absence at 2026-10-20 is a state, not an explanation. I cannot tell
  whether the substrate was removed, never restored after a re-provision, or
  lives under another `HOME` for another user; I measured only
  `/home/vgpnk` at the stated times.
- The AGENTS.md quote's historical existence rests on past session transcripts
  (`~/.omp/agent/sessions/…`), not on a committed host snapshot. Treat the
  2026-09-28 attribution as unverified history; the 2026-10-20 absence is
  observed.
- The working tree was live-edited by sibling lanes during the audit
  (18:34–18:36 mtimes). The entry was untouched, but corpus-wide stale counts
  in §7 are timestamped snapshots, not gate verdicts.
- No depth claim and no legacy-header claims are made here; this report is
  scoped to freshness/calibration of one entry and its row.

## Parent checks after integration

1. `sha256sum corpus/knowledge/tac-evidence-integrity.md` — must equal the
   reviewed new hash after any append; before the append it must remain
   `c7731230…`.
2. `bash corpus/claim-ledger.sh verify` — expect `CLEAN` at the stamped set,
   or exactly the stale rows named in §7; the tac row must not appear as
   `STALE` before the append, and must appear once (only) until the reviewed
   re-stamp after the append.
3. `bash corpus/claim-ledger.sh docs` — expect
   `entries=24 row_linked=21 by_hand=3 undeclared=0 missing_ids=0 unpinned=0`
   unless the `Reverify:` line was changed (it should not be).
4. If the append lands: `bash corpus/claim-ledger.sh stamp $(cut -f1 corpus/stamps.tsv)`
   in a quiescent tree, then re-run (2) and record the old→new tuple.

Revision: `c2cab35bc92e57e39e5489bac3386db078345b3f`; report written
2026-10-20 (round 22, Entry22), read-only.
