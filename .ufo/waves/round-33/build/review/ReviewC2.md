# ReviewC2 — claim C2 (NIST key-management frontier → core), independent re-derivation

Seat `ReviewC2` (reviewer, round 33 build wave). Frozen BASE
`76f4eeae7aa9af4dbb9423f5632b55791824253a`. Contract: `plans/round-33.md` §C2 (read first;
no predicate or counter changed here). No lane-tracked file was written; this seat wrote only
this file and scratch under `/fast/scratch/hyaku/kagi-r33/ReviewC2/` (removed before yield).

Method: every reading below was re-derived on a **scratch mirror** — `git archive` of the
frozen BASE extracted to scratch, then the delivered artifacts applied by hand
(`build/sources-append.md` rows 5–14 inserted after `| S072 |` inside `## Registry`;
`build/fetches-append.tsv` appended; `build/knowledge/nist-*.md` copied; the two frontier
blocks applied from `build/docs/`). The delivered receipts were not read as evidence; the
landed tree was measured separately as corroboration. Capture verification used an
**independent 20-line reimplementation of the declared `rendered-text-v1` algorithm** over the
retained bodies in `build/src-open/`, not `build/src-open/normalize.py`.

Wall-clock: artifact set as of 2026-11-04T10:37Z; live readings at ~10:50Z, before the landing
commit. The landing is `441581b` ("round-33: prefreeze BASE controls (C1) + NIST key-management
assimilation (C2); QM34, routed R32-2..R32-4"); its C2 files were re-checked after the commit
and match the measured tree (82 registry rows, 82 capture rows, identical entry bytes, S078/S079
`raw-literal-v1` / `-`).

---

## 1. The four target readings — re-derived

The plan's four counting commands, run from the mirror root (except 4a, which names the fleet
root and is reproduced on the landed lane). Target values are from the plan's §C2 **Target**
sentence.

