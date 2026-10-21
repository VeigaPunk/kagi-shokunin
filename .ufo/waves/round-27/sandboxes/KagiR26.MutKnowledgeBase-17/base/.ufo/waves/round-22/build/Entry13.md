# Entry13 — `janitor-env-contract.md` + stamp row: freshness/calibration audit

Read-only leaf audit. Target: `corpus/knowledge/janitor-env-contract.md` and its
row in `corpus/stamps.tsv`. Axes exercised: **freshness** (stale-byte vs
substantive, ledger expectation) and **calibration** (what may be asserted).

- Frozen base: `c2cab35bc92e57e39e5489bac3386db078345b3f` (`git rev-parse HEAD`).
- Audited pair is unmodified in the working tree: `git status --porcelain` lists
  neither the entry nor `corpus/stamps.tsv`.
- No host gate was run (`verify`, `cells`, `docs`, `drift-pins.sh`,
  `sources-census.sh`, the SCORECARD node freshness command). No vault/account/
  secret operation, no source-byte read, no install (no package transaction).
- Writes: this report only.

## 1. Decisions (calibration is measured as decisions, not authored counts)

| # | Proposition under audit | Decision | Basis |
|---|---|---|---|
| A1 | The stamp row is stale at byte level | **CONFIRMED** | `88dca63a…/90/5111` stamped vs `dac43ef9…/113/6372` actual |
| A2 | The entry's substantive source basis changed since the pin | **REFUTED** — one append-only qualifier was added; no host fact was re-derived | `head -90` hashes to the stamped digest exactly |
| A3 | An appended correction to the entry is needed for freshness | **REJECTED** — the round-16 erratum already qualifies every source-derived span; adding text would not add evidence | §4 |
| A4 | The entry's source claims can be re-verified this round | **REJECTED** — all four cited source paths are absent; re-pinning bytes is not re-verification | §5 |
| A5 | The round premise "nine dropped historical stamp members" = nine deleted rows | **REFUTED as deletions; RE-CHARACTERISED** as nine *stale* rows at `aea7a43` | §6: 0 row removals across 42 first-parent commits; membership monotonic 28→63 |
| A6 | This row can be re-pinned as an isolated one-row `stamp` run | **REJECTED** — `stamp` replaces the whole row set and recomputes all 63 rows | §7 |
| A7 | The entry's own erratum pointers into `SCORECARD.md` are still accurate | **PARTLY REFUTED** — line ranges drifted; the cited "result" line is now outside the cited range | §8 |

Base-state correction to the round premise: the ledger carries **six** stale
rows at `c2cab35` (the five named by round 21 plus `LOG.md`), and **zero**
missing/unresolvable pins. "Five stale stamps and nine deletions" does not
describe the measured base.

## 2. Stale-byte mismatch — exact measurement

```
$ sha256sum corpus/knowledge/janitor-env-contract.md
dac43ef973938efaba5f990fd185d6137b0d66b1703ef714c44d2b3eedd492a4
$ wc -l -c corpus/knowledge/janitor-env-contract.md
113    6372
$ sed -n '21p' corpus/stamps.tsv | cat -A
corpus/knowledge/janitor-env-contract.md^I88dca63ac7e6137f6a737439f18e99b9f602f57a065c63c478c364b46d873c1f^I90^I5111$
```

(One TAB-separated row: path, sha256, lines, bytes.)

All three stamped columns disagree. Delta: `+23` lines, `+1261` bytes.
Repo-wide read-only detector over the same ledger (63 rows) found exactly six
disagreements and **no** `MISSING`, no `NOT-A-FILE`:

```
corpus/knowledge/config-layering.md        848b8e50…/109/6621 -> 9d4ac8c2…/136/8088
corpus/knowledge/handler-on-disk-state.md  811572dc…/247/17609 -> df6a5e5d…/277/19329
corpus/knowledge/handler-trust-boundary.md 263c7b0e…/285/17669 -> fa17fff3…/316/19410
corpus/knowledge/janitor-env-contract.md   88dca63a…/90/5111   -> dac43ef9…/113/6372
corpus/lessons/round-18.md                 614335f2…/73/4216   -> b00b7dd8…/80/4557
LOG.md                                     60a8fd36…/1043/74864 -> 51e76cf1…/1050/75404
```

## 3. Provenance — the delta is exactly the reviewed erratum

