# XParseSiteProbe — BASE parse-site token tabulation (round-28 BUILD)

BASE `3553d499577084a6c98d7078906017840bbf7b28`. Sandbox:
`.ufo/waves/round-28/sandboxes/XParseSiteProbe-7/` (harness.py, table.md,
probe-results.json; BASE tree under `base/`). Lane production files untouched.
Interpreter CPython 3.14.8; `sys.get_int_max_str_digits()` = 4300.
All path:line below are `corpus/release-clock.py` at BASE.

## Findings

1. **`VERSION_RE` is a dead site at BASE.** Defined :30-33, referenced nowhere
   else in the live tree (grep: only :30 plus historical `.ufo/waves/round-2[567]`
   artifacts). Canonicality work has no `VERSION_RE` consumer to fix. Real
   consumers: `version_is_named` :341-347 (→:566), `numeric_version` :369-379
   (→:404,:408,:577), `is_regression` :383-387 (→:567-568,:794-796),
   `feed_floors` :390-406 (→:523,:885), `norm_version` :362-363
   (→:444,:582,:585,:798), title/href/text regexes :710-712 (→:727,:752,:755),
   `max(stable, key=…)` :760.
2. **Leading-zero tokens flow through every accepting site as-is.**
   `3.15.01`/`03.15.1`/`3.15.00` accepted by all regex sites and
   `parse_latest_version` (xml+text). `numeric_version("3.15.01") ==
   numeric_version("3.15.1")` → `(3,15,1)`. Fired-lie chain at BASE: row
   anchored `3.15.1`, observed `3.15.01`, verdict `fired` → :567-568
   `is_regression` False (numeric equal — the :569-571 comment itself calls
   the equal case indistinguishable), :566 `version_is_named` guards only the
   anchor, :582 fired check is `norm_version` string equality →
   `"3.15.01" != "3.15.1"` → row_fired. A zero-padded observation fires.
3. **Oversize components (>4300 digits) split by call path.** `numeric_version`
   :379 `int(part)` raises `ValueError: Exceeds the limit (4300 digits)…` for
   4301/4302-digit components.
   - evaluate: :523/:567-568 run inside `evaluate`, whose only handler :1749
     is `except SetupError` → uncaught **Traceback** (plan predicate:
     MISHANDLED).
   - run_observe: :885 `feed_floors(rows)` is outside any try → same
     traceback from an oversize *anchored_version* column alone.
   - observe_one: :789/:794-796 raise inside the try; :822
     `except (OSError, ValueError)` → `receipt["error"]` → exit 1, no
     traceback, but the message is CPython's, not a typed finding.
   - text feed with 4301-digit version is **accepted verbatim** by
     `TEXT_VERSION_RE`/:727-729 (no int conversion in text mode); blow-up is
     deferred to :794.
4. **Boundary junk accepted by lookaround sites.** `VERSION_RE` (lookarounds
   exclude only `[A-Za-z0-9.]`) accepts `3.15.1_0` (returns `3.15.1`),
   ` 3.15.1`, `3.15.1\n`. `version_is_named` is search-based: anchors
   `3.15.1_0`, ` 3.15.1`, `3.15.1\n` all name version `3.15.1` (True →:566),
   while `vin("3.15.1","3.15.01")` is False — anchor side would flag
   INCONSISTENT for zero-padded anchors, observed side is string-only
   (:582/:585).
5. **Whitespace, case, zeros.** Callers strip title :752 / href :755, so
   ` 3.15.1` is accepted in situ (raw `.match` rejects). `3.15.1\n`:
   `STABLE_TITLE_RE` `$` :710 and `TEXT_VERSION_RE` MULTILINE `$` :712 accept
   before the final newline even raw; `"Version: 3.15.01"` with no trailing
   newline also matches. `V3.15.1`: :710/:711/:712 are case-sensitive → an
   uppercase-V title is NOT stable (single-entry feed errors `feed has no
   stable X.Y.Z release entry`) while `VERSION_RE`/`norm_version`/
   `version_is_named` accept it — asymmetry. `0.0.0` is stable everywhere;
   as an anchor it becomes a `0.0.0` feed floor for the whole feed.
6. **`feed_floors` quirks.** Stores the anchored string verbatim (floor value
   `v3.15.1`); non-numeric anchors silently skipped (:404-405 `anchor is
   None: continue`) → `<no-floor>` with no diagnostic; zero-equal anchors
   merge silently (floor_merge `3.15.1`+`3.15.01` → `3.15.1`).
7. **max() tie keeps the first entry verbatim** (:760): feed titled `3.15.01`
   with later `3.15.1` entry returns `3.15.01` (equal keys); `max("3.15.1",
   "3.15.10")` → `3.15.10` (numeric order otherwise correct). Oversize title
   raises inside the key function; fullwidth-title entry is silently dropped
   (feed errors only if no other stable entry exists).

## Token × site table (BASE, harness run)

