# Round 53 C1 — critic (falsification) — seat R53CriticC1

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (branch `master`).
BASE `c1953d4afc19a5a336a58685c00ab5260bcfea1c`; CANDIDATE `36d0a86a7539890eb079d893c9a58e37e84d953d`.
Counter attacked: `plans/round-53-c1.sh` (`--tree <dir>` with `C1_ASOF=$(date +%s)`, and revision mode).
Frozen predicate quoted from the counter header:
`C1_CURRENCY_CLOCKS: value = number of ids in F that are WATCHED, when GATE = 1, else 0; target 2 (BASE 0).`
Scratch: `/fast/scratch/hyaku/kagi-r53/R53CriticC1/` (trees `base/`, `cand/`, fixtures `fx/`,
extracted archive `fx5b-extract/`, build+runner scripts).
Receipt of every measured line: `.ufo/waves/round-53/build/R53CriticC1-receipts.txt`, assembled from
the per-batch parts `R53CriticC1-receipts-part{A,B,C,D1,D2}.txt` in the same directory (exact
commands and exit codes; the last line of each gate run included).

No lane file was modified by this seat: the only writes are
`.ufo/waves/round-53/build/R53CriticC1.md` and `.../R53CriticC1-receipts.txt` plus scratch.
No secret, key, vault or account was read or contacted; the only network reads were two plain
GETs of public Atom feeds (§7), no form posts, no logins, no writes to any remote.

## 1. Baselines (measured before any fixture)

| tree | counter line |
|---|---|
| candidate `36d0a86a`, revision mode | `C1_CURRENCY_CLOCKS: value=2 watched=2 gate=1 guard=1 (ok=S103 S104; bad=; gate-line=RELEASE_CLOCK: CLEAN (on_release=31 bound=31 unbound=0 observed=31 fired=13 derived=17))` |
| candidate `36d0a86a`, `--tree` | same line, `value=2` |
| BASE `c1953d4a`, revision mode | `C1_CURRENCY_CLOCKS: value=0 watched=0 gate=1 guard=1 (ok=; bad=S103:recheck=90d S104:recheck=90d; gate-line=RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15))` |
| BASE `c1953d4a`, `--tree` | same line, `value=0` |

## 2. Forgery table

