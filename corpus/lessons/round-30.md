source: S053, S054, S055, S056, S057, S058, S059, S060
verified-at: 2026-11-03 — the eight rows re-opened in-round with the declared fetch profile (`curl -fsSL --max-time 30`); receipts `.ufo/waves/round-30/final/c3/src-open/` and the capture rows in `corpus/source-fetches.tsv` (lines 96–103). No vault, account, handler or CDP contact; `op --version` read only; nothing installed or provisioned.
recheck: 180d — re-run `corpus/eol-sweep.sh` (C2), `bash corpus/sources-census.sh` (C3, expect `entries_sourced=8 captures=60`) and `python3 corpus/self-counts.py` (C1) after any registry, entry or doc-count change

# Round 30 — routed-defect closure (D1–D5), EOL drift repair, secret-scanning adoption

Frozen BASE `f67232cd3ae682ea1fb14d447667016f2b6ed336` (round-29 verifier spot-check).
Plan + START census committed alone in `b7482b4` (QM29). Plan correction 1 committed alone
in `d1632908` before any work commit, after the build-wave attack seats measured the BASE
controls. Host: Linux (python3 3.14.8, sqlite3 present; the-janitor substrate absent —
fail-closed outputs are correct; `op` 2.41.1 observed read-only).

## Plan corrections (appended before the first work commit; QM29)

The frozen text in `plans/round-30.md` was attacked before any work landed. Corrections,
each traced to a measured seat finding (`.ufo/waves/round-30/build/*.md`):

- **C1 stale set: eight, not six.** `self-counts.py` at BASE prints `stale=8`: the routed
  six plus RD-DOCS-ROWLINKED and RD-DOCS-ENTRIES (R14-01's bindings, README.md:67). The
  seventh and eighth were not in the frozen text (CAttackPredicates F1, RAttackC1 F1).
- **C1 ledger set adds R25-02** (`claims=60`, live 62 at BASE; in no claim before; RAttackC1 F2).
- **R29-01 and R29-02 are not migrated (kill rule).** `PYTHON_SCRIPT_RE` (`corpus/claim-ledger.sh:263`)
  does not list `feed-token-agree`, and any pre-script flag breaks its anchored pattern, so the
  frozen re-host reads POLICY `python-script` (measured: `final/c1/_policy-matrix.txt`).
  Passing needs a gate-policy registration, which the kill rule reports rather than makes.
- **C2 counter 2 re-scoped** to `corpus/eol-sweep.sh` (R30-01). The frozen pipeline
  (`grep -rIl $'\r' … | wc -l`) is refused by the ledger's command-safety policy (`$'\r'` and
  `|` are metacharacters) and is unsatisfiable as written: 130+ `.ufo/waves/**` files are CRLF
  in the index (authentic HTTP captures, RFC 7230 CRLF headers, evidence bytes). The script
  excludes `.git`, `.jj`, `.ufo`; before 3, after 0.
- **C3 entry gates** (per entry; see the Gate table): entry 2 refused as staged, admitted after
  flip (i).
- **Frontmatter shape:** one column-1 `source:` line per entry (census `SC_ENTRY_HEADER`), a
  `corpus/source-fetches.tsv` capture row per new id, `Reverify:` line per knowledge entry.

## Gate — sources opened and decided this round

| Staged → adopted | Decision and basis | URL, access date, located quote |
|---|---|---|
| S066 → S053 Gitleaks README | ADMIT, tier A tool, 180d. Scope: the lane's frontier lead, detection semantics only | https://raw.githubusercontent.com/gitleaks/gitleaks/master/README.md ; 2026-11-03; body 29328 bytes, sha256 prefix `65e87e68f4a16aef` (matches the staged campaign prefix); quote "is a tool for **detecting** secrets like passwords, API keys, and tokens" (line 35; the bold markup splits the phrase in raw text, so the located form is the markup-stripped one) |
| S067 → S054 TruffleHog README | ADMIT, tier A tool, 180d | https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/README.md ; 2026-11-03; sha256 prefix `5890da0945e4530f` (the campaign prefix `068fbb5c93eb993d` at the pinned revision no longer matches; recorded, not hidden); quote "can also log in to confirm if that secret is live or not" located once |
| S068 → S055 Betterleaks README | **REFUSE as staged** (QA1: the CEL clause cites an unopened Substack article; the README anchor carries only "Express YourCELf" in the blog-index title). **ADMIT after flip (i)**: CEL clause deleted; README-wins caution kept, anchored to the README blog list | https://raw.githubusercontent.com/betterleaks/betterleaks/main/README.md ; 2026-11-03; sha256 prefix `f61c3993fd48dfb9` (matches campaign); quote "Scans detect secrets without credential provider requests by default" located |
| S069 → S056 GitHub search API (betterleaks) | ADMIT, tier A code-host metadata, 90d | https://api.github.com/search/repositories?q=betterleaks&per_page=10 ; 2026-11-03; `items[0].fork` false, `full_name` betterleaks/betterleaks. Stars and last push moved since the campaign (2322 → 2774; pushed 2026-10-22 → 2026-11-03), so the entry's stars figure is campaign-era and labelled as such |
| S070 → S057 TruffleHog verification-caching | ADMIT, tier A docs, 180d | https://trufflesecurity.com/docs/verification-caching ; 2026-11-03; body 102006 bytes, sha256 prefix `0beb84fec97fa0ac` (the campaign prefix `b1eb8215a66933f9` no longer matches — the page moved); quote "Each cache entry expires after three hours" located once (line 12) |
| S071 → S058 TruffleHog how-we-handle-your-data | ADMIT, tier A docs, 180d | https://trufflesecurity.com/docs/how-we-handle-your-data ; 2026-11-03; quote "Credentials are verified using safe, read-only API calls" located |
| S072 → S059 TruffleHog reverify-secrets | ADMIT, tier A docs, 180d | https://trufflesecurity.com/docs/reverify-secrets ; 2026-11-03; quote "Secret reverification is currently only supported" located |
| S073 → S060 TruffleHog notify-results | ADMIT, tier B docs (single-anchor switch, not a mechanism claim), 180d | https://trufflesecurity.com/docs/notify-results ; 2026-11-03; token `sendUnverified` located (2 matching lines) |

