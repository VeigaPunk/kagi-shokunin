Author: R72Reviewer (reviewer)

# Round 72 review: C1 freshness and C2 calibration, end to end

Scope: freeze integrity, re-measurement of both counters on BASE and candidate, control battery (all 20 re-run), and forgery-route reading of the C1 legs. Lane HEAD inspected read-only. Nothing in the lane or fleet repo was written; no git mutation.

## 1. Measurements (re-run by this seat)

| run | command | result | rc |
|---|---|---|---|
| candidate C1 | `bash plans/round-72-c1.sh a947a42c52dc5b64cc9be1eef98207712fca7c42` | `C1_CLOCK_REARM: value=10 rows_passing=10 gate=1 fresh=1 census=1 live=1`; ten `ID ... PASS` lines | 0 |
| candidate C2 | `bash plans/round-72-c2.sh a947a42c...` | `C2_SELF_COUNTS: value=0 pins=1 shape=1 claims=63 policy=2 ok=61 stale_ids=none` | 0 |
| BASE C1 | `bash plans/round-72-c1.sh b2f3dd66...` | `C1_CLOCK_REARM: value=0 rows_passing=0 gate=0 fresh=0 census=1 live=1`; all ten FAIL `not-armed,not-newer,unsourced,no-ledger` (live=2.2.1 / 2.7.2) | 1 |
| BASE C2 | `bash plans/round-72-c2.sh b2f3dd66...` | `C2_SELF_COUNTS: value=4 pins=1 shape=1 claims=63 policy=2 ok=57 stale_ids=SC-SKILL-STAMPS SC-SKILL-CLAIMS PV-STAMPS PV-CLAIMS` | 1 |

Copies: `c1-candidate.txt`, `c2-candidate.txt`, `c1-base.txt`, `c2-base.txt`, `controls-summary-frozen.txt` in `.ufo/waves/round-72/w1/R72Reviewer/`. Every measured value matches the frozen targets (10/0 candidate, 0/4 BASE).

## 2. Freeze integrity

- Ancestry and order: `f07aba03` (freeze; committer 2026-11-09 01:09:58 -0300) is an ancestor of `a947a42c` (candidate; committer 01:10:42 -0300, 44 s later). `git log b2f3dd66..a947a42c` lists both.
- `git diff --stat f07aba03 a947a42c -- plans/` is empty: no plan, counter or runner file changed after the freeze.
- `sha256sum` of `plans/round-72-c1.sh`, `plans/round-72-c2.sh`, `plans/round-72-controls.sh` equals the committed `.ufo/waves/round-72/controls/receipts/counter.sha256` (cc83b638…, 6ac7c51b…, 77c6cacaa…) and equals the same files at the freeze commit.
- Predicate text: `plans/round-72.md` lines 52-54 (C1) and 105-109 (C2) normalise to the same sentence as the counter headers (`round-72-c1.sh` 4-8, `round-72-c2.sh` 4-12). C2 header contains `PINS = 1` in both.
- Caveat (neutral): the runner's EXPECT table and the 20 receipts landed in the same commit as the plan. Git cannot prove the verdicts were written before the first run. The controls were re-run here and reproduce exactly, so the receipts are not stale, but the "written before the first run" ordering is an assertion, not a git-provable fact.

## 3. Control battery

Built BASE and CAND as `git archive` extractions in my scratch and ran `plans/round-72-controls.sh --base ... --cand ... --out .ufo/waves/round-72/w1/R72Reviewer/controls`. Result: `CONTROLS: 20/20 match`, rc 0, with F0-F10, P1, Q1, Q2, G0-G5 all MATCH (see `controls/`). F6 and F7 were explicitly re-run and match: F6 value=4, F7 value=4. The committed `summary.txt` reproduces line-for-line in verdict.

## 4. Adversarial reading of C1 legs

I read `plans/round-72-c1.sh` lines 56-207 and the relevant parts of `corpus/release-clock.py` (`valid_public_https_url` 172-208, `parse_latest_version` 817-868, `observe_one` 873-885, `run_observe` 971+).

**RV-1 (falsifies-wording, the most important).** LIVE(id) is described as "a live observation ... through the BASE-pinned gate parses the same version" and U3 says it "binds the vendor state". It does not bind the vendor. The counter fetches each F id from the `feed_url` written in the tree's own `corpus/release-clocks.tsv`. `valid_public_https_url` only requires a public-IP or public-name HTTPS URL with no secret-shaped path; there is no host allowlist for vault/openbao. `parse_latest_version` accepts any Atom feed with an entry whose `<title>` is `vX.Y.Z`. SOURCED only requires that the feed row be absent from BASE, `mined`, opened ≥ 2026-11-09, and its URL equal to the table's `feed_url`; a forger adds such a row themselves. GATE and FRESH are re-pinned inside the tree (`DEFAULT_RECEIPT_SHA256`, receipt file). So a tree that (a) adds a SOURCES row pointing at a non-vendor public HTTPS host serving a Atom feed with `<title>v2.7.3</title>`, (b) points the OpenBao rows' `feed_url` there, (c) sets anchors, ledger and receipt to 2.7.3, and (d) re-pins the default receipt sha, should pass all ten legs and print value=10. Not executed: I have no controllable public host, and `valid_public_https_url` rejects localhost and non-global IPs, so a local fixture cannot exercise this. This is a code-reading finding, `[INFERENCE]` from the code paths cited, not an observed run. The control battery does not cover it: F6 edits the table and receipt but leaves the vendor URL in place, so LIVE re-reads the real OpenBao feed (2.7.2) and kills the six rows; F7 edits the registry link, not the URL. A missing control is "F11: retarget a derived clock's feed_url and registry row to a non-vendor public host serving a fabricated release" — expected under the frozen predicate: value=10 (the counter cannot detect it), which the lane should treat as a known ceiling or add a vendor-host binding before the number is cited as vendor-backed.

