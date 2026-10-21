# RevClosureParse — round-23 falsification (closure parser / outside obligations)

Seat: falsification, read-only. Target: `corpus/closure-dispositions.py`,
`corpus/closure-dispositions.json`, and the source document
`corpus/lessons/round-22-verifier-spotcheck.md`. The gate binary was **not executed**
(assignment). Every gate outcome below is re-derived from the current source rules with an
independent scanner; `final-verification.json` citations are the lane's self-recorded run, not
mine. No installs, no git/jj mutation, no host changes.

No `lsp` device is mounted in this session (`xd://lsp` → "No such tool"; the device list has no
`lsp`). Definitions/references/diagnostics were therefore derived from source text and directed
greps, not language-server semantics; this is recorded as unavailable, not as absence.

## Snapshot (pin every claim below to this)

Measured 2026-10-21T01:18–01:19 -03:00.

- HEAD `57776b2` ("round-23: W04 base/end wording, skip semantics, D4 tuple names"), worktree
  clean for the measured paths (`git status --porcelain -- corpus/ .ufo/waves/round-23/
  final-verification.json` → 0 lines at 01:18:52).
- `corpus/lessons/round-22-verifier-spotcheck.md` `65a5b3de…b55869f7`
- `corpus/closure-dispositions.json` `67ac1a42427eca7bc38a0f6785385a3b8039f1e61de24a1716ab76c8bbc5ff60`
- `corpus/closure-dispositions.py` `d79b08a7…`
- `corpus/lessons/round-23.md` `4e971e3d…`
- `corpus/claim-ledger.tsv` `ed125ca5…`
- `corpus/source-fetches.tsv` `6e26e140…`
- `.ufo/waves/round-23/final-verification.json` `72764bf3…`
- `corpus/fixtures/cells-hermetic/SCORECARD.md` `23583252…`

**The tree moved during this review.** It advanced from the state the brief describes
(`fixed=7`, selftest 13, round-23 "seven distinct URLs"; in the worktree I first read, D9's
pointer was `corpus/claim-ledger.tsv`) to
`d218603 → e1884c6 → ea5b734 → b55e0e7 → 7af07b4 → 284d40e → 638d44c → def9bc2 → 58bd8d7 →
57776b2`. Findings marked **[open]** hold at `57776b2`; findings marked **[was]** were true at the
earlier/committed state and were corrected during review — verify the fix stayed committed.

## Claim-by-claim (as handed to me)

| claim element | verdict | basis |
|---|---|---|
| obligation set is exactly 15 | **TRUE** | enumeration below; pinned digest equals the base blob |
| one typed disposition each | **TRUE mechanically** | 15 unique ids, classes match, notes ≥24; see F2 for the earlier false `fixed` |
| fixed pointers resolve | **TRUE mechanically (6/6; 15/15 pointers)** | see F3 — resolution is comment/prose-shaped |
| selftest 13 | **FALSE at `57776b2` — 14 cases** | 12 `mutations.append` + source-drift + digest-mismatch; `round-23.md:60,210` now say 14 |
| C2 "10 captures over 7 URLs" | **FALSE as stated — 9 distinct URLs** | 10 TSV data rows, `sort -u` on `$4` = 9; `round-23.md:180` now says "nine" |
| digest pin | **TRUE** | JSON `source_sha256` = worktree doc = `git show d218603:…` blob |

### The 15 obligations, document order, with classes

Parser insertion order is `SPOT-01..05`, `ADJ`, `D1..D9` (document line order), not the order the
docstring enumerates; the JSON row order follows the parser's order. Classes are section-derived
and checked against the JSON `class` field.

| # | id | class | `round-22-verifier-spotcheck.md` |
|---|---|---|---|
| 1 | SPOT-01 | spot-decision | :103 (S018 row, `admit`) |
| 2 | SPOT-02 | spot-decision | :104 (S017 row, `admit`) |
| 3 | SPOT-03 | spot-decision | :105 (S020/S021/S022/S023 row, `admit`) |
| 4 | SPOT-04 | spot-decision | :106 ("uniformly preview", `reject`) |
| 5 | SPOT-05 | spot-decision | :107 ("borrowed TTL"/"never deleted", `reject`) |
| 6 | ADJ | adjudication | :157 (`**ADMITTED.**`) |
| 7 | D1 | routed-defect | :165 |
| 8 | D2 | routed-defect | :167 |
| 9 | D3 | routed-defect | :170 |
| 10 | D4 | routed-defect | :173 |
| 11 | D5 | routed-defect | :175 |
| 12 | D6 | routed-defect | :177 |
| 13 | D7 | routed-defect | :180 |
| 14 | D8 | routed-defect | :182 |
| 15 | D9 | routed-defect | :183 |

