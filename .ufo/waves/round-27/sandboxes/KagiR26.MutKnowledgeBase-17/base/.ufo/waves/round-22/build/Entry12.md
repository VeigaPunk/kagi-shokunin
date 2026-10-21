# Entry12 — freshness/calibration audit: `corpus/knowledge/janitor-command-surface.md`

Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD, `master`).
Read-only seat. No host gate was executed (no `drift-pins.sh`, `surface-census.sh`,
`claim-ledger.sh verify`, or `the-janitor`). Every count below is a byte/stat read
or a read of committed source; the one behavioural expectation about deferral is
marked `[INFERENCE]` and cites the policy lines that produce it.

Working tree was mid-wave at read time: `git status --porcelain -- corpus/` showed
four modified files (`QUALITY.md`, `SOURCES.md`, `onepassword-machine-credentials.md`,
`vault-openbao-token-lease-lifecycle.md`) and one untracked lesson. The audited entry
and `corpus/stamps.tsv` were unmodified. Verdicts below are stated against the
**committed base**; the in-flight edits are excluded and called out separately.

## Verdict

| question | verdict |
|---|---|
| stale byte mismatch vs its stamp row | **NO** — exact: 88 lines, 5764 bytes, sha256 `4d447b25…16dc`; identical in working tree, index and `HEAD:` blob |
| substantive freshness | **UNVERIFIABLE** — both cited sources and the whole handler substrate are absent; no host bytes exist to compare |
| appended correction needed | **YES**, but only a substrate-absence/historical marker. No content rewrite, no restamp-for-drift, no stamp deletion |

## Evidence (observed)

- Stamp row `corpus/stamps.tsv:20`:
  `corpus/knowledge/janitor-command-surface.md  4d447b25ffb49c85ef845da47bb2df92131c3fc55d5df4da7a0fd52cccaf16dc  88  5764`.
  Recomputed on disk: identical triple. `git show HEAD:… | sha256sum` is the same
  hash and `wc -lc` the same pair; `git diff HEAD -- <entry> corpus/stamps.tsv` is
  empty. So there is **no byte drift of the artifact and no lagging pin**.
- Provenance (`git log --follow`): added `9b3e49f` (2026-09-28, round 2), touched
  `4b8c018` (round 13), `Reverify:` line added `2486643` (round 14, 2026-09-28).
  Unchanged since; the stamp has been exact throughout its committed life.
- Absence of the sources (stat only, base date 2026-10-20):
  `test -x ~/.local/bin/the-janitor` → false; `command -v the-janitor` → empty;
  `~/.config/the-janitor` → no such directory; `~/.local/state/the-janitor` → no
  such directory. `corpus/lessons/round-18.md:15-19` records the same probe result
  at 2026-10-14; `considerthese/2026-10-19.md:77-78` states "missing from the host
  since round 18". So the substrate disappeared **between round 17 and round 18**,
  i.e. before the base freeze and before every round-21 claim about it.
- Last recorded source pin, `corpus/drift-baseline.tsv:1-2`: the-janitor 755 /
  333 lines / sha256 `2408b0c90b7e9057…7edd`; client.py 755 / 117 lines / sha256
  `8179b241c6f15fb9…ace51`. The baseline has not been edited since `e64e81b`
  (round 9, 2026-09-28), so it is a **pre-loss snapshot**. The competing
  `2eb86e1f…` hash in `round-18.md:60` is already corrected as append-only erratum
  at `round-18.md:74-79` (that prefix belongs to `surface-census.sh`). Do not revive it.
- Scope of the loss: 13 of the 15 `drift-baseline.tsv` paths are absent; only
  `~/.config/opencode/opencode.json` and `~/.agents/AGENTS.md` are present.
