# OidcEntry1 — seat report (round-31 BUILD wave, C2)

Seat: `OidcEntry1` (scribe). Lane: `/home/vgpnk/Projects/shokunin/kagi-shokunin`.
Frozen BASE `655e620651808ac04bb59bfa35b81227f62a031b`. Claim served: **C2 coverage** (entry 1 of the
two OIDC-theme entries).

Draft: `.ufo/waves/round-31/build/OidcEntry1.md` — the full re-grounded entry text, landing
candidate for `corpus/knowledge/oidc-federation-trust-policy.md`.

## 1. Behaviour — what I did

1. Read the frozen contract (`plans/round-31.md`), the staged entry
   (`/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/oidc-federation-trust-policy.md`,
   READ-ONLY), the staged registry (`/home/vgpnk/Projects/shokuknow/merge/kagi/SOURCES.append.md`),
   the merge report, the landed house-shape example
   (`corpus/knowledge/secret-scanning-detection-vs-validation.md` lines 2–4), the lane's census
   (`corpus/sources-census.sh`), and the claim-ledger's `docs` audit rules.
2. **Verified the renumber map by URL, not by arithmetic** (the spec's rule). For each of the 8
   adopted rows I compared the staged entry's own `source:` URL against the staged registry row's
   URL and confirmed the staged id ↔ URL ↔ document binding. All 8 agree. Result: the staged map
   in my seat brief (S052→S061 … S065→S068) is correct and is the **only** correct reading — the
   staged ids S052–S057/S064–S065 are all `<=` the lane's live id space (the lane already owns
   S052–S060), so the ids genuinely had to move. The lane's live S052–S060 are different documents
   (Atom RFC 4287, Gitleaks, TruffleHog, Betterleaks, GitHub search API, TruffleHog ×4), so
   overwriting them would have destroyed the round-30 secret-scanning rows.
3. **Re-opened all 8 URLs in-round** myself with the lane's declared profile
   (`curl -fsSL --max-time 30`, plus the lane capture profile `curl -fsSL --compressed -A
   'kagi-shokunin-round23/1.0 (documentation verification)'`), independent of the sibling
   `SrcOpenA/SrcOpenB` receipts. Every raw digest I measured matches the sibling receipts
   exactly (S061 `141dd4819db34dc2`, S062 `fb5b2e35ec37c18b`, S063 `a08888ce4d86adf2`, S064
   `116398b3807c1016`, S065 `0179cc57506a632e`, S066 `0e2d9afdfda461bd`, S067 `4d016752a645e8a3`,
   S068 `9919d061d40a9788`). Independent corroboration of the receipts the entry will cite.
4. **Located every anchor and quote in the re-opened bodies** (26 quoted strings, each checked
   for presence on the page it is cited to). Zero absent. Nine are page-wide phrases that occur
   more than once — the quote is still verbatim on the cited page, but a reviewer counting
   occurrences will see >1; noted in §5.
5. **Re-grounded the entry**: one column-1 `source:` line carrying all 8 rows in the new ids;
   `verified-at:`, `recheck:`, `ground:`, `Reverify:` in the landed shape; all in-text `[Sxxx]`
   refs re-pointed by document; body claims, the bounds section and the tables kept; every
   sentence that asserted more than its anchor tightened (see §3).
6. **Landed the draft in a scratch fixture and ran the lane's own gates against it** — this is
   where the non-obvious coupling in §4 was found, not guessed.

## 2. Gates actually run (all in scratch, never in the lane)

