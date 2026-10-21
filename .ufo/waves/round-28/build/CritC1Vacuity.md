# CritC1Vacuity — is C1 a real freshness move, and can it be passed while a parse site stays open?

Author: KagiR28.CritC1Vacuity-7 (critic; lane-authored advice, not closure). BASE `3553d499577084a6c98d7078906017840bbf7b28`
(sandbox `.ufo/waves/round-28/sandboxes/CritC1Vacuity/base`, made with `git archive`). Plan lines are cited at claims commit `bdf90f58`.
Axes impacted: **freshness** (C1's claim), **calibration** (the derived-anchor interaction with C2).

## Verdict
C1 is **hardening, not a freshness gain**. No real feed or tag has ever produced the input it guards against (finding 1).
Its four frozen fixtures can all be passed by patches that leave token sites open. I built and ran three such patches (findings 3–5).
One fixture, F4, already reads as TYPED at BASE (finding 2). Keep the claim at "9 → 9 hardening", but the after-state proves less than the claim's own text says (plan L20–23: "anchor, table observation or feed entry").

## Findings (ordered by severity)

1. **No real-world trigger has ever existed, so C1 adds no freshness signal.**
   - `git ls-remote --tags --refs` across five repositories returned 1,656 tags, 789 of them shaped like `[v]X.Y.Z` (or curl's `curl-X_Y_Z`): python/cpython 680/270, getsops/sops 49/45, hashicorp/vault 489/246, openbao/openbao 218/30, curl/curl 220/198.
   - **0** of those tags have a leading-zero component. The longest component is **2 digits**. The digits-after-zero pattern `(?<![0-9])0[0-9]` matches 0 tags.
   - Live public feeds fetched today (four Atom/RSS feeds with 10 entries each, plus curl.se/info `Version: 8.23.0`) contain 0 leading-zero titles.
   - Every real receipt the lane retained is canonical: `.ufo/waves/round-25/observe-1.json` and `round-26/observe-{1,2}.json`. Every `3.15.01` found under `.ufo/` is a round-28 sandbox fixture.
   - So C1 only turns typo'd or hostile input into typed findings. It never makes a real release get detected sooner or more correctly.

2. **F4 is vacuous: BASE already handles it the way the predicate calls TYPED.**
   - At BASE, the oversize feed path does not produce a traceback. The `max` key `int()` call at `corpus/release-clock.py:760` raises ValueError inside `observe_one`'s `try`, and `except (OSError, ValueError)` at `:822` catches it and writes `error="Exceeds the limit (4300 digits)…"`.
   - BASE-F4 measured: exit 1, no traceback, `RECEIPT-MISMATCH S027 S028 S040 S041`. That meets plan L40–41 ("exits 1, prints no traceback and names a typed finding for the fixture's row/feed").
   - So the BASE result is MISHANDLED 3/4 (F1 CLEAN fired=4, F2 Traceback, F3 writes 4 fired observations) and TYPED 1/4, not 0/4.
   - The plan's premise "raises an untyped ValueError traceback" (L19–20) holds only for the table path (`:380` reached from `:567`), not for the feed path.
   - The predicate accepts any existing category (RECEIPT-MISMATCH, REGRESSED, INCONSISTENT) as "typed". It cannot tell "non-canonical token reported" apart from "an unrelated rule happened to fire".

3. **Fixture-passing but incomplete patch P1** (guards the table `observed_version` plus only the *returned* feed maximum; anchors untouched):
   - Passes F1–F4: NONCANONICAL S040 ×2, RECEIPT-MISMATCH ×2. The control stays CLEAN30.
   - It leaves an **oversize anchor** that still tracebacks. `feed_floors` calls `numeric_version` on every feed anchor at `:404/:408`, from `evaluate` `:523`, before any per-row check. Case S041 `anchored_version=3.15.`+4301×`1`: exit 1, Traceback (same at BASE).
   - It leaves a **leading-zero derived anchor** that still fires. Derived rows skip `version_is_named` (`:565–566`, `anchor_ok = is_derived or …`). Case S014 `anchored=2.7.01 observed=2.7.1 verdict=fired` with a mirrored receipt gives **CLEAN fired=4 exit 0**.
   - That second hole stays open under every patch I drafted (P1–P4). No frozen fixture puts a non-canonical token into `anchored_version`, although L20 names anchors. This is the **smallest fixture-passing incomplete patch**.

4. **Patch P2 drops non-canonical tokens silently and passes, or fails, depending on how F3/F4 are built.**
   - P2 makes `numeric_version` return None for non-canonical tokens and filters them out of `stable` in `parse_latest_version`.
   - **"Replace" construction** (the 3.15.1 item retitled 3.15.01): the parser falls back to 3.15.0 and reports `REGRESSED S040 S041`, exit 1. The literal predicate counts that as TYPED, but the category is false: there was no regression, only a bad token.
   - **"Prepend" construction** (3.15.01 added, 3.15.1 kept): `RELEASE_CLOCK: CLEAN`, exit 0, so MISHANDLED.
   - Plan L34–35 ("newest stable item is titled `Python 3.15.01`") does not say which construction is meant. The same patch scores 4/4 or 2/4 depending on how `c1-measure.py` is written. `.ufo/waves/round-28/tools/` was empty when I checked.
   - With a real Atom entry, P2 is also silent. GitHub puts `<link>` before `<title>` (live openbao feed: href `releases/tag/v2.7.1`, then title `v2.7.1`). A tag rewritten to `v2.7.01` is dropped and gives CLEAN with no finding, although L23 requires "the feed gets a typed finding".

5. **Patch P4 bounds by catching int()'s ValueError, so the bound depends on the environment.**
   - P4 (catch ValueError in `numeric_version` plus a check on the returned token) passes F1–F4 under the frozen `python3 -I -B` command.
   - The ledger rows invoke the clock without `-I`: `corpus/claim-ledger.tsv:82-83`, `python3 corpus/release-clock.py`. `claim-ledger.sh:595` runs them via `bash -o pipefail -c "$cmd"` and inherits the caller's environment.
   - Case F2 with `PYTHONINTMAXSTRDIGITS=0` and no `-I` gives **CLEAN fired=4 exit 0** under P4 (and under BASE and P3).
   - The bound must be a lane constant on string length checked *before* `int()`, not `sys.get_int_max_str_digits()`.

6. **F1's threat model is already open through a canonical lie, so C1 closes nothing for a forger.**
   - Under the default receipt, F1 is already `RECEIPT-MISMATCH` (the plan correction at L93–97 admits this). F1 is mishandled only when the same actor edits the table and also supplies `--receipt` plus its sha256.
   - That actor can write the canonical `observed_version=3.15.2 verdict=fired` instead. Measured: **CLEAN fired=4 exit 0** at BASE and under every patch P1–P4.
   - F1/F2 guard honest typos only, which is useful but cosmetic for integrity.

7. **Leftovers and tradeoffs.**
   - `VERSION_RE` (`:30-33`, permissive `[0-9]+`) has no use site. `rg -nP '(?<![A-Z_])VERSION_RE'` finds only `:30`. Editing it would be pure cosmetics; deleting it is in scope as dead weight.
   - A 4300-digit component (the CPython limit minus 0) is accepted as fired under every patch (CX-4300digits gives CLEAN fired=4). "Bounded" (L23) has no stated bound; this is a tradeoff to state, not a defect.
   - PyPA integer normalization treats `3.15.01` as equal to `3.15.1` for the python.org feed (S036/S039). Typing it fail-closed is defensible but should be named. [INFERENCE: from memory of PEP 440; I did not fetch it. Peer SrcPep440IntNorm-7 owns this.]
   - The MISHANDLED clause "a written fired observation" (L39) has no scope. S027/S028 on the same python.org feed are legitimately fired at the control (fired=3). An unscoped reading fails every correct patch that still observes 3.15.1, so it forces a feed-wide-error design.

## Sites a complete C1 must cover (BASE)
- **Integer conversions:** `:380` (reached from `:385-386`, `:404`, `:408`, `:577`) and `:760` (the `max` key over **every** stable entry, not only the winner).
- **String equality:** `:444` (receipt `parsed_version`), `:582`, `:585`, `:798`.
- **Derived-anchor bypass:** `:565-566`. This must be closed in C1 itself; relying on C2 to catch it incidentally breaks claim separability (Boundaries L81–83).

## Smallest safe correction
- Add one `canonical_token()` check: ASCII `(0|[1-9][0-9]{0,K-1})` ×3 with an optional `v`, where K is a fixed constant checked by string length.
- Apply it to `anchored_version` (inside `feed_floors` and before `:567`), `observed_version`, receipt `parsed_version`, and every entry collected at `:747-757`.
- Emit one new category, e.g. `NONCANONICAL <row>`, with a feed-level error for observe. Never filter tokens silently.
- Add selftest cases for a derived leading-zero anchor, an oversize anchor, a prepend-style feed, an Atom tag-only token, and `PYTHONINTMAXSTRDIGITS=0`.
- Report the predicate ambiguities above as findings. Do not redefine the frozen predicate.

## Commands run (sandbox only; lane checkout not executed)
| command | exit |
|---|---|
| `git -C <lane> archive 3553d49… \| tar -x -C …/base` | 0 |
| `python3 -I -B corpus/release-clock.py` (in sandbox/base) → CLEAN30, fired=3, derived=15 | 0 |
| `git ls-remote --tags --refs https://github.com/{python/cpython,getsops/sops,hashicorp/vault,openbao/openbao,curl/curl}.git` (`GIT_CONFIG_GLOBAL=/dev/null`) | 0 ×5 |
| tag scan script (`python3 -I -B -`) | 0 |
| `curl -sS -q` of 4 live feeds plus curl.se/info; title scan | 0 |
| `python3 -I -B probe.py`: 15 cases × {BASE, P1, P2, P3}; `probe-results.json` | 0 |
| `python3 -B -E -s p4.py`: P4 × 15 cases plus BASE F3/F4 full output | 0 |
| `rg` searches over the corpus and `.ufo/waves` receipts | 0 |

The probe, patches and raw results are in `.ufo/waves/round-28/sandboxes/CritC1Vacuity/` (`probe.py`, `p4.py`, `probe-results.json`, `tags-*.txt`, `feed-*`).
Observe fixtures were emulated in-process: `request_body` was stubbed to serve the edited live python.org (or openbao) feed, other rows were copied from the default receipt, and `utc_timestamp` was pinned to 2026-10-21. The exact F3/F4 numbers therefore depend on my construction, not on the unwritten `c1-measure.py`.

## Not checked
- The real `c1-measure.py`, which did not exist yet, and how it builds F3/F4 or scopes "written fired".
- GitHub Releases *titles* across history; I scanned only tags and today's 10 newest entries per feed.
- The history of python.org RSS titles.
- Whether GitHub caps tag-name length (relevant to a hostile 4301-digit tag) [INFERENCE: unknown].
- The PEP 440 and SemVer texts.
- Every tied consumer other than `release-clock.py`: `self-counts.py` and `claim-ledger.sh` only pin its output.
- I installed no tools; no pacman transactions and no host-private reads.
