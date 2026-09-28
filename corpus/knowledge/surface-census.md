# surface census — DECLARED-surfaces gate + runtime shape pins

Source basis: `corpus/surface-census.sh` (v1, round 10) run on 2026-09-28 against
the live host; data files `corpus/surface-census.tsv` (35 rows: 20 asset /
15 runtime) and `corpus/state-shape.tsv` (22 rows: 9 sqlite / 9 json / 3 log / 1 lock / 1 marker); `~/.local/bin/the-janitor`
(333 lines, env overrides L7–27, dispatch L293–333), `~/.local/bin/tac-check`
(88 lines), `client.py` (117 lines), live `stat`/`sqlite3`/`the-janitor` probes;
`corpus/drift-baseline.tsv` + `corpus/drift-symbols.tsv` for the cross-check.
Gates observed this round: `SURFACE_CENSUS: CLEAN (assets=20 runtime=15
scanned=4 ok=34 absent=2 skipped=0)` exit 0; `SURFACE_CENSUS_VERBS: CLEAN
(pass=7 skip=3)`; `--deep` → `(pass=10 skip=0)`; `SELFTEST: PASS (16 cases)`.
No vault read, no `op` exec in the default probe set, no handler start.

## Why this gate exists

Rounds 1–9 governed the *contents* claim of this domain and left the *surface*
claim as prose: `PROVINCE.md` §Surfaces said which paths exist and at which
mode, and nothing could falsify it. Two concrete holes followed:

1. **Nothing detected an undeclared file appearing in `$CONFIG_DIR`.** Round 6
   proved `OPENCODE_CONFIG` is *additive* — discovery is not disabled — so a
   file dropped into `~/.config/the-janitor/` is loaded by the handler. A prose
   list cannot fire on an addition.
2. **The two `xdg-data` artifacts were named but unfalsifiable**
   ("mutates legitimately; not pinned"). `opencode.db`/`opencode.log` held the
   round-6 transcript and endpoint-drift evidence, yet no committed value could
   disagree with a truncated or reset file.

`drift-pins.sh` closes the first hole only for files that are *already* listed
(15 files, 19 symbol pins) and is blind to additions in the domain dirs. The
census is the complement: it declares the surface set, enumerates the declared
directories for anything undeclared, and pins runtime state by *shape*.

## Schemas

### `corpus/surface-census.tsv`

`path <TAB> class <TAB> kind <TAB> mode <TAB> note`

| column | values | meaning |
|---|---|---|
| `path` | absolute, `$HOME/...`, or `$STATE/...` | `$STATE` = `$HOME/.local/state/the-janitor`; only these two prefixes are expanded — a literal path into another lane's tree is a scope error, not a feature |
| `class` | `asset` / `runtime` | `asset` missing ⇒ `GONE` + exit 1; `runtime` missing ⇒ `ABSENT`, informational |
| `kind` | `file` / `dir` / `exec` | `exec` = regular file carrying a `u+x` bit; `stat -c %F`'s `regular empty file` is normalized to `file`, or every 0-byte surface (`client.lock`, `opencode.db-wal`) would report phantom kind drift |
| `mode` | 3–4 octal digits / `-` | exact match; `-` = declared but unchecked (used where the mode is not mode-stable or not owned here) |
| `note` | free text | no tabs; no secret value, no vault ref path, no account identifier |

Directive lines (`# scan<TAB><dir>`) declare which directories are *enumerated*:
every direct child of a declared scan dir must be a declared path, or it is
`UNLISTED` + exit 1. Four dirs are enumerable because they are unambiguously
this domain's: `$HOME/.config/the-janitor` (4 children), `$STATE` (5),
`$STATE/xdg-data/opencode` (5), `$HOME/.local/state/tac` (2) — 16/16 declared,
so a clean run reports 0. `~/.config/opencode` (20 children, 4 declared paths),
`~/.local/bin`, `~/.agents` and the chrome-profile subtree are deliberately
**not** enumerated: they are shared surfaces, and a `UNLISTED` verdict over
another lane's files would be an ownership claim this repo must not make.

