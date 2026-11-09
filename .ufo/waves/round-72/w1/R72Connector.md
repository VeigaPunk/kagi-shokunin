Author: R72Connector (connector)

# Round 72 — connector: sibling overlap, census delta, C1/C2 cross-claim, one bounded move

Lane BASE `b2f3dd661abda0ebd09b3f8ffc3f64904606d4d9`; candidate measured `a947a42c52dc5b64cc9be1eef98207712fca7c42`.
All commands read-only; every citation is a committed byte or a receipt copied into
`.ufo/waves/round-72/w1/R72Connector/`. I ran no C1 live observation (network politeness; the executor and
reviewer seats own that re-run) and did not re-execute the prefreeze controls.

## 1. Census delta — what S174/S175 add (seat question 1)

    scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi     → rc 0, `kagi  ok  …/corpus/SOURCES.md`
    W04 at candidate: 28; round-start receipt (.ufo/waves/round-72/base/census-round-start.stdout.txt): 26

Set difference (`comm` over the W04 id fields) is exactly:

    S174 duplicate url github.com/hashicorp/vault/releases.atom across scopes
    S175 duplicate url github.com/openbao/openbao/releases.atom across scopes

So **two new W04, both "across scopes", zero E-codes, validate status `ok` rc 0**; E04 (an error) would
have fired only if a new row repeated a URL *within* the same `scope` cell without a `supersedes S\d{3}`
in `teaches`. It does not: S174's scope cell ("…for the re-armed derived on-release clocks of S013 and
S022-S024…") differs from S034's ("…for the on-release clocks of S012, S013 and S022-S024…") and from
S089's, and its teaches matches the exemption. Lane instrument unchanged: `bash corpus/sources-census.sh`
on the candidate tree prints `SOURCES_CENSUS: CLEAN (rows=166 …)` rc 0 — the same line as at BASE.

The warning is however *not* one duplicate pair but a chain: the two URLs now carry three and four rows
(S034, S089, S174 for the Vault feed; S035, S090, S175 for the OpenBao feed). Receipt:
`census-cand.tsv`.

## 2. Sibling overlap (seat question 2)

Searched all 20 sibling `*-shokunin` repos (read-only, excluding `.git`/`.ufo`):

- No sibling holds a release-clock gate, a Vault/OpenBao feed row, or re-arm doctrine of kagi's shape:
  `grep -r 'release-clock' <sibling>/{corpus/knowledge,corpus/lessons,corpus/QUALITY.md,SKILL.md}`
  returns only the `recheck: on-release` *cadence label* (chousa, kengaku, kumitate, mori, souji, tabi,
  tsukuroi), and no sibling `corpus/SOURCES.md` carries a `hashicorp/vault/releases` or
  `openbao/openbao/releases` row.
