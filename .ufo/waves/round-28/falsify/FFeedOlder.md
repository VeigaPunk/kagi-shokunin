# FFeedOlder — round-28 C1 falsification: non-canonical feed entry that orders BELOW the newest canonical entry

**Verdict: FAIL (against the frozen plan's C1 sentence), scope-limited to one input class.**
The candidate silently ignores such an entry (no typed finding, exit 0) and **writes a fired
release verdict** — the behaviour `plans/round-28.md:20-24` forbids ("a version token used
for … a feed entry must be canonical … otherwise the row or feed gets a typed finding
(exit 1), **never a release event** and never a traceback"). The lane's own lesson narrows
the rule (`corpus/lessons/round-28.md:63-64`) and the candidate's selftest asserts that
narrowing, so it is a deliberate design the frozen plan text does not carry: the L1 must
append a plan correction or change the candidate. No traceback, no wrong release identity
and no mis-typed category was found elsewhere in this carrier.

## Method (isolated, offline, no network)
- Trees: `git archive 62a33b1 | tar -x -C /fast/scratch/hyaku/kagi-r28/FFeedOlder/cand` (exit 0) and the same for BASE `3553d49` → `.../base` (exit 0). Lane checkout untouched.
- Harness (mine; no lane tool reused): `.ufo/waves/round-28/sandboxes/FFeedOlder/probe.py`. Each case is a child `python3 -I -B` of the tree's **own** `corpus/release-clock.py` with `module.request_body` stubbed to serve a local fixture Atom feed and `module.utc_timestamp` pinned (the substitution the script's selftest uses — the same one the lane's frozen `c1-measure.py` uses, `corpus/lessons/round-28.md:105`). `python3 -I -B probe.py <cand> <base> out` → exit 0; per-case child exits below.
- Fixture corpus: `corpus/SOURCES.md` narrowed to rows S039+S040 (verbatim), `corpus/release-clocks.tsv` narrowed to the S040 row (header + one row), module copied from the tree under test. Table edits are mirrored into the receipt as the plan correction requires, so no generic `RECEIPT-MISMATCH` is mistaken for the rule.
- Also run: `unit_probe.py` (377 token sets, int-free value order); `python3 -I -B corpus/release-clock.py --selftest` → `RELEASE_CLOCK_SELFTEST: PASS (106 cases)` exit 0.

## F1 (HIGH, claim text) — older non-canonical feed entry ignored, fired verdict written
Candidate code: `corpus/release-clock.py:784-798` `newest_stable()`; the ignore test is
`:795-796` (`if any(version_order(token) >= version_order(newest) for token in tokens if
non_canonical_version(token))`), documented at `:786-789` ("a non-canonical token … that orders
below the newest canonical token cannot be the newest release **and is ignored**").
Counterexample (fixture A): feed entries `Python 3.15.2` (canonical newest) and
`Python 3.14.01` (non-canonical, value strictly older); table row S040 anchored `3.15.1`,
observed `3.15.2`, verdict `fired` (a legitimate 3.15.2 release).

    cand: exit=0
      RELEASE_CLOCK_OBSERVE: wrote 1 observations (failed=0 fired=1 regressed=0)
      RELEASE_CLOCK: CLEAN (on_release=1 bound=1 unbound=0 observed=1 fired=1 derived=0)
      receipt| id=S040 verdict=fired parsed=3.15.2 error=None     TRACEBACK_PRESENT=no

→ no typed category at all, no traceback, and a release event (`verdict=fired`) written for a
feed that carried a non-canonical version token; the frozen plan demands a typed finding and
"never a release event" for that input. The candidate's selftest asserts this behaviour
(`corpus/release-clock.py:1382-1388`, "older oversize entry was not ignored"); the lesson
states the same narrowing (`corpus/lessons/round-28.md:63-64`). The frozen fixture set cannot
see it: F3/F4 make the malformed token the newest/only entry (`plans/round-28.md:34-36`).

## Controls (same harness, candidate tree) — the rule is real everywhere else
| case | input | exit | stdout category | fired verdict written? |
|---|---|---|---|---|
| A | older non-canonical entry `3.14.01` | 0 | none (CLEAN, fired=1) | **yes (violation)** |
| B | malformed token at the newest value `3.15.02` | 1 | `NON-CANONICAL S040` (feed newest stable entry) | no |
| C | malformed token as only entry `3.15.02` | 1 | `NON-CANONICAL S040` (feed has no canonical stable X.Y.Z entry) | no |
| D | clean feed `3.15.2` | 0 | CLEAN, fired=1 | yes (legitimate) |
| E | over-bound component in feed (4301 digits) | 1 | `NON-CANONICAL S040` | no |
| F | non-canonical token in the **table** row (`3.15.02`), receipt mirrored | 1 | exactly `NON-CANONICAL S040`, **no** `RECEIPT-MISMATCH` | no |
| G | over-bound component in the **table** row, receipt mirrored | 1 | exactly `NON-CANONICAL S040`, no traceback | no |
| Z | frozen default command, unmodified candidate tree | 0 | `RELEASE_CLOCK: CLEAN (on_release=30 bound=30 unbound=0 observed=30 fired=3 derived=15)` | n/a |

F and G are the "exact typed category" proof: with the receipt mirrored the only finding is
`NON-CANONICAL` (`corpus/release-clock.py:617-632` rows; `:679-681` a receipt error carrying
`NON_CANONICAL_PREFIX`), so a generic receipt mismatch is **not** what carries the rule.
Z reproduces the plan's stated control at both BASE and candidate.

## BASE comparison (same fixtures, BASE `3553d49`)
| case | BASE result | candidate result |
|---|---|---|
| A | exit 0 CLEAN fired=1 (identical → the older-entry class was never covered; inherited, not a candidate regression) | exit 0 CLEAN fired=1 |
| B | exit 0 CLEAN fired=1 (tie untyped) | exit 1 `NON-CANONICAL` |
| C | exit 1 `RECEIPT-MISMATCH S040` (generic, untyped) | exit 1 `NON-CANONICAL S040` |
| E | exit 1 `RECEIPT-MISMATCH S040`, receipt error = raw int-limit text | exit 1 `NON-CANONICAL S040` |
| F | exit 1 `INCONSISTENT S040` (BASE-era category) | exit 1 `NON-CANONICAL S040` |
| G | exit 1, uncaught `ValueError` **Traceback** at `base/corpus/release-clock.py:380` (`int(part) for part in value.split(".")`) | exit 1 `NON-CANONICAL S040`, no traceback |
| Z | exit 0 CLEAN, same counts | exit 0 CLEAN, same counts |

## Impact (measured, not assumed)
- Unit probe, 377 token multisets (canonical + leading-zero + over-bound, 1–3 tokens): **269 typed** (`ValueError` prefixed `non-canonical version token: `), **108 silently accepted**, **0 wrong newest release** (every accepted answer equals the highest-valued token). The ignore limit changes *whether the feed is typed*, never *which release is named* — no false "fired" identity, no missed newest release.
- Consequence: the lane's clock can report `CLEAN` (and record `fired`) while the observed feed carried a non-canonical release token; round-28's C1 sentence as frozen is false for this input class.
- Corroboration (not my evidence): lane build reviews `.ufo/waves/round-28/build/RevC1Fixtures.md:61` (R4, HIGH) and `.ufo/waves/round-28/build/RevSelftestIsolation.md:61` describe the same ignore limit.

## Recommendation (L1's call, one of two)
1. Append a plan correction narrowing `plans/round-28.md:20-24` to "… or the feed's **newest** stable entry", matching `corpus/lessons/round-28.md:63-64`; or
2. Change `newest_stable()` (`corpus/release-clock.py:795-796`) to refuse *any* non-canonical stable entry (as the published patch seat's rule did) and add a frozen fixture for it.

## Not checked / limits of this attack
- No network: the real `python.org` feed was never fetched; all feed bodies are local fixtures.
- Did not run the lane's frozen `c1-measure.py`/`c2-measure.py`, the lane selftest or any lane gate inside the lane checkout; all runs are in my sandbox or on exported trees.
- Did not audit C2 (derived-anchor binding), the receipt-pin machinery beyond the mirrored fixtures, `rendered-text-v1`, or the other 29 on-release rows.
- The 18-digit component bound and `-X int_max_str_digits` environment sensitivity were not attacked.
- Kept: `probe.py`, `unit_probe.py`, raw output `out/probe-run.txt` under `.ufo/waves/round-28/sandboxes/FFeedOlder/`; the /fast/scratch tree exports were deleted. Tooling: no package installed or upgraded (none needed; Python 3.14.8, git archive only).