**Existing registry cells, old → new:** S052 untouched. The eight new rows carry `opened`
2026-11-03 and `used-by` = exactly the admitted entries citing them (derivation:
`final/c3/assimilation/used-by-derivation.txt`). The staged package's own S053–S060 are
unrelated documents (AWS, Google Cloud, Alibaba, Tencent, CRYPTREC); the map is per document,
verified by URL against each entry's citation, never arithmetic. Id collision check: `comm -12`
of the lane's 52 ids against the staged 172 ids = **1** (S052), so no staged id other than
S052 is adopted as-is (`final/c3/assimilation/collisions`).

**Campaign anchors kept, not rewritten.** The eight registry rows keep the campaign-era
digests and dates in their anchor cells (`fetched 2026-10-23`). Six of eight 16-hex prefixes
no longer reproduce against today's bytes (sentinel H4, re-measured: vendor pages moved). The
in-round digests with 2026-11-03 dates are the capture rows in `corpus/source-fetches.tsv`
(lines 96–103), and they are the evidence the census checks.

## C1 — calibration: ledger and doc pins to observed state

Counting command: `python3 corpus/self-counts.py`. Result at the measured revision:
`SELF_COUNTS: POLICY (claims=62 stale=0 unlocated=0 ambiguous=0 policy=2 setup=0)`, exit 2.
`stale` is 0 (the eight doc cells are corrected), but two bindings (`PV-FEEDTOKEN-SHAPES` →
`ledger:R29-02`, `PV-FEEDTOKEN-SELFTEST` → `ledger:R29-01`) are refused by the policy because
their commands are not allowlisted. The counter therefore does not reach exit 0 this round;
C1 is not claimed CLEAN.

Ledger rows migrated to measured values (old → live, reason in each row note): R12-03 91→99,
R13-01 34→36, R14-01 entries 25→29 / row_linked 22→26, R21-02 census 51→60 registry rows
(entries_sourced 4→8, captures 51→60), R21-04 65→68, R22-03 revision-audit added 28→36
(stale 0), R24-05 stamps identity, R24-06 scorecard-rounds identity, R24-14 ledger-ids identity,
R24-15 revision-added identity. Doc cells corrected (eight): SKILL.md:46, PROVINCE.md:73,
README.md:64/65/67.

Not migrated and routed: **R25-02** (its `self-counts.py` command exits 2 on the two round-29
policy bindings above, so no expectation it could pin passes), **R29-01** and **R29-02**
(gate-policy registration of `feed-token-agree` in `PYTHON_SCRIPT_RE`).

## C2 — freshness: routed D5 byte drift repaired and gated

