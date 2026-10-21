# AttackEntry20 — falsification of integrated C2 for `corpus/knowledge/substrate-deferral.md`

**Axes:** calibration, freshness. **Wave:** round-22 falsification (fresh attack of the integrated tree).
**Frozen input hashes named from** `.ufo/waves/round-22/integration-manifest.json` — `corpus/knowledge/substrate-deferral.md`: sha256 `ec8800c88195501af806f2d59effcf108b24f5f1db213c082ed17a6f7ee302b2`, bytes 6192, lines 108 (manifest lines 212–215). **Integration landing:** `8ada17a50a25a75e6fc4a8cf880c87a85c67c8a3` (helper landed line, pushed/verified). **Frozen base:** `c2cab35bc92e57e39e5489bac3386db078345b3f` (historical BEFORE, not the falsification input).
All observations 2026-10-20, read-only; no production writes, no host gates, no subagent dispatch. Installs: none.

## 1. Byte/revision chain (observed)

| state | sha256 | bytes | lines |
|---|---|---|---|
| base `c2cab35` blob (historical BEFORE) | `168890519978a96095bba797cfe0fb1a5d4ae94a23a71df23f81e193b8963c98` | 5338 | 93 |
| landing `8ada17a` blob | `ec8800c88195501af806f2d59effcf108b24f5f1db213c082ed17a6f7ee302b2` | 6192 | 108 |
| frozen-before manifest value | `ec8800c8…302b2` | 6192 | 108 |
| current worktree bytes | `ec8800c8…302b2` | 6192 | 108 |

- `cmp` of base blob vs `head -c 5338` of current: **PREFIX_IDENTICAL** — the base 5338 bytes are a byte-exact prefix of the current 6192 bytes. `git diff --stat` base→landing: `1 file changed, 15 insertions(+)`, 0 deletions, pure append after line 93.
- Worktree is clean for this path and no commit after `8ada17a` touches the file; current bytes = landing bytes = frozen-before bytes. The falsification input is confirmed against the manifest, not inferred.
- Diff content: one new block, `## Erratum (round 22 — dated counters and detection limits)`, plus the audit pointer line. No line of the original 93 was edited, reordered or deleted (append-only preserved).

## 2. Stamp record and migration (freshness)

- Current `corpus/stamps.tsv` line 31: `corpus/knowledge/substrate-deferral.md	ec8800c88195501af806f2d59effcf108b24f5f1db213c082ed17a6f7ee302b2	108	6192` — hash, line and byte counts all equal the current blob. Pointer freshness exact. Exactly 1 matching row (no duplicate membership).
- Frozen-before `stamps.tsv` (sha256 `0ce7fa4f97faef5ea8317fadaf5e412e8e5bfef2db532d57cb92b8af43c14e5b`, equal to the pre-c2 revision value in `frozen/before/expected.json`) line 28: `corpus/knowledge/substrate-deferral.md	168890519978a96095bba797cfe0fb1a5d4ae94a23a71df23f81e193b8963c98	93	5338` — the old triplet was retained as evidence, not overwritten silently.
- `.ufo/waves/round-22/pin-migrations-integration.json` lines 303–313 record this path with `old_stamp` = the exact `1688905…/93/5338` row, `base_observed` = base blob facts, `new_stamp` = the exact `ec8800c8…/108/6192` row, disposition "Reviewed current round-22 artifact; historical source facts remain historical. See round-22 lesson and named per-entry audit." Old and new both preserved; the row never left membership (now 69 rows; R12-03 migrated 63→69 with both values recorded).
- `corpus/revision-audit.py --history c2cab35…` returns `REVISION_AUDIT: CLEAN (stale=0 missing=0 dropped=0 added=6 invalid=0)`, exit 0 — matches the manifest `revision_audit` expected values (`added=6`, all else 0). This path is stamped, present, current. Rerun-once duty stays with the parent; this is the single independent observation of this entry.

## 3. Erratum calibration vs the build-wave recommendation (build/Entry20.md §5, lines 56–67)

Entry20 recommended appending: (1) 2026-10-20 recheck with six substrate paths absent; (2) the counter delta (census `diverged=2 gone=22`, AGENTS.md cause, scope breadth 5/1, drift-pins/checklist unchanged) and "2026-10-14 numbers are historical"; (3) the `-x`-predicate erratum; (4) the "0 code changes" overbroad-claim correction, marking line 8's census fragment as an excerpt (`diverged=1` present historically); and no changes to tag grammar, contract or bounds. The landed erratum covers items (1)/(2) as dated-counter history and (3) as the executable-bit/predicate limit, but is narrower than the recommendation on two points (§4). Constraints held: no second `Reverify:` line, append-only, no stamp regeneration, no expectation edit without old/new evidence (R11-09 97→108 and R18-03 are recorded with old text in `pin-migrations-integration.json` lines 404–407).

## 4. Findings

