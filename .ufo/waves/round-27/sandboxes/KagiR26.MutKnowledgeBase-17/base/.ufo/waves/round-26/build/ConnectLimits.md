# ConnectLimits — round 26 bounded sibling-overlap scan (secret scanning / privacy gates)

Seat: `KagiR26.ConnectLimits` (UFO-FSD connector, leaf). Lane-authored advice, not non-author closure.
Judged on: freshness, calibration. Claim served: C1 freshness only (`plans/round-26.md:5`).

## Observed BASE and scope

- `git -C kagi-shokunin rev-parse HEAD` → `1bf3eec48d3761580ffd375c88143232485ae814` (= frozen BASE). Status: only `?? .ufo/waves/round-26/`, `?? plans/round-26.md` untracked.
- `git show 1bf3eec:PROVINCE.md | sha256sum` → `22ed8900afaef06610dfc112fdb7e09d32c152cbdc4385129607424b8ba2cdaa` (83 lines).
- Inspected: the 20 sibling `*-shokunin/PROVINCE.md` files (audio, chousa, game-dev-2d, game-dev-3d, kaidoku, kake, kama, kasegi, kengaku, kotoba, kotodama, kumitate, lore, mado, mori, revenger, souji, tabi, tameshi, tsukuroi). Plus bounded follow-ups into `souji-shokunin/tools/souji-proc-census.sh`, `souji-shokunin/corpus/QUALITY.md`, and `kengaku-shokunin/corpus/SOURCES.md`. Plus `git log -S` chronology in souji, mori and kagi. All reads were repository files; no host, private, config, network, vault, handler, or CDP contact.
- Sibling HEADs at scan time (short): audio 0462a544, chousa 0e9784b, game-dev-2d bce53b83, game-dev-3d 3118be0, kaidoku 2ee3d9f, kake 9f62cda, kama 971d454, kasegi 8bf9807, kengaku 6356b0b→**b9b2479** (it committed during the scan, `2026-10-21 10:37:39 -0300`), kotoba c61a973, kotodama 4ad2683, kumitate 2fa28e5, lore 01306d5, mado 741122d, mori 77a5bbe, revenger cf02419, souji 41553ad, tabi 1b5f449, tameshi 81106f9, tsukuroi e99303c.
- Note on the method: the Glob/Grep tools returned 0 hits under this fleet root because of ignore rules. All evidence below comes from `rg --no-ignore`, `sed -n`, and `git` over explicit paths.

## Bounded result

**C1 remains in-lane.** No sibling PROVINCE claims any of C1's surfaces:
- Python release identity
- the python.org downloads feed
- release clocks
- kagi's `rendered-text-v1` normalizer
- kagi's S027/S028/S036 rows

Search: `rg --no-ignore -i 'python|cpython|release feed|feed|on-release|docs\.python'` over the 20 sibling PROVINCE files. It found only tool or venv mentions in kaidoku (`:26,60,62,108,129`), kama (`:96`), and kengaku (`:19,108,116,117`), plus tsukuroi's Arch News feed (`:20`). None is a Python-release or kagi-clock claim.

A wider search of all non-`.ufo` sibling repo content (`rendered-text-v1|release-clock|kagi-shokunin/corpus/(SOURCES|release)|python.org/downloads/feed|docs.python.org/3/library/(re|html).html`) found exactly one sibling: kengaku (see counterexample 1).

**The secret-scanning and privacy-gate boundary is consistent with kagi's declaration.** Every sibling that mentions secrets refuses custody and routes it to kagi:

| Sibling | Anchor |
|---|---|
| chousa | `PROVINCE.md:14-15` ("secret values in any record (→ kagi for custody; shape-only here)") |
| kake | `:34` |
| kama | `:40` |
| kasegi | `:45` |
| kengaku | `:26,140` |
| kumitate | `:14` (secret members shape-only), `:26` (MCP/OAuth → kasegi / kagi) |
| mado | `:14` |
| mori | `:15,68` |
| souji | `:36-37,55-56,84-85,101-103,155,161-168` |
| tabi | `:11,16` |
| tameshi | `:18,45` |
| tsukuroi | `:25`, ADJ-02 `:47` |

No sibling claims vault operations, SOPS/age, OpenBao/Vault, the Credential Broker, or workload identity. The round-21 sweep sentence still holds on its own terms (`kagi PROVINCE.md:67`).

Two siblings added their own output-privacy filters after kagi's round-21 sweep. Both are hygiene over their own outputs, and both explicitly hand exposure assessment back to kagi/operator:

- **souji**, round-21 privacy boundary. `PROVINCE.md:161-168`: "reason output using the shared secret patterns … Operator/Kagi retains exposure assessment". The patterns are souji-local: `tools/souji-proc-census.sh:7,207-225` defines `redact_secrets` inline (Bearer, `--token=`, `ghp_`, `sk-`). `rg 'source |kagi'` on that file returned nothing, so it consumes no kagi artifact. Landed in commit `4b826a5`, `2026-10-21 09:04:05 -0300`.
- **mori**, round-18 own-evidence retention. `PROVINCE.md:125-131`: "pushed history, exposure assessment, credential rotation and any history rewrite are **kagi/operator**-owned". Landed in commit `daceeec`, `2026-10-21 03:25:06 -0300`.
- **kagi's round-21 sweep** for comparison: commit `c41af82`, `2026-10-19 19:29:35 -0300`.

None of this expands vault operations, and C1 touches none of it.

## Actionable counterexamples (report, don't absorb; no arbitration)

