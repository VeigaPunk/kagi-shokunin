# R51ScribeEntry — landing drafts for round 51 (knowledge entry, S108 rows, lesson Gate/Mistakes)

Seat: scribe (leaf; no subagent dispatch). Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin`, branch `master`.
BASE `214d8bf530a0c87c00686493f21af15396284793`; predeclaration `4ad8ab7cd5bf8949d125ac96ccef45e69dabc567`.
Read-only outside my build dir: no `corpus/`, `plans/`, `SCORECARD.md`, registry row or fixture was written by this seat.

## Artifacts (all under `.ufo/waves/round-51/build/R51ScribeEntry/`)

| file | what it is |
|---|---|
| `entry-section.md` | improved `## Measured (round 51 …)` section for `corpus/knowledge/vault-openbao-token-lease-lifecycle.md` |
| `sources-row.md` | S108 registry row draft (11 columns) + the checks run on it |
| `source-fetches-row.tsv` | S108 fetch row, 16 tab-separated fields, append-ready |
| `source-fetches-row.md` | per-column derivation, incl. the computed `row_identity_sha256` and normalized digest |
| `lesson-round-51.md` | `## Gate` (S108 admit, 2 rejects) and `## Mistakes` row M51-1 |
| `receipts/s108-refetch.txt` | live re-fetch of S108 with the declared profile: HTTP 200, byte-identical to the capture |
| `receipts/quote-locations.txt` | nine `rendered-text-v1.py locate` runs (all `count=1`) + the counter's `entry_line` matcher over the draft + a BASE negative control |
| `receipts/section-attribution.txt` | normalized char offsets: each quote mapped to its page section |
| `receipts/base-claims-declared.txt` | `claims-declared.sh` over a `git archive` of BASE: the two `MISMATCH 50 …` lines |
| `receipts/m51-1-fix.txt` | BASE evidence + the fix reading CLEAN and the same fix made to fail again |
| `receipts/census-candidate.txt` | `sources-census.sh validate` over the candidate working tree |
| `receipts/reject-candidates.txt` | the two Gate reject candidates, fetched and digested |

## State of the candidate when this seat ran

