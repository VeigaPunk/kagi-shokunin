# R67ExecCounterC1 — C1_READTHROUGH counter (round 67, wave w1, A2 + A3)

- **Claim**: C1 (freshness) — the census reads each declared capture's bytes and quote.
- **Frozen plan**: `plans/round-67.md` §C1 under Amendment A2 (A2.1–A2.5) and
  Amendment A3 (S166 prose row; prose derived, never literal). The target, label
  and population are unchanged.
- **BASE** `076701a11a58e3eb58d996b4c76c5e18071fb179`; predeclaration `aa8807e`.
- **Sole-written file**: `plans/round-67-c1.sh` (executable, 1195 lines, sha256
  `3aed2ac69722138e0a0ffbc2745003d040b56ebcef22c1fd549df17c08344ab0`). It also
  carries guard (f) and the trusted-normalizer derivation added as the
  R67Sentinel V-1 countermeasure (documented and selftested here; not reverted).
  No gate, TSV, registry, SCORECARD/SKILL/lesson or fleet file edited; nothing
  committed.
- **Instrument**: `bash plans/round-67-c1.sh [--tree DIR] [--base-tree DIR]
  [--scratch DIR]` / `--selftest`. Exit 0 iff the predicate holds, 1 if measured
  and missed, 2 on `C1_READTHROUGH: SETUP <reason>`.

## Construction (frozen contract as amended)

`bound`/`located` are derived row by row from `corpus/source-fetches.tsv` + the
bytes at col 16: capture-path-shaped per A2.1 (contains `/` and matches
`^[A-Za-z0-9._][A-Za-z0-9._/-]*$`, or the absolute form, always outside-root);
repo-relative, `realpath` inside the tree, regular file, raw sha256 == col 10,
size == col 11 (`bound`); col 13 locates count>=1 under col 14
(`rendered-text-v1` via a TRUSTED normalizer — `--base-tree`'s copy, else this
lane's, never the measured tree's; `raw-literal-v1` by literal byte substring)
(`located`). Prose rows are counted and never opened.

**A2.3 `caught`** comes only from the candidate gate's stdout per mutated copy:
exit 1 + `SOURCES_CENSUS: FAILED` + `SOURCES_CAPTURES: FAILED` with `defects`
equal to the number of `FINDING SC_CAPTURE` lines + every expected reason on the
mutated id (other ids do not count; multiple lines per row are accepted; the
counter does not classify the copy itself). Legs, with the anchor derived from
the population (first binding capture-shaped row with a same-size/different-sha
capture target; on these bytes S143 → `.ufo/waves/round-64/capture/S143.body`):

| leg | construction | expected |
|---|---|---|
| M1 | anchor col 16 → in-tree capture file, **same byte count, different sha256** | `capture-digest-mismatch` |
| M2 | truncate anchor body by one byte | `capture-bytes-mismatch` **and** `capture-digest-mismatch` |
| M3 | delete anchor body | `capture-missing` |
| M4 | anchor col 16 → absolute path of its own body | `capture-outside-root` |
| M5 | anchor col 16 → `..` location escaping the tree | `capture-outside-root` |
| M6 | anchor col 13 → non-empty <=25-word non-locating string | `quote-not-located` |

No same-size/different-sha target (or only byte-identical targets) is SETUP.

**A2.4 population identity** (`pop` guard): the BASE capture-path-shaped id set
and each id's raw col 16 and col 10 are derived from
`git show 076701a:corpus/source-fetches.tsv` (or `--base-tree`'s TSV when it
carries one; a copy without history falls back to this lane's committed blob,
declared in the diagnostic). The candidate set must equal it and those two
columns must be byte-identical. col 13 is not part of the identity.

**A2.5 venue** (`d` guard): the fleet wrapper runs only when `--tree` is this
counter's lane (`venue=lane`), and must print a `kagi ok` row naming the
measured tree's `corpus/SOURCES.md`; any other tree is `venue=skip` and does not
fail.

