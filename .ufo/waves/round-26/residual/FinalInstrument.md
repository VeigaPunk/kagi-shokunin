# FinalInstrument — surgical review of `.ufo/waves/round-26/tools/final-measure.py`

Scope: the measuring instrument only (`.ufo/waves/round-26/tools/final-measure.py`, 176
lines) at candidate `d30c9892a7377b8b5a51817d1db8b81eaddcc397`, plus the code/data it
depends on at the same revision (`corpus/release-clock.py`, `corpus/claim-ledger.sh`,
`corpus/sources-census.sh`, `corpus/self-counts.py`, `corpus/release-clocks.tsv`,
`corpus/SOURCES.md`, `corpus/self-counts.tsv`, `corpus/stamps.tsv`, `corpus/claim-ledger.tsv`,
`.ufo/waves/round-26/{tools/replay-current.sh,*/expected.json,*/inputs.sha256,captures/*,observe-*.json}`).
Axes reviewed: invalid whole-process success, source-id/record population, empty or duplicate
records, failed checks dropped, self-fulfilling snapshots, lone48 expectations, exact receipt
predicates. Static read of candidate blobs and fleet parent directory; **nothing was executed**.
The expected.json oracle issue is being repaired by L1 per dispatch (FinalSnapshot finding);
it is not re-raised here except where it interacts with F5.

## Findings (by severity)

### F1 — HIGH [OBSERVED, code-read]: environment hermeticity regression lets caller env change gate verdicts

`final-measure.py:49-52` builds `env = dict(os.environ, HOME=…, PYTHONDONTWRITEBYTECODE="1")`
and deletes only `OP_SESSION*`/`OP_*` 1Password keys. The round-25 instrument pinned a
whitelist (`{'PATH','HOME','PYTHONDONTWRITEBYTECODE','LC_ALL'}` — observed in the BASE blob
of `.ufo/waves/round-25/tools/final-measure.py`). Everything else in the caller's environment
now reaches every gate. Confirmed behavior-changing sinks:

- `KAGI_SUBSTRATE` — `corpus/claim-ledger.sh:172-177` `substrate_present()` reads it directly;
  `claim-ledger.sh:578` defers `[substrate]` rows when absent. Inherited `KAGI_SUBSTRATE=present`
  or `absent` changes which claim rows run → `deferred` count and run set differ run-to-run
  → the `ledger-default-host-exclusion` verdict is environment-dependent (invalid-success
  risk under a polluted caller env, loud-fail risk is secondary).
- `CLAIM_LEDGER_DEPTH` — `claim-ledger.sh:375` refuses nested audits on `verify` when >0;
  `final-measure.py:50` does not clear it (nor `CELLS_CONTEXT`). Truthy inherited value →
  SETUP/die → loud fail (fail-loud, not invalid-success, but still env-dependent).
- `BASH_ENV` — inherited by `bash corpus/*.sh` and `bash <wrapper>` child invocations;
  arbitrary caller-controlled code execution inside every bash gate.
- `PYTHONPATH`/`PYTHONHOME` — inherited by all `python3` gates; stdlib shadowing can alter
  gate behavior. (L1's planned `python3 -I -B` for the wrapper mitigates the wrapper only;
  `run()` invokes `python3 -B corpus/release-clock.py`, `python3 -B corpus/self-counts.py`,
  `bash corpus/claim-ledger.sh` — none isolated.)
- `GIT_DIR`/`GIT_WORK_TREE`/`GIT_CONFIG*` — inherited by `git` inside claim commands and,
  worse, by the recorder's own setup `git clone`/`checkout` at lines 40-41 and 87-88, which
  run **without** `env=` entirely (so they see even the `OP_*` keys the gate env deletes).
  `GIT_DIR` + `GIT_WORK_TREE` would make both checkouts write into the wrong repository →
  downstream checks measure a different tree while `measured_revision` is reported as the
  intended SHA. That is a direct invalid-success path.
