# S040/S041 overdue recheck — recheck-cell move (proposal, K47ExecS040)

Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin` (master, BASE `252ef1cac9f41d84639c0d1f211d0e0911196112`, predeclaration
`b020d978bac91284a431710148ebb7a7950eaab8`). Measured 2026-11-06. This file is candidate material only; the L1 applies it,
and only the L1 may edit `corpus/SOURCES.md`.

## 1. Cells to change (old → new)

| id | cell | old | new | mutability |
|---|---|---|---|---|
| S040 | `recheck` | `2026-11-05` | `90d` | contract rule 2: `recheck` changes in place |
| S041 | `recheck` | `2026-11-05` | `90d` | same |

Unchanged on both rows: `status` `mined`, `opened` `2026-10-21`, `used-by` `corpus/lessons/round-26.md`, and every
other cell (id, source, kind, tier, scope, anchor, teaches). No row is added, deleted or reordered.

Why `status` stays `mined`: the contract defines `mined` as cited by ≥1 path in `used-by`, and `corpus/lessons/round-26.md`
line 1 is `source: S039, S040, S041` (measured). Moving either row off `mined` would contradict the definition and make
that lesson's citation fail `SC_ENTRY_CITE`. `opened` is not mutable in place under rule 2, so this round's re-open is
recorded in the round lesson (draft in §7), not in the `opened` cell.

The correction half of rule 2 is already discharged: S095 (`supersedes S040 —`) and S096 (`supersedes S041 —`) exist and
are the live rows for the same teaching, so the remaining in-place move for the superseded rows is the cadence cell.

## 2. Rule text quoted (CORPUS.md §SOURCES.md → Rules, contract v1)

> 2. **Append-only.** Only `status`, `recheck` and `used-by` change in place, and each change is logged old→new in the
> round lesson. A correction is a new row whose `teaches` opens `supersedes S0NN —`.

> - `status` — `queued` (opened, worth mining) · `mined` (cited by ≥1 path in `used-by`) · `rejected` (kept — a
> rejection is evidence of taste).
> - `opened` — ISO date the row's author opened the source. `recheck` — ISO date or cadence (`90d`, `180d`, `on-release`).

The plan's non-claim item (plans/round-47.md, §Non-claim work, last bullet) says: "S040/S041 ISO recheck `2026-11-05` is
overdue at BASE; both are re-opened this round and their recheck cell moves to a cadence (old→new logged in the lesson)."

## 3. Why `90d` and not `on-release` (measured, not assumed)

- The live rows for this teaching are S095/S096 (opened 2026-11-05), both `recheck` `90d`. The superseded rows follow the
  successor's cadence, so a single cadence governs the teaching.
- `corpus/release-clock.py` binds every registry row whose `recheck == "on-release"` to a clock row
  (`on_release = sorted(source_id for source_id, source in sources.items() if source["recheck"] == "on-release")`, then
  missing clock rows become `UNBOUND`). The S040/S041 clock rows were retired in round 46 (`0bd8888`, "S040/S041 retired";
  round-46 lesson line 38: "the gate's only consistent state for an ORPHAN clock is retirement"). Measured counterfactual in
  a scratch copy: both rows set to `on-release` → `RELEASE_CLOCK: FAILED (on_release=31 bound=29 unbound=2 …)`, rc 1,
  with `UNBOUND S040` / `UNBOUND S041`. Re-arming those clocks would also violate C2's frozen kill rule ("must not re-arm
  or re-score a clock").
- `90d` is a contract cadence; the fleet validator accepts it (`E09` absent, rc 0). Due date = `opened` 2026-10-21 + 90d =
  **2027-01-19**; the fleet `overdue` mode reports the row as `cadence`, never as overdue before that date (measured).

## 4. Live re-open, 2026-11-06 (the lane's independent live leg)

`curl -fsSL --max-time 60 -A 'kagi-shokunin-round47/1.0 (documentation verification)'` (curl 8.23.0), UTC wall clock.

| row | url | http | bytes | sha256 | served title |
|---|---|---|---|---|---|
| S040/S095 | https://docs.python.org/3/library/re.html | 200 | 257722 | `29fca9b710ae0c857165f68a8c8e62587862c979e1fe4135037a397a8cdf7cf1` | `<title>re — Regular expression operations &#8212; Python 3.15.2 documentation</title>` |
| S041/S096 | https://docs.python.org/3/library/html.html | 200 | 20100 | `388321714e199e3a93849040754819d21b7ca9b36a5c17748a7218e8f300e615` | `<title>html — HyperText Markup Language support &#8212; Python 3.15.2 documentation</title>` |