- Recheck links: the entry declares exactly one line, `Reverify: R11-02, R11-04`
  (line 8). `R11-02` is `surface-census.sh --verbs` and `R11-04` is
  `drift-pins.sh`; both notes end in the literal `[substrate]` tag
  (`corpus/claim-ledger.tsv:16,18`). `substrate_present()` tests
  `-x $HOME/.local/bin/the-janitor` (`corpus/claim-ledger.sh:138-144`), and a
  tagged row on an absent substrate prints `DEFER <id> reason=substrate-absent`
  and is not executed (`claim-ledger.sh:398-399`; policy
  `corpus/knowledge/substrate-deferral.md:27-38`). `[INFERENCE]` Both recheck
  links therefore **defer, not fail**, at this revision. They cannot confirm the
  entry while the substrate is absent.
- `corpus/README.md:19` repeats the present-tense `333 lines` / `117 lines` counts
  without a substrate marker. Same class of defect, different file; outside this
  seat's write scope, reported for the integrator.

## Calibration: what this entry may and may not claim

**Correctly bounded already.** It dates the read ("both read 2026-09-28") and warns
that line numbers are that day's, and "re-grep before trusting a number". It does
not claim a schema, completeness, or that every verb is reachable.

**Fails the bar as written.** QM1 (`corpus/QUALITY.md`): a property of a source the
host no longer carries must sit under an explicit historical marker; an unmarked
current-voice assertion of an absent file fails. Here the line counts and the whole
verb/failure/HTTP tables are present-tense assertions about files that have not
existed since round 18. The read-date is a provenance marker, not a substrate-absence
marker: nothing in the entry tells a reader that `the-janitor` is gone, so the entry
"reads as currently verified" — the exact failure `considerthese/2026-10-19.md:77-78`
names. The `Reverify:` declaration is not evidence of a confirming run either: both
ids defer.

**What must not be done.** Do not call this "stale" in the byte sense, do not
re-stamp it as a drift fix, and do not delete the stamp row to make an audit green —
any of those launders the real condition (unverifiable) into a false one (refreshed
or dropped). Do not re-pin `drift-baseline.tsv` to the empty host: round-18
(`round-18.md:52-55`) already ruled that this destroys the preserved record.

## Freshness context at base (not this entry's defect)

Read-only comparison of every stamp row against the `HEAD:` blob:

| stale at base `c2cab35` | stamp → base (`lines/bytes/sha12`) |
|---|---|
| `corpus/knowledge/config-layering.md` | 109/6621/848b8e50 → 136/8088/9d4ac8c2 |
| `corpus/knowledge/handler-on-disk-state.md` | 247/17609/811572dc → 277/19329/df6a5e5d |
| `corpus/knowledge/handler-trust-boundary.md` | 285/17669/263c7b0e → 316/19410/fa17fff3 |
| `corpus/knowledge/janitor-env-contract.md` | 90/5111/88dca63a → 113/6372/dac43ef9 |
| `corpus/lessons/round-18.md` | 73/4216/614335f2 → 80/4557/b00b7dd8 |
| `LOG.md` | 1043/74864/60a8fd36 → 1050/75404/51e76cf1 |

`janitor-command-surface.md` is **not** in this set. The round-21 statement of
"five stale stamps" (`corpus/lessons/round-21.md:85`) lists the first five; at the
base commit the count is **six**, because the base commit `c2cab35` itself added 7
lines to `LOG.md` without re-stamping it — a QM5 landing defect introduced by the
integration commit, not inherited debt. Against the live working tree the count is
transiently eight (`SOURCES.md`, `onepassword-machine-credentials.md` are being
edited by sibling lanes); those two are **not** stale at base and must not be
re-pinned from the in-flight tree until their lanes land.

## The "nine" — exact provenance, and it is not nine deleted stamps

`considerthese/2026-10-19.md:64` (added by the base commit) reads:
"claim-ledger verify was failing (5 failed, 9 stale; R12-02 expects 29 cases vs 36
now; R13-01 expects 20 rounds vs 22 …)". Measured 2026-10-18 at `ab7d8ca`, itself
an ancestor of base; the document says it was not re-run on 2026-10-19. "9 stale" is
a count of **stale ledger expectations**, i.e. `verify`'s `stale=` column — not nine
deleted stamp rows.

