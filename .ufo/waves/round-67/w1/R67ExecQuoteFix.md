# R67ExecQuoteFix — capture read-through audit + S115 re-cut (round 67, w1)

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`, BASE
`076701a11a58e3eb58d996b4c76c5e18071fb179`, predeclaration
`plans/round-67.md` @ `aa8807e443166f45485e1aada2989f646efc707c`. Leaf seat: nothing
committed, nothing `git add`ed; this seat wrote no lane file outside this report dir. The L1
landed the re-cut line below (`applied=18-word`, §2a). Gate/counter scripts
(`corpus/sources-census.sh`, `plans/round-67-c1.sh`, `plans/round-67-c2.sh`) are other seats'
sole-writer files and were not touched or run.

Axes named: **freshness** (make the row's declared evidence actually resolve against the
bytes), **calibration** (a re-cut that no committed record contradicts), **coverage** (the
whole 36-row class, not the one known failure).

## 1. Census of the 36 capture-path-shaped rows — table in `R67ExecQuoteFix/quote-audit.tsv`

Population derived by the frozen shape (`col16` contains `/` and matches
`^[A-Za-z0-9._][A-Za-z0-9._/-]*$`), never listed: **36 rows**, prose rows **120** (156 data
rows total, all 16 columns).

| check | result |
|---|---|
| file exists, regular, `realpath` inside the tree | 36 / 36 |
| `sha256` == col 10 | 36 / 36 |
| byte count == col 11 | 36 / 36 |
| col 15 normalized digest == `rendered-text-v1.py digest` (31 `rendered-text-v1` rows; 5 `raw-literal-v1` rows carry `-`) | 31 / 31 rendered rows match; the 5 `-` rows as declared |
| col 13 quote locates `count >= 1` under col 14 | **35 / 36** — **S115 `count=0`** |
| capture file tracked by git (so a `--tree` checkout resolves it) | 36 / 36 |
| declared quote word count ≤ 25 | 36 / 36 (range 2–25; **S133 sits exactly at 25**) |

BASE totals for the frozen counter: `path_rows=36 bound=36 located=35 prose=120` — one short
of guard (a)'s required `located=36`, which is exactly why the re-cut is the landing surface.

Only defect: **S115** `.ufo/waves/round-57/capture/S115.body`, `rendered-text-v1`,
`RENDERED_TEXT_V1_LOCATE: count=0` (rc 1). Body verified: 41787 B, sha256
`76339ff7…0d79090c6`, normalized `781463ac…a7d147` — col 10/11/15 are all correct; only the
quote is wrong. This matches `corpus/source-fetches.tsv`'s pre-existing state, round-66 routed
defect 8 and QM93.

Occurrence counts worth knowing for the counter design: `S100=4, S101=2, S102=4, S114=13`
(short ISO title strings, legitimate but matched several times per page), every other locating
row `count=1`.

### Root cause of the S115 miss (measured, not inferred)

`rendered-text-v1` step 3 replaces each tag with one SPACE, so the markup
`<code>audit stanza</code>.` normalizes to `audit stanza .` — the full stop is **not**
byte-adjacent to `stanza`. Ordinal dump over the span: `… 0x61 'a' 0x20 SPACE 0x2e '.' 0x20
SPACE 0x57 'W' …`. The declared quote is normalized by steps 5–6 only (text, not markup), so it
reads `stanza.` and `locate` returns 0. The sentence itself is present and is the one the trial
cites (`knowledge/openbao-audit-device-custody.md:42`, T1).

## 2. The S115 re-cut — exact line for the L1 to apply

`R67ExecQuoteFix/s115-recut-line.tsv` (16 tab-separated columns, only **col 13** differs;
col 3/10/11/14/15/16 verified correct and untouched):

```
S115	mined	d29af8f0b56b51bac2605cac975ec206eeb5333d27239aeb26e7f34a1179b548	https://openbao.org/docs/audit/	https://openbao.org/docs/audit/	200	curl-fsSL-compressed-v1	2026-11-07	decoded-http-body-v1	76339ff7dab618b5e5532bca6daf9dd8361330a43b737408304abfd1d79090c6	41787	-	Audit devices must be enabled by a root user using bao audit enable or using the audit stanza	rendered-text-v1	781463acbf1493a58c0f87ec981809f6f80bd63196e8006ff274c87593a7d147	.ufo/waves/round-57/capture/S115.body
```

New col 13: `Audit devices must be enabled by a root user using bao audit enable or using the
audit stanza` — **18 words** (same tally the round-57 lesson states), `locate count=1` (rc 0),
single contiguous passage under the live heading `Enabling/Disabling audit devices`, and it
supports the row's teaching (audit devices are enabled by a root user, by CLI or the `audit`
stanza).

Rejected alternative: keep the full stop and declare `… or using the audit stanza .` — it also
locates `count=1`, but it carries the normalizer's tag-space artifact into the declared quote
verbatim. The no-terminal-punctuation form follows the round-66 S156 precedent
(`Maximum 3 requests per second per user`).

Re-running the frozen predicate on a scratch copy carrying only this change:
`bound=36 located=36`, `path_rows=36 prose=120`, all 156 rows still 16 columns,
S115 `count=1`, `wc -w` = 18.

### Proposed diff (`R67ExecQuoteFix/s115-recut.diff`) — one line, col 13 only

```diff
--- a/corpus/source-fetches.tsv
+++ b/corpus/source-fetches.tsv
@@ -155,7 +155,7 @@
 S114	mined	fa0c2dabb9f98818e3a1a07ae30a0f12a330a1a27d209b147ce6397d92a46672	https://www.iso.org/standard/85929.html	https://www.iso.org/standard/85929.html	200	curl-fsSL-compressed-v1	2026-11-07	decoded-http-body-v1	8bb88d88ff21d4488cf2205d9655a7fcbdeb3601616bdf4f5767dce13c449bdf	85138	-	ISO/IEC 11770-3:2021/Amd 1:2025	raw-literal-v1	-	.ufo/waves/round-55/capture/S114.body
