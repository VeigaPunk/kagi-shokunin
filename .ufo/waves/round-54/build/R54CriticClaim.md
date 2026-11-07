# R54CriticClaim — adversarial attack on C1 (framing, reachability, separability, axis, liveness, harm)

Seat: R54CriticClaim (leaf, no dispatch). Lane `kagi-shokunin`, branch `master`.
BASE `1a0f43a9220bb0e995462c2aef745ac0124c3317`; predeclaration `27aa53fd40b0b385b3cf2ffeea49977f9e0ff690`; candidate `ede4373afa07a33e24cbd35e9fd33fc2fddf2f14`.
Scratch: `/fast/scratch/hyaku/kagi-r54/R54CriticClaim/` (BASE tree `base/`, candidate tree `cand/`, attack trees `t2/ t3/ t4/`, op archive `op/`, receipts `*.txt`). Nothing in the lane was written except this file; no host changes, no package operations, no tool installs.

Method: read the frozen plan, counter, controls receipt, entry §11/§11.2, lesson, SCORECARD/QUALITY/LOG, fleet `AXES.md`/`PROTOCOL.md`; ran the frozen counter on BASE, four purpose-built trees and the candidate; imported the candidate gate and exercised `evaluate()` on forged tables/receipts; ran the lane's own probe against the published 2.42.0 archive; diffed `self-counts.py` across BASE and candidate.

---

## (1) Could a do-nothing or near-do-nothing landing reach 2 or 1? — **holds** (do-nothing and the seat's example are 0; the named ceiling is real and reproduced)

Counter runs (`HYAKU_SCRATCH=$S`, `C1_ASOF=$(date +%s)` for `--tree`), last line each:

