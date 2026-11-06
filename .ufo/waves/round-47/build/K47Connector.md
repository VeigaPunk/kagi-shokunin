# K47Connector — sibling-overlap scan, kagi round 47

Read-only connector sweep. Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, BASE
`252ef1cac9f41d84639c0d1f211d0e0911196112`. Scan time 2026-11-06; the kagi working tree
already held the uncommitted C1/C2 candidate (`git status`: `M corpus/SOURCES.md`,
`M corpus/lessons/round-4{3,4}.md`, `M corpus/source-fetches.tsv`, `?? corpus/fired-reverify.tsv`,
`?? .ufo/waves/round-47/capture/`). Where the two differ I say BASE or candidate.

Method: `grep`/`awk` over the 20 sibling `*-shokunin` lanes and the fleet root; read-only git
(`show`, `diff`, `cat-file -t`); `sha256sum`; the lane's own normalizer
`python3 corpus/rendered-text-v1.py digest` over the eleven captures. I did **not** run
`corpus/sources-census.sh`, `plans/round-47-c{1,2}.sh`, `release-clock.py`, `claim-ledger verify`
or `self-counts` (my item names no gate; host-heavy runs are the L1's). No git mutation, no
writes outside this file.

The two round-47 claim surfaces, as frozen:
- **C1 (calibration)** — `corpus/sources-census.sh` clears S094/S099 `used-by` nocite and S099
  fetch provenance; S099 provenance bound to fleet blob `75dd2612:.ufo/prompts/kagi-round-44.md`.
- **C2 (freshness)** — the teaching quote of S012–S016, S021–S026 re-located in captures fetched
  on/after 2026-11-06, recorded in the new `corpus/fired-reverify.tsv`; release-clock gate CLEAN.

---

## 1. (a) Vault/OpenBao teaching rows in siblings — ZERO

Measured: the pattern `developer\.hashicorp\.com/vault|openbao\.org` matches **11 lines in
kagi's `corpus/SOURCES.md` (exactly the eleven C2 ids) and 0 lines in all 20 sibling
`corpus/SOURCES.md`** (S001-style row counts 15–951 per lane). `grep -rli openbao` over sibling
lanes outside `.ufo/` returns 0 files (180 hits exist, all inside wave artifacts: connector
reports, scans, receipts). Same for `vaultproject.io`.

| repo:path:line | what it is | verdict vs kagi's C2 claim |
|---|---|---|
| `kumitate-shokunin/corpus/SOURCES.md:183` (S228), `:188` (S234) | `developer.hashicorp.com/terraform/...` rows, in-row `captured 2026-11-04, 276352 bytes, sha256 a501…` provenance | **host-shared, topic-disjoint.** Same doc host, Terraform CLI/lock-file ground. No Vault/OpenBao teaching. A fleet grep for `developer.hashicorp.com` hits kumitate first; kagi's claim text should say *Vault/OpenBao pages*, never "HashiCorp docs". |
| `kaidoku-shokunin/corpus/SOURCES.md:94` (S088) | "ERC-4626 **Tokenized Vaults**", ethereum raw docs | **lexical only.** Financial vault contract standard; no secrets/vault ops. |
| `kake-shokunin/corpus/knowledge/vault-properties.md:1-2` | *publishing* vault (`veigapunk.kimi.page` twins, `PROPERTIES[]`) | **lexical only.** Different sense of "vault". |
| `souji-shokunin/tests/vault/fixture-src-*/…` (via `kaidoku-shokunin/.ufo/waves/round-64/w1/ConnectJscCross/overlap.md:142`) | synthetic test vaults in a fixture | **not knowledge.** Test fixture text. |
| `kasegi-shokunin/PROVINCE.md:48` | "kagi — secrets and vault handling" | **deference**, no claim. |
| `kama-shokunin/.ufo/waves/round-47/w1/out/N1Overlap.md:13,42,84` | same-round sibling sweep: kagi is the only lane whose corpus carries release-clock feeds, and it names "sops/openbao" as kagi's own | **corroborates non-overlap** in this same round. |
| `kengaku-shokunin/.ufo/waves/round-39/build/R39ConnSibling.md:39` | "rotation, Vault/OpenBao clocks; 'secret-scanning…' is kagi" | **deference.** |

No sibling registry row, knowledge doc, or PROVINCE declaration teaches Vault/OpenBao JWT/OIDC,
lease, or token lifecycle. C2's ground is uncontested fleet-wide.

## 2. (b) `SC_USEDBY_NOCITE` / `SC_FETCH` tooling in siblings — no implementation, three near-neighbours

Measured: `grep -rn -E 'SC_USEDBY_NOCITE|SC_FETCH' --include='*.sh' --include='*.py'` outside
kagi returns **no file**; the strings occur only inside sibling *reports* describing kagi's gate.
No sibling has `corpus/sources-census.sh` or `corpus/source-fetches.tsv`.

| repo:path:line | mechanism | relation to C1 |
|---|---|---|
| `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh:24-30` (E01–E12, W01–W04), `:29` `E11 used-by path missing on disk`; `grep -c -i fetch` = **0** | fleet canonical census | **Partial duplicate, decisive contradiction.** E11 tests only that the used-by path *exists*; kagi's `SC_USEDBY_NOCITE` (`corpus/sources-census.sh:40,229-231`) tests that the file *cites the id*. The fleet script has no provenance-ledger concept at all. So S094/S099 are invisible to it: `kotoba-shokunin/.ufo/waves/round-71/receipts/census-after.txt:87` shows kagi `ok` under the fleet script while kagi's own census fails on those rows. |
| `chousa-shokunin/tools/research-gate.sh:3439-3451` — `emit_finding META_SOURCE_USEDBY_MISSING **warn** metadata "entry=… used-by does not name entry"` | the same reciprocity relation, read from the *entry* side | **Duplicate rule, divergent severity.** chousa's is a `warn`; kagi's is a failing `FINDING`. Same fact class, opposite verdict pressure. Nothing in chousa's output is contradicted by C1 clearing kagi's three findings. |
| `chousa-shokunin/tools/assimilate-rows.py:540` (`("used-by", 10, ", ".join(users))`), `:104` | *writer*: recomputes `used-by` from the citing entries | **Complementary.** chousa prevents the nocite class by construction; kagi only *detects* it. A sibling whose registry is machine-written will therefore never exhibit SC_USEDBY_NOCITE — C1 must not generalize the finding as a fleet-wide property. |
| `revenger-shokunin/corpus/audit_source_quotes.py:4-8, :80, :90-91` | committed fetch receipts `{sid, fetch_sha256, length, quote, span, http_status, fetched_at, fetch_url}`; VERIFIED only if the quote appears verbatim at the recorded **span** in the body whose sha the receipt pins | **Duplicate instrument class (closest match to `SC_FETCH` + the S099 BOUND clause), one capability kagi lacks: span binding.** kagi binds id→digest→capture row (so the round-38 cross-row-substitution class is already excluded) and quote→count (`rendered-text-v1.py locate`), but not quote→offset. |
| `kengaku-shokunin/plans/anchor_digest_check.py:1-25, :199-210` | binds each `sha256 <hex>` anchor in `SOURCES.md` to the captures **the row itself names**, via `git cat-file --batch`; cross-row substitution is a defect | **Duplicate of the BOUND idea, different reference substrate.** kengaku: lane-local git blob of a committed capture. kagi's C1: a *foreign repo's* blob (`git -C /home/vgpnk/Projects/shokunin show 75dd2612:…`), computed live by the counter only. |
| `kengaku-shokunin/.ufo/waves/round-68/w2/SiblingOverlap.md:231` | kagi's census run on **kengaku's** registry: 443 findings — `SC_FETCH 232 · SC_USEDBY_NOCITE 163 · SC_ENTRY_HEADER 25 · SC_USEDBY_MISSING 19`, all contract-level codes 0 | **Measured contradiction with portability.** kagi's two codes are lane-local extensions; a fleet-wide reading of their failure count is meaningless. |
| `kengaku-shokunin/.ufo/waves/round-30/build/R30ConnSibling.md:67,73` and `…/falsify/R30FxSibling.md:60-63` | "the only sibling implementation is kagi's lane-local SC_FETCH"; kengaku `corpus/source-fetches.tsv` and `corpus/inrow-pins.tsv` **ABSENT** | **Confirms non-overlap**; unchanged by round 47. |
| `kama-shokunin/.ufo/waves/round-43/w1/out/W1K01/hexrun-ledger-survey.tsv:3` (and `W1K01.md:213`) | restates SC_FETCH's rule (`corpus/sources-census.sh:249` `Fetch sha256:`, `:262` row-identity digest), judges it "64-hex only … no repo/evidence/correct columns" | **Duplicate description.** Accurate today. Round 47 does not edit `sources-census.sh`, so no drift this round. |
| `mori-shokunin/.ufo/waves/round-96/w1/conn/ConnRound.md:39` | "C2 partial (digest consistency inside the registry). Not pinned-copy verification." | **Dated assessment.** Still true of the census; becomes *incomplete* as a description of the lane once `fired-reverify.tsv` lands (C2 evidence lives outside the census). |
| `kumitate-shokunin/.ufo/waves/round-59/build/ConnectorSiblings/commands.md:157`; `tsukuroi-shokunin/.ufo/waves/round-50/w1/R50RevScopeSiblings/tip.kagi.md:55` | verbatim copies of PROVINCE's `sources-census.sh` bullet incl. "`--selftest` proves 70 cases" | **Stale-copy risk only.** Accurate today; both would silently drift if a later round changes the case count. Round 47 does not touch the script. |

## 3. Cross-lane measurements of kagi's C2 surface

| repo:path:line | measurement | relation |
|---|---|---|
| `kotoba-shokunin/.ufo/waves/round-71/receipts/census-after.txt:75-79` (file mtime 2026-10-25) | fleet census over kagi emits `W04 duplicate url` for **S021, S022, S023, S025, S026** (five of the eleven), and `kagi ok` at `:87` | **The only sibling measurement of these rows.** It shows the fleet treats the shared URLs as *warnings*; kagi's clock table treats each id as an independent row. That gap is the concentration defect quantified in §5. |
| `chousa-shokunin/tools/quote-reopen.py:1-40` + `chousa-shokunin/SCORECARD.md:1635` | live re-open: per-hop global-address validation, `DEADLINE`, 8 MiB caps, verdicts `VERBATIM/ABSENT/TOO_LONG/NO_SOURCE/UNREACHABLE`; "page text is kept in memory only; **nothing is written to disk**" | **Duplicate freshness method, incompatible evidence class.** kagi commits captures; chousa refuses to persist them. Neither tool can check the other's property. |
| `kama-shokunin/tools/pin-watch.py:1-25` | freshness of a pinned release vs upstream tags via `git ls-remote --tags`, offline tag-list replay, integer version keys | **Duplicate question ("did the release move?"), disjoint channel.** kagi's clock reads Atom feeds + rendered-quote pages; kama reads tag refs and can replay offline. No shared code. |
| `kotoba` receipt, same line set | five of the eleven C2 ids already duplicated-URL at 2026-10-25, i.e. **before** S099 existed | the duplication is structural, not an artefact of round 47. |

---

## 4. PROVINCE coverage of both claim surfaces

Read at `/home/vgpnk/Projects/shokunin/kagi-shokunin/PROVINCE.md`:

| surface | declared where | verdict |
|---|---|---|
| C1 gate `corpus/sources-census.sh` | `PROVINCE.md:78` (names `SC_FETCH` and the `SC_INROW`/`SC_FETCH` selftest counts) | **covered** |
| C1 ledger `corpus/source-fetches.tsv` | `SKILL.md:754` only; **not** in PROVINCE | **not covered by PROVINCE** (covered by SKILL) |
| C1 lessons edited (`corpus/lessons/round-43.md`, `round-44.md`) | n/a (lessons are not surfaces) | — |
| C2 gate `corpus/release-clock.py` + `corpus/release-clocks.tsv` | `PROVINCE.md:75`, incl. "default is the pinned round-46 receipt `observe-r46.json`, NOT live vendor truth" | **covered** |
| C2 knowledge surface | `PROVINCE.md:89` (round-21 core bullet names `knowledge/vault-openbao-token-lease-lifecycle.md`); `PROVINCE.md:100` names `feature-bound-credential-review.md` | **covered** |
| C2 helper `corpus/rendered-text-v1.py` | `PROVINCE.md:79` | **covered** |
| C2 ledger `corpus/fired-reverify.tsv` (new) | **nowhere** — not PROVINCE, SKILL, `corpus/README.md`, and not read by any gate (`corpus/sources-census.sh` reads exactly `SOURCES.md`, `source-fetches.tsv`, `inrow-pins.tsv`, `knowledge/*.md`) | **undeclared artifact** |

Verdict: **both claim surfaces are covered at instrument level** (each gate is declared by path,
and PROVINCE:75 already states the pinned-receipt limitation). Neither *ledger* file is a
PROVINCE surface, and the round's new corpus-root ledger enters with exactly one reader — the C2
counter. `corpus/adjacency.tsv:75-78` breadth pins cover four `$HOME` dirs only, `row-identity.sh`
does not select `source-fetches.tsv`, and no `self-counts.tsv` row binds either file, so nothing
breaks today; the gap is declaration, not drift. (PROVINCE/README are outside my write scope —
routed to the L1, not fixed here.)

---

## 5. Overlap verdicts

**C1 — calibration: no claim overlap; duplicate instrument class; one severity divergence.**
No sibling lane implements `SC_USEDBY_NOCITE` or `SC_FETCH`; the fleet canonical census cannot
express either predicate (`E11` is path-existence only, zero `fetch` mentions). The nearest
implementations are chousa's warn-level inverse reciprocity check and revenger's span-bound
receipt audit. Clearing the three findings changes nothing in any sibling's output (kengaku's
443-finding measurement and kama's row-identity restatement remain true, because they read the
same unchanged script and their own registries). Two obligations follow for the lesson:
(1) do not generalize C1 as a fleet standard — the only other implementation is a *warning*, and
the fleet contract-level codes are green on the same registry; (2) the one capability kagi lacks
versus revenger/chousa is quote→span binding, so "located" in kagi means "occurs K times", not
"occurs at offset N".

