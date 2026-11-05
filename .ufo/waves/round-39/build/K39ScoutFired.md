# K39ScoutFired — release-clock derivation, live domain recheck, and round-39 plan provenance

Seat: K39ScoutFired (scout, wave `build`, kagi round 39 attempt 1).
Candidate under test: `6742fdef0e261dd06a38a0fb0b66b1bc027d1bee`. Claim BASE `06144518d3b3745e7fdf82d4207b4a3b5532a7a7`.
Predeclaration `1909e3876341cc90246516886def37a7c9ea92f9`. Frozen plan `7c11e769cd7c2450cf46faabcd3b43fca993f388`.

Scope: read-only research on `corpus/release-clock.py` / `corpus/release-clocks.tsv`, the R37-V2
derivation dependence, a concrete next domain recheck, and the round-39 plan's provenance.
Receipts: `.ufo/waves/round-39/build/K39ScoutFired/receipts/00-method.md` … `09-tools.md`.
No tool was installed; no lane, fleet, sibling or source file was modified; one `git archive`
extraction was made and the scratch tree was deleted after the receipts were preserved.

## 0. Frozen counters — reproduced, not falsified

| measurement | candidate | BASE / predeclaration |
|---|---|---|
| `bash plans/round-39-c1.sh` (C1, target 3) | **3** | **0** (BASE-shaped root: instrument absent) |
| `bash plans/round-39-c2.sh` (C2, target 3) | **3** | **0** (BASE-shaped root: instrument absent) |
| `bash corpus/anchor-pins.sh --root .` | `ANCHOR_PINS: CLEAN (pins=3)` rc 0 | n/a |
| `bash corpus/claims-declared.sh --root .` | `CLAIMS_DECLARED: CLEAN (claims=2)` rc 0 | n/a |
| frozen pre-freeze gate at `1909e38` | `PREFREEZE: CLEAN (controls=4 mismatch=0)` — `OK c1_nowork 0`, `OK c1_positive_three 3`, `OK c2_nowork 0`, `OK c2_positive_three 3` | reproduced exactly |

Both kill rules' first clauses hold at the candidate; the three pins are exactly the sha256 of the
**BASE** anchor cells of S034/S035/S039 (recomputed independently and matched), so the pin file is
not a re-derivation of the candidate tree. **Both claims reproduce; nothing here falsifies them.**

## 1. The 15 fired clocks, explained independently

The 15 `fired` rows are exactly S012, S013, S014, S015, S016, S021, S022, S023, S024, S025, S026,
S027, S028, S040, S041 — grouped by feed row S034 (5 rows: Vault), S035 (6 rows: OpenBao),
S036 (2 rows: Python 3.15.0 generation) and S039 (2 rows: Python 3.15.1 generation). The plan's
family attribution is **accurate**.

