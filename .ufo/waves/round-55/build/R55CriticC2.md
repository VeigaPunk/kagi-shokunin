# R55CriticC2 — attack on C2 (freshness: ISO/IEC 11770-3 amendment + recheck clock)

Measured revision `348aa3b8ea7298aeb2f4d69db321fe827a92ae4f` (candidate, `git rev-parse`),
BASE `ebe095857a734caf5efdd7bd776feb22b4e23972`, predeclaration
`f2b986fadd8f8551e760cc89f59e0ae0edb0d499`. Counter attacked:
`plans/round-55-c2.sh`, driven as `bash plans/round-55-c2.sh --tree <dir>` on trees exported
from the candidate into scratch. Scratch `$HYAKU_SCRATCH/kagi-r55/R55CriticC2/`
(`/fast/scratch/hyaku/kagi-r55/R55CriticC2`), receipts in `R55CriticC2.d/`.

Reference readings (receipt `R55CriticC2.d/c2-base-and-candidate.txt`):

```
BASE       C2_ISO_CURRENT: value=0 amd=0 recheck=0 guard=1 (bad=amd:a-rows=0,recheck:S101-count-2-stated-1)
candidate  C2_ISO_CURRENT: value=2 amd=1 recheck=1 guard=1 (bad=none)
```

The candidate's reading reproduces. The counter file is unchanged between predeclaration and
candidate (`git diff --quiet` over the four frozen files, `rc=0`; receipt `kill-rule.txt`).

## What the counter actually measures

Per its frozen definition: AMD = one `mined`/A/2026-11-07 row carrying the AMD URL, a fetch row and
capture whose sha is the frozen `AMDSHA`, a quote-bodies row at byte offset, **and some line of the
entry outside the `source:` field that contains the string `ISO/IEC 11770-3:2021/Amd 1:2025` and a
`[S114]` bracket**; RECHECK = ≥1 backticked `curl '<URL>' | grep -c '<Q>'` -> N with N equal to
the number of capture lines containing Q as a byte string, and no such command false; GUARD =
S100/S101/S102 rows identical to BASE + S101 capture sha + census CLEAN.

So AMD measures *presence of an identifier string plus a citation*, and RECHECK measures *no
command whose stated number disagrees with a byte-substring count*. Neither measures the polarity
of the entry's statement, the sentence the citation supports, nor that the clock discriminates.

## Attack table (all runs: `bash plans/round-55-c2.sh --tree <variant>`; full log `R55CriticC2.d/attack-table.txt`)

| # | mutation (tree under `$S/<name>`) | observed | verdict |
|---|---|---|---|
| v0 | none (candidate export) | `value=2 amd=1 recheck=1 guard=1` | reference; candidate is honest (see §Candidate is not false) |
| v1 | BASE entry body **unchanged**; S113/S114 appended to `source:`; recheck corrected; one trailing `<!-- ISO/IEC 11770-3:2021/Amd 1:2025 [S114] -->` | `value=2 amd=1 recheck=1 guard=1` | **FALSIFIES.** The landing section is entirely absent; the stale sentence "names a newer amendment … the newer amendment's content is outside this entry" is intact. Diff vs BASE is exactly 2 header lines + 1 comment (`R55CriticC2.d/v1-stale-body.txt`) |
| v1b | same, token placed on the `ground:` header line | `value=2` | **FALSIFIES** (same class, header field instead of a comment) |
| v2 | honest section replaced by "the text in force is …/Amd 2:2026 [S113]; …/Amd 1:2025 [S114] was withdrawn in 2026-02 and must not be applied" | `value=2` | **PREDICATE-ACCEPTED tradeoff**: byte-level counter cannot read "in force" vs "withdrawn"; the claim's name ("names the amendment in force") overstates what is measured |
| v3 | recheck Q = `ISO` (40 lines) and `e` (797 lines), stated counts true, both quotes non-discriminating | `value=2` | **hole**: the clock can no longer detect any change; named ceiling, but see §Ceilings — the named escape cannot detect this either |
| v4 | recheck Q = `60.60`, stated 1 (S101) and 3 (S113) = the counter's byte-substring counts; the command as written prints **2** and **4** (`grep` reads Q as a BRE, `.` matches any byte) | `value=2` | **DEFECT, unnamed**: RECHECK's definition says "what `grep -c` prints"; it does not. Measured: `grep -c '60.60' S101.raw`=2, `S113.body`=4 vs literal 1/3 (`R55CriticC2.d/counts-and-hashes.txt`) |
| v5 | one paragraph: "The successor … [S114] is not examined here. ISO/IEC 11770-3:2021/Amd 1:2025 is not examined in this entry and its status is not established." | `value=2` | **FALSIFIES** (paragraph bridge): citation and identifier need not share a statement, let alone support one |
| v6 | S114 tier `A`→`B` | `value=1 amd=0` | self-punishing; conjunct (a) sound |
| v7 | duplicate quote-bodies row for S114 | `value=1 amd=0` (`bad=amd:c`) | self-punishing; uniqueness sound |
| v8 | second column-1 `recheck:` line | `value=1 recheck=0` | self-punishing; the frozen "exactly one column-1 line" rule holds |
| v9 | second `recheck:` indented two spaces | `value=2` | scope note: an indented second clock is invisible (two clocks in the entry, one unchecked). The frozen rule says *column-1*, so this is faithful-to-predicate, not a counter bug |
| v10 | S113 body path `.ufo/waves/round-55/capture/../capture/S113.body` | `value=2` | harmless: same bytes, no evidence change; a `..` that stays inside the tree cannot launder a capture |
| v11 | S113 body path `../../outside/S113.body` (byte-identical copy outside the tree) | `value=1 recheck=0` (`recheck:capture-S113`) | guard holds: `realpath` confinement rejects the escaping `..` |
| v12 | duplicate S114 registry row | `value=FAIL amd=0 recheck=1 guard=0` (`amd:a-rows=2,guard:census`) | self-punishing + census |
| v13 | second row `S115` carrying the AMD URL | `value=FAIL guard=0` | self-punishing |
| v14 | S101 clock **deleted**; only the S113 command remains | `value=2` | **FALSIFIES**: the claim names "S101 -> 2"; deleting the false clock scores the same as correcting it |
| v14b | S101 clock re-pointed to the S113 URL with a true quote (`ISO/IEC 11770-3:2021` -> 16) | `value=2` | **FALSIFIES**: the withdrawal claim loses its clock, the entry still reads 2 |