**F1 (calibration, medium): the erratum does not mark the dated-counter misreadings it names.** It says "The original host-gate figures above are the round-18 observations, not current counters" and "The recheck rows do not measure every quoted historical counter", but the original lines are not marked: line 4 still reads "Source basis: host census re-run 2026-10-14", line 8 still presents the backticked census fragment (which historically included `diverged=1`, omitted without ellipsis) as the gate line, and the `## The problem` block still states "Every live gate correctly fails closed" with the round-18 counts in present tense. No inline historical marker, no excerpt notation, no per-quote date. A fresh reader cannot tell which counters are historical without reading the erratum and connecting it back. QA10/QM14 bar: "preserve the rejected reading and append the correction" is met for the two corrected claims, but the counter staleness marking is only at the erratum, not at the claims. **Correction:** append per-quote markers (e.g. `[historical 2026-10-14]` at line 4 and before the line-8 fragment, noting the omitted `diverged=1`), or one sentence in the erratum explicitly enumerating which quoted figures are superseded. Append-only; no byte before 5338 may move.

**F2 (calibration, low): the "0 code changes" correction is half-marked.** The erratum declares the round-18 claim overbroad and names the legitimate mechanism (isolated selftest skip handling) but does not restate the corrected form (live gate readings on an absent substrate remain unfixable in code; hermetic selftest skip paths can change). The old sentence at line 21 is left standing with only a pointer-distance correction. Acceptable under append-only history, but the correction could be one clause stronger. **Correction:** append the positive restatement; no edit to the original sentence.

**F3 (calibration, low): pointer-freshness mismatch inside the entry itself.** The erratum says "Current selftest totals are read from executed output and their migrated ledger pins, not the old sample count", while the entry's own `## Reproduction` still shows `bash corpus/claim-ledger.sh --selftest   # cases 95-97 prove both arms`, which at the integrated revision is false (R11-09/R18-03 now pin 108; the substrate cases moved). A reader following the entry's own reproduction block at this revision gets a stale case reference. This is exactly a "recheck rows do not measure every quoted historical counter" instance that the erratum's own principle flags. **Correction:** append one line noting the reproduction block's case numbers are historical and the current pins are R11-09/R18-03 at 108; never edit the original line.

**F4 (freshness, low): recheck rows still cannot observe the counter deltas.** The `Reverify: R18-01, R11-09` declaration is unchanged, and its two rows (drift absence pin; ledger selftest count) still do not measure census or scope-breadth counters — the exact freshness gap Entry20 flagged. The erratum discloses this ("no host gate was run in this round") honestly, so this is a residual known gap, not a new defect introduced by the append. No new claim row for a census-counter recheck appears in `corpus/claim-ledger.tsv` (rows R11-01/02/03 unchanged; no added row in the round-22 migration evidence). **Correction (parent duty, not this wave):** a census-counter recheck row (or a dated recheck note) should be opened so the delta becomes observable at the next recheck event.

**F5 (freshness, info): stamp row is now exact, so the entry's stamp migration is complete and evidenced.** No residual action for this path. The row is not one of the six base-stale rows and was never a dropped member; `historical-correction-pins.json` covers later post-landing corrections for other paths, not this one.

**F6 (calibration, verified-clean): predicate erratum is accurate against the code.** `substrate_present()` (`corpus/claim-ledger.sh:143-150`) is `[[ -x "$HOME/.local/bin/the-janitor" ]]` with the env override — an executable-bit predicate that does not exclude a searchable directory, exactly as the erratum states. The erratum does not overstate the fix (none was made); it marks the limit. Correct.

**F7 (freshness, verified-clean): no laundering.** Old stamp value retained verbatim in frozen-before snapshot and migration record; migration disposition names the audit; the erratum dates its own claims ("no host gate was run in this round", "Current selftest totals are read from executed output") without asserting the absent 2026-10-20 host-gate run; the hash pins never promote absent source facts to current (QA6/QM14 language holds: hash/count/bytes measure pointer integrity only). The historical erratum pointer `Audit: kagi-shokunin/.ufo/waves/round-22/build/Entry20.md` resolves (file exists; §1 verdict lines 8–19 confirm).

## 5. Verdict

**ADMISSIBLE with two bounded append-only marking gaps (F1, F3; F2 minor).** The integrated change to this entry is a pure 15-line append (prefix proven byte-identical), its stamp row is exact at the integrated bytes with full old/new migration evidence, and the append's claims are accurate against code and evidence — including the `-x` predicate limit and the honest disclosure that no host gate ran. It correctly distinguishes pointer freshness (exact) from unavailable source facts (round-18 counters remain historical, not reverified). It does not fully mark the historical counters at their original locations (F1) and its own reproduction block carries a stale case-number pointer (F3); both are one-sentence append-only corrections. No depth claim, no legacy-header count claim, no reverify-row laundering. **Residual risk:** if F1/F3 stay unmarked, a reader can still quote round-18 counters or the 95–97 case numbers as current from the entry body alone.

## 6. Verification scope and limits

- All hash/byte/line values above are observed reads of the frozen input, the landing blob, the current worktree file and both stamp snapshots at the stated revisions, 2026-10-20.
- `revision-audit.py --history c2cab35` executed once (parent retains the global rerun); its CLEAN summary for this path is a by-product, not an admission.
- No host gate was executed; no census/scope/checklist counter was measured in this wave. The round-18 counter values quoted in the entry are historical narrative evidence and were not independently re-verified here (nor re-verified by the build wave — Entry20's census/breadth values were static reproductions, per its §8).
- Installs: none. No tool was installed or updated.
