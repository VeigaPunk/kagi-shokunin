# SelfInvSkill5 — C1 inventory, SKILL.md:521-650

Revision: BASE 4587c61a348e4528717404a68912c373f3ef4d03 (real lane HEAD identical). Live values come from sandbox clone `/fast/scratch/kagi-r25/SelfInvSkill5/lane` (git status clean), hermetic runs under `env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/SelfInvSkill5/home`. Real lane tree: read/grep only. Installs/updates: none.
Population: every digit-bearing line and count word in 521-650. Round-dated bullets are HISTORICAL by the doc's own rule (SKILL.md:557-560); present-tense or registry text is CURRENT.

| file:line | phrase | CURRENT/HISTORICAL | claimed | live | source (ledger id or command) | STALE? |
|---|---|---|---|---|---|---|
| SKILL.md:525 | "`op.env` is pinned by mode + line count + a `#10` count pin" | CURRENT | `#10` | `#10` lane pin (drift-symbols.tsv:22); host match count UNRUN | drift-symbols.tsv:22 (`grep -n op.env corpus/drift-symbols.tsv`) | no |
| SKILL.md:543 | "Both files are reviewed commits by design" (surface-census.tsv, drift-baseline.tsv) | CURRENT | 2 | 2, both git-tracked | `git ls-files corpus/surface-census.tsv corpus/drift-baseline.tsv` | no |
| SKILL.md:584 | "zero script references" (host config.json) | HISTORICAL (Round-6, :580) | 0 | UNRUN (host file, mode 600, never read) | none (host-only) | n/a |
| SKILL.md:583 | "resolved `steps: 4` ≠ its `steps: 8`" | HISTORICAL (Round-6) | 4 / 8 | 4 = lane pin drift-symbols.tsv:23 (janitor.md:6); 8 UNRUN | drift-symbols.tsv:23 | no / n/a |
| SKILL.md:602 | "`select count(*) from credential` ⇒ 0" | HISTORICAL (Round-8, :597) | 0 | UNRUN (host transcript DB, credential-adjacent) | none (host-only) | n/a |
| SKILL.md:606-607 | "`DRIFT_PINS: CLEAN (files=15 symbols=19)`" | HISTORICAL (Round-9, :604) | files=15 symbols=19 | files=15, symbols=20; host CLEAN run UNRUN | non-#/non-blank row counts of drift-baseline.tsv and drift-symbols.tsv (drift-pins.sh:368-369 formula); R18-01 symbols_bad=20 | YES (symbols 19→20) |
| SKILL.md:607-608 | "`--selftest` ⇒ `DRIFT_SELFTEST: PASS (13 cases)`" | HISTORICAL (Round-9) | 13 | 13 (exit 0) | R11-05 | no |
| SKILL.md:617-618 | "`SURFACE_CENSUS: CLEAN (assets=20 runtime=15 scanned=4 ok=34 absent=2 skipped=0)`" | HISTORICAL (Round-10, :615) | 20 / 15 / 4; ok 34, absent 2, skipped 0 | 20 / 15 / 4; ok/absent/skipped UNRUN (host scan) | R11-11 (35 rows); awk on class column; `grep -c '^# scan'` | no (computable fields) |
| SKILL.md:618-619 | "`--verbs` ⇒ `CLEAN (pass=7 skip=3)`" | HISTORICAL (Round-10) | 7 / 3 | UNRUN (non-selftest gate; handler-dependent) | R11-02 [substrate] | n/a |
| SKILL.md:619 | "`--selftest` ⇒ `SELFTEST: PASS (16 cases)`" | HISTORICAL (Round-10) | 16 | 16 (exit 0; verb cases skip substrate-absent) | R11-03 | no |
| SKILL.md:629 | "`verify` ⇒ `CLAIM_LEDGER: CLEAN (claims=11 stamped=28)`" | HISTORICAL (Round-11, :626) | claims=11 stamped=28 | claims=61 stamped=83 (verify itself UNRUN) | R21-04 (61); R12-03 (83) | YES |
| SKILL.md:630 | "`citations` ⇒ `CITATION_GATE: CLEAN (cites≈505 docs=39 … labeled=13)`" | HISTORICAL (Round-11) | cites≈505 docs=39 labeled=13 | UNRUN (non-selftest; fleet layout, R11-08) | R11-08 | n/a |
| SKILL.md:631 | "`--selftest` ⇒ `SELFTEST: PASS (39 cases)`" | HISTORICAL (Round-11) | 39 | 151 (exit 0) | R11-09 and R18-03 | YES |
| SKILL.md:641-642 | "`OP_REF_PROBE: CLEAN (checks=44 oprun=12 refs=7 divergent=5 edge=10 sig=6)`" | HISTORICAL (Round-12, :639) | 44/12/7/5/10/6 | UNRUN (host op.env + handler) | R12-01 [substrate] | n/a |
| SKILL.md:643 | "`--selftest` ⇒ `OP_REF_SELFTEST: PASS (36 cases)`" | HISTORICAL (Round-12) | 36 | 36 (exit 0) | R12-02 | no |
| SKILL.md:640 | "`op.env` contract (two parsers)" | HISTORICAL (Round-12) | 2 | UNKNOWN (prose; no mechanical count) | none | n/a |
| SKILL.md:650 | "of the 17 `corpus/knowledge/*.md` entries" | HISTORICAL (Round-14, :649) | 17 | 25 (25 .md files; 25 Reverify lines) | `ls corpus/knowledge/*.md` count; `grep -c '^Reverify: '`; R14-01 expects entries=25 (gate not run) | YES |

