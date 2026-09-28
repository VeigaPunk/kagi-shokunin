# Drift gate — baselines, symbol pins, and what it cannot see

Sources: `corpus/drift-pins.sh` (round-9 v2, 451 lines, sha256 `c138d34c…0feb`),
`corpus/drift-baseline.tsv` (15 rows), `corpus/drift-symbols.tsv` (19 rows);
live runs 2026-09-28; v1 read at HEAD `ea77bf0`; `PROTOCOL.md` §Evidence standard
L292–298; `corpus/lessons/round-8.md` §5; round-9 L2 review (planner, sentinel,
critic, scout, labrat, distiller).

## Why v1 was not a gate

v1 printed `mode+size / sha16 / lines` for 13 host files and exited 0
unconditionally. Expected values lived nowhere in the repo, so the output could
not be compared to anything: `git show HEAD:corpus/drift-pins.sh | grep -c
baseline` → 0. `PROTOCOL.md` states the rule the round-8 audit applied — "a pin
only counts if its expected values are persisted inside the repo"; it found the
kagi pins verifiable for only 2 of 13 files (the two whose hashes happened to be
quoted in prose: `the-janitor` `2408b0c9…57edd`, `client.py` `8179b241…ce51`).
On the record: `MODEL_ENDPOINT`'s line moved 17→19 while four corpus files cited
L17 from round 4 to round 8 (`lessons/round-8.md` §5).

## Schemas

`corpus/drift-baseline.tsv` — one row per pinned host file:

    $HOME/.local/bin/the-janitor<TAB>755<TAB>333<TAB>2408b0c9…57edd
    $HOME/.config/the-janitor/op.env<TAB>600<TAB>17<TAB>-

`path<TAB>mode<TAB>lines<TAB>sha256`. Paths are `$HOME`-relative in the committed
file and expanded at read time (`expand_p`), collapsed on write (`repo_p`), so
the baseline is diffable and reviewable. `sha256` is the full 64 hex chars —
16-char truncation is enough to *print* but not to argue with. A literal `-`
means "hash withheld by policy" (below).

`corpus/drift-symbols.tsv` — one row per content claim the corpus makes:

    $HOME/.local/bin/the-janitor<TAB>19<TAB>^MODEL_ENDPOINT="http://127\.0\.0\.1:8080/v1"$
    $HOME/.config/the-janitor/op.env<TAB>#10<TAB>^[A-Z][A-Z0-9_]*=<TAB>shape
    $HOME/.local/state/tac/handoff-status.json<TAB>#1<TAB>"boundaries"

`path<TAB>line<TAB>ERE[<TAB>shape]`. A numeric `line` asserts the ERE matches
**exactly once**, on that line. `#N` is a **count pin**: assert the ERE matches
exactly N lines and nothing about which lines. The optional fourth column
`shape` (only meaningful on a no-hash dotenv file) additionally asserts that
every non-blank, non-comment line is itself an assignment — so a malformed line
cannot hide behind a correct count.

Which claims assert a **value** rather than a key's presence is a decision, not
an accident:

| Row | ERE kind | Why |
|---|---|---|
| `the-janitor:19` | value | pins the dead `8080` endpoint; the fix must touch this line and the overlay field together |
| `opencode.json:16` | value | same claim, load-bearing copy (SKILL.md: `status` keeps lying until L19 is updated too) |
| `janitor.md:6`, `:8` | value | `steps: 4` and `{"*": deny` are the containment facts; a `steps` bump silently weakens the cap |
| `the-janitor:17`, `:148`, `:194`, `:196`, `:214`, `client.py:19`, `:74`, `opencode.json:4`, `:5`, `janitor_auth.ts:12`, `tac-check:63`, `:69` | key presence | the claim is "this knob/guard/verb exists here", not its argument |
| `op.env:#10` + `shape` | count + shape | naming a key or a value would put secret-shaped text in the repo; the count still detects a key added/removed |
| `handoff-status.json:#1` ×2 | count | the published field names (`boundaries`, `credentials_in_evidence`) asserted without publishing the private file's line layout |

Consequence of the value pins: when the operator applies the documented endpoint
fix, the gate turns red on both rows (`GONE`) until the corpus text is re-read —
intended signal, not regression. Verified on patched copies: `GONE` ×2,
`DRIFT_PINS: DRIFT (files_ok=2 files_bad=0 symbols_ok=0 symbols_bad=2)`, exit 1.

## Verdict vocabulary