The working tree already held the round-51 candidate (files modified 2026-11-06T21:31:56 -03, after this seat started): untracked `corpus/openbao-wrap-trial.sh`, modified `corpus/SOURCES.md`, `corpus/source-fetches.tsv`, `corpus/claims-declared.tsv`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`. Everything below reviews **that** candidate; every BASE measurement used `git archive 214d8bf5 | tar -x` into scratch, not the working tree.

## 1. Entry section

`entry-section.md` keeps the five `- T<n> ` lines — each still starts exactly `- T1 `…`- T5 ` and still names `OpenBao 2.7.2` — and is verified against the counter's own matcher (`plans/round-51-c1.sh:134-143`, run verbatim over the draft: `entry_line=1` for T1–T5; the same awk over the BASE entry returns `0`). What it changes against the reference fixture and the candidate section:

- **Per-test source anchoring was missing.** Each `- T<n> ` line now ends "measures S108 §<section>, '<located quote>'"; nine quotes, every one `count=1` (`receipts/quote-locations.txt`). The fixture named the page but no sentence of it.
- **No output contract.** The draft states the `TRIAL T<n> HOLDS|BROKEN|ERROR <detail>` line, the `OPENBAO_WRAP_TRIAL: … holds=<n> broken=<n> error=<n> bao=<version>` summary and exit codes 0/1/2 — the grammar K1 reads (`grep -q '^OPENBAO_WRAP_TRIAL: '`, `none_rc=2`).
- **No HOLDS-threshold sentence.** The draft says a test HOLDS only when its designated client-side falsifier flips it (SH1–SH5), which is what the counter requires of every counted test.
- **T5 over-claimed detection.** The fixture said "so a client that checks the exact path detects the re-wrap"; the page also warns that a `secret/` prefix check is not enough. The draft states both halves, with the two located quotes.
- **T1's refusal text was unattributed.** `wrapping token is not valid or does not exist` is **not** page text and the trial does not print it (its `unwrapv` swallows stderr); it is the pinned binary's own message (`strings -a ~/.local/bin/bao | grep -c 'wrapping token is not valid or does not exist'` → `1`). The draft says "the server's `…`" so no reader takes it for a citation.
- **No "Does not establish"** in either the fixture or the candidate. The draft adds one with the four required limits — client-side shims, one version (2.7.2 only, pin `9c5f3628…b788`), KV v2 only (and no `X-Vault-Wrap-TTL`, no Go API `SetWrappingLookupFunc`, no `cubbyhole` enumeration), no audit-log reading and no policy TTL bound (both quoted as limits, `count=1` each) — plus dev-mode scope.
- **No re-run line.** Added.

The draft claims **no observed run**. The `OPENBAO_WRAP_TRIAL: HOLDS holds=5 …` line belongs to R51ExecTrial's receipt: the L1 must paste that seat's last line and its rc into the section (round-49's section carries exactly such a sentence) — this seat did not run the trial and says nothing about its verdict.

## 2. Registry row and fetch row

- Registry row: 11 cells, `NF=13` between 12 pipes, no `|` inside a cell; `kind docs`, `tier A`, `status mined`, `recheck 180d` (no release feed bound → `on-release` would trip R36-03, the M50-4 harm), `used-by` = the knowledge entry + `corpus/lessons/round-51.md`.
- `row_identity_sha256` **computed**, not copied: `printf 'S108\tmined\thttps://openbao.org/docs/concepts/response-wrapping/\n' | sha256sum` → `b7ed6ba7eed103207e3745a3b954a847b69476276bab94f3d3f05f84aede270f` (equals the candidate row's field 3).
- `normalized_sha256` **computed**: `python3 corpus/rendered-text-v1.py digest .ufo/waves/round-51/capture/S108.body` → `normalized_sha256=133496495ea72d2ac1fa7e1a8f04661beb2aa0df5e6b16e917f9e93432f4868a normalized_bytes=10424`, raw `a555301e…f9cc32ed55`, 37186 B (equals the candidate row's fields 10 and 15).
- Quote 13 ASCII words (`printf '%s' "$q" | wc -w`), located `count=1`.

## 3. Findings on the candidate (for the L1)

- **F1 — the candidate's §Does not establish was absent** and its T-lines carried no located support. Fixed by `entry-section.md` (see §1). Not a gate failure: K1 checks only the `- T<n> ` prefix plus `OpenBao 2.7.2`, so the candidate would have scored; this is a teaching/calibration defect, not a red.
- **F2 — the fetch row's `location` names the wrong section.** Candidate field 16: `§Response-Wrapping tokens overview (malfeasance detection paragraph)`. The quote sits at normalized char 2805; `§Overview` starts at 914 and `§Response-Wrapping tokens` at 3360 — so it is in **§Overview** (malfeasance bullet), not in §Response-Wrapping tokens (`receipts/section-attribution.txt`). My draft corrects the cell. No gate reads the meaning (SC_FETCH only requires `length >= 8`), so this is a human-reader correctness fix.
- **F3 — representation class differs from every other row for this site.** S014, S015, S016, S021, S025, S026 and S105 all declare `decoded-http-body-volatile-v1`; the candidate S108 row declares the stronger `decoded-http-body-v1`. The only stability evidence is a re-fetch **10 minutes** after the capture (byte-identical, same deployment), which cannot support the non-volatile class for Docusaurus HTML (content-hashed chunks). My draft uses `volatile`; both classes are inside the SC_FETCH enum, so neither choice turns a gate red.
- **F4 — the census will stay red until the lesson lands.** `sources-census.sh validate` over the candidate tree returns exactly one finding: `kagi E11 S108 missing used-by corpus/lessons/round-51.md`, rc 1 (all `W04` duplicate-URL warnings filtered; receipt `receipts/census-candidate.txt`). That is expected pre-landing and is discharged by the lesson's `## Gate` carrying `S108` — the Gate draft does.
- **F5 — the S108 capture reproduces.** Re-fetch at 2026-11-07T00:33Z with the declared profile: HTTP 200, `curl -w '%{url_effective}'` = the same URL (no redirect), body **byte-identical**, `cmp=identical`, same raw digest and byte count. The capture is committed at `.ufo/waves/round-51/capture/S108.body` (37186 B) and is a faith-ful point attestation of the page as served this round.

## 4. Lesson drafts

- `## Gate`: S108 admitted (tier A, `mined`, `recheck 180d`, used-by both surfaces) with nine located quotes and the page's version evidence (`docs-version-2.7.x`, 1 occurrence; edit link to `release/2.7.x`). Two reject candidates, each fetched, digested and reasoned: the OpenBao `/sys/wrapping/unwrap` API reference (endpoint reference; its one behavioural sentence — "this will cause the wrapping token to be revoked but the value to be unable to be looked up", `count=1`, 19 words — restates single use as a client double-use caveat the trial does not exercise) and the HashiCorp Vault response-wrapping page (product boundary: no Vault binary is run). Both carry an explicit flip. Rows added 1, touched 0, registry 107 → 108. Counting rule E49-1 stated.
- `## Mistakes` M51-1 (`manifest-omission`): evidence, `captured-by: none` (`grep -c 'claims-declared' corpus/claim-ledger.tsv` → `0`; a SKILL.md gate-registry line exists at `SKILL.md:826`, but the gate has no ledger row, so `claim-ledger.sh verify` never runs it), and the fix **shown able to fail** from both sides.

