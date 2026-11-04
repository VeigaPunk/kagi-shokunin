# ScribeEntry — round-34 BUILD report

## Behavior and scope

Axes: calibration, operability, coverage. Drafted the Alibaba Cloud RAM AccessKey custody knowledge entry from five independent documentation fetches dated 2026-11-04. No claim of lane admission, installed registry rows, cloud configuration, or full-gate success is made.

Deliverable: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/knowledge/aliyun-accesskey-credential-custody.md`.

Report: `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/ScribeEntry.md`.

Only these two persistent paths were written. Lane-tracked files and staged merge files remained read-only. The staged entry was treated as a draft, not evidence. Read the frozen contract first, then staged entry and both requested lane exemplars. Source mapping follows documents: S140→S083, S141→S084, S142→S085, S143→S086, S145→S087.

## Commands and fetch outcomes

Each command below ran exactly once using Python `subprocess.run` argument lists equivalent to the displayed shell command. Curl stdout was captured as bytes; stderr was empty on success. Exit 0 under `-f` establishes a successful fetch, not an explicitly recorded HTTP status. No extra URLs, credentials, POSTs, or vault contacts were used.

| source | exact command | exit | bytes | raw SHA-256 |
|---|---|---|---|---|
| S083 | `curl -fsSL --compressed https://help.aliyun.com/zh/ram/user-guide/rotate-accesskey-pairs-of-ram-users` | 0 | 55148 | `749e043f902d7fbd8433fb3149f1f953c3c54b426b712f42df08f1c0ccef9d41` |
| S084 | `curl -fsSL --compressed https://help.aliyun.com/zh/ram/delete-idle-accesskey-pairs-of-ram-users` | 0 | 56765 | `ca607bae31934cf80f6da0d0fdd75068e715a73b84d6d180e348c5f2a0ef5a1c` |
| S085 | `curl -fsSL --compressed https://help.aliyun.com/zh/kms/key-management-service/user-guide/manage-and-use-ram-secrets` | 0 | 145023 | `3a618155b42645f89050df5079afde39fc42ac4b9063252c2b6df7abbb4a8a93` |
| S086 | `curl -fsSL --compressed https://help.aliyun.com/zh/ram/support/faq-about-accesskey-pairs` | 0 | 123423 | `0f138d98647e64dbba54d1389315ae4b3e27ec8ae1295b7df4b9c56a31255772` |
| S087 | `curl -fsSL --compressed https://www.alibabacloud.com/help/ja/ram/user-guide/rotate-accesskey-pairs-of-ram-users` | 0 | 13371 | `0d42b535b2b4c9a0aa439255e8d71cc07be8b611652e994709169022d7c4b248` |

Scratch was `/fast/scratch/hyaku/kagi-r34/ScribeEntry/`. The fetch cell explicitly set `os.environ['TMPDIR']='/fast/scratch/hyaku/kagi-r34/ScribeEntry/tmp'`, wrote raw captures only inside this seat's scratch, and removed scratch in `finally: shutil.rmtree(scratch, ignore_errors=True)`. Captured bytes and extracted text remained in cell memory for quote location. Durable evidence is the receipts and exact excerpts in this report; raw captures were not persisted outside scratch. No tools were installed or updated.

## Every retained quotation: source, location, fetch

All quotations below were located verbatim in their own fetched HTML's visible text. Extraction used Python's standard-library HTMLParser, omitting script/style content and blank data nodes, stripping each nonblank text node and joining nodes with newlines. The line numbers are that extraction's lines, not raw HTML lines. No whitespace normalization within any retained quote was needed. Search results were `located=True` for all five. Quoted text is documentation only, with no credential values.

| source/fetch above | section | extracted line | retained quotation |
|---|---|---|---|
| S086 | 什么是 AccessKey, important creation note | 64 | 只在创建时显示一次，后续无法查看。请务必妥善保管。 |
| S083 | 后续步骤 | 108 | 建议您定期重复上述步骤，再次轮转 |
| S085 | 删除 RAM 凭据 → planned deletion | 483 | 设置预删除周期（7~30 天），系统将在预删除周期结束后删除凭据。 |
| S084 | 最佳实践 | 59 | 推荐通过临时访问凭证（STS Token）访问阿里云 |
| S087 | 次のステップ | 44 | このローテーションを 90 日ごと、またはそれより早いタイミングで繰り返してください。 |

The shared document-node claim was separately located in the same raw responses: S083 `window.globalData` contains `nodeId: "152682"`; S087 contains `nodeId:"152682"` and `<!-- docId:152682 -->`. These are documentation-node metadata, not account or credential identifiers. No English vendor page was fetched or claimed verified.

## Findings: staged claims corrected or dropped

