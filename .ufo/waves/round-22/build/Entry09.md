# Entry09 — drift-gate.md freshness/calibration audit

Seat: read-only scout. Base: `c2cab35bc92e57e39e5489bac3386db078345b3f`.
Scope: `corpus/knowledge/drift-gate.md` and its `corpus/stamps.tsv` row only.
Method: in-repo bytes + git objects + parent-repo (`/home/vgpnk/Projects/shokunin`)
read-only history. No host gate was run; no host file was read. No installs.

## Verdict

1. **No stale-byte mismatch.** The stamp row is exact for the current file:
   `corpus/knowledge/drift-gate.md  c58dc578…0a0  201  13232`
   (row 17) = `sha256sum` `c58dc5787a39c014884410e25cf6b6f6c0d1de77b2ad5d03726c773d04f0d0a0`,
   `wc -l` 201, `wc -c` 13232. This row must not be re-pinned or removed for the
   current bytes; an appended correction changes them and requires the same-commit
   regeneration specified below.
2. **Substantive freshness is not clean.** Three source-bound defects remain inside
   the accepted bytes (below). The stamp is a revision pin, not a truth claim — it
   says "this is the revision read", not "every claim in it resolves at HEAD".
3. **An appended correction is needed** for items S1–S3. It must preserve the
   original text and be followed by a same-commit stamp-row regeneration.
4. **This row is not among any dropped-stamp set in committed history**: it appears
   in all nine commits that ever touched `corpus/stamps.tsv` (see §History).

## Calibration adjudications (C1 — decisions, not row counts)

| Proposition | Decision |
|---|---|
| `drift-gate.md` is stale by bytes / row must be re-pinned | **REJECT** — sha/lines/bytes exact |
| The stamp row was dropped or silently rewritten | **REJECT** — present in all 9 revisions, values change only with doc bytes |
| All 9 hashed files are mode 644/755 | **REJECT** — one is 600 (baseline:15) |
| `PROTOCOL.md` L292–298 resolves today | **REJECT** — valid only at parent `4c81066`; base range points at unrelated text |
| The quoted sentence is still verbatim at parent HEAD | **REJECT** — now "A pin counts only if …" |
| `git show HEAD:… \| grep -c baseline` → 0 | **REJECT at base** (16); **ACCEPT** only as `ea77bf0` |
| Host gate is CLEAN today / selftest passes today | **UNADMITTED** — host gate not run by this lane |
| "0 `op.env` key names" in the TSVs | **UNVERIFIED** — private key set not in repo |
| 13-case selftest is what the script ships | **ACCEPT as source-bound structure** (13 `run` cases); execution unverified |

## Evidence — what is fresh

| Claim in entry | Read | Result |
|---|---|---|
| `drift-pins.sh` round-9 v2, 451 lines, sha `c138d34c…0feb` | `sha256sum`, `wc -lc` | `c138d34c7f0d…c70feb`, 451 / 19088 — exact |
| `drift-baseline.tsv` 15 rows | `wc -l`, tab split | 15 rows; 6 `-` (nohash), 9 hashed |
| `drift-symbols.tsv` 20 rows | non-comment rows | 20 data rows (30 file lines / 2003 B; stamp exact) |
| 13-case selftest | `grep '^  run "'` | 13 `run` cases; `DRIFT_SELFTEST: PASS (%d cases)` at L444 |
| Reproduction `files=15 symbols=20` | baseline/symbols counts | structurally forced by the stamped inputs; counts corroborated by `corpus/checklist.tsv:26` `^DRIFT_PINS: CLEAN \(files=15 symbols=20\)$` |
| `--pin` texts: `REPIN`, `MOVED`, count refusal | script L314 / L356 / L336 | present verbatim at the cited script hash |
| v1: 13 files, mode+size/sha16/lines, no baseline, exit 0 | `git show ea77bf0:corpus/drift-pins.sh` | 13 paths, printer-only, no `baseline` token; `grep -c baseline` = 0 |
| R11-04 / R11-05 resolve | `corpus/claim-ledger.tsv:18-19` | both rows exist; `Reverify:` line is in the required form |
| `op://` absence in TSVs | `grep -c op://` | 0 / 0 — supported |
| 6 nohash / 15 total; 9 hashed | baseline modes | 6 `-`; hashed modes 755×3, 644×5, **600×1** |
| `state-shape.tsv` pins opencode.log + db | `corpus/state-shape.tsv:27-38` | both present; file introduced at `03477c0` (round 10) |
| 13-case reproduction not run here | — | execution is a host gate; deferred (see §Recheck) |