- `LC_ALL` unpinned — awk/sort inside `sources-census.sh` is locale-sensitive (low risk).
- Other credential material (`AWS_*`, `VAULT_*`, `GITHUB_TOKEN`, `SSH_AUTH_SOCK`) passes to
  gate children; a claim command that consults a live service could resolve evidence that
  should have failed → invalid success.

Fix direction: restore a whitelist env (PATH, HOME=empty-home, PYTHONDONTWRITEBYTECODE,
LC_ALL, TERM), or at minimum add `GIT_DIR GIT_WORK_TREE BASH_ENV ENV PYTHONPATH PYTHONHOME
CLAIM_LEDGER_DEPTH CELLS_CONTEXT KAGI_SUBSTRATE` to the delete list and pass `env=` to the
setup clones/checkouts too.

### F2 — MEDIUM [OBSERVED, code-read]: substring `contains` pins accept prefix-truncated counts — stale pins mask drift

`run()` at `final-measure.py:57-62` uses `text in process.stdout`. Several pinned tokens end
in digits with no terminator on the left of the true value's end:

- `"rejected=3"` (line 78, `source-census`): the literal even drops the summary's closing
  `)` — `SOURCES_CENSUS: CLEAN (rows=%d A=%d B=%d C=c queued=%d mined=%d rejected=%d …` at
  `sources-census.sh:362` continues ` entries_sourced=…`. `rejected=37` or `rejected=30`
  still contains `rejected=3` → a rejected-count regression reads CLEAN to this pin.
- `"claims=65"` (line 82): true token is `claims=65 `, but `claims=650` also contains it.
- `"unresolved=0"`, `"fleet_absent=48"` (line 90): `unresolved=0` is safe (preceded/followed
  by space in the INCOMPLETE format at `claim-ledger.sh:1275`), but `fleet_absent=48` matches
  `fleet_absent=480`.
- `"layout_incomplete=1"`, `"host_skipped=12"` (line 92): `layout_incomplete=1` matches
  `=10-19`; `host_skipped=12` matches `=120-129`.
- `"UNBOUND S040"`/`"UNBOUND S041"` (line 125): substring matches `UNBOUND S0400`-style ids —
  unreachable today (id regex is `S[0-9]{3}`) but the pattern is unguarded.
- `"RELEASE_CLOCK: FAILED"` (line 125) is safe (word boundary via space), as are the
  space-delimited tokens (`on_release=30 bound=30 …`, `stamped=89`, `stale=0`).

This is the concrete "invalid whole-process success" hole: a gate can drift to a different
count and the stale pin still substring-passes. Fix: boundary-aware matching (regex with
`(?![0-9])` / explicit `)`/` ` terminators) or full summary-line equality for these legs —
same recommendation class as the recorder oracle pin L1 is already adding.

### F3 — MEDIUM [OBSERVED, code-read]: a single exception deletes every already-run check's record — no measurement artifact at all

`records` accumulate inside the `with` block (`final-measure.py:34-164`), and the output
file is written only at line 168 after all checks complete. Any raised exception —
clone/checkout failure, `KeyError` (e.g. `expected[mode]` shape change at line 69,
`sources[sid]`/`by_id[sid]` KeyError at line 117), `.group(1)` on a regex that found no
`<item><title>` (line 161), a missing capture file (lines 139-147), `tempfile.TemporaryDirectory`
on an absent `/fast/scratch` (line 35), non-UTF-8 gate output under `text=True` (line 58) —
exits non-zero **with no JSON written**. The caller then has no `checks[]` at all: every
already-completed PASS/FAIL record is dropped, and an instrument crash is
indistinguishable-by-artifact from "measurement never ran". It cannot produce a false pass
(exit stays non-zero), but it violates the failed-checks-retained contract the round-25 tool
documented ("failures remain failed records") — a crash converts gate evidence into absence.
Fix: `try/finally` that serializes `records` plus an `instrument_error` field to `output`
before propagating, so L1's final run can never emit zero-artifact ambiguity.