- **Pin created** at `2486643` (round-14, 2026-09-28): the row is present with
  `88dca63a…/90/5111` and is unchanged through `aea7a43`, `c41af82`, `e1544c1`
  and `c2cab35` (`git log -S'88dca63ac7e6137f' -- corpus/stamps.tsv`).
- **Entry edit history** (`git log -- corpus/knowledge/janitor-env-contract.md`):
  `486f584` (round 4) → `148ae5c` (round 8) → `e64e81b` (round 9) →
  `2486643` (round 14) → `f4a8dd9` (round-16 re-dispatch, 2026-10-15).
  `f4a8dd9` is the only post-pin edit.
- **The post-pin edit is append-only at commit level**:
  `git show --numstat --format= f4a8dd9 -- corpus/knowledge/janitor-env-contract.md`
  → `23  0` (23 insertions, 0 deletions). `git merge-base --is-ancestor f4a8dd9 HEAD`
  succeeds. `f4a8dd9` did **not** touch `corpus/stamps.tsv`, which is why the row
  was left stale.
- **The stamped artifact is a verbatim prefix of the current file**:

```
$ head -90 corpus/knowledge/janitor-env-contract.md | sha256sum
88dca63ac7e6137f6a737439f18e99b9f602f57a065c63c478c364b46d873c1f  -
$ head -90 corpus/knowledge/janitor-env-contract.md | wc -l -c
90    5111
```

That is stronger than "no other edits": the exact bytes the ledger pins are the
first 90 lines of the shipped file. Line 91 is the blank separator, 92–113 the
erratum. `113 − 90 = 23` lines and `6372 − 5111 = 1261` bytes, matching the
commit numstat.

## 4. Substantive freshness (what did and did not change)

Changed: the appended block `92-113` only. Unchanged, byte-identical:
lines `1-90` — the source basis (`2408b0c9…57edd`, 333 lines), the ten-row knob
table, the auth-selector pseudocode, the endpoint conclusion, the leak-surface
notes and the falsification recipes.

The appended block makes no new host claim. It states the entry is historical,
enumerates the original spans it qualifies (`3-6`, `10-23`, `25-51`, `53-63`,
`65-77`, `79-90` — each span verified against the current headings at 10, 25,
53, 65, 79), preserves the abbreviated hash without expanding it, and refuses
to claim a current hash, line count, auth behavior, endpoint value or handler
behavior. The erratum's own extent `92-113` matches the file length and matches
`SCORECARD.md`'s outcome citation.

**No appended correction is indicated for freshness.** The entry is not
overclaiming in current voice; it is qualified. Editing it would either restate
the erratum or add text unsupported by any new read. The freshness defect is in
the **ledger row**, not the prose.

## 5. Absent-source limits (all unverifiable, by design)

Presence check on 2026-10-20 (metadata only, no contents read):

```
ABSENT  ~/.local/bin/the-janitor
ABSENT  ~/.config/the-janitor/client.py
ABSENT  ~/.config/the-janitor/config.json
ABSENT  ~/.config/the-janitor/op.env
```

Consequences for this entry: the knob defaults, read sites `L7–27`,
`L194–210`, `client.py L74`, the dynamic `OP_SESSION_<domain>` construction, the
`MODEL_ENDPOINT`/`baseURL` conclusion and every leak-surface sentence remain
**unverifiable** — the erratum's 2026-10-15 absence finding still holds five
days later. The abbreviated handler hash and "333 lines" must not be expanded
or re-asserted. Re-pinning the entry's bytes proves only that the shipped file
is the reviewed file; it proves nothing about `the-janitor`. Any
"entry refreshed/verified" phrasing would be a new overclaim and must be refused.
The entry's `Reverify: R11-02, R11-04` pointer is decidable but both rows are
tagged `[substrate]` in `corpus/claim-ledger.tsv`, i.e. they **DEFER** while the
handler is absent — a deferral is not a pass.

## 6. Premise reconciliation — "nine dropped members" is nine *stale* rows

Exact history measured with `git rev-list --first-parent HEAD` (42 commits) and
per-commit tree blobs of `corpus/stamps.tsv`:

- Row **removals** across the whole chain: **0**. Membership only grows:
  `28 → 33 → 44 → 48 → 52 → 54 → 56 → 63`. The 63-row set first appears at
  `c41af82`.
- Stale-row counts recomputed from each revision's own tree:
  `301b9ec…fecee87 = 0`; **`aea7a43 = 9`**; `c41af82 = 5`; `e1544c1 = 5`;
  `c2cab35 = 6`.