## S1 — hash-policy mode overclaim (line 97)

The table row `| everything else | 9 files, mode 644/755 |` is false at the
committed baseline: one of the nine hashed rows is mode **600**:

```
corpus/drift-baseline.tsv:15  $HOME/.local/share/the-musketeer/chrome-profile/NativeMessagingHosts/com.1password.1password.json  600  10  05e1cd94…ce9b
```

It is hashed because its content is names/origins only
(`corpus/lessons/round-8-aggregator-box3-coldrun.md:64`), so the pin is defensible
but the class label is not. Correct decision: **reject the "644/755" class claim,
keep the hash**. The row was introduced with mode 600 at `e64e81b`; this is not
host drift.

## S2 — `PROTOCOL.md` anchor is stale at base (Sources line 6)

`L292–298` was exact against parent revision **`4c81066`** (2026-09-28 17:46:51
-0300, "protocol: round-9 improvements"): there the `## Evidence standard`
heading is L247 and the **Drift pins** bullet is L292–298, including the quoted
sentence and "2 of 13 files". At lane commit `e64e81b` (2026-09-28 18:20:49) that
was the then-current **committed** parent revision (`git log` order; the lane may
have read a working tree, unrecoverable); the next parent commit `43342dd`
(18:41:48) moved the bullet to L455. At parent HEAD `52b3863` (2026-10-20
18:34:37; PROTOCOL.md blob `886e459b…d4411a`, 533 lines, last changed by
`7c5b34f`) the heading is L343 and the bullet L370–372, and the wording is now
`A pin counts only if …`
(word order changed). `git show` over every PROTOCOL.md revision finds no other
revision where the pin sentence falls inside 292–298. The same stale citation is
duplicated at **`SCORECARD.md:19`** (`PROTOCOL.md:292-298`).

Correct decisions: **reject "L292–298 resolves today"**; **accept the rule** (it
is still present, relocated); require the correction to name revision `4c81066`
for the historic locus and L370–372 at parent HEAD.

## S3 — `git show HEAD:` command is now false as written (lines 15–16)

At `ea77bf0` the command `git show HEAD:corpus/drift-pins.sh | grep -c baseline`
printed **0** (verified). At the lane base the same literal command prints **16**,
because HEAD is v2. The header's "v1 read at HEAD `ea77bf0`" supplies the anchor in
prose, but the command itself is not reproducible. Correct decision: **reject the
command as currently written**; anchor it to `ea77bf0`. The same phrasing appears
in `SCORECARD.md:19` and is part of the correction sweep.

## Unresolved negatives / absent sources (no correction drafted)

- **Host verdict**: `DRIFT_PINS: CLEAN`, `--selftest` pass, and accept/reject of
  any `REPIN`/`MOVED` are host observations dated 2026-09-28. This lane may not
  run the host gate, so it cannot admit them as current. Not a claim change.
- **"0 `op.env` key names" (line 110)**: only the two named raw-value keys
  (`XAI_TEAM_ID`, `TOKEN_PLAN_INFNET_IDENT`) can be cross-checked in-repo, and
  neither appears in the TSVs; the full 10-key set is not persisted in the repo.
  `OP_SERVICE_ACCOUNT_TOKEN` appears in `drift-symbols.tsv:14` as a `the-janitor`
  selector, not attributed to `op.env`. The negative is unverified, not false.
- **Parent document is mutable and unpinned**: no stamp/id for `PROTOCOL.md`;
  the citation-gate explicitly does not check bare filenames
  (`corpus/knowledge/claim-ledger.md:328`). Any fix should cite a revision.
- **Uncommitted working tree at authoring is unrecoverable**; all statements above
  use committed objects only.

## History — stamp-row expectation migrations (exact)

