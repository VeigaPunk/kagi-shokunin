# Round 53 — the lane's SOPS and age "current stable release" pins are watched by live release clocks (C1, freshness); the counts its documents state about itself match the live quantities again (C2, calibration)

source: S111 (https://github.com/FiloSottile/age/releases.atom, newest stable entry `<title>age v1.3.2</title>`, opened 2026-11-07)

Frozen plan: `plans/round-53.md` (predeclaration `39460f8676954f135d15fa99b43cd882360b3eee`; BASE `c1953d4afc19a5a336a58685c00ab5260bcfea1c`; no amendment). Counters `plans/round-53-c1.sh`, `plans/round-53-c2.sh`; pre-freeze controls `plans/round-53-controls.sh` (22 controls, all MATCH, `.ufo/waves/round-53/controls/controls-prefreeze.txt`; run 1 kept as `controls-prefreeze-run1.txt`, see M53-2). BASE readings `.ufo/waves/round-53/controls/c1-base.txt` (`value=0`), `c2-base.txt` (`value=5`). One attempt (`.ufo/watchdog.log`: one launch line for round 53).

## Claims

- **C1 freshness — the lane's two "current stable release" pins are watched by a live release clock, 0 → 2.** S103 (SOPS v3.13.3) and S104 (age v1.3.2) teach that the tag "is the project's current stable release, pinned as the version an installed sops / age-keygen must report", but sat on a fixed `90d` recheck that no gate watches; the lane held no age feed row. Change: S103/S104 `90d` → `on-release`; new feed row S111; clock rows S103 → S033 (sops feed, anchored 3.13.3) and S104 → S111 (age feed, anchored 1.3.2), both `derived:` from the feed rows' anchor cells; all 31 clocks observed live on 2026-11-07 into the new default receipt `.ufo/waves/round-53/final/observe-r53.json` (digest `f927b4318dee90ad3e2a8e2f899fcd2e37c43e833e7c3c3705aa5b5723d37c9a`), the 29 old rows' `observed_at` 2026-11-06 → 2026-11-07 with no verdict changed (fired 13 as before).
  - Frozen predicate (verbatim, plan §C1 and counter header): `C1_CURRENCY_CLOCKS: value = number of ids in F that are WATCHED, when GATE = 1, else 0; target 2 (BASE 0).`
- **C2 calibration — the counts the lane's documents state about itself match the live quantities, 5 → 0.** At BASE the lane's own checker read five STALE bindings (`SKILL.md:46`, `PROVINCE.md:73`, `corpus/README.md:65` say 124 stamps, live 125; `corpus/README.md:67` says 33 row-linked / 36 pinned entries, live 34 / 37), all left by the round-52 landing. Change: the four statements carry the live numbers with a round-53 note; no binding, ledger row or tool changed.
  - Frozen predicate (verbatim): `C2_SELF_COUNTS: value = M, the number of claim ids in the BASE binding table that the BASE checker reads STALE, UNLOCATED or AMBIGUOUS on the measured tree, when GUARD = 1, else SETUP; target 0 (BASE 5).`

## Gate

- **S111 — new, opened 2026-11-07** (capture `.ufo/waves/round-53/capture/S111.body`, fetched by the L1 with the declared request profile `curl-fsSL-compressed-v1`): `https://github.com/FiloSottile/age/releases.atom`, HTTP 200, decoded body sha256 `32517112c2ecb63ce97dfbbdf9c47569678738fda984da524b2cd38129d8f21d`, 40379 B. Located quote (byte search, `raw-literal-v1`, count 1, offset 725): "<title>age v1.3.2</title>" (3 words). The gate's own parser (`parse_latest_version` in `corpus/release-clock.py`) reads `1.3.2` from this body; the entry's `<updated>` is 2026-08-29T17:55:50Z, the same release day the S104 tag page shows. Admit: tier A, kind `code`, `mined`, `recheck 90d` (a feed row is never itself on-release: the gate refuses BADFEED), used-by this lesson.
- **Rejected — `https://releases.1password.com/developers/cli/index.xml`** (L1, 2026-11-07: HTTP 200, `text/xml`, 45175 B; titles such as "1Password CLI 2.25.1"): the lane's op CLI row S072 states the 2.41.1 release identity, not that 2.41.1 is current, so there is no currency statement to watch; and the gate's title rule takes at most one leading word, so it reads "feed has no stable X.Y.Z release entry" on this body. Flip: a lane statement that a given op version is the current release, together with a parser rule for multi-word product titles under its own selftest case.
- **Rejected — `https://app-updates.agilebits.com/product_history/CLI2.rss`** (L1: HTTP 404, "Unknown product: CLI2.rss"): no feed at that address. Flip: none (the address does not exist).
- **Rows touched (old → new):** S103 recheck `90d` → `on-release`; S104 recheck `90d` → `on-release` (both: the row teaches currency, which only a release clock can keep true). Status and used-by unchanged.
- **Discernment sample (LEARNING.md):** admit — S111 (quote located count 1; the gate parses the pin from the body). Reject — the 1Password CLI releases feed (no currency statement to watch; parser refuses the title shape).
- **Counting rule (E49-1):** every word count in this `## Gate` is `printf '%s' "<quote>" | wc -w`.
- **Rows added:** 1 (S111; tier A 1). **Rows touched:** 2 (S103, S104 recheck). Registry 110 → 111.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M53-1 | `masked-stale` (a self-description checker existed and read STALE, but its summary verdict word and exit code are POLICY whenever the two operator-routed POLICY rows are present, so a landing that checks the verdict or the exit code sees no STALE) | `python3 corpus/self-counts.py` at BASE `c1953d4a`: five `STALE` lines, last line `SELF_COUNTS: POLICY (claims=63 stale=5 …)`; `corpus/self-counts.py` returns 2 for POLICY before it returns 1 for STALE; the five stale statements date from the round-52 landing `a2cb69b7` (new entry pinned and stamped, ledger R12-03/R14-01 migrated, prose not) | none — the round-52 harm check compared ledger FAIL/POLICY ids and ran the round-48 counter, not the self-count numbers | C2 corrects the five statements under a counter that reads the per-line findings, not the verdict word (`plans/round-53-c2.sh`). **Shown able to fail:** `controls/c2-base.txt` reads `value=5`; K2-F1 (one file fixed) reads 4. QM68 makes the per-line reading a landing rule. |
| M53-2 | `shared-line-binding` (a control expectation counted one binding per edited line, but two edited lines each carry a second binding whose locator depends on the same number) | pre-freeze run 1 (`.ufo/waves/round-53/controls/controls-prefreeze-run1.txt`): K2-F5 expected 5, read 7 (`UNLOCATED` also for SC-SKILL-CLAIMS at `SKILL.md:46` and RD-DOCS-BYHAND at `README.md:67`) | the pre-freeze controls (written expectations) | expectation corrected to 7 before the freeze, run 2 22/22 MATCH; the counter was right and is unchanged in value. Run 1 also printed a traceback for K1-F2 (one-line gate file); the receipt reader now names `receipt-unnamed`, value unchanged. |
| M53-3 | `cadence-on-currency` (a row whose teaching is a currency statement — "the current stable release" — carried a fixed 90-day recheck, so the statement could go false with every gate green) | S103/S104 at BASE (`recheck 90d`, round-48 rows); the release-clock gate watches only `on-release` rows | none | C1: both rows on-release with bound feed clocks; QM69 makes it a rule for new rows. **Shown able to fail:** `controls/c1-base.txt` reads `value=0`; K1-F1 (recheck flipped without clocks) reads 0. |

Misroot sweep (§3): recorded in the report.

## Closure defects of round 52 (spot-check `corpus/lessons/round-52-verifier-spotcheck.md:104-107`)

- D1 → the round-53 candidate cites only receipts that land in or before it: the controls and BASE readings landed in the predeclaration, the receipt `observe-r53.json` and the candidate-tree readings land in the candidate commit; revision-bound readings, the census-end receipt and wave reports land in the receipts commit and are cited only from text in that commit.
- D2 → stays routed (the round-52 C1 counter's printed-protocol hole; no trial counter this round).
- D3 → the full ledger verify ran on the candidate tree before the candidate commit (receipt `.ufo/waves/round-53/final/verify-candidate-tree.txt`); the population migrations it found are journaled in `.ufo/waves/round-53/expectation-migrations.json`.
- D4 → R52ReviewerTrial D1–D4, R52CriticC2/R52ReviewerC2 ceilings and R11-08/R36-01 stay routed as round 52 listed them.

## Routed (named, not claimed this round)

1. Round-52 routed items 1–5 stand (round-51 trial argv/log handling; C1 trial-counter printed protocol; KV trial defects; C2-class counter ceilings; operator-routed R25-02 FAIL and R29-01/R29-02/R38-03 POLICY).
2. `corpus/self-counts.py` summary precedence (M53-1): a STALE line is hidden behind the POLICY verdict word; a separate summary field or exit precedence change needs its own selftest case and a ledger migration (ledger rows that read the selftest count).
3. The op CLI release feed (Gate rejection): parser support for multi-word product titles, only together with a currency statement to watch.

## Frontier

Census at round start (`.ufo/waves/round-53/controls/census-start.txt`): `kagi ok`, rc 0. Frontier move: the lane's tool-release pins move from a cadence to live release clocks — SOPS and age now join Vault, OpenBao, CPython and curl under the release-clock gate (on-release rows 29 → 31).

## Assimilation

None: `grep -rilE 'releases\.atom|release clock|age-keygen|FiloSottile' /home/vgpnk/Projects/shokuknow/merge/kagi | wc -l` prints `0` (L1, 2026-11-07).

## considerthese

Newest file `considerthese/2026-10-26.md`; none taken: its proposals (repair-only release path, machine-readable lane status — implemented round 31 —, the backlog table and carried-over items) touch neither a release clock nor the self-count statements.
