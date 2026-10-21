# ConnectSources — S001–S007 versus the E1 feature-link omission

Axes: **calibration (C1)**, **freshness (C2)**.
Read revision: `c2cab35bc92e57e39e5489bac3386db078345b3f` (HEAD).
Seat: read-only. No install. No census run. No vendor re-fetch.

## Evidence

Frozen path in `corpus/SOURCES.md` (base line 26): **S001 → S004 → S002 → S003 → S006 → S007**. S005 is inside the numeric span and outside the path: tier C, status `queued`, `used-by` `—`, product-page lead, not mechanism support (`corpus/lessons/round-21.md` gate: S005 rejected as E1 support).

E1 `source:` at base lists those six ids only. `verified-at` is 2026-10-19, “six cited public documentation pages”. `recheck` is 90d for S001–S004 and on-release for S006–S007, and it says to reopen “Broker preview status” as one check. The parenthetical under `Reverify: R21-02` states the census re-verifies the citation chain and does not re-open pages.

S007 anchor is one URL, `https://www.1password.dev/brokered-access`, “Page title (public preview), introduction, §GitHub Actions and §Custom Workflow (OIDC)”, opened 2026-10-19, fetch sha256 `e4aef238bb5c93080bc0e1cc2156d0f8d19c9291dbbee60193bd42485686f818`. Teaches quotes on that row are workflow duration, “All configured claims must match”, and “the token value is your integration key”. No child URL. No per-workflow status. S006 (`https://1password.com/blog/1password-credential-broker-public-preview`, published 2026-07-28, sha256 `39a869df8807696009d98bd6d0a86bc27524af65f94f235d37e6dd5a6e514c1f`) teaches the encryption-key versus standing service-account distinction and “is in public preview”. The eligibility sentence is not in the S006 teaches cell.

E1 item 4 (base) applies that guide/announcement “public preview” to Credential Broker, including both GitHub Actions and the OIDC wording, citing only S006 and S007. Items 1–3 stay on S001–S004 custody splits and are not the outside disagreement.

Round-21 erratum (base, appended): eligibility reproduced from S006 as “available for all Enterprise Password Manager Business customers”, and from S007 as setup “in 1Password Business”. Same erratum: “the custom-workflow sub-page was not opened separately”; custom-OIDC release status left **unverified**; item 4’s “public preview” kept as the guide label. Leads (base): “1Password Credential Broker custom-OIDC workflow sub-page” is still “lead only”.

Outside record, `corpus/lessons/round-21-verifier-spotcheck.md` §Adjudication: reviewer disagrees with the E1 admit because it “omits who can use Credential Broker and conflates GitHub Actions public preview with custom-OIDC beta”. Same paragraph: 14 fetch sha256 MATCH, **S005/S006 drift**; C2 debt is in-place ledger rewrites, **9 deleted `stamps.tsv` lines**, and five stale stamps. Round-22 debt named there is a feature-specific-status criterion and an E1 erratum that actually separates Actions preview from custom-OIDC beta. The landed round-21 erratum does not do that separation.

`corpus/sources-census.sh` `src_field` (line 121) is the first column-1 `source:` line plus whitespace continuations, then exit. A second `source:` line is `SC_ENTRY_HEADER`. Body errata are not citations. Mined `used-by` paths that fail `[ -e ]` are `SC_USEDBY_MISSING` (lines 169–171). `R21-02` in `corpus/claim-ledger.tsv` pins the exact verdict `rows=16 A=14 B=0 C=2 queued=1 mined=14 rejected=1 entries_sourced=3 legacy=21`.

Stamp match at this revision, `git show c2cab35:… | sha256sum` equals `corpus/stamps.tsv`:

| path | sha256 | lines | bytes |
|---|---|---|---|
| `corpus/knowledge/onepassword-machine-credentials.md` | `7635be813a930c43c233f378f31d8d80f8feb0e599ba61ec05985785a9b69adb` | 35 | 6240 |
| `corpus/SOURCES.md` | `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332` | 43 | 14261 |

Neither path is in `.ufo/waves/round-22/before.json` `stale_stamps` (six paths: four knowledge entries, `corpus/lessons/round-18.md`, `LOG.md`). `stamps.tsv` is unmodified at HEAD and has 63 non-blank rows, the count `R12-03` pins. The nine deleted stamp paths are not listed in this lane’s files.

