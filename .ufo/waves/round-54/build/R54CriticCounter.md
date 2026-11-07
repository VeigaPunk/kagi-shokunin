# R54CriticCounter — adversarial attack on the frozen C1 counter

Seat: `R54CriticCounter` (leaf, no dispatch). Target: `plans/round-54-c1.sh` (frozen), predicate
`C1_OP_CLOCK: value = WATCHED + MEASURED when GUARD = 1, else 0; target 2 (BASE 0)`.
BASE `1a0f43a9220bb0e995462c2aef745ac0124c3317`; candidate `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14`.
Scratch: `/fast/scratch/hyaku/kagi-r54/R54CriticCounter` (`tree0` = `git archive ede4373 | tar -x`;
each fixture = `cp -al tree0 fx/<id>` + one edit; `HYAKU_SCRATCH` set to the scratch root).
Every run: `C1_ASOF=$(date +%s) bash plans/round-54-c1.sh --tree <fixture>`; the counter `cp -a`s the
tree itself, so hardlinked fixtures are copied, never mutated.

## Frozen reading (control)

| reading | command | rc | last line |
|---|---|---|---|
| BASE | `bash plans/round-54-c1.sh 1a0f43a…` | 0 | `C1_OP_CLOCK: value=0 watched=0 measured=0 guard=1 (bad=watched:s072-recheck=180d measured:oprcpt-missing-or-symlink; gate-line=RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17))` |
| candidate | `bash plans/round-54-c1.sh ede4373…` | 0 | `C1_OP_CLOCK: value=2 watched=1 measured=1 guard=1 (bad=watched:OK measured:OK; gate-line=RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17))` |
| candidate `--tree` | `C1_ASOF=$(date +%s) … --tree tree0` | 0 | `value=2 watched=1 measured=1 guard=1 … CLEAN` |

Candidate commit time `1794032188` = `2026-11-07T06:16:28Z`; receipt S072 `observed_at`
`2026-11-07T05:54:19Z` — 22 min inside the window, so the frozen reading is coherent.

## Forgery table

`value` is the counter's own `value=`; `gate` is the last gate line the counter consumed. Where the
gate line is `CLEAN` but the gate was shadowed, the **real** gate's verdict is given in the cell.

