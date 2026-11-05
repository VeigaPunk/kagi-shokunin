# K38ConnOverlap — sibling-overlap scan, kagi round 38 (wave build)

Seat: K38ConnOverlap. Scope: read-only sibling-overlap scan. Lane: kagi-shokunin (candidate b944735, claim BASE a916f4a56a08a6dea9a1a2318bbe6406fd0ac97c). No sibling file was edited, no git or jj mutation was run, no scratch directory was created, and no subagent was dispatched.

## Top line

**NO OVERLAP on the frozen claims' ground.** No sibling lane holds the same mechanisms (`quote-locate.py`, `laneguard.sh`, `LANE_GUARD_SELFTEST`, `QUOTE_LOCATE:`), registers the same sources (S089–S093), or claims Vault/OpenBao release identity as its domain.

Adjacent references exist and are classified in section 3. None is a conflict. Nothing was absorbed.

## 1. Method and commands

Sibling set: the 20 `*-shokunin/` lanes other than kagi that carry a `corpus/` directory, plus a `PROVINCE.md` check on every lane (21 lanes including kagi, from a `PROVINCE.md` existence loop). Searches used `grep -rIn`, `grep -rIl`, `grep -In`, and `grep -o`, with `--exclude-dir=.jj --exclude-dir=.git`. `.ufo/` was not excluded unless stated. Positive control: the same patterns against `kagi-shokunin/corpus/SOURCES.md` return the S089–S093 rows, so the patterns do match registered URLs.

Broad terms (`located-quote`, `lane-tree`, `QUOTE_LOCATED`) are common fleet vocabulary. About 540 files in siblings match them, almost all wave transcripts or counter output. They were **not** treated as overlap. The hits below use exact mechanism names or exact URLs.

Exit codes were not captured per command; each command's output is quoted in the sections below. No grep error was reported.

## 2. Hit list (file:line)

### 2a. Exact mechanism names (kagi's C1/C2 instruments)

Pattern: `quote-locate\.py|quote_locate|laneguard|LANE_GUARD|QUOTE_LOCATE:|QUOTE_LOCATE |lane-tree\.|lane_tree\.py|located-quote\.py|locate_quote`, sibling-only, `.jj` and `.git` excluded.

| Hit | Sibling file:line | Note |
|---|---|---|
| `sep-quote-locate.py` (substring of `quote-locate.py`) | kaidoku-shokunin/.ufo/waves/round-50/w1/C2RowS147.md:37; kaidoku-shokunin/.ufo/waves/round-50/w1/C2RowS147/receipts/commands.txt:6; kaidoku-shokunin/.ufo/waves/round-50/w1/C2RowS147/receipts.sha256:19 | Wave-scratch reference to `tools/round-50/sep-quote-locate.py`. That path is absent from kaidoku's tree (`ls` → no such file). Different script name and lane. |
| `LANE_GUARD` (local variable) | kengaku-shokunin/.ufo/waves/round-37/build/R37CritC1Battery/sidechannel/crit_p10_sidechannel.py:30 | A wave-critic variable, not the mechanism. |
| `locate_quote` (function) | kotoba-shokunin/verifiers/check_sibling_census.py:328 | Verifier-local quote locator in kotoba. Not a `quote-locate.py` or `laneguard.sh` equivalent. |
| `locate_quote` (function) | kotoba-shokunin/.ufo/waves/round-73/w1/build/MutSiblingCensus/mutants/M01…M05 `.py`:328 | Wave-scratch mutant copies of the kotoba locator. |
| `locate_quote` (function) | kake-shokunin/.ufo/waves/round-75/w1/ScoutSources/verify_sources.py:49 | Wave-scratch scout script. |
| `case_missing_lane_tree.py` | kama-shokunin/.ufo/waves/round-24/build/out/CaseMissingLaneTree/case_missing_lane_tree.py | Unrelated name; "lane_tree" appears only as a case label. |