| # | Gate | Where | Result |
|---|---|---|---|
| G1 | `bash corpus/sources-census.sh` | fixture with my draft as the entry | **CLEAN**, `rows=68 … entries_sourced=9 legacy=21 captures=68` — the 8-row shape the plan predicts for entry 1 alone |
| G2 | same, with the **staged** entry dropped in unedited | fixture | **FAILED** — 8× `SC_USEDBY_NOCITE` + `SC_ENTRY_HEADER … multiple source: lines` + `SC_ENTRY_CITE id=S052 used-by-omits-entry`. The staged file's 8 separate `source:` lines cannot land: the census allows ≤1 column-1 `source:` line per entry. **The staged text is not landable as-is** — the merge must be re-grounded, not appended. |
| G3 | `bash corpus/claim-ledger.sh docs` | fixture with my draft | Rejects the placeholder `Reverify: R31-C2` (`Reverify value matches neither form: R31-C2`): the ledger parses ids strictly as `R<digits>-<digits>`. Expected for a draft-stage placeholder — the L1 must substitute the real row id. With a real-looking id the only remaining findings are `MISSING-ID` (no such ledger row yet) and `UNPINNED` (entry not in `corpus/stamps.tsv`) — both L1 landing steps, not defects in the draft. |
| G4 | same census, **both** entries landed | fixture | **CLEAN**, `rows=71 … entries_sourced=10 … captures=71` — reproduces the plan's frozen predicate shape (`rows=71`, `entries_sourced=10`, `legacy=21`, `captures=71`) |
| G5 | credential sweep on the draft | draft | `grep -nE 'op://|AQAAAB\|client_secret\|password[[:space:]]*='` → **empty**; the census's own `CRED_RE` (op://, PRIVATE KEY, ghp_, AKIA, xox, AGE-SECRET-KEY-, hv[sbr].) → **empty** |

Tooling: no installs. `curl`, `python3` 3.14.8, `grep`/`awk`, and the lane's own
`corpus/rendered-text-v1.py` were the only tools used. Nothing was installed or upgraded, so
there is no tool/version/channel record to report beyond the above.

## 3. Tightenings applied to the staged body (each with its QA id)

The staged entry was faithful on 20 of its sentences. Six asserted more than their anchor; I
tightened each and kept the claim itself.

| # | Staged text | Why it over-asserted | QA | What the entry now says |
|---|---|---|---|---|
| T1 | "AWS requires the issuer URL to begin with `https://`, with no query parameters and normally no port" | The page says the URL **must** begin with `https://` but **should** correspond to the Provider URL, and **should not** contain a port number — three different modalities flattened into one | QA2 | Quotes each clause with its own verb: "must begin with https://", "should correspond to the Provider URL provided to IAM", "should not contain a port number" |
| T2 | "`iss` … Must match exactly the issuer URL registered with the provider" | AWS says *should correspond*; Alibaba's `oidc:iss` is the one that is strict (`条件值只能是您在 OIDC 身份提供商中填写的颁发者 URL`) | QA2 | Split per provider: AWS = "should correspond", Alibaba = "can only be the issuer URL configured in the OIDC identity provider" |
| T3 | "`sub` … it identifies the workload inside the issuer's namespace, not globally" | Over-general from the GCP page; AWS publishes `provider:sub`, Alibaba `oidc:sub` (optional, ≤10), GCP maps `assertion.sub` → `google.subject` | QA1 | Names each provider's spelling and grounds "not globally" in GCP's own collision warning |
| T4 | "GCP … subject `assertion.sub`" cited to the en page | The `assertion.sub` → `google.subject` mapping sample is on the **ja** page; the en page only says "Use a unique subject mapping" | QA1 | Sample now cited to S065 (ja), where it actually appears |
| T5 | "Alibaba … `oidc:aud`, **mandatory**, `StringEquals`" + "`oidc:sub`, **optional**, at most 10 values" | Correct on the page, but the staged cells did not name the mechanism (`必须使用 StringEquals`, `最多设置 10 个 OIDC 主体`) | QA6 | Cells now carry the page's own wording |
| T6 | "RFC 9700 states the symmetric obligation on the resource-server side" | RFC 9700 §4.10.2 is a **SHOULD**-level recommendation scoped to **access tokens**; the entry's other half is about **ID tokens**. Stating it as a symmetric *obligation* overstates the RFC and blurs the token type | QA2 | "the recommendation to use that audience restriction is SHOULD-level and its scope is access tokens; the ID-token case this entry is about is the issuer-side twin of the same obligation, not the RFC's own wording" |

Two further corrections are worth naming because they change what the entry asserts about AWS:

