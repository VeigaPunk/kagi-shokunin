# K44ScoutSources — round-44 scout report (sourced-claim source S099 + assimilation inventory)

Seat: scout. Scope: open the round-44 sourced-claim source, capture its bytes and its anchor
location for the Gate, and inventory the assimilation package (read-only; no registry row
edited, no lane tree edit). Deliverables:
`.ufo/waves/round-44/build/K44ScoutSources/S099.body` and
`.ufo/waves/round-44/build/K44ScoutSources/notes.md`.

## S099 source capture (fleet repo `/home/vgpnk/Projects/shokunin`)

| fact | value | how measured |
|---|---|---|
| file | `.ufo/prompts/kagi-round-44.md` at fleet commit `75dd2612` (`75dd26121698f10cf111120f6cbcd2b2125598f1`, 2026-11-05 15:35:06 -0300, `round-44: kagi dispatch evidence (hyaku inline attempt 1)`) | `git show 75dd2612:.ufo/prompts/kagi-round-44.md` |
| sha256 of the bytes | `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c` | `… \| sha256sum` → exit 0 |
| byte size | **97077 bytes** | `… \| wc -c` → exit 0 |
| git blob id | `a6e4e6d34c4b1e424d10e17de111108fdca33d03` (same at `75dd2612` and at HEAD) | `git rev-parse <rev>:<path>` |
| fleet HEAD today | `7c16c9d53599b320d6b1a98777f6f03c666b2c4e` (2026-11-05 16:11:59 -0300, `addendum: Amendment 33 m_mim role split`) — fleet HEAD advanced during the seat's window (an earlier read showed `67bdd05a74a6e7f7e78eedc5726f6fa642e63e68`) | `git log -1 HEAD` |
| changed between `75dd2612` and HEAD? | **No.** `git diff --quiet 75dd2612 HEAD -- .ufo/prompts/kagi-round-44.md` → **exit 0**; `git log 75dd2612..HEAD -- <path>` → empty | — |
| non-author re-open | pinned raw URL `https://raw.githubusercontent.com/VeigaPunk/shokunin/75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md` → same sha256, exit 0; `master` URL → same sha256, exit 0 | `curl -fsSL --max-time 20 … \| sha256sum` |

## Anchor sentence and its location

There is **no literal `§9` heading** in the file: `##`-level headings are only §1–§7 plus the
Run15 notes. The plan's "§9 'Claim sizing'" is **numbered item 9 of the campaign addendum**
inside `## 6. Campaign addendum` (line 141):

- `9. **Claim sizing** (fleet lesson from the 12 rejections):` → **line 547**, byte offset 51796
- the anchor sentence → **line 561**, byte offset **52924** (line start 52919; the bullet's
  `   - ` prefix occupies 52919–52923)

Verbatim (14 whitespace tokens):

> The claim is judged on the counter, kill rule and predicate declared before data.

**Gate-ready located quote — two forms, both inside the ≤ 25-token CORPUS.md rule 1 budget:**

*Form A — 16 whitespace tokens, one byte-contiguous run inside line 561 (bytes 52924–53012):*

> The claim is judged on the counter, kill rule and predicate declared before data. A rule

*Form B — 25 whitespace tokens (bytes 52924–53062); it **crosses the line break** (the file has
`"…before data. A rule\n     changed after any seat has scored is not the"`), so quote it with
the break shown or the newline rendered as a space:*

> The claim is judged on the counter, kill rule and predicate declared before data. A rule
> changed after any seat has scored is not the

Form A is the safer Gate form (single contiguous byte run, no whitespace normalization).

**Calibration note (needs L1 attention before the Gate is written).** The seat brief calls the
sentence "11 words"; it is **14** whitespace tokens, and CORPUS.md rule 1 caps a Gate quote at
**≤ 25** tokens. A 14-token neighbourhood extension would make 28 > 25 — a Gate violation. The
budget the sentence leaves is **11** tokens, which the quote above uses. Land the 25-token form
(or the 14-token sentence alone), not a 28-token one.

**Distinctiveness (calibration, not admission).** The sentence occurs in **742** committed
`.ufo/prompts/*` files fleet-wide (and in kagi's round-42 and round-43 prompts): it is
campaign-addendum boilerplate injected into every lane's per-round prompt. The specific,
citable artefact is *this lane's round-44 prompt at this commit*; `teaches` should be phrased
as the claim-sizing discipline this round's dispatch bound the lane by, not as a one-off
statement.

## Template relationship

`templates/round-prompt.md` (fleet HEAD, 140 lines) does **not** contain the sentence
(`grep` → no match, exit 1) and has no §9/`Claim sizing` at all (`grep -c 'Claim sizing'` → 0);
its `##`-sections are only 1, 2, 2b, 3, 4, 5. The round-44 prompt is that base with
`{{LANE}}`/`{{ROUND}}`/`{{FLEET_ROOT}}` substituted (a mechanical diff of the first 140 lines
shows only those substitutions) **plus** the per-round campaign addendum appended as `## 6.`,
which carries the numbered items 1–10 and supplies item 9 'Claim sizing'. Therefore the row's
anchor must cite the committed per-round prompt blob at `75dd2612`; anchoring on the template
would point at a file that contains neither the sentence nor a §9.

## Registry-side facts (read-only; no row written)

- The lane's `corpus/SOURCES.md` at HEAD holds **98 rows**, `S001…S098`; **S099 does not yet
  exist** — it is a row to be *appended* this round, so the plan's "used-by moves old `—` → the
  register and the lesson" is executable only as append-then-edit (rule 2), and appending with
  the final `used-by` directly is equally compliant and avoids the transient census `W03`
  (`mined row with used-by = —`).
- Census **E11** requires every `used-by` path of a `mined` row to exist on disk; if S099 names
  `corpus/lessons/round-44.md`, the lesson must exist before the after-census (ordering note).
- **Id-space hazard for any future assimilation:** the staged package's ids `S052…S223` overlap
  the lane's live `S052…S098` — **47 ids, all with different source URLs (0 of 47 the same)** —
  and the staged package's own `S099` is a different source again (TruffleHog
  `pkg/detectors/detectors.go`), which would collide with the S099 this round opens.

