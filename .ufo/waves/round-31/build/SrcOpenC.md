# SrcOpenC — build-scoped findings (round-31 C2 src-open, group C)

**3/3 re-opened, 3 `mined`, 0 refused.** Paste-ready rows: `.ufo/waves/round-31/src-open/group-c.tsv`
(final ids per the wave map: C1→S069, C2→S070, C3→S071; column 3 already computed over the final id).
Receipts: `.ufo/waves/round-31/src-open/group-c-receipts.txt`. Full report: `.ufo/waves/round-31/SrcOpenC-report.md`.

| final | URL | HTTP | bytes | raw sha256 | normalized sha256 | quote — location |
|---|---|---|---|---|---|---|
| S069 | `https://www.1password.dev/brokered-access` | 200 | 215346 | `6179e9c1…3c6fa93c` | `232239dd…cf003b50` | “All configured claims must match to verify the workload’s identity.” — §Custom Workflow (OIDC), ordered setup steps 1-5, item 3 (claims) |
| S070 | `https://www.1password.dev/brokered-access/custom-workflow` | 200 | 266770 | `a34902cc…1e28eca0b` | `20fbc423…c26a76271` | “The client authenticates using your OIDC token, workload ID, and the integration key configured by your administrator” — §Step 3: Use your Environment in your workflow, SDK-client sentence |
| S071 | `https://1password.com/jp/product/credential-broker` | 200 | 200638 | `a5d4a101…ece3aa3f5` | `0c2d13e5…47f1b6813a` | “実行時にAIエージェントとマシンワークロードを検証し、それぞれが受け取る権限を持つ認証情報のみを提供します。” — §1Password Credential Broker マシンとAIエージェントによる実行時の認証情報アクセス, hero lead sentence |

All three: exit 0, no redirect, `decoded-http-body-volatile-v1`, `rendered-text-v1`.

## Findings the L1 must act on

1. **Same-URL rows and the fleet rule.** S069's URL already exists at S007/S019/S032; S070's equals S018's after the
   fleet normalizer strips `/`. `/home/vgpnk/Projects/shokunin/scripts/sources-census.sh` emits **W04** (warning,
   allowed) for the same URL under a *different* scope cell, but **E04** (error) for the same URL under the *same*
   scope cell without a `supersedes S###` teaches cell (lines 645/649). Write S069/S070 scope cells as the new claim
   (issuer/claims/audience/integration key), not a copy of S007/S018, and no E04 fires. The lane census has no
   cross-row URL rule, so it would not catch this. No other lane carries either URL; the `/jp/` URL is fleet-new.
2. **Staged pins are stale.** 2026-10-23 prefixes `11c2476e…` / `bd85d733…` / `654571f5…` match none of today's
   bodies (`6179e9c1…` / `a34902cc…` / `a5d4a101…`). Quotes still locate → not refused; the entry must carry today's
   digests with `verified-at: 2026-11-03`, and the staged `recheck:` command cannot be re-run.
3. **Glyph delta on S069's quote.** Staged `workload's`/`provider's` use ASCII U+0027; the page serves U+2019
   (`workload’s`). Literal locate of the staged spelling = 0; page glyph = 2. Row quote uses the fetched glyph.
4. **S071 is declared but never cited in the staged entry body** (`[S095]` ×0; `[S092]` ×8, `[S093]` ×3). Still keep
   it as a row (frozen 11-row shape), but the entry's single `source:` line must list S071 or `SC_USEDBY_NOCITE`
   fires; and its tier needs a recorded call (S005, the English product page, is tier C; census needs ≥1 A/B, which
   S069/S070 supply, but the plan prose says “tier-A rows”).
5. **Volatility evidence.** C1/C2 byte-stable across 5 captures but carry a Next.js `buildId`/deploy id; C3 gave
   6 distinct raw digests in 7 captures while its normalized digest was identical 7/7 — the normalized digest is the
   reproducible attestation for S071.
6. **`bytes` is the decoded body length**, not `%{size_download}` under `--compressed` (38918/40545/42664 compressed
   vs 215346/266770/200638 decoded).
7. **Column 7's name vs the plan argv.** `curl-fsSL-compressed-v1` documents `--compressed -A '…'`; the plan names
   `curl -fsSL --max-time 30`. Attested with the plan argv; C1/C2 decoded bodies are identical under the census
   argv (control in receipts).
8. **S070's quote is not a raw-literal substring** (an `<a>` element splits it) — `rendered-text-v1` is required.

## Cleanup / constraints

No lane git/jj op, no commit/push, no credential or vault contact, no tool install, no pacman. Scratch
`/fast/scratch/hyaku/kagi-r31/SrcOpenC` (17 capture bodies) deleted and verified absent.