Derivation at the pinned bytes: 9 `^- D` bullets + 5 `admit`/`reject` table rows + 1 `ADMITTED`
line = 15. The 15-row disposition file is a bijection onto this set (no missing, no unknown, no
duplicate ids); current kind counts are `fixed=6 reported=3 operator-owned=1 no-action=5
rejected=0`, `pointers=15`, giving

```
CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=6 reported=3 operator_owned=1 no_action=5 rejected=0 pointers=15)
```

which matches the current `claim-ledger.tsv:60` R23-02 regex exactly (independent match: True).

## Parser attack results (no miscount on this document)

- **Section-prefix matching** (`parser:86,92,98`, `startswith`): the three collectors accept any H2
  whose text begins with `Routed defects`, `Discernment spot-check`, or `Adjudication`. This document
  has exactly one heading per prefix (`:99`, `:155`, `:163`); `## Step-1 conformance` (`:15`),
  `## Claims — re-check` (`:28`), `## Safety / conformance` (`:140`) and the rest do not collide. No
  R23 impact. Latent: a later `## Routed defects (superseded)` or `## Adjudication notes` would still
  be read as the same collector.
- **Header/separator handling**: the spot header `| item | decision | …` (`:101`) is skipped because
  `cells[1] == "decision"`, not because it is a header; the separator `|---|…|` (`:102`) is skipped by
  `SEP_RE` (`parser:64`). Exactly the five data rows `:103-107` are counted. The document's only
  escaped pipe is `\|` at `:22`, inside `## Step-1 conformance` — a section that is not parsed — so it
  does not shift anything here. Latent: `line.strip("|").split("|")` (`parser:94`) splits `\|`; a spot
  table with an escaped pipe would shift the decision column and silently drop the row (demonstrated:
  `| a \| b | admit | … |` → `cells[1] == "b"`).
- **Double counting**: the three collectors are an `elif` chain, so a line cannot be counted twice.
  Only 9 lines match `^- D\d` (`:165-183`); the prose range "D1-D9" at `:15` does not match
  `ROUTED_RE` (needs line-start `- D`); only line `:157` starts `**ADMITTED.**`; the fenced block at
  `:50-58` contains no obligations. **No double count.**
- **Duplicate ids**: `obligations[f"D{n}"] = …` (`parser:90`) silently collapses two `- D1` bullets
  into one key; there is no duplicate-obligation detection (only duplicate *disposition* ids are
  rejected). Not triggered: the 9 bullets are distinct.
- **Anchor rule** (`parser:118-121`): `line.startswith("#") and anchor in line` is a substring test on
  unstripped lines. Current anchor `Routed defect dispositions` matches `round-23.md:64` at column 0.
  Latent: a heading indented ≤3 spaces (valid markdown) fails, and any `#`-starting line containing
  the text passes.
- `**REJECTED` adjudications are now handled (`parser:99`), matching the docstring; this was not true
  in the earlier parser revision.

## Findings

### F1 [open, P1] The recorded final verification no longer matches the current claim row

`.ufo/waves/round-23/final-verification.json` (hash `72764bf3…`, last touched by `ea5b734`) records
`measured_commit = e1884c6ecb7ccd717965b0d748bc193137118dbf` and

```
R23-02 last = CLOSURE_DISPOSITIONS: CLEAN (obligations=15 fixed=7 reported=2 operator_owned=1 no_action=5 rejected=0 pointers=15)
```

but the current tree derives and expects `fixed=6 reported=3` (`closure-dispositions.json` D3 =
`reported`; `claim-ledger.tsv:60`). Machine check against the current regex:

```
recorded matches current R23-02 regex: False
```