Three files had been silently converted LF→CRLF on the round-29 host (SKILL.md,
corpus/SOURCES.md, corpus/claim-ledger.tsv). Repair: LF bytes restored; `.gitattributes` adds
five text classes at `eol=lf` and excludes `.ufo/**` (the sentinel's H7 blocker: without the
exclusion the rule renormalizes five committed round-29 receipts). Standing gate `R30-01`:
`bash corpus/eol-sweep.sh` → `EOL_SWEEP: CLEAN (crlf=0 attrs=5 scope=lane-minus-git-jj-ufo)`.
Red witness: a scratch tree with one CRLF file exits 1 `DRIFT (crlf=1 attrs=5)`.
Measured before/after: CR files 3 → 0; fleet census `sources-census.sh validate --root … kagi`
E12 ×52 exit 1 → exit 0 (W04 duplicate-URL warnings remain, allowed); `checklist-run.sh --ratio`
SETUP exit 2 → `CHECKLIST_RATIO: runnable=9/16 floor=8 by_hand=7 delegated=3 direct=6` exit 0;
`claim-ledger.sh citations` BROKEN unresolved=19 (all SKILL.md CRLF) → unresolved=1 (the LOG
pointer to this round's report, which resolves once the report is filed).

## C3 — coverage: frontier lead moved to admitted knowledge

Theme: secret scanning, detection versus verification (the lane's frontier lead since round 21).
Three knowledge entries, eight registry rows (S053–S060), eight capture rows. Lane census measured:
`SOURCES_CENSUS: CLEAN (rows=60 A=57 B=1 C=2 queued=1 mined=56 rejected=3 entries_sourced=8 legacy=21 captures=60 …)` exit 0.
Frontier moved to core in `PROVINCE.md` (Core bullet) and `corpus/README.md` (coverage row);
the OIDC and NIST frontier bullets are untouched.

## Mistakes

| id | class | evidence | captured-by | fix (shown able to fail) |
|---|---|---|---|---|
| M30-1 | silent byte drift (D5) | three lane files converted LF→CRLF on the round-29 Windows host and landed that way: a CR count of 3 at BASE; the fleet census E12 ×52 at START (`.ufo/waves/round-30/census-start.txt`); `checklist-run.sh --ratio` SETUP | none — no lane gate watched committed byte shape; the round-29 stamps were re-pinned to the converted bytes instead of questioned; the outside verifier caught it (round-29 spot-check D5) | LF restored; `.gitattributes`; standing gate `R30-01` (`corpus/eol-sweep.sh`) with a red witness (exit 1 on a planted CRLF) |
| M30-2 | unsatisfiable frozen counter | the frozen counter-2 pipeline (grep of CR bytes piped to a line count) can never print 0 (130+ `.ufo` capture files are CRLF in the index) and is refused by the ledger policy (`$'\r'` and the pipe are metacharacters); found by the CAttackPredicates and LProbeGitattr seats before any work commit | the attack step (plan §Claim sizing rule 9: a do-nothing control and predicate attack before data) — caught before work, not by a gate | plan correction 1 (before the first work commit); counter moved into a registered script `corpus/eol-sweep.sh` whose verdict line the ledger can read |
| M30-3 | incomplete stale-set enumeration | the routed six doc cells were named as the full stale set; `self-counts.py` at BASE printed `stale=8` (RD-DOCS-ROWLINKED, RD-DOCS-ENTRIES added under R14-01) | none — the plan named six from the round-29 spot-check text, not from a counter run at BASE | plan correction 1 names all eight; the counter is the arbiter (`stale=0`, measured) |
| M30-4 | unowned red inside the claim's own gate | R25-02 (`claims=60`) FAILed at BASE and belonged to no claim (RAttackC1 F2); at the measured revision it is blocked by the round-29 policy bindings, so it is routed, not migrated | none — no rule required every FAIL row of a gate the round touches to be claimed or routed | routed; a follow-up criterion (QM31 family) should require every red row of a touched gate to be claimed or routed before the plan freezes |
| M30-5 | policy-refused re-host | the round-29 rows R29-01/02 read `python -I -B`; the ledger's `PYTHON_SCRIPT_RE` lists no `feed-token-agree`, so every spelling reads POLICY (`final/c1/_policy-matrix.txt`) | the round-29 closure did not run the rows under the ledger's policy (it ran the scripts directly) | not migrated under the kill rule; routed to an operator decision (register the script, with a selftest case) |
| M30-6 | adopted entry asserted more than its anchor | staged Betterleaks entry cites a community article for a CEL claim the README does not carry (RAttackC3 entry 2) | the per-entry QUALITY bar QA1, applied by the attack seat, not by the staging package | refused as staged; admitted after flip (i) (CEL clause deleted); the census re-run (`entries_sourced=8`) |
| M30-7 | lane census rejected the staged package as shipped | 16 findings (two `source:` lines per entry ×8 SC_ENTRY_HEADER; one missing capture per id ×8) on the package as delivered (`final/c3/assimilation/`) | the lane's own census (`corpus/sources-census.sh`) | merged `source:` lines; capture rows appended; census CLEAN |

## Limits

- The campaign digests for six of eight registry anchors no longer reproduce; the in-round
  captures replace them as evidence, but the anchor cells still carry the campaign pins (kept on purpose).
- `Reverify: R21-02` links the three new entries to the registry census, which checks the citation
  chain, not the sentences. Sentence-level re-verification is the in-round fetch receipts.
- R25-02, R29-01 and R29-02 are not migrated: their POLICY state is the honest end state of this
  round and is routed. C1's counter is exit 2, not CLEAN.
- The Betterleaks stars and push-date figures (S056) are campaign-era and labelled as such.
- Frontier bullets in PROVINCE and README keep their history; the older OIDC and NIST frontier
  was not re-audited this round.