| Verdict | Meaning | Exit |
|---|---|---|
| `OK` | file matches its baseline row; symbol ERE matches once at the pinned line (or count matches) | — |
| `DRIFT <path> mode\|lines\|sha <old>-><new>` | live file differs from the baseline row | 1 |
| `MISSING <path>` | baseline row has no live file | 1 |
| `LINK <path>` | pinned path is a symlink, or has `nlink>1` (a hardlink — the path is not uniquely the file); the gate refuses to follow it. Round-9 L2 critic found the hardlink variant | 1 |
| `UNPINNED <path>` | path in `FILES` with no baseline row | 1 |
| `EXTRA <path>` | baseline row for a path not in `FILES` (membership is closed in both directions) | 1 |
| `DUP <path>` | the baseline carries more than one row for a path | 1 |
| `POLICY <path>` | baseline asks for a hash of a no-hash path — refused **before** the file is read, so no secret-derived digest is ever printed | 1 |
| `EMPTY <file>` | a symbols/baseline file with no data rows (pins lost) | 1 |
| `MOVED <path>:<pin>-><actual>` | the claim still matches exactly once, at a different line — the stale-ref class | 1 |
| `GONE <path>:<line>` | claim text absent, or file absent/now a symlink | 1 |
| `AMBIG <path>:<line> (<n> matches)` | the ERE now matches n>1 lines, so the pin cannot resolve | 1 |
| `COUNT <path>:#<pin>->#<actual>` | count pin disagrees | 1 |
| `SHAPE <path> <n> assignments vs <m> non-comment lines` | dotenv shape broken (opt-in `shape` column) | 1 |
| `drift-pins: baseline not readable: … (run --pin once)` | setup | 2 |

Summaries: `DRIFT_PINS: CLEAN (files=N symbols=M)` · `DRIFT_PINS: DRIFT
(files_ok=… files_bad=… symbols_ok=… symbols_bad=…)` · `DRIFT_PINS: PINNED
(files=N symbols=M line_updates=N)` · `DRIFT_SELFTEST: PASS (N cases)`.

## Hash policy (round-9 L2 sentinel review)

| Class | Files | Pin | Compensating control |
|---|---|---|---|
| material | `op.env` (600) | mode + lines + count + shape, sha `-` | none needed: 10 assignments/17 lines/mode 600 is the whole drift signal available without publishing bytes |
| private custody/state | `handoff-status.json`, `daybreak-blue-access.json`, `tac-daybreak-blue.json` (all 600) | mode + lines, sha `-`; two count pins on the *published* handoff field names | `tac-check` independently binds `receipt_sha256` in the custody record; handoff boundaries are asserted by count pins |
| private, corpus-described | `config.json` dev-decoy (600), `~/.agents/AGENTS.md` (600) | mode + lines, sha `-` | `config.json` inertness proven in `config-layering.md`; `AGENTS.md` is fleet-shared context (auto-loaded to every agent, audited by kotoba) |
| everything else | 9 files, mode 644/755 | mode + lines + sha256 | — |

Why the conservative tier: a committed sha256 of a low-entropy private file is an
offline confirmation oracle — sentinel demonstrated recovery of a fake identifier
from its hash alone, with zero host contact. The cost is explicit: for the 6
no-hash files, **content drift is undetectable** beyond mode, line count, count
pins and (for `op.env`) dotenv shape. `op.env` is the only file where NOHASH is
strictly required (it holds values and refs); the other five are a conservative
choice — sentinel's own refinement called them "not strictly required oracle
mitigation" — taken because those files hold personal state whose content class
is not audited, and because a later `--pin` after an operator edits a private
file would otherwise publish the new hash.

Verified clean: the committed TSVs contain 0 `op://` refs and 0 `op.env` key
names (round-9 scribe independent check); the gate prints paths, verdicts and
counts only, never file content or matched text.

## `--pin` semantics (records, never repairs)

- Rewrites the file rows; each changed row prints `REPIN <path> (<old> ->
  <mode>/<lines>/<sha12>)`. (Round-9 L2 planner caught that v2's old-row map was
  keyed literally while lookups were expanded, so `REPIN` never fired; fixed and
  re-verified — the round-9 pin printed three `REPIN` lines.)
- Moves a symbol's recorded line **only** while its ERE still matches exactly
  once (`MOVED <path>:<pin>-><actual>`). A **count** change is a claim change (a
  key was added or removed), not a location move, so it is refused exactly like
  `GONE` — `drift-pins: count pin changed (…:#10->#11), refusing to pin` — and
  the operator hand-edits the count after checking. Rejection list (all exit 2,
  nothing written): `GONE`, `AMBIG`, changed count pin, missing/linked/hardlinked
  symbol source, unreadable or empty symbols file, baseline row outside `FILES`.
- So a pin can absorb a line move but never a vanished or duplicated claim — the
  content assertion outranks the location. What `--pin` cannot do is tell an
  intentional host edit from a hostile one: that judgement is the operator's,
  and the printed `REPIN`/`MOVED` lines are the audit trail. Residual (INFO):
  the two `mv` calls are not one transaction, so a crash between them leaves the
  pair inconsistent — recoverable with one more `--pin`, and the gate reports it
  (baseline/symbols disagreement shows up as `MOVED`/`GONE`).