-S115	mined	d29af8f0b56b51bac2605cac975ec206eeb5333d27239aeb26e7f34a1179b548	https://openbao.org/docs/audit/	https://openbao.org/docs/audit/	200	curl-fsSL-compressed-v1	2026-11-07	decoded-http-body-v1	76339ff7dab618b5e5532bca6daf9dd8361330a43b737408304abfd1d79090c6	41787	-	Audit devices must be enabled by a root user using bao audit enable or using the audit stanza.	rendered-text-v1	781463acbf1493a58c0f87ec981809f6f80bd63196e8006ff274c87593a7d147	.ufo/waves/round-57/capture/S115.body
+S115	mined	d29af8f0b56b51bac2605cac975ec206eeb5333d27239aeb26e7f34a1179b548	https://openbao.org/docs/audit/	https://openbao.org/docs/audit/	200	curl-fsSL-compressed-v1	2026-11-07	decoded-http-body-v1	76339ff7dab618b5e5532bca6daf9dd8361330a43b737408304abfd1d79090c6	41787	-	Audit devices must be enabled by a root user using bao audit enable or using the audit stanza	rendered-text-v1	781463acbf1493a58c0f87ec981809f6f80bd63196e8006ff274c87593a7d147	.ufo/waves/round-57/capture/S115.body
 S116	mined	9f8b630eda927a1977afb1da648b0336952ede0985dc4c64a8af91403088ef38	https://openbao.org/docs/commands/audit/	https://openbao.org/docs/commands/audit/	200	curl-fsSL-compressed-v1	2026-11-07	decoded-http-body-v1	3dc8873201fdb3a971eb5fb1c1cee6a804462510c962ea5df6121cad0d9905ce	33338	-	even if you re-enable the audit device at the same path, as a new salt will be created for hashing.	rendered-text-v1	b23ff89dc153fc17f281793b22d2182a68d515ca6df16451b37917493e2b016e	.ufo/waves/round-57/capture/S116.body
 S117	mined	dfeaa34a1ab953c1cf3431f0f5b45e5ed07237067faaa5587be4f67f1a034f20	https://openbao.org/docs/api/system/audit-hash/	https://openbao.org/docs/api/system/audit-hash/	200	curl-fsSL-compressed-v1	2026-11-07	decoded-http-body-v1	bca1461ee6a1a2a3ca0658f815535878de29446b9459fe2283f3c0e62beeaca9	35071	-	This endpoint hashes the given input data with the specified audit device's hash function and salt.	rendered-text-v1	65cb7bc550ca78a172801394940f9b81420f762aa9c581525d96a2788127b693	.ufo/waves/round-57/capture/S117.body
 S118	mined	dd9051cee7ad78617fd4936a359189a04533140a63486bd9ce5f17a096c98d83	https://openbao.org/docs/concepts/policies/	https://openbao.org/docs/concepts/policies/	200	curl-fsSL-compressed-v1	2026-11-07	decoded-http-body-v1	a55ff1a4caf12c3a62bcaab61ff95fef1d382cba01da5dbd4521dbfbca6e1468	122498	-	Policies are deny by default	rendered-text-v1	9e6355bb51a3f6385c1345f0e2162dc10de8e46fd61110d7f41e195e38173292	.ufo/waves/round-58/capture/S118.body