* **The staged "four dialects" table put `ProviderId` in the AWS STS *subject* cell.** The re-opened
  page says the opposite of what the cell implies: `ProviderId` is "the fully qualified host
  component of the domain name of the OAuth 2.0 identity provider" and the page says **"Do not
  specify this value for an OpenID Connect identity provider"** / "Do not specify this value for
  OpenID Connect ID tokens". For OIDC the subject is the token's `sub` (published as
  `provider:sub` condition keys); `Provider` carries `iss`. The cell is rewritten accordingly.
* **The staged body said AWS "treats all three [iss/aud/sub] as ordinary claim keys".** The AWS
  OIDC federation key table publishes `amr`, `aud`, `email`, `oaud`, `sub` — there is **no `iss`
  condition key**. The entry now states the actual key set and that the issuer is not among them.

## 4. Findings the L1 should attack first

**F1 — the staged file cannot land as-is; the merge must be re-grounded, not appended.**
Eight separate column-1 `source:` lines trip `SC_ENTRY_HEADER` (the census allows at most one),
and the staged ids are the lane's live ids for other documents. Gate G2 above is the reproduction.
My draft shows the landed shape.

**F2 — one column-1 `source:` line, and `used-by` must list *exactly* the citing entries.**
`SC_USEDBY_NOCITE` fires when a registry row's `used-by` names a path whose `source:` field does
not contain that id, and `SC_ENTRY_CITE` fires when a cited id's `used-by` omits the entry. Both
directions are enforced, so `used-by` and the `source:` line must be written together.

