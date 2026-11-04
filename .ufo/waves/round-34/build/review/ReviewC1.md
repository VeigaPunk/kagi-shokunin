# ReviewC1 — round-34 C1 attack review

Verdict recommendation: **C1 defect: frozen counting pipeline treats SETUP/no measurement as SD789_SUM=0.** The delivered SD7–SD9 implementation passes the ordinary frozen controls and requested non-trigger fixtures. This is a counter-level defect/advisory, not a request to change the frozen predicate during this round and not an admission decision.

Axes: calibration, operability, coverage. No network/vault access, installs, subagents, lane-file edits, or other runtime invocation.

## Findings by severity

### Medium — SETUP falsely reads as the numeric target

Frozen `plans/round-34.md` §C1's awk command has no requirement that a verdict contain SD7/SD8/SD9 or that the producer evaluate successfully. Delivered `self-description-sweep.sh:56,75–76` preserves SETUP exit 2; missing required documents also exit 2. An empty-root fixture produced `SELF_DESCRIPTION: SETUP missing PROVINCE.md under root`, yet the exact awk expression printed `0`; instrumented pipeline statuses were `2 0 0` (sweep, tee, awk). Without pipefail, the pipeline succeeds. This is not evidence of a measured zero. Keep the frozen reading, but require a genuine evaluated verdict/producer status in admission evidence; do not mistake this attack's zero for C1 closure.

### Low — SD9 plan/control scope ambiguity

The frozen prose says an entry whose `Reverify:` line names an R>=30 requires the trio. The delivered header at :30 and implementation at :459 restrict this to the **first** `^Reverify: ` line, exactly matching controls.tsv row 3. A first `Reverify: R29-01` followed by `Reverify: R33-01`, or `Reverify:R33-01` without a space, bypasses SD9 and returns CLEAN. ExecSD confirms its assignment explicitly binds first+space. Therefore this is a documented plan/control ambiguity, not a demand to silently widen the counter. If the prose's unrestricted reading governs, these are concrete false negatives; under the pinned controls they are excluded.

## Review provenance and boundaries

Read frozen plan first, inspected actual BASE-to-deliverable diff and new check bodies. Artifact was initially absent; scheduled 30-second checks saw poll 3 absent and poll 4 delivered. Reviewed the delivered script, not a BASE-script fallback. SHA-256: `7d627d0b85e204272d1869b35b05f29820f4d2c6ddb1798ccac514a2f364bb99` (unchanged at end of fixture attacks). Artifact path:
`/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh`.

LSP device unavailable: reading `xd://lsp` returned `No such tool`. No semantic references/definition/diagnostics results are claimed. Actual diff plus runtime fixtures are evidence. No full gates/lint/format/build run. Only assigned attack/counting measurements and the plan's second reading were executed. An initial BASE measurement driver accidentally repeated the BASE call and was interrupted at 120 seconds before retained output; subsequent completed measurements below are the evidence, not the interrupted attempt.

## Fixture construction and command convention

All temporary paths were under `/fast/scratch/hyaku/kagi-r34/ReviewC1`; `TMPDIR` explicitly set to its `tmp` child. BASE extracted with:

```sh
git -C /home/vgpnk/Projects/shokunin/kagi-shokunin archive f9dc06fd8f6b43c175193c76dc6350468f551634 | tar -x -C /fast/scratch/hyaku/kagi-r34/ReviewC1/base
```

No fixture git mutation. In commands below `D` is the absolute artifact above, and `F=/fast/scratch/hyaku/kagi-r34/ReviewC1`. Each attack was run as `bash "$D" --root "$F/<case>" | tee "$F/<case>.out" | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'`, followed by `printf 'PIPESTATUS=%s\n' "${PIPESTATUS[*]}"`. Tee only retained the producer output, without changing the frozen awk parser. Commands and complete retained output follow.

Minimal common fixture files (JSON maps paths relative to each absolute fixture root to their exact contents):

