source: S083 — https://help.aliyun.com/zh/ram/user-guide/rotate-accesskey-pairs-of-ram-users — overview, 操作步骤, 后续步骤; fetched 2026-11-04; S084 — https://help.aliyun.com/zh/ram/delete-idle-accesskey-pairs-of-ram-users — 最佳实践, 治理建议; fetched 2026-11-04; S085 — https://help.aliyun.com/zh/kms/key-management-service/user-guide/manage-and-use-ram-secrets — 功能介绍, RAM凭据轮转, 步骤二, 删除RAM凭据, 检测账号; fetched 2026-11-04; S086 — https://help.aliyun.com/zh/ram/support/faq-about-accesskey-pairs — definition, creation, immutability and deletion FAQs; fetched 2026-11-04; S087 — https://www.alibabacloud.com/help/ja/ram/user-guide/rotate-accesskey-pairs-of-ram-users — introduction, 操作手順, 次のステップ; fetched 2026-11-04
verified-at: 2026-11-04
recheck: 90d — re-open all five source URLs with `curl -fsSL --compressed URL` (replace URL with each source URL above); compare the rotation, idle-key and deletion windows below before applying them
ground: RAM AccessKey credential custody — issuance, overlapping rotation, retirement and the separate KMS-managed lifecycle
Reverify: R34-03

# Custody of an AccessKey: issue, rotate, expire, delete

An AccessKey is a long-term programmatic credential comprising an ID and a
secret. The secret signs API requests; it is not a console password [S086].
This entry separates credential retirement from cryptographic key management.
The windows below are vendor guidance observed on 2026-11-04, not evidence of
any cloud account being configured or tested.

## The lifecycle, as the vendor states it

**Issue.** Save the secret securely at creation: “只在创建时显示一次，后续无法查看。请务必妥善保管。”
[S086]. Neither the secret nor the ID can be modified; a lost secret requires a
new key pair and retirement of the old one. Each RAM user can create at most two
AccessKeys [S083]. Do not confuse that RAM-user quota with the FAQ's separate
root-account quota note [S086].

**Rotate.** For an AccessKey used for more than 90 days, rotate promptly [S083].
Use the two-key overlap rather than deleting the working credential first:

1. Create the second AccessKey, ensuring quota is available.
2. Update every consuming application and system to use it. The console's last-use
   information helps judge whether the new key is used and the old key is idle.
3. Disable the original AccessKey.
4. Verify every consumer still works. If a consumer fails, temporarily re-enable
   the original key and repeat steps 2–4 until migration succeeds.
5. Delete the original key only after successful verification [S083].

The Chinese page says “建议您定期重复上述步骤，再次轮转” [S083]. The Japanese
rendering explicitly recommends repeating every 90 days or sooner [S087].

**Expire / retire idle keys.** Here, expiry is an operator-managed retirement
process, not an asserted automatic expiration timer. The vendor calls a key idle
if never used or unused for more than 90 days [S084]. Apply its branching rule:

- Never used: disable it; after 90 disabled days without related problems, delete it.
- Unused for more than 90 days: first establish whether any program or application
  still contains it. If none does, disable it and wait the same 90 problem-free
  days before deletion. If a consumer still contains it, rotate it instead [S084].

**Delete.** Deleted RAM-user AccessKeys first enter a recycle bin and can be
restored there. Retention is 30 days, after which the system permanently deletes
them; manual permanent deletion is also possible. Permanently deleted keys cannot
be restored [S086]. This documented recovery scope is RAM-user keys, not a promise
for root-account keys. Deleting a key still in use can break applications [S086].
The 90-day idle-key disable observation and the subsequent 30-day recycle-bin
retention are distinct windows, not interchangeable grace periods.

## The managed variant, where the vendor holds the clock

KMS can manage RAM-user AccessKeys, not root-account AccessKeys. The application
configures a credential name and retrieves the effective AccessKey through the
credential integration; it does not thereby cease handling AccessKey material.
KMS manages rotation and stored credential values while RAM creates the new key
and deletes the old one [S085].

Before adoption, enable a KMS instance, create a symmetric encryption key, grant
KMS the documented RAM credential-management authority, and enroll a RAM user
with an existing AccessKey and its secret. The encryption key and credential
must belong to the same KMS instance. Integrate every consumer and ensure it
periodically reads the credential before relying on automatic rotation [S085].

- Periodic rotation takes approximately two days. The configurable automatic
  interval is 7–365 days; the vendor recommends no more than three months.
- Immediate rotation has a selectable 10-minute to two-day window. For a leaked
  credential the vendor recommends 30 minutes; for other scenarios, two days.
- During rotation, do not delete the associated RAM user. Changing the periodic
  policy or starting another immediate rotation is unsupported while rotating.
- The account-detection function checks that the RAM user still exists and that
  its AccessKey ID matches the stored credential [S085].

Deletion of the KMS credential is a separate operation: **it does not delete the
RAM user's AccessKey in RAM**. Stop consumers before deleting the credential and
handle RAM-key retirement separately. The console offers immediate deletion or
scheduled deletion: “设置预删除周期（7~30 天），系统将在预删除周期结束后删除凭据。”
[S085]. A scheduled deletion can be cancelled during that pre-deletion period;
immediate deletion has no such scheduled cancellation window [S085].

## The preference underneath all of it

“推荐通过临时访问凭证（STS Token）访问阿里云” [S084]: prefer temporary STS
credentials rather than fixed AccessKeys. When fixed keys are unavoidable,
rotate them regularly. If rotation cannot be done, the vendor recommends access
allowlists through RAM policies, encryption of the ID and secret in the
application, regular usage audits and reclamation of idle keys [S084]. The FAQ
also recommends avoiding direct AccessKey use in programs and services [S086].
These are vendor recommendations, not proof that this lane has deployed them.

## One node, three languages: the evidence boundary

The fetched Chinese and Japanese rotation pages both identify document node
152682 in their page metadata [S083, S087]. They describe the same two-key limit
and five-step overlap workflow. The Japanese next-step sentence is:
“このローテーションを 90 日ごと、またはそれより早いタイミングで繰り返してください。” [S087].
The third language here is this English operational synthesis, not a separately
verified English vendor page. Shared node identity does not prove identical
wording or freshness across languages: the Chinese next-step text says to repeat
periodically, while the Japanese rendering states a 90-day-or-sooner cadence.

---

Gate: drafted for round 34 assimilation; all five source URLs re-opened 2026-11-04. Quote-to-fetch provenance and staged corrections are recorded in the round-34 build ScribeEntry report. Admission and registry census are L1 responsibilities.