`git diff --stat ea5b734..HEAD -- corpus/ .ufo/waves/round-23/final-verification.json` shows 8 files,
92 insertions / 65 deletions after the verdict was written (parser, dispositions, ledger, lesson,
census, SOURCES, source-fetches, stamps); the verdict file itself was not re-run. So the round's
"final" verification attests `e1884c6`, not `57776b2`; at the current bytes a re-run of R23-02 would
print a different CLEAN line from the recorded one. This is the round-22 D6 failure class recurring
on the round that claims to have learned it: the measured commit is named, but the named commit is
not the shipped tree. Re-run R23-02 at the final commit and refresh `measured_commit` (or state
explicitly that the verdict covers `e1884c6` only). Severity P1 for integration; C1's substance still
verifies (my derivation matches the current row).

### F2 [was, P1 — corrected in `58bd8d7`] D3 was typed `fixed` against its own evidence

At the state the brief describes (JSON `00fbf48d…`, HEAD `def9bc2` and earlier), D3 was
`"disposition": "fixed"` (row `:63-67`) while its note said "id-shaped positionals remain routed
debt (ClaimR11X09)" and the D3 paragraph (current `round-23.md:87-92`) said "It does not yet cover an id-shaped positional
(`R1-01`); that gap is routed debt … **not claimed as fixed**". The round-22 obligation
(`round-22-verifier-spotcheck.md:170-172`) required "The new guard must reject the exact tokens
(`revision`, positional ids) under a selftest case id." The gate passes either way: it reads the
note only for length (`parser:187-188`) and the pointer only for a token match (`parser:124`), so a
false `fixed` is invisible to it. Current JSON `67ac1a42…` has D3 = `reported`, and R23-02 was
updated to `fixed=6 reported=3`; this is the correct fix. It matters because sibling evidence
recorded at the earlier commit (the `fixed=7` CLEAN line) is now stale, and because the episode is a
concrete demonstration that C1 certifies record shape, not disposition truth.

### F3 [open, P2 — bound, not a bug] `fixed` proofs are comment/prose-shaped

All 15 pointers resolve under the source rules, but the `fixed` evidence is not bound to the fix:

- D7 → `corpus/source-fetches.tsv:2` — the match is the comment `# D7: bind every mined row …`.
- D9 → `corpus/fixtures/cells-hermetic/SCORECARD.md:1` — the match is the HTML comment
  `<!-- D9: hermetic cells fixture; rows are declared in claims.tsv -->`. (During review the D9
  pointer moved from `corpus/claim-ledger.tsv` — observed in the earlier 4303-byte JSON — to this
  comment; both resolve.)
- D1–D6 → `corpus/lessons/round-23.md#Routed defect dispositions` — the lane's own narrative; the
  token rule cannot tell "D3" in a disposition bullet from "D3" in a comment.

The gate's docstring bounds this ("does not judge whether a disposition's prose is honest"), so this
is a residual risk rather than a defect. The parent should not cite "fixed pointers resolve" as
evidence that a fix exists; for D7/D9 the pointed artifact is a comment that merely names the id.

### F4 [open, P2/P3 — latent] Parser robustness gaps not exercised by this document or the 14 cases

1. Escaped-pipe cell splitting (`parser:94`) — demonstrated above; the selftest has no escaped-pipe
   case.
2. Duplicate routed ids collapse (`parser:90`) — no case; the selftest's `duplicate` case duplicates a
   *disposition* row, not a `- D` bullet.
3. Decision column hardcoded to `cells[1]`, header never validated — a reordered table silently
   changes which column decides. No reordered-table case.
4. Anchor rule is substring + `startswith("#")` (`parser:118-121`) — indented ATX headings fail; a
   code line starting `#` that contains the anchor would pass. No case.

None of these changes the R23 count (the document is well-formed and the digest pin freezes it);
they are the next closure's failure surface.

### F5 [was, P2 — corrected in `58bd8d7`/`57776b2`] Selftest wrote a fixed host path outside its TemporaryDirectory

The committed parser at `def9bc2` (`cfa2c46a…`) had, at line 281,
`(root.parent / "outside.md").write_text(...)` with `root` the `TemporaryDirectory` root. That is
`/tmp/outside.md` on this host: I observed the 28-byte file (`# outside\n\nD1 outside root.\n`,
mtime 01:11) produced by selftest runs; `TemporaryDirectory` cleanup does not remove it, and every
concurrent wave agent running `--selftest` rewrites the same fixed path (it would clobber any
pre-existing `/tmp/outside.md`). The current parser `d79b08a…` creates `root = tmp/"root"` and
`outside = tmp/"outside.md"` (`:279,285`), so the symlink target is inside the temp directory and the
escape case still fires relative to the gate root; `ls /tmp/outside.md` → exit 2 (absent). Verify the
fix remains committed: earlier 13-case selftest runs (cited by several sibling reports) executed the
leaking revision.