```json
{
  "LOG.md": "# Fixture\n",
  "SKILL.md": "# Fixture\n",
  "PROVINCE.md": "# Fixture\n- **Core \u2014 OIDC workload-federation:** held.\n- **Frontier:** unrelated.\n",
  "corpus/README.md": "# Fixture\n## Frontier\n- unrelated\n",
  "SHONEN.md": "# Fixture\n",
  "corpus/lessons/round-31.md": "| M31-1 | fixture |\n",
  "SCORECARD.md": "lane-status: open\n## Round 30\n| calibration | held |\n",
  "corpus/claim-ledger.sh": "#!/usr/bin/env bash\nprintf 'CITATION_GATE: CLEAN (cites=0)\\n'\n"
}
```

Each tree also has `corpus/knowledge/`. Per-case additions/overrides:

- `code-fence`: `{"SKILL.md": "# Fixture\n```sh\nexample.sh\n```\n", "corpus/example.sh": "# --selftest\n"}`
- `changelog`: `{"SKILL.md": "# Changelog\nMention example.sh only.\n", "corpus/example.sh": "# --selftest\n"}`
- `legit-range`: `{"corpus/README.md": "# Fixture\nM33-1..M33-4\n", "corpus/lessons/round-33.md": "| M33-1 | row |\n| M33-2 | row |\n| M33-3 | row |\n| M33-4 | row |\n"}`
- `legacy`: `{"corpus/knowledge/example.md": "# Legacy entry\n"}`
- `R29`: `{"corpus/knowledge/example.md": "# Entry\nReverify: R29-01\n"}`
- `empty-trio`: `{"corpus/knowledge/example.md": "# Entry\nReverify: R33-01\nsource:\nverified-at:\nrecheck:\n"}`
- `empty-source`: `{"corpus/knowledge/example.md": "# Entry\nReverify: R33-01\nsource:\nverified-at: 2026-11-04\nrecheck: 30d\n"}`
- `unlisted`: `{"corpus/example.sh": "# --selftest\n"}`
- `bad-range`: `{"corpus/README.md": "# Fixture\nM33-1..M33-3\n", "corpus/lessons/round-33.md": "| M33-1 | row |\n| M33-2 | row |\n| M33-3 | row |\n| M33-4 | row |\n"}`
- `no-provenance`: `{"corpus/knowledge/example.md": "Reverify: R33-01\n"}`
- `no-corpus`: empty directory, no common files.
- `Reverify-multiple`: `{"corpus/knowledge/example.md": "Reverify: R29-01\nReverify: R33-01\n"}`
- `Reverify-no-space`: `{"corpus/knowledge/example.md": "Reverify:R33-01\n"}`

`lesson-deleted` has the same `M33-1..M33-3` claim as `bad-range` but only lesson rows M33-1 through M33-3: the contradictory M33-4 row is absent. `checks-deleted.sh` is a scratch copy of the delivered script with the block from `# SD7 — shipped selftesting scripts` up to (not including) the verdict separator removed; counters remain initialized to zero. `BASE-cosmetic` copies BASE and makes only these changes: append a code fence naming the three missing basenames to SKILL.md; omit the M33-4 lesson row; prepend empty `source:`, `verified-at:`, `recheck:` lines to prefreeze-controls.md. No registry rows are added, no doc range corrected, no meaningful provenance supplied.

## Executed attacks and observed lines

### code-fence

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/code-fence | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/code-fence.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: CLEAN n=0
0
PIPESTATUS=0 0 0
```

### changelog

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/changelog | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/changelog.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: CLEAN n=0
0
PIPESTATUS=0 0 0
```

### legit-range

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/legit-range | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/legit-range.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: CLEAN n=0
0
PIPESTATUS=0 0 0
```

### legacy

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/legacy | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/legacy.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: CLEAN n=0
0
PIPESTATUS=0 0 0
```

### R29

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/R29 | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/R29.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: CLEAN n=0
0
PIPESTATUS=0 0 0
```

### empty-trio

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/empty-trio | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/empty-trio.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: CLEAN n=0
0
PIPESTATUS=0 0 0
```

### empty-source

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/empty-source | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/empty-source.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: CLEAN n=0
0
PIPESTATUS=0 0 0
```

### unlisted

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/unlisted | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/unlisted.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
MISMATCH SD7 corpus/example.sh mentions --selftest but SKILL.md never names example.sh
SELF_DESCRIPTION: MISMATCH n=1 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=1 SD8=0 SD9=0)
1
PIPESTATUS=1 0 0
```

