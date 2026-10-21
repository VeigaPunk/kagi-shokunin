# ConnectOwnership — credential-broker status/eligibility boundary

Seat: KagiR22.ConnectOwnership. Axes: calibration (C1), freshness (C2). Read-only. No production edit, no stamp change, no subagent.

## Read revision

kagi-shokunin `c2cab35bc92e57e39e5489bac3386db078345b3f` (2026-10-19 22:05:06 -0300). Specialist bytes checked against `.ufo/waves/round-22/frozen/before/corpus/knowledge/onepassword-machine-credentials.md`. Sibling sentences taken from each repo HEAD. Dirty worktrees are listed under Limits and are not evidence.

## Evidence

Committed specialist record:

- `corpus/stamps.tsv` pins `corpus/knowledge/onepassword-machine-credentials.md` at `7635be813a930c43c233f378f31d8d80f8feb0e599ba61ec05985785a9b69adb`, 35 lines, 6240 bytes. Frozen file matches that pin.
- Item 4 is titled "Credential Broker public preview" and cites S006 and S007 together for the announcement and the setup guide.
- Round-21 erratum on that file: item 4 omitted eligibility; custom-OIDC per-workflow status is unverified because the feature sub-page was not opened. The guide label "(public preview)" is the guide's label.
- `corpus/SOURCES.md` pin `db134917dab989f24c3e33b5983fdac7240fd412c9ebdf94a77c76a8fe55b332`, 43 lines, 14261 bytes. S007 anchor is the page title "(public preview)" plus §GitHub Actions and §Custom Workflow (OIDC). The leads list keeps the custom-OIDC sub-page unopened. S005 is tier C, queued, not mechanism authority.
- `PROVINCE.md` pin `4a346e2df81f7b2e649914d0d99da974d6c484caf12fed1c6bd530d106a78523`, 62 lines, 10586 bytes. Worktree matches this pin. Line 62 places "OIDC workload-federation trust policy" on the frontier (explored, not held). Line 63 records the round-21 sweep: no sibling claims SOPS, OpenBao/Vault, Credential Broker, or workload-identity ground, and kama routes authenticated health checks here through L0.

Sibling province summaries, committed HEAD only:

- kama `1e41928aba2b81dd65ea75084918a7fadf453720`, `corpus/lessons/round-1-safety.md:86`, under "Ambiguities requiring L0 operator decision": "explicitly name the credential broker, header policy, redaction policy, and". `PROVINCE.md` refuses credential material and auth flows to kagi. The lesson names no plan, no preview or beta, and no 1Password feature path.
- kake `df6196b022a7fe9ac9a88af1293dc377a8197652` (2026-10-20 06:08:53 -0300), `corpus/SOURCES.md:52`: "GitHub Actions workflow lockfiles in public preview", changelog dated 2026-10-14, URL https://github.blog/changelog/2026-10-14-github-actions-workflow-lockfiles-in-public-preview. That row is a GitHub changelog, and the commit is later than kagi HEAD.
- tsukuroi `7cc59c8e3761ffb668067c47655216376f0a4e48`, `PROVINCE.md:123` OUT-003: sibling file `kagi-shokunin/PROVINCE.md` @ `c2cab35bc92e`, heading `# kagi-shokunin — Province`, quote `**Domain:** secrets & vault ops — the-janitor flows, credential hygiene evidence`. The proposition is custody ownership. It does not quote PROVINCE lines 61–63 or the specialist entry.
- kaidoku `aad0869012eef957f22e32b748833cc7370d6515` mentions the 1Password asar as a static-analysis surface. No eligibility and no release status. kagi PROVINCE already assigns binary reading to kaidoku and runtime auth to kagi.

Phrase scan of sibling `*.md` and `*.tsv` (skipped `.git`, `.jj`, `node_modules`, `.ufo`): the only "credential broker" sentence outside kagi is the kama lesson. Sibling "public preview" hits are the kake lockfile changelog and a kotodama OED access note. No sibling states Enterprise Password Manager Business eligibility or a custom-OIDC status.