## Bounds — what this gate does **not** do

- **Nothing runs it on a schedule.** The verdict exists only when a lane or the
  operator runs it; both repo gates (`drift-pins.sh`, `transcript-scan.sh`) are
  manual.
- **Coverage = the enumerated claims.** A host file the corpus describes but
  never pins, or a claim nobody wrote into `drift-symbols.tsv`, is invisible.
  Pinning is enumeration, not proof of completeness.
- **6 of 15 files are content-unhashed** (policy above): their content drift is
  invisible; only mode, line count, count/shape pins remain.
- **Count pins are blind to value changes at constant count** — 10 assignments
  before and after is `OK` even if one value was replaced. `shape` catches a
  malformed line, not a replaced value. That is the accepted cost of not putting
  secret-derived bytes in the repo.
- **Value pins red-line on intended remediation** (the two endpoint rows), and
  the correct response is to re-read the citing text and `--pin`, not to loosen
  the ERE.
- **Two cited paths are deliberately unpinned**:
  `$STATE_DIR/xdg-data/…/opencode.log` and `opencode.db` mutate legitimately (the
  DB's hygiene has its own gate, `corpus/transcript-scan.sh`). "Every cited file
  is pinned" is therefore the wrong claim; the correct claim is the explicit
  15-row list. Package-managed host binaries cited in the corpus
  (`/usr/bin/op`, `/opt/1Password/1Password-BrowserSupport`,
  `~/.opencode/bin/opencode`) are also unpinned — their drift signal is the
  package manager's, and they are third-party bytes the lane must not own.
- **Baseline staleness is a human act.** A baseline left un-re-pinned after an
  intentional host change reports `DRIFT` forever — correct, noisy, and the
  reason the checklist requires reporting the accepted `REPIN`/`MOVED` lines.

## Reproduction (2026-09-28)

    bash corpus/drift-pins.sh            # DRIFT_PINS: CLEAN (files=15 symbols=19), exit 0
    bash corpus/drift-pins.sh --selftest # DRIFT_SELFTEST: PASS (13 cases), exit 0
    bash corpus/drift-pins.sh --baseline; echo $?   # → 2 (missing argument)
    sed 's/^\(\$HOME\/.local\/bin\/the-janitor\).*/\1\t755\t333\tdeadbeef/' \
      corpus/drift-baseline.tsv > /tmp/mut.tsv
    bash corpus/drift-pins.sh --baseline /tmp/mut.tsv --symbols corpus/drift-symbols.tsv
    # DRIFT   $HOME/.local/bin/the-janitor sha deadbeef0b7e->2408b0c90b7e      (paths print expanded at runtime)
    # DRIFT_PINS: DRIFT (files_ok=14 files_bad=1 symbols_ok=19 symbols_bad=0), exit 1

    # policy: a baseline row that asks for a hash of a no-hash path
    sed 's/^\(\$HOME\/.config\/the-janitor\/op.env\t600\t17\t\)-$/\1deadbeef/' \
      corpus/drift-baseline.tsv > /tmp/pol.tsv
    bash corpus/drift-pins.sh --baseline /tmp/pol.tsv --symbols corpus/drift-symbols.tsv
    # POLICY  $HOME/.config/the-janitor/op.env baseline sha must be `-` … , exit 1

    # counterfactual: what the gate says the day the endpoint fix lands
    T=$(mktemp -d); sed 's|127.0.0.1:8080/v1|127.0.0.1:34113/v1|' \
      ~/.config/the-janitor/opencode.json > "$T/opencode.json"
    # (with a matching $T baseline + symbols) → GONE …/opencode.json:16, exit 1

Selftest cases (13): clean, content drift, restored, mode drift, missing file,
symbol moved, symbol gone, symbol ambiguous, symlink, count drift, final clean,
dotenv shape drift, shape restored — all on a `mktemp -d` scratch tree via
`--baseline`/`--symbols` (+ `DRIFT_EXTRA_NOHASH` for the scratch secret file),
host untouched. The real corpus dir is never written during a selftest.

## Falsification

Run the commands above: clean run, 13-case selftest, falsified-baseline copy
(exit 1), malformed-`op.env`-row copy (`POLICY`, exit 1), missing `--baseline`
argument (exit 2). Then mutate any single host file **copy** and confirm the
verdict names that file and field. `bash corpus/drift-pins.sh --help` prints the
contract; `grep -n 'NOHASH\|is_nohash\|_p()' corpus/drift-pins.sh` shows the
policy hooks.