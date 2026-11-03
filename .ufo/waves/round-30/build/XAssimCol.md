# Round-30 BUILD — seat XAssimCol (C3 assimilation scratch gate)

Date 2026-11-03. Lane `kagi-shokunin`, frozen BASE `f67232cd3ae682ea1fb14d447667016f2b6ed336`,
plan `b7482b4a`. **Production registry untouched**: every write in this seat is either in
`/fast/scratch/hyaku/kagi-r30/XAssimCol/` or in
`.ufo/waves/round-30/final/c3/assimilation/`. No lane git/jj, no `op`, no credentials, no
installs.

## Verdict

The four assigned steps are done and evidenced: collision proven nonempty (`S052`, exactly one),
8-row renumber map verified **per document**, 8 rows normalized to fleet schema, and a scratch
mirror whose fleet `validate --file` exits **0** (`SOURCES_CENSUS` metrics `rows=60`).
Two findings change what the integration must do, both backed by receipts:

1. **The lane's own gate (`corpus/sources-census.sh`, C3 counter 3) rejects the adoption as the
   package ships it** — 16 findings. They collapse to two mechanical shape fixes: one `source:`
   line per entry (8 findings) and one `corpus/source-fetches.tsv` capture row per new id
   (8 findings). With both applied the lane gate reads
   `SOURCES_CENSUS: CLEAN (rows=60 …, captures=60)`, exit 0. I made both edits in a probe copy
   and captured real provenance with the declared fetch profile so the L1 can adopt directly.
2. **C3's file cannot pass the fleet census while it is CRLF** — the parser does not trim `\r`,
   so `## Registry` never matches and every row becomes `E12`. Receipt: baseline mirror (CRLF,
   unchanged rows) exit 1, `E12` ×52; same file LF-restored, exit 0. C2's LF repair must land
   with or before C3's append, or C3's counter 1 reads red for a C2 reason.

## 1. Id-collision check

Pattern (0–3 leading spaces, as in `plans/round-30.md`):
`^ {0,3}\|[[:space:]]*S[0-9]{3}[[:space:]]*\|`

reg-ids (52): S001 S002 S003 S004 S005 S006 S007 S008 S009 S010 S011 S012 S013 S014 S015 S016 S017 S018 S019 S020 S021 S022 S023 S024 S025 S026 S027 S028 S029 S030 S031 S032 S033 S034 S035 S036 S037 S038 S039 S040 S041 S042 S043 S044 S045 S046 S047 S048 S049 S050 S051 S052

staged-ids (172): S052 S053 S054 S055 S056 S057 S058 S059 S060 S061 S062 S063 S064 S065 S066 S067 S068 S069 S070 S071 S072 S073 S074 S075 S076 S077 S078 S079 S080 S081 S082 S083 S084 S085 S086 S087 S088 S089 S090 S091 S092 S093 S094 S095 S096 S097 S098 S099 S100 S101 S102 S103 S104 S105 S106 S107 S108 S109 S110 S111 S112 S113 S114 S115 S116 S117 S118 S119 S120 S121 S122 S123 S124 S125 S126 S127 S128 S129 S130 S131 S132 S133 S134 S135 S136 S137 S138 S139 S140 S141 S142 S143 S144 S145 S146 S147 S148 S149 S150 S151 S152 S153 S154 S155 S156 S157 S158 S159 S160 S161 S162 S163 S164 S165 S166 S167 S168 S169 S170 S171 S172 S173 S174 S175 S176 S177 S178 S179 S180 S181 S182 S183 S184 S185 S186 S187 S188 S189 S190 S191 S192 S193 S194 S195 S196 S197 S198 S199 S200 S201 S202 S203 S204 S205 S206 S207 S208 S209 S210 S211 S212 S213 S214 S215 S216 S217 S218 S219 S220 S221 S222 S223

collisions (comm -12; 1): S052

`comm -12` count = **1**. Exactly `S052` collides — the staged package was built from the 51-row
registry and the lane has since added its own S052 (RFC 4287). The staged set is far larger than
the 8 rows in scope (172 row-shaped ids, S052–S223), so the collision count is a property of the
package, not of the 8 adopted rows.

## 2. Renumber map (per document)

Each staged row's `source` URL was compared with the URL its entry cites in frontmatter; all 8
match, so the map is an identity-by-document, never arithmetic. The staged package's *own*
`S053`–`S060` are AWS/Google/Alibaba/Tencent/CRYPTREC rows — reusing the numbers arithmetically
would have aliased 8 unrelated documents.

