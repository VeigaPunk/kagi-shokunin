# K44ScoutSources — round-44 sourced-claim source survey (S099) + assimilation inventory

Seat: scout (`K44ScoutSources`), round 44 attempt 1. Read-only survey; no registry row, no
`SOURCES.md` cell, no lane tree edit was made by this seat. Every command below was run in the
fleet repo `/home/vgpnk/Projects/shokunin` (read-only git calls only) and in this seat's scratch
`/fast/scratch/hyaku/kagi-r44/K44ScoutSources` (deleted on exit).

Deliverables (this directory):
- `S099.body` — the file bytes of `.ufo/prompts/kagi-round-44.md` at fleet commit `75dd2612`
  (97077 bytes, sha256 `e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`).
- `notes.md` — this file.

---

## 1. The sourced-claim source (S099)

### 1.1 Byte capture at the cited fleet commit

Command (fleet repo, read-only):

```
git -C /home/vgpnk/Projects/shokunin show 75dd2612:.ufo/prompts/kagi-round-44.md | sha256sum
→ e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c  -      (exit 0)

git -C /home/vgpnk/Projects/shokunin show 75dd2612:.ufo/prompts/kagi-round-44.md | wc -c
→ 97077                                                                   (exit 0)
```

- byte size: **97077 bytes**
- sha256 of the file bytes at `75dd2612`: **`e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c`**
- git blob id at `75dd2612`: `a6e4e6d34c4b1e424d10e17de111108fdca33d03` (same blob at HEAD —
  the file has not been re-written since it was committed)
- commit `75dd2612` = `75dd26121698f10cf111120f6cbcd2b2125598f1`, 2026-11-05 15:35:06 -0300,
  subject `round-44: kagi dispatch evidence (hyaku inline attempt 1)`.
- `S099.body` in this deliverable directory is a byte-copy of that blob
  (`sha256sum` → same digest; `wc -c` → 97077).

### 1.2 Fleet HEAD today, and drift on that path

- fleet HEAD at survey time: **`7c16c9d53599b320d6b1a98777f6f03c666b2c4e`**
  (2026-11-05 16:11:59 -0300, `addendum: Amendment 33 m_mim role split`).
  The fleet HEAD moved during this seat's window (an earlier read in the same session showed
  `67bdd05a74a6e7f7e78eedc5726f6fa642e63e68`) — the fleet is being committed to concurrently;
  the *prompt path* did not move with it.
- drift check: `git -C /home/vgpnk/Projects/shokunin diff --quiet 75dd2612 HEAD -- .ufo/prompts/kagi-round-44.md`
  → **exit 0** (no change on that path).
- `git log --oneline 75dd2612..HEAD -- .ufo/prompts/kagi-round-44.md` → empty (no commit since
  `75dd2612` touched the path). The blob id at HEAD (`a6e4e6d3…`) equals the blob id at
  `75dd2612`.

**Non-author re-open (public mirror of the same commit):**
```
curl -fsSL --max-time 20 https://raw.githubusercontent.com/VeigaPunk/shokunin/75dd26121698f10cf111120f6cbcd2b2125598f1/.ufo/prompts/kagi-round-44.md | sha256sum
→ e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c  -      (exit 0)
curl -fsSL --max-time 20 https://raw.githubusercontent.com/VeigaPunk/shokunin/master/.ufo/prompts/kagi-round-44.md | sha256sum
→ e62e259c8fd3b9d73833865c456786e72ec387a0b20630c15138b4506971b80c  -      (exit 0)
```
Both the pinned-commit URL and the branch URL serve the identical bytes. This supports a row
anchor of the pinned raw URL (the same form S094 uses for `CORPUS.md`), so a non-author can
re-open the exact source without the fleet repo.

### 1.3 The §9 'Claim sizing' section location

The file has **no literal `§9` heading**. `##`-level headings in the file are only
`## 1.` … `## 6.` (plus `## 7.` scratch discipline and the Run15 notes); `grep -n "^## "`
returns sections 1, 2, 2b, 3, 4, 5, 6, 7 and the Run15 operational-note headings.