### bad-range

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/bad-range | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/bad-range.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
MISMATCH SD8 corpus/README.md:2 range 'M33-1..M33-3' row '| M33-4 ' exceeds upper endpoint M33-3
SELF_DESCRIPTION: MISMATCH n=1 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=0 SD8=1 SD9=0)
1
PIPESTATUS=1 0 0
```

### no-provenance

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/no-provenance | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/no-provenance.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
MISMATCH SD9 corpus/knowledge/example.md missing source: verified-at: recheck:
SELF_DESCRIPTION: MISMATCH n=1 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=0 SD7=0 SD8=0 SD9=1)
1
PIPESTATUS=1 0 0
```

### no-corpus

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/no-corpus | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/no-corpus.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: SETUP missing PROVINCE.md under root
0
PIPESTATUS=2 0 0
```

### Reverify-multiple

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/Reverify-multiple | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/Reverify-multiple.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: CLEAN n=0
0
PIPESTATUS=0 0 0
```

### Reverify-no-space

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/Reverify-no-space | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/Reverify-no-space.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: CLEAN n=0
0
PIPESTATUS=0 0 0
```

### BASE-final

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/base | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/BASE-final.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
MISMATCH SD6 corpus/lessons/round-30-verifier-spotcheck.md:41 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-32-verifier-spotcheck.md:54 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-33-verifier-spotcheck.md:90 knowledge/corpus/knowledge/ (shorthand)
MISMATCH SD7 corpus/prefreeze-control.sh mentions --selftest but SKILL.md never names prefreeze-control.sh
MISMATCH SD7 corpus/self-description-sweep.sh mentions --selftest but SKILL.md never names self-description-sweep.sh
MISMATCH SD7 corpus/feed-token-agree.py mentions --selftest but SKILL.md never names feed-token-agree.py
MISMATCH SD8 corpus/README.md:95 range 'M33-1..M33-3' row '| M33-4 ' exceeds upper endpoint M33-3
MISMATCH SD9 corpus/knowledge/prefreeze-controls.md missing source: verified-at: recheck:
SELF_DESCRIPTION: MISMATCH n=8 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=3 SD7=3 SD8=1 SD9=1)
5
PIPESTATUS=1 0 0
```

### current-final

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /home/vgpnk/Projects/shokunin/kagi-shokunin | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/current-final.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
MISMATCH SD6 corpus/lessons/round-30-verifier-spotcheck.md:41 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-32-verifier-spotcheck.md:54 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-33-verifier-spotcheck.md:90 knowledge/corpus/knowledge/ (shorthand)
MISMATCH SD7 corpus/prefreeze-control.sh mentions --selftest but SKILL.md never names prefreeze-control.sh
MISMATCH SD7 corpus/self-description-sweep.sh mentions --selftest but SKILL.md never names self-description-sweep.sh
MISMATCH SD7 corpus/feed-token-agree.py mentions --selftest but SKILL.md never names feed-token-agree.py
SELF_DESCRIPTION: MISMATCH n=6 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=3 SD7=3 SD8=0 SD9=0)
3
PIPESTATUS=1 0 0
```

### lesson-deleted

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/lesson-deleted | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/lesson-deleted.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
SELF_DESCRIPTION: CLEAN n=0
0
PIPESTATUS=0 0 0
```

### checks-deleted

```sh
bash /fast/scratch/hyaku/kagi-r34/ReviewC1/checks-deleted.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/base | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/checks-deleted.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
MISMATCH SD6 corpus/lessons/round-30-verifier-spotcheck.md:41 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-32-verifier-spotcheck.md:54 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-33-verifier-spotcheck.md:90 knowledge/corpus/knowledge/ (shorthand)
SELF_DESCRIPTION: MISMATCH n=3 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=3 SD7=0 SD8=0 SD9=0)
0
PIPESTATUS=1 0 0
```

