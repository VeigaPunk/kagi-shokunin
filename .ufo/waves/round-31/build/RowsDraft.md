# RowsDraft — round-31 BUILD wave: registry append block + renumber map + independent verification

Seat: RowsDraft (leaf member; no subagent dispatch). Lane: kagi-shokunin. BASE 655e6206…,
plan 4767b045… ("round-31: plan + START census + BASE controls"). Deliverable per brief:
registry-append.md + renumber-map.md + collision artifacts + this report (mirrored to
`.ufo/waves/round-31/build/RowsDraft.md` per the milestone trailer).

## Behavior

- Read first: `plans/round-31.md` (frozen claims contract, corrections F1–F10), fleet
  `CORPUS.md` §SOURCES.md, `corpus/sources-census.sh`, `corpus/QUALITY.md`,
  `corpus/SOURCES.md` (landed), staged append + staged entries (READ-ONLY source lane).
- Collision check run exactly as specified → artifacts `reg-ids`, `staged-ids`,
  `collisions` under `build/assimilation/`.
- Renumber map written, **every mapping verified by URL against the staged source line**.
- Registry append block drafted: 11 rows, fleet schema, NF=13, no literal/escaped `|`
  in any cell, no credential material, JP quote with location on the JP row.
- Independent verification of the already-landed state: my own 11 in-round fetches
  (census profile, 2026-11-03) were compared against every committed artifact.

## Gates (outputs pasted)

Lane census, run in the lane repo:

```
SOURCES_CENSUS: CLEAN (rows=71 A=68 B=1 C=2 queued=1 mined=67 rejected=3 entries_sourced=10 legacy=21 captures=71 inrow=16 inrow_only=0 inrow_nonreproducing=12)  exit 0
```

— matches the frozen predicate (rows=71, entries_sourced=10, legacy=21, captures=71;
S061–S071 = 11; all opened 2026-11-03 — the frozen F8 awk prints nothing adverse).

Fleet census `validate --root /home/vgpnk/Projects/shokunin kagi`: **exit 0**, W04
count **16** (START receipt recorded 14; the +2 are the new S069/S070 rows sharing
`www.1password.dev/brokered-access` with S007/S019/S032 and
`…/custom-workflow` with S018 — cross-scope duplicates only, no E04, scopes differ so
no `supersedes` needed). Warnings do not affect clean lanes; recorded as a delta, not a
defect.

Clone tests (scratch copy only, lane untouched): S071 at tier **B** → lane CLEAN
(A=67 B=2 C=2) + fleet exit 0 with **no** new warning; S071 at tier **C** → fleet emits
`W01 S071 tierC mined used-by=corpus/knowledge/cdp-bridge-1password-oidc-workflow.md`
(exit still 0, but a new warning class, and it breaks F9's narrowed clause
"every ADOPTED row is tier A or B").

## Collision counts (pasted)

```
reg-ids: 60   staged-ids: 172   collisions: 9
collisions: S052 S053 S054 S055 S056 S057 S058 S059 S060
```

The brief expected "staged S052–S057 collide with lane S052–S057"; the measured set is
**S052–S060 (9 ids)** — lane S058–S060 (round-30 rows) also collide with staged
S058–S060. Renumber map resolves all; no live lane id overwritten.

## Staged cells rewritten, and why

1. **S063 (staged S054) anchor + scope**: staged said the row covers "the request-time
   `Audience` and `ProviderId` parameters" with anchor "§Request Parameters, entry
   `Audience`". Verified against the 2026-11-03 page: the request-parameter dt list is
   DurationSeconds, MinimumSessionTokenSize, Policy, PolicyArns.member.N, ProviderId,
   RoleArn, RoleSessionName, WebIdentityToken — **no `Audience`**; `Audience` is a
   Response element. Rewritten (matches the landed row and the entry's corrected table
   row).
2. **S066 (staged S057) anchor**: staged "§信任策略 → 限制条件表 … (是否必填 = 是)".
   Verified: the page has no 信任策略 heading (0 hits) and the column header is
   是否必选 (2 hits), not 是否必填 (0). Rewritten to the literal section chain and
   column; the mandatory flags 是/是/否 and the 10-subject cap verified as stated.