Class legend — **CEILING**: inside plan §C1 *Named ceilings* ("a self-consistent forged receipt
whose digest is written into the gate scores"); **DEFECT**: scores (or would score) outside that
sentence, i.e. the counter accepts something the predicate's own words claim it checks;
**NONE**: attack blocked, no defect.

| id | edit | counter | gate | class |
|---|---|---|---|---|
| fx1-invented-receipt | BASE + S111 row + 2 clock rows + S103/S104 `90d`→`on-release` + gate line 28 digest + line 547 `round-46`→`round-53`; receipt is `cand`'s *shape* but **all 31 `sha256` replaced by `sha256("forged-body:<id>")`** and S103/S104 `observed_at` invented (`2026-11-07T00:01:00Z`); no fetch performed | **2** | CLEAN | CEILING |
| fx2-reused-record | cand; S104 receipt record := S103's record with `url`→age feed and `parsed_version`→`1.3.2`; the **SOPS body digest `47a224ad…` and S103's stamp `03:02:39Z` stay**; new receipt digest into line 28 | **2** | CLEAN | CEILING (field-level) |
| fx3-relocated-receipt | cand; line 547 → `round-99/final/obs.json`, `.ufo/waves/round-53/final/observe-r53.json` **deleted**, invented receipt at `round-99` | **2** | CLEAN | **DEFECT** (receipt path unpinned) |
| fx14-renamed-receipt | cand; receipt renamed to `.ufo/waves/round-53/final/r53-final.json`, line 547 follows (same bytes, same digest) | **2** | CLEAN | **DEFECT** (basename unpinned) |
| fx5-symlink-dir | cand; `.ufo/waves/round-53/final` → absolute symlink to a scratch dir holding a receipt with every `sha256` invented | **2** | CLEAN | **DEFECT** (containment) |
| fx5b-committed-symlink | cand; **committed** symlink `final`→`../round-46/final` (git mode `120000`), forged receipt at `.ufo/waves/round-46/final/observe-r53.json`; measured from `git archive HEAD \| tar -x` | **2** | CLEAN | **DEFECT** (containment) + CEILING (content) |
| fx9-future-receipt | cand; S104 `observed_at` in receipt **and** TSV → `2026-12-31T00:00:00Z` | **1** with `C1_ASOF=$(date +%s)` (`S104:receipt-time-window`); **2** with `C1_ASOF=1900000000` | CLEAN both | **DEFECT** in `--tree` (upper bound is caller-supplied) |
| fx12-fenced-row | cand; the S111 registry row moved **inside a ```` ```text ```` fence** (the only S111 row) | **2** | CLEAN (`sources-census.sh` also CLEAN, `rows=111`) | **DEFECT** (fence-blind registry read) |
| fx13-no-capture | cand; `.ufo/waves/round-53/capture/S111.body` **deleted**, receipt untouched | **2** | CLEAN | **DEFECT** (receipt `sha256` never linked to a body; sibling `quote-locate.py` → `NOT-LOCATED S111 body-missing`, `QUOTE_LOCATE: FAIL located=8 rows=9`) |
| fx4-symlink-file | cand; the receipt *file* is a symlink to a scratch copy | 0 (`S103/S104:receipt-missing`) | CLEAN | NONE (counter stricter than gate) |
| fx6-feed-onrelease | cand; S111 `recheck`→`on-release` | 0 (`S104:feed-recheck`) | FAILED (`BADFEED S104`, `UNBOUND S111`) | NONE |
| fx7-lookalike-feed | cand; S111 URL **and** S104 `feed_url` **and** receipt `url` → `https://github.com/FiloSottile/age/releases.atom/` | 1 (`S104:feed-url`) | **CLEAN** | NONE in the counter — but the gate alone would accept it; the counter is the only URL pin |
| fx8a-empty-note | cand; S104 clock row note emptied (9 fields, last empty) | 0 (`watched=2`, `gate=0`) | FAILED (`INCONSISTENT S104`) | NONE scored; latent counter weakness (note unchecked) |
| fx8b-extra-tab | cand; S104 clock row + one trailing TAB (10 fields) | 0 (`S104:clock-fields`) | FAILED | NONE |
| fx10-dup-receipt-record | cand; a second S104 observation appended to the receipt | 0 (`S104:receipt-records=2`) | FAILED | NONE |
| fx11-dup-clock-row | cand; a second S104 clock row appended | 0 (`S104:clock-rows=2`) | FAILED | NONE |

Counts: **9 fixtures produced a scoring value without a genuinely watched pin** (fx1, fx2, fx3,
fx14, fx5, fx5b, fx9-with-inflated-ASOF, fx12, fx13); 4 of those 9 are inside the declared ceiling,
**7 are counter defects** (fixture rows; 5 defect classes). 7 fixtures were blocked.
Rebuild check: `build2.py` regenerated fx10…fx14 and the fx5b tree deterministically — the forged
receipts reproduce byte-identically (fx5b `700a4cc9840c0879…`, fx14 = the candidate's
`f927b4318dee90ad…`) and the six re-measured fixtures returned the same lines (receipts part E).

## 3. Scoring forgeries in detail

### fx1 — a tree with no fetch at all reads 2 (CEILING)
`diff` against BASE (4 files, the complete change):
```
corpus/SOURCES.md        S103,S104: `| mined | 2026-11-06 | 90d |` -> `| … | on-release |`
                         + the S111 row (appended after the last registry row)
corpus/release-clocks.tsv + the two 9-field feed rows (S103→S033/3.13.3, S104→S111/1.3.2)
corpus/release-clock.py  line  28: DEFAULT_RECEIPT_SHA256 = "e0d2ebb8…"   (was "6091c529…")
                         line 547: round-46/final/observe-r46.json -> round-53/final/observe-r53.json
.ufo/waves/round-53/final/observe-r53.json
                         all 31 records: sha256 := sha256("forged-body:<id>")
                         S103,S104: observed_at := 2026-11-07T00:01:00Z
```
Result: `value=2 watched=2 gate=1 guard=1`, gate `CLEAN (… observed=31 …)`. The receipt contains no
digest of any body that ever existed, and neither the counter's `receipt_check` nor the gate's
`receipt_matches`/`load_receipt_bundle` compares the `sha256` field with anything: both check only
`[0-9a-f]{64}`. This is exactly the declared ceiling, and it is broader than the ceiling sentence
suggests: *every* record's digest can be invented, not only the two.
It also proves the three-line GUARD allowance is what lets a forger move the default receipt
(`line 547`), which §5 turns into a defect when used for fx3/fx5b.

### fx2 — S104's record is S103's record with two fields rewritten (CEILING)
```
-  "sha256": "32517112…" , "observed_at": "2026-11-07T03:02:40Z", "id": "S104"
+  "sha256": "47a224ad…" , "observed_at": "2026-11-07T03:02:39Z", "id": "S104"
+  "url": "https://github.com/FiloSottile/age/releases.atom", "parsed_version": "1.3.2"
```
The record still carries the **SOPS feed body digest** and the SOPS observation second, yet the
counter reports `value=2` and the gate `CLEAN`. So the receipt's `sha256`/`observed_at` fields are
not evidence at all; only `id/url/parsed_version/verdict/observed_at-date` are read, and the date is
compared at day granularity.

### fx3 / fx14 — the declared receipt need not exist (DEFECT)
`predicate (d)` says "the default receipt the measured corpus/release-clock.py names (the path in
`receipt_path`, the digest in `DEFAULT_RECEIPT_SHA256`)". GUARD excludes line 547 and the regex on it
accepts **any** `round-[0-9]+/final/[A-Za-z0-9._-]+\.json`, so:
* fx3: line 547 → `round-99/final/obs.json`, `.ufo/waves/round-53/final/` emptied → `value=2`;
* fx14: same bytes, file renamed `r53-final.json` → `value=2`.
Plan §C1 §Change does declare `.ufo/waves/round-53/final/observe-r53.json`, and the kill rules
compare that exact path, so a *reviewer* catches both; the counter does not. This is the third of
the three "allowed" lines being used for something other than the declared artifact.