- The nine at `aea7a43`: `config-layering.md`, `handler-on-disk-state.md`,
  `handler-trust-boundary.md`, `janitor-env-contract.md`,
  `lessons/round-18.md`, `op-ref-probe.sh`, `README.md`, `LOG.md`,
  `SCORECARD.md`. `c41af82` re-pinned four of them (`op-ref-probe.sh`,
  `README.md`, `LOG.md`, `SCORECARD.md`); `e1544c1` later re-pinned four other
  artifacts after its post-landing edits (`claim-ledger.tsv`,
  `onepassword-machine-credentials.md`, `sops-age-key-rotation.md`,
  `vault-openbao-token-lease-lifecycle.md`). `c2cab35` (merge) appended 7 lines
  to `LOG.md` without re-stamping, so `LOG.md` is the sixth stale row at base.

The only "nine" in the reachable record is `LOG.md:983`:
"`aea7a43`: 9 rows mismatched (`sha256sum --check` over `corpus/stamps.tsv`)".
No artifact reachable from this checkout records nine *deletions*; the only
recorded deletion event in the lane's history is the round-12 in-flight
10-path stamp that dropped 18 rows, prevented afterwards by the per-path
`--prune` guard (`corpus/README.md:63`). The outside verifier's report itself
was not found in `.ufo/reports/round-22` or fleet state (only `kasegi.md`,
`kotodama.md`), so the wording cannot be checked directly.

**Recommended wording for the round record:** "nine stale pins at `aea7a43`;
four re-pinned in `c41af82`; five inherited plus `LOG.md` (re-staled by the
`c2cab35` merge) = six at base; zero row removals." Do not restate "nine
deleted" as measured fact.

## 7. Ledger expectation migration (exact, with historic evidence)

`stamps.tsv`'s contract (`corpus/claim-ledger.sh` header lines 14–17): one row
per cited artifact; `verify` recomputes and reports `STALE`/`MISSING` "so a
reviewer can state which revision was read and prove the shipped revision is
the stamped one"; "Regenerating is a reviewed commit, not an automatic re-pin."
Round 21 (`corpus/lessons/round-21.md:85`) reads that as: re-pinning without
review "would bless edits no round claimed". Both readings agree on the
mechanism — **a re-pin is legitimate only when the intervening change is
attributed**.

For this row the intervening change is fully attributed (`f4a8dd9`, +23/0,
prefix-verified), so a re-pin is permitted. Record it as a two-epoch migration,
not a silent overwrite:

| Epoch | Revision window | Row identity |
|---|---|---|
| E0 pre-erratum | `2486643` … `f4a8dd9^` | `88dca63a…/90/5111` |
| E1 post-erratum | `f4a8dd9` … `HEAD` | `dac43ef9…/113/6372` |

The migration note must carry: the old row verbatim, the new row, the append
commit `f4a8dd9`, the `head -90` prefix-equality proof, and the sentence that
**no host fact was re-verified**. Preserve E0 in the round report and the
`LOG.md` append; never drop it from the record.

Two expectation rules the round should state explicitly, because both caused
current drift:

1. **Self-referential artifacts** (`LOG.md`, `SCORECARD.md`) cannot be current
   at the same commit that appends to them. `LOG.md` was re-pinned to
   `1031/73471` at `c41af82`, re-pinned again to `1043/74864` at `e1544c1`
   (after that commit appended 12 lines), then re-staled by the `c2cab35` merge
   (`+7` lines: `1043/74864` stamped vs `1050/75404` actual). Either declare
   them pinned as-of the previous close (named debt) or require the final stamp
   computation to be the last write.
2. **`stamp` is whole-set.** `stamp()` refuses to shrink the row set without
   `--prune`, but it recomputes every named path. A run that names all 63 paths
   today would silently re-pin the other five unaudited stale rows. It must not
   be used to "fix" one row.

## 8. Calibration defect found in the entry (pointer, not claim)

The erratum cites `SCORECARD.md:454-466` and "the command/result at
`SCORECARD.md:496-506`". At base:

- `454-456` are now the round-21 move-log rows; the round-19 correction block
  it means is `458-470`, with the `janitor-env-contract.md:3-4` sentence at
  `465-466`. The cited range still *contains* the evidence, but now begins with
  four unrelated lines.
- `496-506` ends at the fenced `node -e` command; the **Observed** result line
  it promises is `508`, outside the range.