Commits touching `corpus/stamps.tsv` (all nine, in order):

| Commit | Date | drift-gate row (sha / lines / bytes) | Doc revision at that commit |
|---|---|---|---|
| `301b9ec` round 11 | 2026-09-28 | `80098c97…ccd / 199 / 13206` | `03477c0` doc = `80098c97…ccd` |
| `4b8c018` round 13 | 2026-09-28 | `40a4da7f…6fc / 199 / 13206` | `4b8c018` doc = `40a4da7f…6fc`; symbols 19→20 row + prose `20` in same commit |
| `2486643` round 14 | 2026-09-28 | `c58dc578…0a0 / 201 / 13232` | `2486643` doc = `c58dc578…0a0` (+2 lines: `Reverify`) |
| `587fda0`–`e1544c1` (6 commits) | 09-28…10-19 | unchanged `c58dc578…0a0 / 201 / 13232` | no doc change |

Each doc-byte change was paired with a regenerated row **in the same commit**;
later stamps rewrites retained the row verbatim. Set-diff over all nine revisions
shows additions only (28→33→44→48→52→54→56→63); no row was dropped. The round-12
lesson's uncommitted `stamp` incident ("dropped 18 of 28 rows") has no committed
state and cannot be attributed to this row. **Decision: reject "drift-gate's stamp
was dropped/laundered"; reject re-pinning it now.**

## Proposed correction (append-only)

Append after `## Falsification`; do **not** edit the table row, the Sources line, or
the command in place. Preserve the superseded revision `c58dc578…0a0 / 201 / 13232`
by name. Content:

1. `:97` hash-policy class: 9 hashed files are 755×3, 644×5, 600×1; the 600 row is
   the 1Password NativeMessagingHosts manifest (`drift-baseline.tsv:15`), hashed
   because it is names/origins only; "mode 644/755" is superseded.
2. `:5-6` PROTOCOL anchor: exact at parent `4c81066` (heading L247, Drift-pins
   bullet L292–298); at parent HEAD `52b3863` (PROTOCOL blob last changed by
   `7c5b34f`) heading L343, bullet L370–372; quote wording now
   `A pin counts only if …`. Cite the revision.
3. `:15-16` command: anchor to `ea77bf0` (0); at lane base `c2cab35` the literal
   `HEAD` form prints 16.
4. Sweep `SCORECARD.md:19` (same range/command) under the correction-sweep rule;
   `SKILL.md:195` cites the section without lines and needs no range fix.

Preservation requirement: the correction is a **new appended entry**, never an
in-place rewrite or deletion; old sha stays recorded. After the append, in the
same reviewed commit, regenerate `corpus/stamps.tsv` line 17 to the new
sha/lines/bytes (`sha256sum` + `wc -l` + `wc -c`) without deleting/reordering any
other row. Do not run `stamp` on a subset without `--prune`.

## Exact recheck scope (parent-run; not by this lane)

1. `bash corpus/drift-pins.sh` → `DRIFT_PINS: CLEAN (files=15 symbols=20)`, exit 0
   (checklist E1 exact line). Any `DRIFT`/`MOVED`/`GONE` is a host-state event.
2. `bash corpus/drift-pins.sh --selftest` → `DRIFT_SELFTEST: PASS (13 cases)`, exit 0
   (R11-05).
3. `bash corpus/claim-ledger.sh verify` → no `STALE`/`MISSING` for
   `corpus/knowledge/drift-gate.md`; `docs` mode sees the `Reverify:` line and row.
4. After any edit: recompute `sha256sum corpus/knowledge/drift-gate.md` and
   `wc -lc`; the row must match before commit.
5. Sweep: `grep -rn --include=*.md "PROTOCOL.md:292\|L292–298" corpus SKILL.md SCORECARD.md`
   (expect drift-gate + SCORECARD); same paths for
   `grep -rn --include=*.md "git show HEAD:corpus/drift-pins.sh"`.
6. Mode check: `awk -F'\t' '$4!="-" && $2!="644" && $2!="755"' corpus/drift-baseline.tsv`
   → exactly one row (line 15).

No depth move is claimed; this audit adds no header rows and no new count claims.