Uncommitted drift on this tree (not the frozen base), `git diff` vs `c2cab35`: `corpus/QUALITY.md` +8, `corpus/SOURCES.md` +10, `corpus/knowledge/onepassword-machine-credentials.md` +33. Observed dirty hashes from `sha256sum` during this read: E1 `e885081e4d566af05080edde8e92de7692db4dc974b678b6020f2e30e68f96af` (68 lines, 8328 bytes); SOURCES `a4edd52c4fb62f60acff149b1136d67784bf8a68243645627580f9834965c305` (53 lines, 16757 bytes). Dirty rows S019 and S020 reuse the S007 and S006 URLs and say “supersedes” with no fetch sha256. S017/S018 name `…/brokered-access/github-actions/` and `…/brokered-access/custom-workflow/` and also have no fetch sha256. All four `used-by` values are `corpus/lessons/round-22.md`, which is absent at base and absent on this tree. Paths still end at S007. The unopened-lead bullet is still present; a later paragraph says that lead is now S018. QA10/QM13/QM14 cite the missing lesson. E1’s column-1 `source:` line is unchanged, so the new ids are not in `src_field`.

## Affected axes

C1: the defect is a decision, not a missing stamp. S007’s parent title is being used as the status of two workflows, and the round-21 eligibility sentence does not close that decision. Items 1–3 and the integration-key boundary (S006/S007 teaches) are separate decisions and were not the disagreeing admit.

C2: E1 and SOURCES are byte-fresh at `c2cab35`. A restamp, an in-place S006/S007 digest edit, or deletion of those rows would turn a calibration append into stamp laundering. Remote S005/S006 digest drift is already outside the local stamp. The five/six stale paths and the nine historic drops are a different set.

Census row-count and `R21-02` sit on the boundary: adding feature rows changes `rows`/`mined` and must be a journaled expectation migration. Weakening `R21-02` to “more rows” would harm C1 by counting authored rows.

## Proposed move

Keep S001–S007 immutable, including digests, dates, and the path string. Do not put E1 or SOURCES into the stale-stamp or nine-drop restore.

Score C1 as decisions:

- Reject a Broker availability/status claim with no plan.
- Reject one “public preview” bound to both GitHub Actions and custom OIDC when the only status URL is S007 (or S006).
- Reject counting the round-21 erratum as the status split. It leaves custom OIDC unverified.
- Admit S001 versus S004 (process environment versus token controls), S002/S003 (deploy credentials versus caller tokens), and S006/S007 integration-key custody (key remains, not a standing service-account token).
- Admit a status split only when each workflow has its own URL, distinct from `https://www.1password.dev/brokered-access` and from the announcement URL, plus its own fetch sha256, eligibility, and status. Same-URL “supersedes” rows do not open the omitted link.

Citation shape the census can actually see: one new lesson file whose single `source:` line names the new feature ids, file present before those rows are `mined`. Do not add a second `source:` line on E1. Do not rewrite E1’s existing `source:` / `verified-at` / `recheck` lines. Append the erratum and a new recheck sentence there. Journal old→new stamp triples for any file that grows, and append a successor to `R21-02`; leave the `rows=16` cell as the historic expectation.

Do not integrate the current dirty append as that shape. S017/S018 are the right URL class and are not yet digests; S019/S020 repeat parent URLs; the lesson they name does not exist; the lead and the path still describe the omission.

## Risks

- Handshake through a side lesson can go census-clean while E1 item 4 and its `source:` line still stop at S007. The typed-claim gate has to score item 4, not the lesson’s existence.
- Creating `round-22.md` only to satisfy `used-by` without digests makes mined rows look fresher than the 2026-10-19 parent fetches.
- Editing `R21-02` or `R12-03` in place repeats the ledger-rewrite debt the spotcheck already named.
- Treating S005/S006 remote drift as fixed by a local SOURCES restamp leaves the stored parent digests authoritative.

## Verification for the parent

After integration, not run here:

1. Old journal values for the two stamp rows equal the `c2cab35` hashes, line counts, and byte counts above. New values equal `sha256sum` and `wc -lc` of the integrated files. E1 and SOURCES are still absent from the restored nine-drop set.
2. `bash corpus/sources-census.sh` fails closed while a mined row’s `used-by` file is missing, and passes only after that file exists and its `source:` line contains each new id. Verdict row counts match the appended successor expectation. The historic `R21-02` pattern is still in the ledger.
3. Feature-claim selftest rejects the three bad decisions above, admits the S001–S004 and integration-key controls, and rejects a same-URL supersession row as a feature-link open.
4. `src_field` on the entry still returns only S001, S004, S002, S003, S006, S007.

## Limits

Vendor pages were not re-opened; child URLs appear only in the uncommitted diff. The nine deleted stamp paths were not reconstructed. `sources-census.sh` was read, not executed. Dirty-tree hashes are from this read of an uncommitted tree and are not base pins.