### fx5b — the receipt bytes live outside the declared directory, through a committed symlink (DEFECT)
```
$ git -C fx/fx5b-committed-symlink ls-tree HEAD .ufo/waves/round-53/
100644 blob 677e81e1…  .ufo/waves/round-53/expectation-migrations.json
120000 blob 944f9251…  .ufo/waves/round-53/final
$ git -C … archive HEAD | tar -x -C fx5b-extract   # symlink survives the archive step
$ C1_ASOF=$(date +%s) bash plans/round-53-c1.sh --tree /…/fx5b-extract
C1_CURRENCY_CLOCKS: value=2 watched=2 gate=1 guard=1 (ok=S103 S104; … RELEASE_CLOCK: CLEAN …)
```
`receipt_check` rejects a symlinked *file* (`p.is_symlink()`, fx4 → 0) but not a symlinked *parent*:
`p.is_file()` follows the directory component, so "exists in the measured tree with that sha256" is
satisfied by `.ufo/waves/round-46/final/observe-r53.json`. A reviewer running
`git show <rev>:.ufo/waves/round-53/final/observe-r53.json` gets a 17-byte symlink blob, not the
receipt; the kill rule's byte comparison of that path therefore fires only if the reviewer notices
the mode. fx5 is the absolute-path variant (works only while the scratch target exists); fx5b is the
realistic, self-contained variant.

