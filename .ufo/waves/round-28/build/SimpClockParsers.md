# SimpClockParsers — canonical X.Y.Z parser map (Round 28 BUILD)

Agent: `KagiR28.SimpClockParsers-7` · BASE `3553d499577084a6c98d7078906017840bbf7b28` · Target: `corpus/release-clock.py`

## Gods speed axes (this slice)

| Axis | Move kept if… |
|------|----------------|
| **Freshness (C1)** | Non-canonical / oversize tokens → typed finding; never false `fired`, never `Traceback` |
| **Calibration (C2)** | Same canonical string used for derived-row anchor checks (no second equality rule) |
| **Duplication** | One regex + one parse function; delete dead `VERSION_RE` |
| **Ordering (QM25/S042)** | Single int-tuple source for `<` / `max()` |
| **YAGNI** | No new types/exceptions beyond one parser + optional thin wrappers |

## Findings (BASE path:line)

### Five version-shaped regexes (four active + one dead)

| Line | Name | Pattern role |
|------|------|----------------|
| `corpus/release-clock.py:30-33` | `VERSION_RE` | Broad SemVer-like capture — **never referenced** in file (dead authority) |
| `corpus/release-clock.py:366` | `NUMERIC_VERSION_RE` | `fullmatch` gate for `numeric_version` |
| `corpus/release-clock.py:710` | `STABLE_TITLE_RE` | Atom/RSS title → capture `X.Y.Z` |
| `corpus/release-clock.py:711` | `STABLE_TAG_HREF_RE` | GitHub tag href → capture `X.Y.Z` |
| `corpus/release-clock.py:712` | `TEXT_VERSION_RE` | curl-style `Version:` line → capture `X.Y.Z` |

All four active patterns use permissive `[0-9]+\.[0-9]+\.[0-9]+` (accepts leading-zero components and unbounded digit runs).

### Ad-hoc int tuples (duplicate ordering core)

- `corpus/release-clock.py:380` — `tuple(int(part) for part in value.split("."))` inside `numeric_version`
- `corpus/release-clock.py:760` — same lambda in `parse_latest_version` `max(stable, …)`

### Related but out of scope for “one parser”

- `corpus/release-clock.py:341-346` — `version_is_named`: substring match with `re.escape`, not full-token parse (C2 anchor-in-SOURCES check).
- `corpus/release-clock.py:362-363` — `norm_version`: strips optional `v` only; **not** canonicalization (C1 gap).
- `corpus/release-clock.py:171` — hostname/path heuristic `split(".")`; not release tokens.

### Concrete counterexamples (executed on BASE definitions)

Commands (all exit 0):

```text
git -C …/kagi-shokunin show 3553d499…:corpus/release-clock.py | wc -l     → 1758
git -C …/kagi-shokunin diff 3553d499… -- corpus/release-clock.py | wc -l  → 0
python3 -c '… exec BASE module … numeric_version/norm_version/parse_latest_version …'
```

| Input | Behavior | Why it matters for C1 |
|-------|----------|------------------------|
| `numeric_version("3.15.01")` → `(3, 15, 1)` | Accepts leading-zero segment | Numeric path treats as equal to `3.15.1` |
| `norm_version("3.15.01") != norm_version("3.15.1")` → `True` | String inequality | `corpus/release-clock.py:582` treats as **fired** when anchor is `3.15.1` and observed is `3.15.01` |
| `numeric_version("3.15." + "1"*4301)` | `ValueError` (4301-digit limit) | Untyped crash, not exit-1 finding |
| `parse_latest_version(<Atom title "Python 3.15.01">)` → `"3.15.01"` | Feed emits non-canonical token | F3 fixture path propagates lie into observations |

## Proposed minimal canonical parser (C1)

**One shared token pattern** (SemVer S042 §2: no leading zeros on multi-digit numeric identifiers; bound digit count before `int()` per CPython int-string limit, registry row opened this round):

```python
_XYZ_PART = r"(?:0|[1-9][0-9]{0,4299})"  # 4299 digits + optional leading 1–9 → ≤4300 digits
CANONICAL_XYZ_RE = re.compile(
    rf"^v?({_XYZ_PART}\.{_XYZ_PART}\.{_XYZ_PART})$",
    re.IGNORECASE,
)

def parse_canonical_xyz(value):
    """Return (canonical_str, (major, minor, patch)) or None.

    canonical_str is always M.m.p without v-prefix. None if missing, not strict
    X.Y.Z, non-canonical (e.g. 3.15.01), or oversize — never raises ValueError.
    """
```