The "§9" that the plan's anchor cites is **numbered list item 9 of the campaign addendum**,
which lives inside `## 6. Campaign addendum` (line 141):

| what | line | byte offset (0-based, start of the line) |
|---|---|---|
| `## 6. Campaign addendum …` (the containing section) | 141 | 8369 |
| `9. **Claim sizing** (fleet lesson from the 12 rejections):` | **547** | **51796** |
| §9's bullet block (7 bullets) | 548–569 | 51855 … |
| **the anchor sentence** | **561** | **52919** (line start) / **52924** (first byte of the sentence) |

Anchor sentence (verbatim, 14 whitespace tokens):

> The claim is judged on the counter, kill rule and predicate declared before data.

- **line 561**
- **byte offset 52924** (0-based offset of the sentence's first byte; the bullet's `   - `
  prefix occupies 52919–52923)
- it is the 6th bullet of the §9 'Claim sizing' item; the bullet continues on lines 562–564
  ("A rule changed after any seat has scored is not the claim's rule, whatever attacks it later
  passes (kumitate r42). Freeze one predicate that is the same sentence in the plan, the same
  condition in the counter's code and the same label in the receipt.").

**Gate-ready located quote — two forms, both inside the CORPUS.md §"Rules" item 1 budget (≤ 25
whitespace tokens):**

*Form A — 16 whitespace tokens, a single byte-contiguous run, wholly inside line 561
(bytes 52924–53012; no line break inside the quote):*

> The claim is judged on the counter, kill rule and predicate declared before data. A rule

*Form B — 25 whitespace tokens (bytes 52924–53062): the sentence's 14 tokens + 11 tokens of
neighbourhood. It **crosses the line break** — the file has `"…before data. A rule\n     changed
after any seat has scored is not the"` — so it must be quoted with the break shown (or with the
newline rendered as a space):*

> The claim is judged on the counter, kill rule and predicate declared before data. A rule
> changed after any seat has scored is not the

Form A is the safer Gate form (one contiguous byte run, no whitespace normalization needed).
Verified byte ranges: sentence at 52924; Form A end 53012; Form B end 53062.

**Calibration note for the L1 — the seat brief's word count is off and the naive reading would
break the Gate.** The task brief says "quote the sentence verbatim (11 words) plus ≤14 extra
words of its neighbourhood for the Gate". The sentence is **14** whitespace tokens, not 11, and
CORPUS.md's rule 1 caps a Gate quote at **≤ 25** tokens. 14 + 14 = 28 > 25 — a 14-token
neighbourhood extension would be a Gate violation. The budget left by the sentence alone is
**11** tokens, which is what the quote above uses. Please land the Gate quote at exactly the
25-token form above (or the 14-token sentence alone), not at 28 tokens.

### 1.4 Template relationship — `templates/round-prompt.md` does **not** carry the sentence

```
grep -n "The claim is judged on the counter, kill rule and predicate declared before data" \
     /home/vgpnk/Projects/shokunin/templates/round-prompt.md   → no match (exit 1)
grep -c "Claim sizing" /home/vgpnk/Projects/shokunin/templates/round-prompt.md → 0
grep -n "^## " templates/round-prompt.md → sections 1, 2, 2b, 3, 4, 5 only (140 lines)
```

Relationship: `templates/round-prompt.md` (fleet HEAD, 140 lines, tracked at `f47ad6ba`) is the
*base* prompt — it ends at `## 5. Commit, push scope, L0 side channel` and has **no §9 and no
§10**. The round-44 prompt file is the base with `{{LANE}}`/`{{ROUND}}`/`{{FLEET_ROOT}}`
placeholders substituted **plus** the per-round campaign addendum appended as `## 6.` — that
addendum is what carries the numbered items 1–10, and item 9 is 'Claim sizing'. A mechanical
diff of the first 140 lines against the template shows **only** the placeholder substitutions
(36 diff lines, all `{{…}}` → concrete values, plus the trailing blank line) — i.e. the base
text is reproduced verbatim, and everything from line 141 down is per-round injected content.

Consequence for the row: the anchor **must** cite the committed per-round prompt file (the
fleet commit `75dd2612` blob), not the template. A row anchored on
`templates/round-prompt.md` would point at a file that does not contain the sentence and has no
§9 at all.

### 1.5 How distinctive the quoted sentence is (calibration, not admission)

`grep -rl "The claim is judged on the counter, kill rule and predicate declared before data."`
over `.ufo/prompts/` in the fleet repo matches **742** committed round-prompt files across the
lanes (it is a campaign-addendum clause injected into every lane's per-round prompt). It is
also present in the kagi round-42 and round-43 prompt files. So the sentence is fleet-wide
boilerplate, not a kagi-round-44-specific statement; the *file identity* (this lane's
round-44 prompt at this commit) is what is specific and citable. The row's `teaches` should
therefore be phrased as "the claim-sizing discipline the round-44 dispatch bound this lane by"
rather than as a one-off statement — the located quote stays the sentence itself.

### 1.6 Registry-side facts the L1 will hit (measured, read-only)

- The lane's `corpus/SOURCES.md` at HEAD holds **98 rows**, ids `S001…S098`, and **S099 does
  not yet exist** (`grep -c S099` → 0). So S099 is a *row to be appended* this round, not an
  existing row whose `used-by` cell moves.
- The plan's Frontier sentence "the row's `used-by` cell moves old `—` → the register and the
  lesson" is therefore only executable as an append-then-edit pair (append S099 with
  `used-by` `—`, then change `used-by` in place under registry rule 2, logged old→new in the
  lesson). A row appended directly with its final `used-by` is equally rule-compliant
  (rule 2 restricts in-place edits, not the append's content) and avoids the transient
  `W03` warning (`mined row with used-by = —`) that the census emits for the append-then-edit
  form.
- `scripts/sources-census.sh` check E11 requires every `used-by` path of a `mined` row to
  exist on disk relative to the lane root. If S099's `used-by` names
  `.ufo/waves/round-44/controls/receipt-corrections.md` **and** `corpus/lessons/round-44.md`,
  the lesson file must exist before the after-census runs, or the after-census emits E11.
  Ordering note only — this seat does not judge admission.
- **Id-space hazard for any future assimilation**: the staged merge package's row ids
  `S052…S223` overlap the lane's live ids `S052…S098` (**47 ids**, and for all 47 the staged
  row's source URL *differs* from the lane's live row — 0 of 47 are the same source). The
  staged package's own `S099` is a different source again
  (`TruffleHog OSS, pkg/detectors/detectors.go`), so a future adoption of the merge package
  would collide with the S099 this round opens. This is inventory evidence only; admission is
  not this seat's call.

---

## 2. Assimilation survey (read-only) — inventory backing the round's "Assimilation: none"

Sources surveyed:
- `/home/vgpnk/Projects/shokuknow/merge/kagi/MERGE-REPORT.md` (16 169 bytes, staged by
  `corpus-expansion-1`; header: "Nothing was written into the lane repo.", 172 proposed rows
  accepted / 0 refused, **81 proposed knowledge entries**, lane registry "currently holds 51
  rows" as of staging).
- staged tree `/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/` — **81**
  files (the staged copies of the table's targets).
- lane tree `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/knowledge/` — **35** files.

### 2.1 Table vs lane — the set difference

| class | count | note |
|---|---|---|
| table targets (MERGE-REPORT.md "Knowledge files to add") | **81** | unique target paths |
| staged files present in `merge/kagi/knowledge/corpus/knowledge/` | 81 | table and tree agree 1:1 |
| **same filename already in the lane's `corpus/knowledge/`** | **7** | but **byte-different in all 7** |
| same content under a different lane filename | 0 | sha256 comparison of every staged file against every lane file |
| **unadopted (no lane file of that name, no content match)** | **74** | |

The 7 name-collisions are *not* the staged bytes — each lane file is the lane's own
re-verified revision citing a different (lane) row id, e.g.:

| staged file | staged cites | lane file | lane cites |
|---|---|---|---|
| `oidc-federation-trust-policy.md` | S052–S065 (fetched 2026-10-23) | same name | S061–S065 (fetched 2026-11-03, rendered-text-v1) |
| `betterleaks-detection-vs-validation.md` | S068 | same name | S055 |
| `cdp-bridge-1password-oidc-workflow.md` | S092 | same name | S069 |
| `nist-key-management-guidance-status.md` | S061 | same name | S073 |
| `nist-key-management-parts-withdrawal.md` | S083 | same name | S076 |
| `secret-scanning-detection-vs-validation.md` | S066 | same name | S053 |
| `trufflehog-verification-lifecycle.md` | S070 | same name | S057 |

Lane sizes vs staged sizes for those 7 (staged/lane bytes): 7201/10656, 5157/5497, 4425/8217,
5138/8598, 4624/4993, 6287/6441, 4837/9571 — the lane's copies are the later, re-opened
renderings. No lane file cites `shokuknow` (`grep -rl shokuknow corpus/knowledge/` → none), so
the merge package has never been adopted into the lane's knowledge tree.

### 2.2 The 74 unadopted themes, classified against the three round-44 claims

The three round-44 claims are: **(C1)** a counter-discrimination battery, **(C2)** a
replay-gate run receipt, **(C3)** a receipt-drift corrections register.

| theme (unadopted) | files | matches C1 (counter battery)? | matches C2 (replay-gate run receipt)? | matches C3 (receipt-drift corrections register)? |
|---|---|---|---|---|
| GB/T 17901 series (CN key-management standard) | 9 | no | no | no |
| ISO 11770 series | 11 | no | no | no |
| Sakura Cloud key/secret custody | 1 | no | no | no |
| ja/zh scanning vocabularies & validity taxonomies | 13 | no | no | no |
| SP 800-131A approval/status/hash tables | 8 | no | no | no |
| NIST SP 800-57 family status / parts 2–3 | 2 | no | no | no |
| TruffleHog cache & verification semantics | 12 | no | no | no |
| Betterleaks rule-set deltas | 8 | no | no | no |
| cloud-KMS / Aliyun AccessKey custody | 3 | no | no | no |
| Claude Code secret-scan guards | 1 | no | no | no |
| IPA JP key-management guideline | 1 | no | no | no |
| secret-scanner evidence tiers / detection-vs-validation taxonomies | 3 | no | no | no |
| lane-local localisation audits (r42/r43) | 2 | no | no | no |

**74 of 74 unadopted themes match none of the three claims.** Two checks back this:

1. *Keyword sweep.* A case-insensitive scan of all 74 staged files for
   `counter|mutation|battery|replay|receipt|register|drift|correction|kill rule|predicate`
   hits **15** files — and every hit is a different sense of the word:
   - "counter**part**" (Chinese standard vs NIST; symmetric counterpart; TruffleHog's
     deduplication *counters* in `verificationcache/metrics_reporter.go`; the Chinese
     "Chinese statement | Western counterpart" table) — none is a *claim counter*;
   - "cor**rection**" in the domain sense (an operator's correction to a scan finding, a
     correction to a standard's reading, a correction to the record) — none is a
     *receipt-drift corrections register*;
   - `receipt` / `replay` / `register` / `drift` / `kill rule` / `predicate` — **zero** hits in
     any of the 74.
2. *Surface mismatch.* All 74 are domain knowledge about secret-scanning semantics, key-management
   standards and credential custody — none of them is about counters, replay receipts or
   corrections registers, which are the lane's own instrument surfaces.

The lane already holds its own instrument-surface knowledge (e.g. `corpus/knowledge/claim-ledger.md`,
`drift-gate.md`, `prefreeze-controls.md`, `tac-evidence-integrity.md`, `checklist-execution.md`),
which the merge package does not touch.

**Inventory conclusion (no admission judgment).** The round's "Assimilation: none" verdict is
consistent with the observed inventory: no unadopted staged theme bears on C1, C2 or C3.
Two independent reasons for "none" are on the record and can be stated in the report's
Sources & frontier section:
 (a) *thematic* — none of the 74 unadopted themes matches any of the three instrument claims;
 (b) *id-space* — the staged rows `S052…S223` already collide with the lane's live
     `S052…S098` (47 ids, all with different source URLs), and the staged package's own `S099`
     would collide with the S099 this round opens, so a wholesale adoption is not a
     row-level no-op. (b) is an inventory observation, not a claim of exclusion.

### 2.3 `considerthese/2026-10-26.md` proposals 1 and 3 — still unimplemented (re-measured)

The plan says these remain unimplemented. Measured in the lane today:

- proposal 1 — "A repair-only release path under a HOLD" (`considerthese/2026-10-26.md`
  lines 49–53): the lane holds **no** HOLD-release mechanism (grep finds no such path; the lane
  is under the operator HOLD recorded as `kagi | round-28`). This is operator policy, so it is
  not a lane-implementable claim — matches the plan's stated reason.
- proposal 3 — "Mark known-defective instrument output … append a `KNOWN_DEFECT: D1` qualifier
  to a `CLEAN` verdict" (lines 60–62):
  `grep -c 'KNOWN_DEFECT' corpus/release-clock.py` → **0** (the file exists at
  `corpus/release-clock.py`), the same measurement the round-41/42/43 lessons recorded. Proposal
  3 needs its own predicate and counter — no slot this round. Matches the plan's stated reason.

Neither is a theme of the merge package; both are lane-local, and both remain unimplemented for
the reasons the plan records.

---

## 3. Confidence and remaining unknowns

**Observed (commands run, exit codes above):** file bytes + sha256 + size at `75dd2612`; HEAD
hash today; no drift on the path (diff rc 0, identical blob id); §9 item and anchor line/offset;
the template does not contain the sentence; the 742-file spread of the sentence; the merge
table/tree/lane set difference (81 / 7 byte-different / 0 content-matches / 74 unadopted) with
per-theme classification; proposals 1 and 3 still unimplemented.

**Unknowns / limits of this survey:**
- I did not re-derive the merge package's *rows* (`SOURCES.append.md`, 172 rows) against the
  lane registry beyond the id-overlap count; the row-level diff is the connector's/L1's call.
- The merge package is 12 days old (staged 2026-10-24) and its "lane registry currently holds
  51 rows" statement is stale relative to the lane's 98; a re-staged package would differ. My
  survey is of the package as it stands on disk today.
- Whether the merge package's staged `knowledge/` tree has an `amendments/` sub-tree is **not**
  resolvable from the package as delivered: MERGE-REPORT.md's adopt checklist step 5 refers to
  "every file under `amendments/`", but `merge/kagi/` contains no `amendments/` directory
  (only `MERGE-REPORT.md`, `MERGE-REPORT.json`, `SOURCES.append.md`, `knowledge/`). The four
  "amendment" targets the report names (`gbt-17901-3-adoption-mapping-r37.md`,
  `nist-131a-approval-status-rev2-rev3-r37.md`) are **not** present in the staged tree either,
  so they are outside the 81 and outside the 74. Noted for completeness, not judged.
- I did not run the lane's census (host-heavy; out of scope for this seat) — the committed
  `census-start.txt` receipt (`kagi ok`, 98 rows, 19 W04 warnings) was read as evidence, not
  re-measured.

## 4. Tooling

No tools were installed or upgraded by this seat; no `pacman`/`uv`/`cargo`/`npm` transaction was
performed. Everything used was already present: `git`, `curl`, `grep`, `awk`, `sed`, `wc`,
`sha256sum`, `python3` (stdlib only).