Independent check (read-only, all refs): committed `corpus/stamps.tsv` history
`301b9ec → 4b8c018 → … → c41af82 → e1544c1` has `removed=0` at every step
(28→33→44→48→52→54→56→63→63 rows; 0 deletions, 35 additions). `corpus/claim-ledger.tsv`
likewise shows `removed=0` at every step. `git for-each-ref` shows every ref that
carries the file at 63 rows. There is therefore **no committed deletion of nine
stamps to restore**, and fabricating nine rows would be the opposite of the C2 goal.

What is real and migratable:
- `R12-02` expectation `29` → `36`, already migrated at base (`claim-ledger.tsv:27`,
  note records the `aea7a43` landing and the round-21 re-pin to the measured 36).
- `R13-01` at base expects `23` (`claim-ledger.tsv:29`), with the row's note carrying
  the historic ladder `16 → 18 → 20`; the 2026-10-18 snapshot said "20 vs 22".
- The remaining count is the `verify` run's own `failed=5 stale=9`, which can only be
  enumerated by that run when the substrate is restored. Enumerating it now would
  require either executing host gates (forbidden here) or guessing row ids (prohibited).
  Hand this to the seat that owns the full history reconciliation; do not pre-fill it.

## Proposed correction (append-only, exact text)

Append at EOF. The block is 20 lines / 1251 bytes; with it the file measures
**108 lines / 7015 bytes / sha256 `9b2d16a7ac56fd83c5d23b58d664dcf63a75baede7f0532fc62a917ae41afb26`**
(computed in memory over the current base bytes plus this exact block, leading blank
line included, no trailing spaces). Projection is valid only if this block is copied
verbatim.

```
## Freshness correction (round 22, appended 2026-10-20 at base `c2cab35`)

The text above is preserved verbatim; nothing was re-measured or deleted.
- Absence check at `c2cab35`: `[ -x ~/.local/bin/the-janitor ]` → false;
  `[ -d ~/.config/the-janitor ]` → false; `[ -d ~/.local/state/the-janitor ]`
  → false. The substrate has been absent since round 18
  (`corpus/lessons/round-18.md`; `corpus/knowledge/substrate-deferral.md`).
- Last recorded source pin (`corpus/drift-baseline.tsv`, unchanged since
  `e64e81b`): the-janitor 755 / 333 lines / sha256 `2408b0c90b7e9057...`;
  client.py 755 / 117 lines / sha256 `8179b241c6f15fb9...`. Both are
  UNCHECKABLE now — no host bytes exist to compare, so absence is not drift.
- The two recheck ids in the `Reverify:` line above both carry the
  `[substrate]` tag (R11-02, R11-04) and therefore print
  `DEFER reason=substrate-absent` under `substrate-deferral`; neither can
  confirm this entry while the substrate is absent.
- This entry's own stamp was exact at `c2cab35`: 88 lines / 5764 bytes /
  sha256 `4d447b25ffb49c85ef845da47bb2df92131c3fc55d5df4da7a0fd52cccaf16dc`.
  Its verbs, line numbers and failure texts remain the 2026-09-28 observation,
  not a claim about the present host.
```

Why this text and not another: it records the observed absence with the literal
probes, keeps the source pin as the pre-loss record rather than replacing it with
`UNCHECKABLE`, and preserves the old self-stamp inside the appended text so the
stamp-row move is documented rather than silent. It adds no fifth falsifier and no
new behaviour claim.

## Append-only preservation requirement

1. **Original bytes untouched.** The 88 existing lines stay byte-identical; the
   correction is EOF-only, matching the `round-18.md` erratum pattern
   (`round-18.md:74-79`), which is the in-repo model for this class.
2. **Exactly one `Reverify:` line.** `claim-ledger.sh` refuses a second declaration
   and counts any line starting with `Reverify` (L863-878). The proposed block
   mentions the line mid-sentence (`- The two recheck ids in the \`Reverify:\` line …`),
   so the count stays 1. Do **not** append a `by-hand:` declaration as well.