Impacted axes: **freshness** (C2's evidence instrument), **coverage** (AMD as implemented is
presence-of-fact; S113/S114 add two sources), **calibration** (the clock-count repair is instrument
calibration), and **identity/provenance** (entry `ground:` still says "round 45 C2 (coverage)").

## Axis-fit verdict

**(1) Is naming the amendment in force a freshness move rather than coverage? — Mixed; the counter
measures the coverage half.**

- For freshness: the entry's whole question is "which edition is in force"; Amd 1:2025 is the same
  question's terminal fact, not a new topic, and the entry already *asserted* the amendment exists
  ("names a newer amendment … as the version that now exists [S100]") while leaving it unnamed.
- Against: the fact predates the entry. S114's capture has `2025-04` on 3 lines and `60.60` on 3
  lines (4 as a BRE, which is the v4 defect); the
  entry is `verified-at: 2026-11-05`. Nothing aged between writing and this round — the entry was
  incomplete at birth. That is a completeness (coverage) defect, not drift.
- Against, mechanically: AMD=1 is satisfied by the identifier string + any citation anywhere
  (v1, v1b, v5). That is a coverage measurement (fact + source present), not a currency
  measurement of a statement.
- Provenance nit: the candidate entry's `ground:` line still reads `round 45 C2 (coverage)`. A
  freshness claim over a coverage-grounded entry either restates the claim or updates the ground.
- Lane precedent does carry the *other* half: SCORECARD round 9 scored "the drift mechanism could
  not detect drift" as freshness 2→7. A clock that cannot detect change is a freshness defect.

**(2) Was the BASE statement actually stale? — No for the prose; yes for the clock.**

- BASE entry: no occurrence of `2025` at all; it says the 2017 record "names a newer amendment to
  the 2021 edition as the version that now exists [S100]" and "The newer amendment's content is
  outside this entry". Both sentences were true on 2026-11-05 and are true now. Incomplete, not
  false, and the incompleteness predates the entry.
- BASE `recheck:` said `Withdrawal of International Standard` -> **1** against a committed body
  that gives **2** — a false stored observation, and the counter's own BASE bad list says so
  (`recheck:S101-count-2-stated-1`). This is the half of C2 that was genuinely stale-on-contact.

**(3) Does fixing the recheck count belong to freshness? — Yes, with a caveat.**

- Yes: the `recheck:` line is the entry's stored claim about its source's bytes; a wrong N makes
  the clock fire on every run although nothing changed (BASE) and hides real changes (v3). "The
  mechanism cannot detect drift" is this lane's round-9 freshness definition, so repairing the
  stored number is a freshness move.
- Caveat: it is equally instrument calibration — the axis C1 works this round — so C2's second
  point is not on a different axis class from C1's. And RECHECK as written does not force the
  repair, only the absence of a false command (v14/v14b), so "the clock reads true" can be bought
  by deleting the clock.

