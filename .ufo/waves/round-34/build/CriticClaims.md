# CriticClaims — frozen round-34 claim review

Axes: calibration, operability, coverage. Review source: `/home/vgpnk/Projects/shokunin/kagi-shokunin/plans/round-34.md`, frozen BASE `f9dc06fd8f6b43c175193c76dc6350468f551634`. This is a claim-design review, not landing admission or a canonical judgment. No counters were rerun, no network/vault/runtime/subagent was invoked, and no lane-tracked file was written. Evidence below is inspected code and existing receipts; arithmetic is inference from the stated BASE populations and census classification.

## C1 — sound, narrowly as declared

### Frozen wording (verbatim)

> **Predicate (frozen, one sentence):** `SD789_SUM=0` at the landing revision, where
> `SD789_SUM` is the sum of the SD7+SD8+SD9 components of the sweep's verdict line.

```sh
bash corpus/self-description-sweep.sh | awk -F'[ =()]' \
  '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'
```

> **BASE → target:** 5 → 0 (BASE components: SD7=3 SD8=1 SD9=1; measured at freeze by
> `.ufo/waves/round-34/controls/sd789-base.sh` through the pre-freeze gate).

> **Second reading:** `bash corpus/self-description-sweep.sh --selftest` — 7 → 10 cases
> (one planted-mismatch fixture per new check).

> **Kill rule:** `SD789_SUM > 0` at the landing revision → C1 not admitted, reported
> honestly; the number is never re-scoped after data.

The three component definitions are also binding, verbatim:

> **SD7 — gate-registry coverage.** For each top-level `corpus/*.sh` and
> `corpus/*.py` whose bytes mention `--selftest`, its basename must appear at least
> once in `SKILL.md`. Count = scripts not named.

> **SD8 — lesson-row range claims.** For each `M<r>-<n>..M<r>-<m>` token in
> `SKILL.md`, `PROVINCE.md`, `SCORECARD.md` or `corpus/README.md`, the lesson
> `corpus/lessons/round-<r>.md` must exist, must carry a row `| M<r>-<m> `, and must
> carry no row `| M<r>-<k> ` with `k > m`. Count = violations.

> **SD9 — admitted-entry provenance.** A `corpus/knowledge/*.md` entry whose
> `Reverify:` line names an `R<r>-<n>` with `r >= 30` must carry `^source:`,
> `^verified-at:` and `^recheck:`. Count = entries violating.

### Falsification attempts and evidence

