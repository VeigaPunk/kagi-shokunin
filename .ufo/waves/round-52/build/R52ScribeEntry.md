# R52ScribeEntry — round-52 lesson material (Gate, Mistakes, entry accuracy)

Round 52, attempt 1. Seat **R52ScribeEntry** (scribe; leaf, no subagent dispatch).
Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`; BASE `1d984adaa4a5c66ea9f24cb95bf79ffbca16c32b`; predeclaration `52ebb412561d9601ad8658c30d1cfa0087af64d4`.
Scratch `/fast/scratch/hyaku/kagi-r52/R52ScribeEntry/` (`S110.refetch.body`, `S110.rendered.txt`, `probe/run.sh`). Receipts `.ufo/waves/round-52/build/R52ScribeEntry/receipts/` (digest, locates, word counts, re-fetch, entry probe + its script, registry/SCORECARD pointers, K2 control lines, fixture identity, draft extract + scan).
Nothing in `corpus/`, `plans/`, the fixtures, the counters or the controls was edited. The working tree already held other seats' round-52 changes (`SCORECARD.md`, `corpus/SOURCES.md`, the entry, `corpus/lessons/round-51.md`, the trial); every one was read only. This report and its `receipts/` directory are the only artifacts this seat wrote.

Status of the two paste-ready blocks: `## Gate` and `## Mistakes` for `corpus/lessons/round-52.md`. The other lesson sections (Claims, Frontier, Assimilation, considerthese, Routed) belong to other seats and are not drafted here; the Routed bullets this seat can ground are in §4.

---

## 1. Draft — `## Gate` (paste-ready)

<!-- BEGIN DRAFT GATE -->
## Gate

- **S110 — new, opened 2026-11-07** (capture `.ufo/waves/round-52/capture/S110.body`; declared request profile `curl-fsSL-compressed-v1` = `curl -fsSL --compressed`; provenance row `corpus/source-fetches.tsv:153`: status `mined`, HTTP 200, `2026-11-07`, representation `decoded-http-body-v1`, raw sha256 `6cfd72ec…b1587`, 83532 B). Independently re-fetched by R52ScribeEntry at 2026-11-07T02:03Z and again at 02:07Z with the same profile: HTTP 200, 11443 B on the wire (compressed transfer), 83532 B decoded, sha256 identical to the capture, `cmp` byte-identical. `https://openbao.org/docs/secrets/kv/kv-v2/`, decoded body sha256 `6cfd72eca347d0dfbcea73ad429ae5db3f01f2710cd794a473b00047e02b1587` (83532 B), normalized sha256 `6bbd6c4cc131b898965fd573ac68d8307bfc84172ad59874d1188394903b31b6` (15529 B); OpenBao docs **Version 2.7.x** (page selector `Version 2.7.x` and `docs-version-2.7.x`). Located quotes — `python3 corpus/rendered-text-v1.py locate <capture> "<quote>"` → `count=1` each; word count `printf '%s' "<quote>" | wc -w`:
  - "In order for a write to be successful, cas must be set to the current version of the secret." — **19 words**, §Usage → Writing/Reading arbitrary data (the `-cas` paragraph); the T1 anchor.
  - "When deleting data the standard bao kv delete command will perform a soft delete." — **14 words**, §Deleting and destroying data; the T2 anchor and the S110 fetch-row quote.
  - "A version's data is permanently deleted only when the key has more versions than are allowed by the max-versions setting" — **20 words**, §Deleting and destroying data; the T3/T4 anchor. The page continues the sentence with `or when using bao kv destroy` (6 words, `count=1`), which is why one sentence anchors both tests; the full sentence is **26 words**, over the ≤25-word quote rule, so the entry quotes the 20-word clause and states the continuation in prose.
  - "Permanently delete all metadata and versions for a key" — **9 words**, §Key metadata; the T5 anchor. The mechanic sentence immediately before it states the same fact: "Deleting the metadata key will cause all metadata and versions for that key to be permanently removed." (**17 words**, `count=1`).
  - Not cited by the entry, located for the next recheck of T4: "Max versions changes will be applied on next write" (**9 words**, §Key metadata, `count=1`) and "Once a key has more versions than max versions the oldest versions are cleaned up" (**15 words**, §Key metadata, `count=1`).