## Assimilation survey — inventory backing "Assimilation: none"

`/home/vgpnk/Projects/shokuknow/merge/kagi/MERGE-REPORT.md` "Knowledge files to add" table:
**81** unique targets; staged tree holds **81** files; the lane's `corpus/knowledge/` holds
**35**.

- same filename already in the lane: **7** — but **byte-different in all 7** (the lane's copies
  are the later re-opened revisions citing the lane's own row ids, e.g. staged
  `oidc-federation-trust-policy.md` cites S052–S065 while the lane's cites S061–S065);
- content-identical under another lane filename: **0** (sha256 over every staged × every lane
  file);
- **unadopted: 74**. No lane knowledge file cites `shokuknow` — the package has never been
  adopted into the lane.

Classified against the three round-44 claims — **74 of 74 match none of them**:

| unadopted theme | files | C1 counter battery | C2 replay-gate receipt | C3 receipt-drift register |
|---|---|---|---|---|
| GB/T 17901 series | 9 | no | no | no |
| ISO 11770 series | 11 | no | no | no |
| Sakura Cloud custody | 1 | no | no | no |
| ja/zh scanning vocabularies | 13 | no | no | no |
| SP 800-131A tables | 8 | no | no | no |
| NIST SP 800-57 family/parts 2–3 | 2 | no | no | no |
| TruffleHog cache & verification | 12 | no | no | no |
| Betterleaks rule-set deltas | 8 | no | no | no |
| cloud-KMS / Aliyun custody | 3 | no | no | no |
| Claude Code secret-scan guards | 1 | no | no | no |
| IPA JP key-management guideline | 1 | no | no | no |
| secret-scanner evidence tiers / detection-vs-validation | 3 | no | no | no |
| lane-local localisation audits (r42/r43) | 2 | no | no | no |

Backing sweep: a case-insensitive scan of all 74 for
`counter|mutation|battery|replay|receipt|register|drift|correction|kill rule|predicate` hits
**15** files, and every hit is a different sense — "counter**part**" (Chinese standard vs NIST;
symmetric counterpart; TruffleHog's *deduplication* counters in
`verificationcache/metrics_reporter.go`), "cor**rection**" in the domain sense (an operator's
correction to a scan finding; a correction to a standard's reading). `receipt`, `replay`,
`register`, `drift`, `kill rule`, `predicate`: **zero hits** across all 74.

The lane already holds instrument-surface knowledge of its own (`corpus/knowledge/claim-ledger.md`,
`drift-gate.md`, `prefreeze-controls.md`, `tac-evidence-integrity.md`, `checklist-execution.md`),
untouched by the package.

**Two independent reasons for "none" are on the record** for the report's Sources & frontier
section (inventory only — this seat does not judge admission): (a) *thematic* — no unadopted
staged theme bears on C1/C2/C3; (b) *id-space* — the staged rows already collide with 47 live
lane rows and the staged `S099` would collide with this round's new S099, so a wholesale
adoption is not a row-level no-op.

## `considerthese/2026-10-26.md` proposals 1 and 3 — still unimplemented (re-measured)

- proposal 1 (repair-only release path under a HOLD, lines 49–53): the lane holds no HOLD-release
  mechanism — operator policy, not lane-implementable; matches the plan's stated reason.
- proposal 3 (`KNOWN_DEFECT: D1` qualifier on a `CLEAN` verdict, lines 60–62):
  `grep -c 'KNOWN_DEFECT' corpus/release-clock.py` → **0**; needs its own predicate — matches the
  plan's stated reason.

Neither is a theme of the merge package.

## Confidence / unknowns

Observed and reproducible: every number above (bytes, digests, line/offset, exit codes, the
81/7/0/74 set difference, the 74-theme classification, the 742-file spread, both proposals'
non-implementation). Unknowns: the merge package is 12 days stale (its "lane holds 51 rows"
note vs the lane's 98) so a re-staged package would differ; MERGE-REPORT.md's adopt step 5
refers to an `amendments/` directory that does **not** exist in the delivered package (its four
named amendment targets are absent from the staged tree too), so that step is unsatisfiable as
delivered — noted, not judged. The lane census was **not** re-run (host-heavy, out of scope);
the committed `.ufo/waves/round-44/controls/census-start.txt` (`kagi ok`, 98 rows, 19 W04) was
read as evidence only.

No tools installed or upgraded; no `pacman`/`uv`/`cargo`/`npm` transaction performed (git, curl,
grep, awk, sed, wc, sha256sum, python3 stdlib only).

Report: `.ufo/waves/round-44/build/K44ScoutSources.md`
SEAT-STATUS: complete