huge4301 = `3.15.1` + `1`×4300 (third component 4301 digits); huge4302 =
`3.15.1` + `1`×4301. `EXC ValueError(int-str,N)` = CPython `ValueError:
Exceeds the limit (4300 digits)…value has N digits`. vin =
`version_is_named`. `<no-floor>` = anchor excluded from floors.

| token | VERSION_RE :30 | NUM_RE.fullmatch :366 | numeric_version :369 | is_reg(3.15.1,tok) :383 | feed_floors(anchor) :390 | vin(a=3.15.1) :341 | vin(a=tok) :341 | TITLE.match :710 | HREF raw :711 | HREF tag/ :711 | TEXT raw :712 | TEXT line :712 | latest xml :715 | latest text :715 | max(tok,3.15.1) :760 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `3.15.01` | accept | accept | `(3,15,1)` | False | floor `3.15.01` | False | False | accept | reject | accept | reject | accept | accept `3.15.01` | accept | `3.15.01` tie→first |
| `03.15.1` | accept | accept | `(3,15,1)` | False | floor `03.15.1` | False | False | accept | reject | accept | reject | accept | accept | accept | `03.15.1` tie→first |
| `3.15.0` | accept | accept | `(3,15,0)` | True | floor `3.15.0` | False | False | accept | reject | accept | reject | accept | accept | accept | `3.15.1` |
| `3.15.00` | accept | accept | `(3,15,0)` | True | floor `3.15.00` | False | False | accept | reject | accept | reject | accept | accept | accept | `3.15.1` |
| `0.0.0` | accept | accept | `(0,0,0)` | True | floor `0.0.0` | False | False | accept | reject | accept | reject | accept | accept | accept | `3.15.1` |
| huge4301 | accept | accept | EXC(int-str,4301) | EXC(int-str,4301) | EXC(int-str,4301) | False | False | accept | reject | accept | reject | accept verbatim | EXC(int-str,4301) | accept verbatim | EXC(int-str,4301) |
| huge4302 | accept | accept | EXC(int-str,4302) | EXC(int-str,4302) | EXC(int-str,4302) | False | False | accept | reject | accept | reject | accept verbatim | EXC(int-str,4302) | accept verbatim | EXC(int-str,4302) |
| `3.15.１` | reject | reject | None | False | `<no-floor>` | False | False | reject | reject | reject | reject | reject | EXC no-stable-entry | EXC no-Version-line | `3.15.1` dropped |
| `3.15.1_0` | accept `3.15.1` | reject | None | False | `<no-floor>` | False | True | reject | reject | reject | reject | reject | EXC no-stable-entry | EXC no-Version-line | `3.15.1` |
| ` 3.15.1` | accept `3.15.1` | reject | None | False | `<no-floor>` | False | True | reject raw; in-situ accept (strip :752) | reject | reject (interior sp) | reject | accept | accept | accept | `3.15.1` |
| `3.15.1\n` | accept `3.15.1` | reject | None | False | `<no-floor>` | False | True | accept (`$` before \n) | reject | accept (`$` before \n) | reject | accept | accept | accept | `3.15.1` |
| `v3.15.1` | accept `3.15.1` | reject | `(3,15,1)` | False | floor `v3.15.1` verbatim | True | True | accept `3.15.1` | reject | accept `3.15.1` | reject | accept | accept | accept | `3.15.1` |
| `V3.15.1` | accept `3.15.1` | reject | `(3,15,1)` | False | floor `V3.15.1` verbatim | True | True | reject (case) | reject | reject (case) | reject | reject (case) | EXC no-stable-entry | EXC no-Version-line | `3.15.1` |

Extra scenario results (same run): `TEXT_VERSION_RE` matches
`"Version: 3.15.01"` with no trailing newline; exact CPython limit message
and full values preserved in `table.md`/`probe-results.json`.

## Commands (sandbox only; lane checkout never executed)

- `git -C kagi-shokunin archive 3553d49… | tar -x -C …/XParseSiteProbe-7/base`
  → exit 0.
- `python3 -I -B harness.py > table.md 2> stderr.txt` → exit 0, stderr empty
  (BASE module imported read-only via importlib; no network, no writes outside
  sandbox). One harness-side bug (cell() dropped its token argument → spurious
  TypeError column) was fixed before this run; table.md is the corrected run.
- `grep -n` consumer/dead-site confirmation → exit 0.

## Tooling installs

None — existing CPython sufficed; nothing installed or updated.

## What I did NOT check

- End-to-end `c1-measure.py`/`c2-measure.py` fixture runs (parent owns the
  frozen counters); my probe is site-level.
- Real network/observe runs; `--observe` receipts reasoned from :885/:822,
  not executed. Multi-entry feeds beyond the max() probes; normalizer and
  `MAX_FEED_ENTRIES` interaction with huge tokens.
- Non-CPython interpreters / non-default `PYTHONINTMAXSTRDIGITS`.
- C2 derived-anchor binding (outside this item).