3. **No new ref-scheme token.** The entry already carries the generic token at
   line 19; the block adds none. Preserve the existing label-on-line status
   (`claim-ledger.sh` LABELED path, L529/L567).
4. **Stamp moves in the same commit.** Appending changes the bytes, so QM5 requires
   `corpus/stamps.tsv:20` to become
   `…janitor-command-surface.md<TAB>9b2d16a7…<TAB>108<TAB>7015` in the same commit.
   The historical triple `88 / 5764 / 4d447b25…` must remain visible — it is inside
   the appended text. Deletion of the row, or a restamp with no append, is prohibited.
5. **`drift-baseline.tsv` must not change.** Re-pinning it against the empty host
   would erase the only record of what the substrate was (`round-18.md:52-55`).

## Exact proposed recheck scope

Now, with the substrate absent — the only valid checks are the three that need no host:
1. stamp self-consistency (`sha256sum`, `wc -lc` against row 20);
2. declaration well-formedness (exactly one `Reverify:` line; ids resolve to rows);
3. the absence probe above. Nothing else in this entry can be confirmed; any edit that
   says otherwise is a false freshness claim.

On substrate return, in this order:
1. `bash corpus/drift-pins.sh` (row `R11-04`). If the-janitor hashes to `2408b0c9…`
   and client.py to `8179b241…`, the 2026-09-28 observation stands; spot-check the
   four falsifiers at the entry's tail and the dispatcher range L293-333.
2. If either hash differs, treat every line reference as stale before editing: re-read
   `the-janitor` L52-56, L77-119, L121-249, L293-333 and `client.py` L41-113, then
   reconcile the verb table and the startup-gate table to the new bytes.
3. `bash corpus/surface-census.sh --verbs` (row `R11-02`) for the write-side probes;
   both rows un-defer automatically because `substrate_present()` flips.
4. Re-run the entry's own falsification list (four bullets, including
   `THE_JANITOR_PORT=1 the-janitor status`).
5. Only then decide whether the entry needs a further correction; re-stamp in the same
   commit. Never migrate an expectation to match a failure.

## Limits

- Read-only; no gate executed. The deferral behaviour is source-read `[INFERENCE]`,
  not an observed `verify` run.
- Absence is established by `stat` at one instant; I cannot date the removal more
  precisely than "between round 17 and round 18".
- The last source pin is a single hash from round 9; no intermediate observation
  exists, so I cannot say whether the handler changed before it vanished. "Not
  drifted" is therefore not claimed — only "not checkable".
- Nothing here establishes that any verb or failure text is now wrong. It establishes
  that they are unverified since 2026-09-28 and presented as current.
- My stale counts are byte comparisons against `HEAD:` blobs, not a `claim-ledger verify`
  run. The in-flight working-tree edits were excluded by design.

## Checks the parent should run after integration

- `sha256sum corpus/knowledge/janitor-command-surface.md` and `wc -lc` → must equal
  `9b2d16a7…` and `108 / 7015` **only** if the block landed verbatim; otherwise
  recompute and record the new triple in the same commit.
- `bash corpus/claim-ledger.sh docs corpus/knowledge` → `DOC_AUDIT: CLEAN`, proving the
  single-declaration rule still holds for all entries.
- `bash corpus/claim-ledger.sh citations --docs corpus/knowledge/janitor-command-surface.md`
  → `labeled` count unchanged from the pre-append status.
- `bash corpus/claim-ledger.sh cells` (if the scorecard points at this entry's stamp) →
  the stamp pointer must resolve to the new row.
- Do **not** run `drift-pins.sh`, `surface-census.sh --verbs`, or a full `verify` as an
  acceptance check: with the substrate absent they defer or fail by design, and that
  result would be misread as a regression.

## Installs

None. No package, tool, service, or host configuration was changed.

## Report

`.ufo/waves/round-22/build/Entry12.md` (this file), written under
`/home/vgpnk/Projects/shokunin/kagi-shokunin` at base
`c2cab35bc92e57e39e5489bac3386db078345b3f`.