### BASE-cosmetic

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/BASE-cosmetic | tee /fast/scratch/hyaku/kagi-r34/ReviewC1/BASE-cosmetic.out | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'; printf "PIPESTATUS=%s\n" "${PIPESTATUS[*]}"
```

```text
MISMATCH SD6 corpus/lessons/round-30-verifier-spotcheck.md:41 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-32-verifier-spotcheck.md:54 corpus/README.md:64/65/67 (local)
MISMATCH SD6 corpus/lessons/round-33-verifier-spotcheck.md:90 knowledge/corpus/knowledge/ (shorthand)
SELF_DESCRIPTION: MISMATCH n=3 (SD1=0 SD2=0 SD3=0 SD4=0 SD5=0 SD6=3 SD7=0 SD8=0 SD9=0)
0
PIPESTATUS=1 0 0
```

## Interpretation of requested attacks

- **Deleting checks:** succeeds at producing sum 0 against unfixed BASE; retained SD6=3 means sweep still exits 1. Counter cannot attest to the integrity of its own instrument. BASE red replay and selftest evidence are necessary safeguards.
- **Junk SKILL names / registry location:** code-fence and changelog-only names both return CLEAN in isolated fixtures. This is correct against frozen SD7's “appear at least once” predicate; SD7 is not proof of a full gate registry row. Combined cosmetic BASE attack reaches SD789=0.
- **Editing lesson rather than doc:** contradictory M33-4 present gives SD8=1; removing that row, retaining doc range M33-1..M33-3, gives CLEAN. Expected for a consistency-only predicate; the check cannot attest to preserving historical lesson content.
- **Empty source:** empty `source:` with populated dates passes; even all three empty lines pass. This matches presence-only SD9. It does not establish usable provenance.
- **No corpus root:** SETUP rc2 but numeric 0, the medium finding above.
- **Required false-positive fixtures:** code-fence-only script, legitimate M33-1..M33-4 range, legacy entry without Reverify, and R29-01 entry all returned CLEAN; none fired.
- **Required false negatives / BASE red witness:** delivered script on the complete unfixed BASE printed SD7=3 SD8=1 SD9=1 (sum 5), preserving SD6=3 and exit 1. Individual unlisted-gate/bad-range/no-provenance fixtures each fired only the intended new component.

## Exact frozen counting command, reachability, and second reading

The exact counting pipeline (absolute script and --root supplied as requested, no tee) was also executed:

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /fast/scratch/hyaku/kagi-r34/ReviewC1/base | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'
```
Observed BASE: `5`; pipeline exit `0`.

```sh
bash /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/self-description-sweep.sh --root /home/vgpnk/Projects/shokunin/kagi-shokunin | awk -F'[ =()]' '{for(i=1;i<NF;i++) if($i ~ /^SD[789]$/) s+=$(i+1)} END{print s+0}'
```
Observed current: `0`; pipeline exit `0`.

The current lane tree changed during review: the earlier retained run was SD7=3 SD8=0 SD9=0 (sum 3), while the later exact pipeline returned 0. These are time-separated observations, not contradictory readings of an immutable landing revision. BASE extraction remains immutable and returned 5. The current zero is reachable; final landing-revision bytes, producer status and component verdict remain L1 verification responsibilities. SD6 remains a named exclusion, not a reason to call the full sweep CLEAN.

Second reading command: `bash "$D" --selftest` with explicit scratch TMPDIR. Observed:

```text
CASE clean ok
CASE SD1 ok
CASE SD2 ok
CASE SD3 ok
CASE SD4 ok
CASE SD5 ok
CASE SD6 ok
CASE SD7 ok
CASE SD8 ok
CASE SD9 ok
SELFTEST: PASS (10 cases)
exit=0
```

## Residual risk and verification gaps

No immutable landing revision was supplied during this live build wave. C1's numeric target was observed at the current tree at the final counting time, not admitted here. A zero alone is weaker than registry completeness, valid provenance or retained lesson history by construction of the frozen predicates. Main should retain genuine component verdict/status alongside the frozen count and bind final evidence to its landing revision. No C2/C3, unrelated runtime, rerouting or saturation assertion was evaluated.

Self-evaluation: accuracy 4/5 (live-tree timing explicitly distinguished); completeness 4/5 (all requested attacks executed, final immutable revision unavailable); clarity 4/5 (commands and fixture bytes retained, report necessarily lengthy); actionability 4/5 (counter failure named without changing frozen rules); conciseness 4/5 (receipt detail retained for reproducibility). Overall 4.0/5. Improvement with greatest impact: L1 pins landing bytes and records producer verdict/status with its final numeric counter. Would the user agree? Likely, given the explicit split between implementation behavior and predicate limitations.
