# Round 21 — mistakes mined from the lane's own record

Base `aea7a43`. Rows `M1–M8` are re-opened from the round-21 STATE dossier §4 with every pointer re-verified at this worktree (cited lines are current), plus `M9–M12` from `corpus/lessons/*.md` and `SCORECARD.md` errata that dossier missed.
`captured-by (before)` was checked against `SKILL.md` §Anti-patterns and `corpus/QUALITY.md` §Admission bar QA1–QA8 — no existing row captures a class, so every before cell is `none`; `captured-by (after)` names the criterion appended in `corpus/QUALITY.md` §Criteria from mistakes (round 21).
`M8` is the honest-stop model, not a defect, and takes no criterion; every other row's fix names what landed or the open unblock.

## Mistakes

| id | class | evidence pointer | captured-by (before) | captured-by (after) | fix |
|---|---|---|---|---|---|
| M1 | Overclaim / stale provenance — a property of a file absent from the host asserted in current voice | `SCORECARD.md:454` §Round-19 correction; `corpus/knowledge/config-layering.md:58` (`af8873ca…`); `corpus/knowledge/handler-on-disk-state.md:3`; `corpus/knowledge/handler-trust-boundary.md:3,6`; `corpus/knowledge/janitor-env-contract.md:4` | none | QM1 | mark those lines historical in an append-only erratum; never expand `af8873ca…` — named debt, still open (`corpus/lessons/round-19-recensus.md` §Named debt) |
| M2 | Wrong mechanism attribution — `uniq -d` said to exit 1 on empty input; measured exit 0 (GNU coreutils 9.x and the uutils builtin) | `corpus/lessons/round-15.md:112` §Corrigendum; `corpus/lessons/round-16.md:134` §6 | none | QM2 | re-measured and corrected in round 16; the round-15 body stays as the record |
| M3 | Fail-open verdict — `SKIP` read as clean, and a summary can print PASS while a `FALSIFY FAIL` line sits above it | `corpus/lessons/round-10.md:44`; `corpus/lessons/round-10.md:63` (CE3); `corpus/lessons/round-16.md:68` | none | QM3 | `UNVERIFIED` verdict plus `SQLITE3_BIN` selftest case landed in round 10; `mutate_case` now counts failures in round 16 |
| M4 | False hermeticity — a selftest advertised scratch-tree proof while two cases executed the real handler | `corpus/lessons/round-18.md:31` §The defect worth fixing, item 1 (line 37) | none | QM4 | `skip-case … substrate-absent` landed in `corpus/surface-census.sh`; the class itself had no written rule |
| M5 | Unclaimed landing — the `--dotenv-bytes` arm and its records landed with no claim row, a stale stamp and a stale selftest pin | `git show --stat aea7a43` (`corpus/op-ref-probe.sh` +130); `corpus/stamps.tsv:45` (`660 28660` vs `wc -lc` 788/34362); `corpus/claim-ledger.tsv:27` (R12-02 pinned 29 cases while the probe at `aea7a43` prints `OP_REF_SELFTEST: PASS (36 cases)`) | none | QM5 | landed this round (C1): ledger row R21-01 added, R12-02 re-pinned to the measured 36, the probe re-stamped, six `DOTENV_OBS` ids in `knowledge/op-ref-consumption.md` §11 |
| M6 | Round-identity reuse — a second round-16 execution and a reused driver launch counter 16 while rounds 17–19 existed | `SCORECARD.md:468` §Current baseline — round-16 re-dispatch; `corpus/lessons/round-20.md:9` | none | QM6 | preserved and dated as a re-execution, never renumbered; no rule existed |
| M7 | Placeholder in a durable artifact — `<FILL ON STAMP>` committed in a lesson and never filled | `corpus/lessons/round-13.md:9`; `corpus/lessons/round-19-recensus.md:40` §Named debt | none | QM7 | named debt only; still open — the fix is not a debt row |
| M8 | Honest stop (model, not a defect) — route admission refused; no dispatch, no receipt, no fabricated completion | `corpus/lessons/round-20.md:39` (`KAGI_ROUTE_ADMISSION: BLOCKED (roles=7 mismatched=7 …)`, exit 2; the round-20 admission script was lane-local scratch, never committed) | none | none — kept as the model | keep as the model for a blocked round; a blocked attempt is a record, not a verified round |
| M9 | Declared freeze not honoured — the author kept editing after the freeze, so wave comparisons ran against a revision that no longer existed (round-9 "gate before cite" lesson, third recurrence) | `corpus/lessons/round-12.md:84-98` §L2 wave ("the freeze was stale on arrival") | none | QM8 | final numbers re-measured after the last edit; the movement is recorded and the cost kept |
| M10 | Advertised-but-unwired mode — `--falsify` defined but absent from parser and dispatch, and its mutations silently no-opped on files without a trailing newline | `corpus/lessons/round-16.md:66-67` §Defects found while landing, items 6–7 | none | QM9 | wired and repaired in round 16 (mutation trailer, failure counting) |
| M11 | Absence claim without a valid sweep — an "unreachable" reading and "`grep …` is empty" sentences falsified by the sweep's own needle text | `corpus/lessons/round-14.md:139`; `corpus/lessons/round-18.md:7`; `corpus/lessons/round-19-recensus.md:49` §Audit detail | none | QM10 | round-14 corrected in-round; the round-18 sentences stay live — mark the prose lines historical (round-19 audit, open) |
| M12 | Misattributed cross-artifact citation — a citation whose target row does not carry the claim; the ownership question left unassigned | `corpus/lessons/round-17.md:100-103` §4 | none | QM11 | false attribution removed; the ruling remains honestly unassigned — reported, not absorbed |