- **Reachability:** yes for these three bounded classes: register all three omitted basenames, correct the M33 range, and give the prefreeze entry its provenance trio. This does not establish that every routed defect or the whole sweep is clean. SD6 remains excluded and exit 1 must remain visible.
- **Do nothing:** no under the frozen semantic predicates: supplied BASE components are 3/1/1. However the literal pipe is fail-open: an empty-output stub, a setup failure with no SD fields, or the old sweep lacking SD7–SD9 makes awk print zero. This is a counterexample to using the integer alone as proof, not permission to treat that output as the defined sum of three implemented components.
- **Different BASE/tip code paths:** real risk, explicitly present. The freeze helper is separate implementation, not the shipped old sweep. The strongest available local control addresses it: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/receipts/base-new.txt:1-11` runs the new sweep against an explicit BASE extraction and identifies the same five actual defects, ending SD7=3 SD8=1 SD9=1, exit 1. It is not testing a synthetic tree where the defects never existed. Its extraction identity is reported by ExecSD; this seat did not independently recreate the extraction.
- **Not identical general functions:** the frozen helper deduplicates SD8 token strings (`sort -u`, lines 25–34), whereas the new implementation counts occurrences (build sweep lines 419–452); the helper takes the first R-number, whereas the new SD9 scans multiple admissions on its first Reverify line (lines 455–475). Matching observed BASE components does not prove universal equivalence. Neither discrepancy changes the witnessed BASE 5; never claim these programs are byte-identical or universally equivalent.
- **Stub/moved number:** the new sweep's actual loops exist (build script lines 407–475). ExecSD's retained deletion-mutant transcripts report each corresponding planted case failing, and the 10-case receipt is reported in ExecSD. A print-only zero cannot substitute for those implementations and fixture witnesses.
- **Ambiguities held to the narrow reading:** “gate-registry coverage” means literal basename occurrence, not a complete conformant registry row; the R33-1 registry standard is stronger and remains separately reviewable. Presence-only provenance permits empty values; C1 cannot claim provenance validity from SD9 alone. The introductory test-count defect is not a fourth SD789 component. “Committed bytes only” means final evidence must bind the committed tree, not that the delivered `--root` interface magically excludes worktree edits.

**Smallest safe correction:** retain the frozen target and pipe, but accompany its integer with the full component-bearing output/exit, the existing new-code-on-BASE receipt and the 10-case planted-mismatch reading. Do not suppress SD6 or call a missing-component zero success. This is evidence discipline, not a replacement counter.

**Verdict: sound** for SD7–SD9 as bounded; fail-open output and different implementations prohibit admitting C1 from the integer alone.

## C2 — sound, with receipt identity and exact-text caveats

### Frozen wording (verbatim)

> **Predicate (frozen):** `PREFREEZE_SELFTEST: PASS (12 cases)` with the shipped bytes,
> and a committed M7 receipt whose output names `base-isolation` as the failing case.

```sh
bash corpus/prefreeze-control.sh --selftest | tail -1
grep -c 'CASE base-isolation FAIL' .ufo/waves/round-34/mut/m7-shipped.txt
```

> **BASE → target:** `PASS (11 cases)` → `PASS (12 cases)`; `0` → `1` receipt line.

> **Kill rule:** either reading unmet at the landing revision → C2 not admitted.

### Falsification attempts and evidence

- **Reachability:** yes, by retaining the original eleven cases, adding a real relative-work execution, and committing an executed M7 receipt bound to the relevant shipped bytes. **Do nothing:** no; supplied BASE has eleven cases and no receipt.
- **Renaming/printing attack:** a renamed case or hard-coded 12-case summary could satisfy the last-line command without adding coverage. Available code disproves that particular shortcut in the delivered proposal: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/prefreeze-control.sh:167-195` retains base-isolation, then invokes the gate from another directory with `--work ./w`, captures rc/output and calls `ck relative-work`. The helper increments its case count per assertion, not from a fixed 12 literal. ExecGate lines 28–30 report twelve passing cases and a canonicalization-removal mutant whose only failure is relative-work. These are inspected existing reports, not runs by this seat.
- **False provenance attack:** the available `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/mut/m7-shipped-11.txt` is explicitly an eleven-case mutant with BASE source hash `b634a8d1…` (lines 12–15). It cannot silently become proof of a twelve-case candidate's mutant run. At inspection time the required landing path `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/mut/m7-shipped.txt` was absent. This is an unfinished landing condition, not proof that the claim is intrinsically impossible.
- **Exact-text attack:** `ck` prints the label with `%-26s`, so its raw line is `CASE base-isolation             FAIL …`, not the single-space string in the frozen grep. The eleven-case receipt adds one explicit normalized verdict line that matches the grep and also preserves the raw padded line. One such clearly labeled derived line can make the frozen count 1 without falsifying raw output; it must not be presented as raw output or counted twice. A bare copied sentence with no executed raw run would be false provenance, even if grep returns 1.
- **Two failing cases:** ExecGate line 56 reports a candidate M7 that fails both base-isolation and relative-work, because both measure the old three-line revision after the fixture worktree becomes four lines. “As the failing case” could mean exclusive failure or a named failing witness. The frozen grep asserts presence/count of the named witness, not exclusivity; hold it to the latter. Do not remove the new case merely to hide the second legitimate failure.
- **Post-data rescope:** do not accept an eleven-case receipt, an uncommitted scratch receipt, or a promise to replay against shipped bytes as the declared committed execution. Binding source and mutant digests plus raw output is the smallest correction; no new numeric target is needed.

**Verdict: sound** as a reachable execution claim. Admission remains contingent on the final twelve-case shipped reading and correctly bound committed M7 receipt satisfying the exact frozen count.

## C3 — unsound: its exact census target omits C1's required migration

### Frozen wording (verbatim)

> **Predicate (frozen):** the entry exists, the registry carries five more rows, and the
> census is CLEAN at the new counts.