3. **S067 (staged S064) anchor**: staged "§3.1.3.6 "ID Token", claim list entry `aud`
   (REQUIRED) at page lines 923-933". Verified: the `aud` REQUIRED claim-list entry is
   in **§2 "ID Token"**; §3.1.3.6 contains zero `aud` occurrences. Rewritten to §2
   (see F-1 — the *landed* row kept §3.1.3.6).
4. **S068 (staged S065) anchor**: "RFC 9700, BCP 240" → the RFC header reads
   "SPRIND BCP: 240"; "BCP 240" as a literal string occurs 0 times. Rewritten.
5. **S069/S070 (staged S092/S093) scope**: staged scope overlapped lane S007
   (claim matching), S019 (eligibility), S032 (integration-key quote), S018 (feature
   status/beta/SDK). Narrowed to the configuration/runtime mechanics those rows do not
   hold, naming the already-held aspects (matches landed).
6. **S071 (staged S095) tier and scope**: staged tier A with "flip to C if the ja path
   lags the en path". Rewritten per F9 (see F-3/F-4 below).

## Findings

**F-1 (material, anchor locator): S067's registry anchor — and entry 1's `source:`
line — cite §3.1.3.6 for the `aud` (REQUIRED) claim-list entry; that entry lives in
§2 "ID Token".** Measured on the re-opened page: the text `aud REQUIRED` sits at raw
offset 51659, between heading "2. ID Token" (offset 49984) and "3. Authentication"
(offset 62025); the §3.1.3.6 body block contains **zero** occurrences of `aud` — it
says "The contents of the ID Token are as described in Section 2 (ID Token)" and adds
per-flow claims (at_hash ×2). The committed capture row for S067 says
"§2 ID Token, aud claim paragraph (aud REQUIRED)" — correct. So the registry row and
the capture row contradict each other, and the registry anchor (plus E1's source line)
names a section that does not contain the claim it anchors. **Verbatim conflict to
record:** AttackOidc F-C flips the staged defect as "correct the locator (or use the
stable §3.1.3.6 anchor alone)" — my measurement is that the §3.1.3.6 anchor does not
contain the claim-list entry; the locator must be §2. The landed row's own note ("the
staged line-locator (923-933) was wrong at staging, corrected in-round") corrected the
line numbers but kept the wrong section.

**F-2 (material, capture location): the S063 capture row's location cell names the
wrong section.** Committed capture row S063 field 16 =
`Request Parameters, Audience parameter description (line 347)`. Verified: raw line 347
(offset 33061) lies under the h2 "Response Elements" (offset 31876); the
"Request Parameters" section (offset 19882) carries no `Audience` at all. The registry
row's anchor correctly says "Response Elements … the staged request-parameter anchor
does not exist on the re-opened page, recorded". So the *capture* file still carries
the staged defect's section label for a quote that lives in Response Elements — the
exact error F-A corrected, surviving in the provenance artifact a verifier re-runs.
The census cannot see it (SC_FETCH checks location length ≥ 8 only). Secondary note in
the same row: the registry anchor's parenthetical "the page's only `Audience`
occurrences" is overstated — the rendered text carries 3 case-sensitive `Audience`
occurrences (1 element description + 2 inside the Examples response XML,
`<Audience>client.5498841531868486423.1548@apps.example.com</Audience>`); the
load-bearing part (no `Audience` in the request-parameter list) is verified true, and
AttackOidc F-A records the same two-site count.

**F-3 (material, false absence claim in the registry row and the entry body): S071's
scope cell and entry 2's body both assert the JP page "carries no release status at all
(0 status hits)".** Verified against the re-opened body: the rendered text carries
一般提供 ×2 and プレビュー ×1, and the FAQ explicitly answers
「1Password Credential Brokerは一般提供されていますか？」 with 「まだ一般提供されていません。Credential
Brokerは現在、すべてのEnterprise Password Managerのお客様向けにプレビュー版が公開されています。これにはGitHub
ActionとカスタムOIDC構成が含まれています。」 — the JP page **does** carry a release-status
statement: preview for all Enterprise Password Manager customers, covering both GitHub
Actions and custom OIDC configurations. The executor's sweep needles were
パブリックプレビュー / public preview / ベータ (receipt: "0/0/0 hits") — none can match
プレビュー版 or 一般提供されていません. That is the lane's own QM10/QA6 failure mode: an
absence claim whose needle cannot match the corpus it claims to have swept. The
conclusion ("nothing in this entry rests on it for status") survives — but the stated
reason is false, and the *correct* reason is stronger and more useful: the JP page's
status label is a **guide-level uniform preview covering both feature paths**, i.e.
exactly the uniform-preview reading round-22 rejected (S020 distinguishes Actions
public preview from custom-OIDC beta), so no per-feature status claim may rest on it
and the lane's S017/S018/S020 rows hold the split. Fix: restate the scope cell and the
entry bullet to record the page's guide-level uniform preview label and its exclusion,
not an absence. (My registry-append.md row already carries the corrected scope.)