### F4 — MEDIUM [OBSERVED, residual]: the replay oracle chain is still self-sealing inside one commit

Beyond the dispatch-known `expected.json` oracle (recorded at `final-measure.py:66-71`:
`expected = json.loads((root / REL / profile / "expected.json").read_text())` — the same
commit under test supplies the oracle), the same-commit dependency is broader:

- `replay-current.sh:10,13` pins the two `inputs.sha256` *file* SHAs — but both constants
  live in the same commit as the manifests. The wrapper-vs-manifest check proves snapshot
  internal consistency (observed: `frozen/inputs.sha256` sha = `cbb420c5…` = wrapper frozen
  constant; `rearmed/inputs.sha256` sha = `2e476782…` = wrapper rearmed constant), not that
  the snapshot equals anything outside the commit.
- Observed independently: `rearmed/after/corpus/*` shas (`99a9b4bc`, `6008780b`, `a1415da3`,
  `7d6bfe81`) do equal the production `corpus/` blob shas at d30c9892, and `frozen/release-clock.py`
  (`f1a8237c`) equals `BASE:corpus/release-clock.py` — so the snapshot↔production equivalence
  the parent says L1 is adding is data-true at this revision; the assertion still needs to
  exist in code or a later commit can silently break it.
- `current-receipt-literal-pin` (lines 98-100) compares the revision's own `observe-2.json`
  to `CURRENT_SHA`, a literal in the same commit — the observed sha matches
  (`13b8540c…` = `DEFAULT_RECEIPT_SHA256` at `release-clock.py:25` and
  `rearmed/expected.json` `receipt_sha256`), i.e. internally consistent but not an external
  pin. The only genuinely cross-revision pin is `HISTORICAL_SHA`/`BASE` (lines 17-18, 94-97).
- `spec.get("findings", spec.get("finding_ids", []))` (line 71) accepts either key spelling —
  observed both used (`frozen` uses `finding_ids`, `rearmed` uses `findings`), but a typo
  (`findins`) silently degrades the oracle to summary-only. L1's literal-recorder rewrite
  should remove this tolerance, not port it.

### F5 — LOW [OBSERVED, cosmetic/robustness]

- `sys.argv[1:]` unpack at line 31 raises bare `ValueError` on bad arity; round-25 printed a
  usage `SystemExit`. No record either way.
- `tamper-pair` (lines 127-136) rewrites only the `observe-2.json` line of the manifest —
  correctly still detected because the wrapper self-pins the *manifest file's own* sha
  (`replay-current.sh:16-20`) before checking entries. Coverage gap, not a bug: there is no
  leg tampering `release-clock.py` or a `corpus/*` input (manifest-pin transitively covers
  them, but an explicit leg would prove it).
- `replay-current.sh:9` selects the receipt by `[ -f observe-2.json ]` rather than a profile
  argument; a `frozen/` tree containing `observe-2.json` would select the rearmed manifest
  sha → safe (mismatch → `snapshot_tampered`), but the selection is positional-in-file
  rather than declared.
- `--receipt-sha` in the wrapper (line 25-28) is computed by hashing the very file it then
  asks the gate to verify — vacuous as a pin; the real pin is the manifest constant. Harmless
  but worth a comment to prevent a future reader treating it as protection.
- `id-exact-drift` (lines 103-109): `entry.get(key)` conflates missing key with JSON `null`;
  cannot distinguish the two. Exclusion of `observed_at`/`sha256`/`url-independent` fields is
  declared in-record (`timestamps_and_digests_excluded`) — honest.
- Mirror symlinks (`final-measure.py:42-46`) link live sibling worktrees and the live fleet
  `.ufo` (not revision state). `fleet_layout_present`/`cite_target` (`claim-ledger.sh:654-704`)
  only consult `.ufo`, `MANIFEST.json`, `MISSION.md`, `AXES.md` and `*-shokunin` entries, all
  of which the mirror supplies — so mirror completeness is sufficient for the gates as
  written. Residual: live-symlink reads make fleet-`verify` sensitive to uncommitted sibling
  state (fail-loud only), and any sibling-writing gate would mutate production through the
  link (none observed to write).