**C2 — freshness: no claim overlap or contradiction; duplicate method; one under-weighting.**
No sibling holds Vault/OpenBao teaching rows, an `on-release` clock, or a fired-reverify ledger.
Method-duplicates are chousa's live `quote-reopen.py` (in-memory, no capture) and kama's
`pin-watch.py` (tag-ref replay). The only sibling *measurement* of these rows is kotoba's
2026-10-25 fleet-census run, which records five of the eleven as duplicate-URL warnings and still
reports `kagi ok` — i.e. the fleet's signal under-weights exactly the concentration the C2
predicate cannot see.

### Measured concentration (this is the finding)

Over the candidate (uncommitted at scan time) and again over BASE:

| quantity | BASE | candidate 2026-11-06T19:34Z |
|---|---|---|
| ids in F | 11 | 11 |
| distinct registry URLs | 6 | 6 |
| distinct capture bodies (sha256) | 8 | **6** |
| distinct col-13 quotes | 7 | 7 |
| exact (URL, quote) duplicate pairs | 4 | 4 |

Pairs: S012≡S022 (vault JWT), S013≡S023 (vault lease), S014≡S025 (OpenBao JWT),
S016≡S026 (OpenBao tokens); S021 shares the OpenBao tokens *body* with S016/S026 but has its own
quote. So **REVERIFIED=11 corresponds to 6 page observations of 7 distinct sentences**, and three
of the eleven (S016, S021, S026) rise or fall with a single page.