**F-4 (tier decision for the L1): S071 landed tier A; my recommendation is tier B with
the reason recorded.** Plan F9 authorizes it ("the staged JP product page row … may
land tier B or C with the reason recorded") and narrows the predicate to "every ADOPTED
row is tier A or B with the tier justified in the row; each entry keeps ≥1 tier-A
support"; my brief's own test is "tier A only if it is the primary source for a claim
the entry makes, else B with the reason". Measured: entry 2 contains **zero** in-text
`[S071]` citations — the row is on the `source:` line only, and the entry's only
S071-bearing sentence is the negative bullet above. So the JP page is the primary
source for no claim the entry makes. Supporting evidence: the EN twin of the same
product page, S005 (1password.com/product/credential-broker), sits at **tier C** in
this same registry ("This is a lead, not mechanism authority", queued, used-by "—"),
and the JP page's own scope says "content duplicates the en path" — so tier A for the
Japanese rendering of a claim the lane grades C in English is locale-dependent tier
inflation. Counter-argument recorded for the L1: the JP page is the vendor's own native
Japanese page (`lang="ja"`, no machine-translation marker), so a tier A narrowed to the
Japanese wording is arguable under a ja-rendering precedent. Both censuses verified
green at tier B on a scratch clone (lane CLEAN, A=67 B=2 C=2, exit 0; fleet validate
exit 0, no new W01 — tier C would have added one). The tier-A/B support check passes
either way (entry 2 keeps S069/S070 at tier A).

**F-5 (minor, locator labels not verbatim on the page):**
- S066 registry anchor + capture location + entry 2 source line use
  服务级限制条件表 / 限制条件表 — **0 occurrences**; the page's literal strings are
  支持的服务级限制条件 (1 hit, lead-in "支持的服务级限制条件如下表所示") and the table
  header row 限制条件关键字 / 说明 / 是否必选 / 示例 (是否必选 ×2 — the staged
  是否必填 is correctly noted absent, 0 hits; 信任策略 correctly noted absent, 0 hits).
- S068 anchor "RFC 9700, BCP 240, January 2025" — "BCP 240" as a literal string is
  0 hits; the RFC header reads "SPRIND BCP: 240" (colon form). My block says
  "SPRIND BCP: 240".
- S064 anchor claims the three bullets "appear twice on the page — heading list and
  body list"; measured: bullets 1 and 2 appear twice each, bullet 3
  ("…as audience") appears once in that wording, with the heading variant
  "…as the audience" (×1). My block states the counts per bullet.

**F-6 (S065 scope premise + flip condition, moderate): S065's tier-A scope asserts
"content duplicates the en path … flip to C if the ja path lags the en path", but the
en twin of that document was never opened in-round.** Measured: no capture row and no
body exist for `cloud.google.com/iam/docs/workload-identity-federation` (the en path of
the ja URL); the wave's only en fetch (AttackOidc p7) is the *best-practices* page — a
different document (canonical `best-practices-for-using-workload-identity-federation`),
and no lane row holds the en WIF twin. So the duplication premise is inherited from the
staged scope and unevaluated in-round, and the lag flip condition has no baseline to
fire against. What is verified on the ja page itself: 属性条件 (h3), 属性マッピング with
the sample `google.subject=assertion.sub`, CEL ×3 — so the *terminology* scope is
grounded on the ja page alone, which keeps tier A defensible for the Japanese
terminology. Two facts to record in the row: the ja page's own stamp is 最終更新日
2026-03-04 UTC, and its html `lang` attribute is **`ja-x-mtfrom-en`** — Google marks the
page machine-translated from the en path. No lane artifact records either the mt marker
or the unclosed flip condition. Consequence to state: the row must never be cited
beyond terminology (its sentences are MT renderings of the en doc), and the flip
condition needs either an en-twin capture or a restated trigger.

**F-7 (verified non-findings, for the record):**
- W04 14 → 16: cross-scope duplicate URLs only; no E04; exit 0 preserved; scopes
  differ from S007/S019/S032/S018 so no `supersedes` is required.
- Entry-body quote rendering: the two new entries normalize apostrophes to straight
  (') where the pages use curly (’) — e.g. E2 "OIDC provider's issuer URL" vs the
  page's provider’s — and E1 splices the RFC sentence with a lowercased sentence-initial
  "If". Measured with the lane's own locator: E2's issuer-URL quote count=0 as written,
  count=1 with the page's curly form; E1's RFC splice count=0 as written, count=1 with
  the capital form; the capture rows for S069/S070/S068 preserve the pages' exact forms
  and locate. This is the lane-wide convention (all round-30 entry bodies and capture
  rows use straight apostrophes) and the census does not gate entry-body quotes, so it
  is not scored as a defect; recorded because the round-24 lesson ("Reject the original
  lowercase S007 excerpt as an exact quote: the same locator returned exit 1/count 0")
makes the verbatim-form fix cheap if the L1 wants locator-exact body quotes.
- E1's `"What is the audience"` (line 66) is the entry's own prose in scare quotes, not
  a source quote — cleared on read (my locator sweep flagged it; it is not attributed to
  a row).
- S061 `claims_supported` verified (aud/iat/iss present, sub absent); S062
  provider:claim key form and the available-in-session sentence verified; S063's
  landed registry row, entry 1's corrected table row, and my independent measurement all
  agree (no `Audience` request parameter; `Audience` is a response element; ProviderId
  must not be specified for OIDC) — the staged defect was correctly flipped in-round.
- My own fetch digests reproduce the committed capture rows exactly on the five
  byte-stable pages (S061, S062, S063, S067, S068, plus S069/S070) and match the
  **normalized** digest on all four response-coupled pages (S064, S065, S066, S071) —
  independent corroboration of the committed captures.

## Used-by reciprocity (verified)

S066 is cited by both entries, so its used-by lists both paths and both entries'
`source:` lines carry S066 — verified in the landed state and mirrored in my block.
All other rows: S061–S065, S067, S068 → entry 1 only; S069, S070, S071 → entry 2 only.
The census enforces reciprocity in both directions (SC_USEDBY_NOCITE / SC_ENTRY_CITE);
the landed state satisfies both.

## Touched surfaces

Written (all under `.ufo/waves/round-31/`):
- `build/assimilation/registry-append.md` — the 11 rows, ready-to-append, plus the
  row-identity digest table transcribed from the committed capture file (11/11 verified
  byte-exact).
- `build/assimilation/renumber-map.md` — staged id → lane id per document, with URLs.
- `build/assimilation/reg-ids`, `staged-ids`, `collisions` — collision artifacts.
- `RowsDraft-report.md` (this file) and `build/RowsDraft.md` (same content, the
  milestone trailer path named in the brief).

Lane production files: **not modified** (read-only for this seat). No git/jj
mutation anywhere. No installs (none needed; all work done with the lane's own
`rendered-text-v1.py` locator/digest tool, the lane census, the fleet census, and
python3).

## Out of scope / not done

- Entry-file text edits (E1/E2), the S063/S067 anchor corrections, and the S071
  tier/scope correction are **L1 decisions** — lane production files are read-only for
  this seat; every fix is specified above with exact evidence and the verified census
  outcome of each option.
- The en twin of S065's ja page (`cloud.google.com/iam/docs/workload-identity-federation`)
  was not fetched — it is outside the 11 declared re-open URLs, so the F-6 flip
  condition stays open by design of the declared fetch set.

## Cleanup

Scratch `/fast/scratch/hyaku/kagi-r31/RowsDraft/` — **deleted** (all fetch bodies,
clones, and intermediate files removed; `rm -rf` verified). Receipts first copied into
the wave dir as required. Nothing written outside
`.ufo/waves/round-31/{,build/assimilation/}` and scratch.
