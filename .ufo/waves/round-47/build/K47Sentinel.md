# K47Sentinel — round-47 refusal-boundary and scope review

Seat: sentinel (read-only), leaf. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
Reviewed at `HEAD = b020d978bac91284a431710148ebb7a7950eaab8` (predeclaration), `BASE = 252ef1cac9f41d84639c0d1f211d0e0911196112`.
Surface: `plans/round-47.{md,c1.sh,c2.sh}` + `plans/round-47-controls.py`, then everything under
`.ufo/waves/round-47/build/` (the seats' candidate material) at the end of the wave.
Nothing outside `build/K47Sentinel*` and `$HYAKU_SCRATCH/kagi-r47/K47Sentinel` was written; no git/jj
mutation was run; no lane file was created or edited.

Receipts (this directory, sha256 as written at the end of the run):

> Self-reference: this report quotes the credential-scan patterns it ran, so a naive
> `grep -E 'ghp_|op://|sk-'` over `build/` matches **this file** and its `scan.sh`. Exclude
> `K47Sentinel*` when scanning artifacts; `scan.sh` does exactly that for itself. No match in this
> report is a credential: the only `op://` strings are prose quoted from the fetched S094 body, and no
> `ghp_`/`github_pat_`/`AKIA` token appears anywhere in the wave.

| receipt | sha256 | content |
|---|---|---|
| `K47Sentinel-receipts/probes.py` | `e47f9f4c…aa293` | the five adversarial probes, re-runnable (`python3 -B probes.py`) |
| `K47Sentinel-receipts/probes.txt` | `5acd6cd0…33eca` | probe output D1–D5, rc=0 |
| `K47Sentinel-receipts/scan.sh` | `c5164bc4…8e6e6` | the refusal/scope scan, re-runnable (`bash scan.sh`) |
| `K47Sentinel-receipts/scan.txt` | `d24256e4…46b10` | scan output, sections 1–12, `SCAN: done`, rc 0 |

## Findings

| id | severity | surface | status |
|---|---|---|---|
| S-01 | **High** | C1 `CLEARED` is computed from candidate-reachable code (`corpus/sources-census.sh`), unpinned | open (counter frozen) |
| S-02 | **High** | C2 `REVERIFIED` step (e) runs candidate-reachable `corpus/rendered-text-v1.py`, unpinned | open (counter frozen) |
| S-03 | Medium | C2 `GATE` runs candidate-reachable `corpus/release-clock.py`; defeats K2-F6 | open (counter frozen) |
| S-04 | Low | capture-path validation accepts symlinks (file or directory) — bytes come from outside the measured tree | open |
| S-05 | Low | C2 window upper bound is caller-declared in tree mode (`C2_ASOF`) | open (procedural) |
| S-06 | Low | `plans/round-47-controls.py` writes its receipt to an unvalidated caller path (`OUT`) | open |
| S-07 | Low | C2's frozen ledger header is never checked (predicate names it, counter ignores it) | open (counter frozen) |
| S-08 | Low | C2 (a) compares the ledger URL to the **measured** registry URL — the row's `source` cell is editable | open |

### S-01 — C1 scores itself from code the candidate can rewrite (High)

Evidence. `plans/round-47-c1.sh:61` runs `out=$(cd "$T" && bash corpus/sources-census.sh)` and
`cleared` is computed only from that output (`:70-72`). Neither the census script nor
`corpus/SOURCES.md`'s meaning is pinned: `sha256` appears in the counter only for the fleet blob
(`:100`) and the S099 capture (`:114`). `INTACT` reads `SOURCES.md` (data), `BOUND` reads the fetch
row + capture; neither constrains the census program.

Exploit path (probe D1, `probes.txt`). Take the BASE tree, replace `corpus/sources-census.sh` with

```sh
#!/usr/bin/env bash
echo "SOURCES_CENSUS: CLEAN (rows=102)"
exit 0
```

and add only a legitimate S099 fetch row + capture — no `source:` line in either lesson:

```
C1_CENSUS_CALIBRATION: value=3 cleared=3 new=0 intact=1 bound=1
lessons identical to BASE: True
```

Impact. The calibration claim (`target 3`) is satisfiable with zero calibration work. The declared
kill rules do not catch it: they forbid rewriting a pre-existing line of the two lessons, and no rule
or control covers instrument tampering. The control suite's nearest case, K1-F4, replaces the census
with `exit 0` and expects the SETUP refusal — a stub that prints a well-formed `CLEAN` line is not
covered. Secondary trust boundary: the counter executes candidate-supplied shell with the reviewer's
privileges (`bash corpus/sources-census.sh` from an extracted tree), i.e. it is not a sandbox.

Smallest remediation (available now, since the counter is frozen). Gate the candidate before
measuring: `git diff BASE..candidate -- corpus/sources-census.sh corpus/rendered-text-v1.py
corpus/release-clock.py` must be empty (all three are already recorded at BASE in
`controls/instrument-sha256.txt`). Route the permanent fix to the next round: one line per instrument
in the counter, e.g. `[ "$(sha256sum < "$T/corpus/sources-census.sh" | cut -d' ' -f1)" = 8d30d627… ] || setup census-tampered`.

### S-02 — C2's locate step is proved by candidate code (High)

Evidence. `plans/round-47-c2.sh:97` runs `python3 corpus/rendered-text-v1.py locate "$T/$cap" "$mq"`
from the **measured** tree and accepts any `count=K` with `K == quote_count`. Nothing pins that
normalizer (the counter checks only that the file exists, `:61`).

Exploit path (probe D2). Eleven capture files whose entire content is
`placeholder body for S0NN -- no documentation text`, a ledger with `quote_count=1`, and

```python
#!/usr/bin/env python3
import sys
print('count=1')
```

as `corpus/rendered-text-v1.py`:

```
C2_FIRED_REVERIFIED: value=11 reverified=11 gate=1
captures containing the S012 quote: 0/11
```

Impact. The freshness claim (`target 11`) is satisfiable without fetching anything: no quote has to
appear in any body. This is outside the declared ceiling K2-C (which only admits hand-typed
`fetched_at` over byte-correct bodies); here the bodies are not correct at all. The non-author live
leg catches it only while the re-fetched digest differs — a candidate that ships the real bodies but
never checks the teaching would still pass, so the check that matters (does the page still teach the
claim) is delegated to candidate code.

Smallest remediation. Same as S-01: add `corpus/rendered-text-v1.py` to the no-diff gate at the
candidate commit, and pin `14f6ca6a…` in the next round's counter.

### S-03 — C2's gate is candidate code, so K2-F6's protection is removable (Medium)

Evidence. `plans/round-47-c2.sh:64` runs the measured tree's `corpus/release-clock.py`; K2-F6 proves
the counter catches a broken gate only while that program is honest.

Exploit path (probe D3). D2's tree + the exact K2-F6 mutation (`S008 … 3.13.3 → 3.13.2`) +
`corpus/release-clock.py` replaced by `print('RELEASE_CLOCK: CLEAN (doctored)')`:

```
C2_FIRED_REVERIFIED: value=11 reverified=11 gate=1 (gate-line=RELEASE_CLOCK: CLEAN (doctored))
```

Impact. The plan's kill rule "the re-verification must not re-arm or re-score a clock" is only
measured through a program the candidate can rewrite; a candidate can edit columns 1–8 of
`release-clocks.tsv` and keep `gate=1`.

Smallest remediation. Add `corpus/release-clock.py` to the same no-diff gate; state in the receipt
that `GATE` was produced by the BASE blob.

### S-04 — symlinked captures are accepted (Low)

Evidence. `plans/round-47-c2.sh:89` checks `[ -f "$T/$cap" ]`, which follows symlinks; `git archive`
restores committed symlinks as symlinks. C1's `[ -f "$C" ]` (`:113`) behaves the same way, and a
symlinked **directory** at `.ufo/waves/round-47/capture` is not detected either (the `..` guard only
looks at the spelled path).

Exploit path (probe D4). `S021.body` committed as a symlink to
`/home/vgpnk/Projects/shokunin/.ufo/prompts/kagi-round-44.md`, ledger sha/bytes taken from the
target: `value=11 reverified=11` with `S021` counted as reverified.

Impact. The predicate says "the file exists in the measured tree"; the bytes are read from the host,
so the committed artifact does not carry the evidence a third party needs, and the counter reads
outside the tree it claims to measure.

Smallest remediation. Reject non-regular files: `[ -f "$T/$cap" ] && [ ! -L "$T/$cap" ]` (and
`git -C … cat-file -p "$rev:$cap"` mode check, or `find … -type l -print -quit` over the capture dir).

### S-05 — the C2 time window is caller-declared in tree mode (Low)

Evidence. With `C2_TREE`, `ASOF=$C2_ASOF` verbatim (`plans/round-47-c2.sh:52`); only the revision
branch derives the bound from committer time (`:57`). Probe D5: `fetched_at=2029-06-01T00:00:00Z` and
`C2_ASOF=1893456000` (2030-01-01) → `value=11`.

Impact. A receipt produced with `C2_TREE` proves nothing about when the fetch happened; the same
applies to a revision whose committer date was set forward (`GIT_COMMITTER_DATE`), because the upper
bound *is* that date.

Smallest remediation. Receipts must quote the revision form `bash plans/round-47-c2.sh <rev>`; if a
tree-mode run is ever quoted, state the asof and why. (K2-C already names the hand-typed-time
ceiling; this note extends it to the window itself.)

### S-06 — `controls.py` receipt path is unvalidated (Low, M46-3 class)

Evidence. `plans/round-47-controls.py:141,246` opens `outp` as given; the docstring says "absolute
path" but nothing enforces it. With the host guard's cwd (`/home/vgpnk/Projects/shokunin`), a relative
`OUT` writes into the fleet root. The two counters are clean on this class (every write is
`"$SCR/…"`, and `SCR` derives from `HYAKU_SCRATCH` with `:-` default; `REPO` derives from
`dirname "$0"`).

Smallest remediation. `if not os.path.isabs(outp): sys.exit(2)` (one line).

### S-07 — the frozen ledger header is not checked (Low)

Evidence. The C2 predicate names the exact header
(`id url observed_release fetched_at capture_path sha256 bytes quote_count verdict`,
TAB-separated); `plans/round-47-c2.sh` selects rows with `awk -F'\t' -v i="$id" '$1==i'` and never
reads line 1, so any header (or none) is accepted, and a reordered or extended header is invisible.
Independently reached by `K47ReviewerPlan` as K47RP-04.

Impact. A ledger that a third party cannot parse with the declared shape still scores; the
`quote_count` column position is fixed only implicitly by `read -r … qc verdict`.

Smallest remediation. One line before the loop:
`[ "$(head -n1 "$L")" = "$(printf 'id\turl\t…\tverdict')" ] || setup bad-ledger-header`.

### S-08 — C2 re-verifies against a URL the candidate can edit (Low)

Evidence. `plans/round-47-c2.sh:77` extracts the expected URL from the **measured**
`corpus/SOURCES.md` row, and the ledger's URL is compared to that; nothing pins the row's `source`
cell to BASE (C1's `INTACT` pins only `status` and the S094/S099 `used-by` superset). Independent
reach as K47RP-05.

Impact. A candidate that re-points `S0xx`'s URL cell at any page containing the same quote moves the
verification target, and the counter reports `teaching-holds` for a document the row never cited.

Smallest remediation. Read the expected URL from the BASE blob
(`git show "$BASE:corpus/SOURCES.md"`), as C1 already does for the registry snapshot.

## Cross-seat corroboration

`K47ReviewerPlan.md` (independent seat, pre-candidate) reached S-01/S-02 as K47RP-01/K47RP-02 and
S-07/S-08 as K47RP-04/K47RP-05 by fixture construction; this seat reached them from the refusal/scope
side and adds S-03 (gate), S-04 (symlink), S-05 (window) and S-06 (receipt path), each with a
re-runnable probe. The two reports agree; neither found fabricated material in the wave.

## Clean sweep (commands and results)

Run: `bash .ufo/waves/round-47/build/K47Sentinel-receipts/scan.sh` → `SCAN: done`, rc 0
(`scan.txt`, 2026-11-06T19:41Z, the final run after every seat had landed; an earlier run at
19:38Z gave the same verdicts, except the section-6 false positives noted in O-4).

1. **Instrument freeze** — `sha256sum -c .ufo/waves/round-47/controls/instrument-sha256.txt`:
   `plans/round-47-c1.sh`, `-c2.sh`, `-controls.py`, `corpus/sources-census.sh`,
   `corpus/rendered-text-v1.py`, `corpus/release-clock.py` — all `OK`. The instruments have not moved
   since the 17-control receipt was written.
2. **Secret-shaped values in the instruments** —
   `grep -nIE 'ghp_[A-Za-z0-9]{20}|gho_…|ghs_…|github_pat_|sk-[A-Za-z0-9]{20}|AKIA[0-9A-Z]{16}|xox[baprs]-[0-9]|glpat-…|BEGIN [A-Z ]*PRIVATE KEY|op://[A-Za-z0-9_-]+/' plans/round-47*` → no match (exit 1).
3. **Secret-shaped values in all build outputs, captures included** (the same expression over
   `.ufo/waves/round-47/build`, excluding this receipt dir) → no match.
4. **`op://` occurrences** → two, both inside the fetched corpus body
   `K47ScoutSources-receipts/S094.body` (lines 50, 129), where the refusal boundary itself is quoted:
   "vault ref paths (`op://…`) stay out of every corpus" and "No credential material … or `op://`
   references — ever." These are prose mentions inside a captured page, **not** reference paths
   (`op://vault/item/field` shape) and not written by a seat. No `op://` in any report, ledger or
   tool. Do not copy that body into a committed capture (a naive artifact scan would flag it).
5. **Hardcoded `/tmp` in the committed tools (prompt §7 item 4)** — none in
   `plans/round-47*`; none in any `*.sh`/`*.py` under `build/`. The only `/tmp` strings anywhere are
   in the captured fleet prompt (`S099.body:699`, discussing `mkdtemp(dir="/tmp")` as a routed risk) —
   data, not a tool path.
6. **S099 capture credential grep (assignment-mandated)** —
   `grep -nE 'ghp_|github_pat_|sk-|AKIA|op://|BEGIN [A-Z ]*PRIVATE KEY' K47ExecC1/S099.body` →
   two hits, lines 683 and 706, both the substring `sk-` inside `disk-guard.sh`. Zero credential
   shapes. The capture is byte-identical to the fleet blob and to the worktree:
   `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`, 97077 bytes, three ways
   (`sha256sum` of the build copy, of the worktree file, of
   `git show 75dd2612:.ufo/prompts/kagi-round-44.md`); the S099 quote is at byte offset **52924**,
   `RENDERED_TEXT_V1_LOCATE: count=1` — matching the plan's `§6 item 9, line 561, byte offset 52924`.
7. **Writes outside the lane** — the counters write only `"$SCR/…"` (`SCR=$HYAKU_SCRATCH/kagi-r47/{c1,c2}.$$`,
   `trap rm -rf` on exit); `controls.py` writes only under `$HYAKU_SCRATCH/kagi-r47` plus `OUT`.
   Seat receipts write only under `$HYAKU_SCRATCH/kagi-r47/<seat>` and `build/<seat>`. At the first
   scan (19:38Z, before integration) `git -C lane status --porcelain` showed **no** modification to
   any tracked lane file and only the orchestrator's files plus `build/` untracked. No receipt
   contains `git add|commit|checkout|switch|reset|stash|push` or a jj mutation (the only matches are
   inside the captured fleet prompt text).
8. **Candidate applied to the lane working tree (final scan, 19:4xZ)** — `git diff --stat` is exactly
   `corpus/SOURCES.md` (2 changed cells: S040/S041 `recheck` `2026-11-05`→`90d`), the two lessons
   (`+2` each), `corpus/source-fetches.tsv` (`+1`, the S099 row), plus untracked
   `corpus/fired-reverify.tsv` and `.ufo/waves/round-47/capture/`.
   - C1 kill rule holds: `git diff BASE -- corpus/lessons/round-43.md corpus/lessons/round-44.md | grep -cE '^-[^-]'` → **0** (insertions only, at the file head).
   - The S-01 no-diff gate holds at this instant: `git status --porcelain -- plans/round-47.md plans/round-47-c1.sh plans/round-47-c2.sh plans/round-47-controls.py corpus/sources-census.sh corpus/rendered-text-v1.py corpus/release-clock.py` → **empty**.
   - The integrator's copies are the seats' material: `corpus/fired-reverify.tsv` is byte-identical to
     `build/K47ExecC2/fired-reverify.tsv` (12 lines); all 11 `capture/*.body` files match the
     `K47ExecC2/capture` digests; `capture/S099.body` hashes `e62e259c…1b80c` (97077 bytes); the
     capture dir contains no symlinks (`find … -type l` → empty).
9. **cwd-relative output paths (M46-3 class)** — clean in both counters and in the controls' tree
   builds; one residual (S-06). Seat-level: `K47ExecC1/receipts.txt:15` fetches with `-o S099.body`
   (relative) while its header records the host shell start dir as the fleet root; no residue exists
   at the fleet root now (checked `S099.body`, `S099.fetched_at`, `tree/`), so either the seat had
   cd'd into its scratch or it cleaned up. Recorded as process risk, not as a proven violation.
10. **Material, not just bytes** — the C2 candidate material is genuine: `K47ExecC2/fired-reverify.tsv`
   digests/bytes match the 11 bodies on disk, and each of the 11 column-13 quotes verifies with the
   **baseline** normalizer at the ledger's count (`count=1`, except `S024 count=3`). The four
   duplicate digests are URL grouping (`S012≡S022`, `S013≡S023`, `S014≡S025`, `S016≡S021≡S026`) and
   are byte-identical on re-fetch, not copy-paste. Independent seat agreement: every digest in
   `K47ReviewerLive-sha256.txt` (independent re-fetch, 19:34:42–44Z) equals `K47ExecC2/capture/*.body`.
   `K47ExecC1/S099.fetch-row.tsv` and `S099.body` reproduce the pinned digest. So S-01/S-02 are
   defects in what the counters *could* accept, not evidence of fabricated material in this wave.

## Observations (not defects of the instruments)

- O-1. Fleet-root residue of the M46-3 class exists from an earlier run:
  `.scratch/run15-wrapup/misroot-cff0b4cb/{versions.html,w4lines.txt}` (mtime 2026-11-06 12:35 /
  Nov 5) — both older than this wave (dispatch 16:33) and quarantined by the orchestrator, with a
  precedent note in `.scratch/run15-wrapup/round-84-kama.misroot-overwrite.md`. Not attributable to a
  round-47 seat.
- O-2. Fleet-root `MANIFEST.json` has an mtime later than 16:30 but its content equals `HEAD`
  (`git -C /home/vgpnk/Projects/shokunin status` does not list it) — an mtime touch, no content write
  observed. Flagged because the host guard names that file.
- O-3. `/fast/scratch/hyaku/kagi-r47/c2.401188` appeared as an empty directory mid-wave; the counters'
  `trap rm -rf "$SCR"` removes the whole scratch dir, so this is a run whose `mkdir -p` had completed
  and whose trap had not yet fired (concurrent measurement), not leaked state.
- O-4. Receipt correction (tool quirk). The host `grep` is `pi-uu-grep 0.2.0`, not GNU grep: adding
  `--exclude=<glob>` to a command that also carries `--include=<glob>` silently drops the include
  filter and scans every file. My 19:38Z run therefore reported three false `/tmp/` hits in the
  S099 captures (section 6). The scan now relies on the extension-include filter alone; the corrected
  run reports no `/tmp` path in any tool and the captured-prompt mentions are documented here instead.
  `--exclude-dir` + `--include`, and two `--include`s, behave correctly.

## Residual risk / not covered here

- I did not run `corpus/claim-ledger.sh` or any lane self-count (host-heavy; excluded by the seat
  spec), so I make no statement about the full lane gate.
- S-01/S-02/S-03 cannot be fixed inside this round without changing a frozen counter; the check that
  must hold *now* is the no-diff gate on the three instruments at the candidate commit (see S-01).
  If the candidate leaves them byte-identical to BASE — which the freeze receipt above shows at this
  instant — the two claims are being measured honestly, and the residual is the *next* candidate that
  edits them.
- The named ceiling K2-C (hand-typed in-window times) is unchanged and remains the live leg's job.

SEAT-STATUS: complete