## Verified positives (adversarial re-measurement)

- **The obligations are genuine outside text.** `sha256(worktree round-22 doc) = 65a5b3de…` equals
  the JSON pin and equals `git show d218603:corpus/lessons/round-22-verifier-spotcheck.md |
  sha256sum`; the doc is unmodified in the worktree (`git status`). Round 23 did not curate its own
  obligations.
- **No double count / no missed obligation** on this document: 15 exactly, with the line-level trace
  above; the separator/header treatment and section exclusivity hold for these bytes.
- **Bijection and class check**: 15 unique ids, every `class` equals the section-derived class, notes
  86–119 characters (≥ `MIN_NOTE=24`), every pointer resolves (15/15).
- **C2 count**: `source-fetches.tsv` has 10 data rows S017–S026 over **9** distinct `$4` URLs
  (`S021`/`S026` share `https://openbao.org/docs/concepts/tokens/`; `S025` reuses S014's URL;
  `S024` is the only new registry URL). `round-23.md:180` says "nine distinct URLs" — correct. The
  brief's "7 URLs" matches an earlier revision ("seven distinct URLs", corrected in `ea5b734`).
- **Registry distinct-URL claim**: `git show d218603:corpus/SOURCES.md` → 18 distinct URLs, current
  → 19, matching "only the KV v2 API URL is new."
- **D1**: the fleet report `.ufo/reports/round-23/kagi.md:79-85` quotes seven W04 lines
  (S019–S023, S025, S026) verbatim; `round-23.md:66-79` quotes the same seven and distinguishes five
  at base / seven at round end. Read-level check, not a census run.
- **D6 literal**: `final-verification.json` has a `measured_commit` key (e1884c6); see F1 for why the
  value is stale relative to HEAD.

## Verification gaps / residual risk

- I did **not** run `closure-dispositions.py` or `--selftest`; the CLEAN line and the 14-case count
  are derived, and the recorded R23-02 pass is the lane's self-report. My independent derivation
  reproduces the current row exactly, but that is not an execution.
- I did **not** run the census, its 59-case selftest, `sources-census.sh validate`, or the cells gate;
  C2/D7 and C3 cells results are outside this seat (the R23-01 `CELL_AUDIT: CLEAN` line is the
  lane's self-record).
- The gate's own bounds remain: it certifies shape/coverage/pointer existence, never note honesty,
  fix correctness, or that a `fixed` pointer names a fix rather than a comment. F2 is a worked example.
- The tree advanced during review; if it moved after 01:19, re-map findings by the hashes above. The
  only **open** inconsistency at the pinned snapshot is F1 (stale verdict vs current R23-02 row).

## Commands run (with exits)

```
sha256sum corpus/lessons/round-22-verifier-spotcheck.md                  -> 65a5b3de… exit 0
git show d218603…:corpus/lessons/round-22-verifier-spotcheck.md | sha256sum -> 65a5b3de… exit 0
git status --porcelain -- corpus/ .ufo/waves/round-23/final-verification.json -> 0 lines, exit 0
awk -F'\t' '!/^#/ && NF>1 {print $4}' corpus/source-fetches.tsv | sort -u | wc -l -> 9, exit 0
git show d218603:corpus/SOURCES.md | grep -oE 'https://[^ |]+' | sort -u | wc -l -> 18, exit 0
grep -oE 'https://[^ |]+' corpus/SOURCES.md | sort -u | wc -l              -> 19, exit 0
grep -c 'mutations.append(' corpus/closure-dispositions.py                -> 12 (=14 cases), exit 0
grep -n 'W04' .ufo/reports/round-23/kagi.md                               -> lines 79-85, exit 0
git diff --stat ea5b734..HEAD -- corpus/ .ufo/waves/round-23/final-verification.json -> 8 files, exit 0
ls /tmp/outside.md (01:11)                                               -> 28 B, exit 0
ls /tmp/outside.md (01:18)                                               -> missing, exit 2
```

Independent scanner (in-process Python, reimplementation of the current source rules):
`obligations=15`, `counts fixed=6 reported=3`, `pointers=15`, `failures=[]`, derived CLEAN line
matches the current R23-02 regex True; recorded verdict matches it False. No installs or updates
were performed; no host or git state was changed.