- `contains` checks stdout only; stderr is recorded but unasserted (line 59-62). Round-25
  merged stderr into the matched stream. Today no expected string lives on stderr (verified
  against `claim-ledger.sh`/`release-clock.py` output sites), so impact is diagnostic only.
- `first_title` regex `.group(1)` (line 161) crashes if the capture is Atom — currently RSS
  (verified `S039.body` begins `<rss …><channel>` with first `<item><title>Python 3.14.9`).
- `/fast/scratch` hard-coded temp root (line 35) — exists on this host; a crash there is
  another F3 no-artifact path.

## Verified-consistent (no defect found — static evidence)

- **Record population**: 21 records, all unique names (`frozen/rearmed` × `before/after` = 4,
  `active-default`, `clock-selftest`, `source-census`, `self-counts`,
  `ledger-default-host-exclusion`, `lone-citations-honesty`, `lone-verify-honesty`,
  `historical-receipt-immutable`, `current-receipt-literal-pin`, `id-exact-drift`,
  `successors-fire-next-release`, `missing-binding-S040/S041`, `tamper-input-only`,
  `tamper-input-plus-manifest`, `per-clause-source-check`, `backport-first-parser-control`).
  No empty records: `record()` always sets `name`/`passed` + detail; `run()` adds argv/cwd/
  exit/stdout/stderr. Clause ids within `per-clause-source-check` are unique (S039/40/41 +
  six labels). No `run()` overwrites or reuses a name.
- **Whole-process success**: `return 0` iff `passed == total` (line 172); `passed` counts
  `entry["passed"]` over `records` only — no path skips a failed record into the total, and
  no record can pass without a real subprocess/measurement (every `run()` executes; every
  `record()` computes). Expected exits are pinned per-leg (0/1/2/3 — no "any exit accepted").
- **Literals vs candidate data** (all observed by counting blobs, not by running):
  `on_release=30` = `recheck=on-release` rows in SOURCES.md (S005–S032, S040, S041);
  `fired=3` (S012, S027, S028); `derived=15` (`note` starts `derived:` on 15 feed rows);
  `rows=41 A=39 C=2 queued=1 mined=37 rejected=3` all match SOURCES.md histogram;
  `claims=38` = self-counts.tsv data rows; `claims=65`/`stamped=89` = claim-ledger.tsv /
  stamps.tsv data rows; `host_skipped=12` consistent with the host-tagged claim rows
  (claim-ledger.tsv has 13 rows whose text mentions `host`; which exact 12 are
  `is_host_note`-tagged is gate-internal, consistent by count class, not enumerated).
- **Lone-clone honesty**: R11-08 is the only row invoking `claim-ledger.sh citations`
  (observed claim-ledger.tsv:22); in the lone clone its command exits 3 with
  `CITATION_GATE: INCOMPLETE` → `LAYOUT-INCOMPLETE R11-08`, `layout_incomplete=1`,
  `CLAIM_LEDGER: INCOMPLETE`, verify exit 1 (`claim-ledger.sh:601-610,1227-1229`).
  `citations` itself: lone layout → `CITATION_LAYOUT: lone-clone` + `CITATION_GATE:
  INCOMPLETE (… unresolved=0 … fleet_absent=48)` exit 3 (`claim-ledger.sh:1266-1277`) —
  matches both expected literals and the round-25 48 figure the contract says to preserve.
