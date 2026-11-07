# Round 57 — the previous round's numeric self-description becomes a checked surface (C1, calibration); an OpenBao audit-device custody trial measures the enable gate, the salted HMAC, log_raw disclosure, salt rotation and non-audited paths (C2, operability, capability)

source: S115 (https://openbao.org/docs/audit/); S116 (https://openbao.org/docs/commands/audit/), both opened 2026-11-07.

Frozen plan: `plans/round-57.md` (predeclaration `7aa1f4726e1f6bcdc8411d1a8b21828d49785173`; freeze epoch B
`03cbf656943b33bf93607f607bbbeb55d500b0f9` adds amendments A1 (observable contract) and A2 (measured enable
path), both before any candidate measurement; §Amendments). Claim BASE `1cda9e7ae4767b4133e283bfbc08266d4c86362d`.
Instruments: `plans/round-57-c1-check.py`, `plans/round-57-c1.sh`, `plans/round-57-c2.sh`,
`plans/round-57-controls.sh` (epoch-B receipt `.ufo/waves/round-57/controls/controls-prefreeze-epochB.txt`,
11 MATCH, 0 MISMATCH; INSTRUMENT hashes in that file).

## Claims

- **C1 calibration — the audited surface's numeric self-descriptions, 3 → 0.** The round-56 non-author
  spot-check (D5/D6) found three stale current-tense self-descriptions at the tip of last round's landing:
  `SCORECARD.md` "`--selftest` 18 cases" against the gate's 20, `LOG.md:1924` "four freeze epochs" and
  `corpus/lessons/round-56.md:9` "Three freeze epochs" against the six epochs the plan declares. No lane gate
  read that surface. This round lands `corpus/current-claims.py` (four statement classes — `N cases` naming
  recheck-replay, `N MATCH` on a named epoch receipt or a nearest preceding `A`-`F` revision, `W freeze epochs`,
  `N clocks` / `N/N MATCH` — each bound to a machine authority, UNBOUND failing closed, 13-case selftest),
  repairs the three statements and the two epoch references (capability row and round-56 note → epoch F /
  23 MATCH), and re-runs the frozen checker/counter at the landing.
  Frozen predicate (plan §C1 and counter header): `C1_CURRENT: value = MISMATCH+UNBOUND over POP when
  GUARD = 1, else FAIL; target 0 (BASE 3), population floor 8.` BASE `value=3 population=16`; landing
  `value=0 population=16 gate=1`.
- **C2 operability — OpenBao audit-device custody trial (capability acquisition), 0 → 5.**
  `corpus/openbao-audit-trial.sh` measures five documented audit-device mechanics on throwaway OpenBao 2.7.2
  dev servers: T1 the documented `bao audit enable` is refused on a default server and accepted with
  `unsafe_allow_api_audit_creation = true`; T2 the default device's salted `hmac-sha256:` form (stable,
  input-distinct, request/response echo, no plaintext); T3 a `log_raw=true` device writes the value and the
  client token in cleartext; T4 disable + re-enable at the same path rotates the salt; T5 `sys/seal-status`
  leaves no audit entry while a KV read does. Frozen predicate: `C2_AUDIT_TRIAL: value = PASS when the real
  run is HOLDS 5/5 twice, each shim flips its designated test, a PATH with no bao reads SETUP rc2 with no
  HOLDS, and a PATH wrapper emptying `audit list` flips T1; else 0. Target 5 (BASE 0).` BASE `value=0`;
  landing `value=5` with real=1 none=1 wrap=1 secret=1.

## Gate