| id | edit (fixture under `fx/`) | value | gate | classification |
|---|---|---|---|---|
| c0 | none (control) | 2 | CLEAN | not scoring (calibration) |
| f1 | real `### 11.2` deleted; new `## 11.9 Retired notes` section carries `### 11.2` + ``op `2.42.0` `` | **2** | CLEAN | **counter defect** — line 249 re-enters on `## 11.9`; predicate says §11 ends at the next `## ` |
| f2 | real `### 11.2` deleted; a fenced code block **inside §11** holds `### 11.2` + ``op `2.42.0` `` | **2** | CLEAN | **counter defect** — line 254 is fence-blind (a fenced line is not a heading) |
| f2b | real `### 11.2` deleted; a multi-line HTML comment inside §11 holds `### 11.2` + ``op `2.42.0` `` | **2** | CLEAN | **counter defect** — comment-blind |
| f3 | real `### 11.2` deleted; a fenced block after §11 holds `## 11.` + `### 11.2` + ``op `2.42.0` `` | **2** | CLEAN | **counter defect** — the `## ` section detector is fence-blind |
| f4 | real S072 row + the same row inside a multi-line HTML comment | 1 | `SETUP (corpus/SOURCES.md:276 duplicates S072)` | not scoring (correct; `rows()`=2 and gate backstop) |
| f5 | real S072 row + a 4-space-indented S072 row with `180d` | 1 | `SETUP (…:275 duplicates S072)` | not scoring (counter's `rows()` misses it, gate catches it) |
| f6 | real S072 row indented 4 spaces (`180d`) + a forged on-release row outside | 1 | `SETUP (…:275 duplicates S072)` | not scoring (gate backstop) |
| f7 | extra registry row S113 on the feed URL **with a trailing slash** | **2** | CLEAN | **predicate gap + counter defect** — `by_url` exact-string (line 133); gate has no feed-URL uniqueness check |
| f28 | extra registry row S115 on the feed URL **with `?utm=1`** | **2** | CLEAN | same as f7 (query variant) |
| f8 | extra registry row S114 on the **exact** feed URL with 12 cells | 1 | `SETUP (…:275 has 12 fields, expected 11)` | not scoring (gate backstop; `by_url` silently skips len≠11) |
| f9 | extra S072 clock row with a leading space, verdict `not-fired` | 1 | `FAILED (on_release=32 bound=31 unbound=0 observed=31 fired=13 derived=17)` | not scoring (gate backstop) |
| f10 | S072 clock row terminated CRLF | 2 | CLEAN | not scoring (text-mode newline normalization; no effect) |
| f11 | op receipt: `escaped-lf` case line duplicated | 1 | CLEAN | not scoring (correct; `sorted(cases)` exact) |
| f12 | op receipt: `trailing-lf` case line with three trailing spaces | 1 | CLEAN | not scoring (correct) |
| f13 | op receipt: extra `escaped-lf … status=FAIL` line under the CLEAN summary | 1 | CLEAN | not scoring (correct) |
| f14 | `.ufo/waves/round-54/final` replaced by a symlink to a sibling dir | 0 | CLEAN | not scoring (correct; K1-F12) |
| f15 | real `### 11.2` deleted; `### 11.2` + ``op `2.42.0` `` placed under `## 10.` | 1 | CLEAN | not scoring (correct) |
| f16 | `corpus/json.py` shadow (prints CLEAN/PASS, exit 0) + S027 clock row deleted | **2** | CLEAN (real gate on same table: rc=1 `FAILED (… bound=31 unbound=1 observed=31 …)`) | **counter defect** — gate subprocess (line 90) runs with `$T/corpus` on `sys.path` |
| f17 | S072 receipt `observed_at` → `2026-11-08`, gate digest rewritten, table **not** updated | 1 (honest ASOF) / 1 (huge ASOF) | `FAILED (… observed=31 …)` | declared ceiling (forged receipt) — gate's receipt/table cross-check catches the naive version |
| f18 | `FEED_TITLE_PREFIXES[OPFEED]` → `1Password` | 0 | CLEAN | not scoring (correct; `parse-ValueError` + selftest fail) |
| f19 | op receipt replaced by a relative symlink to the same bytes | 1 | CLEAN | not scoring (correct) |
| f20 | f5 (indented duplicate S072) **+ `corpus/json.py` shadow** | **2** | CLEAN (real gate: `SETUP duplicates S072`) | **counter defect** — shadow disables the gate backstop |
| f21 | f8 (12-cell duplicate feed row) **+ shadow** | **2** | CLEAN (real gate: `SETUP 12 fields`) | **counter defect** |
| f22 | f9 (leading-space duplicate clock row) **+ shadow** | **2** | CLEAN (real gate: `FAILED observed=31`) | **counter defect** |
| f23 | selftest case expected `2.42.0`→`2.42.1` **+ shadow** | **2** (no-shadow run: **0**) | CLEAN (real selftest: rc=1 `RELEASE_CLOCK_SELFTEST: FAIL version parser declared product prefix: '2.42.0' != '2.42.1'`) | **counter defect** — GUARD conjunct fully forgeable (+2) |
| f24 | receipt **and** clock `observed_at` → `2026-11-08`, gate digest rewritten (consistent) | 1 honest / **2** with `C1_ASOF=99999999999999999999` | CLEAN | declared ceiling (forged receipt) + ASOF widening |
| f25 | capture replaced by a 212-byte fabricated RSS (`1Password CLI 2.42.0`); counter run from a cwd holding `hashlib.py` | **2** | CLEAN | **counter defect** — `python3 -` heredoc (line 95) puts the caller's cwd on `sys.path`; capture digest (line 216) is chosen by the shadow |
| f26 | same fabricated capture, clean cwd (control for f25) | 1 | CLEAN | not scoring (correct; `watched:capture-sha`) |
| f27 | op receipt hand-written (11 exact lines, no archive/signature evidence) | **2** | CLEAN | declared ceiling (reproduced as declared) |

## Findings

### A. The entry conjunct is fence-blind, comment-blind and section-re-entrant (counter defect, +1)

`measured()` scans the entry as raw lines: `on = l.startswith("## 11.")` (line 249) re-enters on **any**
`## 11.*` heading, and `re.search(r"^### 11\.2\b", s, re.M)` (line 254) accepts a line inside a code
fence or an HTML comment. The frozen predicate says "the measured `corpus/knowledge/op-ref-consumption.md`
section `## 11.` (to the next `## `) contains a `### 11.2` heading and names op `2.42.0` (backticked) at
least once". f1/f2/f2b/f3 delete the real §11.2 and still read `measured=1`, i.e. **value 2 where the
predicate's entry conjunct is false**. The op receipt in those fixtures is the genuine one, so the
*measure* is real; the *documentation* conjunct is not. The live leg (re-fetch feed, download op, run the
probe) cannot catch this — it checks the binary, not the entry. The registry scan (`rows()`, line 117)
already has a fence toggle; the entry scan has none.

Smallest safe correction: in the entry scan, (i) set `on = False` at **every** `## ` line and enter only
on the first `## 11.` heading, (ii) skip fenced blocks (reuse the `rows()` toggle) and `<!-- … -->`
blocks, (iii) require the `### 11.2` line to be an ATX heading at column 0 outside both.

### B. The measured gate is not an independent authority (counter defect, +1 to +2)

The gate and its selftest are run as `python3 corpus/release-clock.py` with cwd `$T` (lines 85, 90).
CPython puts the script's directory (`$T/corpus`) at `sys.path[0]`, so a sibling `corpus/json.py` is
imported instead of the stdlib module; it prints `RELEASE_CLOCK: CLEAN …` / `RELEASE_CLOCK_SELFTEST:
PASS …` and exits 0. The gate file stays byte-identical to the candidate's, so the counter's `m1`/`m2`
receipt-path regexes still pass. Effects measured:

- f16: broken clock table (S027 row deleted; real gate `FAILED unbound=1`) → counter `value=2`.
- f23: real selftest `FAIL` (rc 1) → counter `value=2`; the same tree without the shadow reads `value=0`.
- f20/f21/f22: the gate's own duplicate/field/clock backstops (which correctly reject f5/f8/f9) are
  disabled, so two S072 rows, two feed rows or two clock rows coexist with `value=2`.

This is outside the named ceilings: no receipt is forged (the candidate receipt is used), no op receipt
is hand-written, and the gate file is untouched. The counter's **own** in-process import of the gate is
not reached by `corpus/json.py` (the heredoc's `sys.path[0]` is the caller's cwd, not `$T/corpus`), but
the two subprocesses are; finding C is the same class on the heredoc itself.

Smallest safe correction: `python3 -I corpus/release-clock.py` (and `-I` for `--selftest`). `-I` implies
`-P` (no script-dir on `sys.path`) and ignores `PYTHON*` env; `-P` alone would not stop `PYTHONPATH`.

### C. The counter's own interpreter trusts the caller's cwd (counter defect, full WATCHED forgery)

`res=$(python3 - "$T" …)` (line 95) runs stdin-mode Python, whose `sys.path[0]` is `''` (the caller's
cwd). A `hashlib.py` in that cwd makes `hashlib.sha256(...).hexdigest()` return chosen digests, so the
receipt digest (line 194) and the capture digest (line 216) are no longer byte checks. f25: the capture
is replaced by a 212-byte fabricated RSS whose only item is `1Password CLI 2.42.0`; the receipt is the
**genuine** one; run from `cwdhash/` the counter reads `value=2 watched=1`. From a clean cwd the same
tree reads `value=1` (`watched:capture-sha`, f26). This is outside the named ceilings (no forged
receipt, no hand-written op receipt) and it also affects the **frozen reading**, which uses the same
heredoc: a verifier who runs the counter from a tainted cwd gets the same forged verdict. The live leg
re-fetches the feed and would catch the fabricated body, but the counter cannot.

Smallest safe correction: `python3 -I - "$T" …` for the heredoc (isolated mode), plus `-I` for the two
gate subprocesses. Note the script's own `command -v python3` check does not pin an absolute interpreter;
`-I` is the smallest change that removes cwd/`PYTHON*` influence.

### D. Duplicate authority on the feed URL (predicate gap, faithfully implemented)

`by_url(reg, OPFEED)` (line 133) compares the exact URL string. f7 adds a second registry row S113 on
`https://releases.1password.com/developers/cli/index.xml/` (trailing slash): `by_url` returns `[S112]`,
the gate prints CLEAN, and the counter reads `value=2` with **two** registry rows for the same feed.
The frozen predicate says "exactly one registry row … whose URL is OPFEED", so a trailing-slash URL is
literally not OPFEED — the counter is faithful; the *sentence* permits two authorities. The same hole
exists for a `?query` suffix (f28: `…/index.xml?utm=1`, also `value=2`), and (under the shadow) for a
12-cell row on the exact URL (f21). No value inflation by itself (the visible S112 row is genuine), but
the "one authority per feed" intent is not enforced by either the counter or the gate.

The "different prefix but parse still returns 2.42.0" idea is **not reachable** with the genuine capture:
its only title that yields 2.42.0 is `1Password CLI 2.42.0` (the channel title `1Password CLI - 1Password
Releases` does not match the anchored rule), and `prefixed_title_re` is `re.escape`d and anchored at both
ends, so `1Password` and `1Password CLI ` (trailing space) both fail — f18 shows the `1Password` failure
(`parse-ValueError`, and the selftest fails too).

Smallest safe correction for the next predicate: normalize the feed URL (strip trailing `/`, query,
fragment) before the uniqueness test, or require that no other registry row shares the feed's
origin+path. Cannot be fixed this round without unfreezing the predicate.

### E. ASOF widening (declared ceiling; `--tree` only)

`--tree` takes `C1_ASOF` verbatim (lines 68–69). f24 moves the receipt **and** the clock row to
`2026-11-08`, rewrites the gate digest, and reads `value=1` with an honest `C1_ASOF` but `value=2` with
`C1_ASOF=99999999999999999999`. This is the declared forged-receipt ceiling, reachable only through
`--tree` (which the plan says "is never the frozen reading"). The frozen path uses the revision's
committer time (line 75); an author who commits with `GIT_COMMITTER_DATE` in the future widens the same
window — **[INFERENCE]**, not executed (no commits are permitted in this lane). f17 shows the gate's
receipt/table cross-check (`receipt_matches` compares `receipt_date(observed_at)` to the table's
`observed_at`) is the backstop for a naive future-dated receipt: it prints `FAILED observed=31` and the
counter stays at 1 even with a huge ASOF.

### F. Reproduced declared ceilings (f27, f17/f24)

A hand-written op receipt with the 11 exact lines (no `zip_sha256`, no `op_sha256`, no `command`) reads
`measured=1` → `value=2` (f27), exactly as the plan's ceiling says. A self-consistent forged receipt
with the digest written into the gate reads `watched=1` (f24). Neither is a counter defect; both are the
named ceilings, and the live leg is the only check that catches them.

### G. Correct rejections (calibration)

The counter is exact where it is byte-exact: duplicated/trailing-space/FAIL case lines (f11–f13),
symlinked receipts (f14, f19), `### 11.2` under `## 10.` (f15), a wrong title prefix (f18), and a
tampered capture under a clean cwd (f26) all read 0/1 as they should. The gate's own SOURCES parser is
stricter than the counter's `rows()`/clock scan on duplicates and field counts (f5, f6, f8, f9; f4 is
caught by both), so the gate is the backstop for the counter's weaker row parsing — which is precisely
why finding B matters.