### `corpus/state-shape.tsv`

`path <TAB> kind <TAB> assertion <TAB> value <TAB> note`

| kind | assertion | value | check |
|---|---|---|---|
| `sqlite` | `magic` | `SQLite format 3` | first 16 bytes compared byte-exact including the terminating NUL, via a scratch file + `cmp` — a text file carrying the 15-char prefix but not the NUL fails |
| `sqlite` | `mode`, `size_min`, `tables_min`, `tables_required`, `rows_min` | octal / bytes / count / comma list / `table:floor` | one metadata pass + one count pass |
| `log` | `mode`, `size_min`, `lines_min` | octal / bytes / count | content is never read or matched |
| `json` | `mode`, `keys` | octal / comma list | top-level key **names** only, `json.load` + `d.keys()` |
| `lock` | `mode` | octal | `client.lock` (0-byte flock file) |
| `marker` | `mode` | octal | `session-id` — a conversation marker, not a flock file; the kind exists so the assertion vocabulary makes no lock-semantics claim |

No assertion reads, prints or hashes content. `sha256` of a 0600 private file is
an offline oracle and stays withheld (round-9 sentinel ruling, restated in
`drift-gate.md` §Bounds); the census checks kind/mode, the baseline keeps the
16 published hashes, and the cross-check keeps the two from disagreeing.

## Verdicts and exit codes

| verdict | source | meaning |
|---|---|---|
| `OK` | surfaces / shapes | declared state observed |
| `DIVERGED` | surfaces | kind or exact mode differs from the declaration |
| `GONE` | surfaces | an `asset` path is missing (also a missing scan dir) |
| `ABSENT` | surfaces / shapes | a `runtime` path is missing now — never a failure |
| `LINK` | surfaces | the path is a symlink; the declaration describes a real file/dir |
| `UNLISTED` | surfaces | a direct child of a scan dir is not declared |
| `CROSSCHECK` | surfaces | this census and `drift-baseline.tsv` declare different modes for the same path |
| `SHAPE` | shapes | assertion failed (magic, mode, size/line/table/row floor, missing required table, missing JSON key, unparsable JSON) |
| `SKIP` | shapes | the database is **locked/busy** (a live serve is writing) — transient, exit-neutral, printed so it cannot hide |
| `UNVERIFIED` | shapes | the assertion **could not be evaluated** (no `sqlite3`, snapshot copy failed, unreadable/corrupt file) — exit 1. Fail-closed by design: a `CLEAN` summary over an unread shape class is the false-clean this gate exists to prevent (round-10 critic CE3). Only `locked`/`busy` is treated as transient |
| `PASS` / `FAIL` / `SKIP` | verbs | per-probe verdict |

Exit 0 clean (only `OK`/`ABSENT`/`SKIP`), 1 any drift or failed probe
(including `UNVERIFIED`), 2 usage or setup error.

**Sentinel dissent, recorded not resolved (round 10).** The security lane holds
that *any* `SKIP` under a `CLEAN` summary is an unverified class and should fail
the run. The landed call keeps `locked`/`busy` exit-neutral, because a healthy
handler legitimately holds the database while a request is in flight, and a gate
that turns red whenever the daemon is doing its job trains readers to ignore it
(the round-8 false-positive class). The compromise is that the summary always
prints `skipped=N` and the line names the reason — a reader who needs the DB
verified while the handler runs must stop it. Infra failure is *not* in this
category: it is `UNVERIFIED` and fails closed. A malformed data row aborts through `die` before any verdict is
printed — there is no partially-evaluated run. There is deliberately **no
`--pin`**: unlike a mechanical hash re-pin, editing a declaration is a scope
decision and must be a reviewed commit.

## Shape pins: floors, not hashes, and a snapshot read path

Three decisions make the runtime pinning honest:

0. **A class that cannot be read fails closed.** Infra failure (no `sqlite3`,
   snapshot copy failure, non-database file) yields `UNVERIFIED` + exit 1; only
   a `locked`/`busy` database is exit-neutral `SKIP`. The `sqlite3` binary is
   overridable (`SQLITE3_BIN`) so `--selftest` case 10 proves this path without
   touching a library.
