# Renumber map — staged ids → lane ids (round-31 C2)

Frozen by the seat brief; **every mapping verified by URL against the staged source
line** (the URL is the evidence, the id follows the document — never arithmetic).

- staged source (READ-ONLY): `/home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md`
- lane registry: `/home/vgpnk/Projects/shokunin/kagi-shokunin/corpus/SOURCES.md`
- lane next free id at BASE: **S061** (lane held S001–S060)
- collision artifacts: `reg-ids` (60), `staged-ids` (172), `collisions` (9) — same dir

## Collision set (9 ids, all in the S05x–S06x band)

`S052 S053 S054 S055 S056 S057 S058 S059 S060` — staged S052–S057 collide with lane
S052–S057; staged S058–S060 (gitleaks / trufflehog / betterleaks, already adopted in
round 30 under other ids) collide with lane S058–S060. **Nonempty collisions are
expected** and are fixed in this scratch map only: no live lane id is overwritten.
`comm -12 reg-ids staged-ids` is the collision set; the renumber below re-points each
adopted staged id to a free lane id.

**Second-order collision, found and recorded here:** the staged file *also* uses
S061–S071 for a different, un-adopted theme (NIST SP 800-57 / 800-133, OIDC Core,
RFC 9700, gitleaks, trufflehog, betterleaks, GitHub search API). The lane's new
S061–S071 therefore **shadow staged S061–S071** — those staged rows are NOT adopted
in round 31 (only the OIDC Core + RFC 9700 pair is, and it arrives via staged S064/S065
→ lane S067/S068). Any future wave that adopts the staged NIST/gitleaks rows must
renumber again; the lane ids S061–S071 are taken by this round.

## Entry 1 — `corpus/knowledge/oidc-federation-trust-policy.md`

| staged | → lane | URL (evidence) | staged source line |
|---|---|---|---|
| S052 | **S061** | https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html | L7 |
| S053 | **S062** | https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html | L8 |
| S054 | **S063** | https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html | L9 |
| S055 | **S064** | https://cloud.google.com/iam/docs/best-practices-for-using-workload-identity-federation | L10 |
| S056 | **S065** | https://docs.cloud.google.com/iam/docs/workload-identity-federation?hl=ja | L11 |
| S057 | **S066** | https://help.aliyun.com/zh/ram/user-guide/create-a-ram-role-for-a-trusted-idp | L12 |
| S064 | **S067** | https://openid.net/specs/openid-connect-core-1_0.html | L19 |
| S065 | **S068** | https://www.rfc-editor.org/rfc/rfc9700.txt | L20 |

## Entry 2 — `corpus/knowledge/cdp-bridge-1password-oidc-workflow.md`

| staged | → lane | URL (evidence) | staged source line |
|---|---|---|---|
| S092 | **S069** | https://www.1password.dev/brokered-access | L47 |
| S093 | **S070** | https://www.1password.dev/brokered-access/custom-workflow | L48 |
| S095 | **S071** | https://1password.com/jp/product/credential-broker | L50 |

## In-text staged id inside entry 2

| staged (in-text) | → lane | context |
|---|---|---|
| S057 | **S066** | staged entry 2's provider/consumer comparison table cites the Alibaba row as `[round-1 S057]`; after renumbering that in-text pointer is **[S066]** (the lane's Alibaba RAM row), not a lane-local S057. |

## Lane-side used-by consequence of S066 being cited by both entries

S066 (Alibaba RAM) is cited by **both** new entries, so its `used-by` cell carries
both paths: `corpus/knowledge/oidc-federation-trust-policy.md,
corpus/knowledge/cdp-bridge-1password-oidc-workflow.md`. The census enforces the
reciprocity in both directions (`SC_USEDBY_NOCITE` / `SC_ENTRY_CITE`), and both
entries' `source:` lines do carry S066 — verified.

## Idempotence check (re-derivation, not assertion)

Re-running the collision commands reproduces the counts above:

```
reg-ids=60  staged-ids=172  collisions=9
```

and the landed lane registry now holds exactly 11 rows matching `S(06[1-9]|07[01])`,
all with `opened` = 2026-11-03 — the frozen F8 predicate commands print nothing
adverse and the lane census prints `rows=71 … captures=71`, exit 0.