Fetch window 2026-11-06T19:34:32Z–19:34:32Z; time_total 0.137951 s / 0.133202 s.

Quote location (`python3 corpus/rendered-text-v1.py locate <fresh body> <column-13 quote>`):

| row | column-13 quote (source-fetches.tsv) | locate |
|---|---|---|
| S040 | `Matches Unicode whitespace characters (as defined by str.isspace() ).` | `count=1`, rc 0 |
| S041 | `This function uses the rules defined by the HTML 5 standard for both valid and invalid character references` | `count=1`, rc 0 |
| S095 | `<title>re — Regular expression operations &#8212; Python 3.15.2 documentation</title>` (raw-literal-v1) | `count=0`, rc 1 |
| S096 | `<title>html — HyperText Markup Language support &#8212; Python 3.15.2 documentation</title>` (raw-literal-v1) | `count=0`, rc 1 |

The S095/S096 zeros are by construction, not drift: their declared normalizer is `raw-literal-v1` and the tag-bearing
quote cannot survive rendered-text-v1's tag-removal step. The same strings occur exactly once as raw fixed strings
(`grep -c -F` = 1 each), the inner text locates `count=1` under rendered-text-v1, and the recorded raw offsets still hold:
re offset 75897 → `Matches Unicode whitespace characters (as defined by <a clas…`; html offset 13521 → `This function uses
the rules defined by the HTML 5 standard\n`.

Body volatility vs the committed 2026-11-05 captures (`.ufo/waves/round-40/capture/S095.body`, `S096.body`, whose sha256
equals the `source-fetches.tsv` column-10 values): the only difference is the footer line
`Last updated on Nov 05, 2026 (12:47 UTC).` → `Last updated on Nov 06, 2026 (17:47 UTC).` — same length, hence identical
byte counts with different sha256. The rows declare `decoded-http-body-volatile-v1`; the teaching text is unchanged.

Observation (no action): the two rows' `anchor` cells name "title Python 3.15.1 documentation" while the served title is
3.15.2. `anchor` is not mutable in place under rule 2; that stale identity is exactly why the successor rows S095/S096
(3.15.2) were written, and they carry the current teaching at `90d`.

## 5. Scratch test — archive of BASE `b020d97` (three named gates + supporting overdue read)

`git -C <lane> archive b020d978… | tar -x -C lane-base`, copied to `lane-prop`; the proposal is the two cell edits above.
Scratch root `/fast/scratch/hyaku/kagi-r47/K47ExecS040`. All gates ran in the scratch copy, never in the lane.

| gate | BASE copy | proposal copy |
|---|---|---|
| `bash corpus/sources-census.sh` | rc **1**, `SOURCES_CENSUS: FAILED (findings=3 rows=102)` | rc **1**, `SOURCES_CENSUS: FAILED (findings=3 rows=102)` |
| `python3 corpus/release-clock.py` | rc **0**, `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)` | rc **0**, `RELEASE_CLOCK: CLEAN (on_release=29 bound=29 unbound=0 observed=29 fired=13 derived=15)` |
| `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --file <copy>/corpus/SOURCES.md` | rc **0**, last line `file<TAB>ok<TAB><copy>/corpus/SOURCES.md` (19 W04 duplicate-url warnings) | rc **0**, same last line shape, 19 W04 warnings |
| `… sources-census.sh overdue --file <copy>/corpus/SOURCES.md` (supporting) | rc **1**, `file<TAB>overdue<TAB>S040 1d recheck=2026-11-05 opened=2026-10-21` and `S041 1d …` | rc **0**, `file<TAB>cadence<TAB>S040 recheck=90d opened=2026-10-21` and `S041 recheck=90d opened=2026-10-21` |

The census finding set is byte-identical between the copies (diff empty): the three findings are the pre-existing C1
findings (`SC_USEDBY_NOCITE S094 round-43.md`, `SC_USEDBY_NOCITE S099 round-44.md`, `SC_FETCH S099 missing-provenance`),
which this item neither fixes nor worsens. The recheck move changes no status, so the C1 counter's INTACT test is
unaffected.