| # | Command (as frozen) | Mirror | Landed lane | Target | Verdict |
|---|---|---|---|---|---|
| 1 | `ls corpus/knowledge/nist-key-management-guidance-status.md corpus/knowledge/nist-key-management-parts-withdrawal.md \| wc -l` | `2`, exit 0 | `2`, exit 0 | 2 | **MET** |
| 2 | `grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md` | `82`, exit 0 | `82`, exit 0 | 82 | **MET** |
| 3 | `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md \| grep -c 'NIST'` | `0`, **exit 1** | `0`, **exit 1** | 0 | **MET** (0 printed; exit 1 is `grep -c` no-match, not a failure of the value) |
| 4a | `bash /home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | exit 0 (`--file` variant on the mirror; 16 pre-existing `W04`, none for S073–S082) | exit 0 (`kagi ok`, same 16 `W04`) | exit 0 | **MET** (exit clause) |
| 4b | the same census's named metrics — **not printed by 4a**; sole source is `bash corpus/sources-census.sh` | `SOURCES_CENSUS: CLEAN (rows=82 A=79 B=1 C=2 queued=1 mined=78 rejected=3 entries_sourced=12 legacy=21 captures=82 inrow=16 inrow_only=0 inrow_nonreproducing=12)`, exit 0 | same line with `legacy=22` (the C1 entry is legacy-class), exit 0 | `entries_sourced=12`, `captures=111` | `entries_sourced=12` **MET**; **`captures=82` ≠ 111 — NOT MET** |

**Outcome.** Three of the four readings are met outright. The fourth is split: its exit-0
clause is met, `entries_sourced=12` is met, and **`captures=111` is not** (measured 82). Under
the plan's kill rule ("any of the four target readings unmet … C2 not admitted") **C2 is not
admitted**. This matches the L1's own conclusion as recorded in `corpus/lessons/round-33.md`
§Migrations/M33-3; this review reproduces it from artifacts, not from that report.

**Why 111 is unreachable.** At BASE the lane census measures `captures=72` (one capture row per
registry id: 72 ids, 72 rows), and the lane's own frozen claim rows already pin it:
`corpus/claim-ledger.tsv` R21-02 and R31-02 expect
`… rows=72 … entries_sourced=10 legacy=21 captures=72 …`. The plan's `captures=101` never
existed on any revision; +10 rows produces 82, not 111. `captures` equals the registry row count
by construction of this gate, so the declared delta alone determines it: 72 → 82.

**Command/metric mismatch.** The plan's fourth counting command is the fleet census, which
prints no `entries_sourced` and no `captures` at all (its output is `lane<TAB>code<TAB>detail`
plus `lane ok path`). The two metrics the Target names are only emitted by the *lane* census,
which the plan does not name. A reviewer following the plan literally cannot read the numbers
the Target asserts.

**Sweep clause.** `bash corpus/self-description-sweep.sh` on the landed tree:
`SELF_DESCRIPTION: MISMATCH n=2 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=2)`, exit 1 — **SD1=0 and
SD2=0 hold**, and the total is the plan's expected n=2 with the two integrator-owned SD6 lines.
On the pristine BASE tree the same line and the same exit 1 are measured (so §Inputs' verdict is
reproduced; see finding 4 about the BASE receipt's `sweep_exit=0`).

---

## 2. Citation attack — rows vs captures

Ten adopted rows; every row's URL, quote, and digests were compared with
`build/nist-captures.tsv` **and** re-checked against the retained body under `build/src-open/`.

| Lane id | Document (evidence) | URL = capture | Quote in captured body | Raw sha / bytes | Normalized sha (HTML) |
|---|---|---|---|---|---|
| S073 | SP 800-57 Pt 1 Rev. 5 final page | yes | yes | verify | verify |
| S074 | SP 800-133 Rev. 3 IPD page | yes | yes | verify | verify |
| S075 | SP 800-133 Rev. 2 final page | yes | yes | verify | verify |
| S076 | SP 800-57 Pt 2 (2005) page | yes | yes | verify | verify |
| S077 | SP 800-57 Pt 3 (2009) page | yes | yes | verify | verify |
| S078 | Pt 2 legacy PDF | yes | yes (`pdftotext`, see R6) | verify (stable, = staged pin) | n/a — `raw-literal-v1`, `-` |
| S079 | Pt 3 legacy PDF | yes | yes (`pdftotext`, see R6) | verify (stable, = staged pin) | n/a — `raw-literal-v1`, `-` |
| S080 | SP 800-57 Pt 2 Rev. 1 page | yes | yes | verify | verify |
| S081 | SP 800-57 Pt 3 Rev. 1 page | yes | yes | verify | verify |
| S082 | SP 800-131A Rev. 2 page | yes | yes | verify | verify |

- **Quotes:** 10/10 are exact substrings of my independent `rendered-text-v1` normalization of
  the corresponding retained body; each ≤21 words. No mis-quote and no quote missing from a
  body. The two PDF quotes are contiguous only after `pdftotext -layout`, which the row's
  `location` cell declares.
- **Digests:** 10/10 decoded-body sha256 and byte counts match `nist-captures.tsv`; 8/8 HTML
  normalized digests match; the two PDFs are byte-identical to the 2026-10-23 staged pins
  (`68266cb1…`, `52b9a7d3…`). The eight CSRC pages are volatile at constant byte size (three
  independent fetches per page, three raw shas, one normalized sha — `build/ScribeEntry1-fetches.tsv`),
  so the normalized digest is the reproducible identity and the raw body sha is a point
  attestation, exactly as the rows declare.
- **Id collision (0–3 leading-space pattern):** BASE registry ids under
  `^ {0,3}\|[[:space:]]*S[0-9]{3,}` = 72; append ids = S073–S082; intersection **∅**; no
  leading-space row in the append (0); no duplicate id inside the append; no escaped or literal
  `|` inside any cell (all ten rows NF=11). `build/id-map.txt` proves the by-document map
  10/10 (`MATCH`), and the staged-id → lane-id offsets are non-constant (−5, −3, +12), so no
  arithmetic rule reproduces it.
- **`used-by`:** 10/10 name exactly one of the two admitted entries, and both files exist in
  the mirror. The two staged rows that pointed at the **refused** `nist-key-management-family-status.md`
  (staged S079/S080) were re-pointed to `…-parts-withdrawal.md`, as the scout's handoff required.
  No `used-by` points at an unadopted entry.
- **Entry citations:** entry 1 cites S073–S075 on its `source:` line and S049 **body-only**
  (explicitly declared pre-existing, not re-proposed); entry 2 cites S076–S082. No staged-id
  token and no `[round-` reference survives in either entry. S049's `used-by` was correctly left
  unchanged because it is not on a `source:` line (the lane census's `SC_ENTRY_CITE` reads only
  that line); the census confirms the handshake clean.

**Dangling / mis-quoted rows: none.** The one row-cell defect is not a quote defect:

> **F3 (medium) — S073's `teaches` asserts an inference its page does not support.**
> `build/sources-append.md` S073: "…so a control must cite Rev. 5 and **must not cite the Rev. 6
> initial public draft**". The captured Rev. 5 page names no Rev. 6 (it has no such token); this
> is the S049 status inference riding on S073. `ScoutNist.md` §3 flagged exactly this over-claim
> ("keep it in the entry but do not put it in S061's `teaches`"). The delivered entry *did* fix
> its prose (it attributes Rev. 6 to S049 and says the Rev. 5 page names no Rev. 6), so **row
> and entry now disagree**. The row's own `scope` cell ("revision, publication date and the parts
> list; no control text") is correct; the `teaches` cell should be trimmed to the page's facts.

---

## 3. Detection-risk attack — can the predicate be satisfied without the work?

The frozen predicate (plan §C2) is: *the two named entries exist, every id they cite resolves in
the registry as `mined`, the discharged Frontier bullet is gone from both files, and the fleet
census exits 0.* It names no content check, no capture check, and no lane census.

Two cheat trees were built on pristine BASE extractions and measured with the same four
commands.

**Cheat A — two empty entry files + ten junk rows, no captures.**
Rows: unique `https://example.invalid/junk-N`, `spec`, tier A, `mined`, valid dates, `used-by`
naming the two entries; entries: zero bytes; frontier bullet removed.

| Clause | Result |
|---|---|
| 1. "the two named entries exist" | **passes** — `ls … | wc -l` = 2 (existence only) |
| 2. "every id they cite resolves … mined" | **vacuous pass** — empty entries cite nothing |
| 3. "the Frontier bullet is gone from both files" | **passes** — deleted |
| 4. "the fleet census exits 0" | **passes** — exit 0 (fleet census checks schema/enums/URL-dup/used-by-path, not provenance) |
| Lane census (not named by the predicate) | **FAILED, findings=20** — 10× `SC_FETCH missing-provenance` + 10× `SC_USEDBY_NOCITE` |

So the frozen predicate **does not catch cheat A**; only the unnamed lane census does.

**Cheat B — two near-empty entries + ten junk rows + ten fabricated capture rows.**
Entries: minimal front matter (`source:` listing the ids, `verified-at:`, `recheck:`) plus
`# Junk entry` and "Nothing here." Capture rows: 16 columns, identity digest computed, **all
digests fabricated** (`'a'*64`, `'b'*64`, `bytes=1`), no bodies anywhere.

| Reading | Result |
|---|---|
| 1 entries / 2 rows / 3 frontier | `2` / `82` / `0` (exit 1) — all as targeted |
| 4a fleet census | exit 0 |
| 4b lane census | **CLEAN `rows=82 A=79 B=1 C=2 queued=1 mined=78 rejected=3 entries_sourced=12 legacy=21 captures=82 …`**, exit 0 |
| Target `captures=111` | **fails only here** — and that number is unreachable by the intended change (see §1) |

**This is the surviving cheat:** two near-empty entries, ten junk rows and ten invented capture
rows satisfy the frozen predicate *and every mechanical gate the lane owns*, because
`SC_FETCH` checks shapes (id, status, URL, identity digest, 64-hex, ≤25-word quote, ≥8-char
location) and never opens a body or verifies that a quote occurs in one. The only detector is a
reviewer reading the entries and re-opening the sources — which is what this seat did for the
delivered artifacts. The delivered C2 is **not** such a cheat (10/10 captures verify), but the
predicate cannot distinguish the two.

**"Ten rows with `status=mined` but no captures."** The fleet census **passes** (it has no
fetch-provenance check at all); the lane census fails each row with `SC_FETCH missing-provenance`.
Because the predicate names the fleet census, this variant also **passes the predicate** and is
killed only by the gate the predicate does not name.

**Verdict on detection:** C2's clause set is an existence/shape test, not an evidence test. A
future round can satisfy it with no knowledge content. The cheap repairs (not applied here, since
this seat may not change predicates) would be: name the lane census in the predicate; make the
census's `SC_FETCH` require a body/quote witness (or a digest that a kept body reproduces); and
require a non-empty body in each entry (a length/quote floor) rather than mere file existence.

---

## 4. Frontier discipline

Measured on the landed tree (the same checks on the mirror agree):

| Check | Result |
|---|---|
| `grep -n 'Frontier' PROVINCE.md` | only the `## Core / Frontier / Adjacent (round 21)` heading, the new round-33 **Core** bullet, and a generic governance sentence; **no Frontier bullet names NIST** |
| `awk '/^## Frontier/{f=1;next} /^## /{f=0} f' corpus/README.md \| grep -c NIST` | `0`, exit 1; the section holds only the release-clocks bullet |
| PROVINCE round-31 bullet | edited to "…the NIST leads were still leads at round 31 and moved to core in round 33 (below)" — no surviving "NIST leads stay leads" claim |
| `corpus/SOURCES.md` §Leads | the two NIST "leads only, not evidence" bullets are **removed**; a `Round-33 lead disposition (2026-11-04)` paragraph records the discharge and supersedes the round-28 clause ("SP 800-133 Rev. 3 stays a lead") |
| `self-description-sweep.sh` | `SD1=0 SD2=0`, `n=2` with the same two integrator-owned SD6 lines (live and BASE) |

**No file still claims the NIST ground is a frontier lead.** Two cautions:

- **The delivered docs artifacts alone were insufficient for this.** `build/docs/province-core-bullet.md`
  and `readme-frontier-removal.md` remove the bullet and add the Core bullet, but they do not
  touch PROVINCE.md:89/90 ("the NIST leads stay leads") or `corpus/SOURCES.md` §Leads. The L1
  edited both beyond the artifact set. A future wave that installs only the named artifacts would
  leave the lead text standing. (My mirror, built strictly from the artifacts, still says "the
  NIST leads stay leads"; the landed tree does not.)
- **Pre-existing, not round 33:** PROVINCE.md:89 (the round-30 bullet) still says "The frontier
  bullet below keeps its history" — the bullet it points at (secret scanning) was removed in round
  32. `ScoutLane.md` §8 flagged it; it is unchanged by this round and outside C2.

**Landing-order dependency (F5).** Entry 1's final line cites `corpus/lessons/round-33.md`. On a
mirror holding the C2 artifacts but not the ScribeDocs lesson, the sweep measures
`n=3 (SD6=3)` with a new line `… nist-key-management-guidance-status.md:107 corpus/lessons/round-33.md (local)`.
The landed tree (lesson installed) measures n=2. So C2's "same two SD6 lines" holds only if the
lesson lands with the entry; an entry-only install breaks it.

---

## 5. Findings, by severity

**F1 (high — claim outcome). `captures=111` is unmet and was never reachable.** Measured 82 on
both the artifact mirror and the landed tree; BASE is 72, pinned by R21-02/R31-02's expected
census lines; +10 rows gives 82. The plan's fourth reading names a number no tree produces, and
its own dead controls file (`plans/round-33.controls.tsv`, four rows) does not include a
`captures` control, so the round's new gate ran `PREFREEZE: CLEAN (controls=4 mismatch=0)` while
the plan it was frozen beside carried the wrong figure. Under the kill rule C2 is **not
admitted** — the L1's lesson records the same outcome (M33-3). This is the M32-2 class
recurring in the round that claims to close it.

**F2 (high — detection). The frozen predicate is satisfiable with no knowledge content.**
Cheat B (§3): two near-empty entries + ten junk rows + ten fabricated capture rows pass all four
readings and the lane census `CLEAN` (entries_sourced=12, captures=82). `SC_FETCH` never opens a
body. Only a reviewer detects it. The delivered C2 is not a cheat, but nothing mechanical
distinguishes the two.

**F3 (medium — citation). S073's `teaches` cell asserts "must not cite the Rev. 6 initial public
draft", a claim the captured Rev. 5 page does not contain.** The entry correctly attributes it to
S049, so row and entry disagree; `ScoutNist.md` had flagged the over-claim before append.

**F4 (medium — calibration receipt). `controls/base-values.txt` records `sweep_exit=0`, but the
sweep exits 1 at BASE** (`MISMATCH n=2`, verified on a pristine BASE extraction; the script's
header fixes MISMATCH → exit 1). The counter's *values* in the receipt reproduce exactly; only the
exit annotation is false. The four controls do not include the sweep, so the new gate cannot catch
this. Same class as F1: a declared field the command does not produce.

**F5 (medium — install-order). The entry's Gate line cites `corpus/lessons/round-33.md`; the
sweep's n=2 depends on that lesson being installed.** A C2-only install measures n=3 with a
lane-owned SD6 line (§4). It resolved on the landed tree, but the dependency is not stated in the
C2 artifact set.

**F6 (low — label semantics). S078/S079 declare `normalization=raw-literal-v1` with `-`, but their
quote is `pdftotext`-extracted text, not a raw-byte substring.** The location cell discloses the
extraction, so the evidence is honest; the label's literal meaning is not satisfied. The
alternative (`rendered-text-v1`) is refused by the declared normalizer (`SETUP`, not strict
UTF-8), so the lane chose the lesser mismatch. Bounded; recorded, not failed.

**F7 (low — evidence reach). The landed capture rows' decoded-body sha is ExecCapture's own fetch
(a third body), not the ScoutNist body retained in `build/src-open/`.** Only the normalized digest
and the quote are reproducible from the retained bytes; the raw digest is a point attestation,
consistent with the lane's S072 precedent and the three-fetch volatility receipt.

**F8 (note — receipt integrity). `final/c2-and-calibration-gates.txt` is headed
`== self-description-sweep ==` but contains `SELF_COUNTS: POLICY …` output; the sweep result was
overwritten by a second writer.** The same collision class the lesson records for
`prefreeze-32.txt`. I re-ran the sweep myself (§1) and did not rely on the receipt.

**F9 (note — counter/command mismatch).** The plan's fourth counting command (fleet census)
prints neither `entries_sourced` nor `captures`; the Target's two metrics have no named command
(§1).

---

## 6. Surviving cheats — the yield

1. **Two near-empty entries + ten junk rows + ten fabricated capture rows** (cheat B): passes
   all four frozen readings and the lane census `CLEAN (… entries_sourced=12 … captures=82)`.
   Only the unreachable `captures=111` fails. **Survives.**
2. **Two empty entries + ten junk rows, no captures** (cheat A): passes the frozen predicate
   (existence is literal; the cite clause is vacuous); dies only at the unnamed lane census
   (`FAILED findings=20`). **Survives the predicate; not the lane census.**
3. **Ten `status=mined` rows with no captures:** passes the fleet census (the named command) and
   the predicate; dies at the lane census (`SC_FETCH`). **Survives the predicate as named.**

**Dangling or mis-quoted rows:** none. The only row-level defect is **F3** (S073's `teaches`
over-claim), which is an inference, not a quote. No id collision, no leading-space row, no
duplicate id, no `used-by` to an unadopted entry, no escaped pipes, no staged-id token or
`[round-` reference in either entry.

---

## 7. Residual risk and verification gaps

- I did not re-fetch the ten URLs. Quote and digest verification ran against the retained bodies
  (`build/src-open/`) and my own normalizer implementation; a live re-fetch would be the same
  volatile bytes and the same rendered text (three seats independently showed this), but this
  review proves *consistency with the retained captures*, not that today's network serves the
  same page.
- I ran `claim-ledger.sh docs` (CLEAN: `entries=34 row_linked=31 …`) but not
  `claim-ledger.sh verify` (long) — the migrated claim rows R12-03/R13-01/R14-01/R21-02/R21-04/
  R22-03/R24-05/R24-06/R24-14/R24-15/R31-02 were inspected in the diff and their new expected
  values match the measured census/audit lines, but I did not execute every row.
- The cheat trees used `example.invalid` URLs; the fleet census's only URL test is
  duplicate-URL+scope, so the result generalizes to any unique invented URL.
- The frontier check on the *mirror* still shows the round-31 "the NIST leads stay leads" sentence
  and the §Leads bullets; only the L1's landed edits remove them. I report the landed state as
  authoritative for the claim and the artifact-only gap as F (note in §4).
- Scratch `/fast/scratch/hyaku/kagi-r33/ReviewC2/` was removed before this seat yielded; the
  mirror/cheat trees, the independent normalizer and the sweep receipts are gone with it (the
  measurements are in this file).
- Tooling: nothing installed or upgraded (no pacman/uv/npx/binary fetch; pacman is paused
  host-wide and was not touched). Used only preinstalled `git`, `bash`, `grep`, `awk`, `python3`,
  `pdftotext`. Vault contact: none — no `op` subcommand was run at all.