```
# C3 renumber map — per document, never arithmetic
# lane holds S001-S052 (52 rows); staged package holds S052-S085.
# staged S053-S060 documents in the package (why the map cannot be arithmetic):
#   S053 = AWS IAM User Guide, Available keys for AWS OIDC federation
#   S054 = AWS STS API Reference, AssumeRoleWithWebIdentity
#   S055 = Google Cloud IAM, Best practices for using Workload Identity Federation
#   S056 = Google Cloud IAM ドキュメント（日本語）, Workload Identity 連携
#   S057 = 阿里云 RAM 用户指南，为受信身份提供商创建 RAM 角色
#   S058 = 腾讯云 密钥管理系统 产品概述
#   S059 = CRYPTREC Report 2025（暗号技術活用委員会報告；独立行政法人情報処理推進機構／国立研究開発法人情報通信研究機構）
#   S060 = Google Cloud KMS ドキュメント（日本語）, 鍵の破棄のデフォルト時間 MSA
#
# staged id	document -> new id	staged URL	entry citation URL	verdict
S066	Gitleaks README, gitleaks/gitleaks -> S053	https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md	MATCH (secret-scanning-detection-vs-validation.md)	ok
S067	TruffleHog README, trufflesecurity/trufflehog -> S054	https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md	MATCH (secret-scanning-detection-vs-validation.md)	ok
S068	Betterleaks README, betterleaks/betterleaks -> S055	https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md	MATCH (betterleaks-detection-vs-validation.md)	ok
S069	GitHub repository search API response for "betterleaks" -> S056	https://api.github.com/search/repositories?q=betterleaks&per_page=10	MATCH (betterleaks-detection-vs-validation.md)	ok
S070	TruffleHog Docs, Verification caching -> S057	https://trufflesecurity.com/docs/verification-caching	MATCH (trufflehog-verification-lifecycle.md)	ok
S071	TruffleHog Docs, How we handle your data -> S058	https://trufflesecurity.com/docs/how-we-handle-your-data	MATCH (trufflehog-verification-lifecycle.md)	ok
S072	TruffleHog Docs, Reverify secrets -> S059	https://trufflesecurity.com/docs/reverify-secrets	MATCH (trufflehog-verification-lifecycle.md)	ok
S073	TruffleHog Docs, Notify results -> S060	https://trufflesecurity.com/docs/notify-results	MATCH (trufflehog-verification-lifecycle.md)	ok
```

## 3. Normalized rows (fleet schema)

