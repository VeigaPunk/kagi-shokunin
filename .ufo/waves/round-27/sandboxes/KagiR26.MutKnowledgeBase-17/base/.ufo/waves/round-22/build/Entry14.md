# Entry14 — `janitor-lifecycle.md` stamp + freshness audit (read-only)

Axes: **calibration** (adjudicate this entry's freshness declaration honestly, reject over/under-claims)
and **freshness** (stale-byte mismatch vs substantive currentness; absent-source limits).
No depth move, no legacy-header count claim, no host gate executed, no delegation, no install.

## Read revision and inputs

| item | value |
|---|---|
| frozen base | `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD = `origin/master` = base) |
| jj working-copy commit | `34dc1454c6e42c8afdcd4da64476963eeee27d14` (`@`, empty description) |
| history | 45 commits, full (no `.git/shallow`); `rev-list --all` = 49 (4 `refs/jj/keep/*`) |
| read at | 2026-10-20T21:39:39Z |
| target | `corpus/knowledge/janitor-lifecycle.md` — 81 lines, 5598 bytes, sha256 `13c53ed256e6604e5df739c505d7cbd0d7dee865caa3c653502d47bd49dd3fb8` |
| stamp row | `corpus/stamps.tsv:22` — `corpus/knowledge/janitor-lifecycle.md<TAB>13c53ed2…f3b8<TAB>81<TAB>5598` |
| `stamps.tsv` blob | sha256 `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b` (identical to `.ufo/waves/round-22/frozen/before/corpus/stamps.tsv` and to base) |
| `claim-ledger.tsv` blob | sha256 `8a4019cfc1eec916f30a8958fbc3ca2d30e59632e0f1d5d843cea6d1c24faa97` (identical to frozen before and base) |

`expected.json` digests for both frozen inputs re-computed and match, so "before" is base-identical.

## Verdict

1. **Stamp row: FRESH.** No stale-byte mismatch. `stamp_cmp` semantics are `sha256sum`, `wc -l`,
   `wc -c` (`corpus/claim-ledger.sh:330–348`); all three equal the row. The committed blob at
   `c2cab35` and at `34dc145` hashes to the same value, so the row is not merely working-tree-green.
2. **Substantive freshness: DEFERRED, not verified.** The entry's basis is 2026-09-28 and every one of
   its host sources is absent today (below). Freshness of bytes ≠ currentness of facts (QM14).
3. **Appended correction: not needed for the stamp or for freshness.** One source-independent text
   defect exists; correcting it in-place is not justified without the source (see F1/F2 and §Proposed
   correction). Recommended home is the round-22 mistake ledger, which touches no pinned byte.

## Stamp provenance (observed)

- File revisions: `244b8c1` (round-5, created) → `51c9d30` (round-7) → `e64e81b` (round-9) →
  `2486643` (round-14). No later commit touches it; `git status` shows it unmodified.
- The path had **no stamp row** at `4b8c018` (round-13); the row was added at `2486643` (round-14,
  2026-09-28), the same commit that added the two-line `Reverify:` declaration, and it was created with
  the **post-edit** hash. It has not been modified since (`git log -S<sha>` returns exactly `2486643`).
- That is the round-14 fix of the round-9 failure class (entry with no revision pin), recorded as
  "10 of 17 were not in `corpus/stamps.tsv`" at `4b8c018`. No laundering shape: no re-stamp follows a
  content change for this row, and no old hash was replaced.
- Membership is closed: 63 rows now, 63 distinct paths ever pinned over all 45 commits, **0 deletions**
  at path level and 0 at line level (a removed line's path is always re-added in the same commit).
  Claim-ledger ids likewise: **0 drops** across history.

## Absent-source limits (observed, then derived)

Observed via `ls -ld`: `~/.local/bin/the-janitor`, `~/.config/the-janitor`, `~/.local/state/the-janitor`
all absent, including the three files the entry cites (`the-janitor`, `client.py`,
`~/.config/opencode/tools/janitor_auth.ts`). `corpus/knowledge/substrate-deferral.md` records the same
absence (2026-10-14) with its own `Reverify: R18-01, R11-09`.

Therefore, without running any gate, I cannot adjudicate: any line cite (`L121–135`, `L138–143`,
`L170`, `L173–184`, `L194`, `L237–249`, `client.py L41–95`), any exit text (`stopped` /
`already stopped`), any mode (`0600` on lock/session-id/db/log), the `status` shape, or the
`ensure_started`/`get_session_id` control flow. Drift since 2026-09-28 is **unmeasured, not absent** —
I did not find evidence of drift, and I do not claim the reverse.

Derived from code + filesystem (not executed): `substrate_present()` tests only presence+exec of
`~/.local/bin/the-janitor` (`claim-ledger.sh:138`), so it is false here; both declared ids carry the
literal `[substrate]` tag (`R11-01` note "declared surfaces + runtime shapes … [substrate]";
`R11-04` note "host-file + symbol drift … [substrate]"), so both rows **DEFER** under
`claim-ledger.sh:397–399` — a recorded absence, never a pass, never a FAIL.

Repo-side corroboration that survives absence (all 2026-09-28-era expectations, not live checks):
`drift-symbols.tsv` pins `OP_SERVICE_ACCOUNT_TOKEN` at `the-janitor` **L194** and
`exec op run --env-file` at **L248** — both inside ranges the entry cites; `client.py` L74
(`THE_JANITOR_REQUEST_TIMEOUT`) is inside its cited L41–95; `drift-baseline.tsv` records
`the-janitor` 333 lines/755 and `client.py` 117/755, so every cited line number exists;
`state-shape.tsv:27–40` and `surface-census.tsv:21–41` independently pin the four state objects the
table describes (lock 0600, session-id 0600 "stop removes it", db/log 0600, dir 700).

## Calibration adjudication of `Reverify: R11-01, R11-04`

- **R11-04** is the correct class of link: host-file + symbol drift directly covers the entry's source
  claims. It is currently deferring, so it proves absence, not freshness.
- **R11-01** is a **bounded control**, not an irrelevant row: the census/state-shape pair pins the
  existence, mode and shape of `client.lock`, `session-id`, the transcript DB and log — exactly the
  table's object-level claims. It does not cover the semantic claims (no rotation verb, token dies with
  the process, lazy `AUTH_REQUIRED`), so it must not be read as verifying them.
- Neither id is a fabricated-id defect: both resolve to exactly one row (39 ids, no duplicates), and
  the entry carries exactly one `^Reverify: ` line, so `docs` mode's shape rules hold.
- `SCORECARD.md` contains **0** mentions of this entry, so there is no cell pointer to repair for it.

## Findings

### F1 — real, source-independent text defect (do not fix without source)

`janitor-lifecycle.md:21` ends: "`ensure_started` also removes it when a foreign server squats the port
is ruled out and tmux session is absent (L92–97)". The clause is ungrammatical and supports at least two
different readings (squat present + session absent, vs squat ruled out + session absent). The two
readings differ in behaviour, so no rewrite can be verified while `the-janitor` is absent. This is a
readability/ambiguity defect only; it does not affect the stamp.

### F2 — cross-doc pointer is under-inclusive (sibling file, not my stamp)

`control-plane-hardening.md:90–91` cites "lifecycle evidence in
`corpus/knowledge/janitor-lifecycle.md` L18–21" for a sentence with two clauses: stop removes
`session-id`, and stop does not remove the transcript DB/log. At the current revision L18–21 is header,
separator, `client.lock`, `session-id`; the DB/log row is **L24**. This is **not** a round-14 shift
artifact: when authored at `51c9d30`, L18–21 mapped to `client.lock`, `session-id`, `OP_SESSION`,
`OP_SERVICE_ACCOUNT_TOKEN`, with the DB row at L22 — the range never included it. The correct range to
cover both clauses today is L18–24 (or cite L24). I cannot adjudicate whether `the-janitor`
L173–184/L190–225 covers the non-purge clause; that needs the substrate.

### F3 — "nine previously dropped stamps" is not reproducible from this history

Measured, not assumed: 63/63 stamp path membership, 0 deletions (path and line level); 0 claim-id drops;
unreachable snapshot `61add15` (2026-10-16, divergent from round-20's `65afae7`) has 56 rows with **7**
paths absent (onepassword, sops-age, vault-openbao, round-21, QUALITY, sources-census.sh, SOURCES),
none of them this entry; jj-kept `34dc145/6697761/8924b2e` carry `stamps.tsv` byte-identical to base.
What the history *does* contain is re-pins: 79 row rewrites over 31 distinct paths in 8 commits, and
exactly **nine** rows rewritten in each of `bc1af88` (round-17) and `c41af82` (round-21). If the wave's
"nine" refers to deletions, it needs an artifact outside reachable history; if it refers to rewrites,
those two commits are the exact anchor. `janitor-lifecycle` participates in neither.

### F4 — measure the revision, not the dirty tree

At base **and** at `@` the stale set is **6** (config-layering, handler-on-disk-state,
handler-trust-boundary, janitor-env-contract, lessons/round-18, LOG) — matching `before.json` exactly.
Over the current working tree it is **10**: four extra rows (`QUALITY.md`, `SOURCES.md`,
`onepassword-machine-credentials.md`, `vault-openbao-token-lease-lifecycle.md`) are uncommitted
round-22 drafts (`git status` M) and must not be counted as revision staleness. This entry is in neither
set; an auditor reporting 10 is measuring drafts against a base stamp file.

## Proposed correction (exact, minimal, append-only)

- **Stamp row:** no change. Keep
  `corpus/knowledge/janitor-lifecycle.md  13c53ed2…f3b8  81  5598` exactly; do not re-hash, do not
  delete, do not "refresh" lines/bytes.
- **Entry bytes:** no change this round. Recording the absence here would duplicate a global, already
  gated fact (`substrate-deferral.md`) and force a cosmetic re-stamp. Recommended instead: record F1/F2
  as named findings in the round-22 lesson's §Mistakes (owner lane; I did not edit it) and fix F1 in the
  first pass that has the substrate to adjudicate it.
- **If the owner nevertheless appends an erratum**, it MUST (a) be appended after the existing text,
  (b) state that no host fact was re-verified on 2026-10-20, (c) be committed with the stamp row updated
  in the *same* commit and a migration record: old `13c53ed2…f3b8 / 81 / 5598` → new measured
  sha/lines/bytes, motive, observed checks, and the explicit statement that the new hash is not
  freshness. A fresh hash never promotes absent sources to current.
- **F2** belongs to `control-plane-hardening.md`'s next substrate-present pass: re-check
  `the-janitor` L190–225, then either extend to L18–24 or narrow the sentence. Do not edit now.

## Exact proposed recheck scope

Repo-side (runnable immediately, no host, no gate):

1. `sha256sum corpus/knowledge/janitor-lifecycle.md` ⇒ `13c53ed2…f3b8`; `wc -lc` ⇒ `81 5598`.
2. `git show c2cab35:corpus/knowledge/janitor-lifecycle.md | sha256sum` ⇒ same.
3. `awk -F'\t' '$1=="corpus/knowledge/janitor-lifecycle.md"' corpus/stamps.tsv | wc -l` ⇒ `1`.
4. `grep -cE '^Reverify: ' corpus/knowledge/janitor-lifecycle.md` ⇒ `1`; `R11-01`/`R11-04` each resolve
   once and both notes contain `[substrate]`.
5. `grep -c 'janitor-lifecycle' SCORECARD.md` ⇒ `0`.
6. `sed -n '18,24p' corpus/knowledge/janitor-lifecycle.md` vs `sed -n '90,91p'
   corpus/knowledge/control-plane-hardening.md` ⇒ confirms L24 is outside the cited L18–21.
7. Staleness counts are computed from blobs (`git show <rev>:path`), never from the dirty worktree.

Host-side (only when `test -x ~/.local/bin/the-janitor` is true; never `op`/vault commands, never a
`request` that spawns a live handler):

8. `sed -n '121,135p;138,143p;170p;173,184p;194p;237,249p' ~/.local/bin/the-janitor` — each expected
   function/line present; mismatch ⇒ append erratum.
9. `sed -n '41,95p' ~/.config/the-janitor/client.py` — `get_session_id` fallback/404 logic at L41–46,
   session write at L57–63.
10. `sed -n '1,14p' ~/.config/opencode/tools/janitor_auth.ts`; `stat -c '%a %s'
    ~/.local/state/the-janitor/{client.lock,session-id}` and the db/log modes (0600).
11. `the-janitor status` shape: `state stopped|running`, `handler_session pending|<id>`,
    `authorization process_memory_only`; `tmux has-session -t janitor` ⇒ exit 1 when stopped.
12. `bash corpus/drift-pins.sh` (R11-04) — expected CLEAN only if the restamped-by-nobody baseline still
    matches the restored host; any DRIFT is a host event to record, not a doc defect to launder.

Acceptance: every item passes by exact text/mode, or the failure is appended as an erratum with the
stamp migration record above. No silent re-pin, no deletion.

## Append-only preservation requirement

- Preserve in place (no rebase/amend/squash): `244b8c1`, `51c9d30`, `e64e81b`, `2486643`, and the
  first-pin row in `2486643`. The first-pin event with the post-edit hash is the proof of no laundering.
- Preserve the frozen evidence: `.ufo/waves/round-22/frozen/before/corpus/stamps.tsv`
  (`0ce7fa4f…`) and `.../claim-ledger.tsv` (`8a4019cf…`), both verified equal to base.
- If this entry is ever retired, its row is not deleted; retirement requires the QM14 itemization
  (old row values, justification, observed checks).
- Bound: `stamps.tsv` has no row for itself (no self-reference); its integrity rests on git and the
  frozen digest, not on a revision pin.

## Limits

- No host gate, no `claim-ledger.sh` mode, no `drift-pins.sh` run: verdicts above are derived from
  source + filesystem + git blobs, not from a gate's output.
- jj operation log deliberately not queried (live-lane contention); only `refs/jj/keep/*` snapshots were
  read via git.
- `corpus/claim-ledger.sh` was concurrently edited by a sibling during this audit (`git status` M). The
  cited lines 138, 330–348 and 397–399 were re-checked identical in the base blob and in the worktree at
  read time; any later re-citation should quote the base blob.
- I did not inspect network, vault, or account state; no secrets were read or written.
- F1/F2 are the only textual defects I can support without the substrate; neither changes the stamp.

## Checks the parent should run after integration

1. `sha256sum corpus/knowledge/janitor-lifecycle.md corpus/stamps.tsv` ⇒ `13c53ed2…`, `0ce7fa4f…`
   (unless an erratum was deliberately appended, in which case the migration record must exist).
2. `awk -F'\t' '$1=="corpus/knowledge/janitor-lifecycle.md"' corpus/stamps.tsv | wc -l` ⇒ 1.
3. `grep -cE '^Reverify: ' corpus/knowledge/janitor-lifecycle.md` ⇒ 1.
4. Recompute the stale set from base blobs ⇒ expect exactly the 6 in `before.json`, with this entry
   absent; reject any count taken over the dirty worktree.
5. If any sibling appends to this entry or to `control-plane-hardening.md`, re-run the byte comparison
   and require the same-commit migration record.

Installs/updates: none (no package transactions, no uv/npm/cargo installs; host pacman paused).
Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f`, `@` `34dc1454c6e4`, target digest
`13c53ed256e6604e5df739c505d7cbd0d7dee865caa3c653502d47bd49dd3fb8`.
