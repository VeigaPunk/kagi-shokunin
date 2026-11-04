source: S083, S084, S085, S086, S087, S088; plans/round-34.md; corpus/lessons/round-33-verifier-spotcheck.md
verified-at: 2026-11-04 — L1 opened the six sources below; BASE controls executed before freeze, plan commit 5a2f145ee80b6879a833c2e70d16f2671d103367
recheck: on-change — bash corpus/self-description-sweep.sh; bash corpus/prefreeze-control.sh --selftest; bash corpus/sources-census.sh

# Round 34 — bounded self-description checks and observed prefreeze failures

BASE is f9dc06fd8f6b43c175193c76dc6350468f551634. Frozen predicates remain in plans/round-34.md; no target is amended by this lesson. The three claims are C1 calibration (SD7–SD9 sum 5→0), C2 operability (prefreeze selftest 11→12 plus M7 receipt), and C3 coverage (AccessKey entry plus frozen registry/census readings). Every scalar axis stays 9→9; numbers are not promoted into new expertise scores.

## Gate

All access dates below are **2026-11-04**, independently opened by the L1 using the listed URLs. Quotes are located spans, each at most 25 whitespace-delimited words. Chinese/Japanese quotes are deliberately short; these are public documentation, not credential values.

| Row | URL | Located quote | Scope |
|---|---|---|---|
| S083 | https://help.aliyun.com/zh/ram/user-guide/rotate-accesskey-pairs-of-ram-users | Introduction: “每个RAM用户最多可以创建两个访问密钥（AccessKey）。” | RAM-user quota and overlap rotation; not root-account identity |
| S084 | https://help.aliyun.com/zh/ram/delete-idle-accesskey-pairs-of-ram-users | 最佳实践: “推荐通过临时访问凭证（STS Token）访问阿里云OpenAPI。” | STS preference; idle-key action remains conditional on whether a consumer still contains it |
| S085 | https://help.aliyun.com/zh/kms/key-management-service/user-guide/manage-and-use-ram-secrets | 删除RAM凭据: “不会在RAM中删除RAM用户的AccessKey。” | KMS credential deletion is not RAM AccessKey retirement |
| S086 | https://help.aliyun.com/zh/ram/support/faq-about-accesskey-pairs | 什么是AccessKey, important note: “只在创建时显示一次，后续无法查看。” | Secret-display boundary; recycle-bin recovery is RAM-user scoped |
| S087 | https://www.alibabacloud.com/help/ja/ram/user-guide/rotate-accesskey-pairs-of-ram-users | 次のステップ: “このローテーションを 90 日ごと、またはそれより早いタイミングで繰り返してください。” | Japanese vendor rendering; tier B, not independent product authority |
| S088 | https://raw.githubusercontent.com/VeigaPunk/kagi-shokunin/97b35ceec87cceac25d1e0e5f92f75c953728802/corpus/prefreeze-control.sh | Header measurement rule: “Measurement = the final run of digits on the LAST” | Own-work implementation at a fixed published revision; not command truth or confinement |

**ADMIT:** corrected `corpus/knowledge/aliyun-accesskey-credential-custody.md` on uncovered cloud-IAM credential-custody ground, citing S083–S087. Rotation, idle-key disable observation, recycle-bin retention and KMS deletion are separate clocks. `corpus/knowledge/prefreeze-controls.md` gains the provenance trio and S088 rather than slipping into the legacy exemption again.

**REJECT as staged:** the package's `aliyun-accesskey-credential-custody-r38.md` says the application “never holds an AccessKey” and compresses idle-key governance. S085 expressly retrieves an effective AccessKey by credential name; S084 requires checking whether an idle key remains configured. Flip: a revised entry preserving those boundaries, the RAM-user-only recycle-bin scope, and the distinction between KMS credential deletion and RAM key deletion. The installed corrected entry clears this flip; the original staged bytes are not adopted unchanged.

ScribeEntry's five `source:` lines followed the L1's erroneous seat instructions but violate the existing census's single-line rule. Installation consolidates them to **one** line without changing the cited five documents. ScribeRows' independent fetch bodies were removed with its scratch; its digests are not falsely attributed to ScoutSources' different bodies. Installed capture rows instead recompute raw/normalized digests from the preserved `build/src-open/` files; all five quoted spans locate under the declared normalizer.

**Assimilation:** one AccessKey-custody theme, one entry. Staged ids S140→S083, S141→S084, S142→S085, S143→S086, S145→S087, by document. Full-package collision intersection has 31 ids; selected ids have none. The eight unselected quarantine rows remain quarantined, with no new truth verdict. Lists and the indented-row guard witness are under `.ufo/waves/round-34/assimilation/`. Scratch fleet and lane census receipts are exit 0 before registry append.

**considerthese:** latest file `considerthese/2026-10-26.md` reopened. Proposal 1 requires operator HOLD policy; proposal 2 already landed in round 31; proposal 3's tokenizer defect is already repaired; proposal 4 asks to edit operator-authored considerthese state. None selected. No claim that the stale reflection's HOLD description is current policy.