### fx9 — `--tree`'s time window is caller-supplied (DEFECT in the mode, not in the claim)
Same fixture, two runs:
```
C1_ASOF=$(date +%s)  -> value=1 … bad=S104:receipt-time-window   (gate CLEAN)
C1_ASOF=1900000000   -> value=2 watched=2 gate=1 guard=1         (gate CLEAN)
```
The lower bound (`2026-11-07T00:00:00Z`) is hard-coded, the upper bound is `C1_ASOF` — an environment
variable the caller sets, never cross-checked against `date +%s`. So the predicate's
"observed … no later than the measured commit" is enforced only as "no later than what the claimant
declares". With the seat's declared invocation (`C1_ASOF=$(date +%s)`) the candidate is unaffected;
the defect matters to anyone reproducing the number with a future or stale `C1_ASOF`. In revision
mode the same edge comes from the commit's committer time (`git show -s --format=%ct`), which the
committer chooses (`GIT_COMMITTER_DATE`); I could not exercise that leg because
`bash plans/round-53-c1.sh <rev>` only accepts revisions reachable in the lane (fixture-repo commits
read `SETUP bad-revision`, measured), so I state it as a property of the code and not as a run.

### fx12 — the authorising row exists only inside a code fence (DEFECT, low severity)
The single S111 row is moved inside a ```` ```text ```` block. Both the counter's `row()` and the
gate's `parse_sources()` read with `line.strip().startswith("|")` and no fence state, and
`corpus/sources-census.sh` is fence-blind as well (`SOURCES_CENSUS: CLEAN (rows=111 …)`), so all
three authorities count a row that the rendered `corpus/SOURCES.md` does not show. Counter: `value=2`,
gate `CLEAN`. The pin itself is still real content (URL, kind `code`, `mined`, not on-release), so the
damage is documentation-visible-only; the fix belongs in the parsers, not in the claim.

### fx13 — no evidence linkage: the capture body is decorative (DEFECT, bounded by a sibling gate)
`rm -rf .ufo/waves/round-53/capture` → counter `value=2`, gate `CLEAN`; the sibling round-38 gate
notices: `NOT-LOCATED S111 body-missing` / `QUOTE_LOCATE: FAIL located=8 rows=9`. The C1 counter and
its GATE therefore cannot tell a receipt from an invented one even when the body it names is absent.
Measured fact that matters for the candidate: its receipt **is** backed —
`sha256(.ufo/waves/round-53/capture/S111.body) = 32517112…` equals the S104 record's `sha256`, and the
S103 record's `47a224…` equals the committed `.ufo/waves/round-46/build/K46ScoutFeeds-receipts/sops.body`
(253 037 B, a real `getsops/sops` Atom feed). So a corrected counter that required a body could pass
the candidate as landed (see C-ii).

## 4. Blocked attacks — where the counter is stronger than its own GATE

* **fx7**: with the S111 row, the S104 `feed_url` and the receipt `url` all moved to the lookalike
  `https://github.com/FiloSottile/age/releases.atom/`, the gate is **CLEAN** (it has no expected-URL
  knowledge; it only requires `feed_source["url"] == feed_url`), and only the counter's literal pin
  rejects it (`S104:feed-url`). Consequence for the claim: `GATE = 1` is not evidence that a clock
  watches the pinned feed; the counter's `WATCHED` letters (a)–(c) are the load-bearing part.
* **fx4**: a symlinked receipt *file* → counter 0 while the gate is CLEAN. The counter's
  `p.is_symlink()` is stricter than the gate's `os.path.lexists` + `read_bytes`.
* **fx6, fx8b, fx10, fx11**: rejected by both the counter and the gate (`feed-recheck`,
  `clock-fields`, `receipt-records=2`, `clock-rows=2`); these are the counter's healthiest checks.
* **fx8a** (latent): with the clock row's note emptied, the counter reports `watched=2` (it never
  reads `note`, `observed_version`, `observed_at` or `verdict` from the TSV row) and only the gate's
  `derived:`/anchor check turns the value into 0. If a future round's gate lost that check, the
  counter alone would score a row that asserts nothing about *why* the pin is the anchor.

## 5. What the ceiling covers, and what it does not

Plan §C1 *Named ceilings*: "the counter checks committed bytes; a self-consistent forged receipt
whose digest is written into the gate scores (the non-author live re-fetch of both feeds is the check
that catches it)".

Covers: **fx1, fx2, and the content half of fx5b** — a receipt that is internally consistent with the
TSVs and whose digest is written into line 28. The ceiling is therefore *complete for content*: no
amount of receipt hygiene changes the value, and §7 shows the only real check is the live re-fetch.

