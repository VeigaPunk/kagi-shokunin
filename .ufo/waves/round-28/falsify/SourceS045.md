# KagiR28.SourceS045 — S045 (SemVer 2.0.0 §2) row reopen (round 28)

**Verdict: PASS.** I re-fetched `https://semver.org/spec/v2.0.0.html` under the declared profile and reproduced every declared field of the S045 capture row: HTTP 200, same final URL, raw sha256/bytes, rendered-text-v1 normalized sha256, row-identity sha256, quote 23 words located **once**, and the quoted sentence is the 2nd item of the page's spec list. The teaches claim about the clock is code-true. **No scope overclaim found**; the two observations in §5 are under-claims. Writes: this report + `.ufo/waves/round-28/sandboxes/SourceS045/`. No production edit, no lane gate/selftest in the lane, no host-private read.

Target `…/kagi-shokunin` @ `62a33b1bd15217ed729df2ca40c8a30aba3076c0`; `git diff --stat 62a33b1b… -- corpus/` is empty, so the worktree `corpus/` is the candidate blob set; line numbers below are candidate path:line.

## 1. Row under attack

`corpus/SOURCES.md:52` — `S045 | Semantic Versioning 2.0.0, normal version form — https://semver.org/spec/v2.0.0.html | spec | A | Canonical form of a strict X.Y.Z version core: non-negative integers without leading zeroes; S042's §11.2 precedence scope is unchanged | … item 2 (#semantic-versioning-specification-semver); … as served, fetched 2026-10-21 | A core component with a leading zero (`3.15.01`) is not a SemVer normal version, so the round-28 release clock types it NON-CANONICAL instead of ordering, comparing or firing it; vendors are not asserted to follow SemVer beyond this token form. Quote: “A normal version number MUST take the form X.Y.Z … zeroes.” (item 2). | mined | 2026-10-21 | 180d | corpus/lessons/round-28.md |`

Capture `corpus/source-fetches.tsv:88` (16 columns); Gate row `corpus/lessons/round-28.md:32`; lesson `source:` lists S045 (`:1`). S045 is an **added** line in `git diff 3553d499… 62a33b1b… -- corpus/SOURCES.md`; S042 is context (unchanged).

**Status/eligibility/draft:** `mined` (registry = capture) / tier A `spec`, opened 2026-10-21, recheck 180d / **no draft qualifier** — page title “Semantic Versioning 2.0.0”, `grep -ic draft` on the body = 0, final published spec; the “as served” qualifier covers the undated, version-pinned route.

## 2. Reopen — commands and exits

```
cd …/.ufo/waves/round-28/sandboxes/SourceS045
curl -fsSL --compressed -A 'kagi-shokunin-round23/1.0 (documentation verification)' \
  -o s045.body -w 'http=%{http_code} final=%{url_effective} transfer=%{size_download}\n' \
  https://semver.org/spec/v2.0.0.html
  → http=200 final=https://semver.org/spec/v2.0.0.html transfer=9108       exit 0
sha256sum s045.body   → f9d4b8b1a5e9a0de6621dbbc70d69fdf05310b7a737509317b94a7bddfb9409e  exit 0
wc -c < s045.body     → 31121                                             exit 0
```

Run twice more (`s045.body2`, `s045.third`, exits 0): same sha256; `cmp -s` exit 0. Transfer 9108 B vs decoded 31121 B is curl's wire/decoded split; the row's `bytes` is the decoded body, the domain its `representation` header declares.

## 3. Capture identity, sha and bytes

| field (`source-fetches.tsv:88`) | row | recomputation | match |
|---|---|---|---|
| row_identity_sha256 | `7819f798…8b7d` | sha256(`S045\tmined\thttps://semver.org/spec/v2.0.0.html\n`) = same | yes |
| final_url / http_status | registered URL / `200` | same / 200 | yes |
| sha256 (decoded body) | `f9d4b8b1…9409e` | `f9d4b8b1…9409e` | yes |
| bytes | `31121` | 31121 | yes |
| representation | `decoded-http-body-volatile-v1` | decoded body; class see §5 O1 | domain ok |
| normalization / norm sha | `rendered-text-v1` / `5e0f0d9a…4b3a` | `corpus/rendered-text-v1.py:70` → `5e0f0d9a…4b3a`, 17175 B | yes |
| fetched / revision | `2026-10-21` / `-` | today; not a raw/main moving ref | ok |
| location | `… item 2 (#semantic-versioning-specification-semver)` | id present; item 2 = 2nd `<li>` | yes |