**YAGNI wrappers** (reuse one body, delete duplicate logic):

- `numeric_version(value)` → `parse_canonical_xyz(value)[1] if … else None` (keep name for QM25 call sites).
- Equality sites today using `norm_version(a) == norm_version(b)` → compare `parse_canonical_xyz(a)[0]` (or helper `canonical_xyz_string(value)` returning `str | None`).

**Feed regexes (710–712):** replace repeated `[0-9]+\.[0-9]+\.[0-9]+` with the same `_XYZ_PART` triple (or capture then `parse_canonical_xyz` on group 1). **`parse_latest_version:760`:** `max(stable, key=lambda v: parse_canonical_xyz(v)[1])` with prior filter dropping `None`.

**Deletion candidate:** `VERSION_RE` at `corpus/release-clock.py:30-33` — zero references at BASE (text `rg VERSION_RE` on archived file → definition only).

## Call-site list (BASE line numbers)

| Line(s) | Current | After C1 |
|---------|---------|----------|
| 30–33 | `VERSION_RE` | **delete** |
| 362–363 | `norm_version` | keep for v-strip **or** fold into parser; fired/equality must not use v-strip alone |
| 366–380 | `NUMERIC_VERSION_RE` + tuple split | **delete** regex; body → `parse_canonical_xyz` |
| 385–386, 404, 408 | `numeric_version(...)` | unchanged names → delegate |
| 444 | `norm_version` equality (receipt) | canonical string compare |
| 577 | `numeric_version(...) is None` | `parse_canonical_xyz(...) is None` (or delegate) |
| 582, 585 | `norm_version` fired/not-fired | canonical string compare |
| 710–712 | three feed regexes | shared `_XYZ_PART` or post-capture `parse_canonical_xyz` |
| 727–757 | regex captures → `stable.append` | append only if `parse_canonical_xyz` succeeds |
| 760 | ad-hoc `int` tuple | `parse_canonical_xyz(v)[1]` |
| 794–798 | `is_regression` + `norm_version` | regression via delegate; equality via canonical string |

**Selftest / observe** (`789`, `1171+`, `1400+`): indirect via `parse_latest_version` / `numeric_version`; no separate parser fork.

Typed-finding emission (exit 1, no traceback) belongs in **row/feed validators** above this parser; parser stays pure `None`-on-reject (YAGNI).

## Diff size estimate (integrator, production patch only)

| Area | Δ lines (approx.) |
|------|-------------------|
| Add `CANONICAL_XYZ_RE` + `parse_canonical_xyz` | +28–38 |
| Remove `VERSION_RE`, `NUMERIC_VERSION_RE`; shrink `numeric_version` | −12–18 |
| Rewire 3 feed regexes + `parse_latest_version` loop/max | ±15–22 |
| Replace 5 `norm_version` equality / validity uses | ±8–12 |
| C1 selftest + finding strings (round-28 plan) | +25–45 (outside pure dedupe) |
| **Net (dedupe + C1 hook, excl. selftest)** | **~45–75 lines touched, +15–35 net** |

## Preserved contract

- Non-numeric anchors (`v1.21.x`, two-component) still `None` from parser → existing REGRESSED / INCONSISTENT paths unchanged.
- `parse_latest_version` still rejects DTD/ENTITY (`731–732`); only **stable token acceptance** tightens.
- `version_is_named` unchanged unless L1 later requires canonical anchor strings for C2.

## Tool installs

None (used system `python3` 3.14.8, `git`, `rg`).

## What I did NOT check

- `python3 -I -B .ufo/waves/round-28/tools/c1-measure.py` or frozen F1–F4 fixtures (tools may not exist yet).
- Full `RELEASE_CLOCK_SELFTEST` run on lane checkout (executor isolation rule).
- C2 derived-anchor binding logic vs `SOURCES.md` anchors.
- LSP `references` on `VERSION_RE` (grep-only proof of zero use).
- Whether integrator will add a separate “finding reason” enum vs reusing `INCONSISTENT` for non-canonical tokens.

Report: `.ufo/waves/round-28/build/SimpClockParsers.md`