1. **Floors are one third of the observed value** (`session:2` vs 7,
   `message:13` vs 39, `part:18` vs 55, `event:79` vs 238, `tables_min 12` vs
   20, log `size_min 16384` vs 33687 B). A floor can then fire only on
   truncation below a third. The corpus records no purge, vacuum, rotate or
   reset verb, but an operator `rm -rf $STATE/xdg-data` — the documented
   transcript reset — or a session delete through the unauthenticated control
   plane is plausible, and a floor that fires on *any* shrink would be the
   round-8 false-positive class. A reset lands at 0, below every floor, and the
   `SHAPE` it produces is the correct signal: at that moment every recorded
   census figure in `handler-on-disk-state.md` is stale.
2. **The database is read through a snapshot copy.** `cp -p` of `opencode.db`
   plus any non-empty `-wal`/`-shm` into `mktemp -d`, then
   `sqlite3 "file:<copy>?mode=ro"`. A read-only open of the *live* file still
   touches `-shm` (its mtime advances), which would make this gate a mutator of
   a surface it verifies — the same read-path rule `transcript-scan.sh` follows.
   For ad-hoc reads, `?immutable=1` avoids it too; `?mode=ro` alone does not.
3. **Two sqlite passes.** Call A reads only `sqlite_master` (table count +
   names); call B counts rows **only for tables that exist**. If a required
   table has been dropped, call A still succeeds and the verdict is `SHAPE
   (missing tables)`. A single combined query would instead fail the whole call
   and downgrade a dropped-table event to `SKIP` — a false clean, found by
   selftest case 11 (see `lessons/round-10.md`).

## Verb probes (`--verbs`)

The default set touches no `op` binary, spawns no tmux session, launches no
browser, and writes only inside `mktemp -d` and a scratch
`MUSKETEER_CHROME_PROFILE`:

| probe | what it exercises | expected | safety override |
|---|---|---|---|
| `cdp-ensure-scratch` | `cmd_cdp_ensure` write path | exit 0, JSON parses, `path` = BrowserSupport, 2 origins, mode 600, sole NMH entry | `MUSKETEER_CHROME_PROFILE=$scratch` |
| `cdp-ensure-missing-support` | the `-x` guard | exit 2, `BrowserSupport missing`, **no manifest file** — note the NMH *dir* is still created: `mkdir -p` precedes the guard (F3) | `ONEPASSWORD_BROWSER_SUPPORT=$scratch/nonexistent` |
| `refs-redaction` | `cmd_refs` ref-vs-plain branch | ref echoed verbatim, plain value replaced by `<redacted-non-op-value>`, plain value absent from stdout | `THE_JANITOR_ENV=$scratch` |
| `refs-shape-table` | the awk's **match** set | 4 of 7 line shapes listed; `export K=v`, ` K=v`, `lower_case=v` are silently omitted — an inventory read of `refs` can miss a key that exists | fabricated 7-line env file |
| `refs-redaction-prefix-only` | the awk's redaction **guard** | a value whose first five bytes are the ref scheme is echoed whole, plaintext tail included (F1) | fabricated env file |
| `usage-guards` | `run`/`refs` argument paths | exit 2 `missing command`; exit 2 `missing <env file>`; no file created | scratch env paths |
| `status-contract` | `cmd_status` static lines + live line | 5 static lines present; `state` agrees with `tmux has-session -t janitor` | `THE_JANITOR_STATE_DIR=$scratch` |

`--deep` adds the three probes with a real-world effect, all operator-present:
`run-plain-env` (execs `op`, plain values only → exit 0, value passed),
`run-ref-signed-out` (may block on the 1Password desktop prompt; accepts exit
`1` fast-fail **or** `124` at the bound, recorded with the wall time — both were
observed this round, 4 s and 25 s), and `tac-register-no-replace` (reads the
real custody record; `sha256`+mtime+size compared before/after; refuses to run
at all if the record is absent, so it can never *create* one).

## Round-10 findings these probes produced