**Guard (f)** (R67Sentinel V-1): the candidate's
`corpus/rendered-text-v1.py` must hash byte-identically to the BASE copy
(`--base-tree`'s file, else `git show <BASE>:corpus/rendered-text-v1.py`); the
counter's own derivation reads a trusted normalizer, so a truthy normalizer
cannot move both sides of the cross-check.

Guards as frozen: (a) gate CLEAN with its four counts equal to the derivation,
the derivation's path_rows/bound/located equal to the derived BASE population,
and the summary adjacent to the verdict; (b) gate `--selftest` exit 0 with cases
>= 84; (c) the BASE gate on the M1 repointed copy prints `SOURCES_CENSUS:
CLEAN`; (e) no prose id in a `SC_CAPTURE` finding and the gate's prose count
equals the derived prose count. No literal 36/120 exists in the counter; the
predicate's kill rule uses the derived population.

## Evidence (gate sha256 `e7aacecdfcf06ed6303f5272cd0d3bd6a20d16fdbf0f064a4c68aae940e1d10f`, 966 lines, 89 cases; stable before/after both runs; BASE gate `e9ae2620…`)

### 1. Lane tree (A3 state: S166 prose row, prose=121) — target reached

`bash plans/round-67-c1.sh --tree /home/vgpnk/Projects/shokunin/kagi-shokunin --scratch /fast/scratch/hyaku/kagi-r67/R67ExecCounterC1`
Receipt `lane-final.txt` (sha256 `354085b4…`):

```
c1-readthrough: derived path_rows=36 bound=36 located=36 prose=121 malformed=0
c1-readthrough: population base_ids=36 source=tree-history git show 076701a11a58e3eb58d996b4c76c5e18071fb179 candidate=36
c1-readthrough: anchor id=S143 loc=.ufo/waves/round-63/capture/S143.body target=.ufo/waves/round-64/capture/S143.body bytes=264946
c1-readthrough: clean verdict=CLEAN rc=0 captures=SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121)
c1-readthrough: guard-a verdict=CLEAN rc=0 captures=SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=121) derived=path_rows=36 bound=36 located=36 prose=121 gate_fields=match adjacent=True population=36
c1-readthrough: guard-b selftest rc=0 cases=89
c1-readthrough: guard-c base-gate-on-repoint rc=0 verdict=SOURCES_CENSUS: CLEAN (rows=157 A=140 B=2 C=15 queued=3 mined=137 rejected=17 entries_sourced=27 legacy=21 captures=157 inrow=16 inrow_only=0 inrow_nonreproducing=12)
c1-readthrough: guard-d venue=lane rc=0 kagi_ok=yes measured=/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md
c1-readthrough: guard-e prose_rows=121 prose_findings=none gate_prose=121 derived_prose=121
c1-readthrough: guard-f candidate=14f6ca6ab742296f base=14f6ca6ab742296f verdict=same
c1-readthrough: guard-pop base_ids=36 missing=none extra=none changed=none
c1-readthrough: mut-m1 id=S143 expected=capture-digest-mismatch reasons=capture-digest-mismatch defects=1 findings=1 verdict=FAILED rc=1 captures=FAILED
c1-readthrough: mut-m2 id=S143 expected=capture-bytes-mismatch+capture-digest-mismatch reasons=capture-bytes-mismatch,capture-digest-mismatch defects=2 findings=2 verdict=FAILED rc=1 captures=FAILED
c1-readthrough: mut-m3 id=S143 expected=capture-missing reasons=capture-missing defects=1 findings=1 verdict=FAILED rc=1 captures=FAILED
c1-readthrough: mut-m4 id=S143 expected=capture-outside-root reasons=capture-outside-root defects=1 findings=1 verdict=FAILED rc=1 captures=FAILED
c1-readthrough: mut-m5 id=S143 expected=capture-outside-root reasons=capture-outside-root defects=1 findings=1 verdict=FAILED rc=1 captures=FAILED
c1-readthrough: mut-m6 id=S143 expected=quote-not-located reasons=quote-not-located defects=1 findings=1 verdict=FAILED rc=1 captures=FAILED
c1-readthrough: guard a=1 b=1 c=1 d=1 e=1 f=1 pop=1
C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1
```

Exit 0. M1 is A2.3's same-size/different-sha fixture (digest only); M2 carries
both content reasons; `defects` equals the SC_CAPTURE line count in every leg.

### 2. BASE extraction — no-work control

`git archive 076701a corpus` + the 36 BASE capture files (verified against the
BASE TSV col 10/col 11 before copying), `--tree <extract> --base-tree <extract>`.
Receipt `base-extract-final.txt` (sha256 `fd8604aa…`):

```
c1-readthrough: derived path_rows=36 bound=36 located=35 prose=120 malformed=0
c1-readthrough: derived-defect S115 quote-not-located
c1-readthrough: population base_ids=36 source=base-tree <extract>/corpus/source-fetches.tsv candidate=36
c1-readthrough: clean verdict=CLEAN rc=0 captures=absent
c1-readthrough: guard-a verdict=CLEAN rc=0 captures=absent derived=path_rows=36 bound=36 located=35 prose=120 gate_fields=differ adjacent=False population=36
c1-readthrough: guard-b selftest rc=0 cases=78
c1-readthrough: guard-c base-gate-on-repoint rc=0 verdict=SOURCES_CENSUS: CLEAN (rows=156 …)
c1-readthrough: guard-d venue=skip tree=<extract> lane=/home/vgpnk/Projects/shokunin/kagi-shokunin
c1-readthrough: guard-e prose_rows=120 prose_findings=none gate_prose=absent derived_prose=120
c1-readthrough: guard-f candidate=14f6ca6ab742296f base=14f6ca6ab742296f verdict=same
c1-readthrough: guard-pop base_ids=36 missing=none extra=none changed=none source=base-tree <extract>/corpus/source-fetches.tsv
c1-readthrough: mut-m1..m6 id=S143 reasons=none verdict=CLEAN rc=0 captures=absent
c1-readthrough: guard a=0 b=0 c=1 d=skip e=0 f=1 pop=1
C1_READTHROUGH: bound=36 located=35 caught=0/6 guard=0
```

Exit 1. The BASE gate reads CLEAN on every mutation and has no
`SOURCES_CAPTURES:` line: doing nothing reaches neither `located=36` nor any
catch (A2.6: gate-level `located 35 → 36`, `caught 0/6 → 6/6`).

### 3. Selftest

`bash plans/round-67-c1.sh --selftest` → `C1_READTHROUGH_SELFTEST: PASS (50
cases)`, exit 0 (receipt `selftest-final.txt`, sha256 `a28e52e7…`). Coverage:
derived counts and bytes-only vs digest-only defects; A2.3 anchor derivation
(same size/different sha; no target or identical body = SETUP); caught mapping
on every field (right reason, wrong reason, wrong id, rc 0, rc 2/SETUP, missing
summary, M2 needs both, `defects` == line count, other ids ignored); the A2.3
stub replay (constant CLEAN summary on every copy → caught=0/6; constant FAILED
gate reaches 6/6 but its clean run is FAILED so guard (a) refuses it); A2.4
identity cases (missing/extra/changed col 16/changed col 10 fail, col 13
re-cut allowed); A2.5 venue; guard (f) normalizer identity (same/differ/
missing); zero-match SETUP; hardlink safety; aggregation boundaries against a
derived population.

## Disposition of R67Revenger's points

1. **Guard (a) with prose=121 is reachable.** The counter does not compare the
   gate line to the literal `prose=120`; it derives prose from the candidate
   registry (16-column rows whose col 16 is not capture-shaped — 121 here,
   including S166) and compares the gate's four counts to that derivation, while
   A2.4 pins only the capture-shaped id set and its col 16/col 10. A3 §2 names
   exactly this reading. Measured: `guard-a … gate_fields=match`, guard=1, and
   `C1_READTHROUGH: bound=36 located=36 caught=6/6 guard=1` (receipt above).
2. **Caught accepts multiple SC_CAPTURE lines per row and requires the mutated
   id.** M1 requires `capture-digest-mismatch` (a target that also differs in
   size would print bytes too; both are accepted, digest required); M2 requires
   both bytes and digest. On these bytes the derived anchor is S143 and the six
   legs carry the expected reasons for S143 (receipt above). `defects` must
   equal the number of finding lines.
3. **Guard (e) derives the prose count.** It counts 16-column rows whose col 16
   is not capture-shaped (121 on the A3 lane; 120 at BASE), compares that to the
   gate's `prose` field, and requires no prose id in a `SC_CAPTURE` finding.
   S166 is prose by col 16, so its declared capture is not read — that is A3
   §3's recorded ceiling (its sha256/bytes/quote are verified by hand), not a
   guard-(e) failure. No hard-coded 120 anywhere.

## Risks / ceilings

1. **Gate drift.** The gate changed twice during the wave (46de3d8c → e7aacecd:
   `stat -Lc` symlink fix, 89 cases). The receipts name the measured sha
   (`e7aacecd…`), stable before and after both final runs; a later gate change
   needs a fresh counter reading.
2. **Population identity** pins the BASE capture rows: an added/removed
   capture id or a changed col 16/col 10 fails `pop` even if counts look right.
   A prose row (S166) is outside the identity set; its effect is only the
   derived prose count, per A3.
3. **Anchor derivation is a property.** If no capture row has a
   same-size/different-sha in-tree target, the counter is SETUP; a repoint to an
   identical body is never a mutation.
4. **Guard (f)** refuses a tree that ships a different normalizer; the counter's
   own derivation never reads the measured tree's normalizer.
5. Mutated copies carry gate inputs only (corpus + capture-shaped files, `.git`
   excluded); hardlinks only across the same filesystem, every rewritten file
   unlinked first (selftest-proven).

## Blockers

None.

## Receipts

`.ufo/waves/round-67/w1/R67ExecCounterC1/` — `lane-final.txt`
(`354085b4…`), `base-extract-final.txt` (`fd8604aa…`), `selftest-final.txt`
(`a28e52e7…`), `provenance.txt` (tip, gate/base-gate/counter/TSV/normalizer
sha256, S166 prose row, S115 locate, verdict lines, receipt hashes). Scratch
`/fast/scratch/hyaku/kagi-r67/R67ExecCounterC1/` (including the BASE extraction)
was removed after the receipts were copied.