**F3 — entry 2's in-text `[round-1 S057]` must become `[S066]`, and that forces S066 into
entry 2's `source:` line.** Entry 2 cites the Alibaba row in prose only. If S066's `used-by` lists
entry 2 (it should — entry 2's body cites it), entry 2's `source:` field must contain S066, or the
census fires `SC_USEDBY_NOCITE`. I verified the whole shape end-to-end in G4: both entries landed
with **one** `source:` line each, S066 appearing in entry 2's `source:` line, and the census is
CLEAN at `rows=71 … entries_sourced=10 … captures=71`. Entry 2's own three rows land as S069/S070/S071.

**F4 — the campaign `fetch sha256` pins in the staged registry rows do not reproduce in-round, and
must not be copied into the landed registry as if they were.** Comparing the staged anchor cell
against the in-round capture: S061 `c69aea104f5fb072` → `141dd4819db34dc2`, S062 `c65b05feaf7e5140`
→ `fb5b2e35ec37c18b`, S063 `e5349f6cbfdbc717` → `a08888ce4d86adf2`, S064 `ac85362d89649e66` →
`116398b3807c1016`, S065 `97c3149df09fbc90` → `0179cc57506a632e`, S066 `48173805d3c27af4` →
`0e2d9afdfda461bd`. Only S067/S068 (the two spec documents) reproduce exactly. The six HTML pages
are **deployment-coupled**: their raw bytes carry a per-request nonce, so their raw digest varies
per fetch while the normalized (`rendered-text-v1`) digest is stable. My `source:` line therefore
carries **both** digests for the six volatile pages, exactly as `SrcOpenA/SrcOpenB` classified them
(`decoded-http-body-volatile-v1`), and the registry `used-by`/capture rows must use the same
representation. My draft's `source:` line cites the sibling receipts' raw digests, which match my
independent measurements byte-for-byte.

Note the census's in-row-pin regex is `Fetch sha256: \`` (capital F, colon); the staged anchor
cells use lowercase `fetch sha256 \``, so those stale campaign digests are **not** in-row pins and
the census will not flag them for you. That is precisely why they need a human decision: do not
carry a 2026-10-23 digest into a row whose `opened` is 2026-11-03. My draft's `source:` line carries
the in-round digests.

**F5 — the `Reverify:` placeholder is not a valid ledger id.** The `docs` audit requires
`R<digits>-<digits>`; `R31-C2` is rejected (G3). The L1 substitutes the real claim-ledger row id
at landing; the draft marks the placeholder explicitly so it cannot be committed accidentally.

**F5b — do NOT add the new entry to the `used-by` of the lane rows the entry only mentions in
prose.** The entry's "What this entry does not establish" section names S012/S022 (Vault-side
audience) and S047/S050 (the lane's GitHub-OIDC rows) as **existing ground it does not cover**.
Those mentions are body prose, and the house precedent is exactly this: the landed
`secret-scanning-detection-vs-validation.md` names S048 and S055-S056 in prose, and neither row's
`used-by` lists that entry. If the L1 adds the new entry path to S012's or S047's `used-by` on the
reading "the entry cites it", the census fires `SC_USEDBY_NOCITE` for each — the row's `used-by`
must name only entries whose `source:` field carries that id. Reproduced in scratch: adding the
path to S012/S047 gives `SC_USEDBY_NOCITE id=S012` + `id=S047`, census exit 1. Only the eight
adopted rows' `used-by` change.

**F6 — two landing obligations the draft cannot satisfy for you.** The `docs` audit also requires
the entry to be a row in `corpus/stamps.tsv` (`UNPINNED` otherwise) and its `Reverify:` id to exist
in `corpus/claim-ledger.tsv` (`MISSING-ID` otherwise). Both appear in G3 and both are L1 steps.

**F7 — `README.md` §Frontier still lists the OIDC lead as unopened.** Line 116 says "**OIDC workload
federation trust policy** — … see `SOURCES.md` §Leads (unopened)". The round-30 precedent moved
the secret-scanning line to "moved to core in round 30 (S053–S060; …)". The equivalent README/§Leads
edit for the OIDC lead is an L1 landing step, and `SOURCES.md` line 102 ("GitHub, Google Cloud, and
AWS OIDC workload-federation trust-policy configuration — leads only, not evidence") needs the
same round-31 disposition note the round-30 lead disposition (SOURCES.md lines 119–120) carries.

**F8 — the two plan corrections landed after my frozen BASE do not move the renumber map, but one
of them adds a check the draft already satisfies.** `plans/round-31.md` gained "Plan correction 1"
(`2d46e57`) and "Plan correction 2" (`91f7752`) after `655e620`. Correction 2 clause 3 freezes two
per-row checks: every `S(06[1-9]|07[01])` row's `opened` column must be `2026-11-03`, and every
S-id on a new entry's `source:` line must be in `{S061..S071}`. Against my draft's eight rows:
the `opened` check prints nothing, and the ids on my `source:` line are exactly S061–S068, all
inside the allowed set. Correction 2 clause 4's tier fallback (a staged row may land tier B or C
with the reason recorded, and each entry keeps ≥1 tier-A support) does not bite here: all eight
of my rows are tier A in the staged registry, so my entry cites only tier-A rows and no fallback
is needed. Correction 1 is C1-only (migrations, `cells` predicate) and does not touch C2.
Neither correction renumbers anything, so the seat brief's map stands as written.

## 5. Staged sentences I could not ground, or grounded only loosely

Per the seat brief, listed here for the L1 to attack first. Note: these are **not** all defects —
several are staged-vs-anchor mismatches that I tightened in §3.

1. **"`sub` … it identifies the workload inside the issuer's namespace, not globally."** No anchor
   states this in these words. Loosely supported (AWS `provider:sub`, Alibaba `oidc:sub` ≤10,
   GCP's collision warning). Tightened (T3); the "not globally" half now rests on GCP's own
   "several external identities could map to the same IAM principal".
2. **"A multi-tenant IdP such as GitHub issues many subjects under one issuer; the distinguishing
   information is in the claims, not in the subject."** Not on any of the 8 anchors. The GCP
   best-practices page says use attribute conditions when federating with GitHub or other
   multi-tenant IdPs, and that multiple providers risk subject collisions; it does not say GitHub
   issues many subjects under one issuer, nor that the distinguishing information lives in the
   claims. **Dropped from the draft.** (QA1 — a domain claim with no tier-A anchor.)
3. **"the claim that does the load-bearing work, and it is the one most often left loose."** The
   "load-bearing" half is the entry's own argument (fine); "the one most often left loose" is an
   unsourced prevalence claim. Reframed in the draft to the supportable half.
4. **"the `aud` claim must equal the Audience value configured at IdP registration"** — supported
   ("The aud claim must match the Audience value when creating your IAM OIDC identity provider"),
   but the staged cell omitted that AWS words it as *match*, not *equal*. Kept, with the page's verb.
5. **"Alibaba … `oidc:iss` … 条件值只能是…"** — the staged table cell for `oidc:iss` said only
   "是" (mandatory). The page's actual constraint is stronger and more specific (the value must be
   the issuer URL configured in the OIDC identity provider, `StringEquals` only). Now stated.
6. **"the `aud` … MUST contain the OAuth 2.0 client_id … as an audience value"** — present verbatim
   on S067, and the staged entry's quoting is accurate.
7. **RFC 9700 §4.10.2 scope** — the staged entry quoted the RFC sentence accurately but framed it as
   a symmetric *obligation*. See T6.

Two **anchor-location** corrections the L1 should carry into the registry rows (the staged registry
cells mislocate the anchor; my `source:` line states the location I actually re-opened):

* **S066 (Alibaba).** The staged registry anchor says "§信任策略 → 限制条件表". The re-opened page
  has **no `信任策略` heading at all** — the table sits under `§创建OIDC身份提供商的RAM角色 →
  操作步骤` and the column header is `是否必选` ("required"), not `是否必填`. `SrcOpenB` independently
  recorded the same correction ("the page has no 信任策略 heading"). My `source:` line uses the
  location that exists.
* **S064 (GCP best practices) and S065 (GCP ja).** The `Use a single provider per workload identity
  pool…` / `Use attribute conditions…` / `Use the URL of the workload identity pool provider as
  audience` bullets appear **twice** on the en page (heading list and body list) — nine of my 26
  verified quotes are page-wide for this reason. If the L1 writes a "count=1" style locator, it
  will not hold for these nine.

## 6. Scope boundaries and out-of-scope items

* Lane production files are **unmodified**: I wrote only `build/OidcEntry1.md` and this report.
  No `corpus/` file, no `SOURCES.md`, no `corpus/stamps.tsv`, no `corpus/claim-ledger.tsv`, no
  `README.md`, no `SCORECARD.md`. No git/jj mutation of any kind; no commit, no push.
* The staged tree was read only (`/home/vgpnk/Projects/shokuknow/merge/kagi/**`).
* **Entry 2 is not mine.** `cdp-bridge-1password-oidc-workflow.md` and its staged rows S092/S093/S095
  belong to seat `OidcEntry2`; I did not write it. I only modelled its landing in a scratch
  fixture to test the cross-entry coupling in F3, because that coupling is invisible from entry 1
  alone and would have failed the census at landing.
* No credential material was read or written: no `op` sign-in, no vault/account/handler/CDP
  contact, no `op://` values. `op` was not invoked at all — this seat needed no 1Password surface.
  The only `op` reference in the whole wave is the product-documentation URL the staged entry
  already carried.
* No tool installs (see §2).
* Scratch: `/fast/scratch/hyaku/kagi-r31/OidcEntry1/` (raw fetch bodies, and five `fixture/`
  clones of the lane corpus used for the gates above). **Deleted before this report was written** —
  see §7.

## 7. Scratch hygiene

`/fast/scratch/hyaku/kagi-r31/OidcEntry1/` — removed with `shutil.rmtree` after the gates in §2 had
been run and their outputs pasted here. The fetch bodies and the five fixture clones are gone; the
lane and the staged tree were never written to. Nothing was left in `/tmp` (all scratch stayed
under `/fast/scratch/hyaku/kagi-r31/`).

## 8. Artifacts

| Path | What |
|---|---|
| `.ufo/waves/round-31/build/OidcEntry1.md` | the re-grounded entry draft (the deliverable) |
| `.ufo/waves/round-31/OidcEntry1-report.md` | this report |

The draft is the landing candidate for `corpus/knowledge/oidc-federation-trust-policy.md`, with the
`Reverify:` row id left as the marked placeholder for the L1 to substitute.