- **What the page does not state** (these are measured by the trial, not taught by S110): the `-cas` refusal text (`check-and-set parameter did not match the current version`; the page gives the rule only), whether `kv undelete` after `kv destroy` is accepted or refused (the page defines undelete as the reversal of a soft delete), and the JSON field names the trial reads (`data`, `metadata.deletion_time`, `metadata.destroyed`; the page prints the human table).
- **Rows added:** 1 (S110; tier A, `mined`, `recheck 180d`). **Rows touched:** none. Registry 109 (`kagi ok`, rc 0, `.ufo/waves/round-52/controls/census-start.txt`) → 110 in the candidate tree.
- **Rejected:** none fetched this round; the plan names no candidate to reject. S024 (Vault KV v2 API, `max_versions`) remains a documentation row and is not extended to OpenBao (entry §Scope).
- **Discernment sample (LEARNING.md):** admit — S110 (five mechanics executed by the trial; every quoted sentence located once in the committed capture).
- **Counting rule (E49-1):** every word count stated in this `## Gate` is `printf '%s' "<quote>" | wc -w`.
<!-- END DRAFT GATE -->

---

## 2. Draft — `## Mistakes` (paste-ready)

<!-- BEGIN DRAFT MISTAKES -->
## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M52-1 | `doc-over-read` (a rejection reason attributed a page/binary split to a sample response that never states its input token's creation path) | At BASE `1d984ada`: `corpus/knowledge/vault-openbao-token-lease-lifecycle.md:292` and `corpus/lessons/round-51.md:22`; the round-51 closure records the same reading at `corpus/lessons/round-51-verifier-spotcheck.md:104`. `bash plans/round-52-c2.sh 1d984ada` prints `C2_REWRAP_STATEMENTS: value=2 assertions=2 guard=1 probe=1 obs_helper=sys/wrapping/wrap obs_kv=secret/data/<path> uncorrected=[corpus/knowledge/vault-openbao-token-lease-lifecycle.md:292 corpus/lessons/round-51.md:22]`, rc 0; control K2-0 `expect=2 got=2 MATCH` (`.ufo/waves/round-52/controls/controls-prefreeze.txt:21-22`). | none — the round-51 pre-freeze controls sampled file paths, comments and code spans, never the sample-response prose. | C2: two appended `Correction (round 52, D1)` lines (fixtures `.ufo/waves/round-52/controls/fixtures/ref/corrections/entry.txt`, `lesson.txt`), each naming its `<file>:<line>` and both measured creation paths. **Shown able to fail:** K2-0 2, K2-F1 (literals swapped) 2, K2-F3 (wrong pointer) 1, K2-F7 (only the entry corrected) 1, all MATCH (`controls-prefreeze.txt:21-38`; `CONTROLS: match=20 mismatch=0`). |

Misroot sweep (§3): the counter's `assertions=2` at BASE, over the whole scoped tree (`*.md` outside `.ufo/`, `plans/`, `considerthese/`; excluding `*-verifier-spotcheck.md` and `*aggregator*`), places the root in exactly those two round-51 sentences, not in the lane's other pages. The two correction lines are append-only errata; no BASE line was rewritten (counter GUARD reads `guard=1` at the candidate).

Named ceiling (not fixed this round): the assertion pattern is lexical. `SCORECARD.md:1783` at the round-52 candidate (BASE `:1778`) states the same over-read in vocabulary the pattern does not reach, so it sits outside the frozen population (BASE 2 is the number); the appended SCORECARD erratum E52-1 (`SCORECARD.md:1800`) names both line numbers.
<!-- END DRAFT MISTAKES -->

---

## 3. Entry errors: reference entry vs the page (assignment item 3)

**Result: none found.** The reference entry `corpus/knowledge/openbao-kv-v2-version-lifecycle.md` is byte-identical to `.../controls/fixtures/ref/corpus/knowledge/openbao-kv-v2-version-lifecycle.md` (`diff` empty). What I compared, sentence by sentence, against the rendered page text:

| Entry statement | Page evidence | Verdict |
|---|---|---|
| `source:` §Usage (`-cas`), §Deleting and destroying data, metadata examples; Version 2.7.x; opened 2026-11-07 | Page has h2 `Usage` with `id=usage` and its `-cas` paragraph inside §Writing/Reading arbitrary data (`id=writingreading-arbitrary-data`); `id=deleting-and-destroying-data`; `id=key-metadata`; selector reads `Version 2.7.x` | accurate (one gloss, N1) |
| capture sha256 `6cfd72ec…7e02b1587`, 83532 B | `sha256sum` of the capture and `rendered-text-v1.py digest` both give `6cfd72ec…b1587`, 83532 B | accurate |
| T1 quote (19 words) and the `-cas=0` rule | Q1 `count=1`; page: "If set to 0 a write will only be allowed if the key doesn't exist" | accurate |
| T2 quote (14 words), soft delete populates `deletion_time`, undelete reverses | Q2 `count=1`; page: "It will mark the version as deleted and populate a deletion_time timestamp." and "The bao kv undelete command handles undeleting versions." | accurate |
| T3 quote (20 words) + "the same sentence continues with `bao kv destroy`" | Q3 `count=1`; continuation locates (`or when using bao kv destroy`, `count=1`); page: "When the destroy command is used the underlying version data will be removed and the key metadata will be marked as destroyed." | accurate |
| T4 "writing a third version drops version 1" | page: "Once a key has more versions than max versions the oldest versions are cleaned up" (`count=1`); page's own example (max 2, version 4) shows `oldest_version 3`, i.e. two versions cleaned up in one write | accurate for the trial's fresh-key case (see F3) |
| T5 quote (9 words); metadata delete removes every version and the key history | Q4 `count=1`; preceding sentence: "Deleting the metadata key will cause all metadata and versions for that key to be permanently removed." (`count=1`) | accurate |
| dev server's default `secret/` mount; no `cas_required`, no `delete_version_after` | page: "when running a dev-mode server, the v2 `kv` secrets engine is enabled by default at the path `secret/`"; metadata table shows `cas_required false` and `delete_version_after 0s` | accurate |
| Scope: S024 is a Vault documentation fact, not re-measured | `corpus/SOURCES.md:30` S024 is the Vault KV v2 API row (`max_versions`), never executed | accurate |