## Impacted axes

- **freshness** (the claim's axis): the candidate's own `value=2` is real (BASE 0 → candidate 2, receipt
  inside the commit window, capture digest matches, op receipt exact). Findings A–C do not show the
  landed candidate is false; they show the *counter* can be made to certify a tree that is not what the
  predicate describes. A is a pure entry-conjunct over-score; B and C are gate/interpreter isolation
  defects that survive into the frozen reading when the commit carries the forged bytes.
- **calibration**: the counter's verdict is not reproducible across environments (cwd, `sys.path`,
  `HYAKU_SCRATCH`), and the entry conjunct is not structural. The named ceilings are accurate for the
  receipt/op-receipt classes; they do not name the gate-shadow, cwd-shadow or feed-URL-duplicate classes.

## Smallest safe corrections (one line each)

1. Entry scan: end at every `## `, enter only on the first `## 11.`, skip fences and HTML comments,
   require the heading at column 0 (fixes A).
2. `python3 -I corpus/release-clock.py` for both gate invocations (fixes B; `-I` also drops `PYTHON*`).
3. `python3 -I -` for the counter's heredoc (fixes C).
4. Next predicate: normalize the feed URL before the uniqueness check (fixes D).
5. Optional setup hardening: `mktemp -d` instead of `$HYAKU_SCRATCH/kagi-r54/c1.$$` and verify `$T` is
   empty after `mkdir -p` (the PID path is predictable and `cp -a` merges into a pre-seeded `$T`;
   **[INFERENCE]**, not executed).

