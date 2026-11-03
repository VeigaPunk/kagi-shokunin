# SrcOpenC — round-31 C2 src-open, group C (1Password custom-OIDC sources)

**Verdict: 3/3 staged sources re-opened in-round, 3 `mined`, 0 refused.** Every quote below was located
in the bytes fetched today by the lane's declared command; full 64-hex digests and command receipts are in
`.ufo/waves/round-31/src-open/group-c-receipts.txt`, the paste-ready rows in `…/src-open/group-c.tsv`.

Lane `/home/vgpnk/Projects/shokunin/kagi-shokunin` @ frozen BASE `655e620651808ac04bb59bfa35b81227f62a031b`;
plan `plans/round-31.md` (C2); staged entry (READ-ONLY)
`/home/vgpnk/Projects/shokuknow/merge/kagi/knowledge/corpus/knowledge/cdp-bridge-1password-oidc-workflow.md`.

## Captures

Draft ids follow the seat assignment; final ids follow the wave renumber map (`build-spec.json`, by document,
verified by URL): **C1→S069 (staged S092), C2→S070 (staged S093), C3→S071 (staged S095)**. Column 3 of the TSV
is already computed over the final id; the L1 replaces column 1 and keeps column 3 unless the map changes.

| draft | final | registered URL | HTTP | bytes | raw sha256 | normalized sha256 |
|---|---|---|---|---|---|---|
| C1 | S069 | `https://www.1password.dev/brokered-access` | 200 | 215346 | `6179e9c1408515293f7fdf9b6445a4318e5a1289fc036fbb7559a21e3c6fa93c` | `232239dd8ae8e792148706d72c1c13707a3a6a195046141950e10448cf003b50` |
| C2 | S070 | `https://www.1password.dev/brokered-access/custom-workflow` | 200 | 266770 | `a34902cc251b9d9c9573ff25d7bd9a230494689a4cc9a6c99775c1f1e28eca0b` | `20fbc423c4faea7839316780ef28a5fad24e30982cbc9636e3f9c46c26a76271` |
| C3 | S071 | `https://1password.com/jp/product/credential-broker` | 200 | 200638 | `a5d4a10132d672c46c5afab0ad373418830554177eb688c6d659528ece3aa3f5` | `0c2d13e54cc059d0b39fceb0e8f9c02ccb4a0847529442dfae669647f1b6813a` |

Quotes, each with its location:

1. C1/S069 — **“All configured claims must match to verify the workload’s identity.”**
   Location: §Custom Workflow (OIDC), ordered setup steps 1-5, item 3 (claims). The page's raw HTML carries
   exactly one `<ol>` for this flow with **5 `<li>` items**; item 3 is the claims item. Rendered locator: count=2
   (one visible prose occurrence, one duplicate inside the surviving hydration JSX payload).
2. C2/S070 — **“The client authenticates using your OIDC token, workload ID, and the integration key
   configured by your administrator”**
   Location: §Step 3: Use your Environment in your workflow, SDK-client sentence. Rendered locator: count=1.
3. C3/S071 — **“実行時にAIエージェントとマシンワークロードを検証し、それぞれが受け取る権限を持つ認証情報のみを提供します。”**
   Location: §1Password Credential Broker マシンとAIエージェントによる実行時の認証情報アクセス, hero lead
   sentence (the heading is at rendered offset 161, the sentence at 189). Rendered locator: count=1.

Representation for all three: `decoded-http-body-volatile-v1`; normalization `rendered-text-v1`.

## Method (exact)

- Attested capture per URL: `curl -fsSL --max-time 30 '<registered url>' -o <file> -w '%{http_code} %{url_effective} %{size_download}'`,
  exit 0, HTTP 200, **no redirect** (`url_effective` equals the registered URL), Japanese page kept native
  (no `?hl=`, no `Accept-Language`). Bodies fetched in `/fast/scratch/hyaku/kagi-r31/SrcOpenC`, digests and
  byte counts computed there, receipts copied out, scratch deleted (verified; see Cleanup).