Precision notes (not page errors, no rewrite proposed):

- **N1** — the entry's `source:` gloss "§Usage — writing with `-cas`" names both words that exist as headings, but the exact path is §Usage → §Writing/Reading arbitrary data; a reader who greps a heading called "writing with `-cas`" finds none. The Gate draft above uses the exact path.
- **N2** — the entry's T3 bullet says the post-destroy `kv undelete -versions=1` "is accepted". The frozen trial discards that exit status (`... >/dev/null 2>&1` in T3), so the trial's own evidence does not carry the word. I measured it on OpenBao 2.7.2 (throwaway dev server, random port, random root token in the environment only): `destroy_rc=0`, `undelete_after_destroy_rc=0`, no stderr, then `data_is_none=1 destroyed=True deletion_time=''`. The sentence is true; the trial would need one more conjunct to prove it. Routed in §4.
- **N3** — "on the next write" in "Why it matters" mirrors the page's sentence about changing the setting ("Max versions changes will be applied on next write", 9 words); the entry does not claim the timing was measured, and T4 sets the cap before the first write, so the lowered-cap case is untested. Not an error; a coverage ceiling (§4).

---

## 4. Findings (reported, none of the frozen instruments edited)

1. **F1 — C2's lexical ceiling, already named by the plan.** `SCORECARD.md:1783` (candidate; BASE `:1778`) states the same over-read without the pattern's vocabulary; the erratum E52-1 at `SCORECARD.md:1800` records both pointers. No action for the lesson beyond the ceiling line in §2.
2. **F2 — trial T3 does not assert the post-destroy undelete's exit status** (it redirects the whole result); the entry says "accepted". Measured rc 0 on 2.7.2 (this seat). Route: add `rc=0` (and no refusal text) as a T3 conjunct in the next trial counter; the trial is frozen this round, so the entry text stays as written.
3. **F3 — T4 exercises only the minimal cleanup.** It sets `-max-versions=2` on a fresh key, so exactly one version is dropped on the third write. The page's own example sets `max_versions 2` on a key that already holds versions 1-3; the next write creates version 4 and drops versions 1 and 2 (`oldest_version 3`). So the page's "Max versions changes will be applied on next write" case (a new cap lower than the existing version count, enforced on the next write) is not exercised by T4. Route: a T6 variant in a later round.
4. **F4 — the plan's named-ceiling pointer `SCORECARD.md:1778` is BASE-accurate**; the candidate line moved to 1783 because the round-52 SCORECARD section was inserted above it. E52-1 already cites both. No action.
5. **F5 — the T5 anchor is the example's label, not the mechanic sentence.** Both locate once; a future entry could cite the 17-word mechanic sentence and keep the 9-word label as the trial's pointer. Cosmetic.
6. **F6 — quote-length bound.** The T3/T4 sentence is 26 words end to end (over the 25-word rule), which forces the 20-word truncation; the continuation is stated in prose. This is worth keeping in the Gate so a recheck does not "fix" the quote into an over-length one.

---

## 5. Receipts (exact commands, exit status, last line)

Tooling: `bao` = `/home/vgpnk/.local/bin/bao`, `OpenBao v2.7.2 (9e0a0d3c3504a0a00b45e61355afac5e35c78379)`, sha256 `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` (pin unchanged; no install/upgrade in this seat).

1. Capture digest — `python3 corpus/rendered-text-v1.py digest .ufo/waves/round-52/capture/S110.body`
   → `RENDERED_TEXT_V1: raw_sha256=6cfd72ec…b1587 bytes=83532 normalized_sha256=6bbd6c4c…31b6 normalized_bytes=15529`, rc 0.
