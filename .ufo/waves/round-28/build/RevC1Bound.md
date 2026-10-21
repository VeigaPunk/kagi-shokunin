# RevC1Bound — C1's component-length bound (freshness axis)

Seat: reviewer (`KagiR28.RevC1Bound-7`). BASE `3553d499577084a6c98d7078906017840bbf7b28`.
All `path:line` citations are BASE lines of `corpus/release-clock.py` / `corpus/SOURCES.md`.
Sandbox (read-only `git archive` of BASE): `.ufo/waves/round-28/sandboxes/RevC1Bound-7/base`.

## Findings (severity order)

### F1 (High) — "CPython's integer-string conversion limit" is not a constant; a 4300 bound does not buy "never a traceback"

The plan treats the limit as the fixed number 4300. It is **runtime-configurable**, with a documented *default* (4300), a documented *lowest configurable* value (640), and it can be switched off. Primary source (opened this round; Python 3.15.1 docs served 2026-10-21, `https://docs.python.org/3/library/stdtypes.html#int-max-str-digits`): "The default limit is 4300 digits as provided in `sys.int_info.default_max_str_digits`." / "The lowest limit that can be configured is 640 digits as provided in `sys.int_info.str_digits_check_threshold`." / `PYTHONINTMAXSTRDIGITS=0` "disable[s] the limitation"; `-X int_max_str_digits=640` sets it. Commands (host CPython 3.14.8; exits as shown):

    python3 -I -B -c "import sys; print(sys.int_info.default_max_str_digits, sys.int_info.str_digits_check_threshold)"  # exit 0 -> 4300 640
    python3 -I -B -X int_max_str_digits=640 -c "int('1'*1000)"    # exit 1 -> ValueError: Exceeds the limit (640 digits) ... value has 1000 digits
    PYTHONINTMAXSTRDIGITS=640 python3 -c "int('1'*1000)"          # exit 1 -> ValueError: Exceeds the limit (640 digits) ...
    python3 -I -B -X int_max_str_digits=0 -c "print(len(str(int('1'*5000))))"  # exit 0 -> 5000 (limit absent)

`-I` implies `-E` (env ignored) but **not** `-X`, so the frozen counting command's isolation does not protect the interpreter. With a 4300 bound a 1000-digit component still raises `ValueError` at `corpus/release-clock.py:380` → traceback → C1's "never a traceback" is false on any host that lowers the limit; a claim calibrated only on default-configured hosts is environment-dependent.

### F2 (High) — Proposed bound: `MAX_VERSION_COMPONENT_DIGITS = 640`, checked on the string before any conversion

- **Crash-proof on every conforming CPython:** 640 is the documented lowest configurable limit, so ≤ 640 digits always converts (verified: `int('1'*640)` OK, `int('1'*641)` raises at 640). 4300 is only the default.
- **Refuses no legitimate release:** the widest legitimate numeric components are calendar/epoch stamps — `YYYYMMDD`=8, `YYYYMMDDHHMMSS`=14, ns-epoch=19, 64-bit epoch=19. 640 is >30× the widest known legitimate component; a 641-digit component can only be a corrupt/hostile token. SemVer sets no length limit, so no specification is violated — but the cap is **lane policy**, and the lesson must say so: the doc grounds the *guarantee* (no conversion can be refused), not version semantics.
- **Frozen fixtures unaffected:** F2/F4 use 4301 digits (> 640 → still refused); control rows have ≤ 4-digit components (still CLEAN).
- **Check order is load-bearing:** the length test must precede any `int()` (`:380`, `:760`), and canonicality must not use `str(int(part)) != part` (it re-raises on an oversize component). Use the string: `part.isdigit() and not (len(part) > 1 and part[0] == "0")` plus `len(part) <= MAX_VERSION_COMPONENT_DIGITS`.
- **Stronger, limit-independent variant (recommended):** compare cores as digit strings (strip leading zeros, compare `(len(c), c)` per component) so no `int()` runs on untrusted length; SemVer §11.2's numeric comparison is satisfied exactly, the crash surface disappears structurally, and 640 becomes a policy floor rather than a crash guard.

### F3 (Medium) — Date-like versioning: unaffected by the bound, but the canonicality rule as worded would refuse a legitimate calendar release

- `20261021.0.0` → 8-digit component → accepted under 640 (and 4300); `numeric_version("20261021.0.0")` → `(20261021, 0, 0)`, orderable, no leading zeros → canonical under SemVer §2. **The proposed bound does not affect date-like versions.**
- But `2026.10.05` (zero-padded day) is refused by the plan's "no leading zero in a multi-digit component" rule — a legitimate calendar-style token. Defensible per SemVer §2 ("MUST NOT contain leading zeroes"), yet the registry row does not license it: `corpus/SOURCES.md:49` (S042) declares scope = "Precedence of strict MAJOR.MINOR.PATCH version cores: numeric, left-to-right comparison", and its teaches cell disclaims SemVer semantics for this lane's vendors ("not asserted to follow SemVer's API semantics, only the numeric core ordering is used"). Citing S042 §2 for a *format* rule on CPython/curl/Vault/OpenBao/SOPS feeds exceeds the row's declared scope → widen S042's scope cell (or open a row for semver.org §2) before the lesson cites it, and record "a zero-padded calendar version yields a typed finding, never a release" as a declared limit.
- Bound the numeric components only; a whole-token bound would be unsourced.

