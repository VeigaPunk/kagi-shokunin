# Round 10 lesson — declared surfaces are prose until a gate reads them

Axis moved: **coverage 6 → 8**. Round 9 made *content* claims falsifiable
(`drift-pins.sh`); the surface claim itself — `PROVINCE.md` §Surfaces — was
still prose, so two classes had no verdict at all: an **addition** next to a
declared file, and a **runtime artifact** deliberately left unpinned.

## What landed

`corpus/surface-census.sh` v1 + `corpus/surface-census.tsv` (35 rows) +
`corpus/state-shape.tsv` (20 rows) + `knowledge/surface-census.md`.

- 2026-09-28: `SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34
  absent=2 skipped=0)` exit 0; `--verbs` `CLEAN (pass=7 skip=3)`; `--verbs
  --deep` `CLEAN (pass=10 skip=0)`; `--selftest` `SELFTEST: PASS (16 cases)`.
- Sibling gates unchanged after the round: `DRIFT_PINS: CLEAN (files=15
  symbols=19)` + `DRIFT_SELFTEST: PASS (13 cases)`; `TRANSCRIPT_SCAN: HITS=2
  warns=2 cells=888` (the known `xai-` prose collision, no secret material).

## What the selftest caught (the point of building it before believing the gate)

Two real defects, both of the class this repo keeps meeting — **a gate that
reports clean because it failed to look**:

1. **A dropped required table read as `SKIP`.** The first implementation asked
   for the table list *and* the row counts in one `sqlite3` call; dropping
   `part` made the whole call fail, so `tables_min`, `tables_required` and
   `rows_min` all became exit-neutral `SKIP` and the run exited 0. Fixed by two
   passes: metadata first (never depends on a data table), counts second and
   only for tables that exist. Selftest case 11 now pins `SHAPE (missing
   tables)`.
2. **The fixture did not scan the directory the case mutated.** Case 5 created
   an undeclared `session-id` in a directory no `# scan` directive covered, so
   `UNLISTED` could not fire and the case "passed" as clean. That is the same
   shape as round 9's finding that the drift gate had nothing stored: the
   harness has to exercise the real scope, not a subset of it.

Also worth recording: `declare -A` inside a function is *local*, so assigning to
an undeclared associative array turns the subscript into arithmetic and aborts
mid-run with exit 1 — which is why the selftest compares exit codes **and**
verdict tokens, not either alone.

3. **A third defect came from the L2 critic, not the harness:** `SKIP` was
   fail-open, so an unread shape class could still print `CLEAN`. Selftest case
   10 now pins the fail-closed path (`SQLITE3_BIN=<absent>` → `UNVERIFIED`,
   exit 1) — 16 cases total.

## The L2 critic's blockers, and what happened to each

The critic lane attacked a stale snapshot of the script plus the scout's
frozen draft data, so four of its clauses described
things the landed file never did (no `# scan` directives; a 17-character magic
value; `MALFORMED` advertised; `session-id` given lock semantics). Its own
output was session-scoped scratch and is not retained — the durable residue is
the verdict list below. Round 11's citation gate flagged the raw URI that stood
here: a committed doc citing scratch is a citation no fresh session can resolve
(the class the protocol lane logged for kumitate, D-19). Two clauses
were **real** and are fixed here, one was **fixed while it was writing**, and
the rest are recorded as accepted boundaries:

| Counterexample | Verdict | Action |
|---|---|---|
| CE3 `SKIP` is fail-open — no `sqlite3`/snapshot failure prints `CLEAN skipped=N` with the whole DB shape class unverified | **accepted, real** | `UNVERIFIED` verdict added: only `locked`/`busy` is exit-neutral `SKIP`; everything else fails the run. `SQLITE3_BIN` override added so selftest case 10 proves it (`unverified=3`, exit 1) |
| CE5 `--deep` prints both sha256 digests of the 0600 custody record on failure, contradicting the gate's own hash policy | **accepted, real** | comparison is now digest-free: `check sha-unchanged ok|FAIL (custody record digest changed)` |
| CE6 the cross-check joins on the raw path string, so a `$STATE`-form row escapes the `$HOME`-form baseline row | accepted (already true of the shipped data) | second lookup on the `$HOME`-mapped resolved path added |
| CE7 the mode loader accepts `0755` while `stat -c %a` prints `755` → a data typo becomes permanent `DIVERGED` | accepted | loader restricted to three octal digits and the error text now says so |
| CE4 `rows_min` floors encode history: after a deliberate reset the first requests re-trip them on a healthy handler | accepted as documented semantics | bounds now say a post-reset `SHAPE` means "re-anchor the floors and the recorded census in one commit", not corruption; the verdict line carries the hint |
| CE1/CE2/CE8 (no scan directives, 17-char magic, status races) | stale or not constructible | the shipped file has 4 scan directives; magic is 15 chars compared NUL-exact (case 9 pins the counterexample); the status line is written once and compared once |
| cheap gain: no shape row for the two TAC custodian JSONs | accepted | `keys` rows added for `handoff-state` (14 keys) and `daybreak-blue-access` (8 keys) — a rewrite dropping a published field is now visible |
| cheap gain: verbs scratch guard | accepted | `--verbs` refuses a scratch root outside `$VERB_ROOT` and each probe path is asserted under it before exec |