Counterfactual (rejected alternative), same scratch copy:

| variant | reading |
|---|---|
| S040/S041 `recheck` → `on-release` | rc **1**, `UNBOUND S040` / `UNBOUND S041`, `RELEASE_CLOCK: FAILED (on_release=31 bound=29 unbound=2 observed=29 fired=13 derived=15)` |

So `on-release` is falsified by the required gate CLEAN; `90d` is the admissible cadence.

## 6. S027/S028 successor chain check (requested)

Measured on BASE bytes:

| link | status | recheck | supersedes | used-by (exists, cites id on `source:`) |
|---|---|---|---|---|
| S027 | mined | `on-release` | — | `corpus/lessons/round-24.md` |
| S040 | mined | `2026-11-05` → `90d` | S027 | `corpus/lessons/round-26.md` |
| S095 | mined | `90d` | S040 | `corpus/lessons/round-40.md` |
| S028 | mined | `on-release` | — | `corpus/lessons/round-24.md` |
| S041 | mined | `2026-11-05` → `90d` | S028 | `corpus/lessons/round-26.md` |
| S096 | mined | `90d` | S041 | `corpus/lessons/round-40.md` |

Result: both chains are complete and one-directional, every link's `teaches` opens `supersedes S<prev> —`, every
`used-by` file exists and carries the id on its column-1 `source:` line (the census reports no `SC_USEDBY_NOCITE` /
`SC_ENTRY_CITE` for any of the six ids), and no row is a duplicate. Clock ledger: S027 and S028 keep `on-release` (the
round-39 decision for superseded rows) and their `feed` clock rows are `fired` (anchored 3.15.0, observed 3.15.2,
re-observed by the pinned round-46 receipt) and `bound`; S040/S041 clock rows are retired (round 46), so their rows must
not be `on-release`; S095/S096 make no clock claim (`90d`). Gate CLEAN confirms this composition (`on_release=29
bound=29 unbound=0`).

Two observations, neither a gate finding:
1. The S027/S028 clock notes still read "rearmed successor S040 carries its own named 3.15.1 anchor". That is still true
   of the *registry anchor* (S040's anchor names the 3.15.1 documentation), while the *feed clock* for S040/S041 was
   retired in round 46; SKILL.md:48 and PROVINCE.md:75 already document the retirement, so no doc contradicts the ledger.
   The note is append-only history and needs no change.
2. S027/S028 remain `fired` by design (their anchored 3.15.0 teaching is superseded, not re-armed); the current teaching
   is re-verified through S095/S096, so nothing is stale.

## 7. Ready-to-append lesson log (draft; L1 owns the lesson file)

> - **Registry change, logged old→new.** `corpus/SOURCES.md` S040 and S041: `recheck` `2026-11-05` → `90d`. Both rows
>   were re-opened live this round (2026-11-06): both pages serve `<title>… Python 3.15.2 documentation</title>` and the
>   S040/S041 column-13 quotes locate at count 1 in the fresh bodies (S095/S096 raw-literal quotes: raw fixed-string
>   count 1, recorded offsets 75897/13521 hold; rendered-text locate 0 for the tag-bearing form by construction). `status`
>   (`mined`), `used-by` (`corpus/lessons/round-26.md`), `opened` (`2026-10-21`) and every other cell unchanged; the
>   successors S095/S096 were already in place, so no row was added. `90d` (not `on-release`): the S040/S041 clock rows
>   were retired in round 46 and an `on-release` cell now fails `release-clock.py` with `UNBOUND S040` / `UNBOUND S041`
>   (measured rc 1); `90d` matches S095/S096 and keeps the gate CLEAN (measured rc 0).

## 8. Apply checklist (L1)

1. Edit only the two `recheck` cells; leave `status`, `opened`, `used-by`, `anchor`, `teaches` untouched.
2. Append the §7 log line to the round-47 lesson.
3. Re-run the three gates on the candidate; expected: census findings unchanged from BASE (the three C1 findings remain
   until C1's own edits land — the L1 measures them together), `RELEASE_CLOCK: CLEAN`, fleet validate `ok`.
4. Do not re-arm, retire or re-score any `corpus/release-clocks.tsv` cell; do not change `source-fetches.tsv`.