### F4 (Medium) — The crash surface is wider than the plan's example: two `int()` sites, more entry points

`int()` at BASE: `corpus/release-clock.py:380` (`numeric_version`) and `:760` (`parse_latest_version`'s `max()`), reached from `:386` (`is_regression`), `:404` (`feed_floors`), `:577` (`evaluate`), `:760`. Measured on BASE (sandbox, `python3 -I -B corpus/release-clock.py`):

- `observed_version = 3.15.`+4301×`1` (the F2 fixture) → **exit 1** with `Traceback`: `evaluate` → `:567` → `:386` → `:380` `ValueError: Exceeds the limit (4300 digits) ... 4301 digits`.
- `anchored_version = 3.15.`+4301×`1` → **exit 1** with `Traceback`: `:523` → `feed_floors` `:404` → `:380`.

So the cap must cover `anchored_version` and `observed_version` (both TSV cells) and the feed-parsed title (`:760`); the plan's fixture set only exercises `observed_version`.

### F5 (Medium) — The plan's F1 baseline class is not reproducible from the fixture as written

Plan predicate: MISHANDLED = exit 0 + `RELEASE_CLOCK: CLEAN` (or a written fired observation), or output contains `Traceback`; TYPED = exit 1, no traceback, naming a typed finding for the row. Measured at BASE with F1 ("S040 `observed_version=3.15.01`, `verdict=fired`", TSV edit only, default pinned receipt):

    RECEIPT-MISMATCH S040
    RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=29 fired=3 derived=15)   # exit 1

No traceback, no fired observation (`fired` stays 3) → F1 at BASE is **neither MISHANDLED nor TYPED** under the plan's own predicate; the lie is masked by the receipt binding. The stated before-state "MISHANDLED k/4 → 0/4" needs the fixture to also rewrite the pinned receipt `.ufo/waves/round-26/observe-2.json` (`parsed_version`, `verdict`) **and** the pinned digest `DEFAULT_RECEIPT_SHA256` (`corpus/release-clock.py:28`), else F1's before-count is 0/1. Reported, not redefined: the frozen counting command and fixture set are untouched. Same shape for F4 at BASE: the oversize feed item is caught at `:822-823` → `receipt["error"] = "Exceeds the limit (4300 digits) ..."` (free text, not a typed finding), then `evaluate` reports `RECEIPT-MISMATCH S040` → exit 1, no traceback; F4 at BASE already satisfies "exit 1, no traceback", so only the "names a typed finding for the fixture's row/feed" clause fails → the implementation must emit a **dedicated typed category** (e.g. `VERSION-TOKEN-BOUND S040`), not the receipt's free-text error (the receipt's `error` key is outside the selftest's allowed key set, `:1519-1525`).

### F6 (Low) — A policy cap is needed even though the limit can be disabled

`-X int_max_str_digits=0` converts a 5000-digit component fine (exit 0 above), so "beyond CPython's limit" is not a portable predicate: the bound must be a lane-declared policy (640), checked on the string, independent of interpreter state.

### F7 (Low) — `VERSION_RE` (`corpus/release-clock.py:30-33`) is dead at BASE

The only `VERSION_RE` matches are its definition (`:30`), plus `NUMERIC_VERSION_RE` (`:366`) and `TEXT_VERSION_RE` (`:712`). If reused for token extraction: it allows a variable number of components and an optional `[-+]` suffix whose numeric identifiers carry SemVer §9's *own* leading-zero rule — scope canonicality to the numeric core actually compared (`:366`, strict X.Y.Z).

### F8 (Low) — Do not implement canonicality via `int()`

`str(int(part)) != part` detects leading zeros but re-raises `ValueError` on an oversize component: canonicality must be string-based and run after the length test.

## What I did NOT check

- Did not run lane gates/selftests in the lane checkout; all runs were in my sandbox tree (`git archive` of BASE), never in `/home/vgpnk/Projects/shokunin/kagi-shokunin` itself.
- Did not build `.ufo/waves/round-28/tools/c1-measure.py` (absent at BASE): F1–F4 harness behaviour is inferred from the plan text, so F5's "harness must also align the receipt" is a conditional, not an executed result.
- Did not fetch python.org or any live feed; F3/F4 feed behaviour was reproduced with a local synthetic Atom body through the module's own `observe_one` (no network). Did not test PyPy or CPython < 3.10.7 (the limit predates neither); host is CPython 3.14.8 only.
- Did not verify the rest of the round-26 pinned receipt beyond the S040 mismatch; did not measure int()/comparison cost at 640 digits; did not review C2 (derived-anchor binding); did not consult peer seats' reports (no `agent://` traffic).

## Recommendation to L1

Adopt `MAX_VERSION_COMPONENT_DIGITS = 640` as a static, string-checked per-component cap (sourced to the "lowest limit that can be configured is 640 digits" statement of the Python integer-string conversion limit documentation), and implement component ordering on digit strings so the interpreter's configurable limit cannot reintroduce a traceback. State in the lesson that 4300 is only the default, that the cap is lane policy rather than a SemVer rule, that date-like `20261021.0.0` is accepted while zero-padded calendar components are a declared typed-finding limit, that S042's registry scope cell must be widened before §2 is cited, and that the cap must be applied to `anchored_version`, `observed_version` and feed-parsed titles with a dedicated typed category per row/feed.