CURRENT stale claims: 0 (of 2 CURRENT; the host half of :525 is UNRUN, the lane pin agrees).
HISTORICAL stale: 4 of 17 (:606-607, :629, :631, :650). Expected by rule, but each is a copy-pasteable "⇒ verdict" line.

Commands (sandbox, all exit 0):
```
env -i PATH=/usr/bin:/bin HOME=/fast/scratch/kagi-r25/SelfInvSkill5/home bash corpus/claim-ledger.sh --selftest   -> SELFTEST: PASS (151 cases)
env -i (same) bash corpus/drift-pins.sh --selftest                                                               -> DRIFT_SELFTEST: PASS (13 cases)
env -i (same) bash corpus/surface-census.sh --selftest                                                           -> SELFTEST: PASS (16 cases)
env -i (same) bash corpus/op-ref-probe.sh --selftest                                                             -> OP_REF_SELFTEST: PASS (36 cases)
grep -cv '^#\|^$' corpus/drift-baseline.tsv -> 15 ; corpus/drift-symbols.tsv -> 20 ; corpus/claim-ledger.tsv -> 61
grep -c '[^[:space:]]' corpus/stamps.tsv -> 83 ; grep -c '^# scan' corpus/surface-census.tsv -> 4
awk -F'\t' '!/^#/ && NF {print $2}' corpus/surface-census.tsv | sort | uniq -c -> asset 20, runtime 15
ls corpus/knowledge/*.md | wc -l -> 25 ; grep -c '^Reverify: ' corpus/knowledge/*.md (summed) -> 25
```
Not run (contract): drift-pins.sh and surface-census.sh default and `--verbs` (host-reading); claim-ledger.sh verify/citations/docs/cells; transcript-scan.sh; op-ref-probe.sh default; any read of op.env, config.json, opencode.db, the-janitor; `--allow-host-rows`.

Excluded (not counts of lane artifacts, or not present-tense): dates (:563, :569, :603); round labels and identifiers (`Round-10 probe` :533, cases 5/9/11/14/15/16, `policy-ref-token`, `KAGI12_POISON`); exit/HTTP codes (:565, :589-590, :599, :611-614, :620-623, :632-638, :645-646); `3600 s` lock wedge (:594, host); modes and hash fragments (`0600` :592, `deadbeef…`/`2408b0c90b7e` :609-610); 16-byte SQLite header (:623); `?immutable=1` (:537); `L248` (:647, lane pin drift-symbols.tsv:30 agrees).

Findings:
1. Calibration gap. The 4 stale values all sit in round bullets, so a CURRENT-only binder passes them. Yet each reads as a live expectation: :631 says `SELFTEST: PASS (39 cases)`, while the same command gives 151 cases, exit 0. The historical rule is not visible on the line. Options: C1 reports HISTORICAL-stale as an informational class, or the bullets carry a dated live verdict.
2. No ledger row pins the drift symbol count (20) or the knowledge-entry count (25) as a count. R18-01 carries symbols_bad=20 only in a host row; R14-01 pins entries=25 only through the gate verdict. C1 needs `rows:` sources here: non-#/non-blank rows of drift-symbols.tsv (20) and of corpus/knowledge/*.md (25).
3. The one CURRENT pin (:525, `#10`) lives in drift-symbols.tsv:22. Its host-side truth cannot be measured without reading op.env, so C1 can bind only the lane-side pin.