Recorded vendor quotes (committed SOURCES / specialist erratum; this seat did not re-fetch):

- S006, §Try Credential Broker today, https://1password.com/blog/1password-credential-broker-public-preview, published 2026-07-28, opened 2026-10-19: "is in public preview".
- Specialist erratum, same S006 introduction and section: "available for all Enterprise Password Manager Business customers".
- S007, §Custom Workflow (OIDC), https://www.1password.dev/brokered-access, opened 2026-10-19: "All configured claims must match".

## Affected axes

C1: sibling ownership sentences are being readable as Credential Broker status or eligibility. C2: a matching stamp on `PROVINCE.md` and on the specialist file can be read as a fresh sweep and a fresh feature-page check. QA9 already requires product, path, eligibility, and per-feature status. This seat adds no criterion id and no domain.

## Proposed move

Hand these five decisions to the existing qualifier-gate cases. Count decisions, not rows.

Reject:

1. kama `round-1-safety.md:86` ("credential broker") as 1Password Credential Broker release status or plan eligibility. It is an L0 handoff noun.
2. kake `SOURCES.md:52` lockfile "public preview" as Credential Broker GitHub Actions status.
3. tsukuroi OUT-003, and the kagi domain sentence it quotes, as a re-verification of S006 or S007.
4. PROVINCE.md line 62 ("OIDC workload-federation trust policy" not held) as a custom-OIDC release status. Feature status stays on the specialist entry, where the sub-page lead is still unopened.

Admit one bounded control, specialist entry only:

- Product: 1Password Credential Broker.
- Guide / announcement label: public preview (S007 title; S006 quote above).
- Eligibility: Enterprise Password Manager Business, as the round-21 erratum records, with the guide's "1Password Business" setup scope.
- Custom OIDC: unverified. The guide title does not assign preview or beta to that path.

C2 on the same move: keep the three committed stamp rows above. Do not drop them. Do not restamp the dirty worktree. A later landing that appends a feature-page erratum journals old hash, lines, and bytes beside the new ones. State in that journal that the still-matching `PROVINCE.md` hash does not mean the sibling sweep was repeated after kake `df6196b0`.

## Risks

A string match on "credential broker" flags kama and can be misread as a failed ownership sweep, which would pull health-check policy into kagi. Skipping kake's 2026-10-20 changelog leaves the sweep sentence byte-fresh while the surveyed sibling corpus has moved. Restamping the dirty specialist file (`e885081e4d566af05080edde8e92de7692db4dc974b678b6020f2e30e68f96af`, 68 lines, 8328 bytes) or dirty `SOURCES.md` (`e4afe6d080b97741942c9e8a75e3d6df4284e983b53f54d5e7e88b88b4cebe3f`, 65 lines, 17417 bytes) would pin bytes this seat did not admit.

## Verification

Parent, after integration, not run here:

- `git show c2cab35bc92e57e39e5489bac3386db078345b3f:corpus/stamps.tsv` equals `sha256sum` of the three `git show` blobs named above.
- Worktree hashes in Risks still differ from those pins; no `claim-ledger.sh stamp` on the dirty paths in this wave.
- Qualifier-gate selftest includes the four rejects and the one bounded admit. A case that marks custom OIDC public preview or public beta from the S007 title alone fails.

## Limits

No pages re-fetched. No tests. No installs. Dirty kagi paths excluded from evidence: `corpus/QUALITY.md`, `corpus/SOURCES.md`, `corpus/knowledge/onepassword-machine-credentials.md`, `corpus/knowledge/vault-openbao-token-lease-lifecycle.md`, plus untracked `corpus/lessons/round-22.md` and `plans/round-22.md`. Tsukuroi `PROVINCE.md` and kake `SOURCES.md` are dirty on disk; the quotes above are from HEAD. Kotodama's "public preview" is an OED access note and is outside this boundary.

## Installs

None.
