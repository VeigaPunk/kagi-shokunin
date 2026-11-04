# ScoutSource — S088 own-work source, round 35 (read-only)

Scope: reopen S088 exact source and scope; locate the <=25-word quote; verify cited bytes and old/current boundaries; inspect `corpus/source-fetches.tsv` S088 schema and whether adding the lesson to used-by needs capture or classification changes; check the knowledge entry against gate behaviour. No code was executed. Hashes and reads only. Raw receipt: `.ufo/waves/round-35/build/ScoutSource/receipts.txt`.

## 1. Exact source row

BASE `063c407` registry row, `corpus/SOURCES.md` line 95 (identical in worktree except the used-by cell):

```
| S088 | Own-work pre-freeze control source — https://raw.githubusercontent.com/VeigaPunk/kagi-shokunin/97b35ceec87cceac25d1e0e5f92f75c953728802/corpus/prefreeze-control.sh | own-work | A | shipped numeric BASE-control implementation, not shell-command truth or confinement | prefreeze-control.sh header, measurement rule, revision 97b35ceec87cceac25d1e0e5f92f75c953728802; opened 2026-11-04 | The counter reads the final digit run of the last non-empty stdout line; command validity is outside this rule. | mined | 2026-11-04 | on-change | corpus/knowledge/prefreeze-controls.md |
```

- Registry status `mined`, tier A, scope = the numeric counter's measurement rule only.
- Used-by at BASE: `corpus/knowledge/prefreeze-controls.md`.
- Worktree (uncommitted, `git -C … diff`): used-by becomes `corpus/knowledge/prefreeze-controls.md, corpus/lessons/round-35.md`. That is the only change to `corpus/SOURCES.md`.

## 2. Quote verification (<=25 words)