Does not cover (these are defects, not ceiling):
1. **fx13** — the claim "the receipt holds an observation of the feed" implies evidence; no
   committed body is required and no `sha256` field is ever compared.
2. **fx5b / fx5** — "exists in the measured tree" is claimed and not enforced (parent-directory
   symlink).
3. **fx3 / fx14** — the declared artifact is unnamed by the counter (any `round-N/final/*.json`).
4. **fx9** — the upper time bound is the claimant's number.
5. **fx12** — "exactly one row for id" includes rows that render as code, not as registry.

## 6. Smallest safe corrections (all local, no new authority)

* **C-i (path/containment, kills fx3, fx14, fx5, fx5b).** In `plans/round-53-c1.sh`'s
  `receipt_check` python block, after the two `re.fullmatch` captures, require
  `m2.group(1) == "round-53"` and `m2.group(2) == "observe-r53.json"`, and require
  `os.path.realpath(p.parent) == os.path.realpath(t + "/.ufo/waves/round-53/final")` **and**
  `not os.path.islink(t + "/.ufo/waves/round-53/final")`. Five lines; the counter already knows both
  constants from the predicate text.
* **C-ii (evidence link, kills fx13, raises fx1's cost).** For each watched id require the record's
  `sha256` to equal the digest of a **committed regular file** in the measured tree (content-addressed
  lookup, or the body named for the feed row `S033`/`S111` in `corpus/quote-bodies.tsv`). Compatibility
  measured: the candidate passes either form — `S111.body` (round 53) for S104, the round-46 retained
  `sops.body` for S103. This makes C1 assert the same evidence `corpus/quote-locate.py` already reasons
  over, without duplicating its quote logic.
* **C-iii (ASOF, kills fx9's inflated leg).** `[ "$C1_ASOF" -le "$(date +%s)" ]` (or clamp to `now`),
  in the `--tree` branch only; the revision branch is already bounded by the commit.
* **C-iv (fences, kills fx12).** Skip lines between ``` ``` ``` fences in `row()` and in the gate's
  `parse_sources()`; without the gate change the two authorities would disagree.
* **C-v (latent, fx8a).** In the counter's per-id block, when the clock row's note starts with
  `derived:` require more than the tag, and require the feed row's `anchor` to name the pin (the gate
  already does this via `derived_anchor_bound`; the counter does not).

None of C-i…C-v changes the candidate's measured `value=2` (C-i/C-ii were checked against the
candidate's own bytes as they stand; C-iii/C-iv/C-v are no-ops on the candidate tree).

## 7. Non-author live re-observation (plain GET, 2026-11-07, no login, no POST)

| feed | HTTP | newest stable entry | entry `<updated>` | pin |
|---|---|---|---|---|
| `https://github.com/FiloSottile/age/releases.atom` | 200 | `age v1.3.2` | `2026-08-29T18:12:38Z` | **1.3.2 — holds** |
| `https://github.com/getsops/sops/releases.atom` | 200 | `v3.13.3` | `2026-07-23T05:29:11Z` | **3.13.3 — holds** |

So the claim's *content* (both tags are still the current stable releases) survives the only check
the ceiling names, and the candidate's `not-fired` verdicts are correct as of this read. This leg is
also what makes fx1/fx2 harmless in practice: the transplanted bytes happen to be true today, and a
forger gains nothing by them beyond skipping the fetch.

One **provenance defect** found by that comparison, independent of the counter:

* `corpus/SOURCES.md:118` (S111 evidence cell) and `corpus/lessons/round-53.md:16` state "the entry's
  `<updated>` is **2026-08-29T17:55:50Z**". The committed capture contradicts it:
  `parse(<entry>)` over `.ufo/waves/round-53/capture/S111.body` gives
  `('age v1.3.2', 2026-08-29T18:12:38Z)` and `('age v1.3.1', 2026-08-29T17:55:50Z)` — the quoted
  stamp is **v1.3.1's**, one entry below, as the live feed also shows. The tag page is not the
  source of the confusion either: `https://github.com/FiloSottile/age/releases/tag/v1.3.2` (plain
  GET, 2026-11-07) says "released this 29 Aug 17:55", so S104's own cell is right, and v1.3.2's
  feed entry was *edited* 17 minutes after publication (18:12:38Z). The lesson's parenthetical
  ("the same release day the S104 tag page shows") shows the two times were conflated. The same
  wrong stamp is copied into the controls overlay
  `.ufo/waves/round-53/controls/fixtures/ref/c1/corpus/SOURCES.md:118`.
  No counter letter reads it (neither `WATCHED` (c) nor the gate's `derived_anchor_bound` looks at
  the date), so `value=2` is unaffected — but the row's evidence sentence is false while every gate
  is green, which is the failure mode C1 exists to prevent. Smallest correction: in the row and the
  lesson, either drop the timestamp (keep title + tag link + `updated` from the feed) or replace it
  with `2026-08-29T18:12:38Z`; mirror the correction in the controls overlay copy.

## 8. Verdict for the canonical judge

* **C1 is not falsified by the assignment's named attempts.** The hand-forged receipt with the
  digest written into line 28 (fx1) and the S104 record copied from S103 (fx2) land inside the
  declared ceiling; the lookalike S111 URL (fx7), the `on-release` feed row (fx6) and the trailing-TAB
  clock row (fx8a/fx8b) are all rejected (`value=1/0/0`), and fx7 shows the counter is *stricter*
  than its own gate. The two remaining named shapes do score: "the three allowed lines used to point
  at a receipt outside `.ufo/waves/round-53`" (fx3, plus the same-family fx14) and "symlinked receipt"
  (fx4 is blocked as a file, but fx5/fx5b score through a symlinked parent directory). Those two are
  counter defects caught only outside the counter (kill rule / review).
* **Nine scoring forgeries exist**, seven of them outside the ceiling (fx3, fx14, fx5, fx5b, fx9,
  fx12, fx13 — five defect classes). None of them changes the candidate's
  measured value: the candidate's receipt is at the declared path, is backed by two committed
  bodies, and the live feeds confirm both pins. They are prospective hardening items (C-i…C-v), not
  grounds to reject the candidate.
* **Impacted axes:** C1 freshness only. C2 is untouched — this seat wrote no lane byte outside
  `.ufo/waves/round-53/build/`, so the C2 self-count readings cannot move. The one claim-level
  defect that is *not* about the counter (§7, the S111 `<updated>` stamp) sits on the freshness axis
  and should be fixed in this round's artifact.
* The counter's `GATE` leg is insufficient on its own: fx4, fx7 and fx8a are all `RELEASE_CLOCK:
  CLEAN` trees the counter rejects, so `gate=1` must never be quoted as evidence by itself.

## 9. Reproduction

```bash
S=/fast/scratch/hyaku/kagi-r53/R53CriticC1
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive c1953d4a | tar -x -C $S/base
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 36d0a86a | tar -x -C $S/cand
python3 $S/build.py  $S          # fx1..fx9  (prints the diff -u of every changed file)
python3 $S/build2.py $S          # fx10..fx14 + the fx5b tree
# fx5b archive leg (fixture repo; toplevel asserted before any commit)
D=$S/fx/fx5b-committed-symlink
git -C "$D" init -q && [ "$(git -C "$D" rev-parse --show-toplevel)" = "$D" ]
git -C "$D" add -A && git -C "$D" -c user.name=r53critic -c user.email=r53critic@example.invalid \
    commit -q -m "fx5b" && mkdir -p $S/fx5b-extract && git -C "$D" archive HEAD | tar -x -C $S/fx5b-extract
bash $S/one.sh fx13-no-capture  # one measured block (counter + gate)
bash $S/runner.sh               # the whole sweep, exactly the lines in R53CriticC1-receipts.txt
```
Both builders construct the fixtures programmatically (they rewrite line 28 to the digest of the new
receipt, and line 547 for fx3/fx14/fx5b), and `build.py` prints the exact `diff -u` of every changed
file; the fixtures are generated artifacts under scratch, never lane files. `build2.py` also builds
fx5b as a prepared tree, but its measured leg is the archive extraction above, which is what the
receipt file records.
