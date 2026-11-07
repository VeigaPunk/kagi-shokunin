# R56ExecLive — independent live re-fetch leg, frozen C1 claim (round 56, kagi)

Seat: R56ExecLive-2 · Date of fetches: 2026-11-07T10:38:40–42Z · Answering model: zai/glm-5.3-flashx (workstation context)
Scope: re-run each of the 10 stated `recheck:` commands of BASE `832ba6a53d6a76706b5c80bce2278683dea33d42` LIVE (public GET only) and compare live count ↔ stated N ↔ committed capture replay. Lane tree at HEAD `42070de7770e1558adcf6aa7a7bc59309a9654d7` (frozen predeclaration); `corpus/knowledge` and `corpus/rendered-text-v1.py` verified byte-identical to BASE (`git diff --stat` empty for those paths), so stated commands and stated N are the BASE ones.
Receipts: `live-refetch.tsv`, `env.txt`, `iso-default-ua.txt`, `live-fetch.sh` (+ `.sha256`), `driver-summary-raw.tsv`, raw pipe outputs `c2-locate-raw-pipe.out`, `c6-raw-pipe.out` — all in this `.d/`.

## Verdict for L1

**10/10 clocks MATCH — zero freshness drift.** Every live count equals its stated N and the committed capture's replayed count, on the day, from a non-author executor, ~14 minutes after the sibling executor's independent sample (10:24Z, receipt `../build/R56ExecLive.md`). The frozen C1 capability is live-confirmed: a stated clock that drifts would have been named here; none did. No clock flagged.

## The 10-row table

| clock | entry:line (BASE) | form | live | stated N | capture replay | HTTP | MATCH/DRIFT/UNREACHABLE | evidence |
|---|---|---|---|---|---|---|---|---|
| C1 betterleaks README | betterleaks-detection-vs-validation.md:4 | grep -c | 1 | 1 | 1 (S055) | 200 | MATCH — live body sha256 `f61c3993…` byte-identical to capture | live-refetch.tsv:C1 |
| C2 1Password custom-workflow | cdp-bridge-1password-oidc-workflow.md:3 | rendered-text locate | 1 | 1 | 1 (S070) | 200 | MATCH — `5c226c06…` byte-identical; raw pipe `count=1` | c2-locate-raw-pipe.out |
| C3 ISO 60237 | iso-11770-3-edition-status.md:3 | grep -c, browser UA | 2 | 2 | 2 (S101) | 200 | MATCH — `2e4c1524…` byte-identical | live-refetch.tsv:C3 |
| C4 ISO 82709 | iso-11770-3-edition-status.md:3 | grep -c, browser UA | 3 | 3 | 3 (S113) | 200 | MATCH — `d8dfe354…` byte-identical | live-refetch.tsv:C4 |
| C5 ISO 85929 | iso-11770-3-edition-status.md:3 | grep -c, browser UA | 2 | 2 | 2 (S114) | 200 | MATCH — `8bb88d88…` byte-identical | live-refetch.tsv:C5 |
| C6 CSRC 800-133 r3 ipd | nist-key-management-guidance-status.md:3 | grep -c | 1 | 1 | 1 (S074) | 200 | MATCH on count — live body `ee3f70d8…` ≠ capture `df32e64b…`, same 45351 B (volatile page) | live-refetch.tsv:C6 |
| C7 NIST SP 800-57p2 PDF | nist-key-management-parts-withdrawal.md:3 | pdftotext -layout \| grep -c | 1 | 1 | 1 (S078) | 200 | MATCH — `68266cb1…` byte-identical | live-refetch.tsv:C7 |
| C8 OIDC Core | oidc-federation-trust-policy.md:3 | grep -c | 1 | 1 | 1 (S067) | 200 | MATCH — `4d016752…` byte-identical | live-refetch.tsv:C8 |
| C9 TruffleHog README | secret-scanning-detection-vs-validation.md:4 | grep -c | 1 | 1 | 1 (S054) | 200 | MATCH — `7cf6efb5…` byte-identical | live-refetch.tsv:C9 |
| C10 TruffleHog verification-caching | trufflehog-verification-lifecycle.md:4 | grep -c | 1 | 1 | 1 (S057) | 200 | MATCH — `221d80fa…` byte-identical | live-refetch.tsv:C10 |

Method: each clock ran as the exact stated command piped through its filter (`grep -c '<pat>'` ≡ `grep -c -e '<pat>'` for a single BRE pattern; ISO clocks with the exact stated Chrome/124.0 UA; C2/C8 with `--max-time 30`), plus one `-o body -w '%{http_code} %{size_download}'` fetch per URL (bodies in scratch only, no headers stored, QM72), the filter re-run on the saved body, and the stated filter replayed on the committed capture bytes. Capture bytes/sha256 verified against all 10 `corpus/recheck-captures.tsv` rows: 10/10 equal. All 10 clocks HTTP 200, curl rc 0.

## Findings for L1 (no drift; two flags worth keeping)

1. **S074 (csrc.nist.gov ipd page) is byte-volatile at a fixed size.** Three independent same-day fetches give three distinct sha256 at identical 45351 B: capture `df32e64b…` (committed receipt), sibling live `a97a7cb0…` (10:24Z), mine `ee3f70d8…` (10:38Z). The clock count is 1 in all three. Implication: live-sha equality is not an achievable invariant for this URL; count equality is the meaningful currency check (which is what C1 uses). Any future re-capture of S074 must expect digest churn; attack seats should not read live-sha difference here as capture-forgery evidence.
2. **ISO default-UA 403 confirmed on all three catalogue URLs** (S101/S113/S114 → 403, identical 5448 B block page; browser-UA rows all 200, see `iso-default-ua.txt`). This fresh sample covers both the S113 URL and the S114 URL independently, closing the round-56 mistake-mining gap (round-55 spotcheck D3: the S113 row's only prior 403 receipt had been taken on the S114 URL).
3. **Self-defects recorded** (in `env.txt`): my driver's `pcount` parser printed 11 for C2 (digit concatenation of `…V1…count=1` under `tr -cd '0-9\n'`); the raw receipt shows `count=1`. My `src_rc` bookkeeping column is void (init-never-cleared); fetch success is evidenced by `-w` 200 + size + sha instead. Neither affects any verdict row.

Corroboration, not relied on: sibling R56ExecLive's same-day sample (`../build/R56ExecLive.md`) reports all 10 stated N reproduced, 9/10 byte-identical bodies, S074 sha distinct, gate CLEAN 10/10 + `--selftest` PASS 13 cases — consistent with every number in this report.