## 5. Exact commands and outcomes (receipts)

| # | command | rc | last line |
|---|---|---|---|
| 1 | `bash corpus/claims-declared.sh --root <git archive of 214d8bf5>` | 1 | `CLAIMS_DECLARED: MISMATCH (claims=25 mismatch=2)` — preceded by `MISMATCH 50 C1 no-manifest-row`, `MISMATCH 50 C2 no-manifest-row` |
| 2 | same, after appending `50 C1 operability` + `50 C2 calibration` | 0 | `CLAIMS_DECLARED: CLEAN (claims=27)` |
| 3 | same, after deleting `50 C2 calibration` again | 1 | `CLAIMS_DECLARED: MISMATCH (claims=26 mismatch=1)` — preceded by `MISMATCH 50 C2 no-manifest-row` |
| 4 | `git show 214d8bf5:corpus/claims-declared.tsv \| grep -c '^50'` | 1 | `0` |
| 5 | `git show 214d8bf5:SCORECARD.md \| grep -c '^## Round 50 — post-move'` | 0 | `1` |
| 6 | `git show 214d8bf5:plans/round-50.md \| grep -cE '^## C[0-9]+ — (operability\|calibration):'` | 0 | `2` |
| 7 | `curl -fsSL --compressed -A '<declared UA>' https://openbao.org/docs/concepts/response-wrapping/` | 0 | body sha256 `a555301e…f9cc32ed55`, 37186 B, `cmp=identical` to the capture |
| 8 | `python3 corpus/rendered-text-v1.py digest .ufo/waves/round-51/capture/S108.body` | 0 | `RENDERED_TEXT_V1: raw_sha256=a555301e… bytes=37186 normalized_sha256=13349649… normalized_bytes=10424` |
| 9 | `printf 'S108\tmined\t<url>\n' \| sha256sum` | 0 | `b7ed6ba7…aede270f` |
| 10 | nine × `python3 corpus/rendered-text-v1.py locate capture/S108.body "<quote>"` | 0 | `RENDERED_TEXT_V1_LOCATE: count=1` (all nine) |
| 11 | counter matcher `awk` (verbatim from `plans/round-51-c1.sh`) over `entry-section.md` | 0 | `T1..T5 entry_line=1`; BASE entry → `T1 entry_line=0` |
| 12 | `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` | 1 | `kagi E11 S108 missing used-by corpus/lessons/round-51.md` (only non-`W04` finding) |
| 13 | `strings -a ~/.local/bin/bao \| grep -c 'wrapping token is not valid or does not exist'` | 0 | `1` |
| 14 | `sha256sum ~/.local/bin/bao` / `bao version` | 0 | `9c5f36287c673f386e1533e9c044169a248e4ee50dd54810fa766e95bd41b788` / `OpenBao v2.7.2 (9e0a0d3c…), committed 2026-10-26T20:32:27Z` |

## 6. Not done, by design

- **The trial was not run by this seat** (R51ExecTrial's item), so no `OPENBAO_WRAP_TRIAL:` line is quoted anywhere in my drafts and no dev server was started here.
- **No `claim-ledger.sh verify`** (not named by this item; 300 s+ host-heavy).
- No `corpus/`, `plans/`, `SCORECARD.md`, registry or fixture file was edited; no git mutation was run. The only writes are `build/R51ScribeEntry*` and scratch under `/fast/scratch/hyaku/kagi-r51/R51ScribeEntry/` (each bash call removed it with `trap … EXIT`).
- No token, wrapping token, nonce value or key material was read, printed or written; no `op`, 1Password, vault or account was contacted; the only network traffic was four GETs of public documentation pages.

## 7. Known limits of these drafts

- The nine located quotes are located against the committed capture; the capture itself is trusted as the round's page snapshot (it re-fetches byte-identically today, which is same-deployment evidence, not a drift pin).
- M51-1's `captured-by: none` is a statement about `corpus/claim-ledger.tsv` and the counters at BASE; a future ledger row for the gate would change it.
- The Gate's reject verdicts are judgements about teaching value and product boundary; a reviewer with a different boundary could admit the `/sys/wrapping/unwrap` page.

## 8. Working-tree changes made by peers while this seat ran

`SCORECARD.md` became modified and `.ufo/waves/round-51/build.ready.dispatched` appeared after this seat started (peers' writes, not mine); the five `corpus/` paths above were already modified when I first read them at 21:31 -03. My write-scope check (`git status --porcelain | grep -v '^.ufo/waves/round-51/build'`) shows nothing of mine outside `build/R51ScribeEntry*`.