- **Adjacent ground worth citing.** `tabi-shokunin` holds the closest instrument:
  `scripts/check-release-pins.mjs` sweeps the *whole* `on-release` population and reports rows whose pin
  sits below the current stable, with an explicit superseding-row discipline ("drifted → S109"); its
  `corpus/QUALITY.md` #79 rules that *"a counted population is stated as the rule that selects its
  members, in the same place as the count, with every class the rule excludes named and counted"* — the
  correct citation for C1's F-population rule. `kake-shokunin/corpus/knowledge/freshness-sweep.md` and
  `kake …/lessons/round-24.md` hold the re-arm doctrine ("Re-pin only observed targets with receipts …
  removing a recovered token re-arms disappearance detection"). Nothing in a sibling lane grants or
  duplicates kagi's C1/C2 ground.

## 3. Cross-claim: do C1 and C2 interact? (seat question 3)

**No shared counter input.** C1 reads `corpus/release-clocks.tsv`, `corpus/SOURCES.md`,
`corpus/source-fetches.tsv`, `corpus/clock-rearm.tsv`, the round-72 captures/receipt,
`corpus/release-clock.py` and `corpus/sources-census.sh`. C2 reads `corpus/self-counts.py`/`.tsv`
(pinned byte-identical to BASE), `SKILL.md`, `PROVINCE.md`, and through ledger rows R12-03/R21-04
`corpus/stamps.tsv` and `corpus/claim-ledger.tsv`. No population member is shared.

**They do interact through the live counts at integration.** R12-03 is literally
`grep -c '[^[:space:]]' corpus/stamps.tsv` (181 at BASE, at round-71's landed tip
`CLAIM_LEDGER: POLICY (claims=102 policy=5 stamped=181)`, and at the candidate — the candidate does not
touch `stamps.tsv`); R21-04 counts claim rows (102). C1's integration footprint edits *six* already
stamped files (digest audit on the candidate tree: `corpus/release-clock.py`, `corpus/release-clocks.tsv`,
`corpus/source-fetches.tsv`, `corpus/SOURCES.md`, `PROVINCE.md`, `SKILL.md` → `STALE` 6/181), which
forces a stamp pass, and rounds 68–71 each added their frozen counters to the stamp set (round 71:
177 → 181). Adding the four most likely round-72 paths (three counters + `clock-rearm.tsv`) to the
candidate makes the pinned gate print:

    SELF_COUNTS: POLICY (claims=63 stale=3 …)   rc 2
    STALE SC-SKILL-STAMPS SKILL.md:46     claimed=181 live=185
    STALE PV-STAMPS       PROVINCE.md:73  claimed=181 live=185
    STALE RD-STAMPS       corpus/README.md:65 claimed=181 live=185

i.e. `plans/round-72-c2.sh` would read **value=3, rc 1 (missed)** on a landed tree that stamps the
round's own artifacts — unless the three numbers (note: a *third* site, `corpus/README.md:65`, which the
candidate's C2 change does not touch) are written in the same commit that punches the stamps. The
candidate's `value=0` is correct for `a947a42` but is tree-specific: Q2 (candidate + C2 → 0) does not
transfer to the landed revision. Receipts: `c2-cand.txt`, `demo-selfcounts.txt`, `stamps-audit.txt`.

## 4. Findings

- **CN-1** (neutral): the census delta is exactly the two new W04, both across-scope, no E04; the two
  rows make the Vault/OpenBao feed URLs the lane's only three-/four-row chains.
- **CN-2** (falsifies wording): S174's teaches asserts *"the newest stable Vault release is **now**
  v2.2.1"* and S175's *"…**now** v2.7.2"*. S089/S090 — opened 2026-11-05, round 37 — already carried
  exactly those identities and already superseded S034/S035 (`corpus/lessons/round-37.md`: "ADMIT S089 …
  `<title>v2.2.1</title>` … Supersedes S034 (v2.2.0 anchor). The receipt's vault observation 2.2.1
  matches"). The frozen SOURCED leg ("row absent from the BASE registry, `mined`, opened ≥ 2026-11-09")
  is the *only* thing that required a re-opened row: re-pointing the ten derived clocks to S089/S090 with
  the candidate's anchors and receipt, no new registry row, makes the shipped gate print
  `RELEASE_CLOCK: CLEAN (on_release=32 bound=32 unbound=0 observed=32 fired=4 derived=17)` rc 0
  (`repoint-gate.txt`). The number 10 is unaffected; the provenance sentence is not.
- **CN-3** (neutral, quantified hazard): see §3 — C2's 0 is contingent on the integration's stamp choice,
  and a stamp pass turns three bound numbers stale (three sites, not two).
- **CN-4** (neutral): no lane instrument reads the `supersedes` clause (`grep -c supersedes` → 0 in
  `corpus/release-clock.py` and `corpus/sources-census.sh`; the census's E04 exemption is the only string
  match anywhere). That is the structural cause of the lag CN-2 records: opening a successor row re-arms
  nothing, and a clock bound to a superseded row is invisible to every gate. tabi's population sweep
  (`scripts/check-release-pins.mjs` + QUALITY #79) is the adjacent instrument kagi lacks.

## 5. Affected axes

- **Freshness** (C1 axis): CN-2/CN-4 locate the gap the round is closing — a successor feed row does not
  move a clock — and the round's own record currently hides it behind "is now".
- **Calibration** (C2 axis): CN-3 — the self-count target is a function of C1's integration footprint at
  the moment of landing.

Neither axis moves a measured number in this report; both findings are wording/provenance and
sequencing, and the C1 number 10 / C2 number 0 stand as measured on `a947a42`.

## 6. Proposed move (one, bounded, counter-neutral)

**M1 — re-lineage the two new feed rows and record the re-arm lag.** In the integration commit:

1. S174 `teaches`: replace *"supersedes S034 — the newest stable Vault release is now v2.2.1, so the
   derived clocks re-arm at 2.2.1 …"* with *"supersedes S089 (round 37, whose anchor cell already names
   v2.2.1) and re-opens the feed at 2026-11-09 because the four derived Vault clocks stayed bound to
   S034, the row S089 had superseded; re-arms at 2.2.1 and fires again on the next stable tag; sdk/
   module and -rc entries still do not count."* Keep the trailing `Quote: “<title>v2.2.1</title>”`
   sentence verbatim.
2. S175 `teaches`: the same shape against S090/S035 for the six OpenBao clocks, `v2.7.2` unchanged.
3. One section in `corpus/lessons/round-72.md` (already created by the candidate): a supersedes row does
   not move a clock — `derived_anchor_bound` reads only the bound feed row's anchor cell, so S089/S090
   (round 37) re-armed nothing and the ten clocks read `fired` for 35 rounds; C1's SOURCED leg then
   required a re-opened row even though the release identity was current since round 37, so the round
   records a re-bind, not a new release. Cite tabi QUALITY #79 for the population rule.

Anchor cells, clock rows, captures, receipt, `SKILL.md`/`PROVINCE.md` and `stamps.tsv` are untouched.

**Why it is non-obvious:** the round reads its own new rows as the successor ("a successor FEED row
naming the current release (S174, S175)", plan §C1) because that is what the frozen SOURCED leg can
credit; the registry has held the successor since round 37, and the gate accepts it. The move keeps the
counter's 10 and repairs the record that a reader — and the next round — will otherwise re-learn as new.

## 7. Risks

- **Field-shape risk (low).** The edit is inside one table cell: no `|`, no tab, no newline. Verified on a
  dry-run tree: lane census `SOURCES_CENSUS: CLEAN (rows=166 …)` rc 0 and fleet
  `validate --today 2026-11-09 <tree>` → `ok`, 28 W04, no E01/E04 (`m1-fleet-census.tsv`).
- **C1 neutrality (structural, not live).** The counter reads registry `source` (col 2), `status`,
  `opened` and the *anchor* cell (for QM28) and the clock rows' nine fields with a `derived:` note
  prefix; `teaches` is never read. I did not run the C1 live observation to prove it end to end.
- **C2 neutrality (measured).** `bash plans/round-72-c2.sh --tree <dry-run tree>` → `value=0 … stale_ids=none`
  rc 0 (`c2-m1.txt`), identical to the candidate.
- **Census warning count unchanged.** W04 stays at 28: the scope cells are untouched, and E04's exemption
  still matches (`supersedes S089`/`supersedes S090`).
- **Not touched on purpose:** the frozen counters, the plan, `stamps.tsv`, the three declared numbers, and
  the SOURCED leg's new-row requirement (proposing to defeat it would falsify C1 itself).

## 8. Verification (what the integration must run)

1. `bash plans/round-72-c1.sh <landed rev>` → expect `value=10` (unchanged by M1; one live observation).
2. Stamp pass first: re-pin the six stale paths, add the round's new artifacts if the precedent holds;
   then write the live counts into `SKILL.md:46`, `PROVINCE.md:73` **and** `corpus/README.md:65` in the
   same commit, and re-run `bash plans/round-72-c2.sh <landed rev>` → expect `value=0`.
3. `bash corpus/sources-census.sh` → `SOURCES_CENSUS: CLEAN (rows=166 …)`; `scripts/sources-census.sh
   validate --root /home/vgpnk/Projects/shokunin kagi` → `ok`, 28 W04, no E-codes.

FINDING CN-1 neutral census adds exactly two W04 (S174, S175; 26 → 28), both across-scope, no E04, fleet validate ok rc 0
FINDING CN-2 falsifies-wording S174/S175 teach the current release "is now" v2.2.1/v2.7.2; S089/S090 named both on 2026-11-05 (round 37) and the shipped gate reads CLEAN fired=4 when the ten clocks are re-pointed to them, so the new rows add no release identity
FINDING CN-3 neutral C1 and C2 share no counter input, but C2's 0 holds only on a947a42: integration must re-pin 6 stale stamps, and +4 round-72 stamp rows make SKILL.md:46/PROVINCE.md:73/corpus/README.md:65 stale (stale=3, C2 rc 1)
FINDING CN-4 neutral no lane instrument reads the supersedes clause (0 hits in corpus/release-clock.py and corpus/sources-census.sh), so a clock bound to a superseded row is invisible — the 35-round lag; tabi's check-release-pins.mjs population sweep is the adjacent shape kagi lacks
SEAT-STATUS: complete