## Gate

Round 21, steered (kaika steer table, kagi row, in the fleet-ledger worktree on branch `kaika/ledger`), base
`aea7a43`, worktree branch `kaika/round`. Bar: `corpus/QUALITY.md` §Admission
bar QA1–QA8 (written before dispatch) and §Criteria from mistakes QM1–QM11
(appended this round from §Mistakes above). Legacy-header baseline for QA4: at
`aea7a43`, `grep -l '^recheck:' corpus/knowledge/*.md | wc -l` → 0 of 21.

### Candidates considered

| candidate | origin | verdict | reason (criterion) |
|---|---|---|---|
| byte fidelity of `op run --env-file` (six classes) | round-20 attempt; arm landed unclaimed in `aea7a43` | **admitted** into `knowledge/op-ref-consumption.md` §11 | re-measured on op 2.41.0 (`OP_DOTENV_BYTES: CLEAN (checks=6 failed=0)`, exit 0); reviewer `admit-with-limits`, limits carried in the entry (QA3, QA4) |
| "the six PASS rows are the complete dotenv contract" | round-20 §Gate | **rejected** again | widens a measured path into a general contract (QA3) |
| E1 machine credential custody boundaries | W1 ART candidate 1 | **admitted** `knowledge/onepassword-machine-credentials.md` | S001–S004, S006, S007 re-opened; preview status stated (QA2); boundaries kept apart (QA8) |
| E2 SOPS recipient vs data key vs values | W1 ART candidate 2 | **admitted** `knowledge/sops-age-key-rotation.md` | S009–S011 re-opened; two [INFERENCE] lines labelled |
| E3 Vault/OpenBao token, lease, KV clocks | W1 ART candidate 3 | **admitted** `knowledge/vault-openbao-token-lease-lifecycle.md` | S012–S016 re-opened; Vault and OpenBao attributed separately |
| OIDC federation trust policy | W1 ART candidate 4 | **deferred** to README `## Frontier` | sources not opened this round, so no row and no entry (contract rule 1) |
| secret scanning detection vs verification | W1 ART candidate 5 | **deferred** to Frontier | unopened; adjacent to chousa/kasegi/kumitate hygiene tripwires (QA7 — round-21 connector sweep) |
| NIST key-management draft status | W1 ART candidate 6 | **deferred** to Frontier | unopened (rule 1) |
| "`op run` makes the machine credential short-lived" | W1 ART rejection | **rejected** | S001 scopes the *delivered environment* to the process; S004's token controls are separate (QA8) |
| "Credential Broker removes every secret from CI" | W1 ART rejection | **rejected** | S007's GitHub setup stores an integration key as an organization secret; S006 calls it an encryption key (QA2, QA3) |
| "removing an age recipient alone completes rotation" | W1 ART rejection | **rejected** | S011 orders recipients → data key → values (QA8) |
| "a Vault KV read carries a lease" | W1 ART rejection | **rejected** | S013: the KV backend "does not issue leases" (QA8) |
| S005 product page as mechanism support for E1 | registry | **rejected as support**, kept as a tier-C `queued` lead | a product page carries no anchorable mechanism (QA1) |
| S008 SOPS README as support for E2 | registry | **rejected** row | the README now only points at getsops.io; flip recorded in the row |