- **F1 — `cmd_refs` redaction is a prefix match, not a validator.**
  `awk` L234 selects `v ~ /^op:\/\//`: a value beginning with the ref scheme is
  echoed whole, so `KEY=op://<fake>/<fake>/<fake> plaintext-tail` prints the
  tail. One value shape leaks; three odd key shapes are silently dropped
  instead of redacted. The corpus may therefore claim "keys and ref values are
  echoed, plain values are redacted" — it may **not** claim that `refs` output
  is safe to paste. `SKILL.md` carries this as a decision-table and
  anti-pattern row.
- **F2 — `run` over a ref, signed out, is non-deterministic and may block
  silently.** Observed exit 1 after 4 s with an `op` vault-name error, and exit
  124 at a 25 s bound with **both streams empty** (and a ~60 s desktop-prompt
  block in round 3's `_serve` path). A caller without a timer cannot tell
  "working" from "hung": bound it. Recorded in `knowledge/op-cli-surface.md`.
- **F3 — a refused `cdp-bridge ensure` still creates the NMH directory**
  (`mkdir -p` runs before the `-x` guard). Only the manifest file's absence is
  the refusal signal; the census asserts the file, not the tree.

## Bounds — what this gate does NOT do

- **Nothing runs it on a schedule.** All three gates are manual (or lane-run);
  a surface can drift while nobody looks. Round-9 recorded the same bound for
  `drift-pins.sh`.
- **`xdg-cache`/`xdg-state` are declared shallowly.** `$STATE/xdg-cache` is a
  direct child of a scan dir and is declared, but its subtree (`opencode/`,
  `opencode/bin/`, `bun/`, and the hash-named `bun/@t@/<hash>.pile`) is not
  enumerated, and only `opencode/opencode/models.json` carries a shape row.
  A hash-named, regenerable cache file cannot be tracked by a literal path —
  the scout's round-10 census listed it as `runtime` for that reason. Adding
  `$STATE/xdg-cache` as a scan dir would turn that pile into a permanent
  `UNLISTED`; the choice is to leave the subtree unpinned and say so.
- **Coverage is the declared set.** Enumeration is `maxdepth 1` over 4 dirs;
  nothing here sees a nested addition, a file inside `xdg-cache/`/`xdg-state/`
  (only 2 paths declared there), `~/.config/opencode` (20 children, 4 declared),
  `~/.local/bin`, `~/.agents`, or the chrome-profile subtree below the NMH dir.
- **`LINK` is the only link test.** A hardlink to a declared path is
  indistinguishable from the file itself (same limit as `drift-pins.sh`).
- **Mode checks are exact-octal.** A group-write change is `DIVERGED` by
  design; the single `mode = -` row (the contested chrome-profile
  dir) exists because a mode claim over another lane's surface is not ours to
  make — the scout measured it at 755, but kake leases that profile and a
  Chrome relaunch can recreate it.
- **Floors tolerate a >3× shrink.** Between one third and the observed value,
  the census stays green — the recorded census figures are a floor, not an
  equality.
- **`SKIP` is exit-neutral, `UNVERIFIED` is not.** A *locked* database produces
  no verdict (a live serve holds it) and is printed; any other inability to read
  it fails the run. There is no code path in which an unread shape class yields
  a `CLEAN` summary.
- **Cross-check coverage is the intersection.** A mode is cross-checked only when
  the same path appears in `drift-baseline.tsv`; the census rows written in the
  `$STATE` form resolve through a second lookup, and rows for paths the baseline
  does not carry (the runtime state) are cross-check-irrelevant by construction.
- **A declaration file is refused, not partially read.** Rows are parsed with a
  sixth field captured: a row carrying more than five fields is a `die` (exit 2),
  because a *fused* row — two rows with no newline between them, part of a note
  swallowing the next row — otherwise parses as a long note and silently drops an
  assertion. The L2 wave found exactly that in the first cut of
  `state-shape.tsv` (the `daybreak-blue-access.json` mode row vanished while the
  summary still read `CLEAN`); selftest case 14 pins the refusal.
- **`$STATE` itself is an `asset`, deliberately.** Deleting the state dir while
  the handler is stopped makes the run exit 1 — because the lock, the custody
  record and every declared `xdg-*` child are gone with it, which is exactly the
  event worth firing on. A `runtime` class here would *reduce* the signal.
- **The two sqlite passes are sequential.** A table dropped between them is
  reported as `rows_min` table-absent rather than as a parse failure — the
  ordering that keeps a dropped table from hiding behind `SKIP`.
- **`--deep` probes are not part of a routine run.** They execute `op` and one
  of them can raise a desktop prompt; the JSON output of `run` is not verified
  beyond exit status and the plain-value passthrough.
- **Defaults under test are only the ones encoded.** A verb branch not encoded
  as a probe is unverified — `start`/`request`/`stop`/`_serve` are deliberately
  unprobed (tmux session creation/destruction and the auth prompt are external
  effects), and `--verbs` never exercises a live vault ref.
- **Not a security control.** It detects surface change; it neither prevents
  the round-6 config-drop vector nor substitutes for the operator decisions
  listed in `corpus/README.md` (endpoint fix, control-plane password).

## Reproduction (2026-09-28)

```bash
cd ~/projects/shokunin/kagi-shokunin
bash corpus/surface-census.sh                  # CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0), exit 0
bash corpus/surface-census.sh --verbs          # CLEAN (pass=7 skip=3), exit 0 — no op exec
bash corpus/surface-census.sh --verbs --deep   # CLEAN (pass=10 skip=0), operator present, ≤25 s
bash corpus/surface-census.sh --selftest       # SELFTEST: PASS (16 cases), exit 0
# drift a copy, not the data file, to see a verdict:
sed 's|^$HOME/.config/the-janitor/op.env\tasset\tfile\t600|&|' corpus/surface-census.tsv >/dev/null
```

Selftest cases (verbose output names each; 15 total): clean 0 · mode drift `DIVERGED` ·
asset gone `GONE` · runtime absent `ABSENT` still 0 · undeclared child
`UNLISTED` · baseline mode disagreement `CROSSCHECK` · symlink swap `LINK` ·
non-database `SHAPE` · SQLite prefix without NUL `SHAPE` · dropped required
table `SHAPE (missing tables)` · `SQLITE3_BIN=<absent>` → `UNVERIFIED`
(`unverified=3`), exit 1 · emptied table `SHAPE (rows <table> <n> < floor)` ·
malformed row exit 2 · verbs sandboxed 0 · injected probe failure
(`CENSUS_BREAK=<probe>`) exit 1.

## Falsification

Each of these should turn the gate red; run it on a copy, never on the host:

1. `chmod 644 ~/.config/the-janitor/op.env` → `DIVERGED`.
2. Move `~/.local/bin/the-janitor` aside → `GONE`.
3. `rm ~/.local/state/the-janitor/xdg-data/opencode/log/opencode.log` →
   `SURFACE ABSENT` + `SHAPE ABSENT`, exit **0** (runtime, informational).
4. `touch ~/.config/the-janitor/notes.md` → `UNLISTED`, exit 1 (the round-6
   vector's detection path).
5. Change the census's declared mode for any path that `drift-baseline.tsv`
   also pins → `CROSSCHECK`, exit 1.
6. Overwrite the DB's first bytes with `NOTSQLITE` → `SHAPE (magic mismatch)`.
7. `drop table part` on a DB copy → `SHAPE (missing tables: part)`, never
   `SKIP` (this exact case is selftest 10).
8. `delete from part` on a copy → `SHAPE (rows part 0 < floor 18)`.
9. `rm -rf $STATE/xdg-data` → every DB/log floor fires; the recorded census in
   `handler-on-disk-state.md` is stale from that moment.
10. `MUSKETEER_CHROME_PROFILE=/tmp/x the-janitor cdp-bridge ensure` with
    `ONEPASSWORD_BROWSER_SUPPORT=/nonexistent` → exit 2 and no manifest file
    (but the temp NMH dir *is* created — assert the file, not the tree).
11. Break any default probe (`CENSUS_BREAK=cdp-ensure-scratch`) → `FAIL`,
    exit 1.