- **Receipt predicates**: `observe-1.json` has exactly 28 unique observations; only
  S027/S028 differ from `BASE:.ufo/waves/round-25/observe-1.json` in the 8 compared fields
  (both `fired`/`3.15.1` now; `observed_at` excluded by design). `observe-2.json` adds
  S040/S041 (`not-fired`/`3.15.1`) — 30 unique ids. `BASE:release-clocks.tsv` sha =
  `frozen/inputs.sha256` `before/corpus/release-clocks.tsv` entry (`53264aad…`); frozen
  `after` differs in exactly the S027/S028 lines (4 diff lines). BASE `observed_at` dates
  (2026-10-21) match receipt dates, so `frozen-before` errors are exactly the two
  `RECEIPT-MISMATCH` for S027/S028 — `observed=26 fired=1` (S012) is consistent.
- **Successor-fire leg**: S040/S041 rows are `clock=feed`, `feed_source_id=S039`,
  `feed_url=https://www.python.org/downloads/feed.rss` (matches S039's url); fake-feed title
  `Python 3.15.2` matches `STABLE_TITLE_RE` (`^(?:[A-Za-z]+ )?v?([0-9]+\.[0-9]+\.[0-9]+)$`,
  release-clock.py:649) → `observe_one` sets `parsed_version=3.15.2`, `verdict=fired`, no
  `error` key. Module-global `request_body` patch (line 116) is effective — `observe_one`
  calls the module function each time (line 721).
- **Missing-binding legs**: deleting the `S040\t…` line yields `UNBOUND S040` +
  `RECEIPT-MISMATCH S040` + `RELEASE_CLOCK: FAILED` exit 1 — expected literals correct.
- **Tamper legs**: both fixtures produce `ROUND26_REPLAY: snapshot_tampered` exit 2 via
  manifest-entry failure (input-only) or manifest-self-sha failure (pair) — correct distinct
  provenance, expected exit/literal right.
- **Source-check literals**: S040.body `index-32…33` raw contains `str.isspace()`,
  `non-breaking spaces mandated by typography rules`, `ASCII` flag sentence (tag-split —
  normalized text restores the quoted forms); S041.body contains `Convert all named and
  numeric`, `corresponding Unicode`, `HTML 5 standard` raw. metadata.json ids ↔ `.body`
  files complete.
- **Feed control**: S039.body is RSS; first `<item><title>` = `Python 3.14.9`; max stable
  over all item titles = `3.15.1` (`3.16.0a1`, `3.15.0rc3` rejected by the same regex;
  `Python install manager 26.4` has a two-word prefix → rejected).
- **Selftest literal**: `cases` tally reconciles to 67 (31 `run_case` calls + 5 parser
  cases + 2 parser-failure cases + 2 URL cases + 6 redirect cases + 21 remaining
  `cases += 1` increments), consistent with `PASS (67 cases)` — but [INFERENCE] counted by
  hand from the listing; an off-by-one here is a loud-fail, not an invalid pass.

## Residual risk and verification gaps

- Every numeric literal is verified consistent **at d30c9892 by static counting**; none was
  executed. If L1 edits receipts/manifests during oracle repair, all literals must be
  re-derived, not trusted to drift-safe (F2 explains why the pins themselves can't catch
  prefix drift).
- `clock-selftest`'s 67-case pin is hand-reconciled; the only authoritative check is a real
  run — flag to L1 if it reports 61/63 (loop-multiplicity miscount on my side).
- `host_skipped=12` in the *lone* clone is by-construction identical to fleet (host rows are
  tagged, not layout-dependent) — consistent, but only a real run distinguishes
  `layout_incomplete=1` staying exactly one row if future claim rows also invoke
  `citations`/`cells`.
- The instrument measures its own commit's oracle data end-to-end (F4); the only
  external anchors are `BASE`, `HISTORICAL_SHA`, and the wrapper manifest constants.
  After L1's oracle rewrite, re-verify that `expected.json` input shas are asserted equal
  to `inputs.sha256` and `rearmed/after/corpus/*` asserted byte-equal to production.
- F1's invalid-success direction needs a polluted caller env to manifest; under a clean
  env it is a latent hazard, not an observed wrong verdict.

Verification explicitly NOT run: no gate, selftest, replay, or instrument execution
(per contract); all claims above cite candidate-blob content observed via `git show`
or the fleet directory listing.