Byte/text drift since BASE (col 10 sha and col 15 `rendered-text-v1` digest, recomputed on the
candidate captures with the lane's own normalizer):

| page | raw bytes BASE→now | raw sha | rendered-text digest |
|---|---|---|---|
| vault JWT (S012/S022) | 386435→386833 (+398) | changed | **changed** (06d2508c…→53f5230c…) |
| vault lease (S013/S023) | 261632→261663 (+31) | changed | unchanged (0e62e056…) |
| vault KV v2 (S024) | 586146→586212 (+66) | changed | unchanged (7c5a19e2…) |
| OpenBao JWT (S014/S025) | 63046→63046 | changed | unchanged (ca496ad8…) |
| OpenBao K8s (S015) | 55824→55824 | changed | unchanged (2732189…) |
| OpenBao tokens (S016/S021/S026) | 47384→47384 | changed | unchanged (ed949658…) |

**All six raw bodies differ from BASE; five of six are textually identical** (raw drift is
deploy noise: asset hashes/attributes). Only the vault JWT page's served text changed — and its
quote still locates (`quote_count=1`, both S012 and S022). Consequence for instrument design:
a raw-digest currency pin would report 6/6 stale (false), a rendered-text pin 1/6 (true but
unactionable), and quote-locate 0/6 teaching breaks. `fetched_at` is therefore the only time
evidence in the ledger, which is exactly the plan's named ceiling K2-C.

### Contradictions stated, not smoothed

1. **The freshness gate is not live.** `corpus/release-clock.py` replays a pinned receipt
   (`DEFAULT_RECEIPT_SHA256`, `release-clock.py:28`; `--receipt` help, `:2105`;
   `receipt_matches()` `:475-499` compares receipt `parsed_version` to the table's
   `observed_version`). `GATE=1` therefore certifies *table ↔ 2026-11-04 receipt*, never
   *feed ↔ today*. C2's eleven verdicts are re-verified on docs pages while the release state
   they are "verified at" (2.2.1 / 2.7.2) is inherited.
2. **The feed rows are one release behind the clock table.** `corpus/SOURCES.md:40` (S034,
   Vault) still teaches "Entry titled v2.2.0 … feed fetched 2026-10-21"; `:41` (S035, OpenBao)
   "Entry titled v2.7.1 … feed fetched 2026-10-21", while `corpus/release-clocks.tsv:9-13,18-23`
   carries `observed_version` 2.2.1 / 2.7.2. No gate compares S034/S035's teaches text with the
   clock table; a reader of the registry gets a different release identity than a reader of the
   clocks. If the feeds have moved again (2.2.2 / 2.7.3), C2 can be CLEAN and stale at once.
3. **Claim unit.** "Eleven fired rows re-verified" is six pages and seven sentences, with four
   duplicate pairs and a three-row single-page dependency. That is a true measurement, not a
   defect — but the lesson must state the unit, or the round over-reports independent freshness
   by ~2×.
4. **Transport class is unmarked.** C1's BOUND clause requires the S099 capture to equal the
   fleet **git blob** (verified: `sha256sum .ufo/waves/round-47/capture/S099.body` =
   `e62e259c…1b80c`, 97077 bytes, identical to `git -C /home/vgpnk/Projects/shokunin show
   75dd2612:.ufo/prompts/kagi-round-44.md`). The provenance row nonetheless declares an HTTP
   transaction — cols 5–9 `final_url`, `200`, `curl-fsSL-compressed-v1`, `2026-11-06`,
   `decoded-http-body-v1` — and the tree holds no transport receipt (capture/ has 12 `.body`
   files, no sidecars). The two provenance classes now share one directory and one `.body`
   naming convention. Row internals are otherwise consistent: col 3 row-identity
   `28481f3e…` recomputes exactly as `sha256("S099\tmined\t<registry url>\n")`; col 10/11 equal
   the blob; col 13 is a 17-word quote that occurs in the blob; the row is appended at
   `corpus/source-fetches.tsv:145`, after S102 (order is not read by the census).
   [INFERENCE] The L1 most likely did curl the pinned raw URL, which serves the identical bytes
   by construction; the point is that no artifact can distinguish that from `git show`.

---

## 6. Proposed move (one, bounded, no frozen file touched)

**M1 — make the C2 currency leg live: re-observe the two feed URLs the eleven clocks already
depend on, into a scratch `--observe` receipt, and record the comparison.**

Why this is the non-obvious move: C2's predicate is entirely docs-side, and its gate is a replay.
The round therefore claims *freshness* while holding zero live evidence about the release state
that fired the clocks. Every other instrument in the fleet that answers "did the release move?"
(kama `pin-watch.py`) keeps a replayable observation separate from the pin. C2 already has the
machinery — `release-clock.py --observe` (`:2104`) writes a NEW receipt without rewriting the
table — and the two feeds are already tier-A registry rows (`S034`, `S035`), so no new source.

Shape (L1):
1. `S=${HYAKU_SCRATCH:-/fast/scratch/hyaku}/kagi-r47/K47Connector/feed`; `mkdir -p "$S"` (absolute paths for every path the command touches).
2. `python3 corpus/release-clock.py --observe "$S/observe-r47.json"` — record exit code and last
   line. Do **not** pass `--receipt`, do **not** replace `observe-r46.json`, do **not** touch
   `corpus/release-clocks.tsv` columns 1–8 (C2 kill rule).
3. Compare `parsed_version` for S034/S035 against `release-clocks.tsv` `observed_version`
   (2.2.1 / 2.7.2) and against `SOURCES.md:40,41` (v2.2.0 / v2.7.1, fetched 2026-10-21).
4. Copy the receipt into the build dir; if the two feed bodies are captured, keep them under
   `.ufo/waves/round-47/capture/feed-S034.body` / `feed-S035.body` with their sha256, and locate
   the version token with `rendered-text-v1.py locate`.
5. Write one lesson line: "eleven verdicts hold on docs text re-observed 2026-11-06; feed
   re-observed 2026-11-06 at X / Y; the eleven rest on 6 pages / 7 sentences".

Affected axes: **freshness (C2)** directly — the release state the verdicts are "verified at"
becomes a same-day observation instead of a pinned replay, and the S034/S035-vs-clock-table gap
(§5.2) is either confirmed or closed. **Calibration (C1)** untouched: no census input, no
registry cell, no lesson line, no counter changes; the added artifact is a scratch receipt plus a
lesson sentence.

Risks:
- `--observe` can exit 1 on `REGRESSED` or receipt/profile drift (`PROVINCE.md:75`). That is a
  *finding*, not a failure of the move: record the error text, keep the default replay as the
  gate. Never substitute the scratch receipt.
- If the feeds moved (2.2.2 / 2.7.3), the round's sentence "re-verified at the observed release"
  becomes imprecise. Fix the sentence in the lesson (the verdicts stay, because clause (b)
  pins `observed_release` to the frozen table); do not edit the table.
- Network refusal/ratelimit: record the failed fetch with its error text (honesty rule), and the
  move degrades to "attempted, failed, recorded" — no axis is harmed.
- An L1 reading "new receipt" as a table change: it is not; `DEFAULT_RECEIPT_SHA256` and columns
  1–8 stay byte-identical.

Rejected alternatives: adding span binding to `quote-locate` (revenger/chousa capability) is a
new gate and works calibration, not freshness — out of round; running chousa's
`quote-reopen.py` as a differential normalizer would need network and a third-party instrument
inside kagi's evidence chain.

Verification (all cheap, read-only after step 2):
1. `python3 corpus/release-clock.py --observe "$S/observe-r47.json"` → exit code, last line.
2. `jq`/`awk` the receipt: S034 and S035 `parsed_version` vs `release-clocks.tsv` `observed_version`.
3. If bodies captured: `sha256sum` + `wc -c` against the receipt's `sha256`/bytes, and
   `python3 corpus/rendered-text-v1.py locate <body> 2.2.1` (or 2.7.2) → `count=K`.
4. `python3 corpus/release-clock.py` (default) → exit 0 and last line `RELEASE_CLOCK: CLEAN`
   (gate unchanged; this is the check that proves "no harm").

---

## 7. Lane bounds

Read-only. Wrote only this file. No `corpus/`, `plans/`, `SCORECARD.md`, `LOG.md`, `SKILL.md`,
`README.md`, registry, `MANIFEST.json`, `.ufo/state`, fleet `templates/` or `scripts/` write; no
git mutation; no vault/account contact; no secret printed. Commands used: `grep`, `awk`, `sed`,
`sha256sum`, `wc`, `ls`, `stat`, `find`, `git status|diff|show|cat-file -t`,
`python3 corpus/rendered-text-v1.py digest|locate` (the lane's read-only normalizer).