```sh
ls corpus/knowledge/aliyun-accesskey-credential-custody.md | wc -l
grep -cE '^\|[[:space:]]*S[0-9]{3,}[[:space:]]*\|' corpus/SOURCES.md
bash corpus/sources-census.sh
```

> **BASE → target:** entry 0 → 1; rows 82 → 87; census `entries_sourced=12 legacy=22
> captures=82` → `entries_sourced=13 legacy=21 captures=87`, exit 0.

> **Kill rule:** any reading unmet → C3 not admitted; rows adopted are never
> bulk-appended (only rows the admitted entry cites).

> **Sourced claim:** C3's evidence is the five rows opened this round (S083–S087), and
> the entry's `source:` line names them.

### Falsification attempts and evidence

- **Strongest counterexample — population conservation:** BASE contains 34 entries: 12 sourced and 22 legacy. C1's required prefreeze provenance repair migrates one existing legacy entry to sourced: 13 sourced, 21 legacy. Adding the new sourced AccessKey entry then gives 14 sourced, 21 legacy, total 35. The frozen target 13+21=34 has omitted the added entry. This is a cross-claim conflict, not source freshness uncertainty.
- **Local evidence:** `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/lessons/round-33-verifier-spotcheck.md:150-156` explicitly identifies prefreeze-controls as a newly absorbed legacy entry requiring its source trio. `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/sources-census.sh:87-95` explicitly classifies a column-1 source entry as sourced, and every no-source entry as legacy. The live prefreeze entry now opens with `source: S088` plus the other two headers. L1 separately communicated that S088 supplies that entry's valid own-work handshake, making rows/captures 88 rather than the frozen 87. These observations support, but are not substitutes for, the final census run.
- **Reachability by declared work:** no, jointly with C1's required migration and retention of existing entries. C3 alone, adding a sourced entry without the migration, gives 13 sourced/22 legacy, also not its target. Reaching 13/21 after adding an entry would require deleting or reclassifying another entry, or changing what the census counts; none is declared work. Registering the independently justified own-work source adds a second row-count mismatch. A source-handshake choice cannot repair the entry-population arithmetic.
- **Do nothing:** no: entry absent and rows 82, with the supplied BASE census. A filename stub plus five unrelated rows might move the first two readings but cannot establish the sourced claim.
- **Entry-without-cited-rows attack:** the census's stated SC_ENTRY_CITE and SC_USEDBY_NOCITE checks require registered mined IDs, reciprocal used-by and citation. Those checks prevent a correctly sourced entry silently landing without its cited rows. A headerless stub falls into legacy and evades the sourced-entry checks, so file existence is not sufficient; enforce the explicit `source:` S083–S087 requirement and in-round reopening evidence as well as census CLEAN.
- **Two readings of “five more rows”:** five AccessKey rows can coexist with an additional own-work row, but the frozen counter/target means the total registry must equal 87, not “at least 87” or “87 excluding S088.” Likewise “new counts” includes the explicitly frozen sourced/legacy/capture values, not merely CLEAN exit 0. Hold the closure to exact totals. Do not attribute a fleet-summary output to this lane census or silently omit a required migration.

**Smallest safe correction:** report actual complete measurements and C3 not admitted under the unchanged kill rule. Do not delete a valid entry, strip provenance, exclude S088, change census semantics, or replace the target after data. Coverage content may be delivered without claiming this frozen coverage target passed.

**Verdict: unsound: the frozen census target fails population conservation under the declared combined work; honest outcome is C3 not admitted.**

## Review bounds and self-evaluation

Only this report was written; no scratch was needed, tools installed, measurements rerun or fixtures created. Read-only inspection cannot establish final commit identity or final landing counts. Accuracy 4/5 (receipt/extraction identities are reported evidence, not independently replayed); completeness 4/5 (all three claims and named attacks covered, final landing intentionally not measured); clarity 4/5 (verbatim contract makes the report long); actionability 4/5 (exact receipt-binding conditions stated; installation remains L1's responsibility); conciseness 4/5 (required quotations dominate). Overall 4.0/5. Improvement priorities: preserve final shipped digest bindings and distinguish raw from normalized M7 output. Expected user agreement: yes; frozen targets stay unchanged and no admission is inferred from partial work.