- Normalization and quote location: `python3 corpus/rendered-text-v1.py digest|locate` on each saved body.
- Row identity: `printf '<final-id>\tmined\t<url>\n' | sha256sum`, cross-checked against the TSV column 3
  (all three MATCH) — the exact `sources-census.sh:262` recomputation.
- No other external host was contacted; only the three declared URLs (plus same-URL stability re-fetches).

## Findings for the L1

**F1 — the same-URL rows meet a fleet rule with an error path the lane census does not have.** S069's exact URL
is already registered at S007, S019 and S032; S070's URL equals S018's after the fleet normalizer strips the
trailing slash (`url_of()` in `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh`). That script emits, per
its own header (line 25) and body (lines 645/649):
  - `W04 duplicate url … across scopes` — a **warning** (allowed; the plan counts 14 at round start) when the same
    URL reappears under a *different* scope cell;
  - `E04 duplicate url … within scope` — an **error** when it reappears under the *same* scope cell and the new
    row's `teaches` does not say `supersedes S###`.
Action for the registry rows: write S069/S070 scope cells that state the new claim (the custom-OIDC trust
decision: issuer, claims, audience, integration key) — distinct from S007/S019/S032/S018 — and do not claim
supersession. That yields W04 warnings only. Copying S007's or S018's scope verbatim would fail the fleet validate
at round end, which `corpus/sources-census.sh` (the lane script) would never catch: it has no cross-row URL rule
(`grep duplicate` matches only duplicate registry ids and `duplicate-provenance`). Fleet grep over every live
`SOURCES.md` finds neither URL outside kagi's own wave snapshots, and the `/jp/` URL nowhere at all, so no
cross-lane surprise is in play.

**F2 — the staged 2026-10-23 pins do not reproduce today.** Staged page-fetch prefixes `11c2476e3733ceff`
(S092), `bd85d7332dda43d0` (S093), `654571f5f88fc6bc` (S095) match none of today's bodies (`6179e9c1…`,
`a34902cc…`, `a5d4a101…`). The pages moved in the 11 days between the staged pin and this re-open; the staged
quotes still locate, so no row is refused. Consequence: the adopted entries' `source:` line must carry today's
capture digests with `verified-at: 2026-11-03`, not the staged prefixes; the staged `recheck:` command (which
pipes a page through `grep -c` against 2026-10-23 text) cannot be re-run as written.

**F3 — staged transcription glyph delta on C1's quote.** The staged entry writes `workload's` / `provider's`
with ASCII U+0027; the page serves U+2019 (`workload’s`, `provider’s`). Under the declared normalizer a literal
locate of the staged spelling returns **count=0**; the page glyph returns **count=2**. The anchor is present —
this is transcription normalization, not a missing anchor — and the row quote uses the fetched glyph. Do not
“fix” the capture row to the staged spelling; if the entry prose is copied from staging, its straight
apostrophes are prose, not locator targets.

**F4 — S095/S071 is declared but never cited in the staged entry's body.** `grep` over the staged entry:
`[S092]` ×8, `[S093]` ×3, `[round-1 S057]` ×1, **`[S095]` ×0** (S095 appears only in a front-matter `source:`
line). The entry's claims are all S092/S093; the Japanese page supplies locale terminology the body never uses.
Three consequences the L1 must decide together:
  - the census allows exactly **one** `source:` line per entry, so the three staged `source:` lines must collapse
    into one line listing S069, S070, S071 (the plan already says so);
  - `SC_USEDBY_NOCITE` requires each mined row's `used-by` file to carry that row's id — so S071 must appear in
    that single `source:` line (or its `used-by` must name another file carrying `S071`), else the census fails;
  - tier: S071 is the Japanese rendering of the same product page whose English row **S005 is tier C**
    (“positioning, not configuration mechanics”). The census needs only ≥1 tier A/B id in the entry (S069/S070
    supply that), but the plan's predicate prose says “only adopted `mined` tier-A rows”. Marking S071 tier B is
    defensible only if the locale-terminology claim is recorded and the S005 tier-C precedent is named; marking
    it C keeps the lane's own precedent and passes the census gate; dropping it shrinks the frozen counts
    (rows 60→70) and needs a plan correction **before** the first work commit. Seat advice: keep the row (shape),
    tier C or B by recorded rationale, and cite it in the single `source:` line.