Net: C2 as landed is honest, but its two points are heterogeneous — 1 point of defensible
freshness (the clock's false count), 1 point of coverage-shaped completion (the identifier + two new
rows). The claim name ("names the amendment in force") is stronger than the predicate.

## Named ceilings: agree / disagree

**AGREE — "committed bytes only; a capture and rows forged self-consistently around the frozen
AMDSHA cannot be built without that body."** v10, v11, v12, v13 bear this out: an internal `..`
changes nothing, an escaping `..` is rejected, duplicate rows/URLs self-punish and the census
guard catches the row duplication. The AMDSHA/S101SHA pins plus `realpath` confinement are adequate
for the capture/row chain.

**DISAGREE — "a recheck command whose quote is true of the capture but not discriminating (e.g. a
common word with its true count) scores RECHECK; the live re-fetch by a non-author is the check of
currency on the day."** v3 is that ceiling, and it is not harmless: the non-discriminating quote is
precisely the failure C2 claims to repair (a clock that cannot detect change), and the named escape
cannot detect it either — a common word does not stop matching when the page's substance changes.
The ceiling converts the claim's own defect into an accepted reading. Smallest safe correction:
require Q to occur in the row's registry `quote` cell (or as a token of the row's `title`), so the
clock must quote the row's substantive statement — one extra condition in RECHECK, no new file.

**DISAGREE (unnamed) — RECHECK's "number of lines … containing Q as a byte string equals N (what
`grep -c` prints on the body)".** This is false for any Q with BRE metacharacters. v4 states 1 and
3, the command as written prints 2 and 4, and the counter prints `recheck=1`. This is a real
counter defect, not a ceiling: it makes the entry's recorded clock number not the number the clock
outputs. Smallest safe correction: reject Q containing `.[]*^$\` (one regex test; cheapest, keeps
the byte-count definition true), or count with `re.search(q, line)` instead of substring.

**DISAGREE (unnamed) — RECHECK needs ≥1 command, so a false clock can be deleted rather than
corrected.** v14 (S101 clock removed) and v14b (S101 clock re-pointed to S113 with a true quote)
both read `value=2`, while the claim text says the landing states `S101 -> 2`. The counter already
freezes AMDURL/AMDQ/AMDCAP; the smallest safe correction is to freeze the two clock triples as well
(`60237`+`Withdrawal of International Standard`+2, `82709`+`ISO/IEC 11770-3:2021/Amd 1:2025`+3) and
require both present — that is exactly what the plan's claim sentence promises.

**Scope note (v9).** An indented second `recheck:` is invisible because the predicate says
"column-1". That is faithful to the frozen rule; recorded as scope, not defect.

## Candidate is not false — only the counter is under-discriminating

Verified on the candidate tree: the section "The 2021 edition carries Amendment 1:2025 (round 55)"
names the amendment with `[S114]`/`[S113]`; both ids are on the `source:` line; S114 capture sha256
is `8bb88d88…3c449bdf` = AMDSHA; quote-bodies offset 541 is a literal `ISO/IEC 11770-3:2021/Amd 1:2025`;
and both stated counts are true under the *real* command (`grep -c 'Withdrawal of International
Standard'` = 2, `grep -c 'ISO/IEC 11770-3:2021/Amd 1:2025'` on S113 = 3). So `value=2` is true of
this tree.

What `value=2` may be cited for, given the attacks above: *the entry contains the amendment
identifier with a citation somewhere outside `source:`, and no recheck command's stated number
disagrees with a byte-substring count of its committed capture*. It may **not** be cited as "the
entry names the amendment in force" (v1, v1b, v5), "the recheck clock can detect a change" (v3),
"the stated number is what the command prints" (v4), or "the S101 clock was corrected" (v14, v14b).
No harm to the corpus: all attack trees are scratch-only; the exported candidate tree still matches
the commit byte-for-byte for the entry, registry and quote-bodies (sha256 SAME).

## Reproduction

```
S=/fast/scratch/hyaku/kagi-r55/R55CriticC2          # mkdir -p; trees v0_cand … v14b_reurl_s101
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive 348aa3b8ea7298aeb2f4d69db321fe827a92ae4f | tar -x -C $S/cand
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-55-c2.sh --tree $S/<variant>
```

Receipts (`R55CriticC2.d/`): `attack-table.txt` (17 lines, one per run with rc),
`c2-base-and-candidate.txt`, `counts-and-hashes.txt` (real `grep -c` vs literal counts, entry
sha256s), `v1-stale-body.txt` (BASE-vs-v1 diff + reading), `kill-rule.txt`.

Host/tooling: nothing installed or upgraded; no network fetch was made (all counts measured on the
committed captures); scratch confined to `$HYAKU_SCRATCH`; no lane file outside this report and
`R55CriticC2.d/` was written.
