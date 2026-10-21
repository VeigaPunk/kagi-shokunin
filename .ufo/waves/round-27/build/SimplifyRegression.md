# SimplifyRegression — round-27 C2 (release-clock regression refusal)

**Agent:** `KagiR26.SimplifyRegression-17`  
**BASE:** `0a47dd189356ea66ec83c3891eed54526e95b89b`  
**Scope:** `corpus/release-clock.py` (read-only analysis; diff sketch only)  
**Milestone:** Round-27 build — knowledge-entry binding (C1) + release-clock regression refusal (C2)

## Godspeed axes (named)

| Axis | This slice |
|------|------------|
| **Correctness** | Numeric downgrade must never read as `fired` or CLEAN `not-fired`. |
| **Freshness (C2)** | Stale/cropped feeds with newest stable &lt; anchor → typed `REGRESSED`, exit1. |
| **Surface (YAGNI)** | One ordering predicate; two enforcement call sites; no parallel compare paths. |
| **Declared limits** | Non–strict `X.Y.Z` anchors keep existing inequality/`norm_version` rule. |
| **Observability** | Observe path must persist downgrade as `verdict: regressed`, not `fired`. |

## Problem at BASE

Round-27 plan C2 (`plans/round-27.md` §C2): `fired` is defined as observed ≠ anchor via string normalization only. When both sides are numeric `X.Y.Z`, an observation **below** the anchor is misclassified as a release event or a valid `not-fired` row.

### Buggy authority (BASE)

**Evaluate — feed rows** (`corpus/release-clock.py:518-530` @ BASE):

```518:530:corpus/release-clock.py
            anchor_ok = is_derived or version_is_named(sources[source_id]["anchor"], anchored)
            if (not anchor_ok or not observed_version or observed_version == "-"
                    or not valid_iso_date(observed_at)
                    or verdict not in ("not-fired", "fired")):
                errors.add(("INCONSISTENT", source_id))
                row_valid = False
            elif verdict == "fired" and norm_version(observed_version) != norm_version(anchored):
                row_fired = True
                row_derived = is_derived
            elif verdict == "not-fired" and norm_version(observed_version) == norm_version(anchored):
                row_derived = is_derived
            else:
                errors.add(("INCONSISTENT", source_id))
                row_valid = False
```

**Observe — feed receipts** (`corpus/release-clock.py:727-734` @ BASE):

```727:734:corpus/release-clock.py
        if clock == "feed":
            parsed_version = parse_latest_version(body)
            receipt["parsed_version"] = parsed_version
            receipt["verdict"] = (
                "not-fired"
                if norm_version(parsed_version) == norm_version(values["anchored_version"])
                else "fired"
            )
```

No `REGRESSED` error category exists at BASE; `passed` can remain true on downgrade lies.

## Smallest correct rule change (YAGNI)

### Single comparison helper

Add **`is_regression(anchored, observed)`** immediately after `norm_version` (≈ `corpus/release-clock.py:362-386` in the integrator sketch).

- **`numeric_version`** + `NUMERIC_VERSION_RE` are parser helpers for strict `X.Y.Z` only; they are not a second comparison policy. Collapsing them into `is_regression` is optional; keeping them separate matches `parse_latest_version`’s existing tuple-max idiom and documents the SemVer §11.2 limit in one place.
- **Do not** add a shared “compare_versions” used by `parse_latest_version` in this change — that would widen scope beyond the regression refusal contract.

Predicate (sketch):

```python
def is_regression(anchored, observed):
    anchor = numeric_version(anchored)
    seen = numeric_version(observed)
    return anchor is not None and seen is not None and seen < anchor
```

### Two call sites (only these are required for C2)

| # | Function | BASE lines | Change |
|---|----------|------------|--------|
| 1 | `evaluate` | `518-530` | Before the `anchor_ok` / `fired`/`not-fired` chain: if `is_regression(anchored, observed_version)` → `errors.add(("REGRESSED", source_id))`, `row_valid = False`. |
| 2 | `observe_one` | `727-734` | After `parse_latest_version`: if `is_regression(...)` → `receipt["verdict"] = "regressed"`; else keep existing `not-fired` / `fired` split. |

No change to `parse_latest_version` (`654-698` @ BASE): it already returns max stable `X.Y.Z`; regression is anchor-relative, not feed-order.

### Concrete counterexamples (BASE → must fail after)