- **Admit S115** — https://openbao.org/docs/audit/, opened 2026-11-07 with a browser user agent (HTTP 200,
  decoded body 41787 B, sha256 `76339ff7dab618b5e5532bca6daf9dd8361330a43b737408304abfd1d79090c6`,
  `.ufo/waves/round-57/capture/S115.body`). Located quote (18 words): “Audit devices must be enabled by a
  root user using bao audit enable or using the audit stanza.” (§Enabling and disabling audit devices). The
  same page grounds the salted-HMAC sentence (15 words: “Most strings contained within requests and responses
  are hashed with a salt using HMAC-SHA256.”), the `log_raw` parameter row and the non-audited path list.
  Tier A for OpenBao 2.7.x audit-device behaviour; the trial measures it.
- **Admit S116** — https://openbao.org/docs/commands/audit/, opened 2026-11-07 with a browser user agent
  (HTTP 200, 33338 B, sha256 `3dc8873201fdb3a971eb5fb1c1cee6a804462510c962ea5df6121cad0d9905ce`,
  `.ufo/waves/round-57/capture/S116.body`). Located quote (21 words): “even if you re-enable the audit device
  at the same path, as a new salt will be created for hashing.” (§Disable warning). The §Examples block is
  the documented `bao audit enable file file_path=…` path, which the 2.7.2 binary refuses by default (T1).
- **Admit the knowledge entry** `corpus/knowledge/openbao-audit-device-custody.md`: every mechanism claim
  cites S115/S116 and carries a located quote or the trial verdict; the measured table is the round's runs;
  bounds and falsifiers are stated. QA1/QA2/QA3 hold (tier-A rows with anchors, release scope named, the
  "does not establish" block).
- **Reject: the OpenBao API page** `https://openbao.org/api-docs/system/audit/` (fetched 2026-11-07,
  HTTP 200, 334 B) — it is a stub/redirect body with no mechanism text; a row would teach nothing and its
  anchor could not be located. Flip: a rendered API page carrying the endpoint parameters.
- **Reject: the labrat's config-removal + SIGHUP route as the T4 measurement** — it is a valid independent
  observation (measured: salt rotation `bca9f764…` → `7472b3b0…`), but the documented `audit disable`
  path is the one the page names; the SIGHUP route stays as a corroborating note in the entry, not a test.
  Flip: a release where the API disable of a config-managed device succeeds.
- **Assimilation: none** this round (no `merge/kagi/` theme taken; the audit ground is new coverage, not a
  staged package). `considerthese/read`: the 2026-10-26 §Self-improvement proposals were screened; the one
  that fits (`bind committed numbers to their live source`) is already the C1 gate, so no proposal is
  claimed as new.

## Mistakes