The citation gate resolves the path and tolerates line suffixes, so this is
gate-clean but semantically drifted — the known pointer-relevance ceiling, now
with a concrete instance. It does not falsify the erratum's claims and does not
change the source-status. If the integrator wants entry-local accuracy, append
a one-line pointer note mapping `454-466 → 458-470` and `496-506 → 504-508`.
If that append is taken, it must precede the stamp computation (§9 ordering),
must not touch lines `1-90`, and must not restate the erratum's substance.
Otherwise, record the drift in the round report and leave the entry untouched.

## 9. Proposed recheck scope (for the integration owner; not run here)

1. **Detector (read-only, repeatable).** Already executed for this report; the
   exact loop is:

```bash
while IFS=$'\t' read -r p sha ln by; do
  [ -f "$p" ] || { printf 'MISSING\t%s\n' "$p"; continue; }
  a=$(sha256sum "$p" | cut -d' ' -f1)
  l=$(wc -l <"$p" | tr -d ' '); b=$(wc -c <"$p" | tr -d ' ')
  if [ "$a" != "$sha" ] || [ "$l" != "$ln" ] || [ "$b" != "$by" ]; then
    printf 'STALE\t%s\t%s/%s/%s\t%s/%s/%s\n' "$p" "$sha" "$ln" "$by" "$a" "$l" "$b"
  fi
done < corpus/stamps.tsv
```

2. **Preferred re-pin (minimal diff, this row).** In the reviewed integration
   commit, replace `corpus/stamps.tsv:21` with
   `corpus/knowledge/janitor-env-contract.md<TAB>dac43ef973938efaba5f990fd185d6137b0d66b1703ef714c44d2b3eedd492a4<TAB>113<TAB>6372`
   and add the §7 migration note. Rationale: zero risk to the other 62 rows.
3. **Alternative (whole-set, only after all six are adjudicated).**
   `bash corpus/claim-ledger.sh stamp $(cut -f1 corpus/stamps.tsv)` → must print
   `STAMPED: n=63`; the resulting diff must contain exactly the adjudicated
   rows and **zero** removals. Never `--prune`; never a one-path or partial-path
   invocation (`stamp` would either refuse or require `--prune`, which drops 62
   rows).
4. **Acceptance evidence.** `head -90 corpus/knowledge/janitor-env-contract.md | sha256sum`
   still equals `88dca63a…` (append-only preserved); the new row equals the
   three recomputed columns; owner-run `bash corpus/claim-ledger.sh verify`
   reports no `STALE` for this path; `bash corpus/claim-ledger.sh docs` still
   row-links the entry via `R11-02`/`R11-04`; the citation gate stays clean for
   the entry.
5. **Ordering.** Any optional §8 pointer note and any `LOG.md`/`SCORECARD.md`
   append must land **before** the final stamp computation, or the new row is
   stale on arrival.

## 10. Preservation requirements (append-only)

- Lines `1-90` of the entry are immutable; the erratum is append-only and its
  claim text is not edited.
- The E0 row identity (`88dca63a…/90/5111`) is preserved verbatim in the
  migration record; a re-pin replaces the ledger row, never the history.
- The abbreviated handler hash is not expanded; no hash, line count, behavior
  or endpoint is re-asserted as current.
- No `--prune`, no partial `stamp`, no deletion of any pinned path.
- No correction rewrites in place; all corrections append.

## 11. Confidence and remaining unknowns

- **High:** byte mismatch and its three columns; prefix equality at 90 lines;
  pin commit `2486643`; erratum commit `f4a8dd9` (+23/0, ancestor of HEAD);
  zero membership removals across 42 first-parent commits; six stale rows at
  base; four source paths absent.
- **Medium:** identifying the verifier's "nine" with the `aea7a43` stale count.
  Inference from the only reachable "9" (`LOG.md:983`) plus the absence of any
  deletion record; the verifier report itself is not reachable here.
- **Unknown:** whether the outside verifier measured a different artifact
  (e.g. a fleet-ledger copy or a private clone). Nothing in this checkout
  supports nine deletions.

Checks the parent should run after integration (not run by this seat):
`bash corpus/claim-ledger.sh verify`, `bash corpus/claim-ledger.sh docs`,
`bash corpus/claim-ledger.sh citations --docs 'corpus/knowledge/janitor-env-contract.md'`,
plus the §9.1 detector and the §9.4 prefix check.