| tree | what it contains | last line |
|---|---|---|
| BASE `1a0f43a9` | nothing | `C1_OP_CLOCK: value=0 watched=0 measured=0 guard=1 (bad=watched:s072-recheck=180d …)` |
| `t2` | BASE + S072 recheck flipped to `on-release` only (the seat's "only flipping S072") | `value=0 … bad=watched:clock-rows=0` |
| `t3` | `t2` + S112 registry row + S072 clock row + the candidate `observe-r54.json`, **gate left at BASE** | `value=0 … bad=watched:receipt-unnamed`; gate-line `RELEASE_CLOCK: FAILED (… observed=31 …)` |
| `t4` | BASE + a `### 11.2` heading naming `2.42.0` + a **hand-written** op receipt (six PASS lines, CLEAN, `exit=0`, BASE probe sha) — no op download, no signature, no probe | `value=1 watched=0 measured=1 guard=1` |
| candidate `ede4373` | the landing | `C1_OP_CLOCK: value=2 watched=1 measured=1 guard=1 (bad=watched:OK measured:OK; gate-line=RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17))` |

Reading: a do-nothing landing is 0; the seat's example (flip S072 and write a receipt) is 0, and adding the registry rows without the gate change is still 0 — `WATCHED` needs the gate's pinned receipt digest (d) **and** the gate's own `parse_latest_version(body, FEED_TITLE_PREFIXES[OPFEED])` (e), which the BASE gate cannot satisfy (no `FEED_TITLE_PREFIXES`; cf. K1-F3 `parse-AttributeError`). At BASE `GUARD=1` already (probe equals itself, selftest PASS), so GUARD is not the do-nothing discriminator; the conjuncts are.

The only cheap partial score is **1 from the MEASURED conjunct alone** (`t4`): nine fabricated receipt lines plus a heading, with no measurement. This is exactly the ceiling the plan and SCORECARD name ("a hand-written op receipt scores MEASURED"); admission needs 2, so it is a reporting property, not an admission hole. No path to 2 without the registry work plus the gate change was found.

## (2) Is a vendor binary from scratch a valid basis, and does any lane text imply the installed CLI or R21-01 measures 2.42.0? — **holds** (independently corroborated)

- Archive digest: `curl -fsSL https://cache.agilebits.com/dist/1P/op2/pkg/v2.42.0/op_linux_amd64_v2.42.0.zip` (HTTP 200, 16233648 B) → `sha256=261fe3844a43e7e83a3d85e8a9f36411729436a1d3add1dc7dd46cbbceebe9e5`, identical to the receipt's `zip_sha256`. Unpacked `op` → `8585aa02644f71c05b268125d0b474fd0d8ed606176b3878517cb79d280cfc92`, identical to `op_sha256`.
- Signature: the archive carries `op.sig`; the documented key `3FEF9748469ADBE15DA7CA80AC2D62742012EA22` fetched from `keyserver.ubuntu.com` into a scratch `GNUPGHOME` → `[GNUPG:] VALIDSIG 3FEF9748469ADBE15DA7CA80AC2D62742012EA22 …` / `Good signature from "Code signing for 1Password <codesign@1password.com>"`. (The conventional `.zip.sig`/`.asc` URLs 404 — the signature ships inside the zip, as the vendor install docs show; the receipt's fingerprint line is genuine.)
- Behaviour: `op --version` → `2.42.0`; `HOME=$S/home OP_REF_OP_BIN=$S/op/op bash corpus/op-ref-probe.sh --dotenv-bytes` → six `DOTENV_BYTES_CASE … status=PASS`, `OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, `rc=0`. The candidate probe's sha256 is `0f1945e8…44f4c` = the BASE probe's, so `GUARD` is honest.
- No lane text claims the installed CLI or R21-01 measures 2.42.0: `/usr/bin/op --version` prints `2.41.1`; §11.2 says "The installed CLI stayed `/usr/bin/op` `2.41.1`"; SCORECARD:1821 ends "The installed CLI stays 2.41.1 (ledger `R21-01`)"; the lesson's routed item 2 says the same. The statement is scoped to "a verified vendor binary that is not the installed CLI", which is a valid basis for a release-scoped byte statement (and stronger than the installed binary, which the host cannot upgrade).
- Pre-existing, not introduced here: the ledger note on `R21-01` says "measured CLEAN on op 2.40.0 (round 20) and 2.41.0 (2026-10-19)" while §11.1 (round 32) measured 2.41.1. One release stale, unused by this claim; route as calibration debt, do not score against C1.

Residual limit (named, not a defect): the counter cannot separate a real probe run from a fabricated receipt (see `t4`); the live leg is the only check, and for this landing it passes.

## (3) One claim with two conjuncts; the no-calibration reason — **holds on substance, wording weakened**

Contract: `AXES.md` §"Working the axes" — "A round declares **1–3 claims** … Claims must be **causally separable** … and name **distinct axes**; two claims on one axis in one round count as one claim." `PROTOCOL.md:96` repeats 1–3. So a single claim is compliant, and splitting WATCHED/MEASURED would book the same one claim (both are freshness: round 32 booked the 2.41.1 re-measure under freshness, `SCORECARD.md:1337`). Separability is observable: K1-F5 gives `watched=1 measured=0`; my `t4` gives `watched=0 measured=1`. The `0 → 2` before→after is the claim's own.

Calibration reason: my own run in the BASE archive gives `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` (rc=2; the two POLICY rows are the operator-routed R29-01/R29-02) — identical to the plan's `stale=0`. `R11-08` is `FAIL reason=timeout exit=124 tmo=300` at both BASE and candidate in `.ufo/waves/round-54/final/verify-base.txt` / `verify-candidate-tree.txt`, and its four residual `UNRESOLVED` citations are prose fragments parsed as paths inside **lane-owned historical** verifier spot-checks (`corpus/lessons/round-30-verifier-spotcheck.md:41` `corpus/README.md:64/65/67`, `corpus/lessons/round-32-verifier-spotcheck.md:54`, `round-33-verifier-spotcheck.md:90` `knowledge/corpus/knowledge/`, `round-51-verifier-spotcheck.md:72` `corpus/plans/.ufo`). Editing a historical record to make the gate green is the prohibited move, so no landable calibration claim existed. **Wording defect:** the plan calls these "non-owned closure spot-checks"; they are lane-owned historical lesson files (`.ufo/waves/round-52/build/R52ExecHarm-r11-08-full.txt` is only the receipt that lists them).

Second wording defect: `corpus/knowledge/op-ref-consumption.md:371,397` are **unchanged** — the clock citation lives in the appended §11.2 (line 411 carries `(clock: S072 → S112)`). QM70's antecedent reads "A knowledge line that declares `recheck: on-release of <tool>` cites a registry row …", which is true at entry granularity (§11.1 cites S072) but not of the two declaring lines a reader will check.

## (4) Is the clock really live-watching? — **holds as a recorded live observation; weakened if read as a live gate**

Harness: imported the candidate `corpus/release-clock.py`, parsed the real registry/table/captures, and called `evaluate()` with mutated receipts/rows:

| case | state | verdict |
|---|---|---|
| A | as landed | `passed=True errors=[] on_release=32 observed=32 fired=14` |
| B | receipt re-observed at **2.43.0**, table still 2.42.0 | `passed=False [('RECEIPT-MISMATCH','S072')]` |
| C | receipt 2.43.0 **and** row updated to observed 2.43.0 / fired | `passed=True` (the maintenance path) |
| D | stale 2.42.0 receipt, feed has moved on, nobody re-observes | `passed=True` |
| E | table forged to observed 2.43.0, receipt still 2.42.0 | `passed=False [('RECEIPT-MISMATCH','S072')]` |

So on op 2.43.0 the clock **fails loudly the moment it is re-observed** (B, E) and clears only when the row is updated (C) — it cannot silently bank a newer release. But the gate never fetches: with no re-observation it stays `CLEAN` (D). The lane's own instrument text says so — `PROVINCE.md:75` and `SKILL.md:48`: the default receipt is "NOT live vendor truth". The counter's freshness binding (`observed_at` in `[2026-11-07T00:00Z, committer time]`) is what forces a landing-time observation; it is revision-bound, so the landed commit keeps reading 2 after 2.43.0 ships (by design; a later round must re-observe and migrate `R36-03` again).

Independent live leg: re-fetched `https://releases.1password.com/developers/cli/index.xml` at 2026-11-07T06:21Z → 45175 B, sha256 `2dce505a…405e2` (byte-identical to the committed capture), the candidate gate's own parser returns `2.42.0`. Receipt `observe-r54.json` has 32 observations, 0 with `error`, S072 = `{http_status:200, url:OPFEED, parsed_version:2.42.0, verdict:"fired", sha256:CAPSHA, observed_at:2026-11-07T05:54:19Z}`, and its sha256 `9513690e…98af` equals `DEFAULT_RECEIPT_SHA256`.

Smallest correction: in the lesson/SCORECARD say "watched by a release clock **observed live at landing (2026-11-07)**", not "live release clock" unqualified.

## (5) Harm to any axis — **none found**

`python3 corpus/self-counts.py` in `git archive` trees of BASE and candidate, both rc=2 (POLICY only), last line `SELF_COUNTS: POLICY (claims=63 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)` in both. Diff is exactly two bound statements: `OK SC-CLOCK-SELFTEST SKILL.md:48 claimed=116 live=116` → `121`; `OK PV-CLOCK-SELFTEST PROVINCE.md:75 claimed=116 live=116` → `121`. 61 `OK` lines in both; the only non-OK lines are the pre-existing, operator-routed `POLICY PV-FEEDTOKEN-SHAPES ledger:R29-02` / `POLICY PV-FEEDTOKEN-SELFTEST ledger:R29-01` (allowlist policy, unchanged).

Other counts stated by the landing, checked in the candidate tree: `SOURCES_CENSUS: CLEAN (rows=112 A=108 B=2 C=2 queued=1 mined=107 rejected=4 entries_sourced=16 legacy=21 captures=112 …)` rc=0; `CLAIMS_DECLARED: CLEAN (claims=34)` rc=0; `RELEASE_CLOCK_SELFTEST: PASS (121 cases)`; default gate `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=14 derived=17)`. Migrations landed in `corpus/claim-ledger.tsv`: `R13-01 ^72$`, `R21-02 rows=112`, `R25-03 121 cases`, `R36-03 32/14`, `R38-01 ^10$`. `verify-base.txt` and `verify-candidate-tree.txt` carry the **same** non-PASS set (`R11-08` timeout, `R25-02`, `R29-01`, `R29-02`, `R36-01`, `R38-03`; `CLAIM_LEDGER: POLICY (claims=86 policy=3 stamped=125)`), so the landing adds no ledger harm. `.ufo/waves/round-54/final/kill-rules.txt`: instruments, overlay and capture `IDENTICAL` between predeclaration and candidate. Calibration: no stale/unlocated/ambiguous statement; the two wording defects in (3) and the R21-01 note in (2) are pre-existing or cosmetic.

---

## Impacted axes

| Axis | Verdict | Basis |
|---|---|---|
| freshness (C1's axis) | holds | counter 0 → 2 reproduced independently; live leg reproduced (feed, archive, signature, probe); `WATCHED` requires the gate capability, not registry text alone |
| calibration | holds, wording weakened | no broken self-count; two imprecise statements (plan "non-owned", lesson "live release clock"); QM70 line-granularity; R21-01 note one release stale (pre-existing) |
| depth / coverage / operability | untouched | census 112, selftest 121, no re-score; SCORECARD books them 9 → 9 without claims |
| adjacency | untouched | no sibling/repo change |

## Smallest safe corrections (none blocks admission)

1. Lesson line 1 and the SCORECARD cell: qualify "live release clock" as "observed live at landing (2026-11-07); the default gate replays the pinned receipt and is not live vendor truth".
2. `plans/round-54.md` §Axes: replace "non-owned closure spot-checks" with the actual files (`corpus/lessons/round-30/32/33/51-verifier-spotcheck.md` prose fragments).
3. QM70: say "the **entry** that declares" (or require the declaring line to cite the clock), since `:371,:397` are unchanged.
4. Route `R21-01`'s note (2.41.0 vs §11.1's 2.41.1) as calibration debt for the next round that touches it.

## Verdict

(1) holds · (2) holds · (3) holds (wording weakened) · (4) holds (qualified: observation-live, not gate-live) · (5) no harm. No counterexample falsifies C1 as frozen; the defects found are wording/provenance precision, not reachability or identity changes.