1. **Corrected application custody.** Staged text said the application never holds an AccessKey. S085 instead says applications configure a credential name and retrieve the effective AccessKey. The entry explicitly distinguishes configuration from runtime handling.
2. **Corrected deletion scope.** S085 credential deletion does not delete the RAM AccessKey. The entry now requires separate RAM-key retirement and distinguishes immediate credential deletion from cancellable scheduled deletion (7–30 days).
3. **Restored the idle-key branch.** For keys unused more than 90 days, S084 requires checking whether applications still contain them. Rotate if present; disable then observe for 90 days before deletion if absent. Never-used keys go directly to disable/observe. The staged generalization omitted this distinction.
4. **Narrowed recovery scope.** S086's 30-day recycle bin is specifically for RAM-user AccessKeys; permanent deletion, including manual permanent deletion, is irreversible. No root-account recovery promise remains.
5. **Fixed quota provenance.** RAM-user two-key ceiling comes from S083. The FAQ's explicit two-key note names the root account and is not generalized to every account type.
6. **Corrected credential classification.** Replaced the staged bearer-credential label with a long-term programmatic credential whose secret signs requests, matching S086.
7. **Clarified expiry.** Idle status is not an automatic expiration timer. The 90-day disable observation, 30-day RAM recycle retention, and KMS 7–30-day pre-delete window are independent.
8. **Bounded language claim.** Both fetched vendor renderings identify node 152682, but only Chinese and Japanese were opened. English is this entry's synthesis, not a verified third vendor page. Shared identity does not prove identical wording; Chinese says periodic repetition while Japanese explicitly says every 90 days or sooner.
9. **Dropped unsupported campaign context.** Removed campaign round-7 framing, the unrelated staged S057 cross-reference, campaign IDs, old fetch dates and unneeded last-modified claims. The entry cites only S083–S087.
10. **Replaced rather than silently repaired staged quotations.** Kept only the five verbatim excerpts listed above. Other staged quotations were converted to independently grounded English paraphrases or removed; no unlocated quotation remains.

Retained and made actionable: issuance secrecy, five-step overlap/rollback, >90-day rotation trigger, idle retirement branching, RAM-user recovery window, KMS enrollment prerequisites, 7–365-day auto interval with ≤3-month recommendation, approximately two-day periodic rotation, immediate rotation 10 minutes–2 days with 30-minute leakage recommendation, account consistency check, and preference for STS.

## Gates actually exercised

The only deliverable counting command was:

```sh
wc -w /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/knowledge/aliyun-accesskey-credential-custody.md && grep -c '^source:' /home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/knowledge/aliyun-accesskey-credential-custody.md
```

Exit 0; output: **991 words**, **5 source lines**. This is the POSIX `wc -w` count including metadata, headings and quoted non-English strings; it is not a linguistic tokenizer count. The five quote-location checks were source-evidence measurements, not a full gate suite. The front matter contains five `source:` lines, `verified-at: 2026-11-04`, bounded `recheck: 90d` with the runnable curl invocation and explicit URL substitution, one `ground:` line, then `Reverify: R34-01` in the lane exemplar's metadata position.

No census, lint, formatting, build, full suite, frozen counter, git mutation, cloud operation, validator, or runtime deployment was run. L1 owns installation and final source census; this report does not count contract-only seats as executed C1/C2/C3 evidence.

## Known limits and contract conflict

Raw bodies were intentionally removed with scratch; this report preserves exact quotes, locators, hashes, sizes and successful curl outcomes, not replayable raw HTML files. One fetch per URL establishes this observation only, not byte reproducibility. Recheck commands are future instructions and were not re-executed after drafting. Vendor documentation, not service behavior, was measured.

Conflict recorded verbatim for the canonical judge: assignment says **"kagi round-34 BUILD wave (one v1 wave, 13 seats)"**; frozen plan says **"One v1 wave `kagi-r34-build` under ... (band 8–16, L2 floor 8), 14 seats"**. No seat count, predicate, counter, exclusion, or kill rule was changed here.

## Self-evaluation

Accuracy 4/5: all five retained quotes located in independent fetches; raw bodies are not retained, limiting replay. Completeness 4/5: all requested lifecycle subjects covered; full admission is deliberately left to L1. Clarity 4/5: explicit separation of three deletion windows, but metadata is lengthy. Actionability 4/5: numbered migration/rollback and exact windows; account execution is untested and out of scope. Conciseness 4/5: 991-word standalone entry includes explicit evidence boundaries that could be shortened only at a calibration cost. Overall 4.0/5. Highest-value improvements are preserving the integrator's own captures and running the final census after installation, both outside this seat's write/run scope. Would the user agree: the draft supplies the requested coverage without overstating admission or vendor execution.