Two further clauses it could **not** construct are worth keeping: no symlink
defeat (`-L` is tested before `-e`), and no double-report in `UNLISTED`
(declared-path matching is `resolve()`-string equality on both sides).

## The L2 wave found a defect in *my* artifact — which is the point of the wave

The state scout independently reproduced, on the shipped
`corpus/state-shape.tsv`, that the file declared 22 rows while the loader saw
21: two rows had fused into one 9-field line because an appended block landed on
a file whose last line had no trailing newline. The swallowed row was
`daybreak-blue-access.json mode 600` — an *assertion silently dropped* while the
summary still read `CLEAN`. That is the same false-clean class the gate exists to
detect, one level up: in the data file rather than in the host.

Fixed two ways: the row is split (22 rows, every row 5 fields), and both loader
loops now capture a sixth field and `die` (exit 2) on a fused row — selftest case
14 pins the refusal. A gate that parses a declaration file partially is not a
gate.

Two further observations from the same lane, resolved as deliberate calls:

- **9 surfaces in the scout's broader census are not in the landed one** (the
  `xdg-cache` subtree incl. a hash-named `bun/@t@/*.pile`, the `$HOME/.config/opencode`
  dir, and the in-repo `corpus/drift-*`/`transcript-scan.sh` files). None is a
  direct child of a scan dir, so none can be `UNLISTED`; the cache subtree is
  named in §Bounds as unpinned, and the repo's own gate files are verified by
  `drift-pins.sh` + their own selftests, not by a declaration row.
- **`$STATE` stays `asset`** (the scout proposed `runtime`): deleting the state
  dir while stopped removes the lock, the custody record and every declared
  `xdg-*` child, so exit 1 is the correct signal rather than a false alarm.

## Design calls that were not obvious

- **Snapshot read.** `sqlite3 "file:…?mode=ro"` on the live DB still advances
  `opencode.db-shm`'s mtime: a verification gate that mutates what it verifies
  invalidates the very claims it is checking. The gate copies `db`+`-wal`+`-shm`
  into `mktemp` and reads the copy (the same rule `transcript-scan.sh` follows
  with `?immutable=1`).
- **Floors, not hashes, for runtime state.** Row/table floors at one third of
  the observed value fire on a reset or >3× truncation and never on growth —
  the round-8 false-positive lesson applied to `rm -rf $STATE/xdg-data`, the
  documented reset path. A reset *must* turn the gate red, because it makes the
  recorded census in `handler-on-disk-state.md` stale.
- **No enumeration of shared directories.** `~/.config/opencode` has 20 children
  and only 4 janitor-reaching paths; `~/.local/bin`, `~/.agents` and the
  chrome-profile subtree belong to other lanes. Enumerating them would convert
  an ownership question into a `UNLISTED` verdict. The census declares what
  reaches the handler and *reports* the rest.
- **`--deep` split.** Three probes have real-world effects (`op` exec, a
  possible desktop approval prompt, reading the custody record). Default
  `--verbs` execs no `op` binary and writes nothing outside scratch; the
  L2 planner objected to the earlier all-in-one shape and was right.
- **Ref-literal hygiene.** The redaction probes must feed a value beginning with
  the ref scheme, so the script assembles the prefix at runtime; no committed
  line carries a ref-shaped literal, even a fabricated one.

## Findings the probes produced (coverage that paid for itself immediately)

- `cmd_refs` redaction is a **prefix match** (`v ~ /^op:\/\//`): a ref-shaped
  value is echoed whole with any plaintext tail, and three odd key shapes are
  silently omitted from the inventory. The decision table previously implied
  `refs` output was redacted.
- `run` over a ref while signed out is **non-deterministic**: exit 1 in ~4 s or
  no output at all until the bound (exit 124 at 25 s).
- A refused `cdp-bridge ensure` still creates the NMH **directory**
  (`mkdir -p` precedes the `-x` guard) — assert the manifest file, not the tree.

## Axis note

Coverage moved to 8, not 10: nothing schedules the gates, enumeration is one
level deep, and three probes are opt-in. Those are the named ceilings in
`knowledge/surface-census.md` §Bounds, and the next coverage move should attack
the *nested* surface class (an addition inside `xdg-cache/`, `xdg-state/`, or a
second plugin/tool directory) rather than widen the same four scan dirs.