| Case | anchored | observed / parsed | TSV verdict @ BASE | BASE outcome | Required after |
|------|----------|---------------------|--------------------|--------------|----------------|
| Downgrade fired lie | `1.2.3` | `1.2.2` | `fired` | CLEAN, `fired=1` (`524-525`) | `REGRESSED`, `observed=0`, `fired=0` |
| Downgrade un-fire | `1.2.3` | `1.1.9` | `not-fired` | CLEAN (`527-528`: versions differ but verdict is `not-fired`) | `REGRESSED` |
| Live observe downgrade | `1.2.3` | feed max `1.2.2` | (receipt) | `verdict: fired` (`730-733`) | `verdict: regressed` |
| Non-numeric anchor limit | `1.2.x` | `1.0.0` | `fired` | CLEAN, `fired=1` (inequality preserved) | **Still** CLEAN — `numeric_version("1.2.x")` is `None`, `is_regression` false |
| Numeric not lexical | `1.2.3` | `1.10.0` | `fired` | CLEAN, `fired=1` | **Still** CLEAN — `1.10.0` &gt; `1.2.3` numerically |

Counterexample for **wrong** helper: using `norm_version` string inequality instead of tuple order would still accept downgrade `1.2.2` vs `1.2.3` as `fired` (same as BASE). Using lexical string `<` on `"1.10.0"` vs `"1.2.3"` would false-regress; tuple ints avoid that.

## Flagged unnecessary machinery (integrator may defer)

| Addition | Verdict |
|----------|---------|
| Third gate: `receipt.get("verdict") == "regressed"` after `receipt_matches` (working-tree ≈ `587-589`) | **YAGNI for minimal C2.** TSV downgrade is already caught at call site 1; receipt/TSV skew on `regressed` already yields `RECEIPT-MISMATCH` via `receipt_matches` (`377-398` @ BASE). Dual `REGRESSED`+`RECEIPT-MISMATCH` is test taxonomy only. |
| `run_observe` `regressed=%d` summary counter | **Cosmetic** — not part of exit contract. |
| Extending `receipt_matches` to allow `verdict == "regressed"` in TSV | **Out of scope** — TSV remains `not-fired`/`fired` only; downgrade is a receipt observe outcome + evaluate refusal. |
| New comparison helper wired into `parse_latest_version` max key | **Scope creep** — duplicate ordering logic without changing refusal behavior. |
| CLI/subcommand changes | **None needed** — errors surface via existing `evaluate` → `print_result` FAILED path. |

Selftest additions (downgrade rows, `observe_one` downgrade probe) are **acceptance harness**, not runtime machinery; plan expects case growth (`plans/round-27.md` §C2).

## Diff sketch (minimal production delta @ BASE)

```diff
--- a/corpus/release-clock.py
+++ b/corpus/release-clock.py
@@ after norm_version (~362)
+NUMERIC_VERSION_RE = re.compile(r"[0-9]+\.[0-9]+\.[0-9]+")
+def numeric_version(value): ...
+def is_regression(anchored, observed): ...

@@ evaluate feed (~518)
-            if (not anchor_ok or ...
+            if is_regression(anchored, observed_version):
+                errors.add(("REGRESSED", source_id))
+                row_valid = False
+            elif (not anchor_ok or ...

@@ observe_one feed (~730)
-            receipt["verdict"] = ("not-fired" if norm ... else "fired")
+            if is_regression(values["anchored_version"], parsed_version):
+                receipt["verdict"] = "regressed"
+            elif norm_version(parsed_version) == norm_version(values["anchored_version"]):
+                receipt["verdict"] = "not-fired"
+            else:
+                receipt["verdict"] = "fired"
```

(Omit third receipt-verdict block and observe summary counter for strict YAGNI; add selftests separately per plan.)

## Preserved contract

- `norm_version` equality for match / mismatch when `is_regression` is false.
- Non-numeric anchors (`1.2.x`, prerelease suffixes): no numeric ordering; existing `fired`/`not-fired` rules unchanged.
- Rendered-quote clock path untouched.
- `REGRESSED` participates in `errors` like other categories → `passed` false → non-zero exit via existing driver (not re-verified here).

## Evidence method

- Read `plans/round-27.md` §C2.
- `git show 0a47dd:corpus/release-clock.py` for BASE lines cited above.
- Compared to uncommitted working-tree diff (integrator draft); **production tree was not edited by this agent.**

## What was NOT checked (not passes)

- Did **not** run `corpus/release-clock.py --selftest` or any gate script.
- Did **not** execute live `--observe` against feeds.
- Did **not** read `corpus/claim-ledger.tsv` pins or version-precedence TSV rows opened this round.
- Did **not** use LSP `references` on helpers (grep/`git show` only).
- Did **not** verify exit code wiring from `main` on `REGRESSED` (inferred from `passed` / existing error print path).
- **Godspeed skill** at `skill://godspeed` / `~/.omp/skills/godspeed/SKILL.md`: file not found; axes named inline per assignment prompt.

## Tooling

No installs or updates this session.