Lesson `corpus/lessons/round-35.md` Gate quotes: “Exit codes are deliberately ignored (`grep -c` exits 1 while printing”.

- Pinned blob `97b35cee:corpus/prefreeze-control.sh`, line 18: `# SETUP. Exit codes are deliberately ignored (`grep -c` exits 1 while printing`. Quote is 11 words and sits on line 18 alone. The lesson writes "header lines18–19"; the quote itself ends on 18 and line 19 starts `# 0, which is a measured 0).`. Cosmetic only.
- Same line 18 in BASE `ca338da7`. Quote is located at both revisions.
- Lesson cites the measurement-rule ceiling at header lines 29–34. Confirmed at both revisions: lines 29–30 "Named ceiling: numeric counters only; an integer-shaped line from a failing command still counts", lines 31–34 the final-digit rule.

## 3. Bytes and old/current boundaries

| object | revision | sha256 | bytes/lines | status |
|---|---|---|---|---|
| gate `corpus/prefreeze-control.sh` | `97b35cee` (S088 pin) | `b634a8d1…d9098` | 12421 / 273 | equals the registry capture digest (`source-fetches.tsv` S088 `decoded-http-body-v1`) |
| gate | BASE `063c407` | `ca338da7…6493a` | 13427 / 288 | equals `corpus/stamps.tsv:96` |
| gate | worktree | `ca338da7…6493a` | 13427 / 288 | equal to BASE; no uncommitted gate edit |
| `corpus/knowledge/prefreeze-controls.md` | BASE = worktree | `ee849a24…fd9d1` | 6398 / 103 | equals `stamps.tsv:55` |

Diff `97b35cee → BASE` on the gate (`git -C … diff`): two hunks only.
1. Header comment: "eleven cases" → "twelve cases", plus a relative-work paragraph.
2. Selftest: a new `relative-work` case block.

The measurement loop (`last=$(…| tail -n 1)`, `[[ $last =~ ([0-9]+)[^0-9]*$ ]]`, NORESULT / SETUP / timeout branches) is byte-identical across the two revisions. The S088 teaching therefore holds at BASE. The source identity is still the 97b35cee capture, and the lesson's ADMIT already says "historical implementation semantics only". This is consistent.

## 4. source-fetches.tsv S088 schema and capture/classification impact

`corpus/source-fetches.tsv` line 131, 16 columns, all valid per the census contract: id `S088`, status `mined`, row_identity_sha256 `f87ede31…2a8d` (I recomputed `printf 'S088\tmined\t<url>\n' | sha256sum` → `f87ede31…2a8d`, matches), registry URL = final URL, http 200, `curl-fsSL-compressed-v1`, fetched 2026-11-04, `decoded-http-body-v1`, digest `b634a8d1…d9098`, 12421 bytes, rev `97b35cee…`, `raw-literal-v1`, no normalized digest, quote 10 words, location `header comment: measurement rule, lines 14-16`.

Conclusion: **adding the lesson to used-by needs no capture or classification change.**
- Row identity is `id<TAB>status<TAB>url` only. used-by is not in it.
- S088 has no in-row `Fetch sha256:` pin, so `corpus/inrow-pins.tsv` is not involved (`grep S088 corpus/inrow-pins.tsv` → no match).
- Registry id, status, URL and tier are unchanged.

## 5. Minimal lawful mutable-cell update

Census contract (`corpus/sources-census.sh` lines ~216–232, read not executed): for each used-by path of a mined row it requires the path to be a regular file whose first `source:` line (`src_field`) contains the id token. Lessons are allowed by the regex `^corpus/(knowledge|lessons)/…\.md$`.

The current worktree does **not** satisfy this:
- `grep -c '^source:' corpus/lessons/round-35.md` → 0 (receipt).
- So `src_field` is empty, the id test fails, and the census should emit `SC_USEDBY_NOCITE id=S088 path=corpus/lessons/round-35.md`. **[INFERENCE from reading the census; not executed per assignment.]**

Minimal lawful options:
- **(A, the declared path)** Keep the SOURCES used-by change, and add one column-1 line at the top of `corpus/lessons/round-35.md`, e.g. `source: S088 (own-work corpus/prefreeze-control.sh at 97b35ceec87cceac25d1e0e5f92f75c953728802; S088 quote located at header line 18)`. Lessons are not knowledge entries, so the entry checks (SC_ENTRY_*) do not apply. Precedent: `corpus/lessons/round-22.md` begins with a `source:` line (grep result, line 1).
- **(B, smallest)** Revert the used-by cell to `corpus/knowledge/prefreeze-controls.md` only. The census only checks that listed paths cite the id, not that every citer is listed. No capture, classification or lesson edit is then needed. The lesson's citation stays in prose.

Recommendation: A, because the plan declares it and the cell then records a real consumer. Without the `source:` line the worktree fails the census. B is the fallback if the lesson line cannot be added.

No source definition, id, tier, anchor, status or recheck cell needs to change. `recheck: on-change` is untouched.

## 6. Knowledge entry vs actual gate behaviour

Entry `corpus/knowledge/prefreeze-controls.md` (BASE = worktree, stamped). Checked against the BASE gate (= the code the round-35 instrument runs):

1. "Measurement is the last non-empty stdout line, reduced to its final run of digits." — **accurate.** `last=$(… | grep -v '^[[:space:]]*$' | tail -n 1)`, then the final digit run.
2. "A command that prints no integer is NORESULT." — **accurate**, since the regex needs at least one digit on the last non-empty line.
3. "The gate therefore does not treat a nonzero command exit as a failure … Only an unmeasurable row … is NORESULT." — **accurate for exit codes**: the only exit-code branch is `rc -eq 124` (timeout). Nothing else reads rc. But the list "no integer on the last line, a timeout, a missing file" overstates the third item: there is no missing-file branch; a missing file yields NORESULT only if it leaves stdout without digits.
4. Heading "Why the exit code is part of the measurement" contradicts its own body, which says the exit code is **not** part of the measurement. Wording defect.
5. Falsifier 2: "A command printing a verdict line whose last token is not a number must produce `NORESULT`." — **false at BASE.** The regex is "last digit run followed by any non-digits", so `PREFREEZE: CLEAN (controls=0 mismatch=0)` has final digit run `0` and is measured 0, matching an `expect=0` row, rc 0 OK. That is precisely the frozen instrument's `clean-forgery` case (`controls/measure.py`, expected rc2 NORESULT). The entry's falsifier is the opposite of observed behaviour, and the lesson's "numeric-CLEAN forgery" claim depends on this exact gap. Read-derived from the regex; not executed.
6. The header's named ceiling ("an integer-shaped line from a failing command still counts") is **not** reproduced in the entry. The entry therefore never tells a reader that a failing producer's numeric line is accepted. This is the defect round 35 targets; the entry should say so.
7. "verified-at: 2026-11-04 — published source reopened" and the source row both bind to 97b35cee. BASE gate bytes differ from that pin (+relative-work case, 11→12 selftest cases). The entry's own recheck, `on-change — … replay the frozen BASE controls after any gate change`, has fired at BASE with no recorded re-verification. The measurement rule is unchanged, so the entry is still accurate about the rule, but its "current execution" linkage is stale.
8. Stamps: entry and gate hashes match `corpus/stamps.tsv` (receipt). No stamp drift.

Round-35 candidate impact (from the frozen plan, not executed): the candidate contract will turn rc≠0 (except rc1+`0`) and the diagnostic/SETUP-shaped lines into NORESULT. Entry statements 1–4 and 7 will then be false for the new gate. The entry must be updated in the landing, not left to the on-change recheck.

## 7. Checks not run / boundaries

- No code executed; no gate, selftest or measure.py run. Every verdict above is read from bytes, hashes and `git -C … show|diff` output.
- The lesson's "five false-CLEAN at BASE" matches `controls/before.json` (`mismatches` 5, `invalid_false_clean` 5). I read the summary fields only.
- Not checked: `corpus/claim-ledger.tsv` rows that run `prefreeze-control.sh --selftest` (BASE selftest count now 12). L1 should check any count pin against 12.
- Scratch `/fast/scratch/hyaku/kagi-r35/ScoutSource/` (gate copies) removed after the receipt was written.
- Report location: the seat spec names `build/ScoutSource/` (this file) and the footer names `build/ScoutSource.md`. I wrote only inside `build/ScoutSource/` because the ticket restricts writes to the seat directory. L1 should pick the path.

Report: .ufo/waves/round-35/build/ScoutSource/report.md