`recheck` cells were re-cut to a bare cadence (`180d`; `90d` for the search-API row). The stripped
prose is preserved verbatim in `recheck-prose-stripped.md` for the lesson Gate — it is where the
`curl … | grep -c …` probes live, including the real `|` characters that made six rows 13-pipe
malformed (`E01`) as shipped. `status=mined`, `opened=2026-11-03` (this lane's opening, not the
campaign's 2026-10-23), and `used-by` names only the entries that actually cite the row.

```
| S053 | Gitleaks README, gitleaks/gitleaks — https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md | tool | A | Gitleaks' detection semantics: regex plus optional entropy over text, with no validity check against the credential's issuer | README intro paragraph and the §"Configuration" rule fields `regex`, `secretGroup`, `entropy`; pinned at repo HEAD commit `b58d3f102cf3a2c84cb7f923d05c25c9b1aed84b` (2026-07-22) and fetch sha256 `65e87e68f4a16aef` (fetched 2026-10-23) | A gitleaks finding asserts that a credential-shaped string exists in the text, never that the credential still works | mined | 2026-11-03 | 180d | corpus/knowledge/secret-scanning-detection-vs-validation.md |
| S054 | TruffleHog README, trufflesecurity/trufflehog — https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md | tool | A | TruffleHog's detect-then-validate pipeline and its result statuses verified, unverified and unknown | README §"Validation" and §"1: Scan a repo for only verified secrets" (flags `--results=verified` and `--results=verified,unknown`); pinned at repo HEAD commit `d6ea4a52e3f4705989210e60e9f0da0deafe84bf` (2026-10-23) and fetch sha256 `068fbb5c93eb993d` (fetched 2026-10-23) | TruffleHog logs in to confirm whether a classified secret is live and reports verified, unverified and unknown, so unknown must never be read as safe | mined | 2026-11-03 | 180d | corpus/knowledge/secret-scanning-detection-vs-validation.md |
| S055 | Betterleaks README, betterleaks/betterleaks — https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md | tool | A | Betterleaks' own detection semantics — detection without credential-provider requests by default, with validation and analysis as opt-in stages | §Usage, opening line, and §Features table rows "Secrets Validation", "Secrets Analysis", "Expr-based filtering", "BPE filtering"; `main` is the v2 development branch (v1 lives on `v1.x`); pinned by fetch sha256 `f61c3993fd48dfb9` (fetched 2026-10-23) | A Betterleaks finding means whatever stage produced it, so the scan command or environment variable has to be recorded alongside the result | mined | 2026-11-03 | 180d | corpus/knowledge/betterleaks-detection-vs-validation.md |
| S056 | GitHub repository search API response for "betterleaks" — https://api.github.com/search/repositories?q=betterleaks&per_page=10 | code | A | the repository's own fork status, star count and last-push date as recorded by the code host | `items[0]` object: full_name `betterleaks/betterleaks`, `fork` false, `stargazers_count` 2322, `pushed_at` 2026-10-22T21:28:27Z; pinned by response sha256 `0c8bdbd04508489c` (fetched 2026-10-23) | Betterleaks is an independent project rather than a Gitleaks fork, so its rules are a separate design and not a patch set | mined | 2026-11-03 | 90d | corpus/knowledge/betterleaks-detection-vs-validation.md |
| S057 | TruffleHog Docs, Verification caching — https://trufflesecurity.com/docs/verification-caching | docs | A | how a TruffleHog verification result is cached, and what a cached verdict means in a scan output | §"Verification caching", cache-expiry and cache-contents paragraphs; page stamp "Updated 06 Jul 2026"; pinned by fetch sha256 `b1eb8215a66933f9` (fetched 2026-10-23) | A `verified` result may come from a cache entry up to three hours old, and the OSS output marks it "(Verification info cached)", so every verdict carries a freshness bound | mined | 2026-11-03 | 180d | corpus/knowledge/trufflehog-verification-lifecycle.md |
| S058 | TruffleHog Docs, How we handle your data — https://trufflesecurity.com/docs/how-we-handle-your-data | docs | A | the safety properties of the verification step and what the product stores about a detected credential | §"What We Don't Do" and the Verification Safety panel (read-only API calls, no state-changing operations, no raw credentials stored); pinned by fetch sha256 `aef5f76a64c9565a` (fetched 2026-10-23) | Verification is bounded to read-only API calls and the product keeps only fingerprints, so a scan can prove a credential worked without the credential being retained | mined | 2026-11-03 | 180d | corpus/knowledge/trufflehog-verification-lifecycle.md |
| S059 | TruffleHog Docs, Reverify secrets — https://trufflesecurity.com/docs/reverify-secrets | docs | A | re-verification of previously detected secrets, its trigger and the integrations it covers | §"Reverify secrets", first paragraph and the closing scope sentence; page stamp "Updated 06 Jul 2026"; pinned by fetch sha256 `2997de910834f751` (fetched 2026-10-23) | Rotation is detected by re-verifying on the next interval scan, and that re-verification currently reaches only GitHub- and Slack-detected secrets | mined | 2026-11-03 | 180d | corpus/knowledge/trufflehog-verification-lifecycle.md |
| S060 | TruffleHog Docs, Notify results — https://trufflesecurity.com/docs/notify-results | docs | B | the notifier configuration's explicit switch for unverified findings | §"Notify results", configuration snippet field `sendUnverified` and the notifier matrix; page stamp "Updated 14 Aug 2026"; pinned by fetch sha256 `417032af5635ef39` (fetched 2026-10-23) | Unverified findings reach a notifier only through an explicit switch, so notification volume and notification meaning are two separate decisions | mined | 2026-11-03 | 180d | corpus/knowledge/trufflehog-verification-lifecycle.md |
```

`used-by` derivation (bracketed `[Snnn]` or frontmatter `source: Snnn`, literal id only):

```
# used-by derivation — bracketed citation [Snnn] or frontmatter `source: Snnn`

S053 (was S066): corpus/knowledge/secret-scanning-detection-vs-validation.md
    cited in secret-scanning-detection-vs-validation.md at 16, 18
S054 (was S067): corpus/knowledge/secret-scanning-detection-vs-validation.md
    cited in secret-scanning-detection-vs-validation.md at 29, 31, 34
S055 (was S068): corpus/knowledge/betterleaks-detection-vs-validation.md
    cited in betterleaks-detection-vs-validation.md at 25, 28, 30, 36, 37, 38, 39, 45, 59, 62
S056 (was S069): corpus/knowledge/betterleaks-detection-vs-validation.md
    cited in betterleaks-detection-vs-validation.md at 15
S057 (was S070): corpus/knowledge/trufflehog-verification-lifecycle.md
    cited in trufflehog-verification-lifecycle.md at 22, 24, 25, 28, 33, 80, 100
S058 (was S071): corpus/knowledge/trufflehog-verification-lifecycle.md
    cited in trufflehog-verification-lifecycle.md at 46, 48, 83
S059 (was S072): corpus/knowledge/trufflehog-verification-lifecycle.md
    cited in trufflehog-verification-lifecycle.md at 59, 62, 65, 85
S060 (was S073): corpus/knowledge/trufflehog-verification-lifecycle.md
    cited in trufflehog-verification-lifecycle.md at 71, 73
```

Consequence: each row is used by exactly one entry. The two cross-references inside
`betterleaks-detection-vs-validation.md` (`[the round-1 row S053]`, `[round-2 rows S057-S060]`)
are scope pointers in a "what this entry does not establish" paragraph, not evidence citations, so
they are not counted; the lane's bidirectional check (`SC_ENTRY_CITE`) confirms the stricter set is
the consistent one.

Strip receipt (verbatim prose, for the Gate):

```
# Recheck prose stripped from the 8 adopted rows (verbatim; for the lesson Gate)
# S066/S067 (-> S053/S054) carried a bare `180d`; nothing was stripped from them.

## S068 -> S055 (Betterleaks README, betterleaks/betterleaks)
cadence kept: 180d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md' | grep -c 'Scans detect secrets without credential provider requests by default'` -> 1 (ran 2026-10-23)

## S069 -> S056 (GitHub repository search API response for "betterleaks")
cadence kept: 90d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://api.github.com/search/repositories?q=betterleaks&per_page=10' | python3 -c "import json,sys;d=json.load(sys.stdin);r=[i for i in d['items'] if i['full_name']=='betterleaks/betterleaks'][0];print(r['fork'],r['stargazers_count'],r['pushed_at'])"` -> `False 2322 2026-10-22T21:28:27Z` (ran 2026-10-23; the unauthenticated GitHub API is per-IP rate limited, so the stored response sha256 `0c8bdbd04508489c` is the fallback evidence)

## S070 -> S057 (TruffleHog Docs, Verification caching)
cadence kept: 180d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://trufflesecurity.com/docs/verification-caching' | grep -c 'Each cache entry expires after three hours'` -> 1 (ran 2026-10-23)

## S071 -> S058 (TruffleHog Docs, How we handle your data)
cadence kept: 180d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://trufflesecurity.com/docs/how-we-handle-your-data' | grep -c 'Credentials are verified using safe, read-only API calls'` -> 2 matching lines (ran 2026-10-23; the phrase appears in the feature list and in the Verification Safety panel)

## S072 -> S059 (TruffleHog Docs, Reverify secrets)
cadence kept: 180d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://trufflesecurity.com/docs/reverify-secrets' | grep -c 'Secret reverification is currently only supported'` -> 1 (ran 2026-10-23)

## S073 -> S060 (TruffleHog Docs, Notify results)
cadence kept: 180d
prose removed (verbatim, logical line restored at the stripped pipe):
`curl -fsSL 'https://trufflesecurity.com/docs/notify-results' | grep -c 'sendUnverified'` -> 2 matching lines (ran 2026-10-23)


```

Assertions enforced while building the rows: 11 cells each, exactly 12 pipes, no literal or
escaped `|` in any cell, no CR/LF in any cell, cadence in (180d, 90d), `opened` present-past.

## 4. Scratch mirror and census

Mirror: `/fast/scratch/hyaku/kagi-r30/XAssimCol/scratch-mirror/` (full `corpus/` copy plus the 3
re-pointed entries and the 8 appended rows). Rows were inserted at the **end of the `## Registry`
table**, immediately after `S052` and before `## Paths`; no other section touched.

1. **Baseline, file as it is in the lane (CRLF)** — exit **1**:
   `file E12 S001..S052 row outside Registry section` (52 findings, no other code).
2. **Same copy, `CRLF→LF` on `corpus/SOURCES.md` only (193 pairs), rows unchanged** — exit **0**,
   14 pre-existing `W04` warnings, last line `file ok …corpus/SOURCES.md`.
3. **After appending the 8 rows** — exit **0**, identical warning set, metrics:

```
file	rows	60
file	tier.A	57
file	tier.B	1
file	tier.C	2
file	status.mined	56
file	status.queued	1
file	status.rejected	3
FLEET	rows	60
FLEET	tier.A	57
FLEET	tier.B	1
FLEET	tier.C	2
FLEET	tier.invalid	0
FLEET	status.queued	1
FLEET	status.mined	56
FLEET	status.rejected	3
FLEET	status.invalid	0
FLEET	missing	0

```

Frozen counters, run in the mirror:

```
# C3 frozen counting commands, run in the scratch mirror
# cwd: /fast/scratch/hyaku/kagi-r30/XAssimCol/scratch-mirror  (mirror of the lane corpus, SOURCES.md LF-restored)

$ grep -cE '^ {0,3}\|[[:space:]]*S(05[3-9]|060)[[:space:]]*\|' corpus/SOURCES.md
8

$ ls corpus/knowledge/secret-scanning-detection-vs-validation.md corpus/knowledge/betterleaks-detection-vs-validation.md corpus/knowledge/trufflehog-verification-lifecycle.md
corpus/knowledge/betterleaks-detection-vs-validation.md
corpus/knowledge/secret-scanning-detection-vs-validation.md
corpus/knowledge/trufflehog-verification-lifecycle.md

$ grep -cE '^ {0,3}\|[[:space:]]*S[0-9]{3}[[:space:]]*\|' corpus/SOURCES.md   # registry rows
60

$ grep -c $'\r' corpus/SOURCES.md
0

# lane gate (corpus/sources-census.sh) results are in census-lane-gate-*.txt

```

Lane gate (`bash corpus/sources-census.sh`, C3 counter 3), three states:

```
# as the package ships (mirror, entries copied verbatim + ids re-pointed)
$ bash corpus/sources-census.sh verify --root /fast/scratch/hyaku/kagi-r30/XAssimCol/scratch-mirror
FINDING SC_USEDBY_NOCITE id=S054 path=corpus/knowledge/secret-scanning-detection-vs-validation.md
FINDING SC_USEDBY_NOCITE id=S056 path=corpus/knowledge/betterleaks-detection-vs-validation.md
FINDING SC_USEDBY_NOCITE id=S058 path=corpus/knowledge/trufflehog-verification-lifecycle.md
FINDING SC_USEDBY_NOCITE id=S059 path=corpus/knowledge/trufflehog-verification-lifecycle.md
FINDING SC_USEDBY_NOCITE id=S060 path=corpus/knowledge/trufflehog-verification-lifecycle.md
FINDING SC_FETCH id=S059 missing-provenance
FINDING SC_FETCH id=S058 missing-provenance
FINDING SC_FETCH id=S053 missing-provenance
FINDING SC_FETCH id=S057 missing-provenance
FINDING SC_FETCH id=S056 missing-provenance
FINDING SC_FETCH id=S055 missing-provenance
FINDING SC_FETCH id=S054 missing-provenance
FINDING SC_FETCH id=S060 missing-provenance
FINDING SC_ENTRY_HEADER corpus/knowledge/betterleaks-detection-vs-validation.md: multiple source: lines
FINDING SC_ENTRY_HEADER corpus/knowledge/secret-scanning-detection-vs-validation.md: multiple source: lines
FINDING SC_ENTRY_HEADER corpus/knowledge/trufflehog-verification-lifecycle.md: multiple source: lines
SOURCES_CENSUS: FAILED (findings=16 rows=60)
exit=1

# production baseline at BASE (read-only run, for the delta)
$ cd /home/vgpnk/Projects/shokunin/kagi-shokunin && bash corpus/sources-census.sh
SOURCES_CENSUS: CLEAN (rows=52 A=50 B=0 C=2 queued=1 mined=48 rejected=3 entries_sourced=5 legacy=21 captures=52 inrow=16 inrow_only=0 inrow_nonreproducing=12)
exit=0

# probe: single-line source headers + 8 provenance rows appended
$ bash corpus/sources-census.sh verify --root /fast/scratch/hyaku/kagi-r30/XAssimCol/gate-probe
SOURCES_CENSUS: CLEAN (rows=60 A=57 B=1 C=2 queued=1 mined=56 rejected=3 entries_sourced=8 legacy=21 captures=60 inrow=16 inrow_only=0 inrow_nonreproducing=12)
exit=0
```

Rebuild check (run last, from the wave-dir artifacts alone, scratch discarded afterwards):
copy the lane `corpus/`, restore LF on `SOURCES.md`, insert `normalized-rows.md` after the `S052`
row, copy `entries-repointed/*.md` into `corpus/knowledge/`, append `source-fetches-append.tsv` to
`corpus/source-fetches.tsv` — fleet `validate --file` exit **0**, lane gate
`CLEAN (rows=60 …, captures=60)` exit **0**, counter 1 pattern = **8**. The handoff needs nothing
from this seat's scratch tree.

The 16 findings on the shipped shape are exactly:

- `SC_USEDBY_NOCITE` ×5 (`S054`, `S056`, `S058`, `S059`, `S060`) — the gate reads only the first
  `source:` line (`src_field` stops at the next non-indented line), so ids named on lines 2..n look
  uncited.
- `SC_ENTRY_HEADER` ×3 — `multiple source: lines` (lane convention is one line, `;`-separated).
- `SC_FETCH` ×8 — `missing-provenance`: every registry row needs a 16-field capture row in
  `corpus/source-fetches.tsv`; the staged rows' in-row `fetch sha256 \`<16 hex>\`` fragment is not
  a pin and cannot substitute (the in-row pin regex is capital `Fetch sha256:`, historical rows
  S001–S016 only).

Merging each entry's `source:` lines into one line (`entry-source-headers-draft.txt`, verified)
removes the first 8 findings; appending the captured provenance removes the last 8.

Captured provenance (declared profile `curl -fsSL --compressed`, `decoded-http-body-volatile-v1`,
this lane's 2026-11-03 access), append-ready, 16 fields each:

```
S053	mined	9915c4eaa9ab3cbe514c2a4208b1458bad19cb9f799234bae0efe06a078c6c6f	https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md	https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md	200	curl-fsSL-compressed-v1	2026-11-03	decoded-http-body-volatile-v1	65e87e68f4a16aefa1f1fba55b2e7a9b9bc8716393b7ddb013fc7c7bef4e4bc1	29328	5f6ec56cfa6f8c67648d863582c7ae2f206d5c1c	is a tool for **detecting** secrets like passwords, API keys, and tokens in git repos, files	raw-literal-v1	-	README intro paragraph (line 35)
S054	mined	5890da0945e4530fdea174b81186e8b9420d4146a07a60ec2c2296a69a70570a	https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md	https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md	200	curl-fsSL-compressed-v1	2026-11-03	decoded-http-body-volatile-v1	7cf6efb50ab892347b1fa3bee77592603b371b066b6b1659fcc2c56a62e6eff7	38524	240ccdd9061905ed3d7cbe05c01565f0ccf0cd0a	can also log in to confirm if that secret is live or not	raw-literal-v1	-	README Validation section
S055	mined	650bcc4995c6c8118ee2dddc0f6423d1b9cce48255da4b2f62d1a240d652b962	https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md	https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md	200	curl-fsSL-compressed-v1	2026-11-03	decoded-http-body-volatile-v1	f61c3993fd48dfb973652b9676697f4d37404fad9f30748c2003127eb81a73b1	13252	6cd808f299a81b19fdbd196b04a64e63565c8c5c	Scans detect secrets without credential provider requests by default	raw-literal-v1	-	README Usage, opening line
S056	mined	71625d98608c3a541d4c863fc8869201c171959725f768b3f76d9063f411ac89	https://api.github.com/search/repositories?q=betterleaks&per_page=10	https://api.github.com/search/repositories?q=betterleaks&per_page=10	200	curl-fsSL-compressed-v1	2026-11-03	decoded-http-body-volatile-v1	b7e19953ecde88d0ea2b9b248d9424fd817fa8cf9cde4ba6050d762d281ac21c	64526	-	"full_name": "betterleaks/betterleaks"	raw-literal-v1	-	response items[0] object
S057	mined	592e42c5940b8b41315fbfe1d94bc92fbd34c7931d66bcbd46ffaa06ce3fa04b	https://trufflesecurity.com/docs/verification-caching	https://trufflesecurity.com/docs/verification-caching	200	curl-fsSL-compressed-v1	2026-11-03	decoded-http-body-volatile-v1	0beb84fec97fa0ac2cb2c8c8b1cb0e1616ea7b8485b6848da1771d109c9d44d1	102006	-	Each cache entry expires after three hours	rendered-text-v1	5e697b14d10802cbb06d2c2eba91aaca206f10827360cc04206c21e8b397bc9c	section Verification caching, cache-expiry paragraph
S058	mined	bc614e9d63b91dacf356a998acbc0beee232c54b34c3061c453ba60af87ce320	https://trufflesecurity.com/docs/how-we-handle-your-data	https://trufflesecurity.com/docs/how-we-handle-your-data	200	curl-fsSL-compressed-v1	2026-11-03	decoded-http-body-volatile-v1	2c85abe9e3f842a703ea0a8671230f63ed223233b3590c3c7a3da3f0151b5914	161061	-	Credentials are verified using safe, read-only API calls	rendered-text-v1	b7c2613aec83674b6a34945264f5c17db6cb055a861b7f0906727ee670f130c8	Verification Safety panel, What We Do not Do
S059	mined	0957ff853475b6dbe73d9e8f94a860403c83a5214a9b7a1e8d89d0f8bce33e69	https://trufflesecurity.com/docs/reverify-secrets	https://trufflesecurity.com/docs/reverify-secrets	200	curl-fsSL-compressed-v1	2026-11-03	decoded-http-body-volatile-v1	b4790c43398da9db6aa07b2dd883ecbad33e2e593c8f5cd4a30a90328eae3e0a	99172	-	Secret reverification is currently only supported	rendered-text-v1	df607e982176c63e8118f491aeddebb7eeaa527fe942dd752a4223331ce2fb00	section Reverify secrets, closing scope sentence
S060	mined	33b1c92f067395707e231a680250db753165971f2e6d0d51f39254374f0e4944	https://trufflesecurity.com/docs/notify-results	https://trufflesecurity.com/docs/notify-results	200	curl-fsSL-compressed-v1	2026-11-03	decoded-http-body-volatile-v1	8c0a977c75286c178ce3cc6c296fa46cc70ac676f329b926c5e387e0ee9e4752	144104	-	sendUnverified	rendered-text-v1	e4a550c4a9a6e25f1fb7bdc69468b4b2f1e8215f7b769c3f5dbbfb1f2fadd822	section Notify results, configuration snippet field sendUnverified
```

`capture-notes.md` carries the per-source detail: HTTP status, final URL, raw sha256, bytes,
resolved moving-ref revision, normalization (`raw-literal-v1` for the 3 READMEs and the JSON
response; `rendered-text-v1` + normalized digest for the 4 HTML docs pages), the located quote and
its location. Draft headers for the three entries (single line, lane shape, gate-verified):

```
# secret-scanning-detection-vs-validation.md
source: S053 (https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md, README intro paragraph and §"Configuration" rule fields — repo HEAD commit `b58d3f102cf3a2c84cb7f923d05c25c9b1aed84b`, fetched 2026-10-23); S054 (https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md, §"Validation ✅" and §"1: Scan a repo for only verified secrets" — repo HEAD commit `d6ea4a52e3f4705989210e60e9f0da0deafe84bf`, fetched 2026-10-23)

# betterleaks-detection-vs-validation.md
source: S055 (https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md, §Usage opening line and §Features table rows "Secrets Validation", "Secrets Analysis", "Expr-based filtering", "BPE filtering" — fetch sha256 `f61c3993fd48dfb9`, fetched 2026-10-23); S056 (https://api.github.com/search/repositories?q=betterleaks&per_page=10, `items[0]` fields `fork`, `stargazers_count`, `pushed_at` — response sha256 `0c8bdbd04508489c`, fetched 2026-10-23)

# trufflehog-verification-lifecycle.md
source: S057 (https://trufflesecurity.com/docs/verification-caching, §"Verification caching", cache-expiry and cache-contents paragraphs — page stamp "Updated 06 Jul 2026", fetch sha256 `b1eb8215a66933f9`, fetched 2026-10-23); S058 (https://trufflesecurity.com/docs/how-we-handle-your-data, §"What We Don't Do" and the Verification Safety panel — fetch sha256 `aef5f76a64c9565a`, fetched 2026-10-23); S059 (https://trufflesecurity.com/docs/reverify-secrets, §"Reverify secrets", first paragraph and closing scope sentence — page stamp "Updated 06 Jul 2026", fetch sha256 `2997de910834f751`, fetched 2026-10-23); S060 (https://trufflesecurity.com/docs/notify-results, §"Notify results", configuration snippet field `sendUnverified` — page stamp "Updated 14 Aug 2026", fetch sha256 `417032af5635ef39`, fetched 2026-10-23)
```

## 5. Honest findings the plan should absorb

**5.1 Lane-gate shape is a real gate, not a formality.** Shipped as staged, C3 would land a
registry the fleet census accepts and the lane's own census refuses. The fix is mechanical but it
is a *content* edit (entry headers, provenance TSV), so it belongs to the integrator, not to a
verbatim `cp`. If the L1 declines the header merge, C3's counter 3 cannot be green.

**5.2 CRLF blocks C3 independently of C2's claim.** The fleet parser compares the section heading
to `Registry`, so a CRLF `## Registry` never matches and every row is `E12`. If C3's append is
committed before the LF repair, counter 1 stays red for a reason C3 does not own. Order the
integration C2-then-C3 (or together) and say so in the lesson.

**5.3 Re-grounding: the mechanism claims survive, the digests do not.** Six of eight staged
digest prefixes no longer reproduce; every relied-on quoted sentence still does. Detail and the
per-source mechanism (gitleaks body identical at pin and tip; trufflehog changed by one line) are in
`drift-findings.md`. The plan's own rule — "the campaign's 2026-10-23 dates prove nothing here" —
is therefore not academic: a naive adoption would have carried six stale byte digests.

**5.4 The gitleaks row omits a material status fact.** The re-opened README (and the staged pin)
carry `Gitleaks is feature complete. … Future releases will be security patches only. I'm shifting
my focus to Betterleaks`. The entry treats Gitleaks as a live reference and never mentions that the
same project points at Betterleaks — the subject of entry 2. Not a contradiction of the
detection-semantics claim, but a scope/tier fact a row should state.

**5.5 Volatile numbers and truncated digests in the row cells.** `stargazers_count` 2322 →
**2774**, `pushed_at` 2026-10-22 → **2026-11-03T00:45:58Z** (fork still `false`); the six 16-hex
`fetch sha256` fragments are dead, and none of them is a full digest. Recommendation: drop the
counts and the digest fragments from `anchor`/`teaches`; `source-fetches.tsv` carries provenance.

**5.6 S060's evidence is thinner than its `teaches`.** The captured page shows the config field
`sendUnverified: true`; it states no default, so "unverified findings reach a notifier **only**
through an explicit switch" is an inference, not a located sentence. Soften `teaches` or record the
inference in the Gate.

## 6. Decisions left to the L1 (nothing here is a production write)

1. Adopt the 8 rows as in `normalized-rows.md` (append after `S052`), after C2's LF repair.
2. Adopt or reject the two lane-shape edits: single-line entry headers
   (`entry-source-headers-draft.txt`, and the ready files in `entries-repointed/`) and the 8
   provenance rows (`source-fetches-append.tsv`). The provenance asserts *my* 2026-11-03 captures;
   if the Gate re-fetches, re-capture rather than half-merge.
3. Decide the digest-fragment cleanup in the row cells (§5.5) — it is a content edit inside rows
   whose other cells I was told to keep verbatim.
4. Record §5.4/§5.6 in the lesson Gate (accepted limitation vs refused claim).
5. Restate the staged `fetched 2026-10-23` prose as this lane's 2026-11-03 access if the anchor
   text keeps any date at all.

## 7. Hygiene

No `pacman` (host paused), no installs, no `op` call, no credential material, no `op://` path, no
sibling-lane or fleet-repo write, no lane git/jj mutation. One read-only production gate run
(`bash corpus/sources-census.sh`, writes nothing) for the delta baseline. Scratch
`/fast/scratch/hyaku/kagi-r30/XAssimCol/` held the mirror, the fetched bodies, the probe and the
three builders (`build.py`, `capture.py`, `report.py`); it was removed at the end of the seat
after the rebuild check above, so the receipts in §8 plus the lane's own `corpus/` are the whole
handoff.

## 8. Files written

In `.ufo/waves/round-30/final/c3/assimilation/`:
`id-lists.txt`, `renumber-map.txt`, `normalized-rows.md`, `recheck-prose-stripped.md`,
`used-by-derivation.txt`, `c3-counters.txt`, `census-fleet-validate-baseline-crlf.txt`,
`census-fleet-validate-after.txt`, `census-fleet-metrics-after.txt`,
`census-lane-gate-mirror-as-copied.txt`, `census-lane-gate-probe-lane-shaped.txt`,
`census-lane-gate-production-baseline.txt`, `source-fetches-append.tsv`, `capture-notes.md`,
`entry-source-headers-draft.txt`, `entries-repointed/` (3 entry files, lane-shaped, gate-verified),
`drift-findings.md`, `INDEX.md`, and this report.

Reports: `.ufo/waves/round-30/build/XAssimCol.md` and `.ufo/waves/round-30/XAssimCol-report.md`
(identical).