**RV-2 (falsifies-wording).** VERIFIED's "round-72 page re-fetch" is not checked. The ledger's `sha256`, `bytes`, `fetched_at` (any time in [2026-11-09T00:00Z, now]) and `capture_path` (anywhere under `.ufo/waves/round-72/`) are self-declared; the counter only checks that the file matches the declared digest and contains the BASE quote the declared number of times. Nothing binds a capture to a network fetch. The committed captures are plausibly genuine: the S013 capture is 261663 B against BASE's 261632 B (`corpus/source-fetches.tsv`), and S024 has 3 quote hits matching the ledger, so the re-fetch appears to have happened. But that is an observation about this tree, not something the counter proves. F4 and F5 cover digest and quote-absence only.

**RV-3 (neutral, named in plan as U2).** The 22 non-F observations in the GATE receipt are only shape-checked. A tree can carry any values there. Not part of the number.

**RV-4 (neutral).** C2 measures agreement between SKILL.md/PROVINCE.md numbers and the lane's own ledger. The candidate does not touch the ledger or `self-counts.*` (`git diff --stat` on those paths is empty; the SKILL.md/PROVINCE.md diff is only 164→181 and 101→102). So the 0 is a real calibration in this tree. But the counter would also read 0 if a future change grew the ledger and bumped the two numbers together: C2 is consistency-with-self, not against an external count.

**RV-5 (neutral).** Candidate gate `python3 corpus/release-clock.py` default prints `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=4 derived=17)`. fired=4 is consistent with the table (S012, S027, S028, S072 are the only fired rows). The R36-03 pinned line (`fired=14`) is an integration duty not counted here, as the plan states; I did not check its journal.

## 5. Other checks passed

- Candidate touches only the expected 21 files (`git show a947a42c --stat`).
- C1 quote counts for all ten rows are recomputed with the BASE-pinned `rendered-text-v1.py`, not trusted from the ledger; quote source is BASE's `source-fetches.tsv` column 13 (`base_fetch[i][0][12]`), so the quote cannot be redefined in the tree. Checked: S013 quote is "All dynamic secrets in Vault are required to have a lease." in both.
- C2 PINS and SHAPE: the counter pins `self-counts.py` and `self-counts.tsv` to BASE by sha256; G1/G2/G3/G5 controls confirm SETUP on each tamper.

## 6. Residual risk and verification gaps

- RV-1 is the only finding that can change the C1 number under a forgery route the controls do not cover; it is not executed end-to-end here.
- The live observations were not re-read by this seat beyond the counter's own LIVE leg (which passed on re-run: live values 2.2.1 and 2.7.2).
- Did not check the lesson or journal text (`corpus/lessons/round-72.md`), the S174/S175 page semantic quotes, or the round-47 teaching verdicts (U1). Out of the counter scope and not assigned to this seat.

Tooling: no tools installed or updated. Scratch directory removed before yield.

FINDING RV-1 falsifies-wording LIVE/SOURCED do not bind the feed to the vendor: a tree-added registry row and retargeted feed_url to a non-vendor public HTTPS host serving a fabricated Atom v2.7.3 should pass all ten legs (value=10); F6/F7 do not cover it; code-read [INFERENCE], not executed
FINDING RV-2 falsifies-wording VERIFIED does not bind the capture to a round-72 network fetch: sha/bytes/fetched_at/capture_path are self-declared and only the quote containment is recomputed; committed captures do differ from BASE bytes, so the re-fetch is plausible but uncounted
FINDING RV-3 neutral non-F receipt observations are shape-checked only (plan U2); not part of the number
FINDING RV-4 neutral C2 is consistency with the lane's own ledger and self-counts, not an external count; candidate leaves ledger and gate untouched, so value 0 is a real calibration here
FINDING RV-5 neutral freeze controls and runner landed in the same commit as the plan, so "written before first run" is not git-provable; all 20 receipts reproduce exactly on re-run
SEAT-STATUS: complete all four counter runs, freeze ancestry, predicate and sha checks, 20/20 control re-run (F6 and F7 included), and adversarial leg reading done; RV-1 not executed end-to-end