| id | class | evidence pointer | captured-by | fix |
|---|---|---|---|---|
| M57-1 | `stale-self-description` (three committed current-tense numbers about the lane's own instruments were stale at the tip; no gate read them) | `SCORECARD.md:1850` "`--selftest` 18 cases" at BASE; `LOG.md:1924`; `corpus/lessons/round-56.md:9`; `.ufo/waves/round-56/…` | the non-author closure spot-check (D5/D6), not a lane gate | `corpus/current-claims.py` audits the previous round's landing surface against executed authorities (C1); the three statements repaired |
| M57-2 | `freeze-epoch-drift` (the C2 counter bytes changed after the predeclaration `7aa1f47`; the plan still carried the sketch contract) | freeze-check by R57ScribeLesson (frozen sha `3de6b4de…` vs worktree `140a8f2b…`); epoch-B receipt | a wave seat reading the frozen instrument, not the L1 | disclosed epoch B `03cbf656` in the same commit that updates the plan predicate and re-runs the 11-control battery; both epochs named in the report |
| M57-3 | `plan-instrument-contract-drift` (plan text said `AUDIT_TRIAL: CLEAN (tests=5 pass=5)` while the lane's trials use `TRIAL T<n> HOLDS` + one summary line) | `plans/round-57.md` §C2 before A1; `corpus/openbao-audit-trial.sh` header | the scribe seat's freeze check; A1 names it | A1 rewrites the predicate in the plan and the counter header; the counter now parses the lane convention |
| M57-4 | `stale-premise` (the plan assumed the documented `bao audit enable` works on a default dev server; OpenBao 2.7.2 refuses it) | labrat probe, `.ufo/waves/round-57/w1/R57Labrat.md`; trial T1 refusal text | the labrat seat's independent probe, not the plan | A2 makes T1 measure both sides (refused by default, accepted with `unsafe_allow_api_audit_creation`); the divergence is an entry fact |
| M57-5 | `label-drift` (the trial seat's shim table listed SH4/SH5 vectors against the wrong test order) | `R57ExecTrial.md` §deliverables vs the counter's EXPECT map; counter read `vectors=5/5` on the reference trial | cross-check against the frozen counter, not the seat's table | the counter's `EXPECT` map is authoritative; the seat's receipt is kept as wave history with the correction noted |
| M57-6 | `token-on-argv` (a scout's probe started a dev server with the root token visible in argv before the seat cleaned up) | the exec seat's ps note; no surviving process at the L1 re-check | a sibling seat's process check, not the sentinel (yet) | trial rule unchanged (token via `BAO_DEV_ROOT_TOKEN_ID` only); recorded, sentinel asked to triage the seat's report |

| M57-7 | `seat-claim-contradicted-by-tree` (a connector seat asserted all four instruments were untouched and quoted the ExecGate draft's 10-case selftest as if landed; the epoch-B commit had already changed three of them and the landed gate runs 13 cases) | `.ufo/waves/round-57/w1/R57Connector.md`; epoch B `03cbf656`; `corpus/current-claims.py` selftest | the sentinel's tree check, not the seat's own read | the seat's sentence is not cited as evidence; the landed gate's hash is recorded in `.ufo/waves/round-57/final/landing-receipt.txt` |
| M57-8 | `overclaimed-amendment-wording` (A1 said "before the trial existed and before any candidate measurement", while the labrat probe, the trial file (11:15:43) and the executor's first receipts predate the epoch-B commit; the plan's pre-freeze-controls sentence still says "executed before this commit" over an 11:19 receipt) | `plans/round-57.md` §A1 and §Pre-freeze controls; sentinel timeline | the sentinel seat's timeline check | the record keeps the false sentence as history; the report states the timeline verbatim and the epoch split; the next round's predeclaration must be committed before any candidate file is written |
| M57-9 | `draft-versus-landed-instrument` (the reviewed 10-case gate port and the landed 13-case gate are different bytes; the report must name the landed hash, not the draft's) | `R57ExecGate.d/` draft `40ec0c64` vs landed `corpus/current-claims.py` (hash in the landing receipt) | the sentinel's hash comparison | the landing receipt records the landed hash and the C2 trial's measured hash (`7e645194…`, 10922 B) beside the pre-fix one (`3e8bcc4c…`), and the entry names the measured bytes |

## Sources

- Registry 114 → 116 (S115, S116; both tier A, status `mined`, `recheck on-release` bound to the S090
  OpenBao releases feed). No in-place cell changes to existing rows; no row deleted.
- Sources opened this round: S115, S116 (the trial's two pages). Existing rows re-used: S090 (OpenBao
  releases feed, clock binding), S105 (PKI page, not re-opened), S106/S107 (setpriv/pdeathsig, unchanged).
- Census: `scripts/sources-census.sh validate --root /home/vgpnk/Projects/shokunin kagi` — start
  (`census-start.txt`) `kagi ok` rc 0, 114 rows; end `kagi ok` rc 0, 116 rows.

## Adjacency

Connector sweep (`.ufo/waves/round-57/w1/R57Connector.md`): no sibling lane holds an OpenBao/Vault
audit-device trial or a committed-self-description gate; the shared shape (a stable-id outcome ledger
whose numbers are re-derived by a command) is reported to the integrator, not absorbed. The S115/S116 URLs
appear in no sibling registry (search over `*-shokunin/corpus/SOURCES.md`); audit-device ground is not
claimed in any sibling `PROVINCE.md`.