**No sibling corpus, plans, tools, scripts or templates file carries `quote-locate.py`, `laneguard.sh`, `LANE_GUARD_SELFTEST` or `QUOTE_LOCATE:`.** A separate fleet-shared check over `scripts/`, `tools/`, `templates/` and `research/` for `quote-locate|laneguard|LANE_GUARD|QUOTE_LOCATE|lane-tree` returned no output.

### 2b. Lane-guard vocabulary (not the mechanism)

- tameshi-shokunin/corpus/QUALITY.md:176 — "29. A lane guard is a check whose removal changes a verdict on some input." Sibling criterion text using the term. It defines the concept (mutation-sensitivity of a guard). Kagi's `laneguard.sh` is a lane-tree write guard. Shared vocabulary, not an instrument.
- mado-shokunin/corpus/lessons/round-67.md:95 — "a lane guard that sets both planes". Generic usage.
- mado-shokunin/tools/mado-verify.sh:2012 — comment mention of a "guard assertion". Generic.
- scripts/hyaku/jj-lane.sh:73 — "# ---- lane guards ----" section, fleet-shared. Its guards refuse the fleet root and non-clones (`lane_realdir`, lines 77–84). Different predicate. It does not snapshot a lane tree or detect writes.

### 2c. Located-quote gates (same mechanism class, sibling-local instances)

- chousa-shokunin/corpus/evidence/round43/c3-count.py:50, 64–66 — `QUOTE_LOCATED` counter: entry cites S078, URL matches, located quote is a substring of the committed capture. Round-44 copy: chousa-shokunin/corpus/evidence/round44/c3-count.py:51, 65.
- kengaku-shokunin/plans/sources_adopt.py:21–24, 57–58, 268–273 — quote validation against `--artifact` with capture-to-citation binding (`--url-map`, `EXIT_URL_MISMATCH`, `EXIT_URL_UNMAPPED`), 25-word cap.
- kotoba-shokunin/verifiers/check_sibling_census.py:328 — verifier-local `locate_quote` (see 2a).
- kasegi-shokunin/corpus/lessons/round-26.md, round-28.md, round-29.md, round-30.md — `def locate_quote` / located-quote prose in lessons, not a gate script in corpus.

These share a mechanism family: a quote located in a committed capture and bound to a URL. None is kagi's `quote-locate.py`. None reads kagi's `corpus/quote-bodies.tsv`, and none registers kagi's S-ids.

### 2d. Release-clock / feed mechanisms (adjacent, token-shape only)

- souji-shokunin/census/round-55/wave/w1/S55connector01/receipts/sibling-classification.tsv:7 — `kagi  A  corpus/release-clock.py  OVERLAP  [["splitlines", ...], ["foreign-lineno", ...]]`. Souji's connector labels kagi's `release-clock.py` as OVERLAP at code-token level (`splitlines`, `enumerate`). This is a code-shape match, not a ground claim.
- souji-shokunin/census/round-55/wave/w1/S55connector01/receipts/sibling-classification.tsv:12 — `kagi  C  corpus/sources-census.sh  OVERLAP` (normalization comment text).
- souji-shokunin/census/round-60/wave/w1/S60ConnectorRound.md:149 — kagi `corpus/prefreeze-control.sh` and `corpus/release-clock.py` classified `complementary` (wave output, not a corpus file).

### 2e. Source URLs and feed identity (S089–S093 and the Vault/OpenBao surface)

Pattern run over all sibling `corpus/SOURCES.md`, `PROVINCE.md`, `SKILL.md` and `release-clocks.tsv`:
`releases/tag/v2\.2\.1`, `releases/tag/v2\.7\.2`, `hashicorp/vault/releases`, `openbao/openbao/releases`, `github\.com/hashicorp/vault`, `github\.com/openbao`, `openbao\.org`, `developer\.hashicorp\.com/vault`, `feed\.rss`, `downloads/feed`, `releases\.atom`, `hashicorp[^ |)]*`, `openbao[^ |)]*`, case-insensitive.

Hits outside kagi:

