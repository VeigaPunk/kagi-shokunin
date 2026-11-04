# ScoutSources — Round 34 source reopening

Axes: calibration, operability, coverage. All five permitted URLs opened successfully on 2026-11-04 UTC with the prescribed curl command; every final URL equals its requested URL, with HTTP 200. No credentials or additional URLs were used. No tools installed or upgraded. No lane gates, suites, lint, or build commands run.

## Deliverables

- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/accesskey-captures.tsv`: five data lines, no header; columns: staged_id, lane_id, url, final_url, http_status, fetched, bytes, sha256, quote, location, verdict, note.
- `/home/vgpnk/Projects/shokunin/kagi-shokunin/.ufo/waves/round-34/build/src-open/S140.html`, `S141.html`, `S142.html`, `S143.html`, `S145.html`: unmodified decompressed response bodies; each below 200,000 bytes. SHA-256 receipts were also computed with sha256sum (receipt clock 2026-11-04T14:17:42Z).

## Observed source evidence

### S140 → S083 — agree

- URL and final URL: https://help.aliyun.com/zh/ram/user-guide/rotate-accesskey-pairs-of-ram-users
- Fetch: 2026-11-04 UTC; HTTP 200; 55148 bytes.
- SHA-256: `db5528d6cfff1abe44edb27ea67f687e7321d48a76293bb92dcce304e594244d`.
- Anchor: 概述 (shortdesc); 操作步骤; 后续步骤.
- Located verbatim quote: 「每个RAM用户最多可以创建两个访问密钥」.
- Staged teaches: A RAM user may hold at most two AccessKeys; rotation is create the second key, repoint every consumer, disable the old key, verify, then delete it — and Alibaba advises rotating any key used for more than 90 days
- Comparison: Two-key ceiling, create/update all consumers/disable/verify/delete, and >90-day advisory all present.

### S141 → S084 — differs

- URL and final URL: https://help.aliyun.com/zh/ram/delete-idle-accesskey-pairs-of-ram-users
- Fetch: 2026-11-04 UTC; HTTP 200; 56765 bytes.
- SHA-256: `7a71dda8b20294bbe9a907a0e0a89b587154185d1704bab0fedefe9fdea3440b`.
- Anchor: 治理建议 / 针对超过90天未使用的RAM用户AccessKey / 如果确认存在.
- Located verbatim quote: 「则该AccessKey仍旧有被调用的可能，建议轮转AccessKey。」.
- Staged teaches: An AccessKey counts as idle if it was never used or has not been used for over 90 days; the prescribed governance is to disable it first and delete it only if nothing broke during the following 90 days, and Alibaba's stated first preference is STS temporary credentials over fixed AccessKeys
- Comparison: Staged summary is overbroad: keys unused >90 days but still present in an application should be rotated; disable then observe 90 days applies never-used or confirmed-absent keys. STS preference and idle definition agree.

### S142 → S085 — agree

- URL and final URL: https://help.aliyun.com/zh/kms/key-management-service/user-guide/manage-and-use-ram-secrets
- Fetch: 2026-11-04 UTC; HTTP 200; 145023 bytes.
- SHA-256: `b6401b345f616de183dde27fd966bb04fe4d8adb254aa8a7e396b4d9582c3668`.
- Anchor: 删除RAM凭据 / 计划删除凭据; RAM凭据轮转; 步骤二 / 自动轮转.
- Located verbatim quote: 「预删除周期（7~30 天）」.
- Staged teaches: KMS rotates a managed RAM credential by creating a new AccessKey and deleting the old one; a periodic rotation takes about two days, an immediate rotation is settable from 10 minutes to 2 days (30 minutes on a leak), the automatic period is 7 to 365 days, and a scheduled deletion has a 7-to-30-day pre-delete window during which the deletion can be cancelled
- Comparison: All stated windows present: periodic ~2 days; immediate 10 minutes–2 days, leak advice 30 minutes; automatic 7–365 days; cancellable pre-delete 7–30 days. Deleting the KMS secret does not delete the RAM AccessKey.

### S143 → S086 — agree

- URL and final URL: https://help.aliyun.com/zh/ram/support/faq-about-accesskey-pairs
- Fetch: 2026-11-04 UTC; HTTP 200; 123423 bytes.
- SHA-256: `292da4a9b19f33953e9a83d2cc3b3694143849d74f66c66007dee8e7ad41b3b4`.
- Anchor: 创建AccessKey后，能否修改AccessKey ID？; 什么是AccessKey; AccessKey删除后能否恢复？.
- Located verbatim quote: 「AccessKey ID不能修改。」.
- Staged teaches: The AccessKey Secret is shown once at creation and can never be viewed or modified again; the AccessKey ID cannot be modified — only disabled, enabled or deleted; a deleted AccessKey is moved to a recycle bin from which it can be restored for 30 days, after which it is permanently deleted
- Comparison: One-time immutable Secret, immutable ID, verbs, and 30-day recovery agree in RAM-user scope. Recycle-bin recovery must not be generalized to root-account keys; manual permanent deletion may occur sooner.

### S145 → S087 — agree

- URL and final URL: https://www.alibabacloud.com/help/ja/ram/user-guide/rotate-accesskey-pairs-of-ram-users
- Fetch: 2026-11-04 UTC; HTTP 200; 13371 bytes.
- SHA-256: `ea83e0c18efbbce7ca32281490190a710e1019c80f2fbef228646fbe6ed6a61e`.
- Anchor: 次のステップ; 操作手順; nodeId 152682.
- Located verbatim quote: 「このローテーションを 90 日ごと」.
- Staged teaches: The Japanese rendering of the rotation guide carries the same two-key ceiling, the same five steps and the same 90-day cadence as the Chinese one, because both are renderings of documentation node 152682 rather than separate documents
- Comparison: Two-key ceiling, five steps, and 90-day-or-sooner repeat agree; both HTML bodies identify nodeId 152682. Japanese says repeat every 90 days; Chinese shortdesc advises rotation after >90 days and closing paragraph says periodically.

## Calibration finding and scope

S141 is marked differs because its staged teaches sentence omits a decision branch, not because the idle threshold or observation period changed. Under 治理建议, the current page says to confirm whether a >90-day-unused AccessKey remains in a program/application. The confirmed-absent branch permits disabling and deletion after 90 uneventful days; the confirmed-present branch recommends rotation. The adopted guidance should preserve that branch. This comparison does not establish when the omission arose.

S143 recovery is specifically for RAM-user AccessKeys, and the page additionally permits manual permanent deletion before 30 days. S142 secret deletion is distinct from RAM AccessKey revocation. These limits should survive admission.

Confidence: high for the fetched-document claims and hashes. Remaining unknowns: none of the five URLs failed to open; no inference about actual tenant behavior or live account state was tested. No exported code contract was investigated, so semantic LSP tracing was not applicable.

Only the seat-owned capture/report/body deliverables were written; raw-body interpretation used the local saved HTML, without secondary network requests. Scratch cleanup follows copying these deliverables.