All commands exit 0: `python3 -I -B corpus/rendered-text-v1.py digest …/s045.body` → `raw_sha256=f9d4b8b1… bytes=31121 normalized_sha256=5e0f0d9a…`; an **independent** re-implementation of the declared steps (script/style strip, tags→space, `html.unescape`, Unicode `\s+`→space, trim, UTF-8) returns the same `5e0f0d9a…`, so the digest is not the module agreeing with itself. `… locate … '<quote>'` → `count=1`, exit 0.

## 4. Page checks (source / scope / anchor / teaches)

- **Quote/Gate.** TSV quote byte-identical to the SOURCES teaches quote; `awk` extract of TSV `$13 | wc -w` → **23**, exit 0 (≤25). Raw-literal presence in the body is **False** (spans `X, Y, and Z are\nnon-negative integers`), so declared `rendered-text-v1` is required and correct; `raw-literal-v1` would have been wrong.
- **Item 2.** Normalizing the 2nd `<li>` of the `<ol>` after `id="semantic-versioning-specification-semver"` (`s045.body:431`) yields exactly “A normal version number MUST take the form X.Y.Z where X, Y, and Z are non-negative integers, and MUST NOT contain leading zeroes. X is the major version, … 1.11.0.” — the quote is its first sentence and occurs once on the page. FAQ regex `(0|[1-9]\d*)` per core component corroborates the leading-zero reading.
- **S042 clause.** True: S042 is untouched in the round diff, and its quote “Major, minor, and patch versions are always compared numerically.” locates in the precedence list's 2nd item (11.2). S045's quote is item 2, so the same-URL rows do not double-count a clause.
- **Teaches → clock.** `corpus/release-clock.py:617` computes `non_canonical_version(anchored) or …(observed)`; `:627-631` adds `("NON-CANONICAL", source_id)` with `row_valid=False` in the `if non_canonical:` branch **before** the `is_regression`/verdict branch → never ordered, compared or fired. Direct call on the candidate: `non_canonical_version('3.15.01')` → True, `numeric_version('3.15.01')` → None; `'3.15.1'` → False with an order tuple (exit 0).

## 5. Overclaim audit — nothing to escalate

The scope says only what item 2 says and bounds itself: no SemVer length rule (the 18-digit cap is the lane's constant, `lessons/round-28.md:57`), no vendor conformance (“vendors are not asserted…”), no widening of S042. **O1 (under-claim):** `decoded-http-body-volatile-v1` is not evidenced for this URL — three GETs are byte-identical and equal S042's same-day capture (`source-fetches.tsv:85`, same `f9d4b8b1…`, 31121 B), and no per-response token pattern appears; the lesson discloses the class was inherited (“recorded the same way as S042/S043”; only NIST varied) and the census accepts both classes. **O2 (declared):** S045 duplicates S042's URL → fleet `W04`; the lesson records “one more W04 by design” (`lessons/round-28.md:32`), and the START census predates S045, so the END census is where it must appear.

## 6. What I did NOT check

- Did not run `sources-census.sh`, `c1-measure.py`, `c2-measure.py`, or the clock selftest (lane gates out of scope); SC_FETCH conformance argued from values, not a gate exit.
- Did not re-verify S042's quote beyond its 11.2 location, nor any other registry row.
- Did not check END census, claim-ledger pins, stamps, or the fleet census wrapper.
- Two/three GETs span minutes of one day: daily-chrome volatility is unobservable, so O1 means “not evidenced in this window”, not “non-volatile”.

## Concrete counterexample

None. Strongest attempts: (a) raw-literal quote absent (line break) — not a defect, the row declares `rendered-text-v1`, which locates it once (exit 0); (b) the teaches' clock claim — refuted by direct predicate call (`3.15.01` non-canonical, no order, `NON-CANONICAL` at `corpus/release-clock.py:627-631`); (c) a scope overclaim — none; every extra clause either bounds the source or is code-true.