| Token | Sibling file:line | Subject | Relation to S089–S093 |
|---|---|---|---|
| `releases.atom` (full URL `https://github.com/NationalSecurityAgency/ghidra/releases.atom`) | kaidoku-shokunin/corpus/SOURCES.md:35 (S029 row) | Ghidra releases feed | Different project; not Vault/OpenBao. |
| `releases.atom` token | kotoba-shokunin/corpus/SOURCES.md:64 (S051 row, anomalyco/opencode release delta) | opencode release | Different project. |
| `hashicorp.com/terraform/...` | kumitate-shokunin/corpus/SOURCES.md:183 (S228), :188 (S234) | Terraform CLI plan; Terraform dependency lock | HashiCorp vendor, different product; no Vault/OpenBao identity. |
| `releases/tag/v…` | game-dev-3d-shokunin/corpus/SOURCES.md:42; kake-shokunin/corpus/SOURCES.md:10; kama-shokunin/corpus/SOURCES.md:32, :233; mado-shokunin/corpus/SOURCES.md:38, :40, :49; souji-shokunin/corpus/SOURCES.md:294; tabi-shokunin/corpus/SOURCES.md:155 | Various release tags | Different projects. |
| `Vault` / `vault` (word match, "Tokenized Vaults") | kaidoku-shokunin/corpus/SOURCES.md:94 (S088, ERC-4626 standard text) | Smart-contract standard | Word overlap only; not a Vault product. |

