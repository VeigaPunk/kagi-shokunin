=== corpus/README diff ===
diff --git a/corpus/README.md b/corpus/README.md
index b1315e0..5cae688 100644
--- a/corpus/README.md
+++ b/corpus/README.md
@@ -97,7 +97,7 @@ see `lessons/round-1.md` for the rule and its rationale.
 | Alibaba Cloud RAM AccessKey custody (round 34) | `knowledge/aliyun-accesskey-credential-custody.md` | overlapping rotation, idle-key retirement, RAM-user recycle-bin recovery, and KMS credential deletion versus RAM key deletion; S083–S087 opened 2026-11-04 |
 | Self-description extension (round 34) | `corpus/self-description-sweep.sh` | SD7 script-name presence, SD8 lesson range upper endpoints, SD9 provenance presence; three bounded checks, not semantic proof of registry completeness or provenance truth |
 | Round-35 lesson | `lessons/round-35.md` | Producer-result integrity, executed predeclaration controls, source S088 historical/current boundary and frozen-axis-fit limitation |
-| ISO/IEC 11770-3 edition status (entry, round 45) | `corpus/knowledge/iso-11770-3-edition-status.md` | the 2015 edition is withdrawn and the 2021 edition (edition 4.0) is the one in force; the 2017 amendment is withdrawn too (S100–S102; the ISO catalogue record needs a browser user agent, the default agent gets HTTP 403), all three sources opened 2026-11-05 |
+| ISO/IEC 11770-3 edition status (entry, round 45) | `corpus/knowledge/iso-11770-3-edition-status.md` | the 2015 edition is withdrawn and the 2021 edition (edition 4.0) is the one in force; the 2017 amendment is withdrawn too (S100–S102; the ISO catalogue record needs a browser user agent, the default agent gets HTTP 403), all three sources opened 2026-11-05; round 55: the 2021 edition carries ISO/IEC 11770-3:2021/Amd 1:2025 (S113, S114, opened 2026-11-07) |
 | Feed token extraction boundaries and the extractor agreement gate (entry, round 29) | `corpus/knowledge/feed-token-boundaries.md` | an Atom `atom:title` is a Text construct, so a trailing period is content and not a token boundary; the extractors' right boundary is `STABLE_TOKEN_RE`'s lookahead and never a `$` anchor, and the extractors must agree with the canonicality judge (S045, S052; row-linked to `R29-01`/`R29-02`), sources opened 2026-10-31 |
 
 Held core since round 33: NIST key-management guidance status and the Part 2/Part 3 withdrawal record — `knowledge/nist-key-management-guidance-status.md` (SP 800-57 Part 1 Rev. 5 final vs the Rev. 6 IPD held as S049; SP 800-133 Rev. 2 final vs the Rev. 3 IPD) and `knowledge/nist-key-management-parts-withdrawal.md` (the 2005 Part 2 and the 2009 Part 3 withdrawn; Part 2 Rev. 1 and Part 3 Rev. 1 current; SP 800-131A Rev. 2 the transition reference), rows S073–S082, every source re-opened 2026-11-04. The round-21 frontier lead is discharged, so the frontier list holds release clocks only.
=== ledger changed ids ===
-R13-01	grep -c '^## Round ' SCORECARD.md	^72$	0	30	current round-heading cardinality: round25 had31; round26 adds one b
+R13-01	grep -c '^## Round ' SCORECARD.md	^73$	0	30	current round-heading cardinality: round25 had31; round26 adds one b
-R21-02	bash corpus/sources-census.sh	^SOURCES_CENSUS: CLEAN \(rows=112 A=108 B=2 C=2 queued=1 mined=107 rejected=4 entr
-R21-03	bash corpus/sources-census.sh --selftest	^SOURCES_CENSUS_SELFTEST: PASS \(70 cases\)$	0	120	the census gate's sc
+R21-02	bash corpus/sources-census.sh	^SOURCES_CENSUS: CLEAN \(rows=114 A=110 B=2 C=2 queued=1 mined=109 rejected=4 entr
+R21-03	bash corpus/sources-census.sh --selftest	^SOURCES_CENSUS_SELFTEST: PASS \(78 cases\)$	0	120	the census gate's sc
-R24-06	bash corpus/row-identity.sh scorecard-rounds	^ROW_IDENTITY: scorecard-rounds count=72 sha256=358ac0823e567988b0c
+R24-06	bash corpus/row-identity.sh scorecard-rounds	^ROW_IDENTITY: scorecard-rounds count=73 sha256=eea94d35e6c9223cedc
-R31-02	bash corpus/sources-census.sh	^SOURCES_CENSUS: CLEAN \(rows=112 A=108 B=2 C=2 queued=1 mined=107 rejected=4 entr
+R31-02	bash corpus/sources-census.sh	^SOURCES_CENSUS: CLEAN \(rows=114 A=110 B=2 C=2 queued=1 mined=109 rejected=4 entr
-R33-02	bash corpus/sources-census.sh	^SOURCES_CENSUS: CLEAN \(rows=112 A=108 B=2 C=2 queued=1 mined=107 rejected=4 entr
+R33-02	bash corpus/sources-census.sh	^SOURCES_CENSUS: CLEAN \(rows=114 A=110 B=2 C=2 queued=1 mined=109 rejected=4 entr
-R34-03	bash corpus/sources-census.sh	^SOURCES_CENSUS: CLEAN \(rows=112 A=108 B=2 C=2 queued=1 mined=107 rejected=4 entr
+R34-03	bash corpus/sources-census.sh	^SOURCES_CENSUS: CLEAN \(rows=114 A=110 B=2 C=2 queued=1 mined=109 rejected=4 entr
-R38-01	bash plans/round-38-c1.sh	^10$	0	120	round 38 C1 (freshness): located-quote count of corpus/quote-bodies.tsv via
+R38-01	bash plans/round-38-c1.sh	^12$	0	120	round 38 C1 (freshness): located-quote count of corpus/quote-bodies.tsv via