Every fired row is a `feed` row whose `observed_version` differs from its `anchored_version`:
Vault `2.2.0 → 2.2.1` (plus S012's series anchor `v1.21.x → 2.2.1`), OpenBao `2.7.1 → 2.7.2`,
Python `3.15.0 → 3.15.2` and `3.15.1 → 3.15.2`. The Python pair fires twice because the feed
was re-registered (S036 superseded by S039), so one physical stream carries two anchor
generations.

**Two populations share the number 15 and must not be conflated.** The gate prints `derived=15`,
but the 15 derived rows are the 10 fired rows whose note begins `derived:` (S013–S016, S021–S026)
**plus** the five never-fired derived rows S008–S011 and S029. `fired=15` and `derived=15` are
different sets that coincide numerically.

**Derivation dependence.** Only `derived:` rows are bound to their feed row's anchor cell
(`derived_anchor_bound`, `release-clock.py:349`, used at `:619`): the anchored_version of a derived
row *is defined* by the feed row's anchor cell, so re-pointing the feed id breaks the binding.
The five non-derived fired rows (S012, S027, S028, S040, S041) are anchored in their **own**
registry anchor cell (`:616`) and are therefore inert to a feed-id swap.

I re-pointed all 15 feed ids (S034→S089, S035→S090, S036→S091, S039→S091) on a scratch copy of
the candidate table, keeping anchors:

```
DERIVATION S013 S014 S015 S016 S021 S022 S023 S024 S025 S026
RELEASE_CLOCK: FAILED (on_release=30 bound=30 unbound=0 observed=20 fired=5 derived=5)   rc 1
```

This reproduces the round-38 lesson's table row **exactly**, including the count (10) and the ids
(S013…S026). The 10 findings are exactly the 10 derived fired rows; the 5 non-derived rows produce
no finding. **The plan's R37-V2 account of the derivation dependence is confirmed.**

## 2. Concrete next domain recheck (live, read-only, 2026-11-05)

I re-fetched the five live vendor surfaces and parsed them with the lane's own
`corpus/release-clock.py parse_latest_version`:

| surface | live newest stable | lane's recorded identity |
|---|---|---|
| `hashicorp/vault/releases.atom` | 2.2.1 | S089 = 2.2.1 |
| `openbao/openbao/releases.atom` | 2.7.2 | S090 = 2.7.2 |
| `python.org/downloads/feed.rss` | 3.15.2 | S091 = 3.15.2 (3.16.0a1 still a prerelease) |
| `getsops/sops/releases.atom` | 3.13.3 | S033 = 3.13.3 |
| `curl.se/info` | 8.23.0 | S037/S029 = 8.23.0 |

**No vendor has moved past the identity the lane already recorded.** The live state equals the
round-37 receipt exactly. Two consequences for the next round:

1. **R37-V2 gains nothing from the feeds.** Its cost is entirely the coupled edit (10 derived
   anchored_version cells + the 5 non-derived rows' own anchor cells + a receipt re-observation
   whose date binding is separately broken — the round-38 receipt is not a usable pin, 30
   `RECEIPT-MISMATCH`). The right next step is to *record* that R37-V2 is not a freshness move,
   not to re-point.
2. **A real domain drift exists in the documentation surfaces, not in the feeds.** The Python
   documentation now serves **3.15.2** (`re — Regular expression operations — Python 3.15.2
   documentation`), while registry rows S040/S041 name *"Python 3.15.1 documentation"* and
   S027/S028 name *"Python 3.15.0 documentation"*. Both registered quotes still locate on the
   live pages with the lane's own locator (`count=1` each), and the round-26 capture bodies
   differ from the live bodies. Those rows carry `recheck=on-release`, so **the on-release recheck
   of S027/S028/S040/S041 against the served 3.15.2 docs is already due and is not yet done** —
   this is the concrete next domain recheck.
3. **Vault docs**: `/vault/docs/auth/jwt` now serves the **v2.x** documentation
   (`Currently viewing v2.x (latest).`; the switcher's newest non-`latest` pinned entry is still
   v1.21.x). S012's anchor cell says "version switcher's newest pinned entry v1.21.x" and its
   scope says "unversioned 'latest' page as served 2026-10-19" — the unversioned URL now serves a
   different version than the registry names. The registered S012 quote
   (`…one of the \`aud\` claims declared for the JWT.`) does **not** locate on the live page as a
   rendered-text string (`count=0`, the MDX source renders inline code inside a JSX payload);
   the plain-text form locates (`count=2`) on the latest, v1.21.x and v2.x pages alike. This is
   the same "non-reproducing representation" class the census already records for S012 in
   `corpus/inrow-pins.tsv`.

## 3. Surviving defects (every one measured)

**D1 — freshness — the C1 pin set misses a fourth superseded feed anchor (S036), and the plan's
"only" is wrong.** `plans/round-39.md:26-29` asserts that S034, S035 and S039 "are the **only**
anchors the round-37 counter cannot see changing in place". S036 is also a superseded feed anchor
(S039's anchor cell: "supersedes S036 — …"). I rewrote S036's anchor cell in place
(`Python 3.15.0 → Python 3.15.2`): `anchor-pins.sh` reads **CLEAN** (S036 is not pinned),
`round-37-c2.sh` reads **0**, `release-clock.py` reads **CLEAN**, `sources-census.sh` reads
**CLEAN**, and the sweep reports no new finding. So an in-place rewrite of the superseded feed
anchor S036 violates the very append-only rule this round registers as S094, with **no gate and
no counted finding anywhere**. The plan's mechanism is right; the enumeration is incomplete, and
the claim's own ceiling sentence ("it does not cover any registry row other than the three pinned
ones") is where the gap is silently left.

**D2 — freshness — C1's novelty is narrower than the plan implies, and its mutants are not pure
anchor edits.** Applying the three frozen mutants to the **BASE** tree: M1 (S034) and M2 (S035)
are **already detected at BASE** by the pre-existing `corpus/release-clock.py` as `DERIVATION`
findings (S013,S022,S023,S024 and S014,S015,S016,S021,S025,S026 respectively). Only M3 (S039) is
undetectable at BASE. C1's genuine new coverage is **one cell (S039)**, not three. Separately, the
counter's `sed` rewrites **two** cells per row (anchor *and* teaches), so the frozen mutants are
not the single-cell in-place anchor rewrites the plan describes; the DRIFT verdict is unaffected
because the gate hashes only column 7 (verified: anchor-only rewrite → `DRIFT`; teaches-only
rewrite → `CLEAN`).

**D3 — calibration — the candidate's own SCORECARD breaks a committed self-description counter
row.** `R36-01` (`bash plans/round-36-c1.sh`, expectation `^0$`) reads **0** at BASE and **3** at
the candidate. Cause: the new `## Round 39 — post-move` calibration row (SCORECARD.md:1490) names
none of the three routed reds the `lane-status:` line still declares (R25-02, R29-01, R29-02), so
the sweep's SD5 = 3. Round-38's own lesson records this exact failure mode (M38-5) and round-38's
calibration row named the reds precisely to keep the counter at 0; the round-39 candidate repeats
the omission. The candidate adds **seven** newly-failing ledger rows over BASE
(R13-01, R21-02, R24-06, R31-02, R33-02, R34-03, R36-01). Six are the count-expectation rows the
lesson names as a deliberate, deferred migration; **R36-01 is not** — it is a self-description
counter broken by this round's own edit.

**D4 — calibration — the candidate adds two lane-owned SD6 rows and cites a file that does not
exist.** The sweep's SD6 goes 3 → 5: `SCORECARD.md:1493 .ufo/waves/round-39/expectation-migrations.json`
and `SCORECARD.md:1494 .ufo/waves/round-39/build/`. Neither path exists at the candidate
(`git ls-tree -r 6742fde -- .ufo/waves/round-39` lists only `capture/S094.body`), while round-38's
candidate *did* commit its `expectation-migrations.json`. The plan's BASE statement that the SD6
rows are "not lane-owned" is true at BASE and no longer true at the candidate.

**D5 — provenance — the frozen plan and the candidate lesson both misstate the last three
closures.** `plans/round-39.md:19` and `corpus/lessons/round-39.md:8` say rounds 36, 37 and 38
"closed `ok`" with "no rejected closure in the last three". The fleet manifest says otherwise:
`MANIFEST.json` `rounds[1298]` (round 36) `verdict = "rejected-honest-stop"`,
`rounds[1321]` (round 37) `verdict = "admitted"`, `rounds[1328]` (round 38)
`verdict = "rejected-honest-stop"`. Two of the three named closures were **rejected**. The
conclusion ("not a fresh-start round") still holds, because the rule counts three *consecutive*
rejections and round 37 was admitted between them — but the sentence as written is false against
the fleet record, and it is repeated in the candidate's own lesson.

**D6 — provenance — the census receipts the plan says were "copied to the wave dir" are not
there.** The scratch files exist and read as claimed, but `.ufo/waves/round-39/census/` is empty in
the working tree and nothing under `.ufo/waves/round-39/` is tracked at the candidate except
`capture/S094.body`. Round-38's candidate committed `.ufo/waves/round-38/controls/start-census-*.txt`.

**D7 — provenance — the SCORECARD cites a migration file that is not committed, for rows that are
failing.** SCORECARD.md:1496 names `R21-02, R31-02, R33-02, R34-03` as "(migrated,
`.ufo/waves/round-39/expectation-migrations.json`)"; that file is absent and all four rows now FAIL
(census reads rows=94; their frozen expectations read rows=93).

**D8 — plan/lesson asymmetry (minor).** The frozen plan's "Routed, not claimed" list omits
**R38-D2** (report wording: name the C2 axis relabel as an amendment; replace the lane's
self-verdict). The candidate *lesson* does table it, so the disposition exists — but the frozen
plan does not carry it, and the plan is the claim document.

**D9 — counter fidelity (minor).** `corpus/prefreeze-control.sh` derives its repository from its
own location unless `PREFREEZE_REPO` is set. The plan's stated command line
(`corpus/prefreeze-control.sh run --base 1909e38… --controls plans/round-39.controls.tsv`) only
works when run in place; from a scratch extraction it needs `PREFREEZE_REPO=<lane>`.

**Verified-correct plan statements** (so the defects above are not read as a wholesale refutation):
the round-38 closure account (CD-1/CD-2, C1 0→5), the 15-fired-clock family attribution, the
BASE sweep reading (`n=3 (SD6=3)`, three verifier-owned rows) and `round-36-c1.sh` reading 0 at
BASE, the R37-V2 DERIVATION account, the pin provenance, both kill-rule first clauses, the census
after-expectation (rows=94, entries_sourced unchanged = 14), and the C2 ceiling ("cannot detect an
untagged relabel of a row that was never tagged") — I confirmed the C2 gate's axis comparison is
correct and *would* have caught the round-38 relabel on a tagged row
(`MISMATCH 38 C2 scorecard-axis-operability-not-calibration`); round-38's rows simply carry no
`[C2]` tag, so the gate reports `tagged-rows-0` instead.

## 4. Recommendation

C1 and C2 stand as declared — both counters reproduce their targets and their do-nothing BASE
readings, and the frozen pre-freeze gate reproduces exactly. Nothing measured here meets a C1 or
C2 kill rule. Three things should be recorded before the landing revision rather than silently
absorbed: the **S036 pin gap** (D1, with the plan's "only" corrected), the **R36-01/SD5 regression
the candidate's own SCORECARD introduces** (D3), and the **history correction** to rounds 36/38
being `rejected-honest-stop` (D5). The concrete next *domain* recheck is the **due on-release
recheck of S027/S028/S040/S041 against the now-served Python 3.15.2 documentation** (and the
Vault `latest` page's move to v2.x for S012/S013/S022–S024), not the R37-V2 feed re-point, which
the live feeds show would gain no new information.

## 5. Scope compliance

Read-only on the lane (`git -C <lane>` with explicit revisions throughout; no checkout, commit,
push, branch or worktree change; no jj call). No clone; one `git archive` extraction, deleted after
the receipts were preserved. No tracked lane file, fleet-root file or sibling tree was written.
Written: this report and `K39ScoutFired/receipts/*.md` only. No tool was installed or updated (no
`pacman` transaction; the operator's pause respected). Live network use was limited to read-only
GETs to five public vendor surfaces with the lane's declared User-Agent.
