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