## Receipts (exact commands, rc, last line)

- `bash plans/round-54-c1.sh 1a0f43a…` → rc 0, `value=0 watched=0 measured=0 guard=1 …`.
- `bash plans/round-54-c1.sh ede4373…` → rc 0, `value=2 watched=1 measured=1 guard=1 … CLEAN`.
- `C1_ASOF=$(date +%s) bash plans/round-54-c1.sh --tree fx/<id>` for c0, f1–f24, f26–f28 → rc 0 each;
  last lines in the table above (`results.json`, `results2.json` in the scratch root).
- f16 real gate: `python3 corpus/release-clock.py` in `fx/f16_noshadow` → rc 1,
  `RELEASE_CLOCK: FAILED (on_release=32 bound=31 unbound=1 observed=31 fired=13 derived=17)`.
- f23 real selftest: `python3 corpus/release-clock.py --selftest` in `fx/f23_selftest_noshadow` → rc 1,
  `RELEASE_CLOCK_SELFTEST: FAIL version parser declared product prefix: '2.42.0' != '2.42.1'`.
- f25: `cd cwdhash && C1_ASOF=$(date +%s) bash … --tree …/fx/f25_capture_shadow` → rc 0,
  `value=2 watched=1 measured=1 guard=1 … CLEAN`; the same tree from the scratch root (f26) → rc 0,
  `value=1 watched=0 measured=1 guard=1 (bad=watched:capture-sha …)`.
- Harness: `drive.py`, `drive2.py`, `drive3.py` in the scratch root; 31 fixtures under `fx/`; no lane
  file was written outside `.ufo/waves/round-54/build/`.

No host mutation, no package install, no network fetch, no `op` invocation, no secret read. All fixtures
are copies of `ede4373` under the scratch root; the lane was read-only.

SEAT-STATUS: complete