2. Four entry quotes — `python3 corpus/rendered-text-v1.py locate .ufo/waves/round-52/capture/S110.body "<quote>"` → `RENDERED_TEXT_V1_LOCATE: count=1`, rc 0, for each of the 19-, 14-, 20-, 9-word quotes.
3. Three extra anchors — same command → `count=1`, rc 0 (the 17-word mechanic sentence, the 9-word timing sentence, the 15-word cleanup sentence); continuation `or when using bao kv destroy` → `count=1`; the backticked form `or when using \`bao kv destroy\`` → `count=0`, rc 1 (the page renders a code span; the backticked string is formatting, not text).
4. Word counts — `printf '%s' "<quote>" | wc -w` → `19`, `14`, `20`, `9`, `17`, `9`, `15`; full T3/T4 sentence → `26`.
5. Independent re-fetch — `curl -fsSL --compressed -o S110.refetch.body -w 'HTTP=%{http_code} bytes=%{size_download} url=%{url_effective}\n' https://openbao.org/docs/secrets/kv/kv-v2/` → `HTTP=200 bytes=11443`, rc 0; `sha256sum` `6cfd72ec…b1587`; `cmp -s S110.refetch.body <capture>` → `cmp_rc=0` (byte-identical). Run twice (host time 23:03 and 23:07, both 2026-11-07Z); the second run is `receipts/s110-refetch.txt`.
6. Entry-accuracy probe (throwaway `bao server -dev`, 127.0.0.1 random port, random root token only in the environment, `setpriv --pdeathsig KILL`, output discarded, values on stdin): `cas0_rc=2` with `* check-and-set parameter did not match the current version`; `destroy_rc=0`; `undelete_after_destroy_rc=0` (no stderr); `get: data_is_none=1 destroyed=True deletion_time=''`. Run twice, identical observations; receipt `receipts/entry-probe.txt`, script `receipts/probe-run.sh`. Script rc 0; its cleanup trap killed its server and removed its directory — no process of this seat's remains (the numeric-port `bao server -dev` processes seen at 23:07 belong to other seats' trials, exit on their own, and were not touched; the `127.0.0.1:0` server PID 2714164 started 22:33:13, before this seat).
7. Registry counts — `git show 1d984ada:corpus/SOURCES.md | grep -cE '^\| S[0-9]{3} '` → `109`; working tree → `110`.
8. Fixture identity — `diff <ref entry> <corpus entry>` → empty; `diff <(grep -v '^#' ref trial) <(grep -v '^#' corpus trial)` → empty.
9. Frozen controls read (not rerun) — `.ufo/waves/round-52/controls/controls-prefreeze.txt`: `CONTROL K2-0 expect=2 got=2 MATCH`, `K2-P 0/0`, `K2-F1 2/2`, `K2-F3 1/1`, `K2-F7 1/1`, last line `CONTROLS: match=20 mismatch=0`.
10. Draft self-scan (this file's two draft blocks extracted to `receipts/draft-extract.md`, scanned with the counter's own awk program at `plans/round-52-c2.sh:100-103`) → **0 assertion lines**; receipt `receipts/draft-scan.txt`, see §7.

---

## 6. Honesty, limits

- The Gate's `count=1` values and word counts are outputs of the commands in §5, run by this seat against the committed capture; the re-fetch is this seat's own HTTP 200 and byte-identity, with the declared profile.
- The trial was **not** re-run by this seat; the C1 numbers I cite are read from the frozen pre-freeze controls (K1-P `value=5`) and the plan, not from an execution here. My only OpenBao execution is the six-call probe in §5.6, which tests entry sentences, not the trial.
- `bao` was not installed, upgraded or replaced; the pin was checked before use.
- Nothing outside `.ufo/waves/round-52/build/R52ScribeEntry*` and `/fast/scratch/hyaku/kagi-r52/R52ScribeEntry/` was written. No git mutation; the only git invocations were `rev-parse`, `show`, `status`, `diff`.

---

## 7. Draft self-scan (paste safety for C2)

The frozen C2 counter counts each lane-authored md line that carries the token
`rewrap` (case-insensitive) together with one of the pattern's judgement phrases. The two draft blocks above were extracted to `receipts/draft-extract.md` (31 lines) and scanned with the counter's own awk program (`plans/round-52-c2.sh:100-103`, applied verbatim); **0 lines matched** — `receipts/draft-scan.txt` records `awk_rc=0` and prints no line numbers. One extract line carries the token: the evidence cell's `C2_REWRAP_STATEMENTS` string, which carries no judgement phrase.

Reason it matters: if this draft is pasted into `corpus/lessons/round-52.md`, that file joins the counter's scope; a verbatim restatement of the round-51 sentence would cost C2 a point that no correction line covers. The draft therefore describes the over-read structurally and never reproduces the BASE wording of the two corrected lines.