Positive control (kagi's own SOURCES, same patterns): `hashicorp/vault/releases.atom` at kagi SOURCES.md:40 (S034) and `openbao/openbao/releases.atom` at :41 (S035); `openbao/openbao/releases.atom` also at :97 (S090); `hashicorp/vault/releases/tag/v2.2.1` at :99 (S092); `openbao/openbao/releases/tag/v2.7.2` at :100 (S093). The patterns match kagi's rows and no sibling's.

Per-URL verdicts:

| Row | URL | Registered by a sibling? | Sibling claims Vault/OpenBao release identity? |
|---|---|---|---|
| S089 | `https://github.com/hashicorp/vault/releases.atom` | No (zero sibling hits) | No |
| S090 | `https://github.com/openbao/openbao/releases.atom` | No | No |
| S091 | `https://www.python.org/downloads/feed.rss` | No. The feed URL appears only in kagi SOURCES (S036 :42, S039 :46, S091 :98). Sibling `docs.python.org/3/library/...` URLs exist (chousa SOURCES.md:48–66), but those are documentation pages, not the release feed. | Not Vault/OpenBao (CPython) |
| S092 | `https://github.com/hashicorp/vault/releases/tag/v2.2.1` | No | No |
| S093 | `https://github.com/openbao/openbao/releases/tag/v2.7.2` | No | No |

### 2f. PROVINCE.md: Vault/OpenBao and release identity

Pattern `OpenBao|openbao|vault|Vault|release`, case-insensitive, over `*-shokunin/PROVINCE.md`.

- kagi-shokunin/PROVINCE.md:3 — `**Domain:** secrets & vault ops — …` (kagi's own claim). Line 75 names `corpus/release-clock.py`; line 102 names OpenBao 2.7.x token evidence.
- Siblings reference kagi as the owner of secrets and vault ops only (adjacent, reference only):
  - kasegi-shokunin/PROVINCE.md:48 — "kagi — secrets and vault handling"
  - kotoba-shokunin/PROVINCE.md:63 — kagi "owns secrets and vault ops, credential custody and hygiene evidence"
  - mori-shokunin/PROVINCE.md:68, :206 — kagi owns "secrets, vault operations"; mori does not read credential material
  - souji-shokunin/PROVINCE.md:15, :36, :41 — credentials and vault refs route to kagi; vault approval is operator-owned
  - tsukuroi-shokunin/PROVINCE.md:47, :123 — ADJ-02 routed to kagi
- "release" lines in siblings' PROVINCE.md (kama :14, :58, :68, :166, :354; kasegi :169, :211; mori :258, :433; kumitate :21–22; kake :285; kaidoku :179, :421, :438) name other projects' releases (llama.cpp, vLLM, sglang, Linux, Python, kernel, Sasquatch, WABT, squashfs). None names Vault or OpenBao.

**No sibling PROVINCE.md claims Vault/OpenBao release identity as its domain.** Kagi is the only lane that names Vault/OpenBao releases in its province.

## 3. Classification

| Overlap candidate | Class | Basis |
|---|---|---|
| `quote-locate.py` / `laneguard.sh` / `LANE_GUARD_SELFTEST` / `QUOTE_LOCATE:` | **none** | Zero sibling corpus/plans/tools/scripts hits; only wave-scratch substring or variable matches (2a). |
| S089–S093 URLs | **none** | Zero sibling SOURCES.md hits (2e). |
| Python feed `feed.rss` (S091) | **none** | Kagi-only among siblings' SOURCES (2e). |
| Vault/OpenBao release identity as domain | **none** | No sibling PROVINCE.md claims it; kagi is the only holder (2f). |
| Vault/OpenBao secrets/vault ops as domain | **adjacent (reference only)** | Five siblings route vault/secrets questions to kagi (2f). Not kagi's release-identity claim. |
| Located-quote gates (chousa c3-count, kengaku sources_adopt, kotoba locate_quote) | **adjacent** | Same mechanism family, sibling-local predicates and sources; no shared ids or captures (2c). |
| Lane-guard concept (tameshi QUALITY:176; jj-lane.sh:73) | **adjacent** | Shared term; different predicate (2b). |
| Release-clock code shape (souji sibling-classification.tsv:7) | **adjacent** (token shape only) | Code-token `splitlines`; souji's own census labels it OVERLAP, but no ground is shared (2d). |
| HashiCorp Terraform rows (kumitate SOURCES.md:183, :188) | **adjacent** | Same vendor, different product, no Vault/OpenBao identity (2e). |
| Other `releases.atom` / `releases/tag` URLs (kaidoku :35, kotoba :64, others) | **none** | Different projects (2e). |
| Python docs (chousa SOURCES.md:48–66) vs kagi S027/S028 | **not checked per URL** | Outside the S089–S091 scope; vendor-level only. |

## 4. Notes for the wave

1. Broad-term matches (`located-quote`, `lane-tree`, `QUOTE_LOCATED`, `LANE_GUARD`) are dominated by wave transcripts and counter output. Any future overlap counter should match exact script names and exact URLs, or it will report noise as overlap.
2. Souji's connector labels kagi `corpus/release-clock.py` as OVERLAP at code-token level (round-55 `sibling-classification.tsv:7`). This is a classification artefact of its token rule. It does not establish shared ground. This scan does not edit souji's census.
3. The vocabulary "lane guard" is defined by tameshi QUALITY:176 as a check whose removal changes a verdict. Kagi's C2 instrument is a lane-tree write guard. That is consistent with the term, not an overlap.
4. Path discrepancy: the assignment gives two Report paths, `.ufo/waves/round-38/build/K38ConnOverlap/report.md` (seat path, written here) and `.ufo/waves/round-38/build/K38ConnOverlap.md` (outside the seat write scope). Only the seat path was written, per the write-scope rule. The orchestrator should confirm which path the wave aggregator reads.

## 5. Installs, writes, and cleanup

- Installs: none.
- Files written: this report only (`kagi-shokunin/.ufo/waves/round-38/build/K38ConnOverlap/report.md`), plus the seat directory created with `mkdir -p`.
- Git or jj mutation: none. Read-only tools only (`grep`, `ls`, `sed`, `cut`).
- Scratch directory: none created, so none to delete.
- Frozen counters, controls, manifest, instruments, lesson and lane tracked files: not edited.

## 6. Verdict

**NO OVERLAP** on the frozen claims. The adjacent items in section 3 are shared vocabulary or sibling-local versions of the same generic located-quote pattern. None is a claimed-ground conflict.