### New `corpus/SOURCES.md` rows (opened 2026-10-19; full quotes and fetch sha256 in each row)

| id | URL | location | quote (≤25 words) |
|---|---|---|---|
| S001 | https://www.1password.dev/cli/secrets-scripts | §Use `op run` to pass environment variables from a 1Password Environment | "provisioned for the duration of the process." |
| S002 | https://www.1password.dev/connect | Connect-server diagram caption | "The Connect server is part of your environment, and communicates to Your Apps using access tokens and a REST API." |
| S003 | https://www.1password.dev/connect/get-started | §Deployment, Step 3 | "Create a new token for each application or service you use." |
| S004 | https://www.1password.dev/service-accounts/security | §Token rotation and revocation | "You can rotate or revoke service account tokens." |
| S005 | https://1password.com/product/credential-broker | §The platform identifies the job | "Credential Broker checks the workload's identity against your policy, then delivers the exact credentials that specific job is approved for." |
| S006 | https://1password.com/blog/1password-credential-broker-public-preview | §How it works (published 2026-07-28) | "unlike a service account token that carries standing access, the organization-wide integration key is an encryption key" |
| S007 | https://www.1password.dev/brokered-access | §Custom Workflow (OIDC) | "All configured claims must match" |
| S008 | https://raw.githubusercontent.com/getsops/sops/main/README.rst | §Documentation | "You can find the SOPS documentation on getsops.io" |
| S009 | https://getsops.io/docs/usage/identities/age/ | §Encrypting using age (last modified 2026-05-15) | "It is also possible to use `updatekeys`, when adding or removing age recipients." |
| S010 | https://getsops.io/docs/usage/identities/key-groups/ | §Key groups | "By default, the threshold is set to the number of key groups." |
| S011 | https://getsops.io/docs/usage/key-management/ | §`rotate` command | "Use `updatekeys` if you want to add a key without rotating the data key." |
| S012 | https://developer.hashicorp.com/vault/docs/auth/jwt | §JWT verification, Vault 1.17 note | "must exactly match at least one of the `aud` claims declared for the JWT." |
| S013 | https://developer.hashicorp.com/vault/docs/concepts/lease | §Lease, renew, and revoke | "All dynamic secrets in Vault are required to have a lease." |
| S014 | https://openbao.org/docs/auth/jwt/ | §JWT/OIDC auth method (2.7.x) | "The JWT auth method can be used to authenticate with OpenBao using OIDC" |
| S015 | https://openbao.org/docs/auth/jwt/oidc-providers/kubernetes/ | Kubernetes note (2.7.x) | "The JWT auth engine does not use Kubernetes' `TokenReview` API during authentication" |
| S016 | https://openbao.org/docs/concepts/tokens/ | §Token hierarchies and orphan tokens (2.7.x) | "When a parent token is revoked, all of its child tokens -- and all of their leases -- are revoked as well." |

Rows touched in place this round: none (all 16 are new).

### Spot-check

**Pending — not performed by the lane.** The non-author spot-check of ≥1 admit
and ≥1 reject is the orchestrator's, after this round lands; the lane's own
reviewer/critic/sentinel L2s are still the lane (`LEARNING.md` §Discernment).
No `agree`/`disagree` is recorded here, and none is inferred.

## Named debt (found or carried this round)