**F5 — why all three are `volatile-v1`.** c1/c2 are byte-identical across 5 captures (4 plain + 1 census-profile)
but carry `"buildId":"6aea288dc4fda768c27b88d2"` and a `dpl_…` deploy id — deployment-coupled, so the raw digest
is a point attestation and not a drift pin. c3 is stronger: **7 captures (4 plain + 3 census-profile), 6 distinct
raw digests, 7/7 identical normalized digests** — the raw body is response-coupled while its rendered text is
stable. Practical upshot: for S071 the normalized digest is reproducible even though the raw digest is not; for
S069/S070 both are stable within the session.

**F6 — `bytes` is the decoded body length, not `%{size_download}` under `--compressed`.** Under the census
profile the compressed transfer sizes were 38918 / 40545 / 42664, while the representation lengths are
215346 / 266770 / 200638. The attested captures (plain argv) report body size directly; if a later re-open uses
`--compressed`, do not paste `%{size_download}` into `bytes`.

**F7 — column 7's name and the plan's fetch command describe different argv.** The census shape-checks the literal
`curl-fsSL-compressed-v1`, whose documented argv (TSV header) includes `--compressed -A 'kagi-shokunin-round23/1.0
(documentation verification)'`; the plan text names `curl -fsSL --max-time 30`. I attested with the plan argv and
ran the documented census argv as a control: c1 and c2 produced **the same decoded bodies** (same sha256), while
c3's raw bytes vary across fetches by nature. The declaration is therefore accurate for these rows; the
divergence is an observation, not a defect to fix in this wave.

**F8 — C2's quote is not a raw-literal substring.** The raw HTML splits it with
`<a href="/brokered-access#custom-workflow-oidc" class="link">integration key configured by your administrator</a>`;
raw literal count is 0, rendered locate is 1. A `raw-literal-v1` row could not carry this quote — the declared
`rendered-text-v1` normalization is what makes it contiguous.

## Census-integration checklist (advisory)

1. Append the three capture rows with column 1 set to `S069`/`S070`/`S071`; leave columns 3-16 as written
   (column 3 already matches `sha256("<id>\tmined\t<url>\n")`).
2. Registry rows: status `mined`, `opened 2026-11-03`, `recheck 180d`, `used-by
   corpus/knowledge/cdp-bridge-1password-oidc-workflow.md`; tiers as decided under F4 (S069/S070 tier A).
3. Entries: one `source:` line naming S069, S070, S071 with today's digests; keep one `verified-at:` / `recheck:`.
4. Counts on the frozen shape: rows 60→71, captures 60→71 — these three rows are 3 of the 11; entries_sourced
   8→10 is driven by the two entry files, not by these rows.

## Constraints honored / cleanup

- Read-only lane production files; wrote only `src-open/group-c.tsv`, `src-open/group-c-receipts.txt`, this report
  and `build/SrcOpenC.md`. No lane git/jj operation, no commit, no push, no fleet-root write.
- No credential read, no `op`/vault/account/handler/CDP contact, no secret material in any artifact; no feed-token,
  token-totality or release-clock work touched.
- No tools installed or upgraded; no pacman transaction.
- Scratch `/fast/scratch/hyaku/kagi-r31/SrcOpenC` held the 17 capture bodies (C1 5, C2 5, C3 7), then was
  **deleted**; deletion verified (`test -e` false) after the receipts and TSV were written.