**Outside spot-check:** not yet performed by a non-author integrator. Dispatched seats remain part of this lane and cannot supply independent admission or SHONEN checkmarks.

## Mistakes

| id | class | evidence | captured-by | fix shown able to fail |
|---|---|---|---|---|
| M34-1 | a new entry bypassed provenance checks by entering the legacy bucket | R33-4; prefreeze-controls.md had Reverify R33-01 but no trio; BASE SD9=1 | QM35 | delivered sweep on the BASE extraction prints SD9=1; adding the trio is the production delta; SD9 planted fixture is the executable red witness |
| M34-2 | a declared closure lacked observed failure evidence | R33-2/R33-3; old report said M7 failed and relative-work was re-tested without final-byte receipts | QM36 | build/mut/m7-shipped-11.txt records the actual base-isolation failure; receipts/gate-unfixed-relative-work.txt records the failure when absolute work-root resolution is removed |
| M34-3 | mixed-claim target arithmetic was frozen without measuring the target population | plans/round-34.md C3 expects sourced=13, but 12 BASE + migrated prefreeze entry + AccessKey entry =14; migrated own-work provenance also needs S088, giving rows/captures=88, not87 | QM34 | no claim of repaired frozen arithmetic: C3 is NOT ADMITTED; targets remain unchanged, not retrospectively rewritten |
| M34-4 | seat instruction contradicted an existing schema | five-source-line acceptance in build-spec.json versus census code requiring one source line | QM35 | the untransformed draft fails SC_ENTRY_HEADER multiple source lines; installation consolidates the same five ids into one line |
| M34-5 | literal receipt counter ignored output padding | C2 frozen grep expects CASE base-isolation FAIL, while ck prints a padded label | QM36 | m7-run.sh retains raw output and explicitly labels its normalized derived verdict; the receipt counter reads that derived verdict, not a falsely claimed raw match |

## Migrations and routed dispositions

- R33-1: three complete SKILL gate-registry rows added (prefreeze-control, self-description-sweep, feed-token-agree). SD7 only checks basename presence, not row semantics; registry review is still necessary.
- R33-2: actual M7 receipt retained; round-33's claim of a run was unsupported at that time, even though the experiment can now be reproduced.
- R33-3: relative-work case added with failure witness against the unfixed mutation.
- R33-4: prefreeze entry trio added, cited to own-work S088; legacy population 22→21.
- R33-5: README lesson range becomes M33-1..M33-4. README and PROVINCE's stale “ten cases” become 12 for the current prefreeze selftest. Historical round-33 records are not silently rewritten.
- R33-6: the fleet census prints per-lane ok/warnings; the detailed SOURCES_CENSUS summary belongs to the lane script. This round cites separate receipts for each.
- R33-7: this round preserves the executed docs audit output rather than reconstructing its counts from memory.
- Registry: six rows added (five external + own-work S088); existing status/recheck/used-by cells unchanged. Selected staged recheck prose becomes 180d; provenance conditions remain in this Gate.

## Boundaries

SD7 can be satisfied by a filename anywhere in SKILL; SD8 does not prove lower endpoints or contiguous ranges; SD9 proves field presence, not semantic truth. The three integrator-owned SD6 unresolved citations remain outside C1's frozen target and are reported, not edited. The sweep reads working-tree files; committed measurement requires a named snapshot. Nothing here demonstrates cloud account operations, vault access, a restored handler, or independent promotion.

## Settled wave and adversarial corrections

WAVE-DONE received from the orchestrator for all13 seats; `.ufo/waves/round-34/build-results.json` is the settlement record. The same ExecSD identity was resumed, not replaced or counted as another seat, to close two selftest escapes. MutSweep found M5 (drop the round gate) and M6 (check source only) survived the first ten-case selftest. The clean fixture now includes a pre-round30 entry without a trio, and SD9 checks both an all-missing entry and a source-only entry inside the same case. The frozen10-case tally is unchanged. Retained `build/receipts/sd9-hardening-m5.txt` and `sd9-hardening-m6.txt` show each mutant FAIL; `sd9-hardening-selftest.txt` shows PASS.

ReviewC1 demonstrated the frozen awk counter maps SETUP or empty output to0; this defect is not silently repaired after freeze. Final evidence must therefore show the real producer verdict and all three component values as well as the unchanged integer. Presence-only SD7/SD9 and SD8's upper-endpoint scope remain the declared bounds. The freeze helper deduplicates range tokens and reads the first admission id, unlike the delivered sweep; agreement at the observed BASE does not imply universal equivalence.

ReviewC2 found M7 also fails relative-work because both cases observe the changed file at the old revision. This is a legitimate additional failure, not isolated base-isolation-only evidence. C2's frozen predicate requires the named failure, not exclusivity; both raw failures are retained. The receipt's normalized summary is explicitly derived from the actual padded output, with original and mutant digests retained.