```

### sha256 of `corpus/source-fetches.tsv`

```
before  d2f050b6bf16be382feab19dc3895c95d0646501c9a59edb0c668f0a5bfa6611   87113 bytes
after   60fa5d1059ecac55bf4d60f5c6cb2a3db0ca20cd9f48845a89f859f8a80ed1da   87112 bytes   (single-line diff applied)
```

### §2a Applied (L1 landed it; re-verified here read-only)

`applied=18-word` — the L1 landed the canonical 18-word form in `corpus/source-fetches.tsv`
(col 13 only) and its post-digest equals this receipt's expected after-digest, which proves no
other cell moved. Re-verified after landing:

```
$ sha256sum corpus/source-fetches.tsv
60fa5d1059ecac55bf4d60f5c6cb2a3db0ca20cd9f48845a89f859f8a80ed1da  corpus/source-fetches.tsv   (87112 bytes)

$ grep -P '^S115\t' corpus/source-fetches.tsv | awk -F'\t' '{print NF}'
16
$ grep -P '^S115\t' corpus/source-fetches.tsv | cut -f13
Audit devices must be enabled by a root user using bao audit enable or using the audit stanza

$ python3 corpus/rendered-text-v1.py locate .ufo/waves/round-57/capture/S115.body "$(grep -P '^S115\t' corpus/source-fetches.tsv | cut -f13)"
RENDERED_TEXT_V1_LOCATE: count=1
```

L1's independent cross-check agrees: the same sentence **with** a terminal period does not
locate (that period is the round-57/66 mismatch), the landed form does. Recorded, not re-cut.

Open note for integration (no re-cut proposed, per the L1): R67ExecGate's mutation/selftest
fixture used the 10-word prefix `Audit devices must be enabled by a root user` (also
`count=1`). The shipped string is the 18-word form; the gate proof's counted numbers
(`path_rows=36 bound=36 located=36 prose=120`) are unaffected because both forms locate, but
any fixture that stores `col13` text should store the shipped 18-word string so the proof and
the landed row quote the same bytes.

## 3. Where the replacement quote appears elsewhere (`R67ExecQuoteFix/replacement-quote-hits.txt`)

Committed hits — **4**, none contradicts the re-cut:

| path | form | verdict |
|---|---|---|
| `corpus/SOURCES.md:122` | registry note, terminal period | not a contradiction: same sentence; the location cell `§Enabling and disabling audit devices` stays true. No gate binds the TSV quote to this cell — `corpus/quote-locate.py` cross-checks only the 13 ids in `corpus/quote-bodies.tsv` (S089–S093, S100–S102, S111–S114), and **S115 is not among them** |
| `corpus/knowledge/openbao-audit-device-custody.md:42` | T1 evidence cell, `` bao audit enable `` backticked + period | not a contradiction: backticks render the `<code>` element; the tagged form was never locatable |
| `corpus/lessons/round-57.md:39` | "Located quote (18 words) … stanza." | not a contradiction and the tally survives (re-cut is still 18 words); what was false is the word "Located" for the period-terminated form — the pre-existing record defect round 66 routed |
| `corpus/lessons/round-57-verifier-spotcheck.md:134` | spot-check, period, "is at the live §Enabling/Disabling audit devices" | not a contradiction: section-level claim is true |

`corpus/quote-bodies.tsv`, `corpus/recheck-captures.tsv`, `corpus/knowledge/*`, `plans/*`:
**no other hit** (grep is backtick-tolerant; `plans/round-67.md` mentions S115 but not the
quote).

Historical receipts under tracked `.ufo/`: `…/round-58/build/R58MutCounter/MUTATIONS.diff:60-61`,
`…/R58ReviewerCounters/exploit/hostfixed/corpus/SOURCES.md:122`, `…/exploit/hostfixed/corpus/lessons/round-57.md:39`,
`…/exploit/trivial-quote-lesson.md:39` — records of a past mutated/probed state, read by no
gate against `source-fetches.tsv`; not contradictions.

**Conclusion: no committed file contradicts the re-cut row.** The only divergence anywhere is
the terminal full stop, which cannot be made byte-identical without editing `SOURCES.md:122`
(outside this seat's scope; the L1's call, and not required by C1).

## 4. Interface notes for the gate and counter seats (measured; no edits made)

1. **The absolute-location mutant is not capture-path-shaped under the frozen regex.** A value
   beginning `/` fails `^[A-Za-z0-9._][A-Za-z0-9._/-]*$`, so a gate that classifies purely by
   that regex counts it as prose and prints `CLEAN` — the leg misses. Safe fix, measured: no
   prose row starts with `/` and none carries `..` (120 prose rows checked; 17 contain a `/`,
   all with spaces or parentheses), so treating a leading `/` as capture-intent and emitting
   `FINDING SC_CAPTURE id=<S-id> capture-outside-root` reclassifies nothing today.
2. **The `..` mutant *does* match the regex** (`..` is `[A-Za-z0-9._]` then `.` + `/`), and a
   `..` path need not exist. Test `realpath` containment **before** `isfile` so it deterministically
   yields `capture-outside-root`, not `capture-missing`.
3. **The repoint leg violates two predicates at once** (different size *and* different digest —
   e.g. repointing S115 at `S116.body` gives 33338 B ≠ 41787). If the gate prints one finding
   per row with a single reason, the leg's expected reason can be the wrong one. Emit one
   `FINDING SC_CAPTURE` **per violated predicate** (id repeated) so `repoint→capture-digest-mismatch`
   and `truncate-by-1→capture-bytes-mismatch` are both present; that also keeps the frozen
   reason set intact.
4. **`path_rows` must be counted from the column shape alone**, not from successful binding —
   otherwise the delete/repoint mutants print `path_rows=35` and the CLEAN/FAILED line and
   guard (a) become ambiguous. Guard (a)'s exact string, as measured here, is
   `SOURCES_CAPTURES: CLEAN (path_rows=36 bound=36 located=36 prose=120)` — and it is reachable
   only *after* the re-cut, since BASE reads `located=35`.
5. `S133`'s quote is exactly 25 words: a future re-cut of any row must stay ≤ 25 under
   `printf '%s' "$q" | wc -w`.

## 5. Ceilings and honest limits

- `located=36` means "the declared passage exists in the named bytes under the declared
  normalization". It does **not** mean the quote supports the row's teaching, and `count >= 1`
  cannot distinguish an incidental match: four rows locate 2–13 times (S100=4, S101=2, S102=4,
  S114=13 — short ISO title strings). No change proposed; named so the axis is not overclaimed.
- I did not run the lane gate, `plans/round-67-c1.sh`, `plans/round-67-c2.sh`, the fleet
  wrapper, or any mutation leg — those are R67ExecGate / R67ExecCounterC1 / R67ExecCounterC2
  sole-writer surfaces and the wave's post-integration gate is the L1's. Every number above is
  from a command in this receipt; nothing here is a run I did not make.
- Cross-check incidental to the sweep, not a defect: S143 (round-63 capture) and S164
  (round-64 capture of the same URL) differ at byte 128 — `cmp` says char 128 — the historical
  date-stamp delta M66-12 records; each row's digest matches its own file, so both attest
  truthfully.

## 6. Files written (nothing else; scratch deleted)

```
.ufo/waves/round-67/w1/R67ExecQuoteFix.md
.ufo/waves/round-67/w1/R67ExecQuoteFix/quote-audit.tsv           36 rows + verdict
.ufo/waves/round-67/w1/R67ExecQuoteFix/locate-counts.txt        per-row locate command + output
.ufo/waves/round-67/w1/R67ExecQuoteFix/s115-recut.txt           body digests, both locate runs, codepoint dump
.ufo/waves/round-67/w1/R67ExecQuoteFix/s115-recut-line.tsv      the 16-column replacement line
.ufo/waves/round-67/w1/R67ExecQuoteFix/s115-recut.diff           proposed one-line diff
.ufo/waves/round-67/w1/R67ExecQuoteFix/replacement-quote-hits.txt
```

`corpus/source-fetches.tsv` was not written by this seat; the L1 landed the 18-word re-cut and
the file now reads sha256 `60fa5d1059ecac55bf4d60f5c6cb2a3db0ca20cd9f48845a89f859f8a80ed1da`
(87112 bytes, §2a). No commits, no `git add`, no edits to sibling lanes, `scripts/`,
`.ufo/state`, `MANIFEST.json` or `templates` from this seat.