**1. Shared upstream source with independent ownership (freshness, calibration).**
- What kengaku has: kengaku's own registry cites the same Python docs the 3.15.1 drift affects. `kengaku-shokunin/corpus/SOURCES.md:68` is S046, `docs.python.org/3/library/re.html`, "Python 3.15.0 docs … backslash-s", `on-release`. `:74` is S052, `json.html#…raw_decode`, "Python 3.15.0 documentation", `on-release`. Both cite kengaku's round-26/27 lessons. Kengaku has no feed clock: `rg 'feed\.rss|3\.15\.1'` on that file found nothing.
- Why it matters for C1: C1's drift disposition for kagi's S027 (`re`) is upstream evidence kengaku's S046 also depends on.
- What C1 should do: record a route note to L1 or the orchestrator, for kengaku. It should not add a kagi row for kengaku's source, and it should not edit kengaku.

**2. Registry-ID collision risk for C1's counting instrument (calibration).**
- `plans/round-26.md:5` counts "exact S027/S028 identities in old/new receipts". But kengaku's `SOURCES.md:49-50` also defines `S027` (SciPy `binomtest`) and `S028` (statsmodels `proportion_confint`).
- The counter needs to key on kagi's own registry (`corpus/SOURCES.md` S027/S028, bound via `corpus/release-clocks.tsv:24-25` to clock S036). A bare ID match must not count them.
- Fleet-root or `.ufo/`-lane-first resolution could otherwise conflate two unrelated rows.
- Falsifier: take a receipt fixture that contains kengaku's `S027|…scipy…` line. The counter must not count it as a kagi S027 drift disposition.

**3. Line anchors on kagi's PROVINCE held by siblings (second-order, runtime/contract).**
- mori cites `../kagi-shokunin/PROVINCE.md:3-6` (`mori PROVINCE.md:68`).
- tsukuroi ADJ-02 cites `:3-6,10-17,32-34,54` (`tsukuroi PROVINCE.md:47`). Its OUT-003 pins commit `c2cab35…` with sha256 `4a346e2d…` (`:123,139`). That is stale by its own declaration (`:132`): 6 commits touch kagi's PROVINCE between `c2cab35..1bf3eec`, and the current sha is `22ed8900…`.
- At BASE, `:3-6`, `:10-17` and `:32-34` still carry the cited domain, erratum and runtime-state text. `:54` is now the `release-clock.py` line, not whatever tsukuroi cited.
- What C1 should do: if C1 updates current-tense counts in PROVINCE.md (the `release-clock.py --selftest` count on `:54`, or claim-ledger counts on `:52`), edit in place or append after `:60`. Never insert above `:34`, so the sibling-held `:3-6/10-17/32-34` anchors don't move. Kagi cannot repair tsukuroi's `:54` citation; it is reportable to L1 only.

**4. kagi's adjacency list is incomplete (freshness, not a C1 target).**
- `kagi PROVINCE.md:67` and `corpus/README.md:113` name tripwires in "chousa, kasegi and kumitate" only. They omit souji's round-21 `redact_secrets` and mori's round-18 minimization, both of which postdate the round-21 sweep (chronology above).
- This doesn't change ownership: both siblings route exposure assessment to kagi. It is out of scope for C1 under "No new … coverage surface" (`plans/round-26.md:7`). Record it as a future-round adjacency refresh lead, not a round-26 edit.

**5. Contested-profile cardinality mismatch (pre-existing, unchanged).**
- kake: "contested scope (kagi/tabi/kake)" (`kake PROVINCE.md:35`).
- kagi: "contested with kake" (`kagi PROVINCE.md:43`, `corpus/adjacency.tsv` kake row).
- tabi's PROVINCE claims browser profile surfaces (shape-only) (`tabi PROVINCE.md:7-8`) but doesn't name the musketeer lease.
- Not C1-relevant. It stays with the integrator, per `kagi PROVINCE.md:59`.

## Axes

- Freshness: improved by counterexamples 1 and 2. C1's drift receipt gets exact scoping and a route for a cross-lane shared source.
- Calibration: improved by counterexamples 2 and 3. The count can't be inflated by an ID collision, and sibling anchors aren't silently broken.
- Harmed axes: none. No new surface, retirement or promotion. The round-25 receipt, the binding TSV, R25-04 and the lone-clone INCOMPLETE/48 are untouched by this seat.

## Proposed move (one, bounded)

L1, when integrating C1:
- Key the S027/S028 old/new identity comparison to kagi `corpus/SOURCES.md` together with the `corpus/release-clocks.tsv` clock `S036`. Add the kengaku-shaped collision fixture as a negative case.
- Confine any PROVINCE.md count edits to in-place or post-`:60` text.
- Add one route line, report-only, noting that kengaku S046/S052 cite the same Python 3.15.0 docs.

Risks:
- Kengaku moved during this scan (6356b0b→b9b2479), so its line numbers may shift. Re-read before citing.
- The route line must not read as kagi adjudicating kengaku's rows.

## Verification

- What was run: the probes listed above (`git rev-parse`/`status`/`show`/`log -S`, `sha256sum`, `rg --no-ignore`, `sed -n`). Every quoted output is copied from those runs.
- What was not run: builds, tests, selftests, gates, or network fetches. Nothing here should be read as a passing check.
- L1 post-integration: `python3 corpus/release-clock.py --selftest`, `python3 corpus/self-counts.py`, `corpus/claim-ledger.sh verify`. Also re-run the collision fixture from counterexample 2.

Tool installs or updates: none.