- `bash corpus/claim-ledger.sh cells` → exit 2, `unrecognised round heading … '## Round 20 — interactive attempt; blocked, not completed (2026-10-15)'`: the cell audit has refused the scorecard since `93ab9a5` (round 20). `R13-01` was likewise left at 20 while the file held 21 headings; re-pinned this round (QM5 class). The heading is a filed record and is not rewritten here; the fix (a gate rule for attempt sections, or an operator ruling on the heading) is round-22 work.
- `claim-ledger.sh verify` is not run by the lane on this host: its untagged `R18-01` row runs `drift-pins.sh`, whose symbol checks read host files including the dotenv path when present (round-21 scout, `drift-pins.sh:45-77,191-246`). Rows are re-run individually instead.
- Stale stamps left unpinned on purpose (inherited, not touched this round): `knowledge/config-layering.md`, `knowledge/handler-on-disk-state.md`, `knowledge/handler-trust-boundary.md`, `knowledge/janitor-env-contract.md`, `lessons/round-18.md` — re-pinning them without review would bless edits no round claimed.
- Probe instrument debt (reviewer M1–M3, minor m1–m6): op-side failures read as `DRIFT` not `SETUP`; failing rows print no observed hex; the byte selftest proves the comparator only; stdin not redirected; usage omits the byte arm.
- `SKILL.md` §Falsification still says `PASS (29 cases)` (line 641): the line carries the reference-scheme token, so editing it would put that token in the round diff and trip the fleet sweep; left for a token-free rewrite.

## Provider exhaustion (recorded, not a lane defect)

The first batched L2 dispatch (11 members) was refused twice with `Background job limit reached (100)` and spawned on the third identical call. Once it ran, all four executor seats died on `resource_exhausted` (free model rate limit); of their re-dispatch, three died on `turn_rate_limit_exceeded` and one (ExecSources) landed. Recovery: the ExecDepth slice was finished by the L1; E2/E3 and the census gate were re-dispatched once more and landed. No claim was shrunk to dodge it.

## Post-landing review (`c41af82`; appended — sections above unchanged)

Two lane L2s re-opened the landed commit: a reviewer (gate, ledger, stamps) and
a critic (re-opened S001–S004, S006–S007, S009–S016). Both are still the lane;
this is not the outside spot-check. Dispositions:

| finding | source | disposition |
|---|---|---|
| census gate passes rows whose id is off-shape (leading space, `S17`, `s017`) | reviewer | **agree** — fixed: `SC_MALFORMED` over every `## Registry` table line; selftest cases added |
| only the first column-1 `source:` line is read | reviewer | **agree** — fixed: a second one is `SC_ENTRY_HEADER` |
| absolute or `../` `used-by` paths skip the handshake | reviewer | **agree** — fixed: `SC_USEDBY_MISSING` unless the path is a repo-relative corpus knowledge or lessons markdown file |
| tier-C sole support not enforced | reviewer | **agree** — fixed: `SC_ENTRY_CITE` when no cited row is tier A/B |
| legacy entries (no `source:`) escape every check, incl. the credential scan | reviewer | **agree, kept as a stated bound** — legacy entries already carry ref-scheme prose, so scanning them would fail by construction; documented in the gate's usage; planned round-22 freshness claim moves them under the census |
| E3's clock table merged products and paths (Kubernetes path generalised to "IdP"; OpenBao TTL labelled "Vault/OpenBao"; KV "nothing expires") | critic | **agree** — erratum appended to the entry; the gate (QA1/QA8) let it through, so QA9 added |
| E1 omitted Broker eligibility (EPM Business) | critic | **agree** — reproduced on S006 (`available for all Enterprise Password Manager Business customers`); erratum appended |
| S007 marks the custom-OIDC workflow "public beta" | critic | **disagree (not reproduced)** — the opened guide page contains no "public beta" string; recorded as unverified in the E1 erratum and as a SOURCES lead |
| QM5 ("`verify` before commit") not met: `verify` was not run on this host | critic | **agree** — QM5 was unmet as written for `c41af82`; QM12 appended as the documented substitute (individual safe rows + stamp check + skipped-row list) |
| E2 "independent custodians"; E2/E3 absence sweeps cover corpus mentions only | critic | **agree** — errata appended |
| stale counts: README ledger/stamp/declaration rows; `SKILL.md` §Falsification `29 cases`; QM1/QM6 line locators | critic | README rows refreshed; QUALITY locator note appended; the `SKILL.md` line stays (its rewrite would put the ref-scheme token into the diff) |

**Lesson.** The admission bar checked that a claim had a tier-A anchor and a
status, not that every qualifier on the source sentence (product, path,
eligibility, per-feature status) survived into the entry. Two of three entries
passed the bar on first landing and failed a re-read of their own sources —
the bar, not the entries alone, was the defect. Criterion added:
`corpus/QUALITY.md` QA9. The gate's fail-open paths were found the same way: a
selftest that proves each finding fires does not prove nothing can pass
unseen; mutations that *should* fail but did not are the missing half (QM3's
class, recurring in a gate written this round